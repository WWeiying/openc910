# Strix Halo Infinity Cache 微信公众号发布资料

## 正式标题

实测 Strix Halo 的 Infinity Cache：32 MB 能替代多少内存带宽

## 备选标题

- 32 MB Cache 如何喂饱 Strix Halo 的大 iGPU
- 没有官方命中率，怎样测 Infinity Cache
- 从 CS 到 UMC：观察 Strix Halo 的带宽放大

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Evaluating the Infinity Cache in AMD Strix Halo*
- 发布日期：2025 年 10 月 22 日
- 阅读原文：https://chipsandcheese.com/p/evaluating-the-infinity-cache-in

## 摘要

AMD 工具不报告 Infinity Cache 命中率，本文用 CS 与 UMC 流量差分近似观察。32 MB Cache 在目标分辨率下成功把外部带宽压在 256 GB/s 以内。

## 分享卡片文案

Time Spy Extreme 若没有 Infinity Cache，可能需要 335 GB/s 以上 DRAM；一个区间里 32 MB Cache 截住约 73% Fabric 流量。这个数字又为什么不能代表所有游戏？

## 封面

- 主标题：Infinity Cache
- 副标题：Strix Halo 的 32 MB 带宽放大器
- 小字：CS / UMC / 256 GB/s / Resolution
- 比例：2.35:1，中央 32 MB Cache 拦截通向 LPDDR5X 的流量

## 推荐标签与栏目

- 标签：AMD、Strix Halo、Infinity Cache、GPU、RDNA 3.5、性能计数器、内存带宽
- 栏目：处理器体系结构

## 图片与排版

- 正文图片：18 张，按 01～18 上传
- 图 2～5 是方法，图 6～16 是结果，顺序不能打乱
- 时间序列图在移动端保持横向原尺寸

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/evaluating-the-infinity-cache-in
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- CS-UMC 是命中率 Proxy，不是 AMD 直接事件；只有四组 CS 同时采样并乘四。
- 一秒采样可能低估短尖峰；CPU/Snoop 流量会引入误差。
- 73% 只对应 Time Spy Extreme 的一个峰值区间。
- 视频更正：32/64 B 是 per data beat，不是 per cycle；读多于写。
