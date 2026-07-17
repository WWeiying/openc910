import json
import tempfile
import unittest
from pathlib import Path

from spec_flow.validate_l2plus import (
    REQUIRED_ARTIFACTS,
    REQUIRED_LOGS,
    sha256_file,
    validate_manifest,
    validate_map,
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
                            {"cluster": 0, "interval": 7, "weight": 1.0}
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
                                        "clusters": [{"id": 0, "interval": 7}],
                                    }
                                ],
                                "calibration": {
                                    "size": "ref",
                                    "method": "simpoint_cluster_groups",
                                    "mapping_complete": True,
                                    "manifest_sha256": digest,
                                    "clusters": 1,
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


if __name__ == "__main__":
    unittest.main()
