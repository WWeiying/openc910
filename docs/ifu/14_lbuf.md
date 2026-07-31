# C910 IFU Loop Buffer (lbuf) 模块详解

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_lbuf.v`
>
> 本文档面向希望深入理解 C910 取指前端微架构的读者。建议在阅读本文之前先了解 IFU 整体结构（见 `00_ifu_overview.md`）。

---

## 目录

1. [模块概述与设计动机](#1-模块概述与设计动机)
2. [逻辑结构](#2-逻辑结构)
3. [状态机（核心）](#3-状态机核心)
4. [循环体检测——回边识别](#4-循环体检测回边识别)
5. [Entry 填充逻辑（FILL/FRONT_FILL 状态）](#5-entry-填充逻辑fillfront_fill-状态)
6. [BHT 预测集成](#6-bht-预测集成)
7. [循环出口预测与恢复](#7-循环出口预测与恢复)
8. [Entry 读出（ACTIVE 状态）](#8-entry-读出active-状态)
9. [Flush 逻辑](#9-flush-逻辑)
10. [与 IBUF 的协作](#10-与-ibuf-的协作)
11. [限制与退化条件](#11-限制与退化条件)
12. [接口信号汇总](#12-接口信号汇总)

---

## 1. 模块概述与设计动机

### 1.1 什么是 Loop Buffer

**Loop Buffer（LBUF）** 是 C910 IFU 中面向短循环的专用指令缓冲。它先在正常
前端路径运行循环时，以 16 位半字为单位复制循环体及其预解码属性；缓存建好并等
待 IBUF 排空后，LBUF 在 `ACTIVE` 状态成为 IBDP 的指令来源，每拍最多组织三条
指令。

```
普通取指路径：
  PCGEN → I-Cache/IF/IP → IBUF 或旁路 → IBDP → IDU

LBUF ACTIVE 时的功能供指路径：
  LBUF Entry Array → 指令拼接/分支选择 → IBDP → IDU
```

这里的“绕过 I-Cache”是**功能数据源**意义上的：进入 IBDP 的指令来自 LBUF，
不再依赖该次循环迭代重新从 I-Cache 取回。不能仅据此断言 ACTIVE 的每一拍都在
物理上关闭 I-Cache 的全部时钟或 SRAM 端口。RTL 中能直接看到的是：

- `lbuf_ibctrl_lbuf_active` 使 IBCTRL 选择 LBUF 供指并禁止 IBUF/旁路成为当前来源；
- `lbuf_addrgen_active_state` 屏蔽 ADDRGEN 的普通分支改流计算；
- `lbuf_pcgen_vld_mask` 只在进入/退出等切换拍取消前端有效事务；
- `lbuf_pcgen_active` 在 PCGEN 中还参与 I-Cache invalidation 完成后的 LBUF flush
  条件，但它本身不是一个“关闭 I-Cache”的直接门控信号。

因此，功能路径、时钟门控和最终物理功耗必须分层描述。

### 1.2 设计动机

| 微架构目标 | RTL 中可观察到的做法 |
|------|------|
| **复用短循环指令** | 16 项 Entry 保存已观察到的循环体，ACTIVE 时直接重放 |
| **隔离常规前端波动** | LBUF 输出的当前迭代不依赖 IBUF 中存在新的 I-Cache 返回数据 |
| **维持前端宽度** | 最多读取 6 个半字并拼成最多 3 条指令，匹配 IBDP 的三指令接口 |
| **保留控制流语义** | 单独保存一个回边和至多一个前向条件分支，并继续使用 BHT 预测信息 |
| **保留预解码属性** | Entry 同时保存长度、分支、fence、断点及向量相关元数据 |

LBUF 有降低重复取指活动、缓解 I-Cache 供给波动的设计意图，但“节省多少功耗”
和“比 I-Cache 命中快几拍”不能由这份 RTL 单独量化，需要综合后的门控结构、STA
和功耗分析支持。Entry 读出也不是“纯组合且无延迟”的完整性能结论：组合选择后
仍受 `ibctrl_lbuf_retire_vld`、IDU 反压、PCFIFO full 等条件控制。

RTL 保留了 `vsetvli`、`vl/vlmul/vsew` 和 split 类型等向量元数据路径。不过当前
开源配置中 `ct_cp0_regs.v` 把 `misa_vector` 固定为 0，`ct_idu_id_decd.v` 也把
`x_vec_inst` 固定为 0。因此这些字段说明源码保留了相关设计路径，不能据此把当前
配置直接描述成可运行 RVV 的“向量循环加速器”。

### 1.3 RTL 实际接受的循环形态

LBUF 并非先做一次完整静态检查，再决定是否缓存。它采用“记录回边、下一次进入
FILL、边走边验证”的动态过程；一旦 `fill_not_under_rule` 或
`front_fill_not_under_rule` 成立，就放弃当前填充并禁用相应记录。RTL 可直接确认
的主要边界是：

1. **阵列有 16 个半字槽位**：填充位置采用 4 位模 16 加法，以加法回绕
   `lbuf_target_entry_num < lbuf_cur_entry_num` 判 full。因而“物理上有 16 项”
   不等于“所有恰好 16 半字的路径都能被接受”；累计位置从非零值回到 0 的拍也会
   被判为 full 并放弃。
2. **循环结束必须是已 taken 的后向条件分支**：记录和命中都要求
   `back_br_taken`；填充时若预期循环结束分支未 taken，则放弃。
3. **只接受记录的那个回边**：填充期间遇到 PC 不等于 `new_entry_pc` 的其他后向
   条件分支，会触发 `back_br_not_loop_end`。
4. **至多记录一个前向条件分支**：第二个前向条件分支触发
   `front_br_more_than_one`；目标还必须位于当前循环 Entry 范围内。
5. **拒绝 `hn_chgflw` 标出的其他改流和 AUIPC**：前者包含非条件分支改流类别，
   后者依赖当前 PC。具体覆盖哪些指令应以 IBDP 产生这两个向量的解码为准。
6. **回边距离有限**：32 位回边可接受 1 到 14 个半字，16 位回边可接受 1 到
   15 个半字。
7. **`fence` 不是填充拒绝条件**：RTL 确实把 `hn_fence` 存入 Entry 并在重放时
   输出，但 `fill_not_under_rule` 中没有 fence 项。把“不能含 fence”列为硬约束
   与本版 RTL 不符。

---

## 2. 逻辑结构

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
  │  │  Entry0 / Entry1    │   IDLE=0，其余状态独热 │    │
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
parameter PC_WIDTH  = 40;
parameter ENTRY_NUM = 16;   // Entry 数量
```

`PC_WIDTH=40` 表示普通 PC 路径覆盖架构字节地址低 40 位。由于架构 `PC[0]`
恒为 0，模块端口和寄存器使用 `[PC_WIDTH-2:0]`，即 39 位内部半字地址：

```text
rtl_pc[38:0] = byte_pc[39:1]
byte_pc       = {rtl_pc, 1'b0}
```

所以 RTL PC 加 1 表示字节地址加 2，不存在额外的“模式位”。

LBUF 共有 **16 项 Entry**，每项由 `ct_ifu_lbuf_entry` 实现，存储一个 half-word
及其元信息，因此阵列存储规模是 32 字节。从纯存储槽位看，相当于 8 条 32 位
指令或 16 条压缩指令；但实际填充还受模 16 回绕判 full、分支位置和输入包边界
约束，不能据此声称任意 16 半字循环都能成功进入 ACTIVE。

### 2.3 每个 Entry 存储的字段

每个 `ct_ifu_lbuf_entry` 子模块存储：

| 字段 | 位宽 | 含义 |
|------|------|------|
| `entry_inst_data` | 16 bit | 该 half-word 的指令数据 |
| `entry_vld` | 1 bit | 本 Entry 是否有效 |
| `entry_back_br` | 1 bit | 本 Entry 是循环的回边分支（backward branch）的起始 half-word |
| `entry_front_br` | 1 bit | 本 Entry 是循环内前向分支（front branch）的起始 half-word |
| `entry_32_start` | 1 bit | 本 Entry 是否是 32 位指令的低 half-word（即指令的起始） |
| `entry_fence` | 1 bit | fence 预解码标志，重放时原样送 IBDP；它本身不在填充拒绝方程中 |
| `entry_bkpta/b` | 1 bit × 2 | 断点标记 A/B |
| `entry_vsetvli` | 1 bit | 本 Entry 是 vsetvli 指令（向量长度设置） |
| `entry_vl/vlmul/vsew` | 8/2/3 bit | 源码保留的向量状态：向量长度/倍长系数/元素宽度 |
| `entry_split0_type/split1_type` | 3 bit × 2 | 源码保留的指令拆分类型，重放时结合向量状态重新形成 split0/1 |

`entry_vld` 与 payload 的意义要分开：`lbuf_flush` 和 `fill_state_enter` 会清除
Entry valid；`ct_ifu_lbuf_entry` 的 payload 寄存器在普通 LBUF flush 时不会逐项
清零。只要 valid 为 0，旧 payload 就没有功能意义。这是常见的低翻转设计，不能
把“逻辑失效”误写成“每一位数据都被清零”。

### 2.4 front_entry 与 back_entry 的区别

lbuf 为循环内的两类分支各维护一个专用缓冲区：

| 缓冲区 | 寄存器前缀 | 作用 |
|--------|-----------|------|
| **Back Br Buffer** | `back_entry_*` | 保存循环结束回边的分支 PC、目标 PC、指令长度，以及由 Record FIFO 偏移得到的循环布局信息 |
| **Front Br Buffer** | `front_entry_*` | 保存循环内前向条件分支的 PC、目标 PC、指令长度、目标 Entry 指针、顺序下一 Entry 指针及分支体是否已填充 |

这两个缓冲区都只有 **1 个槽位**，与“一个循环结束回边、至多一个前向条件分支”
的接受规则相对应。

### 2.5 Record FIFO

Record FIFO 是两个回边候选记录，不是迭代次数计数器。每项保存回边分支 PC、回跳
距离、valid、filled、ban 和预测模式快照。`record_fifo_bit` 用来解释哪个槽是
`old_entry`、哪个槽是 `new_entry`：

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

`record_fifo_bit` 不是“每拍翻转”，也不只在写入时翻转。它在以下两类事件中翻转：

1. 一个合法的新回边既不命中 Entry0 也不命中 Entry1，此时同时
   `record_fifo_update=1`，把候选写入当前写槽；
2. 当前回边命中按 `record_fifo_bit` 定义的 old 槽，且该槽 valid、未 ban。
   翻转后该槽成为 new 槽，供状态机的后续填充语义使用。

在 IDLE 状态，候选的生命周期可概括为：

```text
第一次看到合法 taken 回边
    -> 写入候选：记录的是“循环结束分支 PC”和回跳半字数

以后再次看到同一回边
    -> 未 filled：进入 FILL，从回边目标开始收集下一次迭代
    -> 已 filled 且预测模式匹配：进入 CACHE，复用已有 LBUF 内容
```

未 filled 命中不比较 `pred_mode`；filled 命中还要求当前
`{vsetvli_pred_disable, vsetvli_pred_mode}` 与填充完成时保存的模式一致。
这里记录的 PC 是**循环结束回边的 PC**，不是循环起始 PC；循环起始地址由
`branch_pc + signed_offset` 得到。

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

这是一种“IDLE 全零、六个工作状态独热”的混合编码。不能笼统称为完整 one-hot
FSM，因为合法 IDLE 没有任何一位为 1；不过工作状态仍可直接测试单个位，例如
`lbuf_cur_state[3]` 表示 ACTIVE，`[2]` 表示 CACHE。

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
              │ （再次遇到记录的循环结束回边）            │_not_under  │
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

**注意**：状态寄存器的优先级是 reset，然后
`lbuf_flush || bju_mispred`，再然后 `!cp0_ifu_lbuf_en`，最后才接受
`lbuf_next_state`。`ins_inv_on` 不是状态寄存器的直接清零条件；它在
IDLE/CACHE/FRONT_CACHE 的组合转移条件中阻止进入 ACTIVE。

还要避免被辅助信号名称误导：

```text
fill_state_enter       = IDLE && hit_unfilled
idle_cache_state_enter = IDLE && hit_filled
active_state_enter     = (CACHE || FRONT_CACHE) && ibuf_empty
```

这些准备条件没有都带上 `!ins_inv_on`，也不等价于状态寄存器最终绕过
`!cp0_ifu_lbuf_en` 的高优先级处理。因此在 invalidation 或功能关闭期间，波形中
可能看到 pointer/PC 等准备寄存器更新或复位，但 FSM 仍停在或回到
IDLE/CACHE/FRONT_CACHE。判断“真的进入某状态”必须比较时钟沿前后的
`lbuf_cur_state`，不能只看名字中带 `*_enter` 的辅助信号。

### 3.3 关键状态详解

#### IDLE 状态

```verilog
// ct_ifu_lbuf.v: 1296-1303 行
IDLE : begin
  if(back_br_hit_record_fifo_fill && !ins_inv_on)
    lbuf_next_state[5:0] = CACHE;        // 复用已填充内容，先等待有序交接
  else if(back_br_hit_record_fifo_unfill && !ins_inv_on)
    lbuf_next_state[5:0] = FILL;         // 需要填充
  else
    lbuf_next_state[5:0] = IDLE;
end
```

IDLE 状态下，LBUF 观察 IBDP 提供的条件分支信息。离开 IDLE 不是“看到任意合法
回边”即可，而是要求 `ibctrl_lbuf_create_vld=1`，该回边 taken，PC 命中一个
valid、未 ban 的 Record FIFO 项：

- 命中 unfilled 项：进入 FILL；
- 命中 filled 项：还要比较当前预测模式与记录值，匹配后进入 CACHE。

第一次见到的新回边只更新 Record FIFO，状态仍保持 IDLE。

#### FILL 状态

FILL 状态下，lbuf 同步于正常取指流水线，将 IB 级拿到的 half-word 逐个写入 Entry Array。状态转移：

```verilog
// ct_ifu_lbuf.v: 1304-1313 行
FILL : begin
  if(fill_not_under_rule)
    lbuf_next_state[5:0] = IDLE;         // 遇到不规则情况，放弃
  else if(back_br_hit_lbuf_end)
    lbuf_next_state[5:0] = CACHE;        // 再次遇到记录的循环结束回边
  else if(front_br_under_rule)
    lbuf_next_state[5:0] = FRONT_BRANCH; // 检测到合法前向分支
  else
    lbuf_next_state[5:0] = FILL;
end
```

#### CACHE 状态

CACHE 是正常填充完成后的**交接等待状态**。此时 Entry 内容已准备好，但 IBUF
中还可能保留更早进入前端的指令。LBUF 通过 `lbuf_ibctrl_stall=1` 阻止新的正常
数据进入，等待 `ibuf_empty && !ins_inv_on` 后进入 ACTIVE。这样切换数据源时
不会越过 IBUF 中更老的指令，体现了前端仍必须维护程序顺序。

```verilog
// ct_ifu_lbuf.v: 1314-1319 行
CACHE : begin
  if(ibuf_empty && !ins_inv_on)
    lbuf_next_state[5:0] = ACTIVE;
  else
    lbuf_next_state[5:0] = CACHE;
end
```

`lbuf_ibctrl_stall` 在 CACHE、FRONT_BRANCH 和 FRONT_CACHE 三个状态有效；在
CACHE 中对应 `lbuf_cur_state[2]`。

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

- 只有 `ibctrl_lbuf_retire_vld=1` 时才真正推进。IBCTRL 的该信号要求 LBUF
  ACTIVE、PCFIFO 未形成 full stall、IDU 未反压。
- 读端最多查看 6 个连续 half-word，并按 `32_start` 拼成最多 3 条指令。
- 同一拍一旦出现分支，年龄更小的指令会被 `*_br_mask_vld` 屏蔽。也就是说，
  “最多三条”不表示可以把分支后的顺序路径指令与 taken 目标一起发出。
- 最老的有效分支预测 taken 时，retire pointer 和 `lbuf_cur_pc` 跳到保存的目标；
  没有 taken 分支时，二者按本拍实际消费的半字数顺序推进。
- 回边预测 not-taken 时触发 `lbuf_pop_not_taken_back_br`，状态离开 ACTIVE，并
  在寄存后一拍向 IBCTRL 发出恢复正常取指的 change-flow。
- LBUF 使用的是预测方向，不是已经执行确认的方向。若后续 BJU 判定误预测，
  `ibctrl_lbuf_bju_mispred` 会把状态机拉回 IDLE，由全局改流恢复正确路径。

#### FRONT_BRANCH 状态（单周期过渡）

```verilog
// ct_ifu_lbuf.v: 1320-1322 行
FRONT_BRANCH : begin
  lbuf_next_state[5:0] = FILL;  // 无条件返回 FILL
end
```

前向分支信息先由 FILL 拍写入 `front_update_pre_*`，随后状态进入 FRONT_BRANCH。
在 FRONT_BRANCH 拍，`front_entry_update=1`，把预记录值写入 `front_entry_*`，
状态无条件回到 FILL。若该前向分支本次 taken，create pointer 同时跳到
`front_update_pointer`，使后续填充从预测目标对应的 Entry 布局继续。

#### FRONT_FILL / FRONT_CACHE 状态

如果初次 FILL 时前向分支 taken，被跳过的顺序分支体尚未写入 LBUF。ACTIVE 中
该前向分支后来预测 not-taken 时，`front_br_body_not_filled` 触发：

1. ACTIVE 转入 FRONT_FILL，并发出 change-flow 到前向分支的顺序下一条指令；
2. create pointer 从 `front_entry_next_pointer` 开始，只填补缺失的顺序分支体；
3. 再次遇到记录的循环结束回边后转入 FRONT_CACHE；
4. IBUF 排空后回到 ACTIVE。

如果初次 FILL 时前向分支本来就 not-taken，RTL 会把
`front_entry_body_filled` 直接置 1，无需上述补填过程。

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

`local_en` 的意图是：非 IDLE 时持续允许状态更新；IDLE 时仅在
`back_br_taken` 出现时请求开钟。解读波形时还必须结合通用门控单元：

```text
clock_enable = (cp0_yy_clk_en &&
                (cp0_ifu_icg_en || lbuf_sm_clk_en)) ||
               external_en
```

因此 `lbuf_sm_clk_en=0` 并不单独证明输出时钟一定停止，
`cp0_ifu_icg_en` 可以覆盖局部使能。若未定义工艺 ICG 宏，开源
`gated_clk_cell` 的 RTL 仿真分支还可能把输出时钟直接接到输入时钟。实际门控收益
需要门级网表和功耗分析确认。

---

## 4. 循环体检测——回边识别

### 4.1 回边（Backward Branch）的判断

C910 由 IBDP 提供“本拍是否存在条件分支”、分支 PC、立即数和预测方向。LBUF
用立即数符号判断前向/后向，用 `con_br_taken` 判断该次前端预测是否跳转：

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

输入 `ibdp_lbuf_con_br_offset[20:0]` 按架构字节偏移编码；LBUF 实际构造：

```verilog
con_br_offset[38:0] = {{19{offset[20]}}, offset[20:1]};
```

也就是舍弃恒为 0 的字节位 `offset[0]`，转换为与内部 PC 一致的**半字单位有符号
偏移**。因此：

```text
rtl_target_pc = rtl_branch_pc + signed_offset_in_halfwords
byte_target   = {rtl_target_pc, 1'b0}
```

文档和波形中凡是看到 LBUF PC、offset 加减 1，都应按 2 字节解释。

### 4.2 回边偏移距离限制

```verilog
// ct_ifu_lbuf.v: 1523-1528 行
// 计算回边偏移的绝对值（以半字为单位）
assign back_br_offset[3:0] = (~con_br_offset[3:0]) + 4'b1;

// 32 位分支指令：可接受回跳距离 1..14 个半字
assign back_br_offset_less_15 = (&con_br_offset[PC_WIDTH-2:4]) &&
                                (con_br_offset[3:0] != 4'b0000) &&  // 不是 -16
                                (con_br_offset[3:0] != 4'b0001);   // 不是 -15

// 16 位分支指令：可接受回跳距离 1..15 个半字
assign back_br_offset_less_16 = (&con_br_offset[PC_WIDTH-2:4]) &&
                                (con_br_offset[3:0] != 4'b0000);   // 不是 -16
```

RTL 的候选预筛选只检查高位是否全 1，以及低 4 位是否为被排除的边界编码。换成
更直观的半字距离：32 位回边候选允许 1 到 14，16 位回边候选允许 1 到 15。
两者差一项与回边本身分别占两个/一个 Entry 相符。它只是 Record FIFO 的距离
预筛选，后续 FILL 的 `loop_buffer_full` 仍可能拒绝边界路径，尤其是累计位置发生
模 16 回绕时。

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

**新的回边分支写入 Record FIFO 的条件**：必须有有效 IB create、LBUF 已使能、
处于 IDLE、回边预测 taken、距离符合该指令长度的限制，而且两个现有槽都没有
valid PC 命中。

写槽由写入前的 `record_fifo_bit` 决定：0 写 Entry0，1 写 Entry1。该次新候选
会同时触发 `record_fifo_bit_update`，所以时钟沿后 bit 翻转，刚写入的槽成为
`new_entry`。此外，命中当前 old 槽时 bit 也可能翻转，因此不能把它简单理解成
固定轮转写指针。

还要注意一个容易漏掉的细节：`fill_state_enter || record_fifo_update` 会把两个槽
的 `filled` 位都清零，填充成功时才把当前 new 槽重新置为 filled。也就是说，
Record FIFO 不是两个可同时独立保存完整 LBUF 内容的缓存标签；真正的 16 项
Entry Array 只有一份，Record FIFO 主要承担候选发现、当前归属和退化管理。

### 4.4 `back_br_hit_lbuf_end` 信号

在 FILL 状态中，这是"填充完毕"的核心判断：

```verilog
// ct_ifu_lbuf.v: 1392-1394 行
assign back_br_hit_lbuf_end = back_br_taken &&
                              (back_br_pc[PC_WIDTH-2:0] == new_entry_pc[PC_WIDTH-2:0]) &&
                              lbuf_create_vld;
```

`new_entry_pc` 是 Record FIFO 保存的**循环结束回边 PC**。进入 FILL 后，正常
前端已经从该回边的 taken 目标开始执行下一次迭代；当数据流再次到达同一个
回边，并且本次仍预测 taken 时，`back_br_hit_lbuf_end=1`，说明从循环头到循环
尾的一轮路径已经被观察和写入。它绝不是“回边 PC 命中循环起始地址”。

这个条件还要求 `lbuf_create_vld`，所以只在 FILL/FRONT_FILL 且 IB 数据真正被
LBUF 接受时有效。相同 PC 但 not-taken 会形成
`back_br_hit_not_jump_lbuf_end`，在 FRONT_FILL 中属于放弃条件。

---

## 5. Entry 填充逻辑（FILL/FRONT_FILL 状态）

### 5.1 Create Pointer 机制

LBUF 使用循环移位的 one-hot 指针 `lbuf_create_pointer[15:0]` 表示下一批数据的
第一个写入位置。指针不是“每拍加一”，而是按本拍接受的有效半字数旋转：

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

`create_pointer_pre` 根据当前输入包的 half-word 数
`ibdp_lbuf_half_vld_num` 对指针做 1 到 9 位循环旋转。默认分支保持原值：

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

IBDP 最多提供 9 个 half-word 候选。LBUF 先根据 `ibdp_lbuf_h0_vld` 对 h0 到 h8
做对齐：若 h0 无效，则原 h1 移到内部 h0，末尾补 0。随后预生成 9 个旋转版本的
create pointer，以便同一拍把多个有效半字分配到连续 Entry：

```verilog
// ct_ifu_lbuf.v: 5201-5217 行
assign lbuf_create_pointer0 = lbuf_create_pointer;
assign lbuf_create_pointer1 = {lbuf_create_pointer[14:0], lbuf_create_pointer[15]};  // 左移1
assign lbuf_create_pointer2 = {lbuf_create_pointer[13:0], lbuf_create_pointer[15:14]}; // 左移2
// ... 直到 lbuf_create_pointer8（左移8）
```

这里的 h0/h1 指**对齐后的内部 half-word**。h0 对应 pointer0，h1 对应
pointer1，以此类推。每个 Entry 的写入使能由有效向量和这些 pointer 的对应位
共同形成，数据字段则通过按位 one-hot 选择网络送入目标 Entry：

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

最终功能写入条件为：

```text
entry_create =
    pointer_to_valid_halfword
  & lbuf_create_vld

lbuf_create_vld =
    ibctrl_lbuf_create_vld
  & (state == FILL || state == FRONT_FILL)
```

`entry_create_clk_en` 只要求处于 FILL/FRONT_FILL 且该槽有候选半字，不含最终
`ibctrl_lbuf_create_vld`。它是局部门控的预使能，不等价于 Entry 一定在该拍写入；
功能状态仍由 `entry_create` 决定。

### 5.3 front_vld_mask 的作用

若第一次填充时前向分支 taken，从“分支顺序下一条”到“分支目标”之间的半字没有
被执行，也就没有进入 LBUF。后来 FRONT_FILL 专门从顺序下一条开始补这段区域。
`front_br_body_num` 记录尚需补入的半字数，`front_vld_mask` 只保留当前输入包中
最前面的这些半字，防止越过前向分支目标继续覆盖已经存在的 Entry：

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

掩码位序与对齐后的输入一致：`front_vld_mask[8]` 对应内部 h0，
`[7]` 对应 h1。比如剩余 3 个半字时为 `9'b111_000_000`。每次有效
FRONT_FILL 输入后，计数减去本拍 `half_vld_num` 并饱和到 0；
`front_br_body_fill_finish` 在计数为 0 时成立。

### 5.4 lbuf_cur_entry_num 的维护

`lbuf_cur_entry_num[3:0]` 只在正常 FILL 中维护当前逻辑位置，用于检查前向分支
目标是否仍位于当前 16 Entry 循环布局内：

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

前向分支预测 taken 时，逻辑位置直接移动到目标 Entry；否则按本拍有效半字数
推进。由于计数只有 4 位，`loop_buffer_full` 通过“相加后数值变小”检测模 16
回绕。该信号与 `lbuf_create_vld` 一起使当前填充失败并把对应 Record FIFO 项
置 ban，而不是提供一个可持续使用的“满但仍有效”状态。

---

## 6. BHT 预测集成

### 6.1 概述

LBUF 在 ACTIVE 状态仍然需要预测前向条件分支和循环回边。它没有一套完整、独立
复制的 BHT，而是把预测所需信息拆成两部分：

1. 从 BHT 专用接口持续取得 `pre_taken_result[31:0]` 和
   `pre_ntaken_result[31:0]`，它们是 Predict Array 的候选计数器行；
2. 在 FILL 时记录该分支的 Sel Array 2 位值，并在后续执行反馈到来时在 LBUF
   内维护这份 selector。

因此“LBUF 之后完全不读 BHT 阵列”是不准确的。准确说法是：LBUF 不再依赖正常
IPDP 流水携带 selector，而是本地保存 selector，同时继续使用 BHT 提供的
Predict Array 行和当前 VGHR。

### 6.2 Sel Array（方向选择数组）的自维护

BHT 使用 bi-mode 组织：`bht_lbuf_pre_taken_result` 和
`bht_lbuf_pre_ntaken_result` 分别提供 taken bank 与 not-taken bank 的一行 16
个 2 位计数器，Sel Array 的高位选择使用哪一个 bank。

在 FILL 状态捕获 Sel Array 结果：

```verilog
// ct_ifu_lbuf.v: 6284-6286 行
assign front_br_sel_array_record = (lbuf_cur_state[5:0] == FILL) &&
                                   front_br_check &&
                                   lbuf_create_vld;
// 此时 sel_array_result = ibdp_lbuf_bht_sel_array_result（来自 IP 级）
```

后续通过 `iu_ifu_bht_check_vld`、实际分支 PC 和
`iu_ifu_bht_condbr_taken` 更新本地 selector。更新是 2 位饱和计数器，并带有
bi-mode 的“预测正确时部分跨区更新被抑制”条件：

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

### 6.3 最终预测方向的计算

先由 selector 高位选 taken/not-taken bank，再由分支 PC 片段与投机全局历史
异或，从 32 位行中选出一个 2 位计数器：

```verilog
// ct_ifu_lbuf.v: 6202-6238 行（front_br 示例）
assign front_pre_array_result[31:0] = (front_br_sel_array_result[1])
                                    ? pre_taken_result[31:0]
                                    : pre_ntaken_result[31:0];

// 用内部半字地址 PC[6:3] XOR VGHR 低4位，选出 2-bit 计数器
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

这里的 `front_entry_cur_pc[6:3]` 是 RTL 半字地址位，对应架构字节地址
`PC[7:4]`，不能直接按字节 PC 的 `[6:3]` 解读。

前向分支和回边使用相同的索引形式。两者并非完全对称：回边计数器在
`ins_inv_on=1` 时会与零掩码，强制得到 not-taken；前向分支路径没有这一项
掩码。正常进入 ACTIVE 本身还受 `!ins_inv_on` 约束。

### 6.4 lbuf_bht_active_state 信号

```verilog
// ct_ifu_lbuf.v: 6465 行
assign lbuf_bht_active_state = lbuf_cur_state[3]; // ACTIVE 状态标志
```

`lbuf_bht_active_state` 使 BHT 在若干内部选择点改用 LBUF 条件分支事件，而不是
正常 IP 级事件。LBUF 还输出：

```text
lbuf_bht_con_br_vld =
    cp0_ifu_lbuf_en
  & 当前输出包含条件分支
  & lbuf_retire_vld

lbuf_bht_con_br_taken = 最老有效条件分支的预测方向
```

BHT 用这组信号推进投机 VGHR，并对 LBUF 路径提供的分支预测信息做流水对齐。
这里的 `taken` 是前端采用的预测方向；实际方向仍由执行阶段反馈并用于训练与误
预测恢复。

---

## 7. 循环出口预测与恢复

### 7.1 循环退出判断

在 ACTIVE 状态，LBUF 每当接受一个含回边分支的输出包时，检查
`back_br_bht_result`。代码中的 `retire` 是 LBUF 读指针推进/向 IBDP 交付的命名，
不是 RTU 已经完成架构退休：

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

`!lbuf_pop_inst0_br` 等条件保证只考虑程序顺序上最老的分支。相同优先级还用于
指令 valid 屏蔽、retire pointer 选择和 PC 选择，确保一个输出包只沿最老分支
确定下一路径。

### 7.2 loop_exit 与 IDLE 转换

`lbuf_pop_not_taken_back_br` 是**预测循环退出**条件，而不是循环已经执行确认的
证明。一旦触发：
1. 状态机从 ACTIVE 跳回 IDLE。
2. 下一拍 LBUF 向 IBCTRL 发出 change-flow，请求从
   `back_entry_cur_pc + instruction_length` 恢复正常取指。

```verilog
// ct_ifu_lbuf.v: 6694-6697 行
// 循环退出时的 chgflw pc = 回边分支的下一条指令 PC
assign active_idle_chgflw_pc_pre[PC_WIDTH-2:0] = (back_entry_inst_32)
                                                ? (back_entry_cur_pc + 38'd2)  // 32位分支，跳过2个半字
                                                : (back_entry_cur_pc + 38'd1); // 16位分支，跳过1个半字
```

若预测退出但执行结果实际 taken，BJU 的误预测改流优先恢复到正确循环目标，LBUF
状态也因 `bju_mispred` 回到 IDLE。相反，若预测 taken 但实际退出，也由相同的
执行级误预测机制恢复。LBUF 优化不能改变分支必须最终由执行级确认这一原则。

---

## 8. Entry 读出（ACTIVE 状态）

### 8.1 Retire Pointer 机制

与 create pointer 类似，LBUF 使用 one-hot 环形
`lbuf_retire_pointer[15:0]` 指向下一个候选 half-word：

```verilog
// ct_ifu_lbuf.v: 5405-5419 行
always @(posedge lbuf_retire_pointer_update_clk or negedge cpurst_b)
begin
  if(!cpurst_b || lbuf_flush)
    lbuf_retire_pointer <= 16'b1;  // 复位到 Entry[0]
  else if(fill_state_enter || idle_cache_state_enter || front_cache_active_state_enter)
    lbuf_retire_pointer <= 16'b1;  // 为新填充/复用/补填后的重放准备 Entry0
  else if(lbuf_retire_vld && lbuf_pop_branch_vld)
    lbuf_retire_pointer <= lbuf_retire_pointer_branch_pre; // 最老分支预测 taken
  else if(lbuf_retire_vld && !lbuf_pop_branch_vld)
    lbuf_retire_pointer <= lbuf_retire_pointer_pre;         // 顺序推进到已交付分支之后
end
```

三个复位事件的时点并不完全相同：`fill_state_enter` 为重新填充做准备；
`idle_cache_state_enter` 为直接复用 filled 记录做准备；
`front_cache_active_state_enter` 为补填完成后的重放做准备。由于这些辅助条件未
全部包含 `!ins_inv_on`，它们是“准备事件”，严格的状态转移仍以 FSM 下一状态为准。

`lbuf_pop_branch_vld` 的含义不是“输出包里存在分支”，而是“程序顺序最老的有效
分支预测 taken”。若分支预测 not-taken，pointer 使用顺序路径，但只消费到该
分支为止，因为年轻指令已经被分支掩码挡住。

### 8.2 每周期最多弹出 3 条指令（inst0/1/2）

LBUF 的组合读口查看 h0 到 h5，最多拼出 inst0/1/2 三条逻辑指令。每条可以是
16 位或 32 位，`lbuf_pop_inst0/1/2_valid` 来自相应首 half-word 的 Entry valid。
32 位指令按 `{高半字, 低半字}` 拼接。

组合逻辑根据前 5 个 half-word 的 `32_start` 模式确定三条指令的边界，并同时
产生消费 1、2、3 条指令时分别需要推进多少个 half-word。比如
`5'b1?1?1` 表示 h0、h2、h4 分别是三条 32 位指令的起点：

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
| `lbuf_ibctrl_chgflw_vld` | LBUF 切换过程触发 change-flow：停止正常取指、退出 ACTIVE 或开始补填 |
| `lbuf_ibctrl_chgflw_pc` | 对应 change-flow 目标：回边目标、回边顺序下一 PC 或前向分支顺序下一 PC |
| `lbuf_ibctrl_chgflw_pred` | 送给 IBCTRL 的 **I-Cache way prediction mask**：stop-fetch 类为 `2'b00`，重新启动正常取指类为 `2'b11`；不是分支 taken/not-taken 编码 |
| `lbuf_ibctrl_stall` | 请求 ibctrl 暂停接收新指令（CACHE/FRONT_BRANCH/FRONT_CACHE 状态）|
| `lbuf_ibdp_inst0/1/2` | 向 ibdp 输出的最多 3 条指令数据 |
| `lbuf_ibdp_inst0/1/2_valid` | Entry valid、分支年龄掩码、LBUF enable 和 retire 握手共同形成的最终有效 |
| `lbuf_ibdp_inst0/1/2_pc` | 内部半字 PC 的低 15 位，对应架构字节 PC `[15:1]` |

### 8.4 lbuf_cur_pc 的维护

`lbuf_cur_pc[38:0]` 追踪当前 retire pointer 对应的完整内部半字 PC。LBUF 到 IBDP
的这组指令接口只输出低 15 位；它不是一份可独立还原完整架构 PC 的调试总线：

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

顺序推进量来自本拍实际交付到最老分支为止所消费的 1 到 6 个 half-word；预测
taken 时则选择 `front_entry_target_pc` 或 `back_entry_target_pc`。pointer 和 PC
由同一分支优先级、同一消费长度驱动，这是验证 LBUF 正确性的关键不变量：

```text
下一 retire pointer 所指 Entry
    必须与
下一 lbuf_cur_pc 所指架构半字地址
    表示同一条指令
```

---

## 9. Flush 逻辑

### 9.1 触发条件

```verilog
// ct_ifu_lbuf.v: 1278-1279 行
assign lbuf_flush  = ibctrl_lbuf_flush;      // 来自 ibctrl 的全局 flush
assign bju_mispred = ibctrl_lbuf_bju_mispred; // 分支预测失败
```

沿直接连线追踪，IBCTRL 形成：

```text
ibctrl_lbuf_flush =
    pcgen_ibctrl_lbuf_flush
  | lbuf_ibctrl_active_idle_flush

ibctrl_lbuf_bju_mispred = pcgen_ibctrl_bju_chgflw
pcgen_ibctrl_bju_chgflw = iu_ifu_chgflw_vld
```

其中 `pcgen_ibctrl_lbuf_flush` 包括 HAD/调试 PC load、保留的 vector PC load、
RTU change-flow、RTU exception、debug cancel，以及在 LBUF 非 ACTIVE 时完成的
I-Cache invalidation。若 invalidation 请求发生在 ACTIVE，
`active_ctc_record` 会记住请求，等预测退出 change-flow 时通过
`lbuf_ibctrl_active_idle_flush` 补做 flush。

变量名 `bju_mispred` 表达设计意图，但本模块直接看到的源是
`iu_ifu_chgflw_vld`，因此不应把它自行扩写成一份未由连线证明的异常类型列表。

### 9.2 Flush 时的动作

```verilog
// ct_ifu_lbuf.v: 1271-1272 行（状态机）
else if(lbuf_flush || bju_mispred)
  lbuf_cur_state[5:0] <= IDLE;
```

`lbuf_flush` 会使功能状态失效：FSM 回到 IDLE，Record FIFO valid 清除，
front/back buffer 清除，create/retire pointer 回到 Entry0，`lbuf_cur_pc` 清零，
每个 Entry 的 `entry_vld` 清零。Entry payload 不会因普通 LBUF flush 全部写零：

```verilog
// ct_ifu_lbuf_entry.v：flush 只需清 valid
always @(posedge ...)
begin
  if(!cpurst_b)
    entry_vld_x <= 1'b0;
  else if(lbuf_flush)
    entry_vld_x <= 1'b0;
  // ...
end
```

这符合“valid 决定 payload 是否有意义”的常见缓冲区设计：flush 后波形中仍能
看到旧的 `entry_inst_data_*`，并不表示旧循环仍有效。

还要区分 `lbuf_flush` 与 `bju_mispred`：后者在 `ct_ifu_lbuf.v` 中只直接强制
FSM 回到 IDLE，没有直接清除 Entry valid、Record FIFO 或 payload。不能看到一次
IU change-flow 就推断整个 LBUF 存储阵列已经清零。

---

## 10. 与 IBUF 的协作

### 10.1 从正常路径切换到 LBUF

切换分成“先阻止新数据、再等旧数据排空、最后选择 LBUF”三步。CACHE、
FRONT_BRANCH、FRONT_CACHE 通过以下信号直接使 IBCTRL 的 `buf_stall` 成立：

```verilog
// ct_ifu_lbuf.v: 6747-6749 行
assign lbuf_ibctrl_stall = lbuf_cur_state[2]   // CACHE
                        || lbuf_cur_state[1]   // FRONT_BRANCH
                        || lbuf_cur_state[5];  // FRONT_CACHE
```

在 ACTIVE，`lbuf_ibctrl_stall` 已经撤销，但 IBCTRL 仍通过
`!lbuf_active` 条件禁止 `ibuf_create_vld`、bypass 和 merge，并把
`ibctrl_ibdp_lbuf_inst_vld` 作为 IBDP 的数据源选择。IBUF 在进入 ACTIVE 前应已
经为空，所以这里不是两个队列并行竞争，而是有序的数据源交接。

### 10.2 lbuf 激活时 ibctrl 的取指控制

```verilog
// ct_ifu_lbuf.v: 6746 行
assign lbuf_ibctrl_lbuf_active = (lbuf_cur_state[3]); // ACTIVE
```

当 `lbuf_ibctrl_lbuf_active = 1` 时：

- IBCTRL 选择 LBUF 指令，禁止 IBUF、bypass、merge 成为当前 IBDP 来源；
- `ibctrl_lbuf_retire_vld = lbuf_active && !fifo_full_stall && !idu_stall`，
  只有下游可接收时才推进 LBUF；
- `lbuf_pcfifo_if_create_select=1`，PCFIFO 的条件分支元数据改从 LBUF 路径产生；
- `lbuf_bht_active_state=1`，BHT 的投机历史更新改用 LBUF 分支事件；
- `lbuf_addrgen_active_state=1`，普通 ADDRGEN 分支改流计算被屏蔽；
- `lbuf_ipdp_lbuf_active=1`，正常 IP 流水的 vtype 更新被抑制，必要的保留向量
  元数据改由 LBUF 回送。

`lbuf_pcgen_active` 确实等于 ACTIVE，但在 PCGEN 中直接可见的用途是参与
I-Cache invalidation 完成后的 LBUF flush 条件；不能把它解释成“PCGEN 一定停止
计算下一地址”。真正用于取消切换拍 IF/IP 有效事务的是
`lbuf_pcgen_vld_mask`。

### 10.3 change-flow 的时序

LBUF 有三类已寄存的 change-flow：

| 来源 | 目标 PC | `chgflw_pred`/way mask | 目的 |
|------|---------|-------------------------|------|
| FILL/FRONT_FILL 完成，或 IDLE 命中 filled 项 | 回边 taken 目标，即循环头 | `00` | 停止/取消常规取指侧的既有流，准备转入 LBUF |
| ACTIVE 预测回边 not-taken | 回边顺序下一条 | `11` | 退出 LBUF，恢复正常取指 |
| ACTIVE 遇到尚未填充的前向分支体 | 前向分支顺序下一条 | `11` | 启动正常取指以补填缺失路径 |

三类 valid 都先形成 `*_vld_pre`，再由 `lbuf_chgflw_clk` 寄存一拍。若
`lbuf_flush` 或更高优先级的 `iu_ifu_chgflw_vld` 到来，待发送的 LBUF change-flow
valid 会被清零，避免较旧的 LBUF 预测覆盖执行级恢复。

以正常 FILL 完成为例：

```
周期 T：   lbuf 处于 FILL/FRONT_FILL 状态，检测到 back_br_hit_lbuf_end
           → lbuf_stop_fetch_chgflw_vld_pre 置高
           → lbuf_addrgen_chgflw_mask = 1（告知 addrgen 本周期的取指地址无效）

周期 T+1： lbuf_stop_fetch_chgflw_vld 寄存器锁存
           → lbuf_ibctrl_chgflw_vld = 1
           → lbuf_ibctrl_chgflw_pc = back_br_tar_pc（循环起始 PC）
           → ibctrl 选择该 PC 和 way mask=00
           → 同一时钟沿后，lbuf 状态已经由 FILL 变为 CACHE

周期 T+N： IBUF 排空（ibuf_empty = 1）
           → 状态机 CACHE → ACTIVE
           → lbuf 开始向 ibdp 供指
```

### 10.4 退出 lbuf 时的切换

当预测循环退出（`lbuf_pop_not_taken_back_br`）时：

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

若 ACTIVE 期间收到 I-Cache invalidation 请求，`active_ctc_record` 会置位；只有
该记录存在时，退出拍的 `active_idle_chgflw_vld` 才额外形成
`lbuf_ibctrl_active_idle_flush`，清除旧 LBUF 内容。

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
    loop_buffer_full ||    // 4 位 Entry 位置相加发生回绕
    loop_end_br_not_taken || // 记录的循环结束回边本次预测不跳
    front_br_check && front_br_oversize  // 前向分支偏移超界
);
```

| 退化条件 | 原因 |
|----------|------|
| `inst_other_chgflw` | 当前有效半字中出现 IBDP 标记的非条件分支改流；LBUF 只有一个前向条件分支和一个回边目标槽 |
| `inst_auipc` | 当前有效半字中出现 AUIPC；本实现保守地拒绝该 PC-relative 指令，不能推导成“每次迭代 PC 不同” |
| `back_br_not_loop_end` | 出现后向条件分支，但 PC 不是记录的循环结束回边；可能是嵌套或其他复杂控制流 |
| `front_br_more_than_one` | 已有 `front_entry_vld` 后又看到前向条件分支；一个 LBUF 实例只保存一个前向分支 |
| `loop_buffer_full` | 4 位 Entry 位置加本拍半字数后数值变小；任何模 16 回绕都失败，包括累计恰好跨到 16 的边界 |
| `loop_end_br_not_taken` | 再次到达记录的循环结束回边，但本次预测 not-taken，当前填充不能形成可重放的 taken 迭代 |
| `front_br_oversize` | 偏移不在 4 位范围、目标计算回绕，或目标超过 `back_entry_start_num` |

`fill_not_under_rule` 决定 FSM 下一状态和 Record FIFO ban，但没有反向组合屏蔽同拍
的 `entry_create`。所以失败拍仍可能在波形中看到若干 Entry payload/valid 被写入、
create pointer 推进；状态随后回 IDLE，当前 new 记录被 ban，这些部分数据不会被
当作一个成功循环重放。调试时应以“状态 + record ban/filled + Entry valid”联合
判断，不能仅凭某个 Entry 被写过就认定填充成功。

### 11.2 front_fill_not_under_rule——前向分支体填充放弃

```verilog
// ct_ifu_lbuf.v: 1466-1472 行
assign front_fill_not_under_rule = lbuf_create_vld && (
    inst_other_chgflw ||
    inst_auipc        ||
    front_fill_con_br_check   // FRONT_FILL 时遇到了新的条件分支
) ||
back_br_hit_not_jump_lbuf_end; // 到达记录的循环结束回边但预测不跳
```

前三项只在 `lbuf_create_vld=1` 时检查；最后一项在表达式括号外，即使本拍没有
最终 create，只要相关回边信息满足也能使 FRONT_FILL 放弃。`front_fill_con_br_check`
会按 `front_vld_mask` 和 h0 对齐情况只检查仍需补填的那部分半字。

### 11.3 Ban 机制——外层循环保护内层循环

当一个新回边候选形成后，RTL 暂存它的分支 PC 和目标 PC。若 old 槽的回边 PC
严格位于新候选的 `[target_pc, branch_pc]` 区间内，说明新候选是包住旧候选的
外层循环：

```verilog
// ct_ifu_lbuf.v: 1952-1955 行
assign new_record_entry_out_loop = record_fifo_update_flop &&
                                   old_entry_valid &&
                                   (old_entry_pc < new_record_cur_pc) &&     // 旧 PC 在新循环范围内
                                   (old_entry_pc > new_record_target_pc);    // 旧 PC 在新循环范围内
```

此时被置 ban 的是**新回边所在的 new 槽**，不是旧的内层循环槽。RTL 注释说明
其设计意图是防止填充外层循环时冲掉内层循环；但判定方程只检查
`old_entry_valid`，没有额外要求 `old_entry_filled`，文档不能擅自收窄成“仅保护
已填充内层循环”。相同的 ban 更新通路还用于标记 FILL/FRONT_FILL 期间违反规则
的当前 new 槽。被 ban 的槽不能触发 FILL 或 CACHE，直到后续
`record_fifo_update` 覆盖该槽并把 ban 清零。

### 11.4 与 I-Cache Miss 的关系

FILL/FRONT_FILL 的数据来自正常 IF/IP/IB 路径，所以该阶段仍依赖 I-Cache 和
前端返回。如果 I-Cache miss 使 IB 没有可接受数据，
`ibctrl_lbuf_create_vld`/`lbuf_create_vld` 不成立，状态保持在填充态，pointer 和
Entry 数不会功能性推进。

ACTIVE 时，**送往 IBDP 的当前循环指令**来自 LBUF，因而其供给不以当前拍
I-Cache 返回为前提。RTL 没有把 `lbuf_active` 直接连接成 I-Cache SRAM 的全局
关闭信号，所以不能写成“I-Cache 访问完全停止”或据此断言物理上绝无 miss 事务。
性能分析时可以说 LBUF 指令供给对正常 I-Cache 返回解耦；功耗和后台活动则必须
看 IFCTRL、IPCTRL、SRAM 门控波形或门级实现。

---

## 12. 接口信号汇总

### 12.1 主要输入信号

| 信号 | 来源 | 说明 |
|------|------|------|
| `ibctrl_lbuf_create_vld` | IBCTRL | IB 包满足基本接收条件；LBUF 内部还会用 FILL/FRONT_FILL 状态限定最终 create |
| `ibctrl_lbuf_flush` | IBCTRL | 清除 LBUF 功能状态和各 valid |
| `ibctrl_lbuf_bju_mispred` | IBCTRL | 直接连接 IU change-flow 路径，使 FSM 回 IDLE |
| `ibctrl_lbuf_retire_vld` | IBCTRL | ACTIVE 且 IDU/PCFIFO 允许时，接受本拍 LBUF 输出并推进 |
| `ibdp_lbuf_h0_data`、`h1_data`...`h8_data` | IBDP | 最多 9 个候选 half-word 数据 |
| `ibdp_lbuf_h0_*`、`ibdp_lbuf_hn_*` | IBDP | half-word valid、长度、分支、fence、断点、AUIPC 和保留向量属性 |
| `ibdp_lbuf_con_br_cur_pc` | IBDP | 条件分支内部半字 PC |
| `ibdp_lbuf_con_br_offset` | IBDP | 21 位架构字节偏移；LBUF 使用符号扩展后的 `[20:1]` |
| `ibdp_lbuf_con_br_taken` | IBDP | `ibdp_bht_result`，即本次前端预测方向 |
| `ibdp_lbuf_bht_sel_array_result` | IBDP | 与当前条件分支对齐的 2 位 selector |
| `bht_lbuf_pre_taken_result` / `pre_ntaken_result` | BHT | 两个 bi-mode bank 的 32 位计数器行 |
| `bht_lbuf_vghr` | BHT | 22 位投机全局历史 VGHR；不是“向量 GHR” |
| `iu_ifu_bht_check_vld/condbr_taken/cur_pc` | IU | 执行反馈，用于更新 LBUF 保存的 selector |
| `ibuf_lbuf_empty` | IBUF | 正常路径是否已经排空 |
| `ifctrl_lbuf_ins_inv_on/inv_req` | IFCTRL | I-Cache invalidation 正在进行/请求，用于阻止激活或延迟清理 |
| `cp0_ifu_lbuf_en` | CP0 | LBUF 功能使能 |

### 12.2 主要输出信号

| 信号 | 目的地 | 说明 |
|------|--------|------|
| `lbuf_ibctrl_lbuf_active` | ibctrl | lbuf 处于 ACTIVE 状态 |
| `lbuf_ibctrl_stall` | ibctrl | 请求 ibctrl 暂停新指令进入 IBUF |
| `lbuf_ibctrl_chgflw_vld` | ibctrl | 触发一次 change-flow |
| `lbuf_ibctrl_chgflw_pc` | ibctrl | change-flow 的 39 位内部半字目标 PC |
| `lbuf_ibctrl_chgflw_pred` | ibctrl | change-flow 后的 I-Cache way prediction mask，不是分支方向 |
| `lbuf_ibctrl_active_idle_flush` | ibctrl | ACTIVE 期间记录过 invalidation 请求时，在退出 change-flow 后请求清理 |
| `lbuf_ibdp_inst0/1/2` | ibdp | 向 IB 级输出的指令数据 |
| `lbuf_ibdp_inst0/1/2_valid` | ibdp | 各条输出指令的有效性 |
| `lbuf_ibdp_inst0/1/2_pc` | ibdp | 内部半字 PC 低 15 位，对应架构字节 PC `[15:1]` |
| `lbuf_bht_active_state` | bht | 通知 BHT lbuf 处于 ACTIVE |
| `lbuf_bht_con_br_vld/taken` | bht | 报告当前交付的最老条件分支及其预测方向，推进投机历史 |
| `lbuf_addrgen_active_state` | addrgen | ACTIVE 状态，禁止普通 branch_vld_for_gateclk |
| `lbuf_addrgen_cache_state` | addrgen | 仅 CACHE 状态，禁止普通 branch_vld_for_gateclk |
| `lbuf_addrgen_chgflw_mask` | addrgen | 在 stop-fetch 切换拍屏蔽普通 ADDRGEN change-flow |
| `lbuf_pcfifo_if_*` | PCFIFO_IF | ACTIVE 时提供条件分支 PC、VGHR、预测计数器和 selector |
| `lbuf_ipdp_lbuf_active/vtype_updt_*` | IPDP | 切换正常/LBUF 的保留向量状态更新来源 |
| `lbuf_pcgen_active` | pcgen | ACTIVE 状态指示；直接可见用途之一是 invalidation flush 条件 |
| `lbuf_pcgen_vld_mask` | pcgen | LBUF 数据源切换拍取消 IF/IP 流水有效事务 |
| `lbuf_debug_st` | 调试 | FSM 编码：IDLE=`000000`，其余六状态独热 |

### 12.3 用波形验证 LBUF 的方法

不要只看 `lbuf_debug_st` 是否进入 ACTIVE。LBUF 的正确性来自多组状态保持一致，
建议按下面的因果链观察。

**1. 候选是否正确建立**

```text
ibctrl_lbuf_create_vld
hn_con_br / con_br_offset / con_br_taken
back_br_pc / back_br_tar_pc / back_br_offset
record_fifo_update / record_fifo_bit
record_fifo_entry{0,1}_{valid,pc,offset,filled,ban}
```

第一次合法回边应只更新候选；后续 PC 命中 unfilled 候选才出现
`fill_state_enter`。把内部 PC 左移一位、把内部 signed offset 乘 2 后，应能还原
反汇编中的分支 PC 和字节目标。

**2. 填充是否按程序路径推进**

```text
lbuf_create_vld / half_vld_num / hn_create_vld
lbuf_create_pointer / create_pointer_pre
entry_create / entry_vld
lbuf_cur_entry_num
front_br_under_rule / back_br_hit_lbuf_end
fill_not_under_rule / record_fifo_entry_ban_update
```

无 stall 的有效输入拍，create pointer 的旋转量应等于接受的 half-word 数。
出现 taken 前向分支时，pointer/逻辑位置应转到前向目标；再次到达记录的回边 PC
时才允许完成填充。

**3. 正常路径与 LBUF 是否有序交接**

```text
lbuf_ibctrl_stall / ibuf_lbuf_empty
lbuf_stop_fetch_chgflw_vld_pre / lbuf_stop_fetch_chgflw_vld
lbuf_pcgen_vld_mask / lbuf_addrgen_chgflw_mask
lbuf_ibctrl_lbuf_active
```

应先看到 stop-fetch/change-flow 和 CACHE stall，再看到 IBUF empty，最后才进入
ACTIVE。若 ACTIVE 在 IBUF 非空时出现，要优先检查状态转移或 `ins_inv_on` 条件。

**4. 重放宽度、反压和分支是否一致**

```text
ibctrl_lbuf_retire_vld
lbuf_retire_pointer / lbuf_cur_pc
lbuf_ibdp_inst{0,1,2}_valid
lbuf_pop{1,2,3}_half_num
lbuf_pop_inst{0,1,2}_{front_br,back_br}
inst{0,1,2}_bht_result / lbuf_pop_branch_vld
```

`ibctrl_lbuf_retire_vld=0` 时 pointer 和 PC 都应保持。有效推进时，顺序路径的 PC
增量应等于实际交付到最老分支为止的 half-word 数；预测 taken 时 pointer 和 PC
应同时跳到同一个前向目标或循环头。最老分支之后的 `inst_valid` 必须被屏蔽。

**5. 区分预测退出与执行恢复**

```text
lbuf_pop_not_taken_back_br
active_idle_chgflw_vld_pre / active_idle_chgflw_vld
lbuf_ibctrl_chgflw_pc / lbuf_ibctrl_chgflw_pred
iu_ifu_bht_check_vld / iu_ifu_bht_condbr_taken
ibctrl_lbuf_bju_mispred
```

预测退出先使 ACTIVE 转 IDLE，寄存后的 change-flow 再恢复正常取指。
`chgflw_pred` 要按 way mask 看。若实际方向不同，应随后看到 IU change-flow 使
LBUF FSM 回 IDLE；不能把前端预测信号当作最终执行结果。

---

## 附录：关键信号时序示例

以下示例假设循环运行次数足以先完成候选记录和填充；进入 ACTIVE 后，再观察三轮
LBUF 重放，并在第三轮预测退出。实际周期数还会受到取指包边界、IBUF 排空、
IDU stall 和 PCFIFO 状态影响。

```
假设循环：
  loop_start(PC=0x1000): ...指令A(16位)...
  0x1002:                ...指令B(32位)...
  0x1006:                beq x1,x2,-6  // 字节偏移 -6，即半字偏移 -3

时间轴：
T=0: 正常取指，beq 指令到达 IB 级，ibdp_lbuf_con_br_* 有效
     → con_br_offset=-3(半字), back_br_offset=3(回跳距离), PC=0x1006
     → record_fifo_update=1, 写入 Entry0：pc=0x1006, offset=3
     → record_fifo_bit 翻转，新项=Entry0
     → 状态机仍在 IDLE

T=1~N: 同一循环再次执行，beq 再次到达，命中 Entry0（pc匹配，filled=0）
     → back_br_hit_record_fifo_unfill=1
     → 状态机 IDLE → FILL
     → fill_state_enter=1, lbuf_create_pointer 复位到 Entry[0]
     → back_entry_start_num = 3（循环结束分支应从 Entry[3] 开始）

T=FILL: 指令A(h0)、指令B(h1,h2)、beq(h3,h4) 进入 lbuf
     → Entry[0] = 指令A的低16位, Entry[1]=指令B低16位, Entry[2]=指令B高16位
     → Entry[3]=beq低16位, Entry[4]=beq高16位
     → back_br_hit_lbuf_end=1 (beq的PC=0x1006=new_entry_pc)
     → 状态机 FILL → CACHE
     → lbuf_stop_fetch_chgflw_vld_pre=1
     → Record FIFO 当前 new 槽的 filled 位被置 1

T=CACHE: lbuf_ibctrl_stall=1, 等待 IBUF 排空
     → ibuf_empty=1
     → 状态机 CACHE → ACTIVE
     → lbuf_cur_pc 更新为 back_br_tar_pc = 0x1000

T=ACTIVE 第1轮:
     retire ptr = Entry[0]
     同一拍可组织：
       inst0=指令A(pc=0x1000)
       inst1=指令B(pc=0x1002)
       inst2=beq   (pc=0x1006)
     back_br_bht_result=1（BHT 预测跳转）
     → retire ptr 跳回 Entry[0]（循环起始）
     → lbuf_cur_pc 跳回 0x1000

T=ACTIVE 第2轮: 类似第1轮

T=ACTIVE 第3轮:
     同一拍再次组织 A、B、beq
     back_br_bht_result=0（BHT 预测不跳，循环结束）
     → lbuf_pop_not_taken_back_br=1
     → active_idle_chgflw_vld_pre=1
     → 时钟沿后状态机 ACTIVE → IDLE，并锁存 change-flow

T=下一拍:
     → lbuf_ibctrl_chgflw_vld=1
     → 内部半字 PC：0x803 + 2 = 0x805
     → 恢复为架构字节地址：0x805 << 1 = 0x100A
     → ibctrl 从 32 位 beq 的顺序下一条 0x100A 恢复正常取指
```

---

*文档编写基于 RTL 源代码 `ct_ifu_lbuf.v` 的逐行分析，如有疑问请对照相应行号查阅源码。*
