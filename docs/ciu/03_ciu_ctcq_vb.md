# C910 CIU CTCQ/VB 模块详细教学文档

> RTL 文件：`ct_ciu_ctcq.v`、`ct_ciu_ctcq_reqq_entry.v`、
> `ct_ciu_ctcq_respq_entry.v`、`ct_ciu_vb.v`、`ct_ciu_vb_aw_entry.v`
>
> 上层：`ct_ciu_top.v` 中的 `x_ct_ciu_ctcq` 与 `x_ct_ciu_vb`

---

## 1. 先纠正两个容易混淆的概念

### 1.1 CIU 的 CTCQ 不是 cache-to-cache 数据队列

`ct_ciu_ctcq` 处理的是核发起的 **CTC 类缓存/TLB 维护操作**和外部来的
**DVM（Distributed Virtual Memory）操作**。RTL 明确解码了：

- `ctc_dvm_addr[14:12] == 3'b000`：`tlbi`；
- `ctc_dvm_addr[14:12] == 3'b010`：`icachei`；
- `ctc_dvm_addr[14:12] == 3'b111`：`l2cicc`；
- 外部 AC 的 `acsnoop=1111/1110`：DVM operation/sync/complete 类事务。

因此，本文把 **CIU CTCQ**称为“CTC 维护请求队列”，不把缩写擅自扩展成
Cache-to-Cache Queue。CIU CTCQ 的主要数据是维护操作的编码地址、目标位图、
请求 ID 和完成位，不是 64B cache line 数据。

C910 中真正缓冲 coherence data response 的同名结构位于 LSU：
`ct_lsu_snoop_ctcq.v` 和 `ct_lsu_snoop_ctcq_entry.v`。它把被侦听核读出的
cache line 数据送向一致性互联。两个模块名称相近，但层次、数据宽度和职责
不同：

| 模块 | 所在层次 | 主要内容 | 主要作用 |
|------|----------|----------|----------|
| `ct_ciu_ctcq` | CIU | CTC/DVM 操作、目标位图、完成位 | 广播并排序缓存/TLB 维护 |
| `ct_lsu_snoop_ctcq` | 单核 LSU | coherence data response | 缓冲被侦听核返回的数据 |

### 1.2 VB 不是“只缓存脏数据”的抽象

`ct_ciu_vb` 接收 L2C0、L2C1、SNB0、SNB1 发来的 AW/W 事务，保存完整写地址
控制和最多一条 512-bit cache line 数据，再按 128 bit/beat 送 EBIU。常见来源
确实是 victim/writeback，但仅凭进入 VB 不能把每笔事务都断言为“脏行写回”。
是否真正向外发总线写还受 `awsnoop` 控制；例如 `awsnoop==3'b100` 的 Evict
在 EBIU 写通道中令 `aw_needissue=0`，不会产生片外 AW/W。

---

## 2. CTCQ 的输入、输出和请求分类

CTCQ 的结构接口有五个请求来源：

1. PIU0～PIU3 的 CTC 类 AR 请求；
2. EBIUIF 转入的外部 DVM AC 请求。

但当前有效来源只有 PIU0～PIU3。`ct_ebiu_snoop_channel_dummy` 把
`ebiu_ebiuif_acvalid` 固定为 0，所以 `ebiuif_ctcq_acvalid` 不会在正常运行中
拉高，外部 DVM 来源不可达。后文介绍该来源是为了解释保留 RTL，不代表当前
芯片顶层已启用外部 DVM 接收。

PIU 在 `ct_piu_top.v` 中用下式识别 CTC 类 AR：

```verilog
assign ar_ctc = &ibiu_ciu_arsnoop[3:0];
```

即 `arsnoop==4'b1111` 时路由到 CTCQ。该事实只说明核侧用此编码选择 CTCQ，
具体维护类型还要看 CTCQ 对地址字段和 domain 的解码。

| 接口 | 方向 | 作用 |
|------|------|------|
| `piuN_ctcq_ar_req/ar_bus` | PIU→CTCQ | 核发起 CTC 维护请求 |
| `ctcq_piuN_ar_grant` | CTCQ→PIU | CTCQ 已选中该来源且 reqq 有空间 |
| `ctcq_piuN_acvalid/acbus` | CTCQ→PIU | 向目标核派发维护操作 |
| `piuN_ctcq_ac_grant` | PIU→CTCQ | PIU 的 AC FIFO 已接收该派发 |
| `piuN_ctcq_cr_req/cr_bus` | PIU→CTCQ | 目标核返回维护响应 |
| `ctcq_piuN_rvalid/rbus` | CTCQ→PIU | 向原始发起核返回 CTCQ 响应 |
| `ctcq_l2c_addr_req` | CTCQ→L2CIF | 向两个 L2 bank 发维护请求 |
| `ctcq_ebiu_arvalid` | CTCQ→EBIU | 发 DVM operation/sync 类 AR |

这里的 `grant` 不能笼统理解成“事务完成”：

- `ctcq_piuN_ar_grant`：请求被 CTCQ 接收，可以创建 reqq；
- `piuN_ctcq_ac_grant`：某个目标 PIU 接收了 AC 派发；
- `piuN_ctcq_cr_req`：目标核的维护响应回到 CTCQ；
- respq 的全部完成位为 1：所有被点名目标完成；
- `ctcq_piuN_rvalid && piuN_ctcq_r_grant`：原始发起端接收返回。

这些事件可以发生在不同周期，不能在波形中看见一个 `grant` 就宣称整个 CTC
维护操作已经结束。

---

## 3. 请求选择与双事务约束

### 3.1 五源仲裁

```verilog
assign ctc_dvm_req[4:0] = {ebiu_dvm_req, piu_ctc_req[3:0]};
assign ctc_dvm_req_after_mask[4:0] =
       ctc_dvm_req[4:0] & last_req_sel[4:0];
```

`ct_prio #(.NUM(5))` 从五个来源中选一个。`ct_prio` 的内部优先关系会在
`clr` 时更新，因此这里应称为**有状态优先级仲裁**，不应写成固定优先级。

请求真正创建 reqq 的条件是：

```verilog
assign ctc_dvm_create_en = ctc_dvm_req_vld & !reqq_full;
```

也就是说，“有请求”还不等于“请求被接收”；只有选中来源且 reqq 当前可创建
时才在时钟沿更新队列状态。

### 3.2 `addr[0]` 表示两段维护事务

CTCQ 把 `ctc_dvm_addr[0]` 记录到 `two_trans_need`。当第一段表明还有第二段时：

- `last_req_sel` 把仲裁来源固定在同一请求者；
- `aim_last` 保存第一段算出的目标；
- 第二段复用保存的目标位图；
- PIU 收到 CTCQ AC 后也把 `acbus[AC_ADDR_0]` 记入 `ctcq_mask_snb`，在下一段
  完成前阻止普通 SNB AC 插入。

这能从 RTL 证明的是：**两段 CTC 维护请求保持来源和目标连续，且目标 PIU
暂时屏蔽 SNB AC**。不要进一步写成未经证明的“任意 CTC 原子操作”或
“cache-to-cache 数据传输原子性”。

---

## 4. 目标位图 `aim[5:0]`

CTCQ 为每个操作计算六个可能目标：

```verilog
assign ctc_dvm_aim[5:0] =
       {l2c_aim, aim_ebiu_final,
        aim_piu3_final, aim_piu2_final,
        aim_piu1_final, aim_piu0_final};
```

准确映射为：

| 位 | 目标 |
|----|------|
| `[0]` | PIU0 |
| `[1]` | PIU1 |
| `[2]` | PIU2 |
| `[3]` | PIU3 |
| `[4]` | EBIU |
| `[5]` | L2C |

`ct_ciu_ctcq_reqq_entry.v` 头部的旧注释只写到 `[4]`，且把 `[4]` 描述为 L2。
但实际输出逻辑 `reqq_ebiu_aim_x=reqq_aim[4]`、
`reqq_l2c_aim_x=reqq_aim[5]` 给出了无歧义的真实映射，文档以可执行逻辑为准。

当前 RTL 还有几个重要配置事实：

- `cp_mode[3:0] = 4'b1111`；
- `aim_ebiu = 1'b0`，所以普通路径下 `aim[4]` 不会被置位；
- `smpen[3:0]` 决定共享 DVM 操作广播到哪些核；
- 当前双核配置中 `smpen[3:2]=0`，PIU2/3 是 dummy。

`aim` 表示“本操作需要哪些目标参与”，不是 cache line 的 sharer 位图，也不是
SNB 的 `cp[3:0]`。

把这些常量与顶层 dummy 合起来看，当前核发起的 CTC 操作实际只可能选择
PIU0、PIU1 和 L2C；PIU2/3 被 `smpen` 去掉，EBIU aim 固定为 0。接口宽度仍
保留六目标，不能把“六位 aim”误读为运行中一定会向六处广播。

---

## 5. reqq：8 项“派发与返回”队列

每个 reqq 项保存：

```verilog
reg [39:0] reqq_addr;
reg [5:0]  reqq_aim;
reg [3:0]  reqq_respq_id;
reg [4:0]  reqq_rid;
reg [2:0]  reqq_mid;
reg        reqq_piu0_vld ... reqq_piu3_vld;
reg        reqq_ebiu_vld;
reg        reqq_l2c_vld;
reg        resp_done;
reg        reqq_vld;
```

### 5.1 每个目标都有“尚未处理”位

创建 reqq 时，六个 `reqq_*_vld` 全部置 1。随后每个目标使用自己的循环指针
按 reqq 顺序处理：

- `aim=1`：发出真实请求，等目标接收后清该目标的 valid；
- `aim=0`：产生 `void_req`，不向目标拉 valid，但仍推进目标指针并清 valid。

这种“真实请求或空操作都推进”的写法让所有目标各自保持 reqq 顺序，不需要为
不同的 `aim` 组合维护复杂的跳表。

### 5.2 `resp_done` 不等于 respq 全完成

这是读 RTL 时最容易误解的细节。reqq 的 `resp_done` 来自
`reqq_resp_done_x`，而该信号由原始返回路径的 grant 产生：

```verilog
assign reqq_resp_done[7:0] =
       {8{ctc_dvm_resp_grant}} & reqq_resp_ptr[7:0];
```

因此它表示“该 reqq 项给原始来源的响应已被接收”，不是“对应 respq 的六个
目标已经全部完成”。实际目标完成由下一节的 respq 单独跟踪。

reqq 释放条件为：

```verilog
reqq_vld
&& resp_done
&& !reqq_piu0_vld && ... && !reqq_piu3_vld
&& !reqq_ebiu_vld
&& !reqq_l2c_vld
```

所以 reqq 管的是：

1. 请求内容；
2. 各目标是否已经完成**派发/跳过**；
3. 原始响应是否已经交付。

它不需要等所有目标执行完成才释放；完成历史由带 ID 的 respq 保存。

### 5.3 发起端收到的不是 cache line 数据

CTCQ 返回给 PIU 的 `ctcq_piux_rbus` 中 512-bit 数据部分为 0：

```verilog
assign ctcq_piux_rbus =
       {2'b00, 2'b0, 2'b10, 5'b0, reqq_resp_rid, 519'b0};
```

因此该 R 路径是控制类响应，不是“拥有者核把 64B 数据经 CIU CTCQ 直传给
请求者”的证据。

---

## 6. respq：16 项“目标完成”跟踪队列

respq 每项有六个完成位：

```verilog
respq_l2c_cmplt;
respq_ebiu_cmplt;
respq_piu3_cmplt;
respq_piu2_cmplt;
respq_piu1_cmplt;
respq_piu0_cmplt;
```

创建时：

```verilog
assign respq_create_cmplt_init[5:0] = ~ctc_dvm_aim[5:0];
```

未被 `aim` 点名的目标初始即为完成；被点名的目标初始为 0，等对应 CR、EBIU R
或 L2C completion 到达后置 1。六位都为 1 时，该 respq 项才 pop。

### 6.1 respq ID 的作用

CTCQ 创建 reqq 时把 `respq_create_ptr` 写进 `reqq_respq_id`。向目标 PIU
发 AC 时，该 ID 被放入 AC SID 的低四位；目标核返回 CR 时，CTCQ用
`piuN_ctcq_cr_bus[8:5]` 选择对应 respq 项。L2C 和 EBIU 返回也通过保存的
4-bit ID 更新指定项。

因此 respq 允许多个维护操作并行在飞，并允许不同目标在不同时间完成；它不是
靠“当前队头”猜测响应属于谁。

### 6.2 16 项深度的准确边界

- reqq 实例数为 8；
- respq 实例数为 16；
- `ctc_respq_full = &respq_vld[14:0]`；
- `dvm_respq_full = &respq_vld[15:0]`。

这意味着 CTC 来源在前 15 项全部占用时就停止接收，给 DVM 路径保留容量边界。
不能仅根据“一个请求扇出多个目标”推导 respq 必须比 reqq 深；一个请求的六个
目标本来就保存在**同一个** respq 项里。更深的 respq 是实现选择，RTL 没有
给出其设计动机，文档不把猜测写成事实。

---

## 7. CTC/DVM 维护流程

以一个核发起共享 TLBI 为例：

```text
1. PIU 识别 arsnoop=1111，把 AR 放入 PIU AR FIFO并请求 CTCQ。
2. CTCQ 五源仲裁选中该 PIU；reqq 非满时给 ar_grant。
3. 在时钟沿创建 reqq，并为非 sync/complete 操作创建 respq。
4. 根据 domain、操作类型、smpen 计算 PIU0～3/L2C/EBIU 的 aim。
5. 各目标指针依次处理该 reqq：
   - aim=1：向目标发真实 AC/L2 请求；
   - aim=0：执行 void pop，只推进本目标的顺序。
6. 目标 PIU 接收 AC 后，由核内维护逻辑执行 TLBI/I-cache invalidate，
   再经 CR 返回对应 respq ID。
7. respq 对应 PIU 完成位置 1；所有目标完成后 respq 释放。
8. 原始来源接收 CTCQ 控制响应后，reqq 的 resp_done 置 1；
   当六个目标派发位也都清零时 reqq 释放。
9. 后续 barrier/sync 通过 reqq/respq empty 条件确认先前维护已排空。
```

第 8 步和第 7 步没有被 RTL 强制写成同一个周期或固定先后顺序。教学和波形分析
必须分别观察 reqq 与 respq，不能只看发起端 R 返回。

---

## 8. DVM sync/complete 与 barrier

CTCQ 还包含两组 FSM：

- `sync_cur_state`：本地 barrier 需要时，等待先前 CTC 请求和完成队列排空，
  必要时向 EBIU 发 DVM Sync，并等待相应返回；
- `comp_cur_state`：收到外部 DVM Sync 后，等待本地 DVM respq 排空，再组织
  Complete 路径。

关键排空条件包括：

```verilog
reqq_ctc_empty
respq_ctc_empty
respq_dvm_empty
comp_fsm_idle
```

这体现了 barrier 的微结构实现原则：**屏障完成不是“请求进入某个队列”，而是
规定范围内更早事务已经达到所需完成点**。当前 `dvm_comp_arvalid` 被常量置 0，
所以外发 DVM Complete 的这条实现路径在本配置中没有真正发 AR；文档必须把
“存在 FSM/信号”与“当前配置实际驱动有效事务”区分开。

当前边界比单独看 `dvm_comp_arvalid=0` 更严格：

- `aim_ebiu=0` 使 `aim_ebiu_f` 正常情况下不会置位，本地 CTC barrier 排空后
  会直接进入 `S_CMPLT`，不会走 `S_REQ` 发 DVM Sync；
- 外部 DVM AC 入口来自 EBIU snoop dummy，因而 DVM operation/sync/complete
  都不会从外部创建；
- EBIUIF 的 CR/CD 返回也固定无效。

所以本配置可验证的是本地 PIU/L2 维护与排空，不能声称已有端到端外部 DVM
协议实现。

---

## 9. VB：2 项地址/数据解耦缓冲

### 9.1 四个来源与接收条件

VB 的 AW 来源为：

```verilog
{l2c1_vb_awvalid, l2c0_vb_awvalid,
 snb1_vb_awvalid, snb0_vb_awvalid}
```

`ct_prio #(.NUM(4))` 选出一个来源。只有：

```verilog
|vb_aw_req && !vb_aw_full
```

时才产生 `vb_aw_create_en`。相应的 `vb_*_aw_grant` 表示 AW 内容已写入 VB
所选 entry，不表示 EBIU 或片外从设备已经接收该写。

VB 有两个 `ct_ciu_vb_aw_entry`。每项分别记录：

- `vb_aw_vld`：整笔事务仍占用 entry；
- `vb_aw_en`：AW 尚未被 EBIU 接收；
- `vb_w_vld`：该 entry 的 W 数据已经到达；
- 68-bit AW 控制；
- 535-bit W 内容；
- 3-bit `mid`。

AW 和 W 可以在不同周期到达。W 用来源携带的 one-hot `vid[1:0]` 写入先前
AW 分配的正确 entry，而不是再次做 AW 仲裁。

W 数据多路选择使用按位或，而没有运行时冲突检测：

```verilog
vb_w_create_bus = mask(l2c0) | mask(l2c1) | mask(snb0) | mask(snb1);
```

因此系统协议必须保证同一 VB entry 在同一周期至多有一个 W 来源有效，并保证
W 携带的是此前 AW grant 返回的 one-hot VID。验证时适合加入“每 entry 的四源
W valid 为 one-hot-or-zero”断言；否则多个 payload 会被按位或破坏。

### 9.2 四个不同完成点

对一笔 VB 写要区分：

1. **VB 接收 AW**：`vb_aw_create_en && vb_aw_sel[source]`；
2. **EBIU 接收 AW**：`ebiu_vb_aw_grant`，清 entry 的 `vb_aw_en`；
3. **EBIU 接收最后一个 W beat**：
   `ebiu_vb_w_grant && vb_ebiu_wlast`，清 `vb_aw_vld/vb_w_vld` 并释放 entry；
4. **片外 B 返回**：`pad_ebiu_bvalid && ebiu_pad_bready` 进入两项 BFIFO，
   按 BID 找到并释放对应 CAWT。

VB entry 在 W 最后一拍交给 EBIU 后即可复用；片外 B 的长期 outstanding 状态
不留在两项 VB 中，而转移到 EBIU 的 32 项 CAWT。由此不能把“VB 空”解释为
“所有写已经获得片外 B 响应”。

`ebiu_vb_bvalid` 的名字容易造成误解。它不是片外 B：EBIU 在接受 VB 最后一个
W beat 后的下一拍本地产生该脉冲，`ebiu_vb_bresp` 固定为 OKAY，ID 取自
`vb_ebiu_wid`。VB 又把 `vb_ebiu_b_grant` 固定为 1，并不使用输入的
`ebiu_vb_bvalid/bid/bresp` 更新任何 entry。真实片外错误只进入 EBIU 的
BFIFO/CAWT 跟踪，不会通过这条本地脉冲回写已释放的 VB。

### 9.3 512-bit line 如何变成 128-bit beats

W 内容包含四个 128-bit data quad、16-bit strobe、ID 和控制位。输出选择为：

```verilog
assign wdata_sel =
       vb_w_pop_bus[INCR1] ? vb_w_pop_offset : wdata_cnt;
assign ebiu_wlast =
       vb_w_pop_bus[INCR1] ? 1'b1 : (wdata_cnt == 2'b11);
```

- `INCR1=1`：只输出由地址 `[5:4]` 指定的一个 128-bit quad，单拍即 last；
- `INCR1=0`：`wdata_cnt` 从 0 到 3，输出完整四拍 64B line。

因此不能无条件写成“每笔 VB 都固定四拍”。

### 9.4 写数据顺序

VB 有独立 AW 请求指针和 W pop 指针。它按 entry 环形顺序把 AW 发给 EBIU，
也按同一分配顺序等待并发送 W。若队头 entry 的 W 还没到，后面的 W 即使已到
也不能越过，这保持 AW/W 对应关系，但也意味着前项数据迟到会形成 head-of-line
blocking。

---

## 10. VB 与 EBIU 的地址依赖

每个有效 VB entry 比较：

```verilog
ebiuif_vb_index[7:0] == vb_aw_bus[13:6]
```

汇总为：

```verilog
assign vb_ebiuif_addr_depd = |vb_snb_addr_hit[1:0];
```

EBIUIF 用它阻止有冲突的相干内存读发给 EBIU：

```verilog
assign ebiuif_ebiu_arvalid =
       ebiu_rd_req & !vb_ebiuif_addr_depd;
```

比较只使用 PA `[13:6]`，即 64B line 的低 8 位索引，没有比较高位 tag。因此：

- 相同低索引一定被串行；
- 不同高位但低索引相同的地址也会保守地被判冲突；
- 这是减少比较器面积的保守依赖检查，不是完整物理地址比较。

VB 还保留了用同样 `[13:6]` 比较阻止 SNB `snpext` 与尚未完成写重叠的路径。
当前外部 snoop AC 被 dummy 禁用，所以该比较器存在但正常运行中没有有效
`snpext` 请求。文档应称“低索引相关/保守地址依赖”，不能称“精确同一 cache
line 比较”，也不能以比较器存在证明外部 snoop 已启用。

---

## 11. 时钟门控与当前 RTL 边界

CTCQ、reqq、respq、VB entry 都实例化 `gated_clk_cell`。从源码只能确定各处
提供了 `local_en` 和 `ciu_icg_en`；实际是否形成物理门控取决于
`gated_clk_cell` 的编译宏和综合实现：

- 通用非 ICG 分支中 `clk_out=clk_in`；
- DC filelist 定义 `C910_USE_TSMC28_ICG` 时才实例化工艺 ICG。

所以 RTL 文档可以解释“门控意图”和 enable 条件，但不能仅凭模块名断言某次
仿真已经降低动态功耗。

---

## 12. 波形观察建议

### 12.1 CTCQ

建议按以下逻辑链观察：

| 阶段 | 信号 |
|------|------|
| 来源请求 | `piuN_ctcq_ar_req`、`ebiuif_ctcq_acvalid` |
| 接收 | `ctc_dvm_sel`、`ctc_dvm_create_en`、`reqq_create_en` |
| 目标 | `ctc_dvm_aim[5:0]` |
| 派发 | `ctcq_piuN_acvalid`/`piuN_ctcq_ac_grant`、`ctcq_l2c_addr_req` |
| 完成 | `piuN_ctcq_cr_req`、`respq_*_resp_create_en`、`respq_vld` |
| 发起端响应 | `ctcq_piuN_rvalid`/`piuN_ctcq_r_grant` |
| 屏障排空 | `reqq_ctc_empty`、`respq_ctc_empty`、`sync_cur_state` |

判断“操作已完成”至少要看到对应 respq 的目标完成位全 1；只看到 AR grant、
AC grant 或发起端 R 返回都不充分。

### 12.2 VB

| 阶段 | 信号 |
|------|------|
| 来源请求 | `snbN_vb_awvalid`、`l2cN_vb_awvalid` |
| VB 分配 | `vb_aw_create_en`、`vb_aw_create_sel`、`vb_aw_vld[1:0]` |
| 数据到达 | `snbN_vb_wvalid`/`l2cN_vb_wvalid`、`vb_w_vld[1:0]` |
| EBIU 接收 AW | `vb_ebiu_awvalid && ebiu_vb_aw_grant` |
| EBIU 接收 W | `vb_ebiu_wvalid && ebiu_vb_w_grant` |
| entry 释放 | 上式且 `vb_ebiu_wlast` |
| 本地最后 W 确认 | `ebiu_vb_bvalid`；固定 OKAY，不是片外 B |
| 总线最终响应 | `pad_ebiu_bvalid && ebiu_pad_bready`、BFIFO BID、CAWT pop |

---

## 13. 设计结论

| 结构 | RTL 能确认的作用 | 不能直接推出的结论 |
|------|------------------|--------------------|
| CTCQ reqq×8 | 保存操作并按目标有序派发 | 不是 8 项 cache-line 数据缓冲 |
| CTCQ respq×16 | 用 ID 跟踪六目标完成 | 深 16 的具体性能动机未在 RTL 注释中证明 |
| `ctcq_mask_snb` | 两段 CTC 维护期间屏蔽 SNB AC | 不是任意 cache-to-cache 数据事务原子锁 |
| DVM FSM | 保留 operation/sync/barrier 排序结构 | 当前外部 AC dummy、`aim_ebiu=0`、CR/CD tie-off 且 `dvm_comp_arvalid=0`，不能宣称端到端外部 DVM 已启用 |
| VB×2 | 解耦来源 AW/W 与 EBIU，缓存最多一条 line/项 | VB 空不代表片外 B 全部返回 |
| `[13:6]` 依赖比较 | 保守阻止低索引冲突 | 不是完整 PA 精确比较 |
