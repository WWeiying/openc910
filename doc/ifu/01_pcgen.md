# C910 IFU pcgen 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_pcgen.v`（1076 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [PC 来源优先级 MUX](#4-pc-来源优先级-mux)
5. [if_pc 寄存器更新逻辑](#5-if_pc-寄存器更新逻辑)
6. [inc_pc 计算](#6-inc_pc-计算)
7. [if_pc_high_spe 的设计](#7-if_pc_high_spe-的设计)
8. [Way Predict 逻辑](#8-way-predict-逻辑)
9. [Cancel 信号层次设计](#9-cancel-信号层次设计)
10. [MMU 接口](#10-mmu-接口)
11. [RTU 接口](#11-rtu-接口)
12. [调试接口](#12-调试接口)
13. [门控时钟设计](#13-门控时钟设计)

---

## 1. 模块概述

### 1.1 职责

`ct_ifu_pcgen` 是 C910 处理器取指单元（IFU）的**程序计数器生成模块**，也是整个取指流水线的起点与总控中枢。它的核心职责是：

1. **每周期决定下一个取指地址**：从 10 个可能来源中，按优先级选出正确的 PC，驱动 ICache 发起取指请求。
2. **维护 `if_pc` 寄存器**：保存当前 IF 流水级正在取指的 PC，在顺序执行、stall、控制流变化三种情况下分别处理。
3. **处理控制流变化（chgflw）**：检测所有可能导致控制流改变的事件（分支预测失误、异常、调试、重取等），产生 cancel 信号，冲刷流水线中已经在飞的指令。
4. **Way Predict（路预测）**：在访问 ICache 前，预测指令在 cache 哪条 way，避免串行标签比较，降低取指延迟。
5. **生成 MMU 翻译请求**：投机性地将虚地址发给 MMU，同步进行地址翻译和 cache 访问（两者并行）。
6. **向 BTB、BHT、L0 BTB 提供控制信号**：使分支预测结构在每个周期都能进行索引读取和更新。

### 1.2 在 IFU 流水线中的位置

C910 IFU 流水线分为三级：

```
  pcgen → IF（取指）→ IP（预译码/分支预测）→ IB（指令缓冲）
   ↑         ↑              ↑                     ↑
 PC生成    ICache访问     分支解析              指令分发
```

`pcgen` 位于流水线**最前端**，无论 ICache 是否命中、无论分支是否预测，它每周期都必须给出一个 PC，驱动后续流水级工作。它接收来自 IF、IP、IB 各级以及处理器核（IU/RTU）、调试器（HAD）的控制流变更请求，产生正确的下一拍 PC，同时产生各级的 cancel/flush 信号冲刷错误的指令。

---

## 2. 端口说明

端口按功能分为以下几组：

### 2.1 系统控制端口

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `forever_cpuclk` | input | 1 | 全局 CPU 时钟 |
| `cpurst_b` | input | 1 | 低有效复位信号 |
| `cp0_yy_clk_en` | input | 1 | 全局时钟使能（用于门控时钟） |
| `cp0_ifu_icg_en` | input | 1 | IFU 模块级门控时钟使能 |
| `pad_yy_icg_scan_en` | input | 1 | DFT 扫描模式下强制打开门控时钟 |
| `cp0_ifu_iwpe` | input | 1 | Way Predict 使能，来自 CP0 配置寄存器 |

这些信号是模块正常工作的基础。`cp0_ifu_iwpe` 尤其值得注意——当它为 0 时，Way Predict 被全部禁用（输出恒为 `2'b11`，表示 miss/bypass），这是软件可配置的特性。

### 2.2 来自核心各模块的 PC 加载端口（chgflw 来源）

| 端口名 | 方向 | 宽度 | 来源模块 | 语义 |
|--------|------|------|----------|------|
| `had_ifu_pc[38:0]` | input | 39 | HAD（硬件辅助调试） | 调试器注入的 PC |
| `had_ifu_pcload` | input | 1 | HAD | 调试 PC 加载使能 |
| `vector_pcgen_pc[38:0]` | input | 39 | 异常向量模块 | 异常/中断向量 PC |
| `vector_pcgen_pcload` | input | 1 | 异常向量模块 | 向量 PC 加载使能 |
| `vector_pcgen_reset_on` | input | 1 | 异常向量模块 | 复位处理中标志 |
| `rtu_ifu_chgflw_pc[38:0]` | input | 39 | RTU（退休单元） | 精确异常恢复 PC |
| `rtu_ifu_chgflw_vld` | input | 1 | RTU | 精确异常控制流变更有效 |
| `iu_ifu_chgflw_pc[62:0]` | input | 63 | IU（整数执行单元） | 分支预测失误恢复 PC（64位完整虚地址） |
| `iu_ifu_chgflw_vld` | input | 1 | IU | IU 控制流变更有效 |
| `addrgen_pcgen_pc[38:0]` | input | 39 | addrgen（地址生成） | L1 ICache refill 完成后重取 PC |
| `addrgen_pcgen_pcload` | input | 1 | addrgen | addrgen PC 加载使能 |
| `ibctrl_pcgen_pc[38:0]` | input | 39 | IB 控制（指令缓冲控制） | IB 级控制流变更 PC（如 RAS 预测） |
| `ibctrl_pcgen_pcload` | input | 1 | IB 控制 | IB 级 PC 加载有效 |
| `ibctrl_pcgen_pcload_vld` | input | 1 | IB 控制 | IB 级 pcload 有效（用于 L0 BTB） |
| `ipctrl_pcgen_reissue_pc[38:0]` | input | 39 | IP 控制 | IP 级重发 PC |
| `ipctrl_pcgen_reissue_pcload` | input | 1 | IP 控制 | IP 级重发有效 |
| `ipctrl_pcgen_chgflw_pc[38:0]` | input | 39 | IP 控制 | IP 级（BTB 预测跳转）PC |
| `ipctrl_pcgen_chgflw_pcload` | input | 1 | IP 控制 | IP 级控制流变更有效 |
| `ifctrl_pcgen_pcload_pc[38:0]` | input | 39 | IF 控制 | IF 级 L0 BTB 触发的新 PC |
| `ifctrl_pcgen_chgflw_vld` | input | 1 | IF 控制 | IF 级控制流变更有效 |
| `ifctrl_pcgen_reissue_pcload` | input | 1 | IF 控制 | IF 级重发有效 |
| `ifctrl_pcgen_chgflw_no_stall_mask` | input | 1 | IF 控制 | IF 级 chgflw（排除 stall 遮蔽后） |

注意 `iu_ifu_chgflw_pc` 是 63 位宽，而其他 PC 仅 39 位。这是因为 IU 执行时知道完整的 64 位虚地址（[62:0]，bit0 恒为 0），而 IFU 内部其他来源的 PC 已经是经过符号扩展处理的 39 位地址，高位用 bit[38] 符号扩展即可重建 64 位地址。

### 2.3 stall 与流水线控制端口

| 端口名 | 方向 | 说明 |
|--------|------|------|
| `ifctrl_pcgen_stall` | input | IF 级 stall，阻止 PC 推进 |
| `ifctrl_pcgen_stall_short` | input | IF 级 stall 的快速版本（提前半拍） |
| `ipctrl_pcgen_if_stall` | input | IP 级引发的 IF stall |
| `ibctrl_pcgen_ip_stall` | input | IB 级引发的 IP stall |
| `lbuf_pcgen_active` | input | L0 BTB 缓冲活跃中（影响 flush） |
| `lbuf_pcgen_vld_mask` | input | L0 BTB 有效遮蔽信号 |

### 2.4 Way Predict 相关输入

| 端口名 | 方向 | 说明 |
|--------|------|------|
| `ifctrl_pcgen_way_pred[1:0]` | input | IF 级 chgflw 的 way predict |
| `ipctrl_pcgen_chgflw_way_pred[1:0]` | input | IP 级 chgflw 的 way predict |
| `ipctrl_pcgen_reissue_way_pred[1:0]` | input | IP 级重发的 way predict |
| `ibctrl_pcgen_way_pred[1:0]` | input | IB 级的 way predict |
| `ipctrl_pcgen_inner_way_pred[1:0]` | input | IP 级顺序取指的 way predict（来自 BTB 查询结果） |
| `ipctrl_pcgen_inner_way0` | input | IP 级顺序取指 way0 命中标志 |
| `ipctrl_pcgen_inner_way1` | input | IP 级顺序取指 way1 命中标志 |
| `ipctrl_pcgen_h0_vld` | input | 当前 cache line 的 h0（第一个半字）有效（影响 BHT index 计算） |

### 2.5 分支信息输入

| 端口名 | 方向 | 说明 |
|--------|------|------|
| `ipctrl_pcgen_branch_taken` | input | IP 级预测分支跳转（用于 L0 BTB 和 icache bank 控制） |
| `ipctrl_pcgen_branch_mistaken` | input | IP 级分支预测失误（用于 L0 BTB mask） |
| `ipctrl_pcgen_taken_pc[38:0]` | input | IP 级预测跳转目标 PC |
| `ipctrl_pcgen_chk_err_reissue` | input | IP 级 check 错误触发重发 |
| `rtu_ifu_xx_expt_vld` | input | RTU 异常有效（特殊情况，直接触发 cancel，不等控制流变更） |
| `rtu_ifu_xx_dbgon` | input | 进入调试模式信号 |

### 2.6 主要输出端口

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `pcgen_ifctrl_pc[38:0]` | output | 39 | 当前 if_pc，送 IF 控制逻辑 |
| `pcgen_ifdp_pc[38:0]` | output | 39 | 当前 if_pc，送 IF 数据通路 |
| `pcgen_ifdp_inc_pc[38:0]` | output | 39 | 下一 PC（inc_pc），送 IF 数据通路用于指令地址计算 |
| `pcgen_ifdp_way_pred[1:0]` | output | 2 | way predict，送 IF 数据通路 |
| `pcgen_icache_if_index[15:0]` | output | 16 | ICache 索引地址（来自 pc_bus） |
| `pcgen_icache_if_way_pred[1:0]` | output | 2 | ICache way predict |
| `pcgen_icache_if_chgflw` | output | 1 | ICache 控制流变更 |
| `pcgen_icache_if_seq_data_req` | output | 1 | ICache 顺序数据请求（非 stall 时有效） |
| `pcgen_icache_if_seq_tag_req` | output | 1 | ICache tag 请求（仅 cache line 首个请求） |
| `ifu_mmu_va[62:0]` | output | 63 | 发给 MMU 的虚地址 |
| `ifu_mmu_va_vld` | output | 1 | 虚地址有效（恒为 1） |
| `ifu_mmu_abort` | output | 1 | 取消当前 MMU 翻译请求 |
| `ifu_rtu_cur_pc[38:0]` | output | 39 | 当前 PC，上报给 RTU |
| `ifu_rtu_cur_pc_load` | output | 1 | cur_pc 有效 |
| `pcgen_ifctrl_cancel` | output | 1 | 冲刷 IF 级 |
| `pcgen_ipctrl_cancel` | output | 1 | 冲刷 IP 级 |
| `pcgen_ibctrl_cancel` | output | 1 | 冲刷 IB 级 |
| `pcgen_addrgen_cancel` | output | 1 | 冲刷 addrgen 模块 |
| `pcgen_btb_index[9:0]` | output | 10 | BTB 索引（来自 pc_bus[12:3]） |
| `pcgen_bht_pcindex[9:0]` | output | 10 | BHT 索引（来自 pc_bus[12:3]） |
| `pcgen_sfp_pc[16:0]` | output | 17 | 送 SFP（Store Filter Predictor）的 PC 片段 |

---

## 3. 参数与关键寄存器

### 3.1 PC_WIDTH 参数

```verilog
// 第 370 行
parameter PC_WIDTH = 40;
```

`PC_WIDTH = 40` 意味着 PC 寄存器 `if_pc` 宽度为 40 位，但由于 RISC-V 指令地址必须 2 字节对齐（即最低位恒为 0），实际使用 `[PC_WIDTH-2:0]` 即 `[38:0]`，共 39 位有效地址位（代表 40 位物理地址空间）。

这一设计让地址空间达到 2^39 = 512 GB 的物理寻址范围。所有内部 PC 信号均为 39 位（`[38:0]`），最低位（bit 0）隐式为 0。

### 3.2 关键寄存器一览

| 寄存器 | 宽度 | 作用 |
|--------|------|------|
| `if_pc[38:0]` | 39 位 | IF 级当前 PC，是 pcgen 的核心状态寄存器 |
| `if_pc_high_spe[23:0]` | 24 位 | 虚地址高位补充寄存器（bit[62:39]），仅在 IU chgflw 后有效 |
| `if_pc_high_spe_vld` | 1 位 | `if_pc_high_spe` 是否有效的标志位 |
| `if_bht_pc[6:0]` | 7 位 | 专为 BHT 查询保存的 PC 低 7 位，与 `if_pc` 更新逻辑相同但 index 计算略有差异 |
| `way_predict[1:0]` | 2 位 | 组合逻辑输出的当前拍 way predict |
| `way_pred_flop[1:0]` | 2 位 | way_predict 打一拍的寄存器版本，送下游使用 |
| `chgflw_way_pred[1:0]` | 2 位 | 控制流变更时的 way predict，组合逻辑 |
| `chgflw_way_pred_flop[1:0]` | 2 位 | chgflw_way_pred 的寄存器版本（stall 后恢复用） |
| `pcgen_chgflw_flop` | 1 位 | pcgen_chgflw 打一拍，用于 way predict 逻辑 |
| `inner_way_pred[1:0]` | 2 位 | 顺序推进时的 way predict（来自 BTB 预测结果） |
| `ifctrl_pcgen_stall_flop` | 1 位 | stall 打一拍，用于 way predict 的连续 stall 检测 |
| `dbg_dly_reg` | 1 位 | 调试模式进入信号的打拍，用于生成单次 dbg_cancel 脉冲 |
| `ifu_rtu_cur_pc[38:0]` | 39 位 | 上报给 RTU 的当前 PC（打拍版本） |
| `ifu_rtu_cur_pc_load` | 1 位 | cur_pc 有效标志（打拍版本） |
| `pc_bus[15:0]` | 16 位 | 专为 BTB/BHT/ICache 索引计算的 PC 组合输出，优先级与主 MUX 略有不同 |

---

## 4. PC 来源优先级 MUX

### 4.1 总体设计思路

CPU 在任何一拍都可能有多个"希望改变 PC"的请求同时到来。例如，调试器注入新 PC 的同时，流水线里的某条分支指令也完成了预测。此时必须有一个严格的优先级裁决，选择**最权威、最紧急**的来源。

优先级排序的基本原则是：
- **软件/硬件调试 > 异常 > 分支预测失误恢复 > 流水线内部的重取/预测跳转 > 顺序执行**
- 流水线中**越晚发现**的错误，优先级越高（IB > IP > IF），因为越晚发现意味着更多指令已经进入流水线，必须以更高优先级清空。

### 4.2 主 MUX（ifpc_chgflw_pre）

这是更新 `if_pc` 寄存器时使用的 MUX，覆盖完整的 39 位地址：

```verilog
// 第 406-428 行
if(had_ifu_pcload)
  ifpc_chgflw_pre = had_ifu_pc;
else if(vector_pcgen_pcload)
  ifpc_chgflw_pre = vector_pcgen_pc;
else if(rtu_ifu_chgflw_vld)
  ifpc_chgflw_pre = rtu_ifu_chgflw_pc;
else if(iu_ifu_chgflw_vld)
  ifpc_chgflw_pre = iu_ifu_chgflw_pc[38:0];
else if(addrgen_pcgen_pcload)
  ifpc_chgflw_pre = addrgen_pcgen_pc;
else if(ibctrl_pcgen_pcload)
  ifpc_chgflw_pre = ibctrl_pcgen_pc;
else if(ipctrl_pcgen_reissue_pcload)
  ifpc_chgflw_pre = ipctrl_pcgen_reissue_pc;
else if(ipctrl_pcgen_chgflw_pcload)
  ifpc_chgflw_pre = ipctrl_pcgen_chgflw_pc;
else if(ifctrl_pcgen_chgflw_no_stall_mask)
  ifpc_chgflw_pre = ifctrl_pcgen_pcload_pc;
else // ifctrl_pcgen_reissue_pcload
  ifpc_chgflw_pre = if_pc;  // 保持当前 PC（顺序执行用 inc_pc）
```

### 4.3 十个来源逐一解析

| 优先级 | 来源信号 | 触发场景 | 为何是此优先级 |
|--------|----------|----------|----------------|
| 1（最高）| `had_ifu_pcload` | 调试器（JTAG/OpenOCD）通过 HAD 接口注入 PC，通常用于断点命中后单步执行或恢复运行 | 调试器对系统有最高控制权，必须能够覆盖任何硬件自身的控制流决定 |
| 2 | `vector_pcgen_pcload` | 发生异常或中断，跳转到异常向量（如 `mtvec` 指向的地址） | 异常处理仅次于调试，必须立即跳转，不能被分支预测结果覆盖 |
| 3 | `rtu_ifu_chgflw_vld` | RTU（退休单元）在指令精确退休时检测到需要恢复的 PC（如 trap 返回 `mret`、精确异常重启） | RTU 掌握"已提交"的精确状态，其给出的 PC 是最准确的恢复点，级别高于执行中的预测 |
| 4 | `iu_ifu_chgflw_vld` | IU 执行单元检测到分支预测失误，给出正确的跳转目标 | 执行单元已计算出真实目标地址，需要取消流水线中基于错误预测的所有取指 |
| 5 | `addrgen_pcgen_pcload` | L1 ICache miss 触发 refill，refill 完成后 addrgen 通知 pcgen 重新取指 | Cache miss 处理是特殊的流水线重启，需要高于 IFU 内部预测的优先级 |
| 6 | `ibctrl_pcgen_pcload` | IB 级（指令缓冲控制）触发控制流变更，典型场景是 RAS（Return Address Stack）预测的返回地址 | IB 级是最接近指令"派发"的一级，其控制流决策比 IP 级更靠近执行，优先级更高 |
| 7 | `ipctrl_pcgen_reissue_pcload` | IP 级（预译码/分支预测级）检测到需要重发（re-issue）的情况，例如 BTB 访问后发现预测有误需要重新取 | 重发（reissue）是已发现当前取指不合适，必须纠正，但优先级低于 IB 级的更"确定"的控制流变更 |
| 8 | `ipctrl_pcgen_chgflw_pcload` | IP 级 BTB 命中预测到分支跳转，提前改变控制流（投机跳转） | 纯粹的预测跳转，优先级低于重发，因为重发代表检测到错误，而预测跳转只是"可能正确" |
| 9 | `ifctrl_pcgen_chgflw_no_stall_mask` | IF 级 L0 BTB 命中，触发小范围的控制流变更（且当前没有 stall 遮蔽） | 最低层的预测机制，仅在没有任何更高优先级事件时才生效 |
| 10（最低）| 默认（`if_pc` 保持，使用 `inc_pc`） | 顺序执行，PC 按 cache line 宽度递增 | 无任何控制流变更事件时的默认行为 |

### 4.4 pc_bus MUX（用于索引 BTB/BHT/ICache）

`pc_bus` 是一个 16 位的独立 MUX，专门用于生成 BTB、BHT、ICache 的**索引地址**，其优先级与主 MUX 略有不同：

```verilog
// 第 445-458 行（简化）
if(iu_ifu_chgflw_vld)    pc_bus = iu_ifu_chgflw_pc[15:0];
else if(addrgen_pcgen_pcload) pc_bus = addrgen_pcgen_pc[15:0];
else if(ibctrl_pcgen_pcload)  pc_bus = ibctrl_pcgen_pc[15:0];
else if(ipctrl_pcgen_reissue_pcload)  pc_bus = ipctrl_pcgen_reissue_pc[15:0];
else if(ipctrl_pcgen_chgflw_pcload)   pc_bus = ipctrl_pcgen_chgflw_pc[15:0];
else if(ifctrl_pcgen_chgflw_no_stall_mask) pc_bus = ifctrl_pcgen_pcload_pc[15:0];
else                                  pc_bus = inc_pc[15:0];
```

注意与主 MUX 的几个关键差异：
1. `pc_bus` 不包含 `had_ifu_pcload` 和 `vector_pcgen_pcload`，因为调试跳转和异常向量跳转会同时触发各级 cancel，BTB/BHT 不需要提前索引新目标。
2. `pc_bus` 不包含 `rtu_ifu_chgflw_vld`，理由同上。
3. 没有高优先级事件时，`pc_bus` 使用 `inc_pc` 而非 `if_pc`，因为需要提前一拍给出下一周期的 cache 访问索引。

这种"双 MUX"设计的体系结构原因：主 MUX 追求正确性（覆盖所有来源），`pc_bus` 追求时序（只保留时序路径上关键的来源），两者配合使高频时序得以满足。

---

## 5. if_pc 寄存器更新逻辑

### 5.1 三态状态机

`if_pc` 是 pcgen 最核心的寄存器，每个时钟上升沿从以下三种情况中选择其一更新：

```verilog
// 第 484-494 行
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)
    if_pc[38:0] <= 39'b0;              // 复位：PC = 0（异常向量）
  else if(pcgen_chgflw)
    if_pc[38:0] <= ifpc_chgflw_pre;   // 控制流变更：跳到新 PC
  else if(!ifctrl_pcgen_stall)
    if_pc[38:0] <= inc_pc[38:0];      // 正常推进：PC += cache line 宽度
  else
    if_pc[38:0] <= if_pc[38:0];       // stall：保持当前 PC
end
```

**复位（Reset）**：PC 清零（0x0），系统启动后由向量模块（`vector_pcgen_pcload`）重新加载正确的复位向量（如 MROM 入口地址）。

**控制流变更（pcgen_chgflw）**：这是最高优先级的更新路径。`pcgen_chgflw` 是所有 10 个 PC 来源的 OR：

```verilog
// 第 599-608 行
assign pcgen_chgflw = had_ifu_pcload || 
                      vector_pcgen_pcload ||
                      rtu_ifu_chgflw_vld ||
                      iu_ifu_chgflw_vld ||
                      addrgen_pcgen_pcload ||
                      ibctrl_pcgen_pcload ||
                      ipctrl_pcgen_chgflw_pcload ||
                      ipctrl_pcgen_reissue_pcload ||
                      ifctrl_pcgen_reissue_pcload ||
                      ifctrl_pcgen_chgflw_vld;
```

一旦 `pcgen_chgflw` 为 1，`if_pc` 立即在下一拍更新到 `ifpc_chgflw_pre` 指定的目标，同时各级 cancel 信号冲刷流水线。

**顺序推进（!stall）**：当没有控制流变更且 IF 级不 stall 时，`if_pc` 更新为 `inc_pc`。这是常规的每拍向前推进。

**stall 保持**：当 `ifctrl_pcgen_stall` 为 1 时，保持 `if_pc` 不变。stall 可由 ICache miss、IP/IB 级背压等多种原因触发。

### 5.2 pcgen_chgflw 的变体

代码中存在三种 chgflw 变体，各有不同用途：

| 信号 | 包含来源 | 用途 |
|------|----------|------|
| `pcgen_chgflw` | 全部 10 个来源（含 L0 BTB） | 更新 `if_pc` 寄存器 |
| `pcgen_chgflw_without_l0_btb` | 前 9 个来源（不含 `ifctrl_pcgen_chgflw_vld`） | 用于 IF cancel 逻辑（L0 BTB 的 chgflw 不需要触发 IF cancel） |
| `pcgen_chgflw_short` | `pcgen_chgflw_without_l0_btb` + `ifctrl_pcgen_chgflw_no_stall_mask` | 用于 BTB/BHT/ICache 的"短路径"控制 |

`_short` 后缀的信号是 C910 时序优化的常见手法：在关键路径上使用"稍微不那么完整但时序更好"的版本，比完整版本早半拍到达需要它的模块，换取更高的工作频率。

---

## 6. inc_pc 计算

### 6.1 为什么不是简单的 +4

在普通的 RISC 处理器中，PC 每次递增 4（一条 32 位指令）。但 C910 的 pcgen 每次取指并不是取一条指令，而是取一整个 **cache line 对齐块**。以 ICache 的物理组织为例：

- ICache 每次取 64 字节（一个 cache line）
- 但 pcgen 的取指粒度是 **8 字节（一个 cache way 的最小寻址单元，即 3 位偏移对应 8 bytes）**

因此 inc_pc 的设计是：每次 PC 推进 **8 字节**（即 `if_pc[2:0]` 固定为 0，`if_pc[5:3]` 在 0~3 之间滚动，也就是每拍推进到下一个 8B 对齐块）。

### 6.2 inc_pc 的实现

```verilog
// 第 467-471 行
assign inc_pc_hi[35:0] = {if_pc[38:3]} + {35'b0, !ifctrl_pcgen_reissue_pcload};
assign inc_pc[38:0] = {
    inc_pc_hi[35:0],
    {3{ifctrl_pcgen_reissue_pcload}} & if_pc[2:0]
};
```

**正常推进（`ifctrl_pcgen_reissue_pcload == 0`）**：
- `inc_pc_hi = if_pc[38:3] + 1`，即高 36 位加 1（等效于 if_pc 加 8）
- 低 3 位 `{3{0}} & if_pc[2:0] = 3'b000`，始终为 0
- 结果：**inc_pc = if_pc + 8**（下一个 8B 对齐地址）

**reissue（`ifctrl_pcgen_reissue_pcload == 1`）**：
- `inc_pc_hi = if_pc[38:3] + 0`，高位保持不变
- 低 3 位 `{3{1}} & if_pc[2:0] = if_pc[2:0]`，保持当前值
- 结果：**inc_pc = if_pc**（重发时 PC 不推进，重取同一块）

这个设计优雅地用一个条件信号控制了两种行为，避免了额外的 MUX 层。

**体系结构原理**：IFU 每拍都向 ICache 发出一个 8B 对齐的取指请求，通过 `seq_tag_req`（仅在 `pc_bus[4:3] == 2'b00` 时有效，即每 4 个 8B 块的第一个才发 tag 请求）来控制 cache 行内的顺序访问。这允许 IFU 在一个 cache line 内连续取 4 个 8B 块（地址 +0/+8/+16/+24），只需第一次做 tag 比较，大幅降低了 ICache 的功耗。

---

## 7. if_pc_high_spe 的设计

### 7.1 问题背景：39 位 PC 与 64 位虚地址

C910 是支持 64 位虚地址的处理器（RV64GC）。完整的虚地址是 63 位（[62:0]，最低位为 0）。然而 IFU 内部大多数 PC 信号仅有 39 位（[38:0]），通过 bit[38] 的符号扩展可以重建 64 位地址：

```
VA[62:0] = { {24{if_pc[38]}}, if_pc[38:0] }
```

这种设计适用于**内核空间**（高地址，bit[38]=1，扩展成全 1）和**低用户空间**（bit[38]=0，扩展成全 0）。在典型操作系统使用场景下，这两种情况覆盖了几乎所有正常的取指地址。

但有一个例外：**IU 分支预测失误恢复**时，IU 给出的是完整的 64 位目标地址 `iu_ifu_chgflw_pc[62:0]`。这个地址可能是一个任意的 64 位值，高 24 位 `[62:39]` 不一定等于 bit[38] 的符号扩展。例如，跳转目标可能是某个非规范地址或特殊映射区域。

### 7.2 if_pc_high_spe 寄存器的作用

`if_pc_high_spe[23:0]` 用于保存 `iu_ifu_chgflw_pc[62:39]`（高 24 位），`if_pc_high_spe_vld` 标志其是否有效：

```verilog
// 第 501-531 行
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b) begin
    if_pc_high_spe <= 24'b0;
    if_pc_high_spe_vld <= 1'b0;
  end
  else if(had_ifu_pcload || vector_pcgen_pcload || rtu_ifu_chgflw_vld) begin
    // 调试/向量/RTU chgflw：清零（恢复符号扩展模式）
    if_pc_high_spe <= 24'b0;
    if_pc_high_spe_vld <= 1'b0;
  end
  else if(iu_ifu_chgflw_vld) begin
    // IU 分支失误恢复：保存高 24 位
    if_pc_high_spe <= iu_ifu_chgflw_pc[62:39];
    if_pc_high_spe_vld <= 1'b1;
  end
  else if(addrgen_pcgen_pcload || ibctrl_pcgen_pcload || ...) begin
    // 其他流水线内部 chgflw：清零
    if_pc_high_spe <= 24'b0;
    if_pc_high_spe_vld <= 1'b0;
  end
  else if (ifctrl_pcgen_reissue_pcload || !ifctrl_pcgen_stall) begin
    // PC 正常推进：清零（Inc PC 不会改变 bit[62:39] 的需求）
    if_pc_high_spe <= 24'b0;
    if_pc_high_spe_vld <= 1'b0;
  end
  else begin
    // stall：保持
    if_pc_high_spe <= if_pc_high_spe;
    if_pc_high_spe_vld <= if_pc_high_spe_vld;
  end
end
```

### 7.3 何时清零（失效）

以下事件会将 `if_pc_high_spe_vld` 清零，恢复"符号扩展"模式：
- `had_ifu_pcload`、`vector_pcgen_pcload`、`rtu_ifu_chgflw_vld`：更高优先级来源接管，新 PC 同样是 39 位（符号扩展有效）
- 任何流水线内部 chgflw（addrgen/ibctrl/ipctrl/ifctrl）：这些来源的 PC 也是 39 位，高位可以符号扩展
- PC 正常推进（`!ifctrl_pcgen_stall`）：`inc_pc` 仅操作低 39 位，结果同样是符号扩展有效的

只有 **stall** 时才保持 `if_pc_high_spe` 不变，因为 stall 期间 PC 不推进，`if_pc` 保持 IU 给出的那个地址不变，高 24 位依然需要保留。

### 7.4 如何重建完整 64 位虚地址

这一重建逻辑在 MMU 接口处：

```verilog
// 第 881-884 行
assign ifu_mmu_va_high[23:0] = (if_pc_high_spe_vld)
                              ? if_pc_high_spe[23:0]     // IU chgflw 后：使用保存的高位
                              : {24{if_pc[38]}};          // 否则：符号扩展 bit[38]
assign ifu_mmu_va[62:0] = {ifu_mmu_va_high[23:0], if_pc[38:0]};
```

**设计精髓**：绝大多数情况下，高 24 位只是 bit[38] 的符号扩展（无需额外存储），只有 IU 控制流变更后紧接着的若干拍可能需要非符号扩展的高位。使用一个 1 bit 的 valid 标志 + 24 bit 的数据寄存器，在极少数情况下保存完整信息，而通常情况下只占用这 25 个触发器，大大节省了面积。

---

## 8. Way Predict 逻辑

### 8.1 为什么需要 Way Predict

C910 的 ICache 是组相联结构（通常是 4-way 或 8-way）。在每次取指时，如果不做预测，ICache 需要同时读取所有 way 的数据，然后根据 tag 比较结果选择命中的 way，这会消耗大量功耗（无效读取）并增加延迟。

Way Predict 预先猜测指令在哪个 way，只激活那个 way 的读操作。如果预测正确，节省功耗；如果预测错误（way predict miss），触发重发。

### 8.2 Way Predict 编码

`way_predict[1:0]` 的 4 种取值含义：

| 编码 | 含义 |
|------|------|
| `2'b00` | Way Predict **miss**（预测失效，无法确定在哪个 way，触发 stall） |
| `2'b01` | 预测在 **way 0** |
| `2'b10` | 预测在 **way 1** |
| `2'b11` | **Bypass**（跳过 Way Predict，读取全部 way）|

注意 `2'b11` 是"绕过"模式，不是 miss，表示主动选择全 way 读取（功耗高但无延迟）。`2'b00` 才是真正的 miss，会触发 `pcgen_ifctrl_way_pred_stall`。

### 8.3 Way Predict 的 5 个优先级来源

```verilog
// 第 643-652 行
if(!cp0_ifu_iwpe)          // 0. Way Predict 全局禁用
  way_predict = 2'b11;     //    → bypass 模式
else if(pcgen_chgflw)      // 1. 控制流变更
  way_predict = chgflw_way_pred;
else if(ifctrl_pcgen_stall || ifctrl_pcgen_stall_flop)  // 2. stall 中
  way_predict = way_pred_flop;    // → 保持上一拍的值
else if(pcgen_chgflw_flop && !(inc_pc[4:3] == 2'b00))  // 3. chgflw 后第一拍且不在新 cache line 首
  way_predict = chgflw_way_pred_flop;
else                        // 4. 正常顺序推进
  way_predict = inner_way_pred;
```

**级别 0（最高优先）：禁用时全 bypass**。`cp0_ifu_iwpe = 0` 时 way predict 无效，直接 bypass，保证功能正确性牺牲功耗。

**级别 1：控制流变更时用 chgflw_way_pred**。chgflw 说明 PC 将跳到新地址，当前预测来自新目标地址对应的 BTB/cache 信息。

**级别 2：stall 时保持**。stall 说明 IF 级没有在推进，下一拍还是同一个地址，way predict 也应保持。注意这里还检查了 `ifctrl_pcgen_stall_flop`（stall 打拍），这是因为 stall 解除后的第一拍，IF 可能仍在处理同一地址。

**级别 3：chgflw 后第一拍（chgflw_flop）且处于 cache line 内部**。`pcgen_chgflw_flop` 表示上一拍发生了 chgflw，这一拍是 chgflw 的"第一个目标地址"。如果目标地址不在新 cache line 的首部（`inc_pc[4:3] != 2'b00`），那么 way predict 应来自 chgflw 时保存的 `chgflw_way_pred_flop`。

**级别 4（最低）：正常顺序取指用 inner_way_pred**。这来自 BTB 对下一个 cache 块的 way 预测结果。

### 8.4 chgflw_way_pred 来源的 5 个优先级

当发生控制流变更时，`chgflw_way_pred` 的来源也有多个，按以下优先级决策：

```verilog
// 第 687-697 行
if(pcgen_chgflw_higher_than_ib)  // 1. 高于 IB 级的 chgflw
  chgflw_way_pred = 2'b11;       //    → bypass（无法预测）
else if(ibctrl_pcgen_pcload)     // 2. IB 级
  chgflw_way_pred = ibctrl_pcgen_way_pred;
else if(ipctrl_pcgen_chgflw_pcload)  // 3. IP 级 chgflw
  chgflw_way_pred = ipctrl_pcgen_chgflw_way_pred;
else if(ipctrl_pcgen_reissue_pcload) // 4. IP 级重发
  chgflw_way_pred = ipctrl_pcgen_reissue_way_pred;
else                              // 5. IF 级
  chgflw_way_pred = ifctrl_pcgen_way_pred;
```

其中 `pcgen_chgflw_higher_than_ib` 包含：`had_ifu_pcload || vector_pcgen_pcload || rtu_ifu_chgflw_vld || iu_ifu_chgflw_vld || addrgen_pcgen_pcload`。这些来源跳转到完全未知的地址，无法事先知道 way，所以用 bypass（`2'b11`）。

### 8.5 inner_way_pred（顺序取指的 way predict）

```verilog
// 第 742-750 行
if(inc_pc[4:3] == 2'b10 || inc_pc[4:3] == 2'b11)
  inner_way_pred = ipctrl_pcgen_inner_way_pred;  // cache line 后半段
else
  inner_way_pred = inner_way_pred_default;

assign inner_way_pred_default = (ipctrl_pcgen_inner_way1 || ipctrl_pcgen_inner_way0)
                              ? {ipctrl_pcgen_inner_way1, ipctrl_pcgen_inner_way0}
                              : 2'b11;  // 两路都没有命中 → bypass
```

`inc_pc[4:3]` 表示即将取指的地址在 cache line 中的块位置（0~3）。当处于 cache line 的后半部分（块 2 或块 3，`[4:3] == 2'b10 or 11`），使用来自 IP 级 BTB 预测的 `inner_way_pred`（BTB 已经扫描了这个 cache line 里的分支，可能知道跳转目标 way）；否则使用 `inner_way_pred_default`（基于当前 cache line 的标签命中情况）。

### 8.6 Way Predict Stall 的触发

```verilog
// 第 757-762 行
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)
    pcgen_ifctrl_way_pred_stall <= 1'b0;
  else
    pcgen_ifctrl_way_pred_stall <= (way_predict[1:0] == 2'b00);
end
```

当 `way_predict` 为 `2'b00`（miss）时，下一拍 `pcgen_ifctrl_way_pred_stall` 置高，通知 IF 控制逻辑关闭 ICache 读取，直到重新获得有效的 way predict 信息。

---

## 9. Cancel 信号层次设计

### 9.1 三级 Cancel 的必要性

IFU 流水线有三个在飞的指令集：IF 级（正在取指）、IP 级（正在预译码）、IB 级（正在缓冲/等待派发）。当控制流改变时，需要根据具体情况决定冲刷哪些级：

- 较新的控制流变更（如 IU 分支失误）需要冲刷所有三级，因为这三级里都可能是错误路径的指令
- 较小的控制流调整（如 IP 级 BTB 预测跳转）只需要冲刷 IF 级，IP 级自身处理，IB 级不受影响

### 9.2 IF Cancel（pcgen_ifctrl_cancel）

```verilog
// 第 769-771 行
assign pcgen_ifctrl_cancel = pcgen_chgflw_without_l0_btb ||
                             rtu_ifu_xx_expt_vld || 
                             dbg_cancel;
```

IF Cancel 包含：
- `pcgen_chgflw_without_l0_btb`：除 L0 BTB 以外的所有 chgflw（L0 BTB 触发的 chgflw 是当前 cache line 内的短跳转，IF 级自身处理，无需 cancel）
- `rtu_ifu_xx_expt_vld`：RTU 检测到异常，必须立即 cancel IF 级正在取的指令
- `dbg_cancel`：进入调试模式时的单次脉冲 cancel

IF Cancel 触发 IF 级冲刷，让当前正在进行的取指作废。

**pcgen_ifctrl_pipe_cancel**（流水线级联 cancel）：

```verilog
// 第 779-783 行
assign pcgen_ifctrl_pipe_cancel = pcgen_ipctrl_cancel || 
                                  lbuf_pcgen_vld_mask ||
                                  ipctrl_pcgen_chk_err_reissue || 
                                  ipctrl_pcgen_chgflw_pcload && !ipctrl_pcgen_if_stall;
```

这个信号用于控制 IF→IP 流水线寄存器是否置无效（kill），优先级高于 `ip_if_stall`，专门处理 IP 级发生 chgflw 但 IP 级自身已经 stall 的边界情况。

### 9.3 IP Cancel（pcgen_ipctrl_cancel）

```verilog
// 第 796-803 行
assign pcgen_ipctrl_cancel = had_ifu_pcload || 
                             vector_pcgen_pcload ||
                             rtu_ifu_chgflw_vld ||
                             iu_ifu_chgflw_vld ||
                             addrgen_pcgen_pcload || 
                             ibctrl_pcgen_pcload ||
                             rtu_ifu_xx_expt_vld || 
                             dbg_cancel;
```

IP Cancel 比 IF Cancel **多了 IB 级来源**（`ibctrl_pcgen_pcload`），因为 IB 级 chgflw 需要同时冲刷 IP 级和 IF 级，而 IP 级本身发生的 chgflw 不需要 cancel 自己。

**注意**：`ipctrl_pcgen_chgflw_pcload` 和 `ipctrl_pcgen_reissue_pcload` 都**不**在 IP cancel 列表中，因为这些是 IP 级自己发出的控制流变更，IP 级自行处理，无需外部 cancel。

### 9.4 IB Cancel（pcgen_ibctrl_cancel）

```verilog
// 第 817-822 行
assign pcgen_ibctrl_cancel = had_ifu_pcload || 
                             vector_pcgen_pcload ||
                             rtu_ifu_chgflw_vld ||
                             iu_ifu_chgflw_vld ||
                             rtu_ifu_xx_expt_vld || 
                             dbg_cancel;
```

IB Cancel 比 IP Cancel **少了 `ibctrl_pcgen_pcload` 和 `addrgen_pcgen_pcload`**：
- `ibctrl_pcgen_pcload`：IB 级自己发出的，无需 cancel 自己
- `addrgen_pcgen_pcload`：L1 refill 完成的重取，IB 级中可能有正确路径上已经填充的指令（cache miss 期间 IB 可能已经有了部分数据），不应盲目冲刷

### 9.5 Cancel 信号汇总对比

| 来源 | IF Cancel | IP Cancel | IB Cancel |
|------|-----------|-----------|-----------|
| HAD pcload | ✓ | ✓ | ✓ |
| vector pcload | ✓ | ✓ | ✓ |
| RTU chgflw | ✓ | ✓ | ✓ |
| IU chgflw | ✓ | ✓ | ✓ |
| addrgen pcload | ✓ | ✓ | - |
| IB pcload | ✓ | ✓ | - |
| IP reissue | - | - | - |
| IP chgflw | - | - | - |
| IF chgflw | - | - | - |
| rtu_expt_vld | ✓ | ✓ | ✓ |
| dbg_cancel | ✓ | ✓ | ✓ |

### 9.6 其他 cancel/flush 信号

```verilog
// 第 828-832 行（Addrgen Cancel）
assign pcgen_addrgen_cancel = had_ifu_pcload || vector_pcgen_pcload ||
                              rtu_ifu_chgflw_vld || iu_ifu_chgflw_vld ||
                              addrgen_pcgen_pcload;
```

addrgen 自身完成时也 cancel 自己，防止重复 refill。

```verilog
// 第 836-847 行（ibuf/lbuf flush）
assign pcgen_ibctrl_lbuf_flush = had_ifu_pcload || vector_pcgen_pcload || 
    ifctrl_pcgen_ins_icache_inv_done && !lbuf_pcgen_active || 
    rtu_ifu_chgflw_vld || rtu_ifu_xx_expt_vld || dbg_cancel;
assign pcgen_ibctrl_ibuf_flush = had_ifu_pcload || vector_pcgen_pcload ||
    rtu_ifu_chgflw_vld || iu_ifu_chgflw_vld || rtu_ifu_xx_expt_vld || dbg_cancel;
```

`lbuf` (Loop Buffer) 的 flush 还额外包含 `ifctrl_pcgen_ins_icache_inv_done && !lbuf_pcgen_active`，这是 ICache invalidation（多核一致性操作）完成后需要清空 loop buffer 的场景。注意 `iu_ifu_chgflw_vld` 不在 lbuf_flush 中但在 ibuf_flush 中——这是因为注释说明 "IDU will deal with the condition of iu_chgflw"，loop buffer 有更细粒度的处理。

---

## 10. MMU 接口

### 10.1 投机性翻译原理

现代高性能处理器的地址翻译（虚地址 → 物理地址）通常与 cache 访问**并行**进行：

```
同一拍：
  ├─ 用虚地址低位（page offset）索引 ICache（低位不受翻译影响）
  └─ 将完整虚地址发给 MMU/TLB 进行翻译（得到物理地址高位）
下一拍：
  ├─ TLB 翻译完成，得到物理页号
  └─ ICache 读出候选行，用物理页号与标签比较，判断 hit/miss
```

这种"投机性"翻译允许 ICache 访问与 TLB 翻译在一拍内同时进行，是高频流水线处理器的标准实践。

### 10.2 MMU 接口实现

```verilog
// 第 881-889 行
assign ifu_mmu_va_high[23:0] = (if_pc_high_spe_vld)
                              ? if_pc_high_spe[23:0]
                              : {24{if_pc[38]}};
assign ifu_mmu_va[62:0] = {ifu_mmu_va_high[23:0], if_pc[38:0]};

assign ifu_mmu_abort  = pcgen_ifctrl_cancel || !cp0_yy_clk_en || vector_pcgen_reset_on;
assign ifu_mmu_va_vld = 1'b1;
```

**`ifu_mmu_va_vld` 恒为 1**：pcgen 每拍都持续向 MMU 发出翻译请求，无论是否真正需要新的翻译结果（MMU 自己根据 abort 决定是否响应）。这简化了握手逻辑。

**`ifu_mmu_abort`**：通知 MMU 当前这次翻译不需要结果（取消），触发条件：
- `pcgen_ifctrl_cancel`：IF 级被 cancel，当前取指作废，翻译结果无意义
- `!cp0_yy_clk_en`：全局时钟禁用（低功耗模式），MMU 也不工作
- `vector_pcgen_reset_on`：复位处理中，不进行正常翻译（复位向量通常直接走物理地址）

### 10.3 体系结构意义

注意 `ifu_mmu_abort` 不包含 `iu_ifu_chgflw_vld` 等 chgflw 信号——即使发生了控制流变更，当前这拍的翻译请求仍然有效（because `pcgen_ifctrl_cancel` 已经覆盖了大多数需要 abort 的场景）。这避免了不必要的 abort，让 MMU 有更多机会更新 TLB 状态。

---

## 11. RTU 接口

### 11.1 cur_pc 的用途

`ifu_rtu_cur_pc` 上报 IFU 当前 PC 给 RTU（Retire Unit，退休单元）。RTU 使用这个 PC 用于：
- 性能计数器（取指 PC 追踪）
- 调试状态同步
- 某些异常恢复场景

### 11.2 实现细节

```verilog
// 第 894-940 行
assign rtu_cur_pc_load = had_ifu_pcload || vector_pcgen_pcload;
assign rtu_cur_pc = had_ifu_pcload ? had_ifu_pc : vector_pcgen_pc;
```

**关键设计点**：`rtu_cur_pc_load` 仅在 `had_ifu_pcload` 或 `vector_pcgen_pcload` 时有效，即**只有调试器注入和异常向量跳转**才上报给 RTU。这两种情况是"外部强制改变 PC"，RTU 需要知道才能正确维护精确异常状态。其他控制流变更（如分支预测失误）由 IU 直接处理，不需要 IFU 重复上报。

`ifu_rtu_cur_pc` 和 `ifu_rtu_cur_pc_load` 都使用专用门控时钟 `rtu_pcload_clk` 打拍，避免时序违规，同时减少 RTU 侧的翻转功耗：

```verilog
// 第 918-939 行
assign rtu_pcload_clk_en = rtu_cur_pc_load || ifu_rtu_cur_pc_load;
// 时钟使能 = 当前拍要更新 OR 上一拍已更新（维持一拍有效）
```

这种"使能条件 = 当前 OR 上一拍"的门控时钟模式是数字电路中的经典写法，确保在数据有效的那一拍以及保持拍都有时钟翻转（满足寄存器建立和保持时间要求）。

---

## 12. 调试接口

### 12.1 dbg_cancel 生成

```verilog
// 第 867-876 行
assign dbg_dly_clk_en = rtu_ifu_xx_dbgon || dbg_dly_reg;

always @(posedge dbg_dly_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    dbg_dly_reg <= 1'b0;
  else
    dbg_dly_reg <= rtu_ifu_xx_dbgon;
end

assign dbg_cancel = !dbg_dly_reg && rtu_ifu_xx_dbgon;
```

`rtu_ifu_xx_dbgon` 是一个持续有效的电平信号（在调试模式期间一直为 1）。但 IFU 只需要在**进入调试模式的那一拍**产生一个 cancel 脉冲，而不是每拍都 cancel。

`dbg_cancel` 的逻辑是：`dbgon && !dbg_dly_reg`，即"当前 dbgon 有效，但上一拍还没有"，这就是标准的**上升沿检测**电路（edge detector）。`dbg_dly_reg` 是 `dbgon` 的 D 触发器，用专用门控时钟 `dbg_dly_clk` 驱动（使能条件 = `dbgon || dbg_dly_reg`，同样是"当前或上一拍有效"的模式）。

### 12.2 调试 PC 总线

```verilog
// 第 1069-1071 行
assign pcgen_debug_chgflw      = pcgen_chgflw;
assign pcgen_debug_pcbus[13:0] = pc_bus[13:0];
```

这两个信号送往调试接口模块，提供 PC 总线的可观测性（observability）。调试工具可以通过这些信号监控 IFU 的取指流程。

---

## 13. 门控时钟设计

### 13.1 门控时钟的目的

C910 是高性能处理器，在不需要翻转的触发器上关闭时钟可以显著降低动态功耗。`gated_clk_cell` 是平台提供的标准门控时钟单元。

### 13.2 pcgen 中的两个门控时钟

**调试延迟时钟（dbg_dly_clk）**：

```verilog
// 第 850-858 行
gated_clk_cell x_dbg_dly_clk (
  .clk_in             (forever_cpuclk),
  .clk_out            (dbg_dly_clk),
  .external_en        (1'b0),
  .global_en          (cp0_yy_clk_en),
  .local_en           (dbg_dly_clk_en),      // = rtu_ifu_xx_dbgon || dbg_dly_reg
  .module_en          (cp0_ifu_icg_en),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
```

仅在调试模式激活（或刚激活）时打开，驱动 `dbg_dly_reg` 的更新。非调试状态下完全关闭，省去 `dbg_dly_reg` 的无效翻转功耗。

**RTU PC 加载时钟（rtu_pcload_clk）**：

```verilog
// 第 901-909 行
gated_clk_cell x_rtu_pcload_clk (
  .clk_in             (forever_cpuclk),
  .clk_out            (rtu_pcload_clk),
  .external_en        (1'b0),
  .global_en          (cp0_yy_clk_en),
  .local_en           (rtu_pcload_clk_en),   // = rtu_cur_pc_load || ifu_rtu_cur_pc_load
  .module_en          (cp0_ifu_icg_en),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
```

仅在向 RTU 上报 PC（调试/异常向量跳转）时打开。绝大多数正常执行期间 `rtu_cur_pc_load = 0`，`rtu_pcload_clk` 关闭，`ifu_rtu_cur_pc` 和 `ifu_rtu_cur_pc_load` 这两个寄存器完全不翻转。

### 13.3 门控时钟的通用结构

```
        ┌──────────────────────────┐
        │   gated_clk_cell         │
clk_in ─┤                          ├─ clk_out
        │  enable = global_en      │
        │         & module_en      │
        │         & (local_en      │
        │            | scan_en)    │
        └──────────────────────────┘
```

- `global_en`（`cp0_yy_clk_en`）：全芯片级时钟使能，低功耗模式或 WFI 时关闭
- `module_en`（`cp0_ifu_icg_en`）：IFU 模块级时钟使能，软件可通过 CSR 控制
- `local_en`：具体时钟域的局部使能条件（各模块自定义）
- `pad_yy_icg_scan_en`：DFT 扫描使能，测试模式下强制打开所有门控时钟（确保扫描链完整）

---

## 附录：关键信号数据流总结

```
外部输入（HAD/RTU/IU/向量）
      ↓ 高优先级 chgflw
                                 ┌──────────────────────────┐
流水线内部（IB/IP/IF）           │                          │
      ↓ 低优先级 chgflw          │     ifpc_chgflw_pre      │
                                 │     (10路优先级 MUX)      │
      顺序推进 inc_pc ───────────┤                          │
                                 └────────────┬─────────────┘
                                              │ pcgen_chgflw
                                              ▼
                              ┌───────────────────────────────┐
                              │    if_pc 寄存器（39 bit）      │
                              │   chgflw → ifpc_chgflw_pre    │
                              │   !stall → inc_pc             │
                              │   stall  → if_pc              │
                              └───────────┬───────────────────┘
                                          │
              ┌───────────────────────────┼───────────────────────┐
              │                           │                       │
              ▼                           ▼                       ▼
     ifu_mmu_va（重建 63 位      pcgen_ifctrl_pc         pcgen_ifdp_pc
      结合 if_pc_high_spe）     pcgen_icache_if_index   pcgen_ifdp_inc_pc
                                pcgen_btb_index          pcgen_sfp_pc
                                pcgen_bht_pcindex
```

---

*文档覆盖 `ct_ifu_pcgen.v` 全部 1076 行逻辑，编写于 2026 年 6 月。*
