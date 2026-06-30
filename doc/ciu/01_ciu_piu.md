# C910 CIU PIU 模块详细教学文档

> RTL 文件：`ct_piu_top.v`（约 2732 行）、`ct_piu_other_io.v`（约 236 行）
>
> 相关文件：`ct_piu_top_dummy.v`（约 503 行）、`ct_piu_top_dummy_device.v`（约 171 行）、`ct_piu_other_io_dummy.v`（约 98 行）、`ct_piu_other_io_sync.v`（约 353 行）
>
> 上层：`ct_ciu_top.v`（实例化 5 个 PIU，见 `00_ciu_overview.md`）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键编码](#3-参数与关键编码)
4. [PIU 的角色：BIU 与 CIU 之间的适配器](#4-piu-的角色biu-与-ciu-之间的适配器)
5. [AR 通道：读请求与 bank 路由](#5-ar-通道读请求与-bank-路由)
6. [AW 通道：写请求](#6-aw-通道写请求)
7. [AC 通道：侦听请求下发到核](#7-ac-通道侦听请求下发到核)
8. [CR 通道：侦听响应回收](#8-cr-通道侦听响应回收)
9. [CD 通道：侦听数据回收与打包](#9-cd-通道侦听数据回收与打包)
10. [Barrier FSM](#10-barrier-fsm)
11. [dummy 与 dummy_device 变体](#11-dummy-与-dummy_device-变体)
12. [ct_piu_other_io](#12-ct_piu_other_io)
13. [设计取舍小结](#13-设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

`ct_piu_top`（Processor Interface Unit）是**每个核接入 CIU 的适配器**。一个核的 BIU 通过一组 ACE-lite + 侦听通道的信号（顶层 pad 名 `ibiuN_pad_*`）连到对应 PIU。PIU 的工作可以拆成两条对称的方向：

- **上行（核 → CIU）**：接收核发出的读地址（AR）、写地址（AW）、写数据（W）请求，按地址把读/写请求路由到正确的 SNB bank（或 CTCQ/NCQ），并做 outstanding 跟踪。
- **下行（CIU → 核）**：接收来自 SAB/CTCQ 的**侦听请求**，经 **AC 通道**下发给核；再把核回来的**侦听响应（CR）**和**侦听脏数据（CD）**收集、缓冲、打包，回送给发起侦听的 SAB 项。

PIU 内部本身不做一致性判断（那是 SAB 的事），它是**通道仲裁 + FIFO 缓冲 + 协议打包**的集合。每条通道都配独立 FIFO，使多个一致性事务能流水重叠。

### 1.2 位置

```
核N BIU ──ibiuN_pad_*──► PIU N ──► (上行) AR→SNB0/1 or NCQ/CTCQ
                              │       AW→SNB0/1 or NCQ
                              │       W →SNB/NCQ
                              │
                              ◄── (下行) AC←SNB0/SNB1/CTCQ 侦听
                                  CR→SAB  CD→SAB(经 pkb 打包)
```

C910 顶层实例化 5 个：piu0/piu1 用真实 `ct_piu_top`，piu2/piu3 用 `ct_piu_top_dummy`，piu4 用 `ct_piu_top_dummy_device`（`ct_ciu_top.v:2041-2664`）。

---

## 2. 端口说明

PIU 端口极多（按 `ct_piu_top.v` 端口表分组，仅列代表性信号）。

### 2.1 来自/送往核 BIU（经顶层 `ibiuN_pad_*` 转换为 `ibiu_ciu_*` / `ciu_ibiu_*`）

| 信号 | 方向 | 位宽 | 含义 | file:line |
|------|------|------|------|-----------|
| `ibiu_ciu_arsnoop` | in | [3:0] | 核读请求的 snoop 类型（ReadShared/ReadUnique…） | `ct_piu_top.v:214` |
| `ibiu_ciu_arcache` | in | [3:0] | 读请求 cache 属性（区分 cacheable/non-cacheable） | `ct_piu_top.v:207` |
| `ibiu_ciu_awsnoop` | in | [2:0] | 核写请求 snoop 类型 | `ct_piu_top.v:227` |
| `ibiu_ciu_awcache` | in | [3:0] | 写请求 cache 属性 | `ct_piu_top.v:220` |
| `ibiu_ciu_acready` | in | — | 核已准备好接收 AC 侦听 | `ct_piu_top.v:203` |
| `ibiu_ciu_crvalid` / `crresp` | in | — / [4:0] | 核回送的侦听响应（CR 通道） | `ct_piu_top.v:237-238` |
| `ibiu_ciu_cdvalid` / `cddata` | in | — / [127:0] | 核回送的侦听脏数据（CD 通道） | `ct_piu_top.v:233,236` |
| `ibiu_ciu_back` / `rack` | in | — | 写应答/读应答握手 | `ct_piu_top.v:231,239` |
| `ciu_ibiu_acaddr` | out | [39:0] | 下发给核的侦听地址 | `ct_piu_top.v:281` |
| `ciu_ibiu_acsnoop` | out | [3:0] | 下发给核的侦听类型 | `ct_piu_top.v:283` |
| `ciu_ibiu_acprot` | out | [2:0] | 侦听属性（含 inst 位） | `ct_piu_top.v:282` |
| `ciu_ibiu_acvalid` | out | — | 侦听有效 | `ct_piu_top.v:284` |
| `ciu_ibiu_crready` | out | — | PIU 可接收核的 CR | `ct_piu_top.v:1554` |

### 2.2 与 SNB0 / SNB1（相干 bank）

| 信号 | 方向 | 含义 | file:line |
|------|------|------|-----------|
| `piu_snb0_ar_req` / `piu_snb0_ar_bus[70:0]` | out | 路由到 bank0 的读请求 | `ct_piu_top.v:324,943` |
| `piu_snb1_ar_req` / `piu_snb1_ar_bus[70:0]` | out | 路由到 bank1 的读请求 | `ct_piu_top.v:335,944` |
| `piu_snb0_aw_req` / `piu_snb1_aw_req` | out | 写请求路由 | `ct_piu_top.v:1158-1159` |
| `snb0_piu_acbus[54:0]` / `snb0_piu_acvalid` | in | bank0 发来的侦听请求 | `ct_piu_top.v:257-258` |
| `snb1_piu_acbus[54:0]` / `snb1_piu_acvalid` | in | bank1 发来的侦听请求 | `ct_piu_top.v:269-270` |
| `piu_snb0_ac_grant` / `piu_snb1_ac_grant` | out | AC 仲裁授权回给 bank | `ct_piu_top.v:322,333` |
| `piu_snb0_cr_req` / `piu_snb0_cr_bus[9:0]` | out | 把 CR 响应送回 bank0 的 SAB | `ct_piu_top.v:1544,1550` |

### 2.3 与 CTCQ / NCQ

| 信号 | 方向 | 含义 | file:line |
|------|------|------|-----------|
| `ctcq_piu_acbus[54:0]` / `ctcq_piu_acvalid` | in | CTCQ 发来的侦听请求（第 3 个 AC 来源） | `ct_piu_top.v:194-195` |
| `piu_ctcq_ac_grant` | out | CTCQ AC 仲裁授权 | `ct_piu_top.v:307` |
| `piu_ctcq_cr_req` / `piu_ctcq_cr_bus` | out | CR 响应送回 CTCQ | `ct_piu_top.v:1546,1552` |

> dummy_device（piu4）还有到 NCQ 的非相干通道，见第 11 节。

---

## 3. 参数与关键编码

PIU 把请求/响应打包成定宽总线，参数定义了各字段在总线里的位置。

### 3.1 AR 总线字段（`ct_piu_top.v:820-860`）

```verilog
parameter ADDRW       = `PA_WIDTH;   // 物理地址宽度（40）
parameter ARSOOP_0   = 23;  ARSOOP_3 = 26;   // arsnoop[3:0]
parameter ARDOMAIN_0 = 27;  ARDOMAIN_1 = 28; // 一致性域
parameter ARBAR_0    = 29;  ARBAR_1  = 30;   // barrier 位
parameter ARSNB0     = 31;  ARSNB1   = 32;   // ◄ 该读请求该进哪个 SNB bank
parameter ARNCQ      = 33;                   // ◄ 该读请求进 NCQ(非相干)
parameter ARCTC      = 34;                   // ◄ 该读请求进 CTCQ
parameter ARADDR_0   = 35;  ARADDR_H = 74;   // 地址字段
parameter ARWIDTH    = 75;
parameter ARWIDTH_SNB = 71;  // 送给 SNB 的窄总线
```

注意 `ARSNB0/ARSNB1/ARNCQ/ARCTC` 这 4 个 one-hot 位，是 PIU 解析核请求后打上的**路由标签**：决定这个读请求送往哪条下游路径。

### 3.2 AC 总线字段（侦听请求，55 位）

```
AC bus[54:0] = { addr[39:0], xid[4:0]=4'b0001+snb1, sid[4:0], inst, acsnoop[3:0] }
```
该格式在 SAB 侧组装（`ct_ciu_snb_sab_entry.v:1411-1416`）。PIU 内对应的解码参数有 `AC_SNOOP_3:AC_SNOOP_0`、`AC_INST`、`AC_ADDR_H:AC_ADDR_0`、`AC_SID_4:AC_SID_0`、`AC_XID_4:AC_XID_0`（用于 `ct_piu_top.v:1471-1473,1578-1580`）。

### 3.3 其它通道宽度

| 参数 | 值 | 用途 | file:line |
|------|----|----|----------|
| `CR_WIDTH` | 5 | CR 响应位宽（crresp[4:0]） | `ct_piu_top.v:1508` |
| `CRR_WIDTH` | 10 | CR 回送总线（sid[4:0]+crresp[4:0]） | `ct_piu_top.v:1512` |
| `RSPQ_WIDTH` | 12 | CR 响应队列项宽 | `ct_piu_top.v:1566` |
| `CD_IDF_WIDTH` | 9 | CD SID FIFO 项宽 | `ct_piu_top.v:1607` |
| `PKB_WIDTH` | 158 | CD 包缓冲项宽（含 wstrb+werr+data[127:0]+控制） | `ct_piu_top.v:1693` |

---

## 4. PIU 的角色：BIU 与 CIU 之间的适配器

C910 的核与外部用 **ACE-lite + 侦听三通道** 协议交互。PIU 做三件“翻译”工作：

1. **协议字段提取**：从核的 AR/AW 信号里读出 snoop 类型、cache 属性、地址，判断这是相干读、相干写、非相干访问、还是 CTC，并打上路由标签（§3.1）。
2. **下游路由**：按标签把请求送到 SNB0/SNB1（相干，按地址 bit[6] 分 bank）或 NCQ（非相干）或 CTCQ。
3. **侦听三通道收发**：把上游 SAB/CTCQ 的侦听请求经 AC 发给核，把核的 CR/CD 收回。每条通道都有 FIFO，支持多事务流水。

---

## 5. AR 通道：读请求与 bank 路由

### 5.1 bank 选择：地址 bit[6]

C910 把相干侦听分成两个并行 bank（SNB0/SNB1），按 **cache line 地址的 bit[6]** 区分奇偶行（`ct_piu_top.v:876-877`）：

```verilog
assign ibiu_ciu_arxid[SNB1] = !ibiu_ciu_arbar[0] && !ar_ctc && ar_ca && ibiu_ciu_araddr[6];
assign ibiu_ciu_arxid[SNB0] = !ibiu_ciu_arbar[0] && !ar_ctc && ar_ca && !ibiu_ciu_araddr[6];
```

- `ar_ca`：cacheable（相干）请求才进 SNB；非相干进 NCQ。
- `arbar[0]`：barrier 事务单独走（不进 bank）。
- `araddr[6]==1` → SNB1，`==0` → SNB0。两个 bank 的 SAB 各自独立，奇偶 line 的一致性事务可以真正并行。

### 5.2 路由与窄总线

打好标签后，AR 请求经 dfifo 流出，按标签产生 bank 请求（`ct_piu_top.v:929-944`）：

```verilog
assign ar_req_snb1 = ar_req_bus[ARSNB1];
assign ar_req_snb0 = ar_req_bus[ARSNB0];
assign piu_snb1_ar_req = ar_dfifo_sab1_req;
assign piu_snb0_ar_req = ar_dfifo_sab0_req;
// 送给 SNB 的是窄总线（71 位），去掉了 CTC/NCQ/SNB 路由标签
assign piu_snb0_ar_bus[ARWIDTH_SNB-1:0] = {ar_req_bus[ARWIDTH-1:ARADDR_0], ar_req_bus[ARBAR_1:0]};
```

---

## 6. AW 通道：写请求

写地址通道与读对称，同样按 `awaddr[6]` 选 bank（`ct_piu_top.v:1004-1005`）：

```verilog
assign ibiu_ciu_awxid[SNB1] = !ibiu_ciu_awbar[0] && aw_ca && ibiu_ciu_awaddr[6];
assign ibiu_ciu_awxid[SNB0] = !ibiu_ciu_awbar[0] && aw_ca && !ibiu_ciu_awaddr[6];
```

写请求产生 `piu_snb0_aw_req` / `piu_snb1_aw_req`（`ct_piu_top.v:1158-1159`）。写应答时还要回送 SID（`aw_grant_sid`，`ct_piu_top.v:1188`）以匹配 outstanding 写。写数据（W 通道）与写回的脏数据 CD 一起，最终经 SAB 写进 L2C 或经 VB 写回内存。

---

## 7. AC 通道：侦听请求下发到核

这是 PIU 下行的第一段：把上游来的侦听送给核。

### 7.1 三源仲裁

一个 PIU 的 AC 通道可能同时被 **SNB0、SNB1、CTCQ** 三个来源请求（`ct_piu_top.v:1413-1427`）：

```verilog
assign snb0_ac_valid = snb0_piu_acvalid && !ctcq_mask_snb;
assign snb1_ac_valid = snb1_piu_acvalid && !ctcq_mask_snb;
assign ac_valid[2:0] = {ctcq_piu_acvalid, snb1_ac_valid, snb0_ac_valid};
assign ac_idle       = !ac_dfifo_full;

ct_prio #(.NUM(3)) x_ct_piu_ac_prio(...);   // 3 选 1 优先级仲裁 → ac_sel
```

- **`ctcq_mask_snb`**：CTC 是两段连续传输，中间不能被 SNB 侦听打断。一旦 CTCQ 被授权且 acbus 标记还有后续，就锁住 SNB（`ct_piu_top.v:1491-1494`），保证 CTC 原子性。

授权信号反馈给来源（`ct_piu_top.v:1482-1484`）：

```verilog
assign piu_snb0_ac_grant = ac_idle && ac_sel[0];
assign piu_snb1_ac_grant = ac_idle && ac_sel[1];
assign piu_ctcq_ac_grant = ac_idle && ac_sel[2];
```

### 7.2 AC DFIFO 与下发

被选中的 acbus 进入 2 深的 AC DFIFO，再下发给核（`ct_piu_top.v:1442-1473`）：

```verilog
assign ac_dfifo_create_bus = {AC_WIDTH{ac_sel[2]}} & ctcq_piu_acbus |
                             {AC_WIDTH{ac_sel[1]}} & snb1_piu_acbus |
                             {AC_WIDTH{ac_sel[0]}} & snb0_piu_acbus;
// pop 时拆出最终给核的侦听信号
assign ciu_ibiu_acvalid      = ac_req_vld;
assign ciu_ibiu_acsnoop[3:0] = ac_req_bus[AC_SNOOP_3:AC_SNOOP_0];
assign ciu_ibiu_acprot[2:0]  = {2'b00, ac_req_bus[AC_INST]};
assign ciu_ibiu_acaddr       = ac_req_bus[AC_ADDR_H:AC_ADDR_0];
```

每发出一个 AC，就在 **RSPQ（CR 响应队列）**里登记一项（`ct_piu_top.v:1575-1597`），记录该侦听的 xid/sid/addr，用来把将来回来的 CR 响应配对回正确的 SAB 项。RSPQ 深 12。

---

## 8. CR 通道：侦听响应回收

核处理完侦听后，经 CR 通道回 `crresp[4:0]`。PIU 的处理链（`ct_piu_top.v:1514-1552`）：

1. **CR DFIFO**（深 2）缓冲核来的 crresp：`cr_dfifo_create_en = ibiu_ciu_crvalid && !cr_dfifo_full`（行 1514）；`ciu_ibiu_crready = !cr_dfifo_full`（行 1554）。
2. **配对**：从 RSPQ pop 出当初登记的 xid/sid，与 cr_dfifo pop 的 crresp 拼成回送总线 `piu_xx_cr_bus = {sid[4:0], crresp[4:0]}`（行 1548）。
3. **回送来源**：按 xid 判断这条侦听原本来自哪（`ct_piu_top.v:1544-1546`）：
   ```verilog
   assign piu_snb0_cr_req = rspq_pop_xid[1] && !rspq_pop_xid[0] && cr_req_vld;
   assign piu_snb1_cr_req = rspq_pop_xid[1] &&  rspq_pop_xid[0] && cr_req_vld;
   assign piu_ctcq_cr_req = rspq_pop_xid[4] && cr_req_vld;
   ```
4. **是否有数据**：若 crresp 的 DT 位（数据传输位）置位，说明核会经 CD 通道送脏数据，于是在 **CD SID FIFO**（深 8）登记一项，等数据到来配对（`ct_piu_top.v:1615-1639`）。

---

## 9. CD 通道：侦听数据回收与打包

当被侦听的核持有脏数据时，经 CD 通道回送 128 位/拍的数据。PIU 把它打包成统一格式再交给 SAB 写 L2C/写回。

- **CD SID FIFO**（深 8，`ct_piu_top.v:1626`）：记录每段脏数据应配的 sid/xid/addr。`cd_pkb_sid_bus[11:0]` 把这些 ID 字段拼好（`ct_piu_top.v:1685-1688`），区分数据归属哪个 SNB bank（`cd_xid_snb0/cd_xid_snb1`）。
- **包缓冲 PKB**（PKB_WIDTH=158，`ct_piu_top.v:1693-1706`）：把 128 位数据 + 16 位 wstrb + werr + last + xid + addr + sid 打成一个完整“包”。PKB 有多个分立时钟门控（data0~data3，`ct_piu_top.v:1748-1817`），按拍只点亮正在写的那段，省功耗。
- **优先级 CD > WD**（`ct_piu_top.v:1819`）：侦听脏数据写回比普通写数据优先，尽快释放被侦听核。

最终这些打好的数据经 SAB 写进 L2C（脏数据进 L2）或转给 CTC 的请求者。

---

## 10. Barrier FSM

PIU 内有一个 3 位的 barrier 状态机 `bar_cur_state` / `bar_next_state`（`ct_piu_top.v:352,356`）。Barrier（内存屏障）事务（`arbar/awbar` 位）不进 SNB bank，而是单独排序，确保屏障前后的访存顺序在多核间正确可见。屏障完成通过 `ctcq_piuX_bar_cmplt` 等信号回报（CTCQ 侧 `ct_ciu_ctcq.v:650`）。

---

## 11. dummy 与 dummy_device 变体

### 11.1 ct_piu_top_dummy（piu2/piu3）

OpenC910 默认只造 2 核，piu2/piu3 用 `ct_piu_top_dummy`（503 行）占位。它**不接真实核**，所有上行请求输出钉成无效、所有侦听响应钉成“立即完成”。目的：

- 让一致性位图保持 **4 位固定宽度**（`cp[3:0]`、`smpen[3:0]`、`snp_req_en[3:0]`），上层逻辑无需为不同核数改宽度；
- 当 SAB 算出的 `cp_after_mask` 在这两位上恰好为 0（因为 `smpen[3:2]=0`，`ct_ciu_regs.v:634,639`），对应的 `snp2/snp3` 子 FSM 立即 `cmplt`，不影响 `snp_cmplt`。

### 11.2 ct_piu_top_dummy_device（piu4）

piu4 用 `ct_piu_top_dummy_device`（171 行），是**非相干设备入口**。它接外部主设备/DMA：

- 这类访问**不缓存、不侦听**，PIU4 直接把请求送进 NCQ（非相干队列）；
- 它不参与 MOESI、不出现在 cp 位图里——这正是它叫 “device” 且与 piu0-3 分开的原因。

### 11.3 ct_piu_other_io_dummy

对应 piu2/piu3 的杂项 IO 桩（98 行），把 L2PMP/regs/中断相关输出全部钉成 0/无效（`ct_piu_other_io_dummy.v:73-91`），如 `piu_regs_sel=0`、`piu_xx_regs_no_op=1`、`pready_l2pmp_x=1`。

---

## 12. ct_piu_other_io

`ct_piu_other_io`（236 行）是每个真实核 PIU 旁边的“杂项 IO”模块，处理与一致性主数据流无关、但属于该核的杂项信号（`ct_piu_other_io.v:17-120`）：

- **中断转发**：把 sysio 来的各级中断（`sysio_piu_me_int/ms_int/mt_int/se_int/ss_int/st_int`）转成 `ciu_ibiu_*_int` 给核；
- **CSR 通路**：核的 CSR 访问（`ibiu_ciu_csr_sel/csr_wdata`）与回读（`ciu_ibiu_csr_rdata[127:0]`）；
- **L2PMP（L2 物理内存保护）的 APB 从口**：`psel_l2pmp_x`、`x_prdata_l2pmp[31:0]`；
- **HPCP（高性能计数器）/debug 接口**：`piu_regs_hpcp_cnt_en`、`ciu_ibiu_dbgrq_b`、`ciu_ibiu_hpcp_l2of_int`；
- **低功耗/调试模式**：`piu_sysio_lpmd_b`、`piu_sysio_jdb_pm`。

它内部只是实例化了 `ct_piu_other_io_sync`（353 行，做跨时钟域同步，`ct_piu_other_io.v:179-230`），本身无逻辑——纯连线 + 子模块例化。

---

## 13. 设计取舍小结

| 决策 | 内容 | 为什么 |
|------|------|--------|
| 每核一个 PIU | piu0-3 相干 + piu4 设备 | 适配器解耦，核侧协议变化不污染 CIU 内部 |
| 路由标签 ARSNB0/1/NCQ/CTC | PIU 解析请求后打 one-hot 标签 | 下游只看标签转发，逻辑简单 |
| 地址 bit[6] 分 bank | 奇偶 cache line 进不同 SNB | 双 bank 并行，翻倍侦听吞吐 |
| AC 三源优先仲裁 | SNB0/SNB1/CTCQ 经 ct_prio 选 1 | 一个核的 AC 通道串行下发，需仲裁 |
| ctcq_mask_snb 锁 | CTC 传输中锁住 SNB 侦听 | 保证 CTC 两段传输原子、不被打断 |
| 每通道独立 FIFO | AC/CR/CD/RSPQ/PKB 各自缓冲 | 多事务流水重叠，提高吞吐 |
| CD > WD 优先 | 侦听脏数据写回优先于普通写 | 尽快释放被侦听核，降低侦听延迟 |
| dummy 钉 0 占位 | piu2/3 用 dummy 模块 | 位图固定 4 位宽，不为核数改逻辑 |
| 分段时钟门控 | PKB data0~3 各自门控 | 按拍只点亮在写的那段，省功耗 |

---

*文档覆盖 `ct_piu_top.v` 全部约 2732 行逻辑，并涵盖 `ct_piu_other_io.v`、`ct_piu_top_dummy.v`、`ct_piu_top_dummy_device.v`、`ct_piu_other_io_dummy.v` 的角色与差异。*
