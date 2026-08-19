---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "condor_cuzco_wechat_article_zh"
---

> 英文标题：Condor’s Cuzco RISC-V Core at Hot Chips 2025
> 撰文：Chester Lam
> 首发：Chips and Cheese，2025 年 8 月 29 日
> 链接：https://chipsandcheese.com/p/condors-cuzco-risc-v-core-at-hot

Condor Computing 是 Andes Technology 在 2023 年成立的可授权 RISC-V 核心子公司。Hot Chips 2025 上公布的 Cuzco 是一颗八宽乱序核心，定位与 SiFive P870、Ventana Veyron V1 相近，理论上应明显超过已经有硅片的 C910 与 P550。

![图 1：Cuzco 的市场定位与总体特征](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/35c0c79e9fb9f63f_01_figure.jpg)

Cuzco 最特别之处不在 ISA，而在后端：它保留乱序语义，却尽量用静态的“基于时间（time-based）”方式安排执行，以降低传统动态调度器的功耗和复杂度。编译器不需要为此做特殊处理。

## 核心总览与可配置集群

Cuzco 具有 256 项重排序缓冲区（ROB），从取指到数据缓存访问完成共 12 级；Condor 给出的 10 周期误预测代价更适合跨核心比较。TSMC 5 nm 上的目标频率约为慢工艺角 2 GHz、典型工艺角 2.5 GHz。

![图 2：八宽流水线和核心参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/84a9af27eed17baa_02_figure.jpg)

作为授权 IP，Cuzco 由可变数量的执行切片组成。L2 TLB、片外总线宽度、L2/L3 容量和多种内部结构均可按客户需求调整。每个集群最多八核，通过 CHI 总线接入客户自己的片上网络（NoC），从而扩展为多集群系统。

![图 3：Cuzco 集群与可配置系统接口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/f381e7b6eb8d8fb6_03_figure.jpg)

以上来自 Condor 幻灯片和说明，不是量产芯片实测；最终频率、面积、延迟和多核扩展都取决于具体实现。

## 前端：TAGE-SC-L、两级 BTB 与 64 KB L1I

条件分支由 TAGE-SC-L 预测器处理。TAGE 用多张具有不同几何历史长度的带标签表选择合适上下文；统计修正器（SC）可在 TAGE 经常出错的模式下翻转结果；循环预测器（L）则识别“连续执行若干次、最后退出一次”的循环分支。Cuzco 披露的基础双模态表为 16K 项，但其余表容量、历史长度与哈希细节没有公开，不能仅凭算法名称推断精度。

![图 4：分支预测、BTB、取指与译码资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/b229e128db023c03_04_figure.jpg)

分支目标缓冲器（BTB）两级合计 8K 项，返回地址栈（RAS）32 项，另有间接分支预测器。幻灯片显示 BTB 命中/未命中在 L1I 访问启动后一周期得知，因此 taken 分支可能形成一个气泡。

64 KB、八路组相联 L1 指令缓存由 64 项全相联 iTLB 支持。每次先把完整 64 B cache line 放入指令缓存队列（ICQ），再送入指令队列（XIQ），八宽译码器从 XIQ 取指。

### 体系结构视角：准确率之外，预测延迟同样进入 IPC

TAGE-SC-L 可以降低 MPKI，但若方向或目标太晚返回，前端仍会产生覆盖气泡。验证这类前端不能只看误预测数，还应测 taken 分支密度、BTB 不同 footprint 下的吞吐、重定向周期和 L1I miss 并发度。公开资料未给出 Cuzco PMU 事件，因此这里只能提出通用验证方法。

## Rename/Allocate：提前预订未来的执行资源

传统乱序核在重命名、分配后，由调度器每周期检查依赖是否就绪。Cuzco 的重命名/分配级还会预测指令应在未来哪个周期执行。

![图 5：重命名阶段生成执行时间表](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/cc8a5561046bdfcc_05_figure.jpg)

这与 Nvidia Kepler 以后 GPU 的静态调度有相似之处，但 Cuzco 由硬件动态建表，软件仍看到普通 RISC-V。后端不必每周期对所有候选项做复杂唤醒选择，只需等待预定周期再发射。

![图 6：时间资源矩阵 TRM](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/72b7c1627674c248_06_figure.jpg)

时间资源矩阵（Time Resource Matrix，TRM）记录未来最多 256 周期内的执行端口、功能单元和数据总线占用。硬件不会搜索完整 256 行，而只在依赖预计就绪后的一个小窗口寻找空位；Condor 认为八周期窗口是较好的折中。重命名宽度为八，因此每周期最多检查 64 行。窗口内找不到资源时，指令停在 ID2。

长延迟 Load 不会简单占用超出 TRM 的未来格子：调度时一律先假设 L1D 命中，未命中再通过 replay 纠正。因此 TRM 长度本身很少直接造成停顿。

![图 7：有限搜索窗口与理想贪心调度的性能差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/91472504dec88645_07_figure.jpg)

Condor 的模拟显示，有限窗口相比假想的完美“贪心”时间表损失数个百分点。但完美调度本身未必可实现；传统分布式动态调度器也会因某个队列拥塞，而让其他队列背后的空闲单元用不上。

![图 8：变量延迟通过 poison 与 replay 处理](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/a29e33d98ebcaadb_08_figure.jpg)

Load 可能遭遇 cache/TLB miss、bank conflict 或 Store forwarding，延迟无法预知。重命名级会检查 Load 地址是否来自此前 Store 的同一寄存器，以减少部分 replay，但没有像 Intel Core 2 那样预测内存依赖，也不预测 Load 是否会 miss。

### 体系结构视角：把调度复杂度换成 replay

传统调度器持续支付比较和唤醒功耗；Cuzco 先押注固定延迟，错误时才补救。正常命中路径更简单，异常延迟会让消费者及其依赖链重执行。它是否划算取决于 replay 频率、被污染链长度和执行端口余量，而不能只比较队列项数。

## 后端、执行切片与向量

指令在各执行队列（XEQ）中等待指定周期；预测错误的结果标记为 poisoned，消费该结果的指令随后重执行。Condor 给出每千条指令 70.07 次 replay，约额外占用 7% 执行资源。这个数字看起来不低，但现代核心很少长期占满全部宽度，可能仍是可接受的功耗/面积交换；结论有待硅片验证。

![图 9：执行切片、XEQ 和 poison replay](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/8df88150683574ad_09_figure.jpg)

每个切片包含两条流水线、四个寄存器读端口和两个写回端口，并能覆盖全部受支持的 RISC-V 指令。总发射仍限每切片两条，即便寄存器端口尚有余量，也不能同周期发出整数加、分支和 Load 三条。ALU 队列基线为 16 项，分支和地址生成队列为 8 项，均可按 2～32 项、2 的幂配置。跨切片转发通常一周期；零周期可配但实现困难。

向量 VLEN 可为 256/512 bit，一条向量指令拆成多个微操作分发到切片；原生单元宽度为 64 bit。每切片一套 FMA，四切片配置峰值为每周期八次 FP32 FMA，即按乘和加分开计 16 FLOP。FP Add 延迟两周期，FP Mul/FMA 四周期。

## Load/Store、TLB 与缓存层级

基线配置包含 64 项 Load Queue、64 项 Store Queue 和 64 项数据缓存 miss 队列。Load 访问缓存后即可离开 LQ，因此后端等待退休的 Load 数可能超过公布的 LQ 容量，行为可能类似 Zen；这里仍是根据描述的推断。

![图 10：Load/Store 队列与四条访存流水线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/dd386365acafc014_10_figure.jpg)

四切片配置每切片一条 Load/Store 管线，向量 Load 可达到总计 64 B/cycle。L1D 为物理索引、物理标签（PIPT），必须先完成地址翻译；一级 DTLB 是 64 项全相联，二级 TLB 四路组相联，可选 1K、2K 或 4K 项。私有统一 L2 容量可配，2 MB 示例在 TSMC 5 nm 占 1.04 mm²。

![图 11：地址翻译和私有 L2 配置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/01d36982ed9bfa96_11_figure.jpg)

八核共享分片式 L3，每个 slice 可提供 64 B/cycle，slice 数与核数相等。核与 L3 通过 crossbar 相连，L3 最高可与核心同频；对系统通过 64 B/cycle CHI 接口。多个核心映射到同一 slice 时仍可能冲突，集群之外的拓扑完全由实现者决定。

![图 12：八核集群、L3 分片和 CHI 出口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/condor_cuzco_wechat_article_zh/90542b2ee1265a2d_12_figure.jpg)

当 Load 实际命中 L3，消费者可能先按 L1D 命中执行一次、再按 L2 预计到达执行一次，最后在 L3 数据真正到达时执行第三次。这清楚展示了时间调度的代价：低延迟常见路径简单，深层 miss 用更多动态执行换正确性。

## 结语

Cuzco 没有像 Itanium 那样把调度约束写进 ISA，也没有像 Nvidia Denver 那样依赖翻译后的微码缓存。它把非常规部分藏在核心内部，用 TRM 预测时间、用 poison/replay 恢复变量延迟，保持软件透明。

这是一条高风险但边界清晰的路线：前端和 ROB 达到现代大核规模，后端则试图削减最昂贵的动态唤醒选择逻辑。Hot Chips 数据只能证明设计目标与模拟权衡，不能证明量产频率、能效和 replay 行为；真正判断成败，需要在硅片上同时测 IPC、replay、cache miss 层级、端口占用和功耗。

## 参考资料

- Condor Computing Hot Chips 2025 演讲
- Chips and Cheese：Condor’s Cuzco RISC-V Core at Hot Chips 2025
