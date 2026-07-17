# spec_gcc_compile_kernel

Models `502.gcc_r` style compiler backend work: garbage-collected allocation
churn, RTL recognizer table walks, multiply/constant-fold style integer work,
and IRA-like interference updates. This is a representative RTL kernel, not
SPEC source.

The SPEC `test` profile has only one SimPoint interval, so this kernel is still
a mechanism model rather than a strong checkpoint substitute. It is designed to
cover the observed `ggc_alloc_stat`, `do_multiply`, `recog_32`, and `ira_init`
directions more directly than a generic graph traversal.
