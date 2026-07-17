/*
 * spec_gcc_compile_kernel: gcc-like compiler backend kernel.
 *
 * This is not SPEC gcc source code. It models the 502.gcc_r test profile
 * direction: garbage-collected allocation churn, RTL recognizer table walks,
 * multiply/constant-fold style integer work, and IRA-like interference updates.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_GCC_ITEMS
#define SPEC_GCC_ITEMS 64
#endif

#ifndef SPEC_GCC_ITERS
#define SPEC_GCC_ITERS 1
#endif

#ifndef SPEC_GCC_WIDTH
#define SPEC_GCC_WIDTH 8
#endif

#ifndef SPEC_GCC_DEPTH
#define SPEC_GCC_DEPTH 4
#endif

#define ITEMS SPEC_GCC_ITEMS
#define ITERS SPEC_GCC_ITERS
#define WIDTH SPEC_GCC_WIDTH
#define DEPTH SPEC_GCC_DEPTH
#define POOL_SIZE (ITEMS * 4 + 64)
#define LIVE_WORDS ((ITEMS + 31) / 32 + 1)

typedef struct {
    uint32_t opcode;
    uint32_t mode;
    uint32_t lhs;
    uint32_t rhs;
    uint32_t cost;
    uint16_t next;
    uint16_t alloc_tag;
} pseudo_rtx_t;

static pseudo_rtx_t pool[POOL_SIZE];
static uint32_t live[ITEMS][LIVE_WORDS];
static uint16_t free_head;
static uint16_t roots[ITEMS];
static uint32_t recog_table[WIDTH * 16 + 32];
static volatile uint32_t checksum;

static uint32_t rotl32(uint32_t x, unsigned int n)
{
    return (x << n) | (x >> (32u - n));
}

static uint32_t mix32(uint32_t x)
{
    x ^= x >> 16;
    x *= 0x7feb352du;
    x ^= x >> 15;
    x *= 0x846ca68bu;
    return x ^ (x >> 16);
}

static void init_pool(void)
{
    for (int i = 0; i < POOL_SIZE; i++) {
        pool[i].opcode = mix32((uint32_t)i + 0x5022017u) & 63u;
        pool[i].mode = (uint32_t)((i * 3 + WIDTH) & 7);
        pool[i].lhs = (uint32_t)((i * 7 + 5) % ITEMS);
        pool[i].rhs = (uint32_t)((i * 11 + 9) % ITEMS);
        pool[i].cost = mix32((uint32_t)i * 17u + 3u);
        pool[i].next = (uint16_t)(i + 1);
        pool[i].alloc_tag = (uint16_t)(i & 31);
    }
    pool[POOL_SIZE - 1].next = 0xffffu;
    free_head = 0;

    for (int i = 0; i < ITEMS; i++) {
        roots[i] = 0xffffu;
        for (int w = 0; w < LIVE_WORDS; w++)
            live[i][w] = mix32((uint32_t)(i * 97 + w * 13 + 1));
    }

    for (int i = 0; i < WIDTH * 16 + 32; i++)
        recog_table[i] = mix32((uint32_t)i * 131u + 0x9e3779b9u);
}

static uint16_t gc_alloc(uint32_t opcode, uint32_t mode, uint32_t lhs, uint32_t rhs)
{
    if (free_head == 0xffffu)
        free_head = (uint16_t)((opcode + lhs + rhs) % POOL_SIZE);

    uint16_t idx = free_head;
    free_head = pool[idx].next;
    pool[idx].opcode = opcode;
    pool[idx].mode = mode;
    pool[idx].lhs = lhs % ITEMS;
    pool[idx].rhs = rhs % ITEMS;
    pool[idx].cost = mix32(opcode * 17u + mode * 29u + lhs * 37u + rhs);
    pool[idx].next = roots[lhs % ITEMS];
    pool[idx].alloc_tag++;
    roots[lhs % ITEMS] = idx;
    return idx;
}

static void gc_sweep(uint32_t salt)
{
    for (int i = 0; i < ITEMS; i++) {
        uint16_t prev = 0xffffu;
        uint16_t cur = roots[i];
        int budget = DEPTH + 1;

        while (cur != 0xffffu && budget-- > 0) {
            uint16_t next = pool[cur].next;
            if (((pool[cur].cost ^ salt ^ (uint32_t)i) & 7u) == 0) {
                if (prev == 0xffffu)
                    roots[i] = next;
                else
                    pool[prev].next = next;
                pool[cur].next = free_head;
                free_head = cur;
            } else {
                prev = cur;
            }
            cur = next;
        }
    }
}

static uint32_t do_multiply_like(uint32_t a, uint32_t b)
{
    uint32_t hi = 0;
    uint32_t lo = 0;

    for (int i = 0; i < DEPTH + 4; i++) {
        if ((b >> i) & 1u)
            lo += a << (i & 7);
        hi ^= rotl32(a * (uint32_t)(i + 3), (unsigned int)((i & 7) + 1));
        a = rotl32(a + hi + 0x45d9f3bu, 3);
    }

    return lo ^ hi ^ (a * (b | 1u));
}

static uint32_t recog_like(uint16_t idx)
{
    uint32_t state = pool[idx].opcode ^ (pool[idx].mode << 8);
    uint32_t lhs = pool[idx].lhs;
    uint32_t rhs = pool[idx].rhs;

    for (int d = 0; d < DEPTH; d++) {
        uint32_t key = (state + lhs * 3u + rhs * 5u + (uint32_t)d) % (WIDTH * 16u + 32u);
        uint32_t rule = recog_table[key];

        switch ((rule ^ state) & 15u) {
        case 0:
        case 1:
            state = do_multiply_like(state + lhs, rule + rhs);
            break;
        case 2:
        case 3:
        case 4:
            state ^= rotl32(rule + pool[idx].cost, (unsigned int)((d & 7) + 1));
            break;
        case 5:
        case 6:
            state += (live[lhs][d % LIVE_WORDS] & live[rhs][(d + 1) % LIVE_WORDS]);
            break;
        case 7:
            state = (state >> 1) ^ (rule << 3) ^ 0x1021u;
            break;
        default:
            state += rule ^ do_multiply_like(lhs + state, rhs + rule);
            break;
        }
    }

    return state;
}

static void ira_like_update(uint32_t salt)
{
    for (int i = 0; i < ITEMS; i++) {
        int peer = (int)((i * 7 + salt) % ITEMS);
        uint32_t pressure = 0;

        for (int w = 0; w < LIVE_WORDS; w++) {
            uint32_t conflict = live[i][w] & live[peer][w];
            uint32_t merged = live[i][w] | rotl32(live[peer][w], (unsigned int)((i + w) & 7));
            pressure += conflict ^ (conflict >> 3);
            if ((pressure + (uint32_t)w) & 1u)
                live[i][w] = merged ^ salt;
            else
                live[i][w] = (merged & ~conflict) | rotl32(salt, (unsigned int)((w & 7) + 1));
        }

        if ((pressure & 3u) == 0)
            (void)gc_alloc(pressure & 63u, salt & 7u, (uint32_t)i, (uint32_t)peer);
    }
}

static uint32_t gcc_kernel(void)
{
    uint32_t acc = 0x5022017u;

    for (int it = 0; it < ITERS; it++) {
        for (int i = 0; i < ITEMS; i++) {
            uint32_t opcode = (acc + (uint32_t)i * 13u + (uint32_t)it) & 63u;
            uint32_t mode = (acc >> ((i & 3) + 1)) & 7u;
            uint16_t node = gc_alloc(opcode, mode, (uint32_t)i, (uint32_t)((i * 5 + it) % ITEMS));
            uint32_t recog = recog_like(node);

            live[i][(i + it) % LIVE_WORDS] ^= recog | (1u << (i & 31));
            pool[node].cost ^= recog + do_multiply_like(pool[node].lhs + 1u, pool[node].rhs + 3u);
            acc = rotl32(acc ^ recog ^ pool[node].cost, (unsigned int)((i & 7) + 1));
        }

        ira_like_update(acc + (uint32_t)it);
        gc_sweep(acc);
    }

    return acc;
}

static uint32_t bitmap_phase(void)
{
    uint32_t acc = 0x502b17u;
    for (int i = 0; i < (ITEMS * 3) / 4; i++) {
        int peer = (i * 13 + 7) % ITEMS;
        for (int w = 0; w < LIVE_WORDS; w++) {
            uint32_t intersection = live[i][w] & live[peer][w];
            uint32_t difference = live[i][w] & ~live[peer][w];
            live[i][w] = difference | rotl32(intersection, (unsigned int)((w & 7) + 1));
            acc ^= intersection + difference;
        }
    }
    return acc;
}

static uint32_t cfg_schedule_phase(void)
{
    uint32_t acc = 0x502cf6u;
    uint16_t node = roots[0];
    for (int i = 0; i < ITEMS / 5 + 1; i++) {
        if (node == 0xffffu)
            node = (uint16_t)((i * 17 + acc) % POOL_SIZE);
        uint32_t state = recog_like(node);
        int successor = (int)((pool[node].lhs + pool[node].rhs + state) % ITEMS);
        if ((state & 3u) == 0)
            roots[successor] = node;
        else if ((state & 3u) == 1)
            pool[node].cost ^= state;
        else
            pool[node].mode = (pool[node].mode + state) & 7u;
        acc = rotl32(acc + state + (uint32_t)successor, (unsigned int)((i & 7) + 1));
        node = pool[node].next;
    }
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_pool();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++)
        checksum ^= gcc_kernel() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++)
        checksum ^= bitmap_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    SPEC_COMPOSITION_PHASE2_BEGIN();
    for (int round = 0; round < SPEC_COMPOSITION_SCALE +
                              (SPEC_COMPOSITION_SCALE > 1); round++)
        checksum ^= cfg_schedule_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE2_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_gcc_compile_kernel config items=%u iters=%u width=%u depth=%u pool=%u live_words=%u\n",
           (unsigned int)ITEMS, (unsigned int)ITERS, (unsigned int)WIDTH,
           (unsigned int)DEPTH, (unsigned int)POOL_SIZE, (unsigned int)LIVE_WORDS);
    printf("spec_gcc_compile_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
