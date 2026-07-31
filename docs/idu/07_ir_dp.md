# C910 IDU —— IR 阶段数据通路（ir_dp）深度解析

> **阅读前置**：建议先阅读 `00_idu_overview.md` 了解 IDU 四级流水的整体框架。
> 本文聚焦 IR（重命名）阶段的数据通路，对应文件：
> - `ct_idu_ir_dp.v`（2445 行，IR 阶段数据通路主体）
> - `ct_idu_ir_decd.v`（663 行，IR 阶段专属译码器）

---

## 目录

1. [模块概述：IR 数据通路的职责与定位](#1-模块概述)
2. [端口总览与信号分类](#2-端口总览)
3. [流水线寄存器：ID→IR 的打拍机制](#3-流水线寄存器)
4. [IR 数据字段定义（IR_WIDTH=178 位）](#4-ir-数据字段定义)
5. [ct_idu_ir_decd：IR 阶段为何还要译码](#5-ir-阶段译码器)
6. [源寄存器号提取与送查重命名表](#6-源寄存器号提取与送查)
7. [物理寄存器号接收：RTU 分配结果](#7-物理寄存器号接收)
8. [FRT/VRT 多路选择器](#8-frtvrt-多路选择器)
9. [同周期依赖旁路：IR 内多指令间的 in-flight 匹配](#9-同周期依赖旁路)
10. [IS 数据字段定义（IS_WIDTH=271 位）](#10-is-数据字段定义)
11. [重命名后指令组装：送 IS 阶段的完整数据包](#11-重命名后指令组装)
12. [控制信息提取：发射队列分流依据](#12-控制信息提取)
13. [lch_preg 预计算：射频读优化](#13-lch_preg-预计算)
14. [整体数据流总结](#14-整体数据流总结)

---

## 1. 模块概述

### 1.1 IR 阶段在流水线中的位置

```
  ID 阶段             IR 阶段                IS 阶段           RF 阶段
  (译码/拆分)     (寄存器重命名)           (乱序发射)         (读寄存器)
      │                  │                     │                  │
      ▼                  ▼                     ▼                  ▼
 ┌─────────┐     ┌──────────────┐      ┌────────────┐     ┌──────────┐
 │ id_dp   │────▶│   ir_dp      │─────▶│  is_dp     │────▶│  rf_dp   │
 │ 译码结果 │     │  重命名数据   │      │  发射队列  │     │ 操作数读 │
 └─────────┘     └──────┬───────┘      └────────────┘     └──────────┘
                        │
               ┌────────┼────────┐
               ▼        ▼        ▼
            ir_rt     ir_frt   ir_vrt
          (整数重命名) (浮点重命名)(向量重命名)
```

IR 阶段是 IDU 流水线的第二级，位于 ID（译码）之后、IS（发射）之前。其核心任务是**寄存器重命名**：把逻辑寄存器号（架构寄存器）映射为物理寄存器号，消除 WAR（写后读）和 WAW（写后写）假依赖，为后续乱序执行创造条件。

### 1.2 ct_idu_ir_dp 的三大职责

| 职责 | 输入来源 | 处理结果 |
|------|---------|---------|
| **组织重命名查询** | ID 阶段传来的指令包（架构寄存器号） | 送往 ir_rt / ir_frt / ir_vrt 的查询请求 |
| **接收重命名结果** | ir_rt / frt / vrt 返回的物理寄存器号 | 组装含物理寄存器号的完整指令包 |
| **处理同周期依赖** | 本批次 4 条指令之间的 WAW/RAW 关系 | 旁路修正：后指令直接拿前指令的新物理号 |

### 1.3 规模与参数

- **内部最多承载 4 个 IR 槽**（inst0 ~ inst3，程序序上 inst0 最老、inst3 最年轻）；这
  是拆分微操作后的内部宽度，不等同于每周期必有 4 条架构指令进入
- **IR 数据包宽度**：178 位（`IR_WIDTH = 178`），来自 ID 阶段
- **IS 数据包宽度**：271 位（`IS_WIDTH = 271`），输出到 IS 阶段（更宽，因为加入了物理寄存器号和旁路状态）
- **三类重命名表**：整数（ir_rt，7 位物理寄存器），浮点（frt，6 位物理浮点寄存器+5 位扩展寄存器），向量（vrt，6 位物理向量寄存器）

---

## 2. 端口总览

### 2.1 全局控制信号

| 信号 | 方向 | 说明 |
|------|------|------|
| `forever_cpuclk` | in | 主时钟 |
| `cpurst_b` | in | 复位（低有效） |
| `cp0_yy_clk_en` | in | 全局时钟使能 |
| `cp0_idu_icg_en` | in | IDU 时钟门控使能 |
| `pad_yy_icg_scan_en` | in | 扫描链时钟使能 |
| `ctrl_ir_stall` | in | IR 阶段停顿信号（来自 ctrl 模块） |
| `ctrl_id_pipedown_gateclk` | in | ID→IR 流水传输时钟门控使能 |
| `ctrl_dp_ir_inst0_vld` | in | inst0 在 IR 阶段有效（影响时钟门控） |

### 2.2 来自 ID 阶段的输入

```
dp_id_pipedown_inst{0~3}_data[177:0]  — 4 条指令的 178 位数据包
dp_id_pipedown_dep_info[16:0]         — 17 位依赖信息（编码了 inst0-3 之间的同周期 RAW 依赖）
```

### 2.3 与整数重命名表（ir_rt）的接口

**送出（查询源寄存器 + 目的寄存器）：**
```
dp_rt_inst{0~3}_src{0,1}_reg[5:0]    — 架构源寄存器号（送 rt 查找物理号）
dp_rt_inst{0~3}_src{0,1,2}_vld       — 源寄存器有效标志
dp_rt_inst{0~3}_dst_{reg,vld,preg}   — 目的寄存器的架构号和新分配的物理号
dp_rt_inst{0~3}_{mla,mov}            — 乘加/移动标志（影响重命名表特殊处理）
dp_rt_dep_info[16:0]                  — 依赖信息透传给 rt
```

**接收（物理寄存器号）：**
```
rt_dp_inst{0~3}_src{0,1,2}_data[8:0 or 9:0]  — 查表结果：物理号+旁路就绪位
rt_dp_inst{0~3}_rel_preg[6:0]                 — 旧物理号（用于后续释放）
rt_dp_inst0{1,2,3}_src_match[2:0]             — 同周期依赖匹配向量（由 rt 计算）
```

### 2.4 与浮点重命名表（frt）的接口

浮点指令有额外复杂性：浮点目的寄存器 `f0~f31` 是独立的重命名域；可能修改
`fflags` 等粘滞状态的操作还会分配物理 EREG。`fclass/fmv.x.*` 若产生整数结果，
其结果走整数 PREG，而不是 EREG。EREG 保存的是推测执行产生、必须经过退休
边界过滤的状态贡献。

```
— 送出 —
dp_frt_inst{0~3}_srcf{0,1,2}_{reg,vld}  — 浮点源寄存器查询
dp_frt_inst{0~3}_dstf_{reg,vld}          — 浮点目的寄存器
dp_frt_inst{0~3}_dst_{freg,ereg}         — 新分配的物理浮点/扩展寄存器号
dp_frt_inst{0~3}_{fmla,fmov}             — 浮点乘加/浮点移动标志

— 接收 —
frt_dp_inst{0~3}_srcf{0,1,2}_data        — 浮点物理号+旁路就绪位
frt_dp_inst{0~3}_rel_{freg,ereg}         — 旧物理浮点/扩展寄存器号（待释放）
frt_dp_inst{0,1,2}{2,3}_srcf2_match      — 同周期 srcf2 依赖匹配
```

### 2.5 与向量重命名表（vrt）的接口

```
— 送出 —
dp_vrt_inst{0~3}_srcv{0,1,2}_{reg,vld}  — 向量源寄存器查询
dp_vrt_inst{0~3}_dstv_{reg,vld}          — 向量目的寄存器
dp_vrt_inst{0~3}_dst_vreg[5:0]           — 新分配的物理向量寄存器号
dp_vrt_inst{0~3}_srcvm_vld               — 掩码向量源有效（v0 寄存器）
dp_vrt_inst{0~3}_vmla                    — 向量乘加标志

— 接收 —
vrt_dp_inst{0~3}_srcv{0,1,2}_data        — 向量物理号+旁路就绪位
vrt_dp_inst{0~3}_srcvm_data              — 掩码寄存器物理号
vrt_dp_inst{0~3}_rel_vreg[6:0]          — 旧物理向量寄存器号（待释放）
vrt_dp_inst{0,1,2}{2,3}_srcv2_match      — 同周期 srcv2 依赖匹配
```

### 2.6 来自 RTU 的物理寄存器分配

```
rtu_idu_alloc_preg{0~3}[6:0]  — RTU 预先分配的新物理整数寄存器号（7 位，最多 96 个物理寄存器）
rtu_idu_alloc_freg{0~3}[5:0]  — 新物理浮点寄存器号（6 位，最多 64 个）
rtu_idu_alloc_vreg{0~3}[5:0]  — 新物理向量寄存器号（6 位）
rtu_idu_alloc_ereg{0~3}[4:0]  — 新扩展寄存器号（5 位）
```

从 `ir_dp` 的模块边界看，这些物理号已经作为 RTU 输入到达，IR 数据路径直接选择并打包，而不在本模块内
运行空闲表分配算法。这说明“分配决策”和“IR 数据组装”位于不同模块；它对哪条关键路径节省了多少延迟，
以及 RTU 是否在更早周期计算，必须结合顶层时序和 STA 判断，不能只由输入端口位置断言。

### 2.7 输出到 IS 阶段

```
dp_ir_inst{0~3}_data[270:0]   — 4 条指令的 271 位 IS 数据包（含物理寄存器号）
dp_ir_inst{01,02,03,12,13,23}_src_match[3:0]  — 6 对指令间的依赖匹配向量（送 IS 控制）
```

### 2.8 输出到 IR 控制逻辑

```
dp_ctrl_ir_inst{0~3}_dst_vld    — 目的寄存器有效（ctrl 据此判断是否需要重命名分配）
dp_ctrl_ir_inst{0~3}_dst_x0    — 目的为 x0（写哑）
dp_ctrl_ir_inst{0~3}_dstv_vld  — 向量目的有效
dp_ctrl_ir_inst{0~3}_dste_vld  — 扩展目的有效
dp_ctrl_ir_inst{0~3}_dstf_vld  — 浮点目的有效
dp_ctrl_ir_inst{0~3}_ctrl_info[12:0]  — 13 位发射控制信息（告知 ctrl 指令走哪个发射队列）
dp_ctrl_ir_inst{0~3}_hpcp_type[6:0]  — 7 位高性能计数器分类（供 HPCP 统计）
dp_ctrl_ir_inst{0~3}_bar       — barrier 指令标志
```

---

## 3. 流水线寄存器

### 3.1 寄存器声明与时钟门控

```verilog
// 第 574~578 行：IR 阶段寄存器
reg [16:0]  ir_dep_info;           // 17 位依赖信息
reg [177:0] ir_inst0_data;         // 4 条指令的 178 位数据包
reg [177:0] ir_inst1_data;
reg [177:0] ir_inst2_data;
reg [177:0] ir_inst3_data;
```

```verilog
// 第 1297~1298 行：门控时钟使能条件
assign ir_inst_clk_en = ctrl_id_pipedown_gateclk   // ID→IR 有新指令传入
                        || ctrl_dp_ir_inst0_vld;    // IR 中已有有效指令
```

这组状态的有效数据位宽合计为 `4×178 + 17 = 729` 位。`ir_inst_clk_en` 在 ID 提出 pipedown gateclk
请求或 IR 的 inst0 仍有效时提出局部时钟请求，使空闲状态有机会减少寄存器时钟活动。它并不是“stall
时必然关钟”：若 IR 中仍有有效 inst0，请求仍为 1；公共 `gated_clk_cell` 还采用
`global_en && (module_en || local_en)` 并受扫描使能影响，且未定义
`C910_USE_TSMC28_ICG` 时当前 RTL 模型直接透传时钟。实际动态功耗收益需由实现后活动率和功耗报告确认。

### 3.2 寄存器触发逻辑

```verilog
// 第 1320~1343 行
always @(posedge ir_inst_clk or negedge cpurst_b)
begin
  if (!cpurst_b) begin
    ir_inst0_data <= {IR_WIDTH{1'b0}};   // 复位清零
    // ... inst1/2/3/dep_info 同理
  end
  else if (!ctrl_ir_stall) begin         // 未停顿：接受 ID 阶段新数据
    ir_inst0_data <= dp_id_pipedown_inst0_data;
    ir_inst1_data <= dp_id_pipedown_inst1_data;
    ir_inst2_data <= dp_id_pipedown_inst2_data;
    ir_inst3_data <= dp_id_pipedown_inst3_data;
    ir_dep_info   <= dp_id_pipedown_dep_info;
  end
  else begin                             // 停顿：保持当前值（等待重命名表就绪）
    ir_inst0_data <= ir_inst0_data;
    // ...
  end
end
```

**三种状态的语义：**
- **复位**：清空所有 IR 寄存器，防止未初始化数据流入重命名表。
- **正常（!stall）**：接受 ID 阶段传下来的 4 条指令数据包和依赖信息，进入 IR 阶段等待重命名。
- **停顿（stall）**：寄存器自保持，等待停顿原因消除（如 ROB 满、重命名表满、发射队列满）。

停顿时 IR 寄存器维持原值，重命名表查询也维持原值，使得同一批指令可以在下一个周期继续完成重命名，无需重新从 ID 阶段重新拉取。

---

## 4. IR 数据字段定义

ID 阶段组装、IR 阶段接收的 178 位数据包，字段含义如下（从高位到低位）：

```
位[177]      IR_VL_PRED    — 向量长度预测标志
位[176:169]  IR_VL[7:0]    — 向量长度（vl 寄存器值，8 位）
位[168]      IR_VMB        — 向量内存屏障（也用于区分 vamo 的 load/store 半部分）
位[167:153]  IR_PC[14:0]   — 指令 PC 低 15 位（用于 LSU 地址计算上下文）
位[152:150]  IR_VSEW[2:0]  — 向量 SEW（元素宽度：000=8b, 001=16b, 010=32b, 011=64b）
位[149:148]  IR_VLMUL[1:0] — 向量 LMUL（寄存器组长）
位[147]      IR_FMLA       — 浮点乘加标志（fmadd/fmsub/fnmadd/fnmsub）
位[146:140]  IR_SPLIT_NUM  — 拆分指令的当前片段编号（7 位，用于向量拆分）
位[139]      IR_NO_SPEC    — 禁止推测执行（如 lr.w 需要顺序）
位[138]      IR_MLA        — 整数乘加标志（madd 类）
位[137]      IR_DST_X0     — 目的寄存器为 x0（写操作无效）
位[136]      IR_ILLEGAL    — 非法指令标志（保留原 opcode，IR 译码时需屏蔽）
位[135]      IR_SPLIT_LAST — 拆分的最后一片段
位[134]      IR_VMLA       — 向量乘加标志
位[133:130]  IR_IID_PLUS   — IID 偏移量（拆分指令各片段的 IID 增量）
位[129]      IR_BKPTB_INST — 断点 B 类型
位[128]      IR_BKPTA_INST — 断点 A 类型
位[127]      IR_FMOV       — 浮点移动（fmv.*）
位[126]      IR_MOV        — 整数移动（mv/addi x,x,0 等）
位[125:119]  IR_EXPT[6:0]  — 异常编码（7 位）
位[118]      IR_LENGTH     — 指令长度（0=16 位压缩指令，1=32 位标准指令）
位[117]      IR_INTMASK    — 需要关中断（CSR 写等特殊指令）
位[116]      IR_SPLIT      — 正在拆分（还有后续片段）
位[115:106]  IR_INST_TYPE  — 指令类型（10 位独热码，见下表）
位[105:100]  IR_DSTV_REG   — 向量目的架构寄存器号（6 位，v0~v31）
位[99]       IR_DSTV_VLD   — 向量目的寄存器有效
位[98]       IR_SRCVM_VLD  — 向量掩码源有效（v0）
位[97]       IR_SRCV2_VLD  — 向量源 2（通常是累加器）有效
位[96:91]    IR_SRCV1_REG  — 向量源 1 架构寄存器号
位[90]       IR_SRCV1_VLD  — 向量源 1 有效
位[89:84]    IR_SRCV0_REG  — 向量源 0 架构寄存器号
位[83]       IR_SRCV0_VLD  — 向量源 0 有效
位[82]       IR_DSTE_VLD   — 浮点扩展目的有效（如 fclass 写整数堆）
位[81:76]    IR_DSTF_REG   — 浮点目的架构寄存器号
位[75]       IR_DSTF_VLD   — 浮点目的有效
位[74:69]    IR_SRCF2_REG  — 浮点源 2 架构寄存器号（fmadd 的第 3 操作数）
位[68]       IR_SRCF2_VLD  — 浮点源 2 有效
位[67:62]    IR_SRCF1_REG  — 浮点源 1 架构寄存器号
位[61]       IR_SRCF1_VLD  — 浮点源 1 有效
位[60:55]    IR_SRCF0_REG  — 浮点源 0 架构寄存器号
位[54]       IR_SRCF0_VLD  — 浮点源 0 有效
位[53:48]    IR_DST_REG    — 整数目的架构寄存器号（6 位，但实际 5 位 x0~x31）
位[47]       IR_DST_VLD    — 整数目的有效
位[46]       IR_SRC2_VLD   — 整数源 2 有效（如 fmadd 的累加器，写回整数堆）
位[45:40]    IR_SRC1_REG   — 整数源 1 架构寄存器号
位[39]       IR_SRC1_VLD   — 整数源 1 有效
位[38:33]    IR_SRC0_REG   — 整数源 0 架构寄存器号
位[32]       IR_SRC0_VLD   — 整数源 0 有效
位[31:0]     IR_OPCODE     — 原始 32 位指令编码（IR 译码器还要用）
```

**IR_INST_TYPE 10 位独热编码（位[115:106]）：**

| 位偏移（从 IR_INST_TYPE 计） | 含义 | IS_CTRL 对应 |
|------------------------------|------|-------------|
| `[115]` = `IR_INST_TYPE` | SPECIAL（特殊指令：CSR/ecall/fence 等） | IS_CTRL_SPECIAL |
| `[114]` = `IR_INST_TYPE-1` | PIPE7（向量 pipe7 专属） | IS_CTRL_PIPE7 |
| `[113]` = `IR_INST_TYPE-2` | PIPE6（向量 pipe6 专属） | IS_CTRL_PIPE6 |
| `[112]` = `IR_INST_TYPE-3` | PIPE67（向量 pipe6/7 共用） | IS_CTRL_PIPE67 |
| `[111]` = `IR_INST_TYPE-4` | STADDR（存地址，属 LSU 特殊类型） | IS_CTRL_STADDR |
| `[110]` = `IR_INST_TYPE-5` | LSU（Load/Store 单元） | IS_CTRL_LSU |
| `[109]` = `IR_INST_TYPE-6` | DIV（除法） | IS_CTRL_DIV |
| `[108]` = `IR_INST_TYPE-7` | MULT（乘法） | IS_CTRL_MULT |
| `[107]` = `IR_INST_TYPE-8` | BJU（分支跳转） | IS_CTRL_BJU |
| `[106]` = `IR_INST_TYPE-9` | ALU（普通算术逻辑） | IS_CTRL_ALU |

---

## 5. IR 阶段译码器

### 5.1 为什么 IR 阶段还要再译码

ID 阶段已经做过一次完整译码，为什么 IR 阶段还需要专用的 `ct_idu_ir_decd`？有三个原因：

1. **IR 阶段新增的信息需要当拍得到**：ID 阶段传入的 178 位数据包已有 `IR_INST_TYPE`，但像 `alu_short`（短 ALU，决定前递延迟）、`bar_type`（屏障类型，决定 LSU 发射约束）、向量 `vmla_type` 等更细粒度的信息，在 ID 阶段压缩进 opcode 而未显式编码，需要在 IR 阶段再次从 opcode 提取。

2. **非法指令保留了原 opcode**（见 RTL 注释 `CAUTION!!!`）：`ct_idu_ir_decd.v` 第 183 行注释明确指出——非法指令从 ID 阶段流水下来时保留了原始 opcode，IR 阶段的所有输出都必须在 `!x_illegal` 的前提下才有效，即加掩码屏蔽：
   ```verilog
   assign x_load  = !x_illegal && decd_load;   // 行 187
   assign x_store = !x_illegal && decd_store;  // 行 188
   ```
   这样保证非法指令不会被误判为 load/store/bar 等，导致发射队列分流错误。

3. **上下文相关解码**：`decd_load/store` 对于 AMO 指令（如 amoadd.w）需要结合 `x_type_vload`（是向量 AMO 的 load 半部分还是 store 半部分）来判断，这个信息在 ID 阶段已经计算好并存入 `IR_VMB` 位（即 `ir_inst_data[IR_VMB]`），IR 阶段直接取用。

### 5.2 译码器输入

```verilog
input  [31:0]  x_opcode;        // 原始指令编码（来自 IR_OPCODE 字段）
input          x_illegal;       // 非法指令标志
input          x_type_alu;      // 是否为 ALU 类型（来自 IR_INST_TYPE-9）
input          x_type_staddr;   // 是否为 store address 类型
input  [2:0]   x_vsew;          // 向量 SEW（元素宽度，用于浮点乘加类型判断）
input          x_type_vload;    // 向量 AMO 的 load 半部分（来自 IR_VMB）
```

### 5.3 译码器输出分类

**LSU 相关：**

| 信号 | 含义 | 用途 |
|------|------|------|
| `x_load` | load 类指令 | IS 阶段：发 LSIQ，加载类资源申请 |
| `x_store` | store 类指令 | IS 阶段：发 SDIQ（地址）+ LSIQ（数据） |
| `x_str` | register offset store（srb/srw 等 C910 自定义）| 区分普通 store 和寄存器偏移 store |
| `x_sync` | 同步屏障类（fence/lr/sc/amo）| LSIQ 顺序约束 |
| `x_unit_stride` | 向量 unit-stride load/store | VIQ 发射控制 |
| `x_vamo` | 向量 AMO（zvlsseg 也用此位标向量批次） | VIQ 特殊处理 |

**BJU 相关：**

| 信号 | 含义 | 用途 |
|------|------|------|
| `x_rts` | Return-To-Stack（jalr x0,x1,0 等） | 预测堆操作 |
| `x_pcall` | 函数调用（jal/jalr 写 x1/x5） | 预测堆压栈 |
| `x_pcfifo` | 分支/跳转指令（所有需要 PCFIFO 的） | auipc 也算，用于 BJU 发射的 PCFIFO 读写 |

**Barrier：**

| 信号 | 含义 |
|------|------|
| `x_bar` | fence 指令（barrier，影响 LSU 顺序） |
| `x_bar_type[3:0]` | 屏障类型：`1111`（强屏障）或 `1010`（特殊弱屏障，防止发射队列死锁） |

**short ALU 判定（`x_alu_short`）：**

```verilog
// 行 218~228：short ALU = ALU 类型，但排除几个特殊的"long ALU"
assign decd_alu_short =
  x_type_alu
  && !(  {x_opcode[31:25],x_opcode[14:12],x_opcode[6:0]} == 17'b0100000_010_0110011 // pseudo_min
      || {x_opcode[31:25],x_opcode[14:12],x_opcode[6:0]} == 17'b0110000_010_0110011 // pseudo_max
      || ... // 共 8 个 pseudo_min/max/minu/maxu 变体
      || {x_opcode[31:27],x_opcode[14:12],x_opcode[6:0]} == 15'b00000_001_0001011    // addsl
      );
```

**为什么区分 short/long ALU？** Short ALU 在 EX1 级就产生结果并可以前递（forwarding），Long ALU 需要 EX2 才有结果。IS 阶段的唤醒逻辑（wakeup）需要知道等待的依赖结果会在哪个周期准备好，以便精确地唤醒后续指令。

**向量相关译码：**

| 信号 | 含义 |
|------|------|
| `x_vec` | 向量指令（opcode 后 7 位 = `1010111`） |
| `x_vdiv` | 向量/标量除法（延迟不确定，发 VIQ 且需要特殊等待） |
| `x_mfvr` | 浮点→整数移动（fmv.x.w/fclass 等，需要整数目的物理号） |
| `x_mtvr` | 整数→浮点移动（fmv.w.x 等） |
| `x_vmla_type[2:0]` | 向量乘加类型（编码延迟信息，用于 VIQ wakeup） |
| `x_vmla_short` | 向量短延迟乘加（用于背靠背发射判断） |
| `x_vmul` | 向量乘法 |
| `x_vmul_unsplit` | 不可拆分的向量乘法 |
| `x_vsetvl/vsetvli` | 向量配置指令 |
| `x_viq_srcv12_switch` | VIQ 中 srcv1/srcv2 操作数交换（vmadd/vmacc 等指令的操作数顺序不同） |

**CSR/系统指令：**

| 信号 | 含义 |
|------|------|
| `x_csr` | CSR 访问指令（opcode 末 7 位 = `1110011`，且 funct3 != 0） |
| `x_ecall` | 系统调用（完整匹配 `32'h00000073`） |

### 5.4 实例化方式

`ct_idu_ir_dp` 为 4 条指令各例化一个 `ct_idu_ir_decd`：

```verilog
// 行 1892~1925（inst0），1929~1962（inst1），1966~1999（inst2），2003~2036（inst3）
ct_idu_ir_decd x_ct_idu_ir_decd0 (
  .x_opcode     (ir_inst0_opcode),    // 从 ir_inst0_data[31:0] 取出
  .x_illegal    (ir_inst0_illegal),   // 从 ir_inst0_data[IR_ILLEGAL] 取出
  .x_type_alu   (ir_inst0_type_alu),  // 从 ir_inst0_data[IR_INST_TYPE-9] 取出
  .x_type_staddr(ir_inst0_type_staddr), // 从 IR_INST_TYPE-4 取出
  .x_vsew       (ir_inst0_vsew),      // 从 ir_inst0_data[IR_VSEW:IR_VSEW-2] 取出
  .x_type_vload (ir_inst0_type_vload),// 从 IR_VMB 取出
  // 输出
  .x_load(ir_inst0_load), .x_store(ir_inst0_store), ...
);
```

4 个实例在结构上彼此独立，组合地处理四个 IR 槽。某槽无效时其组合输出仍由输入位决定，但只有相应 valid
协议允许下游把结果当成有效指令；“并行”说明没有在 RTL 中复用一个译码器分时计算，不等于组合传播零延迟，
也不保证四槽每周期都有效。

---

## 6. 源寄存器号提取与送查

### 6.1 整数源寄存器（送 ir_rt）

```verilog
// 行 1545~1568：整数源寄存器查询信号
assign dp_rt_inst0_src0_vld = ir_inst0_data[IR_SRC0_VLD];
assign dp_rt_inst0_src0_reg = ir_inst0_data[IR_SRC0_REG:IR_SRC0_REG-5]; // 6 位架构寄存器号
assign dp_rt_inst0_src1_vld = ir_inst0_data[IR_SRC1_VLD];
assign dp_rt_inst0_src1_reg = ir_inst0_data[IR_SRC1_REG:IR_SRC1_REG-5];
assign dp_rt_inst0_src2_vld = ir_inst0_data[IR_SRC2_VLD];  // src2 只有 vld，无独立 reg（src2=dst）
// inst1/2/3 同理
```

注意：`src2` 只有 `vld` 标志而无 `reg` 字段，因为在 C910 中整数 src2（第三个源操作数）的架构寄存器号等同于目的寄存器号（仅用于 mla 类指令的累加器），重命名表可以通过 `dst_reg` 推断。

### 6.2 浮点源寄存器（送 frt）

浮点指令有 0~3 个浮点源寄存器（`srcf0/1/2`），其中 `srcf2` 是 fmadd/fmsub 的第三个操作数，也是 `vmla` 的累加器：

```verilog
// 行 1607~1635
assign dp_frt_inst0_srcf0_vld = ir_inst0_data[IR_SRCF0_VLD];
assign dp_frt_inst0_srcf0_reg = ir_inst0_data[IR_SRCF0_REG:IR_SRCF0_REG-5];
assign dp_frt_inst0_srcf1_vld = ir_inst0_data[IR_SRCF1_VLD];
assign dp_frt_inst0_srcf1_reg = ir_inst0_data[IR_SRCF1_REG:IR_SRCF1_REG-5];
assign dp_frt_inst0_srcf2_vld = ir_inst0_data[IR_SRCF2_VLD];
assign dp_frt_inst0_srcf2_reg = ir_inst0_data[IR_SRCF2_REG:IR_SRCF2_REG-5];
```

### 6.3 向量源寄存器（送 vrt）

```verilog
// 行 1664~1692
assign dp_vrt_inst0_srcv0_vld = ir_inst0_data[IR_SRCV0_VLD];
assign dp_vrt_inst0_srcv0_reg = ir_inst0_data[IR_SRCV0_REG:IR_SRCV0_REG-5];
assign dp_vrt_inst0_srcv1_vld = ir_inst0_data[IR_SRCV1_VLD];
assign dp_vrt_inst0_srcv1_reg = ir_inst0_data[IR_SRCV1_REG:IR_SRCV1_REG-5];
assign dp_vrt_inst0_srcv2_vld = ir_inst0_data[IR_SRCV2_VLD]; // srcv2 只有 vld
assign dp_vrt_inst0_srcvm_vld = ir_inst0_data[IR_SRCVM_VLD]; // 掩码（总是 v0）
```

### 6.4 依赖信息透传

```verilog
// 行 1516
assign dp_rt_dep_info = ir_dep_info;  // 17 位依赖编码直接透传给 rt
```

`ir_dep_info` 由 ID 阶段在指令分组时预计算并随数据包一起流水传递，记录了当前批次 4 条指令之间哪些源-目的对存在 RAW 依赖，重命名表利用这个信息进行内部旁路逻辑的初始化。

---

## 7. 物理寄存器号接收

### 7.1 RTU 分配的新物理号

RTU 在 IR 阶段对每条有目的寄存器的指令预先分配一个新物理寄存器号：

```verilog
// 行 1484~1502：分配新物理号并对 x0 写哑处理
assign ir_inst0_dst_preg = {7{!ir_inst0_data[IR_DST_X0]}} & rtu_idu_alloc_preg0;
// — 若目的是 x0，则强制物理号为 0（写 x0 不应占用物理寄存器）
assign ir_inst0_dst_vreg = rtu_idu_alloc_vreg0;  // 向量目的无 x0 问题
assign ir_inst0_dst_freg = rtu_idu_alloc_freg0;  // 浮点目的无 x0 问题
assign ir_inst0_dst_ereg = rtu_idu_alloc_ereg0;  // fflags 等状态贡献的物理版本
```

**为什么对 x0 屏蔽物理号？** x0 是 RISC-V 的恒零寄存器，对它的写操作没有实际效果。如果不屏蔽，RTU 会白白分配一个物理寄存器并更新重命名表，造成资源浪费和逻辑错误。通过 `{7{!IR_DST_X0}} &` 确保 x0 的物理号为全 0。

### 7.2 功率优化：masked pipedown preg

```verilog
// 行 1505~1508：仅在目的有效时才传递物理号
assign ir_pipedown_inst0_dst_preg =
    {7{ir_inst0_data[IR_DST_VLD]}} & ir_inst0_dst_preg;
```

对于无目的寄存器的指令（如 store、fence），`IR_DST_VLD = 0`，此时物理号被屏蔽为全 0，避免无意义的数据翻转消耗动态功耗。

### 7.3 送给重命名表的目的信息

```verilog
// 行 1530~1543：告知 rt/frt/vrt 目的寄存器信息，以更新映射表
assign dp_rt_inst0_dst_vld  = ir_inst0_data[IR_DST_VLD];
assign dp_rt_inst0_dst_reg  = ir_inst0_data[IR_DST_REG:IR_DST_REG-5];  // 架构目的号
assign dp_rt_inst0_dst_preg = ir_inst0_dst_preg;                        // 新物理号
// — rt 据此建立 arch→phys 映射
```

重命名表（ir_rt）的工作原理：接收架构目的寄存器号和新物理寄存器号，当周期末尾（若不 stall）就更新映射表，使后续指令查询该架构号时得到此新物理号。

---

## 8. FRT/VRT 多路选择器

### 8.1 为什么需要统一接口

C910 的向量指令（VIQ）和浮点标量指令走不同的重命名表（vrt vs frt），但两者在 IS 数据包中共用同一套 `srcv0/srcv1/srcv2/srcvm` 字段。为了将两套来源统一成一套，`ir_dp` 内部有专门的 MUX 逻辑：

```
浮点指令（fp=1，vec=0）：
  srcv0 ← frt 查询结果（frt_dp_inst0_srcf0_data）
  srcv1 ← frt 查询结果（frt_dp_inst0_srcf1_data）
  srcv2 ← frt 查询结果（frt_dp_inst0_srcf2_data）

向量指令（vec=1）：
  srcv0 ← vrt 查询结果（vrt_dp_inst0_srcv0_data）
  srcv1 ← vrt 查询结果（vrt_dp_inst0_srcv1_data）
  srcv2 ← vrt 查询结果（vrt_dp_inst0_srcv2_data）
  srcvm ← vrt 查询结果（vrt_dp_inst0_srcvm_data，固定 v0）
```

### 8.2 MUX 实现（以 inst0 为例）

```verilog
// 行 1705~1735：FRT/VRT MUX for inst0
// 有效位：只要 srcf0 或 srcv0 任一有效，该通道就有效
assign ir_rt_inst0_srcv0_vld =
    ir_inst0_data[IR_SRCF0_VLD] || ir_inst0_data[IR_SRCV0_VLD];
assign ir_rt_inst0_srcv1_vld =
    ir_inst0_data[IR_SRCF1_VLD] || ir_inst0_data[IR_SRCV1_VLD];
assign ir_rt_inst0_srcv2_vld =
    ir_inst0_data[IR_SRCF2_VLD] || ir_inst0_data[IR_SRCV2_VLD];
assign ir_rt_inst0_srcvm_vld = ir_inst0_data[IR_SRCVM_VLD]; // 仅向量

// 数据 MUX：优先用向量重命名表结果
assign ir_rt_inst0_srcv0_data =
    ir_inst0_data[IR_SRCV0_VLD]
    ? vrt_dp_inst0_srcv0_data   // 向量指令
    : frt_dp_inst0_srcf0_data;  // 浮点指令

assign ir_rt_inst0_srcv1_data =
    ir_inst0_data[IR_SRCV1_VLD]
    ? vrt_dp_inst0_srcv1_data
    : frt_dp_inst0_srcf1_data;

assign ir_rt_inst0_srcv2_data =
    ir_inst0_data[IR_SRCV2_VLD]
    ? vrt_dp_inst0_srcv2_data
    : frt_dp_inst0_srcf2_data;

assign ir_rt_inst0_srcvm_data = vrt_dp_inst0_srcvm_data;  // 掩码只来自 vrt
```

**MUX 的选择逻辑**：`IR_SRCV0_VLD=1` 时选择 VRT 结果，否则选择 FRT 结果。若该
统一源本身无效，MUX 输出仍可能落在 FRT 一侧，但下游必须由合并后的 source-valid
屏蔽，不能说“否则就保证是有效浮点源”。正常译码协议还应避免标量浮点源与向量源
同时有效；当前配置 `x_vec_inst=0`，有效 RVV 指令不会从上游进入这条向量选择路径。

### 8.3 目的寄存器统一化

目的寄存器同样需要统一：

```verilog
// 行 1724~1734：dst_vreg 统一化（以 inst0 为例）
// 5 位架构号统一选：向量用 dstv_reg，浮点用 dstf_reg
assign ir_rt_inst0_dstv_reg =
    ir_inst0_data[IR_DSTV_VLD]
    ? ir_inst0_data[IR_DSTV_REG-1:IR_DSTV_REG-5]
    : ir_inst0_data[IR_DSTF_REG-1:IR_DSTF_REG-5];

// 7 位物理号统一：最高位 1=向量物理号，0=浮点物理号（区分两个物理寄存器空间）
assign ir_rt_inst0_dst_vreg =
    {7{ir_inst0_data[IR_DSTV_VLD]}} & {1'b1, ir_inst0_dst_vreg}  // 向量
  | {7{ir_inst0_data[IR_DSTF_VLD]}} & {1'b0, ir_inst0_dst_freg}; // 浮点

// 旧物理号（for release）也需要统一选
assign ir_rt_inst0_rel_vreg =
    ir_inst0_data[IR_DSTV_VLD]
    ? vrt_dp_inst0_rel_vreg   // 向量重命名表返回的旧物理号
    : frt_dp_inst0_rel_freg;  // 浮点重命名表返回的旧物理号
```

注意 `dst_vreg[6]` 最高位的含义：VRT 中用 1 区分向量物理寄存器空间，用 0 区分浮点物理寄存器空间，两个空间的物理号可以独立编址而不冲突。

### 8.4 同周期 srcv2 匹配汇总

```verilog
// 行 1842~1854：汇总 frt 和 vrt 的同周期 srcv2 匹配信号
assign dp_ir_inst01_src_match[3] =
    frt_dp_inst01_srcf2_match || vrt_dp_inst01_srcv2_match;
// — inst1 的 srcv2/srcf2 依赖于同周期 inst0 的目的时，两个重命名表各上报一个匹配位，取 OR
assign dp_ir_inst12_src_match[3] = frt_dp_inst12_srcf2_match || vrt_dp_inst12_srcv2_match;
assign dp_ir_inst23_src_match[3] = frt_dp_inst23_srcf2_match || vrt_dp_inst23_srcv2_match;
// ... 类似地处理 inst02/03/13 对
```

前 3 位来自整数重命名表：
```verilog
// 行 1849~1854
assign dp_ir_inst01_src_match[2:0] = rt_dp_inst01_src_match[2:0];
// ...
```

这 4 位匹配向量的含义：
- `[0]` = inst(A) 的 src0 依赖 inst(B) 的目的
- `[1]` = inst(A) 的 src1 依赖 inst(B) 的目的
- `[2]` = inst(A) 的 src2 依赖 inst(B) 的目的
- `[3]` = inst(A) 的 srcv2/srcf2 依赖 inst(B) 的目的

---

## 9. 同周期依赖旁路

这是 IR 数据通路最复杂、最关键的部分，理解它需要先明白问题的根源。

### 9.1 问题描述：重命名表的"老化"

推测重命名表保存的是此前已经完成重命名更新的当前映射；该映射可以包含尚未退休的
在途目的，并不只包含已提交状态。恢复映射由另一套退休/恢复机制维护。当同一个 IR
组合窗口内多个程序序槽共同更新/查询同一架构寄存器时，会出现本拍可见性问题：

```
假设当前周期：
  inst0: ADD  x5, x1, x2    → 目的 x5，分配物理号 p50
  inst1: MUL  x7, x5, x3    → 源 x5，需要 p50 的映射
  inst2: SUB  x5, x5, x4    → 目的 x5，分配物理号 p51（覆盖 inst0 的 x5）
  inst3: AND  x8, x5, x6    → 源 x5，需要 p51（inst2 的新 x5）
```

问题：重命名表在本周期初看到的 x5 映射是上一周期已有的旧值（比如 p45），它不知道 inst0/inst2 在本周期也在写 x5。如果 inst1 直接查重命名表得到 p45，那就是错误的物理号！

### 9.2 解决方案：同周期依赖由重命名表内部处理

C910 的架构将**同周期旁路逻辑放在重命名表（ir_rt）内部**，而不是放在 `ir_dp` 中。`ir_dp` 的职责是：

1. 把 4 条指令的目的寄存器号和新分配物理号一起送给 ir_rt
2. 接收 ir_rt 返回的已经旁路修正过的源物理号

### 9.3 依赖信息向量（dep_info）

`ir_dep_info[16:0]` 是 ID 阶段预计算的依赖编码，`ir_dp` 透传给 `ir_rt`：

```
参数定义（行 1144~1162）：
DEP_INST01_SRC0_MASK  = 0   → inst1 的 src0 依赖 inst0 的目的（整数）
DEP_INST01_SRC1_MASK  = 1   → inst1 的 src1 依赖 inst0 的目的（整数）
DEP_INST12_SRC0_MASK  = 2   → inst2 的 src0 依赖 inst1 的目的
DEP_INST12_SRC1_MASK  = 3   → inst2 的 src1 依赖 inst1 的目的
DEP_INST23_SRC0_MASK  = 4   → inst3 的 src0 依赖 inst2 的目的
DEP_INST23_SRC1_MASK  = 5   → inst3 的 src1 依赖 inst2 的目的
DEP_INST02_PREG_MASK  = 6   → inst2 的源依赖 inst0 的物理目的（跨一条）
DEP_INST13_PREG_MASK  = 7   → inst3 的源依赖 inst1 的物理目的
DEP_INST01_VREG_MASK  = 8   → inst1 的向量源依赖 inst0 的向量目的
DEP_INST12_VREG_MASK  = 9   → inst2 的向量源依赖 inst1 的向量目的
DEP_INST23_VREG_MASK  = 10  → inst3 的向量源依赖 inst2 的向量目的
DEP_INST13_VREG_MASK  = 11  → inst3 的向量源依赖 inst1 的向量目的
DEP_INST02_VREG_MASK  = 12  → inst2 的向量源依赖 inst0 的向量目的
DEP_INST03_VREG_MASK  = 13  → inst3 的向量源依赖 inst0 的向量目的
DEP_INST01_SRCV1_MASK = 14  → inst1 的 srcv1 依赖 inst0 的向量目的
DEP_INST12_SRCV1_MASK = 15  → inst2 的 srcv1 依赖 inst1 的向量目的
DEP_INST23_SRCV1_MASK = 16  → inst3 的 srcv1 依赖 inst2 的向量目的
```

### 9.4 匹配结果反馈（src_match）

`ir_rt` 完成旁路计算后，向 `ir_dp` 返回各指令对间的依赖匹配结果：

```verilog
// 行 1849~1854：接收 rt 的匹配结果并汇总
assign dp_ir_inst01_src_match[2:0] = rt_dp_inst01_src_match[2:0];
// 含义：inst1 的 src0/src1/src2 中哪些需要从 inst0 的新物理号旁路
```

这些匹配向量被同时送给 IS 阶段：IS 阶段需要知道 "inst1 正在等待 inst0 的结果"，以便在 inst0 执行完毕时能精确唤醒 inst1。

### 9.5 旁路的完整数据流

```
                  ir_dp                           ir_rt
                    │                               │
  inst0 目的 arch reg ──────────────────────────▶  │
  inst0 新物理号 preg0 ─────────────────────────▶  │  比较:
                                                    │  若 inst1.src0_reg == inst0.dst_reg
  inst1 源 arch reg ───────────────────────────▶   │  则 inst1.src0_preg = preg0 (旁路!)
                                                    │  否则 inst1.src0_preg = 表中查得的值
  inst1 物理源号 ←──────────────────────────────── │
                                                    │
  src_match[0] ←──── inst1 src0 hit inst0 dst ─── │
```

`rt_dp_inst0_src0_data[8:0]` 包含：
- `[8]` = 旁路就绪位（BP_RDY，表示值已经在物理寄存器中，或者会在特定延迟后出现）
- `[7:0]` = 物理寄存器号（7 位），高位可能为 LSU match 标志

### 9.6 同周期旁路示意图

```
周期 N：4 条指令同时进 IR 阶段

  inst0: ADD x5, x1, x2                       分配 p50→x5
  inst1: MUL x7, x5, x3     src x5 ────────▶ 旁路: 用 p50（inst0 新分配）
  inst2: SUB x5, x5, x4     src x5 ─ ? ─────▶ 旁路: inst2 的 src0 x5 用 p50（inst0 最新写 x5）
                                                分配 p51→x5（覆盖 inst0 对 x5 的映射）
  inst3: AND x8, x5, x6     src x5 ────────▶ 旁路: 用 p51（inst2 最新写 x5，程序序最近）

关键：若 inst0 和 inst2 都写 x5，inst3 必须拿 inst2（更新的）的物理号 p51。
     DEP_INST02_PREG_MASK = bit[6] 的存在就是为了处理这种"跨越中间指令"的依赖。
```

### 9.7 向量依赖的特殊性

向量指令的 `srcv2`（累加器）在 IS 阶段有专门的 match 逻辑，因为向量乘加指令（vmacc/vmadd）的 srcv2 = 目的向量寄存器，具有读-改-写（RMW）语义，依赖关系更紧密。`DEP_INST01_SRCV1_MASK` 等专门处理 srcv1 的依赖。

---

## 10. IS 数据字段定义

`dp_ir_inst*_data[270:0]`（271 位）是送 IS 阶段的完整数据包，字段含义：

```
位[270]       IS_VL_PRED         — 向量长度预测标志（透传）
位[269:262]   IS_VL[7:0]         — 向量长度
位[261]       IS_LCH_PREG        — 需要在 IS 阶段预先读物理寄存器（RF launch 预计算）
位[260]       IS_VAMO            — 向量 AMO 指令
位[259]       IS_UNIT_STRIDE     — 向量 unit-stride
位[258]       IS_VMB             — 向量内存屏障
位[257]       IS_DSTV_IMP        — 隐含向量目的（dstf 或 dstv 任一有效）
位[256]       IS_VIQ_SRCV12_SWITCH — VIQ 中 srcv1/v2 操作数需交换
位[255]       IS_VSETVL          — vsetvl 指令
位[254]       IS_VSETVLI         — vsetvli 指令
位[253:251]   IS_VSEW[2:0]       — 向量元素宽度
位[250:249]   IS_VLMUL[1:0]      — 向量寄存器组长
位[248]       IS_VMUL            — 向量乘法
位[247]       IS_VMUL_UNSPLIT    — 不可拆分向量乘法
位[246]       IS_VMLA_SHORT      — 向量短延迟乘加
位[245:243]   IS_VMLA_TYPE[2:0]  — 向量乘加类型（用于 wakeup 延迟）
位[242:236]   IS_SPLIT_NUM[6:0]  — 拆分片段编号
位[235]       IS_NO_SPEC         — 禁止推测
位[234]       IS_ALU_SHORT       — 短延迟 ALU（IR 译码新增）
位[233]       IS_MLA             — 整数乘加（src2=dst）
位[232]       IS_STR             — register offset store（IR 译码新增）
位[231]       IS_SPLIT_LAST      — 拆分最后片段
位[230]       IS_MFVR            — 浮点→整数移动（IR 译码新增）
位[229]       IS_MTVR            — 整数→浮点移动（IR 译码新增）
位[228]       IS_VMLA            — 向量乘加（FRT/VRT MUX 后的统一标志）
位[227]       IS_VDIV            — 向量/标量除法
位[226]       IS_PIPE7           — 向量 pipe7
位[225]       IS_PIPE6           — 向量 pipe6
位[224]       IS_PIPE67          — 向量 pipe67
位[223:220]   IS_IID_PLUS[3:0]   — IID 偏移（拆分用）
位[219]       IS_BKPTB_INST      — 断点 B
位[218]       IS_BKPTA_INST      — 断点 A
位[217:211]   IS_EXPT[6:0]       — 异常编码
位[210]       IS_RTS             — 返回（return）指令（IR 译码新增）
位[209]       IS_SPECIAL         — 特殊指令
位[208]       IS_LSU             — LSU 类
位[207]       IS_DIV             — 除法
位[206]       IS_MULT            — 乘法
位[205]       IS_INTMASK         — 关中断
位[204]       IS_SPLIT           — 拆分中
位[203]       IS_LENGTH          — 指令长度
位[202]       IS_PCFIFO          — PCFIFO 相关（IR 译码新增）
位[201]       IS_PCALL           — 函数调用（IR 译码新增）
位[200]       IS_BJU             — 分支跳转
位[199:185]   IS_LSU_PC[14:0]    — LSU 用 PC 低位
位[184:181]   IS_BAR_TYPE[3:0]   — 屏障类型（IR 译码新增）
位[180]       IS_BAR             — barrier 指令（IR 译码新增）
位[179]       IS_STADDR          — store address 类型
位[178]       IS_STORE           — store 指令（IR 译码新增）
位[177]       IS_LOAD            — load 指令（IR 译码新增）
位[176]       IS_ALU             — ALU 类
位[175:171]   IS_DST_REL_EREG    — 旧扩展目的物理号（待释放）
位[170:166]   IS_DST_EREG        — 新扩展目的物理号
位[165:159]   IS_DST_REL_VREG    — 旧向量/浮点目的物理号（待释放，7 位）
位[158:152]   IS_DST_VREG        — 新向量/浮点目的物理号（7 位，含类型标志位）
位[151:147]   IS_DSTV_REG        — 向量/浮点目的架构号（5 位，统一后）
位[146]       IS_SRCVM_LSU_MATCH — 掩码源的 LSU match（初始置 0，IS 阶段会更新）
位[145:144]   IS_SRCVM_BP_RDY    — 掩码源旁路就绪（初始置 0）
位[143:136]   IS_SRCVM_DATA/VREG — 掩码源物理号（9 位，来自 vrt）
位[135:134]   IS_SRCV2_WB        — srcv2 写回标志（部分）
...（以此类推 srcv2, srcv1, srcv0 各占约 12 位：LSU_MATCH/BP_RDY/DATA/WB）
位[97]        IS_DSTE_VLD        — 扩展目的有效
位[96]        IS_DSTV_VLD        — 向量/浮点目的有效
位[95:92]     IS_SRCV{M,2,1,0}_VLD — 各向量源有效位
位[91:85]     IS_DST_REL_PREG    — 旧整数目的物理号（7 位，待释放）
位[84:78]     IS_DST_PREG        — 新整数目的物理号（7 位）
位[77:73]     IS_DST_REG         — 整数目的架构号（5 位，不含 x 前缀编号）
位[72:35]     IS_SRC{2,1,0}_{LSU_MATCH,BP_RDY,DATA,WB,VLD} — 整数源物理寄存器信息
位[35]        IS_DST_VLD         — 整数目的有效
位[34:32]     IS_SRC{2,1,0}_VLD  — 整数源有效
位[31:0]      IS_OPCODE          — 原始指令编码（透传）
```

> 注：IS 阶段中 `BP_RDY`、`LSU_MATCH`、`WB` 字段在 IR 阶段进入时初始化为 `2'b0`/`1'b0`，由 IS 队列中的旁路逻辑动态更新。

---

## 11. 重命名后指令组装

### 11.1 组装原理

IR 阶段的核心输出任务是把 178 位的 `ir_inst*_data` 扩充成 271 位的 `dp_ir_inst*_data`，主要增加了：

1. **物理寄存器号**（src0/src1/src2/srcv0/srcv1/srcv2/srcvm 的物理号及旁路就绪位）
2. **IR 译码新增字段**（load/store/bar/rts/pcall/pcfifo/alu_short/mfvr/mtvr/vmla_type 等）
3. **Release 物理号**（旧物理号，告知 RTU 何时可以释放）
4. **预计算字段**（lch_preg：是否需要在 IS 阶段进行 RF launch 预计算）

### 11.2 关键组装点（以 inst0 为例）

```verilog
// 行 2074~2164：inst0 的 IS 数据包组装
// — 新增的 IR 译码结果 —
assign dp_ir_inst0_data[IS_ALU_SHORT]    = ir_inst0_alu_short;    // IR 译码新增
assign dp_ir_inst0_data[IS_STR]          = ir_inst0_str;          // IR 译码新增
assign dp_ir_inst0_data[IS_LOAD]         = ir_inst0_load;         // IR 译码新增
assign dp_ir_inst0_data[IS_STORE]        = ir_inst0_store;        // IR 译码新增
assign dp_ir_inst0_data[IS_BAR]          = ir_inst0_bar;          // IR 译码新增
assign dp_ir_inst0_data[IS_BAR_TYPE]     = ir_inst0_bar_type;     // IR 译码新增
assign dp_ir_inst0_data[IS_RTS]          = ir_inst0_rts;          // IR 译码新增
assign dp_ir_inst0_data[IS_PCALL]        = ir_inst0_pcall;        // IR 译码新增
assign dp_ir_inst0_data[IS_PCFIFO]       = ir_inst0_pcfifo;       // IR 译码新增
assign dp_ir_inst0_data[IS_MFVR]         = ir_inst0_mfvr;         // IR 译码新增
assign dp_ir_inst0_data[IS_MTVR]         = ir_inst0_mtvr;         // IR 译码新增
assign dp_ir_inst0_data[IS_VMLA]         = ir_rt_inst0_vmla;      // FRT/VRT 统一后

// — 整数源物理寄存器（重命名表查询结果）—
assign dp_ir_inst0_data[IS_SRC0_DATA:IS_SRC0_DATA-8] = rt_dp_inst0_src0_data[8:0];
assign dp_ir_inst0_data[IS_SRC1_DATA:IS_SRC1_DATA-8] = rt_dp_inst0_src1_data[8:0];
assign dp_ir_inst0_data[IS_SRC2_DATA:IS_SRC2_DATA-9] = rt_dp_inst0_src2_data[9:0];

// — 整数目的物理寄存器 —
assign dp_ir_inst0_data[IS_DST_PREG:IS_DST_PREG-6]     = ir_pipedown_inst0_dst_preg;
assign dp_ir_inst0_data[IS_DST_REL_PREG:IS_DST_REL_PREG-6] = rt_dp_inst0_rel_preg; // 旧号

// — 向量/浮点源物理寄存器（FRT/VRT 统一后）—
assign dp_ir_inst0_data[IS_SRCV0_DATA:IS_SRCV0_DATA-8] = ir_rt_inst0_srcv0_data;
assign dp_ir_inst0_data[IS_SRCV1_DATA:IS_SRCV1_DATA-8] = ir_rt_inst0_srcv1_data;
assign dp_ir_inst0_data[IS_SRCV2_DATA:IS_SRCV2_DATA-9] = ir_rt_inst0_srcv2_data;
assign dp_ir_inst0_data[IS_SRCVM_DATA:IS_SRCVM_DATA-8] = ir_rt_inst0_srcvm_data;

// — 向量/浮点目的物理寄存器 —
assign dp_ir_inst0_data[IS_DST_VREG:IS_DST_VREG-6]     = ir_rt_inst0_dst_vreg;
assign dp_ir_inst0_data[IS_DST_REL_VREG:IS_DST_REL_VREG-6] = ir_rt_inst0_rel_vreg;

// — 初始化 IS 阶段的旁路状态位（由 IS 队列动态更新）—
assign dp_ir_inst0_data[IS_SRC0_LSU_MATCH] = 1'b0; // 进队列时尚未命中 LSU
assign dp_ir_inst0_data[IS_SRC0_BP_RDY:IS_SRC0_BP_RDY-1] = 2'b0; // 旁路不就绪
// src1/src2/srcv0/v1/v2/vm 同理初始化为 0
```

### 11.3 inst1/2/3 的组装

inst1/2/3 使用与 inst0 相同的 IS 数据字段布局，并在相邻连续赋值中连接各自槽号
的译码、重命名和依赖结果（行 2166~2440）。这些 374-bit 数据包由并列组合逻辑
形成，不是四次串行循环；但槽号仍影响同包依赖、较老目的旁路、rel 物理号以及
上游选择，因此不能笼统称为“行为完全对称”。“同一周期形成”表示位于同一个
组合流水阶段，是否在目标采样边沿前满足时序仍由综合逻辑、扇出、布线和 STA
决定，不等于零延迟或无关键路径。

---

## 12. 控制信息提取

### 12.1 dp_ctrl_ir_inst*_ctrl_info（13 位）

这 13 位信息被送给 IR 控制逻辑（`ct_idu_ir_ctrl`），用于决定每条指令应该分发到哪个发射队列：

```verilog
// 行 1373~1436
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_ALU]     = ir_inst0_data[IR_INST_TYPE-9]; // ALU
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_MULT]    = ir_inst0_data[IR_INST_TYPE-7]; // 乘法
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_DIV]     = ir_inst0_data[IR_INST_TYPE-6]; // 除法
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_BJU]     = ir_inst0_data[IR_INST_TYPE-8]; // 分支
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_LSU]     = ir_inst0_data[IR_INST_TYPE-5]; // LSU
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_SPLIT]   = ir_inst0_data[IR_SPLIT];       // 拆分中
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_INTMASK] = ir_inst0_data[IR_INTMASK];     // 关中断
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_STADDR]  = ir_inst0_data[IR_INST_TYPE-4]; // staddr
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_SPECIAL] = ir_inst0_data[IR_INST_TYPE];   // 特殊
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_PIPE67]  = ir_inst0_data[IR_INST_TYPE-3]; // pipe67
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_PIPE6]   = ir_inst0_data[IR_INST_TYPE-2]; // pipe6
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_PIPE7]   = ir_inst0_data[IR_INST_TYPE-1]; // pipe7
assign dp_ctrl_ir_inst0_ctrl_info[IS_CTRL_VMB]     = ir_inst0_data[IR_VMB];         // 向量内存屏障
```

**IS_CTRL 与发射队列的映射：**

| IS_CTRL 位 | 对应发射队列 |
|-----------|------------|
| ALU / MULT / DIV | AIQ0 或 AIQ1（整数发射队列） |
| BJU | BIQ（分支发射队列） |
| LSU + STADDR | LSIQ（地址部分）+ SDIQ（数据部分） |
| LSU（不含 STADDR） | LSIQ |
| PIPE67 | VIQ0 或 VIQ1 |
| PIPE6 | VIQ0（优先 pipe6） |
| PIPE7 | VIQ1（优先 pipe7） |
| SPECIAL | LSIQ 或 AIQ（按具体类型） |

### 12.2 dp_ctrl_ir_inst*_hpcp_type（7 位）

7 位高性能计数器分类，供 HPCP（Hardware Performance Counter Processing）模块统计各类指令执行数量：

```verilog
// 行 1438~1479
assign dp_ctrl_ir_inst0_hpcp_type[0] =
    ir_inst0_data[IR_INST_TYPE-9]   // ALU
    || ir_inst0_data[IR_INST_TYPE-7] // MULT
    || ir_inst0_data[IR_INST_TYPE-6]; // DIV
assign dp_ctrl_ir_inst0_hpcp_type[1] = ir_inst0_data[IR_INST_TYPE-5]; // LSU
assign dp_ctrl_ir_inst0_hpcp_type[2] = ir_inst0_vec;    // 向量（IR 译码新增）
assign dp_ctrl_ir_inst0_hpcp_type[3] = ir_inst0_csr;    // CSR
assign dp_ctrl_ir_inst0_hpcp_type[4] = ir_inst0_ecall;  // ecall
assign dp_ctrl_ir_inst0_hpcp_type[5] = ir_inst0_sync;   // 同步屏障
assign dp_ctrl_ir_inst0_hpcp_type[6] = ir_inst0_fp;     // 浮点
```

### 12.3 dst 有效标志

```verilog
// 行 1348~1371
assign dp_ctrl_ir_inst0_dst_vld  = ir_inst0_data[IR_DST_VLD];  // 整数目的有效
assign dp_ctrl_ir_inst0_dst_x0   = ir_inst0_data[IR_DST_X0];   // 写 x0（无效）
assign dp_ctrl_ir_inst0_dstv_vld = ir_inst0_data[IR_DSTV_VLD]; // 向量目的有效
assign dp_ctrl_ir_inst0_dste_vld = ir_inst0_data[IR_DSTE_VLD]; // 扩展目的有效
assign dp_ctrl_ir_inst0_dstf_vld = ir_inst0_data[IR_DSTF_VLD]; // 浮点目的有效
```

这些信号告知控制逻辑（`ir_ctrl`）：是否需要为每条指令申请新的物理寄存器号（通过 `rtu_idu_alloc_preg*`），以及 RTU 应该为哪类寄存器分配。

---

## 13. lch_preg 预计算

### 13.1 作用

`IS_LCH_PREG` 由“存在整数目的寄存器”且指令类型为 ALU 或 SPECIAL 形成：

```verilog
// 行 2055~2066
assign ir_inst0_lch_preg = ir_inst0_data[IR_DST_VLD]
    && (ir_inst0_data[IR_INST_TYPE-9]  // ALU 类
     || ir_inst0_data[IR_INST_TYPE]);  // SPECIAL 类（CSR 等）
```

### 13.2 它实际控制什么

该位随 IS 数据包进入 AIQ，并在生产者被发射时参与
`aiq0_issue_alu_reg_vld = aiq0_xx_issue_en && dp_ctrl_is_aiq0_issue_lch_preg`。
RF 控制再把它寄存为多份 `preg_lch_vld`，供前递网络把该指令的目的 preg 作为候选生产者进行比较。
因此它描述的是**目的寄存器的 launch/前递资格**，不是消费者在 IS 阶段提前读取 PRF，也不是物理寄存器号
在发射时才查询。

为什么方程只覆盖 ALU/SPECIAL，可以从 RTL确认是生产者类型筛选；短流水结果通常需要较早建立旁路资格是合理
的体系结构解释。但具体由 EX1 还是 EX2 提供数据、节省多少周期，仍需结合 `rf_ctrl`、`rf_fwd`、IU 结果有效
信号和波形判断。LSU/VFPU 有各自的目的号广播与依赖更新路径，不能概括为“延迟长所以不需要优化”。

---

## 14. 整体数据流总结

### 14.1 完整信号流图

```
                         ID 阶段                 IR 阶段（ct_idu_ir_dp）
                        ─────────────────────────────────────────────
                         ir_inst0_data[177:0]
                              │
                              ▼
                    ┌─────────────────┐
                    │  流水线寄存器    │  ←── stall 时保持，复位时清零
                    │  (if !stall)    │
                    └────────┬────────┘
                             │  ir_inst{0~3}_data
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │ ir_decd  │   │  送查    │   │ 接收新   │
        │ (4个实例)│   │ 重命名表 │   │ 物理寄号 │
        │ 提取新增 │   │ rt/frt   │   │ 来自 RTU │
        │ 控制字段 │   │ /vrt     │   │ alloc_*  │
        └────┬─────┘   └────┬─────┘   └────┬─────┘
             │              │               │
             ▼              ▼               │
      load/store/bar  ┌───────────┐        │
      alu_short/mfvr  │ 接收物理  │ ◀──────┘
      rts/pcall/sync  │ 寄存器号  │
      vmla_type/...   │ src data  │  ← src0/1/2 (rt_dp_*)
                      │ rel_preg  │  ← 旧物理号（待释放）
                      └────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ FRT/VRT MUX │  浮点/向量统一成 srcv0~srcv2 字段
                    └──────┬──────┘
                           │
                    ┌──────▼──────────────────────────────────────────┐
                    │          组装 IS 数据包（271 位）                 │
                    │  控制字段（load/store/alu/vmla_type/...）         │
                    │  物理源寄存器号 + 旁路就绪位                      │
                    │  物理目的寄存器号 + 旧物理号                      │
                    │  向量元素配置（vsew/vlmul/vl/...）               │
                    │  BP_RDY/LSU_MATCH 初始化为 0                    │
                    └────────────────┬────────────────────────────────┘
                                     │
                    ┌────────────────▼──────────────────┐
                    │              IS 阶段               │
                    │        (ct_idu_is_dp/ctrl)         │
                    │  发射队列入队、乱序唤醒、发射        │
                    └────────────────────────────────────┘
```

### 14.2 各逻辑块一览表

| 逻辑块 | 行号范围 | 关键信号 | 作用 |
|--------|---------|---------|------|
| 参数定义 | 1083~1293 | IR_*/IS_*/DEP_*/IS_CTRL_* | 定义所有位字段偏移量，是理解全文的基础 |
| 时钟门控 | 1297~1308 | ir_inst_clk, ir_inst_clk_en | 降低静态和动态功耗 |
| 流水线寄存器 | 1320~1343 | ir_inst{0~3}_data, ir_dep_info | ID→IR 时序打拍 |
| 控制信号提取 | 1348~1479 | dp_ctrl_ir_inst*_{dst_vld/ctrl_info/hpcp_type} | 送 ctrl 模块决策 |
| 目的物理号赋值 | 1484~1508 | ir_inst*_dst_{preg/vreg/freg/ereg} | 接收 RTU 分配 |
| 送整数重命名表 | 1510~1578 | dp_rt_inst*_* | 查询整数物理源/目的 |
| 送浮点重命名表 | 1580~1645 | dp_frt_inst*_* | 查询浮点物理源/目的 |
| 送向量重命名表 | 1649~1697 | dp_vrt_inst*_* | 查询向量物理源/目的 |
| FRT/VRT MUX | 1700~1854 | ir_rt_inst*_src{v0/v1/v2/vm}_* | 浮点/向量统一 |
| 实例化 ir_decd | 1856~2036 | ir_inst*_{load/store/bar/...} | 4 个并行 IR 译码器 |
| bar 输出 | 2045~2048 | dp_ctrl_ir_inst*_bar | 送 ctrl 做 barrier 处理 |
| lch_preg 类型限定 | 2050~2066 | ir_inst*_lch_preg | 标记 ALU/SPECIAL 的整数目的 preg 可进入 RF launch/前递资格路径 |
| IS 数据组装 inst0 | 2074~2164 | dp_ir_inst0_data[270:0] | 271 位完整 IS 数据包 |
| IS 数据组装 inst1 | 2166~2256 | dp_ir_inst1_data[270:0] | 同上，inst1 |
| IS 数据组装 inst2 | 2258~2348 | dp_ir_inst2_data[270:0] | 同上，inst2 |
| IS 数据组装 inst3 | 2350~2440 | dp_ir_inst3_data[270:0] | 同上，inst3 |

### 14.3 与上下游模块的接口总结

```
上游：ct_idu_id_dp（ID 阶段数据通路）
  → 178 位指令数据包 × 4
  → 17 位依赖信息

旁路：ct_idu_ir_rt（整数重命名表）
  ← 架构源寄存器号 + 目的信息 + 依赖编码
  → 物理源寄存器号（含旁路修正） + 旧物理目的号

旁路：ct_idu_ir_frt（浮点重命名表）
  ← 浮点架构源/目的寄存器号 + fmla/fmov 标志
  → 浮点/扩展物理号 + 同周期 srcf2 匹配位

旁路：ct_idu_ir_vrt（向量重命名表）
  ← 向量架构源/目的寄存器号 + vmla 标志
  → 向量物理号（含掩码） + 同周期 srcv2 匹配位

外部：rtu（退休单元）
  ← 新分配的物理寄存器号（preg/freg/vreg/ereg × 4）

下游：ct_idu_is_dp（IS 阶段数据通路）
  → 271 位 IS 数据包 × 4（含物理寄存器号、IR 译码结果）
  → 同周期依赖匹配向量 × 6 对

下游：ct_idu_ir_ctrl（IR 阶段控制逻辑）
  → 13 位发射控制信息 × 4
  → 目的有效标志 × 4 × {dst/dstv/dste/dstf}
  → 7 位 HPCP 分类 × 4
  → barrier 标志 × 4
```

---

*文档对应 RTL 版本：`ct_idu_ir_dp.v`（2445 行）+ `ct_idu_ir_decd.v`（663 行），T-Head C910。*
