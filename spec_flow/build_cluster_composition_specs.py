#!/usr/bin/env python3
"""Build the audited SimPoint-to-proxy-mechanism grouping specification."""

import argparse
import csv
import json
from collections import Counter
from pathlib import Path


# Groups are semantic, not just a distance threshold over function names.  Every
# source cluster must occur exactly once; the generator verifies that invariant.
CASE_GROUPS = {
    "spec_blender_render_kernel": (
        "526.blender_r",
        [
            ("zbuffer", "raster_zbuffer", [0]),
            ("ray_traversal", "bvh_raycast", [1, 3]),
            ("scene_update", "allocation_transform", [2]),
        ],
    ),
    "spec_bwaves_stencil_kernel": (
        "503.bwaves_r",
        [
            ("matvec", "fp_sparse_matvec", [0, 1, 2]),
            ("bicg_recurrence", "fp_bicg_recurrence", [3]),
        ],
    ),
    "spec_cactubssn_stencil_kernel": (
        "507.cactuBSSN_r",
        [
            ("advection", "fp_stencil_advection", [0, 3]),
            ("rhs", "fp_stencil_rhs", [1]),
            ("constraints", "fp_bounds_constraints", [2]),
        ],
    ),
    "spec_cam4_climate_kernel": (
        "527.cam4_r",
        [
            ("dynamics", "fp_column_dynamics", [0, 1]),
            ("radiation", "fp_transcendental_radiation", [2, 3]),
            ("clouds", "fp_cloud_sedimentation", [4]),
        ],
    ),
    "spec_deepsjeng_search_kernel": (
        "531.deepsjeng_r",
        [
            ("tree_search", "branch_tree_search", [0, 2, 4]),
            ("evaluation_setup", "integer_evaluation_setup", [1, 3]),
        ],
    ),
    "spec_exchange2_search_kernel": (
        "548.exchange2_r",
        [
            ("digit_search", "branch_combinatorial_search", [0, 1, 2, 3]),
            ("minimum_scan", "integer_minimum_reduction", [4]),
        ],
    ),
    "spec_fotonik3d_stencil_kernel": (
        "549.fotonik3d_r",
        [
            ("electric_material", "fp_electric_material", [0]),
            ("magnetic_update", "fp_magnetic_stencil", [2, 4]),
            ("power_and_setup", "fp_power_setup", [1, 3]),
        ],
    ),
    "spec_gcc_compile_kernel": (
        "502.gcc_r",
        [
            ("compiler_graph", "pointer_graph_allocator", [0]),
            ("bitmap", "integer_bitmap", [1]),
            ("cfg_schedule", "branch_cfg_scheduler", [2, 3]),
        ],
    ),
    "spec_imagick_filter_kernel": (
        "538.imagick_r",
        [
            ("mean_shift", "image_mean_shift", [0, 1, 2]),
            ("morphology", "image_morphology", [3]),
        ],
    ),
    "spec_lbm_stream_kernel": (
        "519.lbm_r",
        [
            ("stream_collide", "fp_stream_collide", [0]),
            ("grid_swap", "fp_grid_swap", [1]),
        ],
    ),
    "spec_leela_playout_kernel": (
        "541.leela_r",
        [
            ("primary_playout", "branch_board_playout", [0, 1]),
            ("board_update", "branch_board_state_update", [2, 3, 4]),
        ],
    ),
    "spec_nab_md_kernel": (
        "544.nab_r",
        [
            ("molecular_energy", "fp_molecular_energy", [0, 2, 3]),
            ("nonbonded", "fp_nonbonded_pairs", [1]),
        ],
    ),
    "spec_namd_pair_kernel": (
        "508.namd_r",
        [
            ("full_electrostatic", "fp_full_electrostatic", [0]),
            ("pair_force", "fp_pair_force", [1, 2]),
            ("force_merge", "fp_force_merge", [3, 4]),
        ],
    ),
    "spec_omnetpp_event_kernel": (
        "520.omnetpp_r",
        [
            ("allocation_strings", "allocation_string_runtime", [0, 1]),
            ("event_queue", "pointer_event_queue", [2, 3, 4]),
        ],
    ),
    "spec_perlbench_regex_kernel": (
        "500.perlbench_r",
        [
            ("regex", "branch_regex_engine", [0, 1, 3]),
            ("opcode_objects", "indirect_opcode_object", [2]),
        ],
    ),
    "spec_pop2_ocean_kernel": (
        "628.pop2_s",
        [
            ("ocean_state", "fp_ocean_state", [0, 3, 4]),
            ("advection", "fp_ocean_advection", [1]),
            ("solver_halo", "fp_solver_halo", [2]),
        ],
    ),
    "spec_povray_ray_kernel": (
        "511.povray_r",
        [
            ("geometry", "branch_fp_geometry", [0, 1]),
            ("noise_shading", "fp_noise_shading", [2, 3]),
            ("queue_traversal", "pointer_bvh_queue", [4]),
        ],
    ),
    "spec_roms_stencil_kernel": (
        "554.roms_r",
        [
            ("barotropic", "fp_barotropic_step", [0]),
            ("rhs_mixing", "fp_rhs_mixing", [1, 2]),
            ("eos_flux", "fp_eos_bulk_flux", [3, 4]),
        ],
    ),
    "spec_wrf_stencil_kernel": (
        "521.wrf_r",
        [
            ("dynamics", "fp_atmospheric_dynamics", [0, 1]),
            ("physics", "fp_atmospheric_physics", [2, 3]),
            ("diffusion", "fp_diffusion", [4]),
        ],
    ),
    "spec_x264_pixel_kernel": (
        "525.x264_r",
        [
            ("half_pixel", "integer_half_pixel_filter", [0]),
            ("motion_cost", "integer_sad_satd", [1, 2, 3]),
        ],
    ),
    "spec_xalancbmk_xml_kernel": (
        "523.xalancbmk_r",
        [
            ("dom_strings", "pointer_dom_string_cache", [0, 1, 3]),
            ("datatype_compare", "branch_datatype_compare", [2]),
        ],
    ),
    "spec_xz_lzma_kernel": (
        "557.xz_r",
        [
            ("optimum_match", "integer_lzma_optimum", [1, 3, 4]),
            ("skip_match", "integer_lzma_skip", [0, 2]),
        ],
    ),
}


# SPECspeed cases use their own completed profiles and distinct case names.
# Clusters are grouped by the Speed profile's hotspot semantics; none of these
# definitions inherits cluster ids or weights from the corresponding Rate row.
SPEED_CASE_GROUPS = {
    "spec_600_perlbench_speed_kernel": (
        "600.perlbench_s",
        [
            ("regex", "branch_regex_engine", [0, 3]),
            ("opcode_objects", "indirect_opcode_object", [1, 2]),
        ],
    ),
    "spec_602_gcc_speed_kernel": (
        "602.gcc_s",
        [
            ("bitmap_solver", "integer_bitmap_solver", [0, 1, 2]),
            ("compiler_graph", "pointer_compiler_graph", [3]),
        ],
    ),
    "spec_603_bwaves_speed_kernel": (
        "603.bwaves_s",
        [
            ("matvec_solver", "fp_matvec_solver", [1, 2]),
            ("shell_jacobian", "fp_shell_jacobian", [0, 3, 4]),
        ],
    ),
    "spec_607_cactubssn_speed_kernel": (
        "607.cactuBSSN_s",
        [
            ("advection", "fp_stencil_advection", [1, 4]),
            ("rhs", "fp_stencil_rhs", [3]),
            ("conversion_constraints", "fp_conversion_constraints", [0, 2]),
        ],
    ),
    "spec_619_lbm_speed_kernel": (
        "619.lbm_s",
        [
            ("stream_collide", "fp_stream_collide", [0, 1, 2, 3]),
            ("grid_statistics", "fp_grid_statistics", [4]),
        ],
    ),
    "spec_620_omnetpp_speed_kernel": (
        "620.omnetpp_s",
        [
            ("event_queue", "pointer_event_queue", [0, 1, 4]),
            ("allocation_strings", "allocation_string_runtime", [2, 3]),
        ],
    ),
    "spec_621_wrf_speed_kernel": (
        "621.wrf_s",
        [
            ("dynamics", "fp_atmospheric_dynamics", [0, 3, 4]),
            ("diffusion_advection", "fp_diffusion_advection", [1]),
            ("physics", "fp_transcendental_physics", [2]),
        ],
    ),
    "spec_623_xalancbmk_speed_kernel": (
        "623.xalancbmk_s",
        [
            ("dom_strings", "pointer_dom_string_cache", [0, 1, 2, 3]),
            ("datatype_compare", "branch_datatype_compare", [4]),
        ],
    ),
    "spec_625_x264_speed_kernel": (
        "625.x264_s",
        [
            ("motion_cost", "integer_sad_satd", [0, 2, 3, 4]),
            ("half_pixel", "integer_half_pixel_filter", [1]),
        ],
    ),
    "spec_627_cam4_speed_kernel": (
        "627.cam4_s",
        [
            ("diagnostics_dynamics", "fp_diagnostics_dynamics", [0, 2]),
            ("cloud_optics", "fp_cloud_optics", [1, 3, 4]),
        ],
    ),
    "spec_631_deepsjeng_speed_kernel": (
        "631.deepsjeng_s",
        [
            ("tree_search", "branch_tree_search", [0, 2]),
            ("initialization", "integer_table_initialization", [1]),
        ],
    ),
    "spec_638_imagick_speed_kernel": (
        "638.imagick_s",
        [
            ("morphology", "image_morphology", [0, 1, 2]),
            ("frame_transform", "image_frame_transform", [3]),
        ],
    ),
    "spec_641_leela_speed_kernel": (
        "641.leela_s",
        [
            ("primary_playout", "branch_board_playout", [0, 1]),
            ("board_update", "branch_board_state_update", [2, 3, 4]),
        ],
    ),
    "spec_644_nab_speed_kernel": (
        "644.nab_s",
        [
            ("nonbonded", "fp_nonbonded_pairs", [0]),
            ("molecular_energy", "fp_molecular_energy", [1, 2, 3]),
            ("neighbor_search", "pointer_neighbor_search", [4]),
        ],
    ),
    "spec_648_exchange2_speed_kernel": (
        "648.exchange2_s",
        [
            ("digit_search", "branch_combinatorial_search", [1, 3]),
            ("minimum_scan", "integer_minimum_reduction", [0, 2]),
        ],
    ),
    "spec_649_fotonik3d_speed_kernel": (
        "649.fotonik3d_s",
        [
            ("magnetic_update", "fp_magnetic_stencil", [1]),
            ("electric_material", "fp_electric_material", [2]),
            ("power_and_setup", "fp_power_setup", [0, 3]),
        ],
    ),
    "spec_654_roms_speed_kernel": (
        "654.roms_s",
        [
            ("rhs_mixing", "fp_rhs_mixing", [0, 1, 3]),
            ("eos_flux", "fp_eos_bulk_flux", [2]),
            ("barotropic", "fp_barotropic_step", [4]),
        ],
    ),
    "spec_657_xz_speed_kernel": (
        "657.xz_s",
        [
            ("optimum_match", "integer_lzma_optimum", [0, 4]),
            ("sha", "integer_sha_compression", [1, 2]),
            ("skip_match", "integer_lzma_skip", [3]),
        ],
    ),
}

CASE_GROUPS.update(SPEED_CASE_GROUPS)

# The only unfinished ref profile is explicitly provisional and uses the
# benchmark's own train profile.  It must never fall back to a Rate profile.
CASE_PROFILE_SIZES = {
    "spec_638_imagick_speed_kernel": "train",
}

# New Speed contracts inherit only quick/full sizing bounds from their Rate
# proxy template.  Composition provenance and benchmark identity are replaced.
CASE_PROFILE_TEMPLATES = {
    "spec_600_perlbench_speed_kernel": "spec_perlbench_regex_kernel",
    "spec_602_gcc_speed_kernel": "spec_gcc_compile_kernel",
    "spec_603_bwaves_speed_kernel": "spec_bwaves_stencil_kernel",
    "spec_607_cactubssn_speed_kernel": "spec_cactubssn_stencil_kernel",
    "spec_619_lbm_speed_kernel": "spec_lbm_stream_kernel",
    "spec_620_omnetpp_speed_kernel": "spec_omnetpp_event_kernel",
    "spec_621_wrf_speed_kernel": "spec_wrf_stencil_kernel",
    "spec_623_xalancbmk_speed_kernel": "spec_xalancbmk_xml_kernel",
    "spec_625_x264_speed_kernel": "spec_x264_pixel_kernel",
    "spec_627_cam4_speed_kernel": "spec_cam4_climate_kernel",
    "spec_631_deepsjeng_speed_kernel": "spec_deepsjeng_search_kernel",
    "spec_638_imagick_speed_kernel": "spec_imagick_filter_kernel",
    "spec_641_leela_speed_kernel": "spec_leela_playout_kernel",
    "spec_644_nab_speed_kernel": "spec_nab_md_kernel",
    "spec_648_exchange2_speed_kernel": "spec_exchange2_search_kernel",
    "spec_649_fotonik3d_speed_kernel": "spec_fotonik3d_stencil_kernel",
    "spec_654_roms_speed_kernel": "spec_roms_stencil_kernel",
    "spec_657_xz_speed_kernel": "spec_xz_lzma_kernel",
}


def profile_path(spec_runs: Path, benchmark: str, size: str = "ref") -> Path:
    stem = f"{benchmark}_{size}"
    return spec_runs / f"{stem}_c910" / f"{stem}.function_profile.csv"


def load_profile(path: Path):
    clusters = {}
    with path.open(newline="") as stream:
        for row in csv.DictReader(stream):
            if row["scope"] != "simpoint":
                continue
            cluster = int(row["cluster"])
            entry = clusters.setdefault(
                cluster,
                {
                    "interval": int(row["interval"]),
                    "weight": float(row["weight"]),
                    "functions": Counter(),
                },
            )
            if abs(entry["weight"] - float(row["weight"])) > 1e-12:
                raise ValueError(f"inconsistent weight for cluster {cluster} in {path}")
            # Profiles use one fixed-size interval, so percentages can be mixed
            # using the cluster's SimPoint weight directly.
            entry["functions"][row["function"]] += float(row["percent"]) / 100.0
    if not clusters:
        raise ValueError(f"no simpoint rows in {path}")
    return clusters


def build_case(
    case: str, benchmark: str, groups, profile: Path, profile_size: str = "ref"
):
    clusters = load_profile(profile)
    declared = [cluster for _, _, members in groups for cluster in members]
    if len(declared) != len(set(declared)):
        raise ValueError(f"{case}: a source cluster occurs in multiple groups")
    if set(declared) != set(clusters):
        raise ValueError(
            f"{case}: declared clusters {sorted(declared)} do not match "
            f"profile clusters {sorted(clusters)}"
        )

    raw_total_weight = sum(clusters[cluster]["weight"] for cluster in clusters)
    if abs(raw_total_weight - 1.0) > 1e-5:
        raise ValueError(f"{case}: source weights sum to {raw_total_weight}, not one")
    output_groups = []
    for name, mechanism, members in groups:
        weight = sum(clusters[cluster]["weight"] for cluster in members)
        function_mix = Counter()
        for cluster in members:
            source = clusters[cluster]
            for function, share in source["functions"].items():
                function_mix[function] += source["weight"] * share / weight
        output_groups.append(
            {
                "name": name,
                "mechanism": mechanism,
                "clusters": members,
                "intervals": [clusters[cluster]["interval"] for cluster in members],
                "source_weight": weight,
                "target_weight": weight / raw_total_weight,
                "top_functions": [
                    {"name": function, "share_within_group": share}
                    for function, share in function_mix.most_common(12)
                ],
            }
        )

    total_weight = sum(group["target_weight"] for group in output_groups)
    if abs(total_weight - 1.0) > 1e-12:
        raise AssertionError(f"{case}: normalized weights sum to {total_weight}")
    return {
        "benchmark": benchmark,
        "case": case,
        "calibration": (
            "simpoint-cluster-composition"
            if len(output_groups) > 1
            else "simpoint-single-group"
        ),
        "source_profile_size": profile_size,
        "source_profile": str(profile),
        "source_cluster_count": len(clusters),
        "mechanism_group_count": len(output_groups),
        "groups": output_groups,
    }


def build(spec_runs: Path):
    cases = []
    for case, (benchmark, groups) in CASE_GROUPS.items():
        profile_size = CASE_PROFILE_SIZES.get(case, "ref")
        path = profile_path(spec_runs, benchmark, profile_size)
        if not path.is_file():
            raise FileNotFoundError(path)
        built = build_case(case, benchmark, groups, path, profile_size)
        template = CASE_PROFILE_TEMPLATES.get(case)
        if template:
            built["profile_contract_template"] = template
        cases.append(built)
    return {
        "schema": "openc910-spec-cluster-compositions-v1",
        "description": (
            "Audited semantic grouping of completed benchmark-local SimPoint clusters. "
            "Target weights come directly from the selected SPEC function profiles."
        ),
        "cases": cases,
    }


def write_markdown(path: Path, result):
    lines = [
        "# SPEC SimPoint Cluster 组合定义",
        "",
        "本表由各 benchmark 自己的 function profile 自动生成。cluster 先按热点函数与机制语义",
        "合并，再映射为同一 bare-metal ELF 内的 phase；目标权重为源 SimPoint",
        "权重归一化结果。当前 40 个通用 case 均拆分为 2 至 3 个机制 phase；",
        "`simpoint-single-group` 仅作为生成器对未来同质输入的兼容类别保留。",
        "",
        "| case | 源 benchmark | 校准类别 | phase | cluster | 目标权重 | 机制 | 主要源热点函数 |",
        "|---|---|---|---:|---|---:|---|---|",
    ]
    for case in result["cases"]:
        for index, group in enumerate(case["groups"]):
            hotspots = ", ".join(
                f"`{item['name']}` {item['share_within_group'] * 100:.1f}%"
                for item in group["top_functions"][:3]
            )
            clusters = ",".join(str(value) for value in group["clusters"])
            lines.append(
                f"| `{case['case']}` | `{case['benchmark']}` | "
                f"`{case['calibration']}` | {index} | `{clusters}` | "
                f"{group['target_weight']:.6f} | `{group['mechanism']}` | {hotspots} |"
            )
    lines.extend([
        "",
        "## 校验规则",
        "",
        "- 每个源 cluster 必须且只能出现一次，所有归一化目标权重之和必须为 1。",
        "- quick/full 使用同一 ELF 内的显式 phase 边界统计全部嵌套调用指令。",
        "- 每个 phase 的实测动态指令份额与目标权重最大偏差为 0.5 个百分点。",
        "- full footprint 位于所有 phase 外，不参与机制权重，但计入 ROI 与工作集。",
        "- 这些定义是 SimPoint 指导的代理，不是 SPEC checkpoint/restore 代表区间。",
        "",
    ])
    path.write_text("\n".join(lines))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec-runs", type=Path, default=Path("spec_runs"))
    parser.add_argument(
        "--output", type=Path, default=Path("spec_flow/spec_cluster_compositions.json")
    )
    parser.add_argument(
        "--markdown", type=Path,
        default=Path("spec_flow/SPEC_CLUSTER_COMPOSITIONS.md"),
    )
    args = parser.parse_args()
    result = build(args.spec_runs)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    write_markdown(args.markdown, result)
    multi = sum(case["mechanism_group_count"] > 1 for case in result["cases"])
    print(f"wrote {args.output}: {len(result['cases'])} cases, {multi} multi-group")


if __name__ == "__main__":
    main()
