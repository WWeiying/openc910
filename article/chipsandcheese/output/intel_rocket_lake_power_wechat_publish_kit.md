# Rocket Lake Power Efficiency WeChat Publish Kit

## 正式标题

Rocket Lake 能效真的很差吗：回到 14 nm 同代平台再看一次

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Was Rocket Lake Power Efficient?
- 日期：2022-12-17
- 阅读原文：https://chipsandcheese.com/p/was-rocket-lake-power-efficient
- 栏目：处理器微架构 / 能效

## 摘要

Rocket Lake 默认状态可让四核封装功率冲到 147 W，但在 30 W 以上的中等桌面区间，它能以同功率超过 Skylake，并在 2.5—3 GHz 达到较好能效。低功率缩放和 ISA 不对称，则解释了为何它难以组成实用混合架构。

## 封面文案

147 W 之外，Rocket Lake 还有另一面

## 分享文案

把 Rocket Lake 放回 Intel 14 nm 家族，分别看 libx264 与 7-Zip 的性能—功率曲线：高 IPC 大核在合理降频后可以高效，真正的问题是甜点区太窄。

## 备选标题

- Rocket Lake 不是处处低效，只是默认频率太激进
- 从 30 W 到 147 W：Rocket Lake 的能效窗口

## 标签

Intel、Rocket Lake、Cypress Cove、Skylake、Goldmont Plus、能效、混合架构

## 图片说明

- 共 8 张图，图 2—5 为真实跨代结果，图 6—8 含假想混合分析。
- core power 与 package power 图不可混用。

## 移动端排版与后台设置

- 摘要填后台，开启原文链接。
- 图 4 的 i5-6600K 异常必须保留未知边界。
- 所有曲线保持坐标与图例完整。

## 发布前检查

- [ ] 8 张图全部可访问
- [ ] 四线程、亲和性、2.67 GB ETL 条件保留
- [ ] package/core power 切换有明确说明
- [ ] Goldmont Plus 微码 AVX-512 明确为假设
- [ ] 未将窄功率区优势外推为产品总排名
