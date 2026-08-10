#!/usr/bin/env python3
"""Merge disjoint branch-pattern batch CSV files into one atomic table."""

from __future__ import annotations

import argparse
import csv
import fcntl
from pathlib import Path


KEY_COLUMNS = ("branches_in_loop", "pattern_length", "repeat")
HANDOFF_LOCK = Path(__file__).resolve().parent / "results" / ".branch_pattern_handoff.lock"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, action="append", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--allow-missing", action="store_true")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    HANDOFF_LOCK.parent.mkdir(parents=True, exist_ok=True)
    handoff_lock = HANDOFF_LOCK.open("a+", encoding="ascii")
    fcntl.flock(handoff_lock.fileno(), fcntl.LOCK_EX)
    rows: dict[tuple[int, int, int], dict[str, str]] = {}
    fieldnames: list[str] | None = None

    for path in args.input:
        path = path.expanduser().resolve()
        if not path.is_file():
            if args.allow_missing:
                continue
            raise SystemExit(f"input CSV is missing: {path}")
        with path.open("r", encoding="utf-8", newline="") as stream:
            reader = csv.DictReader(stream)
            if reader.fieldnames is None:
                raise SystemExit(f"input CSV has no header: {path}")
            if fieldnames is None:
                fieldnames = reader.fieldnames
            elif reader.fieldnames != fieldnames:
                raise SystemExit(f"CSV schema mismatch: {path}")
            missing_keys = sorted(set(KEY_COLUMNS) - set(reader.fieldnames))
            if missing_keys:
                raise SystemExit(f"input CSV is missing key columns {missing_keys}: {path}")
            for row in reader:
                key = tuple(int(row[column]) for column in KEY_COLUMNS)
                if key in rows and rows[key] != row:
                    raise SystemExit(f"conflicting duplicate coordinate {key}: {path}")
                rows[key] = row

    if fieldnames is None or not rows:
        raise SystemExit("no branch-pattern rows are available to merge")

    ordered = sorted(
        rows.values(),
        key=lambda row: tuple(int(row[column]) for column in KEY_COLUMNS),
    )
    output = args.output.expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(output.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(ordered)
    temporary.replace(output)
    print(f"merged_coordinates={len(ordered)} output={output}")
    handoff_lock.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
