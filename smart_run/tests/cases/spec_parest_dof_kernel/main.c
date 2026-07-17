/*
 * 510.parest_r representative DoF/sparsity setup kernel.
 *
 * This is not SPEC source code. It models the train/test-visible deal.II
 * phases: local-to-global DoF insertion, row sorting and deduplication,
 * constraint condensation, and indirect sparsity traversal.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_PAREST_DOF_N
#define SPEC_PAREST_DOF_N 24
#endif
#ifndef SPEC_PAREST_DOF_WIDTH
#define SPEC_PAREST_DOF_WIDTH 5
#endif
#ifndef SPEC_PAREST_DOF_CONSTRAINTS
#define SPEC_PAREST_DOF_CONSTRAINTS 4
#endif
#ifndef SPEC_PAREST_DOF_PASSES
#define SPEC_PAREST_DOF_PASSES 1
#endif

#define N SPEC_PAREST_DOF_N
#define W SPEC_PAREST_DOF_WIDTH
#define NNZ (N * W)

static uint16_t columns[NNZ];
static uint16_t row_count[N];
static uint16_t constraints[SPEC_PAREST_DOF_CONSTRAINTS][3];
static uint16_t permutation[N];
static uint32_t row_value[N];
static volatile uint32_t checksum;

static void insert_sorted(uint16_t *row, uint16_t *count, uint16_t value)
{
    int pos = *count;
    if (pos >= W)
        pos = W - 1;
    while (pos > 0 && row[pos - 1] > value) {
        if (pos < W)
            row[pos] = row[pos - 1];
        pos--;
    }
    row[pos] = value;
    if (*count < W)
        (*count)++;
}

static void build_sparsity(int pass)
{
    for (int cell = 0; cell < N; cell++) {
        uint16_t local[W];
        for (int j = 0; j < W; j++)
            local[j] = (uint16_t)((cell * 5 + j * j + pass * 3 + 1) % N);

        for (int i = 0; i < W; i++) {
            int row_id = local[i];
            uint16_t *row = &columns[row_id * W];
            for (int j = 0; j < W; j++)
                insert_sorted(row, &row_count[row_id], local[j]);
        }
    }
}

static void condense_constraints(void)
{
    for (int c = 0; c < SPEC_PAREST_DOF_CONSTRAINTS; c++) {
        int slave = constraints[c][0];
        int master0 = constraints[c][1];
        int master1 = constraints[c][2];
        uint16_t *row = &columns[slave * W];
        insert_sorted(row, &row_count[slave], (uint16_t)master0);
        insert_sorted(row, &row_count[slave], (uint16_t)master1);

        for (int i = 0; i < N; i++) {
            uint16_t *candidate = &columns[i * W];
            for (int j = 0; j < row_count[i]; j++) {
                if (candidate[j] == slave)
                    candidate[j] = (uint16_t)(((i + c) & 1) ? master0 : master1);
            }
        }
    }
}

static void reorder_rows(void)
{
    for (int i = 0; i < N; i++)
        permutation[i] = (uint16_t)i;
    for (int i = 1; i < N; i++) {
        uint16_t value = permutation[i];
        int j = i;
        while (j > 0 && row_count[permutation[j - 1]] > row_count[value]) {
            permutation[j] = permutation[j - 1];
            j--;
        }
        permutation[j] = value;
    }
}

static uint32_t dof_kernel(void)
{
    uint32_t acc = 0x510d0f17u;
    for (int pass = 0; pass < SPEC_PAREST_DOF_PASSES; pass++) {
        for (int i = 0; i < N; i++)
            row_count[i] = 0;
        build_sparsity(pass);
        condense_constraints();
        reorder_rows();

        for (int p = 0; p < N; p++) {
            int row_id = permutation[p];
            uint32_t value = row_value[row_id] ^ (uint32_t)row_count[row_id];
            for (int j = 0; j < row_count[row_id]; j++) {
                int col = columns[row_id * W + j];
                value = (value << 5) ^ (value >> 3) ^ row_value[col] ^ (uint32_t)col;
            }
            row_value[row_id] = value + (uint32_t)(p + pass * 17);
            acc ^= value;
        }
    }
    return acc;
}

int main(void)
{
    for (int i = 0; i < N; i++)
        row_value[i] = (uint32_t)i * 2654435761u + 0x5102017u;
    for (int c = 0; c < SPEC_PAREST_DOF_CONSTRAINTS; c++) {
        constraints[c][0] = (uint16_t)((c * 7 + 3) % N);
        constraints[c][1] = (uint16_t)((c * 11 + 5) % N);
        constraints[c][2] = (uint16_t)((c * 13 + 9) % N);
    }

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = dof_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_parest_dof_kernel config n=%u width=%u constraints=%u passes=%u\n",
           (unsigned int)N, (unsigned int)W,
           (unsigned int)SPEC_PAREST_DOF_CONSTRAINTS,
           (unsigned int)SPEC_PAREST_DOF_PASSES);
    printf("spec_parest_dof_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
