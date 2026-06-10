# C910 IDU ALU 发射队列（AIQ）详解

> RTL 源文件：
> - `ct_idu_is_aiq0.v`（2124 行，AIQ0 顶层）
> - `ct_idu_is_aiq1.v`（2154 行，AIQ1 顶层）
> - `ct_idu_is_aiq0_entry.v`（2668 行，AIQ0 队列项）
> - `ct_idu_is_aiq1_entry.v`（2580 行，AIQ1 队列项）
> - `ct_idu_is_aiq_lch_rdy_1/2/3.v`（各约 105 行，发射就绪仲裁单元）

---

## 1. 模块概述

### 1.1 发射队列在乱序核中的角色

C910 是一款超标量乱序执行处理器，其指令调度分为以下几个阶段：

```
取指 → 译码 → 重命名/分配 → 派遣(Dispatch) → 发射队列(IQ) → 发射(Issue) → 执行
```

**发射队列（Issue Queue，IQ）** 是乱序调度的核心结构，承担以下职责：

1. **缓存已派遣但尚未发射的指令**：指令完成寄存器重命名后写入发射队列，等待源操作数全部就绪。
2. **持续监听写回总线（唤醒）**：每个队列项持续侦听所有写回通路，一旦其依赖的物理寄存器被写回，立即将对应源操作数标记为"就绪"。
3. **选择（仲裁）最老的就绪指令发射**：在多个就绪指令中，依照年龄优先原则选出最老的一条，下发到执行单元。

### 1.2 保留站 vs 发射队列

| 特性 | Reservation Station (RS) | 集中式发射队列 (IQ) |
|------|--------------------------|---------------------|
| 代表架构 | Intel P6 / Tomasulo | Alpha 21264 / C910 |
| 存放位置 | 每条功能单元各有专属 RS | 集中或按功能分组 |
| 操作数存储 | RS 中保存操作数值 | IQ 只保存物理寄存器编号，发射时从 RF 读 |
| 面积 | 较大（每项含操作数字段） | 较小（项目内不存实际数据） |

C910 AIQ 属于**分布式发射队列**模型：AIQ0 专服务 ALU Pipe0（含除法、特殊指令），AIQ1 专服务 ALU Pipe1（含乘法）。这种分发保证了两条 ALU 通路可以同时发射。

### 1.3 AIQ 服务的功能单元

| 发射队列 | 对应管道 | 执行单元 |
|----------|----------|----------|
| AIQ0     | Pipe0    | ALU0 + DIV（除法）+ SPECIAL（CSR/TLB 等特殊指令） |
| AIQ1     | Pipe1    | ALU1 + MUL/MLA（乘法/乘累加） |

---

## 2. 队列整体结构

### 2.1 顶层架构图

```
                  ┌─────────────────────────────────────────────┐
                  │              ct_idu_is_aiq0                 │
                  │                                             │
  Dispatch ──────►│  create0_en  create1_en                     │
  (ctrl/dp)       │       │           │                         │
                  │  ┌────▼──────┬────▼──────┐                  │
                  │  │ entry_    │ entry_    │                  │
                  │  │ create0   │ create1   │                  │
                  │  │ selector  │ selector  │                  │
                  │  │ (e0→e7   │ (e7→e0   │                  │
                  │  │  priority)│  priority)│                  │
                  │  └────┬──────┴────┬──────┘                  │
                  │       │ agevec    │ agevec                  │
                  │  ┌────▼──────────▼──────────────────────┐  │
                  │  │  entry[0..7]  (ct_idu_is_aiq0_entry) │  │
                  │  │  每项含: vld/frz/iid/opcode/preg/    │  │
                  │  │          agevec/src_rdy               │  │
                  │  │          lch_rdy[aiq0/aiq1/biq/lsiq/sdiq] │
                  │  └────────────────────────┬─────────────┘  │
                  │                           │ entry_ready[7:0]│
                  │  ┌────────────────────────▼─────────────┐  │
                  │  │  older_entry_ready + issue_en 仲裁   │  │
                  │  │  (age-based priority selection)      │  │
                  │  └────────────────────────┬─────────────┘  │
                  │                           │ issue_en[7:0]   │
                  │                    bypass_en                │
                  └───────────────────────────┼─────────────────┘
                                              │
                                      aiq0_xx_issue_en
                                      aiq0_dp_issue_entry[7:0]
                                      aiq0_dp_issue_read_data[226:0]
```

### 2.2 关键设计参数

```
AIQ0_WIDTH = 227 位（每项数据总线宽度）
AIQ1_WIDTH = 214 位
深度        = 8 项（entry[0..7]）
源操作数数量 = 3 个（src0/src1/src2）
物理寄存器位宽 = 7 位（128 个物理寄存器）
IID 位宽    = 7 位（指令标识符，用于年龄比较）
```

---

## 3. 端口说明

### 3.1 AIQ0 主要输入端口

| 端口名 | 位宽 | 方向 | 说明 |
|--------|------|------|------|
| `ctrl_aiq0_create0_en` | 1 | I | 派遣通道 0 使能（控制路径） |
| `ctrl_aiq0_create1_en` | 1 | I | 派遣通道 1 使能 |
| `ctrl_aiq0_create0_dp_en` | 1 | I | 派遣通道 0 数据路径使能（时序优化分离） |
| `dp_aiq0_create0_data[226:0]` | 227 | I | 派遣指令 0 的完整字段数据 |
| `dp_aiq0_create1_data[226:0]` | 227 | I | 派遣指令 1 的完整字段数据 |
| `dp_aiq0_bypass_data[226:0]` | 227 | I | Bypass 路径数据（直接发射无需入队） |
| `dp_aiq0_create_div` | 1 | I | 该次派遣是除法指令标记 |
| `dp_aiq0_create_src{0/1/2}_rdy_for_bypass` | 1 | I | Bypass 时源操作数就绪判断 |
| `dp_aiq0_rf_lch_entry[7:0]` | 8 | I | RF 阶段哪个 entry 被发射（one-hot） |
| `dp_aiq0_rf_rdy_clr[2:0]` | 3 | I | 发射失败时清除 src_rdy 的掩码 |
| `ctrl_aiq0_rf_pop_vld` | 1 | I | RF 阶段发射成功，弹出 entry |
| `ctrl_aiq0_rf_lch_fail_vld` | 1 | I | RF 阶段发射失败 |
| `ctrl_aiq0_stall` | 1 | I | 流水线暂停 |
| `iu_idu_div_busy` | 1 | I | 除法单元忙，暂不发射 DIV 指令 |
| `ctrl_aiq0_rf_pipe0_alu_reg_fwd_vld[23:0]` | 24 | I | Pipe0 ALU 前递有效（每 entry 3 位，共 8 entries） |
| `ctrl_aiq0_rf_pipe1_alu_reg_fwd_vld[23:0]` | 24 | I | Pipe1 ALU 前递有效 |
| `iu_idu_ex2_pipe0_wb_preg_dupx[6:0]` | 7 | I | Pipe0 EX2 写回物理寄存器号 |
| `iu_idu_ex2_pipe0_wb_preg_vld_dupx` | 1 | I | Pipe0 EX2 写回有效 |
| `lsu_idu_wb_pipe3_wb_preg_dupx[6:0]` | 7 | I | LSU 写回物理寄存器号 |
| `lsu_idu_ag_pipe3_load_inst_vld` | 1 | I | LSU AG 段 load 指令有效（早期唤醒） |
| `rtu_idu_flush_fe/is` | 1 | I | 前端/发射队列冲刷信号 |
| `rtu_yy_xx_flush` | 1 | I | 全局冲刷（用于 entry_cnt 复位） |

### 3.2 AIQ0 主要输出端口

| 端口名 | 位宽 | 方向 | 说明 |
|--------|------|------|------|
| `aiq0_xx_issue_en` | 1 | O | 本周期有可发射指令 |
| `aiq0_xx_gateclk_issue_en` | 1 | O | 门控时钟版发射使能 |
| `aiq0_dp_issue_entry[7:0]` | 8 | O | 被选中发射的 entry（one-hot） |
| `aiq0_dp_issue_read_data[226:0]` | 227 | O | 被选中 entry 的完整数据 |
| `aiq0_ctrl_full` | 1 | O | 队列已满 |
| `aiq0_ctrl_full_updt` | 1 | O | 下周期将满 |
| `aiq0_ctrl_1_left_updt` | 1 | O | 下周期将只剩一个空闲项 |
| `aiq0_ctrl_empty` | 1 | O | 队列为空 |
| `aiq0_aiq_create0_entry[7:0]` | 8 | O | create0 分配给哪个 entry（one-hot，发给各 IQ 的 aiq0 lch_rdy 仲裁） |
| `aiq0_aiq_create1_entry[7:0]` | 8 | O | create1 分配给哪个 entry（one-hot） |
| `aiq0_ctrl_entry_cnt_updt_val[3:0]` | 4 | O | entry 计数器更新值（供 DLB） |
| `aiq0_top_aiq0_entry_cnt[3:0]` | 4 | O | 当前 AIQ0 中有效 entry 数量 |

> **注**：`_dupx` 后缀的信号表示该信号被"复制"（duplicated）以满足扇出时序，多个接收模块各有一份独立连线。

---

## 4. Entry 分配（Dispatch 进队列）

### 4.1 分配策略：双通道反向优先

C910 支持每周期最多派遣两条指令（create0 和 create1）到同一个 AIQ。为避免两条指令抢占同一 entry，采用**反向扫描分离策略**：

```verilog
// ct_idu_is_aiq0.v，行 698-758
// create0 从 entry0 向 entry7 顺序找第一个空闲项（低地址优先）
always @(...) begin
  if(!aiq0_entry0_vld)
    aiq0_entry_create0_in[7:0] = 8'b0000_0001;
  else if(!aiq0_entry1_vld)
    aiq0_entry_create0_in[7:0] = 8'b0000_0010;
  ...
  else if(!aiq0_entry7_vld)
    aiq0_entry_create0_in[7:0] = 8'b1000_0000;
end

// create1 从 entry7 向 entry0 反向找第一个空闲项（高地址优先）
always @(...) begin
  if(!aiq0_entry7_vld)
    aiq0_entry_create1_in[7:0] = 8'b1000_0000;
  else if(!aiq0_entry6_vld)
    aiq0_entry_create1_in[7:0] = 8'b0100_0000;
  ...
end
```

**为什么双向扫描**：如果两个通道都从低地址扫，当队列中只剩一个空项时，两个通道会选中同一个 entry，造成写冲突。反向扫描保证只要队列剩余空项 >= 2，两条指令一定选中不同 entry。当只剩一个空项时，通过 `aiq0_ctrl_1_left_updt` 信号通知 ctrl，控制层不会同时派遣两条指令。

### 4.2 Entry 创建使能生成

```verilog
// ct_idu_is_aiq0.v，行 769-771
assign aiq0_entry_create_en[7:0] =
       {8{ctrl_aiq0_create0_en}} & aiq0_entry_create0_in[7:0]
     | {8{ctrl_aiq0_create1_en}} & aiq0_entry_create1_in[7:0];
```

通过广播形式，同时向所有 8 个 entry 发送各自的 create_en，每个 entry 只有自己的 bit 为 1 时才实际写入数据。

### 4.3 create0 vs create1 数据选择

每个 entry 需要判断自己是接收 create0 还是 create1 的数据。设计采用了**时序优化的二选一方案**：

```verilog
// ct_idu_is_aiq0.v，行 831-834
// entry0-3: create_sel=0 → 选 create0；create_sel=1 → 选 create1
assign aiq0_entry_create_sel[3:0] = ~({4{ctrl_aiq0_create0_dp_en}}
                                      & aiq0_entry_create0_in[3:0]);
// entry4-7: create_sel=0 → 选 create0；create_sel=1 → 选 create1
assign aiq0_entry_create_sel[7:4] = {4{ctrl_aiq0_create1_dp_en}}
                                     & aiq0_entry_create1_in[7:4];
```

注释说明（行 826-829）：`aiq0_entry_create0_in` 与 `aiq0_entry_create1_in` 不可能同时为 1，故可用取反实现选择，降低关键路径延迟。

### 4.4 Age Vector（年龄向量）

每条入队指令携带一个 7 位的 `agevec`，记录队列中比自己**年轻**（后入队）的 entry 集合（不含自身）。该向量在入队时由顶层计算：

```verilog
// ct_idu_is_aiq0.v，行 817-824
// create0 的 agevec = 当前已有效 entry 列表（排除即将弹出的）
assign aiq0_entry_create0_agevec[7:0] = aiq0_entry_vld[7:0]
                                        & ~({8{ctrl_aiq0_rf_pop_vld}}
                                           & dp_aiq0_rf_lch_entry[7:0]);

// create1 的 agevec = create0 的 agevec + create0 自身（因为 create1 比 create0 晚进）
assign aiq0_entry_create1_agevec[7:0] = aiq0_entry_vld[7:0]
                                        & ~(...)
                                        | aiq0_entry_create0_in[7:0];
```

每个 entry 存储的 `agevec[6:0]` 是 7 位（表示另外 7 个 entry 中哪些比自己年轻），bit 位顺序为从入队时刻的那一帧看，其他 entry 是否存在。发射后弹出 entry 时，其他 entry 的 `agevec` 要减去已弹出的 entry：

```verilog
// ct_idu_is_aiq0_entry.v，行 917-920
else if(ctrl_aiq0_rf_pop_vld)
    agevec[6:0] <= agevec[6:0] & ~x_pop_other_entry[6:0];
```

`x_pop_other_entry[6:0]` 是弹出 entry 在其他 entry 视角中的索引位，确保 agevec 始终准确。

> **agevec 的本质**：`agevec[i][j]=1` 表示"在 entry[i] 入队时，entry[j] 已经在队列中了"，即 entry[j] 比 entry[i] 更老。所以如果 `aiq0_entry_ready[j]=1 & aiq0_entryi_agevec[j]=1`，说明有比 entry[i] 更老且就绪的指令，entry[i] 不该在本周期发射。

---

## 5. 唤醒机制（Wakeup）

### 5.1 架构原理

乱序处理器中，指令入队时其源操作数可能尚未就绪（依赖先前未执行完的指令）。唤醒机制解决"何时所有源就绪"的问题。

C910 AIQ 的唤醒分为**两层**：

1. **dep_reg_entry 层（实时唤醒）**：每个源操作数通过 `ct_idu_dep_reg_entry` 实例独立追踪，接收所有写回通路广播，实时更新 `src_rdy_for_issue`（详见 22_dep 文档）。

2. **lch_rdy 层（前递就绪追踪）**：追踪"当另一个发射队列的某 entry 发射时，其结果是否能转发给本 entry 的某个源"——这是用于 RF 阶段的延迟就绪信号，见第 6 节。

### 5.2 dep_reg_entry 实例化

每个 AIQ entry 中为三个源操作数（src0/src1/src2）各实例化一个 `ct_idu_dep_reg_entry`：

```verilog
// ct_idu_is_aiq0_entry.v，行 1068-1109
ct_idu_dep_reg_entry  x_ct_idu_is_aiq0_src0_entry (
  .alu0_reg_fwd_vld   (x_alu0_reg_fwd_vld[0]),  // Pipe0 ALU 前递有效
  .alu1_reg_fwd_vld   (x_alu1_reg_fwd_vld[0]),  // Pipe1 ALU 前递有效
  .iu_idu_ex2_pipe0_wb_preg_dupx   (...),        // EX2 写回寄存器号
  .iu_idu_ex2_pipe0_wb_preg_vld_dupx (...),      // EX2 写回有效
  .lsu_idu_wb_pipe3_wb_preg_dupx   (...),        // LSU 写回
  ...
  .x_create_data      (create_src0_data[9:0]),   // 入队时的 {lsu_match, preg[6:0], rdy, wb}
  .x_read_data        (read_src0_data[11:0]),    // 当前状态读出
  .x_write_en         (x_create_dp_en),          // 入队写使能
  .x_rdy_clr          (src0_rdy_clr)             // 发射失败时清除 rdy
);
```

从 `read_src0_data` 中取出：
- `read_src0_data[9]` → `src0_rdy_for_issue`：该源操作数是否已就绪可发射
- `read_src0_data[8:2]` → 物理寄存器号（用于 RF 读端口地址）
- `read_src0_data[1]` → wb 标记（表示该 preg 是从 WB 通路唤醒的）

### 5.3 写回广播来源

AIQ entry 中每个 dep_reg_entry 接收的写回广播来源汇总：

| 写回来源 | 信号 | 说明 |
|----------|------|------|
| Pipe0 EX2 ALU | `iu_idu_ex2_pipe0_wb_preg_dupx` + `vld` | ALU0 执行完成 |
| Pipe1 EX2 ALU/MULT | `iu_idu_ex2_pipe1_wb_preg_dupx` + `vld` | ALU1/MUL 执行完成 |
| Pipe1 MULT 延迟唤醒 | `iu_idu_ex2_pipe1_mult_inst_vld_dupx` + `preg` | 乘法提前唤醒 |
| LSU AG 段 Load | `lsu_idu_ag_pipe3_load_inst_vld` + `preg` | Load 早期唤醒（推测） |
| LSU DC 段 Load | `lsu_idu_dc_pipe3_load_inst_vld_dupx` + `preg` | Load DC 段确认 |
| LSU DC 段 Fwd | `lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx` + `preg` | Load 转发 |
| LSU WB | `lsu_idu_wb_pipe3_wb_preg_dupx` + `vld` | LSU 写回 |
| DIV | `iu_idu_div_inst_vld` + `preg` | 除法完成 |
| VFPU Pipe6 MFVR | `vfpu_idu_ex1_pipe6_mfvr_inst_vld_dupx` + `preg` | 向量到整数移动 |
| VFPU Pipe7 MFVR | `vfpu_idu_ex1_pipe7_mfvr_inst_vld_dupx` + `preg` | 向量到整数移动 |
| RF Pipe0 发射前递 | `dp_xx_rf_pipe0_dst_preg_dupx` + `ctrl_xx_rf_pipe0_preg_lch_vld_dupx` | 发射级前递 |
| RF Pipe1 发射前递 | `dp_xx_rf_pipe1_dst_preg_dupx` + `ctrl_xx_rf_pipe1_preg_lch_vld_dupx` | 发射级前递 |

dep_reg_entry 模块内部将这些广播信号与自身保存的物理寄存器号做比较，一旦命中且信号有效，立即将 `rdy` 置 1。具体实现见 **22_dep 文档**。

### 5.4 发射失败时的 rdy 清除

C910 采用"推测性发射"（speculative issue）：一条指令在 load 结果尚未确认时就推测性地唤醒其后继，若 load miss，则需撤销后继指令的发射：

```verilog
// ct_idu_is_aiq0_entry.v，行 1060-1062
assign src0_rdy_clr = x_frz_clr && dp_aiq0_rf_rdy_clr[0];
assign src1_rdy_clr = x_frz_clr && dp_aiq0_rf_rdy_clr[1];
assign src2_rdy_clr = x_frz_clr && dp_aiq0_rf_rdy_clr[2];
```

`x_frz_clr` 在发射失败时有效，同时清除相应 src_rdy，使该指令重新进入等待状态，下一次被真实唤醒后再发射。

---

## 6. 发射就绪判定

### 6.1 entry_rdy 信号

每个 entry 的 `x_rdy`（即 AIQ0 层面的 `aiq0_entry_N_rdy`）是最终发射就绪信号，由多个条件 AND 组成：

```verilog
// ct_idu_is_aiq0_entry.v，行 2657-2663
assign x_rdy = vld                           // 本 entry 有有效指令
               && !frz                       // 本 entry 未被冻结
               && !ctrl_aiq0_stall           // 流水线未暂停
               && !(x_read_data[AIQ0_DIV] && iu_idu_div_busy)
                                             // 除法指令时除法单元空闲
               && src0_rdy_for_issue         // src0 就绪
               && src1_rdy_for_issue         // src1 就绪
               && src2_rdy_for_issue;        // src2 就绪
```

**各条件的含义**：

| 条件 | 说明 |
|------|------|
| `vld` | 本 entry 存有未发射指令 |
| `!frz` | Freeze 机制：指令已被选中发射但尚未确认弹出时置 1，防止重复发射 |
| `!stall` | 全局暂停时不发射（如资源冲突） |
| `DIV+busy` | 除法器是单发单发射的，已在执行则不能再发射另一条 DIV |
| `src_rdy` | 三个源操作数全部就绪 |

### 6.2 AIQ1 的额外条件

AIQ1 entry 的就绪判断在 src_rdy 基础上增加了**乘法停顿**检查：

```verilog
// ct_idu_is_aiq1_entry.v，行 2569-2575
assign x_rdy = vld
               && !frz
               && !ctrl_aiq1_stall
               && !(lch_preg && iu_idu_ex1_pipe1_mult_stall)
                                             // 乘法停顿：结果尚未转发
               && src0_rdy_for_issue
               && src1_rdy_for_issue
               && src2_rdy_for_issue;
```

`lch_preg` 表示本指令依赖来自 Pipe1 RF 级的前递（乘法结果），而 `iu_idu_ex1_pipe1_mult_stall` 表示当前周期该前递不可用，需等待。

### 6.3 vld_with_frz

```verilog
// ct_idu_is_aiq0_entry.v，行 892
assign x_vld_with_frz = vld && !frz;
```

`vld_with_frz` 用于门控时钟使能判断（不含冻结项），区别于 `vld`（包含冻结项）。后者用于空闲 entry 查找，前者用于发射就绪判断。

---

## 7. 选择/仲裁逻辑：唤醒-选择的灵魂

### 7.1 年龄优先仲裁原理

当多个 entry 同时就绪时，必须选出**最老**的一条。C910 使用 **Age Vector 矩阵仲裁**：

```
基本原理：entry[i] 满足发射条件 ⟺
    entry[i].rdy == 1
    AND
    不存在任何 entry[j]（j≠i）满足：
        entry[j].rdy == 1 AND agevec[i][j] == 1
       （即没有比 entry[i] 更老的就绪项）
```

RTL 实现：

```verilog
// ct_idu_is_aiq0.v，行 1097-1118
// Step 1: 对每个 entry，检查是否有"更老的就绪 entry"存在
// agevec[6:0] 中存的是：其他 entry 是否比自己更老
// 注意：agevec 是 7 位，表示 7 个"其他 entry"（不含自身）

assign aiq0_older_entry_ready[0] = |(aiq0_entry0_agevec[6:0]
                                     & aiq0_entry_ready[7:1]);
// entry0 的 agevec[6:0] 对应 entry[7:1]
// 若 agevec 中有 1 且对应 entry 也 ready，则存在更老的就绪项

assign aiq0_older_entry_ready[1] = |(aiq0_entry1_agevec[6:0]
                                     & {aiq0_entry_ready[7:2],
                                        aiq0_entry_ready[0]});
// entry1 的 agevec[6:0] 对应 [7:2,0]（跳过自身 entry1）
...
assign aiq0_older_entry_ready[7] = |(aiq0_entry7_agevec[6:0]
                                     & aiq0_entry_ready[6:0]);
// entry7 的 agevec[6:0] 对应 [6:0]（排除 entry7 自身）

// Step 2: 最终发射使能 = 就绪 AND 没有更老的就绪项
assign aiq0_entry_issue_en[7:0] = aiq0_entry_ready[7:0]
                                  & ~aiq0_older_entry_ready[7:0];
```

**关键映射说明**（以 entry1 为例）：

```
entry1 的 agevec 存储的 7 位按如下对应关系映射到 8 个 entry：
  agevec[6] → entry7
  agevec[5] → entry6
  agevec[4] → entry5
  agevec[3] → entry4
  agevec[2] → entry3
  agevec[1] → entry2
  agevec[0] → entry0
（跳过了 entry1 自身）
```

**为什么年龄优先而不是简单优先级**：年龄优先保证了指令的执行次序相对合理（旧指令先执行可减少后续依赖等待），避免新指令反复抢占旧指令的发射机会（饥饿问题）。

### 7.2 Bypass 发射（零延迟旁路）

当队列为空且入队指令源操作数全部就绪时，可以跳过队列直接发射（bypass），减少一个周期延迟：

```verilog
// ct_idu_is_aiq0.v，行 655-661
assign aiq0_create0_rdy_bypass = ctrl_aiq0_create0_en
                                 && !cp0_idu_iq_bypass_disable  // 未被禁用
                                 && !ctrl_aiq0_stall
                                 && !(dp_aiq0_create_div && iu_idu_div_busy)
                                 && dp_aiq0_create_src0_rdy_for_bypass
                                 && dp_aiq0_create_src1_rdy_for_bypass
                                 && dp_aiq0_create_src2_rdy_for_bypass;

assign aiq0_bypass_en = aiq0_create_bypass_empty  // 队列为空
                        && aiq0_create0_rdy_bypass;
```

只有 create0（不是 create1）才能 bypass，且要求队列完全为空（含冻结项）：

```verilog
// ct_idu_is_aiq0.v，行 686-693
assign aiq0_create_bypass_empty = !(aiq0_entry0_vld_with_frz
                                    || ... || aiq0_entry7_vld_with_frz);
```

**Bypass 的意义**：对于简单整数指令序列（操作数已就绪），避免每条指令都经历一个"入队→等待→仲裁→发射"的完整周期，直接在派遣周期发射，提升 IPC。

### 7.3 发射条件总览

```
最终发射 entry：
    if (bypass_en) → 直接发射 create0 的指令（数据走 bypass_data 路径）
    else           → 发射 entry_issue_en 指向的 entry（恰好只有 1 位为 1）

aiq0_dp_issue_entry[7:0] = bypass ? create0_in : entry_issue_en
aiq0_dp_issue_read_data  = bypass ? bypass_data : entry_read_data（MUX 选出）
```

### 7.4 issue_en 一致性保证

由于 `aiq0_older_entry_ready` 对 `agevec` 做 AND-OR，数学上最终 `entry_issue_en[7:0]` 只有一位或零位为 1（不可能两位同时为 1），理由：

- 若 entry_i 和 entry_j 同时就绪，必有一个的 agevec 记录了另一个（较老的那个的 `older_entry_ready` 为 1），被屏蔽。
- 特殊情况：两条指令同周期入队（互为同代），agevec 互相不记录对方。此时两者同时 ready 时均无 older_entry 阻止，可能 issue_en 两位为 1。

> C910 的仲裁逻辑在同代指令中有额外处理：每周期最多入队 2 条，一个走 create0（agevec 不含 create1），一个走 create1（agevec 含 create0），所以实际上同代指令入队后 create1 的 agevec 已包含 create0，不会出现两位 issue_en 为 1 的情况。

---

## 8. lch_rdy 模块：RF 阶段发射就绪仲裁

### 8.1 为什么需要 lch_rdy

`dep_reg_entry` 追踪的是写回广播到寄存器文件的就绪（通常在指令执行的最后一个周期）。但在 RF（Register File 读端口）阶段，还有一种更快的前递路径：**当另一个发射队列的某条指令恰好在本周期发射，其结果可以在下一周期通过 ALU 前递直接给等待中的后继指令使用**。

`lch_rdy`（launch ready）模块追踪的是：**"若某发射队列的 entry[j] 本周期发射，其目标寄存器与本 entry 的某个源寄存器是否匹配？"**

这样，当 entry[j] 发射确认时（RF 级），下周期该后继 entry 的对应源操作数可以立即就绪（通过前递），无需等到写回阶段。

### 8.2 三个 lch_rdy 变体

C910 提供三种宽度版本，以适应不同 IQ 的源操作数数量：

| 模块 | 输出宽度 | 用途 |
|------|----------|------|
| `ct_idu_is_aiq_lch_rdy_1` | 1 位 | SDIQ（1 个源） |
| `ct_idu_is_aiq_lch_rdy_2` | 2 位 | BIQ/LSIQ（2 个源） |
| `ct_idu_is_aiq_lch_rdy_3` | 3 位 | AIQ0/AIQ1（3 个源） |

三个模块逻辑完全相同，仅数据位宽由参数 `WIDTH` 控制（1/2/3），是设计的参数化复用。

### 8.3 lch_rdy 内部逻辑

以 `ct_idu_is_aiq_lch_rdy_3.v` 为例（3 位，AIQ 使用）：

```verilog
// 行 67-82：寄存器更新逻辑
assign lch_rdy_create0_en = y_create0_dp_en && x_create_entry[0];
assign lch_rdy_create1_en = y_create1_dp_en && x_create_entry[1];

always @(posedge y_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    lch_rdy[2:0] <= 3'b0;
  else if(x_create_dp_en)           // 当本 entry 入队时，从入队数据初始化
    lch_rdy[2:0] <= x_create_lch_rdy[2:0];
  else if(vld && lch_rdy_create0_en) // 当"被监视的 IQ 的某 entry 入队"时更新
    lch_rdy[2:0] <= y_create0_src_match[2:0];
  else if(vld && lch_rdy_create1_en)
    lch_rdy[2:0] <= y_create1_src_match[2:0];
  else
    lch_rdy[2:0] <= lch_rdy[2:0];
end
```

**读出端口**（组合逻辑，无延迟）：

```verilog
// 行 88-100：支持 write-through 读
always @(...)
begin
  case({lch_rdy_create1_en, lch_rdy_create0_en})
    2'b01  : x_read_lch_rdy = y_create0_src_match; // create0 正在入队，直接输出最新值
    2'b10  : x_read_lch_rdy = y_create1_src_match; // create1 正在入队
    default: x_read_lch_rdy = lch_rdy;             // 稳定状态
  endcase
end
```

**write-through 的意义**：当同一周期有 create_en 时，读端口直接输出组合逻辑结果，不走寄存器，避免多一个周期的延迟，确保 RF 仲裁 level 的信号时序正确。

### 8.4 lch_rdy 在 AIQ0 entry 中的应用

每个 AIQ0_entry 对**所有其他发射队列**（AIQ0 自身 8 entries、AIQ1 8 entries、BIQ 12 entries、LSIQ 12 entries、SDIQ 12 entries）各实例化一套 lch_rdy：

```
AIQ0_entry 中的 lch_rdy 实例：
  - 8 × ct_idu_is_aiq_lch_rdy_3  for AIQ0  (8 entries × 3 src = 24 bits)
  - 8 × ct_idu_is_aiq_lch_rdy_3  for AIQ1  (8 × 3 = 24 bits)
  - 12 × ct_idu_is_aiq_lch_rdy_2 for BIQ   (12 × 2 = 24 bits)
  - 12 × ct_idu_is_aiq_lch_rdy_2 for LSIQ  (12 × 2 = 24 bits)
  - 12 × ct_idu_is_aiq_lch_rdy_1 for SDIQ  (12 × 1 = 12 bits)
```

对应数据格式（参数定义位置 entry 文件行 600-603）：

```verilog
parameter AIQ0_LCH_RDY_SDIQ  = 199;  // bit 199 下方 12 位 → SDIQ
parameter AIQ0_LCH_RDY_LSIQ  = 187;  // bit 187 下方 24 位 → LSIQ
parameter AIQ0_LCH_RDY_BIQ   = 163;  // bit 163 下方 24 位 → BIQ
parameter AIQ0_LCH_RDY_AIQ1  = 127;  // bit 127 下方 24 位 → AIQ1  (← 注意：127+24-1=150)
parameter AIQ0_LCH_RDY_AIQ0  = 103;  // bit 103 下方 24 位 → AIQ0 自身
```

**lch_rdy 的物理意义举例**：

```
AIQ0 entry 中 aiq1_entry3_read_lch_rdy[2:0] 表示：
  bit[0]: AIQ1 的 entry3 一旦发射，其结果能否通过前递满足本 AIQ0 entry 的 src0
  bit[1]: 同上，是否满足 src1
  bit[2]: 同上，是否满足 src2
```

这些信息由顶层 `ct_idu_is_aiq0` 在 RF 阶段判断时使用，决定哪个 entry 的哪些源操作数可以通过 ALU forward 获得。

### 8.5 src_match 如何计算

每个 AIQ entry 内部计算"当前队列中入队指令的目标寄存器与本 entry 源寄存器的匹配情况"：

```verilog
// ct_idu_is_aiq0_entry.v，行 1259-1270
// 计算本 entry 目标寄存器是否匹配各派遣指令的源寄存器
assign dis_inst0_src_match[0] = (dst_preg[6:0] == dp_aiq_dis_inst0_src0_preg[6:0]);
assign dis_inst0_src_match[1] = (dst_preg[6:0] == dp_aiq_dis_inst0_src1_preg[6:0]);
assign dis_inst0_src_match[2] = (dst_preg[6:0] == dp_aiq_dis_inst0_src2_preg[6:0]);
...
```

然后根据 `ctrl_dp_is_dis_aiq0_create0_sel[1:0]`（2 位选择器）选出派遣到 AIQ0 create0 槽的那条指令的匹配结果，作为 `lch_rdy_aiq0_create0_src_match[2:0]`，传递给所有 lch_rdy 实例的 `y_create0_src_match` 输入：

```verilog
// ct_idu_is_aiq0_entry.v，行 1282-1290
case(ctrl_dp_is_dis_aiq0_create0_sel[1:0])
  2'd0: lch_rdy_aiq0_create0_src_match = dis_inst0_src_match;
  2'd1: lch_rdy_aiq0_create0_src_match = dis_inst1_src_match;
  2'd2: lch_rdy_aiq0_create0_src_match = dis_inst2_src_match;
  2'd3: lch_rdy_aiq0_create0_src_match = dis_inst3_src_match;
endcase
```

这样，一旦某条指令被派遣到 AIQ0 create0 槽，所有已在队列中等待的 entry 会在同一周期更新其对应的 lch_rdy 寄存器，记录"若该新入队指令未来被发射，本 entry 的哪些源操作数可以通过前递就绪"。

---

## 9. 发射后的处理

### 9.1 Freeze 机制

指令从队列中被选中发射（issue_en 有效）但 RF 读端口还未确认时，置 `frz=1`，防止该 entry 在下一周期再次参与仲裁：

```verilog
// ct_idu_is_aiq0_entry.v，行 893-905
always @(posedge entry_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    frz <= 1'b0;
  else if(x_create_en)   // 入队时清除
    frz <= x_create_frz; // 注：bypass 时 create_frz=1（已 bypass 就绪，不需再发射）
  else if(x_issue_en)    // 被选中发射时冻结
    frz <= 1'b1;
  else if(x_frz_clr)     // 发射失败（load miss等）时解冻
    frz <= 1'b0;
end
```

`x_create_frz` 对于 bypass 指令为 1，即入队时就冻结（实际走 bypass 路径直接发射，但为了安全起见，若 bypass 条件不成立导致还是入队，则需冻结直至被弹出）。

### 9.2 Entry 弹出（Pop）

发射成功后（RF 阶段 `ctrl_aiq0_rf_pop_vld=1`），弹出对应 entry：

```verilog
// ct_idu_is_aiq0_entry.v，行 875-887
always @(posedge entry_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    vld <= 1'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is)
    vld <= 1'b0;
  else if(x_create_en)
    vld <= 1'b1;
  else if(ctrl_aiq0_rf_pop_vld && x_pop_cur_entry) // pop_cur_entry 是本 entry 的 one-hot bit
    vld <= 1'b0;
end
```

`x_pop_cur_entry` 来自 `dp_aiq0_rf_lch_entry[N]`，即该 entry 的 index 位。

### 9.3 pop 信号的分解

顶层通过位拼接的方式，将 8 位 one-hot `dp_aiq0_rf_lch_entry[7:0]` 分解给每个 entry：

```verilog
// ct_idu_is_aiq0.v，行 1188-1209
assign {aiq0_entry0_pop_other_entry[6:0], aiq0_entry0_pop_cur_entry}
         = dp_aiq0_rf_lch_entry[7:0];
// entry0 的 pop_cur_entry = bit[0]，pop_other_entry = bit[7:1]

assign {aiq0_entry1_pop_other_entry[6:1], aiq0_entry1_pop_cur_entry,
        aiq0_entry1_pop_other_entry[0]} = dp_aiq0_rf_lch_entry[7:0];
// entry1 的 pop_cur_entry = bit[1]，pop_other_entry = {bit[7:2], bit[0]}
...
```

每个 entry 使用 `pop_other_entry` 更新自己的 agevec（清除已弹出的比自己更老的 entry 记录）：

```verilog
// ct_idu_is_aiq0_entry.v，行 917-920
else if(ctrl_aiq0_rf_pop_vld)
    agevec[6:0] <= agevec[6:0] & ~x_pop_other_entry[6:0];
```

---

## 10. Entry 数据格式

### 10.1 AIQ0 数据字段布局（227 位）

```verilog
// ct_idu_is_aiq0_entry.v，行 580-635
parameter AIQ0_WIDTH    = 227;

// 位域定义（从高到低）
//  [226:200]  AIQ0_VL        [7:0]   + padding    向量长度
//  [205]      AIQ0_LCH_PREG          发射级前递标记
//  [204:202]  AIQ0_VSEW              向量元素宽度
//  [201:200]  AIQ0_VLMUL             向量乘法器设置
//  [199:188]  AIQ0_LCH_RDY_SDIQ     SDIQ 12 entries lch_rdy
//  [187:164]  AIQ0_LCH_RDY_LSIQ     LSIQ 12 entries × 2 src
//  [175:152]  AIQ0_LCH_RDY_BIQ      BIQ  12 entries × 2 src
//  [151:128]  AIQ0_LCH_RDY_AIQ1     AIQ1 8 entries × 3 src
//  [127:104]  AIQ0_LCH_RDY_AIQ0     AIQ0 8 entries × 3 src
//  [103]      AIQ0_ALU_SHORT         短整数 ALU 指令
//  [102:98]   AIQ0_PID               PC FIFO 项 ID
//  [97]       AIQ0_PCFIFO            需要记录 PC
//  [96]       AIQ0_MTVR              向量到整数移动
//  [95]       AIQ0_DIV               除法指令标记
//  [94]       AIQ0_HIGH_HW_EXPT      上半字异常
//  [93:89]    AIQ0_EXPT_VEC          异常向量
//  [88]       AIQ0_EXPT_VLD          异常有效
//  [87]       AIQ0_SRC2_LSU_MATCH    src2 LSU 匹配标记
//  [86:79]    AIQ0_SRC2_DATA/PREG    src2 物理寄存器号 [7:1]
//  [79]       AIQ0_SRC2_WB           src2 来自写回
//  [78]       AIQ0_SRC2_RDY          src2 就绪（只读时输出，写入时为 0）
//  [77]       AIQ0_SRC1_LSU_MATCH
//  [76:69]    AIQ0_SRC1_DATA/PREG    src1 物理寄存器号
//  [69]       AIQ0_SRC1_WB
//  [68]       AIQ0_SRC1_RDY
//  [67]       AIQ0_SRC0_LSU_MATCH
//  [66:59]    AIQ0_SRC0_DATA/PREG    src0 物理寄存器号
//  [59]       AIQ0_SRC0_WB
//  [58]       AIQ0_SRC0_RDY
//  [57:51]    AIQ0_DST_VREG          目标向量寄存器
//  [50:44]    AIQ0_DST_PREG          目标物理寄存器
//  [43]       AIQ0_DSTV_VLD          目标向量寄存器有效
//  [42]       AIQ0_DST_VLD           目标物理寄存器有效
//  [41]       AIQ0_SRC2_VLD          src2 有效
//  [40]       AIQ0_SRC1_VLD          src1 有效
//  [39]       AIQ0_SRC0_VLD          src0 有效
//  [38:32]    AIQ0_IID               指令 ID（7 位，用于 flush 比较）
//  [31:0]     AIQ0_OPCODE            32 位操作码
```

### 10.2 主要字段说明表

| 字段 | 宽度 | 说明 |
|------|------|------|
| `opcode` | 32 | 指令操作码，发射时送到执行单元 |
| `iid` | 7 | 指令 ID，用于精确 flush 时的年龄比较 |
| `src{0/1/2}_vld` | 1 | 该源操作数是否存在 |
| `src{0/1/2}_preg` | 7 | 物理寄存器编号（依赖追踪用） |
| `dst_vld/dst_preg` | 1/7 | 目标寄存器（整数），用于唤醒后续指令 |
| `dstv_vld/dst_vreg` | 1/7 | 目标向量寄存器 |
| `div` | 1 | 除法指令标记（就绪判断额外检查 div_busy） |
| `mtvr` | 1 | 向量到整数移动（MTVR） |
| `pcfifo/pid` | 1/5 | 指令需要写 PC FIFO，及对应 FIFO 项 ID |
| `alu_short` | 1 | 短 ALU 指令（1 周期，可支持更积极前递） |
| `special` | 1 | 特殊指令（CSR 操作、系统调用等） |
| `lch_preg` | 1 | 依赖 RF 级前递 |
| `expt_vld/vec` | 1/5 | 指令携带异常信息 |
| `vlmul/vsew/vl` | 2/3/8 | 向量配置参数（LMUL、SEW、VL） |
| `lch_rdy_*` | 变 | 各 IQ entry 的 lch_rdy 位图 |

### 10.3 门控时钟分区

为节约功耗，entry 数据按字段特性分组到不同门控时钟域：

```verilog
// ct_idu_is_aiq0_entry.v，行 659-752
assign create_clk_en    = x_create_gateclk_en;         // 通用 create 域
assign create_pcfifo_clk_en = x_create_gateclk_en && x_create_data[AIQ0_PCFIFO];  // 只有 pcfifo 指令
assign create_preg_clk_en   = x_create_gateclk_en && x_create_data[AIQ0_DST_VLD]; // 只有有目标寄存器
assign create_vreg_clk_en   = x_create_gateclk_en && x_create_data[AIQ0_DSTV_VLD];// 只有向量目标
assign create_other_clk_en  = x_create_gateclk_en && x_create_data[AIQ0_EXPT_VLD];// 只有有异常
```

这样，当入队的是简单整数指令（无异常、无向量），异常相关寄存器不翻转，节约动态功耗。

---

## 11. AIQ1 与 AIQ0 的差异

AIQ1 与 AIQ0 结构高度相似，主要差异如下：

### 11.1 数据位宽差异

```
AIQ0_WIDTH = 227 位
AIQ1_WIDTH = 214 位（少了 13 位）
```

差异来源：

| 字段 | AIQ0 | AIQ1 | 说明 |
|------|------|------|------|
| `div` | 有（1 bit） | 无 | 除法只走 Pipe0 |
| `high_hw_expt` | 有（1 bit） | 无 | 上半字异常只在 Pipe0 处理 |
| `expt_vec/vld` | 有（6 bits） | 无 | 异常处理只在 Pipe0 |
| `pcfifo/pid` | 有（6 bits） | 无 | PC FIFO 只在 Pipe0 维护 |
| `mla` | 无 | 有（1 bit） | MLA（乘累加）指令标记 |
| `special` | 有 | 无 | 特殊指令（CSR/TLB）只走 Pipe0 |

因此 AIQ1 entry 少了约 14 位固有字段，但增加了 MLA 字段，净减少约 13 位。

### 11.2 就绪判断差异

AIQ1 entry 的 `x_rdy` 额外检查乘法器管线停顿：

```verilog
// ct_idu_is_aiq1_entry.v，行 2572
&& !(lch_preg && iu_idu_ex1_pipe1_mult_stall)
```

AIQ0 没有此条件，但有除法器忙判断：

```verilog
// ct_idu_is_aiq0_entry.v，行 2660
&& !(x_read_data[AIQ0_DIV] && iu_idu_div_busy)
```

### 11.3 ALU 前递有效信号

AIQ0 顶层从 `ctrl_aiq0_rf_pipe0_alu_reg_fwd_vld[23:0]`（24 位 = 8 entries × 3 src）分发给各 entry 的 `alu0_reg_fwd_vld[2:0]`。AIQ1 也有同样机制，接收 `ctrl_aiq1_rf_pipe0/pipe1_alu_reg_fwd_vld`。

### 11.4 乘法相关新增信号

AIQ1 顶层增加了：
- `ctrl_aiq1_rf_pipe1_mla_reg_lch_vld`：MLA（乘累加）前递有效
- `dp_aiq1_create_alu`：创建 ALU 指令（区分于乘法）
- `iu_idu_ex1_pipe1_mult_stall`：乘法器停顿
- `ctrl_aiq1_rf_pop_dlb_vld`：动态负载均衡弹出

AIQ1 entry 新增 `mla` 字段，在发射数据中标记该指令是乘累加类型，供执行单元使用。

---

## 12. Flush 时的队列清理

### 12.1 两级 flush

C910 支持两种冲刷粒度：

| 信号 | 语义 | 动作 |
|------|------|------|
| `rtu_idu_flush_fe` | 前端冲刷（分支预测错误等） | 所有 entry 清零 |
| `rtu_idu_flush_is` | 发射队列冲刷 | 所有 entry 清零 |
| `rtu_yy_xx_flush` | 全局冲刷 | entry_cnt 复位（防止计数器错误） |

entry 的 vld 寄存器对 flush_fe 和 flush_is 均响应：

```verilog
// ct_idu_is_aiq0_entry.v，行 879
else if(rtu_idu_flush_fe || rtu_idu_flush_is)
    vld <= 1'b0;
```

### 12.2 entry_cnt 的 flush 处理

```verilog
// ct_idu_is_aiq0.v，行 583-593
always @(posedge cnt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    aiq0_entry_cnt[3:0] <= 4'b0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush)
    aiq0_entry_cnt[3:0] <= 4'b0;
  ...
end
```

注释说明（行 586-587）：flush_fe 之后、rtu_yy_xx_flush 之前，RF 阶段可能有"错误的 pop"发生，因此需要 `rtu_yy_xx_flush` 也复位计数器，防止计数器出错。

### 12.3 IID 年龄比较与精确 flush

每个 entry 保存 `iid[6:0]`（7 位指令 ID）。在精确例外/分支预测错误恢复时，RTU 可以通过比较 IID 来判断哪些指令需要被冲刷（IID 晚于回滚点的均需清除）。AIQ 的 vld 在 flush 时无条件清零，不做 IID 比较——这是因为 C910 的 flush 是"全队列清空"级别，更细粒度的保留由 ROB 和重命名表恢复来实现，IID 字段主要用于调试追踪和异常精确化。

### 12.4 lch_rdy 在 flush 时的行为

lch_rdy 寄存器的复位条件也是 `cpurst_b`（全局复位），没有单独针对 flush 的清除逻辑。当 flush 导致 entry 的 `vld` 被清零后，entry 的 `x_rdy` 自动为 0（因为 `vld` 是就绪的前提），lch_rdy 的历史值对发射逻辑无影响。下次该 entry 被重新分配（`x_create_dp_en` 有效），lch_rdy 会被 `x_create_lch_rdy` 重新初始化。

---

## 13. 完整数据流与时序图

### 13.1 正常发射流程（无 bypass）

```
Cycle N:    Dispatch 派遣
            ├─ ctrl 层确定 create0/create1_en
            ├─ 顶层选 create0_in（e0→e7 优先）、create1_in（e7→e0 优先）
            ├─ 计算 agevec（含当前已有 entry 位图）
            └─ 各 entry create_en 选中者写入 vld=1、agevec、opcode、iid、preg 等

Cycle N+1:  dep_reg_entry 开始监听写回广播
            lch_rdy 记录与同期派遣指令的依赖关系

Cycle N+k:  当某写回通路命中该 entry 的依赖 preg → src_rdy_for_issue = 1
            当三个 src 均就绪且无 stall/frz → entry.x_rdy = 1

Cycle M:    发射仲裁
            ├─ aiq0_entry_ready[7:0] = {entry7.rdy, ..., entry0.rdy}
            ├─ older_entry_ready[i] = |(entry_i.agevec & entry_ready)
            ├─ entry_issue_en[i] = entry_i.rdy & ~older_entry_ready[i]
            └─ 结果：至多一位 entry_issue_en 为 1

Cycle M:    发射
            ├─ entry.frz 置 1
            ├─ aiq0_dp_issue_entry 和 aiq0_dp_issue_read_data 输出给下游 RF
            └─ RF 读操作数

Cycle M+1:  RF 确认（ctrl_aiq0_rf_pop_vld）
            ├─ entry.vld 清零（弹出）
            └─ 其他 entry 的 agevec 更新（清除已弹出项）

如果 RF 阶段 lch miss：
            ctrl_aiq0_rf_lch_fail_vld = 1
            entry.frz 清零（x_frz_clr 有效）
            dp_aiq0_rf_rdy_clr 按位清除对应 src_rdy
            → 指令重回等待状态
```

### 13.2 Bypass 发射流程

```
Cycle N:    Dispatch
            条件：队列完全为空（vld_with_frz 全为 0）
                  且 create0 的三个源全部就绪
            ├─ aiq0_bypass_en = 1
            ├─ entry 照常写入（vld=1，frz=1 因为 create_frz=aiq0_bypass_dp_en=1）
            └─ aiq0_dp_issue_read_data = dp_aiq0_bypass_data（直接走 bypass 数据）

Cycle N:    同一周期发射
            └─ 后续 RF、pop 流程同正常发射
```

---

## 14. 关键设计总结

### 14.1 唤醒-选择机制全貌

```
                入队时                     队列驻留期间
                  │                            │
            init agevec               监听写回广播（dep_reg_entry）
            init lch_rdy              监听新入队指令（lch_rdy 更新）
            vld = 1                    src_rdy 状态持续更新
                                              │
                               当 src0 & src1 & src2 全 rdy:
                                       x_rdy = 1
                                              │
                              仲裁：older_entry_ready 矩阵
                               └─ 最老的 rdy entry → issue_en
                                              │
                                     发射：frz=1，送 RF
                                              │
                              RF 确认 → pop（弹出），agevec 更新
                              RF 失败 → frz=0，src_rdy 清除，重新等待
```

### 14.2 性能设计特点

| 特性 | 设计选择 | 原因 |
|------|----------|------|
| 选择策略 | 年龄优先（Age-based） | 防止饥饿，保持程序顺序合理性 |
| 双通道入队 | 反向扫描分离 | 避免写冲突，最大化吞吐 |
| Bypass | 队列空时直接发射 | 减少 1 周期延迟 |
| 推测唤醒 | Load 在 AG 段即唤醒 | 减少 load-use 延迟 |
| write-through lch_rdy | 入队周期即刻可读 | 减少 lch_rdy 建立延迟 |
| 门控时钟分域 | 按字段特性分 5 个时钟域 | 降低动态功耗 |
| `_dupx` 信号 | 写回总线信号复制 | 降低扇出，满足时序 |
| `gateclk_en` 分离 | 控制路径与数据路径分开 | 门控时钟使能提前准备，不影响功能正确性 |

---

*本文档对应 C910 RTL 版本：T-Head 公开发布版（Apache 2.0 License）*
*参考文件：`ct_idu_is_aiq0.v`、`ct_idu_is_aiq0_entry.v`、`ct_idu_is_aiq_lch_rdy_{1/2/3}.v`*
