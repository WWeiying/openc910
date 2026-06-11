/*
 * bench_fp: floating-point pipeline stress test
 *
 * Warmup : initialize matrices with non-trivial values
 * Kernel : Pattern 1 - FP multiply-add dependent chain (latency-bound)
 *          Pattern 2 - double-precision matrix multiply (high FP ILP + memory)
 *
 * N=48 matrices: 3 * 48*48 * 8 = ~55 KB data, fits in 256 KB data region.
 * Key counters: event42(FP_inst), event40(backend_stall), IPC
 */

#define N  8
#define FP_CHAIN_ITER 500

static double A[N][N], B[N][N], C[N][N];
static volatile double sink;

int main(void) {
    int i, j, k, iter;
    double x;

    /* warmup: fill matrices */
    for (i = 0; i < N; i++)
        for (j = 0; j < N; j++) {
            A[i][j] = (double)(i * N + j + 1) * 0.001;
            B[i][j] = (double)(j * N + i + 1) * 0.001;
            C[i][j] = 0.0;
        }

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");

    /* Pattern 1: FP dependent chain - each fmadd waits for previous result */
    x = 1.0;
    for (iter = 0; iter < FP_CHAIN_ITER; iter++) {
        x = x * 1.0000003 + 0.0000001;
    }
    sink = x;

    /* Pattern 2: double-precision matrix multiply - high FP ILP */
    for (iter = 0; iter < 2; iter++) {
        for (i = 0; i < N; i++) {
            for (j = 0; j < N; j++) {
                double s = 0.0;
                for (k = 0; k < N; k++)
                    s += A[i][k] * B[k][j];
                C[i][j] = s;
            }
        }
    }
    sink = C[0][0];

    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
