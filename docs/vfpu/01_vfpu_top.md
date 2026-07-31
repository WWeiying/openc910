# C910 VFPU 顶层（top/ctrl/dp/cbus/rbus）详细教学文档

> RTL：
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_top.v`
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_ctrl.v`
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_dp.v`
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_cbus.v`
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/ct_vfpu_rbus.v`

本文描述生成后 Verilog 中实际生效的实例和赋值。带 `// &Instance`、
`// &Connect`、`// &ConnRule` 的行是生成器注释，不是 Verilog 实例或连接。

## 1. 顶层分工

`ct_vfpu_top` 本身以接线为主：

| 组件 | 负责什么 | 不负责什么 |
|---|---|---|
| `ctrl` | EX1~EX5 有效位、时钟门控请求、原始 EU 选择锁存 | 浮点运算 |
| `dp` | 操作数/目的信息流水、EU 选择压缩、结果来源汇聚 | ROB 顺序退休 |
| `cbus` | IDU 选择寄存后向 RTU 发送 `cmplt+iid` | 浮点数据写回 |
| `rbus` | FREG/EREG 写回、IDU 就绪和前递广播 | 判定指令可否退休 |
| 子执行单元 | fadd/fspu/fcnvt/vfmau/vfdsu 运算 | 全局资源回收 |

顶层当前实例化两份 VFALU、两份 VFMAU 和一份 VFDSU。VDSP 实例只以注释形式
保留，VDIV/VDSP 反馈接口在顶层固定为 0。

## 2. 入口信号如何理解

IDU 的 pipe6/pipe7 RF 接口同时提供：

- `sel`：该发射入口本周期有一条被选择的指令；
- `gateclk_sel`：允许相关寄存器的门控时钟提前打开；
- `eu_sel[11:0]`：执行资源选择；
- `func[19:0]`、`imm0`：具体操作和精度/模式；
- `srcv*_fr[63:0]`：当前有效的 64 位浮点源数据；
- `iid[6:0]`：ROB 身份；
- `dst_vreg/preg/ereg`：不同结果类别的目的编码。

`gateclk_sel` 不是“指令已被执行”，`sel` 也不是“结果已完成”。前者用于时钟
准备，后者表示本级接收事件；真正的数据写回和 ROB 完成有各自的有效信号。

## 3. ctrl：有效位传播

以 pipe6 为例，EX1 指令有效的主要来源为正常 IDU 选择和 IU 的 MTVR 注入：

```verilog
ctrl_ex1_pipe6_inst_vld_pre =
    idu_vfpu_rf_pipe6_sel || iu_vfpu_ex1_pipe0_mtvr_vld;
```

之后控制有效位逐级进入 EX2~EX5。pipe6 还包含两个特殊注入点：

- VFDSU 或保留 VDIV 的返回结果在 EX2 入口重新进入固定流水；
- VFDSU 返回相关控制参与后续 EX5 写回时隙。

这里的“重新注入”是**旧指令结果返回**，不是 IDU 又发射了一条新指令。分析统计
时若把 `pipe6_dp_vfdsu_inst_vld` 当成第二次发射，会重复计算指令数。

### 3.1 `inst_vld`、`data_vld`、`fwd_vld` 的区别

- `inst_vld`：该级有一条占用相应控制槽的指令；
- `data_vld`：该级对应结果类别已达到预定就绪阶段；
- `fwd_vld`：该级数据允许走前递路径；
- `mfvr_inst_vld`：该级存在 MFVR 类早出/搬移事件。

它们不是同义别名。一条指令可以在某级 `inst_vld=1`，但结果尚未
`data_vld`；某些结果已经产生，却因 `no_fwd` 条件不能作为合法前递源。

### 3.2 Flush

顶层有效位寄存器在 `rtu_yy_xx_flush` 时清零。这里“清零”指这些寄存器在有效
门控时钟沿进入 0，而不是组合信号在 flush 上升的同一瞬间无延迟消失。门控条件
通常把 flush 纳入开钟请求，确保清零沿能够到达。

## 4. 门控时钟：`local_en=0` 不是绝对停钟证明

每个 `gated_clk_cell` 还接收：

- `global_en = cp0_yy_clk_en`
- `module_en = cp0_vfpu_icg_en`
- `pad_yy_icg_scan_en`
- 个别单元的 `external_en`

`local_en` 表示本地功能逻辑是否请求开钟。扫描、全局或模块控制会改变最终门控
行为。因此文档只能说“空闲时本地请求可以关闭”，不能说“该时钟在所有模式一定
停止”或由此直接量化省下的动态功耗。

许多有效位时钟的 `local_en` 是“输入有效 OR 当前寄存器有效”。后一个条件用于
在流水尾部把原来的 1 更新回 0，否则寄存器会一直保持旧有效位。这是阅读门控
波形时很容易忽略的小细节。

## 5. dp：12 位选择到级间来源编码

pipe6 的压缩逻辑为：

```verilog
dp_ex2_pipe6_eu_sel_pre[0] = |ctrl_ex1_pipe6_eu_sel[2:0];
dp_ex2_pipe6_eu_sel_pre[1] = ctrl_ex1_pipe6_eu_sel[3]
                           || ctrl_ex1_pipe6_eu_sel[11];
dp_ex2_pipe6_eu_sel_pre[2] = ctrl_ex1_pipe6_eu_sel[4];
dp_ex2_pipe6_eu_sel_pre[3] = |ctrl_ex1_pipe6_eu_sel[10:5];
dp_ex2_pipe6_eu_sel_pre[4] = pipe6_dp_vfdsu_inst_vld
                           || vdivu_vfpu_ex1_pipe6_result_vld;
```

bit0~bit3 是原始请求的执行组归类，bit4 是变延迟返回来源。当前配置中 VDIV 和
VDSP 顶层反馈固定为 0，向量译码也关闭，所以 bit3 和 bit1 中的“保留向量来源”
不能写成当前已实例化能力。pipe7 还进一步把压缩后的 bit3 固定为 0，并且没有
pipe6 的变延迟返回 bit4；这说明两条管线的局部来源编码不是等宽对称结构。

pipe6 送入 VFALU 的选择为 `{1'b0, eu_sel[1:0]}`；pipe7 送入
`eu_sel[2:0]`。因此 fcnvt 的 bit2 在 pipe6 物理上被屏蔽，在 pipe7 才有对应实例。

## 6. CBUS：精确时序和语义

以 pipe6 为例：

```verilog
assign cbus_pipe6_cmplt = idu_vfpu_rf_pipe6_sel;

always @(posedge vfpu_pipe6_inst_clk or negedge cpurst_b)
  if (!cpurst_b || rtu_yy_xx_flush)
    cbus_pipe6_inst_vld <= 1'b0;
  else
    cbus_pipe6_inst_vld <= cbus_pipe6_cmplt;

assign vfpu_rtu_pipe6_cmplt = cbus_pipe6_inst_vld;
```

因此：

1. `idu_vfpu_rf_pipe6_sel` 是 CBUS 的输入事件；
2. 该值在 CBUS 有效位时钟沿被采样；
3. 寄存后的 `cbus_pipe6_inst_vld` 作为 RTU 完成输出；
4. IID 由数据门控时钟在对应输入事件时采样并同行输出。

由上述四步可见，IDU 选择经过一级 CBUS 寄存后才形成 RTU 完成事件，并不是在
选择组合有效的同一拍直接送到 RTU。

CBUS 逻辑只检查 pipe 选择，没有检查 `eu_sel`，所以 VFDSU 请求也进入 CBUS。
不能写成“CBUS 只服务定长单元”或“除法等待最终数据后才走完成总线”。

RTU 用 `cmplt+iid` 命中 ROB 项。这个事件与 FREG/EREG 的写回由不同逻辑管理。
它允许 ROB 更新该接口定义的完成记账，但事件直接源自 IDU 选择，不能把它解释
为子单元已经结束算术执行，也不能单独证明数据已经就绪、异常已经提交或该项
已经从 ROB 退休。

## 7. RBus：当前有效写回路径

RBus 接收：

- VFALU EX3 的 64 位结果和 5 位异常；
- VFMAU 不同阶段形成的结果、异常和前递信息；
- VFDSU 经 pipe6 固定流水重新注入后的结果；
- 各级目的寄存器编码和 ready-stage 控制。

当前 `rbus_pipe*_vreg_fr_wb_vld` 在目的编码最高位为 0 时有效，驱动浮点物理
寄存器路径；`rbus_pipe*_vreg_vr_wb_vld` 固定为 0，VR0/VR1 数据输出也固定为 0。
所以表述应为“七位通用目的编码中的 FREG 分支有效”，而不是“当前把结果写回
128 位 VREG”。

EREG 有独立的目的编号、5 位数据和写有效。子单元产生异常位只表示运算结果携带
异常信息；RBus 写 EREG 后，也还没有等价于体系结构 `fflags` 已经更新。精确
异常要求等到对应指令按序退休。

### 7.1 广播与前递

RBus 向 IDU 输出三类信息：

- 某个目的物理寄存器将在指定阶段就绪；
- 某个阶段已有可直接旁路的数据；
- EX5 已发生物理寄存器写回。

`data_vld` 可以用于唤醒，但消费者能否真正发射还要满足其他源操作数、功能单元
和端口条件。`_dup0...dup3` 是多个逻辑副本/复制链；将其解释为服务高扇出广播
是有结构依据的微结构推断，但具体时序收益必须看综合和布局布线结果。

## 8. 子单元接线

| 子单元 | pipe6 | pipe7 | 当前数据宽度/实例边界 |
|---|---|---|---|
| fadd | 1 份 | 1 份 | 每份当前标量 64 位路径 |
| fspu | 1 份 | 1 份 | 每份当前标量 64 位路径 |
| fcnvt | 无 | 1 份 | 当前标量转换路径 |
| vfmau | 1 份 | 1 份 | 每份只实例化 slice0 |
| vfdsu | 1 份 | 无 | 一个 64 位迭代实例 |
| vdsp/vdiv | 注释/固定零接口 | 注释/固定零接口 | 当前不构成有效执行路径 |

VFALU 的三个子算子有各自的 ctrl 和数据通路，只是选择互斥且共享 EX3 汇聚。
VFMAU 的 slice1 和 VFDSU 的 set1/multi-lane 描述出现在生成器注释中，并没有
出现在生成后有效实例列表。

## 9. 从波形验证一条指令

建议按同一 IID 或同一目的物理寄存器追踪：

1. `idu_vfpu_rf_pipe*_sel/eu_sel/func/iid`；
2. `ctrl_ex1_pipe*_inst_vld` 和相应子单元 `ex1_pipedown`；
3. 子单元的逐级 valid、前递 valid 和结果；
4. `ctrl_exN_pipe*_data_vld` 与 RBus 目的编码；
5. `vfpu_idu_*fwd*` 或 `*wb*`；
6. `vfpu_rtu_pipe*_cmplt/iid`；
7. RTU/ROB 中对应 IID 的完成、异常和退休条件。

只看 CBUS 会漏掉数据何时可用，只看 RBus 会漏掉 ROB 何时记账，只看退休又无法
判断中间依赖是靠前递还是寄存器写回解除。

## 10. 结论

VFPU 顶层的核心不是一个单独的“浮点五级流水”，而是一个把短流水、深流水和
迭代单元统一接入两条后端端口的控制/数据汇聚层。它通过 CBUS、RBus、物理浮点
寄存器状态表和 ROB 的分工，把“执行完成”“数据就绪”“异常保存”“顺序退休”
拆成不同事件。理解这些边界，比记住信号名中的 EX 编号更重要。
