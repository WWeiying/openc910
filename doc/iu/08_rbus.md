# C910 IU 结果总线详解（ct_iu_rbus）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_rbus.v`（660 行）
>
> RBUS（Result Bus）是 IU 两个整数写回端口（pipe0/pipe1）的汇聚点：多个执行
> 单元的结果在这里合流，打一拍后广播给 IDU（写 PRF + 唤醒）和 RTU（PST 就绪）。
> 它还透传 EX1 前递信号。结构与 CBUS 镜像对称——CBUS 管状态，RBUS 管数据。

---

## 1. 两个写回端口的共享者

| 端口 | 共享单元 | 各自写回拍 |
|------|----------|-----------|
| pipe0 | ALU0(EX1) / DIV(变延迟) / SPECIAL(EX1) / CP0(EX3) / VFPU pipe6 mfvr(EX2) | 5 个源 |
| pipe1 | ALU1(EX1) / MULT(EX3 预告+EX4 数据) / VFPU pipe7 mfvr(EX2) | 3 个源 |

```
            EX1(各源汇聚拍)                EX2(广播拍)
 ALU0 ──┐
 DIV  ──┤  5 选 1（独热 case）   打拍   ┌─► iu_idu_ex2_pipe0_wb_preg_vld/preg(+dup0~4)/data
 SPEC ──┼─► rslt_preg/rslt_data ─────► ├─► iu_idu_ex2_pipe0_wb_preg_expand[95:0] → PRF 写使能
 CP0  ──┤        │                     └─► iu_rtu_ex2_pipe0_wb_preg_vld/expand → PST
 mfvr ──┘        └─ expand_96 预展开
 （pipe1 同构，3 选 1）
```

**为什么多个源能共享一个端口而不会撞车？** 全靠上游的发射纪律：
- ALU 与 DIV/SPECIAL 同管线互斥发射（IDU 保证）；
- DIV 写回前用 `iu_idu_div_wb_stall` 清场（见 05_div.md 1.2）；
- CP0 的 CSR 指令被 IDU 串行化（CSR 指令发射后管线排空）；
- mfvr 由 VFPU 侧的调度保证与整数写回不同拍。

RBUS 里看不到任何仲裁逻辑（case 是独热选择不是优先级裁决），**写回端口冲突
在发射端就被消灭了**——这是乱序核常见分工：仲裁前移、数据通路后端保持哑。

---

## 2. 逐逻辑块讲解

### 2.1 pipe0 写回有效（L318-344）

```verilog
assign rbus_pipe0_rslt_vld = alu_vld || div_vld || special_vld || cp0_vld || mfvr_vld;

always @(posedge rslt_vld_clk ...)
    rbus_pipe0_wb_vld[6:0] <= {7{rbus_pipe0_rslt_vld}};   // 7 份物理复制
```

打拍后的 7 份复制各有去处（L337-344）：dup0~4 给 5 个发射队列做唤醒比较，
[5] 给 PRF 写口，[6] 给 RTU 的 PST。**flush 时清零**（L331-332）——这一点
很重要：错误路径指令的"写回"会被压住，PRF 不被污染（数据寄存器不清，但
vld=0 使写使能无效）。

### 2.2 preg/data 选择（L349-405）

```verilog
case ({special_vld, mfvr_vld, cp0_vld, div_vld, alu_vld})   // 独热
  5'h01: preg = alu_preg;   5'h02: preg = div_preg;  ...
```

数据选择同构（L380-405）。`alu_rbus_ex1_pipe0_data_aft_wbbr`（L376-378）：
HAD 调试器的 wbbr（write back by register）可以劫持 ALU 写回值——调试器改
寄存器就是从这里注进去的。

### 2.3 preg 的 96 位独热展开（L407-412）

```verilog
ct_rtu_expand_96 x_..._rslt_preg (.x_num(rbus_pipe0_rslt_preg),
                                  .x_num_expand(rbus_pipe0_rslt_preg_expand));
```

7 位 preg 在**打拍前**展开成 96 位独热（C910 整数 PRF 共 96 项物理寄存器），
锁存后直接送出：
- IDU 的 PRF 拿它当**写使能位图**（免译码）；
- RTU 的 PST 拿它当**就绪置位位图**（96 项寄存器状态各自或上一位）。

又是"译码前移过寄存器"——消费端零译码逻辑。注意展开发生在选择之后、打拍
之前：96 位寄存器比 7 位贵，但两个消费者都要独热码，集中展开一次最划算。

### 2.4 写回数据寄存器（L440-484）

preg 打 6 份 dup + expand 96 位 + data 64 位，约 230 bit 寄存器，时钟仅在
`rslt_vld` 时开（L418）。输出直连 IDU/RTU。

### 2.5 pipe1 的 MULT 特殊处理（L500-647）—— 预告与数据错拍

```verilog
assign rbus_pipe1_rslt_vld = alu_vld || mult_rbus_ex3_data_vld || mfvr_vld;  // 注意是 ex3!
...
// L643-645: 数据输出却看 ex4
assign iu_idu_ex2_pipe1_wb_preg_data = mult_rbus_ex4_data_vld
                                       ? mult_rbus_ex4_data : rbus_pipe1_wb_data;
```

这是 RBUS 最微妙的地方，对应 04_mult.md 的"EX3 预告/EX4 数据"：

```
拍 N  (mult EX3): rslt_vld=1，preg 进寄存器 → 拍 N+1 wb_preg_vld/preg 广播（唤醒）
拍 N+1(mult EX4): mult_rbus_ex4_data_vld=1，数据**组合 bypass** 进输出端
```

即**控制信息走寄存器、数据晚一拍走旁路 mux**，两者在广播拍精确对齐。
消费者在唤醒拍发射、下一拍 RF 抓数，时序刚好闭环。L552 注释
"mult data is available at EX4" 点明此事。
（ALU 数据则规规矩矩跟着 preg 一起锁存——`rbus_pipe1_wb_data` 里存的永远
是 ALU/mfvr 的数据，乘法数据从不进这个寄存器，省 64 bit 翻转。）

### 2.6 前递透传（L489-492, 652-655）

```verilog
//ex1 forward path: only alu0
assign iu_idu_ex1_pipe0_fwd_preg_vld  = alu_rbus_ex1_pipe0_fwd_vld;
assign iu_idu_ex1_pipe0_fwd_preg_data = alu_rbus_ex1_pipe0_fwd_data;
```

EX1 前递**只有 ALU 短指令**（注释 "only alu"）：不打拍、纯改名直通 IDU 前递
网络（`doc/idu/20_rf_fwd.md`）。DIV/MULT/SPECIAL/CP0 都不前递——它们的消费者
最早从 EX2 写回广播拿数。前递路径是全核最紧的时序，必须只留最简单的源。

---

## 3. 一张表总结 IU 数据就绪时刻（消费者视角）

| 生产者指令 | 消费者最早拿到数据的途径 | 生产→消费最小间隔 |
|-----------|------------------------|------------------|
| ALU 短指令 | EX1 前递 | 1 拍（背靠背） |
| ALU 长指令(max/min/addsl) | EX2 写回广播 | 2 拍 |
| MULT | EX3 唤醒 + EX4 数据 bypass | 4 拍 |
| MLA→MLA 累加链 | 乘法器私有前递 | 2 拍 |
| DIV | 写回广播（变延迟） | 6~22 拍 |
| CSR(CP0) | EX3 写回 rbus → EX4 广播 | 4 拍 |
| mfvr | EX2 → EX3 广播 | 3 拍 |

---

## 4. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_rbus`

| 信号 | 看什么 |
|------|--------|
| `rbus_pipe0_rslt_vld` 的 5 个源 vld | 同拍永远至多一个为高（共享端口纪律） |
| `iu_idu_ex1_pipe0_fwd_preg_vld` vs `iu_idu_ex2_pipe0_wb_preg_vld` | 同一条 ALU 指令前递比写回早一拍 |
| `mult_rbus_ex3_data_vld` → `iu_idu_ex2_pipe1_wb_preg_vld` → `mult_rbus_ex4_data_vld` | 乘法预告/数据错拍对齐 |
| `iu_idu_ex2_pipe0_wb_preg_expand` | 96 位独热位图，哪位为 1 就是写哪个 preg |

至此 IU 文档完结。建议回到 [00_iu_overview.md](00_iu_overview.md) 把第 5 节
的两条指令生命周期重新走一遍——现在每一站的内部细节你都见过了。
