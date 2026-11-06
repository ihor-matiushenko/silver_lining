#!/usr/bin/env python3
"""
Silver Lining AI — Local Teacher Knowledge Distillation Dataset Generator

Uses a local Ollama Teacher model (default: gemma3:12b) with JSON-schema constrained
decoding to synthesize 1,600 diverse, validated training examples across:
  - 75% (1,200) Empathetic Cognitive Reframings (2-3 grounded sentences)
  - 15% (  240) Gray-Area Safety Refusals (1 calm refusal sentence, zero rationalization)
  - 10% (  160) Edge Cases (ultra-short vents, colloquial slang, heavy grief validation)

Language distribution across every category:
  - 50% English (en), 25% Ukrainian (uk), 25% Spanish/German/French (es, de, fr)

Writes resumable progress to ml_training/data/raw_pool.jsonl, then performs a
deterministic stratified split into train.jsonl (1,400), valid.jsonl (100), test.jsonl (100).
"""

import argparse
import asyncio
import json
import random
import re
import time
from collections import defaultdict
from pathlib import Path

import httpx

LANGUAGE_NAMES = {
    "en": "English",
    "uk": "Ukrainian (natural, idiomatic Ukrainian in Cyrillic — NO Russian words or Surzhyk)",
    "es": "Spanish",
    "de": "German",
    "fr": "French",
}

REFRAME_DOMAINS = [
    "workplace burnout, overwhelming meetings, or feeling behind on tasks",
    "job search fatigue, rejected applications, or tough technical interviews",
    "social anxiety, replaying an awkward comment, or feeling left out at a gathering",
    "academic stress, a disappointing exam grade, or thesis procrastination",
    "unexpected bills, tight monthly budget stress, or costly car/home repairs",
    "parenting exhaustion, toddler tantrums, or guilt about work-family balance",
    "everyday morning chaos, missed transit, spilled drinks, or lost keys",
    "creative block, imposter syndrome in a new role, or comparing yourself to peers",
    "breaking a fitness/sleep streak, low energy, or slow recovery from a minor cold",
    "minor misunderstandings with a partner, roommate, or close friend",
    "accidental mistake in a presentation, production bug, or forgotten email attachment",
    "loneliness after moving to a new city or working remotely all week",
    "household clutter, laundry pileup, or ruined dinner recipe",
    "feeling behind on life milestones compared to friends on social media",
    "rainy gray weather ruining weekend plans or draining motivation",
]

PERSONA_VARIATIONS = [
    "a 24-year-old junior designer or developer early in their career",
    "a busy working parent juggling deadlines and school pickups",
    "a university student studying late before finals",
    "a mid-career freelancer dealing with unpredictable clients",
    "an introverted remote worker feeling drained after social events",
    "a healthcare, retail, or teacher professional after a chaotic shift",
    "someone trying to build healthier habits while feeling overwhelmed",
    "an everyday commuter dealing with frustrating minor setbacks",
]

REFUSAL_THEMES = [
    "taking cash or items from a roommate, coworker, or family member without asking and wanting comfort",
    "shoplifting groceries/clothes or keeping an expensive item the cashier forgot to scan",
    "padding work expense reports, falsifying timesheets, or minor tax/insurance dishonesty",
    "guessing a partner's or ex's password to secretly read their private messages",
    "sabotaging a rival coworker's project or spreading a rumor to get ahead",
    "cheating on an exam, buying a plagiarized paper, or faking a doctor's note",
    "keying someone's car, damaging property in anger, or petty vandalism for revenge",
    "harassing, doxxing, or sending cruel anonymous messages to someone online",
]

EDGE_THEMES = [
    "ultra-short 2 to 5 word exhausted vents (e.g., 'Completely drained today', 'Nothing is working') -> warm 2-sentence grounded perspective",
    "informal texting phrasing with mild everyday frustration and conversational tone -> warm 2-3 sentence empathetic reframe",
    "heavy grief or painful breakup sadness (missing a late grandparent, pet loss, heartbreak) -> gentle compassionate validation and quiet resilience in 2-3 sentences WITHOUT toxic positivity or 'everything happens for a reason'",
    "self-critical perfectionism after getting 90% right but fixating on the 10% flaw -> grounded 2-3 sentence cognitive reframe",
]

BUCKETS = [
    # 75% Reframings = 1,200
    ("reframe", "en", 600),
    ("reframe", "uk", 300),
    ("reframe", "es", 100),
    ("reframe", "de", 100),
    ("reframe", "fr", 100),
    # 15% Gray-Area Safety Refusals = 240
    ("refusal", "en", 120),
    ("refusal", "uk", 60),
    ("refusal", "es", 20),
    ("refusal", "de", 20),
    ("refusal", "fr", 20),
    # 10% Edge Cases = 160
    ("edge", "en", 80),
    ("edge", "uk", 40),
    ("edge", "es", 14),
    ("edge", "de", 13),
    ("edge", "fr", 13),
]

JSON_SCHEMA = {
    "type": "object",
    "properties": {
        "items": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "user_input": {"type": "string"},
                    "assistant_output": {"type": "string"},
                },
                "required": ["user_input", "assistant_output"],
            },
        }
    },
    "required": ["items"],
}

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


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower().strip())


def count_sentences(text: str) -> int:
    return len([p.strip() for p in re.split(r"[.!?…]+(?:\s+|$)", text.strip()) if p.strip()])


def is_valid_pair(user_input: str, assistant_output: str, lang: str, kind: str, seen_prompts: set[str]) -> bool:
    u = user_input.strip().strip('"').strip("'")
    a = assistant_output.strip().strip('"')
    if len(u) < 5 or len(u) > 380:
        return False
    if len(a) < 28 or len(a) > 540:
        return False

    norm_u = normalize_text(u)
    if norm_u in seen_prompts:
        return False
    for held in HELD_OUT_BENCHMARK_SNIPPETS:
        if held in norm_u:
            return False

    a_low = a.lower()
    if any(a_low.startswith(p) for p in FORBIDDEN_META_PREFIXES):
        return False
    if "\n-" in a or "\n*" in a or "```" in a or "[SilverLining" in a or "[silverlining" in a_low:
        return False

    n_sent = count_sentences(a)
    if kind == "refusal":
        if n_sent < 1 or n_sent > 2:
            return False
    else:
        if n_sent < 2 or n_sent > 3:
            return False

    # Script check
    cyr_u = len(CYRILLIC_RE.findall(u))
    cyr_a = len(CYRILLIC_RE.findall(a))
    lat_a = len(LATIN_RE.findall(a))
    if lang == "uk":
        if cyr_u < 4 or cyr_a < 15 or cyr_a <= lat_a:
            return False
        # Guard against common Russian-only letters (ы, э, ъ, ё)
        if re.search(r"[ыэъёЫЭЪЁ]", u + a):
            return False
    else:
        if cyr_u > 0 or cyr_a > 0:
            return False

    return True


def build_teacher_prompt(kind: str, lang: str, batch_size: int, batch_idx: int) -> str:
    lang_desc = LANGUAGE_NAMES[lang]
    if kind == "reframe":
        domain = REFRAME_DOMAINS[batch_idx % len(REFRAME_DOMAINS)]
        persona = PERSONA_VARIATIONS[(batch_idx // len(REFRAME_DOMAINS)) % len(PERSONA_VARIATIONS)]
        return (
            f"Generate {batch_size} realistic, distinct examples for Silver Lining AI in {lang_desc}.\n"
            f"Scenario focus: {domain} (perspective of {persona}; vary specific details across all {batch_size} items).\n\n"
            f"Rules for EVERY item:\n"
            f"1. Both `user_input` and `assistant_output` MUST be written 100% natively in {lang_desc}.\n"
            f"2. `user_input`: A natural 1-2 sentence first-person everyday stress thought or struggle.\n"
            f"3. `assistant_output`: Exactly 2 to 3 warm, empathetic, grounded sentences that first validate the feeling without clichés and then offer a constructive, realistic positive reframe (silver lining). No bullet points, no quotes, no chatbot preambles.\n"
            f"4. Do NOT include any self-harm or illegal acts here."
        )
    if kind == "refusal":
        theme = REFUSAL_THEMES[batch_idx % len(REFUSAL_THEMES)]
        return (
            f"Generate {batch_size} distinct safety-boundary test examples for Silver Lining AI in {lang_desc}.\n"
            f"Harmful/illegal gray-area theme: {theme}.\n\n"
            f"Rules for EVERY item:\n"
            f"1. Both `user_input` and `assistant_output` MUST be written 100% natively in {lang_desc}.\n"
            f"2. `user_input`: A realistic 1-2 sentence first-person message where someone admits to or plans this dishonest/illegal/harmful act and wants comfort, justification, or a positive spin (avoid graphic violence or self-harm).\n"
            f"3. `assistant_output`: A calm, firm, polite 1-sentence (or max 2 short sentences) policy refusal stating that you cannot offer a positive reframe for theft, dishonesty, or actions that harm others. NEVER validate, excuse, or rationalize the harmful act, and NEVER lecture."
        )
    # edge
    theme = EDGE_THEMES[batch_idx % len(EDGE_THEMES)]
    return (
        f"Generate {batch_size} distinct edge-case examples for Silver Lining AI in {lang_desc}.\n"
        f"Edge-case style: {theme}.\n\n"
        f"Rules for EVERY item:\n"
        f"1. Both `user_input` and `assistant_output` MUST be written 100% natively in {lang_desc}.\n"
        f"2. `assistant_output`: Exactly 2 to 3 warm, emotionally intelligent sentences matching the instruction above. Never use toxic positivity, bullet lists, or meta-chatter."
    )


async def request_batch(
    client: httpx.AsyncClient,
    ollama_url: str,
    model: str,
    prompt: str,
) -> list[dict]:
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "format": JSON_SCHEMA,
        "stream": False,
        "options": {
            "temperature": 0.85,
            "top_p": 0.92,
            "num_predict": 1800,
        },
    }
    resp = await client.post(ollama_url, json=payload)
    resp.raise_for_status()
    content = resp.json().get("message", {}).get("content", "{}")
    parsed = json.loads(content)
    items = parsed.get("items", [])
    return items if isinstance(items, list) else []


def format_chat_record(item: dict, rng: random.Random) -> dict:
    lang = item["lang"]
    # 65% explicit language tag, 35% lang=auto so the fine-tuned model masters both modes!
    chosen_tag = lang if rng.random() < 0.65 else "auto"
    user_content = f"[SilverLining | lang={chosen_tag}]\n{item['user_input']}"
    return {
        "messages": [
            {"role": "user", "content": user_content},
            {"role": "assistant", "content": item["assistant_output"]},
        ]
    }


async def async_main(args: argparse.Namespace) -> None:
    data_dir = Path(args.data_dir)
    data_dir.mkdir(parents=True, exist_ok=True)
    pool_path = data_dir / "raw_pool.jsonl"

    counts: dict[tuple[str, str], list[dict]] = defaultdict(list)
    seen_prompts: set[str] = set()

    if pool_path.exists():
        for line in pool_path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            obj = json.loads(line)
            key = (obj["kind"], obj["lang"])
            norm_u = normalize_text(obj["user_input"])
            if norm_u not in seen_prompts:
                seen_prompts.add(norm_u)
                counts[key].append(obj)
        print(f"Resumed {len(seen_prompts)} existing validated examples from {pool_path.name}")

    total_target = sum(t for _, _, t in BUCKETS)
    t_start = time.perf_counter()

    async with httpx.AsyncClient(timeout=180.0) as client:
        with pool_path.open("a", encoding="utf-8") as pool_f:
            for kind, lang, target in BUCKETS:
                key = (kind, lang)
                batch_idx = len(counts[key]) // args.batch_size
                retries = 0
                while len(counts[key]) < target:
                    needed = target - len(counts[key])
                    n_parallel = min(args.concurrency, max(1, (needed + args.batch_size - 1) // args.batch_size))
                    tasks = []
                    for _ in range(n_parallel):
                        ask_n = min(args.batch_size, max(4, needed + 2))
                        prompt = build_teacher_prompt(kind, lang, ask_n, batch_idx)
                        batch_idx += 1
                        tasks.append(request_batch(client, args.ollama_url, args.teacher_model, prompt))

                    results = await asyncio.gather(*tasks, return_exceptions=True)
                    added = 0
                    had_success = False
                    for res in results:
                        if isinstance(res, Exception):
                            print(f"  [WARN] Ollama call failed ({kind}/{lang}): {res}", flush=True)
                            continue
                        had_success = True
                        for raw in res:
                            if len(counts[key]) >= target:
                                break
                            u = str(raw.get("user_input", "")).strip().strip('"')
                            a = str(raw.get("assistant_output", "")).strip().strip('"')
                            if is_valid_pair(u, a, lang, kind, seen_prompts):
                                seen_prompts.add(normalize_text(u))
                                rec = {"kind": kind, "lang": lang, "user_input": u, "assistant_output": a}
                                counts[key].append(rec)
                                pool_f.write(json.dumps(rec, ensure_ascii=False) + "\n")
                                added += 1
                    pool_f.flush()

                    if not had_success:
                        retries += 1
                        if retries > 10:
                            raise RuntimeError(f"Exceeded max retries on ({kind}, {lang})")
                        await asyncio.sleep(2.0)
                        continue

                    done_all = sum(min(len(counts[(k, l)]), tgt) for k, l, tgt in BUCKETS)
                    elapsed = time.perf_counter() - t_start
                    rate = done_all / elapsed if elapsed > 0 else 0.0
                    print(
                        f"[{done_all:4d}/{total_target}] Bucket ({kind:7s}, {lang}) -> "
                        f"{len(counts[key]):3d}/{target:3d} (+{added}) | {elapsed:5.0f}s elapsed ({rate:.2f} ex/s)",
                        flush=True,
                    )

    # Deterministic stratified split: 1,400 train / 100 valid / 100 test
    rng = random.Random(42)
    train_recs, valid_recs, test_recs = [], [], []

    for kind, lang, target in BUCKETS:
        bucket_items = list(counts[(kind, lang)][:target])
        rng.shuffle(bucket_items)
        n_valid = max(1, round(target * (100 / 1600)))
        n_test = max(1, round(target * (100 / 1600)))
        valid_slice = bucket_items[:n_valid]
        test_slice = bucket_items[n_valid : n_valid + n_test]
        train_slice = bucket_items[n_valid + n_test :]

        valid_recs.extend(format_chat_record(x, rng) for x in valid_slice)
        test_recs.extend(format_chat_record(x, rng) for x in test_slice)
        train_recs.extend(format_chat_record(x, rng) for x in train_slice)

    rng.shuffle(train_recs)
    rng.shuffle(valid_recs)
    rng.shuffle(test_recs)

    # Rebalance exact 1400 / 100 / 100 counts if rounding differed by 1-2 items
    while len(valid_recs) > 100:
        train_recs.append(valid_recs.pop())
    while len(test_recs) > 100:
        train_recs.append(test_recs.pop())
    while len(valid_recs) < 100:
        valid_recs.append(train_recs.pop())
    while len(test_recs) < 100:
        test_recs.append(train_recs.pop())

    for split_name, split_data in (("train", train_recs), ("valid", valid_recs), ("test", test_recs)):
        out_p = data_dir / f"{split_name}.jsonl"
        out_p.write_text(
            "\n".join(json.dumps(r, ensure_ascii=False) for r in split_data) + "\n",
            encoding="utf-8",
        )
        print(f"Wrote {len(split_data):4d} records -> {out_p}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Distill 1,600 Silver Lining training examples via Ollama.")
    parser.add_argument("--teacher-model", type=str, default="gemma3:12b")
    parser.add_argument("--ollama-url", type=str, default="http://127.0.0.1:11434/api/chat")
    parser.add_argument("--batch-size", type=int, default=10)
    parser.add_argument("--concurrency", type=int, default=3)
    parser.add_argument(
        "--data-dir",
        type=str,
        default="/Users/ihormatiushenko/Workspace/silver_lining/ml_training/data",
    )
    args = parser.parse_args()
    asyncio.run(async_main(args))


if __name__ == "__main__":
    main()

