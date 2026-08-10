#!/usr/bin/env python3

import concurrent.futures
import tempfile
import unittest
from pathlib import Path

from run_branch_pattern_sweep import RunConfig, StagedRun, run_staged_case


class ParallelRunIsolationTest(unittest.TestCase):
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

            staged_runs = []
            for mode, cycles in (("predictable", 10), ("random", 14)):
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
                (run_dir / "fixture.log").write_text(
                    f"| Kernel | {cycles} | 8 |\n"
                    "| Kernel Monitor | Value | Total |\n"
                    "| L1I Miss | 0 | 1 |\n"
                    "| Cond Branch Misp | 0 | 4 |\n"
                    "===\n"
                    "| Kernel | retire_bht_mispred | 0 |\n"
                    "| Kernel | rtu_global_flush | 0 |\n"
                    "BRANCH_PC_TOTAL phase=Kernel kind=cond exec=4 mispred=0\n"
                    "BRANCH_PC phase=Kernel kind=cond pc=0x100 "
                    "exec=2 mispred=0 rate_pct=0\n",
                    encoding="ascii",
                )
                staged_runs.append(
                    StagedRun(
                        config=config,
                        run_dir=run_dir,
                        branch_region_start=0x100,
                        branch_region_end=0x104,
                        static_branch_count=1,
                        compiled_config={"branches": 1},
                        text_sha256="same-text",
                    )
                )

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


if __name__ == "__main__":
    unittest.main()
