# Zen 5 Op Cache 与双译码集群｜微信公众号发布资料

## 正式标题

关掉 Zen 5 的 Op Cache：双译码集群到底能做什么

## 备选标题

- Zen 5 的 8-wide 译码，为什么单线程只能用一半
- 37 张图拆解 Zen 5：Op Cache 才是前端主通道
- 关闭微操作缓存后，Zen 5 前端发生了什么

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Disabling Zen 5’s Op Cache and Exploring its Clustered Decoder*
- 发布日期：2025 年 1 月 23 日
- 阅读原文：https://chipsandcheese.com/p/disabling-zen-5s-op-cache-and-exploring

## 摘要

通过 MSR 关闭 Zen 5 的 Op Cache，单独观察双取指/译码集群。SPEC、游戏与 Cinebench 说明：单线程靠微操作缓存，双集群主要为 SMT 和大代码工作集兜底。

## 分享卡片文案

Zen 5 有两套 4-wide 译码器，却不能让单线程得到 8-wide。关闭 Op Cache 后，37 张图给出它们在 SMT、游戏和渲染中的真实角色。

## 封面

- 主标题：ZEN 5 FRONTEND
- 副标题：关掉 Op Cache 以后
- 小字：2×4 Decode / 6K Op Cache / SMT
- 比例：2.35:1；双通路示意汇入一个微操作队列

## 推荐标签与栏目

- 标签：AMD、Zen 5、Op Cache、微操作缓存、译码器、SMT、CPU 前端
- 栏目：处理器体系结构

## 图片与排版

- 正文 37 张图，按 01～37 上传。
- 图 12～17、23～28、29～37 建议按组连续排版。
- 数字密集图保持原比例，不裁掉坐标与图例。

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/disabling-zen-5s-op-cache-and-exploring
- 原创声明：关闭
- AI 内容标识：按平台要求开启

## 发布前边界

- 关闭 Op Cache 是结构探测，不是推荐的日常调优。
- 被测 9900X 使用 DDR5-5600，与此前 9950X/DDR5-6000 数据并非严格同平台。
- x264 的 IPC 小幅提高不等于最终成绩提高。
- 双译码总宽度只在两个 SMT 线程同时使用各自集群时成立。
