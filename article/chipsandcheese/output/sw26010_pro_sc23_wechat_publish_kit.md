# SW26010-Pro 微信公众号发布资料

## 正式发布信息

- 正式标题：SC23 上的 SW26010-Pro：峰值算力之外，Sunway 被什么卡住
- 署名：Chester Lam、George Cozma
- 来源：Chips and Cheese
- 日期：2023 年 11 月 20 日
- 英文标题：China’s New(ish) SW26010-Pro Supercomputer at SC23
- 原始链接：https://chipsandcheese.com/p/chinas-newish-sw26010-pro-supercomputer-at-sc23

### 摘要

六组384 CPE、512-bit Vector和2.25 GHz带来高峰值，但无共享L2、每组双通道DDR4及收敛网络让SW26010-Pro严重受供数限制。

### 封面与分享文案

- 主标题：峰值算力之外的 Sunway
- 副标题：384核为何仍被双通道DDR4卡住
- 分享文案：0.11 B/FP32 FLOP、307.2 GB/s和107,136颗芯片：22张图看懂SW26010-Pro的算力、Scratchpad、NUMA与网络。
- 备选标题：SW26010-Pro：执行单元很多，数据却喂不进去；SC23上的Sunway系统

### 标签与栏目

- 标签：Sunway、SW26010-Pro、超级计算机、HPC、Scratchpad、NUMA、互连
- 栏目：HPC 与多核系统

## 图片与移动端排版

- 图片22张，目录 `sw26010_pro_sc23_figures/`，按01～22上传。
- 芯片/网络拓扑图全宽，Roofline/比率图保持可放大。

## 后台设置与发布前检查

- 2020～2021系统、2023排名语境，不当作当前状态。
- 双通道DDR4-3200与2.7 TB/s Uplink为公开数字反推/假设。
- CPE部分延迟沿用旧SW26010是假设；“为榜单设计”是文章判断。
- 核对6×64 CPE、96 GB、307.2 GB/s、256 KB、0.11 B/FLOP、41,140,224/107,136、10.54/34 GB/s及22图。
- 后台作者 Chester Lam、George Cozma；阅读原文完整链接；原创关闭，AI标识按要求开启。
