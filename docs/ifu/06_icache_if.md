# ct_ifu_icache_if — I-Cache 接口模块深度解析

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_icache_if.v`（832 行）
>
> 本文对该模块全部逻辑做逐段解读，并解释每个设计决策背后的原因。

---

## 目录

1. [模块概述](#1-模块概述)
2. [Array 逻辑组织与 SRAM 映射](#2-array-逻辑组织与-sram-映射)
3. [Index 选择与互斥契约](#3-index-选择与互斥契约)
4. [Tag Array 控制逻辑](#4-tag-array-控制逻辑)
5. [Data Array 控制逻辑](#5-data-array-控制逻辑)
6. [Predecode Array 控制逻辑](#6-predecode-array-控制逻辑)
7. [数据输出路径](#7-数据输出路径)
8. [PMU 性能计数](#8-pmu-性能计数)
9. [完整信号汇总表](#9-完整信号汇总表)

---

## 1. 模块概述

### 1.1 在 IFU 流水线中的位置

```
                    ┌───────────────────────────────────────────────────┐
                    │              ct_ifu_icache_if                     │
                    │                                                   │
  pcgen ───index──▶ │                                                   │
  ifctrl──index──▶ │   ┌─────────────┐   ┌────────────────────────┐   │
  ipb ─────index──▶ │   │  Tag Array  │   │  Data Array0 (Way0)    │   │──▶ ifdp
  l1_refill──wr──▶  │   │  (59bit)    │   │  4 banks × 32bit       │   │──▶ ifctrl
                    │   └─────────────┘   ├────────────────────────┤   │──▶ ipb
                    │                     │  Data Array1 (Way1)    │   │
                    │                     │  4 banks × 32bit       │   │
                    │                     ├────────────────────────┤   │
                    │                     │  Predecode Array0/1    │   │
                    │                     │  32bit each            │   │
                    │                     └────────────────────────┘   │
                    └───────────────────────────────────────────────────┘
```

### 1.2 职责与边界

`ct_ifu_icache_if` 是 IFU 控制/数据通路与五组 I-Cache array wrapper 之间的集中
适配层。这里的“接口”不是纯连线：模块会形成共享 index、逐 array/逐 bank 的
`cen_b`、写掩码、写数据和本地时钟使能，并把 SRAM 输出扇出给不同消费者。
其主要职责是：

1. **选择共享地址**：pcgen 是默认地址来源；IFCTRL cache 管理、refill、IPB
   预取检查和 CP0 cache-read 属于 higher-request 类。higher 类内部依赖上游
   one-hot 互斥，不是一个能处理任意并发请求的优先级仲裁器。
2. **生成 SRAM 操作条件**：区分 Tag、两路 Data、两路 Predecode，进一步对
   Data Array 的四个 32-bit bank 独立生成 `cen_b` 和 clock-enable。
3. **控制 refill 提交**：首 beat 先清替换 way 的 valid，末 beat 才写入物理
   tag、置 valid 并翻转替换位。
4. **路由读出结果**：正常取指结果送 IFDP，预取 tag 检查送 IPB，CP0 显式
   cache-read 所需的 tag/data 送 IFCTRL。

该模块本身不在 SRAM `Q` 与输出之间再插一组流水寄存器，输出直接连接 array
wrapper 的 `Q`。但 wrapper 可映射到 TSMC SRAM 或 FPGA memory，具体宏的读
时序由所选实现决定；IFU 控制按带时钟的单端口存储器协议安排请求和后续流水级。
因此不能把它描述成“异步读端口”。

### 1.3 为什么需要这一层？

如果各模块分别驱动 SRAM wrapper，就会在多个位置重复地址复用、片选、写掩码和
时钟使能规则。集中到 `icache_if` 后：

- 各来源遵守既定时序和互斥契约，接口层统一形成 SRAM 引脚；
- `cen_b` 决定该次宏访问是否有效，`clk_en` 决定相应 wrapper 的本地时钟条件，
  两者职责不同，不能只观察其中一根就判定发生了 SRAM 读写；
- Data Array 可按 way 和 32-bit bank 控制活动范围，Tag/Predecode 则按各自的
  物理组织控制。

这里不能反向推出“接口层会自动解决所有请求冲突”。higher 类请求若错误地同时
拉高，`icache_index_sel` 会落入 `default: 'x`，这正是在仿真中暴露违反 one-hot
契约的方式。

---

## 2. Array 逻辑组织与 SRAM 映射

### 2.1 五个 array wrapper 实例一览

| `ct_ifu_icache_if` 中的实例 | Wrapper 模块 | 逻辑数据行 | 用途 |
|---|---|---|---|
| `x_ct_ifu_icache_tag_array` | `ct_ifu_icache_tag_array` | 59 位 | 存储两路的 valid+tag，以及 FIFO 替换位 |
| `x_ct_ifu_icache_data_array0` | `ct_ifu_icache_data_array0` | 每个数据行由 4 个 32-bit bank 并行组成，共 128 bit | Way0 的指令数据 |
| `x_ct_ifu_icache_data_array1` | `ct_ifu_icache_data_array1` | 每个数据行由 4 个 32-bit bank 并行组成，共 128 bit | Way1 的指令数据 |
| `x_ct_ifu_icache_predecd_array0` | `ct_ifu_icache_predecd_array0` | 每个数据行 32 bit | Way0 的预解码结果 |
| `x_ct_ifu_icache_predecd_array1` | `ct_ifu_icache_predecd_array1` | 每个数据行 32 bit | Way1 的预解码结果 |

C910 的 I-Cache 是**2-way set-associative**，Way0 对应 array0，Way1 对应 array1。

这里列出的是五个 wrapper，而不是五个底层 SRAM 宏。以非 ECC 的
`ICACHE_64K` 分支为例，Tag wrapper 例化一个 512×59 宏；每个 Data wrapper
例化四个 2048×32 bank 宏；每个 Predecode wrapper 例化一个逻辑上的
2048×32 宏。因此从 RTL 存储组织看是 1 个 Tag、8 个 Data bank、2 个
Predecode 存储体。具体库单元可能使用 `_split` 宏或在综合/FPGA 映射中进一步
拆分，物理宏数量和面积必须以目标实现报告为准。

### 2.2 Tag Array 的 59 位格式

Tag Array 的架构有效载荷是 59 bit，每个 entry 存储**一个 cache set** 的全部
元数据。启用 `L1_CACHE_ECC` 时 wrapper 选择 61-bit 宏变体，但本文下列字段仍
按 IFU 可见的 59-bit payload 解释：

```
  bit[58]       bit[57:29]              bit[28:0]
┌──────────┬────────────────────────┬────────────────────────┐
│ FIFO bit │   Way1: valid[57]+     │   Way0: valid[28]+     │
│  (1 bit) │   tag[56:29] (28 bit)  │   tag[27:0]  (28 bit)  │
└──────────┴────────────────────────┴────────────────────────┘
```

**为什么用一个 SRAM 同时存两路的 tag？**

因为正常 VIPT 查找需要并行比较两路 tag，一次 Tag Array 访问即可同时得到两路
`valid+tag` 和替换位。相比把两路拆成两个独立宏，这种组织减少一个独立 array
控制端口；实际面积、时序和功耗优劣仍取决于 SRAM 宏实现，不能仅凭 RTL 断言
一定“更省功耗”。

**28 位 tag 从哪来？**

C910 的架构物理字节地址是 `PA[39:0]`，但 `l1_refill` 内部的 `physical_pc[38:0]` 保存 `PA[39:1]`。因此：

- 64 字节 cache line 的字节偏移是架构 PA `[5:0]`；
- RTL `physical_pc[38:11]` 实际对应架构 PA `[39:12]`，形成 28 位 `l1_refill_icache_if_ptag`；
- 在当前 `ICACHE_64K` 配置下，Tag Array 的 SRAM 地址取内部 VPC `[13:5]`，对应架构虚拟字节地址 `[14:6]`。

这里是 VIPT 访问，物理 tag 和虚拟 set index 不是简单互斥切分同一根地址总线；阅读 RTL 时必须先把内部半字地址位号换算成架构字节地址位号。

**FIFO bit 的作用：**

C910 I-Cache 的替换状态是每个 set 的 1-bit FIFO 位。RTL 没有维护访问顺序所需
的 LRU/伪 LRU 树，因此应称为 FIFO 选择，而不是“FIFO/伪 LRU”：
- `fifo_bit = 0`：下次替换 Way0（写入 array0）
- `fifo_bit = 1`：下次替换 Way1（写入 array1）

每次正常四-beat refill 的末 beat（`l1_refill_icache_if_last`），Tag Array 把
FIFO bit 写成此次锁存替换位的反值，使下一次同 set 替换选择另一路。

### 2.3 Data Array 的 4-bank 结构

每路的 Data Array 被分成 4 个 **32 位** bank（bank0～bank3）。4 个 bank 使用
同一个数据行地址，拼成一次 128 位、16 字节的取指块：

```text
bank0[31:0] + bank1[31:0] + bank2[31:0] + bank3[31:0]
                         = 128 bit = 16 byte
```

一条 64 字节 cache line 因此占用 4 个连续的数据行；Tag Array 按 64 字节行
寻址，Data Array 则按 16 字节取指块寻址。

这里的 128-bit 是 **Data Array 一行的读出宽度**。PCGEN 正常 `inc_pc` 对
内部半字地址的 `[38:3]` 加 1，并把 `[2:0]` 清零；当当前 PC 位于块首时，
内部数值增加 8 个半字单位，对应架构字节 PC 前进 16 byte。改流目标可以落在
块内任一 half-word，第一次顺序推进则会对齐到下一个 16-byte block。IFDP/IPDP
结合 PC 低位、指令边界和跨块信息使用这 128-bit 数据。阅读吞吐波形时仍需区分
“SRAM 一行的读出宽度”“当前块内从哪个 half-word 开始有效”和“实际送往后端的
指令条数”。

- **顺序访问（sequential）**：在被 `way_pred` 选中的 way 中激活全部 4 个
  bank，一次得到完整 128-bit 取指块；
- **换流（change flow）**：当改流来源是 IPCTRL 的预测 taken 且没有更高改流
  覆盖时，可关闭目标位置之前的 32-bit bank，只读取从目标所在 bank 到块末尾
  的有效后缀；对 IU/RTU/HAD/vector 等更高来源，PCGEN 将四个 bank 请求均置 1。

具体 lane 对应关系是 `bank0=D[127:96]`、`bank1=D[95:64]`、
`bank2=D[63:32]`、`bank3=D[31:0]`。结合 refill 模块把最低地址 half-word
放在 128-bit 总线高端的布局，bank0 对应该块最低地址的 4 byte，bank3 对应
最高地址的 4 byte。这种组织为 IP 级提供一个 8-half-word 的 array 数据块；
它不表示这 8 个 half-word 每拍都会作为新指令全部送往后端。预测目标位于块中部
时，还可关闭目标之前的 bank。

### 2.4 Predecode Array 的 32 位格式

每个 Predecode Array entry 存储对应 Data Array entry 中 8 个 half-word 的预解码结果：

```
bit[31:0]: {h1_pre_code[3:0], h2_pre_code[3:0], ..., h8_pre_code[3:0]}
```

每个 half-word 对应 4 位：`{ab_br, br, bry1, bry0}`（详见 07_precode.md）。

---

## 3. Index 选择与互斥契约

### 3.1 整体设计思路

五组 array wrapper 共用 `ifu_icache_index[15:0]`。地址选择分为两层：

```text
higher-request 类是否存在？
├─ 否：使用 pcgen_icache_if_index
└─ 是：higher 类必须恰好 one-hot
       ├─ IFCTRL tag/invalidation 或 reset
       ├─ L1 refill 写
       ├─ IPB prefetch tag 检查
       └─ IFCTRL/CP0 cache-read
```

因此源码中确实存在“higher 类覆盖 pcgen”的二级关系，但 higher 类内部**没有**
按列表顺序逐项抢占的 priority encoder。`case` 只识别 `1000/0100/0010/0001`；
两个 higher 请求同时为 1 时，不会选“更高优先级”的那个，而是输出 `16'hxxxx`。
源码注释也明确写着四类条件不会同时置位。

从体系结构上看，这种实现把请求冲突的避免责任放到 IFCTRL、L1-refill、IPB 和
PCGEN 的状态机协同上。它减少接口层的选择逻辑，但验证时必须检查 one-hot
不变量；“能在正常系统运行中互斥”与“本模块含硬件仲裁器”是两件不同的事。

### 3.2 两路选择器结构

```verilog
// 第 616-626 行
assign ifu_icache_index[15:0] = (icache_req_higher)
                              ? icache_index_higher[15:0]
                              : pcgen_icache_if_index[15:0];

assign icache_req_higher = ifctrl_icache_if_tag_req          ||
                           ifctrl_icache_if_reset_req        ||
                           l1_refill_icache_if_wr            ||
                           ipb_icache_if_req                 ||
                           ifctrl_icache_if_read_req_data0   ||
                           ifctrl_icache_if_read_req_data1   ||
                           ifctrl_icache_if_read_req_tag;
```

`icache_req_higher` 只回答“是否存在任一 higher 请求”。它不编码请求来源，也
不解决 higher 请求之间的冲突。为 0 时选 pcgen；为 1 时选
`icache_index_higher`。

源码注释称该结构使用 AND/OR 逻辑节省时序。可以确定的 RTL 事实是：pcgen
地址只经过最外层 2:1 选择，而 higher 地址先经过 one-hot `case` 组合。至于
综合后是否减少门级深度、改善多少时序，需要综合网表和 STA 证明；文档不把
源码设计意图当作已经量化的物理结论。

### 3.3 higher-request index 的四路 case 选择

```verilog
// 第 636-655 行
assign icache_index_sel[3:0] = {ifctrl_icache_if_tag_req || ifctrl_icache_if_reset_req,
                                l1_refill_icache_if_wr,
                                ipb_icache_if_req,
                                icache_read_req};
always @(*)
begin
  case(icache_index_sel[3:0])
    4'b1000: icache_index_higher[15:0] = ifctrl_icache_if_index[15:0];
    4'b0100: icache_index_higher[15:0] = l1_refill_icache_if_index[15:0];
    4'b0010: icache_index_higher[15:0] = {ipb_icache_if_index[10:0], 5'b0};
    4'b0001: icache_index_higher[15:0] = ifctrl_icache_if_read_req_index[15:0];
    default: icache_index_higher[15:0] = {16{1'bx}};
  endcase
end
```

**index 位宽与来源说明：**

| 来源 | 输入位宽 | 说明 |
|---|---|---|
| `ifctrl_icache_if_index` | 39 位 | 内部半字地址，取低 16 位；用于 IFCTRL invalidation/tag 操作 |
| `l1_refill_icache_if_index` | 39 位 | refill 当前 16-byte block 的内部半字地址，取低 16 位 |
| `ipb_icache_if_index` | 34 位 | IPB 保存的“下一条 64B line”虚拟字节地址 `[39:6]`；取低 11 位 `[16:6]` 后拼 5 个 0，形成 line-base 的内部地址 `[15:0]` |
| `ifctrl_icache_if_read_req_index` | 39 位 | CP0 cache-read 流程形成的内部半字地址，取低 16 位 |

**IPB index 为什么拼接 5 个 0？**

IPB 由 `l1_refill_ipb_vpc[39:6] + 1` 形成下一条 64B line 的虚拟 line number。
`icache_if` 取其低 11 位，即架构虚拟字节地址 `[16:6]`，再拼 `5'b0`，得到
内部半字地址 `[15:0]`，其架构含义为 `{VA[16:6], 6'b0}` 去掉最低恒为 0 的
字节位。这里是虚拟 index，不是 PA，也不能把全部 11 位都称作 set index：
在 `ICACHE_64K` 配置下 Tag SRAM 实际只消费内部 `[13:5]`，即架构
`VA[14:6]` 的 9-bit、512-set index。

**case default 为 `x`：**

当 `icache_index_sel=0000` 时，最外层 MUX 选择 pcgen，因此 higher 路的 `x`
不影响正常输出。若选择向量出现多热编码，`icache_req_higher=1` 而 `case`
进入 default，`x` 会传播到共享 index；它既可能给综合器 don't-care 优化空间，
也能在 RTL 仿真中暴露上游互斥条件被破坏。是否“保证 one-hot”应由接口协议和
断言验证，而不能由这段组合逻辑自身推出。

### 3.4 不同 array 实际消费哪些 index 位

`ifu_icache_index` 是去掉架构 PC bit0 的内部半字地址低 16 位。以当前
`ICACHE_64K` 配置为例：

| Array | SRAM 地址 | 架构虚拟字节地址含义 | 深度 |
|---|---|---|---:|
| Tag | `ifu_icache_index[13:5]` | `VA[14:6]`，64B line 的 set index | 512 |
| Data Way0/1 | `ifu_icache_index[13:3]` | `VA[14:4]`，16B block index | 2048 |
| Predecode Way0/1 | `ifu_icache_index[13:3]` | 与 Data 同一 16B block index | 2048 |

因此 Tag 每个 set 对应一条 64B line 的两路元数据，而每路 Data/Predecode 用
四个连续 block row 覆盖这一条 line。若改用 `ICACHE_32K/128K/256K`，wrapper
参数 `WIDTH` 会改变 SRAM 消费的最高 index 位，不能把 64K 配置的位号外推到
所有编译配置。

---

## 4. Tag Array 控制逻辑

### 4.1 cen_b 生成（Chip Enable）

`cen_b` 低有效，为 0 时激活 SRAM。Tag Array 在以下 6 种情况下需要激活：

```verilog
// 第 266-283 行
assign ifu_icache_tag_cen_b =
  !(l1_refill_icache_if_wr &&
    (l1_refill_icache_if_first || l1_refill_icache_if_last) &&
    cp0_ifu_icache_en
   ) &&                              // 情况1: refill 写（first 或 last beat）
  !(ifctrl_icache_if_tag_req
   ) &&                              // 情况2: ifctrl 的 tag 操作（无效化）
  !(pcgen_icache_if_chgflw &&
    (pcgen_icache_if_way_pred[1:0] != 2'b00) &&
    cp0_ifu_icache_en
   ) &&                              // 情况3: 换流读 tag（way_pred 非 0）
  !(pcgen_icache_if_seq_tag_req &&
    cp0_ifu_icache_en
   ) &&                              // 情况4: 顺序读 tag
  !(ipb_icache_if_req &&
    cp0_ifu_icache_en
   ) &&                              // 情况5: ipb 读 tag（prefetch 后比较）
  !ifctrl_icache_if_read_req_tag;   // 情况6: ifctrl 主动读 tag
```

**情况1 中为什么 refill 只在 first 和 last 激活 tag array？**

一个 cacheable line refill 有四个返回 beat，但 Tag Array 只在首、末两个有效
beat 访问：首 beat 清除所选 way 的旧 valid/tag，末 beat 写入新 tag/valid 和
更新后的替换位。中间两个 beat 只写 Data/Predecode Array。

**情况3 中 `way_pred != 2'b00` 的含义：**

`pcgen_icache_if_way_pred[1:0]` 是该拍计划激活的 way 位图：
- `2'b00`：当前没有可选 way。PCGEN/IFCTRL 另有 `way_pred_stall` 路径处理该
  情形；I-Cache 是否关闭由独立的 `cp0_ifu_icache_en` 决定，不能把 `00`
  直接等同于 cache disabled
- `2'b01`：预测选择 Way0
- `2'b10`：预测选择 Way1
- `2'b11`：两路都读；例如 CP0 关闭 instruction-way-prediction
  (`cp0_ifu_iwpe=0`) 时 PCGEN 明确使用 `11`

换流读 Tag 还要求 `cp0_ifu_icache_en=1`。因此“不访问 Tag Array”可能来自
cache 关闭、没有 way 被选中，或该拍根本没有 change-flow/tag 请求，必须联合
`cp0_ifu_icache_en`、请求类型和 way 位图判断。

### 4.2 wen 编码（Write Enable）

Tag array 的写使能是 3 位：`ifu_icache_tag_wen[2:0]`

```
ifu_icache_tag_wen[2]   → FIFO bit 的写使能
ifu_icache_tag_wen[1]   → Way1 的写使能
ifu_icache_tag_wen[0]   → Way0 的写使能
```

**FIFO bit wen（bit[2]）的逻辑：**

```verilog
// 第 305-317 行
always @(*)
begin
  if(ifctrl_icache_if_inv_on)
    ifu_icache_tag_wen[2] = ifctrl_icache_if_tag_wen[2];  // inv 时按 ifctrl 指示
  else if(l1_refill_icache_if_wr && l1_refill_icache_if_last)
    ifu_icache_tag_wen[2] = 1'b0;  // refill last：允许写 FIFO 字段
  else
    ifu_icache_tag_wen[2] = 1'b1;  // 默认屏蔽 FIFO 字段写入
end
```

虽然顶层信号名是 `ifu_icache_tag_wen` 而没有 `_b` 后缀，其语义仍是**低有效
bit-write mask**：wrapper 将三位展开成 59-bit `WEN`，并将三位与归约送
`GWEN`。所以 `wen[x]=1` 表示该字段保持，`wen[x]=0` 表示允许该字段写入。

refill last 时 `wen[2]=0`，允许更新 FIFO bit。refill first 时 `wen[2]=1`，
保持 FIFO bit 不变，因为首 beat 只需先隐藏被替换 way，不应提前改变下一次
替换选择。

**Way wen（bit[1:0]）的逻辑：**

```verilog
// 第 320-335 行
always @(*)
begin
  if(ifctrl_icache_if_inv_on)
    ifu_icache_tag_wen[1:0] = ifctrl_icache_if_tag_wen[1:0];  // inv 按 ifctrl 指示
  else if(l1_refill_icache_if_wr &&
           (l1_refill_icache_if_first || l1_refill_icache_if_last))
    ifu_icache_tag_wen[1:0] = {!fifo_bit, fifo_bit};  // 只写目标 way
  else
    ifu_icache_tag_wen[1:0] = 2'b11;  // 非写操作，两路都不写
end
```

`{!fifo_bit, fifo_bit}` 的解码：
- `fifo_bit = 0`（替换 Way0）：`wen[1:0] = 2'b10`，即 wen[1]=1（Way1 不写），wen[0]=0（Way0 写）
- `fifo_bit = 1`（替换 Way1）：`wen[1:0] = 2'b01`，即 wen[1]=0（Way1 写），wen[0]=1（Way0 不写）

**为什么这样编码？**

低有效写掩码中，`1` 表示不写，`0` 表示写。因此
`{!fifo_bit, fifo_bit}` 中恰好一位为 0，指向本次替换 way。这里的位序是
`wen[1]=Way1`、`wen[0]=Way0`：`fifo_bit=0` 得到 `2'b10` 并写 Way0，
`fifo_bit=1` 得到 `2'b01` 并写 Way1。

### 4.3 Refill 写入时序：防止伪命中的设计

这是一个精妙的设计，理解它需要考虑 refill 中途的场景：

```
返回事件顺序：
首 beat:  refill first（miss 地址对应的 critical 16B block 到达）
  → 写 tag：valid = 0，tag = 0（清零）
  → 写 data：第一个 128 位数据

中间 beat: 按 WRAP 顺序写另外两个 16B block，只写 data/predecode

末 beat:  refill last（WRAP 顺序的第 4 个有效 beat 到达）
  → 写 tag：valid = 1，tag = ptag（设置有效，写真实 tag）
  → 写 data：最后一个 128 位数据
  → 把 FIFO bit 写成锁存替换位的反值
```

这些 beat 不要求在连续 CPU 周期到达；WFD 状态会停留等待 `data_vld`。
此外首 beat 是 critical block，并不一定是 64B line 的最低地址 block，Data
Array 的 row 地址由 L1-refill 按 mod-4 WRAP 顺序推进。

**为什么 first beat 要先写 tag（valid=0）？**

如果不写，假设被替换 way 之前仍是 `valid=1`，那么 refill 期间本核 IFU
若再次访问到旧 tag，就可能把已被部分 16B block 覆盖的数据误当成完整
cache line。
L1 I-Cache 是本核私有结构，这里的竞争者是本核后续取指、改流或预取请求，
不是另一个 CPU 直接访问该 I-Cache。

通过在 first beat 把 valid 清 0，正常情况下该 way 在其余三个 block 写入期间
不会命中；直到 WFD4 的有效返回产生 `last`，末 block 与新 tag/valid 才在该次
写操作中提交。若中途 `trans_err` 进入 INV_WFD，`last` 不会产生，替换 way
保持无效。这里的完整性单位是 64B line，不是每个 16B block 各自有 valid。

```verilog
// 第 350-357 行
assign tag_fifo_din     = (ifctrl_icache_if_inv_on) ? ifctrl_icache_if_inv_fifo : !fifo_bit;
assign tag_valid_din    = l1_refill_icache_if_last;  // 只有 last beat，valid 才为 1
assign tag_pc_din[27:0] = (ifctrl_icache_if_inv_on || l1_refill_icache_if_first)
                          ? 28'b0          // inv 或 first：tag 清零
                          : l1_refill_icache_if_ptag[27:0];  // last：写真实 tag
```

`tag_valid_din = l1_refill_icache_if_last`：first beat 写 Tag Array 时
`valid_din=0`；只有第四个正常 data beat 产生 `last` 时，`valid_din=1`。

### 4.4 tag_din 格式组装

```verilog
// 第 354-357 行
assign ifu_icache_tag_din[58:0] = {tag_fifo_din,
                                   tag_valid_din, tag_pc_din[27:0],
                                   tag_valid_din, tag_pc_din[27:0]};
```

两路字段在 `ifu_icache_tag_din` 中承载相同的 `tag_valid_din/tag_pc_din`，
但低有效 `wen[1:0]` 只开放替换 way 的 29-bit 字段，另一字段保持原值。因此
“D 总线上两路字段相同”不等于“两路同时被写”；判断实际写入必须联合
`CEN/GWEN/WEN`。

---

## 5. Data Array 控制逻辑

### 5.1 way_pred 决定激活哪路

```verilog
// 第 370-372 行
assign icache_way_pred[1:0] = (l1_refill_icache_if_wr) ? 2'b11 : pcgen_icache_if_way_pred[1:0];
```

- **refill 写**时：内部 `icache_way_pred` 强制为 `2'b11`，避免 way-prediction
  屏蔽写路径；真正选择写 Way0 还是 Way1 的条件仍是锁存的 `fifo_bit`。
- **pcgen 正常读**时：使用 `pcgen_icache_if_way_pred`，bit0/bit1 分别参与
  Way0/Way1 的片选。

因此 `2'b11` 在 refill 路径上只是解除 way-pred gating，并不意味着两路 Data
Array 都写。Way0 的请求项要求 `wr && !fifo_bit`，Way1 要求
`wr && fifo_bit`，最终只有替换 way 的 `cen_b` 和 `wen_b` 同时进入写状态。

### 5.2 Bank 精确激活：节能设计

每路 data array 有 4 个 bank，各 bank 有独立的 `cen_b`。以 array0/bank0 为例：

```verilog
// 第 374-384 行
assign ifu_icache_data_array0_bank0_cen_b = (
    !(l1_refill_icache_if_wr && !fifo_bit) &&  // 不是写 way0
    !(pcgen_icache_if_chgflw_bank0        ) &&  // 不是换流且需要 bank0
    !(pcgen_icache_if_seq_data_req        )     // 不是顺序读
    || !(cp0_ifu_icache_en && icache_way_pred[0])  // 或 way0 未被预测
   ) &&
   !ifctrl_icache_if_read_req_data0 &&  // 不是 ifctrl 强制读 way0
   !icache_reset_inv;                   // 不是复位无效化
```

把低有效表达式还原成正逻辑后，Way0/bank0 被激活的条件是：

```text
ifctrl_read_way0
OR reset_clear
OR (
     icache_en
     AND selected_way0
     AND (refill_write_way0 OR chgflw_needs_bank0 OR sequential_data_read)
   )
```

其中 `selected_way0=icache_way_pred[0]`；refill 时该位被强制为 1，正常取指时
来自 PCGEN。IFCTRL 的 CP0 cache-read 和 reset-clear 是维护路径，所以不依赖
`cp0_ifu_icache_en` 或 PCGEN way prediction。

**各 bank 激活条件的差异：**

| 条件 | bank0 | bank1 | bank2 | bank3 |
|---|---|---|---|---|
| refill 写 | 目标 way 的四个 bank 全部激活，写当前 128-bit beat | 同左 | 同左 | 同左 |
| 换流（chgflw） | `chgflw_bank0` | `chgflw_bank1` | `chgflw_bank2` | `chgflw_bank3` |
| 顺序读（seq） | 全部激活 | 同左 | 同左 | 同左 |

`chgflw_bank0~3` 是 PCGEN 提供的 bank 请求位图。对 IPCTRL 预测 taken 路径，
其模式随目标内部 PC `[2:1]` 依次为 `1111/0111/0011/0001`，即从目标 32-bit
bank 一直打开到 bank3；对更高优先级改流，四位均为 1。该机制减少了部分改流
访问中的宏活动范围；实际动态功耗收益需要门级/功耗分析量化。

**为什么顺序读要激活全部 4 个 bank？**

顺序取指时，IP 级需要当前数据行中的完整 128 位取指块，因此必须把该行的
4 个 32 位 bank 全部激活。这不等于一次读取整条 64 字节 cache line。

### 5.3 Way0 vs Way1 的 cen_b 差异

array0（Way0）与 array1（Way1）的 cen_b 几乎相同，只有一处不同：

- **array0**：refill 写条件为 `l1_refill_icache_if_wr && !fifo_bit`（FIFO bit=0，替换 Way0）
- **array1**：refill 写条件为 `l1_refill_icache_if_wr && fifo_bit`（FIFO bit=1，替换 Way1）
- **array0**：way_pred 检查 `icache_way_pred[0]`
- **array1**：way_pred 检查 `icache_way_pred[1]`

这使 refill 只写目标 way；正常读则只激活 way-prediction 位图选中的 way。
“被预测选择”不等于最终 tag compare 一定命中，错误 way prediction 仍可能触发
stall/recovery。

### 5.4 Write Enable（wen_b，低有效）

```verilog
// 第 535-540 行
assign ifu_icache_data_array0_wen_b = !(l1_refill_icache_if_wr && !fifo_bit) &&
                                      !icache_reset_inv;
assign ifu_icache_data_array1_wen_b = !(l1_refill_icache_if_wr && fifo_bit) &&
                                      !icache_reset_inv;
```

每路 Data Array 共用一个低有效 `wen_b`，wrapper 再把它复制到四个 bank 的
32-bit `WEN`。因此一次选中写操作会把该 way 当前 row 的四个 bank、共 128 bit
全部写入；它不是按 byte 或 bank 独立写掩码。写使能条件：
1. **refill 写**：由 fifo_bit 决定写哪路；
2. **复位无效化**：`icache_reset_inv = ifctrl_icache_if_reset_req`，两路都写（写入 0）。

### 5.5 写数据（din）

```verilog
// 第 545-546 行
assign ifu_icache_data_array0_din[127:0] = (icache_reset_inv) ? 128'b0 : l1_refill_icache_if_inst_data[127:0];
assign ifu_icache_data_array1_din[127:0] = (icache_reset_inv) ? 128'b0 : l1_refill_icache_if_inst_data[127:0];
```

复位时写 0，正常 refill 时写从 L2 传来的 128 位指令数据。两路写入相同的 din，由 wen_b 决定实际写哪路。

---

## 6. Predecode Array 控制逻辑

### 6.1 与 Data Array 的对应关系

在正常 pcgen 取指、refill 和 reset-clear 路径上，Predecode Array 与对应 way 的
Data Array 使用相同的 block index 并协同访问：

- 正常读：跟随 `chgflw` 或 `seq_data_req`，按 way prediction 选择，但
  Predecode 不再细分四个 bank；
- refill：与 128-bit 指令数据同拍写入对应的 32-bit precode；
- reset-clear：两路 Predecode 与 Data 一样写 0；
- CP0 显式 cache-data read：只强制打开指定 Data way，**不**读取 Predecode，
  所以不能概括成所有情形下都“严格并行”。

```verilog
// 第 804-810 行（predecd_array0 实例化）
ct_ifu_icache_predecd_array0  x_ct_ifu_icache_predecd_array0 (
  .ifu_icache_data_array0_wen_b (ifu_icache_data_array0_wen_b),  // wrapper 的 GWEN
  .ifu_icache_predecd_array0_wen_b (ifu_icache_predecd_array0_wen_b),
  ...
);
```

### 6.2 Predecode Array 的 cen_b

```verilog
// 第 551-568 行
assign ifu_icache_predecd_array0_cen_b = (
    !(l1_refill_icache_if_wr && !fifo_bit) &&
    !(pcgen_icache_if_chgflw            ) &&  // 注意：不区分 bank！
    !(pcgen_icache_if_seq_data_req      )
    || !(cp0_ifu_icache_en && icache_way_pred[0])
   ) && !icache_reset_inv;
```

与 Data Array 的区别：换流条件使用 `pcgen_icache_if_chgflw`（整体换流标志），而不是 `chgflw_bank0~3`（逐 bank 标志）。

**为什么 Predecode Array 不需要 bank 精确激活？**

Predecode Array 每个数据行合计 32 位，而 Data Array 的同一数据行是
4×32=128 位。当前 RTL 没有再拆分 predecode bank；该选择减少了控制和宏数量，
具体功耗收益需以实现后的功耗分析量化。

### 6.3 为什么在 IP 级前就做预解码？

若 I-Cache 每次 hit 后都从 128-bit raw instruction 窗口重新推导压缩指令边界、
分支类型和跨块关系，这些组合逻辑会进入前端 hit 数据路径。C910 在 refill 时
预先生成并缓存轻量元数据：

1. **ct_ifu_precode** 对 L1-refill 返回的 128-bit 指令块生成 32-bit 预解码信息；
2. 预解码结果和指令数据一同缓存在 Predecode Array 中；
3. 在 IFDP/IPDP 数据通路中，预解码结果和指令数据同时读出，IP 级可以直接使用
   已缓存的类型/边界提示。`ct_ifu_ipb` 是预取缓冲，不是 IP 流水级。

对于 cacheable refill，预解码结果与数据一起写入 array，后续 hit 可直接读出。
`tsize=0` 的非缓存/Cache-disabled 返回不写 I-Cache，因此只通过 L1-refill 的
组合旁路携带本次 precode，不会在本 array 中持久保存。该设计减少 hit 路径上
重复识别分支边界/类型的逻辑；能否提高频率仍需结合综合时序判断。

### 6.4 `cen_b` 与 `clk_en` 必须联合观察

每个 wrapper 同时接收访问片选和本地时钟条件：

- `cen_b=0` 表示该 SRAM 宏在相应边沿执行一次有效读/写操作；
- `clk_en` 是送入 `gated_clk_cell.local_en` 的提前条件，保证潜在访问到来前
  wrapper 时钟可用；
- `wen/WEN/GWEN` 再区分这次有效访问是读、整行写还是字段写。

三类 array 的 local-enable 范围并不相同：

| Wrapper | `clk_en` 的主要来源 |
|---|---|
| Tag | IFCTRL tag/invalidation、CP0 tag-read，或 `icache_en && (refill_wr \|\| pcgen_gateclk_en \|\| ipb_req_for_gateclk)` |
| Data Way0 | `icache_en && (refill_wr_way0 \|\| chgflw_short \|\| seq_data_req_short)`，以及 CP0 Way0 data-read、reset-clear |
| Data Way1 | 与 Way0 对称，refill 条件改为 `refill_wr_way1` |
| Predecode Way0/1 | 正常/refill/reset 与对应 Data way 类似，但不含 CP0 data-read |

Data 每个 way 的四个 bank 虽然有独立 `cen_b`，却使用内容相同的
per-bank `clk_en` 表达式。以 IPCTRL 预测 taken 只需后缀 bank 为例，四个
wrapper clock 的 local-enable 可能都被 `chgflw_short` 打开，而不需要的前缀
bank 仍由 `cen_b=1` 阻止宏访问。因此“bank 未访问”和“bank wrapper 时钟没有
翻转”不是同一个判断。

通用 ICG 的技术分支还允许 `cp0_ifu_icg_en` 覆盖 local-enable。开源非技术分支
则直接把 `clk_in` 接到 `clk_out`。在 Verdi 中判断一次 I-Cache 行为时，建议
同时观察共享 index、目标 array 的 `cen_b`、`wen_b/WEN`、对应 `clk_en` 和宏
时钟；单看时钟波形无法确定宏是否完成了有效访问。

---

## 7. 数据输出路径

### 7.1 tag_dout 的分解

SRAM 读出 59 位 tag 数据后，立即被分解分发：

```verilog
// 第 662-668 行
assign icache_if_ifdp_tag_data0[28:0]   = icache_ifu_tag_dout[28:0];    // Way0 tag+valid
assign icache_if_ifdp_tag_data1[28:0]   = icache_ifu_tag_dout[57:29];   // Way1 tag+valid
assign icache_if_ifdp_fifo              = icache_ifu_tag_dout[58];       // FIFO bit
assign icache_if_ifctrl_tag_data0[28:0] = icache_ifu_tag_dout[28:0];    // Way0（给 ifctrl）
assign icache_if_ifctrl_tag_data1[28:0] = icache_ifu_tag_dout[57:29];   // Way1（给 ifctrl）
```

**29 位 tag 数据格式：**

```
bit[28]    : valid bit
bit[27:0]  : tag（内部物理半字地址 [38:11]，对应架构 PA[39:12]）
```

### 7.2 各下游模块接收的信号

| 下游模块 | 接收的信号 | 用途 |
|---|---|---|
| **ifdp** | tag_data0/1、fifo、inst_data0/1、precode0/1 | 正常 IF 数据通路；分段比较 MMU 物理 tag，形成 way hit，并把所选数据/预解码送后续级 |
| **ifctrl** | tag_data0/1、inst_data0/1 | CP0 显式 I-Cache tag/data read 状态机的读回数据；不是正常取指 hit compare 的执行位置 |
| **ipb** | tag_data0/1 | 比较“下一 line”预取候选的物理 tag，判断该 line 是否已在 I-Cache |

**为什么 IFCTRL 和 IFDP 都接收 Tag Array 输出？**

两者面对的是不同操作。IFDP 在正常取指路径中把两路 tag 与
`mmu_ifu_pa` 分段比较；IFCTRL 只在 `READ_REQ -> READ_RD -> READ_ST` 的 CP0
cache-read 流程中锁存 tag/data，再送 `ifu_cp0_icache_read_data`。`icache_if`
没有为这两组输出复制存储体，只是对同一 SRAM `Q` 做组合扇出；真正由谁消费，
取决于各自状态机和 valid。

### 7.3 precode 的输出

```verilog
// 第 673-677 行
assign icache_if_ifdp_precode0[31:0] = icache_ifu_predecd_array0_dout[31:0];
assign icache_if_ifdp_inst_data0[127:0] = icache_ifu_data_array0_dout[127:0];
assign icache_if_ifdp_precode1[31:0] = icache_ifu_predecd_array1_dout[31:0];
assign icache_if_ifdp_inst_data1[127:0] = icache_ifu_data_array1_dout[127:0];
```

预解码结果只送到 `ifdp`，不送给 `ifctrl` 或 `ipb`（这两个不需要预解码信息）。

---

## 8. PMU 性能计数

### 8.1 计数器信号

C910 内置 HPCP 性能计数路径，`icache_if` 对外提供两个打拍后的单周期事件：

- `ifu_hpcp_icache_access`：上一拍出现 pcgen sequence-data request 或
  change-flow request，且 I-Cache 使能
- `ifu_hpcp_icache_miss`：上一拍 L1-refill 处于 WFD1 且收到首个 data/error
  返回事件

它们是事件脉冲，不是本模块内部累加的数值寄存器；最终累计由 HPCP 完成。

### 8.2 access 事件的定义

```verilog
// 第 697 行
assign ifu_hpcp_icache_access_pre = (pcgen_icache_if_seq_data_req || pcgen_icache_if_chgflw) && cp0_ifu_icache_en;
```

**为什么只统计 pcgen 的请求，不统计 refill 或 ifctrl 的请求？**

这个事件只覆盖 PCGEN 发起的正常 I-Cache data 访问类，不包含 refill 写、IPB
tag 探测和 CP0 cache-read。`seq_data_req` 本身在 `!ifctrl_pcgen_stall` 时拉高，
所以该计数更接近“前端发出的 I-Cache data 访问拍数”，不是退休指令数、取回
字节数，也不是独立 cache line 数；change-flow 与 sequence 同拍时 OR 后仍只
产生一个 event。

### 8.3 miss 事件的精确定义

`ifu_hpcp_icache_miss_pre` 不在 `icache_if` 内计算，而来自
`ct_ifu_l1_refill`：

```verilog
assign ifu_hpcp_icache_miss_pre =
    (refill_cur_state == WFD1) &&
    (ipb_l1_refill_data_vld || ipb_l1_refill_trans_err);
```

所以它是在非取消的正常 WFD1 路径收到首个返回事件时记一次，而不是
`ipctrl_l1_refill_miss_req` 发起时立即记。它包含首 beat transfer error，不包含
REQ 阶段被 change-flow 撤销的请求，也不代表 refill 已成功提交完整 64B line。
计算 miss ratio 时必须使用这里定义的 `access/miss` 事件口径，不能把它与其他
层级的请求计数任意相除。

### 8.4 寄存器采样与门控时钟

```verilog
// 第 700-741 行
gated_clk_cell x_hpcp_clk (
  .local_en (hpcp_clk_en), ...
);
assign hpcp_clk_en = cp0_ifu_icache_en && hpcp_ifu_cnt_en;

always @(posedge hpcp_clk or negedge cpurst_b) begin
  if(!cpurst_b) begin
    ifu_hpcp_icache_access_reg <= 1'b0;
    ifu_hpcp_icache_miss_reg   <= 1'b0;
  end else if(cp0_ifu_icache_en && hpcp_ifu_cnt_en) begin
    ifu_hpcp_icache_access_reg <= ifu_hpcp_icache_access_pre;
    ifu_hpcp_icache_miss_reg   <= ifu_hpcp_icache_miss_pre;
  end
end
```

`_pre` 是当前拍组合事件，`_reg` 是通过 `hpcp_clk` 打拍后送 HPCP 的事件。
寄存器只在 `cp0_ifu_icache_en && hpcp_ifu_cnt_en` 时更新；否则保持旧值而不是
由这段 RTL 自动清零。

物理门控还必须结合通用 `gated_clk_cell` 理解：技术 ICG 分支下使能表达式是
`cp0_yy_clk_en && (cp0_ifu_icg_en || hpcp_clk_en)`，所以 module-enable 可覆盖
local-enable；未定义 `C910_USE_TSMC28_ICG` 时开源 wrapper 直接
`assign clk_out=clk_in`。因此从 RTL 功能仿真看到时钟持续翻转，不表示寄存器
每拍都更新，也不能仅凭 `hpcp_clk_en=0` 宣称物理时钟一定停止。实际节能需在
目标工艺综合网表上验证。

---

## 9. 完整信号汇总表

### 9.1 输入信号

| 信号名 | 位宽 | 来源 | 含义 |
|---|---|---|---|
| `cp0_ifu_icache_en` | 1 | CP0 | I-Cache 全局使能 |
| `cp0_ifu_icg_en` | 1 | CP0 | IFU module clock-enable；在技术 ICG 分支中可覆盖各 wrapper 的 local enable，但仍受相应 global enable 约束 |
| `cp0_yy_clk_en` | 1 | CP0 | Data/Predecode/HPCP ICG 的 global enable；Tag wrapper 的 ICG 将 global enable 固定为 1 |
| `cpurst_b` | 1 | 复位 | 异步复位（低有效） |
| `forever_cpuclk` | 1 | 时钟 | 主时钟 |
| `hpcp_ifu_cnt_en` | 1 | HPCP | 允许本模块更新 I-Cache access/miss 事件寄存器 |
| `pad_yy_icg_scan_en` | 1 | DFT | 技术 ICG 的 test-enable；开源直通时钟分支不使用它控制功能逻辑 |
| `pcgen_icache_if_index` | 16 | pcgen | `pc_bus[15:0]`，即架构虚拟 PC `[16:1]` 的内部半字地址 |
| `pcgen_icache_if_chgflw` | 1 | pcgen | 换流请求 |
| `pcgen_icache_if_chgflw_bank0~3` | 1×4 | pcgen | 换流时各 Data bank 的请求位图；IPCTRL taken 可形成目标 bank 到 bank3 的后缀，其他高改流通常四位全开 |
| `pcgen_icache_if_chgflw_short` | 1 | pcgen | 供 array clock-enable 提前准备的换流条件；“short”表示控制时序版本，不应直接量化为固定半周期 |
| `pcgen_icache_if_gateclk_en` | 1 | pcgen | Tag Array wrapper 的本地时钟提前使能条件 |
| `pcgen_icache_if_seq_data_req` | 1 | pcgen | 顺序 data 读请求 |
| `pcgen_icache_if_seq_data_req_short` | 1 | pcgen | 顺序 Data/Predecode array 的本地时钟提前使能条件 |
| `pcgen_icache_if_seq_tag_req` | 1 | pcgen | 顺序 Tag 读请求；PCGEN 只在 `pc_bus[4:3]==0` 时发出，以 64B line 内相应 block 边界刷新 tag |
| `pcgen_icache_if_way_pred` | 2 | pcgen | Way 选择位图（bit0=Way0，bit1=Way1）；它是预测结果，不是最终 tag-hit |
| `ifctrl_icache_if_index` | 39 | ifctrl | IFCTRL invalidation/tag 操作的内部半字地址 |
| `ifctrl_icache_if_tag_req` | 1 | ifctrl | IFCTRL invalidation 状态机的 Tag Array 请求 |
| `ifctrl_icache_if_tag_wen` | 3 | ifctrl | invalidation 路径提供的低有效 `{FIFO,Way1,Way0}` 字段写掩码 |
| `ifctrl_icache_if_inv_on` | 1 | ifctrl | IFCTRL I-Cache maintenance 状态机非 IDLE；选择 maintenance 的 tag write-data/mask 来源 |
| `ifctrl_icache_if_inv_fifo` | 1 | ifctrl | inv 时写入的 FIFO bit |
| `ifctrl_icache_if_reset_req` | 1 | ifctrl | reset-clear beat；强制两路 Data/Predecode 当前 row 写 0，并参与共享 index 选择 |
| `ifctrl_icache_if_read_req_data0` | 1 | ifctrl | CP0 cache-read 请求读取 Way0 Data |
| `ifctrl_icache_if_read_req_data1` | 1 | ifctrl | CP0 cache-read 请求读取 Way1 Data |
| `ifctrl_icache_if_read_req_tag` | 1 | ifctrl | CP0 cache-read 请求读取 Tag Array |
| `ifctrl_icache_if_read_req_index` | 39 | ifctrl | CP0 cache-read 的内部半字地址 |
| `l1_refill_icache_if_wr` | 1 | l1_refill | 正常 WFDn、cacheable (`tsize=1`) 且当前 data beat 有效时的 array 写请求 |
| `l1_refill_icache_if_first` | 1 | l1_refill | WFD1 的有效首 beat；触发替换 way 的旧 tag/valid 清除 |
| `l1_refill_icache_if_last` | 1 | l1_refill | WFD4 的有效末 beat；触发新 tag/valid 提交和 FIFO 位更新 |
| `l1_refill_icache_if_index` | 39 | l1_refill | 当前 refill 16B block 的虚拟内部半字地址 |
| `l1_refill_icache_if_inst_data` | 128 | l1_refill | 当前返回 beat 经 half-word lane 重排后的指令数据 |
| `l1_refill_icache_if_pre_code` | 32 | l1_refill | 与当前 128-bit beat 对应的八组 4-bit 预解码数据 |
| `l1_refill_icache_if_ptag` | 28 | l1_refill | 架构物理地址 `PA[39:12]` |
| `l1_refill_icache_if_fifo` | 1 | l1_refill | miss 时锁存的替换 way 选择：0=Way0，1=Way1 |
| `ipb_icache_if_req` | 1 | ipb | 对下一条预取候选 line 发起 I-Cache Tag Array 检查 |
| `ipb_icache_if_req_for_gateclk` | 1 | ipb | IPB tag 检查的本地时钟提前使能；未被 `pre_cancel` 组合屏蔽 |
| `ipb_icache_if_index` | 34 | ipb | 下一条 64B line 的虚拟 line number，即 `VPC[39:6]` |
| `ifu_hpcp_icache_miss_pre` | 1 | l1_refill | WFD1 收到首个 data/error 返回事件的组合 miss 事件 |

### 9.2 输出信号

| 信号名 | 位宽 | 去向 | 含义 |
|---|---|---|---|
| `icache_if_ifdp_tag_data0` | 29 | ifdp | Way0 tag 读出（valid+tag） |
| `icache_if_ifdp_tag_data1` | 29 | ifdp | Way1 tag 读出 |
| `icache_if_ifdp_fifo` | 1 | ifdp | FIFO bit 读出 |
| `icache_if_ifdp_inst_data0` | 128 | ifdp | Way0 指令数据读出 |
| `icache_if_ifdp_inst_data1` | 128 | ifdp | Way1 指令数据读出 |
| `icache_if_ifdp_precode0` | 32 | ifdp | Way0 预解码结果读出 |
| `icache_if_ifdp_precode1` | 32 | ifdp | Way1 预解码结果读出 |
| `icache_if_ifctrl_tag_data0` | 29 | ifctrl | Way0 `{valid,tag}`，供 CP0 cache-tag read 状态机锁存 |
| `icache_if_ifctrl_tag_data1` | 29 | ifctrl | Way1 `{valid,tag}`，供 CP0 cache-tag read 状态机锁存 |
| `icache_if_ifctrl_inst_data0` | 128 | ifctrl | Way0 Data Array `Q`，供 CP0 cache-data read |
| `icache_if_ifctrl_inst_data1` | 128 | ifctrl | Way1 Data Array `Q`，供 CP0 cache-data read |
| `icache_if_ipb_tag_data0` | 29 | ipb | Way0 tag（prefetch 命中检查） |
| `icache_if_ipb_tag_data1` | 29 | ipb | Way1 tag（prefetch 命中检查） |
| `ifu_hpcp_icache_access` | 1 | HPCP | PCGEN sequence/change-flow I-Cache data 访问事件，打拍后输出 |
| `ifu_hpcp_icache_miss` | 1 | HPCP | L1-refill WFD1 首返回事件，打拍后输出；包含 transfer error |

---

## 附录：关键设计决策汇总

| 设计决策 | 原因 |
|---|---|
| Tag array 59 位存两路 | 一次读出完成 tag compare，避免两次 SRAM 读 |
| Refill first 写 valid=0 | 在四个 16B block 尚未全部提交时隐藏替换 way，避免旧 tag 命中部分已覆盖的数据 |
| FIFO 替换位编码为 `{!fifo, fifo}` | 直接 one-hot 驱动 way wen，无需额外译码 |
| Data array 分 4 bank，精确激活 | 顺序取指时省去不需要的 bank 功耗 |
| Predecode array 不分 bank | 当前 RTL 以单个 32-bit 数据行读取；面积/功耗取舍需综合结果量化 |
| higher one-hot case + pcgen 外层 2:1 选择 | 让 pcgen 走独立外层选择；时序收益是源码意图，需 STA 验证 |
| PMU 使用独立条件采样与 ICG wrapper | 计数关闭时寄存器保持；物理时钟是否停止取决于 module/global enable、技术 ICG 配置和实现 |
