# C910 MMU PTW（页表遍历器）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_ptw.v`（约 806 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [Sv39 三级遍历总览](#4-sv39-三级遍历总览)
5. [FSM 详解（~20 态）](#5-fsm-详解20-态)
6. [访存地址生成（走 LSU、无 PTE cache）](#6-访存地址生成走-lsu无-pte-cache)
7. [叶子判定、大页与跨区检查](#7-叶子判定大页与跨区检查)
8. [page fault 与 access fault](#8-page-fault-与-access-fault)
9. [回填 JTLB（FIFO 选路）](#9-回填-jtlbfifo-选路)
10. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

PTW（Page Table Walker，页表遍历器）是 MMU 存储层次的**末级兜底**：当 JTLB 也 miss 时，PTW 用一台状态机按 Sv39 规则**逐级读内存里的页表项（PTE）**，走完三级后把翻译结果（PPN + 属性 + 页大小）经 arb 回填给 JTLB。它没有独立的 PTE cache，而是**借 LSU 的访存口**去读页表（自然命中 D-Cache）。

### 1.2 位置

输入来自 JTLB 的 miss 请求（`jtlb_ptw_req`），访存请求发给 LSU（`mmu_lsu_data_req`），PTE 数据由 LSU 回（`lsu_mmu_data`），结果经 arb 回填 JTLB（`ptw_arb_*`）。物理地址在每次访存前还要过 PMP（`mmu_pmp_pa3`）和 sysmap（`mmu_sysmap_pa3`）确认。

---

## 2. 端口说明

### 2.1 JTLB 请求 / 回填

| 信号 | 方向 | 含义 |
|------|------|------|
| `jtlb_ptw_req` | in | JTLB miss，请求遍历（`ct_mmu_ptw.v:89`） |
| `jtlb_ptw_vpn` / `jtlb_ptw_type` | in | 待翻译 VPN / 访问类型 |
| `jtlb_xx_fifo[11:0]` | in | JTLB 该组的 fifo 指针（回填选路用） |
| `ptw_jtlb_ref_ppn/pgs/flg` | out | 回填 JTLB 的 PPN/页大小/属性 |
| `ptw_jtlb_ref_cmplt`/`data_vld`/`acc_err`/`pgflt` | out | 完成/有效/访问错/缺页 |
| `ptw_jtlb_imiss`/`dmiss`/`pmiss` | out | 区分取指/数据/预取 miss |

### 2.2 借用 LSU 访存

| 信号 | 方向 | 含义 |
|------|------|------|
| `mmu_lsu_data_req` / `_addr[39:0]` / `_size` | out | 读 PTE 请求（`:762-764`） |
| `lsu_mmu_data[63:0]` / `lsu_mmu_data_vld` | in | 返回的 64 位 PTE |
| `lsu_mmu_bus_error` | in | 读 PTE 总线错 → access fault |

### 2.3 arb / PMP / sysmap / CP0

| 信号 | 方向 | 含义 |
|------|------|------|
| `ptw_arb_req`/`vpn`/`pgs`/`tag_din`/`data_din`/`fifo_din`/`bank_sel` | out | 回填 JTLB（经 arb） |
| `arb_ptw_grant` / `arb_ptw_mask` | in | arb 授权 / 屏蔽 |
| `mmu_pmp_pa3` / `pmp_mmu_flg3` | out/in | PMP 检查地址 / 结果 |
| `mmu_sysmap_pa3` / `sysmap_mmu_flg3` / `_hit3` | out/in | sysmap 区检查 |
| `regs_ptw_satp_ppn` / `regs_ptw_cur_asid` | in | 根页表 PPN / 当前 ASID |
| `cp0_mmu_maee/mxr/sum/mprv/mpp`、`cp0_yy_priv_mode` | in | 翻译控制位 |

---

## 3. 参数与关键寄存器

`ct_mmu_ptw.v:250-264`：

| 参数 | 值 | 含义 |
|------|----|------|
| `VADDR_WIDTH` | 39 | 虚拟地址 |
| `PADDR_WIDTH` | 40 | 物理地址 |
| `VPN_WIDTH` | 27 / `PPN_WIDTH` 28 | 页号宽度 |
| `ASID_WIDTH` | 16 | ASID |
| `PGS_WIDTH` | 3 | 页大小 |
| `VPN_PERLEL` | 9 | 每级 VPN 位数 |
| `TAG_WIDTH` | 48 / `DATA_WIDTH` 42 | 回填 JTLB 的 tag/data 宽 |

关键寄存器（`:130-141`）：`ptw_cur_st[4:0]`（当前态）、`ptw_vpn`（待翻译 VPN）、`ptw_req_addr[39:0]`（当前 PTE 物理地址）、`lsu_data_flop[63:0]`（暂存 PTE）、`ptw_fifo[11:0]`（JTLB fifo 指针）、`ref_pgs[2:0]`（命中页大小）、`ptw_type[2:0]`（访问类型）。

---

## 4. Sv39 三级遍历总览

从 `satp.ppn` 指向的根页表出发，按三段 VPN 逐级索引：

1. **第 1 级**：`addr = satp.ppn×4096 + VPN[2]×8` → 读得 `pte1`（`ptw_fst_addr`，`:625-627`）
2. **第 2 级**：`addr = pte1.ppn×4096 + VPN[1]×8` → 读得 `pte0`（`ptw_scd_addr`，`:628-629`）
3. **第 3 级**：`addr = pte0.ppn×4096 + VPN[0]×8` → 读得叶子 `pte`（`ptw_thd_addr`，`:630-631`）

每级读回 PTE 后检查 R/X：若该级 PTE 的 R 或 X 为 1，则它是叶子 —— 第 1 级叶子 = 1GB 大页，第 2 级叶子 = 2MB 大页，第 3 级叶子 = 4KB 页。否则它指向下一级页表，继续走。

---

## 5. FSM 详解（~20 态）

状态定义（`:307-326`，共 **20 个状态**）：

```verilog
parameter PTW_IDLE     = 5'b00000,   // 空闲
          PTW_FST_PMP  = 5'b00001,   // 第1级：PMP 检查
          PTW_FST_DATA = 5'b00010,   // 第1级：发访存读 pte1
          PTW_FST_CHK  = 5'b00011,   // 第1级：检查 pte1
          PTW_SCD_PMP  = 5'b00100,   // 第2级 PMP
          PTW_SCD_DATA = 5'b00101,   // 第2级 读 pte0
          PTW_SCD_CHK  = 5'b00110,   // 第2级 检查
          PTW_THD_PMP  = 5'b00111,   // 第3级 PMP
          PTW_THD_DATA = 5'b01000,   // 第3级 读 pte
          PTW_THD_CHK  = 5'b01001,   // 第3级 检查（必为叶子）
          PTW_ACC_FLT  = 5'b01010,   // access fault
          PTW_PGE_FLT  = 5'b01011,   // page fault
          PTW_DATA_VLD = 5'b01100,   // 翻译有效，等回填
          PTW_ABT_DATA = 5'b01101,   // abort 中等访存返回
          PTW_ABT      = 5'b01110,   // abort
          PTW_MACH_PMP = 5'b01111,   // M 态 PMP
          PTW_1G_CRS1  = 5'b10000,   // 1G 大页跨区检查 1
          PTW_1G_CRS2  = 5'b10001,   // 1G 跨区检查 2
          PTW_2M_CRS1  = 5'b10010,   // 2M 跨区检查 1
          PTW_2M_CRS2  = 5'b10011;   // 2M 跨区检查 2
```

主转移逻辑（`:384-528`）。典型主线（4K 页，无异常）：

```
IDLE --jtlb_ptw_req--> FST_PMP --!deny--> FST_DATA --data_vld--> FST_CHK
  --!leaf--> SCD_PMP --> SCD_DATA --> SCD_CHK
  --!leaf--> THD_PMP --> THD_DATA --> THD_CHK --> DATA_VLD --grant--> IDLE
```

几个关键分支：

- **每级 DATA 态**等访存返回（`lsu_mmu_data_vld`），总线错则转 `PTW_ACC_FLT`（`:401-407` 等）。
- **每级 CHK 态**：缺页转 `PTW_PGE_FLT`；命中大页（`ptw_hit_1g`/`ptw_hit_2m`）且未开 MAEE 则进跨区检查（`PTW_1G_CRS1`/`PTW_2M_CRS1`），开了 MAEE 直接 `PTW_DATA_VLD`（`:408-420`、`:437-449`）。
- **abort**：`tlboper_ptw_abort`（sfence 来打断）时按 `ptw_nxt_abt_st` 跳转（`:332-333`、`:344-367`），保证遍历中途被 sfence 打断能安全收尾。
- **DATA_VLD**：等 `arb_ptw_grant`（拿到回填 JTLB 的授权）后回 IDLE（`:485-491`）。

> ~20 态分三组：三级遍历各 3 态（PMP→DATA→CHK）共 9 态、异常/完成/abort 共 6 态、大页跨区检查 4 态、M 态 PMP 1 态。

---

## 6. 访存地址生成（走 LSU、无 PTE cache）

### 6.1 三级地址

```verilog
ptw_fst_addr = {satp.ppn, VPN[26:18], 3'b0};        // :625-627
ptw_scd_addr = {pte1.ppn, VPN[17:9],  3'b0};        // :628-629（pte1 = lsu_mmu_data）
ptw_thd_addr = {pte0.ppn, VPN[8:0],   3'b0};        // :630-631
```

`×8` 即低 3 位补零（每 PTE 8 字节）。当前请求地址 `ptw_req_addr` 按当前态选择（`:633-636`），并在每次 `lsu_mmu_data_vld` 时推进到下一级（`:599-600`）。

### 6.2 借 LSU 访存口

```verilog
assign mmu_lsu_data_req      = ptw_data_req;             // :762（DATA 态发请求）
assign mmu_lsu_data_req_addr = ptw_req_addr[39:0];       // :763
assign mmu_lsu_data_req_size = 1'b1;                     // :764（8 字节）
```

读回的 64 位 PTE 存入 `lsu_data_flop`（`:575-593`）。**没有独立 PTE cache**：页表读直接走 LSU 通路，天然命中 L1/L2 D-Cache，省一份专用 cache 的面积；代价是要和真正的 load/store 争 LSU 口，但页表遍历是低频事件，划算。

### 6.3 PTE 属性抽取

```verilog
assign ptw_flg[8:0] = {lsu_data_flop[9:6], lsu_data_flop[4:0]};   // :639 → D A G U X W R V（去掉 bit5 的 G 另取）
assign ptw_ref_g    = lsu_data_flop[5];                           // :721 global
assign ptw_ref_pma[4:0] = cp0_mmu_maee ? lsu_data_flop[63:59]     // :709-710 扩展 PMA（SO/C/B/SH/Sec）
                                       : sysmap_mmu_flg3[4:0];     //   否则用 sysmap 区属性
```

---

## 7. 叶子判定、大页与跨区检查

### 7.1 叶子与大页

```verilog
assign ptw_hit_1g = ptw_chk_fst && ptw_flg[0] && (ptw_flg[1] || ptw_flg[3]);  // :641 第1级是叶子=1G
assign ptw_hit_2m = ptw_chk_scd && ptw_flg[0] && (ptw_flg[1] || ptw_flg[3]);  // :642 第2级是叶子=2M
assign ptw_leaf_vld = ptw_hit_1g || ptw_hit_2m || ptw_chk_thd;                // :655（第3级必为叶子）
```

即 V=1 且 (R=1 或 X=1) 表示叶子 PTE。命中页大小记入 `ref_pgs`（`:617-622`）。

### 7.2 大页对齐检查

大页要求其 PPN 低位对齐：1G 页 PPN 低 18 位必须为 0、2M 页低 9 位必须为 0，否则缺页（`:683-684`）：

```verilog
||  ptw_hit_1g && lsu_data_flop[27:10] != 18'b0   // 1g 未对齐
||  ptw_hit_2m && lsu_data_flop[18:10] != 9'b0    // 2m 未对齐
```

### 7.3 跨区（cross）检查

大页可能横跨多个 sysmap PMA 区（属性不一致），未开 MAEE 时 PTW 用 `PTW_1G_CRS1/CRS2`、`PTW_2M_CRS1/CRS2` 把大页拆查 sysmap：记录起点的 hit 向量（`:691-697`），再比对结束点（`:698`）：

```verilog
assign ptw_chk_cross = ptw_crs2_chk && (ptw_hit_num != sysmap_mmu_hit3);  // :698 跨区了
```

若跨区，则把该大页**降级**（1G→2M→4K，见 `:511-522` 的状态转移与 `:619-622` 的 `ref_pgs` 改写），保证回填的 TLB 项属性统一。

---

## 8. page fault 与 access fault

### 8.1 page fault

集中在 `:671-687`，覆盖 RISC-V 规定的全部缺页情形：

```verilog
ptw_page_flt = ((!ptw_flg[0]                                  // V=0
   || !(flg[1] || mxr&&flg[3]) && flg[2]                      // 只写不读
   || (!flg[1] && load && !(mxr&&flg[3])                      // load 不可读
   || !flg[2] && store                                        // store 不可写
   || !flg[3] && fetch                                        // 取指不可执行
   ||  flg[4] && supv && !sum                                 // S 访 U 页且 SUM=0
   || !flg[4] && user                                         // U 访 S 页
   || !flg[5]                                                 // A=0
   || !flg[6] && store                                        // store 时 D=0
   ||  1g 未对齐 || 2m 未对齐
   ) && ptw_leaf_vld)
   || !flg[1] && !flg[3] && ptw_chk_thd);                     // 第3级非叶子（无 R/X）
```

访问类型由 `ptw_type` 解码（`:666-669`：fetch=011 / load=010 / store=110 / pref=100）。fault 时进 `PTW_PGE_FLT`，输出 `ptw_jtlb_ref_pgflt`（`:707/776`）。

### 8.2 access fault

来自总线错或 PMP 拒绝（`:648-653`）：

```verilog
ptw_pmp_deny = (fetch && !pmp_flg3[2] || load && !pmp_flg3[0]
             || store && !pmp_flg3[1] || pref && !pmp_flg3[0])
             && !(mach_mode && !pmp_flg3[3]);   // M 态 L-bit
```

进 `PTW_ACC_FLT`，输出 `ptw_jtlb_ref_acc_err`（`:706/775`）。

---

## 9. 回填 JTLB（FIFO 选路）

遍历成功（`PTW_DATA_VLD`）后经 arb 把结果写回 JTLB（`:786-796`）：

```verilog
assign ptw_arb_req      = ptw_ref_data_vld && !arb_ptw_mask;          // :786
assign ptw_arb_vpn      = ptw_ref_vpn;                                // :788（按页大小掩码后的 VPN，:712-715）
assign ptw_arb_pgs      = ptw_ref_pgs;                                // :789
assign ptw_arb_fifo_din = {ptw_ref_fifo[2:0], ptw_ref_fifo[3]};       // :791 轮转 FIFO 指针
assign ptw_arb_tag_din  = {1'b1, ref_vpn, cur_asid, ref_pgs, ref_g};  // :792-794 组装 48 位 tag（含 16 位 ASID）
assign ptw_arb_data_din = {ref_ppn, ref_flg};                         // :795-796 组装 42 位 data
```

注意几点：

- **回填 JTLB 时才把 16 位 ASID 写进去**（`regs_ptw_cur_asid`，`:793`）—— 这正是"ASID 只存 JTLB"的写入点。
- **FIFO 指针轮转一格**（`:791`）：`ptw_ref_fifo` 选自 JTLB 传来的 `jtlb_xx_fifo` 按当前页大小取 4 位（`:722-724`），写回时轮转，实现 round-robin 替换。
- `ptw_jtlb_ref_data_vld` 在 `arb_ptw_grant` 时有效（`:774`），完成 `ptw_ref_cmplt`（`:701-703`）。

回填 JTLB 后，JTLB 再把同一项回填给最初发起 miss 的 uTLB（见 03 篇 9.3），整条 miss 链闭合。

---

## 设计取舍小结

- **状态机串行三级遍历**：每级 PMP→DATA→CHK 三态，结构规整；20 态里 9 态主遍历、6 态异常/完成/abort、4 态大页跨区、1 态 M 态 PMP。
- **无独立 PTE cache，借 LSU 访存口**：页表读自然命中 D-Cache，省专用 cache 面积；低频事件，争口代价可接受。
- **大页降级保属性一致**：未开 MAEE 时用跨区检查把横跨多 PMA 区的大页降级，保证回填项属性统一。
- **回填即写 ASID + 轮转 FIFO**：PTW 是把 ASID 写进 JTLB 的唯一来源之一，并在回填时推进 round-robin 替换指针。
- **abort 安全收尾**：遍历中被 sfence 打断时按 `ptw_nxt_abt_st` 跳转，等访存返回再退出，不留悬挂访存。

*文档覆盖 ct_mmu_ptw.v 全部 806 行逻辑。*
