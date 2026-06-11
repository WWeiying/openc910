/*
 * bench_cache_cap: L1D cache capacity boundary test
 *
 * Sweeps working-set size across the L1D capacity boundary.
 * C910 L1D is 32 KB, 2-way associative, 64-byte cache lines.
 *
 *   Pattern 1 - 8 KB  working set  (1/4 of L1D) : fits entirely, misp ≈ 0%
 *   Pattern 2 - 32 KB working set  (= L1D size)  : marginal fit, moderate miss
 *   Pattern 3 - 128 KB working set (4× L1D)      : overflows, high miss rate
 *
 * Sequential scan with multiple passes so the steady-state miss rate is
 * clearly visible (first-pass cold misses amortized over many passes).
 *
 * Key counters: event12(ld_access), event13(ld_miss),
 *               event14(st_access), event15(st_miss)
 * Expected: miss rate increases sharply from Pattern 1 → 2 → 3.
 */

#define KB   1024
/* PASS sized so each pattern stays under ~2M cycles.
 * Cache miss penalty ~75 cycles; 32KB L1D; miss rate rises with working set. */
#define PASS_SMALL  16   /*  8 KB fits in L1D, all hits after warm: fast */
#define PASS_MED     4   /* 32 KB = L1D boundary, partial misses */
#define PASS_LARGE   2   /* 64 KB = 2x L1D, capacity misses dominate */

#define SZ_SMALL  (  8 * KB / 4)   /*  8 KB  = 2048 ints */
#define SZ_MED    ( 32 * KB / 4)   /* 32 KB  = 8192 ints */
#define SZ_LARGE  ( 64 * KB / 4)   /* 64 KB  = 16384 ints (2x L1D) */

static int small_arr[SZ_SMALL];
static int med_arr[SZ_MED];
static int large_arr[SZ_LARGE];

static volatile int sink;

static void scan(int *arr, int n, int passes) {
    int p, i;
    for (p = 0; p < passes; p++)
        for (i = 0; i < n; i++)
            arr[i] = arr[i] + 1;
}

int main(void) {
    int i;

    /* initialize */
    for (i = 0; i < SZ_LARGE; i++) large_arr[i] = i;
    for (i = 0; i < SZ_MED;   i++) med_arr[i]   = i;
    for (i = 0; i < SZ_SMALL; i++) small_arr[i]  = i;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: 8 KB - fits in L1D, cache hits dominate */
    scan(small_arr, SZ_SMALL, PASS_SMALL);
    sink = small_arr[0];

    /* Pattern 2: 32 KB - at L1D capacity boundary */
    scan(med_arr, SZ_MED, PASS_MED);
    sink = med_arr[0];

    /* Pattern 3: 64 KB - 2x L1D, capacity misses dominate */
    scan(large_arr, SZ_LARGE, PASS_LARGE);
    sink = large_arr[0];

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
