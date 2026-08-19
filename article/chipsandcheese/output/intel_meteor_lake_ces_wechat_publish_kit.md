# Meteor Lake CES Preview WeChat Publish Kit

## 正式标题

CES 初探 Meteor Lake：三类核心，以及一套为低功耗重做的系统层级

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Previewing Meteor Lake at CES
- 日期：2024-01-11
- 阅读原文：https://chipsandcheese.com/p/previewing-meteor-lake-at-ces
- 栏目：处理器微架构 / Meteor Lake

## 摘要

CES 样品上，Redwood Cove、Crestmont 与 N6 LPE-Core 分别约 4.7、3.77、2.48 GHz。P/E cache 延续 Raptor Lake，L3 延迟和部分带宽却回退；LPE-Core 不接 L3、DRAM 超 200 ns，换取不唤醒 Compute Tile 的低功耗机会。

## 封面文案

三类核心，不只是三档性能

## 分享文案

从 48 KB L1D、2 MB L2 到无 L3 的 LPE-Core，再看跨 Tile cacheline bounce：Meteor Lake 的重点不是单核大改，而是系统层级如何服务轻载省电。

## 备选标题

- Meteor Lake 三种核心初测：LPE-Core 为什么离 DRAM 太近
- Redwood Cove、Crestmont、LPE-Core：CES 上的缓存与互连数据

## 标签

Intel、Meteor Lake、Redwood Cove、Crestmont、LPE-Core、Cache、Chiplet

## 图片说明

- 共 14 张图，全部按页面顺序。
- 图 3—5 为 P-Core，6—8 为 E-Core，9—11 为 LPE-Core，12—13 为互连。

## 移动端排版与后台设置

- 后台作者填 Chester Lam；摘要填后台。
- 开启阅读原文和查看原图。
- 样品频率和 LPDDR 配置必须与结论同屏呈现。

## 发布前检查

- [ ] 14 张图完整、顺序正确
- [ ] 4.7/3.77/2.48 GHz 与样品边界保留
- [ ] P/E/LPE 的 cache 层级没有混写
- [ ] Ring 低频只写为猜测
- [ ] CES 有限测试未外推零售平台总性能
