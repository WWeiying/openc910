# C910 PMU / HPCP（硬件性能计数器）模块教学文档

本目录是对 OpenC910 处理器 **PMU（Performance Monitor Unit，内部代号 HPCP）** 的逐模块教学文档，基于对 RTL 源码的完整通读编写，所有计数器个数、位宽、事件数、CSR 地址均标注源码 `file:line`，不作推测。

RTL 源码位置：`C910_RTL_FACTORY/gen_rtl/pmu/rtl/`

---

## 文档索引

| 文档 | 主题 | 覆盖 RTL | 行数 |
|------|------|----------|------|
| [00_pmu_overview.md](./00_pmu_overview.md) | PMU 是什么、如何做性能分析、关键设计决策汇总 | 全部 6 文件（总览） | — |
| [01_hpcp_counters.md](./01_hpcp_counters.md) | 64 位计数器、溢出检测、溢出中断、mcountinhibit、特权过滤 | `ct_hpcp_cnt.v` / `ct_hpcp_cntof_reg.v` / `ct_hpcp_cntinten_reg.v` | 153 / 63 / 57 |
| [02_hpcp_events.md](./02_hpcp_events.md) | 42 种事件、6 位事件选择、超标量多 bit 加法器、事件清单 | `ct_hpcp_event.v` / `ct_hpcp_adder_sel.v` | 103 / 260 |
| [03_hpcp_top.md](./03_hpcp_top.md) | CSR 访问、M/S/U 三视图、区间剖析、L2 交互、整体连接 | `ct_hpcp_top.v` | 4404 |

---

## RTL 文件与模块对照

| RTL 文件 | 模块 | 例化数 | 作用 |
|----------|------|--------|------|
| `ct_hpcp_top.v` | `ct_hpcp_top` | 1 | PMU 顶层：CSR、三视图、区间剖析、L2、连接 |
| `ct_hpcp_cnt.v` | `ct_hpcp_cnt` | 18 | 64 位计数器主体 + 溢出脉冲 |
| `ct_hpcp_event.v` | `ct_hpcp_event` | 16 | 可编程计数器的事件号寄存器（mhpmevent） |
| `ct_hpcp_adder_sel.v` | `ct_hpcp_adder_sel` | 16 | 42 选 1 事件增量 MUX |
| `ct_hpcp_cntof_reg.v` | `ct_hpcp_cntof_reg` | 32 | 单 bit sticky 溢出标志（mcntof） |
| `ct_hpcp_cntinten_reg.v` | `ct_hpcp_cntinten_reg` | 32 | 单 bit 溢出中断使能（mcntinten） |

---

## 关键数字速查

| 项目 | 数值 | 出处 |
|------|------|------|
| 计数器位宽 | 64 位 | `ct_hpcp_cnt.v:50` |
| 固定计数器 | 2 个（mcycle / minstret） | `ct_hpcp_top.v:3703,3722` |
| 可编程计数器 | 16 个（mhpmcnt3~18） | `ct_hpcp_top.v:1300~1315,4010` |
| 事件总数 | 42 种 | `ct_hpcp_top.v:897` / `ct_hpcp_event.v:55` |
| 事件号位宽 | 6 位 | `ct_hpcp_event.v:56` |
| 每拍最大增量 | +8（4 位增量） | `ct_hpcp_top.v:1437` |
| CSR 地址 | MHPMCR=0x7F0、MCYCLE=0xB00、MHPMEVT3=0x323 … | `ct_hpcp_top.v:902~1045` |

---

## 学习路径

**入门（理解 PMU 用途）**
1. 读 `00_pmu_overview.md` 第 1、4 节 —— 搞清 PMU 是什么、怎么"选事件→圈区间→算 IPC/MPKI→溢出采样"。

**进阶（理解硬件实现）**
2. 读 `01_hpcp_counters.md` —— 计数器如何累加、如何检测溢出、5 道使能闸门、溢出中断怎么产生。
3. 读 `02_hpcp_events.md` —— 重点理解"超标量为什么需要多 bit 加法器"（第 5 节）和 42 种事件清单（第 8 节）。

**深入（理解系统整合）**
4. 读 `03_hpcp_top.md` —— CSR 两拍状态机、M/S/U 三视图与 mcntwen 权限、TME/TS 区间剖析、L2 借道 BIU。
5. 回到 `00_pmu_overview.md` 第 5 节，对照"关键设计决策汇总"复盘整体设计哲学。

**实践建议**：带着一个具体问题去读，例如"我想测某函数的分支误预测率该怎么配寄存器"，沿着 overview 第 4 节 → events 第 8 节（选事件号 6/7）→ top 第 8 节（设 MHPMSP/MHPMEP）走一遍，理解最深。
