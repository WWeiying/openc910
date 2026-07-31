# C910 IFU IBUF 模块详解

**RTL 文件**：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ibuf.v`

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

  PCGEN → IF（I-Cache 访问）→ IP（预解码）→ IBCTRL/IBDP → IBUF → IDU
                                                        ↑
                                                ct_ifu_ibuf.v
```

IBUF（Instruction Buffer，指令缓冲）是 IFU 与 IDU（Instruction Decode Unit）之间的弹性缓冲区。它的核心作用是：**解耦取指速率与译码速率**。

取指侧的供给速率是不均匀的：Cache Miss 时会停顿，命中时 IFU 处理一个
16-byte 取指块的 8 个 half-word；若再带上跨块保留的 H0，IBUF 写入口一次最多
处理 9 个 half-word。这里不是“一次返回整个 64-byte cache line”。IDU
接口每周期最多消费 3 条指令，两端速率不匹配需要弹性缓冲。

IBUF 以 FIFO 方式缓存从 ICache 取回、经过 ibdp 预译码后的指令流，平滑两侧速率差异。

### 1.2 容量设计考量

IBUF 共有 **32 个 Entry**，但这里需要澄清一个重要概念：每个 Entry 存储的是**一个 16 位 half-word**，而非一条完整指令。这是因为 C910 支持 RISC-V 的 C 扩展（16 位压缩指令），指令边界对齐到 16 位。

32 个 Entry 意味着最多保存 64 字节的连续有效半字：若全为 32 位指令，对应
16 条；若全为 16 位压缩指令，对应 32 条；混合指令流的条数介于两者之间。这里的
64 字节是 IBUF 容量换算，不能与 I-Cache 的 cache-line 组织混为一谈。

实际上，代码中的注释揭示了背后的设计逻辑：

```verilog
// Line 3447~3451
assign ibuf_full = |({ibuf_create_pointer[ENTRY_NUM-9:0],
                     ibuf_create_pointer[ENTRY_NUM-1:ENTRY_NUM-8]} &
                     entry_vld[31:0]);
```

每次输入最多涉及 9 个 half-word（`ibdp_ibuf_half_vld_num` 最大为 9），所以
IBUF 采用保守的最坏情况空间判断。上述表达式把 create one-hot 指针旋转 8 位，
只检查从当前写位置起的**第 9 个候选槽**。在有效项连续、读写指针保持 FIFO
不变量时，第 9 个槽仍有效就表示空闲空间不足 9 项；不需要把前九个槽逐一 OR。

因此 `ibuf_full` 更准确地说是“不能保证接受最大 9-half-word 输入包”的
backpressure 条件，不一定表示 32 项每一项都已占满。它用一部分容量裕量换取
固定、简单的上游接收判断。

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
| `entry_pc` | 15 | 该 half-word 内部 PC 的低 15 位（内部 PC 已省略架构 bit 0） |
| `entry_32_start` | 1 | 该 half-word 是否是一条 32 位指令的起始半字 |
| `entry_acc_err` | 1 | 访问错误标记 |
| `entry_pgflt` | 1 | 页故障标记 |
| `entry_high_expt` | 1 | H0 跨窗口 32 位指令的高半字异常归属标记 |
| `entry_fence` | 1 | fence/fence.i 指令标记 |
| `entry_split0` | 1 | 预解码 split 标记 0；当前生成配置中的向量执行路径被禁用 |
| `entry_split1` | 1 | 预解码 split 标记 1；当前生成配置中的向量执行路径被禁用 |
| `entry_bkpta` | 1 | 硬件断点 A 命中 |
| `entry_bkptb` | 1 | 硬件断点 B 命中 |
| `entry_no_spec` | 1 | 不可推测执行标记 |
| `entry_vl_pred` | 1 | 保留的向量长度预测标记 |
| `entry_vl` | 8 | 保留的向量长度字段 |
| `entry_vlmul` | 2 | 保留的向量 LMUL 字段 |
| `entry_vsew` | 3 | 保留的向量 SEW 字段 |

当前生成 RTL 中 `ct_cp0_regs.v` 把 `misa_vector` 固定为 0，
`ct_idu_id_decd.v` 也把 `x_vec_inst` 固定为 0。因此这些字段说明源码保留了
向量相关数据通路，不能据此认定当前 OpenC910 配置具有可工作的完整 RVV 执行
能力。

### 2.2 为什么 Entry 以 half-word 为单位

RISC-V 支持压缩指令（C 扩展），指令长度可以是 16 位或 32 位，且两者可以混合出现，指令边界只保证 2 字节对齐。因此，IBUF 采用 16 位为基本粒度，保留灵活性：

- 一条 16 位压缩指令：占用 1 个 Entry
- 一条 32 位普通指令：占用 2 个相邻 Entry（`entry_32_start` 标记第一个 half-word）

这种设计允许每周期最多输出 3 条逻辑指令，无论是 16 位还是 32 位，读出逻辑都可以通过检查 `pop_hn_32_start` 来决定如何拼接相邻 Entry 的数据形成完整的 32 位指令字。

### 2.3 Entry 数据写入的特殊机制

Entry 把 valid、普通 payload、特殊属性和 PC 分到不同门控时钟。最容易混淆的是
“把 payload 预写到候选槽”和“把该槽置为有效”：

```verilog
// 行 3644~3646
assign entry_data_create[31:0] = entry_create_pre[31:0] & {32{~ibuf_full}} & {32{ibctrl_ibuf_data_vld}};
assign entry_data_create_clk_en[31:0] = entry_create_bypass_pre[31:0] | 
                                        entry_create_nopass_pre_for_gateclk[31:0];
```

- `entry_create = entry_create_pre & ibuf_create_vld`：真正把 entry valid 置 1；
- `entry_data_create`：在输入数据有效且非 full 时，把普通 payload 预写到候选
  entry；它没有直接包含 `ibuf_create_vld`，即使最终不创建有效项也可能改写无效
  槽的旧 payload；
- `entry_vld_create_clk_en`：valid 位的前瞻时钟使能，覆盖九个候选位置；
- `entry_pc_create = entry_create_pre & !ibuf_full`：PC payload 的写条件也与 valid
  create 分开；
- `entry_pc_create_clk_en`：局部 ICG 前瞻使能用 `ib_hn_ldst` 过滤，体现“只有
  load/store 路径需要该低位 PC”的门控意图。

payload 可以被预写而 valid 不成立，是常见的低功耗/时序折中：队列语义只由 valid
决定，失效槽中的旧值或预写值没有架构意义。PC 的功能写条件与局部开钟条件也不能
合并成“非 load/store 不写 PC”的简单结论。通用
`gated_clk_cell` 还允许 `module_en` 覆盖 `local_en`；未定义
`C910_USE_TSMC28_ICG` 时，默认 RTL 模型直接令 `clk_out=clk_in`。因此功能仿真
中时钟仍会运行，而真实门控效果需要结合宏配置、综合网表和物理实现判断。

特殊属性时钟还有一处值得学习的“清旧值”设计：

```verilog
ibuf_entry_spe_clk_en =
  entry_spe_data_vld || entry_acc_err || entry_pgflt || entry_high_expt ||
  entry_bkpta || entry_bkptb || entry_no_spec;
```

新输入含特殊属性时会开钟写入；旧 entry 任一特殊位仍为 1 时也继续允许开钟，使
该槽被普通指令复用时能把旧标志写回 0。若只用“新特殊属性有效”开钟，旧的异常或
断点位可能残留并污染下一条指令。

---

## 3. 队列管理：指针与计数

### 3.1 两套管理机制

IBUF 同时维护两套机制来管理 FIFO 状态：

1. **One-hot 循环指针**：`ibuf_create_pointer[31:0]` 和
   `ibuf_retire_pointer[31:0]`，直接选择写入/读出 Entry；
2. **模 32 位置计数**：`ibuf_create_num[4:0]` 和 `ibuf_retire_num[4:0]`，
   辅助判断 empty、计算 bypass/merge 后的位置。

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

复位后指针从 Entry 0 开始（`32'h0000_0001`），每次 create 后按输入包的
`ibdp_ibuf_half_vld_num` 循环旋转。即使前缀通过 bypass 被直接消费，create
pointer 仍跨过整个输入包，随后由 retire pointer 和位置计数共同界定真正保留的
后缀：

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

**one-hot 指针在这里解决什么问题？**

从 RTL 结构可以直接确认的优势是：
1. 选择某个 Entry 时无需译码，直接用指针对应位作为使能：`entry_create[n] = create_pointer[n] & ibuf_create_vld`
2. 同时需要指向 9 个连续 Entry 时，可把 one-hot 向量固定旋转形成
   `ibuf_create_pointer0~8`，不在每个写端口重复做二进制加法和译码。

这通常有利于局部选择逻辑，但是否比二进制指针更快、更省面积必须以综合报告为
准；one-hot 本身需要 32 个状态位，不能只讲优点而忽略状态位开销。

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
// bypass_vld：计数位置相等且未禁止穿透
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

**为什么 empty 判断需要额外检查一个有效位？**

`create_num` 是模 32 的循环计数器（5 位）。当 IBUF 恰好有 32 个 Entry 全部有效
时，`create_num` 也等于 `retire_num`。此时不是 empty 而是 full。RTL 固定检查
`entry_vld[0]`，而不是假定读指针位于 Entry 0：在
`create_num==retire_num` 的合法 FIFO 状态
下，缓冲器只可能全空或整圈占满；前者全部 valid 为 0，后者全部 valid 为 1，
检查任意固定 entry 都可区分二者。

还要注意，内部 `bypass_vld` 只检查计数位置相等，没有检查 `entry_vld[0]`，
所以它不是严格的 `ibuf_empty` 同义词。功能性的当前包 bypass 是否成立，还由
IBCTRL 的 `bypass_inst_vld`、`ibuf_empty`、create valid 和下游选择共同约束。

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

### 3.5 同周期 Create 与 Retire

IBUF 允许 create 与 retire 在同一周期发生。create pointer/num 和 retire
pointer/num 是两套独立时序状态，各自根据对应 valid 更新，所以正常情况下可以
一边从队头移走最多三条指令，一边在队尾接收新的 half-word。这正是弹性缓冲解耦
上下游速率的核心。

每个 entry 的 valid 更新优先级为：

```verilog
flush > entry_create > entry_retire > hold
```

在合法 FIFO 状态下，普通 create 和 retire 应指向不同区域；若物理 entry 选择
发生重合，create 优先可保护同拍写入的新项不被 retire 清掉。`ibuf_full` 的九项
空间预留和 IBCTRL backpressure 用来避免不安全覆盖。波形中判断占用变化时，应
同时看 create/retire valid 以及各自跨过的 half-word 数，不能只看其中一根指针。

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

`ibdp_ibuf_h0_vld` 指示当前包前面是否带有跨 16 字节取指窗口保留的 H0
half-word。

```verilog
// 行 7560~7562
assign ib_hn_create_vld[8:0] = (ibdp_ibuf_h0_vld)
                             ? ({ibdp_ibuf_h0_vld, ibdp_ibuf_hn_vld[7:0]})
                             : ({ibdp_ibuf_hn_vld[7:0], 1'b0});
```

当 `ibdp_ibuf_h0_vld=1` 时，H0 是上一 16 字节窗口 H8 保留下来的低半字，用来
和当前窗口 H1 组成跨窗口的 32 位指令。H0 是一个独立保存的 **half-word
entry**，不是一条独立的特殊指令；在逻辑指令层面，H0 和 H1 属于同一条指令。
此时内部九个位置按 H0、H1、...、H8 排列。

当 `ibdp_ibuf_h0_vld=0` 时，输入只有当前窗口 H1 到 H8。IBUF 的内部
`ib_h0..ib_h7` 数据线会分别左对齐到 H1..H8，`ib_hn_create_vld` 最低位置补
0。这样后续 bypass 和拼装逻辑始终从内部 H0 位置开始处理连续有效半字。

这个设计使 IBUF 能正确处理跨 16 字节取指窗口的 32 位指令；16 字节窗口与
64 字节 I-Cache line 是不同层次的边界。

---

## 5. Bypass 直通路径

### 5.1 设计动机

当没有更老的 IBUF 数据挡在前面时，当前 IP→IB 包可以直接参与最多三条指令的
拼装和 IBDP 输出选择；不必先等待这些 half-word 成为下一轮 stored-path 头部。
这就是 bypass 的结构意义。它消除了“必须经过队列存后再取”的依赖，但不能仅由
本模块固定断言端到端恰好减少一拍，实际级间寄存和 IDU 接收时序仍要看顶层波形。

### 5.2 触发条件

```verilog
// 行 3417~3419
assign bypass_vld = (ibuf_create_num[4:0] == ibuf_retire_num[4:0]) &&
                     !ibctrl_ibuf_bypass_not_select;
```

两个局部条件分别是：

1. `ibuf_create_num == ibuf_retire_num`：模 32 的 create/retire 位置相等；它可能
   表示空，也可能表示整圈满，不能单独作为严格 empty；
2. `!ibctrl_ibuf_bypass_not_select`：IDU 没有给出 bypass 专用反压。IBCTRL
   当前直接令该输入等于 `idu_ifu_id_bypass_stall`，本模块中没有直接检查 BJU
   mispredict。

真正向 IDU 选择 bypass 输出的有效性由 IBCTRL/IBDP 联合决定；当缓冲实际 full
时，IBCTRL 不会创建当前包，不能把这里的内部 `bypass_vld` 单独当成接口握手。

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

Bypass 路径同样根据 `bypass_way_h0~h4_32_start` 把相邻 half-word 拼成最多
三条指令。它与 stored pop 路径采用相同的 16/32 位组合思想，但实现为另一组
展开的 `casez` 和随路属性选择，不能理解成复用同一个组合实例。

### 5.4 Bypass 与同周期写入的协调

当内部 bypass 条件与 create 同时成立时，当前包最前面的最多三条、最多六个
half-word 可由 bypass 消费；若当前包不足三条，则可把整个有效包消费掉。
`entry_create_bypass_pre` 只为未消费的后缀 half-word 建立有效 entry。这里使用
的是 `ib_hn_create_vld_bypass`，而
`ibuf_nopass_merge_mask` 主要用于 IBUF 非空时的 merge 路径。

```verilog
// 行 3634~3636
assign entry_create_pre[31:0] = (bypass_vld)
                              ? entry_create_bypass_pre[31:0]    // bypass时：只写未消耗的
                              : entry_create_nopass_pre[31:0];   // 普通时：全部写入
```

指针与计数的配合容易看错：

- create pointer 仍按**整个输入包**的 `half_vld_num` 向前移动；
- 若 bypass 形成三条有效指令，`create_num_pre_bypass` 从整个输入数中减去已
  消费的 3~6 个 half-word；若不足三条，整个包被消费，create 位置计数保持原值；
- retire pointer 移到被消费前缀之后；不足三条且整包被消费时直接移到新的 create
  pointer。

因此未消费后缀位于“新 retire pointer 到新 create pointer”之间，FIFO 中没有逻辑
空洞。只看 create pointer 而忽略 retire pointer，会误以为 bypass 后跳过了一段
存储。

### 5.5 Bypass 路径的时序含义

```
stored 路径：
  当前包 → entry create → 后续作为 FIFO 最老项被 pop

bypass 路径：
  当前包 → half-word 拼装 → IBDP 选择 → IDU 接口
```

这说明 bypass 避免了一次队列驻留，但“减少一拍”和“有显著性能提升”都需要结合
顶层寄存边界、命中率、IBUF 空闲比例和性能计数器验证。它也增加当前包到 IDU 的
组合路径深度，属于延迟与时序收敛之间的典型权衡。

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

拼装三条全 32 位指令时最多需要六个连续 half-word，所以指令数据读取到
`pop_h5_data`。但第六个 half-word 只可能是第三条指令的高半字，不会成为新指令
起点；PC、valid、异常、断点和其他随路属性只需读取 `pop_h0~h4`。32 位指令的
属性取其低半字/起始 half-word，第二个 half-word 只补充指令数据。

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

  // ... 共 8 种有效长度组合，另有 default 清零
  5'b1?1?1 :  // inst0=32位, inst1=32位, inst2=32位
    inst0_data = {pop_h1_data, pop_h0_data};
    inst1_data = {pop_h3_data, pop_h2_data};
    inst2_data = {pop_h5_data, pop_h4_data};
    ibuf_pop3_half_num = 3'b110;         // 消耗6个half-word
    ibuf_pop3_retire_vld = 6'b111111;

endcase
```

`ibuf_pop3_half_num` 记录本次三指令拼装需要跨过多少个 half-word，正常为 3~6，
用于更新 retire 指针。`ibuf_pop3_retire_vld[5:0]` 是六个候选 half-word 的
连续 retire mask：bit 5 对应 `pointer0/H0`，随后依次对应 pointer1..5。例如
`6'b111000` 消费前三个 half-word，`6'b111111` 消费六个。它不是“三个高位分别
表示三条指令是否为 32 位”。

---

## 7. Merge 操作

### 7.1 什么是 Merge

Merge 用来减少 IBUF 尾部边界造成的输出宽度浪费。考虑以下场景：

- IBUF 中只剩 1 或 2 条完整指令（不足 3 条）
- 同一周期 ibdp 刚好送来了新的指令

如果不做特殊处理，IDU 本周期只能收到 2 条指令（IBUF 里的），下一周期才能收到新来的指令，吞吐率不足。

Merge 允许在同一输出组合中，把 IBUF 中的最老指令和当前包中的顺序后继合成
最多 3 条送给 IDU，同时用 mask 防止已输出的新 half-word 再进入队列。

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

与此同时，`ibuf_merge_retire_pointer` 会越过刚被 merge 消费的新 half-word，
`retire_num_pre` 在 stored 路径不足三条时以旧 `ibuf_create_num` 加
`merge_half_num` 得到新位置；create pointer 则越过整个当前输入包。mask、retire
位置和 create 位置三者必须一致，才能保证当前包被直接输出的前缀不重复入队，而
未输出的后缀仍按序保留。

---

## 8. 特殊指令标记

### 8.1 Breakpoint（断点）

每个 half-word 携带两个断点标记：

| 标记 | 含义 |
|------|------|
| `entry_bkpta` | 硬件断点 A 命中 |
| `entry_bkptb` | 硬件断点 B 命中 |

这两个标记由上游调试断点比较链路产生，经 IPDP/IBDP 送入 IBUF。IBUF 本身不做
地址比较，只负责按 half-word 保存，并在拼成逻辑指令时把起始半字对应的标志送给
IBDP/IDU。断点最终如何触发调试进入由后续 IDU、RTU 和 HAD 协议决定。

```verilog
// 输入侧：ibdp 提供每个 half-word 的断点信息
input [7:0] ibdp_ibuf_hn_bkpta;        // 8个half-word各自的断点A标记
input       ibdp_ibuf_hn_bkpta_vld;    // 是否有断点A命中（至少一个）

// 输出侧：随每条指令一起送出
output ibuf_ibdp_inst0_bkpta;
output ibuf_ibdp_inst0_bkptb;
```

`hn_bkpta_vld`/`hn_bkptb_vld` 参与生成共享的 `entry_spe_data_vld`，主要用于
特殊属性寄存器的局部时钟前瞻使能；具体时钟是否被门控还受 module/global enable
和 ICG 实现影响。它不是“触发特殊处理流程”的功能 valid。

### 8.2 Fence / Fence.i

```verilog
input [7:0] ibdp_ibuf_hn_fence;
```

上游预解码把需要 fence 类处理的指令标成 `hn_fence`。IBUF 只保存并随逻辑指令
传递这个分类位，不在此处执行内存排序、Cache 维护或流水线串行化。具体是哪种
fence 以及如何执行，仍由 IDU 完整译码和后端控制决定。

### 8.3 Split（向量指令拆分）

```verilog
input [7:0] ibdp_ibuf_hn_split0;
input [7:0] ibdp_ibuf_hn_split1;
```

源码保留了向量/复杂指令 split 的随路字段：

| 标记 | 含义 |
|------|------|
| `split0` | 上游预解码产生的第一类 split 属性 |
| `split1` | 上游预解码产生的第二类 split 属性 |

精确 split 类型在 LBUF 路径还有更宽的 type 字段，IBUF这里只保存两个标志位。
当前生成配置把 `misa_vector` 和 `x_vec_inst` 固定为 0，所以不能用这些遗留字段
证明本版本支持完整 RVV 指令拆分和调度。

### 8.4 vl_pred（向量长度预测）

```verilog
input [7:0] ibdp_ibuf_hn_vl_pred;
input [7:0] ibdp_ibuf_h0_vl;
input [1:0] ibdp_ibuf_h0_vlmul;
input [2:0] ibdp_ibuf_h0_vsew;
```

这些字段反映源码曾设计过 `vsetvli` 相关的前端预测状态随指令流传递：
`vl_pred` 标记预测属性，`vl/vlmul/vsew` 保存相应配置。当前生成配置禁用向量
指令识别，因此本文只把它们作为保留的数据通路解释，不推导实际可运行的投机向量
执行能力。

### 8.5 no_spec（不可推测执行）

```verilog
input [7:0] ibdp_ibuf_hn_no_spec;
```

`no_spec` 来自 IFU 的 SFP/no-spec 属性链路，用来提示下游对该指令施加非推测
约束。IBUF 不判断哪些 opcode 属于该集合，也不直接决定“必须等到所有前序退休”
这一具体策略；应结合 `ct_ifu_sfp.v`、IDU 和后端发射条件判断。

---

## 9. 异常信息维护

### 9.1 随路传递的异常标记

每个 half-word 携带的异常信息在写入 IBUF 时一同保存，并在读出时随指令传递给 IDU：

| 异常标记 | 含义 | 写入方式 |
|----------|------|----------|
| `entry_acc_err` | 指令访问错误分类 | ibdp → IBUF |
| `entry_pgflt` | 指令页故障分类 | ibdp → IBUF |
| `entry_high_expt` | H0 有效且当前窗口异常，表示跨窗口 32 位指令高半字侧的异常归属 | ibdp → IBUF |

`acc_err` 不能在本文中等同于 I-Cache ECC。当前 IBUF 的 stored 和 bypass
`ecc_err` 信号均被直接赋为 `1'b0`，Entry 子模块也没有 ECC 字段；它是保留的
下游接口槽位。

### 9.2 为什么要在 IBUF 中维护异常信息

这是**精确异常（Precise Exception）**的实现需求。

RISC-V 架构要求异常在特定的指令边界处精确报告——必须是发生异常的那条指令的 PC 处触发异常，而不是更早或更晚。

取指是推测性的，访问错误或页故障信息必须绑定到对应 half-word/逻辑指令，随
指令流向下游传递。最终是否成为架构可见异常以及精确异常点，由 IDU/RTU 的异常
和退休控制决定；IBUF 的职责是保持错误类型、PC 和程序顺序不发生错配。

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

`expt_vld` 是 `acc_err|pgflt`，`vec` 对页故障编码 `4'b1100`、对访问错误编码
`4'b0001`。正常协议应保证两类互斥；若同时为 1，按当前 OR 方程会得到
`4'b1101`，因此核查异常波形时也应检查该互斥不变量。IBUF 只负责编码和传递，
异常指令后续是否进入执行单元、何时由 RTU 接管要看下游控制。

---

## 10. Flush 逻辑

### 10.1 Flush 的触发

```verilog
// 行 3413
assign ibuf_flush = ibctrl_ibuf_flush;
```

IBUF 只看到来自 IBCTRL 的 `ibctrl_ibuf_flush`，而 IBCTRL 又直接转接
`pcgen_ibctrl_ibuf_flush`。分支恢复、异常/中断、调试或串行化事件是否产生该
flush，由 PCGEN 的全局改流仲裁决定；本模块没有分别译码这些原因。

### 10.2 Flush 的效果

Flush 时，IBUF 的队列管理状态和所有 entry valid 被清除：

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

每个 Entry 的 `entry_vld` 也在各自 gated clock 上于 flush 时清零。数据、
PC 和特殊属性 payload 并没有因 flush 全部清零；它们可以保留旧值，但 valid=0
后不再属于有效队列内容。两个指针回到 Entry 0，位置计数归零，从协议上 IBUF
恢复为空。这里是“有效性清除”，不是把 32 个 entry 的所有存储位同步擦零。

---

## 11. 向 IDU 的输出

### 11.1 两套输出通路

IBUF 向 IDU（ibdp 中间件）提供两套输出：

| 通路 | 信号前缀 | 数据来源 | 使用场景 |
|------|----------|----------|----------|
| Stored/merge 通路 | `ibuf_ibdp_inst0/1/2_*` | IBUF 头部，必要时由当前包补齐 inst1/2 | IBUF 非空时 |
| Bypass 候选通路 | `ibuf_ibdp_bypass_inst0/1/2_*` | 当前 IP→IB 包直接拼装 | 最终由 IBCTRL/IBDP valid 选择 |

IBDP 根据 IBCTRL 提供的 `ibuf_inst_vld`、`bypass_inst_vld`、`lbuf_inst_vld`
选择最终送往 IDU 的来源；不是 IDU 在两套 IBUF 总线间自行仲裁。

### 11.2 每条指令携带的完整信息

每条输出指令（inst0/1/2）携带以下信息：

```
ibuf_ibdp_inst0[31:0]       : 32位指令数据（16位指令高16位填0）
ibuf_ibdp_inst0_pc[14:0]    : 指令内部 PC 低15位（架构 PC bit 0 已省略）
ibuf_ibdp_inst0_valid        : 该槽位是否有效
ibuf_ibdp_inst0_expt_vld     : 是否有异常（acc_err 或 pgflt）
ibuf_ibdp_inst0_vec[3:0]     : 异常类型编码
ibuf_ibdp_inst0_high_expt    : 高优先级异常
ibuf_ibdp_inst0_ecc_err      : ECC 接口占位；当前 RTL 固定为0
ibuf_ibdp_inst0_fence        : fence/fence.i 标记
ibuf_ibdp_inst0_split0/1     : 保留的 split 预解码标记
ibuf_ibdp_inst0_bkpta/bkptb  : 硬件断点命中
ibuf_ibdp_inst0_no_spec      : 不可推测执行
ibuf_ibdp_inst0_vl_pred      : 保留的向量长度预测标记
ibuf_ibdp_inst0_vl[7:0]     : 保留的 vl 字段
ibuf_ibdp_inst0_vlmul[1:0]  : 保留的 LMUL 字段
ibuf_ibdp_inst0_vsew[2:0]   : 保留的 SEW 字段
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

这意味着 IBUF 头部不足三条、当前包又可接受时，merge 可用较新的顺序后继指令
补齐空槽，减少边界处的供给宽度损失。实际收益取决于该场景频率和下游接收状态。

### 11.4 输出吞吐率分析

每周期最多输出 3 条指令。在混合 16/32 位指令的场景下，最多消耗 6 个 half-word：

| 场景 | 指令组合 | 消耗 half-word | 输出条数 |
|------|----------|----------------|----------|
| 全16位压缩 | C, C, C | 3 | 3 |
| 一种混合示例 | 32, 16, 16 | 4 | 3 |
| 全32位 | 32, 32, 32 | 6 | 3 |
| IBUF 空+bypass | 按当前有效包组成 | 1~6 | 1~3 |

---

## 12. 关键时序与设计权衡

### 12.1 需要重点关注的组合路径

从 RTL 结构看，stored 输出存在一条值得在综合报告和波形中重点检查的长组合候选：

```
ibuf_retire_pointer（32位 one-hot）
  → 32选1 case 语句（6份指令数据；前5份带起始半字属性）
  → casez（5位 32_start 组合）
  → inst0/1/2 输出组合
  → 传递给 IDU
```

该路径包含宽选择和 16/32 位边界拼装，确实可能成为时序压力点；但没有 STA
报告时不能断言它就是全模块关键路径。one-hot 指针避免了在写使能端显式二进制
译码，但读数据仍会综合成多路选择网络，最终延迟取决于综合器映射、布局布线和
IBDP/IDU 的跨模块路径。

### 12.2 功耗优化：门控时钟

IBUF 为每个 entry 的 valid、普通数据、特殊属性和 PC 分别设置了门控时钟接口：

```verilog
// 功能写使能与局部门控前瞻使能分开
assign entry_pc_create[31:0] = entry_create_pre[31:0] & {32{~ibuf_full}};
assign entry_pc_create_clk_en[31:0] = entry_pc_create_bypass_pre[31:0] |
                                      entry_pc_create_nopass_pre_for_gateclk[31:0];
```

`entry_pc_create_clk_en` 的两个 pre 信号带 `ib_hn_ldst` 过滤，而功能
`entry_pc_create` 随候选 `entry_create_pre` 且检查非 full，但不直接包含最终
`ibuf_create_vld`；`entry_data_create_clk_en` 也用 pre 条件提前
打开可能需要的数据时钟，真正写入仍由更严格的
`entry_data_create` 决定。这种“宽松开钟、严格写使能”避免功能写入被迟到的门控
条件漏掉。

通用 ICG 的实际关系是
`(global_en && (module_en || local_en)) || external_en`。`local_en=0` 不代表
`module_en` 无法开钟；默认未定义 `C910_USE_TSMC28_ICG` 的 RTL 模型还会直接
传递 `clk_in`。因此这里只能说明门控意图，面积/功耗收益需用实际综合与功耗分析
验证。

### 12.3 Bypass 路径的延迟

Bypass 候选由当前 IBDP 输入经半字对齐和 `casez` 拼装直接生成，没有先进入
IBUF entry；因此它减少队列驻留，同时把当前包的组合逻辑带到 IBDP/IDU 接口。
`ibctrl_ibuf_bypass_not_select` 由 IDU bypass stall 驱动，是运行时反压协议，
不是一个专供时序收敛任意关闭的静态配置开关。端到端是否跨一拍仍以顶层寄存边界
和 STA 为准。

### 12.4 设计复杂度的根源

`ct_ifu_ibuf.v` 代码量高达 9600+ 行，主要原因有三：

1. **展开的 32 个 Entry 实例化**（约 3000 行）：32 个 `ct_ifu_ibuf_entry` 的连接代码，每个 entry 约 50 行连接语句
2. **每个 Entry 的数据分配逻辑**（约 3000 行）：32 个 entry 的 `entry_create_inst_data_n`、`entry_create_pc_n`、`entry_create_vl_n` 等，每种属性 32 个 entry 展开写
3. **32选1的读出 case 语句**（约 2000 行）：六份 half-word data，以及前五个
   潜在指令起点的 PC/异常/预解码属性选择

这些代码在逻辑上重复性很高，源码中的 `&Instance`、`&ConnRule` 等注释也表明
它来自自动展开流程。阅读时应先提炼“32 项存储 + 9 路 create + 6 路 pop +
3 指令拼装”的规则，再回到某一个展开实例核对位序，避免把代码行数误当成机制
复杂度。

---

## 附录：关键信号速查

| 信号名 | 方向 | 宽度 | 含义 |
|--------|------|------|------|
| `ibctrl_ibuf_create_vld` | 输入 | 1 | IBUF 写入使能 |
| `ibctrl_ibuf_retire_vld` | 输入 | 1 | IBUF 读出使能 |
| `ibctrl_ibuf_flush` | 输入 | 1 | IBUF 全清信号 |
| `ibctrl_ibuf_merge_vld` | 输入 | 1 | 允许 merge 操作 |
| `ibctrl_ibuf_bypass_not_select` | 输入 | 1 | IDU bypass 反压，禁止空队列穿透选择 |
| `ibdp_ibuf_half_vld_num[3:0]` | 输入 | 4 | 有效输入包的 half-word 数量（1~9；无效时可为0） |
| `ibdp_ibuf_hn_vld[7:0]` | 输入 | 8 | 8个普通 half-word 的有效位 |
| `ibdp_ibuf_h0_vld` | 输入 | 1 | 第0个特殊 half-word 有效 |
| `ibuf_create_pointer[31:0]` | 内部 | 32 | One-hot 写指针 |
| `ibuf_retire_pointer[31:0]` | 内部 | 32 | One-hot 读指针 |
| `ibuf_create_num[4:0]` | 内部 | 5 | 写计数器（模32循环） |
| `ibuf_retire_num[4:0]` | 内部 | 5 | 读计数器（模32循环） |
| `bypass_vld` | 内部 | 1 | 模32位置相等且未禁止穿透；不是严格 empty 同义词 |
| `ibuf_full` | 内部 | 1 | 第9个候选写槽仍有效，无法保证接收最大输入包 |
| `ibuf_empty` | 内部 | 1 | IBUF 空 |
| `ibuf_ibctrl_stall` | 输出 | 1 | IBUF 满，取指停顿 |
| `ibuf_ibctrl_empty` | 输出 | 1 | IBUF 为空 |
| `ibuf_ibdp_inst0/1/2_*` | 输出 | 多 | Stored/merge 路径的最多 3 条指令 |
| `ibuf_ibdp_bypass_inst0/1/2_*` | 输出 | 多 | 当前包拼成的最多 3 条 bypass 候选 |
