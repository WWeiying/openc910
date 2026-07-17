#!/usr/bin/env python3
"""Derive detailed, architecture-independent kernel features from KTRACE1."""

from __future__ import annotations

import argparse
import collections
import csv
import hashlib
import json
import math
import re
import statistics
import struct
import subprocess
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable


HEADER = struct.Struct("<8sIIQQQQQQ")
RECORD = struct.Struct("<BBBBIQQQ")
MAGIC = b"KTRACE1\0"
INSN = 1
MEM = 2
MEM_STORE = 1
SCHEMA_VERSION = 1
PHASE_WINDOW = 100_000

COND_BRANCHES = {
    "beq", "bne", "blt", "bge", "bltu", "bgeu", "c.beqz", "c.bnez"
}
DIRECT_JUMPS = {"jal", "c.j", "c.jal"}
INDIRECT_JUMPS = {"jalr", "c.jr", "c.jalr"}
SYSTEM_PREFIXES = (
    "ecall", "ebreak", "fence", "sfence", "wfi", "mret", "sret",
    "th.sync", "th.dcache", "th.icache",
)

INT_REG_ALIASES = {
    "zero": "x0", "ra": "x1", "sp": "x2", "gp": "x3", "tp": "x4",
    "t0": "x5", "t1": "x6", "t2": "x7", "s0": "x8", "fp": "x8",
    "s1": "x9", "a0": "x10", "a1": "x11", "a2": "x12", "a3": "x13",
    "a4": "x14", "a5": "x15", "a6": "x16", "a7": "x17", "s2": "x18",
    "s3": "x19", "s4": "x20", "s5": "x21", "s6": "x22", "s7": "x23",
    "s8": "x24", "s9": "x25", "s10": "x26", "s11": "x27", "t3": "x28",
    "t4": "x29", "t5": "x30", "t6": "x31",
}
for i in range(32):
    INT_REG_ALIASES[f"x{i}"] = f"x{i}"

FP_REG_ALIASES = {}
for i, name in enumerate((
    "ft0", "ft1", "ft2", "ft3", "ft4", "ft5", "ft6", "ft7",
    "fs0", "fs1", "fa0", "fa1", "fa2", "fa3", "fa4", "fa5",
    "fa6", "fa7", "fs2", "fs3", "fs4", "fs5", "fs6", "fs7",
    "fs8", "fs9", "fs10", "fs11", "ft8", "ft9", "ft10", "ft11",
)):
    FP_REG_ALIASES[name] = f"f{i}"
    FP_REG_ALIASES[f"f{i}"] = f"f{i}"

REG_RE = re.compile(
    r"(?<![A-Za-z0-9_])(?:zero|ra|sp|gp|tp|fp|t[0-6]|s(?:[0-9]|1[01])|"
    r"a[0-7]|ft(?:[0-9]|1[01])|fs(?:[0-9]|1[01])|fa[0-7]|"
    r"x(?:[0-9]|[12][0-9]|3[01])|f(?:[0-9]|[12][0-9]|3[01]))(?![A-Za-z0-9_])"
)
FUNCTION_RE = re.compile(r"^([0-9a-fA-F]+)\s+<([^>]+)>:$")
INSN_RE = re.compile(
    r"^\s*([0-9a-fA-F]+):\s+([0-9a-fA-F]{4,16})\s+([^\s]+)(?:\s+(.*?))?\s*$"
)


@dataclass
class StaticInsn:
    pc: int
    size: int
    raw: int
    mnemonic: str
    operands: str
    function: str


@dataclass
class MemEvent:
    pc: int
    address: int
    size: int
    store: bool


@dataclass
class DynamicInsn:
    sequence: int
    pc: int
    size: int
    raw: int
    meta: StaticInsn
    memory: list[MemEvent] = field(default_factory=list)
    category: str = "other"
    subgroup: str = "other"
    sources: list[str] = field(default_factory=list)
    destinations: list[str] = field(default_factory=list)


class Fenwick:
    def __init__(self, size: int):
        self.tree = [0] * (size + 1)

    def add(self, index: int, delta: int) -> None:
        index += 1
        while index < len(self.tree):
            self.tree[index] += delta
            index += index & -index

    def prefix(self, index: int) -> int:
        total = 0
        index += 1
        while index:
            total += self.tree[index]
            index -= index & -index
        return total


def reuse_profile(keys: list[int], capacities: dict[str, int]):
    fenwick = Fenwick(len(keys))
    last_position = {}
    histogram = collections.Counter()
    cold = 0
    for index, key in enumerate(keys):
        previous = last_position.get(key)
        if previous is None:
            cold += 1
        else:
            distance = fenwick.prefix(index - 1) - fenwick.prefix(previous)
            histogram[distance] += 1
            fenwick.add(previous, -1)
        fenwick.add(index, 1)
        last_position[key] = index
    miss_ratio = {}
    for name, capacity in capacities.items():
        misses = cold + sum(count for distance, count in histogram.items()
                            if distance >= capacity)
        miss_ratio[name] = percent(misses, len(keys))
    return {
        "cold_percent": percent(cold, len(keys)),
        "p50": percentile_histogram(histogram, 0.50),
        "p90": percentile_histogram(histogram, 0.90),
        "p99": percentile_histogram(histogram, 0.99),
        "max": max(histogram, default=0),
        "miss_ratio_curve": miss_ratio,
    }


def temporal_working_set(keys: list[int], target_windows: int = 16):
    if not keys:
        return {"window_events": 0, "mean": 0.0, "p50": 0.0, "p90": 0.0,
                "max": 0}
    window = max(64, min(100_000, math.ceil(len(keys) / target_windows)))
    values = [len(set(keys[start:start + window]))
              for start in range(0, len(keys), window)]
    return {
        "window_events": window, "mean": statistics.fmean(values),
        "p50": percentile(values, 0.50), "p90": percentile(values, 0.90),
        "max": max(values),
    }


def percent(value: float, total: float) -> float:
    return 100.0 * value / total if total else 0.0


def percentile(values: list[float], q: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    pos = (len(ordered) - 1) * q
    lo = math.floor(pos)
    hi = math.ceil(pos)
    if lo == hi:
        return float(ordered[lo])
    return float(ordered[lo] * (hi - pos) + ordered[hi] * (pos - lo))


def percentile_histogram(histogram: collections.Counter, q: float) -> float:
    total = sum(histogram.values())
    if not total:
        return 0.0
    position = (total - 1) * q

    def select(rank):
        seen = 0
        for value, count in sorted(histogram.items()):
            seen += count
            if rank < seen:
                return value
        return max(histogram)

    lo = math.floor(position)
    hi = math.ceil(position)
    lo_value = select(lo)
    hi_value = select(hi)
    return float(lo_value * (hi - position) + hi_value * (position - lo))


def entropy_binary(taken: int, total: int) -> float:
    if not total or taken == 0 or taken == total:
        return 0.0
    p = taken / total
    return -(p * math.log2(p) + (1 - p) * math.log2(1 - p))


def entropy_counts(counts: Iterable[int]) -> float:
    values = [value for value in counts if value]
    total = sum(values)
    if total <= 1:
        return 0.0
    return -sum((value / total) * math.log2(value / total) for value in values)


def normalize_reg(reg: str) -> str:
    return INT_REG_ALIASES.get(reg, FP_REG_ALIASES.get(reg, reg))


def operand_registers(operands: str) -> list[str]:
    return [normalize_reg(match.group(0)) for match in REG_RE.finditer(operands)]


def split_operands(operands: str) -> list[str]:
    return [part.strip() for part in operands.split(",") if part.strip()]


def first_register(text: str) -> str | None:
    match = REG_RE.search(text)
    return normalize_reg(match.group(0)) if match else None


def parse_objdump(elf: Path, objdump: str) -> dict[int, StaticInsn]:
    proc = subprocess.run(
        [objdump, "-d", "-M", "no-aliases", str(elf)],
        check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    function = "[unknown]"
    result = {}
    for line in proc.stdout.splitlines():
        stripped = line.strip()
        function_match = FUNCTION_RE.match(stripped)
        if function_match:
            function = function_match.group(2)
            continue
        match = INSN_RE.match(line)
        if not match:
            continue
        pc_text, raw_text, mnemonic, operands = match.groups()
        size = len(raw_text) // 2
        if size not in (2, 4, 6, 8):
            continue
        pc = int(pc_text, 16)
        result[pc] = StaticInsn(
            pc=pc, size=size, raw=int(raw_text, 16), mnemonic=mnemonic.lower(),
            operands=(operands or "").strip(), function=function,
        )
    return result


def parse_elf_layout(elf: Path, objdump: str):
    tool_dir = Path(objdump).parent
    readelf = tool_dir / "riscv64-unknown-elf-readelf"
    nm = tool_dir / "riscv64-unknown-elf-nm"
    segments = []
    if readelf.exists():
        output = subprocess.run(
            [str(readelf), "-W", "-l", str(elf)], check=True, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        ).stdout
        for line in output.splitlines():
            parts = line.split()
            if not parts or parts[0] != "LOAD" or len(parts) < 8:
                continue
            flags = "".join(parts[6:-1])
            segments.append({
                "vaddr": int(parts[2], 16), "memsz": int(parts[5], 16),
                "flags": flags,
            })
    symbols = {}
    if nm.exists():
        output = subprocess.run(
            [str(nm), "-n", str(elf)], check=True, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        ).stdout
        for line in output.splitlines():
            parts = line.split()
            if len(parts) >= 3 and re.fullmatch(r"[0-9a-fA-F]+", parts[0]):
                symbols[parts[2]] = int(parts[0], 16)
    return {"segments": segments, "symbols": symbols}


def load_trace(path: Path, metadata: dict[int, StaticInsn]):
    instructions: list[DynamicInsn] = []
    by_sequence: dict[int, DynamicInsn] = {}
    raw_mismatches = 0
    missing_metadata = collections.Counter()
    with path.open("rb") as handle:
        header_raw = handle.read(HEADER.size)
        if len(header_raw) != HEADER.size:
            raise ValueError(f"short trace header: {path}")
        magic, version, record_size, start, end, *_ = HEADER.unpack(header_raw)
        if magic != MAGIC or version != 1 or record_size != RECORD.size:
            raise ValueError(
                f"unsupported trace: magic={magic!r}, version={version}, record={record_size}"
            )
        while True:
            raw = handle.read(RECORD.size)
            if not raw:
                break
            if len(raw) != RECORD.size:
                raise ValueError(f"truncated trace record in {path}")
            kind, size, flags, _reserved, _aux, sequence, pc, value = RECORD.unpack(raw)
            if kind == INSN:
                meta = metadata.get(pc)
                if meta is None:
                    missing_metadata[pc] += 1
                    meta = StaticInsn(pc, size, value, "unknown", "", "[unknown]")
                mask = (1 << (8 * min(size, 8))) - 1
                if (meta.raw & mask) != (value & mask):
                    raw_mismatches += 1
                item = DynamicInsn(sequence, pc, size, value, meta)
                instructions.append(item)
                by_sequence[sequence] = item
            elif kind == MEM:
                item = by_sequence.get(sequence)
                if item is None:
                    raise ValueError(f"memory record references unknown sequence {sequence}")
                item.memory.append(MemEvent(pc, value, size, bool(flags & MEM_STORE)))
            else:
                raise ValueError(f"unknown trace record kind {kind}")
    return {
        "start": start,
        "end": end,
        "instructions": instructions,
        "raw_mismatches": raw_mismatches,
        "missing_metadata": dict(missing_metadata),
    }


def control_kind(mnemonic: str) -> str | None:
    if mnemonic in COND_BRANCHES:
        return "conditional_branch"
    if mnemonic in DIRECT_JUMPS:
        return "direct_jump"
    if mnemonic in INDIRECT_JUMPS:
        return "indirect_jump"
    return None


def classify_instruction(item: DynamicInsn) -> tuple[str, str]:
    mnemonic = item.meta.mnemonic
    if item.memory:
        loads = any(not event.store for event in item.memory)
        stores = any(event.store for event in item.memory)
        if loads and stores:
            return "memory", "atomic_rmw"
        return ("memory", "store") if stores else ("memory", "load")
    control = control_kind(mnemonic)
    if control:
        return "control", control
    if mnemonic.startswith(SYSTEM_PREFIXES) or mnemonic.startswith("csr"):
        return "system", mnemonic.split(".")[0]
    if mnemonic.startswith("v") or mnemonic.startswith("th.v"):
        return "vector_compute", "vector"
    if (mnemonic.startswith("f") or mnemonic.startswith("th.f")) and not mnemonic.startswith("fence"):
        if "madd" in mnemonic or "msub" in mnemonic:
            return "fp_compute", "fp_fma"
        if "div" in mnemonic:
            return "fp_compute", "fp_div"
        if "sqrt" in mnemonic:
            return "fp_compute", "fp_sqrt"
        if "mul" in mnemonic:
            return "fp_compute", "fp_mul"
        if "add" in mnemonic or "sub" in mnemonic:
            return "fp_compute", "fp_add_sub"
        if "cvt" in mnemonic or "mv" in mnemonic:
            return "fp_compute", "fp_convert_move"
        if "cmp" in mnemonic or mnemonic.startswith(("feq", "flt", "fle")):
            return "fp_compute", "fp_compare"
        return "fp_compute", "fp_other"
    if "div" in mnemonic or "rem" in mnemonic:
        return "integer_compute", "int_div_rem"
    if "mul" in mnemonic:
        return "integer_compute", "int_mul"
    if any(token in mnemonic for token in ("sll", "srl", "sra", "rol", "ror")):
        return "integer_compute", "int_shift"
    if any(token in mnemonic for token in ("xor", "and", "or", "not")):
        return "integer_compute", "int_logic"
    if any(token in mnemonic for token in ("slt", "min", "max", "mveqz", "mvnez")):
        return "integer_compute", "int_compare_select"
    if mnemonic != "unknown":
        return "integer_compute", "int_add_address_other"
    return "other", "unknown"


def infer_registers(item: DynamicInsn) -> tuple[list[str], list[str]]:
    mnemonic = item.meta.mnemonic
    parts = split_operands(item.meta.operands)
    regs = operand_registers(item.meta.operands)
    category, subgroup = item.category, item.subgroup
    if not regs:
        return [], []
    if category == "control":
        if subgroup == "conditional_branch":
            return regs, []
        if mnemonic == "jal":
            dest = first_register(parts[0]) if len(parts) > 1 else "x1"
            return [], [dest] if dest and dest != "x0" else []
        if mnemonic == "jalr":
            dest = first_register(parts[0]) if parts else None
            sources = regs[1:] if dest else regs
            return sources, [dest] if dest and dest != "x0" else []
        if mnemonic == "c.jalr":
            return regs, ["x1"]
        return regs, []
    if category == "memory":
        if subgroup == "load":
            destinations = []
            if mnemonic.startswith("th.") and "dd" in mnemonic and len(regs) >= 3:
                destinations = regs[:2]
                sources = regs[2:]
            else:
                destinations = regs[:1]
                sources = regs[1:]
            return sources, [reg for reg in destinations if reg != "x0"]
        if subgroup == "store":
            return regs, []
        return regs, [regs[0]] if regs[0] != "x0" else []
    destination = regs[0]
    sources = regs[1:]
    read_modify_write = (
        mnemonic.startswith("c.") and mnemonic not in {"c.li", "c.lui"}
    )
    if read_modify_write and destination != "x0":
        sources = [destination] + sources
    return sources, [destination] if destination != "x0" else []


def parse_target(operands: str) -> int | None:
    candidates = re.findall(r"(?:^|,)\s*([0-9a-fA-F]+)(?:\s*<[^>]+>)?(?=\s*$|,)", operands)
    if not candidates:
        candidates = re.findall(r"\b([0-9a-fA-F]+)\s*<", operands)
    return int(candidates[-1], 16) if candidates else None


def branch_is_call(item: DynamicInsn) -> bool:
    mnemonic = item.meta.mnemonic
    parts = split_operands(item.meta.operands)
    if mnemonic in {"c.jal", "c.jalr"}:
        return True
    if mnemonic in {"jal", "jalr"}:
        dest = first_register(parts[0]) if len(parts) > 1 else "x1"
        return dest in {"x1", "x5"}
    return False


def branch_is_return(item: DynamicInsn) -> bool:
    mnemonic = item.meta.mnemonic
    regs = operand_registers(item.meta.operands)
    if mnemonic == "c.jr":
        return bool(regs and regs[0] in {"x1", "x5"})
    if mnemonic != "jalr" or not regs:
        return False
    parts = split_operands(item.meta.operands)
    dest = first_register(parts[0]) if len(parts) > 1 else "x1"
    source = regs[1] if len(regs) > 1 else regs[0]
    return dest == "x0" and source in {"x1", "x5"}


def analyze_control(instructions: list[DynamicInsn], end_pc: int | None = None):
    per_pc = {}
    subtype = collections.Counter()
    distance_bins = collections.Counter()
    basic_lengths = []
    block_counts = collections.Counter()
    current_start = instructions[0].pc if instructions else 0
    current_length = 0
    previous_end = None
    previous_control = True
    call_depth = 0
    max_call_depth = 0
    return_underflows = 0
    bimodal_states = {}
    bimodal_misses = 0
    static_control = {}

    for index, item in enumerate(instructions):
        if previous_end is not None and item.pc != previous_end and not previous_control:
            if current_length:
                basic_lengths.append(current_length)
                block_counts[current_start] += 1
            current_start = item.pc
            current_length = 0
        current_length += 1
        kind = control_kind(item.meta.mnemonic)
        next_pc = instructions[index + 1].pc if index + 1 < len(instructions) else end_pc
        is_control = kind is not None
        if is_control:
            subtype[kind] += 1
            properties = static_control.get(item.pc)
            if properties is None:
                properties = (
                    branch_is_call(item), branch_is_return(item),
                    parse_target(item.meta.operands),
                )
                static_control[item.pc] = properties
            is_call, is_return, target = properties
            if is_call:
                subtype["call"] += 1
                call_depth += 1
                max_call_depth = max(max_call_depth, call_depth)
            if is_return:
                subtype["return"] += 1
                if call_depth:
                    call_depth -= 1
                else:
                    return_underflows += 1
            fallthrough = item.pc + item.size
            taken = next_pc is not None and next_pc != fallthrough
            if kind != "conditional_branch":
                taken = True
            actual_target = next_pc if taken else fallthrough
            entry = per_pc.setdefault(item.pc, {
                "pc": item.pc, "function": item.meta.function,
                "mnemonic": item.meta.mnemonic, "executions": 0, "taken": 0,
                "transitions": 0, "last": None, "targets": collections.Counter(),
                "trip_counts": [], "taken_run": 0,
            })
            entry["executions"] += 1
            entry["taken"] += int(taken)
            if entry["last"] is not None and entry["last"] != taken:
                entry["transitions"] += 1
            entry["last"] = taken
            if actual_target is not None:
                entry["targets"][actual_target] += 1
            if kind == "conditional_branch":
                state = bimodal_states.get(item.pc, 1)
                bimodal_misses += int((state >= 2) != taken)
                bimodal_states[item.pc] = min(3, state + 1) if taken else max(0, state - 1)
                if taken and actual_target is not None and actual_target < item.pc:
                    entry["taken_run"] += 1
                elif entry["taken_run"]:
                    entry["trip_counts"].append(entry["taken_run"] + 1)
                    entry["taken_run"] = 0
            branch_target = target if target is not None else actual_target
            if branch_target is not None:
                displacement = abs(branch_target - item.pc)
                direction = "backward" if branch_target < item.pc else "forward"
                subtype[direction] += 1
                subtype[f"{kind}_{direction}"] += 1
                if displacement <= 32:
                    distance_bins["le32"] += 1
                elif displacement <= 128:
                    distance_bins["le128"] += 1
                elif displacement <= 512:
                    distance_bins["le512"] += 1
                elif displacement <= 4096:
                    distance_bins["le4096"] += 1
                else:
                    distance_bins["gt4096"] += 1
            basic_lengths.append(current_length)
            block_counts[current_start] += 1
            current_start = next_pc or fallthrough
            current_length = 0
        previous_end = item.pc + item.size
        previous_control = is_control
    if current_length:
        basic_lengths.append(current_length)
        block_counts[current_start] += 1

    branch_rows = []
    weighted_entropy = 0.0
    weighted_indirect_target_entropy = 0.0
    indirect_executions = 0
    weighted_transition_misses = 0
    high_entropy_dynamic = 0
    best_static_misses = 0
    conditional_total = subtype["conditional_branch"]
    loop_trip_counts = []
    for entry in per_pc.values():
        if entry["taken_run"]:
            entry["trip_counts"].append(entry["taken_run"] + 1)
        total = entry["executions"]
        ent = entropy_binary(entry["taken"], total)
        if entry["mnemonic"] in COND_BRANCHES:
            weighted_entropy += ent * total
            weighted_transition_misses += entry["transitions"]
            best_static_misses += min(entry["taken"], total - entry["taken"])
            if ent >= 0.8:
                high_entropy_dynamic += total
        if entry["mnemonic"] in INDIRECT_JUMPS:
            weighted_indirect_target_entropy += entropy_counts(entry["targets"].values()) * total
            indirect_executions += total
        loop_trip_counts.extend(entry["trip_counts"])
        branch_rows.append({
            "pc": f"0x{entry['pc']:x}", "function": entry["function"],
            "mnemonic": entry["mnemonic"], "executions": total,
            "taken_percent": percent(entry["taken"], total), "entropy": ent,
            "transition_percent": percent(entry["transitions"], max(total - 1, 0)),
            "unique_targets": len(entry["targets"]),
            "mean_loop_trip_count": statistics.fmean(entry["trip_counts"])
            if entry["trip_counts"] else 0.0,
        })
    branch_rows.sort(key=lambda row: row["executions"], reverse=True)
    return {
        "dynamic_control_instructions": sum(subtype[k] for k in (
            "conditional_branch", "direct_jump", "indirect_jump")),
        "static_control_instructions": len(per_pc),
        "subtypes": dict(subtype),
        "conditional_taken_percent": percent(
            sum(entry["taken"] for entry in per_pc.values()
                if entry["mnemonic"] in COND_BRANCHES), conditional_total),
        "weighted_branch_entropy": weighted_entropy / conditional_total
        if conditional_total else 0.0,
        "high_entropy_branch_dynamic_percent": percent(high_entropy_dynamic, conditional_total),
        "one_bit_transition_miss_proxy_percent": percent(
            weighted_transition_misses, conditional_total),
        "best_per_pc_static_miss_proxy_percent": percent(
            best_static_misses, conditional_total),
        "two_bit_bimodal_miss_proxy_percent": percent(
            bimodal_misses, conditional_total),
        "weighted_indirect_target_entropy": weighted_indirect_target_entropy /
        indirect_executions if indirect_executions else 0.0,
        "call_depth": {
            "max": max_call_depth, "final": call_depth,
            "return_underflows": return_underflows,
        },
        "loop_trip_count": {
            "samples": len(loop_trip_counts),
            "mean": statistics.fmean(loop_trip_counts) if loop_trip_counts else 0.0,
            "p50": percentile(loop_trip_counts, 0.50),
            "p90": percentile(loop_trip_counts, 0.90),
            "max": max(loop_trip_counts, default=0),
        },
        "target_distance_bins": dict(distance_bins),
        "basic_block_length": {
            "mean": statistics.fmean(basic_lengths) if basic_lengths else 0.0,
            "p50": percentile(basic_lengths, 0.50),
            "p90": percentile(basic_lengths, 0.90),
            "max": max(basic_lengths, default=0),
        },
        "dynamic_basic_blocks": len(basic_lengths),
        "static_executed_basic_blocks": len(block_counts),
        "top_branches": branch_rows[:20],
        "top1_branch_dynamic_percent": percent(
            branch_rows[0]["executions"] if branch_rows else 0,
            sum(entry["executions"] for entry in per_pc.values())),
        "top10_branch_dynamic_percent": percent(
            sum(row["executions"] for row in branch_rows[:10]),
            sum(entry["executions"] for entry in per_pc.values())),
        "top_basic_blocks": [
            {"pc": f"0x{pc:x}", "executions": count}
            for pc, count in block_counts.most_common(20)
        ],
    }


def update_line_masks(line_masks: dict[int, int], address: int, size: int) -> None:
    for byte in range(address, address + size):
        line = byte // 64
        line_masks[line] = line_masks.get(line, 0) | (1 << (byte % 64))


def analyze_memory(instructions: list[DynamicInsn], elf_layout: dict):
    events = [event for item in instructions for event in item.memory]
    load_instructions = sum(item.subgroup == "load" for item in instructions)
    store_instructions = sum(item.subgroup == "store" for item in instructions)
    atomic_instructions = sum(item.subgroup == "atomic_rmw" for item in instructions)
    loads = sum(not event.store for event in events)
    stores = len(events) - loads
    read_bytes = sum(event.size for event in events if not event.store)
    write_bytes = sum(event.size for event in events if event.store)
    size_counts = collections.Counter(event.size for event in events)
    unique_lines = set()
    unique_pages = set()
    load_lines = set()
    store_lines = set()
    load_pages = set()
    store_pages = set()
    line_masks = {}
    cross_line = 0
    cross_page = 0
    unaligned = 0
    per_pc = collections.defaultdict(lambda: {
        "count": 0, "loads": 0, "stores": 0, "last": None,
        "strides": collections.Counter(), "bytes": 0,
    })
    region_counts = collections.Counter()
    stack_top = elf_layout.get("symbols", {}).get("__kernel_stack")
    segments = elf_layout.get("segments", [])

    def address_region(address):
        if stack_top is not None and stack_top - 128 * 1024 <= address <= stack_top + 4096:
            return "stack"
        for segment in segments:
            if segment["vaddr"] <= address < segment["vaddr"] + segment["memsz"]:
                return "static_writable_data" if "W" in segment["flags"] else "code_or_rodata"
        return "heap_mmio_or_other"

    for event in events:
        region_counts[address_region(event.address)] += 1
        unique_lines.add(event.address // 64)
        unique_pages.add(event.address // 4096)
        if event.store:
            store_lines.add(event.address // 64)
            store_pages.add(event.address // 4096)
        else:
            load_lines.add(event.address // 64)
            load_pages.add(event.address // 4096)
        update_line_masks(line_masks, event.address, event.size)
        cross_line += int(event.address // 64 != (event.address + event.size - 1) // 64)
        cross_page += int(event.address // 4096 != (event.address + event.size - 1) // 4096)
        unaligned += int(event.size > 1 and event.address % event.size != 0)
        entry = per_pc[event.pc]
        entry["count"] += 1
        entry["loads"] += int(not event.store)
        entry["stores"] += int(event.store)
        entry["bytes"] += event.size
        if entry["last"] is not None:
            entry["strides"][event.address - entry["last"]] += 1
        entry["last"] = event.address

    fenwick = Fenwick(len(events))
    last_position = {}
    reuse_hist = collections.Counter()
    cold = 0
    for index, event in enumerate(events):
        line = event.address // 64
        previous = last_position.get(line)
        if previous is None:
            cold += 1
        else:
            distance = fenwick.prefix(index - 1) - fenwick.prefix(previous)
            reuse_hist[distance] += 1
            fenwick.add(previous, -1)
        fenwick.add(index, 1)
        last_position[line] = index

    cache_sizes = [4, 8, 16, 32, 64, 128, 256, 512, 1024]
    miss_ratio = {}
    for kib in cache_sizes:
        capacity = kib * 1024 // 64
        misses = cold + sum(count for distance, count in reuse_hist.items()
                            if distance >= capacity)
        miss_ratio[f"{kib}KiB"] = percent(misses, len(events))

    pattern_counts = collections.Counter()
    per_pc_rows = []
    for pc, entry in per_pc.items():
        transitions = max(entry["count"] - 1, 0)
        dominant_stride, dominant_count = (entry["strides"].most_common(1)[0]
                                            if entry["strides"] else (0, 0))
        dominant_ratio = dominant_count / transitions if transitions else 0.0
        top3_ratio = sum(count for _, count in entry["strides"].most_common(3)) / transitions \
            if transitions else 0.0
        typical_size = round(entry["bytes"] / entry["count"]) if entry["count"] else 0
        if transitions == 0:
            pattern = "single"
        elif dominant_stride == typical_size and dominant_ratio >= 0.60:
            pattern = "sequential"
        elif dominant_stride != 0 and dominant_ratio >= 0.60:
            pattern = "fixed_stride"
        elif top3_ratio >= 0.80:
            pattern = "multi_stride"
        else:
            pattern = "irregular"
        pattern_counts[pattern] += entry["count"]
        per_pc_rows.append({
            "pc": f"0x{pc:x}", "accesses": entry["count"],
            "loads": entry["loads"], "stores": entry["stores"],
            "bytes": entry["bytes"], "pattern": pattern,
            "dominant_stride": dominant_stride,
            "dominant_stride_percent": 100.0 * dominant_ratio,
        })
    per_pc_rows.sort(key=lambda row: row["accesses"], reverse=True)
    used_bytes = sum(bin(mask).count("1") for mask in line_masks.values())
    prefetchable = pattern_counts["sequential"] + pattern_counts["fixed_stride"]
    addresses = [event.address for event in events]
    page_profile = reuse_profile(
        [event.address // 4096 for event in events],
        {"16_entries": 16, "32_entries": 32, "64_entries": 64,
         "128_entries": 128, "256_entries": 256, "512_entries": 512},
    )
    return {
        "accesses": len(events), "loads": loads, "stores": stores,
        "load_instructions": load_instructions,
        "store_instructions": store_instructions,
        "atomic_rmw_instructions": atomic_instructions,
        "load_percent": percent(loads, len(events)),
        "store_percent": percent(stores, len(events)),
        "load_store_ratio": loads / stores if stores else None,
        "read_bytes": read_bytes, "write_bytes": write_bytes,
        "bytes_per_instruction": (read_bytes + write_bytes) / len(instructions)
        if instructions else 0.0,
        "access_size_counts": {str(key): value for key, value in sorted(size_counts.items())},
        "unaligned_percent": percent(unaligned, len(events)),
        "cross_cache_line_percent": percent(cross_line, len(events)),
        "cross_page_percent": percent(cross_page, len(events)),
        "unique_cache_lines_64B": len(unique_lines),
        "unique_pages_4KiB": len(unique_pages),
        "unique_load_cache_lines_64B": len(load_lines),
        "unique_store_cache_lines_64B": len(store_lines),
        "unique_load_pages_4KiB": len(load_pages),
        "unique_store_pages_4KiB": len(store_pages),
        "minimum_address": f"0x{min(addresses):x}" if addresses else None,
        "maximum_address": f"0x{max(addresses):x}" if addresses else None,
        "address_span_bytes": max(addresses) - min(addresses) + 1 if addresses else 0,
        "unique_touched_bytes": used_bytes,
        "working_set_bytes_64B_lines": len(unique_lines) * 64,
        "cache_line_byte_utilization_percent": percent(used_bytes, len(line_masks) * 64),
        "reuse_distance_lines": {
            "cold_access_percent": percent(cold, len(events)),
            "p50": percentile_histogram(reuse_hist, 0.50),
            "p90": percentile_histogram(reuse_hist, 0.90),
            "p99": percentile_histogram(reuse_hist, 0.99),
            "max": max(reuse_hist, default=0),
        },
        "fully_associative_miss_ratio_curve": miss_ratio,
        "page_reuse_and_fully_associative_tlb_curve": page_profile,
        "address_pattern_dynamic_accesses": dict(pattern_counts),
        "prefetchable_sequential_or_fixed_stride_percent": percent(
            prefetchable, len(events)),
        "address_region_dynamic_accesses": dict(region_counts),
        "top_memory_instructions": per_pc_rows[:20],
        "temporal_working_set_64B_lines": temporal_working_set(
            [event.address // 64 for event in events]),
    }


def analyze_code_locality(instructions: list[DynamicInsn]):
    lines_32 = [item.pc // 32 for item in instructions]
    lines_64 = [item.pc // 64 for item in instructions]
    pcs = [item.pc for item in instructions]
    return {
        "unique_instruction_pcs": len(set(pcs)),
        "unique_code_lines_32B": len(set(lines_32)),
        "unique_code_lines_64B": len(set(lines_64)),
        "instruction_line_reuse_64B": reuse_profile(lines_64, {
            "4KiB": 64, "8KiB": 128, "16KiB": 256, "32KiB": 512,
            "64KiB": 1024, "128KiB": 2048, "256KiB": 4096,
        }),
        "temporal_working_set_64B_lines": temporal_working_set(lines_64),
        "dynamic_pc_entropy_bits": entropy_counts(collections.Counter(pcs).values()),
    }


def instruction_latency(item: DynamicInsn) -> int:
    if item.subgroup == "load":
        return 4
    if item.subgroup in {"int_mul"}:
        return 3
    if item.subgroup in {"int_div_rem"}:
        return 20
    if item.subgroup in {"fp_fma"}:
        return 4
    if item.subgroup in {"fp_div", "fp_sqrt"}:
        return 16
    if item.category == "fp_compute":
        return 3
    return 1


def dependency_window(items: list[DynamicInsn]) -> float:
    ready = {}
    finish = 0
    for item in items:
        start = max((ready.get(reg, 0) for reg in item.sources), default=0)
        finish = start + instruction_latency(item)
        for reg in item.destinations:
            ready[reg] = finish
    return len(items) / max(finish, 1)


def analyze_dependencies(instructions: list[DynamicInsn]):
    last_writer = {}
    writer_category = {}
    dependency_distances = []
    load_dependency_distances = []
    first_load_use_distances = []
    consumed_load_writers = set()
    branch_producer_distances = []
    address_dep_load = 0
    load_count = 0
    last_store_byte = {}
    forwarded_loads = 0
    store_load_distances = []
    ready = {}
    critical_path = 0
    distinct_written_registers = []
    independent_load_flags = []

    for item in instructions:
        source_ready = []
        address_has_load_dependency = False
        for reg in item.sources:
            if reg in last_writer:
                distance = item.sequence - last_writer[reg]
                dependency_distances.append(distance)
                source_ready.append(ready.get(reg, 0))
                if writer_category.get(reg) == "load":
                    load_dependency_distances.append(distance)
                    writer_key = (reg, last_writer[reg])
                    if writer_key not in consumed_load_writers:
                        first_load_use_distances.append(distance)
                        consumed_load_writers.add(writer_key)
                    if item.subgroup == "load":
                        address_has_load_dependency = True
                if item.subgroup == "conditional_branch":
                    branch_producer_distances.append(distance)
        start = max(source_ready, default=0)
        finish = start + instruction_latency(item)
        critical_path = max(critical_path, finish)
        for reg in item.destinations:
            last_writer[reg] = item.sequence
            writer_category[reg] = item.subgroup
            ready[reg] = finish
        distinct_written_registers.append(len(last_writer))

        if item.subgroup == "load":
            load_count += 1
            address_dep_load += int(address_has_load_dependency)
            independent_load_flags.append(int(not address_has_load_dependency))
            hit_sequences = []
            for event in item.memory:
                if event.store:
                    continue
                for byte in range(event.address, event.address + event.size):
                    if byte in last_store_byte:
                        hit_sequences.append(last_store_byte[byte])
            if hit_sequences:
                forwarded_loads += 1
                store_load_distances.append(item.sequence - max(hit_sequences))
        else:
            independent_load_flags.append(0)
        for event in item.memory:
            if event.store:
                for byte in range(event.address, event.address + event.size):
                    last_store_byte[byte] = item.sequence

    live_counts = []
    live_int_counts = []
    live_fp_counts = []
    live = set()
    live_int = 0
    live_fp = 0
    for item in reversed(instructions):
        for reg in item.destinations:
            if reg in live:
                live.remove(reg)
                live_int -= int(reg.startswith("x"))
                live_fp -= int(reg.startswith("f"))
        for reg in item.sources:
            if reg != "x0" and reg not in live:
                live.add(reg)
                live_int += int(reg.startswith("x"))
                live_fp += int(reg.startswith("f"))
        live_counts.append(len(live))
        live_int_counts.append(live_int)
        live_fp_counts.append(live_fp)

    ilp = {}
    for window in (16, 32, 64, 128):
        values = [dependency_window(instructions[i:i + window])
                  for i in range(0, len(instructions), window)]
        ilp[str(window)] = {
            "mean": statistics.fmean(values) if values else 0.0,
            "p50": percentile(values, 0.50), "p90": percentile(values, 0.90),
        }
    loads_per_32 = [
        sum(item.subgroup == "load" for item in instructions[i:i + 32])
        for i in range(0, len(instructions), 32)
    ]
    independent_loads_per_32 = [
        sum(independent_load_flags[i:i + 32])
        for i in range(0, len(independent_load_flags), 32)
    ]
    return {
        "register_dependency_distance": {
            "samples": len(dependency_distances),
            "mean": statistics.fmean(dependency_distances) if dependency_distances else 0.0,
            "p50": percentile(dependency_distances, 0.50),
            "p90": percentile(dependency_distances, 0.90),
            "p99": percentile(dependency_distances, 0.99),
        },
        "load_use_distance": {
            "samples": len(first_load_use_distances),
            "mean": statistics.fmean(first_load_use_distances)
            if first_load_use_distances else 0.0,
            "p50": percentile(first_load_use_distances, 0.50),
            "p90": percentile(first_load_use_distances, 0.90),
            "le4_percent": percent(sum(value <= 4 for value in first_load_use_distances),
                                    len(first_load_use_distances)),
        },
        "all_load_dependency_distance": {
            "samples": len(load_dependency_distances),
            "p50": percentile(load_dependency_distances, 0.50),
            "p90": percentile(load_dependency_distances, 0.90),
        },
        "branch_condition_producer_distance": {
            "samples": len(branch_producer_distances),
            "mean": statistics.fmean(branch_producer_distances)
            if branch_producer_distances else 0.0,
            "p90": percentile(branch_producer_distances, 0.90),
        },
        "load_address_depends_on_load_percent": percent(address_dep_load, load_count),
        "load_with_prior_same_address_store_percent": percent(forwarded_loads, load_count),
        "store_to_load_distance_p50": percentile(store_load_distances, 0.50),
        "abstract_critical_path_cycles": critical_path,
        "global_ideal_ilp": len(instructions) / max(critical_path, 1),
        "window_ideal_ilp": ilp,
        "loads_per_32_instruction_window": {
            "mean": statistics.fmean(loads_per_32) if loads_per_32 else 0.0,
            "p90": percentile(loads_per_32, 0.90),
            "max": max(loads_per_32, default=0),
        },
        "independent_loads_per_32_instruction_window": {
            "mean": statistics.fmean(independent_loads_per_32)
            if independent_loads_per_32 else 0.0,
            "p90": percentile(independent_loads_per_32, 0.90),
            "max": max(independent_loads_per_32, default=0),
            "note": "Address-register independence proxy, not measured outstanding misses.",
        },
        "distinct_written_registers_so_far": {
            "mean": statistics.fmean(distinct_written_registers)
            if distinct_written_registers else 0.0,
            "max": max(distinct_written_registers, default=0),
            "note": "This is not live-register pressure; exact liveness requires a separate backward analysis.",
        },
        "dynamic_register_liveness": {
            "mean_total": statistics.fmean(live_counts) if live_counts else 0.0,
            "p90_total": percentile(live_counts, 0.90),
            "max_total": max(live_counts, default=0),
            "mean_integer": statistics.fmean(live_int_counts) if live_int_counts else 0.0,
            "max_integer": max(live_int_counts, default=0),
            "mean_fp": statistics.fmean(live_fp_counts) if live_fp_counts else 0.0,
            "max_fp": max(live_fp_counts, default=0),
        },
        "model_note": "Idealized infinite-resource dependency model; latencies are configurable abstractions, not C910 cycles.",
    }


def count_flops(item: DynamicInsn) -> int:
    if item.category != "fp_compute":
        return 0
    if item.subgroup == "fp_fma":
        return 2
    return 1


def phase_stability(instructions: list[DynamicInsn]):
    windows = []
    window_size = max(256, min(PHASE_WINDOW, math.ceil(len(instructions) / 16))) \
        if instructions else PHASE_WINDOW
    for start in range(0, len(instructions), window_size):
        subset = instructions[start:start + window_size]
        categories = collections.Counter(item.category for item in subset)
        windows.append({
            "start_sequence": start + 1, "instructions": len(subset),
            "memory_percent": percent(categories["memory"], len(subset)),
            "control_percent": percent(categories["control"], len(subset)),
            "fp_percent": percent(categories["fp_compute"], len(subset)),
        })
    variation = {}
    for key in ("memory_percent", "control_percent", "fp_percent"):
        values = [window[key] for window in windows]
        mean = statistics.fmean(values) if values else 0.0
        variation[key] = {
            "mean": mean,
            "stddev": statistics.pstdev(values) if len(values) > 1 else 0.0,
            "coefficient_of_variation": statistics.pstdev(values) / mean
            if len(values) > 1 and mean else 0.0,
        }
    return {"window_instructions": window_size, "windows": windows,
            "variation": variation}


def top_rows(counter: collections.Counter, total: int, limit: int = 20):
    return [
        {"name": str(name), "count": count, "percent": percent(count, total)}
        for name, count in counter.most_common(limit)
    ]


def analyze_composition_phases(instructions, symbols, trace_start=None):
    markers = {}
    phase_names = []
    for phase in range(16):
        name = f"phase{phase}"
        start = symbols.get(f"spec_composition_{name}_start")
        end = symbols.get(f"spec_composition_{name}_end")
        if start is None and end is None:
            continue
        if start is None or end is None:
            raise ValueError(f"incomplete composition markers for {name}")
        markers[start] = ("start", name)
        markers[end] = ("end", name)
        phase_names.append(name)

    if not phase_names:
        return None

    counts = collections.Counter()
    active = next(
        (
            name
            for name in phase_names
            if symbols[f"spec_composition_{name}_start"] == trace_start
        ),
        None,
    )
    marker_count = 0
    for item in instructions:
        marker = markers.get(item.pc)
        if marker:
            marker_count += 1
            action, name = marker
            if action == "start":
                if active is not None:
                    raise ValueError(f"nested composition phases: {active} then {name}")
                active = name
            else:
                if active != name:
                    raise ValueError(f"composition phase end {name} while active={active}")
                active = None
            continue
        if active is not None:
            counts[active] += 1
    if active is not None:
        raise ValueError(f"unterminated composition phase {active}")

    attributed = sum(counts.values())
    total = len(instructions)
    return {
        "attributed_instructions": attributed,
        "marker_instructions": marker_count,
        "unattributed_instructions": total - attributed - marker_count,
        "coverage_percent": percent(attributed, total),
        "phases": [
            {
                "name": name,
                "count": counts[name],
                "share": counts[name] / attributed if attributed else 0.0,
            }
            for name in phase_names
        ],
    }


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def analyze(
    case: str,
    elf: Path,
    trace: Path,
    objdump: str,
    rtl_retired: int | None,
    rtl_retired_tolerance: int = 0,
    kernel_profile: str | None = None,
    warmup_instructions: int | None = None,
):
    metadata = parse_objdump(elf, objdump)
    elf_layout = parse_elf_layout(elf, objdump)
    loaded = load_trace(trace, metadata)
    instructions = loaded["instructions"]
    decode_cache = {}
    for item in instructions:
        memory_signature = (
            any(not event.store for event in item.memory),
            any(event.store for event in item.memory),
        )
        cache_key = (item.pc, memory_signature)
        decoded = decode_cache.get(cache_key)
        if decoded is None:
            item.category, item.subgroup = classify_instruction(item)
            sources, destinations = infer_registers(item)
            decoded = (item.category, item.subgroup,
                       tuple(sources), tuple(destinations))
            decode_cache[cache_key] = decoded
        item.category, item.subgroup, item.sources, item.destinations = decoded

    category_counts = collections.Counter(item.category for item in instructions)
    subgroup_counts = collections.Counter(item.subgroup for item in instructions)
    mnemonic_counts = collections.Counter(item.meta.mnemonic for item in instructions)
    pc_counts = collections.Counter(item.pc for item in instructions)
    function_counts = collections.Counter(item.meta.function for item in instructions)
    total = len(instructions)
    composition_phases = analyze_composition_phases(
        instructions, elf_layout["symbols"], loaded["start"]
    )
    control = analyze_control(instructions, loaded["end"])
    memory = analyze_memory(instructions, elf_layout)
    code_locality = analyze_code_locality(instructions)
    dependencies = analyze_dependencies(instructions)
    dynamic_bytes = sum(item.size for item in instructions)
    static_pcs = {item.pc for item in instructions}
    static_code_bytes = sum(metadata[pc].size for pc in static_pcs if pc in metadata)
    flops = sum(count_flops(item) for item in instructions)
    integer_ops = category_counts["integer_compute"]
    requested_bytes = memory["read_bytes"] + memory["write_bytes"]
    classification_total = sum(category_counts.values())
    if classification_total != total:
        raise AssertionError(f"classification mismatch: {classification_total} != {total}")

    top_pc = []
    for pc, count in pc_counts.most_common(20):
        meta = metadata.get(pc)
        top_pc.append({
            "pc": f"0x{pc:x}", "count": count, "percent": percent(count, total),
            "function": meta.function if meta else "[unknown]",
            "instruction": f"{meta.mnemonic} {meta.operands}".strip() if meta else "unknown",
        })
    rtl_delta = total - rtl_retired if rtl_retired is not None else None
    result = {
        "schema_version": SCHEMA_VERSION,
        "case": case,
        "profile": {
            "kernel_profile": kernel_profile,
            "warmup_instructions": warmup_instructions,
        },
        "provenance": {
            "elf": str(elf.resolve()), "elf_sha256": sha256(elf),
            "trace": str(trace.resolve()), "objdump": objdump,
            "marker_start": f"0x{loaded['start']:x}",
            "marker_end": f"0x{loaded['end']:x}",
        },
        "validation": {
            "trace_instruction_count": total,
            "rtl_kernel_retired_instructions": rtl_retired,
            "rtl_instruction_delta": rtl_delta,
            "rtl_instruction_tolerance": rtl_retired_tolerance,
            "raw_instruction_mismatches": loaded["raw_mismatches"],
            "missing_metadata_dynamic_instructions": sum(loaded["missing_metadata"].values()),
            "exclusive_instruction_categories_sum": classification_total,
            "passed": loaded["raw_mismatches"] == 0
            and not loaded["missing_metadata"]
            and (rtl_delta is None or abs(rtl_delta) <= rtl_retired_tolerance),
        },
        "execution": {
            "dynamic_instructions": total,
            "dynamic_instruction_bytes": dynamic_bytes,
            "static_executed_instructions": len(static_pcs),
            "static_executed_code_bytes": static_code_bytes,
            "compressed_dynamic_percent": percent(
                sum(item.size == 2 for item in instructions), total),
            "code_lines_32B": len({item.pc // 32 for item in instructions}),
            "code_lines_64B": len({item.pc // 64 for item in instructions}),
        },
        "instruction_mix": {
            "dynamic_mnemonic_entropy_bits": entropy_counts(mnemonic_counts.values()),
            "dynamic_mnemonic_kinds": len(mnemonic_counts),
            "exclusive_categories": {
                key: {"count": category_counts[key], "percent": percent(category_counts[key], total)}
                for key in sorted(category_counts)
            },
            "subgroups": {
                key: {"count": subgroup_counts[key], "percent": percent(subgroup_counts[key], total)}
                for key in sorted(subgroup_counts)
            },
            "top_mnemonics": top_rows(mnemonic_counts, total),
        },
        "control_flow": control,
        "code_locality": code_locality,
        "memory": memory,
        "dependencies_and_parallelism": dependencies,
        "arithmetic_intensity": {
            "floating_point_operations": flops,
            "integer_compute_instructions": integer_ops,
            "requested_memory_bytes": requested_bytes,
            "flops_per_requested_byte": flops / requested_bytes if requested_bytes else None,
            "integer_ops_per_requested_byte": integer_ops / requested_bytes
            if requested_bytes else None,
        },
        "hotspots": {
            "functions": top_rows(function_counts, total),
            "instructions": top_pc,
        },
        "composition_phases": composition_phases,
        "phase_stability": phase_stability(instructions),
        "measurement_classes": {
            "directly_observed": [
                "dynamic instruction stream", "branch outcomes", "memory addresses and sizes"
            ],
            "exactly_derived": [
                "instruction mix", "basic blocks", "branch entropy",
                "working set", "reuse distance", "hotspots"
            ],
            "model_derived": [
                "stride and prefetchability classes", "register dependencies",
                "load-use distance", "dynamic liveness", "ideal ILP", "critical path"
            ],
        },
    }
    return result


def kernel_summary(result: dict) -> str:
    mix = result["instruction_mix"]["exclusive_categories"]
    memory = result["memory"]
    control = result["control_flow"]
    deps = result["dependencies_and_parallelism"]
    code = result["code_locality"]
    arithmetic = result["arithmetic_intensity"]
    phase = result["phase_stability"]
    total = result["execution"]["dynamic_instructions"]
    lines = [f"# {result['case']} 动态 Kernel 特征", ""]
    lines.extend([
        "## 口径", "",
        "只统计当前 ELF 中 `perf_monitor_start` 退休之后至 `perf_monitor_end` 之前的动态执行。",
        "本报告描述程序特征，不包含 IPC、cache miss 或分支预测失败等微结构响应。", "",
        "## 核心特征", "",
        "| 指标 | 数值 |", "|---|---:|",
        f"| 动态指令 | {total:,} |",
        f"| 静态执行指令 | {result['execution']['static_executed_instructions']:,} |",
        f"| 压缩指令 | {result['execution']['compressed_dynamic_percent']:.2f}% |",
        f"| 整数计算 | {mix.get('integer_compute', {}).get('percent', 0):.2f}% |",
        f"| 浮点计算 | {mix.get('fp_compute', {}).get('percent', 0):.2f}% |",
        f"| 访存指令 | {mix.get('memory', {}).get('percent', 0):.2f}% |",
        f"| 控制流指令 | {mix.get('control', {}).get('percent', 0):.2f}% |",
        f"| load / store | {memory['loads']:,} / {memory['stores']:,} |",
        f"| 条件分支 | {control['subtypes'].get('conditional_branch', 0):,} |",
        f"| 条件分支 taken | {control['conditional_taken_percent']:.2f}% |",
        f"| 加权分支熵 | {control['weighted_branch_entropy']:.4f} |",
        f"| 平均基本块长度 | {control['basic_block_length']['mean']:.2f} |",
        f"| 64B 数据工作集 | {memory['working_set_bytes_64B_lines']:,} B |",
        f"| reuse distance P90 | {memory['reuse_distance_lines']['p90']:.1f} lines |",
        f"| load-use 距离 P90 | {deps['load_use_distance']['p90']:.1f} instructions |",
        f"| 64 指令窗口理想 ILP | {deps['window_ideal_ilp']['64']['mean']:.2f} |",
        "", "## 指令构成", "",
        "| 类别 | 动态数量 | 占比 |", "|---|---:|---:|",
    ])
    for name, item in mix.items():
        lines.append(f"| `{name}` | {item['count']:,} | {item['percent']:.2f}% |")
    lines.extend(["", "### 细分指令类型", "", "| 类型 | 动态数量 | 占比 |",
                  "|---|---:|---:|"])
    for name, item in result["instruction_mix"]["subgroups"].items():
        lines.append(f"| `{name}` | {item['count']:,} | {item['percent']:.2f}% |")

    lines.extend([
        "", "## 控制流", "", "| 指标 | 数值 |", "|---|---:|",
        f"| 动态控制流指令 | {control['dynamic_control_instructions']:,} |",
        f"| 静态控制流指令 | {control['static_control_instructions']:,} |",
        f"| 条件分支 | {control['subtypes'].get('conditional_branch', 0):,} |",
        f"| 直接跳转 | {control['subtypes'].get('direct_jump', 0):,} |",
        f"| 间接跳转 | {control['subtypes'].get('indirect_jump', 0):,} |",
        f"| call / return | {control['subtypes'].get('call', 0):,} / {control['subtypes'].get('return', 0):,} |",
        f"| 条件分支后向比例 | {percent(control['subtypes'].get('conditional_branch_backward', 0), control['subtypes'].get('conditional_branch', 0)):.2f}% |",
        f"| 条件分支 taken | {control['conditional_taken_percent']:.2f}% |",
        f"| 加权条件分支熵 | {control['weighted_branch_entropy']:.4f} |",
        f"| 高熵条件分支动态占比 | {control['high_entropy_branch_dynamic_percent']:.2f}% |",
        f"| 最佳静态 per-PC 失误代理 | {control['best_per_pc_static_miss_proxy_percent']:.2f}% |",
        f"| 1-bit 翻转失误代理 | {control['one_bit_transition_miss_proxy_percent']:.2f}% |",
        f"| 2-bit bimodal 失误代理 | {control['two_bit_bimodal_miss_proxy_percent']:.2f}% |",
        f"| 间接目标熵 | {control['weighted_indirect_target_entropy']:.4f} |",
        f"| 最大调用深度 | {control['call_depth']['max']} |",
        f"| 循环 trip count P50 / P90 | {control['loop_trip_count']['p50']:.1f} / {control['loop_trip_count']['p90']:.1f} |",
        f"| 基本块长度 mean / P90 / max | {control['basic_block_length']['mean']:.2f} / {control['basic_block_length']['p90']:.1f} / {control['basic_block_length']['max']} |",
        "", "### 热点分支", "", "| PC | 函数 | 指令 | 执行次数 | taken | 熵 | 翻转率 | 目标数 |",
        "|---|---|---|---:|---:|---:|---:|---:|",
    ])
    for row in control["top_branches"][:10]:
        lines.append(
            f"| `{row['pc']}` | `{row['function']}` | `{row['mnemonic']}` | "
            f"{row['executions']:,} | {row['taken_percent']:.2f}% | {row['entropy']:.3f} | "
            f"{row['transition_percent']:.2f}% | {row['unique_targets']} |"
        )

    lines.extend([
        "", "## 代码局部性", "", "| 指标 | 数值 |", "|---|---:|",
        f"| 唯一动态 PC | {code['unique_instruction_pcs']:,} |",
        f"| 唯一 32B / 64B 代码块 | {code['unique_code_lines_32B']:,} / {code['unique_code_lines_64B']:,} |",
        f"| 64B I-line reuse P50 / P90 / P99 | {code['instruction_line_reuse_64B']['p50']:.1f} / {code['instruction_line_reuse_64B']['p90']:.1f} / {code['instruction_line_reuse_64B']['p99']:.1f} |",
        f"| 动态 PC 熵 | {code['dynamic_pc_entropy_bits']:.3f} bits |",
        f"| 时间窗口活跃 I-line P90 | {code['temporal_working_set_64B_lines']['p90']:.1f} |",
        "", "## 访存与数据局部性", "", "| 指标 | 数值 |", "|---|---:|",
        f"| load/store 指令 | {memory['load_instructions']:,} / {memory['store_instructions']:,} |",
        f"| load/store 访问事件 | {memory['loads']:,} / {memory['stores']:,} |",
        f"| 读取/写入字节 | {memory['read_bytes']:,} / {memory['write_bytes']:,} |",
        f"| 每指令访问字节 | {memory['bytes_per_instruction']:.3f} |",
        f"| 64B line 工作集 | {memory['working_set_bytes_64B_lines']:,} B |",
        f"| load/store 唯一 64B line | {memory['unique_load_cache_lines_64B']:,} / {memory['unique_store_cache_lines_64B']:,} |",
        f"| 4KiB page 工作集 | {memory['unique_pages_4KiB']} pages |",
        f"| load/store 唯一 4KiB page | {memory['unique_load_pages_4KiB']:,} / {memory['unique_store_pages_4KiB']:,} |",
        f"| 唯一触及字节 / 地址跨度 | {memory['unique_touched_bytes']:,} / {memory['address_span_bytes']:,} B |",
        f"| line 字节利用率 | {memory['cache_line_byte_utilization_percent']:.2f}% |",
        f"| 顺序或固定步长可预取代理 | {memory['prefetchable_sequential_or_fixed_stride_percent']:.2f}% |",
        f"| 非对齐 / 跨 line / 跨页 | {memory['unaligned_percent']:.2f}% / {memory['cross_cache_line_percent']:.2f}% / {memory['cross_page_percent']:.2f}% |",
        f"| cold access | {memory['reuse_distance_lines']['cold_access_percent']:.2f}% |",
        f"| reuse distance P50 / P90 / P99 | {memory['reuse_distance_lines']['p50']:.1f} / {memory['reuse_distance_lines']['p90']:.1f} / {memory['reuse_distance_lines']['p99']:.1f} lines |",
        "", "### 访问宽度", "", "| 字节 | 次数 |", "|---:|---:|",
    ])
    for size, count in memory["access_size_counts"].items():
        lines.append(f"| {size} | {count:,} |")
    lines.extend(["", "### 地址模式", "", "| 模式 | 动态访问 | 占比 |",
                  "|---|---:|---:|"])
    for name, count in memory["address_pattern_dynamic_accesses"].items():
        lines.append(f"| `{name}` | {count:,} | {percent(count, memory['accesses']):.2f}% |")
    lines.extend(["", "### 地址区域", "", "| 区域 | 动态访问 | 占比 |",
                  "|---|---:|---:|"])
    for name, count in memory["address_region_dynamic_accesses"].items():
        lines.append(f"| `{name}` | {count:,} | {percent(count, memory['accesses']):.2f}% |")
    lines.extend(["", "### 全相联 LRU miss-ratio curve", "", "| 容量 | 理论 miss ratio |",
                  "|---:|---:|"])
    for size, ratio in memory["fully_associative_miss_ratio_curve"].items():
        lines.append(f"| {size} | {ratio:.3f}% |")
    lines.extend(["", "### 页复用与全相联 TLB 曲线", "",
                  "| TLB 容量 | 理论 miss ratio |", "|---:|---:|"])
    for size, ratio in memory[
            "page_reuse_and_fully_associative_tlb_curve"]["miss_ratio_curve"].items():
        lines.append(f"| {size} | {ratio:.3f}% |")

    lines.extend([
        "", "## 数据依赖与潜在并行性", "",
        "以下指标由反汇编中的显式寄存器操作数和抽象延迟模型推断；不建模隐式寄存器、"
        "物理寄存器重命名、真实 cache 延迟和执行端口约束。", "",
        "| 指标 | 数值 |", "|---|---:|",
        f"| 寄存器依赖距离 P50 / P90 / P99 | {deps['register_dependency_distance']['p50']:.1f} / {deps['register_dependency_distance']['p90']:.1f} / {deps['register_dependency_distance']['p99']:.1f} |",
        f"| 第一次 load-use P50 / P90 | {deps['load_use_distance']['p50']:.1f} / {deps['load_use_distance']['p90']:.1f} |",
        f"| 第一次 load-use <=4 | {deps['load_use_distance']['le4_percent']:.2f}% |",
        f"| branch producer 距离 P90 | {deps['branch_condition_producer_distance']['p90']:.1f} |",
        f"| load 地址依赖 load | {deps['load_address_depends_on_load_percent']:.2f}% |",
        f"| load 存在先前同地址 store | {deps['load_with_prior_same_address_store_percent']:.2f}% |",
        f"| 活跃寄存器 mean / P90 / max | {deps['dynamic_register_liveness']['mean_total']:.2f} / {deps['dynamic_register_liveness']['p90_total']:.1f} / {deps['dynamic_register_liveness']['max_total']} |",
        f"| 32 指令窗口独立 load P90 | {deps['independent_loads_per_32_instruction_window']['p90']:.1f} |",
        "", "### 理想窗口 ILP", "", "| 窗口 | mean | P50 | P90 |", "|---:|---:|---:|---:|",
    ])
    for window, item in deps["window_ideal_ilp"].items():
        lines.append(f"| {window} | {item['mean']:.2f} | {item['p50']:.2f} | {item['p90']:.2f} |")

    lines.extend([
        "", "## 算术强度", "", "| 指标 | 数值 |", "|---|---:|",
        f"| 浮点操作数 | {arithmetic['floating_point_operations']:,} |",
        f"| 整数计算指令 | {arithmetic['integer_compute_instructions']:,} |",
        f"| 请求访存字节 | {arithmetic['requested_memory_bytes']:,} |",
        f"| FLOP/byte | {(arithmetic['flops_per_requested_byte'] or 0):.4f} |",
        f"| integer-op/byte | {(arithmetic['integer_ops_per_requested_byte'] or 0):.4f} |",
        "", "## 热点函数", "", "| 函数 | 动态指令 | 占比 |",
        "|---|---:|---:|",
    ])
    for row in result["hotspots"]["functions"][:10]:
        lines.append(f"| `{row['name']}` | {row['count']:,} | {row['percent']:.2f}% |")
    lines.extend(["", "## 热点指令", "", "| PC | 函数 | 指令 | 动态次数 | 占比 |",
                  "|---|---|---|---:|---:|"])
    for row in result["hotspots"]["instructions"][:15]:
        lines.append(
            f"| `{row['pc']}` | `{row['function']}` | `{row['instruction']}` | "
            f"{row['count']:,} | {row['percent']:.2f}% |"
        )
    lines.extend([
        "", "## 阶段稳定性", "", "| 指标 | 均值 | 标准差 | 变异系数 |",
        "|---|---:|---:|---:|",
    ])
    for name, item in phase["variation"].items():
        lines.append(
            f"| `{name}` | {item['mean']:.3f} | {item['stddev']:.3f} | "
            f"{item['coefficient_of_variation']:.3f} |"
        )
    lines.extend(["", "## 校验", "",
                  f"- ELF SHA256：`{result['provenance']['elf_sha256']}`",
                  f"- trace 指令数：`{result['validation']['trace_instruction_count']}`",
                  f"- RTL Kernel retired inst：`{result['validation']['rtl_kernel_retired_instructions']}`",
                  f"- trace/RTL 差值与容差：`{result['validation']['rtl_instruction_delta']}` / "
                  f"`{result['validation']['rtl_instruction_tolerance']}`",
                  f"- Kernel profile：`{result['profile']['kernel_profile']}`",
                  f"- warmup 指令数：`{result['profile']['warmup_instructions']}`",
                  f"- 校验：`{'PASS' if result['validation']['passed'] else 'FAIL'}`", ""])
    return "\n".join(lines)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True)
    parser.add_argument("--elf", type=Path, required=True)
    parser.add_argument("--trace", type=Path, required=True)
    parser.add_argument("--objdump", required=True)
    parser.add_argument("--out-json", type=Path, required=True)
    parser.add_argument("--out-md", type=Path, required=True)
    parser.add_argument("--rtl-retired", type=int)
    parser.add_argument("--rtl-retired-tolerance", type=int, default=0)
    parser.add_argument("--kernel-profile", choices=("quick", "full"))
    parser.add_argument("--warmup-instructions", type=int)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.rtl_retired_tolerance < 0:
        raise SystemExit("--rtl-retired-tolerance must be non-negative")
    result = analyze(
        args.case,
        args.elf,
        args.trace,
        args.objdump,
        args.rtl_retired,
        args.rtl_retired_tolerance,
        args.kernel_profile,
        args.warmup_instructions,
    )
    args.out_json.parent.mkdir(parents=True, exist_ok=True)
    args.out_md.parent.mkdir(parents=True, exist_ok=True)
    args.out_json.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
    args.out_md.write_text(kernel_summary(result))
    print(json.dumps({
        "case": args.case,
        "instructions": result["execution"]["dynamic_instructions"],
        "memory_accesses": result["memory"]["accesses"],
        "validation": result["validation"]["passed"],
    }, ensure_ascii=False))
    return 0 if result["validation"]["passed"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
