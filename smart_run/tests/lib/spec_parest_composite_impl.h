#ifndef SPEC_PAREST_COMPOSITE_IMPL_H
#define SPEC_PAREST_COMPOSITE_IMPL_H

#include <stdint.h>
#include <stdio.h>

#ifndef PAREST_DOF_N
#define PAREST_DOF_N 24
#endif
#ifndef PAREST_DOF_WIDTH
#define PAREST_DOF_WIDTH 5
#endif
#define PAREST_DOF_NNZ (PAREST_DOF_N * PAREST_DOF_WIDTH)
#ifndef PAREST_DOF_CONSTRAINTS
#define PAREST_DOF_CONSTRAINTS 4
#endif
#ifndef PAREST_SPARSE_N
#define PAREST_SPARSE_N 48
#endif
#ifndef PAREST_SPARSE_NZ
#define PAREST_SPARSE_NZ 5
#endif
#define PAREST_SPARSE_NNZ (PAREST_SPARSE_N * PAREST_SPARSE_NZ)
#ifndef SPEC_PAREST_COMPOSITE_WARMUP
#define SPEC_PAREST_COMPOSITE_WARMUP 0
#endif

#ifndef SPEC_PAREST_COMPOSITE_DOF_PASSES
#define SPEC_PAREST_COMPOSITE_DOF_PASSES 1
#endif
#ifndef SPEC_PAREST_COMPOSITE_SPARSE_ITERS
#define SPEC_PAREST_COMPOSITE_SPARSE_ITERS 20
#endif
#ifndef SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS
#define SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS 13
#endif
#if SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS > PAREST_SPARSE_N
#error "SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS exceeds sparse vector size"
#endif
#define SPEC_PAREST_COMPOSITE_TARGET_DOF_PPM 193611

static uint16_t parest_columns[PAREST_DOF_NNZ];
static uint16_t parest_row_count[PAREST_DOF_N];
static uint16_t parest_constraints[PAREST_DOF_CONSTRAINTS][3];
static uint16_t parest_permutation[PAREST_DOF_N];
static uint32_t parest_row_value[PAREST_DOF_N];

static uint16_t parest_col[PAREST_SPARSE_NNZ];
static float parest_val[PAREST_SPARSE_NNZ];
static float parest_x[PAREST_SPARSE_N];
static float parest_r[PAREST_SPARSE_N];
static float parest_pvec[PAREST_SPARSE_N];
static float parest_y[PAREST_SPARSE_N];
static volatile uint32_t parest_composite_checksum;

static void parest_insert_sorted(uint16_t *row, uint16_t *count, uint16_t value)
{
    int pos = *count;
    if (pos >= PAREST_DOF_WIDTH)
        pos = PAREST_DOF_WIDTH - 1;
    while (pos > 0 && row[pos - 1] > value) {
        if (pos < PAREST_DOF_WIDTH)
            row[pos] = row[pos - 1];
        pos--;
    }
    row[pos] = value;
    if (*count < PAREST_DOF_WIDTH)
        (*count)++;
}

static void parest_build_sparsity(int pass)
{
    for (int cell = 0; cell < PAREST_DOF_N; cell++) {
        uint16_t local[PAREST_DOF_WIDTH];
        for (int j = 0; j < PAREST_DOF_WIDTH; j++)
            local[j] = (uint16_t)((cell * 5 + j * j + pass * 3 + 1) %
                                  PAREST_DOF_N);
        for (int i = 0; i < PAREST_DOF_WIDTH; i++) {
            int row_id = local[i];
            uint16_t *row = &parest_columns[row_id * PAREST_DOF_WIDTH];
            for (int j = 0; j < PAREST_DOF_WIDTH; j++)
                parest_insert_sorted(row, &parest_row_count[row_id], local[j]);
        }
    }
}

static void parest_condense_constraints(void)
{
    for (int c = 0; c < PAREST_DOF_CONSTRAINTS; c++) {
        int slave = parest_constraints[c][0];
        int master0 = parest_constraints[c][1];
        int master1 = parest_constraints[c][2];
        uint16_t *row = &parest_columns[slave * PAREST_DOF_WIDTH];
        parest_insert_sorted(row, &parest_row_count[slave], (uint16_t)master0);
        parest_insert_sorted(row, &parest_row_count[slave], (uint16_t)master1);
        for (int i = 0; i < PAREST_DOF_N; i++) {
            uint16_t *candidate = &parest_columns[i * PAREST_DOF_WIDTH];
            for (int j = 0; j < parest_row_count[i]; j++) {
                if (candidate[j] == slave)
                    candidate[j] = (uint16_t)(((i + c) & 1) ? master0 : master1);
            }
        }
    }
}

static void parest_reorder_rows(void)
{
    for (int i = 0; i < PAREST_DOF_N; i++)
        parest_permutation[i] = (uint16_t)i;
    for (int i = 1; i < PAREST_DOF_N; i++) {
        uint16_t value = parest_permutation[i];
        int j = i;
        while (j > 0 &&
               parest_row_count[parest_permutation[j - 1]] >
               parest_row_count[value]) {
            parest_permutation[j] = parest_permutation[j - 1];
            j--;
        }
        parest_permutation[j] = value;
    }
}

__attribute__((noinline)) static uint32_t parest_dof_phase(void)
{
    uint32_t acc = 0x510d0f17u;

    for (int pass = 0; pass < SPEC_PAREST_COMPOSITE_DOF_PASSES; pass++) {
        for (int i = 0; i < PAREST_DOF_N; i++)
            parest_row_count[i] = 0;
        parest_build_sparsity(pass);
        parest_condense_constraints();
        parest_reorder_rows();
        for (int p = 0; p < PAREST_DOF_N; p++) {
            int row_id = parest_permutation[p];
            uint32_t value = parest_row_value[row_id] ^
                             (uint32_t)parest_row_count[row_id];
            for (int j = 0; j < parest_row_count[row_id]; j++) {
                int col = parest_columns[row_id * PAREST_DOF_WIDTH + j];
                value = (value << 5) ^ (value >> 3) ^
                        parest_row_value[col] ^ (uint32_t)col;
            }
            parest_row_value[row_id] = value + (uint32_t)(p + pass * 17);
            acc ^= value;
        }
    }
    return acc;
}

static void parest_init(void)
{
    for (int i = 0; i < PAREST_DOF_N; i++)
        parest_row_value[i] = (uint32_t)i * 2654435761u + 0x5102017u;
    for (int c = 0; c < PAREST_DOF_CONSTRAINTS; c++) {
        parest_constraints[c][0] = (uint16_t)((c * 7 + 3) % PAREST_DOF_N);
        parest_constraints[c][1] = (uint16_t)((c * 11 + 5) % PAREST_DOF_N);
        parest_constraints[c][2] = (uint16_t)((c * 13 + 9) % PAREST_DOF_N);
    }

    for (int i = 0; i < PAREST_SPARSE_N; i++) {
        parest_x[i] = (float)((i * 11) & 31) * 0.03125f;
        parest_r[i] = 1.0f + (float)((i * 7) & 15) * 0.0625f;
        parest_pvec[i] = parest_r[i];
        for (int k = 0; k < PAREST_SPARSE_NZ; k++) {
            int idx = i * PAREST_SPARSE_NZ + k;
            parest_col[idx] = (uint16_t)((i + k * k + 3 * k + 1) %
                                         PAREST_SPARSE_N);
            parest_val[idx] = (k == 0) ? 2.0f :
                (0.125f + (float)((i + k) & 7) * 0.015625f);
        }
    }
}

static uint32_t parest_fold_float(float x)
{
    int32_t v = (int32_t)(x * 8192.0f);
    return (uint32_t)v ^ ((uint32_t)v >> 9);
}

__attribute__((noinline)) static void parest_spmv(const float *in, float *out)
{
    for (int i = 0; i < PAREST_SPARSE_N; i++) {
        float sum = 0.0f;
        for (int k = 0; k < PAREST_SPARSE_NZ; k++) {
            int idx = i * PAREST_SPARSE_NZ + k;
            sum += parest_val[idx] * in[parest_col[idx]];
        }
        out[i] = sum;
    }
}

__attribute__((noinline)) static uint32_t parest_sparse_phase(void)
{
    uint32_t acc = 0x5102017u;

    for (int it = 0; it < SPEC_PAREST_COMPOSITE_SPARSE_ITERS; it++) {
        parest_spmv(parest_pvec, parest_y);
        float rr = 0.0f;
        float py = 0.0f;
        for (int i = 0; i < PAREST_SPARSE_N; i++) {
            rr += parest_r[i] * parest_r[i];
            py += parest_pvec[i] * parest_y[i];
        }
        float alpha = rr / (py + 0.125f);
        float rr_new = 0.0f;
        for (int i = 0; i < PAREST_SPARSE_N; i++) {
            parest_x[i] += alpha * parest_pvec[i];
            parest_r[i] -= alpha * parest_y[i];
            rr_new += parest_r[i] * parest_r[i];
            acc ^= parest_fold_float(parest_x[i] + parest_r[i]) +
                   (uint32_t)(i * 17 + it);
        }
        float beta = rr_new / (rr + 0.125f);
        for (int i = 0; i < PAREST_SPARSE_N; i++) {
            if (((i + it) & 7) == 0)
                parest_pvec[i] = parest_r[i];
            else
                parest_pvec[i] = parest_r[i] + beta * parest_pvec[i];
            acc = (acc << 4) ^ (acc >> 5) ^
                  parest_fold_float(parest_pvec[i]);
        }
    }
#if SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS > 0
    parest_spmv(parest_pvec, parest_y);
    float rr = 0.0f;
    float py = 0.0f;
    for (int i = 0; i < SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS; i++) {
        rr += parest_r[i] * parest_r[i];
        py += parest_pvec[i] * parest_y[i];
    }
    float alpha = rr / (py + 0.125f);
    float rr_new = 0.0f;
    for (int i = 0; i < SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS; i++) {
        parest_x[i] += alpha * parest_pvec[i];
        parest_r[i] -= alpha * parest_y[i];
        rr_new += parest_r[i] * parest_r[i];
        acc ^= parest_fold_float(parest_x[i] + parest_r[i]) + (uint32_t)i;
    }
    float beta = rr_new / (rr + 0.125f);
    for (int i = 0; i < SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS; i++) {
        parest_pvec[i] = parest_r[i] + beta * parest_pvec[i];
        acc = (acc << 4) ^ (acc >> 5) ^
              parest_fold_float(parest_pvec[i]);
    }
#endif
    return acc;
}

static void parest_warmup(void)
{
    uint32_t acc = 0x9e3779b9u;

    parest_spmv(parest_pvec, parest_y);
    for (int i = 0; i < PAREST_SPARSE_N; i++) {
        int j = (i * 193 + 17) % PAREST_SPARSE_N;
        parest_r[j] += parest_y[i] * 0.0009765625f;
        acc ^= parest_fold_float(parest_r[j] + parest_pvec[i]);
    }
    for (int i = 0; i < PAREST_DOF_N; i++)
        acc = (acc << 5) ^ (acc >> 3) ^ parest_row_value[i];
    parest_composite_checksum ^= acc;
}

int main(void)
{
    parest_init();
    asm volatile(".global perf_warmup_start\n\t" "perf_warmup_start:");
    if (SPEC_PAREST_COMPOSITE_WARMUP)
        parest_warmup();
    asm volatile(".global perf_warmup_end\n\t" "perf_warmup_end:");

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    uint32_t dof_sum = parest_dof_phase();
    uint32_t sparse_sum = parest_sparse_phase();
    parest_composite_checksum = dof_sum ^ (sparse_sum << 1) ^
                                (sparse_sum >> 31);
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_510_parest_composite_kernel config dof_passes=%u "
           "sparse_iters=%u sparse_tail_rows=%u dof_n=%u dof_width=%u "
           "sparse_n=%u sparse_nz=%u warmup=%u target_dof_ppm=%u\n",
           (unsigned int)SPEC_PAREST_COMPOSITE_DOF_PASSES,
           (unsigned int)SPEC_PAREST_COMPOSITE_SPARSE_ITERS,
           (unsigned int)SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS,
           (unsigned int)PAREST_DOF_N,
           (unsigned int)PAREST_DOF_WIDTH,
           (unsigned int)PAREST_SPARSE_N,
           (unsigned int)PAREST_SPARSE_NZ,
           (unsigned int)SPEC_PAREST_COMPOSITE_WARMUP,
           (unsigned int)SPEC_PAREST_COMPOSITE_TARGET_DOF_PPM);
    printf("spec_510_parest_composite_kernel checksum=%u\n",
           (unsigned int)parest_composite_checksum);
    return parest_composite_checksum == 0;
}

#endif
