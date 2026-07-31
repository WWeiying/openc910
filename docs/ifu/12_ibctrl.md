# C910 IFU ibctrl 模块详解

> 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ibctrl.v`
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
| IB 级 | 消费 IP 级已生成的分支类别，协调 RAS/Ind-BTB、PCFIFO、IBUF/LBUF 和 IDU 供给 |

IB 级是 IFU 流水线的**最后一级**，也是距离 IDU 最近的一级。它的核心职责是：

1. **分发指令**：把从 IP 级流入的取指包（fetch bundle）写入 IBUF 或 LBUF；
2. **较晚级重定向**：对 return、间接跳转、LBUF 重定向和 L0-RAS mistaken 做出 Change Flow（chgflw）决策；
3. **控制互锁**：向上游（ipctrl）传递 stall，向下游（IDU）管控指令派发节奏；
4. **维护预测器时序**：在数据包真正可推进时向 RAS 发出 push/pop，并协调
   Indirect BTB 一拍读结果和 path-history 更新。

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
  · ibdp_ibctrl_default_pc[38:0] — 当前包第一条有效指令的 PC
  · ibdp_ibctrl_ras_pc[38:0]     — RAS 栈顶预测 PC
  · ibdp_ibctrl_vpc[38:0]        — 当前取指包基地址
  · ibdp_ibctrl_l0_btb_mispred_pc[38:0] — 多分支/H0/L0 相关恢复 PC
```

这是一种控制/数据职责划分，而不是“完全分离”。IBCTRL 主要消费 IBDP 已整理好的
`pcall/preturn/ind_br` 位图，不重新读取 opcode；IBDP 除了拼接数据，也会计算
RAS/L0 一致性、mask、目标元数据和旁路数据选择。两者共同完成 IB 级行为，不能把
IBDP 描述成没有控制含义的被动寄存器堆。

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
  ibctrl_pcgen_pcload      — 功能性 PC 重定向（chgflw 信号）
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
  ibctrl_ind_btb_check_vld — 间接跳转被 IB 接受，允许更新 Ind-BTB path history
  ibctrl_ind_btb_path[7:0] — 本次预测目标内部 PC [10:3]，写入 path history
```

---

## 2. IBUF 与 LBUF 仲裁

### 2.1 两种缓冲器的定位

C910 IFU 维护了两种指令缓冲器：

| 缓冲器 | 全名 | 典型场景 |
|--------|------|----------|
| IBUF | Instruction Buffer（FIFO 队列） | 正常直线代码、非循环场景 |
| LBUF | Loop Buffer（循环缓冲） | 短循环体，避免反复取指 |

IBUF 与 LBUF 的**退休来源**互斥，但它们的写入并非始终互斥。LBUF 尚未 active 时，
一个满足条件的 IP→IB 数据包可以同时令 `ibuf_create_vld` 与 `lbuf_create_vld`
成立：IBUF 保存正常顺序流，LBUF 同时观察并收集可能形成短循环的内容。LBUF
进入 active 后，`ibuf_create_vld` 被 `!lbuf_active` 压低，IDU 的数据源切到 LBUF。

因此 `lbuf_active` 的准确含义是“循环缓冲正在作为指令供给源”，而不是“系统中只有
LBUF 含有数据”。RTL 注释依赖一个更强的系统不变量：LBUF active 时 IBUF 应为空；
IBCTRL 的 `ibuf_retire_vld` 本身并没有显式检查 `!lbuf_active`。

### 2.2 lbuf_active 下的取指来源切换

```verilog
// 第 816 行
assign lbuf_active = lbuf_ibctrl_lbuf_active;
assign ibuf_empty  = ibuf_ibctrl_empty;
```

`lbuf_active` 来自 LBUF 子模块，由 LBUF 内部状态机管理。何时进入 active 必须结合
`ct_ifu_lbuf.v` 的前分支、缓存和循环状态判断，不能简单等同于“循环计数器激活”。

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

`buf_create_vld` 是公共前置条件。注意源码中 `ib_cancel` 检查被注释掉，实际组合条件
直接排除的是 `ib_addr_cancel`、当前包超过两个 PC-oper、涉及 CALL/RET/间接跳转的
mispred stall、PCFIFO full，以及首次遇到间接跳转时的等待。高优先级 PCGEN cancel
通过 `ibctrl_ibdp_cancel`、PCFIFO create 屏蔽和缓冲 flush 路径共同处理，不能说
`buf_create_vld` 自身包含 `!ib_cancel`。

在公共条件之上：

- 写 IBUF 要求 LBUF 未 active，且 IBUF/LBUF 都未提出 stall；
- 写 LBUF 不要求 `!lbuf_active`，但要求无 IU chgflw 且 IBUF 未 stall；
- 在 LBUF 未 active 的普通阶段，两者可能同拍都为 1。

### 2.4 ibctrl_lbuf_create_vld 的生成条件

```verilog
// 第 878-880 行
assign lbuf_create_vld = buf_create_vld &&
                         !iu_ifu_chgflw_vld &&     // IU 强制 chgflw 时不写
                         !ibuf_ibctrl_stall;       // IBUF 满时不写 LBUF
```

`iu_ifu_chgflw_vld` 表示更后级已经发起高优先级控制流恢复。禁止该拍写 LBUF 可避免
把即将被恢复路径淘汰的数据吸收到循环候选状态；正常 IBUF 侧的清除还由 PCGEN
flush/cancel 协议配合完成。

### 2.5 lbuf_create_vld vs ibuf_create_vld 差异小结

| 条件 | ibuf_create_vld | lbuf_create_vld |
|------|-----------------|-----------------|
| `lbuf_active` | 必须为 0 | 不要求 |
| `ibuf_ibctrl_stall` | 阻止 | 阻止 |
| `lbuf_ibctrl_stall` | 阻止 | 不阻止（LBUF 自己管理） |
| `iu_ifu_chgflw_vld` | 不阻止 | 阻止 |

表中“`lbuf_ibctrl_stall` 不直接阻止 LBUF create”只描述 IBCTRL 这一层的与门；
LBUF 内部是否真正写某个条目，还要看它自己的状态机和 create 选择逻辑。

---

## 3. Change Flow 决策

### 3.1 什么是 Change Flow

"Change Flow"（chgflw）是 IFU 内部对 PC 重定向的统称。它不一定表示某个预测
已经由执行结果证明错误：LBUF 回边、RAS return 和 Ind-BTB 目标预测都可以主动产生
chgflw；L0-RAS mistaken 才是明确的早期预测类别不符。IB 是 IFU 内较晚的前端级，
此时已有完整的 IP 预解码数据包和一拍 Ind-BTB 结果。

### 3.2 IB 级 chgflw 的来源与目标优先级

```
目标 PC 与 way-pred mux 的优先级（高→低）：
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

RTL 明确给 LBUF 最高选择优先级。体系结构上，这保证循环播放期间由 LBUF 保存的
循环控制流支配普通 IB 数据包中的 RAS/间接跳转候选；至于 LBUF 目标是否最终正确，
仍可能被更后级 BJU/RTU 恢复，不能称为“不依赖预测的已确认结果”。

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

`l0_btb_ras_mistaken` 的精确定义不是“L0 目标与 RAS 栈顶不一致”。IBDP 在以下条件
下置位：IF 级已经 chgflw、L0 条目标记为 RAS、IP 级没有再次 chgflw、当前 IB 数据
有效，但包内**没有** `preturn`。也就是 L0 把一条并非 return 的控制流错误分类成
RAS。目标不相等但确实存在 return 的情况属于 `l0_btb_ras_mispred` 路径。

**异常时为何屏蔽 chgflw？** 当 IP 级检测到 page fault 或取指异常时，正确的处理是让异常指令进入 IDU 并最终提交给 RTU 处理。如果此时允许 IB 级的 chgflw 生效，pcgen 会跳转到一个预测 PC，而异常信息（已附在该指令上）可能丢失或被冲走，导致异常处理不正确。

### 3.4 ras_chgflw_mask 的作用

```verilog
// 第 557 行
assign ras_chgflw_mask = ibdp_ibctrl_ras_chgflw_mask;
```

`ras_chgflw_mask` 等于 IBDP 的 `l0_btb_ras_hit`：L0 已在 IF 级按 RAS 重定向，当前
包确实含 return，L0 目标与 RAS 候选相等，且相关有效/使能条件成立。此时 IB 级无需
对同一目标重复重定向。

一个容易忽略的 RTL 细节是：`chgflw_vld` 对 RAS 使用
`ras_chgflw_vld && !ras_chgflw_mask`，但 PC/way mux 的优先级判断使用原始
`ras_chgflw_vld`。设计依赖这些来源在合法状态下具有一致或互斥关系；阅读孤立波形时
应同时观察 raw valid、mask 和最终 `chgflw_vld`。

### 3.5 ibctrl_pcgen_pcload 与 ibctrl_pcgen_pcload_vld 的区别

```verilog
// 第 571-573 行
assign ibctrl_pcgen_pcload     = chgflw_vld;
assign ibctrl_pcgen_pcload_vld = chgflw_vld && !ib_chgflw_self_stall;
```

| 信号 | 含义 |
|------|------|
| `ibctrl_pcgen_pcload` | IB 级 chgflw，本身直接参与 PCGEN 的 PC 优先级选择和 `if_pc` 更新 |
| `ibctrl_pcgen_pcload_vld` | chgflw 且无 `buf/fifo_full/mispred` self-stall，供 PCGEN 的 L0-BTB read-valid 等附属路径使用 |

`ib_chgflw_self_stall`（第 596-598 行）包含三个子原因：

```verilog
assign ib_chgflw_self_stall = buf_stall ||       // IBUF/LBUF 满
                              fifo_full_stall ||  // pcfifo 满
                              mispred_stall;      // IU mispred 期间有 CALL/RET/Ind
```

必须纠正一个常见误读：PCGEN 的 `pcgen_chgflw` 和目标 PC mux直接使用
`ibctrl_pcgen_pcload`，不是 `pcload_vld`；`if_pc` 在 `pcgen_chgflw` 时也优先装入
chgflw PC。`pcload_vld` 出现在 `pcgen_l0_btb_chgflw_vld` 等需要“这次 IB
重定向可继续驱动 L0-BTB 读取”的资格路径。因此二者是“功能重定向”与“去除
self-stall 后的附属有效”，不能解释成 request/accept 握手。

`ib_chgflw_self_stall` 也刻意不包含 `fifo_stall` 和 `ind_btb_rd_stall`，这是源码
为缩短 chgflw 路径作出的协议选择，而不是所有 IB stall 的简单 OR。

### 3.6 预测错误恢复时的 PC 选择

当 L0 BTB 预测错误（`l0_btb_ras_mistaken` 或 `ibctrl_ibdp_l0_btb_mispred` 情况）且没有更高优先级的 chgflw 时，`chgflw_pc` 退回到：

```verilog
// 第 460 行（默认分支）
chgflw_pc[PC_WIDTH-2:0] = ibdp_ibctrl_l0_btb_mispred_pc[PC_WIDTH-2:0];
```

这个值由 IPDP/IBDP 保留下来的 `l0_btb_mispred_pc` 提供，可能表示多分支重发点、
跨窗口 H0 位置或 L0 给出的恢复 PC，具体来源见 `ct_ifu_ipdp.v` 的
`pipe_l0_btb_mispred_pc` 选择。不能统一称为“重新计算出的实际分支目标”。

它也不同于 `ibdp_ibctrl_default_pc`。后者并非“顺序下一取指窗口”，而是当前 IB
数据包第一条指令的内部 PC：有 H0 时取 H0 PC，否则取重排后的 H1 PC。

### 3.7 RAS chgflw 触发条件

```verilog
// 第 556 行
assign ras_chgflw_vld = ib_data_vld && (|hn_preturn[7:0]);
```

`ras_chgflw_vld` 只是 return 重定向候选；最终 `chgflw_vld` 还受
`ras_chgflw_mask` 和异常屏蔽影响。真正使 RAS speculative stack pop 的是后面的
`ibctrl_ras_preturn_vld`，它还要求无 self-stall、无 fifo stall、无 Ind-BTB
等待。因此“选择 RAS 目标”和“允许 RAS 状态前移”是两条相关但不同的控制线。

return 分类实际上已由 IPDP 内的两套 `ct_ifu_ipdecode` 产生，并随数据包进入 IBDP。
把 RAS pop 放到 IB 控制点的关键原因是这里已经知道该包是否被 cancel、是否能跨过
PCFIFO/缓冲反压以及 L0-RAS 是否已完成同目标重定向。它保证 speculative RAS 状态
与真正被前端接受的 CALL/RET 顺序一致，而不是因为 IB 级才第一次解析 JALR。

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

若 Ind-BTB 无效或特权级不匹配，`ind_chgflw_pc` 退回
`ibdp_ibctrl_default_pc`，即当前数据包第一条指令的 PC；`way_pred=2'b00` 表示没有
任何 I-Cache way 可被预测选中，并会在 PCGEN/IFCTRL 路径形成 way-pred stall。

这是一种保守的重取/等待语义，而不是“继续顺序取指”的乐观策略。真实 JALR 目标
仍需执行侧计算后由 IU chgflw 恢复。要判断 miss 期间前端到底保持多少拍，应联合观察
`ind_btb_rd_state`、`way_pred==00`、`pcgen_ifctrl_way_pred_stall` 和 IU chgflw，
不能只看 `ind_chgflw_pc`。

---

## 4. Flush 与 Cancel 逻辑

### 4.1 两种清除操作的语义区别

| 操作 | 目标 | 含义 |
|------|------|------|
| `flush` | IBUF 或 LBUF 整体 | 让缓冲器清除已保存的有效状态 |
| `cancel` | IB 当前包及相关在途操作 | 取消范围依来源和配套协议而异，不能统一推断已有缓冲项是否仍可输出 |

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

RTL 注释给出的**接口意图**是：

| 信号 | 来源 | 接口意图 |
|------|------|----------|
| `ib_cancel` | pcgen | 更高优先级改流取消当前 IB 操作，包括新建缓冲项、创建 PCFIFO 项和向 IDU 发送当前路径指令 |
| `ib_addr_cancel` | addrgen | 取消当前 IP→IB 数据包的地址相关操作和 bypass，但允许 IBUF/LBUF 中先前保存的指令继续输出 |

不过，阅读波形时不能只按这张意图表推断每一根有效信号。当前
`ct_ifu_ibctrl.v` 的局部组合逻辑具有以下精确特征：

- `fifo_create_vld` 同时显式检查 `!ib_cancel` 和 `!ib_addr_cancel`；
- `bypass_inst_vld` 显式检查 `!ib_addr_cancel`，没有直接检查 `ib_cancel`；
- `buf_create_vld` 显式检查 `!ib_addr_cancel`，原来的 `!ib_cancel` 条件已被注释；
- `ibuf_inst_vld` 和 `lbuf_inst_vld` 也没有直接以两个 cancel 为门控。

因此，“`ib_cancel` 会取消所有 IB 级操作”是由 PCGEN 的 cancel/flush、IBCTRL
控制、IBDP 掩码以及 IDU 保持协议共同实现的系统语义，不能由
`buf_create_vld` 这一条方程单独证明。`ib_addr_cancel` 的局部区别则很清楚：
它阻止当前数据包 bypass 和新建缓冲/PCFIFO 项，但没有直接禁止已有 IBUF/LBUF
条目出队。

代码中体现（第 822-823 行）：

```verilog
assign ibctrl_ibdp_cancel = ib_addr_cancel || ib_cancel;
```

IBDP 只收到两者的逻辑或，因而**无法在 IBDP 内部区分 cancel 来源**。该信号在
IBDP 中用于取消/清除 PC 操作更新掩码等状态；两类 cancel 对 bypass、缓冲创建
和已有条目输出的差异，主要由 IBCTRL 的其他控制方程及上游 flush 协议实现。

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

任何 cancel 都会强制清除 IBCTRL 中用于对齐 Ind-BTB 返回结果的状态，避免后续
把已取消数据包与旧的预测结果配对。

---

## 5. RAS Push/Pop 控制

### 5.1 C910 对 CALL 和 RET 的实际识别规则

RISC-V 将 `x1` 和 `x5` 作为 RAS 提示所使用的 link register。C910 在 IP 级由
`ct_ifu_ipdecode` 实例化的 `ct_ifu_decd_normal` 解码每个候选指令，而不是由
四位 precode 完成 CALL/RET 分类。主要 RTL 规则如下：

| 指令类别 | `pcall`（push 候选） | `preturn`（pop 候选） |
|----------|----------------------|-------------------------|
| `JAL` | `rd` 为 `x1` 或 `x5` | 否 |
| `JALR` | `rd` 为 `x1` 或 `x5` | `rs1` 为 `x1`/`x5`、`rd != rs1` 且 `imm=0` |
| `C.JALR` | 有效编码即产生 push 候选 | 隐含 `rd=x1` 且 `rs1=x5` 时也产生 pop 候选 |
| `C.JR` | 否 | `rs1` 为 `x1` 或 `x5` |

所以某条 `JALR` 可以同时属于 push 和 pop 候选，例如两个不同 link register
之间的协程式调用。IPDP 将各位置的结果形成 `hn_pcall[7:0]` 和
`hn_preturn[7:0]` 位图，IBCTRL 再根据异常、停顿和接收状态决定是否真正改变
RAS。这里的“候选”很重要：IP 解码说明指令语义，IB 控制才决定预测器状态何时
推进。

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
| `\|hn_pcall[7:0]` | 取指包中存在 CALL 指令 |
| `ib_data_vld` | 当前拍有有效取指包 |
| `!ib_expt_vld` | 没有异常（异常下的 CALL 不该修改 RAS） |
| `!ib_chgflw_self_stall` | buf/fifo_full/mispred stall 期间不 push |
| `!fifo_stall` | 当前包含超过 PCFIFO 单拍接口可承载的 PC 操作时不 push |
| `!ind_btb_rd_stall` | 首次遇到间接跳转、等待已发起的 Ind-BTB 读取对齐时不 push |

RAS 是**推测性的预测器状态**，并非架构精确状态；但同一个被保持的数据包不能在
多个 stall 周期重复 push/pop。上述条件把 RAS 更新与 IB 级认可该包的时刻对齐。
如果在保持周期重复推进 RAS，返回栈深度和栈顶都会被同一条指令错误修改多次。

注意还有一个 `ibctrl_ras_inst_pcall` 信号：

```verilog
// 第 939-941 行
assign ibctrl_ras_inst_pcall = (|hn_pcall[7:0]) &&
                                ib_data_vld &&
                                !ib_expt_vld;
```

这个信号比 `pcall_vld` 宽松，不检查 stall 条件。它送入 RAS，用于在
`ras_ipdp_pc` 处选择“本拍 CALL 产生的 push PC”还是“现有 RAS 栈顶 PC”，供
PCFIFO/预测相关数据路径使用；真正改变 RAS 栈状态的仍是
`ibctrl_ras_pcall_vld`。

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

`mispred_stall` 只在 IU 报告预测错误、当前 IB 包有效且无异常，并且包中存在
CALL/RET/间接跳转候选时触发。

**为什么需要这个保护？** 当 IU 正在处理一个分支预测错误时，IFU 流水线里可能还有来自错误路径的 CALL/RET 指令正在流动。如果这些指令触发了 RAS push/pop，RAS 状态会被错误路径污染。后续正确路径的 RET 预测就会使用被污染的地址，产生连锁预测错误。`mispred_stall` 让 IB 级暂停，等 IU 的 chgflw 把错误路径冲走之后，再允许 CALL/RET 操作 RAS。

从 IBCTRL 这一方程看，不含上述三类指令的包不会因为
`iu_ifu_mispred_stall` 单独产生这里的 `mispred_stall`。这不等于错误路径普通
指令可以退休；更高优先级改流的 cancel/flush 和 IDU/RTU 协议仍负责维持全局
精确性。

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

`_for_gateclk` 版本用于给 RAS 内部 ICG 提供前瞻使能，比功能版本少
`fifo_stall`，因此它可以多开一个周期，而功能版本仍决定状态是否真正改变。

这里还要区分 RTL 使能意图和仿真实际时钟。通用 `gated_clk_cell` 的使能为

```verilog
(global_en && (module_en || local_en)) || external_en
```

所以 `local_en=0` 不能单独证明时钟停止，`module_en` 仍可覆盖它；而未定义
`C910_USE_TSMC28_ICG` 时，模型直接执行 `assign clk_out = clk_in`，普通 RTL
仿真中不会出现真实门控后的时钟波形。门控节能效果属于综合/物理实现问题，不能
仅凭此处局部使能断言具体功耗收益。

---

## 6. Indirect BTB 状态机

### 6.1 间接跳转的预测难题

RISC-V 的 `JALR rd, rs1, imm` 指令（以下简称间接跳转）的目标地址由寄存器
`rs1` 与立即数计算得到。在取指时源寄存器值尚不可用，因此无法像直接跳转
`JAL` 那样仅靠指令立即数生成目标。

C910 使用独立的 Indirect BTB 预测这类目标。其 256 项索引不是简单使用当前
JALR PC，而是把四级路径历史选定位与虚拟全局历史 `vghr_reg[7:0]` 分段异或；
退休更新时使用相应的退休路径历史与真实 GHR。这样可以让同一间接跳转在不同控制
流上下文中映射到不同预测项，代价是历史维护、别名和恢复逻辑更复杂。IBCTRL
关注的是返回结果与 IB 包对齐，完整索引和更新机制见 `17_ind_btb.md`。

### 6.2 查询的一拍延迟问题

Indirect BTB 数据阵列是 `ct_spsram_256x23`，读出结果还会在
`ct_ifu_ind_btb` 中寄存。初始读取不是由 IBCTRL 的
`ibctrl_ind_btb_check_vld` 发起，而是在 IP 级检测到间接跳转时由
`ipdp_ind_btb_jmp_detect` 触发。IBCTRL 的状态位负责让已经进入 IB 的数据包
等待并与返回结果对齐：

```
IP 级：ipdp_ind_btb_jmp_detect 发起阵列读
  ↓
IB 首次看到 hn_ind_br：ind_btb_rd_stall=1，保持当前包
  ↓
ind_btb_rd_state=1：使用已寄存的 dout 形成目标或 miss 回放
```

RTL 注释明确把这描述为等待一拍；从结构上看，这一拍用于对齐同步存储阵列返回
和 IB 包，而 `ibctrl_ind_btb_check_vld` 是预测改流完成后的路径历史更新有效，
不是存储阵列查询请求。

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
| IDLE | 0 | IBCTRL 没有保持待处理的间接跳转包 |
| WAIT | 1 | 间接跳转包已被保持，当前可把它与 Ind-BTB 返回结果配对 |

**进入 WAIT 的条件（`ind_btb_rd_stall`）**：

```verilog
// 第 729-732 行
assign ind_btb_rd_stall = !ind_btb_rd_state &&     // 当前是 IDLE
                          ib_data_vld &&
                          !ib_expt_vld &&
                          (|hn_ind_br[7:0]);        // 有间接跳转
```

第一次在 IB 检测到 `ind_br` 时（状态为 0），产生
`ind_btb_rd_stall` 并保持流水线一拍，状态进入 1。阵列读取已由前一阶段的
`ipdp_ind_btb_jmp_detect` 发起，IBCTRL 此处不是再次发读请求。

**退出状态 1 的条件**：`ind_btb_rd_state && chgflw_vld` 成立，并且没有
`fifo_stall`/`fifo_full_stall`。若这些约束未满足，状态和 IB 包继续保持。这里的
状态 1 更准确的含义是“返回结果阶段/间接包保持态”，而不是存储器仍在进行一个
可变延迟访问。

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
| `[21:20]` | 创建/读取该条目时保存的特权级编码 |
| `[19:0]` | 跳转目标 PC 的低 20 位 |

命中要求条目保存的特权级与发起读取时锁存的 `cp0_yy_priv_mode` 一致。它用于
防止跨特权环境复用不匹配的间接目标，是预测正确性和隔离设计的一部分，但不能
单独等同于完整的安全边界。
命中目标由当前 `ib_vpc[38:20]` 与条目低 20 位拼接；未命中则使用当前包第一条
有效指令的 PC 形成保守回放，并给出 `way_pred=2'b00`。

### 6.5 时钟门控

```verilog
// 第 724-727 行
assign ind_btb_rd_state_clk_en = ib_cancel ||
                                 ib_addr_cancel ||
                                 ind_btb_rd_state ||    // 处于 WAIT 状态
                                 ind_btb_rd_stall;      // 即将进入 WAIT
```

`local_en` 覆盖状态清除、进入和保持状态所需周期，这是门控意图。是否真的关闭
时钟还取决于 `global_en`、`module_en`、ICG 宏定义和综合实现：在默认非
`C910_USE_TSMC28_ICG` RTL 模型中，`clk_out` 直接等于 `clk_in`。

### 6.6 PCFIFO 信息与路径历史更新

```verilog
// 第 903-904 行
assign ibctrl_pcfifo_if_ind_target_pc[PC_WIDTH-2:0] = ind_chgflw_pc[PC_WIDTH-2:0];
assign ibctrl_pcfifo_if_ind_btb_miss                = ~ind_btb_rd_vld;
```

这些字段随 PCFIFO 创建接口记录本次预测目标和 Ind-BTB 是否 miss，供后续执行
结果检查及退休更新链路使用。它们只是待写数据字段；是否在该拍真正创建条目还要
联合 `ibctrl_pcfifo_if_create_vld` 及 PCFIFO 自身接口条件判断。

另有一组名字容易误解：

```verilog
assign ibctrl_ind_btb_check_vld = ind_chgflw_vld &&
                                   !ib_chgflw_self_stall &&
                                   !fifo_stall;
assign ibctrl_ind_btb_path[7:0] = ind_chgflw_pc[10:3];
```

`check_vld` 不是初始查询有效，而是间接预测改流被接受后更新 Ind-BTB
`path_reg_0..3` 的有效信号；`path` 也不是查询地址，而是预测目标内部 PC
`[10:3]`，对应架构字节地址 `[11:4]` 的 16 字节窗口编号。Ind-BTB 将旧路径
寄存器依次后移并把该值放入 `path_reg_0`，形成后续索引/历史的一部分。

---

## 7. 向 pcgen 的输出汇总

### 7.1 ibctrl_pcgen_pcload（chgflw 触发）

```verilog
// 第 571 行
assign ibctrl_pcgen_pcload = chgflw_vld;
```

这是 IB 级的功能性 PC 重定向信号。PCGEN 的目标选择、`pcgen_chgflw` 以及
`if_pc` 更新路径直接使用 `ibctrl_pcgen_pcload`，因此不能把它只解释成
“请求”。

`ibctrl_pcgen_pcload_vld = chgflw_vld && !ib_chgflw_self_stall` 是额外限定的
side-valid，供 L0-BTB 改流记录等路径使用；它不是 PCGEN 实际切换 PC 的唯一
使能。具体在哪个时钟边沿观察到新 `if_pc`，应结合 PCGEN 寄存器方程和上层
cancel 优先级判断，而不应脱离整个路径固定宣称“下一拍”。

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
| `2'b00` | 两路均未预测；会形成 way-pred stall |
| `2'b01` | 选择/使能 Way 0 |
| `2'b10` | 选择/使能 Way 1 |
| `2'b11` | 两路都作为候选 |

这是两位 **way mask**，不是四种 way 编号；C910 此处的 I-Cache 只有 Way0 和
Way1。RTL 证据包括重发时使用
`{icache_way1_hit, icache_way0_hit}`，以及 PCGEN 在 `way_predict==2'b00` 时
置位 way-pred stall。选择单路可用于减少无效阵列活动，但真实功耗收益仍需综合网
表和物理实现数据验证。RAS、Ind-BTB 命中及默认恢复通常给 `2'b11`；Ind-BTB
miss 给 `2'b00`，迫使前端等待重新建立可靠的取指选择。

### 7.4 ibctrl_pcgen_ip_stall（传递 stall）

```verilog
// 第 618 行
assign ibctrl_pcgen_ip_stall = ibctrl_ipctrl_stall;
```

IB 级的 stall 信号同时发给 ipctrl 和 pcgen，让整个 IFU 上游流水线在同一拍暂停，避免流水线级间的空洞（bubble）不受控扩散。

---

## 8. 与 ibdp 的协作

### 8.1 控制/数据分离设计思想

IBCTRL 主要生成握手、停顿、改流选择和缓冲控制；IBDP 主要组织数据，并计算
掩码、PC、L0/RAS 一致性等数据相关结果。两者并非“控制与数据完全互不相干”，
而是把大部分宽数据组合逻辑和控制仲裁分开。接口可归纳为：

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
  ibdp_ibctrl_default_pc[38:0]    — 当前包第一条有效指令的 PC
  ibdp_ibctrl_ras_pc[38:0]        — RAS 预测 PC
  ibdp_ibctrl_ras_chgflw_mask     — 是否屏蔽 RAS chgflw
  ibdp_ibctrl_ras_mistaken        — L0 将当前流错误分类为 RAS 的恢复条件
  ibdp_ibctrl_l0_btb_mispred_pc[38:0] — 多分支/H0/L0 相关恢复 PC
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

bypass 路径允许当前 IP→IB 包在 IBUF 为空时直接成为 IBDP 向 IDU 组织指令的
数据源，避免必须先把所有半字写入 IBUF、再从 IBUF 头部选出。它减少的是结构上
的缓冲往返，不应仅由这段 RTL 固定量化成“两拍”，也不能称作“IB 延迟为零”：
组合选择、IBDP 打包、IDU 接收和跨级寄存器仍然存在。确切周期数要用
`ipctrl_ibctrl_vld`、`bypass_inst_vld`、`ifu_idu_ib_inst*_vld` 与 IDU
pipedown 波形测量。

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

`merge_inst_vld` 允许 IBUF 在头部不足三个完整输出指令时，用当前 IP→IB 包中的
新指令补齐空余 IDU 槽位。它是“IBUF 头部输出 + 当前包”的输出合并，不是把当前
包简单并到 IBUF 尾部。条件比纯 bypass 更严格，因为合并会同步改变 IBUF 的
retire/create 指针，并要求 IDU 当前能够接受组合后的最多三条指令。

教学上可以把它理解为两条并行路径：

```text
IBUF 已缓存的最老指令 ─┐
                        ├─ 按程序顺序拼成最多 3 条 IDU 输入
当前 IP→IB 新指令 ─────┘
```

IBUF 中的老指令始终排在新指令前面；如果没有足够输出槽位，新数据仍写入 IBUF，
不会越过老指令。

### 8.4 ibctrl_ibuf_bypass_not_select

```verilog
// 第 841 行
assign ibctrl_ibuf_bypass_not_select = idu_ifu_id_bypass_stall;
```

在 `ct_ifu_ibuf.v` 中，它参与

```verilog
bypass_vld = ibuf_empty && !ibctrl_ibuf_bypass_not_select;
```

当 IDU 给出 bypass 反压时，新建半字不能以“空 IBUF 直接穿透”的形式被消费，
而要在 IBUF 条目中实际保存，等待后续正常输出。它不是简单让整个 IBUF 原地等待
的单一握手，而是改变新建数据“穿透还是落入队列”的选择。

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
| `buf_stall` | 有效 IB 包遇到 IBUF 满，或 LBUF 给出自身状态相关 stall | 缓冲接收背压 |
| `fifo_full_stall` | pcfifo 满 | 避免 pcfifo 溢出 |
| `fifo_stall` | 当前包经掩码后含超过两个 `pc_oper` | 把单包 PC 操作拆成 PCFIFO 接口可处理的批次 |
| `ind_btb_rd_stall` | 状态 0 首次看到间接跳转包 | 保持一拍以对齐已发起的 Ind-BTB 读取 |

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

IBCTRL 将该 stall 同时送给 IPCTRL 和 PCGEN，使当前 IP→IB 包及取指 PC 不继续
推进。与此同时，IBUF 中较老指令能否出队仍由 `idu_stall` 和
`ibuf_retire_vld` 判断；因此“上游停止接收新包”和“下游排空已有项”可以同时
发生。等 IBUF 腾出足够空间后，背压解除。

### 9.3 low_power_stall 的特殊性

```verilog
// 第 625-629 行
assign ibctrl_ipctrl_low_power_stall = mispred_stall ||
                                       buf_stall ||
                                       fifo_full_stall ||
                                       ib_expt_low_power_stall;
```

`low_power_stall` 不是简单复制全部功能 stall，而是提供给 IPCTRL 的另一组
“低功耗/取消 refill 判断条件”。注释说明：

> For when low power req, cancel ip refill set to avoid deadlock.
> In case of IDU does not access inst and IFU ibuf full
> Which condition IFU should not let ip_refill set
> Otherwise ip_refill will not let ifu_no_op set

这条路径的设计目标是在低功耗请求期间避免 refill 状态妨碍 IFU 达到
`no_op`。不能据此反推“IDU 已经关闭”或证明某类 stall 绝不会死锁；本模块只能
证明 `mispred_stall`、`buf_stall`、`fifo_full_stall` 和
`ib_expt_low_power_stall` 被纳入该判断，而 `fifo_stall`、
`ind_btb_rd_stall` 没被纳入。

`ib_expt_low_power_stall` 的附加条件
`!(&ib_vpc[10:3])` 表示异常包所在 16 字节窗口并非 4 KiB 页的最后一个窗口：
内部 PC `[10:3]` 对应架构字节地址 `[11:4]`。这使 IPCTRL 可以在不跨页的异常
场景屏蔽不必要 refill；页尾情况需保留更谨慎的边界处理。

### 9.4 pcfifo 相关 stall 的精确语义

```verilog
// 第 682-683 行
assign fifo_stall   = ib_data_vld && pcfifo_stall;
assign pcfifo_stall = pcfifo_if_ibctrl_more_than_two && !ib_expt_vld;
```

`pcfifo_if_ibctrl_more_than_two` **不是 FIFO 占用量**。它由当前包的
`hn_pc_oper[7:0]` 计算：先去掉最前和最后一个有效 PC 操作，再检查中间是否仍有
有效位；若有，说明本包至少包含三个 `pc_oper`。PCFIFO 的单拍创建接口最多承载
两个 PC 操作，所以该包必须保持并通过掩码分批处理。真正表示容量不足的是来自 IU
的 `iu_ifu_pcfifo_full`，它形成 `fifo_full_stall`。

注意代码注释（第 674-678 行）：

```
// fifo_stall get may use 7-8 Gate,
// which will make ib_chgflw_vld timing worse
// Considering ib chgflw not use fifo_stall
// And correct it by cancel IF stage
```

RTL 注释指出 `more_than_two` 检测约有 7 至 8 级门延迟，因此没有把
`fifo_stall` 串入 `chgflw_vld` 的关键组合路径。结果是 `fifo_stall` 期间
`ibctrl_pcgen_pcload` 仍可能有效，且 `pcload_vld` 也没有被
`fifo_stall` 直接屏蔽；与此同时，RAS 更新、缓冲创建和 Ind-BTB 路径历史推进会
被禁止，IBDP/PCFIFO 的 `pc_oper` 掩码保存尚未处理的位。这里体现的是“让 PC
改流关键路径保持短，额外状态负责分批和取消”的设计取舍，不能解释成 PCFIFO
已有条目乱序。

### 9.5 stall 优先级关系注释

代码第 607-608 行有一个重要说明：

```verilog
// idu_ifu_id_bypass_stall > idu_stall > iu_ifu_mispred_stall
// Which can be used to simplify logic
```

这里的 `>` 是设计者对控制覆盖/优先处理关系的注释，说明实现会先按 bypass
保持，再按普通 IDU stall，最后处理 mispredict 相关保持来简化局部逻辑。仅凭这
两行注释不能严格推出任意周期都有布尔蕴含
`bypass_stall => idu_stall => mispred_stall`；若要验证该协议，应沿 IDU 和 IU
的信号产生方程及实际波形继续检查。

---

## 附录：关键信号一览表

### 状态与组合选择量

| 信号 | 类型 | 位宽 | 功能 |
|------|------|------|------|
| `ind_btb_rd_state` | 时序寄存器 | 1 bit | Ind-BTB 返回结果与 IB 包的对齐/保持状态 |
| `chgflw_pc` | 组合选择量 | 39 bit | 按 LBUF、RAS、Ind-BTB、L0/RAS 恢复优先级选目标 |
| `way_pred` | 组合选择量 | 2 bit | 最终 I-Cache 两路 way mask |
| `chgflw_vl/vlmul/vsew` | 组合选择量 | 合计 13 bit | 与所选改流源对应的向量配置字段；当前生成配置中向量 ISA 被禁用 |

### chgflw 有效性与数据选择

`chgflw_vld` 的产生条件和目标多路器并非使用完全相同的条件：

```text
chgflw_vld =
  (RAS 候选且未被 mask) 或 Ind-BTB 或 LBUF 或 L0-RAS mistaken
  并且当前包无异常
```

目标 PC 和 way mask 的组合多路器则使用**原始**
`ras_chgflw_vld`，优先级为：

```
有 lbuf_chgflw_vld ?
  是 → PC = lbuf_chgflw_pc, way = lbuf_chgflw_pred
  否 → 有原始 ras_chgflw_vld ?
         是 → PC = ras_pc, way = 2'b11
         否 → 有 ind_chgflw_vld ?
                是 → PC = ind_chgflw_pc(BTB结果 or default_pc), way = 2'b11/2'b00
                否 → PC = l0_btb_mispred_pc, way = 2'b11
```

这依赖设计不变量保证“RAS 被 mask 时，若另一恢复源使最终 `chgflw_vld` 有效，
原始 RAS 候选不会错误抢占目标”。做波形核查时应同时观察
`ras_chgflw_vld`、`ras_chgflw_mask`、`l0_btb_ras_mistaken`、
`ind_chgflw_vld`、最终 `chgflw_vld` 和 `chgflw_pc`；只按最终 valid 反推目标
来源会漏掉这一层原始选择关系。

### stall 的直接作用矩阵

下表只列本模块方程中的**直接门控**，不把上游 flush、IDU 保持等协议效果混进来：

| 原因 | 上游 `ipctrl_stall` | `pcload` 候选 | `pcload_vld` | RAS 更新 | 当前包新建缓冲 |
|------|:---:|:---:|:---:|:---:|:---:|
| `buf_stall` | Y | 可能 | N | N | N |
| `fifo_full_stall` | Y | 可能 | N | N | N |
| `fifo_stall` | Y | 可能 | 可能 | N | N |
| `mispred_stall` | Y | 可能 | N | N | N |
| `ind_btb_rd_stall` | Y | 当前间接候选为 N | N | N | N |
| `idu_stall` | N | 不直接影响 | 不直接影响 | 不直接影响 | 不直接影响 |
| `ib_addr_cancel` | N | 不直接改变候选 | 不直接改变 | 状态因地址 cancel 清除 | N |

“可能”表示仍取决于是否存在 LBUF/RAS/Ind-BTB/L0-RAS 恢复源。IBUF 已有条目的
retire 主要由 `ibuf_empty`、`mispred_stall` 和 `idu_stall` 决定，不应笼统地
认为任一上游 stall 都同时禁止出队。`ib_cancel` 的系统效果依赖 PCGEN
cancel/flush 协议，见 4.4 节，因而不在这张仅描述局部直接门控的表中伪装成单一
组合条件。

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
| `ct_ifu_ind_btb` | 双向 | check_vld/path 历史更新，dout/priv_mode 读取结果 |
| `ct_ifu_pcfifo_if` | 双向 | create_vld 写入，当前包 more_than_two 检测 |
| IU（整数执行单元） | 输入 | mispred_stall, chgflw_vld, pcfifo_full |
| IDU（译码单元） | 输入 | id_stall, id_bypass_stall |
| addrgen | 输入 | addr_cancel |
