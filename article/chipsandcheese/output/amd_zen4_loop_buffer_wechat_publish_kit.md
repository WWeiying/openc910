# Zen 4 Loop Buffer 微信公众号发布资料

## 正式发布信息

- 正式标题：AMD 为何悄悄关闭了 Zen 4 的 Loop Buffer
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2024 年 11 月 30 日
- 英文标题：AMD Disables Zen 4's Loop Buffer
- 原始链接：https://chipsandcheese.com/p/amd-disables-zen-4s-loop-buffer

### 摘要

AGESA 更新后 Zen 4 的 144 项 Loop Buffer 不再供给微操作。SPEC 几乎无损，Op Cache 接手大多数工作；游戏出现未解释异常，功耗计数又彼此矛盾。

### 封面与分享文案

- 主标题：Zen 4 关闭 Loop Buffer
- 副标题：性能无感，原因仍未知
- 分享文案：从 BIOS 回退、PMU Count Mask 到 SPEC 与 Cyberpunk，复盘一项从未被 AMD 大力宣传、又被静默停用的前端机制。
- 备选标题：一项消失在 AGESA 更新里的 Zen 4 前端功能；144 项 Loop Buffer 为何无关性能

### 标签与栏目

- 标签：AMD、Zen 4、Loop Buffer、AGESA、Op Cache、CPU 前端
- 栏目：CPU 微架构

## 图片与移动端排版

- 图片 25 张，目录 `amd_zen4_loop_buffer_figures/`，按 01～25 上传。
- 封面用 Loop Buffer→Op Cache 交接示意；计数器柱图保持全宽。

## 后台设置与发布前检查

- 144/72 项是计数器反推；关闭位于两个 AGESA 版本之间。
- Bug 只是类比 Skylake 后的猜测，不写成 AMD 已确认。
- Cyberpunk 普通 CCD 约 5% 异常无解释；V-Cache CCD 帧率基本不变。
- Core Energy Status 结果不自洽，不能给出节能结论。
- 核对 3.64/4.31 IPC、56.67%/75.1%、4.2 GHz 与 25 张图；后台原创关闭，AI 标识按要求开启。
