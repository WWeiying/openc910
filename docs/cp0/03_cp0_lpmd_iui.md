# C910 CP0 LPMD / IUI 模块详细教学文档

> RTL 文件：
> - `C910_RTL_FACTORY/gen_rtl/cp0/rtl/ct_cp0_lpmd.v`（232 行）—— WFI 低功耗 3 态机
> - `C910_RTL_FACTORY/gen_rtl/cp0/rtl/ct_cp0_iui.v`（1656 行）—— 与 IU 的 CSR/特权指令接口、4 态执行机、特权检查、中断打包、reset cache inv
>
> 陷入核心见 [01_cp0_trap.md](./01_cp0_trap.md)，CSR 地址表见 [02_cp0_csr.md](./02_cp0_csr.md)。

---

## 目录

- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. IUI 4 态执行机：IDLE→EX1→EX2→EX3](#4-iui-4-态执行机idleex1ex2ex3)
- [5. IUI 特权与合法性检查：iui_privilege](#5-iui-特权与合法性检查iui_privilege)
- [6. IUI 中断打包与请求 RTU](#6-iui-中断打包与请求-rtu)
- [7. IUI 完成判定与 reset cache inv](#7-iui-完成判定与-reset-cache-inv)
- [8. LPMD：WFI 低功耗 3 态机](#8-lpmdwfi-低功耗-3-态机)
- [本章小结](#本章小结)

---

## 1. 模块概述

这两个模块是 CP0 的"执行侧"：

- **IUI（IU Interface）** 是 CP0 指令与流水线之间的接口。它有 IDLE、EX1、EX2、EX3 四个状态；无等待指令在派发后占用三个活动状态，长延时操作可以停在 EX2。因此“四状态”不等于所有 CP0 指令固定四拍完成。
- **LPMD（Low-Power Mode）** 是 WFI 的低功耗协调逻辑。IUI 在合法 WFI 的 EX1 就可拉起 `inst_lpmd_ex1_ex2`，EX2 时还要满足 commit 才产生 `cp0_ex2_select`。LPMD 请求 IFU/LSU/MMU 进入 no-op，等待 IFU/LSU/MMU/BIU 都报告 no-op，再关闭功能时钟；唤醒后才回 `lpmd_cmplt`。

两者通过 `inst_lpmd_ex1_ex2`（IUI→LPMD）与 `lpmd_cmplt`（LPMD→IUI）一对信号握手，在 top.v 行 764/779 连接。

---

## 2. 端口说明

### 2.1 IUI 端口分组

| 组 | 信号 | 方向 | 含义 |
|---|---|---|---|
| IDU 派发 | `idu_cp0_rf_func/iid/opcode/preg/src0/sel/gateclk_sel` | in | 一条 CP0 指令的全部信息 |
| 退休 | `rtu_yy_xx_commit0/_iid` | in | 退休 IID（确认提交） |
| 冲刷 | `rtu_yy_xx_flush`、`rtu_yy_xx_dbgon` | in | 流水冲刷 / 调试激活 |
| → regs | `iui_regs_sel/addr/src0/csr_wr/csrw/inst_mret/inst_sret/inv_expt/opcode/ori_src0` | out | 写选通与写数据 |
| ← regs | `regs_iui_data_out/pm/v/cskyee/fs_off/vs_off/int_sel/tsr/tw/tvm/...` | in | 读数据与权限判定输入 |
| → IU | `cp0_iu_ex3_rslt_data/vld/preg/iid/flush/expt_vld/expt_vec/mtval/inst_vld/abnormal` | out | EX3 回写结果与异常 |
| 中断 | `cp0_rtu_xx_int_b/vec` | out | 向 RTU 请求中断 |
| → LPMD | `inst_lpmd_ex1_ex2` | out | 发起 WFI |
| ← LPMD | `lpmd_cmplt` | in | WFI 完成 |
| L2/HPCP/cache | `cp0_biu_*`、`cp0_hpcp_*`、`cp0_mmu_tlb_all_inv`、`cp0_ifu_rst_inv_done`、`rst_inv` 系列 | out | 路由 L2/HPCP 写、复位 inv |

### 2.2 LPMD 端口

| 信号 | 方向 | 含义 |
|---|---|---|
| `inst_lpmd_ex1_ex2` | in | IUI 发起 WFI |
| `lpmd_cmplt` | out | WFI 完成回 IUI |
| `ifu/lsu/biu/mmu_yy_xx_no_op` | in | 四大单元已停下的应答 |
| `cp0_ifu/lsu/mmu_no_op_req` | out | 请求三单元停下 |
| `cp0_biu_lpmd_b[1:0]` / `cp0_had_lpmd_b` | out | 向 BIU/HAD 报告低功耗 |
| `cp0_yy_clk_en` | out | 全核时钟使能（进低功耗后拉低） |
| `regs_lpmd_int_vld` | in | 至少一个 `pending && 局部 xIE` 成立；不包含当前特权级的全局 MIE/SIE 条件 |
| `had_cp0_xx_dbg`、`rtu_yy_xx_dbgon`、`rtu_yy_xx_flush` | in | 调试/冲刷唤醒 |

---

## 3. 参数与关键寄存器

### 3.1 IUI 状态/参数（ct_cp0_iui.v）

| 名称 | 行 | 含义 |
|---|---|---|
| `IDLE/EX1/EX2/EX3 = 2'b00/01/10/11` | 386-389 | 4 态执行机编码 |
| `RST_IDLE/RST_WFC = 1'b0/1` | 391-392 | 复位 cache inv 子状态机 |
| `cur_state[1:0]` | 202 | 执行机现态 |
| `iui_ex1_inst_*`（csrrw/s/c/i, mret, sret, wfi） | 205-213 | EX1 锁存的指令类型 |
| `iui_ex1_iid/opcode/src0/preg` | 204/214-216 | EX1 锁存的指令信息 |
| `iui_flop_commit` | 217 | 该指令是否已退休（EX2 锁存） |
| `cp0_rslt_reg[63:0]` | 201 | CSR 读出值（EX1 锁存，CSRRS/C 运算用） |
| `iui_int_vec[4:0]`/`iui_int_vld_b` | 218/219 | 中断向量与请求（低有效） |
| `rst_cache/icache/dcache/tlb_inv` | 221-228 | 复位 cache 全失效子状态机 |

### 3.2 LPMD 状态/参数（ct_cp0_lpmd.v）

| 名称 | 行 | 含义 |
|---|---|---|
| `IDLE/WAIT/LPMD = 2'b00/01/10` | 132-134 | 3 态机编码 |
| `cur_state[1:0]` | 65 | 现态 |
| `lpmd_b[1:0]` | 66 | 低功耗状态位（11=正常运行，非 11=已进低功耗） |

---

## 4. IUI 4 态执行机：IDLE→EX1→EX2→EX3

### 4.1 指令锁存（派发拍）

IDU 在 `idu_cp0_rf_gateclk_sel` 拍把 func 译码成各指令类型（行 725-733，func 编码：WFI=5'b01001、SRET=01000、MRET=01010、CSRRW=10000、CSRRS=10001…），连同 iid/opcode/src0/preg 一起锁进 `iui_ex1_*`（行 752-766）。`iui_addr = opcode[31:20]`（行 796），`iui_uimm = opcode[19:15]`（行 797）。

### 4.2 状态转移与两个不同的门控

```verilog
// ct_cp0_iui.v 行 1120-1132
IDLE : if(idu_cp0_rf_sel) next = EX1;     // 来了一条 CP0 指令
EX1  :                    next = EX2;      // 固定一拍
EX2  : if(cp0_inst_cmplt) next = EX3;      // 等操作类完成条件，不直接等待 commit
EX3  :                    next = IDLE;
```
`rtu_yy_xx_flush` 在 IUI 时钟有效时强制状态回 IDLE。

EX2 有两个容易混淆的条件：

```text
cp0_inst_cmplt  -> 决定状态机是否离开 EX2
iui_ex2_commit -> 决定 cp0_ex2_select 是否成立
```

普通 CSR 的 `cp0_inst_cmplt` 通常为 1，即使这一周期 `iui_ex2_commit=0`，状态机也不会因此自动等待；它仍可进入 EX3，但写入、异常、flush 和结果 valid 会被 commit 相关条件挡住。接口正确性依赖 IDU/RTU 对这类串行化指令的调度契约，不能把未出现的“EX2 等 commit 状态保持逻辑”写进文档。

### 4.3 各拍干什么

| 拍 | 关键动作 | 行 |
|---|---|---|
| **EX1** | 合法 CSR 才通过 `inst_csr_ex1` 读取本地/外部旧值；本地结果锁入 `cp0_rslt_reg`。WFI 可从此状态开始 no-op 协调 | 1385、1390、1522 |
| **EX2** | 比较 commit IID；匹配时 `cp0_ex2_select` 才允许 CSR 写、MRET/SRET、非法异常和 flush 锁存。长延时操作由 `cp0_inst_cmplt` 决定是否停留 | 1081、1140、1425 |
| **EX3** | 表示进入回送阶段；CSR 结果 valid 还要求合法和 `iui_flop_commit`。`cp0_iu_ex3_inst_vld` 仅反映 EX3 状态，本身没有 commit 门控 | 1152、1507 |

`cp0_select` 是三类阶段资格的 OR：EX1 状态、EX2 且匹配 commit、EX3 且此前捕获到 commit。它不是单周期脉冲。由它派生的 `cp0_mret/cp0_sret`、efpc valid 等信号可能跨多个阶段出现，而真正修改 `pm/mstatus` 的 `iui_regs_inst_mret/sret` 只在 commit-qualified EX2 成立。

### 4.4 新写值如何算（CSRRW/S/C 语义）

EX1 拿到旧值 `cp0_rslt_reg` 后，按指令类型算新值（行 1436-1448）：
```verilog
csrrw_src0  = src0;                       // 直接覆盖
csrrs_src0  = cp0_rslt_reg |  src0;       // 按位置 1
csrrc_src0  = cp0_rslt_reg & ~src0;       // 按位清 0
csrrwi/si/ci = 用 uimm 替换 src0          // 立即数版本
iui_regs_src0 = 按类型 one-hot 选其一;
```
即 regs 收到的 `iui_regs_src0` 已经是"该写进 CSR 的最终值"，regs 端无需再判指令类型。只读优化：`iui_inst_ro`（行 801）识别 CSRRS/C 且 rs1/uimm 为 0 的情形（纯读，不写），此时不发写选通。

### 4.5 为什么写要等 EX2 退休

`iui_regs_sel = inst_csr_ex2 && cp0_ex2_select`，而 `cp0_ex2_select` 包含匹配 IID 的 `iui_ex2_commit`。因此本地 CSR 写只在 commit-qualified EX2 落盘。EX1 可以先读旧值，但结果只有在 EX3 且 `iui_flop_commit=1` 时才对 IU 声明有效。

“写等 commit”描述的是副作用门控，不是 EX2 状态转移条件；这两个层面必须分开。

---

## 5. IUI 特权与合法性检查：iui_privilege

一条 CSR/特权指令是否允许执行，由组合信号 `iui_privilege`（行 1374-1380）总判。它是多个"非法标志"的反：

```verilog
assign iui_privilege = (dbgon || M模式 || S模式合法 || U模式合法)
                     && !csr_addr_inv && !iui_w_inv && !iui_fs_inv
                     && !iui_vs_inv && !iui_tee_inv;
```

各非法标志：

| 标志 | 行 | 触发条件 |
|---|---|---|
| `csr_addr_inv` | 1076 | 地址不在合法表（`addr_inv`，casez 行 809-1073）且是 CSR 指令 |
| `iui_s_inv` | 1323-1331 | S 模式访问 M 级 CSR（addr[9:8]==11）、或 MRET、或被 tsr/tw/tvm 拦截的 SRET/WFI/SATP、或计数器越权 |
| `iui_u_inv` | 1334-1340 | U 模式访问非 U 级 CSR、或 MRET/SRET/WFI、或计数器越权 |
| `iui_w_inv` | 1343 | 写只读 CSR（addr[11:10]==11 且非纯读） |
| `iui_fs_inv` | 1347-1354 | FS=Off 时访问浮点 CSR |
| `iui_vs_inv` | 1356-1361 | VS=Off 时访问向量 CSR |
| `iui_tee_inv` | 1362-1371 | TEE 未授权时访问 TEE 相关 CSR |

特权级判定来自 regs 的 `regs_iui_pm`。`rtu_yy_xx_dbgon` 只使 `iui_privilege` 最外层的“模式允许”子表达式成立，后面仍与以下条件相与：

```text
!csr_addr_inv && !iui_w_inv && !iui_fs_inv
&& !iui_vs_inv && !iui_tee_inv
```

因此调试模式只改变明确写入上述方程的权限条件，不会让未列入地址白名单的 CSR、
只读编码写入或 FS/VS-Off 访问自动合法。调试访问仍要经过地址命中、读写属性和
浮点/向量状态检查，不能概括为对全部 CSR 的无限制放行。

不合法且 EX2 commit-qualified 时，`iui_regs_inv_expt` 通知 regs 前置记录非法指令编码；IUI 再在 EX3 向 IU给出非法指令异常 cause 2 和原指令 mtval。真正写入哪一套最终 trap CSR，仍以 IU/RTU 后续接受异常时形成的 `rtu_cp0_expt_vld`、委派结果和 payload 为准，详见 [01 §5.3](./01_cp0_trap.md)。

CSR 地址中的 `[9:8]` 和 `[11:10]` 提供最低特权与只读编码，但 IUI 仍然需要 `addr_inv` 白名单以及计数器、FS/VS、TEE 等附加检查。尤其是自定义地址段被通配放行，不能说“完全无需查表”。

---

## 6. IUI 中断打包与请求 RTU

regs 已把过滤后的 15 位候选中断 `regs_iui_int_sel` 送来（见 [01 §9](./01_cp0_trap.md)）。IUI 做两件事：

1. **有无中断**：`int_vld = |regs_iui_int_sel`，在时钟沿被转换成低有效 `iui_int_vld_b`；它每拍根据当前候选重写，并非等待 `rtu_cp0_int_ack` 才清除的 sticky 位。
2. **编码一个向量**：`casez` 按从上到下的固定优先级选择 cause，再在 `int_vld` 时锁存进 `iui_int_vec`。当前优先级为非委派 mcip、mhip、meip、msip、mtip、seip、ssip、stip、moip，之后才是委派候选。

MEIP/MTIP/MSIP/SEIP/STIP/SSIP 使用相应 RISC-V cause 编码；16/17/18 则是本实现的扩展中断槽位。`int_sel` 到对外 request/vector 之间有一拍寄存延迟。RTU 负责把请求变成精确退休边界的异步陷入；IUI 不直接写 EPC/cause。

---

## 7. IUI 完成判定与 reset cache inv

### 7.1 cp0_inst_cmplt：指令何时能离开 EX2

```verilog
// 行 1495-1501
assign cp0_inst_cmplt = ( !(inst_lpmd || iui_csr_mcir || iui_csr_l2regs || iui_csr_hpcp)
                         || lpmd_cmplt || mmu_cp0_cmplt || hpcp_cp0_cmplt || biu_cp0_cmplt)
                        && regs_iui_cfr_no_op && regs_iui_cins_no_op;
```
普通 CSR 不属于括号中的长延时类别时，第一项为真；WFI、MCIR、L2 CSR、HPCP CSR 则等待 completion OR 项之一成立。`regs_iui_cfr_no_op/cins_no_op` 还必须同时为真。

完成条件使用共享 OR：

```text
lpmd_cmplt || mmu_cp0_cmplt || hpcp_cp0_cmplt || biu_cp0_cmplt
```

它没有按“当前操作类型”分别与对应 complete 相与，因此依赖系统保证同一时刻不会有无关的 complete 脉冲误完成当前长操作。接口级验证应检查这个互斥/相关性假设，而不是只验证每条正常路径。

### 7.2 复位 cache 全失效

上电后 IFU 发 `ifu_cp0_rst_inv_req`。IUI 实际有：

- 一个总控 `rst_cache_inv` 状态机，记录请求是否处于等待所有完成阶段；
- I-cache、D-cache、TLB 三个工作状态机。

I-cache/D-cache 请求在各自 WFC 状态保持；TLB 的 `cp0_mmu_tlb_all_inv` 只在 TLB 子状态仍为 IDLE 且原始请求为高时形成启动脉冲，随后 TLB 子状态进入 WFC 等 `mmu_cp0_tlb_done`。三个工作状态都回 IDLE 后，总控才产生 `cp0_ifu_rst_inv_done`。

这条流程覆盖 I-cache、D-cache 和 TLB，不包含一个独立的 L2 全失效状态机，所以不应泛称“所有 cache 层级全部失效”。

---

## 8. LPMD：WFI 低功耗 3 态机

### 8.1 状态机

```verilog
// ct_cp0_lpmd.v 行 153-167
IDLE : if(inst_lpmd_ex1_ex2) next = WAIT;   // IUI 发来合法 WFI
WAIT : if(lpmd_ack)          next = LPMD;    // 四大单元都停了
LPMD : if(!cpu_in_lpmd)      next = IDLE;    // 被唤醒
```
`rtu_yy_xx_flush` 强制回 IDLE（行 141）。

### 8.2 三态各做什么

**WAIT**（`lpmd_in_wait_state = cur_state[0]`，行 171）：拉 `cp0_ifu/lsu/mmu_no_op_req`（行 177-179）请求三大单元停止发起新事务。等它们连同 BIU 都回 `*_yy_xx_no_op`，凑齐 `lpmd_ack`（行 184-188）才进 LPMD：
```verilog
assign lpmd_ack = lpmd_in_wait_state && ifu_yy_xx_no_op && lsu_yy_xx_no_op
                  && biu_yy_xx_no_op && mmu_yy_xx_no_op;
```

**进入 LPMD 时**，`lpmd_ack && !cpu_in_lpmd` 成立，并且该周期 `inst_lpmd_ex1_ex2` 仍须为 1，`lpmd_b` 才写成 `00`；否则写回 `11`。这说明 LPMD 的 no-op 完成还要与 IUI 当前仍在处理该 WFI 相对应。`cpu_in_lpmd = !(lpmd_b[1]&lpmd_b[0])`，因此当前实际写入值中 `00` 表示低功耗、`11` 表示运行。
- `cp0_biu_lpmd_b = lpmd_b`（行 217）通知 BIU 可降频/关时钟；
- `cp0_yy_clk_en = lpmd_b[1]&lpmd_b[0]`（行 227）= 0，**关掉全核功能时钟**，进入真正省电。

**唤醒**：`lpmd_b` 在 `(had_cp0_xx_dbg || regs_lpmd_int_vld) && cpu_in_lpmd || rtu_yy_xx_dbgon` 时重置回 11（行 202-204）——即**有中断挂起、或调试介入**就唤醒。唤醒后 `cpu_in_lpmd` 变 0，状态机回 IDLE，`lpmd_cmplt = (state==LPMD) && !cpu_in_lpmd`（行 190）回 IUI，WFI 指令完成。

`regs_lpmd_int_vld` 是若干 `xip_en = xip && xie` 的 OR：

- 它要求局部中断使能位已经打开；
- 它不检查当前模式的全局 MIE/SIE；
- 它不检查委派后是否最终成为 `int_sel` 候选；
- 它不要求 RTU 已经接受中断。

因此，WFI 唤醒与“最终进入 handler”是两个事件。也不能把它简化成“任何 pending 都能唤醒”，因为局部 xIE=0 的 pending 不在该 OR 中。

### 8.3 时钟门控自洽

状态机 `cur_state` 使用 `cpuclk`，其门控输入的 `global_en` 还是 `cp0_yy_clk_en`；真正的唤醒保持寄存器 `lpmd_b` 则直接使用 `forever_cpuclk`。进入低功耗后：

1. `lpmd_b=00` 使 `cp0_yy_clk_en=0`；
2. 依赖该全局使能的功能时钟停止；
3. `lpmd_b` 仍能在 forever 时钟上观察中断/调试；
4. 唤醒把 `lpmd_b` 写回 11；
5. 功能时钟恢复，LPMD 状态机才有时钟返回 IDLE 并产生完成。

这是 RTL 的门控意图。仓库通用 `gated_clk_cell` 在未定义特定 ICG 宏时会 pass-through，仿真中时钟是否真的停要看编译配置；状态与使能逻辑本身仍按上述关系工作。

## 本章小结

CP0 IUI 把 CSR 指令的计算、合法性检查、提交资格和长延时完成统一在一条执行控制链中。合法读在 EX1 形成，CSRRW/CSRRS/CSRRC 的替换、按位置位和按位清零也在 IUI 中算出最终新值；regs 只按地址和 local enable 保存结果。写入必须等到 EX2 且退休 IID commit 匹配，读结果也只有在该资格被 EX2 捕获后才于 EX3 声明有效。特权检查不仅比较 CSR 地址编码中的最低权限，还组合地址白名单、计数器授权、FS/VS 和 TEE 条件。长延时 cache/TLB 维护与 cache-line 读取通过统一 `cp0_inst_cmplt` 释放 EX2，其中某些请求还由 regs 保持位维持到下游 done；共享完成接口要求各下游脉冲满足既定互斥和归属协议。流水级数量本身不能直接给出 CP0 性能，实际开销还取决于调度串行化、完成等待和前后指令依赖。

WFI 由独立三态低功耗状态机处理，因为它需要等待 IFU、IDU、LSU、RTU 的 `no_op`，再请求关闭功能时钟，并在中断或调试到来时恢复。IUI 与 LPMD 只通过 `inst_lpmd_ex1_ex2` 和 `lpmd_cmplt` 握手；唤醒判定运行在 `forever_cpuclk` 上，使普通 CP0 功能时钟关闭后仍有路径重新开启处理器。复位失效操作则由一个总控状态机同时协调 I-cache、D-cache 和 TLB 三个工作状态机，全部完成后才汇总结束；当前 RTL 没有 L2 子状态机。地址表和外部 CSR 路由见 [02_cp0_csr.md](./02_cp0_csr.md)。观察波形时，应把 IUI 指令状态、commit、regs 写使能、下游请求/done 以及 LPMD 状态放在同一时间轴上，才能判断停顿来自提交资格、维护完成还是低功耗握手。
