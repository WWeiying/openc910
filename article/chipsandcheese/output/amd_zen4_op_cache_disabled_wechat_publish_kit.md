# 关闭 Zen 4 Op Cache 微信公众号发布资料

## 正式发布信息

- 正式标题：关闭 Zen 4 的 Op Cache：六宽前端退回四宽后会怎样
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2024 年 12 月 11 日
- 英文标题：Turning off Zen 4's Op Cache for Curiosity and Giggles
- 原始链接：https://chipsandcheese.com/p/turning-off-zen-4s-op-cache-for-curiosity

### 摘要

通过 MSR 禁用 6.75K 项 Op Cache，让 Zen 4 只靠四宽 Decoder。SPEC 整数/浮点分别下降 11.4%/6.6%，SMT 更重，Cyberpunk 却不到 1%。

### 封面与分享文案

- 主标题：Zen 4 退回四宽
- 副标题：关闭 6.75K Op Cache 的代价
- 分享文案：exchange2 为什么掉 32%，omnetpp 与 Cyberpunk 又几乎不动？答案藏在 Branch 密度、IPC、SMT 与后端等待里。
- 备选标题：没有 Op Cache，Zen 4 还能有多快；9 uops/cycle 对 4-wide Decoder

### 标签与栏目

- 标签：AMD、Zen 4、Op Cache、Decoder、SMT、SPEC CPU2017
- 栏目：CPU 微架构

## 图片与移动端排版

- 图片 21 张，目录 `amd_zen4_op_cache_disabled_figures/`，按 01～21 上传。
- 封面以 9-wide Op Cache 与 4-wide Decoder 对照；柱图全宽。

## 后台设置与发布前检查

- 这是人为关闭关键结构的实验，不是零售默认状态。
- 事件 0xAA 统计投机供给；Taken Branch 主因是支持性解释而非直接计数确认。
- SPEC 与游戏平台/CCD、Boost 设置不同；不能混成统一百分比。
- 核对 6.75K、144、9/6/4-wide、11.4/6.6/16/10.3%、35.04%、4.2 GHz 与 21 张图。
- 后台原创关闭，AI 标识按要求开启，阅读原文填完整链接。
