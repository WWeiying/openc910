/*
 * spec_exchange2_search_kernel: exchange2-like recursive search kernel.
 *
 * This is not SPEC exchange2 source code. It models the integer recursive
 * search, board-state update, transposition hashing, and branch-heavy pruning
 * behavior expected from 548.exchange2_r.
 */

#include <stdint.h>
#include <stdio.h>
#include "spec_composition_markers.h"
#include "spec_profile_footprint.h"

#ifndef SPEC_EXCHANGE2_POSITIONS
#define SPEC_EXCHANGE2_POSITIONS 1
#endif

#ifndef SPEC_EXCHANGE2_DEPTH
#define SPEC_EXCHANGE2_DEPTH 2
#endif

#ifndef SPEC_EXCHANGE2_MOVES
#define SPEC_EXCHANGE2_MOVES 6
#endif

#ifndef SPEC_EXCHANGE2_TABLE
#define SPEC_EXCHANGE2_TABLE 64
#endif

#define POSITIONS SPEC_EXCHANGE2_POSITIONS
#define DEPTH SPEC_EXCHANGE2_DEPTH
#define MOVES SPEC_EXCHANGE2_MOVES
#define TABLE SPEC_EXCHANGE2_TABLE
#define CELLS 64

typedef struct {
    uint8_t cell[CELLS];
    uint64_t key;
    int side;
} position_t;

typedef struct {
    uint16_t a;
    uint16_t b;
    int16_t score;
} move_t;

typedef struct {
    uint64_t key;
    int16_t value;
    int8_t depth;
} entry_t;

static position_t positions[POSITIONS];
static entry_t table[TABLE];
static int16_t history[CELLS][CELLS];
static volatile uint32_t checksum;

static uint32_t lcg_next(uint32_t x)
{
    return x * 1664525u + 1013904223u;
}

static void init_positions(void)
{
    uint32_t seed = 0x5482017u;

    for (int p = 0; p < POSITIONS; p++) {
        positions[p].key = (uint64_t)p << 48;
        positions[p].side = p & 1;
        for (int i = 0; i < CELLS; i++) {
            seed = lcg_next(seed);
            positions[p].cell[i] = (uint8_t)((seed >> 27) & 3u);
            positions[p].key ^= ((uint64_t)positions[p].cell[i] + 1u) << (i & 31);
        }
    }

    for (int i = 0; i < TABLE; i++) {
        table[i].key = 0;
        table[i].value = 0;
        table[i].depth = -1;
    }

    for (int i = 0; i < CELLS; i++)
        for (int j = 0; j < CELLS; j++)
            history[i][j] = (int16_t)((i * 5 + j * 7) & 63);
}

static int evaluate(const position_t *p)
{
    int acc = 0;

    for (int i = 0; i < CELLS; i++) {
        int v = p->cell[i];
        int n0 = p->cell[(i + 1) & 63];
        int n1 = p->cell[(i + 8) & 63];
        if (v == p->side + 1)
            acc += 11 + ((n0 == v) << 2) - (n1 == 0);
        else if (v != 0)
            acc -= 9 + ((n1 == v) << 1);
        else
            acc += ((i ^ p->side) & 3) - 1;
    }

    return acc;
}

static int generate_moves(const position_t *p, move_t *moves)
{
    int n = 0;

    for (int i = 0; i < CELLS && n < MOVES; i++) {
        if (((p->cell[i] + i + p->side) & 3) == 0)
            continue;

        int j = (i * 9 + 7 + p->side) & 63;
        int delta = (int)p->cell[i] - (int)p->cell[j];
        moves[n].a = (uint16_t)i;
        moves[n].b = (uint16_t)j;
        moves[n].score = (int16_t)(history[i][j] + delta * 17 + ((p->key >> (i & 15)) & 31));
        n++;
    }

    return n;
}

static void sort_moves(move_t *moves, int n)
{
    for (int i = 1; i < n; i++) {
        move_t m = moves[i];
        int j = i - 1;
        while (j >= 0 && moves[j].score < m.score) {
            moves[j + 1] = moves[j];
            j--;
        }
        moves[j + 1] = m;
    }
}

static void apply_move(position_t *p, move_t m)
{
    uint8_t tmp = p->cell[m.a];
    p->cell[m.a] = (uint8_t)((p->cell[m.b] + p->side + 1) & 3u);
    p->cell[m.b] = tmp;
    p->key ^= ((uint64_t)m.a << 7) ^ ((uint64_t)m.b << 31) ^ 0x9e3779b97f4a7c15ull;
    p->side ^= 1;
}

static int search(position_t p, int depth, int alpha, int beta)
{
    int idx = (int)(p.key & (TABLE - 1));
    if (table[idx].key == p.key && table[idx].depth >= depth)
        return table[idx].value;

    if (depth == 0)
        return evaluate(&p);

    move_t moves[MOVES];
    int n = generate_moves(&p, moves);
    sort_moves(moves, n);

    int best = -30000;
    for (int i = 0; i < n; i++) {
        position_t child = p;
        apply_move(&child, moves[i]);
        int score = -search(child, depth - 1, -beta, -alpha);
        if (score > best)
            best = score;
        if (score > alpha)
            alpha = score;
        if (alpha >= beta) {
            history[moves[i].a][moves[i].b] += (int16_t)(depth * depth);
            break;
        }
    }

    table[idx].key = p.key;
    table[idx].value = (int16_t)best;
    table[idx].depth = (int8_t)depth;
    return best;
}

static uint32_t exchange2_kernel(void)
{
    int total = 0;
    for (int p = 0; p < POSITIONS; p++)
        total += search(positions[p], DEPTH, -30000, 30000);
    return (uint32_t)total ^ (uint32_t)table[total & (TABLE - 1)].key;
}

static uint32_t minimum_scan_phase(void)
{
    int best = 0x7fffffff;
    uint32_t acc = 0x548a11u;
    for (int i = 0; i < TABLE; i++) {
        int value = table[i].value + history[i & 63][(i * 7) & 63];
        if (value < best)
            best = value;
        acc ^= (uint32_t)(value * 33 + best);
    }
    return acc;
}

static void reset_transposition_table(void)
{
    for (int i = 0; i < TABLE; i++) {
        table[i].key = 0;
        table[i].value = 0;
        table[i].depth = -1;
    }
}

int main(void)
{
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    init_positions();
    spec_profile_footprint_init();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    SPEC_COMPOSITION_PHASE0_BEGIN();
    checksum = 0;
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++) {
        reset_transposition_table();
        checksum ^= exchange2_kernel() + (uint32_t)round;
    }
    SPEC_COMPOSITION_PHASE0_END();
    SPEC_COMPOSITION_PHASE1_BEGIN();
    for (int round = 0; round < SPEC_COMPOSITION_SCALE; round++)
        checksum ^= minimum_scan_phase() + (uint32_t)round;
    SPEC_COMPOSITION_PHASE1_END();
    checksum ^= spec_profile_footprint_run();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_exchange2_search_kernel config positions=%u depth=%u moves=%u table=%u\n",
           (unsigned int)POSITIONS, (unsigned int)DEPTH,
           (unsigned int)MOVES, (unsigned int)TABLE);
    printf("spec_exchange2_search_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
