# 中国 CPU SPEC CPU2017 微信公众号发布资料

## 正式发布信息

- 正式标题：用 SPEC CPU2017 比较龙芯与兆芯：IPC、ISA、预测和频率
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2024 年 10 月 19 日
- 英文标题：Running SPEC CPU2017 on Chinese CPUs, and More
- 原始链接：https://chipsandcheese.com/p/running-spec-cpu2017-on-chinese-cpus

### 摘要

统一 GCC 14.2.0、Bare-metal Linux与单Copy Estimated SPEC，比较3A6000/5000和KX-6640MA，并拆开 Instruction Count、IPC、Branch与频率。

### 封面与分享文案

- 主标题：中国 CPU 的 SPEC 透视
- 副标题：高 IPC 为何没有变成高性能
- 分享文案：3A6000预测已到Skylake量级，LoongArch却平均多执行约一成指令，2.5 GHz再把差距放大。
- 备选标题：龙芯3A6000与兆芯KX-6640MA的SPEC答案；IPC、ISA和时钟缺一不可

### 标签与栏目

- 标签：龙芯、兆芯、SPEC CPU2017、LoongArch、LA664、LuiJiaZui
- 栏目：CPU Benchmark 与微架构

## 图片与移动端排版

- 图片17张，目录 `chinese_cpus_spec2017_figures/`，按01～17上传。
- 子项密集图保留原尺寸，移动端允许点开。

## 后台设置与发布前检查

- 全部为Estimated，不满足正式Documentation；单线程Rate一个Copy，SMT才两个Copy。
- Zen1 Oracle VM永久2T分区；Cloud数据需带边界。
- Retired Instruction差同时含ISA与GCC Codegen，不能只归ISA。
- 核对GCC14.2.0、20% SMT、10.6/11.4%、77.1/78%、94%及17图。
- 后台作者 Chester Lam；阅读原文完整链接；原创关闭，AI标识按要求开启。
