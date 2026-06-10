# C910 IDU 物理寄存器堆（PRF）详解

> 对应 RTL 文件：
> - `ct_idu_rf_prf_pregfile.v`（4052 行）—— 整数物理寄存器堆
> - `ct_idu_rf_prf_fregfile.v`（2229 行）—— 浮点物理寄存器堆
> - `ct_idu_rf_prf_vregfile.v`（293 行）—— 向量物理寄存器堆接口层
> - `ct_idu_rf_prf_eregfile.v`（911 行）—— 浮点异常状态寄存器堆
> - `ct_idu_rf_prf_gated_preg.v`（116 行）—— 整数物理寄存器单元
> - `ct_idu_rf_prf_gated_vreg.v`（120 行）—— 浮点/向量物理寄存器单元
> - `ct_idu_rf_prf_gated_ereg.v`（116 行）—— 异常状态物理寄存器单元

---

## 1. 模块概述：PRF 在流水线中的位置

### 1.1 物理寄存器堆的作用

**PRF（Physical Register File，物理寄存器堆）**是乱序超标量处理器中寄存器重命名机制的核心存储体。它的职责是：

1. **存储指令结果**——执行单元完成计算后，把结果写入该指令目的物理寄存器对应的槽位；
2. **提供源操作数**——在 RF 阶段（Register File Read），每条指令根据重命名后得到的物理寄存器号从 PRF 读取两个（有时三个）源操作数；
3. **隐藏写后读 (WAR) 与写后写 (WAW) 相关**——由于架构寄存器到物理寄存器的映射随指令流动态变化，同一架构寄存器在不同时刻对应不同的物理寄存器，相关消除由重命名完成，PRF 仅负责存储。

### 1.2 上下游关系

```
 重命名阶段 (RAT)
      |  为每条指令分配物理目的寄存器号 (pdest)
      |  查出物理源寄存器号 (psrc0/psrc1)
      v
  IS (发射队列) — 把 psrc0/psrc1 存在发射项中
      |
      | 发射后，psrc0/psrc1 传给 RF 阶段
      v
  RF 阶段 (Register File Read)
      |  dp_prf_rf_pipe*_src*_preg[6:0] ——> PRF 读地址
      |  prf_dp_rf_pipe*_src*_data[63:0] <—— PRF 输出
      v
  EX 执行阶段
      |  产生结果
      |  iu/lsu/vfpu _wb_preg_data[63:0] ——> PRF 写数据
      |  _wb_preg_expand[95:0]           ——> one-hot 写地址
      v
  WB 写回（同时写入 PRF）
```

整数 PRF 由 `ct_idu_rf_prf_pregfile` 统一管理，浮点 PRF 由 `ct_idu_rf_prf_fregfile` 管理，向量 PRF 目前由 `ct_idu_rf_prf_vregfile` 作为占位层（见第 4 节）。异常状态 PRF `ct_idu_rf_prf_eregfile` 存储浮点运算产生的例外标志（见第 5 节）。

---

## 2. 整数物理寄存器堆 `ct_idu_rf_prf_pregfile`

### 2.1 基本参数

| 参数 | 值 | 推断依据 |
|------|----|----------|
| 物理寄存器数量 | **96**（preg0 ~ preg95） | `wire [95:0] pipe0_wb_vld` 及 96 个 `preg*_reg_dout` 声明 |
| 寄存器位宽 | **64 位** | `reg [63:0] reg_dout` |
| 物理寄存器号位宽 | **7 位**（`[6:0]`） | 读端口地址 `dp_prf_rf_pipe*_src*_preg[6:0]`，可寻址 128 个，实际用 96 个 |
| 写端口数 | **3** | pipe0（整数 ALU）、pipe1（整数 ALU）、pipe3（LSU） |
| 读端口数 | **11** | pipe0×2、pipe1×2、pipe2×2、pipe3×2、pipe4×2、pipe5×1，共 11 路 |
| 实现方式 | **触发器阵列**（每个寄存器一个独立模块） | 例化 95 个 `ct_idu_rf_prf_gated_preg` |

> **为什么需要 96 个物理寄存器？**  
> RISC-V 架构有 32 个整数寄存器（x0~x31）。C910 为乱序执行维护一个空闲物理寄存器池。96 - 32 = 64 个额外物理寄存器是"重命名缓冲区"，确保在途（in-flight）指令数量足够多而不发生停顿。数字 96 与 `expand` 向量宽度 96 位完全对应。

### 2.2 端口总览

```
                    ┌─────────────────────────────────┐
                    │   ct_idu_rf_prf_pregfile         │
                    │                                   │
写入端口            │  ←─ iu_idu_ex2_pipe0_wb_preg_data│
pipe0 (整数EX2)     │  ←─ iu_idu_ex2_pipe0_wb_preg_vld │
                    │  ←─ iu_idu_ex2_pipe0_wb_preg_expand│
                    │                                   │
写入端口            │  ←─ iu_idu_ex2_pipe1_wb_preg_data│
pipe1 (整数EX2)     │  ←─ iu_idu_ex2_pipe1_wb_preg_vld │
                    │  ←─ iu_idu_ex2_pipe1_wb_preg_expand│
                    │                                   │
写入端口            │  ←─ lsu_idu_wb_pipe3_wb_preg_data│
pipe3 (LSU)         │  ←─ lsu_idu_wb_pipe3_wb_preg_vld │
                    │  ←─ lsu_idu_wb_pipe3_wb_preg_expand│
                    │                                   │
读端口              │  ←─ dp_prf_rf_pipe0_src0_preg[6:0]│
(pipe0 src0/src1)   │  ──→ prf_dp_rf_pipe0_src0_data    │
                    │  ←─ dp_prf_rf_pipe0_src1_preg[6:0]│
                    │  ──→ prf_dp_rf_pipe0_src1_data    │
                    │  ... (pipe1~pipe5 类似)           │
                    │                                   │
调试                │  ──→ idu_had_wb_data[63:0]        │
                    │  ──→ idu_had_wb_vld               │
                    └─────────────────────────────────┘
```

**读端口列表**（共 11 路）：

| 端口编号 | 信号名 | 服务管线 | 说明 |
|----------|--------|----------|------|
| 1 | `prf_dp_rf_pipe0_src0_data` | pipe0 src0 | 整数 ALU 流水线 0 第一源操作数 |
| 2 | `prf_dp_rf_pipe0_src1_data` | pipe0 src1 | 整数 ALU 流水线 0 第二源操作数 |
| 3 | `prf_xx_rf_pipe1_src0_data` | pipe1 src0 | 整数 ALU 流水线 1 第一源操作数 |
| 4 | `prf_xx_rf_pipe1_src1_data` | pipe1 src1 | 整数 ALU 流水线 1 第二源操作数 |
| 5 | `prf_dp_rf_pipe2_src0_data` | pipe2 src0 | 第三整数执行管线第一源操作数 |
| 6 | `prf_dp_rf_pipe2_src1_data` | pipe2 src1 | 第三整数执行管线第二源操作数 |
| 7 | `prf_dp_rf_pipe3_src0_data` | pipe3 src0 | LSU 基地址 |
| 8 | `prf_dp_rf_pipe3_src1_data` | pipe3 src1 | LSU 存储数据 |
| 9 | `prf_dp_rf_pipe4_src0_data` | pipe4 src0 | pipe4 第一源操作数 |
| 10 | `prf_dp_rf_pipe4_src1_data` | pipe4 src1 | pipe4 第二源操作数 |
| 11 | `prf_dp_rf_pipe5_src0_data` | pipe5 src0 | pipe5 第一源操作数（只有一个） |

> **为什么需要这么多读端口？**  
> C910 是多发射乱序处理器，每周期最多同时向多条执行管线发射指令。每条指令在 RF 阶段都需要并行读出两个源操作数。6 条管线（pipe0~pipe5）对整数寄存器堆共发起最多 11 路读请求，这些读必须在同一个周期完成，因此需要 11 个独立的组合读端口。SRAM 难以提供如此多读端口，故使用触发器（flip-flop）阵列。

### 2.3 expand 机制（物理寄存器号 → one-hot 独热码）

写回时，执行单元发出的是**二进制编码**的物理寄存器号（7 位，0~95），但 pregfile 内部用于选择写使能的是**96 位独热码**（one-hot）。转换工作在 RTL 层次上由 `ct_rtu_expand_96` 完成。

```verilog
// ct_rtu_expand_96：将 7 位物理寄存器号转换为 96 位独热码
// x_num[6:0] = 7'd5  -->  x_num_expand = 96'b...000100000
assign x_num_expand[0]  = (x_num[6:0] == 7'd0);
assign x_num_expand[1]  = (x_num[6:0] == 7'd1);
// ...
assign x_num_expand[95] = (x_num[6:0] == 7'd95);
```

在 pregfile 中（第 1685~1690 行）：

```verilog
// 3 write ports — 用独热码与有效位生成写使能向量
assign pipe0_wb_vld[95:0] = {96{iu_idu_ex2_pipe0_wb_preg_vld}}
                            & iu_idu_ex2_pipe0_wb_preg_expand[95:0];
assign pipe1_wb_vld[95:0] = {96{iu_idu_ex2_pipe1_wb_preg_vld}}
                            & iu_idu_ex2_pipe1_wb_preg_expand[95:0];
assign pipe3_wb_vld[95:0] = {96{lsu_idu_wb_pipe3_wb_preg_vld}}
                            & lsu_idu_wb_pipe3_wb_preg_expand[95:0];
```

然后，每个物理寄存器 N 对应的写使能（第 1692~1787 行）：

```verilog
assign preg0_wb_vld[2:0]  = {pipe3_wb_vld[0], pipe1_wb_vld[0], pipe0_wb_vld[0]};
assign preg1_wb_vld[2:0]  = {pipe3_wb_vld[1], pipe1_wb_vld[1], pipe0_wb_vld[1]};
// ... 以此类推直到 preg95
```

每个物理寄存器得到一个 3 位向量 `preg_N_wb_vld[2:0]`，分别对应 pipe0、pipe1、pipe3 三个写端口。这个向量被传入对应的门控触发器单元 `ct_idu_rf_prf_gated_preg`。

**为什么用独热码？**  
独热码把"物理寄存器号的比较"转换为"对应位置是否为1"，使每个寄存器单元的写使能判断退化为一个简单的单 bit 判断，逻辑层次最少，延迟最小。代价是需要额外的 expand 模块进行二进制到独热码的转换，但这个转换只做一次，所有物理寄存器单元共享结果。

### 2.4 寄存器阵列的实现：门控触发器单元 `ct_idu_rf_prf_gated_preg`

每个物理寄存器（preg1~preg95，共 95 个有效存储单元）都例化一个 `ct_idu_rf_prf_gated_preg` 模块（第 351~1677 行）。结构如下：

```verilog
module ct_idu_rf_prf_gated_preg(
  cp0_idu_icg_en,      // 模块级时钟门控使能（来自 CP0）
  cp0_yy_clk_en,       // 全局时钟使能
  forever_cpuclk,      // 基础时钟
  iu_idu_ex2_pipe0_wb_preg_data, // 写数据 pipe0
  iu_idu_ex2_pipe1_wb_preg_data, // 写数据 pipe1
  lsu_idu_wb_pipe3_wb_preg_data, // 写数据 pipe3
  pad_yy_icg_scan_en,  // 扫描测试模式
  x_reg_dout,          // 寄存器当前值输出
  x_wb_vld             // 3 位写使能（pipe3, pipe1, pipe0）
);
```

#### 2.4.1 门控时钟（ICG）

```verilog
// 第 63~73 行：门控时钟实例化
assign preg_clk_en = write_en;   // 仅在有写操作时开启时钟
gated_clk_cell  x_preg_gated_clk (
  .clk_in             (forever_cpuclk    ),
  .clk_out            (preg_clk          ),
  .external_en        (1'b0              ),
  .global_en          (cp0_yy_clk_en     ),
  .local_en           (preg_clk_en       ),   // 本地使能 = write_en
  .module_en          (cp0_idu_icg_en    ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);
```

**原理**：`preg_clk_en = write_en = |x_wb_vld[2:0]`。当没有任何写端口写入本物理寄存器时，`write_en = 0`，门控时钟单元关闭该寄存器的时钟，触发器不翻转，节省动态功耗。

这是大型寄存器堆最重要的功耗优化手段之一。95 个物理寄存器里，每个周期通常只有 1~3 个被写入，关闭其余 92~94 个寄存器的时钟，可节省寄存器堆 ~97% 的动态开关功耗。

#### 2.4.2 写入逻辑

```verilog
// 第 85~98 行：三选一数据多路选择
assign write_en = |x_wb_vld[2:0];
always @(...) begin
  case (x_wb_vld[2:0])
    3'b001 : write_data[63:0] = iu_idu_ex2_pipe0_wb_preg_data[63:0]; // pipe0
    3'b010 : write_data[63:0] = iu_idu_ex2_pipe1_wb_preg_data[63:0]; // pipe1
    3'b100 : write_data[63:0] = lsu_idu_wb_pipe3_wb_preg_data[63:0]; // pipe3
    default: write_data[63:0] = {64{1'bx}};  // 不会同时两个写同一寄存器
  endcase
end
```

**为什么 default 是 X？**  
重命名机制保证同一物理寄存器在同一周期只被一个写端口写入（功能正确性约束）。如果出现两个写端口同时有效且目标相同，说明重命名逻辑存在 bug，输出 X 可在仿真中立即暴露问题。

#### 2.4.3 寄存器存储

```verilog
// 第 104~111 行：触发器存储
always @(posedge preg_clk)   // 门控后的时钟
begin
  if(write_en)
    reg_dout[63:0] <= write_data[63:0];
  else
    reg_dout[63:0] <= reg_dout[63:0];  // 保持（时钟已门控，此句理论上不触发）
end
assign x_reg_dout[63:0] = reg_dout[63:0];
```

每个物理寄存器是 64 位 D 触发器，在门控时钟上升沿锁存写入数据。

### 2.5 特殊寄存器：preg0 永远为零

```verilog
// 第 344~345 行：preg0 硬连线为 0
//treat preg0 as constant 0
assign preg0_reg_dout[63:0] = 64'b0;
```

**原理**：RISC-V 的 x0 寄存器永远为 0，且不可写。在重命名时，x0 始终映射到物理寄存器 0（preg0）。pregfile 将 preg0 的输出硬编码为全 0，而不为其例化 `gated_preg` 单元——这样既节省了触发器资源，也保证了 x0 不可能被意外修改。

注意：`preg0_wb_vld` 被标注为 `nonport`（第 344 行注释），说明不会有写使能信号连接到 preg0，硬件层面阻止了对 preg0 的写操作。

### 2.6 读出逻辑：多路组合逻辑选择器

每个读端口都是一个独立的大型组合多路选择器（case 语句）。以 pipe0 src0（Read Port 1）为例（第 1806~2007 行）：

```verilog
// 敏感列表：所有 96 个寄存器的输出及地址信号
always @( preg0_reg_dout[63:0] or preg1_reg_dout[63:0] or ...
       or dp_prf_rf_pipe0_src0_preg[6:0])
begin
  case (dp_prf_rf_pipe0_src0_preg[6:0])
    7'd0   : prf_dp_rf_pipe0_src0_data[63:0] = preg0_reg_dout[63:0];  // 返回 0
    7'd1   : prf_dp_rf_pipe0_src0_data[63:0] = preg1_reg_dout[63:0];
    // ... 对应 7'd2 到 7'd95
    7'd95  : prf_dp_rf_pipe0_src0_data[63:0] = preg95_reg_dout[63:0];
    default: prf_dp_rf_pipe0_src0_data[63:0] = {64{1'bx}};
  endcase
end
```

11 个读端口对应 11 段几乎完全相同的 case 语句，每段都遍历全部 96 个物理寄存器。这是典型的"分布式读"架构：所有物理寄存器的值同时广播到读端口，读端口用 case 语句选出目标值。

**读操作是纯组合逻辑（无寄存器）**，在时钟边沿之前完成，数据在当前周期即可被执行单元使用。

### 2.7 调试端口

```verilog
// 第 1792~1799 行：HAD 调试访问
assign idu_had_wb_vld = rtu_yy_xx_dbgon
                        && (iu_idu_ex2_pipe0_wb_preg_vld
                         || iu_idu_ex2_pipe1_wb_preg_vld
                         || lsu_idu_wb_pipe3_wb_preg_vld);
assign idu_had_wb_data[63:0] =
           {64{iu_idu_ex2_pipe0_wb_preg_vld}} & iu_idu_ex2_pipe0_wb_preg_data[63:0]
         | {64{iu_idu_ex2_pipe1_wb_preg_vld}} & iu_idu_ex2_pipe1_wb_preg_data[63:0]
         | {64{lsu_idu_wb_pipe3_wb_preg_vld}} & lsu_idu_wb_pipe3_wb_preg_data[63:0];
```

仅当 `rtu_yy_xx_dbgon`（调试模式激活）时，`idu_had_wb_vld` 有效，用于向硬件调试器（HAD）报告每次寄存器写回事件，支持单步调试和寄存器监视。

---

## 3. 浮点物理寄存器堆 `ct_idu_rf_prf_fregfile`

### 3.1 与整数 PRF 的差异

| 维度 | 整数 pregfile | 浮点 fregfile |
|------|---------------|---------------|
| 物理寄存器数量 | 96（preg0~95） | 64（vreg0~63） |
| 寄存器号位宽 | 7 位（`[6:0]`） | **6 位**（`[5:0]`） |
| 寄存器位宽 | 64 位 | 64 位（相同） |
| 写端口 | pipe0（整数）, pipe1（整数）, pipe3（LSU） | **pipe6（VFPU）, pipe7（VFPU）, pipe3（LSU）** |
| 读端口数 | 11 | **7** |
| 单元模块 | `ct_idu_rf_prf_gated_preg` | `ct_idu_rf_prf_gated_vreg` |
| 门控时钟结构 | 每个寄存器独立门控 | **两级门控**（模块级 + 寄存器级） |

### 3.2 寄存器数量与命名

浮点物理寄存器命名为 `vreg0` ~ `vreg63`，共 64 个（对应 6 位地址空间）。RISC-V 有 32 个架构浮点寄存器（f0~f31），64 - 32 = 32 个额外物理寄存器用于重命名缓冲。

> **注意命名约定**：C910 将浮点寄存器命名为 `vreg`（而非 `freg`），这是因为浮点与向量指令共享同一套物理寄存器命名空间（RISC-V 的 F/D 扩展和 V 扩展在某些场景下共享 f0~f31）。

### 3.3 写端口：来自 VFPU 和 LSU

```verilog
// 第 1169~1175 行：写使能生成
// 3 write ports
assign pipe6_wb_vld[63:0] = {64{vfpu_idu_ex5_pipe6_wb_vreg_vld}}
                            & vfpu_idu_ex5_pipe6_wb_vreg_expand[63:0];
assign pipe7_wb_vld[63:0] = {64{vfpu_idu_ex5_pipe7_wb_vreg_vld}}
                            & vfpu_idu_ex5_pipe7_wb_vreg_expand[63:0];
assign pipe3_wb_vld[63:0] = {64{lsu_idu_wb_pipe3_wb_vreg_vld}}
                            & lsu_idu_wb_pipe3_wb_vreg_expand[63:0];
```

- **pipe6/pipe7**：浮点/向量执行单元（VFPU），在 EX5 阶段（第 5 级执行）完成写回；
- **pipe3**：LSU 加载单元，浮点 load 指令（FLD/FLW 等）通过此端口写回。

**为什么浮点写回比整数晚（EX5 vs EX2）？**  
浮点运算（乘加、除法等）通常需要多个流水级，VFPU 执行延迟远大于整数 ALU，故写回发生在 EX5 而非 EX2。

### 3.4 读端口：服务 VFPU 和 LSU-FP

**7 个读端口**：

| 端口 | 管线 | 说明 |
|------|------|------|
| pipe6 srcv0/srcv1/srcv2 | VFPU pipe6 | 浮点指令最多有 3 个源（如 FMA：rs1, rs2, rs3） |
| pipe7 srcv0/srcv1/srcv2 | VFPU pipe7 | 同上 |
| pipe5 srcv0 | pipe5 | 浮点/向量辅助管线，1 个源 |

> **为什么浮点需要 3 个源读端口（srcv0/srcv1/srcv2）？**  
> RISC-V F/D 扩展的融合乘加（FMA）指令格式为 `fmadd rd, rs1, rs2, rs3`，需要同时读出 3 个源浮点寄存器。整数 ALU 最多只有 2 个源，不需要第三个读端口。

### 3.5 两级门控时钟

fregfile 相比 pregfile 多了一层**模块级顶部门控**：

```verilog
// 第 245~257 行：顶部模块级门控（一次性控制所有 vreg 时钟路径）
assign vreg_clk_en = vfpu_idu_ex5_pipe6_wb_vreg_vld
                     || vfpu_idu_ex5_pipe7_wb_vreg_vld
                     || lsu_idu_wb_pipe3_wb_vreg_vld;
gated_clk_cell  x_vreg_gated_clk (
  .clk_in  (forever_cpuclk),
  .clk_out (vreg_top_clk),
  .local_en(vreg_clk_en),
  ...
);
```

再由 `vreg_top_clk` 作为输入传给每个 `ct_idu_rf_prf_gated_vreg` 内的寄存器级门控：

```verilog
// gated_vreg 内部：第 68~76 行
gated_clk_cell  x_vreg_gated_clk (
  .clk_in  (vreg_top_clk),   // 已由顶层门控过的时钟
  .clk_out (vreg_clk),
  .local_en(vreg_clk_en),    // = write_en（本寄存器有写才开）
  ...
);
```

**两级门控的好处**：  
- 第一级（模块级）：只要本周期没有任何浮点写回，整个 fregfile 的时钟树完全关闭，64 个寄存器和相关缓冲树都不翻转；  
- 第二级（寄存器级）：在有写回的周期，只有目标物理寄存器的时钟开启。  
这种层次化门控显著减少了时钟树的翻转功耗，在浮点指令密度低时尤其有效（整数程序运行时 fregfile 几乎不消耗动态功耗）。

---

## 4. 向量物理寄存器堆 `ct_idu_rf_prf_vregfile`

### 4.1 文件小的原因

`ct_idu_rf_prf_vregfile.v` 仅有 293 行，其实际逻辑几乎为空：

```verilog
// 第 279~287 行：全部输出直接硬连为 0
assign prf_dp_rf_pipe5_srcv0_vreg_data[63:0] = 64'b0;
assign prf_dp_rf_pipe6_srcv0_vreg_data[63:0] = 64'b0;
assign prf_dp_rf_pipe6_srcv1_vreg_data[63:0] = 64'b0;
assign prf_dp_rf_pipe6_srcv2_vreg_data[63:0] = 64'b0;
assign prf_dp_rf_pipe6_srcvm_vreg_data[63:0] = 64'b0;
assign prf_dp_rf_pipe7_srcv0_vreg_data[63:0] = 64'b0;
// ...（共 9 路全为 0）
```

文件中保留了大量注释掉的 `&Instance` 模板（第 99~225 行），说明此模块原本设计为例化 64 个 `ct_idu_rf_prf_gated_vreg` 单元，并实现多路读，但目前**未被激活**。

### 4.2 为什么向量 PRF 是空实现

C910 的向量扩展（RVV）读寄存器逻辑与浮点寄存器**共享**物理寄存器堆。具体地：
- 向量指令的浮点源操作数通过 fregfile 读取（仅低 64 位，即 f 寄存器宽度）；
- `vregfile` 的接口（9 路读端口，包含额外的 mask 端口 `srcvm`）为更宽向量操作（如 LMUL > 1 的情况）预留了扩展点；
- 当前实现中，全部读出恒为 0，意味着向量操作数依赖旁路（forwarding）或由上游已在 fregfile 里读好的值提供。

**注意 srcvm 信号**：

```
dp_prf_rf_pipe6_srcvm_vreg   // mask 寄存器（向量操作的掩码源）
dp_prf_rf_pipe7_srcvm_vreg
```

这两个端口对应 RISC-V V 扩展的向量掩码寄存器 `v0`（充当 mask），是 vregfile 相对于 fregfile 新增的接口，但在当前实现中也输出全 0。

---

## 5. 浮点异常状态物理寄存器堆 `ct_idu_rf_prf_eregfile`

### 5.1 E 寄存器是什么

`ereg`（Exception Register，异常状态寄存器）是 C910 为支持 RISC-V 浮点异常状态标志（FFLAGS）的乱序提交而引入的特殊物理寄存器。

RISC-V 浮点控制状态寄存器 `fcsr` 包含：
- `fflags`（5 位）：NV（非法操作）、DZ（除以零）、OF（上溢）、UF（下溢）、NX（不精确）
- `frm`（3 位）：舍入模式

每条浮点指令可能产生异常标志，这些标志需要**累积**（OR 操作）到 FESR（Floating-point Exception Status Register）。在乱序执行中，指令不按程序顺序完成，但 `fflags` 的更新必须按程序顺序提交——这正是 ereg 存在的意义。

**eregfile 的核心思路**：
1. 每条在途浮点指令被分配一个物理 ereg（共 32 个，ereg0~ereg31）；
2. VFPU 执行完成后，把该指令产生的异常标志（5 位）写入对应的 ereg；
3. 指令**提交（retire）**时，RTU 通知 eregfile 哪些 ereg 已释放；
4. eregfile 把所有已提交指令的 ereg 内容 OR 聚合，更新到 CP0 的 FESR。

### 5.2 基本参数

| 参数 | 值 | 说明 |
|------|----|------|
| 物理 ereg 数量 | **32**（ereg0~ereg31） | 5 位地址 |
| 位宽 | **6 位** | 5 位异常标志 + 1 位扩展（精确性标志） |
| 写端口 | **2** | pipe6（VFPU）、pipe7（VFPU） |
| 读端口 | **聚合读（OR tree）** | 所有已提交 ereg 的 OR 操作 |

注意：ereg 只有 **2** 个写端口（pipe6 和 pipe7），没有 pipe3，因为 LSU 浮点加载不产生异常标志。

### 5.3 写入逻辑

```verilog
// 第 707~743 行：写使能生成（通过独热码扩展）
assign pipe6_wb_vld[31:0] = {32{vfpu_idu_ex5_pipe6_wb_ereg_vld}}
                            & vfpu_idu_ex5_pipe6_wb_ereg_expand[31:0];
assign pipe7_wb_vld[31:0] = {32{vfpu_idu_ex5_pipe7_wb_ereg_vld}}
                            & vfpu_idu_ex5_pipe7_wb_ereg_expand[31:0];

assign ereg0_wb_vld[1:0]  = {pipe7_wb_vld[0], pipe6_wb_vld[0]};
// ...
```

写数据是 6 位的异常标志（`vfpu_idu_ex5_pipe6/7_wb_ereg_data[5:0]`）。

在 `ct_idu_rf_prf_gated_ereg` 中（第 89~91 行）：

```verilog
// 两写端口合并：直接或操作（同一指令不会从两个 VFPU 管线同时写同一 ereg）
assign write_data[5:0] =
    {6{x_wb_vld[0]}} & vfpu_idu_ex5_pipe6_wb_ereg_data[5:0]
  | {6{x_wb_vld[1]}} & vfpu_idu_ex5_pipe7_wb_ereg_data[5:0];
```

### 5.4 提交与聚合读取

```verilog
// eregfile 第 791~855 行：
// 1. 接受 RTU 发来的提交信号（已提交并释放的 ereg bitmap）
assign ereg0_retired_released_wb  = fesr_retired_released_wb_ff[0];
// ...

// 2. 每个 ereg 输出时与"已提交"位相与
//    (gated_ereg 第 111 行)
assign x_acc_reg_dout[5:0] = {6{x_retired_released_wb}} & reg_dout[5:0];

// 3. 所有 ereg 的条件输出做 OR 聚合（第 824~855 行）
assign fesr_acc[5:0] = ereg0_acc_reg_dout[5:0]
                     | ereg1_acc_reg_dout[5:0]
                     | ... | ereg31_acc_reg_dout[5:0];
```

**逻辑流程**：只有当指令正式提交（retire）时，`x_retired_released_wb` 信号才置 1，该 ereg 的值才参与 OR 聚合。未提交的指令（可能被流水线冲刷）的 ereg 值为 0，不影响 FESR。

### 5.5 FESR 更新逻辑

```verilog
// 第 857~861 行：构造完整 FESR 累积值
assign fesr_acc_with_fcr[4:0] = fesr_acc[4:0];    // NV/DZ/OF/UF/NX
assign fesr_acc_with_fcr[5]   = |fesr_acc_with_fcr[4:0]; // "有异常"汇总位
assign fesr_acc_with_fcr[6]   = fesr_acc[5];        // 额外精度位

assign idu_cp0_fesr_acc_updt_val[6:0] = fesr_acc_with_fcr[6:0];

// 第 905~906 行：更新有效信号（只有已提交才发）
assign idu_cp0_fesr_acc_updt_vld = fesr_acc_updt_vld_ff
                                   && (|fesr_retired_released_wb_ff[31:0]);
```

`idu_cp0_fesr_acc_updt_val` 发往 CP0，由 CP0 完成对 `fcsr.fflags` 字段的实际更新（OR 写入）。

---

## 6. 门控时钟原理（gated_preg / gated_vreg / gated_ereg）

### 6.1 三种门控单元对比

| 特性 | gated_preg | gated_vreg | gated_ereg |
|------|-----------|-----------|-----------|
| 时钟源 | `forever_cpuclk`（直接） | `vreg_top_clk`（模块级门控后） | `ereg_top_clk`（模块级门控后） |
| 写使能宽度 | 3 位（pipe0/1/3） | 3 位（pipe6/7/3） | 2 位（pipe6/7） |
| 数据位宽 | 64 位 | 64 位 | 6 位 |
| 复位 | 无异步复位 | 无异步复位 | **有异步复位**（cpurst_b） |
| 有效输出 | 直接输出 `reg_dout` | 直接输出 `reg_dout` | 条件输出（与 retired_wb 位相与） |

**gated_ereg 需要异步复位**，是因为浮点异常标志必须在复位时清零（否则上电后 FESR 状态不确定，可能导致错误的浮点异常报告）。整数和浮点数据寄存器无需异步复位（复位后这些寄存器的值由程序初始化确定）。

### 6.2 gated_clk_cell 门控机制

C910 使用标准的集成时钟门控单元（ICG，Integrated Clock Gating），其逻辑等效为：

```
clk_out = clk_in AND (local_en OR external_en OR !global_en_active)
```

实际实现通常是：
```
latched_en = latch(enable, clk_low_phase)  // 在时钟低电平锁存使能
clk_out    = clk_in AND latched_en
```

使用锁存器（latch）而非寄存器锁存使能，是为了避免引入建立时间冲突：使能信号需要在时钟上升沿前稳定，而不是等到下一个上升沿。

**控制层次**：

```
pad_yy_icg_scan_en  ─────────────────────────┐
                                              ↓
cp0_yy_clk_en (global_en) ──────────────→ gated_clk_cell → clk_out
cp0_idu_icg_en (module_en) ──────────────↗
preg_clk_en (local_en = write_en) ───────↗
```

- `pad_yy_icg_scan_en`：DFT 扫描模式下强制开启所有时钟门，确保扫描链可以传输；
- `cp0_yy_clk_en`：全局时钟使能，CPU 功耗控制寄存器控制；
- `cp0_idu_icg_en`：IDU 模块级时钟使能，更细粒度的功耗控制；
- `local_en`（`write_en`）：最细粒度，每个寄存器独立控制。

---

## 7. expand 机制详解

`expand` 是 C910 PRF 写入架构的核心设计决策之一。

### 7.1 转换关系

```
  写回端口物理寄存器号（二进制）    expand 模块          one-hot 独热码
  iu_idu_ex2_pipe0_wb_preg[6:0] → ct_rtu_expand_96 → pipe0_expand[95:0]
         7'd5                  →                   → 96'h...0000_0010_0000
```

### 7.2 为什么在模块外部做 expand

观察信号来源：`iu_idu_ex2_pipe0_wb_preg_expand` 是从 **IU（Integer Unit）** 传入 pregfile 的，说明 expand 转换发生在 IU 侧，而非 pregfile 内部。这样设计的原因：

1. **减少 pregfile 输入端口**：如果在 pregfile 内部做 expand，需要输入 7 位地址，pregfile 内部完成 decoder。但当前方案已经输入了 96 位独热码；
2. **展开后可并行使用**：同一个 expand 结果可以同时用于 PRF 写使能、RAT 释放、scoreboard 更新等多个下游逻辑，由上游模块做一次 expand 后广播给所有接收方，避免重复计算；
3. **时序优化**：expand 是纯组合逻辑，可以和物理寄存器号的计算并行进行，不在关键路径上。

### 7.3 写入选择的完整路径

```
IU 写回：
  wb_preg[6:0] ──→ ct_rtu_expand_96 ──→ wb_preg_expand[95:0]
                                              │
                                              ↓
                               pipe0_wb_vld[95:0] = {96{vld}} & expand[95:0]
                                              │
                               preg_N_wb_vld[2] = pipe0_wb_vld[N]
                                              │
                               传入 gated_preg 单元的 x_wb_vld[0]
```

---

## 8. 模块间连接关系总览

```
                           重命名 (RAT)
                                │
                   psrc0/psrc1[6:0] (物理寄存器号)
                                │
             ┌──────────────────┴────────────────────┐
             │           发射队列 (IQ)                 │
             │  保存等待发射指令的 psrc 字段            │
             └──────────────────┬────────────────────┘
                                │ 发射时传出
                                │ dp_prf_rf_pipe*_src*_preg[6:0]
                                ↓
          ┌────────────────────────────────────────────────┐
          │                 RF 阶段                         │
          │  ┌───────────────┐  ┌──────────────┐           │
          │  │  pregfile     │  │  fregfile    │           │
          │  │  (96×64b)     │  │  (64×64b)    │           │
          │  └───────┬───────┘  └──────┬───────┘           │
          └──────────┼────────────────┼───────────────────┘
                     │                │
           src_data[63:0]      srcv_data[63:0]
                     │                │
                     ↓                ↓
          ┌──────────────────────────────────┐
          │           EX 执行单元            │
          │  IU (pipe0/1), MUL, LSU, VFPU   │
          └────────────────┬─────────────────┘
                           │ 写回
          ┌────────────────┴─────────────────┐
          │          写回端口                 │
          │  pipe0: IU EX2 → pregfile        │
          │  pipe1: IU EX2 → pregfile        │
          │  pipe3: LSU    → pregfile/fregfile│
          │  pipe6: VFPU EX5 → fregfile/ereg │
          │  pipe7: VFPU EX5 → fregfile/ereg │
          └──────────────────────────────────┘
```

---

## 9. 关键设计总结

### 9.1 整体架构选择

C910 PRF 采用**触发器阵列（FF Array）**而非 SRAM，原因：
- 需要大量读端口（整数 11 路，浮点 7 路），SRAM 实现多读端口成本极高；
- 触发器阵列天然支持任意多路读（纯组合逻辑 case 语句），面积代价是线性增长；
- PRF 总存储量：整数 96×64=6144 位，浮点 64×64=4096 位，合计约 1280 字节，规模不大，适合 FF 实现。

### 9.2 写端口优先级

各 PRF 的写端口优先级（当多个写端口同时尝试写同一物理寄存器时，由重命名机制保证不会发生冲突，但 default 输出 X 作为安全保障）：

| 优先级 | 整数 | 浮点/向量 |
|--------|------|-----------|
| 1（bit[0]） | pipe0（整数 EX2） | pipe6（VFPU EX5） |
| 2（bit[1]） | pipe1（整数 EX2） | pipe7（VFPU EX5） |
| 3（bit[2]） | pipe3（LSU）       | pipe3（LSU FP）   |

### 9.3 x0/f0 等特殊寄存器处理

- **整数 x0（preg0）**：硬连线为 64'b0，不例化存储单元，不接受任何写入；
- **浮点 f0（vreg0）**：与普通物理寄存器相同，需要正常写入（浮点 f0 不是硬连零）；
- **ereg0**：有异步复位，上电清零，其余 ereg 同理。

### 9.4 功耗设计亮点

| 技术 | 应用位置 | 节省估算 |
|------|---------|---------|
| 寄存器级 ICG | 每个 gated_preg/vreg/ereg | 未写入的寄存器 ~100% 动态功耗 |
| 模块级顶部 ICG | fregfile/eregfile 顶层 | 整数程序运行时浮点整体关闭 |
| 扫描模式支持 | `pad_yy_icg_scan_en` 旁路所有 ICG | DFT 完整性保证 |

---

## 附录：信号命名规律

| 前缀 | 含义 |
|------|------|
| `dp_prf_rf_*` | DP（Dispatch 分派/RF 阶段）发给 PRF 的读地址 |
| `prf_dp_rf_*` | PRF 返回给 DP 的读数据 |
| `prf_xx_rf_*` | PRF 返回给其他模块（xx）的读数据 |
| `iu_idu_ex2_pipe0_wb_preg_*` | IU 整数单元 EX2 pipe0 写回信号 |
| `lsu_idu_wb_pipe3_wb_preg_*` | LSU 加载存储单元写回整数 PRF |
| `lsu_idu_wb_pipe3_wb_vreg_*` | LSU 加载存储单元写回浮点 PRF |
| `vfpu_idu_ex5_pipe6/7_wb_vreg_*` | VFPU 浮点单元 EX5 写回浮点 PRF |
| `vfpu_idu_ex5_pipe6/7_wb_ereg_*` | VFPU 写回浮点异常状态 PRF |
| `*_expand[N:0]` | 物理寄存器号的 one-hot 独热码展开 |
| `*_wb_vld` | 写回有效信号（1 bit 整体有效，N bit 为 per-register 使能） |
