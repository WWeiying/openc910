#!/usr/bin/env python3
import argparse
import collections
import csv
import hashlib
import json
import math
import sys
from pathlib import Path

try:
    from spec_flow.aggregate_rtl_by_simpoint import (
        resolve_kernel_weights,
        validate_embedded_composition,
    )
    from spec_flow.check_simpoint_status import RATE, SPEED
    from spec_flow.check_profile_quality import quality_for
except ModuleNotFoundError:
    from aggregate_rtl_by_simpoint import (
        resolve_kernel_weights,
        validate_embedded_composition,
    )
    from check_simpoint_status import RATE, SPEED
    from check_profile_quality import quality_for


SIZES = ("test", "train", "ref")
EXPECTED_INTERVAL = 100_000_000
EXPECTED_MAX_K = 5
EXPECTED_RESERVED_VA = "0x4000000000"
REQUIRED_ARTIFACTS = (
    ".bb",
    ".bb.map",
    ".bb.cmdmap",
    ".bb.modules",
    ".simpoints",
    ".weights",
    ".function_profile.csv",
)
REQUIRED_LOGS = ("qemu_bbv.log", "compare.log", "simpoint.log")
REQUIRED_RTL_SUFFIXES = (
    ".run_case.report",
    ".summary.txt",
    ".perf",
    ".detail.perf",
    ".run.vcs.log",
    ".asm",
    ".symbols.args",
)


def load_json(path):
    return json.loads(path.read_text())


def sha256_file(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def inspect_bbv_map(bbv_map_path, modules_path, cmdmap_path):
    module_ranges = {}
    cmd_ranges = []
    try:
        with modules_path.open() as stream:
            next(stream, None)
            for line in stream:
                fields = line.rstrip("\n").split("\t")
                if len(fields) >= 3:
                    cmd_index = int(fields[0])
                    module_ranges.setdefault(cmd_index, []).append(
                        (int(fields[1], 16), int(fields[2], 16))
                    )
        with cmdmap_path.open() as stream:
            next(stream, None)
            for line in stream:
                fields = line.rstrip("\n").split("\t", 4)
                if len(fields) >= 3:
                    cmd_ranges.append(
                        (int(fields[0]), int(fields[1]), int(fields[2]))
                    )

        hits_by_cmd = collections.Counter()
        map_line_count = 0
        unique_map_ids = set()
        maximum_map_id = 0
        with bbv_map_path.open() as stream:
            for line in stream:
                fields = line.split()
                if len(fields) < 2:
                    continue
                block_id = int(fields[0])
                pc = int(fields[1], 16)
                map_line_count += 1
                unique_map_ids.add(block_id)
                maximum_map_id = max(maximum_map_id, block_id)
                cmd_index = next(
                    (
                        index
                        for index, start, end in cmd_ranges
                        if start <= block_id <= end
                    ),
                    None,
                )
                if cmd_index is None:
                    continue
                if any(
                    base <= pc < end
                    for base, end in module_ranges.get(cmd_index, [])
                ):
                    hits_by_cmd[cmd_index] += 1

        active_commands = [
            index for index, start, end in cmd_ranges if start <= end
        ]
        missing_commands = [
            index
            for index in active_commands
            if not module_ranges.get(index) or hits_by_cmd[index] == 0
        ]
        cmdmap_contiguous = bool(cmd_ranges)
        previous_end = 0
        for _, start, end in cmd_ranges:
            if start != previous_end + 1 or end < start:
                cmdmap_contiguous = False
                break
            previous_end = end
        if map_line_count and previous_end != maximum_map_id:
            cmdmap_contiguous = False

        return {
            "hits": sum(hits_by_cmd.values()),
            "ranges": sum(len(items) for items in module_ranges.values()),
            "missing_commands": missing_commands,
            "map_lines": map_line_count,
            "unique_map_ids": len(unique_map_ids),
            "cmdmap_contiguous": cmdmap_contiguous,
        }
    except (OSError, StopIteration, ValueError):
        return {
            "hits": 0,
            "ranges": 0,
            "missing_commands": [],
            "map_lines": 0,
            "unique_map_ids": 0,
            "cmdmap_contiguous": False,
        }


def validate_manifest(path, bench, size, tolerance):
    if not path.exists():
        return {
            "status": "missing",
            "module_map": False,
            "valid": False,
            "provenance": False,
            "clusters": 0,
            "weight_sum": 0.0,
            "issues": ["manifest missing"],
        }
    try:
        manifest = load_json(path)
    except Exception as exc:
        return {
            "status": "bad_manifest",
            "module_map": False,
            "valid": False,
            "provenance": False,
            "clusters": 0,
            "weight_sum": 0.0,
            "issues": [f"manifest parse failed: {exc}"],
        }

    issues = []
    validation = manifest.get("validation", {})
    simpoints = manifest.get("simpoints", [])
    weights = []
    for item in simpoints:
        try:
            weights.append(float(item.get("weight", 0.0)))
        except (TypeError, ValueError):
            weights.append(float("nan"))
    weight_sum = sum(weights)

    if manifest.get("bench") != bench or manifest.get("size") != size:
        issues.append("manifest identity mismatch")
    if manifest.get("interval") != EXPECTED_INTERVAL:
        issues.append(f"interval={manifest.get('interval')} expected={EXPECTED_INTERVAL}")
    if manifest.get("max_k") != EXPECTED_MAX_K:
        issues.append(f"max_k={manifest.get('max_k')} expected={EXPECTED_MAX_K}")
    if manifest.get("bbv_type") != "qemu_tb_instruction_weighted":
        issues.append(f"unexpected bbv_type={manifest.get('bbv_type')}")
    if manifest.get("qemu_cpu") != "c910":
        issues.append(f"unexpected qemu_cpu={manifest.get('qemu_cpu')}")

    collection = manifest.get("collection", {})
    if not collection.get("full_program"):
        issues.append("collection is not marked full_program")
    if collection.get("skip_intervals", 0) != 0:
        issues.append(f"skip_intervals={collection.get('skip_intervals')}")
    if collection.get("max_intervals") is not None:
        issues.append(f"max_intervals={collection.get('max_intervals')}")
    try:
        bbv_id_stride = int(collection.get("bbv_id_stride", 0))
    except (TypeError, ValueError):
        bbv_id_stride = 0
    if (
        bench in {"500.perlbench_r", "600.perlbench_s"}
        and bbv_id_stride < (1 << 32)
    ):
        issues.append("Perlbench BBV ID stride is missing or too small")

    if not validation.get("compare_pass"):
        issues.append("SPEC compare did not pass")
    if not validation.get("simpoint_done"):
        issues.append("SimPoint not complete")
    if not validation.get("module_map_done"):
        issues.append("guest module map not complete")
    _, _, weighted_unknown, profile_quality = quality_for(manifest)
    if profile_quality == "low":
        issues.append(
            f"weighted external unknown={weighted_unknown:.2f}% exceeds 20%"
        )
    module_method = manifest.get("module_map_method")
    if module_method is None and manifest.get("qemu_reserved_va") == EXPECTED_RESERVED_VA:
        module_method = "fixed_va"
    address_provenance_ok = bool(
        (module_method == "fixed_va" and manifest.get("qemu_reserved_va") == EXPECTED_RESERVED_VA)
        or (
            module_method == "aslr_slide_recovered"
            and manifest.get("qemu_reserved_va") is None
        )
    )
    if not address_provenance_ok:
        issues.append(
            "module address provenance must be fixed_va@0x4000000000 or "
            "aslr_slide_recovered"
        )

    counts = manifest.get("counts", {})
    interval_count = counts.get("bbv_intervals", 0)
    mapped_blocks = counts.get("mapped_blocks", 0)
    if not isinstance(interval_count, int) or interval_count <= 0:
        issues.append(f"invalid bbv_intervals={interval_count}")
        interval_count = 0
    if not isinstance(mapped_blocks, int) or mapped_blocks <= 0:
        issues.append(f"invalid mapped_blocks={mapped_blocks}")

    if not 1 <= len(simpoints) <= EXPECTED_MAX_K:
        issues.append(f"cluster count={len(simpoints)} outside 1..{EXPECTED_MAX_K}")
    clusters = [item.get("cluster") for item in simpoints]
    intervals = [item.get("interval") for item in simpoints]
    if len(set(clusters)) != len(clusters):
        issues.append("duplicate SimPoint cluster IDs")
    if len(set(intervals)) != len(intervals):
        issues.append("duplicate SimPoint intervals")
    if any(not math.isfinite(weight) or weight <= 0.0 for weight in weights):
        issues.append("SimPoint weights must be finite and positive")
    if not math.isfinite(weight_sum) or abs(weight_sum - 1.0) > tolerance:
        issues.append(f"weight_sum={weight_sum:.7f}")
    if interval_count and any(
        not isinstance(interval, int) or interval < 0 or interval >= interval_count
        for interval in intervals
    ):
        issues.append("SimPoint interval is outside the BBV range")

    stem = f"{bench}_{size}"
    expected_artifacts = [path.parent / f"{stem}{suffix}" for suffix in REQUIRED_ARTIFACTS]
    expected_artifacts.extend(path.parent / name for name in REQUIRED_LOGS)
    for artifact in expected_artifacts:
        if not artifact.is_file() or artifact.stat().st_size == 0:
            issues.append(f"missing/empty artifact {artifact.name}")

    map_inspection = inspect_bbv_map(
        path.parent / f"{stem}.bb.map",
        path.parent / f"{stem}.bb.modules",
        path.parent / f"{stem}.bb.cmdmap",
    )
    if map_inspection["map_lines"] != mapped_blocks:
        issues.append(
            f"BBV map lines={map_inspection['map_lines']} manifest mapped_blocks={mapped_blocks}"
        )
    if map_inspection["unique_map_ids"] != map_inspection["map_lines"]:
        issues.append(
            f"duplicate BBV map IDs: lines={map_inspection['map_lines']} "
            f"unique={map_inspection['unique_map_ids']}"
        )
    if not map_inspection["cmdmap_contiguous"]:
        issues.append("BBV command ID ranges are not contiguous and non-empty")
    if map_inspection["ranges"] == 0:
        issues.append("guest module map contains no load ranges")
    elif map_inspection["hits"] == 0:
        issues.append("guest module ranges do not overlap BBV PCs")
    if map_inspection["missing_commands"]:
        issues.append(
            "guest module ranges miss BBV commands: "
            + ",".join(str(index) for index in map_inspection["missing_commands"])
        )

    profile_path = path.parent / f"{stem}.function_profile.csv"
    if profile_path.is_file() and profile_path.stat().st_size:
        try:
            with profile_path.open(newline="") as stream:
                profile_rows = list(csv.DictReader(stream))
            profile_clusters = {
                int(row["cluster"])
                for row in profile_rows
                if row.get("scope") == "simpoint" and row.get("cluster", "") != ""
            }
            if not profile_rows:
                issues.append("function profile has no rows")
            if set(clusters) - profile_clusters:
                issues.append("function profile misses one or more SimPoint clusters")
        except (KeyError, TypeError, ValueError, csv.Error) as exc:
            issues.append(f"invalid function profile: {exc}")

    provenance = manifest.get("provenance", {})
    provenance_ok = bool(
        provenance.get("git_commit") not in {None, "", "unknown"}
        and len(str(provenance.get("git_commit"))) == 40
        and provenance.get("qemu_path")
        and provenance.get("qemu_version") not in {None, "", "unknown"}
        and provenance.get("compiler_path")
        and provenance.get("compiler_version") not in {None, "", "unknown"}
        and provenance.get("simpoint_path")
    )
    if not provenance_ok:
        issues.append("provenance incomplete")

    optimize = str(manifest.get("optimize", ""))
    for option in ("-O2", "-march=rv64imafdcxtheadc", "-mabi=lp64d", "-mtune=c910"):
        if option not in optimize.split():
            issues.append(f"compiler option missing: {option}")

    module_map = bool(
        validation.get("module_map_done")
        and address_provenance_ok
        and (path.parent / f"{stem}.bb.modules").is_file()
        and map_inspection["ranges"] > 0
        and map_inspection["hits"] > 0
        and not map_inspection["missing_commands"]
        and map_inspection["unique_map_ids"] == map_inspection["map_lines"]
        and map_inspection["cmdmap_contiguous"]
    )
    return {
        "status": "ok" if not issues else "invalid",
        "module_map": module_map,
        "valid": not issues,
        "provenance": provenance_ok,
        "clusters": len(simpoints),
        "weight_sum": weight_sum,
        "issues": issues,
    }


def validate_map(path, expected, case_root, spec_runs):
    errors = []
    data = load_json(path)
    if data.get("default_size") != "ref":
        errors.append(
            f"map default_size is {data.get('default_size', 'unspecified')}, expected ref"
        )
    if data.get("calibration_size") != "ref":
        errors.append(
            f"map calibration is {data.get('calibration_size', 'unspecified')}, expected ref"
        )
    calibration = data.get("calibration")
    calibration_claimed = data.get("calibration_size") == "ref"
    if calibration_claimed and (
        not isinstance(calibration, dict)
        or calibration.get("method") != "ref_simpoint_cluster_groups_v2"
        or calibration.get("size") != "ref"
    ):
        errors.append("missing ref calibration provenance")
    top_digests = (
        calibration.get("manifest_sha256", {})
        if isinstance(calibration, dict)
        else {}
    )
    rows = data.get("benchmarks", [])
    mapped = [row.get("bench") for row in rows]
    missing = sorted(set(expected) - set(mapped))
    extra = sorted(set(mapped) - set(expected))
    duplicate = sorted({bench for bench in mapped if mapped.count(bench) > 1})
    low = []
    cases = set()
    for row in rows:
        kernels = row.get("kernels", [])
        if not kernels:
            errors.append(f"benchmark has no kernels: {row.get('bench')}")
            continue
        if len(kernels) != 1:
            errors.append(
                f"{row.get('bench')} must map to exactly one composite kernel"
            )
        explicit_weights = ["weight" in kernel for kernel in kernels]
        cluster_weights = [bool(kernel.get("clusters")) for kernel in kernels]
        function_weights = [
            bool(
                kernel.get("simpoint_functions")
                or kernel.get("simpoint_function_patterns")
            )
            for kernel in kernels
        ]
        if any(cluster_weights) and not all(cluster_weights):
            errors.append(
                f"{row.get('bench')} must assign clusters for every mapped kernel"
            )
        if any(cluster_weights) and any(function_weights):
            errors.append(
                f"{row.get('bench')} cannot mix cluster and function selectors"
            )
        if all(explicit_weights):
            try:
                kernel_weight_sum = sum(float(kernel["weight"]) for kernel in kernels)
                if any(float(kernel["weight"]) <= 0 for kernel in kernels):
                    raise ValueError
                if abs(kernel_weight_sum - 1.0) > 0.002:
                    errors.append(
                        f"kernel weight sum for {row.get('bench')} is {kernel_weight_sum:.7f}"
                    )
            except (TypeError, ValueError):
                errors.append(f"invalid kernel weight for {row.get('bench')}")
        elif not all(cluster_weights) and not all(function_weights):
            errors.append(
                f"{row.get('bench')} must define all explicit weights or all cluster selectors"
            )
        if calibration_claimed and len(kernels) > 1 and not all(cluster_weights):
            errors.append(
                f"{row.get('bench')} multi-kernel ref calibration lacks cluster selectors"
            )
        if not all(cluster_weights):
            errors.append(
                f"incomplete cluster mechanism mapping for {row.get('bench')}"
            )

        if calibration_claimed:
            bench = row.get("bench", "")
            manifest_path = spec_runs / f"{bench}_ref_c910" / "manifest.json"
            row_calibration = row.get("calibration", {})
            if not manifest_path.is_file():
                errors.append(f"missing ref calibration manifest for {bench}")
            else:
                digest = sha256_file(manifest_path)
                if row_calibration.get("manifest_sha256") != digest:
                    errors.append(f"stale row calibration manifest for {bench}")
                if top_digests.get(bench) != digest:
                    errors.append(f"stale map calibration manifest for {bench}")
                try:
                    manifest = load_json(manifest_path)
                    raw_weights, source = resolve_kernel_weights(
                        row, manifest, verify_stored=True
                    )
                    validate_embedded_composition(row, manifest)
                    if len(kernels) > 1 and source != "simpoint_cluster_groups":
                        errors.append(
                            f"{bench} multi-kernel map is not cluster-derived"
                        )
                except (KeyError, TypeError, ValueError, ZeroDivisionError) as exc:
                    errors.append(f"cannot verify ref kernel weights for {bench}: {exc}")
            if row_calibration.get("size") != "ref":
                errors.append(f"invalid row calibration size for {bench}")
            expected_method = (
                "simpoint_cluster_groups" if all(cluster_weights) else "single_proxy"
            )
            if row_calibration.get("method") != expected_method:
                errors.append(f"invalid row calibration method for {bench}")
            try:
                clusters = int(row_calibration.get("clusters", 0))
                matched = float(row_calibration.get("matched_profile_weight", 0.0))
                if clusters <= 0 or not math.isfinite(matched) or matched <= 0.0:
                    raise ValueError
            except (TypeError, ValueError):
                errors.append(f"invalid row calibration evidence for {bench}")

        row_cases = [kernel.get("case", "") for kernel in kernels]
        if len(set(row_cases)) != len(row_cases):
            errors.append(f"duplicate kernel mapping for {row.get('bench')}")
        for kernel in kernels:
            case = kernel.get("case", "")
            cases.add(case)
            if kernel.get("coverage") not in {"high", "medium"}:
                low.append((row.get("bench"), case))
            case_dir = case_root / case
            if not case_dir.is_dir() or not any(case_dir.glob("*.c")):
                errors.append(f"missing kernel source: {case}")
    if missing:
        errors.append(f"missing benchmarks: {','.join(missing)}")
    if extra:
        errors.append(f"extra benchmarks: {','.join(extra)}")
    if duplicate:
        errors.append(f"duplicate benchmarks: {','.join(duplicate)}")
    if low:
        errors.append(
            "low coverage: " + ",".join(f"{bench}->{case}" for bench, case in low)
        )
    return len(rows), cases, low, errors


def validate_rtl_results(root, cases):
    errors = []
    passed = 0
    if root is None or not root.is_dir():
        return 0, ["RTL result directory is missing"]

    run_info = root / "run.info"
    if not run_info.is_file():
        errors.append("missing RTL run.info provenance")
    else:
        info = run_info.read_text(errors="replace")
        for field in ("git_commit=", "git_branch=", "git_dirty=", "bench_cases="):
            if field not in info:
                errors.append(f"RTL run.info missing {field[:-1]}")

    for case in sorted(cases):
        missing = [
            f"{case}{suffix}"
            for suffix in REQUIRED_RTL_SUFFIXES
            if not (root / f"{case}{suffix}").is_file()
            or (root / f"{case}{suffix}").stat().st_size == 0
        ]
        if missing:
            errors.append(f"{case}: missing RTL artifacts: {','.join(missing)}")
            continue
        report = (root / f"{case}.run_case.report").read_text(errors="replace")
        summary = (root / f"{case}.summary.txt").read_text(errors="replace")
        perf = (root / f"{case}.perf").read_text(errors="replace")
        detail = (root / f"{case}.detail.perf").read_text(errors="replace")
        if "TEST PASS" not in report or "TEST FAIL" in report:
            errors.append(f"{case}: RTL report is not TEST PASS")
            continue
        if "|     Kernel" not in summary or "|     Kernel" not in perf:
            errors.append(f"{case}: missing RTL Kernel phase")
            continue
        if "Detailed Performance Statistics" not in detail:
            errors.append(f"{case}: missing detailed RTL counters")
            continue
        passed += 1
    return passed, errors


def resolve_rtl_results(explicit, search_root):
    if explicit:
        return Path(explicit)
    candidates = [
        path
        for path in Path(search_root).glob("spec2017_l2plus_rtl_full_*")
        if path.is_dir()
    ]
    return max(candidates, key=lambda path: path.stat().st_mtime) if candidates else None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("--rate-map", default="spec_flow/spec2017_kernel_map.json")
    parser.add_argument(
        "--speed-map", default="spec_flow/spec2017_speed_kernel_map.json"
    )
    parser.add_argument("--case-root", default="smart_run/tests/cases")
    parser.add_argument("--rtl-results", default="")
    parser.add_argument("--rtl-results-root", default="smart_run/results")
    parser.add_argument("--weight-tolerance", type=float, default=0.002)
    args = parser.parse_args()

    root = Path(args.spec_runs)
    errors = []
    total = 0
    ok = 0
    enhanced = 0
    provenance_ok = 0

    print("# SPEC CPU2017 L2+ 最终验收")
    print()
    print("## SimPoint 矩阵")
    print()
    print("| suite | input | ok | total | provenance | enhanced module profiles |")
    print("|---|---|---:|---:|---:|---:|")
    for suite, benches in (("speed", SPEED), ("rate", RATE)):
        for size in SIZES:
            group_ok = 0
            group_enhanced = 0
            group_provenance = 0
            for bench in benches:
                path = root / f"{bench}_{size}_c910" / "manifest.json"
                result = validate_manifest(path, bench, size, args.weight_tolerance)
                total += 1
                if result["valid"]:
                    ok += 1
                    group_ok += 1
                else:
                    errors.append(
                        f"{suite}/{size}/{bench}: {result['status']}; "
                        + "; ".join(result["issues"])
                    )
                if result["module_map"]:
                    enhanced += 1
                    group_enhanced += 1
                if result["provenance"]:
                    provenance_ok += 1
                    group_provenance += 1
            print(
                f"| `{suite}` | `{size}` | {group_ok} | {len(benches)} | "
                f"{group_provenance} | {group_enhanced} |"
            )

    print()
    print("## RTL 映射")
    print()
    print("| map | benchmarks | unique kernels | low coverage | errors |")
    print("|---|---:|---:|---:|---:|")
    mapped_cases = set()
    for label, path, expected in (
        ("rate", Path(args.rate_map), RATE),
        ("speed", Path(args.speed_map), SPEED),
    ):
        rows, cases, low, map_errors = validate_map(
            path, expected, Path(args.case_root), root
        )
        mapped_cases.update(cases)
        errors.extend(f"{label} map: {error}" for error in map_errors)
        print(
            f"| `{label}` | {rows} | {len(cases)} | {len(low)} | "
            f"{len(map_errors)} |"
        )

    rtl_root = resolve_rtl_results(args.rtl_results, args.rtl_results_root)
    rtl_passed, rtl_errors = validate_rtl_results(rtl_root, mapped_cases)
    errors.extend(f"RTL: {error}" for error in rtl_errors)
    print()
    print("## RTL representative kernels")
    print()
    print(f"- Results: `{rtl_root if rtl_root else 'missing'}`")
    print(f"- Passed: {rtl_passed}/{len(mapped_cases)}")
    print(f"- Errors: {len(rtl_errors)}")

    print()
    print(
        f"验收汇总：SimPoint={ok}/{total}，provenance={provenance_ok}/{total}，"
        f"增强模块画像={enhanced}/{total}，"
        f"错误={len(errors)}。"
    )
    if errors:
        print()
        print("## 未通过项")
        print()
        for error in errors:
            print(f"- {error}")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
