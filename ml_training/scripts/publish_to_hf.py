#!/usr/bin/env python3
"""
Silver Lining AI — Hugging Face Hub Model Publisher (Phase 5)

Uploads our custom MLX LoRA fine-tuned GGUF artifacts (silver-lining-270m-q4_k_m.gguf
and silver-lining-270m-q8_0.gguf) plus a Model Card (README.md) with SHA-256 checksums
to a public Hugging Face Hub repository for free global mobile CDN distribution.

Usage:
  HF_TOKEN=hf_... ml_training/.venv/bin/python ml_training/scripts/publish_to_hf.py \
      --repo-id <your-hf-username>/silver-lining-gemma3-gguf
"""

import argparse
import hashlib
import os
from pathlib import Path

from huggingface_hub import HfApi


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8 * 1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def build_model_card(repo_id: str, artifacts: list[tuple[str, float, str]]) -> str:
    rows = "\n".join(
        f"| `{name}` | `{mb:.1f} MB` | `{sha}` |" for name, mb, sha in artifacts
    )
    return f"""---
license: gemma
base_model: google/gemma-3-270m-it
tags:
  - gguf
  - llama.cpp
  - llamadart
  - mlx
  - lora
  - on-device
  - mobile
  - cognitive-reframing
language:
  - en
  - uk
  - es
  - de
  - fr
---

# {repo_id}

Compact on-device Small Language Model fine-tuned via Apple `mlx-lm` LoRA (`r=16, alpha=32`) from `Gemma 3 270M` on 1,600 multilingual empathetic cognitive reframing & gray-area safety refusal examples for the **Silver Lining AI** mobile app.

## Quantized GGUF Artifacts

| File | Size | SHA-256 |
|---|---|---|
{rows}

## Recommended `llama.cpp` / `llamadart` Inference Settings
- **Prompt Template** (`parse_special = true`):
  ```text
  <start_of_turn>user
  [SilverLining | lang=en]
  <user_thought><end_of_turn>
  <start_of_turn>model
  ```
- **Sampling**: `temp = 0.0` (or `0.1`), `repeat_penalty = 1.0`, `n_ctx = 1024`, `n_predict = 150`.
"""


def main() -> None:
    root = Path("/Users/ihormatiushenko/Workspace/silver_lining/ml_training/models")
    parser = argparse.ArgumentParser(description="Publish Silver Lining GGUF models to Hugging Face Hub.")
    parser.add_argument("--repo-id", required=False, help="e.g. username/silver-lining-gemma3-gguf (auto-detected if omitted)")
    parser.add_argument("--token", required=False, help="Hugging Face Write token (or set HF_TOKEN env var)")
    parser.add_argument("--models-dir", type=Path, default=root)
    args = parser.parse_args()

    token = args.token or os.environ.get("HF_TOKEN")
    api = HfApi(token=token)
    repo_id = args.repo_id
    if not repo_id:
        user_info = api.whoami()
        username = user_info["name"]
        repo_id = f"{username}/silver-lining-gemma3-gguf"
        print(f"Resolved Hugging Face user: {username} -> {repo_id}")

    api.create_repo(repo_id=repo_id, repo_type="model", exist_ok=True)

    files = [
        args.models_dir / "silver-lining-270m-q4_k_m.gguf",
        args.models_dir / "silver-lining-270m-q8_0.gguf",
    ]
    artifact_meta = []
    for f in files:
        if not f.exists():
            raise FileNotFoundError(f"Missing artifact: {f}")
        mb = f.stat().st_size / (1024**2)
        sha = sha256_file(f)
        artifact_meta.append((f.name, mb, sha))
        print(f"Uploading {f.name} ({mb:.1f} MB) -> {repo_id} ...")
        api.upload_file(
            path_or_fileobj=str(f),
            path_in_repo=f.name,
            repo_id=repo_id,
            repo_type="model",
        )

    card_path = args.models_dir / "HF_MODEL_CARD.md"
    card_path.write_text(build_model_card(repo_id, artifact_meta), encoding="utf-8")
    api.upload_file(
        path_or_fileobj=str(card_path),
        path_in_repo="README.md",
        repo_id=repo_id,
        repo_type="model",
    )
    print(f"\n✅ Published successfully: https://huggingface.co/{repo_id}")


if __name__ == "__main__":
    main()

