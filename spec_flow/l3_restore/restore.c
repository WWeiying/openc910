#include <stddef.h>
#include <stdint.h>

#define PAGE_SIZE 4096ULL
#define PT_ENTRIES 512
#define MAX_PAGE_TABLES 128

#define PTE_V (1ULL << 0)
#define PTE_R (1ULL << 1)
#define PTE_W (1ULL << 2)
#define PTE_X (1ULL << 3)
#define PTE_U (1ULL << 4)
#define PTE_A (1ULL << 6)
#define PTE_D (1ULL << 7)

struct checkpoint_segment {
    uint64_t virtual_address;
    uint64_t physical_address;
    uint64_t length;
    uint64_t pte_flags;
};

extern const struct checkpoint_segment checkpoint_segments[];
extern const uint64_t checkpoint_segment_count;
extern void machine_trap_entry(void);
extern void restore_user_state(uint64_t satp) __attribute__((noreturn));
extern char _machine_stack_top[];

uint64_t page_tables[MAX_PAGE_TABLES][PT_ENTRIES]
    __attribute__((aligned(PAGE_SIZE)));
static size_t allocated_page_tables = 1;

static void uart_putc(char value)
{
#ifdef L3_RTL
    (void)value;
#else
    *(volatile uint8_t *)0x10000000UL = (uint8_t)value;
#endif
}

static void uart_puts(const char *text)
{
    while (*text) {
        uart_putc(*text++);
    }
}

static void uart_hex(uint64_t value)
{
    static const char digits[] = "0123456789abcdef";

    uart_puts("0x");
    for (int shift = 60; shift >= 0; shift -= 4) {
        uart_putc(digits[(value >> shift) & 0xf]);
    }
}

static void halt(const char *reason) __attribute__((noreturn));

static void halt(const char *reason)
{
    uart_puts("L3_RESTORE_ERROR ");
    uart_puts(reason);
    uart_putc('\n');
    for (;;) {
        __asm__ volatile("wfi");
    }
}

static uint64_t *allocate_page_table(void)
{
    if (allocated_page_tables >= MAX_PAGE_TABLES) {
        halt("page_table_pool_exhausted");
    }
    return page_tables[allocated_page_tables++];
}

static uint64_t table_pte(uint64_t *table)
{
    return (((uint64_t)(uintptr_t)table >> 12) << 10) | PTE_V;
}

static uint64_t *next_level(uint64_t *table, size_t index)
{
    uint64_t pte = table[index];

    if (!(pte & PTE_V)) {
        uint64_t *child = allocate_page_table();
        table[index] = table_pte(child);
        return child;
    }
    if (pte & (PTE_R | PTE_W | PTE_X)) {
        halt("page_table_leaf_collision");
    }
    return (uint64_t *)(uintptr_t)(((pte >> 10) << 12));
}

static void map_page(uint64_t virtual_address, uint64_t physical_address,
                     uint64_t flags)
{
    uint64_t *level1 = next_level(page_tables[0],
                                  (virtual_address >> 30) & 0x1ff);
    uint64_t *level0 = next_level(level1, (virtual_address >> 21) & 0x1ff);
    size_t index = (virtual_address >> 12) & 0x1ff;
    uint64_t pte = ((physical_address >> 12) << 10) | flags | PTE_V |
                   PTE_U | PTE_A | PTE_D;

    if (level0[index] && level0[index] != pte) {
        halt("duplicate_virtual_page");
    }
    level0[index] = pte;
}

static void build_page_tables(void)
{
#ifdef L3_PREBUILT_PAGE_TABLES
    return;
#else
    for (uint64_t i = 0; i < checkpoint_segment_count; i++) {
        const struct checkpoint_segment *segment = &checkpoint_segments[i];

        if ((segment->virtual_address | segment->physical_address |
             segment->length) & (PAGE_SIZE - 1)) {
            halt("unaligned_checkpoint_segment");
        }
        for (uint64_t offset = 0; offset < segment->length;
             offset += PAGE_SIZE) {
            map_page(segment->virtual_address + offset,
                     segment->physical_address + offset,
                     segment->pte_flags);
        }
    }
#endif
}

static void configure_c910(void)
{
#ifdef L3_C910_MAEE
    const uint64_t mxstatus = 0x638000;

    __asm__ volatile("csrs mxstatus, %0" : : "r"(mxstatus));
#endif
#ifdef L3_C910_INIT
    const uint64_t msmpr = 0x1;
    const uint64_t invalidate = 0x70013;
    const uint64_t mhcr = 0x11ff;
    const uint64_t mhint = 0x6e30c;
    const uint64_t mccr2 = 0xe0000009;

    __asm__ volatile("csrs msmpr, %0" : : "r"(msmpr));
    __asm__ volatile("csrs mcor, %0" : : "r"(invalidate) : "memory");
    __asm__ volatile("csrs mhcr, %0" : : "r"(mhcr) : "memory");
    __asm__ volatile("csrs mhint, %0" : : "r"(mhint));
    __asm__ volatile("csrs mccr2, %0" : : "r"(mccr2));
#endif
}

void trap_report(uint64_t cause, uint64_t pc, uint64_t value,
                 uint64_t syscall_number)
{
    uart_puts("L3_RESTORE_TRAP cause=");
    uart_hex(cause);
    uart_puts(" pc=");
    uart_hex(pc);
    uart_puts(" value=");
    uart_hex(value);
    uart_puts(" a7=");
    uart_hex(syscall_number);
    uart_putc('\n');
    for (;;) {
        __asm__ volatile("wfi");
    }
}

void restore_main(void)
{
    uint64_t satp;

    build_page_tables();
    configure_c910();
    __asm__ volatile("csrw mtvec, %0" : : "r"(machine_trap_entry));
    __asm__ volatile("csrw mscratch, %0" : : "r"(_machine_stack_top));
    __asm__ volatile("csrw pmpaddr0, %0" : : "r"(~0ULL));
    __asm__ volatile("csrw pmpcfg0, %0" : : "r"(0x1fULL));
    satp = (8ULL << 60) | ((uint64_t)(uintptr_t)page_tables[0] >> 12);
    uart_puts("L3_RESTORE_ENTER\n");
    restore_user_state(satp);
}
