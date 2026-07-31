# C910 VFPU vfmau（FMA 乘加 / 乘法器 / 压缩树 / LZA）模块详细教学文档

> RTL 目录：`C910_RTL_FACTORY/gen_rtl/vfmau/rtl/`
> 核心文件：
> - `ct_vfmau_top.v`（560 行，顶层封装）
> - `ct_vfmau_ctrl.v`（344 行，EX1→EX5 五级有效位 + pipedown + 写回有效）
> - `ct_vfmau_dp.v`（数据准备 + 写回汇聚）
> - `ct_vfmau_mult1.v`（3171 行，当前 64 位标量 slice 的乘加核：Booth/压缩树/LZA/规格化/舍入）
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
- [7. 当前 slice0 的半精度子通路](#7-当前-slice0-的半精度子通路)
- [8. ctrl_dp_ex5_fma_wb_vld 写回](#8-ctrl_dp_ex5_fma_wb_vld-写回)
- [9. 前递（fwd）网络](#9-前递fwd网络)
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 vfmau 是什么

vfmau（Vector / Floating-point Multiply-Add Unit）负责当前标量浮点乘加与乘法
路径。VFPU 顶层在 pipe6、pipe7 各实例化一份 `ct_vfmau_top`。这证明两条入口
各有一份 FMAU 资源；“高频单元”“负载中高频使用”或“两个端口任何时候都能
同时接收”仍需时序报告、动态指令统计和调度条件支持。

每份 `ct_vfmau_top` 当前只实例化一个 `ct_vfmau_mult1`，实例名为
`x_ct_vfmau_mult1_slice0`。`ct_vfmau_top.v:444`-`461` 的 slice0/slice1
`&Instance` 行全部是注释，真正的 Verilog 实例从 `:464` 开始且只有 slice0。
因此，当前不能写成“两个 64 位 slice 覆盖 128 位向量”。slice0 内部确实实例化
半精度子模块，详见 §7。

### 1.2 为什么 FMA 要 5 级流水

`a*b+c` 需要部分积生成、压缩、与加数对阶合并、规格化、舍入和异常处理。
RTL 将控制和数据组织为 EX1~EX5 结构，并提供中间前递点。五个 EX 标签是
结构边界，不应在没有参考点时直接写成“从 IDU 发射到退休固定五拍”。

控制流水没有 `ready` 型内部停顿握手，说明被选择的操作按固定级间协议推进；
但“每拍可发一条新 FMA”还受 IDU 选择、源依赖、同端口资源、写回冲突、门控和
flush 影响。RTL 结构支持流水重叠，不等于任意程序都能达到每拍一条。

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

> EX5 full 前递总线为 **68 位**，但多出的 4 位不是守护/低位。`ct_vfmau_mult1.v`
> 将 `[63:0]` 作为数值字段，将 `[64]`、`[65]`、`[66]`、`[67]` 分别定义为
> `INF`、`EXPNT_ZERO`、`QNAN`、`SNAN` 分类元数据。half0 的 EX4 数据总线是
> 16 位。两者不仅宽度不同，语义也不同。

---

## 3. 参数与关键寄存器

| 名称 | 值/宽度 | 出处 | 含义 |
|---|---|---|---|
| 流水级名 | 5（EX1→EX5） | `ct_vfmau_ctrl.v` | EX1 有效是组合选择，EX2~EX5 由四个逐级有效位寄存器保存 |
| `ctrl_ex2..ex5_inst_vld` | 各 1 bit reg | `ct_vfmau_ctrl.v` | 四个逐级有效位寄存器 |
| `ctrl_ex5_fma_wb_vld` | 1 bit reg | `ct_vfmau_ctrl.v:84` | EX5 写回有效 |
| 尾数宽度 | 52 位 | `ct_vfmau_top.v:194` `dp_xx_ex1_op0_frac[51:0]` | double 尾数 |
| 压缩树进位/和 | 106 位 | `ct_vfmau_mult1.v:290`-`291` `compressor_mult1_carry/sum[105:0]` | 部分积压缩输出 |
| LZA 加数/被加数 | 108 位 | `ct_vfmau_mult1.v:538`-`539` `mult1_ex3_lza_addend/summand[107:0]` | 前导零预测输入 |
| LZA 结果 | 7 位 | `ct_vfmau_lza.v:28` `lza_result[6:0]` | 预测的前导零数（移位量） |
| full 前递数据 | 68 位 | `ct_vfmau_mult1.v:1181`-`1188` | 64 位值 + INF/零指数/QNaN/SNaN 四个分类位 |
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

各级有效位寄存器在门控时钟沿检测 `rtu_yy_xx_flush` 并写 0。这里“作废”是
寄存器时序语义，不是组合地在 flush 变化瞬间清除所有数据寄存器。与 VFALU
局部 ctrl 不同，VFMAU 的控制流水直接接入 flush。

**逐级 pipedown 使能**驱动 mult1 内部各级数据寄存器，且在 EX3/EX4 处带 op 类型门控：
- `mult1_ex3_ex4_pipedown = ctrl_ex3_inst_vld && !dp_xx_ex3_half`（`:221`）
- `mult_ex3_ex4_half_pipedown = ctrl_ex3_inst_vld && dp_xx_ex3_half && dp_xx_ex3_fma`（`:222`，半精度只有 FMA 才进 EX4，纯半精度乘法在更早级出结果）
- EX4→EX5 还要求 `dp_xx_ex4_fma || dp_xx_ex4_mult_id`（`:266`-`272`），即只有真正需要第 5 级的 FMA / 标记为 mult_id 的乘法才走满 5 级。

---

## 5. 乘法器 ct_vfmau_mult1：Booth + 压缩树

`ct_vfmau_mult1` 是当前 slice0 的 64 位标量乘加核，跨 EX1~EX5 组织。关键链路：

**部分积生成（EX1，radix-4 Modified Booth）**：压缩器明确实例化 27 个
`booth_code_v1 #(53)` 单元并生成 27 组部分积。这里不只依赖模块名判断：
第 0 组编码为 `{multiplier[1:0],1'b0}`，之后依次使用
`multiplier[3:1]`、`[5:3]` 等三位重叠窗口，每组前进两位；
`common/rtl/booth_code_v1.v` 又把三位编码映射为 `0`、`+A`、`+2A`、
`-2A`、`-A` 及相应符号校正。这个“重叠三位、每组消费两位、选择
0/±A/±2A”的组合正是 radix-4 Modified Booth 重编码。隐藏位由
`mult1_ex1_op0_hidden_bit/op1_hidden_bit` 补入。

**压缩树（EX1→EX2）**：`ct_vfmau_mult_compressor` 把部分积压成两路 106 位
`compressor_mult1_sum/carry`。它是显著的大组合模块，但“核心面积”或面积占比
需要综合报告，不能由源码行数或位宽直接证明。full 路的双/单精度控制进入同一
压缩器；half 还存在独立窄子通路，不能笼统写成所有精度完全共用一棵树。

**对阶并加被加数 c（EX2→EX3）**：把 c 按指数差移位后，与 sum/carry 一起送进 LZA 的加数/被加数（`mult1_ex3_lza_summand/addend[107:0]`，`ct_vfmau_mult1.v:1949`-`1955`）。`mult1_ex3_ex4_sticky1`（`:1942`）记录被移出的低位 sticky，供舍入。

**EX3/EX4 乘法结果接口**：dp 同时导出
`slice0_mult1_dp_ex3_mult_result` 和 `slice0_mult1_dp_ex4_mult_result`。
具体指令由顶层 `ready_stage` 和 EU 来源选择在哪一级作为有效数据。可以说纯
乘法具有早于 EX5 FMA 写回的结果接口，不能把所有乘法统一简化为“EX3 已写回”。

---

## 6. LZA：前导零预测与规格化

FMA 的乘积与加数发生有效相减时可能产生大量前导零，规格化必须据此左移。
若先等待最终和，再串行完成前导零检测，组合深度会增加；是否必须增加一个
流水级取决于目标频率和实现。**LZA（Leading Zero Anticipation）根据加法输入
预测前导零位置，使预测逻辑与最终加法部分并行**：

`ct_vfmau_lza`（730 行）在 EX3 接 108 位加数/被加数（`ct_vfmau_mult1.v:1958`-`1960` 实例化），用 pre-predecode 逻辑（`ct_vfmau_lza.v:81` 注释「pre-predecode for leading zero anticipation」）预测相加结果的前导零数，输出 7 位移位量 `lza_result[6:0]`（`:721`）与有效位 `lza_result_vld`（高/低半各判一次，`:720`）。

预测值经 EX4 锁存为 `mult1_ex4_lza_result`（`ct_vfmau_mult1.v:259`），驱动 EX4 的规格化大移位（`mult1_ex4_fma_lza_shift[110:0]`，`:631`）。因为 LZA 可能差 ±1，EX4 还有 `mult1_ex4_expnt_eq_lza_plus1`、`mult1_ex4_expnt_le_lza`（`:593`,`:596`）做 ±1 修正。规格化后在 EX5 舍入并打包。

辅助 LZA：`ct_vfmau_lza_42.v`（4:2 用）、`ct_vfmau_lza_32.v`（3:2 用）、`ct_vfmau_lza_simd_half.v`（半精度）、`ct_vfmau_ff1_10bit.v`（10 位 find-first-1，给小阶段用）。

---

## 7. 当前 slice0 的半精度子通路

FP16 不是简单截取 full 结果。`ct_vfmau_mult1` 内实例化
`ct_vfmau_mult_simd_half`，ctrl 也生成独立的 `mult_*_half_pipedown`。这证明
half 有专用窄数据逻辑和级间使能；但它仍位于同一个 slice0/FMAU 内，并与 full
路径共享顶层选择、部分控制和汇聚资源，不能描述为完全独立的第二执行端口。

数据切分：full 路按 64b lane（`dp_mult1_ex1_op0_slice0[63:0]`，`ct_vfmau_top.v:161`），half 路按 16b/48b 片（`dp_mult_ex1_op0_slice0_half0[15:0]` + `_half0_high[47:0]`，`ct_vfmau_top.v:169`-`170`）。半精度结果与前递也是独立宽度：
- EX4 半精度 FMA 结果：`slice0_mult1_dp_ex4_half_fma_result[15:0]`（`ct_vfmau_top.v:280`），经 dp 输出 `pipex_vfmau_ex4_fmla_slice0_half0_data[15:0]`（`ct_vfmau_dp.v:1164`）。
- `mult1_ex4_half_fma`（`ct_vfmau_mult1.v:258`）逐级锁存半精度 FMA 标记（`:2300`-`2318`）。

窄通路通常有利于减少不必要的宽逻辑活动和改善局部时序，这是合理的设计解释；
实际收益需综合/功耗数据验证。当前只有 half0 有效实例，slice1 和更多 half lane
只存在于注释模板，所以不能据此宣称当前可并行执行多个 FP16 lane。

---

## 8. ctrl_dp_ex5_fma_wb_vld 写回

非 half 的 FMA 或 `mult_id` 路径在 EX4 形成写回预报，下一时钟沿锁存为 EX5
写回有效：

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

EX5 将 `slice0_mult1_dp_ex5_fma_result[63:0]` 和 5 位异常数据送入 RBus。
当前 RBus 的有效落点是浮点物理寄存器分支和 EREG；向量 VR 写有效固定为 0。
EX3/EX4 的乘法结果由顶层 `ready_stage`/来源选择决定何时有效。

---

## 9. 前递（fwd）网络

若消费者等待 FMA 结果，前递可以避免必须先完成物理寄存器写回再读取，但具体
等待周期取决于消费者进入 EX1/EX2 的时点、命中条件和 `no_fwd`。网络包括：

- **EX4 前递**：`pipex_pipe6/7_ex4_fmla_fwd_vld` + `pipex_vfmau_ex4_fmla_slice0_half0_data`。
- **EX5 前递**：分 `ex5_ex1` 和 `ex5_ex2` 两类接收时点；68 位数据由 64 位
  值和四个特殊值分类位组成，不是“64 位结果加四个守护位”。
- **跨管线**：pipe6 的前递可送 pipe7，反之亦然（顶层互接 `pipe6_pipex_*` ↔ `pipe7_pipex_*`，`ct_vfmau_top.v:107`-`116` 输入、`:125`-`130` 输出）。
- **唤醒广播**：`pipex_rbus_ex1/ex2_fmla_data_vld` 及其 `_dup0..2` 副本（`ct_vfmau_top.v:131`-`138`）告诉 RBUS/IDU 哪拍会有 FMA 结果，供唤醒等待指令；dup 化是为缓解高扇出。
- **no_fwd**：`pipex_rbus_pipe6/7_fmla_no_fwd`（`:139`-`140`）标记某些情形不能前递（须等真正写回）。

---

## 本章小结

VFMAU 把 `a*b+c` 的长组合过程分散到 EX1~EX5：EX1 进行 radix-4 Modified
Booth 重编码并生成 27 组部分积，压缩树把它们归并成 106 位 sum/carry；随后
乘积与被加数按指数关系对齐，形成 108 位 LZA 输入和最终加法输入；LZA 与加法
并行预测规格化移位，EX4 完成大移位和预测误差修正，EX5 再完成舍入、异常整理
与打包。纯乘法和半精度操作可以在较早阶段形成结果接口，而需要完整乘加或
`mult_id` 路径的非 half 操作进入 EX5 写回。因此 EX1~EX5 是覆盖不同操作的
结构框架，并不意味着每条乘法/FMA 都在同一点产生结果，更不等于从发射到退休
固定五拍。

pipe6 和 pipe7 各实例化一份当前只有 slice0 的 VFMAU，half0 在同一 slice 内
使用专用窄乘法和 LZA 通路，但仍共享发射选择、部分控制和结果汇聚，所以它不是
额外的独立执行端口。跨管线前递把 EX4 的 16 位 half 数据或 EX5 的 68 位 full
数据送给另一条管线；后者由 64 位数值与 INF、EXPNT_ZERO、QNAN、SNAN 四个
分类位组成，而不是守护位。流水结构能够重叠多条操作，实际吞吐仍由 IDU
调度、源依赖、端口冲突、写回条件和 flush 共同决定；面积占比与关键路径收益
则必须结合综合和时序报告评价。
