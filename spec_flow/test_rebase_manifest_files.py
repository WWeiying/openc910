import unittest

from spec_flow.rebase_manifest_files import rebase_manifest_files


class RebaseManifestFilesTests(unittest.TestCase):
    def test_rebases_every_file_parent(self):
        manifest = {
            "files": {
                "bbv": "/work/spec_runs/case_staged/case.bb",
                "log": "/work/spec_runs/case_staged/run.log",
            }
        }
        result = rebase_manifest_files(manifest, "case_staged", "case")
        self.assertEqual(
            result["files"]["bbv"], "/work/spec_runs/case/case.bb"
        )
        self.assertEqual(
            result["files"]["log"], "/work/spec_runs/case/run.log"
        )
        self.assertEqual(
            manifest["files"]["bbv"],
            "/work/spec_runs/case_staged/case.bb",
        )

    def test_rejects_unexpected_source_parent(self):
        with self.assertRaisesRegex(ValueError, "expected='case_staged'"):
            rebase_manifest_files(
                {"files": {"bbv": "/work/spec_runs/other/case.bb"}},
                "case_staged",
                "case",
            )


if __name__ == "__main__":
    unittest.main()
