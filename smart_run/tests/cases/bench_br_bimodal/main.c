/*
 * bench_br_bimodal: BHT 2-bit saturating counter stress test
 *
 * Each pattern exercises a different state-transition regime of the
 * Bi-Mode predictor used in C910:
 *
 *   Pattern 1 - always-taken         : counter → ST,  misp ≈ 0%  after warmup
 *   Pattern 2 - always-not-taken     : counter → SN,  misp ≈ 0%  after warmup
 *   Pattern 3 - perfect alternating  : counter oscillates WN↔WT, misp ≈ 100%
 *   Pattern 4 - biased 7T/1NT        : counter mostly ST,  rare misp at NT
 *   Pattern 5 - biased 3T/1NT        : counter oscillates more,  higher misp
 *
 * All patterns use runtime-loaded data arrays (volatile) so the compiler
 * cannot eliminate the branch or constant-fold the condition.
 *
 * Key counters: event6(cond_misp), event7(cond_total)
 * Expected: misp% dramatically differs across patterns.
 */

#define N 500

/* branch direction tables - volatile prevents compile-time branch elimination */
static volatile int taken     = 1;
static volatile int not_taken = 0;

static const int alt[2]       = {1, 0};           /* T NT T NT ... */
static const int biased7[8]   = {1,1,1,1,1,1,1,0}; /* 7T 1NT */
static const int biased3[4]   = {1,1,1,0};          /* 3T 1NT */

static volatile int sink;

int main(void) {
    int i, s;

    /* warmup: always-taken loop to prime BTB/L0BTB */
    s = 0;
    for (i = 0; i < 50000; i++) {
        if (taken) s += i;
    }
    sink = s;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: always taken - predictor should saturate to ST */
    s = 0;
    for (i = 0; i < N; i++) {
        if (taken) s += i;
    }
    sink = s;

    /* Pattern 2: always not-taken - predictor saturates to SN */
    s = 0;
    for (i = 0; i < N; i++) {
        if (not_taken) s += i;
    }
    sink = s;

    /* Pattern 3: alternating T/NT - 2-bit counter cannot predict, ~100% misp */
    s = 0;
    for (i = 0; i < N; i++) {
        if (alt[i & 1]) s += i;
    }
    sink = s;

    /* Pattern 4: 7T/1NT - strong bias, counter mostly ST, rare misp */
    s = 0;
    for (i = 0; i < N; i++) {
        if (biased7[i & 7]) s += i;
    }
    sink = s;

    /* Pattern 5: 3T/1NT - weaker bias, more oscillation */
    s = 0;
    for (i = 0; i < N; i++) {
        if (biased3[i & 3]) s += i;
    }
    sink = s;

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
