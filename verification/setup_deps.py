#!/usr/bin/env python3
"""Install pinned verification sources without installing a reference model."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def run(command: list[str], cwd: Path | None = None) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"command failed ({result.returncode}): {' '.join(command)}\n{result.stdout}")
    return result.stdout.strip()


def install(name: str, spec: dict[str, object], destination: Path) -> None:
    repo = destination / name
    fresh_clone = False
    if not repo.exists():
        destination.mkdir(parents=True, exist_ok=True)
        run(
            [
                "git",
                "clone",
                "--filter=blob:none",
                "--no-recurse-submodules",
                str(spec["url"]),
                str(repo),
            ]
        )
        fresh_clone = True
    if not (repo / ".git").is_dir():
        raise RuntimeError(f"refusing to replace non-git path: {repo}")

    if not fresh_clone:
        dirty = run(["git", "status", "--porcelain"], cwd=repo)
        if dirty:
            raise RuntimeError(f"dependency has local changes; refusing to alter it: {repo}")

    origin = run(["git", "remote", "get-url", "origin"], cwd=repo)
    expected_origin = str(spec["url"])
    if origin.rstrip("/") != expected_origin.rstrip("/"):
        raise RuntimeError(f"unexpected origin for {name}: {origin}")

    commit = str(spec["commit"])
    run(["git", "fetch", "--depth", "1", "origin", commit], cwd=repo)
    run(["git", "checkout", "--detach", commit], cwd=repo)
    if spec.get("submodules", False):
        run(["git", "submodule", "update", "--init", "--recursive"], cwd=repo)
    actual = run(["git", "rev-parse", "HEAD"], cwd=repo)
    if actual != commit:
        raise RuntimeError(f"commit verification failed for {name}: {actual}")
    print(f"READY  {name:<18} {actual[:12]}  {repo}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "components",
        nargs="*",
        help="component names; default installs the standard group",
    )
    parser.add_argument("--all", action="store_true", help="also install riscv-dv")
    parser.add_argument("--dest", type=Path, default=ROOT / ".deps")
    args = parser.parse_args()

    lock = json.loads((ROOT / "deps.lock.json").read_text(encoding="utf-8"))
    if args.components:
        selected = args.components
    elif args.all:
        selected = list(lock)
    else:
        selected = [name for name, spec in lock.items() if spec["group"] == "standard"]

    unknown = sorted(set(selected) - set(lock))
    if unknown:
        parser.error(f"unknown components: {', '.join(unknown)}")

    try:
        for name in selected:
            install(name, lock[name], args.dest.resolve())
    except RuntimeError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
