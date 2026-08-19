# 飞腾 D2000 微信公众号发布资料

## 正式发布信息

- 正式标题：飞腾 D2000：一颗像 Cortex-A72、却没有完成代际跃迁的八核 CPU
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2022 年 9 月 28 日
- 英文标题：China’s Phytium D2000: Building on A72?
- 原始链接：https://chipsandcheese.com/p/chinas-phytium-d2000-building-on-a72

### 摘要

48张图完整覆盖FTC663的预测、BTB、取指、乱序、执行、LSU、Cache/TLB、带宽和拓扑，并解释它为何在八核下仍输给旧四核。

### 封面与分享文案

- 主标题：飞腾 D2000 的微架构答案
- 副标题：像 A72，又为何没有成为下一代 A72
- 分享文案：64+4096项BTB、22周期L2、164 ns内存、单Load AGU：从微基准看FTC663每一步前进与退步。
- 备选标题：八核D2000为何输给四核Skylake；完整拆解飞腾FTC663

### 标签与栏目

- 标签：飞腾、D2000、FTC663、Arm、Cortex-A72、CPU微架构
- 栏目：CPU 实测与微架构

## 图片与移动端排版

- 图片48张，目录 `phytium_d2000_figures/`，按01～48上传。
- 预测3D图、Forwarding Matrix、延迟/带宽图全宽；政治背景结论与技术结论分段。

## 后台设置与发布前检查

- Bare-metal Linux但版本/编译配置不完整；跨 Skylake/N1/A72平台只解释趋势。
- TAGE、16B Sector、双核Cluster动机等为推断；无RTL。
- 与A72的怪癖高度相似是实验证据，不能升级为实现来源已确认。
- 核对八核2.3 GHz、64/4096 BTB、31 RAS、48 KB L1I、28 Store Queue、7-cycle Forwarding、22/>50 cycle、164 ns、1024 TLB、132.08 mm²及48图。
- 后台作者 Chester Lam；阅读原文完整链接；原创关闭，AI标识按要求开启。
