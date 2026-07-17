import tempfile
import unittest
from pathlib import Path

from spec_flow.l3_parse_probe import normalize_registers, parse_probe


class L3ParseProbeTest(unittest.TestCase):
    def test_parses_multiple_records_and_normalizes_abi_names(self):
        text = """vcpu 0
checkpoint 0
target_insns 100
interval_insns 1000
observed_insns 103
boundary_error_insns 3
observed_syscalls 2
tb_pc 0x1000
tb_insns 4
memory_status ok
memory_bytes 4096
memory_image /work/memory.bin
memory_map /work/memory_map.json
reg zero size 8 value 0x0000000000000000
reg sp size 8 value 0x0000000000002000
reg pc size 8 value 0x0000000000001000
reg fa0 size 8 value 0x0000000000000001
reg fcsr size 8 value 0x0000000000000000
end_checkpoint
vcpu 0
checkpoint 1
target_insns 200
interval_insns 1000
observed_insns 200
boundary_error_insns 0
observed_syscalls 2
tb_pc 0x1010
tb_insns 2
reg pc size 8 value 0x0000000000001010
end_checkpoint
"""
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "probe.regs"
            path.write_text(text)
            records = parse_probe(path)
        self.assertEqual(len(records), 2)
        self.assertEqual(records[0]["boundary_error_insns"], 3)
        self.assertEqual(records[0]["memory_bytes"], 4096)
        self.assertEqual(records[0]["memory_status"], "ok")
        normalized = normalize_registers(records[0]["registers"], tb_pc="0x1234")
        self.assertEqual(normalized["x0"]["value"], "0x0000000000000000")
        self.assertEqual(normalized["x2"], normalized["sp"])
        self.assertIn("f10", normalized)
        self.assertEqual(normalized["pc"]["value"], "0x0000000000001234")
        self.assertEqual(normalized["pc"]["source"], "translation_block_entry")


if __name__ == "__main__":
    unittest.main()
