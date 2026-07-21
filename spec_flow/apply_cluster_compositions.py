#!/usr/bin/env python3
"""Apply generated cluster compositions to kernel maps and profile contracts."""

import argparse
import copy
import json
import os
from pathlib import Path


MEASUREMENT_KEYS = (
    "measured_instruction_share",
    "measured_instruction_share_by_profile",
    "functions",
    "function_patterns",
)


def atomic_json_write(path, data):
    tmp = path.with_name(f"{path.name}.tmp.{os.getpid()}")
    try:
        tmp.write_text(json.dumps(data, indent=2) + "\n")
        os.replace(tmp, path)
    finally:
        tmp.unlink(missing_ok=True)


def composition_for_map(case, previous=()):
    previous_by_identity = {
        (group.get("name"), group.get("mechanism")): group
        for group in previous
    }
    result = []
    for group in case["groups"]:
        mapped = {
            "name": group["name"],
            "mechanism": group["mechanism"],
            "clusters": group["clusters"],
            "target_weight": group["target_weight"],
        }
        old = previous_by_identity.get((group["name"], group["mechanism"]), {})
        old_clusters = old.get("clusters", old.get("source_clusters", []))
        stable_source = (
            list(old_clusters) == list(group["clusters"])
            and abs(
                float(old.get("target_weight", -1.0))
                - float(group["target_weight"])
            )
            <= 1e-12
        )
        if stable_source:
            for key in MEASUREMENT_KEYS:
                if key in old:
                    mapped[key] = copy.deepcopy(old[key])
        result.append(mapped)
    return result


def cluster_selectors_for_map(case):
    selectors = []
    for group in case["groups"]:
        clusters = group["clusters"]
        intervals = group.get("intervals", [])
        if len(clusters) != len(intervals):
            raise ValueError(
                f"{case['case']}: cluster/interval counts differ for {group['name']}"
            )
        selectors.extend(
            {"id": int(cluster), "interval": int(interval)}
            for cluster, interval in zip(clusters, intervals)
        )
    selectors.sort(key=lambda item: item["id"])
    if len({item["id"] for item in selectors}) != len(selectors):
        raise ValueError(f"{case['case']}: duplicate top-level cluster selector")
    return selectors


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
        kernel["clusters"] = cluster_selectors_for_map(source)
        kernel["composition"] = composition_for_map(
            source, kernel.get("composition", [])
        )
        kernel["max_unattributed_instruction_share"] = 0.1
        updated.add(kernel["case"])
    atomic_json_write(path, data)
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
            "function_profile": source["source_profile"],
            "source_cluster_count": source["source_cluster_count"],
            "mechanism_group_count": source["mechanism_group_count"],
        }
    atomic_json_write(path, data)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compositions", type=Path,
        default=Path("spec_flow/spec_cluster_compositions.json"),
    )
    parser.add_argument("--map", type=Path, action="append")
    parser.add_argument(
        "--profiles", type=Path,
        default=Path("spec_flow/spec_kernel_profiles.json"),
    )
    args = parser.parse_args()
    map_paths = args.map or [
        Path("spec_flow/spec2017_kernel_map.json"),
        Path("spec_flow/spec2017_speed_kernel_map.json"),
    ]
    source = json.loads(args.compositions.read_text())
    by_case = {case["case"]: case for case in source["cases"]}
    observed = set()
    for path in map_paths:
        observed.update(apply_map(path, by_case))
    missing = set(by_case) - observed
    if missing:
        raise ValueError(f"kernel maps lack composition cases: {sorted(missing)}")
    apply_profiles(args.profiles, by_case)
    print(f"applied {len(by_case)} cluster compositions")


if __name__ == "__main__":
    main()
