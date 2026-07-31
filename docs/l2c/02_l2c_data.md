# C910 L2C Data 阵列与数据通路 模块详细教学文档

> RTL 文件：`ct_l2c_data.v`（约 533 行）、`ct_l2cache_data_array.v`（约 106 行），并涉及 `ct_l2cache_top.v`（约 289 行）的 data 阵列接线
> 配置：`cpu/rtl/cpu_cfig.h`（`L2C_DATA_INDEX_WIDTH`，16WAY/1M = 13，行 398）

## 目录
- [1. 模块概述](#1-模块概述)
- [2. 端口说明](#2-端口说明)
- [3. 参数与关键寄存器](#3-参数与关键寄存器)
- [4. Data 阵列组织：4 bank × 128 位 = 512 位行](#4-data-阵列组织4-bank--128-位--512-位行)
- [5. ct_l2cache_data_array：单 bank 的容量自适应](#5-ct_l2cache_data_array单-bank-的容量自适应)
- [6. Data RAM 访问 FSM 与可编程访问延迟](#6-data-ram-访问-fsm-与可编程访问延迟)
- [7. 索引/片选/写使能生成（setup 两态）](#7-索引片选写使能生成setup-两态)
- [8. Data 级流水信息与读出锁存](#8-data-级流水信息与读出锁存)
- [9. 多源仲裁（cmp / icc）](#9-多源仲裁cmp--icc)
- [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

`ct_l2c_data` 是 L2C 流水的 **第 ③ 级（data 级）**，负责数据 SRAM 的全部访问控制：

1. **驱动 4 个 data bank**：生成 4 个独立索引 `l2c_data_index0~3`、片选 `l2c_data_ram_cen[3:0]`、写使能 `l2c_data_wen[3:0]`，以及 512 位写数据 `l2c_data_din`。
2. **访问 FSM + 可编程延迟**：用 `data_acc_cnt`（4 位）吸收数据 SRAM 的访问延迟（`ct_l2c_data.v:507`）。
3. **流水信息下传**：把 sid/src/resp/cp/index 锁存为 `data_stage_*` 供 wb 级使用（:425）。
4. **读出锁存**：把 SRAM 读回 `l2c_data_dout[511:0]` 锁存成 `l2c_data_dout_flop` 给 wb 级。
5. **多源选择**：cmp 的普通整行读写与 ICC 的维护/DCA 读取共享 data 端口。当前 ICC 没有 data 写数据输入，不能描述为 DCA 读写。

### 1.2 位置

```
ct_l2c_cmp (②) ─cmp_data_req/din/index/wen─► [③ ct_l2c_data] ─► l2c_data_dout_flop ─► ct_l2c_wb (④)
                                                  │  ▲ l2c_data_dout
                              l2c_data_index0~3   ▼  │
                              l2c_data_ram_cen/wen/din
                                    ct_l2cache_top → 4× ct_l2cache_data_array (SRAM)
```

---

## 2. 端口说明

| 组 | 端口 | 方向 | 含义 |
|----|------|------|------|
| 周期配置 | `ciu_l2c_data_acc_cycle[3:0]`/`ciu_l2c_data_setup` | in | 数据 RAM 访问周期 / 是否有 setup 拍 |
| cmp 请求 | `cmp_data_req`/`cmp_data_req_gate`/`cmp_data_din[511:0]`/`cmp_data_index[12:0]`/`cmp_data_wen`/`cmp_stage_write` | in | cmp 级的数据读/写请求与负载 |
| cmp 信息 | `cmp_stage_addr/sid/src/resp/cp` | in | 随路下传的请求属性 |
| icc 请求 | `icc_data_req`/`icc_data_cen[4:0]`/`icc_data_index[12:0]`/`icc_data_flop` | in | 维护遍历读取整行，或 DCA 读取一个 128 位 data 分片/ECC 占位 |
| 给阵列 | `l2c_data_index0~3[12:0]`/`l2c_data_ram_cen[3:0]`/`l2c_data_wen[3:0]`/`l2c_data_din[511:0]`/`l2c_data_ram_clk_en_x` | out | 驱动 4 个 data slice；`cen/wen` 在 SRAM 接口上为低有效 |
| 阵列读回 | `l2c_data_dout[511:0]` | in | 4 bank 拼出的整行 |
| 给 wb | `l2c_data_dout_flop[511:0]`/`data_stage_sid/src/resp/cp/index`/`data_stage_vld`/`data_yy_flop_vld` | out | 锁存后的数据与信息 |
| ECC | `data_ecc_ram_cen`/`data_ecc_wen` | out | 第 5 个 bank（ECC）片选/写（框架，见下） |
| idle/grant | `data_xx_idle`/`data_yy_ram_idle`/`data_icc_grant` | out | 给 icc 仲裁的空闲指示 |

> 注意：内部 `data_ram_cen[4:0]`/`data_ram_wen[4:0]` 是 **5 位低有效控制**。bit[3:0] 对应四个 128 位 data slice，bit[4] 是 data ECC 预留端口。`ct_l2cache_top` 只实例化四个 data SRAM，ECC SRAM 实例被注释，所以 bit4 不会访问实际 ECC 存储体。

---

## 3. 参数与关键寄存器

| 参数 | 值（1M） | file:line | 含义 |
|------|----------|-----------|------|
| `DATA_INDEX_LENTH` | `L2C_DATA_INDEX_WIDTH` = 13 | `ct_l2c_data.v:188` | data 索引宽 → 8192 行/bank |
| `L2C_ADDRW` | 33 | `ct_l2c_data.v:189` | 地址宽 |
| `DATA_IDLE/DATA_BUSY` | 1'b0 / 1'b1 | `ct_l2c_data.v:458-459` | data FSM 两态 |

关键寄存器：

| 寄存器 | 位宽 | 含义 | file:line |
|--------|------|------|-----------|
| `data_ram_state` | 1 | data FSM 态 | `:461` |
| `data_acc_cnt` | 4 | 访问延迟倒数计数器 | `:507` |
| `data_stage_vld` | 1 | data 级有效 | `:414` |
| `data_stage_sid/src/resp/cp` | 5/2/5/4 | 随路属性 | `:425` |
| `data_stage_index` | 7 | 在途请求内部地址低 7 位，即 `PA[13:7]`；供入口 hazard 比较，不是 64 B 行内偏移 | `:433` |
| `l2c_data_dout_flop` | 512 | 锁存的读出整行 | — |
| `l2c_data_index{0..3}_flop` | 各 13 | setup 模式下的索引 | `:361-369` |

---

## 4. Data 阵列组织：4 bank × 128 位 = 512 位行

L2C 一行 64 B = 512 bit，被切成 **4 个 128 位并行 slice**。RTL 信号名把它们称作 bank，但常规 L2 读写会用相同索引同时访问四份 SRAM，目的是拼出或写入一整条 cache line；它们不是四个可让四条独立普通请求并行访问的 L2 地址 bank。`ct_l2cache_top.v:157-230` 实例化 4 个 `ct_l2cache_data_array`：

| 实例 | 数据切片 | 索引 | 片选/写 | file:line |
|------|----------|------|---------|-----------|
| bank0 | `l2c_data_din[127:0]` / `dout[127:0]` | `l2c_data_index0` | `ram_cen[0]`/`wen0` | `ct_l2cache_top.v:157` |
| bank1 | `[255:128]` | `index1` | `ram_cen[1]`/`wen1` | `:179` |
| bank2 | `[383:256]` | `index2` | `ram_cen[2]`/`wen2` | `:200` |
| bank3 | `[511:384]` | `index3` | `ram_cen[3]`/`wen3` | `:221` |

每个 slice 的低有效写屏蔽由 1 位 `l2c_data_wen[i]` 复制为 128 位（`ct_l2cache_top.v:151-154`）：
```verilog
l2c_data_wen0[127:0] = {128{l2c_data_wen[0]}};
```

四个 slice 在模块端口上各有一组 index 信号，但当前 `ct_l2c_data` 无论 `setup=0` 还是 `setup=1`，都把同一个 `l2c_data_index_pre` 复制到四个 index；setup 寄存器也在同一时钟边沿锁存同一个值。因此“接口分开”不等于当前逻辑支持四个 slice 使用不同地址。DCA 选择某个 128 位分片时，依靠独立 `cen` 只使能一个 slice，而不是给该 slice 另发不同索引。

---

## 5. ct_l2cache_data_array：单 bank 的容量自适应

`ct_l2cache_data_array`（`ct_l2cache_data_array.v`）是单个 128 位 bank 的封装：

- 端口固定 128 位 `data_din/dout/wen`，索引宽 `DATA_INDEX_WIDTH`（:35、:39-44）。
- **SRAM 型号随容量切换**（`ifdef` 链，:60-89）：

| 容量宏 | SRAM 实例 | 深度 |
|--------|-----------|------|
| `L2_CACHE_128K` | `ct_spsram_1024x128` | 1024 |
| `L2_CACHE_256K` | `ct_spsram_2048x128` | 2048 |
| `L2_CACHE_512K` | `ct_spsram_4096x128` | 4096 |
| **`L2_CACHE_1M`** | **`ct_spsram_8192x128`** | **8192** | （:69-70，当前配置）
| `L2_CACHE_2M` | `ct_spsram_16384x128` | 16384 |
| `L2_CACHE_4M` | `ct_spsram_32768x128` | 32768 |
| `L2_CACHE_8M` | `ct_spsram_65536x128` | 65536 |

1MB 配置下每个 slice = 8192 深 × 128 位。验证：每 sub-bank 512 组 × 16 路 = 8192 个 way/set 槽，每个槽在每个 slice 占 128 位，所以深度正好为 8192，与 `DATA_INDEX_WIDTH=13` 一致。

- 大容量（≥2M）的 SRAM 还接 `pad_yy_icg_scan_en` 做内部时钟门控（:74-88）。

---

## 6. Data RAM 访问 FSM 与可编程访问延迟

### 6.1 两态 FSM（`ct_l2c_data.v:461-498`）

```
DATA_IDLE ── data_req_vld ──► DATA_BUSY
   ▲                                                   │
   └────────── data_acc_cnt_zero & 无新请求 ───────────┘
```

- `DATA_IDLE -> DATA_BUSY` 的 RTL 条件只有 `data_req_vld`（:478），不包含 `ciu_l2c_data_setup`。`setup` 影响 SRAM 控制信号是直接使用组合值还是先锁存，不改变 FSM 是否看见请求。
- `data_acc_cnt`（4 位，:501-510）在进入访问时载入 `ciu_l2c_data_acc_cycle[3:0]`（:507），倒数到 0（`data_acc_cnt_zero`，:496）表示数据就绪。
- `data_ram_idle`（:497）= IDLE 或（BUSY 且计数到 0），表示当前 data SRAM 访问计数已经释放端口；它参与读出完成判断，也作为 ICC 排空后接管端口的本地 grant。
- `data_acc_cycle` 在 `ct_l2c_top.v:430-446` 由一个查找表从 `ciu_l2c_data_latency` 译出（latency 越大，acc_cycle 越大，最大 4'b1000），把物理延迟映射成流水拍数。

### 6.2 与 tag 级的差异

寄存器位宽上，tag 计数器 3 位可表示 0~7，data 计数器 4 位可表示 0~15；但当前顶层配置换算分别把 tag/data access cycle 钳到最大 4 和 8。位宽容量不等于当前允许的软件/集成配置范围。data 提供更大的合法等待范围，符合其 SRAM 可能需要更长访问时间的实现需求；具体物理延迟仍应由所用 SRAM 宏和时序约束确定。

---

## 7. 索引/片选/写使能生成（setup 两态）

`ct_l2c_data.v:360-397` 是一个根据 `ciu_l2c_data_setup` 分两种时序的大组合块：

- **setup=1（有建立拍）**：索引、片选、写数据取自前一时钟边沿锁存的 `*_flop`（:376-382）。四个 index 寄存器都锁存同一个 `l2c_data_index_pre`。
  ```verilog
  l2c_data_index0 = l2c_data_index0_flop;   // 各 bank 独立
  data_ram_cen[4:0] = ~l2c_data_cen_flop;
  ```
- **setup=0（无建立拍）**：四个 bank 索引同取 `l2c_data_index_pre`（:387-390），片选/写数据取 `*_pre`。
  ```verilog
  l2c_data_index0=index1=index2=index3 = l2c_data_index_pre;
  data_ram_cen[4:0] = ~l2c_data_ram_cen_pre;
  data_ram_wen[4:0] = {5{~l2c_data_wen_pre}};
  ```

随后（:401-406）：
```verilog
l2c_data_ram_clk_en_x = |(~data_ram_cen[4:0]);   // 任一 bank 被选则给时钟
l2c_data_ram_cen[3:0] = data_ram_cen[3:0];       // 对外 4 个数据 bank
l2c_data_wen[3:0]     = data_ram_wen[3:0];
data_ecc_ram_cen      = data_ram_cen[4];          // 第 5 位 = ECC bank
data_ecc_wen          = data_ram_wen[4];
```

> setup 拍的存在与否让设计能在“高频但多一拍建立”与“低频但少一拍”之间权衡——又是一处可配置时序。

---

## 8. Data 级流水信息与读出锁存

- `data_stage_vld`（:414-422）：只在 `cmp_data_req && !cmp_stage_write && data_ram_idle` 时置 1，因此它代表需要在访问结束后向 wb 发送数据的**读类**请求。整行写会访问 SRAM，但不会为写数据建立 `data_stage_vld`；写完成走 cmp 创建的纯响应 rfifo。
- `data_stage_*`（:425-443）：在 `cmp_data_req_gate && data_ram_idle` 时锁存 sid/src/resp/cp 和 `cmp_stage_addr[6:0]`。其中 `addr[6:0]` 对应 `PA[13:7]`，用于 tag 入口对在途 data 访问做保守 hazard 比较；它不是物理地址的 64 B 行内偏移。
- 读出 `l2c_data_dout[511:0]` 经 `data_dout` 门控时钟锁存为 `l2c_data_dout_flop`（:277 门控、最终送 wb 的 `l2c_data_dout_flop`），wb 级直接 `wb_stage_data = l2c_data_dout_flop`（见 `04` 篇 wb 部分）。

---

## 9. 多源仲裁（cmp / icc）

data RAM 端口由 cmp（正常访问）与 ICC（维护/DCA 诊断读）共享：

- 请求合并：data FSM 的进入条件同时看 cmp 与 icc 的请求（`data_req_vld`，结合 :196 的 `data_req_vld_gate`）。
- `data_icc_grant` 组合地等于 `data_ram_idle`，表示当前访问计数已经释放本地 data 端口；真正的 ICC 启动还受整条 `l2c_pipeline_rdy` 限制。
- 地址选择为 `icc_data_req ? icc_data_index : cmp_data_index`。从组合 mux 看 ICC 优先，但协议上 ICC 已在主流水排空后互斥运行。
- ICC maintenance 用四个 data slice 读出一条 512 位脏行；DCA data 读只使能 offset 选中的一个 128 位 slice。
- 写使能和 512 位写数据只来自 cmp：`l2c_data_wen_pre=cmp_data_wen`，`l2c_data_din_pre=cmp_data_din`。当前没有 ICC/DCA 写 data 的路径。

不能把这个 mux 简化为“ICC 随时抢占 cmp”。ICC 只有等 tag/cmp/data/wb 与 rfifo 都为空后才离开 IDLE；进入后又通过 `icc_idle=0` 阻止新的普通地址请求。正确模型是“排空后由 ICC 接管，完成后归还”。

---

## 本章小结

L2 data array 由四个 128 位 slice 组成一条 512 位 cache line。普通 refill、读取或写回可以同时使能四个 slice，DCA 诊断读取则可只选择其中一个 128 位片。虽然 RTL 暴露四个 index 端口，当前控制逻辑始终给它们相同索引，所以这些端口表示一条 line 的分片访问，而不是四个不同地址的并行 cache 访问。data 级还随数据锁存 sid、resp、cp 和 index，使 wb 级可以直接组装返回而无需重新查 tag/status。

访问时延由 setup 选择和 4 位计数器 FSM 控制，顶层当前把合法 data access cycle 限制在 0 至 8；因此“一次阵列访问需要几拍”必须结合实际寄存器配置判断，不能只看 SRAM 端口形式。第 5 个 `data_ram_cen[4]` 和 `data_ecc_*` 通路为 ECC bank 保留，但开源顶层只实例化 `[3:0]` 四个数据 SRAM，未接入实际 ECC 存储。容量宏是否能完整实现还要同时核查 tag、status、data wrapper 和顶层参数。波形分析应从 cmp/data request 开始，检查片选、统一 index、计数状态、SRAM 输出、随路元数据和 wb 接受，避免把片选出现当成返回已经有效。
