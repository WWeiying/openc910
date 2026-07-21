#!/usr/bin/env python3
import argparse
import collections
import csv
import hashlib
import json
import math
import re
import sys
from pathlib import Path

try:
    from spec_flow.aggregate_rtl_by_simpoint import (
        resolve_kernel_weights,
        validate_embedded_composition,
    )
    from spec_flow.check_simpoint_status import RATE, SPEED
    from spec_flow.check_profile_quality import quality_for
    from spec_flow.validate_spec_rtl_profiles import (
        validate_case as validate_rtl_profile_case,
    )
except ModuleNotFoundError:
    from aggregate_rtl_by_simpoint import (
        resolve_kernel_weights,
        validate_embedded_composition,
    )
    from check_simpoint_status import RATE, SPEED
    from check_profile_quality import quality_for
    from validate_spec_rtl_profiles import (
        validate_case as validate_rtl_profile_case,
    )


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
MANIFEST_FILE_NAMES = {
    "bbv": lambda stem: f"{stem}.bb",
    "bbv_map": lambda stem: f"{stem}.bb.map",
    "bbv_cmdmap": lambda stem: f"{stem}.bb.cmdmap",
    "bbv_modules": lambda stem: f"{stem}.bb.modules",
    "simpoints": lambda stem: f"{stem}.simpoints",
    "weights": lambda stem: f"{stem}.weights",
    "function_profile": lambda stem: f"{stem}.function_profile.csv",
    "qemu_bbv_log": lambda stem: "qemu_bbv.log",
    "compare_log": lambda stem: "compare.log",
    "simpoint_log": lambda stem: "simpoint.log",
}
REQUIRED_RTL_SUFFIXES = (
    ".run_case.report",
    ".summary.txt",
    ".perf",
    ".detail.perf",
    ".run.vcs.log",
    ".asm",
    ".elf",
    ".symbols.args",
)


def load_json(path):
    return json.loads(path.read_text())


def read_key_value_info(path):
    result = {}
    if not path.is_file():
        return result
    for line in path.read_text(errors="replace").splitlines():
        key, separator, value = line.partition("=")
        if separator:
            result[key] = value
    return result


def is_hex_digest(value, length):
    return (
        isinstance(value, str)
        and len(value) == length
        and all(character in "0123456789abcdefABCDEF" for character in value)
    )


def sha256_file(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_sha256_manifest(root, manifest_path, required_prefix):
    errors = []
    expected = {}
    try:
        lines = manifest_path.read_text().splitlines()
    except OSError as exc:
        return [f"unable to read {manifest_path.name}: {exc}"]
    for line_number, line in enumerate(lines, 1):
        match = re.fullmatch(r"([0-9a-fA-F]{64}) [ *](.+)", line)
        if match is None:
            errors.append(
                f"{manifest_path.name}:{line_number}: invalid SHA256 manifest row"
            )
            continue
        relative = Path(match.group(2))
        if (
            relative.is_absolute()
            or ".." in relative.parts
            or not relative.parts
            or relative.parts[0] != required_prefix
        ):
            errors.append(
                f"{manifest_path.name}:{line_number}: invalid path {relative}"
            )
            continue
        key = relative.as_posix()
        if key in expected:
            errors.append(f"{manifest_path.name}: duplicate path {key}")
            continue
        expected[key] = match.group(1).lower()

    bundle = root / required_prefix
    actual = (
        {
            path.relative_to(root).as_posix()
            for path in bundle.rglob("*")
            if path.is_file() and not path.is_symlink()
        }
        if bundle.is_dir()
        else set()
    )
    symlinks = list(bundle.rglob("*")) if bundle.is_dir() else []
    symlinks = [path for path in symlinks if path.is_symlink()]
    if symlinks:
        errors.append(f"{required_prefix} contains symbolic links")
    missing = sorted(set(expected) - actual)
    extra = sorted(actual - set(expected))
    if missing:
        errors.append(
            f"{manifest_path.name} files missing: " + ",".join(missing[:10])
        )
    if extra:
        errors.append(
            f"{manifest_path.name} files unlisted: " + ",".join(extra[:10])
        )
    for relative in sorted(set(expected) & actual):
        if sha256_file(root / relative) != expected[relative]:
            errors.append(f"{required_prefix} file SHA256 mismatch: {relative}")
    if not expected:
        errors.append(f"{manifest_path.name} contains no files")
    return errors


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
    manifest_files = manifest.get("files")
    if not isinstance(manifest_files, dict):
        issues.append("manifest files mapping is missing")
    else:
        for key, name_builder in MANIFEST_FILE_NAMES.items():
            raw_value = manifest_files.get(key)
            expected_name = name_builder(stem)
            if not isinstance(raw_value, str) or not raw_value:
                issues.append(f"manifest files.{key} is missing")
                continue
            file_reference = Path(raw_value)
            if not file_reference.is_absolute():
                issues.append(f"manifest files.{key} is not absolute")
            if file_reference.name != expected_name:
                issues.append(
                    f"manifest files.{key} name={file_reference.name}, "
                    f"expected={expected_name}"
                )
            if file_reference.parent.name != path.parent.name:
                issues.append(
                    f"manifest files.{key} parent={file_reference.parent.name}, "
                    f"expected={path.parent.name}"
                )
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
    case_owners = {}
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
            previous_owner = case_owners.get(case)
            if previous_owner is not None and previous_owner != row.get("bench"):
                errors.append(
                    f"composite case {case} is shared by "
                    f"{previous_owner} and {row.get('bench')}"
                )
            else:
                case_owners[case] = row.get("bench")
            cases.add(case)
            composition = kernel.get("composition")
            if not isinstance(composition, list) or len(composition) not in (2, 3):
                errors.append(
                    f"{row.get('bench')} kernel {case} must contain exactly "
                    "two or three composite mechanism groups"
                )
            else:
                names = [group.get("name") for group in composition]
                if any(not name for name in names) or len(names) != len(set(names)):
                    errors.append(
                        f"{row.get('bench')} kernel {case} has missing or "
                        "duplicate composition group names"
                    )
                for profile in ("quick", "full"):
                    measured_sum = 0.0
                    profile_valid = True
                    for group in composition:
                        measured_by_profile = group.get(
                            "measured_instruction_share_by_profile", {}
                        )
                        try:
                            target = float(group["target_weight"])
                            measured = float(measured_by_profile[profile])
                        except (KeyError, TypeError, ValueError):
                            errors.append(
                                f"{row.get('bench')} kernel {case} group "
                                f"{group.get('name', '<unnamed>')} is missing "
                                f"a valid {profile} measured instruction share"
                            )
                            profile_valid = False
                            continue
                        measured_sum += measured
                        if abs(measured - target) > 0.005:
                            errors.append(
                                f"{row.get('bench')} kernel {case} group "
                                f"{group.get('name', '<unnamed>')} {profile} "
                                "measured instruction share exceeds the "
                                "0.5 percentage-point target tolerance"
                            )
                    if profile_valid and abs(measured_sum - 1.0) > 0.002:
                        errors.append(
                            f"{row.get('bench')} kernel {case} {profile} "
                            f"measured instruction shares sum to "
                            f"{measured_sum:.7f}, not one"
                        )
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


def validate_cross_map_case_sets(case_sets, expected_total):
    owners = {}
    errors = []
    for label, cases in case_sets.items():
        for case in cases:
            if case in owners:
                errors.append(
                    f"composite case {case} is shared across "
                    f"{owners[case]} and {label} maps"
                )
            else:
                owners[case] = label
    if len(owners) != expected_total:
        errors.append(
            f"mapped unique composite cases={len(owners)}, "
            f"expected={expected_total}"
        )
    return errors


def validate_feature_results(
    root,
    cases,
    required_profile,
    require_clean=False,
    required_commit=None,
):
    errors = []
    passed = 0
    expected_cases = set(cases)
    if root is None or not root.is_dir():
        return 0, ["program-feature directory is missing"]

    info_path = root / "run.info"
    info = read_key_value_info(info_path)
    if not info:
        errors.append("missing program-feature run.info provenance")
    else:
        configured_list = info.get("cases", "").split()
        configured_cases = set(configured_list)
        if len(configured_list) != len(configured_cases):
            errors.append("program-feature run.info contains duplicate cases")
        missing = sorted(expected_cases - configured_cases)
        extra = sorted(configured_cases - expected_cases)
        if missing:
            errors.append(
                "program-feature run.info cases misses: " + ",".join(missing)
            )
        if extra:
            errors.append(
                "program-feature run.info cases has extras: " + ",".join(extra)
            )
        if info.get("kernel_profile") != required_profile:
            errors.append(
                f"program-feature run.info kernel_profile="
                f"{info.get('kernel_profile', 'missing')}, "
                f"expected {required_profile}"
            )
        if info.get("composite_profile") != required_profile:
            errors.append(
                f"program-feature run.info composite_profile="
                f"{info.get('composite_profile', 'missing')}, "
                f"expected {required_profile}"
            )
        expected_trace_profile = (
            "representative" if required_profile == "full" else "rtl"
        )
        if info.get("profile") != expected_trace_profile:
            errors.append(
                f"program-feature run.info profile="
                f"{info.get('profile', 'missing')}, "
                f"expected {expected_trace_profile}"
            )
        commit = info.get("git_commit", "")
        if require_clean:
            if not is_hex_digest(commit, 40):
                errors.append("program-feature run.info git_commit is not a full SHA")
            if info.get("git_state") != "clean":
                errors.append(
                    f"program-feature run.info git_state="
                    f"{info.get('git_state', 'missing')}, expected clean"
                )
            for name in ("git.status", "git.diff"):
                snapshot = root / name
                if not snapshot.is_file():
                    errors.append(f"missing program-feature {name}")
                elif snapshot.stat().st_size:
                    errors.append(f"program-feature {name} is not empty")
        if required_commit is not None and commit != required_commit:
            errors.append(
                f"program-feature git_commit={commit or 'missing'}, "
                f"expected RTL commit {required_commit}"
            )

    cases_root = root / "cases"
    if not cases_root.is_dir():
        return 0, errors + [f"program-feature cases directory is missing: {cases_root}"]
    actual_cases = {
        path.parent.name for path in cases_root.glob("*/features.json")
    }
    missing = sorted(expected_cases - actual_cases)
    extra = sorted(actual_cases - expected_cases)
    if missing:
        errors.append("program-feature reports miss: " + ",".join(missing))
    if extra:
        errors.append("program-feature reports have extras: " + ",".join(extra))

    for case in sorted(expected_cases):
        case_errors = []
        case_dir = cases_root / case
        feature_path = case_dir / "features.json"
        elf_path = case_dir / f"{case}.elf"
        if not feature_path.is_file() or feature_path.stat().st_size == 0:
            errors.append(f"{case}: missing/empty features.json")
            continue
        if not elf_path.is_file() or elf_path.stat().st_size == 0:
            errors.append(f"{case}: missing/empty archived feature ELF")
            continue
        try:
            features = load_json(feature_path)
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{case}: invalid features.json: {exc}")
            continue
        if features.get("case") != case:
            case_errors.append(
                f"feature identity={features.get('case')!r}, expected={case!r}"
            )
        profile = features.get("profile", {}).get("kernel_profile")
        if profile != required_profile:
            case_errors.append(
                f"feature profile={profile!r}, expected={required_profile!r}"
            )
        if features.get("validation", {}).get("passed") is not True:
            case_errors.append("feature validation.passed is not true")
        expected_hash = features.get("provenance", {}).get("elf_sha256")
        if not is_hex_digest(expected_hash, 64):
            case_errors.append("feature ELF SHA256 is missing or invalid")
        elif sha256_file(elf_path) != expected_hash:
            case_errors.append("archived feature ELF SHA256 mismatch")
        dynamic = features.get("execution", {}).get("dynamic_instructions")
        if not isinstance(dynamic, int) or dynamic <= 0:
            case_errors.append(f"invalid dynamic instruction count={dynamic!r}")
        if case_errors:
            errors.extend(f"{case}: {error}" for error in case_errors)
        else:
            passed += 1
    return passed, errors


def validate_rtl_results(
    root,
    cases,
    require_clean=False,
    required_profile=None,
):
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
        parsed = read_key_value_info(run_info)
        configured_list = parsed.get("bench_cases", "").split()
        configured_cases = set(configured_list)
        missing_cases = sorted(set(cases) - configured_cases)
        if missing_cases:
            errors.append(
                "RTL run.info bench_cases misses: " + ",".join(missing_cases)
            )
        if require_clean:
            if len(configured_list) != len(configured_cases):
                errors.append("RTL run.info bench_cases contains duplicates")
            extra_cases = sorted(configured_cases - set(cases))
            if extra_cases:
                errors.append(
                    "RTL run.info bench_cases has extras: "
                    + ",".join(extra_cases)
                )
            commit = parsed.get("git_commit", "")
            if not is_hex_digest(commit, 40):
                errors.append("RTL run.info git_commit is not a full SHA")
            if parsed.get("git_dirty") != "clean":
                errors.append(
                    f"RTL run.info git_dirty={parsed.get('git_dirty', 'missing')}, "
                    "expected clean"
                )
            for name in ("git.status", "git.diff"):
                snapshot = root / name
                if not snapshot.is_file():
                    errors.append(f"missing RTL {name}")
                elif snapshot.stat().st_size:
                    errors.append(f"RTL {name} is not empty")
            simv_digest = parsed.get("simv_sha256", "")
            archived_simv = root / "simv"
            if not is_hex_digest(simv_digest, 64):
                errors.append("RTL run.info simv_sha256 is missing or invalid")
            elif not archived_simv.is_file() or archived_simv.stat().st_size == 0:
                errors.append("missing/empty archived RTL simv")
            elif sha256_file(archived_simv) != simv_digest:
                errors.append("archived RTL simv SHA256 mismatch")
            daidir_manifest = root / "simv.daidir.sha256"
            daidir_manifest_digest = parsed.get(
                "simv_daidir_manifest_sha256", ""
            )
            if not is_hex_digest(daidir_manifest_digest, 64):
                errors.append(
                    "RTL run.info simv_daidir_manifest_sha256 is missing or invalid"
                )
            elif (
                not daidir_manifest.is_file()
                or daidir_manifest.stat().st_size == 0
            ):
                errors.append("missing/empty RTL simv.daidir.sha256")
            elif sha256_file(daidir_manifest) != daidir_manifest_digest:
                errors.append("RTL simv.daidir manifest SHA256 mismatch")
            else:
                errors.extend(
                    validate_sha256_manifest(
                        root, daidir_manifest, "simv.daidir"
                    )
                )
            compile_digest = parsed.get("compile_log_sha256", "")
            compile_log = root / "comp.vcs.log"
            if not is_hex_digest(compile_digest, 64):
                errors.append(
                    "RTL run.info compile_log_sha256 is missing or invalid"
                )
            elif not compile_log.is_file() or compile_log.stat().st_size == 0:
                errors.append("missing/empty RTL comp.vcs.log")
            elif sha256_file(compile_log) != compile_digest:
                errors.append("RTL comp.vcs.log SHA256 mismatch")
            if parsed.get("perf_detail_compiled") != "on":
                errors.append(
                    f"RTL run.info perf_detail_compiled="
                    f"{parsed.get('perf_detail_compiled', 'missing')}, "
                    "expected on"
                )
        if (
            required_profile is not None
            and parsed.get("kernel_profile") != required_profile
        ):
            errors.append(
                f"RTL run.info kernel_profile="
                f"{parsed.get('kernel_profile', 'missing')}, "
                f"expected {required_profile}"
            )

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
    parser.add_argument(
        "--contracts", default="spec_flow/spec_kernel_profiles.json"
    )
    parser.add_argument("--contracts-label")
    parser.add_argument(
        "--features-dir",
        default="smart_run/kernel_features/spec_all_43_full_final",
    )
    parser.add_argument(
        "--quick-features-dir",
        default="smart_run/kernel_features/spec_all_43_quick_final",
    )
    parser.add_argument(
        "--profile", choices=("quick", "full"), default="full"
    )
    parser.add_argument("--rtl-retired-tolerance", type=int, default=6)
    parser.add_argument("--expected-detail-rows", type=int, default=1048)
    parser.add_argument("--weight-tolerance", type=float, default=0.002)
    args = parser.parse_args()
    if args.rtl_retired_tolerance < 0 or args.expected_detail_rows < 0:
        parser.error("RTL tolerance and expected detail rows must be non-negative")

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
    suite_case_sets = {}
    for label, path, expected in (
        ("rate", Path(args.rate_map), RATE),
        ("speed", Path(args.speed_map), SPEED),
    ):
        rows, cases, low, map_errors = validate_map(
            path, expected, Path(args.case_root), root
        )
        mapped_cases.update(cases)
        suite_case_sets[label] = cases
        errors.extend(f"{label} map: {error}" for error in map_errors)
        print(
            f"| `{label}` | {rows} | {len(cases)} | {len(low)} | "
            f"{len(map_errors)} |"
        )
    errors.extend(
        f"RTL map: {error}"
        for error in validate_cross_map_case_sets(
            suite_case_sets, len(RATE) + len(SPEED)
        )
    )

    rtl_root = resolve_rtl_results(args.rtl_results, args.rtl_results_root)
    rtl_passed, rtl_errors = validate_rtl_results(
        rtl_root,
        mapped_cases,
        require_clean=True,
        required_profile=args.profile,
    )
    errors.extend(f"RTL: {error}" for error in rtl_errors)
    print()
    print("## RTL representative kernels")
    print()
    print(f"- Results: `{rtl_root if rtl_root else 'missing'}`")
    print(f"- Passed: {rtl_passed}/{len(mapped_cases)}")
    print(f"- Errors: {len(rtl_errors)}")

    rtl_commit = (
        read_key_value_info(rtl_root / "run.info").get("git_commit")
        if rtl_root is not None
        else None
    )
    feature_sets = (
        ("quick", Path(args.quick_features_dir)),
        ("full", Path(args.features_dir)),
    )
    feature_errors = []
    print()
    print("## 程序特征集")
    print()
    print("| profile | directory | passed | expected | errors |")
    print("|---|---|---:|---:|---:|")
    for feature_profile, feature_root in feature_sets:
        feature_passed, current_errors = validate_feature_results(
            feature_root,
            mapped_cases,
            feature_profile,
            require_clean=True,
            required_commit=rtl_commit,
        )
        feature_errors.extend(
            f"{feature_profile}: {error}" for error in current_errors
        )
        print(
            f"| `{feature_profile}` | `{feature_root}` | "
            f"{feature_passed} | {len(mapped_cases)} | {len(current_errors)} |"
        )
    errors.extend(f"Features: {error}" for error in feature_errors)

    contracts_path = Path(args.contracts)
    contracts_label = args.contracts_label or str(contracts_path)
    features_dir = Path(args.features_dir)
    rtl_profile_errors = []
    rtl_profile_passed = 0
    if not contracts_path.is_file():
        rtl_profile_errors.append(f"profile contracts are missing: {contracts_path}")
    elif not (features_dir / "cases").is_dir():
        rtl_profile_errors.append(f"feature cases are missing: {features_dir}/cases")
    elif rtl_root is None:
        rtl_profile_errors.append("RTL result directory is missing")
    else:
        contracts = load_json(contracts_path).get("cases", {})
        for case in sorted(mapped_cases):
            contract = contracts.get(case)
            if contract is None:
                rtl_profile_errors.append(f"{case}: profile contract is missing")
                continue
            _, case_errors = validate_rtl_profile_case(
                case,
                contract,
                rtl_root,
                args.profile,
                args.rtl_retired_tolerance,
                args.expected_detail_rows,
                features_dir,
                True,
            )
            if case_errors:
                rtl_profile_errors.extend(
                    f"{case}: {error}" for error in case_errors
                )
            else:
                rtl_profile_passed += 1
    errors.extend(
        f"RTL profile: {error}" for error in rtl_profile_errors
    )
    print()
    print("## RTL 与程序特征一致性")
    print()
    print(f"- Profile: `{args.profile}`")
    print(f"- Contracts: `{contracts_label}`")
    print(f"- Features: `{features_dir}`")
    print(f"- ELF/retired/detail passed: {rtl_profile_passed}/{len(mapped_cases)}")
    print(f"- Errors: {len(rtl_profile_errors)}")

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
