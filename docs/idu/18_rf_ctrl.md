# C910 IDU RF_CTRL 模块详解

> **RTL 文件**：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_ctrl.v`（1615 行）
> **模块名称**：`ct_idu_rf_ctrl`

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [时钟门控架构](#3-时钟门控架构)
4. [RF 指令有效寄存器（RF Inst Valid）](#4-rf-指令有效寄存器rf-inst-valid)
5. [RF 发射就绪寄存器（Launch Ready / ALU Fwd Vld）](#5-rf-发射就绪寄存器launch-ready--alu-fwd-vld)
6. [前递就绪控制（核心）](#6-前递就绪控制核心)
7. [发射暂停（RF Stall）](#7-发射暂停rf-stall)
8. [发射失败（Launch Fail）](#8-发射失败launch-fail)
9. [RF 流水推进与执行单元选择](#9-rf-流水推进与执行单元选择)
10. [性能监控计数器（HPCP）](#10-性能监控计数器hpcp)
11. [与相邻子模块的协调](#11-与相邻子模块的协调)
12. [典型时序场景](#12-典型时序场景)
13. [小结](#13-小结)

---

## 1. 模块概述

### 1.1 RF 阶段在 IDU 流水线中的位置

C910 IDU 采用四级流水：

```
  ┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐
  │ ID  │ -> │ IR  │ -> │ IS  │ -> │ RF  │ -> 执行单元
  └─────┘    └─────┘    └─────┘    └─────┘
  取指解码   重命名/     发射队列   读物理       ALU / MULT /
             空闲表      仲裁调度   寄存器       DIV / BJU /
                                   前递判决      LSU / VFPU
```

- **RF 阶段**（寄存器读取阶段）是 IDU 的最后一级。
- 指令从各发射队列（AIQ0/AIQ1/BIQ/LSIQ/SDIQ/VIQ0/VIQ1）的 IS 级 **issue（发射）** 后，在 RF 时钟沿存入 rf_pipeN_inst_vld 寄存器，进入 RF 阶段。
- RF 阶段完成：读物理寄存器文件（PRF）、执行前递选择、判断源操作数是否就绪、最终向执行单元输出数据路径使能（`_sel`）和门控时钟使能（`_gateclk_sel`）信号。

### 1.2 rf_ctrl 的职责

`ct_idu_rf_ctrl` 是 RF 阶段的**纯控制平面**，负责：

| 职责 | 关键信号 |
|------|---------|
| 维护各管线指令有效寄存器 | `rf_pipe0~7_inst_vld` |
| 维护 ALU 短延迟前递就绪向量 | `rf_pipe0/1_alu_reg_fwd_vld[107:0]` |
| 维护 MLA 以及保留的 VMLA 前递就绪向量 | `rf_pipe1_mla_fwd_vld`, `rf_pipe6/7_vmla_vreg_fwd_vld` |
| 计算 RF 阶段暂停条件 | `ctrl_aiq0/1_stall`, `ctrl_viq0/1_stall` |
| 计算发射失败条件（lch fail） | `ctrl_aiqN_rf_lch_fail_vld` 等 |
| 向执行单元输出使能 | `idu_iu_rf_pipe0_sel` 等 |
| 向上游 IQ 反馈弹出或冻结 | `ctrl_aiq0_rf_pop_vld` 等 |
| 性能监控采样 | `idu_hpcp_rf_*` |

数据路径（PRF 读端口多路选择、操作数前递 MUX）由 `ct_idu_rf_dp` 完成；rf_ctrl 仅产生驱动这些 MUX 的控制位。

> **当前配置边界**：pipe6/7 连接 VFPU，并承担当前有效的标量浮点 F/D 指令；同一 VIQ/RF 结构还保留 VMLA、VDIV、VMUL、MFVR/MTVR 和 VREG 接口，但当前 `x_vec_inst=0`、`misa_vector=0`，这些 RVV 专用条件不会由正常有效译码产生。下文保留其 RTL 逻辑说明，但不把它们当作当前程序必然可观测的事件。

### 1.3 八条执行管线

```
管线 | 发射队列 | 执行单元          | 延迟特征
-----|---------|-------------------|----------
pipe0| AIQ0    | ALU/DIV/CSR/Special | 短 ALU 与长周期 DIV 并存
pipe1| AIQ1    | ALU/MULT          | 短 ALU 与多级 MULT 并存
pipe2| BIQ     | BJU               | 分支执行路径
pipe3| LSIQ    | LSU Load          | 多拍（cache miss 可能更长）
pipe4| LSIQ    | LSU Store Addr    | 多拍
pipe5| SDIQ    | LSU Store Data    | 多拍
pipe6| VIQ0    | VFPU              | VFPU 多拍；VDIV 可变
pipe7| VIQ1    | VFPU              | VFPU 多拍
```

---

## 2. 端口说明

### 2.1 输入：发射队列 issue 信号

| 端口 | 方向 | 含义 |
|------|------|------|
| `aiq0_xx_issue_en` | in | AIQ0 在当前周期发射一条指令 |
| `aiq0_xx_gateclk_issue_en` | in | AIQ0 提供的 RF 局部时钟活动请求；通常比最终 issue 少检查 ready/年龄仲裁条件，但没有固定“早一拍”关系 |
| `aiq1_xx_issue_en` | in | AIQ1 发射使能 |
| `biq_xx_issue_en` | in | BIQ（分支队列）发射使能 |
| `lsiq_xx_pipe3_issue_en` | in | LSIQ 向 pipe3（Load）发射 |
| `lsiq_xx_pipe4_issue_en` | in | LSIQ 向 pipe4（Store Addr）发射 |
| `sdiq_xx_issue_en` | in | SDIQ（Store Data 队列）发射使能 |
| `viq0_xx_issue_en` | in | VIQ0 发射使能 |
| `viq1_xx_issue_en` | in | VIQ1 发射使能 |

> **为什么有独立的 `gateclk_issue_en`？**  
> 各 IQ 的该信号通常由“存在非冻结有效项”或更宽松的 bypass gateclk 条件生成，不依赖完整的源 ready
> 与 oldest-ready 仲裁；`issue_en` 才表示最终存在可发射项。这样局部时钟请求不必经过完整发射判定路径，
> 但两者可能同周期有效，前者也可能在指令等待操作数的多个周期保持有效。RTL 没有规定固定提前半拍或一拍，
> 具体 ICG 建立时间和路径裕量必须由 STA 验证。

### 2.2 输入：IS 级数据路径辅助控制（dp_ctrl_is_*）

| 端口 | 宽度 | 含义 |
|------|------|------|
| `dp_ctrl_is_aiq0_issue_lch_preg` | 1 | AIQ0 发射指令需要写回物理寄存器（有目标寄存器） |
| `dp_ctrl_is_aiq0_issue_dst_vld` | 1 | 目标有效（dst 存在） |
| `dp_ctrl_is_aiq0_issue_alu_short` | 1 | AIQ0 当前指令是短延迟 ALU 指令（1 拍出结果） |
| `dp_ctrl_is_aiq0_issue_special` | 1 | 特殊指令（CSR/Fence 等，需要 EX1 完成端口） |
| `dp_ctrl_is_aiq0_issue_div` | 1 | 除法指令 |
| `dp_ctrl_is_aiq0_issue_lch_rdy[107:0]` | 108 | pipe0 待解锁的等待队列位向量（哪些等待 pipe0 结果的指令可以解锁） |
| `dp_ctrl_is_aiq1_issue_mla_vld` | 1 | AIQ1 发射的 MLA（乘加）指令有效 |
| `dp_ctrl_is_aiq1_issue_mla_lch_rdy[7:0]` | 8 | MLA 前递可解锁位向量 |
| `dp_ctrl_is_viq0_issue_vmla_rf` | 1 | VIQ0 VMLA 指令需要 RF 阶段处理 |
| `dp_ctrl_is_viq0_issue_vmla_short` | 1 | VIQ0 VMLA 是短延迟变体 |
| `dp_ctrl_is_viq0_issue_lch_rdy[15:0]` | 16 | VMLA 前递可解锁位向量 |
| `dp_ctrl_is_viq0_issue_vdiv` | 1 | 向量除法指令 |

### 2.3 输入：RF 级数据路径反馈（dp_ctrl_rf_*）

| 端口 | 含义 |
|------|------|
| `dp_ctrl_rf_pipe0_src_no_rdy` | pipe0 RF 级仍有源操作数未就绪（lch fail 原因之一） |
| `dp_ctrl_rf_pipe0_src2_vld` | pipe0 使用了 src2（第二物理寄存器读端口） |
| `dp_ctrl_rf_pipe0_mtvr` | pipe0 为 MTVR 指令（GPR→VR 数据转移，与 VFPU 共享端口） |
| `dp_ctrl_rf_pipe0_eu_sel[3:0]` | pipe0 的执行单元选择编码 |
| `dp_ctrl_rf_pipe1_eu_sel[1:0]` | pipe1 执行单元选择编码 |
| `dp_ctrl_rf_pipe3_src1_vld` | pipe3（Load）使用 src1 物理寄存器读端口 |
| `dp_ctrl_rf_pipe3_srcvm_vld` | pipe3 使用向量 srcvm 读端口 |
| `dp_ctrl_rf_pipe4_srcvm_vld` | pipe4 使用向量 srcvm 读端口 |
| `dp_ctrl_rf_pipe4_staddr` | pipe4 是 Store Addr 指令（影响 SDIQ staddr_rdy_set） |
| `dp_ctrl_rf_pipe5_src0_vld` | pipe5 使用 src0（整数）读端口 |
| `dp_ctrl_rf_pipe6_mfvr` | pipe6 是 MFVR 指令（VR→GPR 数据转移） |
| `dp_ctrl_rf_pipe6_srcv2_vld` | pipe6 使用向量 srcv2 读端口 |
| `dp_ctrl_rf_pipe6_vmul` | pipe6 是向量乘法指令 |
| `dp_ctrl_rf_pipe7_vmul_unsplit` | pipe7 是未拆分的向量乘法（需独占 pipe6 资源） |

### 2.4 输入：执行单元反馈

| 端口 | 含义 |
|------|------|
| `iu_idu_div_wb_stall` | IU 整数除法写回暂停（除法结果总线占用中） |
| `iu_idu_ex1_pipe1_mult_stall` | IU pipe1 EX1 级乘法暂停（乘法结果总线占用） |
| `vfpu_idu_vdiv_wb_stall` | VFPU 向量除法写回暂停 |

### 2.5 输入：冲刷信号

| 端口 | 含义 |
|------|------|
| `rtu_idu_flush_fe` | RTU 发出前端冲刷（更激进，清除 RF 指令有效） |
| `rtu_idu_flush_is` | RTU 发出 IS 级冲刷（同样清除 RF 指令有效） |
| `rtu_yy_xx_flush` | 全局冲刷（pipe5 Store Data 特殊处理使用） |

### 2.6 输出：主要控制信号

| 端口组 | 含义 |
|--------|------|
| `ctrl_aiqN_rf_lch_fail_vld` | 通知 AIQ/BIQ/LSIQ/SDIQ/VIQ：发射失败，请冻结当前项并重调度 |
| `ctrl_aiqN_rf_pop_vld` | 通知 IQ：发射成功，弹出队列表项 |
| `ctrl_aiqN_rf_pop_dlb_vld` | 向 IR 的 DLB（Dynamic Load Balance）占用估计反馈 RF-stage valid；它不是某个“延迟发射缓冲区”的功能性 pop |
| `ctrl_aiqN_stall` | 发射暂停：阻止 IS 级向 RF 送出新指令 |
| `ctrl_aiq0_rf_pipe0_alu_reg_fwd_vld[23:0]` | AIQ0 等待 pipe0 ALU 结果的前递就绪位（给 AIQ0 用） |
| `ctrl_aiq1_rf_pipe0_alu_reg_fwd_vld[23:0]` | 同上，给 AIQ1 用 |
| `ctrl_biq_rf_pipe0_alu_reg_fwd_vld[23:0]` | 同上，给 BIQ 用 |
| `ctrl_lsiq_rf_pipe0_alu_reg_fwd_vld[23:0]` | 同上，给 LSIQ 用 |
| `ctrl_sdiq_rf_pipe0_alu_reg_fwd_vld[11:0]` | 同上，给 SDIQ 用（12位，SDIQ 较小） |
| `ctrl_xx_rf_pipe0_preg_lch_vld_dup0~4` | pipe0 物理寄存器发射有效（5 份拷贝，供 fwd 模块广播） |
| `ctrl_xx_rf_pipe1_preg_lch_vld_dup0~4` | pipe1 同上 |
| `ctrl_xx_rf_pipe6/7_vmla_lch_vld_dup0~3` | VMLA 发射有效（4 份拷贝） |
| `idu_iu_rf_pipe0_sel` | 通知 IU：pipe0 RF 阶段推进有效，准备接收指令数据 |
| `idu_iu_rf_mult_sel` | 通知 IU MULT：pipe1 RF 推进有效 |
| `idu_iu_rf_bju_sel` | 通知 IU BJU：pipe2 RF 推进有效 |
| `idu_lsu_rf_pipe3_sel` | 通知 LSU：pipe3 RF 推进有效 |
| `idu_vfpu_rf_pipe6_sel` | 通知 VFPU：pipe6 RF 推进有效 |
| `ctrl_sdiq_rf_staddr_rdy_set` | 通知 SDIQ：Store Addr 已执行，可以为 Store Data 设置就绪 |

---

## 3. 时钟门控架构

rf_ctrl 中实例化 5 个门控时钟单元，为不同 RF 控制寄存器提供局部更新时钟。公共
`gated_clk_cell` 的功能使能为 `global_en && (module_en || local_en)`，不是把 module/local 串联；
扫描使能还连接工艺 ICG 的测试使能端。未定义 `C910_USE_TSMC28_ICG` 时，当前 RTL 模型直接
`clk_out = clk_in`。因此 `local_en` 只表示局部请求，实际门控和功耗收益需由所用宏、综合网表及功耗分析量化。

```verilog
// 行 748-749：pipe0 专用门控
assign rf_inst0_clk_en = aiq0_xx_gateclk_issue_en || rf_pipe0_inst_vld;

// 行 768-769：pipe1 专用门控
assign rf_inst1_clk_en = aiq1_xx_gateclk_issue_en || rf_pipe1_inst_vld;

// 行 788-789：pipe6 专用门控
assign rf_inst6_clk_en = viq0_xx_gateclk_issue_en || rf_pipe6_inst_vld;

// 行 808-809：pipe7 专用门控
assign rf_inst7_clk_en = viq1_xx_gateclk_issue_en || rf_pipe7_inst_vld;

// 行 719-729：pipe2~7 共用通用门控
assign rf_inst_clk_en  = biq_xx_gateclk_issue_en || lsiq_xx_gateclk_issue_en
                       || sdiq_xx_gateclk_issue_en || viq0_xx_gateclk_issue_en
                       || viq1_xx_gateclk_issue_en
                       || rf_pipe2_inst_vld || rf_pipe3_inst_vld
                       || rf_pipe4_inst_vld || rf_pipe5_inst_vld
                       || rf_pipe6_inst_vld || rf_pipe7_inst_vld;
```

**设计原理**：

- pipe0 和 pipe1 各有独立控制时钟请求，所驱动状态除 `inst_vld` 外还包括 ALU 前递位图等；这减少它们与通用控制时钟的活动耦合。实际功耗收益由实现结果决定。
- pipe6/7 也各有独立请求，用于各自的 `inst_vld` 和 VMLA 相关控制状态。
- `rf_inst_clk` 驱动 pipe2/3/4/5 的 `inst_vld`，同时其局部请求方程还包含 pipe6/7 的 gateclk issue 和现存 valid；不能把它概括为“只服务四个一位寄存器”。
- `gateclk_issue_en` 绕开最终 ready/仲裁条件，提供更宽松的活动请求；它不是 RTL 定义的固定提前半拍到一拍信号。

---

## 4. RF 指令有效寄存器（RF Inst Valid）

### 4.1 总体机制

每个管线有一个 `rf_pipeN_inst_vld` 寄存器，记录该管线在 RF 级是否存在有效指令。该寄存器的**置位/清除**逻辑是整个 rf_ctrl 的基础骨架。

通用公式（以 pipe0 为例）：

```
rf_pipe0_inst_vld <= 0        (复位或 flush)
rf_pipe0_inst_vld <= aiq0_xx_issue_en  (正常情况)
```

即：**每个时钟沿，直接用当前 IS 级的 issue_en 更新 RF 级 inst_vld**，无需手动置位/清除逻辑——因为如果 IS 级没有发射，下一周期 RF 就自然为空。

### 4.2 各管线逐一分析

#### 4.2.1 Pipe0（AIQ0 → ALU/DIV/CSR/Special）

```verilog
// 行 836-860
assign aiq0_issue_alu_reg_vld = aiq0_xx_issue_en && dp_ctrl_is_aiq0_issue_lch_preg;
assign aiq0_issue_special_vld = aiq0_xx_issue_en && dp_ctrl_is_aiq0_issue_special;
assign idu_iu_is_div_issue    = aiq0_xx_issue_en && dp_ctrl_is_aiq0_issue_div;

always @(posedge rf_inst0_clk or negedge cpurst_b)
begin
  if(!cpurst_b)                          { rf_pipe0_inst_vld, rf_pipe0_preg_lch_vld, rf_pipe0_special_vld } <= 0;
  else if(rtu_idu_flush_fe || rtu_idu_flush_is)
                                         { rf_pipe0_inst_vld, rf_pipe0_preg_lch_vld, rf_pipe0_special_vld } <= 0;
  else begin
    rf_pipe0_inst_vld          <= aiq0_xx_issue_en;
    rf_pipe0_preg_lch_vld[4:0] <= {5{aiq0_issue_alu_reg_vld}};
    rf_pipe0_special_vld       <= aiq0_issue_special_vld;
  end
end
```

- `rf_pipe0_inst_vld`：标记 RF 阶段 pipe0 槽有指令。
- `rf_pipe0_preg_lch_vld[4:0]`：**5 份冗余拷贝**，标记 pipe0 的指令是否会写回物理寄存器（即是否需要向等待者广播前递就绪）。5 份拷贝是为了向 5 个不同接收方（rf_fwd_preg 等模块）分散负载，避免高扇出时序违例。
- `rf_pipe0_special_vld`：标记特殊指令（如 CSR write），决定是否需要阻塞后续 AIQ0 发射（special 指令需要独占 EX1 完成端口）。

**冲刷策略**：`flush_fe` 和 `flush_is` 都会清除 RF 的指令有效位。这是因为冲刷是精确异常/分支预测失误时的操作，RF 中的指令此时都是错误路径上的指令，必须废弃。

#### 4.2.2 Pipe1（AIQ1 → ALU/MULT）

```verilog
// 行 873-897
assign aiq1_issue_alu_reg_vld = aiq1_xx_issue_en && dp_ctrl_is_aiq1_issue_lch_preg;

always @(posedge rf_inst1_clk or negedge cpurst_b)
begin
  ...
  rf_pipe1_inst_vld          <= aiq1_xx_issue_en;
  rf_pipe1_preg_lch_vld[4:0] <= {5{aiq1_issue_alu_reg_vld}};
end
```

与 pipe0 类似，但 pipe1 没有 `special_vld`（特殊指令只走 pipe0）。

#### 4.2.3 Pipe2（BIQ → BJU）

```verilog
// 行 902-912
always @(posedge rf_inst_clk or negedge cpurst_b)
begin
  ...
  rf_pipe2_inst_vld <= biq_xx_issue_en;
end
```

最简单的管线：只有 `inst_vld` 一位。BIQ 发射的分支指令只需知道是否有效，无复杂前递。

#### 4.2.4 Pipe3（LSIQ → LSU Load）

```verilog
// 行 917-927
rf_pipe3_inst_vld <= lsiq_xx_pipe3_issue_en;
```

注意 LSIQ 对 pipe3（Load）和 pipe4（Store Addr）各有独立的 issue 信号。

#### 4.2.5 Pipe4（LSIQ → LSU Store Addr）

```verilog
// 行 932-942
rf_pipe4_inst_vld <= lsiq_xx_pipe4_issue_en;
```

#### 4.2.6 Pipe5（SDIQ → LSU Store Data）

```verilog
// 行 947-958（关键：使用不同冲刷信号）
always @(posedge rf_inst_clk or negedge cpurst_b)
begin
  ...
  // pipe 5 rf stage is flush by flush_be
  else if(rtu_yy_xx_flush)       // 注意：不是 flush_fe/is！
    rf_pipe5_inst_vld <= 1'b0;
  else
    rf_pipe5_inst_vld <= sdiq_xx_issue_en;
end
```

**为什么 pipe5 用 `rtu_yy_xx_flush` 而不是 `flush_fe/flush_is`？**

Store Data（SDIQ）的指令在结构上与 Store Addr（pipe4）配对。Store Data 不涉及前递寄存器读取（只携带数据），其 RF 阶段可以在更晚的时机被冲刷。`rtu_yy_xx_flush` 是更宽泛的全局冲刷信号（包含后端异常），确保 Store Data 在任何异常情况下都能被正确清除，同时避免被过早的前端冲刷不必要地清空。

#### 4.2.7 Pipe6（VIQ0 → VFPU）

```verilog
// 行 963-991
assign idu_vfpu_is_vdiv_issue       = viq0_xx_issue_en && dp_ctrl_is_viq0_issue_vdiv;
assign viq0_issue_vmla_rf_vld       = viq0_xx_issue_en
                                      && dp_ctrl_is_viq0_issue_dstv_vld
                                      && dp_ctrl_is_viq0_issue_vmla_rf;

always @(posedge rf_inst6_clk or negedge cpurst_b)
begin
  ...
  rf_pipe6_inst_vld             <= viq0_xx_issue_en;
  rf_pipe6_vmla_rf_lch_vld[3:0] <= {4{viq0_issue_vmla_rf_vld}};
end
```

- `rf_pipe6_vmla_rf_lch_vld[3:0]`：4 份逻辑副本，记录保留 VMLA 路径的 RF 前递解锁条件；当前 RVV 关闭时不应出现有效 VMLA 指令。
- `idu_vfpu_is_vdiv_issue = viq0_xx_issue_en && dp_ctrl_is_viq0_issue_vdiv` 是 IS issue 的组合输出，没有经过 RF valid 寄存器。RTL 能证明通知时点较早，不能仅凭该连接进一步断言 VFPU 在何时“锁定资源”。当前 RVV 关闭时该事件也应保持不活跃。

#### 4.2.8 Pipe7（VIQ1 → VFPU）

```verilog
// 行 996-1020（与 pipe6 对称）
assign viq1_issue_vmla_rf_vld = viq1_xx_issue_en
                                && dp_ctrl_is_viq1_issue_dstv_vld
                                && dp_ctrl_is_viq1_issue_vmla_rf;

rf_pipe7_inst_vld             <= viq1_xx_issue_en;
rf_pipe7_vmla_rf_lch_vld[3:0] <= {4{viq1_issue_vmla_rf_vld}};
```

pipe7 与 pipe6 共享大部分结构，但并非完全对称：pipe6 侧有 VDIV issue/写回 stall 等控制，pipe7 侧有 `vmul_unsplit` 条件，队列字段宽度和冲突逻辑也不同。当前两路均可承载标量浮点，向量专用差异属于保留结构。

---

## 5. RF 发射就绪寄存器（Launch Ready / ALU Fwd Vld）

### 5.1 机制说明

**背景**：指令在 IS 级被发射时，其源操作数可能依赖于另一条指令的 ALU 结果，而该结果还未写回物理寄存器文件（PRF）。如果依赖关系可以通过**前递（Forwarding）**在执行阶段中途满足，则等待指令不必真正等到 PRF 写回，而是可以在稍早的时刻**提前解锁**，加入下一轮调度。

这套机制的核心是：**当 pipe0/1 的 ALU 短延迟指令进入 RF 阶段时**，将其"预期在 EX1 结束时可向前递"的信息广播给所有发射队列（AIQ0/AIQ1/BIQ/LSIQ/SDIQ），以解锁等待该结果的其他指令。

### 5.2 Pipe0 ALU 前递就绪（`rf_pipe0_alu_reg_fwd_vld[107:0]`）

```verilog
// 行 1028-1048
assign aiq0_issue_alu_fwd_inst = aiq0_xx_issue_en
                                 && dp_ctrl_is_aiq0_issue_dst_vld      // 有目标寄存器
                                 && dp_ctrl_is_aiq0_issue_alu_short;   // 短延迟 ALU

assign aiq0_issue_alu_fwd_vld[107:0] = {108{aiq0_issue_alu_fwd_inst}}
                                       & dp_ctrl_is_aiq0_issue_lch_rdy[107:0];

always @(posedge rf_inst0_clk or negedge cpurst_b)
begin
  ...
  rf_pipe0_alu_reg_fwd_vld[107:0] <= aiq0_issue_alu_fwd_vld[107:0];
end

// 输出分发给各 IQ（行 1044-1048）
assign ctrl_aiq0_rf_pipe0_alu_reg_fwd_vld[23:0] = rf_pipe0_alu_reg_fwd_vld[23:0];
assign ctrl_aiq1_rf_pipe0_alu_reg_fwd_vld[23:0] = rf_pipe0_alu_reg_fwd_vld[47:24];
assign ctrl_biq_rf_pipe0_alu_reg_fwd_vld[23:0]  = rf_pipe0_alu_reg_fwd_vld[71:48];
assign ctrl_lsiq_rf_pipe0_alu_reg_fwd_vld[23:0] = rf_pipe0_alu_reg_fwd_vld[95:72];
assign ctrl_sdiq_rf_pipe0_alu_reg_fwd_vld[11:0] = rf_pipe0_alu_reg_fwd_vld[107:96];
```

**108 位的含义**：AIQ0/AIQ1/BIQ/LSIQ 各占 24 位，SDIQ 占 12 位。每一位对应某个队列 entry
的某一路源匹配资格；同一生产者可能同时匹配多个消费者，甚至匹配同一消费者的多个源，所以整个
108 位向量不是 one-hot。它是“可被该生产者前递资格覆盖的等待源集合”。

**为什么要把该位图寄存在 RF 控制中？**

IS 发射生产者时，队列条目已经携带预计算的 `lch_rdy` 匹配集合。`rf_ctrl` 用
`issue_en && dst_vld && alu_short` 对该集合限定，并在 `rf_inst0_clk` 边沿锁存。
锁存后的位图送回各队列的 `dep_reg_entry`，在其中直接参与
`x_read_rdy_for_issue = rdy || alu*_reg_fwd_vld || ...`。因此可以确认的闭环是：

```text
生产者被 issue
  -> 对应匹配集合在 RF 控制寄存
  -> 等待依赖项获得当拍 issue-ready 资格
  -> 消费者若被选中，RF 数据路径还必须在实际需要数据时命中相应前递源
```

这里的关键不是一个可脱离流水停顿使用的绝对拍数，而是“调度资格”必须与真实数据前递窗口对齐。
`alu_short`、队列仲裁、RF launch fail、执行级 stall 和前递选择都会改变具体时间关系。RTL 注释中的
`ex2 fwd` 描述目标路径类别，不足以单独证明所有短 ALU 都按同一固定周期到达。

### 5.3 Pipe1 ALU + MLA 前递就绪

```verilog
// 行 1053-1086
assign aiq1_issue_alu_fwd_inst = aiq1_xx_issue_en
                                 && dp_ctrl_is_aiq1_issue_dst_vld
                                 && dp_ctrl_is_aiq1_issue_alu_short;

assign aiq1_issue_alu_fwd_vld[107:0] = {108{aiq1_issue_alu_fwd_inst}}
                                       & dp_ctrl_is_aiq1_issue_lch_rdy[107:0];

// MLA（乘加）的前递就绪
assign aiq1_issue_mla_fwd_inst     = aiq1_xx_issue_en && dp_ctrl_is_aiq1_issue_mla_vld;
assign aiq1_issue_mla_fwd_vld[7:0] = {8{aiq1_issue_mla_fwd_inst}}
                                     & dp_ctrl_is_aiq1_issue_mla_lch_rdy[7:0];

always @(posedge rf_inst1_clk or negedge cpurst_b)
begin
  ...
  rf_pipe1_alu_reg_fwd_vld[107:0] <= aiq1_issue_alu_fwd_vld[107:0];
  rf_pipe1_mla_fwd_vld[7:0]       <= aiq1_issue_mla_fwd_vld[7:0];
end
```

- pipe1 除了普通 ALU 短延迟前递，还支持 **MLA（乘加累加）**的前递解锁。
- `ctrl_aiq1_rf_pipe1_mla_reg_lch_vld[7:0]` 输出给 AIQ1，用于解锁等待 MLA 累加输入的指令。
- MLA 前递位图为 8 位，是因为该接口只覆盖 AIQ1 的 8 个 entry；这是连接范围事实。不能仅从位宽推断
  “MLA 依赖通常只在局部形成”这一工作负载统计结论。

### 5.4 Pipe6/7 VMLA 向量前递就绪

```verilog
// 行 1091-1128
assign viq0_issue_vmla_fwd_inst      = viq0_xx_issue_en && dp_ctrl_is_viq0_issue_vmla_short;
assign viq0_issue_vmla_fwd_vld[15:0] = {16{viq0_issue_vmla_fwd_inst}}
                                       & dp_ctrl_is_viq0_issue_lch_rdy[15:0];

always @(posedge rf_inst6_clk or negedge cpurst_b)
begin
  ...
  rf_pipe6_vmla_vreg_fwd_vld[15:0] <= viq0_issue_vmla_fwd_vld[15:0];
end

// 分发给 VIQ0 和 VIQ1（各 8 位）
assign ctrl_viq0_rf_pipe6_vmla_vreg_fwd_vld[7:0] = rf_pipe6_vmla_vreg_fwd_vld[7:0];
assign ctrl_viq1_rf_pipe6_vmla_vreg_fwd_vld[7:0] = rf_pipe6_vmla_vreg_fwd_vld[15:8];
```

VMLA（向量乘加）是向量版本的 MLA，前递就绪机制与整数类似。16 位位图分成两半分别发给 VIQ0 和 VIQ1，因为向量指令在两条 VIQ 之间可能存在依赖。

---

## 6. 前递就绪控制（核心）

### 6.1 前递资格与数据到达的关系

```
生产者 issue_en + alu_short + dst_vld
                    |
                    v
          aiq0_issue_alu_fwd_vld
                    |
             rf_inst0_clk 锁存
                    |
                    v
  ctrl_*_rf_pipe0_alu_reg_fwd_vld
                    |
                    v
 dep_reg_entry.rdy_for_issue（调度资格）
                    |
           oldest-ready 仲裁、RF launch
                    |
                    v
 rf_fwd_preg 选择真实生产者数据（数据资格）
```

前四步只决定消费者“可以尝试发射”，最后一步才决定 RF 数据选择是否真的拿到前递值。若预测的窗口没有
兑现，`src_no_rdy` 会造成 launch fail，IQ 冻结/解冻和 `rdy_clr` 负责重调度。因此读波形时必须同时看
`alu_reg_fwd_vld`、消费者 `issue_en`、`rf_*_lch_fail` 与 `fwd_*_sel/no_fwd`，不能只看到 ready 位就认为
数据已经写回或已经被消费者接收。

### 6.2 `rf_pipe0_preg_lch_vld` 与 `rf_pipe0_alu_reg_fwd_vld` 的区别

| 信号 | 含义 | 使用者 |
|------|------|--------|
| `rf_pipe0_preg_lch_vld[4:0]` | pipe0 当前 RF 指令具有可用于前递比较的目的 preg 资格；多份复制用于不同接收扇出 | `rf_fwd_preg` 的生产者资格比较，不是 PRF 写端口使能 |
| `rf_pipe0_alu_reg_fwd_vld[107:0]` | pipe0 是短延迟 ALU 且有目标寄存器，解锁等待者 | 各 AIQ/BIQ/LSIQ/SDIQ：唤醒等待此结果的指令 |

`rf_pipe0_preg_lch_vld` 进入 `rf_fwd_preg` 后，只是多个候选生产者有效条件之一；模块还比较目的 preg
与消费者源 preg，最终生成 one-hot 选择和 `no_fwd`。因此不能把 `preg_lch_vld` 单独称为“前递总线已经选通”，
更不能称为 PRF 写使能。

`rf_pipe0_special_vld` 的本地作用是形成 `ctrl_rf_pipe0_special_stall`；当前
`aiq0_issue_alu_fwd_inst` 方程只接受 `issue_en && dst_vld && alu_short`。所以不能由注释进一步推出
Special 指令也经同一 `alu_reg_fwd_vld` 位图解锁等待者。若要证明 Special 的 EX2 前递准备路径，应继续
追踪 Special 的结果有效、目的 preg 广播及对应 dep 输入，而不是用 stall 信号替代数据就绪证据。

### 6.3 前递就绪向量的分区布局

`lch_rdy[107:0]` 的分区方式如下：

```
bit[107:96] = SDIQ  中等待该寄存器结果的 12 个条目的就绪位
bit[95:72]  = LSIQ  中等待该寄存器结果的 24 个条目的就绪位
bit[71:48]  = BIQ   中等待该寄存器结果的 24 个条目的就绪位
bit[47:24]  = AIQ1  中等待该寄存器结果的 24 个条目的就绪位
bit[23:0]   = AIQ0  中等待该寄存器结果的 24 个条目的就绪位
```

`dp_ctrl_is_aiq0_issue_lch_rdy[107:0]` 由 IS 阶段的 rf_dp 模块根据物理寄存器号与各 IQ 中等待项的依赖关系计算得出，直接编码为位图传入 rf_ctrl。

---

## 7. 发射暂停（RF Stall）

RF stall 是反馈给相应 IQ 的**新 issue 抑制条件**。已经锁存在 RF 的当前指令仍按本周期的 `inst_vld/lch_fail/pipedown_vld` 处理；在下一次对应 RF 时钟沿，`rf_pipeN_inst_vld` 会重新采样新的 `issue_en`。若 stall 使新 issue 为 0，原有 valid 通常在完成当前周期后更新为 0，而不是无限保持。

### 7.1 AIQ0 暂停条件

```verilog
// 行 1167-1169
assign ctrl_aiq0_stall = ctrl_rf_pipe6_mfvr_vld      // pipe6 有 MFVR（VR→GPR）
                        || ctrl_rf_pipe0_div_stall    // DIV 写回占用 pipe0 总线
                        || ctrl_rf_pipe0_special_stall; // Special 指令独占 EX1 完成端口
```

- **`ctrl_rf_pipe6_mfvr_vld`**：MFVR（Move From Vector Register）指令在 EX2 使用 pipe0/1 的 GPR 写回端口。为避免 pipe0 的新 ALU 指令与 MFVR 争抢 EX2 的 GPR 写端口，必须暂停 AIQ0。注释 `// ex2 pipe6/7 mfvr will share ex1 pipe0/1 // stall aiq all inst issue at pipe6/7 rf` 说明了这个设计意图。
- **`ctrl_rf_pipe0_div_stall`**：整数除法执行结束时需要占用 pipe0 的写回路径，此时不允许新的 ALU 指令进入 pipe0。
- **`ctrl_rf_pipe0_special_stall`**：`rf_pipe0_special_vld` 为高，表示当前 RF 阶段有特殊指令，该指令需要独占 EX1 完成端口，不允许 IS 级发射新的 pipe0 指令（避免竞争）。

### 7.2 AIQ1 暂停条件

```verilog
// 行 1171
assign ctrl_aiq1_stall = ctrl_rf_pipe7_mfvr_vld; // pipe7 有 MFVR
```

pipe7 的 MFVR 会占用 pipe1 的 GPR 写端口，因此暂停 AIQ1。

### 7.3 VIQ0 暂停条件

```verilog
// 行 1173-1174
assign ctrl_viq0_stall = ctrl_rf_pipe0_mtvr_vld   // pipe0 有 MTVR（GPR→VR）
                        || ctrl_rf_pipe6_vdiv_stall; // 向量除法写回占用 pipe6
```

- **`ctrl_rf_pipe0_mtvr_vld`**：MTVR（Move To Vector Register）在 EX2 使用 pipe6/7 的 VRF 写端口。为避免 VIQ0/1 的新指令与 MTVR 争抢 VRF 写端口，必须暂停 VIQ0。
- **`ctrl_rf_pipe6_vdiv_stall`**：向量除法写回时占用 pipe6，暂停 VIQ0 新发射。

### 7.4 VIQ1 暂停条件

```verilog
// 行 1176
assign ctrl_viq1_stall = ctrl_rf_pipe1_mtvr_vld; // pipe1 有 MTVR
```

pipe1 的 MTVR 占用 pipe7 的 VRF 写端口，暂停 VIQ1。

### 7.5 MTVR/MFVR 端口共享关系总结

```
  GPR写端口       VRF写端口
  pipe0(EX2)  <-> pipe6(EX1) [MFVR: 6->0, MTVR: 0->6]
  pipe1(EX2)  <-> pipe7(EX1) [MFVR: 7->1, MTVR: 1->7]
```

这是一个典型的**执行单元端口复用**设计：将两条管线的空闲端口用于跨管线的寄存器移动，节省硬件资源，但必须由控制逻辑协调端口冲突。

---

## 8. 发射失败（Launch Fail）

发射失败（lch fail）与暂停（stall）的区别：
- **Stall**：阻止相应 IQ 产生新的 issue；已经在 RF 的当前项仍完成本周期检查，下一次 RF valid 由新的 issue_en 覆盖。
- **Lch Fail**：IS 级已经发射（inst_vld 置位），但在 RF 阶段检测到指令**无法继续执行**，需要取消本次执行并通知 IQ 解冻（重新调度）。

对发生 launch fail 的这个 RF 周期，`inst_vld` 仍表示槽中确有一项，但 `pipedown_vld = inst_vld && !lch_fail` 为 0，所以不向执行单元提交。IQ 收到 fail 后解冻/重调度该 entry；RF valid 在后续有效时钟沿继续按新的 issue_en 更新。这里的 `inst_vld=1` 是阶段占用事实，不是成功执行事实。

### 8.1 源操作数未就绪（src_no_rdy）

```verilog
// 行 1283-1298
assign ctrl_rf_pipe0_lch_fail = dp_ctrl_rf_pipe0_src_no_rdy || ctrl_rf_pipe0_other_lch_fail;
assign ctrl_rf_pipe1_lch_fail = dp_ctrl_rf_pipe1_src_no_rdy;
assign ctrl_rf_pipe2_lch_fail = dp_ctrl_rf_pipe2_src_no_rdy;
assign ctrl_rf_pipe3_lch_fail = dp_ctrl_rf_pipe3_src_no_rdy || ctrl_rf_pipe3_other_lch_fail;
...
```

`dp_ctrl_rf_pipeN_src_no_rdy` 由 rf_dp 模块计算：在 RF 阶段读物理寄存器时发现前递条件不满足（指令在 IS 阶段预估可前递，但到了 RF 阶段发现前递源尚未完成）。这是一种**乐观发射**（Speculative Issue）机制——IS 阶段乐观地发射指令，在 RF 阶段做最终验证，失败则重发。

### 8.2 MTVR/MFVR 端口冲突导致的发射失败

```verilog
// 行 1189-1203
// pipe0 MTVR 与 pipe6 VDIV 写回同时发生
assign ctrl_rf_pipe0_vdiv_mtvr_lch_fail = ctrl_rf_pipe0_mtvr_vld
                                         && ctrl_rf_pipe6_vdiv_stall;

// pipe6 MFVR 与 pipe0 DIV 写回同时发生
assign ctrl_rf_pipe6_div_mfvr_lch_fail = ctrl_rf_pipe6_mfvr_vld
                                        && ctrl_rf_pipe0_div_stall;

// pipe7 MFVR 与 pipe1 MULT 同时发生
assign ctrl_rf_pipe7_mult_mfvr_lch_fail = ctrl_rf_pipe7_mfvr_vld
                                         && iu_idu_ex1_pipe1_mult_stall;
```

**为什么这些情况会出现？**

Stall 机制只能阻止 IS 级发射**新的** MTVR/MFVR，但如果 MTVR/MFVR 已经在 RF 阶段（上一周期已经发射进来），而此时恰好 DIV/VDIV 写回信号到来，就会产生端口冲突，必须让当前 RF 阶段的 MTVR/MFVR 发射失败重调度。

设计注释特别强调了死锁风险：
```
// CAUTION: avoid dead lock: when inst1 lch fail inst2, inst2
//          may lch fail inst1 through src no ready
```

互相发射失败会形成循环等待。rf_ctrl 通过精确的优先级设计（见下文）避免死锁。

### 8.3 物理寄存器读端口共享冲突（preg/vreg share）

```verilog
// 行 1217-1243
// 整数物理寄存器读端口共享
// 优先级：pipe0 src2 > pipe3 src1；pipe1 src1 > pipe5 src0
assign ctrl_rf_pipe3_preg_lch_fail = ctrl_rf_pipe3_src1_vld && ctrl_rf_pipe0_src2_vld;
assign ctrl_rf_pipe5_preg_lch_fail = ctrl_rf_pipe5_src0_vld && ctrl_rf_pipe1_src2_vld;

// 向量寄存器读端口共享
// 优先级：pipe6 srcv2 > pipe3 srcvm；pipe7 srcv2 > pipe4 srcvm
assign ctrl_rf_pipe3_vreg_lch_fail = ctrl_rf_pipe3_srcvm_vld && ctrl_rf_pipe6_srcv2_vld;
assign ctrl_rf_pipe4_vreg_lch_fail = ctrl_rf_pipe4_srcvm_vld && ctrl_rf_pipe7_srcv2_vld;
```

**物理寄存器文件（PRF）读端口是有限资源**。C910 的 PRF 为每条管线提供固定数量的读端口，当两条管线同时需要读取第三个操作数（src2/srcvm）时，端口不足，必须让低优先级管线发射失败重调度。

端口共享规则总结：

```
整数 PRF 读端口：
  pipe0 有 src2 时，pipe3 的 src1 必须发射失败（pipe0 优先）
  pipe1 有 src2 时，pipe5 的 src0 必须发射失败（pipe1 优先）

向量 PRF 读端口：
  pipe6 有 srcv2 时，pipe3 的 srcvm 必须发射失败（pipe6 优先）
  pipe7 有 srcv2 时，pipe4 的 srcvm 必须发射失败（pipe7 优先）
```

### 8.4 向量乘法未拆分冲突

```verilog
// 行 1251-1259
// 避免死锁：先检查 pipe7 自身是否发射失败
assign ctrl_rf_pipe7_vmul_unsplit_vld = ctrl_rf_pipe7_inst_vld
                                       && !ctrl_rf_pipe7_lch_fail    // pipe7 自身没有失败
                                       && dp_ctrl_rf_pipe7_vmul_unsplit;
assign ctrl_rf_pipe6_vmul_vld         = ctrl_rf_pipe7_inst_vld
                                       && dp_ctrl_rf_pipe6_vmul;
// pipe7 未拆分乘法需要独占 pipe6 的乘法单元
assign ctrl_rf_pipe6_vmul_unsplit_lch_fail = ctrl_rf_pipe7_vmul_unsplit_vld
                                            && ctrl_rf_pipe6_vmul_vld;
```

保留向量乘法路径区分 split/unsplit；当 pipe7 的 unsplit 条件成立时，这段逻辑用于抑制与其共享资源的 pipe6 vmul 候选。

> **RTL 核查点**：公开代码中 `ctrl_rf_pipe6_vmul_vld` 的有效门控写的是 `ctrl_rf_pipe7_inst_vld`，而属性位取自 `dp_ctrl_rf_pipe6_vmul`。这不是文档笔误。它可能是经过上下游配对约束的特意编码，也可能值得进一步验证；在没有仿真断言或设计规格前，不擅自改写为 `pipe6_inst_vld`，也不直接判定为 bug。波形核查时应同时观察 pipe6/7 valid、两个 vmul 属性位和最终 lch-fail。

注意这里的死锁规避设计：**只有当 pipe7 自身没有发射失败时**，才让 pipe6 失败。如果两者互相让对方失败，就会死锁，因此 pipe7 的 `ctrl_rf_pipe7_lch_fail` 被提前计算并反馈到这里。

### 8.5 发射失败信号汇总

```verilog
// 行 1265-1280
assign ctrl_rf_pipe0_other_lch_fail = ctrl_rf_pipe0_vdiv_mtvr_lch_fail;
assign ctrl_rf_pipe3_other_lch_fail = ctrl_rf_pipe3_preg_lch_fail || ctrl_rf_pipe3_vreg_lch_fail;
assign ctrl_rf_pipe4_other_lch_fail = ctrl_rf_pipe4_vreg_lch_fail;
assign ctrl_rf_pipe5_other_lch_fail = ctrl_rf_pipe5_preg_lch_fail;
assign ctrl_rf_pipe6_other_lch_fail = ctrl_rf_pipe6_div_mfvr_lch_fail
                                    || ctrl_rf_pipe6_vmul_unsplit_lch_fail;
assign ctrl_rf_pipe7_other_lch_fail = ctrl_rf_pipe7_mult_mfvr_lch_fail;
```

**汇总规律**：
- pipe0：只有 MTVR/VDIV 冲突（src_no_rdy 来自 dp，单独计算）。
- pipe1/2：只有 src_no_rdy。
- pipe3：preg 端口冲突 + vreg 端口冲突 + src_no_rdy（三路 OR）。
- pipe4：vreg 端口冲突 + src_no_rdy。
- pipe5：preg 端口冲突 + src_no_rdy。
- pipe6：DIV/MFVR 冲突 + vmul_unsplit 冲突 + src_no_rdy。
- pipe7：MULT/MFVR 冲突 + src_no_rdy。

### 8.6 发射失败对 IQ 的影响

```verilog
// 行 1326-1341
assign ctrl_aiq0_rf_lch_fail_vld = ctrl_rf_pipe0_inst_vld && ctrl_rf_pipe0_lch_fail;
assign ctrl_aiq1_rf_lch_fail_vld = ctrl_rf_pipe1_inst_vld && ctrl_rf_pipe1_lch_fail;
assign ctrl_biq_rf_lch_fail_vld  = ctrl_rf_pipe2_inst_vld && ctrl_rf_pipe2_lch_fail;
...
```

发射失败信号发回对应的发射队列（AIQ/BIQ/LSIQ/SDIQ/VIQ），IQ 收到后**解冻（unfreeze）**该条目，使其在下一周期可以重新参与仲裁发射。

### 8.7 Store Addr 就绪通知

```verilog
// 行 1392-1394
assign ctrl_sdiq_rf_staddr_rdy_set = ctrl_rf_pipe4_inst_vld
                                    && !ctrl_rf_pipe4_lch_fail
                                    && dp_ctrl_rf_pipe4_staddr;
```

当 pipe4（Store Addr）成功通过 RF 阶段（没有发射失败），通知 SDIQ：Store Address 已被发出执行，对应的 Store Data 可以设置就绪（从 SDIQ 发射）。注释说明：重放的 Store Addr 不应再次设置 Store Data 就绪，因为 Store Data 在第一次 Store Addr 通过时已经被弹出。

---

## 9. RF 流水推进与执行单元选择

### 9.1 RF 推进有效（pipedown_vld）

```verilog
// 行 1306-1321
assign ctrl_rf_pipe0_pipedown_vld = ctrl_rf_pipe0_inst_vld && !ctrl_rf_pipe0_lch_fail;
assign ctrl_rf_pipe1_pipedown_vld = ctrl_rf_pipe1_inst_vld && !ctrl_rf_pipe1_lch_fail;
// ... 以此类推
```

`pipedown_vld = inst_vld AND NOT lch_fail`

- `inst_vld=1, lch_fail=0`：指令正常推进，`pipedown_vld=1`，激活执行单元。
- `inst_vld=1, lch_fail=1`：发射失败，`pipedown_vld=0`，数据路径不传递。
- `inst_vld=0`：RF 级为空，`pipedown_vld=0`。

### 9.2 Pipe0 执行单元选择（EU Selection）

```verilog
// 行 1402-1416
assign ctrl_rf_pipe0_eu_sel[3:0] =
         {4{ctrl_rf_pipe0_pipedown_vld}} & dp_ctrl_rf_pipe0_eu_sel[3:0];
assign ctrl_rf_pipe0_eu_gateclk_sel[3:0] =
         {4{ctrl_rf_pipe0_inst_vld}}     & dp_ctrl_rf_pipe0_eu_sel[3:0];

assign idu_cp0_rf_sel                = ctrl_rf_pipe0_eu_sel[3]; // CP0/CSR
assign idu_iu_rf_special_sel         = ctrl_rf_pipe0_eu_sel[2]; // Special
assign idu_iu_rf_div_sel             = ctrl_rf_pipe0_eu_sel[1]; // DIV
assign idu_iu_rf_pipe0_sel           = ctrl_rf_pipe0_eu_sel[0]; // ALU/普通整数
```

eu_sel 是一个 4 位独热码，由 IS 阶段解码得出（存在 rf_dp 的 pipeline 寄存器中，通过 `dp_ctrl_rf_pipe0_eu_sel` 传入），在 RF 阶段与 `pipedown_vld` 相与，产生最终的执行单元使能。

`eu_gateclk_sel` 使用 `inst_vld` 而非 `pipedown_vld`，所以 RF 槽中有指令但发生 launch fail 时，
执行单元对应的 gateclk 选择仍可能有效，而功能 `eu_sel` 被 `pipedown_vld` 抑制。这样把执行单元局部时钟
请求与最终功能接收分开；是否用于解决哪一条建立时间路径，应由执行单元连接和 STA 证明，不能仅凭命名断言。

### 9.3 各管线执行单元输出

| 管线 | sel 信号 | 目标单元 |
|------|---------|---------|
| pipe0 | `idu_iu_rf_pipe0_sel` | IU ALU（普通整数） |
| pipe0 | `idu_iu_rf_div_sel` | IU DIV |
| pipe0 | `idu_iu_rf_special_sel` | IU Special（CSR等） |
| pipe0 | `idu_cp0_rf_sel` | CP0（协处理器） |
| pipe1 | `idu_iu_rf_pipe1_sel` | IU ALU（第二路） |
| pipe1 | `idu_iu_rf_mult_sel` | IU MULT |
| pipe2 | `idu_iu_rf_bju_sel` | IU BJU（分支） |
| pipe3 | `idu_lsu_rf_pipe3_sel` | LSU（Load） |
| pipe4 | `idu_lsu_rf_pipe4_sel` | LSU（Store Addr） |
| pipe5 | `idu_lsu_rf_pipe5_sel` | LSU（Store Data） |
| pipe6 | `idu_vfpu_rf_pipe6_sel` | VFPU（当前标量浮点活跃，向量控制保留） |
| pipe7 | `idu_vfpu_rf_pipe7_sel` | VFPU（当前标量浮点活跃，向量控制保留） |

### 9.4 IQ 弹出信号

```verilog
// 行 1347-1356
// 正常弹出：需要成功推进
assign ctrl_aiq0_rf_pop_vld  = ctrl_rf_pipe0_pipedown_vld;
assign ctrl_aiq1_rf_pop_vld  = ctrl_rf_pipe1_pipedown_vld;
assign ctrl_biq_rf_pop_vld   = ctrl_rf_pipe2_pipedown_vld;
assign ctrl_viq0_rf_pop_vld  = ctrl_rf_pipe6_pipedown_vld;
assign ctrl_viq1_rf_pop_vld  = ctrl_rf_pipe7_pipedown_vld;

// DLB（Dynamic Load Balance）占用估计反馈：只看 RF inst_vld
assign ctrl_aiq0_rf_pop_dlb_vld = ctrl_rf_pipe0_inst_vld;
assign ctrl_aiq1_rf_pop_dlb_vld = ctrl_rf_pipe1_inst_vld;
assign ctrl_viq0_rf_pop_dlb_vld = ctrl_rf_pipe6_inst_vld;
assign ctrl_viq1_rf_pop_dlb_vld = ctrl_rf_pipe7_inst_vld;
```

注意：pipe3/4/5 的弹出信号由 LSU 自行处理，不在这里生成。

`DLB` 在 `ct_idu_ir_ctrl.v` 的 RTL 注释中明确指 **Dynamic Load Balance**。这些 `pop_dlb_vld` 用 RF 阶段 `inst_vld` 向 IR 的队列占用估计/动态负载均衡逻辑提供“预计离队”信息；它们不是某个实体 Deferred Launch Buffer 的功能 pop。因为使用 `inst_vld` 而不是成功推进的 `pipedown_vld`，该反馈可与真实队列 pop 存在语义差异，适合做调度容量估计，不应拿来证明指令已成功进入执行单元。

---

## 10. 性能监控计数器（HPCP）

### 10.1 HPCP 时钟门控

```verilog
// 行 1474-1476
assign hpcp_clk_en = hpcp_idu_cnt_en
                     && ctrl_rf_hpcp_inst_vld    // 当前有指令
                     || ctrl_rf_hpcp_inst_vld_ff; // 上一周期有统计需更新
```

HPCP 是 C910 的硬件性能事件采集接口。`hpcp_clk_en` 的运算优先级为 `(hpcp_idu_cnt_en && ctrl_rf_hpcp_inst_vld) || ctrl_rf_hpcp_inst_vld_ff`：第一项在计数使能且当前 RF 有指令时采样，第二项即使当前没有新事件，也为前一拍已寄存的非零采样再保留一个时钟机会，使 `_ff` 能在 else 分支清零。不能简写成“只有当前计数使能且有指令才开钟”。此外，物理门控仍受全局、模块和扫描使能影响。

### 10.2 采样与输出

```verilog
// 行 1518-1586（always 块）
if(hpcp_idu_cnt_en && ctrl_rf_hpcp_inst_vld) begin
  ctrl_rf_hpcp_pipe0_inst_vld_ff <= ctrl_rf_pipe0_inst_vld;
  ...
  ctrl_rf_hpcp_pipe0_rf_lch_fail_vld_ff <= ctrl_rf_hpcp_pipe0_rf_lch_fail_vld;
  ...
  ctrl_rf_hpcp_pipe3_rf_reg_lch_fail_vld_ff <= ctrl_rf_hpcp_pipe3_rf_reg_lch_fail_vld;
end
```

每个管线输出的事件口径必须分开理解：

1. **`inst_vld`**：采样该管线 RF 槽占用。它可以包含随后 launch fail 的项，所以更接近“RF 尝试/占用周期”，不是成功执行或退休吞吐量。
2. **普通 `lch_fail_vld`**：RTL 注释明确为 `lch fail by src no rdy`，只统计 `inst_vld && src_no_rdy`。它没有把 pipe0/6/7 的其他资源冲突自动并入。
3. **`reg_lch_fail_vld`**：只为 pipe3/4/5另行输出共享 PREG/VREG 读端口冲突。它和普通 src-not-ready 事件是不同口径。

其他 launch fail，例如 MFVR 与 DIV/MULT 冲突、保留的 vmul-unsplit 冲突，不一定出现在上述普通 HPCP fail 位中。分析“全部 RF 重放”时不能只加总普通 `lch_fail_vld`。

这些事件先在 `hpcp_clk` 上升沿写入 `_ff`，对外输出因此相对被采样 RF 组合事件晚一个寄存阶段；无新采样时下一次有效 HPCP 时钟会清零。寄存化提供了明确的采样边界和接口时序，不能把设计目的只归结为“消除毛刺”。

---

## 11. 与相邻子模块的协调

### 11.1 与 ct_idu_rf_dp 的关系

```
       ct_idu_rf_ctrl          ct_idu_rf_dp
       ──────────────          ────────────
  pipeN_pipedown_vld ─────────> 使能 RF 阶段 MUX 和输出寄存器
  pipeN_lch_fail     ─────────> 抑制数据路径写入
  pipe0_eu_sel       ─────────> 选择执行单元数据总线
  <──────────────────── pipe0_src_no_rdy（等待验证结果）
  <──────────────────── pipe0_eu_sel（解码后的执行单元编码）
  <──────────────────── pipe0_mtvr / pipe0_src2_vld（端口冲突检测输入）
```

rf_ctrl 和 rf_dp 是**同级模块**，rf_ctrl 生成控制信号，rf_dp 完成实际的操作数读取和前递选择。两者之间通过 `dp_ctrl_*` 和 `ctrl_dp_*` 前缀信号双向通信。

### 11.2 与 ct_idu_rf_fwd / ct_idu_rf_fwd_preg / ct_idu_rf_fwd_vreg 的关系

```
rf_ctrl:
  ctrl_xx_rf_pipe0_preg_lch_vld_dup0~4 ──> rf_fwd_preg
  ctrl_xx_rf_pipe1_preg_lch_vld_dup0~4 ──> rf_fwd_preg
  ctrl_xx_rf_pipe6_vmla_lch_vld_dup0~3 ──> rf_fwd_vreg
  ctrl_xx_rf_pipe7_vmla_lch_vld_dup0~3 ──> rf_fwd_vreg
```

`rf_fwd_preg` 和 `rf_fwd_vreg` 是前递网络模块，它们根据 `preg_lch_vld` / `vmla_lch_vld` 信号，在 EX1 阶段控制前递 MUX 从执行单元输出而非 PRF 中选择操作数。

rf_ctrl 提供的是"是否有有效的写回发生（即使还没完成）"的指示，rf_fwd_* 则根据这个指示和寄存器号匹配，决定具体的 MUX 路径。

### 11.3 与 ct_idu_rf_prf_pregfile / ct_idu_rf_prf_vregfile 的关系

rf_ctrl 不直接控制 PRF。PRF 的读地址和读使能由 rf_dp 提供，rf_ctrl 只通过 `pipedown_vld` 间接影响 rf_dp 是否使用读出的数据。

### 11.4 与上游 IS 级的关系

```
IS 级 (ct_idu_is_ctrl, is_aiq0, is_aiq1, ...) 
  ──> aiqN_xx_issue_en → rf_ctrl（RF 指令有效）
  ──> dp_ctrl_is_aiqN_issue_* → rf_ctrl（指令属性）
  <── ctrl_aiqN_stall（暂停信号，阻止新发射）
  <── ctrl_aiqN_rf_lch_fail_vld（发射失败，解冻 IQ 条目）
  <── ctrl_aiqN_rf_pop_vld（成功推进，弹出 IQ 条目）
```

---

## 12. 典型时序场景

### 12.1 场景一：ALU 短延迟前递（无停顿）

```
时钟:      T-1       T         T+1       T+2       T+3
IS:       [A:ADD]   [B:ADD]   [C:依赖A] ...
AIQ0:     issue_A   issue_B   issue_C
RF:                 [A:inst]  [B:inst]  [C:inst]
                    A->preg_  B->preg_  C->exec
                    lch_vld   lch_vld   (前递)
EX1:                          [A exec]  [B exec]  [C exec,
                               结果可   结果可    拿A的前
                               前递     前递      递结果]
fwd_vld:            T时刻AIQ0
                    广播A的
                    lch_rdy
                    -> C解锁
```

A 在 T 进入 RF，T+1 时刻 C 收到前递就绪解锁，T+2 进入 RF，T+3 进入 EX1 时正好从前递总线拿到 A 的 EX1 结果（A 在 T+2 处于 EX1）——这是零气泡的紧密前递链。

### 12.2 场景二：发射失败（src_no_rdy）重调度

```
时钟:      T         T+1       T+2       T+3
IS:       [A:MULT]  [B:依赖A发射(乐观)]
RF:                 [A:inst]  [B:inst,  [B重试,
                               lch_fail] 等A完成]
IQ:                            B冻结解   B重新
                               冻,重调度  调度发射
```

IS 级在 T 乐观地认为 B 可以发射（预估 A 的乘法结果可以通过前递获取），到了 T+1 的 RF 阶段验证失败（`src_no_rdy=1`），B 发射失败，IQ 解冻 B，等到 MULT 完成写回或更早的前递条件满足后，B 重新被选中发射。

### 12.3 场景三：MFVR/DIV 冲突

```
时钟:      T         T+1       T+2
IS:       [MFVR]   [新ALU(aiq0 issue)]
RF:                 [MFVR inst] ...
           MFVR RF阶段时,    若DIV写回=1:
           ctrl_rf_pipe6_div_mfvr_lch_fail=1
           MFVR 发射失败
DIV写回:            iu_idu_div_wb_stall=1
```

DIV 写回暂停信号是实时（组合）信号，当 RF 阶段的 MFVR 与 DIV 写回同时出现，控制逻辑在同一拍内产生 `lch_fail`，MFVR 被重调度到下一个无冲突的周期。

---

## 13. 小结

`ct_idu_rf_ctrl` 是 C910 IDU 流水线的最后一道关卡，以约 1600 行的 RTL 代码完整实现了以下功能层次：

| 功能层次 | 关键实现 |
|---------|---------|
| 有效性跟踪 | 8 个 `rf_pipeN_inst_vld` 寄存器，冲刷时清零 |
| 前递预通告 | `rf_pipe0/1_alu_reg_fwd_vld[107:0]`：ALU 进入 RF 时广播，提前 1 拍解锁等待者 |
| VFPU 保留向量前递 | `rf_pipe6/7_vmla_vreg_fwd_vld[15:0]`：当前 RVV 关闭，逻辑仍保留 |
| 端口冲突暂停 | MTVR/MFVR 端口复用、DIV/VDIV 写回暂停 4 路暂停逻辑 |
| 资源冲突失败 | PRF 读端口优先级仲裁、vmul_unsplit 死锁避免 |
| 操作数验证失败 | src_no_rdy 乐观发射 + RF 验证 |
| 执行单元调度 | pipedown_vld 驱动 EU sel，gateclk_sel 提前打开门控 |
| 性能监控 | HPCP 单级事件采样寄存器，区分 RF 占用、源未就绪和 pipe3/4/5 端口冲突 |

整个模块体现了**队列先选、RF 再验证、失败重调度**以及前递就绪预告的设计思路。这些机制旨在缩短依赖链等待并协调有限端口，但“接近零气泡”属于需要 workload、波形和性能计数验证的结果，不能由控制结构本身保证。
