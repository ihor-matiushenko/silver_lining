#!/usr/bin/env python3
"""
Silver Lining AI — Quantized GGUF 5-Scenario Evaluator (via llama-cli)

Verifies the final quantized .gguf artifact (e.g. silver-lining-270m-q4_k_m.gguf)
directly through llama.cpp (Apple Metal / ARM CPU) using the exact Gemma 3 chat
turn template (<start_of_turn>user ... <end_of_turn>\n<start_of_turn>model\n)
that llamadart uses on iOS & Android.
"""

import argparse
import json
import subprocess
import time
from pathlib import Path

from eval_benchmark import BENCHMARK_SCENARIOS


def format_gemma3_prompt(lang: str, text: str) -> str:
    return (
        f"<start_of_turn>user\n"
        f"[SilverLining | lang={lang}]\n{text}<end_of_turn>\n"
        f"<start_of_turn>model\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Evaluate quantized GGUF model on 5 scenarios.")
    parser.add_argument(
        "--gguf",
        type=str,
        default="/Users/ihormatiushenko/Workspace/silver_lining/ml_training/models/silver-lining-270m-q4_k_m.gguf",
    )
    parser.add_argument(
        "--llama-cli",
        type=str,
        default="/Users/ihormatiushenko/Workspace/silver_lining/ml_training/llama.cpp/build/bin/llama-completion",
    )
    parser.add_argument(
        "--output-json",
        type=str,
        default="/Users/ihormatiushenko/Workspace/silver_lining/ml_training/benchmarks/after_finetuned_270m_q4_k_m_gguf.json",
    )
    args = parser.parse_args()

    gguf_path = Path(args.gguf)
    size_mb = gguf_path.stat().st_size / (1024**2)
    print(f"Evaluating GGUF: {gguf_path.name} ({size_mb:.1f} MB disk)\n")

    results = []
    for item in BENCHMARK_SCENARIOS:
        prompt = format_gemma3_prompt(item["lang"], item["input"])
        cmd = [
            args.llama_cli,
            "-m",
            str(gguf_path),
            "-p",
            prompt,
            "-c",
            "1024",
            "-n",
            "150",
            "--temp",
            "0.0",
            "--special",
            "--no-display-prompt",
            "-no-cnv",
        ]
        t0 = time.perf_counter()
        proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
        elapsed = time.perf_counter() - t0
        raw_out = proc.stdout.strip()
        # Strip any trailing turn markers or CLI footer lines
        clean_out = raw_out.split("<end_of_turn>")[0].split("[ Prompt:")[0].strip()
        if clean_out.endswith("> EOF by user"):
            clean_out = clean_out[: -len("> EOF by user")].strip()

        print("=" * 80)
        print(f"[{item['name']}] ({elapsed*1000:.0f} ms)")
        print(f"Input : {item['input']}")
        print(f"Output: {clean_out}")
        results.append(
            {
                "id": item["id"],
                "name": item["name"],
                "lang": item["lang"],
                "input": item["input"],
                "output": clean_out,
                "wall_ms": round(elapsed * 1000, 1),
            }
        )

    out_path = Path(args.output_json)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(
            {"gguf_file": gguf_path.name, "disk_size_mb": round(size_mb, 1), "scenarios": results},
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print("=" * 80)
    print(f"Saved GGUF report -> {out_path}")


if __name__ == "__main__":
    main()

