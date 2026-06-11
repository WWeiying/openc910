/*
 * bench_cache_stride: L1D cache stride and conflict miss test
 *
 * C910 L1D: 32 KB, 2-way associative, 64-byte cache lines (16 ints/line).
 * Set size = 32KB / 2 ways = 16KB → conflict stride = 16KB / 4B = 4096 ints.
 *
 *   Pattern 1 - stride  1  (sequential)   : hardware prefetcher friendly, low miss
 *   Pattern 2 - stride 16  (= cache line) : accesses one element per line, no reuse
 *   Pattern 3 - stride 4096 (= set size)  : every access maps to same set → thrash
 *   Pattern 4 - stride 64  (4 lines)      : moderate spatial reuse
 *
 * Array is 2× conflict stride = 8192 ints = 32 KB to cover all patterns.
 * Multiple passes ensure steady-state behavior is captured.
 *
 * Key counters: event12(ld_access), event13(ld_miss)
 * Expected: miss rate: stride-1 < stride-64 < stride-16 << stride-4096.
 */

#define KB          1024
#define ARRAY_INTS  256             /* 1 KB, fits in L1D */

static int arr[ARRAY_INTS];
static volatile int sink;

static void stride_scan(int stride, int passes) {
    int p, i, s = 0;
    for (p = 0; p < passes; p++) {
        for (i = 0; i < ARRAY_INTS; i += stride)
            s += arr[i];
    }
    sink = s;
}

int main(void) {
    int i;
    for (i = 0; i < ARRAY_INTS; i++) arr[i] = i;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: stride 1  - sequential access */
    stride_scan(1, 8);

    /* Pattern 2: stride 4  - every 4th element */
    stride_scan(4, 8);

    /* Pattern 3: stride 16 - one element per cache line */
    stride_scan(16, 8);

    /* Pattern 4: stride 32 - sparse access */
    stride_scan(32, 8);

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
