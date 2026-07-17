import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.l3_checkpoint_plan import analyze_bbv, build_benchmark_plan


class L3CheckpointPlanTest(unittest.TestCase):
    def test_maps_global_interval_to_command_local_interval(self):
        commands = [
            {"index": 0, "start_id": 1, "end_id": 9},
            {"index": 1, "start_id": 10, "end_id": 19},
        ]
        with tempfile.TemporaryDirectory() as tmp:
            bbv = Path(tmp) / "sample.bb"
            bbv.write_text("T:1:100 \nT:2:101 \nT:10:99 \n")
            regions, count = analyze_bbv(bbv, commands, {1, 2}, 100)
        self.assertEqual(count, 3)
        self.assertEqual(regions[1]["command_index"], 0)
        self.assertEqual(regions[1]["command_interval"], 1)
        self.assertEqual(regions[1]["command_instruction_start"], 100)
        self.assertEqual(regions[2]["command_index"], 1)
        self.assertEqual(regions[2]["command_interval"], 0)
        self.assertEqual(regions[2]["command_instruction_start"], 0)

    def test_builds_capture_coordinates_and_provenance(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            elf = root / "case.elf"
            elf.write_bytes(b"elf")
            bbv = root / "case.bb"
            bbv.write_text("T:1:100 \nT:1:100 \n")
            cmdmap = root / "case.bb.cmdmap"
            cmdmap.write_text(
                "cmd_index\tstart_id\tend_id\telf\tcommand\n"
                f"0\t1\t1\t{elf}\t./case.elf input\n"
            )
            manifest = root / "manifest.json"
            manifest.write_text(
                json.dumps(
                    {
                        "bench": "999.example_r",
                        "size": "ref",
                        "interval": 100,
                        "collection": {"full_program": True},
                        "validation": {"compare_pass": True, "simpoint_done": True},
                        "files": {"bbv": str(bbv), "bbv_cmdmap": str(cmdmap)},
                        "simpoints": [
                            {"cluster": 0, "interval": 1, "weight": 1.0}
                        ],
                        "qemu_reserved_va": "0x4000000000",
                    }
                )
            )
            plan = build_benchmark_plan(manifest, root, 25, 1)
        region = plan["regions"][0]
        self.assertTrue(plan["ready_for_capture"])
        self.assertEqual(region["checkpoint_instruction"], 75)
        self.assertEqual(region["roi_start_instruction"], 100)
        self.assertEqual(region["warmup_instructions"], 25)


if __name__ == "__main__":
    unittest.main()
