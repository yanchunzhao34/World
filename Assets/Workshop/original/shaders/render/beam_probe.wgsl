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

struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct SunHits {
    sun_hit: array<u32>,
}

struct LampProbe {
    lamp_probe_out: array<vec4<u32>>,
}

struct Beams {
    beam: array<u32>,
}

struct SunHits_1 {
    sun_hit: array<atomic<u32>>,
}

var<private> g_afterEvent: bool;
var<private> g_n: vec2<i32>;
@group(0) @binding(3) 
var emissive_img: texture_2d<f32>;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
@group(0) @binding(2) 
var albedo_img: texture_2d<f32>;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(8) 
var day_tex: texture_2d<f32>;
@group(2) @binding(8) 
var day_tex_smp: sampler;
@group(0) @binding(11) 
var<storage, read_write> unnamed_1: SunHits_1;
var<workgroup> sh_e: array<vec4<f32>, 64>;
var<workgroup> sh_c: array<vec2<f32>, 64>;
var<workgroup> wu_flags: atomic<u32>;
var<workgroup> wu_alive0_: u32;
var<workgroup> wu_alive1_: u32;
var<workgroup> sh_mask: array<atomic<u32>, 8>;
var<workgroup> sh_E: vec3<f32>;
var<workgroup> sh_cs: vec2<f32>;
var<workgroup> wu_lsum: f32;
var<private> gl_LocalInvocationIndex_1: u32;
@group(0) @binding(12) 
var<storage, read_write> unnamed_2: LampProbe;
@group(0) @binding(4) 
var gaux_img: texture_2d<f32>;
@group(0) @binding(5) 
var fluence_tex: texture_2d<f32>;
@group(2) @binding(5) 
var fluence_tex_smp: sampler;
@group(0) @binding(6) 
var ldir_tex: texture_2d<f32>;
@group(2) @binding(6) 
var ldir_tex_smp: sampler;
@group(0) @binding(7) 
var<storage, read_write> unnamed_3: Beams;
@group(0) @binding(9) 
var beam_prev: texture_2d<f32>;
@group(2) @binding(9) 
var beam_prev_smp: sampler;
@group(0) @binding(10) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(10) 
var medium_tex_smp: sampler;
var<private> g_dir0_: vec2<f32>;
var<workgroup> sh_ray: array<vec4<f32>, 512>;
var<workgroup> sh_L: array<vec4<f32>, 512>;
var<workgroup> sh_dy: array<f32, 512>;

fn matAt_u0028_vi2_u003b(q: ptr<function, vec2<i32>>) -> u32 {
    let _e151 = (*q);
    let _e152 = textureLoad(cells, _e151, 0i);
    return (_e152.x & 255u);
}

fn state_u0028_vi2_u003b(q_1: ptr<function, vec2<i32>>) -> u32 {
    let _e151 = (*q_1);
    let _e152 = textureLoad(emissive_img, _e151, 0i);
    return u32((_e152.w + 0.5f));
}

fn blocks_u0028_vi2_u003b(q_2: ptr<function, vec2<i32>>) -> bool {
    var st: u32;
    var param: vec2<i32>;
    var phi_304_: bool;
    var phi_305_: bool;

    let _e153 = (*q_2);
    param = _e153;
    let _e154 = state_u0028_vi2_u003b((&param));
    st = _e154;
    let _e155 = st;
    let _e157 = st;
    let _e159 = ((_e155 == 3u) || (_e157 == 2u));
    phi_305_ = _e159;
    if !(_e159) {
        let _e161 = st;
        let _e162 = (_e161 == 1u);
        phi_304_ = _e162;
        if _e162 {
            let _e163 = (*q_2);
            let _e164 = textureLoad(albedo_img, _e163, 0i);
            phi_304_ = (_e164.w > 0.97f);
        }
        let _e168 = phi_304_;
        phi_305_ = _e168;
    }
    let _e170 = phi_305_;
    return _e170;
}

fn dispersion_u0028_vi2_u003b_f1_u003b(q_3: ptr<function, vec2<i32>>, ior: ptr<function, f32>) -> f32 {
    var param_1: vec2<i32>;
    var local: f32;

    let _e154 = (*q_3);
    param_1 = _e154;
    let _e155 = state_u0028_vi2_u003b((&param_1));
    if (_e155 == 1u) {
        local = 0f;
    } else {
        let _e157 = (*ior);
        local = ((_e157 - 1f) * 0.06f);
    }
    let _e160 = local;
    return _e160;
}

fn refr_ior_u0028_vi2_u003b(q_4: ptr<function, vec2<i32>>) -> f32 {
    var st_1: u32;
    var param_2: vec2<i32>;
    var ior_1: f32;
    var param_3: vec2<i32>;
    var phi_337_: bool;

    let _e155 = (*q_4);
    param_2 = _e155;
    let _e156 = state_u0028_vi2_u003b((&param_2));
    st_1 = _e156;
    let _e157 = st_1;
    if (_e157 == 0u) {
        return 0f;
    }
    let _e159 = (*q_4);
    let _e160 = textureLoad(albedo_img, _e159, 0i);
    if (_e160.w > 0.97f) {
        return 0f;
    }
    let _e163 = st_1;
    let _e164 = (_e163 == 1u);
    phi_337_ = _e164;
    if _e164 {
        let _e165 = (*q_4);
        let _e166 = textureLoad(cells, _e165, 0i);
        phi_337_ = ((_e166.w & 255u) > 128u);
    }
    let _e171 = phi_337_;
    if _e171 {
        return 0f;
    }
    let _e172 = (*q_4);
    param_3 = _e172;
    let _e173 = matAt_u0028_vi2_u003b((&param_3));
    let _e178 = unnamed.mats[_e173].optics[2u];
    ior_1 = _e178;
    let _e179 = ior_1;
    if (_e179 <= 1.05f) {
        let _e181 = st_1;
        ior_1 = select(0f, 1.33f, (_e181 == 1u));
    }
    let _e184 = ior_1;
    return _e184;
}

fn inw_u0028_vi2_u003b(q_5: ptr<function, vec2<i32>>) -> bool {
    var phi_252_: bool;

    let _e151 = (*q_5);
    let _e153 = all((_e151 >= vec2<i32>(0i, 0i)));
    phi_252_ = _e153;
    if _e153 {
        let _e154 = (*q_5);
        let _e155 = g_n;
        phi_252_ = all((_e154 < _e155));
    }
    let _e159 = phi_252_;
    return _e159;
}

fn oblique_glass_u0028_vi2_u003b(q_6: ptr<function, vec2<i32>>) -> bool {
    var mid: u32;
    var param_4: vec2<i32>;
    var g: vec2<f32>;
    var y: i32;
    var x: i32;
    var c: vec2<i32>;
    var same: bool;
    var param_5: vec2<i32>;
    var param_6: vec2<i32>;
    var param_7: vec2<i32>;
    var param_8: vec2<i32>;
    var phi_436_: bool;
    var phi_437_: bool;
    var phi_438_: bool;
    var phi_464_: bool;
    var phi_476_: bool;

    let _e162 = (*q_6);
    param_4 = _e162;
    let _e163 = matAt_u0028_vi2_u003b((&param_4));
    mid = _e163;
    g = vec2<f32>(0f, 0f);
    y = -1i;
    loop {
        let _e164 = y;
        if (_e164 <= 1i) {
            x = -1i;
            loop {
                let _e166 = x;
                if (_e166 <= 1i) {
                    let _e168 = (*q_6);
                    let _e169 = x;
                    let _e170 = y;
                    c = (_e168 + vec2<i32>(_e169, _e170));
                    let _e173 = c;
                    param_5 = _e173;
                    let _e174 = inw_u0028_vi2_u003b((&param_5));
                    phi_438_ = _e174;
                    if _e174 {
                        let _e175 = c;
                        param_6 = _e175;
                        let _e176 = matAt_u0028_vi2_u003b((&param_6));
                        let _e177 = mid;
                        let _e178 = (_e176 == _e177);
                        phi_437_ = _e178;
                        if !(_e178) {
                            let _e180 = c;
                            param_7 = _e180;
                            let _e181 = refr_ior_u0028_vi2_u003b((&param_7));
                            let _e182 = (_e181 > 0f);
                            phi_436_ = _e182;
                            if _e182 {
                                let _e183 = c;
                                param_8 = _e183;
                                let _e184 = state_u0028_vi2_u003b((&param_8));
                                phi_436_ = (_e184 == 3u);
                            }
                            let _e187 = phi_436_;
                            phi_437_ = _e187;
                        }
                        let _e189 = phi_437_;
                        phi_438_ = _e189;
                    }
                    let _e191 = phi_438_;
                    same = _e191;
                    let _e192 = same;
                    if !(_e192) {
                        let _e194 = x;
                        let _e196 = y;
                        let _e199 = g;
                        g = (_e199 + vec2<f32>(f32(_e194), f32(_e196)));
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e201 = x;
                    x = (_e201 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e203 = y;
            y = (_e203 + 1i);
        }
    }
    let _e206 = g[0u];
    let _e208 = (abs(_e206) > 0.5f);
    phi_464_ = _e208;
    if _e208 {
        let _e210 = g[1u];
        phi_464_ = (abs(_e210) > 0.5f);
    }
    let _e214 = phi_464_;
    phi_476_ = _e214;
    if _e214 {
        let _e216 = g[0u];
        let _e219 = g[1u];
        phi_476_ = (abs((abs(_e216) - abs(_e219))) < 0.5f);
    }
    let _e225 = phi_476_;
    return _e225;
}

fn thin_glass_u0028_vf2_u003b_vf2_u003b(x_1: ptr<function, vec2<f32>>, dir: ptr<function, vec2<f32>>) -> i32 {
    var k: i32;
    var q_7: vec2<i32>;
    var param_9: vec2<i32>;
    var param_10: vec2<i32>;
    var param_11: vec2<i32>;
    var phi_821_: bool;
    var phi_829_: bool;

    k = 0i;
    loop {
        let _e157 = k;
        if (_e157 < 4i) {
            let _e159 = (*x_1);
            let _e160 = (*dir);
            let _e161 = k;
            q_7 = vec2<i32>(floor((_e159 + (_e160 * f32(_e161)))));
            let _e167 = q_7;
            param_9 = _e167;
            let _e168 = inw_u0028_vi2_u003b((&param_9));
            let _e169 = !(_e168);
            phi_821_ = _e169;
            if !(_e169) {
                let _e171 = q_7;
                param_10 = _e171;
                let _e172 = refr_ior_u0028_vi2_u003b((&param_10));
                phi_821_ = (_e172 <= 0f);
            }
            let _e175 = phi_821_;
            phi_829_ = _e175;
            if !(_e175) {
                let _e177 = q_7;
                param_11 = _e177;
                let _e178 = state_u0028_vi2_u003b((&param_11));
                phi_829_ = (_e178 == 1u);
            }
            let _e181 = phi_829_;
            if _e181 {
                let _e182 = k;
                return _e182;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e183 = k;
            k = (_e183 + 1i);
        }
    }
    return 99i;
}

fn lamp_start_u0028_vf2_u003b_vf2_u003b_u1_u003b_vf2_u003b(c_1: ptr<function, vec2<f32>>, dir_1: ptr<function, vec2<f32>>, startMat: ptr<function, u32>, x0_: ptr<function, vec2<f32>>) -> bool {
    var lastIn: i32;
    var k_1: i32;
    var q_8: vec2<i32>;
    var param_12: vec2<i32>;
    var eq: vec3<f32>;
    var param_13: vec2<i32>;
    var th: i32;
    var param_14: vec2<f32>;
    var param_15: vec2<f32>;
    var param_16: vec2<i32>;
    var phi_890_: bool;
    var phi_930_: bool;

    lastIn = 0i;
    k_1 = 0i;
    loop {
        let _e164 = k_1;
        if (_e164 < 48i) {
            let _e166 = (*c_1);
            let _e167 = (*dir_1);
            let _e168 = k_1;
            q_8 = vec2<i32>(floor((_e166 + (_e167 * f32(_e168)))));
            let _e174 = q_8;
            param_12 = _e174;
            let _e175 = inw_u0028_vi2_u003b((&param_12));
            if !(_e175) {
                break;
            }
            let _e177 = q_8;
            let _e178 = textureLoad(emissive_img, _e177, 0i);
            eq = _e178.xyz;
            let _e181 = eq[0u];
            let _e183 = eq[1u];
            let _e186 = eq[2u];
            let _e189 = ((((_e181 + _e183) + _e186) / 3f) >= 0.05f);
            phi_890_ = _e189;
            if !(_e189) {
                let _e191 = q_8;
                param_13 = _e191;
                let _e192 = matAt_u0028_vi2_u003b((&param_13));
                let _e193 = (*startMat);
                phi_890_ = (_e192 == _e193);
            }
            let _e196 = phi_890_;
            if _e196 {
                let _e197 = k_1;
                lastIn = _e197;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e198 = k_1;
            k_1 = (_e198 + 1i);
        }
    }
    let _e200 = (*c_1);
    let _e201 = (*dir_1);
    let _e202 = lastIn;
    (*x0_) = (_e200 + (_e201 * f32((_e202 + 1i))));
    let _e207 = (*x0_);
    param_14 = _e207;
    let _e208 = (*dir_1);
    param_15 = _e208;
    let _e209 = thin_glass_u0028_vf2_u003b_vf2_u003b((&param_14), (&param_15));
    th = _e209;
    let _e210 = th;
    if (_e210 < 4i) {
        let _e212 = (*dir_1);
        let _e213 = th;
        let _e216 = (*x0_);
        (*x0_) = (_e216 + (_e212 * f32(_e213)));
    }
    let _e218 = lastIn;
    let _e219 = (_e218 < 40i);
    phi_930_ = _e219;
    if _e219 {
        let _e220 = (*x0_);
        param_16 = vec2<i32>(floor(_e220));
        let _e223 = refr_ior_u0028_vi2_u003b((&param_16));
        phi_930_ = (_e223 <= 0f);
    }
    let _e226 = phi_930_;
    return _e226;
}

fn lamp_probe_u0028_vf2_u003b_vf2_u003b_u1_u003b_vf2_u003b_b1_u003b(c_2: ptr<function, vec2<f32>>, dir_2: ptr<function, vec2<f32>>, startMat_1: ptr<function, u32>, x0_1: ptr<function, vec2<f32>>, disp: ptr<function, bool>) -> bool {
    var param_17: vec2<f32>;
    var param_18: vec2<f32>;
    var param_19: u32;
    var param_20: vec2<f32>;
    var k_2: i32;
    var q_9: vec2<i32>;
    var param_21: vec2<i32>;
    var iq: f32;
    var param_22: vec2<i32>;
    var solid: bool;
    var param_23: vec2<i32>;
    var th_1: i32;
    var local_1: i32;
    var param_24: vec2<f32>;
    var param_25: vec2<f32>;
    var param_26: vec2<i32>;
    var param_27: vec2<i32>;
    var param_28: f32;
    var param_29: vec2<i32>;
    var mq: Material;
    var param_30: vec2<i32>;
    var phi_1013_: bool;
    var phi_1014_: bool;
    var phi_1101_: bool;
    var phi_1102_: bool;

    (*disp) = false;
    let _e176 = (*c_2);
    param_17 = _e176;
    let _e177 = (*dir_2);
    param_18 = _e177;
    let _e178 = (*startMat_1);
    param_19 = _e178;
    let _e179 = lamp_start_u0028_vf2_u003b_vf2_u003b_u1_u003b_vf2_u003b((&param_17), (&param_18), (&param_19), (&param_20));
    let _e180 = param_20;
    (*x0_1) = _e180;
    if !(_e179) {
        return false;
    }
    k_2 = 0i;
    loop {
        let _e182 = k_2;
        if (_e182 < 56i) {
            let _e184 = (*x0_1);
            let _e185 = (*dir_2);
            let _e186 = k_2;
            q_9 = vec2<i32>(floor((_e184 + (_e185 * f32(_e186)))));
            let _e192 = q_9;
            param_21 = _e192;
            let _e193 = inw_u0028_vi2_u003b((&param_21));
            if !(_e193) {
                return false;
            }
            let _e195 = q_9;
            param_22 = _e195;
            let _e196 = refr_ior_u0028_vi2_u003b((&param_22));
            iq = _e196;
            let _e197 = iq;
            if (_e197 > 0f) {
                let _e199 = q_9;
                param_23 = _e199;
                let _e200 = state_u0028_vi2_u003b((&param_23));
                solid = (_e200 != 1u);
                let _e202 = solid;
                if _e202 {
                    let _e203 = (*x0_1);
                    let _e204 = (*dir_2);
                    let _e205 = k_2;
                    param_24 = (_e203 + (_e204 * f32(_e205)));
                    let _e209 = (*dir_2);
                    param_25 = _e209;
                    let _e210 = thin_glass_u0028_vf2_u003b_vf2_u003b((&param_24), (&param_25));
                    local_1 = _e210;
                } else {
                    local_1 = 99i;
                }
                let _e211 = local_1;
                th_1 = _e211;
                let _e212 = th_1;
                let _e213 = (_e212 < 4i);
                phi_1014_ = _e213;
                if !(_e213) {
                    let _e215 = solid;
                    phi_1013_ = _e215;
                    if _e215 {
                        let _e216 = q_9;
                        param_26 = _e216;
                        let _e217 = oblique_glass_u0028_vi2_u003b((&param_26));
                        phi_1013_ = !(_e217);
                    }
                    let _e220 = phi_1013_;
                    phi_1014_ = _e220;
                }
                let _e222 = phi_1014_;
                if _e222 {
                    let _e223 = th_1;
                    let _e225 = k_2;
                    k_2 = (_e225 + max(_e223, 1i));
                    let _e227 = th_1;
                    if (_e227 >= 4i) {
                        return false;
                    }
                    continue;
                }
                let _e229 = q_9;
                param_27 = _e229;
                let _e230 = iq;
                param_28 = _e230;
                let _e231 = dispersion_u0028_vi2_u003b_f1_u003b((&param_27), (&param_28));
                (*disp) = (_e231 > 0f);
                return true;
            }
            let _e233 = q_9;
            param_29 = _e233;
            let _e234 = blocks_u0028_vi2_u003b((&param_29));
            if _e234 {
                let _e235 = q_9;
                param_30 = _e235;
                let _e236 = matAt_u0028_vi2_u003b((&param_30));
                let _e239 = unnamed.mats[_e236];
                mq.color_a = _e239.color_a;
                mq.color_b = _e239.color_b;
                mq.emission = _e239.emission;
                mq.phys = _e239.phys;
                mq.thermo = _e239.thermo;
                mq.burn = _e239.burn;
                mq.optics = _e239.optics;
                mq.scatter = _e239.scatter;
                mq.ids = _e239.ids;
                mq.ids2_ = _e239.ids2_;
                mq.misc = _e239.misc;
                mq.surface = _e239.surface;
                mq.sss = _e239.sss;
                mq.sss_color = _e239.sss_color;
                mq.optics2_ = _e239.optics2_;
                mq.pal0_ = _e239.pal0_;
                mq.pal1_ = _e239.pal1_;
                mq.pal2_ = _e239.pal2_;
                mq.pal3_ = _e239.pal3_;
                mq.accent = _e239.accent;
                mq.flame = _e239.flame;
                let _e284 = mq.optics2_[1u];
                let _e285 = (_e284 >= 0.3f);
                phi_1102_ = _e285;
                if !(_e285) {
                    let _e289 = mq.surface[2u];
                    let _e290 = (_e289 > 0.5f);
                    phi_1101_ = _e290;
                    if _e290 {
                        let _e293 = mq.surface[1u];
                        phi_1101_ = (_e293 < 0.3f);
                    }
                    let _e296 = phi_1101_;
                    phi_1102_ = _e296;
                }
                let _e298 = phi_1102_;
                return _e298;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e299 = k_2;
            k_2 = (_e299 + 1i);
        }
    }
    return false;
}

fn u01_u0028_u1_u003b(x_2: ptr<function, u32>) -> f32 {
    let _e151 = (*x_2);
    return (f32((_e151 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e151 = (*v);
    (*v) = ((_e151 * vec3(1664525u)) + vec3(1013904223u));
    let _e157 = (*v)[1u];
    let _e159 = (*v)[2u];
    let _e162 = (*v)[0u];
    (*v)[0u] = (_e162 + (_e157 * _e159));
    let _e166 = (*v)[2u];
    let _e168 = (*v)[0u];
    let _e171 = (*v)[1u];
    (*v)[1u] = (_e171 + (_e166 * _e168));
    let _e175 = (*v)[0u];
    let _e177 = (*v)[1u];
    let _e180 = (*v)[2u];
    (*v)[2u] = (_e180 + (_e175 * _e177));
    let _e183 = (*v);
    let _e187 = (*v);
    (*v) = (_e187 ^ (_e183 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e190 = (*v)[1u];
    let _e192 = (*v)[2u];
    let _e195 = (*v)[0u];
    (*v)[0u] = (_e195 + (_e190 * _e192));
    let _e199 = (*v)[2u];
    let _e201 = (*v)[0u];
    let _e204 = (*v)[1u];
    (*v)[1u] = (_e204 + (_e199 * _e201));
    let _e208 = (*v)[0u];
    let _e210 = (*v)[1u];
    let _e213 = (*v)[2u];
    (*v)[2u] = (_e213 + (_e208 * _e210));
    let _e216 = (*v);
    return _e216;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param_31: vec3<u32>;

    let _e152 = (*v_1);
    param_31 = _e152;
    let _e153 = pcg3d_u0028_vu3_u003b((&param_31));
    return _e153.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_32: vec3<u32>;
    var param_33: u32;

    let _e153 = (*p);
    let _e155 = vec2<i32>(floor(_e153));
    param_32 = bitcast<vec3<u32>>(vec3<i32>(_e155.x, _e155.y, 1777i));
    let _e160 = hash1_u0028_vu3_u003b((&param_32));
    param_33 = _e160;
    let _e161 = u01_u0028_u1_u003b((&param_33));
    return _e161;
}

fn lamp_jitter_u0028_vi2_u003b(tile: ptr<function, vec2<i32>>) -> f32 {
    var param_34: vec2<f32>;

    let _e152 = (*tile);
    param_34 = ((vec2<f32>(_e152) * 1.7f) + vec2(3f));
    let _e157 = hash21_u0028_vf2_u003b((&param_34));
    return ((_e157 * 6.2831855f) / 64f);
}

fn lamp_gather_u0028_vi2_u003b_u1_u003b_vf3_u003b_vf2_u003b_f1_u003b(tile_1: ptr<function, vec2<i32>>, li: ptr<function, u32>, E: ptr<function, vec3<f32>>, c_3: ptr<function, vec2<f32>>, lsum: ptr<function, f32>) {
    var p_1: vec2<i32>;
    var e: vec3<f32>;
    var cs: vec2<f32>;
    var le: f32;
    var k_3: i32;
    var q_10: vec2<i32>;
    var param_35: vec2<i32>;
    var eq_1: vec3<f32>;
    var lq: f32;
    var e_1: vec3<f32>;
    var cs_1: vec2<f32>;
    var ls: f32;
    var k_4: i32;

    let _e168 = (*li);
    if (_e168 < 64u) {
        let _e170 = (*tile_1);
        let _e173 = (*li);
        let _e176 = (*li);
        p_1 = ((_e170 * vec2(8i)) + vec2<i32>(bitcast<i32>((_e173 & 7u)), bitcast<i32>((_e176 >> bitcast<u32>(3u)))));
        e = vec3<f32>(0f, 0f, 0f);
        cs = vec2<f32>(0f, 0f);
        le = 0f;
        k_3 = 0i;
        loop {
            let _e182 = k_3;
            if (_e182 < 4i) {
                let _e184 = p_1;
                let _e187 = k_3;
                let _e189 = k_3;
                q_10 = ((_e184 * vec2(2i)) + vec2<i32>((_e187 & 1i), (_e189 >> bitcast<u32>(1i))));
                let _e194 = q_10;
                param_35 = _e194;
                let _e195 = inw_u0028_vi2_u003b((&param_35));
                if !(_e195) {
                    continue;
                }
                let _e197 = q_10;
                let _e198 = textureLoad(emissive_img, _e197, 0i);
                eq_1 = _e198.xyz;
                let _e201 = eq_1[0u];
                let _e203 = eq_1[1u];
                let _e206 = eq_1[2u];
                lq = (((_e201 + _e203) + _e206) / 3f);
                let _e209 = lq;
                if (_e209 < 0.05f) {
                    continue;
                }
                let _e211 = eq_1;
                let _e212 = e;
                e = (_e212 + _e211);
                let _e214 = lq;
                let _e215 = le;
                le = (_e215 + _e214);
                let _e217 = q_10;
                let _e221 = lq;
                let _e223 = cs;
                cs = (_e223 + ((vec2<f32>(_e217) + vec2(0.5f)) * _e221));
                continue;
            } else {
                break;
            }
            continuing {
                let _e225 = k_3;
                k_3 = (_e225 + 1i);
            }
        }
        let _e227 = (*li);
        let _e228 = e;
        let _e229 = le;
        sh_e[_e227] = vec4<f32>(_e228.x, _e228.y, _e228.z, _e229);
        let _e235 = (*li);
        let _e236 = cs;
        sh_c[_e235] = _e236;
    }
    let _e238 = (*li);
    if (_e238 == 0u) {
        atomicStore((&wu_flags), 0u);
        wu_alive0_ = 0u;
        wu_alive1_ = 0u;
    }
    let _e240 = (*li);
    if (_e240 < 8u) {
        let _e242 = (*li);
        atomicStore((&sh_mask[_e242]), 0u);
    }
    workgroupBarrier();
    let _e244 = (*li);
    if (_e244 == 0u) {
        e_1 = vec3<f32>(0f, 0f, 0f);
        cs_1 = vec2<f32>(0f, 0f);
        ls = 0f;
        k_4 = 0i;
        loop {
            let _e246 = k_4;
            if (_e246 < 64i) {
                let _e248 = k_4;
                let _e250 = sh_e[_e248];
                let _e252 = e_1;
                e_1 = (_e252 + _e250.xyz);
                let _e254 = k_4;
                let _e257 = sh_e[_e254][3u];
                let _e258 = ls;
                ls = (_e258 + _e257);
                let _e260 = k_4;
                let _e262 = sh_c[_e260];
                let _e263 = cs_1;
                cs_1 = (_e263 + _e262);
                continue;
            } else {
                break;
            }
            continuing {
                let _e265 = k_4;
                k_4 = (_e265 + 1i);
            }
        }
        let _e267 = e_1;
        sh_E = _e267;
        let _e268 = cs_1;
        sh_cs = _e268;
        let _e269 = ls;
        wu_lsum = _e269;
    }
    workgroupBarrier();
    let _e270 = sh_E;
    (*E) = _e270;
    let _e271 = sh_cs;
    (*c_3) = _e271;
    let _e272 = workgroupUniformLoad((&wu_lsum));
    (*lsum) = _e272;
    return;
}

fn lamp_probe_block_u0028_vi2_u003b(tile_2: ptr<function, vec2<i32>>) {
    var li_1: u32;
    var E_1: vec3<f32>;
    var c_4: vec2<f32>;
    var lsum_1: f32;
    var param_36: vec2<i32>;
    var param_37: u32;
    var param_38: vec3<f32>;
    var param_39: vec2<f32>;
    var param_40: f32;
    var jitter: f32;
    var param_41: vec2<i32>;
    var startMat_2: u32;
    var param_42: vec2<i32>;
    var pi: i32;
    var pa: f32;
    var x0p: vec2<f32>;
    var disp_1: bool;
    var param_43: vec2<f32>;
    var param_44: vec2<f32>;
    var param_45: u32;
    var param_46: vec2<f32>;
    var param_47: bool;
    var flags: u32;
    var gapStart: i32;
    var gapLen: i32;
    var run: i32;
    var runStart: i32;
    var k_5: i32;
    var b: i32;
    var hitb: bool;
    var phi_1314_: bool;

    let _e181 = gl_LocalInvocationIndex_1;
    li_1 = _e181;
    let _e182 = (*tile_2);
    param_36 = _e182;
    let _e183 = li_1;
    param_37 = _e183;
    lamp_gather_u0028_vi2_u003b_u1_u003b_vf3_u003b_vf2_u003b_f1_u003b((&param_36), (&param_37), (&param_38), (&param_39), (&param_40));
    let _e184 = param_38;
    E_1 = _e184;
    let _e185 = param_39;
    c_4 = _e185;
    let _e186 = param_40;
    lsum_1 = _e186;
    let _e187 = workgroupUniformLoad((&wu_lsum));
    let _e188 = (_e187 < 4f);
    phi_1314_ = _e188;
    if !(_e188) {
        let _e192 = pc.f1_[2u];
        phi_1314_ = (_e192 <= 0f);
    }
    let _e195 = phi_1314_;
    if _e195 {
        return;
    }
    let _e196 = lsum_1;
    let _e197 = c_4;
    c_4 = (_e197 / vec2(_e196));
    let _e200 = (*tile_2);
    param_41 = _e200;
    let _e201 = lamp_jitter_u0028_vi2_u003b((&param_41));
    jitter = _e201;
    let _e202 = c_4;
    let _e205 = g_n;
    param_42 = clamp(vec2<i32>(floor(_e202)), vec2<i32>(0i, 0i), (_e205 - vec2(1i)));
    let _e209 = matAt_u0028_vi2_u003b((&param_42));
    startMat_2 = _e209;
    let _e210 = li_1;
    pi = bitcast<i32>(_e210);
    let _e212 = pi;
    let _e217 = jitter;
    pa = ((((f32(_e212) + 0.5f) / 256f) * 6.2831855f) + _e217);
    let _e219 = pa;
    let _e221 = pa;
    let _e224 = c_4;
    param_43 = _e224;
    param_44 = vec2<f32>(cos(_e219), sin(_e221));
    let _e225 = startMat_2;
    param_45 = _e225;
    let _e226 = lamp_probe_u0028_vf2_u003b_vf2_u003b_u1_u003b_vf2_u003b_b1_u003b((&param_43), (&param_44), (&param_45), (&param_46), (&param_47));
    let _e227 = param_46;
    x0p = _e227;
    let _e228 = param_47;
    disp_1 = _e228;
    if _e226 {
        let _e229 = pi;
        let _e233 = pi;
        let _e238 = atomicOr((&sh_mask[(_e229 >> bitcast<u32>(5i))]), (1u << bitcast<u32>(bitcast<u32>((_e233 & 31i)))));
        let _e239 = disp_1;
        let _e241 = atomicOr((&wu_flags), select(1u, 3u, _e239));
    }
    workgroupBarrier();
    let _e242 = workgroupUniformLoad((&wu_flags));
    flags = _e242;
    let _e243 = li_1;
    if (_e243 == 0u) {
        gapStart = 0i;
        gapLen = 0i;
        run = 0i;
        runStart = 0i;
        k_5 = 0i;
        loop {
            let _e245 = k_5;
            if (_e245 < 512i) {
                let _e247 = k_5;
                b = (_e247 % 256i + select(0i, 256i, _e247 % 256i != 0i && ((_e247 % 256i < 0i) != (256i < 0i))));
                let _e255 = b;
                let _e259 = atomicLoad((&sh_mask[(_e255 >> bitcast<u32>(5i))]));
                let _e260 = b;
                hitb = ((_e259 & (1u << bitcast<u32>(bitcast<u32>((_e260 & 31i))))) != 0u);
                let _e267 = hitb;
                if !(_e267) {
                    let _e269 = run;
                    if (_e269 == 0i) {
                        let _e271 = k_5;
                        runStart = _e271;
                    }
                    let _e272 = run;
                    run = (_e272 + 1i);
                    let _e274 = run;
                    let _e275 = gapLen;
                    let _e277 = run;
                    if ((_e274 > _e275) && (_e277 <= 256i)) {
                        let _e280 = run;
                        gapLen = _e280;
                        let _e281 = runStart;
                        gapStart = _e281;
                    }
                } else {
                    run = 0i;
                }
                continue;
            } else {
                break;
            }
            continuing {
                let _e282 = k_5;
                k_5 = (_e282 + 1i);
            }
        }
        let _e285 = (*tile_2)[1u];
        let _e288 = pc.i1_[0u];
        let _e291 = (*tile_2)[0u];
        let _e293 = flags;
        let _e294 = gapStart;
        let _e296 = gapLen;
        unnamed_2.lamp_probe_out[((_e285 * _e288) + _e291)] = vec4<u32>(_e293, bitcast<u32>(_e294), bitcast<u32>(_e296), 0u);
    }
    return;
}

fn luminance_u0028_vf3_u003b(c_5: ptr<function, vec3<f32>>) -> f32 {
    let _e151 = (*c_5);
    return dot(_e151, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn sun_target_u0028_vi2_u003b(q_11: ptr<function, vec2<i32>>) -> bool {
    var param_48: vec2<i32>;
    var param_49: vec2<i32>;
    var param_50: vec2<i32>;
    var param_51: vec2<i32>;
    var m: Material;
    var param_52: vec2<i32>;
    var phi_590_: bool;
    var phi_591_: bool;

    let _e157 = (*q_11);
    param_48 = _e157;
    let _e158 = refr_ior_u0028_vi2_u003b((&param_48));
    if (_e158 > 0f) {
        let _e160 = (*q_11);
        param_49 = _e160;
        let _e161 = state_u0028_vi2_u003b((&param_49));
        if (_e161 == 1u) {
            return true;
        }
        let _e163 = (*q_11);
        param_50 = _e163;
        let _e164 = oblique_glass_u0028_vi2_u003b((&param_50));
        return _e164;
    }
    let _e165 = (*q_11);
    param_51 = _e165;
    let _e166 = blocks_u0028_vi2_u003b((&param_51));
    if !(_e166) {
        return false;
    }
    let _e168 = (*q_11);
    param_52 = _e168;
    let _e169 = matAt_u0028_vi2_u003b((&param_52));
    let _e172 = unnamed.mats[_e169];
    m.color_a = _e172.color_a;
    m.color_b = _e172.color_b;
    m.emission = _e172.emission;
    m.phys = _e172.phys;
    m.thermo = _e172.thermo;
    m.burn = _e172.burn;
    m.optics = _e172.optics;
    m.scatter = _e172.scatter;
    m.ids = _e172.ids;
    m.ids2_ = _e172.ids2_;
    m.misc = _e172.misc;
    m.surface = _e172.surface;
    m.sss = _e172.sss;
    m.sss_color = _e172.sss_color;
    m.optics2_ = _e172.optics2_;
    m.pal0_ = _e172.pal0_;
    m.pal1_ = _e172.pal1_;
    m.pal2_ = _e172.pal2_;
    m.pal3_ = _e172.pal3_;
    m.accent = _e172.accent;
    m.flame = _e172.flame;
    let _e217 = m.optics2_[1u];
    let _e218 = (_e217 >= 0.3f);
    phi_591_ = _e218;
    if !(_e218) {
        let _e222 = m.surface[2u];
        let _e223 = (_e222 > 0.5f);
        phi_590_ = _e223;
        if _e223 {
            let _e226 = m.surface[1u];
            phi_590_ = (_e226 < 0.3f);
        }
        let _e229 = phi_590_;
        phi_591_ = _e229;
    }
    let _e231 = phi_591_;
    return _e231;
}

fn sun_meets_u0028_vf2_u003b_vf2_u003b_i1_u003b_b1_u003b(start: ptr<function, vec2<f32>>, d: ptr<function, vec2<f32>>, t: ptr<function, i32>, disp_2: ptr<function, bool>) -> bool {
    var x_3: vec2<f32>;
    var q_12: vec2<i32>;
    var param_53: vec2<i32>;
    var param_54: vec2<i32>;
    var iq_1: f32;
    var param_55: vec2<i32>;
    var param_56: vec2<i32>;
    var param_57: f32;
    var param_58: vec3<f32>;
    var phi_678_: bool;
    var phi_696_: bool;

    (*disp_2) = false;
    let _e163 = (*start);
    let _e164 = (*d);
    let _e165 = (*t);
    x_3 = (_e163 + (_e164 * f32(_e165)));
    let _e169 = x_3;
    q_12 = vec2<i32>(floor(_e169));
    let _e172 = q_12;
    param_53 = _e172;
    let _e173 = inw_u0028_vi2_u003b((&param_53));
    let _e174 = !(_e173);
    phi_678_ = _e174;
    if !(_e174) {
        let _e176 = q_12;
        param_54 = _e176;
        let _e177 = sun_target_u0028_vi2_u003b((&param_54));
        phi_678_ = !(_e177);
    }
    let _e180 = phi_678_;
    if _e180 {
        return false;
    }
    let _e181 = q_12;
    param_55 = _e181;
    let _e182 = refr_ior_u0028_vi2_u003b((&param_55));
    iq_1 = _e182;
    let _e183 = iq_1;
    let _e184 = (_e183 > 0f);
    phi_696_ = _e184;
    if _e184 {
        let _e185 = q_12;
        param_56 = _e185;
        let _e186 = iq_1;
        param_57 = _e186;
        let _e187 = dispersion_u0028_vi2_u003b_f1_u003b((&param_56), (&param_57));
        phi_696_ = (_e187 > 0f);
    }
    let _e190 = phi_696_;
    (*disp_2) = _e190;
    let _e191 = x_3;
    let _e192 = (*d);
    let _e194 = g_n;
    let _e197 = textureSampleLevel(day_tex, day_tex_smp, ((_e191 - _e192) / vec2<f32>(_e194)), 0f);
    param_58 = _e197.xyz;
    let _e199 = luminance_u0028_vf3_u003b((&param_58));
    return (_e199 > 0.02f);
}

fn sun_ray_u0028_i1_u003b_vf2_u003b_vf2_u003b_i1_u003b(k_6: ptr<function, i32>, d_1: ptr<function, vec2<f32>>, start_1: ptr<function, vec2<f32>>, steps: ptr<function, i32>) -> bool {
    var nrm: vec2<f32>;
    var wc: vec2<f32>;
    var R: f32;
    var off: f32;
    var phi_614_: bool;

    let _e159 = pc.f1_;
    (*d_1) = _e159.xy;
    (*start_1) = vec2<f32>(0f, 0f);
    (*steps) = 0i;
    let _e161 = (*d_1);
    let _e162 = (*d_1);
    let _e164 = (dot(_e161, _e162) < 0.000001f);
    phi_614_ = _e164;
    if !(_e164) {
        let _e168 = pc.f0_[0u];
        phi_614_ = (_e168 <= 0f);
    }
    let _e171 = phi_614_;
    if _e171 {
        return false;
    }
    let _e172 = (*d_1);
    (*d_1) = normalize(_e172);
    let _e175 = (*d_1)[1u];
    let _e178 = (*d_1)[0u];
    nrm = vec2<f32>(-(_e175), _e178);
    let _e180 = g_n;
    wc = (vec2<f32>(_e180) * 0.5f);
    let _e183 = wc;
    R = (length(_e183) + 2f);
    let _e186 = (*k_6);
    off = ((f32(_e186) - 320f) + 0.5f);
    let _e190 = wc;
    let _e191 = (*d_1);
    let _e192 = R;
    let _e195 = nrm;
    let _e196 = off;
    (*start_1) = ((_e190 - (_e191 * _e192)) + (_e195 * _e196));
    let _e199 = R;
    (*steps) = i32((2f * _e199));
    return true;
}

fn sun_probe_seg_u0028_i1_u003b_i1_u003b(k_7: ptr<function, i32>, seg: ptr<function, i32>) {
    var d_2: vec2<f32>;
    var start_2: vec2<f32>;
    var steps_1: i32;
    var param_59: i32;
    var param_60: vec2<f32>;
    var param_61: vec2<f32>;
    var param_62: i32;
    var t0_: i32;
    var t1_: i32;
    var t_1: i32;
    var disp_3: bool;
    var param_63: vec2<f32>;
    var param_64: vec2<f32>;
    var param_65: i32;
    var param_66: bool;
    var phi_738_: bool;

    let _e167 = (*k_7);
    let _e168 = (_e167 >= 640i);
    phi_738_ = _e168;
    if !(_e168) {
        let _e170 = (*k_7);
        param_59 = _e170;
        let _e171 = sun_ray_u0028_i1_u003b_vf2_u003b_vf2_u003b_i1_u003b((&param_59), (&param_60), (&param_61), (&param_62));
        let _e172 = param_60;
        d_2 = _e172;
        let _e173 = param_61;
        start_2 = _e173;
        let _e174 = param_62;
        steps_1 = _e174;
        phi_738_ = !(_e171);
    }
    let _e177 = phi_738_;
    if _e177 {
        return;
    }
    let _e178 = (*seg);
    t0_ = (1i + (_e178 * 32i));
    let _e181 = t0_;
    let _e183 = steps_1;
    t1_ = min((_e181 + 32i), _e183);
    let _e185 = t0_;
    t_1 = _e185;
    loop {
        let _e186 = t_1;
        let _e187 = t1_;
        if (_e186 < _e187) {
            let _e189 = start_2;
            param_63 = _e189;
            let _e190 = d_2;
            param_64 = _e190;
            let _e191 = t_1;
            param_65 = _e191;
            let _e192 = sun_meets_u0028_vf2_u003b_vf2_u003b_i1_u003b_b1_u003b((&param_63), (&param_64), (&param_65), (&param_66));
            let _e193 = param_66;
            disp_3 = _e193;
            if _e192 {
                let _e194 = (*k_7);
                let _e197 = t_1;
                let _e200 = disp_3;
                let _e205 = atomicMax((&unnamed_1.sun_hit[_e194]), (2147483647u - bitcast<u32>(((_e197 << bitcast<u32>(1i)) | select(0i, 1i, _e200)))));
                return;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e206 = t_1;
            t_1 = (_e206 + 1i);
        }
    }
    return;
}

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var g_1: i32;
    var sunN: i32;
    var local_2: i32;
    var i: i32;
    var param_67: i32;
    var param_68: i32;
    var param_69: vec2<i32>;
    var phi_1517_: bool;

    g_afterEvent = false;
    let _e158 = pc.i0_;
    g_n = _e158.xy;
    let _e161 = gl_WorkGroupID_1[0u];
    g_1 = bitcast<i32>(_e161);
    let _e165 = pc.i1_[2u];
    if (_e165 != 0i) {
        let _e169 = pc.i0_[2u];
        local_2 = (((640i * _e169) + 255i) / 256i);
    } else {
        local_2 = 0i;
    }
    let _e173 = local_2;
    sunN = _e173;
    let _e174 = g_1;
    let _e175 = sunN;
    if (_e174 < _e175) {
        let _e177 = g_1;
        let _e179 = gl_LocalInvocationIndex_1;
        i = ((_e177 * 256i) + bitcast<i32>(_e179));
        let _e182 = i;
        let _e190 = i;
        param_67 = (_e182 % 640i + select(0i, 640i, _e182 % 640i != 0i && ((_e182 % 640i < 0i) != (640i < 0i))));
        param_68 = (_e190 / 640i);
        sun_probe_seg_u0028_i1_u003b_i1_u003b((&param_67), (&param_68));
        return;
    }
    let _e192 = sunN;
    let _e193 = g_1;
    g_1 = (_e193 - _e192);
    let _e197 = pc.i1_[3u];
    let _e198 = (_e197 != 0i);
    phi_1517_ = _e198;
    if _e198 {
        let _e199 = g_1;
        let _e202 = pc.i1_[0u];
        let _e205 = pc.i1_[1u];
        phi_1517_ = (_e199 < (_e202 * _e205));
    }
    let _e209 = phi_1517_;
    if _e209 {
        let _e210 = g_1;
        let _e213 = pc.i1_[0u];
        let _e221 = g_1;
        let _e224 = pc.i1_[0u];
        param_69 = vec2<i32>((_e210 % _e213 + select(0i, _e213, _e210 % _e213 != 0i && ((_e210 % _e213 < 0i) != (_e213 < 0i)))), (_e221 / _e224));
        lamp_probe_block_u0028_vi2_u003b((&param_69));
    }
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(local_invocation_index) gl_LocalInvocationIndex: u32, @builtin(workgroup_id) gl_WorkGroupID: vec3<u32>) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1(gl_WorkGroupID);
}
