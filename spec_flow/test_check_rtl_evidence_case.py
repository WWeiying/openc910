import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.check_rtl_evidence_case import validate_archived_case
from spec_flow.validate_l2plus import REQUIRED_RTL_SUFFIXES


class CheckRtlEvidenceCaseTests(unittest.TestCase):
    def make_case(self, root):
        case = "spec_example_kernel"
        results = root / "results"
        features = root / "features"
        results.mkdir()
        feature_case = features / "cases" / case
        feature_case.mkdir(parents=True)
        for suffix in REQUIRED_RTL_SUFFIXES:
            (results / f"{case}{suffix}").write_text("artifact\n")
        elf = results / f"{case}.elf"
        elf.write_bytes(b"same-elf")
        (results / f"{case}.summary.txt").write_text(
            "|     Kernel     | 100 | 20 |\n"
        )
        (results / f"{case}.run_case.report").write_text("TEST PASS\n")
        (results / f"{case}.perf").write_text("|     Kernel | 100 | 20 |\n")
        (results / f"{case}.detail.perf").write_text(
            "Detailed Performance Statistics\n| Kernel | metric | 1 |\n"
        )
        (results / f"{case}.run.vcs.log").write_text("TEST PASS\n")
        digest = hashlib.sha256(elf.read_bytes()).hexdigest()
        (feature_case / "features.json").write_text(
            json.dumps(
                {
                    "profile": {"kernel_profile": "full"},
                    "provenance": {"elf_sha256": digest},
                }
            )
        )
        contracts = root / "contracts.json"
        contracts.write_text(
            json.dumps(
                {
                    "cases": {
                        case: {
                            "profiles": {
                                "full": {
                                    "metrics": {
                                        "dynamic_instructions": {
                                            "measured": 20
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            )
        )
        return case, results, features, contracts

    def validate(self, case, results, features, contracts):
        return validate_archived_case(
            case,
            results,
            contracts,
            "full",
            6,
            1,
            features,
        )

    def test_accepts_complete_matching_case(self):
        with tempfile.TemporaryDirectory() as tmp:
            args = self.make_case(Path(tmp))
            self.assertEqual(self.validate(*args), [])

    def test_rejects_ambiguous_pass_and_elf_mismatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            case, results, features, contracts = self.make_case(Path(tmp))
            (results / f"{case}.run_case.report").write_text(
                "TEST PASS\nTEST FAIL\n"
            )
            feature_path = features / "cases" / case / "features.json"
            feature = json.loads(feature_path.read_text())
            feature["provenance"]["elf_sha256"] = "0" * 64
            feature_path.write_text(json.dumps(feature))

            errors = self.validate(
                case, results, features, contracts
            )

            self.assertIn(
                "run_case.report is not an unambiguous TEST PASS", errors
            )
            self.assertIn("feature/RTL ELF SHA256 mismatch", errors)


if __name__ == "__main__":
    unittest.main()
