# CDC 6600 WeChat Publish Kit

## 正式标题

CDC 6600：在没有分支预测与缓存的年代追求并行

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Inside Control Data Corporation’s CDC 6600
- 日期：2024-04-01
- 阅读原文：https://chipsandcheese.com/p/inside-control-data-corporations-cdc-6600
- 栏目：计算机体系结构史 / 超级计算机

## 摘要

10 MHz、60-bit、十个独立功能单元、scoreboard、32-bank 磁芯内存，以及超过 14 MB 的 ECS：CDC 6600 没有分支预测、cache、rename 和 ROB，却已经在系统化利用指令级与存储体并行。文章保留 4 月 1 日的历史视角幽默，也逐层解释这些机制与现代 CPU 的联系。

## 封面文案

没有缓存、没有预测，CDC 6600 怎样成为超级计算机？

## 分享文案

从 8-word 取指队列、scoreboard 和非流水化功能单元，到 75 MB/s 的 32-bank 磁芯内存，回看现代高性能处理器思想的重要源头。

## 备选标题

- CDC 6600：Scoreboard 与并行执行的早期经典
- 一间房大小的“处理器”：拆解 CDC 6600

## 标签

CDC 6600、Scoreboard、超级计算机、磁芯存储、体系结构史

## 图片说明

- 共 13 张图，按页面顺序保留。
- 图 2、3、6、7、10、11 来自 CDC 手册或历史资料；图 8、9 是现代对照图。
- 图片中的旧式术语应保留，同时在正文说明与现代术语的对应关系。

## 发布前检查

- [ ] 13 张图全部显示且顺序正确
- [ ] 开篇明确 4 月 1 日与“历史新品评测”的讽刺语境
- [ ] 60-bit、18-bit、10 MHz、960 KB、32 bank 等参数准确
- [ ] 4.5 MFLOPS 的完美指令组合条件保留
- [ ] ECS 的 line、频率、容量、bank 与读写时序完整
- [ ] “免疫漏洞”“不到十台”等没有写成严肃结论
