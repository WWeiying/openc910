/*
 * spec_x264_pixel_kernel: x264 pixel/motion-estimation-like RTL kernel.
 *
 * This is not SPEC x264 source code. It models the hot 525.x264_r functions:
 * SAD/SATD-style block metrics, get_ref-like reference loads, interpolation,
 * and small transform/quantization loops.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_X264_WIDTH
#define SPEC_X264_WIDTH 24
#endif

#ifndef SPEC_X264_HEIGHT
#define SPEC_X264_HEIGHT 24
#endif

#ifndef SPEC_X264_BLOCKS
#define SPEC_X264_BLOCKS 1
#endif

#ifndef SPEC_X264_PASSES
#define SPEC_X264_PASSES 1
#endif

#ifndef SPEC_X264_CANDIDATES
#define SPEC_X264_CANDIDATES 1
#endif

#if SPEC_X264_WIDTH < 24 || SPEC_X264_HEIGHT < 24
#error "SPEC_X264_WIDTH/HEIGHT must be at least 24"
#endif

#define WIDTH SPEC_X264_WIDTH
#define HEIGHT SPEC_X264_HEIGHT
#define BLOCKS SPEC_X264_BLOCKS
#define PASSES SPEC_X264_PASSES
#define CANDIDATES SPEC_X264_CANDIDATES

static uint8_t cur[HEIGHT][WIDTH];
static uint8_t ref0[HEIGHT][WIDTH];
static uint8_t ref1[HEIGHT][WIDTH];
static int16_t coeff[8][8];
static uint16_t cabac_ctx[64];
static volatile uint32_t checksum;

static uint32_t lcg_next(uint32_t x)
{
    return x * 1103515245u + 12345u;
}

static uint32_t abs_i32(int32_t x)
{
    return (x < 0) ? (uint32_t)(-x) : (uint32_t)x;
}

static void init_pixels(void)
{
    uint32_t seed = 0x9e3779b9u;

    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            seed = lcg_next(seed);
            cur[y][x] = (uint8_t)((seed >> 16) + x + y);
            seed = lcg_next(seed);
            ref0[y][x] = (uint8_t)((seed >> 17) + 3 * x - y);
            ref1[y][x] = (uint8_t)((seed >> 18) + x + 5 * y);
        }
    }

    for (int i = 0; i < 64; i++)
        cabac_ctx[i] = (uint16_t)(512 + ((i * 23) & 255));
}

static uint32_t sad_16x16(int x, int y, int dx, int dy)
{
    uint32_t sum = 0;
    for (int j = 0; j < 16; j++) {
        for (int i = 0; i < 16; i++) {
            int a = cur[y + j][x + i];
            int b = ref0[y + ((j + dy) & 15)][x + ((i + dx) & 15)];
            sum += abs_i32(a - b);
        }
    }
    return sum;
}

static uint32_t satd_8x4(int x, int y, int dx, int dy)
{
    int16_t tmp[4][8];
    uint32_t sum = 0;

    for (int j = 0; j < 4; j++) {
        for (int i = 0; i < 8; i++) {
            int a = cur[y + j][x + i];
            int b0 = ref0[y + ((j + dy) & 7)][x + ((i + dx) & 7)];
            int b1 = ref1[y + ((j + dy + 1) & 7)][x + ((i + dx + 1) & 7)];
            tmp[j][i] = (int16_t)(a - ((b0 + b1 + 1) >> 1));
        }
    }

    for (int j = 0; j < 4; j++) {
        for (int i = 0; i < 8; i += 2) {
            int a = tmp[j][i] + tmp[j][i + 1];
            int b = tmp[j][i] - tmp[j][i + 1];
            sum += abs_i32(a) + abs_i32(b);
        }
    }

    return sum;
}

static uint32_t transform_quant_4x4(int x, int y)
{
    uint32_t nz = 0;

    for (int j = 0; j < 4; j++) {
        for (int i = 0; i < 4; i++) {
            int v = (int)cur[y + j][x + i] - (int)ref0[y + j][x + i];
            coeff[j][i] = (int16_t)v;
        }
    }

    for (int j = 0; j < 4; j++) {
        int a0 = coeff[j][0] + coeff[j][3];
        int a1 = coeff[j][1] + coeff[j][2];
        int a2 = coeff[j][1] - coeff[j][2];
        int a3 = coeff[j][0] - coeff[j][3];
        coeff[j][0] = (int16_t)(a0 + a1);
        coeff[j][1] = (int16_t)(a3 + a2);
        coeff[j][2] = (int16_t)(a0 - a1);
        coeff[j][3] = (int16_t)(a3 - a2);
    }

    for (int i = 0; i < 4; i++) {
        int a0 = coeff[0][i] + coeff[3][i];
        int a1 = coeff[1][i] + coeff[2][i];
        int a2 = coeff[1][i] - coeff[2][i];
        int a3 = coeff[0][i] - coeff[3][i];
        int out0 = (a0 + a1 + 8) >> 4;
        int out1 = (a3 + a2 + 8) >> 4;
        int out2 = (a0 - a1 + 8) >> 4;
        int out3 = (a3 - a2 + 8) >> 4;
        nz += (out0 != 0) + (out1 != 0) + (out2 != 0) + (out3 != 0);
    }

    return nz;
}

static uint32_t sad_8x8(int x, int y, int dx, int dy)
{
    uint32_t sum = 0;
    for (int j = 0; j < 8; j++) {
        for (int i = 0; i < 8; i++) {
            int a = cur[y + j][x + i];
            int b = ref1[y + ((j + dy) & 7)][x + ((i + dx) & 7)];
            sum += abs_i32(a - b);
        }
    }
    return sum;
}

static uint32_t cabac_like_update(uint32_t acc, uint32_t symbol)
{
    uint32_t ctx = symbol & 63u;
    uint32_t p = cabac_ctx[ctx];

    if (symbol & 1u)
        p += (1024u - p) >> 4;
    else
        p -= p >> 4;

    cabac_ctx[ctx] = (uint16_t)(p & 0x3ffu);
    return (acc << 3) ^ (acc >> 9) ^ p ^ (symbol * 131u);
}

static uint32_t refine_subpel(int x, int y, int dx, int dy)
{
    uint32_t best = 0xffffffffu;

    for (int sy = -1; sy <= 1; sy++) {
        for (int sx = -1; sx <= 1; sx++) {
            uint32_t s = satd_8x4(x, y, dx + sx, dy + sy) +
                         sad_8x8(x, y, dx + sx, dy + sy);
            if (s < best)
                best = s;
        }
    }

    return best;
}

static uint32_t pixel_kernel(void)
{
    uint32_t acc = 0;

    for (int pass = 0; pass < PASSES; pass++) {
        for (int b = 0; b < BLOCKS; b++) {
            int x = 1 + ((b * 7 + pass * 3) % (WIDTH - 17));
            int y = 1 + ((b * 5 + pass * 2) % (HEIGHT - 17));
            int dx = (b + pass) & 7;
            int dy = (b * 3 + pass) & 7;

            uint32_t s0 = 0xffffffffu;
            uint32_t s1 = 0xffffffffu;
            for (int c = 0; c < CANDIDATES; c++) {
                int mdx = (dx + c * 2 - 3) & 7;
                int mdy = (dy + c * 3 - 2) & 7;
                uint32_t cand0 = sad_16x16(x, y, mdx, mdy);
                uint32_t cand1 = satd_8x4(x, y, mdx, mdy);
                if (cand0 < s0) {
                    s0 = cand0;
                    dx = mdx;
                }
                if (cand1 < s1) {
                    s1 = cand1;
                    dy = mdy;
                }
            }

            s1 += refine_subpel(x, y, dx, dy);
            uint32_t q = transform_quant_4x4(x, y);

            if (s1 < s0)
                acc += s1 + (q << 4);
            else
                acc ^= s0 + q;

            acc = cabac_like_update(acc, q + s0 + s1);
            ref0[(y + dy) % HEIGHT][(x + dx) % WIDTH] ^= (uint8_t)acc;
        }
    }

    return acc;
}

static uint32_t half_pixel_phase(void)
{
    uint32_t acc = 0x2644a1fu;
    int count = BLOCKS > 0 ? BLOCKS : 1;
    for (int b = 0; b < count; b++) {
        int x = 1 + ((b * 7) % (WIDTH - 17));
        int y = 1 + ((b * 5) % (HEIGHT - 17));
        acc ^= refine_subpel(x, y, b & 7, (b * 3) & 7);
    }
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_pixels();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++)
        checksum ^= half_pixel_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < 11 * SPEC_COMPOSITION_SCALE; round++)
        checksum ^= pixel_kernel() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_x264_pixel_kernel config width=%u height=%u blocks=%u passes=%u candidates=%u\n",
           (unsigned int)WIDTH, (unsigned int)HEIGHT,
           (unsigned int)BLOCKS, (unsigned int)PASSES,
           (unsigned int)CANDIDATES);
    printf("spec_x264_pixel_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
