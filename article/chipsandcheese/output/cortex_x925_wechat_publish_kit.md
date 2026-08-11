# Cortex-X925 微信公众号发布资料

## 正文文件

`cortex_x925_wechat_article_zh.md`

## 发布字段

- 标题：Cortex-X925 深度拆解：十宽前端、巨型乱序窗口与桌面级性能
- 作者：Chester Lam
- 来源：Chips and Cheese
- 原文日期：2026 年 3 月 3 日
- 原文标题：Arm's Cortex X925: Reaching Desktop Performance
- 原文副标题：A big, high performance core from Arm
- 原文链接：https://chipsandcheese.com/p/arms-cortex-x925-reaching-desktop
- 阅读原文链接：https://chipsandcheese.com/p/arms-cortex-x925-reaching-desktop

### 摘要

Chester Lam 在 Nvidia GB10 上测试 Arm Cortex-X925，并与 Zen 5、Lion Cove 对照。文章从分支预测、十宽前端、重命名、巨型乱序窗口、分区调度器、Load/Store、Cache 和 SPEC CPU2017 出发，解释这颗 4 GHz Arm 大核如何进入桌面级单线程性能区间，以及核心之外仍待解决的平台和软件问题。

### 封面文案

主标题：Cortex-X925 深度拆解

副标题：十宽前端与巨型乱序窗口

### 分享文案

十宽前端、约 525 条实用在途容量、六条 FP/向量管线：Cortex-X925 如何在 4 GHz 追上 Zen 5 与 Lion Cove？从 25 张实测图理解 Arm 桌面级大核的设计取舍。

### 备选标题

- Arm 如何做出桌面级大核：Cortex-X925 微架构与 SPEC 实测
- 4 GHz 追上 Zen 5：Cortex-X925 的宽前端与巨型后端
- 从分支预测到 SPEC：完整拆解 Arm Cortex-X925

### 文章标签

- Cortex-X925
- Arm CPU
- CPU 微架构
- 分支预测
- 乱序执行
- Nvidia GB10
- SPEC CPU2017

### 所属栏目

CPU 微架构

## 文首来源信息

正文已经包含以下来源信息，发布时直接保留：

> **原文信息**
>
> - 原文：*Arm's Cortex X925: Reaching Desktop Performance*
> - 副标题：*A big, high performance core from Arm*
> - 原作者：Chester Lam
> - 首发平台：Chips and Cheese
> - 原文日期：2026 年 3 月 3 日
> - 原文链接：https://chipsandcheese.com/p/arms-cortex-x925-reaching-desktop
> - 内容性质：第三方独立技术分析，非 Arm、Nvidia 或 Dell 官方材料
> - 内容说明：标题为“体系结构视角”的段落是为帮助理解而补充的通用机制分析，与原作者的实测、判断和未确定项分别表述

## 图片资料

- 正文图片：25 张
- 文件目录：`cortex_x925_figures/`
- 文件顺序：`01` 至 `25`
- 图片格式：PNG
- 图片来源：原文图表，按原文出现顺序提取
- 每张图片下方均有中文标题、内容解释和体系结构意义
- 图中英文坐标轴、测试标签和原始数据保持不变，便于与原文核对

图片按文件名前缀顺序上传。公众号编辑器中保留每张图片下方的斜体图注。图 6、7、11、18、20～25 含密集数字，上传时不要二次裁切；图 16、17 是高密度 forwarding 矩阵，应使用原尺寸文件并允许读者点开查看。

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：深蓝、青灰或低饱和橙色
- 画面主体：Cortex-X925 核心框图轮廓、十路前端箭头、ROB 与执行端口
- 主体文字：Cortex-X925 深度拆解
- 辅助文字：十宽前端与巨型乱序窗口
- 右下角小字可选：Chips and Cheese / Chester Lam

标题与核心框图放在中央安全区域。避免把“10-wide”“525+ in flight”等关键文字放在最左或最右，以免消息列表和分享卡片裁切。

## 移动端排版

- 正文字号：15–16 px
- 正文行距：1.7–1.8
- 一级小标题：18–20 px，加粗
- 二级小标题：16–17 px，加粗
- 图片说明：12–13 px，灰色，居中
- 段间距：10–14 px
- 正文颜色：深灰色
- 容量、频率、延迟和英文缩写保留半角字符
- `PTRUE`、`madd`、`MOV r,0`、`intrate-1` 等使用等宽字体或浅灰底行内代码样式

正文没有使用 Markdown 数据表。原文中的三张表作为图片保留，避免在手机端产生横向滚动；图 9、11、18 可在公众号编辑器中设置为点击查看原图。

## 后台设置

- 标题：Cortex-X925 深度拆解：十宽前端、巨型乱序窗口与桌面级性能
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-x925-reaching-desktop
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01–25

## 来源与表述要求

- 不把 Chips and Cheese 的第三方微基准写成 Arm、Nvidia 或 Dell 官方规格。
- 图 1 是原作者整理的粗略框图，其中若干容量带问号；正文中的“作者实测与推断”标签必须保留。
- 返回栈正文为 29 项、图 1 为 31 项，原文内部不一致，不在发布时擅自改成同一个数字。
- ROB 有 750 MOP、768 指令、948 NOP 与约 525 条实用在途容量等不同口径；不得只摘取最大数字作为官方 ROB 深度。
- SPEC CPU2017 为作者标注的估算 `rate-1` 成绩，平台和软件配置不完全统一；不能写成 SPEC 官方可比成绩。
- X925 的高动态指令数只对应作者测试的具体 AArch64 构建，不能直接写成“AArch64 指令集效率更低”。

## 发布预览要点

- 标题、作者、日期、平台和原文链接与文首来源信息一致。
- 25 张图片顺序正确，图片下方均有相应中文图注。
- Cortex-X925、Cortex-A725、Zen 5、Lion Cove、Neoverse V2/N2 等名称没有混写。
- `4 GHz`、`10 instructions/cycle`、`2048/16384 BTB`、`245 LQ`、`109 SQ`、`64 B/cycle` 等数值显示正常。
- 图 20 的 X925 总成绩为 11.77/17.14，9900X 为 11.59/19.66，285K 为 11.57/17.29。
- 图 25 中 554.roms 的 X925 指令计数超过 Zen 5 两倍，但正文保留编译器、向量宽度与软件构建边界。
- 手机预览无横向滚动、图片裁切、图号错位或英文链接断行。
