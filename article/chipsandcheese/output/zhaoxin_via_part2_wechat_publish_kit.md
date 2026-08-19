# 兆芯陆家嘴微信公众号发布资料

## 正式发布信息

- 正式标题：VIA 奇异世界之二：兆芯陆家嘴如何重做 Isaiah
- 署名：George Cozma、Chester Lam
- 来源：Chips and Cheese
- 日期：2021 年 9 月 22 日
- 英文标题：The Weird and Wacky World of VIA Part 2: Zhaoxin’s not quite Electric Boogaloo
- 原始链接：https://chipsandcheese.com/p/the-weird-and-wacky-world-of-via-part-2-zhaoxins-not-quite-electric-boogaloo

### 摘要

陆家嘴把Isaiah三宽/65项窗口改成两宽/48项，加入16项L0 BTB和共享4 MB L2，却留下慢RAS、弱AVX和无Memory Dependence Prediction。

### 封面与分享文案

- 主标题：兆芯如何重做 VIA Isaiah
- 副标题：更窄、更小，也有几项聪明优化
- 分享文案：32张图复原陆家嘴：为什么Not-taken Branch可越过128条指令，而一条256-bit AVX又会严重压缩窗口？
- 备选标题：从Nano到陆家嘴；兆芯KX-6000的两宽核心与奇怪AVX

### 标签与栏目

- 标签：兆芯、VIA、Isaiah、LuiJiaZui、x86、AVX、分支预测
- 栏目：CPU 微架构与历史

## 图片与移动端排版

- 图片32张，目录 `zhaoxin_via_part2_figures/`，按01～32上传。
- Scheduler/ROB图与附录依赖链图全宽，保留英文指令名。

## 后台设置与发布前检查

- 16+4096 BTB、2+34 RAS、P6式RRF、Port Mapping均为微基准复原。
- L1文档2周期与测试5周期冲突完整保留；陆家嘴本体4周期仅推测。
- 部分AVX2 Integer可运行但官方不支持AVX2，不能建议生产使用。
- 核对32/4 MB、48周期、16/4096、2/34、48 ROB、12/20 Scheduler、24/22 LSQ、32图。
- 后台作者 George Cozma、Chester Lam；阅读原文完整链接；原创关闭，AI标识按要求开启。
