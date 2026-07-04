# spec_x264_pixel_kernel

`spec_x264_pixel_kernel` models the dominant `525.x264_r test` profile:
SAD/SATD block metrics, reference-pixel access, interpolation-like averaging,
and small transform/quantization loops.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_X264_WIDTH=24
SPEC_X264_HEIGHT=24
SPEC_X264_BLOCKS=1
SPEC_X264_PASSES=1
SPEC_X264_CANDIDATES=1
```

Build and run:

```bash
make buildcase CASE=spec_x264_pixel_kernel DUMP=off
make simcase CASE=spec_x264_pixel_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_x264_pixel_kernel DUMP=off SPEC_X264_REPRESENTATIVE=1
```
