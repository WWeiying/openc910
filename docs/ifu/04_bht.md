# C910 IFU BHT 模块详解

> 源文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_bht.v`（1975 行）
>
> 模块名：`ct_ifu_bht`

---

## 目录

1. [模块概述](#1-模块概述)
2. [物理结构总览](#2-物理结构总览)
3. [两套 GHR 设计](#3-两套-ghr-设计)
4. [Predict Array 索引计算](#4-predict-array-索引计算)
5. [Select Array 的索引与读取](#5-select-array-的索引与读取)
6. [SRAM 读取时序](#6-sram-读取时序)
7. [预测结果输出](#7-预测结果输出)
8. [Write Buffer 详解](#8-write-buffer-详解)
9. [BHT INV 无效化机制](#9-bht-inv-无效化机制)
10. [Loop Buffer 集成](#10-loop-buffer-集成)

---

## 1. 模块概述

### 1.1 BHT 解决的问题

现代超标量处理器每个时钟周期可取多条指令。当取指流水线遇到条件分支指令（`beq`、`bne`、`blt` 等）时，在指令真正执行并得到结果之前，处理器必须猜测这条分支"是否跳转"（taken / not-taken）。

- 如果猜错，处理器必须取消错误路径上的年轻指令并把取指重定向到正确路径；实际损失取决于分支被发现的位置、当时流水线占用和恢复通路，不能从 BHT 模块单独归纳为固定“数个周期”。
- 如果猜对，前端可以继续沿预测路径推进，但整体吞吐仍可能受 I-Cache、取指边界、后端反压等其他因素限制；“方向预测正确”不等于整条流水线一定无停顿。

BHT（Branch History Table）负责提供条件分支的**方向预测状态**（taken / not-taken）。在当前 RTL 中，`ct_ifu_ipdp` 选择 2-bit 预测计数器并取其最高位作为方向；目标候选由 BTB 等目标预测结构提供，后续控制逻辑还要结合预解码边界、命中 way 和控制流类型形成真正的取指重定向。因此“BHT 只管方向、BTB 只管目标”适合作为职责概括，不代表二者在最终控制方程中彼此独立。

### 1.2 最基础方案：2-bit 饱和计数器

最简单的 BHT 方案：用 PC 的低位索引一张表，每个表项是一个 2-bit 饱和计数器（Saturating Counter）：

| 状态值 | 含义 | 预测 |
|--------|------|------|
| `2'b00` | Strongly Not-Taken | not-taken |
| `2'b01` | Weakly Not-Taken | not-taken |
| `2'b10` | Weakly Taken | taken |
| `2'b11` | Strongly Taken | taken |

每次分支实际执行后，taken 则加 1（最大 `11`），not-taken 则减 1（最小 `00`）。

**问题一：别名冲突（Aliasing）**

如果两条不同的分支指令映射到同一个表项，它们会相互污染，导致预测准确率下降。解决方案是引入 **GHR（Global History Register）** 做哈希：用"最近若干次分支的跳转历史"与 PC 异或后再索引表，让不同 PC 在不同历史下尽量落到不同表项。

**问题二：偏置分支（Biased Branch）**

有些分支几乎总是 taken 或几乎总是 not-taken（例如循环的退出判断）。另一些分支则几乎取决于历史（例如 if-else 中高度相关的判断）。普通 GHR+2-bit 计数器无法区分这两类，当历史"偶然"进入错误状态后，需要两次反向执行才能切换预测方向。

### 1.3 Bi-Mode 算法原理

C910 采用 **Bi-Mode BHT**，这是一种专门解决偏置分支别名问题的算法，出自 Lee 等人 1997 年的论文。

核心思路：**把分支按"倾向"分成两类，分开存储**。

Bi-Mode 有三个表：

1. **Taken 预测表（Taken Predictor）**：专门服务于"倾向于跳转"的分支。
2. **Not-Taken 预测表（Not-Taken Predictor）**：专门服务于"倾向于不跳转"的分支。
3. **选择表（Select Array / Choice Predictor）**：决定当前分支应该查哪个预测表。

预测过程：
1. 用 PC 索引 Select Array，得到 2-bit 计数器值。
2. 若该值的最高位为 `1`（Taken 偏置），查 Taken 预测表作为最终预测。
3. 若该值的最高位为 `0`（Not-Taken 偏置），查 Not-Taken 预测表作为最终预测。

**为什么 Bi-Mode 比普通方案好？**

普通 GHR 索引下，一条强 taken 偏置分支与一条强 not-taken 偏置分支可能反复训练同一个计数器。Bi-Mode 让 Select Array 把它们引向不同的**逻辑方向侧**，从而减少相反偏置在同一个方向计数器上的直接对冲。C910 的两侧并不是两个独立 SRAM：每个 Predict Array 行把 16 个 Taken 与 16 个 Not-Taken 计数器交错放在同一个 64-bit SRAM 中。即使分到不同方向侧，同一侧内部仍可能发生别名，Select Array 本身也会别名，所以“彼此不干扰”或“冲突无害”只能作为算法动机，不能当成所有地址模式下的硬件保证。

当前 RTL 的更新规则需要比“按实际方向更新对应方向表”描述得更精确：

- `cur_sel_rst[1]` 决定本次更新 Taken 侧还是 Not-Taken 侧，因而 **Predict Array 更新的是预测时由 Select Array 选中的那一侧**。
- 被选中的 2-bit 计数器按实际 taken/not-taken 做饱和加减；已经处于同方向饱和值时跳过该侧写入。
- Select Array 是否更新由 `sel_array_check_updt_vld` 的四组排除条件决定。实际结果与当前选择偏置一致时，选择计数器继续向该偏置的饱和端训练；若实际结果与偏置相反但所选方向表仍预测正确，则不改变选择计数器；若这种反偏置结果造成 change-flow/mispredict，则选择计数器向相反方向移动。

这比“只有选择方向与实际结果相反时更新”多了一层条件：**选择表关注的不只是实际方向，还区分所选方向表是否已经正确处理了反偏置样本**。第 8.6 节按当前布尔方程逐项展开。

**本文的 PC 位号约定**：BHT 接收的 `[38:0]` PC 是半字地址，RTL
`rtl_vpc[38:0]` 保存架构字节地址 `byte_vpc[39:1]`。因此 RTL 位
`rtl_vpc[n]` 对应字节地址位 `byte_vpc[n+1]`；与反汇编地址比较时应使用
`{rtl_vpc, 1'b0}`。

---

## 2. 物理结构总览

```verilog
// 行 324-330（文件头部注释）
//CK860 Use Bi-Mode BHT
//Total Size is 64K Bits
//2*Pre_Array + 1*Sel_Array
//2*Pre_Array = Taken_pre_array + Not_Taken_pre_array
//  1KEntry * 32Bits * 2Array  ----  Use one Memory
//1*Sel_Array
//  128Entry * 16Bits
```

### 2.1 Predict Array（预测表）

| 属性 | 说明 |
|------|------|
| 深度 | 1K 项（10-bit 索引） |
| 位宽 | 64 bit（16 个 Taken 计数器 + 16 个 Not-Taken 计数器，每个 2 bit） |
| 逻辑组成 | Taken 表 32-bit + Not-Taken 表 32-bit，合并在同一个 SRAM |
| 总容量 | 1024 × 64 = 65536 bit = **64 Kbit** |

数据布局（SRAM 64 bit 如何拆分 Taken / Not-Taken）：

```verilog
// 行 776-808
assign bht_pre_taken_data[31:0]  = {bht_pre_data_out[61:60],
                                    bht_pre_data_out[57:56],
                                    ...
                                    bht_pre_data_out[ 1: 0]};   // 偶数对 bit[1:0]

assign bht_pre_ntaken_data[31:0] = {bht_pre_data_out[63:62],
                                    bht_pre_data_out[59:58],
                                    ...
                                    bht_pre_data_out[ 3: 2]};   // 奇数对 bit[3:2]
```

每 4 bit 中，低 2 bit 是一个 Taken 计数器，高 2 bit 是一个 Not-Taken
计数器，交错存储。一次 SRAM 读操作同时得到 **16 个 Taken 和 16 个
Not-Taken 计数器**；随后由 PC 低位与 GHR 低位的哈希结果选择其中一路。

### 2.2 Select Array（选择表）

| 属性 | 说明 |
|------|------|
| 深度 | 128 项（7-bit 索引，对应内部 `rtl_vpc[12:6]`，即字节 PC `[13:7]`） |
| 位宽 | 16 bit（8 个 2-bit 计数器） |
| 总容量 | 128 × 16 = 2048 bit = **2 Kbit** |

每项 16 bit 存储 8 个 2-bit 选择计数器。行索引使用内部
`rtl_vpc[12:6]`，行内选择使用 `rtl_vpc[5:3]`；二者合起来就是
`rtl_vpc[12:3]`，对应字节 PC `[13:4]`，所以每个计数器覆盖一个
16 字节取指块。一个块中若有多条条件分支，它们共享该选择计数器。

### 2.3 总容量

| 结构 | 容量 |
|------|------|
| Predict Array | 64 Kbit |
| Select Array | 2 Kbit |
| **合计** | **66 Kbit** |

实例化接口：

```verilog
// 行 1942-1969
ct_ifu_bht_pre_array  x_ct_ifu_bht_pre_array ( ... );  // 64K bit SRAM
ct_ifu_bht_sel_array  x_ct_ifu_bht_sel_array ( ... );  // 2K bit SRAM
```

---

## 3. 两套 GHR 设计

### 3.1 为什么需要两套 GHR？

GHR（Global History Register）记录最近 N 条分支的跳转方向（1=taken, 0=not-taken），用于区分"相同 PC 在不同历史语境下"的预测。

**根本矛盾**：分支预测必须在取指阶段（IF/pcgen）就做出，而分支实际执行和确认（retire）发生在若干周期之后。在分支被确认之前，处理器已经在投机地取了很多后续指令，GHR 中记录的都是还未被验证的投机结果。

如果只维护一套 GHR：
- 太"冒进"：完全跟随投机状态，一旦发生误预测或异常，GHR 进入错误状态，恢复困难。
- 太"保守"：只跟退休状态，则取指阶段无法使用最新的分支历史，预测准确率低。

C910 的解决方案：**同时维护两套 GHR**。

| 寄存器 | 全称 | 用途 | 更新时机 |
|--------|------|------|---------|
| `vghr_reg[21:0]` | Virtual GHR / Speculative GHR | 取指预测时使用 | 每发现一条条件分支就立即更新（投机） |
| `rtughr_reg[21:0]` | RTU GHR / Retire GHR | 已退休条件分支历史参考，RTU flush 时用于恢复 | 接收 retire0/1/2 三个退休槽位的条件分支有效位与实际方向 |

### 3.2 RTUGHR 更新逻辑

```verilog
// 行 596-639
assign rtughr_updt_vld = cp0_ifu_bht_en && rtu_con_br_vld;
assign rtu_con_br_vld  = rtu_ifu_retire0_condbr ||
                         rtu_ifu_retire1_condbr  ||
                         rtu_ifu_retire2_condbr;
```

此接口显式提供 retire0、retire1、retire2 三个退休槽位，所以 BHT 能在一次更新中吸收 0～3 条已退休条件分支。这个事实证明的是**该接口和 RTUGHR 更新逻辑具有三个退休反馈槽位**，不能据此单独推出前端发射宽度，也不能把“退休槽位”写成“发射槽位”。`rtughr_pre` 通过 8 种 case 组合处理这三个槽位：

```verilog
// 行 622-638
case({rtu_ifu_retire0_condbr, rtu_ifu_retire1_condbr, rtu_ifu_retire2_condbr})
  3'b000  : rtughr_pre[21:0] = rtughr_reg[21:0];   // 无分支，不变
  3'b001  : rtughr_pre[21:0] = {rtughr_reg[20:0], rtu_ifu_retire2_condbr_taken};
  3'b010  : rtughr_pre[21:0] = {rtughr_reg[20:0], rtu_ifu_retire1_condbr_taken};
  3'b100  : rtughr_pre[21:0] = {rtughr_reg[20:0], rtu_ifu_retire0_condbr_taken};
  3'b101  : rtughr_pre[21:0] = {rtughr_reg[19:0], rtu_ifu_retire0_condbr_taken,
                                                   rtu_ifu_retire2_condbr_taken};
  3'b110  : rtughr_pre[21:0] = {rtughr_reg[19:0], rtu_ifu_retire0_condbr_taken,
                                                   rtu_ifu_retire1_condbr_taken};
  3'b011  : rtughr_pre[21:0] = {rtughr_reg[19:0], rtu_ifu_retire1_condbr_taken,
                                                   rtu_ifu_retire2_condbr_taken};
  3'b111  : rtughr_pre[21:0] = {rtughr_reg[18:0], rtu_ifu_retire0_condbr_taken,
                                                   rtu_ifu_retire1_condbr_taken,
                                                   rtu_ifu_retire2_condbr_taken};
endcase
```

**8 种情况详解：**

| case 值 | 含义 | GHR 移位量 | 最低位填入 |
|---------|------|-----------|----------|
| `3'b000` | 退休指令中无条件分支 | 0 | — |
| `3'b001` | 仅 retire2 是条件分支 | 左移 1 | retire2 的 taken |
| `3'b010` | 仅 retire1 是条件分支 | 左移 1 | retire1 的 taken |
| `3'b100` | 仅 retire0 是条件分支 | 左移 1 | retire0 的 taken |
| `3'b011` | retire1 和 retire2 是条件分支 | 左移 2 | retire1_taken, retire2_taken |
| `3'b101` | retire0 和 retire2 是条件分支 | 左移 2 | retire0_taken, retire2_taken |
| `3'b110` | retire0 和 retire1 是条件分支 | 左移 2 | retire0_taken, retire1_taken |
| `3'b111` | 全部 3 条都是条件分支 | 左移 3 | 三者 taken 值 |

GHR 通过 `{旧值低位, 新结果}` 形式向高位方向丢弃旧历史，并把最新结果放到 bit0。多槽位同时有效时，拼接顺序是 retire0、retire1、retire2；在 RTU 槽位按程序顺序由老到新排列的接口约定下，retire2 的结果最终位于 bit0，因而是三者中最新的历史。文档应把“最新在低位”建立在该槽位顺序约定上，而不是只根据信号编号猜测。

**注意**：`3'b101`（retire0 和 retire2 有效，retire1 无效）这种情况看起来奇怪，但在程序里完全可能：retire1 可能是非条件分支指令、load 指令或其他非条件分支指令。

### 3.3 VGHR 更新优先级

`vghr_reg` 的更新采用严格的优先级顺序（高优先级在前）：

```verilog
// 行 653-671
always @(posedge bht_ghr_updt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    vghr_reg[21:0] <= 22'b0;
  else if(bht_inv_on_reg)                        // 优先级 1：BHT 无效化
    vghr_reg[21:0] <= 22'b0;
  else if(rtu_ifu_flush && cp0_ifu_bht_en)       // 优先级 2：RTU flush，恢复精确值
    vghr_reg[21:0] <= rtughr_reg[21:0];
  else if(ghr_updt_vld && iu_ifu_bht_check_vld)  // 优先级 3a：BJU 误预测（有check）
    vghr_reg[21:0] <= {bju_ghr[20:0], iu_ifu_bht_condbr_taken};
  else if(ghr_updt_vld && !iu_ifu_bht_check_vld) // 优先级 3b：BJU 误预测（无check）
    vghr_reg[21:0] <= bju_ghr[21:0];
  else if(vghr_lbuf_updt_vld)                    // 优先级 4：Loop Buffer 分支
    vghr_reg[21:0] <= {vghr_reg[20:0], lbuf_bht_con_br_taken};
  else if(vghr_ip_updt_vld && !lbuf_bht_active_state) // 优先级 5：IP 级正常分支
    vghr_reg[21:0] <= {vghr_reg[20:0], ipctrl_bht_con_br_taken};
  else
    vghr_reg[21:0] <= vghr_reg[21:0];            // 保持不变
end
```

| 优先级 | 触发条件 | 动作 | 原因 |
|--------|---------|------|------|
| 1 | `bht_inv_on_reg`（BHT 无效化进行中） | 将 VGHR 清零 | 当前寄存器的最高优先级分支明确写零 |
| 2 | `rtu_ifu_flush`（RTU 冲刷流水线） | 恢复为 `rtughr_reg` | RTUGHR 是本模块中由已退休条件分支形成的历史状态 |
| 3 | `ghr_updt_vld`（`cp0_ifu_bht_en && iu_ifu_chgflw_vld`） | 恢复为 `bju_ghr` 并视 check 状态追加实际方向 | IU/BJU 返回历史快照和本次检查信息，供投机历史重建 |
| 4 | `vghr_lbuf_updt_vld`（Loop Buffer 中有分支） | 移位追加 lbuf 分支方向 | lbuf 激活时取指由 lbuf 控制，需从 lbuf 得知分支结果 |
| 5 | `vghr_ip_updt_vld`（IP 级发现条件分支） | 移位追加 IP 预测方向 | 正常流水线推进，投机更新 GHR |

**优先级 3 的两种子情况**：

当 IU/BJU 发出 change-flow（`iu_ifu_chgflw_vld` 为真，通常对应需要纠正预测路径）时，同周期可能还有 BHT 检查有效（`iu_ifu_bht_check_vld`）。
- `iu_ifu_bht_check_vld` 为真：RTL 形成 `{bju_ghr[20:0], iu_ifu_bht_condbr_taken}`，即在返回的快照之后追加本次已确认方向。
- `iu_ifu_bht_check_vld` 为假：RTL 直接写回 `bju_ghr[21:0]`，不追加方向。该方程说明此类 change-flow 返回包已经给出需要恢复到的完整历史边界；更细的“哪条分支已包含”语义还依赖 IU 对 `iu_ifu_chk_idx` 的生成协议。

### 3.4 bju_ghr 的来源

```verilog
// 行 1933-1936
assign bju_mispred       = iu_ifu_chgflw_vld;
assign bju_pred_rst[1:0] = {iu_ifu_bht_pred, iu_ifu_chk_idx[24]};
assign bju_sel_rst[1:0]  = iu_ifu_chk_idx[23:22];
assign bju_ghr[21:0]     = iu_ifu_chk_idx[21:0];
```

`iu_ifu_chk_idx[24:0]` 是 IU 在分支指令进入流水线时记录并随指令一路传递的"检查包"。当 BJU 检测到误预测时，把这个包传回 IFU，其中包含了当时的 GHR 快照（`bju_ghr`）以及 Sel Array 和 Pred Array 的旧读出值（`bju_sel_rst`、`bju_pred_rst`），用于回滚 GHR 和更新 BHT 表项。

### 3.5 与 Ind BTB 的接口

```verilog
// 行 1897-1898
assign bht_ind_btb_rtu_ghr[7:0]  = rtughr_reg[7:0];
assign bht_ind_btb_vghr[7:0]     = vghr_reg[7:0];
```

间接分支 BTB（Indirect BTB）也使用 GHR 的低 8 位来区分同一个间接跳转在不同历史语境下的目标地址，因此 BHT 对外输出这两个 GHR 的低 8 位。

---

## 4. Predict Array 索引计算

### 4.1 GHR 折叠（Folding）原理

Predict Array 有 1K 行，需要 10-bit 行索引。当前 RTL 针对不同流水线恢复场景，从 22-bit GHR 中选取一个连续的 18-bit 窗口：其中 4 位直接作为索引高位，另两组 6 位异或成索引低位。这属于历史折叠（history folding）形式，但并不是每次都把全部 22 位混入 10 位索引。

```
折叠索引 = { GHR[N:N-3],  GHR[N-4:N-9] ^ GHR[N+8:N+3] }
           |-- 高4位 --|  |-------------- 低6位 -----------|
```

以 ipctrl 正常取指为例（使用 `vghr_reg`）：

```verilog
// 行 477
bht_pred_array_rd_index = {vghr_reg[11:8], {vghr_reg[7:2] ^ vghr_reg[19:14]}};
```

- 高 4 位：直接取 `vghr_reg[11:8]`
- 低 6 位：`vghr_reg[7:2]` 与 `vghr_reg[19:14]` 异或

正常 IP 条件分支读取使用 GHR `[19:2]`：`[11:8]` 直接进入索引高 4 位，`[7:2]` 与 `[19:14]` 异或形成低 6 位；`[13:12]` 没有参与这一条方程，`[21:20]` 和 `[1:0]` 也不在正常读取索引中。其他恢复场景平移这个 18-bit 窗口，以对齐各自所处的历史状态。

**为什么要折叠而不是直接截取？**

与只截取同一窗口中的 10 位相比，异或可让该窗口内额外的历史位影响索引，因此有机会减少某些历史模式的别名；但异或映射本身仍是多对一，也可能产生新的冲突。当前正常方程只使用 22 位 GHR 中的 18 位，而且 18 位压缩成 10 位必然存在别名，所以不能写成“混合全部历史”或“最大化区分能力”。准确率收益需要用工作负载统计或与替代索引方案的对照实验验证。

### 4.2 不同场景下的索引

```verilog
// 行 468-478
if(rtu_ifu_flush)
  bht_pred_array_rd_index = {rtughr_reg[13:10], {rtughr_reg[9:4]  ^ rtughr_reg[21:16]}};
else if(bju_mispred && !iu_ifu_bht_check_vld)
  bht_pred_array_rd_index = {bju_ghr[13:10],   {bju_ghr[9:4]     ^ bju_ghr[21:16]}};
else if(bju_mispred && iu_ifu_bht_check_vld)
  bht_pred_array_rd_index = {bju_ghr[12:9],    {bju_ghr[8:3]     ^ bju_ghr[20:15]}};
else if(after_bju_mispred || after_rtu_ifu_flush)
  bht_pred_array_rd_index = {vghr_reg[12:9],   {vghr_reg[8:3]    ^ vghr_reg[20:15]}};
else  // ipctrl_bht_con_br_vld（正常预测）
  bht_pred_array_rd_index = {vghr_reg[11:8],   {vghr_reg[7:2]    ^ vghr_reg[19:14]}};
```

| 场景 | 使用的 GHR | 折叠位段 | 原因 |
|------|-----------|---------|------|
| RTU flush 当周期 | `rtughr_reg` | `[13:10]` / `[9:4]^[21:16]` | 直接使用已退休历史，并选择窗口 `[21:4]` |
| BJU change-flow 当周期（无 check） | `bju_ghr` | `[13:10]` / `[9:4]^[21:16]` | 使用返回快照的窗口 `[21:4]` |
| BJU change-flow 当周期（有 check） | `bju_ghr` | `[12:9]` / `[8:3]^[20:15]` | 使用返回快照向低位平移一位的窗口 `[20:3]` |
| change-flow/flush 后一周期 | `vghr_reg` | `[12:9]` / `[8:3]^[20:15]` | 使用恢复后 VGHR 的窗口 `[20:3]` |
| 正常预测 | `vghr_reg` | `[11:8]` / `[7:2]^[19:14]` | 使用正常投机 VGHR 的窗口 `[19:2]` |

这些窗口按场景逐级平移，说明设计在补偿“快照所处历史边界”和“SRAM 结果被消费时的历史边界”差异。RTL 可以证明各场景确实选择了上述位段，却不能仅凭位段差一位就断言某一状态固定“慢两个分支”或给出固定 SRAM 周期解释；要完整证明这种对齐，需要同时追踪 VGHR 更新、IF/IP pipedown、change-flow 返回包和读使能时序。调试时应检查的是：同一分支用于更新的 `bju_ghr`、读取索引和 `pre_vghr_offset` 是否保持同一历史语义。

---

## 5. Select Array 的索引与读取

### 5.1 索引方式

```verilog
// 行 554-555
else if(bht_sel_array_rd)
  bht_sel_array_index[6:0] = pcgen_bht_pcindex[9:3];
```

Select Array 用内部虚拟 PC 的 `rtl_vpc[12:6]`（即
`pcgen_bht_pcindex[9:3]`，对应字节 PC `[13:7]`）索引，共 128 项。这里直接
用 PC 而不用 GHR 哈希，原因是 Select Array 的作用是记录该 PC 区域的偏置
倾向，而不是记录特定历史下的预测状态。

`pcgen_bht_pcindex[9:0]` 来自 `pcgen` 阶段，对应内部
`rtl_vpc[12:3]`，也就是字节 PC `[13:4]`，粒度为 16 字节。其高 7 位
`[9:3]` 选择 SRAM 行，低 3 位 `[2:0]`（内部 `rtl_vpc[5:3]`，即字节
PC `[6:4]`）在读出后从 16-bit 数据中选择一个 2-bit 计数器。

### 5.2 数据组织

每个 Select Array 表项 16 bit，对应 8 个 2-bit 计数器，编号 0～7，分别
对应内部 `rtl_vpc[5:3] = 000`～`111`，也就是一个 128 字节地址区域内的
8 个 16 字节取指块。

```
bit[1:0]  → 对应 rtl_vpc[5:3]=000 的取指块的 Select 计数器
bit[3:2]  → 对应 rtl_vpc[5:3]=001
...
bit[15:14] → 对应 rtl_vpc[5:3]=111
```

### 5.3 if_pc_onehot 的作用

```verilog
// 行 729-743
always @(pcgen_bht_ifpc[5:3])
begin
case(pcgen_bht_ifpc[5:3])
  3'b000 : if_pc_onehot[7:0] = 8'b0000_0001;
  3'b001 : if_pc_onehot[7:0] = 8'b0000_0010;
  ...
  3'b111 : if_pc_onehot[7:0] = 8'b1000_0000;
endcase
end
```

`if_pc_onehot` 是 `pcgen_bht_ifpc[5:3]`（即内部 `rtl_vpc[5:3]`、字节
PC `[6:4]`）的 one-hot 展开，作为选通信号，从 16-bit Select Array 读出值中
选出对应的 2-bit 计数器：

```verilog
// 行 744-751
assign sel_array_val_cur[1:0] =
  ({2{if_pc_onehot[0]}} & bht_sel_data[ 1: 0]) |
  ({2{if_pc_onehot[1]}} & bht_sel_data[ 3: 2]) |
  ...
  ({2{if_pc_onehot[7]}} & bht_sel_data[15:14]);
```

这是一个由 8 组“2-bit 数据与 one-hot 位相与”再按位 OR 构成的 8:1 选择网络。RTL 没有显式优先级链；其综合后的门级结构、延迟是否优于其他写法，仍需由综合映射与 STA 结果确认。

### 5.4 sel_array_val_cur 的选择逻辑

```verilog
// 行 755-761
assign memory_sel_array_result[1:0] = (ipctrl_bht_more_br || ipdp_bht_h0_con_br)
                                    ? sel_array_val_flop[1:0]
                                    : sel_array_val_cur[1:0];
// wr_buf bypass select
assign sel_array_val[1:0]           = (wr_buf_hit)
                                    ? wr_buf_sel_array_result[1:0]
                                    : memory_sel_array_result[1:0];
```

最终使用的 Select Array 结果有三层选择：

1. **Write Buffer 的 Select 结果旁路**（最高优先级）：若当前读上下文与某个待写 entry 的 GHR/PC 键匹配，使用该 entry 重新计算出的 Select 计数器值覆盖 `memory_sel_array_result`。这条旁路不替换 Predict Array 两侧的输出。

2. **more_br / h0_con_br 选择保存值**：若 `ipctrl_bht_more_br` 或 `ipdp_bht_h0_con_br` 为 1，使用 `sel_array_val_flop`。该方程表明这些场景沿用前一拍已经对齐的 Select 结果；“已经消耗哪一条分支”等更细语义应结合 IP 控制状态解释。

3. **正常值**：使用当前 SRAM 读出 + one-hot 选择后的 `sel_array_val_cur`。

---

## 6. SRAM 读取时序

### 6.1 两个 SRAM 的读触发时机不同

| SRAM | 读触发阶段 | 触发信号 | 说明 |
|------|-----------|---------|------|
| Select Array | pcgen 阶段（与取指同步） | `pcgen_bht_chgflw` 或 `pcgen_bht_seq_read` | PC 生成后立刻读 Sel Array，为 IF 阶段准备好方向偏置 |
| Predict Array | IP 阶段（由 ipctrl 触发） | `ipctrl_bht_con_br_vld` 等 | IP 阶段才知道哪条指令是条件分支，才真正触发 Pred Array 读 |

这种错拍组织让较早可得的 PC 偏置信息和较晚确认的条件分支信息分别驱动两个独立 SRAM。它用于对齐流水线数据，并不意味着两个 SRAM 之间原本会发生同端口冲突；真正需要仲裁的是**每个单端口 SRAM 自身**的读与写。

### 6.2 pre_rd_flop：Predict Array 读锁存

```verilog
// 行 860-871
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)
    pre_rd_flop <= 1'b0;
  else if(bht_inv_on_reg)
    pre_rd_flop <= 1'b0;
  else if(bht_pred_array_rd)
    pre_rd_flop <= 1'b1;
  else
    pre_rd_flop <= 1'b0;
end
```

`pre_rd_flop` 是 `bht_pred_array_rd` 的单周期延迟版本。当它为 1 时，表示"上一周期发出了 Pred Array 读操作，本周期 SRAM 的 dout 是有效的读出数据"。

### 6.3 btb_rd_flop / sel_rd_flop：Sel Array 读锁存

```verilog
// 行 712-722
always @(posedge forever_cpuclk or negedge cpurst_b)
begin
  if(!cpurst_b)
    sel_rd_flop <= 1'b0;
  else if(bht_inv_on_reg)
    sel_rd_flop <= 1'b0;
  else if(bht_sel_array_rd && !ifctrl_bht_stall)  // 注意：stall 时不产生 flop
    sel_rd_flop <= 1'b1;
  else
    sel_rd_flop <= 1'b0;
end
```

`sel_rd_flop` 同理：上周期读了 Sel Array 时置 1，本周期 SRAM dout 有效。

注意：当 `ifctrl_bht_stall` 为高时，`sel_rd_flop` 不置 1。RTL 能确认的是本次读请求不会被标记为可供后续选择的新读结果；地址是否保持、何时重发由 pcgen/ifctrl 的 stall 与 seq_read 协议共同决定，不能只从这一寄存器推断“下一周期一定重新发”。

### 6.4 读出数据的选择

```verilog
// 行 725-727
assign bht_sel_data[15:0] = (sel_rd_flop)
                          ? bht_sel_data_out[15:0]   // 本周期 SRAM dout 新鲜数据
                          : bht_sel_data_reg[15:0];  // 上周期保存的数据
```

`bht_sel_data_reg` 是用一个带门控时钟的触发器保存的 SRAM dout 值：

```verilog
// 行 699-708
always @(posedge sel_reg_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    bht_sel_data_reg[15:0] <= 16'b0;
  else if(bht_inv_on_reg)
    bht_sel_data_reg[15:0] <= 16'b0;
  else if(sel_rd_flop)
    bht_sel_data_reg[15:0] <= bht_sel_data_out[15:0];
  else
    bht_sel_data_reg[15:0] <= bht_sel_data_reg[15:0];
end
```

这样设计的原因：**SRAM 在写操作发生时，dout 的值可能改变（被新写入的数据覆盖）**。如果一个周期刚完成读操作，下一周期就有写操作，而此时下游逻辑还需要用读出的数据（例如流水线要把 Sel Array 结果传到 IP 级），此时必须用寄存器保存读出值。

`sel_rd_flop=1` 时，直接用 dout（因为 SRAM 刚读完，dout 还是有效的读出值）；`sel_rd_flop=0` 时，使用保存值。

Predict Array 同理（`pre_rd_flop`、`pre_taken_reg`、`pre_ntaken_reg`）。

### 6.5 管道时序图

```
事件顺序（概念图，不代表固定绝对周期）：

pcgen 形成 PC/seq_read 或 chgflw
    → Select Array 接收读地址
    → sel_rd_flop 标记相应读出有效，必要时保存到 bht_sel_data_reg
    → IP 控制确认条件分支并触发 Predict Array 读取
    → pre_rd_flop 标记相应读出有效，必要时保存到 pre_*_reg
    → bht_pipe_clk 条件满足时把预测侧数据、offset 和 VGHR 送入 IP 数据通路
```

---

## 7. 预测结果输出

BHT 向 IP 数据路径（ipdp）输出以下信号，IP 级使用这些信号做最终分支方向预测：

```verilog
// 端口声明（行 111-118）
output [31:0] bht_ipdp_pre_array_data_taken;  // Taken 侧 16 个 2-bit 计数器
output [31:0] bht_ipdp_pre_array_data_ntake;  // Not-Taken 侧 16 个 2-bit 计数器
output [15:0] bht_ipdp_pre_offset_onehot;     // 16-bit one-hot，指向哪个计数器
output  [1:0] bht_ipdp_sel_array_result;      // Sel Array 2-bit 结果（偏置方向）
output [21:0] bht_ipdp_vghr;                  // 当前 VGHR 快照
```

### 7.1 IP 级如何用这些数据做最终预测

IP 级（`ct_ifu_ipdp` 模块）拿到上述数据后的处理逻辑（位于 ipdp 模块，非本文件）大致如下：

1. 用 `bht_ipdp_pre_offset_onehot[15:0]` 从 `bht_ipdp_pre_array_data_taken[31:0]` 中选出目标 2-bit Taken 计数器。
2. 用同一个 one-hot 从 `bht_ipdp_pre_array_data_ntake[31:0]` 中选出 Not-Taken 计数器。
3. 查看 `bht_ipdp_sel_array_result[1]`（最高位）：若为 1，用 Taken 计数器的 MSB 作为预测结果；若为 0，用 Not-Taken 计数器的 MSB 作为预测结果。
4. 将此预测结果以及 `bht_ipdp_vghr` 随指令一起流水。

### 7.2 pre_offset_onehot 的计算

```verilog
// 行 1413-1416
assign pre_offset_ip_0[3:0] = ipdp_bht_vpc[6:3]   ^ pre_vghr_offset_0[3:0];
assign pre_offset_ip_1[3:0] = ipdp_bht_vpc[6:3]   ^ pre_vghr_offset_1[3:0];
assign pre_offset_if_0[3:0] = pcgen_bht_ifpc[6:3] ^ pre_vghr_offset_0[3:0];
assign pre_offset_if_1[3:0] = pcgen_bht_ifpc[6:3] ^ pre_vghr_offset_1[3:0];
```

Predict Array 每个表项存 32 个 2-bit 计数器，即 Taken 和 Not-Taken 两组各
16 个。要从选定的一组中选出当前分支对应的计数器，需要计算 4 位哈希偏移：

```
pre_offset = rtl_vpc[6:3] ^ vghr[3:0]
           = byte_vpc[7:4] ^ vghr[3:0]
```

这里将内部 PC `[6:3]`（即字节 PC `[7:4]`）与 GHR 的低 4 位异或，得到
0～15 的偏移，再转为 16-bit one-hot。该 one-hot 是**哈希后的计数器编号**，
不是分支在 cache line 中的物理位置；引入 PC 低位是为了减少同一 Predict Array
行内的别名冲突。

有 4 套 pre_offset（ip_0 / ip_1 / if_0 / if_1）：

| 后缀 | PC 来源 | GHR offset 来源 | 含义 |
|------|---------|----------------|------|
| `ip_0` | `ipdp_bht_vpc`（IP 级 vpc） | `pre_vghr_offset_0`（IP 级无分支时 GHR） | IP 阶段，当前分支不在前一条分支之后 |
| `ip_1` | `ipdp_bht_vpc` | `pre_vghr_offset_1`（IP 级有分支时 GHR） | IP 阶段，本条分支紧跟在前一条分支之后 |
| `if_0` | `pcgen_bht_ifpc`（IF 级 pc） | `pre_vghr_offset_0` | IF 阶段对应的偏移 |
| `if_1` | `pcgen_bht_ifpc` | `pre_vghr_offset_1` | IF 阶段 + 有分支时的偏移 |

最终选择逻辑：

```verilog
// 行 1467-1476
assign pre_offset_onehot[15:0]    = (ipctrl_bht_more_br || ipdp_bht_h0_con_br)
                                    ? pre_offset_onehot_ip[15:0]
                                    : pre_offset_onehot_if[15:0];

assign pre_offset_onehot_ip[15:0] = (ipctrl_bht_con_br_vld)
                                    ? pre_offset_onehot_ip_1[15:0]
                                    : pre_offset_onehot_ip_0[15:0];
assign pre_offset_onehot_if[15:0] = (ipctrl_bht_con_br_vld)
                                    ? pre_offset_onehot_if_1[15:0]
                                    : pre_offset_onehot_if_0[15:0];
```

### 7.3 流水寄存器

这些输出信号通过 `bht_pipe_clk` 门控时钟触发的寄存器打一拍后送到 IP 级：

```verilog
// 行 1379-1403
always @(posedge bht_pipe_clk or negedge cpurst_b)
begin
  ...
  else if(ifctrl_bht_pipedown && cp0_ifu_bht_en && bht_pred_array_rd)
    bht_ipdp_pre_array_data_taken[31:0] <= pre_array_pipe_taken_data[31:0];
  ...
end
```

只有在 `ifctrl_bht_pipedown`（流水线正常向下推进）且 `bht_pred_array_rd`（本周期有 Pred Array 读操作）时，才更新输出寄存器，否则保持上一周期的值。

---

## 8. Write Buffer 详解

### 8.1 为什么需要 Write Buffer

`ct_ifu_bht_pre_array` 和 `ct_ifu_bht_sel_array` 分别实例化
`ct_spsram_1024x64` 与 `ct_spsram_128x16`；`spsram` 名称以及每个实例只有一组
地址、CEN、GWEN/WEN 和数据端口，表明当前 RTL 按单端口同步 SRAM 接口使用。
同一个阵列周期不能同时给出两个独立读/写地址，因此控制逻辑必须在读与写之间
选择一个地址和操作。BHT 中以下两类请求可能竞争各自阵列端口：

- **读操作**：`ipctrl_bht_con_br_vld`（IP 级取指）、`pcgen_bht_seq_read`（pcgen 阶段顺序读）、`pcgen_bht_chgflw`（跳转时读）等。
- **写操作**：`iu_ifu_bht_check_vld`（BJU 确认分支方向，需要更新 BHT 计数器）。

当前仲裁优先保证预测/恢复读取；发生冲突时，满足
`bht_wr_buf_create_vld && !buf_full` 的更新被存入 4 项 Write Buffer，之后在两个
阵列都没有读请求时消耗。该队列隐藏短时冲突，但它不是无限容量：若创建指针所指
entry 已有效，`buf_full=1` 会阻止本次 `entry_create`，RTL 也没有从 BHT 向 BJU
输出反压。因此持续读压力或缓冲满时，新的训练更新可能不进入队列；这影响学习
及时性，不影响已执行指令的架构正确性。

### 8.2 4 项循环队列的管理

Write Buffer 有 4 项（`entry0`～`entry3`），使用 one-hot 循环指针管理：

```verilog
// 行 997-1006（create_ptr）
always @(posedge wr_buf_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    create_ptr[3:0] <= 4'b0001;
  else if(bht_inv_on_reg)
    create_ptr[3:0] <= 4'b0001;
  else if(bht_wr_buf_create_vld && !buf_full)
    create_ptr[3:0] <= {create_ptr[2:0], create_ptr[3]};  // 循环左移
  ...
end
```

- **create_ptr**：指向下一个要写入（新建）的 entry，循环左移推进。
- **retire_ptr**：指向下一个要排空到 SRAM 的 entry，循环左移推进。这里的 `retire` 是写缓冲内部“消耗 entry”的命名，与处理器架构退休无关。
- **buf_full**：在循环 FIFO 指针与有效位协议保持正确的前提下，create_ptr 所指 entry 仍有效表示没有可覆盖空位，本次不新建。

每个 entry 存储 37 bit 的更新信息：

```verilog
// 行 1029-1036
assign entry_updt_data[36:0] = {
  iu_ifu_bht_condbr_taken,   // [36]    实际跳转方向
  bju_sel_rst[1:0],           // [35:34] Select Array 旧读出值
  bju_pred_rst[1:0],          // [33:32] Predict Array 旧读出值
  bju_ghr[21:0],              // [31:10] 分支发生时的 GHR 快照
  iu_ifu_cur_pc[12:3]         // [9:0]   内部 PC[12:3]，即字节 PC[13:4]
};
```

### 8.3 bht_wr_buf_updt_vld 条件（有读操作时不写）

```verilog
// 行 916-926
assign bht_wr_buf_updt_vld = (bju_check_updt_vld ||
                               bht_wr_buf_not_empty) &&
                             !(
                               after_inv_reg           ||
                               ipctrl_bht_con_br_vld   ||  // Pred Array 在读
                               after_bju_mispred       ||
                               rtu_ifu_flush           ||
                               after_rtu_ifu_flush     ||
                               pcgen_bht_chgflw && !lbuf_bht_active_state ||  // Sel Array 在读
                               pcgen_bht_seq_read              // Sel Array 在读
                             );
```

只有以下情况下才形成 `bht_wr_buf_updt_vld` 并向两个 SRAM 共用的写时隙推进：
1. 有待写的数据（`bju_check_updt_vld` 或 buffer 非空）
2. 当前周期不存在方程列出的预测、恢复或 Select Array 读取条件

**注意**：`lbuf_bht_active_state` 为真时，`pcgen_bht_chgflw` 不会阻止写，因为 lbuf 激活时不走 pcgen 正常流程。

### 8.4 Bypass 逻辑（wr_buf_hit）

当 Write Buffer 中有尚未落入 SRAM 的训练结果，而预测读取匹配相同的历史/PC
键时，阵列仍可能返回训练前的值。`wr_buf_hit` 旁路选择 entry 根据其保存的旧值
与实际方向重新计算出的 Select 计数器结果。需要注意，当前旁路输出
`wr_buf_sel_array_result` 只替换 `sel_array_val`；Predict Array 输出仍走
`pre_array_pipe_*` 路径。因而不能笼统写成“两个阵列的新值都由 Write Buffer
完整前递”。

```verilog
// 行 1785-1803
assign wr_buf_pre_hit_0 = (vghr_reg[20:0] == entry0_data[30:10]);  // GHR 匹配
assign wr_buf_sel_hit_0 = (bht_sel_array_index_flop[9:0] == entry0_data[9:0]);  // PC 匹配
assign wr_buf_hit_0     = wr_buf_pre_hit_0 && wr_buf_sel_hit_0 && entry0_vld;
...
assign wr_buf_hit        = (wr_buf_hit_0 || wr_buf_hit_1 ||
                            wr_buf_hit_2 || wr_buf_hit_3) &&
                           wr_buf_rd;  // 且当前确实在读
assign wr_buf_rd         = sel_rd_flop && pre_rd_flop;  // Sel 和 Pred 都在读
```

命中判断需要同时满足：
- **GHR 键匹配**：`vghr_reg[20:0]` 等于 entry 中保存的 `bju_ghr[20:0]`。比较没有包含 GHR bit21，因此准确说是 21 位键相等，而不是完整 22 位 GHR 相等。
- **PC 键匹配**：`bht_sel_array_index_flop[9:0]` 等于 entry 保存的 `iu_ifu_cur_pc[12:3]`。这里比较的是 Select 行内选择所需的完整 10 位 PC 键，不只是 7 位 SRAM 行地址。
- **entry 有效**

`wr_buf_rd` 要求两个 SRAM 同时处于读后一周期（`sel_rd_flop && pre_rd_flop`），表示当前是 IP 级使用预测结果的时刻，需要 bypass。

Bypass 时使用的 Sel Array 值来自 `entry_sel_updt_data`，它是根据 entry 中存储的旧读出值和实际方向重新计算的新计数器值：

```verilog
// 行 1829-1841（entry0 示例）
always @(entry0_data[35:33])
begin
case({entry0_data[34:33], entry0_data[35]})  // {sel_rst[1:0], condbr_taken}
  3'b001 : entry0_sel_updt_data[1:0] = 2'b01;
  3'b011 : entry0_sel_updt_data[1:0] = 2'b10;
  ...
endcase
end
```

注意：`entry0_data[35]` 是 `condbr_taken`，`entry0_data[34:33]` 是 `sel_rst[1:0]`，case 输入顺序为 `{sel_rst, condbr_taken}`。

### 8.5 pred_array_check_updt_vld：计数器饱和检查

```verilog
// 行 932-938
assign pred_array_check_updt_vld = !(
  ( (bju_pred_rst[1:0] == 2'b00) && !iu_ifu_bht_condbr_taken ) ||
  ( (bju_pred_rst[1:0] == 2'b11) &&  iu_ifu_bht_condbr_taken )
);
```

**逻辑**：如果计数器已经饱和，且实际方向与饱和方向一致，那么更新后计数器不会改变（已经是最大/最小值），写 SRAM 意义不大，可以跳过。

- `bju_pred_rst == 2'b00`（最低值 = 强烈 not-taken）且实际 not-taken：不用更新。
- `bju_pred_rst == 2'b11`（最高值 = 强烈 taken）且实际 taken：不用更新。

该门控避免数值不会变化的 SRAM 写请求，并减少 Write Buffer 占用；“降低功耗”是合理的设计意图，但具体动态功耗收益需要门级活动率和功耗分析量化。

### 8.6 sel_array_check_updt_vld：Bi-Mode 更新规则

```verilog
// 行 940-954
assign sel_array_check_updt_vld = !(
  ( (bju_sel_rst[1:0] == 2'b00) && !iu_ifu_bht_condbr_taken  ) ||  // 条件1：饱和且方向一致
  ( (bju_sel_rst[1:0] == 2'b11) &&  iu_ifu_bht_condbr_taken  ) ||  // 条件2：饱和且方向一致
  ( (bju_sel_rst[1]   == 1'b0)  &&  iu_ifu_bht_condbr_taken  // 条件3：Bi-Mode 规则
    && !iu_ifu_chgflw_vld ) ||
  ( (bju_sel_rst[1]   == 1'b1)  && !iu_ifu_bht_condbr_taken  // 条件4：Bi-Mode 规则
    && !iu_ifu_chgflw_vld )
);
```

4 个不更新的条件：

| 条件 | 含义 | 原因 |
|------|------|------|
| 1 | Sel 计数器为 `00`（强烈 not-taken 偏置）且分支实际 not-taken | 已饱和，更新无效 |
| 2 | Sel 计数器为 `11`（强烈 taken 偏置）且分支实际 taken | 已饱和，更新无效 |
| 3 | Sel MSB 为 0、实际 taken，且没有 change-flow | 虽然样本方向与 Not-Taken 偏置相反，但所选方向表已给出可接受预测，不改变选择侧 |
| 4 | Sel MSB 为 1、实际 not-taken，且没有 change-flow | 虽然样本方向与 Taken 偏置相反，但所选方向表已给出可接受预测，不改变选择侧 |

这四个排除条件合起来得到更准确的行为：

- 实际方向与选择偏置一致时，Select 计数器继续向相同方向训练，直到 `00` 或 `11` 饱和；并非“不更新”。
- 实际方向与偏置相反，但当前预测没有产生 `iu_ifu_chgflw_vld` 时，不更新 Select；说明当前所选方向表能够吸收这次反偏置样本，不必立即切换预测侧。
- 实际方向与偏置相反且产生 change-flow 时，不再命中条件 3/4，Select 计数器向实际方向移动。

这里把 `iu_ifu_chgflw_vld` 作为当前 RTL 的恢复/误预测指示使用。若上游还可能因其他
原因产生 change-flow，则需要结合 IU 文档进一步缩小语义，不能只凭信号名把每次
change-flow 都等同于纯方向误预测。

计数器的更新状态机（pred 和 sel 相同）：

```verilog
// 行 1244-1256
case({cur_pred_rst[1:0], cur_condbr_taken})
  3'b001 : pred_array_updt_data = 2'b01;  // 00+taken  → 01
  3'b011 : pred_array_updt_data = 2'b10;  // 01+taken  → 10
  3'b010 : pred_array_updt_data = 2'b00;  // 01+ntaken → 00
  3'b110 : pred_array_updt_data = 2'b10;  // 11+ntaken → 10（未饱和才能到这里）
  3'b101 : pred_array_updt_data = 2'b11;  // 10+taken  → 11
  3'b100 : pred_array_updt_data = 2'b01;  // 10+ntaken → 01
  3'b111 : pred_array_updt_data = 2'b11;  // 11+taken  → 11（饱和，不会触发写）
  3'b000 : pred_array_updt_data = 2'b00;  // 00+ntaken → 00（饱和，不会触发写）
endcase
```

这是标准 2-bit 饱和计数器的状态转移，`11` 和 `00` 是饱和边界（不再增减）。

---

## 9. BHT INV 无效化机制

### 9.1 触发条件

```verilog
// 行 1752-1753
else if(ifctrl_bht_inv)
  bht_inv_on_reg <= 1'b1;
```

`ifctrl_bht_inv` 是 `ct_ifu_ifctrl` 对 CP0 电平信号 `cp0_ifu_bht_inv` 做上升沿检测后产生的一次启动脉冲。继续追到 `ct_cp0_regs`，该请求由 MCOR 中的 `bht_inv` 控制位发起，并在 IFU 回报完成后清零。因此当前可直接证明的是“软件/CP0 控制的 BHT invalidate 流程”；不能把它未经证据地等同为每次 `fence.i` 必然触发。`fence.i` 的架构语义主要约束指令取值一致性，是否同时清预测器状态属于具体实现策略。

### 9.2 无效化过程

```verilog
// 行 1732-1744
always @(posedge bht_inv_cnt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    bht_inval_cnt_pre[9:0] <= 10'b0;
  else if(bht_inv_on_reg)
    bht_inval_cnt_pre[9:0] <= bht_inval_cnt_pre[9:0] - 10'b1;  // 倒计数
  else if(ifctrl_bht_inv)
    bht_inval_cnt_pre[9:0] <= 10'b1111111111;  // 设置初始值 = 1023
  else
    bht_inval_cnt_pre[9:0] <= bht_inval_cnt_pre[9:0];
end
```

无效化流程：

1. `ifctrl_bht_inv` 有效：设置 `bht_inval_cnt_pre = 1023`（10'b1111111111），设置 `bht_inv_on_reg = 1`。
2. 每周期 `bht_inval_cnt_pre` 减 1，同时 `bht_inval_cnt` 作为 Predict Array 和 Select Array 的写地址（从 1023 倒数到 0）。
3. 当 `bht_inval_cnt == 0` 时，`bht_inv_on_reg` 清零。
4. `bht_inv_on_reg` 从 1 变 0 后，`after_inv_reg` 形成一个后继周期脉冲，并触发 Predict/Select Array 读取。该读取重新建立阵列读出流水状态；RTL 没有比较读回值，所以不能称为“读回确认无效化正确”。

Predict Array 有 1K 项（1024），所以需要 1024 周期写完。Select Array 只有 128 项，但它用 `bht_inval_cnt[6:0]`（低 7 位）作为索引，在 1024 次写入中每个表项被写 8 次，足够。

### 9.3 无效化初始值：为什么是 `64'h3333_3333_3333_3333`？

```verilog
// 行 424-426
assign bht_pred_array_din[63:0] = bht_inv_on_reg
                                ? 64'h3333_3333_3333_3333
                                : bht_wr_buf_pred_updt_val[63:0];
```

`0x3 = 4'b0011` 不能被分割成两个 `01`。结合本模块的数据拆分：

```text
每个 4-bit 小组 = {Not-Taken 计数器[1:0], Taken 计数器[1:0]}
4'b0011          = {2'b00, 2'b11}
```

因此每一行初始化后：

- 16 个 Taken 侧计数器均为 `11`，其方向输出 MSB 为 1；
- 16 个 Not-Taken 侧计数器均为 `00`，其方向输出 MSB 为 0。

这正好让两张方向表从各自命名方向的强状态开始，而不是把全部计数器初始化为弱
not-taken。随后 Select Array 的 8 个计数器均清为 `00`，`ct_ifu_ipdp` 根据
`bht_sel_result[1]` 在两侧之间选择，所以初始默认选择 Not-Taken 侧并输出
not-taken。若后续 Select 训练到 MSB=1，则切换到初始为 strongly-taken 的
Taken 侧。

Select Array 无效化值：

```verilog
// 行 533-535
assign bht_sel_array_din[15:0] = bht_inv_on_reg
                               ? 16'b0           // 全 0，即强烈 not-taken 偏置
                               : bht_wr_buf_sel_updt_val[15:0];
```

Select Array 清零意味着所有 Sel 计数器为 `2'b00`。由
`pre_array_data = bht_sel_result[1] ? taken : ntake` 可直接确认这会默认选择
Not-Taken 侧。至于为何选择该冷启动偏置以及它对具体程序的收益，RTL 没有给出
统计依据，应通过冷启动阶段的分支行为或对照实验评价。

### 9.4 无效化期间 GHR 和输出寄存器清零

```verilog
// 行 605-606（rtughr_reg）
else if(bht_inv_on_reg)
  rtughr_reg[21:0] <= 22'b0;

// 行 657-658（vghr_reg）
else if(bht_inv_on_reg)
  vghr_reg[21:0] <= 22'b0;

// 行 1385-1387（bht_ipdp_pre_array_data_taken）
else if(bht_inv_on_reg)
  bht_ipdp_pre_array_data_taken[31:0] <= 32'b0;
```

无效化期间，两套 GHR、本文列出的预测输出/保存寄存器以及 Write Buffer 有效位
会被清零，两个 SRAM 被写入规定的初始化模式。应避免用“所有内部状态”这种无法
穷举的表述；例如部分索引流水寄存器只按各自读使能更新，并不都在
`bht_inv_on_reg` 分支显式清零。功能上的关键点是：无效化后不再依赖旧的有效训练
entry，预测从指定初态重新开始。

### 9.5 状态输出

```verilog
// 行 1756-1757
assign bht_ifctrl_inv_done = !bht_inv_on_reg;
assign bht_ifctrl_inv_on   = bht_inv_on_reg;
```

`ifctrl` 模块通过 `bht_ifctrl_inv_done` 知道无效化何时完成，期间流水线处于暂停或特殊处理状态。

---

## 10. Loop Buffer 集成

### 10.1 Loop Buffer 的作用

Loop Buffer（lbuf）是 C910 IFU 中的一个小型缓冲区，用于加速短循环的执行。当检测到程序正在执行一个短循环（循环体能完整放入 lbuf）时，lbuf 激活（`lbuf_bht_active_state = 1`），取指不再走正常的 icache 路径，而是直接从 lbuf 重复读出。

### 10.2 lbuf 激活时的 Predict Array 读条件变化

```verilog
// 行 357-358
assign bht_pred_array_rd = after_inv_reg ||
  ipctrl_bht_con_br_vld && !lbuf_bht_active_state ||  // 正常模式：ipctrl 触发
  lbuf_bht_con_br_vld   &&  lbuf_bht_active_state ||  // lbuf 模式：lbuf 触发
  bju_mispred || after_bju_mispred ||
  rtu_ifu_flush || after_rtu_ifu_flush;
```

正常模式下，`ipctrl_bht_con_br_vld` 触发 Pred Array 读；lbuf 激活时，改为由 `lbuf_bht_con_br_vld` 触发。这样 lbuf 的循环分支也能用上 BHT 预测。

同理，Select Array 读的条件：

```verilog
// 行 916-926（bht_wr_buf_updt_vld 中的阻塞条件）
pcgen_bht_chgflw && !lbuf_bht_active_state
```

lbuf 激活时，`pcgen_bht_chgflw` 不再阻止 Write Buffer 写入 SRAM，因为 lbuf 激活时 pcgen 不走 chgflw 路径。

### 10.3 lbuf 的 VGHR 更新

```verilog
// 行 665-666（vghr_reg 更新中）
else if(vghr_lbuf_updt_vld)
  vghr_reg[21:0] <= {vghr_reg[20:0], lbuf_bht_con_br_taken};
```

`vghr_lbuf_updt_vld = cp0_ifu_bht_en && lbuf_bht_con_br_vld`：lbuf 报告条件分支
时，RTL 把 `lbuf_bht_con_br_taken` 追加到 VGHR。这个机制使 lbuf 路径也参与
投机历史推进；“历史是否正确”还依赖 lbuf 提供的 valid/taken 与分支程序顺序
一致，以及后续 change-flow/flush 恢复协议，不能由这一条赋值单独保证。

### 10.4 lbuf 的预测结果输出

```verilog
// 行 1903-1927
always @(posedge bht_pipe_clk or negedge cpurst_b)
begin
  ...
  else if(cp0_ifu_bht_en && lbuf_bht_con_br_vld && lbuf_bht_active_state)
    lbuf_pre_taken_reg[31:0] <= pre_array_pipe_taken_data[31:0];
  ...
end
assign bht_lbuf_pre_taken_result[31:0]  = lbuf_pre_taken_reg[31:0];
assign bht_lbuf_pre_ntaken_result[31:0] = lbuf_pre_ntaken_reg[31:0];
assign bht_lbuf_vghr[21:0]              = vghr_reg[21:0];
```

BHT 为 lbuf 提供专门的输出接口（`bht_lbuf_*`），将 Predict Array 读出的 Taken/Not-Taken 计数器数据和当前 VGHR 提供给 lbuf，使得 lbuf 能够在循环中继续使用 BHT 预测而不必走正常的 ipdp 路径。

---

## 附录：关键信号一览

### 输入信号

| 信号 | 位宽 | 来源模块 | 含义 |
|------|------|---------|------|
| `rtu_ifu_retire0/1/2_condbr` | 1 | RTU | 各退休槽位是否有条件分支 |
| `rtu_ifu_retire0/1/2_condbr_taken` | 1 | RTU | 各退休槽位分支实际方向 |
| `rtu_ifu_flush` | 1 | RTU | RTU 触发流水线冲刷 |
| `iu_ifu_chgflw_vld` | 1 | IU/BJU | BJU 检测到误预测 |
| `iu_ifu_chk_idx[24:0]` | 25 | IU | 分支检查包（含 GHR 快照、旧计数器值） |
| `iu_ifu_bht_check_vld` | 1 | IU | 本周期 BHT 有检查有效 |
| `iu_ifu_bht_condbr_taken` | 1 | IU | 检查分支的实际方向 |
| `iu_ifu_bht_pred` | 1 | IU | 检查分支的预测值（旧） |
| `ipctrl_bht_con_br_vld` | 1 | ipctrl | IP 级有条件分支 |
| `ipctrl_bht_con_br_taken` | 1 | ipctrl | IP 级分支的预测方向（当前预测） |
| `ipctrl_bht_more_br` | 1 | ipctrl | IP 级有多于一条分支 |
| `ipctrl_bht_vld` | 1 | ipctrl | IP 级有效 |
| `pcgen_bht_pcindex[9:0]` | 10 | pcgen | 内部 `rtl_vpc[12:3]`，即字节 PC `[13:4]`，用于 Sel Array 行和行内选择 |
| `pcgen_bht_ifpc[6:0]` | 7 | pcgen | 内部 `rtl_vpc[6:0]`，即字节 PC `[7:1]`；其中 `[5:3]` 用于 `if_pc_onehot` |
| `pcgen_bht_seq_read` | 1 | pcgen | 顺序取指，触发 Sel Array 读 |
| `pcgen_bht_chgflw` | 1 | pcgen | 跳转取指，触发 Sel Array 读 |
| `lbuf_bht_active_state` | 1 | lbuf | Loop Buffer 激活 |
| `lbuf_bht_con_br_vld` | 1 | lbuf | lbuf 当前有条件分支 |
| `lbuf_bht_con_br_taken` | 1 | lbuf | lbuf 分支预测方向 |
| `ifctrl_bht_inv` | 1 | ifctrl | 触发 BHT 无效化（fence.i） |
| `ifctrl_bht_pipedown` | 1 | ifctrl | 流水线向下推进（pipe down） |
| `ifctrl_bht_stall` | 1 | ifctrl | 流水线暂停 |

### 输出信号

| 信号 | 位宽 | 去向 | 含义 |
|------|------|------|------|
| `bht_ipdp_pre_array_data_taken[31:0]` | 32 | ipdp | Pred Array Taken 侧读出（32 个 2-bit） |
| `bht_ipdp_pre_array_data_ntake[31:0]` | 32 | ipdp | Pred Array Not-Taken 侧读出 |
| `bht_ipdp_pre_offset_onehot[15:0]` | 16 | ipdp | 从 32 个中选哪个计数器的 one-hot |
| `bht_ipdp_sel_array_result[1:0]` | 2 | ipdp | Sel Array 2-bit 计数器当前值 |
| `bht_ipdp_vghr[21:0]` | 22 | ipdp | VGHR 快照，随指令流水 |
| `bht_lbuf_pre_taken_result[31:0]` | 32 | lbuf | 为 lbuf 提供的 Pred Array 读出 |
| `bht_lbuf_pre_ntaken_result[31:0]` | 32 | lbuf | 为 lbuf 提供的 Not-Taken 读出 |
| `bht_lbuf_vghr[21:0]` | 22 | lbuf | 为 lbuf 提供的当前 VGHR |
| `bht_ind_btb_vghr[7:0]` | 8 | Ind BTB | vghr 低 8 位 |
| `bht_ind_btb_rtu_ghr[7:0]` | 8 | Ind BTB | rtughr 低 8 位 |
| `bht_ifctrl_inv_on` | 1 | ifctrl | BHT 无效化进行中 |
| `bht_ifctrl_inv_done` | 1 | ifctrl | BHT 无效化完成 |

### 内部关键寄存器

| 寄存器 | 位宽 | 含义 |
|--------|------|------|
| `vghr_reg[21:0]` | 22 | 投机 GHR（Virtual GHR） |
| `rtughr_reg[21:0]` | 22 | 退休 GHR（Retire GHR） |
| `bht_inval_cnt_pre[9:0]` | 10 | 无效化倒计数（1023→0） |
| `bht_inv_on_reg` | 1 | 无效化进行中标志 |
| `create_ptr[3:0]` | 4 | Write Buffer 写入指针（one-hot） |
| `retire_ptr[3:0]` | 4 | Write Buffer 读出指针（one-hot） |
| `entry0/1/2/3_vld` | 1 | Write Buffer 各项有效位 |
| `entry0/1/2/3_data[36:0]` | 37 | Write Buffer 各项数据 |
| `pre_rd_flop` | 1 | Pred Array 读后一周期标志 |
| `sel_rd_flop` | 1 | Sel Array 读后一周期标志 |
| `pre_taken_reg[31:0]` | 32 | Pred Array 读出保存（Taken 侧） |
| `pre_ntaken_reg[31:0]` | 32 | Pred Array 读出保存（Not-Taken 侧） |
| `bht_sel_data_reg[15:0]` | 16 | Sel Array 读出保存 |
| `after_bju_mispred` | 1 | BJU 误预测后一周期标志 |
| `after_rtu_ifu_flush` | 1 | RTU flush 后一周期标志 |
