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
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 CP0 是什么

CP0 是本工程对控制/状态寄存器与特权控制单元的命名。可以用“CSR + 特权状态控制 + CP0 指令接口”帮助理解，但不要把工程名直接当成 RISC-V 规范中的标准模块名。它主要完成四件事：

1. **持有全套 CSR**：标准 RISC-V 的 mstatus/mie/mip/mtvec/mepc/mcause/mtval/medeleg/mideleg…，以及玄铁私有的 mxstatus/mhcr/mcor/mhint/mrvbr/mcer/mcins 等扩展寄存器。寄存器实体几乎全在 `ct_cp0_regs.v`。
2. **执行特权指令**：`CSRRW/S/C[I]`、`MRET`、`SRET`、`WFI`。指令由 IDU 送入 `ct_cp0_iui.v`。IUI 有 `IDLE/EX1/EX2/EX3` 四个状态，但一次无等待操作是在派发后依次占用 EX1、EX2、EX3 三个活动状态，不能把“四状态”机械地写成“固定四拍延迟”。
3. **承接陷入（trap）**：当 RTU 已经选定一个异常或中断并拉高 `rtu_cp0_expt_vld` 时，CP0 在该有效事件对应的 `regs_flush_clk` 时钟沿并行保存 EPC/cause/tval、更新状态栈并切换特权级。这里的“原子”是软件可见状态在同一接受沿更新，不表示异常从最初产生到进入处理程序只花一个周期。
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

顶层 `ct_cp0_top.v` 主要做例化与连线：例化 `x_ct_cp0_iui`、`x_ct_cp0_regs`、`x_ct_cp0_lpmd`，并用 `iui_regs_*`、`regs_iui_*`、`inst_lpmd_ex1_ex2`、`lpmd_cmplt` 等内部线连接三者。顶层自身还有 `cp0_had_debug_info` 的两组状态拼装，因此更准确的说法是“没有新增 CP0 主功能状态机”，而不是绝对的“无逻辑”。

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
| `rtu_cp0_int_ack` | in | 名义上是 RTU 中断接受应答；当前 `ct_cp0_regs.v` 只声明和注释该端口，没有用它更新任何 CP0 状态 |
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

`ct_cp0_iui.v` 和 `ct_cp0_regs.v` 都定义了 CSR 地址 parameter，但两份集合并不严格相同：IUI 为合法性检查和外部路由列出更多 PMP/HPCP/监管计数器等地址，regs 只需定义其本地读写和分类所需部分。即使两边都有同名 parameter，真正的合法性仍由 IUI 的 `addr_inv` case 决定。地址与实现边界见 [02_cp0_csr.md](./02_cp0_csr.md)。

陷入核心相关的寄存器实体（均在 `ct_cp0_regs.v`）：

| 寄存器 reg | 行号 | 作用 |
|---|---|---|
| `pm[1:0]` | 2666-2674 | **当前特权级**（00=U,01=S,11=M），复位为 M |
| `mpp[1:0]` / `spp` | 1616-1645 | mstatus 的上一特权级栈 |
| `mpie/spie`、`mie_bit/sie_bit` | 1651-1709 | mstatus 的中断使能两级栈 |
| `mepc_reg[62:0]` | 1983-1993 | 机器陷入返回地址的架构 `EPC[63:1]`；读取 CSR 时在最低位补 0 |
| `m_intr`、`m_vector[4:0]` | 2005-2027 | mcause（中断位 + cause 码） |
| `mtval_data[63:0]` | 2041-2051 | 机器陷入辅助值 |
| `mtvec_base/mode` | 1913-1933 | 机器陷入向量基址与模式 |
| `edeleg[15:0]`、`*_deleg` | 1752-1831 | 异常/中断委派位 |

---

## 4. M/S/U 三级特权模型

**当前特权级**保存在单一寄存器 `pm[1:0]`（`ct_cp0_regs.v` 行 2666-2674），编码：`2'b11`=Machine、`2'b01`=Supervisor、`2'b00`=User。复位值为 `2'b11`（M 模式，行 2669）。它被广播为 `cp0_yy_priv_mode`（行 4094）供全核使用，也送回 iui 做权限判定（`regs_iui_pm`，行 3986）。

`pm` 的下一值由组合逻辑 `pm_wdata` 决定，写使能 `pm_wen` 只在三类已接受事件下有效：**RTU 陷入有效、提交生效的 MRET、提交生效的 SRET**。IUI 只有在 EX2 看到匹配 IID 的 `commit0` 时才产生 `iui_regs_inst_mret/sret`，所以不能把“译码到 MRET”与“特权级已经返回”混为一谈：

```verilog
// ct_cp0_regs.v 行 2653-2660
if(rtu_cp0_expt_vld && !mdeleg_vld)   pm_wdata = 2'b11;        // 陷入未委派 → 进 M
else if(rtu_cp0_expt_vld && mdeleg_vld) pm_wdata = 2'b01;      // 陷入委派给 S → 进 S
else if(iui_regs_inst_mret)            pm_wdata = mpp[1:0];    // MRET → 回到 mpp
else if(iui_regs_inst_sret)            pm_wdata = {1'b0, sstatus_spp}; // SRET → 回到 spp
```

当前这份 RTL 中 `misa_hypervisor`、`cp0_yy_hyper`、`v`、`cp0_yy_virtual_mode` 均为 0，`iui_hs_inv` 也为 0，因此当前有效配置没有打开 Hypervisor/虚拟化模式。文件中仍保留 H/VS 地址和值为零的通路；只能确认这些通路在当前配置下无功能，至于保留它们是为了兼容、代码生成统一还是未来派生，属于设计意图推测，不应写成 RTL 已证明的事实。

特权级如何约束 CSR 访问，见 [03_cp0_lpmd_iui.md](./03_cp0_lpmd_iui.md) 的 `iui_s_inv`/`iui_u_inv`/`iui_privilege` 一节。

---

## 5. 与 RTU 的 trap 握手

对同步异常的最终接受而言，CP0 regs 是**被动更新端**：RTU 提供 `rtu_cp0_expt_vld`、EPC、cause 和 tval，regs 根据委派结果更新 M 或 S 状态。另一方面，中断 pending、局部使能、全局使能和委派候选是在 CP0 内部形成的，再由 IUI向 RTU发请求。因此不能笼统地说“CP0 完全不判断该不该陷入”：它不决定精确接受时机，但参与中断资格过滤和优先级编码。

### 5.1 异常方向（RTU → CP0）

RTU 在某条退休指令上发现异常（或决定接受一个中断）时：

1. 拉高 `rtu_cp0_expt_vld`（regs.v 各陷入 always 块的触发条件）。
2. 给出 `rtu_yy_xx_expt_vec[5:0]`：bit5 区分中断/异常，bit[4:0] 是 cause。
3. 给出 `rtu_cp0_epc`（陷入点 PC）、`rtu_cp0_expt_mtval`（辅助值）。

当 `rtu_cp0_expt_vld` 在 `regs_flush_clk` 有效沿被接受时，CP0 的并列时序块在该沿完成 mepc/sepc、mcause/scause、mtval/stval、状态栈和 `pm` 的选择性更新。具体写入 M 套还是 S 套由同一时刻的 `mdeleg_vld` 决定。这套同沿更新的细节见 [01_cp0_trap.md](./01_cp0_trap.md)。

### 5.2 中断方向（CP0 → RTU）

中断源（`biu_cp0_*_int`、`hpcp_cp0_int_vld` 和可写的 `*ip_reg`）在 regs 中经过 pending、局部使能、当前特权级全局使能和委派条件，形成 `int_sel[14:0]`。IUI 用固定优先级编码器选择一个 cause，并把请求寄存成低有效 `cp0_rtu_xx_int_b`。

RTU 只在满足其退休侧精确中断条件时把请求转化为异步陷入事件。需要注意两个微小但重要的实现事实：

- IUI 的请求寄存器每个有效时钟沿都根据当前 `int_vld` 重写，并不是一个必须等待 ack 才清除的 sticky 请求位；
- `rtu_cp0_int_ack` 端口在当前 CP0 RTL 中未被逻辑使用。请求最终消失通常依赖陷入后全局中断状态改变、pending 源撤销或局部使能改变，而不是 CP0 消费这个 ack。

---

## 6. 与 IU/IDU 的 CSR 指令握手

一条 CSR/MRET/SRET/WFI 的生命周期：

1. **请求和数据锁存**：`idu_cp0_rf_gateclk_sel` 使 func/iid/opcode/src0/preg 进入 `iui_ex1_*`；`idu_cp0_rf_sel` 则使主状态机从 IDLE 转入 EX1。两者承担“开时钟/锁数据”和“功能请求有效”两个角色，验证时应同时满足接口约定。
2. **EX1**：合法 CSR 访问通过 `inst_csr_ex1` 读取 regs 或外部 CSR 路由，并把旧值锁入 `cp0_rslt_reg`。新写值由旧值和 rs1/uimm 组合计算。
3. **EX2**：`iui_ex2_commit = commit0 && commit_iid==iui_iid`。只有它为 1 时，`cp0_ex2_select` 才成立，进而允许 CSR 写、MRET/SRET 状态更新、非法指令上报和 flush 状态锁存。
4. **EX2 是否停留**：状态机是否离开 EX2看的是 `cp0_inst_cmplt`，不是 `iui_ex2_commit`。普通 CSR 的 `cp0_inst_cmplt` 通常立即为 1；长延时 WFI/MMU/HPCP/BIU/cache 操作才会把 EX2 保持住。因此准确表述是“commit 门控副作用”，不是“状态机一直等 commit”。
5. **EX3**：主状态表明操作进入回送阶段。CSR 结果有效还要求 `iui_privilege && iui_flop_commit`；不能仅因 `cur_state==EX3` 就认为有架构结果写回。

详见 [03_cp0_lpmd_iui.md](./03_cp0_lpmd_iui.md)。

---

## 7. 整体数据流

```
 ① CSR 写：IDU →[EX1 读旧值/算新值]→[EX2 匹配 commit 才产生 iui_regs_sel]→ CSR reg
 ② CSR 读：iui_regs_addr →[regs data_out 大 mux 行3900]→ regs_iui_data_out → cp0_rslt_reg → IU
 ③ 陷入：RTU rtu_cp0_expt_vld →[regs 同沿更新 EPC/cause/tval/status/pm]；
           RTU 同时把 expt_vec/vld 送 IFU，IFU 使用 CP0 的 vbr 计算异常入口
 ④ 出栈：MRET/SRET →[regs 出栈 mstatus + pm←mpp/spp]→ cp0_iu_ex3_efpc(=mepc/sepc) → IFU
 ⑤ 中断：biu/hpcp int →[regs mie/deleg 过滤 → int_sel]→[iui 编码 vec]→ cp0_rtu_xx_vec → RTU 退休边界接受 → 走 ③
 ⑥ 配置广播：CSR reg →(组合)→ cp0_ifu/idu/lsu/mmu/pmp_* (regs.v 行 4102-4278)
 ⑦ WFI：iui inst_lpmd_ex1_ex2 →[lpmd 3 态机]→ no_op_req/lpmd_b → BIU；中断到来唤醒
```

---

## 8. 子模块分工

| 子模块 | 行数 | 一句话职责 | 详见 |
|---|---|---|---|
| `ct_cp0_regs` | 4394 | CSR 实体、trap 同沿状态更新、一层 previous 状态和配置广播 | [01](./01_cp0_trap.md)、[02](./02_cp0_csr.md) |
| `ct_cp0_iui` | 1656 | 接 IDU 指令、4 态执行、特权检查、中断打包、reset cache inv | [03](./03_cp0_lpmd_iui.md) |
| `ct_cp0_lpmd` | 232 | WFI 低功耗 3 态机 | [03](./03_cp0_lpmd_iui.md) |
| `ct_cp0_top` | 1072 | 例化、连线和 `debug_info` 状态拼装；无独立 CP0 主状态机 | 本文 |

---

## 本章小结

CP0 把特权状态、CSR 执行、陷入入口与返回、低功耗控制和若干系统维护请求集中在同一架构状态边界上。当前特权级由单个 `pm[1:0]` 寄存器表示，陷入和返回通过更新当前级以及 `xPP/xPIE` 等 previous 字段完成一层硬件保存，再由 `cp0_yy_priv_mode` 向全核广播。中断资格由 CP0 根据 pending、enable、委派和当前特权组合产生，RTU 再选择精确退休边界接受；同步异常则主要由执行和退休侧检测后送入 RTU。只有 RTU 接受陷入，CP0 才在相应时钟沿更新 EPC、cause、tval、状态位和目标特权级，因此“存在请求”和“架构陷入已经发生”必须严格区分。

CSR 指令沿 RF、EX1、EX2、EX3 前进，读值可以提前形成，但写副作用只有在 EX2、写类 CSR 已锁存且退休 IID commit 匹配时才通过 `iui_regs_sel` 落盘。状态机推进条件和架构副作用资格是两件事，不能因为指令到达 EX2 就认为 CSR 已经写入。`ct_cp0_regs.v` 同时保存会被陷入修改的状态和纯配置位，并用统一地址译码、写入口和读 MUX 路由 PMP、MMU、HPCP、L2 等外部 CSR。H/VS 相关地址常量或数据拼装仍可在源码中看到，但当前能力位和虚拟模式为 0，不能据此认定虚拟化功能可用。阅读 CP0 时，最可靠的方法是按“指令资格或外部事件、组合候选、精确接受、寄存器更新、全核广播”逐步跟踪。

## 9. 精读 CP0 时必须区分的事件

| 事件 | 典型信号 | 是否已经产生架构副作用 |
|---|---|---|
| IDU 提供锁存数据 | `idu_cp0_rf_gateclk_sel` | 否，只是输入寄存器可更新 |
| IDU 声明 CP0 指令有效 | `idu_cp0_rf_sel` | 否，只使 IUI 进入 EX1 |
| CSR 旧值被读取 | `inst_csr_ex1` | 否，读结果还可能被冲刷 |
| 退休 IID 匹配 | `iui_ex2_commit` | 只是 commit 条件 |
| CP0 EX2 真正选中 | `cp0_ex2_select` | 允许产生写、return、异常、flush 等副作用 |
| CSR 寄存器写使能 | `iui_regs_sel && addr_match` | 在相应寄存器时钟沿更新 |
| 中断候选存在 | `int_sel != 0` | 否，只是可请求 |
| IUI 中断请求有效 | `cp0_rtu_xx_int_b==0` | 否，RTU 尚可延后接受 |
| RTU 陷入有效 | `rtu_cp0_expt_vld` | 是，CP0 陷入状态在该沿更新 |
