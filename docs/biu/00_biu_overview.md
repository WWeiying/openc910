# C910 BIU 总线接口单元 模块详细教学文档

> 本文档基于 OpenC910 RTL 源码（`C910_RTL_FACTORY/gen_rtl/biu/rtl/`），
> 覆盖 BIU 全部 8 个文件，自底向上讲清 BIU 的职责、结构、协议与设计取舍。
> 学完本文档，应能回答：BIU 是什么、核里的访存请求如何一路出到 DDR、
> ACE 一致性怎么落地、为什么用 AXI ID 跟踪乱序事务。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [完整外出路径：核 → BIU → CIU → L2 → DDR](#4-完整外出路径核--biu--ciu--l2--ddr)
5. [BIU 与 CIU 的分工](#5-biu-与-ciu-的分工)
6. [ACE 协议与五通道](#6-ace-协议与五通道)
7. [通用思想①：AXI ID = 乱序事务的名牌](#7-通用思想axi-id--乱序事务的名牌)
8. [通用思想②：ACE 让一个端口演主+从两角](#8-通用思想ace-让一个端口演主从两角)
9. [BIU 子模块串讲](#9-biu-子模块串讲)
10. [关键设计决策汇总](#10-关键设计决策汇总)
11. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 BIU 是什么

BIU（Bus Interface Unit，总线接口单元）是 **每个 C910 核对外的唯一 ACE 主端口**。
核内部所有"出核"的访存动作——取指缺失、数据缺失填充（linefill）、
非缓存读写、设备访问、cache line 回写（victim/store）、原子/独占访问——
最终都要经过 BIU 打成 ACE 总线事务，送往核外的 CIU（Coherent Interface Unit，
一致性互联），再由 CIU 经 L2 Cache 访问 DDR。

反方向，外部对本核 cache 的一致性侦听请求（snoop），也由 BIU 的 snoop 通道接进来，
转交核内的 LSU 处理。

一句话定位：

> **BIU = 核与片上总线之间的"协议转换+缓冲+仲裁+跨时钟域同步"层。**

它本身不做缓存、不做地址翻译、不判断一致性状态；它只是忠实地把核内五花八门的请求
"翻译"成标准 ACE 事务，把事务的 outstanding 状态用少量缓冲管起来，并把响应分发回正确的请求源。

```
        ┌────────────────────────────────────────────┐
        │                  C910 核                     │
        │  IFU(取指)         LSU(访存)        CP0/HPCP  │
        │    │ rd            │ ar/aw/w/b/snoop  │ csr   │
        │    └──────┬────────┴────────┬─────────┘       │
        │           ▼                 ▼                 │
        │   ┌────────────────────────────────────┐     │
        │   │              BIU                    │     │
        │   │  req_arbiter  csr_req_arbiter       │     │
        │   │  read_ch  write_ch  snoop_ch        │     │
        │   │  lowpower  other_io_sync            │     │
        │   └───────────────┬────────────────────┘     │
        └───────────────────┼──────────────────────────┘
                            ▼  ACE (pad 接口)
              ┌──────────────────────────────┐
              │   CIU（片上一致性互联）       │
              └───────────────┬──────────────┘
                              ▼
                       ┌────────────┐      ┌────────┐
                       │  L2 Cache  │─────▶│  DDR   │
                       └────────────┘      └────────┘
```

### 1.2 为什么需要 BIU

核内的总线和片上互联是两个世界：

- **时序域不同**：核跑 `coreclk`，总线/CIU 可能跑别的频率。跨域信号必须同步，
  否则会出亚稳态。BIU 的 `other_io_sync`（中断/调试）和各通道的门控时钟就在处理这件事。
- **接口风格不同**：核内 LSU/IFU 用的是私有握手信号（如 `lsu_biu_ar_dp_req`、
  `ifu_biu_rd_req`），片外要求标准 ACE 五通道（AR/R/AW/W/B + AC/CR/CD）。
  BIU 负责把私有信号映射成 ACE 信号，并补齐 ACE ID/snoop/domain 等字段。
- **多请求源要仲裁**：读有 LSU 和 IFU 两个源，写有 store 和 victim 两路，
  CSR 有 CP0 和 HPCP 两个源。同一时刻总线只能发一个，必须仲裁。
- **outstanding 要管理**：ACE 允许多个事务在途、乱序返回。BIU 用 AXI ID 给每个
  在途事务挂名牌，靠 ID 把乱序回来的数据送回正确的请求源。

如果没有 BIU，上述四件事会散落进 IFU/LSU/CP0，既重复又难维护。BIU 把它们集中成一个"边界层"。

---

## 2. 端口说明

BIU 顶层 `ct_biu_top.v` 端口极多（输入约 130、输出约 100），按"对端"分组理解即可。
下表给出每组的代表信号与方向（核侧视角）。

### 2.1 与 IFU 的接口（取指读）

| 信号 | 方向 | 含义 |
|------|------|------|
| `ifu_biu_rd_req` / `ifu_biu_rd_addr` / `ifu_biu_rd_id` | IFU→BIU | 取指读请求/地址/ID（`top.v:135,128,132`） |
| `ifu_biu_rd_len/size/burst/cache/prot/snoop/domain/user` | IFU→BIU | ACE 属性字段 |
| `biu_ifu_rd_grnt` | BIU→IFU | 请求被仲裁授权（`top.v:35`） |
| `biu_ifu_rd_data` / `biu_ifu_rd_data_vld` / `biu_ifu_rd_id` / `biu_ifu_rd_last` / `biu_ifu_rd_resp` | BIU→IFU | 返回 128bit 数据/有效/ID/末拍/响应（`top.v:33-38`） |
| `ifu_biu_r_ready` | IFU→BIU | IFU 能接收数据 |

### 2.2 与 LSU 的接口（读/写/写回/侦听响应）

| 信号组 | 方向 | 含义 |
|------|------|------|
| `lsu_biu_ar_*`（addr/id/len/size/snoop/domain/lock/...） | LSU→BIU | 读地址通道请求（`top.v:142-156`） |
| `lsu_biu_aw_st_*` | LSU→BIU | 写地址：store（WMB，写合并缓冲）一路（`top.v:158-172`） |
| `lsu_biu_aw_vict_*` | LSU→BIU | 写地址：victim（VB，回写缓冲）一路（`top.v:173-187`） |
| `lsu_biu_w_st_*` / `lsu_biu_w_vict_*` | LSU→BIU | 写数据：store 路 / victim 路（128bit，`top.v:194-203`） |
| `biu_lsu_r_*`（data/id/last/resp/vld） | BIU→LSU | 读返回数据 |
| `biu_lsu_b_*`（id/resp/vld） | BIU→LSU | 写响应 B 通道 |
| `biu_lsu_ar_ready` / `biu_lsu_aw_vb_grnt` / `biu_lsu_aw_wmb_grnt` / `biu_lsu_w_*_grnt` | BIU→LSU | 各通道授权 |
| `lsu_biu_cr_*` / `lsu_biu_cd_*` / `lsu_biu_ac_*` / `biu_lsu_ac_*` | 双向 | 侦听响应/侦听数据/侦听地址（见 [02_biu_snoop.md](02_biu_snoop.md)） |

### 2.3 与 pad（片外 ACE 总线）的接口

| 通道 | 输出（biu_pad_*） | 输入（pad_biu_*） |
|------|------|------|
| AR 读地址 | `araddr/arid/arlen/arsize/arburst/arsnoop/ardomain/arvalid/...` | `arready` |
| R 读数据 | `rready/rack` | `rdata/rid/rlast/rresp/rvalid` |
| AW 写地址 | `awaddr/awid/awsnoop/awunique/awvalid/...` | `awready`（区分 ws/wns） |
| W 写数据 | `wdata/wstrb/wlast/wns/wvalid/...` | `wready`（区分 ws/wns） |
| B 写响应 | `bready/back` | `bid/bresp/bvalid` |
| AC 侦听地址 | `acready` | `acaddr/acprot/acsnoop/acvalid` |
| CR 侦听响应 | `crresp/crvalid` | `crready` |
| CD 侦听数据 | `cddata/cdlast/cdvalid/cderr` | `cdready` |

### 2.4 与 CP0/HPCP/HAD（CSR、中断、调试）的接口

| 信号组 | 方向 | 含义 |
|------|------|------|
| `cp0_biu_sel/op/wdata` → `biu_cp0_cmplt/rdata` | CP0↔BIU | CP0 访问 L2 CSR |
| `hpcp_biu_sel/op/wdata` → `biu_hpcp_cmplt/rdata` | HPCP↔BIU | 性能计数器访问 L2 CSR |
| `pad_biu_*_int`（me/ms/mt/se/ss/st） → `biu_cp0_*_int` | pad→BIU→CP0 | 各类中断（同步后） |
| `pad_biu_dbgrq_b` → `biu_had_sdb_req_b` | pad→BIU→HAD | 调试请求 |
| `pad_xx_time` → `biu_hpcp_time` | pad→BIU | 系统计时器 |
| `pad_core_hartid` → `biu_cp0_coreid` / `biu_had_coreid` | pad→BIU | 核 ID |

### 2.5 时钟/复位/低功耗

| 信号 | 含义 |
|------|------|
| `coreclk` / `forever_coreclk` | 核时钟 / 不被门控的核时钟（`top.v:114,121`） |
| `cpurst_b` | 复位（低有效） |
| `cp0_biu_icg_en` | 时钟门控总开关 |
| `biu_yy_xx_no_op` | BIU 全空闲，可进低功耗（`top.v:113`） |
| `pad_yy_icg_scan_en` | 扫描时旁路门控 |

---

## 3. 参数与关键寄存器

BIU 的"硬规格"散落在各子模块，汇总如下（均带 file:line，绝不臆造）：

| 规格 | 取值 | 出处 |
|------|------|------|
| 物理地址宽度 | `PA_WIDTH`（C910 为 40 位，端口 `[39:0]`） | `read_channel.v:75`、`top.v:257` 等 |
| 数据总线宽度 | **128 bit** | `top.v:317,386,404`（`rdata/wdata/cddata` 均 `[127:0]`） |
| 写选通宽度 | 16 bit（128/8） | `top.v:325`（`wstrb[15:0]`） |
| **AXI ID 宽度** | **5 bit**（`[4:0]`） | `top.v:418`（`arid[4:0]`）、`req_arbiter.v:230` |
| 读地址缓冲深度 | **2 项**（buf0/buf1 ping-pong） | `read_channel.v:133-158` |
| 读数据缓冲深度 | **2 项** | `read_channel.v:173-184` |
| **写 FIFO 深度** | **12 项** | `write_channel.v:651`（`parameter W_FIFO_ENTRY = 12`）、`:215`（`reg [11:0] bus_arb_w_fifo`） |
| 写地址缓冲 | store 1 项 + victim 1 项 | `write_channel.v:233-260` |
| 写数据缓冲 | store/victim/round 各 1 项（3 buffer） | `write_channel.v:261-281`（pop_sel 3 位 one-hot，`:750`） |
| 写响应缓冲 | 1 项 + rack/back pending 1 位 | `write_channel.v:217-219` |
| 侦听 AC/CR/CD 缓冲 | 各 **2 项** ping-pong | `snoop_channel.v:92-120` |
| 门控时钟单元数 | 12 个 `gated_clk_cell`（lowpower）+ 2 个（other_io_sync 的 l2reg in/out；apbif 版本被注释掉） | `lowpower.v`、`other_io_sync.v` |
| 中断同步级数 | 2 级触发器（ff1→ff2） | `other_io_sync.v:323-353` |

> 注意：BIU 几乎没有"大状态机"，关键寄存器都是这些小缓冲的 valid/select 位。
> 这是 BIU 与 IFU（大量 SRAM + 状态机）最显著的风格差异——BIU 是**轻量边界层**。

---

## 4. 完整外出路径：核 → BIU → CIU → L2 → DDR

以一次 **D-Cache 读缺失填充（linefill）** 为例，走完全程：

```
① LSU 发现 load miss，向 BIU 发读请求
   lsu_biu_ar_req / lsu_biu_ar_dp_req=1, ar_id=5'b00xxx (linefill 类)
                      │
② BIU req_arbiter 仲裁（读优先级 LSU > IFU）
   选中 LSU，生成统一 ar 总线（araddr/arid/arsnoop/ardomain...）
   req_arbiter.v:434-498
                      │
③ BIU read_channel 把 ar 装入 cur_raddr_buf（2 项之一）
   通过 biu_pad_ar* 握手发到 pad（片外）
   read_channel.v:291-303
                      │
④ CIU 接收 ar，按 ACE 域/snoop 类型决定：
   - 若可一致：向其它核发 snoop，向 L2 查询
   - 选路到 L2 Cache
                      │
⑤ L2 命中则返回；未命中则 L2 向 DDR 控制器发请求
                      │
⑥ DDR 返回 line，经 L2 → CIU → pad → BIU
   pad_biu_rvalid/rdata[127:0]/rid/rlast
                      │
⑦ BIU read_channel 把数据装入 cur_rdata_buf（2 项之一）
   按 rid 判断去向：rid[4:3]==2'b00 → linefill → 送 LSU
   read_channel.v:535-536, 708-712
                      │
⑧ 末拍数据后 BIU 自发 RACK（read acknowledge）给总线
   read_channel.v:542-570
                      │
⑨ LSU 收到 line，写入 D-Cache，唤醒等待的 load
```

写回（victim/store）路径对称：LSU → req_arbiter（写只有 LSU 一源，但分 store/victim 两路）
→ write_channel 的 AW/W FIFO → pad → CIU → L2 → DDR；完成后 B 通道返回，BIU 自发 BACK。

**关键观察**：BIU 在每个通道只放 1～2 项（写 FIFO 12 项是例外，因为写要排序），
说明 BIU 自身不是"深缓冲蓄水池"——真正的 MSHR/缺失队列在 LSU 里，
真正的乱序排队在 CIU/L2 里。BIU 只保证"不丢拍、能背靠背、能跨域"。

---

## 5. BIU 与 CIU 的分工

初学者最容易混的就是 BIU 和 CIU。一句话区分：

> **BIU 是"每核一个"的端口；CIU 是"全片一个"的互联枢纽。**

| 维度 | BIU（核内） | CIU（核外，片上互联） |
|------|------------|----------------------|
| 数量 | 每个核 1 个 | 全芯片 1 个（多核共享） |
| 职责 | 协议转换、缓冲、本核请求仲裁、跨时钟域同步 | 多核一致性裁决、广播 snoop、选路到 L2/外设 |
| 一致性决策 | **不做**，只转发 snoop 给 LSU | **做**，决定谁该被 snoop、谁有最新数据 |
| 看到的范围 | 只看本核 | 看到所有核 + L2 + 总线 |
| 类比 | 一个国家的"驻外大使馆" | "联合国总部" |

BIU 对 ACE 域信号（`ardomain`/`arsnoop`/`awsnoop`/`awunique`）只是**透传或补齐**，
真正解读这些字段、决定一致性动作的是 CIU。例如 victim 回写用 `WriteBack`/`Evict`，
store 用 `WriteUnique`/`WriteLineUnique`——这些 snoop 编码由 LSU 给出、BIU 转发，CIU 执行。

---

## 6. ACE 协议与五通道

ACE（AXI Coherency Extensions）= AXI4 + 一致性扩展。它在 AXI 的 5 个读写通道之外，
增加了 3 个一致性通道，总共 **8 个通道**：

```
       主动发起（本核当 Master，主动访存）
  ┌─────────────────────────────────────────┐
  │  AR  读地址 ──▶                           │
  │  R   读数据 ◀──                           │  read_channel.v
  │  AW  写地址 ──▶                           │
  │  W   写数据 ──▶                           │  write_channel.v
  │  B   写响应 ◀──                           │
  └─────────────────────────────────────────┘
       被动响应（本核当 Slave，响应侦听）
  ┌─────────────────────────────────────────┐
  │  AC  侦听地址 ◀── （CIU 问：你有这行吗?） │
  │  CR  侦听响应 ──▶ （本核答：有/无/脏）    │  snoop_channel.v
  │  CD  侦听数据 ──▶ （若脏，把数据给出）    │
  └─────────────────────────────────────────┘
```

C910 BIU 的 ACE 具体规格：

- **数据宽度 128 bit**（`top.v:317` 等），一个 64B cache line 需 4 拍 burst。
- **AXI ID 5 bit**（`top.v:418`），最高位区分请求源（见第 7 节）。
- **读响应 rresp**：见 `read_channel.v:702-707` 注释——
  `[3]=IsShared`（其它核也有该行，仅 LSU 关心）、`[2]=PassDirty`（不支持）、
  `[1]=Error`、`[1:0]=00 OKAY / 01 EXOKAY`（独占访问成功）。
- **写域区分 ws/wns**：`write_channel.v:415-420` 用 `aw_ws` 判断本次写是否
  "可写共享域"（WriteUnique/WriteLineUnique + Inner Shareable，或带 barrier），
  据此选 `pad_biu_ws_awready` 或 `pad_biu_wns_awready` 两套握手。这正是 ACE 比 AXI 多出来的复杂度。

---

## 7. 通用思想①：AXI ID = 乱序事务的名牌

这是贯穿 BIU 的第一个核心思想，也是和 CPU 其它部件（ROB、MSHR）**完全同一套方法论**。

### 7.1 问题

ACE/AXI 允许多个事务**同时在途**，而且响应可以**乱序返回**——
你先发 A 读再发 B 读，B 的数据可能先回来。那么数据回来时，怎么知道它属于哪个请求、该送给谁？

### 7.2 解法：给每个在途事务挂一个唯一"名牌"——AXI ID

发请求时带上 ID，响应回来时总线把同一个 ID 原样带回。BIU 拿 ID 一查，就知道：
①这是哪个请求；②该送回哪个源（IFU 还是 LSU）；③是不是 linefill。

C910 的 5 位 ID 编码（**真实出处**）：

| ID 值 | 含义 | 出处 |
|------|------|------|
| `5'b10000` | IFU refill（取指缺失填充） | `req_arbiter.v:465` 拼 `{4'b1000, ifu_biu_rd_id}`；`read_channel.v:529` |
| `5'b10001` | IFU prefetch（预取） | 同上，`ifu_biu_rd_id=1` |
| `5'b0xxxx` | LSU 各类事务（linefill / 非缓存 / 独占 …） | `req_arbiter.v:480` 透传 `lsu_biu_ar_id` |
| `rid[4:3]==2'b00` | linefill 类（LSU 关心 ready） | `read_channel.v:535-536` |

read_channel 拿到返回数据后，纯靠 ID 判定去向（`read_channel.v:528-536`）：

```verilog
cur_rdata_is_ifu = rvalid && (rid==5'b10000 || rid==5'b10001); // 高位是 IFU
cur_rdata_is_lsu = rvalid && !cur_rdata_is_ifu;                 // 否则给 LSU
cur_rdata_is_linefill = rvalid && (rid[4:3]==2'b00);            // linefill 需等 LSU ready
```

### 7.3 同一方法在 CPU 各处复用

| 部件 | "名牌"叫什么 | 作用 |
|------|------------|------|
| BIU/ACE | **AXI ID** | 把乱序返回的总线数据对回请求源 |
| ROB | **IID（指令 ID）** | 把乱序完成的执行结果对回指令、按序退休 |
| LSU MSHR | **MSHR entry id** | 把乱序回来的 cache line 对回等待的 load |

记住这一条，BIU 的读/写/侦听三通道就都不神秘了：它们本质都是
"发请求挂名牌 → 等响应认名牌 → 按名牌分发"的小状态机。

---

## 8. 通用思想②：ACE 让一个端口演主+从两角

第二个核心思想：**同一个 BIU 端口，要同时扮演两个角色。**

```
角色 A：Master（主） —— 本核主动访存
  "我要读/写这块内存" → AR/AW/W/R/B 五通道
  对应 read_channel + write_channel

角色 B：Slave（从） —— 本核被动响应侦听
  "别的核问我有没有某行" → AC/CR/CD 三通道
  对应 snoop_channel
```

为什么必须两角？因为一致性是**对称**的：

- 当本核要读一块"可能被别的核改过"的内存（Shareable），CIU 会去 **snoop 别的核**——
  此时别的核在演"从"角色，把数据/状态吐出来。
- 反过来，当别的核读一块本核 cache 里有脏副本的内存，CIU 就来 **snoop 本核**——
  此时轮到本核演"从"角色，由 snoop_channel 把请求转给 LSU，
  LSU 查 D-Cache，经 CR 报状态、（若脏）经 CD 把数据交出去。

所以一个核既是"访存发起者"（主），又是"一致性数据的潜在提供者"（从）。
BIU 把这两个角色干净地拆到两组通道、两组缓冲里：

- **主角色** 的状态在 `read_channel`/`write_channel`，请求源是核内（IFU/LSU）。
- **从角色** 的状态在 `snoop_channel`，请求源是核外（CIU 经 AC 通道）。

`biu_xx_snoop_vld`（`snoop_channel.v:549`）就是"本核当前正被侦听"的标志位，
供核内 ICG（时钟门控）判断"虽然核空闲，但因为在响应侦听，不能熄火"。

---

## 9. BIU 子模块串讲

| 文件 | 行数 | 角色 | 详见 |
|------|------|------|------|
| `ct_biu_top.v` | 1254 | 顶层，例化全部子模块 + 连线 | 本文 |
| `ct_biu_req_arbiter.v` | 567 | 读/写请求仲裁（读 LSU>IFU；写分 store/victim） | [03](03_biu_arbiters_lp.md) |
| `ct_biu_read_channel.v` | 740 | AR+R 通道，按 ID 跟踪 outstanding、IFU/LSU 路由 | [01](01_biu_read_write.md) |
| `ct_biu_write_channel.v` | 1078 | AW+W+B 通道，12 项写 FIFO、store/victim 排序 | [01](01_biu_read_write.md) |
| `ct_biu_snoop_channel.v` | 563 | AC+CR+CD 通道，转发侦听给 LSU SNQ | [02](02_biu_snoop.md) |
| `ct_biu_csr_req_arbiter.v` | 101 | CSR 仲裁（CP0>HPCP），访问 L2 CSR | [03](03_biu_arbiters_lp.md) |
| `ct_biu_lowpower.v` | 360 | 每通道门控时钟 + `no_op` 生成 | [03](03_biu_arbiters_lp.md) |
| `ct_biu_other_io_sync.v` | 445 | 中断/调试/计时器跨时钟域同步、L2 CSR 寄存 | [03](03_biu_arbiters_lp.md) |

数据流（顶层连线，`top.v`）：

```
IFU rd ──┐
         ├─▶ req_arbiter ──ar──▶ read_channel ──pad──▶ (AR/R)
LSU ar ──┘                              │
                                        └──▶ biu_lsu_r_* / biu_ifu_rd_*

LSU aw_st  ──▶ req_arbiter ──st_aw──┐
LSU aw_vict──▶ req_arbiter ──vict_aw┼─▶ write_channel ──pad──▶ (AW/W/B)
LSU w_st/w_vict ────────────────────┘

CIU AC ──pad──▶ snoop_channel ──▶ biu_lsu_ac_* (转给 LSU SNQ)
LSU cr/cd ─────▶ snoop_channel ──pad──▶ (CR/CD)

CP0 ──┐
      ├─▶ csr_req_arbiter ──▶ other_io_sync ──pad──▶ L2 CSR
HPCP ─┘

所有通道的 *_clk_en ──▶ lowpower ──▶ 各 *cpuclk（门控时钟）
中断/调试/time ──▶ other_io_sync（2 级同步）──▶ CP0/HAD
```

---

## 10. 关键设计决策汇总

| 决策 | C910 的选择 | 为什么 | 出处 |
|------|------------|--------|------|
| 每通道缓冲深度 | 读/侦听各 2 项 ping-pong | 够背靠背即可，深缓冲交给 LSU/CIU | `read_channel.v:133-184`, `snoop_channel.v:92-120` |
| 写为何用 12 项 FIFO | 写要保序（store 与 victim 顺序敏感） | AW 与 W 必须按发出顺序配对，需排队记录每拍属于 store 还是 victim | `write_channel.v:651-695` |
| AXI ID 5 位 | 高位标源、低位标类型 | 一个名牌同时编码"谁的+什么"，省查找表 | `req_arbiter.v:465` |
| 读优先级 | LSU > IFU | 数据访问在关键路径上，比取指更迫切 | `req_arbiter.v:433-435` |
| 写优先级 | victim > store | 回写释放 cache 行，避免占用阻塞填充 | `write_channel.v:482` |
| CSR 优先级 | CP0 > HPCP | 架构寄存器访问优先于性能计数器 | `csr_req_arbiter.v:78` |
| RACK/BACK 自发 | BIU 自己生成 | 异步 biu/piu 下总线不回 ack，BIU 须自补 | `read_channel.v:541`, `write_channel.v:1006` |
| 跨时钟域 | 中断/调试用 2 级 FF 同步 | 防亚稳态，标准 CDC 手法 | `other_io_sync.v:323-353` |
| 低功耗 | 每通道独立门控 + 全局 no_op | 空闲通道单独熄火，粒度细省功耗 | `lowpower.v` |

---

## 设计取舍小结

1. **BIU 是"薄"的边界层，不是"厚"的蓄水池。** 它每通道只放 1~2 项缓冲
   （写 FIFO 12 项是因为保序刚需）。真正的缺失队列在 LSU，乱序排队在 CIU/L2。
   这让 BIU 时序好、面积小、易验证。

2. **两个通用思想撑起整个 BIU**：AXI ID 当名牌解决乱序分发（与 ROB/MSHR 同源），
   ACE 主+从双角解决一致性对称性。理解这两点，三大通道一通百通。

3. **仲裁优先级反映"谁在关键路径上"**：读 LSU>IFU、写 victim>store、CSR CP0>HPCP，
   每一条都对应一个"谁更迫切/更基础"的工程判断。

4. **协议转换的复杂度集中在写通道**：ACE 的 ws/wns 域区分、store/victim 保序、
   AW-W 配对，使 write_channel 成为 BIU 最复杂的文件（1078 行）。

---

*文档覆盖 ct_biu_top.v 全部 1254 行逻辑，并综述全部 8 个 BIU 子模块。*
