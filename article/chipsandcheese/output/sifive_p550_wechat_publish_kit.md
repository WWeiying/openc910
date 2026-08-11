# SiFive P550 微信公众号发布资料

## 正文文件

- 母稿：`sifive_p550_wechat_article_zh.md`
- WeMD 发布副本：`sifive_p550_wechat_article_zh_wemd.md`
- WeMD 主题：`custom-1786280678341-jnfpaqasm`（学术论文（副本））

发布时将 WeMD 副本导入 WeMD。该副本由母稿自动生成，不单独修改；母稿更新后，重新运行 `prepare-wemd-cos article/chipsandcheese/output/sifive_p550_wechat_article_zh.md` 即可同步正文和图片。

## 发布字段

- 标题：SiFive P550 深度拆解：三宽乱序、Cache 层次与 SoC 边界
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2025 年 1 月 26 日
- 英文标题：Inside SiFive’s P550 Microarchitecture
- 文章链接：https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture
- 阅读原文链接：https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture

### 摘要

Chester Lam 在搭载 EIC7700X 的 P550 开发板上进行微架构探测。微基准反推出约 96 项可见 ROB 容量，也揭示了分支预测、TLB、未对齐访问、Cache、DRAM 与核间传输的能力边界。

### 封面文案

主标题：SiFive P550 深度拆解

副标题：三宽乱序与 SoC 边界

### 分享文案

微基准反推出约 32 项快速 BTB 和约 96 项 ROB，也测到上千周期的未对齐慢路径。从 23 张图表理解 SiFive P550 的设计配比，并分清核心 IP 与 EIC7700X SoC 的边界。

### 备选标题

- RISC-V 乱序核心走到哪一步：SiFive P550 微架构实测
- 从分支预测到共享 L3：完整拆解 SiFive P550
- SiFive P550 的取舍：三宽后端、私有 L2 与未对齐慢路径

### 文章标签

- SiFive P550
- RISC-V
- CPU 微架构
- 分支预测
- 乱序执行
- Cache 与一致性
- EIC7700X

### 所属栏目

CPU 微架构

## 文首来源信息

正文已经包含以下来源信息，发布时直接保留：

> **文章来源**
>
> - 文章：*Inside SiFive’s P550 Microarchitecture*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 1 月 26 日
> - 链接：https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture

## 图片资料

- 正文图片：23 张
- 文件目录：`sifive_p550_figures/`
- 文件顺序：`01` 至 `23`
- 图片格式：PNG、JPG
- 图片来源：英文网页中的图表，按出现顺序提取
- 每张图片下方均有中文标题、读图说明、关键数据及体系结构意义或结论边界
- 图中英文坐标、模块名、问号、近似号和数据保持不变，便于与网页核对
- WeMD 副本中的图片由脚本上传腾讯云 COS，并替换为 HTTPS 地址
- 当前 23 个 COS 对象均已验证为 HTTPS 200，可匿名读取；JPG/PNG 的 `Content-Type` 与文件格式一致，存储类型为 `MAZ_STANDARD`

图片按文件名前缀顺序上传。图 4、5 是三维预测曲面；图 13、14 是高密度 Store forwarding 矩阵；图 19、20、23 是模块框图。发布时不要二次裁切，并允许读者点击查看原图。

当前图片使用 COS 默认域名时，对象可匿名读取并返回正确图片类型，但腾讯云可能附加 `Content-Disposition: attachment` 与强制下载响应头。若后续启用已备案、带 HTTPS 的自定义域名，应更新本地 COS 配置并重新生成 WeMD 副本，再做一次公众号抓图预览。

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：深蓝、墨绿或低饱和青灰
- 画面主体：P550 核心框图轮廓、三路前端箭头、四 bank L3 与 crossbar
- 主体文字：SiFive P550 深度拆解
- 辅助文字：三宽乱序与 SoC 边界
- 右下角小字可选：Chips and Cheese / Chester Lam

把核心框图和标题放在中央安全区。避免把“P550”“3-wide”“4-bank L3”等关键信息放在最左或最右，以免消息列表和分享卡片裁切。

## 移动端排版

- 正文字号：15～16 px
- 正文行距：1.7～1.8
- 一级小标题：18～20 px，加粗
- 二级小标题：16～17 px，加粗
- 图片说明：12～13 px，灰色，居中
- 段间距：10～14 px
- 正文颜色：深灰色
- 容量、频率、延迟和英文缩写保留半角字符
- `ret`、`valid/ready`、`cause/tval`、`cycle`、`instret` 等使用等宽字体或浅灰底行内代码样式

正文没有使用 Markdown 数据表。关键参数以短段和列表呈现，网页中的容量表与矩阵作为图片保留，避免手机端出现横向滚动。

## 后台设置

- 标题：SiFive P550 深度拆解：三宽乱序、Cache 层次与 SoC 边界
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分
- 阅读原文：https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～23

## 来源与表述要求

- SiFive 的“性能高 30%、面积不到一半”是带条件的厂商目标，文章没有在同工艺、同频率、同软件下复现，不得改写成已经得到验证的结论。
- 测试对象是 1.4 GHz、四核 EIC7700X 中的 P550。4 MB L3、194 ns DRAM、16.74 GB/s 内存带宽和核间矩阵约 380 的高值不能外推为所有 P550 实现的固定属性；核间图本身没有打印单位。
- 约 32 项快速 BTB、约 96 项 ROB、20/16 项 Load/Store Queue、28 项 FP 调度容量来自第三方微基准反推，不得去掉“约”或写成 SiFive 官方规格。
- 图 2 把 L2 TLB 标为“约 256 项？”，后文图 12 与正文采用 512 项；发布时保留这个图文口径差异。
- 图 3 画出 Cortex-A75 的约 48 项 L0 与 3072 项 L1 BTB，后面的文字却称其似乎只有一个小型 BTB 层级；不能擅自统一。
- A75 总览图把 Load Buffer 写成 69，容量表写成 68；两者都是微基准反推，发布时不擅自统一。
- 未对齐 Load 的约 1062 周期、约 505 条附加执行指令支持软件异常模拟假说，但没有 RTL 或内核路径证据，不得写成已确认硬件实现。
- 图 13 正文把未对齐 Load/Store 分别归为约 1062/741 周期，但按图轴读取似乎正好相反；正文已经把它列为未确定项，发布时不得静默选择一种口径。
- RISC-V 不普遍保证未对齐访问的原子性；只有执行环境或软件模拟明确承诺全有或全无时，跨页 Store 才必须先完成两页验证。不要把“无架构可见副作用”改写成“Cache 内部不得发请求或分配”。
- 图 15、17 的对照为 Cortex-A73/Amlogic S922X；其他核心章节主要为 Cortex-A75/Snapdragon 670。不要把 A73 与 A75 混写。
- P550 与 A75 的频率、ISA、Cache、SoC 和软件栈不同；文章也没有给出统一应用 Benchmark，因此不能从单个微基准推出跨 ISA 产品总排名。
- 文章未给出操作系统、编译器、完整微基准源码、预热、重复次数和误差范围；这些缺失条件不得在排版时自行补齐。
- P550 没有向量能力是分析带宽需求的重要条件，不要把 A75 的 NEON 测试能力直接套到 P550。
- core-to-core latency 测试的方法与 AnandTech 并不相同，两边的结果只能作大致对照；约十倍差距可以说明 EIC7700X 路径很慢，不能仅凭矩阵定位到某个 fabric 模块。
- EIC7700X 核间图和 Snapdragon 670 对照图均未打印单位；正文已把“上下文通常按 ns 理解”与图内直接事实分开。
- EIC7700X 手册语境中的图 19，图底小字写作 `EIC700X block diagram`；不要在图片上覆字修正。

## 发布预览要点

- 标题、署名、日期、平台和文章链接与文首信息一致。
- 23 张图片顺序正确，每张图片下方都有对应中文图注。
- P550、EIC7700X、Premier P550 Dev Board、Snapdragon 670、Cortex-A75 与 Cortex-A73 没有混写。
- `1.4 GHz`、`9.1 KiB`、`32 KB`、`96`、`20/16`、`3.01/13.06/38.11 cycle`、`43.88 GB/s`、`194 ns` 等数值显示正常。
- 图 2、3、12 的问号、约号和图文差异仍保留。
- 图 13、14 的密集数字在手机上可点击查看原图，没有被压缩到无法辨认。
- 母稿、WeMD 副本中的图片数一致，COS URL 可通过 HTTPS 匿名读取。
- 手机预览无横向滚动、图片裁切、图号错位或英文链接断行。
