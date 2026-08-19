# Mobile and AVX-512 Energy：发布资料

## 正式标题

移动平台与 AVX-512：搬运数据的能效账

## 基本信息

- 英文题目：Caching Energy Efficiency Data – Mobile and AVX-512
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2022 年 7 月 15 日
- 阅读原文：https://chipsandcheese.com/p/caching-energy-efficiency-data-mobile-and-avx-512
- 后台作者栏：Chester Lam

## 摘要

同为 Zen 3，Monolithic Cezanne 在较低频率下远比 Chiplet Vermeer 省能；Willow Cove 用 AVX-512 在 L1/L2 同时提高带宽和能效，但测试伴随降频。Rocket Lake/Kaby 对照则说明，512 bit Access 能在近似 Energy/bit 下提供两倍以上吞吐。

## 封面与分享文案

- 封面：AVX-512 更费电，还是更省电？
- 分享：同样搬 64 B，512 bit Load 能少做地址计算和 Tag Check；但平台功耗、频率、Cache 与 Throttle 可能把收益全部掩盖。答案只能在完整能量账里找。

## 备选标题

- 从 Cezanne 到 Rocket Lake：缓存搬运的 Energy/bit
- AVX-512 的另一面：更宽访问为何可能更省电

## 标签与栏目

- 标签：AVX-512、Zen 3、Willow Cove、能效、Cache
- 栏目：处理器实测

## 图片与排版

- 共 9 张图，图 1 或图 6 适合作封面。
- pJ/bit、GB/s 与 Package Power 不混用；正文 15～16 px。

## 发布前检查

- Willow Cove Clock Drift 和 Laptop OEM 边界保留。
- 不把单个平台结论外推到全部 AVX-512 CPU。
- 9 张图按顺序可访问。
