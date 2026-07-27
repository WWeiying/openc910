# C910 IFU IBUF 模块详解

**RTL 文件**：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ibuf.v`（9622 行）

---

## 目录

1. [模块概述与设计动机](#1-模块概述与设计动机)
2. [Entry 结构详解](#2-entry-结构详解)
3. [队列管理：指针与计数](#3-队列管理指针与计数)
4. [写入逻辑（Create）](#4-写入逻辑create)
5. [Bypass 直通路径](#5-bypass-直通路径)
6. [读出逻辑（Retire / Pop）](#6-读出逻辑retire--pop)
7. [Merge 操作](#7-merge-操作)
8. [特殊指令标记](#8-特殊指令标记)
9. [异常信息维护](#9-异常信息维护)
10. [Flush 逻辑](#10-flush-逻辑)
11. [向 IDU 的输出](#11-向-idu-的输出)
12. [关键时序与设计权衡](#12-关键时序与设计权衡)

---

## 1. 模块概述与设计动机

### 1.1 IBUF 在 IFU 中的位置

```
取指单元(IFU)流水线：

  [IP/PC生成] → [ICache访存] → [ibdp预译码] → [IBUF] → [IDU译码]
                                                  ↑
                                          ct_ifu_ibuf.v
```

IBUF（Instruction Buffer，指令缓冲）是 IFU 与 IDU（Instruction Decode Unit）之间的弹性缓冲区。它的核心作用是：**解耦取指速率与译码速率**。

取指侧的供给速率是不均匀的：Cache Miss 时停顿多个周期，命中时一次可以带回一整个 Cache 行的数据（最多 9 个 half-word，即 4.5 条 32 位指令）。而 IDU 每周期最多消费 3 条指令。两端速率的不匹配若无缓冲，必然导致频繁的流水线停顿。

IBUF 以 FIFO 方式缓存从 ICache 取回、经过 ibdp 预译码后的指令流，平滑两侧速率差异。

### 1.2 容量设计考量

IBUF 共有 **32 个 Entry**，但这里需要澄清一个重要概念：每个 Entry 存储的是**一个 16 位 half-word**，而非一条完整指令。这是因为 C910 支持 RISC-V 的 C 扩展（16 位压缩指令），指令边界对齐到 16 位。

32 个 Entry 意味着最多可以缓存 32 个 half-word，即最多约 16 条 32 位指令（或更多条 16 位压缩指令）。

实际上，代码中的注释揭示了背后的设计逻辑：

```verilog
// Line 3447~3451
assign ibuf_full = |({ibuf_create_pointer[ENTRY_NUM-9:0],
                     ibuf_create_pointer[ENTRY_NUM-1:ENTRY_NUM-8]} &
                     entry_vld[31:0]);
```

每次写入最多 9 个 half-word（`ibdp_ibuf_half_vld_num` 最大为 9），所以满判断检查下一次写入的 9 个位置是否已有有效项。32 个 Entry 能确保在 IDU 停顿多个周期时不丢失已取到的指令数据。

### 1.3 端口设计总览

| 方向 | 接口来源 | 主要信号 |
|------|----------|----------|
| 输入 | ibctrl   | `ibctrl_ibuf_create_vld`、`ibctrl_ibuf_retire_vld`、`ibctrl_ibuf_flush`、`ibctrl_ibuf_merge_vld`、`ibctrl_ibuf_bypass_not_select` |
| 输入 | ibdp     | `ibdp_ibuf_h0~h8_data/pc/vl/vlmul/vsew`（9个half-word数据）<br>`ibdp_ibuf_hn_vld[7:0]`（各half-word有效位）<br>各 half-word 的异常、断点、fence 等标记 |
| 输出 | → ibdp   | `ibuf_ibdp_inst0/1/2_*`（非bypass通路的3条指令）<br>`ibuf_ibdp_bypass_inst0/1/2_*`（bypass通路的3条指令） |
| 输出 | → ibctrl | `ibuf_ibctrl_empty`、`ibuf_ibctrl_stall`（full时反压） |

注意：IBUF 同时维护两套输出通路：**stored 通路**（从 IBUF 内存储的 entry 中读取）和 **bypass 通路**（直接将本周期取到的指令送出）。

---

## 2. Entry 结构详解

### 2.1 每个 Entry 存储什么

IBUF 由 32 个 `ct_ifu_ibuf_entry` 子模块实例化而成。每个 Entry 存储：

| 字段 | 宽度 | 含义 |
|------|------|------|
| `entry_vld` | 1 | 该 Entry 是否有效 |
| `entry_inst_data` | 16 | 一个 half-word 的指令数据 |
| `entry_pc` | 15 | 该 half-word 的 PC 低 15 位（高位由 ibdp 重建） |
| `entry_32_start` | 1 | 该 half-word 是否是一条 32 位指令的起始半字 |
| `entry_acc_err` | 1 | 访问错误标记 |
| `entry_pgflt` | 1 | 页故障标记 |
| `entry_high_expt` | 1 | 高优先级异常标记 |
| `entry_fence` | 1 | fence/fence.i 指令标记 |
| `entry_split0` | 1 | 向量指令 split 标记 0 |
| `entry_split1` | 1 | 向量指令 split 标记 1 |
| `entry_bkpta` | 1 | 硬件断点 A 命中 |
| `entry_bkptb` | 1 | 硬件断点 B 命中 |
| `entry_no_spec` | 1 | 不可推测执行标记 |
| `entry_vl_pred` | 1 | 向量长度预测标记（vsetvli 相关） |
| `entry_vl` | 8 | 向量长度寄存器值（vl） |
| `entry_vlmul` | 2 | 向量 LMUL 字段 |
| `entry_vsew` | 3 | 向量 SEW（单元素宽度）字段 |

### 2.2 为什么 Entry 以 half-word 为单位

RISC-V 支持压缩指令（C 扩展），指令长度可以是 16 位或 32 位，且两者可以混合出现，指令边界只保证 2 字节对齐。因此，IBUF 采用 16 位为基本粒度，保留灵活性：

- 一条 16 位压缩指令：占用 1 个 Entry
- 一条 32 位普通指令：占用 2 个相邻 Entry（`entry_32_start` 标记第一个 half-word）

这种设计允许每周期最多输出 3 条逻辑指令，无论是 16 位还是 32 位，读出逻辑都可以通过检查 `pop_hn_32_start` 来决定如何拼接相邻 Entry 的数据形成完整的 32 位指令字。

### 2.3 Entry 数据写入的特殊机制

Entry 的数据写入分为两类时钟域：

```verilog
// 行 3644~3646
assign entry_data_create[31:0] = entry_create_pre[31:0] & {32{~ibuf_full}} & {32{ibctrl_ibuf_data_vld}};
assign entry_data_create_clk_en[31:0] = entry_create_bypass_pre[31:0] | 
                                        entry_create_nopass_pre_for_gateclk[31:0];
```

- `entry_data_create`：真正触发数据写入的使能（需要非 full 且数据有效）
- `entry_vld_create_clk_en`：vld 位的时钟使能（覆盖更广，不需要数据有效判断）
- `entry_pc_create`：PC 数据写入（仅在 ldst 指令时需要存储 PC 以便计算地址，通过 `ib_hn_ldst` 过滤以节省功耗）

---

## 3. 队列管理：指针与计数

### 3.1 两套管理机制

IBUF 同时维护两套机制来管理 FIFO 状态：

1. **One-hot 循环指针**：`ibuf_create_pointer[31:0]` 和 `ibuf_retire_pointer[31:0]`，用于精确指向写入/读出的 Entry
2. **循环计数器**：`ibuf_create_num[4:0]` 和 `ibuf_retire_num[4:0]`，用于 full/empty 判断

### 3.2 One-hot 指针机制

写指针 `ibuf_create_pointer` 是一个 32 位 one-hot 编码的循环移位寄存器：

```verilog
// 行 3261~3273
always @(posedge ibuf_create_pointer_update_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    ibuf_create_pointer[ENTRY_NUM-1:0] <= {{(ENTRY_NUM-1){1'b0}}, 1'b1};
  else if(ibuf_flush)
    ibuf_create_pointer[ENTRY_NUM-1:0] <= {{(ENTRY_NUM-1){1'b0}}, 1'b1};
  else if(ibuf_create_vld)
    ibuf_create_pointer[ENTRY_NUM-1:0] <= create_pointer_pre[ENTRY_NUM-1:0];
  else
    ibuf_create_pointer[ENTRY_NUM-1:0] <= ibuf_create_pointer[ENTRY_NUM-1:0];
end
```

复位后指针从 Entry 0 开始（`32'h0000_0001`），每次创建后按写入的 half-word 数量循环左移：

```verilog
// 行 3198~3220：create_pointer_pre 的计算
case(ibdp_ibuf_half_vld_num[3:0])
  4'b0001 : create_pointer_pre = {ibuf_create_pointer[30:0], ibuf_create_pointer[31]};  // 左移1
  4'b0010 : create_pointer_pre = {ibuf_create_pointer[29:0], ibuf_create_pointer[31:30]};// 左移2
  // ... 以此类推，最大左移9位
  4'b1001 : create_pointer_pre = {ibuf_create_pointer[22:0], ibuf_create_pointer[31:23]};
  default : create_pointer_pre = ibuf_create_pointer[31:0];
endcase
```

**为什么用 one-hot 而不是二进制计数器？**

One-hot 指针的优势在于：
1. 选择某个 Entry 时无需译码，直接用指针对应位作为使能：`entry_create[n] = create_pointer[n] & ibuf_create_vld`
2. 同时需要指向 9 个连续 Entry（每次最多写入 9 个 half-word），通过预计算 9 个移位版本 `ibuf_create_pointer0~8` 并行生成即可，不需要加法器

### 3.3 预生成多个指针版本

为了同时向多个 Entry 写入数据，代码预生成了 9 个指针版本：

```verilog
// 行 3422~3438
assign ibuf_create_pointer0[31:0] = ibuf_create_pointer[31:0];
assign ibuf_create_pointer1[31:0] = {ibuf_create_pointer[30:0], ibuf_create_pointer[31]};
assign ibuf_create_pointer2[31:0] = {ibuf_create_pointer[29:0], ibuf_create_pointer[31:30]};
// ...
assign ibuf_create_pointer8[31:0] = {ibuf_create_pointer[22:0], ibuf_create_pointer[31:23]};
```

类似地，读出侧也有 6 个版本（最多读出 6 个 half-word）：`ibuf_retire_pointer0~5`。

### 3.4 计数器机制与 Full/Empty 判断

```verilog
// 行 3417~3452
// bypass_vld：IBUF 空时走直通路径
assign bypass_vld = (ibuf_create_num[4:0] == ibuf_retire_num[4:0]) &&
                     !ibctrl_ibuf_bypass_not_select;

// ibuf_full：下一次写入位置已有有效项
assign ibuf_full = |({ibuf_create_pointer[ENTRY_NUM-9:0],
                     ibuf_create_pointer[ENTRY_NUM-1:ENTRY_NUM-8]} & 
                     entry_vld[31:0]);

// ibuf_empty：create_num == retire_num 且 entry_vld[0] 为 0
assign ibuf_empty = (ibuf_create_num[4:0] == ibuf_retire_num[4:0]) && 
                    !entry_vld[0];
```

**为什么 empty 判断需要额外检查 `entry_vld[0]`？**

`create_num` 是模 32 的循环计数器（5 位）。当 IBUF 恰好有 32 个 Entry 全部有效时，`create_num` 也等于 `retire_num`（两个都绕回到相同的余数）。此时不是 empty 而是 full。额外检查 `entry_vld[0]`（当前读指针指向的 Entry 是否有效）来区分这两种情况。这是 5 位模 32 计数器面对 32 项 FIFO 时的经典边界问题。

**计数器更新逻辑**

`create_num` 在 create 时递增（增加量等于写入的 half-word 数），在 bypass 时减去 bypass 消耗的数量；`retire_num` 在 retire 时递增：

```verilog
// 行 3334~3347：create_num_pre 的计算
case(ibdp_ibuf_half_vld_num[3:0])
  4'b0001 : create_num_pre = ibuf_create_num + 5'd1;
  4'b0010 : create_num_pre = ibuf_create_num + 5'd2;
  // ...
  4'b1001 : create_num_pre = ibuf_create_num + 5'd9;
  default : create_num_pre = ibuf_create_num;
endcase

// bypass 时需要从 create_num 中减去 bypass 走的 half-word 数
case({bypass_way_inst2_valid, bypass_way_half_num[2:0]})
  4'b1011 : create_num_pre_bypass = create_num_pre - 5'd3;
  4'b1100 : create_num_pre_bypass = create_num_pre - 5'd4;
  // ...
endcase
```

---

## 4. 写入逻辑（Create）

### 4.1 触发条件

```verilog
// 行 3411~3413
assign ibuf_create_vld = ibctrl_ibuf_create_vld;
assign ibuf_flush      = ibctrl_ibuf_flush;
```

写入由 `ibctrl_ibuf_create_vld` 触发，这个信号来自 ibctrl 模块，在取指流水线将数据推送到 ibuf 时置高。

### 4.2 写入哪些 Entry

每个 half-word 写入哪个 Entry，由 `ibuf_create_pointer0~8` 中的对应位决定。对于 Entry n，其 create 使能为：

```verilog
// 行 3586~3637 的逻辑核心
assign entry_create_nopass_pre[31:0] =
    (ibuf_create_pointer0[31:0] & {32{ib_hn_create_vld[8]}} & {32{ibuf_nopass_merge_mask[8]}}) |
    (ibuf_create_pointer1[31:0] & {32{ib_hn_create_vld[7]}} & {32{ibuf_nopass_merge_mask[7]}}) |
    // ...（9个 half-word 各一项）
    (ibuf_create_pointer8[31:0] & {32{ib_hn_create_vld[0]}} & {32{ibuf_nopass_merge_mask[0]}});

assign entry_create[31:0] = entry_create_pre[31:0] & {32{ibuf_create_vld}};
```

`ibuf_nopass_merge_mask` 是 merge 操作的屏蔽信号，在 merge 场景下会屏蔽掉已被 bypass 送出的 half-word（避免重复写入）。

### 4.3 写入内容：半字数据的分配

每个 Entry 中的 `entry_inst_data_n` 由写入时对应的 half-word 数据填入：

```verilog
// 行 3793~3801：Entry 0 的数据选择
assign entry_create_inst_data_0[15:0] =
    ({16{ibuf_create_pointer0[0]}} & ib_h0_data[15:0]) |  // 第0个half-word写入Entry 0
    ({16{ibuf_create_pointer1[0]}} & ib_h1_data[15:0]) |  // 第1个half-word写入Entry 0
    ({16{ibuf_create_pointer2[0]}} & ib_h2_data[15:0]) |
    // ...
    ({16{ibuf_create_pointer8[0]}} & ib_h8_data[15:0]);
```

逻辑含义：对于 Entry 0，如果写指针的第 0 位（`ibuf_create_pointer0[0]`）为 1，说明第 0 个 half-word 应该写入 Entry 0，则选择 `ib_h0_data`；以此类推。

同样的模式用于写入 PC、vl、vlmul、vsew 等所有随路数据。

### 4.4 ib_hn_create_vld 的生成

从 ibdp 来的数据有个特殊之处：`ibdp_ibuf_h0_vld` 指示是否有一个"特殊的"第 0 个 half-word。

```verilog
// 行 7560~7562
assign ib_hn_create_vld[8:0] = (ibdp_ibuf_h0_vld)
                             ? ({ibdp_ibuf_h0_vld, ibdp_ibuf_hn_vld[7:0]})
                             : ({ibdp_ibuf_hn_vld[7:0], 1'b0});
```

当 `ibdp_ibuf_h0_vld=1` 时，h0 是一个独立的"特殊指令"（比如从跨 Cache 行拼接中剩余的半字），它排在 h1~h7 之前，共 9 个 half-word（h0~h8）。当 `ibdp_ibuf_h0_vld=0` 时，只有 h1~h8 最多 8 个 half-word 参与写入，h0 位置移入低位 0 填充。

这个设计使得 IBUF 能够正确处理跨 Cache 行的 32 位指令场景。

---

## 5. Bypass 直通路径

### 5.1 设计动机

在流水线运行稳定、IDU 不停顿（无 stall）且 IBUF 恰好为空的情况下，如果让取回的指令先进入 IBUF 再在下一周期读出，会白白增加 1 周期的 latency。Bypass 路径解决了这个问题：当 IBUF 为空且 IDU 不阻塞时，新取回的指令**跳过 IBUF，直接送往 IDU**。

### 5.2 触发条件

```verilog
// 行 3417~3419
assign bypass_vld = (ibuf_create_num[4:0] == ibuf_retire_num[4:0]) &&
                     !ibctrl_ibuf_bypass_not_select;
```

两个条件同时满足：
1. `ibuf_create_num == ibuf_retire_num`：IBUF 为空（create 和 retire 计数相等）
2. `!ibctrl_ibuf_bypass_not_select`：ibctrl 允许 bypass（IDU 无 stall，BJ 单元无误预测冲刷等）

### 5.3 Bypass 路径的数据流

Bypass 路径使用与读出 IBUF 内容时相同的数据格式，但数据来源是本周期的输入：

```verilog
// 行 8425~8516（简化）
// bypass 路径直接使用 ib_hn_* 信号（本周期的新数据）
assign bypass_way_h0_vld  = (ibdp_ibuf_h0_vld) ? ibdp_ibuf_h0_vld : ibdp_ibuf_hn_vld[7];
assign bypass_way_h0_data = ib_h0_data[15:0];
assign bypass_way_h0_pc   = ib_h0_pc[14:0];
// ...
```

Bypass 路径同样需要根据 `bypass_way_h0~4_32_start` 把相邻的 half-word 拼接成 32 位指令，逻辑与 pop 路径完全相同（见第 8663 行起的 `casez` 语句）。

### 5.4 Bypass 与同周期写入的协调

当 bypass 发生时，IBUF 内部同时有一个"选择性写入"：从 9 个新到的 half-word 中，被 bypass 路径消耗的那 3~6 个 half-word **不写入 IBUF**（通过 `ibuf_nopass_merge_mask` 屏蔽），只有剩余的写入 IBUF。

```verilog
// 行 3634~3636
assign entry_create_pre[31:0] = (bypass_vld)
                              ? entry_create_bypass_pre[31:0]    // bypass时：只写未消耗的
                              : entry_create_nopass_pre[31:0];   // 普通时：全部写入
```

对应地，`create_num` 也只累加实际写入 IBUF 的数量（减去 bypass 消耗量）。retire 指针同样需要更新到 bypass 消耗之后的位置（行 3545~3546）。

### 5.5 Bypass 路径的时延优势

```
普通路径（通过 IBUF）：
  周期 N：取指 → ibdp 预译码 → 写入 IBUF
  周期 N+1：从 IBUF 读出 → 输出给 IDU

Bypass 路径（跳过 IBUF）：
  周期 N：取指 → ibdp 预译码 → 直接输出给 IDU（同周期）
```

Bypass 减少了 1 拍的指令传输延迟，对于高频执行的直线代码（无跳转、无 stall）有显著的性能提升。

---

## 6. 读出逻辑（Retire / Pop）

### 6.1 触发条件

```verilog
// 行 3552
assign ibuf_retire_vld = ibctrl_ibuf_retire_vld;
```

由 ibctrl 的 `retire_vld` 信号触发，代表 IDU 已准备好接收新指令。

### 6.2 读出哪些 Entry（retire pointer）

退出指针 `ibuf_retire_pointer` 也是 32 位 one-hot 格式，更新逻辑类似写指针：

```verilog
// 行 3537~3549
always @(posedge ibuf_retire_pointer_update_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    ibuf_retire_pointer <= {{(ENTRY_NUM-1){1'b0}}, 1'b1};
  else if(ibuf_flush)
    ibuf_retire_pointer <= {{(ENTRY_NUM-1){1'b0}}, 1'b1};
  else if(ibuf_retire_vld)
    ibuf_retire_pointer <= retire_pointer_pre;     // 正常退出
  else if(ibuf_create_vld && bypass_vld)
    ibuf_retire_pointer <= retire_pointer_pre_bypass;  // bypass 时也更新
  else
    ibuf_retire_pointer <= ibuf_retire_pointer;
end
```

### 6.3 Pop 数据读取：多路 Case 语句

读出时，需要从 32 个 Entry 中选出 `ibuf_retire_pointer` 指向的 Entry 数据。这通过一个 32 选 1 的 `case` 语句实现：

```verilog
// 行 5671~5721（pop_h0_data 的选择逻辑示例）
case(ibuf_retire_pointer0[31:0])
  32'h00000001 : pop_h0_data[15:0] = entry_inst_data_0[15:0];
  32'h00000002 : pop_h0_data[15:0] = entry_inst_data_1[15:0];
  // ...
  32'h80000000 : pop_h0_data[15:0] = entry_inst_data_31[15:0];
  default      : pop_h0_data[15:0] = {16{1'bx}};
endcase
```

需要同时读取 6 个连续 Entry 的数据（pop_h0~h5），所以有 6 套这样的 case 语句，分别使用 `ibuf_retire_pointer0~5`。

### 6.4 从 Half-word 到指令的拼接（Pop3 逻辑）

读出 6 个 half-word 后，还需要根据 `pop_h0~4_32_start` 标志，将它们拼接为最多 3 条完整指令。这是 IBUF 中最重要的组合逻辑之一：

```verilog
// 行 7918~8417（简化的 casez 逻辑）
casez({pop_h0_32_start, pop_h1_32_start, pop_h2_32_start,
       pop_h3_32_start, pop_h4_32_start})

  5'b000?? :  // 前3个都是16位指令
    inst0_data = {16'b0, pop_h0_data};  // 16位指令
    inst1_data = {16'b0, pop_h1_data};  // 16位指令
    inst2_data = {16'b0, pop_h2_data};  // 16位指令
    ibuf_pop3_half_num = 3'b011;        // 消耗3个half-word
    ibuf_pop3_retire_vld = 6'b111000;   // pop_h0~2有效

  5'b001?? :  // inst0=16位, inst1=16位, inst2=32位(h2+h3)
    inst0_data = {16'b0, pop_h0_data};
    inst1_data = {16'b0, pop_h1_data};
    inst2_data = {pop_h3_data, pop_h2_data};  // 拼接32位
    ibuf_pop3_half_num = 3'b100;         // 消耗4个half-word
    ibuf_pop3_retire_vld = 6'b111100;

  5'b01?0? :  // inst0=16位, inst1=32位(h1+h2), inst2=16位(h3)
    inst0_data = {16'b0, pop_h0_data};
    inst1_data = {pop_h2_data, pop_h1_data};  // 拼接32位
    inst2_data = {16'b0, pop_h3_data};
    ibuf_pop3_half_num = 3'b100;
    ibuf_pop3_retire_vld = 6'b111100;

  // ... 所有组合（7种情况）
  5'b1?1?1 :  // inst0=32位, inst1=32位, inst2=32位
    inst0_data = {pop_h1_data, pop_h0_data};
    inst1_data = {pop_h3_data, pop_h2_data};
    inst2_data = {pop_h5_data, pop_h4_data};
    ibuf_pop3_half_num = 3'b110;         // 消耗6个half-word
    ibuf_pop3_retire_vld = 6'b111111;

endcase
```

`ibuf_pop3_half_num` 记录本次读出消耗了多少个 half-word（3~6 个），用于更新 retire 指针；`ibuf_pop3_retire_vld[5:0]` 标记哪几个 half-word 被有效消耗（高 3 位对应 inst0~2 是否为 32 位）。

---

## 7. Merge 操作

### 7.1 什么是 Merge

Merge 是 IBUF 模块中一个精妙的优化设计。考虑以下场景：

- IBUF 中只剩 2 条有效指令（不足 3 条）
- 同一周期 ibdp 刚好送来了新的指令

如果不做特殊处理，IDU 本周期只能收到 2 条指令（IBUF 里的），下一周期才能收到新来的指令，吞吐率不足。

Merge 允许在**同一周期内**，将 IBUF 已有的不足 3 条指令和新来的 bypass 路径上的指令**合并**成 3 条一起送给 IDU，提高吞吐量。

### 7.2 Merge 的触发条件

```verilog
// 行 9391~9392
assign merge_way_inst0_sel   = !ibuf_pop_inst1_valid;
assign merge_way_inst0_valid = bypass_way_inst0_valid && ibctrl_ibuf_merge_vld;
```

- `merge_way_inst0_sel = !ibuf_pop_inst1_valid`：IBUF 读出的 inst1 无效（说明 IBUF 中不足 2 条指令可以填满 inst0+inst1 位置），此时 merge 才有意义
- `ibctrl_ibuf_merge_vld`：ibctrl 允许 merge（由系统级状态决定）

### 7.3 Merge 的数据选择

```verilog
// 行 9526~9561（输出选择逻辑）

// inst1 输出：优先从 IBUF 取，若 IBUF inst1 为空则用 merge（bypass）数据
assign ibuf_ibdp_inst1_valid = (merge_way_inst0_sel) ? merge_way_inst0_valid
                                                     : ibuf_pop_inst1_valid;
assign ibuf_ibdp_inst1[31:0] = (merge_way_inst0_sel) ? merge_way_inst0[31:0]
                                                     : ibuf_pop_inst1_data[31:0];

// inst2 输出：类似逻辑
assign ibuf_ibdp_inst2_valid = (merge_way_inst1_sel) ? merge_way_inst1_valid
                                                     : ibuf_pop_inst2_valid;
```

在 merge 场景下，IBUF 的 inst0 始终来自 IBUF 本身（从 stored path 读出），而 inst1/inst2 可能来自 bypass 路径上的新指令。

### 7.4 Merge 时 Entry 写入的屏蔽

Merge 发生时，已经通过 merge_way 送出的新指令不应再写入 IBUF（否则会造成重复执行）。这通过 `ibuf_nopass_merge_mask` 屏蔽信号实现：

```verilog
// 行 9492~9494
assign ibuf_nopass_merge_mask[8:0] =
    (ibctrl_ibuf_merge_vld && !ibuf_pop_inst2_valid && bypass_way_inst0_valid)
    ? merge_way_inst_mask[8:0]
    : 9'b111111111;  // 不 merge 时全部写入
```

`merge_way_inst_mask` 根据 merge 消耗了多少条指令（1~2 条），生成相应的屏蔽掩码（屏蔽对应的 half-word 不写 IBUF）。

---

## 8. 特殊指令标记

### 8.1 Breakpoint（断点）

每个 half-word 携带两个断点标记：

| 标记 | 含义 |
|------|------|
| `entry_bkpta` | 硬件断点 A 命中 |
| `entry_bkptb` | 硬件断点 B 命中 |

这两个标记由 ibdp 在预译码阶段通过地址比对硬件断点寄存器产生。IBUF 忠实保存并随指令流传递给 IDU，IDU 在译码时将其发送给调试模块（HAD，Hardware-Assisted Debug）。

```verilog
// 输入侧：ibdp 提供每个 half-word 的断点信息
input [7:0] ibdp_ibuf_hn_bkpta;        // 8个half-word各自的断点A标记
input       ibdp_ibuf_hn_bkpta_vld;    // 是否有断点A命中（至少一个）

// 输出侧：随每条指令一起送出
output ibuf_ibdp_inst0_bkpta;
output ibuf_ibdp_inst0_bkptb;
```

`hn_bkpta_vld` 是优化信号：只有在有断点命中时才触发特殊处理流程，避免无谓的功耗。

### 8.2 Fence / Fence.i

```verilog
input [7:0] ibdp_ibuf_hn_fence;
```

Fence 类指令（`fence`、`fence.i`）需要特殊处理：
- `fence`：存储屏障，需要确保之前的 store 完成后才能继续
- `fence.i`：指令 Cache 刷新，执行后需要重新取指

IBUF 保存 fence 标记并随指令传递给 IDU，IDU 会根据该标记发送特殊控制请求给相关子系统（ICache、DCache）。

### 8.3 Split（向量指令拆分）

```verilog
input [7:0] ibdp_ibuf_hn_split0;
input [7:0] ibdp_ibuf_hn_split1;
```

C910 支持 RISC-V V 扩展（向量指令）。某些向量指令（如向量 load/store）在 ibdp 阶段被识别为需要"拆分"执行的指令：

| 标记 | 含义 |
|------|------|
| `split0` | 该指令是被拆分系列的第一条（前半部分） |
| `split1` | 该指令是被拆分系列的后续部分 |

IDU 会根据这两个标记知道如何调度拆分后的微操作。

### 8.4 vl_pred（向量长度预测）

```verilog
input [7:0] ibdp_ibuf_hn_vl_pred;
input [7:0] ibdp_ibuf_h0_vl;
input [1:0] ibdp_ibuf_h0_vlmul;
input [2:0] ibdp_ibuf_h0_vsew;
```

C910 对 `vsetvli` 指令（设置向量长度寄存器）实现了预测机制：在指令还在 IBUF 中时，就预测其会写入的 `vl`、`vlmul`、`vsew` 值，并将这些预测值随后续向量指令传递，使 IDU 可以在 `vsetvli` 的结果未确定前就开始调度后续向量指令（投机执行）。

`vl_pred=1` 表示 IBUF 中存储的 `vl/vlmul/vsew` 值是预测值（尚未提交的 vsetvli 的预测结果），IDU 需要相应地进行处理或等待确认。

### 8.5 no_spec（不可推测执行）

```verilog
input [7:0] ibdp_ibuf_hn_no_spec;
```

某些指令不能被推测执行（例如 system call、CSR 读写等特权操作）。`no_spec` 标记告知 IDU 该指令必须在确认无误预测、前序指令已提交后才能发射执行。

---

## 9. 异常信息维护

### 9.1 随路传递的异常标记

每个 half-word 携带的异常信息在写入 IBUF 时一同保存，并在读出时随指令传递给 IDU：

| 异常标记 | 含义 | 写入方式 |
|----------|------|----------|
| `entry_acc_err` | 访问错误（如 ICache ECC 错误） | ibdp → IBUF |
| `entry_pgflt` | 页故障（ITLB miss 后 page table walk 失败） | ibdp → IBUF |
| `entry_high_expt` | 高优先级异常（如访问权限异常） | ibdp → IBUF |

### 9.2 为什么要在 IBUF 中维护异常信息

这是**精确异常（Precise Exception）**的实现需求。

RISC-V 架构要求异常在特定的指令边界处精确报告——必须是发生异常的那条指令的 PC 处触发异常，而不是更早或更晚。

取指是投机性的（尤其是分支预测后的取指），ICache 发生 ECC 错误或 TLB 发生 page fault 时，异常信息必须**绑定在对应的指令上**，随指令流向下游传递，直到指令**实际执行到该位置**时，才由后端（ROB/提交逻辑）真正触发异常处理。

如果异常信息不随指令传递而是在发现时立即处理，就无法实现精确异常。

### 9.3 异常信息到 IDU 的格式

Pop 阶段，异常信息被组合成统一格式：

```verilog
// 行 7800~7822
assign pop_h0_expt = (pop_h0_acc_err | pop_h0_pgflt);  // 任一异常成立

// expt_vec：异常类型编码（4位）
assign pop_h0_vec[3:0] = ({4{pop_h0_pgflt}}   & 4'b1100) |  // 页故障
                         ({4{pop_h0_acc_err}} & 4'b0001);   // 访问错误
```

IDU 收到 `inst0_expt_vld=1` 时，会将该指令标记为异常指令，后续不进行真正的执行，而是在 commit 时触发异常处理流程，`vec` 字段指明具体异常类型。

---

## 10. Flush 逻辑

### 10.1 Flush 的触发

```verilog
// 行 3413
assign ibuf_flush = ibctrl_ibuf_flush;
```

Flush 由 ibctrl 控制，在以下场景发生：
- 分支预测错误（BJ 误预测）
- 中断/异常跳转
- Fence.i 清空流水线
- CSR 写入影响取指流

### 10.2 Flush 的效果

Flush 时，IBUF 所有状态同步复位：

```verilog
// 写指针复位（行 3265~3266）
else if(ibuf_flush)
  ibuf_create_pointer <= {{(ENTRY_NUM-1){1'b0}}, 1'b1};

// 读指针复位（行 3541~3542）
else if(ibuf_flush)
  ibuf_retire_pointer <= {{(ENTRY_NUM-1){1'b0}}, 1'b1};

// create_num 复位（行 3319~3320）
if(ibuf_flush)
  ibuf_create_num_pre = 5'b0;

// retire_num 复位（行 3383~3384）
if(ibuf_flush)
  ibuf_retire_num_pre = 5'b0;
```

每个 Entry 的 `entry_vld` 也由 Entry 子模块在 flush 信号到来时清零（在 `ct_ifu_ibuf_entry.v` 中实现）。

Flush 之后，两个指针都回到 Entry 0（`32'h0000_0001`），计数器归零，IBUF 处于完全空的状态，可以接收新的取指流。

---

## 11. 向 IDU 的输出

### 11.1 两套输出通路

IBUF 向 IDU（ibdp 中间件）提供两套输出：

| 通路 | 信号前缀 | 数据来源 | 使用场景 |
|------|----------|----------|----------|
| Stored 通路 | `ibuf_ibdp_inst0/1/2_*` | 从 IBUF entry 中读出 | IBUF 非空时（正常情况） |
| Bypass 通路 | `ibuf_ibdp_bypass_inst0/1/2_*` | 本周期新取到的数据直传 | IBUF 为空且无 stall |

ibdp（或更下游的 IDU）根据实际情况选择使用哪套输出。

### 11.2 每条指令携带的完整信息

每条输出指令（inst0/1/2）携带以下信息：

```
ibuf_ibdp_inst0[31:0]       : 32位指令数据（16位指令高16位填0）
ibuf_ibdp_inst0_pc[14:0]    : 指令 PC 低15位
ibuf_ibdp_inst0_valid        : 该槽位是否有效
ibuf_ibdp_inst0_expt_vld     : 是否有异常（acc_err 或 pgflt）
ibuf_ibdp_inst0_vec[3:0]     : 异常类型编码
ibuf_ibdp_inst0_high_expt    : 高优先级异常
ibuf_ibdp_inst0_ecc_err      : ECC 错误
ibuf_ibdp_inst0_fence        : fence/fence.i 标记
ibuf_ibdp_inst0_split0/1     : 向量指令拆分标记
ibuf_ibdp_inst0_bkpta/bkptb  : 硬件断点命中
ibuf_ibdp_inst0_no_spec      : 不可推测执行
ibuf_ibdp_inst0_vl_pred      : 向量长度预测标记
ibuf_ibdp_inst0_vl[7:0]     : 向量长度 vl
ibuf_ibdp_inst0_vlmul[1:0]  : 向量 LMUL
ibuf_ibdp_inst0_vsew[2:0]   : 向量 SEW
```

### 11.3 inst1/inst2 的 Merge 选择逻辑

```verilog
// 行 9526~9561

// inst0：始终来自 IBUF stored path
assign ibuf_ibdp_inst0_valid = ibuf_pop_inst0_valid;

// inst1：若 IBUF 的 inst1 位无效（IBUF 不足2条指令），可从 merge 填充
assign ibuf_ibdp_inst1_valid = (merge_way_inst0_sel) ? merge_way_inst0_valid
                                                     : ibuf_pop_inst1_valid;

// inst2：同理，优先用 IBUF 的 inst2，不够时用 merge 填充
assign ibuf_ibdp_inst2_valid = (merge_way_inst1_sel) ? merge_way_inst1_valid
                                                     : ibuf_pop_inst2_valid;
```

这意味着在 IBUF 只有 1 条有效指令时，IDU 仍然可以在同一周期接收到 2~3 条指令（通过 merge 补充），大幅提高了紧急情况下的吞吐率。

### 11.4 输出吞吐率分析

每周期最多输出 3 条指令。在混合 16/32 位指令的场景下，最多消耗 6 个 half-word：

| 场景 | 指令组合 | 消耗 half-word | 输出条数 |
|------|----------|----------------|----------|
| 全16位压缩 | C, C, C | 3 | 3 |
| 混合（最常见）| 32, 16, 16 | 4 | 3 |
| 全32位 | 32, 32, 32 | 6 | 3 |
| IBUF 空+bypass | 按新指令组成 | 3~6 | 1~3 |

---

## 12. 关键时序与设计权衡

### 12.1 关键路径分析

IBUF 的关键路径在 **pop 逻辑**上：

```
ibuf_retire_pointer（32位 one-hot）
  → 32选1 case 语句（6个 half-word × 多个属性）
  → casez（5位 32_start 组合）
  → inst0/1/2 输出组合
  → 传递给 IDU
```

这条路径决定了 IBUF 的时序约束，也解释了为何使用 one-hot 指针（避免在关键路径上再加译码延迟）。

### 12.2 功耗优化：门控时钟

IBUF 针对每个 entry 和关键数据路径都使用了门控时钟（Gated Clock）：

```verilog
// PC 数据只在 ldst 指令时写入（节省功耗）
assign entry_pc_create[31:0] = entry_create_pre[31:0] & {32{~ibuf_full}};
assign entry_pc_create_clk_en[31:0] = entry_pc_create_bypass_pre[31:0] |
                                      entry_pc_create_nopass_pre_for_gateclk[31:0];
```

类似地，`entry_data_create_clk_en` 提前（pre）计算好使能信号，用于控制数据路径的门控时钟，而非用实际的写入信号直接做时钟使能（时序更宽松）。

### 12.3 Bypass 路径的延迟

Bypass 路径的数据直接来自 ibdp 的本周期输出，没有经过寄存器，是一条**组合逻辑路径**。这意味着：

1. **延迟低**：同周期即可完成
2. **时序紧**：ibdp 的处理延迟 + IBUF bypass 组合逻辑延迟都在一个时钟周期内完成

如果时序过紧，可以选择不走 bypass（用 `ibctrl_ibuf_bypass_not_select` 禁止），退化为经过 IBUF 寄存的一拍延迟模式。

### 12.4 设计复杂度的根源

`ct_ifu_ibuf.v` 代码量高达 9600+ 行，主要原因有三：

1. **展开的 32 个 Entry 实例化**（约 3000 行）：32 个 `ct_ifu_ibuf_entry` 的连接代码，每个 entry 约 50 行连接语句
2. **每个 Entry 的数据分配逻辑**（约 3000 行）：32 个 entry 的 `entry_create_inst_data_n`、`entry_create_pc_n`、`entry_create_vl_n` 等，每种属性 32 个 entry 展开写
3. **32选1的读出 case 语句**（约 2000 行）：6 个 half-word × 多种属性（data/pc/vl/vlmul/vsew）的选择语句

这些代码在逻辑上重复性很高，是因为 RTL 工具链（T-Head 的 &Instance 宏展开工具）将参数化代码展开生成，而非手工编写。

---

## 附录：关键信号速查

| 信号名 | 方向 | 宽度 | 含义 |
|--------|------|------|------|
| `ibctrl_ibuf_create_vld` | 输入 | 1 | IBUF 写入使能 |
| `ibctrl_ibuf_retire_vld` | 输入 | 1 | IBUF 读出使能 |
| `ibctrl_ibuf_flush` | 输入 | 1 | IBUF 全清信号 |
| `ibctrl_ibuf_merge_vld` | 输入 | 1 | 允许 merge 操作 |
| `ibctrl_ibuf_bypass_not_select` | 输入 | 1 | 禁止 bypass（IDU stall 或误预测） |
| `ibdp_ibuf_half_vld_num[3:0]` | 输入 | 4 | 本次写入的 half-word 数量（1~9） |
| `ibdp_ibuf_hn_vld[7:0]` | 输入 | 8 | 8个普通 half-word 的有效位 |
| `ibdp_ibuf_h0_vld` | 输入 | 1 | 第0个特殊 half-word 有效 |
| `ibuf_create_pointer[31:0]` | 内部 | 32 | One-hot 写指针 |
| `ibuf_retire_pointer[31:0]` | 内部 | 32 | One-hot 读指针 |
| `ibuf_create_num[4:0]` | 内部 | 5 | 写计数器（模32循环） |
| `ibuf_retire_num[4:0]` | 内部 | 5 | 读计数器（模32循环） |
| `bypass_vld` | 内部 | 1 | IBUF 空且允许 bypass |
| `ibuf_full` | 内部 | 1 | IBUF 满（反压取指） |
| `ibuf_empty` | 内部 | 1 | IBUF 空 |
| `ibuf_ibctrl_stall` | 输出 | 1 | IBUF 满，取指停顿 |
| `ibuf_ibctrl_empty` | 输出 | 1 | IBUF 空（触发尽快取指） |
| `ibuf_ibdp_inst0/1/2_*` | 输出 | 多 | Stored 路径向 IDU 输出的 3 条指令 |
| `ibuf_ibdp_bypass_inst0/1/2_*` | 输出 | 多 | Bypass 路径向 IDU 输出的 3 条指令 |
