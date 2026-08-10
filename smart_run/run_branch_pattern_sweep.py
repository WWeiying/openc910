#!/usr/bin/env python3
"""Build, run, validate, and summarize the C910 branch-pattern RTL sweep."""

from __future__ import annotations

import argparse
import concurrent.futures
import csv
import fcntl
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
WORK_DIR = SCRIPT_DIR / "work"
RESULT_SCHEMA_VERSION = 2
DEFAULT_TOOLCHAIN_BIN = (
    REPO_ROOT
    / "toolchains"
    / "Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0"
    / "bin"
)
CONTRACT_FILES = (
    Path("smart_run/run_branch_pattern_sweep.py"),
    Path("smart_run/setup/smart_cfg.mk"),
    Path("smart_run/tests/lib/Makefile"),
    Path("smart_run/tests/cases/bench_br_pattern/main.c"),
    Path("smart_run/tests/cases/bench_br_pattern/generate_branch_sites.py"),
)
COMPILED_CONFIG_SYMBOLS = {
    "bp_compiled_branches": "branches",
    "bp_compiled_pattern_length": "pattern_length",
    "bp_compiled_random_mode": "random_mode",
    "bp_compiled_seed": "seed",
    "bp_compiled_warmup_iterations": "warmup_iterations",
    "bp_compiled_measure_iterations": "measure_iterations",
}

PROFILES = {
    "smoke": {
        "branches": (1, 8),
        "patterns": (2, 16),
        "repeats": 1,
    },
    "quick": {
        "branches": (1, 4, 16),
        "patterns": (2, 8, 32, 128),
        "repeats": 1,
    },
    "rtl": {
        "branches": (1, 2, 4, 8, 16, 32, 64),
        "patterns": (2, 4, 8, 16, 32, 64, 128, 256),
        "repeats": 1,
    },
    "wide-width": {
        "branches": (1, 2, 4, 8, 16, 32, 64, 128, 256, 512),
        "patterns": (2, 4, 6, 8, 12, 16, 24, 32, 48, 64),
        "repeats": 1,
    },
    "wide-mixed": {
        "branches": (1, 2, 4, 8, 16, 32, 64, 128, 256, 512),
        "patterns": (96, 128, 192, 256, 384, 512),
        "repeats": 1,
    },
    "wide-long": {
        "branches": (1, 2, 4, 8, 16, 32, 64, 128, 256, 512),
        "patterns": (768, 1024, 1536, 2048, 3072, 4096, 6144, 8192),
        "repeats": 1,
    },
    "full": {
        "branches": (1, 2, 4, 8, 16, 32, 64, 128, 256, 512),
        "patterns": (
            2, 4, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192, 256, 512,
            600, 768, 1024, 1536, 2048, 3072, 4096, 5120, 6144, 8192,
            10240, 12288, 16384, 24576, 32768, 65536,
        ),
        "repeats": 3,
    },
}

MODE_VALUES = {"predictable": 0, "random": 1}
CONDITIONAL_MNEMONICS = {
    "beq", "bne", "blt", "bge", "bltu", "bgeu",
    "beqz", "bnez", "blez", "bgez", "bltz", "bgtz",
    "c.beqz", "c.bnez",
}

KERNEL_ROW_RE = re.compile(
    r"^\|\s*Kernel\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|",
    re.MULTILINE,
)
DETAIL_ROW_RE = re.compile(
    r"^\|\s*Kernel\s*\|\s*([A-Za-z0-9_]+)\s*\|\s*(\d+)\s*\|",
    re.MULTILINE,
)
BRANCH_TOTAL_RE = re.compile(
    r"^BRANCH_PC_TOTAL phase=Kernel kind=cond exec=(\d+) mispred=(\d+)$",
    re.MULTILINE,
)
BRANCH_PC_RE = re.compile(
    r"^BRANCH_PC phase=Kernel kind=cond pc=0x([0-9a-fA-F]+) "
    r"exec=(\d+) mispred=(\d+)\b",
    re.MULTILINE,
)
DISASM_RE = re.compile(
    r"^\s*([0-9a-fA-F]+):\s+(?:[0-9a-fA-F]{4,16}\s+)+([.$A-Za-z][.$A-Za-z0-9_]*)\b"
)


class SweepError(RuntimeError):
    """Raised when a measurement cannot satisfy the evidence contract."""


@dataclass(frozen=True)
class RunConfig:
    branches: int
    pattern_length: int
    repeat: int
    mode: str
    seed: int
    warmup_iterations: int
    measure_iterations: int

    @property
    def run_id(self) -> str:
        return (
            f"b{self.branches:03d}_p{self.pattern_length:05d}_"
            f"r{self.repeat}_{self.mode}"
        )

    @property
    def target_dynamic_branches(self) -> int:
        return self.branches * self.measure_iterations


@dataclass(frozen=True)
class StagedRun:
    config: RunConfig
    run_dir: Path
    branch_region_start: int
    branch_region_end: int
    static_branch_count: int
    compiled_config: dict[str, int]
    text_sha256: str


def parse_positive_csv(value: str) -> tuple[int, ...]:
    try:
        parsed = tuple(sorted({int(item.strip(), 0) for item in value.split(",")}))
    except ValueError as error:
        raise argparse.ArgumentTypeError(f"invalid integer list: {value}") from error
    if not parsed or parsed[0] <= 0:
        raise argparse.ArgumentTypeError("list must contain positive integers")
    return parsed


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Run real C910 RTL branch-pattern points and emit plotting CSV."
    )
    parser.add_argument("--profile", choices=PROFILES, default="smoke")
    parser.add_argument("--branches", type=parse_positive_csv)
    parser.add_argument("--patterns", type=parse_positive_csv)
    parser.add_argument("--repeats", type=int)
    parser.add_argument("--seed-base", type=int, default=910)
    parser.add_argument("--warmup-periods", type=int, default=2)
    parser.add_argument("--measure-periods", type=int, default=4)
    parser.add_argument("--minimum-warmup-iterations", type=int, default=256)
    parser.add_argument("--minimum-measure-iterations", type=int, default=512)
    parser.add_argument(
        "--max-target-dynamic-branches",
        type=int,
        help="exclude coordinates whose target branches per mode exceed this budget",
    )
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--publish-csv", type=Path)
    parser.add_argument("--simv", type=Path, default=WORK_DIR / "simv")
    parser.add_argument("--timeout-seconds", type=int, default=3600)
    parser.add_argument(
        "--workers",
        type=int,
        default=int(os.environ.get("BRANCH_PATTERN_WORKERS", "4")),
        help="concurrent isolated RTL simulations; software staging remains serial",
    )
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--replace", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument(
        "--allow-waveform-simv",
        action="store_true",
        help="allow a simulator compiled without +define+NO_DUMP",
    )
    return parser


def git_value(*args: str) -> str:
    completed = subprocess.run(
        ["git", "-C", str(REPO_ROOT), *args],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return completed.stdout.strip() or "unknown"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def contract_sha256() -> str:
    digest = hashlib.sha256()
    for relative in CONTRACT_FILES:
        path = REPO_ROOT / relative
        if not path.is_file():
            raise SweepError(f"benchmark contract file is missing: {path}")
        digest.update(str(relative).encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def plan_sha256(plan: Iterable[RunConfig]) -> str:
    payload = [config.__dict__ for config in plan]
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def round_up_multiple(minimum: int, period: int, periods: int) -> int:
    requested = max(minimum, period * periods)
    return ((requested + period - 1) // period) * period


def build_plan(args: argparse.Namespace) -> list[RunConfig]:
    profile = PROFILES[args.profile]
    branches = args.branches or profile["branches"]
    patterns = args.patterns or profile["patterns"]
    repeats = args.repeats if args.repeats is not None else profile["repeats"]
    if not 1 <= repeats <= 100:
        raise SweepError("repeats must be in [1, 100]")
    if max(branches) > 512:
        raise SweepError("branches must not exceed 512")
    if min(patterns) < 2 or max(patterns) > 65536:
        raise SweepError("patterns must be in [2, 65536]")
    if args.warmup_periods < 1 or args.measure_periods < 1:
        raise SweepError("warmup/measure periods must be positive")
    if (
        args.max_target_dynamic_branches is not None
        and args.max_target_dynamic_branches < 1
    ):
        raise SweepError("max target dynamic branches must be positive")

    plan: list[RunConfig] = []
    for branch_count in branches:
        for pattern_length in patterns:
            warmup = round_up_multiple(
                args.minimum_warmup_iterations,
                pattern_length,
                args.warmup_periods,
            )
            measure = round_up_multiple(
                args.minimum_measure_iterations,
                pattern_length,
                args.measure_periods,
            )
            if (
                args.max_target_dynamic_branches is not None
                and branch_count * measure > args.max_target_dynamic_branches
            ):
                continue
            for repeat in range(1, repeats + 1):
                seed = args.seed_base + repeat - 1
                for mode in ("predictable", "random"):
                    plan.append(
                        RunConfig(
                            branches=branch_count,
                            pattern_length=pattern_length,
                            repeat=repeat,
                            mode=mode,
                            seed=seed,
                            warmup_iterations=warmup,
                            measure_iterations=measure,
                        )
                    )
    if not plan:
        raise SweepError("dynamic-branch budget excluded every coordinate")
    return plan


def tool(name: str) -> Path:
    candidate = DEFAULT_TOOLCHAIN_BIN / f"riscv64-unknown-elf-{name}"
    if candidate.is_file():
        return candidate
    located = shutil.which(f"riscv64-unknown-elf-{name}")
    if located:
        return Path(located)
    raise SweepError(f"cannot find riscv64-unknown-elf-{name}")


def read_nm_symbols(elf: Path) -> dict[str, int]:
    output = subprocess.check_output([tool("nm"), "-n", elf], text=True)
    symbols: dict[str, int] = {}
    for line in output.splitlines():
        fields = line.split()
        if len(fields) >= 3:
            symbols[fields[2]] = int(fields[0], 16)
    return symbols


def symbol_addresses(elf: Path) -> tuple[int, int]:
    symbols = read_nm_symbols(elf)
    missing = {
        "branch_pattern_sites_begin",
        "branch_pattern_sites_end",
    } - symbols.keys()
    if missing:
        raise SweepError(f"missing branch-region symbols: {sorted(missing)}")
    start = symbols["branch_pattern_sites_begin"]
    end = symbols["branch_pattern_sites_end"]
    if start >= end:
        raise SweepError(f"invalid branch-region range: 0x{start:x}..0x{end:x}")
    return start, end


def verify_compiled_config(elf: Path, config: RunConfig) -> dict[str, int]:
    symbols = read_nm_symbols(elf)
    missing = sorted(set(COMPILED_CONFIG_SYMBOLS) - symbols.keys())
    if missing:
        raise SweepError(f"ELF is missing compiled-config symbols: {missing}")
    expected = {
        "branches": config.branches,
        "pattern_length": config.pattern_length,
        "random_mode": MODE_VALUES[config.mode],
        "seed": config.seed,
        "warmup_iterations": config.warmup_iterations,
        "measure_iterations": config.measure_iterations,
    }
    compiled = {
        field: symbols[symbol]
        for symbol, field in COMPILED_CONFIG_SYMBOLS.items()
    }
    mismatches = {
        field: (compiled[field], expected[field])
        for field in expected
        if compiled[field] != expected[field]
    }
    if mismatches:
        raise SweepError(f"ELF compile-time configuration mismatch: {mismatches}")
    return compiled


def count_static_branches(asm_path: Path, start: int, end: int) -> int:
    count = 0
    for line in asm_path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = DISASM_RE.match(line)
        if not match:
            continue
        address = int(match.group(1), 16)
        mnemonic = match.group(2)
        if start <= address < end and mnemonic in CONDITIONAL_MNEMONICS:
            count += 1
    return count


def text_section_hash(elf: Path) -> str:
    with tempfile.TemporaryDirectory(prefix="bp-text-") as directory:
        binary = Path(directory) / "text.bin"
        subprocess.run(
            [tool("objcopy"), "-O", "binary", "--only-section=.text", elf, binary],
            check=True,
        )
        return sha256(binary)


def parse_kernel_monitor(text: str) -> dict[str, tuple[str, ...]]:
    rows: dict[str, tuple[str, ...]] = {}
    in_kernel_monitor = False
    for line in text.splitlines():
        if re.match(r"^\|\s*Kernel Monitor\s*\|", line):
            in_kernel_monitor = True
            continue
        if not in_kernel_monitor:
            continue
        if line.startswith("==="):
            break
        if not line.startswith("|"):
            continue
        fields = tuple(field.strip() for field in line.strip().strip("|").split("|"))
        if len(fields) < 2 or not fields[0] or set(fields[0]) == {"-"}:
            continue
        rows[fields[0]] = fields[1:]
    return rows


def parse_run_log(log_path: Path, config: RunConfig, start: int, end: int) -> dict[str, object]:
    text = log_path.read_text(encoding="utf-8", errors="replace")
    kernel = KERNEL_ROW_RE.search(text)
    if not kernel:
        raise SweepError("Kernel performance row is missing")
    total = BRANCH_TOTAL_RE.search(text)
    if not total:
        raise SweepError("Kernel BRANCH_PC_TOTAL evidence is missing; compile PERF_DETAIL=on")

    monitor = parse_kernel_monitor(text)
    required_monitor = {"L1I Miss", "Cond Branch Misp"}
    missing_monitor = sorted(required_monitor - monitor.keys())
    if missing_monitor:
        raise SweepError(f"missing Kernel Monitor rows: {missing_monitor}")

    detail = {name: int(value) for name, value in DETAIL_ROW_RE.findall(text)}
    required_detail = {"retire_bht_mispred", "rtu_global_flush"}
    missing_detail = sorted(required_detail - detail.keys())
    if missing_detail:
        raise SweepError(f"missing Kernel detail counters: {missing_detail}")

    target_mispredictions = 0
    target_mispred_pcs = 0
    for pc_hex, executions, mispredictions in BRANCH_PC_RE.findall(text):
        pc = int(pc_hex, 16)
        if start <= pc < end:
            if int(executions) != config.measure_iterations:
                raise SweepError(
                    f"target branch PC 0x{pc:x} executed {executions} times; "
                    f"expected {config.measure_iterations}"
                )
            target_mispredictions += int(mispredictions)
            target_mispred_pcs += 1

    kernel_cycles = int(kernel.group(1))
    kernel_retired = int(kernel.group(2))
    total_conditional = int(total.group(1))
    total_mispredictions = int(total.group(2))
    monitor_cond_misp = int(monitor["Cond Branch Misp"][0])
    monitor_cond_total = int(monitor["Cond Branch Misp"][1])
    expected_conditional = config.target_dynamic_branches + config.measure_iterations
    if monitor_cond_misp != total_mispredictions or monitor_cond_total != total_conditional:
        raise SweepError(
            "Kernel Monitor Cond Branch Misp does not close with BRANCH_PC_TOTAL: "
            f"({monitor_cond_misp}, {monitor_cond_total}) != "
            f"({total_mispredictions}, {total_conditional})"
        )
    if detail["retire_bht_mispred"] != total_mispredictions:
        raise SweepError(
            "retire_bht_mispred does not close with BRANCH_PC_TOTAL: "
            f"{detail['retire_bht_mispred']} != {total_mispredictions}"
        )
    if target_mispredictions > total_mispredictions:
        raise SweepError("target branch mispredictions exceed Kernel total")
    if total_conditional != expected_conditional:
        raise SweepError(
            "Kernel conditional-branch count does not match target sites plus loop branch: "
            f"{total_conditional} != {expected_conditional}"
        )

    return {
        "kernel_cycles": kernel_cycles,
        "kernel_retired_instructions": kernel_retired,
        "target_executed_branches": config.target_dynamic_branches,
        "target_mispredictions": target_mispredictions,
        "target_mispred_pc_count": target_mispred_pcs,
        "kernel_conditional_branches": total_conditional,
        "kernel_bht_mispredictions": total_mispredictions,
        "kernel_global_flushes": detail["rtu_global_flush"],
        "kernel_l1i_misses": int(monitor["L1I Miss"][0]),
    }


def build_case(
    config: RunConfig,
    simv: Path,
    run_dir: Path,
    timeout: int,
    *,
    contract_hash: str,
    simv_hash: str,
) -> dict[str, object]:
    make_variables = {
        "CASE": "bench_br_pattern",
        "BP_BRANCHES": str(config.branches),
        "BP_PATTERN_LENGTH": str(config.pattern_length),
        "BP_RANDOM_MODE": str(MODE_VALUES[config.mode]),
        "BP_SEED": str(config.seed),
        "BP_WARMUP_ITERATIONS": str(config.warmup_iterations),
        "BP_MEASURE_ITERATIONS": str(config.measure_iterations),
    }
    command = ["make", "-s", "buildcase"] + [f"{key}={value}" for key, value in make_variables.items()]
    build = subprocess.run(
        command,
        cwd=SCRIPT_DIR,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        check=False,
    )
    (run_dir / "build.console.log").write_text(build.stdout, encoding="utf-8")
    if build.returncode != 0:
        raise SweepError(f"software build failed; see {run_dir / 'build.console.log'}")

    elf = WORK_DIR / "bench_br_pattern.elf"
    asm_path = WORK_DIR / "bench_br_pattern.asm"
    symbols_args = WORK_DIR / "symbols.args"
    for path in (elf, asm_path, symbols_args):
        if not path.is_file():
            raise SweepError(f"build output is missing: {path}")

    compiled_config = verify_compiled_config(elf, config)
    start, end = symbol_addresses(elf)
    static_branches = count_static_branches(asm_path, start, end)
    if static_branches != config.branches:
        raise SweepError(
            f"static branch count mismatch in generated region: {static_branches} != {config.branches}"
        )
    section_hash = text_section_hash(elf)

    plusargs = [line.strip() for line in symbols_args.read_text().splitlines() if line.strip()]
    for stale in (
        WORK_DIR / "run.vcs.log",
        WORK_DIR / "run_case.report",
        WORK_DIR / "novas.fsdb",
    ):
        stale.unlink(missing_ok=True)
    started = time.monotonic()
    simulation = subprocess.run(
        [str(simv), "-l", "run.vcs.log", *plusargs],
        cwd=WORK_DIR,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        check=False,
    )
    wall_seconds = time.monotonic() - started
    (run_dir / "simv.console.log").write_text(simulation.stdout, encoding="utf-8")
    if simulation.returncode != 0:
        raise SweepError(f"RTL simulation failed; see {run_dir / 'simv.console.log'}")

    run_log = WORK_DIR / "run.vcs.log"
    if not run_log.is_file():
        raise SweepError("simulator did not produce run.vcs.log")
    report = WORK_DIR / "run_case.report"
    if not report.is_file() or report.read_text(encoding="ascii", errors="replace").strip() != "TEST PASS":
        raise SweepError("RTL run_case.report is missing TEST PASS")
    shutil.copy2(run_log, run_dir / "run.vcs.log")
    shutil.copy2(report, run_dir / "run_case.report")
    shutil.copy2(elf, run_dir / elf.name)
    shutil.copy2(asm_path, run_dir / asm_path.name)
    shutil.copy2(symbols_args, run_dir / symbols_args.name)
    build_log = WORK_DIR / "bench_br_pattern_build.case.log"
    if build_log.is_file():
        shutil.copy2(build_log, run_dir / build_log.name)
    generated_sites = WORK_DIR / "generated_branch_sites.inc"
    if generated_sites.is_file():
        shutil.copy2(generated_sites, run_dir / generated_sites.name)

    metrics = parse_run_log(run_log, config, start, end)
    metrics.update(
        {
            "run_id": config.run_id,
            "branches_in_loop": config.branches,
            "pattern_length": config.pattern_length,
            "repeat": config.repeat,
            "mode": config.mode,
            "seed": config.seed,
            "warmup_iterations": config.warmup_iterations,
            "measure_iterations": config.measure_iterations,
            "branch_region_start": start,
            "branch_region_end": end,
            "static_branch_count": static_branches,
            "compiled_config": compiled_config,
            "text_sha256": section_hash,
            "result_schema_version": RESULT_SCHEMA_VERSION,
            "benchmark_contract_sha256": contract_hash,
            "simv_sha256": simv_hash,
            "simulation_wall_seconds": wall_seconds,
        }
    )
    result_path = run_dir / "result.json"
    temporary_result = result_path.with_suffix(".json.tmp")
    temporary_result.write_text(
        json.dumps(metrics, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    temporary_result.replace(result_path)
    (WORK_DIR / "novas.fsdb").unlink(missing_ok=True)
    return metrics


def stage_parallel_case(config: RunConfig, run_dir: Path, timeout: int) -> StagedRun:
    """Build one ELF in shared work/, then copy every runtime input aside."""
    make_variables = {
        "CASE": "bench_br_pattern",
        "BP_BRANCHES": str(config.branches),
        "BP_PATTERN_LENGTH": str(config.pattern_length),
        "BP_RANDOM_MODE": str(MODE_VALUES[config.mode]),
        "BP_SEED": str(config.seed),
        "BP_WARMUP_ITERATIONS": str(config.warmup_iterations),
        "BP_MEASURE_ITERATIONS": str(config.measure_iterations),
    }
    if run_dir.exists():
        shutil.rmtree(run_dir)
    run_dir.mkdir(parents=True)
    command = ["make", "-s", "buildcase"] + [
        f"{key}={value}" for key, value in make_variables.items()
    ]
    build = subprocess.run(
        command,
        cwd=SCRIPT_DIR,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
        check=False,
    )
    (run_dir / "build.console.log").write_text(build.stdout, encoding="utf-8")
    if build.returncode != 0:
        raise SweepError(f"software build failed; see {run_dir / 'build.console.log'}")

    elf = WORK_DIR / "bench_br_pattern.elf"
    asm_path = WORK_DIR / "bench_br_pattern.asm"
    symbols_args = WORK_DIR / "symbols.args"
    runtime_inputs = (
        WORK_DIR / "case.pat",
        WORK_DIR / "inst.pat",
        WORK_DIR / "data.pat",
        symbols_args,
        elf,
        asm_path,
    )
    for path in runtime_inputs:
        if not path.is_file():
            raise SweepError(f"build output is missing: {path}")

    compiled_config = verify_compiled_config(elf, config)
    start, end = symbol_addresses(elf)
    static_branches = count_static_branches(asm_path, start, end)
    if static_branches != config.branches:
        raise SweepError(
            f"static branch count mismatch in generated region: "
            f"{static_branches} != {config.branches}"
        )
    section_hash = text_section_hash(elf)
    for path in runtime_inputs:
        shutil.copy2(path, run_dir / path.name)
    for optional in (
        WORK_DIR / "bench_br_pattern_build.case.log",
        WORK_DIR / "generated_branch_sites.inc",
    ):
        if optional.is_file():
            shutil.copy2(optional, run_dir / optional.name)

    return StagedRun(
        config=config,
        run_dir=run_dir,
        branch_region_start=start,
        branch_region_end=end,
        static_branch_count=static_branches,
        compiled_config=compiled_config,
        text_sha256=section_hash,
    )


def run_staged_case(
    staged: StagedRun,
    simv: Path,
    timeout: int,
    *,
    contract_hash: str,
    simv_hash: str,
) -> dict[str, object]:
    """Run one fully isolated case directory; safe to call from worker threads."""
    config = staged.config
    run_dir = staged.run_dir
    symbols_args = run_dir / "symbols.args"
    plusargs = [
        line.strip()
        for line in symbols_args.read_text(encoding="ascii").splitlines()
        if line.strip()
    ]
    started = time.monotonic()
    with (run_dir / "simv.console.log").open("w", encoding="utf-8") as console:
        simulation = subprocess.run(
            [str(simv), "-l", "run.vcs.log", *plusargs],
            cwd=run_dir,
            stdout=console,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            check=False,
        )
    wall_seconds = time.monotonic() - started
    if simulation.returncode != 0:
        raise SweepError(f"RTL simulation failed; see {run_dir / 'simv.console.log'}")

    run_log = run_dir / "run.vcs.log"
    report = run_dir / "run_case.report"
    if not run_log.is_file():
        raise SweepError(f"simulator did not produce {run_log}")
    if (
        not report.is_file()
        or report.read_text(encoding="ascii", errors="replace").strip()
        != "TEST PASS"
    ):
        raise SweepError(f"RTL result is missing TEST PASS: {report}")

    metrics = parse_run_log(
        run_log,
        config,
        staged.branch_region_start,
        staged.branch_region_end,
    )
    metrics.update(
        {
            "run_id": config.run_id,
            "branches_in_loop": config.branches,
            "pattern_length": config.pattern_length,
            "repeat": config.repeat,
            "mode": config.mode,
            "seed": config.seed,
            "warmup_iterations": config.warmup_iterations,
            "measure_iterations": config.measure_iterations,
            "branch_region_start": staged.branch_region_start,
            "branch_region_end": staged.branch_region_end,
            "static_branch_count": staged.static_branch_count,
            "compiled_config": staged.compiled_config,
            "text_sha256": staged.text_sha256,
            "result_schema_version": RESULT_SCHEMA_VERSION,
            "benchmark_contract_sha256": contract_hash,
            "simv_sha256": simv_hash,
            "simulation_wall_seconds": wall_seconds,
        }
    )
    result_path = run_dir / "result.json"
    temporary_result = result_path.with_suffix(".json.tmp")
    temporary_result.write_text(
        json.dumps(metrics, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    temporary_result.replace(result_path)
    (run_dir / "novas.fsdb").unlink(missing_ok=True)
    return metrics


def load_result(
    path: Path,
    config: RunConfig,
    *,
    contract_hash: str,
    simv_hash: str,
) -> dict[str, object] | None:
    result_path = path / "result.json"
    if not result_path.is_file():
        return None
    try:
        result = json.loads(result_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return None
    expected = {
        "branches_in_loop": config.branches,
        "pattern_length": config.pattern_length,
        "repeat": config.repeat,
        "mode": config.mode,
        "seed": config.seed,
        "warmup_iterations": config.warmup_iterations,
        "measure_iterations": config.measure_iterations,
        "static_branch_count": config.branches,
        "result_schema_version": RESULT_SCHEMA_VERSION,
        "benchmark_contract_sha256": contract_hash,
        "simv_sha256": simv_hash,
    }
    if any(result.get(key) != value for key, value in expected.items()):
        return None
    return result


def paired_rows(results: Iterable[dict[str, object]]) -> list[dict[str, object]]:
    grouped: dict[tuple[int, int, int], dict[str, dict[str, object]]] = {}
    for result in results:
        key = (
            int(result["branches_in_loop"]),
            int(result["pattern_length"]),
            int(result["repeat"]),
        )
        grouped.setdefault(key, {})[str(result["mode"])] = result

    rows: list[dict[str, object]] = []
    for (branches, pattern, repeat), modes in sorted(grouped.items()):
        if set(modes) != {"predictable", "random"}:
            continue
        predictable = modes["predictable"]
        random = modes["random"]
        if predictable["text_sha256"] != random["text_sha256"]:
            raise SweepError(
                f"paired .text differs for branches={branches}, pattern={pattern}, repeat={repeat}"
            )
        row: dict[str, object] = {
            "branches_in_loop": branches,
            "pattern_length": pattern,
            "repeat": repeat,
            "seed": random["seed"],
            "warmup_iterations": random["warmup_iterations"],
            "measure_iterations": random["measure_iterations"],
            "text_sha256": random["text_sha256"],
        }
        for mode, result in (("random", random), ("predictable", predictable)):
            target = int(result["target_executed_branches"])
            mispredictions = int(result["target_mispredictions"])
            row[f"{mode}_cycles"] = result["kernel_cycles"]
            row[f"{mode}_executed_branches"] = target
            row[f"{mode}_mispredictions"] = mispredictions
            row[f"{mode}_cycles_per_branch"] = int(result["kernel_cycles"]) / target
            row[f"{mode}_mispred_rate_pct"] = 100.0 * mispredictions / target
            row[f"{mode}_kernel_conditional_branches"] = result["kernel_conditional_branches"]
            row[f"{mode}_kernel_bht_mispredictions"] = result["kernel_bht_mispredictions"]
            row[f"{mode}_kernel_global_flushes"] = result["kernel_global_flushes"]
            row[f"{mode}_kernel_l1i_misses"] = result["kernel_l1i_misses"]
            row[f"{mode}_simulation_wall_seconds"] = result["simulation_wall_seconds"]
        rows.append(row)
    return rows


def write_csv(rows: list[dict[str, object]], destination: Path) -> None:
    if not rows:
        raise SweepError("no complete random/predictable pair is available for CSV")
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_suffix(destination.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    temporary.replace(destination)


def publish_rows(
    results: list[dict[str, object]],
    output: Path,
    publish_csv: Path | None,
) -> list[dict[str, object]]:
    rows = paired_rows(results)
    if not rows:
        return rows
    csv_path = output / "branch_pattern_results.csv"
    write_csv(rows, csv_path)
    if publish_csv is not None:
        publish = publish_csv.expanduser().resolve()
        publish.parent.mkdir(parents=True, exist_ok=True)
        temporary = publish.with_suffix(publish.suffix + ".tmp")
        shutil.copy2(csv_path, temporary)
        temporary.replace(publish)
    return rows


def prepare_output(
    args: argparse.Namespace,
    plan: list[RunConfig],
    simv: Path,
    *,
    contract_hash: str,
    simv_hash: str,
    plan_hash: str,
) -> Path:
    short = git_value("rev-parse", "--short=12", "HEAD")
    status = git_value("status", "--porcelain")
    dirty = "dirty" if status and status != "unknown" else "clean"
    output = args.output_dir or SCRIPT_DIR / "results" / f"branch_pattern_{args.profile}_{short}_{dirty}"
    output = output.expanduser().resolve()
    if output.exists():
        if args.replace:
            shutil.rmtree(output)
        elif not args.resume:
            raise SweepError(f"output directory exists; use --resume or --replace: {output}")
    output.mkdir(parents=True, exist_ok=True)
    metadata = {
        "profile": args.profile,
        "result_schema_version": RESULT_SCHEMA_VERSION,
        "benchmark_contract_sha256": contract_hash,
        "plan_sha256": plan_hash,
        "git_commit": git_value("rev-parse", "HEAD"),
        "git_status": git_value("status", "--short"),
        "simv": str(simv),
        "simv_sha256": simv_hash,
        "run_count": len(plan),
        "paired_measurements": len(plan) // 2,
        "coordinates": len({(item.branches, item.pattern_length) for item in plan}),
        "max_target_dynamic_branches": args.max_target_dynamic_branches,
        "minimum_warmup_iterations": args.minimum_warmup_iterations,
        "minimum_measure_iterations": args.minimum_measure_iterations,
        "warmup_periods": args.warmup_periods,
        "measure_periods": args.measure_periods,
        "workers": args.workers,
        "no_interpolation": True,
    }
    metadata_path = output / "run_info.json"
    if args.resume and metadata_path.is_file():
        previous = json.loads(metadata_path.read_text(encoding="utf-8"))
        for key in (
            "git_commit",
            "simv_sha256",
            "profile",
            "result_schema_version",
            "benchmark_contract_sha256",
            "plan_sha256",
        ):
            if previous.get(key) != metadata[key]:
                raise SweepError(f"resume provenance mismatch for {key}")
    else:
        metadata_path.write_text(
            json.dumps(metadata, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
    return output


def validate_simulator(simv: Path, allow_waveform: bool) -> Path:
    simv = simv.expanduser().resolve()
    if not simv.is_file() or not os.access(simv, os.X_OK):
        raise SweepError(f"simulator is missing or not executable: {simv}")
    compile_log = WORK_DIR / "comp.vcs.log"
    if not compile_log.is_file():
        raise SweepError("work/comp.vcs.log is missing")
    text = compile_log.read_text(encoding="utf-8", errors="replace")
    if "+define+PERF_DETAIL" not in text:
        raise SweepError("simulator must be compiled with PERF_DETAIL=on")
    if "+define+NO_DUMP" not in text and not allow_waveform:
        raise SweepError(
            "simulator has waveform dumping enabled; rebuild with "
            "'make compile DUMP=off PERF_DETAIL=on' or pass --allow-waveform-simv"
        )
    return simv


def acquire_lock():
    lock_path = SCRIPT_DIR / ".run_bench.lock"
    stream = lock_path.open("a+", encoding="ascii")
    try:
        fcntl.flock(stream.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError as error:
        stream.close()
        raise SweepError("run_bench or another branch-pattern sweep is active") from error
    stream.seek(0)
    stream.truncate()
    stream.write(f"{os.getpid()}\n")
    stream.flush()
    return stream


def main() -> int:
    args = build_parser().parse_args()
    try:
        if not 1 <= args.workers <= 8:
            raise SweepError("workers must be in [1, 8]")
        plan = build_plan(args)
        print(
            f"profile={args.profile} runs={len(plan)} "
            f"coordinates={len({(item.branches, item.pattern_length) for item in plan})} "
            f"workers={args.workers}"
        )
        max_target = max(config.target_dynamic_branches for config in plan)
        print(f"max target dynamic branches per run={max_target:,}")
        if args.dry_run:
            for config in plan:
                print(config.run_id, config.target_dynamic_branches)
            return 0

        simv = validate_simulator(args.simv, args.allow_waveform_simv)
        simv_hash = sha256(simv)
        contract_hash = contract_sha256()
        current_plan_hash = plan_sha256(plan)
        output = prepare_output(
            args,
            plan,
            simv,
            contract_hash=contract_hash,
            simv_hash=simv_hash,
            plan_hash=current_plan_hash,
        )
        lock = acquire_lock()
        results: list[dict[str, object]] = []
        try:
            if args.workers == 1:
                for index, config in enumerate(plan, start=1):
                    run_dir = output / "runs" / config.run_id
                    run_dir.mkdir(parents=True, exist_ok=True)
                    result = (
                        load_result(
                            run_dir,
                            config,
                            contract_hash=contract_hash,
                            simv_hash=simv_hash,
                        )
                        if args.resume
                        else None
                    )
                    if result is not None:
                        print(f"[{index}/{len(plan)}] {config.run_id}: RESUME")
                    else:
                        print(f"[{index}/{len(plan)}] {config.run_id}: RUN", flush=True)
                        result = build_case(
                            config,
                            simv,
                            run_dir,
                            args.timeout_seconds,
                            contract_hash=contract_hash,
                            simv_hash=simv_hash,
                        )
                        print(
                            f"    cycles={result['kernel_cycles']} "
                            f"target_misp={result['target_mispredictions']} "
                            f"wall={float(result['simulation_wall_seconds']):.2f}s"
                        )
                    results.append(result)
                    rows = publish_rows(results, output, args.publish_csv)
                    if rows and len(results) % 2 == 0:
                        print(f"    complete pairs available={len(rows)}")
            else:
                futures: dict[
                    concurrent.futures.Future[dict[str, object]],
                    tuple[int, RunConfig],
                ] = {}
                executor = concurrent.futures.ThreadPoolExecutor(
                    max_workers=args.workers,
                    thread_name_prefix="branch-pattern-rtl",
                )
                try:
                    def collect_completed(
                        completed: set[
                            concurrent.futures.Future[dict[str, object]]
                        ],
                    ) -> None:
                        for future in completed:
                            index, config = futures.pop(future)
                            result = future.result()
                            results.append(result)
                            print(
                                f"[{index}/{len(plan)}] {config.run_id}: PASS "
                                f"cycles={result['kernel_cycles']} "
                                f"target_misp={result['target_mispredictions']} "
                                f"wall={float(result['simulation_wall_seconds']):.2f}s",
                                flush=True,
                            )
                            rows = publish_rows(
                                results, output, args.publish_csv
                            )
                            if rows:
                                print(
                                    f"    complete pairs available={len(rows)}"
                                )

                    for index, config in enumerate(plan, start=1):
                        run_dir = output / "runs" / config.run_id
                        result = (
                            load_result(
                                run_dir,
                                config,
                                contract_hash=contract_hash,
                                simv_hash=simv_hash,
                            )
                            if args.resume
                            else None
                        )
                        if result is not None:
                            print(f"[{index}/{len(plan)}] {config.run_id}: RESUME")
                            results.append(result)
                            continue
                        print(
                            f"[{index}/{len(plan)}] {config.run_id}: STAGE",
                            flush=True,
                        )
                        staged = stage_parallel_case(
                            config, run_dir, args.timeout_seconds
                        )
                        future = executor.submit(
                            run_staged_case,
                            staged,
                            simv,
                            args.timeout_seconds,
                            contract_hash=contract_hash,
                            simv_hash=simv_hash,
                        )
                        futures[future] = (index, config)

                        # Keep staging bounded and surface worker/license errors
                        # without first building the entire profile.
                        if len(futures) >= args.workers * 2:
                            completed, _ = concurrent.futures.wait(
                                futures,
                                return_when=concurrent.futures.FIRST_COMPLETED,
                            )
                            collect_completed(completed)

                    publish_rows(results, output, args.publish_csv)
                    while futures:
                        completed, _ = concurrent.futures.wait(
                            futures,
                            return_when=concurrent.futures.FIRST_COMPLETED,
                        )
                        collect_completed(completed)
                except BaseException:
                    for future in futures:
                        future.cancel()
                    raise
                finally:
                    executor.shutdown(wait=True, cancel_futures=True)
        finally:
            lock.close()

        rows = publish_rows(results, output, args.publish_csv)
        csv_path = output / "branch_pattern_results.csv"
        if not rows:
            raise SweepError("no complete random/predictable pair is available for CSV")
        if args.publish_csv:
            publish = args.publish_csv.expanduser().resolve()
            print(f"published CSV: {publish}")
        print(f"complete pairs={len(rows)}")
        print(f"results: {output}")
        print(f"CSV: {csv_path}")
        return 0
    except (SweepError, subprocess.SubprocessError, OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
