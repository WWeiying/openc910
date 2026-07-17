#!/usr/bin/env python3
"""Aggregate real representative-region RTL counters with SimPoint weights."""

import argparse
import json
from collections import defaultdict
from pathlib import Path


FORMAT = "openc910-spec-l3-rtl-result-v1"
RATIOS = {
    "branch_mispredict_rate": ("branch_mispredicts", "branches"),
    "l1i_miss_rate": ("l1i_misses", "l1i_accesses"),
    "l1d_load_miss_rate": ("l1d_load_misses", "loads"),
    "l1d_store_miss_rate": ("l1d_store_misses", "stores"),
    "l2_miss_rate": ("l2_misses", "l2_accesses"),
}


def aggregate_benchmark(benchmark, result_root, require_all=True):
    samples = []
    missing = []
    for region in benchmark["regions"]:
        path = result_root / region["checkpoint_id"] / "rtl_result.json"
        if not path.is_file():
            missing.append(region["checkpoint_id"])
            continue
        result = json.loads(path.read_text())
        if result.get("format") != FORMAT:
            raise ValueError(f"{path}: unexpected result format")
        if result.get("checkpoint_id") != region["checkpoint_id"]:
            raise ValueError(f"{path}: checkpoint id mismatch")
        if result.get("status") != "pass":
            raise ValueError(f"{path}: RTL status is not pass")
        instructions = int(result["instructions"])
        cycles = int(result["cycles"])
        if instructions <= 0 or cycles <= 0:
            raise ValueError(f"{path}: invalid cycles/instructions")
        samples.append(
            {
                "checkpoint_id": region["checkpoint_id"],
                "cluster": region["cluster"],
                "weight": float(region["weight"]),
                "instructions": instructions,
                "cycles": cycles,
                "events": {key: int(value) for key, value in result.get("events", {}).items()},
            }
        )
    if require_all and missing:
        raise ValueError(f"{benchmark['bench']}: missing results: {','.join(missing)}")
    if not samples:
        return None

    covered_weight = sum(item["weight"] for item in samples)
    event_per_instruction = defaultdict(float)
    cpi = 0.0
    for sample in samples:
        normalized_weight = sample["weight"] / covered_weight
        cpi += normalized_weight * sample["cycles"] / sample["instructions"]
        for event, count in sample["events"].items():
            event_per_instruction[event] += normalized_weight * count / sample["instructions"]

    events = {
        name: {
            "per_instruction": value,
            "mpki": value * 1000.0,
        }
        for name, value in sorted(event_per_instruction.items())
    }
    ratios = {}
    for name, (numerator, denominator) in RATIOS.items():
        if denominator in event_per_instruction and event_per_instruction[denominator] > 0:
            ratios[name] = (
                event_per_instruction.get(numerator, 0.0)
                / event_per_instruction[denominator]
            )
    return {
        "bench": benchmark["bench"],
        "coverage_weight": covered_weight,
        "regions": samples,
        "cpi": cpi,
        "ipc": 1.0 / cpi,
        "events": events,
        "ratios": ratios,
        "missing": missing,
    }


def write_report(summary, path):
    lines = [
        "# SPEC CPU2017 L3 加权 RTL 结果",
        "",
        "CPI 是各代表区间 CPI 的 SimPoint 权重算术平均；IPC 按 `1/CPI` 计算，不直接平均各区间 IPC。",
        "",
        "| benchmark | 区间数 | 权重覆盖 | CPI | IPC | 分支错误 MPKI | L1D load miss MPKI |",
        "|---|---:|---:|---:|---:|---:|---:|",
    ]
    for item in summary["benchmarks"]:
        event = item["events"]
        lines.append(
            f"| `{item['bench']}` | {len(item['regions'])} | "
            f"{item['coverage_weight']:.7f} | {item['cpi']:.6f} | "
            f"{item['ipc']:.6f} | "
            f"{event.get('branch_mispredicts', {}).get('mpki', 0.0):.4f} | "
            f"{event.get('l1d_load_misses', {}).get('mpki', 0.0):.4f} |"
        )
    if summary.get("excluded_benchmarks"):
        lines.extend(
            [
                "",
                "## 排除的 Benchmark",
                "",
                "以下 benchmark 在冻结计划中被标记为不可捕获，因此不进入加权结果。",
                "",
                "| benchmark | 原因 |",
                "|---|---|",
            ]
        )
        for item in summary["excluded_benchmarks"]:
            lines.append(
                f"| `{item['bench']}` | {'; '.join(item.get('issues', []))} |"
            )
    path.write_text("\n".join(lines) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", required=True)
    parser.add_argument("--rtl-results", required=True)
    parser.add_argument("--allow-partial", action="store_true")
    parser.add_argument("--out-json", required=True)
    parser.add_argument("--out-md", required=True)
    args = parser.parse_args()

    plan = json.loads(Path(args.plan).read_text())
    result_root = Path(args.rtl_results)
    benchmarks = []
    excluded = []
    for benchmark in plan["benchmarks"]:
        if not benchmark.get("ready_for_capture", True):
            excluded.append(
                {"bench": benchmark["bench"], "issues": benchmark.get("issues", [])}
            )
            continue
        result = aggregate_benchmark(
            benchmark, result_root, require_all=not args.allow_partial
        )
        if result:
            benchmarks.append(result)
    summary = {
        "format": "openc910-spec-l3-weighted-summary-v1",
        "plan": str(Path(args.plan).resolve()),
        "benchmarks": benchmarks,
        "excluded_benchmarks": excluded,
    }
    out_json = Path(args.out_json)
    out_md = Path(args.out_md)
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_md.parent.mkdir(parents=True, exist_ok=True)
    out_json.write_text(json.dumps(summary, indent=2) + "\n")
    write_report(summary, out_md)
    print(f"benchmarks={len(benchmarks)}")
    print(f"json={out_json}")
    print(f"report={out_md}")


if __name__ == "__main__":
    main()
