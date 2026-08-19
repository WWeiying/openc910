# Meteor Lake Chiplets Hot Chips 34 WeChat Publish Kit

## 正式标题

Hot Chips 34 的 Meteor Lake：Intel 与 AMD 选择了两种不同的 Chiplet 路线

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Hot Chips 34 – Intel’s Meteor Lake Chiplets, Compared to AMD’s
- 日期：2022-09-10
- 阅读原文：https://chipsandcheese.com/p/hot-chips-34-intels-meteor-lake-chiplets-compared-to-amds
- 栏目：处理器微架构 / Chiplet 与互连

## 摘要

Meteor Lake 把 CPU、GPU、SoC、IOE 分成四 Tile，以 Foveros base die 换取移动端 I/O 密度和低链路能耗；AMD 传统 CCD/IOD 更便宜、reach 更强。IDI 与 iCXL 的协议差异还暗示 iGPU 不再共享 CPU L3，但这在 2022 年材料中仍属证据推断。

## 封面文案

同样是 Chiplet，Intel 与 AMD 为什么切得不一样

## 分享文案

从 FDI 的 `<10 ns`、IDI/iCXL 到 CPU/GPU cache hierarchy，拆解 Meteor Lake 的分解边界，以及它为何更像面向移动功耗的 chiplet，而非跨 die L3 mesh。

## 备选标题

- Meteor Lake 四 Tile：Foveros 如何服务移动端模块化
- IDI、iCXL 与 FDI：从协议看 Meteor Lake 的 Cache 边界

## 标签

Intel、Meteor Lake、Foveros、Chiplet、FDI、IDI、CXL、AMD Infinity Fabric

## 图片说明

- 共 15 张图，保持英文页面顺序。
- 图 2、5、6 是官方 slide；图 13—14 ring 为分析标注。
- 图 10 指标有解释不确定性，不能用作精确 hitrate。

## 移动端排版与后台设置

- 后台作者填 Chester Lam，摘要填后台。
- 开启阅读原文和查看原图。
- 2022 年推断保持原有时态和不确定性。

## 发布前检查

- [ ] 15 张图完整、顺序正确
- [ ] `<10 ns` 未擅自写成 2—3 ns 确认值
- [ ] 2 GT/s 因缺 transfer width 未换算带宽
- [ ] iGPU 不共享 L3 明确为当时推断
- [ ] 官方 slide、论文事实与裸片猜测已区分
