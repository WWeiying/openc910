# CPU Clock Ramp Addendum WeChat Publish Kit

## 正式标题

CPU 从空闲到高频要多久：Alder Lake、Zen 4、M1 与更多平台补测

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Addendum: Clock Ramp on ADL, Zen 4, M1, and More
- 日期：2022-10-26
- 阅读原文：https://chipsandcheese.com/p/addendum-clock-ramp-on-adl-zen-4-m1-and-more
- 栏目：处理器微架构 / DVFS

## 摘要

Speed Shift 让现代 Intel 通常约 5 ms 到最高频率，Rembrandt 不到 1 ms 开始升频，Zen 4 以较高 idle 频率在约 11 ms 到 5.7 GHz；M1 则用更渐进且波动更大的策略。升频轨迹是 OS、硬件控制器、电压和采样方法共同作用的结果。

## 封面文案

CPU 醒来后，几毫秒能跑到高频？

## 分享文案

从 Broadwell 到 Alder Lake、Zen 4 和 M1，对照不同 CPU 的 idle-to-boost 轨迹，并解释为什么静态电压、Speed Shift 与 governor 会让数字完全不同。

## 备选标题

- Alder Lake 5 ms、Zen 4 11 ms、M1 100 ms：升频数字该怎么读
- CPU 升频速度实测：硬件控制为什么改变响应性

## 标签

DVFS、Intel Speed Shift、Alder Lake、Zen 4、Rembrandt、Apple M1、CPU 频率

## 图片说明

- 共 14 张曲线，保持原顺序和图例。
- 图 1 适合封面，但必须保留“非典型条件”提醒。
- 单平台图不可裁掉时间轴和电源模式图例。

## 移动端排版与后台设置

- 摘要填入后台，首屏保留来源和链接。
- 数字密集段落保持短段，图后先给结论再讲边界。
- 开启原文链接和图片查看原图。

## 发布前检查

- [ ] 14 张图可访问且顺序正确
- [ ] 未把 AVX-512 降频与 idle boost 混为同一测试
- [ ] 不把图 1 用作简单速度排名
- [ ] 各平台 OS/电源计划与测试贡献者条件保留
- [ ] 等效频率与真实 PLL 频率的边界保留
