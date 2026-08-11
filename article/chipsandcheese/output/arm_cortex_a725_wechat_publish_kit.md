# Cortex-A725 微信公众号发布资料

## 正文文件

- 母稿：`arm_cortex_a725_wechat_article_zh.md`
- WeMD 发布副本：`arm_cortex_a725_wechat_article_zh_wemd.md`
- 图片目录：`arm_cortex_a725_figures/`
- WeMD 主题：`custom-1786280678341-jnfpaqasm`（学术论文（副本））

发布时把 WeMD 副本导入 WeMD。该文件由母稿自动生成，不单独修改；母稿更新后，重新运行：

```bash
prepare-wemd-cos article/chipsandcheese/output/arm_cortex_a725_wechat_article_zh.md
```

## 发布字段

- 标题：Cortex-A725 深度拆解：五宽乱序、精简前端与密度优化
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2026 年 1 月 27 日
- 英文标题：Arm’s Cortex A725 ft. Dell’s Pro Max with GB10
- 文章链接：https://chipsandcheese.com/p/arms-cortex-a725-ft-dells-pro-max
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a725-ft-dells-pro-max

### 摘要

从 Nvidia GB10 的 22 张图表出发，完整拆解 Cortex-A725 的五宽前端、分支预测、224 项 ROB、三 AGU、TLB 合并与 Cache 层次，并解释密度优化为何不是简单缩小大核。

### 封面文案

主标题：Cortex-A725 深度拆解

副标题：五宽乱序与密度优化

### 分享文案

A725 增大 ROB 和内存窗口，却取消 MOP Cache、缩小 BTB，并重新分配 FP/向量资源。22 张图看清 Arm 密度核心怎样在性能、面积和功耗之间做取舍。

### 备选标题

- Arm 密度核心如何取舍：完整拆解 Cortex-A725
- 从分支预测到 TLB 合并：Cortex-A725 微架构实测
- A725 为什么取消 MOP Cache：五宽中核的资源重配

### 文章标签

- Cortex-A725
- Arm CPU
- CPU 微架构
- 分支预测
- 乱序执行
- TLB
- Cache
- Nvidia GB10

### 所属栏目

CPU 微架构

## 文首来源信息

正文开头保留：

> **文章来源**
>
> - 文章：*Arm’s Cortex A725 ft. Dell’s Pro Max with GB10*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2026 年 1 月 27 日
> - 链接：https://chipsandcheese.com/p/arms-cortex-a725-ft-dells-pro-max

## 图片资料

- 正文图片：22 张
- 文件顺序：`01`～`22`
- 文件格式：PNG、JPG，扩展名与真实 MIME 一致
- 图片来源：英文网页正文，按出现顺序提取
- 每张图后均有中文标题、读图说明、关键数据和体系结构含义或结论边界
- WeMD 副本已把 22 张图片替换为腾讯云 COS HTTPS 地址
- 22 个 COS 对象均已检查为 HTTP 200，`Content-Type` 为 `image/png` 或 `image/jpeg`

图 4、5 为三维分支模式曲面，图 13 为 64×64 高密度对齐矩阵，图 19、20 为较长的 SPEC 分项图。发布时不要裁掉坐标、图例和表注，并在手机预览中确认可以点开原图。

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：深蓝、墨绿或低饱和蓝灰
- 画面主体：A725 框图轮廓、五路前端、ROB 与 DSU/L3 层次
- 主体文字：Cortex-A725 深度拆解
- 辅助文字：五宽乱序与密度优化
- 右下角小字可选：Chips and Cheese / Chester Lam

标题和 A725 标识放在中央安全区，避免最左、最右的重要文字在消息列表与分享卡片中被裁切。封面不要把框图缩到需要放大才能看清内部数字，正文图 2 才承担精确参数展示。

## 移动端排版

- 正文字号：15～16 px
- 正文行距：1.7～1.8
- 一级小标题：18～20 px，加粗
- 二级小标题：16～17 px，加粗
- 图片说明：12～13 px，灰色
- 段间距：10～14 px
- 容量、频率、周期和英文缩写保留半角字符
- `CMP + branch`、`MOV r,0`、`intrate-1`、`L2D_TLB_REFILL` 等使用行内代码样式

正文没有 Markdown 数据表，避免公众号出现横向滚动。图 3、11、12、15、17 已保留为原始表格图片，手机端应允许点击查看大图。

## 后台设置

- 标题：Cortex-A725 深度拆解：五宽乱序、精简前端与密度优化
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a725-ft-dells-pro-max
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～22

## 发布时保持的技术边界

- 测试对象是 Nvidia GB10 中 2.8 GHz 的 A725；两个簇分别有 8 MB 和 16 MB L3。不能把 GB10 的频率、L3、DSU 和内存表现写成所有 A725 实现的固定属性。
- 32/512/8192 项 BTB、16 项 RAS、各调度器深度及部分物理寄存器/队列容量包含微基准反推，不得全部改写成 Arm 官方参数。
- 图 2 把 ITLB 标为 48 项，正文和取指讨论写 32 项；图 2 把 Store Queue 标为 67 项，图 12 则写 78 项。两处差异均已保留，排版时不要静默统一。
- 分支章节先把 A725 概括为与 A715 互有胜负，后面的数值和曲面却使用 A710 对照；正文已自然说明这一口径变化。
- 图 13 结合测试语境应为 64-bit Store 到 32-bit Load，但原图左侧标签可读成 `64-bit Load Offset`。正文将其视为很可能的图内标注错误，没有改动原图。
- `8x32` 被解释为 8 个连续 4 KB 页面合成 32 KB 覆盖，是根据名称和 AMD page smashing 做出的推测；`4x2048` 的精确含义仍未知。
- TRM 的四条 64-bit L1D 写路径与两条 Store AGU 描述的是不同层面，现有资料不足以确认内部映射，不能直接写成每周期四条 Store。
- 图 17 来自 Arm 优化指南的假设模型，假设 3 GHz 核心、2 GHz DSU、异步桥和 1～4 核簇，不是 GB10 实测；GB10 每簇实际有 10 个混合核心。
- SPEC CPU2017 图为估算单副本成绩。平台的 ISA、频率、Cache、内存和执行指令数不同，网页也没有披露完整编译与复测条件，因此不能改写成官方排名。
- 材料不含 A725 RTL。体系结构视角中的 checkpoint、重放、失效和恢复逻辑是通用机制分析，不是对 A725 具体信号和模块的确认。

## 发布预览要点

- 标题、署名、日期、平台和阅读原文链接与正文一致。
- 22 张图片顺序连续，母稿与 WeMD 副本图片数一致。
- WeMD frontmatter 中的主题、主题名和 title 字段正确。
- `2.8 GHz`、`224`、`164/78`、`32/512/8192`、`1536`、`133.34 GB/s` 等关键数据显示正常。
- 图 2、10、12、13 中的内部差异仍可见，近似和推测没有被排版删除。
- 图 13、19、20 在手机上可点开，图例与坐标未被裁切。
- COS 图片可匿名加载，无破图、强制下载或 MIME 错误。
- 手机预览无横向滚动、标题孤行、图号错位或超长英文链接破版。
