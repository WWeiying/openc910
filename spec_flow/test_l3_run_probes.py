import unittest
from pathlib import Path

from spec_flow.l3_run_probes import make_group_command, select_groups


class L3RunProbesTest(unittest.TestCase):
    def test_default_selection_skips_benchmark_level_blocker(self):
        plan = {
            "benchmarks": [
                {
                    "bench": "500.perlbench_r",
                    "ready_for_capture": False,
                    "issues": ["fork unsupported"],
                    "regions": [
                        {
                            "cluster": 0,
                            "command_index": 0,
                            "ready_for_capture": True,
                        }
                    ],
                },
                {
                    "bench": "505.mcf_r",
                    "ready_for_capture": True,
                    "regions": [
                        {
                            "cluster": 0,
                            "command_index": 0,
                            "ready_for_capture": True,
                        }
                    ],
                },
            ]
        }
        groups = select_groups(plan)
        self.assertEqual(list(groups), [("505.mcf_r", 0)])
        with self.assertRaisesRegex(ValueError, "fork unsupported"):
            select_groups(plan, benches=["500.perlbench_r"])

    def test_probe_covers_warmup_and_roi_syscall_windows(self):
        region = {
            "ready_for_capture": True,
            "run_directory": "/repo/spec/run",
            "command": "./mcf inp.in",
            "qemu_seed": 1,
            "qemu_reserved_va": "0x4000000000",
            "checkpoint_instruction": 900,
            "roi_start_instruction": 1000,
            "roi_instructions": 100,
            "checkpoint_id": "505.mcf_r.ref.cluster_0",
        }
        _, script, _ = make_group_command(
            "505.mcf_r",
            0,
            [region],
            Path("/repo"),
            Path("/work"),
            Path("/work/qemu"),
            Path("/work/sysroot"),
            Path("/work/probe.so"),
            Path("/repo/checkpoints"),
        )
        self.assertIn("windows=900-1000:1000-1100", script)
        self.assertIn("targets=900:1100", script)


if __name__ == "__main__":
    unittest.main()
