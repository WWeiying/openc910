#!/usr/bin/env python3
import csv
import tempfile
import unittest
from pathlib import Path

from spec_flow.build_cluster_composition_specs import (
    build_case,
    load_profile,
    select_profile,
)


class BuildClusterCompositionSpecsTest(unittest.TestCase):
    def make_profile(self):
        temporary = tempfile.TemporaryDirectory()
        path = Path(temporary.name) / "profile.csv"
        with path.open("w", newline="") as stream:
            writer = csv.writer(stream)
            writer.writerow(
                ["scope", "interval", "cluster", "weight", "function", "count", "percent"]
            )
            writer.writerow(["simpoint", 10, 0, 0.25, "a", 75, 75])
            writer.writerow(["simpoint", 10, 0, 0.25, "shared", 25, 25])
            writer.writerow(["simpoint", 20, 1, 0.75, "b", 50, 50])
            writer.writerow(["simpoint", 20, 1, 0.75, "shared", 50, 50])
        self.addCleanup(temporary.cleanup)
        return path

    def test_builds_weighted_semantic_groups(self):
        path = self.make_profile()
        result = build_case(
            "case", "bench", [("both", "mixed", [0, 1])], path
        )
        self.assertEqual(result["calibration"], "simpoint-single-group")
        self.assertAlmostEqual(result["groups"][0]["target_weight"], 1.0)
        top = result["groups"][0]["top_functions"]
        self.assertEqual(top[0]["name"], "shared")
        self.assertAlmostEqual(top[0]["share_within_group"], 0.4375)

    def test_rejects_missing_cluster(self):
        path = self.make_profile()
        with self.assertRaisesRegex(ValueError, "do not match"):
            build_case("case", "bench", [("one", "a", [0])], path)

    def test_rejects_duplicate_cluster(self):
        path = self.make_profile()
        with self.assertRaisesRegex(ValueError, "multiple groups"):
            build_case(
                "case", "bench", [("one", "a", [0]), ("two", "b", [0, 1])], path
            )

    def test_load_rejects_empty_profile(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        path = Path(temporary.name) / "empty.csv"
        path.write_text("scope,interval,cluster,weight,function,count,percent\n")
        with self.assertRaisesRegex(ValueError, "no simpoint rows"):
            load_profile(path)

    def test_profile_selection_prefers_ref_over_benchmark_local_fallback(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name)
        train = (
            root / "638.imagick_s_train_c910"
            / "638.imagick_s_train.function_profile.csv"
        )
        train.parent.mkdir()
        train.write_text("train\n")

        path, size = select_profile(
            root, "spec_638_imagick_speed_kernel", "638.imagick_s"
        )
        self.assertEqual((path, size), (train, "train"))

        ref = (
            root / "638.imagick_s_ref_c910"
            / "638.imagick_s_ref.function_profile.csv"
        )
        ref.parent.mkdir()
        ref.write_text("ref\n")
        path, size = select_profile(
            root, "spec_638_imagick_speed_kernel", "638.imagick_s"
        )
        self.assertEqual((path, size), (ref, "ref"))


if __name__ == "__main__":
    unittest.main()
