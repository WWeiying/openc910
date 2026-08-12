# Qualcomm Centriq 2400 / Falkor 微信公众号发布资料

## 正式标题

Qualcomm Centriq 2400 与 Falkor：48 核 Arm 服务器往事

## 备选标题

- Qualcomm Falkor：一颗为云计算而生的 48 核 Arm 服务器芯片
- Centriq 2400：Qualcomm 第一次服务器 CPU 尝试
- Falkor 微架构：核心做瘦，存储系统做强

正式标题以英文题目 *Qualcomm’s Centriq 2400 and the Falkor Architecture* 为基础，保留处理器与核心名称，并用“48 核 Arm 服务器往事”交代文章的历史回看属性。标题不使用“失败”“吊打”或“领先时代”，避免用事后市场结果替代技术分析。

## 作者栏

Chester Lam

## 文章来源

- 首发：Chips and Cheese
- 发布：2025 年 5 月 29 日
- 英文题目：*Qualcomm’s Centriq 2400 and the Falkor Architecture*
- 阅读原文：https://chipsandcheese.com/p/qualcomms-centriq-2400-and-the-falkor

## 摘要

2017 年的 Centriq 2400 以 48 颗 Falkor、120 W、60 MB L3 和六通道内存挑战云服务器市场。本文沿 37 张资料与测试图观察它如何缩减核心峰值吞吐、强化存储系统，并分析这次 Arm 服务器尝试留下的技术价值与局限。

## 分享卡片文案

四宽译码为何只有“3＋1”重命名？Write-through L1D 如何借侧边结构获得写回式收益？24 个双核 Duplex、四条分段环与 60 MB L3 又怎样连接成 48 核服务器？沿 37 张图回看 Qualcomm Centriq 2400 与 Falkor。

## 封面文案

- 主标题：Qualcomm Centriq 2400
- 副标题：Falkor 与 48 核 Arm 服务器往事
- 小字：Frontend / OoO / L1D / TLB / Ring / L3 / DRAM

## 封面规格

- 推荐比例：2.35:1
- 工作尺寸：900 × 383 px
- 色调：Qualcomm 蓝、深蓝黑与少量青色
- 主体：Centriq 芯片轮廓，内部抽象表示 24 个双核 Duplex、四条 Ring 和上下分布的 L3/DDR
- 辅助元素：Falkor 核心、60 MB L3、六通道 DDR 的简化标识
- 安全区：标题、芯片轮廓置于中央 70%，避免分享卡片裁切

封面不堆放 128/70＋、87/37、512/64/64 等细节参数，正文图 3、17、24、26 负责完整展示。

## 推荐标签

- Qualcomm
- Centriq 2400
- Falkor
- Arm 服务器
- CPU 微架构
- 云计算
- 乱序执行
- Cache
- 片上互连

## 推荐栏目

处理器体系结构

## 开头推荐语

在 Oryon 之前，Qualcomm 曾经认真进入过服务器 CPU 市场。Centriq 2400 用 48 颗 Falkor、120 W TDP、60 MB L3 和六通道 DDR4 瞄准云计算。它没有一味加宽核心，而是把资源转向指令缓存、内存并行、L2/L3 和一致性互连。这篇文章从前端一直看到全片环网，重新审视这条没有延续下去的技术路线。

## 文章结构

1. 产品背景：云计算、核心密度和每线程性能底线
2. 核心总览：四宽 AArch64、48 核/120 W 与 SKU
3. 前端：24 KB L0I、64 KB L1I、耦合 BTB、BTIC、方向与间接预测
4. 重命名与乱序执行：3＋1 宽、分离的完成/提交/退休资源和执行端口
5. Load/Store：双 Tag L1D、WCC、Store Forwarding 与奇偶校验
6. 地址翻译：final/non-final/Stage-2 TLB 与虚拟化
7. Duplex 与 L2：双核共享、Bank、QSB 和线程放置
8. 片上系统：四环、12 个 L3 Slice、分布式一致性和六通道 DDR
9. 性能：SPEC CPU2017、IPC、7-Zip 和 libx264
10. 总结：核心做瘦、存储系统做强，以及服务器路线连续性

正文显式保留十个“体系结构视角”小节，并在结尾总结七点认识。机制分析使用通用术语，不把 checkpoint、WCC 内部状态、Ring 队列或 Page Walker 信号写成 Falkor 已确认 RTL。

## 图片清单

1. 2017 年 Centriq 2400 发布资料
2. 云计算对处理器架构的目标
3. Falkor 微架构总览
4. Centriq 与 Xeon SKU 对照
5. Falkor、Kryo、Skylake 前端缓存
6. NOP 工作集下的指令供给
7. 不同分支间距下的 Taken 延迟
8. Falkor 与 Kryo 的目标延迟
9. Falkor 方向预测曲面
10. Kryo 方向预测曲面
11. Falkor 间接分支预测
12. Falkor、Kryo、A72 返回栈
13. Qualcomm 重命名/寄存器访问幻灯片
14. Load＋依赖分支测得的未提交窗口
15. Falkor、Kryo、A72 后端资源
16. FP/向量延迟和吞吐
17. Qualcomm Load/Store 幻灯片
18. WCC 容量和写回吞吐
19. Store-to-Load Forwarding 矩阵
20. 嵌套虚拟化 TLB 结构
21. Qualcomm Duplex L2 幻灯片
22. Falkor 与 Graviton 1 Cache 延迟
23. 单核只读带宽
24. Qualcomm 片上互连幻灯片
25. Falkor、Skylake、A72 系统接口
26. 分布式 L3 和六通道 DDR
27. 服务器 L3 容量、拓扑和延迟
28. 带宽压力下的 L3 延迟
29. Centriq 2452 核间延迟矩阵
30. 分布式一致性点与 Snoop Filter
31. 2×1 GB 受载 DRAM 延迟
32. SPEC CPU2017 单线程估算总分
33. SPEC CPU2017 子项
34. SPEC CPU2017 IPC
35. 四核 7-Zip 与 libx264
36. Snapdragon 821 Kryo 内存功耗
37. Centriq/Falkor/Firetail/Saphira 路线图

37 张图按网页顺序保留。网页真正提供正式 `figcaption` 的只有图 1、4、13；其他图片中的 Qualcomm 幻灯片身份可由画面和上下文确认，但中文图注仍属于辅助读图，不冒充网页正式 caption。图 3、7、9～11、13、17、19、24、26、29、30、33、34 信息密度较高，发布时应保留完整坐标、问号、图例和数据标签，并允许点击查看原图。

## 移动端排版

- 正文字号：15～16 px
- 正文行距：1.7～1.8
- 二级标题：18～20 px，加粗
- 三级标题：16～17 px，加粗
- 图注：12～13 px，灰色
- 段间距：10～14 px
- `BTB`、`BTIC`、`RAS`、`AGU`、`LSQ`、`TLB`、`WCC`、`QSB`、`IPC`、`MPKI` 保留半角缩写
- 容量与性能单位统一为 `KB`、`MB`、`GHz`、`cycle`、`ns`、`B/cycle`、`GB/s`

正文不使用 Markdown 数据表，避免移动端横向滚动。图 19、29 是高密度矩阵，图 9～11 是三维曲面，图 33、34 柱状数据较密，应检查微信压缩后的可读性。

## 后台设置

- 标题：Qualcomm Centriq 2400 与 Falkor：48 核 Arm 服务器往事
- 作者栏：Chester Lam
- 摘要：使用本文件“摘要”部分
- 封面：使用“封面文案”和“封面规格”部分
- 阅读原文：https://chipsandcheese.com/p/qualcomms-centriq-2400-and-the-falkor
- 原创声明：关闭
- AI 内容标识：开启公众号后台提供的相应标识
- 图片上传顺序：01～37

## 来源与表述边界

- 被测设备是 Corellium 免费提供、由 Neggles 搭建的 Centriq 2452 参考平台，配 96 GB DDR4-2666；设备来源和配置均应保留。
- Centriq 2452 是 46 核、57.5 MB L3；48 核和 60 MB 描述的是 Centriq 2460/系列满配上限，不能混成同一 SKU。
- 120 W 是 TDP；48 核平均正好为 2.5 W/core，只有结合 Qualcomm 所说典型全核功耗低于 120 W，才可表述为典型低于 2.5 W/core。
- 图 3 把二级间接目标阵列画成 256 项，正文写 512 项；差异必须并列保留。
- Qualcomm 图 17 宣称每周期 128-bit Load＋128-bit Store，微基准只看到合计不超过 128 bit/cycle；不能静默采用其中一种。
- 128 条未提交、70＋条已提交待退休、256 项 Rename/Completion Buffer 是不同口径；Falkor 不应被简化成“256 项 ROB”。
- WCC 是 Chips and Cheese 为未命名侧边结构借用的称呼，不是 Qualcomm 正式模块名；约 3 KB 容量来自微基准反推。
- L2 官方最低 15 cycle，指针追踪约 16～17 cycle；两者并不矛盾，但不能只保留一个精确数。
- 图 29 核间矩阵没有单位和同步协议，不能擅自写成 ns 或 Cache Line ping-pong。
- 图 28 的 Ryzen 9 7950X3D、图 32 的后续 Arm/Intel 核心来自不同年代，仅用于数量级和演进对照。
- 图 36 是 Snapdragon 821 Kryo 的 USB-C 端口功耗变化，不是 Falkor 或 Centriq 功耗。
- SPEC CPU2017 是单线程估算结果，本页没有完整给出编译器、参数和输入；IPC 又跨 ISA，不能单独当作完成同一任务的性能。
- 2025 年 HUMAIN 与 NVLink Fusion 是文章写作时的公开动向，不证明下一代 Qualcomm 服务器 CPU 复用 Falkor 电路。
- 材料不含 RTL。“体系结构视角”的恢复、别名处理、WCC、Walker、Ring 队列和仲裁分析均为通用机制教学。

## 发布预览要点

- 标题、署名、发布日期、首发平台与阅读原文链接一致。
- 母稿与 WeMD 副本均有 37 张图，图号 1～37 连续。
- WeMD frontmatter 使用主题 `custom-1786280678341-jnfpaqasm` 和主题名“学术论文 (副本)”。
- `46/48 cores`、`57.5/60 MB`、`120 W`、`24＋64 KB`、`16 B/cycle`、`128/70＋/256`、`87/37`、`64/512/64/64`、`512 KB`、`40.9 ns`、`532.61 GB/s`、`121.4 ns` 等关键数字显示正确。
- 图 3 的 256/正文 512 间接目标阵列差异、图 17 的官方/实测带宽差异仍然存在。
- 图 19 的行列与重叠含义、图 29 的无单位边界没有在编辑器中丢失。
- COS 图片可匿名加载，JPG/PNG 的 `Content-Type` 正确，无强制下载。

## 发布前检查

- [ ] 标题、作者栏、日期、来源和阅读原文链接正确
- [ ] 摘要在公众号后台完整显示
- [ ] 37 张图片全部加载，顺序为 01～37
- [ ] 高密度框图、矩阵、曲面与 Benchmark 图可点击查看原图
- [ ] “体系结构视角”标题层级清晰
- [ ] 公开规格、实测、反推、内部差异和未知项未被排版改写
- [ ] 46 核被测 SKU 与 48 核系列上限没有混淆
- [ ] 公众号原创声明关闭，AI 内容标识按后台要求开启
- [ ] 参考资料与 Chips and Cheese 支持链接可点击
