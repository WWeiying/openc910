import subprocess
import tempfile
import unittest
from pathlib import Path


class RunStagedRtlCaseTests(unittest.TestCase):
    def test_runs_fake_simulator_in_isolated_case_directory(self):
        repo = Path(__file__).resolve().parents[1]
        helper = repo / "smart_run" / "run_staged_rtl_case.sh"
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            case = "spec_example_kernel"
            case_dir = root / "stage" / case
            case_dir.mkdir(parents=True)
            for name in (
                "case.pat",
                "inst.pat",
                "data.pat",
                "symbols.args",
                f"{case}.elf",
            ):
                (case_dir / name).write_text(
                    "+sym_main=1\n+sym_exit=2\n"
                    if name == "symbols.args"
                    else "input\n"
                )
            simulator = root / "fake-simv"
            simulator.write_text(
                "#!/usr/bin/env bash\n"
                "printf 'cwd=%s args=%s\\n' \"$PWD\" \"$*\"\n"
                "printf 'TEST PASS\\n' > run_case.report\n"
                "printf '|     Kernel    | 10 | 8 |\\n' > run.vcs.log\n"
            )
            simulator.chmod(0o755)

            completed = subprocess.run(
                [
                    "bash",
                    str(helper),
                    str(simulator),
                    str(root / "stage"),
                    case,
                ],
                text=True,
                capture_output=True,
            )

            self.assertEqual(completed.returncode, 0, completed.stderr)
            self.assertEqual(
                (case_dir / "run_case.report").read_text(), "TEST PASS\n"
            )
            console = (case_dir / "simv.console.log").read_text()
            self.assertIn(f"cwd={case_dir}", console)
            self.assertIn(
                "-l run.vcs.log +sym_main=1 +sym_exit=2", console
            )
            self.assertEqual(
                (case_dir / "simv.exit").read_text(), "simv_exit=0\n"
            )


if __name__ == "__main__":
    unittest.main()
