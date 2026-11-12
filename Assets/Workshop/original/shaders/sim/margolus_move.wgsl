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
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;
@group(0) @binding(3) 
var<storage> unnamed: FluidState;
var<private> cs: array<Cell, 4>;
var<private> st: array<u32, 4>;
var<private> de: array<f32, 4>;
var<private> mov: array<bool, 4>;
var<private> moved: array<bool, 4>;
@group(0) @binding(2) 
var<storage> unnamed_1: Materials;
var<private> gl_GlobalInvocationID_1: vec3<u32>;

fn set_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b(c: ptr<function, Cell>, v: ptr<function, u32>) {
    let _e83 = (*c).extra;
    let _e85 = (*v);
    (*c).extra = ((_e83 & 4294967040u) | min(_e85, 255u));
    return;
}

fn swap_slots_u0028_i1_u003b_i1_u003b(i: ptr<function, i32>, j: ptr<function, i32>) {
    var tc: Cell;
    var ts: u32;
    var td: f32;
    var tm: bool;

    let _e86 = (*i);
    let _e88 = cs[_e86];
    tc = _e88;
    let _e89 = (*i);
    let _e90 = (*j);
    let _e92 = cs[_e90];
    cs[_e89] = _e92;
    let _e94 = (*j);
    let _e95 = tc;
    cs[_e94] = _e95;
    let _e97 = (*i);
    let _e99 = st[_e97];
    ts = _e99;
    let _e100 = (*i);
    let _e101 = (*j);
    let _e103 = st[_e101];
    st[_e100] = _e103;
    let _e105 = (*j);
    let _e106 = ts;
    st[_e105] = _e106;
    let _e108 = (*i);
    let _e110 = de[_e108];
    td = _e110;
    let _e111 = (*i);
    let _e112 = (*j);
    let _e114 = de[_e112];
    de[_e111] = _e114;
    let _e116 = (*j);
    let _e117 = td;
    de[_e116] = _e117;
    let _e119 = (*i);
    let _e121 = mov[_e119];
    tm = _e121;
    let _e122 = (*i);
    let _e123 = (*j);
    let _e125 = mov[_e123];
    mov[_e122] = _e125;
    let _e127 = (*j);
    let _e128 = tm;
    mov[_e127] = _e128;
    let _e130 = (*i);
    moved[_e130] = true;
    let _e132 = (*j);
    moved[_e132] = true;
    return;
}

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e81 = (*x);
    return (f32((_e81 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b(r: ptr<function, Rng>) -> u32 {
    let _e82 = (*r).s;
    let _e86 = (*r).s;
    (*r).s = (_e86 ^ (_e82 << bitcast<u32>(13u)));
    let _e90 = (*r).s;
    let _e94 = (*r).s;
    (*r).s = (_e94 ^ (_e90 >> bitcast<u32>(17u)));
    let _e98 = (*r).s;
    let _e102 = (*r).s;
    (*r).s = (_e102 ^ (_e98 << bitcast<u32>(5u)));
    let _e106 = (*r).s;
    return _e106;
}

fn rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b(r_1: ptr<function, Rng>) -> f32 {
    var param: Rng;
    var param_1: u32;

    let _e83 = (*r_1);
    param = _e83;
    let _e84 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param));
    let _e85 = param;
    (*r_1) = _e85;
    param_1 = _e84;
    let _e86 = u01_u0028_u1_u003b((&param_1));
    return _e86;
}

fn cell_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c_1: ptr<function, Cell>) -> u32 {
    let _e82 = (*c_1).extra;
    return (_e82 & 255u);
}

fn lateral_u0028_i1_u003b_i1_u003b_struct_u002d_Rng_u002d_u11_u003b_vf2_u003b(l: ptr<function, i32>, r_2: ptr<function, i32>, rng: ptr<function, Rng>, wind: ptr<function, vec2<f32>>) {
    var sl: u32;
    var sr: u32;
    var liq: i32;
    var towardRight: bool;
    var dirRight: bool;
    var visc: f32;
    var p: f32;
    var param_2: Cell;
    var param_3: Rng;
    var param_4: i32;
    var param_5: i32;
    var param_6: Rng;
    var param_7: i32;
    var param_8: i32;
    var p_1: f32;
    var lHeavy: bool;
    var rHeavy: bool;
    var param_9: Rng;
    var param_10: i32;
    var param_11: i32;
    var phi_1052_: bool;
    var phi_1060_: bool;
    var phi_1068_: bool;
    var phi_1093_: bool;
    var phi_1134_: bool;
    var phi_1140_: bool;
    var phi_1149_: bool;
    var phi_1193_: bool;
    var phi_1213_: bool;
    var phi_1238_: bool;
    var phi_1269_: bool;

    let _e104 = (*l);
    let _e106 = moved[_e104];
    phi_1052_ = _e106;
    if !(_e106) {
        let _e108 = (*r_2);
        let _e110 = moved[_e108];
        phi_1052_ = _e110;
    }
    let _e112 = phi_1052_;
    phi_1060_ = _e112;
    if !(_e112) {
        let _e114 = (*l);
        let _e116 = mov[_e114];
        phi_1060_ = !(_e116);
    }
    let _e119 = phi_1060_;
    phi_1068_ = _e119;
    if !(_e119) {
        let _e121 = (*r_2);
        let _e123 = mov[_e121];
        phi_1068_ = !(_e123);
    }
    let _e126 = phi_1068_;
    if _e126 {
        return;
    }
    let _e127 = (*l);
    let _e129 = st[_e127];
    sl = _e129;
    let _e130 = (*r_2);
    let _e132 = st[_e130];
    sr = _e132;
    let _e133 = sl;
    let _e135 = sr;
    let _e137 = ((_e133 == 1u) && (_e135 == 0u));
    phi_1093_ = _e137;
    if !(_e137) {
        let _e139 = sr;
        let _e141 = sl;
        phi_1093_ = ((_e139 == 1u) && (_e141 == 0u));
    }
    let _e145 = phi_1093_;
    if _e145 {
        let _e146 = sl;
        let _e148 = (*l);
        let _e149 = (*r_2);
        liq = select(_e149, _e148, (_e146 == 1u));
        let _e151 = liq;
        let _e152 = (*l);
        towardRight = (_e151 == _e152);
        let _e154 = liq;
        let _e157 = cs[_e154].flags;
        dirRight = ((_e157 & 2u) != 0u);
        let _e160 = liq;
        let _e163 = cs[_e160].mat;
        let _e168 = unnamed_1.mats[_e163].phys[1u];
        visc = _e168;
        let _e169 = visc;
        let _e171 = dirRight;
        let _e172 = towardRight;
        p = ((1f - _e169) * select(0.3f, 0.97f, (_e171 == _e172)));
        let _e176 = (*l);
        let _e177 = (_e176 == 0i);
        phi_1134_ = _e177;
        if _e177 {
            let _e179 = st[2i];
            phi_1134_ = (_e179 != 0u);
        }
        let _e182 = phi_1134_;
        phi_1140_ = _e182;
        if _e182 {
            let _e184 = st[3i];
            phi_1140_ = (_e184 != 0u);
        }
        let _e187 = phi_1140_;
        phi_1149_ = _e187;
        if _e187 {
            let _e188 = liq;
            let _e190 = cs[_e188];
            param_2 = _e190;
            let _e191 = cell_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_2));
            phi_1149_ = (_e191 == 0u);
        }
        let _e194 = phi_1149_;
        if _e194 {
            let _e195 = p;
            p = (_e195 * 0.01f);
        }
        let _e197 = (*rng);
        param_3 = _e197;
        let _e198 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_3));
        let _e199 = param_3;
        (*rng) = _e199;
        let _e200 = p;
        if (_e198 < _e200) {
            let _e202 = towardRight;
            if _e202 {
                let _e203 = liq;
                let _e206 = cs[_e203].flags;
                cs[_e203].flags = (_e206 | 2u);
            } else {
                let _e210 = liq;
                let _e213 = cs[_e210].flags;
                cs[_e210].flags = (_e213 & 4294967293u);
            }
            let _e217 = (*l);
            param_4 = _e217;
            let _e218 = (*r_2);
            param_5 = _e218;
            swap_slots_u0028_i1_u003b_i1_u003b((&param_4), (&param_5));
        }
        return;
    }
    let _e219 = sl;
    let _e220 = (_e219 == 1u);
    phi_1193_ = _e220;
    if _e220 {
        let _e221 = (*l);
        let _e224 = cs[_e221].flags;
        phi_1193_ = ((_e224 & 2u) != 0u);
    }
    let _e228 = phi_1193_;
    let _e229 = sr;
    if (_e228 && (_e229 >= 2u)) {
        let _e232 = (*l);
        let _e235 = cs[_e232].flags;
        cs[_e232].flags = (_e235 & 4294967293u);
    }
    let _e239 = sr;
    let _e240 = (_e239 == 1u);
    phi_1213_ = _e240;
    if _e240 {
        let _e241 = (*r_2);
        let _e244 = cs[_e241].flags;
        phi_1213_ = ((_e244 & 2u) == 0u);
    }
    let _e248 = phi_1213_;
    let _e249 = sl;
    if (_e248 && (_e249 >= 2u)) {
        let _e252 = (*r_2);
        let _e255 = cs[_e252].flags;
        cs[_e252].flags = (_e255 | 2u);
    }
    let _e259 = sl;
    let _e261 = sr;
    let _e263 = ((_e259 == 1u) && (_e261 == 1u));
    phi_1238_ = _e263;
    if _e263 {
        let _e264 = (*l);
        let _e267 = cs[_e264].mat;
        let _e268 = (*r_2);
        let _e271 = cs[_e268].mat;
        phi_1238_ = (_e267 != _e271);
    }
    let _e274 = phi_1238_;
    if _e274 {
        let _e275 = (*rng);
        param_6 = _e275;
        let _e276 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_6));
        let _e277 = param_6;
        (*rng) = _e277;
        if (_e276 < 0.04f) {
            let _e279 = (*l);
            param_7 = _e279;
            let _e280 = (*r_2);
            param_8 = _e280;
            swap_slots_u0028_i1_u003b_i1_u003b((&param_7), (&param_8));
        }
        return;
    }
    let _e281 = sl;
    let _e283 = sr;
    let _e285 = ((_e281 == 0u) && (_e283 == 0u));
    phi_1269_ = _e285;
    if _e285 {
        let _e286 = (*l);
        let _e289 = cs[_e286].mat;
        let _e290 = (*r_2);
        let _e293 = cs[_e290].mat;
        phi_1269_ = (_e289 != _e293);
    }
    let _e296 = phi_1269_;
    if _e296 {
        p_1 = 0.3f;
        let _e297 = (*l);
        let _e300 = cs[_e297].mat;
        lHeavy = (_e300 != 0u);
        let _e302 = (*r_2);
        let _e305 = cs[_e302].mat;
        rHeavy = (_e305 != 0u);
        let _e308 = (*wind)[0u];
        let _e310 = lHeavy;
        let _e312 = rHeavy;
        if (((_e308 > 0f) && _e310) && !(_e312)) {
            let _e316 = (*wind)[0u];
            let _e318 = p_1;
            p_1 = (_e318 + min(_e316, 0.65f));
        }
        let _e321 = (*wind)[0u];
        let _e323 = rHeavy;
        let _e325 = lHeavy;
        if (((_e321 < 0f) && _e323) && !(_e325)) {
            let _e329 = (*wind)[0u];
            let _e332 = p_1;
            p_1 = (_e332 + min(-(_e329), 0.65f));
        }
        let _e335 = (*wind)[0u];
        let _e337 = rHeavy;
        let _e339 = lHeavy;
        if (((_e335 > 0f) && _e337) && !(_e339)) {
            let _e342 = p_1;
            p_1 = (_e342 * 0.4f);
        }
        let _e345 = (*wind)[0u];
        let _e347 = lHeavy;
        let _e349 = rHeavy;
        if (((_e345 < 0f) && _e347) && !(_e349)) {
            let _e352 = p_1;
            p_1 = (_e352 * 0.4f);
        }
        let _e354 = (*rng);
        param_9 = _e354;
        let _e355 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_9));
        let _e356 = param_9;
        (*rng) = _e356;
        let _e357 = p_1;
        if (_e355 < _e357) {
            let _e359 = (*l);
            param_10 = _e359;
            let _e360 = (*r_2);
            param_11 = _e360;
            swap_slots_u0028_i1_u003b_i1_u003b((&param_10), (&param_11));
        }
    }
    return;
}

fn fluid_u0028_u1_u003b(s: ptr<function, u32>) -> bool {
    let _e81 = (*s);
    let _e83 = (*s);
    return ((_e81 == 0u) || (_e83 == 1u));
}

fn diag_prob_u0028_i1_u003b_i1_u003b(top: ptr<function, i32>, bot: ptr<function, i32>) -> f32 {
    var param_12: u32;
    var s0_: u32;
    var m: Material;
    var phi_903_: bool;
    var phi_910_: bool;
    var phi_917_: bool;
    var phi_937_: bool;

    let _e85 = (*top);
    let _e87 = mov[_e85];
    let _e88 = !(_e87);
    phi_903_ = _e88;
    if !(_e88) {
        let _e90 = (*bot);
        let _e92 = mov[_e90];
        phi_903_ = !(_e92);
    }
    let _e95 = phi_903_;
    phi_910_ = _e95;
    if !(_e95) {
        let _e97 = (*top);
        let _e99 = moved[_e97];
        phi_910_ = _e99;
    }
    let _e101 = phi_910_;
    phi_917_ = _e101;
    if !(_e101) {
        let _e103 = (*bot);
        let _e105 = moved[_e103];
        phi_917_ = _e105;
    }
    let _e107 = phi_917_;
    if _e107 {
        return 0f;
    }
    let _e108 = (*bot);
    let _e110 = st[_e108];
    param_12 = _e110;
    let _e111 = fluid_u0028_u1_u003b((&param_12));
    let _e112 = !(_e111);
    phi_937_ = _e112;
    if !(_e112) {
        let _e114 = (*top);
        let _e116 = de[_e114];
        let _e117 = (*bot);
        let _e119 = de[_e117];
        phi_937_ = (_e116 <= _e119);
    }
    let _e122 = phi_937_;
    if _e122 {
        return 0f;
    }
    let _e123 = (*top);
    let _e125 = st[_e123];
    s0_ = _e125;
    let _e126 = (*top);
    let _e129 = cs[_e126].mat;
    let _e132 = unnamed_1.mats[_e129];
    m.color_a = _e132.color_a;
    m.color_b = _e132.color_b;
    m.emission = _e132.emission;
    m.phys = _e132.phys;
    m.thermo = _e132.thermo;
    m.burn = _e132.burn;
    m.optics = _e132.optics;
    m.scatter = _e132.scatter;
    m.ids = _e132.ids;
    m.ids2_ = _e132.ids2_;
    m.misc = _e132.misc;
    m.surface = _e132.surface;
    m.sss = _e132.sss;
    m.sss_color = _e132.sss_color;
    m.optics2_ = _e132.optics2_;
    m.pal0_ = _e132.pal0_;
    m.pal1_ = _e132.pal1_;
    m.pal2_ = _e132.pal2_;
    m.pal3_ = _e132.pal3_;
    m.accent = _e132.accent;
    m.flame = _e132.flame;
    let _e175 = s0_;
    if (_e175 == 2u) {
        let _e177 = (*bot);
        let _e179 = st[_e177];
        let _e184 = m.phys[2u];
        return (select(0.4f, 1f, (_e179 == 0u)) * (1f - _e184));
    }
    let _e187 = s0_;
    if (_e187 == 1u) {
        let _e189 = (*bot);
        let _e191 = st[_e189];
        return select(0.3f, 1f, (_e191 == 0u));
    }
    let _e194 = s0_;
    if (_e194 == 0u) {
        return 0.4f;
    }
    return 0f;
}

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e83 = (*a);
    if (_e83 >= 0i) {
        let _e85 = (*a);
        let _e86 = (*b);
        let _e89 = (*b);
        local = ((_e85 + (_e86 / 2i)) / _e89);
    } else {
        let _e91 = (*a);
        let _e93 = (*b);
        let _e96 = (*b);
        local = -(((-(_e91) + (_e93 / 2i)) / _e96));
    }
    let _e99 = local;
    return _e99;
}

fn det_q_u0028_f1_u003b_f1_u003b(v_1: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e82 = (*v_1);
    let _e83 = (*scale);
    return i32(round((_e82 * _e83)));
}

fn fall_prob_u0028_i1_u003b_i1_u003b_vf2_u003b(top_1: ptr<function, i32>, bot_1: ptr<function, i32>, wind_1: ptr<function, vec2<f32>>) -> f32 {
    var s0_1: u32;
    var s1_: u32;
    var param_13: u32;
    var dt: i32;
    var param_14: f32;
    var param_15: f32;
    var db: i32;
    var param_16: f32;
    var param_17: f32;
    var p_2: f32;
    var param_18: i32;
    var param_19: i32;
    var visc_1: f32;
    var phi_722_: bool;
    var phi_767_: bool;
    var phi_784_: bool;
    var phi_846_: bool;

    let _e96 = (*top_1);
    let _e98 = mov[_e96];
    let _e99 = !(_e98);
    phi_722_ = _e99;
    if !(_e99) {
        let _e101 = (*bot_1);
        let _e103 = mov[_e101];
        phi_722_ = !(_e103);
    }
    let _e106 = phi_722_;
    if _e106 {
        return 0f;
    }
    let _e107 = (*top_1);
    let _e109 = st[_e107];
    s0_1 = _e109;
    let _e110 = (*bot_1);
    let _e112 = st[_e110];
    s1_ = _e112;
    let _e113 = s1_;
    param_13 = _e113;
    let _e114 = fluid_u0028_u1_u003b((&param_13));
    if !(_e114) {
        return 0f;
    }
    let _e116 = (*top_1);
    let _e118 = de[_e116];
    let _e119 = (*bot_1);
    let _e121 = de[_e119];
    if (_e118 <= _e121) {
        let _e123 = s0_1;
        let _e125 = s1_;
        if ((_e123 == 0u) && (_e125 == 0u)) {
            let _e129 = (*wind_1)[1u];
            let _e130 = (_e129 > 0f);
            phi_767_ = _e130;
            if _e130 {
                let _e131 = (*top_1);
                let _e134 = cs[_e131].mat;
                phi_767_ = (_e134 != 0u);
            }
            let _e137 = phi_767_;
            if _e137 {
                let _e139 = (*wind_1)[1u];
                return min(_e139, 0.6f);
            }
            let _e142 = (*wind_1)[1u];
            let _e143 = (_e142 < 0f);
            phi_784_ = _e143;
            if _e143 {
                let _e144 = (*bot_1);
                let _e147 = cs[_e144].mat;
                phi_784_ = (_e147 != 0u);
            }
            let _e150 = phi_784_;
            if _e150 {
                let _e152 = (*wind_1)[1u];
                return min(-(_e152), 0.6f);
            }
        }
        return 0f;
    }
    let _e155 = s1_;
    if (_e155 == 0u) {
        let _e157 = s0_1;
        if (_e157 != 0u) {
            return 1f;
        }
        let _e159 = (*top_1);
        let _e161 = de[_e159];
        param_14 = min(_e161, 300f);
        param_15 = 1024f;
        let _e163 = det_q_u0028_f1_u003b_f1_u003b((&param_14), (&param_15));
        dt = _e163;
        let _e164 = (*bot_1);
        let _e166 = de[_e164];
        param_16 = min(_e166, 300f);
        param_17 = 1024f;
        let _e168 = det_q_u0028_f1_u003b_f1_u003b((&param_16), (&param_17));
        db = _e168;
        let _e169 = dt;
        let _e170 = db;
        let _e173 = dt;
        param_18 = ((_e169 - _e170) * 6144i);
        param_19 = max(_e173, 1i);
        let _e175 = det_div_u0028_i1_u003b_i1_u003b((&param_18), (&param_19));
        p_2 = clamp((f32(_e175) / 4096f), 0.08f, 0.9f);
        let _e180 = (*wind_1)[1u];
        let _e181 = (_e180 < 0f);
        phi_846_ = _e181;
        if _e181 {
            let _e182 = (*bot_1);
            let _e185 = cs[_e182].mat;
            phi_846_ = (_e185 != 0u);
        }
        let _e188 = phi_846_;
        if _e188 {
            let _e189 = p_2;
            let _e191 = (*wind_1)[1u];
            p_2 = max(_e189, min(-(_e191), 0.6f));
        }
        let _e195 = p_2;
        return _e195;
    }
    let _e196 = (*bot_1);
    let _e199 = cs[_e196].mat;
    let _e204 = unnamed_1.mats[_e199].phys[1u];
    visc_1 = _e204;
    let _e205 = s0_1;
    if (_e205 == 2u) {
        let _e207 = visc_1;
        return ((0.55f * (1f - _e207)) + 0.05f);
    }
    let _e211 = s0_1;
    if (_e211 == 1u) {
        let _e213 = visc_1;
        return ((0.35f * (1f - _e213)) + 0.05f);
    }
    return 0f;
}

fn lerp256_u0028_i1_u003b_i1_u003b_i1_u003b(a_1: ptr<function, i32>, b_1: ptr<function, i32>, f: ptr<function, i32>) -> i32 {
    var param_20: i32;
    var param_21: i32;

    let _e85 = (*a_1);
    let _e86 = (*f);
    let _e89 = (*b_1);
    let _e90 = (*f);
    param_20 = ((_e85 * (256i - _e86)) + (_e89 * _e90));
    param_21 = 256i;
    let _e93 = det_div_u0028_i1_u003b_i1_u003b((&param_20), (&param_21));
    return _e93;
}

fn fluid_at_u0028_vi2_u003b(q: ptr<function, vec2<i32>>) -> vec2<i32> {
    var fs: vec2<i32>;

    let _e83 = pc.i0_;
    fs = (_e83.xy / vec2(4i));
    let _e87 = (*q);
    let _e88 = fs;
    (*q) = clamp(_e87, vec2<i32>(0i, 0i), (_e88 - vec2(1i)));
    let _e93 = (*q)[1u];
    let _e95 = fs[0u];
    let _e98 = (*q)[0u];
    let _e102 = unnamed.fluid_state[((_e93 * _e95) + _e98)];
    return _e102.xy;
}

fn det_floor_div_u0028_i1_u003b_i1_u003b(a_2: ptr<function, i32>, b_2: ptr<function, i32>) -> i32 {
    var local_1: i32;

    let _e83 = (*a_2);
    if (_e83 >= 0i) {
        let _e85 = (*a_2);
        let _e86 = (*b_2);
        local_1 = (_e85 / _e86);
    } else {
        let _e88 = (*a_2);
        let _e90 = (*b_2);
        let _e93 = (*b_2);
        local_1 = -((((-(_e88) + _e90) - 1i) / _e93));
    }
    let _e96 = local_1;
    return _e96;
}

fn wind_at_u0028_vi2_u003b(origin: ptr<function, vec2<i32>>) -> vec2<f32> {
    var src: vec2<i32>;
    var base: vec2<i32>;
    var param_22: i32;
    var param_23: i32;
    var param_24: i32;
    var param_25: i32;
    var f_1: vec2<i32>;
    var a_3: vec2<i32>;
    var param_26: vec2<i32>;
    var b_3: vec2<i32>;
    var param_27: vec2<i32>;
    var c_2: vec2<i32>;
    var param_28: vec2<i32>;
    var d: vec2<i32>;
    var param_29: vec2<i32>;
    var tx: i32;
    var param_30: i32;
    var param_31: i32;
    var param_32: i32;
    var ty: i32;
    var param_33: i32;
    var param_34: i32;
    var param_35: i32;
    var bx: i32;
    var param_36: i32;
    var param_37: i32;
    var param_38: i32;
    var by: i32;
    var param_39: i32;
    var param_40: i32;
    var param_41: i32;
    var v_2: vec2<i32>;
    var param_42: i32;
    var param_43: i32;
    var param_44: i32;
    var param_45: i32;
    var param_46: i32;
    var param_47: i32;
    var k: i32;
    var param_48: f32;
    var param_49: f32;
    var param_50: i32;
    var param_51: i32;
    var param_52: i32;
    var param_53: i32;

    let _e126 = (*origin);
    src = (((_e126 + vec2(1i)) * vec2(64i)) - vec2(128i));
    let _e134 = src[0u];
    param_22 = _e134;
    param_23 = 256i;
    let _e135 = det_floor_div_u0028_i1_u003b_i1_u003b((&param_22), (&param_23));
    let _e137 = src[1u];
    param_24 = _e137;
    param_25 = 256i;
    let _e138 = det_floor_div_u0028_i1_u003b_i1_u003b((&param_24), (&param_25));
    base = vec2<i32>(_e135, _e138);
    let _e140 = src;
    let _e141 = base;
    f_1 = (_e140 - (_e141 * vec2(256i)));
    let _e145 = base;
    param_26 = _e145;
    let _e146 = fluid_at_u0028_vi2_u003b((&param_26));
    a_3 = _e146;
    let _e147 = base;
    param_27 = (_e147 + vec2<i32>(1i, 0i));
    let _e149 = fluid_at_u0028_vi2_u003b((&param_27));
    b_3 = _e149;
    let _e150 = base;
    param_28 = (_e150 + vec2<i32>(0i, 1i));
    let _e152 = fluid_at_u0028_vi2_u003b((&param_28));
    c_2 = _e152;
    let _e153 = base;
    param_29 = (_e153 + vec2<i32>(1i, 1i));
    let _e155 = fluid_at_u0028_vi2_u003b((&param_29));
    d = _e155;
    let _e157 = a_3[0u];
    param_30 = _e157;
    let _e159 = b_3[0u];
    param_31 = _e159;
    let _e161 = f_1[0u];
    param_32 = _e161;
    let _e162 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_30), (&param_31), (&param_32));
    tx = _e162;
    let _e164 = a_3[1u];
    param_33 = _e164;
    let _e166 = b_3[1u];
    param_34 = _e166;
    let _e168 = f_1[0u];
    param_35 = _e168;
    let _e169 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_33), (&param_34), (&param_35));
    ty = _e169;
    let _e171 = c_2[0u];
    param_36 = _e171;
    let _e173 = d[0u];
    param_37 = _e173;
    let _e175 = f_1[0u];
    param_38 = _e175;
    let _e176 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_36), (&param_37), (&param_38));
    bx = _e176;
    let _e178 = c_2[1u];
    param_39 = _e178;
    let _e180 = d[1u];
    param_40 = _e180;
    let _e182 = f_1[0u];
    param_41 = _e182;
    let _e183 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_39), (&param_40), (&param_41));
    by = _e183;
    let _e184 = tx;
    param_42 = _e184;
    let _e185 = bx;
    param_43 = _e185;
    let _e187 = f_1[1u];
    param_44 = _e187;
    let _e188 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_42), (&param_43), (&param_44));
    let _e189 = ty;
    param_45 = _e189;
    let _e190 = by;
    param_46 = _e190;
    let _e192 = f_1[1u];
    param_47 = _e192;
    let _e193 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_45), (&param_46), (&param_47));
    v_2 = vec2<i32>(_e188, _e193);
    let _e197 = pc.f0_[0u];
    param_48 = _e197;
    param_49 = 4096f;
    let _e198 = det_q_u0028_f1_u003b_f1_u003b((&param_48), (&param_49));
    k = _e198;
    let _e200 = v_2[0u];
    let _e202 = k;
    param_50 = ((_e200 / 16i) * _e202);
    param_51 = 256i;
    let _e204 = det_div_u0028_i1_u003b_i1_u003b((&param_50), (&param_51));
    let _e207 = v_2[1u];
    let _e209 = k;
    param_52 = ((_e207 / 16i) * _e209);
    param_53 = 256i;
    let _e211 = det_div_u0028_i1_u003b_i1_u003b((&param_52), (&param_53));
    return (vec2<f32>(f32(_e204), f32(_e211)) / vec2(65536f));
}

fn pcg3d_u0028_vu3_u003b(v_3: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e81 = (*v_3);
    (*v_3) = ((_e81 * vec3(1664525u)) + vec3(1013904223u));
    let _e87 = (*v_3)[1u];
    let _e89 = (*v_3)[2u];
    let _e92 = (*v_3)[0u];
    (*v_3)[0u] = (_e92 + (_e87 * _e89));
    let _e96 = (*v_3)[2u];
    let _e98 = (*v_3)[0u];
    let _e101 = (*v_3)[1u];
    (*v_3)[1u] = (_e101 + (_e96 * _e98));
    let _e105 = (*v_3)[0u];
    let _e107 = (*v_3)[1u];
    let _e110 = (*v_3)[2u];
    (*v_3)[2u] = (_e110 + (_e105 * _e107));
    let _e113 = (*v_3);
    let _e117 = (*v_3);
    (*v_3) = (_e117 ^ (_e113 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e120 = (*v_3)[1u];
    let _e122 = (*v_3)[2u];
    let _e125 = (*v_3)[0u];
    (*v_3)[0u] = (_e125 + (_e120 * _e122));
    let _e129 = (*v_3)[2u];
    let _e131 = (*v_3)[0u];
    let _e134 = (*v_3)[1u];
    (*v_3)[1u] = (_e134 + (_e129 * _e131));
    let _e138 = (*v_3)[0u];
    let _e140 = (*v_3)[1u];
    let _e143 = (*v_3)[2u];
    (*v_3)[2u] = (_e143 + (_e138 * _e140));
    let _e146 = (*v_3);
    return _e146;
}

fn rng_init_u0028_vu3_u003b(seed: ptr<function, vec3<u32>>) -> Rng {
    var r_3: Rng;
    var param_54: vec3<u32>;

    let _e83 = (*seed);
    param_54 = _e83;
    let _e84 = pcg3d_u0028_vu3_u003b((&param_54));
    r_3.s = (_e84.x | 1u);
    let _e88 = r_3;
    return _e88;
}

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c_3: ptr<function, Cell>) -> vec4<u32> {
    let _e82 = (*c_3).mat;
    let _e85 = (*c_3).variant;
    let _e91 = (*c_3).flags;
    let _e97 = (*c_3).temp;
    let _e100 = (*c_3).life;
    let _e103 = (*c_3).aux;
    let _e109 = (*c_3).extra;
    return vec4<u32>((((_e82 & 255u) | ((_e85 & 255u) << bitcast<u32>(8u))) | ((_e91 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e97), ((_e100 & 65535u) | ((_e103 & 65535u) << bitcast<u32>(16u))), _e109);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p_3: ptr<function, vec2<i32>>, c_4: ptr<function, Cell>) {
    var param_55: Cell;

    let _e83 = (*p_3);
    let _e84 = (*c_4);
    param_55 = _e84;
    let _e85 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_55));
    textureStore(cells_out, _e83, _e85);
    return;
}

fn unpack_cell_u0028_vu4_u003b(v_4: ptr<function, vec4<u32>>) -> Cell {
    var c_5: Cell;

    let _e83 = (*v_4)[0u];
    c_5.mat = (_e83 & 255u);
    let _e87 = (*v_4)[0u];
    c_5.variant = ((_e87 >> bitcast<u32>(8u)) & 255u);
    let _e93 = (*v_4)[0u];
    c_5.flags = (_e93 >> bitcast<u32>(16u));
    let _e98 = (*v_4)[1u];
    c_5.temp = bitcast<f32>(_e98);
    let _e102 = (*v_4)[2u];
    c_5.life = (_e102 & 65535u);
    let _e106 = (*v_4)[2u];
    c_5.aux = (_e106 >> bitcast<u32>(16u));
    let _e111 = (*v_4)[3u];
    c_5.extra = _e111;
    let _e113 = c_5;
    return _e113;
}

fn load_cell_u0028_vi2_u003b(p_4: ptr<function, vec2<i32>>) -> Cell {
    var param_56: vec4<u32>;

    let _e82 = (*p_4);
    let _e83 = textureLoad(cells_in, _e82, 0i);
    param_56 = _e83;
    let _e84 = unpack_cell_u0028_vu4_u003b((&param_56));
    return _e84;
}

fn in_world_u0028_vi2_u003b(p_5: ptr<function, vec2<i32>>) -> bool {
    var phi_266_: bool;
    var phi_280_: bool;
    var phi_288_: bool;

    let _e82 = (*p_5)[0u];
    let _e83 = (_e82 >= 0i);
    phi_266_ = _e83;
    if _e83 {
        let _e85 = (*p_5)[1u];
        phi_266_ = (_e85 >= 0i);
    }
    let _e88 = phi_266_;
    phi_280_ = _e88;
    if _e88 {
        let _e90 = (*p_5)[0u];
        let _e93 = pc.i0_[0u];
        phi_280_ = (_e90 < _e93);
    }
    let _e96 = phi_280_;
    phi_288_ = _e96;
    if _e96 {
        let _e98 = (*p_5)[1u];
        let _e101 = pc.i0_[1u];
        phi_288_ = (_e98 < _e101);
    }
    let _e104 = phi_288_;
    return _e104;
}

fn main_1() {
    var b_4: vec2<i32>;
    var origin_1: vec2<i32>;
    var ps: array<vec2<i32>, 4>;
    var i_1: i32;
    var valid: array<bool, 4>;
    var param_57: vec2<i32>;
    var param_58: vec2<i32>;
    var m_1: Material;
    var still: bool;
    var i_2: i32;
    var i_3: i32;
    var param_59: vec2<i32>;
    var param_60: Cell;
    var rng_1: Rng;
    var param_61: vec3<u32>;
    var wind_2: vec2<f32>;
    var param_62: vec2<i32>;
    var col: i32;
    var p_6: f32;
    var param_63: i32;
    var param_64: i32;
    var param_65: vec2<f32>;
    var param_66: Rng;
    var param_67: i32;
    var param_68: i32;
    var first: bool;
    var param_69: Rng;
    var k_1: i32;
    var top_2: i32;
    var bot_2: i32;
    var p_7: f32;
    var param_70: i32;
    var param_71: i32;
    var param_72: Rng;
    var param_73: i32;
    var param_74: i32;
    var param_75: i32;
    var param_76: i32;
    var param_77: Rng;
    var param_78: vec2<f32>;
    var param_79: i32;
    var param_80: i32;
    var param_81: Rng;
    var param_82: vec2<f32>;
    var i_4: i32;
    var param_83: Cell;
    var param_84: u32;
    var param_85: vec2<i32>;
    var param_86: Cell;
    var phi_1380_: bool;
    var phi_1522_: bool;
    var phi_1523_: bool;
    var phi_1603_: bool;
    var phi_1654_: bool;
    var phi_1702_: bool;

    let _e129 = gl_GlobalInvocationID_1;
    b_4 = bitcast<vec2<i32>>(_e129.xy);
    let _e132 = b_4;
    let _e136 = pc.i1_;
    origin_1 = ((_e132 * vec2(2i)) - _e136.xy);
    let _e140 = origin_1[0u];
    let _e143 = pc.i0_[0u];
    let _e144 = (_e140 >= _e143);
    phi_1380_ = _e144;
    if !(_e144) {
        let _e147 = origin_1[1u];
        let _e150 = pc.i0_[1u];
        phi_1380_ = (_e147 >= _e150);
    }
    let _e153 = phi_1380_;
    if _e153 {
        return;
    }
    let _e154 = origin_1;
    let _e155 = origin_1;
    let _e157 = origin_1;
    let _e159 = origin_1;
    ps = array<vec2<i32>, 4>(_e154, (_e155 + vec2<i32>(1i, 0i)), (_e157 + vec2<i32>(0i, 1i)), (_e159 + vec2<i32>(1i, 1i)));
    i_1 = 0i;
    loop {
        let _e162 = i_1;
        if (_e162 < 4i) {
            let _e164 = i_1;
            let _e165 = i_1;
            let _e167 = ps[_e165];
            param_57 = _e167;
            let _e168 = in_world_u0028_vi2_u003b((&param_57));
            valid[_e164] = _e168;
            let _e170 = i_1;
            moved[_e170] = false;
            let _e172 = i_1;
            let _e174 = valid[_e172];
            if _e174 {
                let _e175 = i_1;
                let _e176 = i_1;
                let _e178 = ps[_e176];
                param_58 = _e178;
                let _e179 = load_cell_u0028_vi2_u003b((&param_58));
                cs[_e175] = _e179;
                let _e181 = i_1;
                let _e184 = cs[_e181].mat;
                let _e187 = unnamed_1.mats[_e184];
                m_1.color_a = _e187.color_a;
                m_1.color_b = _e187.color_b;
                m_1.emission = _e187.emission;
                m_1.phys = _e187.phys;
                m_1.thermo = _e187.thermo;
                m_1.burn = _e187.burn;
                m_1.optics = _e187.optics;
                m_1.scatter = _e187.scatter;
                m_1.ids = _e187.ids;
                m_1.ids2_ = _e187.ids2_;
                m_1.misc = _e187.misc;
                m_1.surface = _e187.surface;
                m_1.sss = _e187.sss;
                m_1.sss_color = _e187.sss_color;
                m_1.optics2_ = _e187.optics2_;
                m_1.pal0_ = _e187.pal0_;
                m_1.pal1_ = _e187.pal1_;
                m_1.pal2_ = _e187.pal2_;
                m_1.pal3_ = _e187.pal3_;
                m_1.accent = _e187.accent;
                m_1.flame = _e187.flame;
                let _e230 = i_1;
                let _e233 = m_1.ids[0u];
                st[_e230] = _e233;
                let _e235 = i_1;
                let _e238 = m_1.phys[0u];
                de[_e235] = _e238;
                let _e240 = i_1;
                let _e241 = i_1;
                let _e243 = st[_e241];
                mov[_e240] = (_e243 != 3u);
            } else {
                let _e246 = i_1;
                st[_e246] = 3u;
                let _e248 = i_1;
                de[_e248] = 1000000000f;
                let _e250 = i_1;
                mov[_e250] = false;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e252 = i_1;
            i_1 = (_e252 + 1i);
        }
    }
    still = true;
    i_2 = 0i;
    loop {
        let _e254 = i_2;
        if (_e254 < 4i) {
            let _e256 = still;
            phi_1523_ = _e256;
            if _e256 {
                let _e257 = i_2;
                let _e259 = mov[_e257];
                let _e260 = !(_e259);
                phi_1522_ = _e260;
                if !(_e260) {
                    let _e262 = i_2;
                    let _e265 = cs[_e262].mat;
                    phi_1522_ = (_e265 == 0u);
                }
                let _e268 = phi_1522_;
                phi_1523_ = _e268;
            }
            let _e270 = phi_1523_;
            still = _e270;
            continue;
        } else {
            break;
        }
        continuing {
            let _e271 = i_2;
            i_2 = (_e271 + 1i);
        }
    }
    let _e273 = still;
    if _e273 {
        i_3 = 0i;
        loop {
            let _e274 = i_3;
            if (_e274 < 4i) {
                let _e276 = i_3;
                let _e278 = valid[_e276];
                if _e278 {
                    let _e279 = i_3;
                    let _e280 = i_3;
                    let _e282 = ps[_e279];
                    param_59 = _e282;
                    let _e284 = cs[_e280];
                    param_60 = _e284;
                    store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_59), (&param_60));
                }
                continue;
            } else {
                break;
            }
            continuing {
                let _e285 = i_3;
                i_3 = (_e285 + 1i);
            }
        }
        return;
    }
    let _e287 = origin_1;
    let _e290 = bitcast<vec2<u32>>((_e287 + vec2(2i)));
    let _e293 = pc.i0_[2u];
    let _e298 = pc.i0_[3u];
    param_61 = vec3<u32>(_e290.x, _e290.y, ((bitcast<u32>(_e293) * 8u) + bitcast<u32>(_e298)));
    let _e304 = rng_init_u0028_vu3_u003b((&param_61));
    rng_1 = _e304;
    let _e305 = origin_1;
    param_62 = _e305;
    let _e306 = wind_at_u0028_vi2_u003b((&param_62));
    wind_2 = _e306;
    col = 0i;
    loop {
        let _e307 = col;
        if (_e307 < 2i) {
            let _e309 = col;
            let _e311 = col;
            param_63 = _e311;
            param_64 = (_e309 + 2i);
            let _e312 = wind_2;
            param_65 = _e312;
            let _e313 = fall_prob_u0028_i1_u003b_i1_u003b_vf2_u003b((&param_63), (&param_64), (&param_65));
            p_6 = _e313;
            let _e314 = p_6;
            let _e315 = (_e314 > 0f);
            phi_1603_ = _e315;
            if _e315 {
                let _e316 = rng_1;
                param_66 = _e316;
                let _e317 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_66));
                let _e318 = param_66;
                rng_1 = _e318;
                let _e319 = p_6;
                phi_1603_ = (_e317 < _e319);
            }
            let _e322 = phi_1603_;
            if _e322 {
                let _e323 = col;
                let _e325 = col;
                param_67 = _e325;
                param_68 = (_e323 + 2i);
                swap_slots_u0028_i1_u003b_i1_u003b((&param_67), (&param_68));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e326 = col;
            col = (_e326 + 1i);
        }
    }
    let _e328 = rng_1;
    param_69 = _e328;
    let _e329 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_69));
    let _e330 = param_69;
    rng_1 = _e330;
    first = (_e329 < 0.5f);
    k_1 = 0i;
    loop {
        let _e332 = k_1;
        if (_e332 < 2i) {
            let _e334 = k_1;
            let _e336 = first;
            top_2 = select(1i, 0i, ((_e334 == 0i) == _e336));
            let _e339 = top_2;
            bot_2 = (3i - _e339);
            let _e341 = top_2;
            param_70 = _e341;
            let _e342 = bot_2;
            param_71 = _e342;
            let _e343 = diag_prob_u0028_i1_u003b_i1_u003b((&param_70), (&param_71));
            p_7 = _e343;
            let _e344 = p_7;
            let _e345 = (_e344 > 0f);
            phi_1654_ = _e345;
            if _e345 {
                let _e346 = rng_1;
                param_72 = _e346;
                let _e347 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_72));
                let _e348 = param_72;
                rng_1 = _e348;
                let _e349 = p_7;
                phi_1654_ = (_e347 < _e349);
            }
            let _e352 = phi_1654_;
            if _e352 {
                let _e353 = top_2;
                param_73 = _e353;
                let _e354 = bot_2;
                param_74 = _e354;
                swap_slots_u0028_i1_u003b_i1_u003b((&param_73), (&param_74));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e355 = k_1;
            k_1 = (_e355 + 1i);
        }
    }
    param_75 = 2i;
    param_76 = 3i;
    let _e357 = rng_1;
    param_77 = _e357;
    let _e358 = wind_2;
    param_78 = _e358;
    lateral_u0028_i1_u003b_i1_u003b_struct_u002d_Rng_u002d_u11_u003b_vf2_u003b((&param_75), (&param_76), (&param_77), (&param_78));
    let _e359 = param_77;
    rng_1 = _e359;
    param_79 = 0i;
    param_80 = 1i;
    let _e360 = rng_1;
    param_81 = _e360;
    let _e361 = wind_2;
    param_82 = _e361;
    lateral_u0028_i1_u003b_i1_u003b_struct_u002d_Rng_u002d_u11_u003b_vf2_u003b((&param_79), (&param_80), (&param_81), (&param_82));
    let _e362 = param_81;
    rng_1 = _e362;
    i_4 = 0i;
    loop {
        let _e363 = i_4;
        if (_e363 < 4i) {
            let _e365 = i_4;
            let _e367 = valid[_e365];
            if _e367 {
                let _e368 = i_4;
                let _e370 = moved[_e368];
                phi_1702_ = _e370;
                if _e370 {
                    let _e371 = i_4;
                    let _e373 = st[_e371];
                    phi_1702_ = (_e373 == 1u);
                }
                let _e376 = phi_1702_;
                if _e376 {
                    let _e377 = i_4;
                    let _e379 = cs[_e377];
                    param_83 = _e379;
                    param_84 = 255u;
                    set_agitation_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b((&param_83), (&param_84));
                    let _e380 = param_83;
                    cs[_e377] = _e380;
                }
                let _e382 = i_4;
                let _e383 = i_4;
                let _e385 = ps[_e382];
                param_85 = _e385;
                let _e387 = cs[_e383];
                param_86 = _e387;
                store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_85), (&param_86));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e388 = i_4;
            i_4 = (_e388 + 1i);
        }
    }
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
