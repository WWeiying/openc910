#!/usr/bin/env python3
"""Join architectural workload features with RTL counters into a triage report."""

import argparse
import hashlib
import json
import re
from pathlib import Path

from compare_bench import parse_detail_perf


def get(data, path, default=0.0):
    value = data
    for key in path.split("."):
        if not isinstance(value, dict) or key not in value:
            return default
        value = value[key]
    return value


def mix(data, category):
    return get(data, f"instruction_mix.exclusive_categories.{category}.percent")


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_kernel_perf(path):
    if not path.exists():
        return {}
    text = path.read_text(errors="replace")
    result = {}
    match = re.search(
        r"\|\s*Kernel\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|"
        r"\s*([\d.]+|nan)\s*\|\s*([\d.]+|nan)\s*\|", text)
    if match:
        result.update({
            "cycles": float(match.group(1)), "instructions": float(match.group(2)),
            "cpi": float(match.group(3)), "ipc": float(match.group(4)),
        })
    marker = re.search(r"\|\s*Kernel Monitor\s*\|", text)
    chunk = text[marker.end():] if marker else ""
    labels = {
        "L1I Miss": "l1i_miss_pct", "L1D Load Miss": "l1d_load_miss_pct",
        "L1D Store Miss": "l1d_store_miss_pct",
        "Cond Branch Misp": "cond_misp_pct",
        "Indir Branch Misp": "indir_misp_pct",
        "Frontend Stall": "frontend_stall_pct",
        "Backend Stall": "backend_stall_pct",
    }
    for label, key in labels.items():
        row = re.search(
            rf"\|\s*{re.escape(label)}\s*\|\s*[-\d]+\s*\|\s*[-\d]*\s*\|"
            rf"\s*([\d.]+)%", chunk)
        if row:
            result[key] = float(row.group(1))
    return result


def detail_cycle(detail, name):
    return detail.get(f"{name}.cycle%", 0.0)


def add_candidate(candidates, name, score, evidence):
    candidates.append({"name": name, "score": max(score, 0.0), "evidence": evidence})


def analyze_case(features, perf, detail):
    program = {
        "integer": mix(features, "integer_compute"),
        "fp": mix(features, "fp_compute"),
        "memory": mix(features, "memory"),
        "control": mix(features, "control"),
        "branch_entropy": get(features, "control_flow.weighted_branch_entropy"),
        "bimodal": get(features, "control_flow.two_bit_bimodal_miss_proxy_percent"),
        "data_ws_kib": get(features, "memory.working_set_bytes_64B_lines") / 1024.0,
        "dcache32": get(features, "memory.fully_associative_miss_ratio_curve.32KiB"),
        "icache32": get(
            features, "code_locality.instruction_line_reuse_64B.miss_ratio_curve.32KiB"),
        "irregular": 100.0 * get(
            features, "memory.address_pattern_dynamic_accesses.irregular") /
        max(get(features, "memory.accesses"), 1),
        "prefetchable": get(
            features, "memory.prefetchable_sequential_or_fixed_stride_percent"),
        "load_use_le4": get(
            features, "dependencies_and_parallelism.load_use_distance.le4_percent"),
        "load_use_samples": get(
            features, "dependencies_and_parallelism.load_use_distance.samples"),
        "load_addr_dep": get(
            features, "dependencies_and_parallelism.load_address_depends_on_load_percent"),
        "ilp64": get(features, "dependencies_and_parallelism.window_ideal_ilp.64.mean"),
        "live_regs": get(
            features, "dependencies_and_parallelism.dynamic_register_liveness.p90_total"),
    }

    cpi_bad_spec = detail_cycle(detail, "cpi_stack_bad_spec")
    cpi_frontend = detail_cycle(detail, "cpi_stack_frontend")
    cpi_memory = detail_cycle(detail, "cpi_stack_memory")
    cpi_backend = detail_cycle(detail, "cpi_stack_backend_core")
    load_not_ready = detail_cycle(detail, "iq_load_dep_not_ready")
    nonload_not_ready = detail_cycle(detail, "iq_nonload_dep_not_ready")
    ready_not_issued = detail_cycle(detail, "iq_ready_not_issued")
    rob_full = max(detail_cycle(detail, "is_rob_full_stall"),
                   detail_cycle(detail, "rtu_rob_full"))
    iq_full = detail_cycle(detail, "is_iq_full_stall")
    retire_zero = max(detail_cycle(detail, "retire_width0_cycle"),
                      detail_cycle(detail, "rob_commit_width0_cycle"))

    candidates = []
    branch_score = (
        1.5 * perf.get("cond_misp_pct", 0.0) + cpi_bad_spec +
        0.10 * program["control"] + 0.10 * program["bimodal"])
    add_candidate(candidates, "分支预测与错误路径恢复", branch_score, [
        f"程序控制流 {program['control']:.2f}%，分支熵 {program['branch_entropy']:.3f}",
        f"2-bit 程序代理 {program['bimodal']:.2f}%，RTL 条件分支失误 {perf.get('cond_misp_pct', 0.0):.2f}%",
        f"CPI bad-spec {cpi_bad_spec:.2f}%",
    ])

    frontend_score = (
        perf.get("frontend_stall_pct", 0.0) + cpi_frontend +
        2.0 * perf.get("l1i_miss_pct", 0.0) + 0.15 * program["icache32"])
    add_candidate(candidates, "取指、I-cache 与前端供给", frontend_score, [
        f"程序 I$ 32KiB 容量代理 {program['icache32']:.2f}%",
        f"RTL L1I miss {perf.get('l1i_miss_pct', 0.0):.2f}%，frontend stall {perf.get('frontend_stall_pct', 0.0):.2f}%",
        f"CPI frontend {cpi_frontend:.2f}%",
    ])

    memory_weight = min(program["memory"] / 20.0, 1.0)
    memory_score = (
        cpi_memory + memory_weight * (
            1.5 * perf.get("l1d_load_miss_pct", 0.0) +
            perf.get("l1d_store_miss_pct", 0.0) +
            0.10 * program["memory"] + 0.05 * program["irregular"]))
    memory_note = (
        "程序容量代理低而 RTL 代价较高，优先检查组冲突、bank/端口、LSU 队列和流水化"
        if program["dcache32"] < 1.0 and memory_score >= 10.0 else
        "结合实际 miss、reuse、地址规则性和 LSU 队列继续区分容量与实现限制")
    add_candidate(candidates, "数据缓存、访存延迟与 LSU", memory_score, [
        f"程序访存 {program['memory']:.2f}%，工作集 {program['data_ws_kib']:.2f} KiB，D$32KiB 代理 {program['dcache32']:.2f}%",
        f"不规则地址 {program['irregular']:.2f}%，可预取代理 {program['prefetchable']:.2f}%",
        f"RTL L1D load/store miss {perf.get('l1d_load_miss_pct', 0.0):.2f}%/{perf.get('l1d_store_miss_pct', 0.0):.2f}%，CPI memory {cpi_memory:.2f}%",
        memory_note,
    ])

    load_sample_weight = min(program["load_use_samples"] / 100.0, 1.0)
    dependency_score = (
        cpi_backend + load_not_ready + nonload_not_ready +
        load_sample_weight * (0.08 * program["load_use_le4"] +
                              0.05 * program["load_addr_dep"]) -
        min(program["ilp64"], 8.0) * 0.25)
    add_candidate(candidates, "数据依赖、唤醒选择与执行端", dependency_score, [
        f"短 load-use {program['load_use_le4']:.2f}%，load 地址链依赖 {program['load_addr_dep']:.2f}%",
        f"理想 ILP64 {program['ilp64']:.2f}，活跃寄存器 P90 {program['live_regs']:.1f}",
        f"RTL load/nonload not-ready {load_not_ready:.2f}%/{nonload_not_ready:.2f}%，CPI backend-core {cpi_backend:.2f}%",
    ])

    capacity_score = rob_full + iq_full + ready_not_issued + 0.25 * retire_zero
    add_candidate(candidates, "ROB/IQ 容量、发射竞争与退休阻塞", capacity_score, [
        f"RTL ROB-full {rob_full:.2f}%，IQ-full {iq_full:.2f}%",
        f"ready-not-issued {ready_not_issued:.2f}%，retire-width0 {retire_zero:.2f}%",
        "队列满与 ready-not-issued 要结合占用率、源操作数和执行端口细分，不能直接相加",
    ])

    candidates.sort(key=lambda item: item["score"], reverse=True)
    return program, candidates


def report_case(case, features, perf, detail, profile, rtl_elf):
    program, candidates = analyze_case(features, perf, detail)
    rtl_inst = perf.get("instructions")
    trace_inst = get(features, "execution.dynamic_instructions", 0)
    feature_sha = get(features, "provenance.elf_sha256", "")
    rtl_sha = sha256(rtl_elf) if rtl_elf.exists() else ""
    if not rtl_sha:
        elf_alignment = "UNAVAILABLE"
    else:
        elf_alignment = "MATCH" if rtl_sha == feature_sha else "DIFFERENT"
    lines = [
        f"## `{case}`", "",
        "| 类别 | 核心指标 |", "|---|---|",
        f"| 程序构成 | 整数 {program['integer']:.2f}%，FP {program['fp']:.2f}%，访存 {program['memory']:.2f}%，控制流 {program['control']:.2f}% |",
        f"| 程序局部性 | D$32K 代理 {program['dcache32']:.2f}%，I$32K 代理 {program['icache32']:.2f}%，数据工作集 {program['data_ws_kib']:.2f} KiB |",
        f"| 程序依赖 | 短 load-use {program['load_use_le4']:.2f}%，地址链依赖 {program['load_addr_dep']:.2f}%，理想 ILP64 {program['ilp64']:.2f} |",
        f"| RTL | IPC {perf.get('ipc', 0.0):.3f}，frontend/backend stall {perf.get('frontend_stall_pct', 0.0):.2f}%/{perf.get('backend_stall_pct', 0.0):.2f}% |",
        f"| 对齐 | profile `{profile}`，ELF `{elf_alignment}`，trace/RTL retired {trace_inst:,}/{int(rtl_inst) if rtl_inst is not None else 'N/A'} |",
        "", "### 候选瓶颈优先级", "",
    ]
    for rank, item in enumerate(candidates[:3], 1):
        lines.append(f"{rank}. **{item['name']}**（筛查分数 {item['score']:.2f}）")
        for evidence in item["evidence"]:
            lines.append(f"   - {evidence}")
    lines.extend(["", "该排序用于安排后续核查，不是因果证明；不同 RTL 事件可能重叠。", ""])
    return lines


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--features-dir", type=Path, required=True)
    parser.add_argument("--out-md", type=Path, required=True)
    args = parser.parse_args()
    info = {}
    run_info = args.features_dir / "run.info"
    if run_info.exists():
        for line in run_info.read_text().splitlines():
            if "=" in line:
                key, value = line.split("=", 1)
                info[key] = value
    profile = info.get("profile", "unknown")
    feature_files = sorted((args.features_dir / "cases").glob("*/features.json"))
    lines = [
        "# 程序动态特征与 RTL 瓶颈联合筛查", "",
        f"特征 profile：`{profile}`。本报告把程序需求与 RTL 响应联合排序，"
        "筛查分数只用于决定深入分析顺序。`PERF_DETAIL` 未启用时仍可使用基础 RTL 指标，"
        "但依赖、队列、CPI stack 等候选依据会缺失。", "",
    ]
    completed = 0
    for path in feature_files:
        case = path.parent.name
        perf = parse_kernel_perf(args.results_dir / f"{case}.perf")
        if not perf:
            continue
        detail = parse_detail_perf(args.results_dir / f"{case}.detail.perf", "Kernel")
        features = json.loads(path.read_text())
        lines.extend(report_case(
            case, features, perf, detail, profile, args.results_dir / f"{case}.elf"))
        completed += 1
    if not completed:
        lines.append("没有找到同时具备程序特征和 RTL `.perf` 的 case。")
    args.out_md.write_text("\n".join(lines) + "\n")
    print(f"joint bottleneck report: {completed} cases -> {args.out_md}")
    return 0 if completed else 1


if __name__ == "__main__":
    raise SystemExit(main())
