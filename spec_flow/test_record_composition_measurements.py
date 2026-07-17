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
                "composition_phases": {"phases": [
                    {"name": "phase0", "share": shares[0]},
                    {"name": "phase1", "share": shares[1]},
                ]}
            }))
        path = root / "map.json"
        path.write_text(json.dumps({"benchmarks": [{"kernels": [{
            "case": "case", "composition": [{"name": "a"}, {"name": "b"}]
        }]}]}))
        self.assertEqual(update_map(path, quick, full), {"case"})
        groups = json.loads(path.read_text())["benchmarks"][0]["kernels"][0]["composition"]
        self.assertEqual(groups[1]["measured_instruction_share_by_profile"]["full"], 0.41)


if __name__ == "__main__":
    unittest.main()
