# C910 PMU / HPCP（硬件性能计数器）模块教学文档

本目录是对 OpenC910 处理器 **PMU（Performance Monitor Unit，RTL 前缀
`hpcp`）** 的逐模块教学文档。文档以当前仓库 RTL 为事实基准，并把三类内容
明确分开：

1. 可以从组合表达式、寄存器更新优先级和实例数量直接证明的实现事实；
2. 用于帮助理解设计意图的体系结构解释；
3. 必须依赖仿真、综合、STA 或功耗报告才能确认的实现结果。

`hpcp` 在 RTL 中是模块/信号命名前缀，源码没有定义一个必须扩写的英文全称。
文中的行号用于定位当前版本，后续 RTL 生成或编辑可能使行号移动，应同时以
模块名和信号名检索。

RTL 源码位置：`C910_RTL_FACTORY/gen_rtl/pmu/rtl/`

---

## 文档索引

| 文档 | 主题 | 覆盖 RTL | 行数 |
|------|------|----------|------|
| [00_pmu_overview.md](./00_pmu_overview.md) | PMU 是什么、如何做性能分析、关键设计决策汇总 | 全部 6 文件（总览） | — |
| [01_hpcp_counters.md](./01_hpcp_counters.md) | 64 位计数器、事件捕获/更新流水、溢出状态和中断、多级使能 | `ct_hpcp_cnt.v` / `ct_hpcp_cntof_reg.v` / `ct_hpcp_cntinten_reg.v` | 153 / 63 / 57 |
| [02_hpcp_events.md](./02_hpcp_events.md) | 42 个事件号、槽位/周期/OR 事件口径、4 位增量和选择器 | `ct_hpcp_event.v` / `ct_hpcp_adder_sel.v` | 103 / 260 |
| [03_hpcp_top.md](./03_hpcp_top.md) | CSR 状态机、标准/自定义视图、TME/TS、L2 映射约束 | `ct_hpcp_top.v` | 4403 |

---

## RTL 文件与模块对照

| RTL 文件 | 模块 | 例化数 | 作用 |
|----------|------|--------|------|
| `ct_hpcp_top.v` | `ct_hpcp_top` | 1 | PMU 顶层：CSR、三视图、区间剖析、L2、连接 |
| `ct_hpcp_cnt.v` | `ct_hpcp_cnt` | 18 | 64 位计数器主体、事件流水寄存和溢出通知 |
| `ct_hpcp_event.v` | `ct_hpcp_event` | 16 | 可编程计数器的事件号寄存器（mhpmevent） |
| `ct_hpcp_adder_sel.v` | `ct_hpcp_adder_sel` | 16 | 42 选 1 事件增量 MUX |
| `ct_hpcp_cntof_reg.v` | `ct_hpcp_cntof_reg` | 31 | bit0、2~31 的 sticky 状态；bit1 在顶层直接 tie 0 |
| `ct_hpcp_cntinten_reg.v` | `ct_hpcp_cntinten_reg` | 31 | bit0、2~31 的中断使能；bit1 在顶层 tie 0 |

注意“18 个计数主体”和“32 位控制向量”不是同一个数量。HPM19~31 没有
`ct_hpcp_cnt`、`ct_hpcp_event` 和 `adder_sel` 实例，但 `mcountinhibit`、
bit19~31 的 `cntinten_reg` 与 `cntof_reg` 状态仍存在。软件写出的 overflow
与 interrupt-enable 位仍可参与中断 OR，因此不能把这些槽笼统描述成
“完全不存在”。bit1 是单独的固定 0 空槽，不属于这组可写状态。

---

## 关键数字速查

| 项目 | 数值 | 出处 |
|------|------|------|
| 计数器位宽 | 64 位 | `ct_hpcp_cnt.v:50` |
| 固定计数器 | 2 个（mcycle / minstret） | `ct_hpcp_top.v:3703,3722` |
| 可编程计数器 | 16 个（mhpmcnt3~18） | `ct_hpcp_top.v:1300~1315,4010` |
| 最大合法事件号 | 42；事件号 0 表示不采样本地事件 | `ct_hpcp_event.v:55,93~94` |
| 事件号位宽 | 6 位 | `ct_hpcp_event.v:56` |
| 普通事件最大候选增量 | +8（RF 八路状态求和） | `ct_hpcp_top.v:1437~1443` |
| `minstret` 表达式上限 | +9（三个 2 bit `inst_num` 项之和） | `ct_hpcp_top.v:1324~1332` |
| CSR 地址 | MHPMCR=0x7F0、MCYCLE=0xB00、MHPMEVT3=0x323 … | `ct_hpcp_top.v:902~1045` |

“候选增量”会先进入 `ct_hpcp_cnt` 的 `cnt_adder_ff`，再在后续有效计数时钟
边沿更新 64 位计数值。表中的 +8/+9 不是“CSR 在同一组合周期立刻增加”的含义。

---

## 学习路径

**入门（理解 PMU 用途）**
1. 读 `00_pmu_overview.md` 第 1、4 节 —— 搞清 PMU 是什么、怎么"选事件→圈区间→算 IPC/MPKI→溢出采样"。

**进阶（理解硬件实现）**
2. 读 `01_hpcp_counters.md` —— 重点区分事件捕获拍、计数更新拍、软件写提交、
   溢出通知、sticky 状态和中断电平。
3. 读 `02_hpcp_events.md` —— 重点区分 RTU 退休槽、IDU IR 分类、RF 管线状态、
   stall 高电平周期和 OR 合并事件，避免用不同口径直接计算占比。

**深入（理解系统整合）**
4. 读 `03_hpcp_top.md` —— EX1/EX2 完成语义、标准和 C910 自定义 CSR 的
   边界、TME/TS 区间控制、L2 借道 BIU 及其一对一映射约束。
5. 回到 `00_pmu_overview.md` 第 5 节，对照"关键设计决策汇总"复盘整体设计哲学。

**实践建议**：例如测某函数的条件分支方向误预测率，可以用 event6 作为分子、
event7 作为退休条件分支槽位分母，再配置 TME/TS 区间。解释结果前还应检查：
起止边界是否符合预期、计数器尾部流水是否落入窗口、event6 只取退休槽0 的
`bht_mispred` 是否覆盖目标场景，以及多次运行的计数是否稳定。
