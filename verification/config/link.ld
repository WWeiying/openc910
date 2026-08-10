OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

MEMORY
{
  imem (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
  dmem (rwx) : ORIGIN = 0x00040000, LENGTH = 0x000c0000
}

SECTIONS
{
  .text ORIGIN(imem) :
  {
    KEEP(*(.text.init))
    *(.text .text.*)
    *(.rodata .rodata.* .srodata .srodata.*)
  } > imem

  .data ORIGIN(dmem) :
  {
    *(.data .data.* .sdata .sdata.*)
  } > dmem

  .bss (NOLOAD) :
  {
    . = ALIGN(16);
    __bss_start = .;
    *(.sbss .sbss.* .bss .bss.* COMMON)
    . = ALIGN(16);
    __bss_end = .;
  } > dmem

  . = ALIGN(16);
  _end = .;
  __stack_top = ORIGIN(dmem) + LENGTH(dmem) - 0x1000;

  ASSERT(SIZEOF(.text) <= LENGTH(imem), "code/rodata exceeds C910 smart_run instruction image")
  ASSERT(ADDR(.data) + SIZEOF(.data) <= ORIGIN(dmem) + 0x40000, "initialized data exceeds C910 smart_run data image")
  ASSERT(_end < __stack_top, "data/bss collides with C910 smart_run stack")

  /DISCARD/ :
  {
    *(.comment)
    *(.note .note.*)
  }
}
