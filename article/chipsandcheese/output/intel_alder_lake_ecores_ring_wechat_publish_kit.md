# Alder Lake E-Cores and Ring WeChat Publish Kit

## 正式标题

Alder Lake 的混合架构磨合：E-Core 一忙，Ring 为何跟着降频

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Alder Lake – E-Cores, Ring Clock, and Hybrid Teething Troubles
- 日期：2021-12-16
- 阅读原文：https://chipsandcheese.com/p/alder-lake-e-cores-ring-clock-and-hybrid-teething-troubles
- 栏目：处理器微架构 / 混合架构

## 摘要

一颗 E-Core 只运行 L1I 内的 NOP，也会让 Alder Lake ring 从 4.7 GHz 降到 3.6 GHz。P-Core 侧 L3 延迟增加约 11.7%，带宽下降约 20%；两个应用损失 2.9% 和 5.8%，但 E-Core 的额外吞吐通常仍能覆盖这笔代价。

## 封面文案

E-Core 没碰 L3，为什么 P-Core 仍会变慢？

## 分享文案

Alder Lake 第一代混合架构不只考验调度器：E-Core 活动状态还会改变共享 ring 频率。用一个只命中 L1I 的 NOP 循环，把互连降频副作用单独测出来。

## 备选标题

- E-Core 一启动，Alder Lake 的 Ring 从 4.7 GHz 降到 3.6 GHz
- Alder Lake 混合架构的早期代价：共享 Ring 降频

## 标签

Intel、Alder Lake、Golden Cove、Gracemont、Ring Bus、L3 Cache、混合架构

## 图片说明

- 共 6 张图，图 1—4 为延迟与带宽证据，图 5—6 为应用结果。
- 建议以图 1 或图 3 制作封面；不要裁掉坐标与图例。

## 移动端排版与后台设置

- 文首保留出处和链接，摘要填入后台摘要栏。
- 关键数字 4.7/3.6 GHz、11.7%、20%、2.9%/5.8% 不额外夸张放大。
- 开启原文链接，按账号实际信息设置署名。

## 发布前检查

- [ ] 6 张图片均可访问
- [ ] NOP 仅访问 L1I 的测试条件保留
- [ ] 单核与全 P-Core 带宽结果未混写
- [ ] 没有把结果写成关闭 E-Core 的建议
- [ ] Raptor Lake 改进仍写作当时预期
