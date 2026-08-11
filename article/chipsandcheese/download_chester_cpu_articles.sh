#!/usr/bin/env bash

set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
downloader="${script_dir}/download_webpage.py"
output_dir="${script_dir}/input"

articles=(
  "arm_cortex_x925|https://chipsandcheese.com/p/arms-cortex-x925-reaching-desktop"
  "arm_cortex_a725|https://chipsandcheese.com/p/arms-cortex-a725-ft-dells-pro-max"
  "arm_cortex_a55|https://chipsandcheese.com/p/arms-cortex-a55"
  "amd_epyc_9355p|https://chipsandcheese.com/p/amds-epyc-9355p-inside-a-32-core"
  "huawei_kunpeng_920_taishan_v110_cpu_architecture|https://chipsandcheese.com/p/huaweis-kunpeng-920-and-taishan-v110"
  "qualcomm_centriq_2400_falkor|https://chipsandcheese.com/p/qualcomms-centriq-2400-and-the-falkor"
  "sifive_p550_microarchitecture|https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture"
  "loongson_3a6000|https://chipsandcheese.com/p/loongson-3a6000-a-star-among-chinese-cpus"
  "qualcomm_oryon|https://chipsandcheese.com/p/qualcomms-oryon-core-a-long-time-in-the-making"
  "arm_neoverse_v2_graviton_4|https://chipsandcheese.com/p/arms-neoverse-v2-in-awss-graviton"
  "amd_bergamo_zen_4c|https://chipsandcheese.com/p/testing-amds-bergamo-zen-4c-spam"
  "nvidia_gb10_cpu_memory_subsystem|https://chipsandcheese.com/p/inside-nvidia-gb10s-memory-subsystem"
  "intel_xeon_6_memory_subsystem|https://chipsandcheese.com/p/a-look-into-intel-xeon-6s-memory"
  "amd_turin_uniform_memory_access|https://chipsandcheese.com/p/evaluating-uniform-memory-access"
  "amd_zen_5_avx512_frequency|https://chipsandcheese.com/p/zen-5s-avx-512-frequency-behavior"
  "amd_zen_5_op_cache_clustered_decoder|https://chipsandcheese.com/p/disabling-zen-5s-op-cache-and-exploring"
  "intel_lion_cove_memory_subsystem|https://chipsandcheese.com/p/analyzing-lion-coves-memory-subsystem"
  "intel_skymont_gaming_workloads|https://chipsandcheese.com/p/skymont-in-gaming-workloads"
  "amd_zen_5_gaming_workloads|https://chipsandcheese.com/p/running-gaming-workloads-through"
  "intel_lion_cove_gaming_workloads|https://chipsandcheese.com/p/intels-lion-cove-p-core-and-gaming"
  "chinese_cpus_spec_cpu2017|https://chipsandcheese.com/p/running-spec-cpu2017-on-chinese"
)

completed=0
skipped=0
failed=0

printf 'Starting Chips and Cheese CPU article queue: %s articles\n' "${#articles[@]}"
printf 'Output directory: %s\n' "${output_dir}"

for article in "${articles[@]}"; do
  name="${article%%|*}"
  url="${article#*|}"
  html_path="${output_dir}/${name}.html"
  asset_path="${output_dir}/${name}_files"

  if [[ -e "${html_path}" || -e "${asset_path}" ]]; then
    printf '[SKIP] %s: archive already exists\n' "${name}"
    skipped=$((skipped + 1))
    continue
  fi

  printf '[START] %s <- %s\n' "${name}" "${url}"
  if python3 "${downloader}" \
      "${url}" \
      --name "${name}" \
      --output-dir "${output_dir}" \
      --allow-partial; then
    printf '[DONE] %s\n' "${name}"
    completed=$((completed + 1))
  else
    printf '[FAIL] %s\n' "${name}"
    failed=$((failed + 1))
  fi
done

printf 'Queue finished: completed=%d skipped=%d failed=%d total=%d\n' \
  "${completed}" "${skipped}" "${failed}" "${#articles[@]}"

if ((failed > 0)); then
  exit 1
fi
