#!/usr/bin/env python3
"""Convert simpoint_probe text records into normalized RISC-V register JSON."""

import argparse
import hashlib
import json
import os
import re
import shutil
from pathlib import Path


INTEGER_ABI = {
    "zero": 0, "ra": 1, "sp": 2, "gp": 3, "tp": 4,
    "t0": 5, "t1": 6, "t2": 7, "fp": 8, "s0": 8, "s1": 9,
    "a0": 10, "a1": 11, "a2": 12, "a3": 13, "a4": 14,
    "a5": 15, "a6": 16, "a7": 17, "s2": 18, "s3": 19,
    "s4": 20, "s5": 21, "s6": 22, "s7": 23, "s8": 24,
    "s9": 25, "s10": 26, "s11": 27, "t3": 28, "t4": 29,
    "t5": 30, "t6": 31,
}
FP_ABI = {
    **{f"ft{i}": i for i in range(8)},
    "fs0": 8, "fs1": 9,
    **{f"fa{i}": 10 + i for i in range(8)},
    **{f"fs{i}": 16 + i for i in range(2, 12)},
    **{f"ft{i}": 20 + i for i in range(8, 12)},
}
REGEX = re.compile(r"^reg (\S+) size (\d+) value (0x[0-9a-fA-F]+)$")


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def localize_path(value, repo_root):
    path = Path(value)
    if path.is_file():
        return path.resolve()
    if path.is_absolute() and path.parts[:2] == ("/", "work"):
        candidate = repo_root.joinpath(*path.parts[2:])
        if candidate.is_file():
            return candidate.resolve()
    return path


def install_artifact(source, destination):
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        destination.unlink()
    try:
        os.link(source, destination)
    except OSError:
        shutil.copy2(source, destination)


def parse_probe(path):
    records = []
    current = None
    for raw in path.read_text().splitlines():
        if raw.startswith("vcpu "):
            current = {"vcpu": int(raw.split()[1]), "registers": {}}
            continue
        if current is None:
            continue
        match = REGEX.match(raw)
        if match:
            name, size, value = match.groups()
            current["registers"][name] = {"size": int(size), "value": value}
            continue
        if raw == "end_checkpoint":
            records.append(current)
            current = None
            continue
        key, _, value = raw.partition(" ")
        if key in {
            "checkpoint", "target_insns", "interval_insns", "observed_insns",
            "boundary_error_insns", "observed_syscalls", "tb_insns",
            "memory_bytes",
        }:
            current[key] = int(value)
        elif key == "tb_pc":
            current[key] = value
        elif key in {
            "memory_status", "memory_image", "memory_map", "replay_status"
        }:
            current[key] = value
    return records


def normalize_registers(raw, tb_pc=None):
    normalized = {}
    for name, item in raw.items():
        if name in INTEGER_ABI:
            normalized[f"x{INTEGER_ABI[name]}"] = item
        if name in FP_ABI:
            normalized[f"f{FP_ABI[name]}"] = item
        if name in {"pc", "fcsr", "fflags", "frm", "priv"}:
            normalized[name] = item
    if "x2" in normalized:
        normalized["sp"] = normalized["x2"]
    if tb_pc is not None:
        normalized["pc"] = {
            "size": raw.get("pc", {}).get("size", 8),
            "value": f"0x{int(tb_pc, 0):016x}",
            "source": "translation_block_entry",
        }
    return normalized


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--probe-map", required=True)
    parser.add_argument("--out-root", default="spec_checkpoints/packages")
    args = parser.parse_args()

    probe_map_path = Path(args.probe_map)
    mapping = json.loads(probe_map_path.read_text())
    probe_path = Path(mapping["probe_file"])
    repo_root = Path(__file__).resolve().parent.parent
    records = parse_probe(probe_path)
    by_target = {record["target_insns"]: record for record in records}
    windows_path = Path(mapping["roi_windows_file"])
    windows_payload = json.loads(windows_path.read_text())
    windows = {
        (int(item["roi_start_instruction"]), int(item["roi_end_instruction"])): item
        for item in windows_payload["windows"]
    }
    output_root = Path(args.out_root)
    for item in mapping["records"]:
        target = int(item["target_insns"])
        if target not in by_target:
            raise ValueError(f"probe record missing target {target}")
        record = by_target[target]
        if record.get("memory_status") != "ok":
            raise ValueError(f"memory capture failed for target {target}")
        memory_image = localize_path(record["memory_image"], repo_root)
        memory_map = localize_path(record["memory_map"], repo_root)
        for checkpoint in item["checkpoints"]:
            checkpoint_id = checkpoint["checkpoint_id"]
            out = output_root / checkpoint_id / "probe"
            out.mkdir(parents=True, exist_ok=True)
            payload = {
                "format": "openc910-spec-l3-register-probe-v1",
                "checkpoint_id": checkpoint_id,
                "target_insns": target,
                "observed_insns": record["observed_insns"],
                "boundary_error_instructions": record["boundary_error_insns"],
                "cumulative_syscalls": record["observed_syscalls"],
                "registers": normalize_registers(
                    record["registers"], tb_pc=record["tb_pc"]
                ),
                "raw_registers": record["registers"],
                "state_boundary": "translation_block_entry",
            }
            (out / "registers.json").write_text(json.dumps(payload, indent=2) + "\n")
            install_artifact(memory_image, out / "memory.bin")
            install_artifact(memory_map, out / "memory_map.json")
            window_key = (
                int(checkpoint["roi_start_instruction"]),
                int(checkpoint["roi_end_instruction"]),
            )
            if window_key not in windows:
                raise ValueError(f"ROI syscall window is missing: {window_key}")
            window = windows[window_key]
            warmup_key = (target, window_key[0])
            warmup_window = windows.get(warmup_key)
            if window_key[1] not in by_target:
                raise ValueError(
                    f"ROI end register/syscall record is missing: {window_key[1]}"
                )
            end_record = by_target[window_key[1]]
            restore_syscalls = (
                int(end_record["observed_syscalls"])
                - int(record["observed_syscalls"])
            )
            if restore_syscalls < 0:
                raise ValueError("cumulative syscall count moved backwards")
            syscall_trace = {
                "format": "openc910-spec-l3-syscall-trace-v1",
                "checkpoint_id": checkpoint_id,
                "roi_start_instruction": window_key[0],
                "roi_end_instruction": window_key[1],
                "roi_syscalls": int(window["roi_syscalls"]),
                "syscall_counts": window.get("syscall_counts", {}),
                "warmup_syscalls": (
                    int(warmup_window["roi_syscalls"])
                    if warmup_window is not None
                    else None
                ),
                "warmup_syscall_counts": (
                    warmup_window.get("syscall_counts", {})
                    if warmup_window is not None
                    else None
                ),
                "restore_syscalls": restore_syscalls,
                "restore_start_observed_instruction": int(
                    record["observed_insns"]
                ),
                "restore_end_observed_instruction": int(
                    end_record["observed_insns"]
                ),
                "instruction_boundary_accuracy": "QEMU translation-block boundary",
            }
            (out / "syscall_trace.json").write_text(
                json.dumps(syscall_trace, indent=2) + "\n"
            )
            summary = {
                "checkpoint_id": checkpoint_id,
                "target_instructions": target,
                "observed_instructions": record["observed_insns"],
                "boundary_error_instructions": record["boundary_error_insns"],
                "memory_bytes": int(record["memory_bytes"]),
                "roi_syscalls": syscall_trace["roi_syscalls"],
                "restore_syscalls": syscall_trace["restore_syscalls"],
                "artifacts": {
                    name: sha256(out / name)
                    for name in (
                        "registers.json",
                        "memory_map.json",
                        "memory.bin",
                        "syscall_trace.json",
                    )
                },
            }
            (out / "capture_summary.json").write_text(
                json.dumps(summary, indent=2) + "\n"
            )
            print(out)

    for item in mapping.get("reference_records", []):
        target = int(item["target_insns"])
        if target not in by_target:
            raise ValueError(f"ROI reference record missing target {target}")
        record = by_target[target]
        checkpoint_id = item["checkpoint_id"]
        out = output_root / checkpoint_id / "reference"
        out.mkdir(parents=True, exist_ok=True)
        payload = {
            "format": "openc910-spec-l3-roi-reference-v1",
            "checkpoint_id": checkpoint_id,
            "target_insns": target,
            "observed_insns": record["observed_insns"],
            "boundary_error_instructions": record["boundary_error_insns"],
            "state_boundary": "translation_block_entry",
            "registers": normalize_registers(
                record["registers"], tb_pc=record["tb_pc"]
            ),
            "raw_registers": record["registers"],
        }
        (out / "roi_end_registers.json").write_text(
            json.dumps(payload, indent=2) + "\n"
        )
        print(out / "roi_end_registers.json")


if __name__ == "__main__":
    main()
