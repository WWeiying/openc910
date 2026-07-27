# C910 RTU 公共组件：IID 比较与编码转换

> RTL 源文件（均在 `C910_RTL_FACTORY/gen_rtl/rtu/rtl/`）：
> - `ct_rtu_compare_iid.v`（82 行）—— 环形 IID 年龄比较
> - `ct_rtu_encode_8/32/64/96.v` —— 独热 → 二进制
> - `ct_rtu_expand_8/32/64/96.v` —— 二进制 → 独热
>
> 这些小模块被全核引用（BJU、PCFIFO、ROB、PST、RBUS……），10 分钟读完，
> 终身受用。

---

## 1. ct_rtu_compare_iid：环形空间的年龄裁判

### 1.1 问题

IID = {1 位 wrap, 6 位 ROB 索引}，分配指针环形递增。"谁更老"不能直接比大小：
wrap 翻转后，数值小的反而更新。

### 1.2 实现（compare_iid.v:42-78）

```verilog
assign iid_msb_mismatch = x_iid0[6] ^ x_iid1[6];          // wrap 是否同圈

// 低 6 位逐位"谁在更高位先胜出"——这是一个展开的无符号比较器
assign iid0_larger[k] = x_iid0[k] && !x_iid1[k];
assign iid0_5_0_larger = iid0_larger[5]
                      || iid0_larger[4] && !iid1_larger[5]
                      || ...;                              // 高位优先

assign x_iid0_older = !iid_msb_mismatch && iid1_5_0_larger   // 同圈: 小者老
                   ||  iid_msb_mismatch && iid0_5_0_larger;  // 异圈: 大者老
```

规则一句话：**同圈比大小（小=老），异圈反着比（大=老）**。

正确性前提：两个有效 IID 的距离 < 64（在飞指令不超 ROB 容量），保证 wrap
位至多差一圈。这由 ROB full 反压结构性保证。

为什么不用 `(iid0 - iid1)` 的符号位判断？功能等价，但减法器有进位链；
这里的展开形式是纯组合的 6 级 AND-OR，对综合更友好（且这模块实在被例化得
太多——BJU 2 个、rob_expt 10 个、retire/lsu 还有一批）。

### 1.3 全核引用点

| 引用处 | 用途 |
|--------|------|
| BJU（doc/iu/02 §2.1） | RF 级判断新分支是否比未决误预测老 |
| rob_expt（doc/rtu/03 §2.1） | 异常擂台 5 路两两比较 |
| rob_expt split ssf | 拆分组 spec fail 最老者 |
| LSU lq/sq | load/store 顺序违例检查（doc/lsu/） |

## 2. encode / expand：两种编码的互换

```
expand_N : log2(N) 位二进制 → N 位独热    （译码器）
encode_N : N 位独热 → log2(N) 位二进制    （编码器）
```

C910 在指针/标识上**两种编码并存、按消费场景选用**：

| 场景 | 用哪种 | 原因 |
|------|--------|------|
| 环形指针步进 | 独热 | 移位即 +1，无进位链（PCFIFO/ROB 的 create/pop ptr） |
| 读/写口选择 | 独热 | 直接当 case 选择子或 AND 使能，零译码 |
| 做加法（iid+n、assign ptr） | 二进制 | 加法器天生吃二进制 |
| 跨模块传输 | 二进制 | 7 位比 96 位省线 |
| 唤醒/写使能位图 | 独热 | 每个比较点一位（RBUS 的 preg_expand[95:0]） |

转换点的摆放原则是**"在打拍前转换"**：如 RBUS 把 7 位 preg 在 EX1 末展开成
96 位锁存（doc/iu/08 §2.3），PCFIFO 在 RF 级把 pid 展开（doc/iu/02 §2.7）——
转换逻辑塞进时序富裕的一拍，消费拍直接用。

宽度家族对应资源：8（管线数）、32（PCFIFO/逻辑寄存器/ereg）、
64（ROB/vreg）、96（整数 preg）。

## 3. 一个小练习

读懂这两个模块后，回头看 rob.v:4334-4360 的这段：

```verilog
rob_create0_ptr <= {rob_create0_ptr[59:0], rob_create0_ptr[63:60]};  // 独热 +4
rob_create0_iid <= rob_create0_iid + 7'd4;                            // 二进制 +4
```

同一个逻辑指针的两种化身在同拍同步前进——这就是 C910 指针体系的全部秘密。
