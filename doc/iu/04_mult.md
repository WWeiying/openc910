# C910 IU 乘法单元详解（ct_iu_mult）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_mult.v`（666 行）
> 内部例化：`multiplier_65x65_3_stage`（DesignWare 风格 3 级流水 65×65 乘法器，
> 在 common 目录，含 booth_code / compressor_32 / compressor_42 压缩树原件）
>
> 挂在 Pipe1（与 ALU1 共享发射端口和写回端口），4 拍流水（EX1~EX4），支持
> 乘法、宽位乘、以及 T-Head 扩展的乘累加（mula/muls 系列）。

---

## 1. 指令与数据通路概览

| 指令 | 语义 | rslt_sel[1:0] |
|------|------|---------------|
| mul | rz = (rx×ry)[63:0] | 00（取低 64） |
| mulh/mulhu/mulhsu | rz = (rx×ry)[127:64] | 01（取高 64） |
| mulw | rz = sext((rx×ry)[31:0]) | 10（取低 32 符扩） |
| th.mula/muls 系列 | rz = rz ± rx×ry（乘累加/乘累减） | 同上 + mla_src2 |

```
   RF             EX1            EX2             EX3             EX4
─────────┬───────────────┬───────────────┬───────────────┬──────────────
 操作数   │ booth 编码     │ 部分积压缩树   │ 最终 132 位加  │ 高/低/字选择
 符号扩展 │ (乘法器拍1)    │ +addend 注入   │ (乘法器拍3)    │ → rbus ex4 写回
 成65位   │               │ (乘法器拍2)    │ → ex3 preg 预告│
```

关键时序事实：

- **EX3 拍发"写回预告"**（`mult_rbus_ex3_data_vld/preg`，L531/555），**EX4 拍数据
  才真正有效**（`mult_rbus_ex4_data_vld/data`，L570, 648-661）。预告比数据早一拍，
  让发射队列提前唤醒消费者——消费者在 EX4 数据广播的同拍发射，RF 级恰好抓到数据。
  这是"延迟感知唤醒"（latency-aware wakeup）的实现。
- 乘法器本体横跨 EX1~EX3 三拍（L611-612 注释），输入在 EX1 直接喂组合逻辑
  （booth 编码），EX2/EX3 拍内部打拍（pipe1_clk/pipe2_clk 即 ex2/ex3_inst_clk）。

---

## 2. 逐逻辑块讲解

### 2.1 RF 级：统一成 65×65 有符号乘（L285-316）

```verilog
// mult_func 位义: [1]=word(mulw) [2]=src0无符号 [3]=src1无符号 [4]=半字 [5]/[6]=累加数低/高 [7]=减
assign mult_rf_src0[64]    = func[2] ? 1'b0 : src0[63];     // 符号位/零扩展第65位
assign mult_rf_src0[63:32] = func[1] ? 32'b0 : src0[63:32]; // mulw 只留低32位
assign mult_rf_src0[31:0]  = func[4] ? sext(src0[15:0]) : src0[31:0];
```

**为什么是 65 位？** 用一个有符号 65×65 乘法器统一处理四种符号组合：
无符号数第 65 位补 0、有符号数补符号位，乘法器内部永远按有符号算。
这比做 4 个变种或在结果端修正便宜得多——典型的"宽一位换统一"技巧。
mulw 则把高 32 位清零（无符号化），结果取低 32 位再符扩，同样无需专用硬件。

`src1_no_imm` 而非 `src1`：pipe1 的 src1 端口可能被立即数替换（ALU 共用），
乘法永远要寄存器原值。

### 2.2 MLA 内部前递判断（L318-342）—— 本模块最有意思的设计

乘累加 `mula rz, rx, ry`（rz += rx×ry）的累加源 rz 有个麻烦：连续 MLA
（如矩阵乘内积）中，下一条 MLA 的 rz 正是上一条 MLA 的结果，而乘法 4 拍延迟，
正常前递网络等不起。C910 做了**乘法器私有前递链**：

```verilog
// L321-326: RF 级检查“我的累加源 preg == 管线中某条 MLA 的目的 preg？”
assign mult_rf_mla_match_ex1 = mla_src2_vld && mult_ex1_inst_vld && mult_ex1_mla
                            && (func[1] == mult_ex1_rslt_sel[1])      // 同为 word/双字
                            && (mla_src2_preg == mult_ex1_dst_preg);
// 同样检查 ex2 / ex3 （L327-338）

assign iu_idu_pipe1_mla_src2_no_fwd = 无任何匹配;                      // L340-342
```

匹配信息打入 EX1 后变成三个选择位（注意拍号平移，L386-388）：
RF 时匹配 ex3 → EX1 时选 ex4；RF 时匹配 ex2 → EX1 时选 ex3；RF 时匹配 ex1 →
**EX2 时**选 ex3（数据还没出来，要再等一拍在 EX2 抓）。

```
EX1 选择（L408-428）:                     EX2 选择（L510-512）:
  ex1_sel_ex3 → 抓 mult_ex3_src2_fwd_data   ex2_sel_ex3 → 抓 mult_ex3_src2_fwd_data
  ex1_sel_ex4 → 抓 mult_ex4_src2_fwd_data   否则 → 用 EX1 传下来的 src2
  否则       → 用 RF 读的 src2
```

`mult_ex3_src2_fwd_data` 直接取自乘法器组合输出（L642-643），
`mult_ex4_src2_fwd_data` 取自 EX4 结果寄存器（L607-608）。于是**背靠背 MLA
可以每 2 拍一条**发射（RF 时上一条在 ex1，EX2 抓 ex3 输出），而不是每 4 拍。

`iu_idu_pipe1_mla_src2_no_fwd` 告诉 IDU：累加源**不能**走私有前递（不是管线内
MLA 产生的），IDU 必须按常规依赖等 src2 写回 PRF 才能发射。为什么累加源不能走
普通前递网络？——因为累加数是在 **EX2 注入压缩树**的（`addend`，L619），普通
前递赶不上这个注入点的时序，干脆只支持"自家管线内"的精确匹配。

`func[1] == rslt_sel[1]` 的检查排除 word/双字宽度不匹配的伪命中——宽度不同时
高位语义不同，不能直接接力。

### 2.3 流水推进与 stall（L344-357, 430-453）

```verilog
assign iu_idu_ex1_pipe1_mult_stall = mult_ex1_inst_vld;   // L357
```

乘法在 EX1 时拉 stall：**禁止 IDU 下一拍向 pipe1 发 ALU 指令**。原因是写回端口
冲突——若 EX1 是乘法（将于 EX4 写回）、下一拍发一条 ALU（EX2 写回），两者会在
同一拍抢 pipe1 写回口。stall 一拍错开即可（乘法 EX2 时发射的 ALU 在乘法 EX4+1
拍写回，不冲突）。

`mult_ex2_inst_vld_dup[4:0]`（L437-453）和 `mult_ex2_dst_preg_dup0~4`（L461-505）
是发往 5 个发射队列的预告唤醒信号的物理复制（见 00 总览 3.2 节）——注意它在
**EX2** 发出（`iu_idu_ex2_pipe1_mult_inst_vld_dup*`），比 rbus 的 ex3 preg 预告
还早一拍，用于 IDU 侧更深的唤醒流水。

### 2.4 乘法器例化（L610-643）

```verilog
multiplier_65x65_3_stage x_... (
  .multiplicand (mult_ex1_src0[64:0]),   // EX1 进
  .multiplier   (mult_ex1_src1[64:0]),
  .addend       (mult_ex2_src2_data[64:0]), // EX2 注入累加数
  .sub_vld      (mult_ex1_sub),          // muls: 累减
  .product      (mult_multiplier_result[129:0]), // EX3 组合输出
  .pipe1_clk/pipe1_down, pipe2_clk/pipe2_down    // 内部两级流水控制
);
```

把累加数直接作为一行部分积送进压缩树（CSA 阵列加一行几乎免费），**乘累加与
纯乘法同延迟**——这是硬件 MAC 的标准做法，也是 th.mula 比"mul+add"两条指令
快的根本原因。`sub_vld` 同理把减法转成补码注入。
`mult_ex2_src2_data` 的高 33 位由 `src2_h`（func[6]）控制（L514-516）：
mulaw 等 32 位累加变种只注入低 32 位。

### 2.5 EX4 结果选择（L645-661）

```verilog
case (mult_ex4_rslt_sel[1:0])
  2'b00: 取 result[63:0]      // mul
  2'b01: 取 result[127:64]    // mulh*
  2'b10: 取 sext(result[31:0])// mulw
```

result 寄存器 128 位（L594-605），130 位乘法器输出截掉顶 2 位（65×65 的符号
冗余位）。选择放在 EX4 而不是 EX3，是让 EX3 那拍只走"压缩树收尾加法"这一条
关键路径，选择逻辑挪到松弛的 EX4。

---

## 3. 接口汇总

| 方向 | 对端 | 信号 | 拍 |
|------|------|------|----|
| 入 | IDU | `idu_iu_rf_mult_sel/gateclk_sel`、`pipe1_src0/src1_no_imm/src2`、`mult_func[7:0]`、`mla_src2_preg/vld`、`dst_preg` | RF |
| 出 | IDU | `iu_idu_ex1_pipe1_mult_stall`（结构冲突）、`iu_idu_pipe1_mla_src2_no_fwd`（发射约束）、`iu_idu_ex2_pipe1_mult_inst_vld_dup*/preg_dup*`（早期唤醒） | EX1/EX2 |
| 出 | RBUS | `mult_rbus_ex3_data_vld/preg`（预告）、`mult_rbus_ex4_data/data_vld`（数据） | EX3/EX4 |

乘法指令的"完成"汇报由 CBUS 用 `idu_iu_rf_mult_sel` 自行延拍生成（乘法定长
4 拍、无异常），MULT 模块不连 CBUS——与 ALU 同理。

---

## 4. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_mult`

| 信号 | 看什么 |
|------|--------|
| `mult_ex1/2/3/4_inst_vld` | 4 级流水推进 |
| `iu_idu_ex1_pipe1_mult_stall` | 乘法后一拍 pipe1 无 ALU 发射 |
| `mult_rbus_ex3_data_vld` vs `mult_rbus_ex4_data_vld` | 预告/数据相差一拍 |
| `mult_rf_mla_match_ex1/2/3` + `mult_ex1_pipedown_src2` | 连续 MLA 的私有前递命中 |

观察 MLA 前递建议写个内积小循环（连续 th.mula），coremark 的矩阵部分
（matrix_mul_matrix）在开启 xtheadc 编译时也会出现成串 mula。
