# AMD Zen 4 下篇微信公众号发布资料

## 正式发布信息

- 正式标题：AMD Zen 4 下篇：Load/Store、Cache、TLB 与 DDR5
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2022 年 11 月 8 日
- 英文标题：AMD’s Zen 4, Part 2: Memory Subsystem and Conclusion
- 文章链接：https://chipsandcheese.com/p/amds-zen-4-part-2-memory-subsystem-and-conclusion
- 阅读原文链接：https://chipsandcheese.com/p/amds-zen-4-part-2-memory-subsystem-and-conclusion

### 摘要

Zen 4 用双层 Load 跟踪、1 MB L2、3K L2 TLB、更深 L2 miss 队列与 DDR5 提高执行资源利用率，同时留下跨页 Store 与带宽效率等慢路。

### 封面文案

主标题：AMD Zen 4 下篇

副标题：Load/Store、Cache、TLB 与 DDR5

### 分享文案

88 项 Load Execution Queue 与 136 项 Validation Queue是什么关系？为什么精确 Store Forwarding 只要 1 周期，跨页却要 43～44 周期？从 17 张图读懂 Zen 4 的 Cache、TLB、内存级并行和 DDR5。

### 备选标题

- Zen 4 存储系统全解：从 Store Forwarding 到 DDR5
- 从 1 周期到 44 周期：拆开 Zen 4 的 Load/Store 慢路
- AMD Zen 4 下篇：1 MB L2、3K TLB 与 72.85 GB/s DDR5

### 文章标签

- AMD Zen 4
- Ryzen 9 7950X
- Load Store Unit
- Cache
- TLB
- DDR5
- CPU 微架构

### 所属栏目

CPU 微架构

## 文首来源信息

正文保留以下信息：

> **文章来源**
>
> - 文章：*AMD’s Zen 4, Part 2: Memory Subsystem and Conclusion*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 11 月 8 日
> - 链接：https://chipsandcheese.com/p/amds-zen-4-part-2-memory-subsystem-and-conclusion

## 图片资料

- 正文图片：17 张
- 文件目录：`amd_zen4_part2_figures/`
- 文件顺序：`01` 至 `17`
- 图片格式：PNG、JPG
- 图 2、3、5、10、14、16、17 带英文正式图注；其他中文图注用于辅助读图
- 图 2 为 Store Forwarding 矩阵，图 3、5、15 为密集表格，移动端保留点击查看原图
- WeMD 副本由脚本上传腾讯云 COS，并改写为 HTTPS 图片地址

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 背景：AMD 深红、Cache 层次的灰黑渐变
- 主体：Load/Store 双队列、L1/L2/TLB 与双 CCD-IOD 链路
- 主标题：AMD Zen 4 下篇
- 副标题：Load/Store、Cache、TLB 与 DDR5

## 移动端排版

- 正文字号：15～16 px；行距：1.7～1.8
- 小标题：18～20 px；“体系结构视角”保持明显层级
- 图片说明：12～13 px，灰色
- AGU、RFO、MAB、FCLK、UCLK、Page Walk 等保留英文缩写
- 图 2、3、5、15 用 100% 宽度，不与其他图拼接

## 后台设置

- 标题：AMD Zen 4 下篇：Load/Store、Cache、TLB 与 DDR5
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分制作
- 阅读原文：https://chipsandcheese.com/p/amds-zen-4-part-2-memory-subsystem-and-conclusion
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～17

## 来源与表述要求

- AMD 的 88 项 Load Execution Queue 与 136 项 Load Validation Queue 是不同生命周期结构，不相加成 224 项单一 Load Queue。
- 64 项 Store Queue 未较 Zen 3 扩容；512-bit Store 占两项，这是 AVX-512 写密集代码的重要边界。
- Store Forwarding 精确匹配、Contained、部分重叠和跨页分别是不同路径；等待退休属于根据延迟作出的推测。
- 跨页 Store 33～34 周期是测试结果，不能写成 Zen 4 所有未对齐 Store 都如此。
- 图 1 的 6 是 Table Walker 数量，Page Directory Cache 标为不少于约 64 项；L2 是 1 MB、16-way。
- 2 MB 页用于分离 Cache 与 TLB 影响，不代表多数应用默认使用大页。
- 4 KB 页下 72 项 L1 DTLB 覆盖 288 KB，3072 项 L2 TLB 覆盖 12 MB；L2 hit 增加约 7～8 周期。
- Page Walk 最多增加四级访问，但 Page Directory Cache 会减少实际下层请求，不能固定写成四次 DRAM。
- DDR5-6000、DDR4-3600、DDR4-3333 和 DDR5-4800 没有统一时序，DRAM 延迟不能横向排名。
- 单核 L2 miss 约 70.45 项来自 Little’s Law 估算，4 KB 页和预取会污染口径，不写成官方队列深度。
- Zen 4 L3 是 Victim Cache，不直接预取；L2 是最后可根据 L1 miss 流向更低层发预取的 Cache。
- 图 10 的 Tiger Lake/Golden Cove AVX-512 为第三方不同平台补测，正文已标来源。
- DDR5 理论 96 GB/s、实测 72.85 GB/s；36.86 GB/s Store 需结合 RFO 乘二理解，不能当作总线总事务量。
- 双 CCD 写方向约 64 GB/s 只是按 16 B/cycle 与 2 GHz FCLK 的链路假说，不能据此确认所有瓶颈位置。
- “AMD 为频率放弃调度器/Store Queue 扩容”是文章的工程推断，不是 AMD 官方说明。
- 13% IPC 在上下文中更接近 performance per clock；AVX-512 可用更少指令完成工作，IPC 下降不等于性能下降。

## 发布预览要点

- 标题、署名、日期与完整原始链接一致。
- 17 张图片编号连续，母稿与 WeMD 图片数一致。
- `88/136/64`、`6～7/19/43～44`、`4/14 cycle`、`72/3072`、`288 KB/12 MB`、`27/24 B/cycle`、`70.45`、`72.85/96 GB/s` 等数字显示正常。
- 图 2、3、5 在手机上可放大，矩阵和表格未裁切。
- 腾讯云 COS URL 返回 HTTPS 200，Content-Type 与 PNG/JPEG 一致。
- 手机预览没有图片错位、标题重复或英文链接断行。
