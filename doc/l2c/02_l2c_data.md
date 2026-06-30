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
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

`ct_l2c_data` 是 L2C 流水的 **第 ③ 级（data 级）**，负责数据 SRAM 的全部访问控制：

1. **驱动 4 个 data bank**：生成 4 个独立索引 `l2c_data_index0~3`、片选 `l2c_data_ram_cen[3:0]`、写使能 `l2c_data_wen[3:0]`，以及 512 位写数据 `l2c_data_din`。
2. **访问 FSM + 可编程延迟**：用 `data_acc_cnt`（4 位）吸收数据 SRAM 的访问延迟（`ct_l2c_data.v:507`）。
3. **流水信息下传**：把 sid/src/resp/cp/index 锁存为 `data_stage_*` 供 wb 级使用（:425）。
4. **读出锁存**：把 SRAM 读回 `l2c_data_dout[511:0]` 锁存成 `l2c_data_dout_flop` 给 wb 级。
5. **多源仲裁**：cmp（正常访问）与 icc（维护/DCA 读写）共享 data 端口。

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
| icc 请求 | `icc_data_req`/`icc_data_cen[4:0]`/`icc_data_index[12:0]`/`icc_data_flop` | in | 维护/DCA 对 data 的访问 |
| 给阵列 | `l2c_data_index0~3[12:0]`/`l2c_data_ram_cen[3:0]`/`l2c_data_wen[3:0]`/`l2c_data_din[511:0]`/`l2c_data_ram_clk_en_x` | out | 驱动 4 个 data bank |
| 阵列读回 | `l2c_data_dout[511:0]` | in | 4 bank 拼出的整行 |
| 给 wb | `l2c_data_dout_flop[511:0]`/`data_stage_sid/src/resp/cp/index`/`data_stage_vld`/`data_yy_flop_vld` | out | 锁存后的数据与信息 |
| ECC | `data_ecc_ram_cen`/`data_ecc_wen` | out | 第 5 个 bank（ECC）片选/写（框架，见下） |
| idle/grant | `data_xx_idle`/`data_yy_ram_idle`/`data_icc_grant` | out | 给 icc 仲裁的空闲指示 |

> 注意：内部 `data_ram_cen[4:0]`/`data_ram_wen[4:0]` 是 **5 位**——bit[3:0] 是 4 个数据 bank，bit[4] 是 ECC bank（`ct_l2c_data.v:405-406`）。对外 `l2c_data_*` 只取 [3:0]（ECC bank 在开源版未接 SRAM）。

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
| `data_stage_index` | 7 | 行内/组内偏移信息 | `:433` |
| `l2c_data_dout_flop` | 512 | 锁存的读出整行 | — |
| `l2c_data_index{0..3}_flop` | 各 13 | setup 模式下的索引 | `:361-369` |

---

## 4. Data 阵列组织：4 bank × 128 位 = 512 位行

L2C 一行 64B = 512 bit，被切成 **4 个 128 位 bank**。`ct_l2cache_top.v:157-230` 实例化 4 个 `ct_l2cache_data_array`：

| 实例 | 数据切片 | 索引 | 片选/写 | file:line |
|------|----------|------|---------|-----------|
| bank0 | `l2c_data_din[127:0]` / `dout[127:0]` | `l2c_data_index0` | `ram_cen[0]`/`wen0` | `ct_l2cache_top.v:157` |
| bank1 | `[255:128]` | `index1` | `ram_cen[1]`/`wen1` | `:179` |
| bank2 | `[383:256]` | `index2` | `ram_cen[2]`/`wen2` | `:200` |
| bank3 | `[511:384]` | `index3` | `ram_cen[3]`/`wen3` | `:221` |

每 bank 的 128 位写使能由 1 位 `l2c_data_wen[i]` 复制 128 份（`ct_l2cache_top.v:151-154`）：
```verilog
l2c_data_wen0[127:0] = {128{l2c_data_wen[0]}};
```

**为什么 4 个独立索引而不是一个**：四个 bank 各有独立 `index` 端口（`ct_l2c_data.v:50-53`），允许在某些场景对不同 bank 用不同地址（例如读改写、ECC 旁路）。常规访问时四者相同（见第 7 节 setup=0 分支，:387-390）。

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

1MB 配置下每 bank = 8192 深 × 128 位。验证：每 sub-bank 512 组 × 16 路 = 8192 行，每行在一个 bank 占 128 位 → 深度 8192。✓ 与 `DATA_INDEX_WIDTH=13`（2^13=8192）一致。

- 大容量（≥2M）的 SRAM 还接 `pad_yy_icg_scan_en` 做内部时钟门控（:74-88）。

---

## 6. Data RAM 访问 FSM 与可编程访问延迟

### 6.1 两态 FSM（`ct_l2c_data.v:461-498`）

```
DATA_IDLE ──(data_req_vld & setup & data ready)──► DATA_BUSY
   ▲                                                   │
   └────────── data_acc_cnt_zero & 无新请求 ───────────┘
```

- 进 BUSY 条件包含 `ciu_l2c_data_setup`（:478），即是否需要一个 setup 拍。
- `data_acc_cnt`（4 位，:501-510）在进入访问时载入 `ciu_l2c_data_acc_cycle[3:0]`（:507），倒数到 0（`data_acc_cnt_zero`，:496）表示数据就绪。
- `data_ram_idle`（:497）= IDLE 或（BUSY 且计数到 0），用于 wb 取数和 icc 抢占。
- `data_acc_cycle` 在 `ct_l2c_top.v:430-446` 由一个查找表从 `ciu_l2c_data_latency` 译出（latency 越大，acc_cycle 越大，最大 4'b1000），把物理延迟映射成流水拍数。

### 6.2 与 tag 级的差异

tag 访问计数 3 位（最多 8 拍），data 访问计数 4 位（最多 16 拍）——因为 data SRAM 更大、读延迟更长，需要更宽的计数范围。这正是“可编程访问延迟”的体现：**data 比 tag 慢，所以流水里给它更多拍**。

---

## 7. 索引/片选/写使能生成（setup 两态）

`ct_l2c_data.v:360-397` 是一个根据 `ciu_l2c_data_setup` 分两种时序的大组合块：

- **setup=1（有建立拍）**：索引/片选/写数据取自上一拍锁存的 `*_flop`（:376-382），4 个 bank 索引可各不相同。
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

- `data_stage_vld`（:414-422）：cmp 发来读请求且 RAM idle 时置 1，访问计数到 0 时清 0。
- `data_stage_*`（:425-443）：在 `cmp_data_req_gate && data_ram_idle` 时锁存 sid/src/resp/cp 和 `cmp_stage_addr[6:0]`（作为 `data_stage_index[6:0]`）。这些随数据一起流到 wb 级，用于组装返回给 CIU 的响应。
- 读出 `l2c_data_dout[511:0]` 经 `data_dout` 门控时钟锁存为 `l2c_data_dout_flop`（:277 门控、最终送 wb 的 `l2c_data_dout_flop`），wb 级直接 `wb_stage_data = l2c_data_dout_flop`（见 `04` 篇 wb 部分）。

---

## 9. 多源仲裁（cmp / icc）

data RAM 端口由 cmp（正常访问）与 icc（维护/DCA）共享：

- 请求合并：data FSM 的进入条件同时看 cmp 与 icc 的请求（`data_req_vld`，结合 :196 的 `data_req_vld_gate`）。
- `data_icc_grant`（输出）告诉 icc 何时可占用 data RAM。
- icc 的 `icc_data_cen[4:0]`/`icc_data_index` 在 icc 抢占时驱动阵列（DCA 读 data、维护回写脏行）。
- 写数据来源：正常路径 `cmp_data_din[511:0]`（填充/写回的整行）；DCA 写路径来自 icc。

> 与 tag 级一样，icc 优先级高于 cmp，保证一致性维护事务能拿到 data 端口。

---

## 设计取舍小结

1. **4-bank × 128 位整行**：一拍读出/写入整 512 位行，匹配 L1 refill 的 64B 粒度；按 bank 精确门控（`ram_cen[i]` 独立 + `clk_en_x` 按需）省动态功耗。
2. **每 bank 独立索引**：常规访问四者相同（省逻辑），但保留了对不同 bank 用不同地址的能力（ECC/读改写场景）。
3. **可编程访问延迟（4 位计数）**：data SRAM 比 tag 大、慢，用更宽的访问计数 + 可选 setup 拍吸收延迟，使同一 RTL 适配 128KB~8MB 七档容量（仅换 SRAM 型号宏）。
4. **第 5 个 ECC bank 预留**：`data_ram_cen[4]`/`data_ecc_*` 通路在，但开源版未实例化 ECC SRAM（对外只接 [3:0]）——与 tag ECC 一样是框架预留。
5. **信息随路下传**：data 级专门锁存 sid/resp/cp/index，让 wb 级无需回查即可组装响应，缩短返回路径。

---

*文档覆盖 ct_l2c_data.v 全部关键逻辑（访问 FSM、可编程延迟、索引/片选生成、流水信息、仲裁）与 ct_l2cache_data_array.v / ct_l2cache_top.v 的 data 阵列组织，合计约 928 行。*
