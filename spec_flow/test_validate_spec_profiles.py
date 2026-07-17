#!/usr/bin/env python3
import unittest

from spec_flow.validate_spec_profiles import validate_case


class ValidateSpecProfilesTest(unittest.TestCase):
    def setUp(self):
        self.contract = {
            "profiles": {
                "full": {
                    "metrics": {
                        "dynamic_instructions": {
                            "min": 400000,
                            "max": 600000,
                            "measured": 500000,
                            "tolerance": 4,
                        },
                        "working_set_bytes_64B_lines": {"min": 131072},
                        "warmup_instructions": {"measured": 1000},
                    },
                    "max_footprint_instruction_share": 0.1,
                }
            }
        }

    @staticmethod
    def features(instructions=500000, working_set=140000, footprint=40000):
        return {
            "profile": {"kernel_profile": "full", "warmup_instructions": 1000},
            "execution": {"dynamic_instructions": instructions},
            "memory": {"working_set_bytes_64B_lines": working_set},
            "hotspots": {
                "functions": [
                    {"name": "kernel", "count": instructions - footprint},
                    {"name": "spec_profile_footprint_run", "count": footprint},
                ]
            },
        }

    def test_accepts_profile(self):
        self.assertEqual(validate_case(self.contract, self.features(), "full"), [])

    def test_rejects_stale_measurement(self):
        errors = validate_case(
            self.contract, self.features(instructions=500010), "full"
        )
        self.assertTrue(any("stale" in error for error in errors))

    def test_rejects_small_working_set(self):
        errors = validate_case(
            self.contract, self.features(working_set=65536), "full"
        )
        self.assertTrue(any("working_set" in error for error in errors))

    def test_rejects_dominant_footprint(self):
        errors = validate_case(
            self.contract, self.features(footprint=60000), "full"
        )
        self.assertTrue(any("footprint instruction share" in error
                            for error in errors))

    def test_rejects_wrong_profile_metadata(self):
        features = self.features()
        features["profile"]["kernel_profile"] = "quick"
        errors = validate_case(self.contract, features, "full")
        self.assertTrue(any("profile metadata" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
