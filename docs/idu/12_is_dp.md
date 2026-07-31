# C910 IDU IS 阶段数据通路模块详解（`ct_idu_is_dp`）

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [IS 流水级寄存器（`is_pipe_entry`）](#3-is-流水级寄存器is_pipe_entry)
4. [分发指令数据组织（IS 数据字段布局）](#4-分发指令数据组织is-数据字段布局)
5. [IR→IS 流水推进与移位 MUX](#5-iris-流水推进与移位-mux)
6. [各执行单元写回信号的接收与唤醒原理](#6-各执行单元写回信号的接收与唤醒原理)
7. [源操作数相关性检测（同组内指令间唤醒）](#7-源操作数相关性检测同组内指令间唤醒)
8. [发射就绪信号（lch\_rdy）的生成](#8-发射就绪信号lch_rdy的生成)
9. [IID 分配与 PST 输出](#9-iid-分配与-pst-输出)
10. [向各发射队列输出分发数据（MUX 选择）](#10-向各发射队列输出分发数据mux-选择)
11. [ROB 写入数据](#11-rob-写入数据)
12. [LSU VMB 创建数据](#12-lsu-vmb-创建数据)
13. [PCFIFO PID 分配](#13-pcfifo-pid-分配)
14. [整体数据流总结](#14-整体数据流总结)

---

## 1. 模块概述

`ct_idu_is_dp` 是 C910 处理器 IDU（指令分发单元）中 **IS（Issue Stage，发射准备阶段）的数据通路**模块。它处于 IR 阶段（重命名/读寄存器完成）和各发射队列（AIQ、BIQ、LSIQ、SDIQ、VIQ 等）之间，负责将已完成重命名的指令信息暂存、加工，再分发到对应的发射队列。

### 1.1 主要职责

```
IR 阶段 (重命名完成)
         |
         v
   +------------+
   | is_dp      |  <-- 本模块
   |  inst0     |  4 路同时分发
   |  inst1     |
   |  inst2     |
   |  inst3     |
   +------------+
         |
   ------+------+-------+-----+------+------+------
   |     |      |       |     |      |      |
  AIQ0  AIQ1   BIQ    LSIQ  SDIQ   VIQ0  VIQ1
                                     |
                                    ROB / PST
```

具体职责包括：

1. **流水线暂存**：将来自 IR 阶段的 4 路指令数据（271 位宽 × 4）锁存在 4 个 `is_pipe_entry` 实例中，每拍在 `ctrl_ir_pipedown` 且无 stall 时刷新。
2. **唤醒监测**：每个 `is_pipe_entry` 实例内部持续监测来自各执行单元的写回信号（preg 写回、vreg 写回），动态更新本指令的源操作数就绪状态（`src_rdy`）。
3. **同组内就绪（lch\_rdy）计算**：当本批次 4 条指令中某条指令是另一条指令的生产者时，计算跨指令的发射就绪位向量，以便入队时已标注依赖关系。
4. **数据重组**：将内部统一格式的 IS 数据重新打包为各发射队列所需的专有格式（AIQ0、AIQ1、BIQ、LSIQ、SDIQ、VIQ0、VIQ1）。
5. **IID 分配**：从 RTU/ROB 接收分配的指令 ID（IID），与物理寄存器号等一起输出给 PST（物理寄存器状态表）和各发射队列。
6. **ROB 条目创建**：生成向 ROB 写入的控制信息（ROB entry data）。
7. **VMB 创建**：为向量 load/store 指令生成向量内存缓冲区（VMB）的初始化数据。

### 1.2 关键数值

| 参数 | 值 |
|------|-----|
| 分发路数 | 4（inst0 \~ inst3）|
| IS 数据总线宽 | 271 位（IS_WIDTH=271）|
| 物理整型寄存器号位宽 | 7 位（最多 128 个 preg）|
| 物理向量寄存器号位宽 | 7 位（最多 128 个 vreg）|
| AIQ0 输出宽度 | 227 位 |
| AIQ1 输出宽度 | 214 位 |
| BIQ 输出宽度 | 82 位 |
| LSIQ 输出宽度 | 163 位 |
| SDIQ 输出宽度 | 27 位 |
| VIQ0 输出宽度 | 151 位 |
| VIQ1 输出宽度 | 150 位 |
| ROB 条目宽度 | 40 位 |

---

## 2. 端口说明

### 2.1 时钟与复位

| 端口 | 方向 | 说明 |
|------|------|------|
| `forever_cpuclk` | in | 全局时钟 |
| `cpurst_b` | in | 低有效同步复位 |
| `cp0_yy_clk_en` | in | 全局时钟使能（来自 CP0） |
| `cp0_idu_icg_en` | in | IDU 门控时钟使能 |
| `pad_yy_icg_scan_en` | in | 扫描模式时钟使能 |

### 2.2 来自 IR 阶段的指令数据

| 端口 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `dp_ir_inst0_data[270:0]` | in | 271 | inst0 的 IR 阶段数据 |
| `dp_ir_inst1_data[270:0]` | in | 271 | inst1 的 IR 阶段数据 |
| `dp_ir_inst2_data[270:0]` | in | 271 | inst2 的 IR 阶段数据 |
| `dp_ir_inst3_data[270:0]` | in | 271 | inst3 的 IR 阶段数据 |
| `dp_ir_inst01_src_match[3:0]` | in | 4 | inst0 源操作数是否匹配 inst1 目标（位 [3:2]=src2/src1，[1:0]=alu/lsu 类型区分）|
| `dp_ir_inst02_src_match[3:0]` | in | 4 | inst0 源是否匹配 inst2 目标 |
| `dp_ir_inst03_src_match[3:0]` | in | 4 | inst0 源是否匹配 inst3 目标 |
| `dp_ir_inst12_src_match[3:0]` | in | 4 | inst1 源是否匹配 inst2 目标 |
| `dp_ir_inst13_src_match[3:0]` | in | 4 | inst1 源是否匹配 inst3 目标 |
| `dp_ir_inst23_src_match[3:0]` | in | 4 | inst2 源是否匹配 inst3 目标 |

### 2.3 来自各执行单元的写回/唤醒广播信号（重点）

这组信号是唤醒机制的核心输入，每个执行管道广播"本周期我写回了哪个物理寄存器"，供 IS 阶段的每个 `is_pipe_entry` 检测自身源操作数的就绪情况。

#### 整型执行单元（IU，pipe0/1）

| 端口 | 方向 | 说明 |
|------|------|------|
| `iu_idu_ex2_pipe0_wb_preg_dupx[6:0]` | in | Pipe0 EX2 写回物理寄存器号 |
| `iu_idu_ex2_pipe0_wb_preg_vld_dupx` | in | Pipe0 EX2 写回有效（ALU 类，2 拍延迟）|
| `iu_idu_ex2_pipe1_wb_preg_dupx[6:0]` | in | Pipe1 EX2 写回物理寄存器号 |
| `iu_idu_ex2_pipe1_wb_preg_vld_dupx` | in | Pipe1 EX2 写回有效 |
| `iu_idu_ex2_pipe1_mult_inst_vld_dupx` | in | Pipe1 乘法指令有效（用于乘法特殊唤醒路径）|
| `iu_idu_ex2_pipe1_preg_dupx[6:0]` | in | Pipe1 EX2 乘法目标 preg |
| `iu_idu_div_inst_vld` | in | 除法指令写回有效（可变延迟，完成时广播）|
| `iu_idu_div_preg_dupx[6:0]` | in | 除法目标 preg |

#### 访存单元（LSU，pipe3）

| 端口 | 方向 | 说明 |
|------|------|------|
| `lsu_idu_ag_pipe3_load_inst_vld` | in | AG（地址生成）阶段 load 有效（用于推测性早唤醒）|
| `lsu_idu_ag_pipe3_preg_dupx[6:0]` | in | AG 阶段 load 目标 preg |
| `lsu_idu_ag_pipe3_vload_inst_vld` | in | AG 阶段向量 load 有效 |
| `lsu_idu_ag_pipe3_vreg_dupx[6:0]` | in | AG 阶段向量 load 目标 vreg |
| `lsu_idu_dc_pipe3_load_inst_vld_dupx` | in | DC（数据 Cache）阶段 load 有效 |
| `lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx` | in | DC 阶段 load forward 有效（数据直通）|
| `lsu_idu_dc_pipe3_preg_dupx[6:0]` | in | DC 阶段 load 目标 preg |
| `lsu_idu_dc_pipe3_vload_inst_vld_dupx` | in | DC 阶段向量 load 有效 |
| `lsu_idu_dc_pipe3_vload_fwd_inst_vld` | in | DC 阶段向量 load forward 有效 |
| `lsu_idu_dc_pipe3_vreg_dupx[6:0]` | in | DC 阶段向量 load 目标 vreg |
| `lsu_idu_wb_pipe3_wb_preg_dupx[6:0]` | in | WB 阶段整型写回 preg |
| `lsu_idu_wb_pipe3_wb_preg_vld_dupx` | in | WB 阶段整型写回有效 |
| `lsu_idu_wb_pipe3_wb_vreg_dupx[6:0]` | in | WB 阶段向量写回 vreg |
| `lsu_idu_wb_pipe3_wb_vreg_vld_dupx` | in | WB 阶段向量写回有效 |

#### 向量浮点单元（VFPU，pipe6/7）

| 端口 | 方向 | 说明 |
|------|------|------|
| `vfpu_idu_ex1_pipe6_data_vld_dupx` | in | Pipe6 EX1 数据就绪（普通向量指令，4 拍延迟路径）|
| `vfpu_idu_ex1_pipe6_fmla_data_vld_dupx` | in | Pipe6 EX1 fmla 数据就绪 |
| `vfpu_idu_ex1_pipe6_mfvr_inst_vld_dupx` | in | Pipe6 EX1 mfvr（向量寄存器到整型）指令有效，目标为 preg |
| `vfpu_idu_ex1_pipe6_preg_dupx[6:0]` | in | Pipe6 EX1 整型目标 preg（mfvr 使用）|
| `vfpu_idu_ex1_pipe6_vreg_dupx[6:0]` | in | Pipe6 EX1 向量目标 vreg |
| `vfpu_idu_ex2_pipe6_data_vld_dupx` | in | Pipe6 EX2 数据就绪 |
| `vfpu_idu_ex2_pipe6_fmla_data_vld_dupx` | in | Pipe6 EX2 fmla 数据就绪 |
| `vfpu_idu_ex2_pipe6_vreg_dupx[6:0]` | in | Pipe6 EX2 向量 vreg |
| `vfpu_idu_ex3_pipe6_data_vld_dupx` | in | Pipe6 EX3 数据就绪 |
| `vfpu_idu_ex3_pipe6_vreg_dupx[6:0]` | in | Pipe6 EX3 向量 vreg |
| `vfpu_idu_ex5_pipe6_wb_vreg_dupx[6:0]` | in | Pipe6 EX5（最终）写回 vreg |
| `vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx` | in | Pipe6 EX5 写回有效 |
| （pipe7 同结构，不再赘述）| | |

#### RF 读出阶段特殊信号

| 端口 | 方向 | 说明 |
|------|------|------|
| `ctrl_xx_rf_pipe0_preg_lch_vld_dupx` | in | Pipe0 RF 读出 lch（latch）有效，用于 srcv2 寄存器特殊路径 |
| `ctrl_xx_rf_pipe1_preg_lch_vld_dupx` | in | Pipe1 RF 读出 lch 有效 |
| `ctrl_xx_rf_pipe6_vmla_lch_vld_dupx` | in | Pipe6 vmla（向量乘加）lch 有效 |
| `ctrl_xx_rf_pipe7_vmla_lch_vld_dupx` | in | Pipe7 vmla lch 有效 |
| `dp_xx_rf_pipe0_dst_preg_dupx[6:0]` | in | Pipe0 RF 读出阶段目标 preg（用于 srcv2 匹配）|
| `dp_xx_rf_pipe6_dst_vreg_dupx[6:0]` | in | Pipe6 RF 读出阶段目标 vreg |

> **为什么需要多个流水阶段的广播？**  
> 各执行路径在不同接口阶段暴露"预计可用"、"可旁路"和"已写回"信息。`is_pipe_entry`
> 按物理寄存器号匹配这些广播，尽量在最终 PRF 写回前唤醒消费者，同时保留
> `rdy_clear`/launch-fail 清除路径。接口名能证明相对阶段，不能单独推导所有指令的
> 固定端到端延迟。

### 2.4 来自 RTU/ROB 的 IID 分配

| 端口 | 方向 | 说明 |
|------|------|------|
| `rtu_idu_rob_inst0_iid[6:0]` | in | ROB 为本批第 0 条指令分配的 IID |
| `rtu_idu_rob_inst1_iid[6:0]` | in | 第 1 条 |
| `rtu_idu_rob_inst2_iid[6:0]` | in | 第 2 条 |
| `rtu_idu_rob_inst3_iid[6:0]` | in | 第 3 条 |

### 2.5 来自控制路径的选择信号

| 端口 | 位宽 | 说明 |
|------|------|------|
| `ctrl_ir_pipedown` | 1 | IR→IS 流水推进使能（且未 stall）|
| `ctrl_ir_pipedown_gateclk` | 1 | 用于门控时钟的推进使能 |
| `ctrl_dp_is_dis_stall` | 1 | 分发暂停信号（来自 IS ctrl） |
| `ctrl_xx_is_inst0_sel[1:0]` | 2 | inst0 流水槽数据来源选择 |
| `ctrl_xx_is_inst_sel[2:0]` | 3 | inst1/2/3 流水槽数据来源选择 |
| `ctrl_dp_is_dis_aiq0_create0_sel[1:0]` | 2 | AIQ0 create0 从 inst0\~3 中选哪条 |
| `ctrl_dp_is_dis_aiq0_create1_sel[1:0]` | 2 | AIQ0 create1 选择 |
| `ctrl_dp_is_dis_aiq1_create0_sel[1:0]` | 2 | AIQ1 create0 选择 |
| ... 其余各队列 create0/1 sel 类似 | | |
| `ctrl_dp_is_dis_rob_create0_sel[1:0]` | 2 | ROB create0 聚合方式 |
| `ctrl_dp_is_dis_rob_create1_sel[2:0]` | 3 | ROB create1 聚合方式 |
| `ctrl_dp_is_dis_pst_create1_iid_sel` | 1 | inst1 IID 来源选择（复用 inst0 IID） |
| `ctrl_dp_is_dis_pst_create2_iid_sel[2:0]` | 3 | inst2 IID 来源 one-hot 选择 |
| `ctrl_dp_is_dis_pst_create3_iid_sel[2:0]` | 3 | inst3 IID 来源 one-hot 选择 |

### 2.6 主要输出端口

| 端口 | 位宽 | 说明 |
|------|------|------|
| `dp_aiq0_create0_data[226:0]` | 227 | AIQ0 create0 数据 |
| `dp_aiq0_create1_data[226:0]` | 227 | AIQ0 create1 数据 |
| `dp_aiq0_bypass_data[226:0]` | 227 | AIQ0 bypass（直通，源未就绪）数据 |
| `dp_aiq0_create_src0_rdy_for_bypass` | 1 | AIQ0 create0 src0 在 bypass 路径上就绪 |
| `dp_aiq0_create_div` | 1 | AIQ0 create0 是除法指令标志 |
| `dp_aiq1_create0_data[213:0]` | 214 | AIQ1 create0 数据 |
| `dp_lsiq_create0_data[162:0]` | 163 | LSIQ create0 数据 |
| `dp_lsiq_bypass_data[162:0]` | 163 | LSIQ bypass 数据 |
| `dp_viq0_create0_data[150:0]` | 151 | VIQ0 create0 数据 |
| `dp_sdiq_create0_data[26:0]` | 27 | SDIQ create0 数据 |
| `idu_rtu_rob_create0_data[39:0]` | 40 | ROB create0 数据 |
| `idu_rtu_pst_dis_inst0_preg[6:0]` | 7 | inst0 目标物理寄存器号（送 PST）|
| `idu_rtu_pst_dis_inst0_preg_iid[6:0]` | 7 | inst0 目标 preg 对应的 IID |
| `dp_aiq_dis_inst0_src0_preg[6:0]` | 7 | inst0 src0 物理寄存器号（AIQ 使用）|
| `idu_lsu_vmb_create0_vreg[5:0]` | 6 | VMB create0 目标向量寄存器 |

---

## 3. IS 流水级寄存器（`is_pipe_entry`）

### 3.1 实例化概览

`is_dp` 中实例化了 4 个相同的 `ct_idu_is_pipe_entry` 子模块，分别对应 4 路分发槽位：

```verilog
// 第 1917 行
ct_idu_is_pipe_entry  x_ct_idu_is_dp_inst0 ( ... );
// 第 1989 行
ct_idu_is_pipe_entry  x_ct_idu_is_dp_inst1 ( ... );
// 第 2061 行
ct_idu_is_pipe_entry  x_ct_idu_is_dp_inst2 ( ... );
// 第 2133 行
ct_idu_is_pipe_entry  x_ct_idu_is_dp_inst3 ( ... );
```

### 3.2 `is_pipe_entry` 内部结构

每个 `is_pipe_entry` 实例暂存一条指令的完整 IS 数据，并实时更新源操作数就绪状态。

#### 3.2.1 存储的指令信息（寄存器）

| 类型 | 字段 | 说明 |
|------|------|------|
| 操作码 | `entry_opcode[31:0]` | 32 位原始操作码 |
| 目标 | `entry_dst_preg[6:0]` | 目标物理整型寄存器 |
| | `entry_dst_vreg[6:0]` | 目标物理向量寄存器 |
| | `entry_dst_ereg[4:0]` | 目标物理 EREG；索引该操作产生的 `fflags` 等状态贡献版本 |
| | `entry_dst_vld` | 有整型目标寄存器 |
| | `entry_dstv_vld` | 有向量目标寄存器 |
| | `entry_dste_vld` | 有扩展目标寄存器 |
| 源 | `entry_src0_vld`/`entry_src1_vld`/`entry_src2_vld` | 整型源有效 |
| | `entry_srcv0_vld`/...vm | 向量源有效 |
| 控制 | `entry_alu`/`entry_lsu`/`entry_bju`/... | 执行单元类型标志 |
| | `entry_load`/`entry_store`/`entry_staddr` | 访存类型 |
| | `entry_mult`/`entry_div`/`entry_vmla`/... | 运算类型 |
| | `entry_split`/`entry_split_last`/`entry_split_num` | 向量拆分信息 |
| | `entry_bar`/`entry_bar_type[3:0]` | 屏障类型 |
| | `entry_vl[7:0]`/`entry_vsew[2:0]`/`entry_vlmul[1:0]` | 向量长度/元素宽度 |

#### 3.2.2 分层门控时钟设计

`is_pipe_entry` 针对不同字段生成独立的局部时钟请求，使只在特定指令类型中有意义的字段不必随每次 IS 槽更新：

```verilog
// 仅当 IS_DST_VLD=1（有目标寄存器）时，请求更新 preg 字段
assign create_preg_clk_en = x_create_gateclk_en && x_create_data[IS_DST_VLD];

// 仅当 IS_DSTV_VLD=1（有向量目标）时，请求更新 vreg 字段
assign create_vreg_clk_en = x_create_gateclk_en && x_create_data[IS_DSTV_VLD];

// 仅当 IS_DSTE_VLD=1 时，请求更新 ereg 字段
assign create_ereg_clk_en = x_create_gateclk_en && x_create_data[IS_DSTE_VLD];

// 仅当有 bar 或 expt 时，请求更新 bar_type/expt 等字段
assign create_other_clk_en = x_create_gateclk_en
                             && (x_create_data[IS_BAR] || x_create_data[IS_EXPT-6]);
```

> **准确边界**：上述 `*_clk_en` 是送入 `gated_clk_cell.local_en` 的局部请求，不等于物理时钟必然关闭或打开。公共门控模型的使能关系是
> `global_en && (module_en || local_en)`，扫描使能还可通过工艺 ICG 的 `TE` 打开时钟；未定义
> `C910_USE_TSMC28_ICG` 时，当前 RTL 模型直接令 `clk_out = clk_in`。因此 RTL 能证明的是字段更新条件被分组，
> 实际门控和功耗收益需要结合所用宏、综合网表与功耗分析确认。

#### 3.2.3 源操作数相关项子模块

每个 `is_pipe_entry` 内部进一步实例化依赖追踪子模块，每种源各一个：

| 子模块实例 | 类型 | 追踪对象 |
|-----------|------|---------|
| `x_ct_idu_is_pipe0_src0_entry` | `ct_idu_dep_reg_entry` | 整型 src0（preg）|
| `x_ct_idu_is_pipe0_src1_entry` | `ct_idu_dep_reg_entry` | 整型 src1（preg）|
| `x_ct_idu_is_pipe0_src2_entry` | `ct_idu_dep_reg_src2_entry` | 整型 src2（preg，扩展支持 MLA）|
| `x_ct_idu_is_pipe0_srcv0_entry` | `ct_idu_dep_vreg_entry` | 向量 srcv0（vreg）|
| `x_ct_idu_is_pipe0_srcv1_entry` | `ct_idu_dep_vreg_entry` | 向量 srcv1（vreg）|
| `x_ct_idu_is_pipe0_srcv2_entry` | `ct_idu_dep_vreg_srcv2_entry` | 向量 srcv2（vreg，扩展支持 VMLA）|
| `x_ct_idu_is_pipe0_srcvm_entry` | `ct_idu_dep_vreg_entry` | 向量掩码 srcvm（vreg）|

每个依赖追踪子模块接收全部执行单元的写回广播，并将匹配结果（就绪标志 + 操作数数据信息）输出到 `x_read_srcX_data` 总线，再由 `is_pipe_entry` 组装进 `x_read_data` 的相应字段。

#### 3.2.4 `x_read_data` 总线的数据来源

```
x_read_data[IS_SRC0_LSU_MATCH] = x_read_src0_data[11]   // src0 是否匹配 LSU 写回
x_read_data[IS_SRC0_BP_RDY:IS_SRC0_BP_RDY-10] = x_read_src0_data[10:0]  // src0 就绪位+WB 信息

x_read_data[IS_SRCV0_BP_RDY:...] = x_read_srcv0_data[10:0]  // 向量 src 类似
```

---

## 4. 分发指令数据组织（IS 数据字段布局）

IS 总线宽度为 271 位（`IS_WIDTH=271`），字段从高位到低位排列：

```
IS_WIDTH-1 = 270                                              0
+----------+---------+--------+------+------+------+----------+
|VL_PRED|VL| VMB/向量 | 控制位 | 源v  | 目标 | 源   | OPCODE  |
| 270-262  | 261-158 |257-200 |147-98|97-69 |68-36 | 35-0    |
+----------+---------+--------+------+------+------+----------+
```

以下列出重要字段的位位置（参数定义在第 1372–1477 行）：

| 参数名 | 位位置（MSB） | 说明 |
|--------|-------------|------|
| `IS_VL_PRED` | 270 | 向量长度预测有效 |
| `IS_VL` | 269 | 向量长度 VL（269:262，8 位）|
| `IS_LCH_PREG` | 261 | lch（latch）preg 标志 |
| `IS_VAMO` | 260 | 向量原子操作 |
| `IS_UNIT_STRIDE` | 259 | 单位步长访存 |
| `IS_VMB` | 258 | 向量内存缓冲标志 |
| `IS_VMLA_TYPE` | 245 | VMLA 类型（245:243）|
| `IS_SPLIT_NUM` | 242 | 向量拆分序号（242:236）|
| `IS_NO_SPEC` | 235 | 非投机执行 |
| `IS_ALU_SHORT` | 234 | ALU 短指令 |
| `IS_PIPE7` | 226 | 目标执行单元为 pipe7 |
| `IS_PIPE6` | 225 | 目标执行单元为 pipe6 |
| `IS_PIPE67` | 224 | pipe6 或 pipe7 |
| `IS_IID_PLUS` | 223 | IID 偏移（223:220，4 位，用于拆分指令）|
| `IS_BKPTB_INST` | 219 | 断点 B 指令 |
| `IS_BKPTA_INST` | 218 | 断点 A 指令 |
| `IS_EXPT` | 217 | 异常信息（217:211）|
| `IS_RTS` | 210 | 返回跳转 |
| `IS_SPECIAL` | 209 | 特殊指令 |
| `IS_LSU` | 208 | 访存指令 |
| `IS_DIV` | 207 | 除法 |
| `IS_MULT` | 206 | 乘法 |
| `IS_INTMASK` | 205 | 中断屏蔽 |
| `IS_SPLIT` | 204 | 拆分指令 |
| `IS_LENGTH` | 203 | 32 位指令（vs 16 位压缩）|
| `IS_PCFIFO` | 202 | PC FIFO 使用 |
| `IS_PCALL` | 201 | 函数调用 |
| `IS_BJU` | 200 | 分支跳转 |
| `IS_LSU_PC` | 199 | LSU PC 信息（199:185）|
| `IS_BAR_TYPE` | 184 | 屏障类型（184:181）|
| `IS_BAR` | 180 | 屏障指令 |
| `IS_STADDR` | 179 | store 地址操作 |
| `IS_STORE` | 178 | store 指令 |
| `IS_LOAD` | 177 | load 指令 |
| `IS_ALU` | 176 | ALU 指令 |
| `IS_DST_REL_EREG` | 175 | 目标释放 ereg（175:171）|
| `IS_DST_EREG` | 170 | 目标 ereg（170:166）|
| `IS_DST_REL_VREG` | 165 | 目标释放 vreg（165:159）|
| `IS_DST_VREG` | 158 | 目标 vreg（158:152，7 位）|
| `IS_DSTV_REG` | 151 | 向量目标 arch reg（151:147）|
| `IS_SRCVM_*` | 146–136 | 向量掩码源相关信息 |
| `IS_SRCV2_*` | 134–123 | 向量 src2 相关 |
| `IS_SRCV1_*` | 121–111 | 向量 src1 相关 |
| `IS_SRCV0_*` | 109–99 | 向量 src0 相关 |
| `IS_DSTE_VLD` | 97 | 有扩展目标寄存器 |
| `IS_DSTV_VLD` | 96 | 有向量目标寄存器 |
| `IS_SRCVM_VLD` | 95 | 有向量掩码源 |
| `IS_SRCV2_VLD` | 94 | 有向量 src2 |
| `IS_SRCV1_VLD` | 93 | 有向量 src1 |
| `IS_SRCV0_VLD` | 92 | 有向量 src0 |
| `IS_DST_REL_PREG` | 91 | 目标释放 preg（91:85）|
| `IS_DST_PREG` | 84 | 目标 preg（84:78，7 位）|
| `IS_DST_REG` | 77 | 目标 arch reg（77:73，5 位）|
| `IS_SRC2_LSU_MATCH` | 72 | src2 LSU match 标志 |
| `IS_SRC2_BP_RDY` | 71 | src2 bypass 就绪 |
| `IS_SRC2_PREG` | 68 | src2 物理寄存器（68:62，7 位）|
| `IS_SRC2_WB` | 61 | src2 WB 信息（61:55）|
| `IS_SRC1_LSU_MATCH` | 59 | src1 LSU match |
| `IS_SRC1_BP_RDY` | 58 | src1 bypass 就绪 |
| `IS_SRC1_PREG` | 56 | src1 物理寄存器（56:50，7 位）|
| `IS_SRC1_WB` | 49 | src1 WB 信息（49:43）|
| `IS_SRC0_LSU_MATCH` | 47 | src0 LSU match |
| `IS_SRC0_BP_RDY` | 46 | src0 bypass 就绪 |
| `IS_SRC0_PREG` | 44 | src0 物理寄存器（44:38，7 位）|
| `IS_SRC0_WB` | 37 | src0 WB 信息（37:31）|
| `IS_DST_VLD` | 35 | 有整型目标寄存器 |
| `IS_SRC2_VLD` | 34 | 有整型 src2 |
| `IS_SRC1_VLD` | 33 | 有整型 src1 |
| `IS_SRC0_VLD` | 32 | 有整型 src0 |
| `IS_OPCODE` | 31 | 操作码（31:0，32 位）|

> **注意**：`IS_SRC0_DATA` 和 `IS_SRC0_PREG` 值相同（均为 44），表示 SRC0 的数据字段即从 preg 开始，WB 位和就绪位紧跟其后。这是因为 dep_reg_entry 子模块内部将 preg+WB+RDY 打包为一个连续字段输出，`IS_SRC0_DATA` 是该区间的引用别名。

---

## 5. IR→IS 流水推进与移位 MUX

### 5.1 推进控制信号

```verilog
// 第 1832–1844 行
assign is_inst0_create_dp_en      = ctrl_ir_pipedown && !ctrl_dp_is_dis_stall;
assign is_inst1_create_dp_en      = ctrl_ir_pipedown && !ctrl_dp_is_dis_stall;
assign is_inst2_create_dp_en      = ctrl_ir_pipedown && !ctrl_dp_is_dis_stall;
assign is_inst3_create_dp_en      = ctrl_ir_pipedown && !ctrl_dp_is_dis_stall;
```

仅当 IR 级完成推进（`ctrl_ir_pipedown=1`）且分发未被暂停（`!ctrl_dp_is_dis_stall`）时，4 个 pipe entry 同时装载新数据。

### 5.2 移位 MUX（槽位对齐）

C910 支持不同路数的同时分发（1/2/3/4 条），并且允许分组聚合（如把 inst0+inst1 打包进 ROB 同一条目）。为适配这一需求，IS 阶段的 4 个流水槽在推进时会根据 `ctrl_xx_is_inst_sel` 进行**移位选择**：

```verilog
// inst0 的槽位（第 1855–1865 行）
case(ctrl_xx_is_inst0_sel[1:0])
  2'b01 : is_inst0_create_data = is_inst2_read_data;  // 从 inst2 槽移过来
  2'b10 : is_inst0_create_data = dp_ir_inst0_data;    // 来自 IR 阶段 inst0
endcase

// inst1/2/3 的槽位（第 1867–1910 行）
case(ctrl_xx_is_inst_sel[2:0])
  3'b001 : is_inst1_create_data = is_inst3_read_data;  // 从 inst3 移
  3'b010 : is_inst1_create_data = dp_ir_inst0_data;    // 来自 IR inst0
  3'b100 : is_inst1_create_data = dp_ir_inst1_data;    // 来自 IR inst1
endcase
```

**为什么要移位？** 当前周期仅分发了 2 条指令（inst0+inst1），IS 槽 inst2/inst3 中残留旧指令；下一周期 IR 推进新的 inst0, inst1 时，旧 inst2 需要"滑落"到 inst0 槽位，形成连续分发。这种动态槽位分配使分发带宽得到充分利用。

---

## 6. 各执行单元写回信号的接收与唤醒原理

### 6.1 唤醒的总体机制

C910 使用**分布式动态调度**：每条指令在进入发射队列前，其源操作数的就绪状态（`src_rdy`）已在 IS 阶段预计算并随指令数据一同写入队列。而对于仍在 IS 阶段等待的指令，`is_pipe_entry` 内部的 `dep_reg_entry` / `dep_vreg_entry` 子模块持续监测写回广播，在每个时钟周期更新就绪状态。

```
执行单元写回广播
     |
     +-->[ dep_reg_entry / dep_vreg_entry ]  <-- 比较写回 preg/vreg 是否 == 本指令的 src preg/vreg
             |
             | 就绪置位
             v
     is_pipe_entry.x_read_data[IS_SRCx_BP_RDY]
```

### 6.2 整型寄存器依赖追踪（preg）

`ct_idu_dep_reg_entry` 子模块接收以下写回广播并逐个比较：

| 写回来源 | 广播信号 | 说明 |
|---------|---------|------|
| Pipe0 ALU | `iu_idu_ex2_pipe0_wb_preg_vld_dupx` + `iu_idu_ex2_pipe0_wb_preg_dupx` | 2 拍 ALU 结果 |
| Pipe1 ALU | `iu_idu_ex2_pipe1_wb_preg_vld_dupx` + `iu_idu_ex2_pipe1_wb_preg_dupx` | |
| Pipe1 MUL | `iu_idu_ex2_pipe1_mult_inst_vld_dupx` + `iu_idu_ex2_pipe1_preg_dupx` | 乘法特殊路径 |
| DIV | `iu_idu_div_inst_vld` + `iu_idu_div_preg_dupx` | 变延迟除法 |
| LSU AG | `lsu_idu_ag_pipe3_load_inst_vld` + `lsu_idu_ag_pipe3_preg_dupx` | 推测早唤醒 |
| LSU DC | `lsu_idu_dc_pipe3_load_inst_vld_dupx` + `lsu_idu_dc_pipe3_preg_dupx` | DC 阶段确认 |
| LSU DC fwd | `lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx` + preg | load-to-use forward |
| LSU WB | `lsu_idu_wb_pipe3_wb_preg_vld_dupx` + `lsu_idu_wb_pipe3_wb_preg_dupx` | WB 阶段最终写回 |
| VFPU mfvr（pipe6）| `vfpu_idu_ex1_pipe6_mfvr_inst_vld_dupx` + `vfpu_idu_ex1_pipe6_preg_dupx` | 向量→整型移动结果 |
| VFPU mfvr（pipe7）| 同 pipe6 结构 | |

**每个源操作数**（src0/src1/src2）各自独立地与所有写回广播比较，只要有一路匹配（写回 preg == 该源的 preg 且写回有效），相应的就绪位立即置 1。

### 6.3 向量寄存器依赖追踪（vreg）

`ct_idu_dep_vreg_entry` 追踪 srcv0/srcv1/srcvm，`ct_idu_dep_vreg_srcv2_entry` 追踪 srcv2（额外支持 VMLA 的累加路径）。写回来源包括：

| 写回来源 | 说明 |
|---------|------|
| `lsu_idu_ag_pipe3_vload_inst_vld` | 向量 load AG 推测唤醒 |
| `lsu_idu_dc_pipe3_vload_inst_vld_dupx` | 向量 load DC 确认 |
| `lsu_idu_dc_pipe3_vload_fwd_inst_vld` | 向量 load forward |
| `lsu_idu_wb_pipe3_wb_vreg_vld_dupx` | 向量 load WB 写回 |
| `vfpu_idu_ex1_pipe6_data_vld_dupx`（EX1\~EX5）| VFPU pipe6 各阶段广播 |
| `vfpu_idu_ex1_pipe6_fmla_data_vld_dupx` | fmla（浮点乘加）专用路径 |
| `vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx` | VFPU pipe6 最终写回 |
| （pipe7 同结构）| |

对 srcv2，额外还处理 `ctrl_xx_rf_pipe6_vmla_lch_vld_dupx` 等 RF 读出阶段的信号，用于 vmla 操作数的提前就绪标记。

### 6.4 LSU 多阶段依赖跟踪的准确边界

load 的结果时刻会受 cache 命中、TLB、对齐、forward、replay 和下层存储返回影响，
不能在这里固定写成“L1 命中 3 拍”或把 AG/DC/WB 名称直接换算成绝对
`+1/+2/+3` 周期。`ct_idu_dep_reg_entry` 可确认的接口行为是：

```text
AG  load valid + preg 匹配
    -> 记录该源与在途 load 的匹配状态 lsu_match

DC  load valid / load_fwd valid + preg
    -> 在已记录匹配及相应资格条件下更新可调度状态

WB  wb valid + preg
    -> 把最终写回完成反映到 ready/wb 状态
```

其中 AG 事件是“目的号匹配/在途阶段广告”，不是 cache hit 证明；DC 的普通
load-valid 与 load-forward 也承担不同条件，不能统称为“命中确认后绝不撤销”。
消费者最终能否发射还要经过 entry freeze、队列年龄、执行端口和取消条件。
`IS_SRC*_LSU_MATCH` 在创建数据中携带与 load 在途关系有关的初始状态，entry
内部还会锁存后续 AG 匹配；它不是一位完整的“L1 hit/miss”结果。详细优先级见
[22_dep.md](22_dep.md) 的 `ct_idu_dep_reg_entry` 逐项说明。

---

## 7. 源操作数相关性检测（同组内指令间唤醒）

### 7.1 问题背景

同一 dispatch 组内（inst0\~inst3），后面的指令可能依赖前面指令的写回。例如 inst1 的 src0 依赖 inst0 的写回结果。由于 inst0 和 inst1 同一周期进入 IS 阶段，`dep_reg_entry` 尚无法通过写回广播感知到 inst0 的结果（inst0 还没执行），需要在入队时就记录这一依赖关系，并在 inst0 完成后通知 inst1 的队列条目可以发射。

### 7.2 src\_match 信号的含义

来自 IR 阶段的 `dp_ir_instXY_src_match[3:0]` 向量（由 `ct_idu_ir_dp` 生成）按位编码了 instX 的源是否与 instY 的目标寄存器重合：

| 位 | 含义（以 `dp_ir_inst01_src_match` 为例） |
|---|---|
| [0] | 较年轻 inst1 的整数 `src0` 最终依赖较老 inst0 的整数目的 |
| [1] | inst1 的整数 `src1` 最终依赖 inst0 的整数目的 |
| [2] | inst1 的整数 `src2`/目的旧值源最终依赖 inst0 的整数目的 |
| [3] | inst1 的标量浮点 `srcf2` 或向量接口 `srcv2` 依赖 inst0 的对应目的 |

`01` 的顺序是“生产者槽 0 → 消费者槽 1”，不是“inst0 的源匹配 inst1 的
目的”。bit[2:0] 直接来自整数 RT，bit[3] 是
`frt_dp_inst01_srcf2_match || vrt_dp_inst01_srcv2_match`。当前 VRT 为常量占位，
因此正常可观测的 bit[3] 主要还要结合 FRT 与实际构建配置解释。

### 7.3 is\_instXY\_src\_match 寄存器

这些 match 信号在 IR→IS 推进时锁存（第 2327–2353 行），以 `is_inst_clk` 驱动：

```verilog
// 第 2327–2353 行
always @(posedge is_inst_clk or negedge cpurst_b)
begin
  if(!cpurst_b) begin
    is_inst01_src_match <= 4'b0;
    ...
  end
  else if(is_inst_create_dp_en) begin
    is_inst01_src_match <= is_inst01_create_src_match;
    ...
  end
end
```

`is_inst01_create_src_match` 由一个移位 MUX 产生（第 2254–2298 行），根据 `ctrl_xx_is_inst_sel` 将当前周期 IR 的 match 向量或上一周期 IS 中的旧 match 向量映射到正确的槽位对组合。

### 7.4 lch\_rdy（Launch Ready）的生成

`lch_rdy` 表示"进入发射队列时，本指令的某个源操作数的就绪依赖于同批分发的另一条指令的某个队列条目"。这是一个**矩阵形式**的位图：

```
is_inst0_lch_rdy_aiq0[23:0]:  24 位 = 8 个 AIQ0 条目 × 3 位（src0/src1/src2）
```

以 inst0 依赖 AIQ0 create0 条目为例（第 3410–3418 行）：

```verilog
assign is_inst0_lch_rdy_aiq0_create0[23:0] =
  {is_inst0_aiq0_create0_src_match[2:0] & {3{ctrl_is_aiq0_create0_entry[7]}},
   is_inst0_aiq0_create0_src_match[2:0] & {3{ctrl_is_aiq0_create0_entry[6]}},
   ...
   is_inst0_aiq0_create0_src_match[2:0] & {3{ctrl_is_aiq0_create0_entry[0]}}};
```

**解读**：
- `ctrl_is_aiq0_create0_entry[7:0]` 是本周期 AIQ0 create0 条目的 one-hot 编码（哪个物理条目被使用）
- `is_inst0_aiq0_create0_src_match[2:0]` 是 inst0 对应的 src 匹配向量
- 两者按位与后展开，形成"inst0 的哪些源依赖于 AIQ0 的哪个条目"的完整位图

这个位图随指令数据写入发射队列，当 AIQ0 中那个条目的指令完成发射（或完成执行）后，可以据此"回点"地通知所有依赖于它的等待指令。

> **为什么需要这组位图？**
> 同包较年轻消费者创建时，较老生产者刚被分配到某个 IQ entry，尚无执行结果可
> 写回。`lch_rdy` 把“消费者的哪个源”与“生产者落入哪个队列 entry”在 dispatch
> 时绑定起来，使后续 launch 相关事件能按 entry 关系更新等待状态。它与 preg
> 写回广播是互补机制，不等于系统不再广播；位图自身也有面积、扇出和更新代价。
> WAW/WAR 主要由重命名消除，这里的核心问题是同包 RAW 生产者尚未出现在旧 RAT
> 稳态中的依赖表示，而不是靠位图去修复 WAW/WAR。

---

## 8. 发射就绪信号（lch\_rdy）的生成

为每条指令（inst0\~3）、每个发射队列（AIQ0/AIQ1/BIQ/LSIQ/SDIQ/VIQ0/VIQ1）分别计算 `lch_rdy`，步骤如下：

### 步骤 1：确定 src\_match 选择

根据目标队列的 create0/create1 选择信号，决定本指令依赖的是哪个"生产者指令对"：

```verilog
// inst0 对于 AIQ0 create0 的 src_match（第 3384–3392 行）
case(ctrl_dp_is_dis_aiq0_create0_sel[1:0])
  2'd0:   is_inst0_aiq0_create0_src_match = 3'b0;         // 无依赖
  2'd1:   is_inst0_aiq0_create0_src_match = is_inst01_src_match[2:0]; // 依赖 inst1
  2'd2:   is_inst0_aiq0_create0_src_match = is_inst02_src_match[2:0]; // 依赖 inst2
  2'd3:   is_inst0_aiq0_create0_src_match = is_inst03_src_match[2:0]; // 依赖 inst3
endcase
```

### 步骤 2：与条目号按位与展开

将 src\_match（3 位）与条目 one-hot 编号（8 位）做张量积，生成 24 位 lch\_rdy：

```
lch_rdy_aiq0[23:0] = entry[7] × {3 bits} | entry[6] × {3 bits} | ... | entry[0] × {3 bits}
```

### 步骤 3：OR 合并 create0 和 create1

```verilog
assign is_inst0_lch_rdy_aiq0 = is_inst0_lch_rdy_aiq0_create0 | is_inst0_lch_rdy_aiq0_create1;
```

同一周期可能有两条指令进入 AIQ0（create0 和 create1），inst0 可能依赖其中任一条或两条，取 OR 得最终 lch\_rdy。

### 8.1 各队列 lch\_rdy 宽度

| 队列 | lch\_rdy 宽度 | 说明 |
|------|-------------|------|
| AIQ0/AIQ1 | 24 位（8 条目 × 3 源）| 3 个整型源（src0/src1/src2）|
| BIQ | 24 位（12 条目 × 2 源）| 2 个整型源（BIQ 无 src2）|
| LSIQ | 24 位（12 条目 × 2 源）| |
| SDIQ | 12 位（12 条目 × 1 源）| 仅 src0 匹配 |
| VIQ0/VIQ1 | 8 位（8 条目 × 1 源）| 仅向量源（bit[3] 匹配）|

---

## 9. IID 分配与 PST 输出

### 9.1 IID 分配逻辑

ROB 为本批次最多 4 条指令分配连续的 IID（`rtu_idu_rob_inst0_iid`\~`rtu_idu_rob_inst3_iid`）。但由于分发数量可能少于 4 条，且某些指令可能是"空洞"（split 消费者共享生产者 IID），需要动态映射：

```verilog
// 第 2974–2985 行
assign is_inst0_iid = rtu_idu_rob_inst0_iid;

assign is_inst1_iid = (ctrl_dp_is_dis_pst_create1_iid_sel)
                     ? rtu_idu_rob_inst0_iid    // inst1 与 inst0 共用 IID（聚合场景）
                     : rtu_idu_rob_inst1_iid;

assign is_inst2_iid =
   {7{sel[0]}} & rtu_idu_rob_inst0_iid   // one-hot 选择
 | {7{sel[1]}} & rtu_idu_rob_inst1_iid
 | {7{sel[2]}} & rtu_idu_rob_inst2_iid;

assign is_inst3_iid =
   {7{sel[0]}} & rtu_idu_rob_inst1_iid
 | {7{sel[1]}} & rtu_idu_rob_inst2_iid
 | {7{sel[2]}} & rtu_idu_rob_inst3_iid;
```

**为什么 inst1 可能复用 inst0 的 IID？** 当 ROB 将 inst0 和 inst1 打包进同一条 ROB 条目（`rob_create0_sel=2'd1` 时包含 inst0+inst1），PST 只需为 inst0 分配 IID，inst1 共享 inst0 的 IID 即可，物理寄存器表项由 preg\_iid 标识。

### 9.2 IID 偏移（IID\_PLUS）

对于需要隐式目标的指令（如向量拆分指令，结果要写入 IID+N），增加 IID\_PLUS 偏移：

```verilog
// 第 3017–3024 行
assign dis_inst0_iid = is_inst0_iid + {3'b0, is_inst0_read_data[IS_IID_PLUS:IS_IID_PLUS-3]};
```

`IS_IID_PLUS` 字段（4 位）记录需要加的偏移量，0 表示无偏移。

### 9.3 PST 输出

向 PST（Physical Register State Table / 重命名表）写入：

```verilog
// 第 3027–3098 行
idu_rtu_pst_dis_inst0_preg_iid = {7{ctrl_dp_dis_inst0_preg_vld}} & dis_inst0_iid;
idu_rtu_pst_dis_inst0_preg    = is_inst0_read_data[IS_DST_PREG:IS_DST_PREG-6];
idu_rtu_pst_dis_inst0_rel_preg = is_inst0_read_data[IS_DST_REL_PREG:IS_DST_REL_PREG-6];
```

`ctrl_dp_dis_inst0_preg_vld` 为 0 时，对应 IID 掩零，避免无效写入（功耗优化）。

---

## 10. 向各发射队列输出分发数据（MUX 选择）

### 10.1 每个队列最多同时创建 2 个条目

C910 每拍最多向一个队列同时插入 2 条指令（create0 和 create1）。对应的 MUX 选择逻辑为：

```verilog
// AIQ0 create0 的指令选择（第 4680–4741 行）
case(ctrl_dp_is_dis_aiq0_create0_sel[1:0])
  2'd0: is_aiq0_create0_data = is_inst0_read_data; // inst0 写入 create0
  2'd1: is_aiq0_create0_data = is_inst1_read_data;
  2'd2: is_aiq0_create0_data = is_inst2_read_data;
  2'd3: is_aiq0_create0_data = is_inst3_read_data;
endcase
```

同时选择对应指令的 IID、PID（PCFIFO）、lch\_rdy 等附属信息。

### 10.2 格式转换（IS → 队列专有格式）

选出数据后，`is_dp` 将 IS 格式（271 位）重新打包为目标队列格式（以 AIQ0 为例，第 4837–4873 行）：

```verilog
assign dp_aiq0_create0_data = {AIQ0_WIDTH{ctrl_aiq0_create0_gateclk_en}} & aiq0_create0_data;

// 字段映射举例：
aiq0_create0_data[AIQ0_IID:AIQ0_IID-6]   = is_aiq0_create0_iid[6:0];
aiq0_create0_data[AIQ0_DST_PREG:...]     = is_aiq0_create0_data[IS_DST_PREG:...];
aiq0_create0_data[AIQ0_SRC0_PREG:...]    = is_aiq0_create0_data[IS_SRC0_DATA:...];
aiq0_create0_data[AIQ0_LCH_RDY_AIQ0:...] = is_aiq0_create0_lch_rdy_aiq0[23:0];
```

> **数据掩码的精确含义**：`{AIQ0_WIDTH{ctrl_aiq0_create0_gateclk_en}} & aiq0_create0_data`
> 在使能为 0 时把输出逐位钳为 0，在使能为 1 时透传数据。这说明 RTL 的功能形式是“按位与掩码”，
> 不能据此断言综合网表中不存在 MUX，也不能仅凭源码定量断言时序或功耗一定更优；综合器可能按标准单元库、
> 约束和扇出选择等价实现。

### 10.3 bypass\_data 的作用

除 create0/create1 数据外，`is_dp` 还输出 `dp_aiqX_bypass_data`，即不经过队列存储而直接供发射使用的数据副本，其 `SRC_RDY` 字段全部清零（来不及计算就绪），发射队列用于处理**直通（bypass）**场景：

```verilog
// 第 4930–4941 行（AIQ0 bypass 数据）
assign dp_aiq0_bypass_data[AIQ0_SRC2_LSU_MATCH] = 1'b0;   // bypass 时不知道 LSU match
assign dp_aiq0_bypass_data[AIQ0_SRC2_RDY]       = 1'b0;   // 强制未就绪
assign dp_aiq0_bypass_data[AIQ0_SRC0_RDY]       = 1'b0;

// 配套的就绪信号由外部另路提供：
assign dp_aiq0_create_src0_rdy_for_bypass = is_aiq0_create0_data[IS_SRC0_BP_RDY];
```

### 10.4 各队列数据宽度与关键字段

#### AIQ0（整型执行单元 0，含除法）

| 字段 | 位范围 | 说明 |
|------|--------|------|
| VL | 226:219 | 向量长度 |
| LCH\_RDY\_AIQ0 | 127:104 | 同批依赖 AIQ0 队列的就绪位图（24 位）|
| LCH\_RDY\_AIQ1 | 151:128 | 同批依赖 AIQ1 的就绪位图 |
| LCH\_RDY\_BIQ | 175:152 | 同批依赖 BIQ 的就绪位图 |
| LCH\_RDY\_LSIQ | 199:176 | 同批依赖 LSIQ 的就绪位图 |
| LCH\_RDY\_SDIQ | 211:200 | 同批依赖 SDIQ 的就绪位图（12 位）|
| ALU\_SHORT | 103 | 短整数指令 |
| PID | 102:98 | PCFIFO ID |
| DIV | 95 | 除法指令标志 |
| SRC2/SRC1/SRC0 数据 | 含 preg/WB/RDY | 源操作数信息 |
| DST\_PREG | 50:44 | 目标 preg |
| IID | 38:32 | 指令 ID |
| OPCODE | 31:0 | 操作码 |

#### LSIQ（访存发射队列）

LSIQ 格式包含 LSU 特有字段：

| 字段 | 说明 |
|------|------|
| VMB | 向量内存缓冲关联 |
| SPLIT\_NUM | 向量拆分序号 |
| AGEVEC\_ALL | 年龄向量（用于 store-to-load forwarding 顺序保证）|
| ALREADY\_DA | 已完成地址计算 |
| NO\_SPEC | 非投机（不可推测执行）|
| SDIQ\_ENTRY | 对应的 SDIQ 条目号 |
| SRCVM\_RDY/VREG | 向量掩码源就绪和寄存器号 |

#### VIQ0/VIQ1（向量发射队列）

| 字段 | 说明 |
|------|------|
| LCH\_RDY\_VIQ0/VIQ1 | 8 位，向量条目间依赖 |
| VMLA\_TYPE/VMLA\_SHORT | VMLA 变体类型信息 |
| SPLIT\_NUM/SPLIT\_LAST | 向量拆分信息 |
| SRCV0/V1/V2/VM 数据 | 4 个向量源操作数 |
| DST\_EREG/VREG/PREG | 状态贡献 EREG、向量/浮点数据物理号、整数目标物理号；字段名相邻不表示三类数据共享寄存器文件 |

---

## 11. ROB 写入数据

ROB 最多同时接受 4 个条目写入（create0\~3）。其中 create0\~2 可以聚合多条指令（ROB 的一个条目可以代表多条指令），create3 固定仅代表 inst3：

```
create3: 固定 = inst3 （第 2940–2969 行，直接赋值）
create0: sel=0 → 仅 inst0；sel=1 → inst0+inst1；sel=2 → inst0+inst1+inst2
create1: sel=0 → 仅 inst1；sel=1 → inst1+inst2；sel=2 → inst1+inst2+inst3
create2: sel=0 → 仅 inst2；sel=1 → inst2+inst3
```

ROB 条目的 `ROB_INST_NUM` 字段记录包含几条指令（1/2/3），`ROB_PC_OFFSET` 记录最后一条指令相对于 ROB 条目起始 PC 的字节偏移，供提交时 PC 更新使用。

**累积标志**：对于聚合条目，某些标志（如 `FP_DIRTY`、`VEC_DIRTY`、`BKPTA/B_INST`）取各指令的 OR：

```verilog
// create0 sel=2（inst0+1+2）的示例
idu_rtu_rob_create0_data[ROB_FP_DIRTY]    = is_dis_inst012_fp_dirty;   // OR
idu_rtu_rob_create0_data[ROB_VEC_DIRTY]   = is_dis_inst012_vec_dirty;  // OR
idu_rtu_rob_create0_data[ROB_PC_OFFSET]   = is_dis_inst012_pc_offset;  // 累加
idu_rtu_rob_create0_data[ROB_INST_NUM]    = 2'd3;                       // 3 条
```

---

## 12. LSU VMB 创建数据

向量 load/store 指令进入发射队列的同时，需要在 VMB（向量内存缓冲）中预分配条目（用于跟踪向量操作的执行进度）：

```verilog
// VMB create0（第 3108–3185 行）
case(ctrl_dp_is_dis_vmb_create0_sel[1:0])
  2'd0: begin  // inst0
    idu_lsu_vmb_create0_vl        = is_inst0_read_data[IS_VL:IS_VL-7];
    idu_lsu_vmb_create0_vsew      = is_inst0_read_data[IS_VSEW-1:IS_VSEW-2];
    idu_lsu_vmb_create0_vreg      = is_inst0_read_data[IS_DST_VREG-1:IS_DST_VREG-6];
    idu_lsu_vmb_create0_split_num = is_inst0_read_data[IS_SPLIT_NUM:IS_SPLIT_NUM-6];
    idu_lsu_vmb_create0_unit_stride = is_inst0_read_data[IS_UNIT_STRIDE];
    idu_lsu_vmb_create0_vamo      = is_inst0_read_data[IS_VAMO];
    idu_lsu_vmb_create0_sdiq_entry = sdiq_dp_create0_entry[11:0];  // 关联的 SDIQ 条目
    idu_lsu_vmb_create0_dst_ready = !ctrl_sdiq_create0_dp_en;       // SDIQ 未创建时已就绪
  end
  ...
endcase
```

`dst_ready` 的逻辑：如果本指令未进入 SDIQ（即非 store 数据路径），则目标寄存器立即就绪；否则需要等待 SDIQ 中的写入完成。

---

## 13. PCFIFO PID 分配

分支跳转指令需要记录预测信息，使用 PCFIFO（PC FIFO）管理。每个需要 PCFIFO 的指令分配一个 PID（PCFIFO ID）：

```verilog
// inst1 的 PID 分配（第 3285–3287 行）
assign is_inst1_alloc_pid = (is_inst0_pcfifo)
                           ? iu_idu_pcfifo_dis_inst1_pid   // inst0 也用了 PCFIFO，inst1 用 pid1
                           : iu_idu_pcfifo_dis_inst0_pid;  // inst0 未用，inst1 复用 pid0
```

inst2 和 inst3 的分配逻辑类似，根据前面有多少条指令使用了 PCFIFO 来决定从 IU 提供的 PID 序列中取哪一个：

```verilog
// inst3 最多可能是第 3 个 PCFIFO 指令（第 3305–3325 行）
if(is_inst0_pcfifo && is_inst1_pcfifo && is_inst2_pcfifo)
    is_inst3_alloc_pid = iu_idu_pcfifo_dis_inst3_pid;
else if(any two of inst0/1/2 use pcfifo)
    is_inst3_alloc_pid = iu_idu_pcfifo_dis_inst2_pid;
...
```

最终 PID 掩零处理（不使用 PCFIFO 的指令 PID 清零）：

```verilog
// 第 3329–3332 行
assign is_inst0_pid = {5{is_inst0_pcfifo}} & is_inst0_alloc_pid;
```

---

## 14. 整体数据流总结

```
         IR 阶段（重命名完成）
              |
     dp_ir_inst[0-3]_data (271 位 × 4)
              |
         +----v----+  ctrl_ir_pipedown
         | shift   |  && !stall         is_instX_create_data
         | MUX     +-------------------->
         +---------+  ctrl_xx_is_inst_sel

              |
   +----------v---------+  +----------v---------+
   | is_pipe_entry inst0 |  | is_pipe_entry inst1 |  ...
   |                     |  |                     |
   | entry_opcode        |  |  entry_opcode        |
   | entry_dst_preg/vreg |  |  entry_dst_preg      |
   | entry_src0/1/2_*    |  |  entry_src0/1/2      |
   |   +dep_reg_entry    |  |   +dep_reg_entry      |
   |   +dep_vreg_entry   |  |   +dep_vreg_entry     |
   +------+------+-------+  +------+-----+----------+
          |      |                 |     |
          |      |   [唤醒信号广播]  |     |
          |      +<================+     |
          |   iu/lsu/vfpu 写回广播        |
          |                              |
          +-------> is_instX_read_data (271 bits)
                          |
            +-------------+-------------+
            |             |             |
   src_match 计算   IID 分配        lch_rdy 生成
            |         |                 |
            +----+----+----+------------+
                 |
          +---------+-------+--------+--------+
          |         |       |        |        |
        AIQ0/1    BIQ     LSIQ    SDIQ   VIQ0/1
         MUX      MUX      MUX     MUX     MUX
          |         |       |        |        |
        格式转换    格式转换  格式转换  格式转换   格式转换
          |         |       |        |        |
      dp_aiq0_   dp_biq_  dp_lsiq_ dp_sdiq_ dp_viq0_
      create0/1  create0/1 create0/1 create0/1 create0/1
      _data       _data     _data    _data    _data

同时输出：
  - idu_rtu_rob_create[0-3]_data     → ROB
  - idu_rtu_pst_dis_inst[0-3]_preg*  → PST
  - idu_lsu_vmb_create[0-1]_*        → LSU VMB
  - dp_aiq_dis_inst[0-3]_src[0-2]_preg → AIQ（源 preg 用于队列内唤醒比较）
```

### 关键设计要点回顾

| 机制 | 实现 | 意义 |
|------|------|------|
| 分级门控时钟 | 按字段类型生成局部更新请求 | 减少无关字段更新机会；物理门控与功耗效果取决于 ICG 宏和实现 |
| 多源依赖更新 | dep\_reg/vreg\_entry 分别比较所连接的执行、DC 和 WB 事件 | 在不同生产者可用点更新 `rdy/wb`；各 dep 变体的输入集合并不相同 |
| LSU load 依赖处理 | AG 生成 `lsu_match` 预匹配，DC 的 load/data-forward 条件参与 issue-ready 或 ready，WB 更新 write-back 状态 | 将预匹配、可供发射的数据条件和最终写回分开；三者不是同义的“三级完成广播” |
| 同组内 lch\_rdy | 分发时预计算生产者-消费者绑定 | 避免组内 WAW 误唤醒 |
| 移位 MUX | IS 槽位动态重排 | 支持 1\~4 路变宽分发 |
| ROB 条目聚合 | create0/1/2 各自可含多条指令 | 提升 ROB 利用率 |
| bypass\_data | 源就绪位清零的副本 | 支持快速 bypass 路径 |

---

**参考文件**

- RTL 主文件：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_dp.v`（6331 行）
- 流水槽实现：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_pipe_entry.v`（1315 行）
- 依赖追踪子模块：`ct_idu_dep_reg_entry.v`、`ct_idu_dep_vreg_entry.v`、`ct_idu_dep_reg_src2_entry.v`、`ct_idu_dep_vreg_srcv2_entry.v`
