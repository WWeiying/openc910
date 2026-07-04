# spec_povray_ray_kernel

`spec_povray_ray_kernel` models `511.povray_r` style rendering work:
ray/object intersection scans, FP geometry, shading branches, and bounced ray
state updates.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_POVRAY_RAYS=32
SPEC_POVRAY_OBJECTS=8
SPEC_POVRAY_BOUNCES=1
```

Build and run:

```bash
make buildcase CASE=spec_povray_ray_kernel DUMP=off
make simcase CASE=spec_povray_ray_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_povray_ray_kernel DUMP=off SPEC_POVRAY_REPRESENTATIVE=1
```
