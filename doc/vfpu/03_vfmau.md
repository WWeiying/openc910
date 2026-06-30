# C910 VFPU vfmau（FMA 乘加 / 乘法器 / 压缩树 / LZA）模块详细教学文档

> RTL 目录：`C910_RTL_FACTORY/gen_rtl/vfmau/rtl/`
> 核心文件：
> - `ct_vfmau_top.v`（560 行，顶层封装）
> - `ct_vfmau_ctrl.v`（344 行，EX1→EX5 五级有效位 + pipedown + 写回有效）
> - `ct_vfmau_dp.v`（数据准备 + 写回汇聚）
> - `ct_vfmau_mult1.v`（3171 行，整 64b lane 乘加核：Booth/压缩树/LZA/规格化/舍入）
> - `ct_vfmau_mult_compressor.v`（部分积压缩树）/ `ct_vfmau_lza.v`（730 行，前导零预测）
> - `ct_vfmau_mult_simd_half.v` / `ct_vfmau_lza_simd_half.v`（半精度 SIMD 独立通路）
> - `ct_vfmau_ff1_10bit.v` / `ct_vfmau_lza_42.v` / `ct_vfmau_lza_32.v`（小位宽辅助）

---

## 目录

- [1. 模块概述](#1-模块概述)
  - [1.1 vfmau 是什么](#11-vfmau-是什么)
  - [1.2 为什么 FMA 要 5 级流水](#12-为什么-fma-要-5-级流水)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. EX1→EX5 五级流水机制](#4-ex1ex5-五级流水机制)
- [5. 乘法器 ct_vfmau_mult1：Booth + 压缩树](#5-乘法器-ct_vfmau_mult1booth--压缩树)
- [6. LZA：前导零预测与规格化](#6-lza前导零预测与规格化)
- [7. 半精度独立 pipedown 与 SIMD 通路](#7-半精度独立-pipedown-与-simd-通路)
- [8. ctrl_dp_ex5_fma_wb_vld 写回](#8-ctrl_dp_ex5_fma_wb_vld-写回)
- [9. 前递（fwd）网络](#9-前递fwd网络)
- [设计取舍小结](#设计取舍小结)
- [覆盖声明](#覆盖声明)

---

## 1. 模块概述

### 1.1 vfmau 是什么

vfmau（Vector / Floating-point Multiply-Add Unit）负责所有**浮点乘加（FMA）与纯乘法**：`vfmacc/vfmadd/vfnmacc/vfmsac/...` 以及 `vfmul`。它在 VFPU 顶层被实例化两份（pipe6 与 pipe7，`ct_vfpu_top.v:1710`,`1779`），是两条管线都满配的高频单元。

每份 vfmau 的核心是一个整 64b lane 的乘加核 `ct_vfmau_mult1`（slice0）；向量 128 位由 slice0+slice1 两份覆盖（顶层注释 `ct_vfmau_top.v:444`-`461` 描述 slice0/slice1 的实例规则，slice1 受 `dp_xx_exN_simd` 门控只在向量时激活）。半精度（FP16）另有专门的 `ct_vfmau_mult_simd_half` 通路（§7）。

### 1.2 为什么 FMA 要 5 级流水

`a*b + c` 的浮点 FMA 是 VFPU 里运算链最长的操作，需要：①生成部分积（Booth 编码）；②压缩树把部分积压成两路（sum/carry）；③与被加数 c 对阶并 3:2 进位保留相加；④前导零预测（LZA）+ 规格化大移位；⑤舍入 + 异常打包。把这 5 步切成 5 级，每级一拍，才能在高频下流水化、且支持每拍发射一条新 FMA。因此 vfmau 是 **EX1→EX5，定长 5 拍**（`ct_vfmau_ctrl.v` 逐级有效位 `:169`,`214`,`258`,`311`）。

---

## 2. 端口说明

`ct_vfmau_top` 端口（`ct_vfmau_top.v:17`-`81`）分组：

| 分组 | 代表信号 | 方向 | 含义 |
|---|---|---|---|
| 时钟/复位/低功耗 | `forever_cpuclk` `cpurst_b` `cp0_vfpu_icg_en` `cp0_yy_clk_en` `pad_yy_icg_scan_en` `rtu_yy_xx_flush` | in | 含冲刷 |
| 发射/选择 | `dp_vfmau_ex1_pipex_sel` `dp_vfmau_rf_pipex_sel` `dp_vfmau_pipex_inst_type[5:0]` `dp_vfmau_pipex_vfmau_sel` | in | 本拍是否发 FMA、指令类型 |
| 源操作数 | `idu_vfpu_rf_pipex_srcv0/1/2_fr[63:0]` `idu_vfpu_rf_pipex_func[19:0]` | in | 三源（含被加数 srcv2）+ 操作码 |
| mla 被加数信息 | `dp_vfmau_pipe6/7_mla_srcv2_vld` `_srcv2_vreg[6:0]` `_mla_type[2:0]` | in | 乘加被加数寄存器与类型 |
| 目的寄存器 | `dp_vfmau_ex1_pipex_dst_vreg[6:0]` `_imm0[2:0]` | in | 写回目标 |
| 跨管线前递输入 | `pipe6/7_pipex_ex4_fmla_fwd_vld` `_ex5_ex1/ex2_fmla_fwd_vld` `pipe6/7_vfmau_ex4_fmla_slice0_half0_data[15:0]` `_ex5_fmla_slice0_data[67:0]` | in | 另一管线 EX4/EX5 前递数据 |
| 写回 RBUS | `pipex_rbus_vfmau_freg_wb_data[63:0]` `_vreg_wb_vld` `_ereg_wb_data[4:0]` `_ereg_wb_vld` | out | 物理寄存器写回 |
| 写回给 dp | `pipex_dp_ex3_vfmau_freg_data[63:0]`（纯乘法早出）`pipex_dp_ex4_vfmau_freg_data` | out | EX3/EX4 结果 |
| 前递广播 | `pipex_rbus_ex1/ex2_fmla_data_vld(_dup0..2)` `pipex_pipe6/7_ex4/ex5_*_fmla_fwd_vld` `pipex_vfmau_ex4_fmla_slice0_half0_data[15:0]` `_ex5_fmla_slice0_data[67:0]` | out | 唤醒/旁路广播（含 dup 副本） |

> 注意 fwd 数据宽度：full 路 EX5 前递是 **68 位**（`[67:0]`，比 64 位多 4 位携带未舍入低位/守护位），half0 路 EX4 前递是 **16 位**（FP16）。这两个宽度直接体现了 full / half 两条独立数据通路。

---

## 3. 参数与关键寄存器

| 名称 | 值/宽度 | 出处 | 含义 |
|---|---|---|---|
| 流水级数 | 5（EX1→EX5） | `ct_vfmau_ctrl.v:81`-`85` | 5 个有效位 reg |
| `ctrl_ex2..ex5_inst_vld` | 各 1 bit reg | `ct_vfmau_ctrl.v:81`-`85` | 逐级有效位 |
| `ctrl_ex5_fma_wb_vld` | 1 bit reg | `ct_vfmau_ctrl.v:84` | EX5 写回有效 |
| 尾数宽度 | 52 位 | `ct_vfmau_top.v:194` `dp_xx_ex1_op0_frac[51:0]` | double 尾数 |
| 压缩树进位/和 | 106 位 | `ct_vfmau_mult1.v:290`-`291` `compressor_mult1_carry/sum[105:0]` | 部分积压缩输出 |
| LZA 加数/被加数 | 108 位 | `ct_vfmau_mult1.v:538`-`539` `mult1_ex3_lza_addend/summand[107:0]` | 前导零预测输入 |
| LZA 结果 | 7 位 | `ct_vfmau_lza.v:28` `lza_result[6:0]` | 预测的前导零数（移位量） |
| full 前递数据 | 68 位 | `ct_vfmau_top.v:111` `ex5_fmla_slice0_data[67:0]` | 含守护位 |
| half 前递数据 | 16 位 | `ct_vfmau_top.v:110` `ex4_fmla_slice0_half0_data[15:0]` | FP16 |

---

## 4. EX1→EX5 五级流水机制

`ct_vfmau_ctrl` 是一条「逐级移位有效位 + 逐级门控时钟 + 逐级 pipedown 使能」的标准流水控制。

**EX1 启动**（`ct_vfmau_ctrl.v:132`-`134`）：

```verilog
assign mult1_ex1_ex2_pipedown     = dp_vfmau_ex1_pipex_sel && !dp_xx_ex1_half;  // full 路
assign mult_ex1_ex2_half_pipedown = dp_vfmau_ex1_pipex_sel &&  dp_xx_ex1_half;  // half 路
assign ctrl_ex1_inst_vld          = dp_vfmau_ex1_pipex_sel;
```

注意从 EX1 起就把 full（`mult1_*`）与 half（`mult_*half*`）拆成两套 pipedown——这是半精度独立通路的起点（§7）。

**逐级有效位移位**（每级一个门控 + 一个 reg，含 flush 清零）：
- EX2：`ctrl_ex2_inst_vld <= dp_vfmau_ex1_pipex_sel`（`ct_vfmau_ctrl.v:162`-`170`），`local_en = sel || ex2_inst_vld`。
- EX3：`ctrl_ex3_inst_vld <= ctrl_ex2_inst_vld`（`:207`-`215`）。
- EX4：`ctrl_ex4_inst_vld <= ctrl_ex3_inst_vld`（`:251`-`259`）。
- EX5：`ctrl_ex5_inst_vld <= ctrl_ex4_inst_vld`（`:304`-`312`）。

每级都有 `else if(rtu_yy_xx_flush) <= 1'b0`，冲刷立即作废——这是 vfmau 与 vfalu 的一个区别（5 级长流水必须支持中途 flush）。

**逐级 pipedown 使能**驱动 mult1 内部各级数据寄存器，且在 EX3/EX4 处带 op 类型门控：
- `mult1_ex3_ex4_pipedown = ctrl_ex3_inst_vld && !dp_xx_ex3_half`（`:221`）
- `mult_ex3_ex4_half_pipedown = ctrl_ex3_inst_vld && dp_xx_ex3_half && dp_xx_ex3_fma`（`:222`，半精度只有 FMA 才进 EX4，纯半精度乘法在更早级出结果）
- EX4→EX5 还要求 `dp_xx_ex4_fma || dp_xx_ex4_mult_id`（`:266`-`272`），即只有真正需要第 5 级的 FMA / 标记为 mult_id 的乘法才走满 5 级。

---

## 5. 乘法器 ct_vfmau_mult1：Booth + 压缩树

`ct_vfmau_mult1`（3171 行）是 full 路 64b lane 的乘加核，跨 EX1→EX5。关键链路：

**部分积生成（EX1，Booth 编码）**：两个 52 位尾数（加隐藏位）做 Booth-2 编码生成部分积。隐藏位由 `mult1_ex1_op0_hidden_bit` / `op1_hidden_bit`（送入 compressor，`ct_vfmau_mult_compressor.v:42`-`45`）补上。

**压缩树（EX1→EX2）**：`ct_vfmau_mult_compressor`（`ct_vfmau_mult1.v:1003`-`1021` 实例化）把所有部分积用 4:2 / 3:2 进位保留加法器（CSA）压成两路 106 位 `compressor_mult1_sum[105:0]` / `compressor_mult1_carry[105:0]`（`ct_vfmau_mult1.v:290`-`291`）。这是乘法的核心面积，故双精度/单精度/半精度共用一棵树（`dp_xx_ex1_double/single/half` 进 compressor 选择宽度，`ct_vfmau_mult_compressor.v:38`-`40`）。

**对阶并加被加数 c（EX2→EX3）**：把 c 按指数差移位后，与 sum/carry 一起送进 LZA 的加数/被加数（`mult1_ex3_lza_summand/addend[107:0]`，`ct_vfmau_mult1.v:1949`-`1955`）。`mult1_ex3_ex4_sticky1`（`:1942`）记录被移出的低位 sticky，供舍入。

**EX3 早出乘法结果**：纯乘法（非 FMA）不需要第 4/5 级的对阶/规格化，结果在 EX3 即给出 `slice0_mult1_dp_ex3_mult_result`（经 dp `pipex_dp_ex3_vfmau_freg_data`，`ct_vfmau_dp.v:982`）。

---

## 6. LZA：前导零预测与规格化

FMA 的「乘积 + 被加数」相加可能产生大量前导零（尤其相近大小相减时），规格化需要把结果左移到首位为 1。如果等加法完成再数前导零，会多一拍关键路径。**LZA（Leading Zero Anticipation）把"数前导零"与"加法"并行做**：

`ct_vfmau_lza`（730 行）在 EX3 接 108 位加数/被加数（`ct_vfmau_mult1.v:1958`-`1960` 实例化），用 pre-predecode 逻辑（`ct_vfmau_lza.v:81` 注释「pre-predecode for leading zero anticipation」）预测相加结果的前导零数，输出 7 位移位量 `lza_result[6:0]`（`:721`）与有效位 `lza_result_vld`（高/低半各判一次，`:720`）。

预测值经 EX4 锁存为 `mult1_ex4_lza_result`（`ct_vfmau_mult1.v:259`），驱动 EX4 的规格化大移位（`mult1_ex4_fma_lza_shift[110:0]`，`:631`）。因为 LZA 可能差 ±1，EX4 还有 `mult1_ex4_expnt_eq_lza_plus1`、`mult1_ex4_expnt_le_lza`（`:593`,`:596`）做 ±1 修正。规格化后在 EX5 舍入并打包。

辅助 LZA：`ct_vfmau_lza_42.v`（4:2 用）、`ct_vfmau_lza_32.v`（3:2 用）、`ct_vfmau_lza_simd_half.v`（半精度）、`ct_vfmau_ff1_10bit.v`（10 位 find-first-1，给小阶段用）。

---

## 7. 半精度独立 pipedown 与 SIMD 通路

FP16 不是简单地复用 full 路低 16 位，而是有一条**物理独立的乘加通路** `ct_vfmau_mult_simd_half`（`ct_vfmau_mult1.v:3120` 实例化 `x_ct_vfmau_mult_half`）。从 ctrl 起就用独立的 `mult_*_half_pipedown` 一族信号驱动它（§4），与 full 路 `mult1_*_pipedown` 完全分开。

数据切分：full 路按 64b lane（`dp_mult1_ex1_op0_slice0[63:0]`，`ct_vfmau_top.v:161`），half 路按 16b/48b 片（`dp_mult_ex1_op0_slice0_half0[15:0]` + `_half0_high[47:0]`，`ct_vfmau_top.v:169`-`170`）。半精度结果与前递也是独立宽度：
- EX4 半精度 FMA 结果：`slice0_mult1_dp_ex4_half_fma_result[15:0]`（`ct_vfmau_top.v:280`），经 dp 输出 `pipex_vfmau_ex4_fmla_slice0_half0_data[15:0]`（`ct_vfmau_dp.v:1164`）。
- `mult1_ex4_half_fma`（`ct_vfmau_mult1.v:258`）逐级锁存半精度 FMA 标记（`:2300`-`2318`）。

半精度独立通路的好处：FP16 的尾数/对阶/规格化位宽远小于 double，做成独立窄通路比硬挤进 double 通路时序更好、且能并行多 lane（`dp_xx_ex*_simd` 控制多 half lane 同激活）。

---

## 8. ctrl_dp_ex5_fma_wb_vld 写回

FMA 走满 5 级，在 EX5 写回。写回有效位由 ctrl 在 EX4 算出再锁存一拍：

**EX4 算写回预报**（`ct_vfmau_ctrl.v:319`-`324`）：

```verilog
assign ctrl_ex4_fma_wb_vld = dp_xx_ex4_fma  && ctrl_ex4_inst_vld && !dp_xx_ex4_half
                          || dp_xx_ex4_mult_id && ctrl_ex4_inst_vld && !dp_xx_ex4_half;
```

即「EX4 是 FMA 或被标记 mult_id、且非半精度」时，下一拍 EX5 要写回。

**EX5 锁存**（`ct_vfmau_ctrl.v:330`-`339`，带 flush 清零）：

```verilog
always @(posedge ctrl_ex4_ex5_clk or negedge cpurst_b)
  ... else ctrl_ex5_fma_wb_vld <= ctrl_ex4_fma_wb_vld;
assign ctrl_dp_ex5_fma_wb_vld = ctrl_ex5_fma_wb_vld;
```

> 端口对外名为 `ctrl_dp_ex5_fma_wb_vld`（`ct_vfmau_ctrl.v:339`、`ct_vfmau_top.v:154`,`296`），内部寄存器名 `ctrl_ex5_fma_wb_vld`（`:84`）。

**dp 用它打开写回**（`ct_vfmau_dp.v:990`-`993`）：

```verilog
assign pipex_rbus_vfmau_vreg_wb_vld   = ctrl_dp_ex5_fma_wb_vld;
assign pipex_rbus_vfmau_ereg_wb_vld   = ctrl_dp_ex5_fma_wb_vld;
assign pipex_rbus_vfmau_freg_wb_data  = slice0_mult1_dp_ex5_fma_result[63:0];
```

即 EX5 把最终 FMA 结果 `slice0_mult1_dp_ex5_fma_result[63:0]` 与异常一起送 RBUS 写回 VREG/物理寄存器（`01_vfpu_top.md` §7）。纯乘法可在 EX3/EX4 早出（`pipex_dp_ex3/ex4_vfmau_freg_data`），由顶层 5 位级内 eu_sel 选对写回级。

---

## 9. 前递（fwd）网络

FMA 延迟 5 拍，若下游指令等结果会停 5 拍，故 vfmau 有密集的前递网络把 EX4/EX5 结果尽早旁路：

- **EX4 前递**：`pipex_pipe6/7_ex4_fmla_fwd_vld` + `pipex_vfmau_ex4_fmla_slice0_half0_data`。
- **EX5 前递**：分 `ex5_ex1`（前递给正进 EX1 的指令）与 `ex5_ex2`（前递给 EX2）两路（`ct_vfmau_top.v:126`-`130`），数据 `ex5_fmla_slice0_data[67:0]` 带 4 位守护位以便接收方继续运算。
- **跨管线**：pipe6 的前递可送 pipe7，反之亦然（顶层互接 `pipe6_pipex_*` ↔ `pipe7_pipex_*`，`ct_vfmau_top.v:107`-`116` 输入、`:125`-`130` 输出）。
- **唤醒广播**：`pipex_rbus_ex1/ex2_fmla_data_vld` 及其 `_dup0..2` 副本（`ct_vfmau_top.v:131`-`138`）告诉 RBUS/IDU 哪拍会有 FMA 结果，供唤醒等待指令；dup 化是为缓解高扇出。
- **no_fwd**：`pipex_rbus_pipe6/7_fmla_no_fwd`（`:139`-`140`）标记某些情形不能前递（须等真正写回）。

---

## 设计取舍小结

1. **FMA 定长 5 级**：把 Booth/压缩/对阶加/LZA规格化/舍入切 5 拍，换取高频下每拍可发一条 FMA；带逐级 flush 应对冲刷。
2. **LZA 与加法并行**：前导零预测把"数零 + 移位"提前到加法旁边算，砍掉关键路径一拍，代价是 ±1 修正逻辑。
3. **压缩树共用、half 通路独立**：乘法压缩树（面积大头）双/单/半共用一棵；但 FP16 的对阶/规格化做成独立窄通路（`mult_*_half_pipedown` + `ct_vfmau_mult_simd_half`），时序更好且支持多 lane。
4. **纯乘法早出**：`vfmul` 在 EX3/EX4 即可写回，不必空走第 5 级。
5. **密集前递 + dup 广播**：EX4/EX5、跨管线、ex5→ex1/ex2 多路前递把 5 拍延迟对下游隐藏；高扇出信号 dup 化换时序。
6. **68 位 / 16 位前递宽度**：full 路带守护位（68b）、half 路 16b，宽度差异即两条独立通路的直接证据。

## 覆盖声明

本文覆盖 vfmau 的 EX1→EX5 五级 FMA 流水、Booth+压缩树乘法器（`ct_vfmau_mult1` / `ct_vfmau_mult_compressor`）、LZA 前导零预测与规格化（`ct_vfmau_lza`）、半精度独立 pipedown 与 SIMD 通路（`ct_vfmau_mult_simd_half`）、`ctrl_dp_ex5_fma_wb_vld` 写回与前递网络。所有流水级数（5 拍）、位宽（106/108/68/16）、信号名与行号均直接引自上述 RTL，未作推测。vfmau 在 VFPU 顶层的接线见 `01_vfpu_top.md` §8，整体定位与延迟总表见 `00_vfpu_overview.md` §12。
