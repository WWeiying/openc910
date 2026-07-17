#!/usr/bin/env python3
"""Generate, run, and parse real SPEC representative-region RTL restores."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

try:
    from .l3_metric_names import EVENT_NAMES, add_derived_events, parse_metric_names
    from .validate_l3_checkpoint import find_region, validate_package
except ImportError:
    from l3_metric_names import EVENT_NAMES, add_derived_events, parse_metric_names
    from validate_l3_checkpoint import find_region, validate_package


FORMAT = "openc910-spec-l3-rtl-result-v1"
RESULT_RE = re.compile(
    r"L3_RTL_RESULT checkpoint=(\S+) cycles=(\d+) instructions=(\d+) "
    r"warmup=(\d+) overshoot=(-?\d+)"
)
VALUE_RE = re.compile(r"L3_(EVENT|DETAIL|PROFILE) id=(\d+) value=(\S+)")
LATENCY_RE = re.compile(r"L3_LATENCY id=(\d+) samples=(\S+) sum=(\S+)")
BUCKET_RE = re.compile(
    r"L3_LATENCY_BUCKET id=(\d+) bucket=(\d+) value=(\S+)"
)


def sha256(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_int(value):
    return int(value, 0) if isinstance(value, str) else int(value)


def parse_counter(value):
    return None if re.fullmatch(r"[xXzZ]+", value) else int(value)


def parse_rtl_log(
    log_path, checkpoint_id, metric_names, require_detail=True, report_path=None
):
    text = Path(log_path).read_text(errors="replace")
    matches = RESULT_RE.findall(text)
    if len(matches) != 1:
        raise ValueError(f"expected one L3_RTL_RESULT, found {len(matches)}")
    found_id, cycles, instructions, warmup, overshoot = matches[0]
    if found_id != checkpoint_id:
        raise ValueError(f"RTL checkpoint mismatch: {found_id} != {checkpoint_id}")
    report_passed = (
        report_path is not None
        and Path(report_path).is_file()
        and "TEST PASS: L3 checkpoint ROI complete"
        in Path(report_path).read_text(errors="replace")
    )
    if "TEST PASS: L3 checkpoint ROI complete" not in text and not report_passed:
        raise ValueError("RTL log does not contain the L3 TEST PASS marker")

    raw = {"EVENT": {}, "DETAIL": {}, "PROFILE": {}}
    for group, metric_id, value in VALUE_RE.findall(text):
        raw[group][int(metric_id)] = parse_counter(value)
    if set(raw["EVENT"]) != set(EVENT_NAMES):
        raise ValueError("RTL log does not contain all 42 base event counters")
    unknown_events = [item for item, value in raw["EVENT"].items() if value is None]
    if unknown_events:
        raise ValueError(f"base RTL event counters contain X/Z: {unknown_events}")

    events = add_derived_events(
        {EVENT_NAMES[item]: value for item, value in raw["EVENT"].items()}
    )
    details = {
        metric_names["details"][item]: value
        for item, value in raw["DETAIL"].items()
    }
    profiles = {
        metric_names["profiles"][item]: value
        for item, value in raw["PROFILE"].items()
    }
    latencies = {}
    for metric_id, samples, total in LATENCY_RE.findall(text):
        metric_id = int(metric_id)
        latencies[metric_names["latencies"][metric_id]] = {
            "samples": parse_counter(samples),
            "sum_cycles": parse_counter(total),
            "buckets": {},
        }
    for metric_id, bucket, value in BUCKET_RE.findall(text):
        name = metric_names["latencies"][int(metric_id)]
        latencies[name]["buckets"][str(int(bucket))] = parse_counter(value)

    if require_detail:
        expected = {
            "detail": len(metric_names["details"]),
            "profile": len(metric_names["profiles"]),
            "latency": len(metric_names["latencies"]),
        }
        observed = {
            "detail": len(details),
            "profile": len(profiles),
            "latency": len(latencies),
        }
        if observed != expected:
            raise ValueError(
                f"PERF_DETAIL metrics incomplete: observed={observed} expected={expected}"
            )
        if any(len(item["buckets"]) != 6 for item in latencies.values()):
            raise ValueError("one or more latency metrics lack all six buckets")

    return {
        "checkpoint_id": checkpoint_id,
        "status": "pass",
        "cycles": int(cycles),
        "instructions": int(instructions),
        "warmup_instructions": int(warmup),
        "retirement_overshoot": int(overshoot),
        "events": events,
        "details": details,
        "profiles": profiles,
        "latencies": latencies,
        "unknown_metrics": {
            "details": [
                metric_names["details"][item]
                for item, value in raw["DETAIL"].items()
                if value is None
            ],
            "profiles": [
                metric_names["profiles"][item]
                for item, value in raw["PROFILE"].items()
                if value is None
            ],
            "latencies": [
                name
                for name, value in latencies.items()
                if value["samples"] is None
                or value["sum_cycles"] is None
                or any(item is None for item in value["buckets"].values())
            ],
        },
    }


def select_regions(plan, requested):
    all_regions = []
    supported = []
    blockers = {}
    for benchmark in plan["benchmarks"]:
        for region in benchmark["regions"]:
            all_regions.append(region)
            if benchmark.get("ready_for_capture", True):
                supported.append(region)
            else:
                blockers[region["checkpoint_id"]] = benchmark.get("issues", [])
    if not requested:
        return supported
    by_id = {region["checkpoint_id"]: region for region in all_regions}
    missing = sorted(set(requested) - set(by_id))
    if missing:
        raise ValueError("unknown checkpoints: " + ",".join(missing))
    unsupported = sorted(set(requested) & set(blockers))
    if unsupported:
        details = "; ".join(
            f"{item}: {','.join(blockers[item])}" for item in unsupported
        )
        raise ValueError("checkpoints are not capture-ready: " + details)
    return [by_id[item] for item in requested]


def update_checkpoint_validation(package, result_path, result):
    manifest_path = package / "checkpoint.json"
    checkpoint = json.loads(manifest_path.read_text())
    checkpoint["status"] = "rtl_execution_validated"
    validation = checkpoint.setdefault("validation", {})
    validation["rtl_restore_match"] = True
    validation["rtl_execution_result"] = {
        "path": str(result_path.resolve()),
        "sha256": sha256(result_path),
        "cycles": result["cycles"],
        "instructions": result["instructions"],
    }
    manifest_path.write_text(json.dumps(checkpoint, indent=2) + "\n")


def run_region(args, repo_root, plan, region, metric_names):
    checkpoint_id = region["checkpoint_id"]
    package = args.checkpoint_root / checkpoint_id
    errors = validate_package(package, plan, require_restore=True)
    if errors:
        raise ValueError("; ".join(errors))
    checkpoint = json.loads((package / "checkpoint.json").read_text())
    _, frozen_region = find_region(plan, checkpoint_id)

    result_dir = args.rtl_results / checkpoint_id
    build_dir = args.build_root / checkpoint_id
    result_dir.mkdir(parents=True, exist_ok=True)
    build_dir.mkdir(parents=True, exist_ok=True)
    generator = repo_root / "spec_flow/l3_generate_restore.py"
    lanes = build_dir / "rtl_lanes"
    if not args.skip_generate:
        command = [
            sys.executable,
            str(generator),
            "--package",
            str(package),
            "--output",
            str(build_dir),
            "--rtl",
        ]
        if args.toolchain:
            command.extend(("--toolchain", str(args.toolchain)))
        subprocess.run(command, check=True)
    if not all((lanes / f"checkpoint.ram{lane}.hex").is_file() for lane in range(16)):
        raise ValueError(f"missing generated RTL SRAM lanes in {lanes}")

    registers_path = package / checkpoint["artifacts"]["registers"]["path"]
    registers = json.loads(registers_path.read_text())["registers"]
    start_pc = parse_int(registers["pc"]["value"])
    capture_observed = int(checkpoint["capture"]["observed_instruction"])
    warmup = int(frozen_region["roi_start_instruction"]) - capture_observed
    if warmup < 0:
        raise ValueError(f"negative effective warmup for {checkpoint_id}: {warmup}")
    roi = int(frozen_region["roi_instructions"])

    plusargs = [
        f"+l3_ram_prefix={lanes / 'checkpoint'}",
        f"+l3_start_pc={start_pc:x}",
        f"+l3_warmup={warmup}",
        f"+l3_roi={roi}",
        f"+l3_checkpoint={checkpoint_id}",
        f"+l3_max_cycles={args.max_cycles}",
    ]
    invocation = [str(args.simv), *plusargs]
    (result_dir / "rtl_command.json").write_text(
        json.dumps(
            {
                "command": invocation,
                "cwd": str(args.work_dir),
                "checkpoint_sha256": sha256(package / "checkpoint.json"),
                "testbench_sha256": sha256(args.testbench),
                "effective_warmup_instructions": warmup,
                "roi_instructions": roi,
            },
            indent=2,
        )
        + "\n"
    )
    if args.dry_run:
        print("DRY-RUN " + " ".join(invocation))
        return

    log_path = result_dir / "rtl.log"
    if not args.parse_existing:
        shutil.copy2(lanes / "inst.pat", args.work_dir / "inst.pat")
        shutil.copy2(lanes / "data.pat", args.work_dir / "data.pat")
        for stale in ("run_case.report", "pc_trace.log"):
            path = args.work_dir / stale
            if path.exists():
                path.unlink()
        print(f"[RTL] start {checkpoint_id}", flush=True)
        with log_path.open("w") as log:
            completed = subprocess.run(
                invocation,
                cwd=args.work_dir,
                stdout=log,
                stderr=subprocess.STDOUT,
            )
        if completed.returncode != 0:
            raise RuntimeError(
                f"RTL simulation failed for {checkpoint_id}: "
                f"returncode={completed.returncode}"
            )
        if (args.work_dir / "run_case.report").is_file():
            shutil.copy2(
                args.work_dir / "run_case.report", result_dir / "run_case.report"
            )
    elif not log_path.is_file():
        raise ValueError(f"missing existing RTL log: {log_path}")
    result = parse_rtl_log(
        log_path,
        checkpoint_id,
        metric_names,
        require_detail=not args.allow_basic,
        report_path=result_dir / "run_case.report",
    )
    result.update(
        {
            "format": FORMAT,
            "benchmark": checkpoint["benchmark"],
            "cluster": checkpoint["cluster"],
            "weight": checkpoint["weight"],
            "source": {
                "checkpoint_manifest": str((package / "checkpoint.json").resolve()),
                "checkpoint_manifest_sha256": sha256(package / "checkpoint.json"),
                "rtl_log": "rtl.log",
                "testbench_sha256": sha256(args.testbench),
            },
        }
    )
    result_path = result_dir / "rtl_result.json"
    result_path.write_text(json.dumps(result, indent=2) + "\n")
    if (args.work_dir / "pc_trace.log").is_file():
        shutil.copy2(args.work_dir / "pc_trace.log", result_dir / "pc_trace.log")
    update_checkpoint_validation(package, result_path, result)
    print(
        f"[RTL] pass {checkpoint_id} cycles={result['cycles']} "
        f"instructions={result['instructions']}",
        flush=True,
    )


def main():
    repo_root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", required=True, type=Path)
    parser.add_argument("--checkpoint-root", required=True, type=Path)
    parser.add_argument("--rtl-results", required=True, type=Path)
    parser.add_argument("--build-root", required=True, type=Path)
    parser.add_argument("--checkpoint", action="append", default=[])
    parser.add_argument(
        "--simv", type=Path, default=repo_root / "smart_run/work/simv"
    )
    parser.add_argument(
        "--work-dir", type=Path, default=repo_root / "smart_run/work"
    )
    parser.add_argument(
        "--testbench", type=Path, default=repo_root / "smart_run/logical/tb/tb.v"
    )
    parser.add_argument("--toolchain", type=Path)
    parser.add_argument("--max-cycles", type=int, default=500_000_000)
    parser.add_argument("--skip-generate", action="store_true")
    parser.add_argument("--parse-existing", action="store_true")
    parser.add_argument("--allow-basic", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    args.plan = args.plan.resolve()
    args.checkpoint_root = args.checkpoint_root.resolve()
    args.rtl_results = args.rtl_results.resolve()
    args.build_root = args.build_root.resolve()
    args.simv = args.simv.resolve()
    args.work_dir = args.work_dir.resolve()
    args.testbench = args.testbench.resolve()
    if args.toolchain:
        args.toolchain = args.toolchain.resolve()
    if not args.dry_run and not args.simv.is_file():
        raise SystemExit(f"missing RTL simulator: {args.simv}")
    args.work_dir.mkdir(parents=True, exist_ok=True)

    plan = json.loads(args.plan.read_text())
    regions = select_regions(plan, args.checkpoint)
    metric_names = parse_metric_names(args.testbench)
    print(f"selected_regions={len(regions)}")
    for region in regions:
        run_region(args, repo_root, plan, region, metric_names)


if __name__ == "__main__":
    main()
