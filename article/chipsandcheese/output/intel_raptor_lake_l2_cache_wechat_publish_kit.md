# Raptor Lake L2 Cache WeChat Publish Kit

## 正式标题

Raptor Lake 的 L2 缓存预览：容量翻倍之外，更重要的是减少片上搬运

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：A Preview of Raptor Lake’s Improved L2 Caches
- 日期：2022-08-23
- 阅读原文：https://chipsandcheese.com/p/a-preview-of-raptor-lakes-improved-l2-caches
- 栏目：处理器微架构 / Cache

## 摘要

Raptor Lake 把 P-Core L2 增至 2 MB，把四核 E-Core 集群 L2 增至 4 MB。工程样品显示，容量提升几乎没有牺牲每周期带宽；模拟中的 IPC 增益虽不足 1%，L2 miss 却下降约 15%—16%，说明更大的价值在于减少 ring 流量和数据搬运功耗。

## 封面文案

Raptor Lake 扩大 L2，为什么不只为 IPC？

## 分享文案

P-Core 多 1 个周期换来 2 MB L2，E-Core 在 20 周期下把容量翻倍。结合工程样品曲线与 ChampSim，拆解缓存扩容对延迟、互连和功耗的真实意义。

## 备选标题

- Raptor Lake 扩大 L2：P-Core 2 MB，E-Core 集群 4 MB
- IPC 提升不到 1%，Raptor Lake 的大 L2 为什么仍然重要

## 标签

Intel、Raptor Lake、Golden Cove、Gracemont、L2 Cache、Ring Bus、CPU 微架构

## 图片说明

- 共 6 张正文图，保持英文页面顺序。
- 建议封面使用图 2；图 1 和图 4 是容量/延迟核心证据。
- 图片上传后保持原比例，曲线图允许点击查看原图。

## 移动端排版与后台设置

- 摘要填入公众号摘要栏；正文首屏保留出处和原始链接。
- 图前后各留一空行，段落不超过约 5 行。
- 开启原文链接；作者可按账号实际署名调整。

## 发布前检查

- [ ] 6 张图片均可显示且顺序正确
- [ ] 工程样品与正式规格边界保留
- [ ] L3、ring 频率未定型的限制保留
- [ ] ChampSim 的 1% IPC 与 14.55%/16.05% miss 数据无误
- [ ] 原始链接、摘要、封面和标签已填写
