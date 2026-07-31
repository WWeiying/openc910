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
9. [回填 JTLB（轮转指针选路）](#9-回填-jtlb轮转指针选路)
10. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

PTW（Page Table Walker，页表遍历器）是 MMU 存储层次的**末级兜底**：当
JTLB 对 4KB/2MB/1GB 三种候选都 miss 时，它串行读取页表项并把成功结果经
arb 回填 JTLB。它没有独立 PTE cache；`mmu_lsu_data_req`由 LSU 的 MCIC
桥接到 D-cache/load DA，D-cache miss 后再经 RB/BIU。PTE **可能**命中
D-cache，但不是“发请求就自然命中”。

### 1.2 位置

输入来自 JTLB 的 miss 请求，PTE 读取发给 LSU，结果经 MMU arb 回填 JTLB。
每级 `*_PMP`状态先观察当前 PTE 物理地址的 PMP 结果；sysmap 同时对该地址
给出 PMA 区属性，并在大页跨区检查中提供 region hit。PMP 是许可检查，
sysmap 是属性映射，二者不能都称为“权限确认”。

---

## 2. 端口说明

### 2.1 JTLB 请求 / 回填

| 信号 | 方向 | 含义 |
|------|------|------|
| `jtlb_ptw_req` | in | JTLB miss，请求遍历（`ct_mmu_ptw.v:89`） |
| `jtlb_ptw_vpn` / `jtlb_ptw_type` | in | 待翻译 VPN / 访问类型 |
| `jtlb_xx_fifo[11:0]` | in | 本次 JTLB 查找累积的 4KB/2MB/1GB 三个候选 set 的 4-bit 轮转指针 |
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

每级读回 PTE 后检查 V/R/X。第一、第二级只有 `V && (R || X)`才被当前 RTL
识别为大页叶子；否则状态机继续下一级。体系结构上“否则”还必须满足合法
非叶条件，而当前 RTL 对无效中间级项的 fault 门控边界见第 8 节。第三级是
最后一级，进入 `THD_CHK`不表示 PTE 必然合法，仍需 page-fault 组合逻辑判定。

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
          PTW_THD_CHK  = 5'b01001,   // 第3级：最终级合法性检查
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

- **每级 PMP 态**根据原始 miss 类型选择 PMP 的 X/R/W 位：取指看
  `pmp_mmu_flg3[2]`，load/prefetch 看 `[0]`，store 看 `[1]`。这是当前 RTL
  的精确选择；即使被检查地址是 PTE 地址，也不是无条件按“页表 load”检查。
- **每级 DATA 态**持续提出 `mmu_lsu_data_req`并等待
  `lsu_mmu_data_vld`。`data_req=1`表示请求保持，MCIC 的 D-cache grant、
  D-cache hit或 RB/BIU 响应是后续不同事件；匹配总线响应报错时转
  `PTW_ACC_FLT`。
- **每级 CHK 态**：缺页转 `PTW_PGE_FLT`；命中大页（`ptw_hit_1g`/`ptw_hit_2m`）且未开 MAEE 则进跨区检查（`PTW_1G_CRS1`/`PTW_2M_CRS1`），开了 MAEE 直接 `PTW_DATA_VLD`（`:408-420`、`:437-449`）。
- **abort/restart**：新的 LSU TLB 维护操作产生单周期
  `tlboper_ptw_abort`。若 PTW 正在 DATA 态等待 PTE，已发请求尚未返回时转
  `PTW_ABT_DATA`并先消费返回；若没有悬挂返回则转 `PTW_ABT`。两种路径随后
  都重新装入一级页表地址并回到 `PTW_FST_DATA`，即丢弃当前遍历进度后从根
  PTE 重新开始，而不是直接退出到 IDLE。
- **DATA_VLD**：等 `arb_ptw_grant`（拿到回填 JTLB 的授权）后回 IDLE（`:485-491`）。

> ~20 态分三组：三级遍历各 3 态（PMP→DATA→CHK）共 9 态、异常/完成/abort 共 6 态、大页跨区检查 4 态、M 态 PMP 1 态。

更精确地说，源码定义了 20 个状态编码，但主 next-state 逻辑中没有任何分支
跳入 `PTW_MACH_PMP`；它只有“若已经处于该状态则回 IDLE”的 case。因而在
当前 RTL 的正常可达路径中，不应把它当成必经的 M-mode 检查阶段。

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

读回的 64 位 PTE 存入 `lsu_data_flop`。当前 RTL **没有独立 PTE cache**：
MCIC 请求 PIPT D-cache，命中时由 load DA 返回 64-bit PTE；miss 时经 RB/BIU。
这会复用已有 cache/总线能力，也会和普通访存竞争。是否存在系统 L2、PTE
命中率多高、竞争是否值得，均不是本模块 RTL 能单独证明的性能结论。

### 6.3 PTE 属性抽取

```verilog
assign ptw_flg[8:0] = {lsu_data_flop[9:6], lsu_data_flop[4:0]};
//                    {       RSW[1:0],D,A, U,X,W,R,V       }
assign ptw_ref_g    = lsu_data_flop[5];                           // :721 global
assign ptw_ref_pma[4:0] = cp0_mmu_maee ? lsu_data_flop[63:59]     // :709-710 扩展 PMA（SO/C/B/SH/Sec）
                                       : sysmap_mmu_flg3[4:0];     //   否则用 sysmap 区属性
```

`ptw_flg[8:0]`包含两个 RSW 位，所以不是 8 个
`D/A/G/U/X/W/R/V`位；G 被单独放入 JTLB tag。最终
`ptw_ref_flg[13:0]`为 `{PMA[4:0],RSW[1:0],D,A,U,X,W,R,V}`。

另一个容易漏掉的边界是 G 传播：当前 RTL 只在最终使用的
`lsu_data_flop[5]`上生成 `ptw_ref_g`，没有看到逐级累积祖先非叶 PTE 的 G 位
的寄存器。若软件依赖 Sv39“非叶 G 使整个子树 global”的语义，应做定向测试；
仅按本 RTL 数据通路，最终 JTLB tag 的 G 来自最后保留的叶子 PTE。

当前 40-bit PA 实现只抽取 PTE `[37:10]`作为 28-bit PPN；除
`[63:59]`在 MAEE 模式下作为扩展属性外，没有看到对 PTE 其余高位/保留位
的显式合法性检查。非叶 PTE 的 U/A/D 等保留组合也没有独立检查项。因而
“所有 Sv39 保留位规则均由 PTW 验证”不是当前 RTL 可支持的结论；这些组合
应纳入架构符合性定向测试。

---

## 7. 叶子判定、大页与跨区检查

### 7.1 叶子与大页

```verilog
assign ptw_hit_1g = ptw_chk_fst && ptw_flg[0] && (ptw_flg[1] || ptw_flg[3]);  // :641 第1级是叶子=1G
assign ptw_hit_2m = ptw_chk_scd && ptw_flg[0] && (ptw_flg[1] || ptw_flg[3]);  // :642 第2级是叶子=2M
assign ptw_leaf_vld = ptw_hit_1g || ptw_hit_2m || ptw_chk_thd;                // :655（第3级必为叶子）
```

即 V=1 且 (R=1 或 X=1) 才在第一/第二级被识别为叶子。第三级无论是否是
合法叶子，`ptw_leaf_vld`都因 `ptw_chk_thd`而有效，随后由 page-fault 逻辑
判断合法性。`ref_pgs`只在识别到叶子或第三级检查时于时钟沿更新，不是 PTE
一返回就立即成为最终页大小。

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

若 1GB 起止地址落在不同 sysmap 区，PTW 先把候选翻译收窄到包含当前 VPN 的
2MB 子页，并再检查这个 2MB 子页的两端；若仍跨区，再收窄到当前 4KB 页。
这里的“降级”只改变本次回填的 VPN/PPN 覆盖粒度，不修改内存中的原页表。
当 `maee=1`时 PMA 来自 PTE 高位，不走这组 sysmap 跨区降级状态。

---

## 8. page fault 与 access fault

### 8.1 page fault

组合表达式检查 V、W-only、R/W/X、U/S、A/D 和大页对齐：

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

访问类型由 `ptw_type`解码：fetch=011 / load=010 / store=110 / pref=100。
fault 时进入 `PTW_PGE_FLT`，随后以完成但无有效 refill 的形式返回。

必须同时说明两个 RTL 边界，而不能只写“覆盖全部 Sv39 情形”：

1. 上述大部分检查被 `&& ptw_leaf_vld`门控。第一、第二级只有
   `V && (R || X)`才令 `ptw_leaf_vld`成立；因此按当前可见表达式，
   `V=0,R=X=0`或 W-only 的中间级 PTE不会在该级立即报 page fault，而可能
   继续使用其 PPN 访问下一级。Sv39 通常要求无效/W-only PTE立即 fault，
   所以这是需要定向仿真确认的实现边界，不能在文档中替 RTL 隐去。
2. RTL 遇到 `A=0`，或 store 叶子 `D=0`时直接 page fault；没有看到硬件
   写回 PTE 设置 A/D 的状态机。因此软件必须预置/处理 A/D，而不能期待 PTW
   自动更新。

另外，S-mode 访问 U 页的判断直接使用 `SUM`，没有对 fetch 单独排除。文档
描述的是这份 RTL 的条件；若要判断与目标特权规范版本是否完全一致，应另做
架构符合性测试。

### 8.2 access fault

access fault 来自 MCIC 报告的匹配总线响应错误，或每级 PMP 状态中的拒绝：

```verilog
ptw_pmp_deny = (fetch && !pmp_flg3[2] || load && !pmp_flg3[0]
             || store && !pmp_flg3[1] || pref && !pmp_flg3[0])
             && !(mach_mode && !pmp_flg3[3]);   // M 态 L-bit
```

该 PMP 选择使用原始请求类型，而不是固定使用 read 权限。进入
`PTW_ACC_FLT`后，`ptw_ref_cmplt=1`和`ptw_ref_acc_err=1`通知原请求结束，
但不会写 JTLB；这与“获得一个有效 PA”不同。

### 8.3 `mmu_hpcp_jtlb_miss`的真实事件边界

该信号不在 JTLB 首次确认 miss 时直接产生。`jtlb_miss_cnt`要求：

- 原始类型是取指或数据 load/store，不包括 PFU；
- 对应 iuTLB/duTLB 仍处于等待 JTLB/PTW 完成的 WFC 状态；
- PTW 已成功进入 `PTW_DATA_VLD`；
- `hpcp_mmu_cnt_en=1`。

条件满足后进入一个“源条件为 1 则置位、下一空闲拍自清零”的寄存器。因此
它更接近“成功走到 PTW 有效结果阶段的 I/D JTLB miss”，不会统计
page/access fault、PFU miss或未成功产生有效结果的遍历。通常
`PTW_DATA_VLD`当拍获得 arb grant，输出表现为单周期事件；若回填被
`arb_ptw_mask`屏蔽而使 DATA_VLD 连续保持，源条件和输出也可能连续为高。
所以性能计数器若按高电平逐周期累加，不能无条件把它理解为“一次 miss
恰好加一”。

---

## 9. 回填 JTLB（轮转指针选路）

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

- **回填 JTLB 时把当前 16 位 ASID 写入翻译 tag**；uTLB 表项不保存该字段。
- `ptw_ref_fifo`按最终 `ref_pgs`从 12-bit 临时汇总中选择一个 4-bit slice；
  当前 one-hot 值同时作为 `bank_sel`，旋转值写回对应 set；
- `ptw_arb_req`在 DATA_VLD 中保持且受 `arb_ptw_mask`抑制；
  `arb_ptw_grant`才表示本次 JTLB 写已被接受；
- `ptw_ref_data_vld`在等待 grant 期间可以为 1，但面向 JTLB/uTLB 的
  `ptw_jtlb_ref_data_vld`还要求 grant。不能把前者当作“回填已经落入 SRAM”。

回填 JTLB 后，JTLB 再把同一项回填给最初发起 miss 的 uTLB（见 03 篇 9.3），整条 miss 链闭合。

---

## 本章小结

PTW 在 JTLB 最终 miss 后串行遍历 Sv39 的三级页表。20 个状态中，主路径为每一级依次执行 PMP 检查、PTE 数据请求和 PTE 合法性检查，其余状态处理完成、异常、abort、M 态 PMP 和大页属性跨区。PTW 没有独立 PTE cache，而是经 MCIC 复用 LSU 访问 D-cache；PTE miss 后还会进入 RB/BIU，所以页表遍历会与普通数据访问竞争现有存储层次。当前逻辑不会硬件更新 PTE 的 A/D 位，A=0 或 store 遇到 D=0 时直接报告 page fault。

识别叶子 PTE 后，PTW还要形成页尺寸、PPN、权限、ASID 和 PMA 属性。未启用 MAEE 时，大页若横跨多个 sysmap/PMA 区域，会通过附加检查降级到更小页粒度，以保证一个回填项内的属性一致；启用 MAEE 时则按 PTE 的扩展属性字段处理。结果只有取得 JTLB refill grant 后才真正写入 SRAM并推进轮转指针。sfence 到来时，PTW 丢弃当前遍历进度；若 PTE 内存请求已经在途，它会先等待并消费返回，再从根 PTE 重启，而不是试图撤销外部事务。因而波形中的 abort、PTE 返回、restart、refill request 和 refill grant 是不同阶段，只有最后的 grant 才表示新翻译已进入 JTLB。规范边界仍应通过定向页表、权限和 sfence 测试验证。
