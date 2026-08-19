# Skymont 游戏负载微信公众号发布资料

## 正式标题

Skymont 跑游戏：Intel E-Core 已经能做到什么

## 备选标题

- 416 项 ROB、八宽分配：Skymont 还是“小核”吗
- 只开 16 颗 E-Core 跑游戏，会发生什么
- Intel Skymont：密度核心的游戏能力与瓶颈

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Skymont in Gaming Workloads*
- 发布日期：2025 年 8 月 20 日
- 阅读原文：https://chipsandcheese.com/p/skymont-in-gaming-workloads

## 摘要

Skymont 有 416 项 ROB、八宽分配和 4 MB 簇级 L2。游戏实测显示前端已很强，真正限制来自分布式调度、序列化与少量高代价 DRAM miss。

## 分享卡片文案

Skymont 在 Cyberpunk 2077 里只比 Lion Cove 低约 5%，但 416 项 ROB 往往还没满，Scheduler 和分配限制已经先挡住后端。

## 封面

- 主标题：Skymont 跑游戏
- 副标题：E-Core 的能力与瓶颈
- 小字：8-wide / 416 ROB / 4 MB L2 / PMU
- 比例：2.35:1，Intel 蓝，E-Core 方阵与 Top-Down 柱图结合

## 推荐标签与栏目

- 标签：Intel、Skymont、E-Core、Arrow Lake、CPU 微架构、游戏性能、PMU、乱序执行
- 栏目：处理器体系结构

## 图片与排版

- 正文图片：12 张，按 01～12 上传
- 图 3～6、10 是事件定义与分类，图注保留证据边界
- 帧率图不做跨平台绝对排名

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/skymont-in-gaming-workloads
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 平台是 285K、Arc B580、DDR5-6000；不是统一游戏评测套件。
- Memory/Core Bound 是按可用事件近似 AMD 方法，不是 Intel 完整官方分解。
- Cortex-X1 图只说明分布式调度的一般限制，不是 Skymont RTL。
- Crestmont 来自不同笔记本平台，只比较瓶颈构成。
