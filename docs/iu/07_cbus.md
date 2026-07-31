# C910 IU 完成总线详解（ct_iu_cbus）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_cbus.v`（585 行）
>
> CBUS（Complete Bus）把 IU 三条管线上各单元的"指令完成 + 异常信息"汇总、
> 仲裁、打拍后送 RTU 的 ROB。它不传数据（数据归 RBUS 管），只传**状态**。

---

## 1. 三条管线的完成信号从哪来

```
pipe0:  ALU(RF级sel即推定) ─┐
        DIV(RF级sel即推定) ─┤
        SPECIAL(EX1实报)   ─┼─► 四源合一 → 打一拍 → iu_rtu_pipe0_*（EX2 视角）
        CP0(EX3实报)       ─┘
pipe1:  ALU(RF级sel即推定) ─┬─► 二源合一 → 打一拍 → iu_rtu_pipe1_*（只有cmplt+iid）
        MULT(RF级sel即推定)─┘
pipe2:  BJU(EX2已打好拍)  ────► 纯改名直通 → iu_rtu_pipe2_*
```

### 关键设计决策：**"推定完成"（presumed complete）**

```verilog
// ct_iu_cbus.v:296-299
assign cbus_pipe0_cmplt = idu_iu_rf_pipe0_sel        // ALU 指令: RF 级就算完成!
                       || idu_iu_rf_div_sel          // 除法: RF 级就算完成!
                       || special_cbus_ex1_inst_vld  // special: EX1 实际汇报
                       || cp0_iu_ex3_inst_vld;       // CSR: EX3 实际汇报
```

ALU/MULT/DIV 的选择信号**在 RF 被接受时就进入“推定完成”路径**，经
`cbus_pipe*_inst_vld` 打一拍后报给 RTU。它们不等待乘除数据真正产生。这里先
限定术语：`cmplt` 表示 ROB 收到了该执行成分的完成记账，不表示目的 preg 已有
可读数据，也不等于一条折叠 ROB entry 内所有微操作都已完成。

1. 这些已被正确译码并接受的整数运算在执行单元内没有同步 trap 结果需要等待；
2. `rtu_yy_xx_flush` 会清除 CBUS 仍寄存着的完成 valid。更年轻的错误路径操作
   在后端 flush 到来前仍可能把 cmplt 写进其推测 ROB 项，这本身允许存在；后续
   ROB flush 会整体作废这些项，不能把正确性解释成“错误路径完成从不进入 RTU”；
3. 消费者的数据相关性由 preg 的 ready/writeback 广播单独约束，所以长延迟
   MULT/DIV 即使先报 `cmplt`，依赖者也仍会等真正的数据路径；
4. ROB 对折叠 entry 还会统计多个完成成分，不能把任意一个 pipe 的单次 cmplt
   等同于整个 entry 已满足退休条件。

收益是把“无异常执行成分的控制记账”从“结果数据到达”中解耦，缩短 ROB
完成路径。它确实可能使相关 entry 更早满足完成条件，但整机仍要靠 RTU/PST、
物理寄存器释放和 flush 协议维持精确状态，不能概括成“退休完全不受执行延迟
影响”。

而 SPECIAL/CP0 可能产生异常和 flush 元数据，必须等相应执行级形成这些字段后
再上报。这里的“实报”指等待控制结果，不表示 CBUS 同时携带了写回数据。

---

## 2. 逐逻辑块讲解

### 2.1 pipe0 四源选择（L322-374）

四个源头的 iid/异常信息用独热 AND-OR 合并：

```verilog
assign cbus_pipe0_src_iid = {7{rf_pipe0_sel}} & rf_pipe0_iid
                          | {7{rf_div_sel}}   & rf_pipe0_iid       // div 共用 pipe0 iid 端口
                          | {7{special_vld}}  & special_iid
                          | {7{cp0_vld}}      & cp0_iid;
```

无优先级仲裁器，接口协议要求同拍最多一个源有效：pipe0 一拍只发射一条指令
（ALU/DIV/SPECIAL 互斥），CP0 的 ex3 汇报与 RF 发射间隔由 IDU 的 CSR
串行化机制保证不重叠。硬件只做合并不做裁决——调度的复杂度留在 IDU，
完成路径保持极简。

异常信息逐项归属（L328-374）：

| 字段 | 可能来源 | 说明 |
|------|----------|------|
| `abnormal` | special / cp0 | 退休时需特殊处理 |
| `expt_vld/expt_vec` | special / cp0 | 真异常 |
| `bkpt` | special | ebreak 断点 |
| `vsetvl` | special | vsetvl 类 flush |
| `vstart_vld/vstart` | special | vstart 清零请求 |
| `immu_expt` | special | 取指 MMU 异常标记 |
| `mtval` | special / cp0 | 异常值（或 vsetvl 配置包） |
| `flush` | special / cp0 | 退休后 flush 请求（CSR 写副作用等） |
| `efpc_vld/efpc` | cp0 仅有 | 异常返回 PC 重定向（如 dret/特殊 CSR） |

### 2.2 双时钟域的功耗细节（L376-483）

完成寄存器分两个门控域：

```verilog
assign pipe0_data_clk_en     = cbus_pipe0_gateclk_cmplt;            // iid+abnormal: 每次完成都翻
assign pipe0_abnormal_clk_en = cbus_pipe0_gateclk_cmplt
                               && (gateclk_src_abnormal || cbus_pipe0_abnormal);  // L398-400
```

12 个异常字段寄存器（expt_vec/mtval/efpc 等约 90 bit）**只在“本次完成带
abnormal 或上一次保存的是 abnormal、需要写回正常值清除”时开钟**（L438 注释
`power optimization: clock enable only when abnormal complete`）。正常完成
不会持续翻转这组异常负载寄存器；实际开钟率取决于 workload 中 abnormal/normal
交替情况，不能从 RTL 给出固定发生率。

### 2.3 pipe1：极简版（L501-567）

```verilog
assign cbus_pipe1_cmplt = idu_iu_rf_pipe1_sel || idu_iu_rf_mult_sel;
```

pipe1 上只有 ALU 和 MULT，都无异常——所以 pipe1 的完成报文只有
`cmplt + iid` 两个字段，连 abnormal 位都没有。接口宽度按管线能力裁剪。

### 2.4 pipe2：纯透传（L569-580）

```verilog
//pipe2 complete signals are flopped by BJU, only rename in cbus
assign iu_rtu_pipe2_cmplt       = bju_cbus_ex2_pipe2_sel;
assign iu_rtu_pipe2_abnormal    = bju_cbus_ex2_pipe2_abnormal;     // = 误预测
assign iu_rtu_pipe2_bht_mispred = ...; iu_rtu_pipe2_jmp_mispred = ...;
```

BJU 在自己的 EX2 寄存器里已经打好拍（02_bju.md 2.7），CBUS 只改个名。
分支的 `abnormal` 含义与 pipe0 不同：**不是架构异常，而是误预测恢复元数据**。
该分支到达退休 inst0 后，retire 走 `FLUSH_IS`/可选 `WF_EMPTY`，最终发出
`rtu_yy_xx_flush`；它不是 `FLUSH_FE` 路线。

---

## 3. 时序汇总

| 管线 | 指令 | 完成报到 RTU 的拍 | 实际数据写回拍 |
|------|------|------------------|----------------|
| pipe0 | ALU | EX1 末（RF+1） | EX2 |
| pipe0 | DIV | RF 选择经一拍到 CBUS | 变延迟；按 `rf_div_sel` 到 `div_rbus_*_data_vld` 实测 |
| pipe0 | SPECIAL | EX2 末（EX1 实报+1 拍） | EX2 |
| pipe0 | CSR(CP0) | EX4 末（EX3 实报+1 拍） | EX4（经 rbus ex3 通道） |
| pipe1 | ALU/MULT | EX1 末 | EX2 / EX4 |
| pipe2 | BJU | EX2（BJU 已打拍） | 无数据写回 |

---

## 4. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_cbus`

| 信号 | 看什么 |
|------|--------|
| `iu_rtu_pipe0/1/2_cmplt + iid` | 三条管线完成节拍；与 RTU 侧 ROB cmplt 置位对照 |
| `idu_iu_rf_pipe0_sel` → `iu_rtu_pipe0_cmplt` | 一拍延迟的"推定完成" |
| `iu_rtu_pipe0_expt_vld/expt_vec/mtval` | 异常注入 ROB 的瞬间（跑 exception case） |
| `iu_rtu_pipe2_abnormal/bht_mispred` | 误预测标记随完成流向 RTU |

把 `iu_idu_div_busy` 和 `iu_rtu_pipe0_cmplt` 摆在一起看除法：完成早早报了，
busy 还高着——这就是"完成≠写回"的波形证据。
