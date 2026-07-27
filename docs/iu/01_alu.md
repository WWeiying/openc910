# C910 IU ALU 详解（ct_iu_alu）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_alu.v`（1096 行）
>
> 同一模块在 ct_iu_top 中例化两次：`x_ct_iu_alu0`（pipe0）和 `x_ct_iu_alu1`（pipe1），
> 端口名中的 `pipex` 由 ConnRule 替换为 pipe0/pipe1。本文信号名保留 `pipex` 写法。

---

## 1. 模块概述

### 1.1 职责

ALU 是 IU 中最简单也最高频的执行单元，完成：

- **加减类**：add/addw/sub/subw、slt 比较、max/min（T-Head 扩展）、加移位（addsl，对应 th.addsl）
- **移位类**：逻辑左/右移、算术右移、64/32 位宽、位段提取 ext/extu（T-Head 扩展）
- **逻辑类**：and/or/xor、lui、cli（短立即数装载）
- **杂项类**：条件搬运 mveqz/mvnez、tstnbz（字节测零）、tst（位测试）、ff1/ff0（找首个 1/0）、rev/revw（字节序反转）
- **mtvr 转发**：整数→向量寄存器搬运指令的数据转交 VFPU

注意这份 RTL 里大量 T-Head 自定义指令（addsl/ext/extu/mveqz/tstnbz/ff1/rev…）——
这正是 `-march=rv64imafdcvxtheadc` 中 `xtheadc` 扩展的硬件支持，CoreMark 分数
6.1 与 4.4 的差距就来自能否用上这些指令（见 smart_run 性能调优记录）。

### 1.2 流水结构：单拍执行

```
       RF（IDU 读寄存器）         EX1（本模块）              EX2
  ─────────────────────────┬──────────────────────────┬────────────────
   idu_iu_rf_pipex_* 有效   │ 三个并行 EU 同时算：       │ （结果已交 RBUS，
   ↓ 打一拍进 EX1 寄存器    │  adder / shifter / other  │  RBUS 在 EX2 写回）
                           │ rslt_sel 独热码选结果      │
                           │ → alu_rbus_ex1_pipex_*    │
```

ALU 本体只有一级流水（RF→EX1 打拍，EX1 纯组合算完即交 RBUS）。
"EX2 写回"由 RBUS 模块再打一拍完成（见 08_rbus.md）。

---

## 2. 逐逻辑块讲解

### 2.1 结果选择编码（ct_iu_alu.v:229-257）

```verilog
parameter ADDER_ADD   = 21'h000001;   // [4:0]   加法器组
parameter SHIFTER_SL  = 21'h000020;   // [9:5]   移位器组
parameter LOGIC_AND   = 21'h000400;   // [20:10] 逻辑/杂项组
...
parameter ADDER_MAX   = 21'h01;       // 复用低 5 位编码"长指令"结果
parameter ADDER_ADDSL = 21'h20;
```

`rslt_sel[20:0]` 是 **21 位独热码**，IDU 译码时就生成（见 `doc/idu/19_rf_dp.md`
的 pipe0/1 译码）。为什么不用 5 位二进制编码？——独热码做多路选择只需一层
AND-OR，**译码逻辑被移到了流水线更早、时序更松的 RF 级**，EX1 的关键路径上
一个译码器都不用摆。这是高频设计的典型手法：时序紧的级只留数据通路。

注意第二组 parameter（ADDER_MAX 等）**复用了低 6 位编码**：max/min/addsl 这些
"长指令"（alu_short=0）单独用一套选择树（见 2.7），与短指令编码空间不冲突，
因为两棵选择树由 `alu_short` 区分使用。

### 2.2 三个门控时钟域（ct_iu_alu.v:265-322）

```verilog
assign ctrl_clk_en     = idu_iu_rf_pipex_gateclk_sel || alu_ex1_inst_vld || misc_ex2_mtvr_vld;
assign ex1_inst_clk_en = idu_iu_rf_pipex_gateclk_sel;
assign ex2_inst_clk_en = misc_ex1_mtvr_vld;
```

| 时钟 | 驱动的寄存器 | 开启条件 |
|------|-------------|----------|
| `ctrl_clk` | inst_vld/fwd_vld 等控制位 | 有指令进入**或**管线内还有指令（需要清零） |
| `ex1_inst_clk` | EX1 数据寄存器（src/func/preg…约 400 bit） | 仅本拍真有指令发射 |
| `ex2_inst_clk` | mtvr EX2 数据寄存器 | 仅 EX1 是 mtvr 指令 |

**为什么分三个？** 数据寄存器位宽大、翻转功耗高，但它们不需要"清零"——
没新指令时保持旧值即可（vld=0 自然无效）。控制位则必须能在 flush/空拍清零，
时钟条件要更宽。把两类寄存器放进不同门控域，数据寄存器的时钟开启率可以压到
最低。这个 ctrl/data 分离模式贯穿 C910 全部 RTL，后续模块不再重复解释。

### 2.3 RF→EX1 流水寄存器（ct_iu_alu.v:327-425）

控制部分（ctrl_clk 域，可清零）：

```verilog
// ct_iu_alu.v:327-345
assign alu_rf_fwd_vld = idu_iu_rf_pipex_sel && idu_iu_rf_pipex_dst_vld
                        && idu_iu_rf_pipex_alu_short;
...
  else if(rtu_yy_xx_flush) begin
    alu_ex1_inst_vld <= 1'b0;
    alu_ex1_fwd_vld  <= 1'b0;
  end
  else begin
    alu_ex1_inst_vld <= idu_iu_rf_pipex_sel;
    alu_ex1_fwd_vld  <= alu_rf_fwd_vld;
  end
```

两个关键点：

1. **fwd_vld 在 RF 级就决定**：只有 `alu_short`（单拍出结果的"短指令"）才能前递。
   max/min/addsl 这类"长指令"虽然也是 EX1 出结果，但走的是独立选择树、
   到达时间晚，**不进前递路径**——前递总线是全核时序最紧的网络，宁可让长指令
   的消费者多等一拍（从 EX2 写回拿数），也不能拖垮前递路径的时钟频率。
2. **flush 只清 vld 不清数据**：错误路径指令的数据留在寄存器里没有副作用，
   下条指令会覆盖它。少清几百 bit 寄存器，flush 路径的扇出小很多。

数据部分（ex1_inst_clk 域，ct_iu_alu.v:354-425）值得注意的是源操作数被**复制
三份**锁存：`alu_ex1_src0/1`、`alu_ex1_adder_src0/1`、`alu_ex1_shifter_src0/1`
（ct_iu_alu.v:387-392）。功能上完全一样，目的同样是物理扇出隔离：adder、
shifter、logic 三个 EU 各用自己的副本，64 位×2 的高扇出网络被切成三段短线。

另外 `eu_sel[2:0]` 在 RF 级由 rslt_sel 按段归并（ct_iu_alu.v:350-352）：

```verilog
assign idu_iu_rf_pipex_eu_sel[0] = |idu_iu_rf_pipex_rslt_sel[4:0];    // adder 组
assign idu_iu_rf_pipex_eu_sel[1] = |idu_iu_rf_pipex_rslt_sel[9:5];    // shifter 组
assign idu_iu_rf_pipex_eu_sel[2] = |idu_iu_rf_pipex_rslt_sel[20:10];  // other 组
```

EX1 最后一级 4:1 选择就用这个 3 位独热码，又一次"译码前移"。

### 2.4 加法器组（ct_iu_alu.v:427-488）

```verilog
assign adder_data_out_add[63:0]  = src0 + src1;        // L436
assign adder_data_out_sub[63:0]  = src0 - src1;        // L438
assign adder_data_out_subw[31:0] = src0[31:0] - src1[31:0];
assign adder_data_out_addw[31:0] = src0[31:0] + src1[31:0];
```

四个加法器**并行展开**而不是复用一个（加法/减法/64 位/32 位共用一个加法器
需要在输入端加取反和选择逻辑，会把选择延迟加进加法关键路径）。面积换时序。

**addsl（add with shift，ct_iu_alu.v:447-461）**：`rd = src0 + (src1 << imm[1:0])`，
对应 T-Head `th.addsl`。数组寻址 `base + index*4/8` 一条指令完成——这是 CoreMark
中出现频率极高的模式，xtheadc 提分的主力之一。

**比较与 max/min（ct_iu_alu.v:466-488）**：

```verilog
assign adder_sltu  = src0 < src1;                       // 无符号
assign adder_slts  = $signed(src0) < $signed(src1);     // 有符号
assign adder_rslt_slt = adder_inst_cmp_unsign ? adder_sltu : adder_slts;  // func[3] 选
assign adder_rslt_max[63:0] = adder_rslt_slt ? src1 : src0;
```

slt 的结果直接复用为 max/min 的选择信号——比较器只做一套。

### 2.5 移位器组（ct_iu_alu.v:490-689）

左移直接用 `<<`。右移的实现值得细看（ct_iu_alu.v:503-512）：

```verilog
assign shifter_r_shift_in[63:0] = src0 & {64{func[4]}}              // 循环移位时补 src0 自身
                                | {64{func[1] && src0[63]}};        // 算术移位时补符号
assign shifter_r_rslt[127:0]    = {shifter_r_shift_in, src0} >> src1[5:0];
```

**一个 128 位逻辑右移器统一实现 srl/sra/循环右移**：高 64 位按指令类型填
0 / 符号 / 原数据，移完取低 64 位。三种右移共享同一个桶形移位器，只差高位
填充逻辑——又是面积优化。

**ext/extu 位段提取（ct_iu_alu.v:517-689）**：T-Head `th.ext rd,rs,msb,lsb` =
取 rs[msb:lsb] 并符号/零扩展。实现分三步：

1. `shifter_ext_shift = src0 >> lsb`（复用右移路径的输入，src1[5:0]=lsb）；
2. 64 项查找表 `shifter_extu_mask`（L520-586）按字段宽度 imm 生成低位掩码；
3. 64 项查找表 `shifter_ext_sign`（L591-670）按 src1[11:6]=msb 直接取出符号位，
   再用 and_mask/or_mask 完成零扩展或符号扩展（L674-689）：

```verilog
assign shifter_ext_rslt = shifter_ext_shift & shifter_ext_and_mask | shifter_ext_or_mask;
```

两个 64 项 case 看着吓人，综合后就是两个 64:1 选择器/译码器，深度 log2(64)=6 级，
完全可接受。**为什么符号位单独查表而不是从移位结果取 bit[width-1]？**——那样
符号位要等移位完成才能用，串行依赖拉长路径；查表与移位**并行**进行。

### 2.6 逻辑与杂项组（ct_iu_alu.v:691-915）

| 逻辑块 | 行号 | 说明 |
|--------|------|------|
| and/or/xor | 697-701 | 直接按位运算 |
| lui | 703 | `{{32{imm[19]}}, imm[19:0], 12'b0}`，src1 携带立即数 |
| cli | 705 | 6 位立即数符号扩展（T-Head 短立即数装载） |
| mveqz/mvnez | 713-720 | `func[1:0]` 区分；src1 为条件，成立选 src2 否则保持 src0（src0 = 旧 rd 值，所以"不搬运"= 写回原值） |
| tstnbz | 725-732 | 8 个字节并行测零，每字节展开成 8'hff/8'h00 |
| tst | 737-813 | 64:1 位选择，取 src0[src1[5:0]] |
| ff1/ff0 | 818-895 | 64 项 casez 优先编码器，找首个 1（ff0 = 先取反再找 1，L820-821 复用同一编码器）；全 0 结果 64 |
| rev/revw | 900-915 | 字节序反转，纯连线无逻辑 |

`misc_mv_rslt` 的实现揭示了**条件搬运在乱序核中的处理方式**：mveqz 不论条件
是否成立都"写回"目的寄存器（条件不成立时写回旧值 src0）。这样指令的目的寄存器
依赖是无条件的，重命名/唤醒逻辑不需要任何特殊处理——代价是 IDU 必须把旧 rd
作为额外源操作数（src0）读出来。

### 2.7 结果选择树与输出（ct_iu_alu.v:928-1043）

四级选择结构：

```
 adder 组果 ──case(rslt_sel[4:0])──► alu_ex1_adder_fwd_data ──┐
 shifter 组 ──case(rslt_sel[9:5])──► alu_ex1_shifter_fwd_data ─┼─case(eu_sel[2:0])──► alu_ex1_fwd_data
 logic/misc ──case(rslt_sel[20:10])► alu_ex1_other_fwd_data ──┘
 max/min/addsl ──case(rslt_sel)────► alu_ex1_long_data  （独立选择树，L929-945）
```

最终输出（ct_iu_alu.v:1034-1043）：

```verilog
assign alu_rbus_ex1_pipex_data_vld  = alu_ex1_inst_vld && alu_ex1_dst_vld;
assign alu_rbus_ex1_pipex_fwd_vld   = alu_ex1_fwd_vld;     // 仅 alu_short
assign alu_rbus_ex1_pipex_data[63:0] = alu_ex1_alu_short ? alu_ex1_fwd_data
                                                          : alu_ex1_long_data;
```

`data` 与 `fwd_data` 的区别：**fwd_data 只含短指令结果**（给前递网络，时序最紧）；
**data 是最终写回值**（短/长指令二选一，给 RBUS 在 EX2 写回，多一拍余量）。
长指令（max/min/addsl）因此前递无效、写回正常——依赖它们的指令从 PRF 或
EX2 写回总线拿数，多等 1 拍。

每位 `rslt_sel` 全 0（如 jal 的链接地址写由别处处理、纯 mtvr 指令）时 case 落
default 输出 x——RTL 靠 vld 信号保证 x 不会被消费，仿真中看到 fwd_data 为 x
不一定是 bug，先看 vld。

### 2.8 mtvr 通路（ct_iu_alu.v:1045-1091）

mtvr（整数→向量寄存器搬运）的执行体在 VFPU，ALU 只做"数据快递"：

```
EX1: iu_vfpu_ex1_pipex_mtvr_vld + vreg/vsew/vlmul/vl   （通知 VFPU 准备写）
EX2: iu_vfpu_ex2_pipex_mtvr_vld + src0                 （数据本体晚一拍送达）
```

控制信息早一拍、数据晚一拍的**两拍握手**：VFPU 用 EX1 信息做写口仲裁/旁路准备，
EX2 数据到了直接写，互不卡顿。`had_idu_wbbr_vld` 时数据可被调试器注入值替换
（ct_iu_alu.v:1081-1083，硬件调试 write-back-by-register 功能）。

---

## 3. 与上下游的接口汇总

| 方向 | 对端 | 信号组 | 说明 |
|------|------|--------|------|
| 入 | IDU rf_dp | `idu_iu_rf_pipex_*` | 操作数/功能码/rslt_sel 独热码 |
| 出 | RBUS | `alu_rbus_ex1_pipex_data/data_vld/fwd_data/fwd_vld/preg` | EX1 结果，RBUS 负责前递广播与 EX2 写回 |
| 出 | VFPU | `iu_vfpu_ex1/ex2_pipex_mtvr_*` | mtvr 两拍交付 |
| 入 | RTU | `rtu_yy_xx_flush` | 全局 flush 清 vld |
| 入 | HAD | `had_idu_wbbr_*` | 调试数据注入 |

ALU 自己**不直接连 CBUS**——pipe0/1 的完成信号由 CBUS 模块直接从
`idu_iu_rf_pipe0/1_sel + iid` 打拍生成（ALU 指令必然 2 拍完成，无需 ALU 汇报，
见 07_cbus.md）。这就是 L917-920 注释 "deal alu complete bus signal in cbus" 的含义。

---

## 4. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_alu0`（pipe0）/ `x_ct_iu_alu1`（pipe1）

| 信号 | 看什么 |
|------|--------|
| `idu_iu_rf_pipex_sel` vs `alu_ex1_inst_vld` | RF→EX1 一拍延迟关系 |
| `alu_ex1_rslt_sel[20:0]` | 独热码哪一位有效 = 当前指令类型 |
| `alu_rbus_ex1_pipex_fwd_vld/fwd_data` | 前递发生：下一拍依赖指令就能发射 |
| `alu_ex1_alu_short` | 0 = max/min/addsl 长指令，确认它不前递 |
| `rtu_yy_xx_flush` 与 `alu_ex1_inst_vld` 同拍 | flush 杀指令的瞬间 |

跑 coremark 时把两条 ALU 的 `alu_ex1_inst_vld` 摆在一起，可以直观看到双发射
的占空比——IPC 1.27 时大约一半的拍两条同时为高。
