# C910 IDU id_ctrl 模块详解

**源文件**：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_id_ctrl.v`（680 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [ID 流水寄存器](#3-id-流水寄存器)
4. [Debug/HPCP 辅助逻辑](#4-debughpcp-辅助逻辑)
5. [ID 阶段控制信号](#5-id-阶段控制信号)
6. [Pipedown 控制（核心）](#6-pipedown-控制核心)
7. [ID 阶段 Stall 生成](#7-id-阶段-stall-生成)
8. [与 IR 阶段的握手](#8-与-ir-阶段的握手)
9. [关键设计总结](#9-关键设计总结)

---

## 1. 模块概述

### 1.1 IDU 四级流水线全局视图

C910 的指令分发单元（IDU）内部组织为四个流水级：

```
  IFU
   │  ifu_idu_ib_inst{0,1,2}_*  (最多 3 条原始指令 + valid)
   ▼
┌──────────────────────────────────────────────────────┐
│  ID 阶段  (Instruction Decode / 译码)                │
│  ┌─────────────┐   ┌─────────────┐                  │
│  │  id_ctrl    │◄──│  id_dp      │ dp→ctrl 指令类型  │
│  │  (本模块)   │──►│             │ ctrl→dp valid/stall│
│  └─────────────┘   └─────────────┘                  │
│  ┌─────────────┐   ┌──────────────┐                 │
│  │  id_fence   │   │ id_split_long│                 │
│  └─────────────┘   └──────────────┘                 │
└──────────────────────────────────────────────────────┘
   │  ctrl_id_pipedown_inst{0,1,2,3}_vld (最多 4 条微操作)
   ▼
┌──────────────────────────────────────────────────────┐
│  IR 阶段  (Issue-Ready / 重命名+分配)                │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│  IS 阶段  (Issue / 发射队列调度)                     │
└──────────────────────────────────────────────────────┘
   │
   ▼
┌──────────────────────────────────────────────────────┐
│  RF 阶段  (Register Fetch / 寄存器读取 + 派遣到执行) │
└──────────────────────────────────────────────────────┘
```

### 1.2 id_ctrl 在 ID 阶段的地位

`ct_idu_id_ctrl` 是 ID 阶段的**流水控制中枢**，承担以下职责：

| 职责 | 说明 |
|------|------|
| IB 指令选择 | 决定当前周期从 IBUF 接收哪几条指令写入 ID 流水寄存器 |
| ID 流水寄存器维护 | 持有 ID 阶段的 3 路 valid（`id_inst{0,1,2}_vld`）及复位/刷新 |
| 指令类型仲裁 | 与 `id_dp` 配合，将 `dp_ctrl` 类型信号与 valid 合并 |
| Pipedown 判定 | 每周期决定向 IR 下发 1/2/3/4 条微操作，以及每路的 valid |
| Stall 生成 | 汇总 fence、long-split、IR 反压等因素，输出多路 stall |
| 调试/性能计数 | 维护 `debug_id_inst*` 寄存器，向 HAD/HPCP 上报状态 |

### 1.3 吞吐量设计原则

IFU 每周期最多送出 **3 条原始指令**（inst0/1/2）。某些 RISC-V 指令（如向量指令、复杂访存）需要被拆分为多条微操作才能进入后端乱序队列。拆分策略有两种：

- **split_short（短拆分）**：1 条原始指令 → **2** 条微操作，ID 阶段内一次性生成，占用 2 个 pipedown 槽位。
- **split_long（长拆分）**：1 条原始指令 → **多条**微操作（最多 4 条/周期），由专用 `id_split_long` 子模块跨周期迭代生成，每次通过 `split_long_ctrl_inst_vld[3:0]` 告知 id_ctrl 本周期有效微操数。

由于短拆分产生额外槽位，再加上原有指令，ID 阶段向 IR 下发的微操作数可达 **4 条**（pipedown inst0~3）。

---

## 2. 端口说明

### 2.1 来自 IFU / IBUF 的输入

| 端口 | 方向 | 说明 |
|------|------|------|
| `ifu_idu_ib_inst{0,1,2}_vld` | input | IBUF 中 3 槽指令的 valid，用于"3 路 pipedown"模式 |
| `ifu_idu_ib_pipedown_gateclk` | input | IBUF 有数据时的门控使能，驱动 id_inst 时钟 |

### 2.2 来自 id_dp（译码结果）的输入

每条指令（inst0/1/2）均有 4 个互斥类型标志：

| 端口组 | 含义 |
|--------|------|
| `dp_ctrl_id_inst{0,1,2}_normal` | 普通指令，无需拆分 |
| `dp_ctrl_id_inst{0,1,2}_split_short` | 短拆分指令（→2 微操作）|
| `dp_ctrl_id_inst{0,1,2}_split_long` | 长拆分指令（→多微操作）|
| `dp_ctrl_id_inst{0,1,2}_fence` | fence 类指令（需等流水线排空）|

### 2.3 来自子模块的输入

| 端口 | 来源模块 | 含义 |
|------|----------|------|
| `fence_ctrl_id_stall` | `id_fence` | fence 未完成，需暂停 ID |
| `fence_ctrl_inst{0,1,2}_vld` | `id_fence` | fence 状态机本周期各槽 valid |
| `split_long_ctrl_id_stall` | `id_split_long` | 长拆分未完成，需暂停 ID |
| `split_long_ctrl_inst_vld[3:0]` | `id_split_long` | 长拆分本周期 4 路微操作 valid |

### 2.4 来自 IR/后端的反压输入

| 端口 | 来源 | 含义 |
|------|------|------|
| `ctrl_ir_stall` | `ir_ctrl` | IR 阶段整体 stall（ROB/IQ 满等） |
| `ctrl_ir_stage_stall` | `ir_ctrl` | IR 阶段级 stall（用于 HAD 上报）|

### 2.5 全局控制输入

| 端口 | 含义 |
|------|------|
| `cpurst_b` | 复位（低有效） |
| `forever_cpuclk` | 全局时钟，门控单元源时钟 |
| `cp0_yy_clk_en` | 全局时钟使能（省电） |
| `cp0_idu_icg_en` | IDU 模块级时钟门控使能 |
| `pad_yy_icg_scan_en` | 扫描测试时钟门控使能穿透 |
| `rtu_idu_flush_fe` | RTU 发出的前端刷新（异常/误预测回滚） |
| `iu_yy_xx_cancel` | IU 发出的取消信号（分支误预测快速取消）|

### 2.6 输出信号

| 端口 | 去向 | 含义 |
|------|------|------|
| `ctrl_dp_id_inst{0,1,2}_vld` | `id_dp` | ID 寄存器中 3 路 valid，数据路径使能 |
| `ctrl_dp_id_pipedown_{1,2,3}_inst` | `id_dp` | 本周期 pipedown 模式（1/2/3 路输入）|
| `ctrl_dp_id_stall` | `id_dp` | 数据路径 stall（保持 ID 寄存器）|
| `ctrl_id_pipedown_inst{0,1,2,3}_vld` | `ir_ctrl`/`ir_dp` | 下发到 IR 的 4 路微操作 valid |
| `ctrl_id_pipedown_gateclk` | `ir_ctrl` | IR 门控时钟使能（inst0 valid）|
| `ctrl_top_id_inst{0,1,2}_vld` | `idu_top` | 顶层 mux 用 valid |
| `ctrl_fence_id_inst_vld` | `id_fence` | 通知 fence 模块 inst0 是 fence 指令 |
| `ctrl_split_long_id_inst_vld` | `id_split_long` | 通知长拆分模块 inst0 是长拆分指令 |
| `ctrl_split_long_id_stall` | `id_split_long` | 长拆分 stall（等于 `ctrl_ir_stall`）|
| `ctrl_fence_id_stall` | `id_fence` | fence stall（等于 `ctrl_ir_stall`）|
| `idu_ifu_id_stall` | IFU | ID 阶段主 stall，阻止 IBUF 弹出 |
| `idu_ifu_id_bypass_stall` | IFU | bypass 路径 stall |
| `idu_had_id_inst{0,1,2}_vld` | HAD | 调试接口指令 valid |
| `idu_had_pipe_stall` | HAD | 流水线暂停状态上报 |
| `idu_hpcp_backend_stall` | HPCP | 后端 stall 性能计数 |

---

## 3. ID 流水寄存器

### 3.1 IB Pipedown 指令选择（行 251-262）

ID 流水寄存器（`id_inst{0,1,2}_vld`）在每次"不 stall"时从**上游**接收新数据。上游数据的来源由本周期的 pipedown 模式（`ctrl_id_pipedown_{1,2,3}_inst`）决定：

```verilog
// 行 251-254
assign ctrl_ib_pipedown_inst0_vld =
            ctrl_id_pipedown_1_inst && id_inst1_vld        // 1-pipedown：消耗 inst1
         || ctrl_id_pipedown_2_inst && id_inst2_vld        // 2-pipedown：消耗 inst2
         || ctrl_id_pipedown_3_inst && ifu_idu_ib_inst0_vld; // 3-pipedown：从 IBUF 取新指令
```

这段逻辑揭示了一个关键设计：**ID 寄存器可以持有来自 IBUF 的"新"指令，也可以持有上一周期遗留的"旧"指令**。

三种 pipedown 模式下，下一周期 ID 寄存器的内容分别为：

| 模式 | 本周期消耗 | 下周期 ID inst0 来源 | 下周期 ID inst1 来源 | 下周期 ID inst2 来源 |
|------|-----------|---------------------|---------------------|---------------------|
| pipedown_1（下发 1 路） | 仅 inst0 | 当前 id_inst1_vld | 当前 id_inst2_vld | 0 |
| pipedown_2（下发 2 路） | inst0+inst1 | 当前 id_inst2_vld | 0 | 0 |
| pipedown_3（下发 3 路） | inst0+1+2 | IBUF inst0 | IBUF inst1 | IBUF inst2 |

**设计意图**：当 inst0 是 fence 或 long-split 类指令时，只能单独下发 inst0，其余指令（inst1、inst2）留在 ID 寄存器中等待下一周期。这避免了复杂的多路 FIFO 设计，利用流水寄存器自然地实现了"部分消耗"语义。

### 3.2 门控时钟（行 268-281）

```verilog
// 行 268-271
assign id_inst_clk_en = ifu_idu_ib_pipedown_gateclk  // IBUF 有数据准备写入
                        || id_inst0_vld               // ID 寄存器本身有效
                        || id_inst1_vld
                        || id_inst2_vld;
```

门控逻辑：当 IBUF 有新指令（将写入 ID 寄存器）或 ID 寄存器当前有效时，才开启 `id_inst_clk`。否则寄存器时钟被关闭，节省功耗。

`gated_clk_cell` 是标准门控时钟单元，其使能由以下层级决定：

- `global_en`（`cp0_yy_clk_en`）：全局时钟使能，省电模式下关断整个核
- `module_en`（`cp0_idu_icg_en`）：IDU 模块级使能
- `local_en`（`id_inst_clk_en`）：局部动态使能

### 3.3 流水寄存器实现（行 293-315）

```verilog
// 行 293-315
always @(posedge id_inst_clk or negedge cpurst_b)
begin
  if(!cpurst_b) begin                            // 复位：清空所有 valid
    id_inst0_vld <= 1'b0; ...
  end
  else if(rtu_idu_flush_fe || iu_yy_xx_cancel) begin  // 流水线冲刷
    id_inst0_vld <= 1'b0; ...
  end
  else if(!ctrl_id_pipedown_stall) begin         // 正常流动：接收上游数据
    id_inst0_vld <= ctrl_ib_pipedown_inst0_vld; ...
  end
  else begin                                     // stall：保持当前值
    id_inst0_vld <= id_inst0_vld; ...
  end
end
```

**优先级**（从高到低）：

1. **复位**：硬件复位后清零
2. **流水线冲刷**：分支误预测（`iu_yy_xx_cancel`）或异常返回（`rtu_idu_flush_fe`）时立即清零
3. **正常推进**：`ctrl_id_pipedown_stall` 为低时，接收上游计算的新 valid
4. **保持**：stall 时保持当前值不变

**为何冲刷优先级高于 stall？** 在流水线回滚场景中，已经在 ID 阶段译码的指令必须无效化，否则会以错误的 PC 上下文向 IR 下发微操作。冲刷信号具有最高语义优先级。

---

## 4. Debug/HPCP 辅助逻辑

### 4.1 设计背景

C910 支持硬件辅助调试（HAD，类似 JTAG debug）和硬件性能计数器（HPCP）。这两个模块需要观察 ID 阶段的指令流动情况，但直接采样 `id_inst*_vld` 会有竞争问题——寄存器在 stall 时保持不变，调试模块难以分辨"新指令进入 IR"还是"stall 保持"。

### 4.2 debug_id_pipedown3 寄存器（行 352-365）

```verilog
// 行 352-363
assign debug_id_inst_vld = id_inst0_vld
                           && (had_idu_debug_id_inst_en
                            || hpcp_idu_cnt_en);

always @(posedge debug_id_inst_clk or negedge cpurst_b)
begin
  ...
  else if(debug_id_inst_vld)
    debug_id_pipedown3 <= !ctrl_id_stall;   // ID 有指令 且 本周期能推进 → 1
  else
    debug_id_pipedown3 <= 1'b0;
end
```

`debug_id_pipedown3` 含义：**本周期 ID 阶段成功向 IR 下发了（至少一条）指令**。只有在调试或性能计数使能（`had_idu_debug_id_inst_en || hpcp_idu_cnt_en`）时才激活。

`idu_hpcp_backend_stall = !debug_id_pipedown3`：当 ID 没有成功下发时，认为后端（从 ID 往后的流水线）处于 stall 状态，HPCP 据此累计停顿周期数。

### 4.3 debug 快照寄存器（行 371-392）

```verilog
// 行 371-388
always @(posedge debug_id_inst_clk or negedge cpurst_b)
begin
  ...
  else if(debug_id_pipedown3) begin  // 成功下发的那个周期
    debug_id_inst0_vld <= id_inst0_vld;
    debug_id_inst1_vld <= id_inst1_vld;
    debug_id_inst2_vld <= id_inst2_vld;
  end
  else begin
    debug_id_inst{0,1,2}_vld <= 1'b0;
  end
end
```

在"成功下发"的周期，将 `id_inst*_vld` 快照到 `debug_id_inst*_vld` 中，驱动 `idu_had_id_inst{0,1,2}_vld` 输出给 HAD 调试接口。这样 HAD 看到的是"刚进入 IR 的那些指令的 valid"，语义清晰。

---

## 5. ID 阶段控制信号

### 5.1 指令类型 Valid 准备（行 400-414）

```verilog
// 行 400-414
assign ctrl_id_inst0_fence       = id_inst0_vld && dp_ctrl_id_inst0_fence;
assign ctrl_id_inst0_split_short = id_inst0_vld && dp_ctrl_id_inst0_split_short;
assign ctrl_id_inst0_split_long  = id_inst0_vld && dp_ctrl_id_inst0_split_long;
assign ctrl_id_inst0_normal      = id_inst0_vld && dp_ctrl_id_inst0_normal;
// inst1、inst2 同理
```

将 `dp_ctrl`（纯类型标志，不含 valid）与 `id_inst*_vld` 做 AND，生成带有效信息的类型信号。**设计要点**：`dp_ctrl_*` 信号是组合逻辑译码结果，当 `id_inst*_vld=0` 时其值无意义，乘以 valid 后才能安全使用。

### 5.2 fence valid 和 long split valid（行 420-426）

```verilog
// 行 420-426
assign ctrl_fence_id_inst_vld      = ctrl_id_inst0_fence;
assign ctrl_split_long_id_inst_vld = ctrl_id_inst0_split_long;
```

**只有 inst0** 的 fence/split_long 才会激活对应子模块。这是设计约束：**fence 和 long-split 指令只在 inst0 位置时才开始处理**。

原因：fence 需要等流水线排空，long-split 需要多周期迭代，它们都要独占 inst0 槽位并持续驻留，直到子模块完成。如果 inst1 或 inst2 是 fence/long-split，必须等待前面的 inst0 处理完毕后（消耗掉 inst0，inst1 移到 inst0 位置）才能激活子模块。

---

## 6. Pipedown 控制（核心）

### 6.1 整体框架

每个周期，ID 阶段向 IR 阶段下发 **4 路**微操作（pipedown inst0~3），每路有独立的 valid 信号。同时存在三种"从 IBUF 角度看"的 pipedown 模式：

```
pipedown_1_inst：本周期只消耗 ID 中 inst0；inst1/inst2 保留到下周期
pipedown_2_inst：本周期消耗 inst0 + inst1；inst2 保留
pipedown_3_inst：本周期消耗全部 inst0/1/2，并从 IBUF 接收新的 inst0/1/2
```

这三个模式信号**互斥**（虽然代码中没有明示互斥检查，但逻辑上 pipedown_3 覆盖 pipedown_1/2 的情形之外的情形）。

### 6.2 pipedown inst0 valid（行 434-438）

```verilog
// 行 434-438
assign ctrl_id_pipedown_inst0_vld =
            ctrl_id_inst0_normal      && id_inst0_vld
         || ctrl_id_inst0_split_short && 1'b1
         || ctrl_id_inst0_split_long  && split_long_ctrl_inst_vld[0]
         || ctrl_id_inst0_fence       && fence_ctrl_inst0_vld;
```

inst0 总是对应 inst0 本身产生的第一个微操作：

| inst0 类型 | pipedown inst0 有效条件 |
|-----------|------------------------|
| normal | `id_inst0_vld`（inst0 存在即有效）|
| split_short | 恒为 1（split 的第一微操必然有效）|
| split_long | `split_long_ctrl_inst_vld[0]`（由长拆分子模块决定）|
| fence | `fence_ctrl_inst0_vld`（由 fence 状态机决定）|

**为何 split_short 恒为 1？** short-split 指令本身就是一条需要拆分的指令，已经在 ID 寄存器中，一定有效；split_short 的本意就是"这条指令被拆成 2 条"，拆分出的第一条必然存在。

### 6.3 pipedown inst1 valid（行 444-473）

这是最复杂的一个信号，使用组合逻辑 `always` 块（相当于 `assign`，有 sensitivity list）：

```verilog
// 行 444-473（精简）
always @(...)
begin
  if(ctrl_id_inst0_fence)
    ctrl_id_pipedown_inst1_vld = fence_ctrl_inst1_vld;       // ①
  else if(ctrl_id_inst0_split_short)
    ctrl_id_pipedown_inst1_vld = 1'b1;                       // ②
  else if(ctrl_id_inst0_split_long)
    ctrl_id_pipedown_inst1_vld = split_long_ctrl_inst_vld[1]; // ③
  else if(ctrl_id_inst1_fence)
    ctrl_id_pipedown_inst1_vld = 1'b0;                       // ④
  else if(ctrl_id_inst1_split_long)
    ctrl_id_pipedown_inst1_vld = 1'b0;                       // ⑤
  else if(ctrl_id_inst1_split_short)
    ctrl_id_pipedown_inst1_vld = 1'b1;                       // ⑥
  else
    ctrl_id_pipedown_inst1_vld = id_inst1_vld                // ⑦
                                 && !ctrl_id_pipedown_1_inst;
end
```

逻辑优先级与含义：

| 分支 | 触发条件 | inst1 valid 来源 | 含义 |
|------|---------|-----------------|------|
| ① | inst0 是 fence | `fence_ctrl_inst1_vld` | fence 状态机多周期输出第 2 个微操 |
| ② | inst0 是 split_short | 恒 1 | split_short → 2 微操，第 2 微操必然有效 |
| ③ | inst0 是 split_long | `split_long_ctrl_inst_vld[1]` | 长拆分子模块第 2 个输出 |
| ④ | inst1 是 fence | 0 | fence 只能在 inst0 位置激活，此处 inst1 的 fence 不能下发 |
| ⑤ | inst1 是 split_long | 0 | 同上，long-split 需等到 inst0 位置 |
| ⑥ | inst1 是 split_short | 恒 1 | inst1 本身产生 2 微操，第 1 微操（对应 pipedown inst1 槽）有效 |
| ⑦ | 其余（inst1 是 normal 或不存在） | `id_inst1_vld && !pipedown_1` | 只有在非 pipedown_1 模式下才能下发 inst1 |

**④⑤ 的设计哲学**：fence 和 long-split 需要多周期处理且独占 inst0。如果 inst1 是这类指令，本周期 inst1 不能下发（其类型逻辑还没激活），必须等 inst0 处理完、inst1 滑入 inst0 位置后再处理。下发 0 可防止错误流量进入 IR。

**⑦ 中的 `!pipedown_1_inst`**：pipedown_1 模式意味着本周期只下发 1 条（inst0），但 pipedown inst1 的 valid 也要反映出"原始 inst1 是有效的（虽然没有下发）"这一信息——实际上这里 `id_inst1_vld && !ctrl_id_pipedown_1_inst` 在 pipedown_1 时为 0，即不下发 inst1，符合语义。

### 6.4 pipedown inst2 valid（行 478-524）

在 inst1 逻辑基础上增加了对 inst2 自身类型的判断（分支 ⑦ 后还有 inst2_fence、inst2_split_long、inst2_split_short 三个分支）：

```
优先级：inst0 类型 > inst1 类型 > inst2 类型 > 默认（inst2 normal）
```

关键分支（摘录）：

```verilog
// 行 494-524（精简）
  else if(ctrl_id_inst0_split_short && ctrl_id_inst1_split_short)
    ctrl_id_pipedown_inst2_vld = 1'b1;                        // 两个 split_short：inst2 是 inst1 拆出的第 2 微操
  else if(ctrl_id_inst0_split_short)
    ctrl_id_pipedown_inst2_vld = id_inst1_vld && !pipedown_1; // inst0 split_short，inst1 是下一条原始指令
  else if(ctrl_id_inst1_fence || ctrl_id_inst1_split_long)
    ctrl_id_pipedown_inst2_vld = 1'b0;                        // inst1 需等待，inst2 更不行
  else if(ctrl_id_inst1_split_short)
    ctrl_id_pipedown_inst2_vld = 1'b1;                        // inst1 split_short 的第 2 微操
  else if(ctrl_id_inst2_fence || ctrl_id_inst2_split_long)
    ctrl_id_pipedown_inst2_vld = 1'b0;                        // inst2 自身不能单周期激活
  else if(ctrl_id_inst2_split_short)
    ctrl_id_pipedown_inst2_vld = 1'b1;
  else
    ctrl_id_pipedown_inst2_vld = id_inst2_vld && !pipedown_1 && !pipedown_2;
```

### 6.5 pipedown inst3 valid（行 529-568）

inst3 **没有**对应的原始 inst3（IBUF 最多 3 条），其来源只可能是：

- inst0 是 fence：fence 的第 4 个微操（但 fence 最多 3 个微操，故 `ctrl_id_pipedown_inst3_vld = 1'b0`）
- inst0 是 split_long：`split_long_ctrl_inst_vld[3]`
- inst0 split_short + inst1 split_short：两条各拆 2 个，4 个微操，inst3 是 inst1 拆出的第 2 个
- inst0 split_short（inst1 normal）：inst3 是 inst2，仅当不在 pipedown_1/2 模式
- inst1 split_short：inst3 是 inst2 的第一个微操（或 inst2 本身）

```verilog
// 行 541-568（精简）
  if(ctrl_id_inst0_fence)
    ctrl_id_pipedown_inst3_vld = 1'b0;              // fence 最多 3 微操
  else if(ctrl_id_inst0_split_long)
    ctrl_id_pipedown_inst3_vld = split_long_ctrl_inst_vld[3];
  else if(ctrl_id_inst0_split_short && ctrl_id_inst1_split_short)
    ctrl_id_pipedown_inst3_vld = 1'b1;              // inst1 拆出的第 2 微操必然有效
  else if(ctrl_id_inst0_split_short)
    ctrl_id_pipedown_inst3_vld = id_inst2_vld && !pipedown_1 && !pipedown_2;
  else if(ctrl_id_inst1_fence || ctrl_id_inst1_split_long)
    ctrl_id_pipedown_inst3_vld = 1'b0;
  else if(ctrl_id_inst1_split_short)
    ctrl_id_pipedown_inst3_vld = id_inst2_vld && !pipedown_1 && !pipedown_2;
  else
    ctrl_id_pipedown_inst3_vld = ctrl_id_inst2_split_short && !pipedown_1 && !pipedown_2;
```

### 6.6 pipedown 模式判定（行 576-627）

#### pipedown_1_inst（只下发 1 路，行 589-593）

```verilog
// 行 589-593
assign ctrl_id_pipedown_1_inst =
            (ctrl_id_inst0_normal || ctrl_id_inst0_split_short)
             && (ctrl_id_inst1_fence || ctrl_id_inst1_split_long)
         || (ctrl_id_inst0_split_long && !split_long_ctrl_id_stall
             || ctrl_id_inst0_fence && !fence_ctrl_id_stall);
```

触发条件（两种情形，OR 关系）：

**情形 A**：`(inst0 是 normal 或 split_short) AND (inst1 是 fence 或 split_long)`
- inst1 是 fence/split_long，不能与 inst0 同时下发
- inst0 可以正常下发，但 inst1 必须等待
- 因此只下发 inst0（及其 split_short 产生的第 2 微操），inst1/inst2 留存

**情形 B**：`(inst0 是 split_long 且无 stall) 或 (inst0 是 fence 且无 stall)`
- inst0 本身是特殊指令，子模块本周期完成了处理（无 stall），成功下发
- 但这类指令不能与后面的指令同时下发，必须先独立过 IR

**为何 fence/split_long 只能 pipedown_1？** 这是顺序语义的保证：
- fence 要求之前所有指令完成后才能执行，之后的指令必须等 fence 完成
- long-split 是多周期生成微操，本周期完成后 inst0 就被消耗，下一周期 inst1 滑入 inst0

#### pipedown_2_inst（下发 2 路，行 601-609）

```verilog
// 行 601-609
assign ctrl_id_pipedown_2_inst =
            (ctrl_id_inst0_normal || ctrl_id_inst0_split_short)
         && (ctrl_id_inst1_normal || ctrl_id_inst1_split_short)
         && (ctrl_id_inst2_normal
             && ctrl_id_inst0_split_short && ctrl_id_inst1_split_short
          || ctrl_id_inst2_split_short
             && (ctrl_id_inst0_split_short || ctrl_id_inst1_split_short)
          || ctrl_id_inst2_split_long
          || ctrl_id_inst2_fence);
```

触发条件：
1. inst0 和 inst1 都是 normal 或 split_short（可以多发）
2. **AND** inst2 满足以下任一：
   - inst2 是 normal 且 inst0、inst1 都是 split_short（4 微操已满，再加 inst2 normal 超出 4 槽）
   - inst2 是 split_short 且 inst0 或 inst1 中有 split_short（会超出 4 槽）
   - inst2 是 split_long（需要等到 inst0 位置）
   - inst2 是 fence（同上）

**直觉理解**：pipedown_2 在"inst2 不能合并进来"的情况下，把 inst0+inst1 一起下发，inst2 留存到下周期。4 个 pipedown 槽位限制了吞吐量——一旦 split_short 产生了额外微操，槽位就会提前用满。

#### pipedown_3_inst（下发全部 3 路，行 617-623）

```verilog
// 行 617-623
assign ctrl_id_pipedown_3_inst =
            !ctrl_id_1_fence_inst           // 没有 fence 指令
         && !ctrl_id_1_split_long_inst      // 没有 long-split 指令
         && !(ctrl_id_inst2_split_short
              && (ctrl_id_inst0_split_short || ctrl_id_inst1_split_short))
         // inst2 split_short 且 inst0/1 中有 split_short → 超出4槽
         && !(id_inst2_vld
              && (ctrl_id_inst0_split_short && ctrl_id_inst1_split_short));
         // inst0 和 inst1 都是 split_short 且 inst2 存在 → 4槽全满，inst2 无法加入
```

pipedown_3 是"最宽松"的模式，在没有任何特殊指令、且 4 个槽位不会溢出时生效。下表总结三种模式：

```
4 个 pipedown 槽的占用示意（○=有效微操，×=无效）：

普通 3 条 normal：
  inst0(normal)→p0○  inst1(normal)→p1○  inst2(normal)→p2○  p3×
  → pipedown_3，消耗 inst0/1/2

inst0(split_short) + inst1(normal) + inst2(normal)：
  inst0→p0○,p1○（拆出2）  inst1→p2○  inst2→p3○
  → pipedown_3，4槽恰好满

inst0(split_short) + inst1(split_short) + inst2(normal)：
  inst0→p0○,p1○  inst1→p2○,p3○（4槽满）  inst2 无法加入
  → pipedown_2，消耗 inst0/1，inst2 留存

inst0(fence)：
  fence 单独下发，p0○（fence 微操1）...
  → pipedown_1
```

### 6.7 pipedown 模式与 pipedown inst valid 的联动图

```
         ID 寄存器
  ┌──────┬──────┬──────┐
  │inst0 │inst1 │inst2 │
  └──┬───┴──┬───┴──┬───┘
     │      │      │
     ▼      ▼      ▼
  ┌────────────────────────────────────────────────────────┐
  │  pipedown_3_inst（最常见）：inst0/1/2 各对应 p0/p1/p2  │
  │  pipedown_2_inst：inst0→p0, inst1→p1, inst2 保留        │
  │  pipedown_1_inst：inst0→p0, inst1/2 保留                │
  └────────────────────────────────────────────────────────┘
     │p0    │p1    │p2    │p3
     ▼      ▼      ▼      ▼
  ctrl_id_pipedown_inst{0,1,2,3}_vld → IR 阶段
```

当有 split_short 时，原始指令的两个微操分别占用相邻的两个 p 槽。例如 inst0(split_short) 占用 p0+p1，inst1(normal) 占用 p2，inst2(normal) 占用 p3。

---

## 7. ID 阶段 Stall 生成

### 7.1 Stall 信号汇总

```verilog
// 行 644-665
assign ctrl_split_long_id_stall = ctrl_ir_stall;
assign ctrl_fence_id_stall      = ctrl_ir_stall;

assign ctrl_id_split_long_stall = ctrl_id_inst0_split_long
                                  && split_long_ctrl_id_stall;

assign ctrl_id_stall            = id_inst0_vld
                                  && (ctrl_ir_stall
                                   || !ctrl_id_pipedown_3_inst);

assign ctrl_id_bypass_stall     = id_inst0_vld
                                  && (ctrl_ir_stall
                                   || !ctrl_id_pipedown_3_inst_for_bypass);

assign ctrl_id_pipedown_stall   = id_inst0_vld
                                  && (ctrl_ir_stall
                                   || fence_ctrl_id_stall
                                   || ctrl_id_split_long_stall);
```

### 7.2 三路 Stall 的区别与用途

| 信号 | 接收方 | 触发条件 | 含义 |
|------|--------|---------|------|
| `ctrl_id_stall` → `idu_ifu_id_stall` | IFU/IBUF | IR stall 或 非 pipedown_3 | 主 stall：IBUF 停止弹出 |
| `ctrl_id_bypass_stall` → `idu_ifu_id_bypass_stall` | IFU bypass | 同上（timing opt 版本）| bypass 路径专用，时序优化分离 |
| `ctrl_id_pipedown_stall` → `ctrl_dp_id_stall` | id_dp（数据路径）| IR stall 或 fence stall 或 long-split stall | 数据路径保持 ID 寄存器 |

**关键细节**：

1. **`ctrl_id_stall` 的宽泛条件 `!pipedown_3_inst`**：只要本周期不是全速 pipedown_3（即有任何限制），就向上游报告 stall。这是**保守**设计——即使本周期只做 pipedown_1（消耗了 inst0），IFU 也不能立即推入新指令，因为 inst1/inst2 还在 ID 寄存器里，没有空间接收完整的 3 条新指令。

2. **`ctrl_id_pipedown_stall` 的条件更窄**：数据路径寄存器（`id_inst*_vld`）只在 IR stall、fence stall 或 long-split stall 时才保持，否则正常更新。pipedown_1/2 模式下数据路径仍然更新（消耗 inst0 或 inst0+inst1，inst2 或 inst1/2 留存）。

3. **`ctrl_split_long_id_stall = ctrl_ir_stall` 和 `ctrl_fence_id_stall = ctrl_ir_stall`**：长拆分和 fence 子模块依赖 IR 阶段的 stall 作为自己的 stall 信号，因为它们生成的微操必须成功进入 IR 才算"消耗"了一个迭代步骤。IR stall 意味着子模块也需要暂停迭代。

### 7.3 Stall 传播时序图

```
时钟周期：  C1         C2         C3         C4
IR 状态：   正常        stall开始   stall持续  stall结束
                        ↑
                   ctrl_ir_stall=1
                        │
                   ctrl_id_pipedown_stall=1 （数据路径保持）
                   idu_ifu_id_stall=1       （IBUF 冻结）
                        │
                   id_inst*_vld 保持不变
                   IBUF 不再弹出新指令
                        │               C3 继续保持
                                                 │
                                            IR stall 结束
                                            ctrl_ir_stall=0
                                            ctrl_id_pipedown_stall=0
                                            正常 pipedown 恢复
```

### 7.4 HAD 流水线 stall 上报

```verilog
// 行 674-675
assign idu_had_pipe_stall = id_inst0_vld && fence_ctrl_id_stall
                            || ctrl_ir_stage_stall;
```

HAD 模块关心"整个 IDU 流水线是否被阻塞"。这里取 fence stall（ID 阶段特有的阻塞原因）和 IR 阶段 stall（后端压力）的 OR。注意没有包含 `ctrl_id_split_long_stall`，因为 long-split 在非 stall 周期仍然在推进（每周期生成微操），并不构成真正的流水线停顿。

---

## 8. 与 IR 阶段的握手

### 8.1 反压机制

`ctrl_ir_stall` 是 IR 阶段发出的反压信号，来源包括：
- ROB（重排序缓冲）满
- 发射队列（AIQ/BIQ/LSIQ 等）满
- 物理寄存器堆空闲列表耗尽

一旦 IR 无法接受新微操，ID 阶段必须全面暂停，通过 `ctrl_id_pipedown_stall` 冻结自身，通过 `idu_ifu_id_stall` 通知 IFU 停止供应。

### 8.2 pipedown 握手接口

ID→IR 的接口是**无握手**的单向推流：

```
ID 阶段输出：
  ctrl_id_pipedown_inst{0,1,2,3}_vld  （4 路 valid）
  ctrl_id_pipedown_gateclk            （门控时钟使能）
  dp_id_pipedown_inst{0,1,2,3}_data   （来自 id_dp，数据路径）

IR 阶段只能通过 ctrl_ir_stall 反压，不能逐路 ack。
```

### 8.3 门控时钟传递

`ctrl_id_pipedown_gateclk = id_inst0_vld`（行 320）传递给 `ir_ctrl`，用于驱动 IR 阶段流水寄存器的门控时钟。当 ID 没有 inst0（即没有任何可下发的内容）时，IR 的时钟被关闭，节省功耗。

---

## 9. 关键设计总结

### 9.1 指令路数映射关系全图

```
IBUF（最多 3 条原始指令）
  inst0  inst1  inst2
   │      │      │
   ▼      ▼      ▼
ID 流水寄存器（带门控时钟 id_inst_clk）
   id_inst0_vld  id_inst1_vld  id_inst2_vld
   │              │              │
   ▼ 类型译码（id_dp 提供 dp_ctrl_id_inst*_*）
   │
   ├── normal      → 1 pipedown 槽
   ├── split_short → 2 pipedown 槽（连续两个）
   ├── split_long  → 1~4 pipedown 槽（split_long 子模块决定）
   └── fence       → 0~3 pipedown 槽（fence 状态机决定）
   │
   ▼ pipedown 仲裁（本模块核心）
   ctrl_id_pipedown_inst{0,1,2,3}_vld
   │
   ▼
IR 阶段（寄存器重命名 + ROB 分配）
```

### 9.2 设计权衡

| 设计选择 | 具体实现 | 原因 |
|--------|----------|------|
| 3 条原始→4 微操 | 4 路 pipedown | 短拆分最多产生 4 微操，超出 3 路设计上限 |
| pipedown 模式分离 | pipedown_1/2/3 三态 | 允许部分消耗 ID 寄存器，避免复杂 FIFO |
| fence/split_long 只在 inst0 处理 | `ctrl_fence_id_inst_vld = ctrl_id_inst0_fence` | 简化子模块接口，保证顺序语义 |
| pipedown_stall vs id_stall 分离 | 两路 stall 信号 | 数据路径保持需要更窄的 stall 条件 |
| 门控时钟两层（id/debug） | `id_inst_clk` + `debug_id_inst_clk` | 调试路径频率低，分离门控可更好节能 |

### 9.3 边界场景速查

| 场景 | pipedown 模式 | p0 | p1 | p2 | p3 |
|------|-------------|----|----|----|----|
| 3 条 normal | pipedown_3 | inst0 | inst1 | inst2 | - |
| inst0(split_short) + inst1/2(normal) | pipedown_3 | inst0_μop0 | inst0_μop1 | inst1 | inst2 |
| inst0(split_short) + inst1(split_short) | pipedown_2 | inst0_μop0 | inst0_μop1 | inst1_μop0 | inst1_μop1 |
| inst0(normal) + inst1(fence) | pipedown_1 | inst0 | - | - | - |
| inst0(fence), fence 无 stall | pipedown_1 | fence_μop0 | fence_μop1 | fence_μop2 | - |
| inst0(split_long), 无 stall | pipedown_1 | sl_μop0 | sl_μop1 | sl_μop2 | sl_μop3 |
| inst0(split_long), IR stall | 全 stall | - | - | - | - |
