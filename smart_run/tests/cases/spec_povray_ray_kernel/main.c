/*
 * spec_povray_ray_kernel: povray-like ray/geometry kernel.
 *
 * This is not SPEC povray source code. It models 511.povray_r style ray
 * traversal, object intersection tests, shading branches, and FP geometry.
 */

#include <stdint.h>
#include <stdio.h>

#ifndef SPEC_POVRAY_RAYS
#define SPEC_POVRAY_RAYS 32
#endif

#ifndef SPEC_POVRAY_OBJECTS
#define SPEC_POVRAY_OBJECTS 8
#endif

#ifndef SPEC_POVRAY_BOUNCES
#define SPEC_POVRAY_BOUNCES 1
#endif

#define RAYS SPEC_POVRAY_RAYS
#define OBJECTS SPEC_POVRAY_OBJECTS
#define BOUNCES SPEC_POVRAY_BOUNCES

typedef struct {
    float ox, oy, oz;
    float dx, dy, dz;
} ray_t;

typedef struct {
    float cx, cy, cz;
    float radius;
    uint32_t material;
} sphere_t;

static ray_t rays[RAYS];
static sphere_t spheres[OBJECTS];
static volatile uint32_t checksum;

static void init_scene(void)
{
    for (int i = 0; i < RAYS; i++) {
        rays[i].ox = 0.0f;
        rays[i].oy = 0.0f;
        rays[i].oz = -4.0f;
        rays[i].dx = (float)((i * 7) & 31) * 0.03125f - 0.5f;
        rays[i].dy = (float)((i * 11) & 31) * 0.03125f - 0.5f;
        rays[i].dz = 1.0f;
    }

    for (int i = 0; i < OBJECTS; i++) {
        spheres[i].cx = (float)((i * 5) & 15) * 0.25f - 2.0f;
        spheres[i].cy = (float)((i * 7) & 15) * 0.25f - 2.0f;
        spheres[i].cz = (float)(i & 7) * 0.375f;
        spheres[i].radius = 0.35f + (float)(i & 3) * 0.0625f;
        spheres[i].material = (uint32_t)(i * 2654435761u);
    }
}

static uint32_t fold_float(float x)
{
    int32_t v = (int32_t)(x * 4096.0f);
    return (uint32_t)v ^ ((uint32_t)v << 7);
}

static int intersect_sphere(const ray_t *r, const sphere_t *s, float *t_out)
{
    float lx = r->ox - s->cx;
    float ly = r->oy - s->cy;
    float lz = r->oz - s->cz;
    float b = lx * r->dx + ly * r->dy + lz * r->dz;
    float c = lx * lx + ly * ly + lz * lz - s->radius * s->radius;
    float disc = b * b - c;

    if (disc <= 0.0f)
        return 0;

    float t = -b - disc * 0.25f;
    if (t <= 0.01f)
        return 0;

    *t_out = t;
    return 1;
}

static uint32_t shade_and_bounce(ray_t *r, const sphere_t *s, float t, uint32_t acc)
{
    float px = r->ox + r->dx * t;
    float py = r->oy + r->dy * t;
    float pz = r->oz + r->dz * t;
    float nx = px - s->cx;
    float ny = py - s->cy;
    float nz = pz - s->cz;
    float ndotl = nx * 0.25f + ny * 0.5f + nz * 0.75f;

    if (ndotl < 0.0f)
        ndotl = -ndotl * 0.5f;

    r->ox = px + nx * 0.03125f;
    r->oy = py + ny * 0.03125f;
    r->oz = pz + nz * 0.03125f;
    r->dx = r->dx - 2.0f * ndotl * nx;
    r->dy = r->dy - 2.0f * ndotl * ny;
    r->dz = r->dz - 2.0f * ndotl * nz;

    return acc ^ s->material ^ fold_float(ndotl + px + py + pz);
}

static uint32_t ray_kernel(void)
{
    uint32_t acc = 0x5112017u;

    for (int i = 0; i < RAYS; i++) {
        ray_t r = rays[i];
        for (int bounce = 0; bounce < BOUNCES; bounce++) {
            int best = -1;
            float best_t = 1.0e9f;

            for (int o = 0; o < OBJECTS; o++) {
                float t = 0.0f;
                if (intersect_sphere(&r, &spheres[o], &t) && t < best_t) {
                    best_t = t;
                    best = o;
                }
            }

            if (best < 0) {
                acc ^= fold_float(r.dx + r.dy + r.dz) + (uint32_t)(i * 31 + bounce);
                break;
            }

            acc = shade_and_bounce(&r, &spheres[best], best_t, acc);
        }
    }

    return acc;
}

int main(void)
{
    init_scene();

    asm volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    checksum = ray_kernel();
    asm volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    printf("spec_povray_ray_kernel config rays=%u objects=%u bounces=%u\n",
           (unsigned int)RAYS, (unsigned int)OBJECTS, (unsigned int)BOUNCES);
    printf("spec_povray_ray_kernel checksum=%u\n", (unsigned int)checksum);
    return checksum == 0;
}
