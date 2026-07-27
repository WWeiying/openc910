# C910 MMU duTLB（数据微 TLB）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_dutlb.v`（约 1542 行）
>
> 相关文件：`ct_mmu_dutlb_entry.v`（215 行，普通项）、`ct_mmu_dutlb_huge_entry.v`（217 行，huge 项）、`ct_mmu_dutlb_read.v`（781 行，读出/命中/异常）、`ct_mmu_dplru.v`（940 行，tree-PLRU）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [16 普通 + 1 huge = 17 项](#4-16-普通--1-huge--17-项)
5. [为什么 huge 项单列：专存 2M/1G](#5-为什么-huge-项单列专存-2m1g)
6. [双端口：两条访存流水同时翻译](#6-双端口两条访存流水同时翻译)
7. [读出数据通路（ct_mmu_dutlb_read.v）](#7-读出数据通路ct_mmu_dutlb_readv)
8. [tree-PLRU 替换（ct_mmu_dplru.v）](#8-tree-plru-替换ct_mmu_dplruv)
9. [miss → JTLB → 回填 流程](#9-miss--jtlb--回填-流程)
10. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

duTLB 是**访存侧的一级微 TLB**：LSU 两条流水各发一个 load/store 虚拟地址，duTLB 当拍并行比较 17 个表项，命中则立刻给出物理页号 + 读写权限 + PMA 属性（Cacheable/Bufferable/Strong-order/Shareable/Security）给 LSU。它是 MMU 存储层次里数据侧最快最小的一层（类比 L1 D-TLB）。

### 1.2 位置

上游 LSU（`lsu_mmu_va0/va1`），命中下游回 LSU（`mmu_lsu_pa0/pa1` 等），miss 经 arb→JTLB。与 iuTLB 一样**不存 ASID**，进程切换写 satp 整表清空。

---

## 2. 端口说明

### 2.1 LSU 接口（双端口）

| 信号 | 方向 | 含义 |
|------|------|------|
| `lsu_mmu_va0/va1` + `_vld` | in | 两端口 load/store VA |
| `lsu_mmu_id0/id1` | in | 两端口指令 ID（用于 refill 匹配） |
| `lsu_mmu_st_inst0/1` | in | 是否 store（决定 W 权限检查） |
| `mmu_lsu_pa0/pa1` + `_vld` | out | 两端口翻译结果 |
| `mmu_lsu_page_fault0/1`、`access_fault0/1` | out | 两端口异常 |
| `mmu_lsu_ca/buf/so/sh/sec 0/1` | out | 两端口 PMA |

### 2.2 arb / JTLB 接口

| 信号 | 方向 | 含义 |
|------|------|------|
| `dutlb_arb_req` / `_vpn` / `_load` | out | miss 请求查 JTLB（`ct_mmu_dutlb.v:692-695`） |
| `dutlb_arb_cmplt` | out | refill 完成 |
| `jtlb_dutlb_ref_pavld`/`ref_cmplt` | in | JTLB 回填有效/完成 |
| `jtlb_utlb_ref_vpn/ppn/pgs/flg` | in | JTLB 回填内容 |

### 2.3 PLRU / 系统

| 信号 | 方向 | 含义 |
|------|------|------|
| `plru_dutlb_ref_num` | (内部) | dplru 牺牲项 one-hot |
| `regs_utlb_clr` / `tlboper_utlb_clr` | in | 整表清 / sfence 清 |
| `rtu_yy_xx_flush` | in | 流水冲刷（refill 中 abort） |

---

## 3. 参数与关键寄存器

`ct_mmu_dutlb.v:446-452`：

| 参数 | 值 | 含义 |
|------|----|------|
| `VPN_WIDTH` | 27 | 虚拟页号 |
| `PPN_WIDTH` | 28 | 物理页号 |
| `FLG_WIDTH` | 14 | 属性标志 |
| `PGS_WIDTH` | 3 | 页大小 |
| `LVL_WIDTH` | 9 | 每级 VPN 位数（huge 项比较用） |
| `IID_WIDTH` | 7 | 指令 ID 宽度 |

refill FSM 状态（`:578-583`）：

```verilog
parameter IDLE  = 3'b000, WFG = 3'b001, WFC = 3'b011,
          PGFLT = 3'b010, ACFLT = 3'b100, ABT = 3'b101;
```

当前态 `ref_cur_st[2:0]`（`:186-187`）。

---

## 4. 16 普通 + 1 huge = 17 项

duTLB 共 **17 个表项**：

- **16 个普通项**（`ct_mmu_dutlb_entry`）：entry0~entry15，例化 `ct_mmu_dutlb.v:812`（entry0）~ `:1187`（entry15）。
- **1 个 huge 项**（`ct_mmu_dutlb_huge_entry`）：entry16，例化 `:1212-1232`。

普通项与 iuTLB 项结构相同（`ct_mmu_dutlb_entry.v:60-64`）：vld + vpn[26:0] + ppn[27:0] + flg[13:0]，**无 ASID**（注释 `:107-109`）、**无 pgs**（普通项固定 4K，见下节）。

---

## 5. 为什么 huge 项单列：专存 2M/1G

### 5.1 比较位数不同

这是理解 duTLB 的核心。普通项比较**完整 27 位 VPN**（`ct_mmu_dutlb_entry.v:195-196`）：

```verilog
assign utlb_hit0 = utlb_req_vpn0[26:0] == utlb_vpn[26:0];   // 全 27 位 → 只能装 4K 页
assign utlb_hit1 = utlb_req_vpn1[26:0] == utlb_vpn[26:0];
```

huge 项只比较 **VPN 高 9 位**（`ct_mmu_dutlb_huge_entry.v:195-199`，`LVL_WIDTH=9`）：

```verilog
assign utlb_hit0 = utlb_req_vpn0[26:18] == utlb_vpn[26:18];  // 只比高 9 位
assign utlb_hit1 = utlb_req_vpn1[26:18] == utlb_vpn[26:18];
```

比较高 9 位意味着忽略低 18 位偏移 —— 这正是 1GB 页（低 30 位是页内偏移，VPN 只有高 9 位有效）和 2MB 页的覆盖范围。读出时 huge 项的低位 PA 用请求 VA 的偏移补齐（`ct_mmu_dutlb_read.v:660-664` 用 `pa_offset` 拼接）。

### 5.2 回填路由

回填时按页大小高位 `jtlb_utlb_ref_pgs[2]` 决定写到普通项还是 huge 项（`ct_mmu_dutlb.v:1511-1517`，概念）：

- `jtlb_utlb_ref_pgs[2]==1`（2M/1G 大页）→ 写 huge 项（`utlb_huge_entry_upd`）；
- 否则（4K）→ 用 `plru_dutlb_ref_num` 在 16 个普通项里选一个写。

### 5.3 为什么不让普通项也支持大页（设计取舍）

让 16 个普通项都支持可变页大小，需要每项存 `pgs` 并做"按 pgs 掩码后比较"（像 iuTLB 项那样三选一），这会让 **16 个高频比较器**都变复杂、变慢 —— 而数据侧每拍要并行做 16×2（双端口）次比较，时序压力远大于取指侧。

C910 的取舍：**大页是相对罕见的情况，把它隔离到唯一的 huge 项专门处理**，让 16 个普通项保持最简单的全宽相等比较，保住数据翻译的关键路径速度。这是"为常见情况（4K）优化、特例（大页）单独伺候"的经典工程权衡。代价是同一时刻只能缓存 1 个大页翻译，但大页本就稀少且每个覆盖巨大地址范围，1 项往往够用。

---

## 6. 双端口：两条访存流水同时翻译

C910 的 LSU 有两条 load/store 流水，所以 duTLB 每拍要**同时翻译 2 个 VA**。这体现在三处：

1. **每个表项有两套命中比较**：`utlb_hit0`（端口 0）和 `utlb_hit1`（端口 1），各比一份请求 VPN（`ct_mmu_dutlb_entry.v:195-196`）。
2. **两份读出数据通路**：`ct_mmu_dutlb_read.v` 被例化两次 —— `x_ct_mmu_dutlb_read0`（端口 0，load 流水）于 `ct_mmu_dutlb.v:1246`，`x_ct_mmu_dutlb_read1`（端口 1，store 流水）于 `:1376`。
3. **PLRU 支持双命中更新**：dplru 有 `utlb_plru_read_hit0`/`hit1` 两个访问向量（见第 8 节），能在同一拍处理两个端口的命中并解决冲突。

此外还有第三条**预取（PFU）通道** `lsu_mmu_va2`，但它不占 uTLB 端口，而是直接走 arb→JTLB（见 05 篇 arb 的 `arb_pfu_grant`）。

---

## 7. 读出数据通路（ct_mmu_dutlb_read.v）

`ct_mmu_dutlb_read.v` 是 duTLB 的"读出 + 命中选择 + 异常判定"单元，每端口一个实例。主要工作：

### 7.1 命中向量与命中选择

把 17 项的 vld 和 hit 拼向量后相与（`:553-568`）：

```verilog
assign vpn_vld[16:0] = {entry16_vld, ..., entry0_vld};
assign vpn_hit[16:0] = {entry16_hit_x, ..., entry0_hit_x};
assign dutlb_entry_hit[16:0] = vpn_vld & vpn_hit;          // :564
assign dutlb_addr_hit        = |dutlb_entry_hit[16:0];     // :568
```

PA 和 flag 用 one-hot case 从 16 个普通项里选（`:597-617` 选 PA，`:637-657` 选 flag）；huge 项（bit16）走单独的 `dutlb_pre_pa` 路径，低位用请求偏移补齐（`:660-664`）。最终 PA/flg/pgs 在普通项结果与"预选/huge/MMU关"之间二选一（`:684-692`）。

### 7.2 PMA 属性输出

从 14 位 flag 解出 LSU 关心的 PMA（`:456-461`）：

```verilog
assign mmu_lsu_sh_x  = flg[10] && !biu_mmu_smp_disable;   // Shareable
assign mmu_lsu_buf_x = flg[11] || !flg[13];               // Bufferable（非 SO 必 buf）
assign mmu_lsu_so_x  = flg[13];                           // Strong Order
assign mmu_lsu_sec_x = flg[9];                            // Security
assign mmu_lsu_ca_x  = flg[12] && !flg[13];               // Cacheable（SO 时强制不 cache）
```

### 7.3 异常判定

`dutlb_va_illegal`（`:472-474`）检查 VA 高位符号扩展是否合法；`dutlb_page_fault`（`:475-488`）按 14 位 flag 判 V/R/W/A/D 及 U/S 越权（注意 store 时检查 W：`!flg[2] && !dutlb_read_type_x`）；`mmu_lsu_access_fault_x`（`:491-497`）来自 JTLB access fault 或 PMP 拒绝。

### 7.4 指令 ID 匹配（refill 时序解耦）

refill 是异步回来的，要确认回填数据属于哪条访存指令：`:525-527` 比较 `refill_id_flop` 与 `lsu_mmu_id_x`，并用 `ct_rtu_compare_iid`（`:530-534`）判断新旧指令谁更老，从而正确决定 bypass/阻塞和异常归属。

---

## 8. tree-PLRU 替换（ct_mmu_dplru.v）

duTLB 普通项（16 个）的替换由 `ct_mmu_dplru.v` 决定，输出 `plru_dutlb_ref_num[15:0]`（`:74`）。huge 项不参与 PLRU（它由 pgs 直接路由）。

### 8.1 16 叶二叉树需要 15 个状态位

一棵 **4 层满二叉树**：16 叶（16 项），15 个内部节点各 1 位（`ct_mmu_dplru.v:81-95`）：`p00`（`:81`）、`p10,p11`（`:82-83`）、`p20~p23`（`:84-87`）、`p30~p37`（`:88-95`）。

### 8.2 牺牲项选择

从根到叶遍历（`:916-933`）：

```verilog
assign plru_num[3] = p00;                          // :916 根
assign plru_num[2] = !p00 && p10 || p00 && p11;    // :918-919
// … 直到 plru_num[0] 由第 4 层 8 个节点选出
```

### 8.3 双端口更新与冲突解决

dplru 的特别之处是要处理**同拍两个端口都命中**的情况（`:469-474` 给出更新条件，分 port0/port1）。以节点 p10 为例（`:510-513`）：

```verilog
assign p10_rdupdt_by_va0  = p10_read_updt0 && !p10_read_updt1;          // 只 port0 经过
assign p10_rdupdt_by_va1  = !p10_read_updt0 && p10_read_updt1;          // 只 port1 经过
assign p10_rdupdt_by_va01 = (p10_read_updt0 && p10_read_updt1)          // 两端口都经过
                          && (p10_read_updt_val0 ^~ p10_read_updt_val1);// 方向一致才更新
```

回填更新 `plru_write_updt = utlb_plru_refill_vld`（`:469`）。同样只翻转 log2(16)=4 个路径节点。

> 同为 tree-PLRU，但 dplru 比 iplru 多了**双端口冲突仲裁**，因为数据侧两条流水可能同拍命中不同项。

---

## 9. miss → JTLB → 回填 流程

refill FSM（`:578-683`）：

1. **IDLE → WFG**：`dutlb_miss_vld`（`ct_mmu_dutlb_read.v:514-518`：va 有效、未命中、VA 合法、未 abort、非 MMU 关）触发，向 arb 发 `dutlb_arb_req=(ref_cur_st==WFG)`（`:692`），并标明是 load 还是 store（`dutlb_arb_load`）。两端口 miss 的 VPN 分别存于 `refill_va_flop0/1`（`:700-711`）。
2. **WFG → WFC**：拿到 `arb_dutlb_grant`。
3. **WFC**：`dutlb_refill_vld = dutlb_wfc && jtlb_dutlb_ref_pavld`。回填内容 `jtlb_utlb_ref_*` 写入选中项（4K→PLRU 普通项，大页→huge 项）。回填 VPN 拼接见 `:1522-1530`（大页时低位用当前请求 VA）。
4. **完成/abort**：`dutlb_arb_cmplt`（概念见 `:750-765`）在 refill 完成或 WFG 期间被 `rtu_yy_xx_flush` 冲刷（→ ABT 态）时拉高。

与 iuTLB 同理，若 JTLB 再 miss 触发 PTW，PTW 先回填 JTLB 再回填 uTLB，duTLB 只感知 `jtlb_utlb_ref_*`。

---

## 设计取舍小结

- **17 = 16 + 1 的非对称结构**：16 个全宽比较的普通项专吃 4K，1 个高 9 位比较的 huge 项专吃 2M/1G —— 为常见情况优化、特例单独伺候，保住 16 个高频比较器的速度。
- **双端口**：每项两套命中比较、两份读出通路、PLRU 双命中冲突仲裁，匹配 LSU 两条访存流水。
- **tree-PLRU（15 位状态）**：小表拼命中率，只翻转 4 个路径节点；dplru 额外解决双端口同拍冲突。
- **不存 ASID**：进程切换整表清空，省 ASID 存储；保命交给 JTLB。
- **指令 ID 解耦 refill**：异步回填用 IID 匹配确认归属，正确处理 bypass 与异常归属。

*文档覆盖 ct_mmu_dutlb.v / _entry.v / _huge_entry.v / _read.v / _dplru.v 的全部关键逻辑（dutlb.v 约 1542 行）。*
