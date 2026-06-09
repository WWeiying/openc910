# C910 IFU Loop Buffer (lbuf) 模块详解

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_lbuf.v`（共 6953 行）
>
> 本文档面向希望深入理解 C910 取指前端微架构的读者。建议在阅读本文之前先了解 IFU 整体结构（见 `00_ifu_overview.md`）。

---

## 目录

1. [模块概述与设计动机](#1-模块概述与设计动机)
2. [物理结构](#2-物理结构)
3. [状态机（核心）](#3-状态机核心)
4. [循环体检测——回边识别](#4-循环体检测回边识别)
5. [Entry 填充逻辑（FILL/FRONT_FILL 状态）](#5-entry-填充逻辑fillfrontfill-状态)
6. [BHT 预测集成](#6-bht-预测集成)
7. [循环出口检测（CACHE 状态）](#7-循环出口检测cache-状态)
8. [Entry 读出（ACTIVE 状态）](#8-entry-读出active-状态)
9. [Flush 逻辑](#9-flush-逻辑)
10. [与 IBUF 的协作](#10-与-ibuf-的协作)
11. [限制与退化条件](#11-限制与退化条件)
12. [接口信号汇总](#12-接口信号汇总)

---

## 1. 模块概述与设计动机

### 1.1 什么是 Loop Buffer

**Loop Buffer（lbuf）** 是 C910 IFU 中的一个专用小缓冲区，用于缓存小循环的指令体。当处理器检测到一个**短循环**（循环体适合存入缓冲区）后，它将循环体中所有 half-word（16 位半字）缓存到 lbuf 中，随后在循环执行期间直接从 lbuf 向 IB（Instruction Buffer）级提供指令，**完全绕过 I-Cache 访问**。

```
普通取指路径：
  PC → ICache → IBUF → IB 级 → ID 级

lbuf 激活后的路径：
  lbuf（循环体已缓存）→ IB 级 → ID 级
       ↑
  无 ICache 访问
```

### 1.2 设计动机

| 动机 | 说明 |
|------|------|
| **功耗节省** | I-Cache 每次访问都有静态和动态功耗。对于高频执行的小循环（如内层向量循环），避免重复访问 I-Cache 可显著降低取指功耗 |
| **延迟消除** | I-Cache 命中延迟通常为 1~2 周期；从 lbuf 取指延迟极低（纯组合逻辑读出）|
| **流水线稳定** | 小循环中不存在 I-Cache Miss 的风险，取指流水线可以以稳定的节奏向 ID 发送指令 |
| **向量循环加速** | C910 支持 RVV（RISC-V Vector），向量计算的内层循环体通常很小，lbuf 对其效果显著 |

### 1.3 适合缓存的循环特征

lbuf 对循环有严格约束，只有满足以下所有条件的循环才能被缓存：

1. **循环体足够小**：循环体半字数 ≤ 16（ENTRY_NUM = 16）
2. **单一回边**：只能有一个条件跳转作为循环的回边（backward branch）
3. **最多一个前向分支**：循环体内允许有一个前向跳转（front branch），用于实现 `if-then` 结构
4. **无 PC 相关指令**：不能含有 `auipc` 等依赖 PC 绝对值的指令
5. **无 fence 指令**：不能含有 fence/fence.i 类屏障指令
6. **无其他控制流变化**：不能含有函数调用、间接跳转等（hn_chgflw 为 0）
7. **回边跳转距离有限**：对于 32 位分支指令，偏移绝对值 < 15 半字；对于 16 位分支指令，偏移绝对值 < 16 半字

---

## 2. 物理结构

### 2.1 整体结构图

```
  ┌──────────────────────────────────────────────────────┐
  │                   ct_ifu_lbuf                        │
  │                                                      │
  │  ┌─────────────────────────────────────────────┐    │
  │  │         Loop Buffer Entry Array              │    │
  │  │  Entry[0] Entry[1] ... Entry[15]            │    │
  │  │  (16 项，每项存一个 half-word 及元信息)       │    │
  │  └──────────────────────┬──────────────────────┘    │
  │                         │                            │
  │  ┌──────────────────────┼──────────────────────┐    │
  │  │   Record FIFO        │   State Machine       │    │
  │  │  (2项，记录回边信息)  │   lbuf_cur_state     │    │
  │  │  Entry0 / Entry1    │   6-bit one-hot       │    │
  │  └─────────────────────-┴──────────────────────┘    │
  │                                                      │
  │  ┌─────────────────┐  ┌──────────────────────────┐  │
  │  │  Back Br Buffer │  │  Front Br Buffer          │  │
  │  │ back_entry_*    │  │ front_entry_*             │  │
  │  │ (循环回边信息)   │  │ (循环内前向分支信息)      │  │
  │  └─────────────────┘  └──────────────────────────┘  │
  │                                                      │
  │  ┌──────────────────────────────────────────────┐   │
  │  │         Create Pointer (环形)                 │   │
  │  │   lbuf_create_pointer[15:0]  one-hot         │   │
  │  └──────────────────────────────────────────────┘   │
  │  ┌──────────────────────────────────────────────┐   │
  │  │         Retire Pointer (环形)                 │   │
  │  │   lbuf_retire_pointer[15:0]  one-hot         │   │
  │  └──────────────────────────────────────────────┘   │
  └──────────────────────────────────────────────────────┘
```

### 2.2 Entry 数量和基本参数

```verilog
// ct_ifu_lbuf.v: 1216-1217 行
parameter PC_WIDTH  = 40;   // PC 宽度（含 1 位模式位），实际使用 39 位
parameter ENTRY_NUM = 16;   // Entry 数量
```

lbuf 共有 **16 项 Entry**，每项均由子模块 `ct_ifu_lbuf_entry` 实现，存储一个 half-word（16 位）的指令片段及其元信息。

### 2.3 每个 Entry 存储的字段

每个 `ct_ifu_lbuf_entry` 子模块存储：

| 字段 | 位宽 | 含义 |
|------|------|------|
| `entry_inst_data` | 16 bit | 该 half-word 的指令数据 |
| `entry_vld` | 1 bit | 本 Entry 是否有效 |
| `entry_back_br` | 1 bit | 本 Entry 是循环的回边分支（backward branch）的起始 half-word |
| `entry_front_br` | 1 bit | 本 Entry 是循环内前向分支（front branch）的起始 half-word |
| `entry_32_start` | 1 bit | 本 Entry 是否是 32 位指令的低 half-word（即指令的起始） |
| `entry_fence` | 1 bit | 本 Entry 对应一条 fence 类指令（通常导致退化） |
| `entry_bkpta/b` | 1 bit × 2 | 断点标记 A/B |
| `entry_vsetvli` | 1 bit | 本 Entry 是 vsetvli 指令（向量长度设置） |
| `entry_vl/vlmul/vsew` | 8/2/3 bit | 向量状态：向量长度/倍长系数/元素宽度 |
| `entry_split0_type/split1_type` | 3 bit × 2 | 向量指令分裂类型（用于 IB 级解码辅助） |

### 2.4 front_entry 与 back_entry 的区别

lbuf 为循环内的两类分支各维护一个专用缓冲区：

| 缓冲区 | 寄存器前缀 | 作用 |
|--------|-----------|------|
| **Back Br Buffer** | `back_entry_*` | 存储循环的**回边分支**（backward branch）信息，包括分支指令的 PC、跳转目标 PC（即循环开始 PC）、起始 entry 编号等 |
| **Front Br Buffer** | `front_entry_*` | 存储循环体内的**前向分支**（forward branch / if-then）信息，包括分支 PC、跳转目标、以及该分支在 lbuf 中的位置指针 |

这两个缓冲区都只有 **1 个槽位**（即每次只能记录一个回边和一个前向分支）。

### 2.5 Record FIFO

Record FIFO 是检测"是否值得为某个回边建立 lbuf"的计数机制，共有 **2 个 Entry**（Entry0 和 Entry1），通过一个 `record_fifo_bit` 翻转位来区分"新项"与"旧项"：

```verilog
// ct_ifu_lbuf.v: 1626-1638 行
assign old_entry_filled = (record_fifo_bit)
                        ? record_fifo_entry1_filled
                        : record_fifo_entry0_filled;
// ... new_entry_* 类似，使用 !record_fifo_bit 选择

// 每项存储：
//   record_fifo_entryN_valid    -- 此项是否有效
//   record_fifo_entryN_pc       -- 回边分支的 PC
//   record_fifo_entryN_offset   -- 回边偏移（半字数）
//   record_fifo_entryN_filled   -- 循环体是否已经完整填充过一次
//   record_fifo_entryN_ban      -- 此项是否被禁用（发生退化时）
//   record_fifo_entryN_pred_mode-- 预测模式快照（与 vsetvli pred 配置相关）
```

**Record FIFO 的作用**：在 lbuf 处于 IDLE 状态时，它持续观察从 IB 级来的条件分支信息。当一个具有负偏移（backward）的条件分支指令被取到时：
- 若其 PC 在 Record FIFO 中已经存在且 `filled=1`（上次已成功填充），则直接进入 `CACHE` 状态，利用已有缓存；
- 若其 PC 在 Record FIFO 中已存在但 `filled=0`（尚未填充），则进入 `FILL` 状态开始填充；
- 若其 PC 不在 Record FIFO 中，则写入 Record FIFO 等待下次触发。

---

## 3. 状态机（核心）

### 3.1 状态定义

```verilog
// ct_ifu_lbuf.v: 1222-1228 行
parameter IDLE         = 6'b000000;  // bit 无效，等待回边触发
parameter FILL         = 6'b000001;  // bit[0]，填充循环体到 lbuf
parameter FRONT_BRANCH = 6'b000010;  // bit[1]，记录前向分支信息（中间过渡态，单周期）
parameter CACHE        = 6'b000100;  // bit[2]，循环体填充完毕，等待 IBUF 排空
parameter ACTIVE       = 6'b001000;  // bit[3]，lbuf 激活，向 IB 供指
parameter FRONT_FILL   = 6'b010000;  // bit[4]，填充前向分支的循环体部分
parameter FRONT_CACHE  = 6'b100000;  // bit[5]，前向分支的循环体填充完毕，等待 IBUF 排空
```

采用 **one-hot 编码**，因此可以通过 `lbuf_cur_state[3]` 直接判断是否处于 ACTIVE 状态，非常高效。

### 3.2 完整状态转移图

```
                      ┌─────────────────────────────┐
                      │              IDLE            │
                      │  等待回边分支出现            │
                      └──────────┬──────────────────┘
                                 │
              ┌──────────────────┼──────────────────────────┐
              │                  │                          │
              │ back_br_taken     │ back_br_taken            │ 其他
              │ hit Record FIFO  │ hit Record FIFO          │
              │ unfilled         │ filled                   │
              │ && !ins_inv_on   │ && !ins_inv_on           │
              ▼                  ▼                          ▼
           ┌──────┐          ┌───────┐              保持 IDLE
           │ FILL │          │ CACHE │
           │ 填充  │          │ 等待  │
           └──┬───┘          └───┬───┘
              │                  │
  ┌───────────┼──────┐          │ ibuf_empty && !ins_inv_on
  │           │      │          ▼
  │fill_not   │front │       ┌────────┐
  │_under_rule│_br   │       │ ACTIVE │◄─────────────────────────────┐
  │           │_under│       │ 循环供指│                              │
  ▼           │_rule │       └────┬───┘                              │
IDLE          ▼      │            │                                  │
         ┌───────────┐│      ┌────┴──────────────────────┐          │
         │FRONT_BRANCH││     │                           │          │
         │ 过渡态(1周期)│     │lbuf_pop_not_taken_back_br │front_br  │
         └─────┬─────┘│     │（回边 BHT 预测不跳）         │_body_not_│
               │      │     ▼                           │filled    │
               │      │   IDLE（循环结束，退出 lbuf）     ▼          │
               ▼      │                          ┌────────────┐    │
           ┌──────┐   │                          │ FRONT_FILL │    │
           │ FILL │◄──┘                          │ 填充前向分支│    │
           └──┬───┘                              └─────┬──────┘    │
              │                                        │            │
              │ back_br_hit_lbuf_end                   │front_fill  │
              │ （回边 PC 命中 lbuf 起始）               │_not_under  │
              ▼                                        │_rule       │
           ┌───────┐                           IDLE   ▼            │
           │ CACHE │                              │back_br_hit_lbuf_end
           └───────┘                              ▼                │
               │                          ┌─────────────┐          │
               │ ibuf_empty && !ins_inv_on │ FRONT_CACHE │──────────┘
               └─────────────────────────►└─────────────┘
                                              ibuf_empty
                                              && !ins_inv_on
```

**注意**：所有状态在 `lbuf_flush || bju_mispred || !cp0_ifu_lbuf_en` 时强制回到 IDLE。

### 3.3 关键状态详解

#### IDLE 状态

```verilog
// ct_ifu_lbuf.v: 1296-1303 行
IDLE : begin
  if(back_br_hit_record_fifo_fill && !ins_inv_on)
    lbuf_next_state[5:0] = CACHE;        // 已有填充好的缓存，直接激活
  else if(back_br_hit_record_fifo_unfill && !ins_inv_on)
    lbuf_next_state[5:0] = FILL;         // 需要填充
  else
    lbuf_next_state[5:0] = IDLE;
end
```

IDLE 状态下，lbuf 持续监视从 ibdp（IB Stage Datapath）来的条件分支信息。只要检测到合法的回边分支且触发条件成立，就立刻离开 IDLE。

#### FILL 状态

FILL 状态下，lbuf 同步于正常取指流水线，将 IB 级拿到的 half-word 逐个写入 Entry Array。状态转移：

```verilog
// ct_ifu_lbuf.v: 1304-1313 行
FILL : begin
  if(fill_not_under_rule)
    lbuf_next_state[5:0] = IDLE;         // 遇到不规则情况，放弃
  else if(back_br_hit_lbuf_end)
    lbuf_next_state[5:0] = CACHE;        // 回边命中起始地址，填充完毕
  else if(front_br_under_rule)
    lbuf_next_state[5:0] = FRONT_BRANCH; // 检测到合法前向分支
  else
    lbuf_next_state[5:0] = FILL;
end
```

#### CACHE 状态

CACHE 状态是一个**等待状态**，循环体已完整填入 lbuf，但还需要等待 IBUF 中已有的指令被 ID 级消耗完毕，然后才能切换到 ACTIVE 模式让 lbuf 独占 IB 级的供给。

```verilog
// ct_ifu_lbuf.v: 1314-1319 行
CACHE : begin
  if(ibuf_empty && !ins_inv_on)
    lbuf_next_state[5:0] = ACTIVE;
  else
    lbuf_next_state[5:0] = CACHE;
end
```

此时 lbuf 向 ibctrl 发送 `lbuf_ibctrl_stall = 1`（通过 `lbuf_cur_state[2]`），阻止新指令进入 IBUF。

#### ACTIVE 状态

ACTIVE 是 lbuf 真正"工作"的状态：

```verilog
// ct_ifu_lbuf.v: 1323-1330 行
ACTIVE : begin
  if(front_br_body_not_filled)
    lbuf_next_state[5:0] = FRONT_FILL;  // 需要补充前向分支体
  else if(lbuf_pop_not_taken_back_br)
    lbuf_next_state[5:0] = IDLE;        // BHT 预测回边不跳，循环结束
  else
    lbuf_next_state[5:0] = ACTIVE;      // 继续循环
end
```

在 ACTIVE 状态：
- 每个 retire 周期，lbuf 按 `lbuf_retire_pointer` 从 Entry Array 中读出最多 3 条指令（打包为 inst0/1/2）发给 ibdp。
- `lbuf_cur_pc` 指向当前正在弹出的指令 PC，每弹出一组指令后自动更新。
- 当 retire 指针绕回到回边分支所在 Entry，且 BHT 预测该分支**跳转（taken）**，则 retire 指针跳回循环起始，开始下一轮。
- 当 BHT 预测该分支**不跳（not taken）**，触发 `lbuf_pop_not_taken_back_br`，状态机回到 IDLE，同时向 ibctrl 发出 `lbuf_ibctrl_chgflw_vld` 通知恢复正常取指。

#### FRONT_BRANCH 状态（单周期过渡）

```verilog
// ct_ifu_lbuf.v: 1320-1322 行
FRONT_BRANCH : begin
  lbuf_next_state[5:0] = FILL;  // 无条件返回 FILL
end
```

此状态仅持续一个周期，用于将当前前向分支的信息锁存到 `front_update_pre_*` 寄存器，下一周期 front_entry 即更新，然后回到 FILL 继续填充。

#### FRONT_FILL / FRONT_CACHE 状态

与 FILL/CACHE 对应，专门处理当前向分支体未被填充的情况（例如第一次运行时前向分支走了另一路，需要单独填充）。

### 3.4 状态机寄存器

```verilog
// ct_ifu_lbuf.v: 1267-1277 行
always @(posedge lbuf_sm_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    lbuf_cur_state[5:0] <= IDLE;
  else if(lbuf_flush || bju_mispred)
    lbuf_cur_state[5:0] <= IDLE;
  else if(!cp0_ifu_lbuf_en)
    lbuf_cur_state[5:0] <= IDLE;
  else
    lbuf_cur_state[5:0] <= lbuf_next_state[5:0];
end
```

状态机时钟 `lbuf_sm_clk` 在以下条件下开启（门控时钟节能）：

```verilog
// ct_ifu_lbuf.v: 1260-1261 行
assign lbuf_sm_clk_en = (lbuf_cur_state[5:0] != IDLE) || back_br_taken;
```

即只有当 lbuf 非 IDLE 或者检测到回边跳转时，状态机时钟才开启，平时处于门控关闭状态节省功耗。

---

## 4. 循环体检测——回边识别

### 4.1 回边（Backward Branch）的判断

C910 将所有条件分支的偏移量符号位作为判断方向的依据：

```verilog
// ct_ifu_lbuf.v: 1514-1528 行
// con_br_offset[37] 为 1 表示负偏移（跳向更低地址，即回边）
assign back_br_taken = (|hn_con_br[7:0]) &&
                       con_br_offset[37] &&   // 负偏移 = 向后跳
                       con_br_taken;

assign back_br_check = (|hn_con_br[7:0]) &&
                       con_br_offset[37];

// 回边跳转目标 PC = 当前 PC + 符号扩展偏移
assign back_br_tar_pc[PC_WIDTH-2:0] = con_br_cur_pc[PC_WIDTH-2:0]
                                    + con_br_offset[PC_WIDTH-2:0];
```

`con_br_offset` 是 21 位带符号立即数（对应 RISC-V B 型指令），在 lbuf 内经过符号扩展为 39 位后参与计算。

### 4.2 回边偏移距离限制

```verilog
// ct_ifu_lbuf.v: 1523-1528 行
// 计算回边偏移的绝对值（以半字为单位）
assign back_br_offset[3:0] = (~con_br_offset[3:0]) + 4'b1;

// 32 位分支指令：偏移绝对值必须 < 15（不能为 -15 或 -16）
assign back_br_offset_less_15 = (&con_br_offset[PC_WIDTH-2:4]) &&
                                (con_br_offset[3:0] != 4'b0000) &&  // 不是 -16
                                (con_br_offset[3:0] != 4'b0001);   // 不是 -15

// 16 位分支指令：偏移绝对值必须 < 16（不能为 -16）
assign back_br_offset_less_16 = (&con_br_offset[PC_WIDTH-2:4]) &&
                                (con_br_offset[3:0] != 4'b0000);   // 不是 -16
```

这里的限制是因为 lbuf 最多有 16 个 Entry，而分支指令本身也要占用 1~2 个 Entry，留给循环体其他指令的空间有限。

### 4.3 Record FIFO 的更新

```verilog
// ct_ifu_lbuf.v: 1875-1894 行
assign record_fifo_update = ibctrl_lbuf_create_vld &&
                            cp0_ifu_lbuf_en &&
                            back_br_taken &&
                            (
                              back_br_offset_less_15 && back_br_inst_32 ||
                              back_br_offset_less_16 && !back_br_inst_32
                            ) &&
                            (lbuf_cur_state[5:0] == IDLE) &&
                            (
                              // 两个已有 Entry 中都不存在相同 PC
                              (!(back_br_pc == record_fifo_entry0_pc) || !record_fifo_entry0_valid) &&
                              (!(back_br_pc == record_fifo_entry1_pc) || !record_fifo_entry1_valid)
                            );
```

**新的回边分支写入 Record FIFO 的条件**：必须在 IDLE 状态、已 taken、偏移符合大小限制、且 PC 不重复。每次写入时 `record_fifo_bit` 翻转，交替使用 Entry0 和 Entry1。

### 4.4 `back_br_hit_lbuf_end` 信号

在 FILL 状态中，这是"填充完毕"的核心判断：

```verilog
// ct_ifu_lbuf.v: 1392-1394 行
assign back_br_hit_lbuf_end = back_br_taken &&
                              (back_br_pc[PC_WIDTH-2:0] == new_entry_pc[PC_WIDTH-2:0]) &&
                              lbuf_create_vld;
```

含义：**当前正在填充的回边分支指令，其 PC 恰好等于 Record FIFO 中记录的新 Entry 的起始 PC**（`new_entry_pc` 就是 Record FIFO 的新槽中记录的 PC，也是循环体的起始地址）。这意味着循环体已经从起始位置走到了终点（回边分支处），填充完整。

---

## 5. Entry 填充逻辑（FILL/FRONT_FILL 状态）

### 5.1 Create Pointer 机制

lbuf 使用**循环移位的 one-hot 指针** `lbuf_create_pointer[15:0]` 来指示下一个要写入的 Entry：

```verilog
// ct_ifu_lbuf.v: 5168-5184 行
always @(posedge lbuf_create_pointer_update_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    lbuf_create_pointer[ENTRY_NUM-1:0] <= {{(ENTRY_NUM-1){1'b0}}, 1'b1}; // Entry[0]
  else if(lbuf_flush)
    lbuf_create_pointer[ENTRY_NUM-1:0] <= {{(ENTRY_NUM-1){1'b0}}, 1'b1};
  else if(fill_state_enter)
    lbuf_create_pointer[ENTRY_NUM-1:0] <= {{(ENTRY_NUM-1){1'b0}}, 1'b1}; // 重置到 0
  else if(taken_front_branch_enter)
    lbuf_create_pointer[ENTRY_NUM-1:0] <= front_update_pointer[15:0];    // 跳到前向分支体起始
  else if(front_fill_enter)
    lbuf_create_pointer[ENTRY_NUM-1:0] <= front_update_next_pointer[15:0];// 从前向分支后一 Half 开始
  else if(lbuf_create_vld)
    lbuf_create_pointer[ENTRY_NUM-1:0] <= create_pointer_pre[ENTRY_NUM-1:0]; // 向前移动
  else
    lbuf_create_pointer[ENTRY_NUM-1:0] <= lbuf_create_pointer[ENTRY_NUM-1:0];
end
```

`create_pointer_pre` 是根据当前周期写入的 half-word 数（`ibdp_lbuf_half_vld_num`）对 `lbuf_create_pointer` 做的循环左移预计算：

```verilog
// ct_ifu_lbuf.v: 5115-5140 行
always @(lbuf_create_pointer[15:0] or ibdp_lbuf_half_vld_num[3:0])
begin
case(ibdp_lbuf_half_vld_num[3:0])
  4'b0001 : create_pointer_pre = {lbuf_create_pointer[14:0], lbuf_create_pointer[15]};
  4'b0010 : create_pointer_pre = {lbuf_create_pointer[13:0], lbuf_create_pointer[15:14]};
  // ...
endcase
end
```

### 5.2 多 Entry 并行写入

每个周期最多可以来自 IB 级的 9 个 half-word（h0 ~ h8）。lbuf 通过预先生成 9 个偏移版本的 create pointer 来支持**同一周期写入多个 Entry**：

```verilog
// ct_ifu_lbuf.v: 5201-5217 行
assign lbuf_create_pointer0 = lbuf_create_pointer;
assign lbuf_create_pointer1 = {lbuf_create_pointer[14:0], lbuf_create_pointer[15]};  // 左移1
assign lbuf_create_pointer2 = {lbuf_create_pointer[13:0], lbuf_create_pointer[15:14]}; // 左移2
// ... 直到 lbuf_create_pointer8（左移8）
```

这样 `h0` 对应 `lbuf_create_pointer0`，`h1` 对应 `lbuf_create_pointer1`，以此类推。每个 Entry 的写入使能信号 `entry_create[n]` 由这些 pointer 的对应位控制，形成一个高效的交叉矩阵：

```verilog
// ct_ifu_lbuf.v: 3539-3547 行
// 示例：Entry[0] 的数据选择逻辑
assign entry_create_inst_data_0[15:0] =
    ({16{lbuf_create_pointer0[ 0]}} & h0_data[15:0]) |  // pointer0 的 bit[0] 选 h0
    ({16{lbuf_create_pointer1[ 0]}} & h1_data[15:0]) |  // pointer1 的 bit[0] 选 h1
    ({16{lbuf_create_pointer2[ 0]}} & h2_data[15:0]) |  // ...
    // ...
    ({16{lbuf_create_pointer8[ 0]}} & h8_data[15:0]);
```

### 5.3 front_vld_mask 的作用

在 FRONT_FILL 状态，前向分支的循环体可能跨越了分支点，需要通过 `front_vld_mask` 屏蔽不属于循环体部分的半字：

```verilog
// ct_ifu_lbuf.v: 2358-2372 行
always @(front_br_body_num[3:0])
begin
case(front_br_body_num[3:0])
  4'b0000 : front_vld_mask[8:0] = 9'b000_000_000; // 0个半字有效
  4'b0001 : front_vld_mask[8:0] = 9'b100_000_000; // 1个有效（h8）
  4'b0010 : front_vld_mask[8:0] = 9'b110_000_000; // 2个有效（h7,h8）
  4'b0011 : front_vld_mask[8:0] = 9'b111_000_000; // 3个有效
  // ...
  default : front_vld_mask[8:0] = 9'b111_111_111; // 全部有效
endcase
end
```

`front_br_body_num` 记录还需要填充多少个半字才能完成前向分支体的填充。

### 5.4 lbuf_cur_entry_num 的维护

`lbuf_cur_entry_num[3:0]` 追踪当前已填充的半字数量，用于判断前向分支的偏移是否超界：

```verilog
// ct_ifu_lbuf.v: 1577-1594 行
always @(posedge lbuf_cur_entry_num_clk or negedge cpurst_b)
begin
  if(!cpurst_b || lbuf_flush || fill_state_enter)
    lbuf_cur_entry_num[3:0] <= 4'b0;
  else if(lbuf_fill_state && lbuf_create_vld)
    lbuf_cur_entry_num[3:0] <= lbuf_cur_entry_num_pre[3:0];
end

// 若该周期有前向分支跳转，需要调整 cur_entry_num 到跳转目标处
assign lbuf_cur_entry_num_pre[3:0] = (front_br_taken)
                                   ? front_target_num[3:0]
                                   : lbuf_target_entry_num[3:0];
```

---

## 6. BHT 预测集成

### 6.1 概述

lbuf 需要在 ACTIVE 状态下对循环内的分支（包括回边和前向分支）进行预测，以决定每次迭代结束时是继续循环还是退出。lbuf **不会每次都读取 BHT 阵列**，而是在填充阶段（FILL）就捕获当时的 BHT Sel Array 结果，在后续 ACTIVE 阶段自己维护和更新该预测值。

### 6.2 Sel Array（方向选择数组）的自维护

BHT 使用 bi-mode 预测：`bht_lbuf_pre_taken_result` 和 `bht_lbuf_pre_ntaken_result` 分别是"倾向于 taken 的计数器数组"和"倾向于 not-taken 的计数器数组"，而 **Sel Array** 决定用哪个数组。

在 FILL 状态捕获 Sel Array 结果：

```verilog
// ct_ifu_lbuf.v: 6284-6286 行
assign front_br_sel_array_record = (lbuf_cur_state[5:0] == FILL) &&
                                   front_br_check &&
                                   lbuf_create_vld;
// 此时 sel_array_result = ibdp_lbuf_bht_sel_array_result（来自 IP 级）
```

后续从 IU 阶段的执行结果来更新（饱和计数器逻辑）：

```verilog
// ct_ifu_lbuf.v: 6288-6308 行
assign front_br_sel_array_result_pre[1:0] = (iu_ifu_bht_condbr_taken)
                                           ? front_br_sel_array_result[1:0] + 2'b01
                                           : front_br_sel_array_result[1:0] - 2'b01;

assign front_br_sel_array_update = iu_ifu_bht_check_vld &&
                                   (iu_ifu_cur_pc == front_entry_cur_pc) &&
                                   !( (front_br_sel_array_result == 2'b00 && !iu_ifu_bht_condbr_taken) ||
                                      (front_br_sel_array_result == 2'b11 &&  iu_ifu_bht_condbr_taken) ||
                                      // bi-mode 特殊逻辑...
                                    );
```

### 6.3 BHT 最终预测结果的计算

有了 Sel Array 结果，再从 BHT 阵列中读出对应 PC 的预测计数器值，做 XOR 折叠：

```verilog
// ct_ifu_lbuf.v: 6202-6238 行（front_br 示例）
assign front_pre_array_result[31:0] = (front_br_sel_array_result[1])
                                    ? pre_taken_result[31:0]
                                    : pre_ntaken_result[31:0];

// 用 PC 低位 XOR VGHR（向量 GHR 低4位）作为索引，选出 2-bit 计数器
always @(front_entry_cur_pc[6:3] or vghr[3:0] or front_pre_array_result)
begin
case(front_entry_cur_pc[6:3] ^ vghr[3:0])
  4'b0000 : front_br_bht_pre_result[1:0] = front_pre_array_result[ 1: 0];
  4'b0001 : front_br_bht_pre_result[1:0] = front_pre_array_result[ 3: 2];
  // ...
endcase
end
assign front_br_bht_result = front_br_bht_pre_result[1]; // MSB = 预测方向
```

回边（back_br）的计算方式完全对称。

### 6.4 lbuf_bht_active_state 信号

```verilog
// ct_ifu_lbuf.v: 6465 行
assign lbuf_bht_active_state = lbuf_cur_state[3]; // ACTIVE 状态标志
```

当 lbuf 处于 ACTIVE 状态时，BHT 模块需要知道当前分支预测是由 lbuf 自己维护的，而不是通过正常的 BHT 读流程。`lbuf_bht_active_state` 就是这个通知信号，BHT 模块据此可以避免对 lbuf 正在使用的分支做重复的正常读操作。

---

## 7. 循环出口检测（CACHE 状态）

### 7.1 循环退出判断

在 ACTIVE 状态，lbuf 每当弹出（retire）包含回边分支指令的一批时，检查 `back_br_bht_result`（BHT 对回边的预测）：

```verilog
// ct_ifu_lbuf.v: 1400-1418 行
assign lbuf_pop_not_taken_back_br = lbuf_retire_vld &&
                                    !back_br_bht_result &&         // BHT 预测不跳
                                    (
                                      (lbuf_pop_inst0_valid && lbuf_pop_inst0_back_br) ||
                                      (lbuf_pop_inst1_valid && lbuf_pop_inst1_back_br && !lbuf_pop_inst0_br) ||
                                      (lbuf_pop_inst2_valid && lbuf_pop_inst2_back_br && !lbuf_pop_inst0_br
                                                                                       && !lbuf_pop_inst1_br)
                                    );
```

`!lbuf_pop_inst0_br` 等条件是为了保证：如果 inst0 就是一个分支，那 inst1/2 的分支不再检查（优先处理靠前的分支）。

### 7.2 loop_exit 与 IDLE 转换

`lbuf_pop_not_taken_back_br` 即相当于"循环出口条件"。一旦触发：
1. 状态机从 ACTIVE 跳回 IDLE。
2. lbuf 向 ibctrl 发出 change-flow 信号，通知 pcgen 从 back_entry_cur_pc + 1（或 +2）的地址重新开始正常取指。

```verilog
// ct_ifu_lbuf.v: 6694-6697 行
// 循环退出时的 chgflw pc = 回边分支的下一条指令 PC
assign active_idle_chgflw_pc_pre[PC_WIDTH-2:0] = (back_entry_inst_32)
                                                ? (back_entry_cur_pc + 38'd2)  // 32位分支，跳过2个半字
                                                : (back_entry_cur_pc + 38'd1); // 16位分支，跳过1个半字
```

---

## 8. Entry 读出（ACTIVE 状态）

### 8.1 Retire Pointer 机制

与 create pointer 类似，lbuf 使用 `lbuf_retire_pointer[15:0]`（one-hot 循环移位）来追踪下一个要读出的 Entry：

```verilog
// ct_ifu_lbuf.v: 5405-5419 行
always @(posedge lbuf_retire_pointer_update_clk or negedge cpurst_b)
begin
  if(!cpurst_b || lbuf_flush)
    lbuf_retire_pointer <= 16'b1;  // 复位到 Entry[0]
  else if(fill_state_enter || idle_cache_state_enter || front_cache_active_state_enter)
    lbuf_retire_pointer <= 16'b1;  // 进入 ACTIVE 时从头开始
  else if(lbuf_retire_vld && lbuf_pop_branch_vld)
    lbuf_retire_pointer <= lbuf_retire_pointer_branch_pre; // 有分支：跳转到分支目标
  else if(lbuf_retire_vld && !lbuf_pop_branch_vld)
    lbuf_retire_pointer <= lbuf_retire_pointer_pre;         // 无分支：顺序前进
end
```

retire pointer 的前进方式取决于当前弹出的指令是否包含分支及分支是否跳转。

### 8.2 每周期最多弹出 3 条指令（inst0/1/2）

lbuf 每周期最多弹出 3 条逻辑指令（inst0、inst1、inst2），每条指令可能是 16 位（1 个 half-word）或 32 位（2 个 half-word）。`lbuf_pop_inst0/1/2_valid` 指示各条是否有效。

弹出逻辑通过一个大的 casez 语句根据 `pop_h0_32_start ~ pop_h4_32_start`（前 5 个 half-word 的起始标志）来确定打包方式（例如 `5'b1?1?1` 表示三条 32 位指令）：

```verilog
// ct_ifu_lbuf.v: 5537-5588 行（部分示意）
casez({pop_h0_32_start, pop_h1_32_start, pop_h2_32_start,
       pop_h3_32_start, pop_h4_32_start})
  5'b000?? : begin  // 三条 16 位指令
    lbuf_pop_inst0_data = {16'b0, pop_h0_data};  // 16位
    lbuf_pop_inst1_data = {16'b0, pop_h1_data};
    lbuf_pop_inst2_data = {16'b0, pop_h2_data};
    lbuf_pop3_half_num  = 3'b011;  // 消耗3个半字
    // ...
  end
  5'b1?1?1 : begin  // 三条 32 位指令
    lbuf_pop_inst0_data = {pop_h1_data, pop_h0_data};  // 32位
    lbuf_pop_inst1_data = {pop_h3_data, pop_h2_data};
    lbuf_pop_inst2_data = {pop_h5_data, pop_h4_data};
    lbuf_pop3_half_num  = 3'b110;  // 消耗6个半字
    // ...
  end
  // ...
endcase
```

### 8.3 关键输出信号

| 信号 | 含义 |
|------|------|
| `lbuf_ibctrl_lbuf_active` | lbuf 处于 ACTIVE 状态（`lbuf_cur_state[3]`），通知 ibctrl 不要通过正常路径向 IB 发指令 |
| `lbuf_ibctrl_chgflw_vld` | lbuf 触发了一次 change-flow（循环开始或循环退出）|
| `lbuf_ibctrl_chgflw_pc` | change-flow 的目标 PC（进入循环时为循环起始 PC；退出循环时为回边分支的下一指令 PC） |
| `lbuf_ibctrl_chgflw_pred` | 本次 change-flow 的预测信息（`2'b11` 表示 taken，`2'b00` 表示 not-taken）|
| `lbuf_ibctrl_stall` | 请求 ibctrl 暂停接收新指令（CACHE/FRONT_BRANCH/FRONT_CACHE 状态）|
| `lbuf_ibdp_inst0/1/2` | 向 ibdp 输出的最多 3 条指令数据 |
| `lbuf_ibdp_inst0/1/2_valid` | 各条指令是否有效 |
| `lbuf_ibdp_inst0/1/2_pc` | 各条指令的 PC（低 15 位，在 lbuf 的循环地址空间内） |

### 8.4 lbuf_cur_pc 的维护

`lbuf_cur_pc` 是 lbuf 内部追踪的"当前指令 PC"，用于向 ibdp 报告输出指令的 PC：

```verilog
// ct_ifu_lbuf.v: 6151-6167 行
always @(posedge lbuf_cur_pc_update_clk or negedge cpurst_b)
begin
  if(!cpurst_b || lbuf_flush || fill_state_enter)
    lbuf_cur_pc <= 0;
  else if(active_state_enter)
    lbuf_cur_pc <= loop_start_pc;         // 进入 ACTIVE 时，设置为循环起始 PC
  else if(lbuf_retire_vld && lbuf_pop_branch_vld)
    lbuf_cur_pc <= lbuf_cur_pc_branch_pre;// 分支跳转：更新为分支目标 PC
  else if(lbuf_retire_vld && !lbuf_pop_branch_vld)
    lbuf_cur_pc <= lbuf_cur_pc_pre;       // 顺序：PC += 弹出的半字数
end

// 循环起始 PC = back_entry_target_pc（回边跳转的目标，即循环头）
assign loop_start_pc = back_update_target_pc;
```

---

## 9. Flush 逻辑

### 9.1 触发条件

```verilog
// ct_ifu_lbuf.v: 1278-1279 行
assign lbuf_flush  = ibctrl_lbuf_flush;      // 来自 ibctrl 的全局 flush
assign bju_mispred = ibctrl_lbuf_bju_mispred; // 分支预测失败
```

`ibctrl_lbuf_flush` 通常由以下事件触发：
- **异常（Exception）**：包括访存异常、系统调用等
- **fence.i**：指令 fence，必须清空所有取指缓冲
- **ICache Invalidation**：Cache 行失效
- **中断（Interrupt）**

`ibctrl_lbuf_bju_mispred` 由 IU 阶段的 BJU（Branch and Jump Unit）在执行阶段发现分支预测错误时触发。

### 9.2 Flush 时的动作

```verilog
// ct_ifu_lbuf.v: 1271-1272 行（状态机）
else if(lbuf_flush || bju_mispred)
  lbuf_cur_state[5:0] <= IDLE;
```

所有主要的寄存器（Entry Array、Record FIFO、Back/Front Br Buffer、create/retire pointer、cur_pc 等）都在 `lbuf_flush` 或 `cpurst_b` 复位时清零：

```verilog
// 例：Entry Array 的 Entry 清零（由各 entry 子模块中的 lbuf_flush 信号触发）
always @(posedge ...)
begin
  if(!cpurst_b || lbuf_flush)
    entry_vld_x <= 1'b0;  // 全部 entry 无效
  // ...
end
```

Flush 后 lbuf 状态机回到 IDLE，等待下一次检测到合法回边后重新开始工作。

---

## 10. 与 IBUF 的协作

### 10.1 lbuf 激活时 IBUF 停止接收新指令

当 lbuf 处于 CACHE/FRONT_BRANCH/FRONT_CACHE 状态时，lbuf 向 ibctrl 发出 stall 信号：

```verilog
// ct_ifu_lbuf.v: 6747-6749 行
assign lbuf_ibctrl_stall = lbuf_cur_state[2]   // CACHE
                        || lbuf_cur_state[1]   // FRONT_BRANCH
                        || lbuf_cur_state[5];  // FRONT_CACHE
```

ibctrl 收到 stall 后停止向 IBUF 写入新指令，等待 IBUF 排空后再由 lbuf 接管。

### 10.2 lbuf 激活时 ibctrl 的取指控制

```verilog
// ct_ifu_lbuf.v: 6746 行
assign lbuf_ibctrl_lbuf_active = (lbuf_cur_state[3]); // ACTIVE
```

当 `lbuf_ibctrl_lbuf_active = 1` 时：
- ibctrl 不再通过正常路径（I-Cache → IBUF）向 IB 级发指令
- IB 级的指令全部来自 lbuf 的 `lbuf_ibdp_inst0/1/2` 输出
- `lbuf_pcgen_active = lbuf_cur_state[3]` 告知 pcgen 不需要再计算下一个取指地址

### 10.3 change-flow 的时序

lbuf 的 change-flow 机制用于平滑切换：

```
周期 T：   lbuf 处于 FILL/FRONT_FILL 状态，检测到 back_br_hit_lbuf_end
           → lbuf_stop_fetch_chgflw_vld_pre 置高
           → lbuf_addrgen_chgflw_mask = 1（告知 addrgen 本周期的取指地址无效）

周期 T+1： lbuf_stop_fetch_chgflw_vld 寄存器锁存
           → lbuf_ibctrl_chgflw_vld = 1
           → lbuf_ibctrl_chgflw_pc = back_br_tar_pc（循环起始 PC）
           → ibctrl 触发取指地址变更到循环起始 PC
           → lbuf 状态机 FILL → CACHE（同时）

周期 T+N： IBUF 排空（ibuf_empty = 1）
           → 状态机 CACHE → ACTIVE
           → lbuf 开始向 ibdp 供指
```

### 10.4 退出 lbuf 时的切换

当循环退出（`lbuf_pop_not_taken_back_br`）时：

```
周期 T：   ACTIVE 状态，回边 BHT 预测不跳
           → active_idle_chgflw_vld_pre 置高
           → 状态机 ACTIVE → IDLE（下周期）

周期 T+1： active_idle_chgflw_vld 锁存
           → lbuf_ibctrl_chgflw_vld = 1
           → lbuf_ibctrl_chgflw_pc = 回边分支下一条指令 PC
           → ibctrl 触发正常取指重新启动
           → lbuf_ibctrl_lbuf_active = 0（IDLE 状态下 bit[3]=0）
```

---

## 11. 限制与退化条件

### 11.1 fill_not_under_rule——填充时放弃

以下任一条件成立时，FILL 状态会立即退回 IDLE（放弃当前循环的缓存尝试）：

```verilog
// ct_ifu_lbuf.v: 1454-1463 行
assign fill_not_under_rule = lbuf_create_vld && (
    inst_other_chgflw ||    // 遇到其他控制流变化（间接跳转、调用等）
    inst_auipc       ||    // 遇到 auipc 指令（PC 绝对值相关）
    back_br_not_loop_end || // 回边 PC 不是预期的循环终点
    front_br_more_than_one|| // 遇到第二个前向分支（只支持1个）
    loop_buffer_full ||    // lbuf 已满（循环体超过16个 half-word）
    loop_end_br_not_taken || // 循环终点的回边不跳转（循环次数<2）
    front_br_check && front_br_oversize  // 前向分支偏移超界
);
```

| 退化条件 | 原因 |
|----------|------|
| `inst_other_chgflw` | 循环体含有其他改变控制流的指令，lbuf 无法正确追踪 |
| `inst_auipc` | `auipc` 的结果与 PC 绝对值相关，循环迭代时 PC 不同，缓存无意义 |
| `back_br_not_loop_end` | 填充过程中遇到了另一个负向分支，说明循环嵌套或不规则，放弃 |
| `front_br_more_than_one` | 第二个前向分支（lbuf 只支持最多一个 if-then 结构） |
| `loop_buffer_full` | 循环体超过16个 half-word，超出 lbuf 容量 |
| `loop_end_br_not_taken` | 检测到回边分支时它没有跳转，意味着该循环只执行了一次，不值得缓存 |
| `front_br_oversize` | 前向分支的目标超出了当前已知的循环范围 |

### 11.2 front_fill_not_under_rule——前向分支体填充放弃

```verilog
// ct_ifu_lbuf.v: 1466-1472 行
assign front_fill_not_under_rule = lbuf_create_vld && (
    inst_other_chgflw ||
    inst_auipc        ||
    front_fill_con_br_check   // FRONT_FILL 时遇到了新的条件分支
) ||
back_br_hit_not_jump_lbuf_end; // 回边命中起始但不跳转
```

### 11.3 Ban 机制——外层循环保护内层循环

当内层循环已经被填充并记录在 Record FIFO 后，如果外层循环的回边触发了新的 Record FIFO 写入，并且新回边的 PC 范围包含了已有记录，则 lbuf 会把内层循环的 Record FIFO Entry 标记为 `ban`（禁用）：

```verilog
// ct_ifu_lbuf.v: 1952-1955 行
assign new_record_entry_out_loop = record_fifo_update_flop &&
                                   old_entry_valid &&
                                   (old_entry_pc < new_record_cur_pc) &&     // 旧 PC 在新循环范围内
                                   (old_entry_pc > new_record_target_pc);    // 旧 PC 在新循环范围内
```

被 ban 的 Entry 不会再触发 FILL 或 CACHE 状态，直到有新的合法回边覆盖该槽位。

### 11.4 与 I-Cache Miss 的关系

lbuf 工作期间**不涉及** I-Cache 访问。lbuf 在 FILL 状态填充数据时，数据来源是正常取指流水线中 IB 级的 `ibdp_lbuf_h*_data`，这些数据在 FILL 阶段是通过正常 I-Cache 路径获取的。一旦进入 ACTIVE 状态，I-Cache 访问完全停止，因此 ACTIVE 状态下不会有 I-Cache Miss。

如果在 FILL 阶段发生了 I-Cache Miss（导致取指暂停），lbuf 的 `lbuf_create_vld` 信号也会随之拉低（因为 ibctrl 不再发送 create），FILL 状态会暂停等待，直到 Miss 处理完毕后继续填充。

---

## 12. 接口信号汇总

### 12.1 主要输入信号

| 信号 | 来源 | 说明 |
|------|------|------|
| `ibctrl_lbuf_create_vld` | ibctrl | IB 级本周期有有效数据写入 lbuf |
| `ibctrl_lbuf_flush` | ibctrl | 全局 flush |
| `ibctrl_lbuf_bju_mispred` | ibctrl | 分支预测失败 |
| `ibctrl_lbuf_retire_vld` | ibctrl | ACTIVE 状态下 lbuf 本周期可输出指令 |
| `ibdp_lbuf_h0_data ~ h8_data` | ibdp | 最多9个 half-word 数据 |
| `ibdp_lbuf_hn_con_br` | ibdp | 各 half-word 中哪个是条件分支的起始 |
| `ibdp_lbuf_con_br_cur_pc` | ibdp | 条件分支的 PC |
| `ibdp_lbuf_con_br_offset` | ibdp | 条件分支的偏移量（21位，RISC-V B型）|
| `ibdp_lbuf_con_br_taken` | ibdp | 条件分支本次是否跳转 |
| `bht_lbuf_pre_taken/ntaken_result` | bht | BHT taken/not-taken 预测数组 |
| `bht_lbuf_vghr` | bht | 向量 GHR（历史寄存器） |
| `ibuf_lbuf_empty` | ibuf | IBUF 是否为空 |
| `cp0_ifu_lbuf_en` | cp0 | lbuf 功能全局使能 |

### 12.2 主要输出信号

| 信号 | 目的地 | 说明 |
|------|--------|------|
| `lbuf_ibctrl_lbuf_active` | ibctrl | lbuf 处于 ACTIVE 状态 |
| `lbuf_ibctrl_stall` | ibctrl | 请求 ibctrl 暂停新指令进入 IBUF |
| `lbuf_ibctrl_chgflw_vld` | ibctrl | 触发一次 change-flow |
| `lbuf_ibctrl_chgflw_pc` | ibctrl | change-flow 目标 PC |
| `lbuf_ibctrl_active_idle_flush` | ibctrl | 循环退出时通知 ibctrl 清理 |
| `lbuf_ibdp_inst0/1/2` | ibdp | 向 IB 级输出的指令数据 |
| `lbuf_ibdp_inst0/1/2_valid` | ibdp | 各条输出指令的有效性 |
| `lbuf_ibdp_inst0/1/2_pc` | ibdp | 各条输出指令的 PC |
| `lbuf_bht_active_state` | bht | 通知 BHT lbuf 处于 ACTIVE |
| `lbuf_bht_con_br_vld/taken` | bht | 向 BHT 更新分支历史 |
| `lbuf_addrgen_active_state` | addrgen | lbuf ACTIVE，无需产生取指地址 |
| `lbuf_addrgen_cache_state` | addrgen | lbuf CACHE，无需产生取指地址 |
| `lbuf_addrgen_chgflw_mask` | addrgen | 屏蔽 addrgen 本周期的地址输出 |
| `lbuf_pcgen_active` | pcgen | lbuf ACTIVE，pcgen 停止正常取指 |
| `lbuf_pcgen_vld_mask` | pcgen | 屏蔽 pcgen 本周期的地址有效信号 |
| `lbuf_debug_st` | 调试 | 状态机当前状态（6-bit one-hot）|

---

## 附录：关键信号时序示例

以一个简单的 3 次迭代循环为例，说明各状态和信号的变化：

```
假设循环：
  loop_start(PC=0x1000): ...指令A(16位)...
  0x1002:                ...指令B(32位)...
  0x1006:                beq x1,x2,-6  // 回边，跳回 0x1000（offset=-6 half-word）

时间轴：
T=0: 正常取指，beq 指令到达 IB 级，ibdp_lbuf_con_br_* 有效
     → back_br_taken=1, back_br_offset=-3(半字), PC=0x1006
     → record_fifo_update=1, 写入 Entry0：pc=0x1006, offset=3
     → record_fifo_bit 翻转，新项=Entry0
     → 状态机仍在 IDLE

T=1~N: 同一循环再次执行，beq 再次到达，命中 Entry0（pc匹配，filled=0）
     → back_br_hit_record_fifo_unfill=1
     → 状态机 IDLE → FILL
     → fill_state_enter=1, lbuf_create_pointer 复位到 Entry[0]
     → back_entry_start_num = 3（填充从 Entry[3] 开始比较）

T=FILL: 指令A(h0)、指令B(h1,h2)、beq(h3,h4) 进入 lbuf
     → Entry[0] = 指令A的低16位, Entry[1]=指令B低16位, Entry[2]=指令B高16位
     → Entry[3]=beq低16位, Entry[4]=beq高16位
     → back_br_hit_lbuf_end=1 (beq的PC=0x1006=new_entry_pc)
     → 状态机 FILL → CACHE
     → lbuf_stop_fetch_chgflw_vld_pre=1

T=CACHE: lbuf_ibctrl_stall=1, 等待 IBUF 排空
     → ibuf_empty=1
     → 状态机 CACHE → ACTIVE
     → lbuf_cur_pc 更新为 back_br_tar_pc = 0x1000

T=ACTIVE 第1轮:
     retire ptr = Entry[0]
     弹出 inst0=指令A(pc=0x1000), inst1=指令B(pc=0x1002)
     → lbuf_retire_pointer 前进3个 half-word
     → lbuf_cur_pc = 0x1006

     下一周期 retire ptr = Entry[3]（beq）
     back_br_bht_result=1（BHT 预测跳转）
     → retire ptr 跳回 Entry[0]（循环起始）
     → lbuf_cur_pc 跳回 0x1000

T=ACTIVE 第2轮: 类似第1轮

T=ACTIVE 第3轮:
     弹出 beq
     back_br_bht_result=0（BHT 预测不跳，循环结束）
     → lbuf_pop_not_taken_back_br=1
     → 状态机 ACTIVE → IDLE
     → active_idle_chgflw_vld 锁存
     → lbuf_ibctrl_chgflw_vld=1, chgflw_pc = 0x1006+2 = 0x1008（beq后面的指令）
     → ibctrl 恢复正常取指，从 0x1008 开始
```

---

*文档编写基于 RTL 源代码 `ct_ifu_lbuf.v` 的逐行分析，如有疑问请对照相应行号查阅源码。*
