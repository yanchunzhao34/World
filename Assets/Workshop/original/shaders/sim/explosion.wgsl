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

struct MediumSrc {
    msrc: array<u32>,
}

struct Pending {
    pend_header: vec4<u32>,
    pend: array<vec4<f32>>,
}

struct MediumSrc_1 {
    msrc: array<atomic<u32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;
@group(0) @binding(2) 
var<storage> unnamed: Materials;
@group(0) @binding(4) 
var<storage, read_write> unnamed_1: MediumSrc_1;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
@group(0) @binding(3) 
var<storage> unnamed_2: Pending;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e75 = (*c).mat;
    let _e78 = (*c).variant;
    let _e84 = (*c).flags;
    let _e90 = (*c).temp;
    let _e93 = (*c).life;
    let _e96 = (*c).aux;
    let _e102 = (*c).extra;
    return vec4<u32>((((_e75 & 255u) | ((_e78 & 255u) << bitcast<u32>(8u))) | ((_e84 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e90), ((_e93 & 65535u) | ((_e96 & 65535u) << bitcast<u32>(16u))), _e102);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p: ptr<function, vec2<i32>>, c_1: ptr<function, Cell>) {
    var param: Cell;

    let _e76 = (*p);
    let _e77 = (*c_1);
    param = _e77;
    let _e78 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param));
    textureStore(cells_out, _e76, _e78);
    return;
}

fn emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b(cell: ptr<function, vec2<i32>>, channel: ptr<function, u32>, amount: ptr<function, f32>) {
    var mp: vec2<i32>;
    var mw: i32;
    var idx: u32;

    let _e79 = (*amount);
    if (_e79 <= 0f) {
        return;
    }
    let _e81 = (*cell);
    mp = (_e81 >> bitcast<vec2<u32>>(vec2(1i)));
    let _e87 = pc.i0_[0u];
    mw = (_e87 >> bitcast<u32>(1i));
    let _e91 = mp[1u];
    let _e92 = mw;
    let _e95 = mp[0u];
    let _e99 = (*channel);
    idx = ((bitcast<u32>(((_e91 * _e92) + _e95)) * 4u) + _e99);
    let _e101 = idx;
    let _e104 = (*amount);
    let _e107 = atomicAdd((&unnamed_1.msrc[_e101]), u32((_e104 * 1024f)));
    return;
}

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e74 = (*x);
    return (f32((_e74 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b(r: ptr<function, Rng>) -> u32 {
    let _e75 = (*r).s;
    let _e79 = (*r).s;
    (*r).s = (_e79 ^ (_e75 << bitcast<u32>(13u)));
    let _e83 = (*r).s;
    let _e87 = (*r).s;
    (*r).s = (_e87 ^ (_e83 >> bitcast<u32>(17u)));
    let _e91 = (*r).s;
    let _e95 = (*r).s;
    (*r).s = (_e95 ^ (_e91 << bitcast<u32>(5u)));
    let _e99 = (*r).s;
    return _e99;
}

fn rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b(r_1: ptr<function, Rng>) -> f32 {
    var param_1: Rng;
    var param_2: u32;

    let _e76 = (*r_1);
    param_1 = _e76;
    let _e77 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_1));
    let _e78 = param_1;
    (*r_1) = _e78;
    param_2 = _e77;
    let _e79 = u01_u0028_u1_u003b((&param_2));
    return _e79;
}

fn set_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b(c_2: ptr<function, Cell>, v: ptr<function, u32>) {
    let _e76 = (*c_2).flags;
    let _e78 = (*v);
    (*c_2).flags = ((_e76 & 4294967267u) | (min(_e78, 7u) << bitcast<u32>(2u)));
    return;
}

fn make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b(mat: ptr<function, u32>, r_2: ptr<function, Rng>) -> Cell {
    var m: Material;
    var c_3: Cell;
    var param_3: Rng;
    var local: f32;
    var li: f32;
    var local_1: u32;
    var param_4: Rng;

    let _e82 = (*mat);
    let _e85 = unnamed.mats[_e82];
    m.color_a = _e85.color_a;
    m.color_b = _e85.color_b;
    m.emission = _e85.emission;
    m.phys = _e85.phys;
    m.thermo = _e85.thermo;
    m.burn = _e85.burn;
    m.optics = _e85.optics;
    m.scatter = _e85.scatter;
    m.ids = _e85.ids;
    m.ids2_ = _e85.ids2_;
    m.misc = _e85.misc;
    m.surface = _e85.surface;
    m.sss = _e85.sss;
    m.sss_color = _e85.sss_color;
    m.optics2_ = _e85.optics2_;
    m.pal0_ = _e85.pal0_;
    m.pal1_ = _e85.pal1_;
    m.pal2_ = _e85.pal2_;
    m.pal3_ = _e85.pal3_;
    m.accent = _e85.accent;
    m.flame = _e85.flame;
    let _e128 = (*mat);
    c_3.mat = _e128;
    let _e130 = (*r_2);
    param_3 = _e130;
    let _e131 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_3));
    let _e132 = param_3;
    (*r_2) = _e132;
    c_3.variant = (_e131 & 255u);
    c_3.flags = 0u;
    let _e138 = m.misc[0u];
    if (_e138 > 0f) {
        let _e142 = m.misc[0u];
        local = _e142;
    } else {
        local = 293f;
    }
    let _e143 = local;
    c_3.temp = _e143;
    let _e147 = m.misc[1u];
    li = _e147;
    let _e148 = li;
    if (_e148 > 0f) {
        let _e150 = li;
        let _e151 = (*r_2);
        param_4 = _e151;
        let _e152 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_4));
        let _e153 = param_4;
        (*r_2) = _e153;
        local_1 = u32((_e150 * (0.5f + _e152)));
    } else {
        local_1 = 0u;
    }
    let _e157 = local_1;
    c_3.life = _e157;
    c_3.aux = 0u;
    c_3.extra = 0u;
    let _e161 = c_3;
    return _e161;
}

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local_2: i32;

    let _e76 = (*a);
    if (_e76 >= 0i) {
        let _e78 = (*a);
        let _e79 = (*b);
        let _e82 = (*b);
        local_2 = ((_e78 + (_e79 / 2i)) / _e82);
    } else {
        let _e84 = (*a);
        let _e86 = (*b);
        let _e89 = (*b);
        local_2 = -(((-(_e84) + (_e86 / 2i)) / _e89));
    }
    let _e92 = local_2;
    return _e92;
}

fn det_isqrt_u0028_i1_u003b(v_1: ptr<function, i32>) -> i32 {
    var x_1: i32;

    let _e75 = (*v_1);
    if (_e75 <= 0i) {
        return 0i;
    }
    let _e77 = (*v_1);
    x_1 = i32(sqrt(f32(_e77)));
    loop {
        let _e81 = x_1;
        let _e82 = x_1;
        let _e84 = (*v_1);
        if ((_e81 * _e82) > _e84) {
            let _e86 = x_1;
            x_1 = (_e86 - 1i);
            continue;
        } else {
            break;
        }
    }
    loop {
        let _e88 = x_1;
        let _e90 = x_1;
        let _e93 = (*v_1);
        if (((_e88 + 1i) * (_e90 + 1i)) <= _e93) {
            let _e95 = x_1;
            x_1 = (_e95 + 1i);
            continue;
        } else {
            break;
        }
    }
    let _e97 = x_1;
    return _e97;
}

fn det_q_u0028_f1_u003b_f1_u003b(v_2: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e75 = (*v_2);
    let _e76 = (*scale);
    return i32(round((_e75 * _e76)));
}

fn blast_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vf4_u003b_struct_u002d_Rng_u002d_u11_u003b(c_4: ptr<function, Cell>, p_1: ptr<function, vec2<i32>>, e: ptr<function, vec4<f32>>, r_3: ptr<function, Rng>) {
    var d2_: vec2<i32>;
    var param_5: f32;
    var param_6: f32;
    var param_7: f32;
    var param_8: f32;
    var r4_: i32;
    var param_9: f32;
    var param_10: f32;
    var d4_: i32;
    var param_11: i32;
    var k4_: i32;
    var param_12: i32;
    var param_13: i32;
    var kp4_: i32;
    var param_14: f32;
    var param_15: f32;
    var param_16: i32;
    var param_17: i32;
    var k: f32;
    var power: f32;
    var m_1: Material;
    var st: u32;
    var param_18: i32;
    var param_19: i32;
    var destroy4_: i32;
    var param_20: i32;
    var param_21: i32;
    var gone: bool;
    var param_22: Rng;
    var param_23: f32;
    var param_24: f32;
    var param_25: Rng;
    var param_26: i32;
    var param_27: i32;
    var param_28: u32;
    var param_29: Rng;
    var param_30: Rng;
    var param_31: i32;
    var param_32: i32;
    var t: f32;
    var param_33: u32;
    var param_34: Rng;
    var param_35: Cell;
    var param_36: u32;
    var param_37: Rng;
    var param_38: vec2<i32>;
    var param_39: u32;
    var param_40: f32;
    var param_41: Rng;
    var param_42: vec2<i32>;
    var param_43: u32;
    var param_44: f32;
    var phi_841_: bool;
    var phi_860_: bool;

    let _e129 = (*p_1);
    let _e135 = (*e)[0u];
    param_5 = _e135;
    param_6 = 4f;
    let _e136 = det_q_u0028_f1_u003b_f1_u003b((&param_5), (&param_6));
    let _e138 = (*e)[1u];
    param_7 = _e138;
    param_8 = 4f;
    let _e139 = det_q_u0028_f1_u003b_f1_u003b((&param_7), (&param_8));
    d2_ = (((_e129 * vec2(4i)) + vec2(2i)) - vec2<i32>(_e136, _e139));
    let _e143 = (*e)[2u];
    param_9 = _e143;
    param_10 = 4f;
    let _e144 = det_q_u0028_f1_u003b_f1_u003b((&param_9), (&param_10));
    r4_ = _e144;
    let _e145 = d2_;
    let _e147 = r4_;
    if any((abs(_e145) > vec2(_e147))) {
        return;
    }
    let _e152 = d2_[0u];
    let _e154 = d2_[0u];
    let _e157 = d2_[1u];
    let _e159 = d2_[1u];
    param_11 = ((_e152 * _e154) + (_e157 * _e159));
    let _e162 = det_isqrt_u0028_i1_u003b((&param_11));
    d4_ = _e162;
    let _e163 = d4_;
    let _e164 = r4_;
    if (_e163 > _e164) {
        return;
    }
    let _e166 = d4_;
    let _e168 = r4_;
    param_12 = (_e166 * 4096i);
    param_13 = max(_e168, 4i);
    let _e170 = det_div_u0028_i1_u003b_i1_u003b((&param_12), (&param_13));
    k4_ = (4096i - _e170);
    let _e172 = k4_;
    let _e174 = (*e)[3u];
    param_14 = min(_e174, 15f);
    param_15 = 256f;
    let _e176 = det_q_u0028_f1_u003b_f1_u003b((&param_14), (&param_15));
    param_16 = (_e172 * _e176);
    param_17 = 256i;
    let _e178 = det_div_u0028_i1_u003b_i1_u003b((&param_16), (&param_17));
    kp4_ = _e178;
    let _e179 = k4_;
    k = (f32(_e179) / 4096f);
    let _e183 = (*e)[3u];
    power = _e183;
    let _e185 = (*c_4).mat;
    let _e188 = unnamed.mats[_e185];
    m_1.color_a = _e188.color_a;
    m_1.color_b = _e188.color_b;
    m_1.emission = _e188.emission;
    m_1.phys = _e188.phys;
    m_1.thermo = _e188.thermo;
    m_1.burn = _e188.burn;
    m_1.optics = _e188.optics;
    m_1.scatter = _e188.scatter;
    m_1.ids = _e188.ids;
    m_1.ids2_ = _e188.ids2_;
    m_1.misc = _e188.misc;
    m_1.surface = _e188.surface;
    m_1.sss = _e188.sss;
    m_1.sss_color = _e188.sss_color;
    m_1.optics2_ = _e188.optics2_;
    m_1.pal0_ = _e188.pal0_;
    m_1.pal1_ = _e188.pal1_;
    m_1.pal2_ = _e188.pal2_;
    m_1.pal3_ = _e188.pal3_;
    m_1.accent = _e188.accent;
    m_1.flame = _e188.flame;
    let _e233 = m_1.ids[0u];
    st = _e233;
    let _e235 = (*c_4).temp;
    let _e236 = kp4_;
    param_18 = (_e236 * 700i);
    param_19 = 64i;
    let _e238 = det_div_u0028_i1_u003b_i1_u003b((&param_18), (&param_19));
    (*c_4).temp = min((_e235 + (f32(_e238) / 64f)), 4000f);
    let _e244 = kp4_;
    param_20 = (_e244 * 14i);
    param_21 = 10i;
    let _e246 = det_div_u0028_i1_u003b_i1_u003b((&param_20), (&param_21));
    destroy4_ = _e246;
    gone = false;
    let _e247 = st;
    if (_e247 == 3u) {
        let _e249 = (*r_3);
        param_22 = _e249;
        let _e250 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_22));
        let _e251 = param_22;
        (*r_3) = _e251;
        let _e255 = destroy4_;
        let _e258 = m_1.phys[3u];
        param_23 = _e258;
        param_24 = 4096f;
        let _e259 = det_q_u0028_f1_u003b_f1_u003b((&param_23), (&param_24));
        gone = (bitcast<i32>((_e250 >> bitcast<u32>(20u))) < (_e255 - _e259));
    } else {
        let _e262 = st;
        let _e264 = st;
        if ((_e262 == 2u) || (_e264 == 1u)) {
            let _e267 = (*r_3);
            param_25 = _e267;
            let _e268 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_25));
            let _e269 = param_25;
            (*r_3) = _e269;
            let _e273 = destroy4_;
            param_26 = (_e273 * 55i);
            param_27 = 100i;
            let _e275 = det_div_u0028_i1_u003b_i1_u003b((&param_26), (&param_27));
            gone = (bitcast<i32>((_e268 >> bitcast<u32>(20u))) < _e275);
        }
    }
    let _e277 = gone;
    if _e277 {
        param_28 = 0u;
        let _e278 = (*r_3);
        param_29 = _e278;
        let _e279 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_28), (&param_29));
        let _e280 = param_29;
        (*r_3) = _e280;
        (*c_4) = _e279;
        (*c_4).temp = 900f;
    }
    let _e283 = (*c_4).mat;
    let _e286 = unnamed.mats[_e283];
    m_1.color_a = _e286.color_a;
    m_1.color_b = _e286.color_b;
    m_1.emission = _e286.emission;
    m_1.phys = _e286.phys;
    m_1.thermo = _e286.thermo;
    m_1.burn = _e286.burn;
    m_1.optics = _e286.optics;
    m_1.scatter = _e286.scatter;
    m_1.ids = _e286.ids;
    m_1.ids2_ = _e286.ids2_;
    m_1.misc = _e286.misc;
    m_1.surface = _e286.surface;
    m_1.sss = _e286.sss;
    m_1.sss_color = _e286.sss_color;
    m_1.optics2_ = _e286.optics2_;
    m_1.pal0_ = _e286.pal0_;
    m_1.pal1_ = _e286.pal1_;
    m_1.pal2_ = _e286.pal2_;
    m_1.pal3_ = _e286.pal3_;
    m_1.accent = _e286.accent;
    m_1.flame = _e286.flame;
    let _e331 = m_1.ids[0u];
    let _e332 = (_e331 == 0u);
    phi_841_ = _e332;
    if _e332 {
        let _e334 = (*c_4).mat;
        let _e337 = pc.i1_[1u];
        phi_841_ = (_e334 != bitcast<u32>(_e337));
    }
    let _e341 = phi_841_;
    let _e342 = k4_;
    let _e344 = (_e341 && (_e342 > 1024i));
    phi_860_ = _e344;
    if _e344 {
        let _e345 = (*r_3);
        param_30 = _e345;
        let _e346 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_30));
        let _e347 = param_30;
        (*r_3) = _e347;
        let _e351 = k4_;
        param_31 = (_e351 * 12i);
        param_32 = 10i;
        let _e353 = det_div_u0028_i1_u003b_i1_u003b((&param_31), (&param_32));
        phi_860_ = (bitcast<i32>((_e346 >> bitcast<u32>(20u))) < _e353);
    }
    let _e356 = phi_860_;
    if _e356 {
        let _e358 = (*c_4).temp;
        t = _e358;
        let _e361 = pc.i1_[1u];
        param_33 = bitcast<u32>(_e361);
        let _e363 = (*r_3);
        param_34 = _e363;
        let _e364 = make_cell_u0028_u1_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_33), (&param_34));
        let _e365 = param_34;
        (*r_3) = _e365;
        (*c_4) = _e364;
        let _e366 = t;
        let _e368 = (*c_4).temp;
        (*c_4).temp = max(_e366, _e368);
    }
    let _e373 = m_1.ids[1u];
    if ((_e373 & 1u) != 0u) {
        let _e377 = (*c_4).temp;
        let _e380 = m_1.burn[0u];
        (*c_4).temp = max(_e377, (_e380 + 20f));
    }
    let _e384 = k4_;
    if ((_e384 * 20i) > 12288i) {
        let _e387 = k4_;
        let _e392 = (*c_4);
        param_35 = _e392;
        param_36 = bitcast<u32>((3i + (_e387 >> bitcast<u32>(10i))));
        set_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_u1_u003b((&param_35), (&param_36));
        let _e393 = param_35;
        (*c_4) = _e393;
    }
    let _e394 = (*r_3);
    param_37 = _e394;
    let _e395 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_37));
    let _e396 = param_37;
    (*r_3) = _e396;
    if (_e395 < 0.35f) {
        let _e398 = k;
        let _e400 = power;
        let _e402 = (*p_1);
        param_38 = _e402;
        param_39 = 0u;
        param_40 = ((1.5f * _e398) * _e400);
        emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_38), (&param_39), (&param_40));
    }
    let _e403 = (*r_3);
    param_41 = _e403;
    let _e404 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_41));
    let _e405 = param_41;
    (*r_3) = _e405;
    if (_e404 < 0.5f) {
        let _e407 = k;
        let _e409 = power;
        let _e411 = (*p_1);
        param_42 = _e411;
        param_43 = 2u;
        param_44 = ((6f * _e407) * _e409);
        emit_medium_u0028_vi2_u003b_u1_u003b_f1_u003b((&param_42), (&param_43), (&param_44));
    }
    return;
}

fn pcg3d_u0028_vu3_u003b(v_3: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e74 = (*v_3);
    (*v_3) = ((_e74 * vec3(1664525u)) + vec3(1013904223u));
    let _e80 = (*v_3)[1u];
    let _e82 = (*v_3)[2u];
    let _e85 = (*v_3)[0u];
    (*v_3)[0u] = (_e85 + (_e80 * _e82));
    let _e89 = (*v_3)[2u];
    let _e91 = (*v_3)[0u];
    let _e94 = (*v_3)[1u];
    (*v_3)[1u] = (_e94 + (_e89 * _e91));
    let _e98 = (*v_3)[0u];
    let _e100 = (*v_3)[1u];
    let _e103 = (*v_3)[2u];
    (*v_3)[2u] = (_e103 + (_e98 * _e100));
    let _e106 = (*v_3);
    let _e110 = (*v_3);
    (*v_3) = (_e110 ^ (_e106 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e113 = (*v_3)[1u];
    let _e115 = (*v_3)[2u];
    let _e118 = (*v_3)[0u];
    (*v_3)[0u] = (_e118 + (_e113 * _e115));
    let _e122 = (*v_3)[2u];
    let _e124 = (*v_3)[0u];
    let _e127 = (*v_3)[1u];
    (*v_3)[1u] = (_e127 + (_e122 * _e124));
    let _e131 = (*v_3)[0u];
    let _e133 = (*v_3)[1u];
    let _e136 = (*v_3)[2u];
    (*v_3)[2u] = (_e136 + (_e131 * _e133));
    let _e139 = (*v_3);
    return _e139;
}

fn rng_init_u0028_vu3_u003b(seed: ptr<function, vec3<u32>>) -> Rng {
    var r_4: Rng;
    var param_45: vec3<u32>;

    let _e76 = (*seed);
    param_45 = _e76;
    let _e77 = pcg3d_u0028_vu3_u003b((&param_45));
    r_4.s = (_e77.x | 1u);
    let _e81 = r_4;
    return _e81;
}

fn unpack_cell_u0028_vu4_u003b(v_4: ptr<function, vec4<u32>>) -> Cell {
    var c_5: Cell;

    let _e76 = (*v_4)[0u];
    c_5.mat = (_e76 & 255u);
    let _e80 = (*v_4)[0u];
    c_5.variant = ((_e80 >> bitcast<u32>(8u)) & 255u);
    let _e86 = (*v_4)[0u];
    c_5.flags = (_e86 >> bitcast<u32>(16u));
    let _e91 = (*v_4)[1u];
    c_5.temp = bitcast<f32>(_e91);
    let _e95 = (*v_4)[2u];
    c_5.life = (_e95 & 65535u);
    let _e99 = (*v_4)[2u];
    c_5.aux = (_e99 >> bitcast<u32>(16u));
    let _e104 = (*v_4)[3u];
    c_5.extra = _e104;
    let _e106 = c_5;
    return _e106;
}

fn in_world_u0028_vi2_u003b(p_2: ptr<function, vec2<i32>>) -> bool {
    var phi_235_: bool;
    var phi_248_: bool;
    var phi_256_: bool;

    let _e75 = (*p_2)[0u];
    let _e76 = (_e75 >= 0i);
    phi_235_ = _e76;
    if _e76 {
        let _e78 = (*p_2)[1u];
        phi_235_ = (_e78 >= 0i);
    }
    let _e81 = phi_235_;
    phi_248_ = _e81;
    if _e81 {
        let _e83 = (*p_2)[0u];
        let _e86 = pc.i0_[0u];
        phi_248_ = (_e83 < _e86);
    }
    let _e89 = phi_248_;
    phi_256_ = _e89;
    if _e89 {
        let _e91 = (*p_2)[1u];
        let _e94 = pc.i0_[1u];
        phi_256_ = (_e91 < _e94);
    }
    let _e97 = phi_256_;
    return _e97;
}

fn main_1() {
    var p_3: vec2<i32>;
    var param_46: vec2<i32>;
    var raw: vec4<u32>;
    var np: i32;
    var c_6: Cell;
    var param_47: vec4<u32>;
    var r_5: Rng;
    var param_48: vec3<u32>;
    var i: i32;
    var param_49: Cell;
    var param_50: vec2<i32>;
    var param_51: vec4<f32>;
    var param_52: Rng;
    var param_53: vec2<i32>;
    var param_54: Cell;

    let _e88 = gl_GlobalInvocationID_1;
    p_3 = bitcast<vec2<i32>>(_e88.xy);
    let _e91 = p_3;
    param_46 = _e91;
    let _e92 = in_world_u0028_vi2_u003b((&param_46));
    if !(_e92) {
        return;
    }
    let _e94 = p_3;
    let _e95 = textureLoad(cells_in, _e94, 0i);
    raw = _e95;
    let _e98 = unnamed_2.pend_header[0u];
    np = min(bitcast<i32>(_e98), 64i);
    let _e101 = np;
    if (_e101 == 0i) {
        let _e103 = p_3;
        let _e104 = raw;
        textureStore(cells_out, _e103, _e104);
        return;
    }
    let _e105 = raw;
    param_47 = _e105;
    let _e106 = unpack_cell_u0028_vu4_u003b((&param_47));
    c_6 = _e106;
    let _e107 = p_3;
    let _e108 = bitcast<vec2<u32>>(_e107);
    let _e111 = pc.i0_[2u];
    param_48 = vec3<u32>(_e108.x, _e108.y, ((bitcast<u32>(_e111) * 31u) + 11u));
    let _e118 = rng_init_u0028_vu3_u003b((&param_48));
    r_5 = _e118;
    i = 0i;
    loop {
        let _e119 = i;
        let _e120 = np;
        if (_e119 < _e120) {
            let _e122 = i;
            let _e123 = c_6;
            param_49 = _e123;
            let _e124 = p_3;
            param_50 = _e124;
            let _e127 = unnamed_2.pend[_e122];
            param_51 = _e127;
            let _e128 = r_5;
            param_52 = _e128;
            blast_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_vf4_u003b_struct_u002d_Rng_u002d_u11_u003b((&param_49), (&param_50), (&param_51), (&param_52));
            let _e129 = param_49;
            c_6 = _e129;
            let _e130 = param_52;
            r_5 = _e130;
            continue;
        } else {
            break;
        }
        continuing {
            let _e131 = i;
            i = (_e131 + 1i);
        }
    }
    let _e133 = p_3;
    param_53 = _e133;
    let _e134 = c_6;
    param_54 = _e134;
    store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_53), (&param_54));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
