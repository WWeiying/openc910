#!/usr/bin/env python3

import concurrent.futures
import tempfile
import unittest
from pathlib import Path

from run_branch_pattern_sweep import (
    CORE_BRANCH_DETAIL_COUNTERS,
    RunConfig,
    StagedRun,
    parse_kernel_detail_counters,
    parse_branch_pc_totals,
    parse_branch_pc_records,
    paired_rows,
    parse_run_log,
    parse_key_values,
    SweepError,
    run_staged_case,
)


class ParallelRunIsolationTest(unittest.TestCase):
    def setUp(self):
        self.log_template = [
            "| Kernel | 10 | 8 |",
            "| Kernel Monitor | Value | Total |",
            "| L1I Miss | 0 | 1 |",
            "| Cond Branch Misp | 2 | 2 |",
            "===",
            "| Kernel | retire_bht_mispred | 2 |",
            "| Kernel | rtu_global_flush | 0 |",
        ]
        for name in CORE_BRANCH_DETAIL_COUNTERS:
            self.log_template.append(f"| Kernel | {name} | 0 |")
        self.log_template.append("| Kernel | retire_bht_mispred | 2 |")
        self.log_template.extend([
            "BRANCH_PC_BEGIN phase=Kernel",
            "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=2 mispred=2",
            "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=2 mispred=2 call_misp=1 return_misp=1 other_misp=0",
            "BRANCH_PC_END phase=Kernel",
        ])

    def _fake_result_paths(self, root: Path, mode: str, cycles: int) -> StagedRun:
        config = RunConfig(
            branches=1,
            pattern_length=2,
            repeat=1,
            mode=mode,
            seed=910,
            warmup_iterations=2,
            measure_iterations=2,
        )
        run_dir = root / config.run_id
        run_dir.mkdir()
        (run_dir / "symbols.args").write_text("", encoding="ascii")
        lines = self.log_template.copy()
        lines[0] = f"| Kernel | {cycles} | 8 |"
        (run_dir / "fixture.log").write_text("\n".join(lines) + "\n", encoding="ascii")

        (run_dir / "bench_br_pattern.asm").write_text(
            "\t.file\n"
            "00000100: 00000000    beqz\ta0, loop\n",
            encoding="ascii",
        )
        return StagedRun(
            config=config,
            run_dir=run_dir,
            branch_region_start=0x100,
            branch_region_end=0x102,
            static_branch_count=1,
            compiled_config={"branches": 1},
            text_sha256="same-text",
        )

    def test_workers_keep_runtime_outputs_in_their_case_directories(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            simv = root / "fake_simv.sh"
            simv.write_text(
                "#!/bin/sh\n"
                "cp fixture.log run.vcs.log\n"
                "printf 'TEST PASS\\n' > run_case.report\n",
                encoding="ascii",
            )
            simv.chmod(0o755)

            staged_runs = [
                self._fake_result_paths(root, "predictable", 10),
                self._fake_result_paths(root, "random", 14),
            ]

            with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
                futures = [
                    executor.submit(
                        run_staged_case,
                        staged,
                        simv,
                        10,
                        contract_hash="contract",
                        simv_hash="simv",
                    )
                    for staged in staged_runs
                ]
                results = [future.result() for future in futures]

            self.assertEqual(
                {result["kernel_cycles"] for result in results}, {10, 14}
            )
            for staged in staged_runs:
                self.assertTrue((staged.run_dir / "result.json").is_file())
                self.assertEqual(
                    (staged.run_dir / "run_case.report").read_text().strip(),
                    "TEST PASS",
                )


class ParseKeyValueUtilsTest(unittest.TestCase):
    def test_parse_key_values(self):
        parsed = parse_key_values("pc=0x100 exec=4 mispred=2 extra=1")
        self.assertEqual(parsed["pc"], "0x100")
        self.assertEqual(parsed["exec"], "4")
        self.assertEqual(parsed["mispred"], "2")

    def test_parse_branch_pc_totals(self):
        text = "\n".join(
            [
                "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=10 mispred=3",
                "BRANCH_PC_TOTAL phase=Kernel kind=jmp exec=1 mispred=0",
            ]
        )
        totals = parse_branch_pc_totals(text)
        self.assertEqual(totals[("Kernel", "cond")]["exec"], 10)
        self.assertEqual(totals[("Kernel", "cond")]["mispred"], 3)
        self.assertEqual(totals[("Kernel", "jmp")]["exec"], 1)

    def test_parse_branch_pc_totals_rejects_duplicate(self):
        text = "\n".join(
            [
                "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=10 mispred=3",
                "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=12 mispred=4",
            ]
        )
        with self.assertRaises(SweepError):
            parse_branch_pc_totals(text)

    def test_parse_branch_pc_records_with_misclassification_tokens(self):
        text = "\n".join(
            [
                "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=3 mispred=1 rate=50 call_misp=0 return_misp=1 other_misp=0",
                "BRANCH_PC phase=Kernel kind=cond pc=0x104 exec=3 mispred=2 rate=50 call_misp=1 return_misp=1 other_misp=0",
                "BRANCH_PC phase=Kernel kind=jmp pc=0x200 exec=3 mispred=0",
            ]
        )
        rows = parse_branch_pc_records(text, "Kernel", "cond", 0x100, 0x110)
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[0]["pc"], 0x100)
        self.assertEqual(rows[1]["call_misp"], 1)
        self.assertEqual(rows[1]["return_misp"], 1)

    def test_parse_branch_pc_records_rejects_duplicate_pc(self):
        text = "\n".join(
            [
                "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=3 mispred=1 call_misp=0 return_misp=1 other_misp=0",
                "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=3 mispred=1 call_misp=0 return_misp=1 other_misp=0",
            ]
        )
        with self.assertRaises(SweepError):
            parse_branch_pc_records(text, "Kernel", "cond", 0x100, 0x110)

    def test_parse_kernel_detail_counters_rejects_conflicting_values(self):
        text = "\n".join(
            [
                "Detailed Performance Statistics",
                "| Kernel | ifu_frontend_stall_raw | 1 |",
                "| Kernel | ifu_frontend_stall_raw | 2 |",
                "===",
            ]
        )
        with self.assertRaises(SweepError):
            parse_kernel_detail_counters(text)


class LogAndPairingTest(unittest.TestCase):
    def _result(self, mode: str, cycles: int, branch_mispred: int, stall: int):
        return {
            "branches_in_loop": 2,
            "pattern_length": 4,
            "repeat": 1,
            "seed": 910,
            "warmup_iterations": 2,
            "measure_iterations": 4,
            "text_sha256": "same",
            "mode": mode,
            "target_executed_branches": 8,
            "kernel_cycles": cycles,
            "kernel_retired_instructions": 100,
            "kernel_conditional_branches": 18,
            "kernel_mispredictions": branch_mispred,
            "kernel_bht_mispredictions": branch_mispred,
            "kernel_global_flushes": 0,
            "kernel_l1i_misses": 0,
            "simulation_wall_seconds": 1.23,
            "target_mispredictions": branch_mispred,
            "target_mispred_site_count": 1,
            "target_branch_top1_mispred_site": "0x100",
            "target_branch_top1_mispred_count": branch_mispred,
            "target_branch_top1_mispred_share_pct": float(branch_mispred),
            "target_branch_top2_mispred_share_pct": 0.0,
            "target_branch_top3_mispred_share_pct": 0.0,
            "target_branch_gini_like": 0.0,
            "target_branch_pc_span": 0,
            "target_branch_pc_first": "0x100",
            "target_branch_pc_last": "0x100",
            "target_branch_exec_mode": "2",
            "target_branch_sites": 2,
            "target_branch_call_mispred": branch_mispred,
            "target_branch_return_mispred": 0,
            "target_branch_other_mispred": 0,
            "target_branch_top1_pct_of_mispred": 100.0,
            "target_branch_top2_pct_of_mispred": 0.0,
            "target_branch_top3_pct_of_mispred": 0.0,
            "kernel_detail_missing_count": 0,
            "kernel_detail_counters": {
                "ifu_frontend_stall_raw": stall,
                "ifu_multi_branch_stall": 0,
                "ifu_retire0_condbr": 0,
                "ifu_retire0_mispred": 0,
                "retire_bht_mispred": branch_mispred,
                "rtu_global_flush": 0,
            },
            "kernel_missing_detail_counters": [],
        }

    def test_paired_rows_keeps_random_and_predictable_metrics(self):
        # fill required detail counters not in explicit map with zero defaults
        for name in CORE_BRANCH_DETAIL_COUNTERS:
            if name not in self._result("predictable", 10, 3, 100)["kernel_detail_counters"]:
                self._result("predictable", 10, 3, 100)["kernel_detail_counters"][name] = 0
            if name not in self._result("random", 12, 5, 120)["kernel_detail_counters"]:
                self._result("random", 12, 5, 120)["kernel_detail_counters"][name] = 0

        rows = paired_rows(
            [
                self._result("predictable", 10, 3, 100),
                self._result("random", 12, 5, 120),
            ]
        )
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertEqual(row["random_ifu_frontend_stall_raw"], 120)
        self.assertEqual(row["predictable_ifu_frontend_stall_raw"], 100)
        self.assertNotEqual(
            row["delta_ifu_frontend_stall_raw_count"],
            0,
        )
        self.assertIn("delta_top_mechanisms_per_kbranch", row)

    def test_paired_rows_rejects_duplicate_mode(self):
        result = self._result("predictable", 10, 3, 100)
        # mutate required fields to make second same-mode entry look independent
        result_duplicate = self._result("predictable", 11, 4, 101)
        with self.assertRaises(SweepError):
            paired_rows([result, result_duplicate])

    def test_parse_run_log_requires_asm_close(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            log_path = root / "run.vcs.log"
            asm_path = root / "bench_br_pattern.asm"
            run_log = "\n".join(
                [
                    "| Kernel | 10 | 8 |",
                    "| Kernel Monitor | Value | Total |",
                    "| L1I Miss | 0 | 1 |",
                    "| Cond Branch Misp | 0 | 6 |",
                    "===",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | rtu_global_flush | 0 |",
                    "| Kernel | ifu_frontend_stall_raw | 0 |",
                    "| Kernel | ifu_multi_branch_stall | 0 |",
                    "| Kernel | ifu_retire0_condbr | 0 |",
                    "| Kernel | ifu_retire0_mispred | 0 |",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | iu_idu_mispred_stall | 0 |",
                    "| Kernel | iu_ifu_mispred_stall | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | bht_bju_mispred | 0 |",
                    "| Kernel | lbuf_bju_mispred | 0 |",
                    "| Kernel | iu_bht_mispred | 2 |",
                    "| Kernel | iu_jmp_mispred | 0 |",
                    "| Kernel | ifu_retire0_jmp_mispred | 0 |",
                    "| Kernel | ifu_retire0_condbr_taken | 0 |",
                    "| Kernel | retire_jmp_mispred | 0 |",
                    "| Kernel | retire_condbr_slot0 | 0 |",
                    "| Kernel | retire_condbr_slot1 | 0 |",
                    "| Kernel | retire_condbr_slot2 | 0 |",
                    "BRANCH_PC_BEGIN phase=Kernel",
                    "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=6 mispred=2",
                    "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=2 mispred=2",
                    "BRANCH_PC_END phase=Kernel",
                ]
            )
            log_path.write_text(run_log + "\n", encoding="ascii")
            asm_path.write_text(
                "\t.file\n"
                "100:\tbeqz a0, loop\n"
                "108:\tnop\n",
                encoding="ascii",
            )
            config = RunConfig(
                branches=1,
                pattern_length=4,
                repeat=1,
                mode="random",
                seed=910,
                warmup_iterations=2,
                measure_iterations=2,
            )
            with self.assertRaises(SweepError):
                parse_run_log(log_path, config, 0x100, 0x102, asm_path)

    def test_parse_run_log_rejects_mispred_classification(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            log_path = root / "run.vcs.log"
            asm_path = root / "bench_br_pattern.asm"
            run_log = "\n".join(
                [
                    "| Kernel | 10 | 8 |",
                    "| Kernel Monitor | Value | Total |",
                    "| L1I Miss | 0 | 1 |",
                    "| Cond Branch Misp | 1 | 2 |",
                    "===",
                    "| Kernel | retire_bht_mispred | 1 |",
                    "| Kernel | rtu_global_flush | 0 |",
                    "| Kernel | ifu_frontend_stall_raw | 0 |",
                    "| Kernel | ifu_multi_branch_stall | 0 |",
                    "| Kernel | ifu_retire0_condbr | 2 |",
                    "| Kernel | ifu_retire0_mispred | 0 |",
                    "| Kernel | ifu_retire0_condbr_taken | 0 |",
                    "| Kernel | ifu_retire0_jmp_mispred | 0 |",
                    "| Kernel | retire_jmp_mispred | 0 |",
                    "| Kernel | retire_condbr_slot0 | 0 |",
                    "| Kernel | retire_condbr_slot1 | 0 |",
                    "| Kernel | retire_condbr_slot2 | 0 |",
                    "| Kernel | retire_bht_mispred | 1 |",
                    "| Kernel | iu_idu_mispred_stall | 0 |",
                    "| Kernel | iu_ifu_mispred_stall | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | bht_bju_mispred | 0 |",
                    "| Kernel | lbuf_bju_mispred | 0 |",
                    "| Kernel | iu_bht_mispred | 0 |",
                    "| Kernel | iu_jmp_mispred | 0 |",
                    "| Kernel | l0_btb_mispred | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | ind_btb_check | 0 |",
                    "| Kernel | ind_btb_fifo_stall | 0 |",
                    "| Kernel | ras_redirect | 0 |",
                    "| Kernel | ras_mistaken | 0 |",
                    "| Kernel | ras_redirect | 0 |",
                    "| Kernel | ras_mistaken | 0 |",
                    "| Kernel | ifu_retire0_condbr_taken | 0 |",
                    "| Kernel | bht_bju_mispred | 0 |",
                    "| Kernel | bht_bju_mispred | 0 |",
                    "| Kernel | lbuf_bju_mispred | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | ind_btb_check | 0 |",
                    "| Kernel | ind_btb_fifo_stall | 0 |",
                    "| Kernel | retire_jmp_mispred | 0 |",
                    "BRANCH_PC_BEGIN phase=Kernel",
                    "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=2 mispred=1",
                    # classification exceeds total on purpose: call_misp + return_misp + other_misp = 2 > mispred 1
                    "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=2 mispred=1 call_misp=1 return_misp=1 other_misp=0",
                    "BRANCH_PC_END phase=Kernel",
                ]
            )
            log_path.write_text(run_log + "\n", encoding="ascii")
            asm_path.write_text(
                "\t.file\n"
                "00000100: 00000000    beqz a0, loop\n",
                encoding="ascii",
            )
            config = RunConfig(
                branches=1,
                pattern_length=4,
                repeat=1,
                mode="random",
                seed=910,
                warmup_iterations=2,
                measure_iterations=2,
            )
            with self.assertRaises(SweepError):
                parse_run_log(log_path, config, 0x100, 0x102, asm_path)

    def test_parse_run_log_slot_counters_close(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            log_path = root / "run.vcs.log"
            asm_path = root / "bench_br_pattern.asm"
            run_log = "\n".join(
                [
                    "| Kernel | 10 | 8 |",
                    "| Kernel Monitor | Value | Total |",
                    "| L1I Miss | 0 | 1 |",
                    "| Cond Branch Misp | 2 | 2 |",
                    "===",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | rtu_global_flush | 0 |",
                    "| Kernel | ifu_frontend_stall_raw | 0 |",
                    "| Kernel | ifu_multi_branch_stall | 0 |",
                    "| Kernel | ifu_retire0_condbr | 2 |",
                    "| Kernel | ifu_retire0_mispred | 0 |",
                    "| Kernel | ifu_retire0_condbr_taken | 0 |",
                    "| Kernel | ifu_retire0_jmp_mispred | 0 |",
                    "| Kernel | retire_condbr_slot0 | 2 |",
                    "| Kernel | retire_condbr_slot1 | 1 |",
                    "| Kernel | retire_condbr_slot2 | 0 |",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | iu_idu_mispred_stall | 0 |",
                    "| Kernel | iu_ifu_mispred_stall | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | bht_bju_mispred | 0 |",
                    "| Kernel | lbuf_bju_mispred | 0 |",
                    "| Kernel | iu_bht_mispred | 0 |",
                    "| Kernel | iu_jmp_mispred | 0 |",
                    "| Kernel | retire_jmp_mispred | 0 |",
                    "| Kernel | l0_btb_mispred | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | ind_btb_check | 0 |",
                    "| Kernel | ind_btb_fifo_stall | 0 |",
                    "| Kernel | ras_redirect | 0 |",
                    "| Kernel | ras_mistaken | 0 |",
                    "BRANCH_PC_BEGIN phase=Kernel",
                    "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=2 mispred=2",
                    "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=2 mispred=2",
                    "BRANCH_PC_END phase=Kernel",
                ]
            )
            log_path.write_text(run_log + "\n", encoding="ascii")
            asm_path.write_text(
                "\t.file\n"
                "00000100: 00000000    beqz a0, loop\n",
                encoding="ascii",
            )
            config = RunConfig(
                branches=1,
                pattern_length=4,
                repeat=1,
                mode="random",
                seed=910,
                warmup_iterations=2,
                measure_iterations=2,
            )
            # 2 cond-branch slots != expected 2 when totals are 2/1/0 -> 3, should fail.
            with self.assertRaises(SweepError):
                parse_run_log(log_path, config, 0x100, 0x102, asm_path)

    def test_parse_run_log_slot_total_missing_fields_not_required(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            log_path = root / "run.vcs.log"
            asm_path = root / "bench_br_pattern.asm"
            run_log = "\n".join(
                [
                    "| Kernel | 10 | 8 |",
                    "| Kernel Monitor | Value | Total |",
                    "| L1I Miss | 0 | 1 |",
                    "| Cond Branch Misp | 2 | 2 |",
                    "===",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | rtu_global_flush | 0 |",
                    "| Kernel | ifu_frontend_stall_raw | 0 |",
                    "| Kernel | ifu_multi_branch_stall | 0 |",
                    "| Kernel | ifu_retire0_condbr | 2 |",
                    "| Kernel | ifu_retire0_mispred | 0 |",
                    "| Kernel | ifu_retire0_condbr_taken | 0 |",
                    "| Kernel | ifu_retire0_jmp_mispred | 0 |",
                    "| Kernel | retire_jmp_mispred | 0 |",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | iu_idu_mispred_stall | 0 |",
                    "| Kernel | iu_ifu_mispred_stall | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | bht_bju_mispred | 0 |",
                    "| Kernel | lbuf_bju_mispred | 0 |",
                    "| Kernel | iu_bht_mispred | 0 |",
                    "| Kernel | iu_jmp_mispred | 0 |",
                    "BRANCH_PC_BEGIN phase=Kernel",
                    "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=2 mispred=2",
                    "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=2 mispred=2",
                    "BRANCH_PC_END phase=Kernel",
                ]
            )
            log_path.write_text(run_log + "\n", encoding="ascii")
            asm_path.write_text(
                "\t.file\n"
                "00000100: 00000000    beqz a0, loop\n",
                encoding="ascii",
            )
            config = RunConfig(
                branches=1,
                pattern_length=4,
                repeat=1,
                mode="random",
                seed=910,
                warmup_iterations=2,
                measure_iterations=2,
            )
            result = parse_run_log(log_path, config, 0x100, 0x102, asm_path)
            self.assertEqual(result["kernel_condbr_slot0"], 0)
            self.assertEqual(result["kernel_condbr_slot_total"], 0)

    def test_parse_run_log_rejects_partial_slot_counters(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            log_path = root / "run.vcs.log"
            asm_path = root / "bench_br_pattern.asm"
            run_log = "\n".join(
                [
                    "| Kernel | 10 | 8 |",
                    "| Kernel Monitor | Value | Total |",
                    "| L1I Miss | 0 | 1 |",
                    "| Cond Branch Misp | 2 | 2 |",
                    "===",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | rtu_global_flush | 0 |",
                    "| Kernel | ifu_frontend_stall_raw | 0 |",
                    "| Kernel | ifu_multi_branch_stall | 0 |",
                    "| Kernel | ifu_retire0_condbr | 2 |",
                    "| Kernel | ifu_retire0_mispred | 0 |",
                    "| Kernel | retire_condbr_slot0 | 2 |",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "BRANCH_PC_BEGIN phase=Kernel",
                    "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=2 mispred=2",
                    "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=2 mispred=2",
                    "BRANCH_PC_END phase=Kernel",
                ]
            )
            log_path.write_text(run_log + "\n", encoding="ascii")
            asm_path.write_text(
                "\t.file\n"
                "00000100: 00000000    beqz a0, loop\n",
                encoding="ascii",
            )
            config = RunConfig(
                branches=1,
                pattern_length=4,
                repeat=1,
                mode="random",
                seed=910,
                warmup_iterations=2,
                measure_iterations=2,
            )
            with self.assertRaises(SweepError):
                parse_run_log(log_path, config, 0x100, 0x102, asm_path)

    def test_parse_run_log_rejects_partial_ifu_retire0_counters(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            log_path = root / "run.vcs.log"
            asm_path = root / "bench_br_pattern.asm"
            run_log = "\n".join(
                [
                    "| Kernel | 10 | 8 |",
                    "| Kernel Monitor | Value | Total |",
                    "| L1I Miss | 0 | 1 |",
                    "| Cond Branch Misp | 2 | 2 |",
                    "===",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | rtu_global_flush | 0 |",
                    "| Kernel | ifu_frontend_stall_raw | 0 |",
                    "| Kernel | ifu_multi_branch_stall | 0 |",
                    "| Kernel | ifu_retire0_condbr | 2 |",
                    "| Kernel | ifu_retire0_condbr_taken | 2 |",
                    "| Kernel | retire_bht_mispred | 2 |",
                    "| Kernel | iu_idu_mispred_stall | 0 |",
                    "| Kernel | iu_ifu_mispred_stall | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | bht_bju_mispred | 0 |",
                    "| Kernel | lbuf_bju_mispred | 0 |",
                    "| Kernel | iu_bht_mispred | 0 |",
                    "| Kernel | iu_jmp_mispred | 0 |",
                    "| Kernel | retire_jmp_mispred | 0 |",
                    "| Kernel | retire_condbr_slot0 | 2 |",
                    "| Kernel | retire_condbr_slot1 | 0 |",
                    "| Kernel | retire_condbr_slot2 | 0 |",
                    "| Kernel | retire_jmp_mispred | 0 |",
                    "| Kernel | l0_btb_mispred | 0 |",
                    "| Kernel | l0_btb_wait | 0 |",
                    "| Kernel | ind_btb_check | 0 |",
                    "| Kernel | ind_btb_fifo_stall | 0 |",
                    "| Kernel | ras_redirect | 0 |",
                    "| Kernel | ras_mistaken | 0 |",
                    "BRANCH_PC_BEGIN phase=Kernel",
                    "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=2 mispred=2",
                    "BRANCH_PC phase=Kernel kind=cond pc=0x100 exec=2 mispred=2",
                    "BRANCH_PC_END phase=Kernel",
                ]
            )
            log_path.write_text(run_log + "\n", encoding="ascii")
            asm_path.write_text(
                "\t.file\n"
                "00000100: 00000000    beqz a0, loop\n",
                encoding="ascii",
            )
            config = RunConfig(
                branches=1,
                pattern_length=4,
                repeat=1,
                mode="random",
                seed=910,
                warmup_iterations=2,
                measure_iterations=2,
            )
            with self.assertRaises(SweepError):
                parse_run_log(log_path, config, 0x100, 0x102, asm_path)


if __name__ == "__main__":
    unittest.main()
