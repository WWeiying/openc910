# C910 MMU iuTLB（指令微 TLB）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_iutlb.v`（约 2340 行）
>
> 相关文件：`ct_mmu_iutlb_entry.v`（256 行，普通表项）、`ct_mmu_iutlb_fst_entry.v`（259 行，fast entry）、`ct_mmu_iplru.v`（1174 行，tree-PLRU）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [32 项全相联表项结构](#4-32-项全相联表项结构)
5. [命中比较与 fast entry 机制](#5-命中比较与-fast-entry-机制)
6. [tree-PLRU 替换（ct_mmu_iplru.v）](#6-tree-plru-替换ct_mmu_iplruv)
7. [miss → JTLB → 回填 流程](#7-miss--jtlb--回填-流程)
8. [异常生成](#8-异常生成)
9. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

iuTLB 是**取指侧的一级微 TLB**：IFU 发来取指虚拟地址，iuTLB 在当拍内并行比较 32 个表项，命中则立刻给出物理页号 + 取指权限（X/U）+ PMA 属性。它是 MMU 存储层次里最快最小的一层（类比 L1 I-Cache）。miss 时它启动 refill 状态机，经 arb 去查 JTLB，拿到结果回填后重试。

### 1.2 位置

上游是 IFU（`ifu_mmu_va`/`ifu_mmu_va_vld`），下游命中给 IFU（`mmu_ifu_pa`/`mmu_ifu_pavld`），miss 时下游是 arb→JTLB。它**不存 ASID**，进程切换写 satp 时由 `regs_utlb_clr` 整表清空。

---

## 2. 端口说明

### 2.1 IFU 接口

| 信号 | 方向 | 含义 |
|------|------|------|
| `ifu_mmu_va` / `ifu_mmu_va_vld` | in | 取指 VA 及有效 |
| `ifu_mmu_abort` | in | IFU 撤销 |
| `mmu_ifu_pa` / `mmu_ifu_pavld` | out | 翻译结果 PA / 有效 |
| `mmu_ifu_pgflt` | out | page fault（`ct_mmu_iutlb.v:607`） |
| `mmu_ifu_deny` | out | access fault（`:611-614`） |

### 2.2 arb / JTLB 接口

| 信号 | 方向 | 含义 |
|------|------|------|
| `iutlb_arb_req` | out | 向 arb 请求查 JTLB（`:851`） |
| `iutlb_arb_vpn` | out | 待查 VPN（`:852`） |
| `iutlb_arb_cmplt` | out | refill 完成（`:867-868`） |
| `jtlb_iutlb_ref_pavld`/`ref_cmplt` | in | JTLB 回填有效/完成 |
| `jtlb_utlb_ref_vpn/ppn/pgs/flg` | in | JTLB 回填的表项内容（`:1906-1909`） |
| `arb_iutlb_grant` | in | arb 授权 |

### 2.3 PLRU / 系统

| 信号 | 方向 | 含义 |
|------|------|------|
| `plru_iutlb_ref_num` | (内部) | iplru 给出的牺牲项 one-hot（`:663`） |
| `regs_utlb_clr` | in | satp 写入触发整表清空 |
| `tlboper_utlb_clr` / `tlboper_utlb_inv_va_req` | in | sfence 清表/按 VA 清 |
| `cp0_mmu_icg_en` | in | 时钟门控使能 |

---

## 3. 参数与关键寄存器

表项字段宽度（`ct_mmu_iutlb.v:495-498`）：

| 参数 | 值 | 含义 |
|------|----|------|
| `VPN_WIDTH` | 39-12 = 27 | 虚拟页号 |
| `PPN_WIDTH` | 40-12 = 28 | 物理页号 |
| `FLG_WIDTH` | 14 | 属性标志 |
| `PGS_WIDTH` | 3 | 页大小 one-hot |

refill 状态机状态定义（`:761-766`）：

```verilog
parameter IDLE  = 3'b000,   // 空闲
          WFG   = 3'b001,   // Waiting For Grant：等 arb 授权
          WFC   = 3'b010,   // Waiting For Completion：等 JTLB 回填
          PGFLT = 3'b100,   // page fault
          ACFLT = 3'b110,   // access fault
          ABT   = 3'b011;   // abort
```

当前态寄存器 `ref_cur_st[2:0]`（`:778`）。

---

## 4. 32 项全相联表项结构

iuTLB 共 **32 个表项**，全部用寄存器实现、全相联（每项独立比较，无 index）。例化分两种：

- **fast entry**（`ct_mmu_iutlb_fst_entry`）共 **4 个**，例化于 `ct_mmu_iutlb.v:895`（entry0）、`:1144`（entry8）、`:1393`（entry16）、`:1642`（entry24）。
- **普通 entry**（`ct_mmu_iutlb_entry`）共 **28 个**，编号 1~7、9~15、17~23、25~31（例化散布在 `:927`~`:1870`）。

每个表项（见 `ct_mmu_iutlb_entry.v:73-77`）存：

```verilog
reg        utlb_vld;        // 有效位
reg [26:0] utlb_vpn;        // 虚拟页号
reg [2 :0] utlb_pgs;        // 页大小 one-hot
reg [27:0] utlb_ppn;        // 物理页号
reg [13:0] utlb_flg;        // 14 位属性（5 PMA + 9 权限）
```

注意：**没有 ASID 字段**。注释明确写道（`ct_mmu_iutlb_entry.v:127-128`）：
> 1. ASID field are not included in uTLB entry
> 2. Each Data uTLB entry always matches the ASID in the SATP register

每项隐含等于 satp 当前 ASID，因此进程切换写 satp（`regs_utlb_clr`）就整表清掉，无需逐项比 ASID。

表项内部还实现三处清除条件（`ct_mmu_iutlb_entry.v:164-171`）：satp 写（`regs_utlb_clr`）、sfence 全清（`tlboper_utlb_clr`）、按 VA 清且 VA 命中（`ctc_inv_va_hit_clr`，比较 `lsu_mmu_tlb_va[7:0]==utlb_vpn[7:0]`）。

---

## 5. 命中比较与 fast entry 机制

### 5.1 多页大小的命中比较

每项的命中按页大小决定比较多少位 VPN（`ct_mmu_iutlb_entry.v:229-238`）：

```verilog
assign vpn2_hit = utlb_req_vpn[26:18] == utlb_vpn[26:18];          // VPN[2]
assign vpn1_hit = utlb_req_vpn[17:9]  == utlb_vpn[17:9];           // VPN[1]
assign vpn0_hit = utlb_req_vpn[8:0]   == utlb_vpn[8:0];            // VPN[0]
assign utlb_hit = utlb_pgs[0] && vpn2_hit && vpn1_hit && vpn0_hit  // 4K：比全 27 位
               || utlb_pgs[1] && vpn2_hit && vpn1_hit              // 2M：比高 18 位
               || utlb_pgs[2] && vpn2_hit;                         // 1G：比高 9 位
```

iuTLB 的普通项**就地支持 4K/2M/1G**（这点与 duTLB 不同，duTLB 把大页隔离到 huge 项 —— 因为取指流的大页比较没有数据侧那两个高频比较器的时序压力大）。

### 5.2 32 项命中归约

32 个表项的 hit/valid 拼成向量，按位与得到最终命中（`ct_mmu_iutlb.v:2013-2033`）：

```verilog
assign iutlb_entry_hit[31:0] = entry_hit[31:0] & entry_vld[31:0];   // :2031
assign iutlb_addr_hit_vld    = |iutlb_entry_hit[31:0];              // :2033
```

### 5.3 fast entry：为什么 32 项里有 4 个"快项"

关键设计点在 `:2035-2036`：

```verilog
assign iutlb_addr_hit = iutlb_entry_hit[0]  || iutlb_entry_hit[8]
                     || iutlb_entry_hit[16] || iutlb_entry_hit[24];
```

**`iutlb_addr_hit`（单周期快命中）只看 4 个 fast entry（0/8/16/24）**，而 `iutlb_addr_hit_vld`（全表命中）看全部 32 项。它们的物理含义是：

- **fast entry 是最近被命中的"热项"**：命中它们时，PA/flg/pgs 走专门的快路 mux（`:2047-2063`，只在 4 项里选），关键路径短，当拍出结果。
- 若命中的是某个普通项（非 fast），则触发 **swap（交换/提升）**：把命中的普通项内容提升到对应的 fast entry 槽，下次访问同一页就能走快路。swap 使能在 `:2038-2039`：

```verilog
assign iutlb_swp_en = ifu_mmu_va_vld && iutlb_addr_hit_vld
                   && !iutlb_addr_hit && !iutlb_off_hit;
```

即"全表命中但不是 fast 命中"时提升。被提升到哪个 fast 槽由一个 4 项轮转寄存器决定（`:2182-2188`）：

```verilog
if (!cpurst_b)         iutlb_fst_wen <= 4'b0001;
else if(iutlb_swp_en)  iutlb_fst_wen <= {iutlb_fst_wen[2:0], iutlb_fst_wen[3]};
```

**fast entry 的本质是一个 4 路 MRU（most-recently-used）缓存层**，把"最近命中"集中到 4 个时序优化过的槽里，让稳态下的取指翻译走最短关键路径，而把全 32 项的全相联比较作为"慢但全"的后备。这是在全相联表内部再做一次"小快表挡大慢表"的层次化思想。

---

## 6. tree-PLRU 替换（ct_mmu_iplru.v）

iuTLB 的替换（选哪一项被 JTLB 回填覆盖）由 `ct_mmu_iplru.v` 决定，例化于 `ct_mmu_iutlb.v:626`，输出 `plru_iutlb_ref_num`（`:663`）。

### 6.1 32 叶二叉树需要 31 个状态位

要近似 LRU 地从 32 项里选牺牲者，C910 用一棵 **5 层满二叉树**：32 个叶子（对应 32 项），31 个内部节点各 1 位（`ct_mmu_iplru.v:107-137`）：

- `p00`（根，`:107`）
- `p10,p11`（`:108-109`）
- `p20~p23`（`:110-113`）
- `p30~p37`（`:114-121`）
- `p40~p4f`（16 个，`:122-137`）

每个节点位指向"哪一侧子树更该被替换"。

### 6.2 牺牲项选择：从根向叶遍历

`plru_num[4:0]`（5 位编码 32 项之一）通过从根到叶逐层跟随 PLRU 位计算（`:1135-1169`）：

```verilog
assign plru_num[4] = p00;                              // :1135 根决定左/右半
assign plru_num[3] = !p00 && p10 || p00 && p11;        // :1137-1138 第二层
// … 逐层向下，最终 plru_num[0] 由第 5 层 16 个节点选出叶子
```

得到的 `plru_num` 再 one-hot 化为 `plru_iutlb_ref_num[31:0]`，回填时与 `iutlb_refill_vld` 相与生成各项的 update 使能（`ct_mmu_iutlb.v:1901`）。

### 6.3 访问/回填时的状态更新：翻转路径上的节点

命中或回填某项时，从该叶到根路径上的节点被翻转，指向"远离刚访问项"的方向（`ct_mmu_iplru.v:529-549` 给出更新条件，`:538-539` 是根节点 p00 的更新值，`:829-845` 是某叶层节点示例）：

```verilog
assign plru_write_updt = utlb_plru_refill_vld;                     // :529 回填更新
assign plru_read_updt  = utlb_plru_read_hit_vld && (...);          // :530-531 命中更新
assign p00_write_updt_val = !refill_num_index[4];                  // :538
assign p00_read_updt_val  = !hit_num_index[4];                     // :539
```

只更新 log2(32)=5 个节点，远小于真 LRU 需要的 O(N·logN) 状态。

> 这是 tree-PLRU（伪 LRU），不是真 LRU、也不是随机：用 31 位状态近似 32 项的最近最少使用，硬件代价远低于真 LRU 而命中率接近。

---

## 7. miss → JTLB → 回填 流程

refill FSM（`:761-778`）驱动整个 miss 处理：

1. **IDLE → WFG**：检测到 iuTLB miss（全表未命中且 MMU 开启），向 arb 发请求 `iutlb_arb_req=(ref_cur_st==WFG)`（`:851`），VPN 取自 `ifu_mmu_va[VPN_WIDTH+10:11]`（`:852`/`:891`）。
2. **WFG → WFC**：拿到 `arb_iutlb_grant` 后进入等回填。
3. **WFC**：`iutlb_refill_vld = iutlb_wfc && jtlb_iutlb_ref_pavld`（`:862`）。回填数据来自 JTLB（`:1906-1909`）：

```verilog
assign utlb_upd_vpn = jtlb_utlb_ref_vpn;
assign utlb_upd_pgs = jtlb_utlb_ref_pgs;
assign utlb_upd_ppn = jtlb_utlb_ref_ppn;
assign utlb_upd_flg = jtlb_utlb_ref_flg;
```

   被写入的项由 `plru_iutlb_ref_num`（PLRU 牺牲者）与 `iutlb_refill_vld` 相与选中（`:1901`）。
4. **完成**：`iutlb_arb_cmplt`（`:867-868`）在 `jtlb_iutlb_ref_cmplt` 时拉高，回 IDLE。请求重查 uTLB，这次命中。

若 JTLB 进一步 miss 触发 PTW，PTW 的结果会先回填 JTLB，再由 JTLB 回填 uTLB —— iuTLB 看到的始终是 `jtlb_utlb_ref_*` 这一组信号，对 PTW 是否介入无感。

---

## 8. 异常生成

### 8.1 page fault（缺页/权限）

`:2593-2604` 汇聚取指页的所有缺页条件（用回填后的 14 位 flag）：

```verilog
assign iutlb_page_fault = (!flg[0]                               // V=0 无效
   || !flg[1] && flg[2]                                          // 只写不读
   || !flg[3]                                                    // 不可执行 X=0
   ||  flg[4] && cp0_supv_mode && !cp0_mmu_sum                   // S 态访问 U 页且 SUM=0
   || !flg[4] && cp0_user_mode && regs_mmu_en                    // U 态访问 S 页
   || !flg[5]                                                    // A=0
   ||  flg[13]                                                   // strong-order 不可取指
   ||  iutlb_ref_pgflt                                           // JTLB/PTW 报缺页
   ||  iutlb_va_illegal) && !jtlb_acc_fault;                     // VA 非法
```

输出 `mmu_ifu_pgflt = iutlb_page_fault`（`:607`）。

### 8.2 access fault（PMP/总线）

`:611-614`：JTLB/PTW 阶段的 access fault（`jtlb_acc_fault_flop`）或 PMP 拒绝取指权限（`!pmp_mmu_flg2[2]`），生成 `mmu_ifu_deny`。

---

## 设计取舍小结

- **全相联 + 寄存器**：32 项每项独立比较，命中当拍出 PA，把命中速度做到极致；容量小所以拼命中率。
- **fast entry 是表内再分层**：4 个 MRU 快项走短关键路径单周期命中，普通项命中后被提升进快项，稳态下取指翻译走最短路。
- **tree-PLRU**：31 位状态近似 32 项 LRU，只翻转 5 个路径节点，硬件代价低、命中率高 —— 小表值得为命中率投入。
- **不存 ASID**：每项隐含 satp ASID，进程切换整表清空，省 16 位/项的 ASID 存储与比较器（保命的活交给 JTLB）。
- **就地支持大页**：iuTLB 普通项按 pgs 比较不同位数，无需像 duTLB 那样单列 huge 项。

*文档覆盖 ct_mmu_iutlb.v / _entry.v / _fst_entry.v / _iplru.v 的全部关键逻辑（iutlb.v 约 2340 行）。*
