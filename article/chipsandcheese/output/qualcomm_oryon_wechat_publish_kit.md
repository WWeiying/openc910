# Qualcomm Oryon 微信公众号发布资料

## 正文文件

- 母稿：`qualcomm_oryon_wechat_article_zh.md`
- WeMD 发布副本：`qualcomm_oryon_wechat_article_zh_wemd.md`
- 图片目录：`qualcomm_oryon_figures/`
- WeMD 主题：`custom-1786280678341-jnfpaqasm`（学术论文（副本））

发布时把 WeMD 副本导入 WeMD。该文件由母稿自动生成，不单独修改；母稿更新后，重新运行：

```bash
prepare-wemd-cos article/chipsandcheese/output/qualcomm_oryon_wechat_article_zh.md
```

## 发布字段

- 标题：Qualcomm Oryon：一颗等待多年的自研 CPU 核心
- 署名：George Cozma、Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 7 月 10 日
- 英文标题：Qualcomm’s Oryon Core: A Long Time in the Making
- 文章链接：https://chipsandcheese.com/p/qualcomms-oryon-core-a-long-time-in-the-making
- 阅读原文：https://chipsandcheese.com/p/qualcomms-oryon-core-a-long-time-in-the-making

### 摘要

从 43 张图完整解析 Qualcomm Oryon 的三簇系统、八宽前端、约 680 项 ROB、超大调度器、TLB 与内存层次，并解释原生性能之外的功耗、互连和 Windows on Arm 生态边界。

### 封面文案

主标题：Qualcomm Oryon

副标题：一颗等待多年的自研 CPU 核心

### 分享文案

从 Nuvia 到 Oryon，Qualcomm 用三组四核簇、八宽前端、约 680 项 ROB 和巨大的调度器重返自研高性能 CPU。43 张图看清它的分支预测、TLB、Cache 与内存优势，也看清跨簇延迟、功耗策略和 Windows on Arm 生态仍要解决的问题。

### 备选标题

- 从 Nuvia 到 Oryon：Qualcomm 自研 CPU 的漫长回归
- Qualcomm Oryon 做成了什么：八宽核心、大窗口与三簇系统
- 等待多年之后，Qualcomm Oryon 站上了怎样的起点

### 文章标签

- Qualcomm Oryon
- Snapdragon X Elite
- Nuvia
- CPU 微架构
- 分支预测
- 乱序执行
- Cache 与内存
- Windows on Arm

### 所属栏目

CPU 微架构

## 文首来源信息

正文开头保留：

> **文章来源**
>
> - 文章：*Qualcomm’s Oryon Core: A Long Time in the Making*
> - 撰文：George Cozma、Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 7 月 10 日
> - 链接：https://chipsandcheese.com/p/qualcomms-oryon-core-a-long-time-in-the-making

## 图片资料

- 正文图片：43 张
- 文件顺序：`01`～`43`
- 文件格式：32 张 PNG、11 张 JPG，扩展名与真实 MIME 一致
- 图片来源：英文网页正文，按出现顺序提取；其中 Qualcomm 幻灯片、宣传渲染和 Chips and Cheese 测试图已在图解中自然区分
- 每张图后均有中文标题、读图说明、关键数据、体系结构意义或最重要的结论边界
- WeMD 副本中的 43 张图片由脚本上传腾讯云 COS，并替换为 HTTPS 地址
- 43 个 COS 对象均已检查为 HTTP 200；`Content-Type` 为 32 个 `image/png` 和 11 个 `image/jpeg`

图 4～6、8、10 是高密度核间延迟矩阵，图 14～16、20～22 是三维分支预测曲面，图 12、13、26、31、35、37 是结构或公开资料图。发布时不要裁掉坐标、图例、问号和脚注，并在手机预览中确认图片可以点击查看原图。

图 6 的正式英文图注说明 M1 数据来自 Asahi Linux；图 12～16、24、28、30、33、41～43 也保留了网页提供的正式图注信息。其余中文图解用于辅助读图，不冒充网页正式 caption。

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：Qualcomm 深紫、黑金或低饱和蓝黑
- 画面主体：Oryon CPU 轮廓、三个四核簇、八宽前端和大 ROB 的抽象层次
- 主体文字：Qualcomm Oryon
- 辅助文字：一颗等待多年的自研 CPU 核心
- 右下角小字可选：Chips and Cheese / George Cozma & Chester Lam

标题与 Oryon 标识放在中央安全区，避免分享卡片裁掉左右文字。封面不需要塞入 680 项 ROB、192 项 Load Queue 等参数，正文图 12、26、27 承担精确结构展示。

## 移动端排版

- 正文字号：15～16 px
- 正文行距：1.7～1.8
- 一级小标题：18～20 px，加粗
- 二级小标题：16～17 px，加粗
- 图片说明：12～13 px，灰色
- 段间距：10～14 px
- `ROB`、`BTB`、`RAS`、`AGU`、`TLB`、`SLC`、`MSHR`、`IPC`、`MPKI` 保留半角缩写
- 容量、延迟和吞吐单位统一保留为 `KB`、`MB`、`cycle`、`ns`、`B/cycle`、`GB/s`

正文没有 Markdown 数据表，避免公众号出现横向滚动。图 4、10、14～16、20～22、27、32、36、38、39 信息密度较高，应允许读者点击查看原图。

## 后台设置

- 标题：Qualcomm Oryon：一颗等待多年的自研 CPU 核心
- 作者栏：George Cozma、Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分
- 阅读原文：https://chipsandcheese.com/p/qualcomms-oryon-core-a-long-time-in-the-making
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～43

## 发布时保持的技术边界

- 被测设备是 Samsung Galaxy Book4 Edge 16，处理器为最高 4.0 GHz 的 X1E-80-100；不能把顶级 SKU 的双核 4.3 GHz 写成这台设备的测试频率。
- 大量微基准运行于 WSL，因为当时缺少适用于该笔记本、已进入上游的设备树；Windows、固件、电源模式和 WSL 会进入端到端结果。
- 三组四核簇和每簇 12 MB L2 属于 Snapdragon X Elite 系统结构；约 170～210 ns 跨簇延迟包含一致性、Fabric、仲裁和整机因素，不能全部归因于 Oryon 核心内部。
- 方向预测曲面、约 2048 项间接预测资源、约 48 项 RAS、目标交付与 8 KB/192 KB 指令层次的关系都来自微基准观察或反推，不是 RTL 确认。
- 约 680 项 ROB、416 项整数/FP 寄存器、192/56 项 Load/Store Queue 是微基准可见量级；Qualcomm 公开资料使用 650+、400+ 等口径，排版时不要把两者静默改成同一个精确官方参数。
- 四 AGU、192 项 Load Queue、每核 50+ 系统请求和 L2 的 220+ 事务分别描述地址生成吞吐、排序容量与不同层级的在途请求，不能混成单一“内存并行度”。
- 224 项 L1 DTLB 与 8K+ 项 L2 TLB 分别来自微基准和 Qualcomm 资料；4 KB 页曲线在约 6 MB、128 MB 后的台阶不能由公开容量简单解释，未知项必须保留。
- Cache、DRAM 和 Cinebench 比较跨越不同 ISA、系统、频率、内存和整机。图 40 的功耗是电池放电率，图 41 的“80 W Device TDP”口径不清，不能改写成统一 CPU 能效排名。
- 材料不含 Oryon RTL。“体系结构视角”中的 checkpoint、恢复、反压、Walker 和一致性路径是通用机制分析，不是 Qualcomm 信号或模块确认。

## 发布预览要点

- 标题、署名、日期、来源和阅读原文链接与正文一致。
- 43 张图片顺序连续，母稿与 WeMD 副本图片数一致。
- WeMD frontmatter 中的主题、主题名和 title 字段正确。
- `4.0 GHz`、`113.91 ms`、`680/320/512`、`416/224/288`、`192/56`、`224`、`8K+`、`110.9 ns`、`112.31 GB/s` 等关键数字显示正常。
- 图 4、6、10 的矩阵颜色和核心编号可辨，图 14～16、20～22 的坐标与图例未裁切。
- 近似值、公开规格、实测与反推的语气没有在编辑器中被抹平。
- COS 图片可匿名加载，无破图、强制下载或 MIME 错误。
- 手机预览无横向滚动、标题孤行、图号错位或超长英文链接破版。

## 发布前检查

- [ ] 标题、署名、日期、文章来源和阅读原文链接正确
- [ ] 摘要不超过公众号后台限制
- [ ] 43 张图片全部显示，顺序为 01～43
- [ ] COS 图片可匿名读取，JPG/PNG 的 `Content-Type` 正确
- [ ] 高密度矩阵、曲面和框图可点击查看原图
- [ ] “体系结构视角”在 WeMD 主题中层级清楚
- [ ] 测试条件、频率、容量、延迟、吞吐与不确定性没有被排版改写
- [ ] 原创声明关闭，AI 内容标识按后台要求开启
- [ ] 文末参考资料与支持链接可点击
