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
| 实现方式 | **触发器阵列**：preg1~preg95 各一个存储单元，preg0 硬连 0 | 实际例化 95 个 `ct_idu_rf_prf_gated_preg` |

> **为什么需要 96 个物理寄存器？**  
> RISC-V 架构有 32 个整数寄存器（x0~x31），乱序重命名还需要额外版本保存尚未退休
> 的目的值。结构上，96 个物理编号比 32 个架构编号多 64 个槽位，并与 96-bit
> `expand` 写选择向量一致；但这 64 项不是一个独立、可直接等同 ROB 深度的
> “重命名缓冲区”。某时刻可分配多少项还取决于已提交映射、在途映射、释放时点和
> preg0 等规则，物理寄存器池耗尽仍可能造成 rename stall，不能写成“保证不发生
> 停顿”。

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
> 当前 RTL 为 pipe0~pipe5 暴露 11 组彼此独立的组合读地址/数据接口，所以在同一
> RF 组合窗口中可以同时形成最多 11 个整数源读结果。并非每条指令都使用两个
> 整数源，pipe5 也只有一个这里列出的整数读口；实际同拍活动数还受发射类型和端口
> 仲裁限制。生成 RTL 确实采用触发器阵列加 11 组大 MUX，而不是多端口 SRAM。
> “因为目标 SRAM 宏无法满足 11 读口而选择触发器”是合理的实现动机，但宏能力、
> 面积和时序优劣仍需存储器编译器与综合结果证明，不能只从 RTL 反推为唯一原因。

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
独热码把每个存储单元的本地写选择变成“该端口 expand 向量的第 N 位是否为 1”，
避免在 95 个单元内部重复做 7-bit 等值比较。代价是上游要形成 96-bit expand
向量并进行高扇出布线。RTL 能证明这种逻辑分解，不能单独证明它在目标工艺中
“逻辑层次最少、延迟一定最小”；这需要综合后的关键路径、扇出修复和布线结果。

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

**原理**：`preg_clk_en = write_en = |x_wb_vld[2:0]`。因此在功能模式且全局、模块
和扫描控制允许门控生效时，没有任何写端口命中本物理寄存器，就不会由该
`local_en` 请求打开 `preg_clk`。这降低该存储触发器和局部时钟树发生无用翻转的
机会；扫描使能、全局/模块开钟策略以及行为级 ICG 模型都可能覆盖本地条件，所以
不能把 `write_en=0` 绝对表述成“物理时钟必然关闭、整个单元完全无动态功耗”。

这是大型寄存器堆常用的功耗优化手段。当前结构让未命中写使能的寄存器单元不翻转
本地时钟；实际动态功耗下降比例还取决于时钟树、读选择逻辑、数据活动率和工艺库，
应以门级功耗分析为准。

#### 2.4.2 写入逻辑

```verilog
// 第 85~98 行：三选一数据多路选择
assign write_en = |x_wb_vld[2:0];
always @(...) begin
  case (x_wb_vld[2:0])
    3'b001 : write_data[63:0] = iu_idu_ex2_pipe0_wb_preg_data[63:0]; // pipe0
    3'b010 : write_data[63:0] = iu_idu_ex2_pipe1_wb_preg_data[63:0]; // pipe1
    3'b100 : write_data[63:0] = lsu_idu_wb_pipe3_wb_preg_data[63:0]; // pipe3
    default: write_data[63:0] = {64{1'bx}};  // 0 路或非 one-hot 多路命中
  endcase
end
```

**为什么 default 是 X？**  
叶子单元没有优先级编码器，而是假定 `x_wb_vld` 为 zero-hot 或 one-hot。全 0 时
`write_en=0`、存储边沿通常不发生，所以 X 数据不被采样；两位及以上为 1 时
`write_en=1` 而数据变 X，可把协议冲突传播到仿真结果。维持 one-hot 需要上游
重命名不重复分配尚未释放的物理目的、各执行管线正确携带目的号，并正确生成互斥
writeback valid；它是跨模块不变量，不是这个 `case` 自己“保证”的事实。出现
多写同号应视为严重协议违例，但是否立刻可见还取决于四态仿真和该值后续是否被
观察。

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

**本模块能确认的事实**：`preg0_reg_dout` 被硬连为 64'b0，且 preg0 没有 `gated_preg` 存储实例，所以对地址 0 的 PRF 读取恒为 0，写回 expand 的 bit0 也没有可更新的存储体。RISC-V 架构 x0 应读取为 0；“重命名逻辑始终把每个 x0 源映射到 preg0”还需要在 RAT/重命名模块中单独核对，不能仅由 pregfile 反推。

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

11 个读端口对应 11 段几乎相同的 96 项 `case` 选择。RTL 语义是每个读地址独立选择一个寄存器值；综合器可能把它实现成多级 MUX、共享局部逻辑并插入缓冲，不能把行为级 `case` 直接等同于版图上“所有寄存器值无条件广播到每个端口”的唯一物理拓扑。

**读选择是纯组合逻辑（本模块内无输出寄存器）**。地址变化后，数据经过 96:1
选择网络传播到 RF 数据通路；其可见时间由组合延迟决定，消费者必须在约定的 RF
采样边沿满足时序。它支持“同一 RF 周期形成读值”，不等于地址变化瞬间零延迟，
也不等于执行单元在任意时刻都可无条件使用。

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

> **注意命名约定**：`ct_idu_rf_prf_fregfile.v` 内部把 64 项浮点物理寄存器的数据单元命名为 `vreg0`~`vreg63`。这是 RTL 的历史命名，不能解释为 RISC-V F/D 与 V 共享架构寄存器。F/D 的 f0~f31 与 V 的 v0~v31 是两套独立架构状态；RTL 也分别提供 fregfile 与 vregfile 模块。

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

**为什么接口名是 EX5，而整数接口名是 EX2？**
这里描述的是两条 PRF 写端口的接口阶段：浮点结果由 VFPU 的 EX5 接口写回，普通整数
结果由 IU 的 EX2 接口写回。它说明两类执行通路的流水组织不同，但不能据此断言每条
浮点指令的延迟都相同；除法、乘加、转换和简单搬移可以有不同的有效路径。

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

**两级本地使能的准确含义**：

- 顶层 `vreg_clk_en` 在三路浮点/LSU 写回有效均为 0 时不提出本地时钟请求；
- 每项 `vreg_clk_en=|x_wb_vld`，只为本项收到写选择时提出第二级本地请求；
- `gated_clk_cell` 的使能方程是
  `global_en && (module_en || local_en) || external_en`，扫描使能另接技术 ICG 的 `TE`。
  因此 `module_en=1` 时可以覆盖 `local_en=0`，不能写成“只有目标项时钟必然开启”；
- 更关键的是，公开 `gated_clk_cell.v` 只有定义 `C910_USE_TSMC28_ICG` 时才实例化
  `CKLNQD4BWP12T40P140`；未定义该宏时直接 `assign clk_out=clk_in`。所以普通 RTL
  仿真中即使本地使能为 0，门控输出也可能继续跟随输入时钟。

这套层次结构表达了实现时减少时钟活动的意图，但是否真正插入技术 ICG、时钟树哪些分支停止以及功耗收益多少，必须结合编译宏、综合网表和功耗报告判断。不能仅凭本地使能在整数程序中为 0，就断言 fregfile “几乎无动态功耗”。

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

### 4.2 当前向量 PRF 是裁剪/占位实现

RTL 只足以证明以下事实：

- `vregfile` 保留 9 路读接口，包括 mask 源 `srcvm`；
- 所有读数据输出均被常量赋为 0；
- 文件里的 64 项寄存器实例是生成器注释，不会参与综合；
- `ct_idu_ir_vrt.v` 同样是常量输出的占位模块。

因此不能把该现象解释为"向量与浮点共享 PRF"，也不能认为旁路网络足以替代完整向量
PRF。更准确的结论是：当前公开配置裁剪了这部分有效向量数据通路；若要研究完整 RVV
执行，必须先确认采用的商业/内部配置是否另有实现。

**注意 srcvm 信号**：

```
dp_prf_rf_pipe6_srcvm_vreg   // mask 寄存器（向量操作的掩码源）
dp_prf_rf_pipe7_srcvm_vreg
```

这两个端口对应 RISC-V V 扩展的向量掩码寄存器 `v0`（充当 mask），是 vregfile 相对于 fregfile 新增的接口，但在当前实现中也输出全 0。

---

## 5. 浮点异常状态物理寄存器堆 `ct_idu_rf_prf_eregfile`

### 5.1 E 寄存器是什么

`ereg` 是 C910 为支持 `fflags` 等状态贡献的推测生成和精确提交而引入的特殊
物理版本。它不保存浮点数值，也不保存 `fclass/fmv.x.*` 的整数结果。

RISC-V 浮点控制状态寄存器 `fcsr` 包含：
- `fflags`（5 位）：NV（非法操作）、DZ（除以零）、OF（上溢）、UF（下溢）、NX（不精确）
- `frm`（3 位）：舍入模式

部分浮点指令可能产生异常标志，这些标志需要按位或累积到体系结构可见状态。
在乱序执行中，指令不按程序顺序完成，错误路径也可能短暂执行；状态贡献必须
经过 RTU 的退休/版本过滤后才能送给 CP0。这正是 EREG 物理化的意义。

**eregfile 的核心思路**：
1. 每个置 `dste_vld` 的在途操作分配一个物理 EREG（共 32 个，ereg0~ereg31），并非每条浮点指令都无条件分配；
2. VFPU 执行完成后，把该指令产生的异常标志（5 位）写入对应的 ereg；
3. RTU 根据该物理版本的退休、释放和写回状态，产生本次允许累积的选择位图；
4. EREG 文件仅把这次被选择项的内容按位或，形成一次 CP0 更新值。它不是把所有历史已提交项永久并在组合树上。

### 5.2 基本参数

| 参数 | 值 | 说明 |
|------|----|------|
| 物理 ereg 数量 | **32**（ereg0~ereg31） | 5 位地址 |
| 位宽 | **6 位** | `[4:0]` 为五个浮点异常标志；第 6 位是保留的额外状态通路，当前 pipe6/7 写回将其置 0 |
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

写数据接口为 6 位（`vfpu_idu_ex5_pipe6/7_wb_ereg_data[5:0]`）。其中 `[4:0]`
承载 `NV/DZ/OF/UF/NX`；当前 `ct_vfpu_rbus.v` 将两个端口的 `[5]` 显式置 0，
所以不能仅凭总线宽度把它解释成当前会动态产生的“精度标志”。

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

**逻辑流程**：这里的选择条件比“退休时恒置 1”更精确。处于 `ALLOC` 的项在
对应 IID 退休且结果此前已写回或当拍写回时可以进入累积；处于
`RETIRE/RELEASE` 的项只在新的写回到达时进入累积，以避免重复提交同一份粘滞
标志。未被 RTU 选择的物理项经门控后输出 0，不参与本次 OR。

### 5.5 FESR 更新逻辑

```verilog
// 第 857~861 行：构造完整 FESR 累积值
assign fesr_acc_with_fcr[4:0] = fesr_acc[4:0];    // NV/DZ/OF/UF/NX
assign fesr_acc_with_fcr[5]   = |fesr_acc_with_fcr[4:0]; // "有异常"汇总位
assign fesr_acc_with_fcr[6]   = fesr_acc[5];        // 额外状态通路；当前 VFPU 写回源将原始 bit5 置 0

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

典型无毛刺 ICG 的概念模型通常是：
```
latched_en = latch(enable, clk_low_phase)  // 在时钟低电平锁存使能
clk_out    = clk_in AND latched_en
```

这段伪代码用于解释 ICG 原理，不是当前公开 `gated_clk_cell.v` 的行为级实现。使用
`C910_USE_TSMC28_ICG` 时，无毛刺锁存细节封装在技术库单元中；未使用该宏时，
`clk_out` 直接等于 `clk_in`。因此不能在 RTL 波形中凭空期待一个可见的低电平锁存器。

**控制层次**：

```
pad_yy_icg_scan_en  ─────────────────────────┐
                                              ↓
cp0_yy_clk_en (global_en) ──────────────→ gated_clk_cell → clk_out
cp0_idu_icg_en (module_en) ──────────────↗
preg_clk_en (local_en = write_en) ───────↗
```

- `pad_yy_icg_scan_en`：在 TSMC28 技术单元分支中接到 `TE`；它是否覆盖“所有”门控点，需检查每个实例是否连接该信号；
- `cp0_yy_clk_en`：连接 `global_en`，是使能方程外层条件；
- `cp0_idu_icg_en`：连接 `module_en`，在方程中与 `local_en` 做 OR，而不是继续与 local 做 AND；
- `local_en`：本实例的功能性请求，例如某个物理寄存器的 `write_en`；
- `external_en`：这些 PRF 门控实例固定为 0，其他模块可能有不同连接。

在未定义 `C910_USE_TSMC28_ICG` 的默认 RTL 分支中，上述使能不改变 `clk_out`；它们主要保留综合到目标 ICG 配置时的控制意图。

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

`iu_idu_ex2_pipe0_wb_preg_expand` 等 96 位信号从 IU/LSU 侧进入 pregfile，能确认
二进制地址到 one-hot 的转换不在 pregfile 内部完成。其直接结构效果是：

1. pregfile 内每个物理项只需取 one-hot 向量中的对应 bit，再与写回总有效组合；
2. 代价是模块边界要传输 96 位 expand，而不是 7 位二进制地址，所以不能称为“减少输入端口”；
3. 上游是否把同一 expand 复用于 RAT、scoreboard 等模块，必须查看那些具体连接，不能由 pregfile 输入推断；
4. decoder 是否与其他逻辑并行、是否离开关键路径，需要综合/STA 证明。RTL 只能说明 decoder 被放在模块边界上游。

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

当前生成 RTL 的整数和浮点 PRF 采用**触发器阵列 + 组合读选择**，而不是 SRAM 宏。
它分别暴露 11 路和 7 路组合读口；多读口需求通常是采用 FF 阵列的重要原因，但“目标
SRAM 一定更差”仍需具体宏库比较。仅按有效数据位计算，整数 96×64 位、浮点
64×64 位，合计 10240 位即 1280 字节；该数字不含门控、写选择、MUX、布线和 EREG
开销，因此不能当作物理面积。

### 9.2 写端口编码与 one-hot 协议

preg/freg 单项使用普通 `case(x_wb_vld)`，只定义单 bit 有效的三种编码，没有优先级
分支。全零和多 bit 有效都进入 `default`，数据成为 X；其中全零时 `write_en=0`，不会
锁存 X，多 bit 有效时 `write_en=1`，会把 X 写入并暴露协议违例。避免多写冲突依赖
重命名目的号生命周期、各写回端口有效窗口和取消协议共同成立，不是由重命名一项机制
或本地 `case` 单独保证。

| one-hot 位 | 整数数据源 | 浮点数据源 |
|------------|------------|------------|
| bit[0] | pipe0（整数 EX2） | pipe6（VFPU EX5） |
| bit[1] | pipe1（整数 EX2） | pipe7（VFPU EX5） |
| bit[2] | pipe3（LSU） | pipe3（LSU FP） |

### 9.3 x0/f0 等特殊寄存器处理

- **整数 preg0**：硬连线为 64'b0，不例化存储单元；它为架构 x0 的零值实现提供固定物理项；
- **浮点物理项 vreg0**：与其他浮点物理项一样可写。这里的 `vreg0` 是物理项编号，不能简单等同架构 f0；架构 f0 本身也不是常量零寄存器；
- **ereg0**：有异步复位，上电清零，其余 ereg 同理。

### 9.4 功耗设计亮点

| 技术 | 应用位置 | 节省估算 |
|------|---------|---------|
| 寄存器级 ICG | 每个 gated_preg/vreg/ereg | 未写入项的本地寄存器时钟停止；节省比例需功耗分析 |
| 模块级顶部 ICG 请求 | fregfile/eregfile 顶层 | 无相关写回时 `local_en=0`；最终是否停钟取决于 module/global/scan、技术宏和综合配置 |
| 扫描使能连接 | `pad_yy_icg_scan_en` 接技术 ICG 的 `TE` | 为采用该技术单元的实例提供测试开钟入口；完整 DFT 仍需扫描插入与验证 |

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
