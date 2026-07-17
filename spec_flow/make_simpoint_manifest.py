#!/usr/bin/env python3
import argparse
import csv
import json
import subprocess
from pathlib import Path


def normalized_bbv_id_stride(bench, requested):
    if bench in {"500.perlbench_r", "600.perlbench_s"}:
        return 1 << 32
    return requested


def load_simpoints(path):
    out = []
    with open(path) as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 2:
                out.append({"interval": int(parts[0]), "cluster": int(parts[1])})
    return out


def load_weights(path):
    out = {}
    with open(path) as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 2:
                out[int(parts[1])] = float(parts[0])
    return out


def load_function_profile(path):
    global_top = []
    simpoint_top = {}
    with open(path, newline="") as f:
        for row in csv.DictReader(f):
            item = {
                "function": row["function"],
                "count": int(row["count"]),
                "percent": float(row["percent"]),
            }
            if row["scope"] == "global":
                global_top.append(item)
            elif row["scope"] == "simpoint":
                cluster = int(row["cluster"])
                simpoint_top.setdefault(cluster, []).append(item)
    return global_top, simpoint_top


def log_contains(path, needles):
    if not path.exists():
        return False
    text = path.read_text(errors="replace")
    return any(needle in text for needle in needles)


def log_has_error(path):
    if not path.exists():
        return True
    text = path.read_text(errors="replace").lower()
    return "error:" in text or "finished with errors" in text or "no such file or directory" in text


def command_output(command):
    try:
        return subprocess.check_output(
            command, text=True, stderr=subprocess.STDOUT
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return "unknown"


def read_git_head(repo_root):
    head = repo_root / ".git" / "HEAD"
    if not head.exists():
        return "unknown"
    value = head.read_text().strip()
    if not value.startswith("ref: "):
        return value
    ref = value[5:]
    loose = repo_root / ".git" / ref
    if loose.exists():
        return loose.read_text().strip()
    packed = repo_root / ".git" / "packed-refs"
    if packed.exists():
        for line in packed.read_text().splitlines():
            if line and not line.startswith(("#", "^")):
                commit, name = line.split(" ", 1)
                if name == ref:
                    return commit
    return "unknown"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bench", required=True)
    parser.add_argument("--size", required=True)
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--interval", type=int, required=True)
    parser.add_argument("--max-k", type=int, required=True)
    parser.add_argument("--skip-intervals", type=int, default=0)
    parser.add_argument("--max-intervals", type=int)
    parser.add_argument("--compiler", default="Xuantie GCC Linux glibc")
    parser.add_argument("--optimize", default="-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910")
    parser.add_argument("--qemu-cpu", default="c910")
    parser.add_argument("--qemu-reserved-va", default="0x4000000000")
    parser.add_argument("--bbv-id-stride", type=int, default=1 << 40)
    parser.add_argument(
        "--module-map-method",
        choices=("fixed_va", "aslr_slide_recovered"),
        default="fixed_va",
    )
    parser.add_argument("--bbv-type", default="qemu_tb_instruction_weighted")
    parser.add_argument("--repo-root", default=str(Path(__file__).resolve().parent.parent))
    parser.add_argument("--qemu-path", default="")
    parser.add_argument("--compiler-path", default="")
    parser.add_argument("--simpoint-path", default="")
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    # The fork-safe Perlbench plugin format reserves bits 63:32 for the host
    # PID.  A long-lived scheduler may still export the older 2^40 value, so
    # bind manifest provenance to the producer format instead of its stale
    # inherited environment.
    args.bbv_id_stride = normalized_bbv_id_stride(
        args.bench, args.bbv_id_stride
    )

    out_dir = Path(args.out_dir)
    stem = f"{args.bench}_{args.size}"
    bbv = out_dir / f"{stem}.bb"
    bbv_map = out_dir / f"{stem}.bb.map"
    bbv_cmdmap = out_dir / f"{stem}.bb.cmdmap"
    bbv_modules = out_dir / f"{stem}.bb.modules"
    simpoints_path = out_dir / f"{stem}.simpoints"
    weights_path = out_dir / f"{stem}.weights"
    profile_path = out_dir / f"{stem}.function_profile.csv"

    repo_root = Path(args.repo_root)
    git_commit = command_output(["git", "-C", str(repo_root), "rev-parse", "HEAD"])
    if git_commit == "unknown":
        git_commit = read_git_head(repo_root)
    git_status = command_output(["git", "-C", str(repo_root), "status", "--porcelain"])
    qemu_version = (
        command_output([args.qemu_path, "-version"]).splitlines()[0]
        if args.qemu_path
        else "unknown"
    )
    compiler_version = (
        command_output([args.compiler_path, "--version"]).splitlines()[0]
        if args.compiler_path
        else "unknown"
    )

    simpoints = load_simpoints(simpoints_path)
    weights = load_weights(weights_path)
    global_top, simpoint_top = load_function_profile(profile_path)
    for item in simpoints:
        item["weight"] = weights.get(item["cluster"], 0.0)
        item["top_functions"] = simpoint_top.get(item["cluster"], [])

    compare_log = out_dir / "compare.log"
    simpoint_log = out_dir / "simpoint.log"
    qemu_log = out_dir / "qemu_bbv.log"

    manifest = {
        "bench": args.bench,
        "size": args.size,
        "interval": args.interval,
        "max_k": args.max_k,
        "collection": {
            "skip_intervals": args.skip_intervals,
            "max_intervals": args.max_intervals,
            "full_program": args.skip_intervals == 0 and args.max_intervals is None,
            "bbv_id_stride": args.bbv_id_stride,
        },
        "compiler": args.compiler,
        "optimize": args.optimize,
        "qemu_cpu": args.qemu_cpu,
        "qemu_reserved_va": (
            args.qemu_reserved_va
            if bbv_modules.exists() and args.module_map_method == "fixed_va"
            else None
        ),
        "module_map_method": args.module_map_method if bbv_modules.exists() else None,
        "bbv_type": args.bbv_type,
        "provenance": {
            "git_commit": git_commit,
            "git_dirty": None if git_status == "unknown" else bool(git_status),
            "qemu_path": args.qemu_path or None,
            "qemu_version": qemu_version,
            "compiler_path": args.compiler_path or None,
            "compiler_version": compiler_version,
            "simpoint_path": args.simpoint_path or None,
        },
        "files": {
            "bbv": str(bbv),
            "bbv_map": str(bbv_map),
            "bbv_cmdmap": str(bbv_cmdmap),
            "bbv_modules": str(bbv_modules),
            "simpoints": str(simpoints_path),
            "weights": str(weights_path),
            "function_profile": str(profile_path),
            "qemu_bbv_log": str(qemu_log),
            "compare_log": str(compare_log),
            "simpoint_log": str(simpoint_log),
        },
        "counts": {
            "bbv_intervals": sum(1 for _ in open(bbv)) if bbv.exists() else 0,
            "mapped_blocks": sum(1 for _ in open(bbv_map)) if bbv_map.exists() else 0,
            "mapped_modules": max(
                0, sum(1 for _ in open(bbv_modules)) - 1
            ) if bbv_modules.exists() else 0,
        },
        "validation": {
            "compare_pass": log_contains(compare_log, [
                "specinvoke exit: rc=0",
                "[compare] exit: rc=0",
            ]) and not log_has_error(compare_log),
            "simpoint_done": log_contains(simpoint_log, [
                "Saving simpoints of all non-empty clusters",
                "Simpoints saved to",
                "Wrote Simpoints",
                "[simpoint] single interval fallback:",
            ]),
            "module_map_done": bbv_modules.exists(),
        },
        "global_top_functions": global_top,
        "simpoints": simpoints,
    }

    Path(args.out).write_text(json.dumps(manifest, indent=2, sort_keys=False) + "\n")
    print(f"[manifest] wrote {args.out}")


if __name__ == "__main__":
    main()
