#!/usr/bin/env python3
"""Store measured quick/full phase shares next to target map weights."""

import argparse
import json
import math
import os
from pathlib import Path

try:
    from spec_flow.validate_composite_features import measure_composition
except ModuleNotFoundError:
    from validate_composite_features import measure_composition


def atomic_json_write(path, data):
    temporary = path.with_name(f"{path.name}.tmp.{os.getpid()}")
    try:
        temporary.write_text(json.dumps(data, indent=2) + "\n")
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def measured_shares(features_root, row, profile):
    case = row["kernels"][0]["case"]
    path = features_root / "cases" / case / "features.json"
    if not path.is_file():
        raise FileNotFoundError(path)
    features = json.loads(path.read_text())
    if features.get("case") != case:
        raise ValueError(f"{case}: feature identity mismatch in {path}")
    observed_profile = features.get("profile", {}).get("kernel_profile")
    if observed_profile != profile:
        raise ValueError(
            f"{case}: feature profile={observed_profile!r}, expected={profile!r}"
        )
    measurement = measure_composition(row, features, profile)
    shares = [float(group["share"]) for group in measurement["groups"]]
    if (
        not shares
        or any(not math.isfinite(share) or share <= 0.0 for share in shares)
        or abs(sum(shares) - 1.0) > 1e-6
    ):
        raise ValueError(f"{case}: invalid composition phase shares")
    return shares


def update_map(path, quick_root, full_root):
    data = json.loads(path.read_text())
    updated = set()
    for row in data.get("benchmarks", []):
        kernels = row.get("kernels", [])
        if len(kernels) != 1 or not kernels[0].get("composition"):
            continue
        kernel = kernels[0]
        quick = measured_shares(quick_root, row, "quick")
        full = measured_shares(full_root, row, "full")
        groups = kernel["composition"]
        if len(groups) != len(quick) or len(groups) != len(full):
            raise ValueError(f"{kernel['case']}: group/phase count mismatch")
        for index, group in enumerate(groups):
            group["measured_instruction_share_by_profile"] = {
                "quick": quick[index],
                "full": full[index],
            }
        updated.add(kernel["case"])
    atomic_json_write(path, data)
    return updated


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--map", action="append", type=Path, required=True)
    parser.add_argument("--quick-features", type=Path, required=True)
    parser.add_argument("--full-features", type=Path, required=True)
    parser.add_argument("--expected-cases", type=int)
    args = parser.parse_args()
    if args.expected_cases is not None and args.expected_cases < 1:
        parser.error("--expected-cases must be positive")
    updated = set()
    for path in args.map:
        updated.update(update_map(path, args.quick_features, args.full_features))
    if args.expected_cases is not None and len(updated) != args.expected_cases:
        raise SystemExit(
            f"expected {args.expected_cases} measured composites, got {len(updated)}"
        )
    print(f"recorded quick/full composition measurements for {len(updated)} cases")


if __name__ == "__main__":
    main()
