---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "cpuid_unreliable_wechat_article_zh"
---

> 英文标题：Why you can’t trust CPUID
> 撰文：Ryan Mull
> 首发：Chips and Cheese，2022 年 10 月 27 日
> 链接：https://chipsandcheese.com/p/why-you-cant-trust-cpuid

社交媒体上流传的“新款 Zen 4”Geekbench 5 结果后来被证实是伪造的。麻烦在于，它们从截图和分数上都可以与真实结果难以区分：AMD 处理器的 Brand String 由六个可读写 CPUID Model-specific Register（MSR）保存，只要改写这些寄存器，依赖标准 CPUID Brand String 的软件就会显示任意名称。

![图 1：AMD Family 19h Model 21h Revision B0 PPR 第 163 页对 Brand String MSR 的定义](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpuid_unreliable_wechat_article_zh/a0dcc1b45fb2829b_01_figure.png)

这六个 64 bit Register 各保存 8 个字符，总共 48 字符；字符串还需 Null Termination，所以名称最长 47 字符。测试表明，这种寄存器至少可追溯到 Bulldozer，但不同软件能否观察到运行时改写并不一致。正常流程是在启动时写入，软件需要身份信息时再通过 `CPUID` 读取。

![图 2：把 47 字符空间写成玩笑名称，说明 Brand String 本身只是可编程数据](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpuid_unreliable_wechat_article_zh/e82a5f0a74f76d4a_02_figure.png)

## CPU-Z 为什么仍能识别 Zen 4，却显示错误名称

![图 3：改写前的 CPU-Z 识别结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpuid_unreliable_wechat_article_zh/b635ac7b8bc3f387_03_figure.jpg)

![图 4：改写 Brand String 后，CPU-Z 仍识别 AMD/Zen 4 特征，但型号名称已经变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpuid_unreliable_wechat_article_zh/495afc72cf5daf59_04_figure.jpg)

CPU-Z 获取 Brand String 时把 EAX 依次设为 `0x80000002`、`0x80000003`、`0x80000004`，每次执行 `CPUID`，从 EAX/EBX/ECX/EDX 取回 16 字符，合并成 48 字符。AMD Zen 返回的三段数据可由上述 MSR 控制，因此名称可以伪造；Family/Model、Feature Bit 等其他叶子仍让工具判断这是一颗 AMD Zen 4，两类信息并不矛盾。

### 体系结构视角：软件可见身份不是物理实现证明

`CPUID` 是硬件/虚拟化层向软件提供的枚举接口，而不是芯片内部结构的不可伪造测量。Brand String 更接近标签；Family/Model 与 Feature Bit 的约束更强，却仍是接口输出。验证“这是什么 CPU”应组合多个独立证据：拓扑、Cache 参数、指令 Feature、性能特征、Vendor-specific Telemetry 和可信平台链，而不能由一行名称完成。

## 为什么伪造 Benchmark 看起来很真

Geekbench 5 同样读取 CPUID 名称。只改字符串会露馅，但若所用高端 CPU 的资源多于目标“SKU”，再限制核心数和频率，性能就能落到一个很合理的区间。

![图 5：被改写身份后的 Geekbench 5 系统信息与单核结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpuid_unreliable_wechat_article_zh/59b4559ddc5bd1aa_05_figure.png)

![图 6：另一张看似合理的 Geekbench 5 结果；性能本身没有提示 Brand String 被改](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpuid_unreliable_wechat_article_zh/f4e610501dc2ca0d_06_figure.png)

实测 Geekbench、Cinebench、AIDA64、HWMonitor、Blender Benchmark 等都会显示修改后的 CPUID 名称。演示中以 Ryzen 9 7950X 和可超频主板提供足够资源，使用团队成员 clamchowder 开发、原本用于定位 CPU 瓶颈的 PMCReader 写 Brand String MSR，再施加负 350 MHz PBO Offset、每 CCD 禁用 3 个核心，组合出一个很像假想“Ryzen 7 7800X”的系统。并非所有机器或软件都能成功，但已经足以骗过社交媒体截图检查。

这里的重点不是教授伪造，而是说明“名称合理+分数合理”仍不是独立证据。基准数据库若允许匿名上传，至少需要更强的 Attestation、原始遥测或多维一致性校验。

## Bare Metal 与虚拟机的信任边界

![图 7：标准 CPUID 叶子提供的处理器标识信息](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpuid_unreliable_wechat_article_zh/b467b5ae11123c49_07_figure.jpg)

在确定为 Bare Metal 时，除 Brand String 外，部分 CPUID 参数仍可帮助判断 Generation；但遇到不常见真实型号，交叉验证也可能困难。一旦进入 Virtualization，Hypervisor 可以拦截 `CPUID` 并返回任意值，连 Family/Model/Feature 都不再能证明底层 Hardware。

HWiNFO 以及使用 HWiNFO 的 BenchMate 是少数不只依赖标准 CPUID 的工具，它们似乎还与 Vendor-specific Component 通信，例如查询新 AMD 处理器的 System Management Unit（SMU）。这种旁路证据更难伪造，却仍不能等价为密码学可信身份。

### 体系结构视角：虚拟化的职责正是重写硬件视图

Hypervisor 截获 CPUID 并非漏洞，而是虚拟化 Compatibility 的基本机制：Guest 需要看到稳定、可迁移的虚拟 ISA 与 Topology，而不一定是 Host 原貌。因此在 Cloud 环境引用 Benchmark 时，应该把实例类型、vCPU Topology、Hypervisor、频率策略和 Provider 声明视为测试条件，不能从 Guest 的 Brand String 反推裸机 SKU。

## 结语

CPU 名称、截图与一个落在预期区间的分数可以同时被构造。对未发布 SKU，厂商正式信息仍是最可靠来源；传闻至少要有多个独立渠道与无法轻易改写的证据。对正式评测，则应保留 Raw Result、平台照片/固件、系统配置、计数器与可复现步骤，并明确 Bare-metal 或 Virtualized。CPUID 很有用，但它描述的是软件看到的接口，不是不可篡改的身份证。

## 参考资料

- AMD Processor Programming Reference，Family 19h Model 21h Revision B0
- x86 CPUID Extended Function `0x80000002`～`0x80000004`
- Chips and Cheese：Why you can’t trust CPUID
