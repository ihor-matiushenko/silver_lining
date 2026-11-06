#!/usr/bin/env python3
"""
Silver Lining AI — Reproducible MLX Adapter Fuse + GGUF Export & Quantization Pipeline

1. Selects the specified LoRA checkpoint (default: 0000700_adapters.safetensors).
2. Fuses LoRA weights into the Gemma 3 270M bf16 base model via mlx_lm.fuse.
3. Copies base tokenizer metadata and strips the out-of-range multimodal <image_soft_token>
   (ID 262144) so text-only Gemma 3 (vocab_size=262144) exports cleanly to GGUF.
4. Converts SafeTensors -> F16 GGUF via llama.cpp/convert_hf_to_gguf.py.
5. Quantizes to Q4_K_M and Q8_0 via llama-quantize and prints SHA-256 checksums.
"""

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8 * 1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    root = Path("/Users/ihormatiushenko/Workspace/silver_lining/ml_training")
    parser = argparse.ArgumentParser(description="Fuse MLX LoRA and quantize GGUF artifacts.")
    parser.add_argument("--base-model", type=Path, default=root / "models/gemma-3-270m-it-bf16")
    parser.add_argument("--adapter-dir", type=Path, default=root / "adapters")
    parser.add_argument("--checkpoint", type=str, default="0000700_adapters.safetensors")
    parser.add_argument("--fused-dir", type=Path, default=root / "models/silver-lining-270m-fused")
    parser.add_argument("--models-dir", type=Path, default=root / "models")
    args = parser.parse_args()

    ckpt_path = args.adapter_dir / args.checkpoint
    if ckpt_path.exists():
        shutil.copy2(ckpt_path, args.adapter_dir / "adapters.safetensors")
        print(f"Selected checkpoint: {ckpt_path.name}")

    subprocess.run(
        [
            sys.executable,
            "-m",
            "mlx_lm",
            "fuse",
            "--model",
            str(args.base_model),
            "--adapter-path",
            str(args.adapter_dir),
            "--save-path",
            str(args.fused_dir),
        ],
        check=True,
    )

    # Restore base tokenizer configs and strip multimodal token 262144 (>= vocab_size 262144)
    for fname in ("tokenizer.json", "tokenizer_config.json", "special_tokens_map.json"):
        src = args.base_model / fname
        if src.exists():
            shutil.copy2(src, args.fused_dir / fname)

    tj_path = args.fused_dir / "tokenizer.json"
    tj = json.loads(tj_path.read_text(encoding="utf-8"))
    tj["added_tokens"] = [t for t in tj.get("added_tokens", []) if t.get("id", 0) < 262144]
    if "vocab" in tj.get("model", {}):
        tj["model"]["vocab"] = {k: v for k, v in tj["model"]["vocab"].items() if v < 262144}
    tj_path.write_text(json.dumps(tj, ensure_ascii=False, indent=2), encoding="utf-8")

    for fname in ("special_tokens_map.json", "tokenizer_config.json"):
        p = args.fused_dir / fname
        d = json.loads(p.read_text(encoding="utf-8"))
        d.pop("image_token", None)
        if "extra_special_tokens" in d and isinstance(d["extra_special_tokens"], dict):
            d["extra_special_tokens"].pop("image_token", None)
        if "added_tokens_decoder" in d:
            d["added_tokens_decoder"] = {k: v for k, v in d["added_tokens_decoder"].items() if int(k) < 262144}
        p.write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")

    # Deduplicate tied embedding tensor (lm_head.weight == model.embed_tokens.weight in Gemma 3)
    # so GGUF stores token_embd.weight once instead of duplicating +168M parameters!
    from safetensors.torch import load_file, save_file
    import torch

    st_path = args.fused_dir / "model.safetensors"
    tensors = load_file(str(st_path))
    if "lm_head.weight" in tensors and "model.embed_tokens.weight" in tensors:
        if torch.equal(tensors["lm_head.weight"], tensors["model.embed_tokens.weight"]):
            del tensors["lm_head.weight"]
            save_file(tensors, str(st_path), metadata={"format": "pt"})
            idx_path = args.fused_dir / "model.safetensors.index.json"
            if idx_path.exists():
                idx = json.loads(idx_path.read_text(encoding="utf-8"))
                idx.get("weight_map", {}).pop("lm_head.weight", None)
                idx_path.write_text(json.dumps(idx, indent=2), encoding="utf-8")
            cfg_path = args.fused_dir / "config.json"
            cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
            cfg["tie_word_embeddings"] = True
            cfg_path.write_text(json.dumps(cfg, indent=2), encoding="utf-8")
            print("Deduplicated tied lm_head.weight -> saved 168M redundant parameters!")

    f16_gguf = args.models_dir / "silver-lining-270m-f16.gguf"
    subprocess.run(
        [
            sys.executable,
            str(root / "llama.cpp/convert_hf_to_gguf.py"),
            str(args.fused_dir),
            "--outfile",
            str(f16_gguf),
            "--outtype",
            "f16",
        ],
        check=True,
    )

    quantize_bin = root / "llama.cpp/build/bin/llama-quantize"
    for qtype in ("q4_k_m", "q8_0"):
        out_gguf = args.models_dir / f"silver-lining-270m-{qtype}.gguf"
        subprocess.run([str(quantize_bin), str(f16_gguf), str(out_gguf), qtype], check=True)
        mb = out_gguf.stat().st_size / (1024**2)
        digest = sha256_file(out_gguf)
        print(f"✅ {out_gguf.name:34s} | {mb:6.1f} MB | sha256={digest}")


if __name__ == "__main__":
    main()
