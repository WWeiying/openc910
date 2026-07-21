import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.validate_l2plus import (
    REQUIRED_ARTIFACTS,
    REQUIRED_LOGS,
    MANIFEST_FILE_NAMES,
    sha256_file,
    validate_feature_results,
    validate_manifest,
    validate_map,
    validate_cross_map_case_sets,
    validate_rtl_results,
)


class ValidateManifestTests(unittest.TestCase):
    def make_manifest(self, root):
        bench = "505.mcf_r"
        size = "ref"
        stem = f"{bench}_{size}"
        for suffix in REQUIRED_ARTIFACTS:
            path = root / f"{stem}{suffix}"
            path.write_text("data\n")
        (root / f"{stem}.bb.map").write_text("1 0x1555d80010 4\n")
        (root / f"{stem}.bb.modules").write_text(
            "cmd_index\tbase\tend\telf\tmodule\n"
            "0\t0x1555d80000\t0x1555d81000\t/lib/libc.so\tlibc.so\n"
        )
        (root / f"{stem}.bb.cmdmap").write_text(
            "cmd_index\tstart_id\tend_id\telf\tcommand\n"
            "0\t1\t1\t/main.elf\t/main.elf\n"
        )
        for name in REQUIRED_LOGS:
            (root / name).write_text("ok\n")
        (root / f"{stem}.function_profile.csv").write_text(
            "scope,cluster,interval,function,count,percent\n"
            "global,,,master,10,100.0\n"
            "simpoint,0,0,master,10,100.0\n"
        )
        manifest = {
            "bench": bench,
            "size": size,
            "interval": 100_000_000,
            "max_k": 5,
            "collection": {
                "skip_intervals": 0,
                "max_intervals": None,
                "full_program": True,
                "bbv_id_stride": 1 << 40,
            },
            "optimize": "-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910 -fcommon",
            "qemu_cpu": "c910",
            "qemu_reserved_va": "0x4000000000",
            "module_map_method": "fixed_va",
            "bbv_type": "qemu_tb_instruction_weighted",
            "provenance": {
                "git_commit": "1" * 40,
                "qemu_path": "/qemu",
                "qemu_version": "qemu 8",
                "compiler_path": "/gcc",
                "compiler_version": "gcc 14",
                "simpoint_path": "/simpoint",
            },
            "counts": {
                "bbv_intervals": 2,
                "mapped_blocks": 1,
                "mapped_modules": 1,
            },
            "files": {
                key: str(root / name_builder(stem))
                for key, name_builder in MANIFEST_FILE_NAMES.items()
            },
            "validation": {
                "compare_pass": True,
                "simpoint_done": True,
                "module_map_done": True,
            },
            "simpoints": [
                {
                    "cluster": 0,
                    "interval": 0,
                    "weight": 1.0,
                    "top_functions": [],
                }
            ],
        }
        path = root / "manifest.json"
        path.write_text(json.dumps(manifest))
        return path

    def test_accepts_complete_full_program_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = self.make_manifest(Path(tmp))
            result = validate_manifest(path, "505.mcf_r", "ref", 0.002)
            self.assertTrue(result["valid"], result["issues"])
            self.assertTrue(result["module_map"])

    def test_rejects_truncated_or_legacy_module_collection(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = self.make_manifest(Path(tmp))
            manifest = json.loads(path.read_text())
            manifest["collection"] = {
                "skip_intervals": 5,
                "max_intervals": 10,
                "full_program": False,
            }
            manifest["validation"]["module_map_done"] = False
            path.write_text(json.dumps(manifest))
            result = validate_manifest(path, "505.mcf_r", "ref", 0.002)
            self.assertFalse(result["valid"])
            self.assertIn("collection is not marked full_program", result["issues"])
            self.assertIn("guest module map not complete", result["issues"])

    def test_rejects_stale_manifest_file_parent(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = self.make_manifest(Path(tmp))
            manifest = json.loads(path.read_text())
            manifest["files"]["bbv"] = "/work/spec_runs/stale/case.bb"
            path.write_text(json.dumps(manifest))
            result = validate_manifest(path, "505.mcf_r", "ref", 0.002)
            self.assertFalse(result["valid"])
            self.assertTrue(
                any(
                    issue.startswith("manifest files.bbv parent=stale")
                    for issue in result["issues"]
                )
            )

    def test_accepts_recovered_aslr_module_provenance(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = self.make_manifest(Path(tmp))
            manifest = json.loads(path.read_text())
            manifest["qemu_reserved_va"] = None
            manifest["module_map_method"] = "aslr_slide_recovered"
            path.write_text(json.dumps(manifest))
            result = validate_manifest(path, "505.mcf_r", "ref", 0.002)
            self.assertTrue(result["valid"], result["issues"])

    def test_rejects_module_ranges_that_do_not_overlap_trace(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = self.make_manifest(root)
            (root / "505.mcf_r_ref.bb.modules").write_text(
                "cmd_index\tbase\tend\telf\tmodule\n"
                "0\t0x7f0000000000\t0x7f0000001000\t/lib/libc.so\tlibc.so\n"
            )
            result = validate_manifest(path, "505.mcf_r", "ref", 0.002)
            self.assertFalse(result["valid"])
            self.assertIn("guest module ranges do not overlap BBV PCs", result["issues"])

    def test_rejects_duplicate_block_ids_from_multi_command_collection(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            path = self.make_manifest(root)
            (root / "505.mcf_r_ref.bb.map").write_text(
                "1 0x1555d80010 4\n1 0x1555d80020 4\n"
            )
            manifest = json.loads(path.read_text())
            manifest["counts"]["mapped_blocks"] = 2
            path.write_text(json.dumps(manifest))
            result = validate_manifest(path, "505.mcf_r", "ref", 0.002)
            self.assertFalse(result["valid"])
            self.assertTrue(
                any(issue.startswith("duplicate BBV map IDs") for issue in result["issues"])
            )

    def test_map_ref_calibration_is_bound_to_manifest_digest(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            spec_runs = root / "spec_runs"
            manifest = spec_runs / "example_r_ref_c910" / "manifest.json"
            manifest.parent.mkdir(parents=True)
            manifest.write_text(
                json.dumps(
                    {
                        "simpoints": [
                            {"cluster": 0, "interval": 7, "weight": 0.6},
                            {"cluster": 1, "interval": 9, "weight": 0.4},
                        ]
                    }
                )
                + "\n"
            )
            digest = sha256_file(manifest)
            case_root = root / "cases"
            case = case_root / "kernel"
            case.mkdir(parents=True)
            (case / "main.c").write_text("int main(void) { return 0; }\n")
            kernel_map = root / "map.json"
            kernel_map.write_text(
                json.dumps(
                    {
                        "default_size": "ref",
                        "calibration_size": "ref",
                        "calibration": {
                            "method": "ref_simpoint_cluster_groups_v2",
                            "size": "ref",
                            "manifest_sha256": {"example_r": digest},
                        },
                        "benchmarks": [
                            {
                                "bench": "example_r",
                                "kernels": [
                                    {
                                        "case": "kernel",
                                        "weight": 1.0,
                                        "coverage": "high",
                                        "clusters": [
                                            {"id": 0, "interval": 7},
                                            {"id": 1, "interval": 9},
                                        ],
                                        "composition": [
                                            {
                                                "name": "a",
                                                "clusters": [0],
                                                "target_weight": 0.6,
                                                "measured_instruction_share_by_profile": {
                                                    "quick": 0.6,
                                                    "full": 0.6
                                                },
                                            },
                                            {
                                                "name": "b",
                                                "clusters": [1],
                                                "target_weight": 0.4,
                                                "measured_instruction_share_by_profile": {
                                                    "quick": 0.4,
                                                    "full": 0.4
                                                },
                                            },
                                        ],
                                    }
                                ],
                                "calibration": {
                                    "size": "ref",
                                    "method": "simpoint_cluster_groups",
                                    "mapping_complete": True,
                                    "manifest_sha256": digest,
                                    "clusters": 2,
                                    "matched_profile_weight": 1.0,
                                },
                            }
                        ],
                    }
                )
            )
            _, _, _, errors = validate_map(
                kernel_map, ["example_r"], case_root, spec_runs
            )
            self.assertEqual(errors, [])

            manifest.write_text('{"changed": true}\n')
            _, _, _, errors = validate_map(
                kernel_map, ["example_r"], case_root, spec_runs
            )
            self.assertIn("stale row calibration manifest for example_r", errors)
            self.assertIn("stale map calibration manifest for example_r", errors)

    def test_map_requires_two_or_three_groups_and_both_profile_measurements(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            spec_runs = root / "spec_runs"
            manifest = spec_runs / "example_r_ref_c910" / "manifest.json"
            manifest.parent.mkdir(parents=True)
            manifest.write_text(
                json.dumps(
                    {
                        "simpoints": [
                            {"cluster": 0, "interval": 7, "weight": 0.5},
                            {"cluster": 1, "interval": 9, "weight": 0.5},
                        ]
                    }
                )
            )
            digest = sha256_file(manifest)
            case_root = root / "cases"
            (case_root / "kernel").mkdir(parents=True)
            (case_root / "kernel" / "main.c").write_text("int main(void){}\n")
            groups = [
                {
                    "name": name,
                    "clusters": [cluster],
                    "target_weight": 0.5,
                    "measured_instruction_share_by_profile": {
                        "quick": 0.5,
                        "full": 0.5,
                    },
                }
                for name, cluster in (("a", 0), ("b", 1))
            ]
            data = {
                "default_size": "ref",
                "calibration_size": "ref",
                "calibration": {
                    "method": "ref_simpoint_cluster_groups_v2",
                    "size": "ref",
                    "manifest_sha256": {"example_r": digest},
                },
                "benchmarks": [
                    {
                        "bench": "example_r",
                        "kernels": [
                            {
                                "case": "kernel",
                                "weight": 1.0,
                                "coverage": "high",
                                "clusters": [
                                    {"id": 0, "interval": 7},
                                    {"id": 1, "interval": 9},
                                ],
                                "composition": groups,
                            }
                        ],
                        "calibration": {
                            "size": "ref",
                            "method": "simpoint_cluster_groups",
                            "manifest_sha256": digest,
                            "clusters": 2,
                            "matched_profile_weight": 1.0,
                        },
                    }
                ],
            }
            kernel_map = root / "map.json"
            kernel_map.write_text(json.dumps(data))
            _, _, _, errors = validate_map(
                kernel_map, ["example_r"], case_root, spec_runs
            )
            self.assertEqual(errors, [])

            del groups[0]["measured_instruction_share_by_profile"]["quick"]
            kernel_map.write_text(json.dumps(data))
            _, _, _, errors = validate_map(
                kernel_map, ["example_r"], case_root, spec_runs
            )
            self.assertTrue(
                any("missing a valid quick measured" in error for error in errors),
                errors,
            )

            groups[0]["measured_instruction_share_by_profile"]["quick"] = 0.5
            groups.extend(
                [
                    {
                        "name": "c",
                        "clusters": [0],
                        "target_weight": 0.0,
                        "measured_instruction_share_by_profile": {
                            "quick": 0.0,
                            "full": 0.0,
                        },
                    },
                    {
                        "name": "d",
                        "clusters": [1],
                        "target_weight": 0.0,
                        "measured_instruction_share_by_profile": {
                            "quick": 0.0,
                            "full": 0.0,
                        },
                    },
                ]
            )
            kernel_map.write_text(json.dumps(data))
            _, _, _, errors = validate_map(
                kernel_map, ["example_r"], case_root, spec_runs
            )
            self.assertTrue(
                any("exactly two or three" in error for error in errors),
                errors,
            )

    def test_cross_map_case_sets_must_be_43_distinct_cases(self):
        errors = validate_cross_map_case_sets(
            {"rate": {"rate_a", "shared"}, "speed": {"speed_a", "shared"}},
            4,
        )
        self.assertIn(
            "composite case shared is shared across rate and speed maps",
            errors,
        )
        self.assertIn("mapped unique composite cases=3, expected=4", errors)

    def test_rtl_results_require_pass_and_detailed_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "run.info").write_text(
                "git_commit=abc\ngit_branch=main\ngit_dirty=false\n"
                "bench_cases=kernel\n"
            )
            for suffix in (
                ".run_case.report",
                ".summary.txt",
                ".perf",
                ".detail.perf",
                ".run.vcs.log",
                ".asm",
                ".elf",
                ".symbols.args",
            ):
                (root / f"kernel{suffix}").write_text("data\n")
            (root / "kernel.run_case.report").write_text("TEST PASS\n")
            (root / "kernel.summary.txt").write_text("|     Kernel    | 10 |\n")
            (root / "kernel.perf").write_text("|     Kernel    | 10 |\n")
            (root / "kernel.detail.perf").write_text(
                "Detailed Performance Statistics\n"
            )
            passed, errors = validate_rtl_results(root, {"kernel"})
            self.assertEqual(passed, 1)
            self.assertEqual(errors, [])

            (root / "kernel.run_case.report").write_text("TEST FAIL\n")
            passed, errors = validate_rtl_results(root, {"kernel"})
            self.assertEqual(passed, 0)
            self.assertIn("kernel: RTL report is not TEST PASS", errors)

    def test_strict_rtl_provenance_requires_clean_full_run(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "run.info").write_text(
                f"git_commit={'a' * 40}\ngit_branch=main\ngit_dirty=dirty\n"
                "bench_cases=kernel\nkernel_profile=quick\n"
            )
            passed, errors = validate_rtl_results(
                root,
                {"kernel"},
                require_clean=True,
                required_profile="full",
            )
            self.assertEqual(passed, 0)
            self.assertIn(
                "RTL run.info git_dirty=dirty, expected clean", errors
            )
            self.assertIn(
                "RTL run.info kernel_profile=quick, expected full", errors
            )

    def test_strict_rtl_provenance_binds_compile_log_and_simv(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            compile_log = root / "comp.vcs.log"
            compile_log.write_text("vcs +define+PERF_DETAIL\n")
            archived_simv = root / "simv"
            archived_simv.write_bytes(b"compiled simulator")
            daidir = root / "simv.daidir"
            daidir.mkdir()
            archive = daidir / "_archive_1.so"
            archive.write_bytes(b"generated shared library")
            daidir_manifest = root / "simv.daidir.sha256"
            daidir_manifest.write_text(
                f"{sha256_file(archive)}  simv.daidir/{archive.name}\n"
            )
            (root / "run.info").write_text(
                f"git_commit={'a' * 40}\ngit_branch=main\ngit_dirty=clean\n"
                "bench_cases=kernel\nkernel_profile=full\n"
                f"simv_sha256={sha256_file(archived_simv)}\n"
                f"simv_daidir_manifest_sha256={sha256_file(daidir_manifest)}\n"
                f"compile_log_sha256={sha256_file(compile_log)}\n"
                "perf_detail_compiled=on\n"
            )
            (root / "git.status").write_text("")
            (root / "git.diff").write_text("")

            _, errors = validate_rtl_results(
                root,
                {"kernel"},
                require_clean=True,
                required_profile="full",
            )
            self.assertFalse(
                any("simv_sha256" in error for error in errors), errors
            )
            self.assertFalse(
                any("comp.vcs.log" in error for error in errors), errors
            )
            self.assertFalse(
                any("perf_detail_compiled" in error for error in errors),
                errors,
            )

            compile_log.write_text("tampered\n")
            _, errors = validate_rtl_results(
                root,
                {"kernel"},
                require_clean=True,
                required_profile="full",
            )
            self.assertIn("RTL comp.vcs.log SHA256 mismatch", errors)

            archived_simv.write_bytes(b"tampered simulator")
            _, errors = validate_rtl_results(
                root,
                {"kernel"},
                require_clean=True,
                required_profile="full",
            )
            self.assertIn("archived RTL simv SHA256 mismatch", errors)

            archive.write_bytes(b"tampered generated shared library")
            _, errors = validate_rtl_results(
                root,
                {"kernel"},
                require_clean=True,
                required_profile="full",
            )
            self.assertTrue(
                any("simv.daidir file SHA256 mismatch" in error for error in errors),
                errors,
            )

    def make_feature_results(self, root, profile="full", state="clean"):
        case = "kernel"
        commit = "a" * 40
        trace_profile = "representative" if profile == "full" else "rtl"
        (root / "run.info").write_text(
            f"git_commit={commit}\ngit_state={state}\n"
            f"profile={trace_profile}\nkernel_profile={profile}\n"
            f"composite_profile={profile}\ncases={case}\n"
        )
        (root / "git.status").write_text("")
        (root / "git.diff").write_text("")
        case_dir = root / "cases" / case
        case_dir.mkdir(parents=True)
        elf = case_dir / f"{case}.elf"
        elf.write_bytes(b"feature-elf")
        (case_dir / "features.json").write_text(
            json.dumps(
                {
                    "case": case,
                    "profile": {"kernel_profile": profile},
                    "provenance": {"elf_sha256": sha256_file(elf)},
                    "validation": {"passed": True},
                    "execution": {"dynamic_instructions": 1234},
                }
            )
        )
        return case, commit

    def test_strict_feature_results_require_clean_matching_commit_and_elf(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            case, commit = self.make_feature_results(root)
            passed, errors = validate_feature_results(
                root,
                {case},
                "full",
                require_clean=True,
                required_commit=commit,
            )
            self.assertEqual(passed, 1)
            self.assertEqual(errors, [])

            (root / "cases" / case / f"{case}.elf").write_bytes(b"changed")
            passed, errors = validate_feature_results(
                root,
                {case},
                "full",
                require_clean=True,
                required_commit=commit,
            )
            self.assertEqual(passed, 0)
            self.assertIn(
                f"{case}: archived feature ELF SHA256 mismatch", errors
            )

    def test_strict_feature_results_reject_dirty_or_inexact_case_set(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            case, commit = self.make_feature_results(root, state="dirty")
            passed, errors = validate_feature_results(
                root,
                {case, "missing"},
                "full",
                require_clean=True,
                required_commit="b" * 40,
            )
            self.assertEqual(passed, 1)
            self.assertIn(
                "program-feature run.info git_state=dirty, expected clean", errors
            )
            self.assertIn(
                f"program-feature git_commit={commit}, "
                f"expected RTL commit {'b' * 40}",
                errors,
            )
            self.assertIn(
                "program-feature reports miss: missing", errors
            )


if __name__ == "__main__":
    unittest.main()
