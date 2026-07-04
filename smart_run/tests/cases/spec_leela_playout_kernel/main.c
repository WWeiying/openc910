/*
 * spec_leela_playout_kernel: Leela/Go playout-like RTL kernel.
 *
 * This is not SPEC leela source code. It models the hot 541.leela_r behavior:
 * random playout selection, board-neighbor checks, pattern lookup, self-atari
 * filtering, group merge/remove updates, and UCT child selection.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_LEELA_BOARD
#define SPEC_LEELA_BOARD 13
#endif

#ifndef SPEC_LEELA_PLAYOUTS
#define SPEC_LEELA_PLAYOUTS 2
#endif

#ifndef SPEC_LEELA_MOVES
#define SPEC_LEELA_MOVES 12
#endif

#ifndef SPEC_LEELA_CHILDREN
#define SPEC_LEELA_CHILDREN 16
#endif

#if SPEC_LEELA_BOARD < 7
#error "SPEC_LEELA_BOARD must be at least 7"
#endif

#define BOARD SPEC_LEELA_BOARD
#define CELLS (BOARD * BOARD)
#define PLAYOUTS SPEC_LEELA_PLAYOUTS
#define MOVES SPEC_LEELA_MOVES
#define CHILDREN SPEC_LEELA_CHILDREN

typedef struct {
    uint16_t visits;
    int16_t wins;
    uint16_t move;
} child_t;

static uint8_t board[CELLS];
static uint8_t liberties[CELLS];
static uint16_t empty_list[CELLS];
static child_t children[CHILDREN];
static volatile uint32_t checksum;
static uint32_t rng_state = 5489u;

static uint32_t rng_next(void)
{
    rng_state ^= rng_state << 13;
    rng_state ^= rng_state >> 17;
    rng_state ^= rng_state << 5;
    return rng_state;
}

static int randint(int n)
{
    return (int)(rng_next() % (uint32_t)n);
}

static void init_board(void)
{
    for (int i = 0; i < CELLS; i++) {
        board[i] = 0;
        liberties[i] = 4;
        empty_list[i] = (uint16_t)i;
    }

    for (int i = 0; i < CHILDREN; i++) {
        children[i].visits = (uint16_t)(1 + (i * 7) % 97);
        children[i].wins = (int16_t)((i * 13) % 101);
        children[i].move = (uint16_t)(i % CELLS);
    }
}

static int get_extra_dir(int p, int dir)
{
    int x = p % BOARD;
    int y = p / BOARD;

    if (dir == 0 && y > 0)
        return p - BOARD;
    if (dir == 1 && x + 1 < BOARD)
        return p + 1;
    if (dir == 2 && y + 1 < BOARD)
        return p + BOARD;
    if (dir == 3 && x > 0)
        return p - 1;
    return -1;
}

static uint32_t pattern3(int p, int color)
{
    uint32_t pat = (uint32_t)color;
    for (int d = 0; d < 4; d++) {
        int n = get_extra_dir(p, d);
        pat = (pat << 2) ^ (uint32_t)((n >= 0) ? board[n] : 3);
    }
    return pat * 2654435761u;
}

static int no_eye_fill(int p, int color)
{
    int same = 0;
    int empty = 0;

    for (int d = 0; d < 4; d++) {
        int n = get_extra_dir(p, d);
        if (n < 0 || board[n] == color)
            same++;
        else if (board[n] == 0)
            empty++;
    }

    return !(same >= 3 && empty == 0);
}

static int self_atari(int p, int color)
{
    int libs = 0;
    int opp = 3 - color;

    for (int d = 0; d < 4; d++) {
        int n = get_extra_dir(p, d);
        if (n < 0)
            continue;
        if (board[n] == 0)
            libs += 1 + (liberties[p] & 1);
        else if (board[n] == opp)
            libs -= 1;
    }

    return libs <= 0;
}

static void update_board_fast(int p, int color)
{
    board[p] = (uint8_t)color;
    liberties[p] = 0;

    for (int d = 0; d < 4; d++) {
        int n = get_extra_dir(p, d);
        if (n >= 0) {
            if (board[n] == 0)
                liberties[p]++;
            else if (board[n] == (uint8_t)color)
                liberties[p] += liberties[n] > 0;
            else if (((pattern3(n, color) >> 5) & 3u) == 0) {
                board[n] = 0;
                liberties[n] = 4;
            } else if (liberties[n] > 0) {
                liberties[n]--;
            }
        }
    }
}

static int select_child(void)
{
    int best = 0;
    int best_score = -32768;

    for (int i = 0; i < CHILDREN; i++) {
        int exploit = (children[i].wins * 256) / (int)children[i].visits;
        int explore = (int)(1024 / (1 + children[i].visits));
        int score = exploit + explore + (int)(pattern3(children[i].move, 1) & 31u);
        if (score > best_score) {
            best_score = score;
            best = i;
        }
    }

    return best;
}

static uint32_t playout_kernel(void)
{
    uint32_t acc = 0;

    for (int p = 0; p < PLAYOUTS; p++) {
        int color = 1 + (p & 1);

        for (int m = 0; m < MOVES; m++) {
            int start = randint(CELLS);
            int chosen = -1;

            int scan_limit = (CELLS < 64) ? CELLS : 64;
            for (int k = 0; k < scan_limit; k++) {
                int idx = (start + k * 7) % CELLS;
                int move = empty_list[idx];
                if (board[move] == 0 &&
                    no_eye_fill(move, color) &&
                    !self_atari(move, color)) {
                    chosen = move;
                    break;
                }
            }

            if (chosen < 0)
                break;

            uint32_t pat = pattern3(chosen, color);
            update_board_fast(chosen, color);

            int child = select_child();
            children[child].visits++;
            children[child].wins += (int16_t)((pat & 1u) ? 1 : -1);
            acc ^= pat + (uint32_t)(child << (m & 7));
            color = 3 - color;
        }

        for (int i = 0; i < CELLS; i += 3)
            board[i] = 0;
        for (int i = 0; i < CELLS; i += 5)
            liberties[i] = 4;
    }

    return acc;
}

int main(void)
{
    init_board();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = playout_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_leela_playout_kernel config board=%u playouts=%u moves=%u children=%u\n",
           (unsigned int)BOARD, (unsigned int)PLAYOUTS,
           (unsigned int)MOVES, (unsigned int)CHILDREN);
    printf("spec_leela_playout_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
