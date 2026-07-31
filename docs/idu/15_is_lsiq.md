# C910 IDU 访存发射队列（LSIQ）详解

> RTL 源文件：
> - `ct_idu_is_lsiq.v`（4114 行，顶层）
> - `ct_idu_is_lsiq_entry.v`（1325 行，单项逻辑）

---

## 目录

1. [模块概述](#1-模块概述)
2. [队列结构与参数](#2-队列结构与参数)
3. [端口说明](#3-端口说明)
4. [Entry 分配（Create）](#4-entry-分配create)
5. [唤醒机制——源寄存器就绪追踪](#5-唤醒机制源寄存器就绪追踪)
6. [发射就绪与选择](#6-发射就绪与选择)
7. [LSU 反馈处理](#7-lsu-反馈处理)
8. [Freeze（冻结）机制](#8-freeze冻结机制)
9. [load / store 差异处理](#9-load--store-差异处理)
10. [向量访存的特殊处理（srcvm）](#10-向量访存的特殊处理srcvm)
11. [发射到 pipe3 / pipe4](#11-发射到-pipe3--pipe4)
12. [Flush 处理](#12-flush-处理)
13. [时钟门控](#13-时钟门控)
14. [关键信号速查表](#14-关键信号速查表)

---

## 1. 模块概述

### 1.1 访存指令的特殊性

LSIQ（Load/Store Issue Queue，访存发射队列）是 IDU 中专门服务于 LSU（Load/Store Unit）的发射队列。相比 ALU 发射队列（AIQ），访存指令有如下额外复杂性：

| 维度 | ALU | Load/Store |
|------|-----|------------|
| 执行流水线 | pipe0/pipe1（2 拍完成） | pipe3（load）/ pipe4（store 地址）|
| 地址计算 | 无 | AG 级（地址生成，base + offset） |
| Cache 访问 | 无 | DC 级（D-Cache 访问，可能 miss） |
| 延迟 | 短整数路径通常较固定，但应先定义起止级 | 访存延迟受地址生成、TLB、Cache、转发、miss/replay 影响，不是单一固定拍数 |
| 顺序约束 | 就绪后可乱序选择 | 允许受控乱序，依靠年龄、barrier、no-spec、LSU 队列和违例恢复共同满足内存模型 |
| 向量掩码 | 无 | 向量访存需要额外 srcvm 寄存器 |
| 后端反馈 | 无 | LSU 多流水级均会向 IDU 反馈 |

因此 LSIQ 相比 AIQ 拥有更多的**反压（back-pressure）状态位**、**推测唤醒与 replay 机制**，以及**向量掩码寄存器依赖追踪**。

> **当前配置边界**：LSIQ 数据结构和 `dep_vreg_entry` 保留了向量访存所需的 VL/VSEW/VLMUL、VREG、srcvm 和多级向量唤醒接口，但当前 `x_vec_inst=0`、`misa_vector=0`。下文向量段落解释的是保留 RTL 机制；当前有效程序主要走标量 load/store、浮点 store 借用通道及其相应依赖路径。

### 1.2 上下游关系

```
        IDU
   ┌────────────────────────────────────────┐
   │  dispatch         LSIQ                 │
   │  ─────────> [entry0 .. entry11]        │
   │                   │  pipe3 (load)      │──────> LSU pipe3 (AG→DC→WB)
   │                   │  pipe4 (store addr)│──────> LSU pipe4
   │  <─────────────── │  LSU 反馈信号       │
   └────────────────────────────────────────┘

LSU 流水线（pipe3）：
  AG (地址生成) → DC (D-Cache 访问) → WB (写回)
  └─ ag_load_inst_vld (推测唤醒)
      └─ dc_load_inst_vld / dc_load_fwd_inst_vld (确认或转发)
          └─ wb_pipe3_wb_preg_vld (最终写回)
```

- **load** 指令发射到 **pipe3**；LSU AG 级向 IDU 提供 load 目的 preg，依赖项据此记录 `lsu_match`
  预匹配。真正参与 `rdy` 或 `rdy_for_issue` 的还包括 DC load-valid、DC forward 和已保存的匹配状态，
  不能把 AG 有效本身等同于依赖已经 ready。
- **store 地址计算** 发射到 **pipe4**；store 还需要从 SDIQ（Store Data Issue Queue）获取数据。
- **barrier（fence/memory order）** 也经由 pipe4 发射。

---

## 2. 队列结构与参数

### 2.1 物理深度

LSIQ 有 **12 个物理 entry**（entry0 ~ entry11），而非题目背景所说的 8 项。这是实际 RTL 的真实深度。

```verilog
// ct_idu_is_lsiq.v L:1386
assign lsiq_ctrl_full = (lsiq_entry_cnt[3:0] == 4'd12);
```

计数器 `lsiq_entry_cnt` 为 4 位，满队列时值为 12。

### 2.2 Entry 数据宽度（163 位）

每个 entry 存储 163 位指令信息，由参数定义各字段偏移：

```verilog
// ct_idu_is_lsiq_entry.v L:435–481（参数定义）
parameter LSIQ_WIDTH   = 163;

parameter LSIQ_VL           = 162;  // 向量长度（8位，[162:155]）
parameter LSIQ_VMB          = 154;  // 向量掩码 bit
parameter LSIQ_SPLIT_NUM    = 153;  // 拆分编号（7位）
parameter LSIQ_VSEW         = 146;  // 向量元素宽度（3位）
parameter LSIQ_VLMUL        = 143;  // 向量 LMUL（2位）
parameter LSIQ_BKPTB_DATA   = 141;  // 断点 B 数据标记
parameter LSIQ_BKPTA_DATA   = 140;  // 断点 A 数据标记
parameter LSIQ_AGEVEC_ALL   = 139;  // 全类型年龄向量（11位，[139:129]）
parameter LSIQ_ALREADY_DA   = 128;  // 已做过地址转换标记
parameter LSIQ_UNALIGN_2ND  = 127;  // 非对齐访存第二次
parameter LSIQ_SPEC_FAIL    = 126;  // 推测失败标记
parameter LSIQ_NO_SPEC_EXIST= 125;  // 存在不可推测 store 标记
parameter LSIQ_NO_SPEC      = 124;  // 本指令不可推测
parameter LSIQ_SPLIT        = 123;  // 向量拆分标记
parameter LSIQ_SDIQ_ENTRY   = 122;  // 对应的 SDIQ entry（12位，[122:111]）
parameter LSIQ_STADDR       = 110;  // store 地址操作标记
parameter LSIQ_PC           = 109;  // PC 低 15 位（[109:95]）
parameter LSIQ_BAR_TYPE     = 94;   // barrier 类型（4位，[94:91]）
parameter LSIQ_BAR          = 90;   // 是否为 barrier
parameter LSIQ_STORE        = 89;   // 是否为 store
parameter LSIQ_LOAD         = 88;   // 是否为 load
parameter LSIQ_SRCVM_RDY    = 78;   // srcvm 就绪位
parameter LSIQ_SRC1_RDY     = 68;   // src1 就绪位
parameter LSIQ_SRC0_RDY     = 58;   // src0 就绪位
parameter LSIQ_DST_VREG     = 57;   // 目的向量寄存器（7位，[57:51]）
parameter LSIQ_DST_PREG     = 50;   // 目的物理寄存器（7位，[50:44]）
parameter LSIQ_IID          = 38;   // 指令 ID（7位，[38:32]）
parameter LSIQ_OPCODE       = 31;   // 操作码（32位，[31:0]）
```

字段布局示意图：

```
bit  162                128  127  126  125 ... 122        110  109      94  90  89  88
     |<--- 向量信息 --->|ALR|UNL|SFL|NSP|...|<- SDIQ ->|STAD|<- PC ->|BAR|BAR|STO|LOA|...
     |<----------- 高位扩展信息 ----------->|            |<- 地址/指令信息 -------------->|

bit  87  86      79  78  77  76      69  68  67  66      59  58  57      51  50      44  43  42  41  40  39  38      32  31              0
     |VM-M|<VM-VR>|VMrdy|S1-M|<S1-PR>|S1rdy|S0-M|<S0-PR>|S0rdy|<DSTV>|<DSTP>|DstV|DstP|VmV|S1V|S0V|<IID>|<---- OPCODE ---->|
```

其中 `SRC0/SRC1/SRCVM` 的 `_RDY` 位在写入时清零（实际就绪由 dep_entry 子模块动态维护，读出时恒为 0），真正的就绪状态通过 `dep_reg_entry`/`dep_vreg_entry` 内部状态机输出。

### 2.3 BAR_TYPE 字段含义

`LSIQ_BAR_TYPE`（4 位）编码了 barrier 指令对前后 load/store 的约束类型：

| 位 | 含义 |
|----|------|
| [0] | bef_load：barrier 之前不能有 load |
| [1] | bef_store：barrier 之前不能有 store |
| [2] | aft_load：barrier 之后不能有 load（此 barrier 阻止后续 load） |
| [3] | aft_store：barrier 之后不能有 store（此 barrier 阻止后续 store）|

---

## 3. 端口说明

### 3.1 来自 ctrl（IDU 控制模块）

| 信号 | 宽度 | 方向 | 含义 |
|------|------|------|------|
| `ctrl_lsiq_create0_en` | 1 | in | 分配 slot 0（控制使能，修改 vld） |
| `ctrl_lsiq_create0_dp_en` | 1 | in | 分配 slot 0（数据路径使能，写入 entry 数据） |
| `ctrl_lsiq_create0_gateclk_en` | 1 | in | 分配 slot 0 门控时钟使能 |
| `ctrl_lsiq_create1_*` | 1 | in | 同上，第二路分配 |
| `ctrl_lsiq_ir_bar_inst_vld` | 1 | in | IR 级（重命名级）存在 barrier 指令 |
| `ctrl_lsiq_is_bar_inst_vld` | 1 | in | IS 级（发射级）存在 barrier 指令 |
| `ctrl_lsiq_rf_pipe3_lch_fail_vld` | 1 | in | pipe3 发射（launch）失败信号 |
| `ctrl_lsiq_rf_pipe4_lch_fail_vld` | 1 | in | pipe4 发射失败信号 |
| `ctrl_lsiq_rf_pipe0_alu_reg_fwd_vld` | 24 | in | pipe0 ALU 对各 entry src0/src1 的前向 |
| `ctrl_lsiq_rf_pipe1_alu_reg_fwd_vld` | 24 | in | pipe1 ALU 对各 entry 的前向 |

### 3.2 来自 dp（IDU 数据路径模块）

| 信号 | 宽度 | 方向 | 含义 |
|------|------|------|------|
| `dp_lsiq_create0_data` | 163 | in | slot 0 分配数据（完整 163 位） |
| `dp_lsiq_create1_data` | 163 | in | slot 1 分配数据 |
| `dp_lsiq_bypass_data` | 163 | in | bypass 路径数据（指令跳过队列直接发射） |
| `dp_lsiq_create0_src0_rdy_for_bypass` | 1 | in | slot 0 src0 在分配时已就绪（bypass 判断） |
| `dp_lsiq_create0_src1_rdy_for_bypass` | 1 | in | 同上，src1 |
| `dp_lsiq_create0_srcvm_rdy_for_bypass` | 1 | in | 同上，srcvm |
| `dp_lsiq_create0_load/store/bar` | 1 | in | slot 0 指令类型标记 |
| `dp_lsiq_create0_no_spec` | 1 | in | slot 0 是不可推测 load |
| `dp_lsiq_rf_pipe3_lch_entry` | 12 | in | pipe3 发射时命中的 entry one-hot |
| `dp_lsiq_rf_pipe3_rdy_clr` | 3 | in | pipe3 发射失败时需清除的就绪位（src0/src1/srcvm） |
| `dp_lsiq_rf_pipe4_lch_entry` | 12 | in | pipe4 发射时命中的 entry one-hot |
| `dp_lsiq_rf_pipe4_rdy_clr` | 3 | in | pipe4 发射失败时需清除的就绪位 |

### 3.3 来自 LSU 的反馈信号（核心）

这是 LSIQ 区别于 AIQ 的核心所在。LSU 的多个流水级都会向 IDU 反馈：

#### AG 级（地址生成级）推测唤醒

| 信号 | 宽度 | 含义 |
|------|------|------|
| `lsu_idu_ag_pipe3_load_inst_vld` | 1 | AG 级有标量 load 在执行（推测唤醒触发） |
| `lsu_idu_ag_pipe3_preg_dupx` | 7 | 该 load 的目的物理寄存器编号 |
| `lsu_idu_ag_pipe3_vload_inst_vld` | 1 | AG 级有向量 load 在执行 |
| `lsu_idu_ag_pipe3_vreg_dupx` | 7 | 向量 load 的目的向量寄存器 |

**精确含义**：AG 级的目的寄存器比较生成 `lsu_match`，为后续 DC forward 快速判断预存匹配关系；
`dep_reg_entry` 中 AG 条件本身不进入 `rdy_update`。DC 的
`load_inst_vld && preg_match` 可更新 `rdy`，而
`load_fwd_inst_vld && lsu_match` 直接参与 `rdy_for_issue`。若后续 RF launch 失败，队列通过
`rdy_clr/frz_clr` 清除相应就绪并重调度。是否由 cache miss 触发某个具体 replay 条件，应结合 LSU
对应控制信号判断，不能只从 AG 接口推断。

#### DC 级（D-Cache 访问级）确认/取消

| 信号 | 宽度 | 含义 |
|------|------|------|
| `lsu_idu_dc_pipe3_load_inst_vld_dupx` | 1 | DC 级有标量 load（确认继续） |
| `lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx` | 1 | DC 级 load 发生了 store-to-load forwarding |
| `lsu_idu_dc_pipe3_preg_dupx` | 7 | 该 load 的目的物理寄存器 |
| `lsu_idu_dc_pipe3_vload_inst_vld_dupx` | 1 | DC 级有向量 load |
| `lsu_idu_dc_pipe3_vload_fwd_inst_vld` | 1 | DC 级向量 load 发生 forwarding |
| `lsu_idu_dc_pipe3_vreg_dupx` | 7 | 向量 load 目的寄存器 |

#### WB 级（写回级）

| 信号 | 宽度 | 含义 |
|------|------|------|
| `lsu_idu_wb_pipe3_wb_preg_vld_dupx` | 1 | WB 级有标量寄存器写回 |
| `lsu_idu_wb_pipe3_wb_preg_dupx` | 7 | 写回的目的物理寄存器 |
| `lsu_idu_wb_pipe3_wb_vreg_vld_dupx` | 1 | WB 级有向量寄存器写回 |
| `lsu_idu_wb_pipe3_wb_vreg_dupx` | 7 | 写回的目的向量寄存器 |

#### LSU 队列状态与 replay 信号

| 信号 | 宽度 | 含义 |
|------|------|------|
| `lsu_idu_lq_full[11:0]` | 12 | 每个 entry 对应的 Load Queue 满标记 |
| `lsu_idu_lq_not_full` | 1 | Load Queue 全局不满（用于唤醒） |
| `lsu_idu_sq_full[11:0]` | 12 | 每个 entry 对应的 Store Queue 满标记 |
| `lsu_idu_sq_not_full` | 1 | Store Queue 全局不满 |
| `lsu_idu_rb_full[11:0]` | 12 | ReOrder Buffer（rb，此处指 miss buffer）满标记 |
| `lsu_idu_rb_not_full` | 1 | rb 不满 |
| `lsu_idu_tlb_busy[11:0]` | 12 | TLB 繁忙（某 entry 发射后 TLB miss） |
| `lsu_idu_tlb_wakeup[11:0]` | 12 | TLB 就绪，唤醒对应 entry |
| `lsu_idu_wait_old[11:0]` | 12 | 需要等待更老指令先完成 |
| `lsu_idu_wait_fence[11:0]` | 12 | 需要等待 fence 清空 |
| `lsu_idu_no_fence` | 1 | fence 已清空（全局唤醒 wait_fence） |
| `lsu_idu_wakeup[11:0]` | 12 | 通用唤醒（清 frz，允许 replay） |
| `lsu_idu_spec_fail[11:0]` | 12 | 推测失败（某 entry 的推测 load 失败） |
| `lsu_idu_secd[11:0]` | 12 | 非对齐第二次访问标记（second） |
| `lsu_idu_already_da[11:0]` | 12 | 已完成地址转换 |
| `lsu_idu_lsiq_pop_vld` | 1 | 有 entry 被弹出（entry 生命周期结束） |
| `lsu_idu_lsiq_pop0_vld / pop1_vld` | 1 | 弹出通道 0/1 有效 |
| `lsu_idu_lsiq_pop_entry[11:0]` | 12 | 被弹出的 entry one-hot 编码 |

### 3.4 LSIQ 输出信号

| 信号 | 宽度 | 含义 |
|------|------|------|
| `lsiq_xx_pipe3_issue_en` | 1 | pipe3（load）可以发射 |
| `lsiq_xx_pipe4_issue_en` | 1 | pipe4（store/bar）可以发射 |
| `lsiq_xx_gateclk_issue_en` | 1 | 门控时钟：有 entry 待发射 |
| `lsiq_dp_pipe3_issue_entry[11:0]` | 12 | pipe3 发射的 entry one-hot |
| `lsiq_dp_pipe3_issue_read_data[162:0]` | 163 | pipe3 发射读出的指令数据 |
| `lsiq_dp_pipe4_issue_entry[11:0]` | 12 | pipe4 发射的 entry one-hot |
| `lsiq_dp_pipe4_issue_read_data[162:0]` | 163 | pipe4 发射读出的指令数据 |
| `lsiq_ctrl_full` | 1 | 队列满（12 项） |
| `lsiq_ctrl_1_left_updt` | 1 | 队列还剩 1 个空位 |
| `lsiq_ctrl_full_updt` | 1 | 下一拍将满 |
| `lsiq_ctrl_empty` | 1 | 队列空 |
| `lsiq_dp_no_spec_store_vld` | 1 | 队列中存在未冻结的 no_spec store |
| `lsiq_dp_create_bypass_oldest` | 1 | bypass 指令是最老的（用于 no_spec 判断） |
| `lsiq_top_frz_entry_vld` | 1 | 无冻结 entry（所有 frz 项已清） |
| `lsiq_top_lsiq_entry_cnt[3:0]` | 4 | 当前队列项数 |
| `lsiq_aiq_create0/1_entry[11:0]` | 12 | 分配给 slot0/1 的 entry one-hot（也发给 AIQ 用于 age 同步） |

---

## 4. Entry 分配（Create）

### 4.1 双路分配与 entry 选择

IDU 每周期最多可以向 LSIQ 写入 **2 条指令**（create0 和 create1）。两路分配采用不同方向的优先级选择空闲 entry：

```verilog
// ct_idu_is_lsiq.v L:1486–1573
// create0 从 entry0 向 entry11 扫描第一个空位（低优先）
always @(...) begin
  if(!lsiq_entry0_vld)      lsiq_entry_create0_in = 12'b0000_0000_0001;
  else if(!lsiq_entry1_vld) lsiq_entry_create0_in = 12'b0000_0000_0010;
  ...
end

// create1 从 entry11 向 entry0 扫描第一个空位（高优先）
always @(...) begin
  if(!lsiq_entry11_vld)     lsiq_entry_create1_in = 12'b1000_0000_0000;
  else if(!lsiq_entry10_vld)lsiq_entry_create1_in = 12'b0100_0000_0000;
  ...
end
```

**为什么两路方向相反？** 两个优先编码器从相反方向寻找空项，使存在至少两个可用 entry 时 create0/create1 选择不同位置。只剩一个空项时仍需上游 `1_left/full_updt` 控制禁止双创建，不能仅靠扫描方向无条件保证。

分配的最终 entry 通过 `lsiq_entry_create_sel[11:0]` 判断：低半部分（entry 0~5）用 `~create0_in` 标记，高半部分（entry 6~11）用 `create1_in` 标记，二者互斥。

### 4.2 Entry 计数器管理

```verilog
// ct_idu_is_lsiq.v L:1358–1384
assign lsiq_entry_cnt_create = {3'b0, ctrl_lsiq_create0_en}
                              + {3'b0, ctrl_lsiq_create1_en};
assign lsiq_entry_cnt_pop    = {pop0_vld & pop1_vld, pop0_vld ^ pop1_vld};

always @(posedge cnt_clk or negedge cpurst_b) begin
  if(!cpurst_b) lsiq_entry_cnt <= 4'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush)
    lsiq_entry_cnt <= 4'b0;   // flush 清零，注意需要加 rtu_yy_xx_flush
  else if(lsiq_entry_cnt_updt_vld)
    lsiq_entry_cnt <= lsiq_entry_cnt + create - pop;
end
```

注意代码注释：`after flush fe/is, the lsu may wrongly pop before rtu_yy_xx_flush`，所以 flush 时需要连 `rtu_yy_xx_flush` 也清零，防止 LSU 错误的 pop 干扰计数。

### 4.3 年龄向量（agevec）

每个 entry 存储两套年龄向量：

1. **`agevec[10:0]`**（同类型年龄）：仅记录同类型（load 一组，store/bar 一组）中比自己老的 entry 集合，用于在多个同类型**已就绪**候选间选择最老者。
2. **`agevec_all[10:0]`**（全类型年龄）：记录所有类型中比自己老的 entry，用于 barrier、no_spec、wait_old 等全局顺序判断。

注意每个 entry 的 agevec 是 11 位（而非 12 位），这是因为每个 entry 不记录自己，通过循环移位的方式排除自身：

```verilog
// ct_idu_is_lsiq.v L:1643–1679（create0 agevec 计算举例）
// create0 进入 entry0，其 agevec 是已有 entry 中同类型的 vld 集合（去掉 entry0 自身位置）
assign lsiq_entry_create0_agevec[11:0] =
    lsiq_entry_vld[11:0]
    & ({12{dp_lsiq_create0_load}} & lsiq_entry_load[11:0]
     | {12{dp_lsiq_create0_store || dp_lsiq_create0_bar}}
        & (lsiq_entry_store[11:0] | lsiq_entry_bar[11:0]))
    & ~lsu_idu_lsiq_pop_entry[11:0]; // 同周期弹出的不计入
```

**为什么这么做？** 通过 agevec 的位与归约，每个 entry 可以判断是否存在同类型、比自己更老且也 `raw_rdy` 的候选；有则压制自己。这保证的是“同类型 ready 集合中的最老者优先”，并不阻止年轻的 ready load/store 越过一个尚未 ready 的同类型老项。

### 4.4 分配时的冻结（create frz）

```verilog
// ct_idu_is_lsiq.v L:1686–1690
assign lsiq_entry_create0_frz = lsiq_bar_mode
                               || lsiq_bypass_dp_en        // bypass 路径也设 frz
                               || dp_lsiq_create0_no_spec && dp_lsiq_create0_load;
assign lsiq_entry_create1_frz = lsiq_bar_mode
                               || dp_lsiq_create1_no_spec && dp_lsiq_create1_load;
```

新 entry 在以下情况入队时置 `frz=1`（冻结，不能发射）：

- **barrier 模式**：队列中有 barrier 指令时，所有新指令都需冻结等待排序检查。
- **bypass 路径**：指令同时走 bypass（不入队直接发射），其对应分配的 entry 也设 frz，待 bypass 发射后 frz 才清，后续指令才解冻。
- **no_spec load**：不可推测 load（如需要等待所有 older store 完成的 load）入队时冻结，待确认安全后解冻。

---

## 5. 唤醒机制——源寄存器就绪追踪

### 5.1 三路源寄存器

LSIQ entry 内有三个依赖追踪子模块：

```verilog
// ct_idu_is_lsiq_entry.v L:1109–1301
ct_idu_dep_reg_entry  x_ct_idu_is_lsiq_src0_entry (...);  // src0：基址寄存器
ct_idu_dep_reg_entry  x_ct_idu_is_lsiq_src1_entry (...);  // src1：偏移寄存器
ct_idu_dep_vreg_entry x_ct_idu_is_lsiq_srcvm_entry(...);  // srcvm：向量掩码寄存器
```

| 源 | 类型 | 用途 |
|----|------|------|
| src0 | 整数物理寄存器 | 访存基址（base address） |
| src1 | 整数物理寄存器 | 访存偏移（offset，标量访存） |
| srcvm | 向量物理寄存器 | 向量访存掩码（vector mask register） |

### 5.2 src0/src1 唤醒来源（dep_reg_entry）

`dep_reg_entry` 子模块监听以下写回总线来更新就绪位：

| 来源 | 信号 | 说明 |
|------|------|------|
| ALU pipe0 | `iu_idu_ex2_pipe0_wb_preg_vld_dupx` + `preg` | 整数 ALU 流水线写回 |
| ALU pipe1 | `iu_idu_ex2_pipe1_wb_preg_vld_dupx` + `preg` | 整数 ALU 流水线写回 |
| 除法器 | `iu_idu_div_inst_vld` + `div_preg` | 除法结果（特殊处理，延迟不固定）|
| VFPU pipe6 mfvr | `vfpu_idu_ex1_pipe6_mfvr_inst_vld_dupx` + `preg` | 向量到整数传输 |
| VFPU pipe7 mfvr | `vfpu_idu_ex1_pipe7_mfvr_inst_vld_dupx` + `preg` | 同上 |
| **LSU AG 级** | `lsu_idu_ag_pipe3_load_inst_vld` + `ag_preg` | **推测唤醒**（load 可能 miss）|
| **LSU DC 级** | `lsu_idu_dc_pipe3_load_inst_vld_dupx` + `dc_preg` | **推测唤醒二次确认** |
| **LSU DC 转发** | `lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx` + `dc_preg` | store-to-load 转发时确认 |
| **LSU WB 级** | `lsu_idu_wb_pipe3_wb_preg_vld_dupx` + `wb_preg` | 最终写回（无推测） |
| pipe0 RF latch | `ctrl_xx_rf_pipe0_preg_lch_vld_dupx` + `dp_xx_rf_pipe0_dst_preg` | RF latch 级前向 |
| pipe1 RF latch | `ctrl_xx_rf_pipe1_preg_lch_vld_dupx` + `dp_xx_rf_pipe1_dst_preg` | RF latch 级前向 |

**关键推测唤醒机制（Load-to-use wakeup）**：

```
周期 T:   load A 发射到 pipe3
          ↓
周期 T+1: AG 级：地址生成完成
          lsu_idu_ag_pipe3_load_inst_vld = 1，preg = A的目标preg
          → dep_reg_entry 将依赖 A 的 src0/src1 标记为就绪（推测）
          ↓
周期 T+2: DC 级：Cache 查询
          若 hit: dc_load_inst_vld = 1，preg = A
                  → 二次确认，推测正确，依赖指令可继续
          若 miss: 不置 dc_load_inst_vld
                   → 需要 replay，依赖指令的就绪位需清除（rdy_clr）
          若 forwarding: dc_load_fwd_inst_vld = 1
                   → 从 store 转发成功，也算就绪
```

### 5.3 srcvm 唤醒来源（dep_vreg_entry）

保留的向量掩码寄存器路径没有连接 VFPU EX1/EX2/EX3 中间级唤醒，相关输入在该实例处接 0；RTL 注释将其标为 timing optimization：

```verilog
// ct_idu_is_lsiq_entry.v L:1253–1258（关键差异：VFPU EX1/EX2/EX3 中间级唤醒接 0）
.vfpu_idu_ex1_pipe6_data_vld_dupx (1'b0),
.vfpu_idu_ex2_pipe6_data_vld_dupx (1'b0),
.vfpu_idu_ex3_pipe6_data_vld_dupx (1'b0),
// ... 同样 pipe7 也全接 0
```

srcvm 仍可由 LSU 向量 load 的 AG/DC/WB 事件以及 VFPU EX5 写回接口唤醒；它不接受 VFPU EX1/2/3 中间级事件。RTL 能证明连接取舍，但“因为链路简单”或“中间级一定太紧”属于设计动机推断，需结合时序报告验证。当前 RVV 关闭时，这些向量事件通常不构成有效工作负载活动。

### 5.4 发射失败时的就绪位清除

```verilog
// ct_idu_is_lsiq.v L:2557–2592
assign lsiq_entry0_rdy_clr[2:0] =
    {3{lsiq_entry_pipe3_frz_clr[0]}} & dp_lsiq_rf_pipe3_rdy_clr[2:0]
  | {3{lsiq_entry_pipe4_frz_clr[0]}} & dp_lsiq_rf_pipe4_rdy_clr[2:0];
```

当 pipe3/pipe4 的 RF launch 失败且相应 entry 被 `frz_clr` 命中时，`rdy_clr[2:0]` 逐位指定哪些源依赖状态需要撤销（bit0=src0、bit1=src1、bit2=srcvm）。清除发生在依赖跟踪模块的有效时钟沿；不是 `lch_fail_vld` 一出现所有 ready 位就组合清零。

---

## 6. 发射就绪与选择

### 6.1 RAW 就绪（raw_rdy）

每个 entry 的原始就绪条件：

```verilog
// ct_idu_is_lsiq_entry.v L:1309–1312
assign x_raw_rdy = vld && !frz
                && src0_rdy_for_issue
                && src1_rdy_for_issue
                && srcvm_rdy_for_issue;
```

- `vld`：entry 有效
- `!frz`：未冻结
- 三个源寄存器全部就绪

### 6.2 年龄仲裁（older_entry_rdy_mask）

同类型中有更老的 entry 也已 raw_rdy 时，当前 entry 被压制：

```verilog
// ct_idu_is_lsiq_entry.v L:1316–1320
// 同类型（agevec 中记录的那些 entry）中是否有任一也是 raw_rdy
assign older_entry_rdy_mask = |(agevec[10:0] & x_other_raw_rdy[10:0]);

// 最终就绪：raw_rdy 且没有更老的同类型 entry 也就绪
assign x_rdy = x_raw_rdy && !older_entry_rdy_mask;
```

**精确语义**：`older_entry_rdy_mask` 只检查“更老且同类型且当前 `raw_rdy`”的项。因此，多个 ready load 中选最老 load，多个 ready store/bar 中选最老 store/bar；若一个更老同类型项因源未就绪或冻结而不属于 `raw_rdy`，年轻 ready 项仍可先发射。这正是乱序发射能力的一部分。内存相关、地址别名、load-store 顺序、barrier 与违例恢复由 `agevec_all`、no-spec/bar 检查及 LSU 的 LQ/SQ/WMB 等机制继续约束，而不是由这条 agevec 逻辑单独实现严格程序序。

### 6.3 发射选择与类型分流

```verilog
// ct_idu_is_lsiq.v L:2344–2378
// load 发射候选：就绪 AND load 类型
assign lsiq_pipe3_entry_ready[11:0] = lsiq_entry_ready[11:0]
                                     & lsiq_entry_load[11:0];
// store/bar 发射候选：就绪 AND (store OR bar)
assign lsiq_pipe4_entry_ready[11:0] = lsiq_entry_ready[11:0]
                                     & (lsiq_entry_store[11:0]
                                        | lsiq_entry_bar[11:0]);
```

由于同一类型的两个 `raw_rdy` 候选之间必有年龄关系，年轻者会被 `older_entry_rdy_mask` 压制；在 agevec 维护一致的前提下，最终每组至多留下一个 ready 候选。因此 `lsiq_pipe3_entry_ready` 与 `lsiq_pipe4_entry_ready` 各自应为 one-hot-or-zero。load 组和 store/bar 组彼此独立，所以同周期可以各有一个候选。

### 6.4 Bypass 路径

当分配指令（create0）的三个源寄存器**在分配时已就绪**，且队列有效项为空，且不在 barrier 模式下，该指令可以**绕过队列**直接发射：

```verilog
// ct_idu_is_lsiq.v L:1438–1459
assign lsiq_create0_rdy_bypass = ctrl_lsiq_create0_en
    && !cp0_idu_iq_bypass_disable
    && !dp_lsiq_create0_bar                       // barrier 不能 bypass
    && !(dp_lsiq_create0_no_spec && dp_lsiq_create0_load) // no_spec load 不能 bypass
    && dp_lsiq_create0_src0_rdy_for_bypass
    && dp_lsiq_create0_src1_rdy_for_bypass
    && dp_lsiq_create0_srcvm_rdy_for_bypass;

assign lsiq_bypass_en = lsiq_create_bypass_empty  // 队列（含非 frz 项）为空
                       && !lsiq_bar_mode
                       && lsiq_create0_rdy_bypass;
```

注意 `lsiq_create_bypass_empty` 汇总的是 entry 的 `vld_with_frz`，而该值为 `vld && (!frz || bar)`：冻结的普通 load/store 不计入，bar 即使冻结仍计入。因此它并不保证 bypass 不越过所有正在等待的普通冻结项；正确性要依赖 no-spec、barrier、LSU 相关检查和 replay 机制。这里的 bypass 只跳过 LSIQ 驻留/仲裁，不代表访存已完成。

**为什么 bypass 时也设置 frz？**

```verilog
// ct_idu_is_lsiq.v L:1686
assign lsiq_entry_create0_frz = lsiq_bar_mode || lsiq_bypass_dp_en || ...
```

bypass 指令虽然同时从 create 数据通路送往 issue，但仍分配一个 entry。该 entry 创建时置 `frz=1`，避免它在旁路尝试尚未由后续阶段确认时再次参与普通 ready 仲裁；之后由 pop 或失败/唤醒路径处理。这里是“防止重复调度”的生命周期保护，不应概括为旁路完成后必然立即清除。

---

## 7. LSU 反馈处理

### 7.1 推测唤醒与 Replay 流程

LSIQ 与 LSU 之间的典型推测-确认-replay 流程如下：

```
IDU (LSIQ)                              LSU
┌──────────────────────────────────────────────────────────┐
│ T+0: load A 发射出队                                      │
│       → A 的 entry vld 仍保持（等待 pop）                 │
│ T+1: AG 级 ag_load_inst_vld=1, preg=A的目标             │
│       → dep_reg_entry：依赖 A 的后续指令 src 标记就绪     │
│       → 依赖 A 的指令可能在本周期发射（投机发射）         │
│ T+2: DC 级                                                │
│  Case1 Hit: dc_load_inst_vld=1 → 确认，推测正确          │
│  Case2 Miss: dc_load_inst_vld=0 → 推测错误               │
│       lsu_idu_lq_full[entry_A] = 1 → A 的 entry 设 lq_full│
│       依赖 A 的指令需要 replay：lch_fail_vld → rdy_clr   │
│  Case3 Fwd: dc_load_fwd_inst_vld=1 → store-to-load 转发  │
│ T+3: WB 级 wb_preg_vld=1 → 最终写回，寄存器文件更新      │
│       lsu_idu_lsiq_pop_vld=1, pop_entry = A               │
│       → A 的 entry vld 清零，真正出队                     │
└──────────────────────────────────────────────────────────┘
```

### 7.2 各 LSU 反馈位对应的 entry 状态

每个 LSIQ entry 维护以下 LSU 反馈状态寄存器（均为 1 bit）：

| 状态寄存器 | 置 1 条件 | 清 0 条件 | 含义 |
|-----------|----------|----------|------|
| `lq_full` | `lsu_idu_lq_full[i]` | `lsu_idu_lq_not_full \|\| old` | Load Queue 满，此 entry 暂停 |
| `sq_full` | `lsu_idu_sq_full[i]` | `lsu_idu_sq_not_full \|\| old` | Store Queue 满 |
| `rb_full` | `lsu_idu_rb_full[i]` | `lsu_idu_rb_not_full \|\| old` | Miss Buffer 满 |
| `wait_old` | `lsu_idu_wait_old[i]` | `old`（自己成为最老） | 需等待更老指令 |
| `wait_fence` | `lsu_idu_wait_fence[i]` | `lsu_idu_no_fence` | 需等待 fence 清空 |
| `tlb_busy` | `lsu_idu_tlb_busy[i]` | `lsu_idu_tlb_wakeup[i]` | TLB miss 中 |
| `spec_fail` | `lsu_idu_spec_fail[i]` | 仅重新分配时清 | 推测失败记录 |
| `already_da` | `lsu_idu_already_da[i]` | 重新分配或 unalign 第二次 | 已完成地址转换 |
| `unalign_2nd` | `lsu_idu_secd[i]` | 重新分配 | 非对齐访存第二次 |
| `bkpta_data` | `lsu_idu_bkpta_data[i]` | 重新分配 | 断点 A 数据触发 |
| `bkptb_data` | `lsu_idu_bkptb_data[i]` | 重新分配 | 断点 B 数据触发 |

### 7.3 LSU Freeze 综合清除逻辑（lsu_frz_clr）

```verilog
// ct_idu_is_lsiq_entry.v L:1015–1025
assign lsu_frz_clr =
    (bar_check || no_spec_check || lq_full || sq_full
     || rb_full || wait_old || wait_fence || tlb_busy)  // 至少一个阻塞位激活
  && (!bar_check     || bar_check_wakeup)    // bar_check 已满足或未激活
  && (!no_spec_check || no_spec_check_wakeup)
  && (!lq_full       || lq_full_wakeup)
  && (!sq_full       || sq_full_wakeup)
  && (!rb_full       || rb_full_wakeup)
  && (!wait_old      || wait_old_wakeup)
  && (!wait_fence    || wait_fence_wakeup)
  && (!tlb_busy      || x_tlb_wakeup);
```

**这是一个多重阻塞的集中解除逻辑**。每个阻塞条件都有对应的唤醒信号，只有所有激活的阻塞条件同时满足唤醒条件，`lsu_frz_clr` 才置 1，解除 freeze。这样避免了各个阻塞逻辑的竞争。

### 7.4 弹出（Pop）机制

```verilog
// ct_idu_is_lsiq_entry.v L:638–650（entry vld 逻辑）
always @(posedge entry_clk or negedge cpurst_b) begin
  if(!cpurst_b) vld <= 1'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is) vld <= 1'b0;
  else if(x_create_en)  vld <= 1'b1;
  else if(lsu_idu_lsiq_pop_vld && x_pop_cur_entry) vld <= 1'b0;
end
```

LSIQ 的 pop 是由 **LSU 主动发起**的（`lsu_idu_lsiq_pop_vld` + `pop_entry`），而非 IDU 自主决定。指令发射后，entry 仍然 valid，直到 LSU 确认该访存操作**已进入其内部队列**（LQ 或 SQ），才发信号让 LSIQ 清除 vld。

**为什么这么做？** 因为 LSU 队列（LQ/SQ）可能满，需要重试。发射后 entry 不立即清除，保证重试时可以再次发射。

---

## 8. Freeze（冻结）机制

### 8.1 Freeze 状态机

每个 entry 的 `frz` 寄存器是 LSIQ 顺序控制的核心：

```verilog
// ct_idu_is_lsiq_entry.v L:664–676
always @(posedge entry_clk or negedge cpurst_b) begin
  if(!cpurst_b)     frz <= 1'b0;
  else if(x_create_en)   frz <= x_create_frz;    // 入队时根据情况设置
  else if(x_issue_en)    frz <= 1'b1;             // 发射时设置（等待 pop）
  else if(x_frz_clr || lsu_frz_clr) frz <= 1'b0; // 明确清除
end
```

| 事件 | frz 动作 | 原因 |
|------|----------|------|
| create | 按情况（bar_mode/no_spec/bypass） | 入队时按策略决定是否冻结 |
| issue（发射） | 置 1 | 发射后等待 LSU pop 确认，期间冻结 |
| frz_clr（发射失败 or wakeup） | 清 0 | replay 或 LSU 通知可以重新发射 |
| lsu_frz_clr | 清 0 | 所有 LSU 阻塞条件解除 |

### 8.2 Freeze 在 vld_with_frz 的体现

```verilog
// ct_idu_is_lsiq_entry.v L:656–657
// 非冻结有效项（用于 bypass 检查、发射候选）
assign x_vld_with_frz = vld && (!frz || bar);  // bar 指令的 frz 用另一套机制
assign x_frz_vld      = vld && frz;            // 冻结有效项
```

注意 barrier 指令（`bar=1`）即使 frz 也参与到 `vld_with_frz` 检查中——因为 barrier 的冻结是通过 `bar_check` 来判断的（见第 8.3 节），而 frz 在这里仅防止 bypass 绕过。

### 8.3 Barrier 冻结（bar_check）

barrier 指令入队时有额外的顺序检查：

```verilog
// ct_idu_is_lsiq_entry.v L:859–888
always @(posedge entry_clk ...) begin
  if(x_create_en)         bar_check <= lsiq_bar_mode; // 进队时是否处于 bar 模式
  else if(bar_check_wakeup) bar_check <= 1'b0;         // 条件满足时解冻
end

assign bar_check_wakeup =
    !lsiq_bar_mode   // 已退出 barrier 模式
  // load 的 barrier 唤醒：没有更老的 bar 带 aft_load 约束
  ||  load  && !(|(x_other_bar & agevec_all & x_other_aft_load))
  // store 的 barrier 唤醒：没有更老的 bar 带 aft_store 约束
  ||  store && !(|(x_other_bar & agevec_all & x_other_aft_store))
  // barrier 自身唤醒：所有 before-load/store 约束已满足
  ||  bar   && (!(|(x_other_load  & agevec_all)) && bef_load  || !bef_load)
           && (!(|(x_other_store & agevec_all)) && bef_store || !bef_store)
           && !(|(x_other_bar    & agevec_all));
```

**barrier 模式的工作原理**：

1. 当 IR/IS 级出现 barrier 指令，`lsiq_bar_mode` 置 1
2. 所有后续进入 LSIQ 的指令以 frz=1 入队
3. barrier 指令本身也进入 LSIQ，它会等待所有**更老的指令**（由 bar_type 决定的 before-load/store 约束）先执行完
4. barrier 发射后，它后面的 load/store 检查 aft_load/aft_store 约束，等待 barrier 退出流水线
5. `lsiq_no_bar_inst`（队列中无 barrier）时退出 bar_mode

### 8.4 No-Spec Load 冻结（no_spec_check）

```verilog
// ct_idu_is_lsiq_entry.v L:894–907
always @(posedge entry_clk ...) begin
  // 仅对 no_spec load 生效
  if(x_create_en) no_spec_check <= x_create_data[LSIQ_NO_SPEC] && x_create_data[LSIQ_LOAD];
  else if(no_spec_check_wakeup) no_spec_check <= 1'b0;
end

assign no_spec_check_wakeup =
    load && !(|(x_other_store & x_other_no_spec & agevec_all & ~x_other_frz));
```

不可推测 load（如弱内存序模型下需要等待更老 store 完成的 load）在入队时通过 `no_spec_check` 记录状态，只有当队列中**所有更老的 no_spec store 都已解冻（不再 frz）**后，该 no_spec load 才解除 bar_check 冻结。

**意义**：防止 load 越过前序 no_spec store 造成内存序违例。

---

## 9. load / store 差异处理

### 9.1 发射通道分流

| 类型 | 发射通道 | 信号 |
|------|----------|------|
| load | pipe3 | `lsiq_xx_pipe3_issue_en`，数据从 `lsiq_dp_pipe3_issue_read_data` |
| store 地址 | pipe4 | `lsiq_xx_pipe4_issue_en`，数据从 `lsiq_dp_pipe4_issue_read_data` |
| barrier | pipe4 | 与 store 共用 pipe4 通道 |

### 9.2 SDIQ Entry（store 数据索引）

store 指令的数据部分（要写入内存的值）存放在独立的 **SDIQ（Store Data Issue Queue）**中。LSIQ entry 中的 `sdiq_entry[11:0]` 字段记录了对应 SDIQ 中的位置：

```verilog
// ct_idu_is_lsiq_entry.v L:743–751（SDIQ entry 寄存）
always @(posedge create_sdiq_clk ...) begin
  if(x_create_dp_en)
    sdiq_entry[11:0] <= x_create_data[LSIQ_SDIQ_ENTRY:LSIQ_SDIQ_ENTRY-11];
end
assign x_read_data[LSIQ_SDIQ_ENTRY:LSIQ_SDIQ_ENTRY-11] = sdiq_entry[11:0];
```

当 store 发射时，`lsiq_dp_pipe4_issue_read_data` 中携带 `sdiq_entry`，LSU 用此索引从 SDIQ 中读取 store 数据。

### 9.3 staddr 字段

`staddr` 位标记该 store 指令是否为"地址计算阶段"（store address），区分 store 地址计算与 store 数据准备两个子操作。

### 9.4 lq_full 与 sq_full 的差异处理

- `lq_full`：仅对 **load** 类指令有意义，LQ 满时 load 无法进入 LQ
- `sq_full`：仅对 **store** 类指令有意义，SQ 满时 store 无法进入 SQ

但在 entry 状态机中，两者都无条件设置（由 LSU 的 `lsu_idu_lq_full[i]` / `sq_full[i]` 直接驱动）。唤醒条件也有差异：除了 `lq/sq_not_full` 外，当该 entry 成为**最老**（`old = !(|agevec_all)`）时也会强制唤醒：

```verilog
// ct_idu_is_lsiq_entry.v L:930, 947, 964
assign lq_full_wakeup = lsu_idu_lq_not_full || old;
assign sq_full_wakeup = lsu_idu_sq_not_full || old;
assign rb_full_wakeup = lsu_idu_rb_not_full || old;
```

**`old` 项的准确作用**：`old = !(|agevec_all)` 时，`lq_full/sq_full/rb_full/wait_old` 的本地锁存阻塞可被清除，使该项重新尝试进入 LSU。它没有修改 LSU 实时的 full 状态，也不保证重试一定被接受；若资源仍不可用，LSU 可以再次返回相应阻塞。该机制避免本地历史状态永久抑制最老项，而不是越过容量约束。

---

## 10. 向量访存的特殊处理（srcvm）

### 10.1 srcvm 的意义

向量 load/store（vload/vstore）指令可以使用**掩码寄存器**（vector mask register）控制哪些元素参与访存。这个掩码寄存器是 LSIQ 的第三个源操作数（srcvm）。

相关字段：
- `LSIQ_SRCVM_VLD`（bit 41）：指令是否使用向量掩码
- `LSIQ_SRCVM_VREG`（bits 86:80）：向量掩码寄存器编号（7位）
- `LSIQ_SRCVM_RDY`（bit 78）：写入时为 0，就绪由 dep_vreg_entry 内部维护
- `LSIQ_VMB`（bit 154）：vector mask bit，指示是否为掩码操作
- `LSIQ_VL`（bits 162:155）：向量长度寄存器值（8位）
- `LSIQ_VSEW`（bits 146:144）：向量元素宽度
- `LSIQ_VLMUL`（bits 143:142）：向量长度乘数
- `LSIQ_SPLIT`（bit 123）：是否为拆分向量访存
- `LSIQ_SPLIT_NUM`（bits 153:147）：拆分编号（7位）

### 10.2 srcvm 唤醒来源（dep_vreg_entry 的特殊性）

```verilog
// ct_idu_is_lsiq_entry.v L:1243–1268（srcvm dep_vreg_entry 实例）
ct_idu_dep_vreg_entry x_ct_idu_is_lsiq_srcvm_entry (
  // 向量 load AG 级推测唤醒（向量 load 的目的向量寄存器）
  .lsu_idu_ag_pipe3_vload_inst_vld      (lsu_idu_ag_pipe3_vload_inst_vld),
  .lsu_idu_ag_pipe3_vreg_dupx           (lsu_idu_ag_pipe3_vreg_dupx),
  // DC 级确认 / 转发
  .lsu_idu_dc_pipe3_vload_fwd_inst_vld  (lsu_idu_dc_pipe3_vload_fwd_inst_vld),
  .lsu_idu_dc_pipe3_vload_inst_vld_dupx (lsu_idu_dc_pipe3_vload_inst_vld_dupx),
  .lsu_idu_dc_pipe3_vreg_dupx           (lsu_idu_dc_pipe3_vreg_dupx),
  // WB 级写回
  .lsu_idu_wb_pipe3_wb_vreg_vld_dupx    (lsu_idu_wb_pipe3_wb_vreg_vld_dupx),
  .lsu_idu_wb_pipe3_wb_vreg_dupx        (lsu_idu_wb_pipe3_wb_vreg_dupx),
  // VFPU 写回（向量运算单元写回向量寄存器）
  .vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx  (vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx),
  .vfpu_idu_ex5_pipe7_wb_vreg_vld_dupx  (vfpu_idu_ex5_pipe7_wb_vreg_vld_dupx),
  // VFPU 中间级前向（全接 0，timing 优化）
  .vfpu_idu_ex1_pipe6_data_vld_dupx (1'b0),
  .vfpu_idu_ex2_pipe6_data_vld_dupx (1'b0),
  ...
);
```

在保留向量配置中，srcvm 的唤醒来源包括：
1. 向量 load AG 级推测（`ag_vload_inst_vld`）
2. 向量 load DC 级确认/转发（`dc_vload_inst_vld` / `dc_vload_fwd_inst_vld`）
3. 向量 load WB 级写回（`wb_vreg_vld`）
4. VFPU EX5 级写回（向量运算最终写回）
5. **不接 VFPU EX1/EX2/EX3 级前向**（对应输入接 0；注释标为 timing optimization）

**实现取舍**：该网络保留 LSU 多级事件与 VFPU EX5 写回，却省略 VFPU EX1～EX3 中间级连接，因此来自 VFPU 的依赖可能只能等到更晚的写回点才被标记 ready。注释给出 timing optimization 方向，但没有 STA 数据时，不把它进一步写成“时序不允许”。当前 RVV 关闭时，这一差异主要是保留结构说明。

---

## 11. 发射到 pipe3 / pipe4

### 11.1 发射数据选择

发射时数据选择是一个 12:1 的 MUX，输入为 12 个 entry 的 read_data，选择信号为 one-hot 的 `lsiq_pipe3_entry_issue_en`：

```verilog
// ct_idu_is_lsiq.v L:2407–2436（pipe3 发射数据选择）
always @(...) begin
  case (lsiq_pipe3_entry_issue_en[11:0])
    12'h001: lsiq_pipe3_entry_read_data = lsiq_entry0_read_data;
    12'h002: lsiq_pipe3_entry_read_data = lsiq_entry1_read_data;
    ...
    12'h800: lsiq_pipe3_entry_read_data = lsiq_entry11_read_data;
    default: lsiq_pipe3_entry_read_data = {LSIQ_WIDTH{1'bx}};
  endcase
end
```

最终，若当前为 bypass 模式（`lsiq_create_bypass_empty=1`），则输出 bypass 数据；否则输出选中 entry 的数据：

```verilog
// ct_idu_is_lsiq.v L:2485–2492
assign lsiq_dp_pipe3_issue_read_data =
    (lsiq_create_bypass_empty)
    ? dp_lsiq_bypass_data
    : lsiq_pipe3_entry_read_data;
```

### 11.2 发射 entry 指示信号

同样，bypass 时 entry 指示信号来自 `create0_in`（即分配到的 entry），否则来自实际就绪的 entry：

```verilog
// ct_idu_is_lsiq.v L:2381–2386
assign lsiq_dp_pipe3_issue_entry =
    (lsiq_create_bypass_empty)
    ? lsiq_entry_create0_in  // bypass 时使用分配的 entry 编号
    : lsiq_pipe3_entry_issue_en;
```

### 11.3 发射使能信号

```verilog
// ct_idu_is_lsiq.v L:2357–2363
assign lsiq_xx_pipe3_issue_en = |{lsiq_pipe3_bypass_en,
                                   lsiq_pipe3_entry_ready[11:0]};
assign lsiq_xx_pipe4_issue_en = |{lsiq_pipe4_bypass_en,
                                   lsiq_pipe4_entry_ready[11:0]};
```

`lsiq_xx_pipe3/4_issue_en` 是发给上层（`ctrl`）的发射使能，上层 ctrl 模块根据此信号决定是否真正驱动 RF 读和 pipe 流水线。

---

## 12. Flush 处理

### 12.1 两种 flush

C910 有两个层次的 flush：

| 信号 | 触发 | 范围 |
|------|------|------|
| `rtu_idu_flush_fe` | 分支预测错误等，前端（FE）flush | 清除所有 entry |
| `rtu_idu_flush_is` | 精确异常，发射级（IS）flush | 清除所有 entry |
| `rtu_yy_xx_flush` | 全局 flush | 仅影响 entry_cnt 计数器 |

### 12.2 各 entry 的 flush 响应

```verilog
// ct_idu_is_lsiq_entry.v L:638–649（entry vld flush）
always @(posedge entry_clk ...) begin
  if(!cpurst_b) vld <= 1'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is) vld <= 1'b0;
  else if(x_create_en) vld <= 1'b1;
  else if(lsu_idu_lsiq_pop_vld && x_pop_cur_entry) vld <= 1'b0;
end
```

flush 使所有 entry 的 `vld` 立刻清零。

### 12.3 LSU 反馈位的 flush 处理

各阻塞状态寄存器（`lq_full`、`sq_full`、`rb_full`、`wait_old`、`wait_fence`、`tlb_busy`）都在 flush 时清零：

```verilog
// ct_idu_is_lsiq_entry.v L:916–928（以 lq_full 为例）
always @(posedge lq_full_clk ...) begin
  if(!cpurst_b) lq_full <= 1'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is) lq_full <= 1'b0;
  ...
end
```

但 `spec_fail`、`already_da`、`unalign_2nd`、`bkpta_data`、`bkptb_data` 等状态**不在 flush 时清零**，它们只在 `x_create_en` 时清零——这些状态记录的是已发射到 LSU 的信息，flush 后 LSU 会重新下发，不需要提前清除。

### 12.4 entry_cnt 的特殊 flush

```verilog
// ct_idu_is_lsiq.v L:1378–1379
else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush)
    lsiq_entry_cnt <= 4'b0;
```

计数器除了响应 fe/is flush，还额外响应 `rtu_yy_xx_flush`。原因是 flush 后 LSU 可能在 `rtu_yy_xx_flush` 到达前就发出错误的 pop 信号，需要多加一个保护。

---

## 13. 时钟门控

LSIQ 为不同状态组生成多组局部时钟请求，每种功能有对应的 `*_clk_en`：

```verilog
// ct_idu_is_lsiq_entry.v L:486–617（门控时钟定义）

// entry 级局部请求：entry 有效或有新指令进入
assign entry_clk_en = x_create_gateclk_en || vld;

// 创建路径局部请求：有新指令写入
assign create_clk_en = x_create_gateclk_en;

// 目的物理寄存器局部请求：创建且有目的寄存器
assign create_preg_clk_en = x_create_gateclk_en && x_create_data[LSIQ_DST_VLD];

// 向量目的寄存器门控：仅在有向量目的时开
assign create_vreg_clk_en = x_create_gateclk_en && x_create_data[LSIQ_DSTV_VLD];

// bar 类型门控：仅 barrier 指令写入时开
assign create_bar_clk_en = x_create_gateclk_en && x_create_data[LSIQ_BAR];

// SDIQ 指针门控：仅在创建时开
assign create_sdiq_clk_en = x_create_gateclk_en;

// 非对齐门控：创建或 LSU 非对齐更新时开
assign unalign_clk_en = x_create_gateclk_en || x_unalign_gateclk_en;
```

顶层 `ct_idu_is_lsiq.v` 中有对应 LSU 反馈位的共享门控时钟：

| 门控时钟 | 使能条件 | 服务对象 |
|---------|---------|---------|
| `lq_full_clk` | `lsu_idu_lq_full_gateclk_en \|\| any_entry_lq_full` | 所有 entry 的 lq_full 寄存器 |
| `sq_full_clk` | `lsu_idu_sq_full_gateclk_en \|\| any_entry_sq_full` | 所有 entry 的 sq_full |
| `rb_full_clk` | `lsu_idu_rb_full_gateclk_en \|\| any_entry_rb_full` | 所有 entry 的 rb_full |
| `tlb_busy_clk` | `lsu_idu_tlb_busy_gateclk_en \|\| any_entry_tlb_busy` | 所有 entry 的 tlb_busy |
| `wait_old_clk` | `lsu_idu_wait_old_gateclk_en \|\| any_entry_wait_old` | 所有 entry 的 wait_old |
| `wait_fence_clk` | `lsu_idu_wait_fence_gateclk_en \|\| any_entry_wait_fence` | 所有 entry 的 wait_fence |
| `bar_clk` | `lsiq_bar_mode \|\| bar_inst_vld` | lsiq_bar_mode 寄存器 |

这些 `clk_out` 被连接到全部 12 个 entry 的对应状态更新逻辑，而非为每个 entry 各实例化一套该类共享门控。
RTL 能证明共享连接和局部使能方程；时钟树复杂度、插入延迟、面积与功耗是否更优仍由物理实现决定。

还需注意公共 `gated_clk_cell` 的边界：局部请求不是唯一使能源，功能使能为
`global_en && (module_en || local_en)`，扫描使能可打开工艺 ICG；未定义
`C910_USE_TSMC28_ICG` 时当前 RTL 模型直接 `clk_out = clk_in`。因此本文中的“请求”均不应读成
“`local_en=0` 时物理时钟必然停止”。

---

## 14. 关键信号速查表

### 14.1 LSU 流水级信号对应关系

```
LSU pipe3 流水线时序图：

周期:  T       T+1     T+2     T+3
       IS      AG      DC      WB
       ────────────────────────────
发射   load A
              ag_load_inst_vld=1
              ag_preg = A.dst     → dep_reg_entry 推测唤醒 A 的依赖者
                      dc_load_inst_vld=1（hit）
                      dc_load_fwd（fwd） → dep_reg_entry 确认或转发唤醒
                                      wb_preg_vld=1  → 最终写回
                                      pop_vld=1      → entry vld 清零
```

### 14.2 entry 状态总结

```
entry 状态机（主要路径）：

空闲 ──create_en──> 有效(frz=create_frz)
                        │
                   frz=0 时 raw_rdy 条件满足且无更老同类 ready
                        │
                   ──issue_en──> 发射(frz=1，等待 pop)
                        │
              ┌─────────┴─────────┐
           pop_vld              lch_fail_vld
              │                    │
            清除 vld             frz_clr，rdy_clr
           （entry 空闲）        （replay，重新等待唤醒）
```

### 14.3 各阻塞条件与对应唤醒

| 阻塞位 | 设置时机 | 唤醒条件 |
|-------|---------|---------|
| `frz` | create/issue/LSU barrier | `frz_clr`（发射失败）或 `lsu_frz_clr`（所有 LSU 条件满足）|
| `bar_check` | create 时 bar_mode=1 | 满足所有 barrier 顺序约束 |
| `no_spec_check` | create no_spec load | 没有更老的未冻结 no_spec store |
| `lq_full` | LSU LQ 满 | `lq_not_full` 或 entry 成为最老 |
| `sq_full` | LSU SQ 满 | `sq_not_full` 或 entry 成为最老 |
| `rb_full` | LSU rb 满 | `rb_not_full` 或 entry 成为最老 |
| `wait_old` | LSU 需要等待更老 | entry 成为最老（`old` 信号） |
| `wait_fence` | LSU 需要等待 fence | `lsu_idu_no_fence`（fence 清空）|
| `tlb_busy` | TLB miss | `lsu_idu_tlb_wakeup[i]`（TLB 完成）|

---

## 附录：模块层次关系

```
ct_idu_is_lsiq（顶层）
├── ct_idu_is_lsiq_entry × 12（entry0 ~ entry11）
│   ├── ct_idu_dep_reg_entry（src0，基址寄存器依赖追踪）
│   ├── ct_idu_dep_reg_entry（src1，偏移寄存器依赖追踪）
│   └── ct_idu_dep_vreg_entry（srcvm，向量掩码寄存器依赖追踪）
└── gated_clk_cell × N（各种门控时钟）
```

`dep_reg_entry` 内部维护一个物理寄存器就绪状态机，监听所有写回总线（包括 AG/DC/WB 级 load 推测和确认），输出 `x_read_data[9]`（就绪位）。`dep_vreg_entry` 类似，专门处理向量寄存器。

---

*文档对应 RTL 版本：OpenC910 开源版本，`ct_idu_is_lsiq.v`（4114 行）及 `ct_idu_is_lsiq_entry.v`（1325 行）。*
