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
5. [为什么 huge 项单列：只存 1GB](#5-为什么-huge-项单列只存-1gb)
6. [双端口：两条访存流水同时翻译](#6-双端口两条访存流水同时翻译)
7. [读出数据通路（ct_mmu_dutlb_read.v）](#7-读出数据通路ct_mmu_dutlb_readv)
8. [tree-PLRU 替换（ct_mmu_dplru.v）](#8-tree-plru-替换ct_mmu_dplruv)
9. [miss → JTLB → 回填 流程](#9-miss--jtlb--回填-流程)
10. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

duTLB 是**访存侧的一级微 TLB**：LSU 两条流水各发一个 load/store 虚拟
地址，每个表项各有两套 VPN 比较器，两个端口可同时查表。命中后组合选择
PPN、权限与 PMA；随后数据通路还要进行 VA 合法性、页权限、PMP 和异常归属
判断。因此“表项组合命中”与“`mmu_lsu_pa*_vld`对 LSU 生效”应按接口时序
分别观察，不能只写成无参考点的“当拍完成”。

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
| `mmu_lsu_pa0/pa1[27:0]` + `_vld` | out | 两端口翻译得到的 PPN；LSU 保留 VA[11:0]以形成完整 PA |
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

iuTLB fast/slow 与 duTLB normal/huge 这四种 entry RTL 都把按 VA 失效写成
`lsu_mmu_tlb_va[7:0] == utlb_vpn[7:0]`。普通项保存 4KB 粒度的完整 VPN，
该比较可能多清除同低 8 位的其他普通项；专用 1GB 项却只在正常查表时比较
VPN[26:18]，失效时没有按 1GB 覆盖范围比较。因而“大页内任意 VA 都能清到
huge entry”不能仅由当前表达式证明，应使用不同 1GB 页内偏移做定向验证。

---

## 5. 为什么 huge 项单列：只存 1GB

### 5.1 比较位数不同

这是理解 duTLB 的核心。普通项比较**完整 27 位 VPN**（`ct_mmu_dutlb_entry.v:195-196`）：

```verilog
assign utlb_hit0 = utlb_req_vpn0[26:0] == utlb_vpn[26:0];   // 全 27 位 → 只能装 4K 页
assign utlb_hit1 = utlb_req_vpn1[26:0] == utlb_vpn[26:0];
```

entry16 只比较 **VPN 高 9 位**（`ct_mmu_dutlb_huge_entry.v:195-199`，
`LVL_WIDTH=9`）：

```verilog
assign utlb_hit0 = utlb_req_vpn0[26:18] == utlb_vpn[26:18];  // 只比高 9 位
assign utlb_hit1 = utlb_req_vpn1[26:18] == utlb_vpn[26:18];
```

只比较 VPN[26:18]、并在读出时用请求 VA 对应的 18-bit VPN offset 补 PPN，
严格对应 **1GB 页**。它不能区分同一 1GB 区域内的不同 2MB 页，所以绝不能
把它描述成 2MB/1GB 共用项。

### 5.2 回填路由

回填时按 `jtlb_utlb_ref_pgs[2]`决定写入位置：

- `pgs=3'b100`（1GB）→ 写 entry16；
- `pgs=3'b010`（2MB）或 `3'b001`（4KB）→ 用 PLRU 写 16 个普通项之一。

### 5.3 2MB 翻译怎样进入不存页大小的普通项

普通项只做完整 27-bit VPN 相等比较，也没有 `pgs`寄存器。2MB 回填时，顶层
会把 JTLB 中按 2MB 对齐的 VPN/PPN 低 9 位替换成**当前 miss 请求**
`dutlb_arb_vpn[8:0]`：

```verilog
utlb_upd_vpn = {jtlb_ref_vpn[26:9],
                pgs[0] ? jtlb_ref_vpn[8:0] : dutlb_arb_vpn[8:0]};
utlb_upd_ppn = {jtlb_ref_ppn[27:9],
                pgs[0] ? jtlb_ref_ppn[8:0] : dutlb_arb_vpn[8:0]};
```

对 2MB 页而言，这相当于把一个大页翻译**专门化为当前 4KB 子页的完整
VPN→PPN 映射**。以后访问同一 4KB 子页可直接命中；访问同一 2MB 页里的另一
个 4KB 子页，duTLB 可能再次 miss，但 JTLB 的 2MB 项可以命中并快速生成另一
个普通项。1GB 页没有这样展开，而由 entry16 覆盖整个 1GB 范围。

### 5.4 这种非对称结构的取舍

RTL 明确可见的结果是：16 个普通项无需保存 `pgs`，每端口只做 16 次完整
VPN 相等比较；1GB 特例由一套高 9 位比较器处理。这样确实减少了可变页大小
比较逻辑。将其进一步解释为“改善关键路径”是合理的微结构动机，但最终改善
多少必须由综合时序报告验证。

容量代价也要说清楚：同一个 2MB 映射的多个 4KB 子页会占用多个普通项，而
1GB 项只有一个，多个活跃 1GB 区域会互相覆盖。不能仅以“大页少见”断言一个
entry 对所有 workload 都足够。

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

PA 和 flag 用 one-hot case 从 16 个普通项里选；entry16 命中时走单独的
`dutlb_pre_pa`路径，将 entry16 PPN 高 10 位与请求的 18-bit VPN offset
拼成最终 PPN，并把 `pgs`固定为 `3'b100`。普通项读出时则固定报告
`3'b001`，所以此前专门化进入普通项的 2MB 翻译在 duTLB 层表现为 4KB 项。
MMU-off、非法 VA、异常匹配和 store-AMO 物理地址旁路也复用
`dutlb_pre_sel`，不能看到该 mux 就都解释成“huge 命中”。

输出 `mmu_lsu_pa_x[27:0]`始终是 PPN。普通 4KB 项直接给出表项 PPN；1GB
项把表项 PPN 高 10 位与请求 VA[29:12]拼成最终 28-bit PPN；MMU-off 时取
VA[39:12]。页内 `VA[11:0]`不经过 duTLB 输出，仍由 LSU 数据通路持有。

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

`mmu_lsu_stall0/1`在当前 RTL 中直接绑为 0。duTLB miss 的等待不是通过该
stall 输出表达，而是通过 `pa_vld`不成立、refill FSM 占用以及 LSU 自身请求
保持/重放逻辑完成。调波形时不能把 `mmu_lsu_stall*=0`误读成“翻译永远不
阻塞访存”。

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

1. **IDLE → WFG**：`dutlb_miss_vld`由两个端口 miss 求或。若两个端口同拍
   miss，顶层结合 IID 比较选择需要先服务的请求，并把选中 VPN、IID、类型
   记录到 refill 寄存器；“两个端口都能同拍查 uTLB”不等于能并行发起两个
   JTLB refill。随后 `dutlb_arb_req=(ref_cur_st==WFG)`保持请求直至 grant。
2. **WFG → WFC**：拿到 `arb_dutlb_grant`。
3. **WFC**：`dutlb_refill_vld = dutlb_wfc && jtlb_dutlb_ref_pavld`。1GB
   回填写 entry16；4KB和2MB回填写 PLRU 选中的普通项，其中2MB按当前
   VPN[8:0]专门化为一个4KB子页翻译。
4. **完成/abort**：`dutlb_arb_cmplt`（概念见 `:750-765`）在 refill 完成或 WFG 期间被 `rtu_yy_xx_flush` 冲刷（→ ABT 态）时拉高。

与 iuTLB 同理，若 JTLB 再 miss 触发 PTW，PTW 先回填 JTLB 再回填 uTLB，duTLB 只感知 `jtlb_utlb_ref_*`。

`mmu_hpcp_dutlb_miss`的源条件是
`dutlb_refill_vld && hpcp_mmu_cnt_en`，随后经过一个“源条件为 1 则置位、
下一空闲拍自清零”的寄存器。正常单次 refill 表现为一个周期事件，但 RTL
没有独立上升沿检测。它统计成功取得有效翻译并回填 duTLB 的 miss；以
page/access fault 结束但没有 `jtlb_dutlb_ref_pavld`的请求不在这个事件中。

---

## 本章小结

duTLB 是 16 个普通项加 1 个专用 1GB 项的非对称双端口结构。普通项保存 4KB 翻译，以及把 2MB 映射按当前访问地址专门化后的 4KB 子页；专用项只比较 1GB 页所需的高位 VPN。两个 LSU 地址端口各有命中比较和读出通路，并共享 15 位 tree-PLRU。单次命中只更新叶到根路径上的四个节点，同拍双端口命中则由 dPLRU 逻辑处理更新冲突。和 iuTLB 一样，duTLB 不保存 ASID，地址空间切换时通过清表避免旧翻译误命中，跨地址空间保留由 JTLB 承担。

duTLB miss、bypass 和 refill 不是同拍完成的组合过程。请求离开小表后经过 MMU arb 和 JTLB，必要时再进入 PTW；返回携带 IID，duTLB 通过 IID 匹配把异步回填和异常归属到原始访存。第二虚地址端口 `lsu_mmu_va2` 直接进入 MMU 仲裁/JTLB-PFU 路径，不经过 duTLB 本体，因此不能把两条外部 VA 接口都解释为 duTLB 的两个查找端口。观察一次 load/store 翻译时，应对齐 VA valid、普通/1GB hit、miss 请求与 grant、refill FSM、IID、PA valid、页权限和 PMP 结果；只有这些阶段闭环，才能判断该访存已经获得可执行的物理地址。
