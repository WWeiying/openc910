#!/usr/bin/env python3
"""Strictly validate an architectural checkpoint before an RTL restore run."""

import argparse
import hashlib
import json
from pathlib import Path


FORMAT = "openc910-spec-l3-checkpoint-v1"
REQUIRED_INTEGER_REGISTERS = {"pc", "sp"} | {f"x{i}" for i in range(32)}
REQUIRED_FP_REGISTERS = {"fcsr"} | {f"f{i}" for i in range(32)}


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_int(value):
    return int(value, 0) if isinstance(value, str) else int(value)


def find_region(plan, checkpoint_id):
    for benchmark in plan["benchmarks"]:
        for region in benchmark["regions"]:
            if region["checkpoint_id"] == checkpoint_id:
                return benchmark, region
    raise ValueError(f"checkpoint id is absent from plan: {checkpoint_id}")


def validate_package(package_dir, plan, require_restore=True):
    manifest_path = package_dir / "checkpoint.json"
    errors = []
    if not manifest_path.is_file():
        return [f"missing {manifest_path}"]
    checkpoint = json.loads(manifest_path.read_text())
    if checkpoint.get("format") != FORMAT:
        errors.append(f"unexpected checkpoint format: {checkpoint.get('format')}")
    checkpoint_id = checkpoint.get("checkpoint_id")
    try:
        benchmark, region = find_region(plan, checkpoint_id)
    except ValueError as error:
        return [str(error)]

    source = checkpoint.get("source", {})
    if source.get("spec_manifest_sha256") != benchmark["manifest_sha256"]:
        errors.append("SPEC manifest digest does not match frozen plan")
    if source.get("elf_sha256") != region["elf_sha256"]:
        errors.append("ELF digest does not match frozen plan")
    if int(source.get("command_index", -1)) != region["command_index"]:
        errors.append("command index does not match frozen plan")

    capture = checkpoint.get("capture", {})
    if int(capture.get("instruction", -1)) != region["checkpoint_instruction"]:
        errors.append("capture instruction does not match frozen plan")
    if int(capture.get("boundary_error_instructions", 1 << 30)) > 64:
        errors.append("checkpoint boundary error exceeds 64 instructions")

    artifacts = checkpoint.get("artifacts", {})
    resolved = {}
    required_artifacts = ["registers", "memory_map", "memory_image", "syscall_trace"]
    if require_restore:
        required_artifacts.extend(("roi_reference", "restore_replay"))
    for name in required_artifacts:
        item = artifacts.get(name, {})
        path = package_dir / item.get("path", "")
        if not item.get("path") or not path.is_file():
            errors.append(f"missing checkpoint artifact: {name}")
            continue
        if item.get("sha256") != sha256(path):
            errors.append(f"checkpoint artifact digest mismatch: {name}")
        resolved[name] = path

    if "registers" in resolved:
        registers = json.loads(resolved["registers"].read_text())
        names = set(registers.get("registers", {}))
        missing = sorted((REQUIRED_INTEGER_REGISTERS | REQUIRED_FP_REGISTERS) - names)
        if missing:
            errors.append("missing architectural registers: " + ",".join(missing))

    if "memory_map" in resolved and "memory_image" in resolved:
        memory_map = json.loads(resolved["memory_map"].read_text())
        segments = memory_map.get("segments", [])
        image_size = resolved["memory_image"].stat().st_size
        if not segments:
            errors.append("memory map has no segments")
        for segment in segments:
            if not segment.get("captured", True):
                if segment.get("image_offset") is not None:
                    errors.append("uncaptured memory segment has an image offset")
                    break
                continue
            offset = parse_int(segment["image_offset"])
            length = parse_int(segment["length"])
            if offset < 0 or length <= 0 or offset + length > image_size:
                errors.append("memory segment exceeds memory image")
                break
        resident = sum(
            parse_int(item["length"])
            for item in segments
            if item.get("captured", True)
        )
        if require_restore and resident > int(
            checkpoint.get("rtl", {}).get("memory_capacity", 32 << 20)
        ):
            errors.append(
                f"resident checkpoint memory {resident} exceeds configured RTL memory"
            )

    if "syscall_trace" in resolved:
        syscall_trace = json.loads(resolved["syscall_trace"].read_text())
        if require_restore and int(syscall_trace.get("restore_syscalls", -1)) != 0:
            errors.append(
                "checkpoint-to-ROI-end window contains syscalls unsupported "
                "by bare-metal restore"
            )

    if require_restore and "restore_replay" in resolved:
        replay = json.loads(resolved["restore_replay"].read_text())
        if not replay.get("passed"):
            errors.append("QEMU restore/replay report did not pass")

    if require_restore and not checkpoint.get("validation", {}).get(
        "qemu_restore_replay_match"
    ):
        errors.append("checkpoint has not passed QEMU restore/replay validation")
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", required=True)
    parser.add_argument("--checkpoint-root", required=True)
    parser.add_argument("--allow-missing", action="store_true")
    parser.add_argument("--stage", choices=("capture", "restore"), default="restore")
    args = parser.parse_args()

    plan = json.loads(Path(args.plan).read_text())
    root = Path(args.checkpoint_root)
    errors = []
    checked = 0
    print("| checkpoint | status |")
    print("|---|---|")
    for benchmark in plan["benchmarks"]:
        for region in benchmark["regions"]:
            package = root / region["checkpoint_id"]
            if not package.is_dir() and args.allow_missing:
                continue
            row_errors = validate_package(
                package, plan, require_restore=args.stage == "restore"
            )
            checked += 1
            print(
                f"| `{region['checkpoint_id']}` | "
                f"{'ok' if not row_errors else '<br>'.join(row_errors)} |"
            )
            errors.extend(f"{region['checkpoint_id']}: {item}" for item in row_errors)
    print(f"\nvalidated checkpoints: {checked}")
    if errors:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
