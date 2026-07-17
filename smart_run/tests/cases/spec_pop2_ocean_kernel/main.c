/*
 * SPECspeed 628.pop2_s representative kernel.
 *
 * This is not SPEC source code. It models the train-profile hot paths:
 * horizontal mixing, state updates, advection, baroclinic recurrence, and a
 * small iterative barotropic operator with periodic neighbor accesses.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_POP2_CELLS
#define SPEC_POP2_CELLS 64
#endif
#ifndef SPEC_POP2_STEPS
#define SPEC_POP2_STEPS 1
#endif
#ifndef SPEC_POP2_SOLVER_ITERS
#define SPEC_POP2_SOLVER_ITERS 3
#endif
#ifndef SPEC_POP2_DEPTH
#define SPEC_POP2_DEPTH 2
#endif

#define N SPEC_POP2_CELLS

static float temp[N];
static float salt[N];
static float uvel[N];
static float vvel[N];
static float pressure[N];
static float mix[N];
static float work[N];
static volatile uint32_t checksum;

static int prev_index(int i)
{
    return i == 0 ? N - 1 : i - 1;
}

static int next_index(int i)
{
    return i + 1 == N ? 0 : i + 1;
}

static uint32_t fold_float(float value)
{
    int32_t scaled = (int32_t)(value * 4096.0f);
    return (uint32_t)scaled ^ ((uint32_t)scaled << 9) ^ ((uint32_t)scaled >> 7);
}

static void init_state(void)
{
    for (int i = 0; i < N; i++) {
        temp[i] = 0.5f + (float)((i * 13 + 7) & 63) * 0.0078125f;
        salt[i] = 0.75f + (float)((i * 5 + 11) & 31) * 0.00390625f;
        uvel[i] = (float)((i * 3 + 1) & 15) * 0.015625f;
        vvel[i] = (float)((i * 7 + 2) & 15) * 0.015625f;
        pressure[i] = temp[i] * 0.25f + salt[i] * 0.5f;
        mix[i] = 0.0f;
        work[i] = 0.0f;
    }
}

static void state_update(void)
{
    for (int i = 0; i < N; i++) {
        float density = 1.0f + salt[i] * 0.0625f - temp[i] * 0.03125f;
        pressure[i] = pressure[i] * 0.875f + density * 0.125f;
    }
}

static void horizontal_mix(void)
{
    for (int i = 0; i < N; i++) {
        int left = prev_index(i);
        int right = next_index(i);
        float lap_u = uvel[left] - 2.0f * uvel[i] + uvel[right];
        float lap_v = vvel[left] - 2.0f * vvel[i] + vvel[right];
        float shear = (uvel[right] - uvel[left]) * (vvel[right] - vvel[left]);
        mix[i] = 0.1875f * lap_u + 0.125f * lap_v + 0.03125f * shear;
    }
}

static void advect_tracers(void)
{
    for (int i = 0; i < N; i++) {
        int left = prev_index(i);
        int right = next_index(i);
        float flux_t = uvel[i] * (temp[right] - temp[left]);
        float flux_s = vvel[i] * (salt[right] - salt[left]);
        work[i] = temp[i] - 0.0625f * flux_t + mix[i];
        pressure[i] += salt[i] - 0.046875f * flux_s;
    }
    for (int i = 0; i < N; i++) {
        temp[i] = work[i];
        salt[i] = pressure[i] * 0.03125f + salt[i] * 0.96875f;
    }
}

static void barotropic_solve(void)
{
    for (int iter = 0; iter < SPEC_POP2_SOLVER_ITERS; iter++) {
        for (int i = 0; i < N; i++) {
            int left = prev_index(i);
            int right = next_index(i);
            float op = pressure[left] + pressure[right] - 2.0f * pressure[i];
            work[i] = pressure[i] + 0.15625f * op - 0.03125f * mix[i];
        }
        for (int i = 0; i < N; i++)
            pressure[i] = work[i];
    }
}

static uint32_t ocean_state_phase(void)
{
    uint32_t acc = 0x6282017u;
    for (int step = 0; step < SPEC_POP2_STEPS; step++) {
        state_update();
        horizontal_mix();
        for (int i = 0; i < N; i++) {
            uvel[i] += mix[i] * 0.0625f - pressure[i] * 0.00390625f;
            vvel[i] -= mix[i] * 0.046875f + temp[i] * 0.001953125f;
            acc ^= fold_float(uvel[i] + vvel[i] + pressure[i]);
        }
    }
    return acc;
}

static uint32_t advection_phase(void)
{
    uint32_t acc = 0x628ad6u;
    for (int depth = 0; depth < SPEC_POP2_DEPTH; depth++) {
        horizontal_mix();
        advect_tracers();
    }
    for (int i = 0; i < N; i++)
        acc ^= fold_float(temp[i] + salt[i]);
    return acc;
}

static uint32_t solver_halo_phase(void)
{
    uint32_t acc = 0x628501u;
    barotropic_solve();
    for (int i = 0; i < N; i++)
        acc = (acc << 5) ^ (acc >> 3) ^ fold_float(pressure[i]);
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_state();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");
    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < 62 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= ocean_state_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < 4 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= advection_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    SPEC_COMPOSITION_PHASE2_BEGIN();
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++)
        checksum ^= solver_halo_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE2_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_pop2_ocean_kernel config cells=%u steps=%u solver=%u depth=%u\n",
           (unsigned int)N, (unsigned int)SPEC_POP2_STEPS,
           (unsigned int)SPEC_POP2_SOLVER_ITERS, (unsigned int)SPEC_POP2_DEPTH);
    printf("spec_pop2_ocean_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
