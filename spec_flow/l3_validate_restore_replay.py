#!/usr/bin/env python3
"""Replay a checkpoint in system QEMU and compare its ROI-end register state."""

import argparse
import hashlib
import json
import subprocess
from pathlib import Path

try:
    from spec_flow.l3_parse_probe import normalize_registers, parse_probe
except ModuleNotFoundError:
    from l3_parse_probe import normalize_registers, parse_probe


REQUIRED_REGISTERS = ["pc"] + [f"x{i}" for i in range(32)] + [
    f"f{i}" for i in range(32)
] + ["fcsr"]


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def container_path(path, repo_root, container_root):
    return container_root / path.resolve().relative_to(repo_root)


def compare_registers(reference, observed):
    differences = []
    for name in REQUIRED_REGISTERS:
        expected = int(reference[name]["value"], 0)
        actual = int(observed[name]["value"], 0)
        if expected != actual:
            differences.append(
                {
                    "register": name,
                    "expected": f"0x{expected:016x}",
                    "observed": f"0x{actual:016x}",
                }
            )
    return differences


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", required=True)
    parser.add_argument("--restore-elf", required=True)
    parser.add_argument("--container", default="openc910-qemu")
    parser.add_argument("--container-root", default="/work")
    parser.add_argument("--memory-mib", type=int, default=128)
    parser.add_argument("--timeout", type=int, default=30)
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    container_root = Path(args.container_root)
    package = Path(args.package).resolve()
    restore_elf = Path(args.restore_elf).resolve()
    checkpoint_path = package / "checkpoint.json"
    checkpoint = json.loads(checkpoint_path.read_text())
    capture = json.loads(
        (package / checkpoint["artifacts"]["registers"]["path"]).read_text()
    )
    reference_path = package / checkpoint["artifacts"]["roi_reference"]["path"]
    reference = json.loads(reference_path.read_text())
    replay_instructions = int(reference["observed_insns"]) - int(
        capture["observed_insns"]
    )
    if replay_instructions <= 0:
        raise ValueError("ROI reference must follow the checkpoint boundary")

    replay_dir = package / "replay"
    replay_dir.mkdir(parents=True, exist_ok=True)
    replay_regs = replay_dir / "replay.regs"
    replay_log = replay_dir / "qemu.log"
    replay_container = container_path(replay_regs, repo_root, container_root)
    elf_container = container_path(restore_elf, repo_root, container_root)
    qemu = container_root / (
        "toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-"
        "B20250721-0303/bin/qemu-system-riscv64"
    )
    plugin = container_root / "tools/qemu-plugins/restore_replay.so"
    start_pc = int(capture["registers"]["pc"]["value"], 0)
    plugin_arg = (
        f"{plugin},start_pc=0x{start_pc:x},instructions={replay_instructions},"
        f"outfile={replay_container},exit_after=1"
    )
    command = [
        "docker", "exec", args.container,
        "timeout", f"{args.timeout}s",
        str(qemu),
        "-machine", "virt",
        "-cpu", "c910",
        "-m", f"{args.memory_mib}M",
        "-smp", "1",
        "-nographic",
        "-monitor", "none",
        "-bios", "none",
        "-plugin", plugin_arg,
        "-device", f"loader,file={elf_container},cpu-num=0",
    ]
    completed = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, check=False)
    replay_log.write_text(completed.stdout)
    if completed.returncode != 0:
        raise SystemExit(
            f"system QEMU replay failed rc={completed.returncode}; see {replay_log}"
        )
    records = parse_probe(replay_regs)
    if len(records) != 1:
        raise ValueError(f"expected one replay record, got {len(records)}")
    record = records[0]
    observed = normalize_registers(record["registers"], record["tb_pc"])
    differences = compare_registers(reference["registers"], observed)
    passed = (
        record.get("replay_status") == "ok"
        and int(record["boundary_error_insns"]) == 0
        and not differences
    )
    report = {
        "format": "openc910-spec-l3-restore-replay-v1",
        "checkpoint_id": checkpoint["checkpoint_id"],
        "passed": passed,
        "capture_observed_instructions": int(capture["observed_insns"]),
        "reference_observed_instructions": int(reference["observed_insns"]),
        "replay_instructions": replay_instructions,
        "replay_status": record.get("replay_status"),
        "boundary_error_instructions": int(record["boundary_error_insns"]),
        "reference_pc": reference["registers"]["pc"]["value"],
        "replay_pc": observed["pc"]["value"],
        "compared_registers": len(REQUIRED_REGISTERS),
        "register_differences": differences,
        "restore_elf_sha256": sha256(restore_elf),
        "replay_registers_sha256": sha256(replay_regs),
    }
    report_path = replay_dir / "replay_validation.json"
    report_path.write_text(json.dumps(report, indent=2) + "\n")
    checkpoint["artifacts"]["restore_replay"] = {
        "path": "replay/replay_validation.json",
        "bytes": report_path.stat().st_size,
        "sha256": sha256(report_path),
    }
    checkpoint["validation"]["qemu_restore_replay_match"] = passed
    checkpoint["validation"]["qemu_restore_replay_registers"] = len(
        REQUIRED_REGISTERS
    )
    checkpoint["validation"]["qemu_restore_replay_report"] = str(
        report_path.relative_to(package)
    )
    if passed:
        checkpoint["status"] = "qemu_replay_validated"
    checkpoint_path.write_text(json.dumps(checkpoint, indent=2) + "\n")
    print(
        f"checkpoint={checkpoint['checkpoint_id']} passed={passed} "
        f"instructions={replay_instructions} differences={len(differences)}"
    )
    if not passed:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
