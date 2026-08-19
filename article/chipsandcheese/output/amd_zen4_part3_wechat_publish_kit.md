# AMD Zen 4 第三篇微信公众号发布资料

## 正式发布信息

- 正式标题：AMD Zen 4 第三篇：Boost、Infinity Fabric 与 Raphael 核显
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2023 年 1 月 5 日
- 英文标题：AMD’s Zen 4, Part 3: System Level Stuff, and iGPU
- 原始链接：https://chipsandcheese.com/p/amds-zen-4-part-3-system-level-stuff-and-igpu

### 摘要

从逐核心短时 Boost、单 CCD 32/16 B/cycle IFOP 边界，到仅一组 WGP、64 KB L1 和 256 KB L2 的 Raphael 核显，补齐 Zen 4 的系统级细节。

### 封面与分享文案

- 主标题：Zen 4 系统级细节
- 副标题：Boost、Infinity Fabric 与最小 RDNA 2
- 分享文案：为什么一颗 CCD 先撞上 Fabric 上限，四线程反而比全线程更快？15 张图看懂 7950X 的细粒度频率、DDR5 调度和 Raphael 核显。
- 备选标题：一颗 7950X 的系统侧秘密；Zen 4 的快慢 CCD、IFOP 与亮机核显

### 标签与栏目

- 标签：AMD、Zen 4、Ryzen 9 7950X、Infinity Fabric、RDNA 2、DDR5
- 栏目：CPU 与 SoC 架构

## 图片与移动端排版

- 图片 15 张，目录 `amd_zen4_part3_figures/`，按 01～15 上传。
- 封面建议 900×383 px，双 CCD—IOD 链路配一组小型 WGP。
- 正文 15～16 px、行距 1.7；带宽曲线与延迟图保持 100% 宽，可点击原图。

## 后台设置与发布前检查

- Boost、好核心位置均为单颗样品，不写成 AMD 固定分箱政策。
- DDR5-6000 与 DDR4-3333 不作直接产品排名；FCLK 降频只清楚验证写链路约束。
- GPU 标量/向量路径不同；Raphael 向量延迟没有完成测试。
- 后台：原创声明关闭；AI 内容标识按平台要求开启；“阅读原文”填完整链接。
- 发布前核对 15 张图、5.51～5.74 GHz、32/16 B/cycle、81%、60 GB/s、64/256 KB 等数字。
