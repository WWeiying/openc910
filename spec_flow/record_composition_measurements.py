#!/usr/bin/env python3
"""Store measured quick/full phase shares next to target map weights."""

import argparse
import json
from pathlib import Path


def phase_shares(features_root, case):
    path = features_root / "cases" / case / "features.json"
    if not path.is_file():
        return None
    features = json.loads(path.read_text())
    phases = features.get("composition_phases")
    if not phases:
        return None
    return [float(phase["share"]) for phase in phases["phases"]]


def update_map(path, quick_root, full_root):
    data = json.loads(path.read_text())
    updated = set()
    for row in data.get("benchmarks", []):
        kernels = row.get("kernels", [])
        if len(kernels) != 1 or not kernels[0].get("composition"):
            continue
        kernel = kernels[0]
        quick = phase_shares(quick_root, kernel["case"])
        full = phase_shares(full_root, kernel["case"])
        if quick is None or full is None:
            continue
        groups = kernel["composition"]
        if len(groups) != len(quick) or len(groups) != len(full):
            raise ValueError(f"{kernel['case']}: group/phase count mismatch")
        for index, group in enumerate(groups):
            group["measured_instruction_share_by_profile"] = {
                "quick": quick[index],
                "full": full[index],
            }
        updated.add(kernel["case"])
    path.write_text(json.dumps(data, indent=2) + "\n")
    return updated


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--map", action="append", type=Path, required=True)
    parser.add_argument("--quick-features", type=Path, required=True)
    parser.add_argument("--full-features", type=Path, required=True)
    args = parser.parse_args()
    updated = set()
    for path in args.map:
        updated.update(update_map(path, args.quick_features, args.full_features))
    print(f"recorded quick/full composition measurements for {len(updated)} cases")


if __name__ == "__main__":
    main()
