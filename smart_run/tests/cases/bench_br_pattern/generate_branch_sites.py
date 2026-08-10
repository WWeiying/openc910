#!/usr/bin/env python3
"""Generate the exact number of static branch sites for bench_br_pattern."""

from __future__ import annotations

import argparse
from pathlib import Path


def positive_int(value: str) -> int:
    parsed = int(value, 0)
    if parsed <= 0:
        raise argparse.ArgumentTypeError("value must be positive")
    return parsed


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--branches", type=positive_int, required=True)
    parser.add_argument("--pattern-length", type=positive_int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser


def phase_for_site(site: int, pattern_length: int) -> int:
    # The odd multiplicative hash is a permutation for power-of-two lengths and
    # provides deterministic phase spreading for the other supported lengths.
    return (site * 2654435761) % pattern_length


def main() -> int:
    args = build_parser().parse_args()
    if args.branches > 512:
        raise SystemExit("--branches must not exceed 512")
    if not 2 <= args.pattern_length <= 65536:
        raise SystemExit("--pattern-length must be in [2, 65536]")

    lines = [
        "/* Generated file: one BP_SITE expansion equals one static branch. */",
        f"/* branches={args.branches} pattern_length={args.pattern_length} */",
    ]
    lines.extend(
        f"BP_SITE({phase_for_site(site, args.pattern_length)}u); /* site {site} */"
        for site in range(args.branches)
    )
    args.output.write_text("\n".join(lines) + "\n", encoding="ascii")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
