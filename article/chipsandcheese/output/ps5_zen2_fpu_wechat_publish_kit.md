# PS5 Zen 2 FPU 微信公众号发布资料

## 正式发布信息

- 正式标题：PS5 的 Zen 2 FPU 如何从四端口缩成两端口
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2024 年 3 月 20 日
- 英文标题：The Nerfed FPU in PS5’s Zen 2 Cores
- 原始链接：https://chipsandcheese.com/p/the-nerfed-fpu-in-ps5s-zen-2-cores

### 摘要

BC-250 微基准显示 PS5 风格 Zen 2 删除 FP3、让 FP2 只做 Store，却保留 160 项 Register、36+64 Queue 与执行延迟，换来 FPU 面积缩小约 35%。

### 封面与分享文案

- 主标题：PS5 的双端口 Zen 2 FPU
- 副标题：删执行单元，保留乱序窗口
- 分享文案：游戏 FP Pipe 平均不到 1%，Y-Cruncher 却让 Scheduler Full 达 17.32%；这就是定制核心的面积—吞吐取舍。
- 备选标题：PS5 如何精简 Zen 2；从四条 FP Pipe 到两条数学 Pipe

### 标签与栏目

- 标签：AMD、PlayStation 5、Zen 2、FPU、BC-250、CPU 定制、Zen 4c
- 栏目：CPU 微架构

## 图片与移动端排版

- 图片 25 张，目录 `ps5_zen2_fpu_figures/`，按 01～25 上传。
- 封面用 FP0～FP3 删除/迁移示意；Die Photo 保留原尺寸。

## 后台设置与发布前检查

- 测试平台是 Harvested PS5 Chip 的 BC-250，不是零售 PS5。
- 与 Steam Deck 跨 SoC；只用三核且有 4% Integer 基线差，不能把全差值归 FPU。
- 8/6 Read Port、FCLK 约 1.2 GHz 为反推；160 项与 Pipe 能力来自微基准。
- Die 面积来自像素测量，不是 AMD Floorplan。
- 核对 0.91/0.59 mm²、160×256-bit、192/128 B/cycle、14.9/0.45/16.4%、6.48/17.32% 与 25 张图。
- 后台作者栏填 Chester Lam，“阅读原文”使用完整链接；原创声明关闭，AI 内容标识按平台要求开启。
