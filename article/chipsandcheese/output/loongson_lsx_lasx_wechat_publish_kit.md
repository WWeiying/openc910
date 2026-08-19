# 龙芯 LSX/LASX 微信公众号发布资料

## 正式发布信息

- 正式标题：龙芯 LSX 与 LASX：LoongArch 的 128/256-bit 向量扩展
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2023 年 2 月 26 日
- 英文标题：Loongson’s LSX and LASX Vector Extensions
- 原始链接：https://chipsandcheese.com/p/loongsons-lsx-and-lasx-vector-extensions

### 摘要

通过 Loongnix 工具链和 3A5000，观察 LSX/LASX 的寄存器别名、固定32-bit编码、高位未定义语义，以及双端口原生256-bit FPU的吞吐与窗口。

### 封面与分享文案

- 主标题：LoongArch 的 256-bit 向量
- 副标题：LASX 的指令语义与 3A5000 实现
- 分享文案：128-bit 运算为什么会改动整个256-bit状态？从 F/VR/XR 别名到32项 Scheduler，拆开 ISA 与硬件实现。
- 备选标题：LASX 不只是“龙芯版 AVX2”；龙芯向量扩展的高位语义与执行代价

### 标签与栏目

- 标签：龙芯、LoongArch、LSX、LASX、SIMD、Vector FPU
- 栏目：ISA 与 CPU 微架构

## 图片与移动端排版

- 图片8张，目录 `loongson_lsx_lasx_figures/`，按01～08上传。
- Encoding/寄存器图用全宽；代码名保留等宽字体。

## 后台设置与发布前检查

- 当时无完整公开 LSX/LASX 文档，编码图为逆向猜测，不冒充规范。
- Partial Register 高位未定义；观察到的跨页随机值不可作为稳定行为。
- 128 Total Vector Register、8/6 Port 等为推断；3A5000不代表 ISA 上限。
- 核对32个寄存器、128/256 bit、5-bit Immediate、32项 Scheduler、96 Rename、4 KB RF及8图。
- 后台作者 Chester Lam；阅读原文填完整链接；原创关闭，AI标识按要求开启。
