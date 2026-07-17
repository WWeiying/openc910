#ifndef SPEC_COMPOSITION_MARKERS_H
#define SPEC_COMPOSITION_MARKERS_H

#ifndef SPEC_COMPOSITION_SCALE
#define SPEC_COMPOSITION_SCALE 1
#endif

/* Global instruction labels let the trace analyzer attribute nested calls to
 * the active composite phase.  Each macro may appear once lexically per ELF. */
#define SPEC_COMPOSITION_PHASE0_BEGIN() \
    asm volatile(".global spec_composition_phase0_start\n\t" \
                 "spec_composition_phase0_start:\n\t" "nop" ::: "memory")
#define SPEC_COMPOSITION_PHASE0_END() \
    asm volatile(".global spec_composition_phase0_end\n\t" \
                 "spec_composition_phase0_end:\n\t" "nop" ::: "memory")
#define SPEC_COMPOSITION_PHASE1_BEGIN() \
    asm volatile(".global spec_composition_phase1_start\n\t" \
                 "spec_composition_phase1_start:\n\t" "nop" ::: "memory")
#define SPEC_COMPOSITION_PHASE1_END() \
    asm volatile(".global spec_composition_phase1_end\n\t" \
                 "spec_composition_phase1_end:\n\t" "nop" ::: "memory")
#define SPEC_COMPOSITION_PHASE2_BEGIN() \
    asm volatile(".global spec_composition_phase2_start\n\t" \
                 "spec_composition_phase2_start:\n\t" "nop" ::: "memory")
#define SPEC_COMPOSITION_PHASE2_END() \
    asm volatile(".global spec_composition_phase2_end\n\t" \
                 "spec_composition_phase2_end:\n\t" "nop" ::: "memory")

#endif
