#!/usr/bin/env python3
"""Summarize retired branch-PC hotspot records from PERF_DETAIL runs."""

from __future__ import annotations

import argparse
import bisect
import csv
import re
import sys
from pathlib import Path


KEY_VALUE_RE = re.compile(r"([a-z_]+)=([^\s]+)")
LABEL_RE = re.compile(r"^([0-9a-fA-F]+) <(.+)>:$")
INST_RE = re.compile(r"^\s*([0-9a-fA-F]+):\s+[0-9a-fA-F]+\s+(.+?)\s*$")
COND_MNEMONICS = {
    "beq", "bne", "blt", "bge", "bltu", "bgeu",
    "beqz", "bnez", "blez", "bgez", "bltz", "bgtz",
    "ble", "bgt", "bleu", "bgtu",
}
JMP_MNEMONICS = {"j", "jr", "jal", "jalr", "ret", "call", "tail"}


def discover_files(inputs: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in inputs:
        path = Path(raw)
        if path.is_dir():
            files.extend(sorted(path.glob("*.branch_pc.perf")))
        elif path.is_file():
            files.append(path)
        else:
            raise FileNotFoundError(path)
    return sorted(set(files))


def case_name(path: Path) -> str:
    suffix = ".branch_pc.perf"
    return path.name[:-len(suffix)] if path.name.endswith(suffix) else path.stem


def parse_key_values(line: str) -> dict[str, str]:
    return dict(KEY_VALUE_RE.findall(line))


def parse_hotspots(path: Path) -> tuple[list[dict[str, object]], dict[tuple[str, str], int]]:
    rows: list[dict[str, object]] = []
    totals: dict[tuple[str, str], int] = {}
    case = case_name(path)
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        values = parse_key_values(line)
        if line.startswith("BRANCH_PC_TOTAL "):
            totals[(values["phase"], values["kind"])] = int(values["mispred"])
        elif line.startswith("BRANCH_PC "):
            rows.append({
                "case": case,
                "_source": path.parent,
                "phase": values["phase"],
                "kind": values["kind"],
                "pc": int(values["pc"], 16),
                "exec": int(values["exec"]),
                "mispred": int(values["mispred"]),
                "rate_pct": float(values["rate_pct"]),
                "call_misp": int(values["call_misp"]),
                "return_misp": int(values["return_misp"]),
                "other_misp": int(values["other_misp"]),
            })
    return rows, totals


def parse_asm(path: Path) -> tuple[list[int], list[str], dict[int, str]]:
    if not path.is_file():
        return [], [], {}
    label_addrs: list[int] = []
    label_names: list[str] = []
    instructions: dict[int, str] = {}
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        label = LABEL_RE.match(line)
        if label:
            label_addrs.append(int(label.group(1), 16))
            label_names.append(label.group(2))
            continue
        instruction = INST_RE.match(line)
        if instruction:
            instructions[int(instruction.group(1), 16)] = instruction.group(2)
    return label_addrs, label_names, instructions


def annotate(rows: list[dict[str, object]]) -> None:
    asm_by_case: dict[tuple[Path, str], tuple[list[int], list[str], dict[int, str]]] = {}
    for row in rows:
        case = str(row["case"])
        source = Path(row["_source"])
        key = (source, case)
        if key not in asm_by_case:
            asm_by_case[key] = parse_asm(source / f"{case}.asm")
        addresses, names, instructions = asm_by_case[key]
        pc = int(row["pc"])
        index = bisect.bisect_right(addresses, pc) - 1
        row["function"] = names[index] if index >= 0 else "?"
        row["instruction"] = instructions.get(pc, "?")


def select_rows(rows: list[dict[str, object]], phase: str, kind: str,
                top: int) -> list[dict[str, object]]:
    selected = [
        row for row in rows
        if row["phase"] == phase and (kind == "all" or row["kind"] == kind)
    ]
    selected.sort(key=lambda row: (
        str(row["case"]), str(row["kind"]),
        -int(row["mispred"]), -float(row["rate_pct"]), int(row["pc"])
    ))
    result: list[dict[str, object]] = []
    group_count: dict[tuple[str, str], int] = {}
    for row in selected:
        group = (str(row["case"]), str(row["kind"]))
        if group_count.get(group, 0) < top:
            result.append(row)
            group_count[group] = group_count.get(group, 0) + 1
    return result


def annotation_errors(rows: list[dict[str, object]]) -> list[str]:
    errors: list[str] = []
    for row in rows:
        instruction = str(row["instruction"])
        mnemonic = instruction.split(None, 1)[0] if instruction != "?" else "?"
        expected = COND_MNEMONICS if row["kind"] == "cond" else JMP_MNEMONICS
        if mnemonic not in expected:
            errors.append(
                f"{row['case']} {row['phase']} {row['kind']} "
                f"0x{int(row['pc']):010x}: expected branch instruction, got {instruction!r}"
            )
    return errors


def print_markdown(rows: list[dict[str, object]], totals: dict[tuple[str, str, str], int]) -> None:
    print("| Case | Kind | PC | Function | Instruction | Exec | Mispred | Miss % | Error share % | Jump class |")
    print("|---|---|---:|---|---|---:|---:|---:|---:|---|")
    for row in rows:
        key = (str(row["case"]), str(row["phase"]), str(row["kind"]))
        total = totals.get(key, 0)
        share = 100.0 * int(row["mispred"]) / total if total else 0.0
        jump_class = "-"
        if row["kind"] == "jmp":
            jump_class = (f"call={row['call_misp']}, return={row['return_misp']}, "
                          f"other={row['other_misp']}")
        instruction = str(row["instruction"]).replace("|", "\\|")
        print(
            f"| {row['case']} | {row['kind']} | 0x{int(row['pc']):010x} | "
            f"{row['function']} | `{instruction}` | {row['exec']} | "
            f"{row['mispred']} | {float(row['rate_pct']):.4f} | {share:.2f} | "
            f"{jump_class} |"
        )


def print_csv(rows: list[dict[str, object]], totals: dict[tuple[str, str, str], int]) -> None:
    fieldnames = [
        "case", "phase", "kind", "pc", "function", "instruction", "exec",
        "mispred", "rate_pct", "error_share_pct", "call_misp", "return_misp",
        "other_misp",
    ]
    writer = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
    writer.writeheader()
    for row in rows:
        output = dict(row)
        key = (str(row["case"]), str(row["phase"]), str(row["kind"]))
        total = totals.get(key, 0)
        output["pc"] = f"0x{int(row['pc']):010x}"
        output["error_share_pct"] = (
            100.0 * int(row["mispred"]) / total if total else 0.0
        )
        writer.writerow({name: output[name] for name in fieldnames})


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Sort branch misprediction PCs and annotate them from archived disassembly."
    )
    parser.add_argument("inputs", nargs="+", help=".branch_pc.perf file or result directory")
    parser.add_argument("--phase", choices=("Main", "Kernel"), default="Kernel")
    parser.add_argument("--kind", choices=("all", "cond", "jmp"), default="all")
    parser.add_argument("--top", type=int, default=20, help="rows per case and branch kind")
    parser.add_argument("--format", choices=("markdown", "csv"), default="markdown")
    parser.add_argument(
        "--strict", action="store_true",
        help="fail if a recorded PC does not disassemble as the expected branch kind",
    )
    args = parser.parse_args()
    if args.top <= 0:
        parser.error("--top must be positive")

    files = discover_files(args.inputs)
    if not files:
        parser.error("no .branch_pc.perf files found")

    rows: list[dict[str, object]] = []
    totals: dict[tuple[str, str, str], int] = {}
    for path in files:
        parsed_rows, parsed_totals = parse_hotspots(path)
        case = case_name(path)
        rows.extend(parsed_rows)
        for (phase, kind), count in parsed_totals.items():
            totals[(case, phase, kind)] = count

    annotate(rows)
    errors = annotation_errors(rows)
    for error in errors:
        print(f"WARN: {error}", file=sys.stderr)
    if errors and args.strict:
        return 2
    selected = select_rows(rows, args.phase, args.kind, args.top)
    if args.format == "csv":
        print_csv(selected, totals)
    else:
        print_markdown(selected, totals)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
