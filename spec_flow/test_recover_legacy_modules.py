import unittest
import random

from spec_flow.recover_legacy_modules import find_slide, guest_arguments


class RecoverLegacyModulesTests(unittest.TestCase):
    def test_recovers_slide_from_matching_pc_sets_with_noise(self):
        probe = [0x7F0000000000 + index * 16 for index in range(100)]
        slide = -0x12345000
        old = [pc + slide for pc in probe]
        old.extend(0x7E0000000000 + index * 32 for index in range(40))
        actual, score, probe_count, old_count = find_slide(old, probe)
        self.assertEqual(actual, slide)
        self.assertEqual(score, len(probe))
        self.assertEqual(probe_count, len(probe))
        self.assertEqual(old_count, len(old))

    def test_rejects_unrelated_pc_sets(self):
        rng = random.Random(17)
        probe = [0x7F0000000000 + value for value in rng.sample(range(1 << 24), 20)]
        old = [0x7E0000000000 + value for value in rng.sample(range(1 << 24), 20)]
        with self.assertRaises(ValueError):
            find_slide(old, probe)

    def test_extracts_guest_arguments_before_shell_redirections(self):
        command = "../perlbench -I./lib splitmail.pl 535 13 > out 2>> err"
        self.assertEqual(
            guest_arguments(command),
            ["-I./lib", "splitmail.pl", "535", "13"],
        )


if __name__ == "__main__":
    unittest.main()
