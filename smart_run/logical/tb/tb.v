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

  initial
  begin
  #(`MAX_RUN_TIME * `CLK_PERIOD);
    $display("**********************************************");
    $display("  Error: Simulation Timeout (Max %0d cycles)!  ", `MAX_RUN_TIME);
    $display("**********************************************");
    FILE = $fopen("run_case.report","w");
    $fwrite(FILE, "TEST FAIL: Timeout after %d cycles", `MAX_RUN_TIME);

    $fclose(FILE); 
  $finish;
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

  parameter NUM = 42; 
  reg [3:0]  event_n_delay[NUM:1]; 
  reg [63:0] event_counter[NUM:1];
  reg [63:0] main_event_counter_start[NUM:1];
  reg [63:0] main_event_counter_end[NUM:1];
  reg [63:0] kernel_event_counter_start[NUM:1];
  reg [63:0] kernel_event_counter_end[NUM:1];

  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b) begin
      for (int i=1; i<(NUM+1); i++) begin
        event_counter[i] = 64'b0;
        event_n_delay[i] = 4'b0; 
      end
    end
    else begin
      for (int i=1; i<(NUM+1); i++) begin
        event_counter[i] <= event_counter[i] + event_n_delay[i];
        event_n_delay[i] <= get_event_value(i);
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
    end
    else if (((`retire0_pc == `main_ADDR) && `tb_retire0) || ((`retire1_pc == `main_ADDR) && `tb_retire1) || ((`retire2_pc == `main_ADDR) && `tb_retire2)) begin
      main_cycle_count_start <= `mcycle_value;
      main_retire_inst_count_start <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_start[i] <= event_counter[i];
      end
    end
    else begin
      main_cycle_count_start <= main_cycle_count_start;
      main_retire_inst_count_start <= main_retire_inst_count_start;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_start[i] <= main_event_counter_start[i];
      end
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
    end
    else if (((`retire0_pc == `__exit_ADDR) && `tb_retire0) || ((`retire1_pc == `__exit_ADDR) && `tb_retire1) || ((`retire2_pc == `__exit_ADDR) && `tb_retire2)) begin
      main_cycle_count_end <= `mcycle_value;
      main_retire_inst_count_end <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_end[i] <= event_counter[i];
      end
    end
    else begin
      main_cycle_count_end <= main_cycle_count_end;
      main_retire_inst_count_end <= main_retire_inst_count_end;
      for (int i=1; i<(NUM+1); i++) begin
        main_event_counter_end[i] <= main_event_counter_end[i];
      end
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
    end
    else if ((((`retire0_pc == `perf_monitor_start_ADDR) && `tb_retire0) || ((`retire1_pc == `perf_monitor_start_ADDR) && `tb_retire1) || ((`retire2_pc == `perf_monitor_start_ADDR) && `tb_retire2)) && (`perf_monitor_start_ADDR != 32'b0)) begin
      kernel_cycle_count_start <= `mcycle_value;
      kernel_retire_inst_count_start <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_start[i] <= event_counter[i];
      end
    end
    else begin
      kernel_cycle_count_start <= kernel_cycle_count_start;
      kernel_retire_inst_count_start <= kernel_retire_inst_count_start;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_start[i] <= kernel_event_counter_start[i];
      end
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
    end
    else if ((((`retire0_pc == `perf_monitor_end_ADDR) && `tb_retire0) || ((`retire1_pc == `perf_monitor_end_ADDR) && `tb_retire1) || ((`retire2_pc == `perf_monitor_end_ADDR) && `tb_retire2)) && (`perf_monitor_end_ADDR != 32'b0)) begin
      kernel_cycle_count_end <= `mcycle_value;
      kernel_retire_inst_count_end <= `minstret_value;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_end[i] <= event_counter[i];
      end
    end
    else begin
      kernel_cycle_count_end <= kernel_cycle_count_end;
      kernel_retire_inst_count_end <= kernel_retire_inst_count_end;
      for (int i=1; i<(NUM+1); i++) begin
        kernel_event_counter_end[i] <= kernel_event_counter_end[i];
      end
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
