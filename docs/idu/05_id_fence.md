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

屏障指令（fence/fence.i/sfence.vma 等）的体系结构语义需要精确区分：
- **FENCE**：按 `pred/succ` 集合约束本 hart 上指定类别的前序与后继内存或设备 I/O 访问的观察顺序；它不是“等待全系统所有内存访问物理完成”的同义词。
- **FENCE.I**：使本 hart 后续的取指与此前对指令存储区的写入同步，是自修改代码常用的本地指令流同步操作；多 hart 可见性还需要相应的数据同步与跨 hart 协调。
- **SFENCE.VMA**：按 `rs1/rs2` 指定的虚拟地址和 ASID 范围同步当前 hart 的地址翻译状态，并对相关页表更新建立规定的顺序；它不等价于笼统的“所有 TLB 和页表全局完成”。

乱序核不能像顺序核那样简单地"等当前指令完成后再取下一条"，必须有专门的机制：
1. **阻止新指令越过屏障**：在屏障到达 ID 阶段后，立刻 stall 住流水线，不让后续指令进入 IS/RF 阶段。
2. **等待 RTL 定义的本地排空条件成立**：等 IR/IS 流水寄存级为空、ROB/退休通路为空、PST 写回条件成立且除法器不忙。
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
| `iu_yy_xx_cancel` | 1 | IU | IU 产生的取消/重定向信号；误预测是典型来源，但信号名本身不限定唯一原因 |
| `pad_yy_icg_scan_en` | 1 | PAD | 扫描模式时钟强制打开 |
| `rtu_idu_flush_fe` | 1 | RTU retire | 退休阶段触发前端冲刷（异常/中断） |
| `rtu_idu_pst_empty` | 1 | RTU PST | 物理寄存器状态表（写回追踪）为空 |
| `rtu_idu_rob_empty` | 1 | RTU ROB/retire | ROB 项数为零，且 LSU 已提交 store 数据全部有效 |

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
| `idu_hpcp_fence_sync_vld` | 1 | HPCP | POP_INST 状态下 type[0]/type[2] 的完成阶段组合电平 |
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

`fence_clk_en` 是状态机的本地活动请求：状态为 IDLE 且没有 `fence_sm_start` 时，
`local_en=0`；开始事件或非 IDLE 状态使其为 1。最终门控单元还计算
`global_en && (module_en || local_en) || external_en` 并接收扫描使能。未定义
`C910_USE_TSMC28_ICG` 时公开 RTL 直接让 `fence_clk` 跟随主时钟，因此不能把
`fence_clk_en=0` 等同于所有配置下物理停钟。该结构的功耗收益需实现后验证。

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

这是 fence 机制最核心的条件之一：**“本模块观察的排空条件全部成立”**。该名称比“整个后端已经全部排空”更准确，因为其中两个输入只观察 IR/IS 流水寄存级，而不是逐项检查所有发射队列。

| 信号 | 来源模块 | 含义 | 为什么需要它 |
|------|----------|------|--------------|
| `ctrl_fence_ir_pipe_empty` | ir_ctrl：`!ir_inst0_vld` | IR 流水寄存级的 inst0 无效 | 观察 IR 级当前没有有效指令包；不等价于所有后端队列为空 |
| `ctrl_fence_is_pipe_empty` | is_ctrl：`!is_inst0_vld` | IS 派遣流水寄存级的 inst0 无效 | 观察 IS 级当前没有待派遣指令包；不等价于 AIQ/BIQ/LSIQ 等发射队列全部为空 |
| `rtu_idu_rob_empty` | RTU ROB：`rob_empty && retire_rob_retire_empty`；后者在 retire 中等于 `lsu_rtu_all_commit_data_vld` | ROB 项数为零，且已提交 store 数据就绪 | 不仅等待已派发指令退出 ROB，也等待 committed store data 满足退休侧条件 |
| `!iu_idu_div_busy` | IU 除法单元 | 除法器不忙 | 对 ROB/PST 条件之外的长周期执行资源再做显式静止检查 |
| `rtu_idu_pst_empty` | RTU PST：`pst_retired_reg_wb` | 物理寄存器状态表写回完毕 | 确保所有寄存器写回动作都完成，消除写回延迟的隐患 |

**准确边界**：该与式是 fence FSM 采用的**本地推进条件**。它能证明 RTL 所观察的 IR/IS 流水级、ROB/退休通路、PST 写回状态和除法器均达到指定状态；它本身不能证明所有外部总线事务已经取得全系统可见性，也不能替代 LSU、Cache、MMU 和一致性互联对具体 barrier 微操作的实现。体系结构顺序语义由“前置排空条件 + 后续生成并执行的 LSU/特殊微操作 + 各下游模块的完成规则”共同实现。

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

即：ID 阶段 inst0 是一条有效 fence 类指令，并且输入 `ctrl_fence_id_stall` 为 0。这里容易混淆两个方向相反、前缀次序不同的信号：

- 输入 `ctrl_fence_id_stall` 来自 `id_ctrl`，实际连接的是 IR 下游反压 `ctrl_ir_stall`；
- 输出 `fence_ctrl_id_stall` 是本 fence FSM 返回给 `id_ctrl` 的保持请求。

因此 `fence_sm_start` 表示 fence 在一个 **IR 未反压** 的 ID 周期被 FSM 接受启动，并不存在用本模块输出 stall 反过来阻止自身启动的组合环。

进入 WAIT_ISSUE 后，`fence_ctrl_id_stall` 保持为高，使原始 fence 留在 ID，并阻止后续原始指令从该处越过。完整的屏障顺序还依赖后端微操作、LSU/MMU 和退休逻辑；本 stall 解决的是 ID 边界上的前后隔离。

**WAIT_ISSUE：等待管线排空**

停在此状态，直到 `fence_pipeline_empty` 为真。此时：
- 屏障指令锁存在 ID 寄存器中不动（stall）
- 屏障之前已经进入后端的指令继续推进；FSM 等待其所观察的 IR/IS 级、ROB/退休、PST 和除法器条件全部满足

等待时长视当时管线中已有多少未完成指令而定，可能 1 周期也可能数十周期。

**ISSUE：派发微操作（单周期）**

仅持续一个周期。在此周期：
- `fence_ctrl_inst0_vld` 拉高：通知 id_ctrl，inst0（屏障微操作）可以 pipedown
- 对于 type[2] 类屏障：`fence_ctrl_inst1_vld` 和 `fence_ctrl_inst2_vld` 也拉高，三条微操作同时派发

**为什么 ISSUE 结构上只占一个状态周期**？`ISSUE` 的 next-state 无条件指向 `WAIT_CMPLT`，所以在 fence 状态时钟正常推进且没有复位/冲刷覆盖时，它只保持一个 `fence_clk` 周期。该周期通过 valid 向 ID/IR 提交候选微操作；“进入 ISSUE”是内部状态事件，不应直接等同于执行单元已经完成该操作。

**WAIT_CMPLT：等待微操作完成**

与 WAIT_ISSUE 使用同一个 `fence_pipeline_empty` 组合条件，但所处时间位置不同：此时新派发的 barrier/特殊微操作也已经计入后端状态，FSM 等待这些微操作使所观察条件再次回到空闲。该条件主要通过 ROB/退休、PST、IR/IS 级和 div_busy 间接观察完成，而不是接收一个来自总线的逐事务 completion。

**为什么还需要二次 `pipeline_empty`**？第一次排空隔离屏障之前的在途工作；ISSUE 又向后端注入了屏障内部微操作，所以必须等待后端再次达到同一组静止条件，才能释放 ID 中的原始 fence。至于 LSU 是否需要互联请求、Cache/TLB 操作或其他内部确认，取决于具体微操作类型，不能仅由本模块统一推断为“已发总线且全局生效”。

**POP_INST：恢复流水线（单周期）**

在此周期：
- `fence_ctrl_id_stall` 变为低（因为 `fence_cur_state[2]` 为高，见第 10 节）
- ID 阶段的 fence 指令被弹出（不再有效）
- `idu_hpcp_fence_sync_vld` 在符合类型的 POP_INST 状态为高（性能计数观测）

若没有复位或冲刷覆盖，下一次 fence 状态时钟沿把状态更新为 IDLE。上游实际何时写入新 ID 数据，还取决于 ID 时钟、IBUF valid 和其他 stall。

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

**inst2 = `sync.is` 的作用边界**：type[2] 展开中还生成一条内部 `sync.is` 微操作，用于触发实现所需的后续同步/取指侧动作。FENCE.I 与 SFENCE.VMA 的体系结构目标不同，不能都简化为“必须让 I-Cache 旧内容失效”；应结合 pipe4/LSU/MMU 对 inst1 和 inst2 功能码的译码分别判断。三条微操作在同一 ISSUE 状态通过不同 IR 槽下发，其先后效果由内部依赖、队列和执行语义保证，不是本 FSM 在三个不同 ISSUE 周期串行发送。

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

**VL/VSEW/VLMUL 字段为何仍出现**：fence 数据包沿用统一的 178 位 IR 格式，因此这些位置仍被赋值。RTL 能证明的是“统一格式保留并传递字段”；不能据此断言 fence 功能依赖向量 hazard 检测。当前配置还关闭了 RVV 总译码，这些字段对标量 fence 通常只是格式占位或旁带透传。

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

这可以称为“当前 fence 驻留期间的 ID stall”：只要
`ctrl_fence_id_inst_vld=1` 且状态不是 `POP_INST`，本模块就向 ID 请求保持；到
`POP_INST` 时 bit2=1，stall 组合释放，使该 fence 可以从 ID 槽弹出。这里的
“完成”边界是 FSM 已经历 WAIT_CMPLT 并再次观察到本模块定义的
`fence_pipeline_empty`，不是笼统的“所有外部 cache/互联事务已达到全系统可见”。
后者还取决于所发微操作在 LSU/CP0/MMU/Cache 中的具体完成协议。

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

该输出的精确分类是：IDLE 一定为 1；非 IDLE 时，只有 type[1] 且 opcode 不是 WFI 才为 1。它向 RTU 暴露的是设计定义的“fence 不构成非空闲阻塞”分类，而不是本 FSM 状态等于 IDLE 的直接镜像。WFI 被单独排除的更深层低功耗/退休策略需要结合 RTU 和 CP0 使用端分析；仅凭这一等式不应推导“RTU 会主动退休”之类未直接编码的行为。

### 10.4 idu_hpcp_fence_sync_vld（性能计数状态事件）

```verilog
// 行 339-341
assign idu_hpcp_fence_sync_vld = (fence_cur_state[2:0] == POP_INST)
                                 && (dp_fence_id_fence_type[0]
                                  || dp_fence_id_fence_type[2]);
```

该信号是一个**组合电平**：当前状态等于 `POP_INST` 且类型为 type[0] 或 type[2] 时为 1。按正常状态序列，`POP_INST` 的 next-state 无条件回到 IDLE，因此通常表现为一个 `fence_clk` 周期宽的事件；严格说脉宽服从状态寄存器实际停留时间及复位/冲刷行为。它适合作为 HPCP 的 fence/sync 完成阶段事件，但并非外部互联事务的 completion 回应。type[1] 不满足该 RTL 计数条件。

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

在调试控制中，该信号可作为本模块定义的流水线静止条件之一。它复用了 `fence_pipeline_empty`，因此其证明范围仍是前述本地观察项；“所有内存操作均已取得系统级提交/可见性”需要额外的 LSU、Cache 和互联条件，不能由该位单独保证。

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
这里不能按 `retire_rob_retire_empty` 的名字解释成“退休流水没有条目”。当前
`ct_rtu_retire.v` 的有效赋值是：

```verilog
assign retire_rob_retire_empty = lsu_rtu_all_commit_data_vld;
```

因此两个真实条件是：`rob_entry_num==0`，以及 LSU 已提交 store 所需的数据全部
有效。该组合让 fence 不会只因 ROB 已弹空，就忽略仍在等待数据就绪的 committed
store。

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

当 RTU 请求前端冲刷时，`rtu_idu_flush_fe` 在 fence 状态寄存器的同步更新分支中具有清状态作用：在相应 `fence_clk` 有效上升沿后，FSM 变为 IDLE。它不是组合意义上的“信号一变就立即复位”。该输入可能由异常、中断或其他退休重定向原因产生，具体来源应以 RTU 文档和波形为准。

### 11.4 IU 的 div_busy 与 cancel

**`iu_idu_div_busy`**：这是 IU 明确提供的长周期除法资源忙信号。fence 条件将其单独纳入，说明 ROB/PST/流水级空闲判定之外还要确认除法器静止；RTL 在此处并不能证明“除法指令已经退休但单元仍在运行”，因此不作这种生命周期推断。

**`iu_yy_xx_cancel`**：IU 取消/重定向有效时，fence 状态寄存器在相应有效时钟沿回到 IDLE。误预测是典型使用场景，但本模块只消费统一 cancel，不在这里辨别原因；各流水级和队列是否、如何清除由各自的 cancel/flush 逻辑决定，不能由 fence 模块概括为“所有在途指令均被撤销”。

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

在 ISSUE 状态期间，`fence_ctrl_inst{0,1,2}_vld` 作为组合 valid 通知 `id_ctrl` 哪些 178 位包可进入 IR。正常状态推进下 ISSUE 仅持续一拍，所以这些 valid 通常也呈单周期事件；它们表示 ID→IR 的有效提交资格，不表示 LSU/CP0 已执行完成。后续仍需经过 IR、IS、RF 和对应执行单元。

---

## 12. fence 完成后的流水线恢复

### 12.1 POP_INST 状态的关键动作

正常无冲刷、状态时钟持续推进时，POP_INST 持续一个 `fence_clk` 周期。在该状态期间：

1. `fence_ctrl_id_stall` 变为低（`fence_cur_state[2]=1`，stall 条件不满足）
2. ID 阶段 fence 指令被 id_ctrl 弹出（标记为已处理）
3. `idu_hpcp_fence_sync_vld` 组合电平为高（若为 type[0]/[2]）
4. 下一拍 FSM 回到 IDLE

### 12.2 流水线恢复时序

```
周期：    T      T+1    T+2    T+3    ...  Tn     Tn+1   Tn+2  Tn+3  Tn+4
状态：   IDLE  WAIT_ISS ...  WAIT_ISS  ISSUE  WAIT_CMPL  ...  POP   IDLE
stall：   0     1      1      1         1      1          1     0     0
inst_vld: 1     1      1      1         1      1          1     1     0（fence 已出）
后续inst: 停在IF/ID               不能进入ID              可以进入ID
```

`fence_ctrl_id_stall` 在**进入 POP_INST 的该周期**已经因 `fence_cur_state[2]=1` 而释放；在允许 ID 数据更新的有效时钟沿，原始 fence 被消耗，随后 FSM 回到 IDLE。波形分析时应把“状态组合输出变低”和“上游数据在时钟沿真正写入 ID”分开，不笼统称为同一个“下一拍恢复”事件。

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
