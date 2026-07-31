# C910 PMP（物理内存保护）学习文档索引

PMP（Physical Memory Protection，物理内存保护）是 RISC-V 特权架构中用于在
**物理地址层面**做访问权限控制的机制。OpenC910 把 PMP 比较器放在独立 RTL 层次中，
但地址和结果有效时序由 MMU 各通路管理。普通取指/数据访问检查翻译后或 Bare 直通后的
物理页号；PTW 则检查 PTE 所在物理地址。它可用于 M 态固件和可信执行环境的物理隔离，
但 CPU PMP 本身不能替代针对 DMA 等其他系统主设备的保护。

本套文档基于当前 OpenC910 RTL 讲解。位宽、编码和有效连线以源码为准；体系结构用途与
工程取舍会明确标注为解释或推断，不把注释、未例化模块和未经综合的性能结论当成实现事实。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_pmp_overview.md](00_pmp_overview.md) | PMP 解决什么问题、与 MMU 的先后关系、8 区结构、M 态语义、顶层 `ct_pmp_top.v` 串讲、关键设计决策 | 先读，建立全局观 |
| [01_pmp_regs.md](01_pmp_regs.md) | `ct_pmp_regs.v`：8 组 pmpcfg/pmpaddr 寄存器、R/W/X+L 锁位、pmpcfg0 打包布局、锁定后只复位能改、地址粒度移位 | 寄存器堆精读 |
| [02_pmp_match.md](02_pmp_match.md) | `ct_pmp_comp_hit.v` + `ct_pmp_acc.v`：OFF/TOR/NAPOT 匹配、NAPOT 位级编码、4KB 粒度、5 个并行检查器、优先级编码、无命中默认值、M 模式 L 位旁路、MPRV | 匹配与权限核心 |

## 模块层次结构

```
ct_pmp_top                                  顶层：CSR 译码 + 时钟门控 + 例化
 ├── ct_pmp_regs                            寄存器堆：8×pmpcfg + 8×pmpaddr
 └── ct_pmp_acc  × 5  （5 条并行访问通道）   单通道权限判定
      └── ct_pmp_comp_hit  × 8  （8 个区）   单区地址匹配（OFF/TOR/NAPOT）
```

- 一份寄存器堆（`ct_pmp_regs`）的输出广播给 **5 个** `ct_pmp_acc` 实例；
- 每个 `ct_pmp_acc` 内含 **8 个** `ct_pmp_comp_hit`（对应 PMP entry 0~7）；
- 5 条通道分别连接 D-uTLB 两个端口、I-uTLB、PTW 和 PFU；PMP 顶层没有对应 valid，
  各 MMU 通路在自己的有效时刻采纳结果。

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
- 每区有一个 8 位配置字段（8 个字段打包在 RV64 的 `pmpcfg0`）和一个 `pmpaddrN` 地址 CSR；
- 匹配模式：**OFF / TOR / NAPOT**（NA4 在本实现中被硬连为 0，未实现）；
- 有效匹配粒度 **4KB**：检查输入为 `PA[39:12]`，内部保存 `pmpaddr` CSR `[37:9]`，
  TOR 比较用内部 `[28:1]`，NAPOT 还用内部 `[0]` 编码范围大小；
- **优先级**：低编号区优先（区 0 最高）；
- **无命中默认值**：有效 M 模式返回 RWX，U/S 返回全拒；命中 `L=0` 项时 M 模式由
  MMU 消费端旁路权限限制，命中 `L=1` 项时 M 模式也受 R/W/X 约束；
- 普通访问检查翻译后/直通后的物理页号；PTW 通道检查的是 PTE 所在物理地址；
- PMP 输出 `{L,X,W,R}` 属性而非事务完成信号，最终 access fault 由 MMU 结合访问类型和
  各通路有效信号产生。
