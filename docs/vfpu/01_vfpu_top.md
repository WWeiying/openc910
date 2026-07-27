# C910 VFPU 顶层（top/ctrl/dp/cbus/rbus）模块详细教学文档

> RTL 文件：
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_top.v`（1854 行）
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_ctrl.v`（1092 行）
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_dp.v`（2139 行）
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_cbus.v`（236 行）
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_rbus.v`（1474 行）

---

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 顶层职责](#11-顶层职责)
  - [1.2 五个组件的分工](#12-五个组件的分工)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. ctrl：流水级有效位与门控时钟](#4-ctrl流水级有效位与门控时钟)
- [5. dp：源操作数准备与 eu_sel 译码](#5-dp源操作数准备与-eu_sel-译码)
- [6. cbus：完成总线](#6-cbus完成总线)
- [7. rbus：结果总线与唤醒广播](#7-rbus结果总线与唤醒广播)
- [8. 管线分发与子单元接线](#8-管线分发与子单元接线)
- [设计取舍小结](#设计取舍小结)
- [覆盖声明](#覆盖声明)

---

## 1. 模块概述

### 1.1 顶层职责

`ct_vfpu_top`（`ct_vfpu_top.v:17`）是 VFPU 的封装层，本身几乎不含运算逻辑，主要做三件事：

1. 实例化控制核 `ct_vfpu_ctrl`、数据核 `ct_vfpu_dp`、完成总线 `ct_vfpu_cbus`、结果总线 `ct_vfpu_rbus`；
2. 实例化各子执行单元（vfalu_pipe6/7、vfmau_pipe6/7、vfdsu）；
3. 用大量 wire 把 ctrl 产生的有效位/门控、dp 产生的源操作数，分发到各子单元，再把子单元结果汇回 dp/rbus。

### 1.2 五个组件的分工

| 组件 | 文件 | 一句话 |
|---|---|---|
| ctrl | `ct_vfpu_ctrl.v` | 产生每条管线每个 EX 级的 `inst_vld`/`data_vld`/`eu_sel`/门控时钟 |
| dp | `ct_vfpu_dp.v` | 准备源操作数、按 eu_sel 分发、收集各 EU 结果到写回前级 |
| cbus | `ct_vfpu_cbus.v` | 发射当拍向 RTU 报完成与 iid |
| rbus | `ct_vfpu_rbus.v` | 把各级结果写回 VREG/PREG，向 IDU 广播唤醒/前递 |
| 子单元 | vfalu/vfmau/vfdsu | 真正的运算 |

---

## 2. 端口说明

顶层端口已在 `00_vfpu_overview.md` §2 分组列出，此处补充各内部组件的核心接口。

**ctrl 的端口分组**（`ct_vfpu_ctrl.v:15`-`101`）：

| 分组 | 信号 | 方向 |
|---|---|---|
| 输入：发射选择 | `idu_vfpu_rf_pipe6_sel` `_gateclk_sel` `_eu_sel[11:0]` | in |
| 输入：MTVR | `iu_vfpu_ex1_pipe0_mtvr_vld` `_inst[4:0]`（pipe1 同构） | in |
| 输入：vfdsu 回灌 | `pipe6_dp_vfdsu_inst_vld` `dp_ctrl_pipe6_vfdsu_inst_vld` `vdivu_vfpu_ex1_pipe6_result_vld` | in |
| 输入：dp 数据有效预报 | `dp_ctrl_exN_pipe6/7_data_vld_pre` `_fwd_vld_pre` | in |
| 输出：逐级有效位 | `ctrl_exN_pipe6/7_inst_vld` `_data_vld(_dupX)` `_mfvr_inst_vld(_dupX)` `_fwd_vld` | out |
| 输出：级选择 | `ctrl_ex1_pipe6/7_eu_sel[11:0]` | out |
| 输出：门控时钟 | `ctrl_ex5_pipe6/7_clk` | out |

**cbus 的端口**（`ct_vfpu_cbus.v:15`-`32`）：仅 `idu_vfpu_rf_pipe6/7_sel`/`_gateclk_sel`/`_iid` 入，`vfpu_rtu_pipe6/7_cmplt`/`_iid` 出。

---

## 3. 参数与关键寄存器

| 名称 | 值/宽度 | 出处 |
|---|---|---|
| `EU_WIDTH` | 12 | `ct_vfpu_ctrl.v:316` |
| ctrl 逐级有效位寄存器 | 1 bit ×（5 级 × 2 管线 ×{inst,data,mfvr,fwd}+dup） | `ct_vfpu_ctrl.v:191`-`242` |
| `ctrl_ex1_pipe6/7_eu_sel_tmp` | 12 bit | `ct_vfpu_ctrl.v:195`,`206` |
| cbus 完成寄存器 | `cbus_pipe6/7_inst_vld` 1b、`cbus_pipe6/7_iid` 7b | `ct_vfpu_cbus.v:53`-`56` |

---

## 4. ctrl：流水级有效位与门控时钟

ctrl 的核心是「逐级移位的有效位 + 逐级门控时钟」。

**(a) EX1 有效位的三种来源**（`ct_vfpu_ctrl.v:411`-`416`）：

```verilog
// EX1 inst can from:
// 1. RF normal pipedown   (正常发射)
// 2. mtvr inst from pipe0 EX1 stage  (整数侧 MTVR 注入)
// 3. vmul replay at EX1    (乘法重放)
assign ctrl_ex1_pipe6_inst_vld_pre = idu_vfpu_rf_pipe6_sel
                                  || iu_vfpu_ex1_pipe0_mtvr_vld;
```

**(b) 逐级移位**：EX2 取 EX1，EX3 取 EX2……以 pipe6 为例（`ct_vfpu_ctrl.v:459`-`461`,`525`,`601`,`656`），每级都在 `rtu_yy_xx_flush` 时清零。

**(c) pipe6 独有的 vfdsu 注入点**：EX2 使能含 `pipe6_dp_vfdsu_inst_vld` 与 `vdivu_vfpu_ex1_pipe6_result_vld`（`ct_vfpu_ctrl.v:424`-`427`、`459`-`461`），EX5 使能含 `dp_ctrl_pipe6_vfdsu_inst_vld`（`:621`-`623`,`644`-`645`）。pipe7 完全没有这些——这是 §00 §7 不对称性在控制路径里的直接体现。

**(d) 门控时钟**：每级一个 `gated_clk_cell`，`local_en` = 本级或下级有有效指令（如 EX2：`ct_vfpu_ctrl.v:424`-`427`）。无指令则停钟。

**(e) eu_sel 锁存**：`pipe6_eu_sel` 在 MTVR 时取现造的 `pipe6_mtvr_eu_sel`，否则取发射 eu_sel（`ct_vfpu_ctrl.v:1042`-`1043`），锁进 `ctrl_ex1_pipe6_eu_sel_tmp`，再与 inst_vld 相与输出（`:1058`）。

## 5. dp：源操作数准备与 eu_sel 译码

dp 把 IDU 送的 `srcv0/1/2_fr[63:0]` 锁存为各级操作数，并完成两件关键译码：

**(a) 12 位 eu_sel → 5 位级内 eu_sel**（`ct_vfpu_dp.v:1024`-`1028`，pipe6）：

```verilog
dp_ex2_pipe6_eu_sel_pre[0] = |ctrl_ex1_pipe6_eu_sel[2:0];                       // vfalu (fspu/fadd/fcnvt)
dp_ex2_pipe6_eu_sel_pre[1] = ctrl_ex1_pipe6_eu_sel[3] || ctrl_ex1_pipe6_eu_sel[11]; // fdiv / 其它
dp_ex2_pipe6_eu_sel_pre[2] = ctrl_ex1_pipe6_eu_sel[4];                          // fma
dp_ex2_pipe6_eu_sel_pre[3] = |ctrl_ex1_pipe6_eu_sel[10:5];                      // 向量整数
dp_ex2_pipe6_eu_sel_pre[4] = pipe6_dp_vfdsu_inst_vld || vdivu_vfpu_ex1_pipe6_result_vld; // vfdsu/vdiv 写回
```

这个 5 位编码随指令逐级（ex2→ex3→ex4，`ct_vfpu_dp.v:1090`,`1195`,`1331`）下传，用于在写回汇聚时选对结果源。

**(b) 子单元分发**（`ct_vfpu_dp.v:1390`-`1421`）：见 `00_vfpu_overview.md` §6 表。pipe6 的 vfalu sel 为 `{1'b0, eu_sel[1:0]}`（无 fcnvt 位），pipe7 为 `eu_sel[2:0]`（含 fcnvt）。

**(c) 数据有效预报**（`ct_vfpu_dp.v:1426`-`1428`）：dp 比 ctrl 早一拍算出各级 data_vld_pre 给 ctrl 锁存，`ready_stage` 决定该指令在第几级出结果（fadd/fcnvt 在 EX3，fmau 在 EX4/EX5）。

**(d) 除法忙/写回阻塞汇聚**（`ct_vfpu_dp.v:1446`-`1447`）：

```verilog
vfpu_idu_vdiv_wb_stall = vdivu_vfpu_pipe6_req_for_bubble || vfdsu_dp_inst_wb_req;
vfpu_idu_vdiv_busy     = vdivu_vfpu_pipe6_vdiv_busy || vfdsu_dp_fdiv_busy;
```

把整数向量除法（vdivu）与浮点除法（vfdsu）的忙信号合并后回报 IDU，IDU 据此停止再向 pipe6 发除法类指令。

## 6. cbus：完成总线

cbus 极简（236 行）。核心逻辑（`ct_vfpu_cbus.v:118`-`172`）：

```verilog
cbus_pipe6_cmplt         = idu_vfpu_rf_pipe6_sel;          // 发射即"将完成"
// 锁一拍
cbus_pipe6_inst_vld <= cbus_pipe6_cmplt;                   // (flush 清零, :128)
vfpu_rtu_pipe6_cmplt = cbus_pipe6_inst_vld;                // 报 RTU
// iid 单独用门控数据时钟锁存
cbus_pipe6_iid <= idu_vfpu_rf_pipe6_iid;                   // (:166)
```

要点：
- **早报完成**：定长单元一进流水就保证完成，故发射拍即可承诺，缩短 ROB 占用。
- **iid 用独立数据门控时钟**（`vfpu_pipe6_data_clk`，`:139`-`149`）只在确有完成时翻转，省功耗。
- **不含 vfdsu**：变延迟除法不能提前承诺，其完成走另一条路（vfdsu 自己的写回状态机 + rbus）。

## 7. rbus：结果总线与唤醒广播

rbus（1474 行）是写回数据面的核心，输入端汇集所有 EU 在所有可能写回级的结果：

| 输入来源 | 信号 | 出处 |
|---|---|---|
| vfalu EX3 浮点结果 | `dp_ex3_pipe6/7_freg_data` | `ct_vfpu_rbus.v:51`,`53` |
| EX5 浮点/异常结果（FMA） | `dp_ex5_pipe6/7_freg_data_pre` `_ereg_data_pre` | `:62`-`65` |
| vfmau 写回 | `pipe6/7_rbus_vfmau_freg_wb_data` `_vreg_wb_vld` `_ereg_wb_*` | `:102`-`119` |
| 写回目的寄存器（各级 vreg/dup） | `dp_rbus_pipe6_exN_vreg(_dupX)` | `:66`-`89` |
| 完成有效位 | `ctrl_exN_pipe6/7_data_vld(_dupX)` `_fwd_vld` | `:19`-`47` |

输出端做两件事：
1. **写回物理寄存器堆**：浮点结果（freg）、异常标志（ereg）、目的寄存器号一起送出。
2. **向 IDU 广播唤醒/前递**：`vfpu_idu_exN_pipe6/7_data_vld_dup*` / `_preg_dup*` / `_vreg_dup*`（`ct_vfpu_rbus.v:171`+）。下游依赖指令据此被唤醒，并可在结果尚未落 RF 时直接旁路。

rbus 之所以大，是因为它要在**多个 EX 级 × 两条管线 × 多个 dup 副本**之间做选择与扇出——是整个 VFPU 里布线/时序最密的一块，因此 freg_data、vreg、data_vld 全部 dup 化。

## 8. 管线分发与子单元接线

顶层把上述组件接到子单元（`ct_vfpu_top.v:1630`-`1845`）：

- `ct_vfalu_top_pipe6`（`:1631`）：接 `dp_vfalu_ex1_pipe6_*`，回 `pipex_dp_ex3_vfalu_freg_data`。
- `ct_vfalu_top_pipe7`（`:1653`）：含 fcnvt，接 pipe7 信号。
- `ct_vfdsu_top`（`:1675`）：**唯一一个**，接 pipe6 的 `dp_vfdsu_ex1_pipe6_*` 与 `dp_vfdsu_fdiv_*`。
- `ct_vfmau_top_pipe6`/`_pipe7`（`:1710`,`:1779`）：各接对应管线的 mult 操作数与 mla 信息。

`eu_sel` 是分发的总开关：ctrl 锁存它、dp 拆它、各子单元 ctrl（如 `ct_fadd_ctrl.v:62`）再用 `dp_vfalu_ex1_pipex_sel[1]` 决定自己是否启动。

---

## 设计取舍小结

1. **顶层只做封装与布线**，运算下沉到子单元——便于复用同一 vfmau/vfalu 模块在两条管线实例化。
2. **ctrl 与 dp 分离**：控制（有效位/门控）与数据（操作数/结果）解耦，dp 的 data_vld_pre 比 ctrl 早一拍，使时序更宽松。
3. **cbus/rbus 双轨**：完成（早、给 RTU）与写回（数据、给 RF/IDU）分开，详见 `00` §9。
4. **dup 化**：把高扇出的写回广播信号人工复制，换时序收敛。
5. **eu_sel 两级压缩**（12→5）：发射时用宽一热码便于 IDU 译码，级内用窄码省寄存器与比较逻辑。

## 覆盖声明

本文覆盖 VFPU 顶层五组件（top/ctrl/dp/cbus/rbus）的职责、端口、有效位流水、eu_sel 两级译码、完成与结果双轨写回及子单元接线。子单元内部运算见 `02_vfalu.md`/`03_vfmau.md`/`04_vfdsu.md`。所有信号名与行号均引自上述 RTL，未作推测。
