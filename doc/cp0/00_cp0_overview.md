# C910 CP0 总览 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/cp0/rtl/ct_cp0_top.v`（1072 行）及其例化的
> `ct_cp0_regs.v`（4394 行）、`ct_cp0_iui.v`（1656 行）、`ct_cp0_lpmd.v`（232 行）

---

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 CP0 是什么](#11-cp0-是什么)
  - [1.2 CP0 在全核中的位置](#12-cp0-在全核中的位置)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. M/S/U 三级特权模型](#4-msu-三级特权模型)
- [5. 与 RTU 的 trap 握手](#5-与-rtu-的-trap-握手)
- [6. 与 IU/IDU 的 CSR 指令握手](#6-与-iuidu-的-csr-指令握手)
- [7. 整体数据流](#7-整体数据流)
- [8. 子模块分工](#8-子模块分工)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 CP0 是什么

CP0（Coprocessor 0，沿用 MIPS/C-SKY 习惯叫法，在 RISC-V 里就是 **CSR + 特权状态机**）是 C910 里负责"处理器全局状态"的单元。它干四件事：

1. **持有全套 CSR**：标准 RISC-V 的 mstatus/mie/mip/mtvec/mepc/mcause/mtval/medeleg/mideleg…，以及玄铁私有的 mxstatus/mhcr/mcor/mhint/mrvbr/mcer/mcins 等扩展寄存器。寄存器实体几乎全在 `ct_cp0_regs.v`。
2. **执行特权指令**：`CSRRW/S/C[I]`、`MRET`、`SRET`、`WFI`。指令由 IDU 派发到 CP0，由 `ct_cp0_iui.v` 接收、走 4 拍流水、做特权检查，再把写值送进 regs。
3. **承接陷入（trap）**：当 RTU（退休单元）在某条指令退休边界判定有异常或中断时，向 CP0 发 `rtu_cp0_expt_vld`，CP0 在同一拍**原子地**保存 mepc/mcause/mtval、压栈 mstatus、切换特权级——这是 `ct_cp0_regs.v` 的核心。
4. **向全核广播配置**：把 CSR 里的使能位/模式位扇出给 IFU（分支预测器使能、向量基址 vbr）、IDU（浮点/向量状态）、LSU（dcache 使能、预取）、MMU（mprv/mpp/sum/mxr/satp）、PMP 等。

### 1.2 CP0 在全核中的位置

```
                 idu_cp0_rf_*  (派发一条 CSR/MRET/SRET/WFI)
   IDU ───────────────────────────────►┐
                                        │
   RTU ──rtu_cp0_expt_vld(trap)────────►│  ┌───────────── ct_cp0_iui ─────────────┐
       ──rtu_yy_xx_commit0(退休)───────►│  │ 4 态 FSM: IDLE→EX1→EX2→EX3            │
       ◄─cp0_rtu_xx_int_b(中断请求)────┤  │ 特权检查 iui_privilege               │
       ◄─cp0_iu_ex3_*(结果/flush/efpc)─┤  │ 中断打包 → cp0_rtu_xx_vec            │
                                        │  └──────┬─────────────────▲─────────────┘
   BIU ──biu_cp0_m*_int(外部中断)──────►│         │ iui_regs_*      │ regs_iui_*
                                        │  ┌──────▼─────────────────┴─────────────┐
   IFU/LSU/MMU ◄─cp0_xx_*(配置位广播)──┤  │      ct_cp0_regs  (CSR 寄存器堆)      │
                                        │  │  mstatus/mie/mip/mtvec/mepc/mcause… │
                                        │  │  陷入原子写 + 特权两级栈            │
                                        │  └───────────────────────────────────────┘
                                        │  ┌─── ct_cp0_lpmd (WFI 低功耗 3 态机) ──┐
   BIU ◄─cp0_biu_lpmd_b───────────────┤  └───────────────────────────────────────┘
```

顶层 `ct_cp0_top.v` 只做例化与连线：例化 `x_ct_cp0_iui`（行 725）、`x_ct_cp0_regs`（行 817）、`x_ct_cp0_lpmd`（行 1036），三者之间通过 `iui_regs_*`/`regs_iui_*`/`inst_lpmd_ex1_ex2`/`lpmd_cmplt` 等内部线互连（top.v 行 645-718 的 wire 声明）。

---

## 2. 端口说明

CP0 顶层端口极多（`ct_cp0_top.v` 行 16-233 共两百多个），按对端模块分组归纳如下。

### 2.1 指令/退休接口（IDU、RTU）

| 信号 | 方向 | 含义 |
|---|---|---|
| `idu_cp0_rf_func[4:0]` | in | IDU 派发的 CP0 指令类型（WFI/SRET/MRET/CSRR*，编码见 iui.v 行 716-733） |
| `idu_cp0_rf_iid[6:0]` | in | 指令 ID，用于与退休 IID 比对 |
| `idu_cp0_rf_opcode[31:0]` | in | 指令编码（含 CSR 地址 [31:20] 与 uimm[19:15]） |
| `idu_cp0_rf_src0[63:0]` | in | rs1 源操作数 |
| `idu_cp0_rf_sel` | in | 该拍确实派发了一条 CP0 指令 |
| `rtu_yy_xx_commit0` / `_iid` | in | 退休单元当拍退休的指令 IID（CP0 据此确认指令"提交"） |
| `rtu_yy_xx_flush` | in | 全核流水冲刷 |
| `cp0_iu_ex3_*` | out | EX3 拍回送 IU 的结果/异常/flush/efpc（见 §6） |

### 2.2 Trap / 中断接口（RTU、BIU、HPCP）

| 信号 | 方向 | 含义 |
|---|---|---|
| `rtu_cp0_expt_vld` | in | RTU 判定退休边界有 trap（异常或中断），CP0 据此压栈 |
| `rtu_cp0_expt_gateclk_vld` | in | trap 的 gateclk 提前唤醒版本 |
| `rtu_yy_xx_expt_vec[5:0]` | in | trap 原因码，bit[5]=1 表示中断、=0 表示异常，[4:0]=cause |
| `rtu_cp0_epc[63:0]` | in | 陷入点 PC（要写进 mepc/sepc） |
| `rtu_cp0_expt_mtval[63:0]` | in | 陷入辅助值（要写进 mtval/stval） |
| `cp0_rtu_xx_int_b` | out | CP0 向 RTU 请求中断（低有效） |
| `cp0_rtu_xx_vec[4:0]` | out | 中断原因码（送 RTU 触发退休边界陷入） |
| `rtu_cp0_int_ack` | in | RTU 接受中断的应答 |
| `biu_cp0_me/ms/mt_int`、`se/ss/st_int` | in | 外部 M/S 级 外部/软件/定时器中断引脚 |
| `hpcp_cp0_int_vld` | in | 性能计数器溢出中断（moip） |

### 2.3 配置位广播（IFU/IDU/LSU/MMU/PMP）

这一类输出占了端口表的大半，都是 `cp0_<对端>_<功能>`，全部由 `ct_cp0_regs.v` 末尾（行 4102-4278）从内部 CSR 位驱动。代表：`cp0_ifu_bht_en/btb_en/icache_en/vbr/rvbr`、`cp0_idu_frm/fs/vs`、`cp0_lsu_dcache_en/mm/ucme`、`cp0_mmu_mpp/mprv/sum/mxr/satp_sel`、`cp0_yy_priv_mode`。

### 2.4 低功耗 / 时钟

| 信号 | 方向 | 含义 |
|---|---|---|
| `cp0_biu_lpmd_b[1:0]` | out | 向 BIU 报告低功耗模式（lpmd.v 行 217） |
| `cp0_ifu/lsu/mmu_no_op_req` | out | WFI 进入 WAIT 态时请求三大单元停下（lpmd.v 行 177-179） |
| `cp0_yy_clk_en` | out | 全核时钟使能；进入低功耗后拉低（lpmd.v 行 227） |
| `forever_cpuclk` / `cpurst_b` | in | 永远跳动的时钟 / 复位 |

---

## 3. 参数与关键寄存器

CP0 没有 module 级 `parameter`，但在 `ct_cp0_iui.v`（行 386-708）和 `ct_cp0_regs.v`（行 1145 起）都用 `parameter` 定义了**整套 CSR 地址常量**。两份地址表内容一致（regs 端用于读写解码，iui 端用于地址合法性 + 访问权限判定）。完整地址表见 [02_cp0_csr.md](./02_cp0_csr.md)。

陷入核心相关的寄存器实体（均在 `ct_cp0_regs.v`）：

| 寄存器 reg | 行号 | 作用 |
|---|---|---|
| `pm[1:0]` | 2666-2674 | **当前特权级**（00=U,01=S,11=M），复位为 M |
| `mpp[1:0]` / `spp` | 1616-1645 | mstatus 的上一特权级栈 |
| `mpie/spie`、`mie_bit/sie_bit` | 1651-1709 | mstatus 的中断使能两级栈 |
| `mepc_reg[62:0]` | 1983-1993 | 机器陷入返回 PC |
| `m_intr`、`m_vector[4:0]` | 2005-2027 | mcause（中断位 + cause 码） |
| `mtval_data[63:0]` | 2041-2051 | 机器陷入辅助值 |
| `mtvec_base/mode` | 1913-1933 | 机器陷入向量基址与模式 |
| `edeleg[15:0]`、`*_deleg` | 1752-1831 | 异常/中断委派位 |

---

## 4. M/S/U 三级特权模型

**当前特权级**保存在单一寄存器 `pm[1:0]`（`ct_cp0_regs.v` 行 2666-2674），编码：`2'b11`=Machine、`2'b01`=Supervisor、`2'b00`=User。复位值为 `2'b11`（M 模式，行 2669）。它被广播为 `cp0_yy_priv_mode`（行 4094）供全核使用，也送回 iui 做权限判定（`regs_iui_pm`，行 3986）。

`pm` 的下一值由组合逻辑 `pm_wdata` 决定（行 2644-2664），写使能 `pm_wen`（行 2640-2642）只在三种事件下有效：**陷入、MRET、SRET**：

```verilog
// ct_cp0_regs.v 行 2653-2660
if(rtu_cp0_expt_vld && !mdeleg_vld)   pm_wdata = 2'b11;        // 陷入未委派 → 进 M
else if(rtu_cp0_expt_vld && mdeleg_vld) pm_wdata = 2'b01;      // 陷入委派给 S → 进 S
else if(iui_regs_inst_mret)            pm_wdata = mpp[1:0];    // MRET → 回到 mpp
else if(iui_regs_inst_sret)            pm_wdata = {1'b0, sstatus_spp}; // SRET → 回到 spp
```

C910 **不实现 Hypervisor**：`misa_hypervisor`/`cp0_yy_hyper`/`v`/`cp0_yy_virtual_mode` 全部硬编码为 0（regs.v 行 1735、2766、4095-4096），iui 的 `iui_hs_inv` 也恒 0（iui.v 行 1320）。文档中出现的 H/VS 痕迹是为兼容而保留的死代码。

特权级如何约束 CSR 访问，见 [03_cp0_lpmd_iui.md](./03_cp0_lpmd_iui.md) 的 `iui_s_inv`/`iui_u_inv`/`iui_privilege` 一节。

---

## 5. 与 RTU 的 trap 握手

CP0 的陷入是**被动的**：它不判断"该不该陷入"，那是 RTU 在退休边界做的。CP0 只负责"陷入发生时把现场原子地存好、把特权级切好"。

### 5.1 异常方向（RTU → CP0）

RTU 在某条退休指令上发现异常（或决定接受一个中断）时：

1. 拉高 `rtu_cp0_expt_vld`（regs.v 各陷入 always 块的触发条件）。
2. 给出 `rtu_yy_xx_expt_vec[5:0]`：bit5 区分中断/异常，bit[4:0] 是 cause。
3. 给出 `rtu_cp0_epc`（陷入点 PC）、`rtu_cp0_expt_mtval`（辅助值）。

CP0 在**同一拍**完成 mepc←epc、mcause←vec、mtval←mtval、mstatus 压栈、pm 切换。这套原子写的细节是 [01_cp0_trap.md](./01_cp0_trap.md) 的全部内容。

### 5.2 中断方向（CP0 → RTU）

中断源（外部 `biu_cp0_*_int`、性能计数器 `hpcp_cp0_int_vld`、软件置位的 `*ip_reg`）在 CP0 内被 `mie`、特权级、`mideleg` 过滤后，打包成 `int_sel[14:0]`（regs.v 行 2187-2193），送进 iui，由 iui 编码出唯一中断向量 `cp0_rtu_xx_vec` 并拉低 `cp0_rtu_xx_int_b`（iui.v 行 1592-1626）请求 RTU。**RTU 只在退休边界才接受**这个请求——这就是"中断只在退休边界被接受"的硬件实现：CP0 把请求挂着，RTU 选时机回 `rtu_cp0_expt_vld`，闭环。

---

## 6. 与 IU/IDU 的 CSR 指令握手

一条 CSR/MRET/SRET/WFI 的生命周期：

1. **派发**：IDU 拉 `idu_cp0_rf_sel`，给出 func/iid/opcode/src0。iui 在 `idu_cp0_rf_gateclk_sel` 拍把它们锁进 `iui_ex1_*`（iui.v 行 735-782）。
2. **EX1**：iui FSM 进 EX1，从 regs 读出旧值锁进 `cp0_rslt_reg`（iui.v 行 1522-1523），并算出新写值 `iui_regs_src0`（按 CSRRW/S/C 语义，iui.v 行 1436-1448）。
3. **EX2**：等到该 IID 退休（`iui_ex2_commit`，行 1081-1083）才真正写 regs（`iui_regs_sel`，行 1425）；同时做特权检查 `iui_privilege`（行 1374-1380），不合法则置 `iui_regs_inv_expt` 触发非法指令异常。
4. **EX3**：把读出值 `cp0_iu_ex3_rslt_data` 回送 IU 写回（行 1507-1527），并产生 `cp0_iu_ex3_flush`（行 1651，CSR/MRET/SRET 都要冲刷后续）。MRET/SRET 还产生 `cp0_iu_ex3_efpc`（返回地址，regs.v 行 4171-4173）。

详见 [03_cp0_lpmd_iui.md](./03_cp0_lpmd_iui.md)。

---

## 7. 整体数据流

```
 ① CSR 写：IDU →[iui FSM EX1/EX2]→ iui_regs_sel/addr/src0 →[regs xx_local_en]→ CSR reg
 ② CSR 读：iui_regs_addr →[regs data_out 大 mux 行3900]→ regs_iui_data_out → cp0_rslt_reg → IU
 ③ 陷入：RTU rtu_cp0_expt_vld →[regs 原子写 mepc/mcause/mtval + 压栈 mstatus + pm]→ (efpc 由 IFU 跳向 mtvec)
 ④ 出栈：MRET/SRET →[regs 出栈 mstatus + pm←mpp/spp]→ cp0_iu_ex3_efpc(=mepc/sepc) → IFU
 ⑤ 中断：biu/hpcp int →[regs mie/deleg 过滤 → int_sel]→[iui 编码 vec]→ cp0_rtu_xx_vec → RTU 退休边界接受 → 走 ③
 ⑥ 配置广播：CSR reg →(组合)→ cp0_ifu/idu/lsu/mmu/pmp_* (regs.v 行 4102-4278)
 ⑦ WFI：iui inst_lpmd_ex1_ex2 →[lpmd 3 态机]→ no_op_req/lpmd_b → BIU；中断到来唤醒
```

---

## 8. 子模块分工

| 子模块 | 行数 | 一句话职责 | 详见 |
|---|---|---|---|
| `ct_cp0_regs` | 4394 | CSR 实体 + 陷入原子写 + 特权两级栈 + 配置广播 | [01](./01_cp0_trap.md)、[02](./02_cp0_csr.md) |
| `ct_cp0_iui` | 1656 | 接 IDU 指令、4 态执行、特权检查、中断打包、reset cache inv | [03](./03_cp0_lpmd_iui.md) |
| `ct_cp0_lpmd` | 232 | WFI 低功耗 3 态机 | [03](./03_cp0_lpmd_iui.md) |
| `ct_cp0_top` | 1072 | 例化 + 连线（无逻辑，仅 debug_info 拼接 行 1061-1062） | 本文 |

---

## 设计取舍小结

1. **特权级用单寄存器 `pm[1:0]` 而非分散标志**：所有压栈/出栈/陷入只改一个 2bit 寄存器（行 2666），逻辑集中、易验证；广播给全核也只需一根 `cp0_yy_priv_mode` 线。

2. **陷入"被动 + 原子"**：CP0 不参与异常判定（交给 RTU 在退休边界做），自身只负责在 `rtu_cp0_expt_vld` 一拍内把 mepc/mcause/mtval/mstatus/pm 全部更新。这把"何时陷入"（投机、乱序、精确性）与"如何陷入"（状态机式状态保存）解耦，CP0 内部因此完全是精确、顺序的。

3. **CSR 写延后到退休（EX2 commit）**：iui 的 4 态机在 EX2 等到指令真正退休 `iui_ex2_commit` 才落盘 CSR（行 1140、1425），保证 CSR 不被投机执行污染——CSR 写是不可回滚的全局副作用，必须等指令确定不会被冲掉。

4. **配置位与陷入状态共处一个大文件**：regs.v 把"会被陷入修改的状态"（mstatus 等）和"纯配置位"（mhcr 等）放一起，因为它们都挂在同一套 `iui_regs_sel + addr` 写解码与同一个 `data_out` 读 mux 上，集中后接口最简。

5. **H 扩展死代码保留**：`misa_hypervisor`、`v`、`iui_hs_inv` 恒 0 但代码结构保留，便于后续派生核打开 H 扩展时最小改动——这是 IP 工厂（RTL_FACTORY）常见做法。
