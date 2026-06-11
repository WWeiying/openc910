/*
 * bench_ilp: instruction-level parallelism stress test
 *
 * Kernel : Pattern 1 - serial multiply chain (each op depends on previous,
 *                      MUL latency-bound, IPC << 1)
 *          Pattern 2 - 8 independent accumulators (high ILP, tests OoO
 *                      dispatch width and issue queue depth)
 *
 * Increasing ROB size or issue queue depth improves Pattern 2 IPC.
 * Key counters: event40(backend_stall), event22(RF_issued), IPC
 */

#define N 500

static volatile long sink;

int main(void) {
    long a, a0, a1, a2, a3, a4, a5, a6, a7;
    int i;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: serial multiply-add chain - latency-bound (MUL ~4 cycles) */
    a = 1L;
    for (i = 0; i < N; i++) {
        a = a * 3L + 7L;
        a = a * 3L + 7L;
        a = a * 3L + 7L;
        a = a * 3L + 7L;
    }
    sink = a;

    /* Pattern 2: 8 independent add accumulators - ILP-rich */
    a0 = 1L; a1 = 2L; a2 = 3L; a3 = 4L;
    a4 = 5L; a5 = 6L; a6 = 7L; a7 = 8L;
    for (i = 0; i < N; i++) {
        a0 += i; a1 += i; a2 += i; a3 += i;
        a4 += i; a5 += i; a6 += i; a7 += i;
    }
    sink = a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7;

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
