/*
 * spec_cactubssn_stencil_kernel: cactuBSSN-like tensor stencil kernel.
 *
 * This is not SPEC cactuBSSN source code. It models 507.cactuBSSN_r style
 * floating-point tensor/stencil updates over 3D grids.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_CACTU_N
#define SPEC_CACTU_N 6
#endif

#ifndef SPEC_CACTU_STEPS
#define SPEC_CACTU_STEPS 1
#endif

#ifndef SPEC_CACTU_TENSORS
#define SPEC_CACTU_TENSORS 3
#endif

#define N SPEC_CACTU_N
#define STEPS SPEC_CACTU_STEPS
#define TENSORS SPEC_CACTU_TENSORS
#define CELLS (N * N * N)

static double phi[TENSORS][CELLS];
static double rhs[TENSORS][CELLS];
static volatile uint32_t checksum;

static int idx3(int x, int y, int z)
{
    return (z * N + y) * N + x;
}

static void init_grid(void)
{
    for (int t = 0; t < TENSORS; t++) {
        for (int i = 0; i < CELLS; i++) {
            int v = (i * 17 + t * 29) & 255;
            phi[t][i] = (double)(v - 127) * 0.00390625;
            rhs[t][i] = 0.0;
        }
    }
}

static uint32_t fold_double(double x)
{
    int32_t v = (int32_t)(x * 65536.0);
    return (uint32_t)v ^ ((uint32_t)v >> 13);
}

static uint32_t stencil_kernel(void)
{
    uint32_t acc = 0x5072017u;

    for (int step = 0; step < STEPS; step++) {
        for (int z = 1; z < N - 1; z++) {
            for (int y = 1; y < N - 1; y++) {
                for (int x = 1; x < N - 1; x++) {
                    int c = idx3(x, y, z);
                    int xp = idx3(x + 1, y, z);
                    int xm = idx3(x - 1, y, z);
                    int yp = idx3(x, y + 1, z);
                    int ym = idx3(x, y - 1, z);
                    int zp = idx3(x, y, z + 1);
                    int zm = idx3(x, y, z - 1);

                    for (int t = 0; t < TENSORS; t++) {
                        double lap = phi[t][xp] + phi[t][xm] +
                                     phi[t][yp] + phi[t][ym] +
                                     phi[t][zp] + phi[t][zm] -
                                     6.0 * phi[t][c];
                        double grad = (phi[t][xp] - phi[t][xm]) *
                                      (phi[(t + 1) % TENSORS][yp] - phi[(t + 2) % TENSORS][ym]);
                        double source = 0.125 * lap + 0.03125 * grad +
                                        0.0078125 * phi[(t + 3) % TENSORS][c];
                        rhs[t][c] = source;
                        acc ^= fold_double(source) + (uint32_t)(c * 13 + t);
                    }
                }
            }
        }

        for (int t = 0; t < TENSORS; t++) {
            for (int i = 0; i < CELLS; i++) {
                phi[t][i] += 0.0625 * rhs[t][i];
                acc = (acc << 5) ^ (acc >> 2) ^ fold_double(phi[t][i]);
            }
        }
    }

    return acc;
}

int main(void)
{
    init_grid();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = stencil_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_cactubssn_stencil_kernel config n=%u steps=%u tensors=%u\n",
           (unsigned int)N, (unsigned int)STEPS, (unsigned int)TENSORS);
    printf("spec_cactubssn_stencil_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
