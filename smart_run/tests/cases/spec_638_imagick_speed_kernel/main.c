#include <math.h>
#include <stdint.h>
#include <stdio.h>

#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_638_WIDTH
#define SPEC_638_WIDTH 12
#endif
#ifndef SPEC_638_HEIGHT
#define SPEC_638_HEIGHT 8
#endif
#ifndef SPEC_638_RESAMPLE_ROUNDS
#define SPEC_638_RESAMPLE_ROUNDS 4
#endif
#ifndef SPEC_638_COLOR_ROUNDS
#define SPEC_638_COLOR_ROUNDS 1
#endif
#ifndef SPEC_638_FILTER_ROUNDS
#define SPEC_638_FILTER_ROUNDS 1
#endif
#ifndef SPEC_638_RESAMPLE_EXTRA_ROUNDS
#define SPEC_638_RESAMPLE_EXTRA_ROUNDS 0
#endif
#ifndef SPEC_638_COLOR_EXTRA_ROUNDS
#define SPEC_638_COLOR_EXTRA_ROUNDS 0
#endif
#ifndef SPEC_638_FILTER_EXTRA_ROUNDS
#define SPEC_638_FILTER_EXTRA_ROUNDS 0
#endif

#define SPEC_638_PIXELS (SPEC_638_WIDTH * SPEC_638_HEIGHT)

#if SPEC_638_WIDTH < 4 || SPEC_638_HEIGHT < 4
#error "638.imagick proxy dimensions must both be at least four"
#endif

static float red[SPEC_638_PIXELS];
static float green[SPEC_638_PIXELS];
static float blue[SPEC_638_PIXELS];
static float scratch[SPEC_638_PIXELS];
static volatile uint32_t checksum;

static float clamp_unit(float value)
{
    if (value < 0.000244140625f)
        return 0.000244140625f;
    if (value > 0.999755859375f)
        return 0.999755859375f;
    return value;
}

static uint32_t fold_float(float value)
{
    union {
        float fp;
        uint32_t bits;
    } folded = {value};

    return folded.bits ^ (folded.bits << 7) ^ (folded.bits >> 11);
}

static void initialize_pixels(void)
{
    uint32_t state = 0x6382017u;

    for (int i = 0; i < SPEC_638_PIXELS; i++) {
        state ^= state << 13;
        state ^= state >> 17;
        state ^= state << 5;
        red[i] = (float)((state >> 8) & 1023u) * (1.0f / 1024.0f);
        green[i] = (float)((state >> 18) & 1023u) * (1.0f / 1024.0f);
        blue[i] = (float)((state ^ (state >> 10)) & 1023u) *
                  (1.0f / 1024.0f);
        scratch[i] = 0.0f;
    }
}

/*
 * Models DistortImage/ResamplePixelColor: coordinate generation, boundary
 * handling, four-neighbor gathers, and floating-point interpolation.
 */
__attribute__((noinline)) static uint32_t resample_phase(int rounds)
{
    uint32_t acc = 0x72657361u;

    for (int round = 0; round < rounds; round++) {
        for (int y = 0; y < SPEC_638_HEIGHT; y++) {
            for (int x = 0; x < SPEC_638_WIDTH; x++) {
                int sx = x + ((y + round) % 3) - 1;
                int sy = y + ((x + round) % 3) - 1;
                float fx = (float)((x * 5 + round * 3) & 7) * 0.125f;
                float fy = (float)((y * 3 + round * 5) & 7) * 0.125f;

                if (sx < 0)
                    sx = 0;
                else if (sx >= SPEC_638_WIDTH - 1)
                    sx = SPEC_638_WIDTH - 2;
                if (sy < 0)
                    sy = 0;
                else if (sy >= SPEC_638_HEIGHT - 1)
                    sy = SPEC_638_HEIGHT - 2;

                int p00 = sy * SPEC_638_WIDTH + sx;
                int p01 = p00 + 1;
                int p10 = p00 + SPEC_638_WIDTH;
                int p11 = p10 + 1;
                float wx0 = 1.0f - fx;
                float wy0 = 1.0f - fy;
                float r0 = red[p00] * wx0 + red[p01] * fx;
                float r1 = red[p10] * wx0 + red[p11] * fx;
                float g0 = green[p00] * wx0 + green[p01] * fx;
                float g1 = green[p10] * wx0 + green[p11] * fx;
                float b0 = blue[p00] * wx0 + blue[p01] * fx;
                float b1 = blue[p10] * wx0 + blue[p11] * fx;
                int out = y * SPEC_638_WIDTH + x;

                scratch[out] = (r0 * wy0 + r1 * fy) * 0.299f +
                               (g0 * wy0 + g1 * fy) * 0.587f +
                               (b0 * wy0 + b1 * fy) * 0.114f;
                acc ^= fold_float(scratch[out]) + (uint32_t)(out + round);
            }
        }
        for (int i = 0; i < SPEC_638_PIXELS; i++) {
            float mixed = clamp_unit(scratch[i]);
            red[i] = mixed;
            green[i] = green[i] * 0.625f + mixed * 0.375f;
            blue[i] = blue[i] * 0.75f + mixed * 0.25f;
        }
    }
    return acc;
}

/*
 * Models RGBTransformImage/TransformRGBImage and gamma/level stages. The
 * libm calls intentionally retain the non-linear software path visible in the
 * ref profile instead of replacing it with a polynomial-only approximation.
 */
__attribute__((noinline)) static uint32_t color_gamma_phase(int rounds)
{
    uint32_t acc = 0x67616d6du;

    for (int round = 0; round < rounds; round++) {
        for (int i = 0; i < SPEC_638_PIXELS; i++) {
            double r = red[i];
            double g = green[i];
            double b = blue[i];
            double linear = 0.4124564 * r + 0.3575761 * g + 0.1804375 * b;
            double chroma = -0.14713 * r - 0.28886 * g + 0.436 * b;
            double exponent = ((i + round) & 1) ? (1.0 / 2.2) : 2.2;
            int binary_exponent = 0;
            double transformed;
            double mantissa;

            if (linear < 1.0 / 4096.0)
                linear = 1.0 / 4096.0;
            else if (linear > 4095.0 / 4096.0)
                linear = 4095.0 / 4096.0;
            transformed = pow(linear, exponent);
            mantissa = frexp(transformed + 0.03125 * chroma,
                            &binary_exponent);
            transformed = scalbn(mantissa * (1.0 + 0.00390625 * round),
                                 binary_exponent);
            scratch[i] = clamp_unit((float)transformed);
            acc += fold_float(scratch[i]) ^ (uint32_t)(binary_exponent + 32);
        }
        for (int i = 0; i < SPEC_638_PIXELS; i++) {
            float level = scratch[i];
            red[i] = level;
            green[i] = clamp_unit(level * 0.875f + green[i] * 0.125f);
            blue[i] = clamp_unit(level * 0.75f + blue[i] * 0.25f);
        }
    }
    return acc;
}

/*
 * Models adaptive blur/sharpen and morphology: a branch-heavy 3x3
 * neighborhood walk combining min/max selection with a weighted convolution.
 */
__attribute__((noinline)) static uint32_t neighborhood_filter_phase(int rounds)
{
    uint32_t acc = 0x66696c74u;

    for (int round = 0; round < rounds; round++) {
        for (int y = 0; y < SPEC_638_HEIGHT; y++) {
            for (int x = 0; x < SPEC_638_WIDTH; x++) {
                float minimum = 1.0f;
                float maximum = 0.0f;
                float sum = 0.0f;

                for (int dy = -1; dy <= 1; dy++) {
                    int ny = y + dy;
                    if (ny < 0)
                        ny = 0;
                    else if (ny >= SPEC_638_HEIGHT)
                        ny = SPEC_638_HEIGHT - 1;
                    for (int dx = -1; dx <= 1; dx++) {
                        int nx = x + dx;
                        if (nx < 0)
                            nx = 0;
                        else if (nx >= SPEC_638_WIDTH)
                            nx = SPEC_638_WIDTH - 1;
                        float value = red[ny * SPEC_638_WIDTH + nx];
                        if (value < minimum)
                            minimum = value;
                        if (value > maximum)
                            maximum = value;
                        sum += value;
                    }
                }

                int index = y * SPEC_638_WIDTH + x;
                float blurred = sum * (1.0f / 9.0f);
                float selected = ((index + round) & 3) == 0 ?
                                 maximum : (((index + round) & 3) == 1 ?
                                 minimum : blurred);
                scratch[index] = clamp_unit(
                    selected + (red[index] - blurred) * 0.375f);
                acc ^= fold_float(scratch[index]) +
                       (uint32_t)(index * 17 + round);
            }
        }
        for (int i = 0; i < SPEC_638_PIXELS; i++)
            red[i] = scratch[i];
    }
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    initialize_pixels();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = 0;
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum ^= resample_phase(
        SPEC_638_RESAMPLE_ROUNDS * SPEC_COMPOSITION_SCALE +
        SPEC_638_RESAMPLE_EXTRA_ROUNDS);
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    checksum ^= color_gamma_phase(
        SPEC_638_COLOR_ROUNDS * SPEC_COMPOSITION_SCALE +
        SPEC_638_COLOR_EXTRA_ROUNDS);
    SPEC_COMPOSITION_PHASE1_END();
    SPEC_COMPOSITION_PHASE2_BEGIN();
    checksum ^= neighborhood_filter_phase(
        SPEC_638_FILTER_ROUNDS * SPEC_COMPOSITION_SCALE +
        SPEC_638_FILTER_EXTRA_ROUNDS);
    SPEC_COMPOSITION_PHASE2_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_638_imagick_speed_kernel config=%ux%u rounds=%u/%u/%u\n",
           (unsigned int)SPEC_638_WIDTH, (unsigned int)SPEC_638_HEIGHT,
           (unsigned int)(SPEC_638_RESAMPLE_ROUNDS * SPEC_COMPOSITION_SCALE +
                          SPEC_638_RESAMPLE_EXTRA_ROUNDS),
           (unsigned int)(SPEC_638_COLOR_ROUNDS * SPEC_COMPOSITION_SCALE +
                          SPEC_638_COLOR_EXTRA_ROUNDS),
           (unsigned int)(SPEC_638_FILTER_ROUNDS * SPEC_COMPOSITION_SCALE +
                          SPEC_638_FILTER_EXTRA_ROUNDS));
    printf("spec_638_imagick_speed_kernel checksum=%u\n",
           (unsigned int)checksum);
    return checksum == 0;
}
