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
- [本章小结](#本章小结)

---

## 1. 模块概述

`ct_cp0_regs.v` 同时承担三种角色：

1. 保存 CP0 本地实现的 CSR 状态；
2. 把 PMP、MMU、HPCP、BIU/L2 等单元中的 CSR 地址路由到对应单元；
3. 把本地 CSR 位广播成 IFU、IDU、LSU、MMU 等模块的控制信号。

多数本地可写 CSR 使用如下模板：

```
//===== Define the XXX register =====
parameter XXX = 12'h???;            // 地址（行 1145 起）
assign xxx_local_en = iui_regs_sel && iui_regs_addr == XXX;   // 写使能（行 1372 起）
always @(...) if(xxx_local_en) reg <= iui_regs_src0[...];      // 寄存器实体
assign xxx_value = {...};            // 读出值拼装
XXX : data_out = xxx_value;          // 读多路一项（行 3900 起）
```

这只是常见模板，不是所有地址的统一保证。只读常量、陷入多源更新状态、维护类自清位、外部单元 CSR 和“地址合法但没有实体”的自定义地址都不完全遵循它。

---

## 2. 端口说明

CSR 读写相关的 regs.v 端口：

| 信号 | 方向 | 含义 |
|---|---|---|
| `iui_regs_sel` | in | 本地/下游 CSR 的提交写选通；要求写类 CSR 已在 EX1 识别，且 EX2 的 IID 与 commit0 匹配 |
| `iui_regs_addr[11:0]` | in | CSR 地址 |
| `iui_regs_src0[63:0]` | in | 写数据（已按 CSRRW/S/C 语义计算） |
| `iui_regs_csr_wr` | in | 是写类 CSR 指令（非只读） |
| `regs_iui_data_out[63:0]` | out | CSR 读出值（回 iui → IU） |
| `regs_iui_pm[1:0]` | out | 当前特权级（供 iui 权限判定） |
| `regs_iui_fs_off`/`vs_off` | out | 浮点/向量单元关闭（权限判定用） |
| `regs_iui_scnt_inv`/`ucnt_inv` | out | 计数器访问越权标志 |
| `cp0_mmu_*`/`cp0_pmp_*`/`cp0_hpcp_*` | out | 转给 MMU/PMP/HPCP 子寄存器堆的写选通与数据 |

CP0 的 CSR 并非全在 regs.v 内部：PMP、MMU、HPCP 和 BIU/L2 方向的实体位于相应单元。regs 提供地址分类、写数据和选择信号，IUI 还为 BIU/HPCP 路径生成请求/完成握手。不能仅看到 regs 中有某个 `*_local_en` 就断言寄存器状态也保存在 regs。

---

## 3. CSR 地址全表

下表主要整理自 `ct_cp0_iui.v` 的 parameter 定义。“定义了 parameter”“IUI 认为地址合法”“存在可读写实体”是三件不同的事：

- 标准 CSR 地址通常必须在 `addr_inv` case 中逐项列出；
- 自定义地址段使用通配符，段内未实现地址也可能通过合法性检查；
- 通过合法性检查后，若读 MUX/外部单元没有实体，读值可能为 0、写入可能无效果。

因此下表是地址与路由索引，不是“每项都完整实现”的合规声明。

### 3.1 机器级（M-mode）标准

| CSR | 地址 | 行(iui) | 作用 | 实体 |
|---|---|---|---|---|
| MVENDORID | 0xF11 | 438 | 厂商 ID（=0x5B7） | regs 1455 |
| MARCHID | 0xF12 | 439 | 架构 ID（=0） | regs 1466 |
| MIMPID | 0xF13 | 440 | 实现 ID（=0） | regs 1477 |
| MHARTID | 0xF14 | 441 | Hart ID（=coreid） | regs 1487 |
| MSTATUS | 0x300 | 444 | 机器状态（特权栈/中断使能/访存权限） | regs 1495+ |
| MISA | 0x301 | 445 | ISA 能力（当前读值含 RV64 IMAFDC、S/U、非标准 X；V/H 为 0） | regs 常量 |
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
| VSTART/VXSAT/VXRM | 0x008/9/A | 571-573 | 有 parameter 和 regs 数据通路，但当前 IUI 地址白名单未列出，软件 CSR 访问判非法 | regs 内部状态 |
| CYCLE/TIME/INSTRET/HPMCNT3-31 | 0xC00-1F | 576-607 | 用户计数器 | HPCP |
| VL/VTYPE/VLENB | 0xC20/21/22 | 609-611 | 有 parameter 和 regs 数据通路，但当前 IUI 地址白名单未列出，软件 CSR 访问判非法 | regs 内部状态 |

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

> H 扩展相关 `HSTATUS/HEDELEG/VSSTATUS` 在 iui 和 regs 中有 parameter，regs 读 MUX 也准备了恒零值；但当前 `addr_inv` 白名单没有列出这些地址，且调试模式也不绕过 `csr_addr_inv`。因此通过正常 CP0 指令访问会先产生非法指令异常，不能把它们描述成“软件可合法读到 0”。

---

## 4. 标准 RISC-V CSR 详解

陷入核心五件套（MSTATUS / MEPC / MCAUSE / MTVAL / MTVEC）及委派/中断（MEDELEG/MIDELEG/MIE/MIP）的动态行为已在 [01_cp0_trap.md](./01_cp0_trap.md) 完整展开，此处不重复。本节补充其余标准 CSR：

- **MISA**：`mxl=2` 表示 RV64；扩展位硬连 I/M/A/F/D/C/S/U 和 X，V/H 为 0。MISA 地址 `0x301` 的 CSR 编码并不是只读编码，IUI 也会允许 M 模式写类指令通过；但 regs 没有任何 MISA 状态更新块，`misa_local_en` 还被赋成 `addr==MCAUSE` 且没有被消费。因此实际行为是“写指令可提交但读值不变”，不是“因写只读 CSR 而触发非法指令”。
- **MSCRATCH/SSCRATCH**（行 1964、2296）：纯 64 位读写暂存，无副作用。
- **MCNTEN/SCNTEN**（行 1944、2272）：32 位计数器使能位图，配合 §8 的计数器访问越权判定。
- **MHARTID**（行 1487）：`{61'b0, biu_cp0_coreid[2:0]}`，多核时每核唯一。
- **SSTATUS/SIE/SIP**（行 2213、2226、2394）：都是 mstatus/mie/mip 的"子集视图"——同一组底层寄存器位（mxr/sum/spp/spie/sie_bit、seie/stie/ssie…）换一个拼装格式读出，写时也只允许改 S 可见的位。这正是 RISC-V"S 视图是 M 寄存器子集"的硬件实现：没有独立的 sstatus 寄存器实体。
- **浮点 FFLAGS/FRM/FCSR**：FFLAGS/FRM 是 FCSR 的字段视图，底层共享一套状态。FS=Off 时，IUI 会把对这些地址及 FXCR/VXSAT/VXRM 的访问判为非法。
- **向量 CSR 边界**：regs 中确实有 `vstart/vl/vtype` 等由 RTU 更新的状态，但当前 IUI 地址合法性 case 没有开放这些标准 CSR，且可见 `mstatus.VS` 被固定为 Off。因此“内部有向量相关寄存器”不能写成“当前标准 V CSR 可由软件正常访问”。

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

这些位直接广播为相应使能，因而是软件控制分支预测和 I/D-cache 的主要开关。它们在 CP0 复位时均为 0；实际启动流程是否以及何时打开，要看复位固件。看到 RTL 中存在 cache 不等于复位后 `ie/de` 已经为 1。

### 5.3 MCOR（0x7C2，行 2846）—— cache/分支预测器维护

写该寄存器的相应位会把维护请求状态置位；请求在后续周期保持，直到对应 done、全局 flush 或其他明确清除条件出现。例：
```verilog
// 行 2867-2879  btb_inv：写 mcor[17] 置位，ifu_cp0_btb_inv_done 回来清 0
if(mcor_local_en)              btb_inv <= iui_regs_src0[17];
else if(ifu_cp0_btb_inv_done) btb_inv <= 1'b0;
```
同理还有 bht/indirect-BTB 和 D-cache 维护。若“新写”和“done”同周期同时成立，时序块中的 `mcor_local_en` 分支排在 done 分支之前，新写值优先。`regs_iui_cfr_no_op` 在请求位、当前 `mcor_local_en` 或维护状态仍有效时为 0，使 IUI 的完成条件等待。这是“请求状态 + 对端完成”的阻塞语义，不是写 CSR 的同一拍已经完成 cache 失效。

### 5.4 MHINT（0x7C5，行 2962）—— 性能提示

一组性能调优开关，全部读写无副作用，仅广播给 LSU/IFU。位域（拼装行 2962+）：corr_dis(25)、fencei/fencerw/tlb_broad_dis(23/22/21)、l2stpld(20)、nsfe(18)、l2_pref_dist(17:16)、l2pld(15)、dcache_pref_dist(14:13)、sre(11)、iwpe(10)、lpe(9)、icache_pref_en(8)、amr2(5)、amr(3)、dcache_pref_en(2)。MHINT2（0x7CC，行 3067）含 vsetvli 预测、div 入口禁用等更细的微架构开关。

### 5.5 MRVBR（0x7C7，行 3039）—— 复位向量，只读

`ifu_cp0_rst_inv_req` 先在 `forever_cpuclk` 上形成 `rst_sample`，`mrvbr_reg` 再在 `regs_flush_clk` 有效沿根据 `rst_sample` 采样 `biu_cp0_rvba[39:1]`。这是两步时序，不是请求组合到来时立即锁存。bit0 不保存，读回补 0。

### 5.6 MCER（0x7C8，行 3137）

当前 RTL 把 `mcer_value` 和 `ecc_int_vld` 硬连为 0，因此这个 CP0 模块不会从 MCER 路径报告 ECC 中断。文件中的注释和空结构不能证明整个 SoC 所有 RAM 都没有任何奇偶校验或错误检测，也不能证明未来派生配置；本文只陈述当前两根信号的实现。

### 5.7 MCINS/MCINDEX/MCDATA（0x7D2-5，行 3208+）—— cache 读行通道

软件诊断路径如下：

1. 写 MCINDEX 保存 `rid/way/index`；
2. 写 MCINS bit0，把 `cins_r/cins_ff` 置位；
3. 根据 rid 向 IFU、LSU 或 BIU/L2 路径发读请求；
4. 对端 data-valid/complete 到来时，把 128 位数据锁入 MCDATA0/1；
5. `cins_r` 清零，`regs_iui_cins_no_op` 恢复为 1，指令才可完成。

rid 0/1 对应 I-cache tag/data，2/3 对应 D-cache store-tag/data，4/5 对应 L2 tag/data，12 对应 D-cache load-tag。ECC rid 比较信号在当前 RTL 中硬连为 0，不能把注释中的 ECC 类型当成已实现读取能力。若 rid 不属于任何支持类型，`cins_no_op_data_vld` 会让请求结束，但不会从对端获得新数据；软件不能假定 MCDATA 已更新。

---

## 6. CSR 写通路：xx_local_en 写解码

每个可写 CSR 都有一行写使能解码（行 1372-1437），统一格式：
```verilog
// 行 1372
assign mstatus_local_en = iui_regs_sel && iui_regs_addr[11:0] == MSTATUS;
```
`iui_regs_sel` 要求写类 CSR 在 EX1 被锁存，并且 EX2 中 `cp0_ex2_select` 成立；后者包含匹配 IID 的 commit。特权非法时 `inst_csr_ex1` 不会置位，因此正常本地写同时具备地址/特权合法和 commit 条件。

少数名为 `*_local_en` 的信号只做**地址命中**，没有 `iui_regs_sel`，例如 MCCR2、MHINT4、MSMPR、SATP。它们主要参与地址分类、外部请求选择或读数据路由。真正的外部请求还由 IUI 的 `cp0_biu_sel/cp0_hpcp_sel`、阶段、指令类型、权限和对端 complete 共同限定。

因此，看到这些 raw address-hit 在 EX1 就为 1，不表示外部寄存器已经写入；也不能泛化成“对端一定再次做 commit 检查”，具体接受条件要在 BIU/MMU/HPCP 接收端继续核查。

写数据 `iui_regs_src0` 已在 iui 里按 CSRRW（直接写）/CSRRS（按位置 1）/CSRRC（按位清 0）算好（iui.v 行 1436-1448），regs 只管落盘。

---

## 7. CSR 读通路：data_out 大多路与访问路由

### 7.1 内部 CSR 读多路

regs 内部读值汇到一个大 case，default 为 0。这个 default 只在读数据组合通路上成立：

- 普通未列出的标准地址通常先被 IUI 的 `csr_addr_inv` 判非法，不能形成一次成功的“读 0”；
- 通配开放的自定义地址段可能合法通过，但没有本地/外部实体，此时才可能成功返回 0；
- 若地址被分类到外部单元，最终值取决于外部选择和完成握手。

### 7.2 跨单元读路由

最终回给 iui 的 `regs_iui_data_out` 用掩码 OR 合并五类来源，把内部 data_out 与 PMP/HPCP/MMU/satp 的回读数据按地址类别组合：
```verilog
assign regs_iui_data_out = {64{cp0_regs_sel}}  & data_out          // regs 内部
                         | {64{pmp_regs_sel}}  & pmp_cp0_data       // PMP 单元
                         | {64{hpm_regs_sel}}  & hpcp_cp0_data      // HPCP 单元
                         | {64{satp_local_en}} & mmu_cp0_satp_data  // satp
                         | {64{mmu_regs_sel}}  & mmu_cp0_data;      // MMU 其它
```

各 `*_regs_sel` 按地址高位段译码，例如 `cp0_regs_sel` 匹配本地段，`mmu_regs_sel` 匹配 `0x9xx`，`pmp_regs_sel` 匹配 `0x3Ax/0x3Bx`。这些分类表达式在设计目标上应互斥，但代码形式不是带优先级的通用仲裁器，也没有在此处给出运行时 one-hot 断言。分析具体地址时应逐项代入，不能假设掩码 OR 会自动解决重叠。

---

## 8. 访问控制：地址合法性与特权检查

CSR 访问的合法性分两道，都在 **iui** 里做（详见 [03 文档](./03_cp0_lpmd_iui.md) §5），这里给读 02 时的速览：

1. **地址合法性 `addr_inv`**：标准地址多为逐项白名单；M/S/U 自定义地址段则有整段通配。因而“合法地址”不等于“实现地址”，parameter 的存在也不等于被白名单纳入。当前向量 CSR 和 H/VS CSR 就是“有 parameter/读值结构，但没有合法白名单项”的例子。
2. **特权检查 `iui_privilege`**：综合当前模式、CSR 地址编码的最低特权、只读编码、FS/VS 状态、计数器授权和 TEE 条件。调试模式只让最外层“当前模式允许”条件成立，后面的 `csr_addr_inv/iui_w_inv/iui_fs_inv/iui_vs_inv/iui_tee_inv` 仍然必须全为 0，所以不能说调试模式无限制访问所有地址。

计数器越权判定值得一提：regs 行 4058-4068 把 CSR 地址译成 32 位 one-hot `cnt_sel`（行 4018-4054），再与 mcnten/scnten/mcntwen 按位与，判断当前特权级是否被授权读该计数器——实现了 RISC-V 的 `[m|s]counteren` 分级授权。

---

## 本章小结

CP0 的 CSR 实现必须同时经过地址定义、访问合法性和实体路由三层判断。IUI 与 regs 各自保留地址常量，IUI 的合法性表决定指令是否允许继续，regs 的 local enable 或外部路由再决定哪一个实体响应；三层并不天然等价。MISA 的未使用 local enable、向量/H CSR 常量与合法表之间的差异说明，看到地址参数或恒零读 MUX 项并不代表软件能够合法访问。MCER、MEICR、MWMSR 位于已开放的自定义地址段时可以合法读到 0，而未进入 IUI 合法表的 H/VS 地址仍会触发非法指令。核查一个 CSR 时，应依次确认地址匹配、特权与扩展状态资格、读写路由、实体寄存器和副作用完成条件。

`ct_cp0_regs.v` 还充当全核 CSR 路由器，按地址段把 PMP、MMU、HPCP 和 L2 的读写请求送往外部单元，再把返回数据并入统一读 MUX。S 级的 sstatus、sie、sip 是 M 级底层状态的受限视图，写 sie/sip 时还要经过委派可访问掩码，因而不是与 M 状态无关的第二套寄存器。MCOR 等维护位在写入后保持请求，收到下游 done 才自清，并通过 `regs_iui_cfr_no_op` 阻止对应指令提前提交；长延时维护因此表现为“配置位保存请求、下游执行、完成握手释放”，而不是 CP0 内部复制一套 cache 状态机。计数器地址则先译成 one-hot，再与分级授权位图相与，实现对 32 个计数器的统一访问检查。陷入动态行为见 [01_cp0_trap.md](./01_cp0_trap.md)。
