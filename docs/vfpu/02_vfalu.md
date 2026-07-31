# C910 VFPU vfalu（fadd / fspu / fcnvt）模块详细教学文档

> RTL 目录：`C910_RTL_FACTORY/gen_rtl/vfalu/rtl/`
> 核心文件：
> - `ct_vfalu_top_pipe6.v`（140 行，fadd+fspu）/ `ct_vfalu_top_pipe7.v`（166 行，fadd+fspu+fcnvt）
> - `ct_fadd_ctrl.v`（164 行）/ `ct_fadd_top.v`（379 行）/ `ct_fadd_scalar_dp.v` / `ct_fadd_double_dp.v` / `ct_fadd_half_dp.v`；
>   close 路：`ct_fadd_close_s0_d/s1_d/s0_h/s1_h.v` + `ct_fadd_onehot_sel_d/_h.v`（数据通路详见 §6.5）
> - `ct_fspu_ctrl.v`（133 行）/ `ct_fspu_top.v`（106 行）/ `ct_fspu_dp.v` / 精度通路 `ct_fspu_double/single/half.v`（见 §9）
> - `ct_fcnvt_ctrl.v`（147 行）/ `ct_fcnvt_top.v`（252 行）/ `ct_fcnvt_scalar_dp.v` / `ct_fcnvt_double_dp.v` /
>   方向移位器 `ct_fcnvt_{dtos,stod,dtoh,htos,stoh,ftoi,itof}_sh.v`（见 §9）
> - `ct_vfalu_dp_pipe6.v` / `ct_vfalu_dp_pipe7.v`（EX3 写回汇聚）

---

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 vfalu 是什么](#11-vfalu-是什么)
- [1.2 三算子共享发射时隙与 EX3 汇聚](#12-三算子共享发射时隙与-ex3-汇聚)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. EX1→EX3 三级流水机制](#4-ex1ex3-三级流水机制)
- [5. dp_vfalu_ex1_pipex_sel：子算子一热选择](#5-dp_vfalu_ex1_pipex_sel子算子一热选择)
- [6. fadd：加 / 减 / 比较 / min / max](#6-fadd加--减--比较--min--max)
- [7. fspu：fsgnj / fmv / fclass](#7-fspufsgnj--fmv--fclass)
- [8. fcnvt：类型转换（仅 pipe7）](#8-fcnvt类型转换仅-pipe7)
- [9. 当前标量实例与保留的 SIMD 生成模板](#9-当前标量实例与保留的-simd-生成模板)
- [10. ex3_pipedown 写回汇聚](#10-ex3_pipedown-写回汇聚)
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 vfalu 是什么

vfalu（Vector / Floating-point Arithmetic & Logic Unit）是 VFPU 中采用
EX1~EX3 结构协议的浮点算术/逻辑子单元集合。这里“EX1~EX3”首先描述内部级名；
若把它换算成从 IDU 接收、前递、物理寄存器写回或退休之间的周期数，必须另行
声明起点和终点。

| 子算子 | 顶层 | 负责的指令 |
|---|---|---|
| **fadd** | `ct_fadd_top.v` | 浮点加 `fadd`、减 `fsub`、标量比较 `feq/flt/fle`、`fmin/fmax`；数据通路还保留向量比较使用的 `fne/ford` 内部操作码 |
| **fspu** | `ct_fspu_top.v` | 符号注入 `fsgnj/fsgnjn/fsgnjx`、寄存器搬移 `fmv.x.f / fmv.f.x`、分类 `fclass` |
| **fcnvt** | `ct_fcnvt_top.v` | 浮点/整数与不同浮点宽度间的类型转换（itof/ftoi/stod/dtos/stoh/htos 等）|

vfalu 在 VFPU 顶层被实例化两份：`ct_vfalu_top_pipe6`（只含 fadd+fspu）与 `ct_vfalu_top_pipe7`（含 fadd+fspu+**fcnvt**）。pipe6 的 `ct_fcnvt_top` 实例被注释掉（`ct_vfalu_top_pipe6.v:81`），fcnvt 仅在 pipe7 实例化（`ct_vfalu_top_pipe7.v:86`）——这是 VFPU 两条入口不对称的一部分（详见 `00_vfpu_overview.md` §4）。

### 1.2 三算子共享发射时隙与 EX3 汇聚

三个子算子分别实例化自己的 ctrl 和数据通路，并不是三种运算复用同一组内部
流水寄存器。它们接收同一个三位选择向量的不同位，正常译码下一次只启动一个，
并在 EX3 由 `ct_vfalu_dp_pipe7`/`pipe6` 汇聚为一个 64 位结果。

因此，“共享”的准确含义是：共享同一个发射时隙约束、同一个 VFALU 结果汇聚点
和后续写回资源；“独立”的准确含义是：fadd、fspu、fcnvt 各自保留控制和运算
逻辑。不能写成“三种算子物理共用一条算术流水”。

当前发布配置只启用 64 位标量浮点路径。各文件前半段的 set0/set1、多 single/
half lane `&Instance` 行均已被注释；它们是生成模板痕迹，不是当前 Verilog 中
正在工作的实例。

---

## 2. 端口说明

vfalu 各子单元顶层的端口高度一致（`ct_fadd_top.v:15`-`33`、`ct_fspu_top.v:18`-`32`、`ct_fcnvt_top.v:15`-`31`），按功能分组：

| 分组 | 代表信号 | 方向 | 含义 |
|---|---|---|---|
| 时钟/复位/低功耗 | `forever_cpuclk` `cpurst_b` `cp0_vfpu_icg_en` `cp0_yy_clk_en` `pad_yy_icg_scan_en` | in | 自由时钟、复位、模块时钟门控使能、扫描使能 |
| 子算子选择 | `dp_vfalu_ex1_pipex_sel[2:0]` | in | 一热码：bit0=fspu、bit1=fadd、bit2=fcnvt |
| 操作码 | `dp_vfalu_ex1_pipex_func[19:0]` | in | 译出加/减/比较/转换类型等 |
| 源操作数 | `dp_vfalu_ex1_pipex_srcf0/1[63:0]` `_imm0[2:0]` | in | 两源 64b lane + 立即数 |
| MTVR 源 | `dp_vfalu_ex1_pipex_mtvr_src0[63:0]`（仅 fspu） | in | 整数侧 MTVR 注入的数据 |
| 舍入/QNaN 配置 | `vfpu_yy_xx_rm[2:0]` `vfpu_yy_xx_dqnan` | in | 静态舍入模式、默认 QNaN |
| EX3 结果（前递） | `fadd_forward_result[63:0]` `fadd_forward_r_vld` `fadd_ereg_ex3_result[4:0]`（fspu/fcnvt 同构） | out | 各子算子 EX3 浮点结果 + 异常标志 + 有效位 |
| mfvr 结果 | `fadd_mfvr_cmp_result[63:0]` `fspu_mfvr_data[63:0]` | out | 比较结果/搬移结果送 EX1 mfvr 通路 |

> fcnvt 顶层没有 `srcf1`/`mtvr_src0`（只有一个源操作数 `srcf0`，`ct_fcnvt_top.v:22`），fspu 没有 `vfpu_yy_xx_rm`（符号/搬移/分类不需要舍入）。这种端口差异本身就反映了三类运算的语义。

---

## 3. 参数与关键寄存器

| 名称 | 值/宽度 | 出处 | 含义 |
|---|---|---|---|
| `dp_vfalu_ex1_pipex_sel` | 3 位一热 | `ct_fadd_ctrl.v:32` | 子算子选择 |
| `ex2_pipedown` / `ex3_pipedown` | 各 1 bit reg | `ct_fadd_ctrl.v:41`-`42` | 逐级有效位（每子算子各一套） |
| 源操作数/结果宽度 | 64 位 | `ct_fadd_top.v:42` | 当前有效标量数据路径宽度 |
| ereg（异常）宽度 | 5 位 | `ct_fadd_top.v:49` `fadd_ereg_ex3_result[4:0]` | NV/DZ/OF/UF/NX 五个浮点异常标志 |
| func 宽度 | 20 位 | `ct_fadd_top.v:39` | 操作码 |

各子算子只有 `ex2_pipedown`、`ex3_pipedown` 两个 1-bit 有效寄存器，是整个 VFPU 里最轻量的控制；真正的数据流水寄存器在各 `*_dp` 文件里（用门控时钟 `ex1_pipe_clk` 等驱动）。

---

## 4. EX1→EX3 三级流水机制

三个 ctrl 文件结构完全相同，以 `ct_fadd_ctrl.v` 为例讲清三级流水：

**EX1（启动）**：`ex1_pipedown` 是纯组合，直接等于子算子选择位（`ct_fadd_ctrl.v:62`）：

```verilog
assign ex1_pipedown = dp_vfalu_ex1_pipex_sel[1];   // fadd 取 bit1
```

fspu 取 `[0]`（`ct_fspu_ctrl.v:60`），fcnvt 取 `[2]`（`ct_fcnvt_ctrl.v:58`）。该信号同拍驱动 `*_scalar_dp` 锁存源操作数并做 EX1 运算（如 fadd 的比较已在 EX1 算出 `ex1_doub_cmp_result`，`ct_fadd_top.v:233`）。

**EX2（传播）**：`ex1_pipedown` 经门控时钟 `ex1_vld_clk` 锁存为 `ex2_pipedown`（`ct_fadd_ctrl.v:86`-`100`）：

```verilog
always @(posedge ex1_vld_clk or negedge cpurst_b)
  if(!cpurst_b)        ex2_pipedown <= 1'b0;
  else if(ex1_pipedown) ex2_pipedown <= 1'b1;
  else                  ex2_pipedown <= 1'b0;
```

**EX3（再传播）**：`ex2_pipedown` 经 `ex2_vld_clk` 锁存为
`ex3_pipedown`（`ct_fadd_ctrl.v:144`-`158`）。它表示该子模块的 EX3 结果
周期有效，随后还要经过 VFALU 汇聚和 VFPU 顶层/RBus 控制；不能把这个局部
有效位单独解释为物理寄存器已写回或指令已退休。

**门控时钟**：每级一个 `gated_clk_cell`。`local_en` 取「本级或下一级有有效指令」，例如：
- `ex1_vld_clk_en = ex1_pipedown || ex2_pipedown`（`ct_fadd_ctrl.v:85`）
- `ex2_vld_clk_en = ex2_pipedown || ex3_pipedown`（`ct_fadd_ctrl.v:143`）
- fadd 的 ctrl 还导出一条 `ex1_pipe_clk`（`ct_fadd_ctrl.v:104`-`121`，
  `local_en=ex1_pipedown`）给部分 EX1 数据寄存器；但这不表示只有 fadd 有
  数据时钟。fadd 的 double/half 数据通路、`ct_fspu_dp` 以及 fcnvt 的
  scalar/double 数据通路也各自在本模块内实例化按 `ex1_pipedown` 开启的
  `x_ex1_pipe_clk`。控制有效位时钟和各数据块的局部门控时钟必须分开追踪。

当本地有效位为空时，`local_en` 可以撤销开钟请求；最终门控仍受
`global_en`、`module_en` 和扫描使能影响，因而不能写成“所有模式下时钟都停”
或“完全没有动态功耗”。

vfalu 的三个局部 ctrl **没有 `rtu_yy_xx_flush` 端口**。被冲刷的局部
`pipedown` 或数据可能继续传播到 EX3；顶层 VFPU/RBus 的 flush 后有效控制负责
阻止其作为有效体系结构结果写回。准确说法是“体系结构可见的有效性在上层被
取消”，而不是“子单元内部立即清空”或未经逐条输出核对便断言“没有任何内部
活动”。

---

## 5. dp_vfalu_ex1_pipex_sel：子算子一热选择

VFPU 顶层 dp 把发射 eu_sel 拆成 vfalu 的三位一热（`00_vfpu_overview.md` §5）：

- pipe6：`dp_vfalu_ex1_pipe6_sel[2:0] = {1'b0, eu_sel[1:0]}` —— bit2 恒 0，因 pipe6 无 fcnvt。
- pipe7：`dp_vfalu_ex1_pipe7_sel[2:0] = eu_sel[2:0]` —— bit2 才可能为 fcnvt。

三个子算子分别只看自己那一位（§4）。正常 IDU 译码应提供一热选择，使它们
互斥复用汇聚/写回时隙。`ct_vfalu_dp_pipe*` 的结果 mux 对 0 热或多热组合进入
default 并输出 `X`，它依赖上游协议，而不是在本模块内检测并纠正非法一热码。

---

## 6. fadd：加 / 减 / 比较 / min / max

当前 fadd 由 `ct_fadd_ctrl`、`ct_fadd_scalar_dp`、一个
`ct_fadd_double_dp` 和一个 `ct_fadd_half_dp` 组成
（`ct_fadd_top.v:211`-`369`）。`ct_fadd_double_dp` 同时接收
`ex1_double/ex1_single`，`ct_fadd_half_dp` 处理标量 half 路径；两者的
`ex1_scalar` 都接常量 1。文件前面的多 set/lane 例化规则是注释，不应计入当前
实例数量。

**op 译码**（`ct_fadd_scalar_dp.v:227`-`237`）从 func 直接取位：

```verilog
assign func[19:0]   = dp_vfalu_ex1_pipex_func[19:0];
assign ex1_double   = func[16];   // 双精度
assign ex1_single   = func[15];   // 单精度
assign ex1_op_add   = func[12];
assign ex1_op_sub   = func[11];
assign ex1_op_cmp   = func[10];   // feq/flt/fle 比较
assign ex1_op_maxnm = func[9];
assign ex1_op_minnm = func[8];
```

比较子操作还使用 `func[4:0]`：`func[0]`、`[1]`、`[2]` 分别选择
`feq`、`flt`、`fle`，`func[3]`、`[4]` 则选择内部 `ford`、`fne`。
这里必须区分“算术数据通路支持的内部操作码”和“当前软件可发出的标量指令”。
前三种由当前标量浮点译码产生；后两种对应 RF 译码中保留的
`vford/vfne` 向量比较路径。由于 `ct_idu_id_decd.v` 把 `x_vec_inst`
固定为 0，后两种内部比较码在当前发布配置下不可由合法向量指令到达，不能列作
当前标量 RISC-V 浮点指令能力。

**三级分工**：
- EX1：对阶/比较的前置准备（比较类指令的结果在 EX1 即产生，见 `ex1_doub_cmp_result`，`ct_fadd_top.v:233`，故比较走 mfvr 通路可早一拍）。
- EX2：尾数对齐相加/相减、舍入模式展开（`ex2_rm_rne/rtz/rdn/rup/rmm`，`ct_fadd_top.v:90`-`94`）。
- EX3：规格化、舍入、异常打包，输出 `ex3_result[63:0]` + `ex3_expt[4:0]`（`ct_fadd_top.v:96`-`98`）。

结构路径为 **EX1→EX2→EX3**（`ct_fadd_ctrl.v:62`,`94`,`152`）。
`fadd_mfvr_cmp_result` 是比较类结果进入 MFVR 汇聚的早出数据；“早出”表示它
不必等待普通 EX3 浮点结果路径，不表示同拍已经完成整数物理寄存器写回。

---

## 6.5 fadd 数据通路内部：close / far 双路浮点加法器

前面讲的是 fadd 的控制与流水；这里钻进**数据通路**，看浮点加法在硬件里到底怎么算——
这是浮点单元最经典、也最值得掌握的一处设计。

**根本难题**：两个浮点数相加/减时，指数**可能差很大、也可能几乎相等**，这两种情形对硬件的
要求恰好相反。业界标准解法是把加法拆成 **far（远）路** 和 **close（近）路** 两条并行通路，
各自优化，最后按指数差选一条。C910 的 fadd 正是这个设计。

**far 路（指数差 > 1）**：小指数的尾数**大幅右移对齐** → 相加 → **最多 1 位规格化**。
因为一个数远大于另一个，结果不会大量抵消，规格化移位很小。RTL：`fadd_ex2_far_adder0/1`
（`ct_fadd_double_dp.v`）。

**close 路（指数差 ≤ 1 的有效减法）**：小对齐 → 相减 → **可能大量抵消** → **大幅左移规格化**。
两个数量级相近做减法时，高位会大片抵消（catastrophic cancellation），结果可能只剩低几位有效，
要左移很多位重新规格化。两个难点：
- **不知道 a−b 还是 b−a 为正** → close 路**同时算两个方向**：`close_sum_a_b` 与 `close_sum_b_a`
  （`ct_fadd_close_s0_d.v`），用 `close_op_chg` 选为正的那个，`close_eq` 处理两数相等（结果 0）。
- **规格化要左移多少位？** 用**前导零预测（LZA）**得到一个 one-hot 位置，再由
  `ct_fadd_onehot_sel_d.v` 把它转成移位量（`fadd_ex2_close_ff1` / `_onehot`）——**与加法并行预测、
  不等加完再数零**，这是 close 路收时序的关键。

**两路选择**：`fadd_ex2_close_sel`（`ct_fadd_double_dp.v`）按指数差挑 close 还是 far 的结果。

**为什么采用双路**：若用一条通路同时覆盖大幅右移对阶和抵消后的大幅左移
规格化，组合逻辑通常更复杂；close/far 分路让两类数值情形分别优化，LZA 又使
前导零预测与尾数运算部分并行。这通常有利于缩短关键组合路径，但“缩短了多少”
和“是否为芯片主关键路径”必须由综合与时序报告确认，不能由 RTL 结构单独量化。

**`close_s0/s1` 不应解释成向量 set0/set1**：当前
`ct_fadd_double_dp` 内部确实实例化 `ct_fadd_close_s0_d` 和多个
`ct_fadd_close_s1_d`，half 路也有对应 `_h` 模块；但这些名称属于 close
算法内部的不同候选/路径，不是 `ct_fadd_top` 注释模板中的 128 位向量
set0/set1。`_d/_h` 反映 double-family 与 half 宽度实现差异。判断“实例还是
模板”应看是否存在未注释的模块例化，而不能只按名称猜测。

---

## 7. fspu：fsgnj / fmv / fclass

fspu（`ct_fspu_top.v`）结构最简：`ct_fspu_ctrl` + `ct_fspu_dp`（`ct_fspu_top.v:71`,`84`）。其 op 从 func 译出（`ct_fspu_dp.v:138`-`156`）：

```verilog
assign ex1_op_fsgnjx = func[6] && func[2];   // 符号异或
assign ex1_op_fsgnjn = func[6] && func[1];   // 符号取反注入
assign ex1_op_fsgnj  = func[6] && func[0];   // 符号注入
assign ex1_op_fmvfx  = func[5] && func[0];   // 整数→浮点搬移
assign ex1_op_fmvxf  = func[5] && func[2];   // 浮点→整数搬移
assign ex1_op_class  = func[18];             // fclass 分类
```

这些操作语义上都是「按位操作」，不需要算术运算与舍入（故 fspu 顶层无 `vfpu_yy_xx_rm`）：
- **fsgnj 系列**：取 src0 的尾数/阶码，符号位取 src1 的符号（或其取反/异或）。
- **fmv**：整数与浮点位模式直接搬移；fmvfx 还会接 `dp_vfalu_ex1_pipex_mtvr_src0`（MTVR 注入数据，`ct_fspu_top.v:89`）。
- **fclass**：把浮点数分类成 10 类（±0/±inf/±normal/±subnormal/sNaN/qNaN），结果是一热位掩码（`set0_doub_result_fclass`，`ct_fspu_dp.v:109`）。

其局部有效协议同样经过 EX1~EX3
（`ct_fspu_ctrl.v:60`,`92`,`124`）；`fspu_mfvr_data[63:0]` 是 MFVR 汇聚的
数据源。该信号本身没有携带最终整数写回完成语义。

---

## 8. fcnvt：类型转换（仅 pipe7）

fcnvt（`ct_fcnvt_top.v`）= `ct_fcnvt_ctrl` + `ct_fcnvt_scalar_dp` + 按精度的 `ct_fcnvt_double_dp` 等（`ct_fcnvt_top.v:148`-`244`）。它只有一个源 `srcf0`。其控制信号体现了"源类型 × 目的类型"的笛卡尔积：

- 源类型：`ex1_src_double/single/float/si`、`ex1_src_l16/l32/l64`（`ct_fcnvt_top.v:68`-`74`）。
- 目的类型：`ex2_dest_double/single/half/float/si`、`ex2_dest_l8/l16/l32/l64`（`ct_fcnvt_top.v:76`-`84`）。
- 方向标志：`ex1_widden`（窄→宽，如 stod）、`ex1_narrow`（宽→窄，如 dtos）。

对应的专用子单元（在 `ct_fcnvt_top.v` 顶部注释列出的实例规则）：`ct_fcnvt_itof_sh.v`（整数→浮点）、`ct_fcnvt_ftoi_sh.v`（浮点→整数）、`ct_fcnvt_stod_sh.v`（单→双）、`ct_fcnvt_dtos_sh.v`（双→单）、`ct_fcnvt_stoh_sh.v`/`htos_sh.v`（单↔半）、`ct_fcnvt_dtoh_sh.v`（双→半）。

其局部有效协议经过 EX1~EX3
（`ct_fcnvt_ctrl.v:58`,`87`,`119`）。当前 RTL 能直接证明的是：fcnvt 只在
pipe7 实例化，pipe6 将选择 bit2 屏蔽。将其解释为面积和常见指令频率之间的
折中是合理的体系结构推断，但“转换一定低频、复制一定不划算”仍需负载统计和
综合结果，不能写成 RTL 已证明的事实。

`ct_fcnvt_ctrl.v` 中注释掉的 SIMD pipedown，以及 `ct_fcnvt_top.v` 前半段的
set0/set1 多实例规则，都是未进入当前有效实例的模板；当前实际实例只有
`ct_fcnvt_scalar_dp` 和一个 `ct_fcnvt_double_dp`，后者的
`ex1_scalar` 固定为 1。

---

## 9. 当前标量实例与保留的 SIMD 生成模板

阅读生成 RTL 时，要把“注释中的目标结构”和“生成后的有效结构”分开：

| 文件 | 注释模板描述 | 当前未注释实例 |
|---|---|---|
| `ct_fadd_top.v` | set0/set1、多 single/half lane | scalar_dp + 1 个 double_dp + 1 个 half_dp |
| `ct_fspu_dp.v` | set0/set1、多 single/half lane | set0 的 double、single0、half0，各自标量模式 |
| `ct_fcnvt_top.v` | set0/set1、多精度转换实例 | scalar_dp + 1 个 double_dp，`ex1_scalar=1` |

因此当前硬件支持标量 f64/f32/f16 的相关路径，但不能由这些文件得出“每拍并行
处理 8 个 FP16 lane”或“两个 64 位 set 构成 VLEN128”的结论。模板本身仍有
教学价值：它展示了生成器曾计划如何复制 lane；只是不能混入当前面积、吞吐或
波形预期。

**fspu 与 fcnvt 的精度/方向变体**：同样的"按精度分通路"也贯穿 fspu 和 fcnvt——
- **fspu**（符号注入 / 搬移 / 分类）有 `ct_fspu_double.v` /
  `ct_fspu_single.v` / `ct_fspu_half.v` 三份当前标量精度通路，分别处理
  f64/f32/f16 的字段抽取、符号组合和分类。浮点数值比较、min/max 属于 fadd，
  不属于 fspu。
- **fcnvt**（类型转换）按"转换方向"拆成一组移位器 `ct_fcnvt_*_sh.v`：`dtos`（双→单）、`stod`（单→双）、
  `dtoh`（双→半）、`htos`（半→单）、`stoh`（单→半）、`ftoi`（浮→整）、`itof`（整→浮）。**每种转换的
  对齐/舍入移位规律不同，做成独立小模块各管一种方向**——"一种方向一个移位器"让每个模块只处理一条
  规格化路径，逻辑简单、易验证（典型的"分而治之"硬件组织）。

---

## 10. ex3_pipedown 写回汇聚

三个子算子的 EX3 结果在 `ct_vfalu_dp_pipe7.v`（pipe6 用精简版 `ct_vfalu_dp_pipe6.v`）做一次三选一汇聚。核心三段（`ct_vfalu_dp_pipe7.v:77`-`100`）：

**(a) 浮点结果三选一**（按各子算子的 `forward_r_vld` 一热选择）：

```verilog
case({fadd_forward_r_vld,fcnvt_forward_r_vld,fspu_forward_r_vld})
  3'b100  : pipex_dp_ex3_vfalu_freg_data = fadd_forward_result;
  3'b010  : pipex_dp_ex3_vfalu_freg_data = fcnvt_forward_result;
  3'b001  : pipex_dp_ex3_vfalu_freg_data = fspu_forward_result;
  default : pipex_dp_ex3_vfalu_freg_data = {64{1'bx}};
endcase
```

`*_forward_r_vld` 来自各子算子 EX3（由 `ex3_pipedown` 派生），因互斥所以只会有一位为 1。

**(b) 异常标志汇聚**（`ct_vfalu_dp_pipe7.v:77`）：只有 fadd 和 fcnvt 产生异常（fspu 的位操作不产生 IEEE 异常）：

```verilog
pipex_dp_ex3_vfalu_ereg_data = {5{fadd_ereg_ex3_forward_r_vld}} & fadd_ereg_ex3_result
                             | {5{fcnvt_ereg_forward_r_vld}}    & fcnvt_ereg_forward_result;
```

**(c) mfvr 通路（EX1 早出）**（`ct_vfalu_dp_pipe7.v:79`）：比较/搬移结果在 EX1 即按 sel 选出，供整数侧 move-from-vector 读取：

```verilog
pipex_dp_ex1_vfalu_mfvr_data = {64{sel[1]}} & fadd_mfvr_cmp_result
                             | {64{sel[0]}} & fspu_mfvr_data;
```

汇聚后的 `pipex_dp_ex3_vfalu_freg_data` 送入 VFPU 顶层和 RBus。当前目的编码
最高位为 0 时走 64 位浮点物理寄存器写回；向量 VR 写有效固定为 0。pipe6 版
少了 fcnvt 那一路。

---

## 本章小结

VFALU 用统一的 EX1~EX3 局部协议接纳三类性质不同的操作，但并没有把它们物理
合并成同一个算术体。fadd、fspu 和 fcnvt 各自保存控制和数据通路，一热选择保证
同一发射时隙只启动其中一路，EX3 再把结果、异常和有效信号汇聚到 VFPU 顶层。
fadd 通过 close/far 双路覆盖近指数抵消和远指数对阶两类数值情形，比较结果还能
从 EX1 的 MFVR 通路早出；fspu 只做符号、分类和位模式搬移，因此不需要舍入和
浮点异常数据通路；fcnvt 处理源类型到目的类型的规格化、移位和舍入，只在 pipe7
实例化。这样的组织同时保持了各算法的数据通路独立性和后端接口的一致性。

当前有效实例是使用 64 位容器的标量 f64/f32/f16 多精度路径。set0/set1 和多
single/half lane 只存在于生成器注释，不能计入当前 VLEN、实例数或并行吞吐。
三个局部 ctrl 都没有直接接收全局 flush，短流水内部可能继续传播已进入的数据；
VFPU 顶层和 RBus 通过清除有效控制阻止被冲刷结果成为体系结构可见写回。因此
EX1~EX3 只描述局部结构级，从 IDU 接收、消费者前递、物理寄存器写回到 ROB
退休的完整延迟仍需沿顶层控制逐段计算。
