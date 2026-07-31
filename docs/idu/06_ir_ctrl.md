# C910 IDU ir_ctrl 模块详细教学文档

> RTL 文件：`ct_idu_ir_ctrl.v`（2660 行）
> 模块名：`ct_idu_ir_ctrl`

---

## 目录

1. [模块概述](#1-模块概述)
2. [IS ctrl path 参数定义](#2-is-ctrl-path-参数定义)
3. [端口说明](#3-端口说明)
4. [IR 流水寄存器与门控时钟](#4-ir-流水寄存器与门控时钟)
5. [IR pipedown 指令有效信号（核心）：分层 stall 与槽位重排](#5-ir-pipedown-指令有效信号核心分层-stall-与槽位重排)
   - 5.1 [三类 stall 的含义与来源](#51-三类-stall-的含义与来源)
   - 5.2 [pipedown valid 如何分别处理 dispatch stall 与 type stall](#52-pipedown-valid-如何分别处理-dispatch-stall-与-type-stall)
   - 5.3 [creg stall：必须考虑的 IR 级 stall](#53-creg-stallir-级必须考虑的-stall)
   - 5.4 [ctrl_ir_pipedown_stall 的计算](#54-ctrl_ir_pipedown_stall-的计算)
   - 5.5 [ir_pipedown_instN_vld 逐位解析](#55-ir_pipedown_instn_vld-逐位解析)
6. [重命名表指令有效信号（rename table inst valid）](#6-重命名表指令有效信号rename-table-inst-valid)
7. [IR stage stall 信号生成](#7-ir-stage-stall-信号生成)
   - 7.1 [creg stall 四类子 stall](#71-creg-stall-四类子-stall)
   - 7.2 [ctrl_ir_stage_stall 汇总](#72-ctrl_ir_stage_stall-汇总)
   - 7.3 [ctrl_ir_stall 与 ID 级的关系](#73-ctrl_ir_stall-与-id-级的关系)
8. [物理寄存器分配信号（alloc_vld）](#8-物理寄存器分配信号alloc_vld)
9. [预分发控制信号（Pre-Dispatch Signals）](#9-预分发控制信号pre-dispatch-signals)
   - 9.1 [IS inst valid 准备](#91-is-inst-valid-准备)
   - 9.2 [type stall pipedown2 信号](#92-type-stall-pipedown2-信号)
   - 9.3 [IQ create enable/select 准备](#93-iq-create-enableselect-准备)
10. [动态负载均衡（DLB）](#10-动态负载均衡dlb)
    - 10.1 [AIQ DLB](#101-aiq-dlb)
    - 10.2 [VIQ DLB](#102-viq-dlb)
11. [ROB/PST fold 与 create 信号](#11-robpst-fold-与-create-信号)
12. [性能监控（HPCP）](#12-性能监控hpcp)
13. [与相邻模块的协调关系](#13-与相邻模块的协调关系)
14. [关键时序路径总结](#14-关键时序路径总结)

---

## 1. 模块概述

### IR 阶段在流水线中的位置

C910 是一款超标量乱序处理器，其前端流水线（IDU 内部）由以下阶段组成：

```
IFU --> ID（译码）--> IR（寄存器重命名）--> IS（发射/分发）--> IQ（指令队列）
```

`ct_idu_ir_ctrl` 是 **IR 阶段的控制中枢**。IR 阶段介于 ID（译码）和 IS（发射）之间，完成以下工作：

| 阶段 | 职责 |
|------|------|
| ID   | 指令解码，生成控制信息 |
| **IR** | **寄存器重命名**：将架构寄存器映射到物理寄存器（preg/vreg/freg/ereg） |
| IS   | 预分发：将已重命名的指令写入各类 IQ（AIQ/BIQ/LSIQ/VIQ 等） |

`ct_idu_ir_ctrl` 负责：

1. **维护 IR 级流水寄存器**（`ir_inst0_vld` ~ `ir_inst3_vld`，最多4条指令同时处于 IR 阶段）
2. **检测并生成 creg stall**（因物理寄存器资源不足，无法完成重命名时产生的 stall）
3. **向 ID 级反压**（`ctrl_ir_stall`），阻止新指令进入 IR 阶段
4. **向 IS 阶段输出 pipedown 有效信号**（`ctrl_ir_pipedown_inst[0-3]_vld`），驱动 IS 阶段锁存器
5. **向重命名表模块输出指令有效信号**（`ctrl_rt_inst[0-3]_vld`）
6. **向 RTU 输出物理寄存器分配请求**（`idu_rtu_ir_[preg/vreg/freg/ereg]N_alloc_vld`）
7. **准备 Pre-Dispatch 信号**（告知 IS 阶段各指令应写入哪个 IQ 的哪个 create 端口）
8. **执行动态负载均衡（DLB）**，在 AIQ0/AIQ1、VIQ0/VIQ1 之间动态分配指令

---

## 2. IS ctrl path 参数定义

```verilog
// 行 851-865
parameter IS_CTRL_WIDTH   = 13;

parameter IS_CTRL_VMB     = 12;  // 向量访存 buffer（VMB）
parameter IS_CTRL_PIPE7   = 11;  // Pipe7（VIQ1 专用）
parameter IS_CTRL_PIPE6   = 10;  // Pipe6（VIQ0 专用）
parameter IS_CTRL_PIPE67  = 9;   // Pipe6 或 Pipe7（VIQ01 可选）
parameter IS_CTRL_SPECIAL = 8;   // 特殊指令（CSR/系统类）
parameter IS_CTRL_STADDR  = 7;   // Store Address（SDIQ）
parameter IS_CTRL_INTMASK = 6;   // 中断屏蔽指令
parameter IS_CTRL_SPLIT   = 5;   // 指令需要拆分
parameter IS_CTRL_LSU     = 4;   // Load/Store（LSIQ）
parameter IS_CTRL_BJU     = 3;   // Branch/Jump（BIQ）
parameter IS_CTRL_DIV     = 2;   // 除法（AIQ0 专用）
parameter IS_CTRL_MULT    = 1;   // 乘法（AIQ1 可选）
parameter IS_CTRL_ALU     = 0;   // 普通 ALU（AIQ01 两路均可）
```

每条指令在经过 ID 译码后，会携带一个 13 位的 `ctrl_info` 字段，其每一位对应上述参数中的某类功能属性。IR 阶段使用这个字段判断指令应被派遣到哪个发射队列（IQ）。

**体系结构意义**：C910 具有 7 条执行流水线，不同类型的指令只能进入特定的 IQ：

| IQ 名称 | 支持的指令类型 | ctrl_info 对应位 |
|---------|-------------|----------------|
| AIQ0    | DIV、SPECIAL | IS_CTRL_DIV、IS_CTRL_SPECIAL |
| AIQ1    | MULT        | IS_CTRL_MULT |
| AIQ01   | ALU（可去 AIQ0 或 AIQ1） | IS_CTRL_ALU |
| BIQ     | 分支跳转     | IS_CTRL_BJU |
| LSIQ    | Load/Store  | IS_CTRL_LSU |
| SDIQ    | Store Address | IS_CTRL_STADDR |
| VIQ0    | 向量 Pipe6  | IS_CTRL_PIPE6 |
| VIQ1    | 向量 Pipe7  | IS_CTRL_PIPE7 |
| VIQ01   | 向量（可去 VIQ0 或 VIQ1） | IS_CTRL_PIPE67 |
| VMB     | 向量访存    | IS_CTRL_VMB（与 LSIQ 同时有效） |

---

## 3. 端口说明

### 3.1 时钟与复位

| 端口 | 方向 | 说明 |
|------|------|------|
| `forever_cpuclk` | in | CPU 主时钟（不门控的全局时钟） |
| `cpurst_b` | in | 低有效复位 |
| `cp0_yy_clk_en` | in | 全局时钟使能（来自 CP0） |
| `cp0_idu_icg_en` | in | IDU 模块级门控使能 |
| `pad_yy_icg_scan_en` | in | 扫描测试时旁路门控 |

### 3.2 来自 ID 阶段的输入

| 端口 | 方向 | 说明 |
|------|------|------|
| `ctrl_id_pipedown_inst[0-3]_vld` | in | ID 阶段向 IR 阶段流水的指令有效信号 |
| `ctrl_id_pipedown_gateclk` | in | ID 阶段门控时钟使能 |

### 3.3 来自 IS/分发阶段的输入

| 端口 | 方向 | 说明 |
|------|------|------|
| `ctrl_is_stall` | in | IS 阶段的总 stall 信号（dispatch stall + type stall 合并） |
| `ctrl_is_dis_type_stall` | in | IS 阶段的 type stall 分量 |
| `ctrl_is_inst2_vld` | in | IS 阶段 slot2 当前有效 |
| `ctrl_is_inst3_vld` | in | IS 阶段 slot3 当前有效 |
| `ctrl_xx_is_inst0_sel[1:0]` | in | IS slot0 数据选择（来自 IR 的哪个 slot 或 IS 自身） |
| `ctrl_xx_is_inst_sel[2:0]` | in | IS slot1~3 的数据选择控制 |

### 3.4 来自 RTU 的物理寄存器分配反馈

| 端口 | 方向 | 说明 |
|------|------|------|
| `rtu_idu_alloc_preg[0-3]_vld` | in | RTU 可为 slot0~3 提供物理整数寄存器 |
| `rtu_idu_alloc_vreg[0-3]_vld` | in | RTU 可为 slot0~3 提供物理向量寄存器 |
| `rtu_idu_alloc_freg[0-3]_vld` | in | RTU 可为 slot0~3 提供物理浮点寄存器 |
| `rtu_idu_alloc_ereg[0-3]_vld` | in | RTU 可为 slot0~3 提供物理 EREG；EREG 保存 `fflags` 等推测状态贡献，不是通用整数结果或 `vl/vtype` |

### 3.5 来自 RTU 的 flush 信号

| 端口 | 方向 | 说明 |
|------|------|------|
| `rtu_idu_flush_fe` | in | Flush 前端（清除 IR/ID 中所有指令） |
| `rtu_idu_flush_is` | in | Flush IS 及以前的级别 |
| `rtu_idu_flush_stall` | in | Flush 引起的 stall（如异常处理期间） |
| `rtu_yy_xx_flush` | in | 全局 flush（广播给所有模块） |
| `iu_yy_xx_cancel` | in | IU 发出的取消信号（预测失败等） |
| `iu_idu_mispred_stall` | in | 分支预测失败产生的 stall |

### 3.6 主要输出信号

| 端口 | 方向 | 说明 |
|------|------|------|
| `ctrl_ir_stall` | out | IR 阶段总 stall，反压到 ID 级 |
| `ctrl_ir_stage_stall` | out | IR 级自身的 stall（creg stall + mispred stall 等） |
| `ctrl_ir_pipedown` | out | IR->IS 流水使能（any inst valid） |
| `ctrl_ir_pipedown_inst[0-3]_vld` | out | IR->IS 各 slot 流水有效信号 |
| `ctrl_rt_inst[0-3]_vld` | out | 送重命名表模块的指令有效信号 |
| `idu_rtu_ir_[preg/vreg/freg/ereg]N_alloc_vld` | out | 向 RTU 申请物理寄存器分配 |
| `ctrl_ir_pre_dis_*` | out | 预分发控制信号（IQ create en/sel） |
| `ctrl_top_ir_inst[0-3]_vld` | out | IR 阶段当前指令有效（供 top 层监控） |
| `ctrl_fence_ir_pipe_empty` | out | IR 阶段为空（fence 指令等待条件） |

---

## 4. IR 流水寄存器与门控时钟

### 4.1 门控时钟设计

```verilog
// 行 870-884
assign ir_inst_clk_en = ctrl_id_pipedown_gateclk
                        || ir_inst0_vld
                        || ir_inst1_vld
                        || ir_inst2_vld
                        || ir_inst3_vld;

gated_clk_cell  x_ir_inst_gated_clk (
  .clk_in  (forever_cpuclk),
  .clk_out (ir_inst_clk   ),
  .local_en(ir_inst_clk_en),
  ...
);
```

当 IR 四个 valid 均为 0，且 ID 没有通过 `ctrl_id_pipedown_gateclk` 提出活动请求时，
`ir_inst_clk_en=0`。这只是该实例的 `local_en`：技术分支还按
`global_en && (module_en || local_en) || external_en` 形成门控条件，并接收扫描使能；
未定义 `C910_USE_TSMC28_ICG` 时，公开 RTL 的 `clk_out` 直接跟随 `clk_in`。因此该
结构表达了减少 IR 状态时钟活动的意图，不能写成所有配置下“完全消除翻转功耗”。

### 4.2 IR 流水寄存器实现

```verilog
// 行 899-925
always @(posedge ir_inst_clk or negedge cpurst_b)
begin
  if(!cpurst_b) begin
    ir_inst0_vld <= 1'b0; ir_inst1_vld <= 1'b0;
    ir_inst2_vld <= 1'b0; ir_inst3_vld <= 1'b0;
  end
  else if(rtu_idu_flush_fe || iu_yy_xx_cancel) begin
    // flush 或取消：清空 IR 阶段所有指令
    ir_inst0_vld <= 1'b0; ...
  end
  else if(!ctrl_ir_stall) begin
    // 无 stall：接收来自 ID 阶段的新指令
    ir_inst0_vld <= ctrl_id_pipedown_inst0_vld;
    ir_inst1_vld <= ctrl_id_pipedown_inst1_vld;
    ir_inst2_vld <= ctrl_id_pipedown_inst2_vld;
    ir_inst3_vld <= ctrl_id_pipedown_inst3_vld;
  end
  else begin
    // 有 stall：保持当前值
    ir_inst0_vld <= ir_inst0_vld; ...
  end
end
```

**状态转移逻辑（优先级从高到低）**：

```
优先级1：复位或 flush/cancel  --> 清零
优先级2：无 stall            --> 从 ID 阶段接收新指令
优先级3：有 stall            --> 保持当前指令（等待 IS 消化）
```

**为什么这么做**：
- **flush/cancel 优先级最高**：确保在分支预测失败或异常发生时，错误的指令立即被清除，避免污染重命名表。
- **stall 时保持**：当下游（IS/分发）无法接收指令时，IR 阶段的指令不能丢弃，必须等待。ID 阶段也会因 `ctrl_ir_stall` 暂停流水。

### 4.3 IR 阶段的 4-wide 超标量设计

C910 IDU 支持每周期最多处理 4 条指令（4-wide superscalar）。IR 阶段因此维护 4 个 valid 寄存器（`ir_inst0_vld` ~ `ir_inst3_vld`），分别对应4个指令槽（slot 0~3）。

```
ID 阶段          IR 阶段          IS 阶段
+------+        +-------+        +-------+
|inst0 | -----> |slot 0 | -----> |slot 0 |
|inst1 | -----> |slot 1 | -----> |slot 1 |
|inst2 | -----> |slot 2 | -----> |slot 2 |
|inst3 | -----> |slot 3 | -----> |slot 3 |
+------+        +-------+        +-------+
```

---

## 5. IR pipedown 指令有效信号（核心）：分层 stall 与槽位重排

这一部分把 IR 本级资源阻塞、IS dispatch 阻塞和 IS type stall 分配到不同的
保持/选择路径。它是理解 IR→IS 数据是否真正更新的关键，但文档必须以生效方程
为准：生成源注释中的“pipedown valid 可以忽略 type stall”是概括性描述，
最终 RTL 的 `ctrl_ir_pipedown_stall` 实际包含 `ctrl_is_dis_type_stall`。

### 5.1 三类 stall 的含义与来源

RTL 注释（行 941-952）对此有明确说明：

```
//to reduce dispatch stall timing, IR and IS stage use delicate
//stall and inst valid design:
//there are two IS stall sources: dispatch stall and type stall
//1.if there is dispatch stall, IS stage control registers does
//  not receive new inst predispatch information
//2.if there is type stall, is_dis_inst_sel will select IS stage
//  inst valid and datapath
//there is one IR stall source: creg stall
//3.if there is creg stall, cannot pipe IR inst to IS stage.
//  however creg stall does not affect IS stage shift inst
//so pipedown inst valid can ignore both dispatch stall and type
//stall, but should consider creg stall.
```

三类 stall 的详细说明：

#### IS stall 类型一：Dispatch Stall（分发 stall）

**来源**：`ctrl_is_stall`（IS 阶段总 stall）中的 dispatch 部分

**含义**：IS 阶段的控制寄存器（存放已重命名指令等待分发的信息）无法在本周期接收新数据。原因通常是：
- IQ（指令队列）满，无法创建新表项
- ROB（重排序缓冲）满，无法分配新 IID

**效果**：相关 IS 控制/数据寄存器保持，当前拍不创建新的 IQ/ROB/VMB 状态。
“整体停顿”只描述 IS 接收/dispatch 边界，不能外推成已经驻留在各 IQ 中的老指令
都停止发射或执行。

#### IS stall 类型二：Type Stall（类型 stall）

**来源**：`ctrl_is_dis_type_stall`

**含义**：当前预分发包若有至少 3 条有效指令被路由到同一个 BIQ、AIQ0、
AIQ1、LSIQ、VIQ0 或 VIQ1，而这些队列各只有两个 create 口，本拍不能把整个
四槽包一次性分发完。检测逻辑并不编码“任意指令类型冲突”，而是逐队列统计
“至少三条目标相同”。

**效果**：预分发只允许 slot0/slot1 形成当拍 create，slot2/slot3 被保存在 IS
寄存器中。随后 `ctrl_xx_is_inst0_sel` / `ctrl_xx_is_inst_sel` 可以把这两个保留槽
前移，并在允许时用 IR 中较老的新槽补到后面。它不是简单地“整个 IS 都改选旧
数据”，而是按选择向量对四个目标槽分别重排。

**典型场景**：4条指令都是 BIQ 类型，但 BIQ 每周期只能接收2条。slot2/slot3 的指令需要 type stall。

#### IR stall（creg stall）

**来源**：`ctrl_ir_stage_stall`，由 preg/vreg/freg/ereg 分配无效，再加
`rtu_idu_flush_stall` 与 `iu_idu_mispred_stall` 组成。

**含义**：RTL 注释使用 “creg stall” 作为本级重命名资源 stall 的简称，但代码
没有定义它是 “Committed Register”。可直接确认的是：只要某个有效目的需要的
preg/vreg/freg/ereg 分配结果无效，或者 flush/mispredict 协议要求 IR 暂停，
本级不能完成这批指令的正常重命名推进。分配无效通常与可用物理项不足有关，但
具体原因由 RTU 分配器状态决定。

**效果**：IR 阶段整体 stall，所有 IR 中的指令均不能向 IS 流水。

### 5.2 pipedown valid 如何分别处理 dispatch stall 与 type stall

不能把 dispatch stall 和 type stall 都概括为“被 pipedown valid 忽略”。当前
生效 RTL 是：

```verilog
assign ctrl_ir_pipedown_stall = ctrl_ir_stage_stall
                              || ctrl_is_dis_type_stall;
```

随后，每个目标槽的 valid 是三类来源的选择：

- 从 IS 保留的 slot2/slot3 前移时，不与 `!ctrl_ir_pipedown_stall` 相与；
- 从 IR 的 inst0–inst3 取新数据时，必须满足 `!ctrl_ir_pipedown_stall`；
- dispatch stall 不直接出现在这个局部方程中，而由 IS 寄存器更新使能和上游
  `ctrl_is_stall` 反馈共同保持状态。

#### 体系结构角度

**Dispatch Stall 场景**：

```
周期 N:   IR[0,1,2,3] 有效，IS 发生 dispatch stall
周期 N+1: IS 阶段控制寄存器被冻结，IR 阶段保持不变
```

dispatch stall 发生时，IS 的状态更新条件阻止当前预分发结果被当作成功 create。
IR 也通过 `ctrl_is_stall` 进入 `ctrl_ir_stall`，停止向 RTU发出实际 alloc，并保持
IR 状态。因而局部 `ir_pipedown_inst*_vld` 没有逐项串入 dispatch-stall 信号，
不等于指令在 dispatch stall 下仍被后续结构接收。

**Type Stall 场景**：

```
周期 N:   IR[0,1,2,3] 都是 BIQ，发生 type stall（BIQ 只能处理2条）
          IS 阶段通过 is_dis_inst_sel 选择"自己保存的 slot2/slot3"重新分发
```

type stall 与之不同：它**明确出现在** `ctrl_ir_pipedown_stall` 中，所以所有
带 `!ctrl_ir_pipedown_stall` 的 IR 新数据分支被阻止；但 IS slot2/slot3 前移分支
没有这个门控，仍可形成新的 slot0/slot1。这样可以继续消化上拍未分发的年轻槽，
同时避免把新的 IR 指令混进尚未解决的 type-stall 包。

#### 时序角度

下面是理解这种逻辑分层的一种体系结构视角；“哪条是关键路径”仍需 STA 证明：

```
概念上的单一总阻塞设计：
  pipedown_valid = ir_inst_vld && !dispatch_stall && !type_stall && !creg_stall
                       ^                  ^                ^              ^
                   IR 寄存器输出      IS 的 IQ 满信号   IS 的类型判断   RTU 分配反馈
                                     （长路径！）
```

`dispatch_stall` 汇聚 IQ/分发资源等反馈，逻辑锥通常比本地 valid 更复杂。RTL 将其
影响放到 IS 侧保持/选择，而没有直接串入这里的 `ir_pipedown_inst*_vld`。可以确认
组合依赖被分开；是否“显著增加周期时间”需比较综合时序路径。

C910 的实现把“保留的 IS 槽能否前移”和“新的 IR 槽能否进入”拆成不同项：
前者可越过 IR stage/type stall，后者受
`ctrl_ir_stage_stall || ctrl_is_dis_type_stall` 限定；dispatch stall 则在 IS
寄存器/分发更新边界处理。可以确认的是控制锥被拆分，而不是所有 valid 都经过
同一个总 stall。是否缩短了目标频率上的关键路径、缩短多少，必须由综合网表和
STA 比较证明。

```
当前结构的概念化伪代码：
  if select_retained_IS_slot:
      target_valid = retained_IS_valid
  else if select_new_IR_slot:
      target_valid = IR_valid && !IR_stage_stall && !IS_type_stall

  dispatch_stall:
      由 IS 状态更新与 IR 反压协议阻止真正接收/分配
```

### 5.3 creg stall：IR 级必须考虑的 stall

creg stall（即 `ctrl_ir_stage_stall`）必须阻止 pipedown，原因如下：

1. **重命名表一致性**：IR 阶段向 RTU 申请物理寄存器，RTU 分配后 IR 阶段才能完成重命名表更新。如果物理寄存器不足（`rtu_idu_alloc_pregN_vld = 0`），重命名动作无法完成，此时不能让指令流入 IS 阶段（IS 阶段依赖已完成重命名的信息）。

2. **不同于 dispatch stall**：dispatch stall 时，重命名已经完成，指令可以安全地在 IS 寄存器中等待；creg stall 时，重命名尚未完成，指令不能"假装已经 ready"流入 IS。

3. **creg stall 不影响 IS 阶段 shift**（RTL 注释第3点）：IS 阶段已有的指令（已完成重命名）仍可继续尝试分发，creg stall 只阻止 IR 新指令进入 IS，不影响 IS 已有指令的操作。

### 5.4 ctrl_ir_pipedown_stall 的计算

```verilog
// 行 953
assign ctrl_ir_pipedown_stall = ctrl_ir_stage_stall || ctrl_is_dis_type_stall;
```

**注意**：这里包含了 `ctrl_is_dis_type_stall`，这与上面"可以忽略 type stall"的说法并不矛盾。

分析如下：

- `ctrl_ir_pipedown_stall` 用于计算 `ir_pipedown_instN_vld`
- 当 type stall 发生时（`ctrl_is_dis_type_stall = 1`），IS 阶段会用自己 slot2/3 的旧数据覆盖来自 IR 的数据。此时如果 IR 的 pipedown valid 还是 1，会导致 IS 阶段门控时钟不必要地打开，浪费功耗。
- 因此 type stall 时将 pipedown valid 置 0，是一种**功耗优化**，而非正确性需求。
- **dispatch stall 不在此处**（`ctrl_is_stall` 不包含在 pipedown_stall 中）：dispatch stall 时 IS 寄存器写使能被关闭，pipedown valid 的真实值无关紧要（IS 会忽略它），所以不需要额外屏蔽。

### 5.5 ir_pipedown_instN_vld 逐位解析

```verilog
// 行 955-969
assign ir_pipedown_inst0_vld =
          ctrl_xx_is_inst0_sel[0] && ctrl_is_inst2_vld     // IS 的 slot2 向 slot0 移位
       || ctrl_xx_is_inst0_sel[1] && ir_inst0_vld && !ctrl_ir_pipedown_stall;  // IR slot0 进入

assign ir_pipedown_inst1_vld =
          ctrl_xx_is_inst_sel[0] && ctrl_is_inst3_vld      // IS slot3 移位到 slot1
       || ctrl_xx_is_inst_sel[1] && ir_inst0_vld && !ctrl_ir_pipedown_stall    // IR slot0 进入
       || ctrl_xx_is_inst_sel[2] && ir_inst1_vld && !ctrl_ir_pipedown_stall;   // IR slot1 进入

assign ir_pipedown_inst2_vld =
          ctrl_xx_is_inst_sel[0] && ir_inst0_vld && !ctrl_ir_pipedown_stall    // IR slot0 进入
       || ctrl_xx_is_inst_sel[1] && ir_inst1_vld && !ctrl_ir_pipedown_stall    // IR slot1 进入
       || ctrl_xx_is_inst_sel[2] && ir_inst2_vld && !ctrl_ir_pipedown_stall;   // IR slot2 进入

assign ir_pipedown_inst3_vld =
          ctrl_xx_is_inst_sel[0] && ir_inst1_vld && !ctrl_ir_pipedown_stall    // IR slot1 进入
       || ctrl_xx_is_inst_sel[1] && ir_inst2_vld && !ctrl_ir_pipedown_stall    // IR slot2 进入
       || ctrl_xx_is_inst_sel[2] && ir_inst3_vld && !ctrl_ir_pipedown_stall;   // IR slot3 进入
```

#### inst_sel 信号的含义

这是理解 pipedown 逻辑的关键：IS 阶段在 type stall 场景下，会将未分发完的指令"上移"（shift），腾出 slot0/1 接收 IR 新指令。

`ctrl_xx_is_inst0_sel[1:0]` 控制 IS slot0 的数据来源：

| 值 | 含义 |
|----|------|
| `[0]=1` | IS slot0 = IS 自身的 slot2（IS slot2 向上移了2位，type stall 残余2条指令） |
| `[1]=1` | IS slot0 = IR slot0（正常从 IR 流入） |

`ctrl_xx_is_inst_sel[2:0]` 控制 IS slot1~3 的来源，3位 one-hot 编码：

| 值 | IS slot 偏移 | 场景 |
|----|-------------|------|
| `[0]=1` | IS 阶段上移2位（IS 原 slot2 -> slot0，原 slot3 -> slot1，IR slot0 -> slot2） | IS 有2条指令未分发 |
| `[1]=1` | IS 阶段上移1位（IS 原 slot3 -> slot1，IR slot0 -> slot2，IR slot1 -> slot3） | IS 有1条指令未分发 |
| `[2]=1` | 无上移（IR slot0 -> slot0，IR slot1 -> slot1 ...） | 正常流水 |

这套机制允许 IS 阶段在 type stall 后继续利用旧指令填充低位 slot，同时 IR 新指令从高位 slot 流入，实现高吞吐的 4-wide 超标量流水。

---

## 6. 重命名表指令有效信号（rename table inst valid）

```verilog
// 行 978-981
assign ctrl_rt_inst0_vld = ir_inst0_vld;
assign ctrl_rt_inst1_vld = ir_inst1_vld;
assign ctrl_rt_inst2_vld = ir_inst2_vld;
assign ctrl_rt_inst3_vld = ir_inst3_vld;
```

注意：送往重命名表模块（`ir_rt` / `ir_frt` / `ir_vrt`）的指令有效信号**直接使用 IR 寄存器值**，不考虑任何 stall。

RTL 注释（行 974-977）：
```
//rename table inst can only be from IR pipeline inst,
//their inst valid signals are from ir inst valid,
//and consider is stall signal (including dispatch stall
//and type stall). the is stall logic is in rt module.
```

**为什么这么做**：

重命名表模块（rt/frt/vrt）内部有自己的 IS stall 处理逻辑。`ir_ctrl` 只需提供"IR 阶段有哪些有效指令"这个事实，stall 的响应由重命名表模块自己处理。这是模块职责清晰划分的体现——每个模块管理自己的 stall 响应，减少跨模块的依赖和时序耦合。

具体地，重命名表模块在收到 `ctrl_rt_instN_vld` 后，会结合 `ctrl_is_stall`（包含 dispatch stall 和 type stall）决定是否真正更新重命名表。

---

## 7. IR stage stall 信号生成

### 7.1 creg stall 四类子 stall

C910 有四类物理寄存器，每类对应一个 stall 信号：

#### preg stall（整数物理寄存器）

```verilog
// 行 1024-1028
assign ctrl_ir_preg_stall =
     ir_inst0_vld && dp_ctrl_ir_inst0_dst_vld && !rtu_idu_alloc_preg0_vld
  || ir_inst1_vld && dp_ctrl_ir_inst1_dst_vld && !rtu_idu_alloc_preg1_vld
  || ir_inst2_vld && dp_ctrl_ir_inst2_dst_vld && !rtu_idu_alloc_preg2_vld
  || ir_inst3_vld && dp_ctrl_ir_inst3_dst_vld && !rtu_idu_alloc_preg3_vld;
```

**触发条件**：IR 中某条指令有整数目标寄存器（`dst_vld=1`），但 RTU 无法为该 slot 分配空闲物理寄存器（`alloc_preg_vld=0`）。

注意：从 IDU 接口看，四个 IR 位置分别检查对应的
`rtu_idu_alloc_pregN_vld`，任何一个实际需要整数目的寄存器的位置拿不到有效
编号都会触发 stall。但这不表示 RTU 内部有四条完全独立的整数空闲项选择链：
当前 PREG PST 只有三条独立新选择链，slot3 在满足接口约束时复用 slot0 或
slot1 的选择结果补位。四个 IR 位置来自最多三条原始指令加 split 微操作，
因此“按位置独立检查有效位”与“最多选择三个不同新 preg”并不矛盾。

#### vreg stall（向量物理寄存器）

```verilog
// 行 1030-1034
assign ctrl_ir_vreg_stall =
     ir_inst0_vld && dp_ctrl_ir_inst0_dstv_vld && !rtu_idu_alloc_vreg0_vld
  || ...
```

条件：指令有向量目标寄存器（`dstv_vld=1`）且对应 vreg 无可分配资源。

#### freg stall（浮点物理寄存器）

```verilog
// 行 1036-1040
assign ctrl_ir_freg_stall =
     ir_inst0_vld && dp_ctrl_ir_inst0_dstf_vld && !rtu_idu_alloc_freg0_vld
  || ...
```

条件：指令有浮点目标寄存器（`dstf_vld=1`）且对应 freg 无可分配资源。

#### ereg stall（异常/状态贡献物理项）

```verilog
// 行 1042-1046
assign ctrl_ir_ereg_stall =
     ir_inst0_vld && dp_ctrl_ir_inst0_dste_vld && !rtu_idu_alloc_ereg0_vld
  || ...
```

条件：有效内部槽具有 EREG 目的（`dste_vld=1`），但 RTU 对该槽没有提供可分配
物理 EREG。这里的 `dste` 表示该 VFPU/浮点操作会产生需要随程序序提交的状态
贡献，典型内容是 `fflags` 五个异常标志；它不是 `fclass/fmv.x` 的整数目的，也
不是向量 `vl/vtype` 的当前值。

#### 向上报告（供 top 层门控时钟使用）

```verilog
// 行 1048-1063
assign ctrl_top_ir_preg_not_vld = !(rtu_idu_alloc_preg0_vld
                                 && rtu_idu_alloc_preg1_vld
                                 && rtu_idu_alloc_preg2_vld
                                 && rtu_idu_alloc_preg3_vld);
// 同理对 vreg / freg / ereg
```

这些信号用于 top 层的门控时钟判断：当任一位置分配输出尚未有效时，相关控制
逻辑需要保持活动以准备处理可能的 stall。以 PREG 为例，
`ctrl_top_ir_preg_not_vld` 只是四个位置有效位的归约，不能进一步推导成“四条
独立整数空闲选择链均无资源”。

### 7.2 ctrl_ir_stage_stall 汇总

```verilog
// 行 1067-1072
assign ctrl_ir_stage_stall = ctrl_ir_preg_stall
                            || ctrl_ir_vreg_stall
                            || ctrl_ir_freg_stall
                            || ctrl_ir_ereg_stall
                            || rtu_idu_flush_stall
                            || iu_idu_mispred_stall;
```

除了四类 creg stall 之外，还包含：

| 信号 | 来源 | 含义 |
|------|------|------|
| `rtu_idu_flush_stall` | RTU | 异常/中断处理期间，需要等待流水线排空 |
| `iu_idu_mispred_stall` | IU（整数执行单元） | 分支预测失败，需要等待前端重新取指 |

**为什么 mispred_stall 在 IR 级处理**：分支预测失败后，正确的指令流需要若干周期才能到达 IR 阶段。在此期间，IR 阶段不应放行已有指令（即使重命名资源充足），因为这些指令是分支后错误路径上的指令（虽然通常已经被 flush 清除，但 mispred_stall 提供了额外的保护窗口）。

### 7.3 ctrl_ir_stall 与 ID 级的关系

```verilog
// 行 1078
assign ctrl_ir_stall = ir_inst0_vld && (ctrl_is_stall || ctrl_ir_stage_stall);
```

**含义**：IR stall 的触发条件是：
1. IR 阶段有有效指令（`ir_inst0_vld = 1`，以 slot0 为代表）
2. 且下游 IS stall（`ctrl_is_stall`）或 IR 自身 stage stall 发生

**为什么以 `ir_inst0_vld` 为代表**：slot0 总是最先被填充，如果 slot0 有效则说明 IR 阶段有指令。（实际上这里是一个简化——只要有任一 IR slot 有效就应该 stall，但 slot0 是最低编号的指令，正常流水时其有效性代表了 IR 阶段整体状态。）

**传播方向**：`ctrl_ir_stall` 被送回 ID 阶段，使 ID 阶段暂停流水（不向 IR 发送新指令）。这形成了经典的**背压（backpressure）机制**。

---

## 8. 物理寄存器分配信号（alloc_vld）

IR 阶段在每个非 stall 周期向 RTU 申请物理寄存器分配：

```verilog
// 行 1083-1098（以 preg 为例）
assign idu_rtu_ir_preg0_alloc_vld = ir_inst0_vld
                                    && !ctrl_ir_stall
                                    && dp_ctrl_ir_inst0_dst_vld
                                    && !dp_ctrl_ir_inst0_dst_x0;
```

条件：
1. `ir_inst0_vld`：IR slot0 有有效指令
2. `!ctrl_ir_stall`：IR 阶段未 stall（若 stall，重命名无法完成，不应分配）
3. `dp_ctrl_ir_inst0_dst_vld`：该指令有目标寄存器（无目标寄存器的指令不需要重命名）
4. `!dp_ctrl_ir_inst0_dst_x0`：目标寄存器不是 x0（x0 是整数零寄存器，写 x0 是 NOP）

向量（vreg）、浮点（freg）和 EREG 的分配控制形式类似，但不检查整数 `x0`：
freg/vreg 没有硬连零的逻辑寄存器，EREG 则是一条全局状态贡献版本链，根本不
使用整数逻辑寄存器编号。三者“分配形式类似”不表示保存的数据或恢复语义相同。

### 门控时钟版本（gateclk_vld）

```verilog
// 行 1139-1143
assign idu_rtu_ir_preg_alloc_gateclk_vld =
            ir_inst0_vld && dp_ctrl_ir_inst0_dst_vld
         || ir_inst1_vld && dp_ctrl_ir_inst1_dst_vld
         || ir_inst2_vld && dp_ctrl_ir_inst2_dst_vld
         || ir_inst3_vld && dp_ctrl_ir_inst3_dst_vld;
```

`gateclk_vld` 故意不与 `ctrl_ir_stall` 相与，因此它是功能 `alloc_vld` 的活动上界：
只要 IR 中存在带目的寄存器的有效指令，就可让 RTU 的相关门控逻辑提前看到请求。
这里的“提前”是相对于最终、受 stall 限定的分配有效，不代表固定提前 1 个完整周期；
准确相位和路径预算需看上下游寄存边界及 STA。

---

## 9. 预分发控制信号（Pre-Dispatch Signals）

IR 阶段在流水到 IS 之前组合计算各槽的目标 IQ、create 口 enable 与 select，并以
`ctrl_ir_pre_dis_*` 输出。IS 侧随后寄存/使用这些信息，因此队列分类和 create
选择不是在各 IQ 内重新从 opcode 开始译码。该分层改变了组合逻辑所在的流水级；
能否“压缩关键路径”以及关键路径是否转移到 IR，需要 STA 证明。

### 9.1 IS inst valid 准备

```verilog
// 行 1419-1424
assign ctrl_ir_pre_dis_inst0_vld = ir_pipedown_inst0_vld;
assign ctrl_ir_pre_dis_inst1_vld = ir_pipedown_inst1_vld;
assign ctrl_ir_pre_dis_inst2_vld = ir_pipedown_inst2_vld
                                   && !ctrl_ir_pre_dis_type_stall_pipedown2;
assign ctrl_ir_pre_dis_inst3_vld = ir_pipedown_inst3_vld
                                   && !ctrl_ir_pre_dis_type_stall_pipedown2;
```

slot2/slot3 额外被 `ctrl_ir_pre_dis_type_stall_pipedown2` 屏蔽，原因见 9.2。

### 9.2 type stall pipedown2 信号

```verilog
// 行 1459-1495
assign ctrl_ir_pre_dis_3_biq_inst =
            ctrl_ir_inst0_biq_vld && ctrl_ir_inst1_biq_vld && ctrl_ir_inst2_biq_vld
         || ctrl_ir_inst0_biq_vld && ctrl_ir_inst1_biq_vld && ctrl_ir_inst3_biq_vld
         || ...;   // 4选3 的组合：至少有3条 BIQ 指令

// 同理对 AIQ0, AIQ1, LSIQ, VIQ0, VIQ1 检测"至少3条"

assign ctrl_ir_pre_dis_type_stall_pipedown2 = ctrl_ir_pre_dis_3_biq_inst
                                           || ctrl_ir_pre_dis_3_aiq0_inst
                                           || ctrl_ir_pre_dis_3_aiq1_inst
                                           || ctrl_ir_pre_dis_3_lsiq_inst
                                           || ctrl_ir_pre_dis_3_viq0_inst
                                           || ctrl_ir_pre_dis_3_viq1_inst;
```

**体系结构原理**：被检测的每个目标队列在该接口上有两个 create 口；若四槽候选
中至少三条指向同一个被检测队列，当前接口无法在一拍内为该队列创建全部表项。
RTL 因此把预分发包截断为最老的两个槽：`inst0/1_vld` 保留，
`inst2/3_vld` 同时屏蔽，并令 `ctrl_ir_pre_dis_pipedown2` 提示后续保留/重排。
注意 inst2/inst3 不一定恰好都是造成超额的那一类；这是按程序序切割整个包，而
不是从四槽中任意挑出两个同类指令。

**注意**：这里检测的是"至少3条同类型指令"，而不是"至少2条"。原因是：即便有2条同类型指令，IQ 也能在一个周期内接收（2个 create 端口），不会 stall；只有3条及以上才会超出容量。

### 9.3 IQ create enable/select 准备

以 AIQ0/AIQ1 为例说明复杂的分配逻辑：

#### AIQ0 create enable

```verilog
// 行 1646-1648
assign ctrl_ir_pre_dis_aiq0_create0_en =
            ctrl_ir_pre_dis_al_1_aiq0_inst   // 至少1条 aiq0 专用指令
         || ctrl_ir_pre_dis_al_1_aiq01_inst;  // 或至少1条 aiq01（ALU）指令
```

**含义**：只要有任意 aiq0 专用（DIV/SPECIAL）或 AIQ01 共享（ALU）指令，就需要激活 AIQ0 的第一个 create 端口。

```verilog
// 行 1650-1656
assign ctrl_ir_pre_dis_aiq0_create1_en =
            ctrl_ir_pre_dis_al_2_aiq0_inst
         || ctrl_ir_pre_dis_al_1_aiq01_inst
            && (ctrl_ir_pre_dis_al_1_aiq0_inst && ctrl_ir_pre_dis_al_1_aiq1_inst)
         || ctrl_ir_pre_dis_al_2_aiq01_inst
            && (ctrl_ir_pre_dis_al_1_aiq0_inst || ctrl_ir_pre_dis_al_1_aiq1_inst)
         || ctrl_ir_pre_dis_al_3_aiq01_inst;
```

**含义（分情况）**：

| 条件 | 说明 |
|------|------|
| `al_2_aiq0` | 有2条 AIQ0 专用指令，需要2个 create 端口 |
| `al_1_aiq01 && al_1_aiq0 && al_1_aiq1` | 1个 aiq01 被 aiq0 占用，还有1个 aiq1 和1个 aiq0，aiq0 create0 给 aiq0 专用，aiq01 去 aiq0 create1 |
| `al_2_aiq01 && al_1_aiq0/1` | 2个 aiq01，有其他 aiq0/1 指令填满 aiq1，aiq0 需要2个 create |
| `al_3_aiq01` | 3个 aiq01，每个 IQ 各接收若干，aiq0 需要2个 create |

这套逻辑处理的是**预分发端口匹配**：在一个组合阶段内，把最多四个有序槽映射
到多个队列的 create0/create1。它不是 IQ 内部从 ready 集合选择执行指令的
issue scheduler。当前实现把选择结果从 IR 送到 IS 使用；这种流水分工意在控制
dispatch 逻辑深度，但实际时序收益仍以 STA 为准。

#### AIQ0 create0 select（实际选哪条指令）

```verilog
// 行 1695-1708
always @(...) begin
  if(ctrl_ir_pre_dis_aiq0_create0_sel_inst0)
    ctrl_ir_pre_dis_aiq0_create0_sel[1:0] = 2'd0; // inst0
  else if(ctrl_ir_pre_dis_aiq0_create0_sel_inst1)
    ctrl_ir_pre_dis_aiq0_create0_sel[1:0] = 2'd1; // inst1
  else if(ctrl_ir_pre_dis_aiq0_create0_sel_inst2)
    ctrl_ir_pre_dis_aiq0_create0_sel[1:0] = 2'd2; // inst2
  else
    ctrl_ir_pre_dis_aiq0_create0_sel[1:0] = 2'd3; // inst3
end
```

该优先链在对应候选条件成立时优先选择较小槽号，因而 create0 通常承载该目标类
中较老的候选，create1 再选择剩余候选。它维持当前包内选择的程序序倾向，但不能
单凭这个 2-bit MUX 宣称整个乱序核“按序发射”；不同 IQ 可以独立 dispatch，
IQ 内部也会在 ready 集合中按各自年龄逻辑选择执行。

BIQ、LSIQ、SDIQ、VIQ0、VIQ1 有类似的 create enable/select 逻辑，此处不再逐一展开，原理相同。

---

## 10. 动态负载均衡（DLB）

### 10.1 AIQ DLB

C910 有两个整数 ALU 队列 AIQ0 和 AIQ1。ALU 类（aiq01）指令可以去任意一个。为防止两个队列负载不均，引入 DLB（Dynamic Load Balance）机制。

```verilog
// 行 1285-1308
assign ctrl_aiq_entry_cnt_diff[3:0] = aiq0_ctrl_entry_cnt_updt_val[3:0]
                                      - aiq1_ctrl_entry_cnt_updt_val[3:0];
assign ctrl_aiq_entry_cnt_diff_8    = (aiq0 == 4'd8) && (aiq1 == 4'd0);
assign ctrl_aiq_entry_cnt_diff_7_2  = !diff[3] && (|diff[2:1]);
// 若 aiq0 比 aiq1 多2个以上空闲条目，启用 DLB
assign ctrl_aiq_dlb_updt_vld = !cp0_idu_dlb_disable
                                && (ctrl_aiq_entry_cnt_diff_8
                                 || ctrl_aiq_entry_cnt_diff_7_2);

always @(posedge dlb_clk or negedge cpurst_b) begin
  if(!cpurst_b) ctrl_aiq_dlb_en <= 1'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush)
    ctrl_aiq_dlb_en <= 1'b0;  // flush 时关闭 DLB
  else if(aiq0_ctrl_entry_cnt_updt_vld || aiq1_ctrl_entry_cnt_updt_vld)
    ctrl_aiq_dlb_en <= ctrl_aiq_dlb_updt_vld;
end
```

**触发条件**：AIQ0 空闲条目数 - AIQ1 空闲条目数 >= 2，说明 AIQ0 比 AIQ1 更空（可接收更多指令）。

**DLB 效果**：当 `ctrl_aiq_dlb_en = 1` 时，原本属于 aiq01（可去任意 AIQ）的 ALU 指令被改为优先去 AIQ1（`ctrl_ir_instN_aiq1` 置1，`ctrl_ir_instN_aiq01` 置0），以平衡两个队列的负载。

```verilog
// 行 1345-1349
assign ctrl_ir_inst0_aiq1 =
            ctrl_ir_inst0_aiq1_bef_dlb
         || ctrl_ir_inst0_aiq01_bef_dlb && ctrl_aiq_dlb_en;
assign ctrl_ir_inst0_aiq01 =
            ctrl_ir_inst0_aiq01_bef_dlb && !ctrl_aiq_dlb_en;
```

**特殊规则（inst2/inst3）**：

```verilog
// 行 1357-1365
assign ctrl_ir_inst2_aiq1 =
            ctrl_ir_inst2_aiq1_bef_dlb
         || ctrl_ir_inst2_aiq01_bef_dlb
            && !(ctrl_ir_inst0_aiq01_bef_dlb && ctrl_ir_inst1_aiq01_bef_dlb)
            && ctrl_aiq_dlb_en;
```

**含义**：若 inst0 和 inst1 已经都被 DLB 改为去 AIQ1，则 inst2/inst3 不再做 DLB 修改（因为 AIQ1 每周期只有2个 create 端口，已经满了）。这避免了 AIQ1 过载。

### 10.2 VIQ DLB

VIQ DLB 复用了与 AIQ DLB 相同形状的差值阈值、独立状态寄存器和
inst0/1 优先重定向规则，但操作的是 `viq0/viq1` 计数与 `PIPE67` 类别。二者
属于两套并列状态：更新 valid、flush 清零和类别字段分别连接，不能把“方程结构
相同”写成所有信号、负载或执行语义完全对称。

**DLB 门控时钟**：

```verilog
// 行 1260-1265
assign dlb_clk_en = ctrl_aiq_dlb_en
                    || aiq0_ctrl_entry_cnt_updt_vld
                    || aiq1_ctrl_entry_cnt_updt_vld
                    || ctrl_viq_dlb_en
                    || viq0/1_ctrl_entry_cnt_updt_vld;
```

`dlb_clk_en` 在 DLB 使能本身或 AIQ/VIQ 计数更新时为 1。它定义独立的本地时钟请求，
使 DLB 状态不必与 IR 主寄存器共享同一活动条件；实际停钟仍受公共 ICG 配置约束。

---

## 11. ROB/PST fold 与 create 信号

### Fold（折叠）机制

C910 支持将多条非存储类的短指令"折叠"到同一个 ROB 条目，以提高 ROB 的利用率。

**fold 条件（行 2400-2420）**：

```verilog
assign ctrl_ir_inst0_fold =
            (ctrl_ir_inst0_aiq01 || ctrl_ir_inst0_aiq0 || ctrl_ir_inst0_aiq1)
            && !ctrl_ir_inst0_special
         || (ctrl_ir_inst0_viq0 || ctrl_ir_inst0_viq1 || ctrl_ir_inst0_viq01);
```

整数 ALU/乘法/除法类指令（非 special）以及所有向量指令可以折叠；分支（BIQ）和访存（LSIQ）不可折叠。

```verilog
// 行 2422-2427
assign ctrl_ir_pre_dis_inst0_fold = ctrl_ir_pre_dis_inst0_vld
                                    && ctrl_ir_inst0_fold
                                    && !ctrl_ir_inst0_split     // 非拆分指令
                                    && !ctrl_ir_inst0_intmask   // 非中断屏蔽指令
                                    && !rtu_idu_srt_en          // SRT（自修复）关闭时
                                    && !cp0_idu_rob_fold_disable; // CP0 未禁用 fold
```

### ROB create 信号

折叠指令共享 ROB 条目，因此 4 条指令不一定对应 4 个 ROB create 端口：

```verilog
// 行 2475-2480（rob_create1_en 的 always block）
if(ctrl_ir_pre_dis_inst012_fold)      // inst0/1/2 三条折叠在一起
  ctrl_ir_pre_dis_rob_create1_en = ctrl_ir_pre_dis_inst3_vld;   // create1 给 inst3
else if(ctrl_ir_pre_dis_inst01_fold)  // inst0/1 折叠
  ctrl_ir_pre_dis_rob_create1_en = ctrl_ir_pre_dis_inst2_vld;   // create1 给 inst2
else
  ctrl_ir_pre_dis_rob_create1_en = ctrl_ir_pre_dis_inst1_vld;   // 正常：create1 给 inst1
```

ROB create0 选择（`rob_create0_sel`）：

```verilog
// 行 2500-2505
assign ctrl_ir_pre_dis_rob_create0_sel[1:0] =
           {2{ctrl_ir_pre_dis_inst012_fold}} & 2'd2   // inst0/1/2 折叠 -> create0 代表 inst2
         | {2{ctrl_ir_pre_dis_inst01_fold}}  & 2'd1;  // inst0/1 折叠 -> create0 代表 inst1
         // 否则 2'd0：create0 代表 inst0（正常情况）
```

**为什么 sel 是 inst2 而不是 inst0**：ROB 的 `create0_sel` 控制的是这个 ROB 条目"代表"哪条实际指令（用于确定 ROB IID）。折叠时，多条指令共用一个 ROB 条目，以编号最大的那条指令作为代表（inst2 或 inst1），因为后续 commit 时需要知道是哪个 PC 范围内的指令完成了。

### PST create iid 选择

```verilog
// 行 2537-2538
assign ctrl_ir_pre_dis_pst_create1_iid_sel = ctrl_ir_pre_dis_inst01_fold
                                          || ctrl_ir_pre_dis_inst012_fold;
```

PST（Physical register Status Table）记录物理寄存器的分配状态。折叠指令共用 ROB IID，因此 PST create 时也需要知道用哪个 IID（`iid_sel` 控制选择 inst0 的 IID 还是 inst1/2 的 IID）。

---

## 12. 性能监控（HPCP）

```verilog
// 行 2605
assign ctrl_ir_hpcp_inst_vld = !ctrl_ir_stall;

// 行 2610-2645
always @(posedge hpcp_clk or negedge cpurst_b) begin
  if(!cpurst_b) begin
    ctrl_ir_hpcp_inst0_vld_ff <= 1'b0; ...
  end
  else if(hpcp_idu_cnt_en && ctrl_ir_hpcp_inst_vld) begin
    ctrl_ir_hpcp_inst0_vld_ff <= ir_inst0_vld;
    ctrl_ir_hpcp_inst1_vld_ff <= ir_inst1_vld;
    ...
    ctrl_ir_hpcp_inst0_type   <= dp_ctrl_ir_inst0_hpcp_type;
    ...
  end
  else begin
    ctrl_ir_hpcp_inst0_vld_ff <= 1'b0; ...  // 不统计
  end
end
```

HPCP（Hardware Performance Counter）在每个 IR stall = 0 的周期记录指令信息：

- 当 `ctrl_ir_stall = 0` 且 `hpcp_idu_cnt_en = 1` 时，统计有多少条指令通过了 IR 阶段（未 stall）
- 统计每条指令的类型（`hpcp_type[6:0]`），便于分析各类指令的执行频率

`hpcp_clk_en` 在“计数使能且本拍任一 IR valid”或任一前拍
`ctrl_ir_hpcp_inst*_vld_ff` 为 1 时成立。后半项给已寄存采样一次清零/推进机会，所以
不能简写成“仅在本拍需要统计时”。最终物理门控同样取决于公共 ICG 配置。

---

## 13. 与相邻模块的协调关系

```
              +-----------+        +-----------+        +-----------+
  rtu_idu_    |           |        |           |        |           |
  alloc_*_vld |  ct_idu_  |        |  ct_idu_  |        |  ct_idu_  |
  ----------->|  ir_ctrl  |        |  ir_dp    |        |  ir_rt    |
              |           |        | (datapath)|        | (rename   |
  rtu_flush   | (control) |        |           |        |  table)   |
  ----------->|           |        |           |        |           |
              +-----------+        +-----------+        +-----------+
                   |  ^                  ^                    ^
    ctrl_ir_stall  |  |  ctrl_ir_        |ctrl_rt_            |ctrl_rt_
    ctrl_ir_       |  |  pipedown_       |inst*_vld           |inst*_vld
    pipedown_*     |  |  inst*_vld       |                    |
                   v  |                  |                    |
              +-----------+        +-----------+
              |  ct_idu_  |        |  ct_idu_  |
              |  id_ctrl  |        |  is_ctrl  |
              | (ID stage |        | (IS stage |
              |  control) |        |  control) |
              +-----------+        +-----------+
                                        |
                                        | ctrl_is_stall
                                        | ctrl_is_dis_type_stall
                                        v
                              [反馈回 ir_ctrl 的 stall 输入]
```

### 与 ct_idu_ir_dp（IR 数据路径）

- `ir_ctrl` 向 `ir_dp` 输出 `ctrl_dp_ir_inst0_vld`（IR slot0 有效，决定数据路径是否更新）
- `ir_dp` 向 `ir_ctrl` 输入 `dp_ctrl_ir_inst[0-3]_*`（指令的目标寄存器信息、控制信息、HPCP 类型）

### 与 ct_idu_ir_rt（整数重命名表）

- `ir_ctrl` 输出 `ctrl_rt_inst[0-3]_vld`（哪些槽的指令需要整数重命名）
- `ir_rt` 在收到 valid 后进行 preg 的读旧映射/写新映射操作，并向 RTU 申请具体的 preg 号

### 与 ct_idu_ir_frt（浮点重命名表）/ ct_idu_ir_vrt（向量重命名表）

与 `ir_rt` 类似，`ctrl_rt_inst*_vld` 也同时发给 `frt` 和 `vrt`，分别处理 freg 和 vreg 的重命名。

### 与 ct_idu_is_ctrl（IS 阶段控制）

- `ir_ctrl` 向 `is_ctrl` 输出：
  - `ctrl_ir_pipedown_inst[0-3]_vld`：流水有效信号
  - `ctrl_ir_pipedown`：IS 阶段整体门控时钟使能
  - `ctrl_ir_pre_dis_*`：预分发控制信号（IQ create en/sel）
  - `ctrl_ir_type_stall_inst2/3_vld`：当前 IS 内有哪些指令（供 type stall 判断）
- `is_ctrl` 向 `ir_ctrl` 反馈：
  - `ctrl_is_stall`：IS 级总 stall
  - `ctrl_is_dis_type_stall`：IS 级 type stall
  - `ctrl_is_inst2/3_vld`：IS 阶段 slot2/3 的当前有效状态
  - `ctrl_xx_is_inst*_sel`：IS 阶段数据选择控制

---

## 14. 关键时序路径总结

| 路径 | 关键信号 | 优化方式 |
|------|---------|---------|
| pipedown valid 生成 | `ir_pipedown_instN_vld` | 不直接串入 dispatch stall，保留本级分配 stall；实际时序看 STA |
| creg stall 生成 | `ctrl_ir_preg_stall` 等 | 由 IR valid/目的类型与 RTU 分配有效组合；不宣称固定门延迟 |
| Pre-Dispatch 信号 | `ctrl_ir_pre_dis_aiq*_create*` | 在 IR 阶段提前计算，流水到 IS 使用，不在 IS 实时计算 |
| DLB 更新 | `ctrl_aiq_dlb_en` | 使用独立本地门控请求；仍属于 CPU 时钟体系，不能称为独立低频域 |
| 物理寄存器分配申请 | `idu_rtu_ir_preg*_alloc_vld` | 由 IR 状态和目的字段组合产生；精确逻辑深度看综合网表 |

### stall 信号与 valid 信号的关系汇总

```
                    [IR 寄存器]
                    ir_inst0_vld ~ ir_inst3_vld
                          |
          +---------------+---------------+
          |                               |
    [creg stall 检测]              [直接输出]
    ctrl_ir_preg_stall              ctrl_rt_inst*_vld    --> ir_rt/frt/vrt
    ctrl_ir_vreg_stall              ctrl_top_ir_inst*_vld --> top
    ctrl_ir_freg_stall
    ctrl_ir_ereg_stall
          |
    ctrl_ir_stage_stall = creg_stall || mispred_stall || flush_stall
          |
          +---------> ctrl_ir_pipedown_stall = stage_stall || type_stall
          |                   |
          |           ir_pipedown_inst*_vld                --> IS 阶段
          |           ctrl_ir_pipedown                     --> IS 门控时钟
          |
    ctrl_ir_stall = ir_inst0_vld && (is_stall || stage_stall)
          |
          +---------> [反压 ID 阶段，阻止新指令流入 IR]
          |
          +---------> idu_rtu_ir_*_alloc_vld = inst_vld && !ctrl_ir_stall && dst_vld
                                           --> RTU（申请物理寄存器）
```

从体系结构角度，这套设计的价值在于把三件事分开：IR 重命名资源不足时阻止新
映射提交，type stall 时保留并前移 IS 的未分发槽，dispatch stall 时保持 IS
状态并向 IR 反压。这样既避免丢失或重复创建指令，又不要求所有 valid 都串过同一
个总 stall 方程。功能正确性还依赖 IS、各 IQ、RTU/ROB 的跨模块协议；目标频率、
关键路径长度和性能收益则必须由验证、STA 与工作负载测量支撑。
