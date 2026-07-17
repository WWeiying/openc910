#!/usr/bin/env python3
import unittest

from smart_run.kernel_characterize import (
    DynamicInsn,
    StaticInsn,
    analyze_composition_phases,
)


def insn(sequence, pc):
    return DynamicInsn(sequence, pc, 4, 0x13, StaticInsn(pc, 4, 0x13, "addi", "", "f"))


class KernelCharacterizePhasesTest(unittest.TestCase):
    def test_attributes_nested_function_instructions_between_markers(self):
        symbols = {
            "spec_composition_phase0_start": 0x10,
            "spec_composition_phase0_end": 0x20,
            "spec_composition_phase1_start": 0x30,
            "spec_composition_phase1_end": 0x40,
        }
        trace = [
            insn(0, 0x08), insn(1, 0x10), insn(2, 0x100),
            insn(3, 0x104), insn(4, 0x20), insn(5, 0x30),
            insn(6, 0x200), insn(7, 0x40), insn(8, 0x48),
        ]
        result = analyze_composition_phases(trace, symbols)
        self.assertEqual(result["attributed_instructions"], 3)
        self.assertEqual(result["marker_instructions"], 4)
        self.assertEqual(result["unattributed_instructions"], 2)
        self.assertAlmostEqual(result["phases"][0]["share"], 2 / 3)
        self.assertAlmostEqual(result["phases"][1]["share"], 1 / 3)

    def test_rejects_incomplete_marker_pair(self):
        with self.assertRaisesRegex(ValueError, "incomplete"):
            analyze_composition_phases(
                [insn(0, 0x10)], {"spec_composition_phase0_start": 0x10}
            )

    def test_trace_start_marker_may_be_excluded_by_plugin(self):
        symbols = {
            "spec_composition_phase0_start": 0x10,
            "spec_composition_phase0_end": 0x20,
        }
        result = analyze_composition_phases(
            [insn(1, 0x14), insn(2, 0x18), insn(3, 0x20)],
            symbols,
            trace_start=0x10,
        )
        self.assertEqual(result["attributed_instructions"], 2)
        self.assertEqual(result["marker_instructions"], 1)


if __name__ == "__main__":
    unittest.main()
