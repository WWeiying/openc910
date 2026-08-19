# Hot Chips 2024 Zen 5｜微信公众号发布资料

## 正式标题

Hot Chips 2024 的 Zen 5：宽前端、512-bit 后端与真正的设计取舍

## 备选标题

- AMD 工程师详解 Zen 5：为什么双译码不能合给单线程
- 从 6K Op Cache 到 124 个 L1 Miss：Zen 5 的取舍
- Zen 5 不只是变宽：前端、调度器和 LSU 的成本控制

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Discussing AMD’s Zen 5 at Hot Chips 2024*
- 发布日期：2024 年 9 月 15 日
- 阅读原文：https://chipsandcheese.com/p/discussing-amds-zen-5-at-hot-chips-2024

## 摘要

结合 AMD Hot Chips 演讲、会场问答、优化指南和微基准，梳理 Zen 5 的双译码、Op Cache、统一调度、512-bit 执行、LSU 与 SPEC 表现。

## 分享卡片文案

双 Decoder 为什么不能合给单线程？6K 项为何可能比 6.75K 更有效？Zen 5 的真正进步藏在路径覆盖与成本控制里。

## 封面

- 主标题：ZEN 5 @ HOT CHIPS
- 副标题：宽核心背后的设计取舍
- 小字：Frontend / Scheduler / 512-bit / LSU
- 比例：2.35:1；AMD 橙色管线框图风格

## 推荐标签与栏目

- 标签：AMD、Zen 5、Hot Chips、CPU 前端、乱序执行、AVX-512、Cache
- 栏目：处理器体系结构

## 图片与排版

- 正文 18 张图，按 01～18 上传。
- 图 14～18 是 SPEC 数据，图例和脚注不可裁切。

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/discussing-amds-zen-5-at-hot-chips-2024
- 原创声明：关闭
- AI 内容标识：按平台要求开启

## 发布前边界

- 正式幻灯片、AMD 问答、优化指南与微基准结论分别表述。
- SPEC 独立测试未锁频，内存配置不同，且为未提交的 Estimate。
- 202 个在飞 Load 不是 AMD 确认的 Load Queue 项数。
- 取指双管线是否共同服务单线程仍未由微基准确认。
