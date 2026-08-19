# PEZY-SC4s：发布资料

## 正式标题

PEZY-SC4s：用低频众核追求 FP64 能效

## 基本信息

- 英文题目：PEZY-SC4s at Hot Chips 2025
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2025 年 9 月 4 日
- 阅读原文：https://chipsandcheese.com/p/pezy-sc4s-at-hot-chips-2025
- 后台作者栏：Chester Lam

## 摘要

2304 个 PE、每 PE 八线程、256 bit 小向量、四层缓存/本地存储和 3.2 TB/s HBM3：SC4s 试图以低频、细粒度线程和较低分支分歧实现高能效 FP64。

## 封面与分享文案

- 封面：不用超宽 Warp，SC4s 如何做 FP64 众核？
- 分享：PEZY 把线程分成两组，把 L1D 延迟变成同线程三条指令间隔，并以 96 GB HBM3 喂 2304 个 PE。这是一条与主流 GPU 不同的 FP64 路线。

## 备选标题

- Hot Chips 2025：PEZY-SC4s 的小向量众核设计
- 2304 个 PE 与 3.2 TB/s HBM3：拆解 PEZY-SC4s

## 标签与栏目

- 标签：PEZY、SC4s、HPC、FP64、众核处理器
- 栏目：加速器架构

## 图片与排版

- 共 16 张图，图 3 或图 9 适合封面。
- 架构层级图保持原始比例；正文 15～16 px，图注 13 px。

## 发布前检查

- 明确尚无硅片，性能和功耗主要是披露/模拟。
- 保留 270 W、212 W 与 91 GFLOP/W 的推导关系和对比边界。
- 16 张图和参考资料完整。
