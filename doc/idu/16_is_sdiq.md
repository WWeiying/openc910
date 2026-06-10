# C910 IDU — Store Data 发射队列（SDIQ）深度教学文档

> 本文档覆盖 `ct_idu_is_sdiq.v`（2637 行，顶层）与 `ct_idu_is_sdiq_entry.v`（734 行，队列项）。
> 读完后应能透彻理解：为什么 store 要拆成地址与数据两部分、SDIQ 如何管理 12 项队列、
> 唤醒与就绪判断的完整逻辑、发射到 pipe5 的流程、以及与 LSIQ/LSU 的协同机制。

---

## 目录

1. [模块概述：store 地址/数据分离设计动机](#1-模块概述)
2. [队列结构：12 项非循环 entry](#2-队列结构)
3. [端口说明](#3-端口说明)
4. [Entry 数据字段定义（SDIQ_WIDTH = 27）](#4-entry-数据字段定义)
5. [Entry 分配：create 流程](#5-entry-分配create-流程)
6. [年龄向量（Age Vector）与优先级](#6-年龄向量与优先级)
7. [唤醒机制：数据源就绪追踪](#7-唤醒机制数据源就绪追踪)
8. [store 地址就绪追踪（staddr_rdy）](#8-store-地址就绪追踪)
9. [冻结（Freeze）机制](#9-冻结freeze机制)
10. [发射就绪与选择逻辑](#10-发射就绪与选择逻辑)
11. [发射到 pipe5：store data 路径](#11-发射到-pipe5store-data-路径)
12. [与 LSIQ/LSU 的协同：地址与数据在 LSU 汇合](#12-与-lsiulsu-的协同)
13. [向量 store 数据处理（vfpu/vreg）](#13-向量-store-数据处理)
14. [物理寄存器 dealloc mask（寄存器释放）](#14-物理寄存器-dealloc-mask)
15. [flush 处理](#15-flush-处理)
16. [时钟门控（ICG）](#16-时钟门控icg)
17. [完整数据流串讲](#17-完整数据流串讲)

---

## 1. 模块概述

### 1.1 为什么 store 要拆成地址和数据两部分？

在乱序处理器中，一条 `sd x1, 8(x2)` 指令需要同时知道：

- **地址**：基址寄存器 `x2` 的值（用于计算 x2+8）
- **数据**：源寄存器 `x1` 的值（要写入内存的数据）

这两个操作数来自不同寄存器，可能在**不同时刻**变得就绪。如果把整条 store 指令放进同一个发射队列，就必须等到地址和数据**同时就绪**才能发射，造成一方等另一方的无谓延迟。

C910 的解决方案：**将 store 指令拆分成两条微操作（micro-op）**：

```
sd x1, 8(x2)
        │
        ├── staddr 微操作 → LSIQ → pipe3/pipe4（计算地址 x2+8，写入 STQ）
        └── stdata 微操作 → SDIQ → pipe5（准备写数据 x1，等地址入 STQ 后执行）
```

这种拆分的好处：
1. **独立就绪**：地址部分（通常只需 rs1）和数据部分（只需 rs2）可以独立等待各自的源寄存器，哪个先就绪就先发射。
2. **流水线解耦**：store 地址走 pipe3（AGU），store 数据走 pipe5，互不阻塞。
3. **STQ（Store Queue）协同**：地址先进 STQ 占位，数据到达后 LSU 再合并提交，符合内存一致性要求。

### 1.2 SDIQ 的角色定位

```
┌───────────────────────────────────────────────────────────────────┐
│                    IDU IS 阶段（乱序发射）                          │
│                                                                   │
│  ┌──────────────────────────────┐   ┌──────────────────────────┐  │
│  │  LSIQ（Load/Store 地址队列）  │   │  SDIQ（Store 数据队列）  │  │
│  │  深度：8 项                  │   │  深度：12 项（逻辑 8）   │  │
│  │  → pipe3/pipe4（AGU）        │   │  → pipe5（stdata）       │  │
│  └──────────────────────────────┘   └──────────────────────────┘  │
│               │                                   │               │
│         共享 entry 编号（sdiq_entry[11:0]），store 同时分配两个槽   │
└───────────────────────────────────────────────────────────────────┘
                │                                   │
                ▼                                   ▼
          LSU pipe3/4                           LSU pipe5
          计算地址、写 STQ               提取数据，等 STQ 分配后写入
                │                                   │
                └──────────── LSU 内部汇合 ─────────┘
```

### 1.3 关键设计约束

- **SDIQ 不能 bypass**：与 ALU 发射队列不同，store data 指令必须等到源寄存器真正就绪，不能用 bypass 通路发射。注释中明确写道 `//SDIQ cannot bypass, create in frz is always 0`（`sdiq_entry.v:390`）。
- **发射后必须等 staddr 进 STQ**：SDIQ 发射的 stdata 指令在 EX1 阶段仍需确认对应的 staddr 是否已进入 STQ（`staddr_rdy` 位），否则需要等待。

---

## 2. 队列结构

### 2.1 物理结构

SDIQ 由 12 个完全独立的 `ct_idu_is_sdiq_entry` 实例构成（entry0 ~ entry11），在代码中实例化命名为 `x_ct_idu_is_sdiq_entry0` ~ `x_ct_idu_is_sdiq_entry11`。

```
ct_idu_is_sdiq（顶层）
├── x_ct_idu_is_sdiq_entry0    (entry 0)
├── x_ct_idu_is_sdiq_entry1    (entry 1)
├── ...
├── x_ct_idu_is_sdiq_entry11   (entry 11)
├── 计数器逻辑 (sdiq_entry_cnt)
├── create 指针逻辑
├── issue 仲裁逻辑（年龄向量）
└── dealloc mask 逻辑
```

### 2.2 为什么是 12 项而不是 8 项？

文档说明中提到 SDIQ"逻辑 8 项"，但物理上实现了 12 项（满容量判断 `sdiq_entry_cnt == 4'd12`，见 `sdiq.v:666`）。这是因为乱序机器在双发射场景下，每周期可同时向 SDIQ 创建两条 store data 指令，适当加深队列可以缓解背压，提高发射吞吐率。

```verilog
// sdiq.v:666
assign sdiq_ctrl_full = (sdiq_entry_cnt[3:0] == 4'd12);
```

### 2.3 每个 entry 内部的子模块

每个 `ct_idu_is_sdiq_entry` 实例内部含有：

| 子模块 | 类型 | 用途 |
|---|---|---|
| `x_ct_idu_is_sdiq_src0_entry` | `ct_idu_dep_reg_entry` | 追踪整数源寄存器（rs2，store 数据） |
| `x_ct_idu_is_sdiq_srcv0_entry` | `ct_idu_dep_vreg_entry` | 追踪向量源寄存器（vector store 数据） |
| 本地寄存器 | FF | vld、frz、agevec、staddr0/1_rdy、stdata1_vld、unalign、src0_vld、srcv0_vld、load |

---

## 3. 端口说明

### 3.1 主要输入端口分组

| 端口前缀 | 含义 |
|---|---|
| `ctrl_sdiq_create*` | IDU ctrl 模块驱动：本周期是否向 SDIQ 创建指令（0/1/2 条） |
| `dp_sdiq_create*_data[26:0]` | IDU dp 模块驱动：创建的 entry 数据字（27 位，见第 4 节） |
| `dp_sdiq_rf_*` | RF 阶段反馈：lch 失败、staddr_rdy_set、rdy_clr 等 |
| `lsu_idu_ex1_sdiq_*` | LSU EX1 阶段：pop（出队）、freeze 清除、entry 编号 |
| `lsu_idu_dc_sdiq_*` | LSU DC 阶段（pipe4）：staddr 已进入 STQ，更新 staddr_rdy |
| `lsu_idu_dc_staddr_vld` | pipe4 DC 阶段 staddr 有效，触发 staddr_stq_create |
| `iu_idu_*` | IU 执行单元写回：整数管线 0/1、除法、乘法写回广播 |
| `lsu_idu_ag/dc/wb_pipe3_*` | LSU pipe3 AGU/DC/WB 阶段写回广播（用于唤醒） |
| `vfpu_idu_ex*_pipe6/7_*` | VFPU 管线执行阶段写回广播（向量唤醒） |
| `rtu_yy_xx_flush` | RTU flush 信号，清空全部 entry |

### 3.2 主要输出端口分组

| 端口 | 宽度 | 含义 |
|---|---|---|
| `sdiq_xx_issue_en` | 1 | 本周期有 entry 就绪，可发射 |
| `sdiq_xx_gateclk_issue_en` | 1 | 时序优化版 issue_en（基于 vld_with_frz） |
| `sdiq_dp_issue_entry[11:0]` | 12 | one-hot，指示本周期发射哪个 entry |
| `sdiq_dp_issue_read_data[26:0]` | 27 | 发射 entry 的数据字 |
| `sdiq_dp_create0/1_entry[11:0]` | 12 | one-hot，本周期 create0/1 分配到哪个 entry |
| `sdiq_aiq_create0/1_entry[11:0]` | 12 | 同上，发给 AIQ/ctrl 模块 |
| `sdiq_ctrl_full` | 1 | 队列满（12 项已占） |
| `sdiq_ctrl_full_updt` | 1 | 预测：下周期是否将满 |
| `sdiq_ctrl_1_left_updt` | 1 | 预测：下周期剩余 1 项 |
| `sdiq_ctrl_empty` | 1 | 队列空 |
| `sdiq_top_sdiq_entry_cnt[3:0]` | 4 | 当前 entry 占用数量 |
| `idu_rtu_pst_preg_dealloc_mask[95:0]` | 96 | 整数物理寄存器 dealloc 掩码 |
| `idu_rtu_pst_freg_dealloc_mask[63:0]` | 64 | 浮点物理寄存器 dealloc 掩码 |
| `idu_rtu_pst_vreg_dealloc_mask[63:0]` | 64 | 向量物理寄存器 dealloc 掩码 |

---

## 4. Entry 数据字段定义

每个 entry 携带一个 27 位数据字（`SDIQ_WIDTH = 27`），字段定义在 `ct_idu_is_sdiq_entry.v` 的参数区（第 310-328 行）：

```verilog
// sdiq_entry.v:310-328
parameter SDIQ_WIDTH             = 27;

parameter SDIQ_LOAD              = 26;  // 是否为 load（SDIQ 也会存入含 load 语义的项？实为判断是否需要 staddr）
parameter SDIQ_STADDR1_IN_STQ    = 25;  // staddr 微操作 1 已进 STQ
parameter SDIQ_STADDR0_IN_STQ    = 24;  // staddr 微操作 0 已进 STQ
parameter SDIQ_STDATA1_VLD       = 23;  // 当前是非对齐 store 的第 2 个 stdata 微操作
parameter SDIQ_UNALIGN           = 22;  // 非对齐 store
parameter SDIQ_SRCV0_LSU_MATCH   = 21;  // 向量源 0 与 LSU 写回匹配（运行时，不存储）
parameter SDIQ_SRCV0_DATA        = 20;  // 向量源 0 数据段起始（bit[20:13]）= vreg[6:0] + wb + rdy
parameter SDIQ_SRCV0_WB          = 13;  // 向量源 0 正在 WB
parameter SDIQ_SRCV0_RDY         = 12;  // 向量源 0 就绪（运行时，不存储）
parameter SDIQ_SRC0_LSU_MATCH    = 11;  // 整数源 0 与 LSU 写回匹配（运行时，不存储）
parameter SDIQ_SRC0_DATA         = 10;  // 整数源 0 数据段起始（bit[10:3]）= preg[6:0] + wb + rdy
parameter SDIQ_SRC0_WB           = 3;   // 整数源 0 正在 WB
parameter SDIQ_SRC0_RDY          = 2;   // 整数源 0 就绪（运行时，不存储）
parameter SDIQ_SRCV0_VLD         = 1;   // 存在向量源（vector store）
parameter SDIQ_SRC0_VLD          = 0;   // 存在整数源（普通 store 数据）
```

**字段布局图：**

```
 26  25  24  23  22  21  20       13  12  11  10       3   2   1   0
┌───┬───┬───┬───┬───┬───┬─────────┬───┬───┬──────────┬───┬───┬───┐
│LOD│A1Q│A0Q│D1V│UNL│VM │SRCV0DAT│VWB│VRD│SRC0 DATA │WB │RD │VLD│SV│
│   │STQ│STQ│   │   │LCH│vreg6:0 │   │   │preg 6:0  │   │   │   │VLD│
└───┴───┴───┴───┴───┴───┴─────────┴───┴───┴──────────┴───┴───┴───┘
  LOAD       STDATA1 UNALIGN         SRCV0（向量）          SRC0（整数）
       STADDR 入 STQ 状态
```

> 注意：`SRC0_RDY`、`SRCV0_RDY`、`SRC0_LSU_MATCH`、`SRCV0_LSU_MATCH` 这些位在 `x_read_data` 输出中**固定为 0**，实际就绪状态由 `dep_reg_entry` / `dep_vreg_entry` 子模块内部跟踪（通过 `src0_rdy_for_issue` 和 `srcv0_rdy_for_issue` 信号输出），不写入数据字以避免跨周期传播错误。

---

## 5. Entry 分配：create 流程

### 5.1 create 指针选择

SDIQ 用**优先级编码器**寻找空闲 entry，create0 从低位（entry0）向高位扫描，create1 从高位（entry11）向低位扫描，两者方向相反以避免冲突。

```verilog
// sdiq.v:728-769（create0，从低向高）
always @(...)
begin
  if(!sdiq_entry0_vld)
    sdiq_entry_create0_in[11:0] = 12'b0000_0000_0001;  // entry 0
  else if(!sdiq_entry1_vld)
    sdiq_entry_create0_in[11:0] = 12'b0000_0000_0010;  // entry 1
  ...
  else if(!sdiq_entry11_vld)
    sdiq_entry_create0_in[11:0] = 12'b1000_0000_0000;  // entry 11
  else
    sdiq_entry_create0_in[11:0] = 12'b0000_0000_0000;  // 队列满
end

// sdiq.v:771-811（create1，从高向低）
always @(...)
begin
  if(!sdiq_entry11_vld)
    sdiq_entry_create1_in[11:0] = 12'b1000_0000_0000;  // entry 11
  else if(!sdiq_entry10_vld)
    ...
  else if(!sdiq_entry0_vld)
    sdiq_entry_create1_in[11:0] = 12'b0000_0000_0001;  // entry 0
  else
    sdiq_entry_create1_in[11:0] = 12'b0000_0000_0000;
end
```

**为什么方向相反？** 同周期双发射时，如果两个 create 指针都从 entry0 开始扫，会产生冲突（都选中同一个空闲 entry）。从两端向中间扫描，保证 create0 和 create1 选中不同的 entry（只要队列不满到只剩 1 项）。

### 5.2 create 使能信号

```verilog
// sdiq.v:817-819
assign sdiq_entry_create_en[11:0] =
       {12{ctrl_sdiq_create0_en}} & sdiq_entry_create0_in[11:0]
     | {12{ctrl_sdiq_create1_en}} & sdiq_entry_create1_in[11:0];
```

`ctrl_sdiq_create0_en` 和 `ctrl_sdiq_create1_en` 来自 IDU ctrl 模块，表示本周期分别是否需要向 SDIQ 写入第 0、第 1 条 store data 指令。

### 5.3 create_sel：数据路径选通

```verilog
// sdiq.v:889-892
assign sdiq_entry_create_sel[11:6] = {6{ctrl_sdiq_create1_dp_en}}
                                     & sdiq_entry_create1_in[11:6];
assign sdiq_entry_create_sel[5:0]  = ~({6{ctrl_sdiq_create0_dp_en}}
                                      & sdiq_entry_create0_in[5:0]);
```

`create_sel[i] = 0` 表示 entry_i 使用 create0 的数据；`= 1` 表示使用 create1 的数据。

- entry 0~5 使用 `~(create0_in & dp_en0)` 实现（低位，create0 优先）
- entry 6~11 使用 `(create1_in & dp_en1)` 实现（高位，create1 优先）

这种**分区**技巧减少了关键路径上的 mux 延迟（注释：`//entry 0~5 use ~sdiq_entry_create0_in for better timing`，见 `sdiq.v:885`）。

### 5.4 entry 计数器

```verilog
// sdiq.v:643-663
assign sdiq_entry_cnt_create[3:0] = {3'b0,ctrl_sdiq_create0_en}
                                    + {3'b0,ctrl_sdiq_create1_en};
assign sdiq_entry_cnt_pop[3:0]    = {3'b0,lsu_idu_ex1_sdiq_pop_vld};

always @(posedge cnt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    sdiq_entry_cnt[3:0] <= 4'b0;
  else if(rtu_yy_xx_flush)
    sdiq_entry_cnt[3:0] <= 4'b0;
  else if(sdiq_entry_cnt_updt_vld)
    sdiq_entry_cnt[3:0] <= sdiq_entry_cnt[3:0]
                           + sdiq_entry_cnt_create[3:0]
                           - sdiq_entry_cnt_pop[3:0];
end
```

每周期最多 +2（双创建）或 -1（单 pop），计数器宽度 4 位（最大 15，实际最大 12）。

---

## 6. 年龄向量与优先级

SDIQ 使用**年龄向量（Age Vector）**机制保证最老指令优先发射，避免饥饿，同时天然保序（按程序顺序发射 store data，符合内存模型）。

### 6.1 年龄向量的含义

每个 entry 持有一个 11 位年龄向量 `agevec[10:0]`，其中第 j 位（相对编号）= 1 表示"有比我更老的 entry j 存在"。若 `agevec == 0`，则该 entry 是队列中最老的。

注意：向量是 11 位（去掉自己那位），并且按循环展开方式存储（entry i 的 agevec 不包含 bit[i]）。

### 6.2 create 时的年龄向量初始化

```verilog
// sdiq.v:874-883
// create0 的年龄向量 = 当前已有的 valid entry（去掉即将 pop 的）
assign sdiq_entry_create0_agevec[11:0] = sdiq_entry_vld[11:0]
                                         & ~({12{lsu_idu_ex1_sdiq_pop_vld}}
                                            & lsu_idu_ex1_sdiq_entry[11:0]);

// create1 的年龄向量 = 当前已有的 valid entry + create0 对应 entry
assign sdiq_entry_create1_agevec[11:0] = sdiq_entry_vld[11:0]
                                         & ~({12{lsu_idu_ex1_sdiq_pop_vld}}
                                            & lsu_idu_ex1_sdiq_entry[11:0])
                                         | sdiq_entry_create0_in[11:0];
```

- create0 的年龄向量只包含"本周期之前已有的 entry"，表示 create0 比它们都新。
- create1 的年龄向量额外加入 create0 的 entry，因为 create0 比 create1 更早进入（同周期双发射时，create0 对应程序顺序更前的指令）。

### 6.3 pop 时的年龄向量更新

```verilog
// sdiq_entry.v:410-413
else if(lsu_idu_ex1_sdiq_pop_vld)
  agevec[10:0] <= agevec[10:0] & ~x_pop_other_entry[10:0];
```

当某个 entry 被 pop（发射执行完毕），其他所有 entry 的年龄向量中**清除**已 pop entry 对应的位，相当于从"我比谁更老"的记录中删去已离开队列的竞争者。

### 6.4 年龄 beat 的循环映射

每个 entry 的 agevec 是 11 位，对应 11 个"其他 entry"的相对位置。以 entry1 为例：

```verilog
// sdiq.v:1359-1361
assign {sdiq_entry1_pop_other_entry[10:1],
        sdiq_entry1_pop_cur_entry,
        sdiq_entry1_pop_other_entry[0]} = lsu_idu_ex1_sdiq_entry[11:0];
```

`lsu_idu_ex1_sdiq_entry[11:0]` 是 12 位 one-hot，bit[1] 对应 entry1 自己（`pop_cur_entry`），其余 11 位按顺序映射到 `pop_other_entry[10:0]`（bit[11:2] 对应 [10:1]，bit[0] 对应 [0]），实现了"跳过自己那位"的循环映射。

---

## 7. 唤醒机制：数据源就绪追踪

### 7.1 整体架构

每个 SDIQ entry 通过内置的 `ct_idu_dep_reg_entry`（整数）和 `ct_idu_dep_vreg_entry`（向量）子模块追踪数据源就绪状态。这两个子模块监听**全处理器所有写回总线**，一旦匹配到本 entry 等待的物理寄存器，立即将就绪位置 1。

### 7.2 store data 的源寄存器：只有 1 个

普通整数/浮点 store 只有一个数据源（`rs2`），在 SDIQ 中对应 `src0`：

```verilog
// sdiq_entry.v:427-430
else if(x_create_dp_en) begin
  src0_vld  <= x_create_data[SDIQ_SRC0_VLD];   // bit[0]：是否有整数源
  srcv0_vld <= x_create_data[SDIQ_SRCV0_VLD];  // bit[1]：是否有向量源
  load      <= x_create_data[SDIQ_LOAD];        // bit[26]：是否为 load（特殊）
end
```

向量 store 使用 `srcv0`（向量寄存器）。二者不会同时有效：普通 store 只有 `src0_vld=1`，向量 store 只有 `srcv0_vld=1`。

### 7.3 dep_reg_entry 连接（整数源）

```verilog
// sdiq_entry.v:567-611
assign create_src0_data[9]   = x_create_data[SDIQ_SRC0_LSU_MATCH];  // bit[9]
assign create_src0_data[8:0] = x_create_data[SDIQ_SRC0_DATA:SDIQ_SRC0_DATA-8];
// 即 create_data[10:2]，包含：preg[6:0] + WB + RDY

ct_idu_dep_reg_entry  x_ct_idu_is_sdiq_src0_entry (
  ...
  .x_create_data   (create_src0_data[9:0]),
  .x_write_en      (x_create_dp_en),
  .x_rdy_clr       (src0_rdy_clr),
  .x_read_data     (read_src0_data[11:0]),
  ...
);
assign src0_rdy_for_issue = read_src0_data[9];  // dep 模块输出的就绪状态
```

`dep_reg_entry` 内部：在创建时记录物理寄存器号，此后每周期广播比较——若任意写回总线的寄存器号匹配，则置位就绪。`src0_rdy_for_issue` 是最终就绪输出。

### 7.4 唤醒总线覆盖

SDIQ 监听以下写回总线（`sdiq_entry.v` 的 dep_reg_entry 连接端口）：

| 来源 | 信号 | 阶段 |
|---|---|---|
| IU pipe0 EX2 | `iu_idu_ex2_pipe0_wb_preg_*` | EX2 整数写回 |
| IU pipe1 EX2 | `iu_idu_ex2_pipe1_wb_preg_*` | EX2 乘法/整数写回 |
| IU div | `iu_idu_div_inst_vld` / `div_preg` | 除法结果写回 |
| LSU pipe3 AG | `lsu_idu_ag_pipe3_preg_*` | load 地址计算阶段 |
| LSU pipe3 DC | `lsu_idu_dc_pipe3_preg_*` | load DC 阶段（含 fwd） |
| LSU pipe3 WB | `lsu_idu_wb_pipe3_wb_preg_*` | load 最终写回 |
| VFPU pipe6/7 EX1 | `vfpu_idu_ex1_pipe6/7_mfvr_inst_vld_dupx` / `preg` | 向量移标量写回 |
| RF pipe0/1 lch | `ctrl_xx_rf_pipe0/1_preg_lch_vld_dupx` | RF 阶段前递 |

### 7.5 rdy_clr：launch fail 时撤销就绪

```verilog
// sdiq_entry.v:562-563
assign src0_rdy_clr  = x_rf_frz_clr && dp_sdiq_rf_rdy_clr[0];
assign srcv0_rdy_clr = x_rf_frz_clr && dp_sdiq_rf_rdy_clr[1];
```

当发射失败（`ctrl_sdiq_rf_lch_fail_vld`，指 RF 阶段发现数据还未就绪）时，对应 entry 的就绪位被清除，下次重新等待唤醒。

---

## 8. Store 地址就绪追踪

这是 SDIQ 区别于其他发射队列的**核心独特逻辑**：除了等待数据源寄存器就绪，还需要等待对应的 store 地址微操作完成（进入 STQ）。

### 8.1 两种地址状态

```verilog
// sdiq_entry.v:184-194（entry 寄存器声明）
reg staddr0_rdy;   // staddr 微操作 0 已进 STQ 且就绪
reg staddr1_rdy;   // staddr 微操作 1 已进 STQ 且就绪（非对齐 store）
reg staddr0_in_stq;
reg staddr1_in_stq;
reg stdata1_vld;   // 当前 entry 是非对齐 store 的第 2 个 stdata
reg unalign;       // 非对齐 store
```

对于普通 store，只有 staddr0。对于**非对齐 store**（跨 8 字节边界），地址和数据都被拆成两条，形成 staddr0+staddr1 和 stdata0+stdata1 四条微操作。`stdata1_vld` 标记当前 entry 是第 2 个数据微操作。

### 8.2 staddr_rdy 的置位

```verilog
// sdiq_entry.v:452-466（staddr0 就绪逻辑）
assign staddr0_rdy_set = staddr0_in_stq        // 情况1：之前已记录在 STQ
                         || x_staddr_rdy_set
                            && !dp_sdiq_rf_staddr1_vld;  // 情况2：本周期 staddr RF 阶段通过且是 staddr0

always @(posedge entry_clk or negedge cpurst_b)
begin
  ...
  else if(staddr0_rdy_clr)
    staddr0_rdy <= 1'b0;
  else if(staddr0_rdy_set)
    staddr0_rdy <= 1'b1;
end
```

`x_staddr_rdy_set` 来自顶层的 `sdiq_entry_staddr_rdy_set`，而后者来自：

```verilog
// sdiq.v:1429-1430
assign sdiq_entry_staddr_rdy_set[11:0] = {12{ctrl_sdiq_rf_staddr_rdy_set}}
                                         & dp_sdiq_rf_sdiq_entry[11:0];
```

当 staddr 微操作在 **RF 阶段（pipe4）** 通过时（`ctrl_sdiq_rf_staddr_rdy_set = 1`），由 `dp_sdiq_rf_sdiq_entry`（12 位 one-hot）指定哪个 SDIQ entry 的地址就绪了。这是通过 staddr 和 stdata 共享同一个 `sdiq_entry` 编号实现的跨队列通信。

### 8.3 staddr_stq_create：DC 阶段进一步确认

```verilog
// sdiq.v:1447-1448
assign sdiq_entry_staddr_stq_create[11:0] = {12{lsu_idu_dc_staddr_vld}}
                                            & lsu_idu_dc_sdiq_entry[11:0];
```

当 staddr 微操作在 **pipe4 DC 阶段**确认进入 STQ（`lsu_idu_dc_staddr_vld`），`x_staddr_stq_create` 信号使对应 entry 的 `staddr0_in_stq` / `staddr1_in_stq` 永久置位，并记录 `unalign` 标志：

```verilog
// sdiq_entry.v:505-512
else if(x_staddr_stq_create && !lsu_idu_dc_staddr1_vld) begin
  staddr0_in_stq <= 1'b1;
  unalign        <= lsu_idu_dc_staddr_unalign;
end
```

一旦 `staddr_in_stq` 置位，即使 `staddr_rdy` 被意外清除（如 flush 后重发），也能通过 `staddr0_in_stq || ...` 的逻辑重新设置 `staddr0_rdy`。

### 8.4 staddr_rdy 的清除

```verilog
// sdiq_entry.v:449-451（staddr0 清除条件）
assign staddr0_rdy_clr = x_rf_frz_clr
                         && dp_sdiq_rf_staddr_rdy_clr
                         && !dp_sdiq_rf_stdata1_vld;
```

当 RF 阶段发射失败（`x_rf_frz_clr`）且 `dp_sdiq_rf_staddr_rdy_clr` 指示地址未完全就绪，且是 stdata0（不是 stdata1），则清除 staddr0_rdy，让 entry 重新等待。

---

## 9. 冻结（Freeze）机制

### 9.1 freeze 的用途

```verilog
// sdiq_entry.v:384-398
assign x_vld_with_frz = vld && !frz;

always @(posedge entry_clk or negedge cpurst_b)
begin
  ...
  else if(x_create_en)
    frz <= 1'b0;   // 注意：create 时 frz 始终为 0（SDIQ 不 bypass）
  else if(x_rf_frz_clr || x_ex1_frz_clr)
    frz <= 1'b0;
  else if(x_issue_en)
    frz <= 1'b1;   // 发射时进入冻结态
end
```

`frz`（冻结）是发射队列中用于"speculative issue"的保护机制：

- 当 entry 被选中发射时，设置 `frz = 1`，阻止该 entry 参与下一轮发射仲裁（`x_vld_with_frz = vld && !frz`）。
- 如果 RF 阶段读寄存器失败（launch fail），`x_rf_frz_clr = 1`，解冻并清除就绪状态，让 entry 重新等待并再次参与发射。
- 如果 pipe5 EX1 阶段成功（`x_ex1_frz_clr = 1`），解冻——但并不立即 pop，实际 pop 由 `lsu_idu_ex1_sdiq_pop_vld` 控制。

**为什么 create 时 frz = 0 且注释说 SDIQ 不 bypass？** 其他发射队列（如 ALU 队列）支持 bypass：指令在入队前如果数据已就绪可以直接"旁路"发射。但 SDIQ 不支持，因为 store data 还需要等待 staddr 进入 STQ，无法在入队时就确定是否可以发射。

### 9.2 frz_clr 的两条路径

| 信号 | 来源 | 触发条件 | 额外效果 |
|---|---|---|---|
| `x_rf_frz_clr` | `ctrl_sdiq_rf_lch_fail_vld & dp_sdiq_rf_lch_entry[i]` | RF 阶段 launch 失败 | 同时清除 src rdy 和 staddr_rdy |
| `x_ex1_frz_clr` | `lsu_idu_ex1_sdiq_frz_clr & lsu_idu_ex1_sdiq_entry[i]` | EX1 阶段成功解冻 | 设置 `stdata1_vld = 1`（非对齐场景） |

---

## 10. 发射就绪与选择逻辑

### 10.1 entry 就绪判断

```verilog
// sdiq_entry.v:723-729
assign x_rdy = vld
               && !frz
               && src0_rdy_for_issue      // 整数数据源就绪
               && srcv0_rdy_for_issue     // 向量数据源就绪（无向量则恒 1）
               && (load                   // 情况1：load 操作（特殊，无需等 staddr）
                  || !stdata1_vld && staddr0_rdy   // 情况2：stdata0，等 staddr0
                  ||  stdata1_vld && staddr1_rdy); // 情况3：stdata1，等 staddr1
```

五个条件缺一不可：
1. 该 entry 有效（`vld`）
2. 未处于冻结状态（`!frz`）
3. 整数数据源就绪（`src0_rdy_for_issue`，由 dep_reg_entry 输出）
4. 向量数据源就绪（`srcv0_rdy_for_issue`，由 dep_vreg_entry 输出；若无向量源则常为 1）
5. 对应的 store 地址已进入 STQ（`staddr0_rdy` 或 `staddr1_rdy`，视对齐情况）

`load` 标志的特殊处理：存在少量情况下 SDIQ 项实际上是 load 语义（具体场景需参考 IDU ctrl 的 dp 逻辑），此时绕过 staddr_rdy 检查。

### 10.2 older entry 仲裁（保序发射）

```verilog
// sdiq.v:1224-1262
// 计算是否有更老的就绪 entry
assign sdiq_older_entry_ready[0] = |(sdiq_entry0_agevec[10:0]
                                     & sdiq_entry_ready[11:1]);
// agevec 非零 bit 对应的 entry 是否就绪
...
// entry i 的 issue_en = 自己就绪 && 没有更老的就绪 entry
assign sdiq_entry_issue_en[11:0] = sdiq_entry_ready[11:0]
                                   & ~sdiq_older_entry_ready[11:0];
```

**关键思路**：entry i 的年龄向量 `agevec[10:0]` 中，置 1 的 bit 代表"比 i 更老的 entry"。`sdiq_older_entry_ready[i]` = 这些更老 entry 中有没有就绪的。如果没有，entry i 就可以发射（`issue_en[i] = 1`）。

由于年龄向量维护了严格的程序顺序关系，这保证了 SDIQ 始终选择就绪指令中**最老**的那条发射，维持 store 的程序顺序。

### 10.3 发射数据读出

```verilog
// sdiq.v:1317-1346（case 语句选出发射 entry 的数据）
always @(...)
begin
  case (sdiq_entry_issue_en[11:0])
    12'h001: sdiq_entry_read_data = sdiq_entry0_read_data;
    12'h002: sdiq_entry_read_data = sdiq_entry1_read_data;
    ...
    12'h800: sdiq_entry_read_data = sdiq_entry11_read_data;
    default: sdiq_entry_read_data = {SDIQ_WIDTH{1'bx}};
  endcase
end

assign sdiq_dp_issue_read_data[SDIQ_WIDTH-1:0] =
         sdiq_entry_read_data[SDIQ_WIDTH-1:0];
```

`issue_en` 是 one-hot（最多只有 1 个 entry 被选中），因此 case 语句的每个分支互斥，实现了 12:1 的数据选择器。

### 10.4 全局发射使能

```verilog
// sdiq.v:1280-1293
assign sdiq_xx_issue_en = |sdiq_entry_ready[11:0];  // 只要有 entry 就绪就置 1

// 时序优化版：基于 vld_with_frz（不等 src rdy），提前一拍给 gated clock 使用
assign sdiq_xx_gateclk_issue_en = sdiq_entry0_vld_with_frz
                                  || sdiq_entry1_vld_with_frz
                                  || ...
                                  || sdiq_entry11_vld_with_frz;
```

`sdiq_xx_issue_en` 输出给 IDU RF 阶段的 ctrl 模块，决定是否在本周期从 SDIQ 发射一条指令。`gateclk_issue_en` 是时序优化版本，仅判断是否有非冻结的有效 entry，用于提前开启 RF 阶段的时钟门控。

---

## 11. 发射到 pipe5：store data 路径

### 11.1 pipe5 的定位

C910 的 LSU 有三条 pipe：

| Pipe | 用途 | 来源队列 |
|---|---|---|
| pipe3 | load/store 地址计算（AGU）、load 数据 | LSIQ |
| pipe4 | store 地址提交（DC/STQ） | LSIQ（经 pipe3 流入） |
| pipe5 | store 数据写入（stdata） | SDIQ |

SDIQ 发射到 pipe5，pipe5 的主要任务是：
1. 从物理寄存器堆（RF）读取 store 数据（rs2 的值）
2. 将数据发送到 STQ 中已分配好地址的项

### 11.2 为什么没有 pipe5 的译码（rf_dp 无 pipe5_decd）

与 pipe0/1（ALU）、pipe2（BRU/BJU）、pipe3（LSU 地址）不同，**pipe5 不需要复杂译码**，原因：

- Store data 的操作极为简单：从 RF 读出 rs2，写入 STQ 对应项。
- 没有立即数扩展、没有 ALU 运算、没有分支预测，只需要"把数据读出来，放到对应地址的 STQ 槽"。
- 因此 IDU 的 `ct_idu_rf_dp` 模块中不需要 pipe5 的专用译码路径；SDIQ 的 `sdiq_dp_issue_read_data[26:0]` 直接提供了 RF 读取所需的物理寄存器号（`preg[6:0]`）。

这也是 store data 路径设计简洁的体现：数据通路的下游模块（LSU pipe5）读到的就是物理寄存器号和一些控制位，不需要经过 IDU 的额外译码。

### 11.3 发射到执行的完整信息流

```
SDIQ 发射时输出：
  sdiq_dp_issue_entry[11:0]      → 告知 RF/ctrl：哪个 entry 发射了
  sdiq_dp_issue_read_data[26:0]  → 携带数据字：
      bit[10:4] = src0_preg[6:0] → RF 读端口地址（读 rs2 数据）
      bit[0]    = src0_vld       → 是否需要读整数 RF
      bit[1]    = srcv0_vld      → 是否需要读向量 RF
      bit[26]   = load           → 特殊标记
      bit[24:23]= staddr_in_stq  → staddr 进 STQ 状态
      bit[22]   = unalign        → 非对齐 store
```

---

## 12. 与 LSIQ/LSU 的协同：地址与数据在 LSU 汇合

### 12.1 store 指令的完整生命周期

```
                    IDU 阶段                          LSU 执行阶段
  ┌─────────────────────────────────────────────────────────────────────┐
  │                                                                     │
  │  IR 重命名：同时分配                                                  │
  │   ├── lsiq entry N   ────── 发射 ──► pipe3 RF ──► pipe3 AGU        │
  │   └── sdiq entry M   ─────────────────────────────┐                │
  │            │                                       │ AGU 计算地址    │
  │            │  (等待 staddr 就绪)                    │                │
  │            │◄── ctrl_sdiq_rf_staddr_rdy_set ───── RF 阶段确认 ────►│
  │            │                                       │ DC 阶段写入 STQ │
  │            │◄── lsu_idu_dc_staddr_vld ─────────── DC stage ──────►│
  │            │                                                        │
  │            │  (staddr_rdy & src0_rdy，就绪)                          │
  │            └── 发射 ──────────────────────────────► pipe5 RF       │
  │                                                    读 rs2 数据      │
  │                                                    写入 STQ[entry] │
  │                                                    store commit ──►│
  └─────────────────────────────────────────────────────────────────────┘
```

### 12.2 关键协同信号详解

| 信号 | 方向 | 时机 | 作用 |
|---|---|---|---|
| `lsu_idu_ex1_sdiq_pop_vld` | LSU→SDIQ | EX1 成功通过 | 将对应 entry 出队（`vld <= 0`） |
| `lsu_idu_ex1_sdiq_entry[11:0]` | LSU→SDIQ | EX1 成功通过 | 哪个 entry 出队（one-hot） |
| `lsu_idu_ex1_sdiq_frz_clr` | LSU→SDIQ | EX1 阶段 | 解冻 entry（供非对齐第 2 条使用） |
| `ctrl_sdiq_rf_staddr_rdy_set` | ctrl→SDIQ | RF 阶段 staddr 通过 | 设置对应 entry 的 staddr_rdy |
| `dp_sdiq_rf_sdiq_entry[11:0]` | dp→SDIQ | RF 阶段 staddr 通过 | 指示哪个 sdiq entry 的 staddr 就绪 |
| `lsu_idu_dc_staddr_vld` | LSU→SDIQ | DC 阶段 staddr 入 STQ | 设置 staddr_in_stq |
| `lsu_idu_dc_sdiq_entry[11:0]` | LSU→SDIQ | DC 阶段 staddr 入 STQ | 指示哪个 sdiq entry |
| `ctrl_sdiq_rf_lch_fail_vld` | ctrl→SDIQ | RF launch 失败 | 解冻 + 清除 rdy |
| `dp_sdiq_rf_lch_entry[11:0]` | dp→SDIQ | RF launch 失败 | 指示哪个 entry launch 失败 |

### 12.3 staddr entry 与 stdata entry 的绑定

LSIQ（staddr）和 SDIQ（stdata）中的对应项通过**共享 sdiq_entry 编号**绑定：
- 在 IR 阶段重命名时，同时分配 lsiq entry 和 sdiq entry，并把 sdiq entry 编号记录在 lsiq entry 中
- 当 staddr 指令在 pipe4 执行时，LSU 通过 `lsu_idu_dc_sdiq_entry[11:0]`（one-hot）告诉 SDIQ 哪个 sdiq entry 对应的地址已经入 STQ

---

## 13. 向量 Store 数据处理

### 13.1 向量 store 的数据源

对于向量 store（如 `vs1, 8(x2)` 类型指令），数据来自向量寄存器而非整数寄存器，因此使用 `srcv0`（`dep_vreg_entry`）而非 `src0`（`dep_reg_entry`）。

```verilog
// sdiq_entry.v:1（字段）
parameter SDIQ_SRCV0_VLD  = 1;  // bit[1] = 1：向量 store
parameter SDIQ_SRC0_VLD   = 0;  // bit[0] = 0：无整数源
```

### 13.2 向量写回总线

`dep_vreg_entry` 监听以下向量写回总线（`sdiq_entry.v:636-674`）：

| 来源 | 信号 | 阶段 |
|---|---|---|
| LSU pipe3 AG | `lsu_idu_ag_pipe3_vload_inst_vld` + `vreg_dupx` | 向量 load AGU |
| LSU pipe3 DC | `lsu_idu_dc_pipe3_vload_*` | 向量 load DC |
| LSU pipe3 WB | `lsu_idu_wb_pipe3_wb_vreg_*` | 向量 load WB |
| VFPU pipe6/7 EX1~EX3 | `vfpu_idu_ex1/2/3_pipe6/7_data_vld_dupx` + `vreg` | VFPU 各执行阶段 |
| VFPU pipe6/7 EX5 WB | `vfpu_idu_ex5_pipe6/7_wb_vreg_*` | VFPU 最终写回 |

向量流水线延迟更长（最多到 EX5），因此监听点比整数多。

### 13.3 srcv0 的读数据解析

```verilog
// sdiq_entry.v:686-690
assign x_read_data[SDIQ_SRCV0_WB]                     = read_srcv0_data[1];
assign x_read_data[SDIQ_SRCV0_VREG:SDIQ_SRCV0_VREG-6] = read_srcv0_data[8:2];
assign srcv0_rdy_for_issue                            = read_srcv0_data[9];
```

`read_srcv0_data[8:2]` 对应 7 位向量寄存器号（vreg），发射时 RF 阶段用此号读取向量 RF。

### 13.4 freg 与 vreg 的区分

```verilog
// sdiq_entry.v:715-718
// x_read_data[SDIQ_SRCV0_VREG] 为 1 → 真正的向量寄存器（vreg）
// x_read_data[SDIQ_SRCV0_VREG] 为 0 → 浮点寄存器（freg，借用 srcv0 通道）
assign x_srcv_vreg_expand[63:0] =
  {64{vld && srcv0_vld && x_read_data[SDIQ_SRCV0_VREG]}} & read_data_srcv0_vreg_expand[63:0];
assign x_srcf_freg_expand[63:0] =
  {64{vld && srcv0_vld && !x_read_data[SDIQ_SRCV0_VREG]}} & read_data_srcv0_vreg_expand[63:0];
```

浮点 store（`fs1, 8(x2)` 类型）的数据源是浮点寄存器，它们借用 `srcv0` 通道传递，通过 `SDIQ_SRCV0_VREG` 位（bit[20]）区分：为 1 是 vreg，为 0 是 freg。

---

## 14. 物理寄存器 Dealloc Mask

### 14.1 用途

SDIQ 向 RTU 的 PST（物理寄存器表）提供 dealloc mask，告知哪些物理寄存器当前仍被 SDIQ 中的 entry 引用，**不能释放**。

### 14.2 计算逻辑

每个 entry 输出自己的 preg expand（96 位，one-hot 编码的物理寄存器号）：

```verilog
// sdiq_entry.v:713-714
assign x_src0_preg_expand[95:0] = {96{vld && src0_vld}}
                                  & read_data_src0_preg_expand[95:0];
```

顶层将所有 entry 的 expand 做 OR 汇总：

```verilog
// sdiq.v:1505-1517
assign sdiq_src0_preg_dealloc_mask_updt[95:0] =
           sdiq_entry0_src0_preg_expand[95:0]
         | sdiq_entry1_src0_preg_expand[95:0]
         | ...
         | sdiq_entry11_src0_preg_expand[95:0];
```

然后用一个时钟门控的寄存器缓存（延迟一拍）输出给 RTU，避免每周期大量 OR 逻辑的时序压力：

```verilog
// sdiq.v:1545-1557
always @(posedge src_mask_clk or negedge cpurst_b)
begin
  ...
  else if(sdiq_src_reg_mask_update_vld_ff)
    sdiq_src0_preg_dealloc_mask[95:0] <= sdiq_src0_preg_dealloc_mask_updt[95:0];
end
assign idu_rtu_pst_preg_dealloc_mask[95:0] = sdiq_src0_preg_dealloc_mask[95:0];
```

`sdiq_src_reg_mask_update_vld_ff` 是更新有效信号的打一拍版本，触发条件包括：flush、create、pop（任何改变队列内容的事件都要更新 mask）。

类似地还有 `idu_rtu_pst_freg_dealloc_mask[63:0]` 和 `idu_rtu_pst_vreg_dealloc_mask[63:0]`，分别对应浮点和向量寄存器。

---

## 15. Flush 处理

### 15.1 flush 来源

SDIQ 仅响应来自 RTU 的全局 flush 信号 `rtu_yy_xx_flush`，而**不响应**前端或 IS 级的局部 flush。

注释明确说明（`sdiq_entry.v:564-565`）：
```verilog
//SDIQ is flush by backend rtu_yy_xx_flush, not frontend or IS
//flush
```

原因：SDIQ 对应的是 store 数据微操作，这些已进入发射队列的指令已经过了重命名，只有在分支预测失败等后端异常（由 RTU 检测并发出全局 flush）时才需要清空。前端 flush（取指/译码错误）不影响已在队列中的指令。

### 15.2 flush 的全局效果

`rtu_yy_xx_flush` 触发时：

1. **所有 entry 的 vld 清零**（`sdiq_entry.v:371-372`）：
```verilog
else if(rtu_yy_xx_flush)
  vld <= 1'b0;
```

2. **entry 计数器清零**（`sdiq.v:659`）：
```verilog
else if(rtu_yy_xx_flush)
  sdiq_entry_cnt[3:0] <= 4'b0;
```

3. **dealloc mask 清零**（`sdiq.v:1549`）：
```verilog
else if(rtu_yy_xx_flush)
  sdiq_src0_preg_dealloc_mask[95:0] <= 96'b0;
```

4. **dep 子模块的 flush**：`dep_reg_entry` 和 `dep_vreg_entry` 的 flush 接口均连接到 `rtu_yy_xx_flush`，内部就绪状态被清除（`sdiq_entry.v:599-600`）：
```verilog
.rtu_idu_flush_fe (rtu_yy_xx_flush),
.rtu_idu_flush_is (rtu_yy_xx_flush),
```

### 15.3 STQ 与 SDIQ 的 flush 协同

flush 后 STQ 中的 staddr 项也会随之无效化，因此 SDIQ 的 staddr_rdy/staddr_in_stq 状态（在各 entry 的寄存器中）随 entry vld 一同失效——因为只有 `vld=1` 的 entry 才会参与发射，flush 后这些状态不再被观察，新创建时会被重置（`x_create_en` 时所有状态清零）。

---

## 16. 时钟门控（ICG）

SDIQ 中共有三类时钟门控单元，节省功耗：

### 16.1 计数器时钟（cnt_clk）

```verilog
// sdiq.v:618-630
assign cnt_clk_en = (sdiq_entry_cnt[3:0] != 4'b0)
                    || ctrl_sdiq_create0_gateclk_en
                    || ctrl_sdiq_create1_gateclk_en;
```

只要队列非空或有新指令要创建，计数器时钟才开启。

### 16.2 各 entry 时钟（entry_clk）

```verilog
// sdiq_entry.v:333
assign entry_clk_en = x_create_gateclk_en || vld;
```

每个 entry 有独立的时钟门控：只要 entry 有效（`vld`）或本周期要创建到该 entry，该 entry 的时钟才开启。空闲 entry 全程关闭时钟。

### 16.3 源寄存器 mask 时钟（src_mask_clk）

```verilog
// sdiq.v:1467-1468
assign src_mask_clk_en = sdiq_src_reg_mask_update_vld
                         || sdiq_src_reg_mask_update_vld_ff;
```

只在队列内容变化时（create/pop/flush）才更新 dealloc mask，两周期窗口（update_vld 当周期 + 打一拍的 ff 周期）。

---

## 17. 完整数据流串讲

以一条 `sd x1, 8(x2)` 指令为例，完整追踪其 stdata 微操作在 SDIQ 中的生命周期：

```
时钟周期  阶段             事件
─────────────────────────────────────────────────────────────────────────
  T0     IDU ID           译码：识别为 store，拆分为 staddr(x2→preg_A)
                          和 stdata(x1→preg_B)
  T1     IDU IR           重命名：分配 lsiq_entry=K，sdiq_entry=M
                          stdata 的数据字写入：
                            data[0]=1 (src0_vld), data[10:4]=preg_B
                            data[26]=0 (not load)
  T2     IDU IS           create0 选中 sdiq entry M（假设 M=3）
                          sdiq_entry3_create_en=1
                          entry3: vld<=1, frz<=0, agevec<=当前有效 entry 掩码
                          dep_reg_entry 开始追踪 preg_B 的写回
  T3~Tk  IS 等待           每周期广播比较：是否有写回总线输出 preg_B 的值
                          同时等待 staddr（进 LSIQ entry K）发射、执行
  T?     pipe3 RF          staddr 指令读寄存器（preg_A），即将发射
                          ctrl_sdiq_rf_staddr_rdy_set=1,
                          dp_sdiq_rf_sdiq_entry=12'b000001000 (entry 3)
                          → entry3: staddr0_rdy<=1
  T?+1   pipe3 AGU         staddr 执行：计算 x2+8
  T?+2   pipe4 DC          staddr 写入 STQ
                          lsu_idu_dc_staddr_vld=1,
                          lsu_idu_dc_sdiq_entry[3]=1
                          → entry3: staddr0_in_stq<=1, unalign<=0
  Tw     某周期             preg_B 的值被写回（另一条指令写 x1）
                          dep_reg_entry 检测到匹配 → src0_rdy_for_issue=1
  Tr     IS 发射周期        entry3: rdy = vld && !frz
                                       && src0_rdy_for_issue   ✓
                                       && srcv0_rdy_for_issue  ✓ (无向量)
                                       && staddr0_rdy           ✓
                          older_entry_ready[3]=0 → issue_en[3]=1
                          sdiq_dp_issue_entry[3]=1
                          sdiq_dp_issue_read_data = entry3 数据字
                          entry3: frz<=1（冻结，等 RF 确认）
  Tr+1   RF 阶段           读 preg_B → 得到 x1 的值
                          假设读取成功：
                          lsu_idu_ex1_sdiq_frz_clr 在 EX1 解冻
  Tr+2   pipe5 EX1         store data 执行：
                          lsu_idu_ex1_sdiq_pop_vld=1,
                          lsu_idu_ex1_sdiq_entry[3]=1
                          → entry3: vld<=0（出队）
                          sdiq_entry_cnt 减 1
  Tr+3   STQ              store 数据写入 STQ[对应地址项]，等待提交
```

---

## 附录：关键寄存器状态机总结

```
entry.vld:
  复位/flush ──► 0
  create_en  ──► 1
  pop_vld && pop_cur ──► 0

entry.frz:
  复位/flush/create ──► 0
  rf_frz_clr / ex1_frz_clr ──► 0
  issue_en ──► 1

entry.staddr0_rdy:
  复位/create ──► 0
  staddr0_rdy_clr ──► 0
  staddr0_rdy_set（staddr RF 通过 || staddr0_in_stq） ──► 1

entry.src0_rdy（由 dep_reg_entry 内部维护）:
  复位/create/flush ──► 0
  广播匹配到 preg ──► 1
  rf_frz_clr && rdy_clr ──► 0（launch fail）
```

---

**文档对应 RTL 文件：**
- `/home/wangwy/openproject/openc910/C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_sdiq.v`（2637 行）
- `/home/wangwy/openproject/openc910/C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_sdiq_entry.v`（734 行）
