# C910 VFPU vfalu（fadd / fspu / fcnvt）模块详细教学文档

> RTL 目录：`C910_RTL_FACTORY/gen_rtl/vfalu/rtl/`
> 核心文件：
> - `ct_vfalu_top_pipe6.v`（141 行，fadd+fspu）/ `ct_vfalu_top_pipe7.v`（166 行，fadd+fspu+fcnvt）
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
  - [1.2 三算子共用一条 3 级流水](#12-三算子共用一条-3-级流水)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. EX1→EX3 三级流水机制](#4-ex1ex3-三级流水机制)
- [5. dp_vfalu_ex1_pipex_sel：子算子一热选择](#5-dp_vfalu_ex1_pipex_sel子算子一热选择)
- [6. fadd：加 / 减 / 比较 / min / max](#6-fadd加--减--比较--min--max)
- [7. fspu：fsgnj / fmv / fclass](#7-fspufsgnj--fmv--fclass)
- [8. fcnvt：类型转换（仅 pipe7）](#8-fcnvt类型转换仅-pipe7)
- [9. 半精度 SIMD 路与 set0/set1 切分](#9-半精度-simd-路与-set0set1-切分)
- [10. ex3_pipedown 写回汇聚](#10-ex3_pipedown-写回汇聚)
- [设计取舍小结](#设计取舍小结)
- [覆盖声明](#覆盖声明)

---

## 1. 模块概述

### 1.1 vfalu 是什么

vfalu（Vector / Floating-point Arithmetic & Logic Unit）是 VFPU 中负责**定长 3 拍浮点运算**的子单元集合，包含三个互斥的子算子：

| 子算子 | 顶层 | 负责的指令 |
|---|---|---|
| **fadd** | `ct_fadd_top.v` | 浮点加 `fadd`、减 `fsub`、比较 `feq/flt/fle/fne/ford`、`fmin/fmax`（minnm/maxnm） |
| **fspu** | `ct_fspu_top.v` | 符号注入 `fsgnj/fsgnjn/fsgnjx`、寄存器搬移 `fmv.x.f / fmv.f.x`、分类 `fclass` |
| **fcnvt** | `ct_fcnvt_top.v` | 浮点/整数与不同浮点宽度间的类型转换（itof/ftoi/stod/dtos/stoh/htos 等）|

vfalu 在 VFPU 顶层被实例化两份：`ct_vfalu_top_pipe6`（只含 fadd+fspu）与 `ct_vfalu_top_pipe7`（含 fadd+fspu+**fcnvt**）。pipe6 的 `ct_fcnvt_top` 实例被注释掉（`ct_vfalu_top_pipe6.v:81`），fcnvt 仅在 pipe7 实例化（`ct_vfalu_top_pipe7.v:86`）——这是 VFPU 两处不对称之一（详见 `00_vfpu_overview.md` §7）。

### 1.2 三算子共用一条 3 级流水

三个子算子的运算延迟都是 **3 拍（EX1→EX3）**，且任一拍最多只有一个子算子被激活。它们各自有一份完全相同结构的 ctrl（`ct_fadd_ctrl` / `ct_fspu_ctrl` / `ct_fcnvt_ctrl`），但都接收同一个三位一热选择信号 `dp_vfalu_ex1_pipex_sel[2:0]`，靠不同位决定自己是否启动。三者的结果在 EX3 末由 `ct_vfalu_dp_pipe7`/`pipe6` 汇聚成一个 `pipex_dp_ex3_vfalu_freg_data[63:0]` 写回。

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
| 源操作数/结果宽度 | 64 位 | `ct_fadd_top.v:42` | 单 lane 浮点宽度 |
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

**EX3（再传播）**：`ex2_pipedown` 经 `ex2_vld_clk` 锁存为 `ex3_pipedown`（`ct_fadd_ctrl.v:144`-`158`）。`ex3_pipedown` 即「本拍 EX3 有 fadd 结果可写回」。

**门控时钟**：每级一个 `gated_clk_cell`。`local_en` 取「本级或下一级有有效指令」，例如：
- `ex1_vld_clk_en = ex1_pipedown || ex2_pipedown`（`ct_fadd_ctrl.v:85`）
- `ex2_vld_clk_en = ex2_pipedown || ex3_pipedown`（`ct_fadd_ctrl.v:143`）
- 另有一条 `ex1_pipe_clk`（仅 fadd 有，`ct_fadd_ctrl.v:104`-`121`，`local_en=ex1_pipedown`）驱动 EX1 数据通路锁存。

空闲时这些时钟全部停摆，子算子不耗动态功耗——这是 vfalu 面积/功耗友好的根基。注意 vfalu 的 ctrl **没有 flush 清零逻辑**（不像 vfmau/vfpu 顶层），因为 3 拍定长、且上层 vfpu ctrl 已用有效位把冲刷的结果丢弃，子算子内部即使「跑完」也无副作用。

---

## 5. dp_vfalu_ex1_pipex_sel：子算子一热选择

VFPU 顶层 dp 把发射 eu_sel 拆成 vfalu 的三位一热（`00_vfpu_overview.md` §6）：

- pipe6：`dp_vfalu_ex1_pipe6_sel[2:0] = {1'b0, eu_sel[1:0]}` —— bit2 恒 0，因 pipe6 无 fcnvt。
- pipe7：`dp_vfalu_ex1_pipe7_sel[2:0] = eu_sel[2:0]` —— bit2 才可能为 fcnvt。

三个子算子分别只看自己那一位（§4）。因为是一热码，任一拍至多一个子算子的 `ex1_pipedown` 为 1，三条 3 级流水实际共享时间槽——这就是「三算子共用 EX1→EX3」的物理含义：它们各有寄存器，但永不同拍激活，互斥复用写回端口。

---

## 6. fadd：加 / 减 / 比较 / min / max

fadd 由 `ct_fadd_scalar_dp`（控制译码 + 标量数据）+ 多份 `ct_fadd_double_dp`/`ct_fadd_single_dp`/`ct_fadd_half_dp`（按精度/lane 的数据通路）组成（`ct_fadd_top.v:211`-`369`）。

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

**三级分工**：
- EX1：对阶/比较的前置准备（比较类指令的结果在 EX1 即产生，见 `ex1_doub_cmp_result`，`ct_fadd_top.v:233`，故比较走 mfvr 通路可早一拍）。
- EX2：尾数对齐相加/相减、舍入模式展开（`ex2_rm_rne/rtz/rdn/rup/rmm`，`ct_fadd_top.v:90`-`94`）。
- EX3：规格化、舍入、异常打包，输出 `ex3_result[63:0]` + `ex3_expt[4:0]`（`ct_fadd_top.v:96`-`98`）。

延迟：**EX1→EX3，3 拍**（`ct_fadd_ctrl.v:62`,`94`,`152`）。`fadd_mfvr_cmp_result` 是比较/搬移结果送往 mfvr（move-from-vector-register）通路，在 EX1 即有效，供整数侧读取浮点比较结果。

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

**为什么非拆两路不可**：单路实现既要支持大对齐移位（far 需要）、又要支持大规格化移位（close 需要），
还得等加法完才能数前导零——关键路径极长、上不了高频。拆两路后**各自只做一种大移位**、且 close 路
用 LZA 把"数零"与加法**并行**——**两条短路径取代一条长路径**，这是浮点加法器能跑高频的根本
（经典 FP adder 设计，见 H&P 附录 J / 浮点单元微架构）。

**为什么有 `close_s0/s1` 与 `_d/_h` 之分**：fadd 顶层把 close/far 通路都例化两份
`x_set0_*` / `x_set1_*`（两条 SIMD lane，见 §9），且双精度走 `*_double_dp`、半精度走 `*_half_dp`。
于是同一套 close/far 逻辑按 **lane × 精度** 复制出 `close_s0_d`/`close_s1_d`（双精度两 lane）、
`close_s0_h`/`close_s1_h`（半精度两 lane）、`onehot_sel_d`/`onehot_sel_h`——**结构复用、只是宽度/lane 不同**。

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

延迟同样 **3 拍**（`ct_fspu_ctrl.v:60`,`92`,`124`）；`fspu_mfvr_data[63:0]` 在 mfvr 通路输出（fmv.x.f / fclass 的结果给整数侧读）。

---

## 8. fcnvt：类型转换（仅 pipe7）

fcnvt（`ct_fcnvt_top.v`）= `ct_fcnvt_ctrl` + `ct_fcnvt_scalar_dp` + 按精度的 `ct_fcnvt_double_dp` 等（`ct_fcnvt_top.v:148`-`244`）。它只有一个源 `srcf0`。其控制信号体现了"源类型 × 目的类型"的笛卡尔积：

- 源类型：`ex1_src_double/single/float/si`、`ex1_src_l16/l32/l64`（`ct_fcnvt_top.v:68`-`74`）。
- 目的类型：`ex2_dest_double/single/half/float/si`、`ex2_dest_l8/l16/l32/l64`（`ct_fcnvt_top.v:76`-`84`）。
- 方向标志：`ex1_widden`（窄→宽，如 stod）、`ex1_narrow`（宽→窄，如 dtos）。

对应的专用子单元（在 `ct_fcnvt_top.v` 顶部注释列出的实例规则）：`ct_fcnvt_itof_sh.v`（整数→浮点）、`ct_fcnvt_ftoi_sh.v`（浮点→整数）、`ct_fcnvt_stod_sh.v`（单→双）、`ct_fcnvt_dtos_sh.v`（双→单）、`ct_fcnvt_stoh_sh.v`/`htos_sh.v`（单↔半）、`ct_fcnvt_dtoh_sh.v`（双→半）。

延迟 **3 拍**（`ct_fcnvt_ctrl.v:58`,`87`,`119`）。fcnvt 之所以只放 pipe7，是因为类型转换是相对低频运算，单份即可，复制到 pipe6 不划算（`00_vfpu_overview.md` §7）。`ct_fcnvt_ctrl.v:125`-`142` 处大段被注释掉的 `ex*_simd_pipedown` 说明早期版本曾为 fcnvt 设计独立 SIMD 流水，最终未启用——现版 SIMD 走 set0/set1 多份数据通路（§9）。

---

## 9. 半精度 SIMD 路与 set0/set1 切分

vfalu 用「**两套 set（set0=低 64b，set1=高 64b）× 每 set 内多份精度数据通路**」覆盖 VLEN=128 的向量。以 fadd 为例（`ct_fadd_top.v:116`-`199` 的 `&Instance` 规则）：

| 实例命名 | 精度/lane | 处理的数据片 |
|---|---|---|
| `x_set0_ct_fadd_double_dp` | 双精度 | set0 整 64b |
| `x_set0_ct_fadd_single_dp` | 单精度 | set0 内 1 个 32b（×2 lane）|
| `x_set0_ct_fadd_doub_half_dp` / `half0_dp` / `half1_dp` | 半精度 FP16 | set0 内 4 个 16b 片 |
| `x_set1_*` | 同上 | set1（高 64b）|

半精度（FP16）走专门的 `ct_fadd_half_dp.v`，每个 64b set 切成 4 个 16 位 lane，两 set 合计 **8 个 FP16 lane**，正好填满 128 位向量。fcnvt 同理（`ct_fcnvt_top.v:103`-`146` 的 set0/set1 × half0/half1 实例）。

标量浮点指令只激活 set0 的对应精度通路（`ex1_scalar` 在标量实例上接 `1'b1`，如 `ct_fadd_top.v:301`、`ct_fcnvt_top.v:218`），其余 lane 停钟。这就是「浮点与向量共享数据通路」的实现——标量是 SIMD 的退化情形，只用 lane0。

**fspu 与 fcnvt 的精度/方向变体**：同样的"按精度分通路"也贯穿 fspu 和 fcnvt——
- **fspu**（比较 / 符号注入 / 分类）有 `ct_fspu_double.v` / `ct_fspu_single.v` / `ct_fspu_half.v`
  三份精度数据通路，分别处理 f64 / f32 / f16：比较、min/max、fclass 在不同精度下尾数/指数位宽不同，
  故各精度独立成路。
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

汇聚后的 `pipex_dp_ex3_vfalu_freg_data` 经 VFPU 顶层送入 RBUS 写回 VREG（`01_vfpu_top.md` §7）。pipe6 版（`ct_vfalu_dp_pipe6.v`）少了 fcnvt 那一路。

---

## 设计取舍小结

1. **三算子共用 EX1→EX3 定长 3 级**：fadd/fspu/fcnvt 流水深度相同、靠一热码互斥激活，共享时间槽与写回端口；各自只有 2 个 1-bit 有效寄存器，控制极轻。
2. **fcnvt 只放 pipe7**：类型转换低频，单份省面积；pipe6 把它的 sel bit2 恒置 0。
3. **fspu 端口最精简**：位操作无需舍入/异常，省掉 rm 与大部分 ereg 逻辑。
4. **set0/set1 × 精度多实例覆盖 VLEN128**：复用成熟 64b lane，FP16 走专用 16b half_dp，每 64b set 拆 4 lane；标量是只激活 lane0 的退化 SIMD。
5. **比较/搬移走 mfvr 早出通路**：EX1 即产生结果，缩短整数侧等待。
6. **门控时钟逐级 + 无 flush**：3 拍短流水靠上层有效位丢弃冲刷结果，子单元内部无需自带 flush。

## 覆盖声明

本文覆盖 vfalu 三子算子（fadd/fspu/fcnvt）的 EX1→EX3 三级流水、`dp_vfalu_ex1_pipex_sel` 一热分发、各 op 的 func 译码、半精度 set0/set1 SIMD 切分与 ex3_pipedown 三选一写回汇聚。所有流水级数（均 3 拍）、信号名与行号均直接引自上述 RTL，未作推测。vfalu 在 VFPU 顶层的接线见 `01_vfpu_top.md` §8，整体定位见 `00_vfpu_overview.md`。
