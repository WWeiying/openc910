# 龙芯 3A6000 微信公众号发布资料

## 正文文件

- 母稿：`loongson_3a6000_wechat_article_zh.md`
- WeMD 发布副本：`loongson_3a6000_wechat_article_zh_wemd.md`
- 图片目录：`loongson_3a6000_figures/`
- WeMD 主题：`custom-1786280678341-jnfpaqasm`（学术论文（副本））

发布时把 WeMD 副本导入 WeMD。该文件由母稿自动生成，不单独修改；母稿更新后，重新运行：

```bash
prepare-wemd-cos article/chipsandcheese/output/loongson_3a6000_wechat_article_zh.md
```

## 发布字段

- 标题：龙芯 3A6000 深度拆解：LA664 六宽乱序、SMT 与内存层次
- 署名：George Cozma、Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 3 月 14 日
- 英文标题：Loongson 3A6000: A Star among Chinese CPUs
- 文章链接：https://chipsandcheese.com/p/loongson-3a6000-a-star-among-chinese-cpus
- 阅读原文：https://chipsandcheese.com/p/loongson-3a6000-a-star-among-chinese-cpus

### 摘要

从 39 张图表完整拆解龙芯 3A6000 的 LA664 六宽前端、分支预测、256 项 ROB、双路 SMT、执行端口、Cache 与 DDR4，并解释其每时钟能力与产品竞争力之间的差距。

### 封面文案

主标题：龙芯 3A6000 深度拆解

副标题：LA664 六宽乱序与 SMT

### 分享文案

方向预测进入 Zen 2 量级，ROB 扩至 256 项，L1D 达 64 B/cycle，首次 SMT 带来约 20%～30% 增益。39 张图看清 LA664 的真正进步、资源配比和仍待补齐的系统短板。

### 备选标题

- 从 LA464 到 LA664：龙芯 3A6000 为什么是一次真正的代际升级
- 分支预测、SMT 与六宽后端：完整拆解龙芯 3A6000
- 龙芯 3A6000 做对了什么：LA664 微架构与内存系统实测

### 文章标签

- 龙芯 3A6000
- LA664
- LoongArch
- CPU 微架构
- 分支预测
- SMT
- 乱序执行
- Cache 与内存

### 所属栏目

CPU 微架构

## 文首来源信息

正文开头保留：

> **文章来源**
>
> - 文章：*Loongson 3A6000: A Star among Chinese CPUs*
> - 撰文：George Cozma、Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 3 月 14 日
> - 链接：https://chipsandcheese.com/p/loongson-3a6000-a-star-among-chinese-cpus

## 图片资料

- 正文图片：39 张
- 文件顺序：`01`～`39`
- 文件格式：PNG、JPG，扩展名与真实 MIME 一致
- 图片来源：英文网页正文，按出现顺序提取
- 每张图后均有中文标题、读图说明、关键数据、体系结构含义或结论边界
- WeMD 副本中的 39 张图片已由脚本上传腾讯云 COS，并替换为 HTTPS 地址
- 39 个对象均已检查为 HTTP 200；其中 16 张为 `image/jpeg`、23 张为 `image/png`，存储类型均为 `MAZ_STANDARD`

图 6、7、10 是三维预测曲面，图 26、27 是高密度 Store forwarding 矩阵，图 4、5、17、20、23 是参数密集的结构图或表格。发布时不要裁掉坐标、图例、问号和表注，并在手机预览中确认图片可点击查看原图。

图 1、18、37 来自龙芯公开视频，图 39 来自龙芯公开微信材料；其余图表来自 Chips and Cheese 的整理或测试。公开材料、微基准反推和体系结构机制分析已经在正文中用自然语气分别保留边界。

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：深红、暗金、深灰或低饱和蓝黑
- 画面主体：LA664 六宽前端轮廓、256 项 ROB、SMT 双线程箭头与 Cache 层次
- 主体文字：龙芯 3A6000 深度拆解
- 辅助文字：LA664 六宽乱序与 SMT
- 右下角小字可选：Chips and Cheese / George Cozma & Chester Lam

标题与“3A6000 / LA664”放在中央安全区，避免消息列表与分享卡片裁掉关键信息。封面不必塞入具体参数，正文图 4、17、20 承担详细结构展示。

## 移动端排版

- 正文字号：15～16 px
- 正文行距：1.7～1.8
- 一级小标题：18～20 px，加粗
- 二级小标题：16～17 px，加粗
- 图片说明：12～13 px，灰色，居中
- 段间距：10～14 px
- 正文颜色：深灰色
- `ROB`、`BTB`、`RAS`、`AGU`、`Load Queue`、`Store Queue`、`MPKI`、`RFO` 等缩写保留半角字符
- 容量、延迟和吞吐单位统一保留为 `KB`、`MB`、`cycle`、`ns`、`B/cycle`、`GB/s`

正文没有使用 Markdown 数据表。结构参数、SMT 策略和向量吞吐表保留为原始图片，避免手机端横向滚动。图 4、5、17、20、23、26、27 信息密度较高，应在预览中确认点击后能看清原图。

## 后台设置

- 标题：龙芯 3A6000 深度拆解：LA664 六宽乱序、SMT 与内存层次
- 作者栏：George Cozma、Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分
- 阅读原文：https://chipsandcheese.com/p/loongson-3a6000-a-star-among-chinese-cpus
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～39

## 表述与预览要点

- 保留 2.5 GHz、4 核 8 线程、双通道 DDR4-2666 等被测条件，不把 LA664 核心能力外推为所有龙芯平台表现
- 7-Zip 与 libx264 的跨 ISA 结果受编译器、向量化、动态指令数和平台影响，不从微小差距得出绝对架构排名
- 64 项 BTB、1K～4K 次级目标容量、32/16 项 RAS、75/80 项 Load Queue 等均按曲线或图表口径描述，不改写成 RTL 确认
- 图 4/17 的 63/64 项 Branch Order Buffer、75/80 项 Load Queue，以及图 32/33 与正文“512 bytes”之间的冲突保持说明
- 图 38 没有单位，不在标题、摘要或分享文案中擅自补成 cycle/ns
- “体系结构视角”继续显式保留，用于区分通用机制解释与网页中的测试观察
- 发布前在微信编辑器里依次检查 39 张图，重点确认图 6、7、10 的坐标，图 26、27 的矩阵数字，图 39 的表格没有被压缩到不可读

## 发布前检查

- [ ] 标题、署名、日期、文章来源和阅读原文链接正确
- [ ] 摘要不超过公众号后台限制
- [ ] 39 张图片全部显示，顺序为 01～39
- [ ] COS 图片可匿名读取，JPG/PNG 的 `Content-Type` 正确
- [ ] 高密度图可点击查看原图，移动端没有横向滚动
- [ ] “体系结构视角”标题在 WeMD 主题中层级清楚
- [ ] 频率、线程数、容量、延迟、吞吐和单位未被编辑器改写
- [ ] 原创声明关闭，AI 内容标识按后台要求开启
- [ ] 文末支持链接和参考资料可点击
