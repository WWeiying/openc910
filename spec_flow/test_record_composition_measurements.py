#!/usr/bin/env python3
import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.record_composition_measurements import update_map


class RecordCompositionMeasurementsTest(unittest.TestCase):
    def test_records_profile_specific_shares(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name)
        quick, full = root / "quick", root / "full"
        for profile, shares in ((quick, [0.6, 0.4]), (full, [0.59, 0.41])):
            case_dir = profile / "cases" / "case"
            case_dir.mkdir(parents=True)
            (case_dir / "features.json").write_text(json.dumps({
                "case": "case",
                "profile": {
                    "kernel_profile": "quick" if profile == quick else "full"
                },
                "execution": {"dynamic_instructions": 100},
                "composition_phases": {
                    "attributed_instructions": 100,
                    "phases": [
                        {"name": "phase0", "count": 100 * shares[0],
                         "share": shares[0]},
                        {"name": "phase1", "count": 100 * shares[1],
                         "share": shares[1]},
                    ],
                },
            }))
        path = root / "map.json"
        path.write_text(json.dumps({"benchmarks": [{"kernels": [{
            "case": "case", "composition": [
                {"name": "a", "target_weight": 0.6},
                {"name": "b", "target_weight": 0.4},
            ]
        }]}]}))
        self.assertEqual(update_map(path, quick, full), {"case"})
        groups = json.loads(path.read_text())["benchmarks"][0]["kernels"][0]["composition"]
        self.assertEqual(groups[1]["measured_instruction_share_by_profile"]["full"], 0.41)

    def test_records_function_selected_composite_without_phase_markers(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name)
        quick, full = root / "quick", root / "full"
        for profile in (quick, full):
            case_dir = profile / "cases" / "case"
            case_dir.mkdir(parents=True)
            (case_dir / "features.json").write_text(json.dumps({
                "case": "case",
                "profile": {
                    "kernel_profile": "quick" if profile == quick else "full"
                },
                "execution": {"dynamic_instructions": 100},
                "hotspots": {"functions": [
                    {"name": "sort", "count": 65},
                    {"name": "price", "count": 35},
                ]},
            }))
        path = root / "map.json"
        path.write_text(json.dumps({"benchmarks": [{
            "bench": "example",
            "kernels": [{
                "case": "case",
                "composition": [
                    {"name": "a", "functions": ["sort"],
                     "target_weight": 0.65},
                    {"name": "b", "functions": ["price"],
                     "target_weight": 0.35},
                ],
            }],
        }]}))
        self.assertEqual(update_map(path, quick, full), {"case"})
        groups = json.loads(path.read_text())["benchmarks"][0]["kernels"][0][
            "composition"
        ]
        self.assertEqual(
            groups[0]["measured_instruction_share_by_profile"],
            {"quick": 0.65, "full": 0.65},
        )


if __name__ == "__main__":
    unittest.main()
