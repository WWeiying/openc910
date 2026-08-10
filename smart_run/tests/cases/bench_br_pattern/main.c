/*
 * Parameterized branch-predictor pattern-recognition benchmark.
 *
 * generated_branch_sites.inc contains exactly BP_BRANCHES static conditional
 * branches.  Both modes execute identical text and differ only in initialized
 * data: predictable uses a balanced alternating pattern, while random_periodic
 * uses a balanced shuffled pattern that repeats every BP_PATTERN_LENGTH steps.
 */

#include <stdint.h>

#ifndef BP_BRANCHES
#define BP_BRANCHES 1
#endif
#ifndef BP_PATTERN_LENGTH
#define BP_PATTERN_LENGTH 2
#endif
#ifndef BP_RANDOM_MODE
#define BP_RANDOM_MODE 0
#endif
#ifndef BP_SEED
#define BP_SEED 910
#endif
#ifndef BP_WARMUP_ITERATIONS
#define BP_WARMUP_ITERATIONS 256
#endif
#ifndef BP_MEASURE_ITERATIONS
#define BP_MEASURE_ITERATIONS 512
#endif

#if BP_BRANCHES < 1 || BP_BRANCHES > 512
#error "BP_BRANCHES must be in [1, 512]"
#endif
#if BP_PATTERN_LENGTH < 2 || BP_PATTERN_LENGTH > 65536
#error "BP_PATTERN_LENGTH must be in [2, 65536]"
#endif
#if BP_WARMUP_ITERATIONS < BP_PATTERN_LENGTH
#error "warmup must cover at least one complete pattern"
#endif
#if BP_MEASURE_ITERATIONS < BP_PATTERN_LENGTH
#error "measurement must cover at least one complete pattern"
#endif

#define BP_STRINGIFY_INNER(value) #value
#define BP_STRINGIFY(value) BP_STRINGIFY_INNER(value)

/* Absolute ELF symbols let the sweep verify every compile-time parameter. */
__asm__(
    ".global bp_compiled_branches\n"
    ".set bp_compiled_branches," BP_STRINGIFY(BP_BRANCHES) "\n"
    ".global bp_compiled_pattern_length\n"
    ".set bp_compiled_pattern_length," BP_STRINGIFY(BP_PATTERN_LENGTH) "\n"
    ".global bp_compiled_random_mode\n"
    ".set bp_compiled_random_mode," BP_STRINGIFY(BP_RANDOM_MODE) "\n"
    ".global bp_compiled_seed\n"
    ".set bp_compiled_seed," BP_STRINGIFY(BP_SEED) "\n"
    ".global bp_compiled_warmup_iterations\n"
    ".set bp_compiled_warmup_iterations," BP_STRINGIFY(BP_WARMUP_ITERATIONS) "\n"
    ".global bp_compiled_measure_iterations\n"
    ".set bp_compiled_measure_iterations," BP_STRINGIFY(BP_MEASURE_ITERATIONS) "\n");

static volatile uint8_t pattern[BP_PATTERN_LENGTH];
static volatile unsigned long sink;

/* These values live in .data. Changing mode/seed does not alter benchmark text. */
static volatile uint32_t configured_random_mode
    __attribute__((section(".data"))) = BP_RANDOM_MODE;
static volatile uint32_t configured_seed = BP_SEED;

static uint32_t next_random(uint32_t *state)
{
    uint32_t value = *state;

    value ^= value << 13;
    value ^= value >> 17;
    value ^= value << 5;
    *state = value;
    return value;
}

static int pattern_has_full_period(void)
{
    uint32_t candidate;

    for (candidate = 1; candidate <= BP_PATTERN_LENGTH / 2u; ++candidate) {
        uint32_t index;
        int repeats = 1;

        if ((BP_PATTERN_LENGTH % candidate) != 0)
            continue;
        for (index = candidate; index < BP_PATTERN_LENGTH; ++index) {
            if (pattern[index] != pattern[index % candidate]) {
                repeats = 0;
                break;
            }
        }
        if (repeats)
            return 0;
    }
    return 1;
}

static void shuffle_pattern(uint32_t *state)
{
    uint32_t index;

    for (index = BP_PATTERN_LENGTH - 1u; index > 0; --index) {
        uint32_t other = next_random(state) % (index + 1u);
        uint8_t temporary = pattern[index];

        pattern[index] = pattern[other];
        pattern[other] = temporary;
    }
}

static void initialize_pattern(void)
{
    uint32_t index;

    if (configured_random_mode == 0) {
        for (index = 0; index < BP_PATTERN_LENGTH; ++index)
            pattern[index] = (uint8_t)(index & 1u);
        return;
    }

    /* Start balanced, then apply a deterministic Fisher-Yates shuffle. */
    for (index = 0; index < BP_PATTERN_LENGTH; ++index)
        pattern[index] = (uint8_t)(index >= (BP_PATTERN_LENGTH / 2u));

    if (BP_PATTERN_LENGTH > 1) {
        uint32_t state = configured_seed | 1u;
        uint32_t attempt;

        for (attempt = 0; attempt < 64u; ++attempt) {
            shuffle_pattern(&state);
            if (pattern_has_full_period())
                break;
        }
        if (!pattern_has_full_period()) {
            for (index = 0; index < BP_PATTERN_LENGTH; ++index)
                pattern[index] = (uint8_t)(index >= (BP_PATTERN_LENGTH / 2u));
        }
    }
}

/*
 * The branch mnemonic is explicit so compiler if-conversion cannot remove the
 * tested branch. Numeric label 1 is local to each inline-assembly statement.
 */
#define BP_SITE(PHASE)                                                       \
    do {                                                                     \
        unsigned long bp_condition =                                         \
            pattern[(cursor + (uint32_t)(PHASE)) % BP_PATTERN_LENGTH];       \
        __asm__ volatile(                                                    \
            "beqz %[condition], 1f\n\t"                                    \
            "addi %[accumulator], %[accumulator], 1\n\t"                   \
            "1:\n\t"                                                      \
            : [accumulator] "+&r"(accumulator)                              \
            : [condition] "r"(bp_condition)                                 \
            : "memory");                                                    \
    } while (0)

__attribute__((noinline))
static unsigned long run_pattern(uint32_t iterations)
{
    uint32_t iteration;
    uint32_t cursor = 0;
    unsigned long accumulator = 0;

    for (iteration = 0; iteration < iterations; ++iteration) {
        __asm__ volatile(
            ".global branch_pattern_sites_begin\n\t"
            "branch_pattern_sites_begin:\n\t"
            ::: "memory");

#include "generated_branch_sites.inc"

        __asm__ volatile(
            ".global branch_pattern_sites_end\n\t"
            "branch_pattern_sites_end:\n\t"
            ::: "memory");

        ++cursor;
        if (cursor == BP_PATTERN_LENGTH)
            cursor = 0;
    }
    return accumulator;
}

int main(void)
{
    initialize_pattern();

    sink = run_pattern(BP_WARMUP_ITERATIONS);

    __asm__ volatile(".global perf_monitor_start\n\t" "perf_monitor_start:");
    sink = run_pattern(BP_MEASURE_ITERATIONS);
    __asm__ volatile(".global perf_monitor_end\n\t" "perf_monitor_end:");

    return 0;
}
