# AMD Zen 5 游戏负载微信公众号发布资料

## 正式标题

Zen 5 跑游戏：更宽、更深，为何仍被前端延迟拖住

## 备选标题

- 24K BTB、6K Op Cache：Zen 5 的游戏前端为何仍会停
- Ryzen 9 9900X 的游戏瓶颈：不是跨 CCX 先出问题
- 从 PMU 看 Zen 5：低 IPC 游戏到底卡在哪里

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Running Gaming Workloads through AMD’s Zen 5*
- 发布日期：2025 年 8 月 2 日
- 阅读原文：https://chipsandcheese.com/p/running-gaming-workloads-through

## 摘要

Zen 5 有 24K BTB、6K Op Cache、448 项 ROB 和统一调度器，游戏却主要受前端延迟限制。PMU 还显示正常调度下跨 CCX 流量很少，强行拆分才下降约 7%。

## 分享卡片文案

标称 12-wide 的 Op Cache 平均只有约 6 uops/cycle；448 项 ROB 能填满，整数寄存器却先吃紧。Zen 5 的游戏短板藏在连续供给和长延迟路径。

## 封面

- 主标题：Zen 5 跑游戏
- 副标题：更宽、更深，为何仍会停
- 小字：24K BTB / 6K Op Cache / 448 ROB / CCX
- 比例：2.35:1，AMD 橙，前端控制流与双 CCD 拓扑结合

## 推荐标签与栏目

- 标签：AMD、Zen 5、Ryzen 9 9900X、游戏性能、分支预测、Op Cache、乱序执行、CCX
- 栏目：处理器体系结构

## 图片与排版

- 正文图片：17 张，按 01～17 上传
- 图 2～14 为 PMU 主体，图 16、17 解释调度与跨 CCX
- AMD/Intel 数据源事件定义不同，图注边界不能删

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/running-gaming-workloads-through
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 与 Lion Cove 的游戏场景、内存和软件版本不同，只比较趋势。
- 11～12 cycle Frontend Stall 接近 L2 是推测线索，不是直接归因。
- 7% 来自关闭 Boost、强制 3＋3 核的人工场景；自然调度跨 CCX 很少。
- L1D Fill 包含 Prefetch/未退休访问，不能与 Intel 退休口径直接相除。
