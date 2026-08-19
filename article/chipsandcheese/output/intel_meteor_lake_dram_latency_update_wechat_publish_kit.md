# Meteor Lake DRAM Latency Update WeChat Publish Kit

## 正式标题

Meteor Lake 内存延迟更新：超过 200 ns，原来还有低功耗状态这一层

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Update on Meteor Lake DRAM Latency Measurements
- 日期：2024-05-27
- 阅读原文：https://chipsandcheese.com/p/update-on-meteor-lake-dram-latency-measurements
- 栏目：处理器微架构 / 内存与功耗管理

## 摘要

单链延迟测试流量太低，会让 Meteor Lake 内存控制器停在低功耗 Gear/频率状态。另一颗 Compute Tile 核心制造带宽后，E-Core 延迟约 153 ns、LPE-Core 175.3 ns；只有 LPE-Core 发流量仍超过 200 ns，显示省电 heuristic 与无 L3 叠加的代价。

## 封面文案

超过 200 ns，不全是 LPDDR 的锅

## 分享文案

给延迟测试旁边加一个带宽线程，Meteor Lake 内存延迟就大幅下降。一次复测说明：微基准不仅观察硬件，也会触发硬件选择不同功耗状态。

## 备选标题

- Meteor Lake 为什么在低流量下测出 200 ns 内存延迟
- Gear 2、Gear 4 与 LPE-Core：Meteor Lake 延迟复测

## 标签

Intel、Meteor Lake、LPDDR5X、Memory Controller、Gear 2、LPE-Core、Crestmont

## 图片说明

- 共 3 张图，图 2 是核心更新证据。
- 图 3 为此前数据，应注明来自 prior article。

## 移动端排版与后台设置

- 后台作者填 Chester Lam，摘要填后台。
- 开启阅读原文和查看原图。
- 153/175.3/>200 ns 必须附带 controller state/负载条件。

## 发布前检查

- [ ] 3 张图均可显示
- [ ] LPDDR5X-7467、最低 3200 MT/s、Gear 2/4 定义准确
- [ ] Queue occupancy 和 P-Core stall 均写为推测
- [ ] 对此前结论的修正清楚
- [ ] Firmware/大 L2/SLC 只写为建议
