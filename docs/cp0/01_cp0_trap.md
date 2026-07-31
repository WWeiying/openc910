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
- [4. mstatus：当前值与一层历史值](#4-mstatus当前值与一层历史值)
- [5. 陷入时的原子写：mepc / mcause / mtval](#5-陷入时的原子写mepc--mcause--mtval)
- [6. 特权级切换 pm 与委派 medeleg/mideleg](#6-特权级切换-pm-与委派-medelegmideleg)
- [7. mtvec / stvec：Direct vs Vectored 与 vbr 输出](#7-mtvec--stvecdirect-vs-vectored-与-vbr-输出)
- [8. mret / sret 出栈与返回地址 efpc](#8-mret--sret-出栈与返回地址-efpc)
- [9. 中断：mie/mip 过滤、委派仲裁、退休边界接受](#9-中断miemip-过滤委派仲裁退休边界接受)
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 什么是"陷入核心"

RISC-V 的陷入（trap，统称同步异常 exception 与异步中断 interrupt）要求软件开始执行处理程序时看到一组彼此一致的架构状态：

- `mepc ← 陷入点 PC`
- `mcause ← 原因码`（区分中断/异常）
- `mtval ← 辅助值`（出错地址/非法指令编码等）
- `mstatus`：把当前中断使能 `mie` 压进 `mpie`、把当前特权级压进 `mpp`、清 `mie`
- `pm ← M（或委派后 S）`

退出时 `MRET`/`SRET` 恢复其中的返回状态。整个过程在 `ct_cp0_regs.v` 中由一组并列时序块实现：实际 RTU trap 路径共享 `rtu_cp0_expt_vld`，并用同一个 `mdeleg_vld` 决定写 M 套还是 S 套寄存器。它们在同一个 `regs_flush_clk` 有效沿更新，因此对后续软件可见为同一次陷入状态转换。

“原子”在这里不表示一个组合块一次性写完，也不表示从异常检测到 handler 第一条指令只需要一拍；它只描述架构状态不会先让软件看见新 `mepc`、下一拍才看见新 `mcause`。

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
| `rtu_cp0_int_ack` | 1 | 288 | 名义上的中断接受应答；当前 regs 仅声明该输入，没有在功能逻辑中使用 |
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
| `cp0_iu_ex3_efpc[38:0]` | 4171 | MRET/SRET 返回地址 `[39:1]`；IU 使用时最低位隐含为 0 |
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

## 4. mstatus：当前值与一层历史值

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

这是一层历史保存，而不是可任意压入多项的通用堆栈：
- 陷入瞬间：`mpie ← mie`（保存），`mie ← 0`（进入处理程序时默认关中断）。
- MRET 瞬间：`mie ← mpie`（恢复），`mpie ← 1`（spec 要求，表示返回后那一层默认允许再陷入）。

S 级用 `sie_bit`/`spie`（行 1695-1709、1665-1679），结构完全对称，触发条件改成 `mdeleg_vld`（委派给 S 时）和 `iui_regs_inst_sret`。

**为什么要硬件保存这一层？** trap 入口必须同步保存原全局使能并关闭目标特权级的全局使能。否则软件在执行第一条 handler 指令前就没有可靠的旧值可恢复。若要支持更深的可重入嵌套，handler 仍需先把这些 CSR 状态保存到软件栈，再有选择地重新开中断。

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

`fs` 有实际可见的脏更新通路：当其当前值为 Initial/Clean 且浮点相关状态被修改时，可更新到 Dirty。向量部分要更谨慎：

- `vs_raw` 确实存在写入和 dirty 更新时序块；
- 但当前 RTL 随后用 `assign vs[1:0] = 2'b0` 把软件可见 `mstatus.VS` 固定为 Off；
- `regs_iui_vs_off` 也因此恒为真。

所以不能仅凭 `vs_raw` 时序块宣称当前配置完整实现标准 `mstatus.VS` 状态机。向量数据通路的存在与标准 V 扩展 CSR 可见状态是否启用是两个不同问题。

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

第二个写入来源是 `iui_regs_inv_expt`。当 IUI 在 EX2 检出非法 CP0 指令时，`mtval_upd_data` 在没有 `rtu_cp0_expt_vld` 的分支选择零扩展的 32 位指令编码。

这里存在时序边界：`iui_regs_inv_expt` 是 IUI 的前置非法检测，真正的架构陷入仍需 IU/RTU 后续形成 `rtu_cp0_expt_vld`。而 `mdeleg_vld` 是根据 RTU 当前 trap vector 计算的，不是根据 IUI 的 `cp0_iu_ex3_expt_vec` 直接计算。因此，不能简单写成“IUI 一发现非法指令，就已经准确选择 mtval 或 stval 完成最终陷入”；最终 M/S trap 状态仍应以 RTU 接受事件为准。

### 5.4 三者为何"原子"

mepc/mcause/mstatus/pm 等是独立时序块；在实际 RTU trap 路径上，它们都由 `rtu_cp0_expt_vld` 和 `mdeleg_vld` 选择，并在 `regs_flush_clk` 的同一个有效沿更新。`mtval/stval` 还多一个 IUI 非法检测写入来源，但 RTU trap 路径仍优先选择 `rtu_cp0_expt_mtval`。

这里不能说“不需要任何 handshake”：RTU 到 CP0 的 `rtu_cp0_expt_vld + payload` 本身就是已经选定的有效事件接口。准确说法是，CP0 regs 内部不再为 EPC/cause/tval 分别进行多次握手。

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

写入时 `mtvec_mode[1:0]` 会保存源数据低两位，但读回值和送 IFU 的值都把 bit1 强制为 0，只使用 `mtvec_mode[0]`。因此软件可见效果是：

| 写入 MODE | 保存的内部两位 | 读回 MODE | IFU 使用 |
|---:|---:|---:|---|
| `00` | `00` | `00` | Direct |
| `01` | `01` | `01` | Vectored |
| `10` | `10` | `00` | Direct |
| `11` | `11` | `01` | Vectored |

所以不是笼统的“MODE>=2 都读为 0”，而是 bit1 被屏蔽、bit0 仍然生效。`stvec` 完全对称。标准软件仍应只写受支持编码 0 或 1。

### 7.2 Direct vs Vectored 的实现在哪？

值得注意：**CP0 本身不计算"基址 + 4×cause"**。CP0 只把基址与 mode 打包成 `cp0_ifu_vbr` 送给 IFU：

```verilog
// 行 4134-4135
assign cp0_ifu_vbr[39:0] = pm[1:0]==2'b11 ? {mtvec_base[37:0],1'b0,mtvec_mode[0]}
                                          : {stvec_base[37:0],1'b0,stvec_mode[0]};
```

`cp0_ifu_vbr` 根据当前 `pm` 选择 M 或 S 向量；RTU trap 被接受的同一个沿会把 `pm` 更新到目标特权级。真正的向量地址计算位于 `ct_ifu_vector.v`：

```text
若 mode[0]=1 且 trap 是中断:
    halfword_PC = VBR_base + (cause << 1)
否则:
    halfword_PC = VBR_base
```

这里 IFU 内部 PC 省略了字节地址 bit0，所以“halfword 表示中的 `cause<<1`”对应完整字节地址的 `4*cause`。异常即使在 Vectored 模式下也仍进入 BASE。把计算放在 IFU 是 RTL 事实；“这样一定缩短 CP0 关键路径”属于合理的微结构解释，但实际时序收益仍需综合时序报告支持。

### 7.3 复位向量 rvbr

`mrvbr` 记录复位入口。实现分两步：

1. `rst_sample` 在 `forever_cpuclk` 上看到 `ifu_cp0_rst_inv_req` 后置 1；
2. `mrvbr_reg` 在后续 `regs_flush_clk` 有效沿看到 `rst_sample` 后采样 `biu_cp0_rvba[39:1]`。

因此不要把它写成请求组合到来时“立即采样”。读回和 `cp0_ifu_rvbr` 都把 bit0 补 0；该值参与 IFU 复位向量流程。

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

MRET 选择 mepc，SRET 选择 sepc，并以省略 bit0 的 `[39:1]` 形式送到 `cp0_iu_ex3_efpc[38:0]`。

有一个容易被端口名掩盖的细节：regs 中的 `cp0_iu_ex3_efpc_vld` 直接等于 IUI 输出的 `cp0_mret || cp0_sret`，而 IUI 的这两个信号由 `cp0_select` 门控。`cp0_select` 在 EX1、匹配 commit 的 EX2、以及已 commit 的 EX3 都可能成立，所以该 valid 不是在 regs 内再次严格限定为单独一个 EX3 周期。真正更新 `pm/mstatus` 的信号则是 `iui_regs_inst_mret/sret`，只在匹配 commit 的 EX2 成立。波形分析必须把“返回目标被广播”与“返回状态已经提交”分开。

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
CP0 内部只保存 `seip_reg/stip_reg/ssip_reg` 三个位：

- 写 MIP 时，M 模式可更新三个位；
- 写 SIP 时，当前代码只在 `ssip_acc_en` 成立时更新 `ssip_reg`，不会通过 SIP 更新 `seip_reg/stip_reg`；
- CSRRW/CSRRWI 对可写位执行直接赋值；
- CSRRS/CSRRC 的原始 source 对应位为 0 时，该位保持不变；为 1 时，IUI 已算好的新值决定置位或清位。

因此它不是简单的“W1C”或“W1S”寄存器，而是为了保持标准 CSRRS/CSRRC 的“source 位为 0 则不写该位”语义所做的逐位写屏蔽。

### 9.2 三级使能 + 特权 + 委派过滤

每个中断要变成"有效请求"，需穿过三道闸：

1. **局部使能**：`xip_en = xie && xip`（行 2124-2133），即 mie 寄存器对应位开。
2. **特权级闸**：`meip/mtip/msip` 使用 `(pm!=M || mie_bit)`，即在较低特权级不看 MIE，在 M 模式看 MIE。S 类源则分别形成委派和非委派条件：非委派去 M 时，在 S/U 模式不看 MIE；委派去 S 时，在 S 模式看 SIE、在 U 模式不看 SIE。
3. **委派分流**：S 类中断和扩展的 `moip` 有 nodeleg/deleg 两套候选。`meip/mtip/msip` 在当前 RTL 中只有直接的 `*_vld` 路径，并没有被 `mideleg` 分流；`mideleg` 可写位也只包括 `moip/seip/stip/ssip`，而 `mhip/mcip` 委派位被硬连为 0。

最终打包成 15 位 one-hot 候选 `int_sel[14:0]`（行 2187-2193），经 `regs_iui_int_sel` 送 iui。

### 9.3 iui 编码唯一向量并请求 RTU

IUI 收到 `regs_iui_int_sel` 后用 `casez` 的从上到下匹配顺序编码一个中断号，随后在 `cpuclk` 沿把 cause 锁存到 `iui_int_vec`，并把“当前是否有候选”锁存为低有效 `iui_int_vld_b`。所以 `int_sel` 组合变化与 `cp0_rtu_xx_int_b/cp0_rtu_xx_vec` 对外变化之间有一个寄存阶段。

固定优先级顺序为：

```text
非委派 mcip > mhip > meip > msip > mtip > seip > ssip > stip > moip
> 委派 mcip > mhip > seip > ssip > stip > moip
```

当前配置下 `mcip`、`mhip` 及其委派项为 0，但编码槽位仍保留。

### 9.4 "中断只在退休边界接受"

关键点：**CP0 产生请求，RTU 决定精确接受条件**。RTU 的 ROB retire 逻辑还会考虑当前提交宽度、调试等约束，再把所选中断转成 `retire_async_expt_vld`，最终形成 `rtu_cp0_expt_vld` 和带 interrupt bit 的 vector。中断和同步异常随后共用 CP0 的 trap 状态更新通路。

- 中断绝不会在指令中途打断（精确性）；
- 投机/乱序执行不会让中断提前生效（CP0 的状态写都挂在退休触发上）。

`cp0_hpcp_int_disable` 在 M 模式且 MIE=0，或 S 模式且 SIE=0 时为 1，并送往
HPCP。沿接收端继续追踪可确认：当前 `ct_hpcp_top` 只把它零扩展为 event36
的每周期增量，用来统计“全局中断关闭状态持续了多少周期”；它没有参与
`hpcp_cp0_int_vld = |(cntinten_value & cntof_int)` 的门控，也不冻结其它事件
计数。因此虽然信号名包含 `int_disable`，它不是“禁止 PMU 溢出中断输出”的
控制线。

---

## 本章小结

CP0 陷入路径首先把中断 pending、enable、当前特权和委派条件压缩成唯一候选及 cause，再由 RTU 在精确退休边界决定是否接受。接受时，单一 `mdeleg_vld` 统一决定写入 M 级还是 S 级陷入状态，各字段虽然由独立时序块更新，却共享同一有效条件和同一分流结果；这保证 EPC、cause、tval、当前 IE/privilege 与 previous 字段在同一个架构事件上成组变化。硬件只保存一层 previous 状态，更深的嵌套上下文仍需软件保存。普通 trap 的 tval 来自 RTU，CP0 自身检测到的非法 CSR 则可选择指令编码作为 mtval 来源，因此必须结合 cause 判断 tval 的语义。

陷入目标 PC 不是在 CP0 内完整计算。CP0 输出压缩表示的 trap base 和 mode，RTU 提供 cause，IFU 的 `ct_ifu_vector` 再在内部省略 PC bit0 的表示下完成等价于字节地址 `base + 4*cause` 的向量偏移，并启动前端重定向。返回指令沿相反方向恢复 previous privilege/IE 并跳回 EPC。由此形成“CP0 判定资格、RTU 保证精确、CP0 更新架构状态、IFU 生成目标地址”的职责链。波形分析时，应先确认候选中断或异常，再确认 RTU 接受，随后检查寄存器更新和 IFU 重定向；只观察其中任一环节都不足以证明一次完整陷入已经完成。CSR 配置位与读写解码见 [02_cp0_csr.md](./02_cp0_csr.md)。
