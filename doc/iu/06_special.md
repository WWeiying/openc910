# C910 IU 特殊指令单元详解（ct_iu_special）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/iu/rtl/ct_iu_special.v`（664 行）
>
> 挂在 Pipe0，单拍执行（EX1）。处理"不适合放进 ALU 数据通路"的杂项指令：
> auipc、ecall/ebreak、译码期异常的占位 NOP、以及 RVV 的 vsetvl/vsetvli。
> 它是整数管线上**异常的主要入口**。

---

## 1. 指令集（ct_iu_special.v:226-232）

```verilog
parameter SPECIAL_NOP=5'b00000;  ECALL=5'b00010;  EBREAK=5'b00011;
          AUIPC=5'b00100;  PSEUDO_AUIPC=5'b00101;  VSETVLI=5'b00110;  VSETVL=5'b00111;
```

| func | 指令 | 做什么 |
|------|------|--------|
| NOP | 异常占位指令 | IDU 译码时已发现异常（非法指令/取指页错）的指令，转成 NOP 送来，由本模块把异常报给 RTU |
| ECALL/EBREAK | 系统调用/断点 | 不算结果，纯产生异常 |
| AUIPC | auipc rd,imm20 | rd = PC + (imm20<<12) |
| PSEUDO_AUIPC | 内部伪指令 | rd = PC + sext(imm20)，IDU 拆分长跳转/PC 相对寻址时生成 |
| VSETVLI/VSETVL | RVV 配置 | 算新 vl 并**校验 IFU 的 vsetvli 预译码预测** |

---

## 2. 逐逻辑块讲解

### 2.1 流水寄存器（L234-338）

与 ALU 同构（ctrl/inst 双时钟域），特别处在于锁存的内容：

```verilog
special_ex1_opcode[31:0] <= idu_iu_rf_pipe0_opcode;      // 原始指令码！
special_ex1_pc[39:0]     <= bju_special_pc[39:0];        // PC 来自 PCFIFO 读口 1
special_ex1_expt_vld/vec <= idu_iu_rf_pipe0_expt_*;      // IDU 译码期已发现的异常
special_ex1_pred_vl[7:0] <= idu_iu_rf_pipe0_vl;          // IFU 预译码预测的 vl
```

- **opcode 全 32 位带下来**：非法指令异常的 mtval 要回填原始指令码（L639-640），
  这是全 IU 唯一需要原始编码的地方；
- **PC 从 PCFIFO 拿**（`bju_special_pc`，见 03_bju_pcfifo.md 4.1 读口 1）：
  auipc 和链接计算需要 PC，而流水线里不传 PC——pid 间接寻址 PCFIFO 是统一方案。

### 2.2 AUIPC（L351-364）

```verilog
assign special_ex1_offset = pseudo_auipc ? sext(imm[19:0])        // 伪 auipc：未移位
                                         : sext(imm[19:0]) << 12; // 标准 auipc
assign special_ex1_pc_addend = mmu_xx_mmu_en ? sext(pc[39:0])     // 开 MMU：VA 符扩
                                             : zext(pc[39:0]);    // 物理模式：零扩
assign special_auipc_rslt = pc_addend + offset;
```

MMU 开关影响 PC 的高位语义（虚拟地址符号扩展 vs 物理地址零扩展），所以这里
要看 `mmu_xx_mmu_en`——一个容易被忽略的体系结构细节。

### 2.3 vsetvl/vsetvli：核心是"预测校验"（L366-570）

背景：C910 的 IFU 对 vsetvli 做了**预译码预测**——在取指阶段就猜出新 vl，
让后续向量指令不必等 vsetvli 执行完就能带着预测 vl 派遣（消除了 RVV 最讨厌的
配置串行化）。SPECIAL 在执行期负责**算出真值并验证预测**：

**算新 vl（L386-478）**：vl = min(AVL, VLMAX)，VLMAX 由 vsew/vlmul 决定
（C910 VLEN=128：如 sew=8,lmul=8 → VLMAX=128；sew=64,lmul=1 → VLMAX=2）。
实现上先并行算出 7 种 VLMAX 档位的结果 `vl_2/4/8/...The/128`（L403-423，
`avl >= VLMAX ? VLMAX : avl` 用前导或归约 `|avl[63:k]` 判断），再按
{vlmul,vsew} 16 路选择（L458-477）。`rs1=x0` 表示 AVL=无穷大，恒取 VLMAX
（L386-401 每档的 `|| rs1_x0`）。

**校验预测（L425-511）**：每档并行比较 `pred_vl != 真值`，同样 16 路选出
`special_ex1_vsetvl_vl_mispred`。

**异常/flush 判定（L544-556）**：

```verilog
assign special_ex1_vsetvlx_abnormal = inst_vsetvl            // vsetvl(寄存器源)永远 flush
    || inst_vsetvli && (vsetvl_illegal                       // 非法配置(vediv≠0/vsew>=100)
                     || vsetvl_vl_mispred                    // 预测错了
                     || cp0_iu_vill                          // 当前 vill 状态
                     || vl_modified_from_0                   // vl 从 0 变非 0
                     || cp0_iu_vsetvli_pre_decd_disable);    // 预译码被禁用
```

体系结构解读：
- **vsetvl（源自寄存器）无法预测**——vtype 在寄存器里取指期不可知，所以一律
  按"预测失败"处理（abnormal → RTU 在它退休时 flush 重取后续指令，此时 CP0
  的 vl/vtype 已更新，IFU 按新配置重新预译码）；
- **vsetvli（立即数 vtype）大概率预测对**：预测对则零开销直通，错了才付一次
  flush 代价；
- mtval 被借用来给 CP0 传递新配置（L558-564：打包 vl/vsew/vlmul/illegal/
  mispred 进 mtval[14:0]）——**RTU flush 时 CP0 从"异常值"通道拿到新 vtype**，
  省了一组专用总线。这是读 RTL 才能发现的"复用暗道"，看波形时注意 mtval
  不一定是异常地址。

**vstart 清零（L538-539）**：执行 vsetvl* 时若 vstart≠0 需要清零（RVV 规范），
通过 `special_cbus_ex1_vstart_vld/vstart=0` 走 CBUS 让 RTU 退休时更新。

### 2.4 异常生成（L572-646）—— 整数管线的异常入口

```verilog
// ecall 的异常号随特权级（L575-585）
case(cp0_yy_priv_mode) 2'b00:U=8; 2'b01:S=9; 2'b11:M=11;
// 异常有效（L612-615）
assign special_cbus_ex1_expt_vld = ecall || ebreak || (nop && expt_vld);
// mtval 三选一（L632-646）：非法指令→opcode；vsetvl→新配置包；其他→0
```

注意 **abnormal 与 expt_vld 的区别**（L589-594 vs L612-615）：
- `expt_vld`：真异常（ecall/ebreak/译码期异常），RTU 走 trap 流程；
- `abnormal`：包含异常 + **vsetvl flush + vstart 清零**——这些不是 trap，
  只是"退休时需要特殊处理（flush 或改 CSR）"。CBUS 的 `flush` 位（L598-599）
  进一步指明是"flush 型 abnormal"。

`immu_expt`（L627-631）标记取指侧 MMU 异常（expt_vec ∈ {0,1,12}：取指
access fault / 取指页错），RTU 处理这类异常时 mtval 应填 PC 而不是 opcode。

### 2.5 写回（L648-659）

```verilog
assign special_rbus_ex1_data_vld = inst_vld && (auipc || pseudo_auipc || vsetvli || vsetvl);
assign special_rbus_ex1_data = (vsetvli||vsetvl) ? {56'b0, vl} : auipc_rslt;
```

vsetvl* 的 rd 写回值就是新 vl（RVV 规范），ecall/ebreak/NOP 无写回。
数据走 RBUS 的 special ex1 通道（与 pipe0 ALU 共享写回口，见 08_rbus.md）。

---

## 3. 与 CP0 的关系辨析

容易混淆：**CSR 读写指令（csrrw 等）不在 SPECIAL 执行**，而是送 CP0 模块执行
3 拍（cp0_iu_ex3_* 接口回 IU，见 00 总览 3.5）。SPECIAL 只管 auipc/ecall/
ebreak/vsetvl* 这几个"一拍出结果或纯异常"的家伙。两者共享 pipe0 的发射端口
（`idu_iu_rf_special_sel` vs cp0 的 sel 由 IDU 区分）。

---

## 4. Verdi 观察建议

层次：`...x_ct_iu_top.x_ct_iu_special`

| 信号 | 看什么 |
|------|--------|
| `special_ex1_func[4:0]` | 当前特殊指令类型 |
| `special_cbus_ex1_expt_vld/expt_vec` | 异常注入瞬间（ecall=8/9/11, ebreak=3） |
| `special_ex1_vsetvl_vl_mispred` | vsetvli 预测失败 → 退休期会有 flush |
| `special_cbus_ex1_mtval` | 注意 vsetvl 时它装的是新配置不是地址 |
| `special_rbus_ex1_data_vld/data` | auipc/vsetvl 写回 |

跑 ISA/ISA_THEAD 或 rvv case 时观察 vsetvli 的预测命中：mispred=0 时管线
无任何扰动，mispred=1 时该指令退休后跟一次 `rtu_yy_xx_flush`。
