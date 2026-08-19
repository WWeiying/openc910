# IBM Giant L3 and V-Cache WeChat Publish Kit

## 正式标题

IBM 的 256 MB L3 与 AMD V-Cache：大缓存会是未来吗？

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Do IBM’s Giant L3 and V-Cache Represent the Future?
- 日期：2021-09-29
- 阅读原文：https://chipsandcheese.com/p/do-ibms-giant-l3-and-v-cache-represent-the-future
- 栏目：缓存体系 / 性能模拟

## 摘要

用约 350 条指令轨迹模拟 32 MB、96 MB 与 256 MB L3：巨大缓存能让部分工作负载获得跨代提升，也会让原本命中率很高、延迟敏感的程序损失 IPC。IBM Telum 与 AMD V-Cache 的选择，背后是不同工作集、访问延迟和产品成本的平衡。

## 封面文案

缓存越大越好吗？350 条轨迹给出的答案

## 分享文案

256 MB Telum L3、96 MB V-Cache 和 32 MB 低延迟 L3，谁更合理？关键不在容量本身，而在 miss 降了多少、每次命中多等多久。

## 备选标题

- 从 32 MB 到 256 MB：缓存容量与延迟如何交换性能
- IBM Telum 和 AMD V-Cache，为什么都对，又都不适合所有负载

## 标签

IBM、Telum、AMD、V-Cache、L3、ChampSim、缓存体系

## 图片说明

- 共 10 张图，全部按页面顺序保留。
- 图 1—5 为轨迹模拟结果，图 6—8 为游戏映射与 AMD 资料，图 9—10 为完整模拟参数。
- 图 6 的游戏位置来自 3950X 计数器，不是游戏轨迹模拟。

## 发布前检查

- [ ] 10 张图全部显示且顺序正确
- [ ] 60/46/52 周期和 256/96/32 MB 配置对应准确
- [ ] 每条轨迹 10 亿条指令、2000 万 warm-up 等条件保留
- [ ] 游戏结论标明是计数器近似映射
- [ ] V-Cache 延迟只有推测，没有写成测量事实
- [ ] Qualcomm 子集非随机、轨迹数量和模拟模型限制保留
