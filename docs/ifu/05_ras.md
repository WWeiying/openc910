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

### 1.1 RAS 解决的问题：函数返回目标的上下文相关预测

正常、配对的 `call`/`ret` 具有后进先出（LIFO）特性：最近一次调用通常最先
返回。这使得专用硬件栈能显著提高返回目标预测率。但即使调用深度未溢出，
非标准链接寄存器用法、协程/长跳转、异常控制流以及投机状态恢复错误仍可能使命中
失败，因此不能从容量直接推出 100% 精度。

**为什么不用 BTB？**

| 特性 | BTB（Branch Target Buffer） | RAS |
|------|----------------------------|-----|
| 预测原理 | 记录历史跳转目标，期望同一条指令下次仍跳同一目标 | 基于 LIFO 栈，显式维护返回地址 |
| call 指令 | JAL 目标由 PC+立即数确定；JALR call 的目标仍可能随寄存器变化 | 不负责 call 目标预测，而是 push 链接地址：32 位指令为 PC+4，16 位 C.JALR 为 PC+2 |
| ret 指令 | **目标随上下文变化**，同一条 ret 可能返回到不同调用点，单目标 BTB 只能保留最近目标 | pop 当前投机栈顶 |
| 主要限制 | 上下文别名 | 深度溢出、非标准 call/ret、错误路径恢复 |

同一条共享函数尾部的 ret 可以由多个调用点到达，因此单目标 BTB 只记住“最近观察
目标”时容易丢失调用上下文。RAS 利用规范 call/return 的 LIFO 关系，在 call 时
压入 PC+4 或 PC+2，在 return 时读取栈顶，从而为这一类上下文相关目标提供更合适
的预测。它并非完美方案：超过 12 层的活动调用、非标准链接寄存器协议、非 LIFO
控制流、特权级切换和投机恢复边界都可能使 RAS 不可用或预测错误。

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
output [38:0] ras_ipdp_pc;            // ret 的预测目标；call 时为本条 call 的链接地址

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

### 2.1 总体布局：12 项投机栈加 6 项退休侧恢复副本

```
┌─────────────────────────────────────┐
│           IFU 侧（12 项）             │
│  ras_entry0  ~ ras_entry11           │
│  每项：pc[38:0] + priv_mode[1:0]    │
│        + filled                      │
│  由 ibctrl 侧 push/pop 直接维护      │
│  top_ptr 指向逻辑栈顶边界/下一写位    │
├─────────────────────────────────────┤
│       RTU 侧（6 个物理恢复副本）       │
│  rtu_entry0  ~ rtu_entry5            │
│  每项：pc[38:0] + priv_mode[1:0]    │
│        + filled                      │
│  仅在 call 退休时写入                │
│  rtu_ptr 记录退休历史的逻辑栈顶边界   │
└─────────────────────────────────────┘
```

**为什么是 12+6，而不是更简单的单一结构？**

C910 是乱序超标量处理器，IFU 看到的 call/ret 是**投机性**的——指令还未退休，预测就已经做了。这意味着：

- IFU 侧 12 项用于**投机状态**：根据预译码立即更新，为后续取指提供最新预测。
- RTU 侧 6 个物理副本用于**恢复退休历史**：`rtu_ptr` 同时跟随 retire0 的
  call/return 前后移动，而副本本身只在 call 退休时写入其链接地址。
- 当预测出错或流水线被冲刷时，RTU 侧副本用于修复 IFU 侧循环栈中的一个有限
  窗口（详见第 7 节），而不是提供另一份完整的 12 项已提交栈。

这 6 项不是额外接在 12 项之后的栈深度。它们按 `rtu_ptr` 的低位复用，保存
退休侧最近窗口的正确返回地址；flush/mispred 时，12 个投机项中符合
`rtu_entry*_copy` 条件的部分由这些副本修复。为什么选择 6 项属于实现取舍，
当前 RTL 能证明其复制映射和恢复行为，但不能证明“所有在途 call 一定不超过
6 个”。

### 2.2 每项的三个字段

| 字段 | 位宽 | 含义 |
|------|------|------|
| `pc[38:0]` | 39 位 | 返回地址的半字地址形式，保存架构字节 PC `[39:1]` |
| `priv_mode[1:0]` | 2 位 | push 时的特权级（M/S/U） |
| `filled` | 1 位 | 该物理项是否曾由有效 push 写入，或在恢复时从有效 RTU 副本复制 |

RAS 省略的是架构地址中恒为 0 的 `PC[0]`，不是最高位或“奇偶位”。因此波形中的 RAS PC 若要与反汇编地址比较，应使用 `{pc[38:0],1'b0}`。

**为什么存储 priv_mode（特权级）？**

当前 RTL 在 push 时记录 `cp0_yy_priv_mode`，使用栈顶返回地址时要求当前特权级与
记录值相等。这样可以避免把另一特权级上下文留下的 RAS 内容直接作为本级预测
目标。需要区分预测安全与架构权限：即使 RAS 目标错误，后续地址翻译、权限检查和
精确异常仍负责架构正确性；privilege match 主要缩小跨特权级错误投机和陈旧上下文
复用，而不能单独证明消除了所有投机侧信道或“否则一定权限提升”。

```verilog
// ct_ifu_ras.v 第 1911~1915 行
assign ras_ipdp_data_vld = (!ras_empty 
                            && ras_filled 
                            && (cp0_yy_priv_mode[1:0] == ras_priv_mode[1:0]) 
                            || ras_push) 
                         && cp0_ifu_ras_en;
```

对于 return 栈顶路径，只有 `!ras_empty`、`ras_filled` 和 privilege match 同时
成立，栈顶地址才使 `ras_ipdp_data_vld` 有效；call push 另有 `ras_push` 旁路，不
要求读取旧栈顶。

**filled 字段的作用：**

复位把全部 `filled` 清零；有效 push 将目标物理项置 1，恢复复制时则继承对应
RTU entry 的 `filled`。pop **不会清除**物理项的 `filled`，因为逻辑栈占用由
`top_ptr/status_ptr` 决定，弹出后留下的旧数据可以继续保存在寄存器中。因此
`filled` 不是每项独立的当前栈有效位，更接近“该槽内容是否初始化可信”的保护位：
先由 `ras_empty` 判断逻辑栈非空，再检查当前 `top_ptr-1` 对应物理项是否有可信
内容。

---

## 3. 指针设计（核心）

### 3.1 三个指针及其职责

模块中维护三个 5 位指针：

| 指针 | 位宽 | 维护方 | 触发更新的事件 |
|------|------|--------|----------------|
| `top_ptr[4:0]` | 5 位 | IFU | 投机 push、投机 pop、RTU 恢复 |
| `status_ptr[4:0]` | 5 位 | IFU | 满栈 push、满栈 pop、RTU 恢复 |
| `rtu_ptr[4:0]` | 5 位 | RTU | call 退休（加一）、ret 退休（减一） |

### 3.2 为什么用 5 位指针，而不是 4 位？

IFU 侧有 12 项，如果用 4 位（0~11）来表示位置，当 `top_ptr == status_ptr` 时，**无法区分"空"还是"满"**——两种情况下两个指针都指向同一位置。

**实现方法：额外 1 位记录环绕代际（wrap/generation bit）**

用 5 位指针，其中 `bit[4]` 是环绕代际位而不是有符号数的符号位，
`bit[3:0]` 编码位置 0~11：

- **空**：`top_ptr[4:0] == status_ptr[4:0]`（完全相等，包括 bit[4]）
- **满**：`top_ptr[4:0] == {~status_ptr[4], status_ptr[3:0]}`（bit[4] 相反，低 4 位相同）

```verilog
// ct_ifu_ras.v 第 425~426 行
assign ras_empty = (top_ptr[4:0] == status_ptr[4:0]);
assign ras_full  = (top_ptr[4:0] == {~status_ptr[4], status_ptr[3:0]});
```

这借用了循环 FIFO 常见的扩展指针思想：低位相同而代际位不同可表示相隔一整圈。
但 C910 RAS 的 `status_ptr` 还承担溢出窗口边界和恢复更新，不能把整套状态机
直接等同于普通 FIFO 的读写指针。

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

恢复条件具有最高优先级，因此同一更新边沿不会再叠加当拍的投机 push/pop；
`top_ptr_pre` 直接采用已纳入 retire0 call/return 动作的 `rtu_ptr_pre`。这说明
恢复边界以 RTU 维护状态为准，但“当拍立刻完成全部恢复”还取决于各 entry 复制
门控与下游重新取指时序。

### 3.5 status_ptr 的含义与 overflow 计数

`status_ptr` 与 `top_ptr` 共同编码当前可用窗口：二者相等表示 empty，
`top_ptr == {~status_ptr[4], status_ptr[3:0]}` 表示 full。可以把它直观理解为
可信窗口的底部边界，但不能把 5-bit 数值直接当成普通线性“溢出次数”；它与
`top_ptr` 一样采用低 4 位 mod-12、bit4 区分环绕代际。

具体逻辑（见第 400~423 行）：

- **RTU 恢复时**：若 `rtu_ptr_pre[4] ^ top_ptr[4]` 为 1，RTL 把
  `status_ptr` 写为 0；否则保留旧 `status_ptr[4]`，只把低 4 位改为
  `rtu_ptr_pre[3:0]`。这是精确方程；它不是无条件把 status 对齐到 top。
- **满时 push（overflow）**：`status_ptr` 加 1，表示最老的一项被覆盖，"可信底部"向前推进一格。
- **满时 pop**：若 `status_ptr[3:0]==0` 则写 0，否则对完整 5-bit
  `status_ptr` 减 1。该分支只在进入周期 `ras_full` 时发生，不能泛化成所有 pop
  都移动底部边界。

RTL 注释给出设计意图示例：连续 13 次 call 时覆盖最老地址，最近 12 次 return
仍可由 RAS 提供，最老一次退回通用寄存器形成的 JALR 实际目标。这里“最近 12 次
正确”成立还要求 call/return 配对、没有干扰恢复且 privilege/filled 检查通过；
RAS 无效时，执行单元依然根据 `rs1+imm` 计算架构目标。

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

这是固定深度循环栈的“保留最近 12 个调用上下文”策略，不宜称为 LRU：这里没有
按访问新近性选择牺牲项，覆盖对象由严格栈顺序决定。被覆盖的更老 return 仍由
JALR 执行语义从链接寄存器计算实际目标，只是前端可能缺少对应 RAS 预测。

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

pop 后 `top_ptr` 减 1（mod 12）。若进入周期 `ras_empty==1`，则不更新
`top_ptr`；这属于空栈 pop 抑制，而不是产生架构异常。即使 RAS 不提供目标，
JALR/return 指令仍会在执行阶段按寄存器和立即数计算实际跳转地址。

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

RTU 侧的 6 项（`rtu_entry0` ~ `rtu_entry5`）**只在 retire0 pcall 有效时写入**，
写入 `rtu_ifu_retire0_inc_pc` 和当时的特权级。`inc_pc` 是该已退休 call 的链接
地址：32 位 call 对应架构 PC+4，16 位 C.JALR 对应 PC+2；不能统一写成 PC+4。

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

注意这里有**两个条件**：`4'b0000` 和 `4'b0110`。RTU 指针按 12 个逻辑位置
移动，而 6 个物理副本按位置 mod-6 复用：0/6 对应 entry0，1/7 对应
entry1，依此类推。一个物理副本只保存这两个位置中**最近一次被已退休 call
写入的值**，不能同时保存两份数据；恢复选择逻辑因此只复制围绕最近 call 的
六位置滚动窗口。

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

`rtu_fifo_ptr[3:0]` 在 retire0 pcall 时记录写入发生前的
`rtu_ptr[3:0]`，也就是该 call 被放入的 12 位置编号；没有 pcall 时保持。它可
近似理解为“最近一次已退休 call 的逻辑槽位”，但不是普通 FIFO 的读写指针。

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

`top_ptr_pre` 直接选择 `rtu_ptr_pre`，并在门控时钟的有效上升沿写入
`top_ptr`。`rtu_ptr_pre` 已计入当前 retire0 的 call/return 组合，因此恢复的是
退休侧维护的**逻辑栈顶边界**；不能把它缩写成“最后一次 call 的位置”，也不能
仅由该指针赋值推出 12 个 IFU entry 的内容已全部恢复。

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

以 `ras_entry0` 为例，copy 条件在 `rtu_fifo_ptr_pre` 位于 0~5 时为真。把 12
个 entry 的条件放在一起看，它们形成一个长度为 6 的循环窗口：窗口以最近一次
已退休 call 的槽位为末端，覆盖该槽位及其之前 5 个 mod-12 位置。每个被选中的
IFU 位置从对应的 mod-6 RTU 物理副本复制。

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

RTU 物理副本按 6 复用，IFU 投机栈按 12 个位置循环；二者不是同一组寄存器，而是
通过上述 copy 多路关系建立恢复映射。

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

这段逻辑**不保证**恢复后 `status_ptr == top_ptr`，因此也不保证 RAS 变空。这样
才符合仍有未返回的已退休 call 的情况：恢复应撤销错误路径的投机操作，同时保留
可恢复的已退休调用上下文。准确行为是：

- `top_ptr` 采用 `rtu_ptr_pre`；
- `status_ptr` 按 bit4 关系选择清零或只对齐低 4 位；
- 位于 `rtu_fifo_ptr_pre` 所定义最近六位置窗口中的 IFU entries 从 RTU 副本修复；
- 其余 IFU entries 保持原值，但能否被当作当前栈顶还受新指针、empty/full 和
  `filled` 约束。

因此恢复是“指针回退 + 有限已退休窗口内容修复”，不是把 12 项全部重建，也不是
简单清空。

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
| `ras_filled` | `top_ptr-1` 所选物理项曾被有效写入或从有效 RTU 副本恢复 |
| `priv_mode 匹配` | 当前特权级与栈顶存储的特权级相同 |
| `\|\| ras_push` | 或当前正在执行有效 push；此时输出的是 call 链接地址旁路，不是 call 跳转目标 |
| `&& cp0_ifu_ras_en` | 全局 RAS 功能使能 |

### 8.3 call 时 ras_ipdp_pc 的特殊行为

当 `ibctrl_ras_inst_pcall == 1`（即当前指令是 call，但不一定推入到 RAS，因为 `ibctrl_ras_inst_pcall` 不含 stall 条件），`ras_ipdp_pc` 输出的是 `ibdp_ras_push_pc`（call 的返回地址 PC+4/PC+2），而不是栈内容。

这意味着对有效 call push，RAS 输出 PC 是该 call 的**链接地址**，不是 call 的
跳转目标。该信息可随预测控制流记录进入 PCFIFO 等恢复元数据通路；它帮助后续
return/RAS 状态关联，但不能单独“保证取指连续性”。

### 8.4 与 L0 BTB 的接口

```verilog
// ct_ifu_ras.v 第 1919~1921 行
assign ras_l0_btb_ras_push              = ras_push && cp0_ifu_ras_en;
assign ras_l0_btb_push_pc[PC_WIDTH-2:0] = ibdp_ras_push_pc;  // call 的链接地址
assign ras_l0_btb_pc[PC_WIDTH-2:0]      = ras_pc_out;         // ret 的预测目标
```

`ct_ifu_l0_btb` 在 `ras_l0_btb_ras_push` 为 1 时优先选择
`ras_l0_btb_push_pc`，否则还可选择 IPDP 提供的 call 链接地址或当前
`ras_l0_btb_pc`；选中值在 L0-BTB 读相关条件下写入其共享 `ras_pc` 寄存器。
命中的 L0-BTB entry 若带 `entry_ras` 标记，目标多路器使用该共享 `ras_pc`
而不是 entry 自身的 20-bit target。因而这里是 L0-BTB 与 RAS 顶部地址通路的
对齐/旁路，不是“每个 call 在 L0-BTB 中额外缓存一份独立返回地址”。

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

RISC-V ISA 对 JAL/JALR 的链接寄存器提示可概括为下表。C910 的
`x_pcall/x_preturn` 大体遵循 x1/x5 的 push/pop 组合，但当前实现还增加了具体
指令形式限制，尤其普通 JALR 只有 `imm==0` 才生成 `preturn`，所以不能笼统称为
“无条件完整实现表中所有编码组合”：

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

**特别说明：当前 RTL 的 jalr preturn 条件包含 `imm == 0`**

标准 `ret` 伪指令是 `jalr x0, x1, 0`。当前 RTL 将普通 JALR 的非零立即数排除
在 `x_preturn` 之外，即使其 `rs1` 是 x1/x5 且 `rd!=rs1`；这是实现采用的较窄
识别条件。不能进一步断言所有带偏移 JALR 都“不遵循 LIFO”，因为软件可能构造
特殊 ABI/控制流；准确结论只是 C910 不对这类编码执行 RAS pop 提示。

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

RAS 模块包含 12 个投机项、6 个退休恢复项及多组指针。RTL 为不同状态划分门控
时钟，只在相应 push/pop/恢复条件下更新，减少无操作周期的寄存器翻转；实际功耗
收益需要门级活动率和功耗分析量化。

### 10.2 门控时钟实例化模式

每个需要门控的寄存器组都实例化 `gated_clk_cell`：

```verilog
// ct_ifu_ras.v 第 296~303 行（rtu_ptr 的门控时钟，其他类似）
gated_clk_cell x_rtu_ptr_upd_clk (
    .clk_in             (forever_cpuclk),      // 主时钟输入
    .clk_out            (rtu_ptr_upd_clk),     // 门控后的时钟
    .external_en        (1'b0),                 // 本实例未使用额外外部开钟请求
    .global_en          (cp0_yy_clk_en),        // 全局使能
    .local_en           (rtu_ptr_upd_clk_en),   // 本地使能条件
    .module_en          (cp0_ifu_icg_en),        // 模块级开钟覆盖条件
    .pad_yy_icg_scan_en (pad_yy_icg_scan_en)    // 工艺 ICG 分支的测试使能 TE
);

assign rtu_ptr_upd_clk_en = cp0_ifu_ras_en && 
                            (rtu_ifu_retire0_pcall || rtu_ifu_retire0_preturn);
```

在 `gated_clk_cell.v` 中，工艺 ICG 分支的功能使能为
`global_en && (module_en || local_en) || external_en`，扫描输入另接 ICG 的
`TE`。因此 `local_en=0` 并不单独证明时钟停止：`module_en=1` 仍会开钟。
此外，只有定义 `C910_USE_TSMC28_ICG` 时开源 RTL 才实例化该工艺门控单元；未
定义时 `clk_out` 直接连接 `clk_in`。下表描述的是各状态的本地更新条件和设计
门控意图，实际综合网表中的时钟门控、翻转率与功耗必须结合所用宏定义、综合映射
和功耗分析判断。

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
    +--> 下一有效时钟边沿：top_ptr = rtu_ptr_pre（退休侧逻辑栈顶边界）
    |
    +--> status_ptr 按 bit4 关系清零，或保留旧 bit4 并更新低 4 位
    |
    +--> 12 个 IFU entry 中：属于 rtu_fifo_ptr_pre 定义的六位置循环窗口的项
    |    从 6 个 RTU 物理副本复制（rtu_entryN_copy 信号激活）
    |
    v
IFU 撤销投机指针偏移，并修复 RTU 能覆盖的退休历史窗口；
这不是完整重建全部 12 个 entry
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
| `top_ptr[4:0]` | 内部 | IFU 投机栈的逻辑栈顶边界/下一 push 位置，按 mod-12 环绕并用 bit4 记录代际 |
| `status_ptr[4:0]` | 内部 | 与 `top_ptr` 共同编码 empty/full 及溢出后可信窗口底部的辅助指针 |
| `rtu_ptr[4:0]` | 内部 | 随 retire0 call/return 更新的退休历史逻辑栈顶边界，按 mod-12 环绕 |
| `rtu_fifo_ptr[3:0]` | 内部 | 最近一次 retire0 call 写入前的 `rtu_ptr[3:0]`，用于选择恢复复制窗口 |
| `top_entry_rtu_updt` | 内部 | 触发 IFU 侧状态从 RTU 侧恢复 |
| `ras_empty` | 内部 | top_ptr == status_ptr |
| `ras_full` | 内部 | top_ptr == {~status_ptr[4], status_ptr[3:0]} |
