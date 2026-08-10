#!/usr/bin/env python3
"""XuanTie QEMU reference execution and C910 RTL terminal-state comparison."""

from __future__ import annotations

import functools
import hashlib
import json
import os
import re
import shutil
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path


VERIFY_ROOT = Path(__file__).resolve().parent
REPO_ROOT = VERIFY_ROOT.parent
DEFAULT_QEMU_ROOT = (
    REPO_ROOT
    / "toolchains"
    / "Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303"
)
DEFAULT_QEMU_PLUGIN = REPO_ROOT / "tools" / "qemu-plugins" / "arch_state.so"
DEFAULT_QEMU_CONTAINER = "openc910-qemu"
QEMU_GUEST_MEMORY = "3G"
STATE_FILENAME = "qemu_arch_state.json"
RTL_STATE_FILENAME = "rtl_arch_state.json"
RESULT_FILENAME = "qemu_result.json"
DIFFERENTIAL_FILENAME = "differential.json"

GPR_NAMES = (
    "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6",
)
# smart_run/crt0.S overwrites these while publishing PASS/FAIL. Because the
# RTL detects the magic at writeback in an out-of-order machine, its snapshot
# can contain a mixture of __exit and the immediately following __fail writes.
TERMINATION_PROTOCOL_GPRS = frozenset({"ra", "sp", "gp", "tp", "a0"})
REGISTER_VALUE_RE = re.compile(r"^0x[0-9a-fA-FxXzZ]{1,16}$")


class ReferenceError(RuntimeError):
    """Raised when QEMU execution or architectural comparison is invalid."""


@dataclass(frozen=True)
class QemuTools:
    container: str
    system_binary: Path
    plugin: Path
    docker: Path


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def atomic_json(path: Path, payload: dict) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def discover_qemu_tools(
    qemu_root: Path = DEFAULT_QEMU_ROOT,
    plugin: Path = DEFAULT_QEMU_PLUGIN,
    container: str = DEFAULT_QEMU_CONTAINER,
) -> QemuTools:
    docker = shutil.which("docker")
    if not docker:
        raise ReferenceError("docker is not available")
    return QemuTools(
        container=container,
        system_binary=qemu_root.resolve() / "bin" / "qemu-system-riscv64",
        plugin=plugin.resolve(),
        docker=Path(docker),
    )


def container_path(path: Path) -> str:
    resolved = path.resolve()
    try:
        relative = resolved.relative_to(REPO_ROOT)
    except ValueError as error:
        raise ReferenceError(
            f"QEMU input/output must be under mounted repository {REPO_ROOT}: {resolved}"
        ) from error
    return f"/work/{relative.as_posix()}"


def docker_command(tools: QemuTools, *command: str) -> list[str]:
    return [
        str(tools.docker),
        "exec",
        "--user",
        f"{os.getuid()}:{os.getgid()}",
        tools.container,
        *command,
    ]


def command_output(command: list[str]) -> str:
    completed = subprocess.run(
        command,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if completed.returncode != 0:
        raise ReferenceError(
            f"command failed ({completed.returncode}): {' '.join(command)}\n"
            f"{completed.stdout}"
        )
    return completed.stdout


@functools.lru_cache(maxsize=None)
def check_qemu(tools: QemuTools) -> dict:
    if not tools.system_binary.is_file() or not os.access(tools.system_binary, os.X_OK):
        raise ReferenceError(f"QEMU system binary is unavailable: {tools.system_binary}")
    if not tools.plugin.is_file():
        raise ReferenceError(f"QEMU architectural-state plugin is unavailable: {tools.plugin}")
    plugin_source = tools.plugin.with_suffix(".c")
    if (
        plugin_source.is_file()
        and plugin_source.stat().st_mtime_ns > tools.plugin.stat().st_mtime_ns
    ):
        raise ReferenceError(
            f"QEMU architectural-state plugin is stale; rebuild it from {plugin_source}"
        )
    running = command_output(
        [str(tools.docker), "inspect", "-f", "{{.State.Running}}", tools.container]
    ).strip()
    if running != "true":
        raise ReferenceError(f"QEMU container is not running: {tools.container}")
    qemu = container_path(tools.system_binary)
    version = command_output(docker_command(tools, qemu, "--version")).splitlines()[0]
    cpus = command_output(docker_command(tools, qemu, "-cpu", "help"))
    machines = command_output(docker_command(tools, qemu, "-machine", "help"))
    if not re.search(r"^\s*c910\s*$", cpus, re.MULTILINE):
        raise ReferenceError("XuanTie QEMU does not advertise CPU model c910")
    if not re.search(r"^smarth\s", machines, re.MULTILINE):
        raise ReferenceError("XuanTie QEMU does not advertise machine smarth")
    return {
        "container": tools.container,
        "qemu_version": version,
        "qemu_system": str(tools.system_binary),
        "qemu_sha256": sha256(tools.system_binary),
        "plugin": str(tools.plugin),
        "plugin_sha256": sha256(tools.plugin),
        "machine": "smarth",
        "cpu": "c910",
        "guest_memory": QEMU_GUEST_MEMORY,
    }


def run_reference(
    elf: Path,
    case_dir: Path,
    tools: QemuTools,
    timeout_seconds: int,
    force: bool,
) -> dict:
    elf = elf.resolve()
    case_dir = case_dir.resolve()
    if not elf.is_file():
        raise ReferenceError(f"ELF is missing: {elf}")
    if timeout_seconds < 1:
        raise ReferenceError("QEMU timeout must be positive")
    case_dir.mkdir(parents=True, exist_ok=True)
    generated = (
        case_dir / "qemu_reference.elf",
        case_dir / "qemu_reference.console.log",
        case_dir / STATE_FILENAME,
        case_dir / RESULT_FILENAME,
    )
    existing = [path for path in generated if path.exists()]
    if existing and not force:
        raise ReferenceError(
            f"QEMU output exists; pass --force to replace: {existing[0]}"
        )
    for path in existing:
        path.unlink()

    provenance = check_qemu(tools)
    reference_elf = case_dir / "qemu_reference.elf"
    shutil.copy2(elf, reference_elf)
    source_elf_sha256 = sha256(elf)
    executed_elf_sha256 = sha256(reference_elf)
    if source_elf_sha256 != executed_elf_sha256:
        raise ReferenceError("QEMU ELF copy failed its SHA-256 integrity check")
    state_path = case_dir / STATE_FILENAME
    console_path = case_dir / "qemu_reference.console.log"
    qemu = container_path(tools.system_binary)
    command = docker_command(
        tools,
        "timeout",
        "--signal=TERM",
        "--kill-after=2",
        f"{timeout_seconds}s",
        qemu,
        "-M",
        "smarth",
        "-m",
        QEMU_GUEST_MEMORY,
        "-cpu",
        "c910",
        "-nographic",
        "-monitor",
        "none",
        "-serial",
        "none",
        "-bios",
        "none",
        "-kernel",
        container_path(reference_elf),
        "-plugin",
        (
            f"{container_path(tools.plugin)},"
            f"outfile={container_path(state_path)},exit_after=1"
        ),
    )
    started = time.monotonic()
    completed = subprocess.run(
        command,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout_seconds + 10,
        check=False,
    )
    elapsed = time.monotonic() - started
    console_path.write_text(completed.stdout, encoding="utf-8")

    state = None
    if state_path.is_file():
        try:
            state = json.loads(state_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as error:
            raise ReferenceError(f"invalid QEMU state JSON: {state_path}") from error
        if state.get("format") != "openc910-qemu-arch-state-v1":
            raise ReferenceError(f"unsupported QEMU state format: {state_path}")
    if completed.returncode == 124:
        status = "TIMEOUT"
    elif state and state.get("status") in {"PASS", "FAIL"}:
        status = str(state["status"])
    else:
        status = "ERROR"

    result = {
        "format": "openc910-qemu-reference-result-v1",
        "case": case_dir.name,
        "status": status,
        "qemu_exit": completed.returncode,
        "elapsed_seconds": round(elapsed, 3),
        "timeout_seconds": timeout_seconds,
        "elf": str(elf),
        "elf_sha256": executed_elf_sha256,
        "source_elf_sha256": source_elf_sha256,
        "state": str(state_path),
        "state_sha256": sha256(state_path) if state_path.is_file() else None,
        "provenance": provenance,
    }
    atomic_json(case_dir / RESULT_FILENAME, result)
    return result


def parse_rtl_terminal_state(state_path: Path) -> dict:
    if not state_path.is_file():
        raise ReferenceError(
            f"RTL architectural-state snapshot is missing: {state_path}; "
            "recompile simv so tb.v can emit rtl_arch_state.json"
        )
    try:
        state = json.loads(state_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ReferenceError(f"invalid RTL state JSON: {state_path}") from error
    if state.get("format") != "openc910-rtl-arch-state-v1":
        raise ReferenceError(f"unsupported RTL state format: {state_path}")
    if state.get("status") not in {"PASS", "FAIL"}:
        raise ReferenceError(f"invalid RTL terminal status: {state_path}")
    raw_registers = state.get("registers")
    if not isinstance(raw_registers, dict):
        raise ReferenceError(f"RTL state has no register map: {state_path}")
    missing = sorted(set(GPR_NAMES) - raw_registers.keys())
    if missing:
        raise ReferenceError(f"RTL terminal register map is incomplete: {missing}")
    registers = {}
    for name in GPR_NAMES:
        value = str(raw_registers[name]).lower()
        if not REGISTER_VALUE_RE.fullmatch(value):
            raise ReferenceError(f"invalid RTL register value for {name}: {value!r}")
        registers[name] = value
    state["registers"] = registers
    return state


def compare_reference(rtl_case: Path, reference_case: Path) -> dict:
    rtl_case = rtl_case.resolve()
    reference_case = reference_case.resolve()
    rtl_result_path = rtl_case / "result.json"
    stage_path = rtl_case / "stage.json"
    qemu_result_path = reference_case / RESULT_FILENAME
    rtl_state_path = rtl_case / RTL_STATE_FILENAME
    qemu_state_path = reference_case / STATE_FILENAME
    for path in (
        rtl_result_path,
        stage_path,
        rtl_state_path,
        qemu_result_path,
        qemu_state_path,
    ):
        if not path.is_file():
            raise ReferenceError(f"comparison input is missing: {path}")

    rtl_result = json.loads(rtl_result_path.read_text(encoding="utf-8"))
    stage = json.loads(stage_path.read_text(encoding="utf-8"))
    qemu_result = json.loads(qemu_result_path.read_text(encoding="utf-8"))
    qemu_state = json.loads(qemu_state_path.read_text(encoding="utf-8"))
    if qemu_result.get("format") != "openc910-qemu-reference-result-v1":
        raise ReferenceError(f"unsupported QEMU result format: {qemu_result_path}")
    if qemu_state.get("format") != "openc910-qemu-arch-state-v1":
        raise ReferenceError(f"unsupported QEMU state format: {qemu_state_path}")
    if stage.get("elf_sha256") != qemu_result.get("elf_sha256"):
        raise ReferenceError(
            "RTL and QEMU did not execute the same ELF: "
            f"{stage.get('elf_sha256')} != {qemu_result.get('elf_sha256')}"
        )

    rtl_state = parse_rtl_terminal_state(rtl_state_path)
    qemu_registers = dict(qemu_state.get("registers", {}))
    if "fp" in qemu_registers:
        qemu_registers["s0"] = qemu_registers["fp"]
    mismatches = []
    ignored_unknown = []
    compared = []
    for name in GPR_NAMES:
        if name in TERMINATION_PROTOCOL_GPRS:
            continue
        rtl_value = rtl_state["registers"][name]
        rtl_hex_digits = rtl_value[2:]
        if "x" in rtl_hex_digits or "z" in rtl_hex_digits:
            ignored_unknown.append(name)
            continue
        if name not in qemu_registers:
            mismatches.append({"register": name, "rtl": rtl_value, "qemu": None})
            continue
        try:
            rtl_integer = int(rtl_value, 16)
            qemu_integer = int(str(qemu_registers[name]), 16)
        except ValueError as error:
            raise ReferenceError(f"invalid register value for {name}") from error
        compared.append(name)
        if rtl_integer != qemu_integer:
            mismatches.append(
                {
                    "register": name,
                    "rtl": f"0x{rtl_integer:016x}",
                    "qemu": f"0x{qemu_integer:016x}",
                }
            )

    pass_conditions = {
        "same_elf": True,
        "rtl_pass": rtl_result.get("status") == "PASS",
        "rtl_snapshot_pass": rtl_state.get("status") == "PASS",
        "qemu_pass": qemu_result.get("status") == "PASS",
        "qemu_snapshot_pass": qemu_state.get("status") == "PASS",
        "known_gprs_match": not mismatches,
        "known_gpr_count_nonzero": bool(compared),
    }
    status = "PASS" if all(pass_conditions.values()) else "FAIL"
    report = {
        "format": "openc910-qemu-rtl-differential-v2",
        "case": rtl_case.name,
        "status": status,
        "pass_conditions": pass_conditions,
        "coverage": {
            "compared_integer_registers": compared,
            "compared_integer_register_count": len(compared),
            "ignored_termination_protocol_registers": sorted(
                TERMINATION_PROTOCOL_GPRS
            ),
            "ignored_rtl_unknown_registers": ignored_unknown,
            "not_compared": [
                "floating-point registers",
                "CSRs",
                "memory signature/store data",
                "interrupt and exception side effects",
                "cycle and microarchitectural state",
            ],
        },
        "rtl_terminal": {
            "status": rtl_state.get("status"),
            "detection_cycle": rtl_state.get("detection_cycle"),
            "retired_instructions": rtl_state.get("retired_instructions"),
            "state_sha256": sha256(rtl_state_path),
        },
        "qemu_terminal": {
            "pc": qemu_state.get("terminal_pc"),
            "executed_instructions": qemu_state.get("executed_instructions"),
        },
        "mismatches": mismatches,
        "rtl_case": str(rtl_case),
        "reference_case": str(reference_case),
        "elf_sha256": stage.get("elf_sha256"),
    }
    atomic_json(rtl_case / DIFFERENTIAL_FILENAME, report)
    return report
