/*
 * Shared SPEC2017 representative bare-metal kernel template.
 *
 * These kernels are not SPEC source code. They are compact workload models used
 * to exercise RTL with instruction mixes similar to missing SPEC2017 rate
 * benchmarks: parser/regex, compiler dataflow, event queues, XML traversal,
 * stencils, molecular dynamics, image filters, and climate columns.
 */

#ifndef SPEC_REPRESENTATIVE_KERNEL_H
#define SPEC_REPRESENTATIVE_KERNEL_H

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#define SPEC_KIND_PARSER 1
#define SPEC_KIND_COMPILER 2
#define SPEC_KIND_EVENT 3
#define SPEC_KIND_XML 4
#define SPEC_KIND_STENCIL 5
#define SPEC_KIND_PAIR 6
#define SPEC_KIND_IMAGE 7
#define SPEC_KIND_COLUMN 8
#define SPEC_KIND_GATHER 9
#define SPEC_KIND_REDUCTION 10
#define SPEC_KIND_TINY_RUNTIME 11

#ifndef SPEC_CASE_NAME
#define SPEC_CASE_NAME "spec_unknown_kernel"
#endif

#ifndef SPEC_CASE_ID
#define SPEC_CASE_ID 0x2017u
#endif

#ifndef SPEC_REP_KIND
#define SPEC_REP_KIND SPEC_KIND_PARSER
#endif

#ifndef SPEC_WORK_ITEMS
#define SPEC_WORK_ITEMS 64
#endif

#ifndef SPEC_WORK_ITERS
#define SPEC_WORK_ITERS 2
#endif

#ifndef SPEC_WORK_WIDTH
#define SPEC_WORK_WIDTH 8
#endif

#ifndef SPEC_WORK_DEPTH
#define SPEC_WORK_DEPTH 4
#endif

#define SPEC_ITEMS SPEC_WORK_ITEMS
#define SPEC_ITERS SPEC_WORK_ITERS
#define SPEC_WIDTH SPEC_WORK_WIDTH
#define SPEC_DEPTH SPEC_WORK_DEPTH

static uint32_t ustate[SPEC_ITEMS + 32];
static uint16_t link_a[SPEC_ITEMS + 32];
static uint16_t link_b[SPEC_ITEMS + 32];
static float fstate_a[SPEC_ITEMS + 32];
static float fstate_b[SPEC_ITEMS + 32];
static float fstate_c[SPEC_ITEMS + 32];
static volatile uint32_t checksum;

static uint32_t rotl32(uint32_t x, unsigned int n)
{
    return (x << n) | (x >> (32u - n));
}

static uint32_t fold_float(float x)
{
    int32_t v = (int32_t)(x * 4096.0f);
    return (uint32_t)v ^ ((uint32_t)v << 7) ^ ((uint32_t)v >> 11);
}

static void spec_init_state(void)
{
    for (int i = 0; i < SPEC_ITEMS + 32; i++) {
        uint32_t x = (uint32_t)i * 2654435761u + SPEC_CASE_ID;
        x ^= x >> 13;
        x *= 0x85ebca6bu;
        ustate[i] = x ^ (x >> 16);
        link_a[i] = (uint16_t)((i * 7 + SPEC_WIDTH + 3) % SPEC_ITEMS);
        link_b[i] = (uint16_t)((i * 11 + SPEC_DEPTH + 5) % SPEC_ITEMS);
        fstate_a[i] = (float)((x >> 3) & 255) * 0.00390625f + 0.125f;
        fstate_b[i] = (float)((x >> 11) & 255) * 0.001953125f + 0.25f;
        fstate_c[i] = 0.0f;
    }
}

static uint32_t parser_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x50000000u;
    uint32_t table[SPEC_WIDTH + 1];

    for (int i = 0; i <= SPEC_WIDTH; i++)
        table[i] = SPEC_CASE_ID + (uint32_t)i * 17u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        uint32_t state = (uint32_t)(it & 7);
        for (int i = 0; i < SPEC_ITEMS; i++) {
            uint32_t ch = ustate[(i + it) % SPEC_ITEMS] & 255u;
            uint32_t cls = ((ch >= '0' && ch <= '9') ? 1u :
                            (ch >= 'A' && ch <= 'Z') ? 2u :
                            (ch >= 'a' && ch <= 'z') ? 3u : 4u);
            uint32_t h = table[(state + cls) % (SPEC_WIDTH + 1)] ^ ch;
            for (int d = 0; d < SPEC_DEPTH; d++) {
                if ((h ^ state) & 1u)
                    h = rotl32(h + ustate[(i + d) % SPEC_ITEMS], 5);
                else
                    h = (h >> 3) ^ (h * 33u) ^ (uint32_t)d;
                state = (state + cls + (h & 7u)) % (SPEC_WIDTH + 1);
            }
            table[state] ^= h + (uint32_t)i;
            acc ^= rotl32(h + state, (unsigned int)((i & 7) + 1));
        }
    }

    return acc;
}

static uint32_t compiler_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x50200000u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int i = 0; i < SPEC_ITEMS; i++) {
            uint32_t use = ustate[i] ^ ustate[link_a[i]];
            uint32_t def = rotl32(ustate[link_b[i]] + (uint32_t)i, 3);
            for (int d = 0; d < SPEC_DEPTH; d++) {
                int a = (i + d + link_a[i]) % SPEC_ITEMS;
                int b = (i + d * 3 + link_b[i]) % SPEC_ITEMS;
                uint32_t live = (use & ustate[a]) | (def ^ ustate[b]);
                if ((live >> (d & 15)) & 1u)
                    def ^= rotl32(live + acc, (unsigned int)((d & 7) + 1));
                else
                    use += (live ^ (uint32_t)(a * 13 + b));
            }
            ustate[i] = def ^ use ^ (uint32_t)it;
            acc += rotl32(ustate[i], (unsigned int)((i & 15) + 1));
        }
    }

    return acc;
}

static void heap_push(uint16_t heap[], int *size, uint16_t value)
{
    int p = (*size)++;
    while (p > 0) {
        int parent = (p - 1) >> 1;
        if (ustate[heap[parent]] <= ustate[value])
            break;
        heap[p] = heap[parent];
        p = parent;
    }
    heap[p] = value;
}

static uint16_t heap_pop(uint16_t heap[], int *size)
{
    uint16_t ret = heap[0];
    uint16_t value = heap[--(*size)];
    int p = 0;

    while (1) {
        int child = p * 2 + 1;
        if (child >= *size)
            break;
        if (child + 1 < *size && ustate[heap[child + 1]] < ustate[heap[child]])
            child++;
        if (ustate[value] <= ustate[heap[child]])
            break;
        heap[p] = heap[child];
        p = child;
    }
    heap[p] = value;
    return ret;
}

static uint32_t event_like_kernel(void)
{
    uint16_t heap[SPEC_ITEMS + 1];
    int size = 0;
    uint32_t acc = SPEC_CASE_ID ^ 0x52000000u;

    for (int i = 0; i < SPEC_ITEMS; i++)
        heap_push(heap, &size, (uint16_t)i);

    for (int it = 0; it < SPEC_ITERS; it++) {
        int events = SPEC_ITEMS;
        while (events-- > 0 && size > 0) {
            uint16_t ev = heap_pop(heap, &size);
            uint32_t tag = (ustate[ev] >> 3) & 3u;
            switch (tag) {
            case 0:
                ustate[ev] += ustate[link_a[ev]] ^ acc;
                break;
            case 1:
                ustate[ev] = rotl32(ustate[ev] + ustate[link_b[ev]], 9);
                break;
            case 2:
                ustate[ev] ^= (ustate[link_a[ev]] & ustate[link_b[ev]]) + (uint32_t)it;
                break;
            default:
                ustate[ev] = (ustate[ev] >> 1) + rotl32(acc, 3);
                break;
            }
            acc ^= ustate[ev] + (uint32_t)ev * 19u;
            heap_push(heap, &size, ev);
        }
    }

    return acc;
}

static uint32_t xml_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x52300000u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int root = 0; root < SPEC_WIDTH; root++) {
            int node = (root * 13 + it) % SPEC_ITEMS;
            for (int d = 0; d < SPEC_DEPTH * 4; d++) {
                uint32_t name = ustate[node] & 0xffffu;
                uint32_t attr = ustate[link_a[node]] ^ ustate[link_b[node]];
                if ((name ^ attr) & 1u)
                    acc += rotl32(name + attr + (uint32_t)d, 7);
                else
                    acc ^= (name * 131u) + attr + (uint32_t)node;
                node = ((attr >> (d & 7)) + link_a[node] + d) % SPEC_ITEMS;
            }
        }
    }

    return acc;
}

static uint32_t stencil_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x50300000u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int i = 1; i < SPEC_ITEMS - 1; i++) {
            float center = fstate_a[i];
            float lap = fstate_a[i - 1] + fstate_a[i + 1] - 2.0f * center;
            for (int w = 1; w <= SPEC_WIDTH; w++) {
                int a = (i + w) % SPEC_ITEMS;
                int b = (i + SPEC_ITEMS - w) % SPEC_ITEMS;
                lap += (fstate_a[a] - fstate_a[b]) * (0.03125f * (float)w);
            }
            fstate_b[i] = center + 0.125f * lap + fstate_c[i] * 0.015625f;
            acc ^= fold_float(fstate_b[i]) + (uint32_t)i;
        }
        for (int i = 1; i < SPEC_ITEMS - 1; i++) {
            fstate_c[i] = fstate_b[i] - fstate_a[i] * 0.25f;
            fstate_a[i] = fstate_b[i];
        }
    }

    return acc;
}

static uint32_t pair_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x50800000u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int i = 0; i < SPEC_ITEMS; i++) {
            float fx = 0.0f;
            float fy = 0.0f;
            float xi = fstate_a[i];
            float yi = fstate_b[i];
            for (int p = 0; p < SPEC_WIDTH; p++) {
                int j = (i + p * 7 + it + 1) % SPEC_ITEMS;
                float dx = fstate_a[j] - xi;
                float dy = fstate_b[j] - yi;
                float r2 = dx * dx + dy * dy + 0.0625f;
                float inv = 1.0f / r2;
                float force = inv * inv - 0.03125f * inv;
                fx += dx * force;
                fy += dy * force;
            }
            fstate_c[i] += fx * 0.015625f + fy * 0.0078125f;
            fstate_a[i] += fstate_c[i] * 0.03125f;
            fstate_b[i] += (fx - fy) * 0.00390625f;
            acc += fold_float(fstate_a[i] + fstate_b[i] + fstate_c[i]);
        }
    }

    return acc;
}

static uint32_t image_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x53800000u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int i = 1; i < SPEC_ITEMS - 1; i++) {
            float r = fstate_a[i - 1] * 0.25f + fstate_a[i] * 0.5f + fstate_a[i + 1] * 0.25f;
            float g = fstate_b[(i + SPEC_WIDTH) % SPEC_ITEMS] * 0.375f + fstate_b[i] * 0.625f;
            float b = (r * 0.299f + g * 0.587f + fstate_c[i] * 0.114f);
            if (((ustate[i] + (uint32_t)it) & 3u) == 0)
                b = b * 1.125f + 0.03125f;
            else
                b = b * 0.875f - 0.015625f;
            fstate_c[i] = b;
            acc ^= fold_float(b) + rotl32(ustate[i], (unsigned int)((i & 7) + 1));
        }
        for (int i = 1; i < SPEC_ITEMS - 1; i++) {
            fstate_a[i] = fstate_c[i];
            fstate_b[i] = fstate_b[i] * 0.75f + fstate_c[i] * 0.25f;
        }
    }

    return acc;
}

static uint32_t column_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x52700000u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int col = 0; col < SPEC_WIDTH; col++) {
            float moist = 0.25f + (float)col * 0.00390625f;
            for (int z = 1; z < SPEC_ITEMS - 1; z++) {
                float temp = fstate_a[z] + 0.0625f * fstate_b[(z + col) % SPEC_ITEMS];
                float pressure = fstate_b[z] + 0.125f * fstate_a[z - 1];
                float mix = (temp - pressure) * 0.03125f + moist;
                if (mix > 0.75f)
                    moist = moist * 0.875f + mix * 0.125f;
                else
                    moist = moist * 0.96875f + 0.015625f;
                fstate_c[z] = temp + pressure * 0.015625f - moist * 0.03125f;
                acc += fold_float(fstate_c[z] + moist);
            }
        }
        for (int z = 1; z < SPEC_ITEMS - 1; z++) {
            fstate_a[z] = fstate_c[z];
            fstate_b[z] += (fstate_a[z + 1] - fstate_a[z - 1]) * 0.015625f;
        }
    }

    return acc;
}

static uint32_t gather_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x6a746872u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int i = 0; i < SPEC_ITEMS; i++) {
            float sum = 0.0f;
            int cursor = (i + it) % SPEC_ITEMS;
            for (int p = 0; p < SPEC_WIDTH; p++) {
                cursor = (link_a[cursor] + link_b[(cursor + p) % SPEC_ITEMS]) % SPEC_ITEMS;
                float delta = fstate_a[cursor] - fstate_b[i];
                sum += delta * delta * (0.015625f * (float)(p + 1));
            }
            fstate_c[i] = sum;
            acc ^= fold_float(sum) + rotl32(ustate[cursor], (unsigned int)((i & 7) + 1));
        }
    }
    return acc;
}

static uint32_t reduction_like_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x72656475u;

    for (int it = 0; it < SPEC_ITERS; it++) {
        for (int block = 0; block < SPEC_WIDTH; block++) {
            float sx = 0.0f;
            float sy = 0.0f;
            uint32_t bits = 0;
            for (int i = block; i < SPEC_ITEMS; i += SPEC_WIDTH) {
                sx += fstate_a[i] * 0.75f + fstate_c[i] * 0.25f;
                sy += fstate_b[i] - fstate_c[i] * 0.125f;
                bits ^= rotl32(ustate[i], (unsigned int)((i + it) & 15) + 1);
            }
            fstate_a[block] = sx;
            fstate_b[block] = sy;
            acc += fold_float(sx + sy) ^ bits;
        }
    }
    return acc;
}

static uint32_t tiny_runtime_kernel(void)
{
    uint32_t acc = SPEC_CASE_ID ^ 0x74696e79u;
    int limit = SPEC_DEPTH + 3;

    for (int i = 0; i < limit; i++) {
        unsigned int index = (unsigned int)(i * 7 + SPEC_WIDTH) % SPEC_ITEMS;
        uint32_t value = ustate[index] ^ (uint32_t)i;
        if (value & 1u)
            acc = rotl32(acc + value, (unsigned int)((i & 7) + 1));
        else
            acc ^= value * 33u;
    }
    return acc;
}

__attribute__((noinline)) static uint32_t spec_run_kernel_kind(int kind)
{
    switch (kind) {
    case SPEC_KIND_PARSER: return parser_like_kernel();
    case SPEC_KIND_COMPILER: return compiler_like_kernel();
    case SPEC_KIND_EVENT: return event_like_kernel();
    case SPEC_KIND_XML: return xml_like_kernel();
    case SPEC_KIND_STENCIL: return stencil_like_kernel();
    case SPEC_KIND_PAIR: return pair_like_kernel();
    case SPEC_KIND_IMAGE: return image_like_kernel();
    case SPEC_KIND_COLUMN: return column_like_kernel();
    case SPEC_KIND_GATHER: return gather_like_kernel();
    case SPEC_KIND_REDUCTION: return reduction_like_kernel();
    case SPEC_KIND_TINY_RUNTIME: return tiny_runtime_kernel();
    default: return parser_like_kernel();
    }
}

#ifndef SPEC_COMPOSITION_GROUPS
#define SPEC_COMPOSITION_GROUPS 0
#endif
#ifndef SPEC_COMPOSITION_PHASE0_KIND
#define SPEC_COMPOSITION_PHASE0_KIND SPEC_REP_KIND
#endif
#ifndef SPEC_COMPOSITION_PHASE1_KIND
#define SPEC_COMPOSITION_PHASE1_KIND SPEC_REP_KIND
#endif
#ifndef SPEC_COMPOSITION_PHASE2_KIND
#define SPEC_COMPOSITION_PHASE2_KIND SPEC_REP_KIND
#endif
#ifndef SPEC_COMPOSITION_PHASE0_ROUNDS
#define SPEC_COMPOSITION_PHASE0_ROUNDS 1
#endif
#ifndef SPEC_COMPOSITION_PHASE1_ROUNDS
#define SPEC_COMPOSITION_PHASE1_ROUNDS 1
#endif
#ifndef SPEC_COMPOSITION_PHASE2_ROUNDS
#define SPEC_COMPOSITION_PHASE2_ROUNDS 1
#endif
#ifndef SPEC_COMPOSITION_FOOTPRINT_PHASE
#define SPEC_COMPOSITION_FOOTPRINT_PHASE 0
#endif
#ifndef SPEC_COMPOSITION_PHASE0_EXTRA_ROUNDS
#define SPEC_COMPOSITION_PHASE0_EXTRA_ROUNDS 0
#endif
#ifndef SPEC_COMPOSITION_PHASE1_EXTRA_ROUNDS
#define SPEC_COMPOSITION_PHASE1_EXTRA_ROUNDS 0
#endif
#ifndef SPEC_COMPOSITION_PHASE2_EXTRA_ROUNDS
#define SPEC_COMPOSITION_PHASE2_EXTRA_ROUNDS 0
#endif

static uint32_t spec_run_rounds(int kind, int rounds)
{
    uint32_t acc = 0;
    for (int round = 0; round < rounds; round++)
        acc ^= spec_run_kernel_kind(kind) + (uint32_t)round * 0x9e3779b9u;
    return acc;
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    spec_init_state();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
#if SPEC_COMPOSITION_GROUPS > 0
    checksum = 0;
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum ^= spec_run_rounds(SPEC_COMPOSITION_PHASE0_KIND,
                                SPEC_COMPOSITION_PHASE0_ROUNDS * SPEC_COMPOSITION_SCALE +
                                SPEC_COMPOSITION_PHASE0_EXTRA_ROUNDS);
    SPEC_COMPOSITION_PHASE0_END();
#if SPEC_COMPOSITION_GROUPS > 1
    SPEC_COMPOSITION_PHASE1_BEGIN();
    checksum ^= spec_run_rounds(SPEC_COMPOSITION_PHASE1_KIND,
                                SPEC_COMPOSITION_PHASE1_ROUNDS * SPEC_COMPOSITION_SCALE +
                                SPEC_COMPOSITION_PHASE1_EXTRA_ROUNDS);
    SPEC_COMPOSITION_PHASE1_END();
#endif
#if SPEC_COMPOSITION_GROUPS > 2
    SPEC_COMPOSITION_PHASE2_BEGIN();
    checksum ^= spec_run_rounds(SPEC_COMPOSITION_PHASE2_KIND,
                                SPEC_COMPOSITION_PHASE2_ROUNDS * SPEC_COMPOSITION_SCALE +
                                SPEC_COMPOSITION_PHASE2_EXTRA_ROUNDS);
    SPEC_COMPOSITION_PHASE2_END();
#endif
    checksum ^= spec_profile_footprint_run();
#else
    checksum = spec_run_kernel_kind(SPEC_REP_KIND) ^ spec_profile_footprint_run();
#endif
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("%s config kind=%u items=%u iters=%u width=%u depth=%u\n",
           SPEC_CASE_NAME, (unsigned int)SPEC_REP_KIND,
           (unsigned int)SPEC_ITEMS, (unsigned int)SPEC_ITERS,
           (unsigned int)SPEC_WIDTH, (unsigned int)SPEC_DEPTH);
    printf("%s checksum=%u\n", SPEC_CASE_NAME, (unsigned int)checksum);
    return checksum == 0;
}

#endif
