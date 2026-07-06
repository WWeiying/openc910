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

DETAIL_FOCUS = [
    "id_ctrl_stall",
    "id_ir_stall",
    "id_not_pipedown3",
    "rtu_rob_full",
    "ir_preg_not_vld",
    "rtu_global_flush",
    "iu_pipe0_flush",
    "lsu_spec_fail_flush",
    "rf_pipe0_lch_fail",
    "rf_pipe1_lch_fail",
    "rf_pipe2_lch_fail",
    "rf_pipe3_lch_fail",
    "rf_pipe4_lch_fail",
    "rf_pipe5_lch_fail",
    "rf_pipe6_lch_fail",
    "rf_pipe7_lch_fail",
    "lsu_ld_cross4k_hpcp",
    "lsu_st_cross4k_hpcp",
    "lsu_ld_other_hpcp",
    "lsu_st_other_hpcp",
    "ld_ag_dcache_stall_req",
    "ld_ag_mmu_stall_req",
    "st_ag_dcache_stall_req",
    "st_ag_mmu_stall_req",
    "ifu_ibuf_full",
    "ifu_pcfifo_full_stall",
    "retire_width0_cycle",
    "retire_width3_cycle",
    "rob_full_dbg",
    "rob_occ_ge64",
    "rob_occ_ge96",
    "is_iq_full",
    "aiq0_full",
    "aiq1_full",
    "biq_full",
    "lsiq_full",
    "sdiq_full",
    "retire_bht_mispred",
    "retire_jmp_mispred",
    "icache_refill_busy",
    "icache_miss_under_refill",
    "dcache_read_miss",
    "dcache_write_miss",
    "ld_utlb_miss",
    "st_utlb_miss",
    "lq_full_raw",
    "sq_full_raw",
    "rb_full_raw",
    "lfb_addr_full",
    "pipe5_inst_vld",
    "pipe6_inst_vld",
    "pipe7_inst_vld",
    "mult_pipe1_stall",
    "div_wb_stall",
    "ifu_ibuf_create",
    "ifu_ibuf_retire",
    "ifu_pcfifo_create",
    "ifu_ind_btb_miss",
    "ifu_ind_btb_rd_stall",
    "ifu_btb_miss",
    "ifu_l0_btb_miss",
    "ras_push",
    "ras_pop",
    "ras_empty",
    "ras_full",
    "bht_wrbuf_create_slot_full",
    "icache_refill_start",
    "icache_refill_cmplt",
    "icache_refill_on",
    "retire_load_any",
    "retire_store_any",
    "retire_preg_write_any",
    "retire_vreg_write_any",
    "retire_s0_valid",
    "retire_s1_valid",
    "retire_s2_valid",
    "retire_s0_load",
    "retire_s1_load",
    "retire_s2_load",
    "retire_s0_store",
    "retire_s1_store",
    "retire_s2_store",
    "retire_s0_bju",
    "retire_s1_bju",
    "retire_s2_bju",
    "rob_head_valid",
    "rob_head_load",
    "rob_head_store",
    "rob_head_bju",
    "rob_head_expt",
    "rob_head_spec_fail",
    "wmb_write_biu_req",
    "wmb_write_stall",
    "wmb_merge_data_stall",
    "lfb_data_full",
    "lfb_data_wait_surplus",
    "biu_arvalid",
    "biu_ar_backpressure",
    "biu_rvalid",
    "biu_r_handshake",
    "biu_r_backpressure",
    "biu_awvalid",
    "biu_aw_handshake",
    "biu_aw_backpressure",
    "biu_wvalid",
    "biu_w_handshake",
    "biu_w_backpressure",
    "biu_bvalid",
    "biu_b_handshake",
    "biu_b_backpressure",
    "biu_st_aw_stall",
    "biu_vict_aw_stall",
    "biu_st_w_stall",
    "biu_vict_w_stall",
    "biu_write_busy",
    "cpi_stack_retiring",
    "cpi_stack_bad_spec",
    "cpi_stack_frontend",
    "cpi_stack_memory",
    "cpi_stack_backend_core",
    "cpi_stack_idle_unknown",
    "preg_alloc0_block",
    "preg_alloc1_block",
    "preg_alloc2_block",
    "preg_alloc3_block",
    "ereg_alloc0_block",
    "ereg_alloc1_block",
    "ereg_alloc2_block",
    "ereg_alloc3_block",
    "freg_vreg_alloc0_block",
    "freg_vreg_alloc1_block",
    "freg_vreg_alloc2_block",
    "freg_vreg_alloc3_block",
    "vfpu_pipe6_issue",
    "vfpu_pipe7_issue",
    "vfpu_vdiv_issue",
    "vfdsu_pipe_busy",
    "vfdsu_ex2_wait",
    "vfpu_pipe6_vmla_no_fwd",
    "vfpu_pipe7_vmla_no_fwd",
    "ld_pfu_act",
    "st_pfu_act",
    "ld_pfu_pf_inst",
    "st_pfu_pf_inst",
    "pfu_biu_ar_req",
    "pfu_biu_req_hit_idx",
    "pfu_biu_pe_grnt",
    "vb_addr_full",
    "vb_data_full",
    "vb_biu_aw_req",
    "vb_biu_w_req",
    "ld_lfb_discard_grnt",
    "ld_rb_discard_grnt",
    "ld_sq_global_discard",
    "ld_data_discard_hpcp",
    "ld_discard_sq_hpcp",
    "is_dispatch_stall",
    "is_rob_full_stall",
    "is_iq_full_stall",
    "is_vmb_full_stall",
    "is_aiq0_full_updt",
    "is_aiq1_full_updt",
    "is_lsiq_full_updt",
    "is_sdiq_full_updt",
    "is_viq0_full_updt",
    "is_viq1_full_updt",
    "is_aiq0_create0",
    "is_aiq1_create0",
    "is_lsiq_create0",
    "is_sdiq_create0",
    "is_viq0_create0",
    "aiq0_rf_pop",
    "aiq1_rf_pop",
    "biq_rf_pop",
    "lsiq_pop",
    "sdiq_pop",
    "viq0_rf_pop",
    "viq1_rf_pop",
    "dca_lfb_ld_req",
    "dca_vb_ld_req",
    "dca_wmb_ld_req",
    "dca_ag_ld_req",
    "dca_lfb_ld_grnt",
    "dca_vb_ld_grnt",
    "dca_wmb_ld_grnt",
    "dca_ag_ld_grnt",
    "dca_lfb_st_req",
    "dca_vb_st_req",
    "dca_wmb_st_req",
    "dca_ag_st_req",
    "dca_serial_vld",
    "dca_ld_borrow_vld",
    "dca_st_borrow_vld",
    "sq_create_success",
    "sq_pop_to_ce_req",
    "sq_wmb_merge_stall_req",
    "sq_data_discard_req",
    "sq_other_discard_req",
    "sq_newest_fwd_req",
    "sq_addr1_dep_discard",
    "lfb_empty",
    "lfb_addr_pop_vld",
    "lfb_addr_discard_vld",
    "lfb_addr_dcache_hit",
    "lfb_ld_da_hit_idx",
    "lfb_st_da_hit_idx",
    "lfb_pfu_biu_req_hit_idx",
    "lfb_rb_biu_req_hit_idx",
    "lfb_wmb_read_req_hit_idx",
    "lfb_wmb_write_req_hit_idx",
    "lfb_vb_create_req",
    "lfb_vb_create_vld",
    "lfb_vb_pe_req",
    "lfb_vb_pe_grnt",
    "lfb_data_create_vld",
    "lfb_lf_sm_vld",
    "lfb_lf_sm_req",
    "lfb_lf_sm_create_vld",
    "lfb_lf_sm_refill_wakeup",
    "lfb_lf_sm_data_grnt",
    "lfb_lf_sm_data_pop_req",
    "lfb_biu_r_id_hit",
    "lfb_ca_rready_grnt",
    "lfb_nc_rready_grnt",
    "lfb_pop_depd_ff",
    "lfb_depd_wakeup",
    "lfb_addr_not_resp",
    "wmb_create_vld",
    "wmb_biu_ar_req",
    "wmb_biu_aw_req",
    "wmb_biu_w_req",
    "wmb_biu_nc_req_grnt",
    "wmb_biu_so_req_grnt",
    "wmb_mem_set_write_grnt",
    "wmb_vb_create_req",
    "wmb_vb_create_vld",
    "wmb_st_wb_cmplt_req",
    "wmb_st_wb_spec_fail",
    "wmb_ld_wb_data_req",
    "wmb_ld_dc_fwd_req",
    "wmb_ld_dc_cancel_acc_req",
    "wmb_pop_depd",
    "wmb_pop_discard_req",
    "wmb_pop_fwd_req",
    "wmb_wakeup_queue_not_empty",
    "wmb_depd_wakeup",
    "wmb_b_nc_id_hit",
    "wmb_b_so_id_hit",
    "wmb_sync_fence_req_success",
    "wmb_has_sync_fence",
    "rb_empty",
    "rb_create_ld_success",
    "rb_create_st_success",
    "rb_biu_req_unmask",
    "rb_biu_ar_req_detail",
    "rb_biu_req_hit_idx",
    "rb_biu_nc_req_grnt",
    "rb_biu_so_req_grnt",
    "rb_lfb_create_vld",
    "rb_lfb_boundary_wakeup",
    "rb_lfb_depd",
    "rb_pfu_biu_req_hit_idx",
    "rb_wmb_ce_hit_idx",
    "rb_ld_da_hit_idx",
    "rb_st_da_hit_idx",
    "rb_ld_da_merge_fail",
    "rb_ld_wb_cmplt_req",
    "rb_ld_wb_data_req",
    "rb_entry_read_req_grnt",
    "rb_entry_wb_cmplt_req",
    "rb_entry_wb_data_req",
    "rb_entry_discard_vld",
    "rb_entry_boundary_wakeup",
    "rb_pfu_nc_no_pending",
    "rob_commit0",
    "rob_commit1",
    "rob_commit2",
    "rob_commit_width0_cycle",
    "rob_commit_width3_cycle",
    "rob_read0_valid",
    "rob_read0_cmplted",
    "rob_read0_commit",
    "rob_head_not_complete",
    "rob_read0_expt_entry",
    "rob_commit1_mask",
    "rob_commit2_mask",
    "rob_read0_pipe0_cmplt",
    "rob_read0_pipe1_cmplt",
    "rob_read0_pipe2_cmplt",
    "rob_read0_pipe3_cmplt",
    "rob_read0_pipe4_cmplt",
    "rob_read0_pipe6_cmplt",
    "rob_read0_pipe7_cmplt",
    "retire_async_expt",
    "retire_async_no_commit",
    "retire_async_no_retire",
    "retire_inst0_flush",
    "retire_inst0_mispred",
    "retire_rob_flush",
    "aiq0_ready_any",
    "aiq1_ready_any",
    "biq_ready_any",
    "lsiq_ready_any",
    "sdiq_ready_any",
    "viq0_ready_any",
    "viq1_ready_any",
    "aiq0_valid_not_ready",
    "aiq1_valid_not_ready",
    "biq_valid_not_ready",
    "lsiq_valid_not_ready",
    "sdiq_valid_not_ready",
    "viq0_valid_not_ready",
    "viq1_valid_not_ready",
    "aiq0_src0_not_ready",
    "aiq0_src1_not_ready",
    "aiq0_src2_not_ready",
    "aiq1_src0_not_ready",
    "aiq1_src1_not_ready",
    "aiq1_src2_not_ready",
    "biq_src0_not_ready",
    "biq_src1_not_ready",
    "lsiq_src0_not_ready",
    "lsiq_src1_not_ready",
    "lsiq_srcvm_not_ready",
    "sdiq_src0_not_ready",
    "sdiq_srcv0_not_ready",
    "sdiq_staddr_not_ready",
    "viq0_srcv0_not_ready",
    "viq0_srcv1_not_ready",
    "viq0_srcv2_not_ready",
    "viq0_srcvm_not_ready",
    "viq1_srcv0_not_ready",
    "viq1_srcv1_not_ready",
    "viq1_srcv2_not_ready",
    "viq1_srcvm_not_ready",
    "iq_load_dep_not_ready",
    "iq_nonload_dep_not_ready",
    "aiq0_load_dep_not_ready",
    "aiq0_nonload_dep_not_ready",
    "aiq1_load_dep_not_ready",
    "aiq1_nonload_dep_not_ready",
    "biq_load_dep_not_ready",
    "biq_nonload_dep_not_ready",
    "lsiq_load_dep_not_ready",
    "lsiq_nonload_dep_not_ready",
    "sdiq_load_dep_not_ready",
    "sdiq_nonload_dep_not_ready",
    "viq0_load_dep_not_ready",
    "viq0_nonload_dep_not_ready",
    "viq1_load_dep_not_ready",
    "viq1_nonload_dep_not_ready",
    "iq_ready_not_issued",
    "aiq0_ready_not_issued",
    "aiq1_ready_not_issued",
    "biq_ready_not_issued",
    "lsiq_ready_not_issued",
    "sdiq_ready_not_issued",
    "viq0_ready_not_issued",
    "viq1_ready_not_issued",
    "rf_pipe0_src0_no_rdy",
    "rf_pipe0_src1_no_rdy",
    "rf_pipe0_src2_no_rdy",
    "rf_pipe1_src0_no_rdy",
    "rf_pipe1_src1_no_rdy",
    "rf_pipe1_src2_no_rdy",
    "rf_pipe2_src0_no_rdy",
    "rf_pipe2_src1_no_rdy",
    "rf_pipe3_src0_no_rdy_deep",
    "rf_pipe3_src1_no_rdy_deep",
    "rf_pipe3_srcvm_no_rdy",
    "rf_pipe4_src0_no_rdy_deep",
    "rf_pipe4_src1_no_rdy_deep",
    "rf_pipe4_srcvm_no_rdy",
    "rf_pipe5_src0_no_rdy",
    "rf_pipe5_srcv0_no_rdy",
    "rf_pipe5_staddr_no_rdy",
    "rf_pipe6_srcv0_no_rdy",
    "rf_pipe6_srcv1_no_rdy",
    "rf_pipe6_srcv2_no_rdy",
    "rf_pipe6_srcvm_no_rdy",
    "rf_pipe7_srcv0_no_rdy",
    "rf_pipe7_srcv1_no_rdy",
    "rf_pipe7_srcv2_no_rdy",
    "rf_pipe7_srcvm_no_rdy",
    "rf_src_no_rdy_any_deep",
    "rf_pipe0_vdiv_mtvr_fail",
    "rf_pipe3_preg_lch_fail",
    "rf_pipe3_vreg_lch_fail",
    "rf_pipe4_vreg_lch_fail",
    "rf_pipe5_preg_lch_fail",
    "rf_pipe6_div_mfvr_fail",
    "rf_pipe6_vmul_unsplit_fail",
    "rf_pipe7_mult_mfvr_fail",
    "lsu_replay_data_discard",
    "lsu_replay_discard_sq",
    "sq_has_fwd_req",
    "sq_fwd_req",
    "sq_fwd_bypass_req",
    "sq_fwd_bypass_multi",
    "sq_fwd_multi",
    "sq_fwd_multi_mask",
    "sq_cancel_acc_req",
    "sq_cancel_ahead_wb",
    "lsu_ld_ag_wait_old",
    "lsu_ld_da_wait_old",
    "lsu_st_ag_wait_old",
    "lsu_wait_old",
    "lsu_lq_full_from_idu",
    "lsu_sq_full_from_idu",
    "lsu_rb_full_from_idu",
    "producer_alu0_wakeup",
    "producer_alu1_wakeup",
    "producer_mult_wakeup",
    "producer_div_wakeup",
    "producer_load_fwd_wakeup",
    "producer_vload_fwd_wakeup",
    "producer_vfpu6_wakeup",
    "producer_vfpu7_wakeup",
    "aiq0_issue_select_any",
    "aiq1_issue_select_any",
    "biq_issue_select_any",
    "lsiq_issue_select_any",
    "sdiq_issue_select_any",
    "viq0_issue_select_any",
    "viq1_issue_select_any",
    "iutlb_miss",
    "dutlb_miss",
    "jtlb_miss",
    "ifu_mmu_va_vld",
    "mmu_ifu_pavld",
    "lsu_mmu_va0_vld",
    "lsu_mmu_va1_vld",
    "lsu_mmu_va2_vld",
    "mmu_lsu_pa0_vld",
    "mmu_lsu_pa1_vld",
    "mmu_lsu_pa2_vld",
    "mmu_lsu_stall0",
    "mmu_lsu_stall1",
    "mmu_lsu_tlb_busy",
    "iutlb_arb_req",
    "iutlb_arb_cmplt",
    "dutlb_arb_req",
    "dutlb_arb_cmplt",
    "jtlb_ptw_req",
    "ptw_arb_req",
    "ptw_jtlb_imiss",
    "ptw_jtlb_dmiss",
    "ptw_jtlb_pmiss",
    "ptw_jtlb_ref_cmplt",
    "ptw_jtlb_ref_data_vld",
    "mmu_lsu_data_req",
    "lsu_mmu_data_vld",
    "ptw_top_imiss",
    "jtlb_arb_tc_miss",
    "jtlb_arb_sel_4k",
    "jtlb_arb_sel_2m",
    "jtlb_arb_sel_1g",
    "mmu_lsu_page_fault",
    "rob_occ_lt32",
    "rob_occ_32_63",
    "rob_occ_ge64_bucket",
    "zero_bad_spec_raw",
    "zero_frontend_raw",
    "zero_memory_raw",
    "zero_backend_raw",
    "zero_multi_raw_cause",
    "l0_btb_hit",
    "l0_btb_mispred",
    "ind_btb_check",
    "ind_btb_fifo_stall",
    "ras_mistaken",
    "bht_pred_array_rd",
    "bht_sel_array_rd",
    "bht_wr_buf_hit",
    "bht_bju_mispred",
    "sq_newest_fwd_req_deep",
    "sq_addr_dep_discard_deep",
    "ld_sq_data_discard_deep",
    "ld_sq_global_discard_deep",
    "ld_wmb_discard_deep",
    "lsu_spec_fail_deep",
    "lfb_rb_create_entry",
    "lfb_pfu_create_entry",
    "lfb_addr_pop_entry",
    "wmb_entry_create_deep",
    "wmb_entry_pop_deep",
    "sq_entry_create_deep",
    "sq_entry_pop_deep",
    "biu_rd_outstanding",
    "biu_rd_outstanding_ge2",
    "biu_wr_outstanding",
    "biu_wr_outstanding_ge2",
    "pst_async_flush",
    "pst_preg_recover_vec",
    "pst_ereg_recover_vec",
    "preg_alloc_avail0",
    "ereg_alloc_avail0",
    "flush_fetch_invalid_cycle",
    "flush_id_invalid_cycle",
]

PROFILE_FOCUS = [
    "id_width_avg",
    "ir_width_avg",
    "is_width_avg",
    "rf_launch_width_avg",
    "retire_width_avg",
    "rob_occ_avg",
    "aiq0_occ_avg",
    "aiq1_occ_avg",
    "biq_occ_avg",
    "lsiq_occ_avg",
    "sdiq_occ_avg",
    "lq_occ_avg",
    "sq_occ_avg",
    "rb_occ_avg",
    "lfb_addr_occ_avg",
    "wmb_occ_avg",
    "ibuf_occ_avg",
    "bht_wrbuf_occ_avg",
    "lfb_data_occ_avg",
    "retire_load_inst_avg",
    "retire_store_inst_avg",
    "retire_bju_inst_avg",
    "retire_condbr_inst_avg",
    "retire_jmp_inst_avg",
    "retire_split_inst_avg",
    "retire_preg_inst_avg",
    "retire_vreg_inst_avg",
    "retire_ereg_inst_avg",
    "retire_nospec_hit_avg",
    "retire_nospec_miss_avg",
    "retire_nospec_misp_avg",
    "retire_vl_pred_avg",
    "preg_alloc_req_avg",
    "preg_alloc_vld_avg",
    "preg_alloc_block_avg",
    "ereg_alloc_req_avg",
    "ereg_alloc_vld_avg",
    "ereg_alloc_block_avg",
    "freg_vreg_alloc_req_avg",
    "freg_vreg_alloc_vld_avg",
    "freg_vreg_alloc_block_avg",
    "vfpu_issue_width_avg",
    "vfpu_wb_width_avg",
    "pfu_pfb_occ_avg",
    "pfu_pmb_occ_avg",
    "pfu_sdb_occ_avg",
    "vb_addr_occ_avg",
    "vb_data_occ_avg",
    "is_create_width_avg",
    "is_aiq_create_avg",
    "is_lsiq_create_avg",
    "is_sdiq_create_avg",
    "is_viq_create_avg",
    "iq_pop_width_avg",
    "int_iq_pop_avg",
    "lsu_iq_pop_avg",
    "vec_iq_pop_avg",
    "dca_ld_req_width_avg",
    "dca_ld_grnt_width_avg",
    "dca_st_req_width_avg",
    "dca_st_grnt_width_avg",
    "lfb_addr_pop_avg",
    "lfb_dcache_hit_avg",
    "lfb_depd_wakeup_avg",
    "lfb_vb_pe_req_avg",
    "wmb_wakeup_queue_avg",
    "wmb_depd_wakeup_avg",
    "wmb_create_width_avg",
    "rb_create_width_avg",
    "rb_biu_pe_req_avg",
    "rob_commit_width_avg",
    "iq_ready_width_avg",
    "iq_not_ready_width_avg",
    "iq_select_width_avg",
    "int_iq_ready_avg",
    "lsu_iq_ready_avg",
    "vec_iq_ready_avg",
    "int_iq_not_ready_avg",
    "lsu_iq_not_ready_avg",
    "vec_iq_not_ready_avg",
    "mmu_va_req_width_avg",
    "tlb_refill_req_avg",
    "tlb_refill_cmplt_avg",
    "ptw_activity_avg",
    "mem_wakeup_width_avg",
    "biu_rd_outstanding_avg",
    "biu_wr_outstanding_avg",
    "cpi_raw_cause_avg",
    "iq_blocked_queue_avg",
    "iq_ready_queue_avg",
    "preg_alloc_avail_avg",
    "ereg_alloc_avail_avg",
    "aiq0_not_ready_avg",
    "aiq1_not_ready_avg",
    "biq_not_ready_avg",
    "lsiq_not_ready_avg",
    "sdiq_not_ready_avg",
    "viq0_not_ready_avg",
    "viq1_not_ready_avg",
    "wmb_pop_width_avg",
    "sq_pop_width_avg",
    "aiq0_src0_not_ready_avg",
    "aiq0_src1_not_ready_avg",
    "aiq0_src2_not_ready_avg",
    "aiq1_src0_not_ready_avg",
    "aiq1_src1_not_ready_avg",
    "aiq1_src2_not_ready_avg",
    "biq_src0_not_ready_avg",
    "biq_src1_not_ready_avg",
    "lsiq_src0_not_ready_avg",
    "lsiq_src1_not_ready_avg",
    "lsiq_srcvm_not_ready_avg",
    "sdiq_src0_not_ready_avg",
    "sdiq_srcv0_not_ready_avg",
    "sdiq_staddr_not_ready_avg",
    "viq0_srcv0_not_ready_avg",
    "viq0_srcv1_not_ready_avg",
    "viq0_srcv2_not_ready_avg",
    "viq0_srcvm_not_ready_avg",
    "viq1_srcv0_not_ready_avg",
    "viq1_srcv1_not_ready_avg",
    "viq1_srcv2_not_ready_avg",
    "viq1_srcvm_not_ready_avg",
    "iq_load_dep_not_ready_avg",
    "iq_nonload_dep_not_ready_avg",
    "aiq0_load_dep_not_ready_avg",
    "aiq0_nonload_dep_not_ready_avg",
    "aiq1_load_dep_not_ready_avg",
    "aiq1_nonload_dep_not_ready_avg",
    "biq_load_dep_not_ready_avg",
    "biq_nonload_dep_not_ready_avg",
    "lsiq_load_dep_not_ready_avg",
    "lsiq_nonload_dep_not_ready_avg",
    "sdiq_load_dep_not_ready_avg",
    "sdiq_nonload_dep_not_ready_avg",
    "viq0_load_dep_not_ready_avg",
    "viq0_nonload_dep_not_ready_avg",
    "viq1_load_dep_not_ready_avg",
    "viq1_nonload_dep_not_ready_avg",
    "aiq0_issue_select_avg",
    "aiq1_issue_select_avg",
    "biq_issue_select_avg",
    "lsiq_issue_select_avg",
    "sdiq_issue_select_avg",
    "viq0_issue_select_avg",
    "viq1_issue_select_avg",
    "iq_ready_not_issued_avg",
    "aiq0_ready_not_issued_avg",
    "aiq1_ready_not_issued_avg",
    "biq_ready_not_issued_avg",
    "lsiq_ready_not_issued_avg",
    "sdiq_ready_not_issued_avg",
    "viq0_ready_not_issued_avg",
    "viq1_ready_not_issued_avg",
    "rf_src_no_rdy_width_avg",
    "rf_pipe0_src_no_rdy_avg",
    "rf_pipe1_src_no_rdy_avg",
    "rf_pipe2_src_no_rdy_avg",
    "rf_pipe3_src_no_rdy_avg",
    "rf_pipe4_src_no_rdy_avg",
    "rf_pipe5_src_no_rdy_avg",
    "rf_pipe6_src_no_rdy_avg",
    "rf_pipe7_src_no_rdy_avg",
    "rf_other_fail_width_avg",
    "rf_pipe0_vdiv_mtvr_avg",
    "rf_pipe3_preg_fail_avg",
    "rf_pipe3_vreg_fail_avg",
    "rf_pipe4_vreg_fail_avg",
    "rf_pipe5_preg_fail_avg",
    "rf_pipe6_div_mfvr_avg",
    "rf_pipe6_vmul_unsplit_avg",
    "rf_pipe7_mult_mfvr_avg",
    "lsu_replay_discard_avg",
    "lsu_sq_fwd_width_avg",
    "lsu_sq_cancel_width_avg",
    "lsu_wait_old_width_avg",
    "lsu_queue_full_width_avg",
    "producer_alu0_avg",
    "producer_alu1_avg",
    "producer_mult_avg",
    "producer_div_avg",
    "producer_load_fwd_avg",
    "producer_vload_fwd_avg",
    "producer_vfpu6_avg",
    "producer_vfpu7_avg",
    "producer_wakeup_width_avg",
]

LATENCY_FOCUS = [
    "icache_refill_latency",
    "biu_ar_to_r_latency",
    "biu_aw_to_b_latency",
    "lfb_create_to_refill",
    "dutlb_arb_latency",
    "iutlb_arb_latency",
    "ptw_refill_latency",
    "zero_retire_episode",
    "bad_spec_episode",
    "frontend_bound_episode",
    "memory_bound_episode",
    "backend_core_episode",
    "rob_head_block_latency",
    "iq_ready_to_select",
    "iq_wait_to_ready",
    "ld_replay_pressure",
    "rb_create_to_wb_cmplt",
    "rb_create_to_wb_data",
    "pfu_pe_req_to_grant",
    "pfu_pe_req_to_lfb",
    "frontend_stall_episode",
    "ibuf_full_episode",
    "ifu_to_id_supply",
    "mispred_to_retire",
    "flush_to_retire",
    "mmu_va_to_pa",
    "aiq0_wait_to_ready",
    "aiq1_wait_to_ready",
    "biq_wait_to_ready",
    "lsiq_wait_to_ready",
    "sdiq_wait_to_ready",
    "viq0_wait_to_ready",
    "viq1_wait_to_ready",
    "aiq0_ready_to_issue",
    "aiq1_ready_to_issue",
    "biq_ready_to_issue",
    "lsiq_ready_to_issue",
    "sdiq_ready_to_issue",
    "viq0_ready_to_issue",
    "viq1_ready_to_issue",
    "dispatch_to_commit",
    "rob_full_episode",
    "sq_create_to_pop",
    "wmb_create_to_pop",
    "lfb_addr_create_to_pop",
    "lfb_data_to_empty",
    "biu_ar_to_rlast",
    "biu_aw_to_b_full",
    "flush_to_fetch",
    "flush_to_id",
    "mispred_to_fetch",
    "bht_mispred_episode",
    "pst_alloc_block_episode",
    "pst_flush_recover",
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


def parse_detail_perf(filepath, phase="Kernel"):
    """Parse a .detail.perf file and return metric -> value."""
    try:
        with open(filepath) as f:
            text = f.read()
    except FileNotFoundError:
        return {}

    result = {}
    row_re = re.compile(
        r"\|\s*(Main|Kernel)\s*\|\s*([A-Za-z0-9_]+)\s*\|"
        r"\s*([-]?\d+)\s*\|\s*([-]?\d+)\s*\|"
        r"\s*([-]?\d+(?:\.\d+)?)\s*\|\s*([-]?\d+(?:\.\d+)?)%"
    )
    for row_phase, name, count, _inst, per_kinst, cycle_pct in row_re.findall(text):
        if row_phase != phase:
            continue
        result[f"{name}.count"] = float(count)
        result[f"{name}.pki"] = float(per_kinst)
        result[f"{name}.cycle%"] = float(cycle_pct)
    return result


def parse_profile_perf(filepath, phase="Kernel"):
    """Parse the profile table in a .detail.perf file."""
    try:
        with open(filepath) as f:
            text = f.read()
    except FileNotFoundError:
        return {}

    result = {}
    row_re = re.compile(
        r"\|\s*(Main|Kernel)\s*\|\s*([A-Za-z0-9_]+)\s*\|"
        r"\s*([-]?\d+)\s*\|\s*([-]?\d+)\s*\|"
        r"\s*([-]?\d+(?:\.\d+)?)\s*\|"
    )
    for row_phase, name, total, cycles, avg in row_re.findall(text):
        if row_phase != phase:
            continue
        result[f"{name}.sum"] = float(total)
        result[f"{name}.cycles"] = float(cycles)
        result[f"{name}.avg"] = float(avg)
    return result


def parse_latency_perf(filepath, phase="Kernel"):
    """Parse the latency table in a .detail.perf file."""
    try:
        with open(filepath) as f:
            text = f.read()
    except FileNotFoundError:
        return {}

    result = {}
    row_re = re.compile(
        r"\|\s*(Main|Kernel)\s*\|\s*([A-Za-z0-9_]+)\s*\|"
        r"\s*([-]?\d+)\s*\|\s*([-]?\d+(?:\.\d+)?)\s*\|"
        r"\s*([-]?\d+)\s*\|\s*([-]?\d+)\s*\|\s*([-]?\d+)\s*\|"
        r"\s*([-]?\d+)\s*\|\s*([-]?\d+)\s*\|\s*([-]?\d+)\s*\|"
    )
    for row in row_re.findall(text):
        row_phase, name, samples, avg, le4, le8, le16, le32, le64, gt64 = row
        if row_phase != phase:
            continue
        result[f"{name}.samples"] = float(samples)
        result[f"{name}.avg"] = float(avg)
        result[f"{name}.le4"] = float(le4)
        result[f"{name}.le8"] = float(le8)
        result[f"{name}.le16"] = float(le16)
        result[f"{name}.le32"] = float(le32)
        result[f"{name}.le64"] = float(le64)
        result[f"{name}.gt64"] = float(gt64)
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
        {os.path.splitext(f)[0] for f in os.listdir(base_dir)
         if f.endswith(".perf") and not f.endswith(".detail.perf")}
        | {os.path.splitext(f)[0] for f in os.listdir(mod_dir)
           if f.endswith(".perf") and not f.endswith(".detail.perf")}
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

        base_detail = parse_detail_perf(os.path.join(base_dir, f"{case}.detail.perf"))
        mod_detail = parse_detail_perf(os.path.join(mod_dir, f"{case}.detail.perf"))
        base_profile = parse_profile_perf(os.path.join(base_dir, f"{case}.detail.perf"))
        mod_profile = parse_profile_perf(os.path.join(mod_dir, f"{case}.detail.perf"))
        base_latency = parse_latency_perf(os.path.join(base_dir, f"{case}.detail.perf"))
        mod_latency = parse_latency_perf(os.path.join(mod_dir, f"{case}.detail.perf"))
        if base_detail or mod_detail:
            emit("    [Kernel detail metrics: per KInst / cycles%]")
            for detail_name in DETAIL_FOCUS:
                b_pki = base_detail.get(f"{detail_name}.pki")
                m_pki = mod_detail.get(f"{detail_name}.pki")
                b_cyc = base_detail.get(f"{detail_name}.cycle%")
                m_cyc = mod_detail.get(f"{detail_name}.cycle%")
                if b_pki is None and m_pki is None and b_cyc is None and m_cyc is None:
                    continue
                b_pki = b_pki or 0.0
                m_pki = m_pki or 0.0
                b_cyc = b_cyc or 0.0
                m_cyc = m_cyc or 0.0
                emit(f"    {detail_name:<28} "
                     f"{b_pki:>9.3f}/{b_cyc:>7.3f}%  ->  "
                     f"{m_pki:>9.3f}/{m_cyc:>7.3f}%")
        if base_profile or mod_profile:
            emit("    [Kernel profile metrics: avg per cycle]")
            for profile_name in PROFILE_FOCUS:
                bv = base_profile.get(f"{profile_name}.avg")
                mv = mod_profile.get(f"{profile_name}.avg")
                if bv is None and mv is None:
                    continue
                bv = bv or 0.0
                mv = mv or 0.0
                emit(f"    {profile_name:<28} {bv:>10.3f}  ->  {mv:>10.3f}")
        if base_latency or mod_latency:
            emit("    [Kernel latency metrics: samples / avg cycles / >64 samples]")
            for latency_name in LATENCY_FOCUS:
                b_samp = base_latency.get(f"{latency_name}.samples")
                m_samp = mod_latency.get(f"{latency_name}.samples")
                b_avg = base_latency.get(f"{latency_name}.avg")
                m_avg = mod_latency.get(f"{latency_name}.avg")
                b_gt64 = base_latency.get(f"{latency_name}.gt64")
                m_gt64 = mod_latency.get(f"{latency_name}.gt64")
                if b_samp is None and m_samp is None:
                    continue
                b_samp = b_samp or 0.0
                m_samp = m_samp or 0.0
                b_avg = b_avg or 0.0
                m_avg = m_avg or 0.0
                b_gt64 = b_gt64 or 0.0
                m_gt64 = m_gt64 or 0.0
                emit(f"    {latency_name:<28} "
                     f"{b_samp:>8.0f}/{b_avg:>8.3f}/{b_gt64:>6.0f}  ->  "
                     f"{m_samp:>8.0f}/{m_avg:>8.3f}/{m_gt64:>6.0f}")

    emit()
    report_file.close()
    print(f"\n[report saved to {report_path}]")


if __name__ == "__main__":
    main()
