# C910 MMU arb + tlboper（仲裁与 TLB 维护）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_arb.v`（约 506 行）、`ct_mmu_tlboper.v`（约 1132 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [arb：JTLB 共享仲裁](#4-arbjtlb-共享仲裁)
5. [arb：访问数据通路的多路合并](#5-arb访问数据通路的多路合并)
6. [tlboper：TLB 维护操作总览](#6-tlbopertlb-维护操作总览)
7. [tlboper：各操作 FSM 详解](#7-tlboper各操作-fsm-详解)
8. [tlboper 与 uTLB / PTW 的协同](#8-tlboper-与-utlb--ptw-的协同)
9. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

- **arb（`ct_mmu_arb.v`）**：统一仲裁 JTLB 的外部请求，包括 iuTLB、
  duTLB、PFU、tlboper 和 PTW 回填；同时接续 JTLB read FSM 发出的 2MB/1GB
  重查及 parity-clear 内部请求。它不仲裁 PTW 的页表内存读取，后者走
  LSU/MCIC。
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
| `mmu_yy_xx_no_op` | out | `cp0_mmu_no_op_req`存在且当前无 uTLB refill 占用；不是无条件全 MMU idle |

### 2.3 tlboper 主要接口

| 信号 | 方向 | 含义 |
|------|------|------|
| `regs_tlboper_invall/invasid/tlbp/tlbr/tlbwi/tlbwr` | in | CP0 触发的维护操作 |
| `lsu_mmu_tlb_all_inv` / `_asid_all_inv` / `_va_all_inv` / `_va_asid_inv` | in | sfence.vma 各变种 |
| `tlboper_utlb_clr` / `tlboper_utlb_inv_va_req` | out | 清 uTLB |
| `tlboper_ptw_abort` | out | 打断正在进行的 PTW |
| `mmu_lsu_tlb_inv_done` | out | LSU/sfence 失效操作完成脉冲 |
| `mmu_cp0_tlb_done` | out | 当前 RTL 仅由 `tlb_invall_cmplt`驱动；其他 CP0 TLB 操作经 regs 的完成接口返回 |

---

## 3. 参数与关键寄存器

两模块共享宽度参数（`ct_mmu_arb.v:239-247`、`ct_mmu_tlboper.v:305-313`）：`VPN_WIDTH=27`、`PPN_WIDTH=28`、`FLG_WIDTH=14`、`PGS_WIDTH=3`、`ASID_WIDTH=16`、`TAG_WIDTH=48`、`DATA_WIDTH=42`。

arb 的请求屏蔽 FSM（`ct_mmu_arb.v:324-327`）：`ARB_IDLE/ARB_IUTLB/ARB_DUTLB/ARB_PFU` 四态，加 `tlboper_on` 标志位（`:153`）。

tlboper 为**每种操作各开一个独立 FSM**（`:160-177` 寄存器声明），互不复用，下文第 7 节逐一展开。

---

## 4. arb：JTLB 共享仲裁

### 4.1 优先级（固定优先）

授权信号的生成体现优先级（`:288-311`）：

```verilog
arb_ptw_grant    = ptw_arb_req;                                         // :311 PTW 最高
arb_tlboper_grant= tlboper_arb_req && !ptw_arb_req && jtlb_arb_sel_4k;  // :307
arb_dutlb_grant  = dutlb_arb_req && !tlboper_arb_req && !ptw_arb_req && !utlb_mask;  // :302
arb_iutlb_grant  = iutlb_arb_req && !dutlb_arb_req && !tlboper... && !ptw... && !utlb_mask; // :296
arb_pfu_grant    = lsu_mmu_va2_vld && !mmu_off && !iutlb... && ... && !ptw_arb_req && !utlb_mask; // :288
```

在所有附加门控都允许时，组合公式体现的固定选择顺序是：
**PTW 回填 > tlboper > duTLB > iuTLB > PFU**。但“req=1”与“grant=1”必须
分开：

- `arb_ptw_grant = ptw_arb_req`看似无条件，是因为 PTW 已在生成
  `ptw_arb_req`时用 `!arb_ptw_mask`屏蔽自己；
- tlboper 还要求 `jtlb_arb_sel_4k=1`，即 JTLB read FSM 回到允许新操作的
  入口阶段；
- I/D/PFU 还受 `utlb_mask`限制，PFU 还要求 MMU 开启；
- grant 是本周期 JTLB 接受该请求的组合事实；请求方状态机通常在随后时钟沿
  记录“已获授权”并进入等待完成状态。

“回填优先用于尽快解除 miss”“预取最低因为可丢弃”可以作为设计动机解释，
但不能反过来替代上述门控公式；“数据访存一定比取指更关键”也不是 RTL 能
证明的普遍性能结论。

最终 `arb_jtlb_req`（`:313-319`）是各授权 + 大页二次读（`arb_read_huge`）+ parity 清除（`arb_par_clr`）的或。

### 4.2 mask：一次 refill 不被打断

请求屏蔽 FSM（`:329-385`）：进入 IUTLB/DUTLB/PFU 态后，直到该方 `cmplt` 才回 IDLE。期间 `utlb_mask`（`:399-400`）拉高，挡住其他 uTLB/PFU 请求，保证一次 uTLB refill 原子完成。

`tlboper_on`在 `arb_tlboper_grant`有效的时钟沿置位，在
`tlboper_xx_cmplt`有效的时钟沿清零。置位期间它经 `utlb_mask`阻止 I/D/PFU
新请求，并通过 `arb_ptw_mask`阻止 PTW 生成回填请求。若 PTW refill request
和尚未开始的 tlboper 同周期竞争，grant 公式先让 PTW 获胜；tlboper 一旦
进入 on 状态，则保持维护操作的独占窗口。

### 4.3 索引页大小选择

JTLB 索引按页大小取不同 VPN 段，arb 据当前请求方选 4k/2m/1g（`:410-418`）：tlboper 用 `tlboper_xx_pgs`、PTW 用 `ptw_arb_pgs`、parity 清用 jtlb 反馈、否则用 jtlb 的 `sel_4k/2m/1g`。再生成最终 index（`:439-445`）：

```verilog
arb_va_index[8:0] = sel_4k?vpn[8:0] : sel_2m?vpn[17:9] : sel_1g?vpn[26:18];
```

这 9 bit 是**逻辑候选页段**。送入 JTLB 后，物理 tag/data SRAM 地址只使用
`arb_jtlb_idx[7:0]`，bit8 仍通过完整 VPN tag 比较区分。TLBR/TLBWI 等直接
索引操作还可能由 MIR 提供 index，不能把所有 `arb_jtlb_idx`都解释为当前 VA。

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

> arb 的本质是“JTLB 请求仲裁 + 数据通路合并”。五类是外部请求方；实际
> `arb_jtlb_req`还会包含 `arb_read_huge`和`arb_par_clr`。mask 保持的是一次
> uTLB/PFU refill 或 tlboper 操作的占用窗口，不是对整个 MMU 所有活动的
> 全局原子锁。

---

## 6. tlboper：TLB 维护操作总览

tlboper 处理两类来源：

1. **CP0 指令**（经 regs）：TLBP（probe 查项）、TLBR（read 读项）、TLBWI（按 index 写）、TLBWR（按 fifo 写）、INVALL（全清）、INVASID（按 ASID 清）。
2. **sfence.vma**（经 LSU）：`tlb_all_inv`（全清）、`tlb_asid_all_inv`（按 ASID 清）、`tlb_va_all_inv` / `tlb_va_asid_inv`（按 VA[+ASID] 清）。

核心难点：JTLB 是单组访问的 SRAM 结构，不能像寄存器全相联 uTLB 那样在
一个周期比较全部 1024 项。INVALL 可逐 set 同时写四路无效；INVASID 必须
逐“set+way”读取 ASID/G 后选择是否清；INVVA 则按 4KB/2MB/1GB 三个候选
set 查找。不是每种操作都扫全表，TLBP/TLBR/TLBWI/TLBWR只访问目标项或组。

全清计数器从 255 到 0覆盖 256 个 set；按 ASID 清从 1023 到 0，计数高位
编码 way、低 8 位编码 set，覆盖 1024 项。`tlb_inv_done`在计数值为 0时成立，
但具体完成脉冲还由相应 FSM 在最后一次请求/完成之后产生，不能只看到
`cnt==0`就断言最后一个 SRAM 写已在更早周期完成。

---

## 7. tlboper：各操作 FSM 详解

### 7.1 TLBP（probe，2~3 态）

`PIDLE/PWFG/PWFC`依次表示空闲、保持请求等待 arb grant、等待 JTLB compare
完成。TLBP 比较结果在完成时写 MIR；request、grant、`jtlb_tlboper_cmplt`
分别对应发起、接受和返回，不是同一个脉冲的三个名字。

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

uTLB 收到 `tlboper_utlb_inv_va_req`后只比较维护 VPN 与表项保存 VPN 的低
8 位。对 4KB 项，这会多清除同低 8 位的其他项；对 iuTLB 的 2MB/1GB 项和
duTLB 的 1GB 专用项，清除比较没有按 `pgs`做覆盖匹配。由于大页表项保存的
VPN 低位还可能来自最初 refill 的具体 VA，仅凭当前逻辑不能证明同一大页内
任意 SFENCE.VMA 地址都能命中该 uTLB 项；应以定向仿真验证，不能把它笼统
归类为只有性能影响的“保守多清”。

### 8.2 打断 PTW

`tlboper_ptw_abort = tlb_lsu_oper && !tlb_lsu_oper_flop`只在检测到一项新的
LSU TLB 维护请求、但尚未把它记入 `tlb_lsu_oper_flop`的窗口有效。PTW 若
正在等待 PTE 返回，会进入 ABT_DATA 等待已发出的 LSU 事务返回；若没有
悬挂返回则走 ABT。随后 `PTW_ABT_DATA/PTW_ABT`都重新生成一级页表地址并
转向 `PTW_FST_DATA`，从根页表重启原翻译。abort 不会取消外部已经接受的
事务，也不是把 PTW 直接送回 IDLE。

### 8.3 ASID / global 控制送 JTLB

probe/invva 时把待比较 ASID、是否忽略 ASID（`tlboper_jtlb_cmp_noasid`，对应 sfence 全 ASID 清）、tlbwr 选 way 等直接送 JTLB（`:1080-1089`）。

---

## 本章小结

MMU arb 把 PTW 回填、TLB 维护、duTLB、iuTLB 和 PFU 等请求汇聚到 JTLB 端口，优先关系依次为 PTW 回填、tlboper、D、I、PFU；各 grant 还受请求 mask、JTLB read state 和 MMU enable 等条件限制，所以优先级表达式不等于请求出现当拍必然接受。PTW 读取 PTE 的内存访问走 MCIC/LSU，不在此仲裁器内。某些来源还具有内部重请求状态，因此外部 valid、内部 pending、最终 grant 和 JTLB SRAM access 必须分别观察。

TLB 维护由状态机和计数器扫描 JTLB SRAM。INVALL 可以按组批量清除 valid，INVASID 必须逐项读取并比较 ASID，INVVA 还要按 4KB、2MB、1GB 三种尺寸搜索，因此不同 sfence 形式的完成时间并不相同。uTLB 不保存 ASID，多数地址空间维护直接整表清空，少数按 VA 清除。sfence 起始还会使正在进行的 PTW 丢弃当前遍历进度，在途 PTE 返回被消费后从根页表重启；`tlboper_on` 同时屏蔽不应在维护期间完成的回填。一次维护只有经历 request、仲裁、SRAM 读写/比较并最终产生 operation complete 才结束，看到起始脉冲或某次 SRAM access 都不能提前宣告完成。
