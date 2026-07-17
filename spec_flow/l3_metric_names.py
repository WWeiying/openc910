#!/usr/bin/env python3
"""Stable names for L3 RTL counters emitted by ``smart_run``."""

import re
from pathlib import Path


EVENT_NAMES = {
    1: "l1i_accesses",
    2: "l1i_misses",
    3: "iutlb_misses",
    4: "dutlb_misses",
    5: "jtlb_misses",
    6: "conditional_branch_mispredicts",
    7: "conditional_branches",
    8: "indirect_branch_mispredicts",
    9: "indirect_branches",
    10: "lsu_speculation_failures",
    11: "retired_stores",
    12: "l1d_load_accesses",
    13: "l1d_load_misses",
    14: "l1d_store_accesses",
    15: "l1d_store_misses",
    16: "l2_read_accesses_unimplemented",
    17: "l2_read_misses_unimplemented",
    18: "l2_write_accesses_unimplemented",
    19: "l2_write_misses_unimplemented",
    20: "rf_launch_failures",
    21: "rf_register_launch_failures",
    22: "rf_pipe_launches",
    23: "lsu_cross_4k_stalls",
    24: "lsu_other_stalls",
    25: "lsu_sq_discards",
    26: "lsu_sq_data_discards",
    27: "branch_target_mispredicts",
    28: "branch_target_instructions",
    29: "decoded_alu_instructions",
    30: "decoded_load_store_instructions",
    31: "decoded_vector_instructions",
    32: "decoded_csr_instructions",
    33: "decoded_sync_instructions",
    34: "unaligned_accesses",
    35: "interrupt_acknowledgements",
    36: "interrupt_disabled_cycles",
    37: "decoded_ecall_instructions",
    38: "retired_long_jumps",
    39: "frontend_stall_cycles",
    40: "backend_stall_cycles",
    41: "synchronization_stall_cycles",
    42: "decoded_floating_point_instructions",
}


TASK_PATTERNS = {
    "details": re.compile(
        r'print_detail_row\(phase,\s*"([^"]+)",\s*(\d+),\s*use_kernel\);'
    ),
    "profiles": re.compile(
        r'print_profile_row\(phase,\s*"([^"]+)",\s*(\d+),\s*use_kernel\);'
    ),
    "latencies": re.compile(
        r'print_latency_row\(phase,\s*"([^"]+)",\s*(\d+),\s*use_kernel\);'
    ),
}


EXPECTED_COUNTS = {
    "details": 805,
    "profiles": 189,
    "latencies": 54,
}


def parse_metric_names(testbench):
    """Extract the canonical detail/profile/latency dictionaries from tb.v."""
    source = Path(testbench).read_text()
    result = {}
    for group, pattern in TASK_PATTERNS.items():
        mapping = {int(metric_id): name for name, metric_id in pattern.findall(source)}
        expected = EXPECTED_COUNTS[group]
        if set(mapping) != set(range(1, expected + 1)):
            raise ValueError(
                f"{testbench}: {group} metric IDs are not contiguous 1-{expected}"
            )
        result[group] = mapping
    return result


def add_derived_events(events):
    """Add aggregation aliases without hiding the raw hardware event names."""
    derived = dict(events)
    derived["branches"] = (
        events.get("conditional_branches", 0)
        + events.get("indirect_branches", 0)
    )
    derived["branch_mispredicts"] = (
        events.get("conditional_branch_mispredicts", 0)
        + events.get("indirect_branch_mispredicts", 0)
    )
    derived["loads"] = events.get("l1d_load_accesses", 0)
    derived["stores"] = events.get("l1d_store_accesses", 0)
    derived["l2_accesses"] = (
        events.get("l2_read_accesses_unimplemented", 0)
        + events.get("l2_write_accesses_unimplemented", 0)
    )
    derived["l2_misses"] = (
        events.get("l2_read_misses_unimplemented", 0)
        + events.get("l2_write_misses_unimplemented", 0)
    )
    return derived
