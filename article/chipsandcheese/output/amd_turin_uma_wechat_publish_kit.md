# AMD Turin NPS0 微信公众号发布资料

## 正式标题

AMD Turin 的统一内存模式：24 个控制器换来多少带宽，又付出多少延迟

## 备选标题

- 双路 EPYC 只显示一个 NUMA 节点，会发生什么
- AMD NPS0 实测：统一内存访问的代价
- 220 ns DRAM 延迟，Turin NPS0 还值得用吗

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Evaluating Uniform Memory Access Mode on AMD’s Turin ft. Verda (formerly DataCrunch.io)*
- 发布日期：2025 年 11 月 26 日
- 阅读原文：https://chipsandcheese.com/p/evaluating-uniform-memory-access

## 摘要

双路 EPYC 9575F 的 NPS0 把 24 个内存控制器合并成一个节点，降低软件复杂度，却把 DRAM 延迟推到 220 ns 以上。SPEC 子项揭示频率与局部性的对冲。

## 分享卡片文案

把双路服务器伪装成桌面式统一内存，软件更简单，硬件路径却更长。NPS0 的额外带宽要到近 400 GB/s 才开始抵消 90 ns 延迟惩罚。

## 封面

- 主标题：Turin NPS0
- 副标题：统一内存访问的代价
- 小字：2×EPYC 9575F / 24 Controllers / >220 ns
- 比例：2.35:1，双 Socket 向中央统一节点汇聚

## 推荐标签与栏目

- 标签：AMD、EPYC、Turin、NUMA、NPS0、服务器、内存延迟、SPEC CPU2017
- 栏目：处理器体系结构

## 图片与排版

- 正文图片：8 张，按 01～08 上传
- 图 7、8 子项密集，建议横图原比例
- `NPS0/1/2/4`、`NUMA`、`ns`、`GB/s` 保持半角

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/evaluating-uniform-memory-access
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 实例由 Verda 提供，模式根据系统行为判断，文中未给 BIOS 截图。
- SPEC 是单 Copy Rate 估算；5 GHz 与 NPS0 同时变化，不能只归因于 NUMA 模式。
- 普通带宽测试受线程结束不同步影响；受载延迟测试另有同步机制。
