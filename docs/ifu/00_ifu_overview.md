# C910 IFU（取指单元）深度学习指南

> 本文从取指重定向、分支预测、I-cache、预译码、指令缓冲和下游交付六条主线说明 C910 IFU，并给出对应 RTL 入口。
> 学完本文档，应能对 IFU 的每个子模块的职责、关键信号、设计取舍有清晰认知。

---

## 目录

1. [IFU 总体架构](#1-ifu-总体架构)
2. [体系结构基础：为什么需要这些模块](#2-体系结构基础)
3. [pcgen — PC 生成](#3-pcgen--pc-生成)
4. [L0 BTB — 前移的分支目标缓冲](#4-l0-btb--前移的分支目标缓冲)
5. [BTB — 分支目标缓冲](#5-btb--分支目标缓冲)
6. [BHT — 分支历史预测器](#6-bht--分支历史预测器)
7. [RAS — 返回地址栈](#7-ras--返回地址栈)
8. [icache_if — I-Cache 接口](#8-icache_if--i-cache-接口)
9. [precode — 预解码](#9-precode--预解码)
10. [ifctrl / ifdp — IF 级控制与数据通路](#10-ifctrl--ifdp--if-级控制与数据通路)
11. [ipctrl / ipdp — IP 级控制与数据通路](#11-ipctrl--ipdp--ip-级控制与数据通路)
12. [ibctrl / ibdp — IB 级控制与数据通路](#12-ibctrl--ibdp--ib-级控制与数据通路)
13. [ibuf — 指令缓冲队列](#13-ibuf--指令缓冲队列)
14. [lbuf — 循环缓冲](#14-lbuf--循环缓冲)
15. [addrgen — 分支地址生成](#15-addrgen--分支地址生成)
16. [l1_refill — L1 Cache 缺失填充](#16-l1_refill--l1-cache-缺失填充)
17. [IFU 完整数据流串讲](#17-ifu-完整数据流串讲)
18. [关键设计决策汇总](#18-关键设计决策汇总)

---

## 1. IFU 总体架构

### 1.1 IFU 在处理器中的位置

```
┌────────────────────────────────────────────────────────────────────┐
│                        C910 处理器核心                              │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                        IFU（取指单元）                        │  │
│  │  PCGEN → IF 级 → IP 级 → IB 级 → IBUF ──→ IDU              │  │
│  └─────────────────────────────────────────────────────────────┘  │
│         ↑ RTU 异常返回 PC         ↑ IU 分支纠错 PC               │
│                                                                    │
│  IDU → IU → LSU → RTU（退休）                                     │
└────────────────────────────────────────────────────────────────────┘
```

IFU 是流水线的**源头**，其核心使命：
- 每周期向 IDU 提供尽量多的有效指令；当前 RTL 的 IDU 接口为
  `inst0/1/2` 三槽，因此接口峰值是 3 条指令/周期
- 通过分支预测减少流水线气泡
- 管理 I-Cache，处理 miss 和 refill

### 1.2 IFU 内部三级流水

IFU 内部有三个流水级，对应三套 ctrl+dp（控制+数据通路）模块：

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  PCGEN   │───▶│  IF 级   │───▶│  IP 级   │───▶│  IB 级   │───▶ IBUF ───▶ IDU
│  PC生成  │    │ 取指/命中 │    │ 预解码   │    │ 打包送出 │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
   L0 BTB          I-Cache        BTB/BHT          IBUF
   BTB              Tag           分支决策          LBUF
   BHT              Data          地址生成
   RAS              Precode
```

| 流水级 | 关键操作 | 主要模块 |
|--------|----------|----------|
| PCGEN  | 选择下一 PC，发起 SRAM 读请求 | `ct_ifu_pcgen.v` |
| IF 级  | 接收 I-Cache 数据，做 tag 比较 | `ct_ifu_ifctrl.v` `ct_ifu_ifdp.v` |
| IP 级  | 预解码，BTB/BHT 决策，生成跳转 PC | `ct_ifu_ipctrl.v` `ct_ifu_ipdp.v` |
| IB 级  | 打包指令，写 IBUF，处理 mispred | `ct_ifu_ibctrl.v` `ct_ifu_ibdp.v` |

### 1.3 模块文件清单

| 文件 | 行数 | 职责简述 |
|------|------|----------|
| `ct_ifu_top.v` | 4366 | IFU 顶层，连接所有子模块 |
| `ct_ifu_pcgen.v` | 1076 | PC 选择与生成 |
| `ct_ifu_l0_btb.v` | 1351 | L0 BTB（16 项寄存器表，命中向量打拍后用于 IF 级早期目标） |
| `ct_ifu_btb.v` | 861 | BTB（当前 RTL 为 512 行×4 个固定位置槽） |
| `ct_ifu_bht.v` | 1975 | BHT（Bi-Mode，64K bits） |
| `ct_ifu_ras.v` | 1930 | 返回地址栈（12 项投机栈 + 6 项退休恢复副本） |
| `ct_ifu_ind_btb.v` | 685 | 间接跳转目标预测（256×23-bit） |
| `ct_ifu_sfp.v` | 1128 | 推测失败与 `vsetvli`/VL 预测表（12 项） |
| `ct_ifu_icache_if.v` | 832 | I-Cache SRAM 接口 |
| `ct_ifu_ipb.v` | 1002 | 下一 cache line 预取、BIU 请求和预取缓冲 |
| `ct_ifu_precode.v` | 320 | 128→32bit 预解码 |
| `ct_ifu_ifctrl.v` | 1396 | IF 级流水线控制 |
| `ct_ifu_ifdp.v` | 2085 | IF 级数据通路 |
| `ct_ifu_ipctrl.v` | 2022 | IP 级流水线控制 |
| `ct_ifu_ipdp.v` | 6872 | IP 级数据通路（最大） |
| `ct_ifu_ibctrl.v` | 986 | IB 级流水线控制 |
| `ct_ifu_ibuf.v` | 9623 | 指令缓冲队列（最复杂） |
| `ct_ifu_lbuf.v` | 6954 | 循环缓冲 |
| `ct_ifu_addrgen.v` | 306 | 分支目标地址计算 |
| `ct_ifu_l1_refill.v` | 793 | I-Cache miss 填充状态机 |
| `ct_ifu_pcfifo_if.v` | 1074 | 从 H1~H8 中选最多两个控制流并创建 IU PCFIFO 项 |
| `ct_ifu_vector.v` | 293 | 复位、异常和中断入口 PC 控制；不是 SIMD 向量执行单元 |
| `ct_ifu_debug.v` | 386 | 将关键状态压缩为 83-bit HAD 调试快照 |

上表列出 `ct_ifu_top.v` 的 22 个直接子模块。各子模块内部还实例化 entry、
array 和 SRAM wrapper；这些叶子模块不是新的体系结构阶段，但它们决定真实容量、
端口数、更新粒度和时序边界，不能只根据顶层信号名推断。

---

## 2. 体系结构基础

### 2.1 为什么需要分支预测？

现代处理器流水线深度通常超过 10 级。若没有分支预测，每遇到分支指令（beq/jal/jalr 等）就必须等到执行阶段确认跳转方向和目标，期间流水线空转。

预测失败的损失不是一个可由单个 RTL 文件固定证明的常数。它取决于错误在哪一级
被发现、重定向优先级、当时各级有效指令数和前端重新供给速度。分析时应从
`iu_ifu_chgflw_vld` 或 RTU flush 开始，量到下一次 IDU 接收非零指令的周期；
综合后的时钟频率和具体 benchmark 统计另行决定最终性能代价。

**分支预测的两个问题**：
1. **方向预测**（taken/not-taken）：条件跳转会不会跳？— BHT 负责
2. **目标预测**（target PC）：跳到哪里？— BTB/L0-BTB/RAS 负责

### 2.2 C910 的三级分支预测层次

```
L0 BTB（16 项）── PCGEN 形成查找键，命中向量打拍后比主 BTB 更早给出目标
    │ miss
    ▼
BTB（512 行×4 个固定位置槽）── IF 级，1 拍 SRAM 延迟，覆盖更多跳转历史
    │ miss
    ▼
Indirect BTB ── IP 级，针对间接跳转（jr, 函数指针）
    └─ RAS ── 专门预测函数返回地址（ret/jalr x0, ra, 0）
```

预测精度逐层提高，延迟也逐层增加。

### 2.3 I-Cache 的组织方式

C910 I-Cache 是**2-way 组相联（Set-Associative）**，使用 **FIFO 替换策略**：

```
I-Cache 结构（当前 `ICACHE_64K` 配置）：
  容量：64 KiB，2 路，64 字节 cache line，共 512 组
  Tag：ct_spsram_512x59，一行保存同一组的两路 tag 和 FIFO 位
  Data：每路 4 个 ct_spsram_2048x32_split bank
  组织：虚拟索引定位 set，物理 tag 判断命中
        tag[27:0] 与 PA 比较 → 判断是否命中（Hit）
        way0 / way1 → 2 路，靠 FIFO bit 决定替换哪路

  每个 Tag Array 项（59 位）：
  [58]      FIFO bit（下次替换哪路）
  [57:29]   Way1：{valid(1), tag(28)}
  [28:0]    Way0：{valid(1), tag(28)}

  数据宽度：每路 4 个 32 位 bank，同一数据行合计 128 位
  即每次取出 128 位 = 8 个 16 位半字；一条 64 字节 line 占 4 个数据行
```

**关键设计**：Tag 和 Data 分开存储，**Tag 先读**（用于命中判断）；
Data 读取由 Way Predict 预先激活对应路，命中后直接使用，未命中则丢弃重新发起。

### 2.4 信号命名规范

C910 信号命名格式：**`源模块_目标模块_含义`**

```
iu_ifu_chgflw_vld     ← IU 发给 IFU 的"改变流向"有效信号
rtu_ifu_chgflw_pc     ← RTU 发给 IFU 的新 PC（异常返回地址）
pcgen_btb_index       ← pcgen 发给 BTB 的查询索引
ifctrl_pcgen_stall    ← ifctrl 通知 pcgen 暂停
cp0_ifu_btb_en        ← CP0 控制 BTB 使能
```

跨模块信号约定：`_vld` 表示有效，`_ack` 表示确认，`_en` 表示使能，`_b` 表示低有效（常用于 SRAM cen/wen）。

---

## 3. pcgen — PC 生成

**文件**：`ct_ifu_pcgen.v`（1076 行）

### 3.1 职责

每个时钟周期确定下一周期要访问的 PC，并驱动 I-Cache、BTB、BHT 开始读取。

### 3.2 PC 宽度设计

```verilog
parameter PC_WIDTH = 40;  // 物理地址 40 位
// 内部 PC 寄存器：if_pc[38:0]，保存架构字节 PC[39:1]
// MMU 地址总线：ifu_mmu_va[62:0]，保存架构虚拟地址 VA[63:1]
```

**首先要分清 RTL 位号和架构地址位号**：RISC-V C 扩展允许指令按 2 字节对齐，因此架构 PC 的 `PC[0]` 恒为 0。C910 不存这一位，内部统一采用半字地址：

```text
if_pc[38:0] = byte_pc[39:1]
byte_pc[39:0] = {if_pc[38:0], 1'b0}
```

所以内部 `if_pc[0]` 不是恒为 0，而是架构字节 PC 的 `PC[1]`。内部 PC 加 1 代表字节地址增加 2。低 39 位之外的虚地址高 24 位由 `if_pc_high_spe` 单独维护，仅在 IU 提供特殊高位地址时使用；其余情况通过 `if_pc[38]` 符号扩展。这既省去常态下的高位寄存器翻转，也保留了 64 位虚拟地址信息。

### 3.3 PC 来源优先级（核心逻辑）

共 10 个来源，从高到低：

```verilog
// ct_ifu_pcgen.v 第 407-428 行
always @(...) begin
  if(had_ifu_pcload)              // 1. HAD 调试器强制加载
    ifpc_chgflw_pre = had_ifu_pc;
  else if(vector_pcgen_pcload)    // 2. 向量模式复位 PC
    ifpc_chgflw_pre = vector_pcgen_pc;
  else if(rtu_ifu_chgflw_vld)    // 3. RTU 异常/中断返回
    ifpc_chgflw_pre = rtu_ifu_chgflw_pc;
  else if(iu_ifu_chgflw_vld)     // 4. IU 分支纠错（最常见外部打断）
    ifpc_chgflw_pre = iu_ifu_chgflw_pc;
  else if(addrgen_pcgen_pcload)  // 5. 地址生成确认
    ifpc_chgflw_pre = addrgen_pcgen_pc;
  else if(ibctrl_pcgen_pcload)   // 6. IB 级改变流向
    ifpc_chgflw_pre = ibctrl_pcgen_pc;
  else if(ipctrl_pcgen_reissue_pcload) // 7. IP 级 reissue
    ifpc_chgflw_pre = ipctrl_pcgen_reissue_pc;
  else if(ipctrl_pcgen_chgflw_pcload)  // 8. IP 级改变流向（BTB/BHT 预测跳转）
    ifpc_chgflw_pre = ipctrl_pcgen_chgflw_pc;
  else if(ifctrl_pcgen_chgflw_no_stall_mask) // 9. IF 级改变流向
    ifpc_chgflw_pre = ifctrl_pcgen_pcload_pc;
  else                           // 10. if_pc（保持）
    ifpc_chgflw_pre = if_pc;
end
```

**为什么是这个优先级？**
- HAD（调试器）是最高权威，必须能强制控制 PC；
- RTU 处理的是已经提交的精确异常，必须优先于推测性执行；
- IU 分支纠错比 IFU 内部预测更晚但更准确；
- IFU 内部优先级：IB 级（越靠后越精确）> IP 级 > IF 级。

### 3.4 if_pc 寄存器更新

```verilog
// ct_ifu_pcgen.v 第 484-494 行
always @(posedge forever_cpuclk or negedge cpurst_b) begin
  if(!cpurst_b)
    if_pc <= 0;                        // 复位：PC = 0
  else if(pcgen_chgflw)
    if_pc <= ifpc_chgflw_pre;         // 有跳转：切换 PC
  else if(!ifctrl_pcgen_stall)
    if_pc <= inc_pc;                   // 无 stall：顺序推进
  else
    if_pc <= if_pc;                    // stall：冻结
end
```

### 3.5 inc_pc — 不是简单的 +4

```verilog
// ct_ifu_pcgen.v 第 467-471 行
assign inc_pc_hi[35:0] = {if_pc[38:3]} + {35'b0, !ifctrl_pcgen_reissue_pcload};
assign inc_pc[38:0] = {inc_pc_hi[35:0], {3{ifctrl_pcgen_reissue_pcload}} & if_pc[2:0]};
```

C910 的 I-Cache line 是 64 字节，但每次送入前端处理的是其中一个 **128 位、16 字节取指块**。`if_pc[2:0]` 对应架构字节 PC `[3:1]`，表示当前 PC 位于这个 16 字节块中的第几个半字。

正常顺序取指时，RTL 对 `if_pc[38:3]` 加 1，并把低 3 位清零，等价于把架构字节 PC 推进到**下一个 16 字节边界**：

```text
next_byte_pc = ((byte_pc >> 4) + 1) << 4
```

若当前 PC 已在块首，内部表现为 `if_pc + 8`，但内部 8 个单位是 8 个半字，即 16 字节。`reissue_pcload=1` 时高位不增加且低 3 位保持，表示重发当前地址。

### 3.6 Way Predict

I-Cache 是 2-way，pcgen 维护一个 `way_predict[1:0]` 预测本次取指在哪一路：

| 编码 | 含义 |
|------|------|
| `2'b11` | 两路都读（保守，性能差但不会错） |
| `2'b10` | 只读 Way1 |
| `2'b01` | 只读 Way0 |
| `2'b00` | 两路都不读（关闭 ICG，触发 stall） |

`way_predict=2'b00` 时 pcgen 向 ifctrl 发出 `pcgen_ifctrl_way_pred_stall`，I-Cache 停止读取。

### 3.7 Cancel 信号层次

pcgen 向各级流水分别发 cancel，越靠后的级别可取消来源越少（设计原则：高优先级外部事件取消一切，低优先级内部事件只取消自身后面）：

```
pcgen_ifctrl_cancel（IF 级）= 几乎所有外部 chgflw + 异常 + 调试
pcgen_ipctrl_cancel（IP 级）= had/vector/rtu/iu/addrgen/ibctrl + 异常 + 调试
pcgen_ibctrl_cancel（IB 级）= had/vector/rtu/iu + 异常 + 调试
```

### 3.8 MMU 接口

```verilog
assign ifu_mmu_va[62:0] = {if_pc_high_spe[23:0], if_pc[38:0]};
assign ifu_mmu_abort    = pcgen_ifctrl_cancel || !cp0_yy_clk_en || vector_pcgen_reset_on;
assign ifu_mmu_va_vld   = 1'b1;  // 每周期无条件发虚地址给 MMU
```

`ifu_mmu_va[62:0]` 表示架构虚拟地址 `VA[63:1]`，不是缺了一位精度的“63 位地址”；完整字节地址应写成 `{ifu_mmu_va[62:0],1'b0}`。MMU 每周期都收到当前 PC 做投机翻译，`abort=1` 时告知 MMU 结果可丢弃，不影响页表状态。取指和翻译并行进行，节省一个周期。

---

## 4. L0 BTB — 前移的分支目标缓冲

**文件**：`ct_ifu_l0_btb.v`（1351 行）

### 4.1 为什么需要 L0 BTB？

普通 BTB 使用同步 SRAM，PCGEN 发起访问后，目标信息要到后续流水阶段才可参与判断。L0 BTB 是一个**全寄存器实现的 16 项热点目标表**，把全项并行比较提前到 IF 级附近；但比较所得命中向量还要写入 `entry_hit_flop`，因此不能把整条重定向路径称为“零周期”或“PCGEN 同周期改 PC”。

### 4.2 结构

```
L0 BTB = 16 个寄存器项（不使用 SRAM）

每项包含：
  vld       (1 bit)  — 有效
  tag[14:0] (15 bit) — 来自 ibdp_btb_index_pc[14:0]
  target[19:0]  (20 bit) — 跳转目标低 20 位
  way_pred[1:0] (2 bit)  — I-Cache way 预测
  cnt       (1 bit)  — 分支计数（用于淘汰）
  ras_bit   (1 bit)  — 是否是 return 指令
```

### 4.3 读取流程（组合比较与命中寄存）

```verilog
// 16 路并行 tag 比较
wire entry0_rd_hit = (l0_btb_rd_tag[14:0] == entry0_tag) && entry0_vld;
// ... entry1~15 类似

// 命中向量先在时钟沿写入 entry_hit_flop，
// 随后再用该向量选择命中项的 target
always @(*) begin
  case(entry_hit_flop[15:0])
    16'b...0001: l0_btb_hit_target = entry0_target;
    16'b...0010: l0_btb_hit_target = entry1_target;
    // ...
  endcase
end
```

命中向量寄存后，L0 BTB 根据命中项的 `cnt`、`target` 和 `way_pred` 形成候选改流信息；IFCTRL 还要检查指令数据有效、stall 和 reissue 等条件，条件成立才向 PCGEN 发出 IF 级改流。它比普通 BTB 的 SRAM 路径更早给出热点目标，但节省的实际周期数要结合整条 PCGEN/IFCTRL 波形判断。

### 4.4 更新时机

L0 BTB 的字段创建和更新来自 IBDP 下传的信息；新条目由 16-bit one-hot
`entry_fifo` 选择，每次创建循环移位一位，形成确定的 FIFO/轮转替换，不是
LRU。ADDRGEN 在更后一级复算直接控制流目标；若已有 L0 BTB 命中项最终被确认
为目标预测错误，它只通过命中独热码清除该项 `vld`，并不把完整正确目标写入
L0 BTB。

### 4.5 状态机

```
IDLE ──[pcgen_l0_btb_chgflw_vld]──▶ WAIT
WAIT ──[IP 级确认已到达且无需继续等待]──▶ IDLE
WAIT ──[更高优先级改流形成 mask]────────▶ IDLE
```

WAIT 不是“等待 entry 写完”。它跟踪一次早期 L0 BTB 改流何时到达 IP 级，
配合 `wait_next/chgflw_mask` 防止预测上下文错拍；精确条件见
[02_l0_btb.md](02_l0_btb.md) 第 6 节。

---

## 5. BTB — 分支目标缓冲

**文件**：`ct_ifu_btb.v`（861 行）

### 5.1 结构

```
BTB = Tag Array + Data Array。当前生成 RTL 中每个阵列由两个 512 深度 SRAM
并行组成；每行合计读出 4 个固定位置槽。RTL 把这些槽命名为 way0~way3，
但写槽由分支 PC 的低位确定，并不存在组相联结构中的任意路替换。

Tag Array（44 位宽，每项含 4 路）：
[43] valid3  [42:33] tag3[9:0]
[32] valid2  [31:22] tag2[9:0]
[21] valid1  [20:11] tag1[9:0]
[10] valid0  [9:0]   tag0[9:0]

Data Array（88 位宽，每项含 4 路）：
[87:86] way_pred3  [85:66] target3[19:0]
[65:64] way_pred2  [63:44] target2[19:0]
[43:42] way_pred1  [41:22] target1[19:0]
[21:20] way_pred0  [19:0]  target0[19:0]
```

### 5.2 Index 与 Tag 编码

```
内部 index[9:0] = rtl_vpc[12:3] = byte_vpc[13:4]
内部 tag[9:0]   = {rtl_vpc[19:13], rtl_vpc[2:0]}
                  = {byte_vpc[20:14], byte_vpc[3:1]}
```

`rtl_vpc[12:3]` 以 16 字节取指块为索引粒度；`rtl_vpc[2:0]` 则精确指出分支位于该块的哪个半字位置。文档后续若直接引用 RTL 信号位号，均遵循“内部位 `n` 对应架构字节地址位 `n+1`”这一规则。

### 5.3 读取流程（两拍）

```
周期 N（pcgen 送 index）：
  → SRAM 读出 tag_dout（44 位）和 data_dout（88 位）

周期 N+1（IF 级，btb_rd_flop=1）：
  → ifdp 收到 btb_ifdp_wayX_tag/target/pred/vld
  → ifdp 做 tag 比较，判断 4 路哪路命中
  → 命中路的 target 送入预测流程
```

读出结果可以来自 SRAM 直接输出或锁存寄存器：当 IP 级 way 预测出错（`ip_way_mispred`）时，不更新锁存寄存器，保留上次结果供 reissue 使用。

### 5.4 Refill Buffer（延迟写机制）

**问题根源**：BTB 中每一项除了存 target_pc，还存 I-Cache way_pred。但 way_pred 在 BTB Miss 时还不知道（要等取指流过 IP 级才能确认）。所以不能在 miss 时立刻把完整信息写入 BTB。

**解决方案**：用 Refill Buffer 缓存 miss 的 index/tag/target，等到 way_pred 确认（约 2 拍后），再将完整条目写入 BTB。

```
BTB Miss 发生：
  → refill_buf_index / tag / target_pc ← addrgen 提供
  → 等 2 拍（after_addrgen_btb_chgflw_first/second）
  → refill_buf_way_pred ← ipctrl_btb_way_pred（IP 级确认）
  → refill_buf_valid = 1（条目完整）

下次发生 Miss 或 I-Cache way 预测错误：
  → refill_buf → 写入 BTB SRAM（才真正填充）
```

这种"懒写"策略避免了多次 SRAM 读写冲突，也利用了 BTB Miss 相对低频的特性。

### 5.5 Invalidation

触发：`fence.i` 指令（或软件主动清 BTB）→ `ifctrl_btb_inv=1`

过程：`btb_inval_cnt` 从 511 倒计数至 0，每周期用 `btb_inv_on_reg` 把每个 index 的 valid 位清 0，共 512 个周期完成全量无效化。期间 BTB 停止响应查询。

---

## 6. BHT — 分支历史预测器

**文件**：`ct_ifu_bht.v`（1975 行）

### 6.1 Bi-Mode 预测算法

C910 使用 **Bi-Mode BHT**。主 Predict Array 为 64 Kibit，另有 2 Kibit
Select Array：

```
结构：
  Predict Array：1 个 1024×64 SRAM（共 64 Kibit）
    - 每行交错存放 32-bit Taken + 32-bit Not-Taken

  Select Array（选择表）：128×16 bits = 1 个 SRAM
    - 每项 16 bits = 8 个 2-bit 饱和计数器
    - 用 PC 高位索引，决定用哪张预测表
```

**为什么用 Bi-Mode？** 经典 2-bit 饱和计数器（2BC）会有"别名"问题——不同分支映射到同一表项，互相污染预测状态。Bi-Mode 将"偏向跳转"和"偏向不跳转"的分支分开存储，显著减少干扰。

### 6.2 两套 GHR

| 寄存器 | 宽度 | 更新来源 | 用途 |
|--------|------|----------|------|
| VGHR（虚拟全局历史）| 22 bit | IP 级实时（投机更新） | 取指时查 BHT 的索引 |
| RTUGHR（退休全局历史）| 22 bit | RTU 退休确认（精确） | 预测出错时恢复 VGHR |

VGHR 每次检测到 IP 级有条件分支就追加预测结果（投机）；RTUGHR 按退休顺序追加每周期最多 3 条指令的真实结果（精确）。预测出错时 VGHR ← RTUGHR，恢复到正确状态。

### 6.3 Predict Array 索引

```verilog
// 普通预测（IP 级有条件分支）
bht_pred_array_rd_index = {vghr_reg[11:8], {vghr_reg[7:2] ^ vghr_reg[19:14]}}
```

**GHR 折叠（Folding）**：将 22 位 GHR 压缩到 10 位索引。折叠异或让不同长度历史模式区分开，减少别名冲突。

### 6.4 预测结果输出

BHT 向 IP 级（ipdp）输出：
```
bht_ipdp_pre_array_data_taken[31:0]   — taken 表的 32 位（16 个分支×2bit）
bht_ipdp_pre_array_data_ntake[31:0]   — not-taken 表的 32 位
bht_ipdp_sel_array_result[1:0]        — 选择表的 2-bit 计数器
bht_ipdp_pre_offset_onehot[15:0]      — 由 PC 低位与 GHR 低位哈希得到的计数器 one-hot 编号
bht_ipdp_vghr[21:0]                   — 当前 VGHR，供 IP 级更新
```

IP 级（ipdp）用 `sel_array_result[1]`（MSB）决定用 taken 还是 not-taken 表，取对应的 2-bit 计数器 MSB 作为最终跳转方向预测。

### 6.5 Write Buffer

BHT 写回必须等 SRAM 无读操作时才能进行（同一周期 SRAM 不能同时读写）。Write Buffer（4 项队列）暂存待更新条目，趁读操作间隙批量写回。

**Bypass**：如果 Write Buffer 中有命中当前读地址的条目，直接用 Write Buffer 里的最新值（不读 SRAM），保证时序一致性。

**写更新条件**：只有计数器不处于饱和状态且分支结果需要改变时才写，否则跳过（节省功耗）。

---

## 7. RAS — 返回地址栈

**文件**：`ct_ifu_ras.v`（1930 行）

### 7.1 原理

函数调用（`jal ra, offset`）和返回（`jalr x0, ra, 0`）是固定的配对模式：
- **call**：把返回地址 PC+4 压栈（Push）
- **ret**：弹出栈顶地址作为跳转目标（Pop）

RAS 专门预测这类模式。正常配对的 call/ret 通常具有很高可预测性，但深度
溢出、非标准链接寄存器用法和投机恢复都会造成失败，RTL 本身不能给出固定精度。

### 7.2 结构

```
RAS 物理状态：12 个投机栈项 + 6 个退休恢复项
  IFU 栈深度：12 项（投机 push/pop，直接用于预测）
  RTU 恢复副本：6 项（提交后确认，按最近窗口选择性复制回 12 项栈）

每项内容：
  pc[38:0]           — 返回地址
  priv_mode[1:0]     — 当时的特权级（M/S/U）
  filled             — 有效位
```

### 7.3 指针设计

```verilog
reg [4:0] top_ptr;    // IFU 侧指针，5 位（bit[4] 为奇偶标志）
// 满/空判断：top_ptr == status_ptr 为空，top_ptr 循环一圈为满

// 环绕：不是简单 mod 16，而是 mod 12（12 项）
// 当 top_ptr[3:0] == 11（最后一项）时，翻转 bit[4]，低 4 位归 0
```

**5 位指针的作用**：12 项的栈不能只比较 4-bit 位置判断满/空。第 5 位是
环绕位：两个指针完全相同表示空；低 4 位相同且环绕位相反表示满。不能把
12+6 简单理解成“可连续预测 18 层调用”，实际投机栈深度是 12。

### 7.4 Push/Pop

```verilog
assign ras_push = ibctrl_ras_pcall_vld && !ras_full;   // call 指令触发 push
assign ras_pop  = ibctrl_ras_preturn_vld && !ras_empty; // ret 指令触发 pop

// 输出当前栈顶（预测返回地址）
assign ras_ipdp_pc      = ras_entry[top_ptr[3:0]].pc;
assign ras_ipdp_data_vld = !ras_empty;
```

---

## 8. icache_if — I-Cache 接口

**文件**：`ct_ifu_icache_if.v`（832 行）

### 8.1 SRAM 组织

```
I-Cache 逻辑阵列（5 组）：

Tag Array（1个，59 位宽）
  格式：[58:FIFO][57:29:Way1 valid+tag28][28:0:Way0 valid+tag28]

Data Array0（Way0，1个，按 4-bank 分割）
  bank0~3 各 32 位，共 128 位/行（= 1 个 16 字节取指块）
  1 条 64 字节 cache line 占 4 个连续数据行

Data Array1（Way1，同 Data Array0 结构）

Predecode Array0（Way0 预解码，1个，32 位宽）
Predecode Array1（Way1 预解码，1个，32 位宽）
```

### 8.2 Index 仲裁

正常取指时 pcgen 直接驱动 index；以下情况会抢占（高优先级）：

```
优先级（高→低）：
  1. ifctrl 特殊请求（fence.i/inv）
  2. ifctrl 复位清零
  3. L1 refill 填充
  4. IPB（预取缓冲）请求
  5. ifctrl 数据读
  6. pcgen 正常取指（默认）
```

### 8.3 Tag Array 写入规则

```
写时机               valid bit   tag bit
─────────────────   ─────────   ───────
INV 时               0           0
Refill 第一包         0           0        ← 先清 valid，防止部分数据被命中
Refill 最后一包       1           真实 tag  ← 数据完整后才置有效
```

**FIFO 替换**：`wen[1:0] = {!fifo_bit, fifo_bit}`，即 fifo_bit=0 时写 Way0，fifo_bit=1 时写 Way1；每次 Refill 完成后翻转 fifo_bit，实现轮转替换。

### 8.4 Data Array Bank 精确激活

每个数据行由 4 个 32 位 bank 组成。对普通高优先级改流和顺序取指，4 个 bank
全部读取；对 IP 级已知目标的预测改流，pcgen 检查内部目标
`taken_pc[2:1]`（对应字节地址 `[3:2]`），关闭目标 32 位字之前的 bank，只读取
从目标所在 bank 到 bank3 的有效后缀。因而实际可关闭 0～3 个 bank，节省量取决于
目标在 16 字节取指块中的位置，并非固定 75%。

### 8.5 Predecode Array

指令从总线取回时，`l1_refill` 模块**顺手做预解码**（`l1_refill_icache_if_pre_code[31:0]`），连同指令数据一起写入 Predecode Array。

下次命中 Cache 时，IP 级直接读到预解码结果，无需在 hit 路径重新计算同一组
边界/类型提示。每 32 位 precode 对应一个 16 字节取指块中 8 个半字的类型信息；
是否缩短完整周期取决于最终流水边界和综合时序。

---

## 9. precode — 预解码

**文件**：`ct_ifu_precode.v`（320 行）

### 9.1 职责

纯组合逻辑，将 128 位指令数据压缩为 32 位预解码结果，供 Predecode Array 存储和 IP 级使用。

### 9.2 编码格式

```
32 位 precode = 8 个 half-word × 4 bit

每个 half-word 的 4 bit 含义：
  [3] ab_br   — 绝对分支（jal / c.j），target 可直接计算
  [2] br      — 任意分支（含条件分支）
  [1] bry1    — 假设本 half-word 不是指令起点时的边界标记
  [0] bry0    — 假设本 half-word 是指令起点时的边界标记
```

**bry 位的作用**：RISC-V 支持 16 位压缩指令（RVC），一个 16 字节取指块内
哪些半字是指令起点取决于前序指令长度。`bry0/bry1` 预先计算两种可能的边界
情况，IP 级根据跨块 H0 状态和实际起始对齐选用合适的 bry 值。

### 9.3 分支类型检测

```verilog
// 无条件跳转（JAL）
assign h1_ab_br = (h1_data[6:0] == 7'b1101111) ||       // RV jal
                  ({h1_data[15:13],h1_data[1:0]} == 5'b10101); // C.J

// 条件分支
assign h1_br = (h1_data[6:0] == 7'b1100011) ||  // beq/bne/blt/bge 等
               ({h1_data[15:13],h1_data[1:0]} == 5'b11101) || // C.BEQZ
               ({h1_data[15:13],h1_data[1:0]} == 5'b11111);   // C.BNEZ
```

---

## 10. ifctrl / ifdp — IF 级控制与数据通路

### 10.1 IF 级在流水线中的位置

```
pcgen → [IF 级] → IP 级 → IB 级
          ↑
          I-Cache Tag/Data 读出结果在这里处理
```

IF 级是 I-Cache 访问的**结果处理级**：
- 接收 icache_if 读出的 tag + data
- 做虚实地址 tag 比较，判断 hit/miss
- 向 IP 级传递指令数据和命中信息

### 10.2 ifctrl 的核心职责

**文件**：`ct_ifu_ifctrl.v`（1396 行）

1. **Stall 生成**：整合来自 IP 级、L1 refill、L0 BTB 等的 stall 请求
2. **Cancel 传播**：把来自 pcgen 的 cancel 信号向下传播
3. **I-Cache Invalidation 状态机**：处理 fence.i、软件 inv 操作

**IF 级 stall 来源汇总**：
```verilog
assign if_stage_stall = ipctrl_ifctrl_stall      // IP 级拥塞
                      || l1_refill_ifctrl_ctc    // refill 占用 I-Cache
                      || ifctrl_l0_btb_stall;    // L0 BTB 查询等待
```

**Invalidation 状态机**：
```
全量/复位路径：IDLE → READ_REQ → READ_RD → READ_ST/INV_ALL → IDLE
按地址路径：    INS_TAG_REQ → INS_TAG_RD → INS_CMP → INS_INV/INS_INV_ALL
```

当前 RTL 共有 10 个编码状态，同时支持全量失效和按地址/tag 检查后的局部失效。
各状态的精确分支条件应以 `ct_ifu_ifctrl.v:748~757` 及后续 next-state 逻辑为准。

### 10.3 ifdp 的核心职责

**文件**：`ct_ifu_ifdp.v`（2085 行）

ifdp 是 IF 级的数据通路，主要工作：

**Tag 比较**：
```
物理地址 PA（来自 MMU）的 tag 部分
  vs
icache 读出的 way0_tag / way1_tag

命中（hit）= valid && (PA_tag == stored_tag)
```

输出到 IP 级的关键信号：
```
ifdp_ipctrl_vpc_2_0_onehot[7:0]   — 内部 PC[2:0]（字节 PC[3:1]）的 one-hot
ifdp_ipctrl_vpc_bry_mask[7:0]     — 有效的分支位掩码
ifdp_ipctrl_way0_X_hit            — Way0 各段的命中信息
ifdp_ipctrl_way1_X_hit            — Way1 命中信息
```

**BRY 候选与流水寄存**：

ifdp 不维护“32 项 × 8-bit BRY 数组”。它从两路 Predecode Array 取得各
32-bit precode，拆出 `way0/way1 × bry0/bry1` 四组 8-bit 候选，在 IF/IP
流水寄存器中保存并由 `ipctrl` 回写更新。这里的 32-bit 是一个 16-byte
取指块的预解码信息，不是 32 个表项。

---

## 11. ipctrl / ipdp — IP 级控制与数据通路

### 11.1 IP 级的核心使命

IP 级是 IFU 中**最关键的决策级**：收到 IF 级的指令数据和 BTB/BHT 预测结果，决定：
1. 本取指窗口内哪条是分支指令？
2. 这条分支跳不跳？（BHT 决定）
3. 跳到哪里？（BTB/L0-BTB/RAS/计算）
4. 是否需要发起 chgflw（改变流向）通知 pcgen？

### 11.2 ipctrl 的核心职责

**文件**：`ct_ifu_ipctrl.v`（2022 行）

**分支碰撞检测**：一个取指窗口（128 位）里可能有多条分支，ipctrl 找到第一条有效分支，后面的指令暂时压住不送出：

```verilog
assign ipctrl_ipdp_br_more_than_one_stall = (hit_cnt > 3'b001);
// 有多条分支命中时 stall，等第一条处理完再继续
```

**BTB Miss 处理**：
```verilog
// L0 BTB miss 且 L1 refill 忙时，不能再发起新 miss 请求，必须 stall
assign ipctrl_ifctrl_stall = (ipctrl_ibctrl_l0_btb_miss && l1_refill_ipctrl_busy);
```

**关键输出**：
```
ipctrl_pcgen_chgflw_pcload    — 通知 pcgen 切换 PC（分支预测跳转）
ipctrl_pcgen_reissue_pcload   — 通知 pcgen 重发（way 预测出错）
ipctrl_l1_refill_miss_req     — 发起 I-Cache miss 请求
ipctrl_btb_chgflw_vld         — 通知 BTB 记录当前命中状态
```

### 11.3 ipdp 的核心职责

**文件**：`ct_ifu_ipdp.v`（6872 行，IFU 最大文件）

ipdp 执行 IP 级的数据处理，是全 IFU 逻辑最密集的模块：

**指令解析（H0~H8）**：

将取指窗口中 8 个 half-word（H1~H8）逐个解析，每个 H 暂存：
```
inst[31:0]      — 32 位指令内容
cur_pc[38:0]    — 指令的半字地址 PC，即架构字节 PC[39:1]
target[38:0]    — 预测的跳转目标
offset[20:0]    — 分支 offset（原始字段）
con_br          — 是否条件分支
vld             — 是否有效指令
```

**目标 PC 选择优先级**：
```
btb 命中         → 用 BTB target
  ↓ 未命中
l0_btb 命中      → 用 L0 BTB target
  ↓ 未命中
ret 指令         → 用 RAS 栈顶地址
  ↓ 其他
由 offset 计算   → cur_pc + sign_extend(offset)
```

**分支预测最终决策**：
```
1. sel_array_result[1] 决定用 taken 表还是 not-taken 表
2. 对应表的 2-bit 计数器 MSB 为预测方向
3. MSB=1 → taken（发起 chgflw，告知 pcgen 跳转）
4. MSB=0 → not-taken（继续顺序取指）
```

---

## 12. ibctrl / ibdp — IB 级控制与数据通路

### 12.1 IB 级的核心使命

IB 级是 IFU 流水线的**出口**，负责：
1. 将 IP 级的指令打包，写入 IBUF
2. 管理 IBUF 与 LBUF（Loop Buffer）的仲裁
3. 检测并处理分支预测的进一步确认（addrgen 级）
4. 检测 RAS push/pop（call/ret 指令识别）

### 12.2 ibctrl 核心逻辑

**文件**：`ct_ifu_ibctrl.v`（986 行）

**Change Flow 决策**（IB 级的两个来源）：
```verilog
assign chgflw_vld = (ibuf_inst_vld && ibuf_chgflw)     ? 1'b1 :  // IBUF 里有分支
                    (lbuf_active && lbuf_chgflw)        ? 1'b1 : 1'b0;

// PC 选择：错误恢复 > 循环缓存 > 指令缓存
assign ibctrl_pcgen_pc = (ib_addr_cancel && mispred) ? ibdp_default_pc :
                         (lbuf_chgflw)               ? lbuf_chgflw_pc :
                                                       ibdp_vpc;
```

**RAS 操作检测**：
```verilog
// 识别 call 指令（JAL rd≠x0，或 JALR rd=ra）→ 触发 RAS push
assign ibctrl_ras_pcall_vld   = ibdp_hn_pcall_vld && !ib_cancel;
// 识别 ret 指令（JALR x0, ra, 0）→ 触发 RAS pop
assign ibctrl_ras_preturn_vld = ibdp_hn_preturn_vld && !ib_cancel;
```

间接跳转的等待控制不是 `ct_ifu_ind_btb.v` 内部的两态 FSM。该模块发起同步
SRAM 查询并锁存结果；IB 级通过 `ind_btb_rd_state` 记录查询是否已经发起，
在结果尚不可用时形成 `ind_btb_stall`。完整路径历史、索引、更新和恢复机制见
[17_ind_btb.md](17_ind_btb.md)。

### 12.3 ibdp 的数据通路

ibdp（IB 级数据通路）负责将指令信息格式化，准备写入 IBUF。

关键输出到 IBUF 的信号包含每条指令的：
- 指令内容（32 位）
- 当前 PC
- 预测目标 PC
- 异常信息（访问错误、页错误）
- 特殊标记（断点、fence、是否为向量指令等）

---

## 13. ibuf — 指令缓冲队列

**文件**：`ct_ifu_ibuf.v`（9623 行，IFU 最复杂文件）

### 13.1 为什么需要 IBUF？

取指速率和译码速率可能不匹配：
- I-Cache Miss 时取指停顿，但 IDU 可能仍在消费之前缓存的指令
- 一个 16-byte 取指块最多带来 8 个新 half-word，叠加跨块 H0 时 IBUF 写入口
  最多处理 9 个 half-word；IDU 接口最多接收 3 条完整指令

IBUF 作为**弹性缓冲**，解耦取指和译码的速率差异，使两端都能满负荷运行。

### 13.2 结构

```
IBUF = 32 个 Entry（FIFO，ENTRY_NUM=32），每 Entry 存一个 16 位 half-word
（C 扩展令指令边界按 16 位对齐，故按 half-word 而非整指令组织）。
32 个 half-word ≈ 最多 16 条 32 位指令；向译码侧每拍最多送出 3 条指令。
（每 Entry 的精确字段与指针管理见本目录 13_ibuf.md，为权威详述）

读出/译码侧接口（送往 IDU，非单个 Entry 的存储布局）：
  inst0/1/2[31:0]  — 每拍最多 3 条指令
  vpc[38:0]        — 起始 PC
  hn_acc_err / hn_pgflt — 各 half-word 的访问错误 / 页故障标记
  branch 相关信息  — 由 ibdp 随指令送出
```

### 13.3 Bypass Path（直通路径）

当 IBUF 为空且 IDU 无 stall 时，IP 级的指令可以**绕过 IBUF**直接送给 IDU，减少一拍延迟：

```verilog
assign bypass_inst_valid = ibdp_inst0_valid && !bypass_not_select;
assign read_inst0 = bypass_inst_valid ? bypass_inst0 : stored_inst0;
assign read_inst1 = bypass_inst_valid ? bypass_inst1 : stored_inst1;
```

Bypass 条件：IBUF 空 + IDU 未 stall + 指令有效。

### 13.4 队列管理

IBUF 使用 32-bit one-hot create/retire pointer 和两组 5-bit 模 32 计数。
`ibuf_full` 检查从当前 create pointer 开始的 9 个候选写位置是否已有 valid，
为最坏 9-half-word 写入预留空间；`ibuf_empty` 比较 create/retire 计数，并
用 `entry_vld[0]` 区分“模 32 后相等”的全满与全空。详见
[13_ibuf.md](13_ibuf.md) 第 3 节。

### 13.5 特殊指令处理

IBUF 为每条指令维护额外标记位：
- **Breakpoint**：硬件断点命中标记，送 HAD 模块
- **Fence**：fence/fence.i 指令标记，影响后续取指和 Cache 操作
- **Split**：长指令（向量指令等）需要拆分，IBUF 记录拆分状态

---

## 14. lbuf — 循环缓冲

**文件**：`ct_ifu_lbuf.v`（6954 行）

### 14.1 设计动机

程序中频繁出现小循环（循环体只有几条指令）。Loop Buffer 把已捕获的循环
half-word 保存在本地 Entry 中，ACTIVE 期间由这些 Entry 承担功能上的指令供给，
从而减少正常 I-Cache 取数及其延迟暴露。BHT 查询、PCGEN、失效/flush 和前端控制
仍可能活动，是否完全关闭某个 SRAM 时钟还取决于当拍请求和 ICG 实现，不能概括成
“整个循环期间 I-Cache 与预测器都停止工作”。

### 14.2 状态机

```
IDLE ──[ibctrl_lbuf_create_vld]──▶ ACTIVE（开始填充循环体）
  │
ACTIVE ──[检测到回边（loop back）]──▶ CACHE（循环体已完整缓存）
  │    ──[ibctrl_lbuf_flush]────────▶ IDLE
  │
CACHE ──[循环出口 && BHT 不再预测跳转]──▶ READY（退出循环）
  │
READY ──[ibctrl_lbuf_retire_vld]──▶ IDLE（循环体消费完毕）
```

- **ACTIVE**：将循环体逐条写入 lbuf entry
- **CACHE**：检测到回边（跳转回循环头），锁定为有效循环
- **READY**：BHT 预测"不跳"（循环结束条件满足）时退出

### 14.3 关键特性

- lbuf 激活时（`lbuf_ibctrel_lbuf_active=1`），IBUF 停止取 I-Cache
- lbuf 自带分支预测状态（`front_br_bht_pre_result[1:0]`），维护循环内的 BHT 状态
- lbuf 满或检测到不规则跳转时退回 IDLE，退化为普通取指

---

## 15. addrgen — 分支地址生成

**文件**：`ct_ifu_addrgen.v`（306 行）

### 15.1 职责

addrgen 在 **IB 级之后（IB+1）**工作，是 IFU 对直接控制流目标的后一级验证阶段：

```
IP 级记录预测改流目标
  → IB 级识别预测 taken 条件分支或 JAL/C.J，并下传 PC 与立即数
  → ADDRGEN 复算 PC-relative 目标
  → 必要时纠正 PC、请求 BTB refill buffer 更新，或使错误的 L0 BTB 项失效
```

主要工作：
1. 对预测 taken 条件分支和 JAL/C.J 计算 PC-relative 目标（PC + sign_extend(offset)）
2. 与 IP 级记录的预测改流目标比较，检测直接目标不一致
3. 不一致时向 PCGEN 发出纠错，并把更新信息提交给 BTB refill buffer
4. 若错误来源是已有 L0 BTB 命中项，则用命中独热码清除该项有效位；ADDRGEN
   不负责向 L0 BTB 写入完整正确目标

### 15.2 目标地址计算

```verilog
// 21 位 offset 符号扩展到 39 位
assign branch_offset[38:0] = {{19{ibdp_branch_offset[20]}},
                              ibdp_branch_offset[20:1]};
// 目标 = 当前 PC + offset
assign branch_cal_result[38:0] = branch_base[38:0] + branch_offset[38:0];
```

### 15.3 Misprediction 检测

```verilog
assign branch_mispred = (branch_pred_result[38:0] != branch_cal_result[38:0]);
```

如果 mispred，addrgen 通知 pcgen 发起 chgflw（优先级 5），同时更新 BTB/L0-BTB。

### 15.4 BTB Entry 格式（写入时）

```verilog
// BTB 格式：10-bit TAG | 20-bit TARGET | 2-bit PRED | 1-bit CNT | 1-bit RAS
assign addrgen_btb_target_pc[19:0] = addrgen_cal_result_flop[19:0];
assign addrgen_btb_index[9:0]      = ibdp_btb_index_pc[12:3];
assign addrgen_btb_tag[9:0]        = {ibdp_btb_index_pc[19:13],
                                      ibdp_btb_index_pc[2:0]};
```

---

## 16. l1_refill — L1 Cache 缺失填充

**文件**：`ct_ifu_l1_refill.v`（793 行）

### 16.1 职责

处理 I-Cache Miss 的完整生命周期：向 L2 Cache（通过 BIU）发起取数请求，等待数据返回，将数据写入 I-Cache。

### 16.2 状态机

```
IDLE ──[miss req]──▶ REQ（向 BIU 发请求）
  │
REQ ──[biu_grant]──▶ WFD1（等待第 1 包数据，128 bit）
  │ ──[chgflw]────▶ IDLE（取消 refill）
  │
WFD1 ──[data_vld]──▶ WFD2 ──▶ WFD3 ──▶ WFD4（接收 4 包数据，共 512 bit）
  │（任意 WFDn 期间发生 chgflw → INV_WFDn，先接收完数据再无效化）
  │
WFD4 ──[最后一包]──▶ IDLE（数据写入 I-Cache，refill 完成）
```

**INV_WFDn 状态**：如果 chgflw 在 refill 进行中发生，不能立刻丢弃（L2 已经开始传输），必须继续接收完所有数据，然后把刚填入的数据也无效化（INV），再回到 IDLE。

### 16.3 数据接收与写入

```verilog
// 4 包 128 位数据接收完毕后触发 cache 写
wire cache_write_vld = (refill_cur_state == WFD4) && ipb_refill_data_vld;

// 输出给 icache_if
assign l1_refill_icache_if_inst_data = ipb_l1_refill_rdata[127:0];  // 指令数据
assign l1_refill_icache_if_ptag      = physical_pc[38:11];           // 架构 PA[39:12]
assign l1_refill_icache_if_index     = virtual_pc[38:0];             // 半字地址形式的写入地址
```

`l1_refill_icache_if_first=1` 时写入时先清 valid；`l1_refill_icache_if_last=1` 时才置 valid（即上文 icache_if 的写入规则）。

---

## 17. IFU 完整数据流串讲

### 17.1 正常顺序取指（无分支）

```
周期 N：
  pcgen: if_pc = current_pc → 送 index 给 I-Cache、BTB、BHT
  BTB: index → SRAM 开始读（1 拍延迟）
  I-Cache: index → Tag+Data SRAM 开始读（1 拍延迟）

周期 N+1（IF 级）：
  I-Cache: tag_dout + data_dout 就绪
  BTB: btb_rd_flop=1，tag_dout/data_dout 就绪
  ifdp: 用 MMU 翻译得到的 PA 做 tag 比较，判断命中
  命中 → 指令数据 + precode 送往 IP 级
  BHT sel_array: index → 开始读（1 拍延迟）

周期 N+2（IP 级）：
  ipdp: 收到 8 个 half-word + BTB 4 路命中信息 + BHT sel 数据
  ipctrl: 识别是否有分支，BTB/BHT 无命中 → 不发起 chgflw
  指令打包 → IB 级

周期 N+3（IB 级）：
  ibctrl/ibdp: 格式化指令 → 写入 IBUF

周期 N+4：
  IBUF 输出指令 → IDU 开始译码
```

**总延迟**：pcgen 到 IDU 约 4 拍（无 miss、无分支、无 stall）。

### 17.2 分支预测跳转（BTB 命中）

```
周期 N：
  pcgen: 送 index → BTB 开始读

周期 N+1（IF 级）：
  BTB: 读出 4 路 tag + target
  ifdp: tag 比较，某路命中 → btb_hit_target 就绪

周期 N+2（IP 级）：
  ipctrl: BHT 预测方向 taken
  ipdp: 选用 BTB target 作为跳转目标
  ipctrl_pcgen_chgflw_pcload = 1 → 通知 pcgen 切换到 target

周期 N+2 同拍（pcgen）：
  if_pc ← btb_target（chgflw 优先级高于顺序推进）
  新 index 送 I-Cache、BTB → 下一取指从目标地址开始
```

### 17.3 分支预测失败（IU 纠错）

```
周期 M（IU 执行阶段）：
  iu_ifu_chgflw_vld = 1
  iu_ifu_chgflw_pc  = 正确目标地址

周期 M（pcgen 同拍响应）：
  优先级 4：iu_ifu_chgflw 胜出
  if_pc ← 正确地址
  pcgen_ifctrl_cancel = 1   → 冲刷 IF 级
  pcgen_ipctrl_cancel = 1   → 冲刷 IP 级
  pcgen_ibctrl_cancel = 1   → 冲刷 IB 级

周期 M+1：
  重新从正确地址开始取指
  BHT Write Buffer 写入本次分支的真实结果（更新预测器）
  BTB Refill Buffer 写入正确 target
```

### 17.4 I-Cache Miss

```
IP 级检测到 I-Cache miss（tag 比较失败）：
  ipctrl_l1_refill_miss_req = 1
  ipctrl_l1_refill_vpc      = miss 的虚地址
  ifctrl_pcgen_stall = 1  → pcgen 暂停（PC 冻结）

l1_refill 模块：
  → 向 BIU/L2 发请求（ipb 模块）
  → 等待 4 包 × 128 bit = 512 bit 数据返回；间隔和总延迟由 BIU/L2/外存响应决定
  → 数据写入 I-Cache（Tag Array + Data Array + Predecode Array）
  → l1_refill_ifctrl_idle = 1 → stall 解除

pcgen 恢复取指，重新从 miss 地址取指（此时命中 Cache）
```

---

## 18. 关键设计决策汇总

### 18.1 分级分支预测

| 预测器 | 容量 | 延迟 | 精度 | 覆盖范围 |
|--------|------|------|------|----------|
| L0 BTB | 16 个寄存器项 | PCGEN 组合查找、结果打拍 | 目标预测 | 热点控制流 |
| BTB | 512 行×4 个固定位置槽 | 同步 SRAM 流水读取 | 目标/way 预测 | 普通直接控制流 |
| BHT（Bi-Mode）| 64 Kibit Predict + 2 Kibit Select | SRAM 读取并流水到 IPDP | 方向预测 | 条件分支 |
| Indirect BTB | 256×23-bit | 同步 SRAM 查询并锁存 | 间接目标预测 | `jalr` 等 |
| RAS | 12 项投机栈 + 6 项恢复副本 | 寄存器读与流水选择 | 返回目标预测 | call/return |

### 18.2 功耗优化技术

| 技术 | 实现位置 | 节省效果 |
|------|----------|----------|
| Way Predict | pcgen → icache_if | 在资格条件满足时只使能预测路的数据阵列；预测错误会触发 stall/reissue |
| Bank 精确激活 | pcgen → icache_if | 减少不需要的 Data SRAM bank 翻转；节能比例需门级功耗分析 |
| ICG（门控时钟）| 预测器、Cache 阵列及控制寄存器的多条局部路径 | RTL 提供 local/module/scan enable；物理停钟与功耗收益取决于 ICG 宏和实现 |
| Predecode Array | icache_if | 保存指令边界/控制流预编码，减少后续级重复计算这些早期属性 |
| Loop Buffer | lbuf | ACTIVE 时由本地 Entry 提供循环指令，减少正常 I-Cache 供给访问；BHT 和前端控制仍参与 |

### 18.3 面积优化技术

| 技术 | 实现 | 说明 |
|------|------|------|
| PC 高位分离 | pcgen | 常用内部 PC 保存 `[39:1]`，异常高位只在特殊改流场景暂存；实际面积收益需综合证明 |
| BTB Refill Buffer | btb | 避免频繁 SRAM 写，简化控制 |
| 两路轮转替换 | icache_if | 每组保存 1 位替换状态，不维护完整 LRU 顺序；该位不是 tag |
| RAS 5 位环形指针 | ras | 低 4 位选 16 个物理位置，附加 wrap 位参与满/空与覆盖关系判断 |

### 18.4 关键权衡

**Bypass vs 队列**：IBUF 支持 bypass path（绕过队列直达 IDU），在 IBUF 空时减少延迟，代价是控制逻辑复杂性增加。

**投机更新 vs 精确更新**：VGHR 在 IP 级投机更新（可能错），RTUGHR 在 RTU 退休时精确更新。预测出错时 VGHR 从 RTUGHR 恢复，以精度换吞吐量。

**L0 BTB 容量 vs 速度**：L0 BTB 只有 16 项（全寄存器，组合命中），容量有限但速度最快。主 BTB 使用 512 行 SRAM，每行读出 4 个由 PC 位置决定的槽，需要 1 拍 SRAM 延迟。分级设计让进入 L0 BTB 的近期分支避开主 BTB 的读延迟。

---

## 附录：关键信号速查表

| 信号 | 方向 | 含义 |
|------|------|------|
| `rtu_ifu_chgflw_vld/pc` | RTU→IFU | 异常/中断返回，最高优先级改变流向 |
| `iu_ifu_chgflw_vld/pc` | IU→IFU | 分支预测失败纠错 |
| `pcgen_ifctrl_cancel` | pcgen→ifctrl | 冲刷 IF 级 |
| `pcgen_ipctrl_cancel` | pcgen→ipctrl | 冲刷 IP 级 |
| `ipctrl_pcgen_chgflw_pcload` | ipctrl→pcgen | BTB/BHT 预测跳转 |
| `ifctrl_pcgen_stall` | ifctrl→pcgen | IF 级拥塞，PC 冻结 |
| `cp0_ifu_btb_en` | CP0→IFU | BTB 全局使能 |
| `cp0_ifu_bht_en` | CP0→IFU | BHT 全局使能 |
| `ifu_mmu_va/vld/abort` | IFU→MMU | 投机性地址翻译请求 |
| `l1_refill_ifctrl_idle` | l1_refill→ifctrl | Refill 完成，解除 stall |
| `btb_ifdp_wayX_*` | BTB→ifdp | BTB 4 路读出数据 |
| `bht_ipdp_pre_array_data_*` | BHT→ipdp | BHT 预测数组数据 |
| `ras_ipdp_pc/data_vld` | RAS→ipdp | RAS 栈顶返回地址 |
| `ibctrl_ras_pcall/preturn_vld` | ibctrl→RAS | 触发 RAS push/pop |
| `addrgen_btb_update_vld` | addrgen→BTB | 更新 BTB 条目 |
| `pcgen_icache_if_way_pred[1:0]` | pcgen→icache | I-Cache way 预测 |
| `ifu_hpcp_icache_access/miss` | IFU→PMU | 性能计数器（命中/缺失） |
| `sfp_ifdp_pc_hit/hit_type` | SFP→IFDP | no-spec 或 VL 预测命中及类型 |
| `ipb_debug_req_cur_st/wb_cur_st` | IPB→debug | 预取请求/回放状态 |
| `vector_pcgen_pcload/pc` | vector→pcgen | 装载复位或异常入口 PC |
| `ifu_had_debug_info[82:0]` | IFU→HAD | JDBREQ 时采样的 IFU 状态快照 |

---

*文档版本：基于 OpenC910 开源代码（Apache-2.0）*
*覆盖文件：ct_ifu_top.v 及其下属全部 22 个子模块*
