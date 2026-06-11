/*
 * bench_branch: branch predictor stress test
 *
 * Warmup : regular alternating branches - warms up BTB/BHT
 * Kernel : Pattern 1 - LFSR-driven unpredictable branches (high misp rate)
 *          Pattern 2 - indirect calls via function pointer table (stresses Indirect BTB)
 *
 * Key counters: event6(cond_misp), event7(cond_total),
 *               event8(jmp_misp),  event9(jmp_total)
 */

#define N_WARMUP   200
#define N_KERNEL  1000

static volatile int sink;

/* 16-bit Galois LFSR - produces pseudo-random sequence */
static unsigned lfsr_state = 0xACE1u;
static inline unsigned lfsr_next(void) {
    unsigned bit = ((lfsr_state >> 0) ^ (lfsr_state >> 2) ^
                    (lfsr_state >> 3) ^ (lfsr_state >> 5)) & 1u;
    lfsr_state = (lfsr_state >> 1) | (bit << 15);
    return lfsr_state;
}

/* four distinct indirect-call targets */
static int f0(int x) { return x + 1; }
static int f1(int x) { return x - 1; }
static int f2(int x) { return x + 3; }
static int f3(int x) { return x - 3; }
typedef int (*fp_t)(int);
static const fp_t ftab[4] = {f0, f1, f2, f3};

int main(void) {
    int s, i;

    /* warmup: perfectly predictable alternating branch */
    s = 0;
    for (i = 0; i < N_WARMUP; i++) {
        if (i & 1) s += i; else s -= i;
    }
    sink = s;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: LFSR-driven unpredictable conditional branches */
    s = 0;
    for (i = 0; i < N_KERNEL; i++) {
        if (lfsr_next() & 1u) s += i;
        else                  s -= i;
    }
    sink = s;

    /* Pattern 2: indirect calls - 4 targets chosen pseudo-randomly */
    s = 0;
    for (i = 0; i < N_KERNEL / 4; i++) {
        s += ftab[lfsr_next() & 3u](i);
    }
    sink = s;

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
