# C910 VFPU 总体架构详细教学文档

> RTL 目录：
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/`（顶层 + ctrl/dp/cbus/rbus）
> - `C910_RTL_FACTORY/gen_rtl/vfalu/rtl/`（fadd 加减 / fspu 特殊 / fcnvt 转换）
> - `C910_RTL_FACTORY/gen_rtl/vfmau/rtl/`（FMA 乘加 + 乘法器/压缩树/LZA）
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/`（除法 / 开方，SRT 基-16）

---

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 VFPU 是什么](#11-vfpu-是什么)
  - [1.2 在 C910 流水线中的位置](#12-在-c910-流水线中的位置)
- [2. 顶层端口说明](#2-顶层端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. 两条对称管线 pipe6 / pipe7](#4-两条对称管线-pipe6--pipe7)
- [5. 四个子执行单元的分工](#5-四个子执行单元的分工)
- [6. eu_sel 一热码：指令如何分发到子单元](#6-eu_sel-一热码指令如何分发到子单元)
- [7. 不对称性：vfdsu 为何只挂在 pipe6](#7-不对称性vfdsu-为何只挂在-pipe6)
- [8. VLEN128 与浮点/向量共享寄存器](#8-vlen128-与浮点向量共享寄存器)
- [9. CBUS / RBUS 双轨写回](#9-cbus--rbus-双轨写回)
- [10. MTVR 注入旁路](#10-mtvr-注入旁路)
- [11. 完整数据流（一条 vfadd / vfmacc / vfdiv 的旅程）](#11-完整数据流)
- [12. 各运算延迟与流水级总表](#12-各运算延迟与流水级总表)
- [设计取舍小结](#设计取舍小结)
- [覆盖声明](#覆盖声明)

---

## 1. 模块概述

### 1.1 VFPU 是什么

VFPU（Vector / Floating-Point Unit，向量/浮点执行单元）是 C910 中负责所有**浮点标量运算**与**向量运算**的执行单元集合。它统一处理：

- 浮点加减、比较、min/max、符号注入、分类（fclass）
- 浮点与整数之间、以及不同浮点宽度之间的类型转换
- 浮点乘加（FMA）/ 乘法
- 浮点除法、开方

VFPU 顶层 `ct_vfpu_top`（`vfpu/rtl/ct_vfpu_top.v:17`）实例化了一个控制核 + 一个数据通路核 + 完成总线 + 结果总线 + 4 类子执行单元的多个副本：

| 实例 | 位置 | 作用 |
|---|---|---|
| `ct_vfpu_ctrl` | `ct_vfpu_top.v:1041` | 流水级有效位/门控时钟产生 |
| `ct_vfpu_dp`   | `ct_vfpu_top.v:1130` | 源操作数准备、eu_sel 译码、结果汇聚 |
| `ct_vfpu_cbus` | `ct_vfpu_top.v:1357` | **完成总线**：发射当拍即报 RTU 完成 |
| `ct_vfpu_rbus` | `ct_vfpu_top.v:1377` | **结果总线**：物理寄存器写回 + 唤醒/前递广播 |
| `ct_vfalu_top_pipe6` | `ct_vfpu_top.v:1631` | pipe6 的 fadd + fspu |
| `ct_vfalu_top_pipe7` | `ct_vfpu_top.v:1653` | pipe7 的 fadd + fspu + **fcnvt** |
| `ct_vfdsu_top` | `ct_vfpu_top.v:1675` | **仅 1 个**，除法/开方，挂 pipe6 |
| `ct_vfmau_top` (pipe6) | `ct_vfpu_top.v:1710` | pipe6 的 FMA |
| `ct_vfmau_top` (pipe7) | `ct_vfpu_top.v:1779` | pipe7 的 FMA |

### 1.2 在 C910 流水线中的位置

VFPU 是后端两条执行管线 **pipe6 / pipe7** 的执行体。IDU（发射单元）把读完寄存器堆的浮点/向量指令通过 `idu_vfpu_rf_pipe6_*` / `idu_vfpu_rf_pipe7_*` 一组接口送进来，VFPU 经过若干 EX 级运算后，由 RBUS 把结果写回物理寄存器堆并向 IDU 广播唤醒，由 CBUS 向 RTU（重排序/退休单元）报告指令完成。整数侧（IU）的 MTVR（move-to-vector-register）指令也会在 EX1/EX2 阶段注入 VFPU。

---

## 2. 顶层端口说明

顶层端口众多（`ct_vfpu_top.v:17`-`1038`），按功能分组列举关键组：

| 分组 | 代表信号 | 方向 | 含义 |
|---|---|---|---|
| 时钟/复位/低功耗 | `forever_cpuclk` `cpurst_b` `cp0_vfpu_icg_en` `cp0_yy_clk_en` `pad_yy_icg_scan_en` | in | 自由运行时钟、复位、模块级时钟门控使能、扫描 |
| IDU 发射（pipe6） | `idu_vfpu_rf_pipe6_sel` `_gateclk_sel` `_eu_sel[11:0]` `_func[19:0]` `_srcv0_fr[63:0]` `_srcv1_fr` `_srcv2_fr` `_iid[6:0]` `_dst_vreg/preg/ereg` | in | pipe6 发射有效、门控、执行单元选择、操作码、三源操作数、指令 ID、目的寄存器 |
| IDU 发射（pipe7） | `idu_vfpu_rf_pipe7_*` | in | 同上，pipe7 |
| IU MTVR 注入 | `iu_vfpu_ex1_pipe0_mtvr_vld/_inst[4:0]` `iu_vfpu_ex2_pipe0_mtvr_src0[63:0]`（pipe1 同构） | in | 整数管线向量寄存器写入指令 |
| 向量除法协同 | `vdivu_vfpu_ex1_pipe6_result_vld` `_dst_vreg` `vdivu_vfpu_pipe6_vdiv_busy` | in | 外部整数向量除法单元（vdivu）回灌 pipe6 |
| 唤醒/前递广播 | `vfpu_idu_ex1_pipe6_data_vld_dup*` `_preg_dup*` `_vreg_dup*`（ex1~ex3，pipe6/7） | out | 向 IDU 广播即将写回的物理寄存器，供唤醒与旁路 |
| 完成报告 | `vfpu_rtu_pipe6_cmplt` `_iid[6:0]`（pipe7 同构） | out | 向 RTU 报告完成与指令 ID |
| 控制状态 | `vfpu_idu_vdiv_busy` `vfpu_idu_vdiv_wb_stall` `vfdsu_ifu_debug_*` | out | 除法忙、写回阻塞、调试态 |
| 舍入/异常配置 | `vfpu_yy_xx_rm[2:0]` `vfpu_yy_xx_dqnan` | 内部 | 静态舍入模式、默认 QNaN 配置 |

> 端口规模本身就反映了设计：每条 EX 级、每个 `data_vld` 都做了 `dup0~dup3` 多副本（如 `ct_vfpu_ctrl.v:137`-`139`），这是为缓解写回广播信号的高扇出 / 时序压力而做的人工 buffer 复制。

---

## 3. 参数与关键寄存器

| 名称 | 值 / 宽度 | 出处 | 含义 |
|---|---|---|---|
| `EU_WIDTH` | 12 | `ct_vfpu_ctrl.v:316` | eu_sel 一热码位宽，12 个潜在执行单元槽位 |
| 源操作数宽度 | 64 位 | `ct_vfpu_dp.v:285` `dp_vfalu_ex1_pipe6_srcf0[63:0]` | 单条 lane 的浮点操作数宽度（标量/每 64b slice） |
| VLEN | 128 位 | 由 vfdsu/vfmau 的 slice0+slice1 双套实现，见 §8 | 向量寄存器位宽 |
| `iid` | 7 位 | `ct_vfpu_cbus.v:40` | 重排序 ID |
| eu_sel→ex2 编码 | 5 位 | `ct_vfpu_dp.v:1024`-`1028` | 把 12 位发射 eu_sel 压成 5 位级内单元选择 |

各 EX 级的有效位寄存器集中在 `ct_vfpu_ctrl.v:191`-`242`，按 `ctrl_exN_pipe6/7_inst_vld`、`ctrl_exN_pipe6/7_data_vld` 命名，逐级移位传播。

---

## 4. 两条对称管线 pipe6 / pipe7

VFPU 物理上是两条几乎镜像的管线，分别对应后端发射端口 pipe6 与 pipe7：

- **控制路径**：`ct_vfpu_ctrl.v` 用完全对称的两段代码分别产生 pipe6（`ctrl_ex1_pipe6_*`，`ct_vfpu_ctrl.v:320`-`659`）与 pipe7（`ctrl_ex1_pipe7_*`，`ct_vfpu_ctrl.v:661`-`989`）的逐级有效位。两条都做满 **EX1→EX5** 五级（FMA 需要 5 级，见 §12）。
- **数据路径**：`ct_vfpu_dp.v` 同样镜像地准备 pipe6 / pipe7 的源操作数与结果。

每级有效位都是「上一级有效位 → 本级寄存器」的简单移位，并在 `rtu_yy_xx_flush` 时清零（如 `ct_vfpu_ctrl.v:355`-`358`），保证冲刷时管线立即作废。每级时钟由 `gated_clk_cell` 门控，`local_en` 取「本级或下一级有有效指令」（如 `ct_vfpu_ctrl.v:424`-`427`），无指令时自动停钟省电。

**对称之外的两处不对称**（这是理解 VFPU 的关键）：

1. **fcnvt 只在 pipe7**：pipe6 的 vfalu 只含 fadd+fspu（`ct_vfalu_top_pipe6.v:83`,`104`，第 81 行的 `ct_fcnvt_top` 实例被注释掉），pipe7 的 vfalu 才包含 fcnvt（`ct_vfalu_top_pipe7.v:86`）。
2. **vfdsu（除法/开方）只在 pipe6**：见 §7。

## 5. 四个子执行单元的分工

| 子单元 | 顶层 | 子算子 | 流水级 | 所在管线 |
|---|---|---|---|---|
| **vfalu/fadd** | `ct_fadd_top.v` | 加、减、比较 feq/flt/fle、min/max | EX1→EX3（3 拍） | pipe6+pipe7 |
| **vfalu/fspu** | `ct_fspu_top.v` | fsgnj/fsgnjn/fsgnjx、fmv、fclass | EX1→EX3（3 拍） | pipe6+pipe7 |
| **vfalu/fcnvt** | `ct_fcnvt_top.v` | itof/ftoi/stod/dtos/stoh/htos/dtoh 等类型转换 | EX1→EX3（3 拍） | **仅 pipe7** |
| **vfmau** | `ct_vfmau_top.v` | FMA（乘加）、纯乘法 | EX1→EX5（5 拍） | pipe6+pipe7 |
| **vfdsu** | `ct_vfdsu_top.v` | 除法、开方（SRT 基-16） | 变延迟（见 §12） | **仅 pipe6** |

vfalu 的三个子算子（fadd / fspu / fcnvt）**共用同一条 EX1→EX3 管线**，靠 `dp_vfalu_ex1_pipex_sel[2:0]` 的一热位选择当拍走哪个算子（详见 `02_vfalu.md`）。

## 6. eu_sel 一热码：指令如何分发到子单元

IDU 发射时给出 12 位一热码 `idu_vfpu_rf_pipe6_eu_sel[11:0]`。`ct_vfpu_ctrl.v` 把它锁存到 `ctrl_ex1_pipe6_eu_sel`（`ct_vfpu_ctrl.v:1058`），再由 `ct_vfpu_dp.v` 拆成各子单元的选择信号：

```
dp_vfalu_ex1_pipe6_sel[2:0] = {1'b0, ctrl_ex1_pipe6_eu_sel[1:0]};   // pipe6 仅 fspu/fadd   (ct_vfpu_dp.v:1395)
dp_vfalu_ex1_pipe7_sel[2:0] =       ctrl_ex1_pipe7_eu_sel[2:0];     // pipe7 含 fcnvt        (ct_vfpu_dp.v:1929)
dp_vfdsu_ex1_pipe6_sel      = ctrl_ex1_pipe6_eu_sel[3];             // 除法/开方             (ct_vfpu_dp.v:1402)
dp_vfmau_ex1_pipe6_sel      = ctrl_ex1_pipe6_eu_sel[4];             // FMA                   (ct_vfpu_dp.v:1413)
```

由此得到 eu_sel 的位分配：

| eu_sel 位 | 子单元 |
|---|---|
| [0] | fspu |
| [1] | fadd |
| [2] | fcnvt（仅 pipe7 有效） |
| [3] | vfdsu（除法/开方，仅 pipe6） |
| [4] | vfmau（FMA） |
| [10:5]、[11] | 其它（向量整数等，归入 ex2 5 位编码的 vec 槽，见 `ct_vfpu_dp.v:1025`,`1027`） |

随后 `ct_vfpu_dp.v:1024`-`1028` 把 12 位压成 5 位级内 eu_sel（bit0=vfalu、bit1=fdiv|其它、bit2=fma、bit3=向量、bit4=vfdsu 写回），逐级（ex2→ex3→ex4）随指令下传，用于在结果汇聚阶段选对数据源。

## 7. 不对称性：vfdsu 为何只挂在 pipe6

`ct_vfpu_top.v` 中 `ct_vfdsu_top` **只实例化一次**（`ct_vfpu_top.v:1675`），且其 `dp_vfdsu_ex1_pipex_sel` 接的是 pipe6 的选择（`ct_vfpu_dp.v:1402`，`eu_sel[3]` 取自 pipe6）。pipe7 没有任何 vfdsu 实例。

设计原因（教学要点）：

1. **除法/开方是低频、长延迟、不可流水化的运算**。SRT 迭代是一个占用多拍的状态机（`ct_vfdsu_ctrl.v:184` 的 `srt_cur_state`），一次只能服务一条指令，做成两份纯属面积浪费——浮点除法在真实负载里出现频率远低于加法/乘加。
2. **面积代价高**：SRT 基-16 引擎、bound 查找表（`ct_vfdsu_srt_radix16_bound_table.v`，1168 行）、round/pack 逻辑加起来是 vfdsu 中最大的一块。复制到 pipe7 性价比极低。
3. **调度上由 IDU 保证**：所有 fdiv/fsqrt 指令被 IDU 统一发往 pipe6（配合 `vfpu_idu_vdiv_busy`/`vfpu_idu_vdiv_wb_stall` 反压，`ct_vfpu_dp.v:1446`-`1447`），因此功能上无需 pipe7 也有除法器。

代价是 pipe7 流水更"纯净"（只有定长 3/5 拍单元），调度更简单；而 pipe6 要额外处理 vfdsu 变延迟指令对写回端口的占用——这正是 `pipe6_dp_vfdsu_inst_vld`、`dp_ctrl_pipe6_vfdsu_inst_vld` 这些只出现在 pipe6 控制路径里的信号的来源（`ct_vfpu_ctrl.v:426`,`622`,`645`）。

## 8. VLEN128 与浮点/向量共享寄存器

C910 向量寄存器宽度 **VLEN=128 位**。但每个浮点算子的核心数据通路是 64 位 lane。VFPU 用「两套 64 位 slice 拼成 128 位」来覆盖向量宽度，这在 vfdsu 与 vfmau 里看得最清楚：

- **vfdsu**：`ct_vfdsu_top.v` 把 128 位源拆成 **set0（低 64 位）+ set1（高 64 位）**，每个 set 内再按精度切分：double 用整 64 位（`ct_vfdsu_top.v:148` `ex1_src0[63:0]`、`:189` `ex1_src0[127:64]`），single 用 [63:32]/[31:0] 各一份，half（FP16）切成 4 个 16 位片（如 `ex1_src0[31:16]`、`[63:48]`，`ct_vfdsu_top.v:158`,`178`）。整片合计 2 set ×（1 double / 2 single / 4 half）。
- **vfmau**：full 路按 64 位 slice（`dp_mult1_ex1_op0_slice0[63:0]`），half（FP16）走独立的 16 位 SIMD 数据（`pipe6_vfmau_ex4_fmla_slice0_half0_data[15:0]`，`ct_vfmau_top.v:240`）。

"浮点与向量共享寄存器"指的是：标量浮点指令与向量浮点指令使用同一个物理向量寄存器堆（VREG），标量只占用 lane0。VFPU 内部不区分两者的数据通路——区别只在 `dp_xx_ex1_simd` 等控制位决定 SIMD 的多 lane 是否同时激活。

## 9. CBUS / RBUS 双轨写回

VFPU 的"写回"被拆成两条独立总线，各管一件事：

### CBUS —— 完成总线（早报完成）

`ct_vfpu_cbus.v` 在**发射当拍**就把完成信号锁存一拍送给 RTU：

```
cbus_pipe6_cmplt = idu_vfpu_rf_pipe6_sel;          // 发射即视为"将完成"  (ct_vfpu_cbus.v:118)
vfpu_rtu_pipe6_cmplt = cbus_pipe6_inst_vld;        // 锁一拍后报 RTU       (ct_vfpu_cbus.v:134)
cbus_pipe6_iid <= idu_vfpu_rf_pipe6_iid;           // 同时带回 iid        (ct_vfpu_cbus.v:166)
```

为什么能"提前"报完成？因为这些定长单元（fadd/fmau 等）一旦进入流水就保证不会再阻塞，RTU 据此可以提前安排退休，缩短指令在 ROB 里的停留。注意 CBUS 不处理 vfdsu——变延迟的除法不能在发射拍就承诺完成。

### RBUS —— 结果总线（真正写数据）

`ct_vfpu_rbus.v` 负责把各 EU 在各 EX 级算出的结果写回物理寄存器堆，并向 IDU 广播唤醒/前递：

- 输入来自各级数据：vfalu 的 EX3（`dp_ex3_pipe6_freg_data`，`ct_vfpu_rbus.v:51`）、vfmau 的 EX4/EX5（`pipe6_rbus_vfmau_freg_wb_data`，`:104`）、vfdsu 的写回。
- 输出物理寄存器写回 + `vfpu_idu_ex*_pipe*_data_vld_dup*`/`_preg_dup*`/`_vreg_dup*` 广播（`ct_vfpu_rbus.v:171`+），供 IDU 唤醒等待该结果的后续指令、并支持旁路前递。

两轨分离的好处：完成（控制面，给 RTU）与数据写回（数据面，给 RF/IDU）时序与扇出特性差异大，分开做让各自时序更好优化，也让变延迟的 vfdsu 能独立申请写回端口（`vfdsu_dp_inst_wb_req`，`ct_vfdsu_ctrl.v:508`）而不影响定长指令的完成上报。

## 10. MTVR 注入旁路

MTVR（move-to-vector-register，把整数/标量值写进向量寄存器）由整数管线 IU 发起，但写的是向量寄存器堆，因此必须借道 VFPU 写回。VFPU 给它开了一条**绕过正常 IDU 发射**的注入路径：

- EX1 注入有效位：`iu_vfpu_ex1_pipe0_mtvr_vld`（`ct_vfpu_ctrl.v:327`），它直接参与 `ctrl_ex1_pipe6_inst_vld_pre`（`ct_vfpu_ctrl.v:415`-`416`）与 data_vld（`:405`），即 MTVR 与正常发射"或"在一起进入流水。
- eu_sel 由 MTVR 指令类型现造：`pipe6_mtvr_eu_sel`（`ct_vfpu_ctrl.v:1037`-`1040`）按 `iu_vfpu_ex1_pipe0_mtvr_inst` 的位选择走 fspu（bit0）还是 vfmau 广播（bit7）。
- EX2 才送来真正的数据 `iu_vfpu_ex2_pipe0_mtvr_src0[63:0]`（`ct_vfpu_dp.v:1398` 接到 vfalu 的 mtvr_src0），即 MTVR 的源数据比指令晚一拍到达——这是与 IU 流水对齐的结果。

`ct_vfpu_dp.v:1455`-`1460` 还为 MTVR 现造了 func 编码区分 half/single/double/move-to-element/copy-to-all 五种形态。

## 11. 完整数据流

以三条代表性指令在 pipe6 上的旅程说明端到端流程：

**(a) `vfadd`（加法，走 fadd）**
1. IDU：`idu_vfpu_rf_pipe6_sel=1`、`eu_sel[1]=1`、送 srcf0/1。
2. EX1：ctrl 锁存 inst_vld（`ct_vfpu_ctrl.v:358`）；dp 把 sel 给 `dp_vfalu_ex1_pipe6_sel[1]=1`；fadd 的 `ex1_pipedown=sel[1]`（`ct_fadd_ctrl.v:62`）启动。
3. EX2、EX3：fadd 内部 `ex2_pipedown`/`ex3_pipedown` 逐拍推进（`ct_fadd_ctrl.v:94`,`152`）。
4. EX3 末：结果 `pipex_dp_ex3_vfalu_freg_data` → RBUS 写回 VREG，并广播唤醒。
5. 发射拍 CBUS 已向 RTU 报完成。**总延迟 3 拍。**

**(b) `vfmacc`（乘加，走 vfmau）**
1. IDU：`eu_sel[4]=1`，送三源（含被加数 srcv2）。
2. EX1→EX5：vfmau 内部 5 级（`ct_vfmau_ctrl.v` 的 `ctrl_ex2..ex5_inst_vld`，`:165`-`311`），EX4 出乘加结果、EX5 出最终 FMA 结果与前递（`ct_vfmau_top.v:241` `..ex5_fmla_slice0_data[67:0]`）。
3. EX5：`ctrl_dp_ex5_fma_wb_vld`（`ct_vfmau_ctrl.v:339`）置位 → RBUS 写回。**总延迟 5 拍。**

**(c) `vfdiv`（除法，走 vfdsu，仅 pipe6）**
1. IDU：`eu_sel[3]=1`，触发 `dp_vfdsu_idu_fdiv_issue`（`ct_vfpu_dp.v:1408`）。
2. div 写回状态机 IDLE→RF→EX1（`ct_vfdsu_ctrl.v:410`-`419`）：EX1 `ex1_pipedown` 启动 SRT 状态机（`:151`,`200`）。
3. EX2：SRT 迭代，`srt_cnt` 从初值递减（`:229`-`248`），直到 `srt_last_round`（`:222`）。
4. 之后 EX3（round）→EX4（pack）→WB_REQ→WB，`pipex_dp_vfdsu_inst_vld`（`:506`）有效时把结果经 pipe6 EX5 槽送入 RBUS。**变延迟，见 §12。**

## 12. 各运算延迟与流水级总表

| 运算 | 子单元 | 流水级 | 延迟（拍） | 关键出处 |
|---|---|---|---|---|
| 加/减/比较/min/max | fadd | EX1→EX3 | **3** | `ct_fadd_ctrl.v:62`,`94`,`152` |
| fsgnj/fmv/fclass | fspu | EX1→EX3 | **3** | `ct_fspu_ctrl.v:60`,`92`,`124` |
| 类型转换 | fcnvt | EX1→EX3 | **3** | `ct_fcnvt_ctrl.v:58`,`87`,`119` |
| FMA / 乘法 | vfmau | EX1→EX5 | **5** | `ct_vfmau_ctrl.v:169`,`214`,`258`,`311` |
| FDIV double | vfdsu | 变延迟 | **约 18** | srt_cnt_ini=13，见下 |
| FDIV single | vfdsu | 变延迟 | **约 11** | srt_cnt_ini=6 |
| FDIV half | vfdsu | 变延迟 | **约 8** | srt_cnt_ini=3 |
| FSQRT | vfdsu | 变延迟 | 比 FDIV 多（需 2 轮） | `srt_secd_round`，见 `04_vfdsu.md` |

vfdsu 的迭代轮数由 `srt_cnt_ini` 决定（`ct_vfdsu_ctrl.v:246`-`248`）：

```
srt_cnt_ini = double ? 5'b01101 (13)
            : single ? 5'b00110 (6)
            :          5'b00011 (3)   // half
```

加上 prepare(EX1) / round(EX3) / pack(EX4) / 写回握手等固定开销，得到上表的总拍数。`skip_srt`（被除数特殊或商提前确定）与 `srt_ctrl_rem_zero`（余数为零）可让 `srt_last_round` 提前置位（`ct_vfdsu_ctrl.v:222`），从而**变延迟提前结束**。开方因为需要先求出试根再修正，需要 `srt_secd_round`（`ct_vfdsu_ctrl.v:275`-`280`）二轮，故比同精度除法多若干拍。

---

## 设计取舍小结

1. **对称双管线（pipe6/pipe7）+ 两处不对称（fcnvt 只 pipe7、vfdsu 只 pipe6）**：吞吐与面积的折中。高频运算（加/乘加）双份保证两发射端口都能跑满；低频高成本运算（转换、除法）单份省面积，由 IDU 调度兜底。
2. **vfalu 三算子共用一条 3 级流水**：fadd/fspu/fcnvt 流水深度相同、互斥使用，共用 EX1→EX3 寄存器与门控，比各做一套省面积。
3. **CBUS/RBUS 双轨**：完成上报（控制面，早报）与数据写回（数据面）解耦，时序更好，且让变延迟的 vfdsu 不拖累定长指令的退休。
4. **门控时钟无处不在**：每级、每总线都用 `gated_clk_cell`，`local_en` 取"本级或下级有效"，空闲即停钟。
5. **大量 `_dup` 信号**：写回广播信号高扇出，靠人工复制分担负载——以少量面积换时序收敛。
6. **VLEN128 = 2×64b slice 拼接**：复用成熟的 64 位浮点 lane，向量化只是多激活 slice/half 子片，避免重做 128 位宽数据通路。

## 覆盖声明

本文覆盖 VFPU 顶层架构、两条管线、四子单元分工、eu_sel 分发、双轨写回、MTVR 注入、VLEN128 切分与各运算延迟。各子单元内部实现细节见同目录 `01_vfpu_top.md` ~ `04_vfdsu.md`。所有流水级数、延迟拍数、`srt_cnt_ini` 值（13/6/3）、SIMD 切分宽度均直接引自上述 RTL 行号，未作推测性补全；其中 `ct_vfdsu_ctrl.v:244`-`245` 的注释（28/14）为历史遗留注释，**实际生效值以 `:246`-`248` 的 assign（13/6/3）为准**。
