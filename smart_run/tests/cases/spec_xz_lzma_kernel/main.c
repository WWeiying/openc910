/*
 * spec_xz_lzma_kernel: xz/LZMA-like RTL kernel.
 *
 * This is not SPEC xz source code. It is a compact bare-metal kernel shaped
 * after the dominant 557.xz_r phases: match finder hash chains, literal/range
 * price table updates, and byte-oriented checksum/transform work.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_XZ_BYTES
#define SPEC_XZ_BYTES 512
#endif

#ifndef SPEC_XZ_DICT
#define SPEC_XZ_DICT 1024
#endif

#ifndef SPEC_XZ_PASSES
#define SPEC_XZ_PASSES 1
#endif

#ifndef SPEC_XZ_PROBES
#define SPEC_XZ_PROBES 12
#endif

#ifndef SPEC_XZ_RANGE_STEPS
#define SPEC_XZ_RANGE_STEPS 4
#endif

#if SPEC_XZ_BYTES < 64
#error "SPEC_XZ_BYTES must be at least 64"
#endif

#if SPEC_XZ_DICT < SPEC_XZ_BYTES
#error "SPEC_XZ_DICT must be greater than or equal to SPEC_XZ_BYTES"
#endif

#define BYTES SPEC_XZ_BYTES
#define DICT SPEC_XZ_DICT
#define PASSES SPEC_XZ_PASSES
#define PROBES SPEC_XZ_PROBES
#define RANGE_STEPS SPEC_XZ_RANGE_STEPS
#define HASH_SIZE 256

static uint8_t dict[DICT];
static uint16_t chain[DICT];
static uint16_t head[HASH_SIZE];
static uint16_t price[HASH_SIZE];
static uint16_t literal_prob[HASH_SIZE];
static uint16_t match_prob[HASH_SIZE];
static volatile uint32_t checksum;

static uint32_t lcg_next(uint32_t x)
{
    return x * 1664525u + 1013904223u;
}

static void init_data(void)
{
    uint32_t seed = 0x31415927u;

    for (int i = 0; i < HASH_SIZE; i++) {
        head[i] = 0xffffu;
        price[i] = (uint16_t)((i * 13 + 7) & 0x3ff);
        literal_prob[i] = (uint16_t)(1024 + ((i * 19) & 255));
        match_prob[i] = (uint16_t)(1024 - ((i * 11) & 255));
    }

    for (int i = 0; i < DICT; i++) {
        seed = lcg_next(seed);
        dict[i] = (uint8_t)((seed >> 16) ^ (i * 29));
        chain[i] = 0xffffu;
    }
}

static uint32_t range_update(uint32_t acc, uint32_t context, uint32_t bit)
{
    uint16_t *prob = bit ? &match_prob[context] : &literal_prob[context];
    uint32_t p = *prob;

    for (int i = 0; i < RANGE_STEPS; i++) {
        if ((bit ^ (acc >> (i + 3))) & 1u)
            p += (2048u - p) >> 5;
        else
            p -= p >> 5;
        acc = (acc << 7) ^ (acc >> 11) ^ p ^ (context * 33u);
    }

    *prob = (uint16_t)(p & 0x7ffu);
    return acc;
}

static uint32_t sha_like_mix(uint32_t a, uint32_t b, uint32_t c)
{
    uint32_t e = a ^ ((b >> 6) | (b << 26)) ^ ((c >> 11) | (c << 21));
    uint32_t ch = (a & b) ^ (~a & c);
    return e + ch + 0x6a09e667u;
}

static uint32_t hash3(int pos)
{
    uint32_t a = dict[pos % DICT];
    uint32_t b = dict[(pos + 1) % DICT];
    uint32_t c = dict[(pos + 2) % DICT];
    return ((a * 257u) ^ (b * 17u) ^ c) & (HASH_SIZE - 1);
}

static uint32_t match_finder_kernel(void)
{
    uint32_t acc = 0x12345678u;

    for (int pass = 0; pass < PASSES; pass++) {
        for (int pos = 0; pos < BYTES; pos++) {
            uint32_t h = hash3(pos);
            uint16_t prev = head[h];
            head[h] = (uint16_t)pos;
            chain[pos] = prev;

            int best_len = 0;
            int probes = 0;
            uint16_t cur = prev;
            while (cur != 0xffffu && probes < PROBES) {
                int len = 0;
                while (len < 16 &&
                       dict[(pos + len) % DICT] == dict[(cur + len) % DICT]) {
                    len++;
                }
                if (len > best_len)
                    best_len = len;

                cur = chain[cur % BYTES];
                probes++;
            }

            uint32_t p = price[(h + best_len) & (HASH_SIZE - 1)];
            if (best_len >= 4) {
                acc += (p ^ (uint32_t)(best_len * 33));
                price[h] = (uint16_t)((p + best_len + probes) & 0x7ff);
                acc = range_update(acc, h, 1u);
            } else {
                acc ^= ((uint32_t)dict[pos] << (pos & 7));
                price[h] = (uint16_t)((p + dict[pos] + 1) & 0x7ff);
                acc = range_update(acc, h, 0u);
            }

            if ((pos & 15) == 0) {
                uint32_t w0 = dict[pos % DICT];
                uint32_t w1 = dict[(pos + 13) % DICT];
                uint32_t w2 = dict[(pos + 29) % DICT];
                acc ^= sha_like_mix(w0 + acc, w1 + price[h], w2 + probes);
            }

            dict[(pos * 5 + pass * 17) % DICT] ^= (uint8_t)(acc >> 9);
            acc = (acc << 5) | (acc >> 27);
        }
    }

    return acc;
}

static uint32_t skip_match_phase(void)
{
    uint32_t acc = 0x5575a1u;
    int limit = (BYTES * (SPEC_COMPOSITION_SCALE > 1 ? 28 : 23)) / 64;
    if (limit < 1)
        limit = 1;
    for (int pass = 0; pass < PASSES; pass++) {
        for (int pos = 0; pos < limit; pos++) {
            uint32_t h = hash3(pos);
            uint16_t cur = head[h];
            int skip = 0;
            while (cur != 0xffffu && skip < (PROBES / 2 + 1)) {
                acc ^= (uint32_t)dict[cur % DICT] + ((uint32_t)cur << (skip & 7));
                cur = chain[cur % BYTES];
                skip++;
            }
            acc = range_update(acc, h, (uint32_t)(skip > 2));
        }
    }
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_data();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++)
        checksum ^= match_finder_kernel() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++)
        checksum ^= skip_match_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_xz_lzma_kernel config bytes=%u dict=%u passes=%u probes=%u range_steps=%u\n",
           (unsigned int)BYTES, (unsigned int)DICT, (unsigned int)PASSES,
           (unsigned int)PROBES, (unsigned int)RANGE_STEPS);
    printf("spec_xz_lzma_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
