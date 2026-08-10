#ifndef C910_RVMODEL_MACROS_H
#define C910_RVMODEL_MACROS_H

/* Keep a conventional tohost section for ELF/tool compatibility. */
#define RVMODEL_DATA_SECTION                                      \
  .pushsection .tohost, "aw", @progbits;                         \
  .balign 8; .global tohost; tohost: .dword 0;                    \
  .balign 8; .global fromhost; fromhost: .dword 0;                \
  .popsection;

/* smart_run detects these values on the architectural writeback buses. */
#define RVMODEL_HALT_PASS                                         \
  .global __exit; __exit:;                                        \
  li x3, 0x444333222;                                              \
  1: j 1b;

#define RVMODEL_HALT_FAIL                                         \
  .global __fail; __fail:;                                        \
  li x3, 0x2382348720;                                             \
  1: j 1b;

/* The current logical testbench has no architectural console endpoint. */
#define RVMODEL_IO_INIT(_R1, _R2, _R3)
#define RVMODEL_IO_WRITE_STR(_R1, _R2, _R3, _STR_PTR)

#endif

