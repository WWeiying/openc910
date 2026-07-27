# C910 PMP（物理内存保护）学习文档索引

PMP（Physical Memory Protection，物理内存保护）是 RISC-V 特权架构中用于在
**物理地址层面**做访问权限控制的硬件单元。它独立于 MMU 之外、位于地址翻译之后，
为 M 态固件、TEE/可信执行环境、外设隔离等场景提供最后一道物理隔离屏障。

本套文档基于 OpenC910 的真实 RTL 逐行讲解，所有数字、位宽、编码、行号均来自源码，
力求与 `doc/ifu/` 同档深度。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_pmp_overview.md](00_pmp_overview.md) | PMP 解决什么问题、与 MMU 的先后关系、8 区结构、M 态语义、顶层 `ct_pmp_top.v` 串讲、关键设计决策 | 先读，建立全局观 |
| [01_pmp_regs.md](01_pmp_regs.md) | `ct_pmp_regs.v`：8 组 pmpcfg/pmpaddr 寄存器、R/W/X+L 锁位、pmpcfg0 打包布局、锁定后只复位能改、地址粒度移位 | 寄存器堆精读 |
| [02_pmp_match.md](02_pmp_match.md) | `ct_pmp_comp_hit.v` + `ct_pmp_acc.v`：OFF/TOR/NAPOT 匹配、NAPOT 末尾连续 1 编码技巧、4KB 粒度、5 个并行检查器、优先级编码、M 态默认全通与锁定约束、MPRV | 匹配与权限核心 |

## 模块层次结构

```
ct_pmp_top                                  顶层：CSR 译码 + 时钟门控 + 例化
 ├── ct_pmp_regs                            寄存器堆：8×pmpcfg + 8×pmpaddr
 └── ct_pmp_acc  × 5  （5 条并行访问通道）   单通道权限判定
      └── ct_pmp_comp_hit  × 8  （8 个区）   单区地址匹配（OFF/TOR/NAPOT）
```

- 一份寄存器堆（`ct_pmp_regs`）的输出广播给 **5 个** `ct_pmp_acc` 实例；
- 每个 `ct_pmp_acc` 内含 **8 个** `ct_pmp_comp_hit`（对应 PMP entry 0~7）；
- 5 条通道对应 MMU 一拍内可能并发产生的 5 个物理地址（取指 + 多个访存）。

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_pmp_overview.md          理解 PMP 为何存在、与 MMU 关系、顶层连线

第二轮（寄存器语义）
  └── 01_pmp_regs.md              pmpcfg/pmpaddr 编码、锁位、打包布局

第三轮（匹配与权限判定）
  └── 02_pmp_match.md             TOR/NAPOT 匹配技巧、优先级编码、M 态规则
```

## 一句话速览

- **8 个 PMP 区**（OpenC910 实现了 0~7；CSR 接口预留到 15）；
- 每区一对寄存器：`pmpcfgN`（权限 R/W/X + 匹配模式 A + 锁位 L）和 `pmpaddrN`（基址/上界）；
- 匹配模式：**OFF / TOR / NAPOT**（NA4 在本实现中被硬连为 0，未实现）；
- 粒度 **4KB**（`PA_WIDTH=40`，地址寄存器只保存 PA[39:12]，共 28 位）；
- **优先级**：低编号区优先（区 0 最高）；
- **M 态**默认全通（除非该区被 Lock），U/S 态默认全拒；
- 与 MMU 串联：**先翻译，后用翻译得到的物理地址查 PMP**。
