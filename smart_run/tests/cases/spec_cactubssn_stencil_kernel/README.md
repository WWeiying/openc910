# spec_cactubssn_stencil_kernel

`spec_cactubssn_stencil_kernel` models `507.cactuBSSN_r` style numerical
relativity work: 3D stencil traversal, tensor coupling, floating-point updates,
and structured memory access.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_CACTU_N=6
SPEC_CACTU_STEPS=1
SPEC_CACTU_TENSORS=3
```

Build and run:

```bash
make buildcase CASE=spec_cactubssn_stencil_kernel DUMP=off
make simcase CASE=spec_cactubssn_stencil_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_cactubssn_stencil_kernel DUMP=off SPEC_CACTU_REPRESENTATIVE=1
```
