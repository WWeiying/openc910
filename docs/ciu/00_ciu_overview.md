# C910 CIU 总览 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ciu/rtl/` 整个目录（37 个 `.v` 文件，约 34600 行）
>
> 顶层：`ct_ciu_top.v`（约 4144 行）
>
> 本文是 CIU 子系统的总览，建议先读本文建立全局观，再按学习路径精读各子模块文档。

---

## 目录

1. [CIU 是什么](#1-ciu-是什么)
2. [在 C910 中的位置](#2-在-c910-中的位置)
3. [5 个 PIU 端口](#3-5-个-piu-端口)
4. [子模块全景](#4-子模块全景)
5. [缓存一致性基础：MOESI 与 cp 位图](#5-缓存一致性基础moesi-与-cp-位图)
6. [Snoop Filter（侦听过滤器）](#6-snoop-filter侦听过滤器)
7. [完整侦听数据流](#7-完整侦听数据流)
8. [Cache-to-Cache（CTC）直传与 Owned 态](#8-cache-to-cachectc直传与-owned-态)
9. [Evict 通知：为什么干净行也要发](#9-evict-通知为什么干净行也要发)
10. [非相干路径与外部总线](#10-非相干路径与外部总线)
11. [关键设计决策汇总](#11-关键设计决策汇总)
12. [学习路径](#12-学习路径)

---

## 1. CIU 是什么

CIU（Coherence Interconnect Unit，一致性互联单元）是 C910 多核 SoC 的“总线管家”和“一致性裁判”。它的核心职责有四个：

1. **多核汇聚**：C910 最多 4 个核（OpenC910 默认配置实例化 2 个真实核 + 2 个 dummy 占位核），每个核通过自己的 **BIU（Bus Interface Unit）**发出读/写请求。CIU 把这些请求汇聚到一起，统一裁决、统一对外。
2. **缓存一致性**：当核 A 要读/写一条 cache line 时，CIU 必须确认别的核 B、C 是否也缓存了这一行，若有则向它们发起**侦听（snoop）**，让对方提供脏数据或者把自己的副本作废。这是 CIU 最复杂的部分，实现 **MOESI** 协议 + **侦听过滤（snoop filter）**。
3. **L2 Cache 接入**：C910 的 L2 Cache 是所有核共享的，CIU 负责把一致性请求翻译成对 L2C 的访问（读 tag、读数据、写数据、改状态）。
4. **对外 AXI 主接口**：当数据既不在任何核的 L1、也不在 L2 时，CIU 通过 **EBIU（External Bus Interface Unit）**用标准 AXI 协议去访问片外内存（DDR）或外设。

一句话概括：**CIU 站在“核的 L1 缓存”与“共享 L2 / 片外内存”之间，保证无论数据在哪个核的缓存里、是干净还是脏，所有核看到的内存视图都是一致的。**

### 1.1 一致性问题的根源

多核每个核都有私有 L1 D-Cache。同一条物理地址的 cache line 可能同时被多个核缓存。问题来了：

- 核 0 把某行改成了 `0x55`（脏，只在核 0 的 L1 里），核 1 此刻想读这一行——核 1 不能从内存读到旧值 `0x00`，必须拿到核 0 的最新值 `0x55`。
- 核 0 想独占写一行，而核 1/2/3 也缓存了同一行——核 0 写之前必须让其它核的副本全部作废，否则写完之后别人还拿着旧数据。

CIU 用 **MOESI 协议 + 侦听** 解决：每次一致性请求都先查“谁缓存了这一行”，再精确地通知相关核做相应动作（提供数据、作废、降级到 Shared）。

---

## 2. 在 C910 中的位置

```
   核0 (CPU0)          核1 (CPU1)        核2/3 (dummy)
   ┌────────┐         ┌────────┐
   │ L1 I/D │         │ L1 I/D │
   │  BIU   │         │  BIU   │          (OpenC910 默认 2 核)
   └───┬────┘         └───┬────┘
       │ ibiu0_*          │ ibiu1_*       ACE-lite + snoop 通道
       ▼                  ▼
  ┌──────────────────────────────────────────────────┐
  │                      CIU                           │
  │  ┌──────┐ ┌──────┐   PIU(每核一个接入口)            │
  │  │ PIU0 │ │ PIU1 │ ... PIU4(非相干设备口)          │
  │  └───┬──┘ └───┬──┘                                  │
  │      │  AR/AW/W ▼  AC/CR/CD(侦听)                    │
  │  ┌───────────────────────┐  ┌─────┐ ┌──────┐        │
  │  │  SNB×2 (含 SAB 侦听过滤)│  │ CTCQ│ │ NCQ  │        │
  │  └───────┬───────────────┘  └──┬──┘ └──┬───┘        │
  │          ▼ l2cif               │       │            │
  │  ┌────────────┐   ┌──────┐     │       ▼ ebiu       │
  │  │  L2 Cache  │   │  VB  │     └──► ┌──────────┐     │
  │  │ (bank0/1)  │   │(逐出)│         │ EBIU     │     │
  │  └────────────┘   └──┬───┘ ◄──────┤(AXI主)   │     │
  └──────────────────────┼────────────┴────┬─────┘     │
                         ▼ biu_pad_* (AXI)  ▼
                   片外内存(DDR) / 外设(APB: PMP/CLINT/PLIC/HAD)
```

CIU 之于多核，相当于 IFU 里的 ICache 接口之于取指流水：它是“资源仲裁 + 协议状态机”的集中地，本身不做计算，但所有核的内存访问都要从它这里走一遭。

---

## 3. 5 个 PIU 端口

PIU（Processor Interface Unit）是每个核接入 CIU 的“适配器”，把核的 BIU 信号转换成 CIU 内部协议。顶层一共实例化了 **5 个 PIU**（`ct_ciu_top.v:2041-2664`）：

| 端口 | 实例 | RTL 实例名 | 角色 | file:line |
|------|------|-----------|------|-----------|
| PIU0 | 真实相干核 | `ct_piu_top x_ct_piu0_top` | 核 0，参与缓存一致性、可被侦听 | `ct_ciu_top.v:2041` |
| PIU1 | 真实相干核 | `ct_piu_top x_ct_piu1_top` | 核 1，参与缓存一致性、可被侦听 | `ct_ciu_top.v:2222` |
| PIU2 | dummy 占位 | `ct_piu_top_dummy x_ct_piu2_top_dummy` | 核 2 不存在，输出全 0 占位（保持 4 核位图宽度） | `ct_ciu_top.v:2411` |
| PIU3 | dummy 占位 | `ct_piu_top_dummy x_ct_piu3_top_dummy` | 核 3 不存在，输出全 0 占位 | `ct_ciu_top.v:2522` |
| PIU4 | 非相干设备口 | `ct_piu_top_dummy_device x_ct_piu4_top_dummy` | 非相干设备/外部主设备入口，**不参与侦听** | `ct_ciu_top.v:2634` |

**为什么是 4 + 1？**

- **PIU0~PIU3 是相干口**：硬件按“最多 4 核”设计，所有一致性位图（`cp[3:0]`、`smpen[3:0]`、侦听请求 `snp_req_en[3:0]`）都是 4 位宽。OpenC910 默认只造 2 个核，PIU2/PIU3 用 dummy 模块把对应位钉成 0，这样位图逻辑不用改宽度，只是那两位永远不命中。
- **PIU4 是非相干口**：它接的是外部主设备/非相干 DMA。这类访问不缓存、不需要侦听，CIU 把它们直接送进 NCQ（非相干队列），绕开整个 MOESI/侦听机制。这就是文档把 piu4 单列、与 piu0-3 分开的原因。

PIU 内部有 3 类一致性通道（ACE 协议的侦听三通道，详见 `01_ciu_piu.md`）：

| 通道 | 方向 | 信号（顶层 pad 名） | 含义 |
|------|------|-----|------|
| **AC** | CIU → 核 | `ciu_ibiu_acaddr/acsnoop/acprot/acvalid` | 侦听请求：CIU 让核检查/作废自己 L1 中的某行 |
| **CR** | 核 → CIU | `ibiu_ciu_crresp/crvalid` | 侦听响应：核告诉 CIU 它的状态（命中/脏/作废完成） |
| **CD** | 核 → CIU | `ibiu_ciu_cddata/cdvalid/cdlast` | 侦听数据：当核持有脏数据时，把数据回送给 CIU |

---

## 4. 子模块全景

`ct_ciu_top.v` 实例化的全部子模块（`ct_ciu_top.v:1849-4103`）：

| 子模块 | 实例数 | 行数 | 职责 | 对应文档 |
|--------|--------|------|------|----------|
| `ct_piu_top` / `_dummy` / `_dummy_device` | 5 | 2732 / 503 / 171 | 每核/设备接入口，AC/CR/CD 三通道仲裁与打包 | 01 |
| `ct_piu_other_io` | 2 | 236 | PIU 侧的杂项 IO（中断、CSR、L2PMP APB） | 01 |
| `ct_ciu_snb` | **2** (snb_0/snb_1) | 993 | 侦听广播单元，按地址 bit[6] 分两个 bank | 02 |
| ├ `ct_ciu_snb_sab` | (在 snb 内) | 5020 | **SAB 侦听缓冲/过滤器**，24 项 | 02 |
| ├ `ct_ciu_snb_sab_entry` | (24/SAB) | 2571 | 单个 SAB 项，含 14 态主 FSM + cp 位图 | 02 |
| ├ `ct_ciu_snb_arb` | (在 snb 内) | 2379 | SNB 内各通道仲裁 | 02 |
| └ `ct_ciu_snb_dp_sel(_8/_16)` | (在 snb 内) | 136/81/121 | 年龄向量“最老优先”选择器 | 02 |
| `ct_ciu_ctcq` | 1 | 2332 | **Cache-to-Cache 传输队列** + DVM 同步 | 03 |
| ├ `ct_ciu_ctcq_reqq_entry` | 8 | 406 | CTC 请求队列项 | 03 |
| └ `ct_ciu_ctcq_respq_entry` | 16 | 246 | CTC 完成跟踪队列项 | 03 |
| `ct_ciu_vb` | 1 | 589 | **CIU 侧逐出/写回缓冲**（victim buffer） | 03 |
| └ `ct_ciu_vb_aw_entry` | 2 | 270 | VB 的 AW 项 | 03 |
| `ct_ciu_ncq` | 1 | 1872 | **非相干队列**（uncached/IO/设备） | 04 |
| └ `ct_ciu_ncq_gm` | 1 | 125 | 全局监视器（LR/SC 独占监视） | 04 |
| `ct_ebiu_top` | 1 | 786 | **外部 AXI 主接口**顶层 | 04 |
| ├ `ct_ebiu_read_channel` | 1 | 691 | AR/R 读通道 | 04 |
| ├ `ct_ebiu_write_channel` | 1 | 3070 | AW/W/B 写通道（含 NCWT×16、CAWT×32） | 04 |
| `ct_ciu_l2cif` | 1 | 1212 | **L2 Cache 接口**（双 bank 仲裁） | 04 |
| `ct_ciu_ebiuif` | 1 | 412 | EBIU 与 SNB/VB/CTCQ 的连接桥 | 04 |
| `ct_ciu_bmbif` | 1 | 303 | Barrier/Monitor 总线接口 | 04 |
| `ct_ciu_apbif` | 1 | 506 | APB 桥（PMP/CLINT/PLIC/HAD/RMR） | 04 |
| `ct_ciu_regs` | 1 | 767 | CIU 配置寄存器（smpen、sf_dis…） | 04 |

辅助小模块：`ct_fifo.v`(156，通用 FIFO)、`ct_prio.v`(60，优先级编码)、`ct_ebiu_lowpower.v`(84)。

---

## 5. 缓存一致性基础：MOESI 与 cp 位图

### 5.1 MOESI 五态

C910 的 L2/L1 一致性协议是 **MOESI**，每条 cache line 在某个核的视角下处于五态之一：

| 态 | 全称 | 含义 | 数据有效 | 是否脏 | 是否独占 |
|----|------|------|----------|--------|----------|
| **M** | Modified | 已修改，唯一拥有 | 是 | 脏 | 是 |
| **O** | Owned | 拥有脏数据，但允许其它核以 Shared 共享 | 是 | 脏 | 否（共享） |
| **E** | Exclusive | 干净且唯一拥有 | 是 | 干净 | 是 |
| **S** | Shared | 干净共享副本 | 是 | 干净 | 否 |
| **I** | Invalid | 无效 | 否 | - | - |

MOESI 相对 MESI 多了 **O（Owned）态**，作用见第 8 节——它让脏数据可以核间直传而不必先写回内存。

### 5.2 cp 位图：CIU 怎么知道“谁缓存了这一行”

CIU 不在每条 L1 line 上贴标签，而是把“哪些核缓存了某条 L2 line”这一信息，以 **cp（core presence，核存在位图）**的形式存在 **L2 Cache 的 tag** 里。每条 L2 line 配一个 **`cp[3:0]`**，4 位对应 4 个核：

```
cp[3:0] = { 核3缓存了?, 核2缓存了?, 核1缓存了?, 核0缓存了? }
```

当一致性请求进入 SAB（侦听缓冲）后，FSM 会向 L2C 发 `acc_tag`（读 tag）请求，L2C 回送的响应里带着这条 line 的 `cp[3:0]`，被锁存进 SAB 项的 `cp` 寄存器：

```verilog
// ct_ciu_snb_sab_entry.v:1947-1951
else if (l2c_resp_wen) begin
  l2_resp[4:0] <= l2c_resp[4:0];
  cp[3:0]      <= l2c_cp[3:0];     // ◄ 从 L2C tag 拿到核存在位图
end
```

L2C 的 line 状态在请求完成后还要被更新（set_cp/clr_cp），见 `ct_ciu_snb_sab_entry.v:1812-1820`：
- **set_cp**（`L2CW` 状态，读分配成功）：把请求者那一位置 1（“这个核现在也缓存了”）；
- **clr_cp**（`L2C` 状态，遇到 ru/cu/ws/wb/ci/mi/evict）：清掉相应位。`clr_cp = (wb|evict)? piu_sel : ~piu_sel`——逐出/写回清自己那位，独占类请求清除“别人”那些位。

L2C 请求类型一共 13 种（`req_type[12:0]`，`ct_ciu_snb_sab_entry.v:1759-1808`），覆盖读、分配、清(clean)、清+作废、写 SD/UC/UD/SC、读 tag、作废、独占(unique)、共享(shared)——这些就是把 MOESI 状态变迁落实到 L2C 的具体命令。

---

## 6. Snoop Filter（侦听过滤器）

### 6.1 为什么需要过滤

最朴素的实现是**广播**：核 0 每发一个一致性请求，CIU 就向核 1/2/3 全部发侦听。这有两个问题：
1. **功耗/带宽浪费**：大多数 line 只被一个核缓存，向没缓存它的核发侦听纯属做无用功，还要等它们回 CR 响应；
2. **延迟**：必须等所有被侦听核都回应才能继续，广播 = 等最慢的那个。

**Snoop Filter** 的思想：用上一节的 **`cp[3:0]` 位图**，只向真正缓存了这条 line 的核发侦听。位图哪一位是 0，就跳过那个核。这就是“过滤”。

### 6.2 三步过滤：cp → cp_after_sf → cp_mask → cp_after_mask

SAB 项里用三个连续的组合逻辑得到最终“要侦听哪些核”的位图（`ct_ciu_snb_sab_entry.v:1962-1964`）：

```verilog
// ① 过滤器开关：若 CSR 关闭了 snoop filter 且 L2 命中，退化为广播全部核
assign cp_after_sf[3:0]   = (ciu_chr2_sf_dis & l2_hit) ? 4'b1111 : cp[3:0];
// ② 去掉请求者自己：piu_sel 是发起请求的核，自己不用侦听自己
assign cp_mask[3:0]       = inst ? 4'b0 : piu_sel[3:0];
// ③ 最终位图 = 持有该行的核 & 去掉自己 & 只保留开了 SMP 的核
assign cp_after_mask[3:0] = cp_after_sf[3:0] & (~cp_mask[3:0]) & smpen[3:0];
```

- **`ciu_chr2_sf_dis`**（来自 `ct_ciu_regs.v:453` 的 CHR2 寄存器 bit4）：debug/兼容用，置 1 时关闭过滤、强制广播 `4'b1111`。
- **`piu_sel`**：发起请求的核的 one-hot 位，从位图里抠掉——你自己改自己的行不需要侦听自己。
- **`smpen[3:0]`**（来自 `ct_ciu_regs.v:656`）：每核 SMP 使能。没进 SMP 域的核（如刚复位、单核模式）不参与一致性，它那位强制为 0。

### 6.3 过滤后派发侦听

最终位图 `cp_after_mask` 驱动每核独立的侦听子 FSM（`ct_ciu_snb_sab_entry.v:1389-1403`）：

```verilog
assign cp_vld       = |cp_after_mask[3:0] & !(rns | wns | evict | l2_prf);  // 有核要侦听，且非特例
assign snp_req_vld  = (main_cur_state == L2C) & l2c_cmplt & !l2_err & cp_vld;
assign snp_req_en[3:0] = {4{snp_req_vld}} & cp_after_mask[3:0];  // ◄ 每位 = 要不要侦听该核
assign snp0_req_vld = snp_req_en[0];  // 核0 侦听子 FSM
assign snp1_req_vld = snp_req_en[1];  // 核1
assign snp2_req_vld = snp_req_en[2];  // 核2
assign snp3_req_vld = snp_req_en[3];  // 核3
assign snp_cmplt = snp0_cmplt & snp1_cmplt & snp2_cmplt & snp3_cmplt;  // 全部侦听完才算完
```

**关键收益**：若 `cp_after_mask = 4'b0010`，只有核 1 那个子 FSM 被触发，核 0/2/3 的 `snpX_cmplt` 立即为 1（无事可做），整个 `SNOP` 状态只等核 1 一个回应。无需广播。

> 顺便：`cp_vld` 在第 918 行还排除了 `rns/wns/evict/l2_prf` 这几类（非缓存读、非缓存写、逐出、L2 预取），它们本就不需要侦听别的核。

---

## 7. 完整侦听数据流

下面以“**核 0 读一条被核 1 以 Modified 持有的 line**”为例，串起从请求进 CIU 到拿到脏数据的全过程。涉及 SAB 主 FSM 的状态机（14 态，`ct_ciu_snb_sab_entry.v:677-690`：IDLE/DEPD/L2C/SNOP/L2CR/L2CW/L2CA/MEMR/L2CT/MEMW/BAR/POP/CR/ECC_ERR）。

```
① 核0 BIU 发 AR(读地址, snoop=ReadShared) ──► PIU0
       │ PIU0 按 araddr[6] 选 bank：bit6=0 走 SNB0，bit6=1 走 SNB1
       │ (ct_piu_top.v:876-877)
       ▼
② SNB 内 SAB 分配一项，main_cur_state: IDLE → L2C
       │ (若有地址依赖/写未完成则先进 DEPD 等待, ct_ciu_snb_sab_entry.v:751-752)
       ▼
③ L2C 状态：向 L2 Cache 发 acc_tag，读回 cp[3:0] 与 L2 line 状态
       │ 假设回来 cp = 4'b0010 (只有核1缓存)、L2 命中
       │ 算出 cp_after_mask = 0010 & ~0001(去掉核0) & smpen = 0010
       │ cp_vld=1 → main_next_state = SNOP  (ct_ciu_snb_sab_entry.v:771-772)
       ▼
④ SNOP 状态：只触发核1 的侦听子 FSM
       │ snp1 子 FSM 生成 sab_piu1_ac_req → PIU1
       │ PIU1 经 AC 通道把侦听送给核1：
       │   acsnoop 编码=CS(1000)/CI(1001)/MI(1101) 之一 (ct_ciu_snb_sab_entry.v:1406-1409)
       │   ac_bus = {addr, 4'b0001, snb1, sid, inst, acsnoop} (行1411)
       ▼
⑤ 核1 检查自己 L1：命中且为 Modified(脏)
       │ 经 CR 通道回 crresp，置 DT(有数据)+PD(脏) 位
       │   crresp 在 SAB 项累积：crresp |= piu_crresp (ct_ciu_snb_sab_entry.v:1884-1885)
       │   l1_dt=crresp[DT], l1_pd=crresp[PD] (行1890-1892)
       │ 经 CD 通道把脏数据回送 CIU
       ▼
⑥ snp_cmplt(全部侦听完成) → SNOP 退出
       │ 脏数据被写进 L2/转给请求者；按需进 L2CW 更新 L2C 状态、set_cp 把核0 那位置1
       │ (ct_ciu_snb_sab_entry.v:802-810)
       ▼
⑦ POP 状态：数据交给 PIU0 的 R 通道返回核0；SAB 项释放
```

**几个细节**：
- **AC 仲裁**：一个 PIU 的 AC 通道可能同时收到 SNB0、SNB1、CTCQ 三个来源的侦听请求，PIU 内用 `ac_sel` 仲裁（`ct_piu_top.v:1482-1484`）。
- **CR/CD 解耦**：CR 响应和 CD 数据走两条 FIFO（`ct_piu_top.v:1525` 的 cr_dfifo、rspq、cd_sid_fifo、pkb 包缓冲），允许多个侦听 outstanding。
- **侦听类型**由请求性质决定：读共享→CS(让对方降级到 Shared 但保留)，独占/写→CI/MI(让对方作废)。

---

## 8. Cache-to-Cache（CTC）直传与 Owned 态

### 8.1 问题：脏数据跨核传递

第 7 节中，核 1 持有脏行、核 0 要读。最笨的做法是：核 1 先把脏行**写回内存**，核 0 再**从内存读**。两次访存，慢且费带宽。

**CTC（Cache-to-Cache transfer）**：核 1 的脏数据**直接传给核 0**，绕过内存。这正是 **MOESI 的 O（Owned）态**存在的意义：

- 在 MESI 里没有 O 态，共享一条脏行时必须先写回内存（变干净）才能共享 → 共享 = 写回。
- 在 MOESI 里，核 1 把脏行的状态从 M **降级为 O**：它仍持有脏数据并负责最终写回，但允许核 0 拿一份 **Shared** 副本。核 0 直接从核 1（经 CIU 的 CTCQ）拿到数据，**内存完全没被触碰**。脏数据的“拥有权/写回责任”留在 Owned 的核 1 手里。

### 8.2 CTCQ 怎么实现

`ct_ciu_ctcq.v`（2332 行）专门管 CTC 与 DVM 同步：

- **请求队列 reqq**：8 项（`ct_ciu_ctcq.v:212` 的 8 位创建指针 + 8 个 `reqq_entry` 实例），每项记 CTC 地址、目标位图 `aim[5:0]`（L2 + EBIU + 4 核）。
- **响应队列 respq**：16 项（`ct_ciu_ctcq.v:514` 的 `respq_vld[15:0]`），跟踪每个 CTC 操作的完成情况；6 位完成位 `cmplt[5:0]` 初始化为 `~aim`（没被点名的目标视为已完成，`ct_ciu_ctcq.v:1396`），全 1 时整项 pop。
- **AC 广播**：CTCQ 也能经 PIU 的 AC 通道向相关核发请求，AC bus 的 snoop 字段为 `4'b1111`（`ct_ciu_ctcq.v:1018`），表示这是 CTC/DVM 类侦听。

详见 `03_ciu_ctcq_vb.md`。

---

## 9. Evict 通知：为什么干净行也要发

直觉上，一个核把**干净**的 line 从 L1 踢出去（容量替换），既没改数据、内存里本来就有正确值，似乎不需要通知任何人。**但 CIU 仍然要处理 Evict 通知（甚至对干净行）。** 原因是 **snoop filter 的正确性依赖 cp 位图的精确**：

- cp 位图记录“哪些核缓存了这一行”。若核 1 悄悄把干净行踢掉却不通知 CIU，cp 里核 1 那位还是 1。
- 之后核 0 要独占写这一行，CIU 查 cp 发现核 1“持有”，于是向核 1 发侦听——**但核 1 早就没有了**，这是一次纯浪费的侦听（多一次往返延迟、多耗一份功耗）。位图越来越“脏”（过度悲观），过滤效果越来越差，最终退化成接近广播。

所以核做容量替换时，即便是干净行，BIU 也会发一个 **Evict** 事务通知 CIU。CIU 在 SAB 里识别 `evict`，走 `clr_cp` 把该核那位清零（`ct_ciu_snb_sab_entry.v:1813-1814`：`evict` 触发 clr_cp，且 `clr_cp = piu_sel` 即清自己那位），让位图重新变精确。

> 这是“精确侦听过滤”的维护成本：用一点 Evict 通知带宽，换取后续大量无效侦听的避免。本质上是把“缓存目录”的维护责任分摊给各核主动上报。

---

## 10. 非相干路径与外部总线

不是所有访问都需要一致性。**非相干（non-coherent）**访问——uncached 内存、设备寄存器、IO——不缓存、不侦听，走单独的快速路径：

- **NCQ（ct_ciu_ncq.v，1872 行）**：汇聚 piu0-3 的非相干请求 + piu4 设备口的请求。内部多个浅 FIFO（读地址 RAQ 深 2、写地址 WAQ 深 2、写序 WOQ 深 16…），不经过 SAB/侦听，直接转发给 EBIU 或 APB。
- **ncq_gm（ct_ciu_ncq_gm.v，125 行）**：全局监视器，为非相干区的 **LR/SC（Load-Reserved/Store-Conditional 原子操作）**维护独占地址监视。
- **EBIU（ct_ebiu_top.v）**：对外 AXI 主接口，读通道 `ct_ebiu_read_channel`、写通道 `ct_ebiu_write_channel`（内含 NCWT×16 非相干写跟踪 + CAWT×32 相干地址写跟踪，做地址冲突检测）。外部信号是标准 AXI 的 `biu_pad_ar*/aw*/w*/r*/b*`。
- **APBIF（ct_ciu_apbif.v）**：把非相干访问桥接到 APB 外设——PMP、CLINT、PLIC、HAD（debug）、RMR。4 态 FSM（IDLE/WADDR/REQ/PEND，`ct_ciu_apbif.v:253-256`）。

详见 `04_ciu_ncq_ebiu_regs.md`。

---

## 11. 关键设计决策汇总

| 决策 | 内容 | 为什么 | 出处 |
|------|------|--------|------|
| 4+1 PIU 口 | piu0-3 相干（2 实 2 dummy）+ piu4 非相干 | 位图按 4 核固定宽度，dummy 钉 0；设备口绕开侦听 | `ct_ciu_top.v:2041-2664` |
| SNB 双 bank | 按地址 bit[6] 分 SNB0/SNB1 两路侦听 | 翻倍侦听吞吐，奇偶 cache line 并行处理 | `ct_piu_top.v:876-877` |
| SAB 24 项 | 16 读 + 8 写（SAB_DEPTH=24） | 容纳足够多 outstanding 一致性事务 | `cpu_cfig.h:468-470` |
| cp 位图过滤 | 用 L2C tag 里的 `cp[3:0]` 精确侦听 | 避免广播全部核，省功耗/带宽/延迟 | `ct_ciu_snb_sab_entry.v:1962-1964` |
| MOESI 含 O 态 | 脏行可降级 Owned 后核间直传 | CTC 绕过内存，省两次访存 | `ct_ciu_ctcq.v` |
| Evict 通知干净行 | 干净行替换也上报 CIU 清 cp | 维护位图精确，防止过滤退化 | `ct_ciu_snb_sab_entry.v:1813-1814` |
| 年龄向量仲裁 | SAB 项用 age_vect 实现最老优先 | 公平、防饿死、保证顺序 | `ct_ciu_snb_dp_sel.v:107-130` |
| smpen 门控 | 每核 SMP 使能位过滤侦听 | 未入 SMP 域的核不参与一致性 | `ct_ciu_regs.v:656` |
| sf_dis 后门 | CSR 可关闭过滤强制广播 | debug/功能兼容回退 | `ct_ciu_regs.v:453` |

---

## 12. 学习路径

```
第一轮（建立全局观）
  └── 00_ciu_overview.md   ← 本文

第二轮（核接入与侦听通道）
  └── 01_ciu_piu.md        PIU：AC/CR/CD 三通道、5 个端口角色

第三轮（一致性核心）
  └── 02_ciu_snb_sab.md    SNB 广播 + SAB 侦听过滤（重点，14 态主 FSM）

第四轮（直传与逐出）
  └── 03_ciu_ctcq_vb.md    CTCQ cache-to-cache、VB 逐出缓冲

第五轮（非相干与对外）
  └── 04_ciu_ncq_ebiu_regs.md  NCQ、EBIU(AXI)、L2CIF、APB、寄存器
```

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_ciu_overview.md](00_ciu_overview.md) | CIU 总览、5 PIU、子模块全景、侦听数据流、MOESI/cp 过滤、设计决策 | 先读 |
| [01_ciu_piu.md](01_ciu_piu.md) | PIU 每核接入口、AC/CR/CD 通道、dummy 变体 | 第一精读 |
| [02_ciu_snb_sab.md](02_ciu_snb_sab.md) | SNB 侦听广播 + SAB 24 项过滤器 + 14 态主 FSM + 仲裁 | 一致性核心 |
| [03_ciu_ctcq_vb.md](03_ciu_ctcq_vb.md) | CTCQ cache-to-cache 传输、VB 逐出缓冲 | 直传与逐出 |
| [04_ciu_ncq_ebiu_regs.md](04_ciu_ncq_ebiu_regs.md) | NCQ、EBIU AXI 主口、L2CIF、BMBIF、APBIF、regs | 非相干与对外 |

---

*本文是 CIU 子系统总览，涉及 `ct_ciu_top.v` 等全部 37 个文件的架构关系；各子模块逐行细节见对应分册文档。*
