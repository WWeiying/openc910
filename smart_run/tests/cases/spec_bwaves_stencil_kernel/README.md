# spec_bwaves_stencil_kernel

Models the dominant `503.bwaves_r test` profile shape: floating-point
matrix-vector products, Jacobian-like coefficient updates, shell-style residual
loops, and BiCGStab-like vector recurrences. This is a representative RTL
kernel, not SPEC source.

The SPEC SimPoint/function profile used for calibration is led by
`mat_times_vec_`, `shell_`, `jacobian_`, and `bi_cgstab_block_`, so this kernel
intentionally does more than a plain stencil update.
