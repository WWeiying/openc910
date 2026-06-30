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
- [4. IUI 4 态执行机：IDLE→EX1→EX2→EX3](#4-iui-4-态执行机ideleex1ex2ex3)
- [5. IUI 特权与合法性检查：iui_privilege](#5-iui-特权与合法性检查iui_privilege)
- [6. IUI 中断打包与请求 RTU](#6-iui-中断打包与请求-rtu)
- [7. IUI 完成判定与 reset cache inv](#7-iui-完成判定与-reset-cache-inv)
- [8. LPMD：WFI 低功耗 3 态机](#8-lpmdwfi-低功耗-3-态机)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

这两个模块是 CP0 的"执行侧"：

- **IUI（IU Interface）** 是 CP0 与流水线之间的唯一指令通道。所有 `CSRRW/S/C[I]`、`MRET`、`SRET`、`WFI` 都从 IDU 进来、在 IUI 走一条 4 拍微流水（IDLE→EX1→EX2→EX3），做特权检查、把读出值回送 IU、把写值送给 regs。它还顺带打包中断向量请求 RTU、驱动复位时的 cache 全失效。
- **LPMD（Low-Power Mode）** 是 WFI 的执行体。IUI 判定一条合法 WFI 后拉 `inst_lpmd_ex1_ex2`，LPMD 用一个 3 态机请求全核停下、报告 BIU 进入低功耗、等中断唤醒，再回 `lpmd_cmplt` 让 IUI 完成那条 WFI。

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
| `regs_lpmd_int_vld` | in | 有中断挂起（唤醒条件） |
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

### 4.2 状态转移

```verilog
// ct_cp0_iui.v 行 1120-1132
IDLE : if(idu_cp0_rf_sel) next = EX1;     // 来了一条 CP0 指令
EX1  :                    next = EX2;      // 固定一拍
EX2  : if(cp0_inst_cmplt) next = EX3;      // 等指令可完成（退休 + 各种 done）
EX3  :                    next = IDLE;
```
`rtu_yy_xx_flush` 强制回 IDLE（行 1109）。

### 4.3 各拍干什么

| 拍 | 关键动作 | 行 |
|---|---|---|
| **EX1** | 从 regs 读旧值锁进 `cp0_rslt_reg`（CSRRS/C 要拿旧值做或/与）；做特权检查（组合，下节） | 1522-1523 |
| **EX2** | 比对退休 IID（`iui_ex2_commit`，行 1081）；`iui_flop_commit` 锁存是否退休（行 1085-1093）；真正给 regs 发写选通 `iui_regs_sel`（行 1425）；锁存 `cp0_flush`/`cp0_expt_vld`（行 1556/1645） | — |
| **EX3** | 把结果回 IU：`cp0_iu_ex3_rslt_vld`（行 1507）、`cp0_iu_ex3_rslt_data=cp0_rslt_reg`（行 1527）；`cp0_iu_ex3_inst_vld`（行 1152） | — |

`cp0_select` 是三拍 select 的合并（行 1147-1149）：EX1 select、EX2 且已退休、EX3 且 flop_commit。

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

`iui_regs_sel = inst_csr_ex2 && cp0_ex2_select`（行 1425），而 `cp0_ex2_select` 含 `iui_ex2_commit`（行 1140）。**即 CSR 写必须等该指令在 RTU 退休才落盘**——CSR 是不可回滚的全局副作用，投机执行的 CSR 写若被冲刷将无法恢复，所以延后到退休确认。读（EX1）可以投机，因为读无副作用且结果在 EX3 才确认有效（`iui_flop_commit` 门控，行 1510）。

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

特权级判定来自 regs 的 `regs_iui_pm`（行 1314-1316）：`iui_m_mode = pm==11` 等。**调试模式 `rtu_yy_xx_dbgon` 一律放行**（行 1374），因为调试器需要无限制访问 CSR。

不合法时：`iui_regs_inv_expt = !iui_privilege && cp0_ex2_select`（行 1430）告诉 regs 这是非法访问（regs 据此把指令编码写进 mtval，见 [01 §5.3](./01_cp0_trap.md)）；同时 `cp0_iu_ex3_expt_vld`（行 1562）+ `cp0_iu_ex3_expt_vec=5'h2`（行 1568，非法指令异常号 2）报给 IU。

CSR 地址里编码的"最低访问特权"：`iui_addr[9:8]` 是 RISC-V CSR 地址约定的特权级字段，`iui_addr[11:10]` 是读写性字段（11=只读）。IUI 直接用地址位做权限，无需查表。

---

## 6. IUI 中断打包与请求 RTU

regs 已把过滤后的 15 位候选中断 `regs_iui_int_sel` 送来（见 [01 §9](./01_cp0_trap.md)）。IUI 做两件事：

1. **有无中断**：`int_vld = |regs_iui_int_sel`（行 1577），锁存成请求 `iui_int_vld_b`（低有效，行 1578-1586）→ `cp0_rtu_xx_int_b`（行 1625）。
2. **编码唯一向量**：用优先级 `casez`（行 1592-1611）把 one-hot 选成单个中断号 `valid_int_vec`，锁存为 `iui_int_vec` → `cp0_rtu_xx_vec`（行 1626）。优先级从高到低：mcip(16)>mhip(18)>meip(11)>msip(3)>mtip(7)>seip(9)>ssip(1)>stip(5)>moip(17)，委派项再排其后。

注意中断号映射到 RISC-V mcause 标准编码（如 meip=11、mtip=7、msip=3、seip=9…）。RTU 拿到向量后在退休边界回 `rtu_cp0_expt_vld` 触发陷入——**IUI 只发请求，不决定时机**。

---

## 7. IUI 完成判定与 reset cache inv

### 7.1 cp0_inst_cmplt：指令何时能离开 EX2

```verilog
// 行 1495-1501
assign cp0_inst_cmplt = ( !(inst_lpmd || iui_csr_mcir || iui_csr_l2regs || iui_csr_hpcp)
                         || lpmd_cmplt || mmu_cp0_cmplt || hpcp_cp0_cmplt || biu_cp0_cmplt)
                        && regs_iui_cfr_no_op && regs_iui_cins_no_op;
```
普通 CSR 指令立即可完成；但**带外部副作用的指令要等对端 done**：WFI 等 `lpmd_cmplt`、TLB/MMU 操作等 `mmu_cp0_cmplt`、L2 CSR 等 `biu_cp0_cmplt`、HPCP 等 `hpcp_cp0_cmplt`。`regs_iui_cfr_no_op`/`cins_no_op`（regs 行 3992-3993）确保 cache 维护/读行操作完成前不放行。这把"长延时 CSR"的阻塞集中在一个完成条件里。

### 7.2 复位 cache 全失效

上电后 IFU 发 `ifu_cp0_rst_inv_req`，IUI 用四个并列子状态机（行 1159-1301，每个 RST_IDLE↔RST_WFC）分别等 icache/dcache/tlb 完成失效，并驱动 `cp0_mmu_tlb_all_inv`（行 1308）、`iui_regs_rst_inv_i/d`（行 1305-1307）。全部 done 后回 `cp0_ifu_rst_inv_done`（行 1309）告诉 IFU 可以开始取指。这是"核出复位后必须先把 cache/TLB 清干净再跑"的硬件流程。

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

**进入 LPMD 时**置低功耗位（行 198-214）：`lpmd_ack && !cpu_in_lpmd` 且确是 WFI 时 `lpmd_b<=2'b00`。`cpu_in_lpmd = !(lpmd_b[1]&lpmd_b[0])`（行 220），即 lpmd_b 非 11 表示已进低功耗。此时：
- `cp0_biu_lpmd_b = lpmd_b`（行 217）通知 BIU 可降频/关时钟；
- `cp0_yy_clk_en = lpmd_b[1]&lpmd_b[0]`（行 227）= 0，**关掉全核功能时钟**，进入真正省电。

**唤醒**：`lpmd_b` 在 `(had_cp0_xx_dbg || regs_lpmd_int_vld) && cpu_in_lpmd || rtu_yy_xx_dbgon` 时重置回 11（行 202-204）——即**有中断挂起、或调试介入**就唤醒。唤醒后 `cpu_in_lpmd` 变 0，状态机回 IDLE，`lpmd_cmplt = (state==LPMD) && !cpu_in_lpmd`（行 190）回 IUI，WFI 指令完成。

注意唤醒只看 `regs_lpmd_int_vld`（regs 行 4012：任一中断使能且挂起），**不要求中断真被接受**——这符合 WFI 语义：WFI 在有挂起中断时就返回，至于是否真的进入 handler 由后续陷入流程决定。

### 8.3 时钟门控自洽

LPMD 自身的时钟 `cpuclk` 由 `lpmd_clk_en = inst_lpmd_ex1_ex2 || state!=IDLE`（行 136）门控——只在有 WFI 或状态机运转时才需要时钟。而它产出的 `cp0_yy_clk_en` 关的是**功能逻辑**时钟；LPMD 自己用 `forever_cpuclk`（行 198 的 lpmd_b 块）保证关核后还能被中断唤醒。这个"用永跳时钟维持唤醒逻辑、用门控时钟关功能"的分层是低功耗设计的关键。

---

## 设计取舍小结

1. **CSR 写延后退休、读可投机**：IUI 把读放 EX1（无副作用，可投机），把写选通押到 EX2 退休确认（行 1425）。这让 CSR 读不阻塞流水，又保证写不被投机污染——读写不同的副作用语义决定了不同的提交时机。

2. **新值在 IUI 算、regs 只落盘**：CSRRW/S/C 的或/与运算放在 IUI（行 1436-1448），regs 收到的就是最终值。好处是 regs 上百个寄存器写逻辑统一（`if(local_en) reg<=src0`），不必每个都判指令类型。

3. **特权检查纯组合 + 地址位直判**：`iui_privilege` 用 CSR 地址自带的特权/读写字段（addr[9:8]/[11:10]）直接判权限（行 1335/1343），无需权限表。一拍组合出结论，不增加流水级。

4. **长延时指令统一用 cp0_inst_cmplt 阻塞**：WFI/TLB/L2/cache 维护等都汇到一个完成条件（行 1495），靠在 EX2 自旋等待，而非各自加状态机。状态机只在执行机主干（4 态）和复位 inv（专用子机）出现，复杂度可控。

5. **WFI 用独立 3 态机而非塞进执行机**：低功耗涉及全核握手（四单元 no_op）+ 关时钟，与 CSR 执行节奏完全不同，单独成模块。IUI 与 LPMD 仅用 `inst_lpmd_ex1_ex2`/`lpmd_cmplt` 一对线握手，解耦清晰。

6. **唤醒逻辑挂永跳时钟**：`lpmd_b` 的唤醒判定用 `forever_cpuclk`（行 198），保证 `cp0_yy_clk_en` 关掉功能时钟后，中断/调试仍能把核唤醒。这是低功耗里"关得掉、醒得来"的必要分层。

7. **复位 cache inv 用四个对称子状态机**：icache/dcache/tlb 各一个 RST_IDLE↔RST_WFC（行 1159-1301），并行等待、统一汇总成 `rst_inv_done`。对称结构便于扩展（加 L2 等只需复制一段），也让各 cache 的失效时序互不阻塞。

---

*文档覆盖 ct_cp0_lpmd.v 全部 232 行逻辑，以及 ct_cp0_iui.v 全部 1656 行中执行机/特权/中断/完成/复位 inv 的核心逻辑（地址表部分见 [02_cp0_csr.md](./02_cp0_csr.md)）。*
