# C910 CIU CTCQ/VB 模块详细教学文档

> RTL 文件：`ct_ciu_ctcq.v`（约 2332 行）、`ct_ciu_ctcq_reqq_entry.v`（约 406 行）、`ct_ciu_ctcq_respq_entry.v`（约 246 行）、`ct_ciu_vb.v`（约 589 行）、`ct_ciu_vb_aw_entry.v`（约 270 行）
>
> 上层：`ct_ciu_top.v` 实例化 `x_ct_ciu_ctcq`（行 3480）、`x_ct_ciu_vb`（行 3122）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与队列深度](#3-参数与队列深度)
4. [CTC 与 MOESI Owned 态](#4-ctc-与-moesi-owned-态)
5. [CTCQ 请求队列 reqq](#5-ctcq-请求队列-reqq)
6. [CTCQ 响应队列 respq](#6-ctcq-响应队列-respq)
7. [CTC 数据流：核间直传绕过内存](#7-ctc-数据流核间直传绕过内存)
8. [DVM 同步](#8-dvm-同步)
9. [VB：CIU 侧逐出/写回缓冲](#9-vbciu-侧逐出写回缓冲)
10. [VB 的地址依赖检测](#10-vb-的地址依赖检测)
11. [设计取舍小结](#11-设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

本文讲两个相邻但职责不同的小队列：

- **CTCQ（Cache-to-Cache transfer Queue，缓存间传输队列）**：当一个核持有脏 cache line（M/O 态）、另一个核要读它时，CTCQ 负责把脏数据**直接从拥有者核传给请求者核**，绕过内存。它同时承担 **DVM（Distributed Virtual Memory）同步**——多核 TLB 维护广播。
- **VB（Victim Buffer，逐出/写回缓冲）**：CIU 侧的写回缓冲。当 L2C 或 SNB 要把一条脏 line 逐出（victim）写回内存时，写地址（AW）+写数据（W）先进 VB 暂存，再排队送 EBIU 写出去。

### 1.2 位置

```
        侦听到脏数据/独占请求
              │
   ┌──────────┴──────────┐
   │       CTCQ          │   reqq×8 (请求) + respq×16 (完成跟踪)
   │  ┌──────┐ ┌───────┐ │
   │  │ reqq │ │ respq │ │── AC→PIU(广播相关核)
   │  └──────┘ └───────┘ │── AR→EBIU(DVM)
   └──────────┬──────────┘
              │ ctc 数据：拥有者核 →(CIU)→ 请求者核
              ▼ 不经内存

   L2C/SNB 逐出脏行 ──AW+W──► VB (2 项) ──► EBIU ──► 内存
```

---

## 2. 端口说明

### 2.1 CTCQ 端口（`ct_ciu_ctcq.v`）

| 组 | 信号 | 方向 | 含义 | file:line |
|----|------|------|------|-----------|
| PIU 请求 | `piu0_ctcq_ar_req`/`ar_bus[70:0]` | in | 各核来的 CTC/DVM 请求 | `ct_ciu_ctcq.v:83-84` |
| PIU 响应 | `piu0_ctcq_cr_req`/`cr_bus[9:0]` | in | 各核 CR 响应（带 respq id） | `ct_ciu_ctcq.v:85-86` |
| PIU 数据授权 | `piu0_ctcq_r_grant` | in | 读数据授权 | `ct_ciu_ctcq.v:87` |
| 给 PIU 侦听 | `ctcq_piu0_acvalid`/`acbus[54:0]` | out | 向核广播 AC（snoop=1111） | `ct_ciu_ctcq.v:171-172` |
| 给 PIU 授权 | `ctcq_piu0_ar_grant`/`cr_grant`/`rvalid`/`bar_cmplt` | out | 各类授权/完成 | `ct_ciu_ctcq.v:47-50` |
| L2C | `ctcq_l2c_addr_req`/`req_type[1:0]`、`l2c_ctcq_cmplt` | out/in | 向 L2C 请求、完成回报 | `ct_ciu_ctcq.v:169-170,125` |
| EBIU AR | `ctcq_ebiu_araddr[39:0]`…`arsnoop[3:0]`/`arvalid` | out | DVM 经外部总线广播 | `ct_ciu_ctcq.v:153-164` |
| EBIU AC | `ebiuif_ctcq_acaddr[39:0]`/`acsnoop[3:0]`/`acid[4:0]`/`acvalid` | in | 外部来的 AC（DVM） | `ct_ciu_ctcq.v:74-77` |
| BMB | `ctcq_bmbif_bar_grant` | out | barrier 授权 | `ct_ciu_ctcq.v:25` |

### 2.2 VB 端口（`ct_ciu_vb.v`）

| 组 | 信号 | 方向 | 含义 | file:line |
|----|------|------|------|-----------|
| L2C 逐出 | `l2c0_vb_awbus[67:0]`/`awvalid`/`mid[2:0]`/`vid[1:0]`、`l2c0_vb_wbus[534:0]`/`wvalid` | in | L2C bank0 逐出的 AW+W | `ct_ciu_vb.v:98-103` |
| SNB 写回 | `snb0_vb_*`、`snb1_vb_*` | in | SNB 来的写回 | `ct_ciu_vb.v:110-124` |
| EBIU 授权 | `ebiu_vb_aw_grant`/`w_grant` | in | EBIU 接收授权 | `ct_ciu_vb.v:90,95` |
| 送 EBIU | `vb_ebiu_awvalid`/`awaddr[39:0]`/`awid[5:0]`、`vb_ebiu_wvalid`/`wdata[127:0]`/`wstrb[15:0]`/`wlast` | out | 写出到外部总线 | `ct_ciu_vb.v:127-145` |
| 授权回送 | `vb_l2c0_vctm_grant`、`vb_snb0_aw_grant`/`w_grant` | out | victim/AW/W 授权回源 | `ct_ciu_vb.v:147-151` |
| 依赖标志 | `vb_ebiuif_addr_depd` | out | 与 SNB 地址冲突 | `ct_ciu_vb.v:146` |

---

## 3. 参数与队列深度

| 结构 | 深度 | 项宽/字段 | file:line |
|------|------|-----------|-----------|
| CTCQ reqq（请求队列） | **8** | `reqq_addr[39:0]` + `reqq_aim[5:0]` | `ct_ciu_ctcq.v:212`（8 位创建指针）、`ct_ciu_ctcq_reqq_entry.v:95-96` |
| CTCQ respq（完成跟踪队列） | **16** | `cmplt[5:0]` 完成位 | `ct_ciu_ctcq.v:514`（`respq_vld[15:0]`） |
| CTCQ AC bus | 55 位 | `{addr[39:0],4'b1000,1'b0,respq_id[3:0],1'b0,4'b1111}` | `ct_ciu_ctcq.v:1016-1018` |
| VB AW 项 | **2** | `vb_aw_bus`(68 位 AW) + `vb_w_bus`(535 位 W) | `ct_ciu_vb.v:219`（`vb_aw_vld[1:0]`）、`ct_ciu_vb.v:374-412` |

**aim/cmplt 的 6 位含义**（`ct_ciu_ctcq_reqq_entry.v:96`、`ct_ciu_ctcq.v:1396`）：

```
位 [5]: L2     [4]: EBIU    [3]:核3   [2]:核2   [1]:核1   [0]:核0
```

`aim`（aim = 目标）标记这个 CTC/DVM 操作要点名哪些目标；`cmplt` 跟踪它们是否都完成了。

---

## 4. CTC 与 MOESI Owned 态

### 4.1 问题

核 1 持有脏行（M 态），核 0 要读它。最笨做法：核 1 先把脏行**写回内存**变干净，核 0 再**从内存读**——两次访存。

### 4.2 O 态如何省掉访存

**MOESI 的 O（Owned）态**让核 1 不必写回内存就能共享脏行：

- 核 1 把脏行状态从 M **降级为 O**：仍持有脏数据、仍负责最终写回，但**允许核 0 拿一份 Shared 副本**。
- 核 0 经 CIU 的 **CTCQ** 直接从核 1 拿数据，**内存完全没被读/写**。
- 脏数据的“拥有权 + 写回责任”留在 O 态的核 1 手里，等它将来真要逐出时才写回内存（那时进 VB，见 §9）。

相比 MESI（无 O 态，共享脏行必须先写回），MOESI 用 O 态把“共享脏行”这一常见场景的两次访存压缩成一次核间直传。

---

## 5. CTCQ 请求队列 reqq

reqq 有 8 项（`ct_ciu_ctcq_reqq_entry.v`），每项是一个简单的有效位 + 完成位结构，而非多态 FSM：

```verilog
// ct_ciu_ctcq_reqq_entry.v:95-107
reg [39:0] reqq_addr;     // CTC 传输地址
reg [5 :0] reqq_aim;      // 目标位图（L2+EBIU+4核）
reg        reqq_vld;      // 项有效
reg        resp_done;     // 对应 respq 已完成
```

生命周期（`ct_ciu_ctcq_reqq_entry.v:174-194`）：

```verilog
assign reqq_pop_en = reqq_vld & resp_done & ...;   // 有效 且 响应完成
// 创建：reqq_create_en → reqq_vld<=1 (行 189-190)
// 释放：reqq_pop_en   → reqq_vld<=0 (行 191-192)
```

`resp_done` 由对应的 respq 项全部完成后回灌（`reqq_resp_done_x`，行 50/72）。即：reqq 记“要做什么”，respq 记“做完了没”，两者配对。

8 项由 one-hot 创建指针轮转分配（`ct_ciu_ctcq.v:899-909`）。

---

## 6. CTCQ 响应队列 respq

respq 有 16 项（`ct_ciu_ctcq_respq_entry.v`），每项跟踪一个 CTC/DVM 操作的多目标完成情况：

```verilog
// ct_ciu_ctcq_respq_entry.v:52-57
reg respq_l2c_cmplt;   // L2 完成
reg respq_ebiu_cmplt;  // EBIU 完成
reg respq_piu0_cmplt;  // 核0 完成
reg respq_piu1_cmplt;  // 核1
reg respq_piu2_cmplt;  // 核2
reg respq_piu3_cmplt;  // 核3
```

**初始化技巧**（`ct_ciu_ctcq.v:1396`）：

```verilog
assign respq_create_cmplt_init[5:0] = ~ctc_dvm_aim[5:0];
```

创建时把完成位初始化为 `~aim`——**没被点名的目标视为“已完成”**。这样只需等被点名的目标各自把自己那位置 1，当 6 位全 1 时整项 pop。无需为不同目标数写特殊逻辑。

```verilog
// 全部完成才 pop
assign respq_pop_en = respq_l2c_cmplt & respq_ebiu_cmplt
                    & respq_piu3_cmplt & respq_piu2_cmplt
                    & respq_piu1_cmplt & respq_piu0_cmplt & respq_vld;
```

> respq（16）比 reqq（8）深，因为一个请求可能扇出多个目标完成跟踪，且 DVM 同步要跟踪更多 outstanding。

---

## 7. CTC 数据流：核间直传绕过内存

以“核 0 读核 1 持有的脏行，触发 CTC”为例（结合 §4-§6）：

```
① 核0 的相干读在 SAB 侦听核1，发现核1 持有脏数据(M/O)
② SAB/CTCQ 决定走 CTC：在 reqq 分配一项，记 addr、aim(点名核0 接收、核1 提供)
③ respq 分配一项，cmplt 初始化为 ~aim（未点名目标预置完成）
④ CTCQ 经 PIU 的 AC 通道向相关核广播：
     acbus = {addr[39:0], 4'b1000, 1'b0, respq_id[3:0], 1'b0, 4'b1111}
     (snoop=4'b1111 标识这是 CTC/DVM 类，ct_ciu_ctcq.v:1016-1018)
⑤ 核1 经 CD 通道把脏数据回送 CIU；核0 经 R 通道收到该数据
     —— 数据在核间直传，内存全程未被访问
⑥ 各目标完成后把自己的 cmplt 位置1，respq 全 1 → pop
     → reqq.resp_done=1 → reqq pop，CTC 事务结束
```

关键：第 ⑤ 步数据路径是“拥有者核 → CIU → 请求者核”，DDR 完全没参与。脏数据仍由 O 态的核 1 负责将来写回（届时走 VB）。

---

## 8. DVM 同步

CTCQ 还兼管 **DVM（Distributed Virtual Memory）**——多核 TLB/分支预测器维护的广播同步（如 TLBI 广播、同步、完成）。`ct_ciu_ctcq.v` 把 DVM 操作经 EBIU 的 AR 通道广播出去，snoop 字段区分（`ct_ciu_ctcq.v:1309-1311`）：

```verilog
// dvm_comp(完成) snoop = 4'b1110
// dvm_sync(同步) snoop = 4'b1111
// dvm_op  (操作) snoop = 4'b1111
```

DVM 与 CTC 复用同一套 reqq/respq 多目标跟踪机制（aim/cmplt 位图），因为两者都是“一个请求扇出到多个核、等全部完成”的模式。barrier 完成经 `ctcq_piuX_bar_cmplt` 回报（`ct_ciu_ctcq.v:650`）。DVM 功能可由 CSR `ciu_chr2_dvm_dis` 关闭（`ct_ciu_regs.v:454`）。

---

## 9. VB：CIU 侧逐出/写回缓冲

VB 处理“L2C/SNB 要把脏行写回内存”的写回数据流。它有 **2 个 AW 项**（`ct_ciu_vb.v:219` 的 `vb_aw_vld[1:0]`，2 个 `ct_ciu_vb_aw_entry` 实例 `ct_ciu_vb.v:374-412`）。

### 9.1 来源仲裁

VB 接收 4 个来源的写回：L2C bank0/bank1、SNB0、SNB1。用 one-hot 轮转指针分配项（`ct_ciu_vb.v:344-348`）：

```verilog
vb_aw_create_ptr[1:0] <= {vb_aw_create_ptr[0], vb_aw_create_ptr[1]};  // 2 项轮转
assign vb_aw_create_sel[1:0] = {2{vb_aw_create_en}} & vb_aw_create_ptr[1:0];
```

授权回送各源（`ct_ciu_vb.v:321-323`）：

```verilog
assign vb_snb0_aw_grant   = vb_aw_create_en && vb_aw_sel[0];
assign vb_l2c0_vctm_grant = vb_aw_create_en && vb_aw_sel[2];  // victim 授权
```

### 9.2 AW + W 分离缓冲

每个 VB 项分两部分（`ct_ciu_vb_aw_entry.v`）：
- **AW 部分**（68 位）：写地址、ID、size 等控制；
- **W 部分**（535 位）：整条 cache line 写数据（4×128 位 + strobe + ID + INCR 标志）。

送 EBIU 时，535 位 line 按 128 位/拍拆分输出（`ct_ciu_vb.v:512-515`），`wlast` 由 INCR 标志或拍计数器决定（`ct_ciu_vb.v:529`）：

```verilog
assign ebiu_wlast = vb_w_pop_bus[INCR1] ? 1'b1 : (wdata_cnt[1:0] == 2'b11);
```

---

## 10. VB 的地址依赖检测

VB 写回的地址若与 SNB 正在处理的某条侦听地址相同，必须告知 EBIU 做依赖排序，否则可能写回旧数据 / 读到将被覆盖的数据。VB 项做地址比较（`ct_ciu_vb_aw_entry.v:224`）：

```verilog
assign vb_snb_addr_hit_x = vb_aw_vld && (ebiuif_vb_index[7:0] == vb_aw_bus[ADDR_13:ADDR_6]);
```

汇总成依赖标志输出（`ct_ciu_vb.v:542`）：

```verilog
assign vb_ebiuif_addr_depd = |vb_snb_addr_hit[1:0];
```

EBIU 收到 `vb_ebiuif_addr_depd` 后会把该写回与冲突的读/侦听串行化。这与 SAB 的 DEPD 机制（`02_ciu_snb_sab.md` §12）异曲同工——同地址访存必须保序。

---

## 11. 设计取舍小结

| 决策 | 内容 | 为什么 | 出处 |
|------|------|--------|------|
| MOESI O 态 + CTC | 脏行降级 O 后核间直传 | 省掉“写回+再读”两次访存 | `ct_ciu_ctcq.v` |
| reqq/respq 分离 | reqq(8)记请求，respq(16)记完成 | 解耦“做什么”与“做完没”，支持多目标扇出 | `ct_ciu_ctcq_reqq/respq_entry.v` |
| cmplt 初值 = ~aim | 未点名目标预置完成 | 无需为不同目标数写特殊逻辑，全 1 即 pop | `ct_ciu_ctcq.v:1396` |
| respq 比 reqq 深 | 16 vs 8 | 一请求扇出多完成跟踪 + DVM outstanding | `ct_ciu_ctcq.v:514` |
| CTC/DVM 复用机制 | 同一 aim/cmplt 位图 | 都是“扇出多核等全完成”模式 | `ct_ciu_ctcq.v:1309-1396` |
| AC snoop=1111 | CTC/DVM 类标识 | 与普通侦听(CS/CI/MI)区分 | `ct_ciu_ctcq.v:1018` |
| VB 仅 2 项 | 写回缓冲浅队列 | 写回不在关键路径，2 项足够缓冲 | `ct_ciu_vb.v:219` |
| AW/W 分离缓冲 | 地址 68 位 + 数据 535 位 | 地址先到可先仲裁，数据按拍流出 | `ct_ciu_vb_aw_entry.v` |
| VB 地址依赖检测 | 与 SNB index 比较 | 同地址写回/侦听保序，防数据冒险 | `ct_ciu_vb.v:542` |

---

*文档覆盖 `ct_ciu_ctcq.v`、`ct_ciu_ctcq_reqq_entry.v`、`ct_ciu_ctcq_respq_entry.v`、`ct_ciu_vb.v`、`ct_ciu_vb_aw_entry.v` 的全部核心逻辑（合计约 3843 行）。*
