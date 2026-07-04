/*
 * spec_parest_sparse_kernel: parest-like sparse solver kernel.
 *
 * This is not SPEC parest source code. It models 510.parest_r style sparse
 * matrix-vector products, indirect memory access, and iterative solver updates.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_PAREST_N
#define SPEC_PAREST_N 48
#endif

#ifndef SPEC_PAREST_NNZ_PER_ROW
#define SPEC_PAREST_NNZ_PER_ROW 5
#endif

#ifndef SPEC_PAREST_ITERS
#define SPEC_PAREST_ITERS 3
#endif

#define N SPEC_PAREST_N
#define NZ SPEC_PAREST_NNZ_PER_ROW
#define ITERS SPEC_PAREST_ITERS
#define NNZ (N * NZ)

static uint16_t col[NNZ];
static float val[NNZ];
static float x[N];
static float r[N];
static float pvec[N];
static float y[N];
static volatile uint32_t checksum;

static void init_sparse(void)
{
    for (int i = 0; i < N; i++) {
        x[i] = (float)((i * 11) & 31) * 0.03125f;
        r[i] = 1.0f + (float)((i * 7) & 15) * 0.0625f;
        pvec[i] = r[i];
    }

    for (int i = 0; i < N; i++) {
        for (int k = 0; k < NZ; k++) {
            int idx = i * NZ + k;
            int c = (i + k * k + 3 * k + 1) % N;
            col[idx] = (uint16_t)c;
            val[idx] = (k == 0) ? 2.0f : (0.125f + (float)((i + k) & 7) * 0.015625f);
        }
    }
}

static uint32_t fold_float(float x)
{
    int32_t v = (int32_t)(x * 8192.0f);
    return (uint32_t)v ^ ((uint32_t)v >> 9);
}

static void spmv(const float *in, float *out)
{
    for (int i = 0; i < N; i++) {
        float sum = 0.0f;
        for (int k = 0; k < NZ; k++) {
            int idx = i * NZ + k;
            sum += val[idx] * in[col[idx]];
        }
        out[i] = sum;
    }
}

static uint32_t sparse_kernel(void)
{
    uint32_t acc = 0x5102017u;

    for (int it = 0; it < ITERS; it++) {
        spmv(pvec, y);

        float rr = 0.0f;
        float py = 0.0f;
        for (int i = 0; i < N; i++) {
            rr += r[i] * r[i];
            py += pvec[i] * y[i];
        }

        float alpha = rr / (py + 0.125f);
        float rr_new = 0.0f;
        for (int i = 0; i < N; i++) {
            x[i] += alpha * pvec[i];
            r[i] -= alpha * y[i];
            rr_new += r[i] * r[i];
            acc ^= fold_float(x[i] + r[i]) + (uint32_t)(i * 17 + it);
        }

        float beta = rr_new / (rr + 0.125f);
        for (int i = 0; i < N; i++) {
            if (((i + it) & 7) == 0)
                pvec[i] = r[i];
            else
                pvec[i] = r[i] + beta * pvec[i];
            acc = (acc << 4) ^ (acc >> 5) ^ fold_float(pvec[i]);
        }
    }

    return acc;
}

int main(void)
{
    init_sparse();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = sparse_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_parest_sparse_kernel config n=%u nnz_per_row=%u iters=%u\n",
           (unsigned int)N, (unsigned int)NZ, (unsigned int)ITERS);
    printf("spec_parest_sparse_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
