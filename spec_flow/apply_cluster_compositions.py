#!/usr/bin/env python3
"""Apply generated cluster compositions to kernel maps and profile contracts."""

import argparse
import copy
import json
from pathlib import Path


def composition_for_map(case):
    return [
        {
            "name": group["name"],
            "mechanism": group["mechanism"],
            "source_clusters": group["clusters"],
            "target_weight": group["target_weight"],
        }
        for group in case["groups"]
    ]


def apply_map(path, by_case):
    data = json.loads(path.read_text())
    by_benchmark = {source["benchmark"]: source for source in by_case.values()}
    updated = set()
    for row in data.get("benchmarks", []):
        kernels = row.get("kernels", [])
        if len(kernels) != 1:
            continue
        kernel = kernels[0]
        source = by_benchmark.get(row.get("bench")) or by_case.get(kernel.get("case"))
        if not source:
            continue
        kernel["case"] = source["case"]
        kernel["calibration"] = source["calibration"]
        kernel["composition_basis"] = {
            "benchmark": source["benchmark"],
            "profile": source.get("source_profile_size", "ref"),
            "function_profile": source["source_profile"],
            "source_cluster_count": source["source_cluster_count"],
        }
        kernel["composition"] = composition_for_map(source)
        kernel["max_unattributed_instruction_share"] = 0.1
        updated.add(kernel["case"])
    path.write_text(json.dumps(data, indent=2) + "\n")
    return updated


def apply_profiles(path, by_case):
    data = json.loads(path.read_text())
    contracts = data.setdefault("cases", {})
    for case, source in by_case.items():
        if case in contracts:
            continue
        template = source.get("profile_contract_template")
        if not template or template not in contracts:
            raise ValueError(f"profile contract lacks {case} and template {template}")
        contracts[case] = copy.deepcopy(contracts[template])
    for case, source in by_case.items():
        row = contracts[case]
        row["benchmarks"] = [source["benchmark"]]
        row["calibration"] = source["calibration"]
        row["composition_basis"] = {
            "benchmark": source["benchmark"],
            "profile": source.get("source_profile_size", "ref"),
            "source_cluster_count": source["source_cluster_count"],
            "mechanism_group_count": source["mechanism_group_count"],
        }
    path.write_text(json.dumps(data, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compositions", type=Path,
        default=Path("spec_flow/spec_cluster_compositions.json"),
    )
    parser.add_argument(
        "--map", type=Path, action="append",
        default=[
            Path("spec_flow/spec2017_kernel_map.json"),
            Path("spec_flow/spec2017_speed_kernel_map.json"),
        ],
    )
    parser.add_argument(
        "--profiles", type=Path,
        default=Path("spec_flow/spec_kernel_profiles.json"),
    )
    args = parser.parse_args()
    source = json.loads(args.compositions.read_text())
    by_case = {case["case"]: case for case in source["cases"]}
    observed = set()
    for path in args.map:
        observed.update(apply_map(path, by_case))
    missing = set(by_case) - observed
    if missing:
        raise ValueError(f"kernel maps lack composition cases: {sorted(missing)}")
    apply_profiles(args.profiles, by_case)
    print(f"applied {len(by_case)} cluster compositions")


if __name__ == "__main__":
    main()
