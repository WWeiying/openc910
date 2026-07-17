#!/usr/bin/env python3
"""Validate SPEC RTL results against quick/full profile contracts."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


SUMMARY_RE = re.compile(
    r"^\|\s*Kernel\s*\|\s*([0-9]+)\s*\|\s*([0-9]+)", re.MULTILINE
)
UNKNOWN_CELL_RE = re.compile(
    r"\|\s*(?:null|n/a|[xz]+)\s*\|", re.IGNORECASE
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_info(path: Path) -> dict[str, str]:
    result = {}
    if not path.is_file():
        return result
    for line in path.read_text().splitlines():
        key, separator, value = line.partition("=")
        if separator:
            result[key] = value
    return result


def validate_case(
    case: str,
    contract: dict,
    results: Path,
    profile: str,
    tolerance: int,
    expected_detail_rows: int,
    features_dir: Path | None,
    require_detail: bool,
) -> tuple[dict, list[str]]:
    errors = []
    summary_path = results / f"{case}.summary.txt"
    report_path = results / f"{case}.run_case.report"
    detail_path = results / f"{case}.detail.perf"
    elf_path = results / f"{case}.elf"
    required = (summary_path, report_path, elf_path)
    if require_detail:
        required += (detail_path,)
    for path in required:
        if not path.is_file():
            errors.append(f"missing {path.name}")
    if errors:
        return {}, errors

    summary = summary_path.read_text()
    match = SUMMARY_RE.search(summary)
    if match is None:
        errors.append("Kernel row is missing from summary")
        cycles = None
        retired = None
    else:
        cycles = int(match.group(1))
        retired = int(match.group(2))

    report = report_path.read_text(errors="replace")
    if "TEST PASS" not in report:
        errors.append("run_case.report does not contain TEST PASS")

    detail_rows = None
    unknown_cells = None
    if detail_path.is_file():
        detail = detail_path.read_text(errors="replace")
        detail_rows = sum(
            1 for line in detail.splitlines() if line.startswith("| Kernel")
        )
        if detail_rows != expected_detail_rows:
            errors.append(
                f"detail/profile/latency rows={detail_rows}, "
                f"expected={expected_detail_rows}"
            )
        unknown_cells = len(UNKNOWN_CELL_RE.findall(detail))
        if unknown_cells:
            errors.append(f"detail report contains {unknown_cells} unknown cells")

    metrics = contract.get("profiles", {}).get(profile, {}).get("metrics", {})
    expected_retired = metrics.get("dynamic_instructions", {}).get("measured")
    delta = None
    if retired is not None and expected_retired is not None:
        delta = retired - expected_retired
        if abs(delta) > tolerance:
            errors.append(
                f"retired boundary delta={delta}, tolerance={tolerance}"
            )

    rtl_hash = sha256(elf_path)
    feature_hash = None
    if features_dir is not None:
        feature_path = features_dir / "cases" / case / "features.json"
        if not feature_path.is_file():
            errors.append(f"missing feature report {feature_path}")
        else:
            features = json.loads(feature_path.read_text())
            feature_profile = features.get("profile", {}).get("kernel_profile")
            if feature_profile != profile:
                errors.append(
                    f"feature profile={feature_profile!r}, expected={profile!r}"
                )
            feature_hash = features.get("provenance", {}).get("elf_sha256")
            if feature_hash != rtl_hash:
                errors.append("feature/RTL ELF SHA256 mismatch")

    return {
        "cycles": cycles,
        "retired": retired,
        "expected_retired": expected_retired,
        "delta": delta,
        "detail_rows": detail_rows,
        "unknown_cells": unknown_cells,
        "rtl_elf_sha256": rtl_hash,
        "feature_elf_sha256": feature_hash,
    }, errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contracts", type=Path, required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--profile", choices=("quick", "full"), required=True)
    parser.add_argument("--features-dir", type=Path)
    parser.add_argument("--retired-tolerance", type=int, default=6)
    parser.add_argument("--expected-detail-rows", type=int, default=1048)
    parser.add_argument("--require-detail", action="store_true")
    parser.add_argument("--allow-missing", action="store_true")
    args = parser.parse_args()
    if args.retired_tolerance < 0 or args.expected_detail_rows < 0:
        raise SystemExit("tolerance and expected row count must be non-negative")

    contracts = json.loads(args.contracts.read_text())
    results = args.results_dir.resolve()
    info = read_info(results / "run.info")
    errors = []
    if info.get("kernel_profile") not in (None, args.profile):
        errors.append(
            f"run.info kernel_profile={info['kernel_profile']!r}, "
            f"expected={args.profile!r}"
        )

    print("# SPEC RTL Profile 校验")
    print()
    print(
        f"profile=`{args.profile}`，retired 边界容差=`{args.retired_tolerance}`，"
        f"detail/profile/latency 期望行数=`{args.expected_detail_rows}`。"
    )
    print()
    print("| case | QEMU ROI | RTL retired | delta | cycles | detail rows | unknown | ELF | status |")
    print("|---|---:|---:|---:|---:|---:|---:|---|---|")
    validated = 0
    for case, contract in contracts.get("cases", {}).items():
        summary = results / f"{case}.summary.txt"
        if not summary.is_file() and args.allow_missing:
            continue
        row, case_errors = validate_case(
            case, contract, results, args.profile, args.retired_tolerance,
            args.expected_detail_rows, args.features_dir, args.require_detail,
        )
        status = "ok" if not case_errors else "invalid"
        elf_status = (
            "match" if args.features_dir is not None and
            row.get("rtl_elf_sha256") == row.get("feature_elf_sha256")
            else "not checked" if args.features_dir is None else "mismatch"
        )
        print(
            f"| `{case}` | {row.get('expected_retired', '')} | "
            f"{row.get('retired', '')} | {row.get('delta', '')} | "
            f"{row.get('cycles', '')} | {row.get('detail_rows', '')} | "
            f"{row.get('unknown_cells', '')} | {elf_status} | {status} |"
        )
        errors.extend(f"{case}: {error}" for error in case_errors)
        validated += 1

    print()
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"validated SPEC RTL profiles: {validated}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
