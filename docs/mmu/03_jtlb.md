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
5. [tag 内容：JTLB 翻译项保存 ASID](#5-tag-内容jtlb-翻译项保存-asid)
6. [global 位与命中逻辑](#6-global-位与命中逻辑)
7. [4K/2M/1G 页与读 FSM](#7-4k2m1g-页与读-fsm)
8. [FIFO-like one-hot 轮转替换](#8-fifo-like-one-hot-轮转替换)
9. [miss 触发 PTW 与回填 uTLB](#9-miss-触发-ptw-与回填-utlb)
10. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

JTLB（Joint TLB，联合 TLB）是 MMU 存储层次的**二级、大容量 TLB**（类比 L2 Cache）。它用 SRAM 实现 256 组 ×4 路 = 1024 项的组相联结构，接住 iuTLB/duTLB 漏下来的 miss。命中则把翻译结果回填回 uTLB；miss（4K/2M/1G 都没中）则触发 PTW 做页表遍历。它还承担 TLB 维护操作（sfence/tlbr/tlbp/tlbwi/tlbwr）的实际读写。

### 1.2 位置

它的外部访问都经 arb 串行进入（指令侧、数据侧、预取、sfence、PTW 回填
共享同一个 JTLB 端口）；4KB miss 后的 2MB/1GB 重查和 parity-clear 则由
JTLB 反馈给 arb 形成内部请求。结果回 uTLB（`jtlb_utlb_ref_*`）、回 PTW
（`jtlb_ptw_req`）或回 tlboper/regs（probe/read 结果）。

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
| `ASID_WIDTH` | **16** | 地址空间标识；翻译缓存项中仅 JTLB tag 保存 |
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

- **物理 SRAM 索引 8 位** → 256 组（`jtlb_tag_idx/jtlb_data_idx =
  arb_jtlb_idx[7:0]`）。
- **4 路**（way0~way3）。
- 256 × 4 = **1024 项**。

arb 会先按候选页大小生成 9-bit `arb_va_index`：4KB 取 VPN[8:0]、2MB 取
VPN[17:9]、1GB 取 VPN[26:18]。但 JTLB SRAM 实际只使用该索引的低 8 位；
第 9 位仍保留在完整 27-bit VPN tag 中参与比较。以 4KB 为例，set 由
VPN[7:0]选择，VPN[8]不是丢失，而是 tag 的一部分。因而“9-bit 候选页段”
和“8-bit 物理 set index”必须分开描述。

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

注意：轮转指针存在 tag 阵列里，可与 tag 同读、在回填时同写。这节省的是
独立状态阵列/端口和普通 hit 更新控制，不是指针 bit 数本身。

### 4.3 data 阵列：2 bank × 256×84 SRAM

`ct_mmu_jtlb_data_array.v` 用**两个** `ct_spsram_256x84`（bank0 `:179`、bank1 `:158`），每 bank 84 位 = 2 路 × 42 位（28 PPN + 14 flg）。bank0 装 way0/way1，bank1 装 way2/way3。两 bank 独立的 cen0/cen1 允许按需激活以省功耗。

### 4.4 顶层例化与实际流水阶段

`ct_mmu_jtlb.v` 例化 tag_array（`:609` 附近）和 data_array（`:622` 附近），读出后解包成 4 路 tag/data。

一次 JTLB 查找不是组合 SRAM 查表。RTL 注释和寄存器将它分成三段：

1. **RB/arb 输入段**：`arb_jtlb_req`驱动 SRAM 的 CEN、index 和 bank select；
2. **TA（TLB Access）段**：SRAM 输出被解包，按当前页大小形成 VPN/ASID/G
   子比较条件；`ta_vld`和请求控制在时钟沿登记；
3. **TC（TLB Compare）段**：比较子条件、四路 data、原 VPN 和访问类型再次
   登记，随后形成 `tc_tlb_hit/miss/hit_mult`与返回数据。

若 4KB 候选 miss，TC 结果使 arb 以 2MB 候选 index 再发一轮 SRAM 访问；
再 miss 才查 1GB。因此“JTLB 命中延迟”至少要区分首次 4KB 命中和经过一到
两轮重查的大页命中，不能只给一个脱离接口参考点的固定周期数。

---

## 5. tag 内容：JTLB 翻译项保存 ASID

### 5.1 每路 48 位 tag 的结构

读出后解包（`ct_mmu_jtlb.v:698-708`，以 way3 为例）：

```verilog
assign {ta_way3_vld, ta_way3_vpn[26:0], ta_way3_asid[15:0],
        ta_way3_pgs[2:0], ta_way3_g} = ta_jtlb_way3_tag[47:0];
```

即每路 tag = `{valid(1), VPN(27), ASID(16), pagesize(3), global(1)}` = 48 位。way0~way2 同构（`:701-708`）。

### 5.2 为什么 JTLB 翻译项保存 ASID

回顾存储层次：uTLB（iuTLB/duTLB）表项不存 ASID，写 satp 时整表清空。
JTLB tag 保存 16 位 ASID + global 位，普通 satp 写不会逐项清 JTLB，后续
命中靠当前 ASID 或 G 位区分。这里的“只存 JTLB”仅限定**翻译缓存项**；
satp、MEH/MCIR 等控制寄存器当然也保存或传递 ASID。

这背后是清晰的成本权衡：

| | uTLB（小，32/16 项） | JTLB（大，1024 项） |
|--|--|--|
| 存 ASID 的字段代价 | iuTLB 32×16 / duTLB 17×16 可省去 | JTLB 1024×16 已包含在 tag SRAM |
| 切换时清空的代价 | 很小（几十项重新暖机即可） | 巨大（清 1024 项 = 抹掉好不容易暖好的大表） |
| 决策 | **不存 ASID，切换时清空** | **存 ASID，切换时保留** |

这体现了“小表写 satp 后重新暖机、大表保留不同地址空间翻译”的策略。至于
该选择的面积和性能净收益，属于设计取舍，需要 workload 与综合数据验证，
不是仅凭 RTL 容量就能量化的结论。

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
assign tc_tlb_hit_mult = !miss && !hit && !par_fail;   // 同一候选有多于一路命中
```

命中路号 `tc_hit_idx[1:0]`（`:926-929`）。多命中在 I/D 请求路径被映射到
`jtlb_*utlb_pgflt`，TLBP 则通过 `jtlb_regs_hit_mult`写入 MIR 的
`tlbp_tfatal`；它不是普通的“任选一路继续”。注：parity 当前置 0
（`:786 tc_par_fail=1'b0`），是预留的奇偶校验钩子。

---

## 7. 4K/2M/1G 页与读 FSM

### 7.1 一项可能是任意页大小，所以要逐尺寸试

JTLB 一项可缓存 4KB/2MB/1GB 任一页。候选页段分别取 VPN[8:0]、
VPN[17:9]、VPN[26:18]；每段的低 8 位选择物理 set，第 9 位留在完整 VPN
tag 中。比较时再按页大小把 VPN 低 0/9/18 位清零，并要求 tag 的 `pgs`
等于当前候选。一次查找因此可能依次访问三个不同 set。

read FSM 正是干这个：先按 4KB 候选 set 读并比较，miss 后经
`arb_read_huge`重新发起 2MB 候选 set，再 miss 才发起 1GB 候选 set。页覆盖
范围是逐步增大，不应写成“降尺寸”。命中任一层即结束；三种页大小都 miss
才是真正 JTLB miss。

```verilog
assign read_cur_4k = read_cur_st == READ_4K;
assign read_cur_2m = read_cur_st == READ_2M;
assign read_cur_1g = read_cur_st == READ_1G;
```

### 7.2 主命中比较的 VPN 对齐

TA 段按当前尝试的页大小把请求 VPN 的页内 VPN 低位清零，再与 tag 中按页
大小对齐保存的 VPN 比较：

```verilog
ta_vpn_4k = ta_vpn;
ta_vpn_2m = {ta_vpn[26:9],  9'b0};   // 2MB：低 9 位清零
ta_vpn_1g = {ta_vpn[26:18],18'b0};   // 1GB：低 18 位清零
```

源码后部另有名称相近的 `tc_vpn_2m={9'b0,tc_vpn[26:9]}`和
`tc_vpn_1g={18'b0,tc_vpn[26:18]}`。那两条逻辑是把页大小对应的 9-bit
物理 set index **右对齐**，用于组装 `jtlb_regs_tlbp_hit_index`，不是主
命中比较的掩码。两组逻辑方向相反、用途不同。

### 7.3 真 miss 的判定

只有走到 `READ_1G` 仍未命中才确认 miss（`:1135`）：

```verilog
assign tc_tlb_miss_fin = (tc_vld && tc_cmp_va && tc_tlb_miss || tc_par_fail) && read_cur_1g;
```

---

## 8. FIFO-like one-hot 轮转替换

### 8.1 准确定性：它简单在更新，不是简单在位数

每个物理 set 保存一个 4-bit one-hot 指针。普通命中不会根据被命中的 way
更新它；PTW refill 或 TLBWR 使用当前 one-hot 选择牺牲 way，随后按
`{fifo[2:0],fifo[3]}`旋转。因此它既可称 FIFO-like，也可称 4-way
round-robin replacement，但不记录严格的时间队列。

不能再说它“比 PLRU 省状态位”：4-way tree-PLRU 通常需要 3 bit/set，而这里
是 4 bit/set。当前 RTL 可直接证明的优势是：

- one-hot 指针可直接作为 `bank_sel[3:0]`，无需再解码路号；
- 普通 hit 不更新替换状态，避免 hit 路径上的状态写回；
- 指针与 tag 共用 SRAM 行和写端口，回填时可同时写 tag 与旋转后的指针。

这些会简化控制，但面积、时序和命中率优劣仍需综合与性能测试，不能从源码
直接下结论。

### 8.2 fifo 指针的存储与轮转

物理上，每个 SRAM set 只存 4 bit。一次普通 VA 查找可能依次访问三个不同
set；JTLB 在 4KB、2MB、1GB 三次候选访问之间把每次读到的 4 bit 累积到
`tc_jtlb_fifo[11:0]`：

```text
[3:0]   = 4KB 候选 set 的指针
[7:4]   = 2MB 候选 set 的指针
[11:8]  = 1GB 候选 set 的指针
```

这 12 bit 是**本次查找的临时汇总**，不是每个 set 存了 12 bit。三种索引若
碰巧落到同一物理 set，也只是多次读取同一行。最终 PTW 根据实际叶子页大小
选择对应 4-bit slice 作为 `ptw_arb_bank_sel`，并把旋转后的 one-hot 值写回
该页大小对应的 set。

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

同时把三次候选 set 累积的 `jtlb_xx_fifo[11:0]`交给 PTW。PTW 发现实际叶子
页大小后，从对应 slice 取 4-bit 指针选择 way。

### 9.2 PTW 回填进 JTLB

PTW 遍历完成后，经 arb 把结果写回 JTLB（输入 `ptw_jtlb_ref_ppn/pgs/flg`、`ptw_jtlb_ref_cmplt/data_vld` 等），写的 tag/data/fifo 由 arb 转发（见 05 篇）。

### 9.3 回填 uTLB

JTLB 命中时，`tc_pa_vld`与访问类型共同产生对应
`jtlb_*utlb_ref_pavld`；PTW 完成时则由 `ptw_jtlb_ref_data_vld`旁路提供同一
组 refill 数据。`ref_cmplt`表示这次查找已结束，`ref_pavld`表示有可写入的
翻译，两者不能互换：page fault、access fault或禁用 PTW后的最终 miss 可以
完成，但没有有效 PA refill。

### 9.4 PFU 是直接查 JTLB，不经过 duTLB

`lsu_mmu_va2[27:0]`是一条独立页号接口。MMU 开启时，arb 以低 27 位 VPN
直接查询 JTLB；命中或 PTW 成功后，JTLB 根据页大小把请求 VPN 的低位补入
PPN，再进入 `PFU_CHK`检查页权限/PMA和 PMP 读许可，最终用
`mmu_lsu_pa2_vld/err`返回 28-bit PPN。MMU 关闭时则把 28 位输入直接当 PPN，
属性来自 sysmap。该通道只返回 PFU 需要的 `sec/share`，不是 duTLB
`ca/buf/so`接口的第三份副本。

---

## 本章小结

JTLB 用 256 组 4 路 SRAM 保存 1024 项翻译，作为 iuTLB/duTLB miss 后的共享后备层。tag 中保存 VPN、ASID、global 和页尺寸等匹配信息，data 中保存 PPN、权限与属性。写 satp 会清 uTLB，但不会直接扫描 JTLB；普通项依靠 ASID 匹配隔离地址空间，global 项旁路 ASID，并在按 ASID 维护时保留。由于不同页尺寸使用不同 VPN 索引和比较位数，read FSM 按 4KB、2MB、1GB 顺序逐级搜索，只有最后一级也未命中才形成真实 miss；因此一次请求可能产生多次 SRAM 访问，不能把首拍未命中当成 JTLB 最终 miss。

每组替换状态是 4 位 one-hot 轮转指针，普通命中不更新，只有成功回填时选中当前路并旋转。指针随 tag 一同读写，`jtlb_xx_fifo[11:0]` 只是一次多页尺寸查找过程中的临时汇总，不是 12 项请求 FIFO。维护、正常查找和 PTW 回填共享 SRAM 端口，实际接受还受仲裁和状态机约束。波形分析应区分外部 request、arb grant、各页尺寸 SRAM read、tag compare、最终 hit/miss、PTW 完成以及 refill grant；只有 refill grant 才真正写入新项并推进轮转指针。替换策略的命中率和 SRAM 实现的面积、时序收益仍需测量结果支持。
