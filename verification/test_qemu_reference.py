#!/usr/bin/env python3

import json
import tempfile
import unittest
from pathlib import Path

from qemu_reference import (
    GPR_NAMES,
    TERMINATION_PROTOCOL_GPRS,
    ReferenceError,
    compare_reference,
)


class QemuReferenceComparisonTest(unittest.TestCase):
    def create_fixture(self, root: Path, mismatch: bool = False) -> tuple[Path, Path]:
        rtl = root / "rtl_case"
        reference = root / "reference_case"
        rtl.mkdir()
        reference.mkdir()
        (rtl / "result.json").write_text('{"status": "PASS"}\n')
        (rtl / "stage.json").write_text('{"elf_sha256": "same"}\n')
        rtl_registers = {
            name: f"0x{index:016x}" for index, name in enumerate(GPR_NAMES)
        }
        rtl_state = {
            "format": "openc910-rtl-arch-state-v1",
            "status": "PASS",
            "detection_cycle": 100,
            "retired_instructions": 10,
            "registers": rtl_registers,
        }
        (rtl / "rtl_arch_state.json").write_text(json.dumps(rtl_state))
        registers = {
            name: f"0x{index:016x}" for index, name in enumerate(GPR_NAMES)
        }
        registers["fp"] = registers.pop("s0")
        if mismatch:
            registers["t0"] = "0xffffffffffffffff"
        state = {
            "format": "openc910-qemu-arch-state-v1",
            "status": "PASS",
            "terminal_pc": "0x14",
            "executed_instructions": 10,
            "registers": registers,
        }
        (reference / "qemu_arch_state.json").write_text(json.dumps(state))
        result = {
            "format": "openc910-qemu-reference-result-v1",
            "status": "PASS",
            "elf_sha256": "same",
        }
        (reference / "qemu_result.json").write_text(json.dumps(result))
        return rtl, reference

    def test_matching_known_gprs_pass(self):
        with tempfile.TemporaryDirectory() as temporary:
            rtl, reference = self.create_fixture(Path(temporary))
            report = compare_reference(rtl, reference)
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(
                report["coverage"]["compared_integer_register_count"],
                len(GPR_NAMES) - len(TERMINATION_PROTOCOL_GPRS),
            )
            self.assertEqual(report["mismatches"], [])

    def test_termination_protocol_register_mismatch_is_reported_as_ignored(self):
        with tempfile.TemporaryDirectory() as temporary:
            rtl, reference = self.create_fixture(Path(temporary))
            state_path = reference / "qemu_arch_state.json"
            state = json.loads(state_path.read_text())
            state["registers"]["ra"] = "0xffffffffffffffff"
            state_path.write_text(json.dumps(state))
            report = compare_reference(rtl, reference)
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(
                set(report["coverage"]["ignored_termination_protocol_registers"]),
                TERMINATION_PROTOCOL_GPRS,
            )

    def test_register_mismatch_fails(self):
        with tempfile.TemporaryDirectory() as temporary:
            rtl, reference = self.create_fixture(Path(temporary), mismatch=True)
            report = compare_reference(rtl, reference)
            self.assertEqual(report["status"], "FAIL")
            self.assertEqual(report["mismatches"][0]["register"], "t0")

    def test_different_elf_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            rtl, reference = self.create_fixture(Path(temporary))
            result_path = reference / "qemu_result.json"
            result = json.loads(result_path.read_text())
            result["elf_sha256"] = "different"
            result_path.write_text(json.dumps(result))
            with self.assertRaisesRegex(ReferenceError, "same ELF"):
                compare_reference(rtl, reference)

    def test_missing_authoritative_rtl_snapshot_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            rtl, reference = self.create_fixture(Path(temporary))
            (rtl / "rtl_arch_state.json").unlink()
            with self.assertRaisesRegex(ReferenceError, "rtl_arch_state.json"):
                compare_reference(rtl, reference)

    def test_only_unknown_rtl_register_is_ignored(self):
        with tempfile.TemporaryDirectory() as temporary:
            rtl, reference = self.create_fixture(Path(temporary))
            state_path = rtl / "rtl_arch_state.json"
            state = json.loads(state_path.read_text())
            state["registers"]["t6"] = "0x" + ("x" * 16)
            state_path.write_text(json.dumps(state))
            report = compare_reference(rtl, reference)
            self.assertEqual(report["status"], "PASS")
            self.assertEqual(
                report["coverage"]["compared_integer_register_count"],
                len(GPR_NAMES) - len(TERMINATION_PROTOCOL_GPRS) - 1,
            )
            self.assertEqual(report["coverage"]["ignored_rtl_unknown_registers"], ["t6"])


if __name__ == "__main__":
    unittest.main()
