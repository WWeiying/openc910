#!/usr/bin/env python3
"""Build a reproducible checkpoint plan from completed SPEC SimPoint data."""

import argparse
import csv
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path


FORMAT = "openc910-spec-l3-plan-v1"
BBV_PAIR = re.compile(r":(\d+):(\d+)")


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def localize_path(value, repo_root):
    path = Path(value)
    if path.exists():
        return path.resolve()
    if path.is_absolute() and path.parts[:2] == ("/", "work"):
        candidate = repo_root.joinpath(*path.parts[2:])
        if candidate.exists():
            return candidate.resolve()
    return path


def load_cmdmap(path, repo_root):
    commands = []
    with path.open(newline="") as stream:
        for row in csv.DictReader(stream, delimiter="\t"):
            commands.append(
                {
                    "index": int(row["cmd_index"]),
                    "start_id": int(row["start_id"]),
                    "end_id": int(row["end_id"]),
                    "elf": str(localize_path(row["elf"], repo_root)),
                    "command": row["command"],
                }
            )
    commands.sort(key=lambda item: item["index"])
    return commands


def command_for_block(block_id, commands):
    for command in commands:
        if command["start_id"] <= block_id <= command["end_id"]:
            return command["index"]
    return None


def analyze_bbv(path, commands, selected_intervals, interval_length):
    selected = set(selected_intervals)
    local_intervals = defaultdict(int)
    regions = {}
    line_count = 0

    with path.open() as stream:
        for line in stream:
            if not line.startswith("T"):
                continue
            interval_index = line_count
            first = BBV_PAIR.search(line)
            primary = command_for_block(int(first.group(1)), commands) if first else None
            if primary is not None:
                local_interval = local_intervals[primary]
                local_start = local_interval * interval_length
            else:
                primary = None
                local_interval = None
                local_start = None

            if interval_index in selected:
                totals = defaultdict(int)
                unknown = 0
                for block, count in BBV_PAIR.findall(line):
                    count = int(count)
                    command = command_for_block(int(block), commands)
                    if command is None:
                        unknown += count
                    else:
                        totals[command] += count
                if totals:
                    primary = max(totals, key=totals.get)
                    local_interval = local_intervals[primary]
                    local_start = local_interval * interval_length
                regions[interval_index] = {
                    "command_index": primary,
                    "command_interval": local_interval,
                    "command_instruction_start": local_start,
                    "vector_instruction_count": sum(totals.values()) + unknown,
                    "command_instruction_counts": {
                        str(key): value for key, value in sorted(totals.items())
                    },
                    "unknown_instruction_count": unknown,
                    "mixed_commands": len(totals) > 1,
                }

            if primary is not None:
                local_intervals[primary] += 1
            line_count += 1

    return regions, line_count


def expected_benches(repo_root, suite):
    maps = []
    if suite in ("rate", "all"):
        maps.append(repo_root / "spec_flow/spec2017_kernel_map.json")
    if suite in ("speed", "all"):
        maps.append(repo_root / "spec_flow/spec2017_speed_kernel_map.json")
    benches = []
    for path in maps:
        data = json.loads(path.read_text())
        benches.extend(row["bench"] for row in data["benchmarks"])
    return benches


def build_benchmark_plan(
    manifest_path, repo_root, warmup_instructions, qemu_seed
):
    manifest = json.loads(manifest_path.read_text())
    bench = manifest["bench"]
    interval_length = int(manifest["interval"])
    source_files = manifest["files"]
    bbv = localize_path(source_files["bbv"], repo_root)
    cmdmap = localize_path(source_files["bbv_cmdmap"], repo_root)
    issues = []

    validation = manifest.get("validation", {})
    if not validation.get("compare_pass"):
        issues.append("SPEC compare did not pass")
    if not validation.get("simpoint_done"):
        issues.append("SimPoint output is incomplete")
    if not manifest.get("collection", {}).get("full_program"):
        issues.append("BBV collection is not a full-program run")
    if bench in ("500.perlbench_r", "600.perlbench_s"):
        issues.append("forked-process checkpoint identity is not implemented")
    for label, path in (("bbv", bbv), ("cmdmap", cmdmap)):
        if not path.is_file():
            issues.append(f"missing {label}: {path}")

    simpoints = manifest.get("simpoints", [])
    weight_sum = sum(float(item["weight"]) for item in simpoints)
    if abs(weight_sum - 1.0) > 0.0001:
        issues.append(f"SimPoint weight sum is {weight_sum:.8f}, expected 1")

    commands = load_cmdmap(cmdmap, repo_root) if cmdmap.is_file() else []
    selected = [int(item["interval"]) for item in simpoints]
    bbv_regions, bbv_line_count = (
        analyze_bbv(bbv, commands, selected, interval_length)
        if bbv.is_file()
        else ({}, 0)
    )

    command_by_index = {item["index"]: item for item in commands}
    regions = []
    for item in sorted(simpoints, key=lambda value: int(value["cluster"])):
        cluster = int(item["cluster"])
        interval = int(item["interval"])
        bbv_region = bbv_regions.get(interval)
        region_issues = []
        if bbv_region is None:
            region_issues.append("representative interval is absent from BBV")
            bbv_region = {
                "command_index": None,
                "command_interval": None,
                "command_instruction_start": None,
                "vector_instruction_count": 0,
                "command_instruction_counts": {},
                "unknown_instruction_count": 0,
                "mixed_commands": False,
            }
        command_index = bbv_region["command_index"]
        command = command_by_index.get(command_index)
        if command is None:
            region_issues.append("unable to bind representative interval to a command")
        elif not Path(command["elf"]).is_file():
            region_issues.append("command ELF is unavailable")
        if bbv_region["mixed_commands"]:
            region_issues.append("representative interval contains multiple commands")
        if bbv_region["unknown_instruction_count"]:
            region_issues.append("representative interval contains unmapped BBV blocks")

        local_start = bbv_region["command_instruction_start"]
        checkpoint_instruction = (
            max(0, local_start - warmup_instructions)
            if local_start is not None
            else None
        )
        effective_warmup = (
            local_start - checkpoint_instruction
            if local_start is not None
            else None
        )
        vector_count = bbv_region["vector_instruction_count"]
        boundary_skew = vector_count - interval_length
        if abs(boundary_skew) > 4096:
            region_issues.append(
                f"BBV interval instruction skew is unexpectedly large: {boundary_skew}"
            )

        region = {
            "checkpoint_id": f"{bench}.{manifest['size']}.cluster_{cluster}",
            "cluster": cluster,
            "simpoint_interval": interval,
            "weight": float(item["weight"]),
            "command_index": command_index,
            "command_interval": bbv_region["command_interval"],
            "command": command["command"] if command else None,
            "run_directory": str(Path(command["elf"]).parent) if command else None,
            "elf": command["elf"] if command else None,
            "elf_sha256": (
                sha256(Path(command["elf"]))
                if command and Path(command["elf"]).is_file()
                else None
            ),
            "checkpoint_instruction": checkpoint_instruction,
            "warmup_instructions": effective_warmup,
            "roi_start_instruction": local_start,
            "roi_instructions": interval_length,
            "bbv_vector_instructions": vector_count,
            "bbv_boundary_skew": boundary_skew,
            "qemu_seed": qemu_seed,
            "qemu_reserved_va": manifest.get("qemu_reserved_va"),
            "issues": region_issues,
            "ready_for_capture": not region_issues,
        }
        regions.append(region)

    return {
        "bench": bench,
        "size": manifest["size"],
        "interval_length": interval_length,
        "weight_sum": weight_sum,
        "manifest": str(manifest_path.resolve()),
        "manifest_sha256": sha256(manifest_path),
        "bbv": str(bbv),
        "bbv_cmdmap": str(cmdmap),
        "bbv_intervals": bbv_line_count,
        "commands": commands,
        "regions": regions,
        "issues": issues,
        "ready_for_capture": not issues and all(
            region["ready_for_capture"] for region in regions
        ),
    }


def write_report(plan, path):
    ready = sum(item["ready_for_capture"] for item in plan["benchmarks"])
    regions = sum(len(item["regions"]) for item in plan["benchmarks"])
    lines = [
        "# SPEC CPU2017 L3 Checkpoint Plan",
        "",
        f"- benchmark: {len(plan['benchmarks'])}/{plan['expected_benchmarks']}",
        f"- capture-ready benchmark: {ready}",
        f"- representative region: {regions}",
        f"- warmup target: {plan['warmup_instructions']:,} instructions",
        "- state: this plan freezes region coordinates; it is not a checkpoint itself",
        "",
        "| benchmark | regions | weight sum | commands | capture-ready | issues |",
        "|---|---:|---:|---:|---|---|",
    ]
    for item in plan["benchmarks"]:
        issues = list(item["issues"])
        issues.extend(
            f"cluster {region['cluster']}: {issue}"
            for region in item["regions"]
            for issue in region["issues"]
        )
        lines.append(
            f"| `{item['bench']}` | {len(item['regions'])} | "
            f"{item['weight_sum']:.7f} | {len(item['commands'])} | "
            f"{'yes' if item['ready_for_capture'] else 'no'} | "
            f"{'<br>'.join(issues)} |"
        )
    if plan["missing_benchmarks"]:
        lines.extend(
            ["", "## Missing Benchmarks", ""]
            + [f"- `{bench}`" for bench in plan["missing_benchmarks"]]
        )
    path.write_text("\n".join(lines) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("--suite", choices=("rate", "speed", "all"), default="all")
    parser.add_argument("--size", default="ref")
    parser.add_argument("--bench", action="append")
    parser.add_argument("--warmup-instructions", type=int, default=10_000_000)
    parser.add_argument("--qemu-seed", type=int, default=1)
    parser.add_argument("--allow-partial", action="store_true")
    parser.add_argument("--out", default="spec_checkpoints/l3_plan.json")
    parser.add_argument("--report", default="spec_checkpoints/L3_CHECKPOINT_PLAN.md")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    spec_runs = Path(args.spec_runs).resolve()
    benches = args.bench or expected_benches(repo_root, args.suite)
    benchmark_plans = []
    missing = []
    for bench in benches:
        manifest = spec_runs / f"{bench}_{args.size}_c910/manifest.json"
        if not manifest.is_file():
            missing.append(bench)
            continue
        benchmark_plans.append(
            build_benchmark_plan(
                manifest, repo_root, args.warmup_instructions, args.qemu_seed
            )
        )

    plan = {
        "format": FORMAT,
        "suite": args.suite,
        "size": args.size,
        "expected_benchmarks": len(benches),
        "missing_benchmarks": missing,
        "warmup_instructions": args.warmup_instructions,
        "qemu_seed": args.qemu_seed,
        "capture_backend": "qemu-user architectural checkpoint (not yet captured)",
        "benchmarks": benchmark_plans,
    }
    out = Path(args.out)
    report = Path(args.report)
    out.parent.mkdir(parents=True, exist_ok=True)
    report.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(plan, indent=2) + "\n")
    write_report(plan, report)

    ready = sum(item["ready_for_capture"] for item in benchmark_plans)
    print(f"plan={out}")
    print(f"report={report}")
    print(f"benchmarks={len(benchmark_plans)}/{len(benches)} ready={ready}")
    if (missing or ready != len(benchmark_plans)) and not args.allow_partial:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
