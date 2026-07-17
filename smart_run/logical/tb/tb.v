/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
`include "../../work/symbols.svh"
`timescale 1ns/100ps

`define CLK_PERIOD          10
`define TCLK_PERIOD         40
`define MAX_RUN_TIME        32'h3000000
`define LAST_CYCLE 100000

`define SOC_TOP             tb.x_soc
`define RTL_MEM             tb.x_soc.x_axi_slave128.x_f_spsram_large

`define CPU_TOP             tb.x_soc.x_cpu_sub_system_axi.x_rv_integration_platform.x_cpu_top
`define tb_retire0          `CPU_TOP.core0_pad_retire0
`define retire0_pc          `CPU_TOP.core0_pad_retire0_pc[39:0]
`define tb_retire1          `CPU_TOP.core0_pad_retire1
`define retire1_pc          `CPU_TOP.core0_pad_retire1_pc[39:0]
`define tb_retire2          `CPU_TOP.core0_pad_retire2
`define retire2_pc          `CPU_TOP.core0_pad_retire2_pc[39:0]
`define CPU_CLK             `CPU_TOP.pll_cpu_clk
`define CPU_RST             `CPU_TOP.pad_cpu_rst_b
`define clk_en              `CPU_TOP.axim_clk_en
`define CP0_RSLT_VLD        `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_iui.cp0_iu_ex3_rslt_vld
`define CP0_RSLT            `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_iui.cp0_iu_ex3_rslt_data[63:0]

`define mcycle_value   `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mcycle_value[63:0]
`define minstret_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.minstret_value[63:0]
`define event1_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event01_adder[3:0]
`define event2_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event02_adder[3:0]
`define event3_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event03_adder[3:0]
`define event4_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event04_adder[3:0]
`define event5_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event05_adder[3:0]
`define event6_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event06_adder[3:0]
`define event7_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event07_adder[3:0]
`define event8_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event08_adder[3:0]
`define event9_value  `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event09_adder[3:0]
`define event10_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event10_adder[3:0]
`define event11_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event11_adder[3:0]
`define event12_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event12_adder[3:0]
`define event13_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event13_adder[3:0]
`define event14_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event14_adder[3:0]
`define event15_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event15_adder[3:0]
`define event16_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event16_adder[3:0]
`define event17_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event17_adder[3:0]
`define event18_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event18_adder[3:0]
`define event19_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event19_adder[3:0]
`define event20_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event20_adder[3:0]
`define event21_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event21_adder[3:0]
`define event22_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event22_adder[3:0]
`define event23_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event23_adder[3:0]
`define event24_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event24_adder[3:0]
`define event25_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event25_adder[3:0]
`define event26_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event26_adder[3:0]
`define event27_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event27_adder[3:0]
`define event28_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event28_adder[3:0]
`define event29_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event29_adder[3:0]
`define event30_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event30_adder[3:0]
`define event31_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event31_adder[3:0]
`define event32_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event32_adder[3:0]
`define event33_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event33_adder[3:0]
`define event34_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event34_adder[3:0]
`define event35_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event35_adder[3:0]
`define event36_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event36_adder[3:0]
`define event37_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event37_adder[3:0]
`define event38_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event38_adder[3:0]
`define event39_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event39_adder[3:0]
`define event40_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event40_adder[3:0]
`define event41_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event41_adder[3:0]
`define event42_value `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.event42_adder[3:0]

`define CORE_TOP       `CPU_TOP.x_ct_top_0.x_ct_core
`define IFU_TOP        `CORE_TOP.x_ct_ifu_top
`define IDU_TOP        `CORE_TOP.x_ct_idu_top
`define IU_TOP         `CORE_TOP.x_ct_iu_top
`define LSU_TOP        `CORE_TOP.x_ct_lsu_top
`define RTU_TOP        `CORE_TOP.x_ct_rtu_top
`define IFU_IFCTRL     `IFU_TOP.x_ct_ifu_ifctrl
`define IFU_IBCTRL     `IFU_TOP.x_ct_ifu_ibctrl
`define IFU_IPCTRL     `IFU_TOP.x_ct_ifu_ipctrl
`define IFU_IBUF       `IFU_TOP.x_ct_ifu_ibuf
`define IFU_RAS        `IFU_TOP.x_ct_ifu_ras
`define IFU_BHT        `IFU_TOP.x_ct_ifu_bht
`define IFU_L1_REFILL  `IFU_TOP.x_ct_ifu_l1_refill
`define IDU_ID_CTRL    `IDU_TOP.x_ct_idu_id_ctrl
`define IDU_IR_CTRL    `IDU_TOP.x_ct_idu_ir_ctrl
`define IDU_IS_CTRL    `IDU_TOP.x_ct_idu_is_ctrl
`define IDU_RF_CTRL    `IDU_TOP.x_ct_idu_rf_ctrl
`define IDU_RF_DP      `IDU_TOP.x_ct_idu_rf_dp
`define IDU_IS_AIQ0    `IDU_TOP.x_ct_idu_is_aiq0
`define IDU_IS_AIQ1    `IDU_TOP.x_ct_idu_is_aiq1
`define IDU_IS_BIQ     `IDU_TOP.x_ct_idu_is_biq
`define IDU_IS_LSIQ    `IDU_TOP.x_ct_idu_is_lsiq
`define IDU_IS_SDIQ    `IDU_TOP.x_ct_idu_is_sdiq
`define IDU_IS_VIQ0    `IDU_TOP.x_ct_idu_is_viq0
`define IDU_IS_VIQ1    `IDU_TOP.x_ct_idu_is_viq1
`define LSU_LD_AG      `LSU_TOP.x_ct_lsu_ld_ag
`define LSU_ST_AG      `LSU_TOP.x_ct_lsu_st_ag
`define LSU_LD_DA      `LSU_TOP.x_ct_lsu_ld_da
`define LSU_ST_DA      `LSU_TOP.x_ct_lsu_st_da
`define LSU_LQ         `LSU_TOP.x_ct_lsu_lq
`define LSU_SQ         `LSU_TOP.x_ct_lsu_sq
`define LSU_RB         `LSU_TOP.x_ct_lsu_rb
`define LSU_LFB        `LSU_TOP.x_ct_lsu_lfb
`define LSU_WMB        `LSU_TOP.x_ct_lsu_wmb
`define LSU_VB         `LSU_TOP.x_ct_lsu_vb
`define LSU_PFU        `LSU_TOP.x_ct_lsu_pfu
`define LSU_DCA        `LSU_TOP.x_ct_lsu_dcache_arb
`define VFPU_TOP       `CORE_TOP.x_ct_vfpu_top
`define RTU_ROB        `RTU_TOP.x_ct_rtu_rob
`define RTU_ROB_RT     `RTU_ROB.x_ct_rtu_rob_rt
`define RTU_RETIRE     `RTU_TOP.x_ct_rtu_retire
`define RTU_PST_PREG   `RTU_TOP.x_ct_rtu_pst_preg
`define RTU_PST_EREG   `RTU_TOP.x_ct_rtu_pst_ereg
`define RTU_PST_FREG   `RTU_TOP.x_ct_rtu_pst_freg
`define MMU_TOP        `CPU_TOP.x_ct_top_0.x_ct_mmu_top
`define BIU_TOP        `CPU_TOP.x_ct_top_0.x_ct_biu_top
`define BIU_READ       `BIU_TOP.x_ct_biu_read_channel
`define BIU_WRITE      `BIU_TOP.x_ct_biu_write_channel

`define lpreg0_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r0_preg[6:0]
`define lpreg1_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r1_preg[6:0] 
`define lpreg2_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r2_preg[6:0] 
`define lpreg3_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r3_preg[6:0] 
`define lpreg4_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r4_preg[6:0] 
`define lpreg5_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r5_preg[6:0] 
`define lpreg6_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r6_preg[6:0] 
`define lpreg7_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r7_preg[6:0] 
`define lpreg8_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r8_preg[6:0] 
`define lpreg9_id  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r9_preg[6:0] 
`define lpreg10_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r10_preg[6:0] 
`define lpreg11_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r11_preg[6:0] 
`define lpreg12_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r12_preg[6:0] 
`define lpreg13_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r13_preg[6:0] 
`define lpreg14_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r14_preg[6:0] 
`define lpreg15_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r15_preg[6:0] 
`define lpreg16_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r16_preg[6:0] 
`define lpreg17_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r17_preg[6:0] 
`define lpreg18_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r18_preg[6:0] 
`define lpreg19_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r19_preg[6:0] 
`define lpreg20_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r20_preg[6:0] 
`define lpreg21_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r21_preg[6:0] 
`define lpreg22_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r22_preg[6:0] 
`define lpreg23_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r23_preg[6:0] 
`define lpreg24_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r24_preg[6:0] 
`define lpreg25_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r25_preg[6:0] 
`define lpreg26_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r26_preg[6:0] 
`define lpreg27_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r27_preg[6:0] 
`define lpreg28_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r28_preg[6:0] 
`define lpreg29_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r29_preg[6:0] 
`define lpreg30_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r30_preg[6:0] 
`define lpreg31_id `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_rtu_top.x_ct_rtu_pst_preg.r31_preg[6:0] 

`define preg1  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg1_reg_dout[63:0]
`define preg2  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg2_reg_dout[63:0]
`define preg3  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg3_reg_dout[63:0]
`define preg4  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg4_reg_dout[63:0]
`define preg5  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg5_reg_dout[63:0]
`define preg6  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg6_reg_dout[63:0]
`define preg7  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg7_reg_dout[63:0]
`define preg8  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg8_reg_dout[63:0]
`define preg9  `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg9_reg_dout[63:0]
`define preg10 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg10_reg_dout[63:0]
`define preg11 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg11_reg_dout[63:0]
`define preg12 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg12_reg_dout[63:0]
`define preg13 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg13_reg_dout[63:0]
`define preg14 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg14_reg_dout[63:0]
`define preg15 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg15_reg_dout[63:0]
`define preg16 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg16_reg_dout[63:0]
`define preg17 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg17_reg_dout[63:0]
`define preg18 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg18_reg_dout[63:0]
`define preg19 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg19_reg_dout[63:0]
`define preg20 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg20_reg_dout[63:0]
`define preg21 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg21_reg_dout[63:0]
`define preg22 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg22_reg_dout[63:0]
`define preg23 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg23_reg_dout[63:0]
`define preg24 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg24_reg_dout[63:0]
`define preg25 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg25_reg_dout[63:0]
`define preg26 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg26_reg_dout[63:0]
`define preg27 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg27_reg_dout[63:0]
`define preg28 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg28_reg_dout[63:0]
`define preg29 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg29_reg_dout[63:0]
`define preg30 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg30_reg_dout[63:0]
`define preg31 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg31_reg_dout[63:0]
`define preg32 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg32_reg_dout[63:0]
`define preg33 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg33_reg_dout[63:0]
`define preg34 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg34_reg_dout[63:0]
`define preg35 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg35_reg_dout[63:0]
`define preg36 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg36_reg_dout[63:0]
`define preg37 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg37_reg_dout[63:0]
`define preg38 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg38_reg_dout[63:0]
`define preg39 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg39_reg_dout[63:0]
`define preg40 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg40_reg_dout[63:0]
`define preg41 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg41_reg_dout[63:0]
`define preg42 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg42_reg_dout[63:0]
`define preg43 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg43_reg_dout[63:0]
`define preg44 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg44_reg_dout[63:0]
`define preg45 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg45_reg_dout[63:0]
`define preg46 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg46_reg_dout[63:0]
`define preg47 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg47_reg_dout[63:0]
`define preg48 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg48_reg_dout[63:0]
`define preg49 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg49_reg_dout[63:0]
`define preg50 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg50_reg_dout[63:0]
`define preg51 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg51_reg_dout[63:0]
`define preg52 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg52_reg_dout[63:0]
`define preg53 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg53_reg_dout[63:0]
`define preg54 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg54_reg_dout[63:0]
`define preg55 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg55_reg_dout[63:0]
`define preg56 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg56_reg_dout[63:0]
`define preg57 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg57_reg_dout[63:0]
`define preg58 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg58_reg_dout[63:0]
`define preg59 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg59_reg_dout[63:0]
`define preg60 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg60_reg_dout[63:0]
`define preg61 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg61_reg_dout[63:0]
`define preg62 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg62_reg_dout[63:0]
`define preg63 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg63_reg_dout[63:0]
`define preg64 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg64_reg_dout[63:0]
`define preg65 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg65_reg_dout[63:0]
`define preg66 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg66_reg_dout[63:0]
`define preg67 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg67_reg_dout[63:0]
`define preg68 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg68_reg_dout[63:0]
`define preg69 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg69_reg_dout[63:0]
`define preg70 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg70_reg_dout[63:0]
`define preg71 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg71_reg_dout[63:0]
`define preg72 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg72_reg_dout[63:0]
`define preg73 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg73_reg_dout[63:0]
`define preg74 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg74_reg_dout[63:0]
`define preg75 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg75_reg_dout[63:0]
`define preg76 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg76_reg_dout[63:0]
`define preg77 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg77_reg_dout[63:0]
`define preg78 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg78_reg_dout[63:0]
`define preg79 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg79_reg_dout[63:0]
`define preg80 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg80_reg_dout[63:0]
`define preg81 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg81_reg_dout[63:0]
`define preg82 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg82_reg_dout[63:0]
`define preg83 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg83_reg_dout[63:0]
`define preg84 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg84_reg_dout[63:0]
`define preg85 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg85_reg_dout[63:0]
`define preg86 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg86_reg_dout[63:0]
`define preg87 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg87_reg_dout[63:0]
`define preg88 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg88_reg_dout[63:0]
`define preg89 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg89_reg_dout[63:0]
`define preg90 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg90_reg_dout[63:0]
`define preg91 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg91_reg_dout[63:0]
`define preg92 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg92_reg_dout[63:0]
`define preg93 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg93_reg_dout[63:0]
`define preg94 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg94_reg_dout[63:0]
`define preg95 `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_rf_prf_pregfile.preg95_reg_dout[63:0]

// `define APB_BASE_ADDR       40'h4000000000
`define APB_BASE_ADDR       40'hb0000000

function automatic logic [3:0] get_event_value(int id);
  case(id)
     1: return `event1_value ;
     2: return `event2_value ;
     3: return `event3_value ;
     4: return `event4_value ;
     5: return `event5_value ;
     6: return `event6_value ;
     7: return `event7_value ;
     8: return `event8_value ;
     9: return `event9_value ;
    10: return `event10_value;
    11: return `event11_value;
    12: return `event12_value;
    13: return `event13_value;
    14: return `event14_value;
    15: return `event15_value;
    16: return `event16_value;
    17: return `event17_value;
    18: return `event18_value;
    19: return `event19_value;
    20: return `event20_value;
    21: return `event21_value;
    22: return `event22_value;
    23: return `event23_value;
    24: return `event24_value;
    25: return `event25_value;
    26: return `event26_value;
    27: return `event27_value;
    28: return `event28_value;
    29: return `event29_value;
    30: return `event30_value;
    31: return `event31_value;
    32: return `event32_value;
    33: return `event33_value;
    34: return `event34_value;
    35: return `event35_value;
    36: return `event36_value;
    37: return `event37_value;
    38: return `event38_value;
    39: return `event39_value;
    40: return `event40_value;
    41: return `event41_value;
    42: return `event42_value;
    default: return 4'b0;
  endcase
endfunction

function automatic logic [63:0] get_preg_value(input logic [6:0] lpreg_id);
  case (lpreg_id)
    7'd1:  return `preg1;
    7'd2:  return `preg2;
    7'd3:  return `preg3;
    7'd4:  return `preg4;
    7'd5:  return `preg5;
    7'd6:  return `preg6;
    7'd7:  return `preg7;
    7'd8:  return `preg8;
    7'd9:  return `preg9;
    7'd10: return `preg10;
    7'd11: return `preg11;
    7'd12: return `preg12;
    7'd13: return `preg13;
    7'd14: return `preg14;
    7'd15: return `preg15;
    7'd16: return `preg16;
    7'd17: return `preg17;
    7'd18: return `preg18;
    7'd19: return `preg19;
    7'd20: return `preg20;
    7'd21: return `preg21;
    7'd22: return `preg22;
    7'd23: return `preg23;
    7'd24: return `preg24;
    7'd25: return `preg25;
    7'd26: return `preg26;
    7'd27: return `preg27;
    7'd28: return `preg28;
    7'd29: return `preg29;
    7'd30: return `preg30;
    7'd31: return `preg31;
    7'd32: return `preg32;
    7'd33: return `preg33;
    7'd34: return `preg34;
    7'd35: return `preg35;
    7'd36: return `preg36;
    7'd37: return `preg37;
    7'd38: return `preg38;
    7'd39: return `preg39;
    7'd40: return `preg40;
    7'd41: return `preg41;
    7'd42: return `preg42;
    7'd43: return `preg43;
    7'd44: return `preg44;
    7'd45: return `preg45;
    7'd46: return `preg46;
    7'd47: return `preg47;
    7'd48: return `preg48;
    7'd49: return `preg49;
    7'd50: return `preg50;
    7'd51: return `preg51;
    7'd52: return `preg52;
    7'd53: return `preg53;
    7'd54: return `preg54;
    7'd55: return `preg55;
    7'd56: return `preg56;
    7'd57: return `preg57;
    7'd58: return `preg58;
    7'd59: return `preg59;
    7'd60: return `preg60;
    7'd61: return `preg61;
    7'd62: return `preg62;
    7'd63: return `preg63;
    7'd64: return `preg64;
    7'd65: return `preg65;
    7'd66: return `preg66;
    7'd67: return `preg67;
    7'd68: return `preg68;
    7'd69: return `preg69;
    7'd70: return `preg70;
    7'd71: return `preg71;
    7'd72: return `preg72;
    7'd73: return `preg73;
    7'd74: return `preg74;
    7'd75: return `preg75;
    7'd76: return `preg76;
    7'd77: return `preg77;
    7'd78: return `preg78;
    7'd79: return `preg79;
    7'd80: return `preg80;
    7'd81: return `preg81;
    7'd82: return `preg82;
    7'd83: return `preg83;
    7'd84: return `preg84;
    7'd85: return `preg85;
    7'd86: return `preg86;
    7'd87: return `preg87;
    7'd88: return `preg88;
    7'd89: return `preg89;
    7'd90: return `preg90;
    7'd91: return `preg91;
    7'd92: return `preg92;
    7'd93: return `preg93;
    7'd94: return `preg94;
    7'd95: return `preg95;
    default: return 64'h0;
  endcase
endfunction


module tb();
  reg clk;
  reg jclk;
  reg rst_b;
  reg jrst_b;
  reg jtap_en;
  wire jtg_tms;
  wire jtg_tdi;
  wire jtg_tdo;
  wire  pad_yy_gate_clk_en_b;
  
  static integer FILE;
  
  wire uart0_sin;
  wire [7:0]b_pad_gpio_porta;
  
  assign pad_yy_gate_clk_en_b = 1'b1;
  
  initial
  begin
    clk =0;
    forever begin
      #(`CLK_PERIOD/2) clk = ~clk;
    end
  end
  
  initial 
  begin 
    jclk = 0;
    forever begin
      #(`TCLK_PERIOD/2) jclk = ~jclk;
    end
  end
  
  initial
  begin
    rst_b = 1;
    #100;
    rst_b = 0;
    #100;
    rst_b = 1;
  end
  
  initial
  begin
    jrst_b = 1;
    #400;
    jrst_b = 0;
    #400;
    jrst_b = 1;
  end
 
  integer i;
  bit [31:0] mem_inst_temp [65536];
  bit [31:0] mem_data_temp [65536];
  integer j;
  string l3_ram_prefix;
  string l3_ram_file;
  reg l3_mode;
  initial
  begin
    $display("\t********* Init Program *********");
    $display("\t********* Wipe memory to 0 *********");
    for(i=0; i < 32'h16384; i=i+1)
    begin
      `RTL_MEM.ram0.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram1.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram2.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram3.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram4.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram5.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram6.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram7.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram8.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram9.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram10.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram11.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram12.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram13.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram14.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram15.mem[i][7:0] = 8'h0;
    end
  
    $display("\t********* Read program *********");
    $readmemh("inst.pat", mem_inst_temp);
    $readmemh("data.pat", mem_data_temp);
  
    $display("\t********* Load program to memory *********");
    i=0;
    for(j=0;i<32'h4000;i=j/4)
    begin
      `RTL_MEM.ram0.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram1.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram2.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram3.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram4.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram5.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram6.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram7.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram8.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram9.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram10.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram11.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram12.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram13.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram14.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram15.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
    end
    i=0;
    for(j=0;i<32'h4000;i=j/4)
    begin
      `RTL_MEM.ram0.mem[i+32'h4000][7:0]  = mem_data_temp[j][31:24];
      `RTL_MEM.ram1.mem[i+32'h4000][7:0]  = mem_data_temp[j][23:16];
      `RTL_MEM.ram2.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram3.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram4.mem[i+32'h4000][7:0]  = mem_data_temp[j][31:24];
      `RTL_MEM.ram5.mem[i+32'h4000][7:0]  = mem_data_temp[j][23:16];
      `RTL_MEM.ram6.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram7.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram8.mem[i+32'h4000][7:0]   = mem_data_temp[j][31:24];
      `RTL_MEM.ram9.mem[i+32'h4000][7:0]   = mem_data_temp[j][23:16];
      `RTL_MEM.ram10.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram11.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram12.mem[i+32'h4000][7:0]  = mem_data_temp[j][31:24];
      `RTL_MEM.ram13.mem[i+32'h4000][7:0]  = mem_data_temp[j][23:16];
      `RTL_MEM.ram14.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram15.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
    end
  end

  initial begin
    if ($value$plusargs("l3_ram_prefix=%s", l3_ram_prefix)) begin
      #1;
      $display("[L3] loading checkpoint SRAM lanes: %s", l3_ram_prefix);
      for (integer lane = 0; lane < 16; lane++) begin
        $sformat(l3_ram_file, "%s.ram%0d.hex", l3_ram_prefix, lane);
        case (lane)
          0:  $readmemh(l3_ram_file, `RTL_MEM.ram0.mem);
          1:  $readmemh(l3_ram_file, `RTL_MEM.ram1.mem);
          2:  $readmemh(l3_ram_file, `RTL_MEM.ram2.mem);
          3:  $readmemh(l3_ram_file, `RTL_MEM.ram3.mem);
          4:  $readmemh(l3_ram_file, `RTL_MEM.ram4.mem);
          5:  $readmemh(l3_ram_file, `RTL_MEM.ram5.mem);
          6:  $readmemh(l3_ram_file, `RTL_MEM.ram6.mem);
          7:  $readmemh(l3_ram_file, `RTL_MEM.ram7.mem);
          8:  $readmemh(l3_ram_file, `RTL_MEM.ram8.mem);
          9:  $readmemh(l3_ram_file, `RTL_MEM.ram9.mem);
          10: $readmemh(l3_ram_file, `RTL_MEM.ram10.mem);
          11: $readmemh(l3_ram_file, `RTL_MEM.ram11.mem);
          12: $readmemh(l3_ram_file, `RTL_MEM.ram12.mem);
          13: $readmemh(l3_ram_file, `RTL_MEM.ram13.mem);
          14: $readmemh(l3_ram_file, `RTL_MEM.ram14.mem);
          15: $readmemh(l3_ram_file, `RTL_MEM.ram15.mem);
        endcase
      end
    end
  end

  initial
  begin
  #(`MAX_RUN_TIME * `CLK_PERIOD);
    if (!l3_mode) begin
    $display("**********************************************");
    $display("  Error: Simulation Timeout (Max %0d cycles)!  ", `MAX_RUN_TIME);
    $display("**********************************************");
    FILE = $fopen("run_case.report","w");
    $fwrite(FILE, "TEST FAIL: Timeout after %d cycles", `MAX_RUN_TIME);

    $fclose(FILE); 
    $finish;
    end
  end

  real cpi =0.0;
  real ipc =0.0;
  real main_cpi =0.0;
  real main_ipc =0.0;
  real kernel_cpi =0.0;
  real kernel_ipc =0.0;
  reg [63:0] main_retire_inst_count_start;
  reg [63:0] main_retire_inst_count_end;
  reg [63:0] main_cycle_count_start;
  reg [63:0] main_cycle_count_end;
  reg [63:0] kernel_retire_inst_count_start;
  reg [63:0] kernel_retire_inst_count_end;
  reg [63:0] kernel_cycle_count_start;
  reg [63:0] kernel_cycle_count_end;
  reg [39:0] sym_main_addr;
  reg [39:0] sym_exit_addr;
  reg [39:0] sym_perf_start_addr;
  reg [39:0] sym_perf_end_addr;

  initial begin
    sym_main_addr       = `main_ADDR;
    sym_exit_addr       = `__exit_ADDR;
    sym_perf_start_addr = `perf_monitor_start_ADDR;
    sym_perf_end_addr   = `perf_monitor_end_ADDR;

    if ($value$plusargs("sym_main=%h", sym_main_addr))
      $display("[sym] main override: 0x%010h", sym_main_addr);
    if ($value$plusargs("sym_exit=%h", sym_exit_addr))
      $display("[sym] exit override: 0x%010h", sym_exit_addr);
    if ($value$plusargs("sym_perf_start=%h", sym_perf_start_addr))
      $display("[sym] perf_start override: 0x%010h", sym_perf_start_addr);
    if ($value$plusargs("sym_perf_end=%h", sym_perf_end_addr))
      $display("[sym] perf_end override: 0x%010h", sym_perf_end_addr);
  end

  parameter NUM = 42; 
  reg [3:0]  event_n_delay[NUM:1]; 
  reg [63:0] event_counter[NUM:1];
  reg [63:0] main_event_counter_start[NUM:1];
  reg [63:0] main_event_counter_end[NUM:1];
  reg [63:0] kernel_event_counter_start[NUM:1];
  reg [63:0] kernel_event_counter_end[NUM:1];

  reg l3_active;
  reg l3_measure_active;
  reg [39:0] l3_start_pc;
  reg [63:0] l3_warmup_instructions;
  reg [63:0] l3_roi_instructions;
  reg [63:0] l3_max_cycles;
  reg [63:0] l3_user_retired;
  reg [63:0] l3_roi_retired;
  reg [63:0] l3_cycle_start;
  reg [63:0] l3_event_start[NUM:1];
  string l3_checkpoint_id;
  wire [2:0] l3_retire_width = {2'b0, `tb_retire0}
                               + {2'b0, `tb_retire1}
                               + {2'b0, `tb_retire2};
  wire l3_start_hit0 = `tb_retire0 && (`retire0_pc == l3_start_pc);
  wire l3_start_hit1 = `tb_retire1 && (`retire1_pc == l3_start_pc);
  wire l3_start_hit2 = `tb_retire2 && (`retire2_pc == l3_start_pc);
  wire [2:0] l3_start_retire_width =
      l3_start_hit0 ? ({2'b0, `tb_retire0} + {2'b0, `tb_retire1}
                       + {2'b0, `tb_retire2}) :
      l3_start_hit1 ? ({2'b0, `tb_retire1} + {2'b0, `tb_retire2}) :
      l3_start_hit2 ? {2'b0, `tb_retire2} : 3'b0;

`ifdef PERF_DETAIL
  parameter DETAIL_NUM = 805;
  parameter PROF_NUM   = 189;
  parameter LAT_NUM    = 54;
  parameter LAT_BUCKET_NUM = 6;
  reg        detail_n_delay[DETAIL_NUM:1];
  reg [63:0] detail_counter[DETAIL_NUM:1];
  reg [63:0] main_detail_counter_start[DETAIL_NUM:1];
  reg [63:0] main_detail_counter_end[DETAIL_NUM:1];
  reg [63:0] kernel_detail_counter_start[DETAIL_NUM:1];
  reg [63:0] kernel_detail_counter_end[DETAIL_NUM:1];
  reg [63:0] prof_sum_counter[PROF_NUM:1];
  reg [63:0] main_prof_sum_start[PROF_NUM:1];
  reg [63:0] main_prof_sum_end[PROF_NUM:1];
  reg [63:0] kernel_prof_sum_start[PROF_NUM:1];
  reg [63:0] kernel_prof_sum_end[PROF_NUM:1];
  reg [63:0] lat_sample_counter[LAT_NUM:1];
  reg [63:0] lat_sum_counter[LAT_NUM:1];
  reg [63:0] lat_bucket_counter[LAT_NUM:1][LAT_BUCKET_NUM:1];
  reg [63:0] main_lat_sample_start[LAT_NUM:1];
  reg [63:0] main_lat_sample_end[LAT_NUM:1];
  reg [63:0] main_lat_sum_start[LAT_NUM:1];
  reg [63:0] main_lat_sum_end[LAT_NUM:1];
  reg [63:0] main_lat_bucket_start[LAT_NUM:1][LAT_BUCKET_NUM:1];
  reg [63:0] main_lat_bucket_end[LAT_NUM:1][LAT_BUCKET_NUM:1];
  reg [63:0] kernel_lat_sample_start[LAT_NUM:1];
  reg [63:0] kernel_lat_sample_end[LAT_NUM:1];
  reg [63:0] kernel_lat_sum_start[LAT_NUM:1];
  reg [63:0] kernel_lat_sum_end[LAT_NUM:1];
  reg [63:0] kernel_lat_bucket_start[LAT_NUM:1][LAT_BUCKET_NUM:1];
  reg [63:0] kernel_lat_bucket_end[LAT_NUM:1][LAT_BUCKET_NUM:1];
  reg [63:0] l3_detail_start[DETAIL_NUM:1];
  reg [63:0] l3_prof_start[PROF_NUM:1];
  reg [63:0] l3_lat_sample_start[LAT_NUM:1];
  reg [63:0] l3_lat_sum_start[LAT_NUM:1];
  reg [63:0] l3_lat_bucket_start[LAT_NUM:1][LAT_BUCKET_NUM:1];
  reg        ic_refill_lat_active;
  reg [31:0] ic_refill_lat_age;
  reg        biu_read_lat_active;
  reg [31:0] biu_read_lat_age;
  reg        biu_write_lat_active;
  reg [31:0] biu_write_lat_age;
  reg        lfb_refill_lat_active;
  reg [31:0] lfb_refill_lat_age;
  reg        dutlb_lat_active;
  reg [31:0] dutlb_lat_age;
  reg        iutlb_lat_active;
  reg [31:0] iutlb_lat_age;
  reg        ptw_lat_active;
  reg [31:0] ptw_lat_age;
  reg        extra_lat_active[LAT_NUM:1];
  reg [31:0] extra_lat_age[LAT_NUM:1];
  reg [7:0]  biu_rd_outstanding;
  reg [7:0]  biu_wr_outstanding;

  typedef bit [39:0] perf_pc_t;
  reg branch_pc_main_active;
  reg branch_pc_kernel_active;
  longint unsigned main_cond_exec_by_pc[perf_pc_t];
  longint unsigned main_cond_misp_by_pc[perf_pc_t];
  longint unsigned main_jmp_exec_by_pc[perf_pc_t];
  longint unsigned main_jmp_misp_by_pc[perf_pc_t];
  longint unsigned main_call_misp_by_pc[perf_pc_t];
  longint unsigned main_return_misp_by_pc[perf_pc_t];
  longint unsigned main_other_jmp_misp_by_pc[perf_pc_t];
  longint unsigned kernel_cond_exec_by_pc[perf_pc_t];
  longint unsigned kernel_cond_misp_by_pc[perf_pc_t];
  longint unsigned kernel_jmp_exec_by_pc[perf_pc_t];
  longint unsigned kernel_jmp_misp_by_pc[perf_pc_t];
  longint unsigned kernel_call_misp_by_pc[perf_pc_t];
  longint unsigned kernel_return_misp_by_pc[perf_pc_t];
  longint unsigned kernel_other_jmp_misp_by_pc[perf_pc_t];

  wire branch_pc_main_start = (`tb_retire0 && (`retire0_pc == sym_main_addr))
                           || (`tb_retire1 && (`retire1_pc == sym_main_addr))
                           || (`tb_retire2 && (`retire2_pc == sym_main_addr));
  wire branch_pc_main_end = (`tb_retire0 && (`retire0_pc == sym_exit_addr))
                         || (`tb_retire1 && (`retire1_pc == sym_exit_addr))
                         || (`tb_retire2 && (`retire2_pc == sym_exit_addr));
  wire branch_pc_kernel_start = (sym_perf_start_addr != 40'b0)
                             && ((`tb_retire0 && (`retire0_pc == sym_perf_start_addr))
                              || (`tb_retire1 && (`retire1_pc == sym_perf_start_addr))
                              || (`tb_retire2 && (`retire2_pc == sym_perf_start_addr)));
  wire branch_pc_kernel_end = (sym_perf_end_addr != 40'b0)
                           && ((`tb_retire0 && (`retire0_pc == sym_perf_end_addr))
                            || (`tb_retire1 && (`retire1_pc == sym_perf_end_addr))
                            || (`tb_retire2 && (`retire2_pc == sym_perf_end_addr)));

  task automatic record_branch_pc(input bit use_kernel,
                                  input bit is_cond,
                                  input bit is_jmp,
                                  input bit is_bht_misp,
                                  input bit is_jmp_misp,
                                  input bit is_call,
                                  input bit is_return,
                                  input perf_pc_t pc);
  begin
    if (use_kernel) begin
      if (is_cond) begin
        if (kernel_cond_exec_by_pc.exists(pc))
          kernel_cond_exec_by_pc[pc] = kernel_cond_exec_by_pc[pc] + 64'd1;
        else
          kernel_cond_exec_by_pc[pc] = 64'd1;
        if (is_bht_misp) begin
          if (kernel_cond_misp_by_pc.exists(pc))
            kernel_cond_misp_by_pc[pc] = kernel_cond_misp_by_pc[pc] + 64'd1;
          else
            kernel_cond_misp_by_pc[pc] = 64'd1;
        end
      end
      if (is_jmp) begin
        if (kernel_jmp_exec_by_pc.exists(pc))
          kernel_jmp_exec_by_pc[pc] = kernel_jmp_exec_by_pc[pc] + 64'd1;
        else
          kernel_jmp_exec_by_pc[pc] = 64'd1;
        if (is_jmp_misp) begin
          if (kernel_jmp_misp_by_pc.exists(pc))
            kernel_jmp_misp_by_pc[pc] = kernel_jmp_misp_by_pc[pc] + 64'd1;
          else
            kernel_jmp_misp_by_pc[pc] = 64'd1;
          if (is_return) begin
            if (kernel_return_misp_by_pc.exists(pc))
              kernel_return_misp_by_pc[pc] = kernel_return_misp_by_pc[pc] + 64'd1;
            else
              kernel_return_misp_by_pc[pc] = 64'd1;
          end
          else if (is_call) begin
            if (kernel_call_misp_by_pc.exists(pc))
              kernel_call_misp_by_pc[pc] = kernel_call_misp_by_pc[pc] + 64'd1;
            else
              kernel_call_misp_by_pc[pc] = 64'd1;
          end
          else begin
            if (kernel_other_jmp_misp_by_pc.exists(pc))
              kernel_other_jmp_misp_by_pc[pc] = kernel_other_jmp_misp_by_pc[pc] + 64'd1;
            else
              kernel_other_jmp_misp_by_pc[pc] = 64'd1;
          end
        end
      end
    end
    else begin
      if (is_cond) begin
        if (main_cond_exec_by_pc.exists(pc))
          main_cond_exec_by_pc[pc] = main_cond_exec_by_pc[pc] + 64'd1;
        else
          main_cond_exec_by_pc[pc] = 64'd1;
        if (is_bht_misp) begin
          if (main_cond_misp_by_pc.exists(pc))
            main_cond_misp_by_pc[pc] = main_cond_misp_by_pc[pc] + 64'd1;
          else
            main_cond_misp_by_pc[pc] = 64'd1;
        end
      end
      if (is_jmp) begin
        if (main_jmp_exec_by_pc.exists(pc))
          main_jmp_exec_by_pc[pc] = main_jmp_exec_by_pc[pc] + 64'd1;
        else
          main_jmp_exec_by_pc[pc] = 64'd1;
        if (is_jmp_misp) begin
          if (main_jmp_misp_by_pc.exists(pc))
            main_jmp_misp_by_pc[pc] = main_jmp_misp_by_pc[pc] + 64'd1;
          else
            main_jmp_misp_by_pc[pc] = 64'd1;
          if (is_return) begin
            if (main_return_misp_by_pc.exists(pc))
              main_return_misp_by_pc[pc] = main_return_misp_by_pc[pc] + 64'd1;
            else
              main_return_misp_by_pc[pc] = 64'd1;
          end
          else if (is_call) begin
            if (main_call_misp_by_pc.exists(pc))
              main_call_misp_by_pc[pc] = main_call_misp_by_pc[pc] + 64'd1;
            else
              main_call_misp_by_pc[pc] = 64'd1;
          end
          else begin
            if (main_other_jmp_misp_by_pc.exists(pc))
              main_other_jmp_misp_by_pc[pc] = main_other_jmp_misp_by_pc[pc] + 64'd1;
            else
              main_other_jmp_misp_by_pc[pc] = 64'd1;
          end
        end
      end
    end
  end
  endtask

  function automatic [7:0] popcount64(input logic [63:0] value);
    int idx;
  begin
    popcount64 = 8'b0;
    for (idx = 0; idx < 64; idx++) begin
      popcount64 = popcount64 + {7'b0, value[idx]};
    end
  end
  endfunction

  function automatic [3:0] id_width();
  begin
    id_width = {3'b0, `IDU_TOP.idu_had_debug_info[0]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[1]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[2]};
  end
  endfunction

  function automatic [3:0] ir_width();
  begin
    ir_width = {3'b0, `IDU_TOP.idu_had_debug_info[6]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[7]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[8]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[9]};
  end
  endfunction

  function automatic [3:0] is_width();
  begin
    is_width = {3'b0, `IDU_TOP.idu_had_debug_info[14]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[15]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[16]}
             + {3'b0, `IDU_TOP.idu_had_debug_info[17]};
  end
  endfunction

  function automatic [3:0] rf_launch_width();
  begin
    rf_launch_width = {3'b0, `IDU_TOP.idu_hpcp_rf_pipe0_inst_vld}
                    + {3'b0, `IDU_TOP.idu_hpcp_rf_pipe1_inst_vld}
                    + {3'b0, `IDU_TOP.idu_hpcp_rf_pipe2_inst_vld}
                    + {3'b0, `IDU_TOP.idu_hpcp_rf_pipe3_inst_vld}
                    + {3'b0, `IDU_TOP.idu_hpcp_rf_pipe4_inst_vld}
                    + {3'b0, `IDU_TOP.idu_hpcp_rf_pipe5_inst_vld}
                    + {3'b0, `IDU_TOP.idu_hpcp_rf_pipe6_inst_vld}
                    + {3'b0, `IDU_TOP.idu_hpcp_rf_pipe7_inst_vld};
  end
  endfunction

  function automatic [3:0] retire_width();
  begin
    retire_width = {3'b0, `tb_retire0}
                 + {3'b0, `tb_retire1}
                 + {3'b0, `tb_retire2};
  end
  endfunction

  function automatic [2:0] retire_slot_sum(input logic slot0,
                                           input logic slot1,
                                           input logic slot2);
  begin
    retire_slot_sum = {2'b0, slot0} + {2'b0, slot1} + {2'b0, slot2};
  end
  endfunction

  function automatic [2:0] four_slot_sum(input logic slot0,
                                         input logic slot1,
                                         input logic slot2,
                                         input logic slot3);
  begin
    four_slot_sum = {2'b0, slot0} + {2'b0, slot1}
                  + {2'b0, slot2} + {2'b0, slot3};
  end
  endfunction

  function automatic [7:0] dispatch_create_width();
  begin
    dispatch_create_width = {7'b0, `IDU_IS_CTRL.ctrl_aiq0_create0_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_aiq0_create1_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_aiq1_create0_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_aiq1_create1_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_biq_create0_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_biq_create1_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_lsiq_create0_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_lsiq_create1_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_sdiq_create0_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_sdiq_create1_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_viq0_create0_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_viq0_create1_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_viq1_create0_en}
                          + {7'b0, `IDU_IS_CTRL.ctrl_viq1_create1_en};
  end
  endfunction

  function automatic [7:0] iq_pop_width();
  begin
    iq_pop_width = {7'b0, `IDU_RF_CTRL.ctrl_aiq0_rf_pop_vld}
                 + {7'b0, `IDU_RF_CTRL.ctrl_aiq1_rf_pop_vld}
                 + {7'b0, `IDU_RF_CTRL.ctrl_biq_rf_pop_vld}
                 + {7'b0, `IDU_TOP.lsu_idu_lsiq_pop_vld}
                 + {7'b0, `IDU_TOP.lsu_idu_ex1_sdiq_pop_vld}
                 + {7'b0, `IDU_RF_CTRL.ctrl_viq0_rf_pop_vld}
                 + {7'b0, `IDU_RF_CTRL.ctrl_viq1_rf_pop_vld};
  end
  endfunction

  function automatic [7:0] rob_commit_width();
  begin
    rob_commit_width = {7'b0, `RTU_ROB_RT.rob_commit0}
                     + {7'b0, `RTU_ROB_RT.rob_commit1}
                     + {7'b0, `RTU_ROB_RT.rob_commit2};
  end
  endfunction

  function automatic [7:0] iq_ready_width();
  begin
    iq_ready_width = popcount64({56'b0, `IDU_IS_AIQ0.aiq0_entry_ready[7:0]})
                   + popcount64({56'b0, `IDU_IS_AIQ1.aiq1_entry_ready[7:0]})
                   + popcount64({52'b0, `IDU_IS_BIQ.biq_entry_ready[11:0]})
                   + popcount64({52'b0, `IDU_IS_LSIQ.lsiq_entry_ready[11:0]})
                   + popcount64({52'b0, `IDU_IS_SDIQ.sdiq_entry_ready[11:0]})
                   + popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_ready[7:0]})
                   + popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_ready[7:0]});
  end
  endfunction

  function automatic [7:0] iq_valid_not_ready_width();
  begin
    iq_valid_not_ready_width = popcount64({56'b0, (`IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0])})
                             + popcount64({56'b0, (`IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0])})
                             + popcount64({52'b0, (`IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0])})
                             + popcount64({52'b0, (`IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0])})
                             + popcount64({52'b0, (`IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0])})
                             + popcount64({56'b0, (`IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0])})
                             + popcount64({56'b0, (`IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0])});
  end
  endfunction

  function automatic [7:0] aiq0_src0_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.src0_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.src0_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.src0_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.src0_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.src0_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.src0_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.src0_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.src0_rdy_for_issue};
    aiq0_src0_not_ready_width = popcount64({56'b0, `IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] aiq0_src1_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.src1_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.src1_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.src1_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.src1_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.src1_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.src1_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.src1_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.src1_rdy_for_issue};
    aiq0_src1_not_ready_width = popcount64({56'b0, `IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] aiq0_src2_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.src2_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.src2_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.src2_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.src2_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.src2_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.src2_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.src2_rdy_for_issue,
                    `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.src2_rdy_for_issue};
    aiq0_src2_not_ready_width = popcount64({56'b0, `IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] aiq1_src0_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.src0_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.src0_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.src0_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.src0_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.src0_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.src0_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.src0_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.src0_rdy_for_issue};
    aiq1_src0_not_ready_width = popcount64({56'b0, `IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] aiq1_src1_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.src1_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.src1_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.src1_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.src1_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.src1_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.src1_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.src1_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.src1_rdy_for_issue};
    aiq1_src1_not_ready_width = popcount64({56'b0, `IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] aiq1_src2_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.src2_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.src2_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.src2_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.src2_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.src2_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.src2_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.src2_rdy_for_issue,
                    `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.src2_rdy_for_issue};
    aiq1_src2_not_ready_width = popcount64({56'b0, `IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] biq_src0_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_BIQ.x_ct_idu_is_biq_entry11.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry10.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry9.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry8.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry7.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry6.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry5.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry4.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry3.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry2.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry1.src0_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry0.src0_rdy_for_issue};
    biq_src0_not_ready_width = popcount64({52'b0, `IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] biq_src1_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_BIQ.x_ct_idu_is_biq_entry11.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry10.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry9.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry8.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry7.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry6.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry5.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry4.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry3.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry2.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry1.src1_rdy_for_issue,
                    `IDU_IS_BIQ.x_ct_idu_is_biq_entry0.src1_rdy_for_issue};
    biq_src1_not_ready_width = popcount64({52'b0, `IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] lsiq_src0_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.src0_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.src0_rdy_for_issue};
    lsiq_src0_not_ready_width = popcount64({52'b0, `IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] lsiq_src1_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.src1_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.src1_rdy_for_issue};
    lsiq_src1_not_ready_width = popcount64({52'b0, `IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] lsiq_srcvm_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.srcvm_rdy_for_issue,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.srcvm_rdy_for_issue};
    lsiq_srcvm_not_ready_width = popcount64({52'b0, `IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] sdiq_src0_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.src0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.src0_rdy_for_issue};
    sdiq_src0_not_ready_width = popcount64({52'b0, `IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] sdiq_srcv0_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.srcv0_rdy_for_issue,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.srcv0_rdy_for_issue};
    sdiq_srcv0_not_ready_width = popcount64({52'b0, `IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] sdiq_staddr_not_ready_width();
    logic [11:0] src_not_rdy;
  begin
    src_not_rdy = {(!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.staddr1_rdy))),
                   (!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.load && ((!`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.staddr0_rdy) || (`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.stdata1_vld && !`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.staddr1_rdy)))};
    sdiq_staddr_not_ready_width = popcount64({52'b0, `IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq0_srcv0_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcv0_rdy_for_issue};
    viq0_srcv0_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq0_srcv1_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcv1_rdy_for_issue};
    viq0_srcv1_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq0_srcv2_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcv2_rdy_for_issue};
    viq0_srcv2_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq0_srcvm_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcvm_rdy_for_issue};
    viq0_srcvm_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq1_srcv0_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcv0_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcv0_rdy_for_issue};
    viq1_srcv0_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq1_srcv1_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcv1_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcv1_rdy_for_issue};
    viq1_srcv1_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq1_srcv2_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcv2_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcv2_rdy_for_issue};
    viq1_srcv2_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] viq1_srcvm_not_ready_width();
    logic [7:0] src_not_rdy;
  begin
    src_not_rdy = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcvm_rdy_for_issue,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcvm_rdy_for_issue};
    viq1_srcvm_not_ready_width = popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0] & src_not_rdy});
  end
  endfunction

  function automatic [7:0] aiq0_load_dep_not_ready_width();
    logic [7:0] entry_wait;
    logic [7:0] src0_load;
    logic [7:0] src1_load;
    logic [7:0] src2_load;
  begin
    entry_wait = `IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0];
    src0_load = ~{`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.src0_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.src0_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.src0_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.src0_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.src0_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.src0_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.src0_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.src0_rdy_for_issue}
                & {`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.x_ct_idu_is_aiq0_src0_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.x_ct_idu_is_aiq0_src0_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.x_ct_idu_is_aiq0_src0_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.x_ct_idu_is_aiq0_src0_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.x_ct_idu_is_aiq0_src0_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.x_ct_idu_is_aiq0_src0_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.x_ct_idu_is_aiq0_src0_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.x_ct_idu_is_aiq0_src0_entry.lsu_match};
    src1_load = ~{`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.src1_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.src1_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.src1_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.src1_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.src1_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.src1_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.src1_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.src1_rdy_for_issue}
                & {`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.x_ct_idu_is_aiq0_src1_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.x_ct_idu_is_aiq0_src1_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.x_ct_idu_is_aiq0_src1_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.x_ct_idu_is_aiq0_src1_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.x_ct_idu_is_aiq0_src1_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.x_ct_idu_is_aiq0_src1_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.x_ct_idu_is_aiq0_src1_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.x_ct_idu_is_aiq0_src1_entry.lsu_match};
    src2_load = ~{`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.src2_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.src2_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.src2_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.src2_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.src2_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.src2_rdy_for_issue,
                  `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.src2_rdy_for_issue, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.src2_rdy_for_issue}
                & {`IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry7.x_ct_idu_is_aiq0_src2_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry6.x_ct_idu_is_aiq0_src2_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry5.x_ct_idu_is_aiq0_src2_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry4.x_ct_idu_is_aiq0_src2_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry3.x_ct_idu_is_aiq0_src2_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry2.x_ct_idu_is_aiq0_src2_entry.lsu_match,
                   `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry1.x_ct_idu_is_aiq0_src2_entry.lsu_match, `IDU_IS_AIQ0.x_ct_idu_is_aiq0_entry0.x_ct_idu_is_aiq0_src2_entry.lsu_match};
    aiq0_load_dep_not_ready_width = popcount64({56'b0, entry_wait & src0_load})
                                  + popcount64({56'b0, entry_wait & src1_load})
                                  + popcount64({56'b0, entry_wait & src2_load});
  end
  endfunction

  function automatic [7:0] aiq0_nonload_dep_not_ready_width();
  begin
    aiq0_nonload_dep_not_ready_width = aiq0_src0_not_ready_width()
                                     + aiq0_src1_not_ready_width()
                                     + aiq0_src2_not_ready_width()
                                     - aiq0_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] aiq1_load_dep_not_ready_width();
    logic [7:0] entry_wait;
    logic [7:0] src0_load;
    logic [7:0] src1_load;
    logic [7:0] src2_load;
  begin
    entry_wait = `IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0];
    src0_load = ~{`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.src0_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.src0_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.src0_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.src0_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.src0_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.src0_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.src0_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.src0_rdy_for_issue}
                & {`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.x_ct_idu_is_aiq1_src0_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.x_ct_idu_is_aiq1_src0_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.x_ct_idu_is_aiq1_src0_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.x_ct_idu_is_aiq1_src0_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.x_ct_idu_is_aiq1_src0_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.x_ct_idu_is_aiq1_src0_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.x_ct_idu_is_aiq1_src0_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.x_ct_idu_is_aiq1_src0_entry.lsu_match};
    src1_load = ~{`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.src1_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.src1_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.src1_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.src1_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.src1_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.src1_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.src1_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.src1_rdy_for_issue}
                & {`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.x_ct_idu_is_aiq1_src1_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.x_ct_idu_is_aiq1_src1_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.x_ct_idu_is_aiq1_src1_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.x_ct_idu_is_aiq1_src1_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.x_ct_idu_is_aiq1_src1_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.x_ct_idu_is_aiq1_src1_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.x_ct_idu_is_aiq1_src1_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.x_ct_idu_is_aiq1_src1_entry.lsu_match};
    src2_load = ~{`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.src2_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.src2_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.src2_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.src2_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.src2_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.src2_rdy_for_issue,
                  `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.src2_rdy_for_issue, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.src2_rdy_for_issue}
                & {`IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry7.x_ct_idu_is_aiq1_src2_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry6.x_ct_idu_is_aiq1_src2_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry5.x_ct_idu_is_aiq1_src2_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry4.x_ct_idu_is_aiq1_src2_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry3.x_ct_idu_is_aiq1_src2_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry2.x_ct_idu_is_aiq1_src2_entry.lsu_match,
                   `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry1.x_ct_idu_is_aiq1_src2_entry.lsu_match, `IDU_IS_AIQ1.x_ct_idu_is_aiq1_entry0.x_ct_idu_is_aiq1_src2_entry.lsu_match};
    aiq1_load_dep_not_ready_width = popcount64({56'b0, entry_wait & src0_load})
                                  + popcount64({56'b0, entry_wait & src1_load})
                                  + popcount64({56'b0, entry_wait & src2_load});
  end
  endfunction

  function automatic [7:0] aiq1_nonload_dep_not_ready_width();
  begin
    aiq1_nonload_dep_not_ready_width = aiq1_src0_not_ready_width()
                                     + aiq1_src1_not_ready_width()
                                     + aiq1_src2_not_ready_width()
                                     - aiq1_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] biq_load_dep_not_ready_width();
    logic [11:0] entry_wait;
    logic [11:0] src0_load;
    logic [11:0] src1_load;
  begin
    entry_wait = `IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0];
    src0_load = ~{`IDU_IS_BIQ.x_ct_idu_is_biq_entry11.src0_rdy_for_issue, `IDU_IS_BIQ.x_ct_idu_is_biq_entry10.src0_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry9.src0_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry8.src0_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry7.src0_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry6.src0_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry5.src0_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry4.src0_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry3.src0_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry2.src0_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry1.src0_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry0.src0_rdy_for_issue}
                & {`IDU_IS_BIQ.x_ct_idu_is_biq_entry11.x_ct_idu_is_biq_src0_entry.lsu_match, `IDU_IS_BIQ.x_ct_idu_is_biq_entry10.x_ct_idu_is_biq_src0_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry9.x_ct_idu_is_biq_src0_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry8.x_ct_idu_is_biq_src0_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry7.x_ct_idu_is_biq_src0_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry6.x_ct_idu_is_biq_src0_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry5.x_ct_idu_is_biq_src0_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry4.x_ct_idu_is_biq_src0_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry3.x_ct_idu_is_biq_src0_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry2.x_ct_idu_is_biq_src0_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry1.x_ct_idu_is_biq_src0_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry0.x_ct_idu_is_biq_src0_entry.lsu_match};
    src1_load = ~{`IDU_IS_BIQ.x_ct_idu_is_biq_entry11.src1_rdy_for_issue, `IDU_IS_BIQ.x_ct_idu_is_biq_entry10.src1_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry9.src1_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry8.src1_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry7.src1_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry6.src1_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry5.src1_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry4.src1_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry3.src1_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry2.src1_rdy_for_issue,
                  `IDU_IS_BIQ.x_ct_idu_is_biq_entry1.src1_rdy_for_issue,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry0.src1_rdy_for_issue}
                & {`IDU_IS_BIQ.x_ct_idu_is_biq_entry11.x_ct_idu_is_biq_src1_entry.lsu_match, `IDU_IS_BIQ.x_ct_idu_is_biq_entry10.x_ct_idu_is_biq_src1_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry9.x_ct_idu_is_biq_src1_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry8.x_ct_idu_is_biq_src1_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry7.x_ct_idu_is_biq_src1_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry6.x_ct_idu_is_biq_src1_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry5.x_ct_idu_is_biq_src1_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry4.x_ct_idu_is_biq_src1_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry3.x_ct_idu_is_biq_src1_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry2.x_ct_idu_is_biq_src1_entry.lsu_match,
                   `IDU_IS_BIQ.x_ct_idu_is_biq_entry1.x_ct_idu_is_biq_src1_entry.lsu_match,  `IDU_IS_BIQ.x_ct_idu_is_biq_entry0.x_ct_idu_is_biq_src1_entry.lsu_match};
    biq_load_dep_not_ready_width = popcount64({52'b0, entry_wait & src0_load})
                                 + popcount64({52'b0, entry_wait & src1_load});
  end
  endfunction

  function automatic [7:0] biq_nonload_dep_not_ready_width();
  begin
    biq_nonload_dep_not_ready_width = biq_src0_not_ready_width()
                                    + biq_src1_not_ready_width()
                                    - biq_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] lsiq_load_dep_not_ready_width();
    logic [11:0] entry_wait;
    logic [11:0] src0_load;
    logic [11:0] src1_load;
    logic [11:0] srcvm_load;
  begin
    entry_wait = `IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0];
    src0_load = ~{`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.src0_rdy_for_issue, `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.src0_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.src0_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.src0_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.src0_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.src0_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.src0_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.src0_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.src0_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.src0_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.src0_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.src0_rdy_for_issue}
                & {`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.x_ct_idu_is_lsiq_src0_entry.lsu_match, `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.x_ct_idu_is_lsiq_src0_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.x_ct_idu_is_lsiq_src0_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.x_ct_idu_is_lsiq_src0_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.x_ct_idu_is_lsiq_src0_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.x_ct_idu_is_lsiq_src0_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.x_ct_idu_is_lsiq_src0_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.x_ct_idu_is_lsiq_src0_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.x_ct_idu_is_lsiq_src0_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.x_ct_idu_is_lsiq_src0_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.x_ct_idu_is_lsiq_src0_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.x_ct_idu_is_lsiq_src0_entry.lsu_match};
    src1_load = ~{`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.src1_rdy_for_issue, `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.src1_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.src1_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.src1_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.src1_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.src1_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.src1_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.src1_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.src1_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.src1_rdy_for_issue,
                  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.src1_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.src1_rdy_for_issue}
                & {`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.x_ct_idu_is_lsiq_src1_entry.lsu_match, `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.x_ct_idu_is_lsiq_src1_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.x_ct_idu_is_lsiq_src1_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.x_ct_idu_is_lsiq_src1_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.x_ct_idu_is_lsiq_src1_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.x_ct_idu_is_lsiq_src1_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.x_ct_idu_is_lsiq_src1_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.x_ct_idu_is_lsiq_src1_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.x_ct_idu_is_lsiq_src1_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.x_ct_idu_is_lsiq_src1_entry.lsu_match,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.x_ct_idu_is_lsiq_src1_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.x_ct_idu_is_lsiq_src1_entry.lsu_match};
    srcvm_load = ~{`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.srcvm_rdy_for_issue, `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.srcvm_rdy_for_issue,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.srcvm_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.srcvm_rdy_for_issue,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.srcvm_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.srcvm_rdy_for_issue,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.srcvm_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.srcvm_rdy_for_issue,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.srcvm_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.srcvm_rdy_for_issue,
                   `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.srcvm_rdy_for_issue,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.srcvm_rdy_for_issue}
                 & {`IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry11.x_ct_idu_is_lsiq_srcvm_entry.lsu_match, `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry10.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry9.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry8.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry7.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry6.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry5.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry4.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry3.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry2.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,
                    `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry1.x_ct_idu_is_lsiq_srcvm_entry.lsu_match,  `IDU_IS_LSIQ.x_ct_idu_is_lsiq_entry0.x_ct_idu_is_lsiq_srcvm_entry.lsu_match};
    lsiq_load_dep_not_ready_width = popcount64({52'b0, entry_wait & src0_load})
                                  + popcount64({52'b0, entry_wait & src1_load})
                                  + popcount64({52'b0, entry_wait & srcvm_load});
  end
  endfunction

  function automatic [7:0] lsiq_nonload_dep_not_ready_width();
  begin
    lsiq_nonload_dep_not_ready_width = lsiq_src0_not_ready_width()
                                     + lsiq_src1_not_ready_width()
                                     + lsiq_srcvm_not_ready_width()
                                     - lsiq_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] sdiq_load_dep_not_ready_width();
    logic [11:0] entry_wait;
    logic [11:0] src0_load;
    logic [11:0] srcv0_load;
  begin
    entry_wait = `IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0];
    src0_load = ~{`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.src0_rdy_for_issue, `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.src0_rdy_for_issue,
                  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.src0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.src0_rdy_for_issue,
                  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.src0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.src0_rdy_for_issue,
                  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.src0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.src0_rdy_for_issue,
                  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.src0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.src0_rdy_for_issue,
                  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.src0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.src0_rdy_for_issue}
                & {`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.x_ct_idu_is_sdiq_src0_entry.lsu_match, `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.x_ct_idu_is_sdiq_src0_entry.lsu_match,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.x_ct_idu_is_sdiq_src0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.x_ct_idu_is_sdiq_src0_entry.lsu_match,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.x_ct_idu_is_sdiq_src0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.x_ct_idu_is_sdiq_src0_entry.lsu_match,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.x_ct_idu_is_sdiq_src0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.x_ct_idu_is_sdiq_src0_entry.lsu_match,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.x_ct_idu_is_sdiq_src0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.x_ct_idu_is_sdiq_src0_entry.lsu_match,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.x_ct_idu_is_sdiq_src0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.x_ct_idu_is_sdiq_src0_entry.lsu_match};
    srcv0_load = ~{`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.srcv0_rdy_for_issue, `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.srcv0_rdy_for_issue,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.srcv0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.srcv0_rdy_for_issue,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.srcv0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.srcv0_rdy_for_issue,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.srcv0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.srcv0_rdy_for_issue,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.srcv0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.srcv0_rdy_for_issue,
                   `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.srcv0_rdy_for_issue,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.srcv0_rdy_for_issue}
                 & {`IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry11.x_ct_idu_is_sdiq_srcv0_entry.lsu_match, `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry10.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry9.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry8.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry7.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry6.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry5.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry4.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry3.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry2.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,
                    `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry1.x_ct_idu_is_sdiq_srcv0_entry.lsu_match,  `IDU_IS_SDIQ.x_ct_idu_is_sdiq_entry0.x_ct_idu_is_sdiq_srcv0_entry.lsu_match};
    sdiq_load_dep_not_ready_width = popcount64({52'b0, entry_wait & src0_load})
                                  + popcount64({52'b0, entry_wait & srcv0_load});
  end
  endfunction

  function automatic [7:0] sdiq_nonload_dep_not_ready_width();
  begin
    sdiq_nonload_dep_not_ready_width = sdiq_src0_not_ready_width()
                                     + sdiq_srcv0_not_ready_width()
                                     - sdiq_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] viq0_load_dep_not_ready_width();
    logic [7:0] entry_wait;
    logic [7:0] srcv0_load;
    logic [7:0] srcv1_load;
    logic [7:0] srcv2_load;
    logic [7:0] srcvm_load;
  begin
    entry_wait = `IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0];
    srcv0_load = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcv0_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcv0_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcv0_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcv0_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcv0_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcv0_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcv0_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcv0_rdy_for_issue}
                 & {`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.x_ct_idu_is_viq0_srcv0_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.x_ct_idu_is_viq0_srcv0_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.x_ct_idu_is_viq0_srcv0_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.x_ct_idu_is_viq0_srcv0_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.x_ct_idu_is_viq0_srcv0_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.x_ct_idu_is_viq0_srcv0_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.x_ct_idu_is_viq0_srcv0_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.x_ct_idu_is_viq0_srcv0_entry.lsu_match};
    srcv1_load = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcv1_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcv1_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcv1_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcv1_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcv1_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcv1_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcv1_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcv1_rdy_for_issue}
                 & {`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.x_ct_idu_is_viq0_srcv1_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.x_ct_idu_is_viq0_srcv1_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.x_ct_idu_is_viq0_srcv1_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.x_ct_idu_is_viq0_srcv1_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.x_ct_idu_is_viq0_srcv1_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.x_ct_idu_is_viq0_srcv1_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.x_ct_idu_is_viq0_srcv1_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.x_ct_idu_is_viq0_srcv1_entry.lsu_match};
    srcv2_load = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcv2_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcv2_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcv2_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcv2_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcv2_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcv2_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcv2_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcv2_rdy_for_issue}
                 & {`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.x_ct_idu_is_viq0_srcv2_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.x_ct_idu_is_viq0_srcv2_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.x_ct_idu_is_viq0_srcv2_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.x_ct_idu_is_viq0_srcv2_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.x_ct_idu_is_viq0_srcv2_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.x_ct_idu_is_viq0_srcv2_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.x_ct_idu_is_viq0_srcv2_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.x_ct_idu_is_viq0_srcv2_entry.lsu_match};
    srcvm_load = ~{`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.srcvm_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.srcvm_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.srcvm_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.srcvm_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.srcvm_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.srcvm_rdy_for_issue,
                   `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.srcvm_rdy_for_issue, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.srcvm_rdy_for_issue}
                 & {`IDU_IS_VIQ0.x_ct_idu_is_viq0_entry7.x_ct_idu_is_viq0_srcvm_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry6.x_ct_idu_is_viq0_srcvm_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry5.x_ct_idu_is_viq0_srcvm_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry4.x_ct_idu_is_viq0_srcvm_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry3.x_ct_idu_is_viq0_srcvm_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry2.x_ct_idu_is_viq0_srcvm_entry.lsu_match,
                    `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry1.x_ct_idu_is_viq0_srcvm_entry.lsu_match, `IDU_IS_VIQ0.x_ct_idu_is_viq0_entry0.x_ct_idu_is_viq0_srcvm_entry.lsu_match};
    viq0_load_dep_not_ready_width = popcount64({56'b0, entry_wait & srcv0_load})
                                  + popcount64({56'b0, entry_wait & srcv1_load})
                                  + popcount64({56'b0, entry_wait & srcv2_load})
                                  + popcount64({56'b0, entry_wait & srcvm_load});
  end
  endfunction

  function automatic [7:0] viq0_nonload_dep_not_ready_width();
  begin
    viq0_nonload_dep_not_ready_width = viq0_srcv0_not_ready_width()
                                     + viq0_srcv1_not_ready_width()
                                     + viq0_srcv2_not_ready_width()
                                     + viq0_srcvm_not_ready_width()
                                     - viq0_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] viq1_load_dep_not_ready_width();
    logic [7:0] entry_wait;
    logic [7:0] srcv0_load;
    logic [7:0] srcv1_load;
    logic [7:0] srcv2_load;
    logic [7:0] srcvm_load;
  begin
    entry_wait = `IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0];
    srcv0_load = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcv0_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcv0_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcv0_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcv0_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcv0_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcv0_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcv0_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcv0_rdy_for_issue}
                 & {`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.x_ct_idu_is_viq1_srcv0_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.x_ct_idu_is_viq1_srcv0_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.x_ct_idu_is_viq1_srcv0_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.x_ct_idu_is_viq1_srcv0_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.x_ct_idu_is_viq1_srcv0_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.x_ct_idu_is_viq1_srcv0_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.x_ct_idu_is_viq1_srcv0_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.x_ct_idu_is_viq1_srcv0_entry.lsu_match};
    srcv1_load = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcv1_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcv1_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcv1_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcv1_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcv1_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcv1_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcv1_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcv1_rdy_for_issue}
                 & {`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.x_ct_idu_is_viq1_srcv1_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.x_ct_idu_is_viq1_srcv1_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.x_ct_idu_is_viq1_srcv1_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.x_ct_idu_is_viq1_srcv1_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.x_ct_idu_is_viq1_srcv1_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.x_ct_idu_is_viq1_srcv1_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.x_ct_idu_is_viq1_srcv1_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.x_ct_idu_is_viq1_srcv1_entry.lsu_match};
    srcv2_load = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcv2_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcv2_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcv2_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcv2_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcv2_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcv2_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcv2_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcv2_rdy_for_issue}
                 & {`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.x_ct_idu_is_viq1_srcv2_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.x_ct_idu_is_viq1_srcv2_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.x_ct_idu_is_viq1_srcv2_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.x_ct_idu_is_viq1_srcv2_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.x_ct_idu_is_viq1_srcv2_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.x_ct_idu_is_viq1_srcv2_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.x_ct_idu_is_viq1_srcv2_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.x_ct_idu_is_viq1_srcv2_entry.lsu_match};
    srcvm_load = ~{`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.srcvm_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.srcvm_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.srcvm_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.srcvm_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.srcvm_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.srcvm_rdy_for_issue,
                   `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.srcvm_rdy_for_issue, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.srcvm_rdy_for_issue}
                 & {`IDU_IS_VIQ1.x_ct_idu_is_viq1_entry7.x_ct_idu_is_viq1_srcvm_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry6.x_ct_idu_is_viq1_srcvm_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry5.x_ct_idu_is_viq1_srcvm_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry4.x_ct_idu_is_viq1_srcvm_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry3.x_ct_idu_is_viq1_srcvm_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry2.x_ct_idu_is_viq1_srcvm_entry.lsu_match,
                    `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry1.x_ct_idu_is_viq1_srcvm_entry.lsu_match, `IDU_IS_VIQ1.x_ct_idu_is_viq1_entry0.x_ct_idu_is_viq1_srcvm_entry.lsu_match};
    viq1_load_dep_not_ready_width = popcount64({56'b0, entry_wait & srcv0_load})
                                  + popcount64({56'b0, entry_wait & srcv1_load})
                                  + popcount64({56'b0, entry_wait & srcv2_load})
                                  + popcount64({56'b0, entry_wait & srcvm_load});
  end
  endfunction

  function automatic [7:0] viq1_nonload_dep_not_ready_width();
  begin
    viq1_nonload_dep_not_ready_width = viq1_srcv0_not_ready_width()
                                     + viq1_srcv1_not_ready_width()
                                     + viq1_srcv2_not_ready_width()
                                     + viq1_srcvm_not_ready_width()
                                     - viq1_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] iq_load_dep_not_ready_width();
  begin
    iq_load_dep_not_ready_width = aiq0_load_dep_not_ready_width()
                                + aiq1_load_dep_not_ready_width()
                                + biq_load_dep_not_ready_width()
                                + lsiq_load_dep_not_ready_width()
                                + sdiq_load_dep_not_ready_width()
                                + viq0_load_dep_not_ready_width()
                                + viq1_load_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] iq_nonload_dep_not_ready_width();
  begin
    iq_nonload_dep_not_ready_width = aiq0_nonload_dep_not_ready_width()
                                   + aiq1_nonload_dep_not_ready_width()
                                   + biq_nonload_dep_not_ready_width()
                                   + lsiq_nonload_dep_not_ready_width()
                                   + sdiq_nonload_dep_not_ready_width()
                                   + viq0_nonload_dep_not_ready_width()
                                   + viq1_nonload_dep_not_ready_width();
  end
  endfunction

  function automatic [7:0] iq_issue_select_width();
  begin
    iq_issue_select_width = aiq0_issue_select_width()
                          + aiq1_issue_select_width()
                          + biq_issue_select_width()
                          + lsiq_issue_select_width()
                          + sdiq_issue_select_width()
                          + viq0_issue_select_width()
                          + viq1_issue_select_width();
  end
  endfunction

  function automatic [7:0] aiq0_issue_select_width();
  begin
    aiq0_issue_select_width = popcount64({56'b0, `IDU_IS_AIQ0.aiq0_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] aiq1_issue_select_width();
  begin
    aiq1_issue_select_width = popcount64({56'b0, `IDU_IS_AIQ1.aiq1_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] biq_issue_select_width();
  begin
    biq_issue_select_width = popcount64({52'b0, `IDU_IS_BIQ.biq_entry_issue_en[11:0]});
  end
  endfunction

  function automatic [7:0] lsiq_issue_select_width();
  begin
    lsiq_issue_select_width = popcount64({52'b0, `IDU_IS_LSIQ.lsiq_entry_issue_en[11:0]});
  end
  endfunction

  function automatic [7:0] sdiq_issue_select_width();
  begin
    sdiq_issue_select_width = popcount64({52'b0, `IDU_IS_SDIQ.sdiq_entry_issue_en[11:0]});
  end
  endfunction

  function automatic [7:0] viq0_issue_select_width();
  begin
    viq0_issue_select_width = popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] viq1_issue_select_width();
  begin
    viq1_issue_select_width = popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] aiq0_ready_not_issued_width();
  begin
    aiq0_ready_not_issued_width = popcount64({56'b0, `IDU_IS_AIQ0.aiq0_entry_ready[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] aiq1_ready_not_issued_width();
  begin
    aiq1_ready_not_issued_width = popcount64({56'b0, `IDU_IS_AIQ1.aiq1_entry_ready[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] biq_ready_not_issued_width();
  begin
    biq_ready_not_issued_width = popcount64({52'b0, `IDU_IS_BIQ.biq_entry_ready[11:0] & ~`IDU_IS_BIQ.biq_entry_issue_en[11:0]});
  end
  endfunction

  function automatic [7:0] lsiq_ready_not_issued_width();
  begin
    lsiq_ready_not_issued_width = popcount64({52'b0, `IDU_IS_LSIQ.lsiq_entry_ready[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_issue_en[11:0]});
  end
  endfunction

  function automatic [7:0] sdiq_ready_not_issued_width();
  begin
    sdiq_ready_not_issued_width = popcount64({52'b0, `IDU_IS_SDIQ.sdiq_entry_ready[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_issue_en[11:0]});
  end
  endfunction

  function automatic [7:0] viq0_ready_not_issued_width();
  begin
    viq0_ready_not_issued_width = popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_ready[7:0] & ~`IDU_IS_VIQ0.viq0_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] viq1_ready_not_issued_width();
  begin
    viq1_ready_not_issued_width = popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_ready[7:0] & ~`IDU_IS_VIQ1.viq1_entry_issue_en[7:0]});
  end
  endfunction

  function automatic [7:0] iq_ready_not_issued_width();
  begin
    iq_ready_not_issued_width = aiq0_ready_not_issued_width()
                              + aiq1_ready_not_issued_width()
                              + biq_ready_not_issued_width()
                              + lsiq_ready_not_issued_width()
                              + sdiq_ready_not_issued_width()
                              + viq0_ready_not_issued_width()
                              + viq1_ready_not_issued_width();
  end
  endfunction

  function automatic [7:0] mmu_va_req_width();
  begin
    mmu_va_req_width = {7'b0, `MMU_TOP.ifu_mmu_va_vld}
                     + {7'b0, `MMU_TOP.lsu_mmu_va0_vld}
                     + {7'b0, `MMU_TOP.lsu_mmu_va1_vld}
                     + {7'b0, `MMU_TOP.lsu_mmu_va2_vld};
  end
  endfunction

  function automatic logic load_replay_pressure();
  begin
    load_replay_pressure = `LSU_LD_DA.ld_da_lfb_discard_grnt
                        || `LSU_LD_DA.ld_da_lm_discard_grnt
                        || `LSU_LD_DA.ld_da_rb_discard_grnt
                        || `LSU_LD_DA.ld_da_sq_data_discard_vld
                        || `LSU_LD_DA.ld_da_sq_global_discard_vld
                        || `LSU_LD_DA.ld_da_wmb_discard_vld
                        || `LSU_LD_DA.ld_da_wb_spec_fail
                        || `LSU_ST_DA.st_da_wb_spec_fail;
  end
  endfunction

  function automatic [7:0] rf_pipe0_src_no_rdy_width();
  begin
    rf_pipe0_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe0_inst_vld && `IDU_RF_DP.rf_pipe0_src0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe0_inst_vld && `IDU_RF_DP.rf_pipe0_src1_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe0_inst_vld && `IDU_RF_DP.rf_pipe0_src2_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_pipe1_src_no_rdy_width();
  begin
    rf_pipe1_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe1_inst_vld && `IDU_RF_DP.rf_pipe1_src0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe1_inst_vld && `IDU_RF_DP.rf_pipe1_src1_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe1_inst_vld && `IDU_RF_DP.rf_pipe1_src2_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_pipe2_src_no_rdy_width();
  begin
    rf_pipe2_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe2_inst_vld && `IDU_RF_DP.rf_pipe2_src0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe2_inst_vld && `IDU_RF_DP.rf_pipe2_src1_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_pipe3_src_no_rdy_width();
  begin
    rf_pipe3_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe3_inst_vld && `IDU_RF_DP.rf_pipe3_src0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe3_inst_vld && `IDU_RF_DP.rf_pipe3_src1_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe3_inst_vld && `IDU_RF_DP.rf_pipe3_srcvm_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_pipe4_src_no_rdy_width();
  begin
    rf_pipe4_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe4_inst_vld && `IDU_RF_DP.rf_pipe4_src0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe4_inst_vld && `IDU_RF_DP.rf_pipe4_src1_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe4_inst_vld && `IDU_RF_DP.rf_pipe4_srcvm_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_pipe5_src_no_rdy_width();
  begin
    rf_pipe5_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe5_inst_vld && `IDU_RF_DP.rf_pipe5_src0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe5_inst_vld && `IDU_RF_DP.rf_pipe5_srcv0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe5_inst_vld && `IDU_RF_DP.rf_pipe5_staddr_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_pipe6_src_no_rdy_width();
  begin
    rf_pipe6_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcv0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcv1_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcv2_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcvm_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_pipe7_src_no_rdy_width();
  begin
    rf_pipe7_src_no_rdy_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcv0_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcv1_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcv2_no_rdy}
                              + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcvm_no_rdy};
  end
  endfunction

  function automatic [7:0] rf_src_no_rdy_width();
  begin
    rf_src_no_rdy_width = rf_pipe0_src_no_rdy_width()
                        + rf_pipe1_src_no_rdy_width()
                        + rf_pipe2_src_no_rdy_width()
                        + rf_pipe3_src_no_rdy_width()
                        + rf_pipe4_src_no_rdy_width()
                        + rf_pipe5_src_no_rdy_width()
                        + rf_pipe6_src_no_rdy_width()
                        + rf_pipe7_src_no_rdy_width();
  end
  endfunction

  function automatic [7:0] rf_other_lch_fail_width();
  begin
    rf_other_lch_fail_width = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe0_vdiv_mtvr_lch_fail}
                            + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe3_preg_lch_fail}
                            + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe3_vreg_lch_fail}
                            + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe4_vreg_lch_fail}
                            + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe5_preg_lch_fail}
                            + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_div_mfvr_lch_fail}
                            + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_vmul_unsplit_lch_fail}
                            + {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe7_mult_mfvr_lch_fail};
  end
  endfunction

  function automatic [7:0] lsu_replay_discard_width();
  begin
    lsu_replay_discard_width = {7'b0, `LSU_TOP.lsu_hpcp_replay_data_discard}
                             + {7'b0, `LSU_TOP.lsu_hpcp_replay_discard_sq}
                             + {7'b0, `LSU_LD_DA.ld_da_lfb_discard_grnt}
                             + {7'b0, `LSU_LD_DA.ld_da_lm_discard_grnt}
                             + {7'b0, `LSU_LD_DA.ld_da_rb_discard_grnt}
                             + {7'b0, `LSU_LD_DA.ld_da_sq_data_discard_vld}
                             + {7'b0, `LSU_LD_DA.ld_da_sq_global_discard_vld}
                             + {7'b0, `LSU_LD_DA.ld_da_wmb_discard_vld};
  end
  endfunction

  function automatic [7:0] lsu_sq_fwd_width();
  begin
    lsu_sq_fwd_width = {7'b0, `LSU_SQ.sq_ld_dc_has_fwd_req}
                     + {7'b0, `LSU_SQ.sq_ld_dc_fwd_req}
                     + {7'b0, `LSU_SQ.sq_ld_dc_fwd_bypass_req}
                     + {7'b0, `LSU_SQ.sq_ld_dc_fwd_bypass_multi}
                     + {7'b0, `LSU_SQ.sq_ld_dc_fwd_multi}
                     + {7'b0, `LSU_SQ.sq_ld_dc_fwd_multi_mask};
  end
  endfunction

  function automatic [7:0] lsu_sq_cancel_width();
  begin
    lsu_sq_cancel_width = {7'b0, `LSU_SQ.sq_ld_dc_cancel_acc_req}
                         + {7'b0, `LSU_SQ.sq_ld_dc_cancel_ahead_wb};
  end
  endfunction

  function automatic [7:0] lsu_wait_old_width();
  begin
    lsu_wait_old_width = popcount64({52'b0, `LSU_TOP.lsu_idu_ld_ag_wait_old[11:0]})
                       + popcount64({52'b0, `LSU_TOP.lsu_idu_ld_da_wait_old[11:0]})
                       + popcount64({52'b0, `LSU_TOP.lsu_idu_st_ag_wait_old[11:0]})
                       + popcount64({52'b0, `LSU_TOP.lsu_idu_wait_old[11:0]});
  end
  endfunction

  function automatic [7:0] lsu_queue_full_width();
  begin
    lsu_queue_full_width = {7'b0, !`LSU_TOP.lsu_idu_lq_not_full}
                         + {7'b0, !`LSU_TOP.lsu_idu_sq_not_full}
                         + {7'b0, !`LSU_TOP.lsu_idu_rb_not_full};
  end
  endfunction

  function automatic [7:0] producer_wakeup_width();
  begin
    producer_wakeup_width = {7'b0, `IDU_TOP.ctrl_xx_rf_pipe0_preg_lch_vld_dup0}
                          + {7'b0, `IDU_TOP.ctrl_xx_rf_pipe1_preg_lch_vld_dup0}
                          + {7'b0, `IU_TOP.iu_idu_ex2_pipe1_mult_inst_vld_dup0}
                          + {7'b0, `IU_TOP.iu_idu_div_inst_vld}
                          + {7'b0, `LSU_TOP.lsu_idu_dc_pipe3_load_fwd_inst_vld_dup1}
                          + {7'b0, `LSU_TOP.lsu_idu_dc_pipe3_vload_fwd_inst_vld}
                          + {7'b0, `VFPU_TOP.vfpu_idu_ex1_pipe6_data_vld_dup0}
                          + {7'b0, `VFPU_TOP.vfpu_idu_ex1_pipe7_data_vld_dup0};
  end
  endfunction

  function automatic [7:0] dcache_ld_grnt_width();
  begin
    dcache_ld_grnt_width = {7'b0, `LSU_DCA.dcache_arb_lfb_ld_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_vb_ld_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_snq_ld_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_wmb_ld_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_icc_ld_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_mcic_ld_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_ag_ld_sel};
  end
  endfunction

  function automatic [7:0] dcache_st_grnt_width();
  begin
    dcache_st_grnt_width = {7'b0, `LSU_DCA.dcache_arb_lfb_st_sel}
                         + {7'b0, `LSU_DCA.dcache_arb_vb_st_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_snq_st_grnt}
                         + {7'b0, `LSU_DCA.dcache_arb_wmb_st_sel}
                         + {7'b0, `LSU_DCA.dcache_arb_icc_st_sel}
                         + {7'b0, `LSU_DCA.dcache_arb_ag_st_sel};
  end
  endfunction

  function automatic [7:0] lfb_addr_pop_width();
  begin
    lfb_addr_pop_width = popcount64({56'b0, `LSU_LFB.lfb_addr_entry_pop_vld[7:0]});
  end
  endfunction

  function automatic [7:0] wmb_create_width();
  begin
    wmb_create_width = popcount64({56'b0, `LSU_WMB.wmb_entry_create_vld[7:0]});
  end
  endfunction

  function automatic [7:0] rb_create_width();
  begin
    rb_create_width = popcount64({56'b0, `LSU_RB.rb_entry_ld_create_vld[7:0]})
                    + popcount64({56'b0, `LSU_RB.rb_entry_st_create_vld[7:0]});
  end
  endfunction

  function automatic [7:0] ibuf_occ();
  begin
    ibuf_occ = popcount64({32'b0, `IFU_IBUF.entry_vld[31:0]});
  end
  endfunction

  function automatic [7:0] bht_wrbuf_occ();
  begin
    bht_wrbuf_occ = popcount64({60'b0,
                                `IFU_BHT.entry3_vld,
                                `IFU_BHT.entry2_vld,
                                `IFU_BHT.entry1_vld,
                                `IFU_BHT.entry0_vld});
  end
  endfunction

  function automatic logic stack_bad_spec();
  begin
    stack_bad_spec = `RTU_TOP.rtu_yy_xx_flush
                  || `RTU_TOP.rtu_ifu_flush
                  || `RTU_TOP.iu_rtu_pipe0_flush
                  || `RTU_TOP.rtu_lsu_spec_fail_flush
                  || `IU_TOP.iu_idu_mispred_stall
                  || `IU_TOP.iu_ifu_mispred_stall
                  || `IU_TOP.iu_rtu_pipe2_bht_mispred
                  || `IU_TOP.iu_rtu_pipe2_jmp_mispred;
  end
  endfunction

  function automatic [7:0] iq_blocked_queue_count();
  begin
    iq_blocked_queue_count = {7'b0, |(`IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0])}
                           + {7'b0, |(`IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0])}
                           + {7'b0, |(`IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0])}
                           + {7'b0, |(`IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0])}
                           + {7'b0, |(`IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0])}
                           + {7'b0, |(`IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0])}
                           + {7'b0, |(`IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0])};
  end
  endfunction

  function automatic [7:0] iq_ready_queue_count();
  begin
    iq_ready_queue_count = {7'b0, |`IDU_IS_AIQ0.aiq0_entry_ready[7:0]}
                         + {7'b0, |`IDU_IS_AIQ1.aiq1_entry_ready[7:0]}
                         + {7'b0, |`IDU_IS_BIQ.biq_entry_ready[11:0]}
                         + {7'b0, |`IDU_IS_LSIQ.lsiq_entry_ready[11:0]}
                         + {7'b0, |`IDU_IS_SDIQ.sdiq_entry_ready[11:0]}
                         + {7'b0, |`IDU_IS_VIQ0.viq0_entry_ready[7:0]}
                         + {7'b0, |`IDU_IS_VIQ1.viq1_entry_ready[7:0]};
  end
  endfunction

  function automatic [7:0] preg_alloc_avail_width();
  begin
    preg_alloc_avail_width = {7'b0, `RTU_PST_PREG.rtu_idu_alloc_preg0_vld}
                           + {7'b0, `RTU_PST_PREG.rtu_idu_alloc_preg1_vld}
                           + {7'b0, `RTU_PST_PREG.rtu_idu_alloc_preg2_vld}
                           + {7'b0, `RTU_PST_PREG.rtu_idu_alloc_preg3_vld};
  end
  endfunction

  function automatic [7:0] ereg_alloc_avail_width();
  begin
    ereg_alloc_avail_width = {7'b0, `RTU_PST_EREG.rtu_idu_alloc_ereg0_vld}
                           + {7'b0, `RTU_PST_EREG.rtu_idu_alloc_ereg1_vld}
                           + {7'b0, `RTU_PST_EREG.rtu_idu_alloc_ereg2_vld}
                           + {7'b0, `RTU_PST_EREG.rtu_idu_alloc_ereg3_vld};
  end
  endfunction

  function automatic logic stack_frontend_bound();
  begin
    stack_frontend_bound = `IFU_IFCTRL.if_frontend_stall
                        || `IFU_IBCTRL.ibctrl_debug_ibuf_full
                        || `IFU_IBCTRL.ibctrl_debug_fifo_full_stall
                        || `IFU_IPCTRL.icache_refill_reissue
                        || `IFU_IPCTRL.l1_refill_ipctrl_busy
                        || `IFU_IPCTRL.miss_under_refill_stall
                        || `IFU_IPCTRL.way_mispred_reissue
                        || `IFU_IPCTRL.bry_missigned_stall
                        || `IFU_IPCTRL.br_more_than_one_stall
                        || `IFU_IBCTRL.ind_btb_rd_stall;
  end
  endfunction

  function automatic logic stack_memory_bound();
  begin
    stack_memory_bound = `LSU_TOP.lsu_hpcp_ld_stall_cross_4k
                      || `LSU_TOP.lsu_hpcp_st_stall_cross_4k
                      || `LSU_TOP.lsu_hpcp_ld_stall_other
                      || `LSU_TOP.lsu_hpcp_st_stall_other
                      || `LSU_LD_AG.ld_ag_dcache_stall_req
                      || `LSU_LD_AG.ld_ag_mmu_stall_req
                      || `LSU_ST_AG.st_ag_dcache_stall_req
                      || `LSU_ST_AG.st_ag_mmu_stall_req
                      || `LSU_LQ.lq_full
                      || `LSU_SQ.sq_full
                      || `LSU_RB.rb_full
                      || `LSU_LFB.lfb_addr_full
                      || `LSU_WMB.wmb_ce_bytes_vld_full
                      || `BIU_READ.biu_pad_arvalid && !`BIU_READ.pad_biu_arready
                      || `BIU_READ.pad_biu_rvalid && !`BIU_READ.biu_pad_rready
                      || `BIU_WRITE.biu_pad_awvalid && !`BIU_WRITE.pad_awready
                      || `BIU_WRITE.biu_pad_wvalid && !`BIU_WRITE.pad_wready
                      || `BIU_WRITE.pad_biu_bvalid && !`BIU_WRITE.biu_pad_bready;
  end
  endfunction

  function automatic logic stack_backend_core_bound();
  begin
    stack_backend_core_bound = `IDU_ID_CTRL.ctrl_id_stall
                            || `IDU_TOP.ctrl_ir_stall
                            || `IDU_TOP.rtu_idu_rob_full
                            || `IDU_IR_CTRL.ctrl_top_ir_preg_not_vld
                            || (`RTU_PST_PREG.idu_rtu_ir_preg0_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg0_vld)
                            || (`RTU_PST_PREG.idu_rtu_ir_preg1_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg1_vld)
                            || (`RTU_PST_PREG.idu_rtu_ir_preg2_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg2_vld)
                            || (`RTU_PST_PREG.idu_rtu_ir_preg3_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg3_vld)
                            || `IDU_ID_CTRL.ctrl_id_split_long_stall
                            || `IDU_TOP.aiq0_ctrl_full
                            || `IDU_TOP.aiq1_ctrl_full
                            || `IDU_TOP.biq_ctrl_full
                            || `IDU_TOP.lsiq_ctrl_full
                            || `IDU_TOP.sdiq_ctrl_full
                            || `IU_TOP.iu_idu_ex1_pipe1_mult_stall
                            || `IU_TOP.iu_idu_div_wb_stall
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe0_src_no_rdy
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe1_src_no_rdy
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe2_src_no_rdy
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe3_src_no_rdy
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe4_src_no_rdy
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe5_src_no_rdy
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe6_src_no_rdy
                            || `IDU_RF_CTRL.dp_ctrl_rf_pipe7_src_no_rdy;
  end
  endfunction

  function automatic [2:0] cpi_raw_cause_width();
  begin
    cpi_raw_cause_width = {2'b0, stack_bad_spec()}
                        + {2'b0, stack_frontend_bound()}
                        + {2'b0, stack_memory_bound()}
                        + {2'b0, stack_backend_core_bound()};
  end
  endfunction

  function automatic [2:0] cpi_stack_class();
  begin
    if (retire_width() != 4'd0)
      cpi_stack_class = 3'd1;
    else if (stack_bad_spec())
      cpi_stack_class = 3'd2;
    else if (stack_frontend_bound())
      cpi_stack_class = 3'd3;
    else if (stack_memory_bound())
      cpi_stack_class = 3'd4;
    else if (stack_backend_core_bound())
      cpi_stack_class = 3'd5;
    else
      cpi_stack_class = 3'd6;
  end
  endfunction

  task automatic record_latency(input int id, input [31:0] latency);
  begin
    lat_sample_counter[id] <= lat_sample_counter[id] + 64'd1;
    lat_sum_counter[id]    <= lat_sum_counter[id] + {32'b0, latency};
    if (latency <= 32'd4)
      lat_bucket_counter[id][1] <= lat_bucket_counter[id][1] + 64'd1;
    else if (latency <= 32'd8)
      lat_bucket_counter[id][2] <= lat_bucket_counter[id][2] + 64'd1;
    else if (latency <= 32'd16)
      lat_bucket_counter[id][3] <= lat_bucket_counter[id][3] + 64'd1;
    else if (latency <= 32'd32)
      lat_bucket_counter[id][4] <= lat_bucket_counter[id][4] + 64'd1;
    else if (latency <= 32'd64)
      lat_bucket_counter[id][5] <= lat_bucket_counter[id][5] + 64'd1;
    else
      lat_bucket_counter[id][6] <= lat_bucket_counter[id][6] + 64'd1;
  end
  endtask

  task automatic update_extra_latency(input int id, input logic start_event, input logic done_event);
  begin
    if (start_event && !extra_lat_active[id]) begin
      extra_lat_active[id] <= 1'b1;
      extra_lat_age[id] <= 32'b0;
    end
    else if (extra_lat_active[id] && done_event) begin
      record_latency(id, extra_lat_age[id]);
      extra_lat_active[id] <= 1'b0;
      extra_lat_age[id] <= 32'b0;
    end
    else if (extra_lat_active[id]) begin
      extra_lat_age[id] <= extra_lat_age[id] + 32'd1;
    end
  end
  endtask

  function automatic [7:0] get_profile_value(int id);
  begin
    case(id)
      1:  get_profile_value = {4'b0, id_width()};
      2:  get_profile_value = {4'b0, ir_width()};
      3:  get_profile_value = {4'b0, is_width()};
      4:  get_profile_value = {4'b0, rf_launch_width()};
      5:  get_profile_value = {4'b0, retire_width()};
      6:  get_profile_value = {1'b0, `RTU_TOP.rtu_had_debug_info[24:18]};
      7:  get_profile_value = {4'b0, `IDU_TOP.idu_had_debug_info[23:20]};
      8:  get_profile_value = {4'b0, `IDU_TOP.idu_had_debug_info[27:24]};
      9:  get_profile_value = {4'b0, `IDU_TOP.idu_had_debug_info[31:28]};
      10: get_profile_value = {4'b0, `IDU_TOP.idu_had_debug_info[35:32]};
      11: get_profile_value = {4'b0, `IDU_TOP.idu_had_debug_info[39:36]};
      12: get_profile_value = {4'b0, `IDU_TOP.idu_had_debug_info[43:40]};
      13: get_profile_value = {4'b0, `IDU_TOP.idu_had_debug_info[47:44]};
      14: get_profile_value = popcount64({48'b0, `LSU_LQ.lq_entry_vld[15:0]});
      15: get_profile_value = popcount64({52'b0, `LSU_SQ.sq_entry_vld[11:0]});
      16: get_profile_value = popcount64({56'b0, `LSU_RB.rb_entry_vld[7:0]});
      17: get_profile_value = popcount64({56'b0, `LSU_LFB.lfb_addr_entry_vld[7:0]});
      18: get_profile_value = popcount64({56'b0, `LSU_WMB.wmb_entry_vld[7:0]});
      19: get_profile_value = ibuf_occ();
      20: get_profile_value = bht_wrbuf_occ();
      21: get_profile_value = popcount64({62'b0, `LSU_LFB.lfb_data_entry_vld[1:0]});
      22: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_load,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_load,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_load)};
      23: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_store,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_store,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_store)};
      24: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_bju,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_bju,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_bju)};
      25: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_condbr,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_condbr,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_condbr)};
      26: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_jmp,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_jmp,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_jmp)};
      27: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_split,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_split,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_split)};
      28: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_preg_vld,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_preg_vld,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_preg_vld)};
      29: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_vreg_vld,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_vreg_vld,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_vreg_vld)};
      30: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_ereg_vld,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_ereg_vld,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_ereg_vld)};
      31: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_hit,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_hit,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_hit)};
      32: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_miss,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_miss,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_miss)};
      33: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_mispred,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_mispred,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_mispred)};
      34: get_profile_value = {5'b0, retire_slot_sum(`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_vl_pred,
                                                      `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_vl_pred,
                                                      `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_vl_pred)};
      35: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_PREG.idu_rtu_ir_preg0_alloc_vld,
                                                    `RTU_PST_PREG.idu_rtu_ir_preg1_alloc_vld,
                                                    `RTU_PST_PREG.idu_rtu_ir_preg2_alloc_vld,
                                                    `RTU_PST_PREG.idu_rtu_ir_preg3_alloc_vld)};
      36: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_PREG.rtu_idu_alloc_preg0_vld,
                                                    `RTU_PST_PREG.rtu_idu_alloc_preg1_vld,
                                                    `RTU_PST_PREG.rtu_idu_alloc_preg2_vld,
                                                    `RTU_PST_PREG.rtu_idu_alloc_preg3_vld)};
      37: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_PREG.idu_rtu_ir_preg0_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg0_vld,
                                                    `RTU_PST_PREG.idu_rtu_ir_preg1_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg1_vld,
                                                    `RTU_PST_PREG.idu_rtu_ir_preg2_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg2_vld,
                                                    `RTU_PST_PREG.idu_rtu_ir_preg3_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg3_vld)};
      38: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_EREG.idu_rtu_ir_ereg0_alloc_vld,
                                                    `RTU_PST_EREG.idu_rtu_ir_ereg1_alloc_vld,
                                                    `RTU_PST_EREG.idu_rtu_ir_ereg2_alloc_vld,
                                                    `RTU_PST_EREG.idu_rtu_ir_ereg3_alloc_vld)};
      39: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_EREG.rtu_idu_alloc_ereg0_vld,
                                                    `RTU_PST_EREG.rtu_idu_alloc_ereg1_vld,
                                                    `RTU_PST_EREG.rtu_idu_alloc_ereg2_vld,
                                                    `RTU_PST_EREG.rtu_idu_alloc_ereg3_vld)};
      40: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_EREG.idu_rtu_ir_ereg0_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg0_vld,
                                                    `RTU_PST_EREG.idu_rtu_ir_ereg1_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg1_vld,
                                                    `RTU_PST_EREG.idu_rtu_ir_ereg2_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg2_vld,
                                                    `RTU_PST_EREG.idu_rtu_ir_ereg3_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg3_vld)};
      41: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_FREG.idu_rtu_ir_xreg0_alloc_vld,
                                                    `RTU_PST_FREG.idu_rtu_ir_xreg1_alloc_vld,
                                                    `RTU_PST_FREG.idu_rtu_ir_xreg2_alloc_vld,
                                                    `RTU_PST_FREG.idu_rtu_ir_xreg3_alloc_vld)};
      42: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_FREG.rtu_idu_alloc_xreg0_vld,
                                                    `RTU_PST_FREG.rtu_idu_alloc_xreg1_vld,
                                                    `RTU_PST_FREG.rtu_idu_alloc_xreg2_vld,
                                                    `RTU_PST_FREG.rtu_idu_alloc_xreg3_vld)};
      43: get_profile_value = {5'b0, four_slot_sum(`RTU_PST_FREG.idu_rtu_ir_xreg0_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg0_vld,
                                                    `RTU_PST_FREG.idu_rtu_ir_xreg1_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg1_vld,
                                                    `RTU_PST_FREG.idu_rtu_ir_xreg2_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg2_vld,
                                                    `RTU_PST_FREG.idu_rtu_ir_xreg3_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg3_vld)};
      44: get_profile_value = {6'b0, `VFPU_TOP.idu_vfpu_rf_pipe6_sel}
                            + {6'b0, `VFPU_TOP.idu_vfpu_rf_pipe7_sel};
      45: get_profile_value = {5'b0, four_slot_sum(`VFPU_TOP.vfpu_rtu_ex5_pipe6_ereg_wb_vld,
                                                    `VFPU_TOP.vfpu_rtu_ex5_pipe7_ereg_wb_vld,
                                                    `VFPU_TOP.vfpu_rtu_ex5_pipe6_wb_vreg_fr_vld || `VFPU_TOP.vfpu_rtu_ex5_pipe6_wb_vreg_vr_vld,
                                                    `VFPU_TOP.vfpu_rtu_ex5_pipe7_wb_vreg_fr_vld || `VFPU_TOP.vfpu_rtu_ex5_pipe7_wb_vreg_vr_vld)};
      46: get_profile_value = popcount64({56'b0, `LSU_PFU.pfu_pfb_entry_vld[7:0]});
      47: get_profile_value = popcount64({56'b0, `LSU_PFU.pfu_pmb_entry_vld[7:0]});
      48: get_profile_value = popcount64({62'b0, `LSU_PFU.pfu_sdb_entry_vld[1:0]});
      49: get_profile_value = popcount64({62'b0, `LSU_VB.vb_addr_entry_vld[1:0]});
      50: get_profile_value = popcount64({61'b0, `LSU_VB.vb_data_entry_vld[2:0]});
      51: get_profile_value = dispatch_create_width();
      52: get_profile_value = {6'b0, `IDU_IS_CTRL.ctrl_aiq0_create0_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_aiq0_create1_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_aiq1_create0_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_aiq1_create1_en};
      53: get_profile_value = {6'b0, `IDU_IS_CTRL.ctrl_biq_create0_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_biq_create1_en};
      54: get_profile_value = {6'b0, `IDU_IS_CTRL.ctrl_lsiq_create0_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_lsiq_create1_en};
      55: get_profile_value = {6'b0, `IDU_IS_CTRL.ctrl_sdiq_create0_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_sdiq_create1_en};
      56: get_profile_value = {6'b0, `IDU_IS_CTRL.ctrl_viq0_create0_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_viq0_create1_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_viq1_create0_en}
                            + {6'b0, `IDU_IS_CTRL.ctrl_viq1_create1_en};
      57: get_profile_value = iq_pop_width();
      58: get_profile_value = {6'b0, `IDU_RF_CTRL.ctrl_aiq0_rf_pop_vld}
                            + {6'b0, `IDU_RF_CTRL.ctrl_aiq1_rf_pop_vld}
                            + {6'b0, `IDU_RF_CTRL.ctrl_biq_rf_pop_vld};
      59: get_profile_value = {6'b0, `IDU_TOP.lsu_idu_lsiq_pop_vld}
                            + {6'b0, `IDU_TOP.lsu_idu_ex1_sdiq_pop_vld};
      60: get_profile_value = {6'b0, `IDU_RF_CTRL.ctrl_viq0_rf_pop_vld}
                            + {6'b0, `IDU_RF_CTRL.ctrl_viq1_rf_pop_vld};
      61: get_profile_value = popcount64({57'b0, `LSU_DCA.dcache_arb_ld_req[6:0]});
      62: get_profile_value = dcache_ld_grnt_width();
      63: get_profile_value = popcount64({58'b0, `LSU_DCA.dcache_arb_st_req[5:0]});
      64: get_profile_value = dcache_st_grnt_width();
      65: get_profile_value = lfb_addr_pop_width();
      66: get_profile_value = popcount64({56'b0, `LSU_LFB.lfb_addr_entry_dcache_hit[7:0]});
      67: get_profile_value = popcount64({52'b0, `LSU_LFB.lfb_depd_wakeup[11:0]});
      68: get_profile_value = popcount64({56'b0, `LSU_LFB.lfb_addr_entry_vb_pe_req[7:0]});
      69: get_profile_value = popcount64({52'b0, `LSU_WMB.wmb_wakeup_queue[11:0]});
      70: get_profile_value = popcount64({52'b0, `LSU_WMB.wmb_depd_wakeup[11:0]});
      71: get_profile_value = wmb_create_width();
      72: get_profile_value = rb_create_width();
      73: get_profile_value = popcount64({56'b0, `LSU_RB.rb_entry_biu_pe_req[7:0]});
      74: get_profile_value = rob_commit_width();
      75: get_profile_value = iq_ready_width();
      76: get_profile_value = iq_valid_not_ready_width();
      77: get_profile_value = iq_issue_select_width();
      78: get_profile_value = popcount64({56'b0, `IDU_IS_AIQ0.aiq0_entry_ready[7:0]})
                             + popcount64({56'b0, `IDU_IS_AIQ1.aiq1_entry_ready[7:0]})
                             + popcount64({52'b0, `IDU_IS_BIQ.biq_entry_ready[11:0]});
      79: get_profile_value = popcount64({52'b0, `IDU_IS_LSIQ.lsiq_entry_ready[11:0]})
                             + popcount64({52'b0, `IDU_IS_SDIQ.sdiq_entry_ready[11:0]});
      80: get_profile_value = popcount64({56'b0, `IDU_IS_VIQ0.viq0_entry_ready[7:0]})
                             + popcount64({56'b0, `IDU_IS_VIQ1.viq1_entry_ready[7:0]});
      81: get_profile_value = popcount64({56'b0, (`IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0])})
                             + popcount64({56'b0, (`IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0])})
                             + popcount64({52'b0, (`IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0])});
      82: get_profile_value = popcount64({52'b0, (`IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0])})
                             + popcount64({52'b0, (`IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0])});
      83: get_profile_value = popcount64({56'b0, (`IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0])})
                             + popcount64({56'b0, (`IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0])});
      84: get_profile_value = mmu_va_req_width();
      85: get_profile_value = {6'b0, `MMU_TOP.iutlb_arb_req}
                             + {6'b0, `MMU_TOP.dutlb_arb_req};
      86: get_profile_value = {6'b0, `MMU_TOP.iutlb_arb_cmplt}
                             + {6'b0, `MMU_TOP.dutlb_arb_cmplt};
      87: get_profile_value = {5'b0, `MMU_TOP.jtlb_ptw_req}
                             + {5'b0, `MMU_TOP.ptw_arb_req}
                             + {5'b0, `MMU_TOP.mmu_lsu_data_req};
      88: get_profile_value = popcount64({52'b0, `LSU_WMB.wmb_wakeup_queue[11:0]})
                             + popcount64({52'b0, `LSU_LFB.lfb_depd_wakeup[11:0]})
                             + popcount64({56'b0, `LSU_RB.rb_entry_boundary_wakeup[7:0]});
      89: get_profile_value = biu_rd_outstanding;
      90: get_profile_value = biu_wr_outstanding;
      91: get_profile_value = {5'b0, cpi_raw_cause_width()};
      92: get_profile_value = iq_blocked_queue_count();
      93: get_profile_value = iq_ready_queue_count();
      94: get_profile_value = preg_alloc_avail_width();
      95: get_profile_value = ereg_alloc_avail_width();
      96: get_profile_value = popcount64({56'b0, (`IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0])});
      97: get_profile_value = popcount64({56'b0, (`IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0])});
      98: get_profile_value = popcount64({52'b0, (`IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0])});
      99: get_profile_value = popcount64({52'b0, (`IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0])});
      100: get_profile_value = popcount64({52'b0, (`IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0])});
      101: get_profile_value = popcount64({56'b0, (`IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0])});
      102: get_profile_value = popcount64({56'b0, (`IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0])});
      103: get_profile_value = popcount64({56'b0, `LSU_WMB.wmb_entry_pop_vld[7:0]});
      104: get_profile_value = popcount64({52'b0, `LSU_SQ.sq_entry_pop_to_ce_grnt[11:0]});
      105: get_profile_value = aiq0_src0_not_ready_width();
      106: get_profile_value = aiq0_src1_not_ready_width();
      107: get_profile_value = aiq0_src2_not_ready_width();
      108: get_profile_value = aiq1_src0_not_ready_width();
      109: get_profile_value = aiq1_src1_not_ready_width();
      110: get_profile_value = aiq1_src2_not_ready_width();
      111: get_profile_value = biq_src0_not_ready_width();
      112: get_profile_value = biq_src1_not_ready_width();
      113: get_profile_value = lsiq_src0_not_ready_width();
      114: get_profile_value = lsiq_src1_not_ready_width();
      115: get_profile_value = lsiq_srcvm_not_ready_width();
      116: get_profile_value = sdiq_src0_not_ready_width();
      117: get_profile_value = sdiq_srcv0_not_ready_width();
      118: get_profile_value = sdiq_staddr_not_ready_width();
      119: get_profile_value = viq0_srcv0_not_ready_width();
      120: get_profile_value = viq0_srcv1_not_ready_width();
      121: get_profile_value = viq0_srcv2_not_ready_width();
      122: get_profile_value = viq0_srcvm_not_ready_width();
      123: get_profile_value = viq1_srcv0_not_ready_width();
      124: get_profile_value = viq1_srcv1_not_ready_width();
      125: get_profile_value = viq1_srcv2_not_ready_width();
      126: get_profile_value = viq1_srcvm_not_ready_width();
      127: get_profile_value = iq_load_dep_not_ready_width();
      128: get_profile_value = iq_nonload_dep_not_ready_width();
      129: get_profile_value = aiq0_load_dep_not_ready_width();
      130: get_profile_value = aiq0_nonload_dep_not_ready_width();
      131: get_profile_value = aiq1_load_dep_not_ready_width();
      132: get_profile_value = aiq1_nonload_dep_not_ready_width();
      133: get_profile_value = biq_load_dep_not_ready_width();
      134: get_profile_value = biq_nonload_dep_not_ready_width();
      135: get_profile_value = lsiq_load_dep_not_ready_width();
      136: get_profile_value = lsiq_nonload_dep_not_ready_width();
      137: get_profile_value = sdiq_load_dep_not_ready_width();
      138: get_profile_value = sdiq_nonload_dep_not_ready_width();
      139: get_profile_value = viq0_load_dep_not_ready_width();
      140: get_profile_value = viq0_nonload_dep_not_ready_width();
      141: get_profile_value = viq1_load_dep_not_ready_width();
      142: get_profile_value = viq1_nonload_dep_not_ready_width();
      143: get_profile_value = aiq0_issue_select_width();
      144: get_profile_value = aiq1_issue_select_width();
      145: get_profile_value = biq_issue_select_width();
      146: get_profile_value = lsiq_issue_select_width();
      147: get_profile_value = sdiq_issue_select_width();
      148: get_profile_value = viq0_issue_select_width();
      149: get_profile_value = viq1_issue_select_width();
      150: get_profile_value = iq_ready_not_issued_width();
      151: get_profile_value = aiq0_ready_not_issued_width();
      152: get_profile_value = aiq1_ready_not_issued_width();
      153: get_profile_value = biq_ready_not_issued_width();
      154: get_profile_value = lsiq_ready_not_issued_width();
      155: get_profile_value = sdiq_ready_not_issued_width();
      156: get_profile_value = viq0_ready_not_issued_width();
      157: get_profile_value = viq1_ready_not_issued_width();
      158: get_profile_value = rf_src_no_rdy_width();
      159: get_profile_value = rf_pipe0_src_no_rdy_width();
      160: get_profile_value = rf_pipe1_src_no_rdy_width();
      161: get_profile_value = rf_pipe2_src_no_rdy_width();
      162: get_profile_value = rf_pipe3_src_no_rdy_width();
      163: get_profile_value = rf_pipe4_src_no_rdy_width();
      164: get_profile_value = rf_pipe5_src_no_rdy_width();
      165: get_profile_value = rf_pipe6_src_no_rdy_width();
      166: get_profile_value = rf_pipe7_src_no_rdy_width();
      167: get_profile_value = rf_other_lch_fail_width();
      168: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe0_vdiv_mtvr_lch_fail};
      169: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe3_preg_lch_fail};
      170: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe3_vreg_lch_fail};
      171: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe4_vreg_lch_fail};
      172: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe5_preg_lch_fail};
      173: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_div_mfvr_lch_fail};
      174: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe6_vmul_unsplit_lch_fail};
      175: get_profile_value = {7'b0, `IDU_RF_CTRL.ctrl_rf_pipe7_mult_mfvr_lch_fail};
      176: get_profile_value = lsu_replay_discard_width();
      177: get_profile_value = lsu_sq_fwd_width();
      178: get_profile_value = lsu_sq_cancel_width();
      179: get_profile_value = lsu_wait_old_width();
      180: get_profile_value = lsu_queue_full_width();
      181: get_profile_value = {7'b0, `IDU_TOP.ctrl_xx_rf_pipe0_preg_lch_vld_dup0};
      182: get_profile_value = {7'b0, `IDU_TOP.ctrl_xx_rf_pipe1_preg_lch_vld_dup0};
      183: get_profile_value = {7'b0, `IU_TOP.iu_idu_ex2_pipe1_mult_inst_vld_dup0};
      184: get_profile_value = {7'b0, `IU_TOP.iu_idu_div_inst_vld};
      185: get_profile_value = {7'b0, `LSU_TOP.lsu_idu_dc_pipe3_load_fwd_inst_vld_dup1};
      186: get_profile_value = {7'b0, `LSU_TOP.lsu_idu_dc_pipe3_vload_fwd_inst_vld};
      187: get_profile_value = {7'b0, `VFPU_TOP.vfpu_idu_ex1_pipe6_data_vld_dup0};
      188: get_profile_value = {7'b0, `VFPU_TOP.vfpu_idu_ex1_pipe7_data_vld_dup0};
      189: get_profile_value = producer_wakeup_width();
      default: get_profile_value = 8'b0;
    endcase
  end
  endfunction

  function automatic logic get_detail_value(int id);
  begin
    case(id)
      // ID / backend stall breakdown.
      1:  get_detail_value = `IDU_ID_CTRL.ctrl_id_stall;
      2:  get_detail_value = `IDU_TOP.ctrl_ir_stall;
      3:  get_detail_value = `IDU_ID_CTRL.id_inst0_vld && !`IDU_ID_CTRL.ctrl_id_pipedown_3_inst;
      4:  get_detail_value = `IDU_ID_CTRL.ctrl_id_pipedown_1_inst;
      5:  get_detail_value = `IDU_ID_CTRL.ctrl_id_pipedown_2_inst;
      6:  get_detail_value = `IDU_ID_CTRL.ctrl_id_pipedown_3_inst;
      7:  get_detail_value = `IDU_TOP.fence_ctrl_id_stall;
      8:  get_detail_value = `IDU_ID_CTRL.ctrl_id_split_long_stall;
      9:  get_detail_value = `IDU_TOP.rtu_idu_rob_full;
      10: get_detail_value = `IDU_IR_CTRL.ctrl_top_ir_preg_not_vld;
      11: get_detail_value = `IDU_TOP.rtu_idu_flush_stall;
      12: get_detail_value = `RTU_TOP.rtu_yy_xx_flush;
      13: get_detail_value = `RTU_TOP.rtu_ifu_flush;
      14: get_detail_value = `RTU_TOP.iu_rtu_pipe0_flush;
      15: get_detail_value = `RTU_TOP.rtu_lsu_spec_fail_flush;

      // RF launch fail by execution pipe, matching the HPCP-registered signals.
      16: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe0_lch_fail_vld;
      17: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe1_lch_fail_vld;
      18: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe2_lch_fail_vld;
      19: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe3_lch_fail_vld;
      20: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe4_lch_fail_vld;
      21: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe5_lch_fail_vld;
      22: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe6_lch_fail_vld;
      23: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe7_lch_fail_vld;

      // Raw RF source-not-ready causes before the HPCP register stage.
      24: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe0_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe0_src_no_rdy;
      25: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe1_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe1_src_no_rdy;
      26: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe2_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe2_src_no_rdy;
      27: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe3_src_no_rdy;
      28: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe4_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe4_src_no_rdy;
      29: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe5_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe5_src_no_rdy;
      30: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe6_src_no_rdy;
      31: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_CTRL.dp_ctrl_rf_pipe7_src_no_rdy;

      // RF register-port conflict sub-causes.
      32: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe3_reg_lch_fail_vld;
      33: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe4_reg_lch_fail_vld;
      34: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe5_reg_lch_fail_vld;
      35: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_preg_lch_fail;
      36: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe5_preg_lch_fail;
      37: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_vreg_lch_fail;
      38: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe4_vreg_lch_fail;

      // LSU split of event23/event24 and lower-level AG stall requests.
      39: get_detail_value = `LSU_TOP.lsu_hpcp_ld_stall_cross_4k;
      40: get_detail_value = `LSU_TOP.lsu_hpcp_st_stall_cross_4k;
      41: get_detail_value = `LSU_TOP.lsu_hpcp_ld_stall_other;
      42: get_detail_value = `LSU_TOP.lsu_hpcp_st_stall_other;
      43: get_detail_value = `LSU_LD_AG.ld_ag_cross_page_ldr_imme_stall_req;
      44: get_detail_value = `LSU_LD_AG.ld_ag_dcache_stall_req;
      45: get_detail_value = `LSU_LD_AG.ld_ag_mmu_stall_req;
      46: get_detail_value = `LSU_LD_AG.ld_ag_atomic_no_cmit_restart_req;
      47: get_detail_value = `LSU_ST_AG.st_ag_cross_page_str_imme_stall_req;
      48: get_detail_value = `LSU_ST_AG.st_ag_dcache_stall_req;
      49: get_detail_value = `LSU_ST_AG.st_ag_mmu_stall_req;
      50: get_detail_value = `LSU_ST_AG.st_ag_atomic_no_cmit_restart_req;

      // Frontend delivery pressure.
      51: get_detail_value = `IFU_IFCTRL.if_frontend_stall;
      52: get_detail_value = `IFU_IBCTRL.ibctrl_debug_ibuf_full;
      53: get_detail_value = `IFU_IBCTRL.ibctrl_debug_fifo_full_stall;

      // Stage width distributions. These are cycle buckets.
      54: get_detail_value = (id_width() == 4'd0);
      55: get_detail_value = (id_width() == 4'd1);
      56: get_detail_value = (id_width() == 4'd2);
      57: get_detail_value = (id_width() == 4'd3);
      58: get_detail_value = (ir_width() == 4'd0);
      59: get_detail_value = (ir_width() == 4'd1);
      60: get_detail_value = (ir_width() == 4'd2);
      61: get_detail_value = (ir_width() == 4'd3);
      62: get_detail_value = (ir_width() == 4'd4);
      63: get_detail_value = (is_width() == 4'd0);
      64: get_detail_value = (is_width() == 4'd1);
      65: get_detail_value = (is_width() == 4'd2);
      66: get_detail_value = (is_width() == 4'd3);
      67: get_detail_value = (is_width() == 4'd4);
      68: get_detail_value = (rf_launch_width() == 4'd0);
      69: get_detail_value = (rf_launch_width() == 4'd1);
      70: get_detail_value = (rf_launch_width() == 4'd2);
      71: get_detail_value = (rf_launch_width() == 4'd3);
      72: get_detail_value = (rf_launch_width() == 4'd4);
      73: get_detail_value = (rf_launch_width() == 4'd5);
      74: get_detail_value = (rf_launch_width() == 4'd6);
      75: get_detail_value = (rf_launch_width() == 4'd7);
      76: get_detail_value = (rf_launch_width() == 4'd8);
      77: get_detail_value = (retire_width() == 4'd0);
      78: get_detail_value = (retire_width() == 4'd1);
      79: get_detail_value = (retire_width() == 4'd2);
      80: get_detail_value = (retire_width() == 4'd3);

      // Queue and allocator pressure.
      81: get_detail_value = `RTU_TOP.rtu_idu_rob_empty;
      82: get_detail_value = `RTU_TOP.rtu_had_debug_info[3];
      83: get_detail_value = (`RTU_TOP.rtu_had_debug_info[24:18] >= 7'd32);
      84: get_detail_value = (`RTU_TOP.rtu_had_debug_info[24:18] >= 7'd64);
      85: get_detail_value = (`RTU_TOP.rtu_had_debug_info[24:18] >= 7'd96);
      86: get_detail_value = `IDU_TOP.idu_had_debug_info[19];
      87: get_detail_value = `IDU_TOP.idu_had_debug_info[49];
      88: get_detail_value = `IDU_TOP.aiq0_ctrl_empty;
      89: get_detail_value = `IDU_TOP.aiq0_ctrl_full;
      90: get_detail_value = `IDU_TOP.aiq1_ctrl_empty;
      91: get_detail_value = `IDU_TOP.aiq1_ctrl_full;
      92: get_detail_value = `IDU_TOP.biq_ctrl_empty;
      93: get_detail_value = `IDU_TOP.biq_ctrl_full;
      94: get_detail_value = `IDU_TOP.lsiq_ctrl_empty;
      95: get_detail_value = `IDU_TOP.lsiq_ctrl_full;
      96: get_detail_value = `IDU_TOP.sdiq_ctrl_empty;
      97: get_detail_value = `IDU_TOP.sdiq_ctrl_full;
      98: get_detail_value = `IDU_TOP.viq0_ctrl_empty;
      99: get_detail_value = `IDU_TOP.viq0_ctrl_full;
      100: get_detail_value = `IDU_TOP.viq1_ctrl_empty;
      101: get_detail_value = `IDU_TOP.viq1_ctrl_full;

      // Retired branch/change-flow detail.
      102: get_detail_value = `RTU_TOP.rtu_hpcp_inst0_vld && `RTU_TOP.rtu_hpcp_inst0_condbr;
      103: get_detail_value = `RTU_TOP.rtu_hpcp_inst1_vld && `RTU_TOP.rtu_hpcp_inst1_condbr;
      104: get_detail_value = `RTU_TOP.rtu_hpcp_inst2_vld && `RTU_TOP.rtu_hpcp_inst2_condbr;
      105: get_detail_value = `RTU_TOP.rtu_hpcp_inst0_vld && `RTU_TOP.rtu_hpcp_inst0_jmp;
      106: get_detail_value = `RTU_TOP.rtu_hpcp_inst1_vld && `RTU_TOP.rtu_hpcp_inst1_jmp;
      107: get_detail_value = `RTU_TOP.rtu_hpcp_inst2_vld && `RTU_TOP.rtu_hpcp_inst2_jmp;
      108: get_detail_value = `RTU_TOP.rtu_hpcp_inst0_vld && `RTU_TOP.rtu_hpcp_inst0_bht_mispred;
      109: get_detail_value = `RTU_TOP.rtu_hpcp_inst0_vld && `RTU_TOP.rtu_hpcp_inst0_jmp_mispred;
      110: get_detail_value = `RTU_TOP.rtu_ifu_retire0_condbr;
      111: get_detail_value = `RTU_TOP.rtu_ifu_retire0_condbr_taken;
      112: get_detail_value = `RTU_TOP.rtu_ifu_retire0_mispred;
      113: get_detail_value = `RTU_TOP.rtu_ifu_retire0_jmp_mispred;
      114: get_detail_value = `RTU_TOP.rtu_ifu_retire_inst0_no_spec_miss
                            || `RTU_TOP.rtu_ifu_retire_inst1_no_spec_miss
                            || `RTU_TOP.rtu_ifu_retire_inst2_no_spec_miss;
      115: get_detail_value = `RTU_TOP.rtu_ifu_retire_inst0_no_spec_mispred
                            || `RTU_TOP.rtu_ifu_retire_inst1_no_spec_mispred
                            || `RTU_TOP.rtu_ifu_retire_inst2_no_spec_mispred;
      116: get_detail_value = `RTU_TOP.rtu_ifu_retire_inst0_vl_miss;
      117: get_detail_value = `RTU_TOP.rtu_ifu_retire_inst0_vl_mispred;
      118: get_detail_value = `IU_TOP.iu_idu_mispred_stall;
      119: get_detail_value = `IU_TOP.iu_ifu_mispred_stall;
      120: get_detail_value = `IU_TOP.iu_rtu_pipe2_bht_mispred;
      121: get_detail_value = `IU_TOP.iu_rtu_pipe2_jmp_mispred;

      // I-cache / frontend refill and alignment pressure.
      122: get_detail_value = `IFU_IPCTRL.ip_refill_pre;
      123: get_detail_value = `IFU_IPCTRL.icache_refill_reissue;
      124: get_detail_value = `IFU_IPCTRL.l1_refill_ipctrl_busy;
      125: get_detail_value = `IFU_IPCTRL.miss_under_refill_stall;
      126: get_detail_value = `IFU_IPCTRL.way_mispred_reissue;
      127: get_detail_value = `IFU_IPCTRL.bry_missigned_stall;
      128: get_detail_value = `IFU_IPCTRL.br_more_than_one_stall;

      // LSU cache/TLB/buffer pressure.
      129: get_detail_value = `LSU_TOP.lsu_hpcp_cache_read_access;
      130: get_detail_value = `LSU_TOP.lsu_hpcp_cache_read_miss;
      131: get_detail_value = `LSU_TOP.lsu_hpcp_cache_write_access;
      132: get_detail_value = `LSU_TOP.lsu_hpcp_cache_write_miss;
      133: get_detail_value = `LSU_TOP.ld_ag_utlb_miss;
      134: get_detail_value = `LSU_TOP.st_ag_utlb_miss;
      135: get_detail_value = `LSU_LD_DA.ld_da_inst_vld && `LSU_LD_DA.ld_da_dcache_miss;
      136: get_detail_value = `LSU_ST_DA.st_da_inst_vld && `LSU_ST_DA.st_da_dcache_miss;
      137: get_detail_value = `LSU_LQ.lq_full;
      138: get_detail_value = `LSU_SQ.sq_full;
      139: get_detail_value = `LSU_RB.rb_full;
      140: get_detail_value = `LSU_LFB.lfb_addr_full;
      141: get_detail_value = `LSU_WMB.wmb_ce_bytes_vld_full;

      // Execution pipe utilization and long-latency stalls.
      142: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe0_inst_vld;
      143: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe1_inst_vld;
      144: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe2_inst_vld;
      145: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe3_inst_vld;
      146: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe4_inst_vld;
      147: get_detail_value = `IU_TOP.iu_idu_ex1_pipe1_mult_stall;
      148: get_detail_value = `IU_TOP.iu_idu_div_wb_stall;

      // Remaining RF launch pipes and deeper frontend delivery probes.
      149: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe5_inst_vld;
      150: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe6_inst_vld;
      151: get_detail_value = `IDU_TOP.idu_hpcp_rf_pipe7_inst_vld;
      152: get_detail_value = `IFU_IBCTRL.ibctrl_ibuf_create_vld;
      153: get_detail_value = `IFU_IBCTRL.ibctrl_ibuf_retire_vld;
      154: get_detail_value = `IFU_IBCTRL.ibctrl_lbuf_create_vld;
      155: get_detail_value = `IFU_IBCTRL.ibctrl_lbuf_retire_vld;
      156: get_detail_value = `IFU_IBCTRL.bypass_inst_vld;
      157: get_detail_value = `IFU_IBCTRL.merge_inst_vld;
      158: get_detail_value = `IFU_IBCTRL.ibctrl_pcfifo_if_create_vld;
      159: get_detail_value = `IFU_IBCTRL.ibctrl_pcfifo_if_ind_btb_miss;
      160: get_detail_value = `IFU_IBCTRL.ind_btb_rd_stall;
      161: get_detail_value = `IFU_TOP.ibdp_btb_miss;
      162: get_detail_value = `IFU_IBCTRL.ibctrl_ibdp_l0_btb_miss;

      // Branch predictor side-buffer events.
      163: get_detail_value = `IFU_RAS.ras_push;
      164: get_detail_value = `IFU_RAS.ras_pop;
      165: get_detail_value = `IFU_RAS.ras_empty;
      166: get_detail_value = `IFU_RAS.ras_full;
      167: get_detail_value = `IFU_BHT.bht_wr_buf_create_vld;
      168: get_detail_value = `IFU_BHT.bht_wr_buf_retire_vld;
      169: get_detail_value = `IFU_BHT.buf_full;
      170: get_detail_value = `IFU_BHT.bht_wr_buf_not_empty;

      // I-cache refill latency ingredients.
      171: get_detail_value = `IFU_TOP.l1_refill_ifctrl_start;
      172: get_detail_value = `IFU_TOP.l1_refill_ifctrl_trans_cmplt;
      173: get_detail_value = `IFU_TOP.ipb_l1_refill_data_vld;
      174: get_detail_value = `IFU_TOP.ipb_l1_refill_trans_err;
      175: get_detail_value = `IFU_TOP.l1_refill_ifctrl_refill_on;
      176: get_detail_value = `IFU_TOP.pcgen_l1_refill_chgflw;

      // Retired instruction mix and ROB-head classification.
      177: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_load)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_load)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_load);
      178: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_store)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_store)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_store);
      179: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_split)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_split)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_split);
      180: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_preg_vld)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_preg_vld)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_preg_vld);
      181: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_vreg_vld)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_vreg_vld)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_vreg_vld);
      182: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_ereg_vld)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_ereg_vld)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_ereg_vld);
      183: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_hit)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_hit)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_hit);
      184: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_miss)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_miss)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_miss);
      185: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_mispred)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_mispred)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_mispred);
      186: get_detail_value = (`RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_vl_pred)
                            || (`RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_vl_pred)
                            || (`RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_vl_pred);
      187: get_detail_value = `RTU_TOP.rob_retire_inst0_vld;
      188: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_load;
      189: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_store;
      190: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_bju;
      191: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_condbr;
      192: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_jmp;
      193: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_expt_vld;
      194: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_int_vld;
      195: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_spec_fail;

      // LSU replay/ordering/buffer activity and memory-system request flow.
      196: get_detail_value = `LSU_LQ.lq_create_success;
      197: get_detail_value = `LSU_LQ.lq_create1_success;
      198: get_detail_value = `LSU_WMB.sq_wmb_pop_to_ce_req;
      199: get_detail_value = `LSU_WMB.wmb_ce_create_vld;
      200: get_detail_value = `LSU_WMB.wmb_ce_pop_vld;
      201: get_detail_value = |`LSU_WMB.wmb_entry_write_biu_req[7:0];
      202: get_detail_value = |`LSU_WMB.wmb_entry_write_stall[7:0];
      203: get_detail_value = `LSU_WMB.sq_wmb_merge_req
                              && `LSU_WMB.wmb_merge_data_stall;
      204: get_detail_value = `LSU_WMB.wmb_ld_dc_discard_req;
      205: get_detail_value = `LSU_RB.rb_biu_ar_req;
      206: get_detail_value = `LSU_RB.rb_lfb_create_req;
      207: get_detail_value = `LSU_RB.rb_ld_da_full;
      208: get_detail_value = `LSU_RB.rb_st_da_full;
      209: get_detail_value = |`LSU_LFB.lfb_data_entry_full[1:0];
      210: get_detail_value = |`LSU_LFB.lfb_data_entry_wait_surplus[1:0];
      211: get_detail_value = !(|`LSU_LFB.lfb_addr_entry_vld[7:0]);
      212: get_detail_value = !(|`LSU_LFB.lfb_data_entry_vld[1:0]);

      // BIU / AXI-facing pressure.
      213: get_detail_value = `BIU_READ.biu_pad_arvalid;
      214: get_detail_value = `BIU_READ.biu_pad_arvalid && `BIU_READ.pad_biu_arready;
      215: get_detail_value = `BIU_READ.biu_pad_arvalid && !`BIU_READ.pad_biu_arready;
      216: get_detail_value = `BIU_READ.pad_biu_rvalid;
      217: get_detail_value = `BIU_READ.pad_biu_rvalid && !`BIU_READ.biu_pad_rready;
      218: get_detail_value = `BIU_WRITE.biu_pad_awvalid;
      219: get_detail_value = `BIU_WRITE.biu_pad_wvalid;
      220: get_detail_value = `BIU_WRITE.pad_biu_bvalid;
      221: get_detail_value = `BIU_READ.pad_biu_rvalid && `BIU_READ.biu_pad_rready;
      222: get_detail_value = `BIU_READ.biu_pad_rready;
      223: get_detail_value = `BIU_WRITE.biu_pad_awvalid && `BIU_WRITE.pad_awready;
      224: get_detail_value = `BIU_WRITE.biu_pad_awvalid && !`BIU_WRITE.pad_awready;
      225: get_detail_value = `BIU_WRITE.biu_pad_wvalid && `BIU_WRITE.pad_wready;
      226: get_detail_value = `BIU_WRITE.biu_pad_wvalid && !`BIU_WRITE.pad_wready;
      227: get_detail_value = `BIU_WRITE.biu_pad_bready;
      228: get_detail_value = `BIU_WRITE.pad_biu_bvalid && `BIU_WRITE.biu_pad_bready;
      229: get_detail_value = `BIU_WRITE.pad_biu_bvalid && !`BIU_WRITE.biu_pad_bready;
      230: get_detail_value = `BIU_WRITE.st_awvalid;
      231: get_detail_value = `BIU_WRITE.st_awvalid && !`BIU_WRITE.st_awready;
      232: get_detail_value = `BIU_WRITE.vict_awvalid;
      233: get_detail_value = `BIU_WRITE.vict_awvalid && !`BIU_WRITE.vict_awready;
      234: get_detail_value = `BIU_WRITE.st_wvalid;
      235: get_detail_value = `BIU_WRITE.st_wvalid && !`BIU_WRITE.st_wready;
      236: get_detail_value = `BIU_WRITE.vict_wvalid;
      237: get_detail_value = `BIU_WRITE.vict_wvalid && !`BIU_WRITE.vict_wready;
      238: get_detail_value = `BIU_WRITE.write_busy;

      // Exact retire-slot events for instruction mix and slot pressure.
      239: get_detail_value = `RTU_TOP.rob_retire_inst0_vld;
      240: get_detail_value = `RTU_TOP.rob_retire_inst1_vld;
      241: get_detail_value = `RTU_TOP.rob_retire_inst2_vld;
      242: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_load;
      243: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_load;
      244: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_load;
      245: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_store;
      246: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_store;
      247: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_store;
      248: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_bju;
      249: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_bju;
      250: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_bju;
      251: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_condbr;
      252: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_condbr;
      253: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_condbr;
      254: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_jmp;
      255: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_jmp;
      256: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_jmp;
      257: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_split;
      258: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_split;
      259: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_split;
      260: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_preg_vld;
      261: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_preg_vld;
      262: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_preg_vld;
      263: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_vreg_vld;
      264: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_vreg_vld;
      265: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_vreg_vld;
      266: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_pst_ereg_vld;
      267: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_pst_ereg_vld;
      268: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_pst_ereg_vld;
      269: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_hit;
      270: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_hit;
      271: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_hit;
      272: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_miss;
      273: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_miss;
      274: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_miss;
      275: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_no_spec_mispred;
      276: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_no_spec_mispred;
      277: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_no_spec_mispred;
      278: get_detail_value = `RTU_TOP.rob_retire_inst0_vld && `RTU_TOP.rob_retire_inst0_vl_pred;
      279: get_detail_value = `RTU_TOP.rob_retire_inst1_vld && `RTU_TOP.rob_retire_inst1_vl_pred;
      280: get_detail_value = `RTU_TOP.rob_retire_inst2_vld && `RTU_TOP.rob_retire_inst2_vl_pred;
      281: get_detail_value = (cpi_stack_class() == 3'd1);
      282: get_detail_value = (cpi_stack_class() == 3'd2);
      283: get_detail_value = (cpi_stack_class() == 3'd3);
      284: get_detail_value = (cpi_stack_class() == 3'd4);
      285: get_detail_value = (cpi_stack_class() == 3'd5);
      286: get_detail_value = (cpi_stack_class() == 3'd6);

      // Physical register allocation pressure at rename.
      287: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg0_alloc_vld;
      288: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg1_alloc_vld;
      289: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg2_alloc_vld;
      290: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg3_alloc_vld;
      291: get_detail_value = `RTU_PST_PREG.rtu_idu_alloc_preg0_vld;
      292: get_detail_value = `RTU_PST_PREG.rtu_idu_alloc_preg1_vld;
      293: get_detail_value = `RTU_PST_PREG.rtu_idu_alloc_preg2_vld;
      294: get_detail_value = `RTU_PST_PREG.rtu_idu_alloc_preg3_vld;
      295: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg0_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg0_vld;
      296: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg1_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg1_vld;
      297: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg2_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg2_vld;
      298: get_detail_value = `RTU_PST_PREG.idu_rtu_ir_preg3_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg3_vld;
      299: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg0_alloc_vld;
      300: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg1_alloc_vld;
      301: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg2_alloc_vld;
      302: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg3_alloc_vld;
      303: get_detail_value = `RTU_PST_EREG.rtu_idu_alloc_ereg0_vld;
      304: get_detail_value = `RTU_PST_EREG.rtu_idu_alloc_ereg1_vld;
      305: get_detail_value = `RTU_PST_EREG.rtu_idu_alloc_ereg2_vld;
      306: get_detail_value = `RTU_PST_EREG.rtu_idu_alloc_ereg3_vld;
      307: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg0_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg0_vld;
      308: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg1_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg1_vld;
      309: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg2_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg2_vld;
      310: get_detail_value = `RTU_PST_EREG.idu_rtu_ir_ereg3_alloc_vld && !`RTU_PST_EREG.rtu_idu_alloc_ereg3_vld;
      311: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg0_alloc_vld;
      312: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg1_alloc_vld;
      313: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg2_alloc_vld;
      314: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg3_alloc_vld;
      315: get_detail_value = `RTU_PST_FREG.rtu_idu_alloc_xreg0_vld;
      316: get_detail_value = `RTU_PST_FREG.rtu_idu_alloc_xreg1_vld;
      317: get_detail_value = `RTU_PST_FREG.rtu_idu_alloc_xreg2_vld;
      318: get_detail_value = `RTU_PST_FREG.rtu_idu_alloc_xreg3_vld;
      319: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg0_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg0_vld;
      320: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg1_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg1_vld;
      321: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg2_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg2_vld;
      322: get_detail_value = `RTU_PST_FREG.idu_rtu_ir_xreg3_alloc_vld && !`RTU_PST_FREG.rtu_idu_alloc_xreg3_vld;
      323: get_detail_value = `RTU_PST_PREG.rtu_idu_pst_empty;
      324: get_detail_value = &`RTU_PST_EREG.rtu_idu_pst_ereg_retired_released_wb[31:0];
      325: get_detail_value = `RTU_PST_FREG.pst_retired_xreg_wb;

      // VFPU/vector execution flow.
      326: get_detail_value = `VFPU_TOP.idu_vfpu_rf_pipe6_sel;
      327: get_detail_value = `VFPU_TOP.idu_vfpu_rf_pipe7_sel;
      328: get_detail_value = `VFPU_TOP.idu_vfpu_rf_pipe6_gateclk_sel;
      329: get_detail_value = `VFPU_TOP.idu_vfpu_rf_pipe7_gateclk_sel;
      330: get_detail_value = `VFPU_TOP.idu_vfpu_is_vdiv_issue;
      331: get_detail_value = `VFPU_TOP.idu_vfpu_is_vdiv_gateclk_issue;
      332: get_detail_value = `VFPU_TOP.vfdsu_ifu_debug_pipe_busy;
      333: get_detail_value = `VFPU_TOP.vfdsu_ifu_debug_ex2_wait;
      334: get_detail_value = `VFPU_TOP.vfdsu_ifu_debug_idle;
      335: get_detail_value = `VFPU_TOP.vfpu_idu_ex1_pipe6_data_vld_dup0;
      336: get_detail_value = `VFPU_TOP.vfpu_idu_ex1_pipe7_data_vld_dup0;
      337: get_detail_value = `VFPU_TOP.vfpu_idu_ex2_pipe6_data_vld_dup0;
      338: get_detail_value = `VFPU_TOP.vfpu_idu_ex2_pipe7_data_vld_dup0;
      339: get_detail_value = `VFPU_TOP.vfpu_idu_ex3_pipe6_data_vld_dup0;
      340: get_detail_value = `VFPU_TOP.vfpu_idu_ex3_pipe7_data_vld_dup0;
      341: get_detail_value = `VFPU_TOP.vfpu_idu_ex3_pipe6_fwd_vreg_vld;
      342: get_detail_value = `VFPU_TOP.vfpu_idu_ex3_pipe7_fwd_vreg_vld;
      343: get_detail_value = `VFPU_TOP.vfpu_idu_ex4_pipe6_fwd_vreg_vld;
      344: get_detail_value = `VFPU_TOP.vfpu_idu_ex4_pipe7_fwd_vreg_vld;
      345: get_detail_value = `VFPU_TOP.vfpu_idu_ex5_pipe6_fwd_vreg_vld;
      346: get_detail_value = `VFPU_TOP.vfpu_idu_ex5_pipe7_fwd_vreg_vld;
      347: get_detail_value = `VFPU_TOP.vfpu_rtu_ex5_pipe6_ereg_wb_vld;
      348: get_detail_value = `VFPU_TOP.vfpu_rtu_ex5_pipe7_ereg_wb_vld;
      349: get_detail_value = `VFPU_TOP.vfpu_rtu_ex5_pipe6_wb_vreg_fr_vld;
      350: get_detail_value = `VFPU_TOP.vfpu_rtu_ex5_pipe7_wb_vreg_fr_vld;
      351: get_detail_value = `VFPU_TOP.vfpu_rtu_ex5_pipe6_wb_vreg_vr_vld;
      352: get_detail_value = `VFPU_TOP.vfpu_rtu_ex5_pipe7_wb_vreg_vr_vld;
      353: get_detail_value = `VFPU_TOP.vfpu_idu_pipe6_vmla_srcv2_no_fwd;
      354: get_detail_value = `VFPU_TOP.vfpu_idu_pipe7_vmla_srcv2_no_fwd;

      // LSU prefetch, victim buffer, replay/discard pressure.
      355: get_detail_value = `LSU_LD_DA.ld_da_pfu_act_vld;
      356: get_detail_value = `LSU_ST_DA.st_da_pfu_act_vld;
      357: get_detail_value = `LSU_LD_DA.ld_da_pfu_pf_inst_vld;
      358: get_detail_value = `LSU_ST_DA.st_da_pfu_pf_inst_vld;
      359: get_detail_value = `LSU_PFU.pfu_biu_ar_req;
      360: get_detail_value = `LSU_PFU.pfu_lfb_create_req;
      361: get_detail_value = `LSU_PFU.pfu_lfb_create_vld;
      362: get_detail_value = `LSU_PFU.pfu_biu_req_unmask;
      363: get_detail_value = `LSU_PFU.pfu_biu_req_hit_idx;
      364: get_detail_value = `LSU_PFU.pfu_pfb_empty;
      365: get_detail_value = `LSU_PFU.pfu_sdb_empty;
      366: get_detail_value = `LSU_PFU.pfu_pmb_empty;
      367: get_detail_value = `LSU_PFU.pfu_part_empty;
      368: get_detail_value = `LSU_PFU.pfu_pop_all_vld;
      369: get_detail_value = `LSU_PFU.pfu_biu_pe_req_grnt;
      370: get_detail_value = `LSU_VB.vb_empty;
      371: get_detail_value = `LSU_VB.vb_addr_full;
      372: get_detail_value = `LSU_VB.vb_data_full;
      373: get_detail_value = `LSU_VB.lfb_vb_create_vld;
      374: get_detail_value = `LSU_VB.wmb_vb_create_vld;
      375: get_detail_value = `LSU_VB.icc_vb_create_vld;
      376: get_detail_value = `LSU_VB.vb_biu_aw_req;
      377: get_detail_value = `LSU_VB.vb_biu_w_req;
      378: get_detail_value = `LSU_VB.vb_dcache_arb_ld_req;
      379: get_detail_value = `LSU_VB.vb_dcache_arb_st_req;
      380: get_detail_value = `LSU_LD_DA.ld_da_lfb_discard_grnt;
      381: get_detail_value = `LSU_LD_DA.ld_da_lm_discard_grnt;
      382: get_detail_value = `LSU_LD_DA.ld_da_rb_discard_grnt;
      383: get_detail_value = `LSU_LD_DA.ld_da_sq_data_discard_vld;
      384: get_detail_value = `LSU_LD_DA.ld_da_sq_global_discard_vld;
      385: get_detail_value = `LSU_LD_DA.ld_da_wmb_discard_vld;
      386: get_detail_value = `LSU_LD_DA.ld_da_wb_spec_fail;
      387: get_detail_value = `LSU_ST_DA.st_da_wb_spec_fail;
      388: get_detail_value = `LSU_LD_DA.lsu_hpcp_ld_data_discard;
      389: get_detail_value = `LSU_LD_DA.lsu_hpcp_ld_discard_sq;
      390: get_detail_value = `LSU_LD_DA.ld_da_pfu_biu_req_hit_idx;
      391: get_detail_value = `LSU_ST_DA.st_da_pfu_biu_req_hit_idx;

      // Dispatch into issue queues and dispatch-side structural blocking.
      392: get_detail_value = `IDU_IS_CTRL.ctrl_is_dis_stall;
      393: get_detail_value = `IDU_IS_CTRL.ctrl_is_rob_full;
      394: get_detail_value = `IDU_IS_CTRL.ctrl_top_is_iq_full;
      395: get_detail_value = `IDU_IS_CTRL.ctrl_top_is_vmb_full;
      396: get_detail_value = `IDU_IS_CTRL.ctrl_is_aiq0_full_updt;
      397: get_detail_value = `IDU_IS_CTRL.ctrl_is_aiq1_full_updt;
      398: get_detail_value = `IDU_IS_CTRL.ctrl_is_biq_full_updt;
      399: get_detail_value = `IDU_IS_CTRL.ctrl_is_lsiq_full_updt;
      400: get_detail_value = `IDU_IS_CTRL.ctrl_is_sdiq_full_updt;
      401: get_detail_value = `IDU_IS_CTRL.ctrl_is_viq0_full_updt;
      402: get_detail_value = `IDU_IS_CTRL.ctrl_is_viq1_full_updt;
      403: get_detail_value = `IDU_IS_CTRL.ctrl_aiq0_create0_en;
      404: get_detail_value = `IDU_IS_CTRL.ctrl_aiq0_create1_en;
      405: get_detail_value = `IDU_IS_CTRL.ctrl_aiq1_create0_en;
      406: get_detail_value = `IDU_IS_CTRL.ctrl_aiq1_create1_en;
      407: get_detail_value = `IDU_IS_CTRL.ctrl_biq_create0_en;
      408: get_detail_value = `IDU_IS_CTRL.ctrl_biq_create1_en;
      409: get_detail_value = `IDU_IS_CTRL.ctrl_lsiq_create0_en;
      410: get_detail_value = `IDU_IS_CTRL.ctrl_lsiq_create1_en;
      411: get_detail_value = `IDU_IS_CTRL.ctrl_sdiq_create0_en;
      412: get_detail_value = `IDU_IS_CTRL.ctrl_sdiq_create1_en;
      413: get_detail_value = `IDU_IS_CTRL.ctrl_viq0_create0_en;
      414: get_detail_value = `IDU_IS_CTRL.ctrl_viq0_create1_en;
      415: get_detail_value = `IDU_IS_CTRL.ctrl_viq1_create0_en;
      416: get_detail_value = `IDU_IS_CTRL.ctrl_viq1_create1_en;

      // Issue queue pop into RF/LSU execution side.
      417: get_detail_value = `IDU_RF_CTRL.ctrl_aiq0_rf_pop_vld;
      418: get_detail_value = `IDU_RF_CTRL.ctrl_aiq1_rf_pop_vld;
      419: get_detail_value = `IDU_RF_CTRL.ctrl_biq_rf_pop_vld;
      420: get_detail_value = `IDU_TOP.lsu_idu_lsiq_pop_vld;
      421: get_detail_value = `IDU_TOP.lsu_idu_ex1_sdiq_pop_vld;
      422: get_detail_value = `IDU_RF_CTRL.ctrl_viq0_rf_pop_vld;
      423: get_detail_value = `IDU_RF_CTRL.ctrl_viq1_rf_pop_vld;
      424: get_detail_value = `IDU_RF_CTRL.ctrl_aiq0_rf_pop_dlb_vld;
      425: get_detail_value = `IDU_RF_CTRL.ctrl_aiq1_rf_pop_dlb_vld;
      426: get_detail_value = `IDU_RF_CTRL.ctrl_viq0_rf_pop_dlb_vld;
      427: get_detail_value = `IDU_RF_CTRL.ctrl_viq1_rf_pop_dlb_vld;

      // D-cache arbiter request/selection pressure by source.
      428: get_detail_value = `LSU_DCA.lfb_dcache_arb_ld_req;
      429: get_detail_value = `LSU_DCA.vb_dcache_arb_ld_req;
      430: get_detail_value = `LSU_DCA.snq_dcache_arb_ld_req;
      431: get_detail_value = `LSU_DCA.icc_dcache_arb_ld_req;
      432: get_detail_value = `LSU_DCA.wmb_dcache_arb_ld_req;
      433: get_detail_value = `LSU_DCA.mcic_dcache_arb_ld_req;
      434: get_detail_value = `LSU_DCA.ag_dcache_arb_ld_tag_req || (|`LSU_DCA.ag_dcache_arb_ld_data_req[7:0]);
      435: get_detail_value = `LSU_DCA.dcache_arb_lfb_ld_grnt;
      436: get_detail_value = `LSU_DCA.dcache_arb_vb_ld_grnt;
      437: get_detail_value = `LSU_DCA.dcache_arb_snq_ld_grnt;
      438: get_detail_value = `LSU_DCA.dcache_arb_icc_ld_grnt;
      439: get_detail_value = `LSU_DCA.dcache_arb_wmb_ld_grnt;
      440: get_detail_value = `LSU_DCA.dcache_arb_mcic_ld_grnt;
      441: get_detail_value = `LSU_DCA.dcache_arb_ag_ld_sel;
      442: get_detail_value = `LSU_DCA.lfb_dcache_arb_st_req;
      443: get_detail_value = `LSU_DCA.vb_dcache_arb_st_req;
      444: get_detail_value = `LSU_DCA.snq_dcache_arb_st_req;
      445: get_detail_value = `LSU_DCA.icc_dcache_arb_st_req;
      446: get_detail_value = `LSU_DCA.wmb_dcache_arb_st_req;
      447: get_detail_value = `LSU_DCA.ag_dcache_arb_st_tag_req || `LSU_DCA.ag_dcache_arb_st_dirty_req;
      448: get_detail_value = `LSU_DCA.dcache_arb_lfb_st_sel;
      449: get_detail_value = `LSU_DCA.dcache_arb_vb_st_grnt;
      450: get_detail_value = `LSU_DCA.dcache_arb_snq_st_grnt;
      451: get_detail_value = `LSU_DCA.dcache_arb_icc_st_sel;
      452: get_detail_value = `LSU_DCA.dcache_arb_wmb_st_sel;
      453: get_detail_value = `LSU_DCA.dcache_arb_ag_st_sel;
      454: get_detail_value = `LSU_DCA.dcache_arb_serial_req;
      455: get_detail_value = `LSU_DCA.dcache_arb_serial_vld;
      456: get_detail_value = `LSU_DCA.dcache_arb_ld_dc_borrow_vld;
      457: get_detail_value = `LSU_DCA.dcache_arb_st_dc_borrow_vld;
      458: get_detail_value = `LSU_DCA.dcache_arb_ld_tag_req;
      459: get_detail_value = |`LSU_DCA.dcache_arb_ld_data_req[7:0];
      460: get_detail_value = `LSU_DCA.dcache_arb_st_tag_req;
      461: get_detail_value = `LSU_DCA.dcache_arb_st_dirty_req;

      // Store queue forwarding/dependency/discard detail.
      462: get_detail_value = `LSU_SQ.sq_create_success;
      463: get_detail_value = |`LSU_SQ.sq_create_vld[11:0];
      464: get_detail_value = `LSU_SQ.sq_pop_to_ce_req;
      465: get_detail_value = `LSU_SQ.sq_wmb_merge_stall_req;
      466: get_detail_value = `LSU_SQ.sq_ld_dc_data_discard_req;
      467: get_detail_value = `LSU_SQ.sq_ld_dc_other_discard_req;
      468: get_detail_value = `LSU_SQ.sq_ld_dc_newest_fwd_data_vld_req;
      469: get_detail_value = `LSU_SQ.sq_ld_dc_addr1_dep_discard;

      // LFB linefill, dependency wakeup, and refill-to-D-cache flow.
      470: get_detail_value = `LSU_LFB.lfb_empty;
      471: get_detail_value = |`LSU_LFB.lfb_addr_entry_pop_vld[7:0];
      472: get_detail_value = |`LSU_LFB.lfb_addr_entry_discard_vld[7:0];
      473: get_detail_value = |`LSU_LFB.lfb_addr_entry_dcache_hit[7:0];
      474: get_detail_value = `LSU_LFB.lfb_ld_da_hit_idx;
      475: get_detail_value = `LSU_LFB.lfb_st_da_hit_idx;
      476: get_detail_value = `LSU_LFB.lfb_pfu_biu_req_hit_idx;
      477: get_detail_value = `LSU_LFB.lfb_rb_biu_req_hit_idx;
      478: get_detail_value = `LSU_WMB.wmb_read_req_unmask
                              && `LSU_LFB.lfb_wmb_read_req_hit_idx;
      479: get_detail_value = `LSU_WMB.wmb_write_req
                              && `LSU_LFB.lfb_wmb_write_req_hit_idx;
      480: get_detail_value = `LSU_LFB.lfb_vb_create_req;
      481: get_detail_value = `LSU_LFB.lfb_vb_create_vld;
      482: get_detail_value = `LSU_LFB.lfb_vb_pe_req;
      483: get_detail_value = |`LSU_LFB.lfb_addr_entry_vb_pe_req_grnt[7:0];
      484: get_detail_value = `LSU_LFB.lfb_data_create_vld;
      485: get_detail_value = `LSU_LFB.lfb_data_not_full;
      486: get_detail_value = `LSU_LFB.lfb_lf_sm_vld;
      487: get_detail_value = `LSU_LFB.lfb_lf_sm_req;
      488: get_detail_value = `LSU_LFB.lfb_lf_sm_create_vld;
      489: get_detail_value = `LSU_LFB.lfb_lf_sm_refill_wakeup;
      490: get_detail_value = |`LSU_LFB.lfb_lf_sm_data_grnt[1:0];
      491: get_detail_value = |`LSU_LFB.lfb_lf_sm_data_pop_req[1:0];
      492: get_detail_value = `LSU_LFB.lfb_biu_r_id_hit;
      493: get_detail_value = `LSU_LFB.lfb_ca_rready_grnt;
      494: get_detail_value = `LSU_LFB.lfb_nc_rready_grnt;
      495: get_detail_value = `LSU_LFB.lfb_pfu_rready_grnt;
      496: get_detail_value = `LSU_LFB.lfb_pop_depd_ff;
      497: get_detail_value = |`LSU_LFB.lfb_depd_wakeup[11:0];
      498: get_detail_value = `LSU_LFB.lfb_mcic_wakeup;
      499: get_detail_value = `LSU_LFB.lfb_snq_bypass_hit;
      500: get_detail_value = `LSU_LFB.lfb_no_rcl_cnt_updt_vld;
      501: get_detail_value = |`LSU_LFB.lfb_addr_entry_not_resp[7:0];

      // WMB writeback, forwarding, dependency wakeup, and BIU grant flow.
      502: get_detail_value = `LSU_WMB.wmb_empty;
      503: get_detail_value = `LSU_WMB.wmb_create_vld;
      504: get_detail_value = `LSU_WMB.wmb_biu_ar_req;
      505: get_detail_value = `LSU_WMB.wmb_biu_aw_req;
      506: get_detail_value = `LSU_WMB.wmb_biu_w_req;
      507: get_detail_value = `LSU_WMB.wmb_biu_nc_req_grnt;
      508: get_detail_value = `LSU_WMB.wmb_biu_so_req_grnt;
      509: get_detail_value = `LSU_WMB.wmb_mem_set_write_grnt;
      510: get_detail_value = `LSU_WMB.wmb_vb_create_req;
      511: get_detail_value = `LSU_WMB.wmb_vb_create_vld;
      512: get_detail_value = `LSU_WMB.wmb_st_wb_cmplt_req;
      513: get_detail_value = `LSU_WMB.wmb_st_wb_spec_fail;
      514: get_detail_value = `LSU_WMB.wmb_ld_wb_data_req;
      515: get_detail_value = `LSU_WMB.wmb_ld_dc_fwd_req;
      516: get_detail_value = `LSU_WMB.wmb_ld_dc_cancel_acc_req;
      517: get_detail_value = `LSU_WMB.wmb_pop_depd;
      518: get_detail_value = `LSU_WMB.wmb_pop_discard_req;
      519: get_detail_value = `LSU_WMB.wmb_pop_fwd_req;
      520: get_detail_value = `LSU_WMB.wmb_wakeup_queue_not_empty;
      521: get_detail_value = |`LSU_WMB.wmb_depd_wakeup[11:0];
      522: get_detail_value = `LSU_WMB.wmb_b_nc_id_hit;
      523: get_detail_value = `LSU_WMB.wmb_b_so_id_hit;
      524: get_detail_value = `LSU_WMB.wmb_sync_fence_biu_req_success;
      525: get_detail_value = `LSU_WMB.wmb_has_sync_fence;

      // RB refill request, hit, LFB-create, and load writeback flow.
      526: get_detail_value = `LSU_RB.rb_empty;
      527: get_detail_value = `LSU_RB.rb_full;
      528: get_detail_value = `LSU_RB.rb_create_ld_success;
      529: get_detail_value = `LSU_RB.rb_create_st_success;
      530: get_detail_value = `LSU_RB.rb_biu_req_unmask;
      531: get_detail_value = `LSU_RB.rb_biu_ar_req;
      532: get_detail_value = `LSU_RB.rb_biu_req_hit_idx;
      533: get_detail_value = `LSU_RB.rb_biu_nc_req_grnt;
      534: get_detail_value = `LSU_RB.rb_biu_so_req_grnt;
      535: get_detail_value = `LSU_RB.rb_lfb_create_vld;
      536: get_detail_value = `LSU_RB.rb_lfb_boundary_depd_wakeup;
      537: get_detail_value = `LSU_RB.rb_lfb_depd;
      538: get_detail_value = `LSU_RB.rb_pfu_biu_req_hit_idx;
      539: get_detail_value = `LSU_RB.rb_wmb_ce_hit_idx;
      540: get_detail_value = `LSU_RB.rb_ld_da_hit_idx;
      541: get_detail_value = `LSU_RB.rb_st_da_hit_idx;
      542: get_detail_value = `LSU_RB.rb_ld_da_merge_fail;
      543: get_detail_value = `LSU_RB.rb_ld_wb_cmplt_req;
      544: get_detail_value = `LSU_RB.rb_ld_wb_data_req_unmask;
      545: get_detail_value = |`LSU_RB.rb_entry_read_req_grnt[7:0];
      546: get_detail_value = |`LSU_RB.rb_entry_wb_cmplt_req[7:0];
      547: get_detail_value = |`LSU_RB.rb_entry_wb_data_req[7:0];
      548: get_detail_value = |`LSU_RB.rb_entry_discard_vld[7:0];
      549: get_detail_value = |`LSU_RB.rb_entry_boundary_wakeup[7:0];
      550: get_detail_value = `LSU_RB.rb_pfu_nc_no_pending;
      551: get_detail_value = `RTU_ROB_RT.rob_commit0;
      552: get_detail_value = `RTU_ROB_RT.rob_commit1;
      553: get_detail_value = `RTU_ROB_RT.rob_commit2;
      554: get_detail_value = (rob_commit_width() == 8'd0);
      555: get_detail_value = (rob_commit_width() == 8'd1);
      556: get_detail_value = (rob_commit_width() == 8'd2);
      557: get_detail_value = (rob_commit_width() == 8'd3);
      558: get_detail_value = `RTU_ROB_RT.rob_read0_inst_vld;
      559: get_detail_value = `RTU_ROB_RT.rob_read0_cmplted;
      560: get_detail_value = `RTU_ROB_RT.rob_read0_commit;
      561: get_detail_value = `RTU_ROB_RT.rtu_had_inst_exe_dead;
      562: get_detail_value = `RTU_ROB_RT.rob_read0_expt_entry_vld;
      563: get_detail_value = `RTU_ROB_RT.rob_commit0_mask;
      564: get_detail_value = `RTU_ROB_RT.rob_commit1_mask;
      565: get_detail_value = `RTU_ROB_RT.rob_commit2_mask;
      566: get_detail_value = `RTU_ROB_RT.rob_read0_pipe0_cmplt;
      567: get_detail_value = `RTU_ROB_RT.rob_read0_pipe1_cmplt;
      568: get_detail_value = `RTU_ROB_RT.rob_read0_pipe2_cmplt;
      569: get_detail_value = `RTU_ROB_RT.rob_read0_pipe3_cmplt;
      570: get_detail_value = `RTU_ROB_RT.rob_read0_pipe4_cmplt;
      571: get_detail_value = `RTU_ROB_RT.rob_read0_pipe6_cmplt;
      572: get_detail_value = `RTU_ROB_RT.rob_read0_pipe7_cmplt;
      573: get_detail_value = `RTU_ROB_RT.rob_read0_cmplted_no_spec_hit;
      574: get_detail_value = `RTU_ROB_RT.rob_read0_cmplted_no_spec_miss;
      575: get_detail_value = `RTU_ROB_RT.rob_read0_cmplted_no_spec_mispred;
      576: get_detail_value = `RTU_RETIRE.retire_async_expt;
      577: get_detail_value = `RTU_RETIRE.retire_async_expt_no_commit;
      578: get_detail_value = `RTU_RETIRE.retire_async_expt_no_retire;
      579: get_detail_value = `RTU_RETIRE.retire_async_expt_vld;
      580: get_detail_value = `RTU_RETIRE.lsu_rtu_all_commit_data_vld;
      581: get_detail_value = `RTU_RETIRE.retire_inst0_flush;
      582: get_detail_value = `RTU_RETIRE.retire_inst0_mispred;
      583: get_detail_value = `RTU_RETIRE.retire_rob_flush;
      584: get_detail_value = |`IDU_IS_AIQ0.aiq0_entry_ready[7:0];
      585: get_detail_value = |`IDU_IS_AIQ1.aiq1_entry_ready[7:0];
      586: get_detail_value = |`IDU_IS_BIQ.biq_entry_ready[11:0];
      587: get_detail_value = |`IDU_IS_LSIQ.lsiq_entry_ready[11:0];
      588: get_detail_value = |`IDU_IS_SDIQ.sdiq_entry_ready[11:0];
      589: get_detail_value = |`IDU_IS_VIQ0.viq0_entry_ready[7:0];
      590: get_detail_value = |`IDU_IS_VIQ1.viq1_entry_ready[7:0];
      591: get_detail_value = |(`IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0]);
      592: get_detail_value = |(`IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0]);
      593: get_detail_value = |(`IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0]);
      594: get_detail_value = |(`IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0]);
      595: get_detail_value = |(`IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0]);
      596: get_detail_value = |(`IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0]);
      597: get_detail_value = |(`IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0]);
      598: get_detail_value = |`IDU_IS_AIQ0.aiq0_entry_issue_en[7:0];
      599: get_detail_value = |`IDU_IS_AIQ1.aiq1_entry_issue_en[7:0];
      600: get_detail_value = |`IDU_IS_BIQ.biq_entry_issue_en[11:0];
      601: get_detail_value = |`IDU_IS_LSIQ.lsiq_entry_issue_en[11:0];
      602: get_detail_value = |`IDU_IS_SDIQ.sdiq_entry_issue_en[11:0];
      603: get_detail_value = |`IDU_IS_VIQ0.viq0_entry_issue_en[7:0];
      604: get_detail_value = |`IDU_IS_VIQ1.viq1_entry_issue_en[7:0];
      605: get_detail_value = `MMU_TOP.mmu_hpcp_iutlb_miss;
      606: get_detail_value = `MMU_TOP.mmu_hpcp_dutlb_miss;
      607: get_detail_value = `MMU_TOP.mmu_hpcp_jtlb_miss;
      608: get_detail_value = `MMU_TOP.ifu_mmu_va_vld;
      609: get_detail_value = `MMU_TOP.mmu_ifu_pavld;
      610: get_detail_value = `MMU_TOP.lsu_mmu_va0_vld;
      611: get_detail_value = `MMU_TOP.lsu_mmu_va1_vld;
      612: get_detail_value = `MMU_TOP.lsu_mmu_va2_vld;
      613: get_detail_value = `MMU_TOP.mmu_lsu_pa0_vld;
      614: get_detail_value = `MMU_TOP.mmu_lsu_pa1_vld;
      615: get_detail_value = `MMU_TOP.mmu_lsu_pa2_vld;
      616: get_detail_value = `MMU_TOP.mmu_lsu_stall0;
      617: get_detail_value = `MMU_TOP.mmu_lsu_stall1;
      618: get_detail_value = `MMU_TOP.mmu_lsu_tlb_busy;
      619: get_detail_value = `MMU_TOP.iutlb_arb_req;
      620: get_detail_value = `MMU_TOP.iutlb_arb_cmplt;
      621: get_detail_value = `MMU_TOP.dutlb_arb_req;
      622: get_detail_value = `MMU_TOP.dutlb_arb_cmplt;
      623: get_detail_value = `MMU_TOP.jtlb_ptw_req;
      624: get_detail_value = `MMU_TOP.ptw_arb_req;
      625: get_detail_value = `MMU_TOP.ptw_jtlb_imiss;
      626: get_detail_value = `MMU_TOP.ptw_jtlb_dmiss;
      627: get_detail_value = `MMU_TOP.ptw_jtlb_pmiss;
      628: get_detail_value = `MMU_TOP.ptw_jtlb_ref_cmplt;
      629: get_detail_value = `MMU_TOP.ptw_jtlb_ref_data_vld;
      630: get_detail_value = `MMU_TOP.mmu_lsu_data_req;
      631: get_detail_value = `MMU_TOP.lsu_mmu_data_vld;
      632: get_detail_value = `MMU_TOP.ptw_top_imiss;
      633: get_detail_value = `MMU_TOP.jtlb_arb_tc_miss;
      634: get_detail_value = `MMU_TOP.jtlb_arb_sel_4k;
      635: get_detail_value = `MMU_TOP.jtlb_arb_sel_2m;
      636: get_detail_value = `MMU_TOP.jtlb_arb_sel_1g;
      637: get_detail_value = (`MMU_TOP.lsu_mmu_va0_vld
                               && `MMU_TOP.mmu_lsu_page_fault0)
                              || (`MMU_TOP.lsu_mmu_va1_vld
                                  && `MMU_TOP.mmu_lsu_page_fault1);
      638: get_detail_value = (`RTU_TOP.rtu_had_debug_info[24:18] < 7'd32);
      639: get_detail_value = (`RTU_TOP.rtu_had_debug_info[24:18] >= 7'd32) && (`RTU_TOP.rtu_had_debug_info[24:18] < 7'd64);
      640: get_detail_value = (`RTU_TOP.rtu_had_debug_info[24:18] >= 7'd64);
      641: get_detail_value = (retire_width() == 4'd0) && stack_bad_spec();
      642: get_detail_value = (retire_width() == 4'd0) && stack_frontend_bound();
      643: get_detail_value = (retire_width() == 4'd0) && stack_memory_bound();
      644: get_detail_value = (retire_width() == 4'd0) && stack_backend_core_bound();
      645: get_detail_value = (retire_width() == 4'd0) && (cpi_raw_cause_width() > 3'd1);
      646: get_detail_value = (retire_width() == 4'd0) && (cpi_raw_cause_width() == 3'd0);
      647: get_detail_value = `IFU_IBCTRL.ibctrl_ibdp_l0_btb_hit;
      648: get_detail_value = `IFU_IBCTRL.ibctrl_ibdp_l0_btb_miss;
      649: get_detail_value = `IFU_IBCTRL.ibctrl_ibdp_l0_btb_mispred;
      650: get_detail_value = `IFU_IBCTRL.ibctrl_ibdp_l0_btb_wait;
      651: get_detail_value = `IFU_IBCTRL.ibctrl_ind_btb_check_vld;
      652: get_detail_value = `IFU_IBCTRL.ibctrl_ind_btb_fifo_stall;
      653: get_detail_value = `IFU_IBCTRL.ibctrl_pcfifo_if_ind_btb_miss;
      654: get_detail_value = `IFU_IBCTRL.ibctrl_pcfifo_if_ras_vld;
      655: get_detail_value = `IFU_IBCTRL.ibdp_ibctrl_ras_mistaken;
      656: get_detail_value = `IFU_IBCTRL.ibctrl_lbuf_bju_mispred;
      657: get_detail_value = `IFU_BHT.bht_pred_array_rd;
      658: get_detail_value = `IFU_BHT.bht_sel_array_rd;
      659: get_detail_value = `IFU_BHT.wr_buf_hit;
      660: get_detail_value = `IFU_BHT.bju_mispred;
      661: get_detail_value = `LSU_WMB.wmb_ld_dc_fwd_req;
      662: get_detail_value = `LSU_WMB.wmb_ld_dc_cancel_acc_req;
      663: get_detail_value = `LSU_SQ.sq_ld_dc_newest_fwd_data_vld_req;
      664: get_detail_value = `LSU_SQ.sq_ld_dc_data_discard_req;
      665: get_detail_value = `LSU_SQ.sq_ld_dc_other_discard_req;
      666: get_detail_value = `LSU_SQ.sq_ld_dc_addr1_dep_discard;
      667: get_detail_value = `LSU_LD_DA.ld_da_sq_data_discard_vld;
      668: get_detail_value = `LSU_LD_DA.ld_da_sq_global_discard_vld;
      669: get_detail_value = `LSU_LD_DA.ld_da_wmb_discard_vld;
      670: get_detail_value = `LSU_LD_DA.ld_da_wb_spec_fail || `LSU_ST_DA.st_da_wb_spec_fail;
      671: get_detail_value = |`LSU_LFB.lfb_addr_entry_rb_create_vld[7:0];
      672: get_detail_value = |`LSU_LFB.lfb_addr_entry_pfu_create_vld[7:0];
      673: get_detail_value = |`LSU_LFB.lfb_addr_entry_pop_vld[7:0];
      674: get_detail_value = `LSU_LFB.lfb_data_create_vld;
      675: get_detail_value = |`LSU_WMB.wmb_entry_create_vld[7:0];
      676: get_detail_value = |`LSU_WMB.wmb_entry_pop_vld[7:0];
      677: get_detail_value = |`LSU_SQ.sq_create_vld[11:0];
      678: get_detail_value = |`LSU_SQ.sq_entry_pop_to_ce_grnt[11:0];
      679: get_detail_value = (biu_rd_outstanding != 8'd0);
      680: get_detail_value = (biu_rd_outstanding >= 8'd2);
      681: get_detail_value = (biu_wr_outstanding != 8'd0);
      682: get_detail_value = (biu_wr_outstanding >= 8'd2);
      683: get_detail_value = `BIU_READ.biu_pad_arvalid && `BIU_READ.pad_biu_arready;
      684: get_detail_value = `BIU_READ.pad_biu_rvalid && `BIU_READ.biu_pad_rready && `BIU_READ.pad_biu_rlast;
      685: get_detail_value = `BIU_WRITE.biu_pad_awvalid && `BIU_WRITE.pad_awready;
      686: get_detail_value = `BIU_WRITE.pad_biu_bvalid && `BIU_WRITE.biu_pad_bready;
      687: get_detail_value = `RTU_PST_PREG.retire_pst_async_flush;
      688: get_detail_value = |`RTU_PST_PREG.rtu_idu_rt_recover_preg[223:0];
      689: get_detail_value = |`RTU_PST_EREG.rtu_idu_rt_recover_ereg[4:0];
      690: get_detail_value = `RTU_PST_PREG.pst_retired_preg_wb;
      691: get_detail_value = `RTU_PST_PREG.rtu_idu_pst_empty;
      692: get_detail_value = (preg_alloc_avail_width() == 8'd0);
      693: get_detail_value = (preg_alloc_avail_width() == 8'd4);
      694: get_detail_value = (ereg_alloc_avail_width() == 8'd0);
      695: get_detail_value = (ereg_alloc_avail_width() == 8'd4);
      696: get_detail_value = `RTU_RETIRE.retire_rob_flush && !`IFU_IFCTRL.ifctrl_ipctrl_vld;
      697: get_detail_value = `RTU_RETIRE.retire_rob_flush && !`IDU_ID_CTRL.ctrl_top_id_inst0_vld;
      698: get_detail_value = `IFU_IFCTRL.ifctrl_ipctrl_vld;
      699: get_detail_value = `IDU_ID_CTRL.ctrl_top_id_inst0_vld;
      700: get_detail_value = `RTU_TOP.rtu_yy_xx_flush && (retire_width() == 4'd0);
      701: get_detail_value = (aiq0_src0_not_ready_width() != 8'd0);
      702: get_detail_value = (aiq0_src1_not_ready_width() != 8'd0);
      703: get_detail_value = (aiq0_src2_not_ready_width() != 8'd0);
      704: get_detail_value = (aiq1_src0_not_ready_width() != 8'd0);
      705: get_detail_value = (aiq1_src1_not_ready_width() != 8'd0);
      706: get_detail_value = (aiq1_src2_not_ready_width() != 8'd0);
      707: get_detail_value = (biq_src0_not_ready_width() != 8'd0);
      708: get_detail_value = (biq_src1_not_ready_width() != 8'd0);
      709: get_detail_value = (lsiq_src0_not_ready_width() != 8'd0);
      710: get_detail_value = (lsiq_src1_not_ready_width() != 8'd0);
      711: get_detail_value = (lsiq_srcvm_not_ready_width() != 8'd0);
      712: get_detail_value = (sdiq_src0_not_ready_width() != 8'd0);
      713: get_detail_value = (sdiq_srcv0_not_ready_width() != 8'd0);
      714: get_detail_value = (sdiq_staddr_not_ready_width() != 8'd0);
      715: get_detail_value = (viq0_srcv0_not_ready_width() != 8'd0);
      716: get_detail_value = (viq0_srcv1_not_ready_width() != 8'd0);
      717: get_detail_value = (viq0_srcv2_not_ready_width() != 8'd0);
      718: get_detail_value = (viq0_srcvm_not_ready_width() != 8'd0);
      719: get_detail_value = (viq1_srcv0_not_ready_width() != 8'd0);
      720: get_detail_value = (viq1_srcv1_not_ready_width() != 8'd0);
      721: get_detail_value = (viq1_srcv2_not_ready_width() != 8'd0);
      722: get_detail_value = (viq1_srcvm_not_ready_width() != 8'd0);
      723: get_detail_value = (iq_load_dep_not_ready_width() != 8'd0);
      724: get_detail_value = (iq_nonload_dep_not_ready_width() != 8'd0);
      725: get_detail_value = (aiq0_load_dep_not_ready_width() != 8'd0);
      726: get_detail_value = (aiq0_nonload_dep_not_ready_width() != 8'd0);
      727: get_detail_value = (aiq1_load_dep_not_ready_width() != 8'd0);
      728: get_detail_value = (aiq1_nonload_dep_not_ready_width() != 8'd0);
      729: get_detail_value = (biq_load_dep_not_ready_width() != 8'd0);
      730: get_detail_value = (biq_nonload_dep_not_ready_width() != 8'd0);
      731: get_detail_value = (lsiq_load_dep_not_ready_width() != 8'd0);
      732: get_detail_value = (lsiq_nonload_dep_not_ready_width() != 8'd0);
      733: get_detail_value = (sdiq_load_dep_not_ready_width() != 8'd0);
      734: get_detail_value = (sdiq_nonload_dep_not_ready_width() != 8'd0);
      735: get_detail_value = (viq0_load_dep_not_ready_width() != 8'd0);
      736: get_detail_value = (viq0_nonload_dep_not_ready_width() != 8'd0);
      737: get_detail_value = (viq1_load_dep_not_ready_width() != 8'd0);
      738: get_detail_value = (viq1_nonload_dep_not_ready_width() != 8'd0);
      739: get_detail_value = (iq_ready_not_issued_width() != 8'd0);
      740: get_detail_value = (aiq0_ready_not_issued_width() != 8'd0);
      741: get_detail_value = (aiq1_ready_not_issued_width() != 8'd0);
      742: get_detail_value = (biq_ready_not_issued_width() != 8'd0);
      743: get_detail_value = (lsiq_ready_not_issued_width() != 8'd0);
      744: get_detail_value = (sdiq_ready_not_issued_width() != 8'd0);
      745: get_detail_value = (viq0_ready_not_issued_width() != 8'd0);
      746: get_detail_value = (viq1_ready_not_issued_width() != 8'd0);
      747: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe0_inst_vld && `IDU_RF_DP.rf_pipe0_src0_no_rdy;
      748: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe0_inst_vld && `IDU_RF_DP.rf_pipe0_src1_no_rdy;
      749: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe0_inst_vld && `IDU_RF_DP.rf_pipe0_src2_no_rdy;
      750: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe1_inst_vld && `IDU_RF_DP.rf_pipe1_src0_no_rdy;
      751: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe1_inst_vld && `IDU_RF_DP.rf_pipe1_src1_no_rdy;
      752: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe1_inst_vld && `IDU_RF_DP.rf_pipe1_src2_no_rdy;
      753: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe2_inst_vld && `IDU_RF_DP.rf_pipe2_src0_no_rdy;
      754: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe2_inst_vld && `IDU_RF_DP.rf_pipe2_src1_no_rdy;
      755: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_inst_vld && `IDU_RF_DP.rf_pipe3_src0_no_rdy;
      756: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_inst_vld && `IDU_RF_DP.rf_pipe3_src1_no_rdy;
      757: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_inst_vld && `IDU_RF_DP.rf_pipe3_srcvm_no_rdy;
      758: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe4_inst_vld && `IDU_RF_DP.rf_pipe4_src0_no_rdy;
      759: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe4_inst_vld && `IDU_RF_DP.rf_pipe4_src1_no_rdy;
      760: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe4_inst_vld && `IDU_RF_DP.rf_pipe4_srcvm_no_rdy;
      761: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe5_inst_vld && `IDU_RF_DP.rf_pipe5_src0_no_rdy;
      762: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe5_inst_vld && `IDU_RF_DP.rf_pipe5_srcv0_no_rdy;
      763: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe5_inst_vld && `IDU_RF_DP.rf_pipe5_staddr_no_rdy;
      764: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcv0_no_rdy;
      765: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcv1_no_rdy;
      766: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcv2_no_rdy;
      767: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe6_inst_vld && `IDU_RF_DP.rf_pipe6_srcvm_no_rdy;
      768: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcv0_no_rdy;
      769: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcv1_no_rdy;
      770: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcv2_no_rdy;
      771: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe7_inst_vld && `IDU_RF_DP.rf_pipe7_srcvm_no_rdy;
      772: get_detail_value = (rf_src_no_rdy_width() != 8'd0);
      773: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe0_vdiv_mtvr_lch_fail;
      774: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_preg_lch_fail;
      775: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe3_vreg_lch_fail;
      776: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe4_vreg_lch_fail;
      777: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe5_preg_lch_fail;
      778: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe6_div_mfvr_lch_fail;
      779: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe6_vmul_unsplit_lch_fail;
      780: get_detail_value = `IDU_RF_CTRL.ctrl_rf_pipe7_mult_mfvr_lch_fail;
      781: get_detail_value = `LSU_TOP.lsu_hpcp_replay_data_discard;
      782: get_detail_value = `LSU_TOP.lsu_hpcp_replay_discard_sq;
      783: get_detail_value = `LSU_SQ.sq_ld_dc_has_fwd_req;
      784: get_detail_value = `LSU_SQ.sq_ld_dc_fwd_req;
      785: get_detail_value = `LSU_SQ.sq_ld_dc_fwd_bypass_req;
      786: get_detail_value = `LSU_SQ.sq_ld_dc_fwd_bypass_multi;
      787: get_detail_value = `LSU_SQ.sq_ld_dc_fwd_multi;
      788: get_detail_value = `LSU_SQ.sq_ld_dc_fwd_multi_mask;
      789: get_detail_value = `LSU_SQ.sq_ld_dc_cancel_acc_req;
      790: get_detail_value = `LSU_SQ.sq_ld_dc_cancel_ahead_wb;
      791: get_detail_value = |`LSU_TOP.lsu_idu_ld_ag_wait_old[11:0];
      792: get_detail_value = |`LSU_TOP.lsu_idu_ld_da_wait_old[11:0];
      793: get_detail_value = |`LSU_TOP.lsu_idu_st_ag_wait_old[11:0];
      794: get_detail_value = |`LSU_TOP.lsu_idu_wait_old[11:0];
      795: get_detail_value = !`LSU_TOP.lsu_idu_lq_not_full;
      796: get_detail_value = !`LSU_TOP.lsu_idu_sq_not_full;
      797: get_detail_value = !`LSU_TOP.lsu_idu_rb_not_full;
      798: get_detail_value = `IDU_TOP.ctrl_xx_rf_pipe0_preg_lch_vld_dup0;
      799: get_detail_value = `IDU_TOP.ctrl_xx_rf_pipe1_preg_lch_vld_dup0;
      800: get_detail_value = `IU_TOP.iu_idu_ex2_pipe1_mult_inst_vld_dup0;
      801: get_detail_value = `IU_TOP.iu_idu_div_inst_vld;
      802: get_detail_value = `LSU_TOP.lsu_idu_dc_pipe3_load_fwd_inst_vld_dup1;
      803: get_detail_value = `LSU_TOP.lsu_idu_dc_pipe3_vload_fwd_inst_vld;
      804: get_detail_value = `VFPU_TOP.vfpu_idu_ex1_pipe6_data_vld_dup0;
      805: get_detail_value = `VFPU_TOP.vfpu_idu_ex1_pipe7_data_vld_dup0;
      default: get_detail_value = 1'b0;
    endcase
  end
  endfunction

  task automatic print_detail_row(input string phase, input string name, input int id, input bit use_kernel);
    reg signed [63:0] cnt;
    reg signed [63:0] inst;
    reg signed [63:0] cycles;
    real per_kinst;
    real cycle_pct;
  begin
    if(use_kernel) begin
      cnt    = $signed(kernel_detail_counter_end[id] - kernel_detail_counter_start[id]);
      inst   = $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start);
      cycles = $signed(kernel_cycle_count_end - kernel_cycle_count_start);
    end
    else begin
      cnt    = $signed(main_detail_counter_end[id] - main_detail_counter_start[id]);
      inst   = $signed(main_retire_inst_count_end - main_retire_inst_count_start);
      cycles = $signed(main_cycle_count_end - main_cycle_count_start);
    end
    per_kinst = (inst != 0) ? 1000.0 * real'(cnt) / real'(inst) : 0.0;
    cycle_pct = (cycles != 0) ? 100.0 * real'(cnt) / real'(cycles) : 0.0;
    $display("| %-8s | %-32s |        %-10d |        %-10d |    %-10.3f |    %-8.3f%%      |",
             phase, name, cnt, inst, per_kinst, cycle_pct);
  end
  endtask

  task automatic print_detail_phase(input string phase, input bit use_kernel);
  begin
    print_detail_row(phase, "id_ctrl_stall",             1,  use_kernel);
    print_detail_row(phase, "id_ir_stall",               2,  use_kernel);
    print_detail_row(phase, "id_not_pipedown3",          3,  use_kernel);
    print_detail_row(phase, "id_pipedown1",              4,  use_kernel);
    print_detail_row(phase, "id_pipedown2",              5,  use_kernel);
    print_detail_row(phase, "id_pipedown3",              6,  use_kernel);
    print_detail_row(phase, "id_fence_stall",            7,  use_kernel);
    print_detail_row(phase, "id_split_long_stall",       8,  use_kernel);
    print_detail_row(phase, "rtu_rob_full",              9,  use_kernel);
    print_detail_row(phase, "ir_preg_not_vld",           10, use_kernel);
    print_detail_row(phase, "rtu_idu_flush_stall",       11, use_kernel);
    print_detail_row(phase, "rtu_global_flush",          12, use_kernel);
    print_detail_row(phase, "rtu_ifu_flush",             13, use_kernel);
    print_detail_row(phase, "iu_pipe0_flush",            14, use_kernel);
    print_detail_row(phase, "lsu_spec_fail_flush",       15, use_kernel);
    print_detail_row(phase, "rf_pipe0_lch_fail",         16, use_kernel);
    print_detail_row(phase, "rf_pipe1_lch_fail",         17, use_kernel);
    print_detail_row(phase, "rf_pipe2_lch_fail",         18, use_kernel);
    print_detail_row(phase, "rf_pipe3_lch_fail",         19, use_kernel);
    print_detail_row(phase, "rf_pipe4_lch_fail",         20, use_kernel);
    print_detail_row(phase, "rf_pipe5_lch_fail",         21, use_kernel);
    print_detail_row(phase, "rf_pipe6_lch_fail",         22, use_kernel);
    print_detail_row(phase, "rf_pipe7_lch_fail",         23, use_kernel);
    print_detail_row(phase, "rf_pipe0_src_no_rdy",       24, use_kernel);
    print_detail_row(phase, "rf_pipe1_src_no_rdy",       25, use_kernel);
    print_detail_row(phase, "rf_pipe2_src_no_rdy",       26, use_kernel);
    print_detail_row(phase, "rf_pipe3_src_no_rdy",       27, use_kernel);
    print_detail_row(phase, "rf_pipe4_src_no_rdy",       28, use_kernel);
    print_detail_row(phase, "rf_pipe5_src_no_rdy",       29, use_kernel);
    print_detail_row(phase, "rf_pipe6_src_no_rdy",       30, use_kernel);
    print_detail_row(phase, "rf_pipe7_src_no_rdy",       31, use_kernel);
    print_detail_row(phase, "rf_pipe3_reg_lch_fail",     32, use_kernel);
    print_detail_row(phase, "rf_pipe4_reg_lch_fail",     33, use_kernel);
    print_detail_row(phase, "rf_pipe5_reg_lch_fail",     34, use_kernel);
    print_detail_row(phase, "rf_pipe3_preg_conflict",    35, use_kernel);
    print_detail_row(phase, "rf_pipe5_preg_conflict",    36, use_kernel);
    print_detail_row(phase, "rf_pipe3_vreg_conflict",    37, use_kernel);
    print_detail_row(phase, "rf_pipe4_vreg_conflict",    38, use_kernel);
    print_detail_row(phase, "lsu_ld_cross4k_hpcp",       39, use_kernel);
    print_detail_row(phase, "lsu_st_cross4k_hpcp",       40, use_kernel);
    print_detail_row(phase, "lsu_ld_other_hpcp",         41, use_kernel);
    print_detail_row(phase, "lsu_st_other_hpcp",         42, use_kernel);
    print_detail_row(phase, "ld_ag_cross_req",           43, use_kernel);
    print_detail_row(phase, "ld_ag_dcache_stall_req",    44, use_kernel);
    print_detail_row(phase, "ld_ag_mmu_stall_req",       45, use_kernel);
    print_detail_row(phase, "ld_ag_atomic_no_cmit",      46, use_kernel);
    print_detail_row(phase, "st_ag_cross_req",           47, use_kernel);
    print_detail_row(phase, "st_ag_dcache_stall_req",    48, use_kernel);
    print_detail_row(phase, "st_ag_mmu_stall_req",       49, use_kernel);
    print_detail_row(phase, "st_ag_atomic_no_cmit",      50, use_kernel);
    print_detail_row(phase, "ifu_frontend_stall_raw",    51, use_kernel);
    print_detail_row(phase, "ifu_ibuf_full",             52, use_kernel);
    print_detail_row(phase, "ifu_pcfifo_full_stall",     53, use_kernel);
    print_detail_row(phase, "id_width0_cycle",           54, use_kernel);
    print_detail_row(phase, "id_width1_cycle",           55, use_kernel);
    print_detail_row(phase, "id_width2_cycle",           56, use_kernel);
    print_detail_row(phase, "id_width3_cycle",           57, use_kernel);
    print_detail_row(phase, "ir_width0_cycle",           58, use_kernel);
    print_detail_row(phase, "ir_width1_cycle",           59, use_kernel);
    print_detail_row(phase, "ir_width2_cycle",           60, use_kernel);
    print_detail_row(phase, "ir_width3_cycle",           61, use_kernel);
    print_detail_row(phase, "ir_width4_cycle",           62, use_kernel);
    print_detail_row(phase, "is_width0_cycle",           63, use_kernel);
    print_detail_row(phase, "is_width1_cycle",           64, use_kernel);
    print_detail_row(phase, "is_width2_cycle",           65, use_kernel);
    print_detail_row(phase, "is_width3_cycle",           66, use_kernel);
    print_detail_row(phase, "is_width4_cycle",           67, use_kernel);
    print_detail_row(phase, "rf_launch_width0_cycle",    68, use_kernel);
    print_detail_row(phase, "rf_launch_width1_cycle",    69, use_kernel);
    print_detail_row(phase, "rf_launch_width2_cycle",    70, use_kernel);
    print_detail_row(phase, "rf_launch_width3_cycle",    71, use_kernel);
    print_detail_row(phase, "rf_launch_width4_cycle",    72, use_kernel);
    print_detail_row(phase, "rf_launch_width5_cycle",    73, use_kernel);
    print_detail_row(phase, "rf_launch_width6_cycle",    74, use_kernel);
    print_detail_row(phase, "rf_launch_width7_cycle",    75, use_kernel);
    print_detail_row(phase, "rf_launch_width8_cycle",    76, use_kernel);
    print_detail_row(phase, "retire_width0_cycle",       77, use_kernel);
    print_detail_row(phase, "retire_width1_cycle",       78, use_kernel);
    print_detail_row(phase, "retire_width2_cycle",       79, use_kernel);
    print_detail_row(phase, "retire_width3_cycle",       80, use_kernel);
    print_detail_row(phase, "rob_empty",                 81, use_kernel);
    print_detail_row(phase, "rob_full_dbg",              82, use_kernel);
    print_detail_row(phase, "rob_occ_ge32",              83, use_kernel);
    print_detail_row(phase, "rob_occ_ge64",              84, use_kernel);
    print_detail_row(phase, "rob_occ_ge96",              85, use_kernel);
    print_detail_row(phase, "is_iq_full",                86, use_kernel);
    print_detail_row(phase, "is_vmb_full",               87, use_kernel);
    print_detail_row(phase, "aiq0_empty",                88, use_kernel);
    print_detail_row(phase, "aiq0_full",                 89, use_kernel);
    print_detail_row(phase, "aiq1_empty",                90, use_kernel);
    print_detail_row(phase, "aiq1_full",                 91, use_kernel);
    print_detail_row(phase, "biq_empty",                 92, use_kernel);
    print_detail_row(phase, "biq_full",                  93, use_kernel);
    print_detail_row(phase, "lsiq_empty",                94, use_kernel);
    print_detail_row(phase, "lsiq_full",                 95, use_kernel);
    print_detail_row(phase, "sdiq_empty",                96, use_kernel);
    print_detail_row(phase, "sdiq_full",                 97, use_kernel);
    print_detail_row(phase, "viq0_empty",                98, use_kernel);
    print_detail_row(phase, "viq0_full",                 99, use_kernel);
    print_detail_row(phase, "viq1_empty",                100, use_kernel);
    print_detail_row(phase, "viq1_full",                 101, use_kernel);
    print_detail_row(phase, "retire_condbr_slot0",       102, use_kernel);
    print_detail_row(phase, "retire_condbr_slot1",       103, use_kernel);
    print_detail_row(phase, "retire_condbr_slot2",       104, use_kernel);
    print_detail_row(phase, "retire_jmp_slot0",          105, use_kernel);
    print_detail_row(phase, "retire_jmp_slot1",          106, use_kernel);
    print_detail_row(phase, "retire_jmp_slot2",          107, use_kernel);
    print_detail_row(phase, "retire_bht_mispred",        108, use_kernel);
    print_detail_row(phase, "retire_jmp_mispred",        109, use_kernel);
    print_detail_row(phase, "ifu_retire0_condbr",        110, use_kernel);
    print_detail_row(phase, "ifu_retire0_condbr_taken",  111, use_kernel);
    print_detail_row(phase, "ifu_retire0_mispred",       112, use_kernel);
    print_detail_row(phase, "ifu_retire0_jmp_mispred",   113, use_kernel);
    print_detail_row(phase, "nospec_miss_any",           114, use_kernel);
    print_detail_row(phase, "nospec_mispred_any",        115, use_kernel);
    print_detail_row(phase, "vl_miss_inst0",             116, use_kernel);
    print_detail_row(phase, "vl_mispred_inst0",          117, use_kernel);
    print_detail_row(phase, "iu_idu_mispred_stall",      118, use_kernel);
    print_detail_row(phase, "iu_ifu_mispred_stall",      119, use_kernel);
    print_detail_row(phase, "iu_bht_mispred",            120, use_kernel);
    print_detail_row(phase, "iu_jmp_mispred",            121, use_kernel);
    print_detail_row(phase, "icache_refill_pre",         122, use_kernel);
    print_detail_row(phase, "icache_refill_reissue",     123, use_kernel);
    print_detail_row(phase, "icache_refill_busy",        124, use_kernel);
    print_detail_row(phase, "icache_miss_under_refill",  125, use_kernel);
    print_detail_row(phase, "icache_way_mispred_reissue", 126, use_kernel);
    print_detail_row(phase, "ifu_bry_missigned_stall",   127, use_kernel);
    print_detail_row(phase, "ifu_multi_branch_stall",    128, use_kernel);
    print_detail_row(phase, "dcache_read_access",        129, use_kernel);
    print_detail_row(phase, "dcache_read_miss",          130, use_kernel);
    print_detail_row(phase, "dcache_write_access",       131, use_kernel);
    print_detail_row(phase, "dcache_write_miss",         132, use_kernel);
    print_detail_row(phase, "ld_utlb_miss",              133, use_kernel);
    print_detail_row(phase, "st_utlb_miss",              134, use_kernel);
    print_detail_row(phase, "ld_da_dcache_miss_raw",     135, use_kernel);
    print_detail_row(phase, "st_da_dcache_miss_raw",     136, use_kernel);
    print_detail_row(phase, "lq_full_raw",               137, use_kernel);
    print_detail_row(phase, "sq_full_raw",               138, use_kernel);
    print_detail_row(phase, "rb_full_raw",               139, use_kernel);
    print_detail_row(phase, "lfb_addr_full",             140, use_kernel);
    print_detail_row(phase, "wmb_bytes_full",            141, use_kernel);
    print_detail_row(phase, "pipe0_inst_vld",            142, use_kernel);
    print_detail_row(phase, "pipe1_inst_vld",            143, use_kernel);
    print_detail_row(phase, "pipe2_inst_vld",            144, use_kernel);
    print_detail_row(phase, "pipe3_inst_vld",            145, use_kernel);
    print_detail_row(phase, "pipe4_inst_vld",            146, use_kernel);
    print_detail_row(phase, "mult_pipe1_stall",          147, use_kernel);
    print_detail_row(phase, "div_wb_stall",              148, use_kernel);
    print_detail_row(phase, "pipe5_inst_vld",            149, use_kernel);
    print_detail_row(phase, "pipe6_inst_vld",            150, use_kernel);
    print_detail_row(phase, "pipe7_inst_vld",            151, use_kernel);
    print_detail_row(phase, "ifu_ibuf_create",           152, use_kernel);
    print_detail_row(phase, "ifu_ibuf_retire",           153, use_kernel);
    print_detail_row(phase, "ifu_lbuf_create",           154, use_kernel);
    print_detail_row(phase, "ifu_lbuf_retire",           155, use_kernel);
    print_detail_row(phase, "ifu_bypass_inst_vld",       156, use_kernel);
    print_detail_row(phase, "ifu_merge_inst_vld",        157, use_kernel);
    print_detail_row(phase, "ifu_pcfifo_create",         158, use_kernel);
    print_detail_row(phase, "ifu_ind_btb_miss",          159, use_kernel);
    print_detail_row(phase, "ifu_ind_btb_rd_stall",      160, use_kernel);
    print_detail_row(phase, "ifu_btb_miss",              161, use_kernel);
    print_detail_row(phase, "ifu_l0_btb_miss",           162, use_kernel);
    print_detail_row(phase, "ras_push",                  163, use_kernel);
    print_detail_row(phase, "ras_pop",                   164, use_kernel);
    print_detail_row(phase, "ras_empty",                 165, use_kernel);
    print_detail_row(phase, "ras_full",                  166, use_kernel);
    print_detail_row(phase, "bht_wrbuf_create",          167, use_kernel);
    print_detail_row(phase, "bht_wrbuf_retire",          168, use_kernel);
    print_detail_row(phase, "bht_wrbuf_create_slot_full", 169, use_kernel);
    print_detail_row(phase, "bht_wrbuf_not_empty",       170, use_kernel);
    print_detail_row(phase, "icache_refill_start",       171, use_kernel);
    print_detail_row(phase, "icache_refill_cmplt",       172, use_kernel);
    print_detail_row(phase, "icache_refill_data_vld",    173, use_kernel);
    print_detail_row(phase, "icache_refill_trans_err",   174, use_kernel);
    print_detail_row(phase, "icache_refill_on",          175, use_kernel);
    print_detail_row(phase, "icache_refill_chgflw",      176, use_kernel);
    print_detail_row(phase, "retire_load_any",           177, use_kernel);
    print_detail_row(phase, "retire_store_any",          178, use_kernel);
    print_detail_row(phase, "retire_split_any",          179, use_kernel);
    print_detail_row(phase, "retire_preg_write_any",     180, use_kernel);
    print_detail_row(phase, "retire_vreg_write_any",     181, use_kernel);
    print_detail_row(phase, "retire_ereg_write_any",     182, use_kernel);
    print_detail_row(phase, "retire_nospec_hit_any",     183, use_kernel);
    print_detail_row(phase, "retire_nospec_miss_any",    184, use_kernel);
    print_detail_row(phase, "retire_nospec_misp_any",    185, use_kernel);
    print_detail_row(phase, "retire_vl_pred_any",        186, use_kernel);
    print_detail_row(phase, "rob_head_valid",            187, use_kernel);
    print_detail_row(phase, "rob_head_load",             188, use_kernel);
    print_detail_row(phase, "rob_head_store",            189, use_kernel);
    print_detail_row(phase, "rob_head_bju",              190, use_kernel);
    print_detail_row(phase, "rob_head_condbr",           191, use_kernel);
    print_detail_row(phase, "rob_head_jmp",              192, use_kernel);
    print_detail_row(phase, "rob_head_expt",             193, use_kernel);
    print_detail_row(phase, "rob_head_int",              194, use_kernel);
    print_detail_row(phase, "rob_head_spec_fail",        195, use_kernel);
    print_detail_row(phase, "lq_create0",                196, use_kernel);
    print_detail_row(phase, "lq_create1",                197, use_kernel);
    print_detail_row(phase, "sq_wmb_pop_to_ce_req",      198, use_kernel);
    print_detail_row(phase, "wmb_ce_create",             199, use_kernel);
    print_detail_row(phase, "wmb_ce_pop",                200, use_kernel);
    print_detail_row(phase, "wmb_write_biu_req",         201, use_kernel);
    print_detail_row(phase, "wmb_write_stall",           202, use_kernel);
    print_detail_row(phase, "wmb_merge_data_stall",      203, use_kernel);
    print_detail_row(phase, "wmb_ld_dc_discard",         204, use_kernel);
    print_detail_row(phase, "rb_biu_ar_req",             205, use_kernel);
    print_detail_row(phase, "rb_lfb_create_req",         206, use_kernel);
    print_detail_row(phase, "rb_ld_da_full",             207, use_kernel);
    print_detail_row(phase, "rb_st_da_full",             208, use_kernel);
    print_detail_row(phase, "lfb_data_full",             209, use_kernel);
    print_detail_row(phase, "lfb_data_wait_surplus",     210, use_kernel);
    print_detail_row(phase, "lfb_addr_empty",            211, use_kernel);
    print_detail_row(phase, "lfb_data_empty",            212, use_kernel);
    print_detail_row(phase, "biu_arvalid",               213, use_kernel);
    print_detail_row(phase, "biu_ar_handshake",          214, use_kernel);
    print_detail_row(phase, "biu_ar_backpressure",       215, use_kernel);
    print_detail_row(phase, "biu_rvalid",                216, use_kernel);
    print_detail_row(phase, "biu_r_backpressure",        217, use_kernel);
    print_detail_row(phase, "biu_awvalid",               218, use_kernel);
    print_detail_row(phase, "biu_wvalid",                219, use_kernel);
    print_detail_row(phase, "biu_bvalid",                220, use_kernel);
    print_detail_row(phase, "biu_r_handshake",           221, use_kernel);
    print_detail_row(phase, "biu_rready",                222, use_kernel);
    print_detail_row(phase, "biu_aw_handshake",          223, use_kernel);
    print_detail_row(phase, "biu_aw_backpressure",       224, use_kernel);
    print_detail_row(phase, "biu_w_handshake",           225, use_kernel);
    print_detail_row(phase, "biu_w_backpressure",        226, use_kernel);
    print_detail_row(phase, "biu_bready",                227, use_kernel);
    print_detail_row(phase, "biu_b_handshake",           228, use_kernel);
    print_detail_row(phase, "biu_b_backpressure",        229, use_kernel);
    print_detail_row(phase, "biu_st_awvalid",            230, use_kernel);
    print_detail_row(phase, "biu_st_aw_stall",           231, use_kernel);
    print_detail_row(phase, "biu_vict_awvalid",          232, use_kernel);
    print_detail_row(phase, "biu_vict_aw_stall",         233, use_kernel);
    print_detail_row(phase, "biu_st_wvalid",             234, use_kernel);
    print_detail_row(phase, "biu_st_w_stall",            235, use_kernel);
    print_detail_row(phase, "biu_vict_wvalid",           236, use_kernel);
    print_detail_row(phase, "biu_vict_w_stall",          237, use_kernel);
    print_detail_row(phase, "biu_write_busy",            238, use_kernel);
    print_detail_row(phase, "retire_s0_valid",           239, use_kernel);
    print_detail_row(phase, "retire_s1_valid",           240, use_kernel);
    print_detail_row(phase, "retire_s2_valid",           241, use_kernel);
    print_detail_row(phase, "retire_s0_load",            242, use_kernel);
    print_detail_row(phase, "retire_s1_load",            243, use_kernel);
    print_detail_row(phase, "retire_s2_load",            244, use_kernel);
    print_detail_row(phase, "retire_s0_store",           245, use_kernel);
    print_detail_row(phase, "retire_s1_store",           246, use_kernel);
    print_detail_row(phase, "retire_s2_store",           247, use_kernel);
    print_detail_row(phase, "retire_s0_bju",             248, use_kernel);
    print_detail_row(phase, "retire_s1_bju",             249, use_kernel);
    print_detail_row(phase, "retire_s2_bju",             250, use_kernel);
    print_detail_row(phase, "retire_s0_condbr",          251, use_kernel);
    print_detail_row(phase, "retire_s1_condbr",          252, use_kernel);
    print_detail_row(phase, "retire_s2_condbr",          253, use_kernel);
    print_detail_row(phase, "retire_s0_jmp",             254, use_kernel);
    print_detail_row(phase, "retire_s1_jmp",             255, use_kernel);
    print_detail_row(phase, "retire_s2_jmp",             256, use_kernel);
    print_detail_row(phase, "retire_s0_split",           257, use_kernel);
    print_detail_row(phase, "retire_s1_split",           258, use_kernel);
    print_detail_row(phase, "retire_s2_split",           259, use_kernel);
    print_detail_row(phase, "retire_s0_preg_write",      260, use_kernel);
    print_detail_row(phase, "retire_s1_preg_write",      261, use_kernel);
    print_detail_row(phase, "retire_s2_preg_write",      262, use_kernel);
    print_detail_row(phase, "retire_s0_vreg_write",      263, use_kernel);
    print_detail_row(phase, "retire_s1_vreg_write",      264, use_kernel);
    print_detail_row(phase, "retire_s2_vreg_write",      265, use_kernel);
    print_detail_row(phase, "retire_s0_ereg_write",      266, use_kernel);
    print_detail_row(phase, "retire_s1_ereg_write",      267, use_kernel);
    print_detail_row(phase, "retire_s2_ereg_write",      268, use_kernel);
    print_detail_row(phase, "retire_s0_nospec_hit",      269, use_kernel);
    print_detail_row(phase, "retire_s1_nospec_hit",      270, use_kernel);
    print_detail_row(phase, "retire_s2_nospec_hit",      271, use_kernel);
    print_detail_row(phase, "retire_s0_nospec_miss",     272, use_kernel);
    print_detail_row(phase, "retire_s1_nospec_miss",     273, use_kernel);
    print_detail_row(phase, "retire_s2_nospec_miss",     274, use_kernel);
    print_detail_row(phase, "retire_s0_nospec_misp",     275, use_kernel);
    print_detail_row(phase, "retire_s1_nospec_misp",     276, use_kernel);
    print_detail_row(phase, "retire_s2_nospec_misp",     277, use_kernel);
    print_detail_row(phase, "retire_s0_vl_pred",         278, use_kernel);
    print_detail_row(phase, "retire_s1_vl_pred",         279, use_kernel);
    print_detail_row(phase, "retire_s2_vl_pred",         280, use_kernel);
    print_detail_row(phase, "cpi_stack_retiring",        281, use_kernel);
    print_detail_row(phase, "cpi_stack_bad_spec",        282, use_kernel);
    print_detail_row(phase, "cpi_stack_frontend",        283, use_kernel);
    print_detail_row(phase, "cpi_stack_memory",          284, use_kernel);
    print_detail_row(phase, "cpi_stack_backend_core",    285, use_kernel);
    print_detail_row(phase, "cpi_stack_idle_unknown",    286, use_kernel);
    print_detail_row(phase, "preg_alloc0_req",           287, use_kernel);
    print_detail_row(phase, "preg_alloc1_req",           288, use_kernel);
    print_detail_row(phase, "preg_alloc2_req",           289, use_kernel);
    print_detail_row(phase, "preg_alloc3_req",           290, use_kernel);
    print_detail_row(phase, "preg_alloc0_vld",           291, use_kernel);
    print_detail_row(phase, "preg_alloc1_vld",           292, use_kernel);
    print_detail_row(phase, "preg_alloc2_vld",           293, use_kernel);
    print_detail_row(phase, "preg_alloc3_vld",           294, use_kernel);
    print_detail_row(phase, "preg_alloc0_block",         295, use_kernel);
    print_detail_row(phase, "preg_alloc1_block",         296, use_kernel);
    print_detail_row(phase, "preg_alloc2_block",         297, use_kernel);
    print_detail_row(phase, "preg_alloc3_block",         298, use_kernel);
    print_detail_row(phase, "ereg_alloc0_req",           299, use_kernel);
    print_detail_row(phase, "ereg_alloc1_req",           300, use_kernel);
    print_detail_row(phase, "ereg_alloc2_req",           301, use_kernel);
    print_detail_row(phase, "ereg_alloc3_req",           302, use_kernel);
    print_detail_row(phase, "ereg_alloc0_vld",           303, use_kernel);
    print_detail_row(phase, "ereg_alloc1_vld",           304, use_kernel);
    print_detail_row(phase, "ereg_alloc2_vld",           305, use_kernel);
    print_detail_row(phase, "ereg_alloc3_vld",           306, use_kernel);
    print_detail_row(phase, "ereg_alloc0_block",         307, use_kernel);
    print_detail_row(phase, "ereg_alloc1_block",         308, use_kernel);
    print_detail_row(phase, "ereg_alloc2_block",         309, use_kernel);
    print_detail_row(phase, "ereg_alloc3_block",         310, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc0_req",      311, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc1_req",      312, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc2_req",      313, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc3_req",      314, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc0_vld",      315, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc1_vld",      316, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc2_vld",      317, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc3_vld",      318, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc0_block",    319, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc1_block",    320, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc2_block",    321, use_kernel);
    print_detail_row(phase, "freg_vreg_alloc3_block",    322, use_kernel);
    print_detail_row(phase, "preg_pst_empty",            323, use_kernel);
    print_detail_row(phase, "ereg_pst_empty",            324, use_kernel);
    print_detail_row(phase, "freg_vreg_pst_empty",       325, use_kernel);
    print_detail_row(phase, "vfpu_pipe6_issue",          326, use_kernel);
    print_detail_row(phase, "vfpu_pipe7_issue",          327, use_kernel);
    print_detail_row(phase, "vfpu_pipe6_gateclk_issue",  328, use_kernel);
    print_detail_row(phase, "vfpu_pipe7_gateclk_issue",  329, use_kernel);
    print_detail_row(phase, "vfpu_vdiv_issue",           330, use_kernel);
    print_detail_row(phase, "vfpu_vdiv_gateclk_issue",   331, use_kernel);
    print_detail_row(phase, "vfdsu_pipe_busy",           332, use_kernel);
    print_detail_row(phase, "vfdsu_ex2_wait",            333, use_kernel);
    print_detail_row(phase, "vfdsu_idle",                334, use_kernel);
    print_detail_row(phase, "vfpu_ex1_pipe6_data_vld",   335, use_kernel);
    print_detail_row(phase, "vfpu_ex1_pipe7_data_vld",   336, use_kernel);
    print_detail_row(phase, "vfpu_ex2_pipe6_data_vld",   337, use_kernel);
    print_detail_row(phase, "vfpu_ex2_pipe7_data_vld",   338, use_kernel);
    print_detail_row(phase, "vfpu_ex3_pipe6_data_vld",   339, use_kernel);
    print_detail_row(phase, "vfpu_ex3_pipe7_data_vld",   340, use_kernel);
    print_detail_row(phase, "vfpu_ex3_pipe6_fwd_vreg",   341, use_kernel);
    print_detail_row(phase, "vfpu_ex3_pipe7_fwd_vreg",   342, use_kernel);
    print_detail_row(phase, "vfpu_ex4_pipe6_fwd_vreg",   343, use_kernel);
    print_detail_row(phase, "vfpu_ex4_pipe7_fwd_vreg",   344, use_kernel);
    print_detail_row(phase, "vfpu_ex5_pipe6_fwd_vreg",   345, use_kernel);
    print_detail_row(phase, "vfpu_ex5_pipe7_fwd_vreg",   346, use_kernel);
    print_detail_row(phase, "vfpu_pipe6_ereg_wb",        347, use_kernel);
    print_detail_row(phase, "vfpu_pipe7_ereg_wb",        348, use_kernel);
    print_detail_row(phase, "vfpu_pipe6_vreg_fr_wb",     349, use_kernel);
    print_detail_row(phase, "vfpu_pipe7_vreg_fr_wb",     350, use_kernel);
    print_detail_row(phase, "vfpu_pipe6_vreg_vr_wb",     351, use_kernel);
    print_detail_row(phase, "vfpu_pipe7_vreg_vr_wb",     352, use_kernel);
    print_detail_row(phase, "vfpu_pipe6_vmla_no_fwd",    353, use_kernel);
    print_detail_row(phase, "vfpu_pipe7_vmla_no_fwd",    354, use_kernel);
    print_detail_row(phase, "ld_pfu_act",                355, use_kernel);
    print_detail_row(phase, "st_pfu_act",                356, use_kernel);
    print_detail_row(phase, "ld_pfu_pf_inst",            357, use_kernel);
    print_detail_row(phase, "st_pfu_pf_inst",            358, use_kernel);
    print_detail_row(phase, "pfu_biu_ar_req",            359, use_kernel);
    print_detail_row(phase, "pfu_lfb_create_req",        360, use_kernel);
    print_detail_row(phase, "pfu_lfb_create_vld",        361, use_kernel);
    print_detail_row(phase, "pfu_biu_req_unmask",        362, use_kernel);
    print_detail_row(phase, "pfu_biu_req_hit_idx",       363, use_kernel);
    print_detail_row(phase, "pfu_pfb_empty",             364, use_kernel);
    print_detail_row(phase, "pfu_sdb_empty",             365, use_kernel);
    print_detail_row(phase, "pfu_pmb_empty",             366, use_kernel);
    print_detail_row(phase, "pfu_part_empty",            367, use_kernel);
    print_detail_row(phase, "pfu_pop_all",               368, use_kernel);
    print_detail_row(phase, "pfu_biu_pe_grnt",           369, use_kernel);
    print_detail_row(phase, "vb_empty",                  370, use_kernel);
    print_detail_row(phase, "vb_addr_full",              371, use_kernel);
    print_detail_row(phase, "vb_data_full",              372, use_kernel);
    print_detail_row(phase, "vb_lfb_create",             373, use_kernel);
    print_detail_row(phase, "vb_wmb_create",             374, use_kernel);
    print_detail_row(phase, "vb_icc_create",             375, use_kernel);
    print_detail_row(phase, "vb_biu_aw_req",             376, use_kernel);
    print_detail_row(phase, "vb_biu_w_req",              377, use_kernel);
    print_detail_row(phase, "vb_dcache_ld_req",          378, use_kernel);
    print_detail_row(phase, "vb_dcache_st_req",          379, use_kernel);
    print_detail_row(phase, "ld_lfb_discard_grnt",       380, use_kernel);
    print_detail_row(phase, "ld_lm_discard_grnt",        381, use_kernel);
    print_detail_row(phase, "ld_rb_discard_grnt",        382, use_kernel);
    print_detail_row(phase, "ld_sq_data_discard",        383, use_kernel);
    print_detail_row(phase, "ld_sq_global_discard",      384, use_kernel);
    print_detail_row(phase, "ld_wmb_discard",            385, use_kernel);
    print_detail_row(phase, "ld_spec_fail",              386, use_kernel);
    print_detail_row(phase, "st_spec_fail",              387, use_kernel);
    print_detail_row(phase, "ld_data_discard_hpcp",      388, use_kernel);
    print_detail_row(phase, "ld_discard_sq_hpcp",        389, use_kernel);
    print_detail_row(phase, "ld_pfu_hit_idx",            390, use_kernel);
    print_detail_row(phase, "st_pfu_hit_idx",            391, use_kernel);
    print_detail_row(phase, "is_dispatch_stall",         392, use_kernel);
    print_detail_row(phase, "is_rob_full_stall",         393, use_kernel);
    print_detail_row(phase, "is_iq_full_stall",          394, use_kernel);
    print_detail_row(phase, "is_vmb_full_stall",         395, use_kernel);
    print_detail_row(phase, "is_aiq0_full_updt",         396, use_kernel);
    print_detail_row(phase, "is_aiq1_full_updt",         397, use_kernel);
    print_detail_row(phase, "is_biq_full_updt",          398, use_kernel);
    print_detail_row(phase, "is_lsiq_full_updt",         399, use_kernel);
    print_detail_row(phase, "is_sdiq_full_updt",         400, use_kernel);
    print_detail_row(phase, "is_viq0_full_updt",         401, use_kernel);
    print_detail_row(phase, "is_viq1_full_updt",         402, use_kernel);
    print_detail_row(phase, "is_aiq0_create0",           403, use_kernel);
    print_detail_row(phase, "is_aiq0_create1",           404, use_kernel);
    print_detail_row(phase, "is_aiq1_create0",           405, use_kernel);
    print_detail_row(phase, "is_aiq1_create1",           406, use_kernel);
    print_detail_row(phase, "is_biq_create0",            407, use_kernel);
    print_detail_row(phase, "is_biq_create1",            408, use_kernel);
    print_detail_row(phase, "is_lsiq_create0",           409, use_kernel);
    print_detail_row(phase, "is_lsiq_create1",           410, use_kernel);
    print_detail_row(phase, "is_sdiq_create0",           411, use_kernel);
    print_detail_row(phase, "is_sdiq_create1",           412, use_kernel);
    print_detail_row(phase, "is_viq0_create0",           413, use_kernel);
    print_detail_row(phase, "is_viq0_create1",           414, use_kernel);
    print_detail_row(phase, "is_viq1_create0",           415, use_kernel);
    print_detail_row(phase, "is_viq1_create1",           416, use_kernel);
    print_detail_row(phase, "aiq0_rf_pop",               417, use_kernel);
    print_detail_row(phase, "aiq1_rf_pop",               418, use_kernel);
    print_detail_row(phase, "biq_rf_pop",                419, use_kernel);
    print_detail_row(phase, "lsiq_pop",                  420, use_kernel);
    print_detail_row(phase, "sdiq_pop",                  421, use_kernel);
    print_detail_row(phase, "viq0_rf_pop",               422, use_kernel);
    print_detail_row(phase, "viq1_rf_pop",               423, use_kernel);
    print_detail_row(phase, "aiq0_rf_pop_dlb",           424, use_kernel);
    print_detail_row(phase, "aiq1_rf_pop_dlb",           425, use_kernel);
    print_detail_row(phase, "viq0_rf_pop_dlb",           426, use_kernel);
    print_detail_row(phase, "viq1_rf_pop_dlb",           427, use_kernel);
    print_detail_row(phase, "dca_lfb_ld_req",            428, use_kernel);
    print_detail_row(phase, "dca_vb_ld_req",             429, use_kernel);
    print_detail_row(phase, "dca_snq_ld_req",            430, use_kernel);
    print_detail_row(phase, "dca_icc_ld_req",            431, use_kernel);
    print_detail_row(phase, "dca_wmb_ld_req",            432, use_kernel);
    print_detail_row(phase, "dca_mcic_ld_req",           433, use_kernel);
    print_detail_row(phase, "dca_ag_ld_req",             434, use_kernel);
    print_detail_row(phase, "dca_lfb_ld_grnt",           435, use_kernel);
    print_detail_row(phase, "dca_vb_ld_grnt",            436, use_kernel);
    print_detail_row(phase, "dca_snq_ld_grnt",           437, use_kernel);
    print_detail_row(phase, "dca_icc_ld_grnt",           438, use_kernel);
    print_detail_row(phase, "dca_wmb_ld_grnt",           439, use_kernel);
    print_detail_row(phase, "dca_mcic_ld_grnt",          440, use_kernel);
    print_detail_row(phase, "dca_ag_ld_grnt",            441, use_kernel);
    print_detail_row(phase, "dca_lfb_st_req",            442, use_kernel);
    print_detail_row(phase, "dca_vb_st_req",             443, use_kernel);
    print_detail_row(phase, "dca_snq_st_req",            444, use_kernel);
    print_detail_row(phase, "dca_icc_st_req",            445, use_kernel);
    print_detail_row(phase, "dca_wmb_st_req",            446, use_kernel);
    print_detail_row(phase, "dca_ag_st_req",             447, use_kernel);
    print_detail_row(phase, "dca_lfb_st_grnt",           448, use_kernel);
    print_detail_row(phase, "dca_vb_st_grnt",            449, use_kernel);
    print_detail_row(phase, "dca_snq_st_grnt",           450, use_kernel);
    print_detail_row(phase, "dca_icc_st_grnt",           451, use_kernel);
    print_detail_row(phase, "dca_wmb_st_grnt",           452, use_kernel);
    print_detail_row(phase, "dca_ag_st_grnt",            453, use_kernel);
    print_detail_row(phase, "dca_serial_req",            454, use_kernel);
    print_detail_row(phase, "dca_serial_vld",            455, use_kernel);
    print_detail_row(phase, "dca_ld_borrow_vld",         456, use_kernel);
    print_detail_row(phase, "dca_st_borrow_vld",         457, use_kernel);
    print_detail_row(phase, "dca_ld_tag_req",            458, use_kernel);
    print_detail_row(phase, "dca_ld_data_req",           459, use_kernel);
    print_detail_row(phase, "dca_st_tag_req",            460, use_kernel);
    print_detail_row(phase, "dca_st_dirty_req",          461, use_kernel);
    print_detail_row(phase, "sq_create_success",         462, use_kernel);
    print_detail_row(phase, "sq_create_vld",             463, use_kernel);
    print_detail_row(phase, "sq_pop_to_ce_req",          464, use_kernel);
    print_detail_row(phase, "sq_wmb_merge_stall_req",    465, use_kernel);
    print_detail_row(phase, "sq_data_discard_req",       466, use_kernel);
    print_detail_row(phase, "sq_other_discard_req",      467, use_kernel);
    print_detail_row(phase, "sq_newest_fwd_req",         468, use_kernel);
    print_detail_row(phase, "sq_addr1_dep_discard",      469, use_kernel);
    print_detail_row(phase, "lfb_empty",                 470, use_kernel);
    print_detail_row(phase, "lfb_addr_pop_vld",          471, use_kernel);
    print_detail_row(phase, "lfb_addr_discard_vld",      472, use_kernel);
    print_detail_row(phase, "lfb_addr_dcache_hit",       473, use_kernel);
    print_detail_row(phase, "lfb_ld_da_hit_idx",         474, use_kernel);
    print_detail_row(phase, "lfb_st_da_hit_idx",         475, use_kernel);
    print_detail_row(phase, "lfb_pfu_biu_req_hit_idx",   476, use_kernel);
    print_detail_row(phase, "lfb_rb_biu_req_hit_idx",    477, use_kernel);
    print_detail_row(phase, "lfb_wmb_read_req_hit_idx",  478, use_kernel);
    print_detail_row(phase, "lfb_wmb_write_req_hit_idx", 479, use_kernel);
    print_detail_row(phase, "lfb_vb_create_req",         480, use_kernel);
    print_detail_row(phase, "lfb_vb_create_vld",         481, use_kernel);
    print_detail_row(phase, "lfb_vb_pe_req",             482, use_kernel);
    print_detail_row(phase, "lfb_vb_pe_grnt",            483, use_kernel);
    print_detail_row(phase, "lfb_data_create_vld",       484, use_kernel);
    print_detail_row(phase, "lfb_data_not_full",         485, use_kernel);
    print_detail_row(phase, "lfb_lf_sm_vld",             486, use_kernel);
    print_detail_row(phase, "lfb_lf_sm_req",             487, use_kernel);
    print_detail_row(phase, "lfb_lf_sm_create_vld",      488, use_kernel);
    print_detail_row(phase, "lfb_lf_sm_refill_wakeup",   489, use_kernel);
    print_detail_row(phase, "lfb_lf_sm_data_grnt",       490, use_kernel);
    print_detail_row(phase, "lfb_lf_sm_data_pop_req",    491, use_kernel);
    print_detail_row(phase, "lfb_biu_r_id_hit",          492, use_kernel);
    print_detail_row(phase, "lfb_ca_rready_grnt",        493, use_kernel);
    print_detail_row(phase, "lfb_nc_rready_grnt",        494, use_kernel);
    print_detail_row(phase, "lfb_pfu_rready_grnt",       495, use_kernel);
    print_detail_row(phase, "lfb_pop_depd_ff",           496, use_kernel);
    print_detail_row(phase, "lfb_depd_wakeup",           497, use_kernel);
    print_detail_row(phase, "lfb_mcic_wakeup",           498, use_kernel);
    print_detail_row(phase, "lfb_snq_bypass_hit",        499, use_kernel);
    print_detail_row(phase, "lfb_no_rcl_cnt_updt",       500, use_kernel);
    print_detail_row(phase, "lfb_addr_not_resp",         501, use_kernel);
    print_detail_row(phase, "wmb_empty",                 502, use_kernel);
    print_detail_row(phase, "wmb_create_vld",            503, use_kernel);
    print_detail_row(phase, "wmb_biu_ar_req",            504, use_kernel);
    print_detail_row(phase, "wmb_biu_aw_req",            505, use_kernel);
    print_detail_row(phase, "wmb_biu_w_req",             506, use_kernel);
    print_detail_row(phase, "wmb_biu_nc_req_grnt",       507, use_kernel);
    print_detail_row(phase, "wmb_biu_so_req_grnt",       508, use_kernel);
    print_detail_row(phase, "wmb_mem_set_write_grnt",    509, use_kernel);
    print_detail_row(phase, "wmb_vb_create_req",         510, use_kernel);
    print_detail_row(phase, "wmb_vb_create_vld",         511, use_kernel);
    print_detail_row(phase, "wmb_st_wb_cmplt_req",       512, use_kernel);
    print_detail_row(phase, "wmb_st_wb_spec_fail",       513, use_kernel);
    print_detail_row(phase, "wmb_ld_wb_data_req",        514, use_kernel);
    print_detail_row(phase, "wmb_ld_dc_fwd_req",         515, use_kernel);
    print_detail_row(phase, "wmb_ld_dc_cancel_acc_req",  516, use_kernel);
    print_detail_row(phase, "wmb_pop_depd",              517, use_kernel);
    print_detail_row(phase, "wmb_pop_discard_req",       518, use_kernel);
    print_detail_row(phase, "wmb_pop_fwd_req",           519, use_kernel);
    print_detail_row(phase, "wmb_wakeup_queue_not_empty", 520, use_kernel);
    print_detail_row(phase, "wmb_depd_wakeup",           521, use_kernel);
    print_detail_row(phase, "wmb_b_nc_id_hit",           522, use_kernel);
    print_detail_row(phase, "wmb_b_so_id_hit",           523, use_kernel);
    print_detail_row(phase, "wmb_sync_fence_req_success", 524, use_kernel);
    print_detail_row(phase, "wmb_has_sync_fence",        525, use_kernel);
    print_detail_row(phase, "rb_empty",                  526, use_kernel);
    print_detail_row(phase, "rb_full",                   527, use_kernel);
    print_detail_row(phase, "rb_create_ld_success",      528, use_kernel);
    print_detail_row(phase, "rb_create_st_success",      529, use_kernel);
    print_detail_row(phase, "rb_biu_req_unmask",         530, use_kernel);
    print_detail_row(phase, "rb_biu_ar_req_detail",      531, use_kernel);
    print_detail_row(phase, "rb_biu_req_hit_idx",        532, use_kernel);
    print_detail_row(phase, "rb_biu_nc_req_grnt",        533, use_kernel);
    print_detail_row(phase, "rb_biu_so_req_grnt",        534, use_kernel);
    print_detail_row(phase, "rb_lfb_create_vld",         535, use_kernel);
    print_detail_row(phase, "rb_lfb_boundary_wakeup",    536, use_kernel);
    print_detail_row(phase, "rb_lfb_depd",               537, use_kernel);
    print_detail_row(phase, "rb_pfu_biu_req_hit_idx",    538, use_kernel);
    print_detail_row(phase, "rb_wmb_ce_hit_idx",         539, use_kernel);
    print_detail_row(phase, "rb_ld_da_hit_idx",          540, use_kernel);
    print_detail_row(phase, "rb_st_da_hit_idx",          541, use_kernel);
    print_detail_row(phase, "rb_ld_da_merge_fail",       542, use_kernel);
    print_detail_row(phase, "rb_ld_wb_cmplt_req",        543, use_kernel);
    print_detail_row(phase, "rb_ld_wb_data_req",         544, use_kernel);
    print_detail_row(phase, "rb_entry_read_req_grnt",    545, use_kernel);
    print_detail_row(phase, "rb_entry_wb_cmplt_req",     546, use_kernel);
    print_detail_row(phase, "rb_entry_wb_data_req",      547, use_kernel);
    print_detail_row(phase, "rb_entry_discard_vld",      548, use_kernel);
    print_detail_row(phase, "rb_entry_boundary_wakeup",  549, use_kernel);
    print_detail_row(phase, "rb_pfu_nc_no_pending",      550, use_kernel);
    print_detail_row(phase, "rob_commit0",               551, use_kernel);
    print_detail_row(phase, "rob_commit1",               552, use_kernel);
    print_detail_row(phase, "rob_commit2",               553, use_kernel);
    print_detail_row(phase, "rob_commit_width0_cycle",   554, use_kernel);
    print_detail_row(phase, "rob_commit_width1_cycle",   555, use_kernel);
    print_detail_row(phase, "rob_commit_width2_cycle",   556, use_kernel);
    print_detail_row(phase, "rob_commit_width3_cycle",   557, use_kernel);
    print_detail_row(phase, "rob_read0_valid",           558, use_kernel);
    print_detail_row(phase, "rob_read0_cmplted",         559, use_kernel);
    print_detail_row(phase, "rob_read0_commit",          560, use_kernel);
    print_detail_row(phase, "rob_head_not_complete",     561, use_kernel);
    print_detail_row(phase, "rob_read0_expt_entry",      562, use_kernel);
    print_detail_row(phase, "rob_commit0_mask",          563, use_kernel);
    print_detail_row(phase, "rob_commit1_mask",          564, use_kernel);
    print_detail_row(phase, "rob_commit2_mask",          565, use_kernel);
    print_detail_row(phase, "rob_read0_pipe0_cmplt",     566, use_kernel);
    print_detail_row(phase, "rob_read0_pipe1_cmplt",     567, use_kernel);
    print_detail_row(phase, "rob_read0_pipe2_cmplt",     568, use_kernel);
    print_detail_row(phase, "rob_read0_pipe3_cmplt",     569, use_kernel);
    print_detail_row(phase, "rob_read0_pipe4_cmplt",     570, use_kernel);
    print_detail_row(phase, "rob_read0_pipe6_cmplt",     571, use_kernel);
    print_detail_row(phase, "rob_read0_pipe7_cmplt",     572, use_kernel);
    print_detail_row(phase, "rob_read0_nospec_hit",      573, use_kernel);
    print_detail_row(phase, "rob_read0_nospec_miss",     574, use_kernel);
    print_detail_row(phase, "rob_read0_nospec_misp",     575, use_kernel);
    print_detail_row(phase, "retire_async_expt",         576, use_kernel);
    print_detail_row(phase, "retire_async_no_commit",    577, use_kernel);
    print_detail_row(phase, "retire_async_no_retire",    578, use_kernel);
    print_detail_row(phase, "retire_async_expt_vld",     579, use_kernel);
    print_detail_row(phase, "retire_lsu_all_commit_data",580, use_kernel);
    print_detail_row(phase, "retire_inst0_flush",        581, use_kernel);
    print_detail_row(phase, "retire_inst0_mispred",      582, use_kernel);
    print_detail_row(phase, "retire_rob_flush",          583, use_kernel);
    print_detail_row(phase, "aiq0_ready_any",            584, use_kernel);
    print_detail_row(phase, "aiq1_ready_any",            585, use_kernel);
    print_detail_row(phase, "biq_ready_any",             586, use_kernel);
    print_detail_row(phase, "lsiq_ready_any",            587, use_kernel);
    print_detail_row(phase, "sdiq_ready_any",            588, use_kernel);
    print_detail_row(phase, "viq0_ready_any",            589, use_kernel);
    print_detail_row(phase, "viq1_ready_any",            590, use_kernel);
    print_detail_row(phase, "aiq0_valid_not_ready",      591, use_kernel);
    print_detail_row(phase, "aiq1_valid_not_ready",      592, use_kernel);
    print_detail_row(phase, "biq_valid_not_ready",       593, use_kernel);
    print_detail_row(phase, "lsiq_valid_not_ready",      594, use_kernel);
    print_detail_row(phase, "sdiq_valid_not_ready",      595, use_kernel);
    print_detail_row(phase, "viq0_valid_not_ready",      596, use_kernel);
    print_detail_row(phase, "viq1_valid_not_ready",      597, use_kernel);
    print_detail_row(phase, "aiq0_issue_select_any",     598, use_kernel);
    print_detail_row(phase, "aiq1_issue_select_any",     599, use_kernel);
    print_detail_row(phase, "biq_issue_select_any",      600, use_kernel);
    print_detail_row(phase, "lsiq_issue_select_any",     601, use_kernel);
    print_detail_row(phase, "sdiq_issue_select_any",     602, use_kernel);
    print_detail_row(phase, "viq0_issue_select_any",     603, use_kernel);
    print_detail_row(phase, "viq1_issue_select_any",     604, use_kernel);
    print_detail_row(phase, "iutlb_miss",                605, use_kernel);
    print_detail_row(phase, "dutlb_miss",                606, use_kernel);
    print_detail_row(phase, "jtlb_miss",                 607, use_kernel);
    print_detail_row(phase, "ifu_mmu_va_vld",            608, use_kernel);
    print_detail_row(phase, "mmu_ifu_pavld",             609, use_kernel);
    print_detail_row(phase, "lsu_mmu_va0_vld",           610, use_kernel);
    print_detail_row(phase, "lsu_mmu_va1_vld",           611, use_kernel);
    print_detail_row(phase, "lsu_mmu_va2_vld",           612, use_kernel);
    print_detail_row(phase, "mmu_lsu_pa0_vld",           613, use_kernel);
    print_detail_row(phase, "mmu_lsu_pa1_vld",           614, use_kernel);
    print_detail_row(phase, "mmu_lsu_pa2_vld",           615, use_kernel);
    print_detail_row(phase, "mmu_lsu_stall0",            616, use_kernel);
    print_detail_row(phase, "mmu_lsu_stall1",            617, use_kernel);
    print_detail_row(phase, "mmu_lsu_tlb_busy",          618, use_kernel);
    print_detail_row(phase, "iutlb_arb_req",             619, use_kernel);
    print_detail_row(phase, "iutlb_arb_cmplt",           620, use_kernel);
    print_detail_row(phase, "dutlb_arb_req",             621, use_kernel);
    print_detail_row(phase, "dutlb_arb_cmplt",           622, use_kernel);
    print_detail_row(phase, "jtlb_ptw_req",              623, use_kernel);
    print_detail_row(phase, "ptw_arb_req",               624, use_kernel);
    print_detail_row(phase, "ptw_jtlb_imiss",            625, use_kernel);
    print_detail_row(phase, "ptw_jtlb_dmiss",            626, use_kernel);
    print_detail_row(phase, "ptw_jtlb_pmiss",            627, use_kernel);
    print_detail_row(phase, "ptw_jtlb_ref_cmplt",        628, use_kernel);
    print_detail_row(phase, "ptw_jtlb_ref_data_vld",     629, use_kernel);
    print_detail_row(phase, "mmu_lsu_data_req",          630, use_kernel);
    print_detail_row(phase, "lsu_mmu_data_vld",          631, use_kernel);
    print_detail_row(phase, "ptw_top_imiss",             632, use_kernel);
    print_detail_row(phase, "jtlb_arb_tc_miss",          633, use_kernel);
    print_detail_row(phase, "jtlb_arb_sel_4k",           634, use_kernel);
    print_detail_row(phase, "jtlb_arb_sel_2m",           635, use_kernel);
    print_detail_row(phase, "jtlb_arb_sel_1g",           636, use_kernel);
    print_detail_row(phase, "mmu_lsu_page_fault",        637, use_kernel);
    print_detail_row(phase, "rob_occ_lt32",              638, use_kernel);
    print_detail_row(phase, "rob_occ_32_63",             639, use_kernel);
    print_detail_row(phase, "rob_occ_ge64_bucket",       640, use_kernel);
    print_detail_row(phase, "zero_bad_spec_raw",         641, use_kernel);
    print_detail_row(phase, "zero_frontend_raw",         642, use_kernel);
    print_detail_row(phase, "zero_memory_raw",           643, use_kernel);
    print_detail_row(phase, "zero_backend_raw",          644, use_kernel);
    print_detail_row(phase, "zero_multi_raw_cause",      645, use_kernel);
    print_detail_row(phase, "zero_no_raw_cause",         646, use_kernel);
    print_detail_row(phase, "l0_btb_hit",                647, use_kernel);
    print_detail_row(phase, "l0_btb_miss_deep",          648, use_kernel);
    print_detail_row(phase, "l0_btb_mispred",            649, use_kernel);
    print_detail_row(phase, "l0_btb_wait",               650, use_kernel);
    print_detail_row(phase, "ind_btb_check",             651, use_kernel);
    print_detail_row(phase, "ind_btb_fifo_stall",        652, use_kernel);
    print_detail_row(phase, "ind_btb_miss_deep",         653, use_kernel);
    print_detail_row(phase, "ras_redirect",              654, use_kernel);
    print_detail_row(phase, "ras_mistaken",              655, use_kernel);
    print_detail_row(phase, "lbuf_bju_mispred",          656, use_kernel);
    print_detail_row(phase, "bht_pred_array_rd",         657, use_kernel);
    print_detail_row(phase, "bht_sel_array_rd",          658, use_kernel);
    print_detail_row(phase, "bht_wr_buf_hit",            659, use_kernel);
    print_detail_row(phase, "bht_bju_mispred",           660, use_kernel);
    print_detail_row(phase, "wmb_ld_fwd_req_deep",       661, use_kernel);
    print_detail_row(phase, "wmb_ld_cancel_req_deep",    662, use_kernel);
    print_detail_row(phase, "sq_newest_fwd_req_deep",    663, use_kernel);
    print_detail_row(phase, "sq_data_discard_req_deep",  664, use_kernel);
    print_detail_row(phase, "sq_other_discard_req_deep", 665, use_kernel);
    print_detail_row(phase, "sq_addr_dep_discard_deep",  666, use_kernel);
    print_detail_row(phase, "ld_sq_data_discard_deep",   667, use_kernel);
    print_detail_row(phase, "ld_sq_global_discard_deep", 668, use_kernel);
    print_detail_row(phase, "ld_wmb_discard_deep",       669, use_kernel);
    print_detail_row(phase, "lsu_spec_fail_deep",        670, use_kernel);
    print_detail_row(phase, "lfb_rb_create_entry",       671, use_kernel);
    print_detail_row(phase, "lfb_pfu_create_entry",      672, use_kernel);
    print_detail_row(phase, "lfb_addr_pop_entry",        673, use_kernel);
    print_detail_row(phase, "lfb_data_create_deep",      674, use_kernel);
    print_detail_row(phase, "wmb_entry_create_deep",     675, use_kernel);
    print_detail_row(phase, "wmb_entry_pop_deep",        676, use_kernel);
    print_detail_row(phase, "sq_entry_create_deep",      677, use_kernel);
    print_detail_row(phase, "sq_entry_pop_deep",         678, use_kernel);
    print_detail_row(phase, "biu_rd_outstanding",        679, use_kernel);
    print_detail_row(phase, "biu_rd_outstanding_ge2",    680, use_kernel);
    print_detail_row(phase, "biu_wr_outstanding",        681, use_kernel);
    print_detail_row(phase, "biu_wr_outstanding_ge2",    682, use_kernel);
    print_detail_row(phase, "biu_ar_hs_deep",            683, use_kernel);
    print_detail_row(phase, "biu_rlast_hs_deep",         684, use_kernel);
    print_detail_row(phase, "biu_aw_hs_deep",            685, use_kernel);
    print_detail_row(phase, "biu_b_hs_deep",             686, use_kernel);
    print_detail_row(phase, "pst_async_flush",           687, use_kernel);
    print_detail_row(phase, "pst_preg_recover_vec",      688, use_kernel);
    print_detail_row(phase, "pst_ereg_recover_vec",      689, use_kernel);
    print_detail_row(phase, "pst_preg_all_retired_wb",   690, use_kernel);
    print_detail_row(phase, "pst_preg_empty",            691, use_kernel);
    print_detail_row(phase, "preg_alloc_avail0",         692, use_kernel);
    print_detail_row(phase, "preg_alloc_avail4",         693, use_kernel);
    print_detail_row(phase, "ereg_alloc_avail0",         694, use_kernel);
    print_detail_row(phase, "ereg_alloc_avail4",         695, use_kernel);
    print_detail_row(phase, "flush_fetch_invalid_cycle", 696, use_kernel);
    print_detail_row(phase, "flush_id_invalid_cycle",    697, use_kernel);
    print_detail_row(phase, "ifctrl_ipctrl_vld",         698, use_kernel);
    print_detail_row(phase, "id_inst0_valid",            699, use_kernel);
    print_detail_row(phase, "global_flush_zero_retire",  700, use_kernel);
    print_detail_row(phase, "aiq0_src0_not_ready",       701, use_kernel);
    print_detail_row(phase, "aiq0_src1_not_ready",       702, use_kernel);
    print_detail_row(phase, "aiq0_src2_not_ready",       703, use_kernel);
    print_detail_row(phase, "aiq1_src0_not_ready",       704, use_kernel);
    print_detail_row(phase, "aiq1_src1_not_ready",       705, use_kernel);
    print_detail_row(phase, "aiq1_src2_not_ready",       706, use_kernel);
    print_detail_row(phase, "biq_src0_not_ready",        707, use_kernel);
    print_detail_row(phase, "biq_src1_not_ready",        708, use_kernel);
    print_detail_row(phase, "lsiq_src0_not_ready",       709, use_kernel);
    print_detail_row(phase, "lsiq_src1_not_ready",       710, use_kernel);
    print_detail_row(phase, "lsiq_srcvm_not_ready",      711, use_kernel);
    print_detail_row(phase, "sdiq_src0_not_ready",       712, use_kernel);
    print_detail_row(phase, "sdiq_srcv0_not_ready",      713, use_kernel);
    print_detail_row(phase, "sdiq_staddr_not_ready",     714, use_kernel);
    print_detail_row(phase, "viq0_srcv0_not_ready",      715, use_kernel);
    print_detail_row(phase, "viq0_srcv1_not_ready",      716, use_kernel);
    print_detail_row(phase, "viq0_srcv2_not_ready",      717, use_kernel);
    print_detail_row(phase, "viq0_srcvm_not_ready",      718, use_kernel);
    print_detail_row(phase, "viq1_srcv0_not_ready",      719, use_kernel);
    print_detail_row(phase, "viq1_srcv1_not_ready",      720, use_kernel);
    print_detail_row(phase, "viq1_srcv2_not_ready",      721, use_kernel);
    print_detail_row(phase, "viq1_srcvm_not_ready",      722, use_kernel);
    print_detail_row(phase, "iq_load_dep_not_ready",     723, use_kernel);
    print_detail_row(phase, "iq_nonload_dep_not_ready",  724, use_kernel);
    print_detail_row(phase, "aiq0_load_dep_not_ready",   725, use_kernel);
    print_detail_row(phase, "aiq0_nonload_dep_not_ready",726, use_kernel);
    print_detail_row(phase, "aiq1_load_dep_not_ready",   727, use_kernel);
    print_detail_row(phase, "aiq1_nonload_dep_not_ready",728, use_kernel);
    print_detail_row(phase, "biq_load_dep_not_ready",    729, use_kernel);
    print_detail_row(phase, "biq_nonload_dep_not_ready", 730, use_kernel);
    print_detail_row(phase, "lsiq_load_dep_not_ready",   731, use_kernel);
    print_detail_row(phase, "lsiq_nonload_dep_not_ready",732, use_kernel);
    print_detail_row(phase, "sdiq_load_dep_not_ready",   733, use_kernel);
    print_detail_row(phase, "sdiq_nonload_dep_not_ready",734, use_kernel);
    print_detail_row(phase, "viq0_load_dep_not_ready",   735, use_kernel);
    print_detail_row(phase, "viq0_nonload_dep_not_ready",736, use_kernel);
    print_detail_row(phase, "viq1_load_dep_not_ready",   737, use_kernel);
    print_detail_row(phase, "viq1_nonload_dep_not_ready",738, use_kernel);
    print_detail_row(phase, "iq_ready_not_issued",        739, use_kernel);
    print_detail_row(phase, "aiq0_ready_not_issued",      740, use_kernel);
    print_detail_row(phase, "aiq1_ready_not_issued",      741, use_kernel);
    print_detail_row(phase, "biq_ready_not_issued",       742, use_kernel);
    print_detail_row(phase, "lsiq_ready_not_issued",      743, use_kernel);
    print_detail_row(phase, "sdiq_ready_not_issued",      744, use_kernel);
    print_detail_row(phase, "viq0_ready_not_issued",      745, use_kernel);
    print_detail_row(phase, "viq1_ready_not_issued",      746, use_kernel);
    print_detail_row(phase, "rf_pipe0_src0_no_rdy",       747, use_kernel);
    print_detail_row(phase, "rf_pipe0_src1_no_rdy",       748, use_kernel);
    print_detail_row(phase, "rf_pipe0_src2_no_rdy",       749, use_kernel);
    print_detail_row(phase, "rf_pipe1_src0_no_rdy",       750, use_kernel);
    print_detail_row(phase, "rf_pipe1_src1_no_rdy",       751, use_kernel);
    print_detail_row(phase, "rf_pipe1_src2_no_rdy",       752, use_kernel);
    print_detail_row(phase, "rf_pipe2_src0_no_rdy",       753, use_kernel);
    print_detail_row(phase, "rf_pipe2_src1_no_rdy",       754, use_kernel);
    print_detail_row(phase, "rf_pipe3_src0_no_rdy_deep",  755, use_kernel);
    print_detail_row(phase, "rf_pipe3_src1_no_rdy_deep",  756, use_kernel);
    print_detail_row(phase, "rf_pipe3_srcvm_no_rdy",      757, use_kernel);
    print_detail_row(phase, "rf_pipe4_src0_no_rdy_deep",  758, use_kernel);
    print_detail_row(phase, "rf_pipe4_src1_no_rdy_deep",  759, use_kernel);
    print_detail_row(phase, "rf_pipe4_srcvm_no_rdy",      760, use_kernel);
    print_detail_row(phase, "rf_pipe5_src0_no_rdy",       761, use_kernel);
    print_detail_row(phase, "rf_pipe5_srcv0_no_rdy",      762, use_kernel);
    print_detail_row(phase, "rf_pipe5_staddr_no_rdy",     763, use_kernel);
    print_detail_row(phase, "rf_pipe6_srcv0_no_rdy",      764, use_kernel);
    print_detail_row(phase, "rf_pipe6_srcv1_no_rdy",      765, use_kernel);
    print_detail_row(phase, "rf_pipe6_srcv2_no_rdy",      766, use_kernel);
    print_detail_row(phase, "rf_pipe6_srcvm_no_rdy",      767, use_kernel);
    print_detail_row(phase, "rf_pipe7_srcv0_no_rdy",      768, use_kernel);
    print_detail_row(phase, "rf_pipe7_srcv1_no_rdy",      769, use_kernel);
    print_detail_row(phase, "rf_pipe7_srcv2_no_rdy",      770, use_kernel);
    print_detail_row(phase, "rf_pipe7_srcvm_no_rdy",      771, use_kernel);
    print_detail_row(phase, "rf_src_no_rdy_any_deep",     772, use_kernel);
    print_detail_row(phase, "rf_pipe0_vdiv_mtvr_fail",    773, use_kernel);
    print_detail_row(phase, "rf_pipe3_preg_lch_fail",     774, use_kernel);
    print_detail_row(phase, "rf_pipe3_vreg_lch_fail",     775, use_kernel);
    print_detail_row(phase, "rf_pipe4_vreg_lch_fail",     776, use_kernel);
    print_detail_row(phase, "rf_pipe5_preg_lch_fail",     777, use_kernel);
    print_detail_row(phase, "rf_pipe6_div_mfvr_fail",     778, use_kernel);
    print_detail_row(phase, "rf_pipe6_vmul_unsplit_fail", 779, use_kernel);
    print_detail_row(phase, "rf_pipe7_mult_mfvr_fail",    780, use_kernel);
    print_detail_row(phase, "lsu_replay_data_discard",    781, use_kernel);
    print_detail_row(phase, "lsu_replay_discard_sq",      782, use_kernel);
    print_detail_row(phase, "sq_has_fwd_req",             783, use_kernel);
    print_detail_row(phase, "sq_fwd_req",                 784, use_kernel);
    print_detail_row(phase, "sq_fwd_bypass_req",          785, use_kernel);
    print_detail_row(phase, "sq_fwd_bypass_multi",        786, use_kernel);
    print_detail_row(phase, "sq_fwd_multi",               787, use_kernel);
    print_detail_row(phase, "sq_fwd_multi_mask",          788, use_kernel);
    print_detail_row(phase, "sq_cancel_acc_req",          789, use_kernel);
    print_detail_row(phase, "sq_cancel_ahead_wb",         790, use_kernel);
    print_detail_row(phase, "lsu_ld_ag_wait_old",         791, use_kernel);
    print_detail_row(phase, "lsu_ld_da_wait_old",         792, use_kernel);
    print_detail_row(phase, "lsu_st_ag_wait_old",         793, use_kernel);
    print_detail_row(phase, "lsu_wait_old",               794, use_kernel);
    print_detail_row(phase, "lsu_lq_full_from_idu",       795, use_kernel);
    print_detail_row(phase, "lsu_sq_full_from_idu",       796, use_kernel);
    print_detail_row(phase, "lsu_rb_full_from_idu",       797, use_kernel);
    print_detail_row(phase, "producer_alu0_wakeup",       798, use_kernel);
    print_detail_row(phase, "producer_alu1_wakeup",       799, use_kernel);
    print_detail_row(phase, "producer_mult_wakeup",       800, use_kernel);
    print_detail_row(phase, "producer_div_wakeup",        801, use_kernel);
    print_detail_row(phase, "producer_load_fwd_wakeup",   802, use_kernel);
    print_detail_row(phase, "producer_vload_fwd_wakeup",  803, use_kernel);
    print_detail_row(phase, "producer_vfpu6_wakeup",      804, use_kernel);
    print_detail_row(phase, "producer_vfpu7_wakeup",      805, use_kernel);
  end
  endtask

  task automatic print_profile_row(input string phase, input string name, input int id, input bit use_kernel);
    reg signed [63:0] sum;
    reg signed [63:0] cycles;
    real avg_per_cycle;
  begin
    if(use_kernel) begin
      sum    = $signed(kernel_prof_sum_end[id] - kernel_prof_sum_start[id]);
      cycles = $signed(kernel_cycle_count_end - kernel_cycle_count_start);
    end
    else begin
      sum    = $signed(main_prof_sum_end[id] - main_prof_sum_start[id]);
      cycles = $signed(main_cycle_count_end - main_cycle_count_start);
    end
    avg_per_cycle = (cycles != 0) ? real'(sum) / real'(cycles) : 0.0;
    $display("| %-8s | %-28s |        %-10d |        %-10d |    %-10.3f |",
             phase, name, sum, cycles, avg_per_cycle);
  end
  endtask

  task automatic print_profile_phase(input string phase, input bit use_kernel);
  begin
    print_profile_row(phase, "id_width_avg",         1,  use_kernel);
    print_profile_row(phase, "ir_width_avg",         2,  use_kernel);
    print_profile_row(phase, "is_width_avg",         3,  use_kernel);
    print_profile_row(phase, "rf_launch_width_avg",  4,  use_kernel);
    print_profile_row(phase, "retire_width_avg",     5,  use_kernel);
    print_profile_row(phase, "rob_occ_avg",          6,  use_kernel);
    print_profile_row(phase, "aiq0_occ_avg",         7,  use_kernel);
    print_profile_row(phase, "aiq1_occ_avg",         8,  use_kernel);
    print_profile_row(phase, "biq_occ_avg",          9,  use_kernel);
    print_profile_row(phase, "lsiq_occ_avg",         10, use_kernel);
    print_profile_row(phase, "sdiq_occ_avg",         11, use_kernel);
    print_profile_row(phase, "viq0_occ_avg",         12, use_kernel);
    print_profile_row(phase, "viq1_occ_avg",         13, use_kernel);
    print_profile_row(phase, "lq_occ_avg",           14, use_kernel);
    print_profile_row(phase, "sq_occ_avg",           15, use_kernel);
    print_profile_row(phase, "rb_occ_avg",           16, use_kernel);
    print_profile_row(phase, "lfb_addr_occ_avg",     17, use_kernel);
    print_profile_row(phase, "wmb_occ_avg",          18, use_kernel);
    print_profile_row(phase, "ibuf_occ_avg",         19, use_kernel);
    print_profile_row(phase, "bht_wrbuf_occ_avg",    20, use_kernel);
    print_profile_row(phase, "lfb_data_occ_avg",     21, use_kernel);
    print_profile_row(phase, "retire_load_inst_avg",  22, use_kernel);
    print_profile_row(phase, "retire_store_inst_avg", 23, use_kernel);
    print_profile_row(phase, "retire_bju_inst_avg",   24, use_kernel);
    print_profile_row(phase, "retire_condbr_inst_avg",25, use_kernel);
    print_profile_row(phase, "retire_jmp_inst_avg",   26, use_kernel);
    print_profile_row(phase, "retire_split_inst_avg", 27, use_kernel);
    print_profile_row(phase, "retire_preg_inst_avg",  28, use_kernel);
    print_profile_row(phase, "retire_vreg_inst_avg",  29, use_kernel);
    print_profile_row(phase, "retire_ereg_inst_avg",  30, use_kernel);
    print_profile_row(phase, "retire_nospec_hit_avg", 31, use_kernel);
    print_profile_row(phase, "retire_nospec_miss_avg",32, use_kernel);
    print_profile_row(phase, "retire_nospec_misp_avg",33, use_kernel);
    print_profile_row(phase, "retire_vl_pred_avg",    34, use_kernel);
    print_profile_row(phase, "preg_alloc_req_avg",     35, use_kernel);
    print_profile_row(phase, "preg_alloc_vld_avg",     36, use_kernel);
    print_profile_row(phase, "preg_alloc_block_avg",   37, use_kernel);
    print_profile_row(phase, "ereg_alloc_req_avg",     38, use_kernel);
    print_profile_row(phase, "ereg_alloc_vld_avg",     39, use_kernel);
    print_profile_row(phase, "ereg_alloc_block_avg",   40, use_kernel);
    print_profile_row(phase, "freg_vreg_alloc_req_avg",41, use_kernel);
    print_profile_row(phase, "freg_vreg_alloc_vld_avg",42, use_kernel);
    print_profile_row(phase, "freg_vreg_alloc_block_avg",43, use_kernel);
    print_profile_row(phase, "vfpu_issue_width_avg",   44, use_kernel);
    print_profile_row(phase, "vfpu_wb_width_avg",      45, use_kernel);
    print_profile_row(phase, "pfu_pfb_occ_avg",        46, use_kernel);
    print_profile_row(phase, "pfu_pmb_occ_avg",        47, use_kernel);
    print_profile_row(phase, "pfu_sdb_occ_avg",        48, use_kernel);
    print_profile_row(phase, "vb_addr_occ_avg",        49, use_kernel);
    print_profile_row(phase, "vb_data_occ_avg",        50, use_kernel);
    print_profile_row(phase, "is_create_width_avg",    51, use_kernel);
    print_profile_row(phase, "is_aiq_create_avg",      52, use_kernel);
    print_profile_row(phase, "is_biq_create_avg",      53, use_kernel);
    print_profile_row(phase, "is_lsiq_create_avg",     54, use_kernel);
    print_profile_row(phase, "is_sdiq_create_avg",     55, use_kernel);
    print_profile_row(phase, "is_viq_create_avg",      56, use_kernel);
    print_profile_row(phase, "iq_pop_width_avg",       57, use_kernel);
    print_profile_row(phase, "int_iq_pop_avg",         58, use_kernel);
    print_profile_row(phase, "lsu_iq_pop_avg",         59, use_kernel);
    print_profile_row(phase, "vec_iq_pop_avg",         60, use_kernel);
    print_profile_row(phase, "dca_ld_req_width_avg",   61, use_kernel);
    print_profile_row(phase, "dca_ld_grnt_width_avg",  62, use_kernel);
    print_profile_row(phase, "dca_st_req_width_avg",   63, use_kernel);
    print_profile_row(phase, "dca_st_grnt_width_avg",  64, use_kernel);
    print_profile_row(phase, "lfb_addr_pop_avg",       65, use_kernel);
    print_profile_row(phase, "lfb_dcache_hit_avg",     66, use_kernel);
    print_profile_row(phase, "lfb_depd_wakeup_avg",    67, use_kernel);
    print_profile_row(phase, "lfb_vb_pe_req_avg",      68, use_kernel);
    print_profile_row(phase, "wmb_wakeup_queue_avg",   69, use_kernel);
    print_profile_row(phase, "wmb_depd_wakeup_avg",    70, use_kernel);
    print_profile_row(phase, "wmb_create_width_avg",   71, use_kernel);
    print_profile_row(phase, "rb_create_width_avg",    72, use_kernel);
    print_profile_row(phase, "rb_biu_pe_req_avg",      73, use_kernel);
    print_profile_row(phase, "rob_commit_width_avg",   74, use_kernel);
    print_profile_row(phase, "iq_ready_width_avg",     75, use_kernel);
    print_profile_row(phase, "iq_not_ready_width_avg", 76, use_kernel);
    print_profile_row(phase, "iq_select_width_avg",    77, use_kernel);
    print_profile_row(phase, "int_iq_ready_avg",       78, use_kernel);
    print_profile_row(phase, "lsu_iq_ready_avg",       79, use_kernel);
    print_profile_row(phase, "vec_iq_ready_avg",       80, use_kernel);
    print_profile_row(phase, "int_iq_not_ready_avg",   81, use_kernel);
    print_profile_row(phase, "lsu_iq_not_ready_avg",   82, use_kernel);
    print_profile_row(phase, "vec_iq_not_ready_avg",   83, use_kernel);
    print_profile_row(phase, "mmu_va_req_width_avg",   84, use_kernel);
    print_profile_row(phase, "tlb_refill_req_avg",     85, use_kernel);
    print_profile_row(phase, "tlb_refill_cmplt_avg",   86, use_kernel);
    print_profile_row(phase, "ptw_activity_avg",       87, use_kernel);
    print_profile_row(phase, "mem_wakeup_width_avg",   88, use_kernel);
    print_profile_row(phase, "biu_rd_outstanding_avg", 89, use_kernel);
    print_profile_row(phase, "biu_wr_outstanding_avg", 90, use_kernel);
    print_profile_row(phase, "cpi_raw_cause_avg",      91, use_kernel);
    print_profile_row(phase, "iq_blocked_queue_avg",   92, use_kernel);
    print_profile_row(phase, "iq_ready_queue_avg",     93, use_kernel);
    print_profile_row(phase, "preg_alloc_avail_avg",   94, use_kernel);
    print_profile_row(phase, "ereg_alloc_avail_avg",   95, use_kernel);
    print_profile_row(phase, "aiq0_not_ready_avg",     96, use_kernel);
    print_profile_row(phase, "aiq1_not_ready_avg",     97, use_kernel);
    print_profile_row(phase, "biq_not_ready_avg",      98, use_kernel);
    print_profile_row(phase, "lsiq_not_ready_avg",     99, use_kernel);
    print_profile_row(phase, "sdiq_not_ready_avg",     100, use_kernel);
    print_profile_row(phase, "viq0_not_ready_avg",     101, use_kernel);
    print_profile_row(phase, "viq1_not_ready_avg",     102, use_kernel);
    print_profile_row(phase, "wmb_pop_width_avg",      103, use_kernel);
    print_profile_row(phase, "sq_pop_width_avg",       104, use_kernel);
    print_profile_row(phase, "aiq0_src0_not_ready_avg", 105, use_kernel);
    print_profile_row(phase, "aiq0_src1_not_ready_avg", 106, use_kernel);
    print_profile_row(phase, "aiq0_src2_not_ready_avg", 107, use_kernel);
    print_profile_row(phase, "aiq1_src0_not_ready_avg", 108, use_kernel);
    print_profile_row(phase, "aiq1_src1_not_ready_avg", 109, use_kernel);
    print_profile_row(phase, "aiq1_src2_not_ready_avg", 110, use_kernel);
    print_profile_row(phase, "biq_src0_not_ready_avg", 111, use_kernel);
    print_profile_row(phase, "biq_src1_not_ready_avg", 112, use_kernel);
    print_profile_row(phase, "lsiq_src0_not_ready_avg", 113, use_kernel);
    print_profile_row(phase, "lsiq_src1_not_ready_avg", 114, use_kernel);
    print_profile_row(phase, "lsiq_srcvm_not_ready_avg", 115, use_kernel);
    print_profile_row(phase, "sdiq_src0_not_ready_avg", 116, use_kernel);
    print_profile_row(phase, "sdiq_srcv0_not_ready_avg", 117, use_kernel);
    print_profile_row(phase, "sdiq_staddr_not_ready_avg",118, use_kernel);
    print_profile_row(phase, "viq0_srcv0_not_ready_avg",119, use_kernel);
    print_profile_row(phase, "viq0_srcv1_not_ready_avg",120, use_kernel);
    print_profile_row(phase, "viq0_srcv2_not_ready_avg",121, use_kernel);
    print_profile_row(phase, "viq0_srcvm_not_ready_avg",122, use_kernel);
    print_profile_row(phase, "viq1_srcv0_not_ready_avg",123, use_kernel);
    print_profile_row(phase, "viq1_srcv1_not_ready_avg",124, use_kernel);
    print_profile_row(phase, "viq1_srcv2_not_ready_avg",125, use_kernel);
    print_profile_row(phase, "viq1_srcvm_not_ready_avg",126, use_kernel);
    print_profile_row(phase, "iq_load_dep_not_ready_avg", 127, use_kernel);
    print_profile_row(phase, "iq_nonload_dep_not_ready_avg",128, use_kernel);
    print_profile_row(phase, "aiq0_load_dep_not_ready_avg",129, use_kernel);
    print_profile_row(phase, "aiq0_nonload_dep_not_ready_avg",130, use_kernel);
    print_profile_row(phase, "aiq1_load_dep_not_ready_avg",131, use_kernel);
    print_profile_row(phase, "aiq1_nonload_dep_not_ready_avg",132, use_kernel);
    print_profile_row(phase, "biq_load_dep_not_ready_avg", 133, use_kernel);
    print_profile_row(phase, "biq_nonload_dep_not_ready_avg",134, use_kernel);
    print_profile_row(phase, "lsiq_load_dep_not_ready_avg",135, use_kernel);
    print_profile_row(phase, "lsiq_nonload_dep_not_ready_avg",136, use_kernel);
    print_profile_row(phase, "sdiq_load_dep_not_ready_avg",137, use_kernel);
    print_profile_row(phase, "sdiq_nonload_dep_not_ready_avg",138, use_kernel);
    print_profile_row(phase, "viq0_load_dep_not_ready_avg",139, use_kernel);
    print_profile_row(phase, "viq0_nonload_dep_not_ready_avg",140, use_kernel);
    print_profile_row(phase, "viq1_load_dep_not_ready_avg",141, use_kernel);
    print_profile_row(phase, "viq1_nonload_dep_not_ready_avg",142, use_kernel);
    print_profile_row(phase, "aiq0_issue_select_avg", 143, use_kernel);
    print_profile_row(phase, "aiq1_issue_select_avg", 144, use_kernel);
    print_profile_row(phase, "biq_issue_select_avg",  145, use_kernel);
    print_profile_row(phase, "lsiq_issue_select_avg", 146, use_kernel);
    print_profile_row(phase, "sdiq_issue_select_avg", 147, use_kernel);
    print_profile_row(phase, "viq0_issue_select_avg", 148, use_kernel);
    print_profile_row(phase, "viq1_issue_select_avg", 149, use_kernel);
    print_profile_row(phase, "iq_ready_not_issued_avg",150, use_kernel);
    print_profile_row(phase, "aiq0_ready_not_issued_avg",151, use_kernel);
    print_profile_row(phase, "aiq1_ready_not_issued_avg",152, use_kernel);
    print_profile_row(phase, "biq_ready_not_issued_avg",153, use_kernel);
    print_profile_row(phase, "lsiq_ready_not_issued_avg",154, use_kernel);
    print_profile_row(phase, "sdiq_ready_not_issued_avg",155, use_kernel);
    print_profile_row(phase, "viq0_ready_not_issued_avg",156, use_kernel);
    print_profile_row(phase, "viq1_ready_not_issued_avg",157, use_kernel);
    print_profile_row(phase, "rf_src_no_rdy_width_avg",158, use_kernel);
    print_profile_row(phase, "rf_pipe0_src_no_rdy_avg",159, use_kernel);
    print_profile_row(phase, "rf_pipe1_src_no_rdy_avg",160, use_kernel);
    print_profile_row(phase, "rf_pipe2_src_no_rdy_avg",161, use_kernel);
    print_profile_row(phase, "rf_pipe3_src_no_rdy_avg",162, use_kernel);
    print_profile_row(phase, "rf_pipe4_src_no_rdy_avg",163, use_kernel);
    print_profile_row(phase, "rf_pipe5_src_no_rdy_avg",164, use_kernel);
    print_profile_row(phase, "rf_pipe6_src_no_rdy_avg",165, use_kernel);
    print_profile_row(phase, "rf_pipe7_src_no_rdy_avg",166, use_kernel);
    print_profile_row(phase, "rf_other_fail_width_avg",167, use_kernel);
    print_profile_row(phase, "rf_pipe0_vdiv_mtvr_avg",168, use_kernel);
    print_profile_row(phase, "rf_pipe3_preg_fail_avg",169, use_kernel);
    print_profile_row(phase, "rf_pipe3_vreg_fail_avg",170, use_kernel);
    print_profile_row(phase, "rf_pipe4_vreg_fail_avg",171, use_kernel);
    print_profile_row(phase, "rf_pipe5_preg_fail_avg",172, use_kernel);
    print_profile_row(phase, "rf_pipe6_div_mfvr_avg",173, use_kernel);
    print_profile_row(phase, "rf_pipe6_vmul_unsplit_avg",174, use_kernel);
    print_profile_row(phase, "rf_pipe7_mult_mfvr_avg",175, use_kernel);
    print_profile_row(phase, "lsu_replay_discard_avg",176, use_kernel);
    print_profile_row(phase, "lsu_sq_fwd_width_avg",177, use_kernel);
    print_profile_row(phase, "lsu_sq_cancel_width_avg",178, use_kernel);
    print_profile_row(phase, "lsu_wait_old_width_avg",179, use_kernel);
    print_profile_row(phase, "lsu_queue_full_width_avg",180, use_kernel);
    print_profile_row(phase, "producer_alu0_avg",181, use_kernel);
    print_profile_row(phase, "producer_alu1_avg",182, use_kernel);
    print_profile_row(phase, "producer_mult_avg",183, use_kernel);
    print_profile_row(phase, "producer_div_avg",184, use_kernel);
    print_profile_row(phase, "producer_load_fwd_avg",185, use_kernel);
    print_profile_row(phase, "producer_vload_fwd_avg",186, use_kernel);
    print_profile_row(phase, "producer_vfpu6_avg",187, use_kernel);
    print_profile_row(phase, "producer_vfpu7_avg",188, use_kernel);
    print_profile_row(phase, "producer_wakeup_width_avg",189, use_kernel);
  end
  endtask

  task automatic print_latency_row(input string phase, input string name, input int id, input bit use_kernel);
    reg signed [63:0] samples;
    reg signed [63:0] sum_cycles;
    reg signed [63:0] bucket1;
    reg signed [63:0] bucket2;
    reg signed [63:0] bucket3;
    reg signed [63:0] bucket4;
    reg signed [63:0] bucket5;
    reg signed [63:0] bucket6;
    real avg_cycles;
  begin
    if(use_kernel) begin
      samples    = $signed(kernel_lat_sample_end[id] - kernel_lat_sample_start[id]);
      sum_cycles = $signed(kernel_lat_sum_end[id] - kernel_lat_sum_start[id]);
      bucket1    = $signed(kernel_lat_bucket_end[id][1] - kernel_lat_bucket_start[id][1]);
      bucket2    = $signed(kernel_lat_bucket_end[id][2] - kernel_lat_bucket_start[id][2]);
      bucket3    = $signed(kernel_lat_bucket_end[id][3] - kernel_lat_bucket_start[id][3]);
      bucket4    = $signed(kernel_lat_bucket_end[id][4] - kernel_lat_bucket_start[id][4]);
      bucket5    = $signed(kernel_lat_bucket_end[id][5] - kernel_lat_bucket_start[id][5]);
      bucket6    = $signed(kernel_lat_bucket_end[id][6] - kernel_lat_bucket_start[id][6]);
    end
    else begin
      samples    = $signed(main_lat_sample_end[id] - main_lat_sample_start[id]);
      sum_cycles = $signed(main_lat_sum_end[id] - main_lat_sum_start[id]);
      bucket1    = $signed(main_lat_bucket_end[id][1] - main_lat_bucket_start[id][1]);
      bucket2    = $signed(main_lat_bucket_end[id][2] - main_lat_bucket_start[id][2]);
      bucket3    = $signed(main_lat_bucket_end[id][3] - main_lat_bucket_start[id][3]);
      bucket4    = $signed(main_lat_bucket_end[id][4] - main_lat_bucket_start[id][4]);
      bucket5    = $signed(main_lat_bucket_end[id][5] - main_lat_bucket_start[id][5]);
      bucket6    = $signed(main_lat_bucket_end[id][6] - main_lat_bucket_start[id][6]);
    end
    avg_cycles = (samples != 0) ? real'(sum_cycles) / real'(samples) : 0.0;
    $display("| %-8s | %-28s | %-10d | %-10.3f | %-6d | %-6d | %-6d | %-6d | %-6d | %-6d |",
             phase, name, samples, avg_cycles, bucket1, bucket2, bucket3, bucket4, bucket5, bucket6);
  end
  endtask

  task automatic print_latency_phase(input string phase, input bit use_kernel);
  begin
    print_latency_row(phase, "icache_refill_latency", 1, use_kernel);
    print_latency_row(phase, "biu_ar_to_r_latency",   2, use_kernel);
    print_latency_row(phase, "biu_aw_to_b_latency",   3, use_kernel);
    print_latency_row(phase, "lfb_create_to_refill",   4, use_kernel);
    print_latency_row(phase, "dutlb_arb_latency",      5, use_kernel);
    print_latency_row(phase, "iutlb_arb_latency",      6, use_kernel);
    print_latency_row(phase, "ptw_refill_latency",     7, use_kernel);
    print_latency_row(phase, "zero_retire_episode",    8, use_kernel);
    print_latency_row(phase, "bad_spec_episode",       9, use_kernel);
    print_latency_row(phase, "frontend_bound_episode", 10, use_kernel);
    print_latency_row(phase, "memory_bound_episode",   11, use_kernel);
    print_latency_row(phase, "backend_core_episode",   12, use_kernel);
    print_latency_row(phase, "rob_head_block_latency", 13, use_kernel);
    print_latency_row(phase, "iq_ready_to_select",     14, use_kernel);
    print_latency_row(phase, "iq_wait_to_ready",       15, use_kernel);
    print_latency_row(phase, "ld_replay_pressure",     16, use_kernel);
    print_latency_row(phase, "rb_create_to_wb_cmplt",  17, use_kernel);
    print_latency_row(phase, "rb_create_to_wb_data",   18, use_kernel);
    print_latency_row(phase, "pfu_pe_req_to_grant",    19, use_kernel);
    print_latency_row(phase, "pfu_pe_req_to_lfb",      20, use_kernel);
    print_latency_row(phase, "frontend_stall_episode", 21, use_kernel);
    print_latency_row(phase, "ibuf_full_episode",      22, use_kernel);
    print_latency_row(phase, "ifu_to_id_supply",       23, use_kernel);
    print_latency_row(phase, "mispred_to_retire",      24, use_kernel);
    print_latency_row(phase, "flush_to_retire",        25, use_kernel);
    print_latency_row(phase, "mmu_va_to_pa",           26, use_kernel);
    print_latency_row(phase, "aiq0_wait_to_ready",     27, use_kernel);
    print_latency_row(phase, "aiq1_wait_to_ready",     28, use_kernel);
    print_latency_row(phase, "biq_wait_to_ready",      29, use_kernel);
    print_latency_row(phase, "lsiq_wait_to_ready",     30, use_kernel);
    print_latency_row(phase, "sdiq_wait_to_ready",     31, use_kernel);
    print_latency_row(phase, "viq0_wait_to_ready",     32, use_kernel);
    print_latency_row(phase, "viq1_wait_to_ready",     33, use_kernel);
    print_latency_row(phase, "aiq0_ready_to_issue",    34, use_kernel);
    print_latency_row(phase, "aiq1_ready_to_issue",    35, use_kernel);
    print_latency_row(phase, "biq_ready_to_issue",     36, use_kernel);
    print_latency_row(phase, "lsiq_ready_to_issue",    37, use_kernel);
    print_latency_row(phase, "sdiq_ready_to_issue",    38, use_kernel);
    print_latency_row(phase, "viq0_ready_to_issue",    39, use_kernel);
    print_latency_row(phase, "viq1_ready_to_issue",    40, use_kernel);
    print_latency_row(phase, "dispatch_to_commit",     41, use_kernel);
    print_latency_row(phase, "rob_full_episode",       42, use_kernel);
    print_latency_row(phase, "sq_create_to_pop",       43, use_kernel);
    print_latency_row(phase, "wmb_create_to_pop",      44, use_kernel);
    print_latency_row(phase, "lfb_addr_create_to_pop", 45, use_kernel);
    print_latency_row(phase, "lfb_data_to_empty",      46, use_kernel);
    print_latency_row(phase, "biu_ar_to_rlast",        47, use_kernel);
    print_latency_row(phase, "biu_aw_to_b_full",       48, use_kernel);
    print_latency_row(phase, "flush_to_fetch",         49, use_kernel);
    print_latency_row(phase, "flush_to_id",            50, use_kernel);
    print_latency_row(phase, "mispred_to_fetch",       51, use_kernel);
    print_latency_row(phase, "bht_mispred_episode",   52, use_kernel);
    print_latency_row(phase, "pst_alloc_block_episode",53, use_kernel);
    print_latency_row(phase, "pst_flush_recover",      54, use_kernel);
  end
  endtask

  task automatic print_branch_pc_phase(input string phase, input bit use_kernel);
    perf_pc_t pc;
    longint unsigned exec_count;
    longint unsigned misp_count;
    longint unsigned call_count;
    longint unsigned return_count;
    longint unsigned other_count;
    longint unsigned total_exec;
    longint unsigned total_misp;
    real miss_rate;
  begin
    $display("BRANCH_PC_BEGIN phase=%s source=retire exact=1", phase);
    total_exec = 64'd0;
    total_misp = 64'd0;
    if (use_kernel) begin
      foreach (kernel_cond_exec_by_pc[pc])
        total_exec = total_exec + kernel_cond_exec_by_pc[pc];
      foreach (kernel_cond_misp_by_pc[pc])
        total_misp = total_misp + kernel_cond_misp_by_pc[pc];
      $display("BRANCH_PC_TOTAL phase=%s kind=cond exec=%0d mispred=%0d",
               phase, total_exec, total_misp);
      foreach (kernel_cond_misp_by_pc[pc]) begin
        exec_count = kernel_cond_exec_by_pc.exists(pc)
                   ? kernel_cond_exec_by_pc[pc] : 64'd0;
        misp_count = kernel_cond_misp_by_pc[pc];
        miss_rate = (exec_count != 0)
                  ? 100.0 * real'(misp_count) / real'(exec_count) : 0.0;
        $display("BRANCH_PC phase=%s kind=cond pc=0x%010h exec=%0d mispred=%0d rate_pct=%0.4f call_misp=0 return_misp=0 other_misp=0",
                 phase, pc, exec_count, misp_count, miss_rate);
      end

      total_exec = 64'd0;
      total_misp = 64'd0;
      foreach (kernel_jmp_exec_by_pc[pc])
        total_exec = total_exec + kernel_jmp_exec_by_pc[pc];
      foreach (kernel_jmp_misp_by_pc[pc])
        total_misp = total_misp + kernel_jmp_misp_by_pc[pc];
      $display("BRANCH_PC_TOTAL phase=%s kind=jmp exec=%0d mispred=%0d",
               phase, total_exec, total_misp);
      foreach (kernel_jmp_misp_by_pc[pc]) begin
        exec_count = kernel_jmp_exec_by_pc.exists(pc)
                   ? kernel_jmp_exec_by_pc[pc] : 64'd0;
        misp_count = kernel_jmp_misp_by_pc[pc];
        call_count = kernel_call_misp_by_pc.exists(pc)
                   ? kernel_call_misp_by_pc[pc] : 64'd0;
        return_count = kernel_return_misp_by_pc.exists(pc)
                     ? kernel_return_misp_by_pc[pc] : 64'd0;
        other_count = kernel_other_jmp_misp_by_pc.exists(pc)
                    ? kernel_other_jmp_misp_by_pc[pc] : 64'd0;
        miss_rate = (exec_count != 0)
                  ? 100.0 * real'(misp_count) / real'(exec_count) : 0.0;
        $display("BRANCH_PC phase=%s kind=jmp pc=0x%010h exec=%0d mispred=%0d rate_pct=%0.4f call_misp=%0d return_misp=%0d other_misp=%0d",
                 phase, pc, exec_count, misp_count, miss_rate,
                 call_count, return_count, other_count);
      end
    end
    else begin
      foreach (main_cond_exec_by_pc[pc])
        total_exec = total_exec + main_cond_exec_by_pc[pc];
      foreach (main_cond_misp_by_pc[pc])
        total_misp = total_misp + main_cond_misp_by_pc[pc];
      $display("BRANCH_PC_TOTAL phase=%s kind=cond exec=%0d mispred=%0d",
               phase, total_exec, total_misp);
      foreach (main_cond_misp_by_pc[pc]) begin
        exec_count = main_cond_exec_by_pc.exists(pc)
                   ? main_cond_exec_by_pc[pc] : 64'd0;
        misp_count = main_cond_misp_by_pc[pc];
        miss_rate = (exec_count != 0)
                  ? 100.0 * real'(misp_count) / real'(exec_count) : 0.0;
        $display("BRANCH_PC phase=%s kind=cond pc=0x%010h exec=%0d mispred=%0d rate_pct=%0.4f call_misp=0 return_misp=0 other_misp=0",
                 phase, pc, exec_count, misp_count, miss_rate);
      end

      total_exec = 64'd0;
      total_misp = 64'd0;
      foreach (main_jmp_exec_by_pc[pc])
        total_exec = total_exec + main_jmp_exec_by_pc[pc];
      foreach (main_jmp_misp_by_pc[pc])
        total_misp = total_misp + main_jmp_misp_by_pc[pc];
      $display("BRANCH_PC_TOTAL phase=%s kind=jmp exec=%0d mispred=%0d",
               phase, total_exec, total_misp);
      foreach (main_jmp_misp_by_pc[pc]) begin
        exec_count = main_jmp_exec_by_pc.exists(pc)
                   ? main_jmp_exec_by_pc[pc] : 64'd0;
        misp_count = main_jmp_misp_by_pc[pc];
        call_count = main_call_misp_by_pc.exists(pc)
                   ? main_call_misp_by_pc[pc] : 64'd0;
        return_count = main_return_misp_by_pc.exists(pc)
                     ? main_return_misp_by_pc[pc] : 64'd0;
        other_count = main_other_jmp_misp_by_pc.exists(pc)
                    ? main_other_jmp_misp_by_pc[pc] : 64'd0;
        miss_rate = (exec_count != 0)
                  ? 100.0 * real'(misp_count) / real'(exec_count) : 0.0;
        $display("BRANCH_PC phase=%s kind=jmp pc=0x%010h exec=%0d mispred=%0d rate_pct=%0.4f call_misp=%0d return_misp=%0d other_misp=%0d",
                 phase, pc, exec_count, misp_count, miss_rate,
                 call_count, return_count, other_count);
      end
    end
    $display("BRANCH_PC_END phase=%s", phase);
  end
  endtask
`endif

  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b) begin
      for (int i=1; i<(NUM+1); i++) begin
        event_counter[i] = 64'b0;
        event_n_delay[i] = 4'b0; 
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        detail_counter[i] = 64'b0;
        detail_n_delay[i] = 1'b0;
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        prof_sum_counter[i] = 64'b0;
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        lat_sample_counter[i] = 64'b0;
        lat_sum_counter[i] = 64'b0;
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          lat_bucket_counter[i][j] = 64'b0;
        end
      end
      ic_refill_lat_active = 1'b0;
      ic_refill_lat_age = 32'b0;
      biu_read_lat_active = 1'b0;
      biu_read_lat_age = 32'b0;
      biu_write_lat_active = 1'b0;
      biu_write_lat_age = 32'b0;
      lfb_refill_lat_active = 1'b0;
      lfb_refill_lat_age = 32'b0;
      dutlb_lat_active = 1'b0;
      dutlb_lat_age = 32'b0;
      iutlb_lat_active = 1'b0;
      iutlb_lat_age = 32'b0;
      ptw_lat_active = 1'b0;
      ptw_lat_age = 32'b0;
      biu_rd_outstanding = 8'b0;
      biu_wr_outstanding = 8'b0;
      for (int i=1; i<(LAT_NUM+1); i++) begin
        extra_lat_active[i] = 1'b0;
        extra_lat_age[i] = 32'b0;
      end
`endif
    end
    else begin
      for (int i=1; i<(NUM+1); i++) begin
        event_counter[i] <= event_counter[i] + event_n_delay[i];
        event_n_delay[i] <= get_event_value(i);
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        detail_counter[i] <= detail_counter[i] + detail_n_delay[i];
        detail_n_delay[i] <= get_detail_value(i);
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        prof_sum_counter[i] <= prof_sum_counter[i] + get_profile_value(i);
      end
      case ({(`BIU_READ.biu_pad_arvalid && `BIU_READ.pad_biu_arready),
             (`BIU_READ.pad_biu_rvalid && `BIU_READ.biu_pad_rready && `BIU_READ.pad_biu_rlast)})
        2'b10: biu_rd_outstanding <= biu_rd_outstanding + 8'd1;
        2'b01: biu_rd_outstanding <= (biu_rd_outstanding != 8'd0)
                                    ? biu_rd_outstanding - 8'd1
                                    : 8'd0;
        default: biu_rd_outstanding <= biu_rd_outstanding;
      endcase
      case ({(`BIU_WRITE.biu_pad_awvalid && `BIU_WRITE.pad_awready),
             (`BIU_WRITE.pad_biu_bvalid && `BIU_WRITE.biu_pad_bready)})
        2'b10: biu_wr_outstanding <= biu_wr_outstanding + 8'd1;
        2'b01: biu_wr_outstanding <= (biu_wr_outstanding != 8'd0)
                                    ? biu_wr_outstanding - 8'd1
                                    : 8'd0;
        default: biu_wr_outstanding <= biu_wr_outstanding;
      endcase
      if (`IFU_TOP.l1_refill_ifctrl_start && !ic_refill_lat_active) begin
        ic_refill_lat_active <= 1'b1;
        ic_refill_lat_age <= 32'b0;
      end
      else if (ic_refill_lat_active && `IFU_TOP.l1_refill_ifctrl_trans_cmplt) begin
        record_latency(1, ic_refill_lat_age);
        ic_refill_lat_active <= 1'b0;
        ic_refill_lat_age <= 32'b0;
      end
      else if (ic_refill_lat_active) begin
        ic_refill_lat_age <= ic_refill_lat_age + 32'd1;
      end

      if (`BIU_READ.biu_pad_arvalid && `BIU_READ.pad_biu_arready && !biu_read_lat_active) begin
        biu_read_lat_active <= 1'b1;
        biu_read_lat_age <= 32'b0;
      end
      else if (biu_read_lat_active && `BIU_READ.pad_biu_rvalid && `BIU_READ.biu_pad_rready) begin
        record_latency(2, biu_read_lat_age);
        biu_read_lat_active <= 1'b0;
        biu_read_lat_age <= 32'b0;
      end
      else if (biu_read_lat_active) begin
        biu_read_lat_age <= biu_read_lat_age + 32'd1;
      end

      if (`BIU_WRITE.biu_pad_awvalid && `BIU_WRITE.pad_awready && !biu_write_lat_active) begin
        biu_write_lat_active <= 1'b1;
        biu_write_lat_age <= 32'b0;
      end
      else if (biu_write_lat_active && `BIU_WRITE.pad_biu_bvalid && `BIU_WRITE.biu_pad_bready) begin
        record_latency(3, biu_write_lat_age);
        biu_write_lat_active <= 1'b0;
        biu_write_lat_age <= 32'b0;
      end
      else if (biu_write_lat_active) begin
        biu_write_lat_age <= biu_write_lat_age + 32'd1;
      end

      if ((`LSU_RB.rb_lfb_create_vld || `LSU_PFU.pfu_lfb_create_vld) && !lfb_refill_lat_active) begin
        lfb_refill_lat_active <= 1'b1;
        lfb_refill_lat_age <= 32'b0;
      end
      else if (lfb_refill_lat_active && `LSU_LFB.lfb_lf_sm_create_vld) begin
        record_latency(4, lfb_refill_lat_age);
        lfb_refill_lat_active <= 1'b0;
        lfb_refill_lat_age <= 32'b0;
      end
      else if (lfb_refill_lat_active) begin
        lfb_refill_lat_age <= lfb_refill_lat_age + 32'd1;
      end

      if (`MMU_TOP.dutlb_arb_req && !dutlb_lat_active) begin
        dutlb_lat_active <= 1'b1;
        dutlb_lat_age <= 32'b0;
      end
      else if (dutlb_lat_active && `MMU_TOP.dutlb_arb_cmplt) begin
        record_latency(5, dutlb_lat_age);
        dutlb_lat_active <= 1'b0;
        dutlb_lat_age <= 32'b0;
      end
      else if (dutlb_lat_active) begin
        dutlb_lat_age <= dutlb_lat_age + 32'd1;
      end

      if (`MMU_TOP.iutlb_arb_req && !iutlb_lat_active) begin
        iutlb_lat_active <= 1'b1;
        iutlb_lat_age <= 32'b0;
      end
      else if (iutlb_lat_active && `MMU_TOP.iutlb_arb_cmplt) begin
        record_latency(6, iutlb_lat_age);
        iutlb_lat_active <= 1'b0;
        iutlb_lat_age <= 32'b0;
      end
      else if (iutlb_lat_active) begin
        iutlb_lat_age <= iutlb_lat_age + 32'd1;
      end

      if (`MMU_TOP.jtlb_ptw_req && !ptw_lat_active) begin
        ptw_lat_active <= 1'b1;
        ptw_lat_age <= 32'b0;
      end
      else if (ptw_lat_active && `MMU_TOP.ptw_jtlb_ref_cmplt) begin
        record_latency(7, ptw_lat_age);
        ptw_lat_active <= 1'b0;
        ptw_lat_age <= 32'b0;
      end
      else if (ptw_lat_active) begin
        ptw_lat_age <= ptw_lat_age + 32'd1;
      end

      update_extra_latency(8,  (retire_width() == 4'd0),
                               (retire_width() != 4'd0));
      update_extra_latency(9,  (cpi_stack_class() == 3'd2),
                               (cpi_stack_class() != 3'd2));
      update_extra_latency(10, (cpi_stack_class() == 3'd3),
                               (cpi_stack_class() != 3'd3));
      update_extra_latency(11, (cpi_stack_class() == 3'd4),
                               (cpi_stack_class() != 3'd4));
      update_extra_latency(12, (cpi_stack_class() == 3'd5),
                               (cpi_stack_class() != 3'd5));
      update_extra_latency(13, `RTU_ROB_RT.rtu_had_inst_exe_dead,
                               !`RTU_ROB_RT.rtu_had_inst_exe_dead);
      update_extra_latency(14, (iq_ready_width() != 8'd0) && (iq_issue_select_width() == 8'd0),
                               (iq_issue_select_width() != 8'd0));
      update_extra_latency(15, (iq_valid_not_ready_width() != 8'd0) && (iq_ready_width() == 8'd0),
                               (iq_ready_width() != 8'd0));
      update_extra_latency(16, load_replay_pressure(),
                               !load_replay_pressure());
      update_extra_latency(17, `LSU_RB.rb_create_ld_success,
                               `LSU_RB.rb_ld_wb_cmplt_req);
      update_extra_latency(18, `LSU_RB.rb_create_ld_success,
                               `LSU_RB.rb_ld_wb_data_req_unmask);
      update_extra_latency(19, `LSU_PFU.pfu_biu_pe_req,
                               `LSU_PFU.pfu_biu_pe_req_grnt);
      update_extra_latency(20, `LSU_PFU.pfu_biu_pe_req,
                               `LSU_PFU.pfu_lfb_create_vld);
      update_extra_latency(21, `IFU_IFCTRL.if_frontend_stall,
                               !`IFU_IFCTRL.if_frontend_stall);
      update_extra_latency(22, `IFU_IBCTRL.ibctrl_debug_ibuf_full,
                               !`IFU_IBCTRL.ibctrl_debug_ibuf_full);
      update_extra_latency(23, `IFU_IBCTRL.ibctrl_ibuf_create_vld,
                               `IDU_ID_CTRL.ctrl_top_id_inst0_vld);
      update_extra_latency(24, `RTU_RETIRE.retire_inst0_mispred,
                               (extra_lat_age[24] != 32'b0) && (retire_width() != 4'd0));
      update_extra_latency(25, `RTU_RETIRE.retire_rob_flush,
                               (extra_lat_age[25] != 32'b0) && (retire_width() != 4'd0));
      update_extra_latency(26, (`MMU_TOP.ifu_mmu_va_vld
                             || `MMU_TOP.lsu_mmu_va0_vld
                             || `MMU_TOP.lsu_mmu_va1_vld
                             || `MMU_TOP.lsu_mmu_va2_vld),
                               (`MMU_TOP.mmu_ifu_pavld
                             || `MMU_TOP.mmu_lsu_pa0_vld
                             || `MMU_TOP.mmu_lsu_pa1_vld
                             || `MMU_TOP.mmu_lsu_pa2_vld));
      update_extra_latency(27, |(`IDU_IS_AIQ0.aiq0_entry_vld[7:0] & ~`IDU_IS_AIQ0.aiq0_entry_ready[7:0]),
                               |`IDU_IS_AIQ0.aiq0_entry_ready[7:0]);
      update_extra_latency(28, |(`IDU_IS_AIQ1.aiq1_entry_vld[7:0] & ~`IDU_IS_AIQ1.aiq1_entry_ready[7:0]),
                               |`IDU_IS_AIQ1.aiq1_entry_ready[7:0]);
      update_extra_latency(29, |(`IDU_IS_BIQ.biq_entry_vld[11:0] & ~`IDU_IS_BIQ.biq_entry_ready[11:0]),
                               |`IDU_IS_BIQ.biq_entry_ready[11:0]);
      update_extra_latency(30, |(`IDU_IS_LSIQ.lsiq_entry_vld[11:0] & ~`IDU_IS_LSIQ.lsiq_entry_ready[11:0]),
                               |`IDU_IS_LSIQ.lsiq_entry_ready[11:0]);
      update_extra_latency(31, |(`IDU_IS_SDIQ.sdiq_entry_vld[11:0] & ~`IDU_IS_SDIQ.sdiq_entry_ready[11:0]),
                               |`IDU_IS_SDIQ.sdiq_entry_ready[11:0]);
      update_extra_latency(32, |(`IDU_IS_VIQ0.viq0_entry_vld[7:0] & ~`IDU_IS_VIQ0.viq0_entry_ready[7:0]),
                               |`IDU_IS_VIQ0.viq0_entry_ready[7:0]);
      update_extra_latency(33, |(`IDU_IS_VIQ1.viq1_entry_vld[7:0] & ~`IDU_IS_VIQ1.viq1_entry_ready[7:0]),
                               |`IDU_IS_VIQ1.viq1_entry_ready[7:0]);
      update_extra_latency(34, (|`IDU_IS_AIQ0.aiq0_entry_ready[7:0]) && !(|`IDU_IS_AIQ0.aiq0_entry_issue_en[7:0]),
                               |`IDU_IS_AIQ0.aiq0_entry_issue_en[7:0]);
      update_extra_latency(35, (|`IDU_IS_AIQ1.aiq1_entry_ready[7:0]) && !(|`IDU_IS_AIQ1.aiq1_entry_issue_en[7:0]),
                               |`IDU_IS_AIQ1.aiq1_entry_issue_en[7:0]);
      update_extra_latency(36, (|`IDU_IS_BIQ.biq_entry_ready[11:0]) && !(|`IDU_IS_BIQ.biq_entry_issue_en[11:0]),
                               |`IDU_IS_BIQ.biq_entry_issue_en[11:0]);
      update_extra_latency(37, (|`IDU_IS_LSIQ.lsiq_entry_ready[11:0]) && !(|`IDU_IS_LSIQ.lsiq_entry_issue_en[11:0]),
                               |`IDU_IS_LSIQ.lsiq_entry_issue_en[11:0]);
      update_extra_latency(38, (|`IDU_IS_SDIQ.sdiq_entry_ready[11:0]) && !(|`IDU_IS_SDIQ.sdiq_entry_issue_en[11:0]),
                               |`IDU_IS_SDIQ.sdiq_entry_issue_en[11:0]);
      update_extra_latency(39, (|`IDU_IS_VIQ0.viq0_entry_ready[7:0]) && !(|`IDU_IS_VIQ0.viq0_entry_issue_en[7:0]),
                               |`IDU_IS_VIQ0.viq0_entry_issue_en[7:0]);
      update_extra_latency(40, (|`IDU_IS_VIQ1.viq1_entry_ready[7:0]) && !(|`IDU_IS_VIQ1.viq1_entry_issue_en[7:0]),
                               |`IDU_IS_VIQ1.viq1_entry_issue_en[7:0]);
      update_extra_latency(41, (dispatch_create_width() != 8'd0),
                               (rob_commit_width() != 8'd0));
      update_extra_latency(42, `IDU_TOP.rtu_idu_rob_full,
                               !`IDU_TOP.rtu_idu_rob_full);
      update_extra_latency(43, |`LSU_SQ.sq_create_vld[11:0],
                               |`LSU_SQ.sq_entry_pop_to_ce_grnt[11:0]);
      update_extra_latency(44, |`LSU_WMB.wmb_entry_create_vld[7:0],
                               |`LSU_WMB.wmb_entry_pop_vld[7:0]);
      update_extra_latency(45, (|`LSU_LFB.lfb_addr_entry_rb_create_vld[7:0])
                            || (|`LSU_LFB.lfb_addr_entry_pfu_create_vld[7:0]),
                               |`LSU_LFB.lfb_addr_entry_pop_vld[7:0]);
      update_extra_latency(46, `LSU_LFB.lfb_data_create_vld,
                               !(|`LSU_LFB.lfb_data_entry_vld[1:0]));
      update_extra_latency(47, `BIU_READ.biu_pad_arvalid && `BIU_READ.pad_biu_arready,
                               `BIU_READ.pad_biu_rvalid && `BIU_READ.biu_pad_rready && `BIU_READ.pad_biu_rlast);
      update_extra_latency(48, `BIU_WRITE.biu_pad_awvalid && `BIU_WRITE.pad_awready,
                               `BIU_WRITE.pad_biu_bvalid && `BIU_WRITE.biu_pad_bready);
      update_extra_latency(49, `RTU_RETIRE.retire_rob_flush,
                               `IFU_IFCTRL.ifctrl_ipctrl_vld);
      update_extra_latency(50, `RTU_RETIRE.retire_rob_flush,
                               `IDU_ID_CTRL.ctrl_top_id_inst0_vld);
      update_extra_latency(51, `RTU_RETIRE.retire_inst0_mispred,
                               `IFU_IFCTRL.ifctrl_ipctrl_vld);
      update_extra_latency(52, `IFU_BHT.bju_mispred,
                               !`IFU_BHT.bju_mispred);
      update_extra_latency(53, (`RTU_PST_PREG.idu_rtu_ir_preg0_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg0_vld)
                            || (`RTU_PST_PREG.idu_rtu_ir_preg1_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg1_vld)
                            || (`RTU_PST_PREG.idu_rtu_ir_preg2_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg2_vld)
                            || (`RTU_PST_PREG.idu_rtu_ir_preg3_alloc_vld && !`RTU_PST_PREG.rtu_idu_alloc_preg3_vld),
                               (preg_alloc_avail_width() != 8'd0));
      update_extra_latency(54, `RTU_PST_PREG.retire_pst_async_flush,
                               (preg_alloc_avail_width() != 8'd0) && (ereg_alloc_avail_width() != 8'd0));
`endif
    end
  end

  initial begin
    l3_mode = $value$plusargs("l3_start_pc=%h", l3_start_pc);
    l3_active = 1'b0;
    l3_measure_active = 1'b0;
    l3_user_retired = 64'b0;
    l3_roi_retired = 64'b0;
    l3_cycle_start = 64'b0;
    l3_checkpoint_id = "unknown";
    l3_max_cycles = 64'd500000000;
    if (l3_mode) begin
      if (!$value$plusargs("l3_warmup=%d", l3_warmup_instructions)) begin
        $error("[L3] missing +l3_warmup=<instructions>");
        $finish;
      end
      if (!$value$plusargs("l3_roi=%d", l3_roi_instructions)) begin
        $error("[L3] missing +l3_roi=<instructions>");
        $finish;
      end
      void'($value$plusargs("l3_checkpoint=%s", l3_checkpoint_id));
      void'($value$plusargs("l3_max_cycles=%d", l3_max_cycles));
      $display("[L3] checkpoint=%s start_pc=0x%010h warmup=%0d roi=%0d",
               l3_checkpoint_id, l3_start_pc, l3_warmup_instructions,
               l3_roi_instructions);
    end
  end

`ifdef PERF_DETAIL
  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b) begin
      branch_pc_main_active <= 1'b0;
      branch_pc_kernel_active <= 1'b0;
      main_cond_exec_by_pc.delete();
      main_cond_misp_by_pc.delete();
      main_jmp_exec_by_pc.delete();
      main_jmp_misp_by_pc.delete();
      main_call_misp_by_pc.delete();
      main_return_misp_by_pc.delete();
      main_other_jmp_misp_by_pc.delete();
      kernel_cond_exec_by_pc.delete();
      kernel_cond_misp_by_pc.delete();
      kernel_jmp_exec_by_pc.delete();
      kernel_jmp_misp_by_pc.delete();
      kernel_call_misp_by_pc.delete();
      kernel_return_misp_by_pc.delete();
      kernel_other_jmp_misp_by_pc.delete();
    end
    else begin
      if (branch_pc_main_start) begin
        branch_pc_main_active <= 1'b1;
        main_cond_exec_by_pc.delete();
        main_cond_misp_by_pc.delete();
        main_jmp_exec_by_pc.delete();
        main_jmp_misp_by_pc.delete();
        main_call_misp_by_pc.delete();
        main_return_misp_by_pc.delete();
        main_other_jmp_misp_by_pc.delete();
      end
      else if (branch_pc_main_end) begin
        branch_pc_main_active <= 1'b0;
      end

      if (branch_pc_kernel_start) begin
        branch_pc_kernel_active <= 1'b1;
        kernel_cond_exec_by_pc.delete();
        kernel_cond_misp_by_pc.delete();
        kernel_jmp_exec_by_pc.delete();
        kernel_jmp_misp_by_pc.delete();
        kernel_call_misp_by_pc.delete();
        kernel_return_misp_by_pc.delete();
        kernel_other_jmp_misp_by_pc.delete();
      end
      else if (branch_pc_kernel_end) begin
        branch_pc_kernel_active <= 1'b0;
      end

      if (branch_pc_main_active && !branch_pc_main_end) begin
        record_branch_pc(1'b0,
                         `RTU_RETIRE.retire_inst0_condbr,
                         `RTU_RETIRE.retire_inst0_normal_retire
                           && `RTU_RETIRE.rob_retire_inst0_jmp,
                         `RTU_RETIRE.retire_inst0_normal_retire
                           && `RTU_RETIRE.rob_retire_inst0_bht_mispred,
                         `RTU_RETIRE.retire_inst0_normal_retire
                           && `RTU_RETIRE.rob_retire_inst0_jmp_mispred,
                         `RTU_TOP.rtu_ifu_retire0_pcall,
                         `RTU_TOP.rtu_ifu_retire0_preturn,
                         `retire0_pc);
        record_branch_pc(1'b0,
                         `RTU_RETIRE.retire_inst1_condbr,
                         `RTU_RETIRE.retire_inst1_normal_retire
                           && `RTU_RETIRE.rob_retire_inst1_jmp,
                         1'b0, 1'b0, 1'b0, 1'b0, `retire1_pc);
        record_branch_pc(1'b0,
                         `RTU_RETIRE.retire_inst2_condbr,
                         `RTU_RETIRE.retire_inst2_normal_retire
                           && `RTU_RETIRE.rob_retire_inst2_jmp,
                         1'b0, 1'b0, 1'b0, 1'b0, `retire2_pc);
      end

      if (branch_pc_kernel_active && !branch_pc_kernel_end) begin
        record_branch_pc(1'b1,
                         `RTU_RETIRE.retire_inst0_condbr,
                         `RTU_RETIRE.retire_inst0_normal_retire
                           && `RTU_RETIRE.rob_retire_inst0_jmp,
                         `RTU_RETIRE.retire_inst0_normal_retire
                           && `RTU_RETIRE.rob_retire_inst0_bht_mispred,
                         `RTU_RETIRE.retire_inst0_normal_retire
                           && `RTU_RETIRE.rob_retire_inst0_jmp_mispred,
                         `RTU_TOP.rtu_ifu_retire0_pcall,
                         `RTU_TOP.rtu_ifu_retire0_preturn,
                         `retire0_pc);
        record_branch_pc(1'b1,
                         `RTU_RETIRE.retire_inst1_condbr,
                         `RTU_RETIRE.retire_inst1_normal_retire
                           && `RTU_RETIRE.rob_retire_inst1_jmp,
                         1'b0, 1'b0, 1'b0, 1'b0, `retire1_pc);
        record_branch_pc(1'b1,
                         `RTU_RETIRE.retire_inst2_condbr,
                         `RTU_RETIRE.retire_inst2_normal_retire
                           && `RTU_RETIRE.rob_retire_inst2_jmp,
                         1'b0, 1'b0, 1'b0, 1'b0, `retire2_pc);
      end
    end
  end
`endif

  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b) begin
      l3_active <= 1'b0;
      l3_measure_active <= 1'b0;
      l3_user_retired <= 64'b0;
      l3_roi_retired <= 64'b0;
      l3_cycle_start <= 64'b0;
    end
    else if (l3_mode) begin
      if (`mcycle_value >= l3_max_cycles) begin
        $display("[L3] ERROR timeout after %0d cycles", l3_max_cycles);
        FILE = $fopen("run_case.report","w");
        $fwrite(FILE,"TEST FAIL: L3 timeout");
        $fclose(FILE);
        $finish;
      end
      else if (!l3_active) begin
        if (l3_start_hit0 || l3_start_hit1 || l3_start_hit2) begin
          l3_active <= 1'b1;
          l3_user_retired <= {61'b0, l3_start_retire_width};
          $display("[L3] restored user state reached at cycle=%0d pc=0x%010h",
                   `mcycle_value, l3_start_pc);
        end
      end
      else if (!l3_measure_active) begin
        if (l3_user_retired >= l3_warmup_instructions) begin
          l3_measure_active <= 1'b1;
          l3_roi_retired <= {61'b0, l3_retire_width};
          l3_cycle_start <= `mcycle_value;
          for (int i=1; i<(NUM+1); i++) begin
            l3_event_start[i] <= event_counter[i];
          end
`ifdef PERF_DETAIL
          for (int i=1; i<(DETAIL_NUM+1); i++) begin
            l3_detail_start[i] <= detail_counter[i];
          end
          for (int i=1; i<(PROF_NUM+1); i++) begin
            l3_prof_start[i] <= prof_sum_counter[i];
          end
          for (int i=1; i<(LAT_NUM+1); i++) begin
            l3_lat_sample_start[i] <= lat_sample_counter[i];
            l3_lat_sum_start[i] <= lat_sum_counter[i];
            for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
              l3_lat_bucket_start[i][j] <= lat_bucket_counter[i][j];
            end
          end
`endif
          $display("[L3] ROI start cycle=%0d warmup_retired=%0d",
                   `mcycle_value, l3_user_retired);
        end
        else begin
          l3_user_retired <= l3_user_retired + {61'b0, l3_retire_width};
        end
      end
      else if ((l3_roi_retired + {61'b0, l3_retire_width})
               >= l3_roi_instructions) begin
        l3_roi_retired <= l3_roi_retired + {61'b0, l3_retire_width};
        #1;
        $display("L3_RTL_RESULT checkpoint=%s cycles=%0d instructions=%0d warmup=%0d overshoot=%0d",
                 l3_checkpoint_id,
                 $signed(`mcycle_value - l3_cycle_start),
                 l3_roi_retired,
                 l3_user_retired,
                 $signed(l3_roi_retired - l3_roi_instructions));
        for (int i=1; i<(NUM+1); i++) begin
          $display("L3_EVENT id=%0d value=%0d", i,
                   $signed(event_counter[i] - l3_event_start[i]));
        end
`ifdef PERF_DETAIL
        for (int i=1; i<(DETAIL_NUM+1); i++) begin
          $display("L3_DETAIL id=%0d value=%0d", i,
                   $signed(detail_counter[i] - l3_detail_start[i]));
        end
        for (int i=1; i<(PROF_NUM+1); i++) begin
          $display("L3_PROFILE id=%0d value=%0d", i,
                   $signed(prof_sum_counter[i] - l3_prof_start[i]));
        end
        for (int i=1; i<(LAT_NUM+1); i++) begin
          $display("L3_LATENCY id=%0d samples=%0d sum=%0d",
                   i,
                   $signed(lat_sample_counter[i] - l3_lat_sample_start[i]),
                   $signed(lat_sum_counter[i] - l3_lat_sum_start[i]));
          for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
            $display("L3_LATENCY_BUCKET id=%0d bucket=%0d value=%0d",
                     i, j,
                     $signed(lat_bucket_counter[i][j]
                             - l3_lat_bucket_start[i][j]));
          end
        end
`endif
        FILE = $fopen("run_case.report","w");
        $fwrite(FILE,"TEST PASS: L3 checkpoint ROI complete");
        $fclose(FILE);
        $display("TEST PASS: L3 checkpoint ROI complete");
        $finish;
      end
      else begin
        l3_roi_retired <= l3_roi_retired + {61'b0, l3_retire_width};
      end
    end
  end

  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b) begin
      main_cycle_count_start <= 64'b0;
      main_retire_inst_count_start <= 64'b0;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_start[i] <= 64'b0;
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        main_detail_counter_start[i] <= 64'b0;
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        main_prof_sum_start[i] <= 64'b0;
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        main_lat_sample_start[i] <= 64'b0;
        main_lat_sum_start[i] <= 64'b0;
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          main_lat_bucket_start[i][j] <= 64'b0;
        end
      end
`endif
    end
    else if (((`retire0_pc == sym_main_addr) && `tb_retire0) || ((`retire1_pc == sym_main_addr) && `tb_retire1) || ((`retire2_pc == sym_main_addr) && `tb_retire2)) begin
      main_cycle_count_start <= `mcycle_value;
      main_retire_inst_count_start <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_start[i] <= event_counter[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        main_detail_counter_start[i] <= detail_counter[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        main_prof_sum_start[i] <= prof_sum_counter[i];
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        main_lat_sample_start[i] <= lat_sample_counter[i];
        main_lat_sum_start[i] <= lat_sum_counter[i];
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          main_lat_bucket_start[i][j] <= lat_bucket_counter[i][j];
        end
      end
`endif
    end
    else begin
      main_cycle_count_start <= main_cycle_count_start;
      main_retire_inst_count_start <= main_retire_inst_count_start;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_start[i] <= main_event_counter_start[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        main_detail_counter_start[i] <= main_detail_counter_start[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        main_prof_sum_start[i] <= main_prof_sum_start[i];
      end
`endif
    end
  end
  
  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b) begin
      main_cycle_count_end <= 64'b0;
      main_retire_inst_count_end <= 64'b0;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_end[i] <= 64'b0;
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        main_detail_counter_end[i] <= 64'b0;
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        main_prof_sum_end[i] <= 64'b0;
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        main_lat_sample_end[i] <= 64'b0;
        main_lat_sum_end[i] <= 64'b0;
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          main_lat_bucket_end[i][j] <= 64'b0;
        end
      end
`endif
    end
    else if (((`retire0_pc == sym_exit_addr) && `tb_retire0) || ((`retire1_pc == sym_exit_addr) && `tb_retire1) || ((`retire2_pc == sym_exit_addr) && `tb_retire2)) begin
      main_cycle_count_end <= `mcycle_value;
      main_retire_inst_count_end <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_end[i] <= event_counter[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        main_detail_counter_end[i] <= detail_counter[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        main_prof_sum_end[i] <= prof_sum_counter[i];
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        main_lat_sample_end[i] <= lat_sample_counter[i];
        main_lat_sum_end[i] <= lat_sum_counter[i];
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          main_lat_bucket_end[i][j] <= lat_bucket_counter[i][j];
        end
      end
`endif
    end
    else begin
      main_cycle_count_end <= main_cycle_count_end;
      main_retire_inst_count_end <= main_retire_inst_count_end;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_end[i] <= main_event_counter_end[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        main_detail_counter_end[i] <= main_detail_counter_end[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        main_prof_sum_end[i] <= main_prof_sum_end[i];
      end
`endif
    end
  end

  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b) begin
      kernel_cycle_count_start <= 64'b0;
      kernel_retire_inst_count_start <= 64'b0;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_start[i] <= 64'b0;
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        kernel_detail_counter_start[i] <= 64'b0;
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        kernel_prof_sum_start[i] <= 64'b0;
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        kernel_lat_sample_start[i] <= 64'b0;
        kernel_lat_sum_start[i] <= 64'b0;
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          kernel_lat_bucket_start[i][j] <= 64'b0;
        end
      end
`endif
    end
    else if ((((`retire0_pc == sym_perf_start_addr) && `tb_retire0) || ((`retire1_pc == sym_perf_start_addr) && `tb_retire1) || ((`retire2_pc == sym_perf_start_addr) && `tb_retire2)) && (sym_perf_start_addr != 40'b0)) begin
      kernel_cycle_count_start <= `mcycle_value;
      kernel_retire_inst_count_start <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_start[i] <= event_counter[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        kernel_detail_counter_start[i] <= detail_counter[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        kernel_prof_sum_start[i] <= prof_sum_counter[i];
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        kernel_lat_sample_start[i] <= lat_sample_counter[i];
        kernel_lat_sum_start[i] <= lat_sum_counter[i];
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          kernel_lat_bucket_start[i][j] <= lat_bucket_counter[i][j];
        end
      end
`endif
    end
    else begin
      kernel_cycle_count_start <= kernel_cycle_count_start;
      kernel_retire_inst_count_start <= kernel_retire_inst_count_start;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_start[i] <= kernel_event_counter_start[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        kernel_detail_counter_start[i] <= kernel_detail_counter_start[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        kernel_prof_sum_start[i] <= kernel_prof_sum_start[i];
      end
`endif
    end
  end

  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b) begin
      kernel_cycle_count_end <= 64'b0;
      kernel_retire_inst_count_end <= 64'b0;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_end[i] <= 64'b0;
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        kernel_detail_counter_end[i] <= 64'b0;
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        kernel_prof_sum_end[i] <= 64'b0;
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        kernel_lat_sample_end[i] <= 64'b0;
        kernel_lat_sum_end[i] <= 64'b0;
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          kernel_lat_bucket_end[i][j] <= 64'b0;
        end
      end
`endif
    end
    else if ((((`retire0_pc == sym_perf_end_addr) && `tb_retire0) || ((`retire1_pc == sym_perf_end_addr) && `tb_retire1) || ((`retire2_pc == sym_perf_end_addr) && `tb_retire2)) && (sym_perf_end_addr != 40'b0)) begin
      kernel_cycle_count_end <= `mcycle_value;
      kernel_retire_inst_count_end <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_end[i] <= event_counter[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        kernel_detail_counter_end[i] <= detail_counter[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        kernel_prof_sum_end[i] <= prof_sum_counter[i];
      end
      for (int i=1; i<(LAT_NUM+1); i++) begin
        kernel_lat_sample_end[i] <= lat_sample_counter[i];
        kernel_lat_sum_end[i] <= lat_sum_counter[i];
        for (int j=1; j<(LAT_BUCKET_NUM+1); j++) begin
          kernel_lat_bucket_end[i][j] <= lat_bucket_counter[i][j];
        end
      end
`endif
    end
    else begin
      kernel_cycle_count_end <= kernel_cycle_count_end;
      kernel_retire_inst_count_end <= kernel_retire_inst_count_end;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_end[i] <= kernel_event_counter_end[i];
      end
`ifdef PERF_DETAIL
      for (int i=1; i<(DETAIL_NUM+1); i++) begin
        kernel_detail_counter_end[i] <= kernel_detail_counter_end[i];
      end
      for (int i=1; i<(PROF_NUM+1); i++) begin
        kernel_prof_sum_end[i] <= kernel_prof_sum_end[i];
      end
`endif
    end
  end

  always @(posedge clk)
  begin
    if((`mcycle_value !=0) && (`mcycle_value % `LAST_CYCLE) == 0)//check and reset retire_inst_count every LAST_CYCLE cycles
    begin
      if(`minstret_value == 0)begin
        $display("*************************************************************");
        $display("* Error: There is no instructions retired in the last %d cycles! *", `LAST_CYCLE);
        $display("*              Simulation Fail and Finished!                *");
        $display("*************************************************************");
        #10;
        FILE = $fopen("run_case.report","w");
        $fwrite(FILE,"TEST FAIL");   
  
	$fclose(FILE); 
        $finish;
      end
    end
  end
  
  reg [31:0] cpu_awaddr;
  reg [3:0]  cpu_awlen;
  reg [15:0] cpu_wstrb;
  reg        cpu_wvalid;
  reg [63:0] value0;
  reg [63:0] value1;
  reg [63:0] value2;
  
  
  always @(posedge clk)
  begin
    cpu_awlen[3:0]   <= `SOC_TOP.x_axi_slave128.awlen[3:0];
    cpu_awaddr[31:0] <= `SOC_TOP.x_axi_slave128.mem_addr[31:0];
    cpu_wvalid       <= `SOC_TOP.biu_pad_wvalid;
    cpu_wstrb        <= `SOC_TOP.biu_pad_wstrb;
    // value0           <= `CPU_TOP.core0_pad_wb0_data[63:0];
    // value1           <= `CPU_TOP.core0_pad_wb1_data[63:0];
    // value2           <= `CPU_TOP.core0_pad_wb2_data[63:0];
    value0              <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_iu_top.x_ct_iu_rbus.rbus_pipe0_wb_data[63:0];
    value1              <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_iu_top.x_ct_iu_rbus.rbus_pipe1_wb_data[63:0];
    value2              <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_lsu_top.x_ct_lsu_ld_wb.ld_wb_preg_data_sign_extend[63:0];
  end

  always @(posedge clk)
  begin
    if(value0 == 64'h444333222 || value1 == 64'h444333222 || value2 == 64'h444333222)
    begin
      cpi = real'(`mcycle_value) / `minstret_value;
      main_cpi = real'($signed(main_cycle_count_end - main_cycle_count_start)) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start));
      kernel_cpi = real'($signed(kernel_cycle_count_end - kernel_cycle_count_start)) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start));
      ipc = real'(`minstret_value) / `mcycle_value;
      main_ipc = real'($signed(main_retire_inst_count_end - main_retire_inst_count_start)) / ($signed(main_cycle_count_end - main_cycle_count_start));
      kernel_ipc = real'($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) / ($signed(kernel_cycle_count_end - kernel_cycle_count_start));
      $display("**********************************************************************************");
      $display("*                        simulation finished successfully                        *");
      $display("**********************************************************************************");
      $display("\n=========================== Performance Statistics ==============================");
      $display("|     Phase     |     Cycles     |  Retired Inst  |     CPI      |     IPC      |");
      $display("|---------------|----------------|----------------|--------------|--------------|");
      $display("|     Total     |   %-10d   |   %-10d   |   %-8.3f   |   %-8.3f   |", 
              `mcycle_value, 
              `minstret_value,
              cpi,
              ipc);
      $display("|-------------------------------------------------------------------------------|");
      
      $display("|     Main      |   %-10d   |   %-10d   |   %-8.3f   |   %-8.3f   |", 
              $signed(main_cycle_count_end - main_cycle_count_start),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              main_cpi,
              main_ipc);
      $display("|     Kernel    |   %-10d   |   %-10d   |   %-8.3f   |   %-8.3f   |", 
              $signed(kernel_cycle_count_end - kernel_cycle_count_start),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              kernel_cpi,
              kernel_ipc);
      $display("|-------------------------------------------------------------------------------|");
      $display("|     Main Inst     |    Inst Count     | Total Inst Count  |    Percentage     |");
      $display("|-------------------------------------------------------------------------------|");
      $display("|       ALU         |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[29] - main_event_counter_start[29]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[29] - main_event_counter_start[29])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|    Float Point    |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[42] - main_event_counter_start[42]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[42] - main_event_counter_start[42])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|      Store        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[11] - main_event_counter_start[11]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[11] - main_event_counter_start[11])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|       LDST        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[30] - main_event_counter_start[30]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[30] - main_event_counter_start[30])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|    Cond Branch    |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[7] - main_event_counter_start[7]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[7] - main_event_counter_start[7])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|    Indir Branch   |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[9] - main_event_counter_start[9]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[9] - main_event_counter_start[9])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|     Long Jump     |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[38] - main_event_counter_start[38]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[38] - main_event_counter_start[38])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|        Vec        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[31] - main_event_counter_start[31]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[31] - main_event_counter_start[31])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|        CSR        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[32] - main_event_counter_start[32]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[32] - main_event_counter_start[32])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|       Sync        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[33] - main_event_counter_start[33]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[33] - main_event_counter_start[33])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|       Ecall       |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[37] - main_event_counter_start[37]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[37] - main_event_counter_start[37])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|-------------------------------------------------------------------------------|");
      $display("|     Main Monitor  |    Perf Count     |    Total Perf     |    Percentage     |");
      $display("|-------------------------------------------------------------------------------|");
      $display("| RF Pipe Launches  |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[22] - main_event_counter_start[22]),
              $signed(main_retire_inst_count_end - main_retire_inst_count_start),
              ($signed(main_retire_inst_count_end - main_retire_inst_count_start) != 0) ?
                  100*real'($signed(main_event_counter_end[22] - main_event_counter_start[22])) / ($signed(main_retire_inst_count_end - main_retire_inst_count_start)) : 0.0);
      $display("|      L1I Miss     |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[2] - main_event_counter_start[2]),
              $signed(main_event_counter_end[1] - main_event_counter_start[1]),
              ($signed(main_event_counter_end[1] - main_event_counter_start[1]) != 0) ?
                  100*real'($signed(main_event_counter_end[2] - main_event_counter_start[2])) / ($signed(main_event_counter_end[1] - main_event_counter_start[1])) : 0.0);
      $display("|   L1D Load Miss   |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[13] - main_event_counter_start[13]),
              $signed(main_event_counter_end[12] - main_event_counter_start[12]),
              ($signed(main_event_counter_end[12] - main_event_counter_start[12]) != 0) ?
                  100*real'($signed(main_event_counter_end[13] - main_event_counter_start[13])) / ($signed(main_event_counter_end[12] - main_event_counter_start[12])) : 0.0);
      $display("|   L1D Store Miss  |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[15] - main_event_counter_start[15]),
              $signed(main_event_counter_end[14] - main_event_counter_start[14]),
              ($signed(main_event_counter_end[14] - main_event_counter_start[14]) != 0) ?
                  100*real'($signed(main_event_counter_end[15] - main_event_counter_start[15])) / ($signed(main_event_counter_end[14] - main_event_counter_start[14])) : 0.0);
      $display("|  Cond Branch Misp |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[6] - main_event_counter_start[6]),
              $signed(main_event_counter_end[7] - main_event_counter_start[7]),
              ($signed(main_event_counter_end[7] - main_event_counter_start[7]) != 0) ?
              100*real'($signed(main_event_counter_end[6] - main_event_counter_start[6])) / ($signed(main_event_counter_end[7] - main_event_counter_start[7])) : 0.0);
      $display("| Indir Branch Misp |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[8] - main_event_counter_start[8]),
              $signed(main_event_counter_end[9] - main_event_counter_start[9]),
              ($signed(main_event_counter_end[9] - main_event_counter_start[9]) != 0) ?
              100*real'($signed(main_event_counter_end[8] - main_event_counter_start[8])) / ($signed(main_event_counter_end[9] - main_event_counter_start[9])) : 0.0);
      $display("| IFU Bran Tar Misp |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[27] - main_event_counter_start[27]),
              $signed(main_event_counter_end[28] - main_event_counter_start[28]),
              ($signed(main_event_counter_end[28] - main_event_counter_start[28]) != 0) ?
              100*real'($signed(main_event_counter_end[27] - main_event_counter_start[27])) / ($signed(main_event_counter_end[28] - main_event_counter_start[28])) : 0.0);
      $display("|    Sync Stall     |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[41] - main_event_counter_start[41]),
              $signed(main_cycle_count_end - main_cycle_count_start),
              ($signed(main_cycle_count_end - main_cycle_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[41] - main_event_counter_start[41])) / ($signed(main_cycle_count_end - main_cycle_count_start)) : 0.0);
      $display("|   Frontend Stall  |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[39] - main_event_counter_start[39]),
              $signed(main_cycle_count_end - main_cycle_count_start),
              ($signed(main_cycle_count_end - main_cycle_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[39] - main_event_counter_start[39])) / ($signed(main_cycle_count_end - main_cycle_count_start)) : 0.0);
      $display("|   Backend Stall   |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(main_event_counter_end[40] - main_event_counter_start[40]),
              $signed(main_cycle_count_end - main_cycle_count_start),
              ($signed(main_cycle_count_end - main_cycle_count_start) != 0) ?
              100*real'($signed(main_event_counter_end[40] - main_event_counter_start[40])) / ($signed(main_cycle_count_end - main_cycle_count_start)) : 0.0);
      $display("|    I-UTLB Miss    |        %-10d |                   |                   |",
              $signed(main_event_counter_end[3] - main_event_counter_start[3]));
      $display("|    D-UTLB Miss    |        %-10d |                   |                   |",
              $signed(main_event_counter_end[4] - main_event_counter_start[4]));
      $display("|    JTLB Miss      |        %-10d |                   |                   |",
              $signed(main_event_counter_end[5] - main_event_counter_start[5]));
      $display("|  LSU Spec Fail    |        %-10d |                   |                   |",
              $signed(main_event_counter_end[10] - main_event_counter_start[10]));
      $display("|  RF Launch Fail   |        %-10d |                   |                   |",
              $signed(main_event_counter_end[20] - main_event_counter_start[20]));
      $display("| RF Reg Launch Fail|        %-10d |                   |                   |",
              $signed(main_event_counter_end[21] - main_event_counter_start[21]));
      $display("| LSU Cross 4K Stall|        %-10d |                   |                   |",
              $signed(main_event_counter_end[23] - main_event_counter_start[23]));
      $display("|  LSU Other Stall  |        %-10d |                   |                   |",
              $signed(main_event_counter_end[24] - main_event_counter_start[24]));
      $display("|   LSU SQ Discard  |        %-10d |                   |                   |",
              $signed(main_event_counter_end[25] - main_event_counter_start[25]));
      $display("|LSU SQ Data Discard|        %-10d |                   |                   |",
              $signed(main_event_counter_end[26] - main_event_counter_start[26]));
      $display("|LDST Unaligh Access|        %-10d |                   |                   |",
              $signed(main_event_counter_end[34] - main_event_counter_start[34]));
      $display("|-------------------------------------------------------------------------------|");
      $display("|    Kernel Inst    |    Inst Count     | Total Inst Count  |    Percentage     |");
      $display("|-------------------------------------------------------------------------------|");
      $display("|       ALU         |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[29] - kernel_event_counter_start[29]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[29] - kernel_event_counter_start[29])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|    Float Point    |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[42] - kernel_event_counter_start[42]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[42] - kernel_event_counter_start[42])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|      Store        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[11] - kernel_event_counter_start[11]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[11] - kernel_event_counter_start[11])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|       LDST        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[30] - kernel_event_counter_start[30]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[30] - kernel_event_counter_start[30])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|    Cond Branch    |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[7] - kernel_event_counter_start[7]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[7] - kernel_event_counter_start[7])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|    Indir Branch   |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[9] - kernel_event_counter_start[9]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[9] - kernel_event_counter_start[9])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|     Long Jump     |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[38] - kernel_event_counter_start[38]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[38] - kernel_event_counter_start[38])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|        Vec        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[31] - kernel_event_counter_start[31]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[31] - kernel_event_counter_start[31])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|        CSR        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[32] - kernel_event_counter_start[32]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[32] - kernel_event_counter_start[32])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|       Sync        |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[33] - kernel_event_counter_start[33]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[33] - kernel_event_counter_start[33])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|       Ecall       |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[37] - kernel_event_counter_start[37]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[37] - kernel_event_counter_start[37])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|-------------------------------------------------------------------------------|");
      $display("|   Kernel Monitor  |    Perf Count     |    Total Perf     |    Percentage     |");
      $display("|-------------------------------------------------------------------------------|");
      $display("| RF Pipe Launches  |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[22] - kernel_event_counter_start[22]),
              $signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start),
              ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start) != 0) ?
                  100*real'($signed(kernel_event_counter_end[22] - kernel_event_counter_start[22])) / ($signed(kernel_retire_inst_count_end - kernel_retire_inst_count_start)) : 0.0);
      $display("|      L1I Miss     |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[2] - kernel_event_counter_start[2]),
              $signed(kernel_event_counter_end[1] - kernel_event_counter_start[1]),
              ($signed(kernel_event_counter_end[1] - kernel_event_counter_start[1]) != 0) ?
                  100*real'($signed(kernel_event_counter_end[2] - kernel_event_counter_start[2])) / ($signed(kernel_event_counter_end[1] - kernel_event_counter_start[1])) : 0.0);
      $display("|   L1D Load Miss   |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[13] - kernel_event_counter_start[13]),
              $signed(kernel_event_counter_end[12] - kernel_event_counter_start[12]),
              ($signed(kernel_event_counter_end[12] - kernel_event_counter_start[12]) != 0) ?
                  100*real'($signed(kernel_event_counter_end[13] - kernel_event_counter_start[13])) / ($signed(kernel_event_counter_end[12] - kernel_event_counter_start[12])) : 0.0);
      $display("|   L1D Store Miss  |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[15] - kernel_event_counter_start[15]),
              $signed(kernel_event_counter_end[14] - kernel_event_counter_start[14]),
              ($signed(kernel_event_counter_end[14] - kernel_event_counter_start[14]) != 0) ?
                  100*real'($signed(kernel_event_counter_end[15] - kernel_event_counter_start[15])) / ($signed(kernel_event_counter_end[14] - kernel_event_counter_start[14])) : 0.0);
      $display("|  Cond Branch Misp |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[6] - kernel_event_counter_start[6]),
              $signed(kernel_event_counter_end[7] - kernel_event_counter_start[7]),
              ($signed(kernel_event_counter_end[7] - kernel_event_counter_start[7]) != 0) ?
              100*real'($signed(kernel_event_counter_end[6] - kernel_event_counter_start[6])) / ($signed(kernel_event_counter_end[7] - kernel_event_counter_start[7])) : 0.0);
      $display("| Indir Branch Misp |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[8] - kernel_event_counter_start[8]),
              $signed(kernel_event_counter_end[9] - kernel_event_counter_start[9]),
              ($signed(kernel_event_counter_end[9] - kernel_event_counter_start[9]) != 0) ?
              100*real'($signed(kernel_event_counter_end[8] - kernel_event_counter_start[8])) / ($signed(kernel_event_counter_end[9] - kernel_event_counter_start[9])) : 0.0);
      $display("| IFU Bran Tar Misp |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[27] - kernel_event_counter_start[27]),
              $signed(kernel_event_counter_end[28] - kernel_event_counter_start[28]),
              ($signed(kernel_event_counter_end[28] - kernel_event_counter_start[28]) != 0) ?
              100*real'($signed(kernel_event_counter_end[27] - kernel_event_counter_start[27])) / ($signed(kernel_event_counter_end[28] - kernel_event_counter_start[28])) : 0.0);
      $display("|    Sync Stall     |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[41] - kernel_event_counter_start[41]),
              $signed(kernel_cycle_count_end - kernel_cycle_count_start),
              ($signed(kernel_cycle_count_end - kernel_cycle_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[41] - kernel_event_counter_start[41])) / ($signed(kernel_cycle_count_end - kernel_cycle_count_start)) : 0.0);
      $display("|   Frontend Stall  |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[39] - kernel_event_counter_start[39]),
              $signed(kernel_cycle_count_end - kernel_cycle_count_start),
              ($signed(kernel_cycle_count_end - kernel_cycle_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[39] - kernel_event_counter_start[39])) / ($signed(kernel_cycle_count_end - kernel_cycle_count_start)) : 0.0);
      $display("|   Backend Stall   |        %-10d |        %-10d |    %-8.2f%%      |",
              $signed(kernel_event_counter_end[40] - kernel_event_counter_start[40]),
              $signed(kernel_cycle_count_end - kernel_cycle_count_start),
              ($signed(kernel_cycle_count_end - kernel_cycle_count_start) != 0) ?
              100*real'($signed(kernel_event_counter_end[40] - kernel_event_counter_start[40])) / ($signed(kernel_cycle_count_end - kernel_cycle_count_start)) : 0.0);
      $display("|    I-UTLB Miss    |        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[3] - kernel_event_counter_start[3]));
      $display("|    D-UTLB Miss    |        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[4] - kernel_event_counter_start[4]));
      $display("|    JTLB Miss      |        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[5] - kernel_event_counter_start[5]));
      $display("|  LSU Spec Fail    |        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[10] - kernel_event_counter_start[10]));
      $display("|  RF Launch Fail   |        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[20] - kernel_event_counter_start[20]));
      $display("| RF Reg Launch Fail|        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[21] - kernel_event_counter_start[21]));
      $display("| LSU Cross 4K Stall|        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[23] - kernel_event_counter_start[23]));
      $display("|  LSU Other Stall  |        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[24] - kernel_event_counter_start[24]));
      $display("|   LSU SQ Discard  |        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[25] - kernel_event_counter_start[25]));
      $display("|LSU SQ Data Discard|        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[26] - kernel_event_counter_start[26]));
      $display("|LDST Unaligh Access|        %-10d |                   |                   |",
              $signed(kernel_event_counter_end[34] - kernel_event_counter_start[34]));

`ifdef PERF_DETAIL
      $display("\n====================== Detailed Performance Statistics =======================");
      $display("|  Phase   |              Detail Event       |    Perf Count     |  Retired Inst   |  Per KInst   |    Cycles %%      |");
      $display("|----------|---------------------------------|-------------------|-----------------|--------------|------------------|");
      print_detail_phase("Main", 1'b0);
      $display("|----------|---------------------------------|-------------------|-----------------|--------------|------------------|");
      print_detail_phase("Kernel", 1'b1);
      $display("==============================================================================\n");

      $display("================ Microarchitecture Width / Occupancy Profile ================");
      $display("|  Phase   |          Profile Metric     |       Sum Value   |      Cycles     |  Avg / Cycle |");
      $display("|----------|-----------------------------|-------------------|-----------------|--------------|");
      print_profile_phase("Main", 1'b0);
      $display("|----------|-----------------------------|-------------------|-----------------|--------------|");
      print_profile_phase("Kernel", 1'b1);
      $display("==============================================================================\n");

      $display("====================== Latency Distribution Profile ==========================");
      $display("|  Phase   |          Latency Metric     |  Samples   | Avg Cycles | <=4    | <=8    | <=16   | <=32   | <=64   | >64    |");
      $display("|----------|-----------------------------|------------|------------|--------|--------|--------|--------|--------|--------|");
      print_latency_phase("Main", 1'b0);
      $display("|----------|-----------------------------|------------|------------|--------|--------|--------|--------|--------|--------|");
      print_latency_phase("Kernel", 1'b1);
      $display("==============================================================================\n");

      $display("====================== Branch PC Hotspot Profile =============================");
      print_branch_pc_phase("Main", 1'b0);
      print_branch_pc_phase("Kernel", 1'b1);
      $display("==============================================================================\n");
`endif

      $display("=================================================================================\n");

      #10;
     FILE = $fopen("run_case.report","w");
     $fwrite(FILE,"TEST PASS");   

     $fclose(FILE); 
     $finish;
    end
    else if (value0 == 64'h2382348720 || value1 == 64'h2382348720 || value2 == 64'h2382348720)
    begin
      $display("*********************************************************************************");
      $display("*                        simulation finished with error                         *");
      $display("*********************************************************************************");
     #10;
     FILE = $fopen("run_case.report","w");
     $fwrite(FILE,"TEST FAIL");   

     $fclose(FILE); 
     $finish;
    end
  
    else if((cpu_awlen[3:0] == 4'b0) &&
  //     (cpu_awaddr[31:0] == 32'h6000fff8) &&
  //     (cpu_awaddr[31:0] == 32'h0003fff8) &&
       (cpu_awaddr[31:0] == 32'h01ff_fff0) &&
        cpu_wvalid &&
       `clk_en)
    begin
     if(cpu_wstrb[15:0] == 16'hf)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[7:0]);
     end
     else if(cpu_wstrb[15:0] == 16'hf0)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[39:32]);
     end
     else if(cpu_wstrb[15:0] == 16'hf00)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[71:64]);
     end
     else if(cpu_wstrb[15:0] == 16'hf000)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[103:96]);
     end
    end
  
  end
  
  integer fd;
  initial begin
      fd = $fopen("pc_trace.log", "w");
  end

  always @(posedge clk) begin
    if(`tb_retire0)$fdisplay(fd, "slot0@%10d:%010h", `mcycle_value, `retire0_pc);
    if(`tb_retire1)$fdisplay(fd, "slot1@%10d:%010h", `mcycle_value, `retire1_pc);
    if(`tb_retire2)$fdisplay(fd, "slot2@%10d:%010h", `mcycle_value, `retire2_pc);
  end

  final begin
      $fclose(fd);
  end

  
  integer fd1;
  initial begin
      fd1 = $fopen("reg_trace.log", "w");
  end

  always @(posedge clk) begin
    if(`tb_retire0) begin
      $fwrite(fd1, "slot0@%10d:%010h\n", `mcycle_value, `retire0_pc);
      $fwrite(fd1, "zero: 0x%16h",  64'h0);
      $fwrite(fd1, "  ra: 0x%16h",  get_preg_value(`lpreg1_id ));
      $fwrite(fd1, "  sp: 0x%16h",  get_preg_value(`lpreg2_id ));
      $fwrite(fd1, "  gp: 0x%16h\n",get_preg_value(`lpreg3_id ));
      $fwrite(fd1, "  tp: 0x%16h",  get_preg_value(`lpreg4_id ));
      $fwrite(fd1, "  t0: 0x%16h",  get_preg_value(`lpreg5_id ));
      $fwrite(fd1, "  t1: 0x%16h",  get_preg_value(`lpreg6_id ));
      $fwrite(fd1, "  t2: 0x%16h\n",get_preg_value(`lpreg7_id ));
      $fwrite(fd1, "  s0: 0x%16h",  get_preg_value(`lpreg8_id ));
      $fwrite(fd1, "  s1: 0x%16h",  get_preg_value(`lpreg9_id ));
      $fwrite(fd1, "  a0: 0x%16h",  get_preg_value(`lpreg10_id));
      $fwrite(fd1, "  a1: 0x%16h\n",get_preg_value(`lpreg11_id));
      $fwrite(fd1, "  a2: 0x%16h",  get_preg_value(`lpreg12_id));
      $fwrite(fd1, "  a3: 0x%16h",  get_preg_value(`lpreg13_id));
      $fwrite(fd1, "  a4: 0x%16h",  get_preg_value(`lpreg14_id));
      $fwrite(fd1, "  a5: 0x%16h\n",get_preg_value(`lpreg15_id));
      $fwrite(fd1, "  a6: 0x%16h",  get_preg_value(`lpreg16_id));
      $fwrite(fd1, "  a7: 0x%16h",  get_preg_value(`lpreg17_id));
      $fwrite(fd1, "  s2: 0x%16h",  get_preg_value(`lpreg18_id));
      $fwrite(fd1, "  s3: 0x%16h\n",get_preg_value(`lpreg19_id));
      $fwrite(fd1, "  s4: 0x%16h",  get_preg_value(`lpreg20_id));
      $fwrite(fd1, "  s5: 0x%16h",  get_preg_value(`lpreg21_id));
      $fwrite(fd1, "  s6: 0x%16h",  get_preg_value(`lpreg22_id));
      $fwrite(fd1, "  s7: 0x%16h\n",get_preg_value(`lpreg23_id));
      $fwrite(fd1, "  s8: 0x%16h",  get_preg_value(`lpreg24_id));
      $fwrite(fd1, "  s9: 0x%16h",  get_preg_value(`lpreg25_id));
      $fwrite(fd1, " s10: 0x%16h",  get_preg_value(`lpreg26_id));
      $fwrite(fd1, " s11: 0x%16h\n",get_preg_value(`lpreg27_id));
      $fwrite(fd1, "  t3: 0x%16h",  get_preg_value(`lpreg28_id));
      $fwrite(fd1, "  t4: 0x%16h",  get_preg_value(`lpreg29_id));
      $fwrite(fd1, "  t5: 0x%16h",  get_preg_value(`lpreg30_id));
      $fwrite(fd1, "  t6: 0x%16h\n",get_preg_value(`lpreg31_id));
      $fwrite(fd1, "zero: 0x%16h",  get_preg_value(`lpreg0_id ));
      $fwrite(fd1, "  ra: 0x%16h",  get_preg_value(`lpreg1_id ));
      $fwrite(fd1, "  sp: 0x%16h",  get_preg_value(`lpreg2_id ));
      $fwrite(fd1, "  gp: 0x%16h\n",get_preg_value(`lpreg3_id ));
      $fwrite(fd1, "  tp: 0x%16h",  get_preg_value(`lpreg4_id ));
      $fwrite(fd1, "  t0: 0x%16h",  get_preg_value(`lpreg5_id ));
      $fwrite(fd1, "  t1: 0x%16h",  get_preg_value(`lpreg6_id ));
      $fwrite(fd1, "  t2: 0x%16h\n",get_preg_value(`lpreg7_id ));
      $fwrite(fd1, "  s0: 0x%16h",  get_preg_value(`lpreg8_id ));
      $fwrite(fd1, "  s1: 0x%16h",  get_preg_value(`lpreg9_id ));
      $fwrite(fd1, "  a0: 0x%16h",  get_preg_value(`lpreg10_id));
      $fwrite(fd1, "  a1: 0x%16h\n",get_preg_value(`lpreg11_id));
      $fwrite(fd1, "  a2: 0x%16h",  get_preg_value(`lpreg12_id));
      $fwrite(fd1, "  a3: 0x%16h",  get_preg_value(`lpreg13_id));
      $fwrite(fd1, "  a4: 0x%16h",  get_preg_value(`lpreg14_id));
      $fwrite(fd1, "  a5: 0x%16h\n",get_preg_value(`lpreg15_id));
      $fwrite(fd1, "  a6: 0x%16h",  get_preg_value(`lpreg16_id));
      $fwrite(fd1, "  a7: 0x%16h",  get_preg_value(`lpreg17_id));
      $fwrite(fd1, "  s2: 0x%16h",  get_preg_value(`lpreg18_id));
      $fwrite(fd1, "  s3: 0x%16h\n",get_preg_value(`lpreg19_id));
      $fwrite(fd1, "  s4: 0x%16h",  get_preg_value(`lpreg20_id));
      $fwrite(fd1, "  s5: 0x%16h",  get_preg_value(`lpreg21_id));
      $fwrite(fd1, "  s6: 0x%16h",  get_preg_value(`lpreg22_id));
      $fwrite(fd1, "  s7: 0x%16h\n",get_preg_value(`lpreg23_id));
      $fwrite(fd1, "  s8: 0x%16h",  get_preg_value(`lpreg24_id));
      $fwrite(fd1, "  s9: 0x%16h",  get_preg_value(`lpreg25_id));
      $fwrite(fd1, " s10: 0x%16h",  get_preg_value(`lpreg26_id));
      $fwrite(fd1, " s11: 0x%16h\n",get_preg_value(`lpreg27_id));
      $fwrite(fd1, "  t3: 0x%16h",  get_preg_value(`lpreg28_id));
      $fwrite(fd1, "  t4: 0x%16h",  get_preg_value(`lpreg29_id));
      $fwrite(fd1, "  t5: 0x%16h",  get_preg_value(`lpreg30_id));
      $fwrite(fd1, "  t6: 0x%16h\n",get_preg_value(`lpreg31_id));
    end
  end

  always @(posedge clk) begin
    if(`tb_retire1) begin
      $fdisplay(fd1, "slot1@%10d:%010h", `mcycle_value, `retire1_pc);
      $fwrite(fd1, "zero: 0x%16h",  64'h0);
      $fwrite(fd1, "  ra: 0x%16h",  get_preg_value(`lpreg1_id ));
      $fwrite(fd1, "  sp: 0x%16h",  get_preg_value(`lpreg2_id ));
      $fwrite(fd1, "  gp: 0x%16h\n",get_preg_value(`lpreg3_id ));
      $fwrite(fd1, "  tp: 0x%16h",  get_preg_value(`lpreg4_id ));
      $fwrite(fd1, "  t0: 0x%16h",  get_preg_value(`lpreg5_id ));
      $fwrite(fd1, "  t1: 0x%16h",  get_preg_value(`lpreg6_id ));
      $fwrite(fd1, "  t2: 0x%16h\n",get_preg_value(`lpreg7_id ));
      $fwrite(fd1, "  s0: 0x%16h",  get_preg_value(`lpreg8_id ));
      $fwrite(fd1, "  s1: 0x%16h",  get_preg_value(`lpreg9_id ));
      $fwrite(fd1, "  a0: 0x%16h",  get_preg_value(`lpreg10_id));
      $fwrite(fd1, "  a1: 0x%16h\n",get_preg_value(`lpreg11_id));
      $fwrite(fd1, "  a2: 0x%16h",  get_preg_value(`lpreg12_id));
      $fwrite(fd1, "  a3: 0x%16h",  get_preg_value(`lpreg13_id));
      $fwrite(fd1, "  a4: 0x%16h",  get_preg_value(`lpreg14_id));
      $fwrite(fd1, "  a5: 0x%16h\n",get_preg_value(`lpreg15_id));
      $fwrite(fd1, "  a6: 0x%16h",  get_preg_value(`lpreg16_id));
      $fwrite(fd1, "  a7: 0x%16h",  get_preg_value(`lpreg17_id));
      $fwrite(fd1, "  s2: 0x%16h",  get_preg_value(`lpreg18_id));
      $fwrite(fd1, "  s3: 0x%16h\n",get_preg_value(`lpreg19_id));
      $fwrite(fd1, "  s4: 0x%16h",  get_preg_value(`lpreg20_id));
      $fwrite(fd1, "  s5: 0x%16h",  get_preg_value(`lpreg21_id));
      $fwrite(fd1, "  s6: 0x%16h",  get_preg_value(`lpreg22_id));
      $fwrite(fd1, "  s7: 0x%16h\n",get_preg_value(`lpreg23_id));
      $fwrite(fd1, "  s8: 0x%16h",  get_preg_value(`lpreg24_id));
      $fwrite(fd1, "  s9: 0x%16h",  get_preg_value(`lpreg25_id));
      $fwrite(fd1, " s10: 0x%16h",  get_preg_value(`lpreg26_id));
      $fwrite(fd1, " s11: 0x%16h\n",get_preg_value(`lpreg27_id));
      $fwrite(fd1, "  t3: 0x%16h",  get_preg_value(`lpreg28_id));
      $fwrite(fd1, "  t4: 0x%16h",  get_preg_value(`lpreg29_id));
      $fwrite(fd1, "  t5: 0x%16h",  get_preg_value(`lpreg30_id));
      $fwrite(fd1, "  t6: 0x%16h\n",get_preg_value(`lpreg31_id));
    end
  end

  always @(posedge clk) begin
    if(`tb_retire2) begin
      $fdisplay(fd1, "slot2@%10d:%010h", `mcycle_value, `retire2_pc);
      $fwrite(fd1, "zero: 0x%16h",  64'h0);
      $fwrite(fd1, "  ra: 0x%16h",  get_preg_value(`lpreg1_id ));
      $fwrite(fd1, "  sp: 0x%16h",  get_preg_value(`lpreg2_id ));
      $fwrite(fd1, "  gp: 0x%16h\n",get_preg_value(`lpreg3_id ));
      $fwrite(fd1, "  tp: 0x%16h",  get_preg_value(`lpreg4_id ));
      $fwrite(fd1, "  t0: 0x%16h",  get_preg_value(`lpreg5_id ));
      $fwrite(fd1, "  t1: 0x%16h",  get_preg_value(`lpreg6_id ));
      $fwrite(fd1, "  t2: 0x%16h\n",get_preg_value(`lpreg7_id ));
      $fwrite(fd1, "  s0: 0x%16h",  get_preg_value(`lpreg8_id ));
      $fwrite(fd1, "  s1: 0x%16h",  get_preg_value(`lpreg9_id ));
      $fwrite(fd1, "  a0: 0x%16h",  get_preg_value(`lpreg10_id));
      $fwrite(fd1, "  a1: 0x%16h\n",get_preg_value(`lpreg11_id));
      $fwrite(fd1, "  a2: 0x%16h",  get_preg_value(`lpreg12_id));
      $fwrite(fd1, "  a3: 0x%16h",  get_preg_value(`lpreg13_id));
      $fwrite(fd1, "  a4: 0x%16h",  get_preg_value(`lpreg14_id));
      $fwrite(fd1, "  a5: 0x%16h\n",get_preg_value(`lpreg15_id));
      $fwrite(fd1, "  a6: 0x%16h",  get_preg_value(`lpreg16_id));
      $fwrite(fd1, "  a7: 0x%16h",  get_preg_value(`lpreg17_id));
      $fwrite(fd1, "  s2: 0x%16h",  get_preg_value(`lpreg18_id));
      $fwrite(fd1, "  s3: 0x%16h\n",get_preg_value(`lpreg19_id));
      $fwrite(fd1, "  s4: 0x%16h",  get_preg_value(`lpreg20_id));
      $fwrite(fd1, "  s5: 0x%16h",  get_preg_value(`lpreg21_id));
      $fwrite(fd1, "  s6: 0x%16h",  get_preg_value(`lpreg22_id));
      $fwrite(fd1, "  s7: 0x%16h\n",get_preg_value(`lpreg23_id));
      $fwrite(fd1, "  s8: 0x%16h",  get_preg_value(`lpreg24_id));
      $fwrite(fd1, "  s9: 0x%16h",  get_preg_value(`lpreg25_id));
      $fwrite(fd1, " s10: 0x%16h",  get_preg_value(`lpreg26_id));
      $fwrite(fd1, " s11: 0x%16h\n",get_preg_value(`lpreg27_id));
      $fwrite(fd1, "  t3: 0x%16h",  get_preg_value(`lpreg28_id));
      $fwrite(fd1, "  t4: 0x%16h",  get_preg_value(`lpreg29_id));
      $fwrite(fd1, "  t5: 0x%16h",  get_preg_value(`lpreg30_id));
      $fwrite(fd1, "  t6: 0x%16h\n",get_preg_value(`lpreg31_id));
    end
  end

  final begin
      $fclose(fd1);
  end

  parameter cpu_cycle = 110;
  `ifndef NO_DUMP
  initial
  begin
  `ifdef NC_SIM
    $dumpfile("test.vcd");
    $dumpvars;  
  `else
    `ifdef IVERILOG_SIM
      $dumpfile("test.vcd");
      $dumpvars;  
    `else
      $fsdbDumpvars();
    `endif
  `endif
  end
  `endif
  
  assign jtg_tdi = 1'b0;
  assign uart0_sin = 1'b1;
  
  
  soc x_soc(
    .i_pad_clk           ( clk                  ),
    .b_pad_gpio_porta    ( b_pad_gpio_porta     ),
    .i_pad_jtg_trst_b    ( jrst_b               ),
    .i_pad_jtg_tclk      ( jclk                 ),
    .i_pad_jtg_tdi       ( jtg_tdi              ),
    .i_pad_jtg_tms       ( jtg_tms              ),
    .i_pad_uart0_sin     ( uart0_sin            ),
    .o_pad_jtg_tdo       ( jtg_tdo              ),
    .o_pad_uart0_sout    ( uart0_sout           ),
    .i_pad_rst_b         ( rst_b                )
  );
  
  int_mnt x_int_mnt(
  );
  
  // debug_stim x_debug_stim(
  // );

// Latest Power control
`ifdef UPF_INCLUDED
  import UPF::*;

  initial
  begin
        supply_on ("VDD", 1.00);
     	supply_on ("VDDG", 1.00);
  end

  initial 
  begin
    $deposit(tb.x_soc.pmu_cpu_pwr_on,  1'b1);
    $deposit(tb.x_soc.pmu_cpu_iso_in,  1'b0);
    $deposit(tb.x_soc.pmu_cpu_iso_out, 1'b0);
    $deposit(tb.x_soc.pmu_cpu_save,    1'b0);
    $deposit(tb.x_soc.pmu_cpu_restore, 1'b0);
  end
`endif
  
  reg [31:0] virtual_counter;
  
  always @(posedge `CPU_CLK or negedge `CPU_RST)
  begin
    if(!`CPU_RST)
      virtual_counter[31:0] <= 32'b0;
    else if(virtual_counter[31:0]==32'hffffffff)
      virtual_counter[31:0] <= virtual_counter[31:0];
    else
      virtual_counter[31:0] <= virtual_counter[31:0] +1'b1;
  end 
  
  //always @(*)
  //begin
  //if(virtual_counter[31:0]> 32'h3000000) $finish;
  //end
  
endmodule
