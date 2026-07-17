import tempfile
import unittest
from pathlib import Path

from spec_flow.compact_bbv_ids import RawIdMapping, compact_bbv, load_and_compact_map


class CompactBbvIdsTests(unittest.TestCase):
    def test_rejects_stride_mismatch_before_dense_allocation(self):
        mapping = RawIdMapping(start_id=1, id_stride=1 << 40)
        raw_id = (215008 << 32) + 1

        with self.assertRaisesRegex(ValueError, "ID strides do not match"):
            mapping.add(raw_id, 1)

    def test_compacts_nested_process_ranges_within_one_outer_command(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            bbv_map = root / "sample.bb.map"
            bbv = root / "sample.bb"
            bbv_map.write_text(
                "1 0x1000 4\n"
                "2 0x2000 2\n"
                "1048577 0x1000 4\n"
                "1048578 0x3000 3\n"
            )
            bbv.write_text(
                "T:1:10 :2:4\n"
                "T :1048577:7 :1048578:9\n"
            )
            entries, mapping = load_and_compact_map(bbv_map, 1, 1048576)
            self.assertEqual(
                entries,
                [(1, 0x1000, 4), (2, 0x2000, 2), (3, 0x3000, 3)],
            )
            self.assertEqual(mapping[1048577], 1)
            self.assertEqual(mapping[1048578], 3)
            self.assertEqual(
                compact_bbv(bbv, mapping),
                ["T :1:10 :2:4\n", "T :1:7 :3:9\n"],
            )

    def test_preserves_prior_outer_command_ids(self):
        with tempfile.TemporaryDirectory() as tmp:
            bbv_map = Path(tmp) / "sample.bb.map"
            bbv_map.write_text(
                "1 0x1000 4\n"
                "2 0x2000 2\n"
                "3 0x1000 4\n"
                "1048579 0x3000 3\n"
            )
            entries, mapping = load_and_compact_map(bbv_map, 3, 1048576)
            self.assertEqual(
                entries,
                [(1, 0x1000, 4), (2, 0x2000, 2), (3, 0x1000, 4), (4, 0x3000, 3)],
            )
            self.assertEqual(mapping[1], 1)
            self.assertEqual(mapping[2], 2)
            self.assertEqual(mapping[1048579], 4)

    def test_rejects_duplicate_ids_in_preexisting_compacted_map(self):
        with tempfile.TemporaryDirectory() as tmp:
            bbv_map = Path(tmp) / "sample.bb.map"
            bbv_map.write_text("1 0x1000 4\n1 0x2000 4\n")
            with self.assertRaisesRegex(ValueError, "duplicate pre-existing"):
                load_and_compact_map(bbv_map, 2)

    def test_detects_overlap_between_reserved_process_ranges(self):
        with tempfile.TemporaryDirectory() as tmp:
            bbv_map = Path(tmp) / "sample.bb.map"
            bbv_map.write_text(
                "17 0x1000 4\n"
                "17 0x2000 2\n"
            )
            with self.assertRaisesRegex(ValueError, "maps to different TBs"):
                load_and_compact_map(bbv_map, 1, 16)

    def test_large_process_ranges_compact_repeated_blocks(self):
        with tempfile.TemporaryDirectory() as tmp:
            bbv_map = Path(tmp) / "sample.bb.map"
            bbv_map.write_text(
                "1 0x1000 4\n"
                "17 0x1000 4\n"
                "18 0x3000 3\n"
            )
            entries, mapping = load_and_compact_map(bbv_map, 1, 16)
            self.assertEqual(entries, [(1, 0x1000, 4), (2, 0x3000, 3)])
            self.assertEqual(mapping[1], 1)
            self.assertEqual(mapping[17], 1)
            self.assertEqual(mapping[18], 2)


if __name__ == "__main__":
    unittest.main()
