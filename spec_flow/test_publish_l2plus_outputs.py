import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from spec_flow.publish_l2plus_outputs import atomic_publish


class PublishL2PlusOutputsTests(unittest.TestCase):
    def test_publishes_complete_set_and_removes_backups(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            stage = root / "stage"
            target = root / "target"
            stage.mkdir()
            target.mkdir()
            source_a = stage / "a"
            source_b = stage / "b"
            target_a = target / "a"
            target_b = target / "b"
            source_a.write_text("new-a")
            source_b.write_text("new-b")
            target_a.write_text("old-a")

            count = atomic_publish(
                [(source_a, target_a), (source_b, target_b)]
            )

            self.assertEqual(count, 2)
            self.assertEqual(target_a.read_text(), "new-a")
            self.assertEqual(target_b.read_text(), "new-b")
            self.assertFalse(source_a.exists())
            self.assertFalse(source_b.exists())
            self.assertEqual(list(target.glob(".l2plus-publish.*")), [])

    def test_preflight_failure_leaves_targets_unchanged(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            stage = root / "stage"
            target = root / "target"
            stage.mkdir()
            target.mkdir()
            source = stage / "missing"
            destination = target / "artifact"
            destination.write_text("old")

            with self.assertRaisesRegex(ValueError, "missing or empty"):
                atomic_publish([(source, destination)])

            self.assertEqual(destination.read_text(), "old")
            self.assertEqual(list(target.glob(".l2plus-publish.*")), [])

    def test_replacement_failure_rolls_back_every_target(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            stage = root / "stage"
            target = root / "target"
            stage.mkdir()
            target.mkdir()
            source_a = stage / "a"
            source_b = stage / "b"
            target_a = target / "a"
            target_b = target / "b"
            source_a.write_text("new-a")
            source_b.write_text("new-b")
            target_a.write_text("old-a")
            target_b.write_text("old-b")

            real_replace = os.replace
            calls = 0

            def fail_fourth_replace(source, destination):
                nonlocal calls
                calls += 1
                if calls == 4:
                    raise OSError("injected publication failure")
                return real_replace(source, destination)

            with patch(
                "spec_flow.publish_l2plus_outputs.os.replace",
                side_effect=fail_fourth_replace,
            ):
                with self.assertRaisesRegex(
                    OSError, "injected publication failure"
                ):
                    atomic_publish(
                        [(source_a, target_a), (source_b, target_b)]
                    )

            self.assertEqual(target_a.read_text(), "old-a")
            self.assertEqual(target_b.read_text(), "old-b")
            self.assertEqual(source_a.read_text(), "new-a")
            self.assertEqual(source_b.read_text(), "new-b")
            self.assertEqual(list(target.glob(".l2plus-publish.*")), [])


if __name__ == "__main__":
    unittest.main()
