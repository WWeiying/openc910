/*
 * SPEC 549/649.fotonik3d representative FDTD kernel.
 *
 * This is not SPEC source code. It models electric/magnetic field updates,
 * material coefficients, UPML boundary work, and power-DFT accumulation.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_FOTONIK_CELLS
#define SPEC_FOTONIK_CELLS 64
#endif
#ifndef SPEC_FOTONIK_STEPS
#define SPEC_FOTONIK_STEPS 1
#endif
#ifndef SPEC_FOTONIK_RADIUS
#define SPEC_FOTONIK_RADIUS 3
#endif
#ifndef SPEC_FOTONIK_DEPTH
#define SPEC_FOTONIK_DEPTH 2
#endif

#define N SPEC_FOTONIK_CELLS

static float efield[N];
static float hfield[N];
static float material[N];
static float pml_e[N];
static float pml_h[N];
static float dft_real[N];
static float dft_imag[N];
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
    int32_t scaled = (int32_t)(value * 8192.0f);
    return (uint32_t)scaled ^ ((uint32_t)scaled << 7) ^ ((uint32_t)scaled >> 11);
}

static void init_fields(void)
{
    for (int i = 0; i < N; i++) {
        efield[i] = (float)((i * 13 + 1) & 63) * 0.0078125f;
        hfield[i] = (float)((i * 7 + 3) & 63) * 0.0078125f;
        material[i] = 0.75f + (float)((i * 5 + 9) & 31) * 0.00390625f;
        pml_e[i] = 0.0f;
        pml_h[i] = 0.0f;
        dft_real[i] = 0.0f;
        dft_imag[i] = 0.0f;
    }
}

static void update_h(void)
{
    for (int i = 0; i < N; i++) {
        float curl = efield[next_index(i)] - efield[i];
        hfield[i] += curl * (0.125f + material[i] * 0.03125f);
    }
}

static void update_e(void)
{
    for (int i = 0; i < N; i++) {
        float curl = hfield[i] - hfield[prev_index(i)];
        float nonlinear = efield[i] * efield[i] * 0.001953125f;
        efield[i] += material[i] * curl * 0.15625f - nonlinear;
    }
}

static void update_upml(void)
{
    int width = SPEC_FOTONIK_RADIUS + SPEC_FOTONIK_DEPTH;
    if (width * 2 > N)
        width = N / 2;
    for (int i = 0; i < width; i++) {
        int right = N - 1 - i;
        float damping = 0.015625f * (float)(width - i);
        pml_e[i] = pml_e[i] * 0.875f + efield[i] * damping;
        pml_h[i] = pml_h[i] * 0.875f + hfield[i] * damping;
        pml_e[right] = pml_e[right] * 0.875f + efield[right] * damping;
        pml_h[right] = pml_h[right] * 0.875f + hfield[right] * damping;
        efield[i] -= pml_e[i];
        hfield[i] -= pml_h[i];
        efield[right] -= pml_e[right];
        hfield[right] -= pml_h[right];
    }
}

static void accumulate_power_dft(int step)
{
    float phase_r = 1.0f - (float)(step & 7) * 0.03125f;
    float phase_i = (float)((step * 3 + 1) & 7) * 0.03125f;
    for (int i = 0; i < N; i++) {
        float power = efield[i] * efield[i] + hfield[i] * hfield[i];
        dft_real[i] += power * phase_r;
        dft_imag[i] += power * phase_i;
    }
}

static uint32_t electric_material_phase(void)
{
    uint32_t acc = 0x5492017u;
    for (int step = 0; step < SPEC_FOTONIK_STEPS; step++) {
        for (int depth = 0; depth < SPEC_FOTONIK_DEPTH; depth++) {
            update_e();
            update_upml();
        }
    }
    for (int i = 0; i < N; i++)
        acc = (acc << 5) ^ (acc >> 3) ^ fold_float(efield[i] + material[i]);
    return acc;
}

static uint32_t magnetic_update_phase(void)
{
    uint32_t acc = 0x5494a91u;
    for (int step = 0; step < SPEC_FOTONIK_STEPS; step++)
        for (int depth = 0; depth < SPEC_FOTONIK_DEPTH; depth++)
            update_h();
    for (int i = 0; i < N; i++)
        acc ^= fold_float(hfield[i]);
    return acc;
}

static uint32_t power_setup_phase(void)
{
    uint32_t acc = 0x549d17u;
    for (int step = 0; step < SPEC_FOTONIK_STEPS; step++)
        accumulate_power_dft(step);
    for (int i = 0; i < N; i++)
        acc = (acc << 5) ^ (acc >> 3) ^ fold_float(dft_real[i] + dft_imag[i]);
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_fields();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");
    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < 5 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= electric_material_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < 8 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= magnetic_update_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    SPEC_COMPOSITION_PHASE2_BEGIN();
    for (int round = 0; round < 15 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= power_setup_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE2_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_fotonik3d_stencil_kernel config cells=%u steps=%u pml=%u depth=%u\n",
           (unsigned int)N, (unsigned int)SPEC_FOTONIK_STEPS,
           (unsigned int)SPEC_FOTONIK_RADIUS, (unsigned int)SPEC_FOTONIK_DEPTH);
    printf("spec_fotonik3d_stencil_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
