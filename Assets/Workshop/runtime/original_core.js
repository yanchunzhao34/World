// Extracted from the local published build. CPU algorithms are unchanged.
// 着色器资源与描述符元数据：由原版发布包提取，platform.js 依赖其字段。
var Ne = {
        "bodies/body_claim.comp": {
            readWrite: [`cells`],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 3,
                binding: 0,
                name: `cells_r`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }],
            workgroup: [64, 1, 1]
        },
        "bodies/body_dead.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed_1`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 0,
                name: `unnamed_2`,
                kind: `storage`
            }],
            workgroup: [64, 1, 1]
        },
        "bodies/body_displace.comp": {
            readWrite: [`cells`, `cells`],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 3,
                binding: 0,
                name: `cells_r`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `cells_pre`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_1`,
                kind: `storage`
            }],
            workgroup: [256, 1, 1]
        },
        "bodies/body_erase.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 6,
                name: `unnamed_2`,
                kind: `storage`
            }, {
                group: 0,
                binding: 5,
                name: `unnamed_3`,
                kind: `storage`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_4`,
                kind: `read-only-storage`
            }],
            workgroup: [8, 8, 1]
        },
        "bodies/body_occ.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_1`,
                kind: `storage`
            }],
            workgroup: [64, 1, 1]
        },
        "bodies/body_owner.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 0,
                name: `unnamed_1`,
                kind: `storage`
            }],
            workgroup: [64, 1, 1]
        },
        "bodies/body_stamp.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 6,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed_1`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_2`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed_3`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 5,
                name: `unnamed_4`,
                kind: `storage`
            }, {
                group: 0,
                binding: 7,
                name: `unnamed_5`,
                kind: `storage`
            }],
            workgroup: [8, 8, 1]
        },
        "fluid/advect.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed_1`,
                kind: `storage`
            }],
            workgroup: [8, 8, 1]
        },
        "fluid/divergence.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 1,
                name: `div_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `r32float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "fluid/fluid_inject.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed_2`,
                kind: `read-only-storage`
            }],
            workgroup: [8, 8, 1]
        },
        "fluid/medium.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 2,
                name: `vel_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 2,
                name: `vel_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 0,
                name: `medium_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `medium_in_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 5,
                name: `unnamed_1`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `medium_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "fluid/pressure.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 0,
                name: `p_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `div_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `p_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `r32float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "fluid/pressure_solve.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `p_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `div_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 3,
                name: `vel`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `p_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `r32float`,
                access: `write-only`
            }],
            workgroup: [1024, 1, 1]
        },
        "fluid/project.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 2,
                name: `pres`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 3,
                name: `vel_view`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "net/net_chunks.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `storage`
            }, {
                group: 0,
                binding: 1,
                name: `medium`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed_2`,
                kind: `storage`
            }],
            workgroup: [16, 16, 1]
        },
        "net/state_hash.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_1`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 3,
                name: `pressure`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed_2`,
                kind: `storage`
            }],
            workgroup: [64, 1, 1]
        },
        "render/beam_blur.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 1,
                name: `prev_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 4,
                name: `dir_prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 3,
                name: `dir_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/beam_probe.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 3,
                name: `emissive_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 2,
                name: `albedo_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 8,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 8,
                name: `day_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 11,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 12,
                name: `unnamed_2`,
                kind: `storage`
            }, {
                group: 0,
                binding: 4,
                name: `gaux_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 5,
                name: `fluence_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `fluence_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 6,
                name: `ldir_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 6,
                name: `ldir_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 7,
                name: `unnamed_3`,
                kind: `storage`
            }, {
                group: 0,
                binding: 9,
                name: `beam_prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 9,
                name: `beam_prev_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 10,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 10,
                name: `medium_tex_smp`,
                kind: `sampler`
            }],
            workgroup: [256, 1, 1]
        },
        "render/beam_waves.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 3,
                name: `emissive_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 2,
                name: `albedo_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `gaux_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 7,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 10,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 10,
                name: `medium_tex_smp`,
                kind: `sampler`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 11,
                name: `unnamed_2`,
                kind: `storage`
            }, {
                group: 0,
                binding: 8,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 8,
                name: `day_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 12,
                name: `unnamed_3`,
                kind: `storage`
            }, {
                group: 0,
                binding: 5,
                name: `fluence_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `fluence_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 6,
                name: `ldir_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 6,
                name: `ldir_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 9,
                name: `beam_prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 9,
                name: `beam_prev_smp`,
                kind: `sampler`
            }],
            workgroup: [8, 8, 1]
        },
        "render/bloom_down.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `src`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `src_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `dst`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/bloom_up.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `low`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `low_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `cur`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 1,
                name: `cur_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 2,
                name: `dst`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/composite.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 8,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 12,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 12,
                name: `day_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 13,
                name: `beam_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 13,
                name: `beam_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 3,
                name: `fluence_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `fluence_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 15,
                name: `cha_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 15,
                name: `cha_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 16,
                name: `chb_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 16,
                name: `chb_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `emissive_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `albedo_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `gaux_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 6,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 7,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `ldir_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 4,
                name: `ldir_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 14,
                name: `beam_dir_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 14,
                name: `beam_dir_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 11,
                name: `sub_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 5,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `medium_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 9,
                name: `l0s_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 10,
                name: `l0t_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/daylight.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 10,
                name: `day_cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 5,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 7,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 3,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `medium_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 8,
                name: `prev_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 4,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/debug_view.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 3,
                name: `aux_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `aux_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 2,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba8unorm`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/dof.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `src`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `src_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `dst`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/downsample.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `src`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `dst`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/exposure.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 1,
                name: `ex`,
                kind: `storage`
            }, {
                group: 0,
                binding: 2,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `hdr`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }],
            workgroup: [8, 8, 1]
        },
        "render/fog_backlight.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `l0s`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `l0t`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `fl2_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 2,
                name: `fl2_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 3,
                name: `fl3_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `fl3_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 4,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 4,
                name: `day_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 5,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/front_fog.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 8,
                name: `backlight`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 6,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 5,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 0,
                name: `l0s`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `l0t`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `bg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 3,
                name: `fl2_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `fl2_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 4,
                name: `fl3_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 4,
                name: `fl3_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 7,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 7,
                name: `day_tex_smp`,
                kind: `sampler`
            }],
            workgroup: [8, 8, 1]
        },
        "render/gbuffer.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 4,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 2,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 2,
                name: `medium_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 3,
                name: `fluence_prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `fluence_prev_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 12,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 12,
                name: `day_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 9,
                name: `bg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 11,
                name: `beam_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 11,
                name: `beam_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 5,
                name: `albedo_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 6,
                name: `emissive_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 7,
                name: `rcsrc_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 10,
                name: `rcext_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 8,
                name: `gaux_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 13,
                name: `ldir_prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 13,
                name: `ldir_prev_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 14,
                name: `gloss_a_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/godrays.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 4,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 3,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 0,
                name: `rcsrc`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `rcsrc_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `bg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 2,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 2,
                name: `medium_tex_smp`,
                kind: `sampler`
            }],
            workgroup: [8, 8, 1]
        },
        "render/light_prep.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `gloss`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `albedo_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 3,
                name: `emissive_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 5,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 6,
                name: `day_cells`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 4,
                name: `bg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `storage`
            }],
            workgroup: [8, 8, 1]
        },
        "render/occ_field.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `l0s`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `occ_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 3,
                name: `bg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 4,
                name: `bg_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 2,
                name: `side_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/rc_avg.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `upper`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `upper_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/rc_cascade.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `scene`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `scene_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 5,
                name: `gloss_a`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `gloss_a_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 4,
                name: `ext_scene`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 4,
                name: `ext_scene_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `upper_avg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 6,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 2,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 3,
                name: `rp`,
                kind: `uniform`
            }],
            workgroup: [128, 1, 1]
        },
        "render/rc_mips.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 2,
                name: `ext_src`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 0,
                name: `src`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `dst`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 3,
                name: `ext_dst`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/rc_resolve.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `c0_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 4,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 1,
                name: `prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 5,
                name: `cha_prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 6,
                name: `chb_prev`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `fluence_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 7,
                name: `cha_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 8,
                name: `chb_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 3,
                name: `dir_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/subsurface.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 3,
                name: `emissive_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `albedo_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 7,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 0,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 6,
                name: `prev_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 5,
                name: `fluence_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `fluence_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 4,
                name: `gaux_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }],
            workgroup: [8, 8, 1]
        },
        "render/tonemap.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `hdr`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `bloom_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 1,
                name: `bloom_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 4,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 2,
                name: `ex`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 3,
                name: `lut`,
                kind: `texture`,
                dim: `3d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `lut_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 6,
                name: `cost_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 5,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba8unorm`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "render/view3d.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 11,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 27,
                name: `cell_shade`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 0,
                name: `l0s`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 14,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 13,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 3,
                name: `fl0_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `fl0_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 4,
                name: `fl1_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 4,
                name: `fl1_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 5,
                name: `fl2_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `fl2_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 6,
                name: `fl3_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 6,
                name: `fl3_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 7,
                name: `fl4_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 7,
                name: `fl4_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 8,
                name: `ldir_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 8,
                name: `ldir_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 24,
                name: `cha_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 24,
                name: `cha_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 25,
                name: `chb_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 25,
                name: `chb_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 16,
                name: `occ_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 16,
                name: `occ_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 15,
                name: `gaux_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `bg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 20,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 20,
                name: `day_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `l0t`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 26,
                name: `emissive_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 18,
                name: `bgsm_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 18,
                name: `bgsm_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 9,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 9,
                name: `medium_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 17,
                name: `side_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 17,
                name: `side_tex_smp`,
                kind: `sampler`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 10,
                name: `godray_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 10,
                name: `godray_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 23,
                name: `fog_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 23,
                name: `fog_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 19,
                name: `beam_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 19,
                name: `beam_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 12,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 21,
                name: `cost_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 22,
                name: `unnamed_1`,
                kind: `storage`
            }],
            workgroup: [64, 1, 1]
        },
        "render/view_cells.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 11,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 3,
                name: `fl0_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 3,
                name: `fl0_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 4,
                name: `fl1_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 4,
                name: `fl1_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 5,
                name: `fl2_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `fl2_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 6,
                name: `fl3_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 6,
                name: `fl3_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 7,
                name: `fl4_`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 7,
                name: `fl4_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 8,
                name: `ldir_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 8,
                name: `ldir_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 24,
                name: `cha_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 24,
                name: `cha_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 25,
                name: `chb_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 25,
                name: `chb_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 16,
                name: `occ_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 16,
                name: `occ_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 13,
                name: `cells`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 14,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 15,
                name: `gaux_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 2,
                name: `bg`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 20,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 20,
                name: `day_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 0,
                name: `l0s`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 1,
                name: `l0t`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 0,
                binding: 26,
                name: `emissive_img`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 27,
                name: `cell_shade`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 9,
                name: `medium_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 9,
                name: `medium_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 10,
                name: `godray_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 10,
                name: `godray_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 12,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 17,
                name: `side_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 17,
                name: `side_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 18,
                name: `bgsm_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 18,
                name: `bgsm_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 19,
                name: `beam_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 19,
                name: `beam_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 21,
                name: `cost_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }, {
                group: 0,
                binding: 23,
                name: `fog_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 23,
                name: `fog_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 22,
                name: `unnamed_1`,
                kind: `storage`
            }],
            workgroup: [8, 8, 1]
        },
        "render/window_shafts.comp": {
            readWrite: [],
            bindings: [{
                group: 0,
                binding: 2,
                name: `rp`,
                kind: `uniform`
            }, {
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `bgsm_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 0,
                name: `bgsm_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 1,
                name: `out_img`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba16float`,
                access: `write-only`
            }],
            workgroup: [8, 8, 1]
        },
        "sim/apply_commands.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `stats`,
                kind: `storage`
            }, {
                group: 0,
                binding: 5,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed_2`,
                kind: `read-only-storage`
            }],
            workgroup: [8, 8, 1]
        },
        "sim/explosion.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed_2`,
                kind: `read-only-storage`
            }],
            workgroup: [8, 8, 1]
        },
        "sim/explosion_gather.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `unnamed`,
                kind: `storage`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 1,
                name: `unnamed_2`,
                kind: `storage`
            }],
            workgroup: [256, 1, 1]
        },
        "sim/heat.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `read-only-storage`
            }],
            workgroup: [8, 8, 1]
        },
        "sim/liquid_spread.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }],
            workgroup: [64, 1, 1]
        },
        "sim/margolus_move.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed_1`,
                kind: `read-only-storage`
            }],
            workgroup: [8, 8, 1]
        },
        "sim/reactions.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 5,
                name: `stats`,
                kind: `storage`
            }, {
                group: 0,
                binding: 7,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 6,
                name: `unnamed_2`,
                kind: `storage`
            }, {
                group: 0,
                binding: 3,
                name: `unnamed_3`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed_4`,
                kind: `read-only-storage`
            }],
            workgroup: [8, 8, 1]
        },
        "sim/unary.comp": {
            readWrite: [],
            bindings: [{
                group: 1,
                binding: 0,
                name: `pc`,
                kind: `uniform`
            }, {
                group: 0,
                binding: 0,
                name: `cells_in`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `uint`
            }, {
                group: 0,
                binding: 1,
                name: `cells_out`,
                kind: `storage-texture`,
                dim: `2d`,
                format: `rgba32uint`,
                access: `write-only`
            }, {
                group: 0,
                binding: 2,
                name: `unnamed`,
                kind: `read-only-storage`
            }, {
                group: 0,
                binding: 3,
                name: `stats`,
                kind: `storage`
            }, {
                group: 0,
                binding: 7,
                name: `unnamed_1`,
                kind: `storage`
            }, {
                group: 0,
                binding: 4,
                name: `unnamed_2`,
                kind: `storage`
            }, {
                group: 0,
                binding: 5,
                name: `light_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 5,
                name: `light_tex_smp`,
                kind: `sampler`
            }, {
                group: 0,
                binding: 6,
                name: `day_tex`,
                kind: `texture`,
                dim: `2d`,
                sampleType: `float`
            }, {
                group: 2,
                binding: 6,
                name: `day_tex_smp`,
                kind: `sampler`
            }],
            workgroup: [8, 8, 1]
        }
    };

var Fe = 1,
    Ie = e => e.__id ??= Fe++,
    S = class e {
        i = new Int32Array(8);
        f = new Float32Array(8);
        constructor(e) {
            if (e)
                for (let [t, n] of Object.entries(e)) this.set(t, n)
        }
        set(e, t) {
            let n = (e[1] === `0` ? 0 : 4) + `xyzw`.indexOf(e[2]);
            return e[0] === `i` ? this.i[n] = t | 0 : this.f[n] = t, this
        }
        clone() {
            let t = new e;
            return t.i.set(this.i), t.f.set(this.f), t
        }
    },
    C = class {
        e = new Map;
        image(e, t) {
            return this.e.set(e, {
                kind: `image`,
                tex: t
            }), this
        }
        buffer(e, t) {
            return this.e.set(e, {
                kind: `buffer`,
                buf: t
            }), this
        }
        ubo(e, t) {
            return this.e.set(e, {
                kind: `ubo`,
                buf: t
            }), this
        }
        sampler(e, t, n) {
            return this.e.set(e, {
                kind: `sampler`,
                smp: t,
                tex: n
            }), this
        }
    },
// 双缓冲容器：read 是当前值，write 是下一次计算目标；swap 只交换引用。
    w = class {
        read;
        write;
        constructor(e, t) {
            this.read = e, this.write = t
        }
        swap() {
            let e = this.read;
            this.read = this.write, this.write = e
        }
    };

var T = {
        Flammable: 1,
        Explosive: 2,
        Extinguisher: 4,
        Decays: 8,
        EmitSteam: 16,
        EmitSmoke: 32,
        AlwaysBurn: 64,
        Charges: 128,
        Rigid: 256
    };

var E = function(e) {
        return e[e.Paint = 1] = `Paint`, e[e.Erase = 2] = `Erase`, e[e.Heat = 3] = `Heat`, e[e.Cool = 4] = `Cool`, e[e.Ignite = 5] = `Ignite`, e[e.Explode = 6] = `Explode`, e[e.Clear = 7] = `Clear`, e
    }({}),
    Ye = function(e) {
        return e[e.Circle = 0] = `Circle`, e[e.Square = 1] = `Square`, e
    }({}),
    Xe = class e {
        static Max = 64;
        static Stride = 64;
        static SizeBytes = 16 + e.Max * e.Stride;
        pending = [];
        seed = 1;
        add(t) {
            this.pending.length < e.Max && this.pending.push(t)
        }
        get count() {
            return this.pending.length
        }
        take() {
            return this.pending.splice(0)
        }
        drain(t) {
            new Uint8Array(t).fill(0);
            let n = new DataView(t),
                r = this.pending.length;
            n.setUint32(0, r, !0);
            for (let t = 0; t < r; t++) {
                let r = this.pending[t],
                    i = 16 + t * e.Stride;
                if (n.setInt32(i, r.type, !0), n.setInt32(i + 4, r.material ?? 0, !0), n.setInt32(i + 8, r.shape ?? 0, !0), n.setInt32(i + 12, +!!r.overwrite, !0), n.setFloat32(i + 16, r.from[0], !0), n.setFloat32(i + 20, r.from[1], !0), n.setFloat32(i + 24, r.to[0], !0), n.setFloat32(i + 28, r.to[1], !0), n.setFloat32(i + 32, r.radius, !0), n.setFloat32(i + 36, r.strength ?? 0, !0), n.setFloat32(i + 40, !r.spray || r.spray <= 0 ? 1 : r.spray, !0), n.setUint32(i + 44, this.seed++ >>> 0, !0), r.clip)
                    for (let e = 0; e < 4; e++) n.setFloat32(i + 48 + 4 * e, r.clip[e], !0)
            }
            return this.pending.length = 0, r
        }
    },
    Ze = function(e) {
        return e[e.Burning = 0] = `Burning`, e[e.Boil = 1] = `Boil`, e[e.Explosion = 2] = `Explosion`, e[e.Sizzle = 3] = `Sizzle`, e[e.Reaction = 4] = `Reaction`, e[e.Melt = 5] = `Melt`, e[e.Freeze = 6] = `Freeze`, e[e.Ignite = 7] = `Ignite`, e
    }({}),
// 统计布局：GPU statsBuf 对应的偏移、计数数组与爆炸列表解码。
    D = class e {
        static HistOffset = 0;
        static ReactionOffset = 1024;
        static IgniteOffset = 5120;
        static PhaseHiOffset = 6144;
        static PhaseLoOffset = 7168;
        static EventsOffset = 8192;
        static ExCountOffset = 8256;
        static ExplosionsOffset = 8272;
        static MaxExplosions = 64;
        static SizeBytes = e.ExplosionsOffset + e.MaxExplosions * 16;
        static PendingSize = 16 + e.MaxExplosions * 16;
        histogram = new Uint32Array(256);
        reactionCount = new Uint32Array(1024);
        igniteCount = new Uint32Array(256);
        phaseHi = new Uint32Array(256);
        phaseLo = new Uint32Array(256);
        events = new Uint32Array(16);
        explosions = [];
        parse(t) {
            if (t.byteLength < e.SizeBytes) return;
            this.histogram = new Uint32Array(t.slice(e.HistOffset, e.HistOffset + 1024)), this.reactionCount = new Uint32Array(t.slice(e.ReactionOffset, e.ReactionOffset + 4096)), this.igniteCount = new Uint32Array(t.slice(e.IgniteOffset, e.IgniteOffset + 1024)), this.phaseHi = new Uint32Array(t.slice(e.PhaseHiOffset, e.PhaseHiOffset + 1024)), this.phaseLo = new Uint32Array(t.slice(e.PhaseLoOffset, e.PhaseLoOffset + 1024)), this.events = new Uint32Array(t.slice(e.EventsOffset, e.EventsOffset + 64));
            let n = new DataView(t),
                r = Math.min(n.getUint32(e.ExCountOffset, !0), e.MaxExplosions);
            this.explosions = [];
            for (let t = 0; t < r; t++) {
                let r = e.ExplosionsOffset + t * 16;
                this.explosions.push([n.getFloat32(r, !0), n.getFloat32(r + 4, !0), n.getFloat32(r + 8, !0), n.getFloat32(r + 12, !0)])
            }
        }
    },
    Qe = class {
        substeps = 8;
        liquidSpread = 8;
        heatIterations = 2;
        pressureIterations = 20;
        windCoupling = .6;
        gasRelax = .01;
        ambient = 293;
        buoyancy = 6e-6;
        blastImpulse = 1.2;
        damping = .985;
        fluidDt = 1;
        sootKeep = .992;
        steamKeep = .985;
        mediumSource = .25;
        mediumRise = .25;
        flameKeep = .8;
        flameRise = .6
    },
    $e = [
        [0, 0],
        [1, 1],
        [1, 0],
        [0, 1]
    ],
// 模拟网格 SimulationGrid：GPU 状态、固定步进、材料反应、温度和流体调度。
    et = class {
        gpu;
        width;
        height;
        settings = new Qe;
        tick = 0;
        fireId;
        steamId;
        cells;
        fluidVel;
        fluidState;
        pressure;
        medium;
        divergence;
        materialsBuf;
        lutBuf;
        reactionsBuf;
        commandsBuf;
        statsBuf;
        pendingBuf;
        mediumSrcBuf;
        lightTex = null;
        daylightTex = null;
        blackTex;
        mediumSrcBytes;
        cmdBytes = new ArrayBuffer(Xe.SizeBytes);
        apply;
        gather;
        exGrid;
        exCounts;
        lightInput = !0;
        debugStop = 99;
        onTick = null;
        onApply = null;
        onHash = null;
        hashEvery = 60;
        hashPass;
        hashBuf;
        explosion;
        move;
        spread;
        react;
        unary;
        heat;
        fInject;
        fAdvect;
        fDiv;
        fPressure;
        fPressureSolve;
        fProject;
        mediumPass;
        get fluidW() {
            return this.width / 4
        }
        get fluidH() {
            return this.height / 4
        }
        get mediumW() {
            return this.width / 2
        }
        get mediumH() {
            return this.height / 2
        }
        constructor(e, t, n, r) {
            if (this.gpu = e, this.width = t, this.height = n, t % 32 != 0 || n % 32 != 0) throw Error(`World size must be a multiple of 32`);
            let i = (t, n, r, i) => e.createTexture(t, n, r, i);
            this.cells = new w(i(t, n, `rgba32uint`, `cells_a`), i(t, n, `rgba32uint`, `cells_b`)), this.fluidVel = new w(i(this.fluidW, this.fluidH, `rgba16float`, `vel_a`), i(this.fluidW, this.fluidH, `rgba16float`, `vel_b`)), this.fluidState = [0, 1].map(t => e.createStorageBuffer(this.fluidW * this.fluidH * 16, null, `fluid_state_${t}`)), this.pressure = new w(i(this.fluidW, this.fluidH, `r32float`, `p_a`), i(this.fluidW, this.fluidH, `r32float`, `p_b`)), this.divergence = i(this.fluidW, this.fluidH, `r32float`, `div`), this.medium = new w(i(this.mediumW, this.mediumH, `rgba16float`, `medium_a`), i(this.mediumW, this.mediumH, `rgba16float`, `medium_b`)), this.commandsBuf = e.createStorageBuffer(Xe.SizeBytes, null, `commands`), this.statsBuf = e.createStorageBuffer(D.SizeBytes, null, `stats`), this.pendingBuf = e.createStorageBuffer(D.PendingSize, null, `pending`), this.exGrid = e.createStorageBuffer(t * n * 4, null, `explosion_grid`), this.exCounts = e.createStorageBuffer(Math.ceil(t * n / 1024) * 4, null, `explosion_counts`), this.mediumSrcBytes = this.mediumW * this.mediumH * 4 * 4, this.mediumSrcBuf = e.createStorageBuffer(this.mediumSrcBytes, null, `medium_src`), this.blackTex = i(4, 4, `rgba16float`, `black`), e.clearTexture(this.blackTex), this.fireId = r.info.fireId, this.steamId = r.info.steamId, this.materialsBuf = e.createStorageBuffer(r.materials.byteLength, r.materials, `materials`), this.lutBuf = e.createStorageBuffer(r.lut.byteLength, r.lut, `reaction_lut`), this.reactionsBuf = e.createStorageBuffer(r.reactions.byteLength, r.reactions, `reactions`);
            let a = t => new Ve(e, t);
            this.apply = a(`sim/apply_commands.comp`), this.gather = a(`sim/explosion_gather.comp`), this.explosion = a(`sim/explosion.comp`), this.move = a(`sim/margolus_move.comp`), this.spread = a(`sim/liquid_spread.comp`), this.react = a(`sim/reactions.comp`), this.unary = a(`sim/unary.comp`), this.heat = a(`sim/heat.comp`), this.fInject = a(`fluid/fluid_inject.comp`), this.fAdvect = a(`fluid/advect.comp`), this.fDiv = a(`fluid/divergence.comp`), this.fPressure = a(`fluid/pressure.comp`), e.limits, this.fPressureSolve = null, this.fProject = a(`fluid/project.comp`), this.mediumPass = a(`fluid/medium.comp`), this.hashPass = a(`net/state_hash.comp`), this.hashBuf = e.createStorageBuffer((n + this.fluidH) * 4, null, `state_hash`)
        }
        encodeHash() {
            let e = (this.height + this.fluidH) * 4;
            this.hashPass.dispatch(new C().image(0, this.cells.read).buffer(1, this.materialsBuf).buffer(2, this.fluidState[0]).image(3, this.pressure.read).buffer(4, this.hashBuf), new S({
                i0x: this.width,
                i0y: this.height,
                i0z: this.fluidW,
                i0w: this.fluidH
            }), this.height + this.fluidH, 1);
            let t = this.gpu.device.createBuffer({
                size: e,
                usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST,
                label: `state_hash_read`
            });
            return this.gpu.enc().copyBufferToBuffer(this.hashBuf, 0, t, 0, e), t
        }
        upload(e) {
            if (e.byteLength !== this.width * this.height * 16) throw Error(`bad world size`);
            let t = this.gpu;
            t.writeTexture(this.cells.read, e, 16), t.clearTexture(this.medium.read), t.clearTexture(this.fluidVel.read), t.clearBuffer(this.fluidState[0], 0, this.fluidW * this.fluidH * 16), t.clearBuffer(this.exGrid, 0, this.width * this.height * 4), t.clearTexture(this.pressure.read), t.device.queue.writeBuffer(this.pendingBuf, 0, new Uint8Array(D.PendingSize)), t.device.queue.writeBuffer(this.statsBuf, D.EventsOffset, new Uint8Array(D.SizeBytes - D.EventsOffset)), this.tick = 0
        }
        P(e = 0, t = 0) {
            return new S({
                i0x: this.width,
                i0y: this.height,
                i0z: e,
                i0w: t
            })
        }
        step(e) {
            let t = null;
            if (e && e.count > 0) {
                let n = e.drain(this.cmdBytes);
                t = new Uint8Array(this.cmdBytes, 0, 16 + n * Xe.Stride)
            }
            this.onTick?.(t), this.stepBytes(t)
        }
        // 一轮模拟：爆炸收集 → 命令 → 爆炸 → 移动 → 铺展 → 反应 → 单材料规则 → 热 → 流体。
        stepBytes(e) {
            let t = this.gpu,
                n = this.settings,
                r = this.tick & 2147483647,
                i = e ? new DataView(e.buffer, e.byteOffset).getUint32(0, !0) : 0;
            i > 0 && this.writeCommands(e);
            let a = new C().buffer(0, this.exGrid).buffer(1, this.pendingBuf).buffer(2, this.exCounts),
                o = Math.ceil(this.width * this.height / 4);
            if (this.gather.dispatch(a, new S({
                    i0x: this.width,
                    i0y: this.height,
                    i0z: 0
                }), o, 1), this.gather.dispatch(a, new S({
                    i0x: this.width,
                    i0y: this.height,
                    i0z: 1
                }), o, 1), t.clearBuffer(this.statsBuf, D.HistOffset, 1024), t.clearBuffer(this.statsBuf, D.EventsOffset, D.SizeBytes - D.EventsOffset), t.clearBuffer(this.mediumSrcBuf, 0, this.mediumSrcBytes), this.debugStop < 1) {
                this.tick++;
                return
            }
            if (i > 0) {
                let e = this.P(r).set(`i1x`, i);
                this.apply.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf).buffer(3, this.commandsBuf).buffer(4, this.statsBuf).buffer(5, this.exGrid), e, this.width, this.height), this.cells.swap()
            }
            if (this.debugStop < 2) {
                this.tick++;
                return
            }
            if (this.explosion.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf).buffer(3, this.pendingBuf).buffer(4, this.mediumSrcBuf), this.P(r).set(`i1y`, this.fireId), this.width, this.height), this.cells.swap(), this.debugStop < 3) {
                this.tick++;
                return
            }
            let s = this.width / 2 + 1,
                c = this.height / 2 + 1;
            for (let e = 0; e < n.substeps; e++) {
                let t = $e[e + r & 3],
                    i = this.P(r, e).set(`i1x`, t[0]).set(`i1y`, t[1]).set(`f0x`, n.windCoupling);
                this.move.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf).buffer(3, this.fluidState[0]), i, s, c), this.cells.swap()
            }
            if (this.debugStop < 4) {
                this.tick++;
                return
            }
            if (n.liquidSpread > 0) {
                let e = (Math.floor(this.width / 64) + 1) * this.height * 64;
                for (let t = 0; t < 2; t++) {
                    let i = this.P(r).set(`i1x`, r + t & 1 ? -1 : 1).set(`i1y`, t === 0 ? 0 : 32).set(`i1z`, n.liquidSpread);
                    this.spread.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf), i, e, 1), this.cells.swap()
                }
            }
            if (this.debugStop < 5) {
                this.tick++;
                return
            }
            for (let e = 0; e < 2; e++) {
                let t = $e[e * 2 + r & 3],
                    n = this.P(r).set(`i1x`, t[0]).set(`i1y`, t[1]).set(`i1z`, this.fireId).set(`i1w`, this.steamId);
                this.react.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf).buffer(3, this.lutBuf).buffer(4, this.reactionsBuf).buffer(5, this.statsBuf).buffer(6, this.mediumSrcBuf).buffer(7, this.exGrid), n, s, c), this.cells.swap()
            }
            if (this.debugStop < 6) {
                this.tick++;
                return
            }
            if (this.unary.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf).buffer(3, this.statsBuf).buffer(4, this.mediumSrcBuf).buffer(7, this.exGrid).sampler(5, t.linearClamp, this.lightInput && this.lightTex || this.blackTex).sampler(6, t.linearClamp, this.lightInput && this.daylightTex || this.blackTex), this.P(r), this.width, this.height), this.cells.swap(), this.debugStop < 7) {
                this.tick++;
                return
            }
            for (let e = 0; e < n.heatIterations; e++) {
                let e = this.P(r).set(`f0x`, n.gasRelax).set(`f0y`, n.ambient);
                this.heat.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf), e, this.width, this.height), this.cells.swap()
            }
            if (this.debugStop < 8) {
                this.tick++;
                return
            }
            this.stepFluid(), this.tick++, this.onHash && this.tick % this.hashEvery === 0 && this.onHash(this.tick, this.encodeHash())
        }
        applyCommandsOnly(e) {
            let t = e.drain(this.cmdBytes);
            if (t === 0) return;
            let n = new Uint8Array(this.cmdBytes, 0, 16 + t * Xe.Stride);
            this.onApply?.(n), this.applyBytes(n)
        }
        cmdSubmit = -1;
        writeCommands(e) {
            let t = this.gpu;
            this.cmdSubmit === t.submits && (t.submit(), t.begin()), t.device.queue.writeBuffer(this.commandsBuf, 0, e), this.cmdSubmit = t.submits
        }
        applyBytes(e) {
            let t = new DataView(e.buffer, e.byteOffset).getUint32(0, !0);
            if (t === 0) return;
            this.writeCommands(e);
            let n = this.P(this.tick & 2147483647).set(`i1x`, t);
            this.apply.dispatch(new C().image(0, this.cells.read).image(1, this.cells.write).buffer(2, this.materialsBuf).buffer(3, this.commandsBuf).buffer(4, this.statsBuf).buffer(5, this.exGrid), n, this.width, this.height), this.cells.swap()
        }
        // 流体求解：注入 → 平流 → 散度 → 压力迭代 → 投影 → 烟雾介质。
        stepFluid() {
            let e = this.gpu,
                t = this.settings,
                n = this.fluidW,
                r = this.fluidH,
                [i, a] = this.fluidState,
                o = new S({
                    i0x: n,
                    i0y: r,
                    i1x: this.width,
                    i1y: this.height,
                    f0x: t.buoyancy,
                    f0y: t.blastImpulse,
                    f0z: t.damping,
                    f0w: t.ambient
                });
            this.fInject.dispatch(new C().image(0, this.cells.read).buffer(1, this.materialsBuf).buffer(2, i).buffer(4, this.pendingBuf), o, n, r), o = new S({
                i0x: n,
                i0y: r,
                f0x: t.fluidDt
            }), this.fAdvect.dispatch(new C().buffer(0, i).buffer(1, a), o, n, r), o = new S({
                i0x: n,
                i0y: r
            }), this.fDiv.dispatch(new C().buffer(0, a).image(1, this.divergence), o, n, r);
            for (let e = 0; e < t.pressureIterations; e++) this.fPressure.dispatch(new C().image(0, this.pressure.read).image(1, this.pressure.write).image(2, this.divergence).buffer(3, a), o, n, r), this.pressure.swap();
            this.fProject.dispatch(new C().buffer(0, a).buffer(1, i).image(2, this.pressure.read).image(3, this.fluidVel.write), o, n, r), this.fluidVel.swap(), o = new S({
                i0x: this.mediumW,
                i0y: this.mediumH,
                i1x: this.width,
                i1y: this.height,
                i1z: this.tick & 65535,
                f0x: t.sootKeep,
                f0y: t.steamKeep,
                f0z: t.fluidDt,
                f0w: t.mediumSource,
                f1x: t.mediumRise,
                f1y: t.flameKeep,
                f1z: t.flameRise
            }), this.mediumPass.dispatch(new C().sampler(0, e.linearClamp, this.medium.read).image(1, this.medium.write).sampler(2, e.linearClamp, this.fluidVel.read).buffer(3, this.mediumSrcBuf).image(4, this.cells.read).buffer(5, this.materialsBuf), o, this.mediumW, this.mediumH), this.medium.swap()
        }
        readStats() {
            return this.gpu.readBuffer(this.statsBuf, D.SizeBytes)
        }
    },
    tt = 4294967295,
    nt = 64,
    rt = 1 << 18,
    it = 1024,
    at = (e, t) => e[0] * t[0] + e[1] * t[1],
    ot = (e, t) => [-e * t[1], e * t[0]],
    O = (e, t) => e[0] * t[1] - e[1] * t[0],
    st = (e, t, n) => Math.min(Math.max(e, t), n),
    ct = class {
        s;
        constructor(e) {
            this.s = e >>> 0 || 1
        }
        next() {
            return this.s ^= this.s << 13, this.s >>>= 0, this.s ^= this.s >>> 17, this.s ^= this.s << 5, this.s >>>= 0, this.s / 4294967296
        }
        int(e) {
            return Math.floor(this.next() * e)
        }
    },
// 单个刚体：位置/速度/角度、质量、局部格子掩码与边界。
    lt = class {
        slot = 0;
        atlas = 0;
        rw = 0;
        rh = 0;
        mask;
        dens;
        count = 0;
        com = [0, 0];
        mass = 0;
        inertia = 0;
        invMass = 0;
        invInertia = 0;
        pos = [0, 0];
        vel = [0, 0];
        angle = 0;
        angVel = 0;
        asleep = !1;
        stillFrames = 0;
        sleepCheck = 0;
        created = -1;
        edge = [];
        all = [];
        rot(e) {
            let t = Math.cos(this.angle),
                n = Math.sin(this.angle);
            return [t * e[0] - n * e[1], n * e[0] + t * e[1]]
        }
        recompute() {
            this.count = 0;
            let e = 0,
                t = 0,
                n = 0,
                {
                    rw: r,
                    rh: i,
                    mask: a,
                    dens: o
                } = this;
            for (let s = 0; s < i; s++)
                for (let i = 0; i < r; i++) {
                    let c = s * r + i;
                    a[c] && (this.count++, e += (i + .5) * o[c], t += (s + .5) * o[c], n += o[c])
                }
            if (this.count === 0) return;
            let s = this.com;
            this.com = [e / n, t / n], this.mass = n;
            let c = 0,
                l = [],
                u = [];
            for (let e = 0; e < i; e++)
                for (let t = 0; t < r; t++) {
                    let n = e * r + t;
                    if (!a[n]) continue;
                    let s = [t + .5 - this.com[0], e + .5 - this.com[1]];
                    c += o[n] * (s[0] * s[0] + s[1] * s[1] + 1 / 6), l.push(s), (t === 0 || e === 0 || t === r - 1 || e === i - 1 || !a[n - 1] || !a[n + 1] || !a[n - r] || !a[n + r]) && u.push(s)
                }
            if (this.inertia = c, this.invMass = 1 / this.mass, this.invInertia = 1 / Math.max(this.inertia, .001), this.all = l, this.edge = u, this.created >= 0 && (s[0] !== 0 || s[1] !== 0)) {
                let e = this.rot([this.com[0] - s[0], this.com[1] - s[1]]);
                this.pos = [this.pos[0] + e[0], this.pos[1] + e[1]]
            }
        }
    },
    ut = class {
        frame = 0;
        atlasUsed = 0;
        bodies = new Float32Array;
        count = 0;
        newRegions = [];
        ownerUpdates = [];
        claims = [];
        reset = !1;
        step = !0
    },
// CPU 刚体世界 RigidBodyWorld：碰撞、分裂、占用读回和 GPU 交换包。
    dt = class e {
        w;
        h;
        mats;
        bodies = [];
        gravity = 320;
        restitution = .15;
        friction = .6;
        substeps = 4;
        nextSlot = 1;
        atlasUsed = 0;
        frame = 0;
        resetPending = !0;
        newRegions = [];
        ownerUpdates = [];
        claims = [];
        occ;
        bodyAt;
        bodyCells = [];
        haveOcc = !1;
        occIn = null;
        ownersIn = null;
        ownersFrame = 0;
        cellsIn = null;
        rng = new ct(7);
        contacts = [];
        wetRows = new Set;
        constructor(e, t, n) {
            this.w = e, this.h = t, this.mats = n, this.occ = new Uint8Array(e * t), this.bodyAt = new Int32Array(e * t)
        }
        get used() {
            return this.atlasUsed
        }
        clear() {
            this.bodies.length = 0, this.nextSlot = 1, this.atlasUsed = 0, this.resetPending = !0, this.newRegions = [], this.ownerUpdates = [], this.claims = [], this.haveOcc = !1, this.bodyAt.fill(0), this.bodyCells = [], this.occIn = this.ownersIn = this.cellsIn = null
        }
        onOccupancy(e) {
            this.occIn = e
        }
        onOwners(e, t) {
            this.ownersIn = e, this.ownersFrame = t
        }
        onCells(e) {
            this.cellsIn = e
        }
        densityOf(e) {
            return Math.max((this.mats[e]?.density ?? 1e3) / 1e3, .05)
        }
        allocate(e) {
            if (this.atlasUsed + e > 262144) return -1;
            let t = this.atlasUsed;
            return this.atlasUsed += e, t
        }
        createFromImage(e, t, n, r, i = 0, a = [0, 0], o = 0) {
            let s = new Uint8Array(e * t * 16),
                c = new Uint8Array(e * t * 4),
                l = new DataView(c.buffer),
                u = new DataView(s.buffer),
                d = this.allocate(e * t);
            if (d < 0) return null;
            let f = new lt;
            f.slot = this.nextSlot++, f.atlas = d, f.rw = e, f.rh = t, f.mask = new Uint8Array(e * t), f.dens = new Float32Array(e * t);
            for (let r = 0; r < e * t; r++) {
                let e = tt,
                    t = n[r];
                if (t > 0) {
                    f.mask[r] = 1, f.dens[r] = this.densityOf(t);
                    let n = this.mats[t];
                    u.setUint32(r * 16, t & 255 | (this.rng.int(256) & 255) << 8, !0), u.setFloat32(r * 16 + 4, n.defaultTemp > 0 ? n.defaultTemp : 293, !0), u.setUint32(r * 16 + 8, Math.max(n.lifeInit, 0) & 65535, !0), e = f.slot
                }
                l.setUint32(r * 4, e >>> 0, !0)
            }
            f.recompute(), f.created = this.frame, f.angle = i;
            let p = f.rot(f.com);
            return f.pos = [r[0] + p[0], r[1] + p[1]], f.vel = a, f.angVel = o, this.bodies.push(f), this.newRegions.push({
                offset: d,
                cells: s,
                owners: c
            }), f
        }
        bodify(e) {
            let t = this.w,
                n = this.h,
                r = new Uint32Array(e),
                i = new Set;
            for (let e of this.bodies)
                for (let t = 0; t < e.mask.length; t++) e.mask[t] && i.add(e.atlas + t);
            let a = new Uint8Array(t * n),
                o = new Int32Array(t * n);
            for (let e = 0; e < t * n; e++) {
                let t = r[e * 4],
                    n = t & 255;
                if (n === 0 || !(this.mats[n].flags & T.Rigid)) continue;
                let s = t >>> 16,
                    c = r[e * 4 + 3];
                (s & nt) !== 0 && i.has(c >>> 8) || (a[e] = 1, o[e] = n)
            }
            let s = new Uint8Array(t * n),
                c = [];
            for (let r = 0; r < t * n; r++) {
                if (!a[r] || s[r]) continue;
                let i = [];
                s[r] = 1, c.push(r);
                let l = t,
                    u = n,
                    d = 0,
                    f = 0;
                for (; c.length;) {
                    let e = c.pop();
                    i.push(e);
                    let r = e % t,
                        o = e / t | 0;
                    l = Math.min(l, r), u = Math.min(u, o), d = Math.max(d, r), f = Math.max(f, o), r > 0 && a[e - 1] && !s[e - 1] && (s[e - 1] = 1, c.push(e - 1)), r < t - 1 && a[e + 1] && !s[e + 1] && (s[e + 1] = 1, c.push(e + 1)), o > 0 && a[e - t] && !s[e - t] && (s[e - t] = 1, c.push(e - t)), o < n - 1 && a[e + t] && !s[e + t] && (s[e + t] = 1, c.push(e + t))
                }
                let p = d - l + 1,
                    m = f - u + 1,
                    h = this.allocate(p * m);
                if (h < 0) return;
                let g = new lt;
                g.slot = this.nextSlot++, g.atlas = h, g.rw = p, g.rh = m, g.mask = new Uint8Array(p * m), g.dens = new Float32Array(p * m);
                let _ = new Uint8Array(p * m * 16),
                    v = new Uint8Array(p * m * 4).fill(255),
                    y = new DataView(v.buffer),
                    b = new Uint8Array(e);
                for (let e of i) {
                    let n = e % t - l,
                        r = ((e / t | 0) - u) * p + n;
                    g.mask[r] = 1, g.dens[r] = this.densityOf(o[e]), _.set(b.subarray(e * 16, e * 16 + 16), r * 16), y.setUint32(r * 4, g.slot, !0), this.claims.push((e % t | (e / t | 0) << 16) >>> 0, h + r, g.slot, o[e])
                }
                g.recompute(), g.created = this.frame, g.pos = [l + g.com[0], u + g.com[1]], this.bodies.push(g), this.newRegions.push({
                    offset: h,
                    cells: _,
                    owners: v
                })
            }
        }
        applyOwners(t, n) {
            let r = new Uint32Array(t),
                i = r.length,
                a = [];
            for (let t = this.bodies.length - 1; t >= 0; t--) {
                let o = this.bodies[t];
                if (o.created > n - 3) continue;
                let s = 0;
                for (let e = 0; e < o.mask.length; e++) {
                    if (!o.mask[e]) continue;
                    let t = o.atlas + e;
                    t >= i || r[t] === 4294967295 && (o.mask[e] = 0, s++)
                }
                if (s === 0) continue;
                o.asleep = !1, o.stillFrames = 0;
                let c = e.components(o);
                if (c.length === 0) {
                    this.bodies.splice(t, 1);
                    continue
                }
                c.sort((e, t) => t.length - e.length);
                let l = o.com;
                for (let e = 1; e < c.length; e++) {
                    let t = new lt;
                    t.slot = this.nextSlot++, t.atlas = o.atlas, t.rw = o.rw, t.rh = o.rh, t.mask = new Uint8Array(o.mask.length), t.dens = o.dens, t.angle = o.angle, t.angVel = o.angVel;
                    for (let n of c[e]) t.mask[n] = 1, o.mask[n] = 0, this.ownerUpdates.push(o.atlas + n, t.slot);
                    t.recompute(), t.created = this.frame;
                    let n = o.rot([t.com[0] - l[0], t.com[1] - l[1]]);
                    t.pos = [o.pos[0] + n[0], o.pos[1] + n[1]], t.vel = [o.vel[0] - o.angVel * n[1], o.vel[1] + o.angVel * n[0]], a.push(t)
                }
                o.recompute()
            }
            this.bodies.push(...a)
        }
        static components(e) {
            let t = [],
                n = new Uint8Array(e.mask.length),
                r = [];
            for (let i = 0; i < e.mask.length; i++) {
                if (!e.mask[i] || n[i]) continue;
                let a = [];
                for (n[i] = 1, r.push(i); r.length;) {
                    let t = r.pop();
                    a.push(t);
                    let i = t % e.rw,
                        o = t / e.rw | 0,
                        s = t => {
                            e.mask[t] && !n[t] && (n[t] = 1, r.push(t))
                        };
                    i > 0 && s(t - 1), i < e.rw - 1 && s(t + 1), o > 0 && s(t - e.rw), o < e.rh - 1 && s(t + e.rw)
                }
                t.push(a)
            }
            return t
        }
        blocked(e, t, n) {
            if (e < 0 || t < 0 || e >= this.w || t >= this.h) return !0;
            let r = t * this.w + e;
            if (this.occ[r] & 1) return !0;
            let i = this.bodyAt[r];
            return i !== 0 && i !== n
        }
        rasterizeBodies() {
            for (let e of this.bodyCells) this.bodyAt[e] = 0;
            this.bodyCells = [];
            for (let e of this.bodies) {
                let t = Math.cos(e.angle),
                    n = Math.sin(e.angle);
                for (let r of e.all) {
                    let i = Math.floor(e.pos[0] + t * r[0] - n * r[1]),
                        a = Math.floor(e.pos[1] + n * r[0] + t * r[1]);
                    if (i < 0 || a < 0 || i >= this.w || a >= this.h) continue;
                    let o = a * this.w + i;
                    this.bodyAt[o] === 0 && this.bodyCells.push(o), this.bodyAt[o] = e.slot
                }
            }
        }
        bySlot(e) {
            return this.bodies.find(t => t.slot === e) ?? null
        }
        findContacts(e, t) {
            let n = Math.cos(e.angle),
                r = Math.sin(e.angle);
            for (let i of e.edge) {
                let a = [n * i[0] - r * i[1], r * i[0] + n * i[1]],
                    o = [e.pos[0] + t[0] + a[0], e.pos[1] + t[1] + a[1]],
                    s = Math.floor(o[0]),
                    c = Math.floor(o[1]);
                if (!this.blocked(s, c, e.slot)) continue;
                let l = 0,
                    u = 0;
                for (let t = -1; t <= 1; t++)
                    for (let n = -1; n <= 1; n++)(n !== 0 || t !== 0) && this.blocked(s + n, c + t, e.slot) && (l += n, u += t);
                let d = [-l, -u];
                d[0] * d[0] + d[1] * d[1] < .01 && (d = [-a[0], -a[1]]), d[0] * d[0] + d[1] * d[1] < 1e-6 && (d = [0, -1]);
                let f = Math.hypot(d[0], d[1]);
                d = [d[0] / f, d[1] / f];
                let p = st(.5 - ((o[0] - (s + .5)) * d[0] + (o[1] - (c + .5)) * d[1]), 0, 1),
                    m = null;
                s >= 0 && c >= 0 && s < this.w && c < this.h && !(this.occ[c * this.w + s] & 1) && (m = this.bySlot(this.bodyAt[c * this.w + s])), this.contacts.push({
                    a: e,
                    b: m,
                    ra: a,
                    rb: m ? [o[0] - m.pos[0], o[1] - m.pos[1]] : [0, 0],
                    n: d,
                    depth: p,
                    jn: 0,
                    jt: 0
                })
            }
        }
        static pointVel(e, t) {
            if (!e || e.asleep) return [0, 0];
            let n = ot(e.angVel, t);
            return [e.vel[0] + n[0], e.vel[1] + n[1]]
        }
        solve() {
            for (let t = 0; t < 8; t++)
                for (let t of this.contacts) {
                    let n = t.a,
                        r = t.b && !t.b.asleep ? t.b : null,
                        i = e.pointVel(n, t.ra),
                        a = e.pointVel(r, t.rb),
                        o = [i[0] - a[0], i[1] - a[1]],
                        s = at(o, t.n),
                        c = O(t.ra, t.n),
                        l = r ? O(t.rb, t.n) : 0,
                        u = n.invMass + n.invInertia * c * c + (r ? r.invMass + r.invInertia * l * l : 0),
                        d = -(1 + (s < -40 ? this.restitution : 0)) * s / u,
                        f = Math.max(t.jn + d, 0);
                    d = f - t.jn, t.jn = f;
                    let p = [t.n[0] * d, t.n[1] * d];
                    n.vel = [n.vel[0] + p[0] * n.invMass, n.vel[1] + p[1] * n.invMass], n.angVel += O(t.ra, p) * n.invInertia, r && (r.vel = [r.vel[0] - p[0] * r.invMass, r.vel[1] - p[1] * r.invMass], r.angVel -= O(t.rb, p) * r.invInertia);
                    let m = [-t.n[1], t.n[0]];
                    i = e.pointVel(n, t.ra), a = e.pointVel(r, t.rb), o = [i[0] - a[0], i[1] - a[1]];
                    let h = at(o, m),
                        g = O(t.ra, m),
                        _ = r ? O(t.rb, m) : 0,
                        v = n.invMass + n.invInertia * g * g + (r ? r.invMass + r.invInertia * _ * _ : 0),
                        y = -h / v,
                        b = this.friction * t.jn,
                        ee = st(t.jt + y, -b, b);
                    y = ee - t.jt, t.jt = ee;
                    let x = [m[0] * y, m[1] * y];
                    n.vel = [n.vel[0] + x[0] * n.invMass, n.vel[1] + x[1] * n.invMass], n.angVel += O(t.ra, x) * n.invInertia, r && (r.vel = [r.vel[0] - x[0] * r.invMass, r.vel[1] - x[1] * r.invMass], r.angVel -= O(t.rb, x) * r.invInertia)
                }
        }
        integrate(e, t) {
            if (e.vel = [e.vel[0], e.vel[1] + this.gravity * t], this.haveOcc && e.edge.length > 0) {
                let n = Math.cos(e.angle),
                    r = Math.sin(e.angle),
                    i = this.w;
                this.wetRows.clear();
                for (let t of e.edge) {
                    let a = e.pos[0] + n * t[0] - r * t[1],
                        o = e.pos[1] + r * t[0] + n * t[1],
                        s = Math.floor(o);
                    if (s < 0 || s >= this.h || this.wetRows.has(s)) continue;
                    let c = Math.floor(a - 1.5),
                        l = Math.floor(a + 1.5);
                    (c >= 0 && this.occ[s * i + c] & 2 || l < i && this.occ[s * i + l] & 2) && this.wetRows.add(s)
                }
                let a = 0,
                    o = 0,
                    s = 0;
                if (this.wetRows.size > 0)
                    for (let t of e.all) {
                        let i = n * t[0] - r * t[1],
                            c = r * t[0] + n * t[1];
                        this.wetRows.has(Math.floor(e.pos[1] + c)) && (a++, o += i, s += c)
                    }
                if (a > 0) {
                    let n = a / e.all.length,
                        r = n * e.count * this.gravity;
                    o /= a, s /= a;
                    let i = [0, -r];
                    e.vel = [e.vel[0] + i[0] * e.invMass * t, e.vel[1] + i[1] * e.invMass * t], e.angVel += O([o, s], i) * e.invInertia * t;
                    let c = Math.exp(-6 * n * t);
                    e.vel = [e.vel[0] * c, e.vel[1] * c * Math.exp(-6 * n * t)], e.angVel *= Math.exp(-8 * n * t)
                }
            }
            e.angVel *= Math.exp(-.2 * t);
            let n = Math.hypot(e.vel[0], e.vel[1]);
            n > 500 && (e.vel = [e.vel[0] / n * 500, e.vel[1] / n * 500]), e.angVel = st(e.angVel, -20, 20), e.pos = [e.pos[0] + e.vel[0] * t, e.pos[1] + e.vel[1] * t], e.angle += e.angVel * t
        }
        blast(e) {
            for (let t of this.bodies) {
                let n = [t.pos[0] - e[0], t.pos[1] - e[1]],
                    r = Math.hypot(n[0], n[1]),
                    i = e[2] * 2.5;
                if (r > i) continue;
                let a = 1 - r / i,
                    o = r > .01 ? [n[0] / r, n[1] / r] : [0, -1];
                t.asleep = !1, t.stillFrames = 0;
                let s = 260 * a * e[3] / Math.sqrt(Math.max(t.mass, 1) / 30 + 1);
                t.vel = [t.vel[0] + o[0] * s, t.vel[1] + o[1] * s], t.angVel += (this.rng.next() - .5) * 8 * a * e[3]
            }
        }
        update(e, t) {
            this.frame++;
            let n = this.occIn,
                r = this.ownersIn,
                i = this.cellsIn,
                a = this.ownersFrame;
            if (this.occIn = this.ownersIn = this.cellsIn = null, n) {
                let e = new Uint32Array(n),
                    t = this.w / 16;
                for (let n = 0; n < this.h; n++)
                    for (let r = 0; r < t; r++) {
                        let i = e[n * t + r];
                        for (let e = 0; e < 16; e++) this.occ[n * this.w + r * 16 + e] = i >>> 2 * e & 3
                    }
                this.haveOcc = !0
            }
            if (r && this.applyOwners(r, a), i && this.bodify(i), !t && this.haveOcc && this.bodies.length > 0) {
                let t = e / this.substeps;
                for (let e = 0; e < this.substeps; e++) {
                    this.rasterizeBodies();
                    for (let e of this.bodies) e.asleep || this.integrate(e, t);
                    this.rasterizeBodies(), this.contacts = [];
                    for (let e of this.bodies) e.asleep || this.findContacts(e, [0, 0]);
                    this.solve();
                    for (let e of this.bodies) {
                        if (e.asleep) continue;
                        let t = 0,
                            n = 0,
                            r = 0;
                        for (let i of this.contacts) {
                            if (i.a !== e) continue;
                            let a = Math.max(i.depth - .05, 0);
                            t += i.n[0] * a, n += i.n[1] * a, r++
                        }
                        r > 0 && (e.pos = [e.pos[0] + t / r * .5, e.pos[1] + n / r * .5])
                    }
                    for (let e of this.contacts) e.b && e.b.asleep && e.jn > 30 && (e.b.asleep = !1, e.b.stillFrames = 0)
                }
                for (let e of this.bodies) {
                    if (e.asleep) {
                        ++e.sleepCheck >= 15 && (e.sleepCheck = 0, this.contacts = [], this.rasterizeBodies(), this.findContacts(e, [0, .8]), this.contacts.length === 0 && (e.asleep = !1, e.stillFrames = 0));
                        continue
                    }
                    e.stillFrames = e.vel[0] * e.vel[0] + e.vel[1] * e.vel[1] < 36 && Math.abs(e.angVel) < .25 ? e.stillFrames + 1 : 0, e.stillFrames > 30 && (e.asleep = !0, e.vel = [0, 0], e.angVel = 0, e.sleepCheck = 0)
                }
            }
            for (let e = this.bodies.length - 1; e >= 0; e--) {
                let t = this.bodies[e];
                (t.pos[1] > this.h + 200 || t.pos[0] < -200 || t.pos[0] > this.w + 200) && this.bodies.splice(e, 1)
            }
            return this.snapshot(t)
        }
        snapshot(e) {
            let t = new ut;
            t.frame = this.frame, t.atlasUsed = this.atlasUsed, t.reset = this.resetPending, t.step = !e, t.count = Math.min(this.bodies.length, it), this.resetPending = !1, t.newRegions.push(...this.newRegions), this.newRegions = [], t.ownerUpdates.push(...this.ownerUpdates), this.ownerUpdates = [], t.claims.push(...this.claims), this.claims = [];
            let n = new ArrayBuffer(t.count * 64),
                r = new DataView(n);
            for (let e = 0; e < t.count; e++) {
                let t = this.bodies[e],
                    n = Math.cos(t.angle),
                    i = Math.sin(t.angle),
                    a = 1 / 0,
                    o = 1 / 0,
                    s = -1 / 0,
                    c = -1 / 0;
                for (let [e, r] of [
                        [0, 0],
                        [t.rw, 0],
                        [0, t.rh],
                        [t.rw, t.rh]
                    ]) {
                    let l = e - t.com[0],
                        u = r - t.com[1],
                        d = t.pos[0] + n * l - i * u,
                        f = t.pos[1] + i * l + n * u;
                    a = Math.min(a, d), o = Math.min(o, f), s = Math.max(s, d), c = Math.max(c, f)
                }
                let l = e * 64;
                r.setFloat32(l, t.pos[0], !0), r.setFloat32(l + 4, t.pos[1], !0), r.setFloat32(l + 8, n, !0), r.setFloat32(l + 12, i, !0), r.setFloat32(l + 16, t.com[0], !0), r.setFloat32(l + 20, t.com[1], !0), r.setInt32(l + 32, t.atlas, !0), r.setInt32(l + 36, t.rw, !0), r.setInt32(l + 40, t.rh, !0), r.setInt32(l + 44, t.slot, !0), r.setInt32(l + 48, st(Math.floor(a) - 1, 0, this.w), !0), r.setInt32(l + 52, st(Math.floor(o) - 1, 0, this.h), !0), r.setInt32(l + 56, st(Math.ceil(s) + 1, 0, this.w), !0), r.setInt32(l + 60, st(Math.ceil(c) + 1, 0, this.h), !0)
            }
            return t.bodies = new Float32Array(n), t
        }
    },
    ft = rt / 32,
    pt = 65536,
// 刚体 GPU 桥 RigidBodyGpuBridge：atlas、owner、盖章、擦除与占用回读。
    mt = class {
        gpu;
        w;
        h;
        atlasBuf;
        owner;
        alive;
        bodies;
        displaced;
        occ;
        updates;
        claims;
        stamped;
        pick;
        erase;
        dead;
        ownerPass;
        claimPass;
        stamp;
        displace;
        occPass;
        deadOwners;
        parity = 0;
        lastSubmit = -1;
        atlasUsed = 0;
        occPending = !1;
        ownerPending = !1;
        constructor(e, t, n) {
            this.gpu = e, this.w = t, this.h = n, this.deadOwners = new Uint8Array(rt * 4).fill(255);
            let r = (t, n, r) => e.createStorageBuffer(t, n, r);
            this.atlasBuf = r(rt * 16, null, `body_atlas`), this.owner = r(rt * 4, this.deadOwners, `body_owner`), this.alive = r(ft * 4, null, `body_alive`), this.stamped = [r(ft * 4, null, `body_stamped_a`), r(ft * 4, null, `body_stamped_b`)], this.bodies = r(it * 64, null, `bodies`), this.displaced = r(262160, null, `body_displaced`), this.occ = r(t * n / 4, null, `body_occ`), this.updates = r(pt * 8, null, `body_owner_updates`), this.claims = r(pt * 16, null, `body_claims`), this.pick = r(rt * 4, null, `body_pick`);
            let i = t => new Ve(e, `bodies/${t}.comp`);
            this.erase = i(`body_erase`), this.dead = i(`body_dead`), this.ownerPass = i(`body_owner`), this.claimPass = i(`body_claim`), this.stamp = i(`body_stamp`), this.displace = i(`body_displace`), this.occPass = i(`body_occ`)
        }
        reset() {
            this.gpu.device.queue.writeBuffer(this.owner, 0, this.deadOwners), this.gpu.clearBuffer(this.stamped[0], 0, ft * 4), this.gpu.clearBuffer(this.stamped[1], 0, ft * 4), this.atlasUsed = 0
        }
        preStep(e, t) {
            if (!t) return;
            let n = this.gpu,
                r = n.device.queue;
            this.lastSubmit === n.submits && (n.submit(), n.begin()), this.lastSubmit = n.submits, t.reset && this.reset();
            for (let e of t.newRegions) r.writeBuffer(this.atlasBuf, e.offset * 16, e.cells), r.writeBuffer(this.owner, e.offset * 4, e.owners);
            if (this.atlasUsed = t.atlasUsed, this.atlasUsed === 0 && t.claims.length === 0) return;
            let i = new S({
                i0x: this.w,
                i0y: this.h
            });
            if (t.claims.length > 0) {
                let n = Math.min(t.claims.length / 4, pt);
                r.writeBuffer(this.claims, 0, new Uint32Array(t.claims.slice(0, n * 4))), this.claimPass.dispatch(new C().image(0, e.cells.read).buffer(1, this.claims), i.clone().set(`i1x`, n), n, 1)
            }
            if (t.ownerUpdates.length > 0) {
                let e = Math.min(t.ownerUpdates.length / 2, pt);
                r.writeBuffer(this.updates, 0, new Uint32Array(t.ownerUpdates.slice(0, e * 2))), this.ownerPass.dispatch(new C().buffer(0, this.owner).buffer(1, this.updates), new S({
                    i0x: e
                }), e, 1)
            }
            if (!t.step) return;
            let a = Math.floor((this.atlasUsed + 31) / 32);
            n.clearBuffer(this.alive, 0, Math.max(a, 1) * 4), n.clearBuffer(this.pick, 0, Math.max(this.atlasUsed, 1) * 4), i.set(`i0z`, this.atlasUsed);
            let o = () => new C().image(0, e.cells.read).image(1, e.cells.write).buffer(2, e.materialsBuf).buffer(3, this.atlasBuf).buffer(4, this.owner).buffer(5, this.alive).buffer(6, this.pick);
            this.erase.dispatch(o(), i.clone().set(`i0w`, 0), this.w, this.h), this.erase.dispatch(o(), i.clone().set(`i0w`, 1), this.w, this.h), e.cells.swap();
            let s = this.stamped[this.parity ^ 1],
                c = this.stamped[this.parity];
            this.dead.dispatch(new C().buffer(0, this.owner).buffer(1, this.alive).buffer(2, s), new S({
                i0x: a
            }), a, 1), n.clearBuffer(c, 0, Math.max(a, 1) * 4), n.clearBuffer(this.displaced, 0, 16), t.count > 0 && (r.writeBuffer(this.bodies, 0, t.bodies.buffer, 0, t.count * 64), i.set(`i0z`, t.count), this.stamp.dispatch(new C().image(0, e.cells.read).image(1, e.cells.write).buffer(2, e.materialsBuf).buffer(3, this.atlasBuf).buffer(4, this.owner).buffer(5, c).buffer(6, this.bodies).buffer(7, this.displaced), i, this.w, this.h), e.cells.swap(), this.displace.dispatch(new C().image(0, e.cells.read).buffer(1, e.materialsBuf).buffer(2, this.displaced).image(4, e.cells.write), new S({
                i0x: this.w,
                i0y: this.h
            }), 256, 1)), this.parity ^= 1
        }
        get state() {
            let e = Math.max(Math.floor((this.atlasUsed + 31) / 32), 1);
            return {
                atlasUsed: this.atlasUsed,
                parity: this.parity,
                words: e,
                atlas: this.atlasBuf,
                owner: this.owner,
                stamped: this.stamped[this.parity ^ 1]
            }
        }
        restore(e, t, n, r, i) {
            let a = this.gpu.device.queue;
            a.writeBuffer(this.owner, 0, this.deadOwners);
            let o = new Uint8Array(ft * 4);
            a.writeBuffer(this.stamped[0], 0, o), a.writeBuffer(this.stamped[1], 0, o), this.atlasUsed = e, this.parity = t, n.length && a.writeBuffer(this.atlasBuf, 0, n), r.length && a.writeBuffer(this.owner, 0, r), i.length && a.writeBuffer(this.stamped[t ^ 1], 0, i)
        }
        postStep(e, t, n, r) {
            if (this.occPending || (this.occPass.dispatch(new C().image(0, e.cells.read).buffer(1, e.materialsBuf).buffer(2, this.occ), new S({
                    i0x: this.w,
                    i0y: this.h
                }), this.w * this.h / 16, 1), this.occPending = !0, queueMicrotask(() => this.gpu.readBuffer(this.occ, this.w * this.h / 4).then(e => {
                    this.occPending = !1, n(e)
                }))), !this.ownerPending && this.atlasUsed > 0) {
                this.ownerPending = !0;
                let e = this.atlasUsed * 4;
                queueMicrotask(() => this.gpu.readBuffer(this.owner, e).then(e => {
                    this.ownerPending = !1, r(e, t)
                }))
            }
        }
    },
    k = (e, t, n) => e + (t - e) * n,
    ht = (e, t, n) => [k(e[0], t[0], n), k(e[1], t[1], n), k(e[2], t[2], n)],
    A = (e, t, n, r, i, a, o, s, c) => ({
        skyMul: e,
        skyTop: t,
        skyHorizon: n,
        sunAngle: r,
        sunColor: i,
        sunMul: a,
        ambient: o,
        ambientMul: s,
        night: c
    }),
    gt = [.3, .52, .95],
    _t = [.85, .72, .6],
    vt = [.02, .03, .09],
    yt = [.06, .07, .14],
    bt = [.55, .68, 1],
    xt = [.35, .45, .85],
    St = [
        [0, A(.12, vt, yt, 60, bt, .1, xt, .45, 1)],
        [4.5, A(.14, vt, yt, 30, bt, .06, xt, .45, 1)],
        [5.5, A(.3, [.1, .12, .3], [.5, .32, .38], 178, [1, .45, .3], .03, [.7, .6, .75], .6, .6)],
        [6.5, A(.75, [.32, .42, .78], [1, .55, .32], 165, [1, .58, .32], .8, [.95, .75, .65], .85, 0)],
        [9, A(1, gt, _t, 125, [1, .88, .72], 1, [.9, .95, 1.05], 1, 0)],
        [12, A(1.05, gt, _t, 92, [1, .95, .88], 1.1, [.95, 1, 1.05], 1.05, 0)],
        [15, A(1, gt, _t, 60, [1, .9, .75], 1, [.95, .95, 1], 1, 0)],
        [17.5, A(.85, [.35, .45, .8], [1, .62, .35], 28, [1, .68, .38], .9, [1, .8, .65], .9, 0)],
        [19, A(.45, [.24, .2, .45], [.92, .42, .4], 10, [1, .45, .32], .3, [.8, .6, .75], .7, .3)],
        [20.5, A(.18, [.06, .06, .18], [.25, .15, .3], 3, [.9, .5, .5], .03, xt, .5, .85)],
        [21.5, A(.12, vt, yt, 140, bt, .05, xt, .45, 1)],
        [24, A(.12, vt, yt, 60, bt, .1, xt, .45, 1)]
    ];

function Ct(e, t, n) {
    return {
        skyTop: ht(e.skyTop, t.skyTop, n),
        skyHorizon: ht(e.skyHorizon, t.skyHorizon, n),
        sunColor: ht(e.sunColor, t.sunColor, n),
        ambient: ht(e.ambient, t.ambient, n),
        skyMul: k(e.skyMul, t.skyMul, n),
        sunAngle: k(e.sunAngle, t.sunAngle, n),
        sunMul: k(e.sunMul, t.sunMul, n),
        ambientMul: k(e.ambientMul, t.ambientMul, n),
        night: k(e.night, t.night, n)
    }
}

function wt(e) {
    e = (e % 24 + 24) % 24;
    for (let t = 0; t < St.length - 1; t++) {
        let [n, r] = St[t], [i, a] = St[t + 1];
        if (e <= i) {
            let t = Math.min(Math.max((e - n) / Math.max(i - n, 1e-4), 0), 1);
            return t = t * t * (3 - 2 * t), Ct(r, a, t)
        }
    }
    return St[St.length - 1][1]
}

function Tt(e) {
    e = (e % 24 + 24) % 24;
    let t = Math.floor(e),
        n = Math.floor((e - t) * 60);
    return `${String(t).padStart(2,`0`)}:${String(n).padStart(2,`0`)}`
}
var Et = 8,
    Dt = 160,
    Ot = e => e * Math.PI / 180,
    kt = class {
        v;
        timeOfDay = 10;
        freezeTime = !1;
        costView = !1;
        frameParallax = [0, 0];
        constructor(e) {
            this.v = structuredClone(e)
        }
        n(e) {
            return this.v[e]
        }
        b(e) {
            return this.v[e]
        }
        c(e) {
            return this.v[e]
        }
        set(e, t) {
            this.v[e] = t
        }
        get voxel() {
            return this.b(`Enable3D`) && this.b(`VoxelExtrude`)
        }
        get effectiveTilt() {
            return this.voxel ? this.n(`Tilt`) : 0
        }
        get effectiveYaw() {
            return this.voxel ? this.n(`YawMax`) : 0
        }
        get effectiveSlab() {
            return this.voxel ? this.n(`SlabThickness`) : 0
        }
        get day() {
            if (this.b(`DayCycleOn`)) return wt(this.timeOfDay);
            let e = e => this.c(e).slice(0, 3);
            return {
                skyTop: e(`SkyTop`),
                skyHorizon: e(`SkyHorizon`),
                skyMul: 1,
                sunAngle: this.n(`SunAngle`),
                sunColor: e(`SunColor`),
                sunMul: 1,
                ambient: e(`Ambient`),
                ambientMul: 1,
                night: 0
            }
        }
        get daylightNow() {
            return this.n(`Daylight`) * this.day.sunMul
        }
        daylightDir() {
            let e = Ot(this.day.sunAngle),
                t = -Math.cos(e),
                n = Math.sin(e);
            n = Math.max(n, .25);
            let r = Math.hypot(t, n);
            return [t / r, n / r]
        }
        toUbo(e, t, n, r, i, a, o, s) {
            let c = new Float32Array(116),
                l = 0,
                u = (e, t, n, r) => {
                    c[l++] = e, c[l++] = t, c[l++] = n, c[l++] = r
                },
                d = (e, t, n) => u(e[0] * t, e[1] * t, e[2] * t, n),
                f = this.day,
                p = Ot(f.sunAngle),
                m = [Math.cos(p), -Math.sin(p)],
                h = e => this.n(e),
                g = e => this.b(e);
            d(f.skyTop, h(`SkyIntensity`) * f.skyMul, 0), d(f.skyHorizon, h(`SkyIntensity`) * f.skyMul, 0), u(m[0], m[1], Math.cos(Ot(h(`SunSize`))), h(`SunIntensity`) * f.sunMul), d(f.sunColor, 1, 0);
            let _ = this.c(`Ambient`);
            u(f.ambient[0] * _[0] * h(`AmbientIntensity`) * f.ambientMul, f.ambient[1] * _[1] * h(`AmbientIntensity`) * f.ambientMul, f.ambient[2] * _[2] * h(`AmbientIntensity`) * f.ambientMul, h(`BackwallLight`)), u(h(`Bounce`), h(`Temporal`), +!!g(`BilinearFix`), h(`FluenceGain`)), u(h(`BloomThreshold`), h(`BloomKnee`), h(`BloomIntensity`), h(`GodRays`)), u(h(`MinEv`), h(`MaxEv`), h(`AdaptUp`), h(`AdaptDown`)), u(h(`ExposureComp`) - f.night * h(`NightDarkness`) * 2.2, +!!g(`AutoExposure`), h(`ManualEv`), t), u(h(`SootSigma`), h(`SteamSigma`), h(`FlameIntensity`), h(`ZThickness`)), d(this.c(`SootColor`), 1, 0), d(this.c(`SteamColor`), 1, 0), u(h(`HeatDistortion`), h(`LiquidSpecular`), h(`Saturation`), h(`Contrast`)), u(e, h(`LutStrength`), n, r), u(i, h(`InteriorLight`), h(`CrossSectionFill`), g(`BgSmooth`) && g(`Enable3D`) ? 1 : 0), u(h(`MediumLightExtinction`), Math.min(h(`MediumScatter`), .9), h(`WaterReflection`), h(`SurfaceSparkle`)), u(a.center[0], a.center[1], a.halfW, a.halfH), u(a.dist, a.tiltTop, a.tiltBottom, a.tiltCurve), u(a.yaw, h(`FrontRim`), h(`TheatreSlope`), this.effectiveSlab), u(h(`FrontDepth`), h(`BackSmooth`), h(`BackFade`), h(`EdgeRim`)), u(Et, Dt, h(`BgDepthScale`), h(`HazeDensity`)), d(this.c(`HazeColor`), 1, h(`FogDepth`)), u(o, s, h(`SideShade`), h(`TheatreDepth`)), u(h(`AirDust`), h(`TheatreHaze`), h(`TheatreLight`), h(`DustMotes`));
            let v = g(`Enable3D`);
            u(this.voxel ? h(`FormLight`) : 0, v ? h(`DropShadow`) : 0, h(`DropOffset`), v ? h(`BgDim`) : 1);
            let y = v && !g(`VoxelExtrude`);
            u(y ? this.frameParallax[0] : 0, y ? this.frameParallax[1] : 0, y ? h(`BackRim`) : 0, y ? Math.max(h(`Bevel`), .001) : 0), u(v ? h(`WindowShafts`) : 0, h(`ShaftFall`), +!!this.costView, h(`WorldBrightness`));
            let b = this.daylightDir();
            return u(h(`ShadowLift`), h(`StillWaterMotion`), b[0], b[1]), u(f.night, this.timeOfDay, h(`GlossyReflection`), h(`DirectionalGI`)), c
        }
    },
    At = e => e * Math.PI / 180,
    j = (e, t, n) => Math.min(Math.max(e, t), n),
    jt = (e, t, n) => e + (t - e) * n;

function Mt(e, t, n, r, i, a, o, s) {
    let c = n[1] * .5 / Math.max(t, .01);
    return {
        center: e,
        halfW: n[0] * .5 / Math.max(t, .01),
        halfH: c,
        dist: c / Math.tan(At(j(s, 1, 120)) * .5),
        tiltTop: At(r),
        tiltBottom: At(i),
        tiltCurve: Math.max(a, .05),
        yaw: At(o)
    }
}
var Nt = (e, t, n) => [e.center[0] + (t * 2 - 1) * e.halfW, e.center[1] + (n * 2 - 1) * e.halfH],
    Pt = (e, t, n) => [(t - e.center[0]) / e.halfW * .5 + .5, (n - e.center[1]) / e.halfH * .5 + .5],
    Ft = class {
        worldSize = [512, 288];
        center = [256, 144];
        zoom = 1.875;
        minZoom = 1;
        maxZoom = 12;
        shake = [0, 0];
        tiltTopDeg = 16;
        tiltBottomDeg = 0;
        tiltCurve = 1.2;
        yawMaxDeg = 3;
        fovYDeg = 24;
        yaw = 0;
        maxUserYawDeg = 22;
        userYaw = 0;
        applyYaw = !0;
        view;
        screen = [1280, 720];
        userYawTarget = 0;
        shakeAmount = 0;
        targetZoom = 1.875;
        zoomAnchorCell = [0, 0];
        zoomAnchorScreen = [0, 0];
        zoomAnimating = !1;
        fit() {
            let [e, t] = this.screen;
            this.zoom = Math.min(e / this.worldSize[0], t / this.worldSize[1]), this.minZoom = this.zoom * .95, this.targetZoom = this.zoom, this.zoomAnimating = !1, this.center = [this.worldSize[0] * .5, this.worldSize[1] * .5], this.updateView()
        }
        setView(e, t) {
            let n = Math.min(this.screen[0] / this.worldSize[0], this.screen[1] / this.worldSize[1]);
            this.zoom = n * Math.max(t, 1), this.targetZoom = this.zoom, this.zoomAnimating = !1, this.center = [e[0], e[1]], this.updateView()
        }
        screenToCell(e, t) {
            return Nt(this.view, e / this.screen[0], t / this.screen[1])
        }
        cellToScreen(e, t) {
            let n = Pt(this.view, e, t);
            return [n[0] * this.screen[0], n[1] * this.screen[1]]
        }
        screenRadius(e, t, n) {
            let r = this.cellToScreen(e, t),
                i = this.cellToScreen(e + n, t);
            return Math.hypot(i[0] - r[0], i[1] - r[1])
        }
        setUserYaw(e) {
            this.userYawTarget = e, this.userYaw = e
        }
        turn(e) {
            this.userYawTarget = j(this.userYawTarget + e, -this.maxUserYawDeg, this.maxUserYawDeg)
        }
        recentreYaw() {
            this.userYawTarget = 0
        }
        addShake(e) {
            this.shakeAmount = Math.min(this.shakeAmount + e, 6)
        }
        updateView() {
            let e = j((this.center[0] - this.worldSize[0] * .5) / (this.worldSize[0] * .5), -1, 1);
            this.yaw = this.applyYaw ? -this.yawMaxDeg * e + this.userYaw : 0, this.view = Mt([this.center[0] + this.shake[0], this.center[1] + this.shake[1]], this.zoom, this.screen, this.tiltTopDeg, this.tiltBottomDeg, this.tiltCurve, this.yaw, this.fovYDeg)
        }
        zoomAt(e, t, n) {
            this.targetZoom = j(n, this.minZoom, this.maxZoom), this.zoomAnchorScreen = [e, t], this.zoomAnchorCell = this.screenToCell(e, t), this.zoomAnimating = !0
        }
        zoomBy(e, t, n) {
            this.zoomAt(e, t, (this.zoomAnimating ? this.targetZoom : this.zoom) * n)
        }
        panBy(e, t) {
            this.center = [this.center[0] - e / this.zoom, this.center[1] - t / this.zoom], this.clampCenter()
        }
        clampCenter() {
            let e = [this.screen[0] * .5 / this.zoom, this.screen[1] * .5 / this.zoom],
                t = [e[0] - 110 / this.zoom, e[1] - 110 / this.zoom],
                n = [this.worldSize[0] - t[0], this.worldSize[1] - t[1]];
            this.center = [t[0] > n[0] ? this.worldSize[0] * .5 : j(this.center[0], t[0], n[0]), t[1] > n[1] ? this.worldSize[1] * .5 : j(this.center[1], t[1], n[1])]
        }
        update(e, t = [0, 0], n = 0) {
            if (this.zoomAnimating) {
                this.zoom = jt(this.zoom, this.targetZoom, 1 - Math.exp(-18 * e)), Math.abs(this.zoom - this.targetZoom) < .001 && (this.zoom = this.targetZoom, this.zoomAnimating = !1), this.updateView();
                let t = this.screenToCell(this.zoomAnchorScreen[0], this.zoomAnchorScreen[1]);
                this.center = [this.center[0] + this.zoomAnchorCell[0] - t[0], this.center[1] + this.zoomAnchorCell[1] - t[1]], this.clampCenter()
            }
            this.userYawTarget = j(this.userYawTarget + n * 40 * e, -this.maxUserYawDeg, this.maxUserYawDeg), this.userYaw = jt(this.userYaw, this.userYawTarget, 1 - Math.exp(-8 * e)), (t[0] || t[1]) && (this.center = [this.center[0] + t[0] * 700 * e / this.zoom, this.center[1] + t[1] * 700 * e / this.zoom], this.clampCenter()), this.shakeAmount = Math.max(0, this.shakeAmount - e * 10), this.shake = this.shakeAmount > .01 ? [(Math.random() * 2 - 1) * this.shakeAmount, (Math.random() * 2 - 1) * this.shakeAmount] : [0, 0], this.updateView()
        }
    },
    It = (e, t, n) => {
        let r = Math.min(Math.max((n - e) / (t - e), 0), 1);
        return r * r * (3 - 2 * r)
    };

function Lt(e) {
    let t = e[0] * .2126 + e[1] * .7152 + e[2] * .0722,
        n = 1 - It(0, .45, t),
        r = It(.55, 1, t),
        i = [-.012, .004, .028],
        a = [.025, .008, -.02],
        o = [.008, .009, .012];
    return e.map((e, t) => Math.min(Math.max((e + i[t] * n + a[t] * r) * .985 + o[t], 0), 1))
}
var Rt = new Float32Array(1),
    zt = new Uint32Array(Rt.buffer);

function Bt(e) {
    Rt[0] = e;
    let t = zt[0],
        n = t >>> 16 & 32768,
        r = (t >>> 23 & 255) - 127 + 15,
        i = t & 8388607;
    return r <= 0 ? r < -10 ? n : (i = (i | 8388608) >>> 1 - r, i & 4096 && i & 12287 && (i += 8192), n | i >>> 13) : r >= 31 || i & 4096 && i & 12287 && (i += 8192, i & 8388608 && (i = 0, r++, r >= 31)) ? n | 31744 : n | r << 10 | i >>> 13
}

function Vt() {
    let e = new Uint16Array(131072),
        t = 0;
    for (let n = 0; n < 32; n++)
        for (let r = 0; r < 32; r++)
            for (let i = 0; i < 32; i++) {
                let a = Lt([i / 31, r / 31, n / 31]);
                e[t++] = Bt(a[0]), e[t++] = Bt(a[1]), e[t++] = Bt(a[2]), e[t++] = Bt(1)
            }
    return e
}
var Ht = function(e) {
        return e[e.Final = 0] = `Final`, e[e.Flat = 1] = `Flat`, e[e.MaterialId = 2] = `MaterialId`, e[e.Temperature = 3] = `Temperature`, e[e.FluidVelocity = 4] = `FluidVelocity`, e[e.Medium = 5] = `Medium`, e[e.Fluence = 6] = `Fluence`, e[e.Cascade = 7] = `Cascade`, e[e.Emission = 8] = `Emission`, e[e.Extinction = 9] = `Extinction`, e[e.Flashes = 10] = `Flashes`, e
    }({}),
    M = 4,
    Ut = 2,
    Wt = 5,
    Gt = 5,
    Kt = 640,
    qt = 32,
    Jt = 512;

function Yt(e) {
    return [Ut * (4 ** e - 1) / 3, Ut * (4 ** (e + 1) - 1) / 3]
}

function Xt(e, t) {
    let n = Math.sqrt(e * e + t * t);
    for (let r = 3; r <= 7; r++)
        if (Yt(r - 1)[1] >= n && e % (1 << r) == 0 && t % (1 << r) == 0) return r;
    throw Error(`World size ${e}x${t} is not supported by the cascade layout`)
}
var Zt = class e {
        w;
        h;
        exposure;
        ubo;
        hdr;
        dof;
        cost;
        output;
        bloomDown = [];
        bloomUp = [];
        lastTime = 0;
        constructor(e, t, n, r, i) {
            this.w = t, this.h = n, this.exposure = r, this.ubo = i, this.hdr = e.createTexture(t, n, `rgba16float`, `view_hdr`), this.dof = e.createTexture(t, n, `rgba16float`, `view_dof`), this.cost = e.createTexture(t, n, `rgba16float`, `cost_view`), this.output = e.createTexture(t, n, `rgba8unorm`, `final`);
            for (let r = 1; r <= Wt; r++) this.bloomDown[r] = e.createTexture(Math.max(t >> r, 1), Math.max(n >> r, 1), `rgba16float`, `bloom_d` + r), r < Wt && (this.bloomUp[r] = e.createTexture(Math.max(t >> r, 1), Math.max(n >> r, 1), `rgba16float`, `bloom_u` + r));
            e.clearTexture(this.hdr)
        }
        static create(t, n, r) {
            let i = new Float32Array(4);
            return i[3] = 1, new e(t, Math.max(64, n & -8), Math.max(64, r & -8), t.createStorageBuffer(16, i, `exposure_extra`), t.createUniformBuffer(464, `render_params_extra`))
        }
        destroy(e = !1) {
            for (let e of [this.hdr, this.dof, this.cost, this.output, ...this.bloomDown, ...this.bloomUp]) e?.destroy();
            e || (this.exposure.destroy(), this.ubo.destroy())
        }
    },
// 世界渲染器 WorldRenderer：光照历史、级联、雾、相机视图与后处理。
    Qt = class {
        gpu;
        width;
        height;
        debugOutput;
        background;
        mode = 0;
        debugCascade = 0;
        settings;
        cascadeCount;
        debugPass;
        albedo;
        emissive;
        rcsrc;
        gaux;
        l0s;
        l0t;
        ldir;
        godrays;
        lut;
        exposureBuf;
        ubo;
        mips = [];
        extMips = [];
        cascades = [];
        flMips = [];
        upperAvg;
        fluence;
        chA;
        chB;
        spacing = 1;
        retired = [];
        lightHalfRate = !1;
        farFrom = 2;
        midHalf = !0;
        fixBelow = 3;
        occ;
        side;
        bgsm;
        shafts;
        fogTex;
        backlight;
        cellShade;
        day;
        beamTex;
        beamDir;
        sub;
        glossA;
        glossB;
        beamBuf;
        matCost;
        sunHit;
        lampProbe;
        rcOccBuf;
        dayCells;
        main;
        p = {};
        frame = 0;
        lastTime = 0;
        get output() {
            return this.main.output
        }
        get viewW() {
            return this.main?.w ?? 0
        }
        get viewH() {
            return this.main?.h ?? 0
        }
        get fluenceTex() {
            return this.fluence.read
        }
        get daylightTex() {
            return this.day.read
        }
        constructor(e, t, n, r, i = 1536, a = 864) {
            this.gpu = e, this.width = t, this.height = n, this.settings = r;
            let o = t,
                s = n,
                c = (t, n, r, i = `rgba16float`) => e.createTexture(Math.max(t, 1), Math.max(n, 1), i, r);
            this.debugOutput = c(o, s, `debug_out`, `rgba8unorm`), this.background = c(o, s, `background`, `rgba8uint`), this.debugPass = new Ve(e, `render/debug_view.comp`), this.cascadeCount = Xt(o, s), this.albedo = c(o, s, `albedo`), this.emissive = c(o, s, `emissive`), this.rcsrc = c(o, s, `rc_src`), this.gaux = c(o, s, `gaux`), this.l0s = c(o, s, `layer0_s`), this.l0t = c(o, s, `layer0_t`), this.mips[0] = this.rcsrc, this.extMips[0] = c(o, s, `rc_ext`);
            for (let e = 1; e < 5; e++) this.mips[e] = c(o >> e, s >> e, `rc_mip` + e), this.extMips[e] = c(o >> e, s >> e, `rc_ext_mip` + e);
            this.allocLight(1), this.godrays = c(o / 2, s / 2, `godrays`);
            let l = new Float32Array(4);
            l[3] = 1, this.exposureBuf = e.createStorageBuffer(16, l, `exposure`), this.ubo = e.createUniformBuffer(464, `render_params`), this.lut = e.createTexture(32, 32, `rgba16float`, `grading_lut`, 32), e.writeTexture(this.lut, Vt(), 8);
            for (let t of [`gbuffer`, `rc_mips`, `rc_cascade`, `rc_resolve`, `composite`, `bloom_down`, `bloom_up`, `exposure`, `tonemap`, `godrays`, `downsample`, `view3d`, `occ_field`, `dof`, `subsurface`, `beam_waves`, `beam_probe`, `light_prep`, `beam_blur`, `window_shafts`, `front_fog`, `fog_backlight`, `daylight`, `view_cells`, `rc_avg`]) this.p[t] = new Ve(e, `render/${t}.comp`);
            this.occ = c(o, s, `occ_field`), this.side = c(o, s, `side_colour`), this.bgsm = c(o, s, `bg_smooth`), this.sunHit = e.createStorageBuffer(Kt * 4, null, `sun_hits`), this.lampProbe = e.createStorageBuffer(Math.ceil((o + 1 >> 1) / 8) * Math.ceil((s + 1 >> 1) / 8) * 16, null, `lamp_probes`), this.rcOccBuf = e.createStorageBuffer(Jt, null, `rc_occupancy`), this.dayCells = c(o, s, `day_cells`, `rgba32uint`), this.beamBuf = e.createStorageBuffer(o / 2 * (s / 2) * 5 * 4, null, `mirror_beams`), this.shafts = c(o, s, `window_shafts`), this.day = new w(c(o, s, `daylight_a`), c(o, s, `daylight_b`)), this.fogTex = c(o, s, `front_fog`), this.backlight = c(o, s, `fog_backlight`), this.cellShade = c(o, s * 3, `cell_shade`, `rgba32float`), this.matCost = e.createStorageBuffer(1040, null, `material_cost`), this.beamTex = new w(c(o / 2, s / 2, `beam_a`), c(o / 2, s / 2, `beam_b`)), this.beamDir = new w(c(o / 2, s / 2, `beam_dir_a`), c(o / 2, s / 2, `beam_dir_b`)), this.glossA = c(o, s, `gloss_a`), this.glossB = c(o, s, `gloss_b`), this.sub = new w(c(o, s, `subsurface_a`), c(o, s, `subsurface_b`));
            for (let t of [this.fluence.read, this.fluence.write, this.ldir, this.day.read, this.day.write, this.beamTex.read, this.beamTex.write, this.beamDir.read, this.beamDir.write, this.sub.read, this.sub.write, this.chA.read, this.chA.write, this.chB.read, this.chB.write]) e.clearTexture(t);
            this.setViewSize(i, a)
        }
        setLightSpacing(e) {
            e !== this.spacing && this.allocLight(e)
        }
        get lightSpacing() {
            return this.spacing
        }
        allocLight(e) {
            let t = this.gpu,
                n = this.width,
                r = this.height,
                i = [...this.cascades, this.upperAvg, ...this.flMips.slice(1), this.ldir, this.fluence?.read, this.fluence?.write, this.chA?.read, this.chA?.write, this.chB?.read, this.chB?.write].filter(e => e);
            i.length && this.retired.push([i, this.frame + 3]), this.spacing = e;
            let a = (e, n, r) => t.createTexture(Math.max(e, 1), Math.max(n, 1), `rgba16float`, r),
                o = n / e * M,
                s = r / e * M;
            this.cascades = [];
            for (let e = 0; e < this.cascadeCount; e++) this.cascades.push(a(o, s, `cascade` + e));
            this.upperAvg = t.createTexture(o / 2, s / 2, `rgba32float`, `cascade_upper_avg`);
            let c = n / e,
                l = r / e;
            this.fluence = new w(a(c, l, `fluence_a`), a(c, l, `fluence_b`)), this.flMips = [this.fluence.read];
            for (let e = 1; e < Gt; e++) this.flMips[e] = a(c >> e, l >> e, `fluence_mip` + e);
            this.ldir = a(c, l, `light_dir`), this.chA = new w(a(c, l, `ch_a0`), a(c, l, `ch_a1`)), this.chB = new w(a(c, l, `ch_b0`), a(c, l, `ch_b1`));
            for (let e of [this.fluence.read, this.fluence.write, this.ldir, this.chA.read, this.chA.write, this.chB.read, this.chB.write]) t.clearTexture(e)
        }
        fl(e) {
            return this.flMips[Math.max(e - (this.spacing >> 1), 0)]
        }
        uploadBackground(e) {
            this.gpu.writeTexture(this.background, e, 4)
        }
        setViewSize(e, t) {
            return e = Math.max(64, e & -8), t = Math.max(64, t & -8), this.main && e === this.main.w && t === this.main.h ? !1 : (this.main?.destroy(!0), this.main = new Zt(this.gpu, e, t, this.exposureBuf, this.ubo), !0)
        }
        defaultCamera() {
            let e = Math.min(this.viewW / this.width, this.viewH / this.height),
                t = this.settings;
            return Mt([this.width / 2, this.height / 2], e, [this.viewW, this.viewH], t.effectiveTilt, t.b(`Enable3D`) ? t.n(`TiltBottom`) : 0, t.n(`TiltCurve`), 0, t.n(`FovY`))
        }
        render(e, t, n) {
            if (this.renderFinal(e, t, n), this.mode === 0) return;
            let r, i = e.fluidVel.read,
                a = 0,
                o = 1;
            switch (this.mode) {
                case 1:
                    r = 0;
                    break;
                case 2:
                    r = 1;
                    break;
                case 3:
                    r = 2;
                    break;
                case 4:
                    r = 3, o = 1.5;
                    break;
                case 5:
                    r = 4, i = e.medium.read;
                    break;
                case 10:
                    r = 6;
                    break;
                default:
                    r = 5, [i, a, o] = this.mode === 6 ? [this.fluence.read, 0, 1] : this.mode === 7 ? [this.cascades[Math.min(Math.max(this.debugCascade, 0), this.cascadeCount - 1)], 0, 1] : this.mode === 8 ? [this.rcsrc, 0, 1] : this.mode === 9 ? [this.rcsrc, 1, .5] : [this.l0s, 0, 1]
            }
            this.debugPass.dispatch(new C().image(0, e.cells.read).buffer(1, e.materialsBuf).image(2, this.debugOutput).sampler(3, this.gpu.linearClamp, i), new S({
                i0x: this.width,
                i0y: this.height,
                i1x: r,
                i1y: a,
                f0x: o
            }), this.width, this.height)
        }
        // 按既有帧奇偶与设置调度光照/光束/雾；纹理历史同时供模拟特定规则读取。
        renderFinal(e, t, n) {
            let r = this.width,
                i = this.height,
                a = this.gpu,
                o = this.settings,
                s = this.p,
                c = Math.min(Math.max(t - this.lastTime, 0), .1);
            for (this.lastTime = t; this.retired.length && this.retired[0][1] <= this.frame;)
                for (let e of this.retired.shift()[0]) e.destroy();
            a.device.queue.writeBuffer(this.ubo, 0, o.toUbo(t, c, r, i, this.cascadeCount, n, this.viewW, this.viewH));
            let l = a.linearClamp,
                u = o.n(`MirrorBeams`),
                d = o.n(`LampBeams`),
                f = o.n(`MirrorBeamRange`),
                p = !(this.frame & 1),
                m = !this.lightHalfRate || p,
                h = !(this.lightHalfRate || this.midHalf) || !p,
                g = this.lightHalfRate || p;
            if (h) {
                a.clearBuffer(this.beamBuf, 0, r / 2 * (i / 2) * 5 * 4);
                let t = o.daylightDir(),
                    n = u > 0,
                    c = d > 0,
                    p = new C().image(0, e.cells.read).buffer(1, e.materialsBuf).image(2, this.albedo).image(3, this.emissive).image(4, this.gaux).sampler(5, l, this.fluence.read).sampler(6, l, this.ldir).buffer(7, this.beamBuf).sampler(8, l, this.day.read).sampler(9, l, this.beamTex.read).sampler(10, l, e.medium.read).buffer(11, this.sunHit).buffer(12, this.lampProbe),
                    m = Math.ceil((r + 1 >> 1) / 8),
                    h = Math.ceil((i + 1 >> 1) / 8),
                    g = Math.floor(2 * (Math.sqrt(r * r + i * i) * .5 + 2)) + 1,
                    _ = Math.ceil(g / qt),
                    v = new S({
                        i0x: r,
                        i0y: i,
                        i0z: _,
                        i1x: m,
                        i1y: h,
                        i1z: +!!n,
                        i1w: +!!c,
                        f0x: u,
                        f0y: f,
                        f1x: t[0],
                        f1y: t[1],
                        f1z: d
                    });
                n && a.clearBuffer(this.sunHit, 0, Kt * 4);
                let y = (n ? Math.ceil(Kt * _ / 256) : 0) + (c ? m * h : 0);
                y > 0 && s.beam_probe.dispatch(p, v, y * 256, 1);
                let b = (n ? 80 + Math.ceil(r / 8) * Math.ceil(i / 8) : 0) + (c ? m * h * 8 : 0);
                b > 0 && s.beam_waves.dispatch(p, v, b * 8, 8), s.beam_blur.dispatch(new C().buffer(0, this.beamBuf).image(1, this.beamTex.read).image(2, this.beamTex.write).image(3, this.beamDir.write).image(4, this.beamDir.read), new S({
                    i0x: r / 2,
                    i0y: i / 2,
                    f0x: .07
                }), r / 2, i / 2), this.beamTex.swap(), this.beamDir.swap()
            }
            let _;
            s.gbuffer.dispatch(new C().image(0, e.cells.read).buffer(1, e.materialsBuf).sampler(2, l, e.medium.read).sampler(3, l, this.fluence.read).ubo(4, this.ubo).image(5, this.albedo).image(6, this.emissive).image(7, this.rcsrc).image(8, this.gaux).image(9, this.background).image(10, this.extMips[0]).sampler(11, l, this.beamTex.read).sampler(12, l, this.day.read).sampler(13, l, this.ldir).image(14, this.glossA), new S({
                i0x: r,
                i0y: i,
                i0z: this.frame & 2147483647
            }), r, i);
            for (let e = 1; e < 5 && m; e++) s.rc_mips.dispatch(new C().image(0, this.mips[e - 1]).image(1, this.mips[e]).image(2, this.extMips[e - 1]).image(3, this.extMips[e]), new S({
                i0x: r >> e,
                i0y: i >> e
            }), r >> e, i >> e);
            if (a.clearBuffer(this.rcOccBuf, 0, Jt), s.light_prep.dispatch(new C().image(0, this.glossA).buffer(1, this.rcOccBuf).image(2, this.albedo).image(3, this.emissive).image(4, this.background).image(5, e.cells.read).image(6, this.dayCells), new S({
                    i0x: r,
                    i0y: i,
                    i0z: r / 8,
                    i0w: i / 8
                }), r, i), m) {
                for (let e = this.cascadeCount - 1; e >= 0; e--) {
                    if (e >= this.farFrom && !g || !this.lightHalfRate && e > this.farFrom && (this.frame & 3) != (e === this.farFrom + 1 ? 0 : 2)) continue;
                    let t = Math.min(Math.max(e - 1, 0), 4),
                        [n, c] = Yt(e);
                    _ = new S({
                        i0x: r,
                        i0y: i,
                        i0z: e,
                        i0w: this.cascadeCount,
                        i1x: this.spacing << e,
                        i1y: M << e,
                        i1z: o.b(`BilinearFix`) && e < this.fixBelow ? 1 : 0,
                        i1w: t,
                        f0x: n,
                        f0y: c,
                        f0z: Math.max(1, 1 << t)
                    });
                    let u = r / this.spacing * M,
                        d = i / this.spacing * M;
                    e < this.cascadeCount - 1 && s.rc_avg.dispatch(new C().sampler(0, a.nearestClamp, this.cascades[e + 1]).image(1, this.upperAvg), new S({
                        i0x: u / 2,
                        i0y: d / 2,
                        i1y: M << e
                    }), u / 2, d / 2), s.rc_cascade.dispatch(new C().sampler(0, l, this.mips[t]).image(1, this.upperAvg).image(2, this.cascades[e]).ubo(3, this.ubo).sampler(4, l, this.extMips[t]).sampler(5, a.nearestClamp, this.glossA).buffer(6, this.rcOccBuf), _, r / this.spacing * M, i / this.spacing * M)
                }
                let e = r / this.spacing,
                    t = i / this.spacing;
                s.rc_resolve.dispatch(new C().image(0, this.cascades[0]).image(1, this.fluence.read).image(2, this.fluence.write).image(3, this.ldir).ubo(4, this.ubo).image(5, this.chA.read).image(6, this.chB.read).image(7, this.chA.write).image(8, this.chB.write), new S({
                    i0x: e,
                    i0y: t,
                    i1x: M
                }), e, t), this.fluence.swap(), this.chA.swap(), this.chB.swap(), this.flMips[0] = this.fluence.read;
                for (let n = 1; n < Gt; n++) {
                    let r = Math.max(e >> n, 1),
                        i = Math.max(t >> n, 1);
                    s.downsample.dispatch(new C().image(0, this.flMips[n - 1]).image(1, this.flMips[n]), new S({
                        i0x: r,
                        i0y: i
                    }), r, i)
                }
            }
            _ = new S({
                i0x: r,
                i0y: i
            });
            for (let t = 0; t < 6 && h; t++) s.subsurface.dispatch(new C().image(0, e.cells.read).buffer(1, e.materialsBuf).image(2, this.albedo).image(3, this.emissive).image(4, this.gaux).sampler(5, l, this.fluence.read).image(6, this.sub.read).image(7, this.sub.write), _, r, i), this.sub.swap();
            let v = o.daylightDir();
            h && s.daylight.dispatch(new C().sampler(3, l, e.medium.read).image(4, this.day.write).ubo(5, this.ubo).buffer(7, e.materialsBuf).image(8, this.day.read).image(10, this.dayCells), new S({
                i0x: r,
                i0y: i,
                f0x: v[0],
                f0y: v[1],
                f0z: o.daylightNow,
                f0w: o.n(`DaylightRange`)
            }), r, i), h && this.day.swap(), s.composite.dispatch(new C().image(0, this.albedo).image(1, this.emissive).image(2, this.gaux).sampler(3, l, this.fluence.read).sampler(4, l, this.ldir).sampler(5, l, e.medium.read).image(6, e.cells.read).buffer(7, e.materialsBuf).ubo(8, this.ubo).image(9, this.l0s).image(10, this.l0t).image(11, this.sub.read).sampler(12, l, this.day.read).sampler(13, l, this.beamTex.read).sampler(14, l, this.beamDir.read).sampler(15, l, this.chA.read).sampler(16, l, this.chB.read), new S({
                i0x: r,
                i0y: i
            }), r, i), s.godrays.dispatch(new C().sampler(0, l, this.rcsrc).image(1, this.background).sampler(2, l, e.medium.read).image(3, this.godrays).ubo(4, this.ubo), new S({
                i0x: r / 2,
                i0y: i / 2,
                i1x: r,
                i1y: i
            }), r / 2, i / 2);
            let y = o.b(`Enable3D`);
            y && (!this.lightHalfRate || p) && s.occ_field.dispatch(new C().image(0, this.l0s).image(1, this.occ).image(2, this.side).image(3, this.background).image(4, this.bgsm), new S({
                i0x: r,
                i0y: i
            }), r, i), y && !o.b(`VoxelExtrude`) && (!this.lightHalfRate || !p) && (s.fog_backlight.dispatch(new C().image(0, this.l0s).image(1, this.l0t).sampler(2, l, this.fl(2)).sampler(3, l, this.fl(3)).sampler(4, l, this.day.read).image(5, this.backlight), new S({
                i0x: r,
                i0y: i
            }), r, i), s.front_fog.dispatch(new C().image(0, this.l0s).image(1, this.l0t).image(2, this.background).sampler(3, l, this.fl(2)).sampler(4, l, this.fl(3)).image(5, this.fogTex).ubo(6, this.ubo).sampler(7, l, this.day.read).image(8, this.backlight), new S({
                i0x: r,
                i0y: i
            }), r, i)), o.costView && a.clearBuffer(this.matCost, 0, 1040), this.main.lastTime = t, this.renderView(e, this.main), this.frame++
        }
        renderExtraView(e, t, n, r, i) {
            let a = this.settings,
                o = Math.min(Math.max(t - r.lastTime, 0), .1);
            r.lastTime = t;
            let s = a.frameParallax;
            a.frameParallax = i, this.gpu.device.queue.writeBuffer(r.ubo, 0, a.toUbo(t, o, this.width, this.height, this.cascadeCount, n, r.w, r.h)), a.frameParallax = s, this.renderView(e, r)
        }
        // 把世界图层投到相机视图，再执行景深、泛光、曝光和色调映射。
        renderView(e, t) {
            let n = this.width,
                r = this.height,
                i = this.settings,
                a = this.p,
                o = this.gpu.linearClamp,
                s = i.b(`Enable3D`),
                c = t.w,
                l = t.h,
                u, d = s && !i.voxel,
                f = new C().image(0, this.l0s).image(1, this.l0t).image(2, this.background).sampler(3, o, this.fl(0)).sampler(4, o, this.fl(1)).sampler(5, o, this.fl(2)).sampler(6, o, this.fl(3)).sampler(7, o, this.fl(4)).sampler(8, o, this.ldir).sampler(9, o, e.medium.read).sampler(10, o, this.godrays).ubo(11, t.ubo).image(12, t.hdr).image(13, e.cells.read).buffer(14, e.materialsBuf).image(15, this.gaux).sampler(16, o, this.occ).sampler(17, o, this.side).sampler(18, o, this.bgsm).sampler(19, o, this.beamTex.read).sampler(20, o, this.day.read).image(21, t.cost).buffer(22, this.matCost).sampler(23, o, this.fogTex).sampler(24, o, this.chA.read).sampler(25, o, this.chB.read).image(26, this.emissive).image(27, this.cellShade);
            d && a.view_cells.dispatch(f, new S({
                i0x: n,
                i0y: r,
                i1x: n,
                i1y: r
            }), n, r), a.view3d.dispatch(f, new S({
                i0x: c,
                i0y: l,
                i0z: this.frame & 2147483647,
                i1x: n,
                i1y: r,
                i1z: +!!d
            }), c, l);
            let p = t.hdr;
            s && i.n(`DofStrength`) > .05 && (a.dof.dispatch(new C().sampler(0, o, t.hdr).image(1, t.dof), new S({
                i0x: c,
                i0y: l,
                f0x: i.n(`DofStrength`),
                f0y: i.n(`DofStart`),
                f0z: Math.max(i.n(`DofEnd`), i.n(`DofStart`) + 1)
            }), c, l), p = t.dof);
            for (let e = 1; e <= Wt; e++) {
                let n = e === 1 ? p : t.bloomDown[e - 1],
                    r = Math.max(c >> e, 1),
                    s = Math.max(l >> e, 1);
                a.bloom_down.dispatch(new C().sampler(0, o, n).image(1, t.bloomDown[e]), new S({
                    i0x: r,
                    i0y: s,
                    i1x: +(e === 1),
                    f0x: i.n(`BloomThreshold`),
                    f0y: i.n(`BloomKnee`)
                }), r, s)
            }
            for (let e = 4; e >= 1; e--) {
                let n = e === 4 ? t.bloomDown[Wt] : t.bloomUp[e + 1],
                    r = Math.max(c >> e, 1),
                    i = Math.max(l >> e, 1);
                a.bloom_up.dispatch(new C().sampler(0, o, n).sampler(1, o, t.bloomDown[e]).image(2, t.bloomUp[e]), new S({
                    i0x: r,
                    i0y: i,
                    f0x: 1,
                    f0y: .85
                }), r, i)
            }
            u = new S({
                i0x: c,
                i0y: l,
                i1x: 0
            }), a.exposure.dispatch(new C().image(0, p).buffer(1, t.exposure).ubo(2, t.ubo), u, c / 2, l / 2), a.exposure.dispatch(new C().image(0, p).buffer(1, t.exposure).ubo(2, t.ubo), u.clone().set(`i1x`, 1), 1, 1), a.tonemap.dispatch(new C().image(0, p).sampler(1, o, t.bloomUp[1]).buffer(2, t.exposure).sampler(3, o, this.lut).ubo(4, t.ubo).image(5, t.output).image(6, t.cost), new S({
                i0x: c,
                i0y: l,
                i0z: this.frame & 2147483647
            }), c, l)
        }
    };
