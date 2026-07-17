import tempfile
import unittest
from pathlib import Path

from spec_flow.l3_metric_names import EVENT_NAMES, parse_metric_names
from spec_flow.l3_run_rtl import parse_rtl_log, select_regions


class L3RunRtlTest(unittest.TestCase):
    def test_default_selection_skips_benchmark_level_blocker(self):
        plan = {
            "benchmarks": [
                {
                    "bench": "500.perlbench_r",
                    "ready_for_capture": False,
                    "issues": ["fork unsupported"],
                    "regions": [{"checkpoint_id": "blocked"}],
                },
                {
                    "bench": "505.mcf_r",
                    "ready_for_capture": True,
                    "regions": [{"checkpoint_id": "supported"}],
                },
            ]
        }
        self.assertEqual(
            [item["checkpoint_id"] for item in select_regions(plan, [])],
            ["supported"],
        )
        with self.assertRaisesRegex(ValueError, "fork unsupported"):
            select_regions(plan, ["blocked"])

    def test_parses_complete_machine_readable_result(self):
        repo = Path(__file__).resolve().parent.parent
        names = parse_metric_names(repo / "smart_run/logical/tb/tb.v")
        lines = [
            "L3_RTL_RESULT checkpoint=sample cycles=1234 instructions=900 "
            "warmup=105 overshoot=0"
        ]
        lines.extend(
            f"L3_EVENT id={metric_id} value={metric_id}"
            for metric_id in EVENT_NAMES
        )
        lines.extend(
            f"L3_DETAIL id={metric_id} value={metric_id}"
            for metric_id in names["details"]
        )
        lines.extend(
            f"L3_PROFILE id={metric_id} value={metric_id}"
            for metric_id in names["profiles"]
        )
        for metric_id in names["latencies"]:
            lines.append(f"L3_LATENCY id={metric_id} samples=2 sum=8")
            lines.extend(
                f"L3_LATENCY_BUCKET id={metric_id} bucket={bucket} value=1"
                for bucket in range(1, 7)
            )
        lines.append("TEST PASS: L3 checkpoint ROI complete")
        with tempfile.TemporaryDirectory() as tmp:
            log = Path(tmp) / "rtl.log"
            log.write_text("\n".join(lines) + "\n")
            result = parse_rtl_log(log, "sample", names)
        self.assertEqual(result["cycles"], 1234)
        self.assertEqual(result["instructions"], 900)
        self.assertEqual(len(result["details"]), 805)
        self.assertEqual(len(result["profiles"]), 189)
        self.assertEqual(len(result["latencies"]), 54)
        self.assertEqual(result["events"]["branch_mispredicts"], 14)


if __name__ == "__main__":
    unittest.main()
