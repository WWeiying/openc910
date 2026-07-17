#!/usr/bin/env python3
import unittest

from spec_flow.validate_composite_features import validate_measurement


class ValidateCompositeFeaturesTest(unittest.TestCase):
    def setUp(self):
        self.row = {
            "bench": "example",
            "kernels": [
                {
                    "case": "composite",
                    "profile_constraints": {
                        "quick": {
                            "dynamic_instructions": {"min": 900, "max": 1100},
                            "working_set_bytes_64B_lines": {"min": 4096},
                        },
                        "full": {
                            "dynamic_instructions": {"min": 9000, "max": 11000},
                        },
                    },
                    "composition": [
                        {
                            "name": "a",
                            "target_weight": 0.6,
                            "measured_instruction_share": 0.6,
                            "functions": ["phase_a"],
                        },
                        {
                            "name": "b",
                            "target_weight": 0.4,
                            "measured_instruction_share": 0.4,
                            "function_patterns": ["^phase_b"],
                        },
                    ],
                }
            ],
        }

    def features(self, a=600, b=400, overhead=1):
        return {
            "execution": {"dynamic_instructions": a + b + overhead},
            "memory": {"working_set_bytes_64B_lines": 8192},
            "hotspots": {
                "functions": [
                    {"name": "phase_a", "count": a},
                    {"name": "phase_b.constprop.0", "count": b},
                    {"name": "perf_monitor_start", "count": overhead},
                ]
            },
        }

    def test_accepts_current_elf_mix(self):
        result, errors = validate_measurement(self.row, self.features())
        self.assertEqual(errors, [])
        self.assertEqual(result["matched"], 1000)

    def test_rejects_target_drift(self):
        _, errors = validate_measurement(self.row, self.features(a=700, b=300))
        self.assertTrue(any("differs from target" in error for error in errors))
        self.assertTrue(any("stored measured share is stale" in error for error in errors))

    def test_rejects_unclassified_dynamic_work(self):
        _, errors = validate_measurement(self.row, self.features(overhead=10))
        self.assertTrue(any("unmatched instruction share" in error for error in errors))

    def test_uses_profile_specific_stored_share(self):
        self.row["kernels"][0]["composition"][0][
            "measured_instruction_share_by_profile"
        ] = {"quick": 0.6, "full": 0.7}
        self.row["kernels"][0]["composition"][1][
            "measured_instruction_share_by_profile"
        ] = {"quick": 0.4, "full": 0.3}
        full = self.features(a=7000, b=3000)
        result, errors = validate_measurement(
            self.row, full, target_tolerance=0.11, profile="full"
        )
        self.assertEqual(errors, [])
        self.assertEqual(result["groups"][0]["stored_measured"], 0.7)

    def test_rejects_profile_size_outside_contract(self):
        _, errors = validate_measurement(self.row, self.features(), profile="full")
        self.assertTrue(any("dynamic_instructions" in error for error in errors))

    def test_rejects_missing_profile_metric(self):
        features = self.features()
        del features["memory"]
        _, errors = validate_measurement(self.row, features)
        self.assertTrue(any("metric working_set_bytes_64B_lines is missing" in error
                            for error in errors))

    def test_prefers_explicit_phase_measurement(self):
        features = self.features(a=1, b=1)
        features["composition_phases"] = {
            "attributed_instructions": 1000,
            "marker_instructions": 4,
            "unattributed_instructions": 0,
            "phases": [
                {"name": "phase0", "count": 600, "share": 0.6},
                {"name": "phase1", "count": 400, "share": 0.4},
            ],
        }
        features["execution"]["dynamic_instructions"] = 1004
        result, errors = validate_measurement(
            self.row, features, unmatched_tolerance=0.005
        )
        self.assertEqual(errors, [])
        self.assertEqual(result["matched"], 1000)

    def test_kernel_may_allow_unattributed_footprint_scaffolding(self):
        self.row["kernels"][0]["max_unattributed_instruction_share"] = 0.1
        features = self.features(overhead=50)
        _, errors = validate_measurement(self.row, features)
        self.assertEqual(errors, [])


if __name__ == "__main__":
    unittest.main()
