# C910 BIU 总线接口单元 模块详细教学文档

> 本文档基于 OpenC910 RTL 源码（`C910_RTL_FACTORY/gen_rtl/biu/rtl/`），
> 覆盖 BIU 全部 8 个文件，自底向上讲清 BIU 的职责、结构、协议与设计取舍。
> 学完本文档，应能回答：BIU 是什么、核里的访存请求如何进入 CIU、
> ACE 一致性通道如何在核侧落地，以及 RTL 实际怎样使用 AXI ID 分类返回数据。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [典型读缺失路径：核 → BIU → CIU → L2/下级存储](#4-典型读缺失路径核--biu--ciu--l2下级存储)
5. [BIU 与 CIU 的分工](#5-biu-与-ciu-的分工)
6. [ACE 的五个读写通道与三个一致性通道](#6-ace-的五个读写通道与三个一致性通道)
7. [通用思想①：AXI ID 是响应分类标签](#7-通用思想axi-id-是响应分类标签)
8. [通用思想②：ACE 让一个端口演主+从两角](#8-通用思想ace-让一个端口演主从两角)
9. [BIU 子模块串讲](#9-biu-子模块串讲)
10. [关键设计决策汇总](#10-关键设计决策汇总)
11. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 BIU 是什么

BIU（Bus Interface Unit，总线接口单元）是每个 C910 核面向 CIU 的**一致性总线端点**。
核内部所有"出核"的访存动作——取指缺失、数据缺失填充（linefill）、
非缓存读写、设备访问、cache line 回写（victim/store）、原子/独占访问——
最终都要经过 BIU 打成 ACE 总线事务，送往核外的 CIU（Coherent Interface Unit，
一致性互联）。CIU 后续可把事务送往 L2、系统总线或其它目标；是否最终访问 DDR
取决于地址、缓存命中和 SoC 集成，不能仅由 BIU RTL 推断。

反方向，外部对本核 cache 的一致性侦听请求（snoop），也由 BIU 的 snoop 通道接进来，
转交核内的 LSU 处理。

一句话定位：

> **BIU = 核内 IFU/LSU 请求与 CIU 侧一致性总线通道之间的字段整理、浅缓冲、
> 仲裁、返回分类和局部时钟门控层。**

它本身不实现 cache 阵列或地址翻译，也不维护 D-Cache 一致性状态。它会执行少量
协议相关分类，例如给 IFU 读拼接 ID、按 `awsnoop/awdomain/awbar` 选择写握手类别，
但 cache tag 查询、脏状态判断和一致性状态转换仍在 LSU/CIU。BIU 的缓冲记录的是
尚未穿过某个本地接口边界的数据，不是覆盖全部 outstanding 事务的完整事务表。

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
                            ▼  ACE 风格 `pad_*` 接口
              ┌──────────────────────────────┐
              │   CIU（片上一致性互联）       │
              └───────────────┬──────────────┘
                              ▼
                       ┌────────────┐      ┌────────────┐
                       │  L2 Cache  │      │ 系统总线/内存 │
                       └────────────┘      └────────────┘
```

### 1.2 为什么需要 BIU

核内的总线和片上互联是两个世界：

- **接口风格不同**：核内 LSU/IFU 用的是私有握手信号（如 `lsu_biu_ar_dp_req`、
  `ifu_biu_rd_req`），CIU 侧使用 AXI/ACE 风格的 AR/R/AW/W/B 与 AC/CR/CD 通道。
  BIU 负责把私有信号映射成 ACE 信号，并补齐 ACE ID/snoop/domain 等字段。
- **多请求源要仲裁**：读有 LSU 和 IFU 两个源，写有 store 和 victim 两路，
  CSR 有 CP0 和 HPCP 两个源。共享输出位置每拍只能选择一组字段，必须仲裁或选路。
- **通道需要解耦**：请求方和接收方可能在不同周期就绪。BIU 用 1～2 项局部缓冲和
  写来源队列保持 `valid` 及其 payload，直到相应边界完成握手。
- **返回需要分类**：读返回携带 AXI ID。BIU 识别两个固定 IFU ID，其余 ID 送 LSU；
  它不维护“每个 ID 对应一个唯一在途请求”的查找表。
- **少量异步输入需要同步**：当前 `ct_biu_top` 没有实例化
  `ct_biu_bus_io_async`，ACE 数据通道寄存器使用 `coreclk` 或
  `forever_coreclk` 的门控派生时钟。明确的双触发器同步只出现在外部中断和调试请求上；
  门控时钟本身不是 CDC。

如果没有 BIU，上述职责会散落进 IFU/LSU/CP0。BIU 把它们集中成一个边界层。

### 1.3 阅读握手信号时必须区分的四件事

后文统一使用以下含义，避免把“请求”“允许”和“完成”混为一谈：

| 层次 | 判定 | 精确含义 |
|------|------|----------|
| 请求意图 | `valid=1` 或模块私有 `req=1` | 源当前提供一笔请求；单独看到它不表示对端已接收 |
| 接收能力 | `ready=1`、某些名为 `grnt` 的容量信号 | 目的端当前有空位；若没有同时检查源 `valid/req`，它不是一次授权事件 |
| 边界接受 | `valid && ready` | 当前时钟边沿前满足握手，边沿后双方才可推进相应状态 |
| 事务完成 | R/B/CR/CD 等响应的有效握手，或模块专用 `cmplt` | 事务越过后续系统路径后的结果；通常晚于地址请求被接受 |

`*_dp_req`/`*_valid_gate` 主要用于提前打开数据寄存器时钟或选择 payload。
它们可以在真正 `valid` 之前出现，不能单独统计成已发请求。

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

### 2.3 与 `pad_*` 一致性总线边界的接口

这里的 `pad` 是 RTL 端口命名，表示 BIU 的模块/集成边界。在 OpenC910 顶层中它通常连接
CIU，并不自动表示封装引脚、片外总线或 DDR 控制器。

| 通道 | 输出（`biu_pad_*`） | 输入（`pad_biu_*`） |
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
| `coreclk` / `forever_coreclk` | 两路顶层时钟输入；`forever_coreclk` 供 AC/唤醒相关状态使用，但其系统级门控/电源性质需看上层 |
| `cpurst_b` | 复位（低有效） |
| `cp0_biu_icg_en` | 接到 `gated_clk_cell.module_en`；工艺 ICG 分支中为 1 会使时钟不依赖 `local_en` 而开启 |
| `biu_yy_xx_no_op` | `!read_busy && !write_busy` 的本地空闲观察；不覆盖 snoop，也不是全系统 outstanding=0 的证明 |
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
| **写来源队列可表示项数** | **12 项** | `write_channel.v:651`（`parameter W_FIFO_ENTRY = 12`）、`:215`（`reg [11:0] bus_arb_w_fifo`）；RTL 无显式 full 反压 |
| 写地址缓冲 | store 1 项 + victim 1 项 | `write_channel.v:233-260` |
| 写数据缓冲 | store/victim/round 各 1 项（3 buffer） | `write_channel.v:261-281`（pop_sel 3 位 one-hot，`:750`） |
| 写响应缓冲 | 1 项；另有 `back_valid/back_pending` 确认状态 | `write_channel.v:213-219` |
| 侦听 AC/CR/CD 缓冲 | 各 **2 项** ping-pong | `snoop_channel.v:92-120` |
| 门控时钟单元数 | 12 个 `gated_clk_cell`（lowpower）+ 2 个（other_io_sync 的 l2reg in/out；apbif 版本被注释掉） | `lowpower.v`、`other_io_sync.v` |
| 中断同步级数 | 2 级触发器（ff1→ff2） | `other_io_sync.v:323-353` |

> 注意：BIU 没有集中编码的大型 FSM，但 valid、创建/弹出选择位、写来源位移队列以及
> RACK/BACK 的 valid/pending 共同构成了分布式协议状态。“没有大 FSM”不等于
> “没有状态”或“无需协议不变量”。

---

## 4. 典型读缺失路径：核 → BIU → CIU → L2/下级存储

以一次 **D-Cache 读缺失填充（linefill）** 为例，走完全程：

```
① LSU 发现 load miss，向 BIU 发读请求
   lsu_biu_ar_req / lsu_biu_ar_dp_req=1, ar_id=5'b00xxx (linefill 类)
                      │
② BIU req_arbiter 仲裁（读优先级 LSU > IFU）
   选中 LSU，生成统一 ar 总线（araddr/arid/arsnoop/ardomain...）
   req_arbiter.v:434-498
                      │
③ BIU read_channel 在 arvalid && arready 时把请求装入两个地址槽之一
   随后在 biu_pad_arvalid && pad_biu_arready 时交给 CIU 侧
   read_channel.v:291-303
                      │
④ CIU 接收 ar，按 ACE 域/snoop 类型决定：
   - 若可一致：向其它核发 snoop，向 L2 查询
   - 选路到 L2 Cache
                      │
⑤ L2 命中则可返回；未命中时由 CIU/L2/系统接口继续访问下级存储
                      │
⑥ 下级数据经系统路径 → CIU → BIU
   pad_biu_rvalid/rdata[127:0]/rid/rlast
                      │
⑦ pad_biu_rvalid && biu_pad_rready 时，BIU 把当前 beat 装入两个 R 槽之一
   精确路由规则：rid==10000/10001 → IFU；其它 → LSU；
   rid[4:3]==00 只用于识别需要观察 LSU linefill-ready 的 LSU 返回
   read_channel.v:535-536, 708-712
                      │
⑧ 末拍被目的端消费后，BIU 生成 RACK（read acknowledge）
   read_channel.v:542-570
                      │
⑨ LSU 后续完成 linefill、cache 更新和等待 load 的唤醒；这些动作不在 BIU RTL 内
```

写路径并非读路径的简单镜像：LSU → `req_arbiter`（写只有 LSU 一类上游，但分
store/victim 两路）→ `write_channel` 的独立 AW 缓冲、W 数据缓冲和 12 项来源队列
→ CIU；B 通道返回后 BIU 生成 BACK。EVICT 地址事务没有 W 数据，因此不会进入写来源队列。

**关键观察**：BIU 在每个通道只放 1～2 项（写 FIFO 12 项是例外，因为写要排序），
说明 BIU 自身不是完整的缺失跟踪器。浅缓冲能吸收有限的 ready 波动，但“能否长期
不丢事务”还依赖上游保持 valid/payload、写来源队列不溢出以及 CIU 侧协议约束，
不能只由缓冲深度推导。

---

## 5. BIU 与 CIU 的分工

初学者最容易混的就是 BIU 和 CIU。一句话区分：

> **BIU 是"每核一个"的端口；CIU 是"全片一个"的互联枢纽。**

| 维度 | BIU（核内） | CIU（核外，片上互联） |
|------|------------|----------------------|
| 数量 | 每个核 1 个 | 全芯片 1 个（多核共享） |
| 职责 | 字段整理、浅缓冲、本核读仲裁、返回分类、转发 snoop | 多请求者选路、一致性事务组织、snoop 分发、访问 L2/系统接口 |
| 一致性决策 | 不维护 cache 一致性状态；执行少量字段分类并转发 AC/CR/CD | 根据请求类型和系统状态组织一致性动作 |
| 看到的范围 | 只看本核 | 看到所有核 + L2 + 总线 |
| 类比 | 一个国家的"驻外大使馆" | "联合国总部" |

BIU 大多透传 LSU/IFU 给出的 `domain/snoop/bar/unique` 字段，但并非完全不读这些字段：
`write_channel` 用 `awsnoop`、`awdomain` 和 `awbar[0]` 生成 `aw_ws`，从两组
`awready` 中选择一组；它还识别 EVICT 并阻止该事务进入 W 来源队列。真正的 cache
状态查询、snoop 目标选择和状态转换不在 BIU 中。

---

## 6. ACE 的五个读写通道与三个一致性通道

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

- **数据宽度 128 bit**（`top.v:317` 等）。若某个事务确实传输完整 64B line，
  数据量对应 4 个 128-bit beat；并非每个 R/W/CD 事务都固定为 4 拍。
- **AXI ID 5 bit**（`top.v:418`）。BIU 只对两个固定 IFU ID 做精确匹配，
  不能简化成“最高位统一区分所有请求源”。
- **读响应 rresp**：见 `read_channel.v:702-707` 注释——
  `[3]=IsShared`（其它核也有该行，仅 LSU 关心）、`[2]=PassDirty`（不支持）、
  `[1]=Error`、`[1:0]=00 OKAY / 01 EXOKAY`（独占访问成功）。
- **写域区分 ws/wns**：`write_channel.v:415-420` 用 `aw_ws` 判断本次写是否
  "可写共享域"（WriteUnique/WriteLineUnique + Inner Shareable，或带 barrier），
  据此选 `pad_biu_ws_awready` 或 `pad_biu_wns_awready` 两套握手。这正是 ACE 比 AXI 多出来的复杂度。

---

## 7. 通用思想①：AXI ID 是响应分类标签

这是贯穿 BIU 的第一个核心思想。它与 ROB IID、MSHR 标签都属于“携带标识再关联结果”
这一类方法，但编码唯一性、生命周期和排序规则并不相同，不能视为完全同一种硬件结构。

### 7.1 问题

ACE/AXI 允许多个事务**同时在途**，而且响应可以**乱序返回**——
你先发 A 读再发 B 读，B 的数据可能先回来。那么数据回来时，怎么知道它属于哪个请求、该送给谁？

### 7.2 本 RTL 的做法：用 ID 分类返回源和返回类型

发请求时带上 ID，响应带回相同 ID。这里的 ID 不一定对每一笔 outstanding 事务都唯一：
AXI 允许多个事务复用同一 ID，同时要求同 ID 事务遵守协议规定的顺序。BIU 没有
ID→请求项查找表，而是做固定组合分类：精确匹配 `10000/10001` 送 IFU，其余送 LSU；
对 LSU 返回再用 `[4:3]==00` 识别 linefill 流控类别。

C910 的 5 位 ID 编码（**真实出处**）：

| ID 值 | 含义 | 出处 |
|------|------|------|
| `5'b10000` | IFU refill（取指缺失填充） | `req_arbiter.v:465` 拼 `{4'b1000, ifu_biu_rd_id}`；`read_channel.v:529` |
| `5'b10001` | IFU prefetch（预取） | 同上，`ifu_biu_rd_id=1` |
| 除 `10000/10001` 外 | 在此模块中都按 LSU 返回处理；实际合法编码由 LSU/系统协议约束 | `req_arbiter.v:480` 透传 LSU ID；`read_channel.v:531-536` |
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
| BIU/ACE | **AXI ID** | 本 RTL 主要用固定编码分类 IFU/LSU 与 LSU linefill；排序还受总线协议约束 |
| ROB | **IID（指令 ID）** | 把乱序完成的执行结果对回指令、按序退休 |
| LSU MSHR | **MSHR entry id** | 把乱序回来的 cache line 对回等待的 load |

需要特别注意：只有 R/B 通道携带读写 ID；AC/CR/CD 侦听路径在该模块中不使用
同样的 ID 查找。因而“发请求挂名牌”不能概括全部三个通道。

---

## 8. 通用思想②：ACE 让一个端口演主+从两角

第二个核心思想：**同一个 BIU 端口，要同时扮演两个角色。**

```
角色 A：Master（主） —— 本核主动访存
  "我要读/写这块内存" → AR/AW/W/R/B 五通道
  对应 read_channel + write_channel

角色 B：被侦听端 —— 本核被动响应一致性请求
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

`biu_xx_snoop_vld`（`snoop_channel.v:549`）是一个粗粒度 snoop 活动锁存：
AC 被 BIU 接受时置位，在 `lsu_biu_ac_empty && CR缓冲空 && CD缓冲空` 时清零。
清零条件虽没有直接写 BIU AC valid，但 LSU 的 `lsu_biu_ac_empty` 不是简单的
“SNQ entry 为空”：它等于
`!(biu_lsu_ac_req || lsu_snq_not_empty || lsu_sdb_not_empty ||
lsu_ctcq_not_empty)`。所以尚在 BIU 缓冲的 AC 会通过 `biu_lsu_ac_req` 阻止清零，
进入 LSU 后再由各非空状态接续保持。这个跨模块链解释了活动标志为何不会在正常
AC 交接缝隙提前撤销；它仍不能被解释成所有系统 snoop 的精确 outstanding 计数。

---

## 9. BIU 子模块串讲

| 文件 | 行数 | 角色 | 详见 |
|------|------|------|------|
| `ct_biu_top.v` | 1254 | 顶层，例化全部子模块 + 连线 | 本文 |
| `ct_biu_req_arbiter.v` | 567 | 读/写请求仲裁（读 LSU>IFU；写分 store/victim） | [03](03_biu_arbiters_lp.md) |
| `ct_biu_read_channel.v` | 740 | AR+R 浅缓冲，按固定 ID 编码做 IFU/LSU 路由 | [01](01_biu_read_write.md) |
| `ct_biu_write_channel.v` | 1078 | AW+W+B 通道，12 项写 FIFO、store/victim 排序 | [01](01_biu_read_write.md) |
| `ct_biu_snoop_channel.v` | 563 | AC+CR+CD 通道，转发侦听给 LSU SNQ | [02](02_biu_snoop.md) |
| `ct_biu_csr_req_arbiter.v` | 101 | CSR 仲裁（CP0>HPCP），访问 L2 CSR | [03](03_biu_arbiters_lp.md) |
| `ct_biu_lowpower.v` | 360 | 每通道门控时钟 + `no_op` 生成 | [03](03_biu_arbiters_lp.md) |
| `ct_biu_other_io_sync.v` | 445 | 中断/调试双触发器同步、配置寄存和 L2 CSR 边界寄存 | [03](03_biu_arbiters_lp.md) |

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
中断/调试 ──▶ other_io_sync（2 级同步）
time/RVBA/APB base/计数控制 ──▶ 单级寄存或直连（不能笼统称为 2 级同步）
```

---

## 10. 关键设计决策汇总

| 决策 | C910 的选择 | 为什么 | 出处 |
|------|------------|--------|------|
| 每通道缓冲深度 | 读/侦听各 2 项 ping-pong | RTL 事实是可容纳两项并解耦局部握手；“一定足够”需由系统流控证明 | `read_channel.v:133-184`, `snoop_channel.v:92-120` |
| 12 项写来源队列 | 每个有数据的 AW 接受事件压入 store/victim 来源位，末个 W beat 接受时弹出 | 队列保持 AW 接受顺序与 W 数据源顺序；无显式 full 反压，依赖 outstanding 上界不超过 12 | `write_channel.v:651-695` |
| AXI ID 5 位 | IFU 使用 `10000/10001`，LSU ID 透传 | 固定组合分类，不是逐事务唯一分配器 | `req_arbiter.v:465-480` |
| 读选择 | `lsu_biu_ar_dp_req=1` 时屏蔽 IFU | 这是 RTL 优先关系；“哪类请求更迫切”属于可能的设计动机 | `req_arbiter.v:433-435` |
| 写选择 | victim AW valid 时输出 victim 字段 | 这是固定选择关系；资源释放动机是架构推断 | `write_channel.v:450-513` |
| victim 域约束 | victim AW/W 本地清除固定观察 WNS ready | LSU 必须保证 victim 始终属于 WNS；严格 victim 优先也可能阻塞已等待的 store | `write_channel.v:523,685,832` |
| CSR 选择 | `cp0_biu_sel=1` 时输出 CP0，否则输出 HPCP | 组合优先关系；响应源没有内部 owner 锁存 | `csr_req_arbiter.v:78-96` |
| RACK/BACK 生成 | BIU 内部产生 valid/pending 状态 | 当前顶层把两个 ready 恒置 1；pending/backpressure 路径在此集成中不会形成满状态 | `top.v:1187-1188` |
| 异步单比特输入 | 中断/调试用 2 级 FF 同步 | 降低亚稳态传播概率，不等于消除风险 | `other_io_sync.v:323-382` |
| 局部时钟门控 | 例化 14 个 `gated_clk_cell`（lowpower 12 个、CSR 2 个） | 未定义 `C910_USE_TSMC28_ICG` 时 `clk_out=clk_in`；DC flist 定义该宏后使用工艺 ICG | `clk/rtl/gated_clk_cell.v:37-57`, `backend/flist/ct_top_dc.f:6` |

---

## 本章小结

BIU 位于 IFU/LSU 与外部 ACE 接口之间，核心职责是把核内请求转换为 AR/AW/W 事务，把 R/B 返回重新分类给原始请求方，并通过 AC/CR/CD 通道承接外部一致性探测。它采用的是浅边界缓冲，而不是集中保存所有未完成事务的完整 outstanding 表：读和 snoop 通道只保存少量完整 payload，12 项写队列也只记录 store/victim 数据来源，事务身份、顺序和完成条件仍分布在 IFU、LSU、CIU 以及总线协议约束中。读返回通过 AXI ID 分类，外部 snoop 则沿 AC 请求与 CR/CD 响应方向流动，这两套机制共同服务一致性，但不共享同一种重排模型。

写通道是 BIU 中状态组合最密集的部分，因为它必须同时区分 ACE 的 write-shareable 与 write-non-shareable 域、保持 store 与 victim 各自顺序，并保证 AW 地址和 W 数据来源正确配对。RTL 还能直接证明 LSU 请求对 IFU 请求、victim 对 store 等固定选择关系，但“哪类请求更迫切”“是否为了尽早释放 cache 行”等设计动机，不能仅凭多路选择器优先级反推。类似地，缓冲深度和代码规模也不能直接证明面积、频率或验证难度，这些结论需要综合、时序和运行测量结果支持。阅读后续章节时，应沿“请求创建、边界缓冲、总线握手、返回分类、源端释放”这一完整生命周期追踪，而不是把 BIU 当成独立完成全局事务管理的单一控制器。
