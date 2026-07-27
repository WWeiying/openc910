# C910 MMU arb + tlboper（仲裁与 TLB 维护）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_arb.v`（约 506 行）、`ct_mmu_tlboper.v`（约 1132 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [arb：JTLB+PTW 共享仲裁](#4-arbjtlbptw-共享仲裁)
5. [arb：访问数据通路的多路合并](#5-arb访问数据通路的多路合并)
6. [tlboper：TLB 维护操作总览](#6-tlbopertlb-维护操作总览)
7. [tlboper：各操作 FSM 详解](#7-tlboper各操作-fsm-详解)
8. [tlboper 与 uTLB / PTW 的协同](#8-tlboper-与-utlb--ptw-的协同)
9. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

- **arb（`ct_mmu_arb.v`）**：JTLB 和 PTW 是 MMU 里唯一一套大资源，被 5 类请求方共享 —— 指令侧（iuTLB）、数据侧（duTLB）、预取（PFU）、TLB 维护（tlboper）、PTW 回填。arb 是它们访问 JTLB 的**唯一咽喉**，负责优先级仲裁、把胜者的地址/控制合并送进 JTLB、并管理 mask（屏蔽）使一次 refill 期间不被打断。
- **tlboper（`ct_mmu_tlboper.v`）**：实现所有 **TLB 维护操作**——RISC-V 的 `sfence.vma` 各变种（全清 / 按 ASID 清 / 按 VA 清 / 按 VA+ASID 清），以及 T-Head 扩展的 TLBP（probe）、TLBR（read）、TLBWI/TLBWR（写）。它把这些操作翻译成对 JTLB 的一系列读/写/比较序列。

### 1.2 位置

arb 上承 iuTLB/duTLB/tlboper/PTW，下接 JTLB；tlboper 上承 regs（CP0 指令）和 LSU（sfence.vma），下经 arb 操作 JTLB，并直接控制 uTLB 清除。

---

## 2. 端口说明

### 2.1 arb 请求方输入

| 信号 | 方向 | 含义 |
|------|------|------|
| `iutlb_arb_req` / `_vpn` / `_cmplt` | in | 指令侧请求 |
| `dutlb_arb_req` / `_vpn` / `_load` / `_cmplt` | in | 数据侧请求 |
| `lsu_mmu_va2_vld` | in | 预取（PFU）请求 |
| `tlboper_arb_req` / `_vpn` / `_idx` / `_write` / `_tag_din` / `_data_din` / `_bank_sel` / `_fifo_*` | in | 维护操作请求 |
| `ptw_arb_req` / `_vpn` / `_pgs` / `_tag_din` / `_data_din` / `_fifo_din` / `_bank_sel` | in | PTW 回填请求 |

### 2.2 arb 输出（给 JTLB / 各请求方）

| 信号 | 方向 | 含义 |
|------|------|------|
| `arb_jtlb_req`/`_vpn`/`_idx`/`_bank_sel`/`_write`/`_tag_din`/`_data_din`/`_fifo_din`/`_acc_type`/`_cmp_with_va` | out | 合并后送 JTLB |
| `arb_iutlb_grant`/`arb_dutlb_grant`/`arb_tlboper_grant`/`arb_ptw_grant` | out | 各方授权 |
| `arb_ptw_mask` | out | 屏蔽 PTW |
| `mmu_yy_xx_no_op` | out | MMU 空闲（可安全做某些操作） |

### 2.3 tlboper 主要接口

| 信号 | 方向 | 含义 |
|------|------|------|
| `regs_tlboper_invall/invasid/tlbp/tlbr/tlbwi/tlbwr` | in | CP0 触发的维护操作 |
| `lsu_mmu_tlb_all_inv` / `_asid_all_inv` / `_va_all_inv` / `_va_asid_inv` | in | sfence.vma 各变种 |
| `tlboper_utlb_clr` / `tlboper_utlb_inv_va_req` | out | 清 uTLB |
| `tlboper_ptw_abort` | out | 打断正在进行的 PTW |
| `mmu_lsu_tlb_inv_done` / `mmu_cp0_tlb_done` | out | 操作完成通知 |

---

## 3. 参数与关键寄存器

两模块共享宽度参数（`ct_mmu_arb.v:239-247`、`ct_mmu_tlboper.v:305-313`）：`VPN_WIDTH=27`、`PPN_WIDTH=28`、`FLG_WIDTH=14`、`PGS_WIDTH=3`、`ASID_WIDTH=16`、`TAG_WIDTH=48`、`DATA_WIDTH=42`。

arb 的请求屏蔽 FSM（`ct_mmu_arb.v:324-327`）：`ARB_IDLE/ARB_IUTLB/ARB_DUTLB/ARB_PFU` 四态，加 `tlboper_on` 标志位（`:153`）。

tlboper 为**每种操作各开一个独立 FSM**（`:160-177` 寄存器声明），互不复用，下文第 7 节逐一展开。

---

## 4. arb：JTLB+PTW 共享仲裁

### 4.1 优先级（固定优先）

授权信号的生成体现优先级（`:288-311`）：

```verilog
arb_ptw_grant    = ptw_arb_req;                                         // :311 PTW 最高
arb_tlboper_grant= tlboper_arb_req && !ptw_arb_req && jtlb_arb_sel_4k;  // :307
arb_dutlb_grant  = dutlb_arb_req && !tlboper_arb_req && !ptw_arb_req && !utlb_mask;  // :302
arb_iutlb_grant  = iutlb_arb_req && !dutlb_arb_req && !tlboper... && !ptw... && !utlb_mask; // :296
arb_pfu_grant    = lsu_mmu_va2_vld && !mmu_off && !iutlb... && ... && !ptw_arb_req && !utlb_mask; // :288
```

**优先级：PTW > tlboper > duTLB > iuTLB > PFU（预取）**。

- PTW 最高：它是别人 miss 的结果，必须尽快回填释放，否则阻塞链上所有请求。
- tlboper 次高（但只在 `jtlb_arb_sel_4k` 阶段授权，避免和 read FSM 的多尺寸搜索打架）。
- 数据访存优于取指（访存通常更关键）；预取最低（可有可无）。

最终 `arb_jtlb_req`（`:313-319`）是各授权 + 大页二次读（`arb_read_huge`）+ parity 清除（`arb_par_clr`）的或。

### 4.2 mask：一次 refill 不被打断

请求屏蔽 FSM（`:329-385`）：进入 IUTLB/DUTLB/PFU 态后，直到该方 `cmplt` 才回 IDLE。期间 `utlb_mask`（`:399-400`）拉高，挡住其他 uTLB/PFU 请求，保证一次 uTLB refill 原子完成。

`tlboper_on`（`:389-397`）：tlboper 一旦被授权就置位，stall 所有其他请求直到操作完成（`tlboper_xx_cmplt`）。它只被 PTW 屏蔽（`arb_ptw_mask = tlboper_on`，`:404`）—— 注释 `:387-388` 明确："tlboper 只被 ptw refill 屏蔽；一旦开始就 stall 所有其他请求"。

### 4.3 索引页大小选择

JTLB 索引按页大小取不同 VPN 段，arb 据当前请求方选 4k/2m/1g（`:410-418`）：tlboper 用 `tlboper_xx_pgs`、PTW 用 `ptw_arb_pgs`、parity 清用 jtlb 反馈、否则用 jtlb 的 `sel_4k/2m/1g`。再生成最终 index（`:439-445`）：

```verilog
arb_va_index[8:0] = sel_4k?vpn[8:0] : sel_2m?vpn[17:9] : sel_1g?vpn[26:18];
```

---

## 5. arb：访问数据通路的多路合并

胜者的 VPN、bank_sel、tag/data/fifo 写入数据都用"授权信号做掩码再或"的方式合并（`:429-496`）。例如 VPN（`:429-437`）：

```verilog
arb_vpn = {27{pfu_grant}}&pfu_vpn | {27{iutlb_grant}}&iutlb_vpn
        | {27{dutlb_grant}}&dutlb_vpn | {27{tlboper_grant}}&tlboper_vpn
        | {27{ptw_grant}}&ptw_vpn | ...;
```

写 JTLB 的 tag/data 只可能来自 tlboper（写操作）或 PTW（回填）（`:490-496`）：

```verilog
arb_jtlb_tag_din  = {48{tlboper_wen}}&tlboper_tag_din | {48{ptw_grant}}&ptw_tag_din;
arb_jtlb_data_din = {42{tlboper_wen}}&tlboper_data_din| {42{ptw_grant}}&ptw_data_din;
```

访问类型 `arb_jtlb_acc_type`（`:472-479`）编码请求方：PFU=100 / iuTLB=011 / load=010 / store=110 / tlboper=001 / PTW=000 等，供 JTLB 区分如何处理命中结果。

> arb 的本质是一个"优先级仲裁 + 总线合并器"：把 5 类异构请求规整成 JTLB 看到的统一一组输入，并用 mask 保证原子性。

---

## 6. tlboper：TLB 维护操作总览

tlboper 处理两类来源：

1. **CP0 指令**（经 regs）：TLBP（probe 查项）、TLBR（read 读项）、TLBWI（按 index 写）、TLBWR（按 fifo 写）、INVALL（全清）、INVASID（按 ASID 清）。
2. **sfence.vma**（经 LSU）：`tlb_all_inv`（全清）、`tlb_asid_all_inv`（按 ASID 清）、`tlb_va_all_inv` / `tlb_va_asid_inv`（按 VA[+ASID] 清）。

核心难点：JTLB 是 SRAM，**清除/查找不能并行做全表比较**，只能用状态机**逐项/逐组读出—比较—写回**。所以每种操作都是一台 FSM 配一个计数器遍历 SRAM。

清除计数器初值（`:947-950`）：全清 `invall_cnt = 11'h0ff`（256 组）、按 ASID 清 `invasid_cnt = 11'h3ff`（1024 项，要逐项比 ASID）。`tlb_inv_cnt` 递减到 0 即完成（`:952-964`）。

---

## 7. tlboper：各操作 FSM 详解

### 7.1 TLBP（probe，2~3 态）

`:356-358` `PIDLE/PWFG/PWFC`：发读请求 → 等授权 → 等 JTLB 比较完成并写回 probe 结果（命中/多命中/index）到 MIR 寄存器（见 06 篇）。

### 7.2 TLBR（read）/ TLBWI（write-index）/ TLBWR（write-random）

- TLBR（`:416-418` `RIDLE/RWFG/RWFC`）：按 index 读 JTLB 一项，结果写回 MEH/MEL 寄存器。
- TLBWI（`:476-478` `WIIDLE/WIWFG/WIWFC`）：按 index 把 MEH/MEL 内容写入 JTLB 一项。
- TLBWR（`:537-540` `WRIDLE/WRWFG/WRTAG/WRWFC`，4 态）：比 TLBWI 多一步 `WRTAG`——先读出该组的 fifo 指针，再按 fifo 指定的 way 写入（实现 random/round-robin 写）。

### 7.3 INVASID（按 ASID 清，5 态）

`:619-623` `IASID_IDLE/RD/WFC/WT/NWT`。逐项读出（RD）→ 等比较（WFC）→ ASID 命中则写无效（WT），否则跳过（NWT）→ 计数器减到 0 完成。要扫全 1024 项，故 `invasid_cnt=1023`。

### 7.4 INVALL（全清，2 态）

`:711-712` `IALL_IDLE/IALL_WFC`。逐组写无效（每次清 4 路），计数器 256 组减到 0 完成。比 INVASID 快（不用逐项比 ASID，按组批量清）。

### 7.5 INVVA（按 VA 清，14 态）

`:772-785` 从 `IVA_IDLE` 到 `IVA_CMPLT`，分 4K/2M/1G 三组各 4 态（RD→CMP→WR→WT）：因为一个 VA 可能落在 4K/2M/1G 任一页里，要**依次按三种页大小索引去找**，找到 VA 命中的项才清。这与 JTLB read FSM 逐尺寸搜索同理。

### 7.6 状态汇聚与完成

`tlb_sm_idle`（`:970-973`）是七个 FSM 全空闲的与；`tlboper_cmplt`（`:1096-1099`）是各操作完成的或；`tlboper_arb_req`（`:999-1001`）是各操作需要访问 JTLB 时的或。

---

## 8. tlboper 与 uTLB / PTW 的协同

### 8.1 清 uTLB

由于 uTLB 不存 ASID 也不便逐项比，维护操作大多直接整清 uTLB：

```verilog
assign tlboper_utlb_clr        = tlbwi || tlbwr || invasid || invall;  // :1107-1108 这些操作整清 uTLB
assign tlboper_utlb_inv_va_req = tlb_invva_req;                        // :1105 按 VA 清时通知 uTLB 按 VA 清
```

uTLB 收到 `tlboper_utlb_inv_va_req` 后比较低位 VA 决定是否清该项（见 01 篇 `ct_mmu_iutlb_entry.v:170-171`）。

### 8.2 打断 PTW

sfence 到来时若 PTW 正在遍历，必须打断以保证一致性：`tlboper_ptw_abort = tlb_lsu_oper && !tlb_lsu_oper_flop`（`:1110`）。PTW 收到后按 abort 状态安全收尾（见 04 篇 FSM 的 abort 分支）。

### 8.3 ASID / global 控制送 JTLB

probe/invva 时把待比较 ASID、是否忽略 ASID（`tlboper_jtlb_cmp_noasid`，对应 sfence 全 ASID 清）、tlbwr 选 way 等直接送 JTLB（`:1080-1089`）。

---

## 设计取舍小结

- **arb 咽喉化**：把 5 类异构请求统一成 JTLB 的一组输入，固定优先级（PTW>tlboper>D>I>PFU）+ mask 保证 refill 原子性，避免在 JTLB 入口铺多份控制。
- **优先级反映关键度**：PTW 回填最急（解阻塞），数据访存优于取指，预取垫底。
- **维护操作 = FSM + 计数器扫 SRAM**：JTLB 是 SRAM 无法并行全表操作，只能逐项/逐组读—比—写；INVALL 按组批量清快，INVASID 逐项比 ASID 慢，INVVA 按三种页大小逐尺寸搜索。
- **uTLB 配合整清**：uTLB 不存 ASID，维护时多数直接整清，少数按 VA 清，简单高效。
- **与 PTW 一致性**：sfence 能打断进行中的 PTW，保证维护操作语义正确。

*文档覆盖 ct_mmu_arb.v（506 行）与 ct_mmu_tlboper.v（1132 行）全部关键逻辑。*
