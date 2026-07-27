# C910 MMU JTLB（联合 TLB）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_jtlb.v`（约 1456 行）
>
> 相关文件：`ct_mmu_jtlb_tag_array.v`（153 行，tag SRAM 封装）、`ct_mmu_jtlb_data_array.v`（224 行，data SRAM 封装）、`ct_spsram_256x196.v`/`ct_spsram_256x84.v`（物理 SRAM）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [1024 = 256×4 的 SRAM 组织](#4-1024--2564-的-sram-组织)
5. [tag 内容：ASID 16 位只存这里](#5-tag-内容asid-16-位只存这里)
6. [global 位与命中逻辑](#6-global-位与命中逻辑)
7. [4K/2M/1G 页与读 FSM](#7-4k2m1g-页与读-fsm)
8. [FIFO 替换](#8-fifo-替换)
9. [miss 触发 PTW 与回填 uTLB](#9-miss-触发-ptw-与回填-utlb)
10. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

JTLB（Joint TLB，联合 TLB）是 MMU 存储层次的**二级、大容量 TLB**（类比 L2 Cache）。它用 SRAM 实现 256 组 ×4 路 = 1024 项的组相联结构，接住 iuTLB/duTLB 漏下来的 miss。命中则把翻译结果回填回 uTLB；miss（4K/2M/1G 都没中）则触发 PTW 做页表遍历。它还承担 TLB 维护操作（sfence/tlbr/tlbp/tlbwi/tlbwr）的实际读写。

### 1.2 位置

它的所有访问都经 arb 串行进来（指令侧、数据侧、预取、sfence、PTW 回填共享同一个 JTLB），输出回 uTLB（`jtlb_utlb_ref_*`）、回 PTW（`jtlb_ptw_req`）、回 tlboper/regs（probe/read 结果）。

---

## 2. 端口说明

### 2.1 arb 输入（统一入口）

| 信号 | 方向 | 含义 |
|------|------|------|
| `arb_jtlb_req` | in | 访问请求 |
| `arb_jtlb_vpn` | in | 待比较 VPN（cmp tag） |
| `arb_jtlb_idx[8:0]` | in | SRAM 索引 |
| `arb_jtlb_bank_sel[3:0]` | in | 4 路 way 选择 |
| `arb_jtlb_write` / `_fifo_write` | in | 写 tag/data / 写 fifo 指针 |
| `arb_jtlb_tag_din[47:0]` / `_data_din[41:0]` / `_fifo_din[3:0]` | in | 写数据 |
| `arb_jtlb_acc_type[2:0]` | in | 访问类型（I/D-load/D-store/PFU/sfence/PTW） |
| `arb_jtlb_cmp_with_va` | in | 是否做 VA 比较（查找 vs 直接索引） |

### 2.2 回 uTLB / PTW

| 信号 | 方向 | 含义 |
|------|------|------|
| `jtlb_utlb_ref_vpn/ppn/pgs/flg` | out | 命中后回填 uTLB 的表项 |
| `jtlb_iutlb_ref_pavld`/`ref_cmplt`、`jtlb_dutlb_ref_*` | out | 回填有效/完成 |
| `jtlb_ptw_req` / `jtlb_ptw_vpn` / `jtlb_ptw_type` | out | miss 触发 PTW |
| `jtlb_xx_fifo[11:0]` | out | 给 PTW 的 fifo 指针（回填选路用） |
| `ptw_jtlb_ref_*` | in | PTW 回填进 JTLB 的内容 |

### 2.3 tlboper / regs（维护）

| 信号 | 方向 | 含义 |
|------|------|------|
| `jtlb_tlboper_cmplt`/`va_hit`/`asid_hit`/`sel`/`fifo` | out | sfence/probe 反馈 |
| `jtlb_tlbr_vpn/ppn/asid/flg/g/pgs` | out | TLBR 读出的整项（给 regs） |
| `jtlb_regs_hit`/`hit_mult`/`tlbp_hit_index` | out | TLBP probe 结果 |

---

## 3. 参数与关键寄存器

`ct_mmu_jtlb.v:520-532`：

| 参数 | 值 | 含义 |
|------|----|------|
| `VPN_WIDTH` | 27 | 虚拟页号 |
| `PPN_WIDTH` | 28 | 物理页号 |
| `FLG_WIDTH` | 14 | 属性标志 |
| `PGS_WIDTH` | 3 | 页大小 |
| `ASID_WIDTH` | **16** | 地址空间标识（**只在此存**） |
| `PTE_LEVEL` | 3 | 页表级数 |
| `VPN_PERLEL` | 27/3 = 9 | 每级 VPN 位数 |
| `TAG_WIDTH` | 1+27+16+3+1 = **48** | 每路 tag 位宽（`:531`） |
| `DATA_WIDTH` | 28+14 = **42** | 每路 data 位宽（`:532`） |

read FSM 状态（`:1036-1041`）：

```verilog
parameter READ_IDLE = 3'b000,
          READ_4K   = 3'b001, READ_4K_FAIL = 3'b101,
          READ_2M   = 3'b010, READ_2M_FAIL = 3'b110,
          READ_1G   = 3'b011;
```

PFU（预取）FSM（`:1281-1284`）：`PFU_IDLE/CHK/DENY/OK`。

---

## 4. 1024 = 256×4 的 SRAM 组织

### 4.1 索引与路数

- **索引 8 位** → 256 组（`:588-589` `jtlb_tag_idx[7:0] = arb_jtlb_idx[7:0]`）。
- **4 路**（way0~way3）。
- 256 × 4 = **1024 项**。

### 4.2 tag 阵列：256×196 SRAM

`ct_mmu_jtlb_tag_array.v` 封装一个 `ct_spsram_256x196`（`:117`）。196 位 = **4 路 × 48 位 tag + 4 位 fifo 指针**（4×48=192，+4=196）。写使能 `jtlb_tag_wen[4:0]`：bit0~3 各对应一路 tag（每路 48 位），bit4 对应 4 位 fifo（`ct_mmu_jtlb_tag_array.v:84-90`）：

```verilog
assign jtlb_tag_bwen[195:0] = {
    {4 {jtlb_tag_wen[4]}},   // fifo（4 位）
    {48{jtlb_tag_wen[3]}},   // way3
    {48{jtlb_tag_wen[2]}},   // way2
    {48{jtlb_tag_wen[1]}},   // way1
    {48{jtlb_tag_wen[0]}}};  // way0
```

注意：**fifo 指针存在 tag 阵列里**，和 tag 同读同写 —— 这是 FIFO 替换"省存储"的关键（见第 8 节）。

### 4.3 data 阵列：2 bank × 256×84 SRAM

`ct_mmu_jtlb_data_array.v` 用**两个** `ct_spsram_256x84`（bank0 `:179`、bank1 `:158`），每 bank 84 位 = 2 路 × 42 位（28 PPN + 14 flg）。bank0 装 way0/way1，bank1 装 way2/way3。两 bank 独立的 cen0/cen1 允许按需激活以省功耗。

### 4.4 顶层例化

`ct_mmu_jtlb.v` 例化 tag_array（`:609` 附近）和 data_array（`:622` 附近），读出后解包成 4 路 tag/data。

---

## 5. tag 内容：ASID 16 位只存这里

### 5.1 每路 48 位 tag 的结构

读出后解包（`ct_mmu_jtlb.v:698-708`，以 way3 为例）：

```verilog
assign {ta_way3_vld, ta_way3_vpn[26:0], ta_way3_asid[15:0],
        ta_way3_pgs[2:0], ta_way3_g} = ta_jtlb_way3_tag[47:0];
```

即每路 tag = `{valid(1), VPN(27), ASID(16), pagesize(3), global(1)}` = 48 位。way0~way2 同构（`:701-708`）。

### 5.2 为什么 ASID 只存 JTLB（核心教学点）

回顾存储层次：uTLB（iuTLB/duTLB）**不存 ASID**，每项隐含等于当前 satp.ASID，进程切换写 satp 时整表清空。而 **JTLB 存 16 位 ASID + global 位**，进程切换**不清空**，靠 ASID 区分新旧进程的项。

这背后是清晰的成本权衡：

| | uTLB（小，32/16 项） | JTLB（大，1024 项） |
|--|--|--|
| 存 ASID 的存储代价 | 32×16=512 bit / 16×16=256 bit | 1024×16=16384 bit（已在 SRAM，边际成本低） |
| 切换时清空的代价 | 很小（几十项重新暖机即可） | 巨大（清 1024 项 = 抹掉好不容易暖好的大表） |
| 决策 | **不存 ASID，切换时清空** | **存 ASID，切换时保留** |

**一句话：小表清得起，省掉 ASID 硬件；大表清不起，才值得花 ASID 来保命。** ASID 机制的全部价值——避免进程切换全清 TLB——正是落在这张大表上。

ASID 比较源由 tlboper 或 regs 提供（`:718-720`）：

```verilog
assign asid_for_va_hit[15:0] = tlboper_jtlb_asid_sel ? tlboper_jtlb_asid
                                                     : regs_jtlb_cur_asid;  // satp.ASID
```

---

## 6. global 位与命中逻辑

### 6.1 4 路并行命中比较

每路命中由多个"kid"子条件构成（`:723-730`，way3 示例），含 3 段 VPN 比较 + 2 段 ASID 比较 + 1 个 global 旁路：

```verilog
ta_way3_hit_kid3 = (ta_way3_asid[8:0]  == asid_for_va_hit[8:0]);    // ASID 低 9 位
ta_way3_hit_kid4 = (ta_way3_asid[15:9] == asid_for_va_hit[15:9]);   // ASID 高 7 位
ta_way3_hit_kid5 =  ta_way3_g || tlboper_jtlb_cmp_noasid;           // global 旁路
```

最终每路命中（`:876-886`）：

```verilog
assign tc_way3_hit = kid0 && kid1 && kid2
                  && (kid3 && kid4 || kid5);   // (ASID 全匹配) 或 (global)
```

**global 位的意义**：内核共享页（如内核代码、设备映射）对所有进程可见，置 G=1 后命中不比 ASID（`kid5` 旁路），这样它们能跨进程复用、sfence 按 ASID 清除时也不会被误清。

### 6.2 命中归约与多命中检测

4 路命中求和（`:1127-1133`）：

```verilog
assign tc_hit_sum[2:0] = way3_hit + way2_hit + way1_hit + way0_hit;
assign tc_tlb_miss     = (tc_hit_sum == 0);
assign tc_tlb_hit      = (tc_hit_sum == 1) && !tc_par_fail;
assign tc_tlb_hit_mult = !miss && !hit && !par_fail;   // 多路命中（错误，报 tfatal）
```

命中路号 `tc_hit_idx[1:0]`（`:926-929`）。注：parity 当前置 0（`:786 tc_par_fail=1'b0`），是预留的奇偶校验钩子。

---

## 7. 4K/2M/1G 页与读 FSM

### 7.1 一项可能是任意页大小，所以要逐尺寸试

JTLB 一项可缓存 4K/2M/1G 任一页（tag 里有 3 位 pagesize）。问题是：**索引和比较位数随页大小而变**。4K 用 VPN[8:0] 做 index、比全 27 位；2M 用 VPN[17:9] 做 index、比高 18 位；1G 用 VPN[26:18] 做 index、比高 9 位。所以一次查找可能要**依次试 4K、2M、1G 三种索引**。

read FSM（`:1036-1107`）正是干这个：`READ_4K`（命中或失败）→ `READ_2M` → `READ_1G`，逐级降尺寸搜索；三者都 miss 才算真 miss。状态解码（`:1110-1112`）：

```verilog
assign read_cur_4k = read_cur_st == READ_4K;
assign read_cur_2m = read_cur_st == READ_2M;
assign read_cur_1g = read_cur_st == READ_1G;
```

### 7.2 VPN 掩码

比较前按当前尝试的页大小对 VPN 掩码（TC 级 `:1203-1208`）：

```verilog
tc_vpn_4k = tc_vpn;
tc_vpn_2m = {9'b0, tc_vpn[26:9]};    // 抹低 9 位
tc_vpn_1g = {18'b0, tc_vpn[26:18]};  // 抹低 18 位
tc_vpn_masked = pgs[0]?4k : pgs[1]?2m : pgs[2]?1g;
```

### 7.3 真 miss 的判定

只有走到 `READ_1G` 仍未命中才确认 miss（`:1135`）：

```verilog
assign tc_tlb_miss_fin = (tc_vld && tc_cmp_va && tc_tlb_miss || tc_par_fail) && read_cur_1g;
```

---

## 8. FIFO 替换

### 8.1 为什么 JTLB 用 FIFO 而不是 PLRU（核心教学点）

uTLB 用 tree-PLRU 拼命中率（小表，命中率敏感、状态位代价小）；**JTLB 用 FIFO（轮转指针）省存储**：

- 大表本身命中率已很高，替换策略的边际收益小；
- 给 256 组各做 per-set tree-PLRU 要额外维护状态并和 SRAM 同步读改写，代价不划算；
- FIFO 每组只需 **4 位指针**（4 路轮转），还能塞进 tag SRAM 跟着一起读写，几乎零额外面积。

**用一点命中率换大量存储与复杂度** —— 这是大表的正确选择。

### 8.2 fifo 指针的存储与轮转

4 位 fifo 指针随 tag 一起存在 256×196 SRAM 里（见 4.2 节）。读出后在 TC 级寄存为 12 位 `tc_jtlb_fifo`（4K/2M/1G 各 4 位，`:429`），输出给 PTW 的 `jtlb_xx_fifo[11:0]`（`:933`）。

回填一项时，指针轮转一格指向下一个将被替换的 way。轮转模式 `{fifo[2:0], fifo[3]}`（在 PTW 侧 `ct_mmu_ptw.v:791` 生成 `ptw_arb_fifo_din = {ptw_ref_fifo[2:0], ptw_ref_fifo[3]}`；JTLB 内 `:889-902` 也据当前页大小把新指针拼回 12 位写回 tag）。one-hot 的 fifo 位即指明"下一个被覆盖的 way"，相当于一个 4 路 round-robin 计数器。

---

## 9. miss 触发 PTW 与回填 uTLB

### 9.1 触发 PTW

确认 miss 后向 PTW 发请求（`:1184-1187`）：

```verilog
assign jtlb_ptw_req      = tc_vld && cp0_mmu_ptw_en && tc_tlb_miss_fin
                        && (tc_acc_type[1] || tc_acc_type[2]);
assign jtlb_ptw_vpn      = tc_vpn;
assign jtlb_ptw_type[2:0]= tc_acc_type;   // I / D-load / D-store / PFU
```

同时把 `jtlb_xx_fifo`（当前组的 fifo 指针）一并交给 PTW，PTW 回填时据此选 way。

### 9.2 PTW 回填进 JTLB

PTW 遍历完成后，经 arb 把结果写回 JTLB（输入 `ptw_jtlb_ref_ppn/pgs/flg`、`ptw_jtlb_ref_cmplt/data_vld` 等），写的 tag/data/fifo 由 arb 转发（见 05 篇）。

### 9.3 回填 uTLB

JTLB 命中（或 PTW 刚回填）后，把整项经 `jtlb_utlb_ref_vpn/ppn/pgs/flg` 回填给发起请求的 uTLB（iuTLB 或 duTLB），并拉 `jtlb_iutlb_ref_pavld`/`jtlb_dutlb_ref_pavld`。uTLB 看到的就是这组信号，对 PTW 是否介入无感。

---

## 设计取舍小结

- **SRAM 组相联（256×4=1024）**：比全相联省面积，容量大，作为 uTLB 的后备 L2 层。
- **ASID 只存这里 + 不清空**：进程切换清小表保大表，ASID 机制的价值全落在这张大表上。
- **global 位旁路 ASID**：内核共享页跨进程复用、按 ASID 清时不被误清。
- **FIFO 替换（4 位/组，塞进 tag SRAM）**：大表用最简策略省存储，用一点命中率换面积与复杂度。
- **read FSM 逐尺寸搜索（4K→2M→1G）**：一项可任意页大小，靠状态机依次试不同索引/比较位数，直到 1G 才判真 miss。
- **fifo 指针随 tag 同读同写**：零额外 SRAM 端口，回填时轮转一格即完成替换。

*文档覆盖 ct_mmu_jtlb.v / _tag_array.v / _data_array.v 及 SRAM 封装的全部关键逻辑（jtlb.v 约 1456 行）。*
