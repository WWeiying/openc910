#!/usr/bin/env python3
import argparse
import json
import math
import re
from pathlib import Path


PHASE_RE = re.compile(
    r"^\|\s*(Total|Main|Kernel)\s*\|\s*([0-9]+)\s*\|\s*([0-9]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|"
)
TABLE_RE = re.compile(
    r"^\|\s*([^|]+?)\s*\|\s*([0-9]+)\s*\|\s*([0-9]*)\s*\|\s*([0-9.]+)%?\s*\|"
)


KEY_METRICS = [
    "ALU",
    "Float Point",
    "Store",
    "LDST",
    "Cond Branch",
    "Indir Branch",
    "L1I Miss",
    "L1D Load Miss",
    "L1D Store Miss",
    "Cond Branch Misp",
    "Indir Branch Misp",
    "Frontend Stall",
    "Backend Stall",
    "RF Launch Fail",
    "LSU Cross 4K Stall",
]


def load_json(path):
    return json.loads(Path(path).read_text())


def parse_summary(path):
    phases = {}
    if not path.exists():
        return phases
    for line in path.read_text(errors="replace").splitlines():
        m = PHASE_RE.match(line)
        if not m:
            continue
        phase, cycles, inst, cpi, ipc = m.groups()
        phases[phase.lower()] = {
            "cycles": int(cycles),
            "inst": int(inst),
            "cpi": float(cpi),
            "ipc": float(ipc),
        }
    return phases


def parse_perf(path):
    current = None
    metrics = {}
    if not path.exists():
        return metrics

    for raw in path.read_text(errors="replace").splitlines():
        line = raw.strip()
        if "Kernel Inst" in line:
            current = "kernel_inst"
            continue
        if "Kernel Monitor" in line:
            current = "kernel_monitor"
            continue
        if "Main Inst" in line or "Main Monitor" in line:
            current = None
            continue
        if current is None:
            continue

        m = TABLE_RE.match(line)
        if not m:
            continue
        name, count, total, percent = m.groups()
        name = " ".join(name.split())
        if name not in KEY_METRICS:
            continue
        metrics[name] = {
            "count": int(count),
            "total": int(total) if total else None,
            "percent": float(percent),
        }
    return metrics


def manifest_for(spec_runs, bench, size):
    path = Path(spec_runs) / f"{bench}_{size}_c910" / "manifest.json"
    if path.exists():
        return load_json(path)
    return None


def component_result(rtl_results, case):
    root = Path(rtl_results)
    summary = parse_summary(root / f"{case}.summary.txt")
    perf = parse_perf(root / f"{case}.perf")
    report = root / f"{case}.run_case.report"
    passed = report.exists() and "TEST PASS" in report.read_text(errors="replace")
    kernel = summary.get("kernel")
    if not kernel:
        raise FileNotFoundError(f"missing Kernel phase in {root}/{case}.summary.txt")
    return {
        "case": case,
        "passed": passed,
        "kernel": kernel,
        "metrics": perf,
    }


def has_function_selectors(kernel):
    return bool(
        kernel.get("simpoint_functions")
        or kernel.get("simpoint_function_patterns")
    )


def function_matches_kernel(function, kernel):
    if function in set(kernel.get("simpoint_functions", [])):
        return True
    return any(
        re.search(pattern, function)
        for pattern in kernel.get("simpoint_function_patterns", [])
    )


def cluster_ids(kernel):
    ids = []
    for item in kernel.get("clusters", []):
        if isinstance(item, dict):
            ids.append(int(item["id"]))
        else:
            ids.append(int(item))
    return ids


def resolve_cluster_weights(row, manifest, verify_stored=False):
    if manifest is None:
        raise ValueError(f"{row['bench']}: manifest is required for cluster-derived weights")

    manifest_clusters = {}
    for item in manifest.get("simpoints", []):
        cluster = int(item["cluster"])
        if cluster in manifest_clusters:
            raise ValueError(f"{row['bench']}: manifest repeats cluster {cluster}")
        manifest_clusters[cluster] = item
    if not manifest_clusters:
        raise ValueError(f"{row['bench']}: manifest has no SimPoint clusters")

    assigned = {}
    raw_weights = []
    for kernel in row["kernels"]:
        selections = kernel.get("clusters", [])
        if not selections:
            raise ValueError(
                f"{row['bench']}: every cluster-mapped kernel must select at least one cluster"
            )
        raw_weight = 0.0
        for selection in selections:
            if isinstance(selection, dict):
                cluster = int(selection["id"])
                expected_interval = selection.get("interval")
            else:
                cluster = int(selection)
                expected_interval = None
            if cluster not in manifest_clusters:
                raise ValueError(f"{row['bench']}: unknown cluster {cluster}")
            if cluster in assigned:
                raise ValueError(
                    f"{row['bench']}: cluster {cluster} is assigned to both "
                    f"{assigned[cluster]} and {kernel['case']}"
                )
            actual_interval = int(manifest_clusters[cluster]["interval"])
            if expected_interval is not None and int(expected_interval) != actual_interval:
                raise ValueError(
                    f"{row['bench']}: cluster {cluster} representative interval changed "
                    f"from {expected_interval} to {actual_interval}; regroup the new profile"
                )
            assigned[cluster] = kernel["case"]
            raw_weight += float(manifest_clusters[cluster]["weight"])
        raw_weights.append(raw_weight)

    missing = sorted(set(manifest_clusters) - set(assigned))
    if missing:
        raise ValueError(
            f"{row['bench']}: unassigned SimPoint clusters: "
            + ",".join(str(cluster) for cluster in missing)
        )

    if verify_stored and all("weight" in kernel for kernel in row["kernels"]):
        total = sum(raw_weights)
        derived = [weight / total for weight in raw_weights]
        configured = [float(kernel["weight"]) for kernel in row["kernels"]]
        if any(abs(a - b) > 0.002 for a, b in zip(derived, configured)):
            raise ValueError(
                f"{row['bench']}: stored kernel weights do not match current cluster weights"
            )
    return raw_weights


def validate_embedded_composition(row, manifest, tolerance=0.005):
    kernels = row.get("kernels", [])
    if len(kernels) != 1 or not kernels[0].get("composition"):
        return None
    if manifest is None:
        raise ValueError(f"{row['bench']}: manifest is required for composite validation")

    cluster_weights = {
        int(item["cluster"]): float(item["weight"])
        for item in manifest.get("simpoints", [])
    }
    assigned = set()
    target_sum = 0.0
    measured_sum = 0.0
    groups = []
    for group in kernels[0]["composition"]:
        configured_clusters = group.get("clusters")
        legacy_clusters = group.get("source_clusters")
        if configured_clusters is not None and legacy_clusters is not None:
            if list(configured_clusters) != list(legacy_clusters):
                raise ValueError(
                    f"{row['bench']}: composite group {group['name']} has "
                    "conflicting clusters and source_clusters"
                )
        selections = (
            configured_clusters
            if configured_clusters is not None
            else legacy_clusters or []
        )
        clusters = [int(item) for item in selections]
        if not clusters:
            raise ValueError(f"{row['bench']}: composite group has no clusters")
        duplicate = assigned.intersection(clusters)
        if duplicate:
            raise ValueError(
                f"{row['bench']}: composite clusters repeated: "
                + ",".join(str(item) for item in sorted(duplicate))
            )
        unknown = sorted(set(clusters) - set(cluster_weights))
        if unknown:
            raise ValueError(
                f"{row['bench']}: composite references unknown clusters: "
                + ",".join(str(item) for item in unknown)
            )
        assigned.update(clusters)
        derived_target = sum(cluster_weights[item] for item in clusters)
        stored_target = float(group["target_weight"])
        measured_by_profile = group.get(
            "measured_instruction_share_by_profile", {}
        )
        if "full" in measured_by_profile:
            measured = float(measured_by_profile["full"])
            measured_profile = "full"
        elif "measured_instruction_share" in group:
            measured = float(group["measured_instruction_share"])
            measured_profile = "legacy"
        else:
            raise ValueError(
                f"{row['bench']}: {group['name']} has no full-profile "
                "measured instruction share"
            )
        if abs(derived_target - stored_target) > 0.002:
            raise ValueError(
                f"{row['bench']}: {group['name']} target weight is stale"
            )
        if abs(measured - derived_target) > tolerance:
            raise ValueError(
                f"{row['bench']}: {group['name']} measured instruction share "
                f"{measured:.7f} differs from target {derived_target:.7f}"
            )
        target_sum += stored_target
        measured_sum += measured
        groups.append({
            "name": group["name"],
            "target_weight": derived_target,
            "measured_instruction_share": measured,
            "measured_profile": measured_profile,
        })

    missing = sorted(set(cluster_weights) - assigned)
    if missing:
        raise ValueError(
            f"{row['bench']}: composite misses clusters: "
            + ",".join(str(item) for item in missing)
        )
    if abs(target_sum - 1.0) > 0.002 or abs(measured_sum - 1.0) > 0.002:
        raise ValueError(f"{row['bench']}: composite shares do not sum to one")
    return {"tolerance": tolerance, "groups": groups}


def resolve_kernel_weights(row, manifest, verify_stored=False):
    kernels = row["kernels"]
    cluster_weighted = [bool(kernel.get("clusters")) for kernel in kernels]
    function_weighted = [has_function_selectors(kernel) for kernel in kernels]
    if any(cluster_weighted):
        if not all(cluster_weighted):
            raise ValueError(
                f"{row['bench']}: either every kernel or no kernel must define clusters"
            )
        if any(function_weighted):
            raise ValueError(
                f"{row['bench']}: cluster selectors and function selectors cannot be mixed"
            )
        return (
            resolve_cluster_weights(row, manifest, verify_stored),
            "simpoint_cluster_groups",
        )
    if not any(function_weighted):
        if len(kernels) == 1:
            return [1.0], "single_proxy"
        return [float(kernel["weight"]) for kernel in kernels], "configured"
    if not all(function_weighted):
        raise ValueError(
            f"{row['bench']}: either every kernel or no kernel must define simpoint_functions"
        )
    if manifest is None:
        raise ValueError(f"{row['bench']}: manifest is required for SimPoint-derived weights")

    raw_weights = []
    for kernel in kernels:
        raw_weight = 0.0
        for simpoint in manifest.get("simpoints", []):
            function_share = sum(
                float(item["percent"]) / 100.0
                for item in simpoint.get("top_functions", [])
                if function_matches_kernel(item["function"], kernel)
            )
            raw_weight += float(simpoint["weight"]) * function_share
        raw_weights.append(raw_weight)

    if sum(raw_weights) <= 0:
        raise ValueError(f"{row['bench']}: SimPoint function groups matched no profile weight")
    if verify_stored and all("weight" in kernel for kernel in kernels):
        total = sum(raw_weights)
        derived = [weight / total for weight in raw_weights]
        configured = [float(kernel["weight"]) for kernel in kernels]
        if any(abs(a - b) > 0.002 for a, b in zip(derived, configured)):
            raise ValueError(
                f"{row['bench']}: stored kernel weights do not match current SimPoint mix"
            )
    return raw_weights, "simpoint_function_mix"


def weighted_benchmark(row, rtl_results, manifest, require_pass=False):
    comps = []
    raw_weights, weight_source = resolve_kernel_weights(
        row, manifest, verify_stored=True
    )
    total_weight = sum(raw_weights)
    if total_weight <= 0:
        raise ValueError(f"{row['bench']}: kernel weights must be positive")

    weighted_cpi = 0.0
    metric_sums = {name: 0.0 for name in KEY_METRICS}
    metric_seen = {name: False for name in KEY_METRICS}

    for kernel, raw_weight in zip(row["kernels"], raw_weights):
        weight = raw_weight / total_weight
        result = component_result(rtl_results, kernel["case"])
        if require_pass and not result["passed"]:
            raise RuntimeError(
                f"{row['bench']}: {kernel['case']} is missing a TEST PASS report"
            )
        cpi = result["kernel"]["cpi"]
        weighted_cpi += weight * cpi
        for name in KEY_METRICS:
            item = result["metrics"].get(name)
            if item is None:
                continue
            metric_sums[name] += weight * item["percent"]
            metric_seen[name] = True
        comps.append({
            "case": kernel["case"],
            "weight": weight,
            "raw_weight": raw_weight,
            "coverage": kernel.get("coverage", ""),
            "kernel_cpi": cpi,
            "kernel_ipc": result["kernel"]["ipc"],
            "passed": result["passed"],
        })

    metrics = {name: metric_sums[name] for name in KEY_METRICS if metric_seen[name]}
    composition = validate_embedded_composition(row, manifest)
    return {
        "bench": row["bench"],
        "suite": row["suite"],
        "coverage": ",".join(sorted({k.get("coverage", "") for k in row["kernels"] if k.get("coverage")})),
        "weight_source": weight_source,
        "mapping_complete": weight_source == "simpoint_cluster_groups",
        "composition_embedded": composition is not None,
        "composition": composition,
        "matched_profile_weight": total_weight if weight_source in {
            "simpoint_cluster_groups", "simpoint_function_mix"
        } else None,
        "weighted_kernel_cpi": weighted_cpi,
        "weighted_kernel_ipc": (1.0 / weighted_cpi) if weighted_cpi > 0 else 0.0,
        "components": comps,
        "metrics": metrics,
    }


def geomean(values):
    vals = [v for v in values if v > 0]
    if not vals:
        return 0.0
    return math.exp(sum(math.log(v) for v in vals) / len(vals))


def suite_summary(rows):
    out = {}
    for suite in sorted({r["suite"] for r in rows}):
        subset = [r for r in rows if r["suite"] == suite]
        out[suite] = {
            "count": len(subset),
            "cluster_grouped": sum(bool(r["mapping_complete"]) for r in subset),
            "geomean_ipc": geomean([r["weighted_kernel_ipc"] for r in subset]),
            "arithmean_ipc": sum(r["weighted_kernel_ipc"] for r in subset) / len(subset),
            "arithmean_cpi": sum(r["weighted_kernel_cpi"] for r in subset) / len(subset),
        }
    out["all"] = {
        "count": len(rows),
        "cluster_grouped": sum(bool(r["mapping_complete"]) for r in rows),
        "geomean_ipc": geomean([r["weighted_kernel_ipc"] for r in rows]),
        "arithmean_ipc": sum(r["weighted_kernel_ipc"] for r in rows) / len(rows),
        "arithmean_cpi": sum(r["weighted_kernel_cpi"] for r in rows) / len(rows),
    }
    return out


def manifest_status(manifest):
    if manifest is None:
        return "missing"
    validation = manifest.get("validation", {})
    compare = "pass" if validation.get("compare_pass") else "fail"
    simpoint = "done" if validation.get("simpoint_done") else "missing"
    counts = manifest.get("counts", {})
    intervals = counts.get("bbv_intervals", "")
    clusters = len(manifest.get("simpoints", []))
    return f"compare={compare}, simpoint={simpoint}, intervals={intervals}, clusters={clusters}"


def markdown_report(payload):
    lines = []
    lines.append(f"# SPEC CPU2017 {payload['size']} 指导的 RTL 代理结果")
    lines.append("")
    lines.append("本报告不是官方 SPEC CPU2017 分数，也不是精确的 SimPoint checkpoint RTL 结果。")
    lines.append("它将 QEMU SimPoint 画像与 bare-metal RTL representative kernel 结果组合，用于仓库内的体系结构研究。")
    lines.append("每个 benchmark 最终只对应一个 bare-metal ELF；如果存在多种机制，SimPoint cluster 权重会被校准为 composite 程序内部的动态指令份额。")
    lines.append("")
    lines.append("## 输入")
    lines.append("")
    lines.append(f"- SPEC 输入规模：`{payload['size']}`")
    lines.append(f"- SPEC 结果根目录：`{payload['spec_runs']}`")
    lines.append(f"- RTL 结果：`{payload['rtl_results']}`")
    lines.append(f"- Kernel 映射：`{payload['kernel_map']}`")
    lines.append("")
    lines.append("## 映射完成度")
    lines.append("")
    lines.append("| 套件 | benchmark 数 | 完成 cluster 混合校准 | 仍为未校准单代理 | 代理 IPC 几何平均 |")
    lines.append("|---|---:|---:|---:|---:|")
    for suite, item in payload["suite_summary"].items():
        lines.append(
            f"| `{suite}` | {item['count']} | {item['cluster_grouped']} | "
            f"{item['count'] - item['cluster_grouped']} | {item['geomean_ipc']:.3f} |"
        )
    lines.append("")
    lines.append("## Benchmark 明细")
    lines.append("")
    lines.append("| 套件 | benchmark | manifest | 覆盖度 | 映射层级 | RTL kernel | 代理 Kernel CPI | 代理 Kernel IPC | 前端停顿 % | 后端停顿 % | 条件分支误预测 % | L1D Load Miss % |")
    lines.append("|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|")
    for row in payload["benchmarks"]:
        metrics = row["metrics"]
        coverage = {"high": "高", "medium": "中", "low": "低"}.get(
            row["coverage"], row["coverage"]
        )
        kernels = "<br>".join(
            f"`{c['case']}` ({c['weight']:.3f}, IPC {c['kernel_ipc']:.3f})"
            for c in row["components"]
        )
        weight_source = row["weight_source"]
        if row["composition_embedded"]:
            weight_source = "单 composite kernel（cluster 混合已写入程序，不做仿真后加权）"
        elif weight_source == "simpoint_cluster_groups":
            weight_source = "SimPoint cluster 映射"
        elif weight_source == "simpoint_function_mix":
            weight_source = f"旧函数份额混合（非 cluster 映射，匹配 {row['matched_profile_weight'] * 100:.2f}%）"
        elif weight_source == "single_proxy":
            weight_source = "单代理 kernel（未做 cluster 加权）"
        else:
            weight_source = "手工组件权重（非 cluster 映射）"
        lines.append(
            f"| `{row['suite']}` | `{row['bench']}` | {row['manifest_status']} | {coverage} | "
            f"{weight_source} | "
            f"{kernels} | {row['weighted_kernel_cpi']:.3f} | {row['weighted_kernel_ipc']:.3f} | "
            f"{metrics.get('Frontend Stall', 0.0):.2f} | {metrics.get('Backend Stall', 0.0):.2f} | "
            f"{metrics.get('Cond Branch Misp', 0.0):.2f} | {metrics.get('L1D Load Miss', 0.0):.2f} |"
        )
    lines.append("")
    lines.append("## 解释规则")
    lines.append("")
    lines.append("- 代理 IPC 几何平均只是仓库内 representative kernel 的汇总指标，不是 SPEC ratio 或可发布的 SPEC 分数。")
    lines.append("- 单 composite kernel 把不同机制的动态指令份额在程序内部校准到 SimPoint cluster 权重；RTL 只跑一个 ELF，不再对子 kernel 结果做仿真后加权。")
    lines.append("- 单代理 kernel 的 CPI/IPC 只描述该代理程序，不是该 SPEC benchmark 的多 SimPoint 加权性能。")
    lines.append("- 覆盖度 `low/medium/high` 表示 bare-metal kernel 与 SPEC train 函数画像及主要机制的贴合程度。")
    lines.append("- 前端停顿和后端停顿来自可重叠的 RTL 事件，不应相加解释为总停顿比例。")
    lines.append("- 精确 SimPoint RTL 仍需要真实 SPEC 状态的 checkpoint/restore、warmup、详细区间执行和按权重汇总，这属于 L3。")
    lines.append("")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("--rtl-results", required=True)
    parser.add_argument("--kernel-map", default="spec_flow/spec2017_kernel_map.json")
    parser.add_argument(
        "--kernel-map-label",
        help="stable path recorded in reports when the input map is staged",
    )
    parser.add_argument("--size", default="test")
    parser.add_argument("--out-md", required=True)
    parser.add_argument("--out-json")
    parser.add_argument(
        "--require-pass",
        action="store_true",
        help="fail if any mapped RTL kernel lacks a TEST PASS report",
    )
    args = parser.parse_args()

    kernel_map = load_json(args.kernel_map)
    rows = []
    for bench in kernel_map["benchmarks"]:
        manifest = manifest_for(args.spec_runs, bench["bench"], args.size)
        item = weighted_benchmark(bench, args.rtl_results, manifest, args.require_pass)
        item["manifest_status"] = manifest_status(manifest)
        rows.append(item)

    payload = {
        "size": args.size,
        "spec_runs": args.spec_runs,
        "rtl_results": args.rtl_results,
        "kernel_map": args.kernel_map_label or args.kernel_map,
        "suite_summary": suite_summary(rows),
        "benchmarks": rows,
    }

    Path(args.out_md).write_text(markdown_report(payload))
    if args.out_json:
        Path(args.out_json).write_text(json.dumps(payload, indent=2) + "\n")
    print(f"[aggregate] wrote {args.out_md}")
    if args.out_json:
        print(f"[aggregate] wrote {args.out_json}")


if __name__ == "__main__":
    main()
