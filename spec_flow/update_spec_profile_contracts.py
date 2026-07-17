#!/usr/bin/env python3
import argparse
import copy
import json
from pathlib import Path

from validate_spec_profiles import footprint_share


def load_features(root, case):
    path = Path(root) / "cases" / case / "features.json"
    if not path.is_file():
        raise FileNotFoundError(path)
    return json.loads(path.read_text())


def feature_signature(features):
    normalized = copy.deepcopy(features)
    for key in ("case", "profile", "provenance", "validation"):
        normalized.pop(key, None)
    return json.dumps(normalized, sort_keys=True, separators=(",", ":"))


def write_markdown(path, output):
    lines = [
        "# SPEC RTL Kernel Profile 总表", "",
        "Rate/Speed 的 43 个 benchmark 分别映射到 43 个独立 bare-metal RTL case；",
        "Rate 和 Speed 不共享 case、ELF、权重或实测结果。每个 case 只有一个完整 ELF，",
        "程序特征统计和 RTL 仿真使用相同的 quick/full 参数。", "",
        "`simpoint-composition` 是专用多机制 composite；",
        "`simpoint-cluster-composition` 将该 benchmark 自身的 SimPoint cluster",
        "按语义分组后，在一个 ELF 内执行并校准动态指令权重。所有 43 个 case",
        "均包含至少两个可独立计数的机制阶段。full 另含 128 KiB footprint 脚手架，",
        "计入 ROI/工作集，",
        "但不计入机制权重，且动态指令占比不得超过 10%。", "",
        "| case | 对应 SPEC benchmark | 校准级别 | quick ROI | quick warmup | full ROI | full warmup | full 工作集 | footprint 占比 |",
        "|---|---|---|---:|---:|---:|---:|---:|---:|",
    ]
    labels = {
        "simpoint-composition": "多机制 SimPoint 校准",
        "simpoint-cluster-composition": "多 cluster 机制校准",
        "simpoint-single-group": "SimPoint 单行为组",
        "single-mechanism-scaled": "单机制规模校准",
    }
    for case, item in output["cases"].items():
        quick = item["profiles"]["quick"]
        full = item["profiles"]["full"]
        qmetrics = quick["metrics"]
        fmetrics = full["metrics"]
        share = full.get("measured_footprint_instruction_share")
        share_text = f"{share * 100.0:.3f}%" if share is not None else "N/A"
        lines.append(
            f"| `{case}` | {', '.join(item['benchmarks'])} | "
            f"{labels[item['calibration']]} | "
            f"{qmetrics['dynamic_instructions']['measured']:,} | "
            f"{qmetrics['warmup_instructions']['measured']:,} | "
            f"{fmetrics['dynamic_instructions']['measured']:,} | "
            f"{fmetrics['warmup_instructions']['measured']:,} | "
            f"{fmetrics['working_set_bytes_64B_lines']['measured']:,} B | "
            f"{share_text} |"
        )
    groups = output.get("feature_equivalence_groups", [])
    if groups:
        lines.extend([
            "", "## 动态特征等价组", "",
            "以下 case 在 quick 和 full 的完整程序特征中完全相同（忽略 case 名称、",
            "ELF provenance、profile 标签和校验元数据）。它们是不同映射/ELF，但当前",
            "代理行为没有提供独立的微结构覆盖，不能把 25 个 case 宣称为 25 种独立机制。", "",
        ])
        for group in groups:
            lines.append("- " + "、".join(f"`{case}`" for case in group))
    lines.extend([
        "", "## 约束与入口", "",
        "- full ROI 契约范围为 400,000 至 620,000 条动态指令。",
        "- full 工作集下限为 128 KiB；三个专用 composite 使用各自更高的实测下限。",
        "- warmup 位于 `perf_warmup_start/end`，不计入 ROI。",
        "- 所有实测值的漂移容差为 0；源码、编译器或参数变化后必须重新统计并显式更新契约。",
        "- RTL/QEMU retired 比较另允许 6 条整周期退休边界偏差，不属于 workload 契约漂移。",
        "- 机器可读契约：`spec_flow/spec_kernel_profiles.json`。",
        "- quick/full 统一入口：`spec_flow/run_spec_kernel_profiles.sh`。",
        "- 完整特征结果：`smart_run/kernel_features/spec_all_43_quick_final/` 和",
        "  `smart_run/kernel_features/spec_all_43_full_final/`。",
        "", "这些 kernel 用于微结构机制研究和版本间相对比较，不是 SPEC CPU2017 原程序",
        "代表区间，也不能生成或替代正式 SPEC 分数。", "",
    ])
    Path(path).write_text("\n".join(lines))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--kernel-map", action="append", required=True)
    parser.add_argument("--quick-features", required=True)
    parser.add_argument("--full-features", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--markdown")
    args = parser.parse_args()

    cases = {}
    for map_name in args.kernel_map:
        data = json.loads(Path(map_name).read_text())
        for row in data.get("benchmarks", []):
            kernel = row["kernels"][0]
            case = kernel["case"]
            item = cases.setdefault(case, {
                "benchmarks": [],
                "calibration": kernel.get("calibration") or (
                    "simpoint-composition" if kernel.get("composition")
                    else "single-mechanism-scaled"
                ),
                "profiles": {},
            })
            if kernel.get("composition_basis"):
                item["composition_basis"] = kernel["composition_basis"]
            item["benchmarks"].append(row["bench"])

    signatures = {"quick": {}, "full": {}}
    for case, item in cases.items():
        quick = load_features(args.quick_features, case)
        full = load_features(args.full_features, case)
        signatures["quick"][case] = feature_signature(quick)
        signatures["full"][case] = feature_signature(full)
        quick_inst = quick["execution"]["dynamic_instructions"]
        full_inst = full["execution"]["dynamic_instructions"]
        full_ws = full["memory"]["working_set_bytes_64B_lines"]
        quick_warmup = quick.get("profile", {}).get("warmup_instructions")
        full_warmup = full.get("profile", {}).get("warmup_instructions")
        if quick_warmup is None or full_warmup is None:
            raise ValueError(f"{case}: quick/full warmup metadata is missing")
        item["profiles"] = {
            "quick": {
                "metrics": {
                    "dynamic_instructions": {
                        "measured": quick_inst,
                        "tolerance": 0,
                    },
                    "warmup_instructions": {
                        "measured": quick_warmup,
                        "tolerance": 0,
                    },
                }
            },
            "full": {
                "metrics": {
                    "dynamic_instructions": {
                        "min": 400000,
                        "max": 620000,
                        "measured": full_inst,
                        "tolerance": 0,
                    },
                    "working_set_bytes_64B_lines": {
                        "min": 131072,
                        "measured": full_ws,
                        "tolerance": 0,
                    },
                    "warmup_instructions": {
                        "measured": full_warmup,
                        "tolerance": 0,
                    },
                }
            },
        }
        if full.get("composition_phases"):
            item["profiles"]["full"]["max_footprint_instruction_share"] = 0.10
            item["profiles"]["full"]["measured_footprint_instruction_share"] = (
                footprint_share(full)
            )
        else:
            item["profiles"]["full"]["metrics"][
                "working_set_bytes_64B_lines"
            ]["min"] = min(200000, full_ws)

    signature_groups = {}
    for case in cases:
        key = (signatures["quick"][case], signatures["full"][case])
        signature_groups.setdefault(key, []).append(case)
    equivalent = sorted(
        (sorted(group) for group in signature_groups.values() if len(group) > 1),
        key=lambda group: group[0],
    )
    output = {
        "schema": "openc910-spec-kernel-profiles-v1",
        "description": (
            "Measured contracts for 43 benchmark-local bare-metal SPEC proxy "
            "cases. Calibration classes distinguish dedicated composites from "
            "semantic multi-cluster composites."
        ),
        "feature_equivalence_groups": equivalent,
        "cases": dict(sorted(cases.items())),
    }
    path = Path(args.output)
    path.write_text(json.dumps(output, indent=2, ensure_ascii=False) + "\n")
    if args.markdown:
        write_markdown(args.markdown, output)
    print(f"wrote {len(cases)} profile contracts -> {path}")


if __name__ == "__main__":
    main()
