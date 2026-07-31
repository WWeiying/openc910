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

注意这份 RTL 里有大量 T-Head 自定义操作（addsl/ext/extu/mveqz/tstnbz/
ff1/rev 等）。RTL 能证明执行单元支持相应功能码，但不能仅凭模块名把每条操作
精确归入某个编译器 `-march` 扩展字符串；不同版本的 Xuantie 工具链可能把多组
XThead 子扩展打包或采用不同命名。确认某个二进制是否真正使用这些硬件，应以
该工具链的 `-march` 帮助、编译器生成的反汇编和动态执行轨迹为准。

同样，开启扩展前后的 CoreMark 分数变化不能全部归因于 ALU 新指令。扩展还可能
改变代码尺寸、对齐、分支布局和访存序列。可靠归因至少要同时比较：静态指令数、
关键函数反汇编、动态指令数、周期数、分支误预测和 I-Cache 行为。

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

`rslt_sel[20:0]` 采用 **21 位独热形式**，由 IDU 在进入执行单元之前生成（见
`docs/idu/19_rf_dp.md` 的 pipe0/1 译码）。与在 EX1 再把一个紧凑二进制操作码
完整译成各个结果选择条件相比，这种接口把大部分“当前要哪一种结果”的信息提前
展开；EX1 可以直接按位选择各候选结果。这里能由 RTL 确认的是**译码位置前移和
选择条件展开**，不能仅凭独热编码断言综合网表一定只有“一层 AND-OR”，也不能
在没有时序报告时断言 RF 级一定更松。综合器仍可能重构选择网络，最终逻辑深度、
扇出和关键路径应以综合/STA 结果为准。

注意第二组 parameter（ADDER_MAX 等）**复用了低 6 位的位型**：max/min/addsl
这些“长结果路径”操作（`alu_short=0`）单独使用一套选择树（见 2.7）。例如
`ADDER_MAX=21'h1` 与短路径的 `ADDER_ADD=21'h1` 数值相同，但二者由
`alu_short` 选择不同结果树，因此语义不冲突。也就是说，`rslt_sel` 的值不能
脱离 `alu_short` 单独解释；看波形时必须把两个信号放在一起。

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
2. **flush 只清 vld 不清数据**：在 `rtu_yy_xx_flush` 被采样的有效时钟沿，
   `alu_ex1_inst_vld/alu_ex1_fwd_vld` 被清零；数据寄存器可以继续保留旧位型。
   旧数据是否存在并不重要，关键是所有消费端都必须用 valid 限定它。这里应说
   “减少了数据寄存器复位/清零控制”，而不能只由 RTL 推导出准确的物理扇出收益。

数据部分（ex1_inst_clk 域，ct_iu_alu.v:354-425）值得注意的是源操作数在 RTL
中被**复制成三组寄存器名**：`alu_ex1_src0/1`、`alu_ex1_adder_src0/1`、
`alu_ex1_shifter_src0/1`（ct_iu_alu.v:387-392）。三组保存相同输入，分别供
misc、adder 和 shifter 路径使用。这种写法明显为分离负载、便于物理实现提供了
结构条件，但综合器是否保留三份寄存器、如何复制驱动和布线，仍由约束与综合/
布局布线结果决定；不应把 RTL 中的三个变量直接等同于版图中必然存在的三套触发器。

另外 `eu_sel[2:0]` 在 RF 级由 rslt_sel 按段归并（ct_iu_alu.v:350-352）：

```verilog
assign idu_iu_rf_pipex_eu_sel[0] = |idu_iu_rf_pipex_rslt_sel[4:0];    // adder 组
assign idu_iu_rf_pipex_eu_sel[1] = |idu_iu_rf_pipex_rslt_sel[9:5];    // shifter 组
assign idu_iu_rf_pipex_eu_sel[2] = |idu_iu_rf_pipex_rslt_sel[20:10];  // other 组
```

EX1 的短结果路径再用这个 3 位独热码在 adder、shifter、other 三组候选中选择，
也就是**三组结果选择**，不是 4:1 选择。若 `eu_sel` 不是合法 one-hot，case
会落入 `default` 或不能表达预期语义；正确性依赖 IDU 生成合法编码。

### 2.4 加法器组（ct_iu_alu.v:427-488）

```verilog
assign adder_data_out_add[63:0]  = src0 + src1;        // L436
assign adder_data_out_sub[63:0]  = src0 - src1;        // L438
assign adder_data_out_subw[31:0] = src0[31:0] - src1[31:0];
assign adder_data_out_addw[31:0] = src0[31:0] + src1[31:0];
```

RTL 分别写出了 64 位加、64 位减、32 位加和 32 位减四个并行候选表达式，选择在
其后完成。这种结构避免在源代码层先把所有操作合并成一个带复杂输入选择的算术
表达式，体现了用并行候选换取较直接选择路径的意图。但“综合网表中一定有四个
彼此独立的加法器”不能由这几行 RTL 单独证明：综合器可能共享、拆分或重构算术
逻辑，准确面积和关键路径必须查看综合网表与时序报告。

**addsl（add with shift，ct_iu_alu.v:447-461）**：`rd = src0 + (src1 << imm[1:0])`，
对应 T-Head `th.addsl`，可把若干 `base + index*2^n` 地址形成模式压成一条指令。
它对某个 benchmark 的实际贡献取决于编译器是否生成该指令以及动态执行次数；
不能在没有反汇编和动态轨迹的情况下断言它是 CoreMark 的高频指令或主要提分来源。

**比较与 max/min（ct_iu_alu.v:466-488）**：

```verilog
assign adder_sltu  = src0[63:0] < src1[63:0];                   // 64 位无符号
assign adder_sltuw = src0[31:0] < src1[31:0];                   // 32 位无符号
assign adder_slts  = $signed(src0[63:0]) < $signed(src1[63:0]); // 64 位有符号
assign adder_sltsw = $signed(src0[31:0]) < $signed(src1[31:0]); // 32 位有符号
assign adder_rslt_slt = adder_inst_cmp_unsign ? adder_sltu : adder_slts;
assign adder_sltw     = adder_inst_cmp_unsign ? adder_sltuw : adder_sltsw;
assign adder_rslt_max[63:0] = adder_rslt_slt ? src1 : src0;
```

RTL 并行形成 64/32 位、有符号/无符号四个比较候选，再由
`adder_inst_cmp_unsign` 选择当前指令所需结果。max/min 直接复用选中的 slt
结果控制两个源操作数的多路选择，因而没有再写一套独立的 max/min 比较表达式。
至于综合后比较逻辑是否共享、共享到什么程度，要以综合网表为准。

### 2.5 移位器组（ct_iu_alu.v:490-689）

左移直接用 `<<`。右移的实现值得细看（ct_iu_alu.v:503-512）：

```verilog
assign shifter_r_shift_in[63:0] = src0 & {64{func[4]}}              // 循环移位时补 src0 自身
                                | {64{func[1] && src0[63]}};        // 算术移位时补符号
assign shifter_r_rslt[127:0]    = {shifter_r_shift_in, src0} >> src1[5:0];
```

RTL 用一个 128 位拼接值的右移表达式统一描述 srl/sra/循环右移：高 64 位按
指令类型填 0、符号位或原数据，移完取低 64 位。这个写法让三种操作共享同一套
“拼接后右移”的逻辑描述；综合后是否实现为一套共享桶形移位网络、网络具体宽度
以及面积收益，需要由综合结果确认，不能把 Verilog 的一个 `>>` 运算符直接当成
一个确定的物理宏单元。

**ext/extu 位段提取（ct_iu_alu.v:517-689）**：T-Head `th.ext rd,rs,msb,lsb` =
取 rs[msb:lsb] 并符号/零扩展。实现分三步：

1. `shifter_ext_shift = src0 >> lsb`（复用右移路径的输入，src1[5:0]=lsb）；
2. 64 项查找表 `shifter_extu_mask`（L520-586）按字段宽度 imm 生成低位掩码；
3. 64 项查找表 `shifter_ext_sign`（L591-670）按 src1[11:6]=msb 直接取出符号位，
   再用 and_mask/or_mask 完成零扩展或符号扩展（L674-689）：

```verilog
assign shifter_ext_rslt = shifter_ext_shift & shifter_ext_and_mask | shifter_ext_or_mask;
```

两个 64 项 case 在逻辑意义上是按 6 位索引选择 64 个候选。综合后的具体门级
拓扑、逻辑深度和是否满足目标频率取决于综合器优化、标准单元库和物理布局，不能
仅由 `case` 项数断言为严格 6 级或“完全可接受”。体系结构意图仍然清楚：
**为什么符号位单独查表而不是从移位结果取 bit[width-1]？**——那样
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

结果选择结构：

```
 adder 组结果 ─case(rslt_sel[4:0])──► alu_ex1_adder_fwd_data ──┐
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
长结果路径操作（max/min/addsl）因此不声明该 ALU 的 EX1 快速前递有效，但仍
通过正常数据写回路径产生结果。消费者具体多等几拍取决于 IDU 的唤醒、RBUS
广播/PRF 写回时序和是否存在其他 stall；本文能直接确认的是它们不能使用这里的
`alu_rbus_ex1_pipex_fwd_vld` 快速前递，不能仅凭该位推导所有场景固定多等一拍。

每位 `rslt_sel` 全 0（例如只借用 ALU 管线向 VFPU 传递数据的 `mtvr`）时 case
落 default 输出 x。RTL 靠对应的结果有效信号保证该 x 不会作为整数 ALU 结果
被消费；仿真中看到 `fwd_data` 为 x 时，应先联合检查 `data_vld/fwd_vld`。
jal/jalr 的链接值不属于这里的 ALU 结果，而由 Pipe0 SPECIAL 的
`PSEUDO_AUIPC` 微操作产生。

### 2.8 mtvr 通路（ct_iu_alu.v:1045-1091）

mtvr（整数→向量寄存器搬运）的执行体在 VFPU，ALU 只做"数据快递"：

```
EX1: iu_vfpu_ex1_pipex_mtvr_vld + vreg/vsew/vlmul/vl   （通知 VFPU 准备写）
EX2: iu_vfpu_ex2_pipex_mtvr_vld + src0                 （数据本体晚一拍送达）
```

控制信息在 EX1 接口出现，数据在 EX2 接口出现，形成分拍传递关系。RTL 能确认
这两个接口的时序与字段，至于 VFPU 内部如何仲裁、是否发生停顿，应继续沿 VFPU
接收端核查，不能只从 IU 发送端概括为“互不卡顿”。`had_idu_wbbr_vld` 时数据可
被调试器注入值替换（ct_iu_alu.v:1081-1083，硬件调试 write-back-by-register
功能）。

还要区分**接口存在**与**当前顶层配置的端到端功能完整**：本模块确实生成 mtvr
送往 VFPU 的接口；但当前所核查顶层中的向量重命名/退休相关 VRT、VREG PST 路径
存在 dummy 常量边界。因此，这一节只能证明 IU 侧 mtvr 发送机制，不能单独证明
当前配置具备完整可用的向量架构状态提交能力。

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
`idu_iu_rf_pipe0/1_sel + iid` 打拍生成。准确地说，这是因为该类 ALU 操作在
这条数据通路中不产生执行期异常，CBUS 可以在 RF 接受后推定其执行成分会完成；
并不是等到“2 拍结果已写回”才收到 ALU 的实报。CBUS `cmplt` 与 RBUS 的 preg
数据写回属于两条不同协议。这就是 L917-920 注释
`deal alu complete bus signal in cbus` 的含义。

---

## 4. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_alu0`（pipe0）/ `x_ct_iu_alu1`（pipe1）

| 信号 | 看什么 |
|------|--------|
| `idu_iu_rf_pipex_sel` vs `alu_ex1_inst_vld` | RF→EX1 一拍延迟关系 |
| `alu_ex1_rslt_sel[20:0]` | 独热码哪一位有效 = 当前指令类型 |
| `alu_rbus_ex1_pipex_fwd_vld/fwd_data` | EX1 快速前递有效及数据；依赖者是否紧邻发射还要结合 IDU ready/issue 与端口竞争 |
| `alu_ex1_alu_short` | 0 = max/min/addsl 长指令，确认它不前递 |
| `rtu_yy_xx_flush`、`forever_cpuclk` 与 `alu_ex1_inst_vld` | flush 在有效沿被采样后清 valid；不要把电平同拍误解为异步立即删除数据 |

跑 CoreMark 时把两条 ALU 的 `alu_ex1_inst_vld` 摆在一起，可以直观看到 ALU
双发射的实际占空比。不要从整机 IPC 直接推算“两条 ALU 同时有效”的比例；IPC
还包含分支、访存、乘除、浮点/向量以及折叠退休计数。应直接统计
`alu0_vld && alu1_vld`、`alu0_vld || alu1_vld` 和各自单独有效的周期数。
