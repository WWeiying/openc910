#!/usr/bin/env python3
import unittest

from spec_flow.aggregate_rtl_by_simpoint import (
    resolve_kernel_weights,
    validate_embedded_composition,
)


class ResolveKernelWeightsTest(unittest.TestCase):
    def test_configured_weights(self):
        row = {
            "bench": "example",
            "kernels": [
                {"case": "a", "weight": 0.25},
                {"case": "b", "weight": 0.75},
            ],
        }
        weights, source = resolve_kernel_weights(row, None)
        self.assertEqual(weights, [0.25, 0.75])
        self.assertEqual(source, "configured")

    def test_single_kernel_is_labeled_single_proxy(self):
        row = {
            "bench": "example",
            "kernels": [{"case": "proxy", "weight": 1.0}],
        }
        weights, source = resolve_kernel_weights(row, None)
        self.assertEqual(weights, [1.0])
        self.assertEqual(source, "single_proxy")

    def test_simpoint_cluster_groups(self):
        row = {
            "bench": "example",
            "kernels": [
                {
                    "case": "sort",
                    "clusters": [{"id": 0, "interval": 10}],
                },
                {
                    "case": "scan",
                    "clusters": [{"id": 1, "interval": 20}],
                },
            ],
        }
        manifest = {
            "simpoints": [
                {
                    "cluster": 0,
                    "interval": 10,
                    "weight": 0.75,
                },
                {
                    "cluster": 1,
                    "interval": 20,
                    "weight": 0.25,
                },
            ]
        }
        weights, source = resolve_kernel_weights(row, manifest)
        self.assertAlmostEqual(weights[0], 0.75)
        self.assertAlmostEqual(weights[1], 0.25)
        self.assertEqual(source, "simpoint_cluster_groups")

    def test_rejects_partial_cluster_mapping(self):
        row = {
            "bench": "example",
            "kernels": [
                {"case": "a", "clusters": [0]},
                {"case": "b", "weight": 0.5},
            ],
        }
        with self.assertRaises(ValueError):
            resolve_kernel_weights(row, {"simpoints": []})

    def test_rejects_unassigned_cluster(self):
        row = {
            "bench": "example",
            "kernels": [
                {"case": "a", "clusters": [0]},
                {"case": "b", "clusters": [1]},
            ],
        }
        manifest = {
            "simpoints": [
                {"cluster": 0, "interval": 10, "weight": 0.4},
                {"cluster": 1, "interval": 20, "weight": 0.3},
                {"cluster": 2, "interval": 30, "weight": 0.3},
            ]
        }
        with self.assertRaisesRegex(ValueError, "unassigned SimPoint clusters: 2"):
            resolve_kernel_weights(row, manifest)

    def test_rejects_duplicate_cluster_assignment(self):
        row = {
            "bench": "example",
            "kernels": [
                {"case": "a", "clusters": [0]},
                {"case": "b", "clusters": [0]},
            ],
        }
        manifest = {
            "simpoints": [{"cluster": 0, "interval": 10, "weight": 1.0}]
        }
        with self.assertRaisesRegex(ValueError, "assigned to both"):
            resolve_kernel_weights(row, manifest)

    def test_rejects_changed_representative_interval(self):
        row = {
            "bench": "example",
            "kernels": [{"case": "a", "clusters": [{"id": 0, "interval": 10}]}],
        }
        manifest = {
            "simpoints": [{"cluster": 0, "interval": 11, "weight": 1.0}]
        }
        with self.assertRaisesRegex(ValueError, "representative interval changed"):
            resolve_kernel_weights(row, manifest)

    def test_rejects_stale_stored_cluster_weights(self):
        row = {
            "bench": "example",
            "kernels": [
                {"case": "a", "weight": 0.9, "clusters": [0]},
                {"case": "b", "weight": 0.1, "clusters": [1]},
            ],
        }
        manifest = {
            "simpoints": [
                {"cluster": 0, "interval": 10, "weight": 0.25},
                {"cluster": 1, "interval": 20, "weight": 0.75},
            ]
        }
        with self.assertRaisesRegex(ValueError, "stored kernel weights"):
            resolve_kernel_weights(row, manifest, verify_stored=True)

    def test_validates_embedded_composite_instruction_mix(self):
        row = {
            "bench": "example",
            "kernels": [
                {
                    "case": "composite",
                    "clusters": [0, 1],
                    "composition": [
                        {
                            "name": "a",
                            "clusters": [0],
                            "target_weight": 0.75,
                            "measured_instruction_share": 0.751,
                        },
                        {
                            "name": "b",
                            "clusters": [1],
                            "target_weight": 0.25,
                            "measured_instruction_share": 0.249,
                        },
                    ],
                }
            ],
        }
        manifest = {
            "simpoints": [
                {"cluster": 0, "interval": 10, "weight": 0.75},
                {"cluster": 1, "interval": 20, "weight": 0.25},
            ]
        }
        result = validate_embedded_composition(row, manifest)
        self.assertEqual(len(result["groups"]), 2)

    def test_rejects_uncalibrated_composite_instruction_mix(self):
        row = {
            "bench": "example",
            "kernels": [
                {
                    "case": "composite",
                    "clusters": [0, 1],
                    "composition": [
                        {
                            "name": "a",
                            "clusters": [0],
                            "target_weight": 0.75,
                            "measured_instruction_share": 0.60,
                        },
                        {
                            "name": "b",
                            "clusters": [1],
                            "target_weight": 0.25,
                            "measured_instruction_share": 0.40,
                        },
                    ],
                }
            ],
        }
        manifest = {
            "simpoints": [
                {"cluster": 0, "interval": 10, "weight": 0.75},
                {"cluster": 1, "interval": 20, "weight": 0.25},
            ]
        }
        with self.assertRaisesRegex(ValueError, "measured instruction share"):
            validate_embedded_composition(row, manifest)


if __name__ == "__main__":
    unittest.main()
