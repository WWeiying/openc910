#!/usr/bin/env python3
"""Atomically rebase manifest file paths after a result-directory rename."""

import argparse
import json
import os
from pathlib import Path, PurePosixPath


def rebase_manifest_files(manifest, old_directory, new_directory):
    files = manifest.get("files")
    if not isinstance(files, dict) or not files:
        raise ValueError("manifest files mapping is missing or empty")
    rebased = {}
    for name, raw_path in files.items():
        if not isinstance(raw_path, str) or not raw_path:
            raise ValueError(f"manifest files.{name} is not a path")
        path = PurePosixPath(raw_path)
        if path.parent.name != old_directory:
            raise ValueError(
                f"manifest files.{name} parent={path.parent.name!r}, "
                f"expected={old_directory!r}"
            )
        rebased[name] = str(path.parent.parent / new_directory / path.name)
    result = dict(manifest)
    result["files"] = rebased
    return result


def atomic_json_write(path, data):
    temporary = path.with_name(f"{path.name}.tmp.{os.getpid()}")
    try:
        temporary.write_text(json.dumps(data, indent=2) + "\n")
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("old_directory")
    parser.add_argument("new_directory")
    args = parser.parse_args()
    data = json.loads(args.manifest.read_text())
    rebased = rebase_manifest_files(
        data, args.old_directory, args.new_directory
    )
    atomic_json_write(args.manifest, rebased)
    print(
        f"[manifest-rebase] {args.old_directory} -> {args.new_directory}: "
        f"{len(rebased['files'])} paths"
    )


if __name__ == "__main__":
    main()
