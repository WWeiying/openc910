# Alder Lake Power Efficiency WeChat Publish Kit

## 正式标题

Alder Lake 的能效是一幅复杂图景：默认频率掩盖了两种核心的甜点区

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Alder Lake’s Power Efficiency – A Complicated Picture
- 日期：2022-01-28
- 阅读原文：https://chipsandcheese.com/p/alder-lakes-power-efficiency-a-complicated-picture
- 栏目：处理器微架构 / 性能与功耗

## 摘要

四核曲线显示，Golden Cove 在 4 GHz 以下、Gracemont 在低 3 GHz 整数负载中都有很好能效；默认 boost 却把两者推过甜点区。向量宽度、静态功耗、任务完成时间和计数器口径，共同解释了 Alder Lake 评价为何如此矛盾。

## 封面文案

默认频率，并不是 Alder Lake 最省能的地方

## 分享文案

只看 stock 功耗，会错过 Golden Cove 和 Gracemont 真正的能效区间。用 libx264、7-Zip 和跨代曲线，把 performance/W 与 energy/task 分开讲清楚。

## 备选标题

- Golden Cove 与 Gracemont：谁才是真正的高效核心
- 从 1 GHz 到 5 GHz，看 Alder Lake 的能效甜点区

## 标签

Intel、Alder Lake、Golden Cove、Gracemont、Zen 2、Skylake、能效、DVFS

## 图片说明

- 共 15 张性能—功率/能量图，全部按英文页面顺序。
- 图 2—5 最适合作为核心内容；封面可用图 4。
- 坐标和图例必须完整，避免把不同功率口径曲线混用。

## 移动端排版与后台设置

- 重点数字可加粗，但不要把单个甜点区写成全平台排名。
- 摘要填入后台，开启原文链接。
- 长图保持原比例并允许点击查看。

## 发布前检查

- [ ] 15 张图完整且顺序正确
- [ ] 四核、Linux、intel_pstate、PP0 条件保留
- [ ] libx264 与 7-Zip 的负载性质未混写
- [ ] AMD RAPL 建模限制保留
- [ ] core、uncore、package 功率没有混为一谈
