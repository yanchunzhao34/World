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

struct Command {
    a: vec4<i32>,
    b: vec4<f32>,
    c: vec4<f32>,
    d: vec4<f32>,
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

struct Commands {
    cmd_header: vec4<u32>,
    cmds: array<Command>,
}

struct StatsBuf_1 {
    hist: array<u32, 256>,
    reaction_count: array<atomic<u32>, 1024>,
    ignite_count: array<u32, 256>,
    phase_hi: array<u32, 256>,
    phase_lo: array<u32, 256>,
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

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;
@group(0) @binding(2) 
var<storage> unnamed: Materials;
@group(0) @binding(4) 
var<storage, read_write> stats: StatsBuf_1;
@group(0) @binding(5) 
var<storage, read_write> unnamed_1: ExGrid_1;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
@group(0) @binding(3) 
var<storage> unnamed_2: Commands;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e70 = (*c).mat;
    let _e73 = (*c).variant;
    let _e79 = (*c).flags;
    let _e85 = (*c).temp;
    let _e88 = (*c).life;
    let _e91 = (*c).aux;
    let _e97 = (*c).extra;
    return vec4<u32>((((_e70 & 255u) | ((_e73 & 255u) << bitcast<u32>(8u))) | ((_e79 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e85), ((_e88 & 65535u) | ((_e91 & 65535u) << bitcast<u32>(16u))), _e97);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p: ptr<function, vec2<i32>>, c_1: ptr<function, Cell>) {
    var param: Cell;

    let _e71 = (*p);
    let _e72 = (*c_1);
    param = _e72;
    let _e73 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param));
    textureStore(cells_out, _e71, _e73);
    return;
}

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e71 = (*a);
    if (_e71 >= 0i) {
        let _e73 = (*a);
        let _e74 = (*b);
        let _e77 = (*b);
        local = ((_e73 + (_e74 / 2i)) / _e77);
    } else {
        let _e79 = (*a);
        let _e81 = (*b);
        let _e84 = (*b);
        local = -(((-(_e79) + (_e81 / 2i)) / _e84));
    }
    let _e87 = local;
    return _e87;
}

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e69 = (*x);
    return (f32((_e69 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b(r: ptr<function, Rng>) -> u32 {
    let _e70 = (*r).s;
    let _e74 = (*r).s;
    (*r).s = (_e74 ^ (_e70 << bitcast<u32>(13u)));
    let _e78 = (*r).s;
    let _e82 = (*r).s;
    (*r).s = (_e82 ^ (_e78 >> bitcast<u32>(17u)));
    let _e86 = (*r).s;
    let _e90 = (*r).s;
    (*r).s = (_e90 ^ (_e86 << bitcast<u32>(5u)));
    let _e94 = (*r).s;
    return _e94;
}

fn rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b(r_1: ptr<function, Rng>) -> f32 {
    var param_1: Rng;
    var param_2: u32;

    let _e71 = (*r_1);
    param_1 = _e71;
    let _e72 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_1));
    let _e73 = param_1;
    (*r_1) = _e73;
    param_2 = _e72;
    let _e74 = u01_u0028_u1_u003b((&param_2));
    return _e74;
}

fn clipped_u0028_vf2_u003b_struct_u002d_Command_u002d_vi4_u002d_vf4_u002d_vf4_u002d_vf41_u003b(p_1: ptr<function, vec2<f32>>, c_2: ptr<function, Command>) -> bool {
    var phi_714_: bool;
    var phi_723_: bool;
    var phi_732_: bool;
    var phi_733_: bool;

    let _e72 = (*c_2).d[2u];
    let _e75 = (*c_2).d[0u];
    let _e76 = (_e72 > _e75);
    phi_733_ = _e76;
    if _e76 {
        let _e78 = (*p_1)[0u];
        let _e81 = (*c_2).d[0u];
        let _e82 = (_e78 < _e81);
        phi_714_ = _e82;
        if !(_e82) {
            let _e85 = (*p_1)[1u];
            let _e88 = (*c_2).d[1u];
            phi_714_ = (_e85 < _e88);
        }
        let _e91 = phi_714_;
        phi_723_ = _e91;
        if !(_e91) {
            let _e94 = (*p_1)[0u];
            let _e97 = (*c_2).d[2u];
            phi_723_ = (_e94 >= _e97);
        }
        let _e100 = phi_723_;
        phi_732_ = _e100;
        if !(_e100) {
            let _e103 = (*p_1)[1u];
            let _e106 = (*c_2).d[3u];
            phi_732_ = (_e103 >= _e106);
        }
        let _e109 = phi_732_;
        phi_733_ = _e109;
    }
    let _e111 = phi_733_;
    return _e111;
}

fn det_q_u0028_f1_u003b_f1_u003b(v: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e70 = (*v);
    let _e71 = (*scale);
    return i32(round((_e70 * _e71)));
}

fn det_isqrt_u0028_i1_u003b(v_1: ptr<function, i32>) -> i32 {
    var x_1: i32;

    let _e70 = (*v_1);
    if (_e70 <= 0i) {
        return 0i;
    }
    let _e72 = (*v_1);
    x_1 = i32(sqrt(f32(_e72)));
    loop {
        let _e76 = x_1;
        let _e77 = x_1;
        let _e79 = (*v_1);
        if ((_e76 * _e77) > _e79) {
            let _e81 = x_1;
            x_1 = (_e81 - 1i);
            continue;
        } else {
            break;
        }
    }
    loop {
        let _e83 = x_1;
        let _e85 = x_1;
        let _e88 = (*v_1);
        if (((_e83 + 1i) * (_e85 + 1i)) <= _e88) {
            let _e90 = x_1;
            x_1 = (_e90 + 1i);
            continue;
        } else {
            break;
        }
    }
    let _e92 = x_1;
    return _e92;
}

fn det_brush_offset_u0028_vi2_u003b_struct_u002d_Command_u002d_vi4_u002d_vf4_u002d_vf4_u002d_vf41_u003b(p_2: ptr<function, vec2<i32>>, c_3: ptr<function, Command>) -> vec2<i32> {
    var a_1: vec2<i32>;
    var param_3: f32;
    var param_4: f32;
    var param_5: f32;
    var param_6: f32;
    var b_1: vec2<i32>;
    var param_7: f32;
    var param_8: f32;
    var param_9: f32;
    var param_10: f32;
    var ab: vec2<i32>;
    var ap: vec2<i32>;
    var den: i32;
    var num: i32;
    var bits: i32;
    var S: i32;
    var t: i32;
    var param_11: i32;
    var param_12: i32;
    var param_13: i32;
    var param_14: i32;
    var param_15: i32;
    var param_16: i32;
    var phi_613_: bool;

    let _e95 = (*c_3).b[0u];
    param_3 = _e95;
    param_4 = 4f;
    let _e96 = det_q_u0028_f1_u003b_f1_u003b((&param_3), (&param_4));
    let _e99 = (*c_3).b[1u];
    param_5 = _e99;
    param_6 = 4f;
    let _e100 = det_q_u0028_f1_u003b_f1_u003b((&param_5), (&param_6));
    a_1 = vec2<i32>(_e96, _e100);
    let _e104 = (*c_3).b[2u];
    param_7 = _e104;
    param_8 = 4f;
    let _e105 = det_q_u0028_f1_u003b_f1_u003b((&param_7), (&param_8));
    let _e108 = (*c_3).b[3u];
    param_9 = _e108;
    param_10 = 4f;
    let _e109 = det_q_u0028_f1_u003b_f1_u003b((&param_9), (&param_10));
    b_1 = vec2<i32>(_e105, _e109);
    let _e111 = b_1;
    let _e112 = a_1;
    ab = (_e111 - _e112);
    let _e114 = (*p_2);
    let _e119 = a_1;
    ap = (((_e114 * vec2(4i)) + vec2(2i)) - _e119);
    let _e122 = ab[0u];
    let _e124 = ab[0u];
    let _e127 = ab[1u];
    let _e129 = ab[1u];
    den = ((_e122 * _e124) + (_e127 * _e129));
    let _e132 = den;
    if (_e132 == 0i) {
        let _e134 = ap;
        return _e134;
    }
    let _e136 = ap[0u];
    let _e138 = ab[0u];
    let _e141 = ap[1u];
    let _e143 = ab[1u];
    let _e146 = den;
    num = clamp(((_e136 * _e138) + (_e141 * _e143)), 0i, _e146);
    bits = 0i;
    loop {
        let _e148 = bits;
        let _e149 = (_e148 < 31i);
        phi_613_ = _e149;
        if _e149 {
            let _e150 = den;
            let _e151 = bits;
            phi_613_ = ((_e150 >> bitcast<u32>(_e151)) > 0i);
        }
        let _e156 = phi_613_;
        if _e156 {
            let _e157 = bits;
            bits = (_e157 + 1i);
            continue;
        } else {
            break;
        }
    }
    let _e159 = bits;
    S = (1i << bitcast<u32>(clamp((29i - _e159), 0i, 15i)));
    let _e164 = num;
    let _e165 = S;
    param_11 = (_e164 * _e165);
    let _e167 = den;
    param_12 = _e167;
    let _e168 = det_div_u0028_i1_u003b_i1_u003b((&param_11), (&param_12));
    t = _e168;
    let _e170 = ap[0u];
    let _e171 = S;
    let _e174 = ab[0u];
    let _e175 = t;
    param_13 = ((_e170 * _e171) - (_e174 * _e175));
    let _e178 = S;
    param_14 = _e178;
    let _e179 = det_div_u0028_i1_u003b_i1_u003b((&param_13), (&param_14));
    let _e181 = ap[1u];
    let _e182 = S;
    let _e185 = ab[1u];
    let _e186 = t;
    param_15 = ((_e181 * _e182) - (_e185 * _e186));
    let _e189 = S;
    param_16 = _e189;
    let _e190 = det_div_u0028_i1_u003b_i1_u003b((&param_15), (&param_16));
    return vec2<i32>(_e179, _e190);
}

fn det_brush_dist4_u0028_vi2_u003b_struct_u002d_Command_u002d_vi4_u002d_vf4_u002d_vf4_u002d_vf41_u003b(p_3: ptr<function, vec2<i32>>, c_4: ptr<function, Command>) -> i32 {
    var d: vec2<i32>;
    var param_17: vec2<i32>;
    var param_18: Command;
    var local_1: i32;
    var param_19: i32;

    let _e75 = (*p_3);
    param_17 = _e75;
    let _e76 = (*c_4);
    param_18 = _e76;
    let _e77 = det_brush_offset_u0028_vi2_u003b_struct_u002d_Command_u002d_vi4_u002d_vf4_u002d_vf4_u002d_vf41_u003b((&param_17), (&param_18));
    d = abs(_e77);
    let _e81 = (*c_4).a[2u];
    if (_e81 == 1i) {
        let _e84 = d[0u];
        let _e86 = d[1u];
        local_1 = max(_e84, _e86);
    } else {
        let _e89 = d[0u];
        let _e91 = d[0u];
        let _e94 = d[1u];
        let _e96 = d[1u];
        param_19 = ((_e89 * _e91) + (_e94 * _e96));
        let _e99 = det_isqrt_u0028_i1_u003b((&param_19));
        local_1 = _e99;
    }
    let _e100 = local_1;
    return _e100;
}

fn add_explosion_u0028_vf2_u003b_f1_u003b_f1_u003b(pos: ptr<function, vec2<f32>>, radius: ptr<function, f32>, power: ptr<function, f32>) {
    var i: u32;
    var c_5: vec2<i32>;
    var key: u32;

    let _e75 = atomicAdd((&stats.ex_count), 1u);
    i = _e75;
    let _e76 = i;
    if (_e76 < 64u) {
        let _e78 = i;
        let _e79 = (*pos);
        let _e80 = (*radius);
        let _e81 = (*power);
        stats.explosions[_e78] = vec4<f32>(_e79.x, _e79.y, _e80, _e81);
    }
    let _e89 = atomicAdd((&stats.events[2i]), 1u);
    let _e90 = (*pos);
    let _e94 = pc.i0_;
    c_5 = clamp(vec2<i32>(floor(_e90)), vec2<i32>(0i, 0i), (_e94.xy - vec2(1i)));
    let _e99 = (*radius);
    let _e104 = (*power);
    key = ((u32(clamp(_e99, 1f, 255f)) << bitcast<u32>(16u)) | u32(clamp(round((_e104 * 256f)), 1f, 65535f)));
    let _e111 = c_5[1u];
    let _e114 = pc.i0_[0u];
    let _e117 = c_5[0u];
    let _e121 = key;
    let _e122 = atomicMax((&unnamed_1.ex_grid[((_e111 * _e114) + _e117)]), _e121);
    return;
}

fn make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b(mat: ptr<function, u32>, r_2: ptr<function, Rng>) -> Cell {
    var m: Material;
    var c_6: Cell;
    var param_20: Rng;
    var local_2: f32;
    var li: f32;
    var local_3: u32;
    var param_21: Rng;

    let _e77 = (*mat);
    let _e80 = unnamed.mats[_e77];
    m.color_a = _e80.color_a;
    m.color_b = _e80.color_b;
    m.emission = _e80.emission;
    m.phys = _e80.phys;
    m.thermo = _e80.thermo;
    m.burn = _e80.burn;
    m.optics = _e80.optics;
    m.scatter = _e80.scatter;
    m.ids = _e80.ids;
    m.ids2_ = _e80.ids2_;
    m.misc = _e80.misc;
    m.surface = _e80.surface;
    m.sss = _e80.sss;
    m.sss_color = _e80.sss_color;
    m.optics2_ = _e80.optics2_;
    m.pal0_ = _e80.pal0_;
    m.pal1_ = _e80.pal1_;
    m.pal2_ = _e80.pal2_;
    m.pal3_ = _e80.pal3_;
    m.accent = _e80.accent;
    m.flame = _e80.flame;
    let _e123 = (*mat);
    c_6.mat = _e123;
    let _e125 = (*r_2);
    param_20 = _e125;
    let _e126 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_20));
    let _e127 = param_20;
    (*r_2) = _e127;
    c_6.variant = (_e126 & 255u);
    c_6.flags = 0u;
    let _e133 = m.misc[0u];
    if (_e133 > 0f) {
        let _e137 = m.misc[0u];
        local_2 = _e137;
    } else {
        local_2 = 293f;
    }
    let _e138 = local_2;
    c_6.temp = _e138;
    let _e142 = m.misc[1u];
    li = _e142;
    let _e143 = li;
    if (_e143 > 0f) {
        let _e145 = li;
        let _e146 = (*r_2);
        param_21 = _e146;
        let _e147 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_21));
        let _e148 = param_21;
        (*r_2) = _e148;
        local_3 = u32((_e145 * (0.5f + _e147)));
    } else {
        local_3 = 0u;
    }
    let _e152 = local_3;
    c_6.life = _e152;
    c_6.aux = 0u;
    c_6.extra = 0u;
    let _e156 = c_6;
    return _e156;
}

fn pcg3d_u0028_vu3_u003b(v_2: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e69 = (*v_2);
    (*v_2) = ((_e69 * vec3(1664525u)) + vec3(1013904223u));
    let _e75 = (*v_2)[1u];
    let _e77 = (*v_2)[2u];
    let _e80 = (*v_2)[0u];
    (*v_2)[0u] = (_e80 + (_e75 * _e77));
    let _e84 = (*v_2)[2u];
    let _e86 = (*v_2)[0u];
    let _e89 = (*v_2)[1u];
    (*v_2)[1u] = (_e89 + (_e84 * _e86));
    let _e93 = (*v_2)[0u];
    let _e95 = (*v_2)[1u];
    let _e98 = (*v_2)[2u];
    (*v_2)[2u] = (_e98 + (_e93 * _e95));
    let _e101 = (*v_2);
    let _e105 = (*v_2);
    (*v_2) = (_e105 ^ (_e101 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e108 = (*v_2)[1u];
    let _e110 = (*v_2)[2u];
    let _e113 = (*v_2)[0u];
    (*v_2)[0u] = (_e113 + (_e108 * _e110));
    let _e117 = (*v_2)[2u];
    let _e119 = (*v_2)[0u];
    let _e122 = (*v_2)[1u];
    (*v_2)[1u] = (_e122 + (_e117 * _e119));
    let _e126 = (*v_2)[0u];
    let _e128 = (*v_2)[1u];
    let _e131 = (*v_2)[2u];
    (*v_2)[2u] = (_e131 + (_e126 * _e128));
    let _e134 = (*v_2);
    return _e134;
}

fn rng_init_u0028_vu3_u003b(seed: ptr<function, vec3<u32>>) -> Rng {
    var r_3: Rng;
    var param_22: vec3<u32>;

    let _e71 = (*seed);
    param_22 = _e71;
    let _e72 = pcg3d_u0028_vu3_u003b((&param_22));
    r_3.s = (_e72.x | 1u);
    let _e76 = r_3;
    return _e76;
}

fn unpack_cell_u0028_vu4_u003b(v_3: ptr<function, vec4<u32>>) -> Cell {
    var c_7: Cell;

    let _e71 = (*v_3)[0u];
    c_7.mat = (_e71 & 255u);
    let _e75 = (*v_3)[0u];
    c_7.variant = ((_e75 >> bitcast<u32>(8u)) & 255u);
    let _e81 = (*v_3)[0u];
    c_7.flags = (_e81 >> bitcast<u32>(16u));
    let _e86 = (*v_3)[1u];
    c_7.temp = bitcast<f32>(_e86);
    let _e90 = (*v_3)[2u];
    c_7.life = (_e90 & 65535u);
    let _e94 = (*v_3)[2u];
    c_7.aux = (_e94 >> bitcast<u32>(16u));
    let _e99 = (*v_3)[3u];
    c_7.extra = _e99;
    let _e101 = c_7;
    return _e101;
}

fn in_world_u0028_vi2_u003b(p_4: ptr<function, vec2<i32>>) -> bool {
    var phi_242_: bool;
    var phi_254_: bool;
    var phi_262_: bool;

    let _e70 = (*p_4)[0u];
    let _e71 = (_e70 >= 0i);
    phi_242_ = _e71;
    if _e71 {
        let _e73 = (*p_4)[1u];
        phi_242_ = (_e73 >= 0i);
    }
    let _e76 = phi_242_;
    phi_254_ = _e76;
    if _e76 {
        let _e78 = (*p_4)[0u];
        let _e81 = pc.i0_[0u];
        phi_254_ = (_e78 < _e81);
    }
    let _e84 = phi_254_;
    phi_262_ = _e84;
    if _e84 {
        let _e86 = (*p_4)[1u];
        let _e89 = pc.i0_[1u];
        phi_262_ = (_e86 < _e89);
    }
    let _e92 = phi_262_;
    return _e92;
}

fn main_1() {
    var p_5: vec2<i32>;
    var param_23: vec2<i32>;
    var raw: vec4<u32>;
    var n: i32;
    var c_8: Cell;
    var param_24: vec4<u32>;
    var pos_1: vec2<f32>;
    var i_1: i32;
    var cmd: Command;
    var type_52: i32;
    var r0_: Rng;
    var param_25: vec3<u32>;
    var param_26: u32;
    var param_27: Rng;
    var param_28: vec2<f32>;
    var param_29: f32;
    var param_30: f32;
    var d4_: i32;
    var param_31: vec2<i32>;
    var param_32: Command;
    var r4_: i32;
    var param_33: f32;
    var param_34: f32;
    var param_35: vec2<f32>;
    var param_36: Command;
    var r_4: Rng;
    var param_37: vec3<u32>;
    var param_38: Rng;
    var cm: Material;
    var falloff: f32;
    var param_39: i32;
    var param_40: i32;
    var dheat: f32;
    var param_41: f32;
    var param_42: f32;
    var target_: u32;
    var over: bool;
    var replaceable: bool;
    var param_43: u32;
    var param_44: Rng;
    var param_45: u32;
    var param_46: Rng;
    var param_47: Rng;
    var param_48: u32;
    var param_49: Rng;
    var param_50: vec2<i32>;
    var param_51: Cell;
    var phi_960_: bool;
    var phi_1090_: bool;
    var phi_1091_: bool;
    var phi_1101_: bool;
    var phi_1180_: bool;

    let _e115 = gl_GlobalInvocationID_1;
    p_5 = bitcast<vec2<i32>>(_e115.xy);
    let _e118 = p_5;
    param_23 = _e118;
    let _e119 = in_world_u0028_vi2_u003b((&param_23));
    if !(_e119) {
        return;
    }
    let _e121 = p_5;
    let _e122 = textureLoad(cells_in, _e121, 0i);
    raw = _e122;
    let _e125 = pc.i1_[0u];
    let _e128 = unnamed_2.cmd_header[0u];
    n = min(_e125, bitcast<i32>(_e128));
    let _e131 = n;
    if (_e131 == 0i) {
        let _e133 = p_5;
        let _e134 = raw;
        textureStore(cells_out, _e133, _e134);
        return;
    }
    let _e135 = raw;
    param_24 = _e135;
    let _e136 = unpack_cell_u0028_vu4_u003b((&param_24));
    c_8 = _e136;
    let _e137 = p_5;
    pos_1 = (vec2<f32>(_e137) + vec2(0.5f));
    i_1 = 0i;
    loop {
        let _e141 = i_1;
        let _e142 = n;
        if (_e141 < _e142) {
            let _e144 = i_1;
            let _e147 = unnamed_2.cmds[_e144];
            cmd.a = _e147.a;
            cmd.b = _e147.b;
            cmd.c = _e147.c;
            cmd.d = _e147.d;
            let _e158 = cmd.a[0u];
            type_52 = _e158;
            let _e159 = type_52;
            if (_e159 == 7i) {
                let _e161 = p_5;
                let _e162 = bitcast<vec2<u32>>(_e161);
                let _e165 = pc.i0_[2u];
                param_25 = vec3<u32>(_e162.x, _e162.y, ((bitcast<u32>(_e165) * 7u) + 3u));
                let _e172 = rng_init_u0028_vu3_u003b((&param_25));
                r0_ = _e172;
                param_26 = 0u;
                let _e173 = r0_;
                param_27 = _e173;
                let _e174 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_26), (&param_27));
                let _e175 = param_27;
                r0_ = _e175;
                c_8 = _e174;
                continue;
            }
            let _e176 = type_52;
            if (_e176 == 6i) {
                let _e178 = p_5;
                let _e180 = cmd.b;
                if all((_e178 == vec2<i32>(floor(_e180.xy)))) {
                    let _e187 = cmd.b;
                    param_28 = _e187.xy;
                    let _e191 = cmd.c[0u];
                    param_29 = _e191;
                    let _e194 = cmd.c[1u];
                    param_30 = _e194;
                    add_explosion_u0028_vf2_u003b_f1_u003b_f1_u003b((&param_28), (&param_29), (&param_30));
                }
                continue;
            }
            let _e195 = p_5;
            param_31 = _e195;
            let _e196 = cmd;
            param_32 = _e196;
            let _e197 = det_brush_dist4_u0028_vi2_u003b_struct_u002d_Command_u002d_vi4_u002d_vf4_u002d_vf4_u002d_vf41_u003b((&param_31), (&param_32));
            d4_ = _e197;
            let _e200 = cmd.c[0u];
            param_33 = _e200;
            param_34 = 4f;
            let _e201 = det_q_u0028_f1_u003b_f1_u003b((&param_33), (&param_34));
            r4_ = _e201;
            let _e202 = d4_;
            let _e203 = r4_;
            let _e204 = (_e202 > _e203);
            phi_960_ = _e204;
            if !(_e204) {
                let _e206 = pos_1;
                param_35 = _e206;
                let _e207 = cmd;
                param_36 = _e207;
                let _e208 = clipped_u0028_vf2_u003b_struct_u002d_Command_u002d_vi4_u002d_vf4_u002d_vf4_u002d_vf41_u003b((&param_35), (&param_36));
                phi_960_ = _e208;
            }
            let _e210 = phi_960_;
            if _e210 {
                continue;
            }
            let _e211 = p_5;
            let _e212 = bitcast<vec2<u32>>(_e211);
            let _e215 = cmd.c[3u];
            let _e219 = pc.i0_[2u];
            param_37 = vec3<u32>(_e212.x, _e212.y, (bitcast<u32>(_e215) ^ bitcast<u32>(_e219)));
            let _e225 = rng_init_u0028_vu3_u003b((&param_37));
            r_4 = _e225;
            let _e226 = r_4;
            param_38 = _e226;
            let _e227 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_38));
            let _e228 = param_38;
            r_4 = _e228;
            let _e231 = cmd.c[2u];
            if (_e227 > _e231) {
                continue;
            }
            let _e234 = c_8.mat;
            let _e237 = unnamed.mats[_e234];
            cm.color_a = _e237.color_a;
            cm.color_b = _e237.color_b;
            cm.emission = _e237.emission;
            cm.phys = _e237.phys;
            cm.thermo = _e237.thermo;
            cm.burn = _e237.burn;
            cm.optics = _e237.optics;
            cm.scatter = _e237.scatter;
            cm.ids = _e237.ids;
            cm.ids2_ = _e237.ids2_;
            cm.misc = _e237.misc;
            cm.surface = _e237.surface;
            cm.sss = _e237.sss;
            cm.sss_color = _e237.sss_color;
            cm.optics2_ = _e237.optics2_;
            cm.pal0_ = _e237.pal0_;
            cm.pal1_ = _e237.pal1_;
            cm.pal2_ = _e237.pal2_;
            cm.pal3_ = _e237.pal3_;
            cm.accent = _e237.accent;
            cm.flame = _e237.flame;
            let _e280 = d4_;
            let _e282 = r4_;
            param_39 = (_e280 * 2048i);
            param_40 = max(_e282, 4i);
            let _e284 = det_div_u0028_i1_u003b_i1_u003b((&param_39), (&param_40));
            falloff = (f32((4096i - _e284)) / 4096f);
            let _e290 = cmd.c[1u];
            let _e291 = falloff;
            param_41 = (_e290 * _e291);
            param_42 = 64f;
            let _e293 = det_q_u0028_f1_u003b_f1_u003b((&param_41), (&param_42));
            dheat = (f32(_e293) / 64f);
            let _e296 = type_52;
            if (_e296 == 1i) {
                let _e300 = cmd.a[1u];
                target_ = bitcast<u32>(_e300);
                let _e304 = cmd.a[3u];
                over = (_e304 != 0i);
                let _e307 = c_8.mat;
                let _e308 = (_e307 == 0u);
                phi_1091_ = _e308;
                if !(_e308) {
                    let _e312 = cm.ids[0u];
                    let _e313 = (_e312 == 0u);
                    phi_1090_ = _e313;
                    if _e313 {
                        let _e314 = target_;
                        let _e319 = unnamed.mats[_e314].ids[0u];
                        phi_1090_ = (_e319 != 0u);
                    }
                    let _e322 = phi_1090_;
                    phi_1091_ = _e322;
                }
                let _e324 = phi_1091_;
                replaceable = _e324;
                let _e325 = over;
                let _e326 = replaceable;
                let _e327 = (_e325 || _e326);
                phi_1101_ = _e327;
                if _e327 {
                    let _e329 = c_8.mat;
                    let _e330 = target_;
                    phi_1101_ = (_e329 != _e330);
                }
                let _e333 = phi_1101_;
                if _e333 {
                    let _e334 = target_;
                    param_43 = _e334;
                    let _e335 = r_4;
                    param_44 = _e335;
                    let _e336 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_43), (&param_44));
                    let _e337 = param_44;
                    r_4 = _e337;
                    c_8 = _e336;
                    let _e338 = target_;
                    let _e342 = atomicAdd((&stats.reaction_count[(768u + _e338)]), 1u);
                }
            } else {
                let _e343 = type_52;
                if (_e343 == 2i) {
                    param_45 = 0u;
                    let _e345 = r_4;
                    param_46 = _e345;
                    let _e346 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_45), (&param_46));
                    let _e347 = param_46;
                    r_4 = _e347;
                    c_8 = _e346;
                } else {
                    let _e348 = type_52;
                    if (_e348 == 3i) {
                        let _e351 = c_8.temp;
                        let _e352 = dheat;
                        c_8.temp = min((_e351 + _e352), 6000f);
                    } else {
                        let _e356 = type_52;
                        if (_e356 == 4i) {
                            let _e359 = c_8.temp;
                            let _e360 = dheat;
                            c_8.temp = max((_e359 - _e360), 2f);
                        } else {
                            let _e364 = type_52;
                            if (_e364 == 5i) {
                                let _e368 = cm.ids[1u];
                                if ((_e368 & 1u) != 0u) {
                                    let _e372 = c_8.temp;
                                    let _e375 = cm.burn[0u];
                                    c_8.temp = max(_e372, (_e375 + 5f));
                                } else {
                                    let _e380 = c_8.mat;
                                    let _e381 = (_e380 == 0u);
                                    phi_1180_ = _e381;
                                    if _e381 {
                                        let _e382 = r_4;
                                        param_47 = _e382;
                                        let _e383 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_47));
                                        let _e384 = param_47;
                                        r_4 = _e384;
                                        phi_1180_ = (_e383 < 0.35f);
                                    }
                                    let _e387 = phi_1180_;
                                    if _e387 {
                                        let _e390 = cmd.a[1u];
                                        param_48 = bitcast<u32>(_e390);
                                        let _e392 = r_4;
                                        param_49 = _e392;
                                        let _e393 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_48), (&param_49));
                                        let _e394 = param_49;
                                        r_4 = _e394;
                                        c_8 = _e393;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e395 = i_1;
            i_1 = (_e395 + 1i);
        }
    }
    let _e397 = p_5;
    param_50 = _e397;
    let _e398 = c_8;
    param_51 = _e398;
    store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_50), (&param_51));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
