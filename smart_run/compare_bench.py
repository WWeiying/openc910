#!/usr/bin/env python3
"""
compare_bench.py - compare two benchmark run results and print a diff table

Usage:
    python compare_bench.py <baseline_tag> <modified_tag>

Example:
    python compare_bench.py baseline modified

Each tag must have a corresponding results/<tag>/ directory produced by run_bench.sh.
"""

import sys
import os
import re
import math

# ---------------------------------------------------------------------------
# Metric definitions: (display_name, regex_pattern)
# ---------------------------------------------------------------------------
METRICS = [
    # --- IPC / Cycles ---
    ("Main_IPC",       r"\|\s*Main\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*[\d.]+\s*\|\s*([\d.]+)\s*\|"),
    ("Kernel_IPC",     r"\|\s*Kernel\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*[\d.nan-]+\s*\|\s*([\d.]+)\s*\|"),
    ("Main_Cycles",    r"\|\s*Main\s*\|\s*([\d]+)\s*\|"),
    ("Main_Insts",     r"\|\s*Main\s*\|\s*[\d]+\s*\|\s*([\d]+)\s*\|"),
    # --- Instruction mix (Main window) ---
    ("ALU%",           r"\|\s*ALU\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    ("FP%",            r"\|\s*Float Point\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    ("LDST%",          r"\|\s*LDST\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    ("CondBr%",        r"\|\s*Cond Branch\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    # --- Cache miss rates ---
    ("L1I_miss%",      r"\|\s*L1I Miss\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    ("L1D_Ld_miss%",   r"\|\s*L1D Load Miss\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    ("L1D_St_miss%",   r"\|\s*L1D Store Miss\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    # --- Branch misprediction rates ---
    ("CondBr_misp%",   r"\|\s*Cond Branch Misp\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    ("IndirBr_misp%",  r"\|\s*Indir Branch Misp\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    # --- Stall rates ---
    ("Frontend_stall%",r"\|\s*Frontend Stall\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
    ("Backend_stall%", r"\|\s*Backend Stall\s*\|\s*[\d]+\s*\|\s*[\d]+\s*\|\s*([\d.]+)%"),
]


def parse_perf(filepath):
    """Parse a .perf file and return dict of metric -> float."""
    try:
        with open(filepath) as f:
            text = f.read()
    except FileNotFoundError:
        return {}

    result = {}
    for name, pattern in METRICS:
        m = re.search(pattern, text)
        if m:
            try:
                result[name] = float(m.group(1))
            except ValueError:
                pass
    return result


def delta_str(base, mod):
    """Return formatted delta string with sign and percent change."""
    if base == 0:
        return f"{'N/A':>10}"
    d = mod - base
    pct = d / base * 100.0
    sign = "+" if d >= 0 else ""
    return f"{sign}{pct:+.1f}%"


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)

    base_tag, mod_tag = sys.argv[1], sys.argv[2]
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.join(script_dir, "results", base_tag)
    mod_dir  = os.path.join(script_dir, "results", mod_tag)

    report_path = os.path.join(script_dir, "results",
                               f"{base_tag}_vs_{mod_tag}.txt")
    report_file = open(report_path, "w")

    def emit(line=""):
        print(line)
        report_file.write(line + "\n")

    cases = sorted(
        {os.path.splitext(f)[0] for f in os.listdir(base_dir) if f.endswith(".perf")}
        | {os.path.splitext(f)[0] for f in os.listdir(mod_dir)  if f.endswith(".perf")}
    )

    # -----------------------------------------------------------------------
    # Print summary table: IPC comparison
    # -----------------------------------------------------------------------
    emit(f"\n{'='*76}")
    emit(f"  Benchmark comparison:  baseline={base_tag}   modified={mod_tag}")
    emit(f"{'='*76}")
    emit(f"{'Case':<16} {'Base_IPC':>10} {'Mod_IPC':>10} {'IPC_chg':>10}  "
         f"{'Base_FE%':>9} {'Mod_FE%':>9}  {'Base_BE%':>9} {'Mod_BE%':>9}")
    emit(f"{'-'*16} {'-'*10} {'-'*10} {'-'*10}  {'-'*9} {'-'*9}  {'-'*9} {'-'*9}")

    geo_base_ipcs = []
    geo_mod_ipcs  = []

    for case in cases:
        base = parse_perf(os.path.join(base_dir, f"{case}.perf"))
        mod  = parse_perf(os.path.join(mod_dir,  f"{case}.perf"))

        b_ipc = base.get("Main_IPC", float("nan"))
        m_ipc = mod.get("Main_IPC",  float("nan"))
        b_fe  = base.get("Frontend_stall%", float("nan"))
        m_fe  = mod.get("Frontend_stall%",  float("nan"))
        b_be  = base.get("Backend_stall%",  float("nan"))
        m_be  = mod.get("Backend_stall%",   float("nan"))

        ipc_chg = delta_str(b_ipc, m_ipc) if (b_ipc == b_ipc and m_ipc == m_ipc) else "N/A"

        emit(f"{case:<16} {b_ipc:>10.3f} {m_ipc:>10.3f} {ipc_chg:>10}  "
             f"{b_fe:>8.1f}% {m_fe:>8.1f}%  {b_be:>8.1f}% {m_be:>8.1f}%")

        if b_ipc > 0 and m_ipc > 0:
            geo_base_ipcs.append(b_ipc)
            geo_mod_ipcs.append(m_ipc)

    # geomean row
    if geo_base_ipcs:
        geo_b = math.exp(sum(math.log(v) for v in geo_base_ipcs) / len(geo_base_ipcs))
        geo_m = math.exp(sum(math.log(v) for v in geo_mod_ipcs)  / len(geo_mod_ipcs))
        geo_chg = delta_str(geo_b, geo_m)
        emit(f"{'-'*16} {'-'*10} {'-'*10} {'-'*10}  {'-'*9} {'-'*9}  {'-'*9} {'-'*9}")
        emit(f"{'GEOMEAN':<16} {geo_b:>10.3f} {geo_m:>10.3f} {geo_chg:>10}")

    # -----------------------------------------------------------------------
    # Print detailed metric table per case
    # -----------------------------------------------------------------------
    emit(f"\n{'='*76}")
    emit("  Detailed metrics (base -> mod, delta%)")
    emit(f"{'='*76}")

    metric_names = [n for n, _ in METRICS]
    for case in cases:
        base = parse_perf(os.path.join(base_dir, f"{case}.perf"))
        mod  = parse_perf(os.path.join(mod_dir,  f"{case}.perf"))
        if not base and not mod:
            continue

        emit(f"\n  [{case}]")
        for name in metric_names:
            bv = base.get(name)
            mv = mod.get(name)
            if bv is None and mv is None:
                continue
            bv = bv or 0.0
            mv = mv or 0.0
            chg = delta_str(bv, mv)
            emit(f"    {name:<20} {bv:>10.3f}  ->  {mv:>10.3f}   {chg}")

    emit()
    report_file.close()
    print(f"\n[report saved to {report_path}]")


if __name__ == "__main__":
    main()
