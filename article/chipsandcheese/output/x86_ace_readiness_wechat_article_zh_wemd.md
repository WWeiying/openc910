---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "x86_ace_readiness_wechat_article_zh"
---

> 英文标题：Is x86 ready to ACE it?
> 撰文：Chester Lam
> 首发：Chips and Cheese，2026 年 7 月 14 日
> 链接：https://chipsandcheese.com/p/is-x86-ready-to-ace-it

工作负载变化时，CPU 也会用 ISA Extension 更高效地表达新计算。Intel AMX 以二维 Tile Register 和配置寄存器服务机器学习，首个硬件 Accelerator Type 是 Sapphire Rapids 的 Tile Matrix Multiply Unit（TMUL）。如今 x86 Ecosystem Advisory Group 提出 ACE，作为 AMX Framework 的第二种 Accelerator。为避免名词混乱，本文沿常见文档习惯，把现有 TMUL 称为 AMX，新提案称 ACE。

![图 1：Intel AMX Programming Reference 早已为 TMUL 之外的 Accelerator Type 预留编号，ACE 对应 Accelerator 2](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/e64e498d429e4c9e_01_figure.jpg)

## 从可配置 Tile 到固定 Tile，从 Inner Product 到 Outer Product

AMX TMUL 允许软件逐个配置 Tile 的 Rows 与 Bytes-per-row。例如 `tmm0` 可设为 16×64 的 INT8 Matrix；`TDPBSSD` 等指令根据配置完成 Tile 间矩阵乘。数据类型覆盖 INT8、FP16、BF16，Granite Rapids-D 最新实现还加入 FP16 Real+Imaginary 的 Complex Number。

![图 2：AMX TMUL 的 Tile 配置与矩阵乘数据流](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/c3f5db79b9c0ba8a_02_figure.png)

ACE 取消 Tile Shape 配置，恒定为 16 Rows×64 Byte；Complex 支持消失，加入 FP8。更根本的变化是计算 Primitive：AMX/AVX512-VNNI 加速 Inner Product，ACE 加速 Outer Product。

![图 3：ACE 固定 Tile 与 Outer-product Instruction 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/14a38055749ef86d_03_figure.png)

若向量为 \(a,b\)，Inner Product 得到 Scalar：

\[
a \cdot b = \sum_i a_i b_i
\]

Outer Product 则得到 Rank-1 Matrix：

\[
C = a b^T,\qquad C_{ij}=a_i b_j
\]

Matrix Multiplication 可看成多个 Outer Product 之和，SVD 也可写为 \(A=\sum_i \sigma_i u_i v_i^T\)。FFT 等不那么直观的 Algorithm 也已有面向 Arm SME 的 Outer-product Reformulation。

![图 4：Arm 展示的以 SME Outer Product 重写 FFT 的示例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/ce5337fa596fec48_04_figure.png)

历史上偏爱 Inner Product，是因为它需要保留的 Register State 少；但当硬件提供大二维 Accumulator 后，Outer Product 更自然。Arm Scalable Matrix Extension（SME/SME2）走的是相似道路。

ACE 延续 AMX 固定 8 KB Tile Register。SME 则有与 SVE 可不同的 Streaming Vector Length（SVL），实现可选 128～2048 bit、按 2 的幂增长；ZA 是 SVL×SVL 的二维阵列，因此容量从 128 bit SVL 时 256 Byte，到 2048 bit 时 64 KB。

### 体系结构视角：外积的价值来自数据复用位置改变

Inner/Outer Product 在数学上可互换，硬件代价却不同。Outer-product Engine 让一对输入 Vector 更新二维 Accumulator，把更多 Partial Sum 留在 Tile Register 内，减少 L1D 往返。性能关键不只是 MAC 数量，还在于 Accumulator Capacity、输入供给路径与数据复用能否匹配。

## 低比特 Quantization：ACE 更灵活，SME2 更紧凑

Model Weight 常量化到很低 Bit-width，以减轻 Capacity 与 Bandwidth。ACE/SME 不像 Nvidia Tensor Core 那样让输入经 Register File 来回搬运，而由软件在向 Accelerator 喂数据前完成 De-quantization。

ACE 借固定 512 bit AVX-512/AVX10 Register：`VPERMB` 可把一张至多 6 bit Input→8 bit Output 的完整 Lookup Table 放入一条 Vector；7 bit 用 `VPERMI2B` 组合两条 512 bit Register。AVX10.3 新 `VUNPACKB` 先把 2～7 bit Element 展开到 Byte-aligned Position，再由 Permute 查表。

![图 5：ACE 以 VUNPACKB 与 VPERM(2I)B 两步完成 2～7 bit 灵活转换](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/bd224bc6d701f802_05_figure.png)

这个组合还能实现自定义 Codebook，不只服务 Weight。SME 不能假定 Vector 足够宽，因此 SME2 另加固定 512 bit `ZT0`，作为 16×4 Byte Lookup Table；`LUTI2/LUTI4` 从 Vector 解压 2/4 bit Index、查表并写回。

![图 6：SME2 用 ZT0 一条 LUT 指令完成转换](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/df33840cb4062483_06_figure.png)

SME2 一条指令完成、无 Intermediate Register，且 Table 不占通用 Vector Register；代价是只直接支持 2/4 bit、复杂多表 Codebook 不方便。Arm 仍可用新增 LUT Variant 扩展更多宽度。

## FP8 Dynamic Range 与 Block Scaling

FP8 Dynamic Range 有限。Open Compute Project Microscaling Format 给一组 Value 共用 Scale，以不增加每个 Element Bit-width 的方式扩大乘积范围。ACE 新增 1024 bit `BSR0`：两半各 512 bit，对应 Outer Product 两个输入；每半再分四组、每组 16 个 8 bit Scale，由指令 Immediate 选择。

![图 7：ACE v1 Specification 中带 Block Scale 的 Outer Product](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/cebb3756d2dc9f87_07_figure.png)

SME 用 Floating Point Mode Register（FPMR）的 `LSCALE/LSCALE2`，先由 `BF1CVT/BF2CVT` 应用 Scale，再执行 Outer Product。两条 Convert 的 1 bit Opcode 差异也可被 Decoder 看作 Immediate，思想与 BSR Group Selection 相近。

两边更新 Scale Register 都覆盖整个 Register，暗示 Scale 不会频繁变化。若硬件不 Rename BSR0/FPMR，每次更新可能形成 FP8 Serialization Barrier；若要 Rename，又会给宽寄存器状态与依赖追踪带来压力。ACE 所有 FP8 Outer Product 都依赖最后一次 BSR0 Write；SME 的 FPMR 还含 FP8 Format/Overflow Mode，同样难绕开。这是基于 ISA 依赖关系的实现风险，不是已有硬件实测。

## Tile 越大，Cache Traffic 越少

Tiling 把 Matrix 切成适合 Cache 的 Submatrix，提高复用；Compute 足够强时，L1/L2/L3/DRAM 供给仍可能成瓶颈。Result Accumulator 最好留在 Register，因为每次 Spill 是 Read-modify-write，而且 Store Bandwidth 通常比 Load 更少。

![图 8：2×2 Tile 覆盖时一个 Input Tile 只被三个 Output Tile 复用；3×3 时要为五个 Output Tile 加载](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/eb80868afb387834_08_figure.png)

用 \(C=AB\)、三矩阵均 32K×32K、INT8 输入作理想化比较，总计算量为 \(32768^3\)，约 35.2 Tera MAC。C 始终留在 Register，A/B 按需加载。以下数字忽略 Real Kernel 中的 Control、Packing 等成本，服务于 Traffic 下界比较。

### AVX-512 VNNI

32 个 512 bit Register 中约 24 个放 C Accumulator、8 个放输入，输出 Tile 为 16×24。每次 Kernel 要从 A/B 读 `(16+24)×32K≈1.3M` Element，共运行约 `32K×32K/(16×24)≈2.7M` 次，总 Cache Traffic 约 3.4 TB，即 0.10 Byte/MAC。

![图 9：AVX-512 VNNI 的 16×24 Accumulator Tiling](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/9e683d58368895f3_09_figure.png)

若 L1D 可给 128 B/Cycle，理论可供 1228 MAC/Cycle，等价于超过 19 条 512 bit Pipe，当前 CPU 不太可能先在此处受限。

### SME

以 512 bit SVL、4 Byte Accumulator 为例，ZA 可形成总计 32×32 Element Output。每轮加载 A/B 共 `2×32×32K≈2M` Element，但只需运行 1M 次，总 Traffic 2.0 TB，即 0.06 Byte/MAC，较 AVX-512 少近 50%；128 B/Cycle 可供约 2088 MAC/Cycle。

![图 10：512 bit SME 的 32×32 Accumulator](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/53c559e40856395b_10_figure.png)

Outer Product 还让 Vector Register 有余量做 Preprocessing，无需因输入占用而 Spill。Apple M4 是 512 bit SVL 实例；假想 1024 bit SME 可形成 64×64 Output，只运行 0.25M 次，总 Traffic 约 1.0 TB。

### AMX TMUL

用 6 个 Tile 保存 C，A/B 各一，输出 32×48。每轮加载 A 32×32K、B 48×32K，共约 2560 Tile Load；运行约 0.7M 次，总 1.7 TB，即 0.052 Byte/MAC，128 B/Cycle 可供 2457 MAC/Cycle。估算与研究表明每加载 7 Tile 至多 Spill 2 Tile，可落在 L1，本文方便起见忽略额外 Traffic。

![图 11：AMX 以六个 Tile 保存 32×48 Accumulator](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/690ac38fce37e126_11_figure.png)

Intel 推荐的另一 Tiling 需约 1M 次、每轮 2048 Tile，共 2.0 TB，明显更差，后续比较不采用。

### ACE

ACE 的 A/B 来自 AVX-512/AVX10 Register，8 KB Tile File 可全给 C，输出扩大到 32×64。每轮加载 `96×32K` Element，约 48K Vector Load，但只运行 0.5M 次，总 1.5 TB，即 0.046 Byte/MAC；128 B/Cycle 可供 2785 MAC/Cycle。

![图 12：ACE 的 32×64 Accumulator Tiling](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_ace_readiness_wechat_article_zh/031c6e51fc6c0855_12_figure.png)

若 \(M=N=K\)，Tile 两维为 \(T_a,T_b\)，总加载 Element 为：

\[
\frac{(T_a+T_b)N^3}{T_aT_b}
\]

一般 Data Reuse 下界约为 \(2MNK/\sqrt{T}\)，\(T\) 为 Accumulator Tile Element 数；Square Accumulator 达到下界。SME Tile Size 放大四倍时，Bandwidth Demand 正好减半，符合公式。

ACE 沿用 AMX 的 8 个 Tile，而 VEX Encoding 可容纳 16 个。AMX 文档提到未来扩展可能；若实现 16 Tile，本例可接近 1024 bit SME 的复用水平。目前 ACE 相对 AMX 的 Tile 增幅不大，收益可能有限，但 Data Movement 消耗显著功率：例如 Zen 5 在 Vector Unit 与 L1D 同时满载时会降频，较少 L1D Access 可能让 Compute-bound Code 保持更高 Boost；若 Engine 强到受下级 Stream 限制，少加载会直接变成性能。

## Tile Register 能否当 8 KB Scratchpad

ACE 的 `TILEMOVROW/TILEMOVCOL` 可在 Vector 与 Tile Register 间直接复制 Row/Column，不再像 AMX 那样绕 L1D。理论上软件可把 Value 暂存在 Tile File，减少 L1D Pollution；若路径独立，还能减轻 L1D Bandwidth。

现实障碍更多。Tile↔Vector 可能没有像 L1D Load 那样优化的 Forwarding，硬件即使给较长 Latency，也不太影响主流 Matrix Kernel，因为 Accumulator 很久才写回；拿它作 Scratchpad 时，Dependent Instruction 却会频繁等待。8 KB 对 Register File 很大，对 Scratchpad 很小——OpenCL 1.0 最低 Local Memory 都要求 16 KB。启用后 OS 还要在 Context Switch 保存额外 8 KB State，增加延迟。因此常规 Spill to Memory 更简单，甚至可能更快。

### 体系结构视角：ISA 潜力不等于实现性能

ACE Specification 只定义可见操作。真正性能取决于 Outer-product Array 宽度、Tile/Vector Move Latency、BSR Rename、L1D Ports、Clock Throttling、Context State 与 Compiler Kernel。没有 Hardware 时，Traffic Model 能说明上限和方向，却不能给出真实 IPC、功耗或相对 SME2 胜负。

## 结语

ACE 与 Arm SME2 都选择 Outer Product 与 Block Scaling，这也不意外：Arm 同样参与 OCP Microscaling Format。ACE 借固定 512 bit AVX Register 获得 2～7 bit 灵活 De-quantization；SME2 则围绕 Scalable Vector Length，用专用 ZT0 减少指令和 Register Pressure。二者各有长短，也都有继续扩展空间。

截至文章发布，市场上还没有 ACE Hardware；可能的 Intel/AMD 下一代支持仍不能当作既成事实。ACE 能否成功，最终取决于具体核心把 Tile、Vector、Cache 与频率控制连接得怎样，而不只是 ISA 表面提供了多少指令。

## 参考资料

- x86 Ecosystem Advisory Group：ACE v1 Public Specification/Whitepaper
- Intel AMX Architecture Instruction Set Extensions Programming Reference
- Arm SME/SME2 Documentation
- OCP Microscaling Formats
- Chips and Cheese：Is x86 ready to ACE it?
