/*
 * spec_mcf_kernel: mcf-like RTL kernel for the first SPEC-to-RTL path.
 *
 * This is not SPEC mcf source code.  It is a compact kernel shaped after the
 * dominant behavior in 505.mcf_r's pricing/basket scan: pointer-rich arc
 * traversal, reduced-cost calculation, branch filtering, and top candidate
 * maintenance.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_MCF_NODES
#define SPEC_MCF_NODES      32
#endif

#ifndef SPEC_MCF_ARCS
#define SPEC_MCF_ARCS       96
#endif

#ifndef SPEC_MCF_BASKET
#define SPEC_MCF_BASKET     8
#endif

#ifndef SPEC_MCF_PASSES
#define SPEC_MCF_PASSES     1
#endif

#if SPEC_MCF_NODES < 2
#error "SPEC_MCF_NODES must be at least 2"
#endif

#if SPEC_MCF_ARCS < SPEC_MCF_BASKET
#error "SPEC_MCF_ARCS must be greater than or equal to SPEC_MCF_BASKET"
#endif

#if SPEC_MCF_BASKET < 2
#error "SPEC_MCF_BASKET must be at least 2"
#endif

#if SPEC_MCF_PASSES < 1
#error "SPEC_MCF_PASSES must be at least 1"
#endif

#define NUM_NODES      SPEC_MCF_NODES
#define NUM_ARCS       SPEC_MCF_ARCS
#define BASKET_SIZE    SPEC_MCF_BASKET
#define PASSES         SPEC_MCF_PASSES

#define BASIC          0
#define AT_LOWER       1
#define AT_UPPER       2

typedef struct {
    int64_t potential;
    int64_t supply;
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
} basket_t;

static node_t nodes[NUM_NODES];
static arc_t arcs[NUM_ARCS];
static basket_t basket[BASKET_SIZE];
static volatile uint32_t checksum;

static uint32_t lcg_next(uint32_t x)
{
    return x * 1664525u + 1013904223u;
}

static void init_network(void)
{
    uint32_t seed = 0x13579bdfu;

    for (int i = 0; i < NUM_NODES; i++) {
        seed = lcg_next(seed);
        nodes[i].potential = (int64_t)((seed >> 8) & 0x3ff) - 512;
        nodes[i].supply = (int64_t)(i & 7) - 3;
    }

    for (int i = 0; i < NUM_ARCS; i++) {
        seed = lcg_next(seed);
        uint32_t tail = (seed >> 7) % NUM_NODES;
        seed = lcg_next(seed);
        uint32_t head = (seed >> 11) % NUM_NODES;

        arcs[i].tail = &nodes[tail];
        arcs[i].head = &nodes[head];
        arcs[i].cost = (int64_t)((seed >> 4) & 0x7ff) - 1024;
        arcs[i].ident = (i % 5 == 0) ? BASIC : ((i & 1) ? AT_LOWER : AT_UPPER);
        arcs[i].id = i;
    }
}

static uint64_t abs64(int64_t x)
{
    return (x < 0) ? (uint64_t)(-x) : (uint64_t)x;
}

static int dual_infeasible(const arc_t *arc, int64_t red_cost)
{
    return ((red_cost < 0 && arc->ident == AT_LOWER) ||
            (red_cost > 0 && arc->ident == AT_UPPER));
}

static void basket_insert(arc_t *arc, int64_t red_cost)
{
    uint64_t abs_cost = abs64(red_cost);
    int pos = BASKET_SIZE - 1;

    if (basket[pos].arc != 0 && abs_cost <= basket[pos].abs_cost)
        return;

    while (pos > 0) {
        if (basket[pos - 1].arc != 0 && basket[pos - 1].abs_cost >= abs_cost)
            break;
        basket[pos] = basket[pos - 1];
        pos--;
    }

    basket[pos].arc = arc;
    basket[pos].red_cost = red_cost;
    basket[pos].abs_cost = abs_cost;
}

static uint32_t mcf_like_pricing_kernel(void)
{
    uint64_t local = 0;

    for (int pass = 0; pass < PASSES; pass++) {
        for (int i = 0; i < BASKET_SIZE; i++) {
            basket[i].arc = 0;
            basket[i].red_cost = 0;
            basket[i].abs_cost = 0;
        }

        int step = 1 + (pass & 7);
        for (int i = pass; i < NUM_ARCS; i += step) {
            arc_t *arc = &arcs[i];
            int64_t red_cost = arc->cost - arc->tail->potential + arc->head->potential;

            if (arc->ident > BASIC && dual_infeasible(arc, red_cost))
                basket_insert(arc, red_cost);
        }

        for (int i = 0; i < BASKET_SIZE; i++) {
            if (basket[i].arc != 0) {
                local += basket[i].abs_cost;
                local ^= (uint64_t)(uint32_t)basket[i].arc->id << (i & 7);
                basket[i].arc->tail->potential += (basket[i].red_cost > 0) ? 1 : -1;
            }
        }
    }

    return (uint32_t)(local ^ (local >> 32));
}

int main(void)
{
    init_network();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = mcf_like_pricing_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_mcf_kernel config nodes=%u arcs=%u basket=%u passes=%u\n",
           (unsigned int)NUM_NODES,
           (unsigned int)NUM_ARCS,
           (unsigned int)BASKET_SIZE,
           (unsigned int)PASSES);
    printf("spec_mcf_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
