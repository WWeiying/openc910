/*
 * spec_lbm_stream_kernel: LBM-like streaming memory kernel.
 *
 * This is not SPEC lbm source code. It models 519.lbm_r style D3Q19
 * collide/stream updates with regular memory bandwidth pressure.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_LBM_CELLS
#define SPEC_LBM_CELLS 24
#endif

#ifndef SPEC_LBM_STEPS
#define SPEC_LBM_STEPS 1
#endif

#ifndef SPEC_LBM_Q
#define SPEC_LBM_Q 19
#endif

#define CELLS SPEC_LBM_CELLS
#define STEPS SPEC_LBM_STEPS
#define Q SPEC_LBM_Q

static float src[CELLS][Q];
static float dst[CELLS][Q];
static uint8_t obstacle[CELLS];
static volatile uint32_t checksum;

static void init_lbm(void)
{
    for (int i = 0; i < CELLS; i++) {
        obstacle[i] = (uint8_t)(((i * 17 + 3) & 31) == 0);
        for (int q = 0; q < Q; q++) {
            src[i][q] = (float)((i * 7 + q * 13) & 63) * 0.015625f;
            dst[i][q] = 0.0f;
        }
    }
}

static uint32_t fold_float(float x)
{
    int32_t v = (int32_t)(x * 4096.0f);
    return (uint32_t)v ^ ((uint32_t)v << 11);
}

static int neighbor(int i, int q)
{
    static const int off[19] = {
        0, 1, -1, 4, -4, 8, -8, 9, -9, 7,
        -7, 5, -5, 3, -3, 12, -12, 16, -16
    };
    int n = i + off[q % 19];
    if (n < 0)
        n += CELLS;
    if (n >= CELLS)
        n -= CELLS;
    return n;
}

static uint32_t stream_collide_phase(void)
{
    uint32_t acc = 0x5192017u;

    for (int step = 0; step < STEPS; step++) {
        for (int i = 0; i < CELLS; i++) {
            float rho = 0.0f;
            float ux = 0.0f;
            float uy = 0.0f;

            for (int q = 0; q < Q; q++) {
                float f = src[i][q];
                rho += f;
                ux += f * (float)((q & 3) - 1);
                uy += f * (float)(((q >> 2) & 3) - 1);
            }

            float inv = 1.0f / (rho + 0.25f);
            ux *= inv;
            uy *= inv;

            for (int q = 0; q < Q; q++) {
                int n = neighbor(i, q);
                float eq = rho * (0.05263158f + 0.015625f * (ux + uy) * (float)((q & 7) - 3));
                float out = src[i][q] + 1.75f * (eq - src[i][q]);
                if (obstacle[i])
                    out = src[i][(Q - q) % Q];
                dst[n][q] = out;
                acc ^= fold_float(out) + (uint32_t)(n * 19 + q);
            }
        }

    }

    return acc;
}

static uint32_t grid_swap_phase(void)
{
    uint32_t acc = 0x5195a9u;

    for (int i = 0; i < CELLS; i++) {
        for (int q = 0; q < Q; q++) {
            src[i][q] = dst[i][q];
            acc = (acc << 3) ^ (acc >> 7) ^ fold_float(src[i][q]);
        }
    }
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_lbm();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < 5 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= stream_collide_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < 6 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= grid_swap_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_lbm_stream_kernel config cells=%u steps=%u q=%u\n",
           (unsigned int)CELLS, (unsigned int)STEPS, (unsigned int)Q);
    printf("spec_lbm_stream_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
