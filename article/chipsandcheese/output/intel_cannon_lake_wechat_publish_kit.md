# Cannon Lake WeChat Publish Kit

## 正式标题

Cannon Lake：Intel 被遗忘的一代，以及 10 nm 初次落地的代价

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Cannon Lake: Intel’s Forgotten Generation
- 日期：2022-11-15
- 阅读原文：https://chipsandcheese.com/p/cannon-lake-intels-forgotten-generation
- 栏目：处理器微架构 / Intel 历史核心

## 摘要

Cannon Lake 只留下 2 核 4 线程、iGPU 被禁用的一款 SKU。10 nm 把 Palm Cove 面积缩到 Kaby Lake 的 43%，却未兑现性能功耗；客户端 AVX-512、Gen 10 iGPU、IPU、GNA 和显示引擎，则成为后续 Intel SoC 的技术试验场。

## 封面文案

密度成功、产品失败：被遗忘的 Cannon Lake

## 分享文案

从 10 nm 功耗曲线、BTB、AVX-512 到无法启动的 Gen 10 iGPU，完整回看 Intel 只出过一个 SKU 的 Cannon Lake，以及它给 Ice Lake 留下了什么。

## 备选标题

- Palm Cove 与 Cannon Lake：Intel 10 nm 的第一次真实答卷
- 只卖过一款的 Intel 处理器，藏着 AVX-512 与 Gen 10 的起点

## 标签

Intel、Cannon Lake、Palm Cove、10nm、AVX-512、Gen 10、iGPU、GNA

## 图片说明

- 共 34 张图，全部按页面顺序保留。
- 图 3—7 讲工艺能效，图 10—24 讲核心，图 25—34 讲 SoC。
- 裸片彩色标注均含推测，不能改写成官方 floorplan。

## 移动端排版与后台设置

- 章节较长，建议保留工艺、核心、AVX-512、iGPU、System Agent 五个导航。
- 摘要填后台，开启原始链接与图片查看原图。
- 图表保持原比例，性能曲线不要裁掉功率口径。

## 发布前检查

- [ ] 34 张图全部显示且顺序正确
- [ ] package/core power 与 Kaby Lake uncore 异常保留
- [ ] 43% 面积、4608 branch、AVX-512 混合吞吐等数据准确
- [ ] iGPU 寿命说法明确为未证实传闻
- [ ] 裸片块识别、L3 timing 和 GNA 位置未写成确认实现
