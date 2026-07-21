#!/usr/bin/env python3
"""Publish a validated L2+ artifact set with rollback on replacement failure."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import signal
import tempfile
from pathlib import Path


class PublishInterrupted(RuntimeError):
    pass


def _fsync_directory(path: Path) -> None:
    descriptor = os.open(path, os.O_RDONLY | os.O_DIRECTORY)
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def atomic_publish(pairs: list[tuple[Path, Path]]) -> int:
    if not pairs:
        raise ValueError("no artifacts were provided")

    normalized = [(source.resolve(), target.resolve()) for source, target in pairs]
    sources = [source for source, _ in normalized]
    targets = [target for _, target in normalized]
    if len(set(sources)) != len(sources):
        raise ValueError("duplicate publication source")
    if len(set(targets)) != len(targets):
        raise ValueError("duplicate publication target")
    for source in sources:
        if not source.is_file() or source.stat().st_size == 0:
            raise ValueError(f"publication source is missing or empty: {source}")
    target_parents = {target.parent for target in targets}
    if len(target_parents) != 1:
        raise ValueError("all publication targets must share one directory")
    target_parent = next(iter(target_parents))
    if not target_parent.is_dir():
        raise ValueError(f"publication target directory is missing: {target_parent}")
    target_device = target_parent.stat().st_dev
    for source in sources:
        if source.stat().st_dev != target_device:
            raise ValueError(
                f"source and target are on different filesystems: {source}"
            )

    backup = Path(
        tempfile.mkdtemp(prefix=".l2plus-publish.", dir=target_parent)
    )
    entries = []
    for index, (source, target) in enumerate(normalized):
        entries.append(
            {
                "source": source,
                "target": target,
                "backup": backup / f"{index:03d}.{target.name}",
                "old_moved": False,
                "new_moved": False,
            }
        )
    (backup / "journal.json").write_text(
        json.dumps(
            [
                {
                    "source": str(entry["source"]),
                    "target": str(entry["target"]),
                    "backup": str(entry["backup"]),
                }
                for entry in entries
            ],
            indent=2,
        )
        + "\n"
    )
    _fsync_directory(backup)

    old_handlers = {}

    def interrupt(signum, _frame):
        raise PublishInterrupted(f"publication interrupted by signal {signum}")

    for signum in (signal.SIGINT, signal.SIGTERM):
        old_handlers[signum] = signal.signal(signum, interrupt)

    try:
        try:
            for entry in entries:
                source = entry["source"]
                target = entry["target"]
                old_copy = entry["backup"]
                if target.exists():
                    os.replace(target, old_copy)
                    entry["old_moved"] = True
                os.replace(source, target)
                entry["new_moved"] = True
            _fsync_directory(target_parent)
        except BaseException as publish_error:
            try:
                for entry in reversed(entries):
                    source = entry["source"]
                    target = entry["target"]
                    old_copy = entry["backup"]
                    if entry["new_moved"] and target.exists():
                        os.replace(target, source)
                    if entry["old_moved"] and old_copy.exists():
                        os.replace(old_copy, target)
                _fsync_directory(target_parent)
            except BaseException as rollback_error:
                raise RuntimeError(
                    f"publication failed and rollback is incomplete; "
                    f"recovery journal retained at {backup}"
                ) from rollback_error
            shutil.rmtree(backup)
            _fsync_directory(target_parent)
            raise publish_error
            raise
    finally:
        for signum, handler in old_handlers.items():
            signal.signal(signum, handler)

    shutil.rmtree(backup)
    _fsync_directory(target_parent)
    return len(entries)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pair",
        nargs=2,
        action="append",
        required=True,
        metavar=("SOURCE", "TARGET"),
    )
    args = parser.parse_args()
    count = atomic_publish(
        [(Path(source), Path(target)) for source, target in args.pair]
    )
    print(f"[publish] committed={count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
