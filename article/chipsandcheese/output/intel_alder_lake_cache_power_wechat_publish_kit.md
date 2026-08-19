# Alder Lake Cache Power WeChat Publish Kit

## 正式标题

Alder Lake 的缓存与能效：数据每远离核心一级，能耗就上一个台阶

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Alder Lake’s Caching and Power Efficiency
- 日期：2022-07-07
- 阅读原文：https://chipsandcheese.com/p/alder-lakes-caching-and-power-efficiency
- 栏目：处理器微架构 / Cache 与能效

## 摘要

四核心功耗微基准显示，L2 hit 的单位数据能耗约为 L1 两倍，L3 往往又超过 L2 两倍，DRAM 通常达到 L3 的 4—5 倍。Golden Cove 私有缓存强，AMD L3 强；Gracemont 在高频桌面配置下更接近面积效率核，而非纯低功耗核。

## 封面文案

CPU 的能量，花在把数据搬多远

## 分享文案

从 Golden Cove、Gracemont 到 Zen 2/3 和三代 Atom，用封装能量计数器观察同一规律：数据每离核心远一级，完成同量传输的成本都会显著上升。

## 备选标题

- 从 L1 到 DRAM：Alder Lake 的数据搬运能耗实测
- Golden Cove 和 Gracemont，谁更擅长省下数据搬运能量

## 标签

Intel、Alder Lake、Golden Cove、Gracemont、Cache、RAPL、能效、Zen

## 图片说明

- 共 21 张图，全部按正文顺序保留。
- 图 19 适合封面；图 4 是带推测标注的裸片图，发布时不得写成官方拓扑。
- 曲线图不要裁掉容量横轴、单位和平台图例。

## 移动端排版与后台设置

- 首屏显示英文标题、来源、日期和链接。
- 长图保持原比例，可开启点击查看原图。
- 摘要填入后台，开启原文链接。

## 发布前检查

- [ ] 21 张图片均可访问、顺序正确
- [ ] 四核独立数组与容量相加条件保留
- [ ] DDR4/DDR3 配置差异保留
- [ ] AMD RAPL 可能为模型值的限制至少出现两处
- [ ] 没有将裸片图推测写成确定实现
