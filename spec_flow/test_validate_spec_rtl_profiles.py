#!/usr/bin/env python3
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.validate_spec_rtl_profiles import validate_case


class ValidateSpecRtlProfilesTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.case = "spec_test_kernel"
        (self.root / f"{self.case}.summary.txt").write_text(
            "| Kernel | 20000 | 100005 | 0.5 | 2.0 |\n"
        )
        (self.root / f"{self.case}.run_case.report").write_text("TEST PASS\n")
        (self.root / f"{self.case}.detail.perf").write_text(
            "| Kernel | metric | 0 |\n" * 1048
        )
        elf = self.root / f"{self.case}.elf"
        elf.write_bytes(b"same elf")
        digest = hashlib.sha256(elf.read_bytes()).hexdigest()
        self.features = self.root / "features"
        feature_case = self.features / "cases" / self.case
        feature_case.mkdir(parents=True)
        (feature_case / "features.json").write_text(json.dumps({
            "profile": {"kernel_profile": "quick"},
            "provenance": {"elf_sha256": digest},
        }))
        self.contract = {
            "profiles": {"quick": {"metrics": {
                "dynamic_instructions": {"measured": 100000}
            }}}
        }

    def tearDown(self):
        self.temp.cleanup()

    def validate(self, tolerance=6):
        return validate_case(
            self.case, self.contract, self.root, "quick", tolerance, 1048,
            self.features, True,
        )

    def test_accepts_same_elf_and_five_instruction_boundary_delta(self):
        row, errors = self.validate()
        self.assertEqual(errors, [])
        self.assertEqual(row["delta"], 5)

    def test_rejects_tighter_boundary_tolerance(self):
        _, errors = self.validate(tolerance=4)
        self.assertTrue(any("boundary delta" in error for error in errors))

    def test_rejects_unknown_detail_cell(self):
        path = self.root / f"{self.case}.detail.perf"
        path.write_text(path.read_text() + "| Kernel | bad | X |\n")
        _, errors = self.validate()
        self.assertTrue(any("unknown cells" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
