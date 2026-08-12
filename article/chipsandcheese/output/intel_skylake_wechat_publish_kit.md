# Intel Skylake 微信公众号发布资料

## 正式发布信息

- 正式标题：Skylake：Intel 服役时间最长的一代核心
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2022 年 10 月 14 日
- 英文标题：Skylake: Intel’s Longest Serving Architecture
- 原文/阅读原文：https://chipsandcheese.com/p/skylake-intels-longest-serving-architecture

### 摘要

从 46 张图回看 Skylake：Client 提升有限，却为 Server Mesh、AVX-512 与产品族复用打底；四宽核心靠稳健前端、Cache 和 14 nm 迭代意外服役六年。

### 封面文案

主标题：Skylake

副标题：服役时间最长的 Intel Core

### 分享文案

Skylake 本应是 Cannon Lake 前的过渡，却靠平衡设计、14 nm 迭代和模块化 Ring 抵挡三代 Zen；它既是架构成功，也是一段 Roadmap 失误史。

### 备选标题

- 46 张图回看 Skylake 的六年
- Skylake 为什么能撑过三代 Zen
- Intel 最长寿核心：成功设计与失败路线图

### 文章标签

- Intel Skylake
- CPU Microarchitecture
- Branch Prediction
- AVX-512
- Cache
- Ring Bus
- Mesh

### 所属栏目

经典处理器

## 图片与排版

- 正文 46 图，目录 `intel_skylake_figures/`，01～46；密集矩阵/Die 保留原尺寸。
- 封面建议图 1、2 或 46；正文 15～16 px，图注 12～13 px。
- 显式保留“体系结构视角”；WeMD 使用腾讯云 COS。

## 后台设置

- 标题：Skylake：Intel 服役时间最长的一代核心
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/skylake-intels-longest-serving-architecture
- 原创声明：关闭；AI 内容标识：开启；图片顺序：01～46

## 关键边界与发布检查

- Predictor 类似 Haswell，不写成完全相同；Die Annotation 是猜测。
- Decoder 5 Micro-op 但 4 Instruction，Op Cache 6-wide，Rename 4-wide，勿混为一个宽度。
- Scheduler 58+39；x87/MMX RF 与 AVX-512 Mask 关联是产品族解释。
- Meltdown/Whiskey Lake 措辞保持 speculative/faulting-load 边界。
- Client Ring 与 Server Mesh、256 KB 与 1 MB L2、Inclusive 与 Non-inclusive 分开。
- 5.7%/11.2% 来自 AnandTech 口径；跨平台对照不升级为统一排名。
- 46 图链接/MIME、Pandoc、COS 200、母稿/WeMD 归一化一致后发布。
