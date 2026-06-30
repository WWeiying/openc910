# C910 VFPU（向量 / 浮点执行单元）学习文档

本目录系统讲解 OpenC910 的 **VFPU**（Vector / Floating-Point Unit）：从顶层架构到四个子执行单元（vfalu / vfmau / vfdsu）的内部实现。所有内容直接基于 RTL，流水级数、延迟拍数、关键参数均带 `file:line` 出处，不作推测。

> RTL 目录：
> - `C910_RTL_FACTORY/gen_rtl/vfpu/rtl/`（顶层 top/ctrl/dp/cbus/rbus）
> - `C910_RTL_FACTORY/gen_rtl/vfalu/rtl/`（fadd 加减 / fspu 特殊 / fcnvt 转换）
> - `C910_RTL_FACTORY/gen_rtl/vfmau/rtl/`（FMA 乘加 + 乘法器/压缩树/LZA）
> - `C910_RTL_FACTORY/gen_rtl/vfdsu/rtl/`（SRT 基-16 除法 / 开方）

---

## 文档索引

| 篇 | 文件 | 主题 | 核心要点 |
|---|---|---|---|
| 00 | [`00_vfpu_overview.md`](./00_vfpu_overview.md) | VFPU 总体架构 | 两条对称管线 pipe6/pipe7、两处不对称（fcnvt 只 pipe7、vfdsu 只 pipe6）、eu_sel 分发、CBUS/RBUS 双轨写回、MTVR 注入、VLEN128 切分、各运算延迟总表 |
| 01 | [`01_vfpu_top.md`](./01_vfpu_top.md) | 顶层五组件 | top/ctrl/dp/cbus/rbus 分工、逐级有效位流水、eu_sel 两级译码（12→5）、完成（早报）与结果（写回）双轨、子单元接线 |
| 02 | [`02_vfalu.md`](./02_vfalu.md) | vfalu（fadd/fspu/fcnvt） | 三算子共用 **EX1→EX3 三级流水**、`dp_vfalu_ex1_pipex_sel` 一热选子算子、op 的 func 译码、半精度 set0/set1 SIMD、ex3_pipedown 三选一写回 |
| 03 | [`03_vfmau.md`](./03_vfmau.md) | vfmau（FMA / 乘法器 / 压缩树 / LZA） | FMA **EX1→EX5 五级流水**、Booth+压缩树乘法、LZA 前导零预测、半精度独立 pipedown 通路、`ctrl_dp_ex5_fma_wb_vld` 写回、前递网络 |
| 04 | [`04_vfdsu.md`](./04_vfdsu.md) | vfdsu（SRT 基-16 除法 / 开方） | 双状态机（SRT 迭代机 + 写回机）、`srt_cnt_ini`（**double=13 / single=6 / half=3**）、`skip_srt`/`rem_zero` 变延迟、商位选择 bound_table、开方二轮 `srt_secd_round`、各精度延迟 |

---

## 各运算延迟与流水级速查

| 运算 | 子单元 | 流水级 | 延迟（拍） | 详见 |
|---|---|---|---|---|
| 加/减/比较/min/max | vfalu/fadd | EX1→EX3 | **3** | 02 §6 |
| fsgnj/fmv/fclass | vfalu/fspu | EX1→EX3 | **3** | 02 §7 |
| 类型转换（仅 pipe7） | vfalu/fcnvt | EX1→EX3 | **3** | 02 §8 |
| FMA / 乘法 | vfmau | EX1→EX5 | **5** | 03 §4 |
| FDIV double | vfdsu | 变延迟 | **约 18**（srt_cnt_ini=13） | 04 §5 |
| FDIV single | vfdsu | 变延迟 | **约 11**（srt_cnt_ini=6） | 04 §5 |
| FDIV half | vfdsu | 变延迟 | **约 8**（srt_cnt_ini=3） | 04 §5 |
| FSQRT | vfdsu | 变延迟 | 比同精度 FDIV 多（需二轮） | 04 §8 |

---

## 推荐学习路径

1. **先读 00（总体架构）**：建立全局图——两条管线、四个子单元、双轨写回、两处不对称。这是后面所有篇章的地图。
2. **再读 01（顶层五组件）**：理解 ctrl 怎么产生逐级有效位、dp 怎么把 eu_sel 分发到子单元、cbus/rbus 怎么分别处理完成与写回。读完 00+01 就掌握了 VFPU 的「骨架与调度」。
3. **按延迟从短到长读子单元**：
   - **02 vfalu**（3 拍，最简）：先理解「定长短流水 + 一热选子算子 + 共用流水」的最小模型。
   - **03 vfmau**（5 拍，中等）：在 vfalu 基础上加深一级，重点是 FMA 的 Booth/压缩树/LZA 与半精度独立通路、前递网络。
   - **04 vfdsu**（变延迟，最复杂）：最后攻克 SRT 基-16 迭代、双状态机、变延迟提前结束、开方二轮——这是 VFPU 里唯一不可流水的单元，理解它就理解了「变延迟单元如何与定长流水共存」。

**建议带着三个问题读**：① 这个运算为什么是这么多拍？② 它怎么与另一条管线 / 写回端口协作？③ 半精度（FP16）/向量是怎么切分覆盖的？这三条线贯穿全部五篇。
