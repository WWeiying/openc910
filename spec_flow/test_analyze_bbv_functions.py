#!/usr/bin/env python3
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from spec_flow.analyze_bbv_functions import (
    load_map,
    load_symbols,
    stream_function_counts,
)


class ModuleAttributionTest(unittest.TestCase):
    def test_load_symbols_accepts_defined_weak_cpp_functions(self):
        nm_output = (
            "0000000000001000 0000000000000020 W weak_template\n"
            "0000000000002000 0000000000000010 T strong_function\n"
            "                 w undefined_weak\n"
            "0000000000003000 0000000000000008 D data_object\n"
        )
        with patch(
            "spec_flow.analyze_bbv_functions.subprocess.check_output",
            return_value=nm_output,
        ) as check_output:
            symbols = load_symbols(Path("sample.elf"), "nm")
        self.assertEqual(
            symbols,
            [
                (0x1000, 0x1020, "weak_template"),
                (0x2000, 0x2010, "strong_function"),
            ],
        )
        check_output.assert_called_once()

    def test_shared_library_pc_uses_rebased_symbols(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            bbv_map = root / "sample.bb.map"
            cmdmap = root / "sample.bb.cmdmap"
            modules = root / "sample.bb.modules"
            bbv_map.write_text("1 0x1014 4\n")
            cmdmap.write_text(
                "cmd_index\tstart_id\tend_id\telf\tcommand\n"
                "0\t1\t1\t/main.elf\t/main.elf\n"
            )
            modules.write_text(
                "cmd_index\tbase\tend\telf\tmodule\n"
                "0\t0x1000\t0x2000\t/lib.so\tlib.so\n"
            )
            symbols = [(0x10, 0x20, "library_function")]
            with patch(
                "spec_flow.analyze_bbv_functions.load_symbols",
                return_value=symbols,
            ):
                functions, pcs = load_map(
                    bbv_map, [], "nm", str(cmdmap), str(modules)
                )
            self.assertEqual(pcs[1], 0x1014)
            self.assertEqual(functions[1], "library_function")

    def test_stripped_shared_library_keeps_module_attribution(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            bbv_map = root / "sample.bb.map"
            cmdmap = root / "sample.bb.cmdmap"
            modules = root / "sample.bb.modules"
            bbv_map.write_text("1 0x1014 4\n")
            cmdmap.write_text(
                "cmd_index\tstart_id\tend_id\telf\tcommand\n"
                "0\t1\t1\t/main.elf\t/main.elf\n"
            )
            modules.write_text(
                "cmd_index\tbase\tend\telf\tmodule\n"
                "0\t0x1000\t0x2000\t/libstripped.so\tlibstripped.so\n"
            )
            with patch(
                "spec_flow.analyze_bbv_functions.load_symbols",
                return_value=[],
            ):
                functions, _ = load_map(
                    bbv_map, [], "nm", str(cmdmap), str(modules)
                )
            self.assertEqual(
                functions[1], "[module:libstripped.so:unresolved]"
            )

    def test_legacy_profile_without_modules_uses_main_elf(self):
        with tempfile.TemporaryDirectory() as tmp:
            bbv_map = Path(tmp) / "sample.bb.map"
            bbv_map.write_text("1 0x114 4\n")
            functions, _ = load_map(
                bbv_map, [(0x110, 0x120, "main_function")], "nm"
            )
            self.assertEqual(functions[1], "main_function")

    def test_bbv_profile_is_aggregated_in_one_streaming_pass(self):
        with tempfile.TemporaryDirectory() as tmp:
            bbv = Path(tmp) / "sample.bb"
            bbv.write_text("T :1:3 :2:2\n\nT :1:5 :3:7\n")
            count, global_counts, selected = stream_function_counts(
                bbv,
                {1: "alpha", 2: "beta", 3: "gamma"},
                {1},
            )
            self.assertEqual(count, 2)
            self.assertEqual(global_counts["alpha"], 8)
            self.assertEqual(global_counts["beta"], 2)
            self.assertEqual(global_counts["gamma"], 7)
            self.assertEqual(selected[1]["alpha"], 5)
            self.assertEqual(selected[1]["gamma"], 7)


if __name__ == "__main__":
    unittest.main()
