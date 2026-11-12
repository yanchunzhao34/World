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

struct Lut {
    lut: array<u32>,
}

struct Reaction {
    ids: vec4<u32>,
    p0_: vec4<f32>,
    ids2_: vec4<u32>,
    p1_: vec4<f32>,
    p2_: vec4<f32>,
}

struct Reactions {
    rules: array<Reaction>,
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
@group(0) @binding(5) 
var<storage, read_write> stats: StatsBuf_1;
@group(0) @binding(7) 
var<storage, read_write> unnamed_1: ExGrid_1;
@group(0) @binding(6) 
var<storage, read_write> unnamed_2: MediumSrc_1;
@group(0) @binding(3) 
var<storage> unnamed_3: Lut;
@group(0) @binding(4) 
var<storage> unnamed_4: Reactions;
var<private> gl_GlobalInvocationID_1: vec3<u32>;

fn add_explosion_u0028_vf2_u003b_f1_u003b_f1_u003b(pos: ptr<function, vec2<f32>>, radius: ptr<function, f32>, power: ptr<function, f32>) {
    var i: u32;
    var c: vec2<i32>;
    var key: u32;

    let _e91 = atomicAdd((&stats.ex_count), 1u);
    i = _e91;
    let _e92 = i;
    if (_e92 < 64u) {
        let _e94 = i;
        let _e95 = (*pos);
        let _e96 = (*radius);
        let _e97 = (*power);
        stats.explosions[_e94] = vec4<f32>(_e95.x, _e95.y, _e96, _e97);
    }
    let _e105 = atomicAdd((&stats.events[2i]), 1u);
    let _e106 = (*pos);
    let _e110 = pc.i0_;
    c = clamp(vec2<i32>(floor(_e106)), vec2<i32>(0i, 0i), (_e110.xy - vec2(1i)));
    let _e115 = (*radius);
    let _e120 = (*power);
    key = ((u32(clamp(_e115, 1f, 255f)) << bitcast<u32>(16u)) | u32(clamp(round((_e120 * 256f)), 1f, 65535f)));
    let _e127 = c[1u];
    let _e130 = pc.i0_[0u];
    let _e133 = c[0u];
    let _e137 = key;
    let _e138 = atomicMax((&unnamed_1.ex_grid[((_e127 * _e130) + _e133)]), _e137);
    return;
}

fn emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b(cell: ptr<function, vec2<i32>>, channel: ptr<function, u32>, amount: ptr<function, f32>) {
    var mp: vec2<i32>;
    var mw: i32;
    var idx: u32;

    let _e90 = (*amount);
    if (_e90 <= 0f) {
        return;
    }
    let _e92 = (*cell);
    mp = (_e92 >> bitcast<vec2<u32>>(vec2(1i)));
    let _e98 = pc.i0_[0u];
    mw = (_e98 >> bitcast<u32>(1i));
    let _e102 = mp[1u];
    let _e103 = mw;
    let _e106 = mp[0u];
    let _e110 = (*channel);
    idx = ((bitcast<u32>(((_e102 * _e103) + _e106)) * 4u) + _e110);
    let _e112 = idx;
    let _e115 = (*amount);
    let _e118 = atomicAdd((&unnamed_2.msrc[_e112]), u32((_e115 * 1024f)));
    return;
}

fn set_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b(c_1: ptr<function, Cell>, v: ptr<function, u32>) {
    let _e87 = (*c_1).flags;
    let _e89 = (*v);
    (*c_1).flags = ((_e87 & 4294967267u) | (min(_e89, 7u) << bitcast<u32>(2u)));
    return;
}

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e85 = (*x);
    return (f32((_e85 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b(r: ptr<function, Rng>) -> u32 {
    let _e86 = (*r).s;
    let _e90 = (*r).s;
    (*r).s = (_e90 ^ (_e86 << bitcast<u32>(13u)));
    let _e94 = (*r).s;
    let _e98 = (*r).s;
    (*r).s = (_e98 ^ (_e94 >> bitcast<u32>(17u)));
    let _e102 = (*r).s;
    let _e106 = (*r).s;
    (*r).s = (_e106 ^ (_e102 << bitcast<u32>(5u)));
    let _e110 = (*r).s;
    return _e110;
}

fn rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b(r_1: ptr<function, Rng>) -> f32 {
    var param: Rng;
    var param_1: u32;

    let _e87 = (*r_1);
    param = _e87;
    let _e88 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param));
    let _e89 = param;
    (*r_1) = _e89;
    param_1 = _e88;
    let _e90 = u01_u0028_u1_u003b((&param_1));
    return _e90;
}

fn make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b(mat: ptr<function, u32>, r_2: ptr<function, Rng>) -> Cell {
    var m: Material;
    var c_2: Cell;
    var param_2: Rng;
    var local: f32;
    var li: f32;
    var local_1: u32;
    var param_3: Rng;

    let _e93 = (*mat);
    let _e96 = unnamed.mats[_e93];
    m.color_a = _e96.color_a;
    m.color_b = _e96.color_b;
    m.emission = _e96.emission;
    m.phys = _e96.phys;
    m.thermo = _e96.thermo;
    m.burn = _e96.burn;
    m.optics = _e96.optics;
    m.scatter = _e96.scatter;
    m.ids = _e96.ids;
    m.ids2_ = _e96.ids2_;
    m.misc = _e96.misc;
    m.surface = _e96.surface;
    m.sss = _e96.sss;
    m.sss_color = _e96.sss_color;
    m.optics2_ = _e96.optics2_;
    m.pal0_ = _e96.pal0_;
    m.pal1_ = _e96.pal1_;
    m.pal2_ = _e96.pal2_;
    m.pal3_ = _e96.pal3_;
    m.accent = _e96.accent;
    m.flame = _e96.flame;
    let _e139 = (*mat);
    c_2.mat = _e139;
    let _e141 = (*r_2);
    param_2 = _e141;
    let _e142 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_2));
    let _e143 = param_2;
    (*r_2) = _e143;
    c_2.variant = (_e142 & 255u);
    c_2.flags = 0u;
    let _e149 = m.misc[0u];
    if (_e149 > 0f) {
        let _e153 = m.misc[0u];
        local = _e153;
    } else {
        local = 293f;
    }
    let _e154 = local;
    c_2.temp = _e154;
    let _e158 = m.misc[1u];
    li = _e158;
    let _e159 = li;
    if (_e159 > 0f) {
        let _e161 = li;
        let _e162 = (*r_2);
        param_3 = _e162;
        let _e163 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_3));
        let _e164 = param_3;
        (*r_2) = _e164;
        local_1 = u32((_e161 * (0.5f + _e163)));
    } else {
        local_1 = 0u;
    }
    let _e168 = local_1;
    c_2.life = _e168;
    c_2.aux = 0u;
    c_2.extra = 0u;
    let _e172 = c_2;
    return _e172;
}

fn transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b(c_3: ptr<function, Cell>, mat_1: ptr<function, u32>, r_3: ptr<function, Rng>) {
    var t: f32;
    var param_4: u32;
    var param_5: Rng;

    let _e91 = (*c_3).temp;
    t = _e91;
    let _e92 = (*mat_1);
    param_4 = _e92;
    let _e93 = (*r_3);
    param_5 = _e93;
    let _e94 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_4), (&param_5));
    let _e95 = param_5;
    (*r_3) = _e95;
    (*c_3) = _e94;
    let _e96 = t;
    (*c_3).temp = _e96;
    return;
}

fn apply_out_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b_struct_u002d_Rng_u002d_u11_u003b(c_4: ptr<function, Cell>, outMat: ptr<function, u32>, outTemp: ptr<function, f32>, heat: ptr<function, f32>, flash: ptr<function, f32>, r_4: ptr<function, Rng>) {
    var param_6: Cell;
    var param_7: u32;
    var param_8: Rng;
    var param_9: Cell;
    var param_10: u32;
    var phi_690_: bool;

    let _e95 = (*outMat);
    let _e97 = (*c_4).mat;
    let _e98 = (_e95 != _e97);
    phi_690_ = _e98;
    if !(_e98) {
        let _e100 = (*outMat);
        let _e105 = unnamed.mats[_e100].ids[1u];
        phi_690_ = ((_e105 & 8u) != 0u);
    }
    let _e109 = phi_690_;
    if _e109 {
        let _e110 = (*c_4);
        param_6 = _e110;
        let _e111 = (*outMat);
        param_7 = _e111;
        let _e112 = (*r_4);
        param_8 = _e112;
        transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_6), (&param_7), (&param_8));
        let _e113 = param_6;
        (*c_4) = _e113;
        let _e114 = param_8;
        (*r_4) = _e114;
    }
    let _e115 = (*outTemp);
    if (_e115 > 0f) {
        let _e117 = (*outTemp);
        (*c_4).temp = _e117;
    }
    let _e120 = (*c_4).temp;
    let _e121 = (*heat);
    (*c_4).temp = clamp((_e120 + _e121), 2f, 6000f);
    let _e125 = (*flash);
    if (_e125 > 0f) {
        let _e127 = (*flash);
        let _e129 = (*c_4);
        param_9 = _e129;
        param_10 = u32(_e127);
        set_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b((&param_9), (&param_10));
        let _e130 = param_9;
        (*c_4) = _e130;
    }
    return;
}

fn in_world_u0028_vi2_u003b(p: ptr<function, vec2<i32>>) -> bool {
    var phi_264_: bool;
    var phi_278_: bool;
    var phi_286_: bool;

    let _e86 = (*p)[0u];
    let _e87 = (_e86 >= 0i);
    phi_264_ = _e87;
    if _e87 {
        let _e89 = (*p)[1u];
        phi_264_ = (_e89 >= 0i);
    }
    let _e92 = phi_264_;
    phi_278_ = _e92;
    if _e92 {
        let _e94 = (*p)[0u];
        let _e97 = pc.i0_[0u];
        phi_278_ = (_e94 < _e97);
    }
    let _e100 = phi_278_;
    phi_286_ = _e100;
    if _e100 {
        let _e102 = (*p)[1u];
        let _e105 = pc.i0_[1u];
        phi_286_ = (_e102 < _e105);
    }
    let _e108 = phi_286_;
    return _e108;
}

fn mat_at_u0028_vi2_u003b(p_1: ptr<function, vec2<i32>>) -> u32 {
    var param_11: vec2<i32>;
    var local_2: u32;

    let _e87 = (*p_1);
    param_11 = _e87;
    let _e88 = in_world_u0028_vi2_u003b((&param_11));
    if _e88 {
        let _e89 = (*p_1);
        let _e90 = textureLoad(cells_in, _e89, 0i);
        local_2 = (_e90.x & 255u);
    } else {
        local_2 = 255u;
    }
    let _e93 = local_2;
    return _e93;
}

fn has_catalyst_u0028_vi2_u003b_u1_u003b(p_2: ptr<function, vec2<i32>>, cat: ptr<function, u32>) -> bool {
    var y: i32;
    var x_1: i32;
    var param_12: vec2<i32>;

    y = -1i;
    loop {
        let _e89 = y;
        if (_e89 <= 1i) {
            x_1 = -1i;
            loop {
                let _e91 = x_1;
                if (_e91 <= 1i) {
                    let _e93 = (*p_2);
                    let _e94 = x_1;
                    let _e95 = y;
                    param_12 = (_e93 + vec2<i32>(_e94, _e95));
                    let _e98 = mat_at_u0028_vi2_u003b((&param_12));
                    let _e99 = (*cat);
                    if (_e98 == _e99) {
                        return true;
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e101 = x_1;
                    x_1 = (_e101 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e103 = y;
            y = (_e103 + 1i);
        }
    }
    return false;
}

fn burn_interact_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vi2_u003b_struct_u002d_Rng_u002d_u11_u003b(x_2: ptr<function, Cell>, y_1: ptr<function, Cell>, px: ptr<function, vec2<i32>>, py: ptr<function, vec2<i32>>, r_5: ptr<function, Rng>) -> bool {
    var my: Material;
    var param_13: Rng;
    var param_14: Rng;
    var param_15: Cell;
    var param_16: u32;
    var param_17: Rng;
    var param_18: vec2<i32>;
    var param_19: u32;
    var param_20: f32;
    var param_21: Rng;
    var t_1: f32;
    var fc: vec3<f32>;
    var fuel: u32;
    var local_3: u32;
    var local_4: u32;
    var param_22: u32;
    var param_23: Rng;
    var phi_823_: bool;
    var phi_855_: bool;

    let _e107 = (*x_2).flags;
    if ((_e107 & 1u) == 0u) {
        return false;
    }
    let _e111 = (*y_1).mat;
    let _e114 = unnamed.mats[_e111];
    my.color_a = _e114.color_a;
    my.color_b = _e114.color_b;
    my.emission = _e114.emission;
    my.phys = _e114.phys;
    my.thermo = _e114.thermo;
    my.burn = _e114.burn;
    my.optics = _e114.optics;
    my.scatter = _e114.scatter;
    my.ids = _e114.ids;
    my.ids2_ = _e114.ids2_;
    my.misc = _e114.misc;
    my.surface = _e114.surface;
    my.sss = _e114.sss;
    my.sss_color = _e114.sss_color;
    my.optics2_ = _e114.optics2_;
    my.pal0_ = _e114.pal0_;
    my.pal1_ = _e114.pal1_;
    my.pal2_ = _e114.pal2_;
    my.pal3_ = _e114.pal3_;
    my.accent = _e114.accent;
    my.flame = _e114.flame;
    let _e159 = my.ids[1u];
    if ((_e159 & 4u) != 0u) {
        let _e162 = (*r_5);
        param_13 = _e162;
        let _e163 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_13));
        let _e164 = param_13;
        (*r_5) = _e164;
        if (_e163 < 0.3f) {
            let _e167 = (*x_2).flags;
            (*x_2).flags = (_e167 & 4294967294u);
            let _e171 = (*x_2).temp;
            let _e173 = (*x_2).mat;
            let _e178 = unnamed.mats[_e173].burn[0u];
            (*x_2).temp = min(_e171, (_e178 - 80f));
            let _e184 = atomicAdd((&stats.events[3i]), 1u);
            let _e187 = my.ids[0u];
            let _e188 = (_e187 == 1u);
            phi_823_ = _e188;
            if _e188 {
                let _e189 = (*r_5);
                param_14 = _e189;
                let _e190 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_14));
                let _e191 = param_14;
                (*r_5) = _e191;
                phi_823_ = (_e190 < 0.5f);
            }
            let _e194 = phi_823_;
            if _e194 {
                let _e197 = pc.i1_[3u];
                let _e199 = (*y_1);
                param_15 = _e199;
                param_16 = bitcast<u32>(_e197);
                let _e200 = (*r_5);
                param_17 = _e200;
                transmute_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_15), (&param_16), (&param_17));
                let _e201 = param_15;
                (*y_1) = _e201;
                let _e202 = param_17;
                (*r_5) = _e202;
                (*y_1).temp = 390f;
                let _e204 = (*py);
                param_18 = _e204;
                param_19 = 1u;
                param_20 = 1f;
                emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_18), (&param_19), (&param_20));
            }
        }
        return true;
    }
    let _e206 = (*y_1).mat;
    let _e207 = (_e206 == 0u);
    phi_855_ = _e207;
    if _e207 {
        let _e208 = (*r_5);
        param_21 = _e208;
        let _e209 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_21));
        let _e210 = param_21;
        (*r_5) = _e210;
        phi_855_ = (_e209 < 0.5f);
    }
    let _e213 = phi_855_;
    if _e213 {
        let _e215 = (*y_1).temp;
        let _e217 = (*x_2).mat;
        let _e222 = unnamed.mats[_e217].burn[1u];
        t_1 = max(_e215, _e222);
        let _e225 = (*x_2).mat;
        let _e229 = unnamed.mats[_e225].flame;
        fc = _e229.xyz;
        let _e232 = (*x_2).flags;
        if ((_e232 & 128u) != 0u) {
            let _e236 = (*x_2).variant;
            local_3 = _e236;
        } else {
            let _e237 = fc;
            let _e238 = fc;
            if (dot(_e237, _e238) > 0f) {
                let _e242 = (*x_2).mat;
                local_4 = _e242;
            } else {
                local_4 = 0u;
            }
            let _e243 = local_4;
            local_3 = _e243;
        }
        let _e244 = local_3;
        fuel = _e244;
        let _e247 = pc.i1_[2u];
        param_22 = bitcast<u32>(_e247);
        let _e249 = (*r_5);
        param_23 = _e249;
        let _e250 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_22), (&param_23));
        let _e251 = param_23;
        (*r_5) = _e251;
        (*y_1) = _e250;
        let _e252 = t_1;
        (*y_1).temp = _e252;
        let _e254 = fuel;
        if (_e254 != 0u) {
            let _e256 = fuel;
            (*y_1).variant = _e256;
            let _e259 = (*y_1).flags;
            (*y_1).flags = (_e259 | 128u);
        }
        return true;
    }
    return false;
}

fn react_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vi2_u003b_struct_u002d_Rng_u002d_u11_u003b(x_3: ptr<function, Cell>, y_2: ptr<function, Cell>, px_1: ptr<function, vec2<i32>>, py_1: ptr<function, vec2<i32>>, r_6: ptr<function, Rng>) {
    var param_24: Cell;
    var param_25: Cell;
    var param_26: vec2<i32>;
    var param_27: vec2<i32>;
    var param_28: Rng;
    var param_29: Cell;
    var param_30: Cell;
    var param_31: vec2<i32>;
    var param_32: vec2<i32>;
    var param_33: Rng;
    var packed: u32;
    var count: u32;
    var off: u32;
    var roll: f32;
    var param_34: Rng;
    var acc: f32;
    var tmax: f32;
    var k: u32;
    var R: Reaction;
    var param_35: vec2<i32>;
    var param_36: u32;
    var param_37: vec2<i32>;
    var param_38: u32;
    var xa: bool;
    var local_5: u32;
    var local_6: f32;
    var param_39: Cell;
    var param_40: u32;
    var param_41: f32;
    var param_42: f32;
    var param_43: f32;
    var param_44: Rng;
    var local_7: u32;
    var local_8: f32;
    var param_45: Cell;
    var param_46: u32;
    var param_47: f32;
    var param_48: f32;
    var param_49: f32;
    var param_50: Rng;
    var param_51: vec2<i32>;
    var param_52: u32;
    var param_53: f32;
    var param_54: vec2<i32>;
    var param_55: u32;
    var param_56: f32;
    var param_57: Rng;
    var param_58: vec2<f32>;
    var param_59: f32;
    var param_60: f32;
    var phi_1035_: bool;
    var phi_1051_: bool;
    var phi_1061_: bool;
    var phi_1183_: bool;

    let _e139 = (*x_3);
    param_24 = _e139;
    let _e140 = (*y_2);
    param_25 = _e140;
    let _e141 = (*px_1);
    param_26 = _e141;
    let _e142 = (*py_1);
    param_27 = _e142;
    let _e143 = (*r_6);
    param_28 = _e143;
    let _e144 = burn_interact_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vi2_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_24), (&param_25), (&param_26), (&param_27), (&param_28));
    let _e145 = param_24;
    (*x_3) = _e145;
    let _e146 = param_25;
    (*y_2) = _e146;
    let _e147 = param_28;
    (*r_6) = _e147;
    if _e144 {
        return;
    }
    let _e148 = (*y_2);
    param_29 = _e148;
    let _e149 = (*x_3);
    param_30 = _e149;
    let _e150 = (*py_1);
    param_31 = _e150;
    let _e151 = (*px_1);
    param_32 = _e151;
    let _e152 = (*r_6);
    param_33 = _e152;
    let _e153 = burn_interact_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vi2_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_29), (&param_30), (&param_31), (&param_32), (&param_33));
    let _e154 = param_29;
    (*y_2) = _e154;
    let _e155 = param_30;
    (*x_3) = _e155;
    let _e156 = param_33;
    (*r_6) = _e156;
    if _e153 {
        return;
    }
    let _e158 = (*x_3).mat;
    let _e161 = (*y_2).mat;
    let _e165 = unnamed_3.lut[((_e158 * 256u) + _e161)];
    packed = _e165;
    let _e166 = packed;
    count = (_e166 & 255u);
    let _e168 = count;
    if (_e168 == 0u) {
        return;
    }
    let _e170 = packed;
    off = (_e170 >> bitcast<u32>(8u));
    let _e173 = (*r_6);
    param_34 = _e173;
    let _e174 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_34));
    let _e175 = param_34;
    (*r_6) = _e175;
    roll = _e174;
    acc = 0f;
    let _e177 = (*x_3).temp;
    let _e179 = (*y_2).temp;
    tmax = max(_e177, _e179);
    k = 0u;
    loop {
        let _e181 = k;
        let _e182 = count;
        if (_e181 < _e182) {
            let _e184 = off;
            let _e185 = k;
            let _e189 = unnamed_4.rules[(_e184 + _e185)];
            R.ids = _e189.ids;
            R.p0_ = _e189.p0_;
            R.ids2_ = _e189.ids2_;
            R.p1_ = _e189.p1_;
            R.p2_ = _e189.p2_;
            let _e200 = tmax;
            let _e203 = R.p0_[1u];
            let _e204 = (_e200 < _e203);
            phi_1035_ = _e204;
            if !(_e204) {
                let _e206 = tmax;
                let _e209 = R.p0_[2u];
                phi_1035_ = (_e206 > _e209);
            }
            let _e212 = phi_1035_;
            if _e212 {
                continue;
            }
            let _e215 = R.ids2_[0u];
            let _e216 = (_e215 != 65535u);
            phi_1051_ = _e216;
            if _e216 {
                let _e217 = (*px_1);
                param_35 = _e217;
                let _e220 = R.ids2_[0u];
                param_36 = _e220;
                let _e221 = has_catalyst_u0028_vi2_u003b_u1_u003b((&param_35), (&param_36));
                phi_1051_ = !(_e221);
            }
            let _e224 = phi_1051_;
            phi_1061_ = _e224;
            if _e224 {
                let _e225 = (*py_1);
                param_37 = _e225;
                let _e228 = R.ids2_[0u];
                param_38 = _e228;
                let _e229 = has_catalyst_u0028_vi2_u003b_u1_u003b((&param_37), (&param_38));
                phi_1061_ = !(_e229);
            }
            let _e232 = phi_1061_;
            if _e232 {
                continue;
            }
            let _e235 = R.p0_[0u];
            let _e236 = acc;
            acc = (_e236 + _e235);
            let _e238 = roll;
            let _e239 = acc;
            if (_e238 >= _e239) {
                continue;
            }
            let _e242 = (*x_3).mat;
            let _e245 = R.ids[0u];
            xa = (_e242 == _e245);
            let _e247 = xa;
            if _e247 {
                let _e250 = R.ids[2u];
                local_5 = _e250;
            } else {
                let _e253 = R.ids[3u];
                local_5 = _e253;
            }
            let _e254 = xa;
            if _e254 {
                let _e257 = R.p1_[0u];
                local_6 = _e257;
            } else {
                let _e260 = R.p1_[1u];
                local_6 = _e260;
            }
            let _e261 = (*x_3);
            param_39 = _e261;
            let _e262 = local_5;
            param_40 = _e262;
            let _e263 = local_6;
            param_41 = _e263;
            let _e266 = R.p0_[3u];
            param_42 = _e266;
            let _e269 = R.p1_[2u];
            param_43 = _e269;
            let _e270 = (*r_6);
            param_44 = _e270;
            apply_out_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_39), (&param_40), (&param_41), (&param_42), (&param_43), (&param_44));
            let _e271 = param_39;
            (*x_3) = _e271;
            let _e272 = param_44;
            (*r_6) = _e272;
            let _e273 = xa;
            if _e273 {
                let _e276 = R.ids[3u];
                local_7 = _e276;
            } else {
                let _e279 = R.ids[2u];
                local_7 = _e279;
            }
            let _e280 = xa;
            if _e280 {
                let _e283 = R.p1_[1u];
                local_8 = _e283;
            } else {
                let _e286 = R.p1_[0u];
                local_8 = _e286;
            }
            let _e287 = (*y_2);
            param_45 = _e287;
            let _e288 = local_7;
            param_46 = _e288;
            let _e289 = local_8;
            param_47 = _e289;
            let _e292 = R.p0_[3u];
            param_48 = _e292;
            let _e295 = R.p1_[2u];
            param_49 = _e295;
            let _e296 = (*r_6);
            param_50 = _e296;
            apply_out_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_45), (&param_46), (&param_47), (&param_48), (&param_49), (&param_50));
            let _e297 = param_45;
            (*y_2) = _e297;
            let _e298 = param_50;
            (*r_6) = _e298;
            let _e301 = R.ids2_[2u];
            let _e304 = atomicAdd((&stats.reaction_count[_e301]), 1u);
            let _e307 = atomicAdd((&stats.events[4i]), 1u);
            let _e308 = (*px_1);
            param_51 = _e308;
            param_52 = 0u;
            let _e311 = R.p2_[0u];
            param_53 = _e311;
            emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_51), (&param_52), (&param_53));
            let _e312 = (*px_1);
            param_54 = _e312;
            param_55 = 1u;
            let _e315 = R.p2_[1u];
            param_56 = _e315;
            emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_54), (&param_55), (&param_56));
            let _e318 = R.ids2_[1u];
            let _e319 = (_e318 > 0u);
            phi_1183_ = _e319;
            if _e319 {
                let _e320 = (*r_6);
                param_57 = _e320;
                let _e321 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_57));
                let _e322 = param_57;
                (*r_6) = _e322;
                phi_1183_ = (_e321 < 0.25f);
            }
            let _e325 = phi_1183_;
            if _e325 {
                let _e326 = (*px_1);
                let _e327 = (*py_1);
                let _e335 = R.ids2_[1u];
                param_58 = ((vec2<f32>((_e326 + _e327)) + vec2(1f)) * 0.5f);
                param_59 = f32(_e335);
                let _e339 = R.p1_[3u];
                param_60 = _e339;
                add_explosion_u0028_vf2_u003b_f1_u003b_f1_u003b((&param_58), (&param_59), (&param_60));
            }
            return;
        } else {
            break;
        }
        continuing {
            let _e340 = k;
            k = (_e340 + bitcast<u32>(1i));
        }
    }
    return;
}

fn pcg3d_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e85 = (*v_1);
    (*v_1) = ((_e85 * vec3(1664525u)) + vec3(1013904223u));
    let _e91 = (*v_1)[1u];
    let _e93 = (*v_1)[2u];
    let _e96 = (*v_1)[0u];
    (*v_1)[0u] = (_e96 + (_e91 * _e93));
    let _e100 = (*v_1)[2u];
    let _e102 = (*v_1)[0u];
    let _e105 = (*v_1)[1u];
    (*v_1)[1u] = (_e105 + (_e100 * _e102));
    let _e109 = (*v_1)[0u];
    let _e111 = (*v_1)[1u];
    let _e114 = (*v_1)[2u];
    (*v_1)[2u] = (_e114 + (_e109 * _e111));
    let _e117 = (*v_1);
    let _e121 = (*v_1);
    (*v_1) = (_e121 ^ (_e117 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e124 = (*v_1)[1u];
    let _e126 = (*v_1)[2u];
    let _e129 = (*v_1)[0u];
    (*v_1)[0u] = (_e129 + (_e124 * _e126));
    let _e133 = (*v_1)[2u];
    let _e135 = (*v_1)[0u];
    let _e138 = (*v_1)[1u];
    (*v_1)[1u] = (_e138 + (_e133 * _e135));
    let _e142 = (*v_1)[0u];
    let _e144 = (*v_1)[1u];
    let _e147 = (*v_1)[2u];
    (*v_1)[2u] = (_e147 + (_e142 * _e144));
    let _e150 = (*v_1);
    return _e150;
}

fn rng_init_u0028_vu3_u003b(seed: ptr<function, vec3<u32>>) -> Rng {
    var r_7: Rng;
    var param_61: vec3<u32>;

    let _e87 = (*seed);
    param_61 = _e87;
    let _e88 = pcg3d_u0028_vu3_u003b((&param_61));
    r_7.s = (_e88.x | 1u);
    let _e92 = r_7;
    return _e92;
}

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c_5: ptr<function, Cell>) -> vec4<u32> {
    let _e86 = (*c_5).mat;
    let _e89 = (*c_5).variant;
    let _e95 = (*c_5).flags;
    let _e101 = (*c_5).temp;
    let _e104 = (*c_5).life;
    let _e107 = (*c_5).aux;
    let _e113 = (*c_5).extra;
    return vec4<u32>((((_e86 & 255u) | ((_e89 & 255u) << bitcast<u32>(8u))) | ((_e95 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e101), ((_e104 & 65535u) | ((_e107 & 65535u) << bitcast<u32>(16u))), _e113);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p_3: ptr<function, vec2<i32>>, c_6: ptr<function, Cell>) {
    var param_62: Cell;

    let _e87 = (*p_3);
    let _e88 = (*c_6);
    param_62 = _e88;
    let _e89 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_62));
    textureStore(cells_out, _e87, _e89);
    return;
}

fn unpack_cell_u0028_vu4_u003b(v_2: ptr<function, vec4<u32>>) -> Cell {
    var c_7: Cell;

    let _e87 = (*v_2)[0u];
    c_7.mat = (_e87 & 255u);
    let _e91 = (*v_2)[0u];
    c_7.variant = ((_e91 >> bitcast<u32>(8u)) & 255u);
    let _e97 = (*v_2)[0u];
    c_7.flags = (_e97 >> bitcast<u32>(16u));
    let _e102 = (*v_2)[1u];
    c_7.temp = bitcast<f32>(_e102);
    let _e106 = (*v_2)[2u];
    c_7.life = (_e106 & 65535u);
    let _e110 = (*v_2)[2u];
    c_7.aux = (_e110 >> bitcast<u32>(16u));
    let _e115 = (*v_2)[3u];
    c_7.extra = _e115;
    let _e117 = c_7;
    return _e117;
}

fn load_cell_u0028_vi2_u003b(p_4: ptr<function, vec2<i32>>) -> Cell {
    var param_63: vec4<u32>;

    let _e86 = (*p_4);
    let _e87 = textureLoad(cells_in, _e86, 0i);
    param_63 = _e87;
    let _e88 = unpack_cell_u0028_vu4_u003b((&param_63));
    return _e88;
}

fn main_1() {
    var b: vec2<i32>;
    var origin: vec2<i32>;
    var ps: array<vec2<i32>, 4>;
    var i_1: i32;
    var valid: array<bool, 4>;
    var param_64: vec2<i32>;
    var cs: array<Cell, 4>;
    var param_65: vec2<i32>;
    var m0_: u32;
    var same: bool;
    var burning: bool;
    var i_2: i32;
    var i_3: i32;
    var param_66: vec2<i32>;
    var param_67: Cell;
    var r_8: Rng;
    var param_68: vec3<u32>;
    var pairing: u32;
    var param_69: Rng;
    var pairs: array<vec2<i32>, 2>;
    var k_1: i32;
    var i_4: i32;
    var j: i32;
    var param_70: Rng;
    var param_71: Cell;
    var param_72: Cell;
    var param_73: vec2<i32>;
    var param_74: vec2<i32>;
    var param_75: Rng;
    var param_76: Cell;
    var param_77: Cell;
    var param_78: vec2<i32>;
    var param_79: vec2<i32>;
    var param_80: Rng;
    var i_5: i32;
    var param_81: vec2<i32>;
    var param_82: Cell;
    var phi_1233_: bool;
    var phi_1317_: bool;
    var phi_1327_: bool;
    var phi_1349_: bool;
    var phi_1350_: bool;
    var phi_1453_: bool;

    let _e121 = gl_GlobalInvocationID_1;
    b = bitcast<vec2<i32>>(_e121.xy);
    let _e124 = b;
    let _e128 = pc.i1_;
    origin = ((_e124 * vec2(2i)) - _e128.xy);
    let _e132 = origin[0u];
    let _e135 = pc.i0_[0u];
    let _e136 = (_e132 >= _e135);
    phi_1233_ = _e136;
    if !(_e136) {
        let _e139 = origin[1u];
        let _e142 = pc.i0_[1u];
        phi_1233_ = (_e139 >= _e142);
    }
    let _e145 = phi_1233_;
    if _e145 {
        return;
    }
    let _e146 = origin;
    let _e147 = origin;
    let _e149 = origin;
    let _e151 = origin;
    ps = array<vec2<i32>, 4>(_e146, (_e147 + vec2<i32>(1i, 0i)), (_e149 + vec2<i32>(0i, 1i)), (_e151 + vec2<i32>(1i, 1i)));
    i_1 = 0i;
    loop {
        let _e154 = i_1;
        if (_e154 < 4i) {
            let _e156 = i_1;
            let _e157 = i_1;
            let _e159 = ps[_e157];
            param_64 = _e159;
            let _e160 = in_world_u0028_vi2_u003b((&param_64));
            valid[_e156] = _e160;
            let _e162 = i_1;
            let _e164 = valid[_e162];
            if _e164 {
                let _e165 = i_1;
                let _e166 = i_1;
                let _e168 = ps[_e166];
                param_65 = _e168;
                let _e169 = load_cell_u0028_vi2_u003b((&param_65));
                cs[_e165] = _e169;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e171 = i_1;
            i_1 = (_e171 + 1i);
        }
    }
    m0_ = 65535u;
    same = true;
    burning = false;
    i_2 = 0i;
    loop {
        let _e173 = i_2;
        if (_e173 < 4i) {
            let _e175 = i_2;
            let _e177 = valid[_e175];
            if _e177 {
                let _e178 = m0_;
                if (_e178 == 65535u) {
                    let _e180 = i_2;
                    let _e183 = cs[_e180].mat;
                    m0_ = _e183;
                }
                let _e184 = same;
                phi_1317_ = _e184;
                if _e184 {
                    let _e185 = i_2;
                    let _e188 = cs[_e185].mat;
                    let _e189 = m0_;
                    phi_1317_ = (_e188 == _e189);
                }
                let _e192 = phi_1317_;
                same = _e192;
                let _e193 = burning;
                phi_1327_ = _e193;
                if !(_e193) {
                    let _e195 = i_2;
                    let _e198 = cs[_e195].flags;
                    phi_1327_ = ((_e198 & 1u) != 0u);
                }
                let _e202 = phi_1327_;
                burning = _e202;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e203 = i_2;
            i_2 = (_e203 + 1i);
        }
    }
    let _e205 = same;
    let _e206 = burning;
    let _e208 = (_e205 && !(_e206));
    phi_1350_ = _e208;
    if _e208 {
        let _e209 = m0_;
        let _e210 = (_e209 == 65535u);
        phi_1349_ = _e210;
        if !(_e210) {
            let _e212 = m0_;
            let _e214 = m0_;
            let _e218 = unnamed_3.lut[((_e212 * 256u) + _e214)];
            phi_1349_ = ((_e218 & 255u) == 0u);
        }
        let _e222 = phi_1349_;
        phi_1350_ = _e222;
    }
    let _e224 = phi_1350_;
    if _e224 {
        i_3 = 0i;
        loop {
            let _e225 = i_3;
            if (_e225 < 4i) {
                let _e227 = i_3;
                let _e229 = valid[_e227];
                if _e229 {
                    let _e230 = i_3;
                    let _e231 = i_3;
                    let _e233 = ps[_e230];
                    param_66 = _e233;
                    let _e235 = cs[_e231];
                    param_67 = _e235;
                    store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_66), (&param_67));
                }
                continue;
            } else {
                break;
            }
            continuing {
                let _e236 = i_3;
                i_3 = (_e236 + 1i);
            }
        }
        return;
    }
    let _e238 = origin;
    let _e241 = bitcast<vec2<u32>>((_e238 + vec2(2i)));
    let _e244 = pc.i0_[2u];
    let _e249 = pc.i1_[0u];
    param_68 = vec3<u32>(_e241.x, _e241.y, (((bitcast<u32>(_e244) * 5u) + (bitcast<u32>(_e249) * 2u)) + 77u));
    let _e257 = rng_init_u0028_vu3_u003b((&param_68));
    r_8 = _e257;
    let _e258 = r_8;
    param_69 = _e258;
    let _e259 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_69));
    let _e260 = param_69;
    r_8 = _e260;
    pairing = (_e259 % 3u);
    let _e262 = pairing;
    if (_e262 == 0u) {
        pairs = array<vec2<i32>, 2>(vec2<i32>(0i, 1i), vec2<i32>(2i, 3i));
    } else {
        let _e264 = pairing;
        if (_e264 == 1u) {
            pairs = array<vec2<i32>, 2>(vec2<i32>(0i, 2i), vec2<i32>(1i, 3i));
        } else {
            pairs = array<vec2<i32>, 2>(vec2<i32>(0i, 3i), vec2<i32>(1i, 2i));
        }
    }
    k_1 = 0i;
    loop {
        let _e266 = k_1;
        if (_e266 < 2i) {
            let _e268 = k_1;
            let _e271 = pairs[_e268][0u];
            i_4 = _e271;
            let _e272 = k_1;
            let _e275 = pairs[_e272][1u];
            j = _e275;
            let _e276 = i_4;
            let _e278 = valid[_e276];
            let _e279 = !(_e278);
            phi_1453_ = _e279;
            if !(_e279) {
                let _e281 = j;
                let _e283 = valid[_e281];
                phi_1453_ = !(_e283);
            }
            let _e286 = phi_1453_;
            if _e286 {
                continue;
            }
            let _e287 = r_8;
            param_70 = _e287;
            let _e288 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_70));
            let _e289 = param_70;
            r_8 = _e289;
            if (_e288 < 0.5f) {
                let _e291 = i_4;
                let _e292 = j;
                let _e293 = i_4;
                let _e294 = j;
                let _e296 = cs[_e291];
                param_71 = _e296;
                let _e298 = cs[_e292];
                param_72 = _e298;
                let _e300 = ps[_e293];
                param_73 = _e300;
                let _e302 = ps[_e294];
                param_74 = _e302;
                let _e303 = r_8;
                param_75 = _e303;
                react_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vi2_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_71), (&param_72), (&param_73), (&param_74), (&param_75));
                let _e304 = param_71;
                cs[_e291] = _e304;
                let _e306 = param_72;
                cs[_e292] = _e306;
                let _e308 = param_75;
                r_8 = _e308;
            } else {
                let _e309 = j;
                let _e310 = i_4;
                let _e311 = j;
                let _e312 = i_4;
                let _e314 = cs[_e309];
                param_76 = _e314;
                let _e316 = cs[_e310];
                param_77 = _e316;
                let _e318 = ps[_e311];
                param_78 = _e318;
                let _e320 = ps[_e312];
                param_79 = _e320;
                let _e321 = r_8;
                param_80 = _e321;
                react_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vi2_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_76), (&param_77), (&param_78), (&param_79), (&param_80));
                let _e322 = param_76;
                cs[_e309] = _e322;
                let _e324 = param_77;
                cs[_e310] = _e324;
                let _e326 = param_80;
                r_8 = _e326;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e327 = k_1;
            k_1 = (_e327 + 1i);
        }
    }
    i_5 = 0i;
    loop {
        let _e329 = i_5;
        if (_e329 < 4i) {
            let _e331 = i_5;
            let _e333 = valid[_e331];
            if _e333 {
                let _e334 = i_5;
                let _e335 = i_5;
                let _e337 = ps[_e334];
                param_81 = _e337;
                let _e339 = cs[_e335];
                param_82 = _e339;
                store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_81), (&param_82));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e340 = i_5;
            i_5 = (_e340 + 1i);
        }
    }
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
