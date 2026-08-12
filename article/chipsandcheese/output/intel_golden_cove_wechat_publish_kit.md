# Intel Golden Cove 微信公众号发布资料

## 正式发布信息

- 正式标题：拆开 Golden Cove：Intel 如何造出一颗又宽又深的 P-Core
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2021 年 12 月 2 日
- 英文标题：Popping the Hood on Golden Cove
- 文章链接：https://chipsandcheese.com/p/popping-the-hood-on-golden-cove
- 阅读原文链接：https://chipsandcheese.com/p/popping-the-hood-on-golden-cove

### 摘要

Golden Cove 以六宽前端、约 512 项可见 ROB、五条 ALU、五条 AGU 和极高私有 Cache 带宽重夺单线程领先；33 张图解析它的优势、资源失衡与高延迟代价。

### 封面文案

主标题：拆开 Golden Cove

副标题：一颗又宽又深的 P-Core

### 分享文案

约 12K 末级 BTB、4K 微操作 Cache、六宽重命名、512 项 ROB、五条整数 ALU、三 Load 加两 Store AGU：Golden Cove 为什么能重夺单线程领先，又为何仍会被整数寄存器与 Cache 延迟限制？

### 备选标题

- Golden Cove 微架构全解：512 项 ROB 背后的强项与短板
- 从分支预测到 Little’s Law：拆解 Intel Golden Cove
- Golden Cove：Intel 重夺单线程领先的宽深核心

### 文章标签

- Intel Golden Cove
- Alder Lake
- P-Core
- CPU 微架构
- 分支预测
- 乱序执行
- Cache 与内存

### 所属栏目

CPU 微架构

## 文首来源信息

正文保留以下信息：

> **文章来源**
>
> - 文章：*Popping the Hood on Golden Cove*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2021 年 12 月 2 日
> - 链接：https://chipsandcheese.com/p/popping-the-hood-on-golden-cove

## 图片资料

- 正文图片：33 张
- 文件目录：`intel_golden_cove_figures/`
- 文件顺序：`01` 至 `33`
- 图片格式：PNG、JPG
- 图片来源：英文网页中的正文图表，按出现顺序提取
- 图 1、4、8、10、15、27、28、30、31、32 带英文正式图注；其余中文图注用于辅助读图
- 图 3～10 为三维方向预测曲面，图 17、19、33 为数字密集表格，移动端保留点击查看原图
- WeMD 副本由脚本上传腾讯云 COS，并改写为 HTTPS 图片地址

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：Intel 深蓝、金色执行管线与冷灰色 Cache
- 主体：六宽入口、512 项 ROB、五 ALU/五 AGU 的抽象框图
- 主标题：拆开 Golden Cove
- 副标题：一颗又宽又深的 P-Core
- 避免直接使用图 17、19、33 等小字号表格作为封面

## 移动端排版

- 正文字号：15～16 px；行距：1.7～1.8
- 小标题：18～20 px；“体系结构视角”保持明显层级
- 图片说明：12～13 px，灰色
- ROB、BTB、RAS、AGU、FMA、MXCSR、Superqueue、Little’s Law 等保留英文缩写或等宽样式
- 图 3～10、17、19、33 使用 100% 宽度，避免压缩后数字不可辨识

## 后台设置

- 标题：拆开 Golden Cove：Intel 如何造出一颗又宽又深的 P-Core
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分制作
- 阅读原文：https://chipsandcheese.com/p/popping-the-hood-on-golden-cove
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～33

## 来源与表述要求

- 512 项 ROB、280/332 项整数与 FP/向量寄存器、192/114 项 Load/Store Queue、205 项调度容量等来自微基准复原，不写成 Intel RTL 参数。
- Sunny Cove 来自 Azure VM 中的 Xeon 8370C；Golden Cove 来自 i9-12900K，不是统一裸机平台。
- 方向预测曲面拐点同时受历史、表容量、散列与 aliasing 影响，不反推确定 GHR 位数或预测算法。
- BTB 的约 128/4608/12288 分支平台是测试行为；三级组织与每级约 1 周期是基于台阶的判断，不补写组相联和标签位宽。
- Golden Cove Return 曲线没有确定容量断崖，不写成已知 RAS 项数。
- 4K 微操作 Cache 没有在八字节 NOP 中显示全部有效容量，不等于物理容量只有约 1K。
- 280 项整数寄存器包含推定的测量偏差修正；正文重点是可见容量没有随 512 项 ROB 同比增长。
- Zen 3 约 64 项 Superqueue 是基于 Zen 2 事件的猜测，保留问号。
- 五条整数 ALU 至少要求十个源读取是逻辑需求推导，不能写成十个独立物理 SRAM 读口已确认。
- AVX-512 不是 Alder Lake 官方支持功能；相关测试来自关闭 E-Core 且主板允许的特定早期平台。
- DDR5-6200 的 96.6 GB/s 与主体 DDR4 图不是同一配置，不能直接并列成单变量对照。
- Cache 周期按 5.2/5.05 GHz 假设换算；内存配置没有匹配，图 31 的 DRAM 延迟不能横向排名。
- Little’s Law 表是假设其他结构不先满、存在足够独立指令的上界模型，不把 512 项 ROB 写成必然隐藏 74 周期 L3。
- 关于 Sapphire Rapids 取舍和整数寄存器端口成本属于文章推测，不写成 Intel 设计团队说明。
- 文章发表于 2021 年 12 月，对 Zen 4 的段落是当时的前瞻判断。

## 发布预览要点

- 标题、署名、日期与原始链接一致。
- 33 张图片编号连续，母稿与 WeMD 图片数一致。
- `6144`、`48/64/96`、`128/4608/12288`、`4K/2.25K/1.5K`、`512/352/256`、`280/332`、`192/114`、`16/48`、`96.6 GB/s` 等数字显示正常。
- 图 17、19、33 在手机上可放大，表格没有被裁切。
- `L = λ × W` 使用 Unicode 符号显示正常，没有被主题转义。
- 腾讯云 COS URL 返回 HTTPS 200，Content-Type 与 PNG/JPEG 一致。
- 手机预览没有横向滚动、图片错位、英文链接断行或重复标题。
