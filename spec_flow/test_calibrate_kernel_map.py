#!/usr/bin/env python3
import unittest

from spec_flow.calibrate_kernel_map import calibrate_map


class CalibrateKernelMapTest(unittest.TestCase):
    def setUp(self):
        self.manifest = {
            "simpoints": [
                {"cluster": 0, "interval": 10, "weight": 0.4},
                {"cluster": 1, "interval": 20, "weight": 0.6},
            ]
        }

    def calibrate(self, kernels, strict=False):
        data = {
            "benchmarks": [
                {"bench": "example", "suite": "test", "kernels": kernels}
            ]
        }
        return calibrate_map(
            data,
            {"example": self.manifest},
            {"example": "digest"},
            require_cluster_mapping=strict,
        )

    def test_intermediate_calibration_labels_single_proxy_incomplete(self):
        result = self.calibrate(
            [{"case": "proxy", "weight": 1.0, "coverage": "medium"}]
        )
        row = result["benchmarks"][0]
        self.assertEqual(row["calibration"]["method"], "single_proxy")
        self.assertFalse(row["calibration"]["mapping_complete"])

    def test_strict_calibration_rejects_single_proxy(self):
        with self.assertRaisesRegex(ValueError, "mapping is incomplete"):
            self.calibrate(
                [{"case": "proxy", "weight": 1.0, "coverage": "medium"}],
                strict=True,
            )

    def test_strict_calibration_accepts_one_complete_composite(self):
        result = self.calibrate(
            [
                {"case": "composite", "coverage": "high", "clusters": [0, 1]},
            ],
            strict=True,
        )
        row = result["benchmarks"][0]
        self.assertTrue(row["calibration"]["mapping_complete"])
        self.assertEqual([k["weight"] for k in row["kernels"]], [1.0])

    def test_strict_calibration_rejects_multiple_kernels(self):
        with self.assertRaisesRegex(ValueError, "exactly one composite"):
            self.calibrate(
                [
                    {"case": "a", "coverage": "high", "clusters": [0]},
                    {"case": "b", "coverage": "high", "clusters": [1]},
                ],
                strict=True,
            )


if __name__ == "__main__":
    unittest.main()
