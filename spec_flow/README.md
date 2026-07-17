# SPEC CPU2017 on Xuantie QEMU

This flow is intended to run inside the Ubuntu 20.04 Docker container while all
inputs and outputs stay visible on the host under the repository directory.

## Container

From the host:

```sh
cd smart_run
make docker-create
make docker-start
make docker-deps
make docker-shell
```

The repository is mounted as `/work` in the container.

## Tool Smoke Test

```sh
cd /work
./spec_flow/smoke_tools.sh
```

This checks the Xuantie GCC glibc toolchain, bundled Xuantie QEMU, and SimPoint.

## SPEC Install

The ISO is expected at:

```text
/work/CPU 2017 1.0.5.iso
```

Install with:

```sh
cd /work
./spec_flow/install_spec2017.sh
```

Host-visible directories:

```text
spec2017_iso/   extracted ISO tree
spec2017/       installed SPEC tree
spec_runs/      logs, BBV files, SimPoint outputs
```

## Compile/Run Configuration

Generated config:

```text
spec2017/config/c910-gcc-linux.cfg
spec_runs/c910-gcc-linux.cfg
```

Key compiler options follow the current C910 Makefile ISA settings:

```text
-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910
```

The SPEC `submit` command runs target binaries with:

```text
qemu-riscv64 -cpu c910 -L <Xuantie GCC glibc sysroot>
```

## Run SPEC Through QEMU

Default smoke benchmark:

```sh
cd /work
./spec_flow/run_spec_qemu.sh 505.mcf_r test run
```

Verified result:

```text
505.mcf_r test: build + QEMU run + SPEC compare passed
SPEC log: spec2017/result/CPU2017.006.log
Text report: spec2017/result/CPU2017.006.intrate.test.txt
Script log: spec_runs/logs/505.mcf_r_test_run.log
Elapsed in this environment: 139 seconds
```

## Generate BBV and SimPoint

Build the local BBV plugin:

```sh
cd /work/tools/qemu-plugins
make
make check-fork
```

`check-fork` runs a RISC-V guest fork test and requires at least two raw PID
namespaces, conflict-free compaction, and contiguous compact block IDs.

Run BBV collection plus SimPoint:

```sh
cd /work
./spec_flow/run_bbv_simpoint.sh 505.mcf_r test 5 100000000
```

Arguments:

```text
1: benchmark, default 505.mcf_r
2: input size, default test
3: SimPoint maxK, default 10
4: BBV interval in guest instructions, default 100000000
```

Outputs:

```text
spec_runs/<bench>_<size>_c910/<bench>_<size>.bb
spec_runs/<bench>_<size>_c910/<bench>_<size>.bb.map
spec_runs/<bench>_<size>_c910/<bench>_<size>.bb.cmdmap
spec_runs/<bench>_<size>_c910/<bench>_<size>.bb.modules
spec_runs/<bench>_<size>_c910/<bench>_<size>.simpoints
spec_runs/<bench>_<size>_c910/<bench>_<size>.weights
spec_runs/<bench>_<size>_c910/qemu_bbv.log
spec_runs/<bench>_<size>_c910/simpoint.log
```

Notes:

```text
The bundled Xuantie libbbv.so accepts interval/rr-style options and does not
produce standard SimPoint .bb files with outfile=.  This flow therefore uses
tools/qemu-plugins/simple_bbv.so, built against the bundled qemu-plugin.h.

BBV collection is much slower than plain QEMU because it instruments every
translated block.  Use large intervals, start with test/train inputs, and run
reference inputs in the background.

New full-program profiles reserve a deterministic guest VA range with
`qemu-riscv64 -R 0x4000000000`. Before BBV collection, the flow records the
guest loader and shared-library address ranges in `.bb.modules` using
`LD_DEBUG=files` plus QEMU `-strace`. Function profiling then resolves TB PCs
against the main ELF and the RISC-V loader/libc/libstdc++/libm/libgcc symbols.
This prevents dynamically linked execution from being collapsed into
`[external-or-unknown]`. Older profiles without `.bb.modules` remain readable
but do not have this enhanced shared-library attribution.
```

Partial validation already produced host-visible SimPoint outputs:

```text
spec_runs/505.mcf_r_test_c910/505.mcf_r_test.bb
spec_runs/505.mcf_r_test_c910/505.mcf_r_test.simpoints
spec_runs/505.mcf_r_test_c910/505.mcf_r_test.weights
spec_runs/605.mcf_s_test_c910/605.mcf_s_test.bb
spec_runs/605.mcf_s_test_c910/605.mcf_s_test.simpoints
spec_runs/605.mcf_s_test_c910/605.mcf_s_test.weights
```

## Batch SimPoint Coverage

Run the configured SPEC2017 rate benchmark set for one input size:

```sh
cd /work
./spec_flow/run_representative_batch.sh test 5 100000000
```

Run the SPECspeed benchmark set for one input size:

```sh
cd /work
./spec_flow/run_representative_batch.sh --suite speed test 5 100000000
```

Run multiple input sizes with the same benchmark list:

```sh
cd /work
./spec_flow/run_spec2017_simpoint_sizes.sh "train ref" 5 100000000
```

Run multiple SPECspeed input sizes:

```sh
cd /work
./spec_flow/run_spec2017_simpoint_sizes.sh --suite speed "train ref" 5 100000000
```

The suite can also be selected with `SPEC_BENCH_SUITE`:

```sh
cd /work
SPEC_BENCH_SUITE=speed ./spec_flow/run_representative_batch.sh test 5 100000000
```

To finish an interrupted full L2+ campaign, strictly re-run only incomplete
cases, and finalize reports only after all 129 manifests pass:

```sh
cd /work
./spec_flow/complete_l2plus.sh \
  /work/smart_run/results/archive/spec2017_l2plus_rtl_full_1f451a653e1c_dirty
```

When another scheduler is still active, pass its PID and the completion driver
will wait before acquiring the scheduler lock:

```sh
L2PLUS_WAIT_PID=<scheduler-pid> ./spec_flow/complete_l2plus.sh <rtl-results>
```

Supported suite selectors:

```text
rate      = intrate + fprate, benchmark names ending in _r
speed     = intspeed + fpspeed, benchmark names ending in _s
all       = rate + speed
intrate   = integer rate only
fprate    = floating-point rate only
intspeed  = integer speed only
fpspeed   = floating-point speed only
```

The batch flow writes one directory per benchmark:

```text
spec_runs/<bench>_<size>_c910/
  <bench>_<size>.bb
  <bench>_<size>.bb.map
  <bench>_<size>.bb.cmdmap
  <bench>_<size>.simpoints
  <bench>_<size>.weights
  <bench>_<size>.function_profile.csv
  manifest.json
```

Do not infer campaign completion from static documentation or the presence of
an output directory. Use `check_l2plus_status.sh`, which validates every
manifest and artifact, as the live source of truth. A campaign is complete
only at strict `129/129`, followed by a successful `finalize_l2plus.sh` run and
a zero-error `SPEC2017_L2PLUS_FINAL_VALIDATION.md`.

For `train` and `ref`, prefer background runs plus explicit status checks. A
single benchmark can take tens of minutes or longer under QEMU BBV
instrumentation.

```sh
cd /work
mkdir -p spec_runs/logs
nohup ./spec_flow/run_representative_batch.sh --suite speed train 5 100000000 \
  625.x264_s 619.lbm_s 654.roms_s \
  > spec_runs/logs/speed_train_subset.log 2>&1 &
```

Check completion status without parsing all logs:

```sh
cd /work
./spec_flow/check_simpoint_status.py --suite speed --size train
./spec_flow/check_simpoint_status.py --suite speed --size train 605.mcf_s 619.lbm_s
```

### Complete L2+ matrix

The L2+ target covers all 129 Rate/Speed x test/train/ref combinations. Show
the unified matrix with:

```sh
./spec_flow/check_l2plus_status.sh
```

This status command uses the strict per-case validator by default. For a fast
artifact-only snapshot that may count semantically invalid manifests, use
`L2PLUS_STATUS_MODE=basic ./spec_flow/check_l2plus_status.sh`.

Audit shared-library attribution and weighted SimPoint unknown coverage with:

```sh
python3 spec_flow/check_profile_quality.py --suite speed --size train
python3 spec_flow/check_profile_quality.py --suite rate --size ref
```

`legacy` means the profile predates deterministic guest VA/module mapping;
`high/medium/low` use weighted SimPoint unknown thresholds of 5% and 20%.
Addresses inside a known stripped shared object are reported separately as
`[module:<name>:unresolved]`; they retain module attribution and are not mixed
with PCs whose owning ELF/module is unknown.

Run the final requirement-by-requirement L2+ gate with:

```sh
python3 spec_flow/validate_l2plus.py \
  > spec_flow/SPEC2017_L2PLUS_FINAL_VALIDATION.md
```

The command exits non-zero until all 129 manifests pass identity, SPEC compare,
100M full-program BBV, SimPoint, weight-sum, artifact, module-address overlap,
compiler-option, provenance, and weighted external-unknown checks; both
Rate/Speed maps must be bound to the current ref manifest SHA-256 values; and
all mapped composite RTL kernels must have `TEST PASS`, phase summaries, detailed
counters, assembly, and simulation logs. By default the validator selects the
newest `smart_run/results/spec2017_l2plus_rtl_full_*` directory; use
`--rtl-results` to select one explicitly.

Check one manifest with the same strict rules using:

```sh
./spec_flow/check_l2plus_case.py 502.gcc_r train
```

The strict check also requires unique BBV block IDs, contiguous per-command ID
ranges, and module-range overlap for every command. This catches multi-command
collections whose plugin ID offset was not advanced between QEMU processes.

Manifest provenance records Git commit/dirty state, exact QEMU and GCC paths
and versions, and the SimPoint binary. Backfill provenance for valid legacy
manifests without rerunning BBV with:

```sh
python3 spec_flow/backfill_manifest_provenance.py \
  --spec-runs /work/spec_runs --repo-root /work \
  --qemu-path "$QEMU" --compiler-path "$GCC_GLIBC/bin/riscv64-unknown-linux-gnu-gcc" \
  --simpoint-path "$SIMPOINT"
```

Run or resume the remaining full-program profiles in parallel:

```sh
L2PLUS_WORKERS=8 ./spec_flow/run_l2plus_parallel.sh
```

Each worker uses an XFS reflink copy under `spec2017_workers/worker-<N>` so
concurrent `runcpu --action=runsetup` commands do not share writable SPEC run
directories. Benchmark assignment is stable across train/ref, allowing each
worker to reuse its locally built executable. Outputs remain in the common
`spec_runs` tree, with per-case logs under `spec_runs/logs/l2plus_parallel`.
For `--size=ref`, the flow resolves SPEC's actual `refspeed` and `refrate` run
directory tags from the benchmark suffix instead of assuming a `ref` tag.
The scheduler uses the same singleton lock and 500 GiB free-space guard as the
sequential runner. It traverses all six Rate/Speed x test/train/ref groups,
uses `check_l2plus_case.py` as its skip condition, and recollects an existing
manifest when strict validation fails.

An active campaign can use otherwise idle host cores with an explicit
supplemental queue:

```sh
./spec_flow/run_l2plus_supplement.sh speed ref \
  648.exchange2_s 657.xz_s 603.bwaves_s 607.cactuBSSN_s
```

Supplemental workers use separate reflink roots under
`spec2017_supplement_workers/`. Every batch invocation holds a per-benchmark
lock under `spec_runs/logs/l2plus_case_locks`; after acquiring it, the batch
rechecks strict completion and skips work completed by another scheduler. The
supplement command deliberately requires an explicit benchmark list so the
operator controls added CPU and memory pressure.

Perlbench can recursively invoke and fork its executable hundreds of times
inside one SPEC command. The BBV plugin optionally encodes the host PID above
32 per-process TB-ID bits, resets inherited interval counts after fork, and
therefore gives both wrapper-launched and forked QEMU children disjoint raw ID
namespaces. `compact_bbv_ids.py` stores those sparse PID ranges in compact
`uint64` arrays, merges identical fixed-VA TBs, and streams the rewritten BBV
as contiguous IDs before SimPoint. This prevents fork collisions, excessively
sparse feature dimensions, and ref-scale Python memory growth.

The sequential fallback is:

```sh
./spec_flow/run_l2plus_remaining.sh
```

The sequential scheduler traverses all six Rate/Speed x test/train/ref groups,
uses the same strict per-case gate and forced recollection behavior as the
parallel scheduler, keeps per-benchmark logs, retries incomplete entries twice,
prevents duplicate schedulers with `flock`, and stops before free disk drops
below 500 GiB. Runtime state is stored under:

```text
spec_runs/logs/l2plus_remaining/scheduler.pid
spec_runs/logs/l2plus_remaining/scheduler.log
spec_runs/logs/l2plus_remaining/<suite>_<size>/<benchmark>.round<N>.log
```

If a long run finished all BBV commands but was interrupted before compare or
SimPoint post-processing, recover it without recollecting BBV:

```sh
./spec_flow/finalize_existing_bbv.sh 500.perlbench_r train 5 100000000
```

The recovery command requires non-empty `.bb`, `.bb.map`, `.bb.cmdmap`, and
`.bb.modules`. It verifies the expected SPEC command count, contiguous unique
map IDs, contiguous command ranges, final map ID, and module coverage before
running SPEC compare, SimPoint, function attribution, and manifest generation.

During a long campaign, watch for fully collected cases whose shell was
interrupted during post-processing:

```sh
L2PLUS_RECOVERY_WATCH=1 ./spec_flow/recover_l2plus_partials.sh
```

The watcher skips any case with a live QEMU, BBV collector, or batch process,
uses the same per-case lock as the schedulers, and never treats a partial
multi-command BBV as complete.

Legacy completed BBVs can be upgraded to deterministic shared-library
attribution and explicit full-program metadata without recollecting BBV:

```sh
BACKFILL_WORKERS=8 ./spec_flow/backfill_module_profiles.sh
```

After changing function-symbol attribution, rebuild every eligible existing
profile and manifest, including cases that already pass the strict gate, with:

```sh
BACKFILL_ALL_EXISTING=1 BACKFILL_WORKERS=8 \
  ./spec_flow/backfill_module_profiles.sh
```

For fixed-VA traces, the command performs a short loader probe directly. For
legacy ASLR traces, it records a same-process probe BBV and loader map, finds
the address slide by exact translated-block matches, and writes the match
evidence to `module_recovery.log`. It then regenerates the function profile in
a single streaming BBV pass and atomically replaces the manifest. The strict
validator rejects module ranges that do not overlap the recorded BBV PCs.

For the current Docker environment, launch it detached with:

```sh
docker exec -d openc910-qemu bash -lc \
  'cd /work && exec env L2PLUS_WORKERS=8 ./spec_flow/run_l2plus_parallel.sh'
```

Status meanings:

```text
ok       = manifest exists, SPEC compare passed, SimPoint output exists
partial  = BBV exists but manifest is missing; do not use as a completed result
missing  = no output directory/artifacts yet
compare_failed = manifest exists, SimPoint exists, but SPEC compare did not pass
incomplete     = manifest exists, but SimPoint validation is incomplete
```

If a foreground run is interrupted, the directory may contain a partial `.bb`.
The normal batch script will rerun that benchmark because `.simpoints`,
`.weights`, or `manifest.json` are missing.

## Aggregate RTL Representative Results

After all 43 ref manifests pass the strict gate, bind both kernel maps to the
exact ref manifest contents. For mappings that have completed mechanism
grouping, every SimPoint cluster is assigned to an internal mechanism of one
benchmark-level composite ELF. The cluster weight becomes that mechanism's
target dynamic retired-instruction share:

```sh
cd /work
python3 spec_flow/calibrate_kernel_map.py \
  --kernel-map spec_flow/spec2017_kernel_map.json \
  --spec-runs spec_runs --require-cluster-mapping \
  --out spec_flow/spec2017_kernel_map.json
python3 spec_flow/calibrate_kernel_map.py \
  --kernel-map spec_flow/spec2017_speed_kernel_map.json \
  --spec-runs spec_runs --require-cluster-mapping \
  --out spec_flow/spec2017_speed_kernel_map.json
```

The calibrated map records a SHA-256 digest for every ref manifest. The final
validator rejects a map if any manifest changes after calibration.

After running all mapped kernels with `smart_run/run_bench.sh`, generate the
separate Rate and Speed ref proxy reports:

The normal one-ELF-per-benchmark entry point derives the unique case list from
both maps. Its default mode collects whole-ELF program features and then runs
the same cases in RTL:

```sh
./spec_flow/run_composite_rtl.sh --suite all --tag spec2017_composite_v1
```

Use `--features-only`, `--rtl-only`, or `--list` when only that stage is needed.
The command rejects any benchmark row that maps to more than one RTL case.

```sh
cd /work
RTL_RESULTS=smart_run/results/spec2017_l2plus_rtl_full_<git>_<state>
python3 spec_flow/aggregate_rtl_by_simpoint.py \
  --size ref --spec-runs spec_runs --rtl-results "$RTL_RESULTS" \
  --kernel-map spec_flow/spec2017_kernel_map.json --require-pass \
  --out-md spec_flow/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.md \
  --out-json spec_flow/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.json
python3 spec_flow/aggregate_rtl_by_simpoint.py \
  --size ref --spec-runs spec_runs --rtl-results "$RTL_RESULTS" \
  --kernel-map spec_flow/spec2017_speed_kernel_map.json \
  --require-pass \
  --out-md spec_flow/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.md \
  --out-json spec_flow/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.json
```

The production close-out command performs the 129-manifest, complete cluster
mapping, and RTL-kernel
preflights, calibrates both maps atomically, writes both proxy/alignment
reports, and runs the final strict gate:

```sh
./spec_flow/finalize_l2plus.sh \
  smart_run/results/spec2017_l2plus_rtl_full_<git>_<state>
```

Inputs:

```text
spec_flow/spec2017_kernel_map.json        rate benchmark -> RTL kernel mapping
spec_flow/spec2017_speed_kernel_map.json  speed benchmark -> RTL kernel mapping
spec_runs/*/manifest.json                 SPEC/QEMU/SimPoint validation
smart_run/results/<run>/*.summary         RTL cycles / retired instruction / IPC
smart_run/results/<run>/*.perf            RTL detailed counters
```

The maps default to `ref`. A completed mapping stores each cluster ID together
with its representative interval. Calibration rejects missing/duplicate
clusters, changed representative intervals, more than one RTL kernel per
benchmark, and an embedded mechanism share that differs from its cluster target
by more than 0.5 percentage points. Rows without explicit cluster assignments
remain `single_proxy`. Intermediate reports allow these rows, but production
calibration and `finalize_l2plus.sh` reject them.

Output:

```text
spec_flow/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.md
spec_flow/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.json
spec_flow/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.md
spec_flow/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.json
```

This aggregate is a repository-local, SimPoint-guided SPEC-like RTL proxy
profile. Each benchmark contributes one RTL composite ELF and no post-RTL
sub-kernel weighting is performed. It is not an official SPEC CPU2017 score,
not real SPEC execution on RTL, and not an exact SimPoint checkpoint result.
