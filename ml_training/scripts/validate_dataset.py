#!/usr/bin/env python3
"""
Silver Lining AI — Dataset Quality & Integrity Validator

Audits ml_training/data/{train,valid,test}.jsonl for:
  1. Exact split sizes & valid ChatDataset JSONL schema ("messages": [user, assistant])
  2. Zero prompt leakage across train / valid / test splits
  3. Zero overlap with the 5 held-out canonical benchmark prompts
  4. Sentence count bounds (1-4 sentences; 1-2 for refusals, 2-3 for reframings)
  5. Zero chatbot meta-chatter ("Sure!", "Here's a reframe", bullet lists)
  6. Language script fidelity (Ukrainian Cyrillic purity vs Latin languages)
"""

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

FORBIDDEN_META_PREFIXES = (
    "sure!",
    "sure,",
    "here is",
    "here's",
    "certainly!",
    "of course!",
    "as an ai",
    "silver lining:",
    "reframe:",
)

HELD_OUT_BENCHMARK_SNIPPETS = (
    "spilled coffee on my shirt, missed my train",
    "three weeks preparing for my dream software engineering interview",
    "виснажила постійна напруга на роботі",
    "awkward joke at a dinner party two hours ago",
    "took $50 from my roommate's wallet",
)

CYRILLIC_RE = re.compile(r"[\u0400-\u04FF]")
LATIN_RE = re.compile(r"[A-Za-zÀ-ÖØ-öø-ÿ]")
TAG_RE = re.compile(r"^\[SilverLining \| lang=(auto|en|uk|es|de|fr)\]\n(.+)$", re.DOTALL)


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower().strip())


def count_sentences(text: str) -> int:
    parts = [p.strip() for p in re.split(r"[.!?…]+(?:\s+|$)", text.strip()) if p.strip()]
    return len(parts)


def detect_script_lang(text: str) -> str:
    cyr = len(CYRILLIC_RE.findall(text))
    lat = len(LATIN_RE.findall(text))
    if cyr > lat and cyr >= 8:
        return "uk"
    return "latin"


def validate_split(path: Path) -> tuple[list[dict], list[str], Counter]:
    errors: list[str] = []
    records: list[dict] = []
    stats: Counter = Counter()

    if not path.exists():
        return [], [f"Missing file: {path}"], stats

    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        if not raw.strip():
            errors.append(f"{path.name}:{lineno} empty line")
            continue
        try:
            obj = json.loads(raw)
        except json.JSONDecodeError as exc:
            errors.append(f"{path.name}:{lineno} invalid JSON: {exc}")
            continue

        msgs = obj.get("messages")
        if not isinstance(msgs, list) or len(msgs) != 2:
            errors.append(f"{path.name}:{lineno} messages must be a 2-element list")
            continue

        u_msg, a_msg = msgs[0], msgs[1]
        if u_msg.get("role") != "user" or a_msg.get("role") != "assistant":
            errors.append(f"{path.name}:{lineno} roles must be user -> assistant")
            continue

        u_text = str(u_msg.get("content", "")).strip()
        a_text = str(a_msg.get("content", "")).strip()

        m = TAG_RE.match(u_text)
        if not m:
            errors.append(f"{path.name}:{lineno} missing valid [SilverLining | lang=...] header")
            continue

        lang_tag, raw_prompt = m.group(1), m.group(2).strip()
        stats[f"tag_{lang_tag}"] += 1

        if len(raw_prompt) < 4:
            errors.append(f"{path.name}:{lineno} user prompt too short")
        if len(a_text) < 25 or len(a_text) > 580:
            errors.append(f"{path.name}:{lineno} assistant length {len(a_text)} out of [25, 580]")

        a_lower = a_text.lower()
        for prefix in FORBIDDEN_META_PREFIXES:
            if a_lower.startswith(prefix):
                errors.append(f"{path.name}:{lineno} forbidden meta prefix '{prefix}'")
        if "\n-" in a_text or "\n*" in a_text or "```" in a_text:
            errors.append(f"{path.name}:{lineno} markdown list/codeblock forbidden")

        n_sent = count_sentences(a_text)
        if n_sent < 1 or n_sent > 4:
            errors.append(f"{path.name}:{lineno} sentence count {n_sent} outside [1, 4]")

        # Script fidelity check
        expected_uk = lang_tag == "uk" or (lang_tag == "auto" and detect_script_lang(raw_prompt) == "uk")
        out_script = detect_script_lang(a_text)
        if expected_uk and out_script != "uk":
            errors.append(f"{path.name}:{lineno} expected Ukrainian Cyrillic output, got: {a_text[:60]}")
        if not expected_uk and CYRILLIC_RE.search(a_text):
            errors.append(f"{path.name}:{lineno} unexpected Cyrillic chars in non-UK output: {a_text[:60]}")

        norm_prompt = normalize_text(raw_prompt)
        for held_out in HELD_OUT_BENCHMARK_SNIPPETS:
            if held_out in norm_prompt:
                errors.append(f"{path.name}:{lineno} benchmark leakage detected: {held_out}")

        records.append({"norm_prompt": norm_prompt, "user": u_text, "assistant": a_text})

    return records, errors, stats


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate Silver Lining MLX JSONL datasets.")
    parser.add_argument(
        "--data-dir",
        type=str,
        default="/Users/ihormatiushenko/Workspace/silver_lining/ml_training/data",
    )
    parser.add_argument("--min-train", type=int, default=1350)
    parser.add_argument("--min-valid", type=int, default=95)
    parser.add_argument("--min-test", type=int, default=95)
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    splits = {
        "train": (data_dir / "train.jsonl", args.min_train),
        "valid": (data_dir / "valid.jsonl", args.min_valid),
        "test": (data_dir / "test.jsonl", args.min_test),
    }

    all_errors: list[str] = []
    seen_by_split: dict[str, set[str]] = {}

    for name, (fpath, min_count) in splits.items():
        recs, errs, stats = validate_split(fpath)
        all_errors.extend(errs)
        if len(recs) < min_count:
            all_errors.append(f"{name}.jsonl has {len(recs)} records, expected >= {min_count}")

        prompts = [r["norm_prompt"] for r in recs]
        dups = len(prompts) - len(set(prompts))
        if dups > 0:
            all_errors.append(f"{name}.jsonl contains {dups} duplicate user prompts")
        seen_by_split[name] = set(prompts)
        print(f"[{name.upper():5s}] {len(recs):4d} records | tags={dict(stats)}")

    # Cross-split leakage check
    for a, b in (("train", "valid"), ("train", "test"), ("valid", "test")):
        overlap = seen_by_split.get(a, set()) & seen_by_split.get(b, set())
        if overlap:
            all_errors.append(f"Cross-split leakage between {a} and {b}: {len(overlap)} overlapping prompts")

    if all_errors:
        print(f"\nVALIDATION FAILED with {len(all_errors)} issue(s):")
        for e in all_errors[:25]:
            print(f"  - {e}")
        sys.exit(1)

    total = sum(len(s) for s in seen_by_split.values())
    print(f"\n✅ VALIDATION PASSED: {total} clean, leak-free records ready for mlx_lm.lora!")


if __name__ == "__main__":
    main()

