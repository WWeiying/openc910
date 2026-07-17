#!/usr/bin/env python3
"""Validate completeness and cross-field invariants of kernel feature reports."""

import argparse
import json
import math
from pathlib import Path


def get(data, path, default=None):
    value = data
    for key in path.split("."):
        if not isinstance(value, dict) or key not in value:
            return default
        value = value[key]
    return value


def check_finite(value, path, errors):
    if isinstance(value, dict):
        for key, child in value.items():
            check_finite(child, f"{path}.{key}", errors)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            check_finite(child, f"{path}[{index}]", errors)
    elif isinstance(value, float) and not math.isfinite(value):
        errors.append(f"{path}: non-finite value {value}")


def check_percentage(value, path, errors):
    if value is None or not 0.0 <= value <= 100.0:
        errors.append(f"{path}: expected percentage, got {value}")


def check_nonincreasing(curve, path, errors):
    values = list(curve.values()) if isinstance(curve, dict) else []
    for before, after in zip(values, values[1:]):
        if after > before + 1e-9:
            errors.append(f"{path}: miss ratio increases with capacity")
            break


def validate_case(data):
    errors = []
    required_groups = (
        "provenance", "validation", "execution", "instruction_mix",
        "control_flow", "code_locality", "memory",
        "dependencies_and_parallelism", "arithmetic_intensity", "hotspots",
        "phase_stability", "measurement_classes",
    )
    for group in required_groups:
        if group not in data:
            errors.append(f"missing group: {group}")
    if errors:
        return errors

    required_paths = (
        "control_flow.best_per_pc_static_miss_proxy_percent",
        "control_flow.two_bit_bimodal_miss_proxy_percent",
        "memory.unique_load_cache_lines_64B",
        "memory.unique_store_cache_lines_64B",
        "memory.unique_load_pages_4KiB",
        "memory.unique_store_pages_4KiB",
        "memory.unique_touched_bytes",
        "memory.address_span_bytes",
        "memory.prefetchable_sequential_or_fixed_stride_percent",
        "memory.page_reuse_and_fully_associative_tlb_curve.miss_ratio_curve",
    )
    for path in required_paths:
        if get(data, path) is None:
            errors.append(f"missing metric: {path}")

    check_finite(data, data.get("case", "case"), errors)
    total = get(data, "execution.dynamic_instructions", 0)
    categories = get(data, "instruction_mix.exclusive_categories", {})
    category_count = sum(item.get("count", 0) for item in categories.values())
    category_percent = sum(item.get("percent", 0.0) for item in categories.values())
    if total <= 0:
        errors.append("execution.dynamic_instructions: expected positive count")
    if category_count != total:
        errors.append(f"instruction category count {category_count} != {total}")
    if abs(category_percent - 100.0) > 1e-6:
        errors.append(f"instruction category percentages sum to {category_percent}")
    if not get(data, "validation.passed", False):
        errors.append("trace/ELF/RTL validation did not pass")

    memory = data["memory"]
    accesses = memory.get("accesses", 0)
    if memory.get("loads", 0) + memory.get("stores", 0) != accesses:
        errors.append("memory loads + stores != accesses")
    if sum(memory.get("address_pattern_dynamic_accesses", {}).values()) != accesses:
        errors.append("address-pattern counts do not cover all memory accesses")
    if sum(memory.get("address_region_dynamic_accesses", {}).values()) != accesses:
        errors.append("address-region counts do not cover all memory accesses")
    if memory.get("unique_touched_bytes", 0) > memory.get("working_set_bytes_64B_lines", 0):
        errors.append("unique touched bytes exceed line-rounded working set")
    for name in (
        "load_percent", "store_percent", "unaligned_percent",
        "cross_cache_line_percent", "cross_page_percent",
        "cache_line_byte_utilization_percent",
        "prefetchable_sequential_or_fixed_stride_percent",
    ):
        check_percentage(memory.get(name, 0.0), f"memory.{name}", errors)
    check_nonincreasing(memory.get("fully_associative_miss_ratio_curve", {}),
                        "memory cache curve", errors)
    check_nonincreasing(get(
        data, "memory.page_reuse_and_fully_associative_tlb_curve.miss_ratio_curve", {}),
        "memory TLB curve", errors)

    control = data["control_flow"]
    subtypes = control.get("subtypes", {})
    principal = sum(subtypes.get(name, 0) for name in (
        "conditional_branch", "direct_jump", "indirect_jump"))
    if principal != control.get("dynamic_control_instructions", 0):
        errors.append("control-flow principal subtype count mismatch")
    conditional = subtypes.get("conditional_branch", 0)
    directions = (subtypes.get("conditional_branch_forward", 0) +
                  subtypes.get("conditional_branch_backward", 0))
    if directions != conditional:
        errors.append(f"conditional branch directions {directions} != {conditional}")
    for name in (
        "conditional_taken_percent", "high_entropy_branch_dynamic_percent",
        "one_bit_transition_miss_proxy_percent",
        "best_per_pc_static_miss_proxy_percent",
        "two_bit_bimodal_miss_proxy_percent",
    ):
        check_percentage(control.get(name, 0.0), f"control_flow.{name}", errors)

    code_curve = get(
        data, "code_locality.instruction_line_reuse_64B.miss_ratio_curve", {})
    check_nonincreasing(code_curve, "instruction cache curve", errors)
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cases-dir", type=Path, required=True)
    parser.add_argument("--expected-case", action="append", default=[])
    parser.add_argument("--out-md", type=Path, required=True)
    args = parser.parse_args()

    files = sorted(args.cases_dir.glob("*/features.json"))
    reports = {}
    for path in files:
        data = json.loads(path.read_text())
        reports[data.get("case", path.parent.name)] = validate_case(data)
    missing = sorted(set(args.expected_case) - set(reports))
    extra = sorted(set(reports) - set(args.expected_case)) if args.expected_case else []
    passed = sum(not errors for errors in reports.values())
    failed = len(reports) - passed + len(missing)

    lines = [
        "# Kernel 特征校验", "",
        f"- 期望 case：{len(args.expected_case) if args.expected_case else len(reports)}",
        f"- 已生成：{len(reports)}",
        f"- 通过：{passed}",
        f"- 失败或缺失：{failed}", "",
        "| Case | 结果 | 说明 |", "|---|---|---|",
    ]
    for case in sorted(reports):
        errors = reports[case]
        lines.append(f"| `{case}` | {'FAIL' if errors else 'PASS'} | "
                     f"{'；'.join(errors) if errors else '全部不变量通过'} |")
    for case in missing:
        lines.append(f"| `{case}` | MISSING | 未生成 `features.json` |")
    for case in extra:
        lines.append(f"| `{case}` | EXTRA | 不在本次请求列表中 |")
    args.out_md.write_text("\n".join(lines) + "\n")
    print(f"validated {len(reports)} reports: {passed} passed, {failed} failed/missing")
    return 0 if failed == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
