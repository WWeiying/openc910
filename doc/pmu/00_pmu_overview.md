# C910 PMU/HPCP 总览与性能分析方法 教学文档

> RTL 目录：`C910_RTL_FACTORY/gen_rtl/pmu/rtl/`
> 涉及文件：`ct_hpcp_top.v`(4404) / `ct_hpcp_cnt.v`(153) / `ct_hpcp_event.v`(103) / `ct_hpcp_adder_sel.v`(260) / `ct_hpcp_cntinten_reg.v`(57) / `ct_hpcp_cntof_reg.v`(63)

---

## 目录

1. [PMU 是什么](#1-pmu-是什么)
2. [整体结构与子模块分工](#2-整体结构与子模块分工)
3. [资源一览（计数器 / 事件 / CSR）](#3-资源一览计数器--事件--csr)
4. [怎么用 PMU 做性能分析](#4-怎么用-pmu-做性能分析)
5. [关键设计决策汇总](#5-关键设计决策汇总)
6. [延伸阅读](#6-延伸阅读)

---

## 1. PMU 是什么

PMU（Performance Monitor Unit，C910 内部代号 HPCP = Hardware Performance Counter & Profiling）是处理器里专门"数事件"的硬件单元。它回答这样的问题：

- 这段程序跑了多少个周期？退休了多少条指令？（→ IPC）
- ICache/DCache 命中率多少？每千条指令多少次缺失？（→ MPKI）
- 分支预测准不准？误预测率多少？
- 前端还是后端是瓶颈？哪个函数最热？

PMU 通过一组**可配置的 64 位计数器**，让每个计数器去数一种**事件**（如"ICache 缺失"），软件读出计数值并组合成派生指标，即可定量评估性能。配合**溢出中断**，还能做统计采样剖析（profiling）。

PMU 是**旁路式**设计：它只监听核内各单元（IFU/IDU/LSU/MMU/RTU/BIU）广播的事件信号，不参与任何执行逻辑，因此对处理器的功能正确性和主频几乎无影响，且默认近零功耗。

---

## 2. 整体结构与子模块分工

```
                         ┌─────────────────── ct_hpcp_top ───────────────────┐
  CP0 (CSR 总线) ───────►│  CSR 访问状态机 / 读写译码 / M-S-U 三视图           │
                         │  事件 rename / 42 个多 bit 事件增量                 │◄── IFU/IDU/LSU/MMU/RTU 事件
                         │  TME/TS 区间剖析 / L2 借道与 BIU 交互               │◄──► BIU (L2/time)
                         │                                                    │
                         │  ┌──────────┐  ┌────────────┐  ┌───────────────┐  │
                         │  │ct_hpcp_  │  │ct_hpcp_    │  │ ct_hpcp_event │  │
                         │  │ cnt ×18  │◄─│ adder_sel  │◄─│   ×16         │  │
                         │  │(64位计数)│  │ (42选1 MUX)│  │ (事件号寄存器) │  │
                         │  └────┬─────┘  └────────────┘  └───────────────┘  │
                         │       │溢出脉冲                                    │
                         │  ┌────▼──────────┐  ┌────────────────────┐        │
                         │  │ct_hpcp_cntof_ │  │ct_hpcp_cntinten_   │        │
                         │  │ reg ×32(sticky)│  │ reg ×32(中断使能)  │───► 溢出中断
                         │  └───────────────┘  └────────────────────┘        │
                         └────────────────────────────────────────────────────┘
```

| 子模块 | 实例数 | 职责 | 详见 |
|--------|--------|------|------|
| `ct_hpcp_top` | 1 | 顶层：CSR、三视图、区间剖析、L2、连接 | `03_hpcp_top.md` |
| `ct_hpcp_cnt` | 18 | 64 位计数器主体 + 溢出脉冲 | `01_hpcp_counters.md` |
| `ct_hpcp_event` | 16 | 可编程计数器的事件号寄存器 | `02_hpcp_events.md` |
| `ct_hpcp_adder_sel` | 16 | 42 选 1 增量 MUX | `02_hpcp_events.md` |
| `ct_hpcp_cntof_reg` | 32 | 单 bit sticky 溢出标志 | `01_hpcp_counters.md` |
| `ct_hpcp_cntinten_reg` | 32 | 单 bit 溢出中断使能 | `01_hpcp_counters.md` |

---

## 3. 资源一览（计数器 / 事件 / CSR）

### 3.1 计数器（`ct_hpcp_top.v:897` HPMCNT_NUM=42；位宽 `ct_hpcp_cnt.v:50` 64）

- **2 个固定**：`mcycle`（周期，每拍 +1）、`minstret`（退休指令，每拍 +0~6）。
- **16 个可编程**：`mhpmcnt3`~`mhpmcnt18`，各数一种事件。
- 全部 **64 位**。注意 RISC-V 定义 HPM3~31，但 C910 只**物理实现到 HPM18**（`ct_hpcp_top.v:4010` 例化止于 cnt18，cnt19~31 例化被注释）。

### 3.2 事件（42 种，6 位事件号；`ct_hpcp_event.v:55` HPMCNT_NUM=42，`:56` HPMEVT_WIDTH=6）

涵盖 I$/D$/L2 访问与缺失、各级 TLB 缺失、分支/BTB/BHT 预测、指令混合（ALU/访存/向量/CSR/FPU/sync/ecall）、前后端 stall、访存重放与非对齐、中断等。完整 42 项清单见 `02_hpcp_events.md` 第 8 节。其中 L2 的 4 个事件（16~19）核内增量为 0，由 BIU/CIU 维护。

### 3.3 CSR 地址（`ct_hpcp_top.v:902~1045`）

| 类别 | M 模式 | S 模式 | U 模式 |
|------|--------|--------|--------|
| 周期/退休 | 0xB00/0xB02 | 0x5E0/0x5E2 | 0xC00/0xC02 |
| HPM3~18 计数 | 0xB03~0xB12 | 0x5E3~0x5F2 | 0xC03~0xC12 |
| 事件选择 | 0x323~0x332 | — | — |
| 控制 MHPMCR | 0x7F0 | 0x5C9 | — |
| 起/止 PC | 0x7F1/0x7F2 | 0x5CA/0x5CB | — |
| inhibit/inten/of | 0x320/0x7CA/0x7CB | 0x5C8/0x5C4/0x5C5 | — |
| 授权位图 MCNTWEN | 0x7C9 | — | — |
| time | — | — | 0xC01 |

---

## 4. 怎么用 PMU 做性能分析

### 第 1 步：选事件（配置 mhpmevent）

给可编程计数器写事件号。例如想统计分支误预测：
- 写 `mhpmevent3 = 6`（BHT 预测失误，event06）
- 写 `mhpmevent4 = 7`（条件分支退休，event07）

写入时硬件会校验事件号 ≤ 42，非法值清 0（`ct_hpcp_event.v:93`）。事件号 0 = 关闭该计数器。

固定计数器 mcycle/minstret 无需配置。

### 第 2 步：圈区间（选触发模式）

通过 `MHPMCR.TME` 选择统计范围（`ct_hpcp_top.v:1291`）：

- **全程统计**（TME=00）：清零计数器 → 运行被测代码 → 读计数器。
- **PC 起止/范围统计**（TME=01/10）：设 `MHPMSP`=起点 PC、`MHPMEP`=终点 PC，硬件自动只在该 PC 区间内计数（`ct_hpcp_top.v:2471~2490`），无需在代码里插桩。适合分析单个函数/循环。

也可用特权过滤（MHPMCR.PMDM/S/U，`ct_hpcp_top.v:1287`）只统计某特权级，例如只数用户态。

### 第 3 步：算派生指标

读出计数值后组合：

| 指标 | 公式 | 用到的事件 |
|------|------|-----------|
| IPC | minstret / mcycle | 固定计数器 |
| I$ MPKI | icache_miss / minstret × 1000 | event02 / minstret |
| D$ 读 MPKI | dcache_read_miss / minstret × 1000 | event13 / minstret |
| 分支误预测率 | (bht_mispred + jmp_mispred) / 退休分支数 | event06+08 / (event07+09) |
| 前端瓶颈占比 | frontend_stall / mcycle | event39 / mcycle |
| 后端瓶颈占比 | backend_stall / mcycle | event40 / mcycle |

由于一拍可退休多条指令，C910 用**多 bit 加法器**保证这些计数不失真（`02_hpcp_events.md` 第 5 节），派生指标才准确。

### 第 4 步：溢出中断采样剖析（profiling）

要做"哪段代码最热"的统计采样：

1. 把目标计数器预置成"再发生 N 次事件就溢出"（软件写计数器，`ct_hpcp_cnt.v:120`）。
2. 开该计数器的中断使能位 `mcntinten`（`ct_hpcp_cntinten_reg.v`）。
3. 运行。第 N 次事件到来时计数器回卷，`cntof` 置 sticky（`ct_hpcp_cntof_reg.v:55`），`hpcp_cp0_int_vld` 触发 PMU 溢出中断（`ct_hpcp_top.v:3042`）。
4. 中断处理读 `mcntof` 确认是哪个计数器溢出、记录当前 PC，清 `cntof`、重装计数器。
5. 多次采样后，PC 直方图就是热点剖析（perf record 的硬件原理）。

---

## 5. 关键设计决策汇总

| 决策 | 内容 | 为什么 | 出处 |
|------|------|--------|------|
| 旁路式架构 | PMU 只监听事件，不在执行路径 | 对功能/主频零影响 | 全局 |
| 2 固定 + 16 可编程 64 位计数器 | mcycle/minstret + hpmcnt3~18 | 兼顾通用与面积；64 位极少溢出 | `ct_hpcp_cnt.v:50`、`ct_hpcp_top.v:1300` |
| 只实现 HPM3~18 | 不实现 HPM19~31 | 16 个可编程槽够用，省面积 | `ct_hpcp_top.v:4010,4026` |
| **多 bit（4 位）事件增量** | 每拍可 +0~8 | 超标量一拍多事件，否则计数失真 | `ct_hpcp_top.v:1419,1437` |
| 6 位事件号 + 写时裁剪 | 非法事件号清 0 | 防 MUX default 的 x 污染计数 | `ct_hpcp_event.v:93` |
| 溢出 sticky + 单拍脉冲分工 | cnt 出脉冲，cntof_reg 保存 | 采样剖析定位溢出源 | `ct_hpcp_cntof_reg.v:55` |
| M/S/U 三视图 + mcntwen | 一组物理寄存器多套地址 | 合规 + 权限隔离 + 省面积 | `ct_hpcp_top.v:2619,4137` |
| TME/TS 区间剖析 | 按 PC 起止/范围自动计数 | 函数级分析免插桩 | `ct_hpcp_top.v:2471` |
| 特权过滤 PMDM/S/U | 按特权级停计数 | 只统计目标特权级 | `ct_hpcp_top.v:1287` |
| L2 计数借道 BIU | L2 计数器代理成普通 hpmcounter | 软件视图统一 | `ct_hpcp_top.v:4288` |
| 逐计数器门控 + 使能广播 | 未用计数器停时钟，并通知各单元 | 默认近零功耗 | `ct_hpcp_cnt.v:91`、`ct_hpcp_top.v:4345` |

---

## 6. 延伸阅读

- `01_hpcp_counters.md` —— 计数器主体、溢出检测、使能链、溢出中断
- `02_hpcp_events.md` —— 42 种事件、多 bit 加法器、事件 MUX
- `03_hpcp_top.md` —— CSR 访问、三视图、区间剖析、L2 交互
- `README.md` —— 索引与学习路径

---

*本总览基于对 pmu/rtl 全部 6 个 RTL 文件的通读，计数器数/位宽/事件数/CSR 地址均带源码行号，未作推测。*
