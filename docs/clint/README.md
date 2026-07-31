# C910 CLINT 文档索引

CLINT 保存两个 hart 的软件中断位和定时器比较值，并根据采样到的系统时间输出 mt/ms/st/ss 四类中断电平。它不产生系统时间，不负责 PLIC 仲裁，也不直接决定处理器何时进入中断。

| 文档 | 内容 | 建议用途 |
|---|---|---|
| [00_clint_overview.md](00_clint_overview.md) | 系统位置、寄存器映射、APB 事务到状态更新的完整因果链、时间采样、中断传播、CLINT 与 PLIC/CP0 的边界 | 先建立整体认识 |
| [01_clint_func.md](01_clint_func.md) | 对 `ct_clint_func.v` 的逐段解释，覆盖地址/权限检查、保留编码、ready/error 时序、寄存器、比较器、时钟门控和验证点 | 对照 RTL 精读 |

主要 RTL 位于：

```text
C910_RTL_FACTORY/gen_rtl/clint/rtl/ct_clint_top.v
C910_RTL_FACTORY/gen_rtl/clint/rtl/ct_clint_func.v
```

建议同时沿以下文件核查上下游：

```text
ct_sysio_top.v       系统计数值的上游采样、两个 sysio_kid 实例
ct_sysio_kid.v       CLINT/PLIC 中断的一拍寄存采样
ct_piu_other_io*.v   sysio 中断向 CIU/核心接口的直接传递
ct_cp0_regs.v        pending 位、clintee、局部使能、委托和优先级条件
```

阅读时应始终区分：

1. APB SETUP 阶段看到请求；
2. ACCESS 阶段完成总线事务；
3. 目标寄存器在时钟沿更新；
4. CLINT 中断输出变为高；
5. `ct_sysio_kid` 采样该输出；
6. CP0 形成 pending；
7. CP0/RTU 最终接受中断并重定向。

其中任意相邻两步都不是同一个概念，也不保证发生在同一个周期。

两个特别重要的准确性边界：

- 本 RTL 的监管态比较寄存器是**内存映射扩展**，目标与 S 态直接管理定时器相近，但不能仅凭该模块宣称标准 Sstc 合规。
- `ct_sysio_kid` 明确可见的是**一拍寄存采样**，不能仅凭这一拍宣称已经实现通用的双触发器异步 CDC。
