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
12. [预测器与 I-Cache 接口](#12-预测器与-i-cache-接口)
13. [调试接口](#13-调试接口)
14. [门控时钟设计](#14-门控时钟设计)

---

## 1. 模块概述

### 1.1 职责

`ct_ifu_pcgen` 是 C910 处理器取指单元（IFU）的**程序计数器生成与前端改流控制模块**。它不只保存和推进 PC，还把一次控制流决定转换成预测器、I-Cache、MMU 以及各级流水寄存器所需的索引、请求、cancel 和 flush。它的核心职责是：

1. **每周期决定取指地址**：在 9 类改流地址来源与顺序推进之间仲裁，按优先级选出正确的 PC。
2. **维护 `if_pc` 寄存器**：保存当前 IF 流水级正在取指的 PC，在顺序执行、stall、控制流变化三种情况下分别处理。
3. **处理控制流变化（chgflw）**：汇聚分支纠错、异常、调试、重取等改流请求，
   选择目标并产生送往 IFU 各级的局部 cancel/flush 控制。它不负责一拍清除全核
   所有在途指令；IU、IDU、RTU 和 LSU 仍按各自的 cancel/flush 协议清理状态。
4. **生成时序提前量**：通过独立的 16 位 `pc_bus`、`_short` 信号和 bank 使能，提前驱动关键 SRAM 路径。
5. **Way Predict（路预测）**：为 2 路 I-Cache 选择要激活的 way；`2'b00` 触发 IF self-stall，单路选错则由 IP 级触发 reissue。
6. **生成 MMU 翻译请求**：重建完整虚地址，将地址翻译与 I-Cache 访问并行启动。
7. **协调 BTB、L0 BTB、BHT、I-Cache、SFP、refill 和 IPB**：提供索引、读请求、改流通知及优先级屏蔽信号。

从体系结构边界看，PCGEN **不负责**计算分支方向、分支目标或判断 I-Cache 命中；这些工作分别由 BHT/BTB/IP/IU 和 I-Cache 完成。PCGEN 的工作是选择“本拍采用哪个地址与控制事件”，并让所有前端结构对这个选择保持一致。

### 1.2 在 IFU 流水线中的位置

C910 IFU 流水线分为三级：

```
  pcgen → IF（取指）→ IP（预译码/分支预测）→ IB（指令缓冲）
   ↑         ↑              ↑                     ↑
 PC生成    ICache访问     分支解析              指令分发
```

`pcgen` 位于流水线**最前端**。它接收来自 IF、IP、IB 各级以及 IU、RTU、异常向量和 HAD 的改流请求，产生正确的下一拍 PC；与此同时，它为预测器和 I-Cache 提供提前索引，并产生各级 cancel/flush。这里的关键不是“始终向前加一个固定值”，而是让**地址选择、预测状态、Cache 请求和流水线有效位**在同一控制流事件下保持一致。

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

这些信号是模块正常工作的基础。`cp0_ifu_iwpe` 尤其值得注意：当它为 0 时，Way Predict 被禁用，输出恒为 `2'b11`，即同时使能 way 0 和 way 1。它是保证功能正确的非预测模式，不是 way-predict miss；真正的 miss 编码是 `2'b00`。

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
| `iu_ifu_chgflw_pc[62:0]` | input | 63 | IU（整数执行单元） | 分支预测失误恢复地址，保存架构 VA `[63:1]` |
| `iu_ifu_chgflw_vld` | input | 1 | IU | IU 控制流变更有效 |
| `addrgen_pcgen_pc[38:0]` | input | 39 | addrgen（地址生成） | 直接控制流 PC-relative 目标复算后的纠错 PC |
| `addrgen_pcgen_pcload` | input | 1 | addrgen | 复算目标与 IP 级记录目标不一致时的 PC 加载使能 |
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

注意 `iu_ifu_chgflw_pc` 是 63 位宽，而其他 PC 仅 39 位。两者都省略了架构地址中恒为 0 的最低位：`iu_ifu_chgflw_pc[62:0]` 对应架构 VA `[63:1]`，普通 `[38:0]` PC 对应架构地址 `[39:1]`。恢复字节地址时必须在右侧补 `1'b0`。

### 2.3 stall 与流水线控制端口

| 端口名 | 方向 | 说明 |
|--------|------|------|
| `ifctrl_pcgen_stall` | input | IF 级 stall，阻止 PC 推进 |
| `ifctrl_pcgen_stall_short` | input | IF 级 stall 的快速时序版本 |
| `ifctrl_pcgen_ins_icache_inv_done` | input | 指令 I-Cache invalidate 完成；在 Loop Buffer 非活跃时触发其 flush |
| `ipctrl_pcgen_if_stall` | input | IP 级引发的 IF stall |
| `ibctrl_pcgen_ip_stall` | input | IB 级引发的 IP stall |
| `lbuf_pcgen_active` | input | Loop Buffer 活跃标志；影响 I-Cache invalidate 后是否立即 flush Loop Buffer |
| `lbuf_pcgen_vld_mask` | input | Loop Buffer 对流水线有效位的屏蔽；参与 IF/IP pipe cancel |

### 2.4 Way Predict 相关输入

| 端口名 | 方向 | 说明 |
|--------|------|------|
| `ifctrl_pcgen_way_pred[1:0]` | input | IF 级 chgflw 的 way predict |
| `ipctrl_pcgen_chgflw_way_pred[1:0]` | input | IP 级 chgflw 的 way predict |
| `ipctrl_pcgen_reissue_way_pred[1:0]` | input | IP 级重发的 way predict |
| `ibctrl_pcgen_way_pred[1:0]` | input | IB 级的 way predict |
| `ipctrl_pcgen_inner_way_pred[1:0]` | input | IP 级返回的本 I-Cache line 实际 way 命中向量 |
| `ipctrl_pcgen_inner_way0` | input | IP 级 way 命中历史计数器饱和偏向 way 0 |
| `ipctrl_pcgen_inner_way1` | input | IP 级 way 命中历史计数器饱和偏向 way 1 |
| `ipctrl_pcgen_h0_vld` | input | IP 级 H0 有效；reissue 时指示 BHT 低位关联到前一个 16 字节块 |

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
| `ifu_rtu_cur_pc[38:0]` | output | 39 | HAD/异常向量强制加载的 PC 基准，送 RTU 重置其 `rob_cur_pc` |
| `ifu_rtu_cur_pc_load` | output | 1 | 上述 PC 基准加载有效信号 |
| `pcgen_ifctrl_cancel` | output | 1 | 冲刷 IF 级 |
| `pcgen_ifctrl_pipe_cancel` | output | 1 | 清除 IF→IP 流水寄存器有效位 |
| `pcgen_ifctrl_reissue` | output | 1 | HAD/向量/RTU 改流引起 IF 级重取 |
| `pcgen_ifctrl_way_pred[1:0]` | output | 2 | way predict 打拍后送 IF 控制 |
| `pcgen_ifctrl_way_pred_stall` | output | 1 | way predict 为 `2'b00` 的打拍 stall |
| `pcgen_ipctrl_cancel` | output | 1 | 冲刷 IP 级 |
| `pcgen_ipctrl_pipe_cancel` | output | 1 | 清除 IP→IB 流水寄存器有效位 |
| `pcgen_ibctrl_cancel` | output | 1 | 冲刷 IB 级 |
| `pcgen_ibctrl_ibuf_flush` | output | 1 | flush Instruction Buffer |
| `pcgen_ibctrl_lbuf_flush` | output | 1 | flush Loop Buffer |
| `pcgen_ibctrl_bju_chgflw` | output | 1 | 将 IU/BJU 改流单独通知 IB 控制 |
| `pcgen_addrgen_cancel` | output | 1 | 冲刷 addrgen 模块 |
| `pcgen_btb_index[9:0]` | output | 10 | BTB 索引（来自 pc_bus[12:3]） |
| `pcgen_bht_pcindex[9:0]` | output | 10 | BHT 索引（来自 pc_bus[12:3]） |
| `pcgen_sfp_pc[16:0]` | output | 17 | 送 SFP（Speculation Fail Predictor，推测失败预测器）的 PC 片段 |

BTB、L0 BTB、BHT 和 I-Cache 的其余专用输出较多，统一在第 12 节按目标模块和使用方式说明。

---

## 3. 参数与关键寄存器

### 3.1 PC_WIDTH 参数

```verilog
// 第 370 行
parameter PC_WIDTH = 40;
```

`PC_WIDTH = 40` 表示 PCGEN 的普通 PC 路径覆盖架构字节地址低 40 位。由于 RISC-V C 扩展下指令至少按 2 字节对齐，架构 `PC[0]` 恒为 0，RTL 只保存 `PC[39:1]`，因此 `if_pc` 的信号位宽是 39 位 `[38:0]`。

这不能简单解释成“IFU 只有 40 位物理地址”：`if_pc` 首先是送 MMU 翻译的虚拟 PC 低位，MMU 地址高位通常由 `if_pc[38]` 符号扩展，IU 改流时还可由 `if_pc_high_spe` 临时补齐架构 VA `[63:40]`。要特别注意：RTL 的 `if_pc[0]` 对应架构 `PC[1]`，它并不恒为 0。

### 3.2 关键寄存器一览

| 寄存器 | 宽度 | 作用 |
|--------|------|------|
| `if_pc[38:0]` | 39 位 | IF 级当前 PC，是 pcgen 的核心状态寄存器 |
| `if_pc_high_spe[23:0]` | 24 位 | 保存 IU 总线 `[62:39]`，对应架构 VA `[63:40]`，仅在 IU chgflw 后有效 |
| `if_pc_high_spe_vld` | 1 位 | `if_pc_high_spe` 是否有效的标志位 |
| `if_bht_pc[6:0]` | 7 位 | BHT 结果选择使用的 PC 低 7 位，IP reissue + H0 时可回退一个 16B 块 |
| `way_predict[1:0]` | 2 位 | 组合逻辑输出的当前拍 way predict |
| `way_pred_flop[1:0]` | 2 位 | way_predict 打一拍的寄存器版本，送下游使用 |
| `chgflw_way_pred[1:0]` | 2 位 | 控制流变更时的 way predict，组合逻辑 |
| `chgflw_way_pred_flop[1:0]` | 2 位 | 保存改流目标的 way 信息，供改流后同一 cache line 的后续块复用 |
| `pcgen_chgflw_flop` | 1 位 | pcgen_chgflw 打一拍，用于 way predict 逻辑 |
| `inner_way_pred[1:0]` | 2 位 | 顺序推进时的 I-Cache way 选择，来自实际命中路或近期命中路偏好 |
| `ifctrl_pcgen_stall_flop` | 1 位 | stall 打一拍，用于 way predict 的连续 stall 检测 |
| `dbg_dly_reg` | 1 位 | 调试模式进入信号的打拍，用于生成单次 dbg_cancel 脉冲 |
| `ifu_rtu_cur_pc[38:0]` | 39 位 | HAD/向量强制加载的 PC 基准（打拍后送 RTU） |
| `ifu_rtu_cur_pc_load` | 1 位 | 上述 PC 基准的加载有效信号 |
| `pc_bus[15:0]` | 16 位 | 专为 BTB/BHT/ICache 索引计算的 PC 组合输出，优先级与主 MUX 略有不同 |

---

## 4. PC 来源优先级 MUX

### 4.1 总体设计思路

CPU 在任何一拍都可能有多个"希望改变 PC"的请求同时到来。例如，调试器注入新 PC 的同时，流水线里的某条分支指令也完成了预测。此时必须有一个严格的优先级裁决，选择**最权威、最紧急**的来源。

优先级排序的基本原则是：
- **软件/硬件调试 > 异常 > 分支预测失误恢复 > 流水线内部的重取/预测跳转 > 顺序执行**
- 流水线中**越晚发现**的错误，优先级越高（IB > IP > IF），因为越晚发现意味着更多指令已经进入流水线，必须以更高优先级清空。

### 4.2 主 MUX（ifpc_chgflw_pre）

这是 `pcgen_chgflw=1` 时更新 `if_pc` 所使用的改流地址 MUX，覆盖完整的 39 位内部半字地址，即架构字节地址 `[39:1]`。无改流时该 MUX 的输出不会被寄存器采用，顺序更新由独立的 `inc_pc` 路径完成：

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

### 4.3 十类改流事件逐一解析

| 优先级 | 来源信号 | 触发场景 | 为何是此优先级 |
|--------|----------|----------|----------------|
| 1（最高）| `had_ifu_pcload` | 调试器（JTAG/OpenOCD）通过 HAD 接口注入 PC，通常用于断点命中后单步执行或恢复运行 | 调试器对系统有最高控制权，必须能够覆盖任何硬件自身的控制流决定 |
| 2 | `vector_pcgen_pcload` | 发生异常或中断，跳转到异常向量（如 `mtvec` 指向的地址） | 异常处理仅次于调试，必须立即跳转，不能被分支预测结果覆盖 |
| 3 | `rtu_ifu_chgflw_vld` | RTU（退休单元）在指令精确退休时检测到需要恢复的 PC（如 trap 返回 `mret`、精确异常重启） | RTU 掌握"已提交"的精确状态，其给出的 PC 是最准确的恢复点，级别高于执行中的预测 |
| 4 | `iu_ifu_chgflw_vld` | IU 执行单元检测到分支预测失误，给出正确的跳转目标 | 执行单元已计算出真实目标地址，需要取消流水线中基于错误预测的所有取指 |
| 5 | `addrgen_pcgen_pcload` | ADDRGEN 在 IB 后一级复算预测 taken 条件分支或 JAL/C.J 的 PC-relative 目标；若复算目标与 IP 级记录的预测改流目标不一致，则改流到复算目标 | 这是较后一级对直接控制流目标的确定性校验，必须覆盖仍属投机性质的 IB/IP/IF 级预测 |
| 6 | `ibctrl_pcgen_pcload` | IB 级因 RAS 返回预测、间接 BTB、LBUF 循环回绕或 L0-BTB/RAS 纠错而改流 | 这些判断使用了比 IP/IF 更完整的指令边界和类型信息，因此覆盖更早阶段的预测 |
| 7 | `ipctrl_pcgen_reissue_pcload` | IP 级发现 I-Cache way prediction 不匹配，或在 refill 单元空闲时接受一次 miss/check-error refill 请求，于原 IP 级 VPC 重发 | 当前 IP 级数据不能直接沿用，重发优先于该级新产生的普通预测改流；它不是“refill 完成”事件 |
| 8 | `ipctrl_pcgen_chgflw_pcload` | IP 级 BTB 命中预测到分支跳转，提前改变控制流（投机跳转） | 纯粹的预测跳转，优先级低于重发，因为重发代表检测到错误，而预测跳转只是"可能正确" |
| 9 | `ifctrl_pcgen_chgflw_no_stall_mask` | IF 级 L0 BTB 命中，触发小范围的控制流变更（且当前没有 stall 遮蔽） | 最低层的预测机制，仅在没有任何更高优先级事件时才生效 |
| 10（最低）| `ifctrl_pcgen_reissue_pcload` | L1 refill 完成、I-Cache invalidate/read 完成，或 HAD/vector/RTU 高优先级改流经 IFCTRL 延迟一拍后，重发当前 IF PC | 该事件令 `pcgen_chgflw=1`，但不提供新地址；MUX 的最终 `else` 选择当前 `if_pc`。它承担真正的 refill 完成后重取 |

顺序推进不属于上述改流 MUX。只有当这 10 类 `pcgen_chgflw` 事件全为 0 且 IF 不 stall 时，`if_pc` 寄存器才从另一条数据路径加载 `inc_pc`。因此：

```text
有改流事件：if_pc_next = ifpc_chgflw_pre
无改流且可推进：if_pc_next = inc_pc
无改流且 stall：if_pc_next = if_pc
```

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
1. `pc_bus` 不包含 `had_ifu_pcload`、`vector_pcgen_pcload` 和 `rtu_ifu_chgflw_vld`。这三类高优先级事件另行产生 `pcgen_ifctrl_reissue`；当前拍先取消旧前端事务，随后由 IF reissue 流程基于已加载的 `if_pc` 重取，而不是把这三条宽地址路径接入快速 `pc_bus` MUX。
2. 因此，HAD/vector/RTU 改流发生的当拍，不能把 `pc_bus` 当成其目标 PC；观察这类事件应看 `ifpc_chgflw_pre`，并在下一拍看 `if_pc`。
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
    if_pc[38:0] <= inc_pc[38:0];      // 正常推进：到下一个 16 字节边界
  else
    if_pc[38:0] <= if_pc[38:0];       // stall：保持当前 PC
end
```

**复位（Reset）**：PC 清零（0x0），系统启动后由向量模块（`vector_pcgen_pcload`）重新加载正确的复位向量（如 MROM 入口地址）。

**控制流变更（pcgen_chgflw）**：这是最高优先级的更新路径。`pcgen_chgflw` 是 10 类改流事件的 OR；其中 IF reissue 不提供新目标地址，而是让主 MUX 保持 `if_pc`：

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
| `pcgen_chgflw` | 全部 10 类改流事件（含 IF reissue 和 L0 BTB） | 更新 `if_pc`，并通知 BTB/BHT/I-Cache/refill/IPB |
| `pcgen_chgflw_without_l0_btb` | 除 `ifctrl_pcgen_chgflw_vld` 外的 9 类事件 | 用于 IF cancel；L0 BTB 改流由 IF 级自身衔接，不取消同级 |
| `pcgen_chgflw_short` | `pcgen_chgflw_without_l0_btb` + `ifctrl_pcgen_chgflw_no_stall_mask` | 用于 BTB/BHT/I-Cache 的“短路径”控制 |

`ifctrl_pcgen_chgflw_vld` 是 IF 控制形成的完整改流有效信号，`ifctrl_pcgen_chgflw_no_stall_mask` 是去掉 stall 相关遮蔽后的快速条件。因而 `_short` 并不是功能上随意删减的近似值，而是给 SRAM 门控等关键路径使用的**时序版本**；最终状态更新仍以完整 `pcgen_chgflw` 为准。

### 5.3 为什么还要单独维护 `if_bht_pc`

BHT 不仅要知道取指块索引，还要用 PC 低位选择一个取指块内对应的预测结果。多数情况下，`if_bht_pc[6:0]` 与 `if_pc[6:0]` 同步更新；两者唯一关键差别出现在 IP reissue 且 `ipctrl_pcgen_h0_vld=1` 时：

```verilog
if (ipctrl_pcgen_reissue_pcload && ipctrl_pcgen_h0_vld)
  ifpc_bht_chgflw_pre[6:0] = {
      ipctrl_pcgen_reissue_pc[6:3] - 4'b1,
      ipctrl_pcgen_reissue_pc[2:0]
  };
else if (ipctrl_pcgen_reissue_pcload)
  ifpc_bht_chgflw_pre[6:0] = ipctrl_pcgen_reissue_pc[6:0];
```

这里的 `[6:3]` 是内部半字地址中的 16 字节块号低位。当 H0 有效时，H0 对应的信息来自前一个取指块，因此 BHT 用于结果选择的块号减 1；块内半字偏移 `[2:0]` 保持不变。主 `if_pc` 仍加载真实 reissue PC，只有 BHT 的低位关联信息做这个修正。

可以把两条路径理解为：

```text
if_pc     = 实际要重新取指的地址
if_bht_pc = 这批预测结果在 BHT 中应关联的取指块
```

如果观察波形时只看 `if_pc` 而忽略 `if_bht_pc`，就可能把跨 16 字节边界后的 BHT 结果误判为“错位一块”。

### 5.4 `pcgen_ifctrl_reissue`

```verilog
assign pcgen_ifctrl_reissue =
       had_ifu_pcload
    || vector_pcgen_pcload
    || rtu_ifu_chgflw_vld;
```

这不是主 PC MUX 的完整改流汇总，而是专门送给 IF 控制器的高优先级重取请求。IF 控制器把它与 refill 完成、I-Cache invalidate/read 完成等条件合并，形成 I-Cache reissue 流程。IU、IB、IP 的改流由各自的前端控制路径处理，因此不在这个三项汇总中。

---

## 6. inc_pc 计算

### 6.1 为什么不是简单的 +4

在普通的标量描述中，32 位指令的顺序 PC 常写作 `PC+4`。C910 前端一次处理 128 位，即 16 字节取指块；一个 64 字节 I-Cache line 包含 4 个这样的块。内部 `if_pc` 采用半字地址，因此：

- `if_pc[2:0]` 对应架构字节 PC `[3:1]`，表示 16 字节块内的 8 个半字位置；
- `if_pc[4:3]` 对应架构字节 PC `[5:4]`，表示 64 字节 cache line 内的 4 个取指块；
- 顺序推进应到达下一个 16 字节边界，而不是下一个 8 字节地址。

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
- `inc_pc_hi = if_pc[38:3] + 1`，即 16 字节块号加 1
- 低 3 位 `{3{0}} & if_pc[2:0] = 3'b000`，始终为 0
- 结果：架构字节 PC 前进到**下一个 16 字节边界**。仅当当前 PC 已位于块首时，内部数值才等于 `if_pc + 8`

**reissue（`ifctrl_pcgen_reissue_pcload == 1`）**：
- `inc_pc_hi = if_pc[38:3] + 0`，高位保持不变
- 低 3 位 `{3{1}} & if_pc[2:0] = if_pc[2:0]`，保持当前值
- 结果：**inc_pc = if_pc**（重发时 PC 不推进，重取同一块）

这个设计优雅地用一个条件信号控制了两种行为，避免了额外的 MUX 层。

**体系结构原理**：IFU 每拍处理一个 16 字节取指块。`seq_tag_req` 仅在内部 `pc_bus[4:3] == 2'b00` 时有效；这两位对应字节地址 `[5:4]`，所以条件表示到达 64 字节 cache line 的第一个取指块。一个 line 内依次处理地址 `+0/+16/+32/+48` 四个块，tag 只需在行首顺序请求时重新读取，从而降低 I-Cache 功耗。

---

## 7. if_pc_high_spe 的设计

### 7.1 问题背景：39 位 PC 与 64 位虚地址

C910 支持 64 位架构虚拟地址。IFU/MMU 接口省略恒为 0 的架构 `VA[0]`：总线 `[62:0]` 保存架构 VA `[63:1]`。IFU 内部大多数 PC 信号 `[38:0]` 则保存架构 VA `[39:1]`，通常通过内部 `if_pc[38]` 向高位符号扩展：

```
ifu_mmu_va[62:0] = { {24{if_pc[38]}}, if_pc[38:0] }  // 架构 VA[63:1]
byte_va[63:0]     = { ifu_mmu_va[62:0], 1'b0 }
```

这种设计适用于**内核空间**（高地址，bit[38]=1，扩展成全 1）和**低用户空间**（bit[38]=0，扩展成全 0）。在典型操作系统使用场景下，这两种情况覆盖了几乎所有正常的取指地址。

但有一个例外：**IU 分支预测失误恢复**时，IU 在
`iu_ifu_chgflw_pc[62:0]` 上给出架构 VA `[63:1]` 的全部 63 位。其总线高
24 位 `[62:39]`，即架构 VA `[63:40]`，不一定等于内部 `if_pc[38]` 的符号扩展；
完整字节地址仍需在最低位补 0。

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
    // IF reissue 或 PC 正常推进：特殊高位失效
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

以下事件会将 `if_pc_high_spe_vld` 清零，恢复“符号扩展”模式：
- `had_ifu_pcload`、`vector_pcgen_pcload`、`rtu_ifu_chgflw_vld`：更高优先级的 39 位 PC 来源接管。
- addrgen、IB、IP、IF 的改流或 reissue：这些接口只携带低 39 位内部 PC。
- IF reissue 或正常推进（`ifctrl_pcgen_reissue_pcload || !ifctrl_pcgen_stall`）：RTL 明确结束特殊高位状态。

只有 **stall** 时才保持 `if_pc_high_spe`，因为此时 IU 给出的目标仍停留在 IF 级，MMU 还需要看到完整高位。这个寄存器不是一条持续进行 64 位顺序加法的 PC 路径，而是 IU 改流目标进入 IF 时的临时高位补丁；一旦前端继续推进，地址重新按 `if_pc[38]` 符号扩展。该行为也使 MMU 能看到 IU 提供的完整异常高位目标，不能把 `if_pc` 单独当成完整 64 位 VA。

### 7.4 如何重建 MMU 地址与完整字节地址

这一重建逻辑在 MMU 接口处：

```verilog
// 第 881-884 行
assign ifu_mmu_va_high[23:0] = (if_pc_high_spe_vld)
                              ? if_pc_high_spe[23:0]     // IU chgflw 后：使用保存的高位
                              : {24{if_pc[38]}};          // 否则：符号扩展 bit[38]
assign ifu_mmu_va[62:0] = {ifu_mmu_va_high[23:0], if_pc[38:0]};
```

这里得到的是架构 VA `[63:1]`。若调试或分析需要普通字节地址，还应计算 `{ifu_mmu_va[62:0],1'b0}`。绝大多数情况下，高 24 位只是 `if_pc[38]` 的符号扩展；只有 IU 控制流变更后的特殊地址需要额外保存高位。

---

## 8. Way Predict 逻辑

### 8.1 为什么需要 Way Predict

C910 的 L1 I-Cache 是 **64KB、2 路组相联、64 字节 cache line**。其两个 data way 分别由 `ct_ifu_icache_data_array0/1` 实现。若每次取指都读两个 data way，功能正确但动态功耗较高；若能提前知道目标位于哪一路，就只需激活对应的数据阵列。

Way Predict 的实质是生成一个 2 位 way 使能向量。预测正确时只读一个 data way；无法可靠选择时可令两位均为 1，同时读取两路；若形成 `2'b00`，则当前没有 data way 可读，IF 级进入 self-stall。若输出 `01/10` 但 IP 级标签比较发现真正命中的是另一 way，IP 级产生 `way_mispred_reissue`，携带正确命中路重新取指。标签命中判断仍由 I-Cache/IP 侧完成，PCGEN 只选择 data way 的激活方式。

### 8.2 Way Predict 编码

`way_predict[1:0]` 的 4 种取值含义：

| 编码 | 含义 |
|------|------|
| `2'b00` | Way Predict **miss**（预测失效，无法确定在哪个 way，触发 stall） |
| `2'b01` | 预测在 **way 0** |
| `2'b10` | 预测在 **way 1** |
| `2'b11` | 同时使能 **way 0 和 way 1**，即非预测/全路读取模式 |

注意 `2'b11` 不是 miss，而是两路 data array 都可读的功能保底模式；`2'b00` 才会在下一拍置位 `pcgen_ifctrl_way_pred_stall`。

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

**级别 1：控制流变更时用 chgflw_way_pred**。chgflw 说明 PC 将跳到新地址；若发起改流的级已经携带目标地址的 way 信息，则沿改流一起使用，否则两路均打开。

**级别 2：stall 时保持**。stall 说明 IF 级没有在推进，下一拍还是同一个地址，way predict 也应保持。注意这里还检查了 `ifctrl_pcgen_stall_flop`（stall 打拍），这是因为 stall 解除后的第一拍，IF 可能仍在处理同一地址。

**级别 3：chgflw 后第一拍（chgflw_flop）且处于 cache line 内部**。内部 `inc_pc[4:3]` 对应架构字节地址 `[5:4]`。如果目标不在新 64 字节 cache line 的首个 16 字节块（`inc_pc[4:3] != 2'b00`），way predict 应来自 chgflw 时保存的 `chgflw_way_pred_flop`。

**级别 4（最低）：正常顺序取指用 inner_way_pred**。它来自 IP 级反馈的 I-Cache 实际命中路或近期命中路偏好，不是 BTB 的分支目标预测结果。

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

`inc_pc[4:3]` 表示即将处理的 16 字节取指块在 64 字节 cache line 中的位置（0~3），对应架构字节地址 `[5:4]`：

- 即将访问第 2、3 块时，当前 line 的标签比较已经完成，直接使用 `{icache_way1_hit, icache_way0_hit}`，同一 line 后续块无需重新猜测。
- 即将访问第 0、1 块时，尚缺少新 line 的精确命中路，使用 IP 级维护的 3 位饱和 `hit_cnt`。计数器饱和到 `000` 时偏向 way 0，饱和到 `111` 时偏向 way 1，中间状态则输出 `2'b11`，同时读两路。

因此，这里结合了“**同一 cache line 的已知命中路**”和“**跨 line 时的近期路偏好**”。它主要优化 I-Cache data array 功耗；预测错误造成的代价由 IP reissue 路径恢复。

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
- `pcgen_chgflw_without_l0_btb`：HAD、vector、RTU、IU、addrgen、IB、IP chgflw、IP reissue 和 IF reissue。L0 BTB 的 `ifctrl_pcgen_chgflw_vld` 是最早的 IF 级预测改流，由 IF 级自身衔接，不在这里触发同级 cancel。
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

这个信号直接控制 IF→IP 流水寄存器有效位，优先级高于下游 stall。除 `pcgen_ipctrl_cancel` 外，它还覆盖 Loop Buffer 有效屏蔽、IP check-error reissue，以及“IP 发出 chgflw 且当前没有要求 IF stall”的情况。也就是说，`cancel` 面向本级正在处理的事务，`pipe_cancel` 面向级间寄存器中的有效位，两者不能混为一个信号。

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

IP Cancel 只接受**高于 IP 级**的改流来源：HAD、vector、RTU、IU、addrgen 和 IB，再加 RTU 异常与调试进入。相比 IF Cancel，它不包含 IP 自己发出的 reissue/chgflw，也不包含 IF reissue。

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
- `addrgen_pcgen_pcload`：RTL 仅让它取消 IF/IP 和 addrgen，不扩展到 IB。其功能边界是保留 IB 已有状态，不能仅凭本模块进一步断言这些状态一定属于何种指令。

### 9.5 Cancel 信号汇总对比

| 来源 | IF Cancel | IP Cancel | IB Cancel |
|------|-----------|-----------|-----------|
| HAD pcload | ✓ | ✓ | ✓ |
| vector pcload | ✓ | ✓ | ✓ |
| RTU chgflw | ✓ | ✓ | ✓ |
| IU chgflw | ✓ | ✓ | ✓ |
| addrgen pcload | ✓ | ✓ | - |
| IB pcload | ✓ | ✓ | - |
| IP reissue | ✓ | - | - |
| IP chgflw | ✓ | - | - |
| IF reissue | ✓ | - | - |
| IF L0 BTB chgflw | - | - | - |
| rtu_expt_vld | ✓ | ✓ | ✓ |
| dbg_cancel | ✓ | ✓ | ✓ |

### 9.6 其他 cancel/flush 信号

```verilog
// 第 828-832 行（Addrgen Cancel）
assign pcgen_addrgen_cancel = had_ifu_pcload || vector_pcgen_pcload ||
                              rtu_ifu_chgflw_vld || iu_ifu_chgflw_vld ||
                              addrgen_pcgen_pcload;
```

`pcgen_addrgen_cancel` 的边界到 ADDRGEN 为止：HAD、vector、RTU、IU 的更高优先级
改流会丢弃当前地址生成事务；`addrgen_pcgen_pcload` 自身也被并入 cancel，使已经
发出的 ADDRGEN 纠错成为一次性事务，下一拍不会对同一记录重复改流。这里与
I-Cache refill 完成无关。

```verilog
// 第 836-847 行（ibuf/lbuf flush）
assign pcgen_ibctrl_lbuf_flush = had_ifu_pcload || vector_pcgen_pcload || 
    ifctrl_pcgen_ins_icache_inv_done && !lbuf_pcgen_active || 
    rtu_ifu_chgflw_vld || rtu_ifu_xx_expt_vld || dbg_cancel;
assign pcgen_ibctrl_ibuf_flush = had_ifu_pcload || vector_pcgen_pcload ||
    rtu_ifu_chgflw_vld || iu_ifu_chgflw_vld || rtu_ifu_xx_expt_vld || dbg_cancel;
```

`lbuf`（Loop Buffer）的 flush 还包含 `ifctrl_pcgen_ins_icache_inv_done && !lbuf_pcgen_active`，即 I-Cache 指令无效化完成且 Loop Buffer 当前不活跃时清空其旧内容。`iu_ifu_chgflw_vld` 不在 `lbuf_flush` 中，却在 `ibuf_flush` 中；这是 RTL 明确划定的不同恢复边界，不能把 IBUF 的 flush 条件直接套给 LBUF。

```verilog
assign pcgen_ibctrl_bju_chgflw = iu_ifu_chgflw_vld;
```

该信号把 IU/BJU 已确认的执行级改流单独通知 IB 控制器；在 `ct_ifu_ibctrl.v` 中它直接成为 `ibctrl_lbuf_bju_mispred`，专门告知 Loop Buffer 发生了执行级分支误预测。它与通用 `pcgen_ibctrl_cancel` 的用途不同。

此外，`pcgen_ipctrl_pipe_cancel` 用来清除 IP→IB 的级间有效位：

```verilog
assign pcgen_ipctrl_pipe_cancel =
       had_ifu_pcload
    || vector_pcgen_pcload
    || rtu_ifu_chgflw_vld
    || iu_ifu_chgflw_vld
    || addrgen_pcgen_pcload
    || rtu_ifu_xx_expt_vld
    || dbg_cancel
    || lbuf_pcgen_vld_mask
    || (ibctrl_pcgen_pcload && !ibctrl_pcgen_ip_stall);
```

最后一项体现了与 IF→IP 相同的原则：下游 IB 改流时，若 IP→IB 没有因 IB stall 而保持，就要显式清除正在写入的流水有效位。分析波形时应同时观察 `*_cancel`、`*_pipe_cancel`、对应 stall 和级间 valid；只看 cancel 容易漏掉“本级不取消、但级间 valid 被 kill”的情况。

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
- `vector_pcgen_reset_on`：向量/复位控制正在处理 reset，取消当前普通翻译事务

### 10.3 体系结构意义

`ifu_mmu_abort` 虽未逐项写出 IU、RTU、IB、IP reissue 等改流信号，但这些事件已经通过 `pcgen_ifctrl_cancel` **间接包含**。唯一有意排除的是 IF 级 L0 BTB 自身的改流：它不产生 IF cancel，因此也不由这条路径 abort MMU。读组合逻辑时要继续展开中间信号，不能因顶层表达式没有出现某个名字，就断言该事件不参与。

---

## 11. RTU 接口

### 11.1 这不是持续的“当前取指 PC”

信号名 `ifu_rtu_cur_pc` 容易让人误以为 PCGEN 每拍把 `if_pc` 送给 RTU。实际并非如此：它只在 HAD 强制加载 PC 或异常向量加载 PC 时产生一次基准 PC 更新。普通顺序取指、BTB 改流、分支预测失误和 refill 重取都不会直接加载该寄存器。

在 RTU 的 `ct_rtu_rob_rt.v` 中，`ifu_rtu_cur_pc_load` 会把该值写入 `rob_cur_pc_addend0` 并清零增量项。此后 ROB 随退休指令自身维护当前 PC。因此，这个接口的准确作用是：**当调试或向量入口从前端外部重置执行起点时，同步重置 RTU/ROB 的 PC 基准**。

### 11.2 实现细节

```verilog
// 第 894-940 行
assign rtu_cur_pc_load = had_ifu_pcload || vector_pcgen_pcload;
assign rtu_cur_pc = had_ifu_pcload ? had_ifu_pc : vector_pcgen_pc;
```

**关键设计点**：HAD 的优先级高于 vector；两者同时有效时选择 `had_ifu_pc`。输出保存的仍是省略架构 `PC[0]` 的内部半字地址 `[39:1]`。

`ifu_rtu_cur_pc` 和 `ifu_rtu_cur_pc_load` 都使用专用门控时钟 `rtu_pcload_clk` 打拍，避免时序违规，同时减少 RTU 侧的翻转功耗：

```verilog
// 第 918-939 行
assign rtu_pcload_clk_en = rtu_cur_pc_load || ifu_rtu_cur_pc_load;
```

`rtu_cur_pc_load` 让门控时钟打开并把输出 valid 置 1；若下一拍没有新加载，旧的 `ifu_rtu_cur_pc_load=1` 仍让时钟再开一拍，从而把输出 valid 清回 0。这里的“当前 OR 上一拍”是为了保证**事件结束后 valid 能够撤销**，不是为了满足普通寄存器保持时间；若上游连续保持 pcload，valid 也会连续保持。PC 数据在无新加载时保持不变。

---

## 12. 预测器与 I-Cache 接口

这一部分是 PCGEN 除“保存 PC”外最容易被忽略的功能。BTB、L0 BTB、BHT 和 I-Cache 都需要在 SRAM 访问开始前拿到地址与控制条件；若等 `if_pc` 在时钟沿更新后再逐级计算，关键路径会过长。因此 PCGEN 同时提供：

- **状态地址**：`if_pc`，表示当前 IF 级实际采用的内部半字 PC。
- **提前地址**：`pc_bus`，组合地产生下一次查询所需的低 16 位地址。
- **完整控制**：`pcgen_chgflw`、`ifctrl_pcgen_stall`，用于功能状态更新。
- **快速控制**：`pcgen_chgflw_short`、`ifctrl_pcgen_stall_short`，用于门控时钟和 SRAM 使能关键路径。
- **优先级限定**：`*_higher_than_*`、`*_mask`，防止低优先级预测事务覆盖高优先级改流。

PCGEN 只生成这些结构的**查询与控制输入**。BTB 是否命中、BHT 预测 taken/not-taken、L0 BTB 条目内容以及 I-Cache tag/data 命中，均在对应下游模块中完成。

### 12.1 BTB 接口

```verilog
assign pcgen_btb_index[9:0]   = pc_bus[12:3];
assign pcgen_btb_stall        = ifctrl_pcgen_stall;
assign pcgen_btb_stall_short  = ifctrl_pcgen_stall_short;
assign pcgen_btb_chgflw       = pcgen_chgflw;
assign pcgen_btb_chgflw_short = pcgen_chgflw_short;
```

`pcgen_btb_index=pc_bus[12:3]`。由于内部 PC 省略架构 `PC[0]`，它对应字节地址 `PC[13:4]`，即以 16 字节取指块为粒度形成 10 位 BTB 查询索引。`pc_bus` 默认取 `inc_pc`，所以正常顺序执行时 BTB 查询的是即将进入 IF 级的下一个取指块，而不是已经保存在 `if_pc` 中的块。

BTB 还接收三个“更高优先级改流”限定信号：

| 信号 | RTL 中包含的来源 | 含义 |
|------|------------------|------|
| `pcgen_btb_chgflw_higher_than_if` | HAD、vector、RTU、IU、addrgen、IB、IP chgflw、IP reissue、IF reissue | 当前存在比 IF L0 BTB 改流更高优先级的事件 |
| `pcgen_btb_chgflw_higher_than_ip` | HAD、vector、RTU、IU、addrgen、IB | 当前存在比 IP 级 BTB 结果更高优先级的事件 |
| `pcgen_btb_chgflw_higher_than_addrgen` | HAD、vector、RTU、IU | 当前存在比 addrgen 操作更高优先级的事件 |

这些信号不是新的预测结果，而是 BTB 内部更新、错误修正和流水状态机的**所有权屏蔽条件**。例如，IP 正在报告 way-predict error 时若同拍出现 IU 分支失误改流，BTB 应以 IU 恢复为准，不应让较低优先级的 IP 事务改变状态。观察波形时应把 `pcgen_btb_chgflw` 与相应 `higher_than_*` 一起看；只看到 `chgflw=1` 不能判断 BTB 最终采用了哪一级事务。

### 12.2 L0 BTB 接口

L0 BTB 是 IF 级的低延迟目标缓存。PCGEN 为它分别产生“发起查询”“屏蔽查询”和“查询地址”：

```verilog
assign pcgen_l0_btb_chgflw_vld =
       ifctrl_pcgen_chgflw_vld
    || ipctrl_pcgen_branch_taken
    || ibctrl_pcgen_pcload_vld
    || iu_ifu_chgflw_vld;

assign pcgen_l0_btb_chgflw_mask =
       had_ifu_pcload
    || vector_pcgen_pcload
    || rtu_ifu_chgflw_vld
    || addrgen_pcgen_pcload
    || iu_ifu_chgflw_vld
    || ipctrl_pcgen_branch_mistaken
    || ipctrl_pcgen_reissue_pcload
    || ifctrl_pcgen_reissue_pcload;
```

RTL 注释写“6 types”，但当前实际表达式有上述 **8 个信号**，分析应以综合的表达式为准。`chgflw_vld` 表示有一种值得对目标地址继续做快速 L0 BTB 查询的改流；`chgflw_mask` 表示同拍存在会让该查询失效或不应采用的恢复/重发条件。两者可能同时为 1，最终是否读表由 L0 BTB 内部结合判断。

低 15 位查询地址的优先级为：

```text
IB pcload
  > IP branch-taken target
  > IF no-stall chgflw target
  > inc_pc
```

对应 RTL 为：

```verilog
assign pcgen_l0_btb_chgflw_pc[14:0] =
    ibctrl_pcgen_pcload        ? ibctrl_pcgen_pc[14:0] :
    ipctrl_pcgen_branch_taken  ? ipctrl_pcgen_taken_pc[14:0] :
    ifctrl_pcgen_chgflw_no_stall_mask
                               ? ifctrl_pcgen_pcload_pc[14:0] :
                                 inc_pc[14:0];
```

`pcgen_l0_btb_chgflw_pc[14:0]` 对应架构字节地址 `[15:1]`；`pcgen_l0_btb_if_pc=if_pc` 则提供完整的当前 IF PC。前者是快速查询所需的低位，后者用于与当前取指上下文关联。这里再次体现“窄而快的提前路径”和“完整状态路径”并存。

### 12.3 BHT 接口

```verilog
assign pcgen_bht_pcindex[9:0] = pc_bus[12:3];
assign pcgen_bht_chgflw       = pcgen_chgflw;
assign pcgen_bht_chgflw_short = pcgen_chgflw_short;
assign pcgen_bht_seq_read     = if_pc[6] ^ inc_pc[6];
assign pcgen_bht_ifpc[6:0]    = if_bht_pc[6:0];
```

各信号承担不同角色：

| 信号 | 用途 |
|------|------|
| `pcgen_bht_pcindex` | BHT SRAM 查询索引；对应架构字节 PC `[13:4]` |
| `pcgen_bht_chgflw` | 改流时发起 BHT 相关读取 |
| `pcgen_bht_chgflw_short` | 为 BHT memory gate clock 提供快速使能 |
| `pcgen_bht_seq_read` | 顺序执行跨越 BHT Select Array 地址边界时发起下一行读取 |
| `pcgen_bht_ifpc` | 当前预测结果选择所需的 PC 低位，包含 H0 reissue 修正 |

`if_pc[6]` 对应架构字节地址 `PC[7]`。顺序推进时，`if_pc[6] ^ inc_pc[6]` 在跨越 128 字节边界时为 1。下游 `ct_ifu_bht` 的 Select Array 以 `pcgen_bht_pcindex[9:3]` 读行，因此这个脉冲用于在顺序执行跨到下一 Select Array 行时启动读取，而不是表示“发生了一条顺序分支”。

理解 BHT 波形时要分清两种 PC：

```text
pcgen_bht_pcindex <- pc_bus      ：决定读哪一组/哪一行
pcgen_bht_ifpc    <- if_bht_pc   ：决定如何从已读预测信息中选择结果
```

前者面向下一次 SRAM 查询，后者面向当前预测上下文；它们处在不同的时序角色，不要求每拍数值完全相同。

### 12.4 I-Cache 请求与索引

| 输出 | RTL 逻辑 | 作用 |
|------|----------|------|
| `pcgen_icache_if_index[15:0]` | `pc_bus[15:0]` | 提前提供 I-Cache 虚索引低位 |
| `pcgen_icache_if_way_pred[1:0]` | `way_predict[1:0]` | 选择读取 way 0、way 1、两路或暂不读 |
| `pcgen_icache_if_chgflw` | `pcgen_chgflw` | 改流访问请求 |
| `pcgen_icache_if_chgflw_short` | `pcgen_chgflw_short` | 改流请求的快速门控版本 |
| `pcgen_icache_if_seq_data_req` | `!ifctrl_pcgen_stall` | 非 stall 时进行顺序 data array 读取 |
| `pcgen_icache_if_seq_data_req_short` | `!ifctrl_pcgen_stall_short` | 顺序 data 请求的快速版本 |
| `pcgen_icache_if_seq_tag_req` | `!stall && pc_bus[4:3]==0` | 顺序进入 64B line 首个 16B 块时读 tag |
| `pcgen_icache_if_gateclk_en` | `chgflw_short \|\| !stall_short` | 改流或可顺序推进时打开 I-Cache 相关门控时钟 |

`pc_bus[4:3]` 对应架构字节地址 `[5:4]`，它在一个 64 字节 cache line 内依次取 `00/01/10/11`。因此顺序路径每个 16 字节块都可能请求 data，但只有进入 line 的第一个块时重新请求 tag。后续三个块复用已经得到的 tag/way 上下文，减少 tag array 动态功耗。

这组信号不是独立握手协议。I-Cache 内部还会将它们与 invalidate、refill、IPB 请求、CP0 I-Cache 使能和 way predict 等条件组合，最终形成各 SRAM 的低有效 `CEN`。例如 `seq_data_req=1` 只表示 PCGEN 允许顺序数据读取，不代表两个 data way、四个 bank 都一定实际打开。

### 12.5 I-Cache 四个 32 位 bank 的精确门控

每个 I-Cache data way 的 128 位取指数据由 4 个 32 位 bank 组成。IP 级预测分支落在一个 16 字节块中间时，目标之前的 bank 不包含有效目标路径指令，可以不读取：

| `ipctrl_pcgen_taken_pc[2:1]` | 架构字节块内位置 | 置位的 bank 改流请求 |
|-------------------------------|------------------|----------------------|
| `00` | `+0` 或 `+2` 字节所在 bank | bank 0、1、2、3 |
| `01` | `+4` 或 `+6` 字节所在 bank | bank 1、2、3 |
| `10` | `+8` 或 `+10` 字节所在 bank | bank 2、3 |
| `11` | `+12` 或 `+14` 字节所在 bank | bank 3 |

这里内部 `[2:1]` 对应架构字节地址 `[3:2]`；架构 `PC[1]` 允许压缩指令落在一个 32 位 bank 的前后半字，但不改变 bank 编号。

该裁剪路径只在 `ipctrl_pcgen_branch_taken && !chgflw_higher_than_btb` 时使用，其中当前 RTL 的：

```verilog
chgflw_higher_than_btb =
       iu_ifu_chgflw_vld
    || addrgen_pcgen_pcload
    || ibctrl_pcgen_pcload;
```

四个输出的实际判定可简化为：

```text
pcgen_icache_if_chgflw_bank0 = IP branch 特殊路径 ? (target_bank == 0) : pcgen_chgflw
pcgen_icache_if_chgflw_bank1 = IP branch 特殊路径 ? (target_bank <= 1) : pcgen_chgflw
pcgen_icache_if_chgflw_bank2 = IP branch 特殊路径 ? (target_bank <= 2) : pcgen_chgflw
pcgen_icache_if_chgflw_bank3 =                                      pcgen_chgflw

其中 IP branch 特殊路径 = ipctrl_pcgen_branch_taken && !chgflw_higher_than_btb
     target_bank           = ipctrl_pcgen_taken_pc[2:1]
```

否则四个 bank 都跟随完整 `pcgen_chgflw`。要注意，这个名字看似泛指“所有高于 BTB 的来源”，但表达式实际只有 IU、addrgen 和 IB 三项；不能仅凭信号名把 HAD、vector 或 RTU 自行补入解释。此处的同拍互斥关系还依赖上游控制协议，波形判断应以实际表达式和输入是否并发为准。

这类 bank gating 的主要收益是降低分支跳转时的 I-Cache 动态功耗，不会改变架构可见行为。若门控错误，典型波形表现是目标 PC 正确、tag/way 也正确，但目标所在的 32 位 bank 未使能，随后出现取指无效或 reissue。

### 12.6 SFP、refill 与 IPB

```verilog
assign pcgen_sfp_pc[16:0]     = if_pc[19:3];
assign pcgen_l1_refill_chgflw = pcgen_chgflw;
assign pcgen_ipb_chgflw       = pcgen_chgflw;
```

`pcgen_sfp_pc` 送往 SFP。根据 `ct_ifu_sfp.v` 中的 RTL 注释及其 no-spec hit/miss/mispred 更新接口，SFP 应理解为 **Speculation Fail Predictor（推测失败预测器）**；该模块还复用 PC 索引条目承载 barrier/no-spec 和 `vsetvli`/VL 预测信息，不应解释为 Store Filter Predictor。

`if_pc[19:3]` 对应架构字节 PC `[20:4]`，即舍弃 16 字节块内偏移后的 17 位 PC 特征。PCGEN 只提供索引片段，SFP 的命中比较、条目更新和预测语义都在 `ct_ifu_sfp.v` 中实现。

`pcgen_l1_refill_chgflw` 和 `pcgen_ipb_chgflw` 则把完整改流事件广播给 I-Cache refill 与 Instruction Prefetch Buffer，使旧路径上的在途 refill/prefetch 状态能够按各自规则取消、重定向或重新关联。PCGEN 不在这里直接清空它们，只通知“控制流已变”。

### 12.7 一次改流如何同时作用于前端

以 IU 发现分支预测失误为例，同一输入 `iu_ifu_chgflw_vld` 会在 PCGEN 中并行产生：

```text
主 PC MUX       -> 选择 iu_ifu_chgflw_pc
if_pc           -> 下一拍加载正确目标
pc_bus          -> 立即给出目标低位，提前索引 BTB/BHT/I-Cache
way_predict     -> 两路均使能，避免未知目标的 way 预测阻塞
IF/IP/IB cancel -> 清除错误路径前端状态
MMU abort       -> 经 IF cancel 取消旧地址翻译
BTB/BHT/I-Cache -> 收到 chgflw 与优先级限定
L0 BTB          -> chgflw_vld 与 mask 同时反映该恢复事件
refill/IPB      -> 收到改流广播
```

这正是 PCGEN 的体系结构定位：它不是分支执行单元，也不是缓存本体，而是把一个“正确 PC 已经确定”的事件，原子地翻译成整个取指前端一致的恢复动作。

---

## 13. 调试接口

### 13.1 dbg_cancel 生成

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

### 13.2 调试 PC 总线

```verilog
// 第 1069-1071 行
assign pcgen_debug_chgflw      = pcgen_chgflw;
assign pcgen_debug_pcbus[13:0] = pc_bus[13:0];
```

`pcgen_debug_pcbus` 取自提前路径 `pc_bus`，不是当前状态寄存器 `if_pc`。它保存内部半字地址低 14 位，对应架构字节 PC `[14:1]`；恢复可见的低位字节地址时要写成 `{pcgen_debug_pcbus, 1'b0}`。因此它适合观察“前端下一次正在索引哪里”，而不能单独当作完整当前 PC。`pcgen_debug_chgflw` 则说明该拍是否存在任一完整改流事件。

---

## 14. 门控时钟设计

### 14.1 门控时钟的目的

C910 是高性能处理器，在不需要翻转的触发器上关闭时钟可以显著降低动态功耗。`gated_clk_cell` 是平台提供的标准门控时钟单元。

### 14.2 pcgen 中的两个门控时钟

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

### 14.3 门控时钟的通用结构

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
- `module_en`（`cp0_ifu_icg_en`）：IFU 模块级时钟门控配置使能；本文件只使用该输入，是否以及如何由软件配置需以 CP0 寄存器实现为准
- `local_en`：具体时钟域的局部使能条件（各模块自定义）
- `pad_yy_icg_scan_en`：DFT 扫描使能，测试模式下强制打开所有门控时钟（确保扫描链完整）

---

## 附录：关键信号数据流总结

```text
HAD/vector/RTU/IU/addrgen/IB/IP/IF 改流地址
                   |
                   v
         ifpc_chgflw_pre（完整 39 位改流 MUX）
                   |
                   | pcgen_chgflw=1
                   v
              +----------+
inc_pc ------>|  if_pc   |<------ stall 时保持
无改流且推进  | 39 bit   |
              +----+-----+
                   |
          +--------+-------------------+
          |        |                   |
          v        v                   v
   IF ctrl/data   MMU VA 重建      SFP PC 特征
                   |
                   +--> if_pc_high_spe 仅补 IU 改流高位

IU/addrgen/IB/IP/IF 低位改流 + inc_pc
                   |
                   v
             pc_bus（快速 16 位 MUX）
                   |
          +--------+---------+----------------+
          |                  |                |
          v                  v                v
      BTB/BHT index     I-Cache index     debug pcbus

pcgen_chgflw / short / higher_than / mask
                   |
          +--------+---------+----------------+-------------+
          v                  v                v             v
      各级 cancel       BTB/L0 BTB/BHT     I-Cache      refill/IPB
      与 pipe kill       查询及屏蔽          请求/bank      改流通知
```

最后再次强调 PC 位号换算：

| RTL 信号位 | 对应架构字节地址位 | 典型用途 |
|------------|--------------------|----------|
| `if_pc[0]` | `PC[1]` | 16/32 位指令半字位置；并非恒为 0 |
| `if_pc[2:0]` | `PC[3:1]` | 16 字节取指块内半字偏移 |
| `if_pc[4:3]` | `PC[5:4]` | 64 字节 cache line 内的 4 个取指块 |
| `if_pc[6]` | `PC[7]` | BHT Select Array 顺序跨行检测 |
| `pc_bus[12:3]` | `PC[13:4]` | BTB/BHT 的 10 位提前索引 |
| `if_pc[19:3]` | `PC[20:4]` | SFP 的 17 位、16 字节粒度 PC 特征 |
