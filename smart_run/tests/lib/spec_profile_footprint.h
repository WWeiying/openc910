#ifndef SPEC_PROFILE_FOOTPRINT_H
#define SPEC_PROFILE_FOOTPRINT_H

#include <stdint.h>

#ifndef SPEC_PROFILE_FOOTPRINT_BYTES
#define SPEC_PROFILE_FOOTPRINT_BYTES 0
#endif

#if SPEC_PROFILE_FOOTPRINT_BYTES > 0
#if SPEC_PROFILE_FOOTPRINT_BYTES < 64
#error "SPEC_PROFILE_FOOTPRINT_BYTES must be at least one 64-byte line"
#endif
#if (SPEC_PROFILE_FOOTPRINT_BYTES % 64) != 0
#error "SPEC_PROFILE_FOOTPRINT_BYTES must be a multiple of 64"
#endif

#define SPEC_PROFILE_FOOTPRINT_LINES (SPEC_PROFILE_FOOTPRINT_BYTES / 64)
#define SPEC_PROFILE_FOOTPRINT_WORDS (SPEC_PROFILE_FOOTPRINT_BYTES / 8)

static volatile uint64_t spec_profile_footprint[SPEC_PROFILE_FOOTPRINT_WORDS];

__attribute__((noinline)) static void spec_profile_footprint_init(void)
{
    uint64_t state = 0x9e3779b97f4a7c15ull;

    for (uint32_t line = 0; line < SPEC_PROFILE_FOOTPRINT_LINES; line++) {
        uint32_t index = (line * 1093u + 17u) % SPEC_PROFILE_FOOTPRINT_LINES;
        state ^= state << 7;
        state ^= state >> 9;
        spec_profile_footprint[index * 8u] = state ^ index;
    }
}

__attribute__((noinline)) static uint32_t spec_profile_footprint_run(void)
{
    uint64_t state = 0x243f6a8885a308d3ull;

    for (uint32_t line = 0; line < SPEC_PROFILE_FOOTPRINT_LINES; line++) {
        uint32_t index = (line * 1093u + 17u) % SPEC_PROFILE_FOOTPRINT_LINES;
        uint32_t word = index * 8u;
        uint64_t value = spec_profile_footprint[word];
        state ^= value + ((uint64_t)index << (line & 7u));
        state = (state << 11) | (state >> 53);
        spec_profile_footprint[word] = value ^ state;
    }
    return (uint32_t)(state ^ (state >> 32));
}
#else
static void spec_profile_footprint_init(void) {}
static uint32_t spec_profile_footprint_run(void) { return 0; }
#endif

#endif
