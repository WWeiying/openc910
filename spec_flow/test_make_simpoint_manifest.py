import unittest

from spec_flow.make_simpoint_manifest import normalized_bbv_id_stride


class ManifestStrideTests(unittest.TestCase):
    def test_perlbench_stride_is_bound_to_pid_namespace_format(self):
        for bench in ("500.perlbench_r", "600.perlbench_s"):
            self.assertEqual(normalized_bbv_id_stride(bench, 1 << 40), 1 << 32)

    def test_non_perlbench_stride_is_preserved(self):
        self.assertEqual(normalized_bbv_id_stride("602.gcc_s", 1 << 40), 1 << 40)


if __name__ == "__main__":
    unittest.main()
