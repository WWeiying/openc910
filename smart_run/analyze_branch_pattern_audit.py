#!/usr/bin/env python3
"""Audit branch-pattern sweep results for data integrity and pair completeness."""

from __future__ import annotations

import argparse
import csv
import json
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from run_branch_pattern_sweep import (
    RESULT_SCHEMA_VERSION,
    RunConfig,
    SweepError,
    parse_run_log,
)


@dataclass
class RunRecord:
    run_dir: Path
    run_id: str
    mode: str
    branches: int
    pattern: int
    repeat: int
    repeat_reason: str
    schema: int | str
    valid: bool
    warnings: list[str]
    failures: list[str]
    metrics: dict[str, Any]


def _load_json(path: Path) -> dict[str, Any] | None:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError, UnicodeDecodeError):
        return None


def _as_int(value: object, default: int | None = None) -> int | None:
    if value is None:
        return default
    if isinstance(value, bool):
        return int(value)
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _normalize_missing_counters(value: object) -> tuple[list[str], int]:
    if value is None:
        return [], 0
    if isinstance(value, int):
        return [f"<legacy-missing-detail-count={value}>"], value
    if isinstance(value, list):
        items = [str(item) for item in value]
        return items, len(items)
    return [], 0


def _validate_run(result: dict[str, Any], expected_schema: int | None) -> tuple[bool, list[str], list[str], dict[str, Any]]:
    """Return (valid, warnings, failures, normalized_metrics)."""

    warnings: list[str] = []
    failures: list[str] = []
    metrics: dict[str, Any] = {}

    try:
        mode = str(result.get("mode", ""))
        branches = _as_int(result.get("branches_in_loop"))
        pattern = _as_int(result.get("pattern_length"))
        repeat = _as_int(result.get("repeat"))
        warmup = _as_int(result.get("warmup_iterations", 0), 0)
        measure = _as_int(result.get("measure_iterations", 0), 0)
        seed = _as_int(result.get("seed"))
        target_executed = _as_int(result.get("target_executed_branches"), 0)
        target_mispred = _as_int(result.get("target_mispredictions"), 0)
        kernel_conditional = _as_int(result.get("kernel_conditional_branches"), 0)
        kernel_mispred = _as_int(result.get("kernel_bht_mispredictions"), 0)
        kernel_missing, kernel_missing_count = _normalize_missing_counters(
            result.get("kernel_missing_detail_counters")
        )
        start = _as_int(result.get("branch_region_start"))
        end = _as_int(result.get("branch_region_end"))
        text_sha = result.get("text_sha256")
    except Exception as error:  # pragma: no cover - defensive
        failures.append(f"failed to read core fields: {error}")
        return False, warnings, failures, {
            "branches": result.get("branches_in_loop"),
            "pattern": result.get("pattern_length"),
            "repeat": result.get("repeat"),
            "mode": result.get("mode"),
        }

    metrics.update(
        {
            "mode": mode,
            "branches": branches,
            "pattern": pattern,
            "repeat": repeat,
            "seed": seed,
            "warmup_iterations": warmup,
            "measure_iterations": measure,
            "target_executed": target_executed,
            "target_mispred": target_mispred,
            "kernel_conditional": kernel_conditional,
            "kernel_mispred": kernel_mispred,
            "kernel_cycle": _as_int(result.get("kernel_cycles")),
            "kernel_retired": _as_int(result.get("kernel_retired_instructions")),
            "kernel_detail_missing": kernel_missing,
            "kernel_detail_missing_count": kernel_missing_count,
            "text_sha256": text_sha,
            "start": start,
            "end": end,
            "schema": result.get("result_schema_version"),
            "run": result.get("run_id"),
            "simv_sha256": result.get("simv_sha256"),
            "benchmark_contract_sha256": result.get("benchmark_contract_sha256"),
        }
    )

    if mode not in {"predictable", "random"}:
        failures.append(f"unsupported mode {mode!r}")

    if branches is None or pattern is None or repeat is None:
        failures.append("non-integer branches/pattern/repeat")

    if measure is not None and warmup is not None and measure <= 0:
        failures.append(f"measure_iterations <= 0: {measure}")

    if branches is not None and measure is not None:
        expected = branches * measure
        if target_executed != expected:
            failures.append(
                f"target_executed_branches != branches*measure_iterations: "
                f"{target_executed} != {expected}"
            )

    if kernel_conditional is not None and kernel_conditional < 0:
        failures.append(f"negative kernel_conditional_branches: {kernel_conditional}")

    if target_mispred is not None and target_mispred < 0:
        failures.append(f"negative target_mispredictions: {target_mispred}")

    if kernel_conditional is not None and target_executed is not None:
        if target_executed > kernel_conditional:
            failures.append(
                "target_executed_branches > kernel_conditional_branches: "
                f"{target_executed} > {kernel_conditional}"
            )

    if target_mispred is not None and kernel_conditional is not None and target_mispred > kernel_conditional:
        failures.append(
            f"target_mispredictions > kernel_conditional_branches: "
            f"{target_mispred} > {kernel_conditional}"
        )

    if kernel_mispred is not None and target_mispred is not None and target_mispred > kernel_mispred:
        failures.append(
            f"target_mispredictions > kernel_bht_mispredictions: "
            f"{target_mispred} > {kernel_mispred}"
        )

    if _as_int(result.get("target_branch_sites"), 0) > (branches or 0):
        failures.append("target_branch_sites > configured branches")

    branch_class_fields = [
        "target_branch_call_mispred",
        "target_branch_return_mispred",
        "target_branch_other_mispred",
        "target_branch_unknown_mispred",
    ]
    class_sum = sum(_as_int(result.get(name), 0) for name in branch_class_fields)
    if target_mispred is not None and class_sum > target_mispred:
        failures.append(
            f"sum(branch-class mispredictions) > target_mispredictions: {class_sum} > {target_mispred}"
        )

    if kernel_missing_count > 0:
        warnings.append(
            "kernel_detail_counters missing optional events: "
            + ",".join(sorted(kernel_missing))
        )

    schema = _as_int(result.get("result_schema_version"))
    metrics["schema"] = schema
    if schema is None:
        failures.append("missing result_schema_version")
    elif expected_schema is not None and schema != expected_schema:
        warnings.append(f"schema mismatch: got {schema}, expected {expected_schema}")

    valid = len(failures) == 0
    return valid, warnings, failures, metrics


def _build_run_records(
    results_root: Path, expected_schema: int | None = None,
) -> tuple[list[RunRecord], Counter[str]]:
    runs: list[RunRecord] = []
    counters: Counter[str] = Counter()

    run_root = results_root / "runs"
    if not run_root.is_dir():
        raise SweepError(f"results directory is missing runs/: {run_root}")

    for run_dir in sorted(run_root.iterdir()):
        if not run_dir.is_dir():
            continue
        run_id = run_dir.name
        result_path = run_dir / "result.json"
        result = _load_json(result_path)
        if result is None:
            counters["missing_result_json"] += 1
            runs.append(
                RunRecord(
                    run_dir=run_dir,
                    run_id=run_id,
                    mode="<missing>",
                    branches=0,
                    pattern=0,
                    repeat=0,
                    repeat_reason="missing_result_json",
                    schema="<missing>",
                    valid=False,
                    warnings=[],
                    failures=["result.json missing or invalid"],
                    metrics={},
                )
            )
            continue

        mode = str(result.get("mode", ""))
        branches = _as_int(result.get("branches_in_loop"), 0)
        pattern = _as_int(result.get("pattern_length"), 0)
        repeat = _as_int(result.get("repeat"), 0)
        schema = result.get("result_schema_version")

        valid, warnings, failures, metrics = _validate_run(result, expected_schema)
        repeat_reason = "ok" if valid else "validation_fail"
        if failures:
            repeat_reason = "validation_fail"
        if not failures and warnings:
            repeat_reason = "warnings_only"

        run_record = RunRecord(
            run_dir=run_dir,
            run_id=run_id,
            mode=mode,
            branches=branches,
            pattern=pattern,
            repeat=repeat,
            repeat_reason=repeat_reason,
            schema=str(schema),
            valid=valid,
            warnings=warnings,
            failures=failures,
            metrics=metrics,
        )
        for failure in failures:
            counters[f"run_fail::{failure}"] += 1
        for warning in warnings:
            counters[f"run_warn::{warning}"] += 1
        counters["run_ok" if run_record.valid else "run_not_ok"] += 1
        runs.append(run_record)

    return runs, counters


def _build_pair_report(runs: list[RunRecord]) -> tuple[list[dict[str, Any]], Counter[str]]:
    grouped: dict[tuple[int, int, int], dict[str, RunRecord]] = {}
    for run in runs:
        key = (run.branches, run.pattern, run.repeat)
        bucket = grouped.setdefault(key, {})
        bucket[run.mode] = run

    rows: list[dict[str, Any]] = []
    counters: Counter[str] = Counter()
    for (branches, pattern, repeat), modes in sorted(grouped.items()):
        row: dict[str, Any] = {
            "branches_in_loop": branches,
            "pattern_length": pattern,
            "repeat": repeat,
            "available_modes": sorted(modes),
        }
        modeset = set(modes)

        if "predictable" not in modeset or "random" not in modeset:
            missing = sorted({"predictable", "random"} - modeset)
            status = "INCOMPLETE"
            row["status"] = status
            row["issues"] = f"missing_modes={missing}"
            row["delta_cycles"] = ""
            row["delta_cycles_per_branch"] = ""
            row["delta_mispred_rate_pct"] = ""
            counters[status] += 1
            rows.append(row)
            continue

        if len(modeset) != 2:
            status = "UNSUPPORTED_MODE_DUPLICATE"
            row["status"] = status
            row["issues"] = f"multiple_modes={sorted(modeset)}"
            row["delta_cycles"] = ""
            row["delta_cycles_per_branch"] = ""
            row["delta_mispred_rate_pct"] = ""
            counters[status] += 1
            rows.append(row)
            continue

        pred = modes["predictable"]
        rand = modes["random"]
        row["status"] = "OK"
        issues: list[str] = []

        if pred.metrics.get("seed") != rand.metrics.get("seed"):
            issues.append(
                f"seed mismatch: {pred.metrics.get('seed')} vs {rand.metrics.get('seed')}"
            )
        if pred.metrics.get("warmup_iterations") != rand.metrics.get("warmup_iterations"):
            issues.append(
                "warmup_iterations mismatch: "
                f"{pred.metrics.get('warmup_iterations')} vs "
                f"{rand.metrics.get('warmup_iterations')}"
            )
        if pred.metrics.get("measure_iterations") != rand.metrics.get("measure_iterations"):
            issues.append(
                "measure_iterations mismatch: "
                f"{pred.metrics.get('measure_iterations')} vs "
                f"{rand.metrics.get('measure_iterations')}"
            )
        if pred.metrics.get("simv_sha256") != rand.metrics.get("simv_sha256"):
            issues.append("simv_sha256 mismatch")
        if pred.metrics.get("benchmark_contract_sha256") != rand.metrics.get(
            "benchmark_contract_sha256"
        ):
            issues.append("benchmark_contract_sha256 mismatch")

        pred_missing = set(pred.metrics.get("kernel_detail_missing", []))
        rand_missing = set(rand.metrics.get("kernel_detail_missing", []))
        if pred_missing != rand_missing:
            issues.append(
                "optional detail counters mismatch: "
                f"predictable={sorted(pred_missing)}; random={sorted(rand_missing)}"
            )

        if pred.schema != rand.schema:
            issues.append(
                f"schema mismatch between modes: {pred.schema} vs {rand.schema}"
            )
        if pred.metrics.get("text_sha256") != rand.metrics.get("text_sha256"):
            issues.append("text_sha256 mismatch")

        pred_target = pred.metrics.get("target_executed")
        rand_target = rand.metrics.get("target_executed")
        if pred_target != rand_target:
            issues.append(
                "target_executed mismatch: "
                f"{pred_target} vs {rand_target}"
            )

        if pred.metrics.get("kernel_conditional") != rand.metrics.get("kernel_conditional"):
            issues.append(
                "kernel_conditional mismatch: "
                f"{pred.metrics.get('kernel_conditional')} vs "
                f"{rand.metrics.get('kernel_conditional')}"
            )

        status = None
        if not pred.valid:
            issues.append("predictable run invalid")
            status = "FAIL_PAIR"
        elif not rand.valid:
            issues.append("random run invalid")
            status = "FAIL_PAIR"

        if issues:
            status = status if status is not None else "WARN_PAIR"
            row["status"] = status

        for label, run in ("predictable", pred), ("random", rand):
            row[f"{label}_run_id"] = run.run_id
            row[f"{label}_schema"] = run.metrics.get("schema")
            row[f"{label}_target_mispred"] = run.metrics.get("target_mispred")
            row[f"{label}_kernel_cycles"] = run.metrics.get("kernel_cycle")
            row[f"{label}_kernel_conditional"] = run.metrics.get("kernel_conditional")

        pred_cycles = pred.metrics.get("kernel_cycle") or 0
        rand_cycles = rand.metrics.get("kernel_cycle") or 0
        pred_cond = pred.metrics.get("kernel_conditional") or 0
        rand_cond = rand.metrics.get("kernel_conditional") or 0
        pred_target = pred.metrics.get("target_executed") or 0
        rand_target = rand.metrics.get("target_executed") or 0
        row["delta_cycles"] = rand_cycles - pred_cycles
        row["delta_cycles_per_branch"] = (
            (rand_cycles / rand_target) - (pred_cycles / pred_target)
            if pred_target > 0 and rand_target > 0 else None
        )
        pred_misp = pred.metrics.get("kernel_mispred") or 0
        rand_misp = rand.metrics.get("kernel_mispred") or 0
        row["delta_mispred_rate_pct"] = (
            0.0 if pred_target == 0 else (100.0 * rand_misp / rand_target - 100.0 * pred_misp / pred_target)
        )

        row["issues"] = ";".join(issues)
        if not issues:
            status = "OK"
            row["status"] = status
            row["issues"] = ""
        if status not in {"OK"}:
            counters[status] += 1
        else:
            counters["OK"] += 1
        rows.append(row)

    return rows, counters


def _write_csv(path: Path, rows: list[dict[str, Any]]) -> None:
    if not rows:
        path.write_text("", encoding="utf-8")
        return
    fieldnames: list[str] = sorted({name for row in rows for name in row})
    with path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def _recheck_logs(results_root: Path, runs: list[RunRecord]) -> list[str]:
    notes: list[str] = []
    for run in runs:
        if not run.valid:
            continue
        if run.metrics.get("schema") != RESULT_SCHEMA_VERSION:
            continue
        result = _load_json(run.run_dir / "result.json")
        if not result:
            continue

        start = run.metrics.get("start")
        end = run.metrics.get("end")
        if not isinstance(start, int) or not isinstance(end, int):
            run.failures.append("missing branch_region_start/end in result")
            run.valid = False
            run.repeat_reason = "validation_fail"
            continue

        asm_path = run.run_dir / "bench_br_pattern.asm"
        if not asm_path.is_file():
            run.failures.append("bench_br_pattern.asm missing")
            run.valid = False
            run.repeat_reason = "validation_fail"
            continue

        log_path = run.run_dir / "run.vcs.log"
        if not log_path.is_file():
            run.failures.append("run.vcs.log missing")
            run.valid = False
            run.repeat_reason = "validation_fail"
            continue

        config = RunConfig(
            branches=run.branches,
            pattern_length=run.pattern,
            repeat=run.repeat,
            mode=run.mode,
            seed=run.metrics.get("seed", 0),
            warmup_iterations=run.metrics.get("warmup_iterations", 0),
            measure_iterations=run.metrics.get("measure_iterations", 0),
        )
        try:
            reparsed = parse_run_log(log_path, config, start, end, asm_path)
        except SweepError as error:
            run.failures.append(f"log_recheck_failed:{error}")
            run.valid = False
            run.repeat_reason = "validation_fail"
            continue

        if reparsed.get("target_mispredictions") != run.metrics.get("target_mispred", -1):
            run.warnings.append("log_recheck target_mispredictions mismatch")
            run.repeat_reason = "warnings_only"

        delta = {
            "target_branch_sites": run.metrics.get("target_branch_sites", 0),
            "kernel_conditional": run.metrics.get("kernel_conditional", 0),
        }
        if delta:
            notes.append(f"{run.run_id}: rechecked ok")
    return notes


def analyze(
    results_dir: Path,
    do_recheck: bool,
    output_dir: Path | None,
    *,
    strict: bool = False,
) -> int:
    run_info = _load_json(results_dir / "run_info.json") or {}
    expected_schema = run_info.get("result_schema_version")
    if isinstance(expected_schema, str):
        try:
            expected_schema = int(expected_schema)
        except ValueError:
            expected_schema = None
    expected_schema = _as_int(expected_schema)

    runs, run_counters = _build_run_records(results_dir, expected_schema)
    if do_recheck:
        _recheck_logs(results_dir, runs)

    pair_rows, pair_counters = _build_pair_report(runs)
    total_runs = len(runs)
    valid_runs = sum(1 for item in runs if item.valid)
    warning_runs = sum(1 for item in runs if item.valid and item.warnings and not item.failures)

    summary = {
        "results_dir": str(results_dir),
        "total_runs": total_runs,
        "valid_runs": valid_runs,
        "warning_only_runs": warning_runs,
        "invalid_runs": total_runs - valid_runs,
        "pair_total": len(pair_rows),
        "pair_ok": pair_counters.get("OK", 0),
        "pair_incomplete": pair_counters.get("INCOMPLETE", 0),
        "pair_fail": pair_counters.get("FAIL_PAIR", 0)
        + pair_counters.get("UNSUPPORTED_MODE_DUPLICATE", 0)
        + pair_counters.get("WARN_PAIR", 0),
        "pair_fail_or_incomplete": pair_counters.get("FAIL_PAIR", 0)
        + pair_counters.get("UNSUPPORTED_MODE_DUPLICATE", 0)
        + pair_counters.get("WARN_PAIR", 0)
        + pair_counters.get("INCOMPLETE", 0),
        "expected_schema": expected_schema,
        "run_info_schema": run_info.get("result_schema_version"),
        "run_reasons": run_counters,
        "pair_reasons": pair_counters,
    }
    pair_total = summary["pair_total"]
    summary["pair_ok_ratio"] = (
        round(100.0 * summary["pair_ok"] / pair_total, 4) if pair_total else 0.0
    )
    summary["pair_fail_or_incomplete_ratio"] = (
        round(100.0 * summary["pair_fail_or_incomplete"] / pair_total, 4)
        if pair_total
        else 0.0
    )

    top_issues = run_counters.most_common(12)

    print(f"=== branch-pattern audit: {results_dir}")
    print(f"total_runs={summary['total_runs']} valid={summary['valid_runs']} "
          f"warning_only={summary['warning_only_runs']} invalid={summary['invalid_runs']}")
    print(
        f"pairs: total={summary['pair_total']} ok={summary['pair_ok']} "
        f"incomplete={summary['pair_incomplete']} fail={summary['pair_fail']}"
    )
    if top_issues:
        print("run_failure_top:")
        for reason, count in top_issues:
            print(f"  {reason}: {count}")

    if output_dir is not None:
        output_dir = output_dir.expanduser().resolve()
        output_dir.mkdir(parents=True, exist_ok=True)
        run_rows = []
        for run in runs:
            run_rows.append(
                {
                    "run_id": run.run_id,
                    "status": "OK" if run.valid else "INVALID" if run.failures else "WARN",
                    "mode": run.mode,
                    "branches": run.branches,
                    "pattern": run.pattern,
                    "repeat": run.repeat,
                    "schema": run.schema,
                    "failures": "|".join(run.failures),
                    "warnings": "|".join(run.warnings),
                    "run_dir": str(run.run_dir),
                    "metrics": json.dumps(run.metrics, sort_keys=True, ensure_ascii=False),
                }
            )
        _write_csv(output_dir / "branch_pattern_run_audit.csv", run_rows)
        _write_csv(output_dir / "branch_pattern_pair_audit.csv", pair_rows)
        with (output_dir / "branch_pattern_audit_summary.json").open("w", encoding="utf-8") as stream:
            json.dump(
                {
                    "summary": summary,
                    "top_run_reasons": [{"reason": r, "count": c} for r, c in top_issues],
                },
                stream,
                indent=2,
                sort_keys=True,
            )
        print(f"outputs: {output_dir}")
    return 1 if summary["invalid_runs"] or (
        strict and summary["pair_fail_or_incomplete"]
    ) else 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="audit branch-pattern sweep results")
    parser.add_argument("results_dir", type=Path)
    parser.add_argument("--recheck-logs", action="store_true", help="reparse run.vcs.log for schema v4 runs")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="directory to write CSV/JSON audit outputs",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="exit non-zero when any invalid run/pair exists",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    code = analyze(args.results_dir, args.recheck_logs, args.output_dir, strict=args.strict)
    return code if args.strict else 0


if __name__ == "__main__":
    raise SystemExit(main())
