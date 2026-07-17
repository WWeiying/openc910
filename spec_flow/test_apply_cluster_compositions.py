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
                    {"name": "a", "mechanism": "ma", "clusters": [0], "target_weight": 0.6},
                    {"name": "b", "mechanism": "mb", "clusters": [1], "target_weight": 0.4},
                ],
            }
        }

    def test_applies_map_metadata(self):
        path = self.root / "map.json"
        path.write_text(json.dumps({"benchmarks": [{"bench": "x", "kernels": [{"case": "case"}]}]}))
        self.assertEqual(apply_map(path, self.source), {"case"})
        kernel = json.loads(path.read_text())["benchmarks"][0]["kernels"][0]
        self.assertEqual(len(kernel["composition"]), 2)
        self.assertEqual(kernel["composition_basis"]["benchmark"], "bench")

    def test_applies_profile_class(self):
        path = self.root / "profiles.json"
        path.write_text(json.dumps({"cases": {"case": {"calibration": "old"}}}))
        apply_profiles(path, self.source)
        row = json.loads(path.read_text())["cases"]["case"]
        self.assertEqual(row["calibration"], "simpoint-cluster-composition")


if __name__ == "__main__":
    unittest.main()
