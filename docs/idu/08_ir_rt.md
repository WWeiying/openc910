# C910 IDU 整数寄存器重命名表（ir_rt）详解

**RTL 文件**：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_ir_rt.v`（5275 行）  
**子模块**：`ct_idu_dep_reg_src2_entry.v`（每个架构寄存器对应一个实例）  
**模块名**：`ct_idu_ir_rt`

---

## 目录

1. [模块概述：寄存器重命名原理与 RAT 的作用](#1-模块概述)
2. [参数定义：依赖信息掩码 DEP_INST*_MASK](#2-参数定义)
3. [端口说明](#3-端口说明)
4. [重命名表结构：每个架构寄存器的存储单元](#4-重命名表结构)
5. [查表逻辑：读取源寄存器的物理映射](#5-查表逻辑)
6. [表更新逻辑：写入新映射](#6-表更新逻辑)
7. [同周期多指令依赖旁路](#7-同周期多指令依赖旁路)
8. [依赖信息生成：src_match 信号与唤醒机制](#8-依赖信息生成)
9. [flush 恢复机制：基于退休状态的 RAT 恢复](#9-flush-恢复机制)
10. [x0 寄存器的特殊处理](#10-x0-寄存器的特殊处理)
11. [总结：一个 rename 周期的完整数据流](#11-总结)

---

## 1. 模块概述

### 1.1 寄存器重命名的体系结构动机

乱序处理器在调度指令时面临三种数据相关：

| 相关类型 | 示例 | 性质 |
|---------|------|------|
| RAW（先写后读，真相关） | `add x1, x2, x3` → `sub x4, x1, x5` | 真实依赖，必须等待 |
| WAR（先读后写，反相关） | `sub x4, x1, x5` → `add x1, x2, x3` | **假**相关 |
| WAW（先写后写，输出相关） | `add x1, ...` → `add x1, ...` | **假**相关 |

WAR 和 WAW 是"假相关"，原因是：多条指令碰巧使用了同一个**架构寄存器名字**，但逻辑上它们之间并没有真正的数据依赖关系。**寄存器重命名**通过将架构寄存器（x0–x31，共 32 个）映射到更多的**物理寄存器**来消除假相关。当前 RTL 实现了 **96 项整数物理寄存器**（preg0–preg95）；物理寄存器号使用 7 位编码，但 7 位编码能力不等于实现了 128 项。

### 1.2 RAT 的作用

寄存器别名表（Register Alias Table, RAT）是实现重命名的核心数据结构，它维护一张映射表：

```
架构寄存器索引 (arch_reg[4:0]) ─→ 当前物理寄存器号 (preg[6:0])
                                   + 就绪位 (rdy)
                                   + 回写位 (wb)
                                   + MLA 就绪位 (mla_rdy)
```

每当一条指令被**重命名/派遣（Rename/Dispatch）**时，RAT 完成两件事：
1. **读**：查表得到所有源寄存器当前的物理映射及就绪状态，填入发射队列（IQ）表项。
2. **写**：如果该指令有目的寄存器，将目的架构寄存器映射到一个新分配的物理寄存器，并将旧映射记录下来（用于后续 flush 恢复或释放）。

### 1.3 C910 的实现特点

C910 的 IR/IS 内部通路可同时处理 **inst0/inst1/inst2/inst3** 四个派遣槽。这里的"4 路"准确含义是**最多 4 个内部指令/微操作完成重命名和派遣**，不能直接写成"每周期发射 4 条执行指令"：IFU/ID 原始输入最多为 3 条架构指令，拆分可扩展成 4 个内部槽，而各发射队列和执行管线随后独立选择。四路重命名带来了显著的设计复杂性：

```
同一个周期内：

inst0: ADD x5, x1, x2  (写 x5)
inst1: SUB x6, x5, x3  (读 x5，x5 依赖 inst0！)
inst2: MUL x7, x5, x6  (读 x5、x6，分别依赖 inst0、inst1！)
inst3: AND x8, x7, x6  (读 x7、x6，依赖 inst2、inst1！)
```

RAT 寄存器在本周期内尚未更新（要等时钟沿才写入），因此必须通过**组合逻辑旁路（bypass）**来正确处理同包指令间的写后读依赖。

---

## 2. 参数定义

### 2.1 `dp_rt_dep_info` 信号的作用

`dp_rt_dep_info[16:0]` 是从译码数据通路（dp）传入的**预先解码好的跨指令依赖禁止掩码**，共 17 位，每位对应一种特殊的依赖关系豁免。

```verilog
// 第 719–743 行
parameter DEP_WIDTH             = 17;

parameter DEP_INST01_SRC0_MASK  = 0;   // inst1.src0 不应旁路 inst0.dst
parameter DEP_INST01_SRC1_MASK  = 1;   // inst1.src1 不应旁路 inst0.dst
parameter DEP_INST12_SRC0_MASK  = 2;   // inst2.src0 不应旁路 inst1.dst
parameter DEP_INST12_SRC1_MASK  = 3;   // inst2.src1 不应旁路 inst1.dst
parameter DEP_INST23_SRC0_MASK  = 4;   // inst3.src0 不应旁路 inst2.dst
parameter DEP_INST23_SRC1_MASK  = 5;   // inst3.src1 不应旁路 inst2.dst
parameter DEP_INST02_PREG_MASK  = 6;   // inst2 源 不应旁路 inst0.dst（隐式依赖）
parameter DEP_INST13_PREG_MASK  = 7;   // inst3 源 不应旁路 inst1.dst（隐式依赖）
parameter DEP_INST01_VREG_MASK  = 8;   // 向量寄存器相关（预留）
parameter DEP_INST12_VREG_MASK  = 9;
parameter DEP_INST23_VREG_MASK  = 10;
parameter DEP_INST13_VREG_MASK  = 11;
parameter DEP_INST02_VREG_MASK  = 12;
parameter DEP_INST03_VREG_MASK  = 13;
parameter DEP_INST01_SRCV1_MASK = 14;
parameter DEP_INST12_SRCV1_MASK = 15;
parameter DEP_INST23_SRCV1_MASK = 16;
```

### 2.2 为什么需要这些掩码？

C910 支持**拆分指令（split instruction）**：一条复杂指令在译码后被拆为两条微操作（前后 slot），它们共享同一个架构目的寄存器编号，但实际是不同的内部操作。拆分指令对之间的某些"寄存器号相同"并不代表真实的 RAW 依赖，而只是人为的命名关联。

例如，一条 MLA（乘加）指令被拆为 MUL（inst0）和 ADD（inst1），inst1 的 src2 名义上使用了 inst0 的 dst_reg 号，但这是设计约定，不是真正的数据流依赖。此时 `DEP_INST01_SRC0_MASK` 或 `DEP_INST01_SRC1_MASK` 会被置 1，RAT 据此**禁止旁路**，从而避免错误地认为存在 RAW 依赖。

---

## 3. 端口说明

### 3.1 输入端口汇总

| 信号名 | 宽度 | 方向 | 描述 |
|--------|------|------|------|
| `forever_cpuclk` | 1 | in | 全局主时钟 |
| `cpurst_b` | 1 | in | 异步复位（低有效） |
| `ctrl_ir_stall` | 1 | in | IR 阶段流水线停顿信号 |
| `ctrl_rt_inst[0-3]_vld` | 1×4 | in | 四条指令各自的有效信号 |
| `dp_rt_dep_info[16:0]` | 17 | in | 依赖豁免掩码（见第2节） |
| `dp_rt_inst[0-3]_dst_preg[6:0]` | 7×4 | in | 新分配的目的物理寄存器号 |
| `dp_rt_inst[0-3]_dst_reg[5:0]` | 6×4 | in | 目的架构寄存器索引（bit5=扩展位） |
| `dp_rt_inst[0-3]_dst_vld` | 1×4 | in | 目的寄存器有效 |
| `dp_rt_inst[0-3]_src[0/1]_reg[5:0]` | 6×8 | in | 源寄存器架构索引 |
| `dp_rt_inst[0-3]_src[0/1/2]_vld` | 1×12 | in | 源寄存器有效 |
| `dp_rt_inst[0-3]_mla` | 1×4 | in | 指令是 MLA 类型（影响 mla_rdy 判断） |
| `dp_rt_inst[0-3]_mov` | 1×3 | in | inst0/1/2 是 MOV 指令（影响旁路） |
| `rtu_yy_xx_flush` | 1 | in | 全局 flush 信号（分支预测失败/异常） |
| `rtu_idu_flush_fe` | 1 | in | flush fetch end（用于 entry 内部 rdy/wb 恢复） |
| `rtu_idu_flush_is` | 1 | in | flush issue stage |
| `rtu_idu_rt_recover_preg[223:0]` | 224 | in | 退休单元提供的 32 个架构寄存器的恢复映射（32×7=224 位） |
| `ifu_xx_sync_reset` | 1 | in | 同步复位（触发 RAT 初始化） |
| 各流水线 wb/preg 信号 | 7×N | in | 执行单元回写通知，用于更新就绪位 |

### 3.2 输出端口汇总

| 信号名 | 宽度 | 描述 |
|--------|------|------|
| `rt_dp_inst[0-3]_src0_data[8:0]` | 9 | 源寄存器 src0 的 {preg, wb, rdy} |
| `rt_dp_inst[0-3]_src1_data[8:0]` | 9 | 源寄存器 src1 的 {preg, wb, rdy} |
| `rt_dp_inst[0-3]_src2_data[9:0]` | 10 | 隐式依赖源（dst 旧值）的 {rdy, preg, wb, mla_rdy} |
| `rt_dp_inst[0-3]_rel_preg[6:0]` | 7 | 目的寄存器的**旧物理映射**；随指令送往后续 RTU/PST 退休与物理寄存器释放协议，不表示在 IR 或发射后立即释放 |
| `rt_dp_inst01_src_match[2:0]` | 3 | inst1 的三个源是否与 inst0 的 dst 匹配 |
| `rt_dp_inst02_src_match[2:0]` | 3 | inst2 的源是否间接匹配 inst0 |
| `rt_dp_inst03_src_match[2:0]` | 3 | inst3 的源是否间接匹配 inst0 |
| `rt_dp_inst12_src_match[2:0]` | 3 | inst2 的源是否与 inst1 dst 匹配 |
| `rt_dp_inst13_src_match[2:0]` | 3 | inst3 的源是否与 inst1 dst 匹配 |
| `rt_dp_inst23_src_match[2:0]` | 3 | inst3 的源是否与 inst2 dst 匹配 |

---

## 4. 重命名表结构

### 4.1 物理组织

RAT 的查表编码覆盖 0–32 共 33 个逻辑槽位，但物理实现不是 33 个相同状态实例：

- **reg_0**：对应架构寄存器 x0，`reg_0_read_data` 直接固定为常量，没有实例化依赖状态子模块
- **reg_1 – reg_31**：对应架构寄存器 x1–x31
- **reg_32**：对应编码为 `dst_reg[5]=1, dst_reg[4:0]=0` 的扩展槽（用于拆分指令的隐式目的）

因此动态状态实例数为 32：reg1–reg32 各实例化一个 `ct_idu_dep_reg_src2_entry`。reg0 虽保留若干
自动生成的 write/create wire 名称，但没有对应 always 状态，相关写请求不改变其常量读值。

```
每个 entry 包含的状态：
┌─────────────────────────────────────────────────────────────┐
│  preg[6:0]   : 7 位物理寄存器号                              │
│  rdy         : 就绪位（1=值已预测可用，可发射）               │
│  wb          : 回写位（1=值已写入物理寄存器文件）             │
│  mla_rdy     : MLA 提前就绪位（乘加指令特殊路径）             │
│  lsu_match   : LSU 加载匹配位（bypass 用途）                  │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 read_data 总线编码

每个 entry 向外提供 13-bit 的 `x_read_data[12:0]`（在 ir_rt 中记为 `reg_N_read_data[12:0]`）：

```
x_read_data[12]   = lsu_match      (LSU load bypass 匹配标志)
x_read_data[11]   = rdy_for_bypass (旁路就绪，专用于 bypass 逻辑)
x_read_data[10]   = rdy_for_issue  (发射就绪，含 mla 和 forward 路径)
x_read_data[9]    = mla_rdy        (乘加提前就绪)
x_read_data[8:2]  = preg[6:0]      (物理寄存器号，7位)
x_read_data[1]    = wb             (已写回 PRF)
x_read_data[0]    = rdy            (当前周期主就绪位)
```

ir_rt 中实际使用的字段：

```verilog
// 第 3434–3437 行（以 inst0 src0 为例）
assign inst0_src0_read_rdy       = inst0_src0_read_data[0];   // rdy
assign inst0_src0_read_wb        = inst0_src0_read_data[1];   // wb
assign inst0_src0_read_preg[6:0] = inst0_src0_read_data[8:2]; // preg
assign inst0_src0_read_mla_rdy   = inst0_src0_read_data[9];   // mla_rdy
```

### 4.3 create_data 写入编码

动态 entry 使用 11-bit 的 `x_create_data[10:0]`。以下方程在源码中对 reg0–reg32 都生成，但 reg0
没有状态实例，真正消费该总线的是 reg1–reg32：

```verilog
// 第 3322 行（以动态 reg_1 为例）
assign reg_1_create_data[10:0] = {1'b0, r_vld, reg_1_create_preg[6:0], {2{r_vld}}};
//                                  ^      ^            ^                    ^
//                              lsu_match recover_vld  preg          {wb, rdy}
```

解读：
- 正常重命名写入时（`r_vld=0`）：`{0, 0, new_preg, 0, 0}` → rdy=0, wb=0（新映射，结果尚未就绪）
- flush 恢复写入时（`r_vld=1`）：`{0, 1, recover_preg, 1, 1}` → 将 entry 的 `rdy/wb`
  编码为 1。体系结构上这是把退休映射当作可从 PRF 读取的精确状态；本地模块只负责存储该协议状态，
  PRF 内容一致性仍由 RTU、写回和 flush 时序共同保证。

### 4.4 就绪位的动态更新（entry 内部）

就绪位由 entry 内部自动维护，不需要 ir_rt 主动写入：

```verilog
// ct_idu_dep_reg_src2_entry.v 第 281–298 行
assign alu0_data_ready = ctrl_xx_rf_pipe0_preg_lch_vld_dupx
                         && (dp_xx_rf_pipe0_dst_preg_dupx == preg);
assign alu1_data_ready = ctrl_xx_rf_pipe1_preg_lch_vld_dupx
                         && (dp_xx_rf_pipe1_dst_preg_dupx == preg);
assign load_data_ready = lsu_idu_dc_pipe3_load_inst_vld_dupx
                         && (lsu_idu_dc_pipe3_preg_dupx == preg);
// ... (mult, div, vfpu 类似)

assign rdy_update = (rdy || data_ready || wake_up) && !rdy_clear;
```

**原理**：每个 entry 监听所有执行单元的广播回写信号，当某执行单元广播的 preg 与本 entry 存储的 preg 匹配时，就绪位置 1。这是典型的**Scoreboard 唤醒**（wakeup）机制，在发射队列（IQ）中同样使用同一套信号。

回写位（wb）的更新类似，但只在结果真正写入物理寄存器文件（PRF）时才置 1：

```verilog
// ct_idu_dep_reg_src2_entry.v 第 361–385 行
assign pipe0_wb = iu_idu_ex2_pipe0_wb_preg_vld_dupx
                  && (iu_idu_ex2_pipe0_wb_preg_dupx == preg);
assign wb_update = wb || write_back;  // 单调置 1，不会清零
```

---

## 5. 查表逻辑

### 5.1 读端口组织

每条指令需要查询最多三个源寄存器：

| 字段 | 使用的 reg 索引 | 说明 |
|------|----------------|------|
| src0 | `dp_rt_instN_src0_reg[5:0]` | 第一源操作数 |
| src1 | `dp_rt_instN_src1_reg[5:0]` | 第二源操作数 |
| src2 | `dp_rt_instN_dst_reg[5:0]` | 目的寄存器的**旧映射**（用于拆分指令隐式依赖 + rel_preg 释放） |

因此 ir_rt 共有 4×3=12 个读口（组合逻辑 case 语句），分别命名为 `instN_src{0,1,dst}_read_data[12:0]`。

### 5.2 读口实现：case 语句

以 inst0 src0 为例（第 3395–3431 行）：

```verilog
// 第 3395–3431 行
always @(...)
begin
  case (dp_rt_inst0_src0_reg[5:0])
    6'd0   : inst0_src0_read_data[12:0] = reg_0_read_data[12:0];
    6'd1   : inst0_src0_read_data[12:0] = reg_1_read_data[12:0];
    ...
    6'd31  : inst0_src0_read_data[12:0] = reg_31_read_data[12:0];
    6'd32  : inst0_src0_read_data[12:0] = reg_32_read_data[12:0];
    default: inst0_src0_read_data[12:0] = {13{1'bx}};
  endcase
end
```

这是行为级 33 路组合选择：地址 0 选择 x0 常量，1–32 选择动态状态，其他 6 位编码输出 `X`。
它没有额外输出寄存器，但不等于零延迟；能否在目标采样边沿前稳定由综合后的 MUX 结构、布线和 STA 决定。

### 5.3 输出数据格式

读到的数据被分解并输出给 dp（数据通路），格式如下：

**src0/src1（9-bit 输出）：**
```verilog
// 第 3439–3443 行
assign rt_dp_inst0_src0_data[0]   = inst0_src0_read_rdy || !dp_rt_inst0_src0_vld;
assign rt_dp_inst0_src0_data[1]   = inst0_src0_read_wb  || !dp_rt_inst0_src0_vld;
assign rt_dp_inst0_src0_data[8:2] = inst0_src0_read_preg[6:0];
// bit [0] = rdy (若源不使用则视为就绪)
// bit [1] = wb  (若源不使用则视为已写回)
// bit [8:2] = preg (物理寄存器号)
```

**src2/隐式依赖（10-bit 输出）：**
```verilog
// 第 3618–3625 行
assign rt_dp_inst0_src2_data[9]   = inst0_src2_read_rdy   || !dp_rt_inst0_src2_vld;
assign rt_dp_inst0_src2_data[0]   = inst0_src2_read_mla_rdy && dp_rt_inst0_mla
                                    || !dp_rt_inst0_src2_vld;
assign rt_dp_inst0_src2_data[1]   = inst0_src2_read_wb    || !dp_rt_inst0_src2_vld;
assign rt_dp_inst0_src2_data[8:2] = inst0_src2_read_preg[6:0];
// bit [9]   = rdy（主就绪位，注意位置与 src0/1 不同）
// bit [0]   = mla_rdy（乘加提前就绪）
// bit [1]   = wb
// bit [8:2] = preg
```

### 5.4 rel_preg：旧物理寄存器号的获取

`rt_dp_inst0_rel_preg` 是目的寄存器的**当前（即将被覆盖的旧）**物理映射，用于后续在退休时由 RTU 释放回物理寄存器空闲列表：

```verilog
// 第 3629–3631 行
assign rt_dp_inst0_rel_preg[6:0] = dp_rt_inst0_dst_reg[5]
                                   ? dp_rt_inst0_dst_preg[6:0]
                                   : inst0_dst_read_data[8:2];
```

- 若 `dst_reg[5]=1`（扩展槽，如 reg_32）：rel_preg 直接用新分配的 preg 本身（该槽没有"旧值"的概念，需要自我释放）
- 否则：rel_preg = 该架构寄存器当前的物理映射（即将被新 preg 替换）

---

## 6. 表更新逻辑

### 6.1 写使能生成

写端口共四个（对应 inst0–inst3），每个写入使能条件（以 inst0 为例）：

```verilog
// 第 2351–2354 行
assign inst0_write_en = ctrl_rt_inst0_vld     // 指令有效
                        && !ctrl_ir_stall      // 无停顿
                        && !rt_recover_updt_vld // 无 flush 恢复
                        && dp_rt_inst0_dst_vld; // 有目的寄存器
```

**为什么 flush 恢复时禁止正常写？** flush 恢复（`rt_recover_updt_vld`）和正常重命名写入是互斥的优先级关系：flush 时所有 in-flight 的指令都作废，必须把 RAT 恢复到提交状态，正常写入无意义且有害。

### 6.2 寄存器选择：one-hot 展开

目的架构寄存器号 `dst_reg[4:0]`（5位，最多32个）通过 `ct_rtu_expand_32` 模块展开为 32-bit one-hot 编码 `dst_reg_lsb_expand[31:0]`，再与写使能组合：

```verilog
// 第 2355–2358 行
assign reg_write0_en[31:0] = dp_rt_inst0_dst_reg_lsb_expand[31:0]
                              & {32{inst0_write_en && !dp_rt_inst0_dst_reg[5]}};
assign reg_write0_en[32]   = dp_rt_inst0_dst_reg_lsb_expand[0]
                              && inst0_write_en && dp_rt_inst0_dst_reg[5];
```

- `dst_reg[5]=0`：映射到 reg_0–reg_31（普通寄存器）
- `dst_reg[5]=1` 且 `dst_reg[4:0]=0`：映射到 reg_32（扩展槽）

### 6.3 写入数据的优先级仲裁

当多条指令在同一周期写同一个架构寄存器时（WAW 场景），必须选择最新的那条（程序序最后的）：

```verilog
// 第 2560–2581 行（以 reg_0 为例）
always @(...)
begin
  if(reg_gateclk_write3_en[0])       // inst3 优先级最高
    reg_0_create_preg = dp_rt_inst3_dst_preg;
  else if(reg_gateclk_write2_en[0])
    reg_0_create_preg = dp_rt_inst2_dst_preg;
  else if(reg_gateclk_write1_en[0])
    reg_0_create_preg = dp_rt_inst1_dst_preg;
  else if(reg_gateclk_write0_en[0])
    reg_0_create_preg = dp_rt_inst0_dst_preg;
  else
    reg_0_create_preg = rt_recover_updt_preg[6:0]; // flush 恢复值
end
```

该数据 MUX 的源码顺序是 **inst3 > inst2 > inst1 > inst0 > recover/default**。但正常功能协议中，
`rt_recover_updt_vld=1` 会把四路 `instN_gateclk_write_en` 全部压低，所以恢复与普通写应互斥；
“recover 排在最后”不是说 flush 的功能优先级最低。若互斥协议被破坏，MUX 会按源码顺序选择较高槽位，
而不是自动保护恢复值。

**为什么 inst3 优先级最高？** 同一个周期内，程序序越靠后的指令对同一架构寄存器的写是"最终有效"的写，RAT 必须记录最新的映射。inst3 在四槽派遣包中程序序最后，优先级最高。

### 6.4 gateclk 优化

注意代码中有两套写使能：`inst_write_en`（真实写入）和 `inst_gateclk_write_en`（门控时钟写使能，忽略 stall）。

```verilog
// 第 2360–2362 行（注释说明了原因）
//gateclk write en ignore stall signal
assign inst0_gateclk_write_en = ctrl_rt_inst0_vld
                                 && !rt_recover_updt_vld
                                 &&  dp_rt_inst0_dst_vld;
```

门控请求有意不含 `ctrl_ir_stall`，而功能 `x_write_en` 含 stall，形成“宽松活动请求 + 精确状态写入”。
源码注释把它标为 timing optimization；可以确认它切断了 `local_en` 对 stall 的直接组合依赖，但
stall 是否为关键路径、建立时间改善多少必须由 STA 证明。

公共 `gated_clk_cell` 的使能为 `global_en && (module_en || local_en)`，扫描使能还可打开工艺 ICG；
未定义 `C910_USE_TSMC28_ICG` 时当前 RTL 模型直接透传时钟。因此
`instN_gateclk_write_en=0` 只表示本地不请求，不保证该叶子物理时钟停止。

---

## 7. 同周期多指令依赖旁路

### 7.1 问题描述

RAT 的寄存器是时序逻辑（触发器），在同一个重命名周期内：
- inst0 的写操作要到**下一周期时钟沿**才能被 inst1/2/3 读到
- 如果 inst1 的源寄存器与 inst0 的目的寄存器相同，直接读 RAT 得到的是**旧映射**，这是错误的

因此必须用组合逻辑旁路（forwarding）来处理同包指令间的 RAW 依赖。

### 7.2 旁路检测：match 信号

以 inst1 的 src0 依赖 inst0 的 dst 为例：

```verilog
// 第 3719–3724 行
assign rt_inst1_src0_match_inst0 =
          ctrl_rt_inst1_vld && dp_rt_inst1_src0_vld
       && ctrl_rt_inst0_vld && dp_rt_inst0_dst_vld
       && (dp_rt_inst0_dst_reg[5:0] == dp_rt_inst1_src0_reg[5:0])  // 寄存器号相同
       && (dp_rt_inst0_dst_reg[5:0] != 6'd0)                        // 排除 x0
       && !dp_rt_dep_info[DEP_INST01_SRC0_MASK];                    // 非拆分指令豁免
```

检测条件：
1. 两条指令都有效
2. 架构寄存器号相等
3. 不是 x0（x0 恒为 0，不参与重命名）
4. 不是被 DEP 掩码豁免的拆分指令对

### 7.3 旁路数据选择

检测到 match 后，依赖的源寄存器不从 RAT 读，而是直接使用较早指令的**新分配 preg**：

```verilog
// 第 3738–3761 行（inst1 src0 的三路旁路选择）
always @(...)
begin
  if(rt_inst1_src0_match_inst0 && dp_rt_inst0_mov) begin
    // inst0 是 MOV 指令：进一步透传 MOV 的源的物理映射
    rt_dp_inst1_src0_data[0]   = rt_inst0_mov_dst_rdy;
    rt_dp_inst1_src0_data[1]   = rt_inst0_mov_dst_wb;
    rt_dp_inst1_src0_data[8:2] = rt_inst0_mov_dst_preg;
    rt_dp_inst01_src_match[0]  = 1'b0;  // 已经解析了依赖，无需 IQ 继续追踪
  end
  else if(rt_inst1_src0_match_inst0) begin
    // 普通 RAW：inst1 src0 依赖 inst0 dst（结果尚未产生，rdy=0）
    rt_dp_inst1_src0_data[0]   = 1'b0;
    rt_dp_inst1_src0_data[1]   = 1'b0;
    rt_dp_inst1_src0_data[8:2] = dp_rt_inst0_dst_preg;  // 使用新分配的 preg
    rt_dp_inst01_src_match[0]  = 1'b1;  // 告知 IQ：inst1 src0 依赖 inst0
  end
  else begin
    // 无依赖：直接使用 RAT 查表结果
    rt_dp_inst1_src0_data[0]   = inst1_src0_read_rdy || !dp_rt_inst1_src0_vld;
    rt_dp_inst1_src0_data[1]   = inst1_src0_read_wb  || !dp_rt_inst1_src0_vld;
    rt_dp_inst1_src0_data[8:2] = inst1_src0_read_preg;
    rt_dp_inst01_src_match[0]  = 1'b0;
  end
end
```

### 7.4 完整的旁路优先级链（以 inst3 src0 为例）

inst3 可能依赖 inst0、inst1 或 inst2，优先级从高到低：

```verilog
// 第 4823–4873 行（inst3 src0）
if(rt_inst3_src0_match_inst2) begin
    // 依赖 inst2：使用 inst2 的目的状态（rt_inst2_dst_*）
    ...
    rt_dp_inst23_src_match[0] = rt_inst2_mov_match_inst2;
    rt_dp_inst13_src_match[0] = rt_inst2_mov_match_inst1;
    rt_dp_inst03_src_match[0] = rt_inst2_mov_match_inst0;
end
else if(rt_inst3_src0_match_inst1) begin
    // 依赖 inst1
    rt_dp_inst3_src0_data[8:2] = dp_rt_inst1_dst_preg;
    rt_dp_inst13_src_match[0]  = 1'b1;
    ...
end
else if(rt_inst3_src0_match_inst0) begin
    // 依赖 inst0
    rt_dp_inst3_src0_data[8:2] = dp_rt_inst0_dst_preg;
    rt_dp_inst03_src_match[0]  = 1'b1;
    ...
end
else begin
    // 无同包依赖：使用 RAT 查表结果
    ...
end
```

**优先级：inst2 > inst1 > inst0**。这符合程序语义：若 inst1 和 inst2 都写同一个寄存器，inst3 应看到 inst2 的结果（程序序更新的那次写）。

### 7.5 MOV 指令的同包依赖透传

`dp_rt_instN_mov` 标记译码器识别出的 zero-delay move 候选。这里的“透传”
只修改**同一重命名包内较年轻源操作数的依赖指向**，不修改 MOV 自身在 RAT 中
建立的目的映射：

- MOV 自身的逻辑目的仍写入 `dp_rt_instN_dst_preg`，即 RTU 分配的新物理号；
- 如果同包较年轻指令读取该逻辑目的，RT 可以利用 `rd=rs1` 的数值等价性，
  让消费者直接依赖 MOV 的源物理项；
- 因而省掉的是“消费者等待 MOV 新目的项”的依赖边，不应表述为
  `RAT[rd]=RAT[rs1]`，也不能仅据此断定 MOV 本身不发射或不执行。

例如：

```text
inst0: MOV x3, x7
       RAT 拍后状态仍是 RAT[x3] = inst0 新分配的 preg

inst1: ADD x5, x3, x2
       若与 inst0 同包且满足保护条件，inst1 的 x3 源可直接使用
       重命名前 RAT[x7] 的 preg/rdy/wb，而不依赖 inst0 的新 preg
```

实现上，`rt_inst0_mov_dst_preg` 这个名字表示“MOV 数值语义对应的源物理号”，
并不是“要写进 RAT 的 MOV 目的物理号”。它等于 inst0 的 src0 查表结果；
当 inst1 的某个源匹配 inst0 的逻辑目的且 `dp_rt_inst0_mov=1` 时，该源数据
选择 `rt_inst0_mov_dst_*`，相应的直接 `inst1→inst0` RAW match 被清除。若
MOV 的源本身来自同包更老指令，则另外的级联 match 仍保留真实生产者关系。

```verilog
// 第 3445–3449 行：inst0 MOV 旁路值的定义
assign rt_inst0_mov_dst_rdy       = inst0_src0_read_rdy;   // x7 的 rdy
assign rt_inst0_mov_dst_mla_rdy   = inst0_src0_read_mla_rdy;
assign rt_inst0_mov_dst_wb        = inst0_src0_read_wb;
assign rt_inst0_mov_dst_preg[6:0] = inst0_src0_read_preg[6:0];  // x7 的 preg
```

### 7.6 inst2 的 MOV 旁路安全检测

对于 inst2 的 MOV 旁路，有一个特殊的安全检测：

```verilog
// 第 4194–4197 行
assign rt_inst0_mov_bypass_over_inst1 =
          dp_rt_inst0_mov
       && !(dp_rt_inst1_dst_vld
           && (dp_rt_inst0_src0_reg[5:0] == dp_rt_inst1_dst_reg[5:0]));
```

**含义**：如果 inst0 是 MOV，且 inst0 MOV 的逻辑源与 inst1 的逻辑目的相同，
inst1 会为该逻辑寄存器建立更新版本。此时 inst2 若继续跨过 inst1 使用 inst0
重命名时看到的旧源物理项，就可能引用错误版本，并与旧映射的释放生命周期冲突。
所以该条件只允许在 inst1 没有覆盖这个逻辑源时把 inst0 的语义源映射继续透传
给 inst2。具体该依赖最终指向 inst1、inst0 或 RAT 旧映射，还要结合 inst2
自身的源匹配优先级判断，不能概括成所有场景都“必须依赖 inst1”。

---

## 8. 依赖信息生成

### 8.1 src_match 信号的语义

`rt_dp_instXY_src_match[2:0]` 是 RAT 输出的**同包依赖关系位**，告诉后续数据通路
“当前重命名包中较年轻的指令 Y，其某个整数源最终依赖较老的指令 X”。这里的
`XY` 描述同一个 IR 包内的槽号关系，不是两个不同取指包之间的比较。

| 信号 | bit[0] | bit[1] | bit[2] |
|------|--------|--------|--------|
| `rt_dp_inst01_src_match` | inst1.src0 依赖 inst0 | inst1.src1 依赖 inst0 | inst1.src2(dst) 依赖 inst0 |
| `rt_dp_inst12_src_match` | inst2.src0 依赖 inst1 | inst2.src1 依赖 inst1 | — |
| `rt_dp_inst02_src_match` | inst2.src0 间接依赖 inst0 | inst2.src1 间接依赖 inst0 | — |
| `rt_dp_inst23_src_match` | inst3.src0 依赖 inst2 | inst3.src1 依赖 inst2 | inst3.src2 依赖 inst2 |
| `rt_dp_inst13_src_match` | inst3.src0 间接依赖 inst1 | inst3.src1 间接依赖 inst1 | inst3.src2 间接依赖 inst1 |
| `rt_dp_inst03_src_match` | inst3.src0 间接依赖 inst0 | inst3.src1 间接依赖 inst0 | inst3.src2 间接依赖 inst0 |

### 8.2 IQ 中的唤醒机制

这些 match 信号进入发射队列表项后，会被用于**精确唤醒（precise wakeup）**：

```
IQ 表项携带的依赖信息：
┌────────────────────────────────────────────────────────┐
│  src0_preg[6:0]       : 等待的物理寄存器号              │
│  src0_rdy             : 是否已就绪                      │
│  src0_wb              : 是否已写回                      │
│  inst01_src0_match    : 是否依赖同包 inst0              │
│  ... (其他 match 位)                                    │
└────────────────────────────────────────────────────────┘
```

当一条指令在 IQ 中等待时，IQ 会对每个源寄存器：
1. 监听广播的执行单元写回（preg 匹配则置 rdy）
2. 如果 src_match 置位，则还需等待对应的同包指令完成执行后通知

### 8.3 间接依赖的传播

以 `rt_dp_inst02_src_match` 为例，inst2 的源通过 inst1 的 MOV 间接依赖 inst0：

```verilog
// 第 4223–4224 行（inst2 src0 依赖 inst1，inst1 是 MOV）
rt_dp_inst12_src_match[0] = 1'b0;
rt_dp_inst02_src_match[0] = rt_inst1_mov_dst_match_inst0;
//                           ^---- inst1 的 MOV src 本身是否依赖 inst0
```

这实现了**依赖链的传播**：
```
inst0 写 x5 → inst1 MOV x3←x5 → inst2 读 x3
              inst2 的 src 最终依赖 inst0，需要设置 inst02_src_match
```

---

## 9. flush 恢复机制

### 9.1 恢复策略：基于退休状态（精确状态恢复）

C910 使用**提交状态恢复**策略。RTU 的 PST（Physical Status Table）并不是一份
按逻辑寄存器索引的 RAT 快照；每个 PST 项对应一个物理寄存器，保存其生命周期和
目的逻辑寄存器号。RTU 把所有处于 RETIRE 状态的物理项按逻辑目的号转置、编码，
形成一条完整的已提交映射总线；发生 flush 时，IR_RAT 再从这条总线并行恢复。

```verilog
// 第 2430–2434 行
assign rt_recover_updt_vld         = ifu_xx_sync_reset
                                     || rtu_yy_xx_flush;
assign rt_recover_updt_preg[223:0] = (ifu_xx_sync_reset)
                                     ? rt_reset_updt_preg[223:0]   // 复位映射
                                     : rtu_idu_rt_recover_preg[223:0]; // PST 导出的退休映射
```

两种触发：
- `ifu_xx_sync_reset`：同步复位，将 RAT 恢复为初始映射（ri → pi，i=0–31）
- `rtu_yy_xx_flush`：任意 flush 事件（分支预测失败、异常、中断等），使用 RTU
  从 RETIRE 状态物理项导出的已提交映射

### 9.2 初始映射

复位时的恢复向量是一个固定常量：

```verilog
// 第 2425–2429 行
assign rt_reset_updt_preg[223:0] =
         {7'd31, 7'd30, 7'd29, ..., 7'd1, 7'd0};
//  reg_31→p31, reg_30→p30, ..., reg_1→p1, reg_0→p0
```

初始映射向量把 x0–x31 映射到 p0–p31。当前整数 PRF 实现的是 p0–p95 共 96 项，
所以可进一步进入空闲/分配流程的额外编号范围是 p32–p95；7 位编码空间中的 p96–p127 并不存在于当前 PRF，
不能称为“全部空闲物理寄存器”。

### 9.3 恢复数据的写入

恢复时，x0–x31 的 32 组映射从 `rt_recover_updt_preg[223:0]` 解包。写使能向量仍是 33 位，
因为还包含 reg32 扩展槽：

```verilog
// 第 2438–2442 行
assign reg_write_en[32:0] = {33{rt_recover_updt_vld}}  // 恢复时所有逻辑槽位有效
                            | reg_write0_en[32:0]
                            | reg_write1_en[32:0]
                            | reg_write2_en[32:0]
                            | reg_write3_en[32:0];
```

`rt_recover_updt_vld` 同时压低普通功能写和 gateclk 写条件，建立恢复与正常重命名写的互斥。reg32
没有对应的 33rd 恢复总线切片，其 create preg 默认取 0；reg0 则仍是常量读值，不会因这条 33 位使能变成
动态状态。

恢复后写入 entry 的 create_data：

```verilog
// 第 3320–3322 行
assign r_vld = rt_recover_updt_vld;
assign reg_1_create_data[10:0] = {1'b0, r_vld, reg_1_create_preg, {2{r_vld}}};
// 恢复时 r_vld=1：写入 {0, 1, recover_preg, 1, 1} → rdy=1, wb=1
// 正常写入时 r_vld=0：写入 {0, 0, new_preg,     0, 0} → rdy=0, wb=0
```

恢复 create_data 把动态 entry 的 `rdy/wb` 写成 1；正常重命名写把新目的的 `rdy/wb` 写成 0。
这是一条明确的状态编码。把恢复映射解释为“最后退休版本可从 PRF 读取”是整个精确恢复协议的不变量，
并非 `ir_rt` 能单独检查的数据内容事实。

### 9.4 与 entry 内部 flush 的配合

entry 内部在收到 `rtu_idu_flush_fe` 或 `rtu_idu_flush_is` 时，会直接将 `rdy` 和 `wb` 置 1：

```verilog
// ct_idu_dep_reg_src2_entry.v 第 309–318 行
always @(posedge dep_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    rdy <= 1'b1;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is)
    rdy <= 1'b1;  // flush：重置为就绪
  else if(x_write_en)
    rdy <= x_create_rdy;  // 新指令写入
  else
    rdy <= rdy_update;    // 执行单元唤醒
end
```

要区分两组输入：`rtu_yy_xx_flush` 生成 RAT 恢复写请求，`rtu_idu_flush_fe/is` 在 dep entry
内部把 `rdy/wb` 置为中性 1。物理 preg 索引使用独立 write clock 且没有 dep 内部 flush 分支。
系统协议通常让这些事件共同完成恢复，但若它们同周期到达，dep 的 always 优先级是
`flush_fe/is` 高于 `x_write_en`；具体逐拍结果应按三种 flush 信号的实际时序查看，不能把它们当成同一个信号。

### 9.5 恢复策略的体系结构含义

```
时间线（提交状态恢复）：

Cycle N:   inst_A(arch_x1←p45) 退休
           ──→ p45 的 PST 项进入 RETIRE，并以 dst_reg=x1 贡献恢复位图
Cycle N+k: 分支预测失败 flush
           ──→ rtu_yy_xx_flush=1
           ──→ RTU 编码 RETIRE 项导出的映射；ir_rt 恢复 RAT[x1]=p45
           ──→ 尚未退休的推测指令按全局 flush 协议失效
           ──→ 表项协议状态置为 p45 rdy=1, wb=1
```

该实现通过一条 224 位退休映射总线并行恢复 x0–x31，而不是在 `ir_rt` 内保存多份分支 RAT 快照。
若恢复请求在有效门控边沿被采样，reg1–reg31 从总线相应字段恢复 x1–x31，内部 reg32
在同一边沿写成 0；x0/reg0 没有动态状态，恢复总线中的 x0 字段不会写入本地表项。
所以这里是“一次边沿更新 32 个动态实例”，但不能写成“32 个动态架构寄存器映射”：
其中 31 个实例对应 x1–x31，另 1 个实例是内部扩展槽 reg32。
与检查点方案的面积、恢复延迟和布线代价孰优，仍需结合分支恢复总延迟、PST 面积和 224 位总线实现量化，
不能只由“没有本地多份快照”推导整体开销一定更低。

---

## 10. x0 寄存器的特殊处理

RISC-V 的 x0 寄存器硬连接为 0，任何写入都被丢弃，读取永远返回 0。

### 10.1 静态常量映射

ir_rt 中，reg_0（对应 x0）不使用 `ct_idu_dep_reg_src2_entry` 实例，而是直接用一个常量赋值：

```verilog
// 第 835 行
assign reg_0_read_data[12:0] = 13'b0111000000011;
//                                    ^          ^^ 
//                              bits[12:0]       rdy=1, wb=1（bit[1:0]）
//                            preg[6:0]=0（bit[8:2]=7'b0000000）
//                            mla_rdy=1（bit[9]=1）
//                            rdy_for_issue=1（bit[10]=1）
//                            rdy_for_bypass=1（bit[11]=1）
//                            lsu_match=0（bit[12]=0）
```

二进制展开：`13'b0111000000011`

| bit[12] | bit[11] | bit[10] | bit[9] | bit[8:2] | bit[1] | bit[0] |
|---------|---------|---------|--------|----------|--------|--------|
| lsu_match=0 | rdy_bypass=1 | rdy_issue=1 | mla_rdy=1 | preg=0 | wb=1 | rdy=1 |

x0 的**本地依赖编码**固定为 preg=0、rdy=1、wb=1。这里能直接证明的是 RAT
查表结果始终就绪；p0 的实际数据内容和写屏蔽还需结合整数 PRF 及其写使能逻辑，
不能仅从本常量进一步推导“p0 触发器永远不被写”。对依赖调度而言，读 x0 不会
因 `ir_rt` 的 ready/writeback 状态而等待。

### 10.2 写 x0 的屏蔽

由于 `dst_reg[5:0]==6'd0` 时 one-hot 展开后 `dp_rt_instN_dst_reg_lsb_expand[31:0]` 的 bit[0] 为 1，理论上会使能 `reg_write0_en[0]`。但由于：

```verilog
// 第 3723 行（match 检测）
&& (dp_rt_inst0_dst_reg[5:0] != 6'd0)  // x0 排除在外
```

所有旁路检测都排除了 x0，加上 x0 的 read_data 是静态常量，写入 reg_0 的值会被忽略（`reg_0_write_en` 信号确实可能被置位，但 reg_0 没有实际的触发器，任何写入均无效）。

实际上代码中 `reg_0_write_en = reg_write_en[0]`，但 reg_0 并未实例化 entry 模块，`reg_0_create_preg`、`reg_0_create_data` 等信号虽然被计算但没有实际的触发器接收，因此对 x0 的任何写入操作在硬件上都是无效的。

---

## 11. 总结

### 11.1 一个 rename 周期的完整数据流

```
                    ┌─────────────────────────────────────────────┐
                    │              ir_rt 模块边界                   │
                    │                                              │
  dp_rt_instN_src_reg ──→  ┌──────────────────┐ ──→ rt_dp_instN_srcX_data
                    │      │ 33 个可查逻辑槽   │     (preg, rdy, wb)
  dp_rt_instN_dst_reg ──→  │  (reg_0 ~ reg_32) │ ──→ rt_dp_instN_rel_preg
                    │      │ reg0 为常量；       │     (旧 preg，进入退休释放协议)
                    │      │ reg1~32 有动态状态  │
                    │      └──────────────────┘
                    │              ↑
  dp_rt_instN_dst_preg ─────────────────────────→ (在有效写边沿更新新 preg)
  ctrl_rt_instN_vld ──────────────────────────→
  ctrl_ir_stall ──────────────────────────────→   写使能控制
  rt_recover_updt_vld ────────────────────────→
                    │
  执行单元 wb 广播 ──────────────────────────────→ entry 内部 rdy/wb 更新
                    │
  rtu_yy_xx_flush ─────────────────────────────→  全局 flush + 恢复
  rtu_idu_rt_recover_preg ────────────────────→  PST 退休态映射（x0~x31，32×7 bit）
                    │
  各流水线 wb 信号 ──────────────────────────────→  entry 内部就绪位
                    │                                              │
                    └─────────────────────────────────────────────┘
```

### 11.2 数据流时序图

```
Cycle T（rename）：
  1. [组合] 读 RAT：src_reg → case 语句 → read_data（preg, rdy, wb）
  2. [组合] 旁路检测：inst{1,2,3} src 是否 match inst{0,1,2} dst？
  3. [组合] 旁路选择：match? 用新 dst_preg : 用 RAT 结果
  4. [组合] 生成 src_match、src_data，供后续 IS/IQ 创建数据通路采样
  5. [时序] 在满足写使能且门控时钟产生有效边沿时：
             dst_reg 对应动态 entry ← new preg

Cycle T 之后（执行中）：
  6. [每周期] entry 内部监听 wb 广播，自动更新 rdy、wb 位
  7. [恢复时] rt_recover_updt_vld=1 →
       reg1~reg31 写入 PST 的 x1~x31 退休映射，reg32 写 0；reg0 保持常量
```

### 11.3 关键设计要点总结

| 设计点 | 实现方式 | 体系结构原理 |
|--------|---------|------------|
| 四槽派遣包内旁路 | 组合逻辑 match+select，优先级链 inst3>inst2>inst1>inst0 | 同周期写入尚未更新 RAT，必须旁路 |
| MOV 同包依赖透传 | `inst0_mov_bypass_over_inst1`、级联 match 标志 | 消费者可直接依赖 MOV 的语义源映射；MOV 自身仍建立新目的物理映射 |
| 拆分指令豁免 | `DEP_INST*_MASK` 参数，禁止错误旁路 | 拆分指令对的寄存器号相同不代表 RAW |
| flush 恢复 | 224-bit 退休映射总线并行写 x0–x31，reg32 单独回到 0 | 从退休态重建推测 RAT；实际恢复总延迟还包括 flush 传播和重新取指 |
| 就绪位更新 | reg1–reg32 的 dep entry 分布式比较执行/DC/WB 事件 | 在映射项旁保存 ready/writeback 状态；广播布线与比较仍有面积和时序代价 |
| x0 特殊处理 | 静态常量 read_data，不实例化 entry | x0 硬连接为 0，无需动态管理 |
| 门控时钟请求分离 | gateclk write 条件忽略 stall，功能 write 条件保留 stall | 减少 local_en 对 stall 的直接依赖；收益由 STA/功耗报告确认 |
| 扩展槽 reg_32 | dst_reg[5]=1 时映射到 reg_32 | 支持拆分指令的隐式目的（超过 x31） |

### 11.4 与 IQ 的接口约定

RAT 向发射队列输出的每个源寄存器的 9/10-bit 数据是 IQ 表项的初始状态。IQ 后续通过：
1. 广播匹配更新 `rdy` 位
2. `src_match` 位维护跨包指令间的唤醒依赖链

当所有源的 `rdy=1` 时，指令可以被发射（issue）。`wb=1` 则表示值已在 PRF 中，可以被随时读取（不依赖 forwarding）。

---

*文档对应 RTL 文件：`ct_idu_ir_rt.v`（5275 行）及子模块 `ct_idu_dep_reg_src2_entry.v`（425 行）*
