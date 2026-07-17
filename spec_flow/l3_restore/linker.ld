OUTPUT_ARCH(riscv)
ENTRY(_start)

__image_base = DEFINED(PHYS_BASE) ? PHYS_BASE : 0x80000000;

SECTIONS
{
  . = __image_base;
  _image_start = .;

  .text : ALIGN(16) {
    KEEP(*(.text.start))
    *(.text*)
  }
  .rodata : ALIGN(16) {
    *(.rodata*)
    *(.checkpoint_meta)
  }
  .data : ALIGN(16) {
    *(.data*)
  }
  .checkpoint_pages : ALIGN(4096) {
    *(.checkpoint_pages)
  }
  .bss (NOLOAD) : ALIGN(4096) {
    _bss_start = .;
    *(.bss*)
    *(COMMON)
    _bss_end = .;
  }
  . = ALIGN(16);
  . += 0x10000;
  _machine_stack_top = .;
  _image_end = .;
}

ASSERT((_image_end - _image_start) <=
       (DEFINED(IMAGE_LIMIT) ? IMAGE_LIMIT : 0x08000000),
       "L3 restore image exceeds configured physical memory")
