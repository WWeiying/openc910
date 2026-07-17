    .section .text.start,"ax",@progbits
    .globl _start
_start:
    la sp, _machine_stack_top
#ifndef L3_RTL
    la t0, _bss_start
    la t1, _bss_end
1:
    bgeu t0, t1, 2f
    sd zero, 0(t0)
    addi t0, t0, 8
    j 1b
2:
#endif
    call restore_main
3:
    wfi
    j 3b

    .globl restore_user_state
restore_user_state:
    csrw satp, a0
    sfence.vma zero, zero

    csrr t1, mstatus
    li t2, (3 << 13)
    or t1, t1, t2
    csrw mstatus, t1

    la t0, checkpoint_fprs
    fld f0,   0(t0)
    fld f1,   8(t0)
    fld f2,  16(t0)
    fld f3,  24(t0)
    fld f4,  32(t0)
    fld f5,  40(t0)
    fld f6,  48(t0)
    fld f7,  56(t0)
    fld f8,  64(t0)
    fld f9,  72(t0)
    fld f10, 80(t0)
    fld f11, 88(t0)
    fld f12, 96(t0)
    fld f13,104(t0)
    fld f14,112(t0)
    fld f15,120(t0)
    fld f16,128(t0)
    fld f17,136(t0)
    fld f18,144(t0)
    fld f19,152(t0)
    fld f20,160(t0)
    fld f21,168(t0)
    fld f22,176(t0)
    fld f23,184(t0)
    fld f24,192(t0)
    fld f25,200(t0)
    fld f26,208(t0)
    fld f27,216(t0)
    fld f28,224(t0)
    fld f29,232(t0)
    fld f30,240(t0)
    fld f31,248(t0)

    la t0, checkpoint_fcsr
    ld t1, 0(t0)
    csrw fcsr, t1
    la t0, checkpoint_pc
    ld t1, 0(t0)
    csrw mepc, t1

    csrr t1, mstatus
    li t2, ~(3 << 11)
    and t1, t1, t2
    li t2, (3 << 13)
    or t1, t1, t2
    li t2, (1 << 17)
    not t2, t2
    and t1, t1, t2
    csrw mstatus, t1

    la x5, checkpoint_gprs
    ld x1,   8(x5)
    ld x2,  16(x5)
    ld x3,  24(x5)
    ld x4,  32(x5)
    ld x6,  48(x5)
    ld x7,  56(x5)
    ld x8,  64(x5)
    ld x9,  72(x5)
    ld x10, 80(x5)
    ld x11, 88(x5)
    ld x12, 96(x5)
    ld x13,104(x5)
    ld x14,112(x5)
    ld x15,120(x5)
    ld x16,128(x5)
    ld x17,136(x5)
    ld x18,144(x5)
    ld x19,152(x5)
    ld x20,160(x5)
    ld x21,168(x5)
    ld x22,176(x5)
    ld x23,184(x5)
    ld x24,192(x5)
    ld x25,200(x5)
    ld x26,208(x5)
    ld x27,216(x5)
    ld x28,224(x5)
    ld x29,232(x5)
    ld x30,240(x5)
    ld x31,248(x5)
    ld x5,  40(x5)
    mret

    .align 4
    .globl machine_trap_entry
machine_trap_entry:
    mv t0, a7
    csrrw sp, mscratch, sp
    addi sp, sp, -32
    sd ra, 0(sp)
    sd a0, 8(sp)
    sd a1, 16(sp)
    sd a2, 24(sp)
    csrr a0, mcause
    csrr a1, mepc
    csrr a2, mtval
    mv a3, t0
    call trap_report
4:
    wfi
    j 4b
