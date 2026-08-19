# Gigabyte Leak Zen 4 WeChat Publish Kit

## 正式标题

Gigabyte 泄露材料里的 Zen 4：从 Cache、AVX-512 到 Genoa I/O

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Details on the Gigabyte Leak
- 日期：2021-08-22
- 阅读原文：https://chipsandcheese.com/p/details-on-the-gigabyte-leak
- 栏目：处理器微架构 / Zen 4 与平台 I/O

## 摘要

2021 年泄露文件显示，Zen 4 延续四组整数调度器与两级 BTB，L2 翻倍、L2 DTLB 增至 3072 项，并加入广泛 AVX-512；Genoa 又为 SCM/扩展内存、双 I/O Hub 与 page migration 做准备。文件事实和 FMA/SDP 等推测必须严格分开。

## 封面文案

Zen 4 发布前：Cache、AVX-512 与 Genoa I/O 的早期线索

## 分享文案

从 1 MB L2、3072 项 DTLB、64 B uop，到 SCM、MPIO、MPDMA 和 AM5 BIOS update，回看一份 2021 年材料如何勾勒 Zen 4 平台。

## 备选标题

- 2021 年的 Zen 4 线索：哪些是文档事实，哪些只是推演
- 从核心到 I/O：Gigabyte 泄露材料中的 Genoa 与 AM5

## 标签

AMD、Zen 4、Genoa、AM5、AVX-512、DTLB、SCM、Infinity Fabric

## 图片说明

- 共 12 张图，按页面顺序完整保留。
- 图 1—3 为核心/cache，4—10 为 Genoa memory/I/O，11—12 为 AM5。
- 所有图片应保留“发布前泄露材料”语境。

## 移动端排版与后台设置

- 后台作者填 Chester Lam；摘要填后台。
- 开启阅读原文和查看原图。
- 不在标题或封面渲染勒索团伙，不提供泄露文件下载入口。

## 发布前检查

- [ ] 12 张图完整且顺序正确
- [ ] 3072 项=12 MB、48 MB 需四页合并假设
- [ ] AVX-512 单 uop 与物理 512-bit FMA 未混同
- [ ] 双 SDP、narrow mode、peer memory 等保留推测
- [ ] 2021 年发布前文件的版本边界保留
