# C910 CP0 CSR 寄存器 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/cp0/rtl/ct_cp0_regs.v`（4394 行）
> 地址常量同时定义于 `ct_cp0_iui.v`（行 438-708）与 `ct_cp0_regs.v`（行 1145 起）。
> 本文是 CSR 速查 + 访问/读写机制；陷入相关 CSR 的动态行为见 [01_cp0_trap.md](./01_cp0_trap.md)。

---

## 目录

- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. CSR 地址全表](#3-csr-地址全表)
- [4. 标准 RISC-V CSR 详解](#4-标准-risc-v-csr-详解)
- [5. 玄铁私有扩展 CSR 详解](#5-玄铁私有扩展-csr-详解)
- [6. CSR 写通路：xx_local_en 写解码](#6-csr-写通路xx_local_en-写解码)
- [7. CSR 读通路：data_out 大多路与访问路由](#7-csr-读通路data_out-大多路与访问路由)
- [8. 访问控制：地址合法性与特权检查](#8-访问控制地址合法性与特权检查)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

`ct_cp0_regs.v` 的本质是一座 **CSR 寄存器堆**：上百个标准与私有 CSR 的实体、它们的写使能解码、读出多路选择，以及把寄存器位扇出成全核配置信号。每个 CSR 在源码里都有一段固定模板：

```
//===== Define the XXX register =====
parameter XXX = 12'h???;            // 地址（行 1145 起）
assign xxx_local_en = iui_regs_sel && iui_regs_addr == XXX;   // 写使能（行 1372 起）
always @(...) if(xxx_local_en) reg <= iui_regs_src0[...];      // 寄存器实体
assign xxx_value = {...};            // 读出值拼装
XXX : data_out = xxx_value;          // 读多路一项（行 3900 起）
```

读懂这一个模板，就读懂了全文件的写法。下面的表与详解都按这个结构组织。

---

## 2. 端口说明

CSR 读写相关的 regs.v 端口：

| 信号 | 方向 | 含义 |
|---|---|---|
| `iui_regs_sel` | in | 一次合法 CSR 写选通（来自 iui EX2 commit） |
| `iui_regs_addr[11:0]` | in | CSR 地址 |
| `iui_regs_src0[63:0]` | in | 写数据（已按 CSRRW/S/C 语义计算） |
| `iui_regs_csr_wr` | in | 是写类 CSR 指令（非只读） |
| `regs_iui_data_out[63:0]` | out | CSR 读出值（回 iui → IU） |
| `regs_iui_pm[1:0]` | out | 当前特权级（供 iui 权限判定） |
| `regs_iui_fs_off`/`vs_off` | out | 浮点/向量单元关闭（权限判定用） |
| `regs_iui_scnt_inv`/`ucnt_inv` | out | 计数器访问越权标志 |
| `cp0_mmu_*`/`cp0_pmp_*`/`cp0_hpcp_*` | out | 转给 MMU/PMP/HPCP 子寄存器堆的写选通与数据 |

CP0 的 CSR 并非全在 regs.v 内部：**PMP**（地址 0x3A/0x3B）、**MMU/satp**（0x9x、satp）、**HPCP 性能计数器**（0xB/0x32/0x33/0xC0…）的实体分别在 PMP/MMU/HPCP 单元，regs.v 只做地址路由（见 §7）。

---

## 3. CSR 地址全表

下表整理自 `ct_cp0_iui.v` 行 438-708 的 `parameter` 定义。"实体位置"指寄存器真正存在哪个单元。

### 3.1 机器级（M-mode）标准

| CSR | 地址 | 行(iui) | 作用 | 实体 |
|---|---|---|---|---|
| MVENDORID | 0xF11 | 438 | 厂商 ID（=0x5B7） | regs 1455 |
| MARCHID | 0xF12 | 439 | 架构 ID（=0） | regs 1466 |
| MIMPID | 0xF13 | 440 | 实现 ID（=0） | regs 1477 |
| MHARTID | 0xF14 | 441 | Hart ID（=coreid） | regs 1487 |
| MSTATUS | 0x300 | 444 | 机器状态（特权栈/中断使能/访存权限） | regs 1495+ |
| MISA | 0x301 | 445 | ISA 能力（RV64IMAFDC+SU） | regs 1738 |
| MEDELEG | 0x302 | 446 | 异常委派 | regs 1752 |
| MIDELEG | 0x303 | 447 | 中断委派 | regs 1808 |
| MIE | 0x304 | 448 | 中断使能 | regs 1856 |
| MTVEC | 0x305 | 449 | 陷入向量基址+模式 | regs 1913 |
| MCNTEN | 0x306 | 450 | 计数器使能 | regs 1944 |
| MSCRATCH | 0x340 | 453 | M 暂存 | regs 1964 |
| MEPC | 0x341 | 454 | M 返回 PC | regs 1983 |
| MCAUSE | 0x342 | 455 | M 陷入原因 | regs 2005 |
| MTVAL | 0x343 | 456 | M 陷入辅助值 | regs 2041 |
| MIP | 0x344 | 457 | 中断挂起 | regs 2080 |
| PMPCFG0/2 | 0x3A0/2 | 460-461 | PMP 配置 | PMP 单元 |
| PMPADDR0-15 | 0x3B0-F | 462-477 | PMP 地址 | PMP 单元 |
| MCYCLE/MINSTRET/MHPMCNT3-31 | 0xB00-1F | 480-510 | 机器计数器 | HPCP |
| MCNTIHBT/MHPMEVT3-31 | 0x320/0x323-33F | 516-545 | 计数器抑制/事件 | HPCP |
| MHPMCR/SP/EP | 0x7F0-2 | 513-515 | HPM 控制 | HPCP |

### 3.2 监管级（S-mode）标准

| CSR | 地址 | 行(iui) | 作用 | 实体 |
|---|---|---|---|---|
| SSTATUS | 0x100 | 550 | mstatus 的 S 视图 | regs 2213 |
| SIE | 0x104 | 551 | S 中断使能视图 | regs 2226 |
| STVEC | 0x105 | 552 | S 向量 | regs 2240 |
| SCNTEN | 0x106 | 553 | S 计数器使能 | regs 2272 |
| SSCRATCH | 0x140 | 556 | S 暂存 | regs 2296 |
| SEPC | 0x141 | 557 | S 返回 PC | regs 2308 |
| SCAUSE | 0x142 | 558 | S 陷入原因 | regs 2330 |
| STVAL | 0x143 | 559 | S 陷入辅助值 | regs 2364 |
| SIP | 0x144 | 560 | S 中断挂起 | regs 2388 |
| SATP | 0x180 | 563 | 地址翻译与保护 | MMU 单元 |

### 3.3 用户级（U-mode）标准

| CSR | 地址 | 行(iui) | 作用 | 实体 |
|---|---|---|---|---|
| FFLAGS/FRM/FCSR | 0x001/2/3 | 568-570 | 浮点状态/舍入 | regs 2410/2415/2420 |
| VSTART/VXSAT/VXRM | 0x008/9/A | 571-573 | 向量起始/饱和/舍入 | regs 2534/2557/2562 |
| CYCLE/TIME/INSTRET/HPMCNT3-31 | 0xC00-1F | 576-607 | 用户计数器 | HPCP |
| VL/VTYPE/VLENB | 0xC20/21/22 | 609-611 | 向量长度/类型/字节数 | regs 2567/2593/2627 |

### 3.4 玄铁私有扩展 CSR

| CSR | 地址 | 行(iui) | 作用 | 实体 |
|---|---|---|---|---|
| **MXSTATUS** | 0x7C0 | 615 | 扩展机器状态（pm/mm/maee/ucme/pmd…） | regs 2768 |
| **MHCR** | 0x7C1 | 616 | 硬件配置（分支预测/cache 使能） | regs 2843 |
| **MCOR** | 0x7C2 | 617 | cache 操作（inv/clr/分支预测器 inv） | regs 2846+ |
| MCCR2 | 0x7C3 | 618 | L2 cache 控制（路由到 BIU/L2） | L2 |
| MCER2 | 0x7C4 | 619 | L2 错误（路由到 L2） | L2 |
| **MHINT** | 0x7C5 | 620 | 性能提示（预取/写突发/转发禁用…） | regs 2962+ |
| MRMR | 0x7C6 | 621 | 复位控制（未实现，行 1419 注释） | — |
| **MRVBR** | 0x7C7 | 622 | 复位向量基址（只读） | regs 3039 |
| **MCER** | 0x7C8 | 623 | cache 错误（C910 恒 0） | regs 3137 |
| MCNTWEN | 0x7C9 | 624 | 计数器写使能 | regs |
| MCNTINTEN/MCNTOF | 0x7CA/CB | 625-626 | 计数器中断/溢出 | HPCP |
| MHINT2/3/4 | 0x7CC/CD/CE | 627-629 | 扩展提示（vsetvli 预测/div 禁用…） | regs 3067/MHINT3/L2 |
| MSMPR | 0x7F3 | 631 | SMP 控制（路由 L2） | L2 |
| MTEECFG | 0x7F4 | 632 | TEE 配置（路由 L2） | L2 |
| MCINS | 0x7D2 | 635 | cache 读行指令 | regs 3208 |
| MCINDEX | 0x7D3 | 636 | cache 读行索引 | regs 3261 |
| MCDATA0/1 | 0x7D4/5 | 637-638 | cache 读行数据 | regs 3304 |
| MEICR/MEICR2 | 0x7D6/7 | 639-640 | 错误注入（恒 0） | regs 3196/L2 |
| MCPUID | 0xFC0 | 644 | CPU ID 扩展（多字段，索引递增） | regs 3683 |
| MAPBADDR | 0xFC1 | 645 | APB 基址（只读=biu_cp0_apb_base） | regs 3683 |
| MWMSR | 0xFC2 | 646 | （恒 0） | regs 3688 |
| **SXSTATUS** | 0x5C0 | 649 | mxstatus 的 S 视图 | regs |
| SHCR/SCER2/SCER | 0x5C1-3 | 650-652 | S 视图硬件配置/错误 | regs/L2 |
| SCNTINTEN/OF/SHINT… | 0x5C4-CB | 653-660 | S 视图计数器/提示 | HPCP/regs |
| SCYCLE/SINSTRET/SHPMCNT3-31 | 0x5E0-FF | 663-693 | S 计数器 | HPCP |
| SMIR/SMEL/SMEH/SMCIR | 0x9C0-3 | 696-699 | TLB 操作扩展 | MMU |
| FXCR | 0x800 | 702 | 浮点扩展控制 | regs |

> H 扩展相关（HSTATUS 0x600、HEDELEG 0x602、VSSTATUS 0x200，iui 行 705-708）在 C910 里读出恒 0（regs 行 3767 等），属保留死代码。

---

## 4. 标准 RISC-V CSR 详解

陷入核心五件套（MSTATUS / MEPC / MCAUSE / MTVAL / MTVEC）及委派/中断（MEDELEG/MIDELEG/MIE/MIP）的动态行为已在 [01_cp0_trap.md](./01_cp0_trap.md) 完整展开，此处不重复。本节补充其余标准 CSR：

- **MISA**（行 1728-1738）：`mxl=2`(RV64)，扩展位 `extensions[25:0]` 硬编码点亮 I/M/A/F/D/C/S/U（行 1736-1737），向量位 `misa_vector` 与 H 位均为 0（可配置但本核关闭）。MISA 只读（无 local_en 写实体，misa_local_en 实际错绑到 MCAUSE，行 1373，等同不可写）。
- **MSCRATCH/SSCRATCH**（行 1964、2296）：纯 64 位读写暂存，无副作用。
- **MCNTEN/SCNTEN**（行 1944、2272）：32 位计数器使能位图，配合 §8 的计数器访问越权判定。
- **MHARTID**（行 1487）：`{61'b0, biu_cp0_coreid[2:0]}`，多核时每核唯一。
- **SSTATUS/SIE/SIP**（行 2213、2226、2394）：都是 mstatus/mie/mip 的"子集视图"——同一组底层寄存器位（mxr/sum/spp/spie/sie_bit、seie/stie/ssie…）换一个拼装格式读出，写时也只允许改 S 可见的位。这正是 RISC-V"S 视图是 M 寄存器子集"的硬件实现：没有独立的 sstatus 寄存器实体。
- **浮点 FFLAGS/FRM/FCSR**（行 2410-2510）：FFLAGS/FRM 是 FCSR 的字段切片视图（行 2410、2415），底层只有一套 fcsr 位。

---

## 5. 玄铁私有扩展 CSR 详解

### 5.1 MXSTATUS（0x7C0，行 2768）

扩展机器状态，承载 C910 私有的关键开关。位域（拼装行 2768-2771）：

| 字段 | bit | 行 | 作用 |
|---|---|---|---|
| pm | [31:30] | 2768 | 当前特权级（只读镜像） |
| cskyisaee | 22 | 2734 | C-SKY 扩展指令使能 |
| maee | 21 | 2735 | 扩展地址属性使能 |
| insde | 19 | 2736 | 指令本地错误使能 |
| mhrd | 18 | 2737 | 硬件页表遍历禁用（→ cp0_mmu_ptw_en，行 4257） |
| clintee | 17 | 2738 | CLINT S 中断使能（影响 stip/ssip，行 2116-2117） |
| ucme | 16 | 2739 | 用户态 cache 维护使能 |
| mm | 15 | 2689 | 非对齐访存使能（→ cp0_lsu_mm） |
| pmdm/pmds/pmdu | 13/11/10 | 2740/2690/2691 | M/S/U 态性能计数禁用 |

### 5.2 MHCR（0x7C1，行 2843）—— 硬件功能总开关

直接控制 IFU/cache 各功能模块使能（拼装行 2843-2844）：

| 字段 | bit | 行 | 广播到 |
|---|---|---|---|
| l0btbe | 12 | 2803 | cp0_ifu_l0btb_en |
| ibpe | 7 | 2789 | cp0_ifu_ind_btb_en |
| btbe | 6 | 2804 | cp0_ifu_btb_en |
| bpe | 5 | 2827 | cp0_ifu_bht_en |
| rse | 4 | 2828 | cp0_ifu_ras_en |
| wa | 2 | 2829 | cp0_lsu_wa（写分配） |
| de | 1 | 2830 | cp0_lsu_dcache_en |
| ie | 0 | 2831 | cp0_ifu_icache_en |

这是软件打开/关闭分支预测、I/D-cache 的总闸。

### 5.3 MCOR（0x7C2，行 2846）—— cache/分支预测器维护

写该寄存器触发各种 invalidate/clear，且这些位是**自清的**：发出后等对端 done 信号回来自动清 0。例：
```verilog
// 行 2867-2879  btb_inv：写 mcor[17] 置位，ifu_cp0_btb_inv_done 回来清 0
if(mcor_local_en)              btb_inv <= iui_regs_src0[17];
else if(ifu_cp0_btb_inv_done) btb_inv <= 1'b0;
```
同理 bht_inv（bit16，行 2881）、ibp_inv（bit18，行 2853）。dcache 的 clr/inv 还要等 `lsu_cp0_dcache_done`（行 2897）。这套"写位发起、done 清位、未清期间 `regs_iui_cfr_no_op` 拉低让指令等待"（行 3992）实现了 cache 维护指令的阻塞语义。

### 5.4 MHINT（0x7C5，行 2962）—— 性能提示

一组性能调优开关，全部读写无副作用，仅广播给 LSU/IFU。位域（拼装行 2962+）：corr_dis(25)、fencei/fencerw/tlb_broad_dis(23/22/21)、l2stpld(20)、nsfe(18)、l2_pref_dist(17:16)、l2pld(15)、dcache_pref_dist(14:13)、sre(11)、iwpe(10)、lpe(9)、icache_pref_en(8)、amr2(5)、amr(3)、dcache_pref_en(2)。MHINT2（0x7CC，行 3067）含 vsetvli 预测、div 入口禁用等更细的微架构开关。

### 5.5 MRVBR（0x7C7，行 3039）—— 复位向量，只读

上电首次 `ifu_cp0_rst_inv_req` 采样引脚 `biu_cp0_rvba` 存入 `mrvbr_reg`（行 3046-3064），软件只能读，经 `cp0_ifu_rvbr` 给 IFU 当复位入口。

### 5.6 MCER（0x7C8，行 3137）

cache 错误寄存器。OpenC910 公开版未实现 ECC，故 `mcer_value=64'b0`、`ecc_int_vld=1'b0`（行 3144-3145），读出恒 0。结构保留供带 ECC 的派生核填充。

### 5.7 MCINS/MCINDEX/MCDATA（0x7D2-5，行 3208+）—— cache 读行通道

软件诊断用：写 MCINDEX 指定 cache 类型(rid)/way/index（行 3262-3284，rid 编码见行 3286-3293：0=icache tag,1=icache data,2=dcache st_tag,3=dcache data,4/5=L2,12=dcache ld_tag），写 MCINS[0] 发起读（行 3225），读回的数据经 MCDATA0/1 返回（行 3304-3370 锁存来自 ifu/lsu/biu 的 read_data）。

---

## 6. CSR 写通路：xx_local_en 写解码

每个可写 CSR 都有一行写使能解码（行 1372-1437），统一格式：
```verilog
// 行 1372
assign mstatus_local_en = iui_regs_sel && iui_regs_addr[11:0] == MSTATUS;
```
`iui_regs_sel` 是 iui 在 EX2 确认指令退休、且特权检查通过后给出的总选通（见 [03 文档](./03_cp0_lpmd_iui.md) §4）。因此**任何 CSR 写都隐含"已退休 + 已鉴权"两个前提**。

少数私有 CSR 的 local_en 不带 `iui_regs_sel`（如 mhint4/msmpr/mccr2/satp，行 1410/1412/1417/1433），因为它们要在更早的拍把写选通路由给外部单元（L2/MMU），由对端再做提交时序。

写数据 `iui_regs_src0` 已在 iui 里按 CSRRW（直接写）/CSRRS（按位置 1）/CSRRC（按位清 0）算好（iui.v 行 1436-1448），regs 只管落盘。

---

## 7. CSR 读通路：data_out 大多路与访问路由

### 7.1 内部 CSR 读多路

regs 内部所有 CSR 的读出值汇到一个大 `case`（行 3900-3975），按 `iui_regs_addr` 选出 `data_out`。default 返回 0（行 3974）——读不存在的地址得 0。

### 7.2 跨单元读路由

最终回给 iui 的 `regs_iui_data_out` 是**五选一**（行 3996-4001），把内部 data_out 与 PMP/HPCP/MMU/satp 的回读数据按"哪类地址"合并：
```verilog
assign regs_iui_data_out = {64{cp0_regs_sel}}  & data_out          // regs 内部
                         | {64{pmp_regs_sel}}  & pmp_cp0_data       // PMP 单元
                         | {64{hpm_regs_sel}}  & hpcp_cp0_data      // HPCP 单元
                         | {64{satp_local_en}} & mmu_cp0_satp_data  // satp
                         | {64{mmu_regs_sel}}  & mmu_cp0_data;      // MMU 其它
```

各 `*_regs_sel` 是按地址高位段译码的（行 3792-3832）：例如 `cp0_regs_sel` 匹配 0xFxx/0x30x/0x34x/0x10x/0x14x/0x7Cx… 等大段（行 3792-3807），`mmu_regs_sel = addr[11:8]==4'h9`（行 3832），`pmp_regs_sel = addr[11:4]==0x3A/0x3B`（行 3809）。这套"高位段译码 → one-hot 选通 → 与数据"的结构让 CP0 既是寄存器堆又是 CSR 总线的路由器。

---

## 8. 访问控制：地址合法性与特权检查

CSR 访问的合法性分两道，都在 **iui** 里做（详见 [03 文档](./03_cp0_lpmd_iui.md) §5），这里给读 02 时的速览：

1. **地址合法性 `addr_inv`**（iui.v 行 809-1076）：一个大 `casez`，列出所有实现的地址，命中则 `addr_inv=0`；未命中（含本核未实现的标准地址）则 `addr_inv=1`，产生非法指令异常。注意私有地址段用通配匹配（如 `12'b0111_11??_????` 覆盖 0x7C0-0x7FF，行 885）。
2. **特权检查 `iui_privilege`**（iui.v 行 1374-1380）：综合特权级（`iui_addr[9:8]` 取 CSR 地址里编码的最低访问特权）、读写性（写只读 CSR `iui_w_inv`，地址[11:10]==11，行 1343）、fs/vs 关闭（行 1347-1361）、计数器越权（`regs_iui_scnt_inv`/`ucnt_inv`，由 regs 行 4065-4068 算出）等。

计数器越权判定值得一提：regs 行 4058-4068 把 CSR 地址译成 32 位 one-hot `cnt_sel`（行 4018-4054），再与 mcnten/scnten/mcntwen 按位与，判断当前特权级是否被授权读该计数器——实现了 RISC-V 的 `[m|s]counteren` 分级授权。

---

## 设计取舍小结

1. **"地址表写两遍"**：iui 与 regs 各有一份 `parameter` 地址表。iui 那份服务"地址合法性 + 权限"，regs 那份服务"读写解码"。重复换来两个模块各自自洽、综合时各自优化，且地址改动只影响本模块行为定义。

2. **CSR 堆兼任总线路由器**：regs 不只存自己的 CSR，还按地址段把 PMP/MMU/HPCP/L2 的读写路由出去（行 3792-3832、3996-4001、4245-4277）。把"CSR 地址空间唯一入口"集中在 CP0，外部单元只暴露数据口，简化了全核 CSR 互连。

3. **S 视图无独立实体**：sstatus/sie/sip 都是 mstatus/mie/mip 的换格式读出（行 2213/2226/2394），底层共享同一批触发器。省面积，且天然保证 M 与 S 视图一致。

4. **维护类位自清 + 阻塞握手**：MCOR 的各 inv/clr 位写后等 done 自清（行 2867-2897），并通过 `regs_iui_cfr_no_op`（行 3992）让指令在维护完成前不提交。把"长延时 cache 操作"做成寄存器位 + done 握手，避免在 CP0 里塞状态机。

5. **未实现功能留 0 不留洞**：MCER/MEICR/MWMSR/H 系列读出硬编码 0（行 3144、3196、3688、3767），地址仍在合法表里——软件读得到合法的 0，而非触发非法异常。这对软件兼容更友好，也为派生核预留填充点。

6. **计数器授权用 one-hot 按位与**：把计数器地址译成 one-hot 再与使能位图相与（行 4058-4068），一次比较覆盖 32 个计数器的分级授权，比逐个比较地址简洁得多。

---

*文档覆盖 ct_cp0_regs.v 全部 4394 行中 CSR 定义/读写/路由/访问控制部分；陷入动态行为见 [01_cp0_trap.md](./01_cp0_trap.md)。*
