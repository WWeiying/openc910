#!/usr/bin/env python3
"""OpenC910 RISC-V RTL runner with an optional XuanTie QEMU reference backend."""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

from qemu_reference import (
    DEFAULT_QEMU_CONTAINER,
    DEFAULT_QEMU_PLUGIN,
    DEFAULT_QEMU_ROOT,
    RTL_STATE_FILENAME,
    ReferenceError,
    check_qemu,
    compare_reference,
    discover_qemu_tools,
    run_reference,
)


VERIFY_ROOT = Path(__file__).resolve().parent
REPO_ROOT = VERIFY_ROOT.parent
DEFAULT_TOOLCHAIN = REPO_ROOT / "toolchains" / "Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0"
DEFAULT_OUT = VERIFY_ROOT / "out"
DEFAULT_SIMV = DEFAULT_OUT / "rtl-build" / "work" / "simv"
CONVERTER = REPO_ROOT / "smart_run" / "tests" / "bin" / "Srec2vmem"
CONFIG_PATH = VERIFY_ROOT / "config" / "c910_rv64gc.json"
LINKER_PATH = VERIFY_ROOT / "config" / "link.ld"
SMOKE_SOURCE = VERIFY_ROOT / "tests" / "rv64gc_harness_smoke.S"
RTL_TB_SOURCE = REPO_ROOT / "smart_run" / "logical" / "tb" / "tb.v"
RTL_SOURCE_ROOTS = (
    REPO_ROOT / "smart_run" / "logical",
    REPO_ROOT / "C910_RTL_FACTORY" / "gen_rtl",
)
RTL_BUILD_INPUTS = (VERIFY_ROOT / "Makefile", VERIFY_ROOT / "config" / "symbols.svh")


class VerificationError(RuntimeError):
    pass


@dataclass(frozen=True)
class Tools:
    gcc: Path
    objcopy: Path
    objdump: Path
    readelf: Path
    nm: Path
    converter: Path
    simv: Path


def load_config() -> dict:
    return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))


def tool_path(root: Path, name: str) -> Path:
    return root / "bin" / f"riscv64-unknown-elf-{name}"


def discover_tools(toolchain: Path, simv: Path) -> Tools:
    return Tools(
        gcc=tool_path(toolchain, "gcc"),
        objcopy=tool_path(toolchain, "objcopy"),
        objdump=tool_path(toolchain, "objdump"),
        readelf=tool_path(toolchain, "readelf"),
        nm=tool_path(toolchain, "nm"),
        converter=CONVERTER,
        simv=simv,
    )


def command_output(command: list[str], cwd: Path | None = None) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if result.returncode != 0:
        raise VerificationError(
            f"command failed ({result.returncode}): {' '.join(command)}\n{result.stdout}"
        )
    return result.stdout


def require_file(path: Path, description: str, executable: bool = False) -> None:
    if not path.is_file():
        raise VerificationError(f"missing {description}: {path}")
    if executable and not os.access(path, os.X_OK):
        raise VerificationError(f"{description} is not executable: {path}")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def latest_rtl_input_mtime_ns() -> int:
    suffixes = {".v", ".sv", ".V", ".h", ".fl"}
    mtimes = [
        path.stat().st_mtime_ns
        for root in RTL_SOURCE_ROOTS
        for path in root.rglob("*")
        if path.is_file() and path.suffix in suffixes
    ]
    mtimes.extend(
        path.stat().st_mtime_ns for path in RTL_BUILD_INPUTS if path.is_file()
    )
    return max(mtimes, default=0)


def git_revision() -> str:
    try:
        return command_output(["git", "rev-parse", "--short=12", "HEAD"], REPO_ROOT).strip()
    except VerificationError:
        return "unknown"


def check_elf(elf: Path, tools: Tools, config: dict) -> str:
    require_file(elf, "ELF")
    header = command_output([str(tools.readelf), "-h", str(elf)])
    required = ("Class:                             ELF64", "little endian", "Machine:                           RISC-V")
    missing = [text for text in required if text not in header]
    if missing:
        raise VerificationError(f"unsupported ELF {elf}; missing header properties: {missing}")

    entry_match = re.search(r"Entry point address:\s+(0x[0-9a-fA-F]+)", header)
    if not entry_match:
        raise VerificationError(f"cannot read entry point from {elf}")
    entry = int(entry_match.group(1), 16)
    memory = config["memory"]
    start = int(memory["origin"])
    end = start + int(memory["size"])
    if not start <= entry < end:
        raise VerificationError(f"ELF entry 0x{entry:x} is outside smart_run RAM [0x{start:x}, 0x{end:x})")
    return header


def loadable_sections(elf: Path, tools: Tools, config: dict) -> tuple[list[str], list[str]]:
    output = command_output([str(tools.objdump), "-h", str(elf)])
    lines = output.splitlines()
    sections: list[tuple[str, int, int]] = []
    row = re.compile(
        r"^\s*\d+\s+(\S+)\s+([0-9a-fA-F]+)\s+([0-9a-fA-F]+)\s+"
        r"[0-9a-fA-F]+\s+[0-9a-fA-F]+\s+"
    )
    for index, line in enumerate(lines[:-1]):
        match = row.match(line)
        if not match:
            continue
        flags = lines[index + 1]
        if "ALLOC" not in flags or "CONTENTS" not in flags:
            continue
        name, size_text, vma_text = match.groups()
        size = int(size_text, 16)
        vma = int(vma_text, 16)
        if size:
            sections.append((name, vma, size))

    if not sections:
        raise VerificationError(f"ELF has no loadable content sections: {elf}")

    memory = config["memory"]
    origin = int(memory["origin"])
    limit = origin + int(memory["size"])
    split = int(memory["data_origin"])
    data_image_limit = split + int(memory["data_image_size"])
    instruction: list[str] = []
    data: list[str] = []
    for name, vma, size in sections:
        section_end = vma + size
        if vma < origin or section_end > limit:
            raise VerificationError(
                f"section {name} [0x{vma:x}, 0x{section_end:x}) exceeds smart_run RAM"
            )
        if vma < split < section_end:
            raise VerificationError(f"section {name} crosses instruction/data split at 0x{split:x}")
        if section_end <= split:
            instruction.append(name)
        else:
            if section_end > data_image_limit:
                raise VerificationError(
                    f"initialized section {name} ends at 0x{section_end:x}, beyond the "
                    f"smart_run data image limit 0x{data_image_limit:x}"
                )
            data.append(name)

    if not instruction:
        raise VerificationError("ELF contains no initialized section below the data split")
    return instruction, data


def extract_symbols(elf: Path, tools: Tools, entry: int) -> dict[str, int]:
    output = command_output([str(tools.nm), "-n", str(elf)])
    symbols: dict[str, int] = {}
    wanted = {"main", "rvtest_entry_point", "__exit", "perf_monitor_start", "perf_monitor_end"}
    for line in output.splitlines():
        fields = line.split()
        if len(fields) >= 3 and fields[2] in wanted:
            try:
                symbols[fields[2]] = int(fields[0], 16)
            except ValueError:
                continue

    start = symbols.get("main", symbols.get("rvtest_entry_point", entry))
    exit_address = symbols.get("__exit", start)
    return {
        "main": start,
        "exit": exit_address,
        "perf_start": symbols.get("perf_monitor_start", start),
        "perf_end": symbols.get("perf_monitor_end", exit_address),
    }


def prepare_output(directory: Path, force: bool) -> None:
    if directory.exists():
        if not force:
            raise VerificationError(f"output exists; pass --force to replace generated case: {directory}")
        shutil.rmtree(directory)
    directory.mkdir(parents=True)


def elf_entry(header: str) -> int:
    match = re.search(r"Entry point address:\s+(0x[0-9a-fA-F]+)", header)
    assert match
    return int(match.group(1), 16)


def stage_elf(elf: Path, name: str, out_root: Path, tools: Tools, force: bool) -> Path:
    config = load_config()
    header = check_elf(elf, tools, config)
    instruction_sections, data_sections = loadable_sections(elf, tools, config)
    case_dir = out_root / name
    prepare_output(case_dir, force)

    with tempfile.TemporaryDirectory(prefix="c910-stage-", dir=case_dir) as temporary:
        temp = Path(temporary)
        images = {
            "case": ([], temp / "case.hex", temp / "case.pat"),
            "inst": (instruction_sections, temp / "inst.hex", temp / "inst.pat"),
            "data": (data_sections, temp / "data.hex", temp / "data.pat"),
        }
        for kind, (sections, hex_path, pat_path) in images.items():
            if kind != "case" and not sections:
                pat_path.write_text(
                    "@00000000  00000000  00000000  00000000  00000000  \n",
                    encoding="ascii",
                )
                shutil.copy2(pat_path, case_dir / f"{kind}.pat")
                continue
            command = [str(tools.objcopy), "-O", "srec"]
            for section in sections:
                command.extend(["-j", section])
            command.extend([str(elf), str(hex_path)])
            command_output(command)
            command_output([str(tools.converter), str(hex_path), str(pat_path)], cwd=temp)
            if not pat_path.is_file():
                raise VerificationError(f"converter did not create {kind} pattern")
            shutil.copy2(pat_path, case_dir / f"{kind}.pat")

    staged_elf = case_dir / f"{name}.elf"
    shutil.copy2(elf, staged_elf)
    symbols = extract_symbols(elf, tools, elf_entry(header))
    (case_dir / "symbols.args").write_text(
        "".join(
            [
                f"+sym_main={symbols['main']:x}\n",
                f"+sym_exit={symbols['exit']:x}\n",
                f"+sym_perf_start={symbols['perf_start']:x}\n",
                f"+sym_perf_end={symbols['perf_end']:x}\n",
            ]
        ),
        encoding="ascii",
    )
    (case_dir / f"{name}.asm").write_text(
        command_output([str(tools.objdump), "-d", "-S", str(elf)]), encoding="utf-8"
    )
    metadata = {
        "case": name,
        "source_elf": str(elf.resolve()),
        "staged_elf": str(staged_elf),
        "elf_sha256": sha256(elf),
        "git_revision": git_revision(),
        "isa": config["standard_isa"],
        "symbols": {key: f"0x{value:x}" for key, value in symbols.items()},
        "instruction_sections": instruction_sections,
        "data_sections": data_sections,
    }
    (case_dir / "stage.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    return case_dir


def run_staged(case_dir: Path, tools: Tools, timeout_seconds: int) -> dict:
    require_file(tools.simv, "compiled smart_run simulator", executable=True)
    required = ["case.pat", "inst.pat", "data.pat", "symbols.args", "stage.json"]
    for filename in required:
        require_file(case_dir / filename, f"staged input {filename}")

    symbol_args = [line.strip() for line in (case_dir / "symbols.args").read_text().splitlines() if line.strip()]
    command = [str(tools.simv), "-l", "run.vcs.log", *symbol_args]
    started = time.monotonic()
    timed_out = False
    with (case_dir / "simv.console.log").open("w", encoding="utf-8") as console:
        try:
            completed = subprocess.run(
                command,
                cwd=case_dir,
                stdout=console,
                stderr=subprocess.STDOUT,
                timeout=timeout_seconds,
                check=False,
            )
            simulator_exit = completed.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
            simulator_exit = 124
    elapsed = time.monotonic() - started

    report_path = case_dir / "run_case.report"
    report = report_path.read_text(encoding="utf-8", errors="replace").strip() if report_path.is_file() else ""
    if timed_out:
        status = "TIMEOUT"
    elif "TEST PASS" in report:
        status = "PASS"
    elif "TEST FAIL" in report:
        status = "FAIL"
    else:
        status = "ERROR"

    rtl_state_path = case_dir / RTL_STATE_FILENAME
    rtl_state_metadata = None
    if rtl_state_path.is_file():
        try:
            rtl_state = json.loads(rtl_state_path.read_text(encoding="utf-8"))
            rtl_state_metadata = {
                "path": str(rtl_state_path.resolve()),
                "sha256": sha256(rtl_state_path),
                "format": rtl_state.get("format"),
                "status": rtl_state.get("status"),
            }
        except json.JSONDecodeError:
            rtl_state_metadata = {
                "path": str(rtl_state_path.resolve()),
                "sha256": sha256(rtl_state_path),
                "format": None,
                "status": "INVALID_JSON",
            }

    result = {
        "case": case_dir.name,
        "status": status,
        "simulator_exit": simulator_exit,
        "elapsed_seconds": round(elapsed, 3),
        "timeout_seconds": timeout_seconds,
        "report": report,
        "case_directory": str(case_dir.resolve()),
        "simulator": {
            "path": str(tools.simv.resolve()),
            "sha256": sha256(tools.simv),
        },
        "rtl_arch_state": rtl_state_metadata,
    }
    (case_dir / "result.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"{status:<7} {case_dir.name:<40} {elapsed:8.2f}s  {report or 'no report'}")
    return result


def build_smoke(output: Path, tools: Tools) -> Path:
    config = load_config()
    output.parent.mkdir(parents=True, exist_ok=True)
    command = [
        str(tools.gcc),
        f"-march={config['march']}",
        f"-mabi={config['mabi']}",
        "-mcmodel=medany",
        "-mno-relax",
        "-nostdlib",
        "-nostartfiles",
        "-static",
        "-Wl,--build-id=none",
        f"-Wl,-T,{LINKER_PATH}",
        str(SMOKE_SOURCE),
        "-o",
        str(output),
    ]
    command_output(command)
    print(f"BUILT   {output}")
    return output


def write_regression_reports(results: list[dict], out_root: Path) -> None:
    counts = {status: sum(result["status"] == status for result in results) for status in ("PASS", "FAIL", "TIMEOUT", "ERROR")}
    summary = {"total": len(results), "counts": counts, "results": results}
    (out_root / "summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

    suite = ET.Element(
        "testsuite",
        name="openc910-riscv-rtl",
        tests=str(len(results)),
        failures=str(counts["FAIL"]),
        errors=str(counts["ERROR"] + counts["TIMEOUT"]),
        time=f"{sum(result['elapsed_seconds'] for result in results):.3f}",
    )
    for result in results:
        case = ET.SubElement(suite, "testcase", name=result["case"], time=f"{result['elapsed_seconds']:.3f}")
        if result["status"] == "FAIL":
            ET.SubElement(case, "failure", message=result["report"] or "RTL test failed")
        elif result["status"] in {"ERROR", "TIMEOUT"}:
            ET.SubElement(case, "error", message=result["report"] or result["status"])
    ET.ElementTree(suite).write(out_root / "junit.xml", encoding="utf-8", xml_declaration=True)


def valid_case_name(value: str) -> str:
    if not re.fullmatch(r"[A-Za-z0-9_.-]+", value):
        raise argparse.ArgumentTypeError("case name may contain only letters, digits, '.', '_' and '-'")
    return value


def add_common_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--toolchain", type=Path, default=Path(os.environ.get("RISCV_TOOLCHAIN", DEFAULT_TOOLCHAIN)))
    parser.add_argument("--simv", type=Path, default=Path(os.environ.get("C910_SIMV", DEFAULT_SIMV)))


def add_reference_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--qemu-root",
        type=Path,
        default=Path(os.environ.get("QEMU_ROOT", DEFAULT_QEMU_ROOT)),
    )
    parser.add_argument(
        "--qemu-plugin",
        type=Path,
        default=Path(os.environ.get("C910_QEMU_PLUGIN", DEFAULT_QEMU_PLUGIN)),
    )
    parser.add_argument(
        "--qemu-container",
        default=os.environ.get("DOCKER_CONTAINER", DEFAULT_QEMU_CONTAINER),
    )


def doctor(tools: Tools, qemu_tools) -> int:
    checks = [
        ("gcc", tools.gcc, True),
        ("objcopy", tools.objcopy, True),
        ("objdump", tools.objdump, True),
        ("readelf", tools.readelf, True),
        ("nm", tools.nm, True),
        ("Srec2vmem", tools.converter, True),
        ("simv", tools.simv, True),
    ]
    failed = False
    for name, path, executable in checks:
        ready = path.is_file() and (not executable or os.access(path, os.X_OK))
        print(f"{'READY' if ready else 'MISSING':<8} {name:<12} {path}")
        failed |= not ready
    if tools.simv.is_file() and RTL_TB_SOURCE.is_file():
        snapshot_ready = tools.simv.stat().st_mtime_ns >= latest_rtl_input_mtime_ns()
        print(
            f"{'READY' if snapshot_ready else 'STALE':<8} RTL snapshot "
            f"{RTL_TB_SOURCE}"
        )
        if not snapshot_ready:
            print("INFO     rebuild      make rtl-compile")
        failed |= not snapshot_ready
    if tools.gcc.is_file():
        first_line = command_output([str(tools.gcc), "--version"]).splitlines()[0]
        print(f"INFO     toolchain    {first_line}")
    config = load_config()
    print(f"INFO     DUT ISA      {config['standard_isa']} (vendor extensions excluded)")
    print(f"INFO     privilege    {config['privileged_spec']} (ACT4 privileged tests require a compatibility audit)")
    sources = {
        "ACT4 source": VERIFY_ROOT / ".deps" / "riscv-arch-test" / ".git",
        "riscv-tests": VERIFY_ROOT / ".deps" / "riscv-tests" / ".git",
        "riscv-test-env": VERIFY_ROOT / ".deps" / "riscv-tests" / "env" / ".git",
        "riscv-dv": VERIFY_ROOT / ".deps" / "riscv-dv" / ".git",
    }
    for name, path in sources.items():
        print(f"{'READY' if path.exists() else 'OPTIONAL':<8} {name:<12} {path.parent}")
    act_cli = VERIFY_ROOT / ".venv-act4" / "bin" / "act"
    dv_cli = VERIFY_ROOT / ".venv-riscv-dv" / "bin" / "run"
    print(f"{'READY' if act_cli.is_file() else 'OPTIONAL':<8} ACT4 Python {act_cli}")
    print(f"{'READY' if dv_cli.is_file() else 'OPTIONAL':<8} riscv-dv CLI {dv_cli}")
    python311 = shutil.which("python3.11")
    if not act_cli.is_file():
        print(f"INFO     Python 3.11  {python311 or 'not found'}")
    try:
        reference = check_qemu(qemu_tools)
        print(f"READY    QEMU C910    {reference['qemu_version']}")
        print(
            f"INFO     reference    container={reference['container']} "
            f"machine={reference['machine']} cpu={reference['cpu']} "
            f"memory={reference['guest_memory']}"
        )
        print(f"READY    QEMU plugin  {reference['plugin']}")
    except ReferenceError as error:
        failed = True
        print(f"MISSING  QEMU C910    {error}")
    return 2 if failed else 0


def collect_elfs(directory: Path, pattern: str) -> list[Path]:
    if not directory.is_dir():
        raise VerificationError(f"ELF directory does not exist: {directory}")
    return sorted(path for path in directory.glob(pattern) if path.is_file())


def run_differential_case(
    elf: Path,
    name: str,
    out_root: Path,
    tools: Tools,
    qemu_tools,
    rtl_timeout: int,
    qemu_timeout: int,
    force: bool,
) -> dict:
    started = time.monotonic()
    case_dir = stage_elf(elf.resolve(), name, out_root, tools, force)
    rtl_result = run_staged(case_dir, tools, rtl_timeout)
    qemu_result = None
    differential = None
    if rtl_result["status"] == "PASS":
        staged_elf = case_dir / f"{name}.elf"
        qemu_result = run_reference(
            staged_elf, case_dir, qemu_tools, qemu_timeout, force=True
        )
        if qemu_result["status"] == "PASS":
            differential = compare_reference(case_dir, case_dir)

    if differential is not None:
        status = differential["status"]
        report_text = (
            f"RTL=PASS QEMU=PASS GPR mismatches={len(differential['mismatches'])}"
        )
    elif rtl_result["status"] != "PASS":
        status = rtl_result["status"]
        report_text = f"RTL={rtl_result['status']}; QEMU not run"
    else:
        assert qemu_result is not None
        status = qemu_result["status"]
        report_text = f"RTL=PASS QEMU={qemu_result['status']}; comparison not run"

    result = {
        "case": name,
        "status": status,
        "elapsed_seconds": round(time.monotonic() - started, 3),
        "report": report_text,
        "case_directory": str(case_dir.resolve()),
        "rtl_status": rtl_result["status"],
        "qemu_status": qemu_result["status"] if qemu_result else "NOT_RUN",
        "differential_status": differential["status"] if differential else "NOT_RUN",
    }
    (case_dir / "differential_case_result.json").write_text(
        json.dumps(result, indent=2) + "\n", encoding="utf-8"
    )
    print(f"{status:<7} {name:<40} {result['elapsed_seconds']:8.2f}s  {report_text}")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    doctor_parser = subparsers.add_parser("doctor", help="check DUT-side tools")
    add_common_options(doctor_parser)
    add_reference_options(doctor_parser)

    build_parser = subparsers.add_parser("build-smoke", help="build the harness smoke ELF")
    add_common_options(build_parser)
    build_parser.add_argument("--output", type=Path, default=DEFAULT_OUT / "build" / "rv64gc_harness_smoke.elf")

    stage_parser = subparsers.add_parser("stage", help="convert one ELF into smart_run memory images")
    add_common_options(stage_parser)
    stage_parser.add_argument("elf", type=Path)
    stage_parser.add_argument("--name", type=valid_case_name)
    stage_parser.add_argument("--out", type=Path, default=DEFAULT_OUT / "cases")
    stage_parser.add_argument("--force", action="store_true")

    run_parser = subparsers.add_parser("run", help="stage and run one ELF on C910 RTL")
    add_common_options(run_parser)
    run_parser.add_argument("elf", type=Path)
    run_parser.add_argument("--name", type=valid_case_name)
    run_parser.add_argument("--out", type=Path, default=DEFAULT_OUT / "cases")
    run_parser.add_argument("--timeout", type=int, default=1800)
    run_parser.add_argument("--force", action="store_true")

    reference_parser = subparsers.add_parser(
        "reference", help="run one smart_run ELF on XuanTie QEMU c910"
    )
    add_common_options(reference_parser)
    add_reference_options(reference_parser)
    reference_parser.add_argument("elf", type=Path)
    reference_parser.add_argument("--name", type=valid_case_name)
    reference_parser.add_argument("--out", type=Path, default=DEFAULT_OUT / "reference")
    reference_parser.add_argument("--timeout", type=int, default=300)
    reference_parser.add_argument("--force", action="store_true")

    compare_parser = subparsers.add_parser(
        "compare", help="compare an existing RTL case with a QEMU reference case"
    )
    add_common_options(compare_parser)
    compare_parser.add_argument("--rtl-case", type=Path, required=True)
    compare_parser.add_argument("--reference-case", type=Path, required=True)

    diff_parser = subparsers.add_parser(
        "run-diff", help="run the same ELF on C910 RTL and XuanTie QEMU, then compare"
    )
    add_common_options(diff_parser)
    add_reference_options(diff_parser)
    diff_parser.add_argument("elf", type=Path)
    diff_parser.add_argument("--name", type=valid_case_name)
    diff_parser.add_argument("--out", type=Path, default=DEFAULT_OUT / "differential")
    diff_parser.add_argument("--timeout", type=int, default=1800)
    diff_parser.add_argument("--qemu-timeout", type=int, default=300)
    diff_parser.add_argument("--force", action="store_true")

    regress_parser = subparsers.add_parser("regress", help="run a directory of self-checking ELFs")
    add_common_options(regress_parser)
    regress_parser.add_argument("--elf-dir", type=Path, required=True)
    regress_parser.add_argument("--pattern", default="*.elf")
    regress_parser.add_argument("--out", type=Path, default=DEFAULT_OUT / "regression")
    regress_parser.add_argument("--timeout", type=int, default=1800)
    regress_parser.add_argument("--jobs", type=int, default=1)
    regress_parser.add_argument("--force", action="store_true")

    regress_diff_parser = subparsers.add_parser(
        "regress-diff",
        help="run a directory of self-checking ELFs on RTL/QEMU and compare GPRs",
    )
    add_common_options(regress_diff_parser)
    add_reference_options(regress_diff_parser)
    regress_diff_parser.add_argument("--elf-dir", type=Path, required=True)
    regress_diff_parser.add_argument("--pattern", default="*.elf")
    regress_diff_parser.add_argument(
        "--out", type=Path, default=DEFAULT_OUT / "differential-regression"
    )
    regress_diff_parser.add_argument("--timeout", type=int, default=1800)
    regress_diff_parser.add_argument("--qemu-timeout", type=int, default=300)
    regress_diff_parser.add_argument("--force", action="store_true")

    args = parser.parse_args()
    tools = discover_tools(args.toolchain.resolve(), args.simv.resolve())
    try:
        if args.command == "doctor":
            qemu_tools = discover_qemu_tools(
                args.qemu_root, args.qemu_plugin, args.qemu_container
            )
            return doctor(tools, qemu_tools)
        for path, description in [
            (tools.gcc, "RISC-V GCC"),
            (tools.objcopy, "RISC-V objcopy"),
            (tools.objdump, "RISC-V objdump"),
            (tools.readelf, "RISC-V readelf"),
            (tools.nm, "RISC-V nm"),
            (tools.converter, "Srec2vmem"),
        ]:
            require_file(path, description, executable=True)

        if args.command == "build-smoke":
            build_smoke(args.output.resolve(), tools)
            return 0

        if args.command == "stage":
            name = args.name or args.elf.stem
            case_dir = stage_elf(args.elf.resolve(), name, args.out.resolve(), tools, args.force)
            print(f"STAGED  {case_dir}")
            return 0

        if args.command == "run":
            name = args.name or args.elf.stem
            case_dir = stage_elf(args.elf.resolve(), name, args.out.resolve(), tools, args.force)
            result = run_staged(case_dir, tools, args.timeout)
            return 0 if result["status"] == "PASS" else 1

        if args.command == "reference":
            check_elf(args.elf.resolve(), tools, load_config())
            name = args.name or args.elf.stem
            case_dir = args.out.resolve() / name
            prepare_output(case_dir, args.force)
            qemu_tools = discover_qemu_tools(
                args.qemu_root, args.qemu_plugin, args.qemu_container
            )
            result = run_reference(
                args.elf.resolve(), case_dir, qemu_tools, args.timeout, force=True
            )
            print(
                f"{result['status']:<7} {name:<40} "
                f"{result['elapsed_seconds']:8.2f}s  XuanTie QEMU c910"
            )
            return 0 if result["status"] == "PASS" else 1

        if args.command == "compare":
            report = compare_reference(args.rtl_case, args.reference_case)
            print(
                f"{report['status']:<7} {report['case']:<40} "
                f"known_gprs={report['coverage']['compared_integer_register_count']} "
                f"mismatches={len(report['mismatches'])}"
            )
            return 0 if report["status"] == "PASS" else 1

        if args.command == "run-diff":
            name = args.name or args.elf.stem
            qemu_tools = discover_qemu_tools(
                args.qemu_root, args.qemu_plugin, args.qemu_container
            )
            result = run_differential_case(
                args.elf,
                name,
                args.out.resolve(),
                tools,
                qemu_tools,
                args.timeout,
                args.qemu_timeout,
                args.force,
            )
            return 0 if result["status"] == "PASS" else 1

        if args.command == "regress-diff":
            elfs = collect_elfs(args.elf_dir.resolve(), args.pattern)
            if not elfs:
                raise VerificationError(
                    f"no ELF matches {args.pattern!r} under {args.elf_dir}"
                )
            args.out.mkdir(parents=True, exist_ok=True)
            qemu_tools = discover_qemu_tools(
                args.qemu_root, args.qemu_plugin, args.qemu_container
            )
            results = [
                run_differential_case(
                    elf,
                    elf.stem,
                    args.out.resolve(),
                    tools,
                    qemu_tools,
                    args.timeout,
                    args.qemu_timeout,
                    args.force,
                )
                for elf in elfs
            ]
            write_regression_reports(results, args.out.resolve())
            return 0 if all(result["status"] == "PASS" for result in results) else 1

        elfs = collect_elfs(args.elf_dir.resolve(), args.pattern)
        if not elfs:
            raise VerificationError(f"no ELF matches {args.pattern!r} under {args.elf_dir}")
        if args.jobs < 1:
            raise VerificationError("--jobs must be at least 1")
        args.out.mkdir(parents=True, exist_ok=True)

        def execute(elf: Path) -> dict:
            case_dir = stage_elf(elf, elf.stem, args.out.resolve(), tools, args.force)
            return run_staged(case_dir, tools, args.timeout)

        if args.jobs == 1:
            results = [execute(elf) for elf in elfs]
        else:
            with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
                results = list(executor.map(execute, elfs))
        results.sort(key=lambda item: item["case"])
        write_regression_reports(results, args.out.resolve())
        return 0 if all(result["status"] == "PASS" for result in results) else 1
    except (VerificationError, ReferenceError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
