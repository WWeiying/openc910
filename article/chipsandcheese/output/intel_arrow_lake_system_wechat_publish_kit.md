# Arrow Lake 系统架构｜微信公众号发布资料

## 正式标题

从系统层看 Arrow Lake：高带宽 Chiplet，为何仍有高延迟

## 备选标题

- 读写带宽接近理论值，Arrow Lake 延迟为何超过 100 ns
- Foveros、Ring 与 36 MB L3：拆解 Arrow Lake 系统架构
- Arrow Lake 的 Chiplet 答卷：吞吐很强，固定路径还很长

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Examining Intel’s Arrow Lake, at the System Level*
- 发布日期：2024 年 12 月 4 日
- 阅读原文：https://chipsandcheese.com/p/examining-intels-arrow-lake-at-the

## 摘要

Arrow Lake 的 FDI 提供近乎单片的 DRAM 带宽，却伴随超过 100 ns 的内存延迟、80 周期以上 L3 和意外偏高的 P-Core 核间延迟。

## 分享卡片文案

Chiplet 可以同时高带宽、高延迟。21 张图从 Foveros、Ring、L3 和一致性路径解释 Arrow Lake 的系统级取舍。

## 封面与标签

- 主标题：ARROW LAKE SYSTEM
- 副标题：高带宽 Chiplet 的延迟代价
- 小字：FDI / Ring / 36 MB L3 / >100 ns
- 标签：Intel、Arrow Lake、Foveros、Chiplet、L3 Cache、内存延迟
- 栏目：处理器体系结构

## 图片与排版

- 正文 21 张图，按 01～21 上传；图 8～18 为核心数据。

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/examining-intels-arrow-lake-at-the
- 原创声明：关闭；AI 内容标识按平台要求开启。

## 发布前边界

- Meteor Lake、9900X 与 285K 平台内存配置不同，重点是拓扑趋势。
- “2K Mainband Width”不足以直接推出 2048-bit 有效数据通路。
- Core-to-core 方法不能单独证明 Lion Cove 一致性内部步骤。
- Arrow Lake 当时缺少公开 L3 PMU，部分多核带宽验证借助 Zen 5 对照。
