#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["tokenizers", "tiktoken"]
# ///
"""Report the static context cost of every skill in this repository.

Usage:
    ./scripts/skill-sizes.py [-v] [--tokenizer [DIR] | --model MODEL]

Columns:
    body  SKILL.md bytes without frontmatter; added to the conversation on load
    desc  frontmatter description bytes; advertised to the model every step
    refs  references/*.md bytes; read on demand, never loaded automatically

Token counts default to bytes / 4 estimates. Exact counts require a tokenizer:
    --tokenizer [DIR]  DeepSeek V4 offline tokenizer; DIR defaults to
                       $DEEPSEEK_TOKENIZER_DIR or deepseek_v4_tokenizer/
    --model MODEL      OpenAI tiktoken model name (gpt-5) or encoding
                       name (o200k_base)

The PEP 723 block above installs tokenizers and tiktoken on demand when the
script runs through uv (./scripts/skill-sizes.py); python3 works for estimates
only unless those libraries are installed. Token counts are model-specific,
so treat any number as attached to its tokenizer.
"""

from __future__ import annotations

import argparse
import os
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
LOCAL_TOKENIZER_DIR = REPO_ROOT / "deepseek_v4_tokenizer"


@dataclass(frozen=True)
class Counter:
    count: Callable[[str], int]
    source: str
    exact: bool


def local_tokenizer_dir() -> Path:
    env_dir = os.environ.get("DEEPSEEK_TOKENIZER_DIR")
    return Path(env_dir) if env_dir else LOCAL_TOKENIZER_DIR


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Estimate the static context cost of the skills in this repository."
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="list every reference file"
    )
    counter = parser.add_mutually_exclusive_group()
    counter.add_argument(
        "--tokenizer",
        type=Path,
        nargs="?",
        metavar="DIR",
        const=local_tokenizer_dir(),
        default=os.environ.get("DEEPSEEK_TOKENIZER_DIR") or None,
        help="count with the DeepSeek V4 tokenizer; DIR defaults to "
        "$DEEPSEEK_TOKENIZER_DIR or ./deepseek_v4_tokenizer",
    )
    counter.add_argument(
        "--model",
        metavar="MODEL",
        help="count with an OpenAI tiktoken model name (gpt-5) "
        "or encoding name (o200k_base)",
    )
    return parser.parse_args()


def strip_frontmatter(text: str) -> str:
    lines = text.splitlines(keepends=True)
    if not lines or lines[0].strip() != "---":
        return text
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            return "".join(lines[index + 1 :])
    return text


def frontmatter_description(text: str) -> str:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return ""
    for line in lines[1:]:
        if line.strip() == "---":
            break
        if line.startswith("description: "):
            return line.removeprefix("description: ")
    return ""


def estimate_tokens(n_bytes: int) -> int:
    return (n_bytes + 2) // 4


def measure(text: str, count_tokens: Callable[[str], int]) -> tuple[int, int]:
    n_bytes = len(text.encode())
    return n_bytes, count_tokens(text)


def load_deepseek_tokenizer(directory: Path):
    tokenizer_file = directory / "tokenizer.json"
    if not tokenizer_file.is_file():
        raise SystemExit(f"tokenizer.json not found in {directory}")
    try:
        from tokenizers import Tokenizer
    except ImportError as exc:
        raise SystemExit(
            "--tokenizer requires the tokenizers library; run with uv "
            "(./scripts/skill-sizes.py) or pip install tokenizers"
        ) from exc
    return Tokenizer.from_file(str(tokenizer_file))


def load_openai_encoding(name: str):
    try:
        import tiktoken
    except ImportError as exc:
        raise SystemExit(
            "--model requires the tiktoken library; run with uv "
            "(./scripts/skill-sizes.py) or pip install tiktoken"
        ) from exc
    try:
        return tiktoken.encoding_for_model(name)
    except KeyError:
        try:
            return tiktoken.get_encoding(name)
        except ValueError as exc:
            raise SystemExit(
                f"unknown OpenAI model or tiktoken encoding: {name} "
                "(examples: gpt-5, gpt-4o, o200k_base, cl100k_base)"
            ) from exc


def build_counter(args: argparse.Namespace) -> Counter:
    if args.tokenizer is not None:
        tokenizer = load_deepseek_tokenizer(args.tokenizer)

        def count_deepseek(text: str) -> int:
            return len(tokenizer.encode(text, add_special_tokens=False).ids)

        source = f"exact, DeepSeek V4 tokenizer at {args.tokenizer}"
        return Counter(count_deepseek, source, True)

    if args.model:
        encoding = load_openai_encoding(args.model)

        def count_openai(text: str) -> int:
            return len(encoding.encode(text, disallowed_special=()))

        source = f"exact, OpenAI {encoding.name} via tiktoken ({args.model})"
        return Counter(count_openai, source, True)

    def count_estimate(text: str) -> int:
        return estimate_tokens(len(text.encode()))

    source = "bytes / 4 estimates; pass --tokenizer [DIR] or --model MODEL"
    return Counter(count_estimate, source, False)


def size(n_bytes: int) -> str:
    return f"{n_bytes} B"


def report(counter: Counter, verbose: bool) -> None:
    skill_paths = sorted(SKILLS_DIR.glob("*/SKILL.md"))
    if not skill_paths:
        raise SystemExit(f"no skills found under {SKILLS_DIR}")

    token_header = "tok" if counter.exact else "~tok"
    print(
        f"{'skill':<32} {'body':>8} {token_header:>6} {'desc':>7} "
        f"{'refs':>9} {'files':>5} {token_header:>6}"
    )

    total_body_bytes = total_body_tokens = 0
    total_desc_bytes = total_desc_tokens = 0
    total_refs_bytes = total_refs_tokens = 0
    total_files = 0

    for skill_md in skill_paths:
        text = skill_md.read_text()
        body_bytes, body_tokens = measure(strip_frontmatter(text), counter.count)
        desc_bytes, desc_tokens = measure(frontmatter_description(text), counter.count)

        ref_rows = []
        refs_bytes = refs_tokens = 0
        for ref_path in sorted((skill_md.parent / "references").glob("*.md")):
            ref_bytes, ref_tokens = measure(ref_path.read_text(), counter.count)
            ref_rows.append((ref_path.name, ref_bytes, ref_tokens))
            refs_bytes += ref_bytes
            refs_tokens += ref_tokens

        print(
            f"{skill_md.parent.name:<32} {size(body_bytes):>8} {body_tokens:>6} "
            f"{size(desc_bytes):>7} {size(refs_bytes):>9} {len(ref_rows):>5} "
            f"{refs_tokens:>6}"
        )
        if verbose:
            for name, ref_bytes, ref_tokens in ref_rows:
                label = f"references/{name}"
                print(f"    {label:<44} {size(ref_bytes):>8} {ref_tokens:>6}")

        total_body_bytes += body_bytes
        total_body_tokens += body_tokens
        total_desc_bytes += desc_bytes
        total_desc_tokens += desc_tokens
        total_refs_bytes += refs_bytes
        total_refs_tokens += refs_tokens
        total_files += len(ref_rows)

    print(
        f"{f'TOTAL ({len(skill_paths)} skills)':<32} {size(total_body_bytes):>8} "
        f"{total_body_tokens:>6} {size(total_desc_bytes):>7} "
        f"{size(total_refs_bytes):>9} {total_files:>5} {total_refs_tokens:>6}"
    )
    print(f"tokens: {counter.source}")
    print(
        f"advertised every step: {size(total_desc_bytes)} ({total_desc_tokens} tokens) | "
        f"read on demand: {size(total_refs_bytes)} ({total_refs_tokens} tokens)"
    )


def main() -> None:
    args = parse_args()
    report(build_counter(args), args.verbose)


if __name__ == "__main__":
    main()
