#!/usr/bin/env python3
"""Run multi-SimPoint architectural-state probes without touching L2 results."""

import argparse
import json
import shlex
import subprocess
from collections import defaultdict
from pathlib import Path


def container_path(path, repo_root, container_root):
    path = Path(path).resolve()
    try:
        relative = path.relative_to(repo_root)
    except ValueError as error:
        raise ValueError(f"path is outside repository mount: {path}") from error
    return container_root / relative


def select_groups(plan, benches=None, clusters=None):
    selected = defaultdict(list)
    benches = set(benches or [])
    clusters = set(clusters or [])
    for benchmark in plan["benchmarks"]:
        if benches and benchmark["bench"] not in benches:
            continue
        if not benchmark.get("ready_for_capture", True):
            if benchmark["bench"] in benches:
                raise ValueError(
                    f"{benchmark['bench']}: benchmark is not capture-ready: "
                    + "; ".join(benchmark.get("issues", []))
                )
            continue
        for region in benchmark["regions"]:
            if clusters and int(region["cluster"]) not in clusters:
                continue
            selected[(benchmark["bench"], region["command_index"])].append(region)
    return selected


def make_group_command(
    bench,
    command_index,
    regions,
    repo_root,
    container_root,
    qemu,
    sysroot,
    plugin,
    output_root,
):
    if any(not region["ready_for_capture"] for region in regions):
        raise ValueError(f"{bench}/command {command_index}: plan is not capture-ready")
    run_directories = {region["run_directory"] for region in regions}
    commands = {region["command"] for region in regions}
    seeds = {int(region["qemu_seed"]) for region in regions}
    reserved = {region["qemu_reserved_va"] or "0x4000000000" for region in regions}
    if len(run_directories) != 1 or len(commands) != 1:
        raise ValueError(f"{bench}/command {command_index}: inconsistent command source")
    if len(seeds) != 1 or len(reserved) != 1:
        raise ValueError(f"{bench}/command {command_index}: inconsistent QEMU settings")

    source_run_dir = Path(next(iter(run_directories))).resolve()
    source_container = container_path(source_run_dir, repo_root, container_root)
    group_name = f"{bench}.command_{command_index}"
    group_host = output_root / group_name
    group_container = container_path(group_host, repo_root, container_root)
    workspace = group_container / "work" / source_run_dir.name
    probe_file = group_container / "probe.regs"
    windows_file = group_container / "roi_syscalls.json"
    memory_prefix = group_container / "memory"
    maps_file = group_container / "process.maps"
    capture_targets = sorted(
        {int(region["checkpoint_instruction"]) for region in regions}
    )
    roi_windows = {
        (
            int(region["roi_start_instruction"]),
            int(region["roi_start_instruction"])
            + int(region["roi_instructions"]),
        )
        for region in regions
    }
    warmup_windows = {
        (
            int(region["checkpoint_instruction"]),
            int(region["roi_start_instruction"]),
        )
        for region in regions
    }
    windows = sorted(roi_windows | warmup_windows)
    windows_arg = ":".join(f"{start}-{end}" for start, end in windows)
    reference_targets = sorted(end for _, end in roi_windows)
    targets = sorted(set(capture_targets) | set(reference_targets))
    target_arg = ":".join(str(value) for value in targets)
    memory_target_arg = ":".join(str(value) for value in capture_targets)
    plugin_options = ",".join(
        [
            str(plugin),
            f"targets={target_arg}",
            f"memory_targets={memory_target_arg}",
            f"windows={windows_arg}",
            f"outfile={probe_file}",
            f"windowsfile={windows_file}",
            f"mapsfile={maps_file}",
            f"memory_prefix={memory_prefix}",
            f"guest_limit={next(iter(reserved))}",
            "dump_memory=1",
            "exit_after=1",
        ]
    )

    script = "\n".join(
        [
            "set -euo pipefail",
            f"rm -rf {shlex.quote(str(group_container / 'work'))}",
            f"mkdir -p {shlex.quote(str(workspace))}",
            f"cp -a --reflink=auto {shlex.quote(str(source_container) + '/.')} {shlex.quote(str(workspace) + '/')}",
            f"cd {shlex.quote(str(workspace))}",
            "exec "
            + " ".join(
                [
                    shlex.quote(str(qemu)),
                    "-R",
                    shlex.quote(str(next(iter(reserved)))),
                    "-seed",
                    str(next(iter(seeds))),
                    "-cpu",
                    "c910",
                    "-L",
                    shlex.quote(str(sysroot)),
                    "-plugin",
                    shlex.quote(plugin_options),
                    next(iter(commands)),
                ]
            ),
        ]
    )
    mapping = {
        "bench": bench,
        "command_index": command_index,
        "source_run_directory": str(source_run_dir),
        "probe_file": str(group_host / "probe.regs"),
        "roi_windows_file": str(group_host / "roi_syscalls.json"),
        "process_maps_file": str(group_host / "process.maps"),
        "records": [
            {
                "target_insns": target,
                "checkpoints": [
                    {
                        "checkpoint_id": region["checkpoint_id"],
                        "roi_start_instruction": int(region["roi_start_instruction"]),
                        "roi_end_instruction": int(region["roi_start_instruction"])
                        + int(region["roi_instructions"]),
                    }
                    for region in regions
                    if int(region["checkpoint_instruction"]) == target
                ],
            }
            for target in capture_targets
        ],
        "reference_records": [
            {
                "target_insns": int(region["roi_start_instruction"])
                + int(region["roi_instructions"]),
                "checkpoint_id": region["checkpoint_id"],
            }
            for region in regions
        ],
    }
    return group_host, script, mapping


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", default="spec_checkpoints/l3_plan.json")
    parser.add_argument("--bench", action="append")
    parser.add_argument("--cluster", action="append", type=int)
    parser.add_argument("--output-root", default="spec_checkpoints/probes")
    parser.add_argument("--container", default="openc910-qemu")
    parser.add_argument("--container-root", default="/work")
    parser.add_argument("--execute", action="store_true")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    container_root = Path(args.container_root)
    plan = json.loads(Path(args.plan).read_text())
    output_root = Path(args.output_root).resolve()
    output_root.mkdir(parents=True, exist_ok=True)
    qemu = container_root / "toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303/bin/qemu-riscv64"
    sysroot = container_root / "toolchains/Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.1.0/sysroot"
    plugin = container_root / "tools/qemu-plugins/simpoint_probe.so"

    groups = select_groups(plan, args.bench, args.cluster)
    if not groups:
        raise SystemExit("no checkpoint regions selected")
    for (bench, command_index), regions in sorted(groups.items()):
        group_host, script, mapping = make_group_command(
            bench,
            command_index,
            regions,
            repo_root,
            container_root,
            qemu,
            sysroot,
            plugin,
            output_root,
        )
        group_host.mkdir(parents=True, exist_ok=True)
        (group_host / "probe_map.json").write_text(json.dumps(mapping, indent=2) + "\n")
        (group_host / "run_probe.sh").write_text("#!/usr/bin/env bash\n" + script + "\n")
        print(
            "docker exec "
            + shlex.quote(args.container)
            + " bash -lc "
            + shlex.quote(script)
        )
        if args.execute:
            subprocess.run(
                ["docker", "exec", args.container, "bash", "-lc", script],
                check=True,
            )


if __name__ == "__main__":
    main()
