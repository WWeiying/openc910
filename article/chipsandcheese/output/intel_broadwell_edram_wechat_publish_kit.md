# Broadwell eDRAM WeChat Publish Kit

## 正式标题

Broadwell 的 128 MB eDRAM：在 3D V-Cache 之前，Intel 怎样做大容量缓存

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Broadwell’s eDRAM: VCache before VCache was Cool
- 日期：2024-11-01
- 阅读原文：https://chipsandcheese.com/p/broadwells-edram-vcache-before-vcache
- 栏目：处理器微架构 / Cache 与先进封装

## 摘要

Broadwell 用独立 77 mm²、22 nm Crystal Well die 实现 128 MB L4：128 个 bank、独立读写 OPIO 与并行 L3/L4 tag 检查，让它达到约 36.6 ns、50 GB/s。它减少 DRAM 流量，却受高延迟、单接口带宽和成本限制，成为 3D V-Cache 之前一次重要的大缓存实验。

## 封面文案

128 MB L4：Intel 比 V-Cache 早了近七年

## 分享文案

从 eDRAM bitcell、128-bank、OPIO 到 victim cache 和 SPEC 实测，完整回看 Broadwell Crystal Well：它为什么惊艳，又为什么没能延续。

## 备选标题

- Crystal Well：Broadwell 如何把 128 MB eDRAM 变成 L4
- V-Cache 之前，Intel 的 Broadwell 已经做过大容量 Cache Die

## 标签

Intel、Broadwell、Crystal Well、eDRAM、L4 Cache、OPIO、3D V-Cache、Chiplet

## 图片说明

- 共 29 张图，按网页顺序完整保留。
- 图 2、5、8、9 讲实现，图 10—15 讲实测，图 23—26 讲 Skylake 改版。
- 建议封面使用图 2 或图 29；论文图须保留来源说明。

## 移动端排版与后台设置

- 文章较长，保留 Crystal Well、L4 实现、实测、Skylake、历史位置五个主章节。
- 摘要填后台，开启原文链接与查看原图。
- 参数密集图避免裁切坐标、单位和图例。

## 发布前检查

- [ ] 29 张图片均可访问且顺序正确
- [ ] 77 mm²、22 nm、128 MB、128 bank、36.6 ns、50 GB/s 数据无误
- [ ] CBo/ARB 命中率明确为估算，未知请求来源未被抹去
- [ ] Broadwell/Haswell 内存配置差异保留
- [ ] SPEC 和 libx264 的边界未混写
- [ ] Broadwell 与 Skylake 两代 eDRAM tag 路径区分清楚
