# Golden Cove Cache Simulation WeChat Publish Kit

## 正式标题

如果重做 Golden Cove 的缓存：214 条 Trace 告诉我们哪些取舍值得

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Going Armchair Quarterback on Golden Cove’s Caches
- 日期：2022-02-11
- 阅读原文：https://chipsandcheese.com/p/going-armchair-quarterback-on-golden-coves-caches
- 栏目：处理器微架构 / Cache 仿真

## 摘要

ChampSim 的 214 条 trace 显示：32 KB/4 周期 L1D 在 204 条上胜出，大型 Golden Cove L2 胜过 512 KB/12 周期方案，低延迟 L3 普遍有益，而 90 MB 大缓存表现高度分化。M1 Max 缓存很强，却对应完全不同的频率和产品目标。

## 封面文案

Golden Cove 的缓存，哪些地方值得重做？

## 分享文案

把 Golden Cove 的 L1、L2、L3 分别换成 Skylake、Phenom、Zen 3、V-Cache 和 M1 Max 风格，214 条 trace 展示延迟、容量与相联度如何互相拉扯。

## 备选标题

- 从 32 KB L1 到 90 MB L3：Golden Cove 缓存假设实验
- 大缓存不总是更快：Golden Cove 的 214 条 Trace

## 标签

Intel、Golden Cove、ChampSim、L1 Cache、L2 Cache、L3 Cache、Zen 3、Apple M1

## 图片说明

- 共 34 张图，全部按英文页面顺序保留。
- 图 20、23、30 为三组核心结论，图 34 是模拟配置边界。
- 分布图和散点图必须保留完整坐标，不用平均值图替代。

## 移动端排版与后台设置

- 章节较长，目录建议保留 L1/L2/L3/整套替换四级导航。
- 摘要填入后台，开启原文链接和图片查看原图。
- 正文不得把 ChampSim 结果写成芯片实测。

## 发布前检查

- [ ] 34 张图片完整、顺序正确
- [ ] 214 条 trace、10 亿指令和来源限制保留
- [ ] 204/214、115/214、111/214、205/214 数据无误
- [ ] 模拟建议与真实 Golden Cove 实现明确分开
- [ ] 未把不同频率目标下的 M1 缓存直接判为产品替代方案
