#!/usr/bin/env python3

import json
import tempfile
import unittest
from pathlib import Path

from analyze_branch_pattern_audit import analyze, _normalize_missing_counters


class AnalyzeLogicAuditTests(unittest.TestCase):
    @staticmethod
    def _base_run(mode: str, cycles: int, branches: int = 2, iterations: int = 3, seed: int = 2024) -> dict:
        executed = branches * iterations
        return {
            "run_id": f"run_{mode}",
            "mode": mode,
            "branches_in_loop": branches,
            "pattern_length": 4,
            "repeat": 1,
            "seed": seed,
            "warmup_iterations": 2,
            "measure_iterations": iterations,
            "target_executed_branches": executed,
            "target_mispredictions": 0,
            "kernel_bht_mispredictions": 0,
            "kernel_conditional_branches": executed,
            "kernel_cycles": cycles,
            "kernel_retired_instructions": 10000,
            "kernel_global_flushes": 0,
            "kernel_l1i_misses": 0,
            "kernel_detail_missing_counters": [],
            "target_branch_call_mispred": 0,
            "target_branch_return_mispred": 0,
            "target_branch_other_mispred": 0,
            "target_branch_top1_pct_of_mispred": 0.0,
            "target_branch_top2_pct_of_mispred": 0.0,
            "target_branch_top3_pct_of_mispred": 0.0,
            "text_sha256": "same-text-hash",
            "branch_region_start": 0x100,
            "branch_region_end": 0x110,
            "result_schema_version": 4,
            "simv_sha256": "simv-hash",
            "benchmark_contract_sha256": "contract-hash",
        }

    def _write_run(self, root: Path, mode: str, cycles: int, **overrides: object) -> None:
        run = self._base_run(mode, cycles)
        run.update(overrides)
        run_dir = root / "runs" / run["run_id"]
        run_dir.mkdir(parents=True)
        (run_dir / "result.json").write_text(
            json.dumps(run, sort_keys=True, indent=2), encoding="utf-8"
        )

    def test_normalize_missing_detail_counter_list(self):
        counters, count = _normalize_missing_counters(["a", "b"])
        self.assertEqual(counters, ["a", "b"])
        self.assertEqual(count, 2)

    def test_normalize_missing_detail_counter_count_int(self):
        counters, count = _normalize_missing_counters(7)
        self.assertEqual(counters, ["<legacy-missing-detail-count=7>"])
        self.assertEqual(count, 7)

    def test_pair_audit_warns_when_optional_counters_mismatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "runs").mkdir()
            (root / "run_info.json").write_text(
                json.dumps({"result_schema_version": 4}), encoding="utf-8"
            )
            self._write_run(
                root,
                "predictable",
                100,
                kernel_missing_detail_counters=["ifu_frontend_stall_raw"],
            )
            self._write_run(
                root,
                "random",
                120,
                kernel_missing_detail_counters=["retire_bht_mispred"],
            )

            status = analyze(
                root,
                do_recheck=False,
                output_dir=root / "audit",
                strict=True,
            )
            self.assertNotEqual(status, 0)
            summary = json.loads(
                (root / "audit" / "branch_pattern_audit_summary.json").read_text(
                    encoding="utf-8"
                )
            )
            self.assertGreater(summary["summary"]["pair_fail_or_incomplete"], 0)
            self.assertGreater(summary["summary"]["pair_fail"], 0)

    def test_pair_audit_warns_when_run_metadata_mismatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "runs").mkdir()
            (root / "run_info.json").write_text(
                json.dumps({"result_schema_version": 4}), encoding="utf-8"
            )
            self._write_run(root, "predictable", 100, seed=1)
            self._write_run(root, "random", 120, seed=2)

            status = analyze(
                root,
                do_recheck=False,
                output_dir=root / "audit",
                strict=True,
            )
            self.assertNotEqual(status, 0)
            summary = json.loads(
                (root / "audit" / "branch_pattern_audit_summary.json").read_text(
                    encoding="utf-8"
                )
            )
            self.assertEqual(summary["summary"]["pair_incomplete"], 0)
            self.assertGreater(summary["summary"]["pair_fail"], 0)

    def test_strict_run_returns_incomplete_when_predictable_missing(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "runs").mkdir()
            (root / "run_info.json").write_text(
                json.dumps({"result_schema_version": 4}), encoding="utf-8"
            )
            self._write_run(root, "predictable", 100)

            status = analyze(
                root,
                do_recheck=False,
                output_dir=root / "audit",
                strict=True,
            )
            self.assertNotEqual(status, 0)
            summary = json.loads(
                (root / "audit" / "branch_pattern_audit_summary.json").read_text(
                    encoding="utf-8"
                )
            )
            self.assertEqual(summary["summary"]["pair_incomplete"], 1)


if __name__ == "__main__":
    unittest.main()
