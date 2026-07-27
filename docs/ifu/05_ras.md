# C910 IFU RAS（Return Address Stack）模块详解

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ras.v`（1930 行）
>
> 相关文件：`ct_ifu_ibctrl.v`、`ct_ifu_ibdp.v`、`ct_ifu_ipdp.v`、`ct_ifu_decd_normal.v`

---

## 目录

1. [模块概述](#1-模块概述)
2. [物理结构](#2-物理结构)
3. [指针设计（核心）](#3-指针设计核心)
4. [Push 逻辑](#4-push-逻辑)
5. [Pop 逻辑](#5-pop-逻辑)
6. [RTU 侧维护](#6-rtu-侧维护)
7. [预测错误的恢复](#7-预测错误的恢复)
8. [与 ipdp 的接口](#8-与-ipdp-的接口)
9. [call/ret 指令识别](#9-callret-指令识别)
10. [时钟门控设计](#10-时钟门控设计)
11. [完整数据流总结](#11-完整数据流总结)

---

## 1. 模块概述

### 1.1 RAS 解决的问题：函数调用/返回的精确预测

程序执行中，`call`（过程调用）和 `ret`（过程返回）是最常见的控制流转移。它们具有明显的后进先出（LIFO）特性：最近一次调用的函数，一定最先返回。这使得用专用硬件栈进行预测成为可能，且理论上可以做到 100% 精确（在栈深度范围内）。

**为什么不用 BTB？**

| 特性 | BTB（Branch Target Buffer） | RAS |
|------|----------------------------|-----|
| 预测原理 | 记录历史跳转目标，期望同一条指令下次仍跳同一目标 | 基于 LIFO 栈，显式维护返回地址 |
| call 指令 | 目标固定，BTB 可以做到，但需要占用一条 BTB 表项 | push 返回地址（PC+4），无需额外条目 |
| ret 指令 | **目标随上下文变化**，同一条 ret 可能返回到不同调用点，BTB 只能记录最后一次的目标，准确率很低 | pop 栈顶，始终正确（不超深度时） |
| 精度上限 | 受调用上下文影响，ret 预测率通常 < 50% | 理论 100%（深度内） |

ret 指令的返回目标完全取决于是谁调用了它，而不取决于 ret 本身的 PC。这是 BTB 的根本缺陷。RAS 通过在 call 时把返回地址（PC+4）压栈、ret 时弹栈来完美解决这一问题。

### 1.2 RISC-V 中的 call/ret 编码

RISC-V 标准以 `jal` 和 `jalr` 实现函数调用和返回：

```
# 标准 call（32 位，保存返回地址到 ra=x1）
jal  ra, offset         # x1 = PC+4，跳转到 PC+offset
jalr ra, rs1, 0         # x1 = PC+4，跳转到 rs1

# 标准 ret（32 位）
jalr x0, ra, 0          # 跳转到 x1，不保存返回地址
# 等价于：jalr zero, ra, 0

# 压缩指令（16 位）
c.jalr rs1              # 等效 jalr x1, rs1, 0  (call)
c.jr   rs1              # 等效 jalr x0, rs1, 0  (ret，rs1 为 link reg)
```

C910 按照 RISC-V 规范，以 **x1（ra）和 x5（t0）**作为 link register（链接寄存器）。判断规则见第 9 节。

### 1.3 模块端口一览

```verilog
// 输入：来自 ibctrl（预译码控制器）
input  ibctrl_ras_pcall_vld;            // call 指令触发 push
input  ibctrl_ras_preturn_vld;          // ret  指令触发 pop
input  ibctrl_ras_inst_pcall;           // 当前指令是 call（不含 stall 条件）
input  [38:0] ibdp_ras_push_pc;        // call 的返回地址（PC+4 或 PC+2）

// 输入：来自 RTU（Retire Unit，退休单元）
input  rtu_ifu_retire0_pcall;           // call 指令正式退休
input  rtu_ifu_retire0_preturn;         // ret  指令正式退休
input  [38:0] rtu_ifu_retire0_inc_pc;  // 退休 call 的返回地址
input  rtu_ifu_retire0_mispred;        // 退休指令预测出错
input  rtu_ifu_flush;                   // 流水线冲刷

// 输出：返回地址预测结果
output ras_ipdp_data_vld;              // 预测结果有效
output [38:0] ras_ipdp_pc;            // 预测的返回地址（或 call 目标）

// 输出：给 L0 BTB 的接口
output ras_l0_btb_ras_push;
output [38:0] ras_l0_btb_push_pc;
output [38:0] ras_l0_btb_pc;

// 系统控制
input  cp0_ifu_ras_en;                 // CSR 控制：RAS 功能使能
input  [1:0] cp0_yy_priv_mode;        // 当前特权级
```

---

## 2. 物理结构

### 2.1 总体布局：18 项分两层

```
┌─────────────────────────────────────┐
│           IFU 侧（12 项）             │
│  ras_entry0  ~ ras_entry11           │
│  每项：pc[38:0] + priv_mode[1:0]    │
│        + filled                      │
│  由 ibctrl 侧 push/pop 直接维护      │
│  top_ptr 指向栈顶                    │
├─────────────────────────────────────┤
│           RTU 侧（6 项）              │
│  rtu_entry0  ~ rtu_entry5            │
│  每项：pc[38:0] + priv_mode[1:0]    │
│        + filled                      │
│  仅在 call 退休时写入                │
│  rtu_ptr 指向栈顶                    │
└─────────────────────────────────────┘
```

**为什么是 12+6，而不是更简单的单一结构？**

C910 是乱序超标量处理器，IFU 看到的 call/ret 是**投机性**的——指令还未退休，预测就已经做了。这意味着：

- IFU 侧 12 项用于**投机状态**：根据预译码立即更新，为后续取指提供最新预测。
- RTU 侧 6 项用于**已提交状态**：只在 call 正式退休时写入，存放已知正确的返回地址。
- 当预测出错、流水线被冲刷时，RTU 侧保存的 6 项可以帮助 IFU 侧快速恢复到正确状态（详见第 7 节）。

6 项是一个工程折中：理论上 RTU 窗口内 in-flight 的 call 数量不会超过 6 个（退休窗口 + 执行深度约束），保存最近 6 个已确认的返回地址足够覆盖恢复需求。

### 2.2 每项的三个字段

| 字段 | 位宽 | 含义 |
|------|------|------|
| `pc[38:0]` | 39 位 | 返回地址的半字地址形式，保存架构字节 PC `[39:1]` |
| `priv_mode[1:0]` | 2 位 | push 时的特权级（M/S/U） |
| `filled` | 1 位 | 该项是否存放了有效地址 |

RAS 省略的是架构地址中恒为 0 的 `PC[0]`，不是最高位或“奇偶位”。因此波形中的 RAS PC 若要与反汇编地址比较，应使用 `{pc[38:0],1'b0}`。

**为什么存储 priv_mode（特权级）？**

操作系统在不同特权级之间切换（U-mode 用户程序调用 S-mode 内核，S-mode 调用 M-mode 固件）。如果在 M-mode 的调用返回地址被留在栈中，然后在 U-mode 中被弹出使用，那么：

1. **地址无效**：不同特权级的地址空间映射不同，地址本身就可能是错误的。
2. **安全风险**：用户程序可能利用特权级间的地址跳转执行权限提升攻击。

因此，pop 时必须检查当前特权级与栈顶存储的特权级是否一致，不一致则预测结果无效：

```verilog
// ct_ifu_ras.v 第 1911~1915 行
assign ras_ipdp_data_vld = (!ras_empty 
                            && ras_filled 
                            && (cp0_yy_priv_mode[1:0] == ras_priv_mode[1:0]) 
                            || ras_push) 
                         && cp0_ifu_ras_en;
```

只有当 `cp0_yy_priv_mode == ras_priv_mode`（即当前特权级与栈顶记录的特权级相同）时，弹出的地址才被认为有效。

**filled 字段的作用：**

RAS 复位后所有项都未曾被写入。`filled=0` 表示该项不含有效数据。即使 `top_ptr` 指向某项，如果 `filled=0`，说明这是一个"假空"场景（溢出后覆盖写），该弹出结果也不可信。

---

## 3. 指针设计（核心）

### 3.1 三个指针及其职责

模块中维护三个 5 位指针：

| 指针 | 位宽 | 维护方 | 触发更新的事件 |
|------|------|--------|----------------|
| `top_ptr[4:0]` | 5 位 | IFU | 投机 push、投机 pop、RTU 恢复 |
| `status_ptr[4:0]` | 5 位 | IFU | 溢出（overflow）时推进，RTU 恢复时重置 |
| `rtu_ptr[4:0]` | 5 位 | RTU | call 退休（加一）、ret 退休（减一） |

### 3.2 为什么用 5 位指针，而不是 4 位？

IFU 侧有 12 项，如果用 4 位（0~11）来表示位置，当 `top_ptr == status_ptr` 时，**无法区分"空"还是"满"**——两种情况下两个指针都指向同一位置。

**经典解决方案：额外 1 位作为"环绕标志位"（wrap bit）**

用 5 位指针，其中 `bit[4]` 是符号/环绕位，`bit[3:0]` 是位置（0~11）：

- **空**：`top_ptr[4:0] == status_ptr[4:0]`（完全相等，包括 bit[4]）
- **满**：`top_ptr[4:0] == {~status_ptr[4], status_ptr[3:0]}`（bit[4] 相反，低 4 位相同）

```verilog
// ct_ifu_ras.v 第 425~426 行
assign ras_empty = (top_ptr[4:0] == status_ptr[4:0]);
assign ras_full  = (top_ptr[4:0] == {~status_ptr[4], status_ptr[3:0]});
```

这种设计被广泛用于循环 FIFO：通过扩展 1 位来编码"绕了几圈"的信息，从而区分空满两种状态。

### 3.3 12 项模 12 环绕的实现

位置 0~11（十进制）映射到 `bit[3:0]`，但不是按 2 的幂取模，而是按 12 取模。因此加 1 时不能简单用 `+1`（二进制加法会给出 0~15），必须在到达 11 后跳回 0。

实现方法：检测 `bit[3:0] == 4'b1011`（即 11），此时翻转 `bit[4]`，低 4 位清零：

```verilog
// ct_ifu_ras.v 第 337~341 行（top_ptr push 加 1）
if(top_ptr[3:0] == 4'b1011)
    top_ptr_pre[4:0] = {{~top_ptr[4]}, 4'b0000};  // 翻转 wrap bit，归零
else
    top_ptr_pre[4:0] = top_ptr[4:0] + 5'b1;        // 普通加法
```

减 1 时（pop）：检测 `bit[3:0] == 4'b0000`（即 0），此时翻转 `bit[4]`，低 4 位设为 11：

```verilog
// ct_ifu_ras.v 第 342~346 行（top_ptr pop 减 1）
else if(ras_pop && !ras_empty)
  if(top_ptr[3:0] == 4'b0000)
    top_ptr_pre[4:0] = {{~top_ptr[4]}, 4'b1011};   // 翻转 wrap bit，设为 11
  else
    top_ptr_pre[4:0] = top_ptr[4:0] - 5'b1;
```

`rtu_ptr` 使用相同的环绕逻辑（见第 269~278 行）。

### 3.4 top_ptr 的完整更新逻辑

```verilog
// ct_ifu_ras.v 第 326~349 行
always @(...)
begin
  if(top_entry_rtu_updt)                    // 最高优先级：RTU 恢复
    top_ptr_pre[4:0] = rtu_ptr_pre[4:0];
  else if(ras_push && ras_pop)              // push 和 pop 同时，抵消
    top_ptr_pre[4:0] = top_ptr[4:0];
  else if(ras_push)                         // 仅 push：加 1（mod 12）
    ...
  else if(ras_pop && !ras_empty)            // 仅 pop 且非空：减 1（mod 12）
    ...
  else                                      // 无操作：保持
    top_ptr_pre[4:0] = top_ptr[4:0];
end
```

优先级顺序：**RTU 恢复 > push+pop 同时 > 单独 push > 单独 pop > 保持**。

RTU 恢复具有最高优先级，确保一旦检测到预测出错，立刻将 `top_ptr` 拉回到经过验证的正确值。

### 3.5 status_ptr 的含义与 overflow 计数

`status_ptr` 本质上是 RAS 的**底部指针**，指向栈底（最老的有效项的下方）。正常情况下，`status_ptr` 不动；只有在溢出时才推进，用于跟踪"有多少个最老的返回地址已被覆盖"。

具体逻辑（见第 400~423 行）：

- **RTU 恢复时**：根据 `rtu_ptr_pre` 与 `top_ptr` 的 bit[4] 关系来重置 `status_ptr`。若两者 bit[4] 不同（跨越了环绕点），说明 RTU 恢复点在当前 top 之后（绕了半圈），此时清零 `status_ptr`；否则保留 bit[4]，低位设为 `rtu_ptr_pre[3:0]`。
- **满时 push（overflow）**：`status_ptr` 加 1，表示最老的一项被覆盖，"可信底部"向前推进一格。
- **满时 pop（underflow 方向）**：`status_ptr` 减 1（若非零），表示恢复一个可信项。

注释（第 393~396 行）给出了一个例子：连续 13 次 call，栈中只保留最后 12 次的返回地址；返回时最后 12 次可以正确预测，最老的那次返回会从 x1 寄存器值中得到答案（由 IU 提供）。

---

## 4. Push 逻辑

### 4.1 触发条件

```verilog
// ct_ifu_ras.v 第 796 行
assign ras_push = ibctrl_ras_pcall_vld;
```

`ibctrl_ras_pcall_vld` 由 ibctrl 在预译码阶段识别 call 指令后，在无 stall 条件下拉高（详见第 9 节）。这是**投机性**操作，指令此时还在流水线的取指/预译码阶段。

### 4.2 写入内容：返回地址

```verilog
// ct_ifu_ras.v 第 797 行
assign ras_push_pc[PC_WIDTH-2:0] = ibdp_ras_push_pc[PC_WIDTH-2:0];
```

`ibdp_ras_push_pc` 来自 ibdp，最终来源是 `ipdp_ibdp_ras_push_pc`，即 ipdp 在预译码时计算的返回地址：
- 32 位 call（jal/jalr）：PC+4
- 16 位 call（c.jalr）：PC+2

### 4.3 写入哪一项（entry_push 解码）

当 push 发生时，写入 `top_ptr[3:0]` 所指向的项。每一项都有一个独热判断：

```verilog
// ct_ifu_ras.v 第 892 行
assign entry0_push = (top_ptr[3:0] == 4'b0000);   // 当 top_ptr 指向位置 0 时写入 entry0
assign entry1_push = (top_ptr[3:0] == 4'b0001);   // 当 top_ptr 指向位置 1 时写入 entry1
// ... 以此类推，entry11_push = (top_ptr[3:0] == 4'b1011)
```

push 完成后，`top_ptr` 加 1（mod 12）。这里注意：**top_ptr 是"下一个可写位置"**，读取（pop）时读的是 `top_ptr-1`（即当前栈顶存储的内容）。

### 4.4 满时的 overflow 处理

当 `ras_full == 1` 时，push 不会停止，而是继续写入，覆盖最老的一项。同时 `status_ptr` 加 1，记录覆盖发生：

```verilog
// ct_ifu_ras.v 第 411~414 行
else if(cp0_ifu_ras_en && ras_full && ras_push)
    status_ptr[4:0] <= status_ptr_pre[4:0];  // 底部指针前进，记录溢出
```

这是一种"最新优先"（LRU 的对立面）策略：最近的调用占据栈顶，最老的被丢弃。因为编程中深度嵌套最终还是需要最近的返回，老的调用如果栈溢出，ret 时再通过寄存器 x1 提供答案。

---

## 5. Pop 逻辑

### 5.1 触发条件

```verilog
// ct_ifu_ras.v 第 1810 行
assign ras_pop = ibctrl_ras_preturn_vld;
```

同样是投机性的：预译码识别到 ret 指令（preturn），立即触发 pop。

### 5.2 读出地址：大选择器（case 语句）

pop 时读取 `top_ptr[3:0]` 的**前一个位置**所存的内容。实现方式是直接用 `top_ptr[3:0]` 作为选择器，但注意映射关系：

```verilog
// ct_ifu_ras.v 第 1826~1839 行
case(top_ptr[3:0])
  4'b0001 : ras_pc_out = ras_entry0_pc;   // ptr=1 时，读 entry0（即位置0）
  4'b0010 : ras_pc_out = ras_entry1_pc;   // ptr=2 时，读 entry1（即位置1）
  ...
  4'b1011 : ras_pc_out = ras_entry10_pc;  // ptr=11 时，读 entry10
  4'b0000 : ras_pc_out = ras_entry11_pc;  // ptr=0（绕回后），读 entry11
  default : ras_pc_out = ras_entry0_pc;
endcase
```

**关键理解**：`top_ptr` 指向的是"下一个要写入的位置"，而"栈顶存储的内容"在 `top_ptr-1` 处。因此 `ptr=1` 对应读 `entry0`，`ptr=0`（刚好绕回）对应读 `entry11`。这个映射通过 case 语句硬编码实现，不需要额外的减法。

对应地，`filled` 和 `priv_mode` 的读取也用相同的 case 逻辑（第 1858~1907 行）。

### 5.3 pop 后的 top_ptr 更新

pop 后 `top_ptr` 减 1（mod 12）。若检测到 underflow（`ras_empty == 1`），则不更新 `top_ptr`，避免指针越界。

```verilog
// ct_ifu_ras.v 第 342~346 行
else if(ras_pop && !ras_empty)
  if(top_ptr[3:0] == 4'b0000)
    top_ptr_pre[4:0] = {{~top_ptr[4]}, 4'b1011};
  else
    top_ptr_pre[4:0] = top_ptr[4:0] - 5'b1;
```

### 5.4 输出到 ipdp

pop 读出的地址通过 `ras_pc_out` 输出，最终到达 `ras_ipdp_pc`。ipdp 用此地址作为 ret 指令的预测目标。

---

## 6. RTU 侧维护

### 6.1 RTU FIFO 的写入逻辑

RTU 侧的 6 项（`rtu_entry0` ~ `rtu_entry5`）**只在 call 指令退休时写入**，写入内容是 `rtu_ifu_retire0_inc_pc`（退休 call 的 PC+4）和当时的特权级：

```verilog
// ct_ifu_ras.v 第 461~464 行（rtu_entry0 为例）
else if(cp0_ifu_ras_en && rtu_ifu_retire0_pcall && rtu_entry0_push)
    rtu_entry0_pc <= rtu_ifu_retire0_inc_pc;
```

每一项使用 `rtu_ptr[3:0]` 的独热解码来决定哪个 entry 被更新：

```verilog
// ct_ifu_ras.v 第 486~487 行（rtu_entry0 的写入条件）
assign rtu_entry0_push = (rtu_ptr[3:0] == 4'b0000) || 
                         (rtu_ptr[3:0] == 4'b0110);
```

注意这里有**两个条件**：`4'b0000` 和 `4'b0110`。这是因为 RTU 侧只有 6 项但按照 12 取模计数，所以 `rtu_ptr` 每绕一圈（12 格）会回到同一物理 entry 两次（0 和 6 对应 entry0，1 和 7 对应 entry1，以此类推）。RTU 侧 6 项实际上是 12 个逻辑位置中每两个共享一个物理存储。

### 6.2 rtu_ptr 的更新逻辑

```verilog
// ct_ifu_ras.v 第 261~279 行
if(rtu_ifu_retire0_pcall && rtu_ifu_retire0_preturn)
    rtu_ptr_pre = rtu_ptr;                   // call+ret 同时退休，互相抵消
else if(rtu_ifu_retire0_pcall)
    // 加 1，mod 12 环绕
else if(rtu_ifu_retire0_preturn && !rtu_ras_empty)
    // 减 1，mod 12 环绕
```

`rtu_ras_empty` 的判断：`rtu_ptr[4:0] == status_ptr[4:0]`，与 IFU 侧的 `ras_empty` 使用相同的原理（但这里用的 `rtu_ptr` 而非 `top_ptr`）。

### 6.3 rtu_fifo_ptr 的作用

`rtu_fifo_ptr[3:0]` 是一个专用寄存器，记录**最后一次 call 退休时 rtu_ptr 的低 4 位值**：

```verilog
// ct_ifu_ras.v 第 808~810 行
assign rtu_fifo_ptr_pre[3:0] = (rtu_ifu_retire0_pcall) 
                             ? rtu_ptr[3:0] 
                             : rtu_fifo_ptr[3:0];
```

这个值在 RTU 恢复阶段被 IFU 侧的 `rtu_entryN_copy` 信号使用，决定哪些 IFU 侧的 entry 需要从 RTU 侧复制（详见第 7 节）。

---

## 7. 预测错误的恢复

### 7.1 何时会出错

RAS 预测出错的场景：

1. **ret 指令本身被预测错误地执行**：例如前面的条件分支预测错了，ret 根本就不应该执行，但 RAS 已经 pop 了一项，导致栈状态混乱。
2. **call 指令流路径错误**：同上，错误路径上的 call push 了不该 push 的地址。
3. **异常、中断、fence 等导致的流水线冲刷**：这些事件会改变正确的控制流，之前的所有投机 push/pop 都需要撤销。

### 7.2 恢复触发条件

```verilog
// ct_ifu_ras.v 第 386~387 行
assign top_entry_rtu_updt = rtu_ifu_retire0_mispred || 
                            rtu_ifu_flush;
```

- `rtu_ifu_retire0_mispred`：退休单元检测到 retire0 指令的分支/跳转预测错误。
- `rtu_ifu_flush`：流水线被冲刷（异常、中断等）。

### 7.3 恢复机制：将 RTU 状态复制到 IFU 侧

恢复时执行两个操作：

**第一步：top_ptr 恢复**

```verilog
// ct_ifu_ras.v 第 333~334 行
if(top_entry_rtu_updt)
    top_ptr_pre[4:0] = rtu_ptr_pre[4:0];
```

将 `top_ptr` 直接设为 `rtu_ptr_pre`（RTU 侧退休后的指针值）。这样 IFU 侧的栈顶位置立即回到 RTU 侧最后一次 call 退休后的正确位置。

**第二步：IFU entry 内容恢复（从 RTU 复制）**

`rtu_entryN_copy` 信号决定哪些 IFU entry 需要从 RTU entry 复制数据：

```verilog
// ct_ifu_ras.v 第 886~891 行（entry0_copy 为例）
assign rtu_entry0_copy = (rtu_fifo_ptr_pre[3:0] == 4'b0101) ||
                         (rtu_fifo_ptr_pre[3:0] == 4'b0100) ||
                         (rtu_fifo_ptr_pre[3:0] == 4'b0011) ||
                         (rtu_fifo_ptr_pre[3:0] == 4'b0010) ||
                         (rtu_fifo_ptr_pre[3:0] == 4'b0001) ||
                         (rtu_fifo_ptr_pre[3:0] == 4'b0000);
```

这段逻辑的含义：当 `rtu_fifo_ptr`（最后一次 call 退休时的指针位置）落在 0~5 的范围内时，`rtu_entry0` 需要复制给对应的 IFU entry。

**IFU entry6 的特殊处理（体现 RTU 与 IFU entry 的循环对应关系）：**

```verilog
// ct_ifu_ras.v 第 1201~1202 行（entry6 从 rtu_entry0 复制）
if(rtu_entry6_copy)
    ras_entry6_pc <= rtu_entry0_pre;    // entry6 复制 rtu_entry0 的内容！
```

这是因为 RTU 只有 6 项，而 IFU 有 12 项。映射关系是：
- `ras_entry0` ↔ `rtu_entry0`
- `ras_entry1` ↔ `rtu_entry1`
- ...
- `ras_entry5` ↔ `rtu_entry5`
- `ras_entry6` ↔ `rtu_entry0`（循环）
- `ras_entry7` ↔ `rtu_entry1`（循环）
- ...
- `ras_entry11` ↔ `rtu_entry5`（循环）

RTU 以 6 为周期循环，IFU 以 12 为周期循环，两者共享 RTU 侧的物理存储。

### 7.4 恢复时 status_ptr 的更新

```verilog
// ct_ifu_ras.v 第 404~409 行
else if(cp0_ifu_ras_en && top_entry_rtu_updt)
begin
    if(rtu_ptr_pre[4] ^ top_ptr[4])
        status_ptr <= 5'b0;                         // bit[4] 不同：清零
    else
        status_ptr <= {status_ptr[4], rtu_ptr_pre[3:0]};  // bit[4] 不变，低位对齐
end
```

这里的逻辑：恢复后，`status_ptr` 应当与 `top_ptr`（即 `rtu_ptr_pre`）匹配，使得恢复后的 RAS 满足 `ras_empty = (top_ptr == status_ptr)`，即初始状态为空（从 RTU 视角看没有未退休的 call）。

---

## 8. 与 ipdp 的接口

### 8.1 输出信号

```verilog
// ct_ifu_ras.v 第 1911~1918 行
assign ras_ipdp_data_vld = (!ras_empty 
                            && ras_filled 
                            && (cp0_yy_priv_mode[1:0] == ras_priv_mode[1:0]) 
                            || ras_push) 
                         && cp0_ifu_ras_en;

assign ras_ipdp_pc = (ibctrl_ras_inst_pcall)
                   ? ibdp_ras_push_pc     // call 指令：输出 call 的返回地址
                   : ras_pc_out;          // ret 指令：输出弹出的栈顶地址
```

### 8.2 有效条件的详细解释

`ras_ipdp_data_vld` 为高的条件：

| 条件 | 含义 |
|------|------|
| `!ras_empty` | 栈不为空，有内容可弹 |
| `ras_filled` | 栈顶项已被正式写入（非未初始化状态） |
| `priv_mode 匹配` | 当前特权级与栈顶存储的特权级相同 |
| `|| ras_push` | 或者当前正在 push（call 指令），此时也有效（用于预测 call 目标） |
| `&& cp0_ifu_ras_en` | 全局 RAS 功能使能 |

### 8.3 call 时 ras_ipdp_pc 的特殊行为

当 `ibctrl_ras_inst_pcall == 1`（即当前指令是 call，但不一定推入到 RAS，因为 `ibctrl_ras_inst_pcall` 不含 stall 条件），`ras_ipdp_pc` 输出的是 `ibdp_ras_push_pc`（call 的返回地址 PC+4/PC+2），而不是栈内容。

这意味着对于 call 指令：ipdp 接收到的 RAS PC 实际上是 call 的**链接地址**，ipdp 可以据此在 pcfifo（预测 PC FIFO）中登记下一条指令的 PC，保证取指连续性。

### 8.4 与 L0 BTB 的接口

```verilog
// ct_ifu_ras.v 第 1919~1921 行
assign ras_l0_btb_ras_push              = ras_push && cp0_ifu_ras_en;
assign ras_l0_btb_push_pc[PC_WIDTH-2:0] = ibdp_ras_push_pc;  // call 的链接地址
assign ras_l0_btb_pc[PC_WIDTH-2:0]      = ras_pc_out;         // ret 的预测目标
```

L0 BTB 是一个更小更快的一级分支目标缓冲器。RAS 在 push 时通知 L0 BTB，让 L0 BTB 也缓存这次 call 对应的返回地址，以便在某些场景下 L0 BTB 能够更快命中。

---

## 9. call/ret 指令识别

### 9.1 识别在哪一级完成

识别链路（从底层到顶层）：

```
ct_ifu_decd_normal.v
    -> ct_ifu_ipdecode.v (聚合 h0~h8 共 9 个 half-word 的结果)
    -> ct_ifu_ipdp.v     (整合 way0/way1 双路，生成 pcall[7:0]/preturn[7:0])
    -> ct_ifu_ibdp.v     (经过 chgflw_mask 过滤，输出给 ibctrl)
    -> ct_ifu_ibctrl.v   (加入 stall 条件，输出 pcall_vld/preturn_vld 给 RAS)
```

### 9.2 RISC-V call/ret 识别规则（`ct_ifu_decd_normal.v`）

RISC-V 规范（Volume I，2.5 节）给出了推荐的 RAS 行为表，C910 完整实现了这张表：

```
+-------+-------+--------+--------------+
|   rd  |  rs1  | rs1=rd | RAS action   |
+-------+-------+--------+--------------+
| !link | !link |    -   | none         |
| !link | link  |    -   | pop          |
| link  | !link |    -   | push         |
| link  | link  |    0   | push and pop |
| link  | link  |    1   | push         |
+-------+-------+--------+--------------+
```

其中 link register 定义为 `x1`（ra）或 `x5`（t0）。

**call（pcall）识别**（`ct_ifu_decd_normal.v` 第 187~204 行）：

```verilog
assign x_pcall = (
    // jalr: rd == x1 或 rd == x5
    ({x_inst[14:12], x_inst[6:0]} == 10'b000_1100111) &&
    (x_inst[11:7] == 5'b00001 || x_inst[11:7] == 5'b00101)
) ||
(
    // jal: rd == x1 或 rd == x5
    (x_inst[6:0] == 7'b1101111) &&
    (x_inst[11:7] == 5'b00001 || x_inst[11:7] == 5'b00101)
) ||
(
    // c.jalr: rd 默认为 x1，rs1 != x0（由 [11:7] != 0 保证）
    ({x_inst[15:12], x_inst[6:0]} == 11'b1001_00000_10) &&
    (x_inst[11:7] != 5'b0)
);
```

**ret（preturn）识别**（`ct_ifu_decd_normal.v` 第 210~230 行）：

```verilog
assign x_preturn = (
    // jalr: rs1 == link，rd != rs1，imm == 0
    ({x_inst[14:12], x_inst[6:0]} == 10'b000_1100111) &&
    (x_inst[11:7] != x_inst[19:15]) &&        // rd != rs1
    (x_inst[19:15] == 5'b00001 || x_inst[19:15] == 5'b00101) &&  // rs1 是 link
    (x_inst[31:20] == 12'b0)                   // 偏移量为 0（纯跳转，不加偏移）
) ||
(
    // c.jr: rs1 == x1 或 rs1 == x5
    ({x_inst[15:12], x_inst[6:0]} == 11'b1000_00000_10) &&
    (x_inst[11:7] == 5'b00001 || x_inst[11:7] == 5'b00101) &&
    (x_inst[11:7] != 5'b0)
) ||
(
    // c.jalr: rs1 == x5（此时 rd 默认为 x1，rs1 != rd，故触发 pop 同时 push）
    ({x_inst[15:12], x_inst[6:0]} == 11'b1001_00000_10) &&
    (x_inst[11:7] == 5'b00101)
);
```

**特别说明：jalr 的 ret 条件包含 `imm == 0`**

标准 ret 是 `jalr x0, ra, 0`，偏移量为 0。若使用 `jalr x0, ra, 4`（带非零偏移），则不被识别为 ret，原因是这类带偏移的间接跳转并不遵循 LIFO 的调用/返回语义。

### 9.3 ibctrl 中的最终控制

```verilog
// ct_ifu_ibctrl.v 第 939~954 行
assign ibctrl_ras_inst_pcall  = (|hn_pcall) && ib_data_vld && !ib_expt_vld;

assign ibctrl_ras_pcall_vld   = (|hn_pcall) && ib_data_vld && !ib_expt_vld
                               && !ib_chgflw_self_stall && !fifo_stall
                               && !ind_btb_rd_stall;

assign ibctrl_ras_preturn_vld = (|hn_preturn) && ib_data_vld && !ib_expt_vld
                               && !ib_chgflw_self_stall && !fifo_stall
                               && !ind_btb_rd_stall;
```

`ibctrl_ras_inst_pcall` 和 `ibctrl_ras_pcall_vld` 的区别：
- `inst_pcall`：只要数据有效且无异常就拉高，不考虑 stall（用于 `ras_ipdp_pc` 的选择，即告诉下游"当前是 call 指令"）。
- `pcall_vld`：额外排除了 stall 条件，用于实际触发 RAS push（只有流水线能前进时才真正 push）。

---

## 10. 时钟门控设计

### 10.1 门控时钟的必要性

RAS 模块有大量寄存器（18 项 × 3 字段 + 3 个指针），如果每个周期都有时钟边沿，功耗极高。门控时钟（gated clock）只在需要更新时打开，大幅降低动态功耗。

### 10.2 门控时钟实例化模式

每个需要门控的寄存器组都实例化 `gated_clk_cell`：

```verilog
// ct_ifu_ras.v 第 296~303 行（rtu_ptr 的门控时钟，其他类似）
gated_clk_cell x_rtu_ptr_upd_clk (
    .clk_in             (forever_cpuclk),      // 主时钟输入
    .clk_out            (rtu_ptr_upd_clk),     // 门控后的时钟
    .external_en        (1'b0),                 // 外部使能（扫描测试用）
    .global_en          (cp0_yy_clk_en),        // 全局使能
    .local_en           (rtu_ptr_upd_clk_en),   // 本地使能条件
    .module_en          (cp0_ifu_icg_en),        // 模块级 ICG 使能
    .pad_yy_icg_scan_en (pad_yy_icg_scan_en)    // 扫描模式旁路
);

assign rtu_ptr_upd_clk_en = cp0_ifu_ras_en && 
                            (rtu_ifu_retire0_pcall || rtu_ifu_retire0_preturn);
```

各寄存器的门控条件汇总：

| 寄存器/组 | 门控条件 |
|-----------|----------|
| `rtu_ptr` | call 或 ret 退休 |
| `top_ptr` | RTU 恢复、预译码 call、预译码 ret |
| `status_ptr` | 满时 push/pop、RTU 恢复 |
| `rtu_entryN_pc/filled/priv` | RTU 侧 call 退休且选中此项 |
| `ras_entryN_pc/filled/priv` | RTU 恢复且此项被选中，或预译码 call 且此项被选中 |
| `rtu_fifo_ptr` | RTU 侧 call 退休 |

---

## 11. 完整数据流总结

### 11.1 正常执行路径

```
call 指令预译码识别
    |
    v
ibctrl_ras_pcall_vld = 1
    |
    +--> top_ptr 加 1（mod 12）
    |
    +--> ras_entry[top_ptr] 写入 ibdp_ras_push_pc（返回地址）
    |
    +--> ras_ipdp_data_vld = 1, ras_ipdp_pc = ibdp_ras_push_pc（告知 ipdp）
    |
    v
call 退休
    |
    +--> rtu_ptr 加 1（mod 12）
    |
    +--> rtu_entry[rtu_ptr] 写入 rtu_ifu_retire0_inc_pc（已确认的返回地址）
```

```
ret 指令预译码识别
    |
    v
ibctrl_ras_preturn_vld = 1
    |
    +--> 读取 ras_entry[top_ptr-1] 中的 pc 和 priv_mode、filled
    |
    +--> 若条件满足，ras_ipdp_data_vld = 1, ras_ipdp_pc = ras_pc_out
    |
    +--> top_ptr 减 1（mod 12）
    |
    v
ipdp 用 ras_ipdp_pc 作为下一条取指 PC
```

### 11.2 预测出错恢复路径

```
退休单元检测到预测错误（mispred）或流水线冲刷（flush）
    |
    v
top_entry_rtu_updt = 1
    |
    +--> top_ptr 立即 = rtu_ptr_pre（RTU 侧当前正确值）
    |
    +--> status_ptr 重置（与 rtu_ptr_pre 对齐）
    |
    +--> 12 个 IFU entry 中：属于"最近 6 个已退休 call"范围内的项
    |    从 RTU entry 重新复制（rtu_entryN_copy 信号激活）
    |
    v
IFU 侧 RAS 恢复到最后一次 RTU 确认的正确状态
```

### 11.3 关键信号依赖关系图

```
ibctrl_ras_pcall_vld  ───────────────> ras_push ──> top_ptr++, entry写入
ibctrl_ras_preturn_vld ──────────────> ras_pop  ──> top_ptr--, pc读出
rtu_ifu_retire0_pcall  ──────────────> rtu_ptr++, rtu_entry写入
rtu_ifu_retire0_preturn ─────────────> rtu_ptr--
rtu_ifu_retire0_mispred ─┐
rtu_ifu_flush            ─┴──> top_entry_rtu_updt ──> top_ptr=rtu_ptr_pre
                                                    ──> entry复制
top_ptr, status_ptr ─────────────────> ras_empty, ras_full
cp0_yy_priv_mode ────────────────────> ras_ipdp_data_vld（特权级匹配检查）
```

---

## 附录：重要信号汇总

| 信号名 | 方向 | 含义 |
|--------|------|------|
| `ibctrl_ras_pcall_vld` | 输入 | 预译码有效 call，无 stall，触发 push |
| `ibctrl_ras_inst_pcall` | 输入 | 预译码到 call（不考虑 stall），用于选择输出 PC |
| `ibctrl_ras_preturn_vld` | 输入 | 预译码有效 ret，无 stall，触发 pop |
| `ibdp_ras_push_pc` | 输入 | call 的返回地址（PC+4 或 PC+2） |
| `rtu_ifu_retire0_pcall` | 输入 | call 退休，触发 RTU 侧写入 |
| `rtu_ifu_retire0_preturn` | 输入 | ret 退休，触发 rtu_ptr 减 1 |
| `rtu_ifu_retire0_inc_pc` | 输入 | 退休 call 的已确认返回地址 |
| `rtu_ifu_retire0_mispred` | 输入 | 退休指令预测出错，触发恢复 |
| `rtu_ifu_flush` | 输入 | 流水线冲刷，触发恢复 |
| `ras_ipdp_data_vld` | 输出 | RAS 预测结果有效 |
| `ras_ipdp_pc` | 输出 | RAS 预测地址（ret 的目标，或 call 的链接地址） |
| `top_ptr[4:0]` | 内部 | IFU 侧栈顶指针（5 位，mod 12 环绕） |
| `status_ptr[4:0]` | 内部 | 溢出/满空检测辅助指针（5 位，mod 12） |
| `rtu_ptr[4:0]` | 内部 | RTU 侧已提交状态的栈顶指针（5 位，mod 12） |
| `rtu_fifo_ptr[3:0]` | 内部 | 最后一次 call 退休时 rtu_ptr 的低 4 位，用于恢复时的 entry 映射 |
| `top_entry_rtu_updt` | 内部 | 触发 IFU 侧状态从 RTU 侧恢复 |
| `ras_empty` | 内部 | top_ptr == status_ptr |
| `ras_full` | 内部 | top_ptr == {~status_ptr[4], status_ptr[3:0]} |
