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
from bisect import bisect_right
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
    "branch_ex1_valid", "branch_iid_oldest", "branch_ex1_iid", "branch_pc",
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
    "branch_recovery_conditional", "branch_recovery_actual_taken",
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
    "ifu_ib_vpc_halfword",
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
    "branch_ex1_chk_idx", "branch_ex2_chk_idx", "branch_ex2_pc_halfword",
    "pcfifo_if_create0_en", "pcfifo_if_create0_pc",
    "pcfifo_if_create0_target", "pcfifo_if_create0_bht_pred",
    "pcfifo_if_create0_chk_idx", "pcfifo_if_create0_jal",
    "pcfifo_if_create0_jalr", "pcfifo_if_create0_indirect_miss",
    "pcfifo_if_create1_en", "pcfifo_if_create1_pc",
    "pcfifo_if_create1_target", "pcfifo_if_create1_bht_pred",
    "pcfifo_if_create1_chk_idx", "pcfifo_if_create1_jal",
    "pcfifo_if_create1_jalr", "pcfifo_if_create1_indirect_miss",
    "pcfifo_if_lbuf_create", "pcfifo_write0_valid", "pcfifo_write0_pid",
    "pcfifo_write1_valid", "pcfifo_write1_pid", "pcfifo_write2_valid",
    "pcfifo_write2_pid", "pcfifo_pending0_pc", "pcfifo_pending0_bht_pred",
    "pcfifo_pending0_chk_idx", "pcfifo_pending1_pc",
    "pcfifo_pending1_bht_pred", "pcfifo_pending1_chk_idx",
    "pcfifo_pending0_two_entries", "bht_vghr", "bht_retired_ghr",
    "bht_pred_update_valid", "bht_selector_update_valid",
    "bht_any_update_valid", "bht_update_buffer_create",
    "bht_update_buffer_retire", "bht_update_buffer_full",
    "bht_update_buffer_nonempty",
    "bht_update_pred_row", "bht_update_selector_row",
    "bht_update_pred_state", "bht_update_selector_state",
    "ifu_l0_hit_vector",
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


def parse_disassembly(path: Path) -> dict[int, dict[str, str]]:
    """Return exact byte-PC annotations from GNU objdump output."""
    current_function = ""
    result: dict[int, dict[str, str]] = {}
    function_re = re.compile(r"^\s*([0-9a-fA-F]+)\s+<([^>]+)>:\s*$")
    instruction_re = re.compile(
        r"^\s*([0-9a-fA-F]+):\s+([0-9a-fA-F]+)\s+(.+?)\s*$"
    )
    for line in path.read_text(errors="replace").splitlines():
        function = function_re.match(line)
        if function:
            current_function = function.group(2)
            continue
        instruction = instruction_re.match(line)
        if not instruction:
            continue
        text = instruction.group(3).split("#", 1)[0].strip()
        result[int(instruction.group(1), 16)] = {
            "function": current_function,
            "instruction": text,
            "opcode": text.split(None, 1)[0] if text else "",
        }
    return result


def saturating_update(state: int, taken: int) -> int:
    return min(3, state + 1) if taken else max(0, state - 1)


def bht_context(pc_byte: int, predicted: int, chk_idx: int) -> dict:
    """Decode the exact predictor snapshot and update key defined by ct_ifu_bht."""
    ghr = chk_idx & ((1 << 22) - 1)
    selector = (chk_idx >> 22) & 0x3
    counter = ((predicted & 1) << 1) | ((chk_idx >> 24) & 1)
    cur_pc = (pc_byte >> 4) & 0x3FF  # iu_ifu_cur_pc[12:3]
    pred_row = (((ghr >> 10) & 0xF) << 6) | (
        ((ghr >> 4) & 0x3F) ^ ((ghr >> 16) & 0x3F)
    )
    offset = (cur_pc & 0xF) ^ (ghr & 0xF)
    selected_taken_bank = (selector >> 1) & 1
    pred_slot = (offset << 1) | (0 if selected_taken_bank else 1)
    selector_row = (cur_pc >> 3) & 0x7F
    selector_slot = cur_pc & 0x7
    return {
        "bht_ghr": ghr,
        "bht_ghr_hex": f"0x{ghr:06x}",
        "bht_ghr_taken_count": ghr.bit_count(),
        "bht_selector_state": selector,
        "bht_selected_bank": "taken" if selected_taken_bank else "not_taken",
        "bht_counter_state": counter,
        "bht_counter_strength": "strong" if counter in (0, 3) else "weak",
        "bht_pred_row": pred_row,
        "bht_pred_slot": pred_slot,
        "bht_pred_key": pred_row * 32 + pred_slot,
        "bht_selector_row": selector_row,
        "bht_selector_slot": selector_slot,
        "bht_selector_key": selector_row * 8 + selector_slot,
    }


def build_pcfifo_creates(frame: pd.DataFrame) -> pd.DataFrame:
    parts = []
    for slot in range(2):
        positions = np.flatnonzero(flag(frame, f"pcfifo_if_create{slot}_en").to_numpy())
        if not len(positions):
            continue
        part = pd.DataFrame({
            "create_position": positions,
            "create_cycle": frame.cycle.to_numpy()[positions],
            "create_slot": slot,
            "pc": frame[f"pcfifo_if_create{slot}_pc"].to_numpy()[positions],
            "target": frame[f"pcfifo_if_create{slot}_target"].to_numpy()[positions],
            "predicted": frame[f"pcfifo_if_create{slot}_bht_pred"].to_numpy()[positions],
            "chk_idx": frame[f"pcfifo_if_create{slot}_chk_idx"].to_numpy()[positions],
            "jal": frame[f"pcfifo_if_create{slot}_jal"].to_numpy()[positions],
            "jalr": frame[f"pcfifo_if_create{slot}_jalr"].to_numpy()[positions],
            "indirect_miss": frame[
                f"pcfifo_if_create{slot}_indirect_miss"
            ].to_numpy()[positions],
            "from_loop_buffer": frame.pcfifo_if_lbuf_create.to_numpy()[positions],
        })
        parts.append(part)
    if not parts:
        return pd.DataFrame()
    return pd.concat(parts, ignore_index=True).sort_values(
        ["create_position", "create_slot"]
    ).reset_index(drop=True)


def pair_pcfifo_creates(dynamic: pd.DataFrame, creates: pd.DataFrame) -> pd.DataFrame:
    """Greedily pair by the complete PC/prediction snapshot, nearest first."""
    if dynamic.empty or creates.empty:
        return dynamic
    candidates: dict[tuple[int, int, int], list[tuple[int, int]]] = {}
    for row in creates.itertuples():
        key = (int(row.pc), int(row.predicted), int(row.chk_idx))
        candidates.setdefault(key, []).append((int(row.create_position), int(row.Index)))
    used: set[int] = set()
    paired = []
    for event in dynamic.itertuples():
        key = (int(event.pc_byte), int(event.predicted_taken), int(event.chk_idx))
        choices = candidates.get(key, [])
        at = bisect_right(choices, (int(event.position), np.iinfo(np.int64).max)) - 1
        while at >= 0 and choices[at][1] in used:
            at -= 1
        selected = choices[at][1] if at >= 0 else None
        if selected is not None and (
            int(event.position) - int(creates.at[selected, "create_position"]) > 4096
        ):
            selected = None
        if selected is None:
            paired.append({
                "pcfifo_pair_exact": False,
                "pcfifo_create_position": np.nan,
                "pcfifo_create_cycle": np.nan,
                "pcfifo_create_slot": np.nan,
                "pcfifo_create_to_bju_ex1": np.nan,
                "pcfifo_predicted_target_byte": "",
                "pcfifo_jal": np.nan,
                "pcfifo_jalr": np.nan,
                "pcfifo_indirect_miss": np.nan,
                "pcfifo_from_loop_buffer": np.nan,
            })
            continue
        used.add(selected)
        create = creates.loc[selected]
        paired.append({
            "pcfifo_pair_exact": True,
            "pcfifo_create_position": int(create.create_position),
            "pcfifo_create_cycle": int(create.create_cycle),
            "pcfifo_create_slot": int(create.create_slot),
            "pcfifo_create_to_bju_ex1": int(event.cycle - create.create_cycle),
            "pcfifo_predicted_target_byte": f"0x{int(create.target):x}",
            "pcfifo_jal": int(create.jal),
            "pcfifo_jalr": int(create.jalr),
            "pcfifo_indirect_miss": int(create.indirect_miss),
            "pcfifo_from_loop_buffer": int(create.from_loop_buffer),
        })
    return pd.concat(
        [dynamic.reset_index(drop=True), pd.DataFrame(paired)], axis=1
    )


def build_pcfifo_writes(frame: pd.DataFrame) -> pd.DataFrame:
    """Decode conditional-capable PCFIFO writes after PID allocation."""
    parts = []
    masks = [
        flag(frame, "pcfifo_write0_valid"),
        flag(frame, "pcfifo_write1_valid") & ~flag(
            frame, "pcfifo_pending0_two_entries"
        ),
    ]
    for port, mask in enumerate(masks):
        positions = np.flatnonzero(mask.to_numpy())
        if not len(positions):
            continue
        pending = port
        parts.append(pd.DataFrame({
            "write_position": positions,
            "write_cycle": frame.cycle.to_numpy()[positions],
            "write_port": port,
            "pid": frame[f"pcfifo_write{port}_pid"].to_numpy()[positions],
            "pc": frame[f"pcfifo_pending{pending}_pc"].to_numpy()[positions],
            "predicted": frame[
                f"pcfifo_pending{pending}_bht_pred"
            ].to_numpy()[positions],
            "chk_idx": frame[
                f"pcfifo_pending{pending}_chk_idx"
            ].to_numpy()[positions],
        }))
    return pd.concat(parts, ignore_index=True).sort_values(
        ["write_position", "write_port"]
    ).reset_index(drop=True) if parts else pd.DataFrame()


def pair_pcfifo_writes(dynamic: pd.DataFrame, writes: pd.DataFrame) -> pd.DataFrame:
    """Pair the BJU event to its allocated PCFIFO PID and complete payload."""
    candidates: dict[tuple[int, int, int, int], list[tuple[int, int]]] = {}
    for row in writes.itertuples():
        key = (int(row.pid), int(row.pc), int(row.predicted), int(row.chk_idx))
        candidates.setdefault(key, []).append((int(row.write_position), int(row.Index)))
    paired = []
    for event in dynamic.itertuples():
        key = (
            int(event.pid), int(event.pc_byte), int(event.predicted_taken),
            int(event.chk_idx),
        )
        choices = candidates.get(key, [])
        at = bisect_right(choices, (int(event.position), np.iinfo(np.int64).max)) - 1
        if at < 0:
            paired.append({"pcfifo_pid_payload_pair_exact": False})
            continue
        write = writes.loc[choices[at][1]]
        paired.append({
            "pcfifo_pid_payload_pair_exact": True,
            "pcfifo_write_position": int(write.write_position),
            "pcfifo_write_cycle": int(write.write_cycle),
            "pcfifo_write_port": int(write.write_port),
            "pcfifo_write_to_bju_ex1": int(event.cycle - write.write_cycle),
        })
    return pd.concat(
        [dynamic.reset_index(drop=True), pd.DataFrame(paired)], axis=1
    )


def pair_frontend_redirects(
    dynamic: pd.DataFrame, redirects: pd.DataFrame
) -> pd.DataFrame:
    """Attach a frontend redirect by branch fetch-block identity when observable."""
    if dynamic.empty:
        return dynamic
    frontend = redirects.loc[
        redirects.source.isin(["L0 BTB", "IP", "IB", "Addrgen"])
    ] if not redirects.empty else pd.DataFrame()
    redirects_by_block: dict[int, list[tuple[int, int]]] = {}
    if not frontend.empty:
        for row in frontend.loc[frontend.origin_halfword.notna()].itertuples():
            block = int(row.origin_halfword) >> 3
            redirects_by_block.setdefault(block, []).append(
                (int(row.position), int(row.Index))
            )
    attached = []
    for event in dynamic.itertuples():
        values = {
            "frontend_path": "unpaired",
            "frontend_redirect_source": "",
            "frontend_redirect_cycle": np.nan,
            "frontend_redirect_pair_exact_block": False,
            "frontend_redirect_to_target_if": np.nan,
            "frontend_redirect_to_target_idu": np.nan,
            "frontend_target_if_cycle": np.nan,
            "frontend_target_idu_cycle": np.nan,
        }
        if not event.predicted_taken:
            values.update({
                "frontend_path": "sequential_not_taken",
                "frontend_redirect_pair_exact_block": True,
            })
            attached.append(values)
            continue
        if event.pcfifo_from_loop_buffer == 1:
            values.update({
                "frontend_path": "loop_buffer",
                "frontend_redirect_pair_exact_block": True,
            })
            attached.append(values)
            continue
        if not event.pcfifo_pair_exact or frontend.empty:
            attached.append(values)
            continue
        create_position = int(event.pcfifo_create_position)
        block = int(event.pc_byte) >> 4
        candidates = redirects_by_block.get(block, [])
        at = bisect_right(candidates, (create_position, np.iinfo(np.int64).max)) - 1
        if at < 0 or create_position - candidates[at][0] > 8:
            values["frontend_path"] = "taken_redirect_not_identified"
            attached.append(values)
            continue
        selected = frontend.loc[candidates[at][1]]
        values.update({
            "frontend_path": selected.subtype,
            "frontend_redirect_source": selected.source,
            "frontend_redirect_cycle": int(selected.cycle),
            "frontend_redirect_pair_exact_block": True,
            "frontend_redirect_to_target_if": selected.to_target_if_valid,
            "frontend_redirect_to_target_idu": selected.to_exact_target_idu_accept,
            "frontend_target_if_cycle": selected.target_if_cycle,
            "frontend_target_idu_cycle": selected.target_idu_cycle,
        })
        attached.append(values)
    result = pd.concat(
        [dynamic.reset_index(drop=True), pd.DataFrame(attached)], axis=1
    )
    result["branch_to_target_idu_cycles"] = (
        result.frontend_target_idu_cycle - result.branch_idu_accept_cycle
    )
    result["observed_idu_bubbles_after_branch"] = (
        result.branch_to_target_idu_cycles - 1
    ).clip(lower=0)
    return result


def pair_branch_idu_accept(frame: pd.DataFrame, dynamic: pd.DataFrame) -> pd.DataFrame:
    """Pair the branch's low PC to an accepted IFU->IDU slot near PCFIFO create."""
    blocked = flag(frame, "idu_ifu_stall") | flag(frame, "rtu_flush_frontend") | flag(
        frame, "iu_cancel"
    )
    by_pc: dict[int, list[int]] = {}
    for slot in range(3):
        valid = flag(frame, f"ifu_idu_valid{slot}") & ~blocked
        pcs = frame[f"ifu_idu_pc{slot}_low_halfword"].to_numpy()
        for position in np.flatnonzero(valid.to_numpy()):
            if pd.notna(pcs[position]):
                by_pc.setdefault(int(pcs[position]), []).append(int(position))
    by_pc = {pc: sorted(set(positions)) for pc, positions in by_pc.items()}
    rows = []
    for event in dynamic.itertuples():
        if not event.pcfifo_pair_exact:
            rows.append({"branch_idu_pair_exact_low_pc": False})
            continue
        positions = by_pc.get((int(event.pc_byte) >> 1) & 0x7FFF, [])
        start = int(event.pcfifo_create_position) - 1
        at = bisect_right(positions, start - 1)
        selected = positions[at] if at < len(positions) else None
        if selected is None or selected - int(event.pcfifo_create_position) > 8:
            rows.append({"branch_idu_pair_exact_low_pc": False})
            continue
        rows.append({
            "branch_idu_pair_exact_low_pc": True,
            "branch_idu_accept_position": selected,
            "branch_idu_accept_cycle": int(frame.cycle.iat[selected]),
            "pcfifo_create_to_branch_idu_accept": int(
                frame.cycle.iat[selected] - event.pcfifo_create_cycle
            ),
        })
    return pd.concat(
        [dynamic.reset_index(drop=True), pd.DataFrame(rows)], axis=1
    )


def build_dynamic_conditional_events(
    frame: pd.DataFrame,
    bju_events: pd.DataFrame,
    redirects: pd.DataFrame,
    disassembly: dict[int, dict[str, str]],
) -> tuple[pd.DataFrame, dict]:
    eligible = (
        flag(frame, "branch_ex1_valid")
        & flag(frame, "branch_iid_oldest")
        & flag(frame, "branch_conditional")
        & ~flag(frame, "branch_page_fault")
    )
    assert_known(frame, ["branch_pc", "branch_ex1_chk_idx"], eligible)
    recovery = {}
    if not bju_events.empty:
        recovery = {
            int(row.position) - 1: row
            for _, row in bju_events.iterrows()
            if row.architecturally_retired_misprediction
            and row.subtype == "bju_conditional_direction_misprediction"
        }

    rows = []
    ex2_identity_failures = 0
    ex2_identity_observed = 0
    ex2_suppressed_by_flush = 0
    ex2_unexplained_missing = 0
    direct_update_checks = 0
    direct_update_failures = 0
    local_outcomes: dict[int, list[int]] = {}
    for position in np.flatnonzero(eligible.to_numpy()):
        pc = int(frame.branch_pc.iat[position])
        predicted = int(frame.branch_bht_pred_taken.iat[position])
        actual = int(frame.branch_taken.iat[position])
        chk_idx = int(frame.branch_ex1_chk_idx.iat[position])
        context = bht_context(pc, predicted, chk_idx)
        annotation = disassembly.get(pc, {})
        previous_local = local_outcomes.setdefault(pc, [])
        local_signature = "".join("T" if value else "N" for value in previous_local[-16:])
        previous_local.append(actual)

        ex2 = position + 1
        ex2_exact = False
        ex2_status = "missing"
        update_exact = np.nan
        if ex2 < len(frame) and bit(frame, ex2, "branch_ex2_valid"):
            ex2_identity_observed += 1
            ex2_exact = bool(
                frame.branch_recovery_iid.iat[ex2] == frame.branch_ex1_iid.iat[position]
                and frame.branch_recovery_pid.iat[ex2] == frame.branch_ex1_pid.iat[position]
                and int(frame.branch_ex2_chk_idx.iat[ex2]) == chk_idx
                and int(frame.branch_ex2_pc_halfword.iat[ex2]) == (pc >> 1)
                and int(frame.branch_recovery_conditional.iat[ex2]) == 1
                and int(frame.branch_recovery_actual_taken.iat[ex2]) == actual
            )
            if not ex2_exact:
                ex2_identity_failures += 1
                ex2_status = "identity_mismatch"
            else:
                ex2_status = "exact"
            if not bit(frame, ex2, "bht_update_buffer_nonempty"):
                direct_update_checks += 1
                expected_pred = saturating_update(context["bht_counter_state"], actual)
                expected_selector = saturating_update(
                    context["bht_selector_state"], actual
                )
                update_exact = bool(
                    int(frame.bht_update_pred_row.iat[ex2]) == context["bht_pred_row"]
                    and int(frame.bht_update_selector_row.iat[ex2])
                    == context["bht_selector_row"]
                    and int(frame.bht_update_pred_state.iat[ex2]) == expected_pred
                    and int(frame.bht_update_selector_state.iat[ex2])
                    == expected_selector
                )
                if not update_exact:
                    direct_update_failures += 1
        elif bit(frame, position, "global_flush") or bit(
            frame, position, "rtu_flush_frontend"
        ):
            ex2_suppressed_by_flush += 1
            ex2_status = "suppressed_by_global_flush"
        else:
            ex2_unexplained_missing += 1

        recovery_row = recovery.get(int(position))
        arch_wrong = recovery_row is not None
        row = {
            "event_id": len(rows),
            "position": int(position),
            "cycle": int(frame.cycle.iat[position]),
            "pc_byte": pc,
            "pc": f"0x{pc:04x}",
            "function": annotation.get("function", ""),
            "instruction": annotation.get("instruction", ""),
            "opcode": annotation.get("opcode", ""),
            "iid": int(frame.branch_ex1_iid.iat[position]),
            "pid": int(frame.branch_ex1_pid.iat[position]),
            "predicted_taken": predicted,
            "actual_taken": actual,
            "execution_direction_mismatch": predicted != actual,
            "architectural_direction_misprediction": arch_wrong,
            "direction_class": ("T->N" if predicted and not actual else
                                "N->T" if not predicted and actual else
                                "correct-T" if actual else "correct-NT"),
            "chk_idx": chk_idx,
            "chk_idx_hex": f"0x{chk_idx:07x}",
            "local_outcome_history_16": local_signature,
            "ex1_to_ex2_identity_exact": ex2_exact,
            "ex1_to_ex2_status": ex2_status,
            "rtl_direct_update_exact": update_exact,
            "bht_counter_state_after": saturating_update(
                context["bht_counter_state"], actual
            ),
            "bht_selector_state_after": saturating_update(
                context["bht_selector_state"], actual
            ),
            "recovery_cancel_cycle": (
                np.nan if recovery_row is None else int(recovery_row.cycle)
            ),
            "recovery_to_idu_release_cycles": (
                np.nan if recovery_row is None
                else recovery_row.cancel_to_idu_mispred_stall_clear
            ),
            **context,
        }
        rows.append(row)
    dynamic = pd.DataFrame(rows)
    dynamic = pair_pcfifo_creates(dynamic, build_pcfifo_creates(frame))
    dynamic = pair_pcfifo_writes(dynamic, build_pcfifo_writes(frame))
    dynamic = pair_branch_idu_accept(frame, dynamic)
    dynamic = pair_frontend_redirects(dynamic, redirects)

    if not dynamic.empty:
        key_pc_count = dynamic.groupby("bht_pred_key").pc_byte.transform("nunique")
        key_direction_count = dynamic.groupby("bht_pred_key").actual_taken.transform("nunique")
        context_direction_count = dynamic.groupby(
            ["pc_byte", "bht_ghr"]
        ).actual_taken.transform("nunique")
        dynamic["bht_key_distinct_static_pcs"] = key_pc_count
        dynamic["bht_key_observed_both_outcomes"] = key_direction_count.gt(1)
        dynamic["same_pc_same_ghr_observed_both_outcomes"] = context_direction_count.gt(1)
        dynamic["first_pred_key_observation_in_roi"] = ~dynamic.bht_pred_key.duplicated()

        previous_pc = {}
        previous_actual = {}
        previous_event = {}
        previous_pcs = []
        previous_outcomes = []
        previous_distances = []
        for row_index, row in dynamic.iterrows():
            key = int(row.bht_pred_key)
            previous_pcs.append(previous_pc.get(key, np.nan))
            previous_outcomes.append(previous_actual.get(key, np.nan))
            previous_distances.append(
                np.nan if key not in previous_event else row_index - previous_event[key]
            )
            previous_pc[key] = int(row.pc_byte)
            previous_actual[key] = int(row.actual_taken)
            previous_event[key] = int(row_index)
        dynamic["previous_same_key_pc_byte"] = previous_pcs
        dynamic["previous_same_key_actual_taken"] = previous_outcomes
        dynamic["previous_same_key_event_distance"] = previous_distances
        dynamic["previous_key_writer_is_other_pc"] = (
            dynamic.previous_same_key_pc_byte.notna()
            & dynamic.previous_same_key_pc_byte.ne(dynamic.pc_byte)
        )
        dynamic["previous_key_outcome_conflicts"] = (
            dynamic.previous_same_key_actual_taken.notna()
            & dynamic.previous_same_key_actual_taken.ne(dynamic.actual_taken)
        )

        def evidence(row: pd.Series) -> str:
            if not row.execution_direction_mismatch:
                return "correct"
            if row.first_pred_key_observation_in_roi:
                return "ROI首见，预热前状态未知"
            if row.same_pc_same_ghr_observed_both_outcomes:
                return "相同PC与22位GHR出现相反结果，存在不可分上下文证据"
            if row.previous_key_writer_is_other_pc and row.previous_key_outcome_conflicts:
                return "预测表key被其他PC以相反方向使用，存在跨PC别名证据"
            if row.bht_counter_strength == "weak":
                return "所选2位计数器处于弱状态"
            return "仅凭单次轨迹无法唯一归因"

        dynamic["cause_evidence"] = dynamic.apply(evidence, axis=1)

    diagnostics = {
        "execution_conditional_events": int(len(dynamic)),
        "execution_direction_mismatches": int(
            dynamic.execution_direction_mismatch.sum()
        ),
        "architectural_direction_mispredictions": int(
            dynamic.architectural_direction_misprediction.sum()
        ),
        "ex1_to_ex2_identity_observed": ex2_identity_observed,
        "ex1_to_ex2_identity_failures": ex2_identity_failures,
        "ex1_to_ex2_suppressed_by_flush": ex2_suppressed_by_flush,
        "ex1_to_ex2_unexplained_missing": ex2_unexplained_missing,
        "direct_bht_update_checks": direct_update_checks,
        "direct_bht_update_failures": direct_update_failures,
        "pcfifo_exact_context_pairs": int(dynamic.pcfifo_pair_exact.sum()),
        "pcfifo_pair_coverage_pct": 100.0 * dynamic.pcfifo_pair_exact.mean(),
        "pcfifo_pid_payload_exact_pairs": int(
            dynamic.pcfifo_pid_payload_pair_exact.sum()
        ),
        "pcfifo_pid_payload_pair_coverage_pct": 100.0 * (
            dynamic.pcfifo_pid_payload_pair_exact.mean()
        ),
        "branch_idu_low_pc_pair_coverage_pct": 100.0 * (
            dynamic.branch_idu_pair_exact_low_pc.fillna(False).mean()
        ),
        "predicted_taken_frontend_path_coverage_pct": 100.0 * dynamic.loc[
            dynamic.predicted_taken.eq(1), "frontend_redirect_pair_exact_block"
        ].fillna(False).mean(),
    }
    return dynamic, diagnostics


def union_length(intervals: list[tuple[int, int]]) -> int:
    if not intervals:
        return 0
    ordered = sorted(intervals)
    total = 0
    start, stop = ordered[0]
    for next_start, next_stop in ordered[1:]:
        if next_start > stop:
            total += stop - start
            start, stop = next_start, next_stop
        else:
            stop = max(stop, next_stop)
    return total + stop - start


def build_static_branch_summary(dynamic: pd.DataFrame, roi_cycles: int) -> pd.DataFrame:
    rows = []
    total_arch_wrong = int(dynamic.architectural_direction_misprediction.sum())
    for pc, group in dynamic.groupby("pc_byte", sort=False):
        wrong = group.loc[group.architectural_direction_misprediction]
        intervals = []
        for _, event in wrong.dropna(subset=["recovery_to_idu_release_cycles"]).iterrows():
            start = int(event.recovery_cancel_cycle)
            intervals.append((start, start + int(event.recovery_to_idu_release_cycles)))
        saved = union_length(intervals)
        rows.append({
            "pc_byte": int(pc),
            "pc": f"0x{int(pc):04x}",
            "function": group.function.iloc[0],
            "instruction": group.instruction.iloc[0],
            "executions_at_bju": int(len(group)),
            "actual_taken": int(group.actual_taken.sum()),
            "actual_not_taken": int(len(group) - group.actual_taken.sum()),
            "execution_direction_mismatches": int(
                group.execution_direction_mismatch.sum()
            ),
            "architectural_direction_mispredictions": int(len(wrong)),
            "architectural_errors_share_pct": (
                100.0 * len(wrong) / total_arch_wrong if total_arch_wrong else 0.0
            ),
            "execution_observed_mismatch_pct": (
                100.0 * group.execution_direction_mismatch.mean()
            ),
            "nt_to_t": int((group.direction_class == "N->T").sum()),
            "t_to_nt": int((group.direction_class == "T->N").sum()),
            "unique_ghr_contexts": int(group.bht_ghr.nunique()),
            "unique_predictor_keys": int(group.bht_pred_key.nunique()),
            "weak_counter_mismatches": int((
                group.execution_direction_mismatch
                & group.bht_counter_strength.eq("weak")
            ).sum()),
            "cross_pc_alias_evidence_mismatches": int((
                group.execution_direction_mismatch
                & group.previous_key_writer_is_other_pc
                & group.previous_key_outcome_conflicts
            ).sum()),
            "same_context_ambiguous_mismatches": int((
                group.execution_direction_mismatch
                & group.same_pc_same_ghr_observed_both_outcomes
            ).sum()),
            "measured_recovery_interval_union_cycles": saved,
            "single_hotspot_ideal_upper_bound_speedup_pct": (
                100.0 * roi_cycles / (roi_cycles - saved) - 100.0
                if saved and saved < roi_cycles else 0.0
            ),
        })
    result = pd.DataFrame(rows).sort_values(
        ["architectural_direction_mispredictions", "executions_at_bju"],
        ascending=False,
    ).reset_index(drop=True)
    if not result.empty:
        result["error_rank"] = np.arange(1, len(result) + 1)
        result["cumulative_architectural_errors"] = (
            result.architectural_direction_mispredictions.cumsum()
        )
        result["cumulative_architectural_errors_pct"] = (
            100.0 * result.cumulative_architectural_errors / total_arch_wrong
        )
    return result


def build_bht_key_summary(dynamic: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for key, group in dynamic.groupby("bht_pred_key", sort=False):
        rows.append({
            "bht_pred_key": int(key),
            "bht_pred_row": int(group.bht_pred_row.iloc[0]),
            "bht_pred_slot": int(group.bht_pred_slot.iloc[0]),
            "events": int(len(group)),
            "execution_mismatches": int(group.execution_direction_mismatch.sum()),
            "architectural_mispredictions": int(
                group.architectural_direction_misprediction.sum()
            ),
            "distinct_static_pcs": int(group.pc_byte.nunique()),
            "observed_both_outcomes": bool(group.actual_taken.nunique() > 1),
            "cross_pc_conflicting_predecessors": int((
                group.previous_key_writer_is_other_pc
                & group.previous_key_outcome_conflicts
            ).sum()),
        })
    return pd.DataFrame(rows).sort_values(
        ["architectural_mispredictions", "events"], ascending=False
    )


def build_branch_phase_summary(dynamic: pd.DataFrame, roi: dict) -> pd.DataFrame:
    if dynamic.empty:
        return pd.DataFrame()
    width = max(1, int(np.ceil(roi["cycles"] / 10)))
    phase = np.minimum(
        9, (dynamic.cycle - roi["start_cycle_inclusive"]) // width
    )
    work = dynamic.assign(phase=phase.astype(int))
    rows = []
    for phase_id, group in work.groupby("phase"):
        rows.append({
            "phase": int(phase_id),
            "cycle_start": roi["start_cycle_inclusive"] + int(phase_id) * width,
            "cycle_stop_exclusive": min(
                roi["stop_cycle_exclusive"],
                roi["start_cycle_inclusive"] + (int(phase_id) + 1) * width,
            ),
            "conditional_executions": int(len(group)),
            "execution_mismatches": int(group.execution_direction_mismatch.sum()),
            "architectural_mispredictions": int(
                group.architectural_direction_misprediction.sum()
            ),
            "execution_mismatch_pct": 100.0 * group.execution_direction_mismatch.mean(),
            "unique_static_pcs": int(group.pc_byte.nunique()),
            "first_key_observations": int(group.first_pred_key_observation_in_roi.sum()),
        })
    return pd.DataFrame(rows)


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
        if src == "L0 BTB":
            origin = frame.ifu_l0_lookup_pc_halfword.iloc[position]
        elif src == "IP":
            origin = frame.ifu_ip_vpc_halfword.iloc[position]
        elif src in ("IB", "Addrgen"):
            origin = frame.ifu_ib_vpc_halfword.iloc[position]
        elif src == "BJU":
            origin = frame.branch_recovery_pc_halfword.iloc[position]
        else:
            origin = np.nan
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
            "origin_halfword": origin,
            "target_halfword": target,
            "next_cycle_pc_matches_target": bool(next_pc_match),
            "target_if_cycle": (
                np.nan if target_if is None else int(cycles[target_if])
            ),
            "target_idu_cycle": (
                np.nan if target_accept is None else int(cycles[target_accept])
            ),
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


def predictor_internal_summary(frame: pd.DataFrame, dynamic: pd.DataFrame) -> pd.DataFrame:
    l0_hits = frame.ifu_l0_hit_vector.fillna(0).astype("int64")
    rows = [
        ("bht_pred_counter_update_requested", count(flag(frame, "bht_pred_update_valid"))),
        ("bht_selector_update_requested", count(flag(frame, "bht_selector_update_valid"))),
        ("bht_any_update", count(flag(frame, "bht_any_update_valid"))),
        ("bht_update_buffer_create", count(flag(frame, "bht_update_buffer_create"))),
        ("bht_update_buffer_retire", count(flag(frame, "bht_update_buffer_retire"))),
        ("bht_update_buffer_full_cycles", count(flag(frame, "bht_update_buffer_full"))),
        ("bht_update_buffer_nonempty_cycles", count(flag(frame, "bht_update_buffer_nonempty"))),
        ("l0_btb_any_hit_cycles_raw", int(l0_hits.ne(0).sum())),
        ("l0_btb_multiple_hit_cycles_raw", int(l0_hits.map(int.bit_count).gt(1).sum())),
        ("conditional_predictions_from_weak_counter", int(
            dynamic.bht_counter_strength.eq("weak").sum()
        )),
        ("conditional_predictions_from_strong_counter", int(
            dynamic.bht_counter_strength.eq("strong").sum()
        )),
    ]
    return pd.DataFrame(rows, columns=["internal_metric", "events_or_cycles"])


def prediction_path_summary(dynamic: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for (direction_class, path), group in dynamic.groupby(
        ["direction_class", "frontend_path"], dropna=False
    ):
        rows.append({
            "direction_class": direction_class,
            "frontend_path": path,
            "events": int(len(group)),
            "architectural_mispredictions": int(
                group.architectural_direction_misprediction.sum()
            ),
            "pcfifo_create_to_bju_ex1_mean": group.pcfifo_create_to_bju_ex1.mean(),
            "pcfifo_create_to_bju_ex1_p90": percentile_higher(
                group.pcfifo_create_to_bju_ex1, 0.9
            ),
            "redirect_to_target_if_mean": group.frontend_redirect_to_target_if.mean(),
            "redirect_to_target_idu_mean": group.frontend_redirect_to_target_idu.mean(),
            "observed_idu_bubbles_mean": group.observed_idu_bubbles_after_branch.mean(),
            "observed_idu_bubbles_p90": percentile_higher(
                group.observed_idu_bubbles_after_branch, 0.9
            ),
        })
    return pd.DataFrame(rows).sort_values(
        ["direction_class", "events"], ascending=[True, False]
    )


def write_identity_report(
    path: Path,
    dynamic: pd.DataFrame,
    static: pd.DataFrame,
    diagnostics: dict,
) -> None:
    wrong = dynamic.loc[dynamic.execution_direction_mismatch]
    evidence = (
        wrong.groupby("cause_evidence", dropna=False)
        .agg(
            execution_mismatches=("event_id", "size"),
            architectural_mispredictions=(
                "architectural_direction_misprediction", "sum"
            ),
        )
        .sort_values("execution_mismatches", ascending=False)
    )
    lines = [
        "# CoreMark 分支身份与 BHT 状态分析",
        "",
        "本文件由同目录分析器自动生成。逐条原始记录见 "
        "`dynamic_conditional_branches.csv`，不要仅根据本摘要下结论。",
        "",
        "## 覆盖与守恒",
        "",
        f"- BJU 执行级条件分支：{diagnostics['execution_conditional_events']:,} 条。",
        f"- 执行级方向不一致：{diagnostics['execution_direction_mismatches']:,} 条。",
        f"- 与退休误预测严格配对：{diagnostics['architectural_direction_mispredictions']:,} 条。",
        f"- PCFIFO 完整上下文配对率：{diagnostics['pcfifo_pair_coverage_pct']:.3f}%。",
        f"- PCFIFO PID/payload 配对率：{diagnostics['pcfifo_pid_payload_pair_coverage_pct']:.3f}%。",
        f"- EX1 到 EX2 身份错误：{diagnostics['ex1_to_ex2_identity_failures']} 条。",
        f"- 可直接核验的 BHT 更新错误：{diagnostics['direct_bht_update_failures']} 条。",
        "",
        "执行级方向不一致包含最终被更老指令冲刷的推测路径；只有“与退休误预测严格配对”"
        "才是架构可见的错误数。",
        "",
        "## 错误证据分类",
        "",
        "| 证据类别 | 执行级方向不一致 | 最终退休方向误预测 |",
        "|---|---:|---:|",
    ]
    for label, row in evidence.iterrows():
        lines.append(
            f"| {label} | {int(row.execution_mismatches):,} | "
            f"{int(row.architectural_mispredictions):,} |"
        )
    lines.extend([
        "",
        "这些类别是单次轨迹证据，不是反事实证明。尤其是容量、别名和历史长度的因果拆分，"
        "仍需改变表容量/索引/历史长度后做 A/B 实验。",
        "",
        "## 最高错误热点",
        "",
        "| 排名 | PC | 函数 | 执行 | 退休误预测 | 错误占比 | 累计占比 | 单热点理想上界 |",
        "|---:|---:|---|---:|---:|---:|---:|---:|",
    ])
    for _, row in static.head(30).iterrows():
        lines.append(
            f"| {int(row.error_rank)} | `{row.pc}` | `{row.function}` | "
            f"{int(row.executions_at_bju):,} | "
            f"{int(row.architectural_direction_mispredictions):,} | "
            f"{row.architectural_errors_share_pct:.3f}% | "
            f"{row.cumulative_architectural_errors_pct:.3f}% | "
            f"{row.single_hotspot_ideal_upper_bound_speedup_pct:.3f}% |"
        )
    lines.extend([
        "",
        "“单热点理想上界”只删除该 PC 已测得的 IDU 误预测恢复区间，忽略新暴露瓶颈，"
        "因此是局部敏感性上界，不是修改 RTL 后必然得到的收益。",
        "",
    ])
    path.write_text("\n".join(lines), encoding="utf-8")


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
    disassembly = parse_disassembly(result_dir / "coremark.asm")
    dynamic, identity_diagnostics = build_dynamic_conditional_events(
        frame, bju_events, redirects, disassembly
    )
    static = build_static_branch_summary(dynamic, roi["cycles"])
    bht_keys = build_bht_key_summary(dynamic)
    phases = build_branch_phase_summary(dynamic, roi)
    internal = predictor_internal_summary(frame, dynamic)
    paths = prediction_path_summary(dynamic)
    causes = (
        dynamic.loc[dynamic.execution_direction_mismatch]
        .groupby("cause_evidence", dropna=False)
        .agg(
            execution_mismatches=("event_id", "size"),
            architectural_mispredictions=(
                "architectural_direction_misprediction", "sum"
            ),
            distinct_static_pcs=("pc_byte", "nunique"),
        )
        .reset_index()
        .sort_values("execution_mismatches", ascending=False)
    )

    architecture.to_csv(output / "architecture_summary.csv", index=False)
    execution.to_csv(output / "execution_observations.csv", index=False)
    redirects.to_csv(output / "redirect_events.csv", index=False)
    redirect_summary.to_csv(output / "redirect_summary.csv", index=False)
    l0_ip.to_csv(output / "l0_ip_pairs.csv", index=False)
    bju_events.to_csv(output / "bju_events.csv", index=False)
    bju_summary.to_csv(output / "bju_recovery_summary.csv", index=False)
    stalls.to_csv(output / "stall_summary.csv", index=False)
    components.to_csv(output / "component_summary.csv", index=False)
    dynamic.to_csv(output / "dynamic_conditional_branches.csv", index=False)
    static.to_csv(output / "static_branch_hotspots.csv", index=False)
    bht_keys.to_csv(output / "bht_predictor_key_aliases.csv", index=False)
    phases.to_csv(output / "branch_phase_summary.csv", index=False)
    internal.to_csv(output / "predictor_internal_summary.csv", index=False)
    paths.to_csv(output / "prediction_path_summary.csv", index=False)
    causes.to_csv(output / "misprediction_cause_evidence.csv", index=False)
    write_identity_report(output / "branch_identity_report.md", dynamic, static,
                          identity_diagnostics)

    validations = {
        "roi": roi,
        "rows": int(len(frame)),
        "cycle_sequence_exact": True,
        "architecture": architecture_scalars,
        "redirect_diagnostics": redirect_diagnostics,
        "bju_diagnostics": bju_diagnostics,
        "branch_identity_diagnostics": identity_diagnostics,
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
    if identity_diagnostics["architectural_direction_mispredictions"] != architecture_scalars[
        "retired_direction_mispredictions"
    ]:
        raise ValueError(f"per-branch direction count does not conserve: {validations}")
    if identity_diagnostics["ex1_to_ex2_identity_failures"]:
        raise ValueError(f"BJU EX1->EX2 v3 state validation failed: {validations}")
    if identity_diagnostics["ex1_to_ex2_unexplained_missing"]:
        raise ValueError(f"BJU EX1->EX2 has unexplained missing events: {validations}")
    if identity_diagnostics["direct_bht_update_failures"]:
        raise ValueError(f"derived BHT update does not match RTL: {validations}")
    if identity_diagnostics["pcfifo_pair_coverage_pct"] < 99.0:
        raise ValueError(f"PCFIFO lifecycle coverage is below 99%: {validations}")
    if identity_diagnostics["pcfifo_pid_payload_pair_coverage_pct"] < 99.0:
        raise ValueError(f"PCFIFO PID/payload coverage is below 99%: {validations}")
    write_json(output / "validation.json", validations)
    print(json.dumps(validations, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
