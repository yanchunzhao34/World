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

struct FluidState {
    fluid_state: array<vec4<i32>>,
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

@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> g_base: vec2<i32>;
var<workgroup> sh_cells: array<vec4<u32>, 400>;
@group(0) @binding(3) 
var<storage> unnamed: FluidState;
var<private> cs: array<Cell, 4>;
var<private> st: array<u32, 4>;
var<private> de: array<f32, 4>;
var<private> mov: array<bool, 4>;
var<private> moved: array<bool, 4>;
@group(0) @binding(2) 
var<storage> unnamed_1: Materials;
var<private> gl_LocalInvocationIndex_1: u32;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
var<private> gl_LocalInvocationID_1: vec3<u32>;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e91 = (*c).mat;
    let _e94 = (*c).variant;
    let _e100 = (*c).flags;
    let _e106 = (*c).temp;
    let _e109 = (*c).life;
    let _e112 = (*c).aux;
    let _e118 = (*c).extra;
    return vec4<u32>((((_e91 & 255u) | ((_e94 & 255u) << bitcast<u32>(8u))) | ((_e100 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e106), ((_e109 & 65535u) | ((_e112 & 65535u) << bitcast<u32>(16u))), _e118);
}

fn mg_store_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p: ptr<function, vec2<i32>>, c_1: ptr<function, Cell>) {
    var q: vec2<i32>;
    var param: Cell;

    let _e93 = (*p);
    let _e94 = g_base;
    q = (_e93 - _e94);
    let _e97 = q[1u];
    let _e100 = q[0u];
    let _e102 = (*c_1);
    param = _e102;
    let _e103 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param));
    sh_cells[((_e97 * 20i) + _e100)] = _e103;
    return;
}

fn set_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b(c_2: ptr<function, Cell>, v: ptr<function, u32>) {
    let _e92 = (*c_2).extra;
    let _e94 = (*v);
    (*c_2).extra = ((_e92 & 4294967040u) | min(_e94, 255u));
    return;
}

fn swap_slots_u0028_i1_u003b_i1_u003b(i: ptr<function, i32>, j: ptr<function, i32>) {
    var tc: Cell;
    var ts: u32;
    var td: f32;
    var tm: bool;

    let _e95 = (*i);
    let _e97 = cs[_e95];
    tc = _e97;
    let _e98 = (*i);
    let _e99 = (*j);
    let _e101 = cs[_e99];
    cs[_e98] = _e101;
    let _e103 = (*j);
    let _e104 = tc;
    cs[_e103] = _e104;
    let _e106 = (*i);
    let _e108 = st[_e106];
    ts = _e108;
    let _e109 = (*i);
    let _e110 = (*j);
    let _e112 = st[_e110];
    st[_e109] = _e112;
    let _e114 = (*j);
    let _e115 = ts;
    st[_e114] = _e115;
    let _e117 = (*i);
    let _e119 = de[_e117];
    td = _e119;
    let _e120 = (*i);
    let _e121 = (*j);
    let _e123 = de[_e121];
    de[_e120] = _e123;
    let _e125 = (*j);
    let _e126 = td;
    de[_e125] = _e126;
    let _e128 = (*i);
    let _e130 = mov[_e128];
    tm = _e130;
    let _e131 = (*i);
    let _e132 = (*j);
    let _e134 = mov[_e132];
    mov[_e131] = _e134;
    let _e136 = (*j);
    let _e137 = tm;
    mov[_e136] = _e137;
    let _e139 = (*i);
    moved[_e139] = true;
    let _e141 = (*j);
    moved[_e141] = true;
    return;
}

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e90 = (*x);
    return (f32((_e90 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b(r: ptr<function, Rng>) -> u32 {
    let _e91 = (*r).s;
    let _e95 = (*r).s;
    (*r).s = (_e95 ^ (_e91 << bitcast<u32>(13u)));
    let _e99 = (*r).s;
    let _e103 = (*r).s;
    (*r).s = (_e103 ^ (_e99 >> bitcast<u32>(17u)));
    let _e107 = (*r).s;
    let _e111 = (*r).s;
    (*r).s = (_e111 ^ (_e107 << bitcast<u32>(5u)));
    let _e115 = (*r).s;
    return _e115;
}

fn rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b(r_1: ptr<function, Rng>) -> f32 {
    var param_1: Rng;
    var param_2: u32;

    let _e92 = (*r_1);
    param_1 = _e92;
    let _e93 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_1));
    let _e94 = param_1;
    (*r_1) = _e94;
    param_2 = _e93;
    let _e95 = u01_u0028_u1_u003b((&param_2));
    return _e95;
}

fn cell_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c_3: ptr<function, Cell>) -> u32 {
    let _e91 = (*c_3).extra;
    return (_e91 & 255u);
}

fn lateral_u0028_i1_u003b_i1_u003b_struct_u002d_Rng_u002d_u11_u003b_vf2_u003b(l: ptr<function, i32>, r_2: ptr<function, i32>, rng: ptr<function, Rng>, wind: ptr<function, vec2<f32>>) {
    var sl: u32;
    var sr: u32;
    var liq: i32;
    var towardRight: bool;
    var dirRight: bool;
    var visc: f32;
    var p_1: f32;
    var param_3: Cell;
    var param_4: Rng;
    var param_5: i32;
    var param_6: i32;
    var param_7: Rng;
    var param_8: i32;
    var param_9: i32;
    var p_2: f32;
    var lHeavy: bool;
    var rHeavy: bool;
    var param_10: Rng;
    var param_11: i32;
    var param_12: i32;
    var phi_1083_: bool;
    var phi_1091_: bool;
    var phi_1099_: bool;
    var phi_1124_: bool;
    var phi_1165_: bool;
    var phi_1171_: bool;
    var phi_1180_: bool;
    var phi_1224_: bool;
    var phi_1244_: bool;
    var phi_1269_: bool;
    var phi_1300_: bool;

    let _e113 = (*l);
    let _e115 = moved[_e113];
    phi_1083_ = _e115;
    if !(_e115) {
        let _e117 = (*r_2);
        let _e119 = moved[_e117];
        phi_1083_ = _e119;
    }
    let _e121 = phi_1083_;
    phi_1091_ = _e121;
    if !(_e121) {
        let _e123 = (*l);
        let _e125 = mov[_e123];
        phi_1091_ = !(_e125);
    }
    let _e128 = phi_1091_;
    phi_1099_ = _e128;
    if !(_e128) {
        let _e130 = (*r_2);
        let _e132 = mov[_e130];
        phi_1099_ = !(_e132);
    }
    let _e135 = phi_1099_;
    if _e135 {
        return;
    }
    let _e136 = (*l);
    let _e138 = st[_e136];
    sl = _e138;
    let _e139 = (*r_2);
    let _e141 = st[_e139];
    sr = _e141;
    let _e142 = sl;
    let _e144 = sr;
    let _e146 = ((_e142 == 1u) && (_e144 == 0u));
    phi_1124_ = _e146;
    if !(_e146) {
        let _e148 = sr;
        let _e150 = sl;
        phi_1124_ = ((_e148 == 1u) && (_e150 == 0u));
    }
    let _e154 = phi_1124_;
    if _e154 {
        let _e155 = sl;
        let _e157 = (*l);
        let _e158 = (*r_2);
        liq = select(_e158, _e157, (_e155 == 1u));
        let _e160 = liq;
        let _e161 = (*l);
        towardRight = (_e160 == _e161);
        let _e163 = liq;
        let _e166 = cs[_e163].flags;
        dirRight = ((_e166 & 2u) != 0u);
        let _e169 = liq;
        let _e172 = cs[_e169].mat;
        let _e177 = unnamed_1.mats[_e172].phys[1u];
        visc = _e177;
        let _e178 = visc;
        let _e180 = dirRight;
        let _e181 = towardRight;
        p_1 = ((1f - _e178) * select(0.3f, 0.97f, (_e180 == _e181)));
        let _e185 = (*l);
        let _e186 = (_e185 == 0i);
        phi_1165_ = _e186;
        if _e186 {
            let _e188 = st[2i];
            phi_1165_ = (_e188 != 0u);
        }
        let _e191 = phi_1165_;
        phi_1171_ = _e191;
        if _e191 {
            let _e193 = st[3i];
            phi_1171_ = (_e193 != 0u);
        }
        let _e196 = phi_1171_;
        phi_1180_ = _e196;
        if _e196 {
            let _e197 = liq;
            let _e199 = cs[_e197];
            param_3 = _e199;
            let _e200 = cell_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_3));
            phi_1180_ = (_e200 == 0u);
        }
        let _e203 = phi_1180_;
        if _e203 {
            let _e204 = p_1;
            p_1 = (_e204 * 0.01f);
        }
        let _e206 = (*rng);
        param_4 = _e206;
        let _e207 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_4));
        let _e208 = param_4;
        (*rng) = _e208;
        let _e209 = p_1;
        if (_e207 < _e209) {
            let _e211 = towardRight;
            if _e211 {
                let _e212 = liq;
                let _e215 = cs[_e212].flags;
                cs[_e212].flags = (_e215 | 2u);
            } else {
                let _e219 = liq;
                let _e222 = cs[_e219].flags;
                cs[_e219].flags = (_e222 & 4294967293u);
            }
            let _e226 = (*l);
            param_5 = _e226;
            let _e227 = (*r_2);
            param_6 = _e227;
            swap_slots_u0028_i1_u003b_i1_u003b((&param_5), (&param_6));
        }
        return;
    }
    let _e228 = sl;
    let _e229 = (_e228 == 1u);
    phi_1224_ = _e229;
    if _e229 {
        let _e230 = (*l);
        let _e233 = cs[_e230].flags;
        phi_1224_ = ((_e233 & 2u) != 0u);
    }
    let _e237 = phi_1224_;
    let _e238 = sr;
    if (_e237 && (_e238 >= 2u)) {
        let _e241 = (*l);
        let _e244 = cs[_e241].flags;
        cs[_e241].flags = (_e244 & 4294967293u);
    }
    let _e248 = sr;
    let _e249 = (_e248 == 1u);
    phi_1244_ = _e249;
    if _e249 {
        let _e250 = (*r_2);
        let _e253 = cs[_e250].flags;
        phi_1244_ = ((_e253 & 2u) == 0u);
    }
    let _e257 = phi_1244_;
    let _e258 = sl;
    if (_e257 && (_e258 >= 2u)) {
        let _e261 = (*r_2);
        let _e264 = cs[_e261].flags;
        cs[_e261].flags = (_e264 | 2u);
    }
    let _e268 = sl;
    let _e270 = sr;
    let _e272 = ((_e268 == 1u) && (_e270 == 1u));
    phi_1269_ = _e272;
    if _e272 {
        let _e273 = (*l);
        let _e276 = cs[_e273].mat;
        let _e277 = (*r_2);
        let _e280 = cs[_e277].mat;
        phi_1269_ = (_e276 != _e280);
    }
    let _e283 = phi_1269_;
    if _e283 {
        let _e284 = (*rng);
        param_7 = _e284;
        let _e285 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_7));
        let _e286 = param_7;
        (*rng) = _e286;
        if (_e285 < 0.04f) {
            let _e288 = (*l);
            param_8 = _e288;
            let _e289 = (*r_2);
            param_9 = _e289;
            swap_slots_u0028_i1_u003b_i1_u003b((&param_8), (&param_9));
        }
        return;
    }
    let _e290 = sl;
    let _e292 = sr;
    let _e294 = ((_e290 == 0u) && (_e292 == 0u));
    phi_1300_ = _e294;
    if _e294 {
        let _e295 = (*l);
        let _e298 = cs[_e295].mat;
        let _e299 = (*r_2);
        let _e302 = cs[_e299].mat;
        phi_1300_ = (_e298 != _e302);
    }
    let _e305 = phi_1300_;
    if _e305 {
        p_2 = 0.3f;
        let _e306 = (*l);
        let _e309 = cs[_e306].mat;
        lHeavy = (_e309 != 0u);
        let _e311 = (*r_2);
        let _e314 = cs[_e311].mat;
        rHeavy = (_e314 != 0u);
        let _e317 = (*wind)[0u];
        let _e319 = lHeavy;
        let _e321 = rHeavy;
        if (((_e317 > 0f) && _e319) && !(_e321)) {
            let _e325 = (*wind)[0u];
            let _e327 = p_2;
            p_2 = (_e327 + min(_e325, 0.65f));
        }
        let _e330 = (*wind)[0u];
        let _e332 = rHeavy;
        let _e334 = lHeavy;
        if (((_e330 < 0f) && _e332) && !(_e334)) {
            let _e338 = (*wind)[0u];
            let _e341 = p_2;
            p_2 = (_e341 + min(-(_e338), 0.65f));
        }
        let _e344 = (*wind)[0u];
        let _e346 = rHeavy;
        let _e348 = lHeavy;
        if (((_e344 > 0f) && _e346) && !(_e348)) {
            let _e351 = p_2;
            p_2 = (_e351 * 0.4f);
        }
        let _e354 = (*wind)[0u];
        let _e356 = lHeavy;
        let _e358 = rHeavy;
        if (((_e354 < 0f) && _e356) && !(_e358)) {
            let _e361 = p_2;
            p_2 = (_e361 * 0.4f);
        }
        let _e363 = (*rng);
        param_10 = _e363;
        let _e364 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_10));
        let _e365 = param_10;
        (*rng) = _e365;
        let _e366 = p_2;
        if (_e364 < _e366) {
            let _e368 = (*l);
            param_11 = _e368;
            let _e369 = (*r_2);
            param_12 = _e369;
            swap_slots_u0028_i1_u003b_i1_u003b((&param_11), (&param_12));
        }
    }
    return;
}

fn fluid_u0028_u1_u003b(s: ptr<function, u32>) -> bool {
    let _e90 = (*s);
    let _e92 = (*s);
    return ((_e90 == 0u) || (_e92 == 1u));
}

fn diag_prob_u0028_i1_u003b_i1_u003b(top: ptr<function, i32>, bot: ptr<function, i32>) -> f32 {
    var param_13: u32;
    var s0_: u32;
    var m: Material;
    var phi_935_: bool;
    var phi_942_: bool;
    var phi_949_: bool;
    var phi_969_: bool;

    let _e94 = (*top);
    let _e96 = mov[_e94];
    let _e97 = !(_e96);
    phi_935_ = _e97;
    if !(_e97) {
        let _e99 = (*bot);
        let _e101 = mov[_e99];
        phi_935_ = !(_e101);
    }
    let _e104 = phi_935_;
    phi_942_ = _e104;
    if !(_e104) {
        let _e106 = (*top);
        let _e108 = moved[_e106];
        phi_942_ = _e108;
    }
    let _e110 = phi_942_;
    phi_949_ = _e110;
    if !(_e110) {
        let _e112 = (*bot);
        let _e114 = moved[_e112];
        phi_949_ = _e114;
    }
    let _e116 = phi_949_;
    if _e116 {
        return 0f;
    }
    let _e117 = (*bot);
    let _e119 = st[_e117];
    param_13 = _e119;
    let _e120 = fluid_u0028_u1_u003b((&param_13));
    let _e121 = !(_e120);
    phi_969_ = _e121;
    if !(_e121) {
        let _e123 = (*top);
        let _e125 = de[_e123];
        let _e126 = (*bot);
        let _e128 = de[_e126];
        phi_969_ = (_e125 <= _e128);
    }
    let _e131 = phi_969_;
    if _e131 {
        return 0f;
    }
    let _e132 = (*top);
    let _e134 = st[_e132];
    s0_ = _e134;
    let _e135 = (*top);
    let _e138 = cs[_e135].mat;
    let _e141 = unnamed_1.mats[_e138];
    m.color_a = _e141.color_a;
    m.color_b = _e141.color_b;
    m.emission = _e141.emission;
    m.phys = _e141.phys;
    m.thermo = _e141.thermo;
    m.burn = _e141.burn;
    m.optics = _e141.optics;
    m.scatter = _e141.scatter;
    m.ids = _e141.ids;
    m.ids2_ = _e141.ids2_;
    m.misc = _e141.misc;
    m.surface = _e141.surface;
    m.sss = _e141.sss;
    m.sss_color = _e141.sss_color;
    m.optics2_ = _e141.optics2_;
    m.pal0_ = _e141.pal0_;
    m.pal1_ = _e141.pal1_;
    m.pal2_ = _e141.pal2_;
    m.pal3_ = _e141.pal3_;
    m.accent = _e141.accent;
    m.flame = _e141.flame;
    let _e184 = s0_;
    if (_e184 == 2u) {
        let _e186 = (*bot);
        let _e188 = st[_e186];
        let _e193 = m.phys[2u];
        return (select(0.4f, 1f, (_e188 == 0u)) * (1f - _e193));
    }
    let _e196 = s0_;
    if (_e196 == 1u) {
        let _e198 = (*bot);
        let _e200 = st[_e198];
        return select(0.3f, 1f, (_e200 == 0u));
    }
    let _e203 = s0_;
    if (_e203 == 0u) {
        return 0.4f;
    }
    return 0f;
}

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e92 = (*a);
    if (_e92 >= 0i) {
        let _e94 = (*a);
        let _e95 = (*b);
        let _e98 = (*b);
        local = ((_e94 + (_e95 / 2i)) / _e98);
    } else {
        let _e100 = (*a);
        let _e102 = (*b);
        let _e105 = (*b);
        local = -(((-(_e100) + (_e102 / 2i)) / _e105));
    }
    let _e108 = local;
    return _e108;
}

fn det_q_u0028_f1_u003b_f1_u003b(v_1: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e91 = (*v_1);
    let _e92 = (*scale);
    return i32(round((_e91 * _e92)));
}

fn fall_prob_u0028_i1_u003b_i1_u003b_vf2_u003b(top_1: ptr<function, i32>, bot_1: ptr<function, i32>, wind_1: ptr<function, vec2<f32>>) -> f32 {
    var s0_1: u32;
    var s1_: u32;
    var param_14: u32;
    var dt: i32;
    var param_15: f32;
    var param_16: f32;
    var db: i32;
    var param_17: f32;
    var param_18: f32;
    var p_3: f32;
    var param_19: i32;
    var param_20: i32;
    var visc_1: f32;
    var phi_754_: bool;
    var phi_799_: bool;
    var phi_816_: bool;
    var phi_878_: bool;

    let _e105 = (*top_1);
    let _e107 = mov[_e105];
    let _e108 = !(_e107);
    phi_754_ = _e108;
    if !(_e108) {
        let _e110 = (*bot_1);
        let _e112 = mov[_e110];
        phi_754_ = !(_e112);
    }
    let _e115 = phi_754_;
    if _e115 {
        return 0f;
    }
    let _e116 = (*top_1);
    let _e118 = st[_e116];
    s0_1 = _e118;
    let _e119 = (*bot_1);
    let _e121 = st[_e119];
    s1_ = _e121;
    let _e122 = s1_;
    param_14 = _e122;
    let _e123 = fluid_u0028_u1_u003b((&param_14));
    if !(_e123) {
        return 0f;
    }
    let _e125 = (*top_1);
    let _e127 = de[_e125];
    let _e128 = (*bot_1);
    let _e130 = de[_e128];
    if (_e127 <= _e130) {
        let _e132 = s0_1;
        let _e134 = s1_;
        if ((_e132 == 0u) && (_e134 == 0u)) {
            let _e138 = (*wind_1)[1u];
            let _e139 = (_e138 > 0f);
            phi_799_ = _e139;
            if _e139 {
                let _e140 = (*top_1);
                let _e143 = cs[_e140].mat;
                phi_799_ = (_e143 != 0u);
            }
            let _e146 = phi_799_;
            if _e146 {
                let _e148 = (*wind_1)[1u];
                return min(_e148, 0.6f);
            }
            let _e151 = (*wind_1)[1u];
            let _e152 = (_e151 < 0f);
            phi_816_ = _e152;
            if _e152 {
                let _e153 = (*bot_1);
                let _e156 = cs[_e153].mat;
                phi_816_ = (_e156 != 0u);
            }
            let _e159 = phi_816_;
            if _e159 {
                let _e161 = (*wind_1)[1u];
                return min(-(_e161), 0.6f);
            }
        }
        return 0f;
    }
    let _e164 = s1_;
    if (_e164 == 0u) {
        let _e166 = s0_1;
        if (_e166 != 0u) {
            return 1f;
        }
        let _e168 = (*top_1);
        let _e170 = de[_e168];
        param_15 = min(_e170, 300f);
        param_16 = 1024f;
        let _e172 = det_q_u0028_f1_u003b_f1_u003b((&param_15), (&param_16));
        dt = _e172;
        let _e173 = (*bot_1);
        let _e175 = de[_e173];
        param_17 = min(_e175, 300f);
        param_18 = 1024f;
        let _e177 = det_q_u0028_f1_u003b_f1_u003b((&param_17), (&param_18));
        db = _e177;
        let _e178 = dt;
        let _e179 = db;
        let _e182 = dt;
        param_19 = ((_e178 - _e179) * 6144i);
        param_20 = max(_e182, 1i);
        let _e184 = det_div_u0028_i1_u003b_i1_u003b((&param_19), (&param_20));
        p_3 = clamp((f32(_e184) / 4096f), 0.08f, 0.9f);
        let _e189 = (*wind_1)[1u];
        let _e190 = (_e189 < 0f);
        phi_878_ = _e190;
        if _e190 {
            let _e191 = (*bot_1);
            let _e194 = cs[_e191].mat;
            phi_878_ = (_e194 != 0u);
        }
        let _e197 = phi_878_;
        if _e197 {
            let _e198 = p_3;
            let _e200 = (*wind_1)[1u];
            p_3 = max(_e198, min(-(_e200), 0.6f));
        }
        let _e204 = p_3;
        return _e204;
    }
    let _e205 = (*bot_1);
    let _e208 = cs[_e205].mat;
    let _e213 = unnamed_1.mats[_e208].phys[1u];
    visc_1 = _e213;
    let _e214 = s0_1;
    if (_e214 == 2u) {
        let _e216 = visc_1;
        return ((0.55f * (1f - _e216)) + 0.05f);
    }
    let _e220 = s0_1;
    if (_e220 == 1u) {
        let _e222 = visc_1;
        return ((0.35f * (1f - _e222)) + 0.05f);
    }
    return 0f;
}

fn lerp256_u0028_i1_u003b_i1_u003b_i1_u003b(a_1: ptr<function, i32>, b_1: ptr<function, i32>, f: ptr<function, i32>) -> i32 {
    var param_21: i32;
    var param_22: i32;

    let _e94 = (*a_1);
    let _e95 = (*f);
    let _e98 = (*b_1);
    let _e99 = (*f);
    param_21 = ((_e94 * (256i - _e95)) + (_e98 * _e99));
    param_22 = 256i;
    let _e102 = det_div_u0028_i1_u003b_i1_u003b((&param_21), (&param_22));
    return _e102;
}

fn fluid_at_u0028_vi2_u003b(q_1: ptr<function, vec2<i32>>) -> vec2<i32> {
    var fs: vec2<i32>;

    let _e92 = pc.i0_;
    fs = (_e92.xy / vec2(4i));
    let _e96 = (*q_1);
    let _e97 = fs;
    (*q_1) = clamp(_e96, vec2<i32>(0i, 0i), (_e97 - vec2(1i)));
    let _e102 = (*q_1)[1u];
    let _e104 = fs[0u];
    let _e107 = (*q_1)[0u];
    let _e111 = unnamed.fluid_state[((_e102 * _e104) + _e107)];
    return _e111.xy;
}

fn det_floor_div_u0028_i1_u003b_i1_u003b(a_2: ptr<function, i32>, b_2: ptr<function, i32>) -> i32 {
    var local_1: i32;

    let _e92 = (*a_2);
    if (_e92 >= 0i) {
        let _e94 = (*a_2);
        let _e95 = (*b_2);
        local_1 = (_e94 / _e95);
    } else {
        let _e97 = (*a_2);
        let _e99 = (*b_2);
        let _e102 = (*b_2);
        local_1 = -((((-(_e97) + _e99) - 1i) / _e102));
    }
    let _e105 = local_1;
    return _e105;
}

fn wind_at_u0028_vi2_u003b(origin: ptr<function, vec2<i32>>) -> vec2<f32> {
    var src: vec2<i32>;
    var base: vec2<i32>;
    var param_23: i32;
    var param_24: i32;
    var param_25: i32;
    var param_26: i32;
    var f_1: vec2<i32>;
    var a_3: vec2<i32>;
    var param_27: vec2<i32>;
    var b_3: vec2<i32>;
    var param_28: vec2<i32>;
    var c_4: vec2<i32>;
    var param_29: vec2<i32>;
    var d: vec2<i32>;
    var param_30: vec2<i32>;
    var tx: i32;
    var param_31: i32;
    var param_32: i32;
    var param_33: i32;
    var ty: i32;
    var param_34: i32;
    var param_35: i32;
    var param_36: i32;
    var bx: i32;
    var param_37: i32;
    var param_38: i32;
    var param_39: i32;
    var by: i32;
    var param_40: i32;
    var param_41: i32;
    var param_42: i32;
    var v_2: vec2<i32>;
    var param_43: i32;
    var param_44: i32;
    var param_45: i32;
    var param_46: i32;
    var param_47: i32;
    var param_48: i32;
    var k: i32;
    var param_49: f32;
    var param_50: f32;
    var param_51: i32;
    var param_52: i32;
    var param_53: i32;
    var param_54: i32;

    let _e135 = (*origin);
    src = (((_e135 + vec2(1i)) * vec2(64i)) - vec2(128i));
    let _e143 = src[0u];
    param_23 = _e143;
    param_24 = 256i;
    let _e144 = det_floor_div_u0028_i1_u003b_i1_u003b((&param_23), (&param_24));
    let _e146 = src[1u];
    param_25 = _e146;
    param_26 = 256i;
    let _e147 = det_floor_div_u0028_i1_u003b_i1_u003b((&param_25), (&param_26));
    base = vec2<i32>(_e144, _e147);
    let _e149 = src;
    let _e150 = base;
    f_1 = (_e149 - (_e150 * vec2(256i)));
    let _e154 = base;
    param_27 = _e154;
    let _e155 = fluid_at_u0028_vi2_u003b((&param_27));
    a_3 = _e155;
    let _e156 = base;
    param_28 = (_e156 + vec2<i32>(1i, 0i));
    let _e158 = fluid_at_u0028_vi2_u003b((&param_28));
    b_3 = _e158;
    let _e159 = base;
    param_29 = (_e159 + vec2<i32>(0i, 1i));
    let _e161 = fluid_at_u0028_vi2_u003b((&param_29));
    c_4 = _e161;
    let _e162 = base;
    param_30 = (_e162 + vec2<i32>(1i, 1i));
    let _e164 = fluid_at_u0028_vi2_u003b((&param_30));
    d = _e164;
    let _e166 = a_3[0u];
    param_31 = _e166;
    let _e168 = b_3[0u];
    param_32 = _e168;
    let _e170 = f_1[0u];
    param_33 = _e170;
    let _e171 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_31), (&param_32), (&param_33));
    tx = _e171;
    let _e173 = a_3[1u];
    param_34 = _e173;
    let _e175 = b_3[1u];
    param_35 = _e175;
    let _e177 = f_1[0u];
    param_36 = _e177;
    let _e178 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_34), (&param_35), (&param_36));
    ty = _e178;
    let _e180 = c_4[0u];
    param_37 = _e180;
    let _e182 = d[0u];
    param_38 = _e182;
    let _e184 = f_1[0u];
    param_39 = _e184;
    let _e185 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_37), (&param_38), (&param_39));
    bx = _e185;
    let _e187 = c_4[1u];
    param_40 = _e187;
    let _e189 = d[1u];
    param_41 = _e189;
    let _e191 = f_1[0u];
    param_42 = _e191;
    let _e192 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_40), (&param_41), (&param_42));
    by = _e192;
    let _e193 = tx;
    param_43 = _e193;
    let _e194 = bx;
    param_44 = _e194;
    let _e196 = f_1[1u];
    param_45 = _e196;
    let _e197 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_43), (&param_44), (&param_45));
    let _e198 = ty;
    param_46 = _e198;
    let _e199 = by;
    param_47 = _e199;
    let _e201 = f_1[1u];
    param_48 = _e201;
    let _e202 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_46), (&param_47), (&param_48));
    v_2 = vec2<i32>(_e197, _e202);
    let _e206 = pc.f0_[0u];
    param_49 = _e206;
    param_50 = 4096f;
    let _e207 = det_q_u0028_f1_u003b_f1_u003b((&param_49), (&param_50));
    k = _e207;
    let _e209 = v_2[0u];
    let _e211 = k;
    param_51 = ((_e209 / 16i) * _e211);
    param_52 = 256i;
    let _e213 = det_div_u0028_i1_u003b_i1_u003b((&param_51), (&param_52));
    let _e216 = v_2[1u];
    let _e218 = k;
    param_53 = ((_e216 / 16i) * _e218);
    param_54 = 256i;
    let _e220 = det_div_u0028_i1_u003b_i1_u003b((&param_53), (&param_54));
    return (vec2<f32>(f32(_e213), f32(_e220)) / vec2(65536f));
}

fn pcg3d_u0028_vu3_u003b(v_3: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e90 = (*v_3);
    (*v_3) = ((_e90 * vec3(1664525u)) + vec3(1013904223u));
    let _e96 = (*v_3)[1u];
    let _e98 = (*v_3)[2u];
    let _e101 = (*v_3)[0u];
    (*v_3)[0u] = (_e101 + (_e96 * _e98));
    let _e105 = (*v_3)[2u];
    let _e107 = (*v_3)[0u];
    let _e110 = (*v_3)[1u];
    (*v_3)[1u] = (_e110 + (_e105 * _e107));
    let _e114 = (*v_3)[0u];
    let _e116 = (*v_3)[1u];
    let _e119 = (*v_3)[2u];
    (*v_3)[2u] = (_e119 + (_e114 * _e116));
    let _e122 = (*v_3);
    let _e126 = (*v_3);
    (*v_3) = (_e126 ^ (_e122 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e129 = (*v_3)[1u];
    let _e131 = (*v_3)[2u];
    let _e134 = (*v_3)[0u];
    (*v_3)[0u] = (_e134 + (_e129 * _e131));
    let _e138 = (*v_3)[2u];
    let _e140 = (*v_3)[0u];
    let _e143 = (*v_3)[1u];
    (*v_3)[1u] = (_e143 + (_e138 * _e140));
    let _e147 = (*v_3)[0u];
    let _e149 = (*v_3)[1u];
    let _e152 = (*v_3)[2u];
    (*v_3)[2u] = (_e152 + (_e147 * _e149));
    let _e155 = (*v_3);
    return _e155;
}

fn rng_init_u0028_vu3_u003b(seed: ptr<function, vec3<u32>>) -> Rng {
    var r_3: Rng;
    var param_55: vec3<u32>;

    let _e92 = (*seed);
    param_55 = _e92;
    let _e93 = pcg3d_u0028_vu3_u003b((&param_55));
    r_3.s = (_e93.x | 1u);
    let _e97 = r_3;
    return _e97;
}

fn unpack_cell_u0028_vu4_u003b(v_4: ptr<function, vec4<u32>>) -> Cell {
    var c_5: Cell;

    let _e92 = (*v_4)[0u];
    c_5.mat = (_e92 & 255u);
    let _e96 = (*v_4)[0u];
    c_5.variant = ((_e96 >> bitcast<u32>(8u)) & 255u);
    let _e102 = (*v_4)[0u];
    c_5.flags = (_e102 >> bitcast<u32>(16u));
    let _e107 = (*v_4)[1u];
    c_5.temp = bitcast<f32>(_e107);
    let _e111 = (*v_4)[2u];
    c_5.life = (_e111 & 65535u);
    let _e115 = (*v_4)[2u];
    c_5.aux = (_e115 >> bitcast<u32>(16u));
    let _e120 = (*v_4)[3u];
    c_5.extra = _e120;
    let _e122 = c_5;
    return _e122;
}

fn mg_load_u0028_vi2_u003b(p_4: ptr<function, vec2<i32>>) -> Cell {
    var q_2: vec2<i32>;
    var param_56: vec4<u32>;

    let _e92 = (*p_4);
    let _e93 = g_base;
    q_2 = (_e92 - _e93);
    let _e96 = q_2[1u];
    let _e99 = q_2[0u];
    let _e102 = sh_cells[((_e96 * 20i) + _e99)];
    param_56 = _e102;
    let _e103 = unpack_cell_u0028_vu4_u003b((&param_56));
    return _e103;
}

fn in_world_u0028_vi2_u003b(p_5: ptr<function, vec2<i32>>) -> bool {
    var phi_278_: bool;
    var phi_292_: bool;
    var phi_300_: bool;

    let _e91 = (*p_5)[0u];
    let _e92 = (_e91 >= 0i);
    phi_278_ = _e92;
    if _e92 {
        let _e94 = (*p_5)[1u];
        phi_278_ = (_e94 >= 0i);
    }
    let _e97 = phi_278_;
    phi_292_ = _e97;
    if _e97 {
        let _e99 = (*p_5)[0u];
        let _e102 = pc.i0_[0u];
        phi_292_ = (_e99 < _e102);
    }
    let _e105 = phi_292_;
    phi_300_ = _e105;
    if _e105 {
        let _e107 = (*p_5)[1u];
        let _e110 = pc.i0_[1u];
        phi_300_ = (_e107 < _e110);
    }
    let _e113 = phi_300_;
    return _e113;
}

fn mg_block_u0028_vi2_u003b_u1_u003b(origin_1: ptr<function, vec2<i32>>, substep: ptr<function, u32>) {
    var ps: array<vec2<i32>, 4>;
    var i_1: i32;
    var valid: array<bool, 4>;
    var param_57: vec2<i32>;
    var param_58: vec2<i32>;
    var m_1: Material;
    var rng_1: Rng;
    var param_59: vec3<u32>;
    var wind_2: vec2<f32>;
    var param_60: vec2<i32>;
    var col: i32;
    var p_6: f32;
    var param_61: i32;
    var param_62: i32;
    var param_63: vec2<f32>;
    var param_64: Rng;
    var param_65: i32;
    var param_66: i32;
    var first: bool;
    var param_67: Rng;
    var k_1: i32;
    var top_2: i32;
    var bot_2: i32;
    var p_7: f32;
    var param_68: i32;
    var param_69: i32;
    var param_70: Rng;
    var param_71: i32;
    var param_72: i32;
    var param_73: i32;
    var param_74: i32;
    var param_75: Rng;
    var param_76: vec2<f32>;
    var param_77: i32;
    var param_78: i32;
    var param_79: Rng;
    var param_80: vec2<f32>;
    var i_2: i32;
    var param_81: Cell;
    var param_82: u32;
    var param_83: vec2<i32>;
    var param_84: Cell;
    var phi_1546_: bool;
    var phi_1597_: bool;
    var phi_1645_: bool;

    let _e133 = (*origin_1);
    let _e134 = (*origin_1);
    let _e136 = (*origin_1);
    let _e138 = (*origin_1);
    ps = array<vec2<i32>, 4>(_e133, (_e134 + vec2<i32>(1i, 0i)), (_e136 + vec2<i32>(0i, 1i)), (_e138 + vec2<i32>(1i, 1i)));
    i_1 = 0i;
    loop {
        let _e141 = i_1;
        if (_e141 < 4i) {
            let _e143 = i_1;
            let _e144 = i_1;
            let _e146 = ps[_e144];
            param_57 = _e146;
            let _e147 = in_world_u0028_vi2_u003b((&param_57));
            valid[_e143] = _e147;
            let _e149 = i_1;
            moved[_e149] = false;
            let _e151 = i_1;
            let _e153 = valid[_e151];
            if _e153 {
                let _e154 = i_1;
                let _e155 = i_1;
                let _e157 = ps[_e155];
                param_58 = _e157;
                let _e158 = mg_load_u0028_vi2_u003b((&param_58));
                cs[_e154] = _e158;
                let _e160 = i_1;
                let _e163 = cs[_e160].mat;
                let _e166 = unnamed_1.mats[_e163];
                m_1.color_a = _e166.color_a;
                m_1.color_b = _e166.color_b;
                m_1.emission = _e166.emission;
                m_1.phys = _e166.phys;
                m_1.thermo = _e166.thermo;
                m_1.burn = _e166.burn;
                m_1.optics = _e166.optics;
                m_1.scatter = _e166.scatter;
                m_1.ids = _e166.ids;
                m_1.ids2_ = _e166.ids2_;
                m_1.misc = _e166.misc;
                m_1.surface = _e166.surface;
                m_1.sss = _e166.sss;
                m_1.sss_color = _e166.sss_color;
                m_1.optics2_ = _e166.optics2_;
                m_1.pal0_ = _e166.pal0_;
                m_1.pal1_ = _e166.pal1_;
                m_1.pal2_ = _e166.pal2_;
                m_1.pal3_ = _e166.pal3_;
                m_1.accent = _e166.accent;
                m_1.flame = _e166.flame;
                let _e209 = i_1;
                let _e212 = m_1.ids[0u];
                st[_e209] = _e212;
                let _e214 = i_1;
                let _e217 = m_1.phys[0u];
                de[_e214] = _e217;
                let _e219 = i_1;
                let _e220 = i_1;
                let _e222 = st[_e220];
                mov[_e219] = (_e222 != 3u);
            } else {
                let _e225 = i_1;
                st[_e225] = 3u;
                let _e227 = i_1;
                de[_e227] = 1000000000f;
                let _e229 = i_1;
                mov[_e229] = false;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e231 = i_1;
            i_1 = (_e231 + 1i);
        }
    }
    let _e233 = (*origin_1);
    let _e236 = bitcast<vec2<u32>>((_e233 + vec2(2i)));
    let _e239 = pc.i0_[2u];
    let _e242 = (*substep);
    param_59 = vec3<u32>(_e236.x, _e236.y, ((bitcast<u32>(_e239) * 8u) + _e242));
    let _e247 = rng_init_u0028_vu3_u003b((&param_59));
    rng_1 = _e247;
    let _e248 = (*origin_1);
    param_60 = _e248;
    let _e249 = wind_at_u0028_vi2_u003b((&param_60));
    wind_2 = _e249;
    col = 0i;
    loop {
        let _e250 = col;
        if (_e250 < 2i) {
            let _e252 = col;
            let _e254 = col;
            param_61 = _e254;
            param_62 = (_e252 + 2i);
            let _e255 = wind_2;
            param_63 = _e255;
            let _e256 = fall_prob_u0028_i1_u003b_i1_u003b_vf2_u003b((&param_61), (&param_62), (&param_63));
            p_6 = _e256;
            let _e257 = p_6;
            let _e258 = (_e257 > 0f);
            phi_1546_ = _e258;
            if _e258 {
                let _e259 = rng_1;
                param_64 = _e259;
                let _e260 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_64));
                let _e261 = param_64;
                rng_1 = _e261;
                let _e262 = p_6;
                phi_1546_ = (_e260 < _e262);
            }
            let _e265 = phi_1546_;
            if _e265 {
                let _e266 = col;
                let _e268 = col;
                param_65 = _e268;
                param_66 = (_e266 + 2i);
                swap_slots_u0028_i1_u003b_i1_u003b((&param_65), (&param_66));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e269 = col;
            col = (_e269 + 1i);
        }
    }
    let _e271 = rng_1;
    param_67 = _e271;
    let _e272 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_67));
    let _e273 = param_67;
    rng_1 = _e273;
    first = (_e272 < 0.5f);
    k_1 = 0i;
    loop {
        let _e275 = k_1;
        if (_e275 < 2i) {
            let _e277 = k_1;
            let _e279 = first;
            top_2 = select(1i, 0i, ((_e277 == 0i) == _e279));
            let _e282 = top_2;
            bot_2 = (3i - _e282);
            let _e284 = top_2;
            param_68 = _e284;
            let _e285 = bot_2;
            param_69 = _e285;
            let _e286 = diag_prob_u0028_i1_u003b_i1_u003b((&param_68), (&param_69));
            p_7 = _e286;
            let _e287 = p_7;
            let _e288 = (_e287 > 0f);
            phi_1597_ = _e288;
            if _e288 {
                let _e289 = rng_1;
                param_70 = _e289;
                let _e290 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_70));
                let _e291 = param_70;
                rng_1 = _e291;
                let _e292 = p_7;
                phi_1597_ = (_e290 < _e292);
            }
            let _e295 = phi_1597_;
            if _e295 {
                let _e296 = top_2;
                param_71 = _e296;
                let _e297 = bot_2;
                param_72 = _e297;
                swap_slots_u0028_i1_u003b_i1_u003b((&param_71), (&param_72));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e298 = k_1;
            k_1 = (_e298 + 1i);
        }
    }
    param_73 = 2i;
    param_74 = 3i;
    let _e300 = rng_1;
    param_75 = _e300;
    let _e301 = wind_2;
    param_76 = _e301;
    lateral_u0028_i1_u003b_i1_u003b_struct_u002d_Rng_u002d_u11_u003b_vf2_u003b((&param_73), (&param_74), (&param_75), (&param_76));
    let _e302 = param_75;
    rng_1 = _e302;
    param_77 = 0i;
    param_78 = 1i;
    let _e303 = rng_1;
    param_79 = _e303;
    let _e304 = wind_2;
    param_80 = _e304;
    lateral_u0028_i1_u003b_i1_u003b_struct_u002d_Rng_u002d_u11_u003b_vf2_u003b((&param_77), (&param_78), (&param_79), (&param_80));
    let _e305 = param_79;
    rng_1 = _e305;
    i_2 = 0i;
    loop {
        let _e306 = i_2;
        if (_e306 < 4i) {
            let _e308 = i_2;
            let _e310 = valid[_e308];
            if _e310 {
                let _e311 = i_2;
                let _e313 = moved[_e311];
                phi_1645_ = _e313;
                if _e313 {
                    let _e314 = i_2;
                    let _e316 = st[_e314];
                    phi_1645_ = (_e316 == 1u);
                }
                let _e319 = phi_1645_;
                if _e319 {
                    let _e320 = i_2;
                    let _e322 = cs[_e320];
                    param_81 = _e322;
                    param_82 = 255u;
                    set_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b((&param_81), (&param_82));
                    let _e323 = param_81;
                    cs[_e320] = _e323;
                }
                let _e325 = i_2;
                let _e326 = i_2;
                let _e328 = ps[_e325];
                param_83 = _e328;
                let _e330 = cs[_e326];
                param_84 = _e330;
                mg_store_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_83), (&param_84));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e331 = i_2;
            i_2 = (_e331 + 1i);
        }
    }
    return;
}

fn substep_over_u0028_vi2_u003b_vi2_u003b_u1_u003b_u1_u003b(lo: ptr<function, vec2<i32>>, hi: ptr<function, vec2<i32>>, sub: ptr<function, u32>, li: ptr<function, u32>) {
    var off: vec2<i32>;
    var indexable: array<vec2<i32>, 4>;
    var o0_: vec2<i32>;
    var n: vec2<i32>;
    var o: vec2<i32>;
    var param_85: vec2<i32>;
    var param_86: u32;
    var phi_1734_: bool;

    let _e100 = (*sub);
    let _e103 = pc.i0_[2u];
    indexable = array<vec2<i32>, 4>(vec2<i32>(0i, 0i), vec2<i32>(1i, 1i), vec2<i32>(1i, 0i), vec2<i32>(0i, 1i));
    let _e108 = indexable[((_e100 + bitcast<u32>(_e103)) & 3u)];
    off = _e108;
    let _e109 = (*lo);
    let _e110 = (*lo);
    let _e111 = off;
    o0_ = (_e109 - ((_e110 + _e111) & vec2(1i)));
    let _e116 = (*hi);
    let _e117 = o0_;
    n = (((_e116 - _e117) + vec2(1i)) / vec2(2i));
    let _e123 = (*li);
    let _e126 = n[0u];
    let _e128 = n[1u];
    if (bitcast<i32>(_e123) >= (_e126 * _e128)) {
        return;
    }
    let _e131 = o0_;
    let _e132 = (*li);
    let _e133 = bitcast<i32>(_e132);
    let _e135 = n[0u];
    let _e143 = (*li);
    let _e146 = n[0u];
    o = (_e131 + (vec2(2i) * vec2<i32>((_e133 % _e135 + select(0i, _e135, _e133 % _e135 != 0i && ((_e133 % _e135 < 0i) != (_e135 < 0i)))), (bitcast<i32>(_e143) / _e146))));
    let _e153 = o[0u];
    let _e156 = pc.i0_[0u];
    let _e157 = (_e153 >= _e156);
    phi_1734_ = _e157;
    if !(_e157) {
        let _e160 = o[1u];
        let _e163 = pc.i0_[1u];
        phi_1734_ = (_e160 >= _e163);
    }
    let _e166 = phi_1734_;
    if _e166 {
        return;
    }
    let _e167 = o;
    param_85 = _e167;
    let _e168 = (*sub);
    param_86 = _e168;
    mg_block_u0028_vi2_u003b_u1_u003b((&param_85), (&param_86));
    return;
}

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var li_1: u32;
    var T: vec2<i32>;
    var i_3: u32;
    var p_8: vec2<i32>;
    var param_87: vec2<i32>;
    var local_2: vec4<u32>;
    var s0_2: u32;
    var param_88: vec2<i32>;
    var param_89: vec2<i32>;
    var param_90: u32;
    var param_91: u32;
    var param_92: vec2<i32>;
    var param_93: vec2<i32>;
    var param_94: u32;
    var param_95: u32;
    var p_9: vec2<i32>;
    var param_96: vec2<i32>;

    let _e106 = gl_LocalInvocationIndex_1;
    li_1 = _e106;
    let _e107 = gl_WorkGroupID_1;
    T = (bitcast<vec2<i32>>(_e107.xy) * vec2(16i));
    let _e112 = T;
    g_base = (_e112 - vec2(2i));
    let _e115 = li_1;
    i_3 = _e115;
    loop {
        let _e116 = i_3;
        if (_e116 < 400u) {
            let _e118 = g_base;
            let _e119 = i_3;
            let _e120 = bitcast<i32>(_e119);
            let _e128 = i_3;
            p_8 = (_e118 + vec2<i32>((_e120 % 20i + select(0i, 20i, _e120 % 20i != 0i && ((_e120 % 20i < 0i) != (20i < 0i)))), (bitcast<i32>(_e128) / 20i)));
            let _e133 = i_3;
            let _e134 = p_8;
            param_87 = _e134;
            let _e135 = in_world_u0028_vi2_u003b((&param_87));
            if _e135 {
                let _e136 = p_8;
                let _e137 = textureLoad(cells_in, _e136, 0i);
                local_2 = _e137;
            } else {
                local_2 = vec4<u32>(0u, 0u, 0u, 0u);
            }
            let _e138 = local_2;
            sh_cells[_e133] = _e138;
            continue;
        } else {
            break;
        }
        continuing {
            let _e140 = i_3;
            i_3 = (_e140 + 256u);
        }
    }
    workgroupBarrier();
    let _e144 = pc.i0_[3u];
    s0_2 = bitcast<u32>(_e144);
    let _e146 = T;
    let _e149 = T;
    param_88 = (_e146 - vec2(1i));
    param_89 = ((_e149 + vec2(16i)) + vec2(1i));
    let _e154 = s0_2;
    param_90 = _e154;
    let _e155 = li_1;
    param_91 = _e155;
    substep_over_u0028_vi2_u003b_vi2_u003b_u1_u003b_u1_u003b((&param_88), (&param_89), (&param_90), (&param_91));
    workgroupBarrier();
    let _e156 = T;
    let _e159 = s0_2;
    let _e161 = T;
    param_92 = _e161;
    param_93 = (_e156 + vec2(16i));
    param_94 = (_e159 + 1u);
    let _e162 = li_1;
    param_95 = _e162;
    substep_over_u0028_vi2_u003b_vi2_u003b_u1_u003b_u1_u003b((&param_92), (&param_93), (&param_94), (&param_95));
    workgroupBarrier();
    let _e163 = T;
    let _e164 = gl_LocalInvocationID_1;
    p_9 = (_e163 + bitcast<vec2<i32>>(_e164.xy));
    let _e168 = p_9;
    param_96 = _e168;
    let _e169 = in_world_u0028_vi2_u003b((&param_96));
    if _e169 {
        let _e170 = p_9;
        let _e172 = gl_LocalInvocationID_1[1u];
        let _e177 = gl_LocalInvocationID_1[0u];
        let _e182 = sh_cells[((((bitcast<i32>(_e172) + 2i) * 20i) + bitcast<i32>(_e177)) + 2i)];
        textureStore(cells_out, _e170, _e182);
    }
    return;
}

@compute @workgroup_size(16, 16, 1) 
fn main(@builtin(local_invocation_index) gl_LocalInvocationIndex: u32, @builtin(workgroup_id) gl_WorkGroupID: vec3<u32>, @builtin(local_invocation_id) gl_LocalInvocationID: vec3<u32>) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    gl_LocalInvocationID_1 = gl_LocalInvocationID;
    main_1(gl_WorkGroupID);
}
