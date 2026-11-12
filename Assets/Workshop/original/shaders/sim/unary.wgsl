struct Rng {
    s: u32,
}

struct Cell {
    mat: u32,
    variant: u32,
    flags: u32,
    temp: f32,
    life: u32,
    aux: u32,
    extra: u32,
}

struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Material {
    color_a: vec4<f32>,
    color_b: vec4<f32>,
    emission: vec4<f32>,
    phys: vec4<f32>,
    thermo: vec4<f32>,
    burn: vec4<f32>,
    optics: vec4<f32>,
    scatter: vec4<f32>,
    ids: vec4<u32>,
    ids2_: vec4<u32>,
    misc: vec4<f32>,
    surface: vec4<f32>,
    sss: vec4<f32>,
    sss_color: vec4<f32>,
    optics2_: vec4<f32>,
    pal0_: vec4<f32>,
    pal1_: vec4<f32>,
    pal2_: vec4<f32>,
    pal3_: vec4<f32>,
    accent: vec4<f32>,
    flame: vec4<f32>,
}

struct Materials {
    mats: array<Material>,
}

struct StatsBuf {
    hist: array<u32, 256>,
    reaction_count: array<u32, 1024>,
    ignite_count: array<u32, 256>,
    phase_hi: array<u32, 256>,
    phase_lo: array<u32, 256>,
    events: array<u32, 16>,
    ex_count: u32,
    ex_pad0_: u32,
    ex_pad1_: u32,
    ex_pad2_: u32,
    explosions: array<vec4<f32>, 64>,
}

struct ExGrid {
    ex_grid: array<u32>,
}

struct MediumSrc {
    msrc: array<u32>,
}

struct StatsBuf_1 {
    hist: array<atomic<u32>, 256>,
    reaction_count: array<u32, 1024>,
    ignite_count: array<atomic<u32>, 256>,
    phase_hi: array<atomic<u32>, 256>,
    phase_lo: array<atomic<u32>, 256>,
    events: array<atomic<u32>, 16>,
    ex_count: atomic<u32>,
    ex_pad0_: u32,
    ex_pad1_: u32,
    ex_pad2_: u32,
    explosions: array<vec4<f32>, 64>,
}

struct ExGrid_1 {
    ex_grid: array<atomic<u32>>,
}

struct MediumSrc_1 {
    msrc: array<atomic<u32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;
@group(0) @binding(2) 
var<storage> unnamed: Materials;
@group(0) @binding(3) 
var<storage, read_write> stats: StatsBuf_1;
@group(0) @binding(7) 
var<storage, read_write> unnamed_1: ExGrid_1;
@group(0) @binding(4) 
var<storage, read_write> unnamed_2: MediumSrc_1;
@group(0) @binding(5) 
var light_tex: texture_2d<f32>;
@group(2) @binding(5) 
var light_tex_smp: sampler;
@group(0) @binding(6) 
var day_tex: texture_2d<f32>;
@group(2) @binding(6) 
var day_tex_smp: sampler;
var<workgroup> sh_burning: atomic<u32>;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> sh_hist: array<atomic<u32>, 256>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e96 = (*c).mat;
    let _e99 = (*c).variant;
    let _e105 = (*c).flags;
    let _e111 = (*c).temp;
    let _e114 = (*c).life;
    let _e117 = (*c).aux;
    let _e123 = (*c).extra;
    return vec4<u32>((((_e96 & 255u) | ((_e99 & 255u) << bitcast<u32>(8u))) | ((_e105 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e111), ((_e114 & 65535u) | ((_e117 & 65535u) << bitcast<u32>(16u))), _e123);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p: ptr<function, vec2<i32>>, c_1: ptr<function, Cell>) {
    var param: Cell;

    let _e97 = (*p);
    let _e98 = (*c_1);
    param = _e98;
    let _e99 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param));
    textureStore(cells_out, _e97, _e99);
    return;
}

fn set_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b(c_2: ptr<function, Cell>, v: ptr<function, u32>) {
    let _e97 = (*c_2).extra;
    let _e99 = (*v);
    (*c_2).extra = ((_e97 & 4294967040u) | min(_e99, 255u));
    return;
}

fn cell_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c_3: ptr<function, Cell>) -> u32 {
    let _e96 = (*c_3).extra;
    return (_e96 & 255u);
}

fn add_explosion_u0028_vf2_u003b_f1_u003b_f1_u003b(pos: ptr<function, vec2<f32>>, radius: ptr<function, f32>, power: ptr<function, f32>) {
    var i: u32;
    var c_4: vec2<i32>;
    var key: u32;

    let _e101 = atomicAdd((&stats.ex_count), 1u);
    i = _e101;
    let _e102 = i;
    if (_e102 < 64u) {
        let _e104 = i;
        let _e105 = (*pos);
        let _e106 = (*radius);
        let _e107 = (*power);
        stats.explosions[_e104] = vec4<f32>(_e105.x, _e105.y, _e106, _e107);
    }
    let _e115 = atomicAdd((&stats.events[2i]), 1u);
    let _e116 = (*pos);
    let _e120 = pc.i0_;
    c_4 = clamp(vec2<i32>(floor(_e116)), vec2<i32>(0i, 0i), (_e120.xy - vec2(1i)));
    let _e125 = (*radius);
    let _e130 = (*power);
    key = ((u32(clamp(_e125, 1f, 255f)) << bitcast<u32>(16u)) | u32(clamp(round((_e130 * 256f)), 1f, 65535f)));
    let _e137 = c_4[1u];
    let _e140 = pc.i0_[0u];
    let _e143 = c_4[0u];
    let _e147 = key;
    let _e148 = atomicMax((&unnamed_1.ex_grid[((_e137 * _e140) + _e143)]), _e147);
    return;
}

fn det_floor_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e97 = (*a);
    if (_e97 >= 0i) {
        let _e99 = (*a);
        let _e100 = (*b);
        local = (_e99 / _e100);
    } else {
        let _e102 = (*a);
        let _e104 = (*b);
        let _e107 = (*b);
        local = -((((-(_e102) + _e104) - 1i) / _e107));
    }
    let _e110 = local;
    return _e110;
}

fn det_q_u0028_f1_u003b_f1_u003b(v_1: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e96 = (*v_1);
    let _e97 = (*scale);
    return i32(round((_e96 * _e97)));
}

fn emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b(cell: ptr<function, vec2<i32>>, channel: ptr<function, u32>, amount: ptr<function, f32>) {
    var mp: vec2<i32>;
    var mw: i32;
    var idx: u32;

    let _e100 = (*amount);
    if (_e100 <= 0f) {
        return;
    }
    let _e102 = (*cell);
    mp = (_e102 >> bitcast<vec2<u32>>(vec2(1i)));
    let _e108 = pc.i0_[0u];
    mw = (_e108 >> bitcast<u32>(1i));
    let _e112 = mp[1u];
    let _e113 = mw;
    let _e116 = mp[0u];
    let _e120 = (*channel);
    idx = ((bitcast<u32>(((_e112 * _e113) + _e116)) * 4u) + _e120);
    let _e122 = idx;
    let _e125 = (*amount);
    let _e128 = atomicAdd((&unnamed_2.msrc[_e122]), u32((_e125 * 1024f)));
    return;
}

fn det_div_u0028_i1_u003b_i1_u003b(a_1: ptr<function, i32>, b_1: ptr<function, i32>) -> i32 {
    var local_1: i32;

    let _e97 = (*a_1);
    if (_e97 >= 0i) {
        let _e99 = (*a_1);
        let _e100 = (*b_1);
        let _e103 = (*b_1);
        local_1 = ((_e99 + (_e100 / 2i)) / _e103);
    } else {
        let _e105 = (*a_1);
        let _e107 = (*b_1);
        let _e110 = (*b_1);
        local_1 = -(((-(_e105) + (_e107 / 2i)) / _e110));
    }
    let _e113 = local_1;
    return _e113;
}

fn det_scale_u0028_f1_u003b_i1_u003b_f1_u003b(v_2: ptr<function, f32>, f: ptr<function, i32>, scale_1: ptr<function, f32>) -> f32 {
    var param_1: f32;
    var param_2: f32;
    var param_3: i32;
    var param_4: i32;

    let _e101 = (*v_2);
    param_1 = _e101;
    let _e102 = (*scale_1);
    param_2 = _e102;
    let _e103 = det_q_u0028_f1_u003b_f1_u003b((&param_1), (&param_2));
    let _e104 = (*f);
    param_3 = (_e103 * _e104);
    param_4 = 4096i;
    let _e106 = det_div_u0028_i1_u003b_i1_u003b((&param_3), (&param_4));
    let _e108 = (*scale_1);
    return (f32(_e106) / _e108);
}

fn det_jit_u0028_f1_u003b_f1_u003b_u1_u003b(a_2: ptr<function, f32>, b_2: ptr<function, f32>, bits: ptr<function, u32>) -> i32 {
    var param_5: f32;
    var param_6: f32;
    var param_7: f32;
    var param_8: f32;
    var param_9: i32;
    var param_10: i32;

    let _e103 = (*a_2);
    param_5 = _e103;
    param_6 = 4096f;
    let _e104 = det_q_u0028_f1_u003b_f1_u003b((&param_5), (&param_6));
    let _e105 = (*b_2);
    param_7 = _e105;
    param_8 = 4096f;
    let _e106 = det_q_u0028_f1_u003b_f1_u003b((&param_7), (&param_8));
    let _e107 = (*bits);
    param_9 = (_e106 * bitcast<i32>((_e107 >> bitcast<u32>(20u))));
    param_10 = 4096i;
    let _e112 = det_div_u0028_i1_u003b_i1_u003b((&param_9), (&param_10));
    return (_e104 + _e112);
}

fn rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b(r: ptr<function, Rng>) -> u32 {
    let _e96 = (*r).s;
    let _e100 = (*r).s;
    (*r).s = (_e100 ^ (_e96 << bitcast<u32>(13u)));
    let _e104 = (*r).s;
    let _e108 = (*r).s;
    (*r).s = (_e108 ^ (_e104 >> bitcast<u32>(17u)));
    let _e112 = (*r).s;
    let _e116 = (*r).s;
    (*r).s = (_e116 ^ (_e112 << bitcast<u32>(5u)));
    let _e120 = (*r).s;
    return _e120;
}

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e95 = (*x);
    return (f32((_e95 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b(r_1: ptr<function, Rng>) -> f32 {
    var param_11: Rng;
    var param_12: u32;

    let _e97 = (*r_1);
    param_11 = _e97;
    let _e98 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_11));
    let _e99 = param_11;
    (*r_1) = _e99;
    param_12 = _e98;
    let _e100 = u01_u0028_u1_u003b((&param_12));
    return _e100;
}

fn make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b(mat: ptr<function, u32>, r_2: ptr<function, Rng>) -> Cell {
    var m: Material;
    var c_5: Cell;
    var param_13: Rng;
    var local_2: f32;
    var li: f32;
    var local_3: u32;
    var param_14: Rng;

    let _e103 = (*mat);
    let _e106 = unnamed.mats[_e103];
    m.color_a = _e106.color_a;
    m.color_b = _e106.color_b;
    m.emission = _e106.emission;
    m.phys = _e106.phys;
    m.thermo = _e106.thermo;
    m.burn = _e106.burn;
    m.optics = _e106.optics;
    m.scatter = _e106.scatter;
    m.ids = _e106.ids;
    m.ids2_ = _e106.ids2_;
    m.misc = _e106.misc;
    m.surface = _e106.surface;
    m.sss = _e106.sss;
    m.sss_color = _e106.sss_color;
    m.optics2_ = _e106.optics2_;
    m.pal0_ = _e106.pal0_;
    m.pal1_ = _e106.pal1_;
    m.pal2_ = _e106.pal2_;
    m.pal3_ = _e106.pal3_;
    m.accent = _e106.accent;
    m.flame = _e106.flame;
    let _e149 = (*mat);
    c_5.mat = _e149;
    let _e151 = (*r_2);
    param_13 = _e151;
    let _e152 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_13));
    let _e153 = param_13;
    (*r_2) = _e153;
    c_5.variant = (_e152 & 255u);
    c_5.flags = 0u;
    let _e159 = m.misc[0u];
    if (_e159 > 0f) {
        let _e163 = m.misc[0u];
        local_2 = _e163;
    } else {
        local_2 = 293f;
    }
    let _e164 = local_2;
    c_5.temp = _e164;
    let _e168 = m.misc[1u];
    li = _e168;
    let _e169 = li;
    if (_e169 > 0f) {
        let _e171 = li;
        let _e172 = (*r_2);
        param_14 = _e172;
        let _e173 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_14));
        let _e174 = param_14;
        (*r_2) = _e174;
        local_3 = u32((_e171 * (0.5f + _e173)));
    } else {
        local_3 = 0u;
    }
    let _e178 = local_3;
    c_5.life = _e178;
    c_5.aux = 0u;
    c_5.extra = 0u;
    let _e182 = c_5;
    return _e182;
}

fn transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b(c_6: ptr<function, Cell>, mat_1: ptr<function, u32>, r_3: ptr<function, Rng>) {
    var t: f32;
    var param_15: u32;
    var param_16: Rng;

    let _e101 = (*c_6).temp;
    t = _e101;
    let _e102 = (*mat_1);
    param_15 = _e102;
    let _e103 = (*r_3);
    param_16 = _e103;
    let _e104 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_15), (&param_16));
    let _e105 = param_16;
    (*r_3) = _e105;
    (*c_6) = _e104;
    let _e106 = t;
    (*c_6).temp = _e106;
    return;
}

fn set_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b(c_7: ptr<function, Cell>, v_3: ptr<function, u32>) {
    let _e97 = (*c_7).flags;
    let _e99 = (*v_3);
    (*c_7).flags = ((_e97 & 4294967267u) | (min(_e99, 7u) << bitcast<u32>(2u)));
    return;
}

fn cell_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c_8: ptr<function, Cell>) -> u32 {
    let _e96 = (*c_8).flags;
    return ((_e96 & 28u) >> bitcast<u32>(2u));
}

fn pcg3d_u0028_vu3_u003b(v_4: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e95 = (*v_4);
    (*v_4) = ((_e95 * vec3(1664525u)) + vec3(1013904223u));
    let _e101 = (*v_4)[1u];
    let _e103 = (*v_4)[2u];
    let _e106 = (*v_4)[0u];
    (*v_4)[0u] = (_e106 + (_e101 * _e103));
    let _e110 = (*v_4)[2u];
    let _e112 = (*v_4)[0u];
    let _e115 = (*v_4)[1u];
    (*v_4)[1u] = (_e115 + (_e110 * _e112));
    let _e119 = (*v_4)[0u];
    let _e121 = (*v_4)[1u];
    let _e124 = (*v_4)[2u];
    (*v_4)[2u] = (_e124 + (_e119 * _e121));
    let _e127 = (*v_4);
    let _e131 = (*v_4);
    (*v_4) = (_e131 ^ (_e127 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e134 = (*v_4)[1u];
    let _e136 = (*v_4)[2u];
    let _e139 = (*v_4)[0u];
    (*v_4)[0u] = (_e139 + (_e134 * _e136));
    let _e143 = (*v_4)[2u];
    let _e145 = (*v_4)[0u];
    let _e148 = (*v_4)[1u];
    (*v_4)[1u] = (_e148 + (_e143 * _e145));
    let _e152 = (*v_4)[0u];
    let _e154 = (*v_4)[1u];
    let _e157 = (*v_4)[2u];
    (*v_4)[2u] = (_e157 + (_e152 * _e154));
    let _e160 = (*v_4);
    return _e160;
}

fn rng_init_u0028_vu3_u003b(seed: ptr<function, vec3<u32>>) -> Rng {
    var r_4: Rng;
    var param_17: vec3<u32>;

    let _e97 = (*seed);
    param_17 = _e97;
    let _e98 = pcg3d_u0028_vu3_u003b((&param_17));
    r_4.s = (_e98.x | 1u);
    let _e102 = r_4;
    return _e102;
}

fn process_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p_1: ptr<function, vec2<i32>>, c_9: ptr<function, Cell>) -> Cell {
    var m_1: Material;
    var fl: u32;
    var r_5: Rng;
    var param_18: vec3<u32>;
    var f_1: u32;
    var param_19: Cell;
    var param_20: Cell;
    var param_21: u32;
    var uv: vec2<f32>;
    var Lf: vec3<f32>;
    var Ld: vec3<f32>;
    var pump: f32;
    var cap: f32;
    var gain: f32;
    var life: f32;
    var param_22: Rng;
    var param_23: Cell;
    var param_24: u32;
    var param_25: Rng;
    var param_26: Rng;
    var param_27: f32;
    var param_28: f32;
    var param_29: u32;
    var param_30: f32;
    var param_31: i32;
    var param_32: f32;
    var param_33: Rng;
    var param_34: vec2<i32>;
    var param_35: u32;
    var param_36: f32;
    var fa: f32;
    var param_37: vec2<i32>;
    var param_38: u32;
    var param_39: f32;
    var fc: vec3<f32>;
    var hue: f32;
    var local_4: f32;
    var param_40: vec2<i32>;
    var param_41: u32;
    var param_42: f32;
    var param_43: Rng;
    var param_44: vec2<i32>;
    var param_45: u32;
    var param_46: f32;
    var burning: bool;
    var param_47: f32;
    var param_48: f32;
    var param_49: Rng;
    var param_50: f32;
    var param_51: f32;
    var param_52: u32;
    var param_53: i32;
    var param_54: i32;
    var param_55: Rng;
    var param_56: vec2<f32>;
    var param_57: f32;
    var param_58: f32;
    var param_59: Rng;
    var param_60: f32;
    var param_61: f32;
    var param_62: u32;
    var param_63: f32;
    var param_64: i32;
    var param_65: f32;
    var param_66: Rng;
    var param_67: vec2<i32>;
    var param_68: u32;
    var param_69: f32;
    var fa_1: f32;
    var param_70: Rng;
    var param_71: vec2<i32>;
    var param_72: u32;
    var param_73: f32;
    var hue_1: f32;
    var local_5: f32;
    var param_74: vec2<i32>;
    var param_75: u32;
    var param_76: f32;
    var to: u32;
    var param_77: Cell;
    var param_78: u32;
    var param_79: Rng;
    var param_80: Cell;
    var param_81: u32;
    var hi: f32;
    var lo: f32;
    var latent: f32;
    var from_: u32;
    var to_1: u32;
    var param_82: Rng;
    var param_83: Cell;
    var param_84: u32;
    var param_85: Rng;
    var param_86: vec2<i32>;
    var param_87: u32;
    var param_88: f32;
    var from_1: u32;
    var param_89: Cell;
    var param_90: u32;
    var param_91: Rng;
    var phi_966_: bool;
    var phi_1019_: bool;
    var phi_1053_: bool;
    var phi_1081_: bool;
    var phi_1129_: bool;
    var phi_1216_: bool;
    var phi_1298_: bool;
    var phi_1339_: bool;
    var phi_1385_: bool;

    let _e197 = (*c_9).mat;
    let _e200 = unnamed.mats[_e197];
    m_1.color_a = _e200.color_a;
    m_1.color_b = _e200.color_b;
    m_1.emission = _e200.emission;
    m_1.phys = _e200.phys;
    m_1.thermo = _e200.thermo;
    m_1.burn = _e200.burn;
    m_1.optics = _e200.optics;
    m_1.scatter = _e200.scatter;
    m_1.ids = _e200.ids;
    m_1.ids2_ = _e200.ids2_;
    m_1.misc = _e200.misc;
    m_1.surface = _e200.surface;
    m_1.sss = _e200.sss;
    m_1.sss_color = _e200.sss_color;
    m_1.optics2_ = _e200.optics2_;
    m_1.pal0_ = _e200.pal0_;
    m_1.pal1_ = _e200.pal1_;
    m_1.pal2_ = _e200.pal2_;
    m_1.pal3_ = _e200.pal3_;
    m_1.accent = _e200.accent;
    m_1.flame = _e200.flame;
    let _e245 = m_1.ids[1u];
    fl = _e245;
    let _e246 = (*p_1);
    let _e247 = bitcast<vec2<u32>>(_e246);
    let _e250 = pc.i0_[2u];
    param_18 = vec3<u32>(_e247.x, _e247.y, ((bitcast<u32>(_e250) * 13u) + 5u));
    let _e257 = rng_init_u0028_vu3_u003b((&param_18));
    r_5 = _e257;
    let _e258 = (*c_9);
    param_19 = _e258;
    let _e259 = cell_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_19));
    f_1 = _e259;
    let _e260 = f_1;
    if (_e260 > 0u) {
        let _e262 = f_1;
        let _e264 = (*c_9);
        param_20 = _e264;
        param_21 = (_e262 - 1u);
        set_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b((&param_20), (&param_21));
        let _e265 = param_20;
        (*c_9) = _e265;
    }
    let _e266 = fl;
    if ((_e266 & 128u) != 0u) {
        let _e269 = (*p_1);
        let _e274 = pc.i0_;
        uv = ((vec2<f32>(_e269) + vec2(0.5f)) / vec2<f32>(_e274.xy));
        let _e278 = uv;
        let _e279 = textureSampleLevel(light_tex, light_tex_smp, _e278, 0f);
        Lf = _e279.xyz;
        let _e281 = uv;
        let _e282 = textureSampleLevel(day_tex, day_tex_smp, _e281, 0f);
        Ld = _e282.xyz;
        let _e284 = Lf;
        let _e288 = Ld;
        pump = (max((dot(_e284, vec3<f32>(0.3f, 0.5f, 0.2f)) - 0.6f), 0f) + dot(_e288, vec3<f32>(0.3f, 0.5f, 0.2f)));
        let _e293 = m_1.misc[1u];
        cap = _e293;
        let _e294 = pump;
        let _e295 = cap;
        gain = ((_e294 * _e295) * 0.004f);
        let _e299 = (*c_9).life;
        let _e301 = gain;
        life = (f32(_e299) + _e301);
        let _e303 = r_5;
        param_22 = _e303;
        let _e304 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_22));
        let _e305 = param_22;
        r_5 = _e305;
        if (_e304 < 0.5f) {
            let _e307 = life;
            life = (_e307 - 1f);
        }
        let _e309 = life;
        let _e310 = cap;
        (*c_9).life = u32(clamp(_e309, 0f, _e310));
    } else {
        let _e314 = fl;
        if ((_e314 & 8u) != 0u) {
            let _e318 = (*c_9).life;
            if (_e318 <= 1u) {
                let _e320 = (*c_9);
                param_23 = _e320;
                let _e323 = m_1.ids2_[2u];
                param_24 = _e323;
                let _e324 = r_5;
                param_25 = _e324;
                transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_23), (&param_24), (&param_25));
                let _e325 = param_23;
                (*c_9) = _e325;
                let _e326 = param_25;
                r_5 = _e326;
                let _e327 = (*c_9);
                return _e327;
            }
            let _e329 = (*c_9).life;
            (*c_9).life = (_e329 - 1u);
        }
    }
    let _e332 = fl;
    if ((_e332 & 64u) != 0u) {
        let _e336 = (*c_9).temp;
        let _e337 = r_5;
        param_26 = _e337;
        let _e338 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_26));
        let _e339 = param_26;
        r_5 = _e339;
        param_27 = 0.85f;
        param_28 = 0.15f;
        param_29 = _e338;
        let _e340 = det_jit_u0028_f1_u003b_f1_u003b_u1_u003b((&param_27), (&param_28), (&param_29));
        let _e343 = m_1.burn[1u];
        param_30 = _e343;
        param_31 = _e340;
        param_32 = 64f;
        let _e344 = det_scale_u0028_f1_u003b_i1_u003b_f1_u003b((&param_30), (&param_31), (&param_32));
        (*c_9).temp = max(_e336, _e344);
    }
    let _e347 = fl;
    let _e349 = ((_e347 & 32u) != 0u);
    phi_966_ = _e349;
    if _e349 {
        let _e350 = r_5;
        param_33 = _e350;
        let _e351 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_33));
        let _e352 = param_33;
        r_5 = _e352;
        phi_966_ = (_e351 < 0.25f);
    }
    let _e355 = phi_966_;
    if _e355 {
        let _e356 = (*p_1);
        param_34 = _e356;
        param_35 = 0u;
        let _e359 = m_1.scatter[3u];
        param_36 = _e359;
        emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_34), (&param_35), (&param_36));
    }
    let _e360 = fl;
    if ((_e360 & 64u) != 0u) {
        let _e364 = (*c_9).life;
        let _e369 = m_1.misc[1u];
        fa = ((0.35f * f32(_e364)) / max(_e369, 1f));
        let _e372 = (*p_1);
        param_37 = _e372;
        param_38 = 2u;
        let _e373 = fa;
        param_39 = _e373;
        emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_37), (&param_38), (&param_39));
        let _e375 = (*c_9).flags;
        if ((_e375 & 128u) != 0u) {
            let _e379 = (*c_9).variant;
            let _e383 = unnamed.mats[_e379].flame;
            fc = _e383.xyz;
            let _e386 = fc[0u];
            let _e387 = (_e386 > 0.8f);
            phi_1019_ = _e387;
            if _e387 {
                let _e389 = fc[2u];
                phi_1019_ = (_e389 > 0.8f);
            }
            let _e392 = phi_1019_;
            if _e392 {
                local_4 = 1f;
            } else {
                let _e394 = fc[2u];
                let _e396 = fc[0u];
                local_4 = select(0f, 0.5f, (_e394 > _e396));
            }
            let _e399 = local_4;
            hue = _e399;
            let _e400 = hue;
            if (_e400 > 0f) {
                let _e402 = fa;
                let _e403 = hue;
                let _e405 = (*p_1);
                param_40 = _e405;
                param_41 = 3u;
                param_42 = (_e402 * _e403);
                emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_40), (&param_41), (&param_42));
            }
        }
    }
    let _e406 = fl;
    let _e408 = ((_e406 & 16u) != 0u);
    phi_1053_ = _e408;
    if _e408 {
        let _e409 = r_5;
        param_43 = _e409;
        let _e410 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_43));
        let _e411 = param_43;
        r_5 = _e411;
        phi_1053_ = (_e410 < 0.25f);
    }
    let _e414 = phi_1053_;
    if _e414 {
        let _e415 = (*p_1);
        param_44 = _e415;
        param_45 = 1u;
        param_46 = 0.12f;
        emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_44), (&param_45), (&param_46));
    }
    let _e417 = (*c_9).flags;
    burning = ((_e417 & 1u) != 0u);
    let _e420 = fl;
    let _e423 = burning;
    let _e425 = (((_e420 & 1u) != 0u) && !(_e423));
    phi_1081_ = _e425;
    if _e425 {
        let _e427 = (*c_9).temp;
        let _e430 = m_1.burn[0u];
        phi_1081_ = (_e427 >= _e430);
    }
    let _e433 = phi_1081_;
    if _e433 {
        burning = true;
        let _e435 = (*c_9).flags;
        (*c_9).flags = (_e435 | 1u);
        let _e440 = m_1.burn[2u];
        param_47 = _e440;
        param_48 = 16f;
        let _e441 = det_q_u0028_f1_u003b_f1_u003b((&param_47), (&param_48));
        let _e442 = r_5;
        param_49 = _e442;
        let _e443 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_49));
        let _e444 = param_49;
        r_5 = _e444;
        param_50 = 0.6f;
        param_51 = 0.8f;
        param_52 = _e443;
        let _e445 = det_jit_u0028_f1_u003b_f1_u003b_u1_u003b((&param_50), (&param_51), (&param_52));
        param_53 = (_e441 * _e445);
        param_54 = 65536i;
        let _e447 = det_floor_div_u0028_i1_u003b_i1_u003b((&param_53), (&param_54));
        (*c_9).life = bitcast<u32>(max(_e447, 1i));
        let _e452 = (*c_9).mat;
        let _e455 = atomicAdd((&stats.ignite_count[_e452]), 1u);
        let _e458 = atomicAdd((&stats.events[7i]), 1u);
        let _e459 = fl;
        let _e461 = ((_e459 & 2u) != 0u);
        phi_1129_ = _e461;
        if _e461 {
            let _e462 = r_5;
            param_55 = _e462;
            let _e463 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_55));
            let _e464 = param_55;
            r_5 = _e464;
            let _e467 = m_1.misc[3u];
            phi_1129_ = (_e463 < _e467);
        }
        let _e470 = phi_1129_;
        if _e470 {
            let _e471 = (*p_1);
            let _e477 = m_1.ids2_[3u];
            param_56 = (vec2<f32>(_e471) + vec2(0.5f));
            param_57 = f32(_e477);
            param_58 = 1f;
            add_explosion_u0028_vf2_u003b_f1_u003b_f1_u003b((&param_56), (&param_57), (&param_58));
        }
    }
    let _e479 = burning;
    if _e479 {
        let _e480 = atomicAdd((&sh_burning), 1u);
        let _e482 = (*c_9).temp;
        let _e483 = r_5;
        param_59 = _e483;
        let _e484 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_59));
        let _e485 = param_59;
        r_5 = _e485;
        param_60 = 0.9f;
        param_61 = 0.1f;
        param_62 = _e484;
        let _e486 = det_jit_u0028_f1_u003b_f1_u003b_u1_u003b((&param_60), (&param_61), (&param_62));
        let _e489 = m_1.burn[1u];
        param_63 = _e489;
        param_64 = _e486;
        param_65 = 64f;
        let _e490 = det_scale_u0028_f1_u003b_i1_u003b_f1_u003b((&param_63), (&param_64), (&param_65));
        (*c_9).temp = max(_e482, _e490);
        let _e493 = r_5;
        param_66 = _e493;
        let _e494 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_66));
        let _e495 = param_66;
        r_5 = _e495;
        if (_e494 < 0.3f) {
            let _e499 = m_1.scatter[3u];
            let _e501 = (*p_1);
            param_67 = _e501;
            param_68 = 0u;
            param_69 = (_e499 * 0.5f);
            emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_67), (&param_68), (&param_69));
        }
        let _e502 = r_5;
        param_70 = _e502;
        let _e503 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_70));
        let _e504 = param_70;
        r_5 = _e504;
        fa_1 = (0.5f + (0.5f * _e503));
        let _e507 = (*p_1);
        param_71 = _e507;
        param_72 = 2u;
        let _e508 = fa_1;
        param_73 = _e508;
        emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_71), (&param_72), (&param_73));
        let _e510 = m_1.flame;
        let _e513 = m_1.flame;
        if (dot(_e510.xyz, _e513.xyz) > 0f) {
            let _e519 = m_1.flame[0u];
            let _e520 = (_e519 > 0.8f);
            phi_1216_ = _e520;
            if _e520 {
                let _e523 = m_1.flame[2u];
                phi_1216_ = (_e523 > 0.8f);
            }
            let _e526 = phi_1216_;
            if _e526 {
                local_5 = 1f;
            } else {
                let _e529 = m_1.flame[2u];
                let _e532 = m_1.flame[0u];
                local_5 = select(0f, 0.5f, (_e529 > _e532));
            }
            let _e535 = local_5;
            hue_1 = _e535;
            let _e536 = hue_1;
            if (_e536 > 0f) {
                let _e538 = fa_1;
                let _e539 = hue_1;
                let _e541 = (*p_1);
                param_74 = _e541;
                param_75 = 3u;
                param_76 = (_e538 * _e539);
                emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_74), (&param_75), (&param_76));
            }
        }
        let _e543 = (*c_9).life;
        if (_e543 <= 1u) {
            let _e546 = (*c_9).flags;
            (*c_9).flags = (_e546 & 4294967294u);
            let _e551 = m_1.ids2_[0u];
            to = _e551;
            let _e552 = to;
            let _e554 = (*c_9).mat;
            if (_e552 != _e554) {
                let _e556 = (*c_9);
                param_77 = _e556;
                let _e557 = to;
                param_78 = _e557;
                let _e558 = r_5;
                param_79 = _e558;
                transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_77), (&param_78), (&param_79));
                let _e559 = param_77;
                (*c_9) = _e559;
                let _e560 = param_79;
                r_5 = _e560;
            }
            let _e561 = (*c_9);
            param_80 = _e561;
            param_81 = 2u;
            set_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b((&param_80), (&param_81));
            let _e562 = param_80;
            (*c_9) = _e562;
            let _e563 = (*c_9);
            return _e563;
        }
        let _e565 = (*c_9).life;
        (*c_9).life = (_e565 - 1u);
        let _e568 = (*c_9);
        return _e568;
    }
    let _e571 = m_1.thermo[2u];
    hi = _e571;
    let _e574 = m_1.thermo[3u];
    lo = _e574;
    let _e577 = m_1.burn[3u];
    latent = _e577;
    let _e578 = hi;
    let _e579 = (_e578 > 0f);
    phi_1298_ = _e579;
    if _e579 {
        let _e581 = (*c_9).temp;
        let _e582 = hi;
        phi_1298_ = (_e581 > _e582);
    }
    let _e585 = phi_1298_;
    if _e585 {
        let _e587 = (*c_9).aux;
        let _e589 = (*c_9).temp;
        let _e590 = hi;
        (*c_9).aux = min((_e587 + u32(((_e589 - _e590) + 1f))), 65535u);
        let _e597 = hi;
        (*c_9).temp = _e597;
        let _e600 = (*c_9).aux;
        let _e602 = latent;
        if (f32(_e600) >= _e602) {
            let _e605 = (*c_9).mat;
            from_ = _e605;
            let _e608 = m_1.ids[2u];
            to_1 = _e608;
            let _e611 = m_1.ids2_[1u];
            let _e612 = (_e611 != 65535u);
            phi_1339_ = _e612;
            if _e612 {
                let _e613 = r_5;
                param_82 = _e613;
                let _e614 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_82));
                let _e615 = param_82;
                r_5 = _e615;
                let _e618 = m_1.misc[2u];
                phi_1339_ = (_e614 < _e618);
            }
            let _e621 = phi_1339_;
            if _e621 {
                let _e624 = m_1.ids2_[1u];
                to_1 = _e624;
            }
            let _e625 = (*c_9);
            param_83 = _e625;
            let _e626 = to_1;
            param_84 = _e626;
            let _e627 = r_5;
            param_85 = _e627;
            transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_83), (&param_84), (&param_85));
            let _e628 = param_83;
            (*c_9) = _e628;
            let _e629 = param_85;
            r_5 = _e629;
            let _e630 = hi;
            (*c_9).temp = (_e630 + 15f);
            let _e633 = from_;
            let _e636 = atomicAdd((&stats.phase_hi[_e633]), 1u);
            let _e639 = m_1.ids[0u];
            let _e644 = atomicAdd((&stats.events[select(5i, 1i, (_e639 == 1u))]), 1u);
            let _e647 = m_1.ids[0u];
            if (_e647 == 1u) {
                let _e649 = (*p_1);
                param_86 = _e649;
                param_87 = 1u;
                param_88 = 0.6f;
                emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_86), (&param_87), (&param_88));
            }
        }
    } else {
        let _e650 = lo;
        let _e651 = (_e650 > 0f);
        phi_1385_ = _e651;
        if _e651 {
            let _e653 = (*c_9).temp;
            let _e654 = lo;
            phi_1385_ = (_e653 < _e654);
        }
        let _e657 = phi_1385_;
        if _e657 {
            let _e659 = (*c_9).aux;
            let _e660 = lo;
            let _e662 = (*c_9).temp;
            (*c_9).aux = min((_e659 + u32(((_e660 - _e662) + 1f))), 65535u);
            let _e669 = lo;
            (*c_9).temp = _e669;
            let _e672 = (*c_9).aux;
            let _e674 = latent;
            if (f32(_e672) >= _e674) {
                let _e677 = (*c_9).mat;
                from_1 = _e677;
                let _e678 = (*c_9);
                param_89 = _e678;
                let _e681 = m_1.ids[3u];
                param_90 = _e681;
                let _e682 = r_5;
                param_91 = _e682;
                transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_89), (&param_90), (&param_91));
                let _e683 = param_89;
                (*c_9) = _e683;
                let _e684 = param_91;
                r_5 = _e684;
                let _e685 = lo;
                (*c_9).temp = (_e685 - 5f);
                let _e688 = from_1;
                let _e691 = atomicAdd((&stats.phase_lo[_e688]), 1u);
                let _e694 = atomicAdd((&stats.events[6i]), 1u);
            }
        } else {
            let _e696 = (*c_9).aux;
            if (_e696 > 0u) {
                let _e699 = (*c_9).aux;
                (*c_9).aux = (_e699 - 1u);
            }
        }
    }
    let _e702 = (*c_9);
    return _e702;
}

fn unpack_cell_u0028_vu4_u003b(v_5: ptr<function, vec4<u32>>) -> Cell {
    var c_10: Cell;

    let _e97 = (*v_5)[0u];
    c_10.mat = (_e97 & 255u);
    let _e101 = (*v_5)[0u];
    c_10.variant = ((_e101 >> bitcast<u32>(8u)) & 255u);
    let _e107 = (*v_5)[0u];
    c_10.flags = (_e107 >> bitcast<u32>(16u));
    let _e112 = (*v_5)[1u];
    c_10.temp = bitcast<f32>(_e112);
    let _e116 = (*v_5)[2u];
    c_10.life = (_e116 & 65535u);
    let _e120 = (*v_5)[2u];
    c_10.aux = (_e120 >> bitcast<u32>(16u));
    let _e125 = (*v_5)[3u];
    c_10.extra = _e125;
    let _e127 = c_10;
    return _e127;
}

fn load_cell_u0028_vi2_u003b(p_2: ptr<function, vec2<i32>>) -> Cell {
    var param_92: vec4<u32>;

    let _e96 = (*p_2);
    let _e97 = textureLoad(cells_in, _e96, 0i);
    param_92 = _e97;
    let _e98 = unpack_cell_u0028_vu4_u003b((&param_92));
    return _e98;
}

fn in_world_u0028_vi2_u003b(p_3: ptr<function, vec2<i32>>) -> bool {
    var phi_272_: bool;
    var phi_286_: bool;
    var phi_294_: bool;

    let _e96 = (*p_3)[0u];
    let _e97 = (_e96 >= 0i);
    phi_272_ = _e97;
    if _e97 {
        let _e99 = (*p_3)[1u];
        phi_272_ = (_e99 >= 0i);
    }
    let _e102 = phi_272_;
    phi_286_ = _e102;
    if _e102 {
        let _e104 = (*p_3)[0u];
        let _e107 = pc.i0_[0u];
        phi_286_ = (_e104 < _e107);
    }
    let _e110 = phi_286_;
    phi_294_ = _e110;
    if _e110 {
        let _e112 = (*p_3)[1u];
        let _e115 = pc.i0_[1u];
        phi_294_ = (_e112 < _e115);
    }
    let _e118 = phi_294_;
    return _e118;
}

fn main_1() {
    var li_1: u32;
    var k: u32;
    var p_4: vec2<i32>;
    var param_93: vec2<i32>;
    var c_11: Cell;
    var param_94: vec2<i32>;
    var param_95: vec2<i32>;
    var param_96: Cell;
    var ag: u32;
    var param_97: Cell;
    var local_6: u32;
    var param_98: Cell;
    var param_99: u32;
    var param_100: vec2<i32>;
    var param_101: Cell;
    var k_1: u32;
    var phi_1547_: bool;

    let _e110 = gl_LocalInvocationIndex_1;
    li_1 = _e110;
    let _e111 = li_1;
    k = _e111;
    loop {
        let _e112 = k;
        if (_e112 < 256u) {
            let _e114 = k;
            atomicStore((&sh_hist[_e114]), 0u);
            continue;
        } else {
            break;
        }
        continuing {
            let _e116 = k;
            k = (_e116 + 64u);
        }
    }
    let _e118 = li_1;
    if (_e118 == 0u) {
        atomicStore((&sh_burning), 0u);
    }
    workgroupBarrier();
    let _e120 = gl_GlobalInvocationID_1;
    p_4 = bitcast<vec2<i32>>(_e120.xy);
    let _e123 = p_4;
    param_93 = _e123;
    let _e124 = in_world_u0028_vi2_u003b((&param_93));
    if _e124 {
        let _e125 = p_4;
        param_94 = _e125;
        let _e126 = load_cell_u0028_vi2_u003b((&param_94));
        let _e127 = p_4;
        param_95 = _e127;
        param_96 = _e126;
        let _e128 = process_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_95), (&param_96));
        c_11 = _e128;
        let _e129 = c_11;
        param_97 = _e129;
        let _e130 = cell_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_97));
        ag = _e130;
        let _e131 = ag;
        if (_e131 > 0u) {
            let _e133 = ag;
            if (_e133 > 5u) {
                let _e135 = ag;
                local_6 = (_e135 - 5u);
            } else {
                local_6 = 0u;
            }
            let _e137 = c_11;
            param_98 = _e137;
            let _e138 = local_6;
            param_99 = _e138;
            set_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b((&param_98), (&param_99));
            let _e139 = param_98;
            c_11 = _e139;
        }
        let _e140 = p_4;
        param_100 = _e140;
        let _e141 = c_11;
        param_101 = _e141;
        store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_100), (&param_101));
        let _e143 = c_11.mat;
        let _e145 = atomicAdd((&sh_hist[_e143]), 1u);
    }
    workgroupBarrier();
    let _e146 = li_1;
    k_1 = _e146;
    loop {
        let _e147 = k_1;
        if (_e147 < 256u) {
            let _e149 = k_1;
            let _e151 = atomicLoad((&sh_hist[_e149]));
            if (_e151 > 0u) {
                let _e153 = k_1;
                let _e156 = k_1;
                let _e158 = atomicLoad((&sh_hist[_e156]));
                let _e159 = atomicAdd((&stats.hist[_e153]), _e158);
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e160 = k_1;
            k_1 = (_e160 + 64u);
        }
    }
    let _e162 = li_1;
    let _e163 = (_e162 == 0u);
    phi_1547_ = _e163;
    if _e163 {
        let _e164 = atomicLoad((&sh_burning));
        phi_1547_ = (_e164 > 0u);
    }
    let _e167 = phi_1547_;
    if _e167 {
        let _e170 = atomicLoad((&sh_burning));
        let _e171 = atomicAdd((&stats.events[0i]), _e170);
    }
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(local_invocation_index) gl_LocalInvocationIndex: u32, @builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
