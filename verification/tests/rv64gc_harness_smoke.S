/*
 * This is a harness smoke test, not an ISA certification suite.  It checks
 * that a standard RV64GC ELF can boot, execute representative instructions,
 * and report pass/fail through the existing OpenC910 smart_run testbench.
 */

  .section .text.init
  .align  2
  .globl  rvtest_entry_point
  .globl  main
  .globl  perf_monitor_start
  .globl  perf_monitor_end
  .globl  __exit
  .globl  __fail

rvtest_entry_point:
  la      sp, __stack_top
  la      t0, trap_fail
  csrw    mtvec, t0

main:
perf_monitor_start:
  /* I: integer ALU, branch, and load/store. */
  li      t0, 7
  li      t1, 5
  add     t2, t0, t1
  li      t3, 12
  bne     t2, t3, __fail
  sub     t2, t2, t1
  bne     t2, t0, __fail

  la      t0, scratch_word
  li      t1, 0x12345678
  sd      t1, 0(t0)
  ld      t2, 0(t0)
  bne     t1, t2, __fail

  /* M: multiply and divide. */
  li      t0, 13
  li      t1, 7
  mul     t2, t0, t1
  li      t3, 91
  bne     t2, t3, __fail
  div     t2, t2, t1
  bne     t2, t0, __fail

  /* A: aligned 64-bit atomic read-modify-write. */
  la      t0, atomic_word
  li      t1, 5
  sd      t1, 0(t0)
  li      t1, 3
  amoadd.d.aqrl t2, t1, (t0)
  li      t3, 5
  bne     t2, t3, __fail
  ld      t2, 0(t0)
  li      t3, 8
  bne     t2, t3, __fail

  /* F/D: enable architectural FP state and check a double result. */
  li      t0, (3 << 13)
  csrs    mstatus, t0
  la      t0, fp_inputs
  fld     ft0, 0(t0)
  fld     ft1, 8(t0)
  fadd.d  ft2, ft0, ft1
  fmv.x.d t1, ft2
  li      t2, 0x400e000000000000
  bne     t1, t2, __fail

  /* C: force at least one compressed instruction into the executed stream. */
  li      t0, 1
  .option push
  .option rvc
  c.addi  t0, 1
  .option pop
  li      t1, 2
  bne     t0, t1, __fail

  /* Zicsr and the expected standard misa extension bits. */
  csrr    t0, misa
  li      t1, 0x112d
  and     t0, t0, t1
  bne     t0, t1, __fail
  fence.i

perf_monitor_end:
__exit:
  li      x3, 0x444333222
1:
  j       1b

trap_fail:
__fail:
  li      x3, 0x2382348720
2:
  j       2b

  .section .data
  .align 3
scratch_word:
  .dword 0
atomic_word:
  .dword 0
fp_inputs:
  .dword 0x3ff8000000000000 /* 1.5 */
  .dword 0x4002000000000000 /* 2.25 */
