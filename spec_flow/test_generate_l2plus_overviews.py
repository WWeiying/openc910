import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.generate_l2plus_overviews import (
    collect_mapping_rows,
    render_representative_document,
    render_status_document,
    validate_final_evidence,
)


COMMIT = "1" * 40


def make_inputs():
    profiles = {"cases": {}}

    def make_map(prefix, count):
        rows = []
        for index in range(count):
            benchmark = f"{500 + index}.{prefix}_{index}"
            case = f"spec_{prefix}_{index}_kernel"
            rows.append(
                {
                    "bench": benchmark,
                    "calibration": {"size": "ref"},
                    "kernels": [
                        {
                            "case": case,
                            "weight": 1.0,
                            "clusters": [{"id": 0}, {"id": 1}],
                            "composition": [
                                {
                                    "name": "phase_a",
                                    "clusters": [0],
                                    "target_weight": 0.6,
                                    "measured_instruction_share_by_profile": {
                                        "quick": 0.601,
                                        "full": 0.599,
                                    },
                                },
                                {
                                    "name": "phase_b",
                                    "clusters": [1],
                                    "target_weight": 0.4,
                                    "measured_instruction_share_by_profile": {
                                        "quick": 0.399,
                                        "full": 0.401,
                                    },
                                },
                            ],
                        }
                    ],
                }
            )
            profiles["cases"][case] = {
                "benchmarks": [benchmark],
                "profiles": {
                    "quick": {
                        "metrics": {
                            "dynamic_instructions": {
                                "measured": 20_000 + index
                            }
                        }
                    },
                    "full": {
                        "metrics": {
                            "dynamic_instructions": {
                                "measured": 500_000 + index
                            },
                            "working_set_bytes_64B_lines": {
                                "measured": 131_072 + 64 * index
                            },
                        }
                    },
                },
            }
        return {"calibration_size": "ref", "benchmarks": rows}

    return make_map("rate", 23), make_map("speed", 20), profiles


def write_info(path, values):
    path.write_text("".join(f"{key}={value}\n" for key, value in values.items()))


class GenerateL2PlusOverviewsTests(unittest.TestCase):
    def test_collects_43_distinct_ref_composites(self):
        rate, speed, profiles = make_inputs()
        rows = collect_mapping_rows(rate, speed, profiles)

        self.assertEqual(len(rows), 43)
        self.assertEqual(len({row.case for row in rows}), 43)
        self.assertTrue(all(row.source_profile == "ref" for row in rows))
        self.assertTrue(all(row.cluster_count == 2 for row in rows))
        self.assertAlmostEqual(max(row.full_error_pp for row in rows), 0.1)

    def test_rejects_cross_suite_case_sharing(self):
        rate, speed, profiles = make_inputs()
        speed["benchmarks"][0]["kernels"][0]["case"] = (
            rate["benchmarks"][0]["kernels"][0]["case"]
        )

        with self.assertRaisesRegex(ValueError, "duplicate or missing case"):
            collect_mapping_rows(rate, speed, profiles)

    def test_validates_evidence_and_renders_current_only_documents(self):
        rate, speed, profiles = make_inputs()
        rows = collect_mapping_rows(rate, speed, profiles)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            rtl = root / "rtl"
            quick = root / "quick"
            full = root / "full"
            for path in (rtl, quick / "cases", full / "cases"):
                path.mkdir(parents=True)

            write_info(
                rtl / "run.info",
                {
                    "git_commit": COMMIT,
                    "git_dirty": "clean",
                    "kernel_profile": "full",
                    "composite_profile": "full",
                    "program_features": "on",
                    "perf_detail_compiled": "on",
                },
            )
            expected = {row.case: row for row in rows}
            for case, row in expected.items():
                (rtl / f"{case}.run_case.report").write_text("TEST PASS\n")
                for profile, feature_root, instructions in (
                    ("quick", quick, row.quick_instructions),
                    ("full", full, row.full_instructions),
                ):
                    case_root = feature_root / "cases" / case
                    case_root.mkdir()
                    (case_root / "features.json").write_text(
                        json.dumps(
                            {
                                "case": case,
                                "profile": {"kernel_profile": profile},
                                "execution": {
                                    "dynamic_instructions": instructions
                                },
                                "memory": {
                                    "working_set_bytes_64B_lines": (
                                        row.full_working_set
                                    )
                                },
                            }
                        )
                    )
            for profile, feature_root in (("quick", quick), ("full", full)):
                write_info(
                    feature_root / "run.info",
                    {
                        "git_commit": COMMIT,
                        "git_state": "clean",
                        "kernel_profile": profile,
                    },
                )

            status = root / "status.md"
            status.write_text("L2+ SimPoint strict 总进度：129/129（100.0%）。\n")
            validation = root / "validation.md"
            validation.write_text(
                "验收汇总：SimPoint=129/129，provenance=129/129，错误=0。\n"
                "- Passed: 43/43\n"
                "- ELF/retired/detail passed: 43/43\n"
            )

            commit = validate_final_evidence(
                rows, rtl, quick, full, status, validation
            )
            representative = render_representative_document(rows, commit)
            state = render_status_document(
                rows, commit, "rtl", "quick", "full"
            )

            self.assertEqual(commit, COMMIT)
            self.assertIn("43 / 43", representative)
            self.assertIn("500.rate_0", representative)
            self.assertIn("129/129", state)
            self.assertIn("full RTL TEST PASS | 43/43", state)
            self.assertNotIn("63/129", state)
            self.assertNotIn("旧 split-kernel", state)


if __name__ == "__main__":
    unittest.main()
