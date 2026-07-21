#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

static uint64_t mix(uint64_t value)
{
    value ^= value >> 29;
    value *= UINT64_C(0x9e3779b97f4a7c15);
    value ^= value >> 31;
    return value;
}

int main(void)
{
    uint64_t state = UINT64_C(0x123456789abcdef0);

    for (uint64_t index = 0; index < 1000000; index++) {
        if ((index & 7) == 0) {
            state += mix(index + state);
        } else if ((index & 3) == 0) {
            state ^= state << 9;
        } else {
            state = state * 33 + index;
        }
    }

    printf("%" PRIu64 "\n", state);
    return 0;
}
