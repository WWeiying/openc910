#!/usr/bin/env python3
import argparse
import bisect
import collections
import csv
import subprocess
from pathlib import Path


CODE_SYMBOL_TYPES = {"T", "t", "W", "w", "I", "i"}
UNRESOLVED_SYMBOLS = {"[unknown]", "[external-or-unknown]", "[no-symbols]"}


def load_symbols(elf, nm):
    out = subprocess.check_output(
        [nm, "-n", "-S", str(elf)], text=True, stderr=subprocess.DEVNULL
    )
    if not any(
        line.split()[2:3] and line.split()[2] in CODE_SYMBOL_TYPES
        for line in out.splitlines()
    ):
        out = subprocess.check_output(
            [nm, "-D", "-n", "-S", str(elf)], text=True, stderr=subprocess.DEVNULL
        )
    symbols = []
    for line in out.splitlines():
        parts = line.split()
        if len(parts) < 3:
            continue
        if len(parts) >= 4:
            addr_s, size_s, typ, name = parts[0], parts[1], parts[2], parts[3]
        else:
            addr_s, size_s, typ, name = parts[0], None, parts[1], parts[2]
        if typ not in CODE_SYMBOL_TYPES:
            continue
        try:
            addr = int(addr_s, 16)
            size = int(size_s, 16) if size_s else 0
        except ValueError:
            continue
        end = addr + size if size > 0 else None
        symbols.append((addr, end, name))
    symbols.sort()
    return symbols


def symbol_addrs(symbols):
    return [addr for addr, _, _ in symbols]


def symbol_for_pc(symbols, addrs, pc):
    if not symbols:
        return "[no-symbols]"
    idx = bisect.bisect_right(addrs, pc) - 1
    if idx < 0:
        return "[unknown]"
    addr, end, name = symbols[idx]
    if end is not None:
        if pc >= end:
            return "[external-or-unknown]"
    elif idx + 1 < len(symbols) and pc >= symbols[idx + 1][0]:
        return "[unknown]"
    elif idx + 1 >= len(symbols):
        return "[external-or-unknown]"
    return name


def load_cmdmap(path):
    ranges = []
    with open(path) as f:
        header = f.readline()
        for line in f:
            parts = line.rstrip("\n").split("\t", 4)
            if len(parts) < 4:
                continue
            try:
                start = int(parts[1], 10)
                end = int(parts[2], 10)
            except ValueError:
                continue
            ranges.append((start, end, parts[3]))
    return ranges


def command_for_block(cmd_ranges, bid):
    for cmd_index, (start, end, elf) in enumerate(cmd_ranges):
        if start <= bid <= end:
            return cmd_index, elf
    return None, None


def load_modules(path):
    modules = collections.defaultdict(list)
    if not path:
        return modules
    with open(path) as stream:
        next(stream, None)
        for line in stream:
            parts = line.rstrip("\n").split("\t", 4)
            if len(parts) < 4:
                continue
            cmd_index = int(parts[0], 10)
            base = int(parts[1], 16)
            end = int(parts[2], 16)
            modules[cmd_index].append((base, end, parts[3]))
    return modules


def load_map(path, default_symbols, nm, cmdmap=None, module_map=None):
    block_to_func = {}
    block_to_pc = {}
    cmd_ranges = load_cmdmap(cmdmap) if cmdmap else []
    modules = load_modules(module_map)
    default_addrs = symbol_addrs(default_symbols)
    symbol_cache = {}
    with open(path, newline="") as f:
        for line in f:
            parts = line.split()
            if len(parts) < 3:
                continue
            bid = int(parts[0], 10)
            if bid in block_to_func:
                continue
            pc = int(parts[1], 16)
            block_to_pc[bid] = pc
            cmd_index, elf = command_for_block(cmd_ranges, bid)
            module = next(
                (
                    (base, module_elf)
                    for base, end, module_elf in modules.get(cmd_index, [])
                    if base <= pc < end
                ),
                None,
            )
            if module:
                base, module_elf = module
                if module_elf not in symbol_cache:
                    symbols = load_symbols(Path(module_elf), nm)
                    symbol_cache[module_elf] = (symbols, symbol_addrs(symbols))
                symbols, addrs = symbol_cache[module_elf]
                function = symbol_for_pc(symbols, addrs, pc - base)
                if function in UNRESOLVED_SYMBOLS:
                    function = f"[module:{Path(module_elf).name}:unresolved]"
                block_to_func[bid] = function
                continue
            if elf:
                if elf not in symbol_cache:
                    symbols = load_symbols(Path(elf), nm)
                    symbol_cache[elf] = (symbols, symbol_addrs(symbols))
                symbols, addrs = symbol_cache[elf]
                block_to_func[bid] = symbol_for_pc(symbols, addrs, pc)
            else:
                block_to_func[bid] = symbol_for_pc(default_symbols, default_addrs, pc)
    return block_to_func, block_to_pc


def parse_bbv_line(line):
    counts = {}
    line = line.strip()
    if not line or not line.startswith("T"):
        return counts
    for token in line[1:].split():
        if not token.startswith(":"):
            continue
        fields = token[1:].split(":")
        if len(fields) != 2:
            continue
        counts[int(fields[0])] = int(fields[1])
    return counts


def load_simpoints(path):
    mapping = {}
    with open(path) as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 2:
                interval = int(parts[0])
                cluster = int(parts[1])
                mapping[cluster] = interval
    return mapping


def load_weights(path):
    weights = {}
    with open(path) as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 2:
                weight = float(parts[0])
                cluster = int(parts[1])
                weights[cluster] = weight
    return weights


def aggregate_function_counts(interval_counts, block_to_func):
    total = collections.Counter()
    for bid, count in interval_counts.items():
        total[block_to_func.get(bid, "[unknown]")] += count
    return total


def stream_function_counts(path, block_to_func, selected_intervals):
    global_counts = collections.Counter()
    selected_counts = {}
    interval_count = 0
    with open(path) as stream:
        for line in stream:
            if not line.strip():
                continue
            block_counts = parse_bbv_line(line)
            function_counts = aggregate_function_counts(block_counts, block_to_func)
            global_counts.update(function_counts)
            if interval_count in selected_intervals:
                selected_counts[interval_count] = function_counts
            interval_count += 1
    return interval_count, global_counts, selected_counts


def write_profile_csv(path, rows):
    with open(path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["scope", "interval", "cluster", "weight", "function", "count", "percent"])
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bbv", required=True)
    parser.add_argument("--map", required=True)
    parser.add_argument("--elf", required=True)
    parser.add_argument("--cmdmap")
    parser.add_argument("--modules")
    parser.add_argument("--simpoints", required=True)
    parser.add_argument("--weights", required=True)
    parser.add_argument("--nm", default="riscv64-unknown-linux-gnu-nm")
    parser.add_argument("--top", type=int, default=12)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    symbols = load_symbols(Path(args.elf), args.nm)
    block_to_func, _ = load_map(
        Path(args.map), symbols, args.nm, args.cmdmap, args.modules
    )
    simpoints = load_simpoints(Path(args.simpoints))
    weights = load_weights(Path(args.weights))
    interval_count, global_counts, selected_counts = stream_function_counts(
        Path(args.bbv), block_to_func, set(simpoints.values())
    )

    rows = []

    global_total = sum(global_counts.values())
    for func, count in global_counts.most_common(args.top):
        pct = 100.0 * count / global_total if global_total else 0.0
        rows.append(["global", "", "", "", func, count, f"{pct:.4f}"])

    for cluster in sorted(simpoints):
        interval_no = simpoints[cluster]
        weight = weights.get(cluster, 0.0)
        if interval_no < 0 or interval_no >= interval_count:
            continue
        func_counts = selected_counts.get(interval_no, collections.Counter())
        total = sum(func_counts.values())
        for func, count in func_counts.most_common(args.top):
            pct = 100.0 * count / total if total else 0.0
            rows.append(["simpoint", interval_no, cluster, f"{weight:.7f}", func, count, f"{pct:.4f}"])

    write_profile_csv(Path(args.out), rows)

    print(f"[profile] intervals={interval_count} blocks={len(block_to_func)}")
    print(f"[profile] wrote {args.out}")
    print("[profile] global top functions:")
    for row in rows:
        if row[0] == "global":
            print(f"  {row[4]:28s} {row[6]:>9s}% {row[5]}")
    print("[profile] simpoints:")
    for cluster in sorted(simpoints):
        print(f"  cluster={cluster} interval={simpoints[cluster]} weight={weights.get(cluster, 0.0):.7f}")


if __name__ == "__main__":
    main()
