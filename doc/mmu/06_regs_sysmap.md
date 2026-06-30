# C910 MMU regs + sysmap（寄存器与硬连线 PMA）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/ct_mmu_regs.v`（约 724 行）、`ct_mmu_sysmap.v`（约 210 行）、`ct_mmu_sysmap_hit.v`（约 47 行）、`sysmap.h`（52 行宏定义）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [satp 寄存器](#4-satp-寄存器)
5. [TLB 维护寄存器 MIR/MEL/MEH/MCIR](#5-tlb-维护寄存器-mirmelmehmcir)
6. [XMAE 14 位属性（SO/CA/BUF/SEC/SH）](#6-xmae-14-位属性socabufsecsh)
7. [sysmap：8 区硬连线 PMA](#7-sysmap8-区硬连线-pma)
8. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

- **regs（`ct_mmu_regs.v`）**：存放 MMU 的所有软件可见寄存器 —— 标准的 **satp**（控制翻译开关、ASID、根页表 PPN），以及 T-Head 扩展的 **MIR/MEL/MEH/MCIR** 四个 TLB 维护寄存器。它解码 CP0 写、生成各维护操作的触发信号给 tlboper，并把 satp 内容分发给 PTW/JTLB。
- **sysmap（`ct_mmu_sysmap.v` + `_hit.v` + `sysmap.h`）**：一张**硬连线的 8 区物理内存属性（PMA）表**。当 MMU 关闭、或大页跨区检查、或没有页表属性时，物理地址落在哪个区就用该区硬定义的属性（cacheable/strong-order 等）。

### 1.2 位置

regs 接 CP0（`cp0_mmu_*`）、接 tlboper（双向）、接 PTW/JTLB（输出 satp.ppn/asid）。sysmap 是纯组合查表，输入物理页号、输出 5 位属性 flag 和 8 位命中向量，被 PTW 和 duTLB_read 等调用。

---

## 2. 端口说明

### 2.1 regs ↔ CP0

| 信号 | 方向 | 含义 |
|------|------|------|
| `cp0_mmu_reg_num[1:0]` / `cp0_mmu_wreg` / `cp0_mmu_wdata` | in | 写哪个 MMU 寄存器 / 写数据 |
| `cp0_mmu_satp_sel` | in | 写 satp |
| `cp0_mmu_cskyee` | in | T-Head 扩展使能（维护寄存器解码门控） |
| `mmu_cp0_data` / `mmu_cp0_satp_data` | out | 读回数据 |
| `mmu_xx_mmu_en` / `mmu_lsu_mmu_en` | out | MMU 是否使能 |

### 2.2 regs ↔ tlboper / JTLB / PTW

| 信号 | 方向 | 含义 |
|------|------|------|
| `regs_tlboper_invall/invasid/tlbp/tlbr/tlbwi/tlbwr` | out | 触发各维护操作 |
| `regs_tlboper_cur_vpn/pgs/asid/inv_asid/mir` | out | 维护操作用的参数 |
| `regs_ptw_satp_ppn` / `regs_ptw_cur_asid` | out | 给 PTW |
| `regs_jtlb_cur_asid/ppn/flg/g` | out | 给 JTLB（写项/比较） |
| `regs_utlb_clr` | out | satp 写 → 清 uTLB |
| `jtlb_tlbr_*` / `jtlb_regs_hit*` | in | TLBR/TLBP 结果回写 |

### 2.3 sysmap

| 信号 | 方向 | 含义 |
|------|------|------|
| `mmu_sysmap_pa_y[27:0]` | in | 物理页号 |
| `sysmap_mmu_flg_y[4:0]` | out | 5 位 PMA 属性 |
| `sysmap_mmu_hit_y[7:0]` | out | 命中哪个区（one-hot） |

---

## 3. 参数与关键寄存器

regs 宽度参数（`ct_mmu_regs.v:229-233`）：`VPN_WIDTH=27`、`PPN_WIDTH=28`、`FLG_WIDTH=14`、`PGS_WIDTH=3`、`ASID_WIDTH=16`。

四个维护寄存器编号（`:272-275`）：`MIR_NUM=0`、`MEL_NUM=1`、`MEH_NUM=2`、`MCIR_NUM=3`。

sysmap 参数（`ct_mmu_sysmap.v:69-70`）：`ADDR_WIDTH = PA_WIDTH-12`、`FLG_WIDTH=5`。

---

## 4. satp 寄存器

布局（`ct_mmu_regs.v:624-653`）：

```
|63  60|59        44|43        28|27                 0|
| Mode |    ASID    |  Reserved  |        PPN         |
```

- **Mode**（`:630-636`）：写 `cp0_mmu_wdata[63]` 到 `satp_mode[3]`，仅当 `wdata[62:60]==0`（即 mode 只能是 0 或 8）。**`mode==4'b1000` 表示开启 Sv39**（`:700` `regs_mmu_en = satp_mode==4'b1000`）。
- **ASID**（16 位，`:642-648`）、**PPN**（28 位）。

MMU 使能区分两类（`:704-707`）：

```verilog
mmu_lsu_mmu_en = (satp_mode==8) && (priv_mode != M);   // 数据侧（考虑 MPRV）
mmu_xx_mmu_en  = (satp_mode==8) && (cur_priv  != M);   // 取指侧
```

即 M 态不翻译。satp 输出给 PTW（`regs_ptw_satp_ppn`/`regs_ptw_cur_asid`，`:708-709`）和 JTLB（`regs_jtlb_cur_asid`，`:712`）。

**关键联动**：satp 写 → `regs_utlb_clr = satp_write_en`（`:238`）→ 整清 uTLB。这正是"uTLB 不存 ASID、进程切换清空"的实现点（见 01/02 篇）。

---

## 5. TLB 维护寄存器 MIR/MEL/MEH/MCIR

这是 T-Head 对 RISC-V 的扩展，提供软件直接 probe/read/write/invalidate JTLB 的能力（`cp0_mmu_cskyee` 门控）。

### 5.1 MEH（Entry High，`:452-487`）

```
|63    46|45    19|18  16|15    0|
|Reserved|  VPN   | PGS  | ASID  |
```

存待操作项的 VPN/页大小/ASID。异常发生时（`rtu_mmu_expt_vld`）记录 bad VPN（`:472-477`），供软件读取出错地址。

### 5.2 MEL（Entry Low，`:343-446`）

存待操作项的 PPN + 全部属性位：

```
|63 |62 |61 |60 |59 |…|37  32|31  10|9 8| 7 6 5 4 3 2 1 0 |
| So| C | B | Sh|Sec|…| PPN  | PPN  |RSW|D A G U X W R V  |
```

即高 5 位是扩展 PMA（So/C/B/Sh/Sec），低位是标准 PTE 权限/状态位。TLBR 把 JTLB 读出项写进 MEL（`:423-440`），TLBWI/WR 把 MEL 写进 JTLB。

### 5.3 MIR（Index，`:290-340`）

存 probe/写操作的 index，以及 TLBP 结果：`P`（match flag，`:319`）、`tlbp_tfatal`（多命中，`:320`）、`Index`（命中位置，`:334-337`）。

### 5.4 MCIR（Control & Invalidate，`:490-619`）

```
|31  |30  |29   |28   |27       |26    |25  16| 15 0 |
|tlbp|tlbr|tlbwi|tlbwr|inv asid |invall|resv. | ASID |
```

写 MCIR 的对应位即触发相应维护操作（`:504-520` 解码），各操作有独立的 set/clear 触发寄存器（`:522-590`），完成时由 `tlboper_regs_cmplt` 清零。`mcir_no_op`（`:609-619`）处理写全 0 的空操作。这些触发位输出给 tlboper（`:687-692`）。

---

## 6. XMAE 14 位属性（SO/CA/BUF/SEC/SH）

整个 MMU 的页属性 flag 统一是 **14 位**（`FLG_WIDTH=14`），由 **5 位扩展 PMA + 9 位标准位**组成。它在 PTE、MEL、TLB 项、回 LSU/IFU 之间一脉相承。

### 6.1 14 位 flag 的构成

从 PTW 组装可见（`ct_mmu_ptw.v:718`）：

```verilog
ptw_ref_flg[13:0] = {ptw_ref_pma[4:0], lsu_data_flop[9:6], lsu_data_flop[4:0]};
//                    └─ 5 位扩展 PMA ┘ └─ RSW,D,A ┘ └─ U,X,W,R,V ┘
```

| bit | 含义 | bit | 含义 |
|-----|------|-----|------|
| 13 | **SO** Strong-order（强序） | 6 | D Dirty |
| 12 | **CA** Cacheable（可缓存） | 5 | A Accessed |
| 11 | **BUF** Bufferable（可缓冲） | 4 | U User |
| 10 | **SH** Shareable（可共享） | 3 | X Execute |
| 9  | **SEC** Security（安全） | 2 | W Write |
| 8-7 | RSW（软件保留） | 1 | R Read |
|     |      | 0 | V Valid |

高 5 位（SO/CA/BUF/SH/SEC）即 **XMAE（扩展内存属性）**，对应 MEL 的 `So/C/B/Sh/Sec`（`ct_mmu_regs.v:443-446` 组装 MEL）。

### 6.2 属性来源（XMAE 使能 maee）

- **`cp0_mmu_maee==1`**：用 PTE 高位 `lsu_data_flop[63:59]` 作为 XMAE（`ct_mmu_ptw.v:709`）—— 页表自带属性。
- **`maee==0`**：用 **sysmap** 区属性 `sysmap_mmu_flg3[4:0]`（`:710`）—— 由物理地址所在区硬定义。

### 6.3 属性如何用

duTLB_read 把 14 位 flag 解给 LSU（`ct_mmu_dutlb_read.v:456-461`）：

```verilog
mmu_lsu_so_x  = flg[13];                  // 强序
mmu_lsu_ca_x  = flg[12] && !flg[13];      // SO 时强制不可缓存
mmu_lsu_buf_x = flg[11] || !flg[13];      // 非 SO 必可缓冲
mmu_lsu_sh_x  = flg[10] && !smp_disable;  // 共享
mmu_lsu_sec_x = flg[9];                   // 安全
```

注意 SO 与 CA 的互斥逻辑：强序内存（设备）必然不可缓存。

---

## 7. sysmap：8 区硬连线 PMA

### 7.1 思想：MMU 关时也得有内存属性

当 MMU 关闭（M 态或 satp.mode=0）、或大页跨区、或 maee=0 时，没有页表项提供属性，物理地址的 cacheable/strong-order 等必须从别处来。sysmap 就是一张**编译期固化（硬连线）的 8 段地址→属性表**：把物理地址空间分 8 段，每段一个 5 位属性，地址落哪段用哪段属性。

### 7.2 边界与属性定义（sysmap.h）

`sysmap.h` 定义 8 个段的上界 `SYSMAP_BASE_ADDR0..7`（28 位物理页号粒度）和属性 `SYSMAP_FLG0..7`（5 位）。例如（`sysmap.h:27-49`，非 FPGA 分支）：

```
ADDR0=0x01000 FLG0=01111   ADDR1=0x02000 FLG1=10000
ADDR2=0xd0000 FLG2=10000   ADDR3=0xeffff FLG3=01101
ADDR4=0xfffff FLG4=01111   ADDR5=0x4000000 FLG5=01111
ADDR6=0x5000000 FLG6=10000 ADDR7=0xfffffff FLG7=01111
```

5 位属性对应 `{SO, CA, BUF, SH, SEC}`（与 14 位 flag 的高 5 位同构）。例如 `01111` = 非 SO、可缓存可缓冲可共享有安全；`10000` = 强序（设备区）。

### 7.3 命中逻辑

sysmap 是 8 个"区间比较器"的级联（`ct_mmu_sysmap.v`）：

- 每段一个 `sysmap_comp_hit`：地址是否 < 该段上界（`:189-204`）。
- 每段命中 = 地址 ≥ 下界 且 < 上界（`ct_mmu_sysmap_hit.v:42` `sysmap_mmu_hit_x = addr_ge_bottom_x && addr_ls_top`），下界即上一段的上界，首段下界固定为 0（`ct_mmu_sysmap.v:154-161`）。
- 8 个命中拼成 one-hot `sysmap_hit[7:0]`（`:164-167`），用 casez 选出对应区的 5 位属性（`:170-183`）。默认属性 `5'b10011`（`:182`）。

输出 `sysmap_mmu_flg_y`（5 位属性）和 `sysmap_mmu_hit_y`（8 位 one-hot 命中区）。后者被 PTW 的大页跨区检查使用（见 04 篇 7.3：比较大页起止点的 hit 向量是否一致，不一致则降级）。

---

## 设计取舍小结

- **satp 写即清 uTLB**：用一根 `regs_utlb_clr` 把"uTLB 不存 ASID、进程切换清空"落地，配合 JTLB 存 ASID 不清空，构成完整的 ASID 分层策略。
- **MIR/MEL/MEH/MCIR 扩展**：给软件直接 probe/read/write/invalidate JTLB 的能力，弥补纯 sfence 的粒度不足（T-Head 扩展，cskyee 门控）。
- **14 位 flag 贯穿全链**：5 位 XMAE + 9 位标准位，从 PTE/sysmap 一路传到 LSU/IFU，SO/CA/BUF 间有互斥约束。
- **属性双来源**：maee=1 用页表自带属性，maee=0 用 sysmap 硬连线区属性，保证 MMU 关或无页表时也有确定 PMA。
- **sysmap 硬连线 8 区**：编译期固化的区间比较表，零运行开销给出物理内存属性，并支撑 PTW 的大页跨区降级判断。

*文档覆盖 ct_mmu_regs.v（724 行）、ct_mmu_sysmap.v（210 行）、ct_mmu_sysmap_hit.v（47 行）与 sysmap.h 全部逻辑。*
