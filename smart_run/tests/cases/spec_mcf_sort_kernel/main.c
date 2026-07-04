/*
 * spec_mcf_sort_kernel: mcf sort/comparator-like RTL kernel.
 *
 * This is not SPEC mcf source code. It is shaped after the dominant
 * 505.mcf_r test SimPoint phase where spec_qsort and cost_compare account for
 * most of the interval, with primal_bea_mpp-style reduced-cost data feeding the
 * comparator.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_MCF_SORT_ITEMS
#define SPEC_MCF_SORT_ITEMS 96
#endif

#ifndef SPEC_MCF_SORT_PASSES
#define SPEC_MCF_SORT_PASSES 1
#endif

#if SPEC_MCF_SORT_ITEMS < 8
#error "SPEC_MCF_SORT_ITEMS must be at least 8"
#endif

#if SPEC_MCF_SORT_PASSES < 1
#error "SPEC_MCF_SORT_PASSES must be at least 1"
#endif

#define ITEMS SPEC_MCF_SORT_ITEMS
#define PASSES SPEC_MCF_SORT_PASSES

typedef struct {
    int64_t potential;
    int32_t mark;
} node_t;

typedef struct {
    node_t *tail;
    node_t *head;
    int64_t cost;
    int32_t ident;
    int32_t id;
} arc_t;

typedef struct {
    arc_t *arc;
    int64_t red_cost;
    uint64_t abs_cost;
    int32_t sequence;
} basket_t;

static node_t nodes[ITEMS + 17];
static arc_t arcs[ITEMS];
static basket_t basket[ITEMS];
static volatile uint32_t checksum;

static uint32_t lcg_next(uint32_t x)
{
    return x * 1664525u + 1013904223u;
}

static uint64_t abs64(int64_t x)
{
    return (x < 0) ? (uint64_t)(-x) : (uint64_t)x;
}

static void init_items(void)
{
    uint32_t seed = 0x2468ace1u;

    for (int i = 0; i < ITEMS + 17; i++) {
        seed = lcg_next(seed);
        nodes[i].potential = (int64_t)((seed >> 9) & 0x7ff) - 1024;
        nodes[i].mark = (int32_t)(seed & 7u);
    }

    for (int i = 0; i < ITEMS; i++) {
        seed = lcg_next(seed);
        uint32_t tail = (seed >> 5) % (ITEMS + 17);
        seed = lcg_next(seed);
        uint32_t head = (seed >> 13) % (ITEMS + 17);

        arcs[i].tail = &nodes[tail];
        arcs[i].head = &nodes[head];
        arcs[i].cost = (int64_t)((seed >> 3) & 0xfff) - 2048;
        arcs[i].ident = (int32_t)((seed >> 19) & 3u);
        arcs[i].id = i;

        int64_t red_cost = arcs[i].cost - arcs[i].tail->potential +
                           arcs[i].head->potential;
        basket[i].arc = &arcs[i];
        basket[i].red_cost = red_cost;
        basket[i].abs_cost = abs64(red_cost);
        basket[i].sequence = (int32_t)(seed & 0xffffu);
    }
}

static int cost_compare(const basket_t *a, const basket_t *b)
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

static void swap_items(int a, int b)
{
    basket_t tmp = basket[a];
    basket[a] = basket[b];
    basket[b] = tmp;
}

static int partition_items(int lo, int hi)
{
    basket_t pivot = basket[hi];
    int store = lo;

    for (int i = lo; i < hi; i++) {
        if (cost_compare(&basket[i], &pivot) < 0) {
            swap_items(i, store);
            store++;
        }
    }

    swap_items(store, hi);
    return store;
}

static void qsort_items(int lo, int hi)
{
    while (lo < hi) {
        int mid = partition_items(lo, hi);

        if (mid - lo < hi - mid) {
            if (lo < mid - 1)
                qsort_items(lo, mid - 1);
            lo = mid + 1;
        } else {
            if (mid + 1 < hi)
                qsort_items(mid + 1, hi);
            hi = mid - 1;
        }
    }
}

static uint32_t sort_kernel(void)
{
    uint64_t local = 0;

    for (int pass = 0; pass < PASSES; pass++) {
        for (int i = 0; i < ITEMS; i++) {
            int64_t perturb = ((int64_t)((i + 1) * (pass + 3)) & 31) - 16;
            basket[i].red_cost += perturb;
            basket[i].abs_cost = abs64(basket[i].red_cost);
            basket[i].sequence ^= (int32_t)((pass << 8) + i);
        }

        qsort_items(0, ITEMS - 1);

        for (int i = 0; i < ITEMS; i += 3) {
            local += basket[i].abs_cost;
            local ^= (uint64_t)(uint32_t)basket[i].arc->id << (i & 7);
            basket[i].arc->tail->mark ^= (int32_t)(local & 7u);
        }
    }

    return (uint32_t)(local ^ (local >> 32));
}

int main(void)
{
    init_items();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = sort_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_mcf_sort_kernel config items=%u passes=%u\n",
           (unsigned int)ITEMS,
           (unsigned int)PASSES);
    printf("spec_mcf_sort_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
