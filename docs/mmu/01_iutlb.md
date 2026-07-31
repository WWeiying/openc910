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
9. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

iuTLB 是**取指侧的一级微 TLB**：IFU 发来取指虚拟地址，32 个表项并行比较
以判断“翻译是否存在于 iuTLB”。但是，直接生成最终 PA/PGS/flag 的快速读出
只连接 entry 0/8/16/24 四个 fast slot。其余 28 项命中时不会发起 JTLB
访问，而是先与一个 fast slot 交换；随后 IFU 保持或重提该 VA，才从 fast
slot 完成翻译。miss 时才启动 refill 状态机，经 arb 查询 JTLB。

### 1.2 位置

上游是 IFU（`ifu_mmu_va`/`ifu_mmu_va_vld`），下游命中给 IFU
（`mmu_ifu_pa`/`mmu_ifu_pavld`），miss 时下游是 arb→JTLB。它**不存
ASID**，进程切换写 satp 时由 `regs_utlb_clr`整表清空。这里还有一项接口
约定：IFU 已省略恒为 0 的取指地址 bit0，所以 `ifu_mmu_va[n]`表示体系结构
`VA[n+1]`。

---

## 2. 端口说明

### 2.1 IFU 接口

| 信号 | 方向 | 含义 |
|------|------|------|
| `ifu_mmu_va[62:0]` / `ifu_mmu_va_vld` | in | 取指 VA[63:1] 及有效；最低地址位未在总线上传输 |
| `ifu_mmu_abort` | in | IFU 撤销 |
| `mmu_ifu_pa[27:0]` / `mmu_ifu_pavld` | out | 翻译结果 PPN / 有效，不是完整 40-bit 字节地址 |
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

表项内部有三类清除条件（`ct_mmu_iutlb_entry.v:164-171`）：satp 写
（`regs_utlb_clr`）、维护操作整清（`tlboper_utlb_clr`），以及按 VA 维护时
低 8 位相等：

```verilog
ctc_inv_va_hit_clr = tlboper_utlb_inv_va_req
                   && (lsu_mmu_tlb_va[7:0] == utlb_vpn[7:0]);
```

这里不是 27-bit VPN 的精确相等比较，而是只比较低 8 位。对 4KB 项而言，
不同高位 VPN 只要低 8 位相同就会一起失效，属于过度失效；但对 2MB/1GB
项，覆盖判断本应按页大小忽略请求 VPN 的部分低位，当前清除表达式却没有
使用 `utlb_pgs`。此外，大页 refill 进入 uTLB 时保存的低位可能来自触发
refill 的具体请求。仅凭这条低 8 位比较，不能证明“任意落在同一大页内的
SFENCE.VMA 地址都必然清到该项”；这是需要用不同页内地址做定向仿真的
RTL 边界。`tlboper_utlb_inv_va_req=1`触发组合比较，`utlb_vld`在对应门控
时钟上升沿才真正清零。

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

iuTLB 的 fast/slow 两类项都保存 `pgs`，因此每项都能直接缓存
4KB/2MB/1GB 翻译。duTLB 则采用另一种非对称组织：2MB 翻译专门化为普通项
中的 4KB 子页，1GB 翻译进入唯一专用项。两种组织差异是 RTL 事实；将差异
归因于取指/数据关键路径压力只是设计动机推断，需时序报告佐证。

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

`iutlb_addr_hit`只看 4 个 fast entry（0/8/16/24），而
`iutlb_addr_hit_vld`看全部 32 项。两者不是同义的“hit”：

- fast slot 命中时，PA/flg/pgs 由只含四路的快路 mux 选出；最终
  `pa_fin/pgs_fin/flg_fin`也只接受 `iutlb_addr_hit`或 MMU-off 路径；
- slow entry 命中时，`iutlb_addr_hit_vld=1`阻止真正 miss FSM 启动，但
  `iutlb_addr_hit=0`，所以本周期不会把 slow entry 的 PA 宣告为
  `iutlb_hit_vld`；相反会触发 swap：

```verilog
assign iutlb_swp_en = ifu_mmu_va_vld && iutlb_addr_hit_vld
                   && !iutlb_addr_hit && !iutlb_off_hit;
```

被提升到哪个 fast slot 由一个 4-bit one-hot 轮转寄存器决定：

```verilog
if (!cpurst_b)         iutlb_fst_wen <= 4'b0001;
else if(iutlb_swp_en)  iutlb_fst_wen <= {iutlb_fst_wen[2:0], iutlb_fst_wen[3]};
```

这一步是**真正的数据交换**，不只是复制：被命中的 slow entry 写入所选 fast
slot 的 VPN/PGS/PPN/flag；该 slow entry 同时接收被替换 fast slot 的原内容，
若 fast slot 原来无效则 slow entry 也变为无效。交换在
`iutlb_swp_en`有效的时钟沿发生。

因此不能把四个 fast slot 称为严格“4-way MRU”。slow hit 的确会把当前
命中项带入 fast 集合，但牺牲哪个 fast slot由固定 round-robin 顺序决定，
普通 fast hit不会重排四个 slot。准确说法是：**四个固定快速读出槽，加上
slow-hit 驱动的轮转交换机制**。其目标很可能是缩短常见取指翻译的数据 mux
路径，但实际时序收益应由综合报告确认。

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

一次命中或回填只需要更新从叶到根的 5 个节点；整个树保存 31 bit。真 LRU
需要维护更完整的项间次序，不能仅由这里的 RTL推导出一个固定
`O(N·logN)`硬件实现，因此不使用该复杂度表述。

> 这是 tree-PLRU（伪 LRU），不是真 LRU、也不是随机：用 31 位状态近似 32 项的最近最少使用，硬件代价远低于真 LRU 而命中率接近。

---

## 7. miss → JTLB → 回填 流程

refill FSM（`:761-778`）驱动整个 miss 处理：

1. **IDLE → WFG**：检测到 iuTLB miss（全表未命中且 MMU 开启），向 arb
   发请求 `iutlb_arb_req=(ref_cur_st==WFG)`（`:851`）。VPN 取
   `ifu_mmu_va[37:11]`；由于这条总线表示体系结构 `VA[63:1]`，该切片实际
   对应体系结构 `VA[38:12]`，正是 27-bit Sv39 VPN。
2. **WFG → WFC**：拿到 `arb_iutlb_grant` 后进入等回填。
3. **WFC**：`iutlb_refill_vld = iutlb_wfc && jtlb_iutlb_ref_pavld`（`:862`）。回填数据来自 JTLB（`:1906-1909`）：

```verilog
assign utlb_upd_vpn = jtlb_utlb_ref_vpn;
assign utlb_upd_pgs = jtlb_utlb_ref_pgs;
assign utlb_upd_ppn = jtlb_utlb_ref_ppn;
assign utlb_upd_flg = jtlb_utlb_ref_flg;
```

   被写入的项由 `plru_iutlb_ref_num`（PLRU 牺牲者）与 `iutlb_refill_vld` 相与选中（`:1901`）。
4. **完成**：`iutlb_arb_cmplt`在 WFC/ABT 状态收到
   `jtlb_iutlb_ref_cmplt`时拉高，通知 arb 结束这一占用窗口。只有
   `jtlb_iutlb_ref_pavld`才会写入 PLRU 选中的表项；page fault/access fault
   只有完成通知，不会写入有效翻译。正常回填后，IFU 后续保持或重提请求才
   命中新项。

若 JTLB 进一步 miss 触发 PTW，PTW 的结果会先回填 JTLB，再由 JTLB 回填 uTLB —— iuTLB 看到的始终是 `jtlb_utlb_ref_*` 这一组信号，对 PTW 是否介入无感。

`mmu_hpcp_iutlb_miss`也在这条回填路径上产生：源条件是
`iutlb_refill_vld && hpcp_mmu_cnt_en`，随后经过一个“源条件为 1 则置位、
下一空闲拍自清零”的寄存器。正常单次 refill 表现为一个周期事件，但这不是
通用上升沿检测器，解释波形时仍应同时看源条件。它统计的是得到有效
JTLB/PTW 翻译并写 uTLB 的 miss，不包括 slow-entry swap，也不包括最终以
page/access fault 结束而没有 `ref_pavld`的 miss。

---

## 8. 异常生成

### 8.1 page fault（缺页/权限）

`ct_mmu_iutlb.v:596-605`汇聚取指页的 page-fault 条件：

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

当前表达式对 S-mode 取指 U 页也使用 `SUM`门控，没有把 fetch 从 SUM 逻辑
单独排除。本文记录的是 RTL 行为；与目标 RISC-V 特权规范版本的一致性应由
取指权限定向用例验证。

### 8.2 access fault（PMP/总线）

`:611-614`：JTLB/PTW 阶段的 access fault（`jtlb_acc_fault_flop`）或 PMP 拒绝取指权限（`!pmp_mmu_flg2[2]`），生成 `mmu_ifu_deny`。

---

## 本章小结

iuTLB 用 32 项全相联比较判断当前取指 VPN 是否已经缓存，但最终 PA 并不是由 32 项同时直接驱动。表内另设四个 fast slot 连接快速 PA 选择路径；当命中其余 slow 项时，命中项会与 round-robin 选中的 fast slot 在时钟沿交换，使后续相同翻译进入快速路径。该机制是固定 fast 层与 slow 层之间的交换，不是严格 MRU。全表替换状态由 31 位 tree-PLRU 保存，一次访问只更新命中叶到根路径上的五个节点；它近似记录使用关系，实际命中率仍需由工作负载量化。

iuTLB 项不保存 ASID，每项都隐含属于当前 satp 地址空间，因此 satp 切换或相关维护会清空整张小表，跨地址空间保留能力由带 ASID/G 的 JTLB 提供。4KB、2MB 和 1GB 页通过 pgs 决定参与比较的 VPN 位数与 PA 拼接方式，均可在 fast/slow 项中表达，这一点与 duTLB 的独立 1GB 项结构不同。观察波形时，应把请求 valid、全相联 hit 向量、fast/slow 选择、交换写入、PA valid、JTLB miss 请求以及后续 PMP 结果放在同一条时间线上；“表内存在命中”“快速 PA 已选出”和“取指访问获准”是三个不同阶段。
