# 14. 分支发射队列（BIQ）详解

> RTL 文件：
> - `C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_biq.v`（顶层控制，1999 行）
> - `C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_biq_entry.v`（单项逻辑，540 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [队列整体结构](#2-队列整体结构)
3. [端口说明](#3-端口说明)
4. [数据域格式（BIQ Entry 82 位）](#4-数据域格式biq-entry-82-位)
5. [Entry 分配（Dispatch 进队）](#5-entry-分配dispatch-进队)
6. [年龄向量与顺序保序](#6-年龄向量与顺序保序)
7. [源操作数唤醒机制](#7-源操作数唤醒机制)
8. [Freeze（冻结）机制](#8-freeze冻结机制)
9. [发射就绪与仲裁选择](#9-发射就绪与仲裁选择)
10. [Bypass（旁路直通）路径](#10-bypass旁路直通路径)
11. [发射到 BJU（pipe2）](#11-发射到-bjupipe2)
12. [弹出（Pop）与发射确认](#12-弹出pop与发射确认)
13. [Flush 处理](#13-flush-处理)
14. [门控时钟策略](#14-门控时钟策略)
15. [与 IFU/BHT 的关系](#15-与-ifubht-的关系)
16. [与普通 ALU 队列的差异对比](#16-与普通-alu-队列的差异对比)
17. [完整数据流时序图](#17-完整数据流时序图)

---

## 1. 模块概述

### 1.1 为什么需要独立的分支发射队列

C910 是乱序超标量处理器，同一周期可以有来自 IFU 的多条预测指令在流水线中执行。**分支/跳转指令**与普通 ALU 指令有根本性区别：

1. **预测相关**：IFU 在取指阶段就已经做了分支预测（BHT/BTB），并按预测路径继续取指。若预测错误，所有在错误路径上取来的指令都必须冲刷，代价极高。
2. **执行后校验**：分支指令发射到 BJU（Branch Jump Unit，pipe2）执行后，BJU 计算出实际跳转方向/目标，若与 IFU 预测不符则必须触发 `rtu_idu_flush_fe`/`rtu_idu_flush_is` 冲刷流水线。
3. **两个源操作数**：条件分支（beq/bne/blt 等）需要比较两个整数寄存器，因此 BIQ 每项都维护 src0 和 src1 两套依赖追踪，这与只需要单源的部分 ALU 指令不同。
4. **携带分支元数据**：除了普通的操作码/源寄存器，BIQ 还需要保存 IFU 提供的预测信息（预测跳转目标、IFU 的 `pcall`/`rts` 优化标记），供 BJU 执行后做比对。

BIQ 专门服务分支/跳转指令，目标执行单元是 **pipe2（BJU）**，物理深度为 **12 项**（entry0–entry11）。

### 1.2 BIQ 在 IDU 中的位置

```
IFU (取指+预测)
      |
      | ctrl_biq_create0/1_en
      v
  IDU Dispatch
  /           \
AIQ (pipe0/1)   BIQ  <-- 本模块
                 |
                 | biq_xx_issue_en / biq_dp_issue_read_data
                 v
            RF 读端口 → pipe2 (BJU)
                 |
                 v
            BJU 执行 → 分支结果
                 |
            预测正确? --否--> rtu_idu_flush_fe/is
                 |是
            提交 (ROB)
```

---

## 2. 队列整体结构

BIQ 由一个**顶层控制模块** `ct_idu_is_biq` 和 **12 个相同的 entry 子模块** `ct_idu_is_biq_entry` 组成，是非压缩（non-compacting）的乱序发射队列。

```
ct_idu_is_biq (顶层)
├── 计数器逻辑 (biq_entry_cnt)
├── 空/满检测 (biq_ctrl_empty / biq_ctrl_full)
├── create0/1 指针选择 (biq_entry_create0_in / create1_in)
├── 仲裁：年龄向量 + older_entry_ready
├── bypass 路径判断
├── 弹出/清零逻辑
└── x12 ct_idu_is_biq_entry
        ├── vld (有效位)
        ├── frz (冻结位)
        ├── agevec[10:0] (年龄向量)
        ├── 指令信息寄存器 (opcode/iid/pid/...)
        └── x2 ct_idu_dep_reg_entry
                ├── src0 依赖追踪
                └── src1 依赖追踪
```

### 2.1 物理深度说明

代码中实际实例化了 entry0–entry11，共 **12 项**，使用 12 位 one-hot 指针：

```verilog
// ct_idu_is_biq.v 第 499 行
assign biq_ctrl_full = (biq_entry_cnt[3:0] == 4'd12);
```

满条件为计数器到达 12，说明 12 项全部被占用时队列满。

---

## 3. 端口说明

### 3.1 输入端口分类

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `ctrl_biq_create0_en` | 输入 | 1 | create 槽 0 有效（控制面，时序关键） |
| `ctrl_biq_create0_dp_en` | 输入 | 1 | create 槽 0 数据路径使能（分拆以优化时序） |
| `ctrl_biq_create0_gateclk_en` | 输入 | 1 | create 槽 0 门控时钟使能 |
| `ctrl_biq_create1_en/dp_en/gateclk_en` | 输入 | 1 | create 槽 1 对应信号 |
| `dp_biq_create0_data[81:0]` | 输入 | 82 | 槽 0 指令数据（见第 4 节） |
| `dp_biq_create1_data[81:0]` | 输入 | 82 | 槽 1 指令数据 |
| `dp_biq_bypass_data[81:0]` | 输入 | 82 | bypass 直通数据（队列空时旁路） |
| `dp_biq_create_src0_rdy_for_bypass` | 输入 | 1 | src0 入队时已就绪（用于 bypass 判断） |
| `dp_biq_create_src1_rdy_for_bypass` | 输入 | 1 | src1 入队时已就绪（用于 bypass 判断） |
| `ctrl_biq_rf_pop_vld` | 输入 | 1 | RF 发射成功确认，允许弹出 entry |
| `dp_biq_rf_lch_entry[11:0]` | 输入 | 12 | 当前被选中发射的 entry（one-hot） |
| `ctrl_biq_rf_lch_fail_vld` | 输入 | 1 | 发射失败（load-use 等），需要 replay |
| `dp_biq_rf_rdy_clr[1:0]` | 输入 | 2 | replay 时清除 src0/src1 就绪位 |
| `ctrl_biq_rf_pipe0_alu_reg_fwd_vld[23:0]` | 输入 | 24 | pipe0 ALU 结果前递有效（每 entry 2 位） |
| `ctrl_biq_rf_pipe1_alu_reg_fwd_vld[23:0]` | 输入 | 24 | pipe1 ALU 结果前递有效（每 entry 2 位） |
| `rtu_idu_flush_fe` | 输入 | 1 | RTU 触发前端 flush（分支误预测等） |
| `rtu_idu_flush_is` | 输入 | 1 | RTU 触发 IS 级 flush |
| `rtu_yy_xx_flush` | 输入 | 1 | 全局 flush（仅用于计数器，注释说明） |
| `cp0_idu_iq_bypass_disable` | 输入 | 1 | CSR 软件禁用 bypass 优化 |

**各执行管道写回广播信号**（用于唤醒，详见第 7 节）：

| 端口名 | 说明 |
|--------|------|
| `iu_idu_ex2_pipe0_wb_preg_dupx[6:0]` + `_vld` | IU pipe0 EX2 级写回物理寄存器 |
| `iu_idu_ex2_pipe1_wb_preg_dupx[6:0]` + `_vld` | IU pipe1 EX2 级写回物理寄存器 |
| `iu_idu_ex2_pipe1_mult_inst_vld_dupx` | pipe1 乘法指令在 EX2 广播（延迟 1 拍） |
| `iu_idu_div_inst_vld` + `_preg_dupx` | 除法写回广播 |
| `lsu_idu_ag_pipe3_load_inst_vld` + `_preg` | LSU AG 级 load 预广播 |
| `lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx` + `_preg` | LSU DC 级 load forwarding |
| `lsu_idu_dc_pipe3_load_inst_vld_dupx` + `_preg` | LSU DC 级 load |
| `lsu_idu_wb_pipe3_wb_preg_dupx` + `_vld` | LSU WB 级写回 |
| `vfpu_idu_ex1_pipe6/7_mfvr_inst_vld_dupx` + `_preg` | VFPU pipe6/7 浮点→整数移动写回 |
| `dp_xx_rf_pipe0/1_dst_preg_dupx[6:0]` | RF 读阶段 pipe0/1 目标 preg（用于同周期前递检测） |
| `ctrl_xx_rf_pipe0/1_preg_lch_vld_dupx` | RF 读阶段有效标志 |

### 3.2 输出端口

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `biq_xx_issue_en` | 输出 | 1 | BIQ 有指令可发射（通知 ctrl） |
| `biq_xx_gateclk_issue_en` | 输出 | 1 | 门控时钟版本（提前一拍，时序优化） |
| `biq_dp_issue_entry[11:0]` | 输出 | 12 | 选中发射的 entry（one-hot） |
| `biq_dp_issue_read_data[81:0]` | 输出 | 82 | 选中 entry 的数据（发往 RF 读端口） |
| `biq_ctrl_empty` | 输出 | 1 | 队列空（所有 entry 无效） |
| `biq_ctrl_full` | 输出 | 1 | 队列满（当前计数 == 12） |
| `biq_ctrl_full_updt` | 输出 | 1 | 下一拍将满（提前通知 dispatch 停止） |
| `biq_ctrl_1_left_updt` | 输出 | 1 | 下一拍仅剩 1 个空位 |
| `biq_ctrl_full_updt_clk_en` | 输出 | 1 | full_updt 相关门控时钟使能 |
| `biq_top_biq_entry_cnt[3:0]` | 输出 | 4 | 当前 entry 计数（供 top 层监控） |
| `biq_aiq_create0_entry[11:0]` | 输出 | 12 | create0 指向的 entry（供 AIQ 参考） |
| `biq_aiq_create1_entry[11:0]` | 输出 | 12 | create1 指向的 entry |

---

## 4. 数据域格式（BIQ Entry 82 位）

每个 entry 保存一条 82 位的指令描述向量，参数定义在 `ct_idu_is_biq_entry.v` 第 210–232 行：

```verilog
// ct_idu_is_biq_entry.v 第 210～232 行
parameter BIQ_WIDTH          = 82;
parameter BIQ_VL             = 81;  // [81:74] 向量长度 vl[7:0]
parameter BIQ_VSEW           = 73;  // [73:71] 向量元素宽度
parameter BIQ_VLMUL          = 70;  // [70:69] 向量 LMUL
parameter BIQ_PCALL          = 68;  // [68]    调用优化标记
parameter BIQ_RTS             = 67;  // [67]    返回优化标记
parameter BIQ_PID            = 66;  // [66:62] 5 位管道 ID
parameter BIQ_LENGTH         = 61;  // [61]    指令长度（16b/32b）
parameter BIQ_SRC1_LSU_MATCH = 60;  // [60]    src1 LSU load 地址匹配
parameter BIQ_SRC1_DATA      = 59;  // [59:51] src1 依赖信息(9位)
parameter BIQ_SRC1_PREG      = 59;  // src1 物理寄存器号[59:53]
parameter BIQ_SRC1_WB        = 52;  // src1 需要写回标记
parameter BIQ_SRC1_RDY       = 51;  // [51]    src1 已就绪（读出时恒0，由dep_reg维护）
parameter BIQ_SRC0_LSU_MATCH = 50;
parameter BIQ_SRC0_DATA      = 49;  // [49:41] src0 依赖信息(9位)
parameter BIQ_SRC0_PREG      = 49;
parameter BIQ_SRC0_WB        = 42;
parameter BIQ_SRC0_RDY       = 41;  // [41]    src0 已就绪（读出时恒0）
parameter BIQ_SRC1_VLD       = 40;  // [40]    src1 有效（指令使用了 src1）
parameter BIQ_SRC0_VLD       = 39;  // [39]    src0 有效
parameter BIQ_IID            = 38;  // [38:32] 7 位指令 ID（用于 ROB）
parameter BIQ_OPCODE         = 31;  // [31:0]  32 位 RISC-V 编码
```

### 4.1 字段图示

```
 81      74 73   71 70 69  68  67  66    62  61  60     51  50     41  40  39  38    32  31         0
 +--------+-------+-----+---+---+--------+---+---+--------+---+--------+---+---+--------+-----------+
 |  vl    | vsew  |vlmul|pcl|rts|  pid   |len|s1m| src1   |s0m| src0   |s1v|s0v|  iid   |  opcode   |
 +--------+-------+-----+---+---+--------+---+---+--------+---+--------+---+---+--------+-----------+
```

### 4.2 关键字段说明

| 字段 | 位宽 | 含义 | 分支特殊性 |
|------|------|------|----------|
| `opcode[31:0]` | 32 | 完整 RISC-V 指令编码 | BJU 通过 funct3 区分 beq/bne/blt/jal/jalr 等 |
| `iid[6:0]` | 7 | 指令 ID（ROB entry 号） | flush 时按 iid 顺序判断 |
| `pid[4:0]` | 5 | 管道 ID（分支固定到 pipe2） | 标识目标执行单元 |
| `pcall` | 1 | 是否为 CALL 型跳转（如 jalr ra, 0(ra)） | IFU RAS（返回地址栈）优化 |
| `rts` | 1 | 是否为 RET 型跳转（ret/jalr x0） | IFU RAS 弹出优化 |
| `src0_vld/src1_vld` | 各 1 | 该源操作数是否存在 | beq 两个源都有效；jal 通常只有 dest |
| `src0/src1_preg[6:0]` | 7 | 重命名后物理寄存器号 | 依赖追踪的比较键 |
| `src0/src1_wb` | 各 1 | 是否需要等待写回 | 与 dep_reg_entry 配合 |
| `vl/vsew/vlmul` | — | 向量相关（保留给 V 扩展） | 当前分支不使用，保留字段 |

> **注意**：`BIQ_SRC0_RDY` 和 `BIQ_SRC1_RDY` 在 entry 对外读出时**强制为 0**（见 entry.v 第 463/527 行 `assign x_read_data[BIQ_SRC0_RDY] = 1'b0`）。实际就绪状态由 `ct_idu_dep_reg_entry` 内部维护，只通过 `src0_rdy_for_issue` / `src1_rdy_for_issue` 信号输出给 `x_rdy`，不通过数据总线携带。这是为了避免数据总线上的状态更新路径影响关键路径时序。

---

## 5. Entry 分配（Dispatch 进队）

### 5.1 每周期最多两条分支指令入队

C910 IDU 每拍最多分发（dispatch）两条指令进入各 IQ。对于分支指令，对应的是 `create0` 和 `create1` 两个槽。

### 5.2 Entry 指针选择策略

create0 使用**从低到高**优先级，create1 使用**从高到低**优先级，两者从不同方向扫描空闲位，从而**在物理上分离**，降低仲裁冲突概率：

```verilog
// ct_idu_is_biq.v 第 592～676 行（节选）
// create0：从 entry0 到 entry11 找第一个空位
always @(...)
begin
  if(!biq_entry0_vld)
    biq_entry_create0_in = 12'b0000_0000_0001; // entry0
  else if(!biq_entry1_vld)
    biq_entry_create0_in = 12'b0000_0000_0010; // entry1
  // ...
end

// create1：从 entry11 到 entry0 找第一个空位
always @(...)
begin
  if(!biq_entry11_vld)
    biq_entry_create1_in = 12'b1000_0000_0000; // entry11
  else if(!biq_entry10_vld)
    biq_entry_create1_in = 12'b0100_0000_0000; // entry10
  // ...
end
```

**为什么这样设计？** create0 和 create1 需要确保不指向同一个 entry。若同向扫描，需要先确定 create0 的选择再计算 create1，有串行依赖。反向扫描在队列未满时天然不重叠（create0 选最低空位、create1 选最高空位），消除了组合逻辑串行依赖，对时序友好。

### 5.3 入队信号拆分（控制/数据/门控）

每个 create 槽分为三路信号：

| 信号 | 用途 |
|------|------|
| `create_gateclk_en` | 仅用于打开门控时钟（含 bypass 但不做功能判断） |
| `create_en` | 控制面，用于 vld/frz/agevec 的寄存器写入 |
| `create_dp_en` | 数据面，用于 opcode/iid 等数据寄存器写入 |

三路信号的宽松度依次降低，越靠近数据存储越松弛，目的是在不影响功能正确性的前提下**减小关键路径扇出/延迟**。

```verilog
// ct_idu_is_biq.v 第 684～742 行
assign biq_entry_create_en[11:0] =
       {12{ctrl_biq_create0_en}} & biq_entry_create0_in[11:0]
     | {12{ctrl_biq_create1_en}} & biq_entry_create1_in[11:0];

assign biq_entry_create_dp_en[11:0] =
       {12{ctrl_biq_create0_dp_en}} & biq_entry_create0_in[11:0]
     | {12{ctrl_biq_create1_dp_en}} & biq_entry_create1_in[11:0];
```

### 5.4 数据选择：create_sel 优化

对于 entry0–5，用 `~biq_entry_create0_in[5:0]` 为 0 表示"选 create0 数据"；对于 entry6–11，用 `biq_entry_create1_in[11:6]` 为 1 表示"选 create1 数据"。这样两段逻辑互不干涉：

```verilog
// ct_idu_is_biq.v 第 758～761 行
assign biq_entry_create_sel[11:6] = {6{ctrl_biq_create1_dp_en}}
                                     & biq_entry_create1_in[11:6];
assign biq_entry_create_sel[5:0]  = ~({6{ctrl_biq_create0_dp_en}}
                                      & biq_entry_create0_in[5:0]);
```

注释中明确说明：`biq_entry_create0/1_in` 不会同时为 1（即同一 entry 不会被 create0 和 create1 同时选中），因此两段判断不会冲突。

### 5.5 Entry 计数器

```verilog
// ct_idu_is_biq.v 第 476～497 行
assign biq_entry_cnt_create[3:0] = {3'b0, ctrl_biq_create0_en}
                                  + {3'b0, ctrl_biq_create1_en};
assign biq_entry_cnt_updt_val[3:0] = biq_entry_cnt[3:0]
                                    + biq_entry_cnt_create[3:0]
                                    - {3'b0, ctrl_biq_rf_pop_vld};
always @(posedge cnt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    biq_entry_cnt <= 4'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush)
    biq_entry_cnt <= 4'b0;
  else if(biq_entry_cnt_updt_vld)
    biq_entry_cnt <= biq_entry_cnt_updt_val;
end
```

**注意 `rtu_yy_xx_flush`**：注释（第 489–490 行）说明，在 flush_fe/is 之后 RF 级可能在 rtu_yy_xx_flush 来临之前提前弹出一次，因此计数器需要额外响应 `rtu_yy_xx_flush` 来清零，防止计数不一致。

### 5.6 满/将满预测

```verilog
// ct_idu_is_biq.v 第 511～538 行
assign biq_ctrl_full_updt =
    (biq_entry_cnt == 4'd10) && biq_entry_cnt_create_2 && biq_entry_cnt_pop_0
 || (biq_entry_cnt == 4'd11) && biq_entry_cnt_create_1 && biq_entry_cnt_pop_0
 || (biq_entry_cnt == 4'd12) && biq_entry_cnt_create_0 && biq_entry_cnt_pop_0;
```

`biq_ctrl_full_updt` 在当前周期就预测**下一周期是否会满**，让 dispatch 控制逻辑提前停止派送，避免出现队列满后还送入指令的情况。`biq_ctrl_1_left_updt` 类似，预测下一拍仅剩 1 个空位，供 dispatch 做单发决策。

---

## 6. 年龄向量与顺序保序

### 6.1 年龄向量的含义

BIQ 是乱序发射队列，多个 entry 可能同时就绪，必须按**程序顺序**发射最老（最先进入）的那条。年龄向量（age vector）是实现这一目标的核心机制。

每个 entry 有一个 `agevec[10:0]`（11 位，对应其他 11 个 entry）。若 `agevec[j] = 1`，表示**entry j 比本 entry 更年轻**（即本 entry 先入队）。发射时，只有"没有任何更老的 entry 也就绪"的 entry 才能被选中。

### 6.2 入队时年龄向量的初始化

```verilog
// ct_idu_is_biq.v 第 744～751 行
// create0 的年龄向量：当前所有有效 entry（排除正在弹出的）
assign biq_entry_create0_agevec[11:0] = biq_entry_vld[11:0]
    & ~({12{ctrl_biq_rf_pop_vld}} & dp_biq_rf_lch_entry[11:0]);

// create1 的年龄向量：create0 的年龄向量 | create0 自身所在 entry
assign biq_entry_create1_agevec[11:0] = biq_entry_vld[11:0]
    & ~({12{ctrl_biq_rf_pop_vld}} & dp_biq_rf_lch_entry[11:0])
    | biq_entry_create0_in[11:0];
```

- create0 入队时，将当前所有有效 entry 标记为"比我老"（即它们都在我之前进队）。
- create1 入队时，额外包含 create0 所在 entry，因为同一周期 create0 比 create1 更早（程序顺序上在前）。

然后从 12 位 agevec 中去掉"本 entry 自身对应的那一位"（不需要跟自己比较），所以每个 entry 存储 11 位：

```verilog
// 以 entry0 为例（ct_idu_is_biq.v 第 774 行）：
biq_entry0_create_agevec[10:0] = biq_entry_create0_agevec[11:1];
// 去掉了 bit[0]（即 entry0 自身），保存 entry1~11 的信息
```

### 6.3 弹出时年龄向量的更新

当一条指令弹出（RF launch pass），所有还在队列中的 entry 需要清除其 agevec 中该 entry 对应的位：

```verilog
// ct_idu_is_biq_entry.v 第 332～335 行
else if(ctrl_biq_rf_pop_vld)
    agevec[10:0] <= agevec[10:0] & ~x_pop_other_entry[10:0];
```

`x_pop_other_entry` 是从 `dp_biq_rf_lch_entry` 中提取出"除本 entry 以外"的位组合，这样每个 entry 在 pop 发生时只清除"被弹出的那个 entry"对应的比较位，不影响其他位。

---

## 7. 源操作数唤醒机制

### 7.1 整体设计

每个 BIQ entry 实例化了两个 `ct_idu_dep_reg_entry` 子模块（src0 和 src1），分别负责追踪两个源操作数的就绪状态。这是**分支指令相对于部分 ALU 指令的重要区别**：条件分支（beq/bne/blt/bge 等）需要比较两个寄存器值，因此两个源都必须就绪。

```verilog
// ct_idu_is_biq_entry.v 第 407～448 行（src0）
ct_idu_dep_reg_entry  x_ct_idu_is_biq_src0_entry (
  .alu0_reg_fwd_vld (x_alu0_reg_fwd_vld[0]),   // pipe0 前递匹配
  .alu1_reg_fwd_vld (x_alu1_reg_fwd_vld[0]),   // pipe1 前递匹配
  ...
  .x_create_data    (create_src0_data[9:0]),    // 入队时传入 src0 信息
  .x_read_data      (read_src0_data[11:0]),     // 读出：[9]=rdy,[8:2]=preg,[1]=wb
  .x_rdy_clr        (src0_rdy_clr),             // replay 时清除就绪
);
```

### 7.2 写回广播匹配

`ct_idu_dep_reg_entry` 内部监听来自所有执行单元的写回广播（preg 号 + vld），一旦广播的 preg 号与本 entry 的 src preg 号匹配，就将该 src 标记为就绪。

BIQ 监听的写回源包括：

| 写回来源 | 信号 | 时序特点 |
|----------|------|---------|
| IU pipe0 EX2 写回 | `iu_idu_ex2_pipe0_wb_preg_dupx/vld` | 正常 ALU 结果，2 周期延迟 |
| IU pipe1 EX2 写回 | `iu_idu_ex2_pipe1_wb_preg_dupx/vld` | 含乘法（`mult_inst_vld` 标识延迟） |
| IU pipe1 除法 | `iu_idu_div_inst_vld/preg` | 变长延迟，完成后广播 |
| LSU AG 预告 | `lsu_idu_ag_pipe3_load_inst_vld/preg` | load 地址计算完成，可能最终 miss |
| LSU DC forwarding | `lsu_idu_dc_pipe3_load_fwd_inst_vld/preg` | load forwarding 成功 |
| LSU DC load | `lsu_idu_dc_pipe3_load_inst_vld/preg` | |
| LSU WB | `lsu_idu_wb_pipe3_wb_preg_dupx/vld` | 最终写回 |
| VFPU pipe6/7 | `vfpu_idu_ex1_pipe6/7_mfvr_inst_vld/preg` | 浮点→整数移动 |
| RF 读阶段 pipe0/1 | `dp_xx_rf_pipe0/1_dst_preg_dupx` + `ctrl_xx_rf_pipe0/1_preg_lch_vld` | 同拍前递 |

### 7.3 前递（Forwarding）唤醒

`ctrl_biq_rf_pipe0_alu_reg_fwd_vld[23:0]` 是一个 24 位向量，每 2 位对应一个 entry（src0 和 src1）：

```verilog
// ct_idu_is_biq.v 第 1095～1106 行
assign biq_entry0_alu0_reg_fwd_vld[1:0]  = ctrl_biq_rf_pipe0_alu_reg_fwd_vld[1:0];
assign biq_entry1_alu0_reg_fwd_vld[1:0]  = ctrl_biq_rf_pipe0_alu_reg_fwd_vld[3:2];
// ... 以此类推
assign biq_entry11_alu0_reg_fwd_vld[1:0] = ctrl_biq_rf_pipe0_alu_reg_fwd_vld[23:22];
```

这个信号在 RF 读取阶段（latch 阶段）产生，表示"正在 RF 读的那条指令结果可以直接前递给本 entry 的 src0/src1"，使得唤醒可以在 RF latch 阶段完成，而不必等到 EX1 写回。

### 7.4 src 数据入队格式

```verilog
// ct_idu_is_biq_entry.v 第 404～406 行
assign create_src0_data[9]   = x_create_data[BIQ_SRC0_LSU_MATCH];  // bit9: LSU match 标记
assign create_src0_data[8:0] = x_create_data[BIQ_SRC0_DATA:BIQ_SRC0_DATA-8]; // bit8:就绪位, bit7:1=wb, bit6:0=rdy原始, bit5~1:preg高位, bit0:...
```

入队时 `create_src0_data[9:0]` 包含：`[9]=LSU_MATCH`，`[8:0]` 是 `dep_reg_entry` 的 9 位创建数据（包含初始就绪状态、物理寄存器号、是否需要等写回等）。

### 7.5 读出 src 状态

```verilog
// ct_idu_is_biq_entry.v 第 460～464 行
assign x_read_data[BIQ_SRC0_WB]                    = read_src0_data[1];
assign x_read_data[BIQ_SRC0_PREG:BIQ_SRC0_PREG-6]  = read_src0_data[8:2];
assign src0_rdy_for_issue                          = read_src0_data[9];
assign x_read_data[BIQ_SRC0_RDY]                   = 1'b0;  // 不通过数据总线传递就绪
assign x_read_data[BIQ_SRC0_LSU_MATCH]             = 1'b0;
```

就绪状态 `src0_rdy_for_issue` 直接用于本地 `x_rdy` 计算，不经过数据总线，这是刻意的时序设计。

---

## 8. Freeze（冻结）机制

### 8.1 为什么要冻结

BIQ 采用**推测性发射**（speculative issue）策略：当一条指令在 RF 读取阶段发射出去后，若后续发现数据还未就绪（例如 load-use 冲突），则需要 replay（重新发射）。

在等待 replay 确认期间，已发射但未确认成功的 entry 必须处于**冻结**状态——即该 entry 仍然有效（`vld=1`），但不能再次参与发射仲裁（`vld_with_frz = vld && !frz`）。

### 8.2 Freeze 状态机

```verilog
// ct_idu_is_biq_entry.v 第 307～320 行
always @(posedge entry_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    frz <= 1'b0;
  else if(x_create_en)       // 入队时：从 biq_bypass_dp_en 获取初始 frz
    frz <= x_create_frz;
  else if(x_frz_clr)         // 发射失败（replay）：清除冻结，可再次发射
    frz <= 1'b0;
  else if(x_issue_en)        // 发射成功（进入 RF 读阶段）：冻结本 entry
    frz <= 1'b1;
  else
    frz <= frz;
end
```

状态转换：

```
           x_create_en                x_issue_en
               |                          |
    frz=0 <--- + <--- x_frz_clr  ---> frz=1
  (可发射)    (replay 清冻)         (等待确认)
               ^                          |
               |   ctrl_biq_rf_pop_vld   |
               +---- (成功弹出)           |
                                          v
                                    (pop 或 flush 清除 vld)
```

### 8.3 入队时的初始 Freeze

```verilog
// ct_idu_is_biq.v 第 773 行（以 entry0 为例）
biq_entry0_create_frz = biq_bypass_dp_en;
```

若当前指令通过 bypass 路径直接发射（`biq_bypass_dp_en=1`），入队时就设置 `frz=1`，因为该指令同时在走发射流程，entry 会立即冻结等待确认。若是普通入队（`biq_bypass_dp_en=0`），入队时 `frz=0`，等到仲裁选中后再冻结。

### 8.4 发射失败时的 Replay

```verilog
// ct_idu_is_biq.v 第 1308～1311 行
assign biq_entry0_frz_clr = ctrl_biq_rf_lch_fail_vld
                            && dp_biq_rf_lch_entry[0];
```

`ctrl_biq_rf_lch_fail_vld` 表示 RF 发射失败，`dp_biq_rf_lch_entry[0]` 标识哪个 entry 失败了。对应 entry 的 `frz_clr` 被拉高，`frz` 回到 0，该 entry 重新参与下轮发射竞争。

同时，`dp_biq_rf_rdy_clr[1:0]` 会在 replay 时清除对应的 src0/src1 就绪位（如果该 src 的数据实际上还没到），以便重新等待唤醒：

```verilog
// ct_idu_is_biq_entry.v 第 400～401 行
assign src0_rdy_clr = x_frz_clr && dp_biq_rf_rdy_clr[0];
assign src1_rdy_clr = x_frz_clr && dp_biq_rf_rdy_clr[1];
```

---

## 9. 发射就绪与仲裁选择

### 9.1 Entry 就绪条件

每个 entry 的就绪信号（`x_rdy`）在 `ct_idu_is_biq_entry.v` 第 532–535 行定义：

```verilog
// ct_idu_is_biq_entry.v 第 532～535 行
assign x_rdy = vld
               && !frz
               && src0_rdy_for_issue
               && src1_rdy_for_issue;
```

**四个条件缺一不可**：
1. `vld`：entry 有效（已入队且未弹出）
2. `!frz`：未处于冻结状态（未在等待发射确认）
3. `src0_rdy_for_issue`：src0 操作数已就绪（或本指令不需要 src0）
4. `src1_rdy_for_issue`：src1 操作数已就绪（条件分支专有要求）

### 9.2 年龄向量仲裁

仲裁在顶层完成，核心是计算 `biq_older_entry_ready`：

```verilog
// ct_idu_is_biq.v 第 1152～1185 行
// entry0 的仲裁：检查所有比 entry0 更老（agevec 中为 1）且已就绪的 entry
assign biq_older_entry_ready[0] = |(biq_entry0_agevec[10:0]
                                    & biq_entry_ready[11:1]);
// entry1 的仲裁：
assign biq_older_entry_ready[1] = |(biq_entry1_agevec[10:0]
                                    & {biq_entry_ready[11:2],
                                       biq_entry_ready[0]});
// ... 以此类推
```

注意 `biq_entry_ready[11:1]` 是 entry0 的年龄向量对应的其他 11 个 entry 的就绪信号（agevec 位 j 对应 entryj，但跳过自身那一位）。

最终发射使能：

```verilog
// ct_idu_is_biq.v 第 1189～1190 行
assign biq_entry_issue_en[11:0] = biq_entry_ready[11:0]
                                  & ~biq_older_entry_ready[11:0];
```

一个 entry 能发射，当且仅当：**自身就绪 AND 没有更老的 entry 也就绪**。由于年龄向量维护了完全偏序，理论上每周期只有一个 entry 满足此条件（除非两个 entry 恰好无法比较，但 BIQ 的年龄向量是入队时赋值完整关系，不存在此情况）。

### 9.3 整体 issue 使能

```verilog
// ct_idu_is_biq.v 第 1135～1136 行
assign biq_xx_issue_en = |{biq_bypass_en, biq_entry_ready[11:0]};
```

包含 bypass 路径：若 bypass 条件满足，即使队列中无就绪项，也拉高 issue_en。

---

## 10. Bypass（旁路直通）路径

### 10.1 Bypass 的意义

Bypass 是性能优化机制：若一条新入队的分支指令两个源操作数在 dispatch 时**已经就绪**，并且队列中**没有任何未冻结的有效项**（表明没有更老的指令在等待），则该指令可以**不实际进入队列存储**而直接发射，节省一拍延迟。

### 10.2 Bypass 条件

```verilog
// ct_idu_is_biq.v 第 549～552 行
assign biq_create0_rdy_bypass = ctrl_biq_create0_en
                                && !cp0_idu_iq_bypass_disable   // 软件未禁用
                                && dp_biq_create_src0_rdy_for_bypass
                                && dp_biq_create_src1_rdy_for_bypass;
// ...
assign biq_bypass_en = biq_create_bypass_empty   // 队列（去除冻结后）为空
                       && biq_create0_rdy_bypass;
```

`biq_create_bypass_empty` 检查所有 entry 的 `vld_with_frz`（`vld && !frz`），只要存在任何一个 entry 处于"有效且未冻结"状态，bypass 就不成立（必须先等那些更老的指令发射完）。

### 10.3 Bypass 时的数据路径

```verilog
// ct_idu_is_biq.v 第 1261～1264 行
assign biq_dp_issue_read_data[BIQ_WIDTH-1:0] =
    (biq_create_bypass_empty)
    ? dp_biq_bypass_data[BIQ_WIDTH-1:0]   // bypass：用专用旁路数据
    : biq_entry_read_data[BIQ_WIDTH-1:0]; // 正常：从 entry 读出
```

bypass 时直接使用 `dp_biq_bypass_data`，这是来自 dispatch 级的指令数据（未经过 entry 存储），同时 `biq_dp_issue_entry` 输出 `biq_entry_create0_in`（表明是哪个 entry 接收了这条指令）。

---

## 11. 发射到 BJU（pipe2）

### 11.1 发射数据流

当 BIQ 选出一条最老的就绪指令后，输出：

- `biq_dp_issue_entry[11:0]`：one-hot，指示哪个 entry 被发射
- `biq_dp_issue_read_data[81:0]`：该 entry 的完整 82 位数据（含 opcode、iid、preg 等）

下游控制器（`ct_idu_is_rf`）收到后，用 preg 号访问物理寄存器堆读取操作数，然后将：

- opcode（分支类型、立即数偏移）
- rs1/rs2 值（读自 RF）
- PC（需要从其他路径获取，BIQ 自身不存 PC，bjt 通过 iid 从 ROB 获取）
- pcall/rts 标记

一起打包送到 pipe2 的 BJU 输入锁存器。

### 11.2 BJU 的分支处理

BJU 在 EX1 阶段：
- 对于条件分支（beq/bne/...）：比较 rs1 和 rs2，确定实际方向（taken/not taken）
- 对于 jal：计算 PC + imm 得到跳转目标
- 对于 jalr：计算 rs1 + imm 得到跳转目标

EX1 结束后将结果写回（`iu_idu_ex2_pipe0/1_wb_preg`），同时将实际跳转方向/目标与 IFU 预测进行比对。

### 11.3 分支结果与 IFU 校验

若实际方向/目标与 IFU 的预测（记录在 BIQ 数据中的 `pcall/rts` 标记及预测 PC 信息，以及 IFU 内部 BHT 的预测）不符：

1. RTU 收到 BJU 的误预测通知
2. RTU 发出 `rtu_idu_flush_fe`（冲刷前端和 IS 级所有指令）
3. BIQ 中所有 entry 的 `vld` 清零（第 294–296 行）
4. IFU 重新从正确 PC 取指

---

## 12. 弹出（Pop）与发射确认

### 12.1 两阶段流程

BIQ 的发射（issue）和弹出（pop）是**异步两阶段**流程：

```
周期 N:   BIQ 仲裁，选中 entry X，biq_entry_issue_en[X]=1
          entry X 的 frz 置 1（冻结）
          
周期 N+1: RF 读取（latch）阶段
          若 RF 发射成功：ctrl_biq_rf_pop_vld=1，dp_biq_rf_lch_entry=entry X
            => entry X 的 vld=0（弹出），frz 保持（无所谓，vld=0 后不再参与）
          若 RF 发射失败：ctrl_biq_rf_lch_fail_vld=1
            => entry X 的 frz_clr=1，frz 回 0，src rdy 可能被清除
            => entry X 重新参与发射竞争
```

### 12.2 pop_other_entry 的构造

每个 entry 需要知道"被弹出的是否是我，还是其他 entry"，以更新自己的 agevec。通过位重排实现：

```verilog
// ct_idu_is_biq.v 第 1271～1304 行
// entry0：pop_cur_entry = dp_biq_rf_lch_entry[0]
//         pop_other_entry = dp_biq_rf_lch_entry[11:1]（去掉 bit0）
assign {biq_entry0_pop_other_entry[10:0],
        biq_entry0_pop_cur_entry}          = dp_biq_rf_lch_entry[11:0];

// entry1：pop_cur_entry = dp_biq_rf_lch_entry[1]
//         pop_other_entry = {dp_biq_rf_lch_entry[11:2], dp_biq_rf_lch_entry[0]}
assign {biq_entry1_pop_other_entry[10:1],
        biq_entry1_pop_cur_entry,
        biq_entry1_pop_other_entry[0]}     = dp_biq_rf_lch_entry[11:0];
```

这样每个 entry 的 `pop_other_entry[10:0]` 是从 12 位 lch_entry 中去除自己那一位后的 11 位向量，与自己的 `agevec[10:0]` 一一对应，可以直接做 AND 清除操作。

---

## 13. Flush 处理

### 13.1 Entry 级 Flush

每个 entry 的 `vld` 直接响应 flush 信号：

```verilog
// ct_idu_is_biq_entry.v 第 290～302 行
always @(posedge entry_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    vld <= 1'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is)
    vld <= 1'b0;          // flush：立即清除有效位
  else if(x_create_en)
    vld <= 1'b1;          // 入队：置有效
  else if(ctrl_biq_rf_pop_vld && x_pop_cur_entry)
    vld <= 1'b0;          // 发射成功：弹出
  else
    vld <= vld;
end
```

`rtu_idu_flush_fe` 和 `rtu_idu_flush_is` 都会导致所有 entry 清零。

### 13.2 计数器 Flush

```verilog
// ct_idu_is_biq.v 第 491～492 行
else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush)
    biq_entry_cnt[3:0] <= 4'b0;
```

计数器额外响应 `rtu_yy_xx_flush`，这比 entry 的 vld 清除多了一路信号。注释说明原因：flush_fe/is 之后，RF 级可能在 rtu_yy_xx_flush 到来之前已经弹出一条指令（减了一次计数），但 flush 后那些 entry 已经被清零，计数器若不对齐会导致后续状态不一致，所以计数器在 `rtu_yy_xx_flush` 时也归零。

### 13.3 两类 Flush 信号的区别

| 信号 | 触发来源 | 范围 |
|------|---------|------|
| `rtu_idu_flush_fe` | RTU 通知前端冲刷（分支误预测、异常） | 清除 IS 级所有 IQ entry 和 FE 级 |
| `rtu_idu_flush_is` | RTU 通知 IS 级冲刷（比 flush_fe 更局部） | 仅清除 IS 级（已在 IS 但未发射的）entry |

两者在 BIQ 中的处理相同（都清 vld），但 flush 来源不同，覆盖范围不同。分支误预测通常触发 `flush_fe`（全面清刷）。

---

## 14. 门控时钟策略

BIQ 使用精细的门控时钟策略减少动态功耗。

### 14.1 计数器门控时钟

```verilog
// ct_idu_is_biq.v 第 451～453 行
assign cnt_clk_en = (biq_entry_cnt[3:0] != 4'b0)
                    || ctrl_biq_create0_gateclk_en
                    || ctrl_biq_create1_gateclk_en;
```

仅在计数器非零（有指令在队列中）或新指令入队时才开启计数器时钟。

### 14.2 Entry 门控时钟（两级）

每个 entry 有两个门控时钟：

```verilog
// ct_idu_is_biq_entry.v 第 237～266 行
// entry_clk：给 vld/frz/agevec 使用（entry 有效或入队时开启）
assign entry_clk_en = x_create_gateclk_en || vld;

// create_clk：给指令数据寄存器使用（仅入队时开启）
assign create_clk_en = x_create_gateclk_en;
```

- `entry_clk`：驱动 `vld`、`frz`、`agevec`——这些需要在 entry 有效期间可能更新（flush、pop、age 更新）
- `create_clk`：驱动 `opcode`、`iid`、`src0_vld` 等静态指令信息——只在入队时写一次，之后只读，所以只在 `x_create_gateclk_en` 时开启

这样 12 个 entry 中未被使用的 entry 其内部时钟完全关闭，大幅节省功耗。

---

## 15. 与 IFU/BHT 的关系

### 15.1 BIQ 携带的分支预测元数据

BIQ 中 `opcode` 字段的 `[14:12]` 是 RISC-V funct3 字段，BJU 用它区分分支类型。`pcall`（bit[68]）和 `rts`（bit[67]）是 IFU 在 dispatch 时根据指令类型附加的标记：

- `pcall=1`：这是一个 CALL 型跳转，IFU 的 RAS（返回地址栈）已经在取指时 push 了返回地址
- `rts=1`：这是一个 RET 型跳转，IFU 的 RAS 已经在取指时 pop 了预测返回地址

BJU 执行完后，会将实际跳转目标与 IFU 的预测目标比对。如果不符，通过 RTU 触发 flush 并通知 IFU 更新预测器。

### 15.2 反馈更新 BHT/BTB

BIQ 本身不直接与 IFU 通信，BJU 的执行结果通过 IU→RTU→IFU 路径反馈：

```
BIQ → pipe2(BJU) → [分支结果: taken/not-taken + 实际目标]
                  → RTU (iu_rtu_ex1_pipe2_bju_res_vld 等)
                  → IFU BHT 更新 (rtu_ifu_bid_xxx)
```

IFU 的 BHT/BTB 训练是异步的，训练结果改善后续取指预测精度。

### 15.3 分支密集场景下的 BIQ 压力

正常代码中分支指令约占 15~25%。BIQ 深度 12 项，在 dispatch 宽度为 2 的情况下最多支持 6 拍的满负荷分支填充。若 BJU 因某种原因延迟（如等待条件寄存器就绪），BIQ 可能填满并阻塞 dispatch，此时 `biq_ctrl_full=1`，IDU ctrl 模块停止向 BIQ 派送新的分支指令。

---

## 16. 与普通 ALU 队列的差异对比

| 特性 | BIQ（分支） | AIQ（普通 ALU） |
|------|------------|----------------|
| 目标单元 | pipe2（BJU） | pipe0/pipe1（ALU） |
| 发射宽度 | 1 条/周期 | 最多 2 条/周期（双发射） |
| 源操作数 | **src0 + src1 均需就绪** | 视指令而定（单目 ALU 只需 src0） |
| 执行结果 | 分支方向/目标，可触发 flush | 算术结果，写回 PRF |
| 分支元数据 | 携带 `pcall/rts/opcode` 供 BJU 校验 | 无特殊元数据 |
| flush 触发 | 本模块指令执行后**可能**触发 flush | 不触发 flush |
| 深度 | 12 项 | （见 ct_idu_is_aiq，一般更深） |
| Bypass | 支持（队列空+源就绪） | 支持 |
| Freeze/replay | 支持 | 支持 |

最核心的差异：**BIQ 中的指令执行后可能导致整个 BIQ（及其他所有 IQ）被清空**——分支误预测触发的 flush 会清除所有后续指令。这意味着 BIQ 的每条指令都是潜在的"破坏者"，BJU 执行的延迟直接影响误预测发现的时机（发现越早，被错误取进来的指令越少）。这也是 BIQ 独立于 AIQ 存在的根本原因：分支指令的调度策略和时序要求与普通 ALU 指令不同。

---

## 17. 完整数据流时序图

```
拍  |  IFU       |  Dispatch(IDU)   |  BIQ           |  RF-latch  |  pipe2(BJU)
----+------------+------------------+----------------+------------+-------------
 T  | 预测取指   |                  |                |            |
    | 分支预测   |                  |                |            |
T+1 |            | create0/1_en=1   |                |            |
    |            | create0_data=xxx |  entry_N.vld=1 |            |
    |            |                  |  frz=0         |            |
    |            |                  |  agevec 初始化 |            |
    |            |                  |  dep_reg 入队  |            |
T+2 |            |                  |  唤醒监听广播  |            |
... |            |                  |  src_rdy 更新  |            |
T+K |            |                  |  src0&src1 rdy |            |
    |            |                  |  issue_en=1    |            |
    |            |                  |  frz置1        |            |
T+K+1|           |                  |  (冻结等待确认)|  lch_en=1  |
    |            |                  |                |            |  EX1: 分支计算
T+K+2|           |                  |  pop_vld=1     |  (成功)    |  EX2: 写回+预测比对
    |            |                  |  vld=0         |            |
    |            |                  | [若失败: frz=0,|            |
    |            |                  |  replay]        |            |
```

### 特殊路径：Bypass

```
拍  |  IFU        |  Dispatch(IDU)          |  BIQ                |  RF-latch
----+-------------+-------------------------+---------------------+-----------
 T  | 分支指令来  | create0_en=1            |                     |
    |             | src0_rdy_bypass=1       |  biq_create_bypass  |
    |             | src1_rdy_bypass=1       |  _empty=1 (队列空)  |
    |             |                         |  bypass_en=1        |
    |             |                         |  entry_N.vld=1,frz=1|
    |             |                         |  issue_en=1 (同拍)  |
 T+1|             |                         |  (等待 RF 确认)     | lch_en=1
 T+2|             |                         |  pop_vld → vld=0    |
```

Bypass 情况下，指令入队（`vld=1`，`frz=1`）和发射（`issue_en=1`）在同一拍完成，比普通路径省去至少一拍等待。

---

## 附：信号索引快查表

| 关键信号 | 所在文件/行号 | 含义 |
|----------|-------------|------|
| `biq_entry_cnt[3:0]` | biq.v L481 | 当前 entry 占用计数 |
| `biq_ctrl_full` | biq.v L499 | 队列满（cnt==12） |
| `biq_ctrl_full_updt` | biq.v L511 | 下一拍将满（提前通知） |
| `biq_entry_create0_in` | biq.v L606 | create0 目标 entry（低到高扫描） |
| `biq_entry_create1_in` | biq.v L649 | create1 目标 entry（高到低扫描） |
| `biq_entry_create0/1_agevec` | biq.v L744 | 入队时的年龄向量 |
| `biq_create0_rdy_bypass` | biq.v L549 | bypass 发射条件 |
| `biq_older_entry_ready` | biq.v L1152 | 年龄仲裁结果（有更老的就绪项） |
| `biq_entry_issue_en` | biq.v L1189 | 最终发射使能（one-hot） |
| `biq_dp_issue_read_data` | biq.v L1261 | 发往 RF 的指令数据（bypass 或 entry 读出） |
| `biq_entry_frz_clr` | biq.v L1308 | replay 清冻信号 |
| `x_vld` | entry.v L289 | entry 有效位 |
| `x_vld_with_frz` | entry.v L307 | 有效且未冻结（参与 bypass_empty 和 gateclk 判断） |
| `x_rdy` | entry.v L532 | 发射就绪（vld & !frz & src0_rdy & src1_rdy） |
| `frz` | entry.v L308 | 冻结位（已发射等待确认） |
| `agevec[10:0]` | entry.v L325 | 年龄向量（谁比我年轻） |
| `src0/1_rdy_for_issue` | entry.v L462/525 | 源操作数就绪（来自 dep_reg_entry） |
| `src0/1_rdy_clr` | entry.v L400 | replay 时清除就绪位 |
