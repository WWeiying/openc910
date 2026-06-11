/*
 * bench_br_indirect: Indirect BTB capacity and prediction accuracy test
 *
 * C910 Indirect BTB has 256 entries indexed by a 4-segment XOR-folded
 * path history.  This benchmark varies the number of unique call targets
 * to probe capacity and aliasing behavior.
 *
 *   Pattern 1 -  4 targets, fixed round-robin  : predictor learns quickly, low misp
 *   Pattern 2 -  4 targets, LFSR-random order  : harder (path history varies)
 *   Pattern 3 - 64 targets, LFSR-random order  : stresses Indirect BTB capacity
 *
 * Each target is noinline with a unique body (x^N) to prevent linker merging.
 *
 * Key counters: event8(jmp_misp), event9(jmp_total)
 * Expected: misp increases from Pattern 1 → 2 → 3.
 */

#define N_ITER 200

/* single-literal macro: F(N) produces function fN - token-pasting works */
#define F(n) __attribute__((noinline)) static int f##n(int x){return x^(n);}

F(0)  F(1)  F(2)  F(3)  F(4)  F(5)  F(6)  F(7)
F(8)  F(9)  F(10) F(11) F(12) F(13) F(14) F(15)
F(16) F(17) F(18) F(19) F(20) F(21) F(22) F(23)
F(24) F(25) F(26) F(27) F(28) F(29) F(30) F(31)
F(32) F(33) F(34) F(35) F(36) F(37) F(38) F(39)
F(40) F(41) F(42) F(43) F(44) F(45) F(46) F(47)
F(48) F(49) F(50) F(51) F(52) F(53) F(54) F(55)
F(56) F(57) F(58) F(59) F(60) F(61) F(62) F(63)

typedef int (*fp_t)(int);

static const fp_t tab4[4] = {
    f0, f1, f2, f3
};

static const fp_t tab64[64] = {
    f0,  f1,  f2,  f3,  f4,  f5,  f6,  f7,
    f8,  f9,  f10, f11, f12, f13, f14, f15,
    f16, f17, f18, f19, f20, f21, f22, f23,
    f24, f25, f26, f27, f28, f29, f30, f31,
    f32, f33, f34, f35, f36, f37, f38, f39,
    f40, f41, f42, f43, f44, f45, f46, f47,
    f48, f49, f50, f51, f52, f53, f54, f55,
    f56, f57, f58, f59, f60, f61, f62, f63
};

static volatile int sink;

static unsigned lfsr = 0xBEEFu;
static inline unsigned lfsr_next(void) {
    unsigned bit = ((lfsr>>0)^(lfsr>>2)^(lfsr>>3)^(lfsr>>5)) & 1u;
    lfsr = (lfsr >> 1) | (bit << 15);
    return lfsr;
}

int main(void) {
    int i, s;

    /* warmup */
    s = 0;
    for (i = 0; i < 20; i++) s += f0(i);
    sink = s;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: 4 targets, fixed round-robin - predictor learns quickly */
    s = 0;
    for (i = 0; i < N_ITER; i++)
        s += tab4[i & 3](i);
    sink = s;

    /* Pattern 2: 4 targets, LFSR-random - path history varies, harder */
    s = 0;
    for (i = 0; i < N_ITER; i++)
        s += tab4[lfsr_next() & 3u](i);
    sink = s;

    /* Pattern 3: 64 targets, LFSR-random - stresses Indirect BTB capacity */
    s = 0;
    for (i = 0; i < N_ITER; i++)
        s += tab64[lfsr_next() & 63u](i);
    sink = s;

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
