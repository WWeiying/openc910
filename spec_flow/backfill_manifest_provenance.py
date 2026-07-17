#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

try:
    from spec_flow.make_simpoint_manifest import command_output, read_git_head
except ModuleNotFoundError:
    from make_simpoint_manifest import command_output, read_git_head


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("--repo-root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--qemu-path", required=True)
    parser.add_argument("--compiler-path", required=True)
    parser.add_argument("--simpoint-path", required=True)
    args = parser.parse_args()

    repo_root = Path(args.repo_root)
    git_commit = command_output(["git", "-C", str(repo_root), "rev-parse", "HEAD"])
    if git_commit == "unknown":
        git_commit = read_git_head(repo_root)
    git_status = command_output(["git", "-C", str(repo_root), "status", "--porcelain"])
    provenance = {
        "git_commit": git_commit,
        "git_dirty": None if git_status == "unknown" else bool(git_status),
        "qemu_path": args.qemu_path,
        "qemu_version": command_output([args.qemu_path, "-version"]).splitlines()[0],
        "compiler_path": args.compiler_path,
        "compiler_version": command_output(
            [args.compiler_path, "--version"]
        ).splitlines()[0],
        "simpoint_path": args.simpoint_path,
    }

    updated = 0
    for path in sorted(Path(args.spec_runs).glob("*_c910/manifest.json")):
        manifest = json.loads(path.read_text())
        manifest["provenance"] = provenance
        path.write_text(json.dumps(manifest, indent=2) + "\n")
        updated += 1
    print(f"[provenance] updated={updated} root={args.spec_runs}")


if __name__ == "__main__":
    main()
