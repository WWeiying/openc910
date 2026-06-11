/*
 * bench_br_corr: correlated branch (global history) stress test
 *
 * Tests the global history register (GHR) mechanism of C910's Bi-Mode BHT.
 * Branch outcomes that are correlated with recent history can be predicted
 * accurately by a GHR-indexed predictor but not by a per-branch counter alone.
 *
 *   Pattern 1 - history-independent : each branch outcome is random (LFSR),
 *               no correlation with other branches → GHR provides no benefit
 *
 *   Pattern 2 - history-correlated  : if Branch A was taken, Branch B is
 *               almost always taken too (same condition applied twice).
 *               A GHR-indexed predictor can learn this correlation.
 *
 *   Pattern 3 - stride-correlated   : a sequence of branches where the
 *               i-th branch is taken iff (i % 8 < 6).  The GHR captures
 *               the "position within the period" and predicts correctly.
 *
 * Key counters: event6(cond_misp), event7(cond_total)
 * Expected: Pattern 2 & 3 show lower misp% than Pattern 1 because GHR helps.
 */

#define N 500

static volatile int sink;

/* LFSR for Pattern 1 random data */
static unsigned lfsr = 0xFACEu;
static inline unsigned lfsr_next(void) {
    unsigned bit = ((lfsr>>0)^(lfsr>>2)^(lfsr>>3)^(lfsr>>5)) & 1u;
    lfsr = (lfsr >> 1) | (bit << 15);
    return lfsr;
}

int main(void) {
    int i, s;
    unsigned r;

    /* warmup */
    s = 0;
    for (i = 0; i < 200; i++) s += i & 1;
    sink = s;

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: independent random branches - GHR cannot help */
    s = 0;
    for (i = 0; i < N; i++) {
        r = lfsr_next();
        if (r & 1u) s += i;         /* random, no history correlation */
        if (r & 2u) s -= i;         /* independent of first branch */
    }
    sink = s;

    /* Pattern 2: correlated pair - both branches use same condition.
     * A GHR-aware predictor: after seeing Branch A taken, it predicts
     * Branch B taken, which is correct.  */
    s = 0;
    for (i = 0; i < N; i++) {
        int cond = (i & 3) != 3;    /* taken 3/4 of the time, predictable pattern */
        if (cond) s += i;           /* Branch A */
        if (cond) s += i >> 1;      /* Branch B: perfectly correlated with A */
    }
    sink = s;

    /* Pattern 3: stride-correlated sequence.
     * Taken for positions 0..5 within each 8-element window, not-taken at 6,7.
     * GHR encodes position-in-window, enabling prediction.  */
    s = 0;
    for (i = 0; i < N; i++) {
        if ((i & 7) < 6) s += i;   /* taken 6/8 of the time, period-8 pattern */
        if ((i & 7) < 4) s -= i;   /* different threshold, same period */
    }
    sink = s;

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
