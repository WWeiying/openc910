# C910 L2C 总体架构 模块详细教学文档

> RTL 目录：`/home/wangwy/openc910/C910_RTL_FACTORY/gen_rtl/l2c/rtl/`
> 配置文件：`cpu/rtl/cpu_cfig.h`（L2C 容量/路数/位宽宏定义，行 214 起）
> 本文是 L2C 子系统的总览，串讲所有模块；细节见 `01`~`04` 各分篇。

## 目录
- [1. 模块概述](#1-模块概述)
- [2. 顶层结构与端口](#2-顶层结构与端口)
- [3. 容量 / 组织参数（带 file:line）](#3-容量--组织参数带-fileline)
- [4. 五级流水线总览](#4-五级流水线总览)
- [5. 两核一致性汇聚点与侦听过滤器](#5-两核一致性汇聚点与侦听过滤器)
- [6. 完整访问数据流](#6-完整访问数据流)
- [7. 关键设计决策汇总](#7-关键设计决策汇总)
- [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

C910 的 L2 Cache 是**两个核共享的二级缓存**，同时充当片上一致性（coherence）的**汇聚点**。它接收来自 CIU（Cache Interface Unit / 一致性互联单元）的统一请求流，完成：

1. **数据缓存**：缓存来自两个核 L1（I-Cache / D-Cache）的数据，1MB / 16 路 / 64B 行。
2. **一致性维护**：记录每行被哪些核持有（`cp[3:0]` core-presence 位），是一个**侦听过滤器 / 目录（snoop filter / directory）**。L2 知道某行是否在某核 L1，从而过滤掉无谓的侦听（snoop），只在必要时向核发 snpl2。
3. **状态管理**：维护 MESI 风格的 valid/shared/dirty 状态。
4. **维护指令与 DCA**：处理 cache flush、clean、invalidate（CMO/CTC）与直接缓存访问（DCA，调试/诊断读写 tag/data/ECC）。
5. **硬件预取**：对指令取指 miss 和 TLB 取页表 miss 触发下一行预取请求。

### 1.2 在 SoC 中的位置

```
   core0 (IFU/LSU/MMU)        core1 (IFU/LSU/MMU)
            \                       /
             \                     /
              v                   v
        ┌─────────────────────────────┐
        │            CIU              │  一致性互联：仲裁、序列化、snoop 路由
        └─────────────┬──────────────┘
                      │  ciu_l2c_* / l2c_ciu_*   （两套：bank_0 / bank_1）
                      v
        ┌─────────────────────────────┐
        │          ct_l2c_top         │  ← L2C 顶层（本目录）
        │  ┌────────────┐ ┌─────────┐ │
        │  │ sub_bank_0 │ │sub_bank1│ │  2 个 sub-bank 并行
        │  └────────────┘ └─────────┘ │
        │       ┌──────────────┐      │
        │       │  prefetch    │      │  共享预取引擎
        │       └──────────────┘      │
        └─────────────┬──────────────┘
                      │  l2c_ciu_rdl_* / l2c_ciu_prf_*
                      v
                  下游总线 / 内存
```

`ct_l2c_top` 是 L2C 综合边界，内部实例化两个 `ct_l2c_sub_bank`（地址按 bank 位散列到两个 sub-bank）、一个共享的 `ct_l2c_prefetch`，以及一个对接 SoC flush 的小状态机（`ct_l2c_top.v:454` 起，IDLE/REQ/WAIT_1/WAIT_0/DONE 五态）。

---

## 2. 顶层结构与端口

`ct_l2c_top`（`ct_l2c_top.v`，约 713 行）的对外端口几乎全部按 **bank_0 / bank_1 成对出现**，这是“2 sub-bank 并行”在接口上的直接体现。主要端口组：

| 组 | 代表信号 | 方向 | 含义 |
|----|----------|------|------|
| 请求输入 | `ciu_l2c_addr_bank_{0,1}`/`ciu_l2c_addr_vld_*` | in | CIU 给每个 bank 的访问地址（33 位）与有效 |
| 请求属性 | `ciu_l2c_type_bank_*`(13b)/`ciu_l2c_src_*`(2b)/`ciu_l2c_sid_*`(5b)/`ciu_l2c_mid_*` | in | 操作类型、来源、source-id、master-id |
| 一致性位 | `ciu_l2c_set_cp_*`/`ciu_l2c_clr_cp_*`(各 4b) | in | 置位/清除 core-presence 位 |
| 写数据 | `ciu_l2c_wdata_bank_*`/`ciu_l2c_data_vld_*` | in | 写回/填充数据通道 |
| 维护/DCA | `ciu_l2c_ctcq_req_*`/`ciu_l2c_dca_req_*`/`ciu_l2c_dca_addr_*`/`ciu_l2c_rst_req` | in | CMO 维护队列、DCA、复位失效 |
| 预取使能 | `ciu_l2c_iprf`(2b)/`ciu_l2c_tprf`/`ciu_l2c_prf_ready` | in | 指令预取深度、TLB 预取使能、下游接受 |
| 时序配置 | `ciu_l2c_tag_setup`/`ciu_l2c_tag_latency`/`ciu_l2c_data_setup`/`ciu_l2c_data_latency` | in | 可编程 RAM 访问周期/建立 |
| 完成响应 | `l2c_ciu_cmplt_*`/`l2c_ciu_data_*`(512b)/`l2c_ciu_resp_*`/`l2c_ciu_cp_*` | out | 给 CIU 的完成、读数据、响应码、cp |
| 读下游 | `l2c_ciu_rdl_addr_*`/`l2c_ciu_rdl_dvld_*`/`l2c_ciu_rdl_rvld_*` | out | L2 miss 后向下游发读 |
| 侦听 | `l2c_ciu_snpl2_addr_*`/`l2c_ciu_snpl2_vld_*`/`ciu_l2c_snpl2_ready_*` | out/in | L2 向核发起 snoop |
| 预取输出 | `l2c_ciu_prf_addr`(34b)/`l2c_ciu_prf_prot`(3b)/`l2c_ciu_prf_vld` | out | 预取请求 |
| RAM 时钟 | `l2c_tag_clk_*`/`l2c_data_clk_*` | out | 给 SRAM 阵列的门控时钟 |

> 备注：地址端口宽 33 位（`L2C_ADDRW = 33`，见 `ct_l2c_tag.v:571`），代表 40 位物理地址去掉低位的行内偏移后的可寻址范围；预取地址 34 位（`ct_l2c_prefetch.v:63`）。

---

## 3. 容量 / 组织参数（带 file:line）

当前激活配置（`cpu_cfig.h`）：

| 宏 | 值 | file:line |
|----|----|-----------|
| `L2_CACHE_16WAY` | 定义（16 路） | `cpu_cfig.h:214` |
| `L2_CACHE_1M` | 定义（1MB） | `cpu_cfig.h:219` |
| `L2C_TAG_INDEX_WIDTH` | 9 | `cpu_cfig.h:396` |
| `L2C_TAG_DATA_WIDTH` | 24 | `cpu_cfig.h:397` |
| `L2C_DATA_INDEX_WIDTH` | 13 | `cpu_cfig.h:398` |

由这些参数推导出的组织（**这是理解全部 L2C 的基础**）：

```
总容量      1 MB
相联度      16 路 (way)
行大小      64 B  = 512 bit
总行数      1MB / 64B          = 16384 行
组数(set)   16384 / 16 way     = 1024 组
            → 分到 2 个 sub-bank，每 bank 512 组
tag 标签宽  24 bit  (L2C_TAG_DATA_WIDTH)
tag 索引宽  9 bit → 512 (每个 tag SRAM 512 深，正好 1 sub-bank 的组数)
data 索引宽 13 bit → 8192 行 (每 sub-bank 512组×16路 = 8192 行)
```

**关键印证**：
- `00 总览`的 1024 组 = 2 sub-bank × 512 组，由 `L2C_TAG_INDEX_WIDTH=9`（2^9=512）× 2 个 sub-bank 得到。
- tag SRAM：`L2_CACHE_1M` 下 16 路 tag 阵列实例化 4 颗 `ct_spsram_512x96`（512 深 × 96 位 = 4 路 × 24 位），见 `ct_l2cache_tag_array_16way.v:70-72`。4 颗 × 4 路 = 16 路。
- data SRAM：每个 sub-bank 内 4 个 bank，每 bank 一颗 `ct_spsram_8192x128`（8192 深 × 128 位），见 `ct_l2cache_data_array.v:69-70`。4 个 bank × 128 位 = 512 位 = 一整行。
- dirty/status 阵列：一颗 `ct_spsram_512x144`（512 深 × 144 位），见 `ct_l2cache_dirty_array_16way.v:61-62`。144 = 16 路 × 8 位（每路 status）+ 16 位 FIFO 替换位。

> L2C 是参数化的：同一份 RTL 通过 `cpu_cfig.h` 的 `L2_CACHE_128K`~`8M` 与 `8WAY/16WAY` 宏，可综合成 128KB~8MB 的不同尺寸（`cpu_cfig.h:332-420`）。本文档以出厂默认 **16 路 / 1MB** 展开。

---

## 4. 五级流水线总览

L2C 的访问被拆成 5 个流水级，每级对应一个 RTL 模块（均实例化于 `ct_l2c_sub_bank.v`）：

| 级 | 模块 | 实例化行 | 干什么 |
|----|------|----------|--------|
| ① tag | `ct_l2c_tag` | `ct_l2c_sub_bank.v:423` | 读 tag/dirty/status RAM，FSM 控制 RAM 访问，可编程访问周期；ECC 框架；FIFO 替换指针 |
| ② cmp | `ct_l2c_cmp` | `ct_l2c_sub_bank.v:565` | 16 路并行 tag 比较，命中/选路，hit/miss 判定，状态更新计算，回写 tag/dirty |
| ③ data | `ct_l2c_data` | `ct_l2c_sub_bank.v:685` | 读/写 data RAM，4 bank 选择，可编程数据访问延迟 |
| ④ wb | `ct_l2c_wb` | `ct_l2c_sub_bank.v:732` | 组装返回 CIU 的数据/响应；响应 FIFO（rfifo）；ECC 写回框架 |
| ⑤ icc | `ct_l2c_icc` | `ct_l2c_sub_bank.v:771` | 核间一致性/维护/DCA 的 13 态 FSM（与主流水并行旁路） |

> 说明：①~④ 是顺序数据流水；第 ⑤ 级 `icc` 不是数据通过的“第五拍”，而是一个**与主流水仲裁共享 tag/data RAM 端口**的维护引擎（处理 flush/clean/inv/DCA）。文档把它列为“流水第 5 阶段”是沿用 T-Head 资料的口径——它确实是访问完成后落地一致性副作用的那一级。`prompt` 中的 “tag→cmp→data→wb→icc” 即此顺序。

### 各级握手与门控

- 每级都有独立的访问计数器 + 状态机，把“RAM 可编程访问周期”吸收进流水（tag：`tag_acc_cnt` 3 位，`ct_l2c_tag.v:948`；data：`data_acc_cnt` 4 位，`ct_l2c_data.v:507`）。
- 大量 `gated_clk_cell` 局部时钟门控（每个 always 块前都有），是低功耗设计：只有该级有有效请求时才翻转时钟。
- 反压：`cmp_stage_stall`、`next_stage_stall`、`tag_stage_stall` 层层串联（`ct_l2c_tag.v:934`），后级忙则前级保持。

---

## 5. 两核一致性汇聚点与侦听过滤器

L2C 是两核一致性的中枢，核心抓手是每路 status 里的 **`cp[3:0]`（core-presence）** 与 **shared/dirty** 位。

每路 status 共 8 位，编码为 `{cp[3:0], valid, shared, dirty, pend}`（`ct_l2c_tag.v:1078-1161` 按位解出）：

| 位段 | 名称 | 含义 |
|------|------|------|
| `[7:4]` | `cp[3:0]` | core-presence：该行当前被哪些核/主控持有（侦听过滤器的核心） |
| `[3]` | `valid` | 行有效 |
| `[2]` | `shared` | 共享（多核可读）；为 0 表示 unique（独占） |
| `[1]` | `dirty` | 脏（相对下游内存被改过） |
| `[0]` | `pend` | pending：该行有未完成的事务（正在 alloc/refill），用于序列化 |

**侦听过滤的逻辑**（在 cmp 级，`ct_l2c_cmp.v`）：
- CIU 用 `ciu_l2c_set_cp`/`ciu_l2c_clr_cp` 告诉 L2 某核取走/放弃了一行 → L2 更新 `cp` 位。
- 当一个核要独占写一行而它在另一核是 shared，L2 据 `cp`/`shared` 决定是否向持有核发 `l2c_ciu_snpl2_*`（snoop），只 snoop 真正持有该行的核，**而不是广播**——这就是“侦听过滤器”省功耗/省带宽的价值。
- `shared_set`/`shared_clr`/`dirty_set`/`dirty_clr`/`valid_clr` 等由操作类型组合（`ct_l2c_cmp.v:616-632`）驱动，实现 MESI 风格的状态迁移。

**操作类型 `type[12:0]` 全解码**（`ct_l2c_cmp.v:542-554`），这是理解 L2 全部行为的字典：

| 位 | 信号 | 含义 |
|----|------|------|
| 12 | `read` | 读 |
| 11 | `alct` | allocate（占位/预分配） |
| 10 | `cln` | clean（写回但保留） |
| 9 | `icln` | invalidate-clean（写回并失效） |
| 8 | `write_sd` | write shared-dirty |
| 7 | `write_uc` | write unique-clean |
| 6 | `write_ud` | write unique-dirty |
| 5 | `write_sc` | write shared-clean |
| 4 | `atag` | access tag（仅访 tag） |
| 3 | `inv` | invalidate |
| 2 | `release` | release（释放 pending 占位） |
| 1 | `unique` | 升级为独占 |
| 0 | `shared` | 降级为共享 |

---

## 6. 完整访问数据流

下面以**一次核读请求**为例，串起全流水（行号给出代表性落点）：

```
CIU 发起 ciu_l2c_addr_vld_x + ciu_l2c_addr_x[32:0] + type=read
   │
   ▼ ① TAG 级 (ct_l2c_tag.v)
   ciu_req_vld 拉高 → tag FSM IDLE→BUSY (ct_l2c_tag.v:906)
   用 index 读 tag/dirty/status RAM；tag_acc_cnt 倒数吸收 RAM 周期
   16 路 tag_dout / status 解出 (status_vld/shared/dirty/cp, :1095-1161)
   存入 cmp_info flop (:1444)，并算出 FIFO 替换指针 cmp_refill_ptr
   │
   ▼ ② CMP 级 (ct_l2c_cmp.v)
   16 路并行比较 tag_stage_addr_hit & status_vld → cmp_way_v_hit (:560)
   l2c_cache_hit = |cmp_way_v_hit  （命中=任一路 valid 且 tag 匹配）
   命中：选中路 → data_rd 拉高 (:717)；one-hot 转 4 位 way 编号 (:747)
   未命中：cmp_stage_refill / 触发预取 / 发 rdl 读下游
   状态更新计算：valid/shared/dirty/cp 的 set/clr → 回写 tag/dirty RAM
   │
   ▼ ③ DATA 级 (ct_l2c_data.v)
   data FSM IDLE→BUSY (:475)；data_acc_cnt 吸收数据 RAM 延迟
   选中 way 对应的 4 个 128b bank 读出 512b 整行 (l2c_data_dout 512b)
   │
   ▼ ④ WB 级 (ct_l2c_wb.v)
   wb_stage 锁存 sid/resp/cp + 512b 数据 (:200,217)
   组装 l2c_ciu_data_x(512b)/resp/cp/sid → l2c_ciu_cmplt_x 拉高 (:266)
   若数据未就绪先入 rfifo（3 深响应 FIFO，:242）等数据
   │
   ▼ 返回 CIU → 路由回发起核
```

- **写请求**：type 为 write_xx，cmp 级判 hit/miss；hit 改 data + 更新 dirty/shared；miss 则 `cmp_stage_refill`（先占一路、发下游读、回填）。
- **维护（flush/clean/inv）**：走 ⑤ icc FSM（见 `04` 篇），遍历所有 index/way 清状态、必要时写回脏行。
- **预取**：cmp 级若是 ifu/tlb 的读 miss 且未跨页，触发 prefetch 引擎对下一行发 `l2c_ciu_prf_*`（见 `04` 篇）。

---

## 7. 关键设计决策汇总

| 决策 | 内容 | 证据 | 取舍 |
|------|------|------|------|
| 2 sub-bank 并行 | 1024 组拆成两个 512 组 sub-bank，独立流水，接口 bank_0/bank_1 | `ct_l2c_top.v:525,599` | 翻倍吞吐、降单 bank 端口压力；代价是接口/逻辑翻倍 |
| 4-bank data 阵列 | 每 sub-bank 内 data 分 4 个 128b bank 拼 512b 行 | `ct_l2cache_top.v:157-230` | 一拍读出整行；按 bank 精确门控省功耗 |
| 集中 status 阵列 | 16 路 status + FIFO 位集中放一颗 512×144 dirty/status RAM | `ct_l2cache_dirty_array_16way.v:61` | 一次读出全 16 路状态，利于并行命中判定 |
| core-presence 目录 | status 含 cp[3:0]，L2 充当 snoop filter | `ct_l2c_tag.v:1078` | 过滤无谓 snoop；代价是每路多 4 位存储 |
| FIFO 替换 | 用 status_fifo 位做近似 FIFO 替换，优先填 pend&!valid 的路 | `ct_l2c_tag.v:1171-1331` | 实现简单、面积小；非真 LRU |
| 可编程访问周期 | tag/data 访问周期由 CIU 配置（acc_cycle/setup/latency） | `ct_l2c_tag.v:953`、`ct_l2c_data.v:507` | 适配不同 SRAM/频率；流水深度可调 |
| 细粒度时钟门控 | 每 always 前 gated_clk_cell | 全文件 | 低功耗；代价是大量门控单元 |
| ECC 框架预留 | tag/dirty/data 的 ECC 编解码、ECC rfifo 在本开源版**留接口未落实现** | 见 `01`、`04` | 框架在、纠错核未开源；功能上等效“无 ECC 纠错” |

---

## 设计取舍小结

L2C 的设计主线是 **“共享 + 一致性 + 可配置 + 低功耗”**：

1. **共享与一致性合一**——L2 不仅是更大的缓存，还兼任目录/侦听过滤器（cp 位）。把一致性目录放在 L2，避免了独立目录的面积与一致性协议复杂度，但让 L2 的 status 编码、cmp 级的状态机变得相对复杂。
2. **2 sub-bank + 4 data-bank 的双层 banking**——sub-bank 解决相联吞吐，data-bank 解决“一拍取整行”和精确门控。代价是接口几乎全部成对、综合规模翻倍。
3. **可编程访问周期**把 SRAM 的物理时序从逻辑里解耦出来，使同一 RTL 既能配低频大容量、又能配高频小容量；副作用是每级都要带一个访问计数器和对应 FSM。
4. **FIFO 近似替换**而非 LRU，体现了“面积优先、性能够用”的工程取舍。
5. **ECC 仅留框架**——保护通路（after_correct 信号、syndrome flop、ECC rfifo）在结构上都在，但纠错运算在开源版被旁路（直通 + fatal_err 置 0）。学习时要分清“架构意图”与“开源实现现状”。

---

*本文为 L2C 子系统总览，未逐行覆盖单一 .v 文件；逐文件全行覆盖见 `01_l2c_tag_status.md`、`02_l2c_data.md`、`03_l2c_pipeline.md`、`04_l2c_prefetch_icc_wb.md`。*
