#!/usr/bin/env python3
"""Aggregate per-case kernel feature JSON into machine-readable and readable reports."""

import argparse
import csv
import json
from pathlib import Path


def get(data, path, default=0):
    value = data
    for key in path.split("."):
        if not isinstance(value, dict) or key not in value:
            return default
        value = value[key]
    return value


def mix(data, name):
    return get(data, f"instruction_mix.exclusive_categories.{name}.percent")


def dynamic_pattern_percent(data, name):
    count = get(data, f"memory.address_pattern_dynamic_accesses.{name}")
    total = get(data, "memory.accesses")
    return 100.0 * count / total if total else 0.0


def characterize(row):
    traits = []
    if row["control_pct"] >= 20:
        traits.append("控制流密集")
    elif row["control_pct"] <= 8:
        traits.append("低控制流密度")
    if row["branch_entropy"] >= 0.65:
        traits.append("分支结果高熵")
    elif row["conditional_branches"]:
        traits.append("分支结果规则")
    if row["memory_pct"] >= 35:
        traits.append("访存密集")
    if row["memory_pct"] >= 10:
        if row["irregular_mem_pct"] >= 30:
            traits.append("地址不规则")
        elif row["sequential_mem_pct"] + row["fixed_stride_mem_pct"] >= 70:
            traits.append("规则流式/步长访存")
    if row["fp_pct"] >= 15:
        traits.append("浮点计算密集")
    elif row["integer_pct"] >= 60:
        traits.append("整数计算密集")
    if row["load_use_le4_pct"] >= 40:
        traits.append("短 load-use 较多")
    if row["ilp64"] < 2.0:
        traits.append("潜在 ILP 较低")
    elif row["ilp64"] >= 4.0:
        traits.append("潜在 ILP 较高")
    if row["top_instruction_pct"] >= 15:
        traits.append("热点高度集中")
    return "、".join(traits) if traits else "混合型 kernel"


def flatten(data):
    control_total = get(data, "control_flow.dynamic_control_instructions")
    subtypes = get(data, "control_flow.subtypes", {})
    conditional = subtypes.get("conditional_branch", 0)
    conditional_backward = subtypes.get("conditional_branch_backward", 0)
    hotspots = get(data, "hotspots.instructions", [])
    row = {
        "case": data["case"],
        "kernel_profile": get(data, "profile.kernel_profile", None),
        "warmup_instructions": get(data, "profile.warmup_instructions", None),
        "validation": get(data, "validation.passed", False),
        "elf_sha256": get(data, "provenance.elf_sha256", ""),
        "dynamic_instructions": get(data, "execution.dynamic_instructions"),
        "static_executed_instructions": get(data, "execution.static_executed_instructions"),
        "static_code_bytes": get(data, "execution.static_executed_code_bytes"),
        "compressed_pct": get(data, "execution.compressed_dynamic_percent"),
        "integer_pct": mix(data, "integer_compute"),
        "fp_pct": mix(data, "fp_compute"),
        "vector_pct": mix(data, "vector_compute"),
        "memory_pct": mix(data, "memory"),
        "control_pct": mix(data, "control"),
        "system_other_pct": mix(data, "system") + mix(data, "other"),
        "loads": get(data, "memory.loads"),
        "stores": get(data, "memory.stores"),
        "load_pct_of_memory": get(data, "memory.load_percent"),
        "store_pct_of_memory": get(data, "memory.store_percent"),
        "memory_bytes_per_instruction": get(data, "memory.bytes_per_instruction"),
        "conditional_branches": conditional,
        "direct_jumps": subtypes.get("direct_jump", 0),
        "indirect_jumps": subtypes.get("indirect_jump", 0),
        "calls": subtypes.get("call", 0),
        "returns": subtypes.get("return", 0),
        "branches_per_kinst": 1000.0 * control_total /
        max(get(data, "execution.dynamic_instructions"), 1),
        "taken_pct": get(data, "control_flow.conditional_taken_percent"),
        "backward_pct": 100.0 * conditional_backward / conditional
        if conditional else 0.0,
        "branch_entropy": get(data, "control_flow.weighted_branch_entropy"),
        "high_entropy_branch_pct": get(data, "control_flow.high_entropy_branch_dynamic_percent"),
        "best_static_branch_miss_proxy_pct": get(
            data, "control_flow.best_per_pc_static_miss_proxy_percent"),
        "one_bit_branch_miss_proxy_pct": get(
            data, "control_flow.one_bit_transition_miss_proxy_percent"),
        "two_bit_bimodal_miss_proxy_pct": get(
            data, "control_flow.two_bit_bimodal_miss_proxy_percent"),
        "indirect_target_entropy": get(data, "control_flow.weighted_indirect_target_entropy"),
        "maximum_call_depth": get(data, "control_flow.call_depth.max"),
        "basic_block_mean": get(data, "control_flow.basic_block_length.mean"),
        "basic_block_p90": get(data, "control_flow.basic_block_length.p90"),
        "code_lines_64b": get(data, "execution.code_lines_64B"),
        "working_set_bytes": get(data, "memory.working_set_bytes_64B_lines"),
        "pages_4k": get(data, "memory.unique_pages_4KiB"),
        "load_lines_64b": get(data, "memory.unique_load_cache_lines_64B"),
        "store_lines_64b": get(data, "memory.unique_store_cache_lines_64B"),
        "load_pages_4k": get(data, "memory.unique_load_pages_4KiB"),
        "store_pages_4k": get(data, "memory.unique_store_pages_4KiB"),
        "unique_touched_bytes": get(data, "memory.unique_touched_bytes"),
        "address_span_bytes": get(data, "memory.address_span_bytes"),
        "line_utilization_pct": get(data, "memory.cache_line_byte_utilization_percent"),
        "unaligned_pct": get(data, "memory.unaligned_percent"),
        "cross_line_pct": get(data, "memory.cross_cache_line_percent"),
        "reuse_p50_lines": get(data, "memory.reuse_distance_lines.p50"),
        "reuse_p90_lines": get(data, "memory.reuse_distance_lines.p90"),
        "reuse_p99_lines": get(data, "memory.reuse_distance_lines.p99"),
        "fa_miss_ratio_32k_pct": get(data, "memory.fully_associative_miss_ratio_curve.32KiB"),
        "fa_miss_ratio_64k_pct": get(data, "memory.fully_associative_miss_ratio_curve.64KiB"),
        "sequential_mem_pct": dynamic_pattern_percent(data, "sequential"),
        "fixed_stride_mem_pct": dynamic_pattern_percent(data, "fixed_stride"),
        "multi_stride_mem_pct": dynamic_pattern_percent(data, "multi_stride"),
        "irregular_mem_pct": dynamic_pattern_percent(data, "irregular"),
        "prefetchable_mem_pct": get(
            data, "memory.prefetchable_sequential_or_fixed_stride_percent"),
        "fa_tlb_miss_ratio_32_pct": get(
            data, "memory.page_reuse_and_fully_associative_tlb_curve.miss_ratio_curve.32_entries"),
        "fa_tlb_miss_ratio_64_pct": get(
            data, "memory.page_reuse_and_fully_associative_tlb_curve.miss_ratio_curve.64_entries"),
        "dependency_p90": get(data, "dependencies_and_parallelism.register_dependency_distance.p90"),
        "load_use_p50": get(data, "dependencies_and_parallelism.load_use_distance.p50"),
        "load_use_p90": get(data, "dependencies_and_parallelism.load_use_distance.p90"),
        "load_use_le4_pct": get(data, "dependencies_and_parallelism.load_use_distance.le4_percent"),
        "load_address_depends_on_load_pct": get(
            data, "dependencies_and_parallelism.load_address_depends_on_load_percent"),
        "prior_store_same_address_load_pct": get(
            data, "dependencies_and_parallelism.load_with_prior_same_address_store_percent"),
        "ilp16": get(data, "dependencies_and_parallelism.window_ideal_ilp.16.mean"),
        "ilp32": get(data, "dependencies_and_parallelism.window_ideal_ilp.32.mean"),
        "ilp64": get(data, "dependencies_and_parallelism.window_ideal_ilp.64.mean"),
        "ilp128": get(data, "dependencies_and_parallelism.window_ideal_ilp.128.mean"),
        "loads_per_32_p90": get(
            data, "dependencies_and_parallelism.loads_per_32_instruction_window.p90"),
        "independent_loads_per_32_p90": get(
            data, "dependencies_and_parallelism.independent_loads_per_32_instruction_window.p90"),
        "live_registers_p90": get(
            data, "dependencies_and_parallelism.dynamic_register_liveness.p90_total"),
        "flops": get(data, "arithmetic_intensity.floating_point_operations"),
        "flops_per_byte": get(data, "arithmetic_intensity.flops_per_requested_byte", None),
        "integer_ops_per_byte": get(
            data, "arithmetic_intensity.integer_ops_per_requested_byte", None),
        "phase_memory_cv": get(
            data, "phase_stability.variation.memory_percent.coefficient_of_variation"),
        "phase_control_cv": get(
            data, "phase_stability.variation.control_percent.coefficient_of_variation"),
        "top_instruction_pct": hotspots[0]["percent"] if hotspots else 0.0,
    }
    row["conclusion"] = characterize(row)
    return row


def markdown(rows):
    lines = [
        "# Benchmark Kernel 动态程序特征汇总", "",
        "统计对象为每个 case 的 `perf_monitor_start` 至 `perf_monitor_end` 动态执行。",
        "数据来自功能模拟器中的架构态追踪；`rtl` profile 可与 RTL ELF 对齐，"
        "`representative` profile 使用更适合特征分析的运行规模。",
        "报告不包含 IPC、真实 cache miss、真实预测失败或流水线停顿。",
        "", "## 总表", "",
        "| Kernel | profile | warmup | 指令数 | 整数% | FP% | 访存% | 控制流% | 分支/KI | 分支熵 | 工作集 | ILP64 | 结论 |",
        "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|",
    ]
    for row in rows:
        lines.append(
            f"| `{row['case']}` | {row['kernel_profile'] or 'unknown'} | "
            f"{row['warmup_instructions'] if row['warmup_instructions'] is not None else 'N/A'} | "
            f"{row['dynamic_instructions']:,} | "
            f"{row['integer_pct']:.2f} | {row['fp_pct']:.2f} | "
            f"{row['memory_pct']:.2f} | {row['control_pct']:.2f} | "
            f"{row['branches_per_kinst']:.1f} | {row['branch_entropy']:.3f} | "
            f"{row['working_set_bytes']:,} B | {row['ilp64']:.2f} | {row['conclusion']} |"
        )
    lines.extend([
        "", "## 统计口径", "",
        "- 指令类别互斥，所有类别之和等于 Kernel 动态指令数。",
        "- 分支熵按静态 branch PC 分别计算，再按动态执行次数加权。",
        "- reuse distance、cache/TLB miss-ratio curve 使用全相联 LRU 容量模型，不含组相联冲突。",
        "- 静态、1-bit、2-bit 分支失误率是程序可预测性代理，不是 C910 实测失误率。",
        "- ILP 是无限执行资源、抽象操作延迟下的模型派生值，不是 C910 IPC。",
        "- 工作集、stride、依赖和热点均只覆盖 Kernel 标记区间。", "",
    ])
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases-dir", type=Path, required=True)
    parser.add_argument("--out-csv", type=Path, required=True)
    parser.add_argument("--out-json", type=Path, required=True)
    parser.add_argument("--out-md", type=Path, required=True)
    args = parser.parse_args()
    files = sorted(args.cases_dir.glob("*/features.json"))
    if not files:
        raise SystemExit(f"no features.json under {args.cases_dir}")
    payload = [json.loads(path.read_text()) for path in files]
    rows = [flatten(item) for item in payload]
    rows.sort(key=lambda row: row["case"])
    args.out_csv.parent.mkdir(parents=True, exist_ok=True)
    with args.out_csv.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    args.out_json.write_text(json.dumps({
        "schema_version": 1, "case_count": len(rows), "kernels": rows,
    }, indent=2, ensure_ascii=False) + "\n")
    args.out_md.write_text(markdown(rows))
    print(f"aggregated {len(rows)} kernels -> {args.out_md}")


if __name__ == "__main__":
    main()
