/*
 * bench_mem: L1D cache stress test
 *
 * Warmup : initialize arrays and build shuffle index for pointer chasing
 * Kernel : Pattern 1 - sequential stream (cache-friendly, low miss rate)
 *          Pattern 2 - pointer chasing (random access, forces L1D misses)
 *
 * Array size (64 KB) exceeds typical 32 KB L1D to ensure cache pressure.
 * Key counters: event12(ld_access), event13(ld_miss),
 *               event14(st_access), event15(st_miss)
 */

#define ARRAY_SIZE  256     /* 256 * 4 bytes = 1 KB, fits in L1D */
#define STREAM_PASS 4

static int   arr[ARRAY_SIZE];
static int   next[ARRAY_SIZE];  /* precomputed shuffle for pointer chasing */

static volatile int sink;

/* LCG-based array shuffle (Fisher-Yates) - run before kernel */
static void build_shuffle(void) {
    int i, j, tmp;
    unsigned lcg = 0x12345678u;

    for (i = 0; i < ARRAY_SIZE; i++) next[i] = i;

    for (i = ARRAY_SIZE - 1; i > 0; i--) {
        lcg = lcg * 1664525u + 1013904223u;
        j = (int)((lcg >> 16) % (unsigned)(i + 1));
        tmp = next[i]; next[i] = next[j]; next[j] = tmp;
    }
}

int main(void) {
    int i, idx, pass;

    /* warmup: initialize data array and build shuffle */
    for (i = 0; i < ARRAY_SIZE; i++) arr[i] = i;
    build_shuffle();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: sequential stream - stride-1 read-modify-write */
    for (pass = 0; pass < STREAM_PASS; pass++) {
        for (i = 0; i < ARRAY_SIZE; i++)
            arr[i] = arr[i] + 1;
    }
    sink = arr[0];

    /* Pattern 2: pointer chasing - random access through shuffled index */
    idx = 0;
    for (i = 0; i < ARRAY_SIZE; i++) {
        idx = next[idx];
        sink += arr[idx];
    }

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
