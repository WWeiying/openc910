# Zen 2 Cinebench R15 微信公众号发布资料

## 正式发布信息

- 正式标题：Zen 2 为什么能在 Cinebench R15 单线程领先 Skylake
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2021 年 2 月 22 日
- 英文标题：Analyzing Zen 2’s Cinebench R15 Lead
- 原始链接：https://chipsandcheese.com/p/analyzing-zen-2s-cinebench-r15-lead

### 摘要

96% 分支准确率、512 KB/12-cycle L2，以及 36 项 FP Scheduler 后的 64 项 NSQ，共同让 Zen 2 在 CBR15 单线程领先 Skylake。

### 封面与分享文案

- 主标题：Zen 2 为何领先 Skylake
- 副标题：预测、Cache 与 36+64 FP 队列
- 分享文案：执行端口并没有跑满，Op Cache 命中率还更低；真正差距藏在错误路径、L2 miss 和后端窗口里。
- 备选标题：拆开 Cinebench R15 的 Zen 2 优势；不是更宽执行端，而是更少等待

### 标签与栏目

- 标签：AMD、Zen 2、Intel Skylake、Cinebench R15、Branch Prediction、Scheduler、Cache
- 栏目：CPU 微架构

## 图片与移动端排版

- 图片 19 张，目录 `amd_zen2_cinebench_r15_figures/`，按 01～19 上传。
- 相关散点图全宽，图注保留 PMU 口径限制。

## 后台设置与发布前检查

- CBR15 为单线程、1 s 阶段采样；相关性不自动证明因果。
- Zen/Intel Data Source、Microcode 与 Stall 事件口径不同。
- Skylake RS/ROB Unit Mask 在 Haswell 后未文档化，结论需保留疑问。
- 192 个后端等待微操作是结构合计表达，不是一个统一 Scheduler。
- 核对 41.7%、5.15/6.45 MPKI、1.39/1.63、97/128、36+64、512/256 KB 与 19 张图。
- 后台作者栏填 Chester Lam，“阅读原文”使用完整链接；原创声明关闭，AI 内容标识按平台要求开启。
