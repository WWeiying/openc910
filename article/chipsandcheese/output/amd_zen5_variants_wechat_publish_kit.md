# Zen 5 同频跨代对比｜微信公众号发布资料

## 正式标题

把十代 CPU 都锁到 3 GHz：Zen 5 每周期到底强在哪

## 备选标题

- 从 Husky 到 Zen 5：同为 3 GHz，CPU 为什么越做越宽
- 3 GHz 同频实验：IPC、分支预测与内存延迟的真相
- Zen 5 同频对决：高 IPC 为什么不一定更快

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Zen 5 Variants and More, Clock for Clock*
- 发布日期：2024 年 8 月 20 日
- 阅读原文：https://chipsandcheese.com/p/zen-5-variants-and-more-clock-for-clock

## 摘要

把跨越十多年的 AMD、Intel 核心尽量限制在 3 GHz，以 libx264、7-Zip 和内核编译观察 IPC、指令数、分支预测与内存延迟怎样共同决定性能。

## 分享卡片文案

IPC 不一定等于每周期性能，锁频也消不掉数据和分支的不可预测性。20 张图看 Zen 5、Zen 4、Skylake、Bulldozer 等核心的同频差异。

## 封面

- 主标题：ALL AT 3 GHz
- 副标题：Zen 5 的每周期优势从哪来
- 小字：IPC / Branch / Cache / Memory
- 比例：2.35:1；横向排列多代 CPU，统一频率刻度

## 推荐标签与栏目

- 标签：AMD、Intel、Zen 5、IPC、分支预测、Cache、微体系结构
- 栏目：处理器体系结构

## 图片与排版

- 正文 20 张图，按 01～20 上传。
- 图 6～10、11～14、15～18 分三组排版。
- 图中平台多，移动端注意图例可读性。

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/zen-5-variants-and-more-clock-for-clock
- 原创声明：关闭
- AI 内容标识：按平台要求开启

## 发布前边界

- `cpupower` 不能让所有平台精确保持 3 GHz；Bulldozer 与 Zen 2 均有偏差。
- 该实验不代表默认频率下的购买或产品排名。
- 内核编译指令数受环境影响，未给出正式完成时间排名。
- 不同架构的 Top-down 事件定义不同，只能做趋势比较。
