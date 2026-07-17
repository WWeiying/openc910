#!/usr/bin/env python3
import unittest

from spec_flow.check_profile_quality import (
    module_unresolved_percent,
    quality_for,
    unknown_percent,
)


class ProfileQualityTest(unittest.TestCase):
    def manifest(self, module_map, unknown):
        return {
            "validation": {"module_map_done": module_map},
            "global_top_functions": [
                {"function": "[external-or-unknown]", "percent": unknown}
            ],
            "simpoints": [
                {
                    "weight": 0.75,
                    "top_functions": [
                        {"function": "[external-or-unknown]", "percent": unknown}
                    ],
                },
                {
                    "weight": 0.25,
                    "top_functions": [
                        {"function": "known", "percent": 100.0}
                    ],
                },
            ],
        }

    def test_legacy_is_explicit(self):
        self.assertEqual(quality_for(self.manifest(False, 1.0))[3], "legacy")

    def test_weighted_thresholds(self):
        self.assertEqual(quality_for(self.manifest(True, 4.0))[3], "high")
        self.assertEqual(quality_for(self.manifest(True, 20.0))[3], "medium")
        self.assertEqual(quality_for(self.manifest(True, 40.0))[3], "low")

    def test_module_known_but_symbol_unresolved_is_reported_separately(self):
        items = [
            {"function": "[module:libgfortran.so:unresolved]", "percent": 42.0}
        ]
        self.assertEqual(unknown_percent(items), 0.0)
        self.assertEqual(module_unresolved_percent(items), 42.0)


if __name__ == "__main__":
    unittest.main()
