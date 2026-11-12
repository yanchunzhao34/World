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

struct Vel {
    vel: array<vec4<i32>>,
}

struct Pending {
    pend_header: vec4<u32>,
    pend: array<vec4<f32>>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(0) @binding(2) 
var<storage, read_write> unnamed_1: Vel;
@group(0) @binding(4) 
var<storage> unnamed_2: Pending;

fn det_isqrt_u0028_i1_u003b(v: ptr<function, i32>) -> i32 {
    var x: i32;

    let _e44 = (*v);
    if (_e44 <= 0i) {
        return 0i;
    }
    let _e46 = (*v);
    x = i32(sqrt(f32(_e46)));
    loop {
        let _e50 = x;
        let _e51 = x;
        let _e53 = (*v);
        if ((_e50 * _e51) > _e53) {
            let _e55 = x;
            x = (_e55 - 1i);
            continue;
        } else {
            break;
        }
    }
    loop {
        let _e57 = x;
        let _e59 = x;
        let _e62 = (*v);
        if (((_e57 + 1i) * (_e59 + 1i)) <= _e62) {
            let _e64 = x;
            x = (_e64 + 1i);
            continue;
        } else {
            break;
        }
    }
    let _e66 = x;
    return _e66;
}

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e45 = (*a);
    if (_e45 >= 0i) {
        let _e47 = (*a);
        let _e48 = (*b);
        let _e51 = (*b);
        local = ((_e47 + (_e48 / 2i)) / _e51);
    } else {
        let _e53 = (*a);
        let _e55 = (*b);
        let _e58 = (*b);
        local = -(((-(_e53) + (_e55 / 2i)) / _e58));
    }
    let _e61 = local;
    return _e61;
}

fn det_q_u0028_f1_u003b_f1_u003b(v_1: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e44 = (*v_1);
    let _e45 = (*scale);
    return i32(round((_e44 * _e45)));
}

fn main_1() {
    var p: vec2<i32>;
    var solid: i32;
    var gas: i32;
    var tsum: i32;
    var y: i32;
    var x_1: i32;
    var c: vec4<u32>;
    var param: f32;
    var param_1: f32;
    var amb: i32;
    var param_2: f32;
    var param_3: f32;
    var tavg: i32;
    var local_1: i32;
    var param_4: i32;
    var param_5: i32;
    var idx: i32;
    var v_2: vec2<i32>;
    var dT: i32;
    var t1_: i32;
    var param_6: f32;
    var param_7: f32;
    var param_8: i32;
    var param_9: i32;
    var param_10: i32;
    var param_11: i32;
    var wpos4_: vec2<i32>;
    var np: i32;
    var i: i32;
    var e: vec4<f32>;
    var reach4_: i32;
    var param_12: f32;
    var param_13: f32;
    var d4_: vec2<i32>;
    var param_14: f32;
    var param_15: f32;
    var param_16: f32;
    var param_17: f32;
    var len4_: i32;
    var param_18: i32;
    var power: i32;
    var param_19: f32;
    var param_20: f32;
    var param_21: i32;
    var param_22: i32;
    var param_23: i32;
    var param_24: i32;
    var keep: i32;
    var param_25: f32;
    var param_26: f32;
    var param_27: i32;
    var param_28: i32;
    var param_29: i32;
    var param_30: i32;
    var v64_: vec2<i32>;
    var s2_: i32;
    var sp: i32;
    var param_31: i32;
    var param_32: i32;
    var param_33: i32;
    var param_34: i32;
    var param_35: i32;

    let _e104 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e104.xy);
    let _e107 = p;
    let _e109 = pc.i0_;
    if any((_e107 >= _e109.xy)) {
        return;
    }
    solid = 0i;
    gas = 0i;
    tsum = 0i;
    y = 0i;
    loop {
        let _e113 = y;
        if (_e113 < 4i) {
            x_1 = 0i;
            loop {
                let _e115 = x_1;
                if (_e115 < 4i) {
                    let _e117 = p;
                    let _e120 = x_1;
                    let _e121 = y;
                    let _e124 = textureLoad(cells, ((_e117 * vec2(4i)) + vec2<i32>(_e120, _e121)), 0i);
                    c = _e124;
                    let _e126 = c[0u];
                    let _e132 = unnamed.mats[(_e126 & 255u)].ids[0u];
                    if (_e132 == 0u) {
                        let _e134 = gas;
                        gas = (_e134 + 1i);
                        let _e137 = c[1u];
                        param = clamp(bitcast<f32>(_e137), 1f, 9000f);
                        param_1 = 64f;
                        let _e140 = det_q_u0028_f1_u003b_f1_u003b((&param), (&param_1));
                        let _e141 = tsum;
                        tsum = (_e141 + _e140);
                    } else {
                        let _e143 = solid;
                        solid = (_e143 + 1i);
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e145 = x_1;
                    x_1 = (_e145 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e147 = y;
            y = (_e147 + 1i);
        }
    }
    let _e151 = pc.f0_[3u];
    param_2 = _e151;
    param_3 = 64f;
    let _e152 = det_q_u0028_f1_u003b_f1_u003b((&param_2), (&param_3));
    amb = _e152;
    let _e153 = gas;
    if (_e153 > 0i) {
        let _e155 = tsum;
        param_4 = _e155;
        let _e156 = gas;
        param_5 = _e156;
        let _e157 = det_div_u0028_i1_u003b_i1_u003b((&param_4), (&param_5));
        local_1 = _e157;
    } else {
        let _e158 = amb;
        local_1 = _e158;
    }
    let _e159 = local_1;
    tavg = _e159;
    let _e161 = p[1u];
    let _e164 = pc.i0_[0u];
    let _e167 = p[0u];
    idx = ((_e161 * _e164) + _e167);
    let _e169 = idx;
    let _e172 = unnamed_1.vel[_e169];
    v_2 = _e172.xy;
    let _e174 = tavg;
    let _e175 = amb;
    dT = clamp((_e174 - _e175), -19200i, 96000i);
    let _e178 = dT;
    let _e181 = pc.f0_[0u];
    param_6 = _e181;
    param_7 = 1073741800f;
    let _e182 = det_q_u0028_f1_u003b_f1_u003b((&param_6), (&param_7));
    param_8 = (_e178 * _e182);
    param_9 = 1024i;
    let _e184 = det_div_u0028_i1_u003b_i1_u003b((&param_8), (&param_9));
    t1_ = _e184;
    let _e185 = t1_;
    let _e186 = solid;
    param_10 = (_e185 * (16i - _e186));
    param_11 = 16384i;
    let _e189 = det_div_u0028_i1_u003b_i1_u003b((&param_10), (&param_11));
    let _e191 = v_2[1u];
    v_2[1u] = (_e191 - _e189);
    let _e194 = p;
    wpos4_ = ((_e194 * vec2(16i)) + vec2(8i));
    let _e201 = unnamed_2.pend_header[0u];
    np = min(bitcast<i32>(_e201), 64i);
    i = 0i;
    loop {
        let _e204 = i;
        let _e205 = np;
        if (_e204 < _e205) {
            let _e207 = i;
            let _e210 = unnamed_2.pend[_e207];
            e = _e210;
            let _e212 = e[2u];
            param_12 = (_e212 * 3.5f);
            param_13 = 4f;
            let _e214 = det_q_u0028_f1_u003b_f1_u003b((&param_12), (&param_13));
            reach4_ = _e214;
            let _e215 = wpos4_;
            let _e217 = e[0u];
            param_14 = _e217;
            param_15 = 4f;
            let _e218 = det_q_u0028_f1_u003b_f1_u003b((&param_14), (&param_15));
            let _e220 = e[1u];
            param_16 = _e220;
            param_17 = 4f;
            let _e221 = det_q_u0028_f1_u003b_f1_u003b((&param_16), (&param_17));
            d4_ = (_e215 - vec2<i32>(_e218, _e221));
            let _e224 = d4_;
            let _e226 = reach4_;
            if any((abs(_e224) > vec2(_e226))) {
                continue;
            }
            let _e231 = d4_[0u];
            let _e233 = d4_[0u];
            let _e236 = d4_[1u];
            let _e238 = d4_[1u];
            param_18 = ((_e231 * _e233) + (_e236 * _e238));
            let _e241 = det_isqrt_u0028_i1_u003b((&param_18));
            len4_ = _e241;
            let _e242 = len4_;
            let _e243 = reach4_;
            let _e245 = len4_;
            if ((_e242 >= _e243) || (_e245 == 0i)) {
                continue;
            }
            let _e249 = e[3u];
            let _e252 = pc.f0_[1u];
            param_19 = (_e249 * _e252);
            param_20 = 256f;
            let _e254 = det_q_u0028_f1_u003b_f1_u003b((&param_19), (&param_20));
            power = _e254;
            let _e256 = d4_[0u];
            let _e257 = reach4_;
            let _e258 = len4_;
            let _e262 = len4_;
            let _e263 = reach4_;
            param_21 = ((_e256 * (_e257 - _e258)) * 256i);
            param_22 = (_e262 * _e263);
            let _e265 = det_div_u0028_i1_u003b_i1_u003b((&param_21), (&param_22));
            let _e266 = power;
            let _e269 = v_2[0u];
            v_2[0u] = (_e269 + (_e265 * _e266));
            let _e273 = d4_[1u];
            let _e274 = reach4_;
            let _e275 = len4_;
            let _e279 = len4_;
            let _e280 = reach4_;
            param_23 = ((_e273 * (_e274 - _e275)) * 256i);
            param_24 = (_e279 * _e280);
            let _e282 = det_div_u0028_i1_u003b_i1_u003b((&param_23), (&param_24));
            let _e283 = power;
            let _e286 = v_2[1u];
            v_2[1u] = (_e286 + (_e282 * _e283));
            continue;
        } else {
            break;
        }
        continuing {
            let _e289 = i;
            i = (_e289 + 1i);
        }
    }
    let _e291 = v_2;
    v_2 = clamp(_e291, vec2<i32>(-1048576i, -1048576i), vec2<i32>(1048576i, 1048576i));
    let _e295 = pc.f0_[2u];
    param_25 = _e295;
    param_26 = 65536f;
    let _e296 = det_q_u0028_f1_u003b_f1_u003b((&param_25), (&param_26));
    keep = (65536i - _e296);
    let _e299 = v_2[0u];
    let _e300 = keep;
    param_27 = (_e299 * _e300);
    param_28 = 65536i;
    let _e302 = det_div_u0028_i1_u003b_i1_u003b((&param_27), (&param_28));
    let _e304 = v_2[1u];
    let _e305 = keep;
    param_29 = (_e304 * _e305);
    param_30 = 65536i;
    let _e307 = det_div_u0028_i1_u003b_i1_u003b((&param_29), (&param_30));
    let _e309 = v_2;
    v_2 = (_e309 - vec2<i32>(_e302, _e307));
    let _e311 = v_2;
    v64_ = (_e311 / vec2(64i));
    let _e315 = v64_[0u];
    let _e317 = v64_[0u];
    let _e320 = v64_[1u];
    let _e322 = v64_[1u];
    s2_ = ((_e315 * _e317) + (_e320 * _e322));
    let _e325 = s2_;
    if (_e325 > 9437184i) {
        let _e327 = s2_;
        param_31 = _e327;
        let _e328 = det_isqrt_u0028_i1_u003b((&param_31));
        sp = _e328;
        let _e330 = v64_[0u];
        param_32 = (_e330 * 3072i);
        let _e332 = sp;
        param_33 = _e332;
        let _e333 = det_div_u0028_i1_u003b_i1_u003b((&param_32), (&param_33));
        let _e335 = v64_[1u];
        param_34 = (_e335 * 3072i);
        let _e337 = sp;
        param_35 = _e337;
        let _e338 = det_div_u0028_i1_u003b_i1_u003b((&param_34), (&param_35));
        v_2 = (vec2<i32>(_e333, _e338) * vec2(64i));
    }
    let _e342 = solid;
    if (_e342 >= 10i) {
        v_2 = vec2<i32>(0i, 0i);
    }
    let _e344 = idx;
    let _e345 = v_2;
    let _e346 = solid;
    let _e347 = tavg;
    unnamed_1.vel[_e344] = vec4<i32>(_e345.x, _e345.y, _e346, _e347);
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
