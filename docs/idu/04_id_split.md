# C910 IDU 指令拆分模块详解

> RTL 文件：
> - `ct_idu_id_split_short.v`（1290 行）
> - `ct_idu_id_split_long.v`（7600 行）
>
> 被 `ct_idu_id_dp.v` 实例化：`x_ct_idu_id_split_short0/1/2`（各处理一路解码指令），`x_ct_idu_id_split_long`（全局唯一）。

---

## 1. 为什么需要拆分

RISC-V 标量指令集中，几乎每条指令都能直接映射到一个微操作（µOP）。但以下情形下，单条 ISA 指令无法用一个 µOP 完成：

| 场景 | 原因 | 示例 |
|------|------|------|
| PC 相对跳转（JAL/CJALR） | 需要先计算 PC+4/PC+2 作为链接地址，再跳转 | `jal rd, label` |
| 向量/FP 类型转换 | 结果宽度与操作宽度不一致，使用临时寄存器中转 | `fcvt.w.s` |
| T-Head 扩展访存（lsi/lsd） | 带后索引寻址，地址更新 + 访存两步 | `lwia rd, (rs1), imm5<<2` |
| 向量普通运算（LMUL>1） | 向量寄存器组最多 4 个物理寄存器，每次最多 4 µOP | `vadd.vv vd, vs2, vs1`（LMUL=8） |
| 向量访存 | stride/index 每拍只能做 1 元素，循环拆分 | `vlse32.v vd, (rs1), rs2` |
| 向量规约 | 需要逐级归并，中间结果通过临时向量寄存器传递 | `vfredosum.vs vd, vs2, vs1` |
| 向量置换（vrgather/vslide/vcompress） | 每拍处理一个目的寄存器 group | `vrgather.vv vd, vs2, vs1` |
| AMO 带 aq/rl | 需要在 lr/amoload-amoalu-amostore 前后插 fence | `amoswap.w.aqrl rd, rs2, (rs1)` |

**短拆分**（`split_short`）：固定拆成 2 个 µOP，纯组合逻辑，无状态机，延迟为 0。  
**长拆分**（`split_long`）：拆成 1~4 个 µOP/周期，有多个状态机，需要多个 ID 周期，会向 `id_ctrl` 反压 stall。

---

## 2. 微操作包格式（IR，178 位）

两个模块均使用相同的 178 位 IR（Instruction Record）格式，关键字段如下：

```
位[177]        IR_VL_PRED     向量长度预测有效
位[176:169]    IR_VL          向量长度（8 位）
位[168]        IR_VMB         向量 load 有效元素 mask-before 标志
位[167:153]    IR_PC          PC[14:0]
位[152:150]    IR_VSEW        标量元素宽度 SEW（3 位）
位[149:148]    IR_VLMUL       LMUL（2 位：00=1, 01=2, 10=4, 11=8）
位[146:140]    IR_SPLIT_NUM   拆分序号（7 位）
位[139]        IR_NO_SPEC     不可推测执行
位[135]        IR_SPLIT_LAST  本 µOP 是该指令最后一拍（IR_SPLIT 的反相）
位[134]        IR_VMLA        向量 MAC/cmp/reduce 等需要 vd 作为第三操作数
位[133:130]    IR_IID_PLUS    后续 µOP 与本 µOP 的 IID 偏移（0=共用同一 IID）
位[118]        IR_LENGTH      32 位指令（1=32b, 0=16b/RVC）
位[117]        IR_INTMASK     中间 µOP 屏蔽中断（只在最后一拍允许中断）
位[116]        IR_SPLIT       仍有后续 µOP（1=还没结束）
位[115:106]    IR_INST_TYPE   10 位流水线类型（ALU/BJU/MULT/DIV/LSU/PIPE6/PIPE7/PIPE67/SPECIAL）
位[105:100]    IR_DSTV_REG    目的向量寄存器（6 位：[5]=使用临时寄存器 tmp_reg）
位[96:91]      IR_SRCV1_REG   源向量寄存器 vs1（6 位）
位[89:84]      IR_SRCV0_REG   源向量寄存器 vs2（6 位）
位[53:48]      IR_DST_REG     目的整数寄存器（6 位）
位[45:40]      IR_SRC1_REG    源整数寄存器 rs2（6 位）
位[38:33]      IR_SRC0_REG    源整数寄存器 rs1（6 位）
位[31:0]       IR_OPCODE      原始 32 位指令编码
```

`IR_SPLIT=1` 表示"还有更多 µOP"，`IR_SPLIT_LAST = !IR_SPLIT` 用于 ROB 判断是否提交该指令。`IR_INTMASK=1` 使中间 µOP 不响应中断，确保一条 ISA 指令的多个 µOP 原子提交。

---

## 3. 短拆分模块（`ct_idu_id_split_short`）

### 3.1 模块接口

```verilog
// 输入（来自 id_dp，一路译码通道）
input  [31:0]  dp_split_short_inst;      // 32 位原始指令
input  [6:0]   dp_split_short_type;      // 拆分类型独热码
input  [7:0]   dp_split_short_vl;        // 向量长度
input  [1:0]   dp_split_short_vlmul;     // LMUL
input  [2:0]   dp_split_short_vsew;      // SEW
// 输出（回 id_dp）
output [177:0] split_short_dp_inst0_data;  // µOP 0
output [177:0] split_short_dp_inst1_data;  // µOP 1
output [3:0]   split_short_dp_dep_info;    // 内部依赖掩码
```

无时钟寄存器，纯组合逻辑。

### 3.2 type 独热码含义

```
dp_split_short_type[0]  = JAL/CJALR 类
dp_split_short_type[1]  = FP 类型转换
dp_split_short_type[2]  = lsi（T-Head 扩展索引访存）
dp_split_short_type[3]  = lsd（T-Head 扩展双字访存）
dp_split_short_type[6:4]= 向量（bit[4]=norm, bit[5]=mpop, bit[6]=vext）
```

### 3.3 各类指令的拆分方案

#### 3.3.1 JAL / CJALR

标准 RISC-V 的 `jal rd, label` 语义是"将 PC+4 写 rd，然后跳转"。在 C910 的微结构中，链接地址的生成和跳转分离为两个 µOP：

```
µOP 0（SPECIAL 流水）：pseudo_auipc rd, 4/2
    作用：rd ← PC + 4（32 位指令）或 PC + 2（16 位 C.JALR）
    IR_SPLIT = 1, IR_IID_PLUS = 4'b0001（µOP1 与 µOP0 共用 IID+1）

µOP 1（BJU 流水）：jal/jalr r0, target
    作用：执行实际跳转，rd 不再写（由 µOP0 完成）
    IR_SPLIT = 0（最后一拍）
```

为什么这样拆：C910 的 BJU 流水线只执行跳转，不做通用写寄存器；链接地址通过 SPECIAL 流水的"伪 AUIPC"指令高效计算。

关键 RTL（行 308~353）：
```verilog
// µOP 0: pseudo_auipc，opcode = 7'b0011111
jal_inst0_data[31:20] = (jal_cjalr) ? 12'd2 : 12'd4; // 立即数 = 指令长度
jal_inst0_data[11:7]  = (jal_cjalr) ? 5'd1 : jal_inst[11:7]; // C.JALR 链接 r1
jal_inst0_data[IR_SPLIT] = 1'b1;
jal_inst0_data[IR_IID_PLUS:IR_IID_PLUS-3] = 4'b1;

// µOP 1: 真正的跳转指令
jal_inst1_data[IR_SRC0_VLD] = !jal_jal; // jalr 需要读 rs1，jal 不需要
jal_inst1_data[IR_SPLIT] = 1'b0; // 最后一拍
```

#### 3.3.2 lsi（T-Head 扩展索引访存）

T-Head 扩展指令 `lwia rd, (rs1), imm5<<2` 语义：先用 rs1 作基址访存，再将 rs1 += sign_ext(imm5<<2)。

```
µOP 0（ALU）：addi rs1, rs1, sign_ext(imm5<<scale)
    更新基址寄存器
    IR_SPLIT = 1

µOP 1（LSU/LSU_P5）：lw/sw rd, offset(rs1)
    若为 post 模式，offset = 0；否则 offset = 符号扩展偏移
    IR_SPLIT = 0
```

关键点：`lsi_post = lsi_inst[28]`，后索引模式时 µOP1 的偏移为 0，此时地址直接用更新前的 rs1；前索引模式 µOP1 的偏移为真实偏移，与 µOP0 形成 RAW 依赖（rs1 先加后读），`dep_info[1:0]=2'b11` 表示相邻 µOP 之间存在整数寄存器依赖。

#### 3.3.3 lsd（T-Head 扩展双字访存）

`ldia rd, rd+1, (rs1), imm5<<scale` 访存两个相邻字/双字：

```
µOP 0（LSU 或 LSU_P5）：lw/sd rd, base_offset(rs1)
    IR_SPLIT = 1

µOP 1（LSU 或 LSU_P5）：lw/sd rd+1, (base_offset + 4 or 8)(rs1)
    IR_SPLIT = 0
```

两个 µOP 都用相同基址 rs1，偏移量差 4（字）或 8（双字）。`dep_info[1:0]=2'b11` 指示两个 µOP 之间有 preg 依赖（虽然这里无直接数据依赖，只是确保顺序提交）。

#### 3.3.4 FP 类型转换

浮点类型转换（如 `fcvt.w.d`）在 C910 中通过一个内部临时 FP 寄存器 `f_tmp`（编号 32，即 `6'b100000`）中转：

```
µOP 0（PIPE7）：pseudo_fcvt.t.t  f_tmp, fs（截断/扩展到目标格式）
    操作浮点数，结果写入 f_tmp（IR_DSTF_REG = 6'd32）
    IR_SPLIT = 1

µOP 1（PIPE67 或 PIPE7）：fmv.x.w/d  rd, f_tmp
    将 f_tmp 中的结果搬到整数寄存器
    IR_SRCF0_REG = 6'd32
    IR_SPLIT = 0
```

对于整数→FP 方向（`fcvt_type1`）：µOP0 是 ALU（`fmv.w.x`，整数→fptmp），µOP1 是 PIPE7（最终转换）。这样做的原因是浮点流水线（PIPE6/PIPE7）不直接连接整数寄存器文件，需要先通过 ALU/移动指令搬运。

#### 3.3.5 向量短拆分（norm / mpop / vext）

**向量普通指令（norm）** 在 LMUL=2 时，涉及 2 个物理寄存器，split_short 给出 2 个 µOP，每个 µOP 操作一个 vreg：

```
µOP 0：操作 vs2[0]/vs1[0] → vd[0]（寄存器基编号）
µOP 1：操作 vs2[1]/vs1[1] → vd[1]（基编号 | offset）
```

偏移量计算（行 919~953）：
```verilog
// 普通指令：srcv0_offset = {3'b001, 3'b000}，即 µOP0 用 vreg+0，µOP1 用 vreg+1
// 宽化指令（wide）：srcv0_offset = {3'b000, 3'b000}，
//   vs2 不偏移（源更宽），vd 偏移（目的更宽）
// 缩减指令（narr）：destv_offset = {3'b000, 3'b000}（目的不偏移）
```

`vec_src_switch`（行 955~970）：对 vsub、vwsub.w、vmadd 等"减法/被减数"或 MAC 特殊形式指令，vs1/vs2 在硬件中交换，使减法的被减数总来自 srcv0 端口。

**向量 mpop（vmpopc.m/vmfirst.m）**：
```
µOP 0（PIPE67）：vmpopc/vmfirst，结果写到 v_tmp（6'b100000）
µOP 1（PIPE67，实为 mfvr/vext.x.v）：将 v_tmp[0] 搬到整数 rd
```
因为 vmpopc/vmfirst 的结果是标量（popcount 或首个置位索引），执行单元生成到向量临时寄存器，再通过 mfvr 提取。

**向量 vext（vext.x.v 取元素到整数）**：
```
µOP 0（ALU）：mtvr，将 rs1（索引）写入 v_tmp，opcode 编码为 vmv.s.x
µOP 1（PIPE67）：vext.x.v vd_int, vs2, v_tmp（用 v_tmp 中的索引）
```
先把标量索引通过 ALU 写入向量临时寄存器，再用向量执行单元按索引取元素。

### 3.4 三路实例化

`id_dp` 中并行实例化了三个 `split_short`，分别对应三路 decode 通道：

```
x_ct_idu_id_split_short0  ← inst0 通道
x_ct_idu_id_split_short1  ← inst1 通道
x_ct_idu_id_split_short2  ← inst2 通道
```

三路彼此独立，互无依赖，全组合逻辑，面积/延迟均为可接受的三倍。需要三份是因为 C910 的 ID 级一次 fetch/decode 最多 3 条指令，每条均可能需要短拆分。

---

## 4. 长拆分模块（`ct_idu_id_split_long`）

### 4.1 模块接口

```verilog
// 输入
input  [31:0]  dp_split_long_inst;           // 原始指令
input  [9:0]   dp_split_long_type;           // 10 位独热类型
input  [7:0]   dp_split_long_vl;             // 向量长度
input  [1:0]   dp_split_long_vlmul;          // LMUL
input  [2:0]   dp_split_long_vsew;           // SEW
input          ctrl_split_long_id_inst_vld;  // 来自 ctrl：当前拍指令有效
input          ctrl_split_long_id_stall;     // 来自下游：stall 请求
// 输出
output [177:0] split_long_dp_inst0_data;  // µOP 0 数据
output [177:0] split_long_dp_inst1_data;  // µOP 1 数据
output [177:0] split_long_dp_inst2_data;  // µOP 2 数据
output [177:0] split_long_dp_inst3_data;  // µOP 3 数据
output [3:0]   split_long_ctrl_inst_vld;  // µOP 0/1/2/3 有效位
output         split_long_ctrl_id_stall;  // 向上游发 stall（还未拆完）
output [16:0]  split_long_dp_dep_info;    // 17 位内部依赖掩码
```

有时钟域，每类拆分使用独立门控时钟（gated clock）节能。

### 4.2 type 独热码含义

```
dp_split_long_type[0]  = AMO（原子内存操作）
dp_split_long_type[1]  = vec_norm（向量普通算术/访存单元stride指令）
dp_split_long_type[2]  = vec_perm（vrgather/vslide/vcompress）
dp_split_long_type[3]  = vec_fred（向量浮点规约）
dp_split_long_type[4]  = vec_stride（向量 stride ld/st）
dp_split_long_type[5]  = vec_index（向量 index ld/st）
dp_split_long_type[6]  = vec_amo（向量原子操作）
dp_split_long_type[7]  = zvlsseg_unit（向量 segment unit stride ld/st）
dp_split_long_type[8]  = zvlsseg_stride（向量 segment stride ld/st）
dp_split_long_type[9]  = zvlsseg_index（向量 segment index ld/st）
```

### 4.3 依赖信息（`split_long_dp_dep_info`，17 位）

```
位[0]  DEP_INST01_SRC0_MASK：µOP1 的 src0 读 µOP0 的 dst（整数）
位[1]  DEP_INST01_SRC1_MASK：µOP1 的 src1 读 µOP0 的 dst
位[2]  DEP_INST12_SRC0_MASK：µOP2 读 µOP1 dst
位[3]  DEP_INST12_SRC1_MASK
位[4]  DEP_INST23_SRC0_MASK：µOP3 读 µOP2 dst
位[5]  DEP_INST23_SRC1_MASK
位[6]  DEP_INST02_PREG_MASK：µOP0 和 µOP2 写相同整数寄存器
位[7]  DEP_INST13_PREG_MASK
位[8..13]  DEP_INSTxy_VREG_MASK：向量寄存器依赖
位[14..16] DEP_INSTxy_SRCV1_MASK：srcv1 依赖（用于缩减指令链）
```

这些信息告诉 id_dp 中的 issue 路径，同一拍内的多个 µOP 之间有哪些 forwarding 依赖，避免 RAW 导致错误调度。

---

## 5. AMO 拆分（`dp_split_long_type[0]`）

### 5.1 AMO 语义分解

RISC-V AMO 指令（`amoswap/amoadd/amoand/amoor/amoxor/amomin/amomax` 等）的语义是：
1. 从地址读取旧值（lr 语义）
2. 对旧值和 rs2 执行 ALU 操作
3. 将新值写回地址（sc 语义）

带 `aq`（acquire）时需要在操作后加 fence；带 `rl`（release）时需要在操作前加 fence。

### 5.2 状态机

```
         amo_sm_start
         (aq && rl && split_inst)
              |
   AMO_IDLE ─────────────► AMO_SPLIT
      ▲                         │
      └─── !stall ──────────────┘
           (第 2 周期 fence.aq 发出后回 IDLE)
```

`amo_more_than_4 = amo_split_inst && amo_aq && amo_rl`，即只有同时带 aq 和 rl 的 AMO 才需要 2 周期（5 个 µOP 超出 4 槽）。

### 5.3 µOP 序列（不同 aq/rl 组合）

| 情形 | µOP0 | µOP1 | µOP2 | µOP3 |
|------|------|------|------|------|
| 纯 amoXXX（无 aq/rl） | amoload | amoalu | amostore | — |
| aq 只有 | amoload | amoalu | amostore | fence.aq |
| rl 只有 | fence.rl | amoload | amoalu | amostore |
| aq+rl（第 1 周期） | fence.rl | amoload | amoalu | amostore |
| aq+rl（第 2 周期/AMO_SPLIT 状态） | fence.aq | — | — | — |
| lr（+aq/rl） | [fence.rl] | lr | [fence.aq] | — |
| sc（+aq/rl） | [fence.rl] | sc | [fence.aq] | — |

关键 RTL（行 1497~1591）：
```verilog
casez({amo_cur_state, amo_aq, amo_rl, lr_inst, sc_inst})
  {AMO_SPLIT, ...}: // 第 2 周期只发 fence.aq
    amo_inst0_data = amo_fence_aq_inst_data;
    amo_inst1/2/3  = 0;
  {AMO_IDLE, ?, 1'b1, 0, 0}: // 有 rl：先 fence.rl，再三个 AMO µOP
    amo_inst0_data = amo_fence_rl_inst_data;
    amo_inst1_data = amo_amoload_inst_data;
    amo_inst2_data = amo_amoalu_inst_data;
    amo_inst3_data = amo_amostore_inst_data;
```

`amoload` 的 `IR_IID_PLUS = 4'd2`，意味着其后面跟着的 amoalu 和 amostore 在相同 IID 下发射，确保三步原子完成。`amoalu` 的 `IR_IID_PLUS = 4'd1`。

内部依赖：`amo_012_dep_info` 设置 `DEP_INST01_SRC0 + DEP_INST12_SRC0 + DEP_INST02_PREG`，表示 amoalu 的 src0 来自 amoload 的 dst（旧值），amostore 的 src0 来自 amoalu 的 dst（新值），且 amoload 和 amostore 写同一个整数寄存器。

---

## 6. 向量普通指令拆分（`dp_split_long_type[1]`）

这是 C910 向量实现的核心路径，覆盖向量算术、单步长访存、整数/浮点向量指令。

### 6.1 为什么需要多个 µOP

C910 向量执行单元每拍处理 **1 个物理向量寄存器**（128 位，含 SEW=64 时 2 个元素，SEW=32 时 4 个元素等）。当 LMUL > 1 时，一条指令需要的逻辑向量寄存器跨越多个物理寄存器：

```
LMUL=1：1 个物理 vreg → 1 µOP（同一周期 1 槽）
LMUL=2：2 个物理 vreg → 1 或 2 µOP
LMUL=4：4 个物理 vreg → 最多 4 µOP/周期（1~2 周期）
LMUL=8：8 个物理 vreg → 最多 8 µOP（2 周期，每周期 4 槽）

宽化/缩减指令（wide/narr）源或目的寄存器数量翻倍：
  LMUL=4, wide → 等效处理 8 个 vreg → 2 周期
  LMUL=2, narr → 等效处理 4 个 vreg → 可能 2 周期
```

### 6.2 状态机

```
              vec_norm_sm_start
              (slow_0 或 slow_1)
                     |
  VEC_NORM_IDLE ─────┴───────────► VEC_NORM_1ST (第 1 周期)
       ▲                                   │
       │                                   ├── slow_1 ──► VEC_NORM_2ND (第 2 周期)
       │                                   │
       └───── !stall ─────────────────────┘
```

状态：
- `VEC_NORM_IDLE`：等待或直接单周期完成
- `VEC_NORM_1ST`：第 1 个拆分周期（发 µOP 0/1/2/3 的前半）
- `VEC_NORM_2ND`：第 2 个拆分周期（发 µOP 0/1/2/3 的后半，带 `IR_SPLIT_NUM[4]=1`）

触发慢速路径的条件：
```verilog
// slow_0：有标量 GPR → 向量操作数（需要先 mtvr）
vec_norm_split_slow_0 = (vec_opivx || vec_opmvx || vec_opfvf && !vec_inst_fmv);

// slow_1：需要第 2 个拆分周期
vec_norm_require_2nd = vec_type_wide_narr && (vec_lmul == 2'b10) ||  // wide/narr + LMUL=4
                       !vec_type_wide_narr && (vec_lmul == 2'b11);    // 普通 + LMUL=8
```

### 6.3 每周期最多 4 个 µOP

长拆分每周期输出 4 路 µOP（`inst0~inst3`）。有效槽数由 `vec_norm_inst_vld[3:0]` 控制：

```verilog
// 行 3435~3438
assign vec_norm_inst_vld[0] = vec_norm_cur_mtvr || vec_norm_cur_1st || vec_norm_cur_2nd;
assign vec_norm_inst_vld[1] = vec_norm_cur_1st && !vec_norm_inst_0_finish || vec_norm_cur_2nd;
assign vec_norm_inst_vld[2] = vec_norm_cur_1st && !inst_0_finish && !inst_1_finish || vec_norm_cur_2nd;
assign vec_norm_inst_vld[3] = vec_norm_cur_1st && !inst_0_finish && !inst_1_finish || vec_norm_cur_2nd;
```

`vec_norm_inst_N_finish` 标记某槽是否为该周期的最后 µOP：
```verilog
assign vec_norm_inst_0_finish = cur_1st && (split_num == 4'b0001); // LMUL=1, 只需 1µOP
assign vec_norm_inst_1_finish = cur_1st && (split_num == 4'b0010); // LMUL=2, 需 2µOP
assign vec_norm_inst_3_finish = cur_1st && (split_num == 4'b0100)  // LMUL=4 第 1 周期
                              || cur_2nd && (split_num == 4'b1000); // LMUL=8 第 2 周期
```

其中 `vec_norm_split_num = (wide/narr ? 2 : 1) << vlmul`，即宽化/缩减指令等效翻倍。

### 6.4 标量→向量 MTVR（寄存器搬运）预处理

当 opcode 为 `opivx/opmvx/opfvf`（使用 GPR 或 FPR 作源操作数）时，在正式向量运算前需要先把标量寄存器内容广播到全向量寄存器（MTVR：Move To VReg），然后向量运算才能读向量寄存器文件：

```
第 0 周期（VEC_NORM_IDLE 看到 slow_0，发 MTVR 而非运算）：
  µOP 0（ALU 或 PIPE67）：vmv.v.x / vfmv.v.f
    src：整数 rs1（IR_SRC0_REG）或 FPR（IR_SRCF1_REG）
    dst：v_tmp（IR_DSTV_REG = 6'b100000）
    IR_IID_PLUS = vec_norm_split_num（让后续 µOP 偏移 IID）

第 1 周期（VEC_NORM_1ST 状态）：
  µOP 0/1/2/3：正式向量运算，src 之一读 v_tmp（临时向量寄存器）
    IR_SRCV0_REG[5] = vec_norm_srcv0_tmp（表示来自 tmp_reg）
    IR_SRCV1_REG[5] = vec_norm_srcv1_tmp
```

关键 RTL（行 3136~3167）：
```verilog
// MTVR 指令编码（vmv.v.x / vfmv.v.f）
vec_mtvr_inst_op[31:26] = 6'b010111;  // vmv.v.x opcode
vec_mtvr_inst_op[25]    = 1'b1;       // 无 mask（总是广播）
vec_mtvr_inst_op[19:15] = vec_inst[19:15]; // rs1
vec_mtvr_inst_op[14:12] = vec_opfvf ? 3'b101 : 3'b100; // .f 或 .x
// 写临时向量寄存器
vec_norm_mtvr_data[IR_DSTV_REG:IR_DSTV_REG-5] = 6'b100000; // v_tmp
vec_norm_mtvr_data[IR_IID_PLUS:IID_PLUS-3]     = vec_norm_split_num; // 让下一拍等本拍
```

### 6.5 寄存器偏移计算

每个 µOP 操作的具体物理向量寄存器通过偏移量确定（行 3063~3106）：

```
普通指令（LMUL=N）：
  srcv0_offset = {3, 2, 1, 0}（4 个 µOP 对应 vreg+3/+2/+1/+0）
  加上 vec_norm_cur_2nd ? 4 : 0（第 2 周期偏移 +4）

宽化指令（wide）：
  srcv0_offset（源）= {1, 1, 0, 0}（源不宽化，每 2 µOP 一组）
  destv_offset（目的）= {3, 2, 1, 0}（目的是宽化后的）

缩减指令（narr）：
  destv_offset = {1, 1, 0, 0}（目的更窄，每 2 µOP 写同一宽度目的）
  srcv0_offset = {3, 2, 1, 0}（源为宽的）
```

举例 `vadd.vv vd, vs2, vs1`（LMUL=4）：
```
µOP0：vd+0 = vs2+0 + vs1+0
µOP1：vd+1 = vs2+1 + vs1+1
µOP2：vd+2 = vs2+2 + vs1+2
µOP3：vd+3 = vs2+3 + vs1+3
（全部在同一个 ID 周期发出，vld[3:0] = 4'b1111）
```

### 6.6 向量源寄存器特殊情形

**向量规约（vec_inst_red）**：
- µOP0~N-1：vd 写临时规约寄存器（6'b100001），src0 是 vs2 的各段，src1 是 vd_acc
- 最后 µOP（vec_norm_inst_3_finish = 1）：目的写回实际 vd，src1 特殊处理（读整数 r1 即累加中间结果）

**比较指令（vec_type_cmp）**：
- destv_offset 始终为 0（目的是 mask 寄存器 v0，不随 LMUL 偏移）

**fcvt 指令（vec_type_fcvt）**：
- srcv1 特殊地读 destv_vreg（目的向量寄存器作为第二操作数），以实现 round-to-nearest 需要读旧值的语义

**src_switch**：以下指令在 C910 中源操作数顺序被交换，使减法的被减数对应 srcv0 端口（行 3108~3131）：
```
vsub/vsbc/vmsbc/vmsltu/vmslt/vssubu/vssub/vasub（整数减法类）
vwsubu/vwsub/vwsubu.w/vwsub.w（宽化减法）
vmadd/vmsub/vnmsub（MAC 减法形式）
vfmacc/vfwmacc、vfnmacc/vfnmsub 等浮点 MAC
vfrdiv/vfrsub（反向除/减）
vmfgt/vmfge（浮点比较 .vf 格式）
```

---

## 7. 向量置换指令拆分（`dp_split_long_type[2]`）

置换类指令（vrgather.vv、vslideup、vslidedown、vcompress）的特点是：目的寄存器和源寄存器之间存在**非规则的跨寄存器组依赖**，每个目的 vreg segment 都可能来自任意源 vreg segment，无法像普通指令那样简单按 LMUL 线性展开。

### 7.1 vslide1up/vslide1down（标量版，`vslide1_stride=1`）

使用独立 VSLIDE 状态机（5 状态：IDLE/ONE/TWO/THREE/FOUR）。以 `vslide1up.vx vd, vs2, rs1` 为例（将整个向量向上移一个元素，最低位插入 rs1）：

```
µOP 0（MTVR，ALU）：将 rs1 写入 v_tmp（vmv.s.x）

LMUL=1：
  µOP 1：vslideup v_tmp 只需 1 µOP，处理整个 vd

LMUL=2（2 个 vreg segment）：
  µOP 1：处理 segment 1（高段），src0 = vs2+1，src1 = v_tmp（slide 出口）
  µOP 2（下一周期）：处理 segment 0（低段），需要 src1 = vs2+1 的最后一元素
         此时 src1 来自上一轮 µOP 的结果 → 需要 VSLIDE_TWO 状态
```

`vslide_mtvr_fwd_inst` 控制 MTVR µOP 的 IID_PLUS（需要等多少拍后续 µOP）：
```verilog
case(vec_lmul)
  2'b00: vslide_mtvr_fwd_inst = 4'b0001; // LMUL=1, 只需 1 拍后续
  2'b01: vslide_mtvr_fwd_inst = vslidedown ? 4'b0011 : 4'b0001;
  2'b10: vslide_mtvr_fwd_inst = vslidedown ? 4'b0111 : 4'b0001;
  2'b11: vslide_mtvr_fwd_inst = vslidedown ? 4'b1111 : 4'b0001;
```
vslidedown 需要更多后续拍数，因为它从高端插入。

### 7.2 vrgather.vv / vslideup.vv / vslidedown.vv / vcompress.vm（VPERM 状态机）

对于非标量版本（vec-vec 格式），使用 VPERM 状态机（3 状态：IDLE/GMV/VPR）：

```
VPERM_IDLE：IDLE 态收到新指令
  若需要 MTVR（GPR 源操作数 或 LMUL>1）→ 转 VPERM_VPR
  否则（LMUL=1，无 GPR 源）→ 直接单周期完成

VPERM_VPR：主要 gather/permutation 执行
  每周期输出最多 4 个 µOP（每 µOP 处理 1 个 vs2 vreg segment）
  vpr_counter 跟踪当前处理到哪一组
  当 vpr_cnt_over → 回 IDLE
  若遇到需要 MTVR 插入（vperm_require_mtvr）→ 转 GMV

VPERM_GMV：插入 MTVR µOP（将下一段的标量索引搬入 v_tmp）
  完成后回 VPR
```

`vpr_counter`（4 位）记录当前处理的目的/源 vreg 组偏移，终止条件：
```verilog
vpr_cnt_over = (vperm_cur_state == VPERM_VPR) &&
  ((vpr_counter == 4'b0000 && lmul==2'b00)  // LMUL=1：第 0 组即结束
 ||(vpr_counter == 4'b0010 && lmul==2'b01)  // LMUL=2：第 2 组结束
 ||(vpr_counter == 4'b0110 && lmul==2'b10)  // LMUL=4：第 6 组结束
 ||(vpr_counter == 4'b1111 && lmul==2'b11)); // LMUL=8：第 15 组结束
```

每周期 4 个 µOP 对应目的 vreg 的 4 个不同"count"组合（`vperm_srcv0_inst{0~3}_count`），使得每拍可以并行处理 4 路 gather 子操作。

每个 µOP 的寄存器编号（行 2019~2125）：
```verilog
// 目的 vreg 根据 vpr_counter[3:1] 选组
vperm_instN_data[IR_DSTV_REG] = {1'b0, vec_inst[11:7] | {2'b0, vpr_counter[3:1]}};
// 源 vreg（vs2 索引表段）根据 vperm_srcv0_inst{N}_count 偏移
vperm_instN_data[IR_SRCV0_REG] = {1'b0, vec_inst[24:20] | {2'b0, vperm_srcv0_instN_count}};
// VMLA=1 表示本 µOP 的 vd 是读-改-写（RMW），用于 vslideup 的元素合并
vperm_instN_data[IR_VMLA] = 1'b1;
```

---

## 8. 向量浮点规约拆分（`dp_split_long_type[3]`）

### 8.1 为什么浮点规约最复杂

整数规约（vredsum/vreand 等）在 C910 中是特殊情形的 norm 指令，可由 vec_norm 路径处理。但**浮点规约**由于浮点加法不满足交换律和结合律（NaN/INF/round mode），必须严格按顺序执行，并且宽化规约（vfwredosum.vs 等）还需要在不同 SEW 的向量寄存器之间传递中间结果。

C910 将浮点规约进一步细分为 6 种子类型（行 3991~4051）：

| 子类型 | 条件 | 说明 |
|--------|------|------|
| `fored`（有序规约） | funct6=000011 或 特定 funct6 且 SEW=64 | 严格有序浮点归并 |
| `fored_w`（宽化有序） | funct6=110011 或 funct6=110001 且 SEW=32 | 宽化有序规约 |
| `funored`（无序规约） | funct6 符合且 SEW≠64 | 允许部分重排的规约 |
| `funored_w`（宽化无序） | funct6=110001 且 SEW≠32 | 宽化无序规约 |
| `fnorm_wv`（浮点宽化加 .vv） | funct6=1101, opfvv | 宽化浮点算术规约前处理 |
| `fnorm_wf`（浮点宽化加 .vf） | funct6=1101, opfvf | 同上，标量浮点版 |

每种子类型有独立的状态机（`VEC_FORED_IDLE/BUSY`，`VEC_FUNORED_IDLE/BUSY` 等）和计数器（`vec_fored_cnt`、`vec_funored_cnt` 等）。

### 8.2 计数器与拆分数量

以 `fored`（有序规约，最严格）为例：
```
fored_total_cnt_num = (lmul==0) ? 1 : (lmul==1) ? 2 : (lmul==2) ? 4 : ...
```
每拍发 1~4 个 µOP，每个 µOP 做一次二元浮点加，累加器暂存在临时向量寄存器（`vec_fored_destv_vreg`）中。计数器驱动源操作数的 vreg 偏移（`vec_fored_split_inst{N}_src0/1`），最终结果写入实际 vd。

**宽化规约（fored_w/funored_w）**需要动态切换 SEW 和 LMUL：每轮将更宽的中间结果与更窄的源元素相加，因此不同 µOP 的 `IR_VSEW` 和 `IR_VLMUL` 可能不同，由 `widden_split_inst{N}_vsew/vlmul` 覆盖（行 7494~7495）：
```verilog
split_long_dp_inst0_data[IR_VSEW:IR_VSEW-2] =
    widden_split_inst_vld ? widden_split_inst0_vsew[2:0] : dp_split_long_vsew[2:0];
```

---

## 9. 向量 stride 访存拆分（`dp_split_long_type[4]`）

### 9.1 拆分单位

stride 访存（`vlse32.v vd, (rs1), rs2`）每次访问一个元素，步长为 rs2 字节。C910 每拍可以发出多个 µOP，每个 µOP 对应一次元素访问 + 地址更新。

基础思路是将地址生成（ALU add rs2 累加）和访存（LSU）配对：
```
µOP 0（LSU 或 LSU_P5）：load/store element[cnt], addr = base_reg
µOP 1（ALU）：base_reg += rs2（更新地址，写 tmp 整数寄存器 6'b100000）
µOP 2（LSU 或 LSU_P5）：load/store element[cnt+1], addr = base_reg（来自 µOP1）
µOP 3（ALU）：base_reg += rs2（下一轮用）
```

连续的 LSU+ALU 对可以流水线，dep_info 指示 LSU 的 src0 依赖前一个 ALU 的 dst。

### 9.2 计数器与 vreg 偏移

```verilog
// vec_stride_cnt：元素计数（6 位）
// vec_stride_vreg_offset：当前写入的 vreg 偏移（3 位）

// vreg 边界判断（根据 SEW 决定多少个元素在同一 vreg 内）
vec_stride_vreg_begin = (sew==8b)  && (cnt[2:0]==3'b000)  // 8  元素/vreg
                      || (sew==16b) && (cnt[1:0]==2'b00)  // 4  元素/vreg
                      || (sew==32b) && (cnt[0]  ==1'b0)   // 2  元素/vreg
                      || (sew==64b);                      // 1  元素/vreg

vec_stride_vreg_end = (sew==8b)  && (cnt[2:0]==3'b111)
                    || ...
```

只有在 `vreg_begin` 时才设置 `IR_DSTV_VLD=1`（写入目的向量寄存器），否则只更新元素但不整体覆盖寄存器。

### 9.3 dstv0 重叠特殊情形

当目的寄存器 vd=v0 且非 mask（`vec_stride_dstv0_ovlp`）时，访存结果会覆盖 mask 寄存器，需要特殊处理：先把 v0 保存到 v_tmp，然后用 v_tmp 作为新 mask 屏蔽自身（行 5687~5700）。

---

## 10. 向量 index 访存拆分（`dp_split_long_type[5]`）

`vloxei32.v vd, (rs1), vs2` 按 vs2 中存储的索引寻址，每个元素有不同地址，无法做批量地址预测。C910 采用 index 计数器（`vec_index_cnt`，7 位）和 vreg 偏移（`vec_index_vreg_offset`，3 位）配合，每周期发 4 路 index 访存 µOP，每路消耗 vs2（索引向量）的一个 segment：

```
µOP 0（LSU）：ext(vs2[idx_offset+0]) + rs1 → load/store
µOP 1（ALU/LSU）：视情况
µOP 2（LSU）：ext(vs2[idx_offset+1]) + rs1
µOP 3（ALU/LSU）：...
```

`vec_index_vreg_offset` 在每次 vreg 边界（`vec_index_vreg_end`）递增，指示当前访问 vs2（index 向量）的哪个物理寄存器。终止条件 `vec_index_split_last` 类似 stride 模式。

---

## 11. 向量 AMO 拆分（`dp_split_long_type[6]`）

向量 AMO（`vamoswap.w.v` 等）：对向量寄存器中每个元素地址各执行一次标量 AMO，按序执行。拆分策略：

```
µOP 0（LSU）：vector lr on element[0]（加载）
µOP 1（ALU）：vector alu for element[0]
µOP 2（LSU_P5）：vector sc on element[0]（存储结果）
...（下一周期处理 element[1]）
```

`vec_amo_cnt`（7 位）记录当前元素编号，`vec_amo_vreg_offset` 记录当前 index vreg 组。每拍输出最多 3 个 µOP（load+alu+store），通过 `vec_amo_inst_vld[3:0]` 控制。

---

## 12. 向量 segment 访存拆分（`dp_split_long_type[7/8/9]`）

Zvlsseg（段访存）指令如 `vlseg3e32.v vd, (rs1)` 每次访问 nf 个连续字段（segment），写入 nf 个连续向量寄存器。相应地，需要额外维护 segment 计数（`zvlsseg_unit_nf_cnt`，`zvlsseg_stride_nf_cnt`，`zvlsseg_index_nf_cnt`）：

- **unit stride（type[7]）**：每个 segment 的地址连续，可以相对高效地批量发出 LSU µOP，配合 nf_offset_cnt 生成跨寄存器偏移
- **stride（type[8]）**：每个 element 的所有 segment 字段连续，address += stride × nf
- **index（type[9]）**：index 向量指向每个 element 基址，nf 个字段在基址连续偏移

三种 segment 拆分各有独立状态机和计数器，但共享相同的 vreg_offset 计算逻辑。

---

## 13. stall 机制与流水线协同

### 13.1 stall 信号传递路径

```
split_long_ctrl_id_stall
    ↑
    由各子拆分 stall 信号 OR 后生成：
    amo_split_stall || vec_norm_split_stall || vec_perm_split_stall
    || vec_fred_split_stall || vec_stride_split_stall || ...
    ↓
    回送给 ct_idu_id_ctrl → 冻结 ID 级输入（IF 停发新指令）
```

```
              IF ──→ ID ──→ IS ──→ EX
                     │
              split_long_ctrl_id_stall ──→ id_ctrl ──→ 冻结 IF/ID
```

stall 信号在以下情况为高：
- 当前周期是拆分的**第一周期**且尚未发出所有 µOP（还需要下一周期）
- 上游背压（来自 IS 或更下游的 `ctrl_split_long_id_stall`）使当前拆分无法继续

### 13.2 flush 处理

当 IU（Instruction Unit）产生 `rtu_idu_flush_fe` 或 `iu_yy_xx_cancel`（分支预测失败/异常恢复）时，所有状态机强制复位到 IDLE：

```verilog
always @(posedge split_clk or negedge cpurst_b) begin
  if (!cpurst_b)          amo_cur_state <= AMO_IDLE;
  else if (rtu_idu_flush_fe || iu_yy_xx_cancel)
                          amo_cur_state <= AMO_IDLE; // flush → 强制清状态
  else                    amo_cur_state <= amo_next_state;
end
```

所有 11 个状态机（amo + vec_norm + vperm + vslide + vrgather + vec_fored + vec_funored + ... + zvlsseg × 3）均有相同的 flush 逻辑，确保出错后 ID 流水线能干净重启。

### 13.3 门控时钟节能

每个子拆分模块使用独立的 `gated_clk_cell`（行 1096~1104 等），只有当该子模块活跃时才打开时钟：

```verilog
assign split_clk_en = ctrl_split_long_id_inst_vld && dp_split_long_type[0]  // AMO 指令到来
                    || (amo_cur_state != AMO_IDLE);                          // AMO 状态机运行中
```

这极大减少了非向量/非 AMO 程序下的动态功耗。

---

## 14. 最终 µOP 打包与输出

### 14.1 长拆分 MUX 选择（行 7384~7466）

```verilog
// 10 路子类型 OR-MUX 选择有效 µOP 数据
assign split_long_ctrl_inst_vld[3:0] =
    {4{dp_split_long_type[0]}} & amo_inst_vld    |
    {4{dp_split_long_type[1]}} & vec_norm_inst_vld |
    {4{dp_split_long_type[2]}} & vec_perm_inst_vld |
    ...;

assign split_long_inst0_data = {178{type[0]}} & amo_inst0_data
                              | {178{type[1]}} & vec_norm_inst0_data
                              | ...;
```

每拍最多 4 个 µOP 有效，有效位由各子类型的 `_inst_vld` 控制，由 id_dp 进一步路由到 issue 队列。

### 14.2 IR 后处理字段填充（行 7470~7594）

拆分模块内部生成的 IR 不含 PC、VL、VLMUL/VSEW 等"公共"字段，由最终的 always 块填入：

```verilog
always @(...) begin
  split_long_dp_inst0_data = split_long_inst0_data; // 基础 IR
  // 覆盖/补充字段
  split_long_dp_inst0_data[IR_SPLIT_LAST] = !split_long_inst0_data[IR_SPLIT];
  split_long_dp_inst0_data[IR_DST_X0]     = (dst_reg == 6'd0);  // rd=x0 标记
  split_long_dp_inst0_data[IR_BKPTA_INST] = dp_split_long_bkpta_inst;
  split_long_dp_inst0_data[IR_NO_SPEC]    = dp_split_long_no_spec;
  // 宽化指令覆盖 VLMUL/VSEW（每 µOP 可能不同）
  split_long_dp_inst0_data[IR_VLMUL:IR_VLMUL-1] =
      widden_split_inst_vld ? widden_split_inst0_vlmul : dp_split_long_vlmul;
  split_long_dp_inst0_data[IR_VSEW:IR_VSEW-2]   =
      widden_split_inst_vld ? widden_split_inst0_vsew :
      vperm_split_mtvr_vld  ? 3'b011 :   // MTVR µOP 使用 SEW=64
      dp_split_long_vsew;
  split_long_dp_inst0_data[IR_VL:IR_VL-7]       = dp_split_long_vl;
  split_long_dp_inst0_data[IR_PC:IR_PC-14]       = dp_split_long_pc;
end
```

注意 `vperm_split_mtvr_vld` 时强制 SEW=64（3'b011）：这是因为 MTVR 指令（vmv.v.x / vmv.s.x）不依赖实际元素宽度，统一按 64 位处理以覆盖最宽情形。

宽化规约类（fored_w/funored_w/fnorm_wv/fnorm_wf）各 µOP 的 VLMUL/VSEW 由 `widden_split_inst{N}_vlmul/vsew` 提供，它是将各宽化子模块的 lmul/sew 输出做 MUX（行 4014~4051）。

---

## 15. 寄存器编号生成总结

| 寄存器类型 | 普通指令 | 宽化（wide） | 缩减（narr） | 规约 | 置换 |
|-----------|---------|-------------|-------------|------|------|
| srcv0（vs2） | base \| offset[N] | base \| offset_half[N] | base \| offset[N] | base \| cnt_offset | base \| vpr_cnt |
| srcv1（vs1） | base \| offset[N] | base \| offset_half[N]（宽化时更窄） | base（不偏移）| acc_tmp | gpr_tmp 或 base |
| dstv（vd） | base \| offset[N] | base \| offset[N]（目的更宽） | base \| offset_half[N] | acc_tmp → 最后写 vd | base \| vpr_cnt[3:1] |

其中 `offset[N]` = `{N_bit_field_of_offset_for_µOP_N}`，由 3 位组为单位从 12 位宽的 `_offset[11:0]` 中提取。

临时寄存器编号约定（MSB=1 表示"临时"）：
- `6'b100000`：整数/向量通用临时寄存器（v_tmp / x_tmp）
- `6'b100001`：规约操作的累加器（v_acc）
- `6'd32`（= `6'b100000`）：浮点临时寄存器（f_tmp）

---

## 16. 系统集成关系

```
ct_idu_id_dp
  ├── x_ct_idu_id_split_short0  (inst0 通道：2 µOP 输出)
  ├── x_ct_idu_id_split_short1  (inst1 通道：2 µOP 输出)
  ├── x_ct_idu_id_split_short2  (inst2 通道：2 µOP 输出)
  └── x_ct_idu_id_split_long    (全局唯一：4 µOP/周期输出，带 stall)
           ↑                             ↑
  dp_split_long_type[9:0]      split_long_ctrl_id_stall
  dp_split_long_inst[31:0]     split_long_ctrl_inst_vld[3:0]
  dp_split_long_vl/vlmul/vsew  split_long_dp_inst{0~3}_data
           ↓
  ct_idu_id_ctrl
    ├── 接收 split_long_ctrl_id_stall → 冻结 IF/ID
    ├── 接收 split_long_ctrl_inst_vld → 决定本周期 ROB/IQ 分配槽数
    └── 向 split_long 发 ctrl_split_long_id_stall（来自 IS 反压）
```

下游 IS（Issue Stage）在 ROB/IQ 满时向 `ctrl_split_long_id_stall` 反压，此信号传入 `split_long` 后所有状态机停止迁移（保持当前状态），下一周期重发相同的 µOP，直到 IS 就绪。

`split_short` 无状态机，不参与 stall 链路，其 2 µOP 总是在同一周期与对应 decode 槽输出，由 `id_ctrl` 决定是否本周期 issue。

---

## 17. 关键信号一览

| 信号 | 方向 | 宽度 | 含义 |
|------|------|------|------|
| `dp_split_long_type[9:0]` | 输入 | 10 | 10 类长拆分类型独热码 |
| `split_long_ctrl_id_stall` | 输出 | 1 | 当前指令未拆完，要求 ID stall |
| `split_long_ctrl_inst_vld[3:0]` | 输出 | 4 | 本周期 inst0/1/2/3 是否有效 |
| `split_long_dp_inst{N}_data[177:0]` | 输出 | 4×178 | µOP 0~3 完整 IR |
| `split_long_dp_dep_info[16:0]` | 输出 | 17 | 内部 µOP 依赖掩码 |
| `IR_SPLIT` | IR 字段 | 1 | 1=还有后续 µOP |
| `IR_SPLIT_LAST` | IR 字段 | 1 | 1=这是最后一拍（SPLIT 的反码）|
| `IR_INTMASK` | IR 字段 | 1 | 1=屏蔽中断（中间 µOP）|
| `IR_SPLIT_NUM[6:0]` | IR 字段 | 7 | 拆分序号（向量 µOP 识别用）|
| `IR_IID_PLUS[3:0]` | IR 字段 | 4 | 后续 µOP 的 IID 相对偏移 |
| `IR_VMLA` | IR 字段 | 1 | 向量 vd 同时作为源操作数（RMW）|
| `IR_VMB` | IR 字段 | 1 | 向量 load 需要 mask-before 写屏蔽 |
