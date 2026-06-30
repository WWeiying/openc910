# 经典开源与商业处理器微结构 / Benchmark 调研

本文用于给 OpenC910 / 玄铁 C910 的 benchmark 结果找参照系。重点不是做绝对排名，而是把公开可查的微结构参数、benchmark 指标、来源强度和可比性风险放到同一套表里。

更新时间：2026-06-30。

## 0. 读表口径

- **优先来源**：官方 TRM / optimization guide / datasheet、开源仓库文档、论文、厂商公开 benchmark、SPEC 官方结果库。
- **Benchmark 不天然可比**：Dhrystone、CoreMark、SPEC 的分数强依赖编译器、flags、库、内存系统、频率、电源策略、benchmark 版本和是否遵守发布规则。
- **Dhrystone 规范重点**：Dhrystone 2.1 的可发布结果应说明优化选项；默认口径是不使用 `register`，并避免过程合并 / 内联把 `Proc_*`、`Func_*` 直接消掉。
- **SPEC 口径**：SPEC CPU2006 / CPU2017 必须区分 speed / rate、base / peak、单核 / 多核、编译器版本和系统配置。本文不把某个服务器 SKU 的 SPEC rate 当成“微结构单核分数”。
- **本仓库实测**：本文中的 OpenC910 Dhrystone 标准配置来自 `smart_run` RTL 仿真，不是 FPGA / ASIC 上板结果。

来源强度：

| 等级 | 含义 | 用法 |
|---|---|---|
| A | 官方手册 / datasheet / 项目文档 / 本仓库实测 | 可直接引用，但仍要写配置 |
| B | 学术论文 / Hot Chips / 厂商公开演示 | 可引用，需要绑定版本、配置和会议/论文 |
| C | 第三方反向分析 / 评测 / 社区报告 | 只能作辅助，不宜当作硬件规格事实 |
| D | 行业常见口径但无法定位到稳定原始表 | 只能保留为范围或备注 |

符号说明：

| 符号 | 含义 |
|---|---|
| `—` | 没有找到足够可靠的公开数值，或该 benchmark 对该核不合适 |
| `约` | 公开资料给出的是图表估读、不同配置区间、或非同一条件的代表值 |
| `reported` | 厂商 / 项目 / 论文公开宣称值，未在本文环境复现 |
| `measured here` | 本仓库当前环境实测 |

## 1. 开源 / 可研究处理器微结构指标

| 处理器 | ISA / 位宽 | 定位 | 流水线 / 顺序性 | 前端 / 发射宽度 | OoO 窗口 | Cache / Memory | 分支预测 | SIMD / Vector | 来源强度 | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|
| PicoRV32 | RV32IMC 可配 | 极小 FPGA / MCU 软核 | 多周期 in-order | 单指令串行 | 无 ROB | 通常无 cache，SoC 外挂 | 简单控制流 | 无 | A: 项目文档 | 以面积/Fmax 为目标，不适合和应用核比 IPC |
| NEORV32 | RV32IMC/B 等可配 | 可移植 MCU SoC | in-order，多配置 | single-issue | 无 ROB | 可选 I/D cache / TCM | 简单动态或静态配置 | 无 | A: 项目文档 | 教学/MCU 友好，benchmark 受配置影响很大 |
| lowRISC Ibex | RV32IMC，可配 RV32E/B | 小型 MCU / 安全控制核 | 2-stage 或 3-stage，in-order | single-issue | 无 ROB | 通常无 cache，或 SoC 侧集成 | 静态 / 可选 branch target ALU | 无 | A: Ibex 文档 | 有官方性能章节，CoreMark 随 small/maxperf 配置变化 |
| VexRiscv | RV32，可插件化 IMAC/MMU/cache | FPGA 友好软核 | 2-6 stage 可配，in-order | single-issue | 无 ROB | I/D cache、MMU 插件可选 | 可插件化预测器 | 无标准向量 | A/C: 项目 + 社区 | SpinalHDL 插件生态，分数取决于插件组合 |
| Rocket | RV64GC / RV32 | 经典 RISC-V 标量 Linux 核 | 5-stage，in-order | single-issue | 无 ROB | L1 I/D + TileLink L2 依 SoC 配置 | BHT/BTB/RAS 可配 | F/D 可配 | A/B: Rocket/Chipyard | 学术 SoC 基线，经常作为 BOOM 对照 |
| CVA6 / Ariane | RV64GC | 开源 Linux 应用核 | 6-stage，in-order | single-issue，scoreboard | 无 ROB | 常见 16KB I$ + 32KB D$ 量级，L2 由 SoC 决定 | 动态预测，BTB/BHT/RAS 依版本 | FPU 可配 | A/B: OpenHW + Ariane paper | 比 Rocket 更偏应用核，但仍无法隐藏长延迟 |
| Berkeley BOOM | RV64GC | 可配置 OoO 研究核 | OoO superscalar | 2-4 wide 典型配置 | ROB/issue queue 可配，约 64-160+ 常见 | Chipyard cache 子系统 | BTB/BHT/RAS/TAGE 依版本 | F/D 可配，vector 依集成 | A/B: BOOM docs/papers | 不是固定 SKU，必须报告 BOOM config |
| SonicBOOM | RV64GC | BOOM 后续高性能版本 | OoO superscalar | 3-wide 量级 | 160+ 量级，依配置 | Chipyard cache 子系统 | 更强前端 / 预测 | F/D 可配 | B: 论文/项目报告 | 公开论文常用 SPEC CPU2006 做 IPC/性能评估 |
| OpenC910 / 玄铁 C910 | RV64GC + XTheadC / XIE / XMAE | 开源高性能应用处理器核 | 9-12 stage，OoO superscalar | 3 发射 / 8 执行；本仓库文档拆为 3 decode / 4 dispatch / 8 ports | ROB 64；integer PRF 96；FP/vector PRF 64 | 64KB I$ + 64KB D$，2-way，64B line；L2 1MB | L0-BTB 16，BTB 1024x4，Bi-Mode BHT 64Kb，RAS 18，Loop Buffer | 128-bit 玄铁早期向量扩展，非 RVV 1.0 | A: 本仓库文档 + C910 手册 | 本仓库重点对象；ROB 比 A72/A76/Skylake 等小 |
| XiangShan Nanhu | RV64GC + RVV 方向 | 高性能开源 OoO 核 | OoO superscalar | 4-wide 量级 | 公开资料常见 192-entry ROB 量级 | 64KB 级 L1，完整 cache 子系统 | TAGE/ITTAGE/RAS 等现代预测器 | RVV 方向 | B: 项目/论文/Hot Chips | 面向 SPEC 的开源高性能路线，版本要绑定 commit |
| XiangShan Kunminghu | RV64GC + RVV 方向 | 下一代高性能开源 OoO 核 | 更宽 OoO superscalar | 6-wide 量级公开目标 | 更大窗口，版本变化快 | 更强 memory hierarchy | 更强 TAGE-like predictor | RVV 方向 | B: 项目报告 | 演进快，应引用具体阶段文档 |

## 2. 商业处理器微结构指标

| 处理器 | ISA / 位宽 | 定位 | 流水线 / 顺序性 | 前端 / 发射宽度 | OoO 窗口 | Cache / Memory | 分支预测 | SIMD / Vector | 来源强度 | 备注 |
|---|---|---|---|---|---|---|---|---|---|---|
| Arm Cortex-M7 | Armv7E-M | 高性能 MCU | 6-stage，in-order，dual-issue 量级 | 双发射部分场景 | 无 ROB | 可选 I/D cache，TCM | 静态/简单动态 | DSP + 单/双精度 FPU 可配 | A: Arm 文档 | CoreMark/Dhrystone 在 MCU 宣传中常见 |
| Arm Cortex-M33 | Armv8-M | 安全 MCU | in-order，single/limited dual issue 量级 | 窄前端 | 无 ROB | 可选 cache/TCM | 简单预测 | DSP/FPU 可配 | A: Arm 文档 | TrustZone-M，性能不是主线应用核级别 |
| Arm Cortex-A53 | Armv8-A AArch64/AArch32 | 小核 / 低功耗 Linux | 8-stage，in-order | 2-wide decode / dual-issue 量级 | 无 ROB | L1 I/D 可配，常见 32KB/32KB；共享 L2 | 动态预测 | NEON / FP | A: Arm 文档 | A 系列小核基线，适合与 U74/CVA6 这类 in-order 应用核对比 |
| Arm Cortex-A55 | Armv8.2-A | 新一代小核 | in-order，dual-issue | 2-wide 量级 | 无 ROB | 32KB/64KB L1 依配置，私有 L2 可配 | 改进动态预测 | NEON / FP | A: Arm 文档 | 相比 A53 有内存系统和能效提升 |
| Arm Cortex-A72 | Armv8-A | 高性能移动 / 嵌入式 big core | OoO superscalar，约 15-stage 量级 | Arm 官方博客说明 3-wide decode、5 µop dispatch、8-wide issue | 公开资料常见 128-entry 量级，Arm 未完整逐项公开 | 48KB I$，32KB D$；L2 512KB-4MB 依实现 | Arm 称使用新的高效分支预测器 | NEON / FP，FMUL/FADD 3-cycle，FMAC 6-cycle | A/B: Arm blog + SoC docs | 与 C910 属同级应用核参照 |
| Arm Cortex-A76 | Armv8.2-A | 高性能移动 / Neoverse N1 基础 | OoO superscalar | 4-wide decode 量级，8-wide issue 量级 | 128-entry 量级公开资料常见 | 64KB I$，64KB D$ 常见；私有 L2 | 更强方向/目标预测和 µBTB | NEON / FP | A/B: Arm docs/blogs | A72/A75 之后的重要性能跃迁点 |
| Arm Neoverse N1 | Armv8.2-A | 服务器 / 云应用核 | A76 派生 OoO | 4-wide 量级 | 128-entry 量级 | 64KB I$ + 64KB D$，私有 L2，系统级 mesh/CCN 依 SoC | 服务器化前端/预测 | NEON / FP | A/B: Arm docs + SPEC/Vendor | Ampere Altra、AWS Graviton2 等常见 N1 平台提供 SPEC 对比 |
| SiFive U54/U74 | RV64GC | 商用 RISC-V Linux in-order 应用核 | U74 常见 8-stage，in-order | dual-issue 量级 | 无 ROB | 常见 32KB I$ + 32KB D$，共享 L2 依 core complex | 动态预测 | F/D，可选扩展依产品 | A/B: SiFive docs/briefs | HiFive Unleashed/Unmatched/FU740 代表性应用 |
| SiFive P550 | RV64GBC / RV64GC 系列 | 商用 RISC-V OoO 应用核 | 13-stage，triple-issue，OoO | triple-issue 公开描述 | 厂商未完整公开 | L1/L2 依 core complex | 动态预测 | F/D；P550 Gen 3 无大向量定位 | A/B: SiFive product page/brief | 厂商公开用 SPECint2006 / CoreMark/MHz 宣传 |
| SiFive P670 / P570 | RV64GCV / RVA profile 方向 | 高性能商用 RISC-V OoO | OoO superscalar | 比 P550 更宽/更深 | 厂商未完整公开 | 依实现 | 动态预测 | RVV / vector crypto 方向 | A/B: SiFive product page/brief | 详细队列参数未完全公开 |
| Intel Skylake client/server | x86-64 | 高性能通用 CPU | OoO superscalar | 4-wide legacy decode；µop cache 约 6 µops/cycle | ROB 224；scheduler 97 量级 | 32KB I$ + 32KB D$；256KB L2 client / 更大 server；共享 LLC | 复杂动态预测 / BTB / RSB | SSE/AVX2，部分 SKU AVX-512 | A/C: Intel manual + third-party µarch | SPEC 公开结果丰富，但平台差异大 |
| AMD Zen 1 | x86-64 | 高性能通用 CPU | OoO superscalar | 4-wide decode，µop cache | ROB 192 量级 | 64KB I$ + 32KB D$；512KB L2；共享 L3 | 复杂动态预测 | SSE/AVX2 | A/C: AMD guide + third-party µarch | Zen 是 AMD 重新进入高性能区间的代表 |
| AMD Zen 4 | x86-64 | 高性能通用 CPU | OoO superscalar | 更宽前端，µop cache | ROB 320 量级公开资料常见 | 32KB D$，较大 L2/LLC，依 SKU | 更强预测 | AVX-512 语义支持 | A/C: AMD guide + third-party µarch | 商业核很多队列细节来自优化手册/反向分析 |
| Apple M1 Firestorm | Armv8-A | 高性能移动/桌面 SoC | 大宽度 OoO superscalar | 第三方认为前端很宽 | 大 ROB / 大队列，非官方 | 大 L1 / 大系统缓存 | 高级预测器，细节未公开 | NEON/AMX-like 矩阵单元非公开细节 | C: 第三方分析 | 性能强，但不适合把反向分析数字当官方规格 |

## 3. 经典 Benchmark 公开成绩摘录

### 3.1 Dhrystone / CoreMark

| 处理器 | Dhrystone DMIPS/MHz | CoreMark/MHz | 来源强度 | 条件 / 备注 |
|---|---:|---:|---|---|
| OpenC910 / 当前仓库标准配置 | **4.204** | — | A: measured here | RTL 仿真，Dhrystone 2.1，1000 runs，`-O3`，禁用内联/过程合并，不使用 `register` |
| OpenC910 / 当前仓库激进优化旧结果 | 4.900 | — | A: measured here, non-standard | 旧结果允许 Dhrystone 子程序内联/合并，不建议作为正式口径 |
| 玄铁 C910 / 集成手册公开口径 | 6.0 | 7.0 | A: 本地官方手册 | `doc/玄铁C910集成手册_20240627.pdf` 写明，属于厂商公开优化口径 |
| lowRISC Ibex | — | 约 2.4-3.1 | A: Ibex docs | 取决于 small / maxperf 配置、乘除法、branch target ALU、编译器 |
| VexRiscv | 约 1.4-1.8 | 约 2-3 | C: 项目/FPGA报告 | 插件化软核，数据只适合看量级 |
| Rocket | — | 约 2-3 | B/C: 学术/项目报告 | SoC/cache/DRAM 配置影响很大，无单一官方口径 |
| CVA6 / Ariane | — | 约 3-4 | B/C: 项目/论文报告 | single-issue in-order 应用核，FPU/cache/FPGA/ASIC 配置影响明显 |
| Arm Cortex-M7 | 约 5 | 约 5+ | A/B: Arm/EEMBC 口径 | MCU 场景常见，cache/TCM/编译器影响很大 |
| Arm Cortex-A53 | 约 2.3 | 约 4.x | B/C: SoC/vendor reported | in-order dual-issue 小核；不同 SoC / compiler 差异明显 |
| Arm Cortex-A72 | 约 4.7-5.8 | 约 6-7+ | A/B: SoC/vendor reported | AMD/Xilinx Versal A72 文档可见 5.80 DMIPS/MHz 量级 |
| SiFive U54/U74 系列 | 约 2.5-2.7 | 约 5.0-5.1 | A/B: SiFive/vendor reported | in-order dual-issue RISC-V 应用核 |
| SiFive P550 | — | 约 8.6-8.7 | A/B: SiFive reported | OoO RISC-V，厂商通常同时给 SPECint2006/GHz 和 CoreMark/MHz |
| SiFive P670 / P570 | — | 约 10+ 到 13+ | A/B: SiFive reported | 不同代际和 vector 配置差异大，必须绑定 product brief |
| Intel Skylake / AMD Zen | — | — | — | x86 商业 CPU 通常用 SPEC、Geekbench、server workload；CoreMark/Dhrystone 不作为主宣传口径 |

### 3.2 SPEC CPU2006 / CPU2017

| 处理器 / 平台 | SPECint2006/GHz 或等价摘录 | SPEC CPU2017 摘录 | 来源强度 | 条件 / 备注 |
|---|---:|---:|---|---|
| OpenC910 / 当前仓库 | — | — | — | RTL 仿真跑完整 SPEC 成本很高；当前只正式跑了 Dhrystone |
| BOOM / SonicBOOM | 约 4-6+ 到更高，依配置 | — | B: academic reported | 不同 BOOM 配置差异极大，应引用具体 BOOM config 和论文版本 |
| XiangShan Nanhu | 约 10 SPECint2006/GHz 量级 | — | B: project / paper | 项目常用 SPECint2006/GHz 跟踪迭代，需绑定 commit / tapeout |
| XiangShan Kunminghu | 高于 Nanhu，阶段值变化快 | — | B: project roadmap / Hot Chips | 最好引用官方阶段报告，不要写成固定最终值 |
| SiFive P550 | 约 8.6 SPECint2006/GHz | — | A/B: SiFive reported | 厂商宣传口径，完整 base/peak 配置需查 product brief |
| SiFive P670 / P570 | 约 12+ SPECint2006/GHz 量级 | — | A/B: SiFive reported | 版本/工艺/配置变化明显 |
| Arm Cortex-A72 | 约 6-8 SPECint2006/GHz 量级 | — | B/C: vendor / academic / SoC reported | A72 平台较多，频率、内存、编译器差异明显 |
| Arm Cortex-A76 | 相比 A75/A73 有明显 uplift | — | A/B: Arm official relative data | Arm 官方更多给相对提升，绝对 SPEC 分数常来自第三方 SoC 评测 |
| Arm Neoverse N1 / Ampere Altra / Graviton2 | — | 有公开 SPEC CPU2017 rate/speed 结果 | A: SPEC official / vendor | server SoC 多核 rate 更常见，不能直接和单核 RTL 仿真比较 |
| Intel Skylake server/client | — | SPEC CPU2017 官方结果丰富 | A: SPEC official | 必须按 SKU、编译器、base/peak、speed/rate 分开 |
| AMD Zen / Zen2 / Zen4 | — | SPEC CPU2017 官方结果丰富 | A: SPEC official | server EPYC 常用 rate，桌面 Ryzen 常用第三方 speed |
| Apple M1 | — | 第三方 SPEC2017 单线程结果较多 | C: third-party | 可作性能参考，不宜作硬件结构定论 |

## 4. C910 和 A72/A76/SiFive P 系列的关键对比

| 指标 | C910 | Cortex-A72 | Cortex-A76 / N1 | SiFive P550 | 解读 |
|---|---|---|---|---|---|
| ISA | RV64GC + XTheadC | Armv8-A | Armv8.2-A | RV64GBC / RV64GC 系列 | ISA 影响编译器、代码密度和 benchmark 可比性 |
| 流水线 | 9-12 stage | 约 15-stage 量级 | 更深/更高频移动 OoO | 13-stage | A72/P550 与 C910 属同级 OoO 应用核 |
| 前端 | 128-bit fetch，3 decode | 3-wide decode | 4-wide decode 量级 | triple-issue 公开描述 | C910 前端宽度接近 A72，但低于 A76 量级 |
| Dispatch / Issue | 4 dispatch，8 execution ports | 5 µop dispatch，8-wide issue | 8-wide issue 量级 | triple-issue OoO | 只看端口数不够，还要看 issue queue 和窗口 |
| ROB / 窗口 | ROB 64 | 公开资料常见 128 量级 | 128 量级 | 未完整公开 | C910 最大短板之一是窗口相对小 |
| L1 I/D | 64KB / 64KB | 48KB / 32KB | 64KB / 64KB 常见 | 依 core complex | C910 L1 容量不小，但替换、预取、miss handling 同样关键 |
| 分支预测 | L0-BTB + BTB + Bi-Mode BHT + RAS + Loop Buffer | Arm 官方称新高效预测器 | 更强前端预测 | 动态预测，未完整公开 | Dhrystone/CoreMark 对前端预测敏感 |
| 公开 Dhrystone | 手册 6.0；本仓库标准 4.204 | 约 4.7-5.8 | 较少用 Dhrystone | 较少用 Dhrystone | C910 标准实测低于厂商优化口径，符合编译规则差异 |
| 公开 CoreMark | 手册 7.0 | 约 6-7+ | 平台差异大 | 约 8.6-8.7 | CoreMark 比 Dhrystone 更适合宣传，但仍小工作集 |
| SPEC | 当前未跑 | 约 6-8/GHz 量级 | 更高 | 约 8.6/GHz | 若要论文级对比，SPEC kernel 或完整 SPEC 才更有意义 |

## 5. 按处理器类型解读

### 5.1 小型 MCU / 控制核

代表：PicoRV32、NEORV32、Ibex、VexRiscv 小配置、Cortex-M 系列。

这类核通常是单发射、短流水、无乱序执行。Dhrystone / CoreMark/MHz 可以反映编译器和基本整数路径效率，但不代表应用处理器能力。它们的优势是面积、功耗、可验证性和实时性。

### 5.2 In-order Linux 应用核

代表：Rocket、CVA6、SiFive U54/U74、Cortex-A53/A55。

这类核能跑 Linux，有 MMU/cache/FPU，CoreMark/MHz 往往明显高于 MCU 核，但遇到 cache miss、分支误预测、长依赖链时没有 OoO 窗口隐藏延迟。它们适合作为 C910 的“低一档应用核”参照。

### 5.3 OoO RISC-V 应用核

代表：BOOM/SonicBOOM、OpenC910、XiangShan、SiFive P550/P670。

这类核开始具备与 Arm A72/A76、低端 x86 core 对比的资格。关键指标不只是 decode/issue 宽度，还包括：

| 指标 | 为什么重要 | 对 C910 的含义 |
|---|---|---|
| ROB / load queue / store queue | 决定能隐藏多少 miss / 长延迟 | C910 ROB 64，比 A72/A76/Skylake 这类商业 OoO 核小 |
| 分支预测器 | 决定前端有效供给 | C910 有 L0-BTB + BTB + Bi-Mode BHT + RAS + Loop Buffer，结构完整 |
| 取指/译码宽度 | 决定前端峰值吞吐 | C910 128-bit fetch、3 decode，接近 A72 的 3-wide decode |
| dispatch / issue / retire | 决定后端吞吐上限 | C910 4 dispatch、8 exec ports、3 retire entry/cycle |
| cache hierarchy | Dhrystone/CoreMark 受影响较小，SPEC/应用受影响很大 | C910 L1 I/D 都是 64KB，容量不小，但 miss handling 和 prefetch 同样重要 |

### 5.4 商业高性能 Arm / x86 核

代表：Cortex-A72/A76/Neoverse N1、Intel Skylake、AMD Zen。

这些核的优势通常不只在“宽度”，而在物理实现、频率、编译器、预取器、分支预测、cache/memory hierarchy、功耗管理和多年软件生态。用 Dhrystone 或 CoreMark 单点指标比较 C910 与它们容易误导；更合适的是分层：

| 层级 | 推荐 benchmark | 说明 |
|---|---|---|
| 基本整数控制流 | Dhrystone | 只能作补充指标，必须说明编译器和 no-inline 规则 |
| 嵌入式综合整数 | CoreMark | 比 Dhrystone 更现代，但仍小工作集 |
| 应用级整数/浮点 | SPEC CPU2006/2017 | 更接近商业宣传与论文，但 RTL 仿真成本极高 |
| 内存带宽/streaming | STREAM / memcpy / lmbench 子集 | 需要控制数据规模，RTL 中不能太大 |
| 分支/前端微基准 | branch predictor kernels | 对 C910 这类 OoO 核很有解释力 |
| cache/TLB/LSU | stride/capacity/pointer chasing | 能解释 SPEC 或应用 benchmark 的失分原因 |

## 6. C910 当前 benchmark 位置

当前本仓库已经正式跑出的可引用结果：

| Benchmark | 配置 | 结果 | 归档 |
|---|---|---:|---|
| Dhrystone 2.1 | 1000 runs，`-O3`，禁用 Dhrystone 子程序内联/过程合并，不使用 `register` | **4.204 DMIPS/MHz** | `smart_run/results/dhrystone_std_1000/` |

与同类公开指标的大致位置：

| 对比对象 | 大致范围 | C910 当前结果怎么理解 |
|---|---:|---|
| Cortex-A53 / U74 这类 in-order 应用核 | 约 2-3 DMIPS/MHz | C910 标准实测明显高一档，符合 OoO 应用核定位 |
| Cortex-A72 这类同级 OoO Arm 核 | 约 4.7-5.8 DMIPS/MHz | C910 当前标准 Dhrystone 低于部分 A72 公开平台，但已在同级区间 |
| C910 厂商公开优化口径 | 6.0 DMIPS/MHz / 7.0 CoreMark/MHz | 手册口径通常使用更适合宣传的编译器/flags，不能直接等同于本仓库 no-inline 标准 Dhrystone |
| x86 Skylake / Zen | 不常用 Dhrystone/MHz 作正式指标 | 不建议用 Dhrystone 对比，应看 SPEC/真实应用 |

## 7. 后续建议：应该补哪些 benchmark

| 优先级 | Benchmark | 目的 | 预计难度 | 备注 |
|---:|---|---|---|---|
| P0 | CoreMark 标准化复跑 | 与 C910 手册 `7.0 CoreMark/MHz` 和商用 IP 宣传口径对齐 | 低 | 需要固定 iterations、编译器、flags、是否允许 vendor flags |
| P0 | Embench 子集 | 更现代的小型 embedded workload | 中 | 比 Dhrystone 更有说服力，适合 RTL 小规模仿真 |
| P1 | MiBench 子集 | 应用型整数 / 内存 / 分支混合 | 中 | 选 qsort、crc32、sha、dijkstra 等小规模输入 |
| P1 | 分支预测微基准 | 解释 Dhrystone/CoreMark/SPEC 前端表现 | 已有基础 | 本仓库已有 branch 相关 bench，可扩展统计 |
| P1 | cache stride / pointer chasing | 定位 LSU/cache/TLB 行为 | 已有基础 | 数据规模要适配 RTL 仿真 |
| P2 | SPEC kernel 抽取 | 接近 SPEC，但可控仿真时间 | 中高 | 抽热点 kernel，比完整 SPEC 更现实 |
| P3 | 完整 SPEC CPU | 论文级 / 商业级主指标 | 很高 | RTL 仿真通常非常久，需要 checkpoint/采样/FPGA/仿真加速 |

## 8. 2024-2026 行业动态

这一节收集最新行业新闻/发布信息。它们反映 benchmark 口径和处理器 IP 市场正在怎么变化，但不应直接替代前面的微结构参数表。

| 日期 | 事件 | 关键信息 | 对 C910 benchmark 对比的影响 | 来源强度 |
|---|---|---|---|---|
| 2026-05-05 | SPEC CPU 2026 发布 | SPEC CPU 2026 包含 52 个 benchmark，分为 SPECspeed / SPECrate 的 Integer / Floating Point 四套；SPEC 强调它更新了 CPU、内存和编译器技术覆盖，并引入更多现代软件工作负载 | 未来论文/商业宣传会逐步从 CPU2017 转向 CPU2026；C910 若规划 SPEC，不应只考虑 CPU2006/2017 | A: SPEC 官方 |
| 2026-06-10 | AWS Graviton5 / EC2 M9g、M9gd GA | AWS 官方称 Graviton5 M9g 相比 Graviton4 M8g 有最高 25% compute uplift，web / ML inference 最高 35%，database 最高 30%；Amazon News 写明 Graviton5 有 192 cores 和 33% lower inter-core latency | Arm Neoverse 服务器生态继续强化，商业对比会越来越关注 cloud instance 性价比、内存/IO 带宽和 rate 类 benchmark，而不只是单核 IPC | A: AWS 官方 |
| 2024-08-14 | SiFive P870-D 发布 | P870-D 面向 data center / AI infrastructure，支持 CHI，可扩展到 256 cores，支持 RVA23、Sv57、AIA、IOMMU 等，SiFive 称 final production release by end of 2024 | 高性能 RISC-V IP 已经从 embedded/edge 扩展到 datacenter 叙事；C910 作为早期开源 OoO 核，比较对象应区分“同代应用核”和“新一代数据中心核” | A: SiFive 官方 |
| 2024-2026 | SiFive P800/P870/P570/P550 Gen 3 产品线更新 | SiFive P800 页面称 P870/P870-A 是其最高性能 RISC-V core；P500 页面描述 P550 Gen 3 / P570 Gen 3，P550 Gen 1 已不再作为新授权主推 | 文档中 P550/P670/P870 的 CoreMark/SPEC 不能混为一个固定代际，必须写明 Gen / product brief / 日期 | A: SiFive 官方 |
| 2024-2026 | Arm Neoverse CSS V3/N3 与 V3/N3 IP | Arm newsroom 称 CSS V3 相比 CSS N2 有 50% performance-per-socket uplift，CSS N3 相比 CSS N2 有 20% performance-per-watt uplift；Arm 产品页写 Neoverse V3 支持最高 3MB private L2，N3 有 2MB L2 option | A72/A76 已不是最新 Arm 服务器对标物；若对比“当前商业高性能”，应加入 Neoverse V2/V3/N3 或云实例 | A: Arm 官方 |
| 2024-10-21 | RISC-V RVA23 Profile ratified | RISC-V International 称 RVA23 面向能运行 rich OS stacks 的 64-bit application processors，目标是减少软件生态碎片化 | 后续商用 RISC-V 应用核会更强调 RVA23 compatibility；C910 的 XThead 私有扩展与 RVA profile 的关系需要单独说明 | A: RISC-V International |
| 2025-12-10 | Qualcomm 收购 Ventana Micro Systems | Qualcomm 官方称收购 Ventana 深化 RISC-V CPU expertise，Ventana 团队将补充 Qualcomm 的 RISC-V 和 custom Oryon CPU development | RISC-V 高性能/服务器 IP 被大厂收购，说明 RISC-V 不再只是 MCU 生态；对比对象应加入 Ventana/Veyron 这类 datacenter-class IP | A: Qualcomm 官方 |
| 2023-11 / 2025 延续 | Ventana Veyron V2 | Ventana 公开称 Veyron V2 面向 data center-class RISC-V processor/chiplet/IP，性能最高提升 40%，并强调 cache hierarchy、vector processor 和 processor fabric | RISC-V 高性能路线正在走 chiplet / IP / data center 方向，和 C910 的开源单核 RTL 定位不同 | B: Ventana/RISC-V 新闻稿 |
| 2024-04 | Imagination APXM-6200 | Imagination 发布 RISC-V applications processor IP；公开宣传中用 SPECint2006 相对 Arm Cortex-A 系列小核对比，但不少结果基于估算/仿真 | 说明 RISC-V 在应用小核市场也开始用 SPECint2006 宣传；这种数据必须注明“simulation / estimate” | B/C: RISC-V/媒体报道 |
| 2025-10 | Andes / Cuzco | Andes 预告下一代 OoO CPU “Cuzco”，面向 AI、datacenter、networking、automotive，强调 RVA23-compatible 和高性能/能效 | RISC-V 高性能 IP 厂商增多，未来 benchmark 表应加入 Andes Cuzco，但目前缺少完整公开实测 | B: Andes 新闻稿 |
| 2024 Hot Chips / 2026 HPCA tutorial | XiangShan Nanhu / Kunminghu | Hot Chips 2024 slides 写 Nanhu V2 test chip 2.5GHz、SPEC CPU2006 ~10/GHz；HPCA 2026 tutorial 页面写 KMH-V2 achieves 15/GHz in SPEC06，KMH-V3 targets 22/GHz by end of 2026 | XiangShan 已经成为开源 RISC-V 高性能核最重要参照之一；但必须绑定版本、阶段和是否 silicon / simulation | B: XiangShan / Hot Chips |

行业趋势总结：

| 趋势 | 说明 | 对本文后续维护的影响 |
|---|---|---|
| SPEC CPU 2026 成为新主线 | CPU2006 已很旧，CPU2017 仍常用，但 2026 会逐步进入服务器和论文评测 | 后续 benchmark 计划应新增 CPU2026 适配/抽核研究 |
| RISC-V 高性能 IP 从 edge 进入 datacenter | SiFive P870-D、Ventana、Andes Cuzco、XiangShan KMH 都在强化 data center / AI / chiplet 叙事 | C910 对标时要分清“同代应用核”和“新一代高性能 IP” |
| 云厂商自研 Arm CPU 继续推进 | Graviton5 说明 cloud CPU 的核心数、cache、内存和 IO 扩展比单核 IPC 更受重视 | C910 若做系统级对比，不能只看 Dhrystone/CoreMark |
| Profile / platform 标准越来越重要 | RVA23、AIA、Sv57、IOMMU、CHI/CXL 等频繁出现在新 IP 发布中 | 对 OpenC910 需要单列 ISA/profile/platform 兼容性差距 |
| benchmark 宣传更偏 workload / perf-per-watt | 厂商越来越少只宣传 DMIPS，更多用 SPEC、应用、AI inference、database、web workload | Dhrystone 只能保留为历史补充，CoreMark/Embench/SPEC kernel 更重要 |

## 9. 来源索引

### 9.1 本仓库 / 本地结果

- `doc/C910_体系结构总览.md`
- `doc/idu/00_idu_overview.md`
- `doc/iu/00_iu_overview.md`
- `doc/rtu/00_rtu_overview.md`
- `doc/openc910_datasheet.pdf`
- `doc/玄铁C910用户手册_20240627.pdf`
- `doc/玄铁C910集成手册_20240627.pdf`
- `smart_run/results/dhrystone_std_1000/dhrystone.summary.txt`
- `smart_run/results/dhrystone_std_1000/dhrystone.run.vcs.log`

### 9.2 Benchmark 标准

- Dhrystone 2.1 netlib：<https://www.netlib.org/benchmark/dhry-c>
- CoreMark / EEMBC：<https://www.eembc.org/coremark/>
- SPEC CPU：<https://www.spec.org/cpu/>
- SPEC CPU 2026：<https://www.spec.org/cpu2026/>
- SPEC CPU 2026 press release：<https://www.spec.org/pressreleases/2026/20260505-spec-releases-cpu-2026-benchmark-suite/>

### 9.3 开源处理器

- PicoRV32：<https://github.com/YosysHQ/picorv32>
- NEORV32：<https://github.com/stnolting/neorv32>
- lowRISC Ibex：<https://ibex-core.readthedocs.io/>
- VexRiscv：<https://github.com/SpinalHDL/VexRiscv>
- Rocket Chip：<https://github.com/chipsalliance/rocket-chip>
- Chipyard：<https://chipyard.readthedocs.io/>
- BOOM documentation：<https://docs.boom-core.org/>
- CVA6：<https://github.com/openhwgroup/cva6>
- Ariane paper：<https://ieeexplore.ieee.org/document/8872566>
- XiangShan：<https://github.com/OpenXiangShan/XiangShan>
- XiangShan docs：<https://docs.xiangshan.cc/>
- OpenC910：<https://github.com/T-head-Semi/openc910>
- XiangShan Hot Chips 2024 slides：<https://hc2024.hotchips.org/assets/program/conference/day2/29_HC2024.ChineseAcademy.XiangShan.Kaifan.final.pdf>
- XiangShan HPCA 2026 tutorial：<https://tutorial.xiangshan.cc/hpca26/topic_details/>

### 9.4 商业处理器

- Arm technical documentation portal：<https://developer.arm.com/documentation/>
- Arm Cortex-A72 microarchitecture blog：<https://community.arm.com/arm-community-blogs/b/architectures-and-processors-blog/posts/a-walk-through-of-the-microarchitectural-improvements-in-cortex-a72>
- Arm Cortex-A76 / Neoverse documentation：<https://developer.arm.com/documentation/>
- Arm Neoverse CSS V3/N3 announcement：<https://newsroom.arm.com/news/enabling-ai-infrastructure-on-arm>
- AMD/Xilinx Versal documentation：<https://docs.amd.com/>
- AWS Graviton5 M9g launch blog：<https://aws.amazon.com/blogs/aws/now-available-amazon-ec2-m9g-and-m9gd-instances-powered-by-new-aws-graviton5-processors/>
- AWS Graviton5 availability article：<https://www.aboutamazon.com/news/aws/aws-graviton-5-cpu-amazon-ec2>
- SiFive processor IP：<https://www.sifive.com/risc-v-core-ip>
- SiFive P500 series：<https://www.sifive.com/cores/performance-p500>
- SiFive P800 series：<https://www.sifive.com/cores/performance-p800>
- SiFive P870-D announcement：<https://www.sifive.com/press/sifive-announces-high-performance-risc-v-datacenter-processor-for-ai-workloads>
- RISC-V RVA23 ratification：<https://riscv.org/blog/risc-v-announces-ratification-of-the-rva23-profile-standard/>
- Qualcomm Ventana acquisition：<https://www.qualcomm.com/news/releases/2025/12/qualcomm-acquires-ventana-micro-systems--deepening-risc-v-cpu-ex>
- Ventana Veyron V2 announcement：<https://riscv.org/blog/ventana-introduces-veyron-v2-worlds-highest-performance-data-center-class-risc-v-processor-and-platform/>
- Imagination APXM-6200：<https://riscv.org/blog/imagination-reveals-risc-v-processor-at-embedded-world-2024/>
- Andes Cuzco announcement：<https://www.andestech.com/en/2025/10/18/andes-showcases-expanding-risc-v-ecosystem-and-next-generation-cuzco-high-performance-cpu-at-risc-v-summit-north-america-2025/>
- Intel Optimization Reference Manual：<https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html>
- AMD Software Optimization Guides：<https://www.amd.com/en/developer.html>

## 10. 引用注意事项

正式写论文或对外报告时，不建议只引用本文。建议做法：

1. C910 结构参数引用本仓库 RTL / 文档，并标注 commit。
2. C910 benchmark 引用 `smart_run/results/...` 的完整日志和编译参数。
3. 商业处理器 benchmark 引用 SPEC 官方 result 或厂商白皮书原表。
4. 开源处理器 benchmark 引用具体论文、commit、配置文件和 toolchain。
5. 所有 `DMIPS/MHz`、`CoreMark/MHz` 都必须附编译器、flags、运行环境和是否遵守 benchmark 规则。

## 11. 仍需二次确认的字段

以下字段已经按当前能检索到的公开资料给出量级，但在正式报告里不应直接作为最终精确值：

| 字段 | 当前处理 | 正式使用前需要补什么 |
|---|---|---|
| BOOM / SonicBOOM SPECint2006/GHz | 写成配置相关范围 | 具体 BOOM config、论文版本、benchmark harness、编译器 |
| XiangShan Nanhu / Kunminghu SPEC | 写成项目阶段量级 | 具体 commit、分支、Hot Chips/论文页码、是否仿真/FPGA/流片 |
| SiFive P670 / P570 CoreMark/SPEC | 写成 product brief 量级 | 当前 product brief PDF 原表、代际、是否 Gen 3、vector 配置 |
| Cortex-A76 / Neoverse N1 绝对 SPEC | 写成相对/官方结果入口 | SPEC 官方 result ID、SoC SKU、频率、base/peak、speed/rate |
| Intel / AMD ROB 等内部队列 | 写成优化手册 + 第三方量级 | 对应优化手册章节或高可信反向分析来源 |
| Apple M1 微结构参数 | 明确标 third-party | 不能当官方规格；只可作为第三方性能参考 |

对 C910 当前最可靠的闭环仍是：本仓库 RTL/文档结构参数 + `smart_run/results/dhrystone_std_1000/` 实测日志 + `doc/玄铁C910集成手册_20240627.pdf` 公开性能口径。后续若补 CoreMark，应优先把 `7.0 CoreMark/MHz` 的复现实验做成同样可追溯的日志目录。
