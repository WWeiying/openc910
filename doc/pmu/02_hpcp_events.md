# C910 PMU 事件选择与多 bit 加法器 模块详细教学文档

> RTL 文件：
> - `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_event.v`（103 行）—— 事件选择寄存器 `mhpmeventN`
> - `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_adder_sel.v`（260 行）—— 按事件号选出"本拍增量"的 42 选 1 MUX
> - 事件增量（adder）的**产生**逻辑位于 `ct_hpcp_top.v` 第 1412~1463 行，本文一并讲解

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [事件选择寄存器 mhpmeventN（ct_hpcp_event）](#4-事件选择寄存器-mhpmeventnct_hpcp_event)
5. [超标量的痛点：为什么一拍要能加多于 1](#5-超标量的痛点为什么一拍要能加多于-1)
6. [42 个事件增量的产生（ct_hpcp_top.v 1412~1463）](#6-42-个事件增量的产生ct_hpcp_topv-14121463)
7. [42 选 1 加法器 MUX（ct_hpcp_adder_sel）](#7-42-选-1-加法器-muxct_hpcp_adder_sel)
8. [42 种事件完整清单与分类](#8-42-种事件完整清单与分类)
9. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

PMU 的可编程计数器（HPM3~HPM18）每个都要回答一个问题："本周期我应该 +几？"这个"+几"由两步决定：

1. **选哪种事件**：软件把一个 6 位的事件号写进 `mhpmeventN` CSR，由 `ct_hpcp_event` 模块保存。
2. **该事件本拍发生了几次**：C910 是 3 发射退休 / 多发射执行的超标量核，同一周期内一个事件（例如"条件分支退休"）可能发生 0、1、2 甚至 3 次。`ct_hpcp_top` 为每种事件预先算出一个 **4 位增量 `eventNN_adder`**，再由 `ct_hpcp_adder_sel` 这个 42 选 1 MUX 按事件号选出当前计数器对应的增量 `mhpmcntx_adder[3:0]`，最终送给计数器累加。

这两个模块合在一起，构成了 PMU "事件 → 增量" 的数据通路。

### 1.2 两个核心设计点

- **事件号合法性过滤**：`ct_hpcp_event` 写入时会检查事件号是否 ≤ 42（`HPMCNT_NUM`），非法值写 0，避免计数器选到未定义事件（`ct_hpcp_event.v:93`）。
- **多 bit 加法器**：增量是 4 位而非 1 位。这是超标量 PMU 的关键——如果每拍最多只能 +1，那么在一拍退休 3 条分支时会丢掉 2 次计数，导致统计严重失真。C910 的事件增量用真正的加法把同周期多次事件累加进 4 位（`ct_hpcp_top.v:1419` 等）。

---

## 2. 端口说明

### 2.1 ct_hpcp_event 端口（`ct_hpcp_event.v:17~36`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `forever_cpuclk` | input | 1 | 自由运行时钟 |
| `cpurst_b` | input | 1 | 低有效复位 |
| `cp0_hpcp_icg_en` | input | 1 | 模块级门控时钟使能 |
| `pad_yy_icg_scan_en` | input | 1 | DFT 扫描时强开门控 |
| `eventx_clk_en` | input | 1 | 本事件寄存器局部门控使能（=本寄存器 wen） |
| `eventx_wen` | input | 1 | 写使能（来自 `ct_hpcp_top` 的 `mhpmevtN_wen`） |
| `hpcp_wdata[63:0]` | input | 64 | CSR 写数据 |
| `eventx_value[63:0]` | output | 64 | 当前事件号（高位补 0，低 6 位有效） |

### 2.2 ct_hpcp_adder_sel 端口（`ct_hpcp_adder_sel.v:17~108`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `event01_adder` ~ `event42_adder` | input | 各 4 | 42 种事件本拍各自的增量（0~max） |
| `mhpmevtx_value[63:0]` | input | 64 | 本计数器的事件号（取低 6 位 `[5:0]` 做选择） |
| `mhpmcntx_adder[3:0]` | output | 4 | 选出的增量，送给对应 `ct_hpcp_cnt` |

注意：本模块是**纯组合逻辑**（一个大 `case`），没有时钟也没有复位。

---

## 3. 参数与关键寄存器

两文件都定义了同一对参数（`ct_hpcp_event.v:55~56`、`ct_hpcp_adder_sel` 通过实例化复用）：

| 参数 | 值 | 含义 |
|------|----|----|
| `HPMCNT_NUM` | 42 | 事件总数（也是事件号合法上限） |
| `HPMEVT_WIDTH` | 6 | 事件号位宽（6 位可表示 0~63，足够 42 种） |

`ct_hpcp_event` 内唯一的状态：

| 寄存器 | 宽度 | 行号 | 含义 |
|--------|------|------|------|
| `value` | 6 | `ct_hpcp_event.v:39` | 当前事件号（`mhpmeventN` 的低 6 位） |

事件号为 0 表示"不计任何事件"。`ct_hpcp_top.v:1300` 用 `(|mhpmevtN_value[5:0])` 判断事件号非 0 才允许该计数器计数——即事件号 0 等价于关掉这个可编程计数器。

---

## 4. 事件选择寄存器 mhpmeventN（ct_hpcp_event）

C910 把 16 个可编程计数器（HPM3~HPM18，对应 `mhpmevt3`~`mhpmevt18`）的事件号寄存器做成同一个 `ct_hpcp_event` 模块的 16 次例化（`ct_hpcp_top.v:3451` 起，到 `x_hpcp_mhpmevent18`）。

### 4.1 写入逻辑与合法性过滤

核心代码（`ct_hpcp_event.v:83~94`）：

```verilog
always @(posedge eventx_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    value[HPMEVT_WIDTH-1:0] <= {HPMEVT_WIDTH{1'b0}};
  else if(eventx_wen)
    value[HPMEVT_WIDTH-1:0] <= hpcp_wdata[HPMEVT_WIDTH-1:0] & {HPMEVT_WIDTH{value_mask}} ;
  else
    value[HPMEVT_WIDTH-1:0] <= value[HPMEVT_WIDTH-1:0];
end

assign value_mask = (!(|hpcp_wdata[63:HPMEVT_WIDTH]))
                 && (hpcp_wdata[HPMEVT_WIDTH-1:0] <= HPMCNT_NUM);
```

**是什么**：写 `mhpmeventN` 时，先用 `value_mask` 检查两件事：
1. `hpcp_wdata[63:6]` 全为 0（高位不能有杂散位）；
2. 低 6 位数值 ≤ 42。

只要任一条件不满足，`value_mask=0`，写入的事件号被按位与成全 0（即写 0 = 关闭该计数器）。

**为什么**：事件号被直接拿去做 `ct_hpcp_adder_sel` 的 `case` 选择子。若允许写入 43~63 这类未定义事件号，MUX 会落到 `default` 分支输出 `4'bxxxx`（`ct_hpcp_adder_sel.v:250`），把不定值灌进计数器加法器，仿真/逻辑都会出错。在源头做合法性裁剪，比在每个使用点防护更省逻辑也更安全。

### 4.2 输出

`ct_hpcp_event.v:97`：

```verilog
assign eventx_value[63:0] = {{64-HPMEVT_WIDTH{1'b0}},value[HPMEVT_WIDTH-1:0]};
```

读 `mhpmeventN` CSR 时返回的就是这个高位补 0 的 64 位值。

---

## 5. 超标量的痛点：为什么一拍要能加多于 1

在一个标量（每拍最多退休 1 条指令）核里，任何"按指令计数"的事件每周期最多发生一次，计数器每拍 +0 或 +1 就够了。

C910 不是标量核：

- 退休侧（RTU）一拍最多反馈 **3 条**退休指令（`rtu_hpcp_inst0/1/2_*`）；
- 译码 / 重命名侧（IDU）一拍最多反馈 **4 条**指令的类型（`hpcp_ir_inst0/1/2/3_*`）；
- 寄存器读发射侧一拍最多 **8 条**流水（`pipe0~7`）。

如果计数器每拍只能 +1，那么"一拍退休 3 条条件分支"只会被记成 1 次，长时间运行后 MPKI、分支占比这类派生指标会被系统性低估，性能分析失去意义。

C910 的解决办法：**每个事件的增量是把同周期所有来源加起来的一个多 bit 数**。例如条件分支事件（event07）：

```verilog
// ct_hpcp_top.v:1419
assign event07_adder[3:0] = {3'b0,inst0_condbr} + {3'b0,inst1_condbr} + {3'b0,inst2_condbr};
```

一拍退休 3 条条件分支时 `event07_adder = 3`，计数器一次 +3，毫无损失。增量位宽取 4 位，足以容纳本设计中最大的同周期来源数 8（event20/event22 的 8 路流水）。

计数器侧的累加见 `ct_hpcp_cnt.v:140`：`counter_adder = counter + cnt_adder_ff[3:0]`（详见 `01_hpcp_counters.md`）。

---

## 6. 42 个事件增量的产生（ct_hpcp_top.v 1412~1463）

`ct_hpcp_top` 在第 1412~1463 行集中产生全部 42 个 `eventNN_adder[3:0]`。按"来源数"可分三类：

**(a) 单来源、最多 +1**：增量就是某个 1 bit 事件信号补到 4 位，例如

```verilog
assign event01_adder[3:0] = {3'b0,hpcp_icache_access};   // ICache 访问
assign event02_adder[3:0] = {3'b0,hpcp_icache_miss};     // ICache 缺失
assign event06_adder[3:0] = {3'b0,bht_mispred};          // BHT 预测失误
```

**(b) 多来源退休/译码事件、可 +0~3 或 +0~4**：把同周期多条指令的对应信号相加，例如

```verilog
assign event07_adder[3:0] = {3'b0,inst0_condbr}+{3'b0,inst1_condbr}+{3'b0,inst2_condbr};      // 条件分支 0~3
assign event29_adder[3:0] = {3'b0,ir_inst0_alu}+{3'b0,ir_inst1_alu}+{3'b0,ir_inst2_alu}+{3'b0,ir_inst3_alu}; // ALU 0~4
```

**(c) 8 路流水事件、可 +0~8**：寄存器读发射的 latch fail / 有效指令，是位宽必须 4 位的根本原因：

```verilog
// ct_hpcp_top.v:1437
assign event20_adder[3:0] = {3'b0,pipe0_lch_fail}+...+{3'b0,pipe7_lch_fail}; // 0~8
assign event22_adder[3:0] = {3'b0,pipe0_inst_vld}+...+{3'b0,pipe7_inst_vld}; // 0~8
```

**(d) 双来源**：例如非对齐访存 `event34`（`lsu_hpcp_unalign_inst[1:0]`，0~2），跨 4K stall `event23`（load+store，0~2）。

**(e) 恒 0 的占位事件**：L2 cache 的 4 个事件 event16~19 在核内被 tie 到 0（`ct_hpcp_top.v:1429~1432`），因为 L2 计数器由 CIU/BIU 维护，不在本 PMU 里累加：

```verilog
assign event16_adder[3:0] = 4'b0;   // L2 read access  -> 由 CIU 维护
assign event17_adder[3:0] = 4'b0;   // L2 read miss
assign event18_adder[3:0] = 4'b0;   // L2 write access
assign event19_adder[3:0] = 4'b0;   // L2 write miss
```

L2 事件走的是另一条"借道某个可编程计数器索引、把请求发到 BIU、由 L2 返回计数值"的路径（见 `03_hpcp_top.md` 的 L2 交互一节），所以核内增量为 0。

`ir_instN_xxx` 这一族（event29~33、37、42）的译码类型来自 7 位 `hpcp_ir_instN_type`，解码规则见 `ct_hpcp_top.v:1375~1402`，例如 ALU = `type[0] && !type[2] && !type[6]`（排除向量/浮点）。

---

## 7. 42 选 1 加法器 MUX（ct_hpcp_adder_sel）

每个可编程计数器配一个 `ct_hpcp_adder_sel` 实例（`ct_hpcp_top.v:1469` 起的 `x_ct_hpcp_adder_sel_3`~`_18`），把 42 个 `eventNN_adder` 全部接进去，用本计数器的事件号 `mhpmevtx_value[5:0]` 选一个出来。

核心 `case`（`ct_hpcp_adder_sel.v:207~251`）：

```verilog
case(mhpmevtx_value[5:0])
  6'd1   : mhpmcntx_adder[3:0] = event01_adder[3:0];
  6'd2   : mhpmcntx_adder[3:0] = event02_adder[3:0];
  ...
  6'd42  : mhpmcntx_adder[3:0] = event42_adder[3:0];
  default: mhpmcntx_adder[3:0] = {4{1'bx}};
endcase
```

**是什么**：一个 42 路、每路 4 位的多路选择器。事件号 1~42 各对应一个增量，事件号 0 不在 case 列举中（会落入 default 给出 x，但此时计数器使能 `mhpmcntN_en` 因 `(|mhpmevtN_value)`=0 而关闭，x 不会被采样进计数器，是安全的）。

**为什么用独立模块多次例化**：16 个可编程计数器逻辑完全一样，做成一个模块例化 16 次，既减少代码量也保证一致性；同时把这块大 MUX 从顶层切出，综合时更容易复用/平衡。

---

## 8. 42 种事件完整清单与分类

下表来自 `ct_hpcp_top.v:1413~1463` 的 `eventNN_adder` 赋值，事件号即 `ct_hpcp_adder_sel.v` 的 `case` 选择子。增量上限指同周期最多累加数。

| 事件号 | 名称（信号） | 来源单元 | 增量上限 | 行号 | 用途 |
|-------|-------------|---------|---------|------|------|
| 1 | ICache 访问 `hpcp_icache_access` | IFU | 1 | 1413 | I$ 命中率分母 |
| 2 | ICache 缺失 `hpcp_icache_miss` | IFU | 1 | 1414 | I$ MPKI |
| 3 | IUTLB 缺失 | MMU | 1 | 1415 | 取指 TLB |
| 4 | DUTLB 缺失 | MMU | 1 | 1416 | 访存 TLB |
| 5 | JTLB 缺失 | MMU | 1 | 1417 | 联合 TLB |
| 6 | BHT 预测失误 `bht_mispred` | RTU | 1 | 1418 | 方向预测误判 |
| 7 | 条件分支退休 `condbr` | RTU | 3 | 1419 | 分支占比 |
| 8 | 间接跳转预测失误 `jmp_mispred` | RTU | 1 | 1420 | 目标误判 |
| 9 | 跳转指令退休 `jmp` | RTU | 3 | 1421 | 跳转占比 |
| 10 | 投机失败 `spec_fail` | RTU | 1 | 1422 | 流水冲刷 |
| 11 | store 退休 | RTU | 3 | 1423 | 写访存占比 |
| 12 | DCache 读访问 | LSU | 1 | 1424 | D$ 读命中率分母 |
| 13 | DCache 读缺失 | LSU | 1 | 1425 | D$ 读 MPKI |
| 14 | DCache 写访问 | LSU | 1 | 1426 | D$ 写命中率分母 |
| 15 | DCache 写缺失 | LSU | 1 | 1427 | D$ 写 MPKI |
| 16 | L2 读访问（核内 tie 0） | CIU/BIU | 0 | 1429 | L2 由 CIU 计 |
| 17 | L2 读缺失（核内 tie 0） | CIU/BIU | 0 | 1430 | 同上 |
| 18 | L2 写访问（核内 tie 0） | CIU/BIU | 0 | 1431 | 同上 |
| 19 | L2 写缺失（核内 tie 0） | CIU/BIU | 0 | 1432 | 同上 |
| 20 | RF 流水 latch fail（8 路） | IDU | 8 | 1437 | 发射阻塞 |
| 21 | RF 流水 reg latch fail（3 路） | IDU | 3 | 1440 | 寄存器冲突 |
| 22 | RF 流水有效指令（8 路） | IDU | 8 | 1441 | 发射带宽 |
| 23 | load/store 跨 4K stall | LSU | 2 | 1444 | 跨页惩罚 |
| 24 | load/store 其它 stall | LSU | 2 | 1445 | 访存阻塞 |
| 25 | SQ discard（replay） | LSU | 1 | 1446 | store 队列重放 |
| 26 | SQ data discard | LSU | 1 | 1447 | 数据重放 |
| 27 | 分支目标（BTB）预测失误 | IFU | 1 | 1448 | BTB 误判 |
| 28 | 分支目标（BTB）命中指令 | IFU | 1 | 1449 | BTB 覆盖 |
| 29 | ALU 指令退休/译码（4 路） | IDU | 4 | 1450 | 指令混合 |
| 30 | load/store 指令（4 路） | IDU | 4 | 1451 | 指令混合 |
| 31 | 向量指令（4 路） | IDU | 4 | 1452 | 指令混合 |
| 32 | CSR 指令（4 路） | IDU | 4 | 1453 | 指令混合 |
| 33 | 同步指令 sync（4 路） | IDU | 4 | 1454 | 屏障开销 |
| 34 | 非对齐访存指令 | LSU | 2 | 1455 | 非对齐惩罚 |
| 35 | 中断响应 `int_ack_vld` | RTU | 1 | 1456 | 中断频率 |
| 36 | 中断禁用周期 `int_disable` | CP0 | 1 | 1457 | 关中断窗口 |
| 37 | ecall/异常入口指令（4 路） | IDU | 4 | 1458 | 系统调用 |
| 38 | 长跳转（>8M offset，3 路） | RTU | 3 | 1459 | 远跳转 |
| 39 | 前端 stall `frontend_stall` | IFU | 1 | 1460 | 前端瓶颈 |
| 40 | 后端 stall `backend_stall` | IDU | 1 | 1461 | 后端瓶颈 |
| 41 | fence/sync stall | LSU/IDU | 1 | 1462 | 屏障停顿 |
| 42 | 浮点指令（4 路） | IDU | 4 | 1463 | 指令混合 |

固定计数器（不经事件 MUX）：

| 计数器 | 增量来源 | 行号 | 说明 |
|--------|---------|------|------|
| mcycle | 恒 `4'b1` | `ct_hpcp_top.v:1321` | 每拍 +1，周期数 |
| minstret | 0~6 累加 | `ct_hpcp_top.v:1330` | 退休指令数，按 `instN_num` 加权（一条可代表多个 RVC 等） |

---

## 设计取舍小结

- **6 位事件号 + 写时合法性裁剪**：6 位足够 42 种事件，留有余量；在写寄存器时就把非法事件号清 0（`ct_hpcp_event.v:88,93`），把不定值堵在源头，比下游逐点防护更经济。
- **4 位增量而非 1 位**：这是超标量 PMU 的命门。退休最多 3 路、译码 4 路、发射 8 路，若每拍只能 +1 必然计数失真；用真加法器把同周期事件累加成 0~8 的 4 位增量（`ct_hpcp_top.v:1419/1437`），保证统计精确。
- **42 选 1 MUX 独立成模块并多次例化**：16 个可编程计数器共享同一段大 MUX 逻辑（`ct_hpcp_adder_sel`），代码一致、综合友好；事件号 0 不进 case，配合计数器使能门控，default 的 x 不会污染结果。
- **L2 事件在核内 tie 0**：L2 计数器物理上在 CIU/BIU，PMU 只做"借索引转发"的代理，核内增量恒 0（`ct_hpcp_top.v:1429~1432`），避免重复计数。

---

*文档覆盖 ct_hpcp_event.v 全部 103 行逻辑、ct_hpcp_adder_sel.v 全部 260 行逻辑，并含 ct_hpcp_top.v 中事件增量产生（1412~1463 行）的相关逻辑。*
