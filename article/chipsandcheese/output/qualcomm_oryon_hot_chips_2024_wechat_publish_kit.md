# Hot Chips 2024 Oryon｜微信公众号发布资料

## 正式标题

Hot Chips 2024 的 Oryon：8-wide 核心如何被 80 KB TAGE 与 12 MB L2 喂饱

## 备选标题

- Oryon 不只是 8-wide：Qualcomm 如何解决指令和数据供给
- 80 KB TAGE、超大 TLB、12 MB L2：拆解 Oryon
- Qualcomm Oryon 的宽核心方法：预测、预取与大 Cache

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Hot Chips 2024: Qualcomm’s Oryon Core*
- 发布日期：2024 年 8 月 27 日
- 阅读原文：https://chipsandcheese.com/p/hot-chips-2024-qualcomms-oryon-core

## 摘要

Qualcomm 公布 Oryon 的 80 KB TAGE、8-wide 前端、分布式调度、224 项 DTLB、巨大 L2 TLB、12 MB L2 与激进预取，展示宽核心如何获得持续供给。

## 分享卡片文案

8-wide Decode 只是表面。Oryon 真正的投入在 80 KB TAGE、巨大地址翻译覆盖、12 MB L2 和单核近 100 GB/s 的预取带宽。

## 封面

- 主标题：ORYON @ HOT CHIPS
- 副标题：8-wide 核心如何被喂饱
- 小字：80 KB TAGE / 12 MB L2 / Huge TLB
- 比例：2.35:1；Qualcomm 红与深灰，突出预测器—核心—L2 流程

## 推荐标签与栏目

- 标签：Qualcomm、Oryon、Snapdragon X Elite、TAGE、TLB、L2 Cache、CPU
- 栏目：处理器体系结构

## 图片与排版

- 正文 14 张图，按 01～14 上传。
- 图 2、5、9、13 为结构图，保留标注清晰度。

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/hot-chips-2024-qualcomms-oryon-core
- 原创声明：关闭
- AI 内容标识：按平台要求开启

## 发布前边界

- 80 KB、224 项、12 MB 等来自 Qualcomm 幻灯片；未公开表组织不得自行补齐。
- 128 MB TLB 台阶存在 32K/16K/8K 合并页等多种解释。
- 约 62 个 Load 后的 Stall 不能直接等同于 Scheduler 物理容量。
- 近 100 GB/s 是可预取访问模式下的单线程带宽，不是随机访问保证。
