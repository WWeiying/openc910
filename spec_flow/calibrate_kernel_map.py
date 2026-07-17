#!/usr/bin/env python3
import argparse
import copy
import hashlib
import json
import os
from datetime import datetime, timezone
from pathlib import Path

try:
    from .aggregate_rtl_by_simpoint import (
        resolve_kernel_weights,
        validate_embedded_composition,
    )
    from .validate_l2plus import validate_manifest
except ImportError:
    from aggregate_rtl_by_simpoint import (
        resolve_kernel_weights,
        validate_embedded_composition,
    )
    from validate_l2plus import validate_manifest


CALIBRATION_METHOD = "ref_simpoint_cluster_groups_v2"


def sha256_file(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def calibrate_map(
    data,
    manifests,
    manifest_digests,
    min_match=0.05,
    require_cluster_mapping=False,
):
    calibrated = copy.deepcopy(data)
    calibrated["default_size"] = "ref"
    calibrated["calibration_size"] = "ref"
    calibrated["description"] = (
        "Ref-bound mapping from each SPEC CPU2017 benchmark to one bare-metal "
        "RTL composite kernel. Multi-mechanism rows embed the SimPoint cluster "
        "mix as calibrated dynamic instruction shares. Rows marked single_proxy "
        "have not completed that calibration. These are not SPEC source code or "
        "exact SimPoint checkpoints."
    )

    for row in calibrated.get("benchmarks", []):
        bench = row["bench"]
        manifest = manifests[bench]
        kernels = row.get("kernels", [])
        if not kernels:
            raise ValueError(f"{bench}: no mapped kernels")

        raw_weights, source = resolve_kernel_weights(row, manifest)
        if len(kernels) > 1 and source != "simpoint_cluster_groups":
            raise ValueError(
                f"{bench}: multi-kernel mapping must assign every SimPoint cluster"
            )
        if source not in {"single_proxy", "simpoint_cluster_groups"}:
            raise ValueError(
                f"{bench}: production calibration rejects legacy weight source {source}"
            )
        if require_cluster_mapping and source != "simpoint_cluster_groups":
            raise ValueError(
                f"{bench}: cluster mechanism mapping is incomplete (single proxy only)"
            )
        if require_cluster_mapping and len(kernels) != 1:
            raise ValueError(
                f"{bench}: production mapping must use exactly one composite kernel"
            )
        if any(weight <= 0 for weight in raw_weights):
            raise ValueError(f"{bench}: a mapped kernel has zero cluster weight")
        matched = sum(raw_weights)
        if source == "simpoint_cluster_groups" and abs(matched - 1.0) > 0.002:
            raise ValueError(
                f"{bench}: assigned cluster weight {matched:.7f} does not cover the profile"
            )

        total = sum(raw_weights)
        for kernel, raw_weight in zip(kernels, raw_weights):
            kernel["weight"] = raw_weight / total
        composition = validate_embedded_composition(row, manifest)
        row["calibration"] = {
            "size": "ref",
            "method": source,
            "mapping_complete": source == "simpoint_cluster_groups",
            "manifest_sha256": manifest_digests[bench],
            "clusters": len(manifest.get("simpoints", [])),
            "matched_profile_weight": matched,
            "embedded_composition": composition,
        }

    calibrated["calibration"] = {
        "method": CALIBRATION_METHOD,
        "size": "ref",
        "cluster_grouped_benchmarks": sum(
            row["calibration"]["mapping_complete"]
            for row in calibrated.get("benchmarks", [])
        ),
        "total_benchmarks": len(calibrated.get("benchmarks", [])),
        "generated_utc": datetime.now(timezone.utc).isoformat(),
        "manifest_sha256": {
            bench: manifest_digests[bench]
            for bench in sorted(manifest_digests)
        },
    }
    return calibrated


def atomic_json_write(path, data):
    tmp = path.with_name(f"{path.name}.tmp.{os.getpid()}")
    try:
        tmp.write_text(json.dumps(data, indent=2) + "\n")
        os.replace(tmp, path)
    finally:
        tmp.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--kernel-map", required=True)
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("--out", required=True)
    parser.add_argument("--min-match", type=float, default=0.05)
    parser.add_argument(
        "--require-cluster-mapping",
        action="store_true",
        help="reject every benchmark that remains a single proxy",
    )
    parser.add_argument("--weight-tolerance", type=float, default=0.002)
    args = parser.parse_args()

    map_path = Path(args.kernel_map)
    data = json.loads(map_path.read_text())
    spec_runs = Path(args.spec_runs)
    manifests = {}
    digests = {}
    for row in data.get("benchmarks", []):
        bench = row["bench"]
        path = spec_runs / f"{bench}_ref_c910" / "manifest.json"
        result = validate_manifest(path, bench, "ref", args.weight_tolerance)
        if not result["valid"]:
            raise SystemExit(f"{bench}: invalid ref manifest: {'; '.join(result['issues'])}")
        manifests[bench] = json.loads(path.read_text())
        digests[bench] = sha256_file(path)

    calibrated = calibrate_map(
        data,
        manifests,
        digests,
        args.min_match,
        args.require_cluster_mapping,
    )
    atomic_json_write(Path(args.out), calibrated)
    print(
        f"[calibrate-map] wrote {args.out} "
        f"benchmarks={len(calibrated.get('benchmarks', []))} size=ref"
    )


if __name__ == "__main__":
    main()
