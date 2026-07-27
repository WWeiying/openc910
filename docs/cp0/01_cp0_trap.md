# C910 CP0 陷入核心 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/cp0/rtl/ct_cp0_regs.v`（4394 行）
> 本文聚焦 regs.v 中"陷入入口 / 出口"相关逻辑（约行 1495-2200、2640-2674、4134-4173）。
> CSR 的完整地址表与配置位见 [02_cp0_csr.md](./02_cp0_csr.md)，指令如何进入见 [03_cp0_lpmd_iui.md](./03_cp0_lpmd_iui.md)。

---

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 什么是"陷入核心"](#11-什么是陷入核心)
  - [1.2 两条触发线：陷入与出栈](#12-两条触发线陷入与出栈)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. mstatus：两级特权栈与中断使能栈](#4-mstatus两级特权栈与中断使能栈)
- [5. 陷入时的原子写：mepc / mcause / mtval](#5-陷入时的原子写mepc--mcause--mtval)
- [6. 特权级切换 pm 与委派 medeleg/mideleg](#6-特权级切换-pm-与委派-medelegmideleg)
- [7. mtvec / stvec：Direct vs Vectored 与 vbr 输出](#7-mtvec--stvec-direct-vs-vectored-与-vbr-输出)
- [8. mret / sret 出栈与返回地址 efpc](#8-mret--sret-出栈与返回地址-efpc)
- [9. 中断：mie/mip 过滤、委派仲裁、退休边界接受](#9-中断miemip-过滤委派仲裁退休边界接受)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 什么是"陷入核心"

RISC-V 的陷入（trap，统称异常 exception 与中断 interrupt）要求硬件在进入异常处理程序前**原子地**完成一组状态保存：

- `mepc ← 陷入点 PC`
- `mcause ← 原因码`（区分中断/异常）
- `mtval ← 辅助值`（出错地址/非法指令编码等）
- `mstatus`：把当前中断使能 `mie` 压进 `mpie`、把当前特权级压进 `mpp`、清 `mie`
- `pm ← M（或委派后 S）`

退出时 `MRET`/`SRET` 做逆操作。整个过程在 `ct_cp0_regs.v` 用一组并列的 `always` 块实现，**它们共享同一个触发条件 `rtu_cp0_expt_vld`/`mdeleg_vld`，因此天然在同一拍同步发生，即"原子"**。这正是本文要逐块拆解的内容。

### 1.2 两条触发线：陷入与出栈

陷入核心的所有寄存器都监听这几个触发源：

| 触发 | 信号 | 含义 |
|---|---|---|
| 陷入（去 M） | `rtu_cp0_expt_vld && !mdeleg_vld` | RTU 报 trap 且未委派给 S |
| 陷入（去 S） | `rtu_cp0_expt_vld && mdeleg_vld` | RTU 报 trap 且委派给 S |
| 出栈（M） | `iui_regs_inst_mret` | 执行 MRET |
| 出栈（S） | `iui_regs_inst_sret` | 执行 SRET |
| 软件写 | `<csr>_local_en` | CSRRW/S/C 显式写该 CSR |

注意陷入相关寄存器多用 `regs_flush_clk` 时钟域（行 1092-1115 的门控），因为陷入/flush/mret/sret 是同一类"流水冲刷"事件。

---

## 2. 端口说明

本文涉及的 regs.v 端口（按来源分组）：

### 2.1 来自 RTU 的陷入输入

| 信号 | 位宽 | 行号 | 含义 |
|---|---|---|---|
| `rtu_cp0_expt_vld` | 1 | 286/702 | trap 有效（异常或中断被接受） |
| `rtu_yy_xx_expt_vec[5:0]` | 6 | 301/717 | bit5=中断/异常，[4:0]=cause |
| `rtu_cp0_epc[63:0]` | 64 | 283/699 | 陷入点 PC → mepc/sepc |
| `rtu_cp0_expt_mtval[63:0]` | 64 | 285/701 | 辅助值 → mtval/stval |
| `rtu_cp0_int_ack` | 1 | 288 | RTU 接受中断的应答 |
| `rtu_yy_xx_flush` | 1 | 302 | 全核冲刷 |

### 2.2 来自 IUI 的写/出栈输入

| 信号 | 行号 | 含义 |
|---|---|---|
| `iui_regs_sel` | — | 一次合法 CSR 写选通（EX2 commit） |
| `iui_regs_addr[11:0]` | — | 被写 CSR 地址 |
| `iui_regs_src0[63:0]` | — | 写入数据（已按 CSRRW/S/C 算好） |
| `iui_regs_inst_mret/sret` | 268/269 | MRET/SRET 出栈触发 |
| `iui_regs_inv_expt` | — | CP0 自己检出的非法指令异常 |
| `iui_regs_csrw` | — | 是 CSRRW（用于 MIP 写语义） |
| `iui_regs_ori_src0[63:0]` | — | 写前原始 rs1/uimm（MIP 写语义） |

### 2.3 陷入/特权相关输出

| 信号 | 行号 | 含义 |
|---|---|---|
| `cp0_yy_priv_mode[1:0]` | 4094 | 当前特权级 pm |
| `cp0_ifu_vbr[39:0]` | 4134 | 当前特权级的陷入向量基址（M 用 mtvec，S 用 stvec） |
| `cp0_ifu_rvbr[39:0]` | 4137 | 复位向量基址（mrvbr） |
| `cp0_iu_ex3_efpc[38:0]` | 4171 | MRET/SRET 返回地址 |
| `cp0_iu_ex3_efpc_vld` | 4173 | efpc 有效 |
| `cp0_pad_mstatus[63:0]` | 4388 | mstatus 全值（送 pad 调试观测） |
| `regs_iui_int_sel[14:0]` | 4005 | 已过滤的中断请求位图（送 iui 编码） |

---

## 3. 参数与关键寄存器

陷入核心的状态寄存器一览（全部 `ct_cp0_regs.v`）：

| reg | 行号 | 复位值 | 语义 |
|---|---|---|---|
| `pm[1:0]` | 2666 | `2'b11`(M) | 当前特权级 |
| `mpp[1:0]` | 1616 | `2'b11` | 陷入前 M 视角的上一特权级 |
| `spp` | 1631 | `1'b1` | 陷入前 S 视角的上一特权级（0=U,1=S） |
| `mpie` | 1651 | 0 | 陷入前的 mie 备份 |
| `spie` | 1665 | 0 | 陷入前的 sie 备份 |
| `mie_bit` | 1681 | 0 | M 全局中断使能 |
| `sie_bit` | 1695 | 0 | S 全局中断使能 |
| `tsr/tw/tvm/mprv` | 1542 | 0 | mstatus 陷阱/虚拟化控制位 |
| `mxr/sum` | 1567 | 0 | 访存权限控制位（M 与 S 都可写） |
| `fs[1:0]` | 1602 | 0 | 浮点单元脏状态 |
| `mepc_reg[62:0]` | 1983 | 0 | 机器返回 PC（bit0 恒 0） |
| `m_intr`,`m_vector[4:0]` | 2005/2017 | 0 | mcause |
| `mtval_data[63:0]` | 2041 | 0 | 机器陷入辅助值 |
| `mtvec_base[61:0]`,`mtvec_mode[1:0]` | 1923/1913 | 0 | 机器向量 |
| `stvec_base/mode` | 2253/2240 | 0 | 监管向量 |
| `edeleg[15:0]` | 1752 | 0 | 异常委派位 |
| `moie/seie/stie/ssie_deleg` | 1808 | 0 | 中断委派位 |

---

## 4. mstatus：两级特权栈与中断使能栈

`mstatus` 是陷入核心最复杂的寄存器。它的字段布局在注释里画得很清楚（regs.v 行 1501-1510）。每个字段是独立的小 `always` 块，下面挑陷入相关的讲。

### 4.1 中断使能两级栈：mie_bit / mpie（M）

```verilog
// ct_cp0_regs.v 行 1681-1693  （M 全局中断使能）
if(rtu_cp0_expt_vld && !mdeleg_vld) mie_bit <= 1'b0;     // 陷入：关中断
else if(iui_regs_inst_mret)         mie_bit <= mpie;      // MRET：从 mpie 恢复
else if(mstatus_local_en)           mie_bit <= iui_regs_src0[3];
```
```verilog
// 行 1651-1662  （mie 的备份位 mpie）
if(rtu_cp0_expt_vld && !mdeleg_vld) mpie <= mie_bit;     // 陷入：把旧 mie 压入 mpie
else if(iui_regs_inst_mret)         mpie <= 1'b1;         // MRET：mpie 置 1（spec 规定）
else if(mstatus_local_en)           mpie <= iui_regs_src0[7];
```

**这就是经典的"硬件中断使能栈，深度 1"**：
- 陷入瞬间：`mpie ← mie`（保存），`mie ← 0`（进入处理程序时默认关中断）。
- MRET 瞬间：`mie ← mpie`（恢复），`mpie ← 1`（spec 要求，表示返回后那一层默认允许再陷入）。

S 级用 `sie_bit`/`spie`（行 1695-1709、1665-1679），结构完全对称，触发条件改成 `mdeleg_vld`（委派给 S 时）和 `iui_regs_inst_sret`。

**为什么要硬件栈？** trap 处理程序入口必须保证"原中断使能被保存且当前关中断"，否则刚进 handler 又被中断会丢现场。用硬件单层栈而非软件保存，是因为它必须与 mepc/pm 在同一拍原子完成。

### 4.2 特权级两级栈：mpp / spp

```verilog
// 行 1616-1627  （mpp：陷入前特权级）
if(rtu_cp0_expt_vld && !mdeleg_vld) mpp[1:0] <= pm[1:0];  // 陷入：压入当前特权级
else if(iui_regs_inst_mret)         mpp[1:0] <= 2'b00;     // MRET：清成 U（spec least-privilege）
else if(mstatus_local_en)           mpp[1:0] <= iui_regs_src0[12:11];
```
```verilog
// 行 1631-1644  （spp：S 级单 bit，0=U,1=S）
if(rtu_cp0_expt_vld && mdeleg_vld)  spp <= pm[0];          // 委派陷入：压入当前级低位
else if(iui_regs_inst_sret)         spp <= 1'b0;           // SRET：清成 U
```

陷入压入"现在是谁"，返回时 `pm` 从 `mpp`/`spp` 弹回（见 §6），同时 `mpp`/`spp` 被清成最低权限——这是 RISC-V 的"返回后把栈位降级"安全规则，防止 handler 残留高权限。

### 4.3 mstatus 拼装与只读字段

```verilog
// 行 1712-1715
assign mstatus_value = {sd, 23'b0, mpv, 3'b0, sxl, uxl, 7'b0, vs,
                        tsr, tw, tvm, mxr, sum, mprv,
                        xs, fs, mpp, 2'b0, spp,
                        mpie, 1'b0, spie, 1'b0, mie_bit, 1'b0, sie_bit, 1'b0};
```

只读派生字段：`sd`（任一 xs/fs/vs 为脏即 1，行 1511）、`sxl/uxl`（=`mxl`=2，即 RV64，行 1515-1517、1728）、`mpv`/`vs`/`xs` 恒 0（行 1513、1540、1591，因 C910 无 H、向量状态走另路、无附加扩展状态）。

`fs`/`vs` 还有"脏更新"通路（行 1593-1614）：当浮点/向量寄存器被写（`rtu_cp0_fp_dirty_vld` 等）时自动从 01/10 跳到 11(Dirty)，无需软件干预。

---

## 5. 陷入时的原子写：mepc / mcause / mtval

### 5.1 mepc — 返回 PC

```verilog
// 行 1983-1993
if(rtu_cp0_expt_vld && !mdeleg_vld) mepc_reg[62:0] <= rtu_cp0_epc[63:1]; // 陷入存 PC
else if(mepc_local_en)              mepc_reg[62:0] <= iui_regs_src0[63:1];
assign mepc_value = {mepc_reg[62:0], 1'b0};   // bit0 恒 0，PC 至少 2 字节对齐
```

`sepc` 同理（行 2308-2327），触发条件换成 `mdeleg_vld`。bit0 不存储，保证读出永远偶地址（RVC 下 2 字节对齐）。

### 5.2 mcause — 原因码

`mcause` 拆成中断位 `m_intr` 与 cause 码 `m_vector[4:0]`，分别取 RTU 给的 `rtu_yy_xx_expt_vec[5]` 和 `[4:0]`：

```verilog
// 行 2005-2027
if(rtu_cp0_expt_vld && !mdeleg_vld) m_intr     <= rtu_yy_xx_expt_vec[5];   // bit5=中断标志
...
if(rtu_cp0_expt_vld && !mdeleg_vld) m_vector   <= rtu_yy_xx_expt_vec[4:0];
assign mcause_value = {m_intr, 58'b0, m_vector[4:0]};   // 行 2029，MSB=Interrupt
```

`scause` 对称（行 2330-2361）。**原因码的语义**：异常时 `m_vector` 是异常号（如 2=非法指令，CP0 自己产生的非法指令异常 cause 由 iui 给出 `cp0_iu_ex3_expt_vec=5'h2`，iui.v 行 1568）；中断时是中断号（见 §9 的编码表）。

### 5.3 mtval — 辅助值

```verilog
// 行 2039-2051
assign mtval_upd_data = rtu_cp0_expt_vld ? rtu_cp0_expt_mtval[63:0]
                                         : {32'b0, iui_regs_opcode[31:0]};
...
if((rtu_cp0_expt_vld || iui_regs_inv_expt) && !mdeleg_vld)
    mtval_data <= mtval_upd_data;     // 普通 trap 用 RTU 给的值；CP0 自检非法指令用指令编码
```

注意第二输入 `iui_regs_inv_expt`：当 CP0 自己在 iui 里检出"特权不足/非法 CSR"时（[03 文档](./03_cp0_lpmd_iui.md) §5），用**指令编码**当 mtval（行 2040），符合非法指令异常应填指令本身的约定。`stval` 同理（行 2364-2386）。

### 5.4 三者为何"原子"

mepc/mcause/mtval/mstatus 各字段/pm 都是**独立的 always 块**，但**全部以 `rtu_cp0_expt_vld`（+ `mdeleg_vld`）为唯一陷入触发**，且都在同一时钟沿（`regs_flush_clk`）更新。因此从软件视角，进 handler 后看到的这五者必然来自同一个陷入事件——这就是硬件层面的"原子陷入"，不需要任何 handshake/排序。

---

## 6. 特权级切换 pm 与委派 medeleg/mideleg

### 6.1 pm 的四选一更新

`pm` 的下一值（regs.v 行 2644-2664）已在 [00 概览 §4](./00_cp0_overview.md#4-msu-三级特权模型) 引用，核心：陷入未委派→M(11)，陷入委派→S(01)，MRET→mpp，SRET→{0,spp}。写使能 `pm_wen = expt_vld || mret || sret`（行 2640）。

### 6.2 委派如何决定去 M 还是 S：mdeleg_vld

`mdeleg_vld = medeleg_vld || mideleg_vld`（行 1842），它是贯穿整个陷入核心的"分流开关"：为 1 时所有陷入写打到 S 套寄存器（sepc/scause/spp/spie/sie_bit），为 0 时打到 M 套。

**异常委派**（行 1789-1791）：
```verilog
assign medeleg_vld = (pm[1] == 1'b0)            // 仅当陷入前不在 M 模式（U 或 S）
                  && !rtu_yy_xx_expt_vec[5]      // 是异常（非中断）
                  && |(vec_num[15:0] & edeleg[15:0]);  // 该异常号在 medeleg 里置位
```

这里 `vec_num` 是把 5bit cause 译成 one-hot 位图（行 1765-1787），再与 `edeleg` 按位与——即"软件在 medeleg 里点亮了哪些异常号，且当前不在 M 模式"，该异常就委派给 S 处理。`pm[1]==0` 这个条件实现了 spec 的"M 模式发生的陷入永远在 M 处理，不下放"。

**中断委派**（行 1838-1840）：结构相同，换成 `rtu_yy_xx_expt_vec[5]==1` 且与 `mideleg_value[18:0]` 按位与。

`medeleg` 写入时只保留合法位（行 1748-1750 的 `edeleg_upd_val` 把 bit10/11/14 等保留位强制清 0）。`mideleg` 各委派位见行 1808-1831（moie/seie/stie/ssie 可写，mhie/mcie 恒 0）。

---

## 7. mtvec / stvec：Direct vs Vectored 与 vbr 输出

### 7.1 寄存器存储

```verilog
// 行 1913-1933
mtvec_mode[1:0] <= iui_regs_src0[1:0];   // 低 2 位是 MODE
mtvec_base[61:0] <= iui_regs_src0[63:2]; // 高位是 BASE
assign mtvec_value = {mtvec_base[61:0], 1'b0, mtvec_mode[0]};  // 只回读 mode bit0
```

注意 `mtvec_value` 拼装时把 bit1 强制成 0、只保留 `mode[0]`：即 C910 只支持 **MODE=0(Direct)** 与 **MODE=1(Vectored)** 两种，MODE>=2 的编码被读为 0（行 1933）。`stvec` 完全对称（行 2240-2260）。

### 7.2 Direct vs Vectored 的实现在哪？

值得注意：**CP0 本身不计算"基址 + 4×cause"**。CP0 只把基址与 mode 打包成 `cp0_ifu_vbr` 送给 IFU：

```verilog
// 行 4134-4135
assign cp0_ifu_vbr[39:0] = pm[1:0]==2'b11 ? {mtvec_base[37:0],1'b0,mtvec_mode[0]}
                                          : {stvec_base[37:0],1'b0,stvec_mode[0]};
```

即：陷入发生时按**陷入后的目标特权级**（M 用 mtvec、否则 stvec）选基址，连同 mode[0] 一起给 IFU。真正的"Vectored 模式下 PC = base + 4×cause"的偏移加法由 IFU 在取指时完成（IFU 用 vbr + RTU 给的 vec）。CP0 这样设计是为了把陷入向量计算放到取指通路，缩短 CP0 关键路径。

### 7.3 复位向量 rvbr

`mrvbr` 记录复位入口：上电时由 IFU 的首次 inv 请求 `ifu_cp0_rst_inv_req` 采样 `biu_cp0_rvba`（行 3046-3064），只读，经 `cp0_ifu_rvbr` 给 IFU（行 4137）。这是核出复位后第一条指令地址的来源。

---

## 8. mret / sret 出栈与返回地址 efpc

### 8.1 出栈动作汇总

| 寄存器 | MRET 动作 | 行号 | SRET 动作 | 行号 |
|---|---|---|---|---|
| `pm` | ← mpp | 2658 | ← {0,spp} | 2660 |
| `mie_bit`/`sie_bit` | ← mpie | 1688 | ← spie | 1702 |
| `mpie`/`spie` | ← 1 | 1658 | ← 1 | 1672 |
| `mpp`/`spp` | ← U(00) | 1623 | ← U(0) | 1638 |

四件事同样并列、同拍发生，是 §5 原子陷入的逆操作。

### 8.2 返回地址 efpc

```verilog
// 行 4171-4173
assign cp0_iu_ex3_efpc[38:0] = cp0_mret ? mepc_value[39:1] : sepc_value[39:1];
assign cp0_iu_ex3_efpc_vld   = cp0_mret || cp0_sret;
```

MRET 返回到 mepc、SRET 返回到 sepc，作为 `cp0_iu_ex3_efpc` 送回 IU（IU 据此重定向取指）。`cp0_mret`/`cp0_sret` 信号来自 iui（top.v 行 746/749 把 iui 的 `cp0_mret` 连过来，但 efpc 选择用的是 regs 内部根据 iui_regs_inst_mret/sret 派生的同名信号）。`efpc_vld` 告诉 IU"这是一次返回跳转"。

`MRET`/`SRET` 本身还会触发 `cp0_iu_ex3_flush`（iui.v 行 1651），冲掉错误路径上预取的指令——因为返回目标在执行前不可知。

---

## 9. 中断：mie/mip 过滤、委派仲裁、退休边界接受

### 9.1 中断源 → mip

`mip` 各 pending 位的来源（行 2108-2117）：
```verilog
assign meip = biu_cp0_me_int;        // 外部中断引脚
assign mtip = biu_cp0_mt_int;
assign msip = biu_cp0_ms_int;
assign moip = hpcp_cp0_int_vld;      // 性能计数器溢出
assign mcip = ecc_int_vld;           // ECC（C910 恒 0，行 2110/3203）
assign seip = biu_cp0_se_int || seip_reg;  // 引脚 OR 软件置位
```
S 级 pending 位（seip/stip/ssip）可由软件经 MIP/SIP 写 `*ip_reg`（行 2080-2106）；写语义特殊（行 2063-2068）：只有 CSRRW 或写值对应位为 1 时才真正改，模拟 MIP 的 W1-style 行为。

### 9.2 三级使能 + 特权 + 委派过滤

每个中断要变成"有效请求"，需穿过三道闸：

1. **局部使能**：`xip_en = xie && xip`（行 2124-2133），即 mie 寄存器对应位开。
2. **特权级闸**：M 级中断只在"当前 M 且 mie_bit 开，或当前更低权"时有效（行 2157-2159）；S 级中断的 nodeleg/deleg 两套条件见行 2165-2185。核心思想：**更高特权级的中断总能打断更低特权级；同级中断需该级全局使能**。
3. **委派分流**：每个源拆成 `xip_nodeleg_vld`（去 M）与 `xip_deleg_vld`（去 S）两条，由 `mideleg_value[*]` 决定走哪条（行 2136-2185）。

最终打包成 15 位 one-hot 候选 `int_sel[14:0]`（行 2187-2193），经 `regs_iui_int_sel` 送 iui。

### 9.3 iui 编码唯一向量并请求 RTU

iui 收到 `regs_iui_int_sel` 后用优先级 casez 编码出**唯一**中断号（iui.v 行 1592-1611，含优先级：mcip>mhip>meip>msip>mtip>seip>… 顺序），锁存为 `iui_int_vec`，并拉低 `cp0_rtu_xx_int_b`（iui.v 行 1625）请求 RTU。

### 9.4 "中断只在退休边界接受"

关键点：**CP0 只是"请求"，真正何时陷入由 RTU 在退休边界决定**。RTU 拿到 `cp0_rtu_xx_int_b`+`cp0_rtu_xx_vec` 后，会等到一条指令的退休边界（保证精确中断），才回送 `rtu_cp0_expt_vld`（bit5=1 表示中断）+ `rtu_yy_xx_expt_vec`，触发 §5 的原子陷入。也就是说，中断和异常**共用同一条陷入回路**，区别只在 `rtu_yy_xx_expt_vec[5]`。这保证了：

- 中断绝不会在指令中途打断（精确性）；
- 投机/乱序执行不会让中断提前生效（CP0 的状态写都挂在退休触发上）。

`cp0_hpcp_int_disable`（行 2195-2196）则在当前特权级关中断时反向通知 HPCP 别再报溢出中断，省功耗。

---

## 设计取舍小结

1. **"一字段一 always、共享触发"实现原子陷入**：mepc/mcause/mtval/mstatus 各位/pm 写成几十个独立小块，但都监听同一组 `rtu_cp0_expt_vld + mdeleg_vld` 条件，同一时钟沿落盘。这比写一个巨型 always 更易读、综合更友好，且天然原子——无需任何内部握手。

2. **委派用单一 `mdeleg_vld` 做全局分流**：把"去 M 还是去 S"压缩成一个布尔（行 1842），所有陷入寄存器据它二选一。代价是 M/S 两套寄存器逻辑几乎重复，但换来分流点单一、易验证不会"半边写 M 半边写 S"。

3. **向量偏移计算下放给 IFU**：CP0 只输出 `cp0_ifu_vbr`(base+mode)（行 4134），不算 `base+4×cause`。把加法放到 IFU 取指通路，避免在 CP0 陷入关键路径上插加法器。

4. **中断"请求/接受"分离**：CP0 负责按 mie/特权/委派过滤并编码出唯一向量，RTU 负责选退休边界接受。职责切分让 CP0 完全组合式地算请求、RTU 独占精确性时机——这是乱序核实现精确中断的标准范式。

5. **特权栈深度恰为 1**：硬件只存一层 mpp/mpie（spp/spie），多层嵌套靠软件在 handler 里再保存。深度 1 覆盖了"陷入即关中断"的最常见场景，硬件成本最低；嵌套陷入的额外保存交给软件，符合 RISC-V 的最小硬件原则。

6. **mtval 双源（RTU 值 / 指令编码）**：普通 trap 用 RTU 的 mtval，CP0 自检的非法 CSR 异常用指令编码（行 2039-2040）。一个寄存器复用两条来源，省掉单独的非法指令记录寄存器。

---

*文档覆盖 ct_cp0_regs.v 全部 4394 行逻辑中与陷入入口/出口/特权/中断相关的部分；CSR 配置位与读写解码见 [02_cp0_csr.md](./02_cp0_csr.md)。*
