# C910 IDU id_fence 模块详解

> RTL 文件：`ct_idu_id_fence.v`（559 行）
> 所属子模块：IDU（指令分发单元）ID 阶段屏障控制

---

## 目录

1. [模块概述：屏障指令在乱序核中的挑战](#1-模块概述屏障指令在乱序核中的挑战)
2. [RISC-V 屏障指令语义回顾](#2-risc-v-屏障指令语义回顾)
3. [端口说明](#3-端口说明)
4. [fence 指令识别与分类](#4-fence-指令识别与分类)
5. [时钟门控](#5-时钟门控)
6. [流水线空判定（fence_pipeline_empty）](#6-流水线空判定fence_pipeline_empty)
7. [fence 状态机（核心）](#7-fence-状态机核心)
8. [各类屏障的指令包展开](#8-各类屏障的指令包展开)
9. [IR 数据通路打包](#9-ir-数据通路打包)
10. [对外控制信号](#10-对外控制信号)
11. [与 RTU/LSU/HAD 的交互](#11-与-rtulsuHAD-的交互)
12. [fence 完成后的流水线恢复](#12-fence-完成后的流水线恢复)
13. [全模块信号流综合视图](#13-全模块信号流综合视图)

---

## 1. 模块概述：屏障指令在乱序核中的挑战

### 1.1 乱序执行与内存顺序

C910 是一款超标量乱序执行处理器。在乱序核中，指令在发射队列（Issue Queue）中按操作数就绪情况乱序发射，访存操作可以在 Store Buffer、Load Queue 中等待，与程序顺序不同的实际完成顺序对性能有利，但对正确性构成威胁。

屏障指令（fence/fence.i/sfence.vma 等）要求：
- **fence**：屏障之前的所有内存访问（load/store），对屏障之后的内存访问具有可见性顺序保证（基于 pred/succ 字段）。
- **fence.i**：指令流同步，保证取指不会看到旧的指令缓存内容——在写入自修改代码后必须执行。
- **sfence.vma**：TLB 同步，保证 satp/页表写入对后续地址转换可见。

乱序核不能像顺序核那样简单地"等当前指令完成后再取下一条"，必须有专门的机制：
1. **阻止新指令越过屏障**：在屏障到达 ID 阶段后，立刻 stall 住流水线，不让后续指令进入 IS/RF 阶段。
2. **等待已在管线中的指令全部完成**：等 ROB 空、PST 空、除法器空、IR 队列空、IS 队列空。
3. **派发屏障对应的内部微操作**：将屏障编码为内部 barrier/sync 操作送入 LSU 或 CSR 执行单元。
4. **等待微操作执行完毕**：再次等流水线空。
5. **恢复取指**：弹出屏障指令，流水线恢复正常。

`ct_idu_id_fence` 正是负责步骤 1-5 的控制与数据通路核心模块。

### 1.2 在 IDU 中的位置

```
IFU → [ID stage] → [IR stage] → [IS stage] → [RF stage] → EXU/LSU
         ↑
     ct_idu_id_fence
       - 识别 fence 类型
       - 驱动 stall
       - 运行 FSM
       - 产生微操作包
```

`id_fence` 仅处理 **inst0**（槽 0）的屏障指令。RISC-V 规范要求屏障指令是完整的顺序边界，不与其他指令并发发射，因此 C910 限定屏障只能在 inst0 槽出现并独占处理。

---

## 2. RISC-V 屏障指令语义回顾

### 2.1 fence（内存屏障）

```
 31      28 27  24 23  20 19      15 14  12 11       7 6     0
 ┌──────────┬──────┬──────┬─────────┬──────┬─────────┬───────┐
 │  0000    │ pred │ succ │  00000  │ 000  │  00000  │0001111│
 └──────────┴──────┴──────┴─────────┴──────┴─────────┴───────┘
```

- **pred**（bits[27:24]）：屏障前的访存类型（I/O/R/W）
- **succ**（bits[23:20]）：屏障后的访存类型（I/O/R/W）
- C910 实现中将 fence 规范化为 `0xff0000f`（full fence，pred=succ=0xF），统一处理为全屏障，不区分 pred/succ 字段——这是一种常见的保守实现。

### 2.2 fence.i（指令同步）

```
opcode = 0001111, funct3 = 001
完整编码：0x0000100F（标准）
C910 检测：{inst[14:12], inst[6:0]} == 10'b001_0001111
```

fence.i 要求冲刷 I-Cache / 指令流水线，确保后续取指看到最新写入的指令。在 C910 中，fence.i 触发 `fence_type[2]`，会展开为两条内部微操作（见第 8 节）。

### 2.3 sfence.vma（TLB 同步）

```
funct7 = 0001001, funct3 = 000, opcode = 1110011
rs1（bits[19:15]）：VA（虚拟地址），0 表示刷全部 VA
rs2（bits[24:20]）：ASID，0 表示刷全部 ASID
C910 检测：{inst[31:25], inst[14:0]} == 22'b0001001_000000001110011
```

sfence.vma 也属于 `fence_type[2]`，同样展开为两条微操作，其中 rs1/rs2 字段携带 VA 和 ASID 信息，决定 TLB 刷新范围。

### 2.4 T-Head 扩展同步指令（fence_type[0]）

C910 实现了玄铁自定义扩展（需 `cp0_idu_cskyee` 使能）：

| 指令       | 编码         | 语义                     |
|------------|--------------|--------------------------|
| sync       | 0x0180000b   | 同步屏障                 |
| sync.s     | 0x0190000b   | 同步屏障（系统级）       |
| sync.i     | 0x01a0000b   | 同步 + I-Cache 刷新      |
| sync.is    | 0x01b0000b   | 同步 + I-Cache 刷新（系统）|
| dcache.call| 0x0010000b   | D-Cache 清除所有行       |
| dcache.iall| 0x0020000b   | D-Cache 无效所有行       |
| dcache.ciall| 0x0030000b  | D-Cache 清除+无效所有行  |

### 2.5 CSR 类及特权指令（fence_type[1]）

以下指令因为要修改处理器状态或特权级，同样需要清空流水线后串行处理：

| 指令        | 编码特征                          |
|-------------|-----------------------------------|
| sret        | 0x10200073                        |
| mret        | 0x30200073                        |
| wfi         | 0x10500073（等待中断）            |
| csrrw/csrrs/csrrc | funct3=001/010/011, opcode=1110011 |
| csrwi/csrsi/csrci | funct3=101/110/111, opcode=1110011 |

---

## 3. 端口说明

### 3.1 输入端口

| 信号名 | 位宽 | 来源 | 含义 |
|--------|------|------|------|
| `cp0_idu_icg_en` | 1 | CP0 | 时钟门控使能（模块级） |
| `cp0_yy_clk_en` | 1 | CP0 | 全局时钟使能 |
| `cpurst_b` | 1 | 全局 | 低有效复位 |
| `ctrl_fence_id_inst_vld` | 1 | id_ctrl | ID 阶段 inst0 是 fence 指令且有效 |
| `ctrl_fence_id_stall` | 1 | id_ctrl | ID 阶段通用 stall（来自下游背压） |
| `ctrl_fence_ir_pipe_empty` | 1 | ir_ctrl | IR（寄存器读取）流水级为空 |
| `ctrl_fence_is_pipe_empty` | 1 | is_ctrl | IS（发射队列）流水级为空 |
| `dp_fence_id_bkpta_inst` | 1 | id_dp | inst0 命中断点 A |
| `dp_fence_id_bkptb_inst` | 1 | id_dp | inst0 命中断点 B |
| `dp_fence_id_fence_type[2:0]` | 3 | id_dp→id_decd_special | fence 指令类型编码（见第 4 节） |
| `dp_fence_id_inst[31:0]` | 32 | id_dp | inst0 原始 32 位编码 |
| `dp_fence_id_pc[14:0]` | 15 | id_dp | inst0 PC 低 15 位 |
| `dp_fence_id_vl[7:0]` | 8 | id_dp | 向量长度（VL） |
| `dp_fence_id_vl_pred` | 1 | id_dp | 向量断言使能 |
| `dp_fence_id_vlmul[1:0]` | 2 | id_dp | 向量 LMUL |
| `dp_fence_id_vsew[2:0]` | 3 | id_dp | 向量 SEW |
| `forever_cpuclk` | 1 | 全局 | 主时钟 |
| `iu_idu_div_busy` | 1 | IU | 整数除法单元忙碌 |
| `iu_yy_xx_cancel` | 1 | IU | 分支预测取消（冲刷信号） |
| `pad_yy_icg_scan_en` | 1 | PAD | 扫描模式时钟强制打开 |
| `rtu_idu_flush_fe` | 1 | RTU retire | 退休阶段触发前端冲刷（异常/中断） |
| `rtu_idu_pst_empty` | 1 | RTU PST | 物理寄存器状态表（写回追踪）为空 |
| `rtu_idu_rob_empty` | 1 | RTU ROB | 重排序缓冲区为空 |

### 3.2 输出端口

| 信号名 | 位宽 | 去向 | 含义 |
|--------|------|------|------|
| `fence_ctrl_id_stall` | 1 | id_ctrl | 请求 ID 阶段 stall（屏障等待期间） |
| `fence_ctrl_inst0_vld` | 1 | id_ctrl | 通知 inst0 可以 pipedown（进入 IR 阶段） |
| `fence_ctrl_inst1_vld` | 1 | id_ctrl | 通知 inst1 可以 pipedown |
| `fence_ctrl_inst2_vld` | 1 | id_ctrl | 通知 inst2 可以 pipedown |
| `fence_dp_inst0_data[177:0]` | 178 | id_dp | inst0 微操作数据包（IR 数据通路格式） |
| `fence_dp_inst1_data[177:0]` | 178 | id_dp | inst1 微操作数据包 |
| `fence_dp_inst2_data[177:0]` | 178 | id_dp | inst2 微操作数据包 |
| `fence_top_cur_state[2:0]` | 3 | idu_top | 当前 FSM 状态（供外部观测） |
| `idu_had_pipeline_empty` | 1 | HAD | 流水线已空（调试模块感知 CPU 空闲） |
| `idu_hpcp_fence_sync_vld` | 1 | HPCP | fence/sync 类完成脉冲（硬件性能计数） |
| `idu_rtu_fence_idle` | 1 | RTU rob_rt | fence 模块空闲（退休模块判断是否可无限制退休） |

---

## 4. fence 指令识别与分类

### 4.1 分类来源

fence 类型的识别在 `ct_idu_id_decd_special.v` 中完成，结果以 `x_fence_type[2:0]` 传给 `id_dp`，再以 `dp_fence_id_fence_type[2:0]` 传入 `id_fence`。

```verilog
// ct_idu_id_decd_special.v（节选）
assign x_fence         = |x_fence_type[2:0];

// Type[0]：T-Head 自定义 sync/dcache 类（需 cskyee 使能）
assign x_fence_type[0] = cp0_idu_cskyee
                      && ((x_inst[31:0] == 32'h0180000b)  //sync
                       || (x_inst[31:0] == 32'h0190000b)  //sync.s
                       || ...);

// Type[1]：CSR 及特权跳转类（sret/mret/wfi/csr*）
assign x_fence_type[1] = (x_inst[31:0] == 32'h10200073)  //sret
                      || ...
                      || ({x_inst[14:12],x_inst[6:0]} == 10'b001_1110011); //csrrw...

// Type[2]：fence.i / sfence.vma（标准 RISC-V 屏障）
assign x_fence_type[2] = ({x_inst[14:12],x_inst[6:0]} == 10'b001_0001111) //fence.i
                      || ({x_inst[31:25],x_inst[14:0]}
                         == 22'b0001001_000000001110011) //sfence.vma
                      || hfence_inst;                    //hfence（实现为0）
```

**注意**：三个类型是互斥的独热码（one-hot），标准 `fence`（0x0ff0000f）实际上**不单独**对应 type[0]/[1]/[2] 中的任何一位——它在 id_fence 中被重新识别为 `fence_type[2]` 分支下的 `fence_inst0_fence_fencei == 0` 情形处理（通过排除 fencei 来区分 fence 与 fence.i，见第 8.2 节）。

### 4.2 独热码含义表

| `dp_fence_id_fence_type[2:0]` | 类型 | 代表指令 |
|-------------------------------|------|----------|
| `3'b001`（bit0） | sync 类 | sync / sync.s / sync.i / dcache.* |
| `3'b010`（bit1） | CSR/特权类 | sret / mret / wfi / csrrw / csrrs … |
| `3'b100`（bit2） | fence/fence.i/sfence.vma | fence、fence.i、sfence.vma |

> 为什么这样分类？
> - sync 类（bit0）：T-Head 自有语义，只需派发一条 sync 微操作到 LSU。
> - CSR 类（bit1）：需要进入 SPECIAL 执行单元（cp0 单元），且 wfi 有特殊的 fence_idle 语义。
> - fence.i/sfence.vma（bit2）：需要两条微操作（fence barrier + sync.is），且需要携带 rs1/rs2 地址参数。

---

## 5. 时钟门控

```verilog
// 行 236-247
assign fence_clk_en = fence_sm_start
                      || (fence_cur_state[2:0] != IDLE);

gated_clk_cell  x_fence_gated_clk (
  .clk_in             (forever_cpuclk    ),
  .clk_out            (fence_clk         ),
  .global_en          (cp0_yy_clk_en     ),
  .local_en           (fence_clk_en      ),
  .module_en          (cp0_idu_icg_en    ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
```

**为什么这么做**：`fence_clk` 是 `fence_cur_state` 状态寄存器的时钟。当没有屏障指令（状态为 IDLE 且 `fence_sm_start == 0`）时，关闭时钟门控，节约动态功耗。

`fence_clk_en` 的两个条件：
- `fence_sm_start`：屏障指令刚进入 ID 阶段，FSM 即将离开 IDLE，需要在当前周期打开时钟。
- `fence_cur_state != IDLE`：FSM 正在运行，需要持续有时钟。

---

## 6. 流水线空判定（fence_pipeline_empty）

```verilog
// 行 261-265
assign fence_pipeline_empty   = ctrl_fence_ir_pipe_empty
                                && ctrl_fence_is_pipe_empty
                                && rtu_idu_rob_empty
                                && !iu_idu_div_busy
                                && rtu_idu_pst_empty;
```

这是 fence 机制最核心的条件之一：**"后端流水线已经全部排空"**。

| 信号 | 来源模块 | 含义 | 为什么需要它 |
|------|----------|------|--------------|
| `ctrl_fence_ir_pipe_empty` | ir_ctrl：`!ir_inst0_vld` | IR（寄存器读取）级没有指令 | 确保没有指令卡在 IR 级等待寄存器 |
| `ctrl_fence_is_pipe_empty` | is_ctrl：`!is_inst0_vld` | IS（发射队列）级没有指令 | 确保发射队列中没有未发射的指令 |
| `rtu_idu_rob_empty` | RTU ROB：`rob_empty && retire_rob_retire_empty` | 重排序缓冲区完全为空 | 所有已派发的指令都已退休 |
| `!iu_idu_div_busy` | IU 除法单元 | 除法器不忙 | 除法器是非流水化的，ROB 退休了不代表除法完成 |
| `rtu_idu_pst_empty` | RTU PST：`pst_retired_reg_wb` | 物理寄存器状态表写回完毕 | 确保所有寄存器写回动作都完成，消除写回延迟的隐患 |

**体系结构原理**：只有当 IR、IS、ROB、PST 全部为空且除法器不忙，才能确保屏障之前的所有指令已经完成了包括内存写入在内的全部副作用。此后向 LSU 派发 barrier 微操作，才能保证严格的 before-after 顺序关系。

---

## 7. fence 状态机（核心）

### 7.1 状态定义

```verilog
// 行 227-231
parameter IDLE        = 3'b000;  // 空闲，无屏障指令
parameter WAIT_ISSUE  = 3'b001;  // 屏障已锁存，等待后端排空
parameter ISSUE       = 3'b010;  // 派发微操作
parameter WAIT_CMPLT  = 3'b011;  // 等待微操作完成（再次排空）
parameter POP_INST    = 3'b100;  // 弹出 ID 级屏障指令，恢复流水线
```

### 7.2 状态转移逻辑

```verilog
// 行 280-289（状态寄存器）
always @(posedge fence_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    fence_cur_state[2:0] <= IDLE;
  else if(rtu_idu_flush_fe)     // 异常/中断冲刷
    fence_cur_state[2:0] <= IDLE;
  else if(iu_yy_xx_cancel)      // 分支预测取消
    fence_cur_state[2:0] <= IDLE;
  else
    fence_cur_state[2:0] <= fence_next_state[2:0];
end
```

```verilog
// 行 293-316（次态逻辑）
always @(...)
begin
  case(fence_cur_state[2:0])
  IDLE       : if(fence_sm_start)
                 fence_next_state = WAIT_ISSUE;   // 屏障来了
               else
                 fence_next_state = IDLE;
  WAIT_ISSUE : if(fence_pipedown)
                 fence_next_state = ISSUE;         // 管线已空，派发
               else
                 fence_next_state = WAIT_ISSUE;    // 继续等
  ISSUE      :   fence_next_state = WAIT_CMPLT;   // 单周期派发
  WAIT_CMPLT : if(fence_pipeline_empty)
                 fence_next_state = POP_INST;      // 微操作完成
               else
                 fence_next_state = WAIT_CMPLT;    // 继续等
  POP_INST   :   fence_next_state = IDLE;          // 完成，恢复
  default    :   fence_next_state = IDLE;
  endcase
end
```

### 7.3 状态机图

```
                    复位 / rtu_idu_flush_fe / iu_yy_xx_cancel
                                    │
                                    ▼
                    ┌───────────────────────────────────┐
                    │              IDLE                  │
                    │         (3'b000)                   │
                    └───────────────┬───────────────────┘
                                    │ fence_sm_start
                                    │ (inst_vld && !stall)
                                    ▼
                    ┌───────────────────────────────────┐
                    │           WAIT_ISSUE               │◄──┐
                    │  (3'b001) 等待后端管线清空        │   │ !fence_pipedown
                    └───────────────┬───────────────────┘   │
                                    │ fence_pipedown         │
                                    │ (pipeline_empty)  ─────┘
                                    ▼
                    ┌───────────────────────────────────┐
                    │             ISSUE                  │
                    │  (3'b010) 派发微操作（1 周期）    │
                    └───────────────┬───────────────────┘
                                    │ 无条件（单周期）
                                    ▼
                    ┌───────────────────────────────────┐
                    │           WAIT_CMPLT               │◄──┐
                    │  (3'b011) 等待微操作执行完成      │   │ !pipeline_empty
                    └───────────────┬───────────────────┘   │
                                    │ fence_pipeline_empty ──┘
                                    ▼
                    ┌───────────────────────────────────┐
                    │            POP_INST                │
                    │  (3'b100) 弹出 fence，恢复流水    │
                    └───────────────┬───────────────────┘
                                    │ 无条件（单周期）
                                    ▼
                                  IDLE
```

### 7.4 各状态的详细语义

**IDLE → WAIT_ISSUE**

触发条件：`fence_sm_start = ctrl_fence_id_inst_vld && !ctrl_fence_id_stall`

即：ID 阶段 inst0 是一条有效的 fence 类指令，且当前周期没有通用 stall（下游不反压）。

进入 WAIT_ISSUE 后，`fence_ctrl_id_stall` 拉高，阻止 ID 阶段的 fence 指令向下流动，同时阻止后续指令进入 ID 阶段。这是"屏障之后的指令不得越过屏障"的保证。

**WAIT_ISSUE：等待管线排空**

停在此状态，直到 `fence_pipeline_empty` 为真。此时：
- 屏障指令锁存在 ID 寄存器中不动（stall）
- 屏障之前的所有指令逐渐在 IR、IS 中向前推进，进入 EXU/LSU 执行，退休，最终 ROB/PST 清空

等待时长视当时管线中已有多少未完成指令而定，可能 1 周期也可能数十周期。

**ISSUE：派发微操作（单周期）**

仅持续一个周期。在此周期：
- `fence_ctrl_inst0_vld` 拉高：通知 id_ctrl，inst0（屏障微操作）可以 pipedown
- 对于 type[2] 类屏障：`fence_ctrl_inst1_vld` 和 `fence_ctrl_inst2_vld` 也拉高，三条微操作同时派发

**为什么需要 ISSUE 只占一个周期**？因为派发是一次性的"推入"动作，微操作进入 IR→IS→RF→EXU 之后，ISSUE 状态本身的任务就结束了，后续跟踪执行完成是 WAIT_CMPLT 的职责。

**WAIT_CMPLT：等待微操作完成**

与 WAIT_ISSUE 使用相同的 `fence_pipeline_empty` 判断，但语义不同：此时等待的是刚刚派发出去的 barrier 微操作本身执行完成并退休。

**为什么还需要二次 pipeline_empty**？barrier 微操作进入 LSU 后，需要实际发出 fence 操作到互联网络/总线。只有当 LSU 执行完毕，ROB 退休，PST 写回，才能确认屏障已经生效。

**POP_INST：恢复流水线（单周期）**

在此周期：
- `fence_ctrl_id_stall` 变为低（因为 `fence_cur_state[2]` 为高，见第 10 节）
- ID 阶段的 fence 指令被弹出（不再有效）
- `idu_hpcp_fence_sync_vld` 脉冲（性能计数）

次个周期回到 IDLE，流水线恢复正常取指/译码。

---

## 8. 各类屏障的指令包展开

屏障指令到达 ISSUE 状态时，需要被转化为后端能理解的内部微操作格式。`id_fence` 根据 `fence_type` 为三种类型准备不同的微操作包。

### 8.1 Type[0]：sync 类

```verilog
// 行 347-356
always @( dp_fence_id_inst[31:0])
begin
  fence_inst0_sync_data[IR_WIDTH-1:0]                = {IR_WIDTH{1'b0}};
  fence_inst0_sync_data[IR_OPCODE:IR_OPCODE-31]      = dp_fence_id_inst[31:0]; // 原始编码透传
  fence_inst0_sync_data[IR_INST_TYPE:IR_INST_TYPE-9] = LSU;   // 发往 LSU
  fence_inst0_sync_data[IR_LENGTH]                   = 1'b1;  // 32位指令
end
```

**特点**：只派发一条微操作（inst0），原始指令编码透传给 LSU，由 LSU 自行识别 sync 类型并执行对应的缓存一致性操作。不修改任何寄存器（无 dst/src），类型设为 `LSU`（10'b0000010000）。

### 8.2 Type[2]：fence / fence.i / sfence.vma

Type[2] 展开为**三条**微操作（inst0 + inst1 + inst2），这是最复杂的情况。

#### 8.2.1 区分 fence.i 与 fence/sfence.vma

```verilog
// 行 425-429
assign fence_inst0_fence_fencei      = (dp_fence_id_inst[6:0] == 7'b0001111); // opcode=0x0f
assign fence_inst0_fence_sfence_asid = (dp_fence_id_inst[24:20] != 5'd0)
                                       && !fence_inst0_fence_fencei;
assign fence_inst0_fence_sfence_va   = (dp_fence_id_inst[19:15] != 5'd0)
                                       && !fence_inst0_fence_fencei;
```

- `fence_inst0_fence_fencei`：opcode=0001111 即 fence/fence.i 编码空间。
  - fence.i 的 funct3=001（已在 type 识别时区分），此处 opcode 一致，用于排除 sfence.vma（opcode=1110011）。
- `fence_inst0_fence_sfence_asid`：sfence.vma 且 rs2（ASID）非零，说明要按 ASID 精细刷新。
- `fence_inst0_fence_sfence_va`：sfence.vma 且 rs1（VA）非零，说明要按特定地址刷新。

#### 8.2.2 inst0：barrier 操作

```verilog
// 行 410-423
assign fence_inst0_bar_opcode[31:0] = 32'h0ff0000f; //fence（全屏障规范化编码）

always @( fence_inst0_bar_opcode[31:0])
begin
  fence_inst0_fence_data[IR_OPCODE:IR_OPCODE-31]      = fence_inst0_bar_opcode[31:0];
  fence_inst0_fence_data[IR_INST_TYPE:IR_INST_TYPE-9] = LSU;
  fence_inst0_fence_data[IR_LENGTH]                   = 1'b1;
  fence_inst0_fence_data[IR_SPLIT]                    = 1'b1;  // 标记为 split 指令序列头
end
```

**为什么 OPCODE 规范化为 0xff0000f**：无论原始 fence 的 pred/succ 字段是什么，C910 统一发出全屏障。这是保守但正确的实现——芯片级实现选择不对 pred/succ 做优化，避免遗漏任何依赖。

**IR_SPLIT=1**：标识这是一个 split 指令组的一部分，通知后端三条微操作是关联的，用于正确追踪完成。

#### 8.2.3 inst1：sfence.vma 或 fence.i 的 TLB/cache 操作

```verilog
// 行 432-449
always @(...)
begin
  fence_inst1_fence_data[IR_OPCODE:IR_OPCODE-31]      = dp_fence_id_inst[31:0]; // 原始编码（含rs1/rs2）
  fence_inst1_fence_data[IR_INST_TYPE:IR_INST_TYPE-9] = fence_inst0_fence_sfence_asid
                                                        ? LSU_P5 : LSU;
  fence_inst1_fence_data[IR_SRC0_VLD]                 = fence_inst0_fence_sfence_va;
  fence_inst1_fence_data[IR_SRC0_REG:IR_SRC0_REG-5]   = {1'b0, dp_fence_id_inst[19:15]}; // rs1=VA
  fence_inst1_fence_data[IR_SRC1_VLD]                 = fence_inst0_fence_sfence_asid;
  fence_inst1_fence_data[IR_SRC1_REG:IR_SRC1_REG-5]   = {1'b0, dp_fence_id_inst[24:20]}; // rs2=ASID
  fence_inst1_fence_data[IR_LENGTH]                   = 1'b1;
  fence_inst1_fence_data[IR_SPLIT]                    = 1'b1;
end
```

**关键点**：
- 当 `sfence_asid` 为真（rs2≠0），inst1 发往 `LSU_P5`（10'b0000110000）管道，这是一条专用的 TLB ASID 刷新管道。
- 当 `sfence_asid` 为假时，发往普通 `LSU`（10'b0000010000）。
- `IR_SRC0_VLD/IR_SRC1_VLD` 控制是否读取 rs1/rs2 寄存器的值，只有当相应字段非零时才需要读。这样 LSU/TLB 模块能从寄存器文件拿到实际的 VA 和 ASID 值进行精确刷新。

#### 8.2.4 inst2：sync.is（I-Cache 同步）

```verilog
// 行 358
assign fence_inst2_sync_opcode[31:0] = 32'h01b0000b; // sync.is

always @( fence_inst2_sync_opcode[31:0])
begin
  fence_inst2_sync_data[IR_OPCODE:IR_OPCODE-31]      = fence_inst2_sync_opcode[31:0];
  fence_inst2_sync_data[IR_INST_TYPE:IR_INST_TYPE-9] = LSU;
  fence_inst2_sync_data[IR_LENGTH]                   = 1'b1;
end
```

**为什么需要 inst2 = sync.is**：fence.i 和 sfence.vma 都需要让指令缓存中已有的旧内容失效，`sync.is`（sync + I-cache invalidation）正是实现 I-Cache 同步的内部操作。这条微操作在 inst1 的 fence/sfence 操作完成之后执行，确保后续取指拿到最新内容。

### 8.3 Type[1]：CSR/特权类

```verilog
// 行 375-405
assign fence_inst0_cp0_csrr = ({dp_fence_id_inst[14:12], dp_fence_id_inst[6:0]}
                               == 10'b001_1110011)  // csrrw
                           || ... // csrrs, csrrc

assign fence_inst0_cp0_csri = ({dp_fence_id_inst[14:12], dp_fence_id_inst[6:0]}
                               == 10'b101_1110011)  // csrwi
                           || ... // csrsi, csrci

always @(...)
begin
  fence_inst0_cp0_data[IR_OPCODE:IR_OPCODE-31]      = dp_fence_id_inst[31:0];
  fence_inst0_cp0_data[IR_INST_TYPE:IR_INST_TYPE-9] = SPECIAL;  // 发往特权单元
  fence_inst0_cp0_data[IR_SRC0_VLD]                 = fence_inst0_cp0_csrr;  // csrrw/s/c 需读 rs1
  fence_inst0_cp0_data[IR_SRC0_REG:IR_SRC0_REG-5]   = {1'b0, dp_fence_id_inst[19:15]}; // rs1
  fence_inst0_cp0_data[IR_DST_VLD]                  = fence_inst0_cp0_csrr || fence_inst0_cp0_csri;
  fence_inst0_cp0_data[IR_DST_REG:IR_DST_REG-5]     = {1'b0, dp_fence_id_inst[11:7]};  // rd
  fence_inst0_cp0_data[IR_LENGTH]                   = 1'b1;
end
```

**特点**：
- 类型设为 `SPECIAL`（10'b1000000000），对应 CP0/CSR 执行单元。
- 对寄存器操作数（csrrw 需要 rs1，csrwi 不需要 rs1）做精细控制。
- 有写目标寄存器（rd）的情况下设 `IR_DST_VLD`。
- **只有 inst0**，不展开 inst1/inst2。

### 8.4 三种类型微操作展开对比

| fence_type | inst0 内容 | inst1 内容 | inst2 内容 | inst 数量 |
|------------|-----------|-----------|-----------|-----------|
| 3'b001（sync 类） | sync 原始编码，LSU | — | — | 1 |
| 3'b010（CSR 类） | CSR/sret/mret，SPECIAL，含rd/rs1 | — | — | 1 |
| 3'b100（fence/fence.i/sfence.vma） | 0xff0000f，LSU，SPLIT | 原始编码，LSU/LSU_P5，SPLIT，含rs1/rs2 | sync.is，LSU | 3 |

---

## 9. IR 数据通路打包

三条微操作（inst0/1/2）组装好操作码、类型、源/目标寄存器字段后，还需要填入一些来自 ID 阶段的元数据字段，才能形成完整的 IR 格式（178 位）数据包。

```verilog
// 行 480-503（inst0 打包，inst1/2 类似）
always @(...)
begin
  fence_dp_inst0_data = fence_inst0_data;  // 基础字段已填
  // 补充元数据：
  fence_dp_inst0_data[IR_DST_X0]            = (fence_inst0_data[IR_DST_REG:IR_DST_REG-5] == 6'd0);
  fence_dp_inst0_data[IR_BKPTB_INST]        = dp_fence_id_bkptb_inst;
  fence_dp_inst0_data[IR_BKPTA_INST]        = dp_fence_id_bkpta_inst;
  fence_dp_inst0_data[IR_VLMUL:IR_VLMUL-1]  = dp_fence_id_vlmul[1:0];
  fence_dp_inst0_data[IR_VSEW:IR_VSEW-2]    = dp_fence_id_vsew[2:0];
  fence_dp_inst0_data[IR_VL:IR_VL-7]        = dp_fence_id_vl[7:0];
  fence_dp_inst0_data[IR_VL_PRED]           = dp_fence_id_vl_pred;
  fence_dp_inst0_data[IR_PC:IR_PC-14]       = dp_fence_id_pc[14:0];
end
```

### 9.1 IR 数据包关键字段索引

| 字段 | 位 | 含义 |
|------|----|------|
| `IR_OPCODE` [31:0] | 31:0 | 原始或规范化 32 位指令编码 |
| `IR_INST_TYPE` [9:0] | 115:106 | 执行单元类型（ALU/LSU/SPECIAL 等） |
| `IR_SRC0_VLD`, `IR_SRC0_REG` [5:0] | 32+7 bit | 源操作数 0 有效及寄存器号 |
| `IR_SRC1_VLD`, `IR_SRC1_REG` [5:0] | 39+7 bit | 源操作数 1 |
| `IR_DST_VLD`, `IR_DST_REG` [5:0] | 47+7 bit | 目标寄存器 |
| `IR_DST_X0` | 137 | 目标是 x0 寄存器（写入无效） |
| `IR_LENGTH` | 118 | 1=32 位指令，0=16 位（C 扩展） |
| `IR_SPLIT` | 116 | 属于 split 指令组 |
| `IR_PC` [14:0] | 167:153 | PC 低 15 位 |
| `IR_VL` [7:0] | 176:169 | 向量长度 |
| `IR_VL_PRED` | 177 | 向量断言 |
| `IR_BKPTA_INST`, `IR_BKPTB_INST` | 128, 129 | 断点命中标志 |

**为什么需要 VL/VSEW/VLMUL 字段**：即使是 fence 类指令，IR 数据通路是统一的 178 位格式，向量状态字段在非向量指令中虽不使用，但保留携带是为了 hazard 检测的完整性（后端 issue 队列需要一致的格式处理）。

---

## 10. 对外控制信号

### 10.1 fence_ctrl_id_stall（ID 级 stall 请求）

```verilog
// 行 321-322
assign fence_ctrl_id_stall = ctrl_fence_id_inst_vld
                             && !fence_cur_state[2]; // POP_INST 时 bit2=1
```

逻辑解析：
- 当 ID 阶段有 fence 指令（`ctrl_fence_id_inst_vld=1`）时开始 stall
- **只有当 `fence_cur_state[2]=1` 时才释放 stall**
- 状态机中 `fence_cur_state[2]` 仅在 `POP_INST`（3'b100）时为 1
- 因此：从 IDLE→WAIT_ISSUE 开始，stall 一直有效，直到 POP_INST 状态才松开

这是一个"全程 stall"设计：屏障指令在 ID 级锁定，后续指令无法进入，直到屏障完全处理完毕。

### 10.2 fence_ctrl_inst{0,1,2}_vld（微操作派发有效）

```verilog
// 行 324-330
assign fence_ctrl_inst0_vld = (fence_cur_state[2:0] == ISSUE);

assign fence_ctrl_inst1_vld = (fence_cur_state[2:0] == ISSUE)
                              && dp_fence_id_fence_type[2]; // 仅 fence/fence.i/sfence.vma

assign fence_ctrl_inst2_vld = (fence_cur_state[2:0] == ISSUE)
                              && dp_fence_id_fence_type[2]; // 同上
```

- inst0 对所有 fence 类型都派发
- inst1、inst2 只对 `fence_type[2]` 派发（因为其他类型只有 1 条微操作）

### 10.3 idu_rtu_fence_idle（fence 空闲状态）

```verilog
// 行 334-337
assign idu_rtu_fence_idle = (fence_cur_state[2:0] == IDLE)
                         || (fence_cur_state[2:0] != IDLE)
                            && dp_fence_id_fence_type[1]
                            && !(dp_fence_id_inst[31:0] == 32'h10500073); //非 wfi
```

**两种情况下 fence_idle 为真**：
1. FSM 处于 IDLE（最简单情况）
2. FSM 不在 IDLE，但当前是 CSR 类（type[1]）且**不是 wfi**

**为什么 wfi 不算 idle**：wfi（Wait For Interrupt，0x10500073）是一条等待中断的指令，处理器进入低功耗等待状态。RTU 在判断是否可以无限期等待退休（`rtu_cpu_no_retire`）时，需要知道 IDU 没有在处理 wfi——否则处理器应该等待中断而不是主动退休。其他 CSR 类指令在 fence 处理期间虽然流水线 stall，但 RTU 仍可以照常退休已有指令，所以这些情况都标记为 idle。

### 10.4 idu_hpcp_fence_sync_vld（性能计数脉冲）

```verilog
// 行 339-341
assign idu_hpcp_fence_sync_vld = (fence_cur_state[2:0] == POP_INST)
                                 && (dp_fence_id_fence_type[0]
                                  || dp_fence_id_fence_type[2]);
```

在 POP_INST 状态（屏障完成的最后一拍），对 type[0]（sync 类）和 type[2]（fence/fence.i/sfence.vma）产生一个单周期脉冲，送给硬件性能计数器（HPCP），用于统计屏障指令完成次数。type[1]（CSR 类）不计入，因为 CSR 操作不归为"内存同步屏障"范畴。

### 10.5 idu_had_pipeline_empty（调试流水线空标志）

```verilog
// 行 267
assign idu_had_pipeline_empty = fence_pipeline_empty;
```

直接等于 `fence_pipeline_empty`，送给 HAD（Hardware-Assisted Debug）调试模块。HAD 用此信号判断 CPU 是否处于空闲状态：

```verilog
// ct_had_regs.v（节选）
assign cpu_idle = idu_had_pipeline_empty && ...;
```

在调试暂停（halt）时，等待此信号为真后再进入调试状态，确保所有内存操作都已提交。

---

## 11. 与 RTU/LSU/HAD 的交互

### 11.1 信号交互总览

```
                ┌─────────────────────────────────────────┐
                │           ct_idu_id_fence                │
                │                                          │
                │  ◄── rtu_idu_rob_empty (ROB 空)         │
                │  ◄── rtu_idu_pst_empty (PST 写回完毕)   │
                │  ◄── rtu_idu_flush_fe  (前端冲刷)       │
                │                                          │
                │  ──► idu_rtu_fence_idle (fence 空闲)    │
                │                                          │
                │  ◄── iu_idu_div_busy (除法器忙)         │
                │  ◄── iu_yy_xx_cancel (分支取消)         │
                │                                          │
                │  ──► idu_had_pipeline_empty (调试)      │
                │  ──► idu_hpcp_fence_sync_vld (性能计数) │
                │                                          │
                │  ──► fence_dp_inst{0,1,2}_data → LSU/CP0│
                └─────────────────────────────────────────┘
```

### 11.2 RTU 的 ROB 与 PST

**rtu_idu_rob_empty** 来自 `ct_rtu_rob.v`：
```verilog
assign rtu_idu_rob_empty = rob_empty && retire_rob_retire_empty;
```
两个条件：ROB 本身为空，且退休流水内没有正在退休的条目。

**rtu_idu_pst_empty** 来自 `ct_rtu_pst_preg.v`：
```verilog
assign rtu_idu_pst_empty = pst_retired_reg_wb;
```
PST（Physical register Status Table）跟踪每个物理寄存器是否已经完成写回。`pst_retired_reg_wb` 为真时表示所有已退休指令的寄存器写回均已完成，不存在"退休但未写回"的情况。

**为什么两个都需要**：ROB 退休意味着指令按程序顺序提交，PST 写回意味着寄存器文件中的值确实已更新。对于 fence 的正确性，需要两者都完成，尤其对于后续可能依赖前序结果的 barrier 操作。

### 11.3 RTU 的 flush_fe

```verilog
// ct_rtu_retire.v
assign rtu_idu_flush_fe = retire_flush_fe;
```

当退休阶段检测到异常或中断需要冲刷前端（fetch + decode 级）时，`rtu_idu_flush_fe` 拉高一个周期，fence FSM 立即复位到 IDLE。这确保了异常/中断的处理不受正在执行的 fence 序列干扰——旧的 fence 序列被丢弃，处理器进入异常处理流程。

### 11.4 IU 的 div_busy 与 cancel

**iu_idu_div_busy**：整数除法是不可中断的长周期操作，在 ROB 中可能已经退休但除法器仍在运行（C910 的除法指令设计允许非阻塞分派），因此需要额外等待除法完成。

**iu_yy_xx_cancel**：当分支预测错误发生，IU 广播取消信号，所有正在飞行的指令被撤销，fence FSM 同样必须复位。这防止了一种危险情况：基于错误预测路径上的 fence 指令影响了真实执行路径的内存顺序。

### 11.5 微操作到 LSU/CP0 的路径

```
id_fence ──► fence_dp_inst{0,1,2}_data
              │
              ▼ (经 id_dp → id_ctrl → IR 流水级)
          IR 数据通路
              │
              ▼ (经 is_ctrl → IS 发射队列)
      LSIQ（Load/Store Issue Queue）  ← LSU 类微操作
      或
      AIQ（ALU/Integer Issue Queue）   ← SPECIAL 类微操作（CP0 接收 CSR）
```

在 ISSUE 状态的那一拍，`fence_ctrl_inst{0,1,2}_vld` 脉冲通知 `id_ctrl`，后者允许 fence 相关的 pipedown，将 178 位 IR 数据包推入 IR 级寄存器。后续各级正常流水，最终由 LSU 执行 barrier/sync/sfence 操作，或由 CP0 执行 CSR 读写。

---

## 12. fence 完成后的流水线恢复

### 12.1 POP_INST 状态的关键动作

POP_INST 持续一个周期，在此周期内：

1. `fence_ctrl_id_stall` 变为低（`fence_cur_state[2]=1`，stall 条件不满足）
2. ID 阶段 fence 指令被 id_ctrl 弹出（标记为已处理）
3. `idu_hpcp_fence_sync_vld` 脉冲（若为 type[0]/[2]）
4. 下一拍 FSM 回到 IDLE

### 12.2 流水线恢复时序

```
周期：    T      T+1    T+2    T+3    ...  Tn     Tn+1   Tn+2  Tn+3  Tn+4
状态：   IDLE  WAIT_ISS ...  WAIT_ISS  ISSUE  WAIT_CMPL  ...  POP   IDLE
stall：   0     1      1      1         1      1          1     0     0
inst_vld: 1     1      1      1         1      1          1     1     0（fence 已出）
后续inst: 停在IF/ID               不能进入ID              可以进入ID
```

POP_INST 的下一拍（Tn+4），stall 释放，流水线上游（IFU）可以推送 fence 之后的指令进入 ID 阶段，处理器恢复正常工作。

### 12.3 异常/中断打断 fence 的处理

若 fence 处理过程中（任意状态）发生异常或中断：

1. RTU 生成 `rtu_idu_flush_fe`
2. fence FSM 在下一周期复位到 IDLE
3. `fence_ctrl_id_stall` 撤销
4. ID 阶段 fence 指令随前端 flush 一起清除
5. 处理器跳转到异常处理入口

fence 派发出去的微操作（若已进入后端）由 RTU 的 rob_flush 机制处理，这部分不在 `id_fence` 模块范围内。

---

## 13. 全模块信号流综合视图

```
【ID 阶段】
  IFU → [IF/ID 寄存器] → id_decd_special → fence_type[2:0]
                        ↓
                    id_dp → dp_fence_id_{inst, pc, fence_type, vl...}
                        ↓
              ┌─────────────────────────────────────────────────────┐
              │                ct_idu_id_fence                      │
              │                                                      │
              │  ┌──────────────────────────────────────┐           │
              │  │              fence FSM                │           │
              │  │  IDLE → WAIT_ISSUE → ISSUE →         │           │
              │  │  WAIT_CMPLT → POP_INST → IDLE        │           │
              │  └──────────────────────────────────────┘           │
              │          ▲                   ▲                      │
              │   fence_sm_start       fence_pipeline_empty         │
              │   (inst_vld &&        (ir_empty && is_empty &&      │
              │    !id_stall)          rob_empty && pst_empty &&    │
              │                        !div_busy)                   │
              │                                                      │
              │  微操作构建：                                        │
              │  type[0] → inst0_sync (LSU)                         │
              │  type[1] → inst0_cp0  (SPECIAL, rd/rs1)             │
              │  type[2] → inst0_fence(LSU, SPLIT)                  │
              │           +inst1_fence(LSU/LSU_P5, SPLIT, rs1/rs2)  │
              │           +inst2_sync  (LSU, sync.is)               │
              │                                                      │
              │  IR 打包 → fence_dp_inst{0,1,2}_data[177:0]         │
              └──────────────────────────────────┬──────────────────┘
                                                 │
              fence_ctrl_id_stall ──► id_ctrl    │
              fence_ctrl_inst{0,1,2}_vld ──►     │
                                                 ▼
                                        id_dp → [IR 流水级]
                                                 ↓
                                        [IS 发射队列 LSIQ/AIQ]
                                                 ↓
                                        LSU（barrier/sync/sfence）
                                        或 CP0（CSR/sret/mret）
                                                 ↓
                                        [ROB 退休] ──► rtu_idu_rob_empty
                                        [PST 写回] ──► rtu_idu_pst_empty
                                                 │
                                                 ▼（反馈回 fence_pipeline_empty）
              idu_had_pipeline_empty ──► HAD（调试 CPU 空闲判断）
              idu_rtu_fence_idle ──► RTU rob_rt（退休限速）
              idu_hpcp_fence_sync_vld ──► HPCP（性能计数）
```

---

## 附录：关键参数速查

### IR 数据包字段参数

| 参数名 | bit 位置 | 说明 |
|--------|---------|------|
| `IR_VL_PRED` | 177 | 向量断言有效 |
| `IR_VL` | 176:169 | 向量长度（8位） |
| `IR_PC` | 167:153 | PC 低 15 位 |
| `IR_VSEW` | 152:150 | 向量元素宽度 |
| `IR_VLMUL` | 149:148 | 向量寄存器组长 |
| `IR_NO_SPEC` | 139 | 不可投机执行 |
| `IR_DST_X0` | 137 | 目标为 x0 |
| `IR_BKPTB_INST` | 129 | 断点 B 命中 |
| `IR_BKPTA_INST` | 128 | 断点 A 命中 |
| `IR_EXPT` | 125 | 异常标志 |
| `IR_LENGTH` | 118 | 指令长度（1=32b） |
| `IR_SPLIT` | 116 | split 指令组 |
| `IR_INST_TYPE` | 115:106 | 执行单元类型 |
| `IR_DST_REG` | 53:48 | 目标寄存器号 |
| `IR_DST_VLD` | 47 | 目标寄存器有效 |
| `IR_SRC1_REG` | 45:40 | 源 1 寄存器号 |
| `IR_SRC1_VLD` | 39 | 源 1 有效 |
| `IR_SRC0_REG` | 38:33 | 源 0 寄存器号 |
| `IR_SRC0_VLD` | 32 | 源 0 有效 |
| `IR_OPCODE` | 31:0 | 指令编码 |

### 执行单元类型编码

| 参数 | 编码 | 目标执行单元 |
|------|------|------------|
| `ALU` | 10'b0000000001 | 整数 ALU |
| `BJU` | 10'b0000000010 | 分支跳转 |
| `MULT` | 10'b0000000100 | 乘法器 |
| `DIV` | 10'b0000001000 | 除法器 |
| `LSU` | 10'b0000010000 | 访存单元（pipe4） |
| `LSU_P5` | 10'b0000110000 | 访存单元（pipe5，sfence ASID） |
| `PIPE67` | 10'b0001000000 | 向量/浮点 pipe6+7 |
| `SPECIAL` | 10'b1000000000 | 特权/CSR 单元 |

### fence FSM 状态编码

| 状态 | 编码 | 主要动作 |
|------|------|---------|
| `IDLE` | 3'b000 | 无屏障，正常流水 |
| `WAIT_ISSUE` | 3'b001 | Stall ID，等待后端排空 |
| `ISSUE` | 3'b010 | 派发微操作（1周期） |
| `WAIT_CMPLT` | 3'b011 | 等待微操作完成 |
| `POP_INST` | 3'b100 | 弹出 fence，释放 stall |
