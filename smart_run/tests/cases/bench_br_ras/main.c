/*
 * bench_br_ras: Return Address Stack (RAS) depth stress test
 *
 * C910 RAS has 16 entries.  When recursion depth <= 16, every return address
 * is correctly predicted.  When depth > 16, the oldest entries are pushed
 * out and the corresponding returns are mispredicted.
 *
 *   Pattern 1 - depth  8  (well within 16): returns all predicted, misp ≈ 0
 *   Pattern 2 - depth 32  (overflows by 16): ~16 misp per call chain
 *   Pattern 3 - depth  1  (leaf calls, RAS trivially correct): misp ≈ 0
 *
 * __attribute__((noinline)) prevents inlining and tail-call elimination,
 * ensuring each call actually pushes a return address onto the hardware RAS.
 * The volatile write inside the recursive body prevents tail-call optimization.
 *
 * Key counters: event8(jmp_misp), event9(jmp_total)
 * Expected: Pattern 2 shows significantly higher jmp_misp than Patterns 1 & 3.
 */

#define ITER        20
#define DEPTH_SHALLOW  8
#define DEPTH_DEEP    32
#define DEPTH_LEAF     1

static volatile long sink;

__attribute__((noinline))
static long recurse(int depth) {
    if (depth <= 0) {
        return 1L;
    }
    /* volatile write breaks tail-call optimization: compiler must emit a real call */
    sink = depth;
    return recurse(depth - 1) + (long)depth;
}

int main(void) {
    long acc;
    int i;

    /* warmup: shallow recursion to prime RAS */
    acc = 0;
    for (i = 0; i < 5; i++) acc += recurse(DEPTH_SHALLOW);
    sink = acc;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: depth 8 - all return addresses fit in 16-entry RAS */
    acc = 0;
    for (i = 0; i < ITER; i++) acc += recurse(DEPTH_SHALLOW);
    sink = acc;

    /* Pattern 2: depth 32 - overflows 16-entry RAS by 16 levels */
    acc = 0;
    for (i = 0; i < ITER; i++) acc += recurse(DEPTH_DEEP);
    sink = acc;

    /* Pattern 3: depth 1 - single-level call, RAS trivially correct */
    acc = 0;
    for (i = 0; i < ITER; i++) acc += recurse(DEPTH_LEAF);
    sink = acc;

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
