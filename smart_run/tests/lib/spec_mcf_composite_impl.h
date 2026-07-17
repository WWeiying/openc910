#ifndef SPEC_MCF_COMPOSITE_IMPL_H
#define SPEC_MCF_COMPOSITE_IMPL_H

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_MCF_COMPOSITE_NAME
#error "SPEC_MCF_COMPOSITE_NAME must be defined"
#endif
#ifndef SPEC_MCF_COMPOSITE_SORT_ROUNDS
#error "SPEC_MCF_COMPOSITE_SORT_ROUNDS must be defined"
#endif
#ifndef SPEC_MCF_COMPOSITE_PRICE_ROUNDS
#error "SPEC_MCF_COMPOSITE_PRICE_ROUNDS must be defined"
#endif
#ifndef SPEC_MCF_COMPOSITE_TARGET_SORT_PPM
#error "SPEC_MCF_COMPOSITE_TARGET_SORT_PPM must be defined"
#endif
#ifndef SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS
#define SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS 0
#endif

#ifndef MCF_SORT_ITEMS
#define MCF_SORT_ITEMS 96
#endif
#ifndef MCF_PRICE_NODES
#define MCF_PRICE_NODES 32
#endif
#ifndef MCF_PRICE_ARCS
#define MCF_PRICE_ARCS 96
#endif
#ifndef MCF_PRICE_BASKET
#define MCF_PRICE_BASKET 8
#endif
#ifndef SPEC_MCF_COMPOSITE_WARMUP
#define SPEC_MCF_COMPOSITE_WARMUP 0
#endif

typedef struct {
    int64_t potential;
    int32_t mark;
} mcf_sort_node_t;

typedef struct {
    mcf_sort_node_t *tail;
    mcf_sort_node_t *head;
    int64_t cost;
    int32_t ident;
    int32_t id;
} mcf_sort_arc_t;

typedef struct {
    mcf_sort_arc_t *arc;
    int64_t red_cost;
    uint64_t abs_cost;
    int32_t sequence;
} mcf_sort_item_t;

typedef struct {
    int64_t potential;
    int64_t supply;
} mcf_price_node_t;

typedef struct {
    mcf_price_node_t *tail;
    mcf_price_node_t *head;
    int64_t cost;
    int32_t ident;
    int32_t id;
} mcf_price_arc_t;

typedef struct {
    mcf_price_arc_t *arc;
    int64_t red_cost;
    uint64_t abs_cost;
} mcf_price_item_t;

static mcf_sort_node_t mcf_sort_nodes[MCF_SORT_ITEMS + 17];
static mcf_sort_arc_t mcf_sort_arcs[MCF_SORT_ITEMS];
static mcf_sort_item_t mcf_sort_items[MCF_SORT_ITEMS];
static mcf_price_node_t mcf_price_nodes[MCF_PRICE_NODES];
static mcf_price_arc_t mcf_price_arcs[MCF_PRICE_ARCS];
static mcf_price_item_t mcf_price_basket[MCF_PRICE_BASKET];
static volatile uint32_t mcf_composite_checksum;

static uint32_t mcf_lcg_next(uint32_t x)
{
    return x * 1664525u + 1013904223u;
}

static uint64_t mcf_abs64(int64_t x)
{
    return (x < 0) ? (uint64_t)(-x) : (uint64_t)x;
}

static void mcf_init_sort(void)
{
    uint32_t seed = 0x2468ace1u;

    for (int i = 0; i < MCF_SORT_ITEMS + 17; i++) {
        seed = mcf_lcg_next(seed);
        mcf_sort_nodes[i].potential = (int64_t)((seed >> 9) & 0x7ff) - 1024;
        mcf_sort_nodes[i].mark = (int32_t)(seed & 7u);
    }
    for (int i = 0; i < MCF_SORT_ITEMS; i++) {
        seed = mcf_lcg_next(seed);
        uint32_t tail = (seed >> 5) % (MCF_SORT_ITEMS + 17);
        seed = mcf_lcg_next(seed);
        uint32_t head = (seed >> 13) % (MCF_SORT_ITEMS + 17);

        mcf_sort_arcs[i].tail = &mcf_sort_nodes[tail];
        mcf_sort_arcs[i].head = &mcf_sort_nodes[head];
        mcf_sort_arcs[i].cost = (int64_t)((seed >> 3) & 0xfff) - 2048;
        mcf_sort_arcs[i].ident = (int32_t)((seed >> 19) & 3u);
        mcf_sort_arcs[i].id = i;

        int64_t red_cost = mcf_sort_arcs[i].cost -
                           mcf_sort_arcs[i].tail->potential +
                           mcf_sort_arcs[i].head->potential;
        mcf_sort_items[i].arc = &mcf_sort_arcs[i];
        mcf_sort_items[i].red_cost = red_cost;
        mcf_sort_items[i].abs_cost = mcf_abs64(red_cost);
        mcf_sort_items[i].sequence = (int32_t)(seed & 0xffffu);
    }
}

static int mcf_cost_compare(const mcf_sort_item_t *a,
                            const mcf_sort_item_t *b)
{
    if (a->abs_cost != b->abs_cost)
        return (a->abs_cost > b->abs_cost) ? -1 : 1;
    if (a->red_cost != b->red_cost)
        return (a->red_cost > b->red_cost) ? -1 : 1;

    int32_t a_mix = a->arc->tail->mark - a->arc->head->mark + a->arc->ident;
    int32_t b_mix = b->arc->tail->mark - b->arc->head->mark + b->arc->ident;
    if (a_mix != b_mix)
        return (a_mix < b_mix) ? -1 : 1;
    if (a->sequence != b->sequence)
        return (a->sequence < b->sequence) ? -1 : 1;
    return a->arc->id - b->arc->id;
}

static void mcf_swap_items(int a, int b)
{
    mcf_sort_item_t tmp = mcf_sort_items[a];
    mcf_sort_items[a] = mcf_sort_items[b];
    mcf_sort_items[b] = tmp;
}

static void mcf_scramble_items(int round)
{
    uint32_t state = 0x9e3779b9u ^ (uint32_t)(round * 0x45d9f3bu);

    for (int i = MCF_SORT_ITEMS - 1; i > 0; i--) {
        state = mcf_lcg_next(state);
        int j = (int)(state % (uint32_t)(i + 1));
        mcf_swap_items(i, j);
        mcf_sort_items[i].red_cost += (int64_t)((state >> 27) & 15u) - 7;
        mcf_sort_items[i].abs_cost = mcf_abs64(mcf_sort_items[i].red_cost);
        mcf_sort_items[i].sequence ^= (int32_t)(state >> 8);
    }
}

static int mcf_partition_items(int lo, int hi)
{
    mcf_sort_item_t pivot = mcf_sort_items[hi];
    int store = lo;

    for (int i = lo; i < hi; i++) {
        if (mcf_cost_compare(&mcf_sort_items[i], &pivot) < 0) {
            mcf_swap_items(i, store);
            store++;
        }
    }
    mcf_swap_items(store, hi);
    return store;
}

__attribute__((noinline)) static void mcf_qsort_items(int lo, int hi)
{
    while (lo < hi) {
        int mid = mcf_partition_items(lo, hi);
        if (mid - lo < hi - mid) {
            if (lo < mid - 1)
                mcf_qsort_items(lo, mid - 1);
            lo = mid + 1;
        } else {
            if (mid + 1 < hi)
                mcf_qsort_items(mid + 1, hi);
            hi = mid - 1;
        }
    }
}

__attribute__((noinline)) static uint32_t mcf_sort_phase(void)
{
    uint64_t local = 0;

    for (int round = 0; round < SPEC_MCF_COMPOSITE_SORT_ROUNDS; round++) {
        if (MCF_SORT_ITEMS > 96 || SPEC_MCF_COMPOSITE_SORT_ROUNDS > 1)
            mcf_scramble_items(round);
        for (int i = 0; i < MCF_SORT_ITEMS; i++) {
            int64_t perturb = ((int64_t)((i + 1) * (round + 3)) & 31) - 16;
            mcf_sort_items[i].red_cost += perturb;
            mcf_sort_items[i].abs_cost = mcf_abs64(mcf_sort_items[i].red_cost);
            mcf_sort_items[i].sequence ^= (int32_t)((round << 8) + i);
        }
        mcf_qsort_items(0, MCF_SORT_ITEMS - 1);
        for (int i = 0; i < MCF_SORT_ITEMS; i += 3) {
            local += mcf_sort_items[i].abs_cost;
            local ^= (uint64_t)(uint32_t)mcf_sort_items[i].arc->id << (i & 7);
            mcf_sort_items[i].arc->tail->mark ^= (int32_t)(local & 7u);
        }
    }
    for (int i = 0; i < SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS; i++) {
        int a = (i * 17 + 3) % MCF_SORT_ITEMS;
        int b = (i * 29 + 11) % MCF_SORT_ITEMS;
        int order = mcf_cost_compare(&mcf_sort_items[a], &mcf_sort_items[b]);
        local ^= (uint64_t)(uint32_t)(order + mcf_sort_items[a].sequence);
        local += mcf_sort_items[b].abs_cost;
    }
    return (uint32_t)(local ^ (local >> 32));
}

static void mcf_init_pricing(void)
{
    uint32_t seed = 0x13579bdfu;

    for (int i = 0; i < MCF_PRICE_NODES; i++) {
        seed = mcf_lcg_next(seed);
        mcf_price_nodes[i].potential = (int64_t)((seed >> 8) & 0x3ff) - 512;
        mcf_price_nodes[i].supply = (int64_t)(i & 7) - 3;
    }
    for (int i = 0; i < MCF_PRICE_ARCS; i++) {
        seed = mcf_lcg_next(seed);
        uint32_t tail = (seed >> 7) % MCF_PRICE_NODES;
        seed = mcf_lcg_next(seed);
        uint32_t head = (seed >> 11) % MCF_PRICE_NODES;

        mcf_price_arcs[i].tail = &mcf_price_nodes[tail];
        mcf_price_arcs[i].head = &mcf_price_nodes[head];
        mcf_price_arcs[i].cost = (int64_t)((seed >> 4) & 0x7ff) - 1024;
        mcf_price_arcs[i].ident = (i % 5 == 0) ? 0 : ((i & 1) ? 1 : 2);
        mcf_price_arcs[i].id = i;
    }
}

static int mcf_dual_infeasible(const mcf_price_arc_t *arc, int64_t red_cost)
{
    return ((red_cost < 0 && arc->ident == 1) ||
            (red_cost > 0 && arc->ident == 2));
}

static void mcf_basket_insert(mcf_price_arc_t *arc, int64_t red_cost)
{
    uint64_t abs_cost = mcf_abs64(red_cost);
    int pos = MCF_PRICE_BASKET - 1;

    if (mcf_price_basket[pos].arc != 0 &&
        abs_cost <= mcf_price_basket[pos].abs_cost)
        return;
    while (pos > 0) {
        if (mcf_price_basket[pos - 1].arc != 0 &&
            mcf_price_basket[pos - 1].abs_cost >= abs_cost)
            break;
        mcf_price_basket[pos] = mcf_price_basket[pos - 1];
        pos--;
    }
    mcf_price_basket[pos].arc = arc;
    mcf_price_basket[pos].red_cost = red_cost;
    mcf_price_basket[pos].abs_cost = abs_cost;
}

__attribute__((noinline)) static uint32_t mcf_pricing_phase(void)
{
    uint64_t local = 0;

    for (int round = 0; round < SPEC_MCF_COMPOSITE_PRICE_ROUNDS; round++) {
        for (int i = 0; i < MCF_PRICE_BASKET; i++) {
            mcf_price_basket[i].arc = 0;
            mcf_price_basket[i].red_cost = 0;
            mcf_price_basket[i].abs_cost = 0;
        }
        int step = 1 + (round & 7);
        for (int i = round % MCF_PRICE_ARCS; i < MCF_PRICE_ARCS; i += step) {
            mcf_price_arc_t *arc = &mcf_price_arcs[i];
            int64_t red_cost = arc->cost - arc->tail->potential +
                               arc->head->potential;
            if (arc->ident > 0 && mcf_dual_infeasible(arc, red_cost))
                mcf_basket_insert(arc, red_cost);
        }
        for (int i = 0; i < MCF_PRICE_BASKET; i++) {
            if (mcf_price_basket[i].arc != 0) {
                local += mcf_price_basket[i].abs_cost;
                local ^= (uint64_t)(uint32_t)mcf_price_basket[i].arc->id <<
                         (i & 7);
                mcf_price_basket[i].arc->tail->potential +=
                    (mcf_price_basket[i].red_cost > 0) ? 1 : -1;
            }
        }
    }
    return (uint32_t)(local ^ (local >> 32));
}

static void mcf_warmup(void)
{
    uint64_t state = 0x6a09e667f3bcc909ull;

    for (int i = 0; i < MCF_SORT_ITEMS; i++) {
        mcf_sort_item_t *item = &mcf_sort_items[(i * 73 + 19) % MCF_SORT_ITEMS];
        state ^= item->abs_cost + (uint64_t)(uint32_t)item->sequence;
        state += (uint64_t)item->arc->tail->potential;
        item->sequence ^= (int32_t)(state >> 17);
    }
    for (int i = 0; i < MCF_PRICE_ARCS; i++) {
        mcf_price_arc_t *arc = &mcf_price_arcs[(i * 193 + 31) % MCF_PRICE_ARCS];
        state += (uint64_t)(arc->cost + arc->tail->potential -
                            arc->head->potential);
        arc->tail->supply ^= (int64_t)(state & 3u);
    }
    mcf_composite_checksum ^= (uint32_t)(state ^ (state >> 32));
}

int main(void)
{
    mcf_init_sort();
    mcf_init_pricing();
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    if (SPEC_MCF_COMPOSITE_WARMUP)
        mcf_warmup();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    uint32_t sort_sum = mcf_sort_phase();
    uint32_t price_sum = mcf_pricing_phase();
    mcf_composite_checksum = sort_sum ^ (price_sum << 1) ^ (price_sum >> 31);
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("%s config sort_rounds=%u sort_tail_items=%u price_rounds=%u "
           "sort_items=%u price_nodes=%u price_arcs=%u price_basket=%u "
           "warmup=%u target_sort_ppm=%u\n",
           SPEC_MCF_COMPOSITE_NAME,
           (unsigned int)SPEC_MCF_COMPOSITE_SORT_ROUNDS,
           (unsigned int)SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS,
           (unsigned int)SPEC_MCF_COMPOSITE_PRICE_ROUNDS,
           (unsigned int)MCF_SORT_ITEMS,
           (unsigned int)MCF_PRICE_NODES,
           (unsigned int)MCF_PRICE_ARCS,
           (unsigned int)MCF_PRICE_BASKET,
           (unsigned int)SPEC_MCF_COMPOSITE_WARMUP,
           (unsigned int)SPEC_MCF_COMPOSITE_TARGET_SORT_PPM);
    printf("%s checksum=%u\n", SPEC_MCF_COMPOSITE_NAME,
           (unsigned int)mcf_composite_checksum);
    return mcf_composite_checksum == 0;
}

#endif
