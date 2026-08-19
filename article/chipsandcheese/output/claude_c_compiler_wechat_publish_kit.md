# Claude C Compiler WeChat Publish Kit

## 正式标题

Claude 写出的 C 编译器：当糟糕代码生成撞上现代 CPU

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Embracing AI with Claude's C Compiler
- 日期：2026-04-01
- 阅读原文：https://chipsandcheese.com/p/embracing-ai-with-claudes-c-compiler
- 栏目：编译器 / CPU 性能分析

## 摘要

Claude 生成的 C 编译器把简单数组访问扩成九指令依赖链，让八个纯 C SPEC CPU2017 workload 平均慢 70% 以上，却一度跑出更高 IPC。这篇 4 月 1 日技术讽刺文，用真实汇编、SPEC 和 Top-Down 数据说明：IPC 不等于性能，乱序硬件也无法无限掩盖糟糕代码生成。

## 封面文案

指令多十倍、IPC 还更高：AI 编译器给 CPU 上了一课

## 分享文案

Zen 5、Lion Cove、Cortex-X925 同场运行 Claude 生成的代码：move elimination、store forwarding、op cache 和 8-wide decoder，全被迫替编译器收拾残局。

## 备选标题

- CCC 对决 GCC：现代 CPU 能吞下多少无用指令？
- AI 编译器慢 70%，却揭开了 IPC 指标的陷阱

## 标签

Claude、编译器、GCC、SPEC CPU2017、Zen 5、Lion Cove、Cortex-X925

## 图片说明

- 共 18 张图，按页面顺序保留。
- 图 1—8 为微基准与类型测试，图 9—18 为 SPEC、IPC、指令数与 Top-Down。
- 图 18 比较的是不同编译器、不同处理器，不能当作处理器世代的同条件性能比较。

## 发布前检查

- [ ] 18 张图全部显示且顺序正确
- [ ] 开篇明确 4 月 1 日讽刺语境与 4 月 2 日撤回更新
- [ ] 三个平台、9800X3D 关闭 boost、八个纯 C workload 保留
- [ ] 502.gcc 崩溃、平均下降 70% 以上与指令数暴增准确
- [ ] IPC 与完成时间没有混为一谈
- [ ] Top-Down 跨厂商计数口径差异保留
