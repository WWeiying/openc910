# Loongson 3A5000 微信公众号发布资料

## 正式发布信息

- 正式标题：龙芯 3A5000：LA464 的实力、短板与追赶难题
- 署名：Chester Lam、George Cozma；来源：Chips and Cheese；发布日期：2023 年 4 月 9 日
- 英文标题：Loongson’s 3A5000: China’s Best Shot?
- 原文/阅读原文：https://chipsandcheese.com/p/loongsons-3a5000-chinas-best-shot

### 摘要

从 30 张图理解 LA464：四宽 OoO、256-bit Vector、16 MB L3 与 16 KB Page 有亮点；64 项 BTB、低频、L2/DRAM 和软件生态则暴露完整系统追赶的难度。

### 封面/分享

- 主标题：龙芯 3A5000；副标题：LA464 的实力与短板
- 分享文案：3A5000 的 L1D/Vector 并不弱，真正难题是前端供给、低频下的绝对延迟、理论 L3 口宽无法兑现，以及 Hardware/ISA/Toolchain 必须同步追赶。

### 备选标题

- 30 张图看懂龙芯 3A5000
- LA464：一颗四宽国产核心的完整剖面
- 龙芯 3A5000 为什么仍难追上现代大核

### 标签/栏目

- 龙芯 3A5000、LA464、LoongArch、国产 CPU、Branch Prediction、Cache、CPU Microarchitecture
- 栏目：处理器体系结构

## 图片、排版与后台

- 30 图，目录 `loongson_3a5000_figures/`，01～30；封面建议 1/3/23；COS HTTPS。
- 正文 15～16 px，图注 12～13 px；显式保留“体系结构视角”。
- 后台标题同正式标题；作者 Chester Lam、George Cozma；原创关闭；AI 标识开启；阅读原文同上。

## 关键边界与发布检查

- 大量 LoongArch64 Assembly 首次编写、无第二颗已知 CPU 校验，误差风险必须保留。
- LA464 Tournament/GS464V 来源/L2 Coherence 等是可能/推测，不写成确认。
- 64 BTB、128 ROB、Queue 等为测试/资料口径；图 13 Zen LQ 采用可见 116。
- Old/New World、Binary Translation 是 2023 文章时点，不外推到当前生态。
- 对原材料的尖锐评价自然转述，但不升级为官方事实或民族化结论。
- 30 图、MIME、Pandoc、禁词、COS 200、母稿/WeMD 一致后发布。
