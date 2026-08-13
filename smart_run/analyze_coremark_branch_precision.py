#!/usr/bin/env python3
"""Analyze C910 CoreMark branch behavior from an exported full-cycle FSDB table.

The analyzer intentionally keeps three statistical layers separate:

* architectural retirement counts for rates and MPKI;
* execution-level BJU observations for mechanism decomposition;
* PCGEN redirect transactions for frontend and recovery latency.

It never uses execution-level observations as an architectural denominator.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

import numpy as np
import pandas as pd


PRIORITY = [
    ("HAD", "ifu_redirect_had"),
    ("Vector", "ifu_redirect_vector"),
    ("RTU", "ifu_redirect_rtu"),
    ("BJU", "iu_cancel"),
    ("Addrgen", "ifu_redirect_addrgen"),
    ("IB", "ifu_redirect_ib_raw"),
    ("IP reissue", "ifu_redirect_ip_reissue"),
    ("IP", "ifu_redirect_ip"),
    ("IF reissue", "ifu_redirect_if_reissue"),
    ("L0 BTB", "ifu_redirect_l0"),
]
BRANCH_SOURCES = {"BJU", "Addrgen", "IB", "IP", "L0 BTB"}

REQUIRED_COLUMNS = {
    "cycle", "retired_instructions",
    "retire0", "retire1", "retire2",
    "rtu_retire0_condbr", "rtu_retire1_condbr", "rtu_retire2_condbr",
    "rtu_retire0_condbr_taken_raw", "rtu_retire1_condbr_taken_raw",
    "rtu_retire2_condbr_taken_raw", "rtu_retired_mispred",
    "rtu_retire0_bht_mispred_raw", "rtu_retire0_jump_mispred_raw",
    "rtu_retire0_return_raw", "rtu_retire0_return",
    "rtu_retire0_jump_nonreturn", "rtu_retire1_jump", "rtu_retire2_jump",
    "rtu_retire0_changeflow",
    "rtu_retire1_changeflow", "rtu_retire2_changeflow",
    "rtu_retire0_iid", "rtu_retire0_pc_halfword",
    "branch_ex1_valid", "branch_iid_oldest", "branch_ex1_iid",
    "branch_ex1_pid", "branch_conditional", "branch_unconditional",
    "branch_jump", "branch_call", "branch_return", "branch_taken",
    "branch_bht_pred_taken", "branch_direction_mispred",
    "branch_jump_mispred", "branch_target_mispred",
    "branch_pcfifo_jump_mispred", "branch_page_fault",
    "branch_jump_page_fault", "branch_actual_target_pc_halfword",
    "branch_ex1_mispred", "branch_ex1_change_flow",
    "branch_ex2_valid", "branch_ex2_change_flow",
    "branch_recovery_bht_mispred", "branch_recovery_jump_mispred",
    "branch_recovery_call", "branch_recovery_return",
    "branch_recovery_iid", "branch_recovery_pid",
    "branch_recovery_target_pc_halfword", "branch_recovery_pc_halfword",
    "ifu_pcgen_change_flow", "ifu_redirect_had", "ifu_redirect_vector",
    "ifu_redirect_rtu", "iu_cancel", "ifu_redirect_addrgen",
    "ifu_redirect_ib_raw", "ifu_redirect_ib_valid",
    "ifu_redirect_ip_reissue", "ifu_redirect_ip", "ifu_redirect_ip_stall",
    "ifu_redirect_if_reissue", "ifu_redirect_l0",
    "ifu_l0_redirect_is_ras", "ifu_addrgen_redirect_target_halfword",
    "ifu_ib_redirect_target_halfword", "ifu_ip_redirect_target_halfword",
    "ifu_l0_redirect_target_halfword", "ifu_ib_lbuf_redirect",
    "ifu_ib_ras_redirect", "ifu_ib_ras_mask", "ifu_ib_indirect_redirect",
    "ifu_ib_indirect_target_valid", "ifu_ib_l0_ras_correction",
    "ifu_ip_branch_mistaken", "ifu_ip_branch_taken",
    "ifu_ip_l0_btb_miss_current", "ifu_ip_l0_btb_mispred_current",
    "ifu_fetch_pc_halfword", "ifu_if_valid", "ifu_ip_vpc_halfword",
    "ifu_l0_lookup_pc_halfword", "ifu_idu_valid0", "ifu_idu_valid1",
    "ifu_idu_valid2", "ifu_idu_pc0_low_halfword",
    "ifu_idu_pc1_low_halfword", "ifu_idu_pc2_low_halfword",
    "idu_ifu_stall", "rtu_flush_frontend", "rob_create0", "rob_create1",
    "rob_create2", "rob_create3", "global_flush", "bju_mispred_stall",
    "bju_ifu_mispred_stall", "head_valid", "head_completed",
    "load_da_valid", "load_dcache_miss", "div_busy",
    "lsu_rb_valid_bitmap", "ifu_multi_branch_stall",
    "ifu_branch_misaligned_stall", "ifu_ind_btb_stall",
    "ifu_ind_btb_fifo_stall", "ifu_pcfifo_full_stall",
    "icache_way_mispred_reissue", "ifu_l0_btb_hit_raw",
    "ifu_l0_btb_miss_raw", "ifu_l0_btb_mispred_raw",
    "ifu_ip_pipeline_stall", "ifu_ind_btb_check_valid",
    "ifu_ind_btb_miss_raw", "ras_redirect", "ras_mistaken",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("result_dir", type=Path)
    parser.add_argument("--signals", type=Path)
    parser.add_argument(
        "--supplement", type=Path,
        help="optional CSV containing newly exported columns, joined by cycle",
    )
    parser.add_argument("--output-dir", type=Path)
    return parser.parse_args()


def parse_coremark_roi(asm_path: Path, trace_path: Path, log_path: Path) -> dict:
    log_text = log_path.read_text(errors="replace")
    match = re.search(r"CoreMark has been run .*?cost\s+(\d+)\s+cycles", log_text)
    if not match:
        raise ValueError(f"cannot find CoreMark cycle count in {log_path}")
    reported_cycles = int(match.group(1))

    asm_lines = asm_path.read_text(errors="replace").splitlines()
    in_timer = False
    timer_pc = None
    for line in asm_lines:
        if re.search(r"<get_vtimer>:\s*$", line):
            in_timer = True
            continue
        if in_timer and re.search(r"<[^>]+>:\s*$", line):
            break
        if in_timer and "rdtime" in line:
            address = re.match(r"\s*([0-9a-fA-F]+):", line)
            if address:
                timer_pc = int(address.group(1), 16)
                break
    if timer_pc is None:
        raise ValueError(f"cannot find rdtime inside get_vtimer in {asm_path}")

    retire_cycles = []
    trace_re = re.compile(r"slot\d+@\s*(\d+):([0-9a-fA-F]+)\s*$")
    with trace_path.open(errors="replace") as trace:
        for line in trace:
            parsed = trace_re.search(line)
            if parsed and int(parsed.group(2), 16) == timer_pc:
                retire_cycles.append(int(parsed.group(1)))

    candidates = [
        (start, stop) for start, stop in zip(retire_cycles, retire_cycles[1:])
        if stop - start == reported_cycles
    ]
    if len(candidates) != 1:
        raise ValueError(
            "expected exactly one rdtime retirement pair matching the reported "
            f"{reported_cycles} cycles; found {candidates} from {retire_cycles}"
        )
    start, stop = candidates[0]
    return {
        "method": "retired rdtime PC pair matched to simulator CoreMark cycles",
        "rdtime_pc_byte": timer_pc,
        "start_cycle_inclusive": start,
        "stop_cycle_exclusive": stop,
        "cycles": stop - start,
        "simulator_reported_cycles": reported_cycles,
    }


def numeric_frame(path: Path, supplement: Path | None = None) -> pd.DataFrame:
    header = set(pd.read_csv(path, nrows=0).columns)
    supplement_header = (
        set(pd.read_csv(supplement, nrows=0).columns) if supplement else set()
    )
    missing = sorted(REQUIRED_COLUMNS - header - supplement_header)
    if missing:
        raise ValueError(f"missing {len(missing)} required columns: {missing}")
    join_key = "sample_index" if "sample_index" in header & supplement_header else "cycle"
    base_columns = sorted((REQUIRED_COLUMNS & header) | {join_key})
    frame = pd.read_csv(path, usecols=base_columns, low_memory=False)
    if supplement:
        added_columns = sorted((REQUIRED_COLUMNS - header) & supplement_header)
        extra = pd.read_csv(
            supplement, usecols=[join_key, *added_columns], low_memory=False
        )
        if frame[join_key].duplicated().any() or extra[join_key].duplicated().any():
            raise ValueError(f"cannot join supplemental signals: duplicate {join_key} values")
        frame = frame.merge(extra, on=join_key, how="left", validate="one_to_one")
    return frame.apply(pd.to_numeric, errors="coerce")


def flag(frame: pd.DataFrame, name: str) -> pd.Series:
    return frame[name].eq(1)


def count(mask: pd.Series | np.ndarray) -> int:
    return int(np.count_nonzero(np.asarray(mask, dtype=bool)))


def bit(frame: pd.DataFrame, position: int, name: str) -> bool:
    return frame[name].iat[position] == 1


def percentile_higher(values: pd.Series | list[float], q: float) -> float:
    clean = pd.to_numeric(pd.Series(values), errors="coerce").dropna().to_numpy()
    if not len(clean):
        return float("nan")
    return float(np.quantile(clean, q, method="higher"))


def latency_stats(values: pd.Series) -> dict:
    clean = pd.to_numeric(values, errors="coerce").dropna()
    if clean.empty:
        return {"observed": 0, "mean": np.nan, "median": np.nan,
                "p90_higher": np.nan, "max": np.nan}
    return {
        "observed": int(len(clean)),
        "mean": float(clean.mean()),
        "median": float(clean.median()),
        "p90_higher": percentile_higher(clean, 0.9),
        "max": float(clean.max()),
    }


def assert_binary_known(frame: pd.DataFrame, names: list[str], gate: pd.Series) -> None:
    for name in names:
        active = frame.loc[gate, name]
        if active.isna().any():
            raise ValueError(f"{name} contains X/Z/missing samples under its valid gate")
        invalid = ~active.isin([0, 1])
        if invalid.any():
            raise ValueError(f"{name} is non-binary under its valid gate")


def assert_known(frame: pd.DataFrame, names: list[str], gate: pd.Series) -> None:
    for name in names:
        if frame.loc[gate, name].isna().any():
            raise ValueError(f"{name} contains X/Z/missing samples under its valid gate")


def select_roi(frame: pd.DataFrame, roi: dict) -> pd.DataFrame:
    start = roi["start_cycle_inclusive"]
    stop = roi["stop_cycle_exclusive"]
    selected = frame.loc[(frame.cycle >= start) & (frame.cycle < stop)].copy()
    selected.sort_values("cycle", inplace=True)
    selected.reset_index(drop=True, inplace=True)
    expected = np.arange(start, stop, dtype=np.int64)
    observed = selected.cycle.to_numpy(dtype=np.int64)
    if not np.array_equal(observed, expected):
        raise ValueError("ROI is not exactly one FSDB sample per core cycle")
    return selected


def architecture_summary(frame: pd.DataFrame) -> tuple[pd.DataFrame, dict]:
    cond_masks = [flag(frame, f"rtu_retire{slot}_condbr") for slot in range(3)]
    taken_masks = [
        cond_masks[slot] & flag(frame, f"rtu_retire{slot}_condbr_taken_raw")
        for slot in range(3)
    ]
    control_masks = [flag(frame, f"rtu_retire{slot}_changeflow") for slot in range(3)]
    mispred = flag(frame, "rtu_retired_mispred")
    bht_mispred = mispred & flag(frame, "rtu_retire0_bht_mispred_raw")
    jump_mispred = mispred & flag(frame, "rtu_retire0_jump_mispred_raw")
    return_mispred = jump_mispred & flag(frame, "rtu_retire0_return_raw")
    retired_returns = count(flag(frame, "rtu_retire0_return"))
    retired_jumps = (
        retired_returns + count(flag(frame, "rtu_retire0_jump_nonreturn"))
        + count(flag(frame, "rtu_retire1_jump"))
        + count(flag(frame, "rtu_retire2_jump"))
    )
    if count(bht_mispred & jump_mispred):
        raise ValueError("retired BHT and jump misprediction classes overlap")
    if count(bht_mispred | jump_mispred) != count(mispred):
        raise ValueError("retired misprediction type bits do not cover aggregate pulses")

    retired = int(frame.retired_instructions.iloc[-1] - frame.retired_instructions.iloc[0])
    conditional = sum(count(mask) for mask in cond_masks)
    taken = sum(count(mask) for mask in taken_masks)
    control = sum(count(mask) for mask in control_masks)
    direction_wrong = count(bht_mispred)
    total_wrong = count(mispred)
    rows = [
        ("retired_instructions", retired, retired, 100.0),
        ("retired_control_flow", control, retired, 100.0 * control / retired),
        ("retired_conditional_branches", conditional, retired,
         100.0 * conditional / retired),
        ("retired_conditional_taken", taken, conditional,
         100.0 * taken / conditional),
        ("retired_conditional_not_taken", conditional - taken, conditional,
         100.0 * (conditional - taken) / conditional),
        ("retired_direction_mispredictions", direction_wrong, conditional,
         100.0 * direction_wrong / conditional),
        ("retired_jump_or_return_mispredictions", count(jump_mispred),
         retired_jumps, 100.0 * count(jump_mispred) / retired_jumps),
        ("retired_return_target_mispredictions", count(return_mispred),
         retired_returns, 100.0 * count(return_mispred) / retired_returns),
        ("retired_all_mispredictions", total_wrong, retired,
         1000.0 * total_wrong / retired),
    ]
    table = pd.DataFrame(rows, columns=["metric", "events", "denominator", "value"])
    table["unit"] = ["percent", "percent", "percent", "percent", "percent",
                     "percent", "percent", "percent", "MPKI"]
    scalars = {
        "retired_instructions": retired,
        "retired_control_flow": control,
        "retired_conditional_branches": conditional,
        "retired_conditional_taken": taken,
        "retired_direction_mispredictions": direction_wrong,
        "retired_returns": retired_returns,
        "retired_return_target_mispredictions": count(return_mispred),
        "retired_all_mispredictions": total_wrong,
        "direction_accuracy_pct": 100.0 * (conditional - direction_wrong) / conditional,
        "direction_misprediction_pct": 100.0 * direction_wrong / conditional,
        "total_misprediction_mpki": 1000.0 * total_wrong / retired,
    }
    return table, scalars


def execution_summary(frame: pd.DataFrame) -> pd.DataFrame:
    eligible = flag(frame, "branch_ex1_valid") & flag(frame, "branch_iid_oldest")
    conditional = eligible & flag(frame, "branch_conditional")
    actual = frame.branch_taken
    predicted = frame.branch_bht_pred_taken
    direction = conditional & ~flag(frame, "branch_page_fault")
    assert_binary_known(frame, ["branch_taken", "branch_bht_pred_taken"], conditional)
    jump = eligible & flag(frame, "branch_jump")
    rows = [
        ("eligible_control_flow", count(eligible)),
        ("eligible_conditional", count(conditional)),
        ("conditional_correct_nt", count(direction & actual.eq(0) & predicted.eq(0))),
        ("conditional_correct_t", count(direction & actual.eq(1) & predicted.eq(1))),
        ("conditional_nt_to_t", count(direction & actual.eq(1) & predicted.eq(0))),
        ("conditional_t_to_nt", count(direction & actual.eq(0) & predicted.eq(1))),
        ("eligible_jump", count(jump)),
        ("jump_misprediction_candidates",
         count(jump & flag(frame, "branch_jump_mispred")
               & ~flag(frame, "branch_jump_page_fault"))),
        ("eligible_returns", count(jump & flag(frame, "branch_return"))),
        ("return_misprediction_candidates",
         count(jump & flag(frame, "branch_return")
               & flag(frame, "branch_jump_mispred")
               & ~flag(frame, "branch_jump_page_fault"))),
    ]
    result = pd.DataFrame(rows, columns=["execution_level_metric", "events"])
    result["scope"] = "execution-level; never use as a retirement denominator"
    return result


def mux_state(frame: pd.DataFrame) -> tuple[pd.Series, pd.Series, pd.Series]:
    source = pd.Series("", index=frame.index, dtype="object")
    for name, signal in PRIORITY:
        source.loc[source.eq("") & flag(frame, signal)] = name
    selected_cycle = source.ne("") & flag(frame, "ifu_pcgen_change_flow")

    # IB has an explicit one-shot acceptance qualifier. IP has no equivalent;
    # preserve both raw selected cycles and a de-duplicated request stream.
    event = selected_cycle.copy()
    event.loc[source.eq("IB")] &= flag(frame, "ifu_redirect_ib_valid")

    ip = selected_cycle & source.eq("IP")
    ip_key = pd.DataFrame({
        "vpc": frame.ifu_ip_vpc_halfword,
        "target": frame.ifu_ip_redirect_target_halfword,
        "taken": frame.ifu_ip_branch_taken,
        "mistaken": frame.ifu_ip_branch_mistaken,
    })
    same_key = ip_key.eq(ip_key.shift(1)).all(axis=1)
    previous_ip = ip.shift(1, fill_value=False)
    previous_stall = flag(frame, "ifu_redirect_ip_stall").shift(1, fill_value=False)
    current_stall = flag(frame, "ifu_redirect_ip_stall")
    ip_new_request = ip & (
        ~previous_ip | ~same_key | (~current_stall & ~previous_stall)
    )
    event.loc[source.eq("IP")] = ip_new_request.loc[source.eq("IP")]
    return source, selected_cycle, event


def classify_redirect(frame: pd.DataFrame, source: str, position: int) -> tuple[str, float]:
    if source == "L0 BTB":
        subtype = "l0_ras" if bit(frame, position, "ifu_l0_redirect_is_ras") else "l0_btb"
        target = frame.ifu_l0_redirect_target_halfword.iloc[position]
    elif source == "IP":
        if bit(frame, position, "ifu_ip_branch_mistaken"):
            subtype = "ip_correct_l0"
        elif bit(frame, position, "ifu_ip_l0_btb_mispred_current"):
            subtype = "ip_correct_l0_taken_or_target"
        elif bit(frame, position, "ifu_ip_l0_btb_miss_current"):
            subtype = "ip_after_l0_miss"
        else:
            subtype = "ip_main_prediction"
        target = frame.ifu_ip_redirect_target_halfword.iloc[position]
    elif source == "IB":
        if bit(frame, position, "ifu_ib_lbuf_redirect"):
            subtype = "ib_lbuf"
        elif (bit(frame, position, "ifu_ib_ras_redirect")
              and not bit(frame, position, "ifu_ib_ras_mask")):
            subtype = "ib_ras"
        elif bit(frame, position, "ifu_ib_indirect_redirect"):
            subtype = ("ib_indirect_hit" if bit(frame, position, "ifu_ib_indirect_target_valid")
                       else "ib_indirect_miss_default")
        elif bit(frame, position, "ifu_ib_l0_ras_correction"):
            subtype = "ib_correct_l0_ras"
        else:
            subtype = "ib_other"
        target = frame.ifu_ib_redirect_target_halfword.iloc[position]
    elif source == "Addrgen":
        subtype = "addrgen_direct_target_correction"
        target = frame.ifu_addrgen_redirect_target_halfword.iloc[position]
    elif source == "BJU":
        ex1 = position - 1
        if ex1 < 0:
            return "bju_identity_missing", frame.branch_recovery_target_pc_halfword.iloc[position]
        exact = (
            bit(frame, ex1, "branch_ex1_valid")
            and bit(frame, ex1, "branch_ex1_change_flow")
            and frame.branch_ex1_iid.iloc[ex1] == frame.branch_recovery_iid.iloc[position]
            and frame.branch_ex1_pid.iloc[ex1] == frame.branch_recovery_pid.iloc[position]
        )
        if not exact:
            subtype = "bju_identity_mismatch"
        elif (bit(frame, ex1, "branch_conditional")
              and frame.branch_taken.iloc[ex1] != frame.branch_bht_pred_taken.iloc[ex1]
              and not bit(frame, ex1, "branch_page_fault")):
            subtype = "bju_conditional_direction_misprediction"
        elif (bit(frame, ex1, "branch_jump")
              and bit(frame, ex1, "branch_return")
              and bit(frame, ex1, "branch_target_mispred")):
            subtype = "bju_return_target_misprediction"
        elif bit(frame, ex1, "branch_jump") and bit(frame, ex1, "branch_jump_mispred"):
            subtype = "bju_jump_or_indirect_misprediction"
        elif bit(frame, ex1, "branch_page_fault") or bit(frame, ex1, "branch_jump_page_fault"):
            subtype = "bju_target_address_fault"
        else:
            subtype = "bju_other_recovery"
        target = frame.branch_recovery_target_pc_halfword.iloc[position]
    else:
        subtype, target = "not_branch", np.nan
    return subtype, target


def first_position(mask: np.ndarray, start: int, stop: int) -> int | None:
    positions = np.flatnonzero(mask[start:stop])
    return None if not len(positions) else start + int(positions[0])


def first_indexed(positions: np.ndarray, start: int, stop: int) -> int | None:
    at = int(np.searchsorted(positions, start, side="left"))
    if at >= len(positions) or positions[at] >= stop:
        return None
    return int(positions[at])


def index_positions_by_value(values: np.ndarray, valid: np.ndarray) -> dict[int, np.ndarray]:
    result: dict[int, list[int]] = {}
    for position in np.flatnonzero(valid):
        value = values[position]
        if pd.notna(value):
            result.setdefault(int(value), []).append(int(position))
    return {key: np.asarray(positions, dtype=np.int64)
            for key, positions in result.items()}


def build_redirect_events(frame: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame, dict]:
    source, selected_cycles, event = mux_state(frame)
    cycles = frame.cycle.to_numpy(dtype=np.int64)
    fetch = frame.ifu_fetch_pc_halfword.to_numpy()
    if_valid = flag(frame, "ifu_if_valid").to_numpy()
    blocked = (flag(frame, "idu_ifu_stall") | flag(frame, "rtu_flush_frontend")
               | flag(frame, "iu_cancel"))
    accepted_slots = []
    for slot in range(3):
        accepted_slots.append(
            (flag(frame, f"ifu_idu_valid{slot}") & ~blocked).to_numpy()
        )
    accepted_pc = [frame[f"ifu_idu_pc{slot}_low_halfword"].to_numpy() for slot in range(3)]
    create_width = frame[[f"rob_create{slot}" for slot in range(4)]].sum(axis=1).to_numpy()
    accept_width = frame[[f"ifu_idu_valid{slot}" for slot in range(3)]].sum(axis=1)
    accept_width = accept_width.where(~blocked, 0).to_numpy()

    hard_redirect = selected_cycles & ~source.isin(["IP reissue", "IF reissue"])
    hard_positions = np.flatnonzero(hard_redirect.to_numpy())
    event_positions = np.flatnonzero((event & source.isin(BRANCH_SOURCES)).to_numpy())
    target_if_by_pc = index_positions_by_value(fetch, if_valid)
    target_accept_by_pc: dict[int, list[int]] = {}
    for slot in range(3):
        for position in np.flatnonzero(accepted_slots[slot]):
            value = accepted_pc[slot][position]
            if pd.notna(value):
                target_accept_by_pc.setdefault(int(value), []).append(int(position))
    target_accept_by_pc = {
        key: np.asarray(sorted(set(positions)), dtype=np.int64)
        for key, positions in target_accept_by_pc.items()
    }
    any_accept_positions = np.flatnonzero(accept_width > 0)
    any_create_positions = np.flatnonzero(create_width > 0)
    rows = []
    for position in event_positions:
        src = source.iloc[position]
        subtype, target = classify_redirect(frame, src, position)
        hard_at = int(np.searchsorted(hard_positions, position, side="right"))
        later = hard_positions[hard_at:hard_at + 1]
        if src == "BJU":
            # The RTU redirect/flush following a retired misprediction belongs
            # to this recovery and must not censor its target-path resumption.
            bju_later = hard_positions[hard_at:]
            later = bju_later[source.iloc[bju_later].eq("BJU").to_numpy()][:1]
        # A redirect issued in cycle q changes IF on q+1. The target already in
        # IF during q therefore remains attributable to the older event.
        stop = int(later[0] + 1) if len(later) else len(frame)
        target_if = target_accept = first_accept = first_create = None
        if pd.notna(target):
            target_int = int(target)
            target_if = first_indexed(
                target_if_by_pc.get(target_int, np.empty(0, dtype=np.int64)),
                position + 1, stop,
            )
            target_low = target_int & 0x7FFF
            target_accept = first_indexed(
                target_accept_by_pc.get(target_low, np.empty(0, dtype=np.int64)),
                position + 1, stop,
            )
        first_accept = first_indexed(any_accept_positions, position + 1, stop)
        first_create = first_indexed(any_create_positions, position + 1, stop)

        def delay(endpoint: int | None) -> float:
            return np.nan if endpoint is None else float(cycles[endpoint] - cycles[position])

        next_pc_match = (
            position + 1 < len(frame) and pd.notna(target)
            and fetch[position + 1] == int(target)
        )
        rows.append({
            "position": position,
            "cycle": int(cycles[position]),
            "source": src,
            "subtype": subtype,
            "target_halfword": target,
            "next_cycle_pc_matches_target": bool(next_pc_match),
            "to_target_if_valid": delay(target_if),
            "to_exact_target_idu_accept": delay(target_accept),
            "to_first_any_idu_accept_proxy": delay(first_accept),
            "to_first_any_rob_create_proxy": delay(first_create),
        })
    events = pd.DataFrame(rows)

    summaries = []
    if not events.empty:
        for (src, subtype), group in events.groupby(["source", "subtype"], sort=False):
            row = {"source": src, "subtype": subtype, "events": int(len(group))}
            for column in ["to_target_if_valid", "to_exact_target_idu_accept",
                           "to_first_any_idu_accept_proxy", "to_first_any_rob_create_proxy"]:
                row.update({f"{column}_{key}": value
                            for key, value in latency_stats(group[column]).items()})
            summaries.append(row)
    summary = pd.DataFrame(summaries)
    ip_selected = selected_cycles & source.eq("IP")
    ip_event = event & source.eq("IP")
    diagnostics = {
        "pcgen_selected_cycles": int(selected_cycles.sum()),
        "ip_selected_raw_cycles": int(ip_selected.sum()),
        "ip_selected_nonstall_cycles": int((ip_selected & ~flag(frame, "ifu_redirect_ip_stall")).sum()),
        "ip_distinct_request_events": int(ip_event.sum()),
        "branch_redirect_events": int(len(events)),
    }
    return events, summary, diagnostics


def pair_l0_ip(frame: pd.DataFrame, redirect_events: pd.DataFrame) -> pd.DataFrame:
    if redirect_events.empty:
        return pd.DataFrame()
    l0 = redirect_events.loc[redirect_events.source.eq("L0 BTB")].copy()
    ip = redirect_events.loc[redirect_events.subtype.eq("ip_correct_l0")].copy()
    used = set()
    rows = []
    for _, correction in ip.iterrows():
        p = int(correction.position)
        vpc = frame.ifu_ip_vpc_halfword.iloc[p]
        candidates = l0.loc[
            (l0.position < p) & (p - l0.position <= 8) & ~l0.position.isin(used)
        ].copy()
        candidates = candidates.loc[
            candidates.position.map(lambda q: frame.ifu_l0_lookup_pc_halfword.iloc[int(q)] == vpc)
        ]
        if candidates.empty:
            rows.append({"ip_cycle": int(correction.cycle), "matched": False,
                         "l0_cycle": np.nan, "l0_to_ip_cycles": np.nan,
                         "vpc_halfword": vpc})
            continue
        match = candidates.iloc[-1]
        used.add(int(match.position))
        rows.append({"ip_cycle": int(correction.cycle), "matched": True,
                     "l0_cycle": int(match.cycle),
                     "l0_to_ip_cycles": int(correction.cycle - match.cycle),
                     "vpc_halfword": vpc})
    return pd.DataFrame(rows)


def build_bju_events(frame: pd.DataFrame, redirects: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame, dict]:
    cycles = frame.cycle.to_numpy(dtype=np.int64)
    cancel_positions = np.flatnonzero(flag(frame, "iu_cancel").to_numpy())
    retire_positions = np.flatnonzero(flag(frame, "rtu_retired_mispred").to_numpy())
    flush_positions = np.flatnonzero(flag(frame, "global_flush").to_numpy())
    idu_stall_low_positions = np.flatnonzero(
        (~flag(frame, "bju_mispred_stall")).to_numpy()
    )
    ifu_stall_low_positions = np.flatnonzero(
        (~flag(frame, "bju_ifu_mispred_stall")).to_numpy()
    )
    selected_bju = set(
        redirects.loc[redirects.source.eq("BJU"), "position"].astype(int).tolist()
    ) if not redirects.empty else set()
    redirect_by_position = redirects.set_index("position") if not redirects.empty else pd.DataFrame()
    rows = []
    identity_failures = 0
    for position in cancel_positions:
        ex1 = position - 1
        exact = ex1 >= 0 and (
            bit(frame, ex1, "branch_ex1_valid")
            and bit(frame, ex1, "branch_ex1_change_flow")
            and frame.branch_ex1_iid.iloc[ex1] == frame.branch_recovery_iid.iloc[position]
            and frame.branch_ex1_pid.iloc[ex1] == frame.branch_recovery_pid.iloc[position]
        )
        if not exact:
            identity_failures += 1
        subtype = (classify_redirect(frame, "BJU", position)[0]
                   if exact else "bju_identity_mismatch")
        iid = frame.branch_recovery_iid.iloc[position]
        future_flush = flush_positions[flush_positions >= position]
        first_flush = int(future_flush[0]) if len(future_flush) else len(frame) - 1
        candidates = retire_positions[(retire_positions > position) & (retire_positions <= first_flush)]
        retire = None
        for candidate in candidates:
            if pd.notna(iid) and frame.rtu_retire0_iid.iloc[candidate] == iid:
                retire = int(candidate)
                break
        flush = None
        if retire is not None:
            after_retire = flush_positions[flush_positions >= retire]
            if len(after_retire):
                flush = int(after_retire[0])
        stall_clear = first_indexed(
            idu_stall_low_positions, position + 1,
            min((flush + 64) if flush is not None else len(frame), len(frame)),
        )
        ifu_stall_clear = first_indexed(
            ifu_stall_low_positions, position + 1,
            min((flush + 64) if flush is not None else len(frame), len(frame)),
        )
        redirect = (redirect_by_position.loc[position]
                    if position in selected_bju else None)

        def delta(endpoint: int | None) -> float:
            return np.nan if endpoint is None else float(cycles[endpoint] - cycles[position])

        rows.append({
            "position": int(position), "cycle": int(cycles[position]),
            "subtype": subtype, "ex1_ex2_identity_exact": bool(exact),
            "pcgen_selected_bju": position in selected_bju,
            "architecturally_retired_misprediction": retire is not None,
            "cancel_to_target_if_valid": (np.nan if redirect is None
                                           else redirect.to_target_if_valid),
            "cancel_to_exact_target_idu_accept": (
                np.nan if redirect is None else redirect.to_exact_target_idu_accept
            ),
            "cancel_to_retired_misprediction": delta(retire),
            "retired_misprediction_to_flush": (
                np.nan if retire is None or flush is None
                else float(cycles[flush] - cycles[retire])
            ),
            "cancel_to_global_flush": delta(flush),
            "cancel_to_idu_mispred_stall_clear": delta(stall_clear),
            "cancel_to_ifu_state_protect_clear": delta(ifu_stall_clear),
        })
    events = pd.DataFrame(rows)
    summary_rows = []
    if not events.empty:
        paired = events.loc[events.architecturally_retired_misprediction]
        for subtype, group in paired.groupby("subtype", sort=False):
            for metric in ["cancel_to_target_if_valid", "cancel_to_exact_target_idu_accept",
                           "cancel_to_retired_misprediction",
                           "retired_misprediction_to_flush", "cancel_to_global_flush",
                           "cancel_to_idu_mispred_stall_clear",
                           "cancel_to_ifu_state_protect_clear"]:
                summary_rows.append({"subtype": subtype, "metric": metric,
                                     **latency_stats(group[metric])})
    diagnostics = {
        "all_bju_cancel_events": int(len(cancel_positions)),
        "ex1_to_ex2_identity_failures": identity_failures,
        "pcgen_selected_bju_events": int(events.pcgen_selected_bju.sum()) if not events.empty else 0,
        "architecturally_retired_mispredictions_paired": (
            int(events.architecturally_retired_misprediction.sum()) if not events.empty else 0
        ),
    }
    return events, pd.DataFrame(summary_rows), diagnostics


def stall_summary(frame: pd.DataFrame) -> pd.DataFrame:
    signals = [
        ("multi_branch", "ifu_multi_branch_stall"),
        ("boundary_redecode", "ifu_branch_misaligned_stall"),
        ("indirect_btb_read", "ifu_ind_btb_stall"),
        ("ib_fifo_aggregate", "ifu_ind_btb_fifo_stall"),
        ("pcfifo_full", "ifu_pcfifo_full_stall"),
        ("icache_way_reissue", "icache_way_mispred_reissue"),
        ("bju_idu_recovery", "bju_mispred_stall"),
        ("bju_ifu_state_protect", "bju_ifu_mispred_stall"),
    ]
    rows = []
    for label, signal in signals:
        mask = flag(frame, signal).to_numpy()
        transitions = np.diff(np.r_[False, mask, False].astype(np.int8))
        starts = np.flatnonzero(transitions == 1)
        stops = np.flatnonzero(transitions == -1)
        lengths = pd.Series(stops - starts, dtype=float)
        rows.append({"name": label, "signal": signal, "active_cycles": int(mask.sum()),
                     "cycle_pct": 100.0 * mask.sum() / len(frame),
                     "episodes": int(len(lengths)),
                     "episode_mean": lengths.mean() if len(lengths) else np.nan,
                     "episode_median": lengths.median() if len(lengths) else np.nan,
                     "episode_p90_higher": percentile_higher(lengths, 0.9),
                     "episode_max": lengths.max() if len(lengths) else np.nan})
    return pd.DataFrame(rows)


def component_summary(frame: pd.DataFrame) -> pd.DataFrame:
    l0_gate = ~flag(frame, "ifu_ip_pipeline_stall")
    rows = [
        ("l0_hit_gated", count(flag(frame, "ifu_l0_btb_hit_raw") & l0_gate)),
        ("l0_miss_gated", count(flag(frame, "ifu_l0_btb_miss_raw") & l0_gate)),
        ("l0_mispred_gated", count(flag(frame, "ifu_l0_btb_mispred_raw") & l0_gate)),
        ("indirect_btb_checks", count(flag(frame, "ifu_ind_btb_check_valid"))),
        ("indirect_btb_misses", count(flag(frame, "ifu_ind_btb_check_valid")
                                      & flag(frame, "ifu_ind_btb_miss_raw"))),
        ("ras_redirects", count(flag(frame, "ras_redirect"))),
        ("ras_type_corrections", count(flag(frame, "ras_mistaken"))),
    ]
    return pd.DataFrame(rows, columns=["component_metric", "events"])


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def main() -> None:
    args = parse_args()
    result_dir = args.result_dir.resolve()
    signals = (args.signals or result_dir / "branch_precision_signals.csv").resolve()
    output = (args.output_dir or result_dir / "branch_precision_analysis").resolve()
    output.mkdir(parents=True, exist_ok=True)

    roi = parse_coremark_roi(result_dir / "coremark.asm", result_dir / "pc_trace.log",
                             result_dir / "run.vcs.log")
    supplement = args.supplement.resolve() if args.supplement else None
    frame = select_roi(numeric_frame(signals, supplement), roi)
    assert_binary_known(frame, ["rtu_retire0_condbr", "rtu_retire1_condbr",
                                "rtu_retire2_condbr"], pd.Series(True, index=frame.index))
    assert_known(frame, ["branch_ex1_iid", "branch_ex1_pid"],
                 flag(frame, "branch_ex1_valid"))
    assert_known(frame, ["branch_recovery_iid", "branch_recovery_pid"],
                 flag(frame, "iu_cancel"))

    architecture, architecture_scalars = architecture_summary(frame)
    execution = execution_summary(frame)
    redirects, redirect_summary, redirect_diagnostics = build_redirect_events(frame)
    l0_ip = pair_l0_ip(frame, redirects)
    bju_events, bju_summary, bju_diagnostics = build_bju_events(frame, redirects)
    stalls = stall_summary(frame)
    components = component_summary(frame)

    architecture.to_csv(output / "architecture_summary.csv", index=False)
    execution.to_csv(output / "execution_observations.csv", index=False)
    redirects.to_csv(output / "redirect_events.csv", index=False)
    redirect_summary.to_csv(output / "redirect_summary.csv", index=False)
    l0_ip.to_csv(output / "l0_ip_pairs.csv", index=False)
    bju_events.to_csv(output / "bju_events.csv", index=False)
    bju_summary.to_csv(output / "bju_recovery_summary.csv", index=False)
    stalls.to_csv(output / "stall_summary.csv", index=False)
    components.to_csv(output / "component_summary.csv", index=False)

    validations = {
        "roi": roi,
        "rows": int(len(frame)),
        "cycle_sequence_exact": True,
        "architecture": architecture_scalars,
        "redirect_diagnostics": redirect_diagnostics,
        "bju_diagnostics": bju_diagnostics,
        "l0_ip_corrections": int(len(l0_ip)),
        "l0_ip_identity_matched": int(l0_ip.matched.sum()) if not l0_ip.empty else 0,
    }
    if bju_diagnostics["ex1_to_ex2_identity_failures"]:
        raise ValueError(f"BJU EX1->EX2 identity validation failed: {bju_diagnostics}")
    if validations["l0_ip_corrections"] != validations["l0_ip_identity_matched"]:
        raise ValueError(f"L0->IP identity validation failed: {validations}")
    if bju_diagnostics["architecturally_retired_mispredictions_paired"] != architecture_scalars[
        "retired_all_mispredictions"
    ]:
        raise ValueError(f"BJU cancel->retirement coverage mismatch: {validations}")
    write_json(output / "validation.json", validations)
    print(json.dumps(validations, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
