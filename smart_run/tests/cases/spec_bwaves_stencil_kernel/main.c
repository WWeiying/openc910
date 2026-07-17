/*
 * spec_bwaves_stencil_kernel: bwaves-like block solver kernel.
 *
 * This is not SPEC bwaves source code. It models the dominant 503.bwaves_r
 * test profile shape: matrix-vector products, Jacobian-like coefficient
 * updates, shell-style residual loops, and BiCGStab-like vector recurrences.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_BWAVES_CELLS
#define SPEC_BWAVES_CELLS 64
#endif

#ifndef SPEC_BWAVES_STEPS
#define SPEC_BWAVES_STEPS 1
#endif

#ifndef SPEC_BWAVES_RADIUS
#define SPEC_BWAVES_RADIUS 3
#endif

#ifndef SPEC_BWAVES_DEPTH
#define SPEC_BWAVES_DEPTH 2
#endif

#define N SPEC_BWAVES_CELLS
#define STEPS SPEC_BWAVES_STEPS
#define RADIUS SPEC_BWAVES_RADIUS
#define DEPTH SPEC_BWAVES_DEPTH
#define BAND (2 * RADIUS + 1)
#define NNZ (N * BAND)

static uint16_t col[NNZ];
static float jac[NNZ];
static float x[N];
static float bvec[N];
static float rvec[N];
static float rhat[N];
static float pvec[N];
static float vvec[N];
static float svec[N];
static float tvec[N];
static volatile uint32_t checksum;

static uint32_t fold_float(float x)
{
    int32_t v = (int32_t)(x * 8192.0f);
    return (uint32_t)v ^ ((uint32_t)v << 7) ^ ((uint32_t)v >> 11);
}

static void init_problem(void)
{
    for (int i = 0; i < N; i++) {
        float base = (float)((i * 17 + 31) & 255) * 0.00390625f;
        x[i] = 0.125f + base;
        bvec[i] = 0.75f + (float)((i * 7 + 3) & 63) * 0.0078125f;
        rvec[i] = bvec[i];
        rhat[i] = bvec[i] * 0.875f + 0.03125f;
        pvec[i] = rvec[i];
        vvec[i] = 0.0f;
        svec[i] = 0.0f;
        tvec[i] = 0.0f;
    }

    for (int i = 0; i < N; i++) {
        for (int k = 0; k < BAND; k++) {
            int off = k - RADIUS;
            int c = (i + off + N) % N;
            int idx = i * BAND + k;
            col[idx] = (uint16_t)c;
            if (off == 0)
                jac[idx] = 2.0f + (float)((i + DEPTH) & 7) * 0.015625f;
            else
                jac[idx] = -0.0625f / (float)((off < 0 ? -off : off) + 1);
        }
    }
}

static void update_jacobian(int step)
{
    for (int i = 0; i < N; i++) {
        float xi = x[i];
        float left = x[(i + N - 1) % N];
        float right = x[(i + 1) % N];
        float wave = right - 2.0f * xi + left;

        for (int k = 0; k < BAND; k++) {
            int idx = i * BAND + k;
            float scale = 0.0009765625f * (float)(((i + k + step) & 15) + 1);
            if (k == RADIUS)
                jac[idx] = 2.0f + 0.0625f * xi * xi + scale;
            else
                jac[idx] += wave * scale;
        }
    }
}

static void mat_times_vec(const float *in, float *out)
{
    for (int i = 0; i < N; i++) {
        float sum = 0.0f;
        for (int k = 0; k < BAND; k++) {
            int idx = i * BAND + k;
            sum += jac[idx] * in[col[idx]];
        }
        out[i] = sum;
    }
}

static float dot_product(const float *a, const float *b)
{
    float sum = 0.0f;
    for (int i = 0; i < N; i++)
        sum += a[i] * b[i];
    return sum;
}

static uint32_t matvec_phase(void)
{
    uint32_t acc = 0x5036d76u;

    for (int step = 0; step < STEPS; step++) {
        update_jacobian(step);
        mat_times_vec(x, vvec);
        for (int i = 0; i < N; i++)
            acc ^= fold_float(vvec[i]) + (uint32_t)(i * 17 + step);
        acc ^= fold_float(dot_product(x, vvec));
    }
    return acc;
}

static uint32_t bicg_recurrence_phase(void)
{
    uint32_t acc = 0x5032017u;
    float rho_old = 1.0f;
    float alpha = 1.0f;
    float omega = 1.0f;

    for (int step = 0; step < STEPS; step++) {
        for (int d = 0; d < DEPTH; d++) {
            float rho = dot_product(rhat, rvec) + 0.03125f;
            float beta = (rho / rho_old) * (alpha / omega);

            for (int i = 0; i < N; i++) {
                pvec[i] = rvec[i] + beta * (pvec[i] - omega * vvec[i]);
                acc ^= fold_float(pvec[i]) + (uint32_t)(i * 13 + d);
            }

            mat_times_vec(pvec, vvec);

            float denom = dot_product(rhat, vvec) + 0.03125f;
            alpha = rho / denom;

            for (int i = 0; i < N; i++)
                svec[i] = rvec[i] - alpha * vvec[i];

            mat_times_vec(svec, tvec);

            float tt = dot_product(tvec, tvec) + 0.03125f;
            omega = dot_product(tvec, svec) / tt;

            for (int i = 0; i < N; i++) {
                x[i] += alpha * pvec[i] + omega * svec[i];
                rvec[i] = svec[i] - omega * tvec[i];
                if (((i + d + step) & 7) == 0)
                    rvec[i] += (bvec[i] - x[i]) * 0.00390625f;
                acc = (acc << 5) ^ (acc >> 3) ^ fold_float(x[i] + rvec[i]);
            }

            rho_old = rho;
        }
    }

    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_problem();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < 14 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= matvec_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < 3 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= bicg_recurrence_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_bwaves_stencil_kernel config cells=%u steps=%u radius=%u depth=%u band=%u\n",
           (unsigned int)N, (unsigned int)STEPS, (unsigned int)RADIUS,
           (unsigned int)DEPTH, (unsigned int)BAND);
    printf("spec_bwaves_stencil_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
