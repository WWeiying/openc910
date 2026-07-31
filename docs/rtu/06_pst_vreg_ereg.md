# C910 浮点、向量与 EREG 物理状态管理

本文解释 RTU 中浮点物理寄存器状态表、向量物理寄存器状态表和 EREG
物理状态表。阅读时必须先区分两件事：

1. 仓库里有哪些可复用 RTL 模块；
2. 当前 `ct_rtu_top.v` 顶层实际例化了哪些模块。

只看模块文件名或生成器留下的 `// &Instance(...)` 注释，会把“设计曾经支持或
准备支持的配置”误认为“当前 RTL 已启用的硬件”。本文结论以当前顶层的有效
Verilog 实例为准。

## 1. 当前配置的准确结论

相关 RTL：

- `ct_rtu_top.v`
- `ct_rtu_pst_vreg.v`
- `ct_rtu_pst_vreg_entry.v`
- `ct_rtu_pst_vreg_dummy.v`
- `ct_rtu_pst_ereg.v`
- `ct_rtu_pst_ereg_entry.v`
- `ct_idu_rf_prf_eregfile.v`
- `ct_idu_rf_prf_gated_ereg.v`
- `ct_vfpu_rbus.v`
- `ct_cp0_regs.v`

当前顶层实际配置如下：

| 状态域 | 顶层实例 | 有效实现 | 规模 | 当前功能 |
|---|---|---|---:|---|
| 浮点物理寄存器 | `x_ct_rtu_pst_freg` | `ct_rtu_pst_vreg` | 64 项 | 完整分配、退休、释放、写回跟踪和恢复 |
| 向量物理寄存器 | `x_ct_rtu_pst_vreg_dummy` | `ct_rtu_pst_vreg_dummy` | 无活动表项 | 接口占位，分配有效恒为 0 |
| 浮点/向量状态贡献 | `x_ct_rtu_pst_ereg` | `ct_rtu_pst_ereg` | 32 项 | 管理推测执行产生的 `fflags` 等状态贡献 |

因此，当前 RTL **不是**“完整的 64 项浮点 PST 和完整的 64 项向量 PST 各例化
一份”。准确说法是：

> 完整的 64 项通用 `vreg` 型 PST 被用于浮点物理寄存器；向量 PST 在当前顶层
> 由 dummy 模块替代；此外还有一套独立的 32 项 EREG PST。

`ct_rtu_pst_vreg.v` 的完整源码仍然存在，`ct_rtu_top.v` 中也保留了完整向量
PST 的生成器注释和端口连接注释。这只能证明代码库保留了完整实现，不能证明
当前顶层正在使用它。

## 2. 为什么浮点 PST 复用名为 vreg 的模块

`ct_rtu_pst_vreg` 的名字容易引起误解。这个模块的核心职责不是保存浮点或
向量数据，而是管理一组 64 项物理寄存器的生命周期：

```text
空闲物理项
  -> 进入预分配槽
  -> 被重命名指令占用
  -> 对应指令退休
  -> 被后续版本释放
  -> 等待数据写回完成后重新空闲
```

只要物理寄存器编号宽度、表项数量、分配宽度、退休协议和写回位图接口相同，
同一个状态管理模块就可以复用。当前顶层通过端口重命名，把
`ct_rtu_pst_vreg` 的通用 `xreg/vreg` 端口连接到浮点 `freg` 信号。

这不表示浮点寄存器与向量寄存器在体系结构上是同一组寄存器，也不表示两类
数据共享同一个物理寄存器文件。它只表示二者在“物理编号生命周期管理”这个
局部问题上可以使用同一种控制结构。

## 3. 当前向量 PST dummy 到底做了什么

有效实例是：

```verilog
ct_rtu_pst_vreg_dummy x_ct_rtu_pst_vreg_dummy (...);
```

dummy 模块接收完整向量 PST 原本会接收的分配、派发、写回和释放接口，但不
保存任何状态。其关键输出是常量：

```verilog
assign pst_retired_xreg_wb            = 1'b1;
assign rtu_idu_alloc_xreg0_vld        = 1'b0;
assign rtu_idu_alloc_xreg1_vld        = 1'b0;
assign rtu_idu_alloc_xreg2_vld        = 1'b0;
assign rtu_idu_alloc_xreg3_vld        = 1'b0;
assign rtu_idu_rt_recover_xreg[191:0] = 192'b0;
```

各常量的含义如下：

- `alloc_xreg*_vld=0`：不向 IDU 提供任何可分配的向量物理寄存器；
- `recover_xreg=0`：不提供有效的向量退休映射用于重命名恢复；
- `pst_retired_xreg_wb=1`：从 RTU flush 等待逻辑的角度，向量物理状态永远不会
  因“已退休但尚未写回”而阻塞。

这里的 `pst_retired_xreg_wb=1` 不是“所有向量结果都已经正确写回”的性能事件，
而是 dummy 配置用于解除等待条件的常量。波形中看到它长期为 1，不能据此
推导真实向量执行延迟或向量寄存器写回吞吐。

同理，在当前配置里观察 `x_ct_rtu_pst_vreg_dummy` 的输入翻转，最多能说明
上游接口有活动，不能说明向量物理状态机真的分配了表项。判断功能是否活动
必须同时看输出分配有效位和有效实例类型。

## 4. 完整浮点 PST 的结构

当前 `x_ct_rtu_pst_freg` 是完整的 64 项 PST。它与整数 PST 使用相同的基本
思想，但物理编号宽度、表项数量和写回源不同。

| 属性 | 整数 PREG PST | 当前浮点 FREG PST |
|---|---:|---:|
| 物理项数 | 96 | 64 |
| 物理编号宽度 | 7 位 | 6 位 |
| 分配接口与新选择链 | 4 个位置输出；3 条独立新空闲选择链，slot3 复用 slot0/1 选择结果补位 | 4 个位置输出；4 条独立新空闲选择链 |
| 退休匹配槽 | 3 个 ROB 退休槽 | 3 个 ROB 退休槽 |
| 主要写回源 | IU、LSU、部分 VFPU | LSU pipe3、VFPU pipe6/7 |
| 恢复映射 | 32 个逻辑整数寄存器 | 32 个逻辑浮点寄存器 |

当前浮点 PST 的四条 `dealloc_vreg0~3` 选择链都是有效 RTL，因此可以同时准备
四个不同的空闲浮点物理项；整数 PST 的第四条完整选择链则被注释，并用 slot3
复用 slot0/1 选择结果的办法满足位置接口。即便浮点 PST 有四条独立选择链，也
不等价于每拍必然分配四个浮点物理寄存器，更不等价于四条体系结构指令能够持续
发射。实际分配数量由当拍重命名槽中具有浮点目的寄存器的有效操作数量决定，
还受上游停顿和空闲物理项数量约束。

### 4.1 五态生命周期

每个完整表项使用 one-hot 五态生命周期：

```verilog
DEALLOC = 5'b00001;
WF_ALLOC = 5'b00010;
ALLOC   = 5'b00100;
RETIRE  = 5'b01000;
RELEASE = 5'b10000;
```

更准确的含义是：

| 状态 | 含义 | 能否立即作为新目的项使用 |
|---|---|---|
| `DEALLOC` | 该物理项已经不属于有效映射，且写回条件允许回收 | 可以进入预分配选择 |
| `WF_ALLOC` | 已被 PST 选进某个分配寄存器，等待 IDU 实际消费 | 不可以被另一槽重复选择 |
| `ALLOC` | 已分配给一条尚未完成体系结构提交的生产者 | 不可以 |
| `RETIRE` | 该生产者已退休，该项是某逻辑寄存器的已提交版本 | 不可以 |
| `RELEASE` | 该已提交版本已被更新版本替代，但数据写回尚未满足回收条件 | 不可以 |

`DEALLOC` 并不只是“未分配”。它还隐含了“数据写回状态允许重用”。这就是
生命周期 FSM 与写回 FSM 必须分开的原因：体系结构版本已经无用，不代表该
物理存储项在当前时钟边界上已经可以安全覆盖。

### 4.2 独立的写回 FSM

每项另有两态写回 FSM：

```verilog
IDLE = 1'b0;
WB   = 1'b1;
```

- 创建新版本时，写回状态回到 `IDLE`；
- 匹配到该物理编号的执行写回时，转为 `WB`；
- 表项回到 `DEALLOC` 后，写回状态可重新回到 `IDLE`，为下一次分配做准备。

因此，表项能否回收到空闲池，取决于两个逻辑维度：

```text
旧版本已经被释放
        并且
对应结果已经写回
```

如果旧版本先被后继版本释放，但其写回晚到，生命周期会停在 `RELEASE`；
如果数据先写回，而版本仍是当前退休映射，表项会停在 `RETIRE`。二者都不能
提前重分配。

### 4.3 退休与释放不是同一件事

设一条指令把 `f5` 从物理项 P12 重命名到 P40：

```text
指令重命名时：
  新映射 f5 -> P40
  旧映射 rel_freg = P12

P40 对应生产者退休时：
  P40: ALLOC -> RETIRE
  P12: RETIRE -> RELEASE，或者在写回已完成时直接回到 DEALLOC
```

P40 退休后仍不能立即释放，因为它已经成为 `f5` 的最新已提交版本。只有以后
另一条指令再次改写 `f5`，P40 才会作为那条新指令携带的 `rel_freg` 被释放。

这也是为什么只看 ROB 占用量不足以判断物理寄存器压力。物理项回收还取决于
目的寄存器密度、同一逻辑寄存器被覆盖的速度、生产者写回时间和 flush 行为。

### 4.4 flush 恢复

恢复时，PST 不是简单地把物理编号按大小排序。完整 PST 从处于 `RETIRE`
状态的表项中提取已提交映射，并按表项保存的逻辑目的寄存器号
`dstv_reg[4:0]` 重新构造 32 个逻辑浮点寄存器的恢复映射。

需要区分：

- `rtu_yy_xx_flush`：清除推测态分配，保留已提交映射；
- `ifu_xx_sync_reset`：按模块定义的 reset 映射重新初始化状态；
- `retire_pst_async_flush`：主要参与写回等待和 flush 过程中的状态收敛。

仅看到全局 flush 拉高，不能立即断言下一拍所有表项都已可分配。还应检查
PST 的恢复输出、已退休未写回汇总条件以及各项生命周期。

同步复位时，当前 FREG 实例把物理项 0~31 初始化为 32 个逻辑浮点寄存器的
`RETIRE` 映射，物理项 32~63 初始化为 `DEALLOC`。这与整数 PST 的
“32 个初始提交映射 + 额外推测版本容量”思路相同，但两者的物理表规模分别是
64 和 96，不能互换编号或容量结论。

## 5. EREG 的体系结构含义

### 5.1 它不是通用整数结果，也不是 vtype/vl 重命名

这里的 EREG 不能笼统解释为“T-Head 任意扩展指令的附加寄存器”，也不能解释
为 `vsetvl/vsetvli` 修改的 `vl/vtype`。当前 RTL 的直接证据是：

- IDU 文件注释称其为 `F expt Physical Registers`；
- VFPU pipe6/pipe7 在 EX5 输出 `wb_ereg_data[5:0]`；
- EREG 数据文件把符合条件的物理项按位或，形成 `fesr_acc`；
- 结果通过 `idu_cp0_fesr_acc_updt_val/vld` 送到 CP0；
- CP0 用其中 `[4:0]` 更新浮点异常标志 `NV/DZ/OF/UF/NX`。

因此，更准确的定义是：

> EREG 是一组用于保存乱序浮点/相关 VFPU 操作所产生“状态贡献”的物理版本。
> 它让这些副作用先随指令推测执行，只有在对应版本进入可提交范围后，才累积
> 到 CP0 中的体系结构状态。

从数据位用途看：

| EREG/累积路径位 | 当前可见用途 |
|---|---|
| `[4:0]` | 浮点异常标志 `NV/DZ/OF/UF/NX` |
| 原始数据 `[5]` | 送 CP0 更新值 `[6]`，CP0 将其 OR 入 `fcsr_raw_vxsat` |
| 更新值 `[5]` | 由五个浮点异常位 `[4:0]` 的按位或归约生成，CP0 将其 OR 入 `fxcr_fe` |

还要加一个当前配置限定：`ct_vfpu_rbus.v` 把
`vfpu_idu_ex5_pipe6/7_wb_ereg_data[5]` 显式置 0。因此，虽然 EREG 数据文件和
CP0 累积接口保留了第 6 个原始状态位的通路，但由当前 pipe6/7 写回端口产生
的该位不会置 1。文档不应仅凭接口宽度断言当前实现一定产生该类状态。

### 5.2 为什么一个体系结构状态需要 32 个物理项

体系结构上的 `fflags` 是一个粘滞累积状态，但多条浮点指令可以乱序执行。
若执行结果一产生就直接修改体系结构 `fflags`，错误路径上的指令也可能留下
异常标志，破坏精确状态。

EREG 把每条相关生产者的状态贡献物理化：

```text
浮点指令 A -> EREG P3  -> {NV,DZ,OF,UF,NX}
浮点指令 B -> EREG P9  -> {NV,DZ,OF,UF,NX}
浮点指令 C -> EREG P14 -> {NV,DZ,OF,UF,NX}
```

指令可以先乱序写各自的 EREG 项。PST 继续记录这些物理版本与 IID、旧 EREG
版本之间的关系；只有满足退休/释放与写回条件的贡献，才进入后续累积。

IDU FRT 中只有一个当前 EREG 映射寄存器 `reg_e`，这是因为从重命名视角看，
它代表一个全局的、按程序顺序串联的状态依赖链，而不是 32 个不同的体系结构
寄存器。32 项是物理版本容量，不是 32 个逻辑 EREG。

### 5.3 EREG 的依赖链

若同一拍多个内部重命名槽都产生 EREG 目的项，后槽的 `rel_ereg` 必须看到
前槽刚分配的新映射：

```text
进入本拍前：reg_e = E5

inst0 产生状态 -> dst_ereg = E8，rel_ereg = E5
inst2 产生状态 -> dst_ereg = E9，rel_ereg = E8

本拍结束后：reg_e = E9
```

这是一种“映射旁路”，不是执行结果数据旁路。它解决的是同拍重命名时的版本
先后关系；真正的异常位数据仍由 VFPU 在 EX5 写入物理 EREG 项。

### 5.4 EREG PST 的生命周期

EREG 的 32 个表项也使用：

```text
DEALLOC -> WF_ALLOC -> ALLOC -> RETIRE -> RELEASE -> DEALLOC
```

并配有独立的 `IDLE/WB` 写回状态。主要转换条件是：

```text
DEALLOC:
  被空闲选择逻辑取走 -> WF_ALLOC

WF_ALLOC:
  分配槽被 IDU 消费 -> ALLOC
  flush              -> DEALLOC

ALLOC:
  对应 IID 退休       -> RETIRE
  旧版本被释放且已写回 -> DEALLOC
  旧版本被释放但未写回 -> RELEASE
  flush               -> DEALLOC

RETIRE:
  被后继版本释放且已写回 -> DEALLOC
  被后继版本释放但未写回 -> RELEASE

RELEASE:
  写回完成 -> DEALLOC
```

其中 `RETIRE` 表示“该物理版本已成为提交状态链上的当前版本”，不是“它已无
用途”。只有后继 EREG 版本退休并释放它之后，它才不再是已提交状态链的一部分。

同步复位只把 `ereg0` 标为初始 `RETIRE` 映射，其余 31 项为 `DEALLOC`，这与
FREG/PREG 各自需要 32 个初始逻辑寄存器映射不同：EREG 的重命名视图只有一个
全局状态链。顶层仍实现四条独立的 `dealloc_ereg0~3` 空闲选择链和四个位置
预分配输出；这是每拍候选物理版本的端口能力，不表示体系结构中存在四个逻辑
EREG，也不表示每拍必然消费四项。

### 5.5 写回和累积是两条相关但不同的路径

VFPU 写回携带：

```text
wb_ereg_vld + wb_ereg[4:0] + wb_ereg_data[5:0]
```

RTU PST 使用编号和 valid 更新该物理项的写回状态；IDU EREG 数据文件使用同一
编号把 6 位数据写入 32 项寄存器之一。二者分别回答：

- RTU：这个物理版本是否已写回，可以进入退休/释放后的回收判断吗？
- IDU：这个物理版本具体产生了哪些异常或状态位？

`rtu_idu_pst_ereg_retired_released_wb[31:0]` 再选择当次允许进入体系结构累积的
物理项。数据文件将被选项的数据按位或：

```verilog
fesr_acc = ereg0_acc_reg_dout
         | ereg1_acc_reg_dout
         | ...
         | ereg31_acc_reg_dout;
```

这里使用按位或是因为 `fflags` 是粘滞标志：一批可提交指令中只要有一条产生
某异常，该异常位就应为 1。它不是数值加法，也不表示异常发生次数。

选择信号还有一个细节：

- `ALLOC` 项在对应指令当拍退休时，若此前已经写回或当拍恰好写回，可以被
  计入累积；
- 已在 `RETIRE/RELEASE` 的项只在新的写回到达时触发累积，避免把同一份粘滞
  异常贡献重复提交。

数据文件对选择位打一拍后再产生 `idu_cp0_fesr_acc_updt_vld`。因此比较波形时，
不能要求 RTU 选择位与 CP0 更新 valid 完全同拍。

### 5.6 CP0 最终怎样使用结果

数据文件构造：

```verilog
update[4:0] = fesr_acc[4:0];
update[5]   = |fesr_acc[4:0];
update[6]   = fesr_acc[5];
```

CP0 对这 7 位都采用粘滞 OR 更新：

```text
[4] NV: invalid operation
[3] DZ: divide by zero
[2] OF: overflow
[1] UF: underflow
[0] NX: inexact
[5] 任一浮点异常位的归约，更新 fxcr_fe
[6] 原始 EREG data[5]，更新 fcsr_raw_vxsat
```

当前 VFPU RBUS 把两个 EREG 写回端口的原始 `data[5]` 固定为 0，所以这条
EREG 写回路径在当前配置下不会把 `fcsr_raw_vxsat` 置 1；这里记录的是数据文件
和 CP0 仍保留的接口语义。`fxcr_fe` 则由实际产生的五个浮点异常位归约得到，
不能与 `vxsat` 混为同一状态。

这条路径体现了精确乱序处理器的基本原则：

> 执行单元可以乱序计算副作用，但体系结构可见状态必须按提交边界过滤错误路径，
> 并按该状态的定义进行合并。

EREG 对 `fflags` 的作用，与 ROB 保护精确异常、PST 保护寄存器映射，本质上都
是在分离“推测产生的结果”和“允许成为体系结构状态的结果”。

## 6. 三类状态管理不能混为一谈

| 问题 | FREG PST | 向量 PST dummy | EREG PST |
|---|---|---|---|
| 管理的对象 | 浮点寄存器物理版本 | 当前无活动物理版本 | 浮点/VFPU 状态贡献的物理版本 |
| 保存实际数据吗 | 不保存，只跟踪状态 | 不保存状态 | PST 不保存数据；数据在 IDU EREG 文件 |
| 当前是否分配 | 是 | 否 | 是 |
| 恢复目标 | 32 个逻辑浮点寄存器映射 | 恢复输出恒 0 | 一个全局 EREG 当前映射 |
| 写回源 | LSU/VFPU 的浮点结果路径 | 输入被忽略 | VFPU pipe6/7 EX5 |
| 对 flush 等待的作用 | 可能等待已退休浮点结果写回 | 常量表示无需等待 | 可能等待状态贡献写回 |

特别注意，“PST 管理某类寄存器”不表示实际数据存储在 PST。PST 保存的是物理项
生命周期、IID、逻辑目的号、旧版本号和写回完成状态；FREG 数据在浮点物理
寄存器文件，EREG 的 6 位贡献数据在 `ct_idu_rf_prf_eregfile`。

## 7. Verdi 中如何验证

### 7.1 首先确认当前实例类型

在 RTU 顶层展开：

```text
x_ct_rtu_top
  x_ct_rtu_pst_freg
  x_ct_rtu_pst_vreg_dummy
  x_ct_rtu_pst_ereg
```

若波形数据库里根本没有完整 `x_ct_rtu_pst_vreg` 实例，不应按照完整向量 PST
文档解释 dummy 输入。

### 7.2 浮点物理寄存器完整链路

建议同时观察：

```text
rtu_idu_alloc_freg0..3
rtu_idu_alloc_freg0_vld..freg3_vld
idu_rtu_pst_dis_inst*_freg_vld
idu_rtu_pst_dis_inst*_vreg
idu_rtu_pst_dis_inst*_rel_vreg
vfpu_rtu_ex5_pipe6_wb_vreg_fr_vld
vfpu_rtu_ex5_pipe7_wb_vreg_fr_vld
retire_pst_wb_retire_inst*_vreg_vld
rob_pst_retire_inst*_iid_updt_val
pst_retired_freg_wb
rtu_idu_rt_recover_freg
rtu_yy_xx_flush
```

顶层复用通用 vreg 端口时，某些内部信号仍带 `vreg` 名称。判断它在当前实例中
代表浮点还是向量，必须依据实例路径和顶层连接，不能只看叶子信号名。

验证一条浮点目的指令时，应看到：

```text
分配 valid
  -> 派发携带新 freg 和 rel_freg
  -> 对应物理项进入 ALLOC
  -> VFPU/LSU 对该物理编号写回
  -> 相同 IID 在退休槽出现
  -> 新项进入 RETIRE，旧 rel_freg 被释放
```

### 7.3 EREG 完整链路

建议同时观察：

```text
rtu_idu_alloc_ereg0..3
rtu_idu_alloc_ereg0_vld..ereg3_vld
dp_frt_inst*_dste_vld
dp_frt_inst*_dst_ereg
frt_dp_inst*_rel_ereg
vfpu_idu_ex5_pipe6_wb_ereg_vld
vfpu_idu_ex5_pipe6_wb_ereg
vfpu_idu_ex5_pipe6_wb_ereg_data
vfpu_idu_ex5_pipe7_wb_ereg_vld
vfpu_idu_ex5_pipe7_wb_ereg
vfpu_idu_ex5_pipe7_wb_ereg_data
rtu_idu_pst_ereg_retired_released_wb
idu_cp0_fesr_acc_updt_vld
idu_cp0_fesr_acc_updt_val
```

检查因果链时，至少匹配三个标识：

1. 物理 EREG 编号；
2. 指令 IID；
3. 退休/写回发生的周期关系。

只看到 `wb_ereg_data` 非零不能证明它已修改体系结构 `fflags`；还必须看到相应
物理项进入允许累积的集合，并最终产生 CP0 更新 valid。

### 7.4 适合做的定向测试

- 产生 `NX` 的非精确浮点运算；
- 浮点除零，验证 `DZ`；
- 无效运算，验证 `NV`；
- 在产生异常标志的浮点指令之后立即制造分支误预测，检查错误路径贡献是否被
  flush 丢弃；
- 连续多条产生不同异常位的指令，检查最终更新值是否按位或；
- 在浮点长延迟操作尚未写回时触发 flush，观察 `pst_retired_freg_wb` 或
  `pst_retired_ereg_wb` 是否参与等待。

## 8. 阅读 RTL 时的边界

本文能从静态 RTL 直接确认：

- 当前顶层使用完整 FREG PST、向量 dummy PST 和完整 EREG PST；
- 各表项规模、状态机、分配接口、恢复接口和写回接口；
- EREG 数据按物理编号写入，并经过退休/释放过滤后按位或送 CP0；
- CP0 对五个标准浮点异常位采用粘滞 OR 更新。

以下结论不能只靠模块结构直接给出：

- 某个程序中浮点物理寄存器耗尽的实际比例；
- 一次浮点结果写回平均等待多少周期；
- flush 被 FREG/EREG 未写回状态延长了多少周期；
- 某类浮点指令实际产生各异常位的频率。

这些属于动态行为，必须在明确测试程序、编译选项和仿真区间后，用波形或性能
计数器测量。静态结构说明“可能在哪里等待”，动态数据才说明“实际等了多少”。
