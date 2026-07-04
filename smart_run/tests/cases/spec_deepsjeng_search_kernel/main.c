/*
 * spec_deepsjeng_search_kernel: chess-search-like RTL kernel.
 *
 * This is not SPEC deepsjeng source code. It models the hot 531.deepsjeng_r
 * behavior: bitboard attack generation, move ordering, make/unmake, recursive
 * search/qsearch control flow, evaluation, and transposition-table probing.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_DEEPSJENG_POSITIONS
#define SPEC_DEEPSJENG_POSITIONS 1
#endif

#ifndef SPEC_DEEPSJENG_DEPTH
#define SPEC_DEEPSJENG_DEPTH 1
#endif

#ifndef SPEC_DEEPSJENG_MOVES
#define SPEC_DEEPSJENG_MOVES 8
#endif

#ifndef SPEC_DEEPSJENG_QMOVES
#define SPEC_DEEPSJENG_QMOVES 0
#endif

#if SPEC_DEEPSJENG_DEPTH < 1
#error "SPEC_DEEPSJENG_DEPTH must be at least 1"
#endif

#define POSITIONS SPEC_DEEPSJENG_POSITIONS
#define DEPTH SPEC_DEEPSJENG_DEPTH
#define MAX_MOVES SPEC_DEEPSJENG_MOVES
#define QMOVES SPEC_DEEPSJENG_QMOVES
#define TT_SIZE 64

typedef struct {
    uint64_t white;
    uint64_t black;
    uint64_t queens;
    uint64_t rooks;
    uint64_t bishops;
    uint64_t knights;
    uint64_t key;
    int side;
} state_t;

typedef struct {
    uint16_t from;
    uint16_t to;
    int16_t score;
} move_t;

typedef struct {
    uint64_t key;
    int16_t value;
    int8_t depth;
} tt_entry_t;

static state_t states[POSITIONS];
static tt_entry_t ttable[TT_SIZE];
static int16_t history[64][64];
static volatile uint32_t checksum;

static uint32_t lcg_next(uint32_t x)
{
    return x * 1664525u + 1013904223u;
}

static uint32_t popcount64(uint64_t x)
{
    uint32_t c = 0;
    while (x != 0) {
        x &= x - 1;
        c++;
    }
    return c;
}

static int first_bit(uint64_t x)
{
    return __builtin_ctzll(x);
}

static uint64_t rook_attacks(int sq, uint64_t occ)
{
    uint64_t attacks = 0;
    int rank = sq & 56;
    int file = sq & 7;

    for (int s = sq + 1; (s & 7) != 0; s++) {
        attacks |= 1ull << s;
        if (occ & (1ull << s))
            break;
    }
    for (int s = sq - 1; s >= rank; s--) {
        attacks |= 1ull << s;
        if (occ & (1ull << s))
            break;
    }
    for (int s = sq + 8; s < 64; s += 8) {
        attacks |= 1ull << s;
        if (occ & (1ull << s))
            break;
    }
    for (int s = sq - 8; s >= file; s -= 8) {
        attacks |= 1ull << s;
        if (occ & (1ull << s))
            break;
    }
    return attacks;
}

static uint64_t bishop_attacks(int sq, uint64_t occ)
{
    uint64_t attacks = 0;
    const int dirs[4] = {9, 7, -7, -9};

    for (int d = 0; d < 4; d++) {
        int s = sq;
        int prev_file = s & 7;
        while (1) {
            s += dirs[d];
            if (s < 0 || s >= 64)
                break;
            int file = s & 7;
            if (file == 0 && prev_file == 7)
                break;
            if (file == 7 && prev_file == 0)
                break;
            attacks |= 1ull << s;
            if (occ & (1ull << s))
                break;
            prev_file = file;
        }
    }
    return attacks;
}

static void init_states(void)
{
    uint32_t seed = 0x10203040u;

    for (int i = 0; i < POSITIONS; i++) {
        seed = lcg_next(seed);
        states[i].white = ((uint64_t)seed << 32) ^ lcg_next(seed);
        seed = lcg_next(seed);
        states[i].black = (((uint64_t)seed << 32) ^ lcg_next(seed)) & ~states[i].white;
        states[i].rooks = states[i].white & 0x00ff00000000ff00ull;
        states[i].bishops = states[i].black & 0x0000ff0000ff0000ull;
        states[i].queens = (states[i].white ^ states[i].black) & 0x0000001818000000ull;
        states[i].knights = (states[i].white | states[i].black) & 0x0042000000004200ull;
        states[i].key = states[i].white ^ (states[i].black << 1) ^ ((uint64_t)i << 48);
        states[i].side = i & 1;
    }

    for (int i = 0; i < TT_SIZE; i++) {
        ttable[i].key = 0;
        ttable[i].value = 0;
        ttable[i].depth = -1;
    }

    for (int i = 0; i < 64; i++)
        for (int j = 0; j < 64; j++)
            history[i][j] = (int16_t)((i * 3 + j * 5) & 31);
}

static int evaluate(const state_t *s)
{
    int material = 5 * (int)popcount64(s->rooks) +
                   3 * (int)popcount64(s->bishops | s->knights) +
                   9 * (int)popcount64(s->queens);
    int mobility = 0;
    uint64_t occ = s->white | s->black;

    for (int sq = 0; sq < 64; sq += 7)
        mobility += (int)popcount64(rook_attacks(sq, occ) ^ bishop_attacks(sq, occ));

    return s->side ? (material - mobility) : (mobility - material);
}

static int see_like(const state_t *s, int from, int to)
{
    uint64_t occ = s->white | s->black;
    int attack_mix = (int)popcount64(rook_attacks(to, occ) | bishop_attacks(to, occ));
    int from_mix = (int)popcount64(rook_attacks(from, occ) ^ bishop_attacks(from, occ));
    return (attack_mix * 7) - (from_mix * 3) + history[from][to];
}

static int generate_moves(const state_t *s, move_t *moves)
{
    uint64_t occ = s->white | s->black;
    int n = 0;

    for (int sq = 0; sq < 64 && n < MAX_MOVES; sq++) {
        uint64_t bit = 1ull << sq;
        if ((occ & bit) == 0)
            continue;

        uint64_t a = rook_attacks(sq, occ) ^ bishop_attacks(sq, occ);
        while (a != 0 && n < MAX_MOVES) {
            int to = first_bit(a);
            moves[n].from = (uint16_t)sq;
            moves[n].to = (uint16_t)to;
            moves[n].score = (int16_t)(popcount64(a) * 8 + see_like(s, sq, to));
            a &= a - 1;
            n++;
        }
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

static void make_move(state_t *s, move_t m)
{
    uint64_t from = 1ull << m.from;
    uint64_t to = 1ull << m.to;
    uint64_t *side = s->side ? &s->black : &s->white;
    *side ^= from;
    *side ^= to;
    s->key ^= ((uint64_t)m.from << 17) ^ ((uint64_t)m.to << 41) ^ 0x9e3779b97f4a7c15ull;
    s->side ^= 1;
}

static int qsearch(state_t s, int alpha, int beta)
{
    int stand_pat = evaluate(&s);
    if (stand_pat >= beta)
        return beta;
    if (stand_pat > alpha)
        alpha = stand_pat;

    move_t moves[MAX_MOVES];
    int n = generate_moves(&s, moves);
    sort_moves(moves, n);

    for (int i = 0; i < n && i < QMOVES; i++) {
        if (moves[i].score < 12)
            break;
        state_t child = s;
        make_move(&child, moves[i]);
        int score = -evaluate(&child);
        if (score > alpha)
            alpha = score;
        if (alpha >= beta)
            break;
    }

    return alpha;
}

static int search(state_t s, int depth, int alpha, int beta)
{
    int idx = (int)(s.key & (TT_SIZE - 1));
    if (ttable[idx].key == s.key && ttable[idx].depth >= depth)
        return ttable[idx].value;

    if (depth == 0)
        return qsearch(s, alpha, beta);

    move_t moves[MAX_MOVES];
    int n = generate_moves(&s, moves);
    sort_moves(moves, n);

    int best = -32767;
    for (int i = 0; i < n && i < 10; i++) {
        state_t child = s;
        make_move(&child, moves[i]);
        int score = -search(child, depth - 1, -beta, -alpha);
        if (score > best)
            best = score;
        if (score > alpha)
            alpha = score;
        if (alpha >= beta) {
            history[moves[i].from][moves[i].to] += (int16_t)(depth * depth);
            break;
        }
    }

    ttable[idx].key = s.key;
    ttable[idx].value = (int16_t)best;
    ttable[idx].depth = (int8_t)depth;
    return best;
}

static uint32_t deepsjeng_kernel(void)
{
    uint32_t acc = 0;

    for (int i = 0; i < POSITIONS; i++) {
        int score = search(states[i], DEPTH, -30000, 30000);
        acc = (acc << 3) ^ (uint32_t)score ^ (uint32_t)states[i].key;
    }

    return acc;
}

int main(void)
{
    init_states();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = deepsjeng_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_deepsjeng_search_kernel config positions=%u depth=%u moves=%u qmoves=%u\n",
           (unsigned int)POSITIONS, (unsigned int)DEPTH,
           (unsigned int)MAX_MOVES, (unsigned int)QMOVES);
    printf("spec_deepsjeng_search_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
