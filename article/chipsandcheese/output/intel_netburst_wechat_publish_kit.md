# Intel NetBurst WeChat Publish Kit

## 正式标题

Intel NetBurst：一次失败，怎样成为 Sandy Bridge 的技术地基

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Intel’s Netburst: Failure is a Foundation for Success
- 日期：2022-06-17
- 阅读原文：https://chipsandcheese.com/p/intels-netburst-failure-is-a-foundation-for-success
- 栏目：处理器微架构 / Intel 历史核心

## 摘要

NetBurst 用 trace cache、PRF、分布式 scheduler、replay 与极长流水线追逐频率。小分支 footprint 和 trace 命中极快，BTB miss、跨线转发和写穿 L1D 却代价惊人。它失败了，但 PRF、SMT 和 uop caching 经验后来成为 Sandy Bridge 的技术地基。

## 封面文案

NetBurst：失败如何变成 Sandy Bridge 的地基

## 分享文案

从 12K trace cache、36 周期 BTB miss、165 周期 forwarding 慢路径，到 PRF 与 Hyper-Threading，重看 Pentium 4 为何失败，又留下了哪些现代核心仍在使用的思想。

## 备选标题

- Pentium 4 的 NetBurst：快速路径有多快，悬崖就有多深
- 从 NetBurst 到 Sandy Bridge：Intel 如何把失败经验重新组合

## 标签

Intel、NetBurst、Pentium 4、Trace Cache、PRF、Hyper-Threading、Sandy Bridge

## 图片说明

- 共 32 张图，按英文页面顺序完整保留。
- 图 3—11 为前端，图 14—18 为乱序/LSU，图 19—27 为缓存，图 30 为技术继承。
- 裸片标注均带推测，不得当成官方模块边界。

## 移动端排版与后台设置

- 保留前端、后端、LSU、缓存、历史影响五个导航。
- 摘要填后台，开启原始链接和查看原图。
- 慢路径数字可突出，但不做脱离条件的猎奇标题。

## 发布前检查

- [ ] 32 张图全部可访问且顺序正确
- [ ] 16/24 history、1024/2048、4096 BTB 等均保留证据强度
- [ ] 36/50/89/125/165 周期对应场景未混淆
- [ ] PRF 导致不 squash 的关系写为推测而非确认因果
- [ ] 主平台、Athlon 与 Northwood 配置完整保留
