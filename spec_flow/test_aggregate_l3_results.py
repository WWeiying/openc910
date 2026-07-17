import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.aggregate_l3_results import FORMAT, aggregate_benchmark


class AggregateL3ResultsTest(unittest.TestCase):
    def test_weights_cpi_and_event_rates(self):
        benchmark = {
            "bench": "999.example_r",
            "regions": [
                {"checkpoint_id": "a", "cluster": 0, "weight": 0.25},
                {"checkpoint_id": "b", "cluster": 1, "weight": 0.75},
            ],
        }
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for checkpoint_id, cycles, branches, misses in (
                ("a", 200, 20, 2),
                ("b", 100, 10, 2),
            ):
                path = root / checkpoint_id
                path.mkdir()
                (path / "rtl_result.json").write_text(
                    json.dumps(
                        {
                            "format": FORMAT,
                            "checkpoint_id": checkpoint_id,
                            "status": "pass",
                            "instructions": 100,
                            "cycles": cycles,
                            "events": {
                                "branches": branches,
                                "branch_mispredicts": misses,
                            },
                        }
                    )
                )
            result = aggregate_benchmark(benchmark, root)
        self.assertAlmostEqual(result["cpi"], 1.25)
        self.assertAlmostEqual(result["ipc"], 0.8)
        self.assertAlmostEqual(result["events"]["branches"]["mpki"], 125.0)
        self.assertAlmostEqual(result["ratios"]["branch_mispredict_rate"], 0.16)

    def test_rejects_missing_region_by_default(self):
        benchmark = {
            "bench": "999.example_r",
            "regions": [{"checkpoint_id": "missing", "cluster": 0, "weight": 1.0}],
        }
        with tempfile.TemporaryDirectory() as tmp:
            with self.assertRaisesRegex(ValueError, "missing results"):
                aggregate_benchmark(benchmark, Path(tmp))


if __name__ == "__main__":
    unittest.main()
