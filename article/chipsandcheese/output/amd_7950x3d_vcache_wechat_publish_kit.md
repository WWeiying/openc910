# AMD Ryzen 9 7950X3D 微信公众号发布资料

## 正式发布信息

- 正式标题：AMD Ryzen 9 7950X3D：Zen 4 的 V-Cache 容量、延迟与调度取舍
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2023 年 4 月 23 日
- 英文标题：AMD’s 7950X3D: Zen 4 Gets VCache
- 原始链接：https://chipsandcheese.com/p/amds-7950x3d-zen-4-gets-vcache

### 摘要

一颗 96 MB L3 CCD 与一颗 32 MB 高频 CCD，让 7950X3D 把容量、延迟和频率的取舍摆到操作系统面前。27 张图覆盖延迟、带宽、游戏、压缩与 eDRAM 对照。

### 封面与分享文案

- 主标题：7950X3D 的两种核心
- 副标题：96 MB 容量与 7% 频率如何取舍
- 分享文案：多四周期 L3，换来三倍容量；GHPC、Cyberpunk、DCS、COD、libx264 与 7-Zip 却给出不同答案。
- 备选标题：V-Cache 并不总是更快；7950X3D：大 Cache CCD 对高频 CCD

### 标签与栏目

- 标签：AMD、Zen 4、7950X3D、3D V-Cache、L3 Cache、Chiplet
- 栏目：CPU 微架构

## 图片与移动端排版

- 图片 27 张，目录 `amd_7950x3d_vcache_figures/`，按 01～27 上传。
- 封面建议双 CCD，一侧叠层、一侧高频；图 23～27 的封装对比保留原尺寸。
- 正文 15～16 px；工作负载小节连续排版，不拼图。

## 后台设置与发布前检查

- PMU 为 L3 侧投机请求，含预取；IPC 不等于最终帧率。
- DCS/COD 场景有限或不完全可重复，不能扩展为全游戏排名。
- 18.45/20.8 B/cycle 差因未知；V-Cache 地址/Tag 路径为推测。
- Meteor Lake L4 段落是文章 2023 年的前瞻。
- 核对 96/32 MB、约 7%、四周期、1.61 ns、各工作负载 IPC/MPKI 与 27 张图。
- 后台原创关闭，AI 标识按要求开启，阅读原文填完整链接。
