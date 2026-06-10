# C910 IDU — IS 阶段控制核心：`ct_idu_is_ctrl` 深度解析

> **文件**：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_ctrl.v`（1768 行）
>
> **在系列中的位置**：本文是 IDU 系列第 11 篇，专注于 IS（Issue/Dispatch）阶段的总控模块。
> 阅读前建议先理解 `00_idu_overview.md` 的四级流水结构和发射队列概念。

---

## 目录

1. [IS 阶段职责：顺序→乱序的分界点](#1-is-阶段职责)
2. [模块总体结构与设计思路](#2-模块总体结构)
3. [端口说明（分组详解）](#3-端口说明)
4. [门控时钟：两路独立 ICG](#4-门控时钟)
5. [IS 流水线寄存器——inst valid 组](#5-is-inst-valid-寄存器)
6. [IS 流水线寄存器——dispatch control 组](#6-dispatch-control-寄存器)
7. [IS 数据通路更新控制（is_inst_sel 信号）](#7-is-数据通路更新控制)
8. [type stall 判定](#8-type-stall-判定)
9. [ROB 创建控制（核心之核心）](#9-rob-创建控制)
10. [PST 物理寄存器状态表维护信号](#10-pst-控制)
11. [LSU VMB 创建控制](#11-lsu-vmb-创建控制)
12. [PCFIFO 分配信号](#12-pcfifo-分配信号)
13. [Barrier 指令有效信号](#13-barrier-指令有效信号)
14. [发射队列分发握手（7 个队列的统一模式）](#14-发射队列分发握手)
15. [发射队列满状态预判（Full Prepare 机制）](#15-发射队列满状态预判)
16. [VMB 满状态预判](#16-vmb-满状态预判)
17. [Queue Full 寄存器与 dispatch stall 生成](#17-dispatch-stall-生成)
18. [IS stall 总合成](#18-is-stall-总合成)
19. [信号流全景图](#19-信号流全景图)
20. [常见问题与设计权衡](#20-常见问题与设计权衡)

---

## 1. IS 阶段职责

### 1.1 顺序→乱序的分界点

C910 IDU 有四个流水级：**ID → IR → IS → RF**。

```
顺序域（程序序严格保持）         乱序域（就绪时即可执行）
─────────────────────────      ─────────────────────────
 IFU → ID(译码) → IR(重命名)  →  IS(分发) → 发射队列 → RF → EX
                               ▲
                        顺序/乱序分界点
```

**IS 阶段是顺序→乱序的最后关卡**：

- 上游（IR 阶段）严格按程序序输出已重命名的指令，每周期最多 4 条（inst0~inst3，inst0 总是最老的）。
- IS 阶段按程序序把这 4 条指令**同时**写入各自对应的发射队列（dispatch）。
- 一旦进入发射队列，指令就可以乱序地在操作数就绪时被唤醒（issue）并执行。
- IS 阶段同时向 RTU 申请 ROB 表项，向 LSU 申请 VMB 表项，通知 RTU 更新 PST。

### 1.2 is_ctrl 的核心职责

`ct_idu_is_ctrl` 是 IS 阶段的**纯控制模块**，不处理任何指令数据（操作数、立即数等）。它负责：

| 职责 | 对应输出信号类型 |
|------|-----------------|
| 维护 IS 流水线寄存器（inst valid） | `is_inst*_vld` 寄存器组 |
| 维护分发控制信息（队列选择/ROB sel） | `is_dis_*` 寄存器组 |
| 驱动 ROB 创建使能 | `idu_rtu_rob_create*_en` |
| 驱动 PST 更新使能 | `idu_rtu_pst_dis_inst*_*reg_vld` |
| 驱动 VMB 创建使能 | `idu_lsu_vmb_create*_en` |
| 驱动 7 个发射队列的创建使能 | `ctrl_aiq0/1/biq/lsiq/sdiq/viq0/1_create*_en` |
| 生成 stall 信号反压上游 | `ctrl_is_stall`, `ctrl_is_dis_type_stall` |
| 生成数据通路 mux 选择 | `ctrl_xx_is_inst_sel`, `ctrl_dp_is_dis_*_sel` |

---

## 2. 模块总体结构

### 2.1 内部分层

```
ct_idu_is_ctrl
│
├── 门控时钟生成（ICG）
│   ├── is_inst_clk        ── 驱动 IS 流水线寄存器
│   └── queue_full_clk     ── 驱动 IQ full 状态寄存器
│
├── IS 流水线寄存器
│   ├── is_inst{0..3}_vld       ── 当前 IS 级有效 inst（由 IR pipedown 驱动）
│   └── is_dis_{inst/aiq/biq/lsiq/sdiq/viq/rob/pst/vmb}_{*}
│                                ── 分发控制信息（由 IR pre_dis 驱动）
│
├── IS 数据通路控制
│   ├── is_dis_type_stall        ── type stall 判定
│   ├── ctrl_xx_is_inst0_sel     ── inst0 数据来源选择
│   └── ctrl_xx_is_inst_sel      ── inst1/2/3 数据来源选择
│
├── ROB 创建控制
├── PST 控制
├── LSU VMB 创建控制
├── PCFIFO 分配控制
├── Barrier 指令检测
├── 发射队列创建控制（7 个队列，共 14 个创建端口）
├── 发射队列满预判（Full Prepare）
└── Dispatch Stall / IS Stall 生成
```

### 2.2 两类使能信号的设计模式

RTL 中每个创建操作都有**三种**使能信号，这是 C910 功耗优化的典型模式：

| 信号后缀 | 含义 | 使用场景 |
|----------|------|---------|
| `_en` | 真正的功能使能（含 stall 检查） | 写入队列/ROB/VMB 的功能触发 |
| `_dp_en` | 数据通路使能（不含 stall，检查资源满） | 驱动 mux 写入数据，避免写 full 表项时损坏数据 |
| `_gateclk_en` | 门控时钟使能（仅看指令是否存在） | 打开对应存储单元的时钟，最宽松，功耗敏感 |

例如 ROB create0（行 1239–1258）：
```verilog
// 行 1239-1258
assign idu_rtu_rob_create0_en         = is_dis_inst0_vld && !ctrl_is_dis_stall;
assign idu_rtu_rob_create0_dp_en      = is_dis_inst0_vld && !rtu_idu_rob_full;
assign idu_rtu_rob_create0_gateclk_en = is_dis_inst0_vld;
```

- `_en`：inst0 有效 **且** 当前 dispatch 没有 stall → 才真正写入 ROB。
- `_dp_en`：inst0 有效 **且** ROB 没满 → 才让数据通路把数据写过去（即使 stall 也可以，因为 ROB 有空间）。
- `_gateclk_en`：只要 inst0 有效就打开时钟，提前准备，不检查任何 full/stall。

> **设计原理**：`_en` 是"是否真的写"，`_dp_en` 是"数据写不写过去"（写满的表项会造成错误），`_gateclk_en` 是"要不要给该表项上电"。三者粒度从细到粗，控制逻辑复杂度和功耗按需分离。

---

## 3. 端口说明

### 3.1 来自 IR 阶段的输入

#### IR pipedown（IS 级 inst valid 信息）

| 信号名 | 宽度 | 含义 |
|--------|------|------|
| `ctrl_ir_pipedown_inst{0..3}_vld` | 1×4 | IR→IS 流水 valid（用于更新 `is_inst*_vld`） |
| `ctrl_ir_pipedown_gateclk` | 1 | IR 流水的门控时钟使能（触发 is_inst_clk） |

#### IR pre_dis（IS 级分发控制预计算）

IR 阶段在自己的最后一拍提前计算好下一拍（IS）需要的所有分发控制信息，这样 IS 阶段只需要一个寄存器打拍，不增加关键路径延迟。

| 信号组 | 含义 |
|--------|------|
| `ctrl_ir_pre_dis_inst{0..3}_vld` | IS 分发有效位（比 pipedown_inst*_vld 晚一拍捕捉） |
| `ctrl_ir_pre_dis_{队列名}_create{0/1}_en` | 指令应进入哪个队列的使能 |
| `ctrl_ir_pre_dis_{队列名}_create{0/1}_sel[1:0]` | 指令在该队列中从哪条 IR inst 来（mux 选择） |
| `ctrl_ir_pre_dis_rob_create{0..3}_sel` | ROB 创建的数据通路选择 |
| `ctrl_ir_pre_dis_rob_create{1..3}_en` | ROB 创建 1/2/3 使能（create0 固定从 dis_inst0_vld） |
| `ctrl_ir_pre_dis_pst_create{1..3}_iid_sel` | PST IID 选择（IID = Instruction Identifier） |
| `ctrl_ir_pre_dis_vmb_create{0/1}_en/sel` | VMB 创建使能和数据选择 |
| `ctrl_ir_pre_dis_pipedown2` | 本批次是 2-inst pipedown 模式（非4条） |

#### type stall 相关

| 信号名 | 含义 |
|--------|------|
| `ctrl_ir_type_stall_inst2_vld` | 若 IR inst2 存在某类型约束，发出 type stall |
| `ctrl_ir_type_stall_inst3_vld` | 若 IR inst3 存在某类型约束，发出 type stall |

### 3.2 来自各发射队列的反压输入

每个队列提供以下信号，共 7 个队列（aiq0/aiq1/biq/lsiq/sdiq/viq0/viq1）：

| 信号后缀 | 含义 |
|----------|------|
| `*_ctrl_full` | 队列当前已满（组合逻辑） |
| `*_ctrl_full_updt` | 队列下一拍是否会满（考虑发射消耗） |
| `*_ctrl_1_left_updt` | 队列下一拍只剩 1 个空位 |
| `*_ctrl_empty` | 队列当前为空（用于 HAD debug 接口） |
| `*_ctrl_full_updt_clk_en` | 队列满预判更新的门控时钟使能 |

### 3.3 RTU 接口

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `rtu_idu_rob_full` | ROB 空间不足（不能再创建） |
| in | `rtu_idu_flush_fe` | Front-end flush（刷新至 IR 前） |
| in | `rtu_idu_flush_is` | IS flush（用于 queue_full 寄存器复位） |
| in | `rtu_yy_xx_flush` | 全局 flush |
| out | `idu_rtu_rob_create{0..3}_{en/dp_en/gateclk_en}` | ROB 创建三种使能 |
| out | `idu_rtu_pst_dis_inst{0..3}_{preg/vreg/freg/ereg}_vld` | PST 更新有效位 |

### 3.4 LSU 接口

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `lsu_idu_vmb_full` | VMB 满（不能写数据） |
| in | `lsu_idu_vmb_full_updt` | VMB 下一拍满 |
| in | `lsu_idu_vmb_1_left_updt` | VMB 下一拍只剩 1 项 |
| in | `lsu_idu_vmb_empty` | VMB 空（用于 iq_empty） |
| out | `idu_lsu_vmb_create{0/1}_{en/dp_en/gateclk_en}` | VMB 创建三种使能 |

### 3.5 数据通路（dp）接口

来自 `ct_idu_is_dp` 的指令属性（只读，已寄存在 IS 流水线中）：

| 信号 | 含义 |
|------|------|
| `dp_ctrl_is_inst{0..3}_dst_vld` | 整数目的寄存器有效（有 preg 写） |
| `dp_ctrl_is_inst{0..3}_dstv_vld` | 向量/浮点目的寄存器有效 |
| `dp_ctrl_is_inst{0..3}_dstv_vec` | 目的是向量寄存器（1=vreg, 0=freg） |
| `dp_ctrl_is_inst{0..3}_dste_vld` | CSR/扩展目的寄存器有效 |
| `dp_ctrl_is_inst{0..3}_bar` | Barrier 指令标志 |
| `dp_ctrl_is_inst{0..3}_pcfifo` | 需要写 PCFIFO 的指令 |

### 3.6 其他全局信号

| 信号 | 含义 |
|------|------|
| `cpurst_b` | 全局复位（低有效） |
| `forever_cpuclk` | 无门控的基础时钟 |
| `iu_yy_xx_cancel` | IU 发出的取消（分支预测失败等） |
| `cp0_idu_icg_en` / `cp0_yy_clk_en` | CP0 控制的 ICG 全局使能 |
| `pad_yy_icg_scan_en` | 测试扫描模式 ICG 使能 |

---

## 4. 门控时钟

模块使用两个独立的门控时钟单元（gated_clk_cell），体现了精细的功耗管理：

### 4.1 is_inst_clk（行 927–941）

```verilog
// 行 927-931
assign is_inst_clk_en = ctrl_ir_pipedown_gateclk
                        || is_inst0_vld
                        || is_inst1_vld
                        || is_inst2_vld
                        || is_inst3_vld;
```

**使能条件**：IR 正在打拍（即将有新指令进 IS），**或者** IS 级当前有任何有效指令。

**驱动的寄存器**：全部 `is_inst*_vld` 和 `is_dis_*`（dispatch control）寄存器。

**设计原理**：IS 流水线寄存器只在"有指令在流动"时才翻转，当流水线空时完全停止，节省功耗。

### 4.2 queue_full_clk（行 1571–1598）

```verilog
// 行 1571-1580
assign queue_full_clk_en = ctrl_ir_pipedown_gateclk
                        || is_inst0_vld
                        || aiq0_ctrl_full_updt_clk_en
                        || aiq1_ctrl_full_updt_clk_en
                        || biq_ctrl_full_updt_clk_en
                        || lsiq_ctrl_full_updt_clk_en
                        || sdiq_ctrl_full_updt_clk_en
                        || viq0_ctrl_full_updt_clk_en
                        || viq1_ctrl_full_updt_clk_en
                        || lsu_idu_vmb_full_updt_clk_en;
```

**使能条件**：有指令流动 **或** 任何队列的 full_updt 可能发生变化。

**驱动的寄存器**：`ctrl_is_iq_full` 和 `ctrl_is_vmb_full`（queue full 状态寄存器）。

**设计原理**：队列满状态寄存器需要在队列变化时及时更新，但不需要与指令流水完全同步，独立门控可以更精细地控制翻转时机。

---

## 5. IS inst valid 寄存器

### 5.1 寄存器含义

```
is_inst0_vld, is_inst1_vld, is_inst2_vld, is_inst3_vld
```

这 4 个 1-bit 寄存器记录**当前 IS 流水级**中有哪些槽位持有有效指令。inst0 总是最老的指令，inst3 总是最新的。

### 5.2 更新逻辑（行 957–983）

```verilog
// 行 957-983
always @(posedge is_inst_clk or negedge cpurst_b)
begin
  if(!cpurst_b) begin
    is_inst0_vld <= 1'b0; ...
  end
  else if(rtu_idu_flush_fe || iu_yy_xx_cancel) begin
    is_inst0_vld <= 1'b0; ...   // flush：清空所有槽位
  end
  else if(!ctrl_is_dis_stall) begin
    is_inst0_vld <= ctrl_ir_pipedown_inst0_vld;  // 正常：接收 IR 打拍结果
    ...
  end
  else begin
    is_inst0_vld <= is_inst0_vld;                // stall：保持
    ...
  end
end
```

**优先级（从高到低）**：

1. **复位**（`cpurst_b`）：清零所有有效位
2. **Flush/Cancel**（`rtu_idu_flush_fe || iu_yy_xx_cancel`）：清零（流水线气泡）
3. **无 stall**（`!ctrl_is_dis_stall`）：从 IR 阶段接收新的 pipedown valid
4. **有 stall**：保持当前值（整个 IS 级"冻结"）

> **为什么 flush_fe 而不是 flush_is？**
>
> `rtu_idu_flush_fe` 是前端 flush，代表从取指到 IS 之间所有流水级都要清空（例如分支预测失败、中断）。`flush_is` 只用于 `ctrl_is_iq_full/vmb_full` 寄存器的复位（因为资源满状态在 flush 后要重新评估，而指令本身已通过 `flush_fe` 清空）。

### 5.3 输出

```verilog
// 行 986-999
assign ctrl_dp_is_inst0_vld  = is_inst0_vld;   // 送 IS 数据通路
assign ctrl_top_is_inst0_vld = is_inst0_vld;   // 送 IS 顶层（其他模块）
assign ctrl_is_inst2_vld     = is_inst2_vld;   // 送 IR 阶段（用于 type stall 判断）
assign ctrl_fence_is_pipe_empty = !is_inst0_vld; // Fence 指令判断 IS 流水是否空
```

`ctrl_fence_is_pipe_empty` 的逻辑：只要 inst0 无效，就认为 IS 流水为空。原因是 inst0 是最老的指令，如果它无效，说明当前周期 IS 级没有"正在等待分发"的指令批次，fence 类指令可以安全推进。

---

## 6. dispatch control 寄存器

### 6.1 寄存器含义与来源

dispatch control 寄存器组（行 1004–1198）保存 **IS→DIS 阶段**（IS 分发阶段）所需的全部控制信息，由 IR 阶段的 `ctrl_ir_pre_dis_*` 提前一拍计算好后打入。

**寄存器命名模式**：`is_dis_{目标}_{操作}_{_en|_sel|_iid_sel}`

| 寄存器子组 | 包含寄存器 | 作用 |
|-----------|-----------|------|
| inst valid | `is_dis_inst{0..3}_vld` | 分发槽位有效（比 is_inst 晚一个半周期） |
| pipedown2 | `is_dis_pipedown2` | 标记本批次是否为 2-inst pipedown |
| AIQ0/1 create | `is_dis_aiq{0/1}_create{0/1}_{en,sel}` | AIQ 创建使能和来源选择 |
| BIQ create | `is_dis_biq_create{0/1}_{en,sel}` | BIQ 创建使能和来源选择 |
| LSIQ create | `is_dis_lsiq_create{0/1}_{en,sel}` | LSIQ 创建使能和来源选择 |
| SDIQ create | `is_dis_sdiq_create{0/1}_{en,sel}` | SDIQ 创建使能和来源选择 |
| VIQ0/1 create | `is_dis_viq{0/1}_create{0/1}_{en,sel}` | VIQ 创建使能和来源选择 |
| ROB create | `is_dis_rob_create{1..3}_{en,sel}`, `is_dis_rob_create0_sel` | ROB 分配控制 |
| PST iid_sel | `is_dis_pst_create{1..3}_iid_sel` | PST IID 写入选择 |
| VMB create | `is_dis_vmb_create{0/1}_{en,sel}` | VMB 创建使能和来源选择 |

### 6.2 为什么需要两套 vld（is_inst vs is_dis）

```
IR 阶段最后一拍
  │
  ├── 计算 ctrl_ir_pipedown_inst*_vld   ─→  is_inst*_vld (早一拍)
  └── 计算 ctrl_ir_pre_dis_inst*_vld   ─→  is_dis_inst*_vld (晚一拍)
```

**is_inst_vld**：用于 IS 流水线本身的状态（fence 检测、type stall 输入、is_inst_clk 使能等），需要尽早有效。

**is_dis_inst_vld**：用于分发目标（ROB create、IQ create）的使能逻辑，与 pre_dis 控制寄存器对齐，保证时序一致性。

两套信号实质上携带同一信息（同一批指令），只是时序对齐点不同，是精心的时序优化结果。

### 6.3 更新逻辑（与 is_inst 完全对称）

```verilog
// 行 1102-1148（正常更新路径）
else if(!ctrl_is_dis_stall) begin
  is_dis_inst0_vld  <= ctrl_ir_pre_dis_inst0_vld;
  is_dis_pipedown2  <= ctrl_ir_pre_dis_pipedown2;
  is_dis_aiq0_create0_en  <= ctrl_ir_pre_dis_aiq0_create0_en;
  // ... 所有 is_dis_* 全部从 ctrl_ir_pre_dis_* 更新
end
```

stall 时整组保持，flush 时整组清零（同 is_inst 组）。

---

## 7. IS 数据通路更新控制

### 7.1 背景：pipedown2 模式

C910 IS 阶段支持两种 pipedown 模式：

- **pipedown4**：IR→IS 一次打入 4 条指令（inst0~inst3），正常高吞吐情况
- **pipedown2**：IR→IS 一次只打入 2 条指令（inst0~inst1），另 2 条保留在 IS 缓冲区

pipedown2 模式出现于：上游只有 2 条就绪指令，或者因 type stall 只能发送 2 条时。

此时 IS 阶段保存 4 条指令的方式是：

```
pipedown2 时：
  is_inst0 = 原 is_inst2（已在 IS 级的旧指令）
  is_inst1 = 原 is_inst3（已在 IS 级的旧指令）
  is_inst2/3 = ir_inst0/1（新来的 2 条）

pipedown4 时：
  is_inst0 = ir_inst0
  is_inst1 = ir_inst1
  is_inst2 = ir_inst2
  is_inst3 = ir_inst3
```

### 7.2 inst0 数据来源选择（行 1219–1222）

```verilog
// 行 1219-1222
// 1. pipedown2：is inst0 来自原来的 is_inst2
assign ctrl_xx_is_inst0_sel[0] = is_dis_pipedown2;
// 2. pipedown4：is inst0 来自 ir_inst0
assign ctrl_xx_is_inst0_sel[1] = !is_dis_pipedown2;
```

`ctrl_xx_is_inst0_sel` 是 2-bit one-hot 编码，送到 IS 数据通路的 mux。

### 7.3 inst1/2/3 数据来源选择（行 1224–1231）

```verilog
// 行 1224-1231
// pipedown2 且 is_inst3 有效 → is_inst1 来自旧 is_inst3，is_inst2/3 来自 ir_inst0/1
assign ctrl_xx_is_inst_sel[0] = is_dis_pipedown2 && is_inst3_vld;
// pipedown2 且 is_inst3 无效 → is_inst1/2/3 来自 ir_inst0/1/2
assign ctrl_xx_is_inst_sel[1] = is_dis_pipedown2 && !is_inst3_vld;
// pipedown4 → is_inst1/2/3 来自 ir_inst1/2/3
assign ctrl_xx_is_inst_sel[2] = !is_dis_pipedown2;
```

`ctrl_xx_is_inst_sel` 是 3-bit one-hot 编码，控制 IS 数据通路中 inst1/2/3 的 mux 选择。

三种情况汇总：

| `is_dis_pipedown2` | `is_inst3_vld` | sel[0] | sel[1] | sel[2] | inst0 来自 | inst1 来自 | inst2 来自 | inst3 来自 |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 0 | - | 0 | 0 | 1 | ir_inst0 | ir_inst1 | ir_inst2 | ir_inst3 |
| 1 | 1 | 1 | 0 | 0 | is_inst2(旧) | is_inst3(旧) | ir_inst0 | ir_inst1 |
| 1 | 0 | 0 | 1 | 0 | is_inst2(旧) | ir_inst0 | ir_inst1 | ir_inst2 |

---

## 8. type stall 判定

### 8.1 逻辑（行 1206–1214）

```verilog
// 行 1206-1214
assign is_dis_type_stall =
  is_dis_pipedown2
  && (is_inst3_vld && ctrl_ir_type_stall_inst2_vld
  || !is_inst3_vld && ctrl_ir_type_stall_inst3_vld);

assign ctrl_is_dis_type_stall = is_dis_type_stall;
```

### 8.2 含义解释

**type stall** 是一种特殊的流水线停顿，发生在 pipedown2 模式下 IR 新指令和 IS 中已有指令发生**类型约束冲突**时。

具体触发条件：

1. 当前批次是 **pipedown2**（`is_dis_pipedown2 = 1`）
2. **且**满足以下任一：
   - IS 中已有 inst3（4 槽全满），而 IR 新来的 inst2（即将成为新 is_inst2）存在类型约束 → `is_inst3_vld && ctrl_ir_type_stall_inst2_vld`
   - IS 中 inst3 空（3 槽占用），而 IR 新来的 inst3 存在类型约束 → `!is_inst3_vld && ctrl_ir_type_stall_inst3_vld`

**类型约束**的来源（由 `ct_idu_ir_ctrl` 计算）：某些特殊指令（如 barrier、load-use 相关约束等）不能与特定位置的指令组成同一个 pipedown 批次。

**效果**：type stall 会传递到 `ctrl_is_stall`，阻止 IR→IS 打拍，直到类型约束解除。

---

## 9. ROB 创建控制

ROB（Reorder Buffer，重排序缓冲区）是乱序处理器维护"程序序"的核心结构。每条分发的指令都需要在 ROB 中占一个表项，记录：指令编号（IID）、完成状态、异常信息等。退休时按 ROB 顺序提交，保证精确异常语义。

### 9.1 设计关键：create0 总是来自 dis_inst0_vld

```verilog
// 行 1239-1240（注释原文：create 0 always from dis_inst0_vld）
assign idu_rtu_rob_create0_en = is_dis_inst0_vld && !ctrl_is_dis_stall;
```

**inst0 始终是最老的指令**，ROB create0 总是对应 inst0。这是乱序处理器的基本约束：ROB 表项必须按程序序分配，inst0 先于 inst1 先于 inst2 先于 inst3 获得 ROB 位置。

**为什么 create0 没有 `_en` 控制位？** 因为 inst0 必然占 ROB create0 端口，不存在"inst0 有效但不用 create0"的情况，所以 IR 阶段没有为它单独计算 `rob_create0_en`，直接用 `is_dis_inst0_vld`。

create1/2/3 则需要 IR 阶段根据指令类型、pipedown 模式等因素预先计算是否需要（`is_dis_rob_create{1..3}_en`）。

### 9.2 四路 create 使能（行 1239–1258）

```verilog
// 行 1239-1258
assign idu_rtu_rob_create0_en         = is_dis_inst0_vld && !ctrl_is_dis_stall;
assign idu_rtu_rob_create1_en         = is_dis_rob_create1_en && !ctrl_is_dis_stall;
assign idu_rtu_rob_create2_en         = is_dis_rob_create2_en && !ctrl_is_dis_stall;
assign idu_rtu_rob_create3_en         = is_dis_rob_create3_en && !ctrl_is_dis_stall;

assign idu_rtu_rob_create0_dp_en      = is_dis_inst0_vld && !rtu_idu_rob_full;
assign idu_rtu_rob_create1_dp_en      = is_dis_rob_create1_en && !rtu_idu_rob_full;
assign idu_rtu_rob_create2_dp_en      = is_dis_rob_create2_en && !rtu_idu_rob_full;
assign idu_rtu_rob_create3_dp_en      = is_dis_rob_create3_en && !rtu_idu_rob_full;

assign idu_rtu_rob_create0_gateclk_en = is_dis_inst0_vld;
assign idu_rtu_rob_create1_gateclk_en = is_dis_rob_create1_en;
assign idu_rtu_rob_create2_gateclk_en = is_dis_rob_create2_en;
assign idu_rtu_rob_create3_gateclk_en = is_dis_rob_create3_en;
```

注意 `_dp_en` 使用 `rtu_idu_rob_full` 而不是 `ctrl_is_dis_stall`。这是因为：

- `ctrl_is_dis_stall` 会因 ROB 满、IQ 满或 VMB 满而置 1；
- 若 ROB 满导致 stall，数据通路不应写入 ROB（ROB 已满没有空槽）；
- 若 IQ 满导致 stall，ROB 本身有空间，数据通路可以先写好（ROB 会等待），所以 `dp_en` 只看 `rob_full`。

### 9.3 ROB create 数据通路选择（行 1260–1266）

```verilog
// 行 1260-1266
assign ctrl_dp_is_dis_rob_create0_sel[1:0] = is_dis_rob_create0_sel[1:0];
assign ctrl_dp_is_dis_rob_create1_sel[2:0] = is_dis_rob_create1_sel[2:0];
assign ctrl_dp_is_dis_rob_create2_sel[1:0] = is_dis_rob_create2_sel[1:0];

assign ctrl_dp_is_dis_pst_create1_iid_sel      = is_dis_pst_create1_iid_sel;
assign ctrl_dp_is_dis_pst_create2_iid_sel[2:0] = is_dis_pst_create2_iid_sel[2:0];
assign ctrl_dp_is_dis_pst_create3_iid_sel[2:0] = is_dis_pst_create3_iid_sel[2:0];
```

这些 sel 信号送到 `ct_idu_is_dp`，控制 ROB 创建时数据通路从哪条 inst 取数据（`is_dis_rob_create0_sel` 为 2-bit，`rob_create1_sel` 为 3-bit，覆盖更多组合情况，因为 create1 在 pipedown2 时可能来自不同位置）。

### 9.4 ROB 与 dispatch 的关系

```
每周期 dispatch 的 N 条指令（N ≤ 4）
→ 向 RTU 申请 N 个 ROB 表项（rob_create0 ~ rob_create{N-1}）
→ RTU 分配 N 个 IID（指令标识符），按 create0 ~ create{N-1} 顺序递增
→ IID 写回 IS 分发数据通路，填入发射队列和 PST 表项
```

ROB 满（`rtu_idu_rob_full`）会触发 dispatch stall，整个 IS 级暂停分发。

---

## 10. PST 控制

PST（Physical register Status Table，物理寄存器状态表）记录每个物理寄存器的当前状态（空闲/被分配/就绪）。分发时需要通知 RTU 更新 PST，标记新分配的物理目的寄存器为"in-flight"（已分配但未就绪）。

### 10.1 四类目的寄存器

C910 区分四类寄存器文件，对应不同的 PST 状态表：

| 类型 | 信号后缀 | 含义 |
|------|---------|------|
| preg | `_preg_vld` | 整数物理寄存器（x0-x31 的物理映射） |
| vreg | `_vreg_vld` | 向量物理寄存器（V 扩展） |
| freg | `_freg_vld` | 浮点物理寄存器（F/D 扩展） |
| ereg | `_ereg_vld` | CSR/扩展寄存器 |

### 10.2 PST 使能生成（行 1271–1329）

以 preg 为例：

```verilog
// 行 1271-1282
assign ctrl_dis_inst0_preg_vld = is_dis_inst0_vld
                                 && !ctrl_is_dis_stall
                                 && dp_ctrl_is_inst0_dst_vld;
assign ctrl_dis_inst1_preg_vld = is_dis_inst1_vld
                                 && !ctrl_is_dis_stall
                                 && dp_ctrl_is_inst1_dst_vld;
// ... inst2/3 同理
```

**三个条件缺一不可**：
1. `is_dis_inst*_vld`：该槽位有指令
2. `!ctrl_is_dis_stall`：当前周期确实完成分发（没有 stall）
3. `dp_ctrl_is_inst*_dst_vld`：该指令确实有整数目的寄存器写

vreg 的条件更严格（行 1284–1299）：

```verilog
// 行 1284-1287
assign ctrl_dis_inst0_vreg_vld = is_dis_inst0_vld
                                 && !ctrl_is_dis_stall
                                 && dp_ctrl_is_inst0_dstv_vld
                                 && dp_ctrl_is_inst0_dstv_vec;  // 必须是向量（非浮点）
```

freg 恰好相反（行 1301–1304）：

```verilog
// 行 1301-1304
assign ctrl_dis_inst0_freg_vld = is_dis_inst0_vld
                                 && !ctrl_is_dis_stall
                                 && dp_ctrl_is_inst0_dstv_vld
                                 && !dp_ctrl_is_inst0_dstv_vec; // dstv 有效但不是向量 → 浮点
```

**设计原理**：vreg 和 freg 共用同一个目的寄存器端口（`dstv`），通过 `dstv_vec` 标志区分到底写向量还是浮点寄存器，从而更新对应的 PST。这是 C910 向量浮点统一设计的体现。

### 10.3 PST 信号的双重输出

PST 相关信号同时输出到两个目标（行 1332–1371）：

```verilog
// → ct_idu_is_dp（数据通路，用于驱动分发数据写入）
assign ctrl_dp_dis_inst0_preg_vld = ctrl_dis_inst0_preg_vld;
// → RTU PST（物理寄存器状态表，标记新写入的目的寄存器为 in-flight）
assign idu_rtu_pst_dis_inst0_preg_vld = ctrl_dis_inst0_preg_vld;
```

---

## 11. LSU VMB 创建控制

VMB（Virtual Memory Buffer，或 Vector Memory Buffer）是 LSU 为访存指令（load/store）预留的缓冲区。访存指令分发时必须同时在 LSU 的 VMB 中占一个位置。

### 11.1 使能生成（行 1376–1389）

```verilog
// 行 1376-1389
assign idu_lsu_vmb_create0_en      = is_dis_vmb_create0_en && !ctrl_is_dis_stall;
assign idu_lsu_vmb_create1_en      = is_dis_vmb_create1_en && !ctrl_is_dis_stall;
assign idu_lsu_vmb_create0_dp_en   = is_dis_vmb_create0_en && !lsu_idu_vmb_full;
assign idu_lsu_vmb_create1_dp_en   = is_dis_vmb_create1_en && !lsu_idu_vmb_full;
assign idu_lsu_vmb_create0_gateclk_en = is_dis_vmb_create0_en;
assign idu_lsu_vmb_create1_gateclk_en = is_dis_vmb_create1_en;

assign ctrl_dp_is_dis_vmb_create0_sel[1:0] = is_dis_vmb_create0_sel[1:0];
assign ctrl_dp_is_dis_vmb_create1_sel[1:0] = is_dis_vmb_create1_sel[1:0];
```

`is_dis_vmb_create{0/1}_en` 是 IR 阶段预计算好的"哪些 inst 需要 VMB 条目"，只有访存类指令（load、store、向量访存等）才会置 1。

VMB 满（`lsu_idu_vmb_full`）会通过 `ctrl_is_vmb_full`（经过一拍寄存，见第 16 节）传递到 dispatch stall。

---

## 12. PCFIFO 分配信号

PCFIFO 是分支预测器中的一个结构，记录 dispatch 指令的 PC（程序计数器）。某些指令（如间接跳转、需要记录返回地址的 call）需要在分发时向 IU（Integer Unit）的 PCFIFO 写入 PC 信息。

### 12.1 逻辑（行 1523–1545）

```verilog
// 行 1523-1545
assign ctrl_is_pcfifo_inst0_vld = is_dis_inst0_vld
                                  && !ctrl_is_dis_stall
                                  && dp_ctrl_is_inst0_pcfifo;
// ... inst1/2/3 同理

assign idu_iu_is_pcfifo_inst_vld = (ctrl_is_pcfifo_inst0_vld || ... || ctrl_is_pcfifo_inst3_vld)
                                   && !ctrl_is_dis_stall;

// 注意：inst_num 计算不包含 dis_stall（时序优化）
assign idu_iu_is_pcfifo_inst_num[2:0] = {2'b0, ctrl_is_pcfifo_inst0_vld}
                                        + {2'b0, ctrl_is_pcfifo_inst1_vld}
                                        + {2'b0, ctrl_is_pcfifo_inst2_vld}
                                        + {2'b0, ctrl_is_pcfifo_inst3_vld};
```

RTL 注释说明（行 1541）：`inst_num` 的计算不包含 `ctrl_is_dis_stall`，这是**时序优化**的刻意决策——stall 信号在 dispatch 时通常是关键路径，通过 `inst_vld` 信号提前给 IU 估算数量，由 IU 侧结合 `inst_vld` 再做最终判断。

---

## 13. Barrier 指令有效信号

```verilog
// 行 1551-1554
assign ctrl_lsiq_is_bar_inst_vld = is_inst0_vld && dp_ctrl_is_inst0_bar
                                || is_inst1_vld && dp_ctrl_is_inst1_bar
                                || is_inst2_vld && dp_ctrl_is_inst2_bar
                                || is_inst3_vld && dp_ctrl_is_inst3_bar;
```

注意：这里使用的是 `is_inst*_vld`（IS 流水线寄存器），**不是** `is_dis_inst*_vld`，也**不检查 stall**。

**设计原理**：barrier 指令（如 fence、sfence.vma）需要等待 LSIQ 排空后才能执行。LSIQ ctrl 模块监视 `ctrl_lsiq_is_bar_inst_vld` 信号来阻止新的 load/store 进入队列直到 barrier 完成。这个检测需要尽早（IS 级一出现就报告），不能等到分发成功才报告，否则 barrier 会滞后生效。

---

## 14. 发射队列分发握手

### 14.1 统一设计模式

7 个发射队列（AIQ0/AIQ1/BIQ/LSIQ/SDIQ/VIQ0/VIQ1），每个队列有 2 个创建端口（create0/create1），共 14 个端口。每个端口遵循完全相同的三段式模式（以 AIQ0 create0 为例，行 1395–1401）：

```verilog
// 行 1395-1401
assign ctrl_aiq0_create0_en         = is_dis_aiq0_create0_en && !ctrl_is_dis_stall;
assign ctrl_aiq0_create0_dp_en      = is_dis_aiq0_create0_en && !aiq0_ctrl_full;
assign ctrl_aiq0_create0_gateclk_en = is_dis_aiq0_create0_en;
assign ctrl_dp_is_dis_aiq0_create0_sel[1:0] = is_dis_aiq0_create0_sel[1:0];
```

### 14.2 14 个创建端口一览

| 队列 | 功能 | create0 来源 | create1 来源 |
|------|------|-------------|-------------|
| AIQ0 | ALU 整数运算管线 0 | is_dis_aiq0_create0_en | is_dis_aiq0_create1_en |
| AIQ1 | ALU 整数运算管线 1 | is_dis_aiq1_create0_en | is_dis_aiq1_create1_en |
| BIQ | 分支/跳转指令 | is_dis_biq_create0_en | is_dis_biq_create1_en |
| LSIQ | Load/Store 指令 | is_dis_lsiq_create0_en | is_dis_lsiq_create1_en |
| SDIQ | Store-Data 指令 | is_dis_sdiq_create0_en | is_dis_sdiq_create1_en |
| VIQ0 | 向量/浮点管线 0 | is_dis_viq0_create0_en | is_dis_viq0_create1_en |
| VIQ1 | 向量/浮点管线 1 | is_dis_viq1_create0_en | is_dis_viq1_create1_en |

> **为什么 LSIQ 和 SDIQ 分开？**
> Store 指令需要两个动作：（1）计算地址（LSIQ→LSU 地址计算管线）；（2）提交数据写内存（SDIQ→LSU store data 管线）。这两个动作可以乱序相对于其他指令，但 store data 的实际写入必须在 ROB 退休后（精确异常保证）。SDIQ 专门管理 store 的数据传输，与 LSIQ 解耦，提高 load/store 的并行度。

### 14.3 sel[1:0] 的含义

每个创建端口的 `sel[1:0]` 是 2-bit 信号，由 IR 阶段预计算，送到 `ct_idu_is_dp` 驱动 mux，选择该创建端口的数据来自哪条 `is_dis_inst`。编码通常为：

| sel | 含义 |
|-----|------|
| 2'b01 | 来自 is_dis_inst0 的数据 |
| 2'b10 | 来自 is_dis_inst1 的数据 |
| 2'b11 | 来自 is_dis_inst2/3 的数据（具体见 dp 模块） |

具体含义以 IR ctrl 预计算逻辑为准，is_ctrl 模块只负责寄存和透传。

---

## 15. 发射队列满状态预判

### 15.1 为什么需要"预判"

发射队列满状态（`aiq0_ctrl_full`）是从队列内部发出的**组合逻辑信号**，但 dispatch stall 的判断需要在当前周期完成，有时序压力。为了提前一拍决定是否 stall，is_ctrl 采用"预判"机制：

```
当前周期                 下一周期
  ↓                        ↓
is_dis_*_en（即将分发） + 队列满预判信息
  ↓
ctrl_is_iq_full_updt（组合逻辑）
  ↓
ctrl_is_iq_full（寄存一拍）
  ↓
ctrl_is_dis_stall（下一周期的 dispatch stall）
```

### 15.2 _updt 信号的组合逻辑（行 1669–1697）

```verilog
// 行 1669-1697
assign ctrl_is_aiq0_full_updt =
           is_dis_aiq0_create0_en_updt && aiq0_ctrl_full_updt
        || is_dis_aiq0_create1_en_updt && aiq0_ctrl_1_left_updt;
```

**含义分析**：

- `aiq0_ctrl_full_updt`：队列（考虑本周期出队后）下一拍仍然满 → 即使只创建 1 条也会满
- `aiq0_ctrl_1_left_updt`：队列下一拍只剩 1 个位置 → 如果同时创建 2 条（create0 且 create1）则会满
- `is_dis_aiq0_create0_en_updt`：下一拍将要向 AIQ0 分发 1 条（create0）
- `is_dis_aiq0_create1_en_updt`：下一拍将要向 AIQ0 分发第 2 条（create1）

组合逻辑：

```
队列会满 = (分发1条 && 1条就满) || (分发2条 && 1条后才满)
```

### 15.3 _en_updt 的来源（行 1604–1665）

```verilog
// 行 1634-1648（if !stall 分支）
always @(...)
begin
  if(!ctrl_is_dis_stall) begin
    is_dis_aiq0_create0_en_updt = ctrl_ir_pre_dis_aiq0_create0_en; // 下一批指令
    ...
  end
  else begin
    is_dis_aiq0_create0_en_updt = is_dis_aiq0_create0_en; // 当前批次（stall 保持）
    ...
  end
end
```

当没有 stall 时，`_en_updt` 取 IR 阶段新计算的值（预告下一批分发需求）；当有 stall 时，`_en_updt` 取当前 `is_dis_*_en`（因为这批指令还没有分发出去，下一拍还是同样需求）。

### 15.4 总满信号（行 1691–1697）

```verilog
// 行 1691-1697
assign ctrl_is_iq_full_updt = ctrl_is_aiq0_full_updt
                           || ctrl_is_aiq1_full_updt
                           || ctrl_is_biq_full_updt
                           || ctrl_is_lsiq_full_updt
                           || ctrl_is_sdiq_full_updt
                           || ctrl_is_viq0_full_updt
                           || ctrl_is_viq1_full_updt;
```

任何一个队列预判会满，就产生 `ctrl_is_iq_full_updt = 1`，下一拍触发 dispatch stall。

---

## 16. VMB 满状态预判

与 IQ 满预判类似，VMB 也有独立的满预判逻辑（行 1702–1724）：

```verilog
// 行 1720-1724
assign ctrl_is_vmb_full_updt =
           lsu_idu_vmb_full_updt
           && (is_dis_vmb_create0_en_updt || is_dis_vmb_create1_en_updt)
        || lsu_idu_vmb_1_left_updt
           && (is_dis_vmb_create0_en_updt && is_dis_vmb_create1_en_updt);
```

逻辑与 IQ 类似：

- 若 VMB 下拍满 且 有任何访存指令要创建 → 满
- 若 VMB 下拍只剩 1 项 且 同时有两条访存指令要创建 → 满

---

## 17. dispatch stall 生成

### 17.1 Queue Full 寄存器（行 1730–1747）

```verilog
// 行 1730-1744
always @(posedge queue_full_clk or negedge cpurst_b)
begin
  if(!cpurst_b) begin
    ctrl_is_iq_full  <= 1'b0;
    ctrl_is_vmb_full <= 1'b0;
  end
  else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush) begin
    ctrl_is_iq_full  <= 1'b0;
    ctrl_is_vmb_full <= 1'b0;
  end
  else begin
    ctrl_is_iq_full  <= ctrl_is_iq_full_updt;
    ctrl_is_vmb_full <= ctrl_is_vmb_full_updt;
  end
end
```

注意 flush 处理：这里除了 `flush_fe` 外，还响应 `flush_is`（IS flush）和 `rtu_yy_xx_flush`（全局 flush）。原因是：flush 后 IS 级所有指令被清空，没有分发需求，即使队列原来满，清空后也不构成 stall 条件，需要重置满标志。

### 17.2 Dispatch Stall 三个来源（行 1752–1757）

```verilog
// 行 1752-1757
// 1. ROB 满
assign ctrl_is_rob_full = is_dis_inst0_vld && rtu_idu_rob_full;
// 2. IQ 满 或 VMB 满
assign ctrl_is_dis_stall = ctrl_is_rob_full || ctrl_is_iq_full || ctrl_is_vmb_full;
assign ctrl_dp_is_dis_stall = ctrl_is_dis_stall;
```

| 满的来源 | 信号 | 触发条件 |
|---------|------|---------|
| ROB 满 | `ctrl_is_rob_full` | `is_dis_inst0_vld && rtu_idu_rob_full` |
| 发射队列满 | `ctrl_is_iq_full` | 寄存的预判结果（任意队列预判满） |
| VMB 满 | `ctrl_is_vmb_full` | 寄存的预判结果（VMB 预判满） |

**ROB 满检测的特殊性**：`ctrl_is_rob_full` 只在 `is_dis_inst0_vld` 为真时才会置位。原因是：如果 IS 级没有有效指令（inst0_vld=0），即使 ROB 满也不需要 stall（没有要分发的指令）。IQ/VMB 满则直接寄存预判值，不检查 inst_vld，因为预判已经考虑了"是否有分发需求"（`_en_updt` 只在有指令时才有效）。

---

## 18. IS stall 总合成

```verilog
// 行 1763
assign ctrl_is_stall = ctrl_is_dis_stall || is_dis_type_stall;
```

`ctrl_is_stall` 是反压给 IR 阶段的总停顿信号，有两种来源：

| 来源 | 信号 | 含义 |
|------|------|------|
| dispatch stall | `ctrl_is_dis_stall` | 资源不足（ROB/IQ/VMB 满），无法分发 |
| type stall | `is_dis_type_stall` | 指令类型约束冲突，pipedown2 模式下需要等待 |

**传播路径**：
```
ctrl_is_stall → ct_idu_ir_ctrl → IR 阶段 pipedown 禁止 → IFU/ID 停止推送
```

当 `ctrl_is_stall = 1` 时：
- IR 阶段暂停向 IS 打拍（`ctrl_ir_pipedown_inst*_vld` 保持 0）
- IS 级的 `is_inst*_vld` 和 `is_dis_*` 寄存器保持不变（stall 时 else 分支保持）
- 发射队列、ROB、VMB、PST 均不更新

**注意**：dispatch stall 和 type stall 虽然都产生 IS 停顿，但它们的粒度不同：
- dispatch stall 是整体资源问题，停顿是"本批 4 条都不能发"
- type stall 是指令排列约束，可能只需要等待几拍后约束解除就可以继续

---

## 19. 信号流全景图

```
IR 阶段（上游）
    │
    ├── ctrl_ir_pipedown_inst{0..3}_vld  ──→  is_inst{0..3}_vld (FF)
    │                                          │
    │                                          ├──→ ctrl_dp_is_inst*_vld（送 IS dp）
    │                                          ├──→ ctrl_top_is_inst*_vld（送顶层）
    │                                          ├──→ ctrl_fence_is_pipe_empty
    │                                          └──→ is_inst_clk_en（ICG 使能）
    │
    ├── ctrl_ir_pre_dis_*                ──→  is_dis_* (FF)
    │                                          │
    │                                          ├── is_dis_inst{0..3}_vld
    │                                          │    └──→ ROB create{0..3}_en / dp_en
    │                                          │
    │                                          ├── is_dis_{队列名}_create{0/1}_en
    │                                          │    └──→ ctrl_{队列名}_create{0/1}_en/dp_en
    │                                          │
    │                                          ├── is_dis_rob_create{1..3}_en
    │                                          │    └──→ idu_rtu_rob_create{1..3}_en
    │                                          │
    │                                          ├── is_dis_pst_create*_iid_sel
    │                                          │    └──→ ctrl_dp_is_dis_pst_create*_iid_sel
    │                                          │
    │                                          └── is_dis_vmb_create{0/1}_en
    │                                               └──→ idu_lsu_vmb_create{0/1}_en
    │
    ├── ctrl_ir_type_stall_inst{2/3}_vld
    │    └──→ is_dis_type_stall ──→ ctrl_is_stall（反压 IR）
    │
    └── ctrl_ir_pipedown_gateclk ──→ is_inst_clk_en

发射队列（下游）
    │
    ├── {队列名}_ctrl_full_updt / 1_left_updt
    │    └──→ ctrl_is_{队列名}_full_updt
    │          └──→ ctrl_is_iq_full_updt
    │                └──→ ctrl_is_iq_full (FF, queue_full_clk)
    │                      └──→ ctrl_is_dis_stall ──→ ctrl_is_stall（反压 IR）
    │
    └── {队列名}_ctrl_full ──→ ctrl_{队列名}_create{0/1}_dp_en（数据使能）

RTU（下游）
    ├── rtu_idu_rob_full
    │    └──→ ctrl_is_rob_full → ctrl_is_dis_stall
    │    └──→ idu_rtu_rob_create*_dp_en（直接控制数据写入）
    │
    └── rtu_idu_flush_fe / flush_is / rtu_yy_xx_flush（清空流水和状态）

dp 模块
    ├── dp_ctrl_is_inst*_dst/dstv/dste_vld  ──→  PST 控制使能
    ├── dp_ctrl_is_inst*_bar               ──→  ctrl_lsiq_is_bar_inst_vld
    └── dp_ctrl_is_inst*_pcfifo            ──→  idu_iu_is_pcfifo_inst_vld
```

---

## 20. 常见问题与设计权衡

### Q1：为什么 is_inst_vld 和 is_dis_inst_vld 要分开？

`is_inst_vld` 由 IR pipedown 驱动，紧跟 IR→IS 打拍；`is_dis_inst_vld` 由 `ir_pre_dis` 驱动，额外承载分发控制信息（队列选择、ROB sel 等），两者时序对齐点略有不同，但在同一个时钟沿下一起更新，本质上携带相同的"哪些指令有效"信息，只是作为不同下游逻辑的参考基准，避免因多路扇出引入时序问题。

### Q2：为什么 queue full 判断要用寄存一拍的预判值而不是实时的 full 信号？

如果直接用队列的 `ctrl_full` 组合信号，从"队列状态变化"到"stall 生效"再到"IR 停止打拍"形成一条长组合路径，极易成为时序关键路径。使用预判+寄存的方案，虽然引入 1 周期的延迟（即有时会"多打"一拍指令进来，但此时队列还没真的满），但完全消除了该关键路径。

代价是：当预判命中时，IS 级可能在 stall 生效前多收了一批指令（因为预判在上一周期就置位 stall，阻止了 IR 向 IS 打那一拍），实际上这批"多出来"的指令会被阻挡在 IR，不会真正写入满的队列（因为 `_dp_en` 使用实时 `full` 信号）。

### Q3：ROB create0 为什么没有 `_en` 控制位？

ROB 必须按程序序分配表项。inst0 是最老的指令，如果 inst0 有效，它必然使用 create0。IR 阶段的 pre_dis 逻辑为 create1/2/3 计算了使能（因为不同模式下 inst1/2/3 不一定都需要分配 ROB 条目），但 create0 与 inst0 一一对应，不需要额外使能位。

### Q4：type stall 与 dispatch stall 的根本区别？

| 维度 | dispatch stall | type stall |
|------|---------------|------------|
| 原因 | 硬件资源不足（ROB/IQ/VMB 满） | 指令排列约束（类型不兼容） |
| 解决方式 | 等待执行单元消耗队列项目 | 等待 pipedown2 批次内约束消失 |
| 反压粒度 | 整批 4 指令全部停顿 | 仅发生在 pipedown2 模式特定情形 |
| 哪级 stall | IS→IR（通过 ctrl_is_stall） | IS→IR（同一信号） |

### Q5：`ctrl_lsiq_is_bar_inst_vld` 为何不检查 stall？

Barrier 指令的作用是"我之后的所有 load/store 不能在我之前完成"。LSIQ 需要在 barrier 进入 IS 级时**立即**停止接受新的 load/store 进队，不能等到 barrier 实际分发（dispatch）才生效。如果等到分发时才通知 LSIQ，在 stall 期间新的 load/store 可能已经进入 LSIQ，违反了 barrier 语义。因此用 `is_inst*_vld`（比 `is_dis` 更早有效）且不检查 stall，实现最保守最安全的 barrier 检测。

---

*文档覆盖 `ct_idu_is_ctrl.v` 全部 1768 行逻辑。如需进一步了解 IS 数据通路（`ct_idu_is_dp`）或 IR 阶段预分发逻辑（`ct_idu_ir_ctrl`），请参阅系列其他文档。*
