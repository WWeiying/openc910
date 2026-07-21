#!/usr/bin/env python3
"""Generate concise, evidence-bound overview documents for SPEC2017 L2+."""

from __future__ import annotations

import argparse
import json
import math
import re
from dataclasses import dataclass
from pathlib import Path


EXPECTED = {"Rate": 23, "Speed": 20}
EXPECTED_CASES = 43
MAX_COMPOSITION_ERROR = 0.005


@dataclass(frozen=True)
class MappingRow:
    suite: str
    benchmark: str
    case: str
    source_profile: str
    cluster_count: int
    group_mix: str
    quick_error_pp: float
    full_error_pp: float
    quick_instructions: int
    full_instructions: int
    full_working_set: int


def load_json(path: Path) -> dict:
    return json.loads(path.read_text())


def read_key_value_file(path: Path) -> dict[str, str]:
    values = {}
    for line in path.read_text(errors="replace").splitlines():
        key, separator, value = line.partition("=")
        if separator:
            values[key] = value
    return values


def metric_measured(contract: dict, profile: str, metric: str) -> int:
    try:
        value = contract["profiles"][profile]["metrics"][metric]["measured"]
    except KeyError as exc:
        raise ValueError(
            f"missing {profile}.{metric} contract measurement"
        ) from exc
    if not isinstance(value, int) or value <= 0:
        raise ValueError(
            f"invalid {profile}.{metric} contract measurement: {value!r}"
        )
    return value


def composition_error(group: dict, profile: str) -> float:
    try:
        target = float(group["target_weight"])
        measured = float(group["measured_instruction_share_by_profile"][profile])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError(
            f"{group.get('name', '<unnamed>')}: missing {profile} composition result"
        ) from exc
    return abs(measured - target)


def collect_mapping_rows(
    rate_map: dict,
    speed_map: dict,
    profiles: dict,
) -> list[MappingRow]:
    contracts = profiles.get("cases")
    if not isinstance(contracts, dict):
        raise ValueError("profile contracts must contain an object named cases")

    rows = []
    benchmarks = set()
    cases = set()
    for suite, mapping in (("Rate", rate_map), ("Speed", speed_map)):
        map_rows = mapping.get("benchmarks", [])
        if len(map_rows) != EXPECTED[suite]:
            raise ValueError(
                f"{suite}: expected {EXPECTED[suite]} benchmarks, got {len(map_rows)}"
            )
        if mapping.get("calibration_size") != "ref":
            raise ValueError(
                f"{suite}: production overview requires calibration_size=ref"
            )

        for benchmark_row in map_rows:
            benchmark = benchmark_row.get("bench")
            kernels = benchmark_row.get("kernels", [])
            if not benchmark or benchmark in benchmarks:
                raise ValueError(f"duplicate or missing benchmark: {benchmark!r}")
            if len(kernels) != 1:
                raise ValueError(
                    f"{benchmark}: expected one composite kernel, got {len(kernels)}"
                )
            kernel = kernels[0]
            case = kernel.get("case")
            if not case or case in cases:
                raise ValueError(f"{benchmark}: duplicate or missing case {case!r}")
            if not math.isclose(float(kernel.get("weight", 0.0)), 1.0, abs_tol=1e-9):
                raise ValueError(f"{benchmark}: composite kernel weight must be 1")

            groups = kernel.get("composition", [])
            if len(groups) not in (2, 3):
                raise ValueError(
                    f"{benchmark}: expected 2 or 3 mechanism groups, got {len(groups)}"
                )
            cluster_ids = [int(item["id"]) for item in kernel.get("clusters", [])]
            grouped_ids = [
                int(cluster)
                for group in groups
                for cluster in group.get("clusters", [])
            ]
            if (
                not cluster_ids
                or len(grouped_ids) != len(set(grouped_ids))
                or set(grouped_ids) != set(cluster_ids)
            ):
                raise ValueError(
                    f"{benchmark}: mechanism groups do not partition all clusters"
                )
            target_sum = sum(float(group["target_weight"]) for group in groups)
            if not math.isclose(target_sum, 1.0, abs_tol=0.002):
                raise ValueError(
                    f"{benchmark}: composition target sum is {target_sum:.7f}"
                )

            quick_error = max(composition_error(group, "quick") for group in groups)
            full_error = max(composition_error(group, "full") for group in groups)
            for profile in ("quick", "full"):
                measured_sum = sum(
                    float(
                        group["measured_instruction_share_by_profile"][profile]
                    )
                    for group in groups
                )
                if not math.isclose(measured_sum, 1.0, abs_tol=0.002):
                    raise ValueError(
                        f"{benchmark}: {profile} composition sum is "
                        f"{measured_sum:.7f}"
                    )
            if max(quick_error, full_error) > MAX_COMPOSITION_ERROR:
                raise ValueError(
                    f"{benchmark}: composition error exceeds "
                    f"{100 * MAX_COMPOSITION_ERROR:.2f} percentage points"
                )

            source_profile = (
                kernel.get("composition_basis", {}).get("profile")
                or benchmark_row.get("calibration", {}).get("size")
            )
            if source_profile != "ref":
                raise ValueError(
                    f"{benchmark}: production composition is not ref-bound"
                )

            contract = contracts.get(case)
            if contract is None:
                raise ValueError(f"{benchmark}: missing profile contract for {case}")
            if contract.get("benchmarks") != [benchmark]:
                raise ValueError(
                    f"{case}: profile contract benchmark binding is inconsistent"
                )
            quick_instructions = metric_measured(
                contract, "quick", "dynamic_instructions"
            )
            full_instructions = metric_measured(
                contract, "full", "dynamic_instructions"
            )
            full_working_set = metric_measured(
                contract, "full", "working_set_bytes_64B_lines"
            )

            group_mix = "; ".join(
                f"{group['name']}={100.0 * float(group['target_weight']):.2f}%"
                for group in groups
            )
            rows.append(
                MappingRow(
                    suite=suite,
                    benchmark=benchmark,
                    case=case,
                    source_profile=source_profile,
                    cluster_count=len(cluster_ids),
                    group_mix=group_mix,
                    quick_error_pp=100.0 * quick_error,
                    full_error_pp=100.0 * full_error,
                    quick_instructions=quick_instructions,
                    full_instructions=full_instructions,
                    full_working_set=full_working_set,
                )
            )
            benchmarks.add(benchmark)
            cases.add(case)

    if len(rows) != EXPECTED_CASES or len(cases) != EXPECTED_CASES:
        raise ValueError(
            f"expected {EXPECTED_CASES} benchmark/case pairs, "
            f"got {len(rows)}/{len(cases)}"
        )
    if set(contracts) != cases:
        missing = sorted(cases - set(contracts))
        extra = sorted(set(contracts) - cases)
        raise ValueError(
            f"profile contract case set mismatch: missing={missing}, extra={extra}"
        )
    return rows


def validate_feature_root(
    root: Path,
    profile: str,
    commit: str,
    rows: list[MappingRow],
) -> None:
    info_path = root / "run.info"
    if not info_path.is_file():
        raise ValueError(f"{profile} feature run.info is missing: {info_path}")
    info = read_key_value_file(info_path)
    if info.get("git_commit") != commit or info.get("git_state") != "clean":
        raise ValueError(f"{profile} feature evidence is not from the clean RTL commit")
    if info.get("kernel_profile") != profile:
        raise ValueError(f"{profile} feature evidence has the wrong kernel profile")

    expected = {row.case: row for row in rows}
    case_root = root / "cases"
    actual = {
        path.parent.name
        for path in case_root.glob("*/features.json")
        if path.is_file()
    }
    if actual != set(expected):
        raise ValueError(
            f"{profile} feature case set mismatch: "
            f"missing={sorted(set(expected) - actual)}, "
            f"extra={sorted(actual - set(expected))}"
        )
    for case, row in expected.items():
        features = load_json(case_root / case / "features.json")
        if features.get("case") != case:
            raise ValueError(f"{case}: feature case identity mismatch")
        if features.get("profile", {}).get("kernel_profile") != profile:
            raise ValueError(f"{case}: feature profile identity mismatch")
        measured = features.get("execution", {}).get("dynamic_instructions")
        expected_instructions = (
            row.quick_instructions if profile == "quick" else row.full_instructions
        )
        if measured != expected_instructions:
            raise ValueError(
                f"{case}: {profile} feature instruction count does not match contract"
            )
        if profile == "full":
            working_set = features.get("memory", {}).get(
                "working_set_bytes_64B_lines"
            )
            if working_set != row.full_working_set:
                raise ValueError(
                    f"{case}: full feature working set does not match contract"
                )


def validate_final_evidence(
    rows: list[MappingRow],
    rtl_results: Path,
    quick_features: Path,
    full_features: Path,
    simpoint_status: Path,
    final_validation: Path,
) -> str:
    status_text = simpoint_status.read_text()
    if not re.search(r"总进度：129/129（100\.0%）", status_text):
        raise ValueError("strict SimPoint status is not 129/129")

    validation_text = final_validation.read_text()
    required_fragments = (
        "验收汇总：SimPoint=129/129",
        "错误=0。",
        "- Passed: 43/43",
        "- ELF/retired/detail passed: 43/43",
    )
    missing = [
        fragment for fragment in required_fragments if fragment not in validation_text
    ]
    if missing:
        raise ValueError(
            "final validation does not prove complete L2+: " + ", ".join(missing)
        )

    rtl_info_path = rtl_results / "run.info"
    if not rtl_info_path.is_file():
        raise ValueError(f"RTL run.info is missing: {rtl_info_path}")
    rtl_info = read_key_value_file(rtl_info_path)
    commit = rtl_info.get("git_commit", "")
    if not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ValueError("RTL evidence does not identify a full Git commit")
    required_info = {
        "git_dirty": "clean",
        "kernel_profile": "full",
        "composite_profile": "full",
        "program_features": "on",
        "perf_detail_compiled": "on",
    }
    for key, expected in required_info.items():
        if rtl_info.get(key) != expected:
            raise ValueError(f"RTL run.info requires {key}={expected}")

    expected_cases = {row.case for row in rows}
    reports = {
        path.name.removesuffix(".run_case.report"): path
        for path in rtl_results.glob("*.run_case.report")
    }
    if set(reports) != expected_cases:
        raise ValueError("RTL report case set is not exactly the 43 mapped cases")
    for case, report in reports.items():
        text = report.read_text(errors="replace")
        if "TEST PASS" not in text or "TEST FAIL" in text:
            raise ValueError(f"{case}: RTL report is not TEST PASS")

    validate_feature_root(quick_features, "quick", commit, rows)
    validate_feature_root(full_features, "full", commit, rows)
    return commit


def render_representative_document(
    rows: list[MappingRow],
    commit: str,
) -> str:
    quick_min = min(row.quick_instructions for row in rows)
    quick_max = max(row.quick_instructions for row in rows)
    full_min = min(row.full_instructions for row in rows)
    full_max = max(row.full_instructions for row in rows)
    working_set_min = min(row.full_working_set for row in rows)
    working_set_max = max(row.full_working_set for row in rows)
    quick_error = max(row.quick_error_pp for row in rows)
    full_error = max(row.full_error_pp for row in rows)

    lines = [
        "# SPEC CPU2017 L2+ Composite Kernel 映射",
        "",
        "> 本文档由 `generate_l2plus_overviews.py` 从最终映射、特征契约和 RTL "
        "证据生成。它只描述当前生产口径，不保留旧 split-kernel 历史。",
        "",
        "## 口径",
        "",
        "- 23 个 Rate 与 20 个 Speed benchmark 各有一个独立 bare-metal "
        "composite ELF，共 43 个 ELF；Rate/Speed 不共享 case。",
        "- 每个 ELF 包含 2–3 个机制 phase。ref SimPoint cluster 被完整且互斥地"
        "分配给这些 phase，cluster 权重校准为同一 ELF 内的动态指令份额。",
        "- quick 与 full 都运行完整 composite ELF；不存在分别运行子 kernel "
        "后再加权，也不存在真实 SPEC checkpoint/restore。",
        "- 这些结果是 SimPoint 指导的 SPEC-like RTL proxy，不是官方 SPEC "
        "CPU2017 分数，也不是原始 SPEC 二进制在 RTL 上的执行结果。",
        "",
        "## 总体约束",
        "",
        "| 项目 | 最终值 |",
        "|---|---:|",
        f"| benchmark / 唯一 case | {len(rows)} / {len({row.case for row in rows})} |",
        "| Rate / Speed | 23 / 20 |",
        "| 每项机制组 | 2–3 |",
        "| SimPoint 来源 | ref |",
        f"| quick 动态指令范围 | {quick_min:,}–{quick_max:,} |",
        f"| full 动态指令范围 | {full_min:,}–{full_max:,} |",
        f"| full 工作集范围 | {working_set_min:,}–{working_set_max:,} B |",
        f"| 最大 quick 配比绝对误差 | {quick_error:.4f} percentage points |",
        f"| 最大 full 配比绝对误差 | {full_error:.4f} percentage points |",
        f"| 证据 Git commit | `{commit}` |",
        "",
        "## 逐项映射",
        "",
        "| suite | benchmark | composite case | ref clusters | 机制目标动态指令份额 | "
        "quick 最大误差(pp) | full 最大误差(pp) | quick inst | full inst | "
        "full working set(B) |",
        "|---|---|---|---:|---|---:|---:|---:|---:|---:|",
    ]
    for row in rows:
        lines.append(
            f"| {row.suite} | `{row.benchmark}` | `{row.case}` | "
            f"{row.cluster_count} | {row.group_mix} | "
            f"{row.quick_error_pp:.4f} | {row.full_error_pp:.4f} | "
            f"{row.quick_instructions:,} | {row.full_instructions:,} | "
            f"{row.full_working_set:,} |"
        )
    lines.extend(
        [
            "",
            "## 审计入口",
            "",
            "- cluster、代表区间、函数热点与机制分组："
            "`SPEC_CLUSTER_COMPOSITIONS.md`",
            "- quick/full 指令数与工作集契约：`SPEC_KERNEL_PROFILES.md`",
            "- ref cluster 到 composite 的逐项映射："
            "`SPEC2017_RATE_REF_ALIGNMENT.md`、`SPEC2017_SPEED_REF_ALIGNMENT.md`",
            "- 实际 RTL 指标：`SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.md`、"
            "`SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.md`",
            "- 全部严格门禁：`SPEC2017_L2PLUS_FINAL_VALIDATION.md`",
        ]
    )
    return "\n".join(lines) + "\n"


def render_status_document(
    rows: list[MappingRow],
    commit: str,
    rtl_results_label: str,
    quick_features_label: str,
    full_features_label: str,
) -> str:
    return "\n".join(
        [
            "# SPEC CPU2017 SimPoint 与 RTL L2+ 状态",
            "",
            "> 本文档由 `generate_l2plus_overviews.py` 在全部严格门禁通过后生成。"
            "本文只报告当前最终状态。",
            "",
            "## 最终结论",
            "",
            "SPEC CPU2017 L2+ 已形成完整、可复现且绑定干净提交的证据链："
            "Rate/Speed 的 test、train、ref 共 129 个 SimPoint 组合全部通过；"
            "43 个 benchmark 分别映射到 43 个 ref 校准的 composite ELF；"
            "quick/full 动态特征和 full PERF_DETAIL RTL 仿真均为 43/43。",
            "",
            "| 门禁 | 结果 | 权威证据 |",
            "|---|---:|---|",
            "| SimPoint 严格矩阵 | 129/129 | `SPEC2017_L2PLUS_STATUS.md` |",
            "| Rate benchmark / case | 23/23 | `spec2017_kernel_map.json` |",
            "| Speed benchmark / case | 20/20 | `spec2017_speed_kernel_map.json` |",
            f"| 唯一 composite case | {len({row.case for row in rows})}/43 | "
            "`SPEC2017_REPRESENTATIVE_KERNELS.md` |",
            "| quick 程序特征 | 43/43 | "
            f"`{quick_features_label}` |",
            "| full 程序特征 | 43/43 | "
            f"`{full_features_label}` |",
            "| full RTL TEST PASS | 43/43 | "
            f"`{rtl_results_label}` |",
            "| ELF/退休指令/细粒度计数器一致性 | 43/43 | "
            "`SPEC2017_RTL_PROFILE_VALIDATION.md` |",
            "| 最终综合验收 | errors=0 | "
            "`SPEC2017_L2PLUS_FINAL_VALIDATION.md` |",
            f"| 证据 Git commit | `{commit}` | `run.info` |",
            "",
            "## 实际流程",
            "",
            "```text",
            "SPEC test/train/ref 全程序",
            "  -> QEMU 精确 TB 指令加权 BBV",
            "  -> SimPoint(maxK=5, interval=100M)",
            "  -> 代表区间函数画像",
            "  -> ref clusters 按机制语义完整分组",
            "  -> 每个 benchmark 构造一个 2–3 phase composite ELF",
            "  -> quick/full 动态指令份额校准",
            "  -> 同一 full ELF 先做程序特征统计，再做 C910 RTL PERF_DETAIL 仿真",
            "  -> 严格校验 ELF、退休指令、细粒度指标、Git 与工具产物 provenance",
            "```",
            "",
            "## 准确含义",
            "",
            "L2+ 保留了真实 SPEC ref SimPoint 的阶段权重和主要热点机制，并通过"
            "单一 composite ELF 让 RTL 仿真同时暴露这些机制；它适合比较同一 RTL "
            "不同微结构版本的相对变化、定位前端/发射/依赖/执行和存储层次瓶颈。",
            "",
            "L2+ 没有恢复原始 Linux SPEC 进程状态，不执行真实代表区间，也不能输出"
            "官方 SPEC 分数。只有完成 SPEC Linux checkpoint/restore、warmup、"
            "真实代表区间执行及按 SimPoint 权重汇总后，才属于 L3。",
            "",
            "## 权威文件",
            "",
            "- 当前映射和配比：`SPEC2017_REPRESENTATIVE_KERNELS.md`",
            "- cluster 与函数级来源：`SPEC_CLUSTER_COMPOSITIONS.md`",
            "- 程序规模契约：`SPEC_KERNEL_PROFILES.md`",
            "- Rate/Speed RTL 汇总：`SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.md`、"
            "`SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.md`",
            "- 最终验收：`SPEC2017_L2PLUS_FINAL_VALIDATION.md`",
        ]
    ) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--rate-map", required=True)
    parser.add_argument("--speed-map", required=True)
    parser.add_argument("--profiles", required=True)
    parser.add_argument("--rtl-results", required=True)
    parser.add_argument("--quick-features", required=True)
    parser.add_argument("--full-features", required=True)
    parser.add_argument("--simpoint-status", required=True)
    parser.add_argument("--final-validation", required=True)
    parser.add_argument("--representative-out", required=True)
    parser.add_argument("--status-out", required=True)
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()

    rows = collect_mapping_rows(
        load_json(Path(args.rate_map)),
        load_json(Path(args.speed_map)),
        load_json(Path(args.profiles)),
    )
    rtl_results = Path(args.rtl_results).resolve()
    quick_features = Path(args.quick_features).resolve()
    full_features = Path(args.full_features).resolve()
    repo_root = Path(args.repo_root).resolve()

    def display_path(path: Path) -> str:
        try:
            return path.relative_to(repo_root).as_posix()
        except ValueError:
            return path.as_posix()

    commit = validate_final_evidence(
        rows,
        rtl_results,
        quick_features,
        full_features,
        Path(args.simpoint_status),
        Path(args.final_validation),
    )

    Path(args.representative_out).write_text(
        render_representative_document(rows, commit)
    )
    Path(args.status_out).write_text(
        render_status_document(
            rows,
            commit,
            display_path(rtl_results),
            display_path(quick_features),
            display_path(full_features),
        )
    )
    print(
        f"[l2plus-overview] wrote 2 documents benchmarks={len(rows)} "
        f"cases={len({row.case for row in rows})} commit={commit}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
