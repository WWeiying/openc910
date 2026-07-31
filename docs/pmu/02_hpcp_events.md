# C910 PMU 事件选择与多 bit 增量通路详细教学文档

> RTL 文件：
> - `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_event.v`（103 行）—— 事件选择寄存器 `mhpmeventN`
> - `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_adder_sel.v`（260 行）—— 按事件号选出当前事件样本增量的 42 选 1 MUX
> - 事件增量（adder）的**产生**逻辑位于 `ct_hpcp_top.v` 第 1412~1463 行，本文一并讲解

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [事件选择寄存器 mhpmeventN（ct_hpcp_event）](#4-事件选择寄存器-mhpmeventnct_hpcp_event)
5. [为什么一个事件样本需要能大于 1](#5-为什么一个事件样本需要能大于-1)
6. [42 个事件增量的产生（ct_hpcp_top.v 1412~1463）](#6-42-个事件增量的产生ct_hpcp_topv-14121463)
7. [42 选 1 加法器 MUX（ct_hpcp_adder_sel）](#7-42-选-1-加法器-muxct_hpcp_adder_sel)
8. [42 种事件完整清单与分类](#8-42-种事件完整清单与分类)
9. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

PMU 的可编程计数器（HPM3~HPM18）每个都要回答一个问题：
“当前采样周期观察到多少个所选事件？”这个事件样本增量由两步决定：

1. **选哪种事件**：软件把一个 6 位的事件号写进 `mhpmeventN` CSR，由 `ct_hpcp_event` 模块保存。
2. **该事件在当前样本中出现几次**：C910 的 RTU 向 PMU 暴露 3 个退休槽，
   IDU IR 侧暴露 4 个指令分类槽，RF 侧暴露 8 个执行管线状态位。因此某些事件
   在同一周期可以贡献多个计数。`ct_hpcp_top` 先形成 42 个 4 位
   `eventNN_adder`，每个 `ct_hpcp_adder_sel` 实例再按本计数器的事件号选出
   `mhpmcntx_adder[3:0]`。

选出的增量并不在组合逻辑产生的同一瞬间直接写入 64 位计数值。它先由
`ct_hpcp_cnt` 在一个有效 `cnt_clk` 边沿捕获到 `cnt_adder_ff`，再在后续有效
边沿参与计数更新。因而本文所说的“当前周期增量”是**事件源采样周期的候选
增量**，不是“该周期结束时 CSR 读值已经增加”的承诺。

### 1.2 两个核心设计点

- **事件号合法性过滤**：`ct_hpcp_event` 同时检查写数据高
  `[63:6]` 位为 0、低 6 位不大于 42；任一条件不满足便存入 0。
  RTL 参数名 `HPMCNT_NUM` 容易误导，它在这里实际表示**最大合法事件号**，
  不是物理计数器数量。
- **多 bit 增量**：4 位接口可以表示 0~15。当前 42 个普通事件中，结构上
  最大的增量为 8，来自 RF 八路状态求和。多 bit 求和避免把同周期不同槽位
  的事件简单压成一个布尔值；但最终统计语义仍取决于源信号到底代表槽位事件、
  周期电平还是多个条件的 OR。

---

## 2. 端口说明

### 2.1 ct_hpcp_event 端口（`ct_hpcp_event.v:17~36`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `forever_cpuclk` | input | 1 | 自由运行时钟 |
| `cpurst_b` | input | 1 | 低有效复位 |
| `cp0_hpcp_icg_en` | input | 1 | 模块级门控时钟使能 |
| `pad_yy_icg_scan_en` | input | 1 | DFT 扫描时强开门控 |
| `eventx_clk_en` | input | 1 | 本事件寄存器局部门控使能（=本寄存器 wen） |
| `eventx_wen` | input | 1 | 写使能（来自 `ct_hpcp_top` 的 `mhpmevtN_wen`） |
| `hpcp_wdata[63:0]` | input | 64 | CSR 写数据 |
| `eventx_value[63:0]` | output | 64 | 当前事件号（高位补 0，低 6 位有效） |

### 2.2 ct_hpcp_adder_sel 端口（`ct_hpcp_adder_sel.v:17~108`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `event01_adder` ~ `event42_adder` | input | 各 4 | 42 种事件在当前源信号采样周期形成的候选增量 |
| `mhpmevtx_value[63:0]` | input | 64 | 本计数器的事件号（取低 6 位 `[5:0]` 做选择） |
| `mhpmcntx_adder[3:0]` | output | 4 | 选出的增量，送给对应 `ct_hpcp_cnt` |

注意：本模块是**纯组合逻辑**（一个大 `case`），没有时钟也没有复位。

---

## 3. 参数与关键寄存器

两文件都定义了同一对参数（`ct_hpcp_event.v:55~56`、`ct_hpcp_adder_sel` 通过实例化复用）：

| 参数 | 值 | 含义 |
|------|----|----|
| `HPMCNT_NUM` | 42 | RTL 名称沿用“counter num”，实际用作最大合法事件号 |
| `HPMEVT_WIDTH` | 6 | 事件号位宽（6 位可表示 0~63，足够 42 种） |

`ct_hpcp_event` 内唯一的状态：

| 寄存器 | 宽度 | 行号 | 含义 |
|--------|------|------|------|
| `value` | 6 | `ct_hpcp_event.v:39` | 当前事件号（`mhpmeventN` 的低 6 位） |

事件号 0 表示不采样新的可编程事件。`ct_hpcp_top.v:1300~1315` 用
`(|mhpmevtN_value[5:0])` 参与各计数器的 `cnt_en`。准确地说，写 0 会阻止
后续事件进入 `cnt_en_ff/cnt_adder_ff`；若旧事件已在写 0 前被捕获，它仍可能
在尾部更新边沿生效，不能把写 0 理解成异步撤销所有在途计数。

---

## 4. 事件选择寄存器 mhpmeventN（ct_hpcp_event）

C910 把 16 个可编程计数器（HPM3~HPM18，对应 `mhpmevt3`~`mhpmevt18`）的事件号寄存器做成同一个 `ct_hpcp_event` 模块的 16 次例化（`ct_hpcp_top.v:3451` 起，到 `x_hpcp_mhpmevent18`）。

### 4.1 写入逻辑与合法性过滤

核心代码（`ct_hpcp_event.v:83~94`）：

```verilog
always @(posedge eventx_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    value[HPMEVT_WIDTH-1:0] <= {HPMEVT_WIDTH{1'b0}};
  else if(eventx_wen)
    value[HPMEVT_WIDTH-1:0] <= hpcp_wdata[HPMEVT_WIDTH-1:0] & {HPMEVT_WIDTH{value_mask}} ;
  else
    value[HPMEVT_WIDTH-1:0] <= value[HPMEVT_WIDTH-1:0];
end

assign value_mask = (!(|hpcp_wdata[63:HPMEVT_WIDTH]))
                 && (hpcp_wdata[HPMEVT_WIDTH-1:0] <= HPMCNT_NUM);
```

**是什么**：写 `mhpmeventN` 时，先用 `value_mask` 检查两件事：
1. `hpcp_wdata[63:6]` 全为 0（高位不能有杂散位）；
2. 低 6 位数值 ≤ 42。

只要任一条件不满足，`value_mask=0`，写入的事件号被按位与成全 0（即写 0 = 关闭该计数器）。

**与下游 `default` 的关系**：事件号 43~63 会使
`ct_hpcp_adder_sel` 落入 `default` 并输出 `4'bxxxx`，所以事件寄存器在正常
软件写路径上把这类值裁成 0。事件号 0 也落入 `default`，但顶层同时令该槽
`cnt_en=0`，正常二值逻辑下不会捕获这个 X。这里能由 RTL 直接证明的是
“合法 CSR 写入值与使能条件共同阻止 X 被采样”；不能由此泛化为任意 X 注入、
强制信号或门级未知态都安全。

### 4.2 输出

`ct_hpcp_event.v:97`：

```verilog
assign eventx_value[63:0] = {{64-HPMEVT_WIDTH{1'b0}},value[HPMEVT_WIDTH-1:0]};
```

读 `mhpmeventN` CSR 时返回的就是这个高位补 0 的 64 位值。

---

## 5. 为什么一个事件样本需要能大于 1

只有当事件严格定义为“单一槽位上的布尔事件”时，0/1 增量才足够。超标量核
同一周期可在多个槽位上观察到同类事件，如果先做 OR，就会丢失同周期的槽位数。
不过，并非所有 C910 PMU 事件都是“按退休指令计数”；本章必须区分三种口径：

- **槽位计数**：对 RTU 3 槽、IDU IR 4 槽或 RF 8 路逐位求和；
- **周期计数**：某个 stall/disable 电平为 1 时，本周期贡献 1；
- **合并事件计数**：多个原因先 OR 为 1，同周期同时发生也只贡献 1。

C910 不是标量核：

- 退休侧（RTU）一拍最多反馈 **3 条**退休指令（`rtu_hpcp_inst0/1/2_*`）；
- 译码 / 重命名侧（IDU）一拍最多反馈 **4 条**指令的类型（`hpcp_ir_inst0/1/2/3_*`）；
- 寄存器读发射侧一拍最多 **8 条**流水（`pipe0~7`）。

若条件分支事件只对三个退休槽做 OR，那么“一拍三个槽都标记为条件分支”只会
记 1。当前 RTL 逐槽相加，因此算术表示能力不会在这一步把 3 压成 1。这里
证明的是**加法通路没有因位宽不足而饱和**；它不自动证明上游分类不会重叠、
源信号一定对应架构退休事件，或所有派生指标都可直接相除。

C910 的解决办法：**每个事件的增量是把同周期所有来源加起来的一个多 bit 数**。例如条件分支事件（event07）：

```verilog
// ct_hpcp_top.v:1419
assign event07_adder[3:0] = {3'b0,inst0_condbr} + {3'b0,inst1_condbr} + {3'b0,inst2_condbr};
```

当三个退休槽的 `condbr` 条件同时成立时，`event07_adder=3`。4 位接口也能
容纳 event20/event22 的八路求和。该值随后进入计数器的一拍寄存级，并非在
event07 组合值产生的同一拍直接加到 CSR 可见值。

计数器侧的累加见 `ct_hpcp_cnt.v:140`：`counter_adder = counter + cnt_adder_ff[3:0]`（详见 `01_hpcp_counters.md`）。

---

## 6. 42 个事件增量的产生（ct_hpcp_top.v 1412~1463）

`ct_hpcp_top` 在第 1412~1463 行集中产生全部 42 个 `eventNN_adder[3:0]`。按"来源数"可分三类：

**(a) 单 bit 来源、每个源采样周期最多 +1**：增量就是某个 1 bit 信号补到
4 位。它可能表示一次事件，也可能表示“整个周期处于某状态”，必须结合源信号
定义解释。例如：

```verilog
assign event01_adder[3:0] = {3'b0,hpcp_icache_access};   // ICache 访问
assign event02_adder[3:0] = {3'b0,hpcp_icache_miss};     // ICache 缺失
assign event06_adder[3:0] = {3'b0,bht_mispred};          // BHT 预测失误
```

**(b) 多槽位事件，可 +0~3 或 +0~4**：RTU 来源是退休槽；IDU 的
event29~33、37、42 则是 **IR 级分类槽**，不能写成退休事件：

```verilog
assign event07_adder[3:0] = {3'b0,inst0_condbr}+{3'b0,inst1_condbr}+{3'b0,inst2_condbr};      // 条件分支 0~3
assign event29_adder[3:0] = {3'b0,ir_inst0_alu}+{3'b0,ir_inst1_alu}+{3'b0,ir_inst2_alu}+{3'b0,ir_inst3_alu}; // ALU 0~4
```

**(c) RF 八路状态求和，可 +0~8**：event20/22 统计八个 pipe 对应状态位，
这些是 IDU RF 控制路径暴露的管线状态，不应未经进一步验证就等同于“本周期
成功发射了八条架构指令”：

```verilog
// ct_hpcp_top.v:1437
assign event20_adder[3:0] = {3'b0,pipe0_lch_fail}+...+{3'b0,pipe7_lch_fail}; // 0~8
assign event22_adder[3:0] = {3'b0,pipe0_inst_vld}+...+{3'b0,pipe7_inst_vld}; // 0~8
```

**(d) 双来源求和**：跨 4K stall `event23` 将 load/store 两个布尔源相加，
可为 0~2。非对齐访存 `event34` 在 PMU 内只是把 LSU 提供的 2 bit
`hpcp_unalign_inst` 零扩展；继续追到 `ct_lsu_ctrl.v:891`，该值实际也是
load/store 两个 1 bit 非对齐指示之和，所以合法范围为 0~2，而不是仅根据
总线位宽推断出的 0~3。

**(e) 本地增量恒 0 的 L2 映射选择码**：event16~19 不只是“保留不用”。
把某个 `mhpmeventN` 写成这些编号会触发 `cnt_mask` 和四路 L2 映射索引逻辑；
该 HPM 槽的本地计数被关闭，读写/溢出通过 BIU 访问 L2 计数器。因此它们在
本地事件加法器中 tie 0：

```verilog
assign event16_adder[3:0] = 4'b0;   // L2 read access  -> 由 CIU 维护
assign event17_adder[3:0] = 4'b0;   // L2 read miss
assign event18_adder[3:0] = 4'b0;   // L2 write access
assign event19_adder[3:0] = 4'b0;   // L2 write miss
```

L2 事件走的是另一条"借道某个可编程计数器索引、把请求发到 BIU、由 L2 返回计数值"的路径（见 `03_hpcp_top.md` 的 L2 交互一节），所以核内增量为 0。

`ir_instN_xxx` 这一族（event29~33、37、42）的译码类型来自 7 位 `hpcp_ir_instN_type`，解码规则见 `ct_hpcp_top.v:1375~1402`，例如 ALU = `type[0] && !type[2] && !type[6]`（排除向量/浮点）。

---

## 7. 42 选 1 加法器 MUX（ct_hpcp_adder_sel）

每个可编程计数器各自配一个 `ct_hpcp_adder_sel` 实例（`x_ct_hpcp_adder_sel_3`
到 `_18`）。16 个实例接收同一组 42 个全局事件增量，但各用自己的
`mhpmevtx_value[5:0]` 选择。源码层面是 16 个独立实例，不能描述成 16 个
计数器在时分复用一个物理 MUX；综合工具是否合并或优化逻辑，需要综合网表证明。

核心 `case`（`ct_hpcp_adder_sel.v:207~251`）：

```verilog
case(mhpmevtx_value[5:0])
  6'd1   : mhpmcntx_adder[3:0] = event01_adder[3:0];
  6'd2   : mhpmcntx_adder[3:0] = event02_adder[3:0];
  ...
  6'd42  : mhpmcntx_adder[3:0] = event42_adder[3:0];
  default: mhpmcntx_adder[3:0] = {4{1'bx}};
endcase
```

**是什么**：一个 42 路、每路 4 位的多路选择器。事件号 1~42 各对应一个增量，事件号 0 不在 case 列举中（会落入 default 给出 x，但此时计数器使能 `mhpmcntN_en` 因 `(|mhpmevtN_value)`=0 而关闭，x 不会被采样进计数器，是安全的）。

**为什么用独立模块多次例化**：模块化例化让 16 个槽使用同一份 RTL 定义，
减少手工复制引入不一致的风险。把 MUX 单独成模块也形成清楚的层次边界；至于
门级面积、共享、布线和平衡结果，必须由具体综合实现判断。

---

## 8. 42 种事件完整清单与分类

下表来自 `ct_hpcp_top.v:1413~1463` 的 `eventNN_adder` 赋值，事件号即 `ct_hpcp_adder_sel.v` 的 `case` 选择子。增量上限指同周期最多累加数。

| 事件号 | 名称（信号） | 来源单元 | 增量上限 | 行号 | 用途 |
|-------|-------------|---------|---------|------|------|
| 1 | ICache 访问 `hpcp_icache_access` | IFU | 1 | 1413 | I$ 命中率分母 |
| 2 | ICache 缺失 `hpcp_icache_miss` | IFU | 1 | 1414 | I$ MPKI |
| 3 | IUTLB 缺失 | MMU | 1 | 1415 | 取指 TLB |
| 4 | DUTLB 缺失 | MMU | 1 | 1416 | 访存 TLB |
| 5 | JTLB 缺失 | MMU | 1 | 1417 | 联合 TLB |
| 6 | BHT 预测失误 `bht_mispred` | RTU | 1 | 1418 | 方向预测误判 |
| 7 | 条件分支退休 `condbr` | RTU | 3 | 1419 | 分支占比 |
| 8 | 跳转预测错误 `jmp_mispred` | RTU 退休槽0 | 1 | 1420 | RTL 未仅凭该信号限定为“间接跳转” |
| 9 | 跳转指令退休 `jmp` | RTU | 3 | 1421 | 跳转占比 |
| 10 | 退休槽0 `spec_fail` | RTU 退休槽0 | 1 | 1422 | 统计该标志；不能直接等同所有 flush |
| 11 | store 退休 | RTU | 3 | 1423 | 写访存占比 |
| 12 | DCache 读访问 | LSU | 1 | 1424 | D$ 读命中率分母 |
| 13 | DCache 读缺失 | LSU | 1 | 1425 | D$ 读 MPKI |
| 14 | DCache 写访问 | LSU | 1 | 1426 | D$ 写命中率分母 |
| 15 | DCache 写缺失 | LSU | 1 | 1427 | D$ 写 MPKI |
| 16 | L2 读访问（核内 tie 0） | CIU/BIU | 0 | 1429 | L2 由 CIU 计 |
| 17 | L2 读缺失（核内 tie 0） | CIU/BIU | 0 | 1430 | 同上 |
| 18 | L2 写访问（核内 tie 0） | CIU/BIU | 0 | 1431 | 同上 |
| 19 | L2 写缺失（核内 tie 0） | CIU/BIU | 0 | 1432 | 同上 |
| 20 | RF pipe launch/latch fail（8 路） | IDU RF | 8 | 1437 | 八路失败状态之和 |
| 21 | RF pipe3/4/5 reg launch/latch fail | IDU RF | 3 | 1440 | 三路 `reg_lch_fail`，不泛化为所有寄存器冲突 |
| 22 | RF pipe 有效状态（8 路） | IDU RF | 8 | 1441 | 八路 `pipeN_inst_vld` 之和，不直接等同退休带宽 |
| 23 | load/store 跨 4K stall | LSU | 2 | 1444 | 跨页惩罚 |
| 24 | load/store 其它 stall | LSU | 2 | 1445 | 访存阻塞 |
| 25 | SQ discard（replay） | LSU | 1 | 1446 | store 队列重放 |
| 26 | SQ data discard | LSU | 1 | 1447 | 数据重放 |
| 27 | 分支目标（BTB）预测失误 | IFU | 1 | 1448 | BTB 误判 |
| 28 | IFU branch-target 处理样本 | IFU addrgen | 1 | 1449 | 实际源为 `addrgen_vld`，不能直接称 BTB hit |
| 29 | IR 级 ALU 类指令槽（4 路） | IDU IR | 4 | 1450 | 前端分类样本，不是退休数 |
| 30 | IR 级 load/store 类指令槽（4 路） | IDU IR | 4 | 1451 | 前端分类样本 |
| 31 | IR 级向量类指令槽（4 路） | IDU IR | 4 | 1452 | 前端分类样本 |
| 32 | IR 级 CSR 类指令槽（4 路） | IDU IR | 4 | 1453 | 前端分类样本 |
| 33 | IR 级 sync 类指令槽（4 路） | IDU IR | 4 | 1454 | 分类样本，不等同 stall 周期 |
| 34 | load/store 非对齐事件之和 | LSU | 2 | 1455 | LSU 先把两个 1 bit 指示相加，PMU 再零扩展 |
| 35 | `int_ack && retire_inst0_vld` | CP0/RTU | 1 | 1456 | 两条件同周期成立的样本 |
| 36 | `int_disable` 高电平周期 | CP0 | 1 | 1457 | 统计状态持续周期，不是关中断动作次数 |
| 37 | IR 级 ecall 类指令槽（4 路） | IDU IR | 4 | 1458 | 分类样本，不等同实际异常入口次数 |
| 38 | 长跳转（>8M offset，3 路） | RTU | 3 | 1459 | 远跳转 |
| 39 | 前端 stall 高电平周期 | IFU | 1 | 1460 | 每个高电平周期贡献 1 |
| 40 | 后端 stall 高电平周期 | IDU | 1 | 1461 | 可与 event39 同周期重叠 |
| 41 | fence stall 或 fence sync valid | LSU/IDU | 1 | 1462 | 两源先 OR，同时成立仍只计 1 |
| 42 | IR 级浮点类指令槽（4 路） | IDU IR | 4 | 1463 | 前端分类样本，不是退休数 |

固定计数器（不经事件 MUX）：

| 计数器 | 增量来源 | 行号 | 说明 |
|--------|---------|------|------|
| mcycle | 原始候选增量恒 `4'b1` | `ct_hpcp_top.v:1321` | 只有各级使能允许并完成流水更新时才加 1 |
| minstret | 三个 2 bit `inst_num` 条件项之和，表达式范围 0~9 | `ct_hpcp_top.v:1330` | 排除 `split` 退休项；`inst_num` 表示折叠项覆盖的架构指令数，不是 RVC 长度 |

### 8.1 读表时必须注意的口径

1. event7/9/11/38 来自 RTU 退休槽，适合与 `minstret` 讨论退休指令组成；
2. event29~33/37/42 来自 IDU IR 级，可能包含后来被冲刷或未退休的指令，
   不能与 `minstret` 混作严格的退休指令百分比；
3. event36/39/40 是状态高电平周期数。一次长停顿会连续计多次，这正是
   “停了多久”的口径，不是“发生了几次停顿”；
4. event41 先 OR 后计数，只能回答“本周期至少有一种 fence/sync 条件成立”；
5. event39 与 event40 没有互斥逻辑。二者都高时会分别被各自计数器统计，
   所以不能默认把两者相加当作总停顿周期；
6. event16~19 的本地增量为 0，但其事件号还承担 L2 映射控制语义，必须结合
   `cnt_mask`、映射索引和 BIU 完成握手理解。
7. event36 的源信号虽名为 `cp0_hpcp_int_disable`，当前 HPCP 只把它作为事件
   样本；它不门控 `hpcp_cp0_int_vld`，也不是 PMU 计数总开关。

---

## 本章小结

每个 HPM 槽保存 6 位事件号，正常 CSR 写只保留 0 至 42 的合法编码；编码 0 或非法值不会启动新的本地事件采样。16 个槽各自实例化事件选择逻辑，可以同时观察不同事件，并把选中的活动转换为 4 位增量。该宽度可表示 0 至 15，覆盖当前事件源单拍最大并行数以及 `minstret` 三个 2 位退休计数项求和的范围。事件号 16 至 19 还可被解释为 L2 远端计数映射，此时本地加法被屏蔽，读值和溢出来源切换到 L2；正确性依赖软件维持槽位与四种 L2 事件的一对一映射，以及 BIU 代理事务正常完成。

事件编码相同为“每拍加一个数”并不意味着统计口径相同。退休类事件按提交槽计数，IR 分类描述进入发射侧的指令，RF 事件反映执行管线状态，cache miss 或 stall 常是周期电平，某些事件又先 OR 合并多个来源后只加 1。计算 IPC、MPKI、命中率或停顿占比前，必须确认分子与分母的流水阶段、单位、最大单拍增量以及是否允许同周期重叠。事件选择模块只忠实执行这些编码，不能自动把不同口径归一化；指标解释必须回到每个源信号的 RTL 语义。
