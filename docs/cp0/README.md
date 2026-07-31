# C910 CP0（控制状态寄存器 / 特权）单元教学文档

本目录讲解 OpenC910 工程中名为 **CP0** 的控制单元。它管理当前有效配置下的 M/S/U 特权状态、CSR 访问、trap 状态更新、中断资格与 cause 编码，并向各微结构模块广播配置位。“CP0”是工程命名，不是 RISC-V 规范要求的标准模块边界。

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
| [00_cp0_overview.md](./00_cp0_overview.md) | CP0 职责、M/S/U 特权模型、与 RTU 的 trap 接口、IUI 的请求/commit/副作用边界、整体数据流 | 全部 4 个文件 + top |
| [01_cp0_trap.md](./01_cp0_trap.md) | 陷入入口/出口核心：EPC/cause/tval 同沿更新、mstatus 一层 previous 状态、mret/sret、mtvec Direct/Vectored、委派和中断接受 | `ct_cp0_regs.v` |
| [02_cp0_csr.md](./02_cp0_csr.md) | CSR 地址索引、合法性/实体/路由三者的区别、标准和私有字段、读写与外部单元路由 | `ct_cp0_regs.v` + `ct_cp0_iui.v` |
| [03_cp0_lpmd_iui.md](./03_cp0_lpmd_iui.md) | WFI 低功耗 3 态机、IUI 四状态执行、commit 对副作用的门控、特权检查、复位 I/D-cache/TLB 失效 | `ct_cp0_lpmd.v` + `ct_cp0_iui.v` |

## 推荐学习路径

1. **先读 [00 概览](./00_cp0_overview.md)**，建立 CP0 在全核中的位置、M/S/U 特权模型、以及"指令进入 → 执行 → 陷入/出栈"的整体数据流。
2. **再读 [03 lpmd_iui](./03_cp0_lpmd_iui.md)**，理解四个状态为什么不等于固定四拍，以及 commit 为什么只门控架构副作用、并不直接作为 EX2 状态保持条件。
3. **然后读 [01 trap](./01_cp0_trap.md)**，理解 RTU trap 有效沿如何一致更新 EPC/cause/tval/status，previous 字段如何保存一层返回状态，以及委派如何决定写 M 还是 S 套寄存器。
4. **最后读 [02 csr](./02_cp0_csr.md)** 作为参考手册，速查任意 CSR 的地址、位域、访问权限与读出路径。

## 前置知识

- RISC-V 特权架构 spec（Machine/Supervisor/User 三特权级，CSR 概念）
- 已读过本仓库 [IFU](../ifu/README.md) 或 [IDU](../idu/README.md) 任一单元，熟悉 C910 的 `gated_clk_cell` 时钟门控写法与 `xx_local_en` 写使能命名习惯。

阅读本目录时始终同时问四个问题：

1. 地址只是定义了 parameter，还是已经进入 IUI 合法白名单？
2. 请求只是地址命中，还是已经通过特权和 commit？
3. `valid/select` 只是声明操作存在，还是目标寄存器已在时钟沿更新？
4. 中断只是 pending/request，还是 RTU 已经形成 `rtu_cp0_expt_vld`？
