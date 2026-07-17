#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path


def validate_completed_bbv(bbv, bbv_map, cmdmap, modules, expected_commands):
    errors = []
    for path in (bbv, bbv_map, cmdmap, modules):
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing/empty artifact: {path}")
    if errors:
        return errors

    with bbv.open(errors="replace") as stream:
        if not any(line.startswith("T") for line in stream):
            errors.append("BBV contains no intervals")

    map_ids = []
    with bbv_map.open() as stream:
        for line_no, line in enumerate(stream, 1):
            fields = line.split()
            if len(fields) < 3:
                errors.append(f"invalid map row {line_no}")
                continue
            try:
                map_ids.append(int(fields[0]))
            except ValueError:
                errors.append(f"invalid map ID at row {line_no}")
    if map_ids:
        if len(set(map_ids)) != len(map_ids):
            errors.append("BBV map contains duplicate IDs")
        if sorted(map_ids) != list(range(1, max(map_ids) + 1)):
            errors.append("BBV map IDs are not contiguous from 1")
    else:
        errors.append("BBV map contains no blocks")

    try:
        with cmdmap.open(newline="") as stream:
            rows = list(csv.DictReader(stream, delimiter="\t"))
    except (OSError, csv.Error) as exc:
        errors.append(f"invalid cmdmap: {exc}")
        rows = []
    if len(rows) != expected_commands:
        errors.append(
            f"cmdmap commands={len(rows)} expected={expected_commands}"
        )
    previous_end = 0
    for index, row in enumerate(rows):
        try:
            cmd_index = int(row["cmd_index"])
            start = int(row["start_id"])
            end = int(row["end_id"])
        except (KeyError, TypeError, ValueError):
            errors.append(f"invalid cmdmap row {index}")
            continue
        if cmd_index != index or start != previous_end + 1 or end < start:
            errors.append(f"non-contiguous cmdmap row {index}")
        previous_end = end
    if map_ids and previous_end != max(map_ids):
        errors.append(
            f"cmdmap end={previous_end} does not match map max={max(map_ids)}"
        )

    module_commands = set()
    with modules.open(errors="replace") as stream:
        next(stream, None)
        for line in stream:
            fields = line.rstrip("\n").split("\t")
            if len(fields) >= 3:
                try:
                    module_commands.add(int(fields[0]))
                except ValueError:
                    pass
    missing_modules = set(range(expected_commands)) - module_commands
    if missing_modules:
        errors.append(
            "module map misses commands: "
            + ",".join(str(item) for item in sorted(missing_modules))
        )
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bbv", type=Path, required=True)
    parser.add_argument("--map", type=Path, required=True)
    parser.add_argument("--cmdmap", type=Path, required=True)
    parser.add_argument("--modules", type=Path, required=True)
    parser.add_argument("--expected-commands", type=int, required=True)
    args = parser.parse_args()

    errors = validate_completed_bbv(
        args.bbv, args.map, args.cmdmap, args.modules, args.expected_commands
    )
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"[completed-bbv] commands={args.expected_commands} status=complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
