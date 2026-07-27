# C910 IDU 向量发射队列（VIQ）详解

> RTL 文件：
> - `ct_idu_is_viq0.v`（1857 行）—— 向量发射队列 0，发射到 pipe6
> - `ct_idu_is_viq1.v`（1840 行）—— 向量发射队列 1，发射到 pipe7
> - `ct_idu_is_viq0_entry.v`（1492 行）—— VIQ0 每个 entry 的内部逻辑
> - `ct_idu_is_viq1_entry.v`（1482 行）—— VIQ1 每个 entry 的内部逻辑

---

## 1. 模块概述

### 1.1 向量发射队列的特殊性

VIQ（Vector Issue Queue）是 C910 IDU 中专门服务向量/浮点指令的发射队列。它与整数发射队列（AIQ）的核心区别在于：

| 特性 | AIQ（整数） | VIQ（向量） |
|------|-------------|-------------|
| 源操作数类型 | 1–2 个标量寄存器 | 最多 4 个：srcv0、srcv1、srcv2、srcvm |
| 向量掩码 | 无 | srcvm（始终为 v0 寄存器） |
| 第三向量源 | 无 | srcv2（FMA 累加源，使用专用 `dep_vreg_srcv2_entry`）|
| 执行延迟 | 短（1–3 周期） | 长（最多 5 级 EX1–EX5） |
| 唤醒来源 | pipe0–pipe5 | pipe6、pipe7（VFPU）、pipe3（LSU 向量 load）|
| vdiv 阻塞 | 无 | viq0 需检查 `vfpu_idu_vdiv_busy` |
| 数据字段 | 标量寄存器号 | VL / VSEW / VLMUL + 向量寄存器号 |

向量 FMA 指令（`vfmacc`/`vfnmacc` 等）具有三个向量源和一个掩码源，因此 VIQ entry 必须同时跟踪 **四路依赖**，这是复杂性的根本来源。

### 1.2 双队列设计意图

C910 设置两个独立的向量发射队列：

```
VIQ0 ─────► pipe6 ─────► VFPU EX1~EX5 ─► wb（vreg）
VIQ1 ─────► pipe7 ─────► VFPU EX1~EX5 ─► wb（vreg）
```

两个队列各深 8 项，每周期最多各发射一条指令，支持双发射吞吐。每个队列独立维护自己的 entry 计数、满/空标志、年龄向量和就绪状态。

---

## 2. 队列结构

### 2.1 整体层次

```
ct_idu_is_viq0
├── entry_cnt（4 bit，记录 0~8 项占用数）
├── entry_create0_in / entry_create1_in（8 bit onehot，分配指针）
├── viq0_entry0 ~ viq0_entry7（8 个 ct_idu_is_viq0_entry 实例）
│   ├── vld / frz / agevec（7 bit）
│   ├── 指令信息寄存器（opcode / iid / VL / VSEW / VLMUL / …）
│   ├── ct_idu_dep_vreg_entry  ×3（srcv0 / srcv1 / srcvm）
│   └── ct_idu_dep_vreg_srcv2_entry ×1（srcv2，专用）
└── 发射选择逻辑（年龄仲裁）
```

### 2.2 数据通路宽度

| 队列 | 参数宏 | 位宽 |
|------|--------|------|
| VIQ0 | `VIQ0_WIDTH` | 151 bit |
| VIQ1 | `VIQ1_WIDTH` | 150 bit |

VIQ0 比 VIQ1 多 1 bit，原因是 VIQ0 携带 `vdiv` 标志（位 135），用于检测向量除法指令是否可以发射（见第 9 节）。

### 2.3 entry 数据格式（VIQ0，151 bit）

下表从高位到低位排列，参数定义见 `ct_idu_is_viq0_entry.v` 第 392–438 行：

| 位域 | 参数名 | 宽度 | 含义 |
|------|--------|------|------|
| [150:143] | VIQ0_VL | 8 | 向量长度 VL |
| [142:140] | VIQ0_VSEW | 3 | 元素宽度 SEW |
| [139:138] | VIQ0_VLMUL | 2 | 寄存器组因子 LMUL |
| [137] | VIQ0_VMUL | 1 | vmul 指令标志 |
| [136] | VIQ0_VMLA_SHORT | 1 | vmla short 标志 |
| [135] | VIQ0_VDIV | 1 | vdiv 指令标志（VIQ0 独有）|
| [134:127] | VIQ0_LCH_RDY_VIQ1 | 8 | 对 VIQ1 各 entry 的 lch_rdy 位图 |
| [126:119] | VIQ0_LCH_RDY_VIQ0 | 8 | 对 VIQ0 各 entry 的 lch_rdy 位图 |
| [118:116] | VIQ0_VMLA_TYPE | 3 | vmla 类型 |
| [115:109] | VIQ0_SPLIT_NUM | 7 | 向量分裂序号 |
| [108] | VIQ0_SPLIT_LAST | 1 | 是否最后一个 split |
| [107] | VIQ0_MFVR | 1 | mfvr 指令标志 |
| [106] | VIQ0_VMLA | 1 | vmla 指令标志 |
| [105:96] | VIQ0_SRCVM_DATA/RDY | 10 | 掩码源 srcvm 依赖信息 |
| [95:85] | VIQ0_SRCV2_DATA/RDY | 11 | 第三向量源 srcv2 依赖信息 |
| [84:75] | VIQ0_SRCV1_DATA/RDY | 10 | 向量源 srcv1 依赖信息 |
| [74:65] | VIQ0_SRCV0_DATA/RDY | 10 | 向量源 srcv0 依赖信息 |
| [64:60] | VIQ0_DST_EREG | 5 | 目标浮点寄存器号 |
| [59:53] | VIQ0_DST_VREG | 7 | 目标向量寄存器号 |
| [52:46] | VIQ0_DST_PREG | 7 | 目标物理寄存器号 |
| [45] | VIQ0_DSTE_VLD | 1 | 浮点目标有效 |
| [44] | VIQ0_DSTV_VLD | 1 | 向量目标有效 |
| [43] | VIQ0_DST_VLD | 1 | 通用目标有效 |
| [42] | VIQ0_SRCVM_VLD | 1 | srcvm 有效（使用掩码）|
| [41] | VIQ0_SRCV2_VLD | 1 | srcv2 有效 |
| [40] | VIQ0_SRCV1_VLD | 1 | srcv1 有效 |
| [39] | VIQ0_SRCV0_VLD | 1 | srcv0 有效 |
| [38:32] | VIQ0_IID | 7 | 指令 ID |
| [31:0] | VIQ0_OPCODE | 32 | 指令编码 |

> **为什么把 LCH_RDY 嵌在数据字中？** 这是跨队列依赖传递的关键机制：当 VIQ0 发射的指令在 RF launch 阶段完成，VIQ1 中等待其结果的 entry 需要立即更新就绪位。将 VIQ0/VIQ1 所有 entry 的 lch_rdy 嵌在数据字中，可以在写回时一次性广播更新，无需单独的内容相关查找（CAM）。

---

## 3. 端口说明

### 3.1 VIQ0 关键输入端口

```
ct_idu_is_viq0.v，第 112–188 行
```

| 端口 | 方向 | 含义 |
|------|------|------|
| `ctrl_viq0_create0_en` / `create1_en` | in | 控制逻辑指示本周期分配 entry0/entry1 |
| `ctrl_viq0_create0_dp_en` / `create1_dp_en` | in | 数据通路使能（有时序优化的分离版本）|
| `ctrl_viq0_rf_pop_vld` | in | RF launch 成功，弹出该 entry |
| `ctrl_viq0_rf_lch_fail_vld` | in | RF launch 失败，清除 frz 和 rdy |
| `ctrl_viq0_stall` | in | 发射队列暂停（资源冲突等）|
| `ctrl_viq0_rf_pipe6_vmla_vreg_fwd_vld[7:0]` | in | pipe6 vmla 的前向有效位，按 entry 展开 |
| `ctrl_viq0_rf_pipe7_vmla_vreg_fwd_vld[7:0]` | in | pipe7 vmla 的前向有效位，按 entry 展开 |
| `dp_viq0_create0_data[150:0]` | in | 分配 slot0 的 151-bit 指令数据 |
| `dp_viq0_bypass_data[150:0]` | in | bypass 路径的 151-bit 指令数据 |
| `dp_viq0_create_srcv0/1/2/vm_rdy_for_bypass` | in | 各源操作数在 bypass 时是否已就绪 |
| `dp_viq0_create_vdiv` | in | 新入队的指令是否为 vdiv |
| `dp_viq_dis_inst0~3_srcv2_vreg[6:0]` | in | 当前分发的 4 条指令各自的 srcv2 向量寄存器号 |
| `vfpu_idu_ex1~ex3_pipe6/7_*` | in | VFPU EX1–EX3 的唤醒广播（寄存器号+有效位）|
| `vfpu_idu_ex5_pipe6/7_wb_vreg*` | in | EX5 写回信号（最终唤醒）|
| `vfpu_idu_vdiv_busy` | in | VFPU 向量除法单元繁忙（阻止 vdiv 发射）|
| `lsu_idu_ag/dc/wb_pipe3_*` | in | LSU pipe3 向量 load 的各阶段唤醒 |

### 3.2 VIQ0 关键输出端口

| 端口 | 宽度 | 含义 |
|------|------|------|
| `viq0_xx_issue_en` | 1 | 本周期有指令可发射 |
| `viq0_xx_gateclk_issue_en` | 1 | 发射时钟使能（低功耗优化）|
| `viq0_dp_issue_entry[7:0]` | 8 | 发射的 entry 编号（one-hot）|
| `viq0_dp_issue_read_data[150:0]` | 151 | 发射指令数据 |
| `viq0_ctrl_full` | 1 | 队列满（8 项均占用）|
| `viq0_ctrl_full_updt` | 1 | 下周期将满的预测 |
| `viq0_ctrl_1_left_updt` | 1 | 下周期仅剩 1 空位的预测 |
| `viq0_ctrl_empty` | 1 | 队列为空 |
| `viq0_top_viq0_entry_cnt[3:0]` | 4 | 当前 entry 计数（0–8）|
| `viq0_viq_create0/1_entry[7:0]` | 8 | 本周期 create0/1 分配的 entry（one-hot），供 entry 子模块的年龄向量初始化 |

---

## 4. Entry 分配

### 4.1 分配指针计算

VIQ0 使用**双指针分配**：create0 从低号 entry 往高分配，create1 从高号 entry 往低分配，两者在 8 个 entry 间不重叠。

```verilog
// ct_idu_is_viq0.v，第 631–692 行
// create0：从 entry0 找到第一个空闲
if(!viq0_entry0_vld)
    viq0_entry_create0_in[7:0] = 8'b0000_0001;
else if(!viq0_entry1_vld)
    viq0_entry_create0_in[7:0] = 8'b0000_0010;
...

// create1：从 entry7 往低找第一个空闲
if(!viq0_entry7_vld)
    viq0_entry_create1_in[7:0] = 8'b1000_0000;
else if(!viq0_entry6_vld)
    viq0_entry_create1_in[7:0] = 8'b0100_0000;
...
```

**为什么 create0 从低到高，create1 从高到低？** 这样两个新指令大概率落在不同 entry，避免同时选中同一个空槽（不过即使两者指向同一位置，因为 create0 比 create1 优先级高，entry 的创建逻辑会用 `viq0_entry_create_sel` 区分，见 4.2 节）。

### 4.2 创建选择信号

```verilog
// ct_idu_is_viq0.v，第 764–767 行
// 低 4 位（entry 0~3）：用 ~create0_in 区分；高 4 位（entry 4~7）：用 create1_in 区分
assign viq0_entry_create_sel[7:4] = {4{ctrl_viq0_create1_dp_en}} & viq0_entry_create1_in[7:4];
assign viq0_entry_create_sel[3:0] = ~({4{ctrl_viq0_create0_dp_en}} & viq0_entry_create0_in[3:0]);
```

每个 entry 根据 `viq0_entry_create_sel[n]` 判断自己接收 create0 数据还是 create1 数据：

```verilog
// ct_idu_is_viq0.v，第 778–789 行（以 entry0 为例）
if(!viq0_entry_create_sel[0]) begin          // create0 目标
    viq0_entry0_create_frz   = viq0_bypass_dp_en;  // bypass 时需要 frz
    viq0_entry0_create_agevec = viq0_entry_create0_agevec[7:1]; // 年龄向量
    viq0_entry0_create_data   = dp_viq0_create0_data;
end else begin                               // create1 目标
    viq0_entry0_create_frz   = 1'b0;
    viq0_entry0_create_agevec = viq0_entry_create1_agevec[7:1];
    viq0_entry0_create_data   = dp_viq0_create1_data;
end
```

### 4.3 年龄向量初始化

年龄向量（age vector）是 7 bit 位图，用于后续的最老指令仲裁。create0 的年龄向量基线为当前 entry_vld，并去掉本周期即将弹出的 entry；create1 在 create0 的基础上再加入 create0_in，表示 create0 比 create1 更老。

```verilog
// ct_idu_is_viq0.v，第 750–757 行
assign viq0_entry_create0_agevec[7:0] = viq0_entry_vld[7:0]
    & ~({8{ctrl_viq0_rf_pop_vld}} & dp_viq0_rf_lch_entry[7:0]);

assign viq0_entry_create1_agevec[7:0] = viq0_entry_vld[7:0]
    & ~({8{ctrl_viq0_rf_pop_vld}} & dp_viq0_rf_lch_entry[7:0])
    | viq0_entry_create0_in[7:0];   // create1 比 create0 更新
```

### 4.4 entry 计数器

```verilog
// ct_idu_is_viq0.v，第 500–523 行
assign viq0_entry_cnt_create[3:0] = {3'b0,ctrl_viq0_create0_en}
                                  + {3'b0,ctrl_viq0_create1_en};
assign viq0_entry_cnt_updt_vld    = ctrl_viq0_create0_en || ctrl_viq0_rf_pop_vld;
assign viq0_entry_cnt_updt_val[3:0] = viq0_entry_cnt[3:0]
                                    + viq0_entry_cnt_create[3:0]
                                    - {3'b0,ctrl_viq0_rf_pop_vld};
```

- 每周期最多入队 2 条，出队 1 条（pop）
- flush 时计数归零
- 计数为 8 时置 `viq0_ctrl_full`

---

## 5. 唤醒机制（核心重点）

### 5.1 四路向量源依赖追踪概述

每个 VIQ0 entry 内部实例化 **4 个依赖追踪子模块**：

```
ct_idu_is_viq0_entry
├── ct_idu_dep_vreg_entry   (srcv0)   ← 普通向量依赖
├── ct_idu_dep_vreg_entry   (srcv1)   ← 普通向量依赖
├── ct_idu_dep_vreg_srcv2_entry (srcv2) ← 专用！含额外 FMA 前向逻辑
└── ct_idu_dep_vreg_entry   (srcvm)   ← 掩码寄存器（始终为 v0）依赖
```

发射条件：**四路全部就绪**

```verilog
// ct_idu_is_viq0_entry.v，第 1480–1487 行
assign x_rdy = vld
               && !frz
               && !ctrl_viq0_stall
               && !(x_read_data[VIQ0_VDIV] && vfpu_idu_vdiv_busy)
               && srcv0_rdy_for_issue
               && srcv1_rdy_for_issue
               && srcv2_rdy_for_issue
               && srcvm_rdy_for_issue;
```

> 这与整数 AIQ 的 `x_rdy = vld && !frz && src0_rdy && src1_rdy` 相比，多了 srcv2 和 srcvm 两路，以及 vdiv_busy 检测。

### 5.2 普通向量源（srcv0 / srcv1 / srcvm）唤醒

这三路均使用 `ct_idu_dep_vreg_entry`，接收来自以下来源的唤醒广播：

| 唤醒来源 | 信号前缀 | 对应阶段 |
|----------|----------|----------|
| VFPU pipe6 EX1 | `vfpu_idu_ex1_pipe6_data_vld_dupx` + `vreg` | EX1（投机唤醒）|
| VFPU pipe6 EX2 | `vfpu_idu_ex2_pipe6_data_vld_dupx` + `vreg` | EX2 |
| VFPU pipe6 EX3 | `vfpu_idu_ex3_pipe6_data_vld_dupx` + `vreg` | EX3 |
| VFPU pipe6 EX5 | `vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx` + `vreg` | EX5（写回）|
| VFPU pipe7 EX1~EX5 | 同上，pipe7 | EX1–EX5 |
| LSU pipe3 AG | `lsu_idu_ag_pipe3_vload_inst_vld` + `vreg` | AG（投机）|
| LSU pipe3 DC | `lsu_idu_dc_pipe3_vload_inst_vld_dupx` + `vreg` | DC |
| LSU pipe3 WB | `lsu_idu_wb_pipe3_wb_vreg_vld_dupx` + `vreg` | WB |

依赖追踪子模块内部做寄存器号比较。一旦某条广播的寄存器号与 entry 保存的 srcv0 寄存器号匹配且有效，就将对应 rdy 位置位。

**为什么需要多个阶段的唤醒？** VFPU 流水线深（5 级），越早唤醒下游指令，CPU 效率越高，但须避免误唤醒。LSU 有 load-use 延迟，AG 阶段唤醒属于投机，DC 阶段确认，WB 阶段兜底。

### 5.3 srcv2 专用 entry（dep_vreg_srcv2_entry）

**为什么 srcv2 需要专用子模块？** 向量 FMA 指令（如 `vfmacc.vv vd, vs1, vs2`，即 vd += vs1 * vs2）的第三源（accumulator）就是目标寄存器 vd 本身，因此：
1. srcv2 的寄存器号不从 dispatch 数据中读取，而是从**同队列中其他 entry 的目标寄存器**推断，即"哪个 entry 会写 srcv2 的值"；
2. FMA 的 srcv2 前向依赖来自 **vmla 指令本身的中间流水线结果**（EX1/EX2 的 fmla 前向），而不只是最终写回；
3. 因此 `ct_idu_dep_vreg_srcv2_entry` 额外接收 `fmla_data_vld_dupx` 信号，以及 `x_entry_vmla` 标志（本 entry 是否是 vmla 指令）和 `vfpu0/1_vreg_fwd_vld`（来自 ctrl 模块的 per-entry vmla 前向有效位）。

```verilog
// ct_idu_is_viq0_entry.v，第 899–947 行（srcv2 实例化）
ct_idu_dep_vreg_srcv2_entry  x_ct_idu_is_viq0_srcv2_entry (
  ...
  .ctrl_xx_rf_pipe6_vmla_lch_vld_dupx    (ctrl_xx_rf_pipe6_vmla_lch_vld_dupx),
  .ctrl_xx_rf_pipe7_vmla_lch_vld_dupx    (ctrl_xx_rf_pipe7_vmla_lch_vld_dupx),
  .dp_xx_rf_pipe6_dst_vreg_dupx          (dp_xx_rf_pipe6_dst_vreg_dupx),
  .dp_xx_rf_pipe7_dst_vreg_dupx          (dp_xx_rf_pipe7_dst_vreg_dupx),
  .vfpu0_vreg_fwd_vld                    (x_vfpu0_vreg_fwd_vld),   // per-entry pipe6 fwd
  .vfpu1_vreg_fwd_vld                    (x_vfpu1_vreg_fwd_vld),   // per-entry pipe7 fwd
  .vfpu_idu_ex1_pipe6_fmla_data_vld_dupx (vfpu_idu_ex1_pipe6_fmla_data_vld_dupx),
  .vfpu_idu_ex2_pipe6_fmla_data_vld_dupx (vfpu_idu_ex2_pipe6_fmla_data_vld_dupx),
  ...
  .x_entry_vmla                          (vmla),                   // 本 entry 是 vmla
  .x_create_data                         (create_srcv2_data[10:0]) // 11 bit（比 srcv0 多 1 bit）
```

srcv2 的 create 数据宽度为 11 bit（`create_srcv2_data[10:0]`），比 srcv0/v1/vm 的 10 bit 多 1 bit，是因为还要传递"srcv2 是否来自 vmla 写回"的标志。

```verilog
// ct_idu_is_viq0_entry.v，第 896–897 行
assign create_srcv2_gateclk_en = x_create_gateclk_en && x_create_data[VIQ0_SRCV2_VLD];
assign create_srcv2_data[10:0] = x_create_data[VIQ0_SRCV2_DATA:VIQ0_SRCV2_DATA-10]; // 11 bit
```

从 read_data 中读取：

```verilog
// ct_idu_is_viq0_entry.v，第 961–966 行
assign x_read_data[VIQ0_SRCV2_WB]                     = read_srcv2_data[1];
assign x_read_data[VIQ0_SRCV2_VREG:VIQ0_SRCV2_VREG-6] = read_srcv2_data[8:2];
assign srcv2_rdy_for_issue                            = read_srcv2_data[10]; // 注意是 bit[10]
// srcv0/v1/vm 的 rdy 在 read_data[9]，srcv2 的 rdy 在 read_data[10]（额外 1 bit）
```

### 5.4 lch_rdy 位图：跨 entry 前向就绪追踪

除了基础的寄存器比对唤醒，VIQ 还维护一个精细的 **lch_rdy（launch ready）位图**，记录当前 entry 相对于 VIQ0 和 VIQ1 每个 entry 的前向依赖状态。

```
当前 entry 的 read_data[134:127] = VIQ1 entry0~7 的 lch_rdy
当前 entry 的 read_data[126:119] = VIQ0 entry0~7 的 lch_rdy
```

**lch_rdy 的语义**：当某 entry 进入 RF launch（read-file launch）阶段时，若其目标寄存器与当前 entry 的 srcv2 匹配，则对应的 lch_rdy 位被置 1，表示"该依赖将在本周期或下周期通过 vmla 前向路径满足"。

每个依赖项在 entry 内实例化了 16 个 `ct_idu_is_aiq_lch_rdy_1` 子模块，分别对应 VIQ0 和 VIQ1 的 8 个 entry。每个 `lch_rdy_1` 子模块的逻辑如下：

```
// ct_idu_is_viq0_entry.v，第 1032–1113 行（srcv2 的 dis_inst 寄存器匹配）
assign dis_inst0_srcv2_match = (dst_vreg[6:0] == dp_viq_dis_inst0_srcv2_vreg[6:0]);
...
// 根据 ctrl_dp_is_dis_viq0_create0_sel 选择 4 条 dis 指令中的哪条
case(ctrl_dp_is_dis_viq0_create0_sel[1:0])
  2'd0: lch_rdy_viq0_create0_src_match = dis_inst0_srcv2_match;
  ...
```

这里的逻辑含义是：**当 VIQ0 的 create0 槽接收一条新指令时，检查该新指令的 srcv2 是否就等于当前 entry 的 dst_vreg（即当前 entry 是否是新指令的 srcv2 来源）**。如果匹配，则新指令在入队时就记录"VIQ0 某 entry 将提供其 srcv2"，一旦该 entry 进入 launch，前向就绪位就被置位。

这个机制解决了 FMA 指令链（A → B 的 srcv2 为 A 的 dst）的快速唤醒问题，无需等待 EX5 写回即可发射 B。

### 5.5 就绪清除（rdy_clr）

当 RF launch 失败（推测失败后的重放），需要清除 srcv0~srcv2/srcvm 的就绪位，防止错误依赖满足。

```verilog
// ct_idu_is_viq0_entry.v，第 774–777 行
assign srcv0_rdy_clr = x_frz_clr && dp_viq0_rf_rdy_clr[0];
assign srcv1_rdy_clr = x_frz_clr && dp_viq0_rf_rdy_clr[1];
assign srcv2_rdy_clr = x_frz_clr && dp_viq0_rf_rdy_clr[2];
assign srcvm_rdy_clr = x_frz_clr && dp_viq0_rf_rdy_clr[3];
```

`x_frz_clr = ctrl_viq0_rf_lch_fail_vld && dp_viq0_rf_lch_entry[n]`，即只有发射失败且本 entry 是发射者时才清除。

---

## 6. 向量掩码寄存器（srcvm，v0）的依赖处理

### 6.1 掩码寄存器的特殊性

RVV 规范规定，向量掩码操作数**固定为 v0 寄存器**（物理上是向量寄存器 0）。因此：

- `srcvm_vld = 1` 表示该指令使用掩码，此时 srcvm 对应的向量寄存器号固定（v0 的物理寄存器号）
- 与 srcv0/v1/v2 相同，srcvm 也通过 `ct_idu_dep_vreg_entry` 追踪写 v0 的 VFPU 指令

### 6.2 在分配时的 bypass 检测

```verilog
// ct_idu_is_viq0.v，第 584–591 行
assign viq0_create0_rdy_bypass = ctrl_viq0_create0_en
    && !cp0_idu_iq_bypass_disable
    && !ctrl_viq0_stall
    && !(dp_viq0_create_vdiv && vfpu_idu_vdiv_busy)
    && dp_viq0_create_srcv0_rdy_for_bypass
    && dp_viq0_create_srcv1_rdy_for_bypass
    && dp_viq0_create_srcv2_rdy_for_bypass
    && dp_viq0_create_srcvm_rdy_for_bypass;  // 掩码就绪也是 bypass 条件之一
```

只有**全部四个源**都在入队时就绪，且队列为空，才能走 bypass 路径直接发射，跳过写入 entry 的过程。

### 6.3 `srcvm_vld` 为 0 时的处理

当 `srcvm_vld = 0`（指令不使用掩码，如无掩码的向量加法）时，`ct_idu_dep_vreg_entry` 内部的相关比较逻辑应当永远输出就绪（ready），避免因为 v0 的写指令阻塞不使用掩码的指令。这由 `create_srcvm_gateclk_en` 控制初始化是否有效来保证：

```verilog
// ct_idu_is_viq0_entry.v，第 969 行
assign create_srcvm_gateclk_en = x_create_gateclk_en && x_create_data[VIQ0_SRCVM_VLD];
```

即只有 srcvm_vld 为 1 时，才更新掩码依赖的寄存器索引；否则 dep_vreg_entry 内部不写入有效 vreg，始终保持就绪。

---

## 7. 发射就绪与选择

### 7.1 年龄仲裁（最老指令优先）

```verilog
// ct_idu_is_viq0.v，第 1029–1051 行
// entry0 的年龄向量 agevec[6:0] 中，bit i 为 1 表示 entry(i+1) 比 entry0 更老
assign viq0_older_entry_ready[0] = |(viq0_entry0_agevec[6:0]
                                     & viq0_entry_ready[7:1]);
// 如果有更老的 entry 已就绪，entry0 的发射使能被抑制
assign viq0_entry_issue_en[7:0]  = viq0_entry_ready[7:0]
                                   & ~viq0_older_entry_ready[7:0];
```

每个 entry 的年龄向量去掉 bit 0（自身）后形成 7 bit，与其他 7 个 entry 的就绪向量做 AND，非零则表示有更老的就绪指令存在。最终发射使能 = 就绪 AND NOT（存在更老就绪）。

年龄向量在 `vld` 保持期间随着 pop 动态更新：

```verilog
// ct_idu_is_viq0_entry.v，第 637–641 行
else if(ctrl_viq0_rf_pop_vld)
    agevec[6:0] <= agevec[6:0] & ~x_pop_other_entry[6:0];
// pop 时，将弹出的 entry 从所有活跃 entry 的年龄向量中清除
```

### 7.2 发射数据选择

```verilog
// ct_idu_is_viq0.v，第 1087–1108 行
case (viq0_entry_issue_en[7:0])
  8'h01 : viq0_entry_read_data = viq0_entry0_read_data;
  8'h02 : viq0_entry_read_data = viq0_entry1_read_data;
  ...
  8'h80 : viq0_entry_read_data = viq0_entry7_read_data;
  default: viq0_entry_read_data = {VIQ0_WIDTH{1'bx}};
endcase

// bypass 时优先走 bypass 路径
assign viq0_dp_issue_read_data[VIQ0_WIDTH-1:0] =
    (viq0_create_bypass_empty)
    ? dp_viq0_bypass_data[VIQ0_WIDTH-1:0]
    : viq0_entry_read_data[VIQ0_WIDTH-1:0];
```

发射 entry 编号（one-hot）：

```verilog
// ct_idu_is_viq0.v，第 1068–1070 行
assign viq0_dp_issue_entry[7:0] = (viq0_create_bypass_empty)
    ? viq0_entry_create0_in[7:0]    // bypass 时指向假想 entry（供 pop 逻辑对齐）
    : viq0_entry_issue_en[7:0];
```

### 7.3 bypass 路径

**条件**：队列为空 + 新 create0 指令全部四源在入队时就绪 + 无 stall + 无 vdiv 忙

```verilog
// ct_idu_is_viq0.v，第 619–626、699–700 行
assign viq0_create_bypass_empty = !(viq0_entry0_vld_with_frz || ... || viq0_entry7_vld_with_frz);
assign viq0_bypass_en = viq0_create_bypass_empty && viq0_create0_rdy_bypass;
```

`vld_with_frz = vld && !frz`，即 frz（发射但尚未 launch 确认）的 entry 也会阻塞 bypass，防止结构冒险。

bypass 路径使指令不写入任何 entry 而直接发射，可消除一拍延迟。

---

## 8. 发射到 pipe6 / pipe7（VFPU 长延迟流水线）

### 8.1 VFPU 流水线级数

VIQ0 → pipe6，VIQ1 → pipe7，两路均进入 VFPU（Vector Floating-Point Unit）的 5 级执行流水线：

```
EX1 ─► EX2 ─► EX3 ─► EX4 ─► EX5（写回 vreg）
```

VIQ 在以下 VFPU 阶段收到唤醒广播：

| 阶段 | pipe6 唤醒信号 | pipe7 唤醒信号 |
|------|----------------|----------------|
| EX1（普通） | `vfpu_idu_ex1_pipe6_data_vld_dupx` | `vfpu_idu_ex1_pipe7_data_vld_dupx` |
| EX1（vmla 前向） | `vfpu_idu_ex1_pipe6_fmla_data_vld_dupx` | `vfpu_idu_ex1_pipe7_fmla_data_vld_dupx` |
| EX2（普通） | `vfpu_idu_ex2_pipe6_data_vld_dupx` | `vfpu_idu_ex2_pipe7_data_vld_dupx` |
| EX2（vmla 前向） | `vfpu_idu_ex2_pipe6_fmla_data_vld_dupx` | `vfpu_idu_ex2_pipe7_fmla_data_vld_dupx` |
| EX3 | `vfpu_idu_ex3_pipe6_data_vld_dupx` | `vfpu_idu_ex3_pipe7_data_vld_dupx` |
| EX5 写回 | `vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx` | `vfpu_idu_ex5_pipe7_wb_vreg_vld_dupx` |

注意：EX4 没有单独的唤醒广播，可能是 EX3 唤醒已足够覆盖 4–5 级延迟的场景。

### 8.2 vmla 前向的特殊处理

对于向量 FMA（vmla）类指令，由于其输出在 EX1/EX2 就可以前向给下一条 FMA 的 accumulator（srcv2），因此存在两套唤醒路径：

1. **普通 data_vld**：针对 srcv0 / srcv1 / srcvm，EX1 即可就绪
2. **fmla_data_vld**：针对 srcv2（accumulator），需要验证 vmla 类型匹配

`ctrl_viq0_rf_pipe6_vmla_vreg_fwd_vld[7:0]` 是 per-entry 的位向量，由 ctrl 模块在 RF launch 阶段根据 "本周期发射的指令是 vmla" 且 "其 dst_vreg 与等待 entry 的 srcv2_vreg 匹配" 来计算，广播给所有 8 个 entry。

```verilog
// ct_idu_is_viq0.v，第 989–1005 行
assign viq0_entry0_vfpu0_vreg_fwd_vld = ctrl_viq0_rf_pipe6_vmla_vreg_fwd_vld[0];
...
assign viq0_entry0_vfpu1_vreg_fwd_vld = ctrl_viq0_rf_pipe7_vmla_vreg_fwd_vld[0];
```

这些 `vfpu0/1_vreg_fwd_vld` 信号直接传入每个 entry 的 `dep_vreg_srcv2_entry`，使其在 RF launch 阶段就能解除 srcv2 的依赖。

### 8.3 弹出（pop）逻辑

```verilog
// ct_idu_is_viq0.v，第 1121–1142 行
// entry N 的 pop_cur_entry 表示本 entry 是被弹出者
// entry N 的 pop_other_entry[6:0] 是其他 7 个 entry 的指示位（用于更新年龄向量）
assign {viq0_entry0_pop_other_entry[6:0],
        viq0_entry0_pop_cur_entry}        = dp_viq0_rf_lch_entry[7:0];
```

`dp_viq0_rf_lch_entry[7:0]` 是 one-hot 编码，指示本周期弹出哪个 entry。

---

## 9. 向量指令的特殊属性

### 9.1 VL / VSEW / VLMUL 向量配置信息

每个 entry 在入队时保存当前向量配置状态：

```verilog
// ct_idu_is_viq0_entry.v，第 717–720 行
vlmul[1:0] <= x_create_data[VIQ0_VLMUL:VIQ0_VLMUL-1];
vsew[2:0]  <= x_create_data[VIQ0_VSEW:VIQ0_VSEW-2];
vl[7:0]    <= x_create_data[VIQ0_VL:VIQ0_VL-7];
```

**为什么 entry 要保存这些？** VFPU 执行向量指令时，VL（向量长度）、SEW（标量元素宽度）、LMUL（寄存器组因子）决定了处理的数据量和宽度。这些参数必须随指令携带到执行单元，不能共享或省略，因为 vsetvl 可能在相邻指令间修改这些参数。

### 9.2 向量指令分裂（split）

向量指令在某些情况下需要分裂执行（如 LMUL > 1 的多寄存器组操作）：

```verilog
// ct_idu_is_viq0_entry.v，第 712–713 行
split_last       <= x_create_data[VIQ0_SPLIT_LAST];   // 是否是分裂组的最后一条
split_num[6:0]   <= x_create_data[VIQ0_SPLIT_NUM:VIQ0_SPLIT_NUM-6];  // 分裂序号
```

`split_num` 为 7 bit，`split_last` 为 1 bit，合计 8 bit（位 115:108），标识该 entry 属于哪个分裂序列及位置。

### 9.3 vmla / vmla_type / vmla_short

FMA 类指令的子类型信息：

```verilog
// ct_idu_is_viq0_entry.v，第 710–716 行
vmla             <= x_create_data[VIQ0_VMLA];          // 是否是 vmla 类
vmla_type[2:0]   <= x_create_data[VIQ0_VMLA_TYPE:...]; // FMA 操作类型
vmla_short       <= x_create_data[VIQ0_VMLA_SHORT];    // 短延迟 vmla
```

`vmla` 标志决定了 srcv2 的唤醒逻辑是否走 FMA 快速前向路径。

### 9.4 vdiv（VIQ0 独有）

向量除法是 VFPU 中的长延迟操作，且不可流水。VIQ0 专门保存 `vdiv` 标志（位 135），并在就绪判断时检测 `vfpu_idu_vdiv_busy`：

```verilog
// ct_idu_is_viq0_entry.v，第 1483 行
&& !(x_read_data[VIQ0_VDIV] && vfpu_idu_vdiv_busy)
```

VIQ1 不保存 `vdiv`（其 WIDTH = 150，无此位），说明向量除法指令只被分配到 VIQ0。

### 9.5 mfvr（move from vector register）

```verilog
// ct_idu_is_viq0_entry.v，第 711 行
mfvr <= x_create_data[VIQ0_MFVR];  // 从向量寄存器搬移到通用/浮点寄存器
```

mfvr 类指令写浮点/整数目标，因此 `dste_vld`（浮点目标有效）或 `dst_vld` 可能置位。

---

## 10. VIQ1 与 VIQ0 的差异

### 10.1 关键差异对比表

| 特性 | VIQ0 | VIQ1 |
|------|------|------|
| 发射到 | pipe6 | pipe7 |
| 数据宽度 | 151 bit | 150 bit |
| `vdiv` 字段 | 有（bit 135）| 无 |
| `vmul` 字段 | 有（`VIQ0_VMUL` = 137）| 无（替换为 `VIQ1_VMUL_UNSPLIT` = 136）|
| 就绪条件 | 含 `vfpu_idu_vdiv_busy` 检测 | 不含 vdiv 检测 |
| stall 信号 | `ctrl_viq0_stall` | `ctrl_viq1_stall` |
| 接收 bypass 数据 | `dp_viq1_bypass_data[149:0]`（来自 viq0.v 中的 `dp_viq0_bypass_data`）| 实际上两者各自有 bypass |

### 10.2 VIQ1 entry 差异分析

```verilog
// ct_idu_is_viq1_entry.v，第 388–393 行
parameter VIQ1_WIDTH        = 150;
parameter VIQ1_VMUL_UNSPLIT = 136;   // 对应 VIQ0 的位 137 处是 VIQ0_VMUL（=137）
parameter VIQ1_VMLA_SHORT   = 135;   // VIQ0 的 136
// VIQ1 没有 VIQ0_VDIV（135）字段，所以 VMLA_SHORT 向下移了一位
```

VIQ1 的 `x_rdy` 不含 vdiv_busy 检测：

```verilog
// ct_idu_is_viq1_entry.v，第 1471–1477 行
assign x_rdy = vld
               && !frz
               && !ctrl_viq1_stall
               && srcv0_rdy_for_issue     // 注意：无 vdiv_busy 项
               && srcv1_rdy_for_issue
               && srcv2_rdy_for_issue
               && srcvm_rdy_for_issue;
```

### 10.3 VIQ0 与 VIQ1 的互依赖

尽管是两个独立队列，VIQ0 的每个 entry 内部同时维护对 VIQ0 **和** VIQ1 所有 entry 的 lch_rdy 信息（反之亦然）。这是因为同一条 FMA 指令链可能跨 VIQ0 和 VIQ1 分配，前面的指令在 VIQ0 发射，后面依赖其结果的在 VIQ1 等待。

```verilog
// ct_idu_is_viq0_entry.v，第 1297–1313 行（VIQ1 lch_rdy 子模块实例化）
assign viq1_entry0_create_entry[1:0] = {viq1_viq_create1_entry[0], viq1_viq_create0_entry[0]};
...
ct_idu_is_aiq_lch_rdy_1  x_ct_idu_is_aiq_lch_rdy_1_viq1_entry0 (
    .y_clk              (lch_rdy_viq1_clk),
    .y_create0_src_match(lch_rdy_viq1_create0_src_match),
    ...
```

每个 VIQ0 entry 内部有 16 个 `lch_rdy_1` 子模块（8 个追踪 VIQ0，8 个追踪 VIQ1），构成双队列间的互联唤醒网络。

---

## 11. freeze（frz）机制

### 11.1 frz 的含义与作用

`frz`（freeze）是发射队列中的一个关键概念，表示"指令已经发射（issue），但尚未完成 RF launch 确认"。

```
entry 生命周期：
create → vld=1 → (就绪) → issue_en=1 → frz=1 → RF launch
                                                  ├── 成功: frz_clr=1 → pop → vld=0
                                                  └── 失败: frz_clr=1, rdy_clr=1 → 重新就绪
```

### 11.2 frz 的状态转换

```verilog
// ct_idu_is_viq0_entry.v，第 613–625 行
always @(posedge entry_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    frz <= 1'b0;
  else if(x_create_en)
    frz <= x_create_frz;    // bypass 时 create_frz=1，直接以 frz 状态创建
  else if(x_frz_clr)
    frz <= 1'b0;            // launch 结果（成功/失败）均清除 frz
  else if(x_issue_en)
    frz <= 1'b1;            // 发射时置 frz
  else
    frz <= frz;
end
```

`x_vld_with_frz = vld && !frz`，frz 状态的 entry 不参与：
- bypass 空检测（`viq0_create_bypass_empty`），因为它占据着队列但不可见给新 bypass
- 发射仲裁（`x_rdy` 要求 `!frz`）

### 11.3 bypass 时的 frz 预置

当新指令走 bypass 路径时，队列已空但仍需为可能的 RF launch fail 做准备。此时 create0 的 entry 以 `create_frz = viq0_bypass_dp_en = 1` 进入，即一创建就处于 frz 状态。如果 launch 成功则 pop，如果失败则 frz_clr 解冻，指令回到就绪态等待重发。

---

## 12. flush 处理

### 12.1 flush 信号与处理逻辑

VIQ 响应三种 flush 信号：

| 信号 | 含义 | 作用范围 |
|------|------|----------|
| `rtu_idu_flush_fe` | 前端 flush | 清空所有 entry（vld=0）|
| `rtu_idu_flush_is` | 发射级 flush | 清空所有 entry（vld=0）|
| `rtu_yy_xx_flush` | 全局 flush | 仅清空 entry_cnt（防止计数器不一致）|

```verilog
// ct_idu_is_viq0.v，第 511–519 行（entry_cnt 清零）
else if(rtu_idu_flush_fe || rtu_idu_flush_is || rtu_yy_xx_flush)
    viq0_entry_cnt[3:0] <= 4'b0;
```

```verilog
// ct_idu_is_viq0_entry.v，第 597–601 行（单 entry vld 清零）
else if(rtu_idu_flush_fe || rtu_idu_flush_is)
    vld <= 1'b0;
```

`rtu_yy_xx_flush` 不直接清 vld，因为此时 RF launch 可能已在途，但 entry_cnt 需要归零，防止后续分配逻辑错误。

### 12.2 flush 不影响 dep_vreg_entry

依赖追踪子模块（`dep_vreg_entry`）响应 `rtu_idu_flush_fe` 和 `rtu_idu_flush_is`，将内部的寄存器号和就绪位清零。这是因为 flush 后所有向量依赖均需重新建立。

---

## 13. 时钟门控（ICG）优化

每个 entry 和子模块使用细粒度门控时钟，以降低空闲时的动态功耗：

| 门控时钟 | 使能条件 | 保护的寄存器 |
|----------|----------|-------------|
| `entry_clk` | `x_create_gateclk_en \|\| vld` | vld、frz、agevec |
| `create_clk` | `x_create_gateclk_en` | opcode、iid、VL、VSEW 等 |
| `create_vreg_clk` | `x_create_gateclk_en && dstv_vld` | dst_vreg |
| `create_ereg_clk` | `x_create_gateclk_en && dste_vld` | dst_ereg |
| `create_preg_clk` | `x_create_gateclk_en && dst_vld` | dst_preg |
| `lch_rdy_viq0_clk` | `create_gateclk_en \|\| (vld && create_gateclk_en)` | lch_rdy VIQ0 |
| `lch_rdy_viq1_clk` | 同上，VIQ1 版 | lch_rdy VIQ1 |

顶层 `cnt_clk` 在 entry_cnt 非零或有新指令入队时开启，保护计数器和 full/empty 逻辑。

---

## 14. 整体数据流 ASCII 图

```
分发（dispatch）
  │  ctrl_viq0_create0_en / create1_en
  │  dp_viq0_create0_data / create1_data [150:0]
  ▼
┌─────────────────────────────────────────────┐
│           VIQ0 队列控制（viq0.v）             │
│  entry_cnt: 0~8  full / 1_left_updt         │
│  create0_in：entry0→7 分配指针（one-hot）     │
│  create1_in：entry7→0 分配指针（one-hot）     │
│                                             │
│  entry0 ~ entry7（viq0_entry.v）             │
│  ┌─────────────────────────────────────┐    │
│  │ vld / frz / agevec[6:0]            │    │
│  │ opcode / iid / VL / VSEW / VLMUL   │    │
│  │ vmla / vdiv / split_num / split_last│    │
│  │ ┌─────────────────────────────────┐│    │
│  │ │dep_vreg_entry (srcv0)           ││    │
│  │ │dep_vreg_entry (srcv1)           ││    │
│  │ │dep_vreg_srcv2_entry (srcv2)*    ││    │
│  │ │dep_vreg_entry (srcvm/v0)        ││    │
│  │ └─────────────────────────────────┘│    │
│  │ lch_rdy_1 ×16（VIQ0×8 + VIQ1×8） │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  年龄仲裁：entry_ready & ~older_entry_ready  │
│  → entry_issue_en[7:0]（one-hot）           │
└─────────────────────────────────────────────┘
          │
          │ viq0_dp_issue_read_data [150:0]
          │ viq0_dp_issue_entry [7:0]
          ▼
      RF（Register File）读取
          │
          ▼
      pipe6 → VFPU EX1→EX2→EX3→EX4→EX5
                                      │
                                      │ vreg 写回
                                      ▼
                              唤醒广播 → 所有 VIQ0/VIQ1 entry
```

```
唤醒来源总览：
VFPU pipe6 EX1 ─────┐
VFPU pipe6 EX2 ─────┤
VFPU pipe6 EX3 ─────┤──► dep_vreg_entry（srcv0/v1/vm）
VFPU pipe6 EX5 wb ──┤    dep_vreg_srcv2_entry（srcv2）
VFPU pipe7 EX1~EX5──┤
LSU pipe3 AG ───────┤
LSU pipe3 DC ───────┤
LSU pipe3 WB ───────┘

vmla fwd（EX1/EX2）──────────────► dep_vreg_srcv2_entry（仅 srcv2）
per-entry vmla vreg fwd ─────────► dep_vreg_srcv2_entry（仅 srcv2）
```

---

## 15. 关键设计决策总结

| 决策 | 理由 |
|------|------|
| srcv2 使用专用 `dep_vreg_srcv2_entry` | FMA 的 accumulator 有特殊的 vmla 前向路径，普通 dep_vreg_entry 不支持 fmla_data_vld 和 vfpu_fwd_vld 输入 |
| lch_rdy 位图嵌入数据字 | 避免 CAM 查找，直接在新指令入队时计算依赖关系，随数据一起触发就绪位更新 |
| create0 从低到高，create1 从高到低 | 最大化两个分配指针的分散性，减少同周期两条指令争用同一 entry 的概率 |
| VIQ0 保存 vdiv 而 VIQ1 不保存 | 向量除法在设计上只走 pipe6，VIQ1 不处理 vdiv，节省 1 bit |
| bypass 通道要求四源全就绪 | 向量指令不允许投机发射时只有部分源就绪，四源全就绪是硬性约束 |
| 年龄向量动态更新（pop 时清除被弹出项） | 保证年龄向量始终反映队列的真实新旧顺序，pop 后已发射的 entry 不再影响其他 entry 的仲裁 |
| `vld_with_frz`（vld && !frz）用于 bypass 空检测 | 已发射未确认的 entry 虽然在等待 launch 结果，但也算占用资源，不能允许 bypass 穿越 |
