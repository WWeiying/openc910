# Crestmont Comparison WeChat Publish Kit

## 正式标题

同是 Crestmont，有没有 L3 能差多少：Meteor Lake 两类 E-Core 对比

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Comparing Crestmonts: No L3 Hurts
- 日期：2024-05-21
- 阅读原文：https://chipsandcheese.com/p/comparing-crestmonts-no-l3-hurts
- 栏目：处理器微架构 / Cache 与 Top-Down

## 摘要

同为 Crestmont，标准 E-Core 有 24 MB L3，LPE-Core 只有 2 MB L2。libx264 和 kernel compile 中，标准核心 IPC 分别高 30% 以上与 28.5%；7-Zip 因 L2 已拦住大部分访问，差距缩至 10.2%。Top-Down 揭示数据与指令两侧如何被 DRAM 延迟拖住。

## 封面文案

没有 L3，同一颗 E-Core 会慢多少？

## 分享文案

0.1% 的 DRAM load 就能制造 26% stall。用 Top-Down 拆解 Meteor Lake 标准 E-Core 与 LPE-Core，看看 Cache 如何同时保护前端和后端。

## 备选标题

- Meteor Lake LPE-Core：被 DRAM 延迟限制的 Crestmont
- 从 1.55 到 1.17 IPC：一层 L3 的体系结构价值

## 标签

Intel、Meteor Lake、Crestmont、LPE-Core、L3 Cache、Top-Down、LPDDR5

## 图片说明

- 共 20 张图，按页面顺序完整保留。
- 图 2—5、6—11、12—18 分别对应三项负载。
- 图 19 的图像来源需保留。

## 移动端排版与后台设置

- 后台作者填 Chester Lam，摘要填后台。
- 开启阅读原文和查看原图。
- Top-Down 图例和百分比坐标不可裁切。

## 发布前检查

- [ ] 20 张图完整、顺序正确
- [ ] 0.1%、26%、44%、1.17/1.55 IPC 数据准确
- [ ] 前端指令 miss 与后端数据 miss 未混写
- [ ] 7-Zip 作为反例和 35% L3 hitrate 保留
- [ ] 浏览器/Discord 只作为特定环境观察
