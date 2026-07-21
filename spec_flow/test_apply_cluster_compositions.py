#!/usr/bin/env python3
import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.apply_cluster_compositions import apply_map, apply_profiles


class ApplyClusterCompositionsTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.source = {
            "case": {
                "benchmark": "bench",
                "case": "case",
                "calibration": "simpoint-cluster-composition",
                "source_profile": "profile.csv",
                "source_cluster_count": 2,
                "mechanism_group_count": 2,
                "groups": [
                    {
                        "name": "a",
                        "mechanism": "ma",
                        "clusters": [0],
                        "intervals": [10],
                        "target_weight": 0.6,
                    },
                    {
                        "name": "b",
                        "mechanism": "mb",
                        "clusters": [1],
                        "intervals": [20],
                        "target_weight": 0.4,
                    },
                ],
            }
        }

    def test_applies_map_metadata(self):
        path = self.root / "map.json"
        path.write_text(
            json.dumps(
                {
                    "benchmarks": [
                        {
                            "bench": "x",
                            "kernels": [
                                {
                                    "case": "case",
                                    "composition": [
                                        {
                                            "name": "a",
                                            "mechanism": "ma",
                                            "source_clusters": [0],
                                            "target_weight": 0.6,
                                            "measured_instruction_share_by_profile": {
                                                "quick": 0.61,
                                                "full": 0.60,
                                            },
                                        }
                                    ],
                                }
                            ],
                        }
                    ]
                }
            )
        )
        self.assertEqual(apply_map(path, self.source), {"case"})
        kernel = json.loads(path.read_text())["benchmarks"][0]["kernels"][0]
        self.assertEqual(len(kernel["composition"]), 2)
        self.assertEqual(kernel["composition_basis"]["benchmark"], "bench")
        self.assertEqual(
            kernel["clusters"],
            [{"id": 0, "interval": 10}, {"id": 1, "interval": 20}],
        )
        self.assertEqual(kernel["composition"][0]["clusters"], [0])
        self.assertNotIn("source_clusters", kernel["composition"][0])
        self.assertEqual(
            kernel["composition"][0]["measured_instruction_share_by_profile"],
            {"quick": 0.61, "full": 0.60},
        )
        self.assertNotIn(
            "measured_instruction_share_by_profile", kernel["composition"][1]
        )

    def test_drops_measurement_when_cluster_source_changes(self):
        path = self.root / "map.json"
        path.write_text(
            json.dumps(
                {
                    "benchmarks": [
                        {
                            "bench": "bench",
                            "kernels": [
                                {
                                    "case": "case",
                                    "composition": [
                                        {
                                            "name": "a",
                                            "mechanism": "ma",
                                            "clusters": [7],
                                            "target_weight": 0.6,
                                            "measured_instruction_share_by_profile": {
                                                "quick": 0.6,
                                                "full": 0.6,
                                            },
                                        }
                                    ],
                                }
                            ],
                        }
                    ]
                }
            )
        )
        apply_map(path, self.source)
        groups = json.loads(path.read_text())["benchmarks"][0]["kernels"][0][
            "composition"
        ]
        self.assertNotIn(
            "measured_instruction_share_by_profile", groups[0]
        )

    def test_applies_profile_class(self):
        path = self.root / "profiles.json"
        path.write_text(json.dumps({"cases": {"case": {"calibration": "old"}}}))
        apply_profiles(path, self.source)
        row = json.loads(path.read_text())["cases"]["case"]
        self.assertEqual(row["calibration"], "simpoint-cluster-composition")


if __name__ == "__main__":
    unittest.main()
