/* ACT4 DUT linker adapter for the OpenC910 smart_run memory loader. */
RAM_ORIGIN = 0x00000000;
RAM_LENGTH = 0x00100000;
TEST_BASE = RAM_ORIGIN;
NUM_HARTS = 1;
STACK_SIZE = 0x00008000;

OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)
PROVIDE(__stack_size = STACK_SIZE);
PROVIDE(__num_harts = NUM_HARTS);

MEMORY
{
  imem (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
  dmem (rwx) : ORIGIN = 0x00040000, LENGTH = 0x000c0000
}

SECTIONS
{
  .text.init TEST_BASE : { KEEP(*(.text.init)) } > imem
  .text.rvtest : { *(.text.rvtest) *(.text.rvtest.*) } > imem
  .text.rvmodel : { *(.text.rvmodel) *(.text.rvmodel.*) *(.text) *(.text.*) } > imem
  .rodata : { *(.rodata) *(.rodata.*) *(.srodata) *(.srodata.*) } > imem

  .data ORIGIN(dmem) : { *(.data) *(.data.*) *(.sdata) *(.sdata.*) *(.tohost) } > dmem
  .bss (NOLOAD) :
  {
    __bss_start = .;
    *(.sbss) *(.sbss.*) *(.bss) *(.bss.*) *(COMMON)
    . = ALIGN(16);
    __bss_end = .;
  } > dmem

  . = ALIGN(16);
  __stack_bottom = .;
  . += __stack_size * __num_harts;
  __stack_top = .;
  _end = .;

  ASSERT(SIZEOF(.text.init) + SIZEOF(.text.rvtest) + SIZEOF(.text.rvmodel) + SIZEOF(.rodata) <= LENGTH(imem), "ACT code exceeds smart_run instruction image")
  ASSERT(ADDR(.data) + SIZEOF(.data) <= ORIGIN(dmem) + 0x40000, "ACT initialized data exceeds smart_run data image")
  ASSERT(_end <= ORIGIN(dmem) + LENGTH(dmem), "ACT data/stack exceeds smart_run RAM")
}
