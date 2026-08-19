# Golden Cove Vector Register File WeChat Publish Kit

## 正式标题

Golden Cove 不对称的向量寄存器文件：AVX-512 宽度、重命名容量与 SMT 的取舍

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Golden Cove’s Lopsided Vector Register File
- 日期：2022-12-25
- 阅读原文：https://chipsandcheese.com/p/golden-coves-lopsided-vector-register-file
- 栏目：处理器微架构 / 重命名与向量执行

## 摘要

Golden Cove 约测到 295 个 256-bit rename、210 个 512-bit rename，说明并非所有物理向量寄存器都有完整 ZMM 宽度。重命名器按结果宽度使用资源，SMT 再以 watermark 动态共享，在面积、乱序窗口与公平性之间折中。

## 封面文案

为什么 Golden Cove 的向量寄存器并不一样宽

## 分享文案

从裸片布局到结构容量微基准，解释 Golden Cove 如何让常见 AVX2 结果使用更多 entry，同时保留强 AVX-512 能力，并在 SMT 下避免资源简单对半。

## 备选标题

- Golden Cove 的 AVX-512：不是每个物理寄存器都有 512 bit
- 从 295 到 210：Golden Cove 向量重命名容量实测

## 标签

Intel、Golden Cove、AVX-512、寄存器重命名、SMT、物理寄存器文件、Zen 4

## 图片说明

- 共 8 张图，图 4、5、6 是微基准核心证据。
- 裸片图只能用于说明物理布局观察，不能写成 RTL 确认。

## 移动端排版与后台设置

- 摘要填后台，开启原文链接。
- 295/210 与推算 327/242 必须保留“约”和假设条件。
- 图表保持原比例。

## 发布前检查

- [ ] 8 张图均可显示
- [ ] 未把微基准估计写成官方总容量
- [ ] AVX-512 需特殊芯片和旧 BIOS 的条件保留
- [ ] watermark 与完全竞争共享的区别准确
- [ ] 没有从裸片照片猜测未公开控制逻辑
