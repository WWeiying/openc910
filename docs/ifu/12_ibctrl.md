# C910 IFU ibctrl 模块详解

> 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ibctrl.v`（986 行）
>
> 本文档逐块讲解 ibctrl 的全部逻辑，每段均解释"为什么这么做"，读完后应能对 IB 级控制器有非常详细的了解。

---

## 目录

1. [模块概述](#1-模块概述)
2. [IBUF 与 LBUF 仲裁](#2-ibuf-与-lbuf-仲裁)
3. [Change Flow 决策](#3-change-flow-决策)
4. [Flush 与 Cancel 逻辑](#4-flush-与-cancel-逻辑)
5. [RAS Push/Pop 控制](#5-ras-pushpop-控制)
6. [Indirect BTB 状态机](#6-indirect-btb-状态机)
7. [向 pcgen 的输出汇总](#7-向-pcgen-的输出汇总)
8. [与 ibdp 的协作](#8-与-ibdp-的协作)
9. [Stall 传播](#9-stall-传播)

---

## 1. 模块概述

### 1.1 IB 级在 IFU 流水线中的位置

C910 IFU 内部是一条三级流水线：

```
PCGEN ──► IF 级 (ifctrl/ifdp) ──► IP 级 (ipctrl/ipdp) ──► IB 级 (ibctrl/ibdp)
                                                                    │
                                                          ┌─────────┴──────────┐
                                                          │                    │
                                                        IBUF               LBUF
                                                          │                    │
                                                          └─────────┬──────────┘
                                                                    │
                                                                   IDU
```

各级分工：

| 流水级 | 主要工作 |
|--------|----------|
| IF 级 | 发出 I-Cache 读请求，L0 BTB 预测下一 PC |
| IP 级 | 接收 I-Cache 返回数据，预解码（precode），L0 BTB 结果比较 |
| IB 级 | 最终分支解码，向 RAS/Ind-BTB 查询，决定 chgflw；把指令写入 IBUF/LBUF |

IB 级是 IFU 流水线的**最后一级**，也是距离 IDU 最近的一级。它的核心职责是：

1. **分发指令**：把从 IP 级流入的取指包（fetch bundle）写入 IBUF 或 LBUF；
2. **分支纠偏**：对 RAS 返回指令、间接跳转（JALR）、LBUF 分支做出 Change Flow（chgflw）决策，通知 pcgen 重新取指；
3. **控制互锁**：向上游（ipctrl）传递 stall，向下游（IDU）管控指令派发节奏；
4. **维护预测器状态**：在正确时机向 RAS 发出 push/pop，向 Indirect BTB 发出查询。

### 1.2 ibctrl 与 ibdp、IBUF、LBUF 的关系

```
ibctrl（控制器）                ibdp（数据通路）
─────────────────────────       ────────────────────────────
生成各种 _vld、_stall、         持有实际的指令数据、PC、
_flush、_create_vld 信号        预解码结果、hn_xxx 位图

ibctrl 读取 ibdp 提供的：
  · ibdp_ibctrl_hn_pcall[7:0]    — 当前取指包中哪些槽位是 CALL 指令
  · ibdp_ibctrl_hn_preturn[7:0]  — 哪些槽位是 RET 指令
  · ibdp_ibctrl_hn_ind_br[7:0]   — 哪些槽位是间接跳转
  · ibdp_ibctrl_default_pc[38:0] — 顺序执行的下一 PC
  · ibdp_ibctrl_ras_pc[38:0]     — RAS 栈顶预测 PC
  · ibdp_ibctrl_vpc[38:0]        — 当前取指包基地址
  · ibdp_ibctrl_l0_btb_mispred_pc[38:0] — L0 BTB 预测错误时的目标 PC
```

**设计哲学**：控制逻辑（ibctrl）与数据通路（ibdp）完全分离。ibctrl 只看"有没有 CALL/RET/间接跳转"，不关心指令的编码细节；ibdp 只做数据拼接和打包，不做控制决策。这样可以独立优化时序路径。

### 1.3 端口总览（重要信号速查）

```
输入（来自 IP 级）：
  ipctrl_ibctrl_vld           — IP 级当前拍有有效取指包（ib_data_vld）
  ipctrl_ibctrl_expt_vld      — IP 级检测到异常（屏蔽 chgflw/RAS 等）
  ipctrl_ibctrl_if_chgflw_vld — IF 级已发生过 chgflw（透传给 ibdp）
  ipctrl_ibctrl_ip_chgflw_vld — IP 级当拍有 chgflw（透传给 ibdp）
  ipctrl_ibctrl_l0_btb_*      — L0 BTB 命中/缺失/预测错等状态

输入（来自 LBUF）：
  lbuf_ibctrl_chgflw_vld/pc/pred — LBUF 发出的跳转请求
  lbuf_ibctrl_lbuf_active         — LBUF 当前处于活跃（循环）状态
  lbuf_ibctrl_stall               — LBUF 处于特殊状态，需要 stall

输入（来自 pcgen）：
  pcgen_ibctrl_cancel      — pcgen 已经接受了更高优先级的 chgflw，取消本级操作
  pcgen_ibctrl_ibuf_flush  — 通知刷新 IBUF
  pcgen_ibctrl_lbuf_flush  — 通知刷新 LBUF

输入（来自 IU）：
  iu_ifu_mispred_stall     — IU 检测到分支预测错误，IFU 需暂停
  iu_ifu_chgflw_vld        — IU 触发 change flow（外部强制 chgflw）
  iu_ifu_pcfifo_full       — pcfifo 已满，禁止新建 pcfifo 条目

输出（到 pcgen）：
  ibctrl_pcgen_pcload      — 请求 pcgen 接受新 PC（chgflw 信号）
  ibctrl_pcgen_pc[38:0]    — 目标 PC
  ibctrl_pcgen_way_pred[1:0] — I-Cache way 预测

输出（到 ibdp）：
  ibctrl_ibdp_cancel       — 通知 ibdp 取消当拍操作
  ibctrl_ibdp_chgflw       — 通知 ibdp 本拍有 chgflw
  ibctrl_ibdp_{ibuf,lbuf,bypass}_inst_vld — 指令派发方式

输出（到 IBUF）：
  ibctrl_ibuf_create_vld   — 允许写入 IBUF
  ibctrl_ibuf_retire_vld   — 允许 IBUF 出队送 IDU
  ibctrl_ibuf_flush        — 刷新 IBUF

输出（到 LBUF）：
  ibctrl_lbuf_create_vld   — 允许写入 LBUF
  ibctrl_lbuf_retire_vld   — 允许 LBUF 出队送 IDU
  ibctrl_lbuf_flush        — 刷新 LBUF

输出（到 RAS）：
  ibctrl_ras_pcall_vld     — 触发 RAS push（CALL 指令确认）
  ibctrl_ras_preturn_vld   — 触发 RAS pop（RET 指令确认）

输出（到 Ind-BTB）：
  ibctrl_ind_btb_check_vld — 向间接 BTB 发起查询
  ibctrl_ind_btb_path[7:0] — 查询地址的低位（用于索引 BTB 表）
```

---

## 2. IBUF 与 LBUF 仲裁

### 2.1 两种缓冲器的定位

C910 IFU 维护了两种指令缓冲器：

| 缓冲器 | 全名 | 典型场景 |
|--------|------|----------|
| IBUF | Instruction Buffer（FIFO 队列） | 正常直线代码、非循环场景 |
| LBUF | Loop Buffer（循环缓冲） | 短循环体，避免反复取指 |

IBUF 和 LBUF 是**互斥使用**的：同一时刻只有一个处于活跃状态。`lbuf_active` 信号是仲裁的核心。

**为什么要互斥？** IBUF 是 FIFO，需要有序出队；LBUF 是循环播放，两者的调度节奏完全不同。同时激活会导致 IDU 收到乱序的指令流，因此硬件上强制互斥。

### 2.2 lbuf_active 下的取指来源切换

```verilog
// 第 816 行
assign lbuf_active = lbuf_ibctrl_lbuf_active;
assign ibuf_empty  = ibuf_ibctrl_empty;
```

`lbuf_active` 来自 LBUF 子模块，由 LBUF 内部状态机管理（当循环计数器激活时置 1）。

**ibuf_inst_vld（IBUF 出队有效）**：

```verilog
// 第 776-779 行
assign ibuf_inst_vld = !ibuf_empty &&
                       !lbuf_active &&        // LBUF 活跃时 IBUF 静默
                       !mispred_stall;
```

**lbuf_inst_vld（LBUF 出队有效）**：

```verilog
// 第 771-774 行
assign lbuf_inst_vld = lbuf_active &&         // 只有 LBUF 活跃才输出
                       !fifo_full_stall &&
                       !mispred_stall;
```

### 2.3 ibctrl_ibuf_create_vld 的生成条件

```verilog
// 第 846-855 行
assign buf_create_vld  = ib_data_vld &&
                         !ib_addr_cancel &&
                         !(pcfifo_stall) &&
                         !(iu_ifu_mispred_stall && (|hn_mispred_stall[7:0])) &&
                         !iu_ifu_pcfifo_full &&
                         !(!ind_btb_rd_state && (|hn_ind_br[7:0]));

assign ibuf_create_vld = buf_create_vld &&
                         !lbuf_active &&                          // LBUF 活跃不写 IBUF
                         !(ibuf_ibctrl_stall || lbuf_ibctrl_stall);
```

`buf_create_vld` 是公共前置条件，在此基础上：
- 写 IBUF 要求 LBUF 不活跃、IBUF 和 LBUF 均未满/异常状态；
- 写 LBUF 有单独条件（见下文）。

### 2.4 ibctrl_lbuf_create_vld 的生成条件

```verilog
// 第 878-880 行
assign lbuf_create_vld = buf_create_vld &&
                         !iu_ifu_chgflw_vld &&     // IU 强制 chgflw 时不写
                         !ibuf_ibctrl_stall;       // IBUF 满时不写 LBUF
```

**为什么 `iu_ifu_chgflw_vld` 要阻止写 LBUF？** 当 IU 检测到分支预测错误并触发 chgflw 时，当前流水线中的指令将被丢弃。如果此时继续向 LBUF 写入，LBUF 会记录错误路径的指令，后续 flush 不及时可能导致错误指令被循环播放。

### 2.5 lbuf_create_vld vs ibuf_create_vld 差异小结

| 条件 | ibuf_create_vld | lbuf_create_vld |
|------|-----------------|-----------------|
| `lbuf_active` | 必须为 0 | 不要求 |
| `ibuf_ibctrl_stall` | 阻止 | 阻止 |
| `lbuf_ibctrl_stall` | 阻止 | 不阻止（LBUF 自己管理） |
| `iu_ifu_chgflw_vld` | 不阻止 | 阻止 |

---

## 3. Change Flow 决策

### 3.1 什么是 Change Flow

"Change Flow"（chgflw）是 IFU 内部的术语，表示"当前预测的取指方向需要纠正，pcgen 应该切换到新的 PC"。IB 级是最晚产生 chgflw 的流水级，其延迟最大，但可以处理 IP 级无法识别的间接跳转和 RAS 返回。

### 3.2 IB 级 chgflw 的三个来源

```
优先级（高→低）：
  1. lbuf_chgflw_vld   — LBUF 循环分支跳转
  2. ras_chgflw_vld    — RAS 返回地址预测
  3. ind_chgflw_vld    — Indirect BTB 间接跳转预测
  4. （默认）l0_btb_mispred_pc — L0 BTB 预测错误时的纠正 PC
```

代码中的优先级多路复用器（第 444-534 行）：

```verilog
// chgflw_pc 选择（第 453-461 行）
always @( ras_chgflw_vld or ras_chgflw_pc[38:0]
       or lbuf_chgflw_vld or lbuf_chgflw_pc[38:0]
       or ind_chgflw_vld  or ind_chgflw_pc[38:0]
       or ibdp_ibctrl_l0_btb_mispred_pc[38:0])
begin
  if(lbuf_chgflw_vld)
    chgflw_pc[PC_WIDTH-2:0] = lbuf_chgflw_pc[PC_WIDTH-2:0];
  else if(ras_chgflw_vld)
    chgflw_pc[PC_WIDTH-2:0] = ras_chgflw_pc[PC_WIDTH-2:0];
  else if(ind_chgflw_vld)
    chgflw_pc[PC_WIDTH-2:0] = ind_chgflw_pc[PC_WIDTH-2:0];
  else
    chgflw_pc[PC_WIDTH-2:0] = ibdp_ibctrl_l0_btb_mispred_pc[PC_WIDTH-2:0];
end
```

**为什么 lbuf 优先级最高？** LBUF 活跃时表示处理器正在执行一个已经确认的短循环，LBUF 对循环回边的跳转目标是已知且精确的（不依赖预测）。此时若 RAS 或 Ind-BTB 也产生了 chgflw，说明流水线里还有来自循环外的残留信息，这些信息已过时，应被 LBUF 的结果覆盖。

### 3.3 chgflw_vld（总体有效信号）

```verilog
// 第 575-583 行
assign chgflw_vld = (
                      ras_chgflw_vld && !ras_chgflw_mask ||
                      ind_chgflw_vld ||
                      lbuf_chgflw_vld ||
                      l0_btb_ras_mistaken
                    ) &&
                    !ib_expt_vld;  // 异常时屏蔽
```

注意 `l0_btb_ras_mistaken`：这是 ibdp 检测到 L0 BTB 对一条 RET 指令的预测目标与 RAS 栈顶不一致时产生的信号。这种情况下 RAS 的预测优先于 L0 BTB，需要触发一次 chgflw。

**异常时为何屏蔽 chgflw？** 当 IP 级检测到 page fault 或取指异常时，正确的处理是让异常指令进入 IDU 并最终提交给 RTU 处理。如果此时允许 IB 级的 chgflw 生效，pcgen 会跳转到一个预测 PC，而异常信息（已附在该指令上）可能丢失或被冲走，导致异常处理不正确。

### 3.4 ras_chgflw_mask 的作用

```verilog
// 第 557 行
assign ras_chgflw_mask = ibdp_ibctrl_ras_chgflw_mask;
```

`ras_chgflw_mask` 由 ibdp 根据具体的解码结果产生，用于屏蔽某些不需要触发 chgflw 的 RAS 命中情况（例如 RAS 预测结果与 L0 BTB 结果相同，则无需重复 chgflw）。

### 3.5 ibctrl_pcgen_pcload 与 ibctrl_pcgen_pcload_vld 的区别

```verilog
// 第 571-573 行
assign ibctrl_pcgen_pcload     = chgflw_vld;
assign ibctrl_pcgen_pcload_vld = chgflw_vld && !ib_chgflw_self_stall;
```

| 信号 | 含义 |
|------|------|
| `ibctrl_pcgen_pcload` | "本 IB 级有 chgflw 意图"（通知 ibdp、用于 debug） |
| `ibctrl_pcgen_pcload_vld` | "pcgen 可以现在执行跳转"（排除了自身 stall 情况） |

`ib_chgflw_self_stall`（第 596-598 行）包含三个子原因：

```verilog
assign ib_chgflw_self_stall = buf_stall ||       // IBUF/LBUF 满
                              fifo_full_stall ||  // pcfifo 满
                              mispred_stall;      // IU mispred 期间有 CALL/RET/Ind
```

**为什么有这个区分？** `pcload` 通知 ibdp 进行局部操作（如记录本次 chgflw 类型）不需要等待；而真正让 pcgen 切换 PC 的 `pcload_vld` 必须确保下游不会产生死锁。当 IBUF 满、pcfifo 满或 mispred 期间时，IFU 内部状态不稳定，立即切换 PC 可能导致新取回的指令因无处存放而卡死。

### 3.6 预测错误恢复时的 PC 选择

当 L0 BTB 预测错误（`l0_btb_ras_mistaken` 或 `ibctrl_ibdp_l0_btb_mispred` 情况）且没有更高优先级的 chgflw 时，`chgflw_pc` 退回到：

```verilog
// 第 460 行（默认分支）
chgflw_pc[PC_WIDTH-2:0] = ibdp_ibctrl_l0_btb_mispred_pc[PC_WIDTH-2:0];
```

这个 PC 由 ibdp 计算，是 L0 BTB 预测的目标 PC（而非顺序 PC）。注意与 `ibdp_ibctrl_default_pc`（顺序 PC）不同——在 L0 BTB 预测错时，目标 PC 仍然是分支目标，只是 BTB 表里记录的版本与实际不符，需要以 ibdp 重新计算的为准。

### 3.7 RAS chgflw 触发条件

```verilog
// 第 556 行
assign ras_chgflw_vld = ib_data_vld && (|hn_preturn[7:0]);
```

只要本拍取指包中有任何一个槽位被标记为 `preturn`（即 RET 指令），就触发 RAS pop 并使用 RAS 栈顶作为跳转目标。

**为什么 RAS 在 IB 级而不在 IP 级处理？** RAS 需要精确的指令解码结果来判断哪条指令是 RET（RISC-V 中通过 `JALR x0, ra, 0` 特征判断）。IP 级的预解码（precode）虽然有部分解码能力，但对 JALR 的操作数识别要等到 IB 级完成完整解码后才可靠。在 IB 级操作 RAS 可以减少误触发的概率。

### 3.8 Indirect BTB chgflw 触发条件

```verilog
// 第 543 行
assign ind_chgflw_vld = ib_data_vld && (|hn_ind_br[7:0]) && ind_btb_rd_state;
```

间接跳转（`hn_ind_br`）的 chgflw 有一个额外条件：`ind_btb_rd_state`。这是因为 Indirect BTB 查询有一拍延迟，必须等状态机进入 WAIT 状态（即已经发出查询并等到结果）才能用结果跳转。详见[第 6 节](#6-indirect-btb-状态机)。

### 3.9 Ind-BTB Miss 时的 fallback

```verilog
// 第 546-553 行
assign ind_btb_rd_vld              = ind_btb_ibctrl_dout[22]
                                   && (ind_btb_ibctrl_dout[21:20] == ind_btb_ibctrl_priv_mode[1:0]);
assign ind_chgflw_pc[PC_WIDTH-2:0] = (ind_btb_rd_vld)
                                   ? {ib_vpc[PC_WIDTH-2:20], ind_btb_ibctrl_dout[19:0]}
                                   : ibdp_ibctrl_default_pc[PC_WIDTH-2:0]; // Ind BTB Miss
assign ind_way_pred[1:0]           = (ind_btb_rd_vld) ? 2'b11 : 2'b00;    // Ind BTB Miss
```

Indirect BTB 命中的判断条件：
- `dout[22]`：valid 位，该条目是否有效；
- `dout[21:20] == priv_mode`：特权级匹配（用户态/内核态的函数指针跳转目标不同）。

若 BTB Miss，`ind_chgflw_pc` 退回到 `ibdp_ibctrl_default_pc`（顺序下一 PC），way_pred 置 `2'b00` 表示不做 I-Cache way 预测。

**为什么 Miss 时用顺序 PC 而非停顿等待？** 间接跳转的目标完全未知时，任何猜测都无法保证正确。C910 选择继续顺序取指（让流水线保持流动），等到执行单元（IU）确认实际跳转目标后再通过 `iu_ifu_chgflw_vld` 纠正。这是一种"乐观继续"策略，比停顿流水线的吞吐量更好。

---

## 4. Flush 与 Cancel 逻辑

### 4.1 两种清除操作的语义区别

| 操作 | 目标 | 含义 |
|------|------|------|
| `flush` | IBUF 或 LBUF 整体 | 清空缓冲器中已存入的所有指令条目 |
| `cancel` | 当拍 IB 级操作 | 取消本拍向 IBUF/LBUF 写入，已有内容不受影响 |

### 4.2 ibctrl_ibuf_flush 触发条件

```verilog
// 第 834 行
assign ibctrl_ibuf_flush = pcgen_ibctrl_ibuf_flush;
```

`ibctrl_ibuf_flush` 完全来自 pcgen。当更高优先级的 chgflw（IU 分支预测失败、RTU 异常等）被 pcgen 接受后，pcgen 会通知 IFU 所有缓冲器需要清空，因为缓冲器里存的是旧路径的指令。

**为什么 IBUF flush 不在 ibctrl 内部产生？** pcgen 是全局 PC 管理者，它知道何时发生了真正意义上的 PC 切换（而非 IB 级内部的预测纠正）。只有 pcgen 确认接受了新 PC，才应该清空 IBUF，否则会丢失正确路径上的指令。

### 4.3 ibctrl_lbuf_flush 触发条件

```verilog
// 第 869-870 行
assign ibctrl_lbuf_flush = pcgen_ibctrl_lbuf_flush ||
                           lbuf_ibctrl_active_idle_flush;
```

LBUF flush 有两个来源：

1. `pcgen_ibctrl_lbuf_flush`：与 IBUF flush 同理，pcgen 产生的全局 flush；
2. `lbuf_ibctrl_active_idle_flush`：LBUF 自身的状态机检测到循环结束（active→idle 转换），需要主动清空自身。

LBUF 自清的原因：循环结束后如果不清空 LBUF，下次程序进入不同的循环时，LBUF 可能还残留上次循环的指令，导致错误的循环播放。

### 4.4 ib_cancel 与 ib_addr_cancel 的区别

```verilog
// 第 753 行
assign ib_cancel = pcgen_ibctrl_cancel;
// 第 762 行
assign ib_addr_cancel = addrgen_ibctrl_cancel;
```

| 信号 | 来源 | 作用范围 |
|------|------|----------|
| `ib_cancel` | pcgen | 取消写入 IBUF/LBUF/pcfifo；同时取消发送给 IDU 的 bypass/ibuf/lbuf 指令 |
| `ib_addr_cancel` | addrgen | 取消写入 IBUF/LBUF/pcfifo；**但允许** IBUF/LBUF 继续向 IDU 输出指令 |

`addrgen` 是分支地址生成模块，当它检测到地址错误时只需要取消取指侧的操作，已经在缓冲器里的合法指令不受影响，可以继续派发给 IDU。这种细粒度的 cancel 减少了不必要的流水线冲刷。

代码中体现（第 822-823 行）：

```verilog
assign ibctrl_ibdp_cancel = ib_addr_cancel || ib_cancel;
```

ibdp 收到的 cancel 是两者的并集，但 ibdp 内部会区分处理（允许 addr_cancel 时继续 retire）。

### 4.5 cancel 对 Indirect BTB 状态机的影响

```verilog
// 第 696-703 行
always @(posedge ind_btb_rd_state_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    ind_btb_rd_state <= 1'b0;
  else if(ib_cancel || ib_addr_cancel)
    ind_btb_rd_state <= 1'b0;   // cancel 立即清零状态机
  ...
end
```

任何 cancel 都会强制重置 Ind-BTB 查询状态机，防止在路径切换后使用旧路径的 BTB 查询结果。

---

## 5. RAS Push/Pop 控制

### 5.1 RISC-V 中 CALL 和 RET 的识别规则

RISC-V 规范约定（非强制，但 RAS 优化依赖此约定）：

| 指令 | 编码特征 | 语义 |
|------|----------|------|
| `JAL rd, offset`（rd ≠ x0） | `rd = ra(x1)` 或 `rd = t0(x5)` | 函数调用（push RAS） |
| `JALR ra, rs, 0`（rd=ra, rs=ra） | rd=x1, rs=x1 | 协程式调用（push+pop） |
| `JALR x0, ra, 0` | rd=x0, rs=x1(ra) | 函数返回（pop RAS） |
| `JALR rd, rs, 0`（rd=ra） | rd=x1, rs≠ra | 间接调用（push RAS） |

C910 的 precode 模块在 IP 级完成上述识别，将结果以位图形式（每个槽位一位）保存在 `hn_pcall` 和 `hn_preturn` 中，通过 ibdp 传递给 ibctrl。

### 5.2 ibctrl_ras_pcall_vld（RAS push 触发）

```verilog
// 第 943-948 行
assign ibctrl_ras_pcall_vld = (|hn_pcall[7:0]) &&
                               ib_data_vld &&
                               !ib_expt_vld &&
                               !ib_chgflw_self_stall &&
                               !fifo_stall &&
                               !ind_btb_rd_stall;
```

有效条件逐项解释：

| 条件 | 原因 |
|------|------|
| `|hn_pcall[7:0]` | 取指包中存在 CALL 指令 |
| `ib_data_vld` | 当前拍有有效取指包 |
| `!ib_expt_vld` | 没有异常（异常下的 CALL 不该修改 RAS） |
| `!ib_chgflw_self_stall` | buf/fifo_full/mispred stall 期间不 push |
| `!fifo_stall` | pcfifo 拥塞时不 push |
| `!ind_btb_rd_stall` | Ind-BTB 查询未完成时不 push |

**为什么 stall 时不 push？** RAS 是精确状态，push 必须与指令的"确认通过"同步。如果在 stall 拍 push，而后续 cancel 导致该 CALL 指令被取消，RAS 就会多一个多余的返回地址，导致后续所有 RET 预测错误。

注意还有一个 `ibctrl_ras_inst_pcall` 信号：

```verilog
// 第 939-941 行
assign ibctrl_ras_inst_pcall = (|hn_pcall[7:0]) &&
                                ib_data_vld &&
                                !ib_expt_vld;
```

这个信号比 `pcall_vld` 宽松，不检查 stall 条件，专门用于通知 ibdp"当前包含 CALL 指令"（ibdp 需要这个信息来打包数据，不涉及 RAS 状态变更）。

### 5.3 ibctrl_ras_preturn_vld（RAS pop 触发）

```verilog
// 第 949-954 行
assign ibctrl_ras_preturn_vld = (|hn_preturn[7:0]) &&
                                 ib_data_vld &&
                                 !ib_expt_vld &&
                                 !ib_chgflw_self_stall &&
                                 !fifo_stall &&
                                 !ind_btb_rd_stall;
```

条件与 `pcall_vld` 对称，保证 push 和 pop 在同等约束下执行，维持 RAS 深度的正确性。

### 5.4 mispred_stall 对 RAS 的保护

```verilog
// 第 659-668 行
assign mispred_stall = iu_ifu_mispred_stall &&
                       ib_data_vld &&
                       !ib_expt_vld &&
                       (
                         (
                           |hn_pcall[7:0]   ||
                           |hn_preturn[7:0] ||
                           |hn_ind_br[7:0]
                         )
                       );
```

`mispred_stall` 专门在 IU 报告分支预测错误期间、且当前取指包含 CALL/RET/间接跳转时触发。这是一种精细的保护机制：

**为什么需要这个保护？** 当 IU 正在处理一个分支预测错误时，IFU 流水线里可能还有来自错误路径的 CALL/RET 指令正在流动。如果这些指令触发了 RAS push/pop，RAS 状态会被错误路径污染。后续正确路径的 RET 预测就会使用被污染的地址，产生连锁预测错误。`mispred_stall` 让 IB 级暂停，等 IU 的 chgflw 把错误路径冲走之后，再允许 CALL/RET 操作 RAS。

普通指令（无 CALL/RET/Ind-Br）在 mispred 期间不需要 stall，因为它们不影响预测器状态。

### 5.5 `_for_gateclk` 版本

```verilog
// 第 955-964 行
assign ibctrl_ras_pcall_vld_for_gateclk   = (|hn_pcall[7:0]) &&
                                             ib_data_vld &&
                                             !ib_expt_vld &&
                                             !ib_chgflw_self_stall &&
                                             !ind_btb_rd_stall;   // 无 fifo_stall

assign ibctrl_ras_preturn_vld_for_gateclk = (|hn_preturn[7:0]) &&
                                             ib_data_vld &&
                                             !ib_expt_vld &&
                                             !ib_chgflw_self_stall &&
                                             !ind_btb_rd_stall;   // 无 fifo_stall
```

`_for_gateclk` 版本用于给 RAS 模块的时钟门控（ICG）做使能信号，比功能版本少了 `fifo_stall` 的约束。这是因为：时钟门控只需要"可能有操作"就开门（宁可多开），避免 RAS 在真正需要写入时因时钟被关而无法响应。功能版本（`pcall_vld`/`preturn_vld`）有更严格的条件，才真正触发 RAS 状态变化。

---

## 6. Indirect BTB 状态机

### 6.1 间接跳转的预测难题

RISC-V 的 `JALR rs, rd, imm` 指令（以下简称间接跳转）的目标地址是寄存器值加立即数。在取指时，寄存器值尚未计算，因此无法像直接跳转（JAL）那样在预解码时直接知道目标。

C910 使用独立的 Indirect BTB（间接跳转目标缓冲）来预测这类指令的目标，基本原理是"用历史上同一 PC 的 JALR 指令的跳转目标来预测下一次的目标"（函数指针通常在程序生命期内保持不变）。

### 6.2 查询的一拍延迟问题

Indirect BTB 是一个 SRAM（`ct_spsram_256x23`），查询需要一拍。时序关系如下：

```
周期 N：IB 级检测到 ind_br（hn_ind_br 非零），发出查询请求（ind_btb_check_vld）
周期 N+1：Indirect BTB 返回结果（ind_btb_ibctrl_dout）
```

这意味着查询和使用结果之间有一拍气泡，需要状态机来协调。

### 6.3 状态机实现（IDLE/WAIT）

```verilog
// 第 692-704 行
always @(posedge ind_btb_rd_state_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    ind_btb_rd_state <= 1'b0;                        // 复位：IDLE
  else if(ib_cancel || ib_addr_cancel)
    ind_btb_rd_state <= 1'b0;                        // cancel：强制回 IDLE
  else if(ind_btb_rd_stall)
    ind_btb_rd_state <= 1'b1;                        // 检测到 ind_br：进入 WAIT
  else if(ind_btb_rd_state && chgflw_vld && !fifo_stall && !fifo_full_stall)
    ind_btb_rd_state <= 1'b0;                        // chgflw 成功：回 IDLE
  else
    ind_btb_rd_state <= ind_btb_rd_state;            // 保持
end
```

状态转换图：

```
                  ib_cancel/addr_cancel
                  ┌──────────────────────────────┐
                  │                              │
          ind_btb_rd_stall                       │
IDLE(0) ──────────────────► WAIT(1) ──────────────────► IDLE(0)
  ▲                                    chgflw_vld &&
  │                                    !fifo_stall &&
  │                                    !fifo_full_stall
  │
  └── 复位
```

| 状态 | `ind_btb_rd_state` 值 | 含义 |
|------|-----------------------|------|
| IDLE | 0 | 没有间接跳转在等待查询结果 |
| WAIT | 1 | 已发出查询，等待结果；本周期可以使用结果 |

**进入 WAIT 的条件（`ind_btb_rd_stall`）**：

```verilog
// 第 729-732 行
assign ind_btb_rd_stall = !ind_btb_rd_state &&     // 当前是 IDLE
                          ib_data_vld &&
                          !ib_expt_vld &&
                          (|hn_ind_br[7:0]);        // 有间接跳转
```

第一次检测到 ind_br 时（处于 IDLE），产生 `ind_btb_rd_stall`，流水线停顿一拍，同时将查询发出，状态机进入 WAIT。

**退出 WAIT 的条件**：下一拍结果回来，`ind_chgflw_vld`（即 `ib_data_vld && |hn_ind_br && ind_btb_rd_state`）为真，且 chgflw 能成功（无 fifo stall），跳转完成，状态机回 IDLE。

### 6.4 查询有效性检查（命中 + 特权级）

```verilog
// 第 546-547 行
assign ind_btb_rd_vld = ind_btb_ibctrl_dout[22]
                      && (ind_btb_ibctrl_dout[21:20] == ind_btb_ibctrl_priv_mode[1:0]);
```

Indirect BTB 返回 23 位数据：

| 位域 | 含义 |
|------|------|
| `[22]` | valid 位 |
| `[21:20]` | 存储该条目时的特权级（00=U, 01=S, 11=M） |
| `[19:0]` | 跳转目标 PC 的低 20 位 |

特权级匹配检查是安全机制：避免在特权级切换后使用旧特权级记录的跳转目标（内核态和用户态的同一个函数指针 PC 可能跳向不同目标）。

### 6.5 时钟门控

```verilog
// 第 724-727 行
assign ind_btb_rd_state_clk_en = ib_cancel ||
                                 ib_addr_cancel ||
                                 ind_btb_rd_state ||    // 处于 WAIT 状态
                                 ind_btb_rd_stall;      // 即将进入 WAIT
```

状态机寄存器只有在真正需要变化的周期才开启时钟，其余时间处于门控休眠状态，节省功耗。

### 6.6 pcfifo 侧的通知

```verilog
// 第 903-904 行
assign ibctrl_pcfifo_if_ind_target_pc[PC_WIDTH-2:0] = ind_chgflw_pc[PC_WIDTH-2:0];
assign ibctrl_pcfifo_if_ind_btb_miss                = ~ind_btb_rd_vld;
```

每次间接跳转确认时，ibctrl 会把目标 PC 和 "是否 BTB miss" 写入 pcfifo（PC FIFO），供 IU 退休时做精确比对和 BTB 更新训练。

---

## 7. 向 pcgen 的输出汇总

### 7.1 ibctrl_pcgen_pcload（chgflw 触发）

```verilog
// 第 571 行
assign ibctrl_pcgen_pcload = chgflw_vld;
```

这是 IB 级向 pcgen 发出的"强制跳转"信号。pcgen 收到后，将在下一拍把 PC 切换到 `ibctrl_pcgen_pc`。

注意与 `ibctrl_pcgen_pcload_vld` 的区别已在第 3.5 节说明。在架构上，`pcload` 表示"意图"，`pcload_vld` 表示"可执行"。pcgen 同时接收两个信号：`pcload` 用于记录"IB 级上报了 chgflw"，`pcload_vld` 用于实际切换 PC。

### 7.2 ibctrl_pcgen_pc[38:0]（目标 PC）

```verilog
// 第 441 行
assign ibctrl_pcgen_pc[PC_WIDTH-2:0] = chgflw_pc[PC_WIDTH-2:0];
```

直接输出多路复用后的 `chgflw_pc`，优先级见第 3.2 节。

`PC_WIDTH = 40` 表示架构物理字节地址宽度为 40 位。该总线只保存架构地址 `[39:1]`，所以 RTL 宽度为 39 位 `[38:0]`；恢复普通字节 PC 时应在最低位补 `1'b0`。

### 7.3 ibctrl_pcgen_way_pred[1:0]（I-Cache way 预测）

```verilog
// 第 442 行
assign ibctrl_pcgen_way_pred[1:0] = way_pred[1:0];
```

`way_pred` 的多路复用（第 464-481 行）：

```verilog
if(lbuf_chgflw_vld)
  way_pred[1:0] = lbuf_chgflw_pred[1:0];  // LBUF 提供（来自上次命中记录）
else if(ras_chgflw_vld)
  way_pred[1:0] = ras_way_pred[1:0];       // RAS：2'b11（不确定，全选）
else if(ind_chgflw_vld)
  way_pred[1:0] = ind_way_pred[1:0];       // Ind-BTB：命中 2'b11，Miss 2'b00
else
  way_pred[1:0] = 2'b11;                   // L0 BTB mispred 默认：2'b11
```

`way_pred[1:0]` 的编码含义：

| 值 | 含义 |
|----|------|
| `2'b00` | 预测命中 Way 0 |
| `2'b01` | 预测命中 Way 1 |
| `2'b10` | 预测命中 Way 2 |
| `2'b11` | 不确定，两路都访问 |

I-Cache way 预测是一种"伪相联"优化：如果能提前知道指令在哪个 way，就不需要同时读多路 SRAM，可以降低功耗。当不确定时（`2'b11`），则两路都读（保证命中），代价是多消耗功耗。RAS 和 L0 BTB mispred 场景下一般使用 `2'b11`，因为历史信息不可靠。

### 7.4 ibctrl_pcgen_ip_stall（传递 stall）

```verilog
// 第 618 行
assign ibctrl_pcgen_ip_stall = ibctrl_ipctrl_stall;
```

IB 级的 stall 信号同时发给 ipctrl 和 pcgen，让整个 IFU 上游流水线在同一拍暂停，避免流水线级间的空洞（bubble）不受控扩散。

---

## 8. 与 ibdp 的协作

### 8.1 控制/数据分离设计思想

ibctrl 生成所有控制信号，ibdp 持有所有数据。两者的接口可以归纳为：

```
ibctrl → ibdp（控制命令）：
  ibctrl_ibdp_cancel              — 取消本拍操作
  ibctrl_ibdp_chgflw              — 本拍有 chgflw（ibdp 据此决定是否打包特殊字段）
  ibctrl_ibdp_ibuf_inst_vld       — 指示用 IBUF 路径发送给 IDU
  ibctrl_ibdp_lbuf_inst_vld       — 指示用 LBUF 路径发送给 IDU
  ibctrl_ibdp_bypass_inst_vld     — 指示走 bypass 路径（直接发送，不经过 IBUF）
  ibctrl_ibdp_mispred_stall       — 当前处于 mispred stall
  ibctrl_ibdp_self_stall          — 其他类型的 stall
  ibctrl_ibdp_buf_stall           — buf（IBUF/LBUF）stall
  ibctrl_ibdp_fifo_stall          — pcfifo stall
  ibctrl_ibdp_fifo_full_stall     — pcfifo 满 stall
  ibctrl_ibdp_ind_btb_rd_stall    — Ind-BTB 读 stall
  ibctrl_ibdp_if_chgflw_vld       — IF 级曾经发生 chgflw（透传）
  ibctrl_ibdp_ip_chgflw_vld       — IP 级当拍 chgflw（透传）
  ibctrl_ibdp_l0_btb_{hit,miss,mispred,wait} — L0 BTB 状态（透传）

ibdp → ibctrl（数据结果）：
  ibdp_ibctrl_hn_pcall[7:0]       — 哪些槽位是 CALL 指令
  ibdp_ibctrl_hn_preturn[7:0]     — 哪些槽位是 RET 指令
  ibdp_ibctrl_hn_ind_br[7:0]      — 哪些槽位是间接跳转
  ibdp_ibctrl_default_pc[38:0]    — 顺序下一 PC
  ibdp_ibctrl_ras_pc[38:0]        — RAS 预测 PC
  ibdp_ibctrl_ras_chgflw_mask     — 是否屏蔽 RAS chgflw
  ibdp_ibctrl_ras_mistaken        — L0 BTB 对 RAS 预测错
  ibdp_ibctrl_l0_btb_mispred_pc[38:0] — L0 BTB 预测错误时的正确 PC
  ibdp_ibctrl_vpc[38:0]           — 当前取指包基地址（用于 Ind-BTB 地址拼接）
  ibdp_ibctrl_chgflw_{vl,vlmul,vsew} — chgflw 时的向量寄存器状态快照
```

### 8.2 bypass 路径的意义

```verilog
// 第 783-791 行
assign bypass_inst_vld = ib_data_vld &&
                         ibuf_empty &&        // IBUF 必须为空（保证顺序）
                         !lbuf_active &&
                         !buf_stall &&
                         !fifo_stall &&
                         !fifo_full_stall &&
                         !mispred_stall &&
                         !ib_addr_cancel &&
                         !ind_btb_rd_stall;
```

bypass 路径允许 IP 级的取指包在 IBUF 为空时**直接**发送给 IDU，跳过"写入 IBUF 再读出"的两拍延迟。这是一种关键路径优化：

- 普通情况（IBUF 为空、无 stall）：IP 级指令直接送 IDU，IB 级延迟为 0 拍（纯组合逻辑路径）；
- 积压情况（IBUF 非空）：新指令先进 IBUF，按 FIFO 顺序出队，保证有序性。

注意 bypass 要求 `ibuf_empty`——如果 IBUF 还有旧指令，直接 bypass 会破坏程序顺序（IDU 会先收到新指令），因此必须等 IBUF 排空。

### 8.3 merge_inst_vld（IBUF merge 操作）

```verilog
// 第 796-808 行
assign merge_inst_vld = ib_data_vld &&
                        !ib_expt_vld &&
                        !ibuf_empty &&        // IBUF 非空才有 merge 意义
                        !lbuf_active &&
                        !buf_stall &&
                        !fifo_stall &&
                        !fifo_full_stall &&
                        !mispred_stall &&
                        !ib_addr_cancel &&
                        !ind_btb_rd_stall &&
                        !idu_stall &&
                        !idu_ifu_id_bypass_stall;
```

`merge_inst_vld` 允许把 IP 级新到的取指包与 IBUF 头部的指令**合并**发送给 IDU（IBUF 尾部合并），实现更高的带宽利用率。条件比 bypass 更严格，需要额外排除 `idu_stall` 和 `idu_ifu_id_bypass_stall`，因为 merge 操作涉及 IBUF 出队，必须确保 IDU 此刻可以接收。

### 8.4 ibctrl_ibuf_bypass_not_select

```verilog
// 第 841 行
assign ibctrl_ibuf_bypass_not_select = idu_ifu_id_bypass_stall;
```

当 IDU 反压（`bypass_stall`）时，通知 IBUF 不要选择 bypass 路径，而是等待 IDU 准备好后再通过正常的 IBUF 出队路径发送。这是一个握手信号，防止 IBUF 在 IDU 未就绪时误认为 bypass 通道可用。

---

## 9. Stall 传播

### 9.1 ibctrl 产生的 stall 种类

ibctrl 汇聚了多个来源的 stall，向上游传递统一的 `ibctrl_ipctrl_stall`：

```verilog
// 第 612-616 行
assign ibctrl_ipctrl_stall = mispred_stall   ||
                             buf_stall       ||
                             fifo_full_stall ||
                             fifo_stall      ||
                             ind_btb_rd_stall;
```

各 stall 信号的来源和含义：

| stall 信号 | 触发条件 | 影响范围 |
|------------|---------|----------|
| `mispred_stall` | IU mispred 期间 + CALL/RET/Ind-Br | 保护 RAS/Ind-BTB 状态 |
| `buf_stall` | IBUF 满 或 LBUF 异常状态 | 背压（下游无处存放） |
| `fifo_full_stall` | pcfifo 满 | 避免 pcfifo 溢出 |
| `fifo_stall` | pcfifo 超过 2 项 | 避免 pcfifo 项目过多导致 OoO 问题 |
| `ind_btb_rd_stall` | Ind-BTB 查询进行中 | 等待查询结果（一拍气泡） |

### 9.2 IBUF 满时的 stall 处理

```verilog
// 第 637-641 行
assign buf_stall = (
                    ib_data_vld &&
                    ibuf_ibctrl_stall   // ibuf_full
                  ) ||
                  lbuf_ibctrl_stall;   // lbuf 特殊状态
```

`ibuf_ibctrl_stall` 来自 IBUF 子模块，表示 IBUF 已满（无法接受新指令）。此时如果 IP 级仍有有效取指包（`ib_data_vld`），IB 级必须 stall，防止指令丢失。

stall 向上传播路径：

```
IBUF 满（ibuf_ibctrl_stall）
  → buf_stall = 1
    → ibctrl_ipctrl_stall = 1
      → IP 级（ipctrl）保持当前指令不前进
        → IF 级（ifctrl）停止发出新取指请求
          → pcgen 暂停 PC 递增
```

整条流水线同步暂停，等到 IDU 从 IBUF 取走指令、IBUF 出现空槽后，`ibuf_ibctrl_stall` 降低，流水线恢复流动。

### 9.3 low_power_stall 的特殊性

```verilog
// 第 625-629 行
assign ibctrl_ipctrl_low_power_stall = mispred_stall ||
                                       buf_stall ||
                                       fifo_full_stall ||
                                       ib_expt_low_power_stall;
```

`low_power_stall` 是 `ipctrl_stall` 的子集，用于低功耗模式下的特殊处理。注释说明：

> For when low power req, cancel ip refill set to avoid deadlock.
> In case of IDU does not access inst and IFU ibuf full
> Which condition IFU should not let ip_refill set
> Otherwise ip_refill will not let ifu_no_op set

低功耗模式下，如果 IDU 停止从 IFU 取指（省电），但 IFU 的 IBUF 已满，此时 IFU 会反复尝试 refill（因为自认为还需要取指），导致死锁。`low_power_stall` 告知 IP 级在这种情况下**取消** refill 请求，让 IFU 进入真正的空闲状态。

注意 `fifo_stall` 和 `ind_btb_rd_stall` 不包含在 `low_power_stall` 中（注释掉的代码可以看出曾经包含）——这两个 stall 不会导致死锁，低功耗模式下不需要特殊处理。

### 9.4 pcfifo 相关 stall 的精确语义

```verilog
// 第 682-683 行
assign fifo_stall   = ib_data_vld && pcfifo_stall;
assign pcfifo_stall = pcfifo_if_ibctrl_more_than_two && !ib_expt_vld;
```

`pcfifo_more_than_two` 表示 PC FIFO 中已经有超过 2 个条目等待（IP/IF 级还在处理的取指请求）。此时继续创建新 pcfifo 条目可能导致乱序 PC 管理问题。

注意代码注释（第 674-678 行）：

```
// fifo_stall get may use 7-8 Gate,
// which will make ib_chgflw_vld timing worse
// Considering ib chgflw not use fifo_stall
// And correct it by cancel IF stage
```

`fifo_stall` 的组合逻辑深度较大，若加入 `chgflw_vld` 的路径会使时序变差。C910 的解决方案是：`chgflw_vld`（第 575-581 行）**不包含** `fifo_stall`，允许 chgflw 在 fifo stall 期间照常发出，通过 cancel IF 级来解决 pcfifo 中的旧条目。

### 9.5 stall 优先级关系注释

代码第 607-608 行有一个重要说明：

```verilog
// idu_ifu_id_bypass_stall > idu_stall > iu_ifu_mispred_stall
// Which can be used to simplify logic
```

这说明 C910 内部维护了以下 stall 优先级契约（由更高层保证）：
- 如果 `idu_ifu_id_bypass_stall` 有效，则 `idu_stall` 一定有效；
- 如果 `idu_stall` 有效，则 `iu_ifu_mispred_stall` 一定有效。

基于这个关系，ibctrl 的某些逻辑可以省略对低优先级信号的重复检查，减少逻辑门数。

---

## 附录：关键信号一览表

### 状态寄存器

| 寄存器 | 位宽 | 功能 |
|--------|------|------|
| `ind_btb_rd_state` | 1 bit | Indirect BTB 查询状态机（0=IDLE, 1=WAIT） |
| `chgflw_pc` | 39 bit | 寄存最终选定的 chgflw 目标 PC（组合逻辑，无寄存） |
| `way_pred` | 2 bit | 寄存最终选定的 I-Cache way 预测（组合逻辑） |
| `chgflw_vl/vlmul/vsew` | 合计 13 bit | chgflw 时向量配置寄存器快照（组合逻辑） |

### chgflw 决策树

```
有 lbuf_chgflw_vld ?
  是 → PC = lbuf_chgflw_pc, way = lbuf_chgflw_pred
  否 → 有 ras_chgflw_vld && !mask ?
         是 → PC = ras_pc, way = 2'b11
         否 → 有 ind_chgflw_vld ?
                是 → PC = ind_chgflw_pc(BTB结果 or default_pc), way = 2'b11/2'b00
                否 → 有 l0_btb_ras_mistaken ?
                       是 → PC = l0_btb_mispred_pc, way = 2'b11
                       否 → chgflw_vld = 0（不跳转）
```

### stall 影响矩阵

| 阻塞原因 | ipctrl stall | chgflw 可用 | RAS push/pop | IBUF write | IBUF retire |
|---------|:---:|:---:|:---:|:---:|:---:|
| `buf_stall` | Y | N | N | N | N |
| `fifo_full_stall` | Y | N | N | N | N |
| `fifo_stall` | Y | Y* | N | N | N |
| `mispred_stall` | Y | N | N | N | N |
| `ind_btb_rd_stall` | Y | N | N | N | N |
| `idu_stall` | N | N | N | N | N（出队阻止） |
| `ib_cancel` | N | N | N | N | N（全取消） |
| `ib_addr_cancel` | N | N | N | N | Y（允许出队） |

> `*`：`fifo_stall` 不阻止 `chgflw_vld` 产生（时序优化设计），但会阻止 chgflw 成功执行（通过 IF 级 cancel 修正）。

---

## 参考：与本模块交互的子模块

| 模块 | 交互方向 | 主要信号类型 |
|------|---------|-------------|
| `ct_ifu_ibdp` | 双向 | 解码结果（ibdp→ctrl），控制命令（ctrl→ibdp） |
| `ct_ifu_ibuf` | 双向 | 写入/读出控制，flush，满/空状态 |
| `ct_ifu_lbuf` | 双向 | 写入/读出控制，flush，active/stall 状态，chgflw 请求 |
| `ct_ifu_pcgen` | 双向 | pcload/pc 输出，cancel/flush 输入 |
| `ct_ifu_ipctrl` | 双向 | vld/expt 输入，stall 输出，L0 BTB 状态透传 |
| `ct_ifu_ras` | 输出 | pcall_vld, preturn_vld 触发 RAS 状态机 |
| `ct_ifu_ind_btb` | 双向 | check_vld/path 查询，dout/priv_mode 结果 |
| `ct_ifu_pcfifo_if` | 双向 | create_vld 写入，more_than_two/full 背压 |
| IU（整数执行单元） | 输入 | mispred_stall, chgflw_vld, pcfifo_full |
| IDU（译码单元） | 输入 | id_stall, id_bypass_stall |
| addrgen | 输入 | addr_cancel |
