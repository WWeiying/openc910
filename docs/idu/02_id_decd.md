# C910 IDU 主译码器详解：`ct_idu_id_decd` 与 `ct_idu_id_decd_special`

> **RTL 源文件**
> - `/home/wangwy/openproject/openc910/C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_id_decd.v`（4502 行）
> - `/home/wangwy/openproject/openc910/C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_id_decd_special.v`（227 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [RISC-V 指令格式回顾](#3-risc-v-指令格式回顾)
4. [译码器层次结构与选择器](#4-译码器层次结构与选择器)
5. [指令长度识别（16位/32位）](#5-指令长度识别16位32位)
6. [子译码器详解](#6-子译码器详解)
   - 6.1 [32 位整数指令译码（decd_32）](#61-32-位整数指令译码decd_32)
   - 6.2 [16 位压缩指令译码（decd_16）](#62-16-位压缩指令译码decd_16)
   - 6.3 [标量浮点译码（decd_fp0 / decd_fp1）](#63-标量浮点译码decd_fp0--decd_fp1)
   - 6.4 [Cache 扩展指令译码（decd_cache）](#64-cache-扩展指令译码decd_cache)
   - 6.5 [性能扩展指令译码（decd_perf）](#65-性能扩展指令译码decd_perf)
   - 6.6 [向量指令译码（decd_v / decd_vec）](#66-向量指令译码decd_v--decd_vec)
7. [执行类别与队列路由（inst_type 位图）](#7-执行类别与队列路由inst_type-位图)
8. [源/目的寄存器提取](#8-源目的寄存器提取)
9. [特殊信号：mov/fmov/mla/fmla/vmla](#9-特殊信号movfmovmlafmlavmla)
10. [非法指令检测](#10-非法指令检测)
11. [特殊指令译码子模块：`ct_idu_id_decd_special`](#11-特殊指令译码子模块ct_idu_id_decd_special)
    - 11.1 [指令拆分类型（split_short / split_long）](#111-指令拆分类型split_short--split_long)
    - 11.2 [Fence 指令类型](#112-fence-指令类型)
12. [向量掩码与 vmb 信号](#12-向量掩码与-vmb-信号)
13. [译码输出汇总与下游影响](#13-译码输出汇总与下游影响)

---

## 1. 模块概述

### 1.1 译码器的职责

`ct_idu_id_decd` 是 C910 处理器指令译码单元（IDU）的**主译码器**，工作在 ID（Instruction Decode）流水线阶段。它的核心职责是：

1. **识别指令类型**：通过分析 32 位（或 16 位压缩）指令字的各个字段，判断该指令属于哪一大类（整数 ALU、乘法、除法、分支、访存、浮点、向量等）。
2. **提取操作数信息**：确定源寄存器（rs1/rs2/rs3）和目的寄存器（rd）的编号，以及各寄存器类型（整数/浮点/向量）是否有效。
3. **产生执行类别路由位图**（`x_inst_type`）：供后续 IR 预分发逻辑判断指令应进入 AIQ、BIQ、LSIQ/SDIQ 或 VIQ。该字段大多数类别为单 bit，但 store 类 `LSU_P5` 同时置两位，因此不是严格 one-hot 编码。
4. **生成非法指令标志**（`x_illegal`）：供异常处理使用。
5. **生成拆分/fence 类型标志**：供 id_split 和 id_fence 子模块使用，决定该指令是否需要被拆成多条微操作，或者是否会产生流水线刷新。

### 1.2 为什么实例化 3 份

当前 ID 数据通路具有 **3 个原始指令槽**（inst0、inst1、inst2），因此
`ct_idu_id_dp` 实例化 3 个同一模块类型的 `ct_idu_id_decd`，使三个有效槽可以在
同一 ID 组合阶段分别产生译码结果：

```verilog
// ct_idu_id_dp.v，第 749~858 行
ct_idu_id_decd  x_ct_idu_id_decd0 ( .x_inst(id_inst0_inst), ... );
ct_idu_id_decd  x_ct_idu_id_decd1 ( .x_inst(id_inst1_inst), ... );
ct_idu_id_decd  x_ct_idu_id_decd2 ( .x_inst(id_inst2_inst), ... );
```

三个实例共享来自 CP0 的配置/状态输入（如 `cp0_idu_fs`、`cp0_idu_frm`、
`cp0_idu_vill`），但各自连接不同的 `x_inst` 和输出网络。这可以直接证明
**最多三槽并行组合译码的结构宽度**，不能仅由译码器实例数进一步推出整个核心
每周期一定发射三条、执行三条或退休三条；后续 IR 可形成四个微操作槽，实际
dispatch/issue/retire 宽度还受拆分、队列端口、源就绪、执行资源和退休协议限制。
三个实例在 RTL 上属于同一模块定义的结构复制，但综合后的面积并不必然严格等于
单实例面积乘三；常量传播、层次打平、缓冲和布线都会改变物理结果。

### 1.3 在流水线中的位置

```
  IF 阶段                  ID 阶段                     IR/IS 阶段
┌──────────┐   3×inst   ┌────────────────────────────┐   译码结果
│  IFU     ├───────────►│  id_dp                     ├──────────────►  重命名 (ir_rt)
│ (取指)   │            │  ├── id_decd0 ◄─ inst0     │                 │
└──────────┘            │  ├── id_decd1 ◄─ inst1     │                 ▼
                        │  ├── id_decd2 ◄─ inst2     │               发射队列
                        │  ├── id_decd_special       │               (AIQ0~AIQ5)
                        │  ├── id_split              │
                        │  └── id_fence              │
                        └────────────────────────────┘
```

---

## 2. 端口说明

### 2.1 输入端口

| 端口名 | 宽度 | 来源 | 含义 |
|--------|------|------|------|
| `x_inst` | 32 | IF/IR 流水线寄存器 | 待译码指令字（32 位，即使是 16 位 RVC 也放在低 16 位） |
| `cp0_idu_fs` | 2 | CP0 状态寄存器 | 浮点状态（FS 字段）：`2'b00` = Off，即浮点不可用 |
| `cp0_idu_frm` | 3 | CP0 fcsr | 动态舍入模式，用于检测非法 FP 舍入编码 |
| `cp0_idu_vs` | 2 | CP0 状态寄存器 | 向量状态（VS 字段）：`2'b00` = Off |
| `cp0_idu_vill` | 1 | CP0 vtype | 向量非法配置标志 |
| `cp0_idu_vstart` | 7 | CP0 vstart | 向量起始元素号（非零则大多数向量指令非法） |
| `cp0_idu_cskyee` | 1 | CP0 | T-Head 厂商扩展使能（XuanTie 自定义指令集） |
| `cp0_idu_zero_delay_move_disable` | 1 | CP0 | 禁止 RTL 所称的 zero-delay move 候选识别；该优化的准确边界见 9.1 节 |
| `cp0_yy_hyper` | 1 | CP0 | Hypervisor 模式使能 |
| `x_vl` | 8 | 向量状态 | 当前向量长度（用于 vl==0 时的 NOP 处理） |
| `x_vlmul` | 2 | 向量状态 | 向量寄存器组长度乘子 |
| `x_vsew` | 2 | 向量状态 | 向量元素宽度 |

### 2.2 输出端口

| 端口名 | 宽度 | 含义 |
|--------|------|------|
| `x_inst_type` | 10 | **执行类别路由位图**；通常单 bit，store 的 `LSU_P5` 为 bit4+bit5，见第 7 节 |
| `x_length` | 1 | 指令长度：`1` = 32 位，`0` = 16 位 |
| `x_illegal` | 1 | 非法指令标志（触发非法指令异常） |
| `x_dst_reg` | 5 | 整数目的寄存器编号（rd，inst[11:7]） |
| `x_dst_vld` | 1 | 整数目的寄存器有效 |
| `x_dst_x0` | 1 | 目的寄存器是 x0（写入无效，用于消除假依赖） |
| `x_dstf_reg` | 5 | 浮点目的寄存器编号 |
| `x_dstf_vld` | 1 | 浮点目的寄存器有效 |
| `x_dstv_reg` | 5 | 向量目的寄存器编号 |
| `x_dstv_vld` | 1 | 向量目的寄存器有效 |
| `x_dste_vld` | 1 | 浮点/向量异常标志位更新有效（写 fcsr.fflags） |
| `x_src0_reg` | 5 | 整数源 0 寄存器编号（rs1） |
| `x_src0_vld` | 1 | 整数源 0 有效 |
| `x_src1_reg` | 5 | 整数源 1 寄存器编号（rs2） |
| `x_src1_vld` | 1 | 整数源 1 有效 |
| `x_src2_vld` | 1 | 整数源 2 有效（T-Head 三源操作数扩展） |
| `x_srcf0_reg` | 5 | 浮点源 0 寄存器编号 |
| `x_srcf0_vld` | 1 | 浮点源 0 有效 |
| `x_srcf1_reg` | 5 | 浮点源 1 寄存器编号 |
| `x_srcf1_vld` | 1 | 浮点源 1 有效 |
| `x_srcf2_reg` | 5 | 浮点源 2 寄存器编号（FMA 的第三操作数） |
| `x_srcf2_vld` | 1 | 浮点源 2 有效 |
| `x_srcv0_reg` | 5 | 向量源 0 寄存器编号 |
| `x_srcv0_vld` | 1 | 向量源 0 有效 |
| `x_srcv1_reg` | 5 | 向量源 1 寄存器编号 |
| `x_srcv1_vld` | 1 | 向量源 1 有效 |
| `x_srcv2_vld` | 1 | 向量源 2（累积目的/旧值）有效 |
| `x_srcvm_vld` | 1 | 向量掩码寄存器（v0）有效 |
| `x_vmb` | 1 | 向量 load 带 mask 且目的更新掩码 |
| `x_mov` | 1 | 整数 move 同包依赖穿透候选标志；并不表示 RAT 复用源物理号 |
| `x_fmov` | 1 | 浮点 move 同包依赖穿透候选标志；并不表示 RAT 复用源物理号 |
| `x_mla` | 1 | T-Head 乘加指令（mla） |
| `x_fmla` | 1 | 浮点乘加类指令（fmadd/fmsub 等） |
| `x_vmla` | 1 | 向量乘加指令（vmacc/vfmacc） |
| `x_fence_type` | 3 | Fence 类型（由 decd_special 产生） |
| `x_split_long_type` | 10 | 长拆分类型（原子指令等） |
| `x_split_short_type` | 7 | 短拆分类型（JAL with dst、FP 比较/转换等） |

---

## 3. RISC-V 指令格式回顾

理解译码器的核心是掌握 RISC-V 的指令编码规则。以下是标准 32 位格式（`x_inst[1:0] == 2'b11`）。

### 3.1 标准 32 位格式

```
 31      25 24   20 19   15 14 12 11    7 6      0
┌──────────┬───────┬───────┬─────┬───────┬────────┐
│ funct7   │  rs2  │  rs1  │funct│  rd   │ opcode │  R-type
│ [31:25]  │[24:20]│[19:15]│3    │[11:7] │[6:0]   │
└──────────┴───────┴───────┴─────┴───────┴────────┘

│  imm[11:0]        │  rs1  │funct│  rd   │ opcode │  I-type
│  [31:20]          │[19:15]│3    │[11:7] │[6:0]   │

│imm[11:5] │  rs2  │  rs1  │funct│imm[4:0]│ opcode │  S-type
│ [31:25]  │[24:20]│[19:15]│3    │[11:7]  │[6:0]   │
```

### 3.2 译码器使用的关键字段

| 字段 | 位置 | 说明 |
|------|------|------|
| `opcode` | `[6:0]` | 指令大类，最低两位 `11` 表示 32 位指令 |
| `funct3` | `[14:12]` | 同一 opcode 内的功能区分 |
| `funct7` | `[31:25]` | 进一步区分（R 型）或立即数上半部分 |
| `rd` | `[11:7]` | 目的寄存器 |
| `rs1` | `[19:15]` | 源寄存器 1 |
| `rs2` | `[24:20]` | 源寄存器 2 |
| `rs3` | `[31:27]` | 浮点 FMA 第三源（`funct2` 在 `[26:25]`） |

译码器的 case 语句通常拼接 `{x_inst[31:25], x_inst[14:12], x_inst[6:2]}` 这 15 位来作为匹配键，覆盖 funct7 + funct3 + opcode[6:2] 的组合，从而在一个 case 中精确区分所有 32 位指令。

### 3.3 16 位 RVC 压缩格式

```
 15      10 9   7 6      2 1 0
┌──────────┬─────┬────────┬────┐
│ funct6   │ rs2'│  rs1'  │ op │  CL/CS/CA/CB type
│ [15:10]  │[4:2]│ [9:7]  │    │
└──────────┴─────┴────────┴────┘
```

- `op`（`[1:0]`）：`00`/`01`/`10` 分别对应三个 RVC 四分象限
- 3 位寄存器编号 `[4:2]` / `[9:7]` 通过加偏移量 8（即 `{2'b01, x_inst[4:2]}`）映射到整数寄存器 x8~x15

---

## 4. 译码器层次结构与选择器

### 4.1 子译码器分类

主译码器内部并非单一的大 case，而是**按指令集大类分成多个独立的 combinational block**，最后通过一个 6 位 one-hot 选择器汇总：

```
x_inst ──┬──► decd_32（32位整数）     decd_sel[0]
         ├──► decd_16（16位RVC）      decd_sel[1]
         ├──► decd_fp（标量浮点）     decd_sel[2]
         ├──► decd_cache（Cache扩展）  decd_sel[3]
         ├──► decd_perf（性能扩展）    decd_sel[4]
         └──► decd_vec（向量）         decd_sel[5]
                                          │
                                    6-to-1 MUX
                                          │
                                    x_inst_type, x_dst_vld,
                                    x_src0_vld, ...(最终输出)
```

### 4.2 选择器逻辑（第 776～794 行）

```verilog
// decd.v 第776~794行
assign decd_sel[0] = decd_length           // 32位
                     && !decd_fp_sel        // 非浮点opcode
                     && !decd_sel[3]        // 非Cache扩展
                     && !decd_sel[4]        // 非性能扩展
                     && !decd_sel[5];       // 非向量

assign decd_sel[1] = !decd_length;         // 16位（RVC）

assign decd_sel[2] = decd_fp_sel;          // 浮点：opcode==7'b1010011 或 {op[6:4],op[1:0]}==5'b10011

assign decd_sel[3] = ({x_inst[31:26],x_inst[14:0]} == 21'b000000_000_00000_0001011)
                     && cp0_idu_cskyee;     // XuanTie Cache扩展（custom opcode 0001011）

assign decd_sel[4] = (x_inst[6:0] == 7'b0001011) // XuanTie 性能扩展
                     && (x_inst[14:12] != 3'b000)
                     && cp0_idu_cskyee;

assign decd_sel[5] = 1'b0;                 // 向量：在此版本中被禁用（x_vec_inst=0）
```

**关键设计原则**：

- `decd_sel` 是互斥的 one-hot 编码。所有子译码器**同时并行**计算，最后 MUX 选择有效的一路。这种方式以面积换取时序，避免了串行判断的逻辑链。
- 向量译码器（`decd_sel[5]`）在当前 RTL 中被硬置为 0（`assign x_vec_inst = 1'b0`），向量功能已预留但未激活，仅保留了完整的译码框架代码供参考。
- 浮点选择优先于普通 32 位：`decd_sel[0]` 显式排除 `decd_fp_sel`，保证浮点指令走 `decd_sel[2]` 路径。

### 4.3 MUX 汇总（第 851～966 行）

```verilog
// decd.v 第851~966行
case(decd_sel[5:0])
  6'h1:  /* 使用 decd_32_*  系列信号 */
  6'h2:  /* 使用 decd_16_*  系列信号 */
  6'h4:  /* 使用 decd_fp_*  系列信号 */
  6'h8:  /* 使用 decd_cache_* 系列信号 */
  6'h10: /* 使用 decd_perf_* 系列信号 */
  6'h20: /* 使用 decd_vec_*  系列信号 */
  default: /* 全 x（don't care） */
endcase
```

---

## 5. 指令长度识别（16位/32位）

```verilog
// decd.v 第400~401行
assign decd_length = (x_inst[1:0] == 2'b11);
assign x_length    = decd_length;
```

RISC-V 规定：标准 32 位指令的最低两位恒为 `11`；所有 16 位压缩指令（RVC）的最低两位为 `00`、`01` 或 `10`。这个判断是整个译码器的第一级筛选，极为简单但至关重要。

**为什么不需要更复杂的判断**：RISC-V ISA 从设计上保证了 16/32 位的长度编码完全由最低两位决定，不存在歧义，因此这里只需一个 2 位比较。

---

## 6. 子译码器详解

### 6.1 32 位整数指令译码（decd_32）

**触发条件**：`decd_sel[0]` 为 1，即指令为 32 位非浮点、非扩展指令。

**匹配键**：`{x_inst[31:25], x_inst[14:12], x_inst[6:2]}`，共 15 位（funct7 + funct3 + opcode[6:2]）。

```verilog
// decd.v 第1168~1172行
always @( x_inst[14:12] or x_inst[31:25] or x_inst[6:2])
begin
  // 初始化所有输出为 0
  casez({x_inst[31:25], x_inst[14:12], x_inst[6:2]})
```

#### 6.1.1 标准整数指令分类

下表覆盖所有 32 位整数 RISC-V 指令的译码结果：

| 指令类别 | 代表指令 | `inst_type` | `src0_vld` | `src1_vld` | `dst_vld` |
|----------|----------|-------------|-----------|-----------|----------|
| LUI | lui | ALU | 0 | 0 | 1 |
| AUIPC | auipc | SPECIAL | 0 | 0 | 1 |
| JAL | jal | BJU | 0 | 0 | 0（dst 由 split 处理）|
| JALR | jalr | BJU | 1 | 0 | 0（dst 由 split 处理）|
| 条件分支 | beq/bne/blt/bge/bltu/bgeu | BJU | 1 | 1 | 0 |
| 整数 LOAD | lb/lh/lw/ld/lbu/lhu/lwu | LSU | 1 | 0 | 1 |
| 浮点 LOAD | flh/flw/fld | LSU | 1 | 0 | 0（`dstf_vld=1`）|
| 整数 STORE | sb/sh/sw/sd | LSU_P5 | 1 | 1 | 0 |
| 浮点 STORE | fsh/fsw/fsd | LSU_P5 | 1 | 0 | 0（`srcf2_vld=1`）|
| OP-IMM | addi/slti/xori/ori/andi/slli/srli/srai | ALU | 1 | 0 | 1 |
| OP-IMM-W | addiw/slliw/srliw/sraiw | ALU | 1 | 0 | 1 |
| OP | add/sub/sll/slt/sltu/xor/srl/sra/or/and | ALU | 1 | 1 | 1 |
| OP-W | addw/subw/sllw/srlw/sraw | ALU | 1 | 1 | 1 |
| MUL | mul/mulh/mulhsu/mulhu/mulw | MULT | 1 | 1 | 1 |
| DIV | div/divu/rem/remu/divw/divuw/remw/remuw | DIV | 1 | 1 | 1 |
| LR.W/D | lr.w/lr.d | LSU | 1 | 0 | 1 |
| SC.W/D | sc.w/sc.d | LSU_P5 | 1 | 1 | 1 |
| AMO | amoadd/amoswap/... | —（deal in split）| — | — | — |
| FENCE | fence | LSU | 0 | 0 | 0 |
| SYSTEM | ecall/ebreak | SPECIAL | 0 | 0 | 0 |
| CSR/RET/WFI | csrrw/.../mret/sret/wfi | —（deal in fence）| — | — | — |

**说明**：

- **AUIPC 归 SPECIAL 而非 ALU**：AUIPC 需要读取 PC，而 PC 不是普通整数寄存器文件中的值，需要在特殊执行路径处理（通常在 BJU 单元），因此 inst_type 为 SPECIAL（`10'b1000000000`），而 LUI 只需立即数运算，直接用 ALU。
- **JAL/JALR 的 dst_vld 为 0**：JAL/JALR 写目的寄存器（保存返回地址）这一属性由 `id_decd_special` 的 `x_split_short_type[0]` 来处理（见第 11 节），避免了主译码器的重复逻辑。
- **AMO 指令不在这里处理**：原子内存操作（AMO）需要拆分为 load+store 两个微操作，因此主译码器不产生任何有效信号，完全由 `id_split_long` 处理。
- **STORE 使用 LSU_P5**：Store 指令有两个 整数源寄存器（地址基址 rs1 和数据 rs2），访存单元中 LSU_P5 对应的端口 5 专门服务于 store 类请求。

#### 6.1.2 LR/SC 特殊处理

```verilog
// decd.v 第1555~1603行
15'b00010??01001011: begin //lr.w   (opcode=0101111 -> 01011 = 0b01011 -> [6:2]=01011)
  decd_32_inst_type = LSU;
  decd_32_src0_vld  = 1'b1;
  decd_32_dst_vld   = 1'b1;
end
15'b00011??01001011: begin //sc.w
  decd_32_inst_type = LSU_P5;
  decd_32_src0_vld  = 1'b1;
  decd_32_src1_vld  = 1'b1;
  decd_32_dst_vld   = 1'b1;
end
```

LR（Load-Reserved）本质是 load，因此归 LSU；SC（Store-Conditional）有地址源和数据源两个，加上目的寄存器（用于写入 success/fail），归 LSU_P5。两者都由 `decd_special` 标记为 `split_long_type[0]`，在流水线中触发序列化处理。

### 6.2 16 位压缩指令译码（decd_16）

**触发条件**：`decd_sel[1]` 为 1（`x_inst[1:0] != 2'b11`）。

**匹配键**：`{x_inst[15:10], x_inst[6:5], x_inst[1:0]}`，共 10 位。

```verilog
// decd.v 第971~987行
always @( x_inst[15:2] or x_inst[1:0])
begin
  casez({x_inst[15:10], x_inst[6:5], x_inst[1:0]})
```

#### 6.2.1 RVC 三个象限

| op[1:0] | 象限 | 典型指令 |
|---------|------|----------|
| `00` | C0（寄存器偏移 load/store）| c.addi4spn, c.fld, c.lw, c.ld, c.fsd, c.sw, c.sd |
| `01` | C1（整数运算/分支）| c.addi, c.addiw, c.li, c.lui, c.srli, c.srai, c.andi, c.sub, c.xor, c.or, c.and, c.subw, c.addw, c.j, c.beqz, c.bnez |
| `10` | C2（基于栈的 load/store + 间接跳转）| c.slli, c.fldsp, c.lwsp, c.ldsp, c.jr, c.mv, c.jalr, c.add, c.ebreak, c.fsdsp, c.swsp, c.sdsp |

#### 6.2.2 寄存器宽度转换

RVC 使用两种寄存器编号方式：

- **5 位全寄存器**：出现在 C2 象限，使用 `x_inst[11:7]`（rd/rs1）和 `x_inst[6:2]`（rs2），与 32 位指令相同。
- **3 位压缩寄存器**：出现在 C0/C1 象限，`x_inst[9:7]` 和 `x_inst[4:2]`，映射为 x8~x15（加偏移 8）：`{2'b01, x_inst[9:7]}`。

这一映射逻辑在寄存器提取阶段处理（见第 8 节）。

#### 6.2.3 c.jr / c.mv / c.jalr / c.add / c.ebreak 的区分

这 5 条指令共享 `x_inst[15:12] == 4'b100x` 且 `op == 2'b10`：

```verilog
// decd.v 第1125~1154行
10'b1000??_??10: begin //c.jr / c.mv
  decd_16_inst_type = (x_inst[6:2] == 5'b0) ? BJU : ALU;  //rs2==0 → c.jr; else c.mv
  decd_16_src0_vld  = 1'b1;
  decd_16_dst_vld   = (x_inst[6:2] != 5'b0);              //c.mv 有目的寄存器
end
10'b1001??_??10: begin //c.jalr / c.add / c.ebreak
  decd_16_inst_type = (x_inst[6:2] == 5'b0)
                    ? ((x_inst[11:7] == 5'b0) ? SPECIAL : BJU)  //rs1==0→ebreak; rs2==0→c.jalr
                    : ALU;                                        //rs2!=0 → c.add
  ...
end
```

这里通过检查 rs2（`x_inst[6:2]`）和 rs1/rd（`x_inst[11:7]`）是否为 0 来精确区分这些 opcode 相同但语义完全不同的指令。

#### 6.2.4 浮点压缩 load/store

| 指令 | 匹配模式 | inst_type | 源 | 目的 |
|------|----------|-----------|-----|------|
| c.fld | `001???_??00` | LSU | src0（基址寄存器）| dstf（浮点 rd）|
| c.fsd | `101???_??00` | LSU_P5 | src0（基址）| srcf2（浮点存储数据）|
| c.fldsp | `001???_??10` | LSU | src0（sp）| dstf |
| c.fsdsp | `101???_??10` | LSU_P5 | src0（sp）| srcf2 |

### 6.3 标量浮点译码（decd_fp0 / decd_fp1）

**触发条件**：`decd_sel[2]` 为 1，即 `opcode == 7'b1010011`（OP-FP）或 `{inst[6:4],inst[1:0]} == 5'b10011`（FMA 类 opcode）。

浮点译码被拆成两个独立的 combinational block：

| 子块 | 覆盖指令 | 匹配键 |
|------|----------|--------|
| `decd_fp0` | OP-FP 类（fadd/fsub/fmul/fdiv/fsqrt/fsgnj/fmin/fmax/fcvt/fmv/feq/flt/fle/fclass）| `{x_inst[31:20], x_inst[14:12]}` (15 位) |
| `decd_fp1` | FMA 类（fmadd/fmsub/fnmsub/fnmadd）| `{x_inst[26:25], x_inst[4:2]}` (5 位) |

最后通过 `{decd_fp1_sel, decd_fp0_sel}` 二选一汇总为 `decd_fp_*` 信号。

#### 6.3.1 浮点精度字段（fmt）

RISC-V 浮点指令用 `x_inst[26:25]`（funct2）编码精度：

| fmt | `[26:25]` | 精度 |
|-----|-----------|------|
| S | `00` | 单精度 32 位 |
| D | `01` | 双精度 64 位 |
| H | `10` | 半精度 16 位（T-Head Zfh 扩展）|

译码器用同一套逻辑覆盖 H/S/D 三种精度，通过不同的 `[31:20]` 模式匹配区分。

#### 6.3.2 功能单元分配策略

| 指令类型 | `inst_type` | 说明 |
|----------|-------------|------|
| fadd/fsub/fmul/fmin/fmax/fsgnj/feq/flt/fle/fclass/fmv | PIPE67 | 延迟适中，双端口（pipe6 和 pipe7 均可执行）|
| fdiv/fsqrt | PIPE6 | 延迟最长（迭代算法），只走 pipe6 |
| fcvt（格式转换）| PIPE7 | 专用转换单元，走 pipe7 |
| fmv.x.w/fmv.w.x（整数←→浮点搬运）| ALU | 仅需数据搬运，复用 ALU 通路 |
| FMA（fmadd/fmsub 等）| PIPE67 | 三源操作数，使用 `srcf2_vld` |

**为什么 fdiv 只走 pipe6**：除法/开方使用迭代算法（如 SRT 或 Newton-Raphson），延迟高且不固定，C910 将其隔离到单独的 PIPE6，避免阻塞其他浮点操作。

#### 6.3.3 `dste_vld`（浮点异常标志位更新）

大多数浮点运算（fadd/fsub/fmul/fdiv/fcvt 等）会在运算后更新 fcsr 中的 fflags（NV/DZ/OF/UF/NX）。这类指令的 `dste_vld` = 1，告知重命名器需要额外分配一个用于写 fcsr 的"目的"。纯符号位操作（fsgnj 系列）和数据搬运（fmv）不修改 fflags，其 `dste_vld` = 0。

#### 6.3.4 FP 转换指令（split 处理）

所有 `fcvt.x.f`（浮点转整数）和 `fcvt.f.x`（整数转浮点）类指令在主译码器的 decd_fp0 中被标记为 "deal in split"（空的 case 分支），不产生任何操作数信息，而是由 `id_decd_special` 的 `x_split_short_type[1]` 来处理。原因是这类指令涉及跨寄存器文件的数据传输（GPR ↔ FPR），需要额外的微操作序列。

### 6.4 Cache 扩展指令译码（decd_cache）

**触发条件**：`decd_sel[3]` 为 1，`{x_inst[31:26], x_inst[14:0]} == 21'h000_0001011` 且 `cp0_idu_cskyee = 1`。

这是 T-Head XuanTie 自定义 opcode（`0001011`）中的 Cache 管理子集，匹配键为 `{x_inst[25], x_inst[24:20], x_inst[19:15]}`（11 位）。

| 指令 | 匹配 | 含义 |
|------|------|------|
| dcache.iall | `0_00010_00000` | D-Cache 全部无效 |
| dcache.call | `0_00001_00000` | D-Cache 全部清除 |
| dcache.ciall | `0_00011_00000` | D-Cache 清除+无效 |
| dcache.isw | `1_00010_?????` | D-Cache 按路无效（需 src0）|
| dcache.csw/cisw | `1_00001/3_?????` | 按路清除/清除+无效 |
| dcache.iva/cva/civa | `1_00110/5/7_?????` | 按虚地址操作 |
| icache.iall/iva | 对应编码 | I-Cache 操作 |
| sync/sync.s/sync.i/sync.is | `0_11000/1/2/3_00000` | 内存屏障系列 |

所有 Cache 指令的 `inst_type` 均为 `LSU`（通过访存单元执行），需要地址操作数的指令 `src0_vld = 1`，全局操作的指令无需源寄存器。

### 6.5 性能扩展指令译码（decd_perf）

**触发条件**：`decd_sel[4]` 为 1，`x_inst[6:0] == 7'b0001011` 且 `x_inst[14:12] != 3'b000` 且 `cp0_idu_cskyee = 1`。

匹配键：`{x_inst[31:25], x_inst[14:12]}`（10 位）。

#### 6.5.1 整数性能扩展

| 指令 | 类型 | 源操作数 | 说明 |
|------|------|----------|------|
| addsl | ALU | src0, src1 | 移位后加（add shifted left）|
| srri/srriw | ALU | src0 | 循环右移立即数 |
| tstnbz | ALU | src0 | 测试非零字节 |
| rev/ff0/ff1 | ALU | src0 | 位反转/首 0/首 1 |
| tst | ALU | src0 | 位测试 |
| revw | ALU | src0 | 字内位反转 |
| mveqz/mvnez | ALU | src0, src1, src2 | 条件移动（3 源操作数）|
| ext/extu | ALU | src0 | 位域提取 |
| mula/muls/mulaw/mulsw | MULT | src0, src1, src2 | 乘加/乘减（3 源操作数）|
| mulah/mulsh | MULT | src0, src1, src2 | 半字乘加 |

注意 `mveqz`/`mvnez` 和 `mula` 系列有三个整数源（src0、src1、src2），这在标准 RISC-V 中不存在，是 T-Head 扩展的独特特性。

#### 6.5.2 索引访存扩展

| 指令类型 | inst_type | 操作数 |
|----------|-----------|--------|
| lrb/lrh/lrw/lrd（寄存器偏移 load）| LSU | src0（基址）+ src1（偏移）→ dst |
| srb/srh/srw/srd（寄存器偏移 store）| LSU_P5 | src0 + src1 + src2（数据）|
| flrw/flrd（FP 寄存器偏移 load）| LSU | src0 + src1 → dstf |
| fsrw/fsrd（FP 寄存器偏移 store）| LSU_P5 | src0 + src1 + srcf2 |
| lbib/lbia/...（地址自增 load）| —（deal in split）| 需要拆分 |

**为什么 store 使用 src2 而不是 src1**：C910 的设计中，src2 专门用于"额外的数据源"，与地址生成所需的 src0/src1 分开，这样寄存器读端口可以独立安排。

### 6.6 向量指令译码（decd_v / decd_vec）

**设计现状**：`assign x_vec_inst = 1'b0` 使向量子系统在当前版本中不起作用。但完整的译码框架代码存在，说明 C910 RTL 为向量扩展预留了完整路径。

#### 6.6.1 向量指令编码分析

向量指令的 opcode 为 `7'b1010111`（OP-V），通过 `x_inst[14:12]`（funct3）区分操作类型：

| funct3 | 名称 | 含义 |
|--------|------|------|
| `000` | OPIVV | 向量-向量整数操作 |
| `011` | OPIVI | 向量-立即数整数操作 |
| `100` | OPIVX | 向量-标量（GPR）整数操作 |
| `010` | OPMVV | 向量-向量整数乘法/mask/reduction |
| `110` | OPMVX | 向量-标量整数乘法/mask |
| `001` | OPFVV | 向量-向量浮点操作 |
| `101` | OPFVF | 向量-标量（FPR）浮点操作 |
| `111` | OPCFG | 配置指令（vsetvl/vsetvli）|

匹配键：`{x_inst[31:26], x_inst[14:12]}`（9 位），覆盖 opcode 上半部分（功能码）和操作类型。

#### 6.6.2 vsetvl/vsetvli

```verilog
// decd.v 第3169~3180行
9'b0?????_111: begin //vsetvli
  decd_v_inst_type = SPECIAL;
  decd_v_src0_vld  = 1'b1;  //rs1（AVL）
  decd_v_dst_vld   = 1'b1;  //rd（写回新 vl）
end
9'b100000_111: begin //vsetvl
  decd_v_inst_type = SPECIAL;
  decd_v_src0_vld  = 1'b1;  //rs1（AVL）
  decd_v_src1_vld  = 1'b1;  //rs2（vtype）
  decd_v_dst_vld   = 1'b1;
  decd_code_illegal = x_inst[25]; //vsetvl 要求 inst[25]==0
end
```

vsetvl 配置指令归 SPECIAL 类，意味着它需要在特殊执行通路中处理，可能会影响后续向量指令的配置状态。

#### 6.6.3 向量 NOP 处理（vl == 0）

```verilog
// decd.v 第4435~4436行
assign decd_vec_nop = (x_vl[7:0]==8'b0) && !x_vec_opcfg && !vec_mfvr_inst;
```

当向量长度 vl = 0 时，除 vsetvl/vsetvli 和 vfmv.f.s/vext.x.v 等读向量寄存器返回标量的指令以外，所有向量指令被软件降级为 NOP（inst_type = SPECIAL，所有操作数 valid = 0）。这是 RISC-V V 扩展规范的要求：vl = 0 时操作应无副作用。

#### 6.6.4 源操作数寄存器交换（switch 逻辑）

对于向量减法（vsub）和部分乘加指令，源操作数的语义顺序与指令编码中的物理寄存器位置相反（被减数是 vs2 而非 vs1）：

```verilog
// decd.v 第2864~2874行
assign x_srcv0_reg = x_srcv0_srcv1_switch ? x_inst[19:15] : x_inst[24:20];
assign x_srcv1_reg = x_srcv1_srcv2_switch ? x_inst[11: 7]
                   : x_srcv0_srcv1_switch  ? x_inst[24:20]
                   :                         x_inst[19:15];
```

`x_srcv0_srcv1_switch` 对 vsub/vsbc/vmsbc/vmsltu/vmslt/vssubu/vssub/vasub/vmadd/vnmsub 等指令有效，实现了逻辑语义到物理寄存器的重新映射，使执行单元总是从同一个端口读被减数/被减寄存器。

#### 6.6.5 向量非法检测的多维度

向量指令的非法检测比标量指令复杂得多：

```verilog
// decd.v 第3135~3139行
assign decd_v_illegal = decd_code_illegal     // 指令编码本身非法
                     || decd_vreg_illegal      // 向量寄存器未对齐（LMUL）
                     || decd_ovlp_illegal      // 源/目寄存器组重叠
                     || decd_size_illegal      // SEW/LMUL 组合非法（widen/narrow 边界）
                     || decd_start_illegal     // vstart != 0（大多数指令不支持）
                     || decd_vill_illegal      // vtype.vill = 1
                     || decd_vs_illegal        // VS = Off
                     || decd_fs_illegal        // FS = Off 但需要浮点
                     || decd_fp_rounding_illegal; // 非法动态舍入模式
```

这种多层次检测是 RISC-V V 扩展规范复杂性的体现，反映了向量指令语义中对寄存器对齐、元素宽度、掩码使用等诸多约束。

---

## 7. 执行类别与队列路由（inst_type 位图）

### 7.1 inst_type 位定义

```verilog
// decd.v 第759~770行
parameter TYPE_WIDTH = 10;
parameter ALU     = 10'b0000000001;  // bit 0：整数 ALU（加减移位逻辑比较）
parameter BJU     = 10'b0000000010;  // bit 1：分支/跳转单元
parameter MULT    = 10'b0000000100;  // bit 2：乘法单元
parameter DIV     = 10'b0000001000;  // bit 3：除法单元
parameter LSU_P5  = 10'b0000110000;  // bit 5+4：访存单元（Store 端口）
parameter LSU     = 10'b0000010000;  // bit 4：访存单元（Load 端口）
parameter PIPE67  = 10'b0001000000;  // bit 6：浮点/向量双通道
parameter PIPE6   = 10'b0010000000;  // bit 7：浮点 pipe6（fdiv/fsqrt）
parameter PIPE7   = 10'b0100000000;  // bit 8：浮点 pipe7（fcvt）
parameter SPECIAL = 10'b1000000000;  // bit 9：特殊处理单元（AUIPC/ecall/vsetvl 等）
```

`LSU_P5 = 10'b0000110000` 同时置 bit4 和 bit5，因此 `x_inst_type` 应称为
**类别位图**，而不是无例外的 one-hot 编码。沿当前 `ir_dp`/`ir_ctrl` 连接，
bit4 使 store 地址部分进入 LSIQ，bit5 同时使 store 数据部分进入 SDIQ。这里的
“P5”是 RTL 类别名；不能仅凭名字把它解释成一个独立的 load/store 执行端口。

### 7.2 inst_type 与发射队列映射

| inst_type 位 | IR 中的控制位 | 当前 RTL 队列路由 | 精确说明 |
|--------------|---------------|------------------|----------|
| ALU / bit0 | `IS_CTRL_ALU` | AIQ0/AIQ1 动态选择 | 先形成 `aiq01` 类，再受整数 DLB 控制选择队列 |
| BJU / bit1 | `IS_CTRL_BJU` | BIQ | 分支/跳转进入独立 Branch IQ，不是 AIQ0 |
| MULT / bit2 | `IS_CTRL_MULT` | AIQ1 | 当前 `ir_ctrl` 将乘法类固定归入 AIQ1 |
| DIV / bit3 | `IS_CTRL_DIV` | AIQ0 | 当前 `ir_ctrl` 将除法类固定归入 AIQ0 |
| LSU / bit4 | `IS_CTRL_LSU` | LSIQ | load 以及 store 的地址/LSU 部分进入 LSIQ |
| LSU_P5 的 bit5 | `IS_CTRL_STADDR` | SDIQ | store 类还创建 SDIQ 项，用于独立跟踪 store data |
| PIPE67 / bit6 | `IS_CTRL_PIPE67` | VIQ0/VIQ1 动态选择 | 可由两条 VFPU 路径承载的类别，经 VIQ DLB 选择 |
| PIPE6 / bit7 | `IS_CTRL_PIPE6` | VIQ0 | 固定归入面向 pipe6 的 VIQ0 |
| PIPE7 / bit8 | `IS_CTRL_PIPE7` | VIQ1 | 固定归入面向 pipe7 的 VIQ1 |
| SPECIAL / bit9 | `IS_CTRL_SPECIAL` | AIQ0，并保留 special 属性 | `ir_ctrl` 的 AIQ0 条件是 `DIV \|\| SPECIAL`；不存在名为 `AIQ_SPECIAL` 的独立队列 |

这种按位表示使 `ir_dp` 可以把各 bit 直接展开成 `IS_CTRL_*` 控制位，随后由
`ir_ctrl` 组合出队列选择。RTL 能证明的是“字段到控制位的直接连接”和上述队列
方程；是否因此减少了多少优先编码级数、扇出或关键路径延迟，仍需综合网表与 STA
报告，而不能由编码形式单独定量。

---

## 8. 源/目的寄存器提取

寄存器索引的提取逻辑需要同时支持 32 位指令的 5 位寄存器字段和 16 位 RVC 的 3 位/5 位寄存器字段，因此使用了带优先级的多路复用结构。

### 8.1 整数源 0（rs1）提取

```verilog
// decd.v 第476~499行
assign decd_inst_src0_reg_32bit   = (x_inst[1:0] == 2'b11);       // 32位：rs1在[19:15]
assign decd_inst_src0_reg_16bit_5 = (({x_inst[1:0],x_inst[15]}==3'b01_0) // C1 非H类
                                    || (x_inst[1:0]==2'b10))       // C2象限
                                    && !decd_inst_src0_reg_r2
                                    && !decd_inst_src0_reg_cmv;
assign decd_inst_src0_reg_cmv     = ({x_inst[1:0],x_inst[15:12]}==6'b10_1000)
                                    && (x_inst[6:2]!=5'd0);        // c.mv：src0来自rs2字段
assign decd_inst_src0_reg_16bit_3 = (({x_inst[1:0],x_inst[15]}==3'b01_1)  // C1 H类
                                    || (x_inst[1:0]==2'b00))       // C0象限
                                    && !decd_inst_src0_reg_r2;
assign decd_inst_src0_reg_r2      = ({x_inst[14:13],x_inst[1:0]}==4'b00_00) // c.addi4spn→sp
                                    || (x_inst[1:0]==2'b10)        // C2中的load/store
                                       && (x_inst[15:13]!=3'b000)
                                       && (x_inst[15:13]!=3'b100);

assign decd_src0_reg =
     {5{decd_inst_src0_reg_32bit}}   & x_inst[19:15]   // 标准 rs1
   | {5{decd_inst_src0_reg_16bit_5}} & x_inst[11:7]    // C1/C2 全5位
   | {5{decd_inst_src0_reg_cmv}}     & x_inst[6:2]     // c.mv 特殊
   | {5{decd_inst_src0_reg_16bit_3}} & {2'b01,x_inst[9:7]}  // 3位→x8-x15
   | {5{decd_inst_src0_reg_r2}}      & 5'd2;           // 固定为 x2（sp）
```

**注释说明关键设计决策**：

- 注释明确指出这里"已针对时序优化"（`optimized for timing by ignoring invalid instructions`）。因此这里的多路选择逻辑有意忽略了无效指令的情况（default 值），以减少逻辑级数。
- `decd_inst_src0_reg_r2` 处理需要隐式读栈指针（sp = x2）的指令，如 `c.addi4spn`（目的地址是 sp+偏移）以及 C2 象限的基于栈的 load/store。
- `decd_inst_src0_reg_cmv` 是 `c.mv` 的特殊处理：`c.mv` 语义等于 `mv rd, rs2`，其"源寄存器"在编码的 rs2 位置（`[6:2]`），但正常的 C2 源寄存器是从 `[11:7]` 取。

### 8.2 整数源 1（rs2）提取

```verilog
// decd.v 第504~517行
assign decd_src1_reg =
     {5{decd_inst_src1_reg_32bit}}   & x_inst[24:20]   // 标准 rs2
   | {5{decd_inst_src1_reg_16bit_5}} & x_inst[6:2]     // C2 象限
   | {5{decd_inst_src1_reg_16bit_3}} & {2'b01,x_inst[4:2]};  // C0/C1 3位
```

源 1 的逻辑相对简单，因为 RVC 的 C2 象限 rs2 字段固定在 `[6:2]`，C0/C1 的 3 位压缩寄存器固定在 `[4:2]`。

### 8.3 整数/浮点目的寄存器（rd）提取

```verilog
// decd.v 第529~543行
assign decd_dst_reg =
     {5{decd_inst_dst_reg_32bit}}         & x_inst[11:7]         // 32位 rd
   | {5{decd_inst_dst_reg_16bit_5}}       & x_inst[11:7]         // C1低位/C2
   | {5{decd_inst_dst_reg_16bit_3_high}}  & {2'b01,x_inst[9:7]}  // C1高位 rd'
   | {5{decd_inst_dst_reg_16bit_3_low}}   & {2'b01,x_inst[4:2]}; // C0 rd'

assign x_dst_x0 = (decd_dst_reg == 5'd0);  // 写 x0 标志
```

`x_dst_x0` 只比较译码得到的整数目的号是否为 0。到 IR 阶段，
`idu_rtu_ir_pregN_alloc_vld` 显式包含 `!dp_ctrl_ir_instN_dst_x0`，因此写 x0 的
指令不发出正常整数物理寄存器分配请求；`ir_instN_dst_preg` 也被按
`!IR_DST_X0` 屏蔽为 0。整数 RAT 对 reg0 使用专门的常量读出语义，而不是把 x0
当作普通可重命名寄存器更新。提前生成该标志让后续控制可直接使用，但它是否位于
物理关键路径、节省多少延迟或功耗，需要 STA/功耗结果证明。

### 8.4 浮点源寄存器提取

```verilog
// decd.v 第555~573行
assign x_srcf0_reg = x_inst[19:15];  // 浮点 rs1 固定在 [19:15]

assign x_srcf1_reg =
     {5{decd_inst_srcf1_reg_32bit}}     & x_inst[24:20]   // 32位 rs2
   | {5{decd_inst_srcf1_reg_32bit_low}} & x_inst[11:7]    // XuanTie扩展特殊情况
   | {5{decd_inst_srcf1_reg_16bit}}     & x_inst[6:2]     // C2
   | {5{decd_inst_srcf1_reg_16bit_low}} & {2'b01,x_inst[4:2]}; // C0
```

`decd_inst_srcf1_reg_32bit_low` 处理 T-Head 自定义 opcode（`0001011`）中某些浮点指令（如 flrw/flrd）的 srcf1 来自 `[11:7]` 的特殊情况。

### 8.5 浮点源 2（FMA 第三操作数）寄存器提取

```verilog
// decd.v 第588~607行
always @(...)
begin
  case({decd_inst_vls, decd_inst_fls, decd_inst_cls_sp, decd_inst_cls})
    4'b1000: x_srcf2_reg = x_inst[11: 7];  // XuanTie VLS 格式
    4'b0100: x_srcf2_reg = x_inst[24:20];  // 标准 FLS（fsh/fsw/fsd）
    4'b0010: x_srcf2_reg = x_inst[6:2];    // c.fsdsp（C2）
    4'b0001: x_srcf2_reg = {2'b1,x_inst[4:2]};  // c.fsd（C0）
    default: x_srcf2_reg = x_inst[31:27];  // FMA 的 rs3
  endcase
end
```

这里用 case 而非组合 OR 的原因是 srcf2 的来源具有真正的优先级，不同指令类型的 srcf2 来自完全不同的位域，且相互排斥。注意标准 FMA（fmadd/fmsub 等）的 rs3 在 `[31:27]`，而标准 store（fsd 等）的数据源 rs2 在 `[24:20]`。

---

## 9. 特殊信号：mov/fmov/mla/fmla/vmla

这些信号用于流水线的特殊优化：

### 9.1 RTL 所称的“零延迟 MOV”（x_mov / x_fmov）

```verilog
// decd.v 第412~427行
assign x_mov =
  !cp0_idu_zero_delay_move_disable
  && (({x_inst[1:0],x_inst[15:12]}==6'b10_1000) //c.mv
      && (x_inst[11:7] != 5'd0)     //dest != x0
      && (x_inst[11:7] != x_inst[6:2]) //dest != src
   || ({x_inst[6:0],x_inst[14:12]}==10'b0010011_000) //addi（即 mv）
      && (x_inst[31:20] == 12'd0)   //立即数==0（即 mv rd, rs1）
      && (x_inst[11:7] != 5'd0)
      && (x_inst[11:7] != x_inst[19:15])); //dest != src

assign x_fmov = !cp0_idu_zero_delay_move_disable
             && (x_inst[31:25] == 7'b0010001)  //fsgnj.d（fsgnj.d rd,rs1,rs1 = fmv.d）
             && (x_inst[14:12] == 3'b000)
             && (x_inst[6:0]   == 7'b1010011)
             && (x_inst[24:20] == x_inst[19:15]) //rs1 == rs2（伪指令 fmv）
             && (x_inst[11:7]  != x_inst[19:15]); //dst != src
```

这里的“零延迟”是 RTL 信号命名，准确含义是**同一个重命名包内的 move
依赖穿透**，不能扩展解释成“目的不分配物理寄存器”“RAT 目的表项直接等于源
表项”或“该指令一定不进入执行流水线”。

以 `inst0: mv x3,x7` 和同包较年轻的 `inst1: add x5,x3,x2` 为例：

1. `inst0` 的 `x3` 仍取得 RTU 分配的新目的物理号，整数 RAT 也仍以这个新物理号
   更新 `x3` 的映射。
2. 因为 move 的数值语义是 `x3=x7`，整数 RAT 的组合旁路可让 `inst1` 直接继承
   `x7` 当前物理映射的 `preg/rdy/wb` 信息，不必把 `inst1` 建成对 `inst0`
   新目的物理号的同包 RAW 依赖。
3. 这只消除了特定同包消费者依赖 move 的等待边；仅凭 `x_mov=1` 不能证明
   move 本身不分配、不发射或不执行。当前 IR 数据通路仍把新分配的
   `dp_rt_instN_dst_preg` 写入 RAT，并随指令送往后续结构。

浮点 `fmv.d rd,rs1` 是 `fsgnj.d rd,rs1,rs1` 的汇编伪指令。`x_fmov` 采用相同
思想：FRT 仍写入新分配的目的浮点物理号，但同包较年轻消费者可以从
`srcf0` 的旧映射与就绪状态取得等价的数据依赖信息。

`rd!=rs` 条件也应按代码注释的生命周期问题理解，而不只是笼统称为“防止组合
环”。如果目的和源是同一逻辑寄存器，继续把 move 的旧源物理项透传给较年轻
消费者，会与覆盖旧映射后的物理寄存器释放时序发生冲突；因此当前 RTL 不把这种
自 move 标成 zero-delay 候选。跨过包内另一条同名目的写时，RT/FRT 还会使用
`*_mov_bypass_over_inst1` 一类条件阻止透传过时版本。

### 9.2 乘加（x_mla）

```verilog
// decd.v 第432行
assign x_mla = {x_inst[31:28],x_inst[14:12],x_inst[6:0]} == 14'b0010_001_0001011;
```

T-Head 自定义乘加指令 `mla`，用于向乘法器发射特殊的累积操作。

### 9.3 浮点乘加（x_fmla）

```verilog
// decd.v 第437行
assign x_fmla = ({x_inst[6:4],x_inst[1:0]} == 5'b100_11);
```

FMA 类指令（fmadd/fmsub/fnmsub/fnmadd，opcode 低 5 位为 `10011`），标记供流水线控制使用。

### 9.4 向量乘加（x_vmla）

```verilog
// decd.v 第442~446行
assign x_vmla = x_vec_inst && x_vec_opmvv &&
               ((x_inst[31:26]==6'b101101) || //vmacc
                (x_inst[31:26]==6'b101111))   //vnmsac
             || x_vec_inst && x_vec_opfvv &&
               (x_inst[31:28] == 4'b1011);    //vfmacc
```

向量乘加类指令的标记，用于通知流水线这些指令需要读取目的向量寄存器的当前值（作为累积操作数）。

---

## 10. 非法指令检测

非法指令检测分散在多个层次，最终汇总为 `x_illegal`：

```verilog
// decd.v 第741~749行
assign x_illegal = decd_32_illegal && decd_sel[0]   // 32位整数 case default
                || decd_16_illegal && decd_sel[1]    // 16位 case default
                || decd_i_illegal                    // SYSTEM 指令的精确检测
                || decd_c_illegal                    // RVC 特定非法编码
                || decd_lsu_illegal                  // FS=Off 时的浮点 load/store
                || decd_fp_illegal && decd_sel[2]    // 浮点舍入/FS 检测
                || decd_cache_illegal && decd_sel[3] // Cache 扩展 case default
                || decd_perf_illegal && decd_sel[4]  // 性能扩展 case default
                || decd_vec_illegal && decd_sel[5];  // 向量多维度检测
```

### 10.1 基础非法（decd_i_illegal）

```verilog
// decd.v 第635~659行
assign decd_i_illegal =
   // ecall 精确检测：必须 inst[24:15]==0 且 rd==0
   ({x_inst[31:25],x_inst[14:12],x_inst[6:0]}==17'b0000000_000_1110011)
   && ({x_inst[24:15],x_inst[11:7]} != 15'b0)   //ecall 非法：若有额外字段非零
   && ({x_inst[24:15],x_inst[11:7]} != 15'h400) //ebreak 编码例外
   // sret：检查是否有非法附加字段
   || ...
   // mret：同上
   // sfence.vma：rd 必须为 0
   || ({x_inst[31:25],x_inst[14:12],x_inst[6:0]}==17'b0001001_000_1110011)
      && (x_inst[11:7] != 5'b0)
   // hfence.vvma/hfence.gvma：需要 Hypervisor 模式
   || ... && !cp0_yy_hyper
   // LR.W/D：rs2 必须为 0
   || ({x_inst[31:27],x_inst[14:12],x_inst[6:0]}==15'b00010_010_0101111)
      && (x_inst[24:20] != 5'b0)
```

这里的非法检测非常精细——不仅检测"这是哪类指令"，还检测"指令的保留字段是否为零"，符合 RISC-V 规范对未定义字段的要求。

### 10.2 RVC 特定非法（decd_c_illegal）

```verilog
// decd.v 第664~677行
assign decd_c_illegal =
   ({x_inst[15:13],x_inst[1:0]}==5'b000_00) && (x_inst[12:5]==8'b0) //c.addi4spn nzimm==0
|| ({x_inst[15:13],x_inst[1:0]}==5'b001_01) && (x_inst[11:7]==5'b0) //c.addiw rd==0
|| ({x_inst[15:13],x_inst[1:0]}==5'b011_01) && ({x_inst[12],x_inst[6:2]}==6'b0) //c.lui/c.addi16sp nzimm==0
|| ({x_inst[15:13],x_inst[1:0]}==5'b010_10) && (x_inst[11:7]==5'b0) //c.lwsp rd==0
|| ({x_inst[15:13],x_inst[1:0]}==5'b011_10) && (x_inst[11:7]==5'b0) //c.ldsp rd==0
|| ({x_inst[15:12],x_inst[1:0]}==6'b1000_10) && (x_inst[6:2]==5'b0) && (x_inst[11:7]==5'b0); //c.jr rs1==0
```

这些是 RVC 规范明确定义的"保留编码"，例如 `c.addi4spn` 要求立即数非零，`c.jr` 要求 rs1 非零等。

### 10.3 浮点非法（decd_fp_illegal）

```verilog
// decd.v 第725~735行
assign fp_static_rounding_illegal  = (x_inst[14:12]==3'b101) // rm=101 保留
                                  || (x_inst[14:12]==3'b110); // rm=110 保留
assign fp_dynamic_rounding_illegal = (x_inst[14:12]==3'b111) // 动态舍入模式
                                  && ((cp0_idu_frm==3'b101)   // 但 fcsr.frm 也是非法值
                                     ||(cp0_idu_frm==3'b110)
                                     ||(cp0_idu_frm==3'b111));
assign fp_fs_illegal = (cp0_idu_fs[1:0]==2'b00); // FS=Off：任何浮点操作都非法

assign decd_fp_illegal = decd_fp_inst_illegal   // fp0/fp1 sub-decoder default
                      || fp_static_rounding_illegal
                      || fp_dynamic_rounding_illegal
                      || fp_fs_illegal;
```

浮点非法检测是**动态**的（取决于 fcsr.frm 和 mstatus.fs 的当前值），这要求译码器实时读取 CP0 寄存器的状态，这些信号（`cp0_idu_fs`、`cp0_idu_frm`）从 CP0 广播到 IDU。

---

## 11. 特殊指令译码子模块：`ct_idu_id_decd_special`

`ct_idu_id_decd_special` 在 `ct_idu_id_decd` 内部被实例化，负责识别需要"特殊处理"的指令类型，主要产生三类信号：`x_split_short_type`、`x_split_long_type`、`x_fence_type`。

### 11.1 指令拆分类型（split_short / split_long）

**拆分的体系结构意义**：某些指令语义复杂（如 AMO 需要读-修改-写序列），或需要跨寄存器文件操作（如整数→浮点转换），无法由单一微操作完成，需要在 ID 阶段被**拆分**成多条简单的微操作再进入流水线。

#### split_short_type（6 位，短拆分）

| bit | 指令类型 | 匹配逻辑 |
|-----|----------|----------|
| [0] | JAL/JALR/c.jalr（有返回地址）| `inst[11:7] != 0` 的 JAL/JALR/c.jalr |
| [1] | FP 比较与转换（fcvt.w.s 等）| `{inst[31:27],inst[24:22],inst[6:0]}` 匹配 + FS 检查 + 舍入合法 |
| [2] | XuanTie 索引 load/store（lbib/lbia/...）| `cp0_idu_cskyee && {inst[31:27],inst[14:12],inst[6:0]}`|
| [3] | XuanTie 双字 load/store（lwd/lwud/ldd/swd/sdd）| `cp0_idu_cskyee && {inst[31:27],inst[14:12],inst[6:0]}`|
| [6:4] | 保留 | 恒为 0 |

```verilog
// decd_special.v 第78~83行
assign x_split_short_type[0] = ({x_inst[15:12],x_inst[6:0]}==11'b1001_0000010)
                                && (x_inst[11:7]!=5'd0) //c.jalr（写 ra）
                             || (x_inst[6:0]==7'b1101111)
                                && (x_inst[11:7]!=5'd0) //jal（写 rd）
                             || ({x_inst[14:12],x_inst[6:0]}==10'b000_1100111)
                                && (x_inst[11:7]!=5'd0); //jalr
```

**JAL/JALR 写链接地址的特殊处理**：主译码器中跳转检查微操作的
`dst_vld = 0`，写链接寄存器的能力通过 `split_short_type[0]` 单独标记，交由
`id_split_short` 处理。后者生成一条 `PSEUDO_AUIPC` 微操作：32 位 jal/jalr
向 rd 写入 `PC+4`，压缩 `C.JALR` 向 x1 写入 `PC+2`；另一条微操作只负责跳转
与目标检查。

#### split_long_type（10 位，长拆分）

```verilog
// decd_special.v 第152~164行
assign x_split_long_type[0] = ({x_inst[14:13],x_inst[6:0]}==9'b01_0101111) //AMO opcode
                              && (({x_inst[31:27],x_inst[24:20]}==10'b00010_00000) //lr.w/d
                               || (x_inst[31:27]==5'b00011) //sc.w/d
                               || (x_inst[31:27]==5'b00000) //amoadd.w/d
                               || ... );
assign x_split_long_type[1] = 1'b0; //normal vector（禁用）
assign x_split_long_type[2] = 1'b0; //permute（禁用）
... （[3]~[9] 全部为 0，向量功能预留）
```

当前版本中只有 `split_long_type[0]`（原子指令）是激活的。LR/SC/AMO 指令被标记后，`id_split_long` 将其拆分为 load 微操作 + store 微操作 + 可能的 ALU 操作，实现原子语义。

### 11.2 Fence 指令类型

```verilog
// decd_special.v 第184~221行
assign x_fence_type[0] = cp0_idu_cskyee   // XuanTie sync/dcache 系列
                      && ((x_inst[31:0]==32'h0180000b) //sync
                       || (x_inst[31:0]==32'h0190000b) //sync.s
                       || (x_inst[31:0]==32'h01a0000b) //sync.i
                       || (x_inst[31:0]==32'h01b0000b) //sync.is
                       || (x_inst[31:0]==32'h0010000b) //dcache.call
                       || ...);

assign x_fence_type[1] = (x_inst[31:0]==32'h10200073) //sret
                      || (x_inst[31:0]==32'h30200073) //mret
                      || (x_inst[31:0]==32'h10500073) //wfi
                      || ({x_inst[14:12],x_inst[6:0]}==10'b001_1110011) //csrrw
                      || ... ; //所有 CSR 指令

assign x_fence_type[2] = ({x_inst[14:12],x_inst[6:0]}==10'b001_0001111) //fence.i
                      || ({x_inst[31:25],x_inst[14:0]}==22'b0001001_...) //sfence.vma
                      || hfence_inst;
```

| fence_type 位 | 当前译码集合 | `ct_idu_id_fence` 中可直接确认的区别 |
|---------------|--------------|---------------------------------------|
| `[0]` | XuanTie sync/cache 操作 | ISSUE 时只产生 inst0；POP_INST 时计入 `idu_hpcp_fence_sync_vld` |
| `[1]` | CSR、mret/sret、wfi 等 | ISSUE 时只产生 inst0；非 WFI 时 `idu_rtu_fence_idle` 在非 IDLE 状态也可为 1 |
| `[2]` | fence.i、sfence.vma、hfence | ISSUE 时同时产生 inst0/inst1/inst2；POP_INST 时计入 fence/sync 事件 |

三位是分类位，不是“序列化强度从低到高”的数值编码。`ct_idu_id_fence` 对这些
类别都先等待它所观察的后端空条件，再在 ISSUE 状态下发相应微操作，并在
WAIT_CMPLT 再次等待本地 `fence_pipeline_empty`。具体是 I-cache 失效、TLB
失效、CSR 写入、返回还是低功耗等待，由生成的 opcode 和下游 LSU/CP0/MMU/RTU
处理；不能只由 `fence_type` 位断言“必然刷新整条流水线”或“绝不刷新”。

从体系结构上，把 CSR/return/WFI 送入 fence FSM 可以防止其状态变化与周围指令
无约束交叠。例如部分 CSR 会影响后续译码、异常、特权或执行环境。但并非每条 CSR
都修改同一类状态，精确副作用应按 opcode 和 CP0 实现判断。RTL 在这里能证明的
是该类指令经过统一的 ID fence 状态机，而不是译码器自身执行了刷新。

---

## 12. 向量掩码与 vmb 信号

### 12.1 向量掩码源有效（x_srcvm_vld）

```verilog
// decd.v 第451~455行
assign x_srcvm_vld = x_vec_inst && !x_inst[25] && !x_vec_opcfg   // 通用：vm=0
                  || x_vec_inst && (x_inst[31:28]==4'b0100) &&    // vadc/vmadc/vsbc/vmsbc
                     (x_vec_opivv || x_vec_opivi)
                  || ((x_inst[6:0]==7'b0000111)||(x_inst[6:0]==7'b0100111)) //vld/vst
                     && !x_inst[25]
                     && ((x_inst[14:12]==3'b000) || x_inst[14] && |x_inst[13:12]);
```

`x_inst[25]` 是 RISC-V V 扩展的 `vm` 位：`vm = 0` 表示该指令使用 v0 作为掩码，`vm = 1` 表示无掩码（所有元素参与）。当 `vm = 0` 时 `x_srcvm_vld = 1`，告知重命名器需要为 v0 建立数据依赖。

特例：vadc/vmadc/vsbc/vmsbc 的语义是"进位加/减"，它们**强制**使用 v0 作为进位寄存器，且**要求** `vm = 1`（否则是非法指令），但仍需要读 v0，因此这里的逻辑是在 `vm = 1` 的情况下为这类指令单独置位 `srcvm_vld`。

### 12.2 vmb 信号

```verilog
// decd.v 第460~465行
assign x_vmb = (x_inst[6:0]==7'b0000111)  // 向量 load opcode
              && ((x_inst[14:12]==3'b000)  // unit-stride
                  || (x_inst[14:12]==3'b101) // stride
                  || (x_inst[14:12]==3'b110) // indexed unordered
                  || (x_inst[14:12]==3'b111)) // indexed ordered
              && vlsu_ld_srcv2_vld;           // VLSU 源 2 有效（当前恒为 0）
```

`x_vmb` 标记的是"带掩码的向量 load 且目标是掩码寄存器"的情况。由于 `vlsu_ld_srcv2_vld = 0`，该信号当前恒为 0，预留给向量 LSU 激活时使用。

---

## 13. 译码输出汇总与下游影响

### 13.1 信号流向 id_dp

`ct_idu_id_decd` 的所有输出都在 `ct_idu_id_dp` 中被处理，经过重命名前的数据准备：

```
id_decd0/1/2
    │
    ▼ inst_type、src0/1/2_vld、dst_vld、illegal、length...
ct_idu_id_dp （数据通路）
    │
    ├──► ct_idu_id_fence   （处理 fence 类型，触发流水线序列化）
    ├──► ct_idu_id_split_short（处理 split_short，生成额外微操作）
    ├──► ct_idu_id_split_long （处理 split_long，原子指令拆分）
    └──► ct_idu_ir_dp          ──► ct_idu_ir_rt（重命名）
                                       │
                               inst_type 决定进入哪个 AIQ
                               src0/1/dstf 等决定 RAT 查找端口
```

### 13.2 inst_type 驱动发射队列选择

在重命名/发射阶段，`x_inst_type` 的 one-hot 位直接决定这条指令写入哪个发射队列（AIQ）。具体地：

```
x_inst_type[0] = ALU  → AIQ0 或 AIQ1（整数 ALU 队列，C910 可能有两个）
x_inst_type[1] = BJU  → 整数 ALU 队列中的 BJU 端口
x_inst_type[2] = MULT → 整数 ALU 队列（乘法器通路）
x_inst_type[3] = DIV  → 整数 ALU 队列（除法器通路，独占）
x_inst_type[4] = LSU  → LSU 发射队列（load 端口）
x_inst_type[5] = store→ LSU 发射队列（store 端口）
x_inst_type[6] = PIPE67 → 浮点/向量发射队列（双通道）
x_inst_type[7] = PIPE6  → 浮点发射队列（pipe6 端口）
x_inst_type[8] = PIPE7  → 浮点发射队列（pipe7 端口）
x_inst_type[9] = SPECIAL→ 特殊指令队列
```

### 13.3 src/dst 有效信号驱动重命名

各 `*_vld` 信号在重命名阶段（`ct_idu_ir_rt`、`ct_idu_ir_frt`、`ct_idu_ir_vrt`）分别驱动对应的 RAT 查找和物理寄存器分配：

| 信号 | 重命名阶段操作 |
|------|---------------|
| `src0_vld = 1` | `src0_reg` 的 RAT 读出结果是本指令的真实源依赖；无效时下游 ready/wb 被置为无依赖状态 |
| `src1_vld = 1` | `src1_reg` 的 RAT 读出结果是本指令的真实源依赖；无效时下游 ready/wb 被置为无依赖状态 |
| `dst_vld = 1, !dst_x0` | 指令存在有效整数目的；RTU 分配端提供新 preg，整数 RAT 在有效写条件下更新 |
| `dstf_vld = 1` | 指令存在有效标量浮点目的；对应分配与 FRT 更新协议生效 |
| `dstv_vld = 1` | 接口语义上存在有效向量目的；当前开源 VRT 的实际实现边界还需结合 `10_ir_vrt.md` 阅读 |
| `dste_vld = 1` | 指令会产生浮点异常标志目的版本，参与异常标志重命名协议 |
| `dst_x0 = 1` | 目的在体系结构上是 x0；当前 IR 数据通路把目的 preg 数据屏蔽为 0，不能把它描述成一次普通 RAT 重命名 |

需要区分**组合读出**和**语义有效**。例如 `ct_idu_ir_rt` 的源端先按
`dp_rt_instN_srcM_reg` 经过 `case` MUX 读出表项；当 `srcM_vld=0` 时，再把送往
下游的 ready/wb 置成“无需等待”。所以不能说无效源“完全不进入 RAT 查找电路”。
有效位的 RTL 可证明作用，是限定该读出是否构成本指令的真实依赖，并参与目的
更新、分配和后续控制。它是否因综合优化或时钟门控降低了多少动态功耗，必须以
门级网表和功耗分析为准，不能仅由功能 RTL 断言。

### 13.4 译码信号与 illegal 的优先级

非法指令标志 `x_illegal` 在 `id_dp` 中被捕获，在该指令到达重命名阶段时触发非法指令异常（通过异常处理流程），后续流水线不会为非法指令真正执行任何操作。

---

## 附录 A：调试速查表

### A.1 根据指令快速定位 case 分支

| 你的指令 | 找哪个 always block | 匹配键 |
|----------|---------------------|--------|
| 普通整数（add/ld 等）| decd_32（第 1167 行）| `{inst[31:25],inst[14:12],inst[6:2]}` |
| RVC（c.addi 等）| decd_16（第 971 行）| `{inst[15:10],inst[6:5],inst[1:0]}` |
| 浮点运算（fadd 等）| decd_fp0（第 1682 行）| `{inst[31:20],inst[14:12]}` |
| FMA（fmadd 等）| decd_fp1（第 2133 行）| `{inst[26:25],inst[4:2]}` |
| Cache 指令（dcache.iva 等）| decd_cache（第 2323 行）| `{inst[25],inst[24:20],inst[19:15]}` |
| 性能扩展（addsl/mula 等）| decd_perf（第 2434 行）| `{inst[31:25],inst[14:12]}` |
| 向量（vadd.vv 等）| decd_v（第 3144 行）| `{inst[31:26],inst[14:12]}` |
| AMO/split 指令 | decd_special（split_long）| 见第 11 节 |
| CSR/fence 类 | decd_special（fence）| 见第 11 节 |

### A.2 常见信号含义快查

| 信号 | 含义 |
|------|------|
| `x_inst_type == ALU` | 进整数 ALU 发射队列 |
| `x_dst_vld && !x_dst_x0` | 需要在整数 RAT 分配新的物理寄存器 |
| `x_dste_vld` | 需要写 fcsr.fflags（浮点/向量异常标志）|
| `x_fmla` | 三源浮点乘加，占用 srcf0/srcf1/srcf2 三个浮点读端口 |
| `x_vmla` | 向量乘加，dst 既是目的也是源（读-改-写语义）|
| `x_mov / x_fmov` | 同包 move 依赖穿透候选；RAT 目的仍写入新分配物理号，详见 9.1 节 |
| `x_split` | 需要长拆分（如 AMO），由 id_split_long 处理 |
| `x_split_short` | 需要短拆分（如 JAL 写 ra），由 id_split_short 处理 |
| `x_fence` | 需要 fence/序列化处理，由 id_fence 处理 |
| `x_illegal` | 触发非法指令异常 |
