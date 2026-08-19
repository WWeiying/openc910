# CPU Clock Speed Change WeChat Publish Kit

## 正式标题

CPU 改变频率到底有多快：从 Zen 3、Skylake 到手机 SoC 的毫秒级测试

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：How Quickly do CPUs Change Clock Speeds?
- 日期：2022-09-15
- 阅读原文：https://chipsandcheese.com/p/how-quickly-do-cpus-change-clock-speeds
- 栏目：处理器微架构 / DVFS

## 摘要

Skylake 借 Speed Shift 约 5.62 ms 到顶，Zen 2/3 多在数到十几 ms；Haswell/Piledriver 默认几十 ms，电池下 Snapdragon 821 可近 400 ms。高 idle 电压能把 Piledriver 压到亚毫秒，却以空闲功耗换响应。完整轨迹比“到顶时间”更重要。

## 封面文案

从空闲到高频，CPU 要等几毫秒？

## 分享文案

同样的核心，换一块 OEM 主板、一个电源计划或电池状态，升频曲线就可能完全不同。用依赖加法与 timestamp counter，把 DVFS 的时间尺度测出来。

## 备选标题

- Skylake 5.62 ms，手机可到 400 ms：CPU 升频实测
- 最高频率不是瞬间到达：一组跨平台 DVFS 曲线

## 标签

DVFS、CPU 频率、Intel Speed Shift、Zen 3、Skylake、Snapdragon、兆芯

## 图片说明

- 共 13 张图，保持页面顺序。
- 图 1 只能作总览，图 13 是方法边界。
- 接电/电池、电源计划图例不可裁切。

## 移动端排版与后台设置

- 后台作者填 Chester Lam，摘要填后台。
- 开启阅读原文与查看原图。
- 不用单一到顶数字制作脱离条件的排名。

## 发布前检查

- [ ] 13 张图完整且顺序正确
- [ ] 各平台主板、移动设备和电源状态保留
- [ ] 100% minimum state 的高 idle 电压代价保留
- [ ] LuJiaZui 旧版按键测试误差保留
- [ ] RDTSC/CNTVCT_EL0 精度差异准确
