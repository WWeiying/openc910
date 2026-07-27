# C910 CP0（控制状态寄存器 / 特权）单元教学文档

本目录系统讲解 OpenC910 的 **CP0 单元**（Control/Status Register & Privilege Unit）。CP0 是处理器里管理 RISC-V 特权架构（M/S/U 三态）、CSR 读写、陷入（trap）入口/出口、以及向全核各模块广播配置位的中枢。

所有内容均基于以下 RTL 真实源码逐行整理，行号引用均指向：

```
C910_RTL_FACTORY/gen_rtl/cp0/rtl/
├── ct_cp0_top.v    (1072 行)  顶层例化 + 信号互连
├── ct_cp0_regs.v   (4394 行)  CSR 寄存器堆 + 陷入核心（最核心、最大）
├── ct_cp0_iui.v    (1656 行)  与 IU 的 CSR/特权指令接口 + 4 态执行 FSM + 中断打包
└── ct_cp0_lpmd.v   ( 232 行)  WFI/低功耗 3 态状态机
```

## 文档索引

| 文档 | 主题 | 对应 RTL |
|---|---|---|
| [00_cp0_overview.md](./00_cp0_overview.md) | CP0 职责、M/S/U 特权模型、与 RTU 的 trap 握手、整体数据流、关键设计决策 | 全部 4 个文件 + top |
| [01_cp0_trap.md](./01_cp0_trap.md) | 陷入入口/出口核心：mepc/mcause/mtval 原子写、mstatus 两级特权栈压栈/出栈、mret/sret、mtvec Direct/Vectored、medeleg/mideleg 委派、中断仲裁与退休边界接受 | `ct_cp0_regs.v` |
| [02_cp0_csr.md](./02_cp0_csr.md) | CSR 地址全表（标准 + 玄铁私有 mxstatus/mhcr/mcor/mhint/mrvbr/mcer…）、各自作用与位域、读出多路与访问路由 | `ct_cp0_regs.v` + `ct_cp0_iui.v` |
| [03_cp0_lpmd_iui.md](./03_cp0_lpmd_iui.md) | 低功耗 WFI 3 态机（IDLE→WAIT→LPMD）与 IUI 的 4 态执行机（IDLE→EX1→EX2→EX3）、特权检查、reset cache inv | `ct_cp0_lpmd.v` + `ct_cp0_iui.v` |

## 推荐学习路径

1. **先读 [00 概览](./00_cp0_overview.md)**，建立 CP0 在全核中的位置、M/S/U 特权模型、以及"指令进入 → 执行 → 陷入/出栈"的整体数据流。
2. **再读 [03 lpmd_iui](./03_cp0_lpmd_iui.md)**，理解一条 CSR/MRET/SRET/WFI 指令是怎么被 IUI 接进来、走 4 拍流水、做特权检查、最后把写值送给 regs 的——这是理解后续一切的"入口"。
3. **然后读 [01 trap](./01_cp0_trap.md)**，这是 CP0 的灵魂：异常/中断如何原子地写 mepc/mcause/mtval，mstatus 两级栈如何压栈/出栈，mret/sret 如何恢复，委派如何决定去 M 还是 S。
4. **最后读 [02 csr](./02_cp0_csr.md)** 作为参考手册，速查任意 CSR 的地址、位域、访问权限与读出路径。

## 前置知识

- RISC-V 特权架构 spec（Machine/Supervisor/User 三特权级，CSR 概念）
- 已读过本仓库 `doc/ifu/` 或 `doc/idu/` 任一单元，熟悉 C910 的 gated_clk_cell 时钟门控写法与 `xx_local_en` 写使能命名习惯。
