/*
 * bench_frontend: IFU fetch bandwidth stress test
 *
 * Kernel : Pattern 1 - dense independent increments, maximizes fetch/decode
 *                      throughput (tests peak IPC close to 3-wide retire)
 *          Pattern 2 - many small taken branches, breaks sequential fetch
 *                      and stresses BTB capacity / redirect latency
 *
 * Key counters: event39(frontend_stall), event1(L1I_access),
 *               event2(L1I_miss), IPC
 */

#define N 500

static volatile long sink;

int main(void) {
    long a0, a1, a2, a3;
    int i, s;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: 16 independent increments per iteration
     * Maximizes fetch bandwidth - all ops are independent, no stalls from
     * data hazards; bottleneck moves to fetch/decode width */
    a0 = 0L; a1 = 0L; a2 = 0L; a3 = 0L;
    for (i = 0; i < N; i++) {
        a0++; a1++; a2++; a3++;
        a0++; a1++; a2++; a3++;
        a0++; a1++; a2++; a3++;
        a0++; a1++; a2++; a3++;
    }
    sink = a0 + a1 + a2 + a3;

    /* Pattern 2: dense taken branches - each small function called in
     * a chain stresses branch redirect and front-end refill latency */
    s = 0;
    for (i = 0; i < N; i++) {
        /* loop-carried branch every 2 instructions: high branch density */
        if (i & 1)  s += i;
        if (i & 2)  s -= i;
        if (i & 4)  s += 1;
        if (i & 8)  s -= 1;
    }
    sink += s;

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
