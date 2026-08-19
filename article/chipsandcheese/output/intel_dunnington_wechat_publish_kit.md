# Intel Dunnington WeChat Publish Kit

## 正式标题

Dunnington：六个 Penryn 核心、16 MB L3，以及 Intel 早期多核互连的代价

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Intel’s Dunnington: Core 2 Goes Dun Dun Dun
- 日期：2023-02-05
- 阅读原文：https://chipsandcheese.com/p/intels-dunnington-core-2-goes-dun-dun-dun
- 栏目：处理器微架构 / 服务器与互连

## 摘要

Dunnington 把三组双核 Penryn、16 MB inclusive L3 与中央 CBC 塞进 503 mm² die，再用 7300 芯片组的百万项 snoop filter 扩到四路。核心基本功强，L3、FSB 和 DRAM scaling 却让六核单 socket 难以发挥，成为 Intel 走向 Nehalem/Sandy Bridge uncore 的过渡点。

## 封面文案

503 mm²、六核、16 MB L3：Intel 多核 Uncore 的早期试炼

## 分享文案

从 Penryn 的 ROB、LSU 和 6 MB L2，到 Dunnington 的 CBC、inclusive L3、四 FSB 与百万项 snoop filter，完整拆解 Intel 在共享总线时代怎样硬扩到四路服务器。

## 备选标题

- Dunnington：Intel 如何用 16 MB L3 对抗 FSB 瓶颈
- 从 Core 2 到 Nehalem 之间，被忽略的六核服务器实验

## 标签

Intel、Dunnington、Penryn、Core 2、FSB、L3 Cache、Snoop Filter、Uncore

## 图片说明

- 共 34 张图，保持英文页面顺序。
- 图 3—17 讲 Penryn，图 18—21 讲 L3，图 22—29 讲芯片组，图 32—34 讲 scaling。
- 图 29 的 DRAM 数据必须连同三条损坏 FBDIMM 一起说明。

## 移动端排版与后台设置

- 后台作者填写 Chester Lam。
- 摘要填后台，开启阅读原文与查看原图。
- 长文保留 Penryn、L3、7300、扩展性四个导航。

## 发布前检查

- [ ] 34 张图全部显示且顺序正确
- [ ] 503 mm²/19 亿、16 MB/16-way、37 ns 等参数准确
- [ ] Load/store 跨线、跨页和 4K alias 场景未混写
- [ ] Shared-array request combining 与损坏 DIMM 限制保留
- [ ] Dunnington 测试结果未外推为所有 Penryn 平台
