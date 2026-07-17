#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


def selected_cluster_ids(kernel):
    return {
        int(item["id"] if isinstance(item, dict) else item)
        for item in kernel.get("clusters", [])
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--kernel-map", required=True)
    parser.add_argument("--size", default="ref")
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("--out", required=True)
    parser.add_argument("--top", type=int, default=6)
    args = parser.parse_args()

    kernel_map = json.loads(Path(args.kernel_map).read_text())
    lines = [
        f"# {args.size} SimPoint 与 RTL Kernel 对齐报告",
        "",
        f"- Kernel map：`{args.kernel_map}`",
        f"- Calibration state：`{kernel_map.get('calibration_size', 'unspecified')}`",
        f"- SPEC input：`{args.size}`",
        "",
        "| benchmark | cluster | interval | weight | assigned RTL kernel | mapping state | coverage | representative-interval top functions |",
        "|---|---:|---:|---:|---|---|---|---|",
    ]
    missing = 0
    clusters = 0
    for row in kernel_map.get("benchmarks", []):
        bench = row["bench"]
        manifest_path = (
            Path(args.spec_runs) / f"{bench}_{args.size}_c910" / "manifest.json"
        )
        kernels = row.get("kernels", [])
        assigned = {}
        for kernel in kernels:
            for cluster in selected_cluster_ids(kernel):
                assigned[cluster] = kernel
        grouped = bool(kernels) and all(kernel.get("clusters") for kernel in kernels)
        if not manifest_path.exists():
            missing += 1
            names = ", ".join(f"`{item['case']}`" for item in kernels)
            lines.append(
                f"| `{bench}` |  |  |  | {names} | unknown |  | **missing {args.size} manifest** |"
            )
            continue
        manifest = json.loads(manifest_path.read_text())
        for simpoint in sorted(
            manifest.get("simpoints", []), key=lambda item: item.get("cluster", 0)
        ):
            clusters += 1
            cluster = int(simpoint.get("cluster", -1))
            kernel = assigned.get(cluster)
            if kernel is not None:
                kernel_name = f"`{kernel['case']}`"
                state = (
                    "single composite; mix embedded"
                    if len(kernels) == 1 and kernel.get("composition")
                    else "cluster mechanism group"
                )
                coverage = kernel.get("coverage", "")
            elif len(kernels) == 1 and not grouped:
                kernel_name = f"`{kernels[0]['case']}`"
                state = "single proxy; not cluster-mapped"
                coverage = kernels[0].get("coverage", "")
            else:
                kernel_name = "**UNASSIGNED**"
                state = "invalid/incomplete"
                coverage = ""
            top = "; ".join(
                f"{item['function']} {float(item['percent']):.2f}%"
                for item in simpoint.get("top_functions", [])[: args.top]
            )
            lines.append(
                f"| `{bench}` | {cluster} | "
                f"{simpoint.get('interval', '')} | {float(simpoint.get('weight', 0.0)):.7f} | "
                f"{kernel_name} | {state} | {coverage} | {top} |"
            )
    lines.extend(
        [
            "",
            f"汇总：benchmark={len(kernel_map.get('benchmarks', []))}，"
            f"cluster={clusters}，missing manifest={missing}。",
            "",
            "`single composite; mix embedded` 表示该 benchmark 只跑一个 ELF，"
            "cluster 权重已用于校准程序内部的动态指令份额。"
            "`cluster mechanism group` 是仍保留多 kernel 的旧映射。"
            "`single proxy` 仅表示当前用一个综合代理 kernel 代表整个 benchmark，"
            "不构成多 SimPoint 加权性能。",
        ]
    )
    Path(args.out).write_text("\n".join(lines) + "\n")
    print(f"[alignment] wrote {args.out} missing={missing} clusters={clusters}")


if __name__ == "__main__":
    main()
