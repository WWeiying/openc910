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
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
WORK_DIR = SCRIPT_DIR / "work"
RESULT_SCHEMA_VERSION = 4
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
BRANCH_LINE_RE = re.compile(r"^([A-Za-z_]+)\s+(.*)$")
DISASM_RE = re.compile(
    r"^\s*([0-9a-fA-F]+):\s+(?:[0-9a-fA-F]{4,16}\s+)+([.$A-Za-z][.$A-Za-z0-9_]*)\b"
)


def parse_key_values(payload: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for token in payload.split():
        if "=" not in token:
            continue
        key, value = token.split("=", 1)
        values[key] = value
    return values


def parse_branch_pc_totals(text: str) -> dict[tuple[str, str], dict[str, int]]:
    totals: dict[tuple[str, str], dict[str, int]] = {}
    seen: set[tuple[str, str]] = set()
    for index, line in enumerate(text.splitlines(), start=1):
        match = BRANCH_LINE_RE.match(line)
        if not match:
            continue
        prefix, payload = match.groups()
        if prefix != "BRANCH_PC_TOTAL":
            continue
        fields = parse_key_values(payload)
        phase = fields.get("phase")
        kind = fields.get("kind")
        if phase is None or kind is None:
            continue
        key = (phase, kind)
        if key in seen:
            previous = totals[key]
            raise SweepError(
                f"duplicate BRANCH_PC_TOTAL for phase={phase} kind={kind}: "
                f"exec={previous['exec']}, mispred={previous['mispred']} then "
                f"exec={fields.get('exec')}, mispred={fields.get('mispred')}"
            )
        try:
            exec_count = int(fields["exec"])
            mispred_count = int(fields["mispred"])
        except KeyError as error:
            raise SweepError(
                f"malformed BRANCH_PC_TOTAL on line {index}: missing key {error}"
            ) from None
        except ValueError as error:
            raise SweepError(
                f"malformed BRANCH_PC_TOTAL on line {index}: non-integer value"
            ) from error
        if exec_count < 0 or mispred_count < 0:
            raise SweepError(
                f"negative BRANCH_PC_TOTAL for phase={phase} kind={kind}: "
                f"exec={exec_count}, mispred={mispred_count}"
            )
        seen.add(key)
        totals[key] = {
            "exec": exec_count,
            "mispred": mispred_count,
        }
    return totals


def parse_branch_pc_records(
    text: str,
    phase: str,
    kind: str,
    start: int,
    end: int,
) -> list[dict[str, int]]:
    records: list[dict[str, int]] = []
    seen_pc: set[int] = set()
    for index, line in enumerate(text.splitlines(), start=1):
        match = BRANCH_LINE_RE.match(line)
        if not match:
            continue
        prefix, payload = match.groups()
        if prefix != "BRANCH_PC":
            continue
        fields = parse_key_values(payload)
        if fields.get("phase") != phase or fields.get("kind") != kind:
            continue
        try:
            pc = int(fields["pc"], 16)
            exec_count = int(fields["exec"])
            mispred_count = int(fields["mispred"])
        except KeyError as error:
            raise SweepError(
                f"malformed BRANCH_PC on line {index}: missing key {error}"
            ) from None
        except ValueError as error:
            raise SweepError(
                f"malformed BRANCH_PC on line {index}: non-integer value"
            ) from error
        if pc in seen_pc:
            raise SweepError(f"duplicate BRANCH_PC entry for pc=0x{pc:x}")
        seen_pc.add(pc)
        if not (start <= pc < end):
            continue
        try:
            call_misp = int(fields.get("call_misp", "0"))
            return_misp = int(fields.get("return_misp", "0"))
            other_misp = int(fields.get("other_misp", "0"))
        except ValueError as error:
            raise SweepError(
                f"malformed BRANCH_PC on line {index}: non-integer branch-class value"
            ) from error
        if exec_count < 0:
            raise SweepError(f"negative BRANCH_PC exec on line {index}: pc=0x{pc:x}")
        if mispred_count < 0:
            raise SweepError(
                f"negative BRANCH_PC mispred on line {index}: pc=0x{pc:x}"
            )
        if call_misp < 0:
            raise SweepError(
                f"negative BRANCH_PC call_misp on line {index}: pc=0x{pc:x}"
            )
        if return_misp < 0:
            raise SweepError(
                f"negative BRANCH_PC return_misp on line {index}: pc=0x{pc:x}"
            )
        if other_misp < 0:
            raise SweepError(
                f"negative BRANCH_PC other_misp on line {index}: pc=0x{pc:x}"
            )
        if call_misp + return_misp + other_misp > mispred_count:
            raise SweepError(
                f"BRANCH_PC classification exceeds mispred at pc=0x{pc:x}"
            )
        if mispred_count > exec_count:
            raise SweepError(
                f"BRANCH_PC mispred > exec on line {index}: pc=0x{pc:x}, "
                f"mispred={mispred_count}, exec={exec_count}"
            )
        unknown_misp = mispred_count - (call_misp + return_misp + other_misp)
        records.append(
            {
                "pc": pc,
                "exec": exec_count,
                "mispred": mispred_count,
                "call_misp": call_misp,
                "return_misp": return_misp,
                "other_misp": other_misp,
                "unknown_misp": unknown_misp,
            }
        )
    return records


def parse_branch_pc_begin_end(text: str, phase: str) -> bool:
    begin_seen = False
    end_seen = False
    target = f"BRANCH_PC_BEGIN phase={phase}"
    end_token = f"BRANCH_PC_END phase={phase}"
    for line in text.splitlines():
        if line.startswith(target):
            begin_seen = True
        if begin_seen and line.startswith(end_token):
            end_seen = True
            break
    return begin_seen and end_seen


def branch_pcs_from_asm(asm_path: Path, start: int, end: int) -> list[int]:
    pces: list[int] = []
    for line in asm_path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = DISASM_RE.match(line)
        if not match:
            continue
        pc = int(match.group(1), 16)
        if start <= pc < end and match.group(2) in CONDITIONAL_MNEMONICS:
            pces.append(pc)
    return pces

BRANCH_MECHANISM_DETAIL_COUNTERS: tuple[str, ...] = (
    "ifu_frontend_stall_raw",
    "ifu_ibuf_full",
    "ifu_pcfifo_full_stall",
    "ifu_multi_branch_stall",
    "ifu_bry_missigned_stall",
    "ifu_ind_btb_miss",
    "ifu_ind_btb_rd_stall",
    "ifu_btb_miss",
    "ifu_l0_btb_miss",
    "ifu_retire0_condbr",
    "ifu_retire0_condbr_taken",
    "ifu_retire0_mispred",
    "ifu_retire0_jmp_mispred",
    "retire_condbr_slot0",
    "retire_condbr_slot1",
    "retire_condbr_slot2",
    "retire_jmp_slot0",
    "retire_jmp_slot1",
    "retire_jmp_slot2",
    "retire_bht_mispred",
    "retire_jmp_mispred",
    "iu_idu_mispred_stall",
    "iu_ifu_mispred_stall",
    "iu_bht_mispred",
    "iu_jmp_mispred",
    "bht_bju_mispred",
    "lbuf_bju_mispred",
    "rtu_global_flush",
    "rob_head_bju",
    "l0_btb_hit",
    "l0_btb_miss_deep",
    "l0_btb_mispred",
    "l0_btb_wait",
    "ind_btb_check",
    "ind_btb_fifo_stall",
    "ind_btb_miss_deep",
    "ras_redirect",
    "ras_mistaken",
    "icache_refill_busy",
    "icache_miss_under_refill",
    "icache_refill_start",
    "icache_refill_reissue",
    "ifu_ibuf_create",
    "ifu_ibuf_retire",
    "ifu_pcfifo_create",
)

CORE_BRANCH_DETAIL_COUNTERS: tuple[str, ...] = (
    "ifu_frontend_stall_raw",
    "ifu_multi_branch_stall",
    "ifu_bry_missigned_stall",
    "ifu_btb_miss",
    "ifu_l0_btb_miss",
    "ifu_ind_btb_miss",
    "ifu_ind_btb_rd_stall",
    "ifu_retire0_mispred",
    "ifu_retire0_condbr",
    "ifu_retire0_jmp_mispred",
    "ifu_retire0_condbr_taken",
    "retire_bht_mispred",
    "retire_jmp_mispred",
    "iu_idu_mispred_stall",
    "iu_ifu_mispred_stall",
    "iu_bht_mispred",
    "iu_jmp_mispred",
    "l0_btb_mispred",
    "l0_btb_wait",
    "ind_btb_check",
    "ind_btb_fifo_stall",
    "ras_redirect",
    "ras_mistaken",
    "bht_bju_mispred",
    "lbuf_bju_mispred",
)

ESSENTIAL_BRANCH_DETAIL_COUNTERS: tuple[str, ...] = (
    "ifu_frontend_stall_raw",
    "ifu_multi_branch_stall",
    "ifu_retire0_condbr",
    "ifu_retire0_mispred",
    "retire_bht_mispred",
    "rtu_global_flush",
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


def build_plan(
    args: argparse.Namespace,
) -> tuple[list[RunConfig], list[dict[str, int | str]]]:
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
    excluded: list[dict[str, int | str]] = []
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
                for repeat in range(1, repeats + 1):
                    excluded.append(
                        {
                            "branches": branch_count,
                            "pattern_length": pattern_length,
                            "repeat": repeat,
                            "reason": "max_target_dynamic_branches",
                            "measure_iterations": measure,
                            "target_dynamic_branches": branch_count * measure,
                        }
                    )
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
    return plan, excluded


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
    return len(branch_pcs_from_asm(asm_path, start, end))


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


def parse_kernel_detail_counters(text: str) -> dict[str, int]:
    """Parse Kernel detail events from the detailed table or compact fallback rows."""

    counters: dict[str, int] = {}
    in_detail_section = False
    seen_detail_section = False
    seen_rows: set[str] = set()
    detail_row_re = re.compile(
        r"^\|\s*Kernel\s*\|\s*([A-Za-z_][A-Za-z0-9_]*)\s*\|\s*(-?\d+)"
    )

    def _record_counter(name: str, value: int, line: str) -> None:
        if name in counters and counters[name] != value:
            raise SweepError(
                f"conflicting Kernel counter value for {name}: {counters[name]} vs "
                f"{value} (line: {line})"
            )
        counters[name] = value
        seen_rows.add(name)

    for line in text.splitlines():
        if "Detailed Performance Statistics" in line:
            in_detail_section = True
            seen_detail_section = True
            continue

        if not in_detail_section:
            # Compatibility path: some logs dump only kernel rows without table header.
            fallback_match = detail_row_re.match(line)
            if fallback_match:
                name, value = fallback_match.group(1), int(fallback_match.group(2))
                if name in seen_rows and counters.get(name) != value:
                    raise SweepError(
                        f"conflicting Kernel counter value in fallback rows: {name} "
                        f"{counters[name]} vs {value} (line: {line})"
                    )
                counters[name] = value
            continue

        if not line.startswith("|"):
            if counters:
                break
            continue

        match = detail_row_re.match(line)
        if match:
            _record_counter(match.group(1), int(match.group(2)), line)

        # if we are in detail section and have consumed at least one row, a second
        # section separator indicates end-of-table and keeps the parser deterministic.
        if seen_detail_section and "===" in line and counters:
            break

    return counters


def parse_target_branch_pc_rows(
    text: str, start: int, end: int
) -> list[dict[str, int]]:
    """Parse kernel conditional branch PC rows that fall into the generated region."""

    return parse_branch_pc_records(text, "Kernel", "cond", start, end)


def summarize_target_branch_rows(
    rows: list[dict[str, int]]
) -> dict[str, object]:
    """Summarize per-PC branch behavior for the target region."""

    if not rows:
        return {
            "target_branch_sites": 0,
            "target_mispred_site_count": 0,
            "target_branch_top1_mispred_site": None,
            "target_branch_top1_mispred_count": 0,
            "target_branch_top1_mispred_share_pct": 0.0,
            "target_branch_top2_mispred_share_pct": 0.0,
            "target_branch_top3_mispred_share_pct": 0.0,
            "target_branch_mispred_gini_like": 0.0,
            "target_branch_pc_span": 0,
            "target_branch_pc_first": None,
            "target_branch_pc_last": None,
            "target_branch_pc_unique_exec": 0,
        }

    total_sites = len(rows)
    total_exec = sum(record["exec"] for record in rows)
    total_misp = sum(record["mispred"] for record in rows)
    mispred_sites = sum(1 for record in rows if record["mispred"] > 0)
    rows_sorted = sorted(rows, key=lambda item: item["mispred"], reverse=True)
    top = rows_sorted[:3]
    top_counts = [item["mispred"] for item in top]

    pc_values = [record["pc"] for record in rows]
    gini_like = 0.0
    if total_misp > 0 and total_sites > 1:
        running = 0.0
        cumulative = 0.0
        for record in sorted(rows, key=lambda item: item["mispred"], reverse=True):
            mispred = record["mispred"]
            cumulative += mispred
            running += cumulative
        denom = total_misp * total_sites
        if denom > 0:
            gini_like = (2.0 * running / denom) - (total_sites + 1.0) / total_sites

    top_share = lambda count: 100.0 * count / total_misp if total_misp else 0.0

    return {
        "target_branch_sites": total_sites,
        "target_mispred_site_count": mispred_sites,
        "target_branch_top1_mispred_site": f"0x{top[0]['pc']:x}" if top else None,
        "target_branch_top1_mispred_count": top_counts[0] if top_counts else 0,
        "target_branch_top1_mispred_share_pct": top_share(top_counts[0] if top_counts else 0),
        "target_branch_top2_mispred_share_pct": top_share(
            sum(top_counts[:2])
        ),
        "target_branch_top3_mispred_share_pct": top_share(
            sum(top_counts[:3])
        ),
        "target_branch_mispred_gini_like": gini_like,
        "target_branch_pc_span": max(pc_values) - min(pc_values) if total_sites > 1 else 0,
        "target_branch_pc_first": f"0x{min(pc_values):x}",
        "target_branch_pc_last": f"0x{max(pc_values):x}",
        "target_branch_pc_unique_exec": total_exec,
        "target_branch_pc_exec_count_mode": str(
            Counter(record["exec"] for record in rows).most_common(1)[0][0]
        ),
        "target_branch_call_mispred": sum(record["call_misp"] for record in rows),
        "target_branch_return_mispred": sum(record["return_misp"] for record in rows),
        "target_branch_other_mispred": sum(record["other_misp"] for record in rows),
        "target_branch_unknown_mispred": sum(record["unknown_misp"] for record in rows),
        "target_branch_top1_pct_of_mispred": 100.0 * (top_counts[0] / total_misp)
        if total_misp
        else 0.0,
        "target_branch_top2_pct_of_mispred": 100.0 * (sum(top_counts[:2]) / total_misp)
        if total_misp
        else 0.0,
        "target_branch_top3_pct_of_mispred": 100.0 * (sum(top_counts[:3]) / total_misp)
        if total_misp
        else 0.0,
    }


def parse_run_log(
    log_path: Path, config: RunConfig, start: int, end: int, asm_path: Path
) -> dict[str, object]:
    text = log_path.read_text(encoding="utf-8", errors="replace")
    kernel = KERNEL_ROW_RE.search(text)
    if not kernel:
        raise SweepError("Kernel performance row is missing")

    branch_totals = parse_branch_pc_totals(text)
    cond_total = branch_totals.get(("Kernel", "cond"))
    if cond_total is None:
        raise SweepError("Kernel BRANCH_PC_TOTAL evidence is missing; compile PERF_DETAIL=on")

    monitor = parse_kernel_monitor(text)
    required_monitor = {"L1I Miss", "Cond Branch Misp"}
    missing_monitor = sorted(required_monitor - monitor.keys())
    if missing_monitor:
        raise SweepError(f"missing Kernel Monitor rows: {missing_monitor}")

    kernel_detail = parse_kernel_detail_counters(text)
    required_detail = set(ESSENTIAL_BRANCH_DETAIL_COUNTERS)
    missing_detail = sorted(required_detail - kernel_detail.keys())
    if missing_detail:
        raise SweepError(f"missing essential Kernel detail counters: {missing_detail}")
    for name, value in kernel_detail.items():
        if value < 0:
            raise SweepError(f"negative kernel detail counter {name}: {value}")

    optional_detail = {
        name: int(kernel_detail[name])
        for name in CORE_BRANCH_DETAIL_COUNTERS
        if name in kernel_detail
    }
    missing_optional_detail = sorted(set(CORE_BRANCH_DETAIL_COUNTERS) - optional_detail.keys())

    branch_pc_rows = parse_target_branch_pc_rows(text, start, end)
    if not branch_pc_rows:
        raise SweepError("missing kernel BRANCH_PC lines for target region")

    expected_pcs = branch_pcs_from_asm(asm_path, start, end)
    if len(expected_pcs) != config.branches:
        raise SweepError(
            f"Static branch site count mismatch in region: {len(expected_pcs)} != "
            f"{config.branches}"
        )
    expected_pc_set = set(expected_pcs)
    parsed_pc_set = {record["pc"] for record in branch_pc_rows}
    if expected_pc_set != parsed_pc_set:
        missing_pc = sorted(expected_pc_set - parsed_pc_set)
        extra_pc = sorted(parsed_pc_set - expected_pc_set)
        raise SweepError(
            "Kernel BRANCH_PC rows do not match ASM branch sites. "
            f"missing={['0x%x' % value for value in missing_pc]}, "
            f"extra={['0x%x' % value for value in extra_pc]}"
        )

    if len(branch_pc_rows) != config.branches:
        raise SweepError(
            f"Kernel BRANCH_PC site count mismatch: {len(branch_pc_rows)} != "
            f"{config.branches}"
        )

    target_mispredictions = 0
    for row in branch_pc_rows:
        if row["unknown_misp"] < 0:
            raise SweepError(
                "BRANCH_PC call_misp/return_misp/other_misp exceed mispred at pc="
                f"0x{row['pc']:x}"
            )
        if row["exec"] != config.measure_iterations:
            pc = row["pc"]
            raise SweepError(
                f"target branch PC 0x{pc:x} executed {row['exec']} times; "
                f"expected {config.measure_iterations}"
            )
        target_mispredictions += row["mispred"]

    branch_summary = summarize_target_branch_rows(branch_pc_rows)
    if not parse_branch_pc_begin_end(text, "Kernel"):
        raise SweepError("Kernel BRANCH_PC begin/end markers are missing")

    kernel_cycles = int(kernel.group(1))
    kernel_retired = int(kernel.group(2))
    total_conditional = cond_total["exec"]
    total_mispredictions = cond_total["mispred"]
    monitor_cond_misp = int(monitor["Cond Branch Misp"][0])
    monitor_cond_total = int(monitor["Cond Branch Misp"][1])
    expected_conditional = config.target_dynamic_branches
    if monitor_cond_misp != total_mispredictions or monitor_cond_total != total_conditional:
        raise SweepError(
            "Kernel Monitor Cond Branch Misp does not close with BRANCH_PC_TOTAL: "
            f"({monitor_cond_misp}, {monitor_cond_total}) != "
            f"({total_mispredictions}, {total_conditional})"
        )
    if int(kernel_detail["retire_bht_mispred"]) != total_mispredictions:
        raise SweepError(
            "retire_bht_mispred does not close with BRANCH_PC_TOTAL: "
            f"{kernel_detail['retire_bht_mispred']} != {total_mispredictions}"
        )
    if target_mispredictions != total_mispredictions:
        raise SweepError(
            "target branch mispredictions not equal BRANCH_PC_TOTAL cond mispredictions: "
            f"{target_mispredictions} != {total_mispredictions}"
        )
    if total_conditional != expected_conditional:
        raise SweepError(
            "Kernel conditional-branch count does not match target sites * measure iterations: "
            f"{total_conditional} != {expected_conditional}"
        )
    if total_conditional != branch_summary["target_branch_pc_unique_exec"]:
        raise SweepError(
            "Kernel conditional branch total does not close with BRANCH_PC target-region rows: "
            f"{total_conditional} != {branch_summary['target_branch_pc_unique_exec']}"
        )

    required_slot_keys = {"retire_condbr_slot0", "retire_condbr_slot1", "retire_condbr_slot2"}
    present_slot_keys = required_slot_keys.intersection(kernel_detail.keys())
    if 0 < len(present_slot_keys) < len(required_slot_keys):
        raise SweepError(
            "partial retire_condbr slot counters are present; required counters are all or none, "
            f"got {sorted(present_slot_keys)}"
        )
    if present_slot_keys:
        retire_slot0 = int(kernel_detail["retire_condbr_slot0"])
        retire_slot1 = int(kernel_detail["retire_condbr_slot1"])
        retire_slot2 = int(kernel_detail["retire_condbr_slot2"])
        slot_sum = retire_slot0 + retire_slot1 + retire_slot2
        if slot_sum != total_conditional:
            raise SweepError(
                "retire_condbr slot counters do not close with conditional-branch total: "
                f"({retire_slot0}, {retire_slot1}, {retire_slot2}) -> {slot_sum} != {total_conditional}"
            )
    else:
        retire_slot0 = 0
        retire_slot1 = 0
        retire_slot2 = 0
        slot_sum = 0

    ifu_retire0_condbr = int(kernel_detail.get("ifu_retire0_condbr", 0))
    ifu_retire0_group = {
        "ifu_retire0_condbr",
        "ifu_retire0_condbr_taken",
        "ifu_retire0_mispred",
    }
    present_ifu_retire0 = ifu_retire0_group.intersection(kernel_detail.keys())
    if 0 < len(present_ifu_retire0) < len(ifu_retire0_group):
        raise SweepError(
            "partial IFU conditional branch counters are present; required counters are all or none, "
            f"got {sorted(present_ifu_retire0)}"
        )
    if "ifu_retire0_condbr" in kernel_detail:
        ifu_retire0_condbr_taken = int(kernel_detail.get("ifu_retire0_condbr_taken", 0))
        ifu_retire0_mispred = int(kernel_detail.get("ifu_retire0_mispred", 0))
        if ifu_retire0_condbr_taken > ifu_retire0_condbr:
            raise SweepError(
                "ifu_retire0_condbr_taken > ifu_retire0_condbr: "
                f"{kernel_detail.get('ifu_retire0_condbr_taken', 0)} > {ifu_retire0_condbr}"
            )
        if ifu_retire0_mispred > ifu_retire0_condbr:
            raise SweepError(
                "ifu_retire0_mispred > ifu_retire0_condbr: "
                f"{kernel_detail.get('ifu_retire0_mispred', 0)} > {ifu_retire0_condbr}"
            )

    return {
        **branch_summary,
        "kernel_cycles": kernel_cycles,
        "kernel_retired_instructions": kernel_retired,
        "target_executed_branches": config.target_dynamic_branches,
        "target_mispredictions": target_mispredictions,
        "target_mispred_pc_count": len(branch_pc_rows),
        "kernel_conditional_branches": total_conditional,
        "kernel_bht_mispredictions": total_mispredictions,
        "kernel_global_flushes": kernel_detail["rtu_global_flush"],
        "kernel_l1i_misses": int(monitor["L1I Miss"][0]),
        "kernel_detail_counters": optional_detail,
        "kernel_missing_detail_counters": missing_optional_detail,
        "kernel_branch_pc_begin_end": True,
        "kernel_indirect_total_exec": branch_totals.get(("Kernel", "jmp"), {}).get("exec", 0),
        "kernel_indirect_total_mispred": branch_totals.get(("Kernel", "jmp"), {}).get("mispred", 0),
        "kernel_condbr_slot0": retire_slot0,
        "kernel_condbr_slot1": retire_slot1,
        "kernel_condbr_slot2": retire_slot2,
        "kernel_condbr_slot_total": slot_sum,
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

    metrics = parse_run_log(run_log, config, start, end, asm_path)
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
        staged.run_dir / "bench_br_pattern.asm",
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


def _per_k(value: int | float, denominator: int | float) -> float:
    if denominator <= 0:
        return 0.0
    return 1000.0 * (value / denominator)


def _get_detail_count(result: dict[str, object], name: str) -> int:
    detail = result.get("kernel_detail_counters")
    if not isinstance(detail, dict):
        return 0
    value = detail.get(name, 0)
    try:
        return int(value)
    except (TypeError, ValueError):
        return 0


def _safe_float(value: object) -> float:
    if value is None:
        return 0.0
    if isinstance(value, (int, float)):
        return float(value)
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def top_mechanism_deltas(
    row: dict[str, object],
    counter_names: tuple[str, ...],
    metric: str,
    *,
    suffix: str = "",
    top: int = 5,
) -> str:
    items: list[tuple[str, float]] = []
    for name in counter_names:
        key = f"{metric}_{name}{suffix}"
        if key not in row:
            continue
        value = _safe_float(row[key])
        if value == 0.0:
            continue
        items.append((name, value))
    items.sort(key=lambda item: abs(item[1]), reverse=True)
    return ",".join(f"{name}={value:.4g}" for name, value in items[:top])


def safe_divide(numerator: float, denominator: float) -> float:
    if denominator == 0:
        return 0.0
    return numerator / denominator


def paired_rows(results: Iterable[dict[str, object]]) -> list[dict[str, object]]:
    grouped: dict[tuple[int, int, int], dict[str, dict[str, object]]] = {}
    for result in results:
        key = (
            int(result["branches_in_loop"]),
            int(result["pattern_length"]),
            int(result["repeat"]),
        )
        mode = str(result["mode"])
        current = grouped.setdefault(key, {})
        if mode in current:
            raise SweepError(
                f"duplicate mode='{mode}' result for branches={key[0]}, "
                f"pattern={key[1]}, repeat={key[2]}"
            )
        current[mode] = result

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
            retired = int(result["kernel_retired_instructions"])
            conditional = int(result["kernel_conditional_branches"])

            row[f"{mode}_cycles"] = result["kernel_cycles"]
            row[f"{mode}_executed_branches"] = target
            row[f"{mode}_mispredictions"] = int(result["target_mispredictions"])
            row[f"{mode}_cycles_per_branch"] = _safe_float(result["kernel_cycles"]) / target
            row[f"{mode}_target_mispredictions"] = int(result["target_mispredictions"])
            row[f"{mode}_mispredictions"] = row[f"{mode}_target_mispredictions"]
            row[f"{mode}_mispred_rate_pct"] = (
                100.0 * _safe_float(row[f"{mode}_target_mispredictions"]) / target
            )
            row[f"{mode}_kernel_detail_missing_count"] = len(
                result.get("kernel_missing_detail_counters", []) or []
            )
            row[f"{mode}_kernel_conditional_branches"] = result["kernel_conditional_branches"]
            row[f"{mode}_kernel_bht_mispredictions"] = result["kernel_bht_mispredictions"]
            row[f"{mode}_kernel_global_flushes"] = result["kernel_global_flushes"]
            row[f"{mode}_kernel_l1i_misses"] = result["kernel_l1i_misses"]
            row[f"{mode}_simulation_wall_seconds"] = result["simulation_wall_seconds"]
            row[f"{mode}_kernel_retired_instructions"] = retired

            row[f"{mode}_target_branch_sites"] = result.get("target_branch_sites", 0)
            row[f"{mode}_target_mispred_site_count"] = result.get(
                "target_mispred_site_count", 0
            )
            row[f"{mode}_target_branch_top1_site"] = result.get(
                "target_branch_top1_mispred_site"
            )
            row[f"{mode}_target_branch_top1_mispred_count"] = result.get(
                "target_branch_top1_mispred_count", 0
            )
            row[f"{mode}_target_branch_top1_share_pct"] = result.get(
                "target_branch_top1_mispred_share_pct", 0.0
            )
            row[f"{mode}_target_branch_top2_share_pct"] = result.get(
                "target_branch_top2_mispred_share_pct", 0.0
            )
            row[f"{mode}_target_branch_top3_share_pct"] = result.get(
                "target_branch_top3_mispred_share_pct", 0.0
            )
            row[f"{mode}_target_branch_gini_like"] = result.get(
                "target_branch_mispred_gini_like", 0.0
            )
            row[f"{mode}_target_branch_pc_span"] = result.get(
                "target_branch_pc_span", 0
            )
            row[f"{mode}_target_branch_pc_first"] = result.get("target_branch_pc_first")
            row[f"{mode}_target_branch_pc_last"] = result.get("target_branch_pc_last")
            row[f"{mode}_target_branch_exec_mode"] = result.get(
                "target_branch_pc_exec_count_mode"
            )
            row[f"{mode}_target_branch_call_mispred"] = result.get(
                "target_branch_call_mispred", 0
            )
            row[f"{mode}_target_branch_return_mispred"] = result.get(
                "target_branch_return_mispred", 0
            )
            row[f"{mode}_target_branch_other_mispred"] = result.get(
                "target_branch_other_mispred", 0
            )
            row[f"{mode}_target_branch_unknown_mispred"] = result.get(
                "target_branch_unknown_mispred", 0
            )
            row[f"{mode}_target_branch_top1_pct_of_mispred"] = result.get(
                "target_branch_top1_pct_of_mispred", 0.0
            )
            row[f"{mode}_target_branch_top2_pct_of_mispred"] = result.get(
                "target_branch_top2_pct_of_mispred", 0.0
            )
            row[f"{mode}_target_branch_top3_pct_of_mispred"] = result.get(
                "target_branch_top3_pct_of_mispred", 0.0
            )
            row[f"{mode}_target_branch_unknown_share_pct"] = safe_divide(
                100.0 * _safe_float(row[f"{mode}_target_branch_unknown_mispred"]),
                _safe_float(row[f"{mode}_target_mispredictions"]),
            )

            for name in CORE_BRANCH_DETAIL_COUNTERS:
                count = _get_detail_count(result, name)
                row[f"{mode}_{name}"] = count
                row[f"{mode}_{name}_per_kbranch"] = _per_k(count, target)
                row[f"{mode}_{name}_per_kinst"] = _per_k(count, retired)
                row[f"{mode}_{name}_per_kcond"] = _per_k(count, conditional)

        for name in CORE_BRANCH_DETAIL_COUNTERS:
            random_count = float(row[f"random_{name}"])
            predictable_count = float(row[f"predictable_{name}"])
            row[f"delta_{name}_count"] = random_count - predictable_count
            row[f"delta_{name}_per_kbranch"] = row[f"random_{name}_per_kbranch"] - row[
                f"predictable_{name}_per_kbranch"
            ]
            row[f"delta_{name}_per_kinst"] = row[f"random_{name}_per_kinst"] - row[
                f"predictable_{name}_per_kinst"
            ]
            row[f"delta_{name}_per_kcond"] = row[f"random_{name}_per_kcond"] - row[
                f"predictable_{name}_per_kcond"
            ]

        row["delta_target_branch_sites"] = (
            _safe_float(row["random_target_branch_sites"])
            - _safe_float(row["predictable_target_branch_sites"])
        )
        row["delta_target_mispred_site_count"] = (
            _safe_float(row["random_target_mispred_site_count"])
            - _safe_float(row["predictable_target_mispred_site_count"])
        )
        row["delta_target_top1_share_pct"] = (
            _safe_float(row["random_target_branch_top1_share_pct"])
            - _safe_float(row["predictable_target_branch_top1_share_pct"])
        )
        row["delta_target_top2_share_pct"] = (
            _safe_float(row["random_target_branch_top2_share_pct"])
            - _safe_float(row["predictable_target_branch_top2_share_pct"])
        )
        row["delta_target_top3_share_pct"] = (
            _safe_float(row["random_target_branch_top3_share_pct"])
            - _safe_float(row["predictable_target_branch_top3_share_pct"])
        )
        row["delta_target_branch_gini_like"] = (
            _safe_float(row["random_target_branch_gini_like"])
            - _safe_float(row["predictable_target_branch_gini_like"])
        )
        row["delta_target_top1_mispred_pct"] = (
            _safe_float(row["random_target_branch_top1_pct_of_mispred"])
            - _safe_float(row["predictable_target_branch_top1_pct_of_mispred"])
        )
        row["delta_target_top2_mispred_pct"] = (
            _safe_float(row["random_target_branch_top2_pct_of_mispred"])
            - _safe_float(row["predictable_target_branch_top2_pct_of_mispred"])
        )
        row["delta_target_top3_mispred_pct"] = (
            _safe_float(row["random_target_branch_top3_pct_of_mispred"])
            - _safe_float(row["predictable_target_branch_top3_pct_of_mispred"])
        )
        row["delta_target_call_mispred"] = (
            _safe_float(row["random_target_branch_call_mispred"])
            - _safe_float(row["predictable_target_branch_call_mispred"])
        )
        row["delta_target_return_mispred"] = (
            _safe_float(row["random_target_branch_return_mispred"])
            - _safe_float(row["predictable_target_branch_return_mispred"])
        )
        row["delta_target_other_mispred"] = (
            _safe_float(row["random_target_branch_other_mispred"])
            - _safe_float(row["predictable_target_branch_other_mispred"])
        )
        row["delta_target_unknown_mispred"] = (
            _safe_float(row["random_target_branch_unknown_mispred"])
            - _safe_float(row["predictable_target_branch_unknown_mispred"])
        )

        random_target = float(row["random_executed_branches"])
        predictable_target = float(row["predictable_executed_branches"])
        row["delta_executed_branches"] = random_target - predictable_target
        row["delta_mispredictions"] = float(row["random_mispredictions"]) - float(
            row["predictable_mispredictions"]
        )
        row["delta_cycles"] = float(row["random_cycles"]) - float(row["predictable_cycles"])
        row["delta_cycles_per_branch"] = (
            float(row["random_cycles_per_branch"]) - float(row["predictable_cycles_per_branch"])
        )
        row["delta_mispred_rate_pct"] = float(row["random_mispred_rate_pct"]) - float(
            row["predictable_mispred_rate_pct"]
        )
        extra_mispred = _safe_float(row["delta_mispredictions"])
        row["delta_cycles_per_extra_mispred"] = safe_divide(
            _safe_float(row["delta_cycles"]),
            extra_mispred,
        )

        for name in CORE_BRANCH_DETAIL_COUNTERS:
            row[f"delta_{name}_per_extra_mispred"] = safe_divide(
                _safe_float(row[f"delta_{name}_count"]),
                extra_mispred,
            )

        for label in ("call", "return", "other", "unknown"):
            row[f"random_target_branch_{label}_mispred_share_pct"] = safe_divide(
                100.0 * _safe_float(row[f"random_target_branch_{label}_mispred"]),
                _safe_float(row["random_mispredictions"]),
            )
            row[f"predictable_target_branch_{label}_mispred_share_pct"] = safe_divide(
                100.0 * _safe_float(row[f"predictable_target_branch_{label}_mispred"]),
                _safe_float(row["predictable_mispredictions"]),
            )
            row[f"delta_target_branch_{label}_mispred_share_pct"] = (
                _safe_float(row[f"random_target_branch_{label}_mispred_share_pct"])
                - _safe_float(row[f"predictable_target_branch_{label}_mispred_share_pct"])
            )
            row[f"delta_target_branch_{label}_mispred_per_extra_mispred"] = safe_divide(
                _safe_float(row[f"random_target_branch_{label}_mispred"])
                - _safe_float(row[f"predictable_target_branch_{label}_mispred"]),
                extra_mispred,
            )

        row["random_target_branch_unknown_share_pct"] = safe_divide(
            100.0 * _safe_float(row["random_target_branch_unknown_mispred"]),
            _safe_float(row["random_mispredictions"]),
        )
        row["predictable_target_branch_unknown_share_pct"] = safe_divide(
            100.0 * _safe_float(row["predictable_target_branch_unknown_mispred"]),
            _safe_float(row["predictable_mispredictions"]),
        )
        row["delta_target_branch_unknown_share_pct"] = (
            _safe_float(row["random_target_branch_unknown_share_pct"])
            - _safe_float(row["predictable_target_branch_unknown_share_pct"])
        )
        row["delta_target_unknown_mispred_per_extra_mispred"] = safe_divide(
            _safe_float(row["delta_target_unknown_mispred"]),
            extra_mispred,
        )

        row["delta_top_mechanisms_count"] = top_mechanism_deltas(
            row, CORE_BRANCH_DETAIL_COUNTERS, "delta", suffix="_count", top=5
        )
        row["delta_top_mechanisms_per_kbranch"] = top_mechanism_deltas(
            row, CORE_BRANCH_DETAIL_COUNTERS, "delta", suffix="_per_kbranch", top=5
        )
        row["delta_top_mechanisms_per_kcond"] = top_mechanism_deltas(
            row, CORE_BRANCH_DETAIL_COUNTERS, "delta", suffix="_per_kcond", top=5
        )

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
    plan_exclusions: list[dict[str, int | str]],
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
        "excluded_coordinate_count": len(
            {(item["branches"], item["pattern_length"], item["repeat"]) for item in plan_exclusions}
        ),
        "excluded_points": plan_exclusions,
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
        plan, excluded = build_plan(args)
        if excluded:
            sample = ", ".join(
                f"(branches={item['branches']}, pattern={item['pattern_length']}, reason={item['reason']})"
                for item in excluded[:5]
            )
            print(f"excluded={len(excluded)} examples: {sample}")
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
            excluded,
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
