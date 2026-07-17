import tempfile
import unittest
from pathlib import Path

from spec_flow.check_completed_bbv import validate_completed_bbv


class CompletedBbvTests(unittest.TestCase):
    def make_artifacts(self, root):
        bbv = root / "case.bb"
        bbv_map = root / "case.bb.map"
        cmdmap = root / "case.bb.cmdmap"
        modules = root / "case.bb.modules"
        bbv.write_text("T :1:10 :2:20\n")
        bbv_map.write_text("1 0x1000 4\n2 0x2000 3\n")
        cmdmap.write_text(
            "cmd_index\tstart_id\tend_id\telf\tcommand\n"
            "0\t1\t2\t/tmp/a\t./a\n"
        )
        modules.write_text(
            "cmd_index\tstart\tend\tpath\tmethod\n"
            "0\t0x1000\t0x3000\t/tmp/a\tfixed_va\n"
        )
        return bbv, bbv_map, cmdmap, modules

    def test_accepts_complete_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            paths = self.make_artifacts(Path(tmp))
            self.assertEqual(validate_completed_bbv(*paths, 1), [])

    def test_rejects_missing_expected_command(self):
        with tempfile.TemporaryDirectory() as tmp:
            paths = self.make_artifacts(Path(tmp))
            errors = validate_completed_bbv(*paths, 2)
            self.assertIn("cmdmap commands=1 expected=2", errors)
            self.assertIn("module map misses commands: 1", errors)

    def test_rejects_duplicate_map_ids(self):
        with tempfile.TemporaryDirectory() as tmp:
            paths = self.make_artifacts(Path(tmp))
            paths[1].write_text("1 0x1000 4\n1 0x2000 3\n")
            errors = validate_completed_bbv(*paths, 1)
            self.assertIn("BBV map contains duplicate IDs", errors)


if __name__ == "__main__":
    unittest.main()
