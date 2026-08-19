# AMD Zen 5 Leaked Slides WeChat Publish Kit

## 正式标题

Zen 5 泄露幻灯片：哪些信息值得分析，哪些只能等待验证

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Zen 5’s Leaked Slides
- 日期：2023-10-08
- 阅读原文：https://chipsandcheese.com/p/zen-5s-leaked-slides
- 栏目：AMD Zen / 泄露资料分析

## 摘要

一张无法核验的 Zen 5 slide 提到 zero-bubble branch、two-block fetch、48 KB L1D、8-wide rename、larger unified scheduler、6 ALU、4 load/2 store 与 512-bit FP。逐条回到 Zen 1—4 和同期架构，区分已有能力、合理方向、激进解释与纯粹未知。

## 封面文案

不替泄露背书，只回答这些参数意味着什么

## 分享文案

48 KB、12-way L1D 怎样保持 4 周期？“2 Basic Block Fetch”究竟有三种什么解释？6 ALU 又为什么未必提升游戏？

## 备选标题

- Zen 5 传闻逐条拆解：从双块取指到 512-bit 执行
- 看懂 Zen 5 泄露页：哪些是新机制，哪些只是营销短语

## 标签

AMD、Zen 5、分支预测、L1D、Scheduler、AVX-512、处理器泄露

## 图片说明

- 共 24 张图，按页面顺序保留。
- 图 1、22、24 是第三方泄露/传闻页面；图 10、20、21、23 为 AMD 公开资料；其余多为机制解释和实测背景。
- 图 16 是作者提出的低成本端口布局，不是 AMD 框图。

## 发布前检查

- [ ] 24 张图全部显示且顺序正确
- [ ] 全文保持 2023 年时点，不用后来产品信息反向确认
- [ ] zero-bubble 与 two-block 的多种解释完整
- [ ] DTLB、PWC、scheduler 与执行端口推测没有写成事实
- [ ] 泄露页、AMD 官方 slide、第三方性能传闻来源清楚
- [ ] 20%—30% IPC 没有当作可兑现规格
