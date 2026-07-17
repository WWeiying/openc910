#!/usr/bin/env python3
"""Freeze parsed probe artifacts into provenance-checked L3 packages."""

import argparse
import hashlib
import json
from pathlib import Path


FORMAT = "openc910-spec-l3-checkpoint-v1"
ARTIFACTS = {
    "registers": "probe/registers.json",
    "memory_map": "probe/memory_map.json",
    "memory_image": "probe/memory.bin",
    "syscall_trace": "probe/syscall_trace.json",
}


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_int(value):
    return int(value, 0) if isinstance(value, str) else int(value)


def build_package(plan, benchmark, region, root, memory_capacity):
    package = root / region["checkpoint_id"]
    summary_path = package / "probe/capture_summary.json"
    if not summary_path.is_file():
        raise ValueError(f"missing parsed capture summary: {summary_path}")
    summary = json.loads(summary_path.read_text())
    artifacts = {}
    for name, relative in ARTIFACTS.items():
        path = package / relative
        if not path.is_file():
            raise ValueError(f"missing checkpoint artifact: {path}")
        digest = sha256(path)
        summary_name = Path(relative).name
        if summary["artifacts"].get(summary_name) != digest:
            raise ValueError(f"capture summary digest mismatch: {path}")
        artifacts[name] = {
            "path": relative,
            "bytes": path.stat().st_size,
            "sha256": digest,
        }
    reference_path = package / "reference/roi_end_registers.json"
    if reference_path.is_file():
        artifacts["roi_reference"] = {
            "path": "reference/roi_end_registers.json",
            "bytes": reference_path.stat().st_size,
            "sha256": sha256(reference_path),
        }

    memory_map = json.loads((package / ARTIFACTS["memory_map"]).read_text())
    resident = sum(
        parse_int(item["length"])
        for item in memory_map["segments"]
        if item.get("captured", True)
    )
    syscall_trace = json.loads((package / ARTIFACTS["syscall_trace"]).read_text())
    roi_syscalls = int(syscall_trace["roi_syscalls"])
    restore_syscalls = int(syscall_trace.get("restore_syscalls", -1))
    rtl_compatible = resident <= memory_capacity and restore_syscalls == 0
    checkpoint = {
        "format": FORMAT,
        "status": "captured_unvalidated" if rtl_compatible else "captured_unsupported",
        "checkpoint_id": region["checkpoint_id"],
        "benchmark": benchmark["bench"],
        "size": benchmark["size"],
        "cluster": int(region["cluster"]),
        "weight": float(region["weight"]),
        "source": {
            "plan_format": plan["format"],
            "spec_manifest": benchmark["manifest"],
            "spec_manifest_sha256": benchmark["manifest_sha256"],
            "elf": region["elf"],
            "elf_sha256": region["elf_sha256"],
            "command_index": int(region["command_index"]),
            "command": region["command"],
            "qemu_seed": int(region["qemu_seed"]),
            "qemu_reserved_va": region["qemu_reserved_va"],
        },
        "capture": {
            "instruction": int(region["checkpoint_instruction"]),
            "observed_instruction": int(summary["observed_instructions"]),
            "boundary_error_instructions": int(
                summary["boundary_error_instructions"]
            ),
            "warmup_instructions": int(region["warmup_instructions"]),
        },
        "roi": {
            "start_instruction": int(region["roi_start_instruction"]),
            "instructions": int(region["roi_instructions"]),
            "syscalls": roi_syscalls,
            "warmup_syscalls": syscall_trace.get("warmup_syscalls"),
            "restore_syscalls": restore_syscalls,
        },
        "artifacts": artifacts,
        "rtl": {
            "memory_capacity": memory_capacity,
            "resident_checkpoint_memory": resident,
            "memory_fits": resident <= memory_capacity,
            "zero_syscall_roi": roi_syscalls == 0,
            "zero_syscall_restore": restore_syscalls == 0,
        },
        "validation": {
            "capture_artifact_digests_match": True,
            "roi_reference_available": "roi_reference" in artifacts,
            "qemu_restore_replay_match": False,
            "rtl_restore_match": False,
        },
    }
    (package / "checkpoint.json").write_text(
        json.dumps(checkpoint, indent=2) + "\n"
    )
    return checkpoint


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", required=True)
    parser.add_argument("--checkpoint-root", default="spec_checkpoints/packages")
    parser.add_argument("--bench", action="append")
    parser.add_argument("--cluster", action="append", type=int)
    parser.add_argument("--memory-capacity-mib", type=int, default=32)
    args = parser.parse_args()

    plan = json.loads(Path(args.plan).read_text())
    root = Path(args.checkpoint_root)
    benches = set(args.bench or [])
    clusters = set(args.cluster or [])
    built = 0
    for benchmark in plan["benchmarks"]:
        if benches and benchmark["bench"] not in benches:
            continue
        for region in benchmark["regions"]:
            if clusters and int(region["cluster"]) not in clusters:
                continue
            checkpoint = build_package(
                plan,
                benchmark,
                region,
                root,
                args.memory_capacity_mib << 20,
            )
            print(
                f"{checkpoint['checkpoint_id']}: {checkpoint['status']} "
                f"memory={checkpoint['rtl']['resident_checkpoint_memory']} "
                f"restore_syscalls={checkpoint['roi']['restore_syscalls']}"
            )
            built += 1
    if not built:
        raise SystemExit("no parsed checkpoint packages selected")


if __name__ == "__main__":
    main()
