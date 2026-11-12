struct Ray {
    x: vec2<f32>,
    dir: vec2<f32>,
    L: vec3<f32>,
    range: f32,
    spread: f32,
    travelled: f32,
    events: i32,
    specS: f32,
    chOff: f32,
    last: vec2<i32>,
    medMat: u32,
    medIor: f32,
    alive: bool,
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

struct Beams {
    beam: array<u32>,
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

struct Beams_1 {
    beam: array<atomic<u32>>,
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
@group(0) @binding(4) 
var gaux_img: texture_2d<f32>;
@group(0) @binding(7) 
var<storage, read_write> unnamed_1: Beams_1;
var<private> g_dir0_: vec2<f32>;
@group(0) @binding(10) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(10) 
var medium_tex_smp: sampler;
var<workgroup> sh_ray: array<vec4<f32>, 512>;
var<workgroup> sh_L: array<vec4<f32>, 512>;
var<workgroup> sh_dy: array<f32, 512>;
var<workgroup> wu_alive1_: atomic<u32>;
var<workgroup> wu_alive0_: atomic<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> wu_flags: atomic<u32>;
var<workgroup> sh_tmin: atomic<i32>;
@group(0) @binding(11) 
var<storage, read_write> unnamed_2: SunHits;
@group(0) @binding(8) 
var day_tex: texture_2d<f32>;
@group(2) @binding(8) 
var day_tex_smp: sampler;
var<workgroup> sh_e: array<vec4<f32>, 64>;
var<workgroup> sh_c: array<vec2<f32>, 64>;
var<workgroup> sh_mask: array<u32, 8>;
var<workgroup> sh_E: vec3<f32>;
var<workgroup> sh_cs: vec2<f32>;
var<workgroup> wu_lsum: f32;
@group(0) @binding(12) 
var<storage, read_write> unnamed_3: LampProbe;
var<private> gl_LocalInvocationID_1: vec3<u32>;
@group(0) @binding(5) 
var fluence_tex: texture_2d<f32>;
@group(2) @binding(5) 
var fluence_tex_smp: sampler;
@group(0) @binding(6) 
var ldir_tex: texture_2d<f32>;
@group(2) @binding(6) 
var ldir_tex_smp: sampler;
@group(0) @binding(9) 
var beam_prev: texture_2d<f32>;
@group(2) @binding(9) 
var beam_prev_smp: sampler;

fn deposit_u0028_vf2_u003b_vf3_u003b_vf2_u003b(x: ptr<function, vec2<f32>>, L: ptr<function, vec3<f32>>, dir: ptr<function, vec2<f32>>) {
    var h: vec2<i32>;
    var i: u32;
    var u: vec3<u32>;
    var lum: f32;

    let _e186 = (*x);
    let _e190 = g_n;
    h = clamp(vec2<i32>(floor((_e186 * 0.5f))), vec2<i32>(0i, 0i), ((_e190 / vec2(2i)) - vec2(1i)));
    let _e197 = h[1u];
    let _e199 = g_n[0u];
    let _e203 = h[0u];
    i = (bitcast<u32>(((_e197 * (_e199 / 2i)) + _e203)) * 5u);
    let _e207 = (*L);
    u = vec3<u32>(clamp((_e207 * 256f), vec3(0f), vec3(65535f)));
    let _e214 = u[0u];
    let _e216 = u[1u];
    let _e219 = u[2u];
    if (((_e214 + _e216) + _e219) == 0u) {
        return;
    }
    let _e222 = i;
    let _e226 = u[0u];
    let _e227 = atomicAdd((&unnamed_1.beam[_e222]), _e226);
    let _e228 = i;
    let _e233 = u[1u];
    let _e234 = atomicAdd((&unnamed_1.beam[(_e228 + 1u)]), _e233);
    let _e235 = i;
    let _e240 = u[2u];
    let _e241 = atomicAdd((&unnamed_1.beam[(_e235 + 2u)]), _e240);
    let _e243 = (*L)[0u];
    let _e245 = (*L)[1u];
    let _e248 = (*L)[2u];
    lum = ((((_e243 + _e245) + _e248) / 3f) * 256f);
    let _e252 = i;
    let _e257 = (*dir)[0u];
    let _e258 = lum;
    let _e263 = atomicAdd((&unnamed_1.beam[(_e252 + 3u)]), bitcast<u32>(i32(round((_e257 * _e258)))));
    let _e264 = i;
    let _e269 = (*dir)[1u];
    let _e270 = lum;
    let _e275 = atomicAdd((&unnamed_1.beam[(_e264 + 4u)]), bitcast<u32>(i32(round((_e269 * _e270)))));
    return;
}

fn state_u0028_vi2_u003b(q: ptr<function, vec2<i32>>) -> u32 {
    let _e180 = (*q);
    let _e181 = textureLoad(emissive_img, _e180, 0i);
    return u32((_e181.w + 0.5f));
}

fn blocks_u0028_vi2_u003b(q_1: ptr<function, vec2<i32>>) -> bool {
    var st: u32;
    var param: vec2<i32>;
    var phi_384_: bool;
    var phi_385_: bool;

    let _e182 = (*q_1);
    param = _e182;
    let _e183 = state_u0028_vi2_u003b((&param));
    st = _e183;
    let _e184 = st;
    let _e186 = st;
    let _e188 = ((_e184 == 3u) || (_e186 == 2u));
    phi_385_ = _e188;
    if !(_e188) {
        let _e190 = st;
        let _e191 = (_e190 == 1u);
        phi_384_ = _e191;
        if _e191 {
            let _e192 = (*q_1);
            let _e193 = textureLoad(albedo_img, _e192, 0i);
            phi_384_ = (_e193.w > 0.97f);
        }
        let _e197 = phi_384_;
        phi_385_ = _e197;
    }
    let _e199 = phi_385_;
    return _e199;
}

fn fresnel_u0028_vf3_u003b_f1_u003b(F0_: ptr<function, vec3<f32>>, cosi: ptr<function, f32>) -> vec3<f32> {
    let _e181 = (*F0_);
    let _e182 = (*F0_);
    let _e185 = (*cosi);
    return (_e181 + ((vec3(1f) - _e182) * pow((1f - clamp(_e185, 0f, 1f)), 5f)));
}

fn dispersion_u0028_vi2_u003b_f1_u003b(q_2: ptr<function, vec2<i32>>, ior: ptr<function, f32>) -> f32 {
    var param_1: vec2<i32>;
    var local: f32;

    let _e183 = (*q_2);
    param_1 = _e183;
    let _e184 = state_u0028_vi2_u003b((&param_1));
    if (_e184 == 1u) {
        local = 0f;
    } else {
        let _e186 = (*ior);
        local = ((_e186 - 1f) * 0.06f);
    }
    let _e189 = local;
    return _e189;
}

fn matAt_u0028_vi2_u003b(q_3: ptr<function, vec2<i32>>) -> u32 {
    let _e180 = (*q_3);
    let _e181 = textureLoad(cells, _e180, 0i);
    return (_e181.x & 255u);
}

fn refr_ior_u0028_vi2_u003b(q_4: ptr<function, vec2<i32>>) -> f32 {
    var st_1: u32;
    var param_2: vec2<i32>;
    var ior_1: f32;
    var param_3: vec2<i32>;
    var phi_417_: bool;

    let _e184 = (*q_4);
    param_2 = _e184;
    let _e185 = state_u0028_vi2_u003b((&param_2));
    st_1 = _e185;
    let _e186 = st_1;
    if (_e186 == 0u) {
        return 0f;
    }
    let _e188 = (*q_4);
    let _e189 = textureLoad(albedo_img, _e188, 0i);
    if (_e189.w > 0.97f) {
        return 0f;
    }
    let _e192 = st_1;
    let _e193 = (_e192 == 1u);
    phi_417_ = _e193;
    if _e193 {
        let _e194 = (*q_4);
        let _e195 = textureLoad(cells, _e194, 0i);
        phi_417_ = ((_e195.w & 255u) > 128u);
    }
    let _e200 = phi_417_;
    if _e200 {
        return 0f;
    }
    let _e201 = (*q_4);
    param_3 = _e201;
    let _e202 = matAt_u0028_vi2_u003b((&param_3));
    let _e207 = unnamed.mats[_e202].optics[2u];
    ior_1 = _e207;
    let _e208 = ior_1;
    if (_e208 <= 1.05f) {
        let _e210 = st_1;
        ior_1 = select(0f, 1.33f, (_e210 == 1u));
    }
    let _e213 = ior_1;
    return _e213;
}

fn inw_u0028_vi2_u003b(q_5: ptr<function, vec2<i32>>) -> bool {
    var phi_332_: bool;

    let _e180 = (*q_5);
    let _e182 = all((_e180 >= vec2<i32>(0i, 0i)));
    phi_332_ = _e182;
    if _e182 {
        let _e183 = (*q_5);
        let _e184 = g_n;
        phi_332_ = all((_e183 < _e184));
    }
    let _e188 = phi_332_;
    return _e188;
}

fn thin_wall_u0028_vi2_u003b_vf2_u003b(q_6: ptr<function, vec2<i32>>, n: ptr<function, vec2<f32>>) -> bool {
    var k: i32;
    var c: vec2<i32>;
    var param_4: vec2<i32>;
    var param_5: vec2<i32>;
    var phi_516_: bool;

    k = 1i;
    loop {
        let _e185 = k;
        if (_e185 <= 3i) {
            let _e187 = (*q_6);
            let _e191 = (*n);
            let _e192 = k;
            c = vec2<i32>(floor(((vec2<f32>(_e187) + vec2(0.5f)) - (_e191 * f32(_e192)))));
            let _e198 = c;
            param_4 = _e198;
            let _e199 = inw_u0028_vi2_u003b((&param_4));
            let _e200 = !(_e199);
            phi_516_ = _e200;
            if !(_e200) {
                let _e202 = c;
                param_5 = _e202;
                let _e203 = refr_ior_u0028_vi2_u003b((&param_5));
                phi_516_ = (_e203 <= 0f);
            }
            let _e206 = phi_516_;
            if _e206 {
                return true;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e207 = k;
            k = (_e207 + 1i);
        }
    }
    return false;
}

fn u01_u0028_u1_u003b(x_1: ptr<function, u32>) -> f32 {
    let _e180 = (*x_1);
    return (f32((_e180 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e180 = (*v);
    (*v) = ((_e180 * vec3(1664525u)) + vec3(1013904223u));
    let _e186 = (*v)[1u];
    let _e188 = (*v)[2u];
    let _e191 = (*v)[0u];
    (*v)[0u] = (_e191 + (_e186 * _e188));
    let _e195 = (*v)[2u];
    let _e197 = (*v)[0u];
    let _e200 = (*v)[1u];
    (*v)[1u] = (_e200 + (_e195 * _e197));
    let _e204 = (*v)[0u];
    let _e206 = (*v)[1u];
    let _e209 = (*v)[2u];
    (*v)[2u] = (_e209 + (_e204 * _e206));
    let _e212 = (*v);
    let _e216 = (*v);
    (*v) = (_e216 ^ (_e212 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e219 = (*v)[1u];
    let _e221 = (*v)[2u];
    let _e224 = (*v)[0u];
    (*v)[0u] = (_e224 + (_e219 * _e221));
    let _e228 = (*v)[2u];
    let _e230 = (*v)[0u];
    let _e233 = (*v)[1u];
    (*v)[1u] = (_e233 + (_e228 * _e230));
    let _e237 = (*v)[0u];
    let _e239 = (*v)[1u];
    let _e242 = (*v)[2u];
    (*v)[2u] = (_e242 + (_e237 * _e239));
    let _e245 = (*v);
    return _e245;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param_6: vec3<u32>;

    let _e181 = (*v_1);
    param_6 = _e181;
    let _e182 = pcg3d_u0028_vu3_u003b((&param_6));
    return _e182.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_7: vec3<u32>;
    var param_8: u32;

    let _e182 = (*p);
    let _e184 = vec2<i32>(floor(_e182));
    param_7 = bitcast<vec3<u32>>(vec3<i32>(_e184.x, _e184.y, 1777i));
    let _e189 = hash1_u0028_vu3_u003b((&param_7));
    param_8 = _e189;
    let _e190 = u01_u0028_u1_u003b((&param_8));
    return _e190;
}

fn frost_u0028_vf2_u003b_vi2_u003b_u1_u003b(dir_1: ptr<function, vec2<f32>>, q_7: ptr<function, vec2<i32>>, mat: ptr<function, u32>) -> vec2<f32> {
    var amp: f32;
    var a: f32;
    var param_9: vec2<f32>;
    var c_1: f32;
    var sn: f32;

    let _e187 = (*mat);
    let _e192 = unnamed.mats[_e187].surface[1u];
    amp = (max((_e192 - 0.08f), 0f) * 2.5f);
    let _e196 = amp;
    if (_e196 <= 0f) {
        let _e198 = (*dir_1);
        return _e198;
    }
    let _e199 = (*q_7);
    param_9 = ((vec2<f32>(_e199) * 1.31f) + vec2(7.7f));
    let _e204 = hash21_u0028_vf2_u003b((&param_9));
    let _e207 = amp;
    a = (((_e204 - 0.5f) * 2f) * _e207);
    let _e209 = a;
    c_1 = cos(_e209);
    let _e211 = a;
    sn = sin(_e211);
    let _e213 = c_1;
    let _e215 = (*dir_1)[0u];
    let _e217 = sn;
    let _e219 = (*dir_1)[1u];
    let _e222 = sn;
    let _e224 = (*dir_1)[0u];
    let _e226 = c_1;
    let _e228 = (*dir_1)[1u];
    return vec2<f32>(((_e213 * _e215) - (_e217 * _e219)), ((_e222 * _e224) + (_e226 * _e228)));
}

fn normal_at_u0028_vi2_u003b_vf2_u003b(q_8: ptr<function, vec2<i32>>, fallback: ptr<function, vec2<f32>>) -> vec2<f32> {
    var nrm: vec2<f32>;
    var local_1: vec2<f32>;

    let _e183 = (*q_8);
    let _e184 = textureLoad(gaux_img, _e183, 0i);
    nrm = _e184.xy;
    let _e186 = nrm;
    let _e187 = nrm;
    if (dot(_e186, _e187) > 0.01f) {
        let _e190 = nrm;
        local_1 = normalize(_e190);
    } else {
        let _e192 = (*fallback);
        local_1 = _e192;
    }
    let _e193 = local_1;
    return _e193;
}

fn redirected_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b(r: ptr<function, Ray>) -> bool {
    var phi_759_: bool;

    let _e180 = g_afterEvent;
    let _e181 = !(_e180);
    phi_759_ = _e181;
    if !(_e181) {
        let _e184 = (*r).dir;
        let _e185 = g_dir0_;
        phi_759_ = (dot(_e184, _e185) < 0.995f);
    }
    let _e189 = phi_759_;
    return _e189;
}

fn ray_step_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b_vf3_u003b_b1_u003b_vf3_u003b(r_1: ptr<function, Ray>, airL: ptr<function, vec3<f32>>, inAir: ptr<function, bool>, landL: ptr<function, vec3<f32>>) {
    var md: vec2<f32>;
    var q_9: vec2<i32>;
    var param_10: vec2<i32>;
    var fade: f32;
    var w: f32;
    var spreadFade: f32;
    var param_11: vec2<i32>;
    var a_1: vec4<f32>;
    var param_12: Ray;
    var nOut: vec2<f32>;
    var param_13: vec2<i32>;
    var param_14: vec2<f32>;
    var rr: vec2<f32>;
    var param_15: vec2<f32>;
    var param_16: vec2<i32>;
    var param_17: u32;
    var ior_2: f32;
    var param_18: vec2<i32>;
    var n_1: vec2<f32>;
    var param_19: vec2<i32>;
    var param_20: vec2<f32>;
    var param_21: vec2<i32>;
    var param_22: vec2<i32>;
    var param_23: vec2<f32>;
    var a_2: vec4<f32>;
    var param_24: vec2<i32>;
    var param_25: f32;
    var f0_: f32;
    var param_26: vec3<f32>;
    var param_27: f32;
    var rr_1: vec2<f32>;
    var param_28: vec2<i32>;
    var param_29: vec2<f32>;
    var param_30: vec2<i32>;
    var param_31: u32;
    var param_32: vec2<i32>;
    var param_33: vec2<i32>;
    var m: Material;
    var param_34: vec2<i32>;
    var mirror: f32;
    var glossy: bool;
    var nr: vec2<f32>;
    var param_35: vec2<i32>;
    var param_36: vec2<f32>;
    var n_2: vec2<f32>;
    var local_2: vec2<f32>;
    var local_3: vec2<f32>;
    var F0_1: vec3<f32>;
    var R: vec3<f32>;
    var local_4: vec3<f32>;
    var param_37: vec3<f32>;
    var param_38: f32;
    var param_39: vec2<f32>;
    var param_40: vec3<f32>;
    var param_41: vec2<f32>;
    var param_42: Ray;
    var param_43: Ray;
    var phi_1009_: bool;
    var phi_1199_: bool;
    var phi_1200_: bool;
    var phi_1207_: bool;

    (*airL) = vec3<f32>(0f, 0f, 0f);
    (*landL) = vec3<f32>(0f, 0f, 0f);
    (*inAir) = false;
    let _e241 = (*r_1).dir;
    let _e243 = (*r_1).x;
    (*r_1).x = (_e243 + _e241);
    let _e247 = (*r_1).travelled;
    (*r_1).travelled = (_e247 + 1f);
    let _e251 = (*r_1).x;
    let _e252 = g_n;
    let _e255 = textureSampleLevel(medium_tex, medium_tex_smp, (_e251 / vec2<f32>(_e252)), 0f);
    md = _e255.xy;
    let _e258 = (*r_1).x;
    q_9 = vec2<i32>(floor(_e258));
    let _e261 = q_9;
    param_10 = _e261;
    let _e262 = inw_u0028_vi2_u003b((&param_10));
    if !(_e262) {
        (*r_1).alive = false;
        return;
    }
    let _e266 = (*r_1).travelled;
    let _e269 = (*r_1).range;
    let _e273 = (*r_1).range;
    let _e276 = (*r_1).range;
    let _e279 = (*r_1).travelled;
    fade = (exp((-(_e266) / _e269)) * (1f - smoothstep((_e273 * 1.2f), (_e276 * 2f), _e279)));
    let _e283 = fade;
    if (_e283 < 0.01f) {
        (*r_1).alive = false;
        return;
    }
    let _e287 = (*r_1).spread;
    let _e289 = (*r_1).travelled;
    w = (_e287 * _e289);
    let _e291 = w;
    spreadFade = (1f / (1f + (_e291 * 0.5f)));
    let _e296 = (*r_1).medIor;
    if (_e296 > 0f) {
        let _e298 = q_9;
        param_11 = _e298;
        let _e299 = matAt_u0028_vi2_u003b((&param_11));
        let _e301 = (*r_1).medMat;
        if (_e299 == _e301) {
            let _e303 = q_9;
            let _e304 = textureLoad(albedo_img, _e303, 0i);
            a_1 = _e304;
            let _e305 = a_1;
            let _e312 = a_1[3u];
            let _e318 = (*r_1).L;
            (*r_1).L = (_e318 * mix(vec3<f32>(1f, 1f, 1f), clamp((_e305.xyz * 1.25f), vec3(0f), vec3(1f)), vec3((0.06f + (0.1f * _e312)))));
            let _e321 = (*r_1);
            param_12 = _e321;
            let _e322 = redirected_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b((&param_12));
            if _e322 {
                let _e324 = (*r_1).L;
                let _e325 = fade;
                let _e327 = spreadFade;
                (*airL) = (((_e324 * _e325) * _e327) * 0.3f);
            }
            let _e330 = q_9;
            (*r_1).last = _e330;
            return;
        }
        let _e333 = (*r_1).last;
        param_13 = _e333;
        let _e335 = (*r_1).dir;
        param_14 = _e335;
        let _e336 = normal_at_u0028_vi2_u003b_vf2_u003b((&param_13), (&param_14));
        nOut = _e336;
        let _e337 = nOut;
        let _e339 = (*r_1).dir;
        if (dot(_e337, _e339) < 0f) {
            let _e342 = nOut;
            nOut = -(_e342);
        }
        let _e345 = (*r_1).dir;
        let _e346 = nOut;
        let _e349 = (*r_1).medIor;
        let _e351 = (*r_1).chOff;
        rr = refract(_e345, -(_e346), (_e349 + _e351));
        let _e354 = rr;
        let _e355 = rr;
        if (dot(_e354, _e355) < 0.0001f) {
            let _e359 = (*r_1).events;
            let _e360 = (_e359 + 1i);
            (*r_1).events = _e360;
            if (_e360 > 4i) {
                (*r_1).alive = false;
                return;
            }
            let _e364 = (*r_1).dir;
            let _e365 = nOut;
            (*r_1).dir = reflect(_e364, -(_e365));
            let _e370 = (*r_1).dir;
            let _e372 = nOut;
            let _e376 = (*r_1).x;
            (*r_1).x = (_e376 - ((_e370 * 0.5f) + (_e372 * 0.5f)));
            return;
        }
        let _e379 = rr;
        param_15 = normalize(_e379);
        let _e382 = (*r_1).last;
        param_16 = _e382;
        let _e384 = (*r_1).medMat;
        param_17 = _e384;
        let _e385 = frost_u0028_vf2_u003b_vi2_u003b_u1_u003b((&param_15), (&param_16), (&param_17));
        (*r_1).dir = _e385;
        (*r_1).medIor = 0f;
        (*r_1).medMat = 0u;
        let _e390 = (*r_1).events;
        let _e391 = (_e390 + 1i);
        (*r_1).events = _e391;
        if (_e391 > 4i) {
            (*r_1).alive = false;
            return;
        }
    }
    let _e394 = q_9;
    param_18 = _e394;
    let _e395 = refr_ior_u0028_vi2_u003b((&param_18));
    ior_2 = _e395;
    let _e396 = ior_2;
    if (_e396 > 0f) {
        let _e399 = (*r_1).dir;
        let _e401 = q_9;
        param_19 = _e401;
        param_20 = -(_e399);
        let _e402 = normal_at_u0028_vi2_u003b_vf2_u003b((&param_19), (&param_20));
        n_1 = _e402;
        let _e403 = n_1;
        let _e405 = (*r_1).dir;
        if (dot(_e403, _e405) > 0f) {
            let _e408 = n_1;
            n_1 = -(_e408);
        }
        let _e410 = q_9;
        param_21 = _e410;
        let _e411 = state_u0028_vi2_u003b((&param_21));
        let _e412 = (_e411 == 3u);
        phi_1009_ = _e412;
        if _e412 {
            let _e413 = q_9;
            param_22 = _e413;
            let _e414 = n_1;
            param_23 = _e414;
            let _e415 = thin_wall_u0028_vi2_u003b_vf2_u003b((&param_22), (&param_23));
            phi_1009_ = _e415;
        }
        let _e417 = phi_1009_;
        if _e417 {
            let _e418 = q_9;
            let _e419 = textureLoad(albedo_img, _e418, 0i);
            a_2 = _e419;
            let _e420 = a_2;
            let _e427 = a_2[3u];
            let _e433 = (*r_1).L;
            (*r_1).L = (_e433 * mix(vec3<f32>(1f, 1f, 1f), clamp((_e420.xyz * 1.25f), vec3(0f), vec3(1f)), vec3((0.06f + (0.1f * _e427)))));
            let _e436 = q_9;
            (*r_1).last = _e436;
            return;
        }
        let _e439 = (*r_1).events;
        let _e440 = (_e439 + 1i);
        (*r_1).events = _e440;
        if (_e440 > 4i) {
            (*r_1).alive = false;
            return;
        }
        let _e444 = (*r_1).specS;
        if (_e444 != -99f) {
            let _e447 = (*r_1).specS;
            let _e448 = q_9;
            param_24 = _e448;
            let _e449 = ior_2;
            param_25 = _e449;
            let _e450 = dispersion_u0028_vi2_u003b_f1_u003b((&param_24), (&param_25));
            (*r_1).chOff = (_e447 * _e450);
        }
        let _e453 = ior_2;
        let _e455 = ior_2;
        f0_ = ((_e453 - 1f) / (_e455 + 1f));
        let _e458 = f0_;
        let _e459 = f0_;
        let _e463 = (*r_1).dir;
        let _e465 = n_1;
        param_26 = vec3((_e458 * _e459));
        param_27 = dot(-(_e463), _e465);
        let _e467 = fresnel_u0028_vf3_u003b_f1_u003b((&param_26), (&param_27));
        let _e471 = (*r_1).L;
        (*r_1).L = (_e471 * (1f - _e467.x));
        let _e475 = (*r_1).dir;
        let _e476 = n_1;
        let _e477 = ior_2;
        let _e479 = (*r_1).chOff;
        rr_1 = refract(_e475, _e476, (1f / (_e477 + _e479)));
        let _e483 = rr_1;
        let _e484 = rr_1;
        if (dot(_e483, _e484) > 0.0001f) {
            let _e487 = rr_1;
            let _e489 = q_9;
            param_28 = _e489;
            let _e490 = matAt_u0028_vi2_u003b((&param_28));
            param_29 = normalize(_e487);
            let _e491 = q_9;
            param_30 = _e491;
            param_31 = _e490;
            let _e492 = frost_u0028_vf2_u003b_vi2_u003b_u1_u003b((&param_29), (&param_30), (&param_31));
            (*r_1).dir = _e492;
        }
        let _e494 = ior_2;
        (*r_1).medIor = _e494;
        let _e496 = q_9;
        param_32 = _e496;
        let _e497 = matAt_u0028_vi2_u003b((&param_32));
        (*r_1).medMat = _e497;
        let _e499 = q_9;
        (*r_1).last = _e499;
        return;
    }
    let _e501 = q_9;
    param_33 = _e501;
    let _e502 = blocks_u0028_vi2_u003b((&param_33));
    if _e502 {
        let _e503 = q_9;
        param_34 = _e503;
        let _e504 = matAt_u0028_vi2_u003b((&param_34));
        let _e507 = unnamed.mats[_e504];
        m.color_a = _e507.color_a;
        m.color_b = _e507.color_b;
        m.emission = _e507.emission;
        m.phys = _e507.phys;
        m.thermo = _e507.thermo;
        m.burn = _e507.burn;
        m.optics = _e507.optics;
        m.scatter = _e507.scatter;
        m.ids = _e507.ids;
        m.ids2_ = _e507.ids2_;
        m.misc = _e507.misc;
        m.surface = _e507.surface;
        m.sss = _e507.sss;
        m.sss_color = _e507.sss_color;
        m.optics2_ = _e507.optics2_;
        m.pal0_ = _e507.pal0_;
        m.pal1_ = _e507.pal1_;
        m.pal2_ = _e507.pal2_;
        m.pal3_ = _e507.pal3_;
        m.accent = _e507.accent;
        m.flame = _e507.flame;
        let _e552 = m.optics2_[1u];
        mirror = _e552;
        let _e553 = mirror;
        let _e554 = (_e553 >= 0.3f);
        phi_1200_ = _e554;
        if !(_e554) {
            let _e558 = m.surface[2u];
            let _e559 = (_e558 > 0.5f);
            phi_1199_ = _e559;
            if _e559 {
                let _e562 = m.surface[1u];
                phi_1199_ = (_e562 < 0.3f);
            }
            let _e565 = phi_1199_;
            phi_1200_ = _e565;
        }
        let _e567 = phi_1200_;
        glossy = _e567;
        let _e568 = glossy;
        phi_1207_ = _e568;
        if _e568 {
            let _e570 = (*r_1).events;
            phi_1207_ = (_e570 < 4i);
        }
        let _e573 = phi_1207_;
        if _e573 {
            let _e575 = (*r_1).dir;
            let _e577 = q_9;
            param_35 = _e577;
            param_36 = -(_e575);
            let _e578 = normal_at_u0028_vi2_u003b_vf2_u003b((&param_35), (&param_36));
            nr = _e578;
            let _e579 = mirror;
            if (_e579 >= 0.5f) {
                let _e582 = nr[0u];
                let _e585 = nr[1u];
                if (abs(_e582) > abs(_e585)) {
                    let _e589 = nr[0u];
                    local_3 = vec2<f32>(sign(_e589), 0f);
                } else {
                    let _e593 = nr[1u];
                    local_3 = vec2<f32>(0f, sign(_e593));
                }
                let _e596 = local_3;
                local_2 = _e596;
            } else {
                let _e597 = nr;
                local_2 = _e597;
            }
            let _e598 = local_2;
            n_2 = _e598;
            let _e599 = n_2;
            let _e601 = (*r_1).dir;
            if (dot(_e599, _e601) > 0f) {
                let _e604 = n_2;
                n_2 = -(_e604);
            }
            let _e606 = q_9;
            let _e607 = textureLoad(albedo_img, _e606, 0i);
            let _e611 = m.surface[2u];
            F0_1 = mix(vec3<f32>(0.04f, 0.04f, 0.04f), _e607.xyz, vec3(_e611));
            let _e614 = mirror;
            if (_e614 >= 0.3f) {
                let _e616 = mirror;
                let _e618 = F0_1;
                local_4 = (vec3(_e616) * mix(vec3<f32>(1f, 1f, 1f), _e618, vec3(0.2f)));
            } else {
                let _e623 = (*r_1).dir;
                let _e625 = n_2;
                let _e627 = F0_1;
                param_37 = _e627;
                param_38 = dot(-(_e623), _e625);
                let _e628 = fresnel_u0028_vf3_u003b_f1_u003b((&param_37), (&param_38));
                let _e631 = m.surface[1u];
                local_4 = (_e628 * (1f - _e631));
            }
            let _e634 = local_4;
            R = _e634;
            let _e635 = q_9;
            let _e640 = (*r_1).L;
            let _e641 = fade;
            let _e643 = R;
            param_39 = (vec2<f32>(_e635) + vec2(0.5f));
            param_40 = (((_e640 * _e641) * (vec3(1f) - _e643)) * 0.6f);
            let _e649 = (*r_1).dir;
            param_41 = _e649;
            deposit_u0028_vf2_u003b_vf3_u003b_vf2_u003b((&param_39), (&param_40), (&param_41));
            let _e650 = R;
            let _e652 = (*r_1).L;
            (*r_1).L = (_e652 * _e650);
            let _e656 = (*r_1).dir;
            let _e657 = n_2;
            (*r_1).dir = reflect(_e656, _e657);
            let _e660 = n_2;
            let _e663 = (*r_1).x;
            (*r_1).x = (_e663 + (_e660 * 0.6f));
            let _e667 = (*r_1).events;
            (*r_1).events = (_e667 + 1i);
            let _e671 = (*r_1).L[0u];
            let _e674 = (*r_1).L[1u];
            let _e677 = (*r_1).L[2u];
            if (max(_e671, max(_e674, _e677)) < 0.02f) {
                (*r_1).alive = false;
            }
            return;
        }
        let _e682 = (*r_1);
        param_42 = _e682;
        let _e683 = redirected_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b((&param_42));
        if _e683 {
            let _e685 = (*r_1).L;
            let _e687 = fade;
            let _e689 = spreadFade;
            (*landL) = (((_e685 * 0.6f) * _e687) * _e689);
        }
        (*r_1).alive = false;
        return;
    }
    let _e692 = q_9;
    (*r_1).last = _e692;
    let _e695 = md[0u];
    let _e698 = md[1u];
    let _e704 = (*r_1).L;
    (*r_1).L = (_e704 * exp(-(((_e695 * 0.35f) + (_e698 * 0.12f)))));
    let _e707 = (*r_1);
    param_43 = _e707;
    let _e708 = redirected_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b((&param_43));
    if !(_e708) {
        let _e711 = (*r_1).travelled;
        if (_e711 > 56f) {
            (*r_1).alive = false;
        }
        return;
    }
    let _e715 = (*r_1).L;
    let _e716 = fade;
    let _e718 = spreadFade;
    (*airL) = ((_e715 * _e716) * _e718);
    (*inAir) = true;
    return;
}

fn ray_init_u0028_vf2_u003b_vf2_u003b_vf3_u003b_f1_u003b_f1_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b(x_2: ptr<function, vec2<f32>>, dir_2: ptr<function, vec2<f32>>, L_1: ptr<function, vec3<f32>>, range: ptr<function, f32>, spread: ptr<function, f32>, medMat: ptr<function, u32>, medIor: ptr<function, f32>, specS: ptr<function, f32>, disp: ptr<function, f32>) -> Ray {
    var r_2: Ray;
    var local_5: f32;

    let _e190 = (*x_2);
    r_2.x = _e190;
    let _e192 = (*dir_2);
    r_2.dir = _e192;
    let _e194 = (*L_1);
    r_2.L = _e194;
    let _e196 = (*range);
    r_2.range = _e196;
    let _e198 = (*spread);
    r_2.spread = _e198;
    r_2.travelled = 0f;
    r_2.events = 0i;
    let _e202 = (*specS);
    r_2.specS = _e202;
    let _e204 = (*specS);
    if (_e204 == -99f) {
        local_5 = 0f;
    } else {
        let _e206 = (*specS);
        let _e207 = (*disp);
        local_5 = (_e206 * _e207);
    }
    let _e209 = local_5;
    r_2.chOff = _e209;
    let _e211 = (*x_2);
    r_2.last = vec2<i32>(floor(_e211));
    let _e215 = (*medMat);
    r_2.medMat = _e215;
    let _e217 = (*medIor);
    r_2.medIor = _e217;
    r_2.alive = true;
    let _e220 = r_2;
    return _e220;
}

fn trace_u0028_vf2_u003b_vf2_u003b_vf3_u003b_f1_u003b_f1_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b(x_3: ptr<function, vec2<f32>>, dir_3: ptr<function, vec2<f32>>, L_2: ptr<function, vec3<f32>>, range_1: ptr<function, f32>, spread_1: ptr<function, f32>, medMat_1: ptr<function, u32>, medIor_1: ptr<function, f32>, specS_1: ptr<function, f32>, disp_1: ptr<function, f32>) {
    var r_3: Ray;
    var param_44: vec2<f32>;
    var param_45: vec2<f32>;
    var param_46: vec3<f32>;
    var param_47: f32;
    var param_48: f32;
    var param_49: u32;
    var param_50: f32;
    var param_51: f32;
    var param_52: f32;
    var t: i32;
    var airL_1: vec3<f32>;
    var inAir_1: bool;
    var landL_1: vec3<f32>;
    var param_53: Ray;
    var param_54: vec3<f32>;
    var param_55: bool;
    var param_56: vec3<f32>;
    var param_57: vec2<f32>;
    var param_58: vec3<f32>;
    var param_59: vec2<f32>;
    var w_1: f32;
    var side: vec2<f32>;
    var k_1: i32;
    var param_60: vec2<f32>;
    var param_61: vec3<f32>;
    var param_62: vec2<f32>;
    var param_63: vec2<f32>;
    var param_64: vec3<f32>;
    var param_65: vec2<f32>;
    var phi_1471_: bool;

    let _e218 = (*x_3);
    param_44 = _e218;
    let _e219 = (*dir_3);
    param_45 = _e219;
    let _e220 = (*L_2);
    param_46 = _e220;
    let _e221 = (*range_1);
    param_47 = _e221;
    let _e222 = (*spread_1);
    param_48 = _e222;
    let _e223 = (*medMat_1);
    param_49 = _e223;
    let _e224 = (*medIor_1);
    param_50 = _e224;
    let _e225 = (*specS_1);
    param_51 = _e225;
    let _e226 = (*disp_1);
    param_52 = _e226;
    let _e227 = ray_init_u0028_vf2_u003b_vf2_u003b_vf3_u003b_f1_u003b_f1_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b((&param_44), (&param_45), (&param_46), (&param_47), (&param_48), (&param_49), (&param_50), (&param_51), (&param_52));
    r_3 = _e227;
    t = 0i;
    loop {
        let _e228 = t;
        let _e231 = r_3.alive;
        if ((_e228 < 320i) && _e231) {
            let _e233 = r_3;
            param_53 = _e233;
            ray_step_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b_vf3_u003b_b1_u003b_vf3_u003b((&param_53), (&param_54), (&param_55), (&param_56));
            let _e234 = param_53;
            r_3 = _e234;
            let _e235 = param_54;
            airL_1 = _e235;
            let _e236 = param_55;
            inAir_1 = _e236;
            let _e237 = param_56;
            landL_1 = _e237;
            let _e238 = landL_1;
            if any((_e238 != vec3<f32>(0f, 0f, 0f))) {
                let _e242 = r_3.x;
                param_57 = (floor(_e242) + vec2(0.5f));
                let _e246 = landL_1;
                param_58 = _e246;
                let _e248 = r_3.dir;
                param_59 = _e248;
                deposit_u0028_vf2_u003b_vf3_u003b_vf2_u003b((&param_57), (&param_58), (&param_59));
            }
            let _e249 = airL_1;
            let _e251 = all((_e249 == vec3<f32>(0f, 0f, 0f)));
            phi_1471_ = _e251;
            if !(_e251) {
                let _e253 = t;
                phi_1471_ = ((_e253 & 1i) != 0i);
            }
            let _e257 = phi_1471_;
            if _e257 {
                continue;
            }
            let _e259 = r_3.spread;
            let _e261 = r_3.travelled;
            w_1 = (_e259 * _e261);
            let _e263 = inAir_1;
            let _e264 = w_1;
            if (_e263 && (_e264 > 1f)) {
                let _e269 = r_3.dir[1u];
                let _e273 = r_3.dir[0u];
                side = vec2<f32>(-(_e269), _e273);
                k_1 = -1i;
                loop {
                    let _e275 = k_1;
                    if (_e275 <= 1i) {
                        let _e278 = r_3.x;
                        let _e279 = side;
                        let _e280 = k_1;
                        let _e283 = w_1;
                        let _e287 = airL_1;
                        param_60 = (_e278 + (((_e279 * f32(_e280)) * _e283) * 0.5f));
                        param_61 = (_e287 / vec3(3f));
                        let _e291 = r_3.dir;
                        param_62 = _e291;
                        deposit_u0028_vf2_u003b_vf3_u003b_vf2_u003b((&param_60), (&param_61), (&param_62));
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e292 = k_1;
                        k_1 = (_e292 + 1i);
                    }
                }
            } else {
                let _e295 = r_3.x;
                param_63 = _e295;
                let _e296 = airL_1;
                param_64 = _e296;
                let _e298 = r_3.dir;
                param_65 = _e298;
                deposit_u0028_vf2_u003b_vf3_u003b_vf2_u003b((&param_63), (&param_64), (&param_65));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e299 = t;
            t = (_e299 + 1i);
        }
    }
    return;
}

fn mirror_cell_u0028_vi2_u003b(p_1: ptr<function, vec2<i32>>) {
    var st_2: u32;
    var param_66: vec2<i32>;
    var m_1: Material;
    var param_67: vec2<i32>;
    var mirror_1: f32;
    var spec: f32;
    var rough: f32;
    var metal: f32;
    var nrm_1: vec2<f32>;
    var ownE: vec3<f32>;
    var sn_1: vec2<f32>;
    var local_6: vec2<f32>;
    var local_7: vec2<f32>;
    var pos: vec2<f32>;
    var outside: vec2<f32>;
    var dayDir: vec2<f32>;
    var Lsun: vec3<f32>;
    var sunW: f32;
    var sunlit: bool;
    var baseRange: f32;
    var ior_3: f32;
    var param_68: vec2<i32>;
    var local_8: bool;
    var Lin: vec3<f32>;
    var inDir: vec2<f32>;
    var cosi_1: f32;
    var alb: vec3<f32>;
    var iorR: f32;
    var local_9: f32;
    var f0d: f32;
    var F: vec3<f32>;
    var param_69: vec3<f32>;
    var param_70: f32;
    var R_1: vec3<f32>;
    var local_10: vec3<f32>;
    var L_3: vec3<f32>;
    var Lmax: f32;
    var range_2: f32;
    var local_11: f32;
    var local_12: f32;
    var param_71: vec2<f32>;
    var param_72: vec2<f32>;
    var param_73: vec3<f32>;
    var param_74: f32;
    var param_75: f32;
    var param_76: u32;
    var param_77: f32;
    var param_78: f32;
    var param_79: f32;
    var phi_3187_: bool;
    var phi_3201_: bool;

    let _e229 = (*p_1);
    let _e230 = g_n;
    if any((_e229 >= _e230)) {
        return;
    }
    let _e233 = (*p_1);
    param_66 = _e233;
    let _e234 = state_u0028_vi2_u003b((&param_66));
    st_2 = _e234;
    let _e235 = st_2;
    if (_e235 == 0u) {
        return;
    }
    let _e237 = (*p_1);
    param_67 = _e237;
    let _e238 = matAt_u0028_vi2_u003b((&param_67));
    let _e241 = unnamed.mats[_e238];
    m_1.color_a = _e241.color_a;
    m_1.color_b = _e241.color_b;
    m_1.emission = _e241.emission;
    m_1.phys = _e241.phys;
    m_1.thermo = _e241.thermo;
    m_1.burn = _e241.burn;
    m_1.optics = _e241.optics;
    m_1.scatter = _e241.scatter;
    m_1.ids = _e241.ids;
    m_1.ids2_ = _e241.ids2_;
    m_1.misc = _e241.misc;
    m_1.surface = _e241.surface;
    m_1.sss = _e241.sss;
    m_1.sss_color = _e241.sss_color;
    m_1.optics2_ = _e241.optics2_;
    m_1.pal0_ = _e241.pal0_;
    m_1.pal1_ = _e241.pal1_;
    m_1.pal2_ = _e241.pal2_;
    m_1.pal3_ = _e241.pal3_;
    m_1.accent = _e241.accent;
    m_1.flame = _e241.flame;
    let _e286 = m_1.optics2_[1u];
    mirror_1 = _e286;
    let _e289 = m_1.surface[0u];
    spec = _e289;
    let _e292 = m_1.surface[1u];
    rough = clamp(_e292, 0f, 1f);
    let _e296 = m_1.surface[2u];
    metal = _e296;
    let _e297 = (*p_1);
    let _e298 = textureLoad(gaux_img, _e297, 0i);
    nrm_1 = _e298.xy;
    let _e300 = nrm_1;
    let _e301 = nrm_1;
    if (dot(_e300, _e301) < 0.01f) {
        return;
    }
    let _e304 = (*p_1);
    let _e305 = textureLoad(emissive_img, _e304, 0i);
    ownE = _e305.xyz;
    let _e308 = ownE[0u];
    let _e310 = ownE[1u];
    let _e312 = ownE[2u];
    if (max(_e308, max(_e310, _e312)) > 0.05f) {
        return;
    }
    let _e316 = mirror_1;
    if (_e316 >= 0.5f) {
        let _e319 = nrm_1[0u];
        let _e322 = nrm_1[1u];
        if (abs(_e319) > abs(_e322)) {
            let _e326 = nrm_1[0u];
            local_7 = vec2<f32>(sign(_e326), 0f);
        } else {
            let _e330 = nrm_1[1u];
            local_7 = vec2<f32>(0f, sign(_e330));
        }
        let _e333 = local_7;
        local_6 = _e333;
    } else {
        let _e334 = nrm_1;
        local_6 = normalize(_e334);
    }
    let _e336 = local_6;
    sn_1 = _e336;
    let _e337 = (*p_1);
    pos = (vec2<f32>(_e337) + vec2(0.5f));
    let _e341 = pos;
    let _e342 = sn_1;
    outside = (_e341 + (_e342 * 1.5f));
    let _e346 = pc.f1_;
    dayDir = _e346.xy;
    let _e348 = outside;
    let _e349 = g_n;
    let _e352 = textureSampleLevel(day_tex, day_tex_smp, (_e348 / vec2<f32>(_e349)), 0f);
    Lsun = (_e352.xyz * 1.6f);
    let _e355 = dayDir;
    let _e357 = sn_1;
    let _e361 = Lsun[0u];
    let _e363 = Lsun[1u];
    let _e365 = Lsun[2u];
    sunW = (smoothstep(0f, 0.15f, dot(-(_e355), _e357)) * smoothstep(0.12f, 0.35f, max(_e361, max(_e363, _e365))));
    let _e370 = sunW;
    sunlit = (_e370 > 0.001f);
    let _e372 = sunW;
    let _e373 = Lsun;
    Lsun = (_e373 * _e372);
    let _e377 = pc.f0_[1u];
    baseRange = max(_e377, 1f);
    let _e379 = (*p_1);
    param_68 = _e379;
    let _e380 = refr_ior_u0028_vi2_u003b((&param_68));
    ior_3 = _e380;
    let _e381 = mirror_1;
    let _e382 = (_e381 < 0.3f);
    phi_3187_ = _e382;
    if _e382 {
        let _e383 = rough;
        let _e385 = spec;
        phi_3187_ = ((_e383 > 0.4f) || (_e385 < 0.25f));
    }
    let _e389 = phi_3187_;
    if _e389 {
        return;
    }
    let _e390 = mirror_1;
    let _e391 = (_e390 >= 0.3f);
    phi_3201_ = _e391;
    if !(_e391) {
        let _e393 = metal;
        let _e395 = rough;
        phi_3201_ = ((_e393 > 0.5f) && (_e395 < 0.3f));
    }
    let _e399 = phi_3201_;
    if _e399 {
        return;
    }
    let _e400 = mirror_1;
    if (_e400 >= 0.3f) {
        let _e403 = (*p_1)[0u];
        let _e405 = (*p_1)[1u];
        local_8 = (((_e403 + _e405) & 1i) != 0i);
    } else {
        let _e410 = (*p_1)[0u];
        let _e412 = (*p_1)[1u];
        local_8 = (((_e410 | _e412) & 1i) != 0i);
    }
    let _e416 = local_8;
    if _e416 {
        return;
    }
    let _e417 = sunlit;
    if _e417 {
        let _e418 = Lsun;
        Lin = _e418;
        let _e419 = dayDir;
        inDir = _e419;
    } else {
        return;
    }
    let _e420 = inDir;
    let _e422 = sn_1;
    cosi_1 = clamp(dot(-(_e420), _e422), 0f, 1f);
    let _e425 = (*p_1);
    let _e426 = textureLoad(albedo_img, _e425, 0i);
    alb = _e426.xyz;
    let _e430 = m_1.optics[2u];
    if (_e430 > 1f) {
        let _e434 = m_1.optics[2u];
        local_9 = _e434;
    } else {
        local_9 = 1.5f;
    }
    let _e435 = local_9;
    iorR = _e435;
    let _e436 = iorR;
    let _e438 = iorR;
    f0d = ((_e436 - 1f) / (_e438 + 1f));
    let _e441 = f0d;
    let _e442 = f0d;
    let _e445 = alb;
    let _e446 = metal;
    param_69 = mix(vec3((_e441 * _e442)), _e445, vec3(_e446));
    let _e449 = cosi_1;
    param_70 = _e449;
    let _e450 = fresnel_u0028_vf3_u003b_f1_u003b((&param_69), (&param_70));
    F = _e450;
    let _e451 = mirror_1;
    if (_e451 >= 0.3f) {
        let _e453 = F;
        let _e454 = mirror_1;
        let _e456 = alb;
        let _e460 = mirror_1;
        local_10 = mix(_e453, (vec3(_e454) * mix(vec3<f32>(1f, 1f, 1f), _e456, vec3(0.2f))), vec3(_e460));
    } else {
        let _e463 = F;
        let _e464 = spec;
        let _e466 = rough;
        let _e469 = rough;
        local_10 = (((_e463 * _e464) * (1f - _e466)) * (1f - _e469));
    }
    let _e472 = local_10;
    R_1 = _e472;
    let _e474 = R_1[0u];
    let _e476 = R_1[1u];
    let _e478 = R_1[2u];
    if (max(_e474, max(_e476, _e478)) < 0.08f) {
        return;
    }
    let _e482 = Lin;
    let _e483 = R_1;
    let _e487 = pc.f0_[0u];
    let _e490 = mirror_1;
    L_3 = ((((_e482 * _e483) * _e487) * 2f) * select(2f, 2.5f, (_e490 >= 0.3f)));
    let _e495 = L_3[0u];
    let _e497 = L_3[1u];
    let _e499 = L_3[2u];
    Lmax = max(_e495, max(_e497, _e499));
    let _e502 = Lmax;
    if (_e502 < 0.04f) {
        return;
    }
    let _e504 = baseRange;
    let _e505 = mirror_1;
    if (_e505 >= 0.3f) {
        local_11 = 1f;
    } else {
        let _e507 = rough;
        let _e509 = rough;
        local_11 = ((1f - _e507) * (1f - _e509));
    }
    let _e512 = local_11;
    range_2 = max((_e504 * _e512), 1f);
    let _e515 = range_2;
    let _e516 = baseRange;
    let _e517 = Lmax;
    range_2 = min(_e515, (((_e516 * log((_e517 / 0.01f))) * 0.5f) + 1f));
    let _e524 = pos;
    let _e525 = sn_1;
    let _e528 = inDir;
    let _e529 = sn_1;
    let _e531 = mirror_1;
    if (_e531 >= 0.5f) {
        local_12 = 0f;
    } else {
        let _e533 = rough;
        local_12 = (_e533 * 0.6f);
    }
    param_71 = (_e524 + (_e525 * 0.6f));
    param_72 = reflect(_e528, _e529);
    let _e535 = L_3;
    param_73 = _e535;
    let _e536 = range_2;
    param_74 = _e536;
    let _e537 = local_12;
    param_75 = _e537;
    param_76 = 0u;
    param_77 = 0f;
    param_78 = -99f;
    param_79 = 0f;
    trace_u0028_vf2_u003b_vf2_u003b_vf3_u003b_f1_u003b_f1_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b((&param_71), (&param_72), (&param_73), (&param_74), (&param_75), (&param_76), (&param_77), (&param_78), (&param_79));
    return;
}

fn deposit_seg_u0028_vf2_u003b_vf2_u003b_vf3_u003b_vf2_u003b(a_3: ptr<function, vec2<f32>>, b: ptr<function, vec2<f32>>, L_4: ptr<function, vec3<f32>>, dir_4: ptr<function, vec2<f32>>) {
    var n_3: i32;
    var k_2: i32;
    var param_80: vec2<f32>;
    var param_81: vec3<f32>;
    var param_82: vec2<f32>;

    let _e188 = (*b);
    let _e189 = (*a_3);
    n_3 = clamp((i32(ceil((length((_e188 - _e189)) * 0.5f))) + 1i), 1i, 8i);
    k_2 = 0i;
    loop {
        let _e197 = k_2;
        let _e198 = n_3;
        if (_e197 < _e198) {
            let _e200 = (*a_3);
            let _e201 = (*b);
            let _e202 = k_2;
            let _e205 = n_3;
            let _e210 = (*L_4);
            let _e211 = n_3;
            param_80 = mix(_e200, _e201, vec2(((f32(_e202) + 0.5f) / f32(_e205))));
            param_81 = (_e210 / vec3(f32(_e211)));
            let _e215 = (*dir_4);
            param_82 = _e215;
            deposit_u0028_vf2_u003b_vf3_u003b_vf2_u003b((&param_80), (&param_81), (&param_82));
            continue;
        } else {
            break;
        }
        continuing {
            let _e216 = k_2;
            k_2 = (_e216 + 1i);
        }
    }
    return;
}

fn wavefront_u0028_u1_u003b_u1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b(li: ptr<function, u32>, b_1: ptr<function, u32>, x_4: ptr<function, vec2<f32>>, ev: ptr<function, i32>, L_5: ptr<function, vec3<f32>>, dir_5: ptr<function, vec2<f32>>) {
    var jr: u32;
    var jl: u32;
    var R_2: vec4<f32>;
    var Lf: vec4<f32>;
    var right: bool;
    var left: bool;
    var param_83: vec2<f32>;
    var param_84: vec2<f32>;
    var param_85: vec3<f32>;
    var param_86: vec2<f32>;
    var param_87: vec2<f32>;
    var param_88: vec3<f32>;
    var param_89: vec2<f32>;
    var phi_1615_: bool;
    var phi_1624_: bool;
    var phi_1636_: bool;
    var phi_1644_: bool;

    let _e198 = (*b_1);
    let _e199 = (*li);
    jr = (_e198 + ((_e199 + 1u) % 64u));
    let _e203 = (*b_1);
    let _e204 = (*li);
    jl = (_e203 + (((_e204 + 64u) - 1u) % 64u));
    let _e209 = jr;
    let _e211 = sh_ray[_e209];
    R_2 = _e211;
    let _e212 = jl;
    let _e214 = sh_ray[_e212];
    Lf = _e214;
    let _e216 = R_2[3u];
    let _e217 = (_e216 > 0f);
    phi_1615_ = _e217;
    if _e217 {
        let _e219 = R_2[2u];
        let _e221 = (*ev);
        phi_1615_ = (i32(_e219) == _e221);
    }
    let _e224 = phi_1615_;
    phi_1624_ = _e224;
    if _e224 {
        let _e225 = R_2;
        let _e227 = (*x_4);
        phi_1624_ = (distance(_e225.xy, _e227) < 8f);
    }
    let _e231 = phi_1624_;
    right = _e231;
    let _e233 = Lf[3u];
    let _e234 = (_e233 > 0f);
    phi_1636_ = _e234;
    if _e234 {
        let _e236 = Lf[2u];
        let _e238 = (*ev);
        phi_1636_ = (i32(_e236) == _e238);
    }
    let _e241 = phi_1636_;
    phi_1644_ = _e241;
    if _e241 {
        let _e242 = Lf;
        let _e244 = (*x_4);
        phi_1644_ = (distance(_e242.xy, _e244) < 8f);
    }
    let _e248 = phi_1644_;
    left = _e248;
    let _e249 = right;
    if _e249 {
        let _e250 = (*L_5);
        let _e251 = jr;
        let _e253 = sh_L[_e251];
        let _e257 = (*x_4);
        param_83 = _e257;
        let _e258 = R_2;
        param_84 = _e258.xy;
        param_85 = ((_e250 + _e253.xyz) * 0.5f);
        let _e260 = (*dir_5);
        param_86 = _e260;
        deposit_seg_u0028_vf2_u003b_vf2_u003b_vf3_u003b_vf2_u003b((&param_83), (&param_84), (&param_85), (&param_86));
    } else {
        let _e261 = left;
        if !(_e261) {
            let _e263 = (*x_4);
            param_87 = _e263;
            let _e264 = (*L_5);
            param_88 = _e264;
            let _e265 = (*dir_5);
            param_89 = _e265;
            deposit_u0028_vf2_u003b_vf3_u003b_vf2_u003b((&param_87), (&param_88), (&param_89));
        }
    }
    return;
}

fn wf_join_u0028_u1_u003b_i1_u003b(li_1: ptr<function, u32>, n_4: ptr<function, i32>) {
    var j: i32;
    var b_2: u32;
    var me: vec4<f32>;
    var l: vec4<f32>;
    var param_90: u32;
    var param_91: u32;
    var param_92: vec2<f32>;
    var param_93: i32;
    var param_94: vec3<f32>;
    var param_95: vec2<f32>;

    j = 0i;
    loop {
        let _e191 = j;
        let _e192 = (*n_4);
        if (_e191 < _e192) {
            let _e194 = j;
            b_2 = (bitcast<u32>(_e194) * 64u);
            let _e197 = b_2;
            let _e198 = (*li_1);
            let _e201 = sh_ray[(_e197 + _e198)];
            me = _e201;
            let _e203 = me[3u];
            if (_e203 > 0f) {
                let _e205 = b_2;
                let _e206 = (*li_1);
                let _e209 = sh_L[(_e205 + _e206)];
                l = _e209;
                let _e211 = me[2u];
                let _e214 = l[3u];
                let _e215 = b_2;
                let _e216 = (*li_1);
                let _e219 = sh_dy[(_e215 + _e216)];
                let _e221 = (*li_1);
                param_90 = _e221;
                let _e222 = b_2;
                param_91 = _e222;
                let _e223 = me;
                param_92 = _e223.xy;
                param_93 = i32(_e211);
                let _e225 = l;
                param_94 = _e225.xyz;
                param_95 = vec2<f32>(_e214, _e219);
                wavefront_u0028_u1_u003b_u1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b((&param_90), (&param_91), (&param_92), (&param_93), (&param_94), (&param_95));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e227 = j;
            j = (_e227 + 1i);
        }
    }
    return;
}

fn wf_finish_u0028_u1_u003b_i1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b(li_2: ptr<function, u32>, n_5: ptr<function, i32>, landX: ptr<function, vec2<f32>>, landEv: ptr<function, i32>, landL_2: ptr<function, vec3<f32>>, dir_6: ptr<function, vec2<f32>>) {
    var param_96: u32;
    var param_97: i32;
    var param_98: u32;
    var param_99: u32;
    var param_100: vec2<f32>;
    var param_101: i32;
    var param_102: vec3<f32>;
    var param_103: vec2<f32>;

    let _e193 = (*n_5);
    if (_e193 > 0i) {
        workgroupBarrier();
        let _e195 = (*li_2);
        param_96 = _e195;
        let _e196 = (*n_5);
        param_97 = _e196;
        wf_join_u0028_u1_u003b_i1_u003b((&param_96), (&param_97));
    }
    workgroupBarrier();
    let _e197 = (*li_2);
    let _e198 = (*landX);
    let _e199 = (*landEv);
    let _e201 = (*landEv);
    sh_ray[_e197] = vec4<f32>(_e198.x, _e198.y, f32(_e199), select(0f, 1f, (_e201 >= 0i)));
    let _e208 = (*li_2);
    let _e209 = (*landL_2);
    sh_L[_e208] = vec4<f32>(_e209.x, _e209.y, _e209.z, 0f);
    workgroupBarrier();
    let _e215 = (*landEv);
    if (_e215 >= 0i) {
        let _e217 = (*li_2);
        param_98 = _e217;
        param_99 = 0u;
        let _e218 = (*landX);
        param_100 = _e218;
        let _e219 = (*landEv);
        param_101 = _e219;
        let _e220 = (*landL_2);
        param_102 = _e220;
        let _e221 = (*dir_6);
        param_103 = _e221;
        wavefront_u0028_u1_u003b_u1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b((&param_98), (&param_99), (&param_100), (&param_101), (&param_102), (&param_103));
    }
    return;
}

fn wf_flush_u0028_u1_u003b_i1_u003b_b1_u003b(li_3: ptr<function, u32>, t_1: ptr<function, i32>, alive: ptr<function, bool>) -> bool {
    var odd: bool;
    var param_104: u32;
    var param_105: i32;
    var live: u32;

    let _e186 = (*t_1);
    odd = (((_e186 >> bitcast<u32>(4i)) & 1i) != 0i);
    let _e191 = (*alive);
    if _e191 {
        let _e192 = odd;
        if _e192 {
            let _e193 = atomicOr((&wu_alive1_), 1u);
        } else {
            let _e194 = atomicOr((&wu_alive0_), 1u);
        }
    }
    let _e195 = (*li_3);
    if (_e195 == 0u) {
        let _e197 = odd;
        if _e197 {
            atomicStore((&wu_alive0_), 0u);
        } else {
            atomicStore((&wu_alive1_), 0u);
        }
    }
    workgroupBarrier();
    let _e198 = (*li_3);
    param_104 = _e198;
    param_105 = 8i;
    wf_join_u0028_u1_u003b_i1_u003b((&param_104), (&param_105));
    let _e199 = odd;
    if _e199 {
        let _e200 = workgroupUniformLoad((&wu_alive1_));
        live = _e200;
    } else {
        let _e201 = workgroupUniformLoad((&wu_alive0_));
        live = _e201;
    }
    workgroupBarrier();
    let _e202 = live;
    return (_e202 == 0u);
}

fn wf_record_u0028_u1_u003b_i1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b(li_4: ptr<function, u32>, t_2: ptr<function, i32>, x_5: ptr<function, vec2<f32>>, ev_1: ptr<function, i32>, L_6: ptr<function, vec3<f32>>, dir_7: ptr<function, vec2<f32>>) {
    var slot: u32;

    let _e186 = (*t_2);
    let _e192 = (*li_4);
    slot = ((bitcast<u32>(((_e186 >> bitcast<u32>(1i)) & 7i)) * 64u) + _e192);
    let _e194 = slot;
    let _e195 = (*x_5);
    let _e196 = (*ev_1);
    let _e198 = (*L_6);
    sh_ray[_e194] = vec4<f32>(_e195.x, _e195.y, f32(_e196), select(0f, 1f, any((_e198 != vec3<f32>(0f, 0f, 0f)))));
    let _e206 = slot;
    let _e207 = (*L_6);
    let _e209 = (*dir_7)[0u];
    sh_L[_e206] = vec4<f32>(_e207.x, _e207.y, _e207.z, _e209);
    let _e215 = slot;
    let _e217 = (*dir_7)[1u];
    sh_dy[_e215] = _e217;
    return;
}

fn thin_glass_u0028_vf2_u003b_vf2_u003b(x_6: ptr<function, vec2<f32>>, dir_8: ptr<function, vec2<f32>>) -> i32 {
    var k_3: i32;
    var q_10: vec2<i32>;
    var param_106: vec2<i32>;
    var param_107: vec2<i32>;
    var param_108: vec2<i32>;
    var phi_2347_: bool;
    var phi_2355_: bool;

    k_3 = 0i;
    loop {
        let _e186 = k_3;
        if (_e186 < 4i) {
            let _e188 = (*x_6);
            let _e189 = (*dir_8);
            let _e190 = k_3;
            q_10 = vec2<i32>(floor((_e188 + (_e189 * f32(_e190)))));
            let _e196 = q_10;
            param_106 = _e196;
            let _e197 = inw_u0028_vi2_u003b((&param_106));
            let _e198 = !(_e197);
            phi_2347_ = _e198;
            if !(_e198) {
                let _e200 = q_10;
                param_107 = _e200;
                let _e201 = refr_ior_u0028_vi2_u003b((&param_107));
                phi_2347_ = (_e201 <= 0f);
            }
            let _e204 = phi_2347_;
            phi_2355_ = _e204;
            if !(_e204) {
                let _e206 = q_10;
                param_108 = _e206;
                let _e207 = state_u0028_vi2_u003b((&param_108));
                phi_2355_ = (_e207 == 1u);
            }
            let _e210 = phi_2355_;
            if _e210 {
                let _e211 = k_3;
                return _e211;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e212 = k_3;
            k_3 = (_e212 + 1i);
        }
    }
    return 99i;
}

fn lamp_start_u0028_vf2_u003b_vf2_u003b_u1_u003b_vf2_u003b(c_2: ptr<function, vec2<f32>>, dir_9: ptr<function, vec2<f32>>, startMat: ptr<function, u32>, x0_: ptr<function, vec2<f32>>) -> bool {
    var lastIn: i32;
    var k_4: i32;
    var q_11: vec2<i32>;
    var param_109: vec2<i32>;
    var eq: vec3<f32>;
    var param_110: vec2<i32>;
    var th: i32;
    var param_111: vec2<f32>;
    var param_112: vec2<f32>;
    var param_113: vec2<i32>;
    var phi_2415_: bool;
    var phi_2455_: bool;

    lastIn = 0i;
    k_4 = 0i;
    loop {
        let _e193 = k_4;
        if (_e193 < 48i) {
            let _e195 = (*c_2);
            let _e196 = (*dir_9);
            let _e197 = k_4;
            q_11 = vec2<i32>(floor((_e195 + (_e196 * f32(_e197)))));
            let _e203 = q_11;
            param_109 = _e203;
            let _e204 = inw_u0028_vi2_u003b((&param_109));
            if !(_e204) {
                break;
            }
            let _e206 = q_11;
            let _e207 = textureLoad(emissive_img, _e206, 0i);
            eq = _e207.xyz;
            let _e210 = eq[0u];
            let _e212 = eq[1u];
            let _e215 = eq[2u];
            let _e218 = ((((_e210 + _e212) + _e215) / 3f) >= 0.05f);
            phi_2415_ = _e218;
            if !(_e218) {
                let _e220 = q_11;
                param_110 = _e220;
                let _e221 = matAt_u0028_vi2_u003b((&param_110));
                let _e222 = (*startMat);
                phi_2415_ = (_e221 == _e222);
            }
            let _e225 = phi_2415_;
            if _e225 {
                let _e226 = k_4;
                lastIn = _e226;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e227 = k_4;
            k_4 = (_e227 + 1i);
        }
    }
    let _e229 = (*c_2);
    let _e230 = (*dir_9);
    let _e231 = lastIn;
    (*x0_) = (_e229 + (_e230 * f32((_e231 + 1i))));
    let _e236 = (*x0_);
    param_111 = _e236;
    let _e237 = (*dir_9);
    param_112 = _e237;
    let _e238 = thin_glass_u0028_vf2_u003b_vf2_u003b((&param_111), (&param_112));
    th = _e238;
    let _e239 = th;
    if (_e239 < 4i) {
        let _e241 = (*dir_9);
        let _e242 = th;
        let _e245 = (*x0_);
        (*x0_) = (_e245 + (_e241 * f32(_e242)));
    }
    let _e247 = lastIn;
    let _e248 = (_e247 < 40i);
    phi_2455_ = _e248;
    if _e248 {
        let _e249 = (*x0_);
        param_113 = vec2<i32>(floor(_e249));
        let _e252 = refr_ior_u0028_vi2_u003b((&param_113));
        phi_2455_ = (_e252 <= 0f);
    }
    let _e255 = phi_2455_;
    return _e255;
}

fn lamp_jitter_u0028_vi2_u003b(tile: ptr<function, vec2<i32>>) -> f32 {
    var param_114: vec2<f32>;

    let _e181 = (*tile);
    param_114 = ((vec2<f32>(_e181) * 1.7f) + vec2(3f));
    let _e186 = hash21_u0028_vf2_u003b((&param_114));
    return ((_e186 * 6.2831855f) / 64f);
}

fn lamp_gather_u0028_vi2_u003b_u1_u003b_vf3_u003b_vf2_u003b_f1_u003b(tile_1: ptr<function, vec2<i32>>, li_5: ptr<function, u32>, E: ptr<function, vec3<f32>>, c_3: ptr<function, vec2<f32>>, lsum: ptr<function, f32>) {
    var p_2: vec2<i32>;
    var e: vec3<f32>;
    var cs: vec2<f32>;
    var le: f32;
    var k_5: i32;
    var q_12: vec2<i32>;
    var param_115: vec2<i32>;
    var eq_1: vec3<f32>;
    var lq: f32;
    var e_1: vec3<f32>;
    var cs_1: vec2<f32>;
    var ls: f32;
    var k_6: i32;

    let _e197 = (*li_5);
    if (_e197 < 64u) {
        let _e199 = (*tile_1);
        let _e202 = (*li_5);
        let _e205 = (*li_5);
        p_2 = ((_e199 * vec2(8i)) + vec2<i32>(bitcast<i32>((_e202 & 7u)), bitcast<i32>((_e205 >> bitcast<u32>(3u)))));
        e = vec3<f32>(0f, 0f, 0f);
        cs = vec2<f32>(0f, 0f);
        le = 0f;
        k_5 = 0i;
        loop {
            let _e211 = k_5;
            if (_e211 < 4i) {
                let _e213 = p_2;
                let _e216 = k_5;
                let _e218 = k_5;
                q_12 = ((_e213 * vec2(2i)) + vec2<i32>((_e216 & 1i), (_e218 >> bitcast<u32>(1i))));
                let _e223 = q_12;
                param_115 = _e223;
                let _e224 = inw_u0028_vi2_u003b((&param_115));
                if !(_e224) {
                    continue;
                }
                let _e226 = q_12;
                let _e227 = textureLoad(emissive_img, _e226, 0i);
                eq_1 = _e227.xyz;
                let _e230 = eq_1[0u];
                let _e232 = eq_1[1u];
                let _e235 = eq_1[2u];
                lq = (((_e230 + _e232) + _e235) / 3f);
                let _e238 = lq;
                if (_e238 < 0.05f) {
                    continue;
                }
                let _e240 = eq_1;
                let _e241 = e;
                e = (_e241 + _e240);
                let _e243 = lq;
                let _e244 = le;
                le = (_e244 + _e243);
                let _e246 = q_12;
                let _e250 = lq;
                let _e252 = cs;
                cs = (_e252 + ((vec2<f32>(_e246) + vec2(0.5f)) * _e250));
                continue;
            } else {
                break;
            }
            continuing {
                let _e254 = k_5;
                k_5 = (_e254 + 1i);
            }
        }
        let _e256 = (*li_5);
        let _e257 = e;
        let _e258 = le;
        sh_e[_e256] = vec4<f32>(_e257.x, _e257.y, _e257.z, _e258);
        let _e264 = (*li_5);
        let _e265 = cs;
        sh_c[_e264] = _e265;
    }
    let _e267 = (*li_5);
    if (_e267 == 0u) {
        atomicStore((&wu_flags), 0u);
        atomicStore((&wu_alive0_), 0u);
        atomicStore((&wu_alive1_), 0u);
    }
    let _e269 = (*li_5);
    if (_e269 < 8u) {
        let _e271 = (*li_5);
        sh_mask[_e271] = 0u;
    }
    workgroupBarrier();
    let _e273 = (*li_5);
    if (_e273 == 0u) {
        e_1 = vec3<f32>(0f, 0f, 0f);
        cs_1 = vec2<f32>(0f, 0f);
        ls = 0f;
        k_6 = 0i;
        loop {
            let _e275 = k_6;
            if (_e275 < 64i) {
                let _e277 = k_6;
                let _e279 = sh_e[_e277];
                let _e281 = e_1;
                e_1 = (_e281 + _e279.xyz);
                let _e283 = k_6;
                let _e286 = sh_e[_e283][3u];
                let _e287 = ls;
                ls = (_e287 + _e286);
                let _e289 = k_6;
                let _e291 = sh_c[_e289];
                let _e292 = cs_1;
                cs_1 = (_e292 + _e291);
                continue;
            } else {
                break;
            }
            continuing {
                let _e294 = k_6;
                k_6 = (_e294 + 1i);
            }
        }
        let _e296 = e_1;
        sh_E = _e296;
        let _e297 = cs_1;
        sh_cs = _e297;
        let _e298 = ls;
        wu_lsum = _e298;
    }
    workgroupBarrier();
    let _e299 = sh_E;
    (*E) = _e299;
    let _e300 = sh_cs;
    (*c_3) = _e300;
    let _e301 = workgroupUniformLoad((&wu_lsum));
    (*lsum) = _e301;
    return;
}

fn lamp_rays_u0028_vi3_u003b(grp: ptr<function, vec3<i32>>) {
    var li_6: u32;
    var tile_2: vec2<i32>;
    var pre: u32;
    var E_1: vec3<f32>;
    var c_4: vec2<f32>;
    var lsum_1: f32;
    var param_116: vec2<i32>;
    var param_117: u32;
    var param_118: vec3<f32>;
    var param_119: vec2<f32>;
    var param_120: f32;
    var jitter: f32;
    var param_121: vec2<i32>;
    var range_3: f32;
    var startMat_1: u32;
    var param_122: vec2<i32>;
    var probe: vec4<u32>;
    var flags: u32;
    var gapStart: i32;
    var gapLen: i32;
    var a0_: f32;
    var span: f32;
    var ang: f32;
    var dir_10: vec2<f32>;
    var mine: bool;
    var x0_1: vec2<f32>;
    var param_123: vec2<f32>;
    var param_124: vec2<f32>;
    var param_125: u32;
    var param_126: vec2<f32>;
    var share: f32;
    var passes: i32;
    var pass_: i32;
    var E0_: vec3<f32>;
    var L0_: vec3<f32>;
    var local_13: vec3<f32>;
    var indexable: array<vec4<f32>, 8>;
    var r_4: Ray;
    var local_14: f32;
    var indexable_1: array<vec4<f32>, 8>;
    var param_127: vec2<f32>;
    var param_128: vec2<f32>;
    var param_129: vec3<f32>;
    var param_130: f32;
    var param_131: f32;
    var param_132: u32;
    var param_133: f32;
    var param_134: f32;
    var param_135: f32;
    var landL_3: vec3<f32>;
    var landX_1: vec2<f32>;
    var landEv_1: i32;
    var pend: i32;
    var t_3: i32;
    var airL_2: vec3<f32>;
    var lL: vec3<f32>;
    var inAir_2: bool;
    var param_136: Ray;
    var param_137: vec3<f32>;
    var param_138: bool;
    var param_139: vec3<f32>;
    var param_140: u32;
    var param_141: i32;
    var param_142: vec2<f32>;
    var param_143: i32;
    var param_144: vec3<f32>;
    var param_145: vec2<f32>;
    var param_146: u32;
    var param_147: i32;
    var param_148: bool;
    var param_149: u32;
    var param_150: i32;
    var param_151: vec2<f32>;
    var param_152: i32;
    var param_153: vec3<f32>;
    var param_154: vec2<f32>;
    var phi_2667_: bool;
    var phi_2668_: bool;
    var phi_2695_: bool;
    var phi_2883_: bool;

    let _e256 = gl_LocalInvocationIndex_1;
    li_6 = _e256;
    let _e257 = (*grp);
    tile_2 = _e257.xy;
    let _e259 = li_6;
    if (_e259 == 0u) {
        let _e262 = tile_2[1u];
        let _e265 = pc.i1_[0u];
        let _e268 = tile_2[0u];
        let _e273 = unnamed_3.lamp_probe_out[((_e262 * _e265) + _e268)][0u];
        atomicStore((&wu_flags), _e273);
    }
    workgroupBarrier();
    let _e274 = workgroupUniformLoad((&wu_flags));
    pre = _e274;
    let _e275 = pre;
    let _e277 = ((_e275 & 1u) == 0u);
    phi_2668_ = _e277;
    if !(_e277) {
        let _e280 = (*grp)[2u];
        let _e281 = (_e280 > 0i);
        phi_2667_ = _e281;
        if _e281 {
            let _e282 = pre;
            phi_2667_ = ((_e282 & 2u) == 0u);
        }
        let _e286 = phi_2667_;
        phi_2668_ = _e286;
    }
    let _e288 = phi_2668_;
    if _e288 {
        return;
    }
    workgroupBarrier();
    let _e289 = tile_2;
    param_116 = _e289;
    let _e290 = li_6;
    param_117 = _e290;
    lamp_gather_u0028_vi2_u003b_u1_u003b_vf3_u003b_vf2_u003b_f1_u003b((&param_116), (&param_117), (&param_118), (&param_119), (&param_120));
    let _e291 = param_118;
    E_1 = _e291;
    let _e292 = param_119;
    c_4 = _e292;
    let _e293 = param_120;
    lsum_1 = _e293;
    let _e294 = workgroupUniformLoad((&wu_lsum));
    let _e295 = (_e294 < 4f);
    phi_2695_ = _e295;
    if !(_e295) {
        let _e299 = pc.f1_[2u];
        phi_2695_ = (_e299 <= 0f);
    }
    let _e302 = phi_2695_;
    if _e302 {
        return;
    }
    let _e303 = lsum_1;
    let _e304 = c_4;
    c_4 = (_e304 / vec2(_e303));
    let _e307 = tile_2;
    param_121 = _e307;
    let _e308 = lamp_jitter_u0028_vi2_u003b((&param_121));
    jitter = _e308;
    g_afterEvent = true;
    let _e311 = pc.f0_[1u];
    range_3 = max(_e311, 1f);
    let _e313 = c_4;
    let _e316 = g_n;
    param_122 = clamp(vec2<i32>(floor(_e313)), vec2<i32>(0i, 0i), (_e316 - vec2(1i)));
    let _e320 = matAt_u0028_vi2_u003b((&param_122));
    startMat_1 = _e320;
    let _e322 = tile_2[1u];
    let _e325 = pc.i1_[0u];
    let _e328 = tile_2[0u];
    let _e332 = unnamed_3.lamp_probe_out[((_e322 * _e325) + _e328)];
    probe = _e332;
    let _e333 = li_6;
    if (_e333 == 0u) {
        let _e336 = probe[0u];
        atomicStore((&wu_flags), _e336);
    }
    workgroupBarrier();
    let _e337 = workgroupUniformLoad((&wu_flags));
    flags = _e337;
    let _e338 = flags;
    if ((_e338 & 1u) == 0u) {
        return;
    }
    let _e342 = probe[1u];
    gapStart = bitcast<i32>(_e342);
    let _e345 = probe[2u];
    gapLen = bitcast<i32>(_e345);
    let _e347 = gapStart;
    let _e348 = gapLen;
    a0_ = (f32((_e347 + _e348)) - 1f);
    let _e352 = gapLen;
    span = (f32((256i - _e352)) + 2f);
    let _e356 = span;
    span = min(_e356, 256f);
    let _e358 = a0_;
    let _e359 = li_6;
    let _e363 = span;
    let _e369 = jitter;
    ang = (((((_e358 + (((f32(_e359) + 0.5f) / 64f) * _e363)) + 0.5f) / 256f) * 6.2831855f) + _e369);
    let _e371 = ang;
    let _e373 = ang;
    dir_10 = vec2<f32>(cos(_e371), sin(_e373));
    let _e376 = c_4;
    param_123 = _e376;
    let _e377 = dir_10;
    param_124 = _e377;
    let _e378 = startMat_1;
    param_125 = _e378;
    let _e379 = lamp_start_u0028_vf2_u003b_vf2_u003b_u1_u003b_vf2_u003b((&param_123), (&param_124), (&param_125), (&param_126));
    let _e380 = param_126;
    x0_1 = _e380;
    mine = _e379;
    let _e381 = dir_10;
    g_dir0_ = _e381;
    let _e382 = span;
    share = (_e382 / 256f);
    let _e384 = flags;
    passes = select(1i, 8i, ((_e384 & 2u) != 0u));
    let _e389 = (*grp)[2u];
    pass_ = _e389;
    let _e390 = pass_;
    let _e391 = passes;
    if (_e390 >= _e391) {
        return;
    }
    let _e393 = E_1;
    let _e394 = share;
    let _e400 = pc.f1_[2u];
    E0_ = ((((_e393 * _e394) / vec3(64f)) * _e400) * 2.2f);
    let _e403 = passes;
    if (_e403 == 1i) {
        let _e405 = E0_;
        local_13 = _e405;
    } else {
        let _e406 = E0_;
        let _e407 = pass_;
        indexable = array<vec4<f32>, 8>(vec4<f32>(0.024f, 0f, 0.266f, 1.468f), vec4<f32>(0.022f, 0.0036f, 0.5882f, 0.918f), vec4<f32>(0f, 0.1629f, 0.1455f, 0.488f), vec4<f32>(0f, 0.4539f, 0.0004f, 0.145f), vec4<f32>(0.2057f, 0.3374f, 0f, -0.131f), vec4<f32>(0.495f, 0.0419f, 0f, -0.358f), vec4<f32>(0.2289f, 0f, 0f, -0.547f), vec4<f32>(0.0245f, 0.0004f, 0f, -0.705f));
        let _e409 = indexable[_e407];
        local_13 = (_e406 * _e409.xyz);
    }
    let _e412 = local_13;
    L0_ = _e412;
    let _e413 = passes;
    if (_e413 == 1i) {
        local_14 = -99f;
    } else {
        let _e415 = pass_;
        indexable_1 = array<vec4<f32>, 8>(vec4<f32>(0.024f, 0f, 0.266f, 1.468f), vec4<f32>(0.022f, 0.0036f, 0.5882f, 0.918f), vec4<f32>(0f, 0.1629f, 0.1455f, 0.488f), vec4<f32>(0f, 0.4539f, 0.0004f, 0.145f), vec4<f32>(0.2057f, 0.3374f, 0f, -0.131f), vec4<f32>(0.495f, 0.0419f, 0f, -0.358f), vec4<f32>(0.2289f, 0f, 0f, -0.547f), vec4<f32>(0.0245f, 0.0004f, 0f, -0.705f));
        let _e418 = indexable_1[_e415][3u];
        local_14 = _e418;
    }
    let _e419 = x0_1;
    param_127 = _e419;
    let _e420 = dir_10;
    param_128 = _e420;
    let _e421 = L0_;
    param_129 = _e421;
    let _e422 = range_3;
    param_130 = _e422;
    param_131 = 0f;
    param_132 = 0u;
    param_133 = 0f;
    let _e423 = local_14;
    param_134 = _e423;
    param_135 = 0f;
    let _e424 = ray_init_u0028_vf2_u003b_vf2_u003b_vf3_u003b_f1_u003b_f1_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b((&param_127), (&param_128), (&param_129), (&param_130), (&param_131), (&param_132), (&param_133), (&param_134), (&param_135));
    r_4 = _e424;
    let _e425 = mine;
    phi_2883_ = _e425;
    if _e425 {
        let _e427 = L0_[0u];
        let _e429 = L0_[1u];
        let _e431 = L0_[2u];
        phi_2883_ = (max(_e427, max(_e429, _e431)) > 0.002f);
    }
    let _e436 = phi_2883_;
    r_4.alive = _e436;
    landL_3 = vec3<f32>(0f, 0f, 0f);
    landX_1 = vec2<f32>(0f, 0f);
    landEv_1 = -1i;
    pend = 0i;
    t_3 = 0i;
    loop {
        let _e438 = t_3;
        if (_e438 < 220i) {
            airL_2 = vec3<f32>(0f, 0f, 0f);
            lL = vec3<f32>(0f, 0f, 0f);
            let _e441 = r_4.alive;
            if _e441 {
                let _e442 = r_4;
                param_136 = _e442;
                ray_step_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b_vf3_u003b_b1_u003b_vf3_u003b((&param_136), (&param_137), (&param_138), (&param_139));
                let _e443 = param_136;
                r_4 = _e443;
                let _e444 = param_137;
                airL_2 = _e444;
                let _e445 = param_138;
                inAir_2 = _e445;
                let _e446 = param_139;
                lL = _e446;
                let _e447 = lL;
                if any((_e447 != vec3<f32>(0f, 0f, 0f))) {
                    let _e450 = lL;
                    landL_3 = _e450;
                    let _e452 = r_4.x;
                    landX_1 = (floor(_e452) + vec2(0.5f));
                    let _e457 = r_4.events;
                    landEv_1 = _e457;
                }
            }
            let _e458 = t_3;
            if ((_e458 & 1i) == 0i) {
                let _e461 = li_6;
                param_140 = _e461;
                let _e462 = t_3;
                param_141 = _e462;
                let _e464 = r_4.x;
                param_142 = _e464;
                let _e466 = r_4.events;
                param_143 = _e466;
                let _e467 = airL_2;
                param_144 = _e467;
                let _e469 = r_4.dir;
                param_145 = _e469;
                wf_record_u0028_u1_u003b_i1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b((&param_140), (&param_141), (&param_142), (&param_143), (&param_144), (&param_145));
                let _e470 = pend;
                pend = (_e470 + 1i);
                let _e472 = t_3;
                if ((_e472 & 15i) == 14i) {
                    pend = 0i;
                    let _e475 = li_6;
                    param_146 = _e475;
                    let _e476 = t_3;
                    param_147 = _e476;
                    let _e478 = r_4.alive;
                    param_148 = _e478;
                    let _e479 = wf_flush_u0028_u1_u003b_i1_u003b_b1_u003b((&param_146), (&param_147), (&param_148));
                    if _e479 {
                        break;
                    }
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e480 = t_3;
            t_3 = (_e480 + 1i);
        }
    }
    let _e482 = li_6;
    param_149 = _e482;
    let _e483 = pend;
    param_150 = _e483;
    let _e484 = landX_1;
    param_151 = _e484;
    let _e485 = landEv_1;
    param_152 = _e485;
    let _e486 = landL_3;
    param_153 = _e486;
    let _e487 = dir_10;
    param_154 = _e487;
    wf_finish_u0028_u1_u003b_i1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b((&param_149), (&param_150), (&param_151), (&param_152), (&param_153), (&param_154));
    return;
}

fn sun_ray_u0028_i1_u003b_vf2_u003b_vf2_u003b_i1_u003b(k_7: ptr<function, i32>, d: ptr<function, vec2<f32>>, start: ptr<function, vec2<f32>>, steps: ptr<function, i32>) -> bool {
    var nrm_2: vec2<f32>;
    var wc: vec2<f32>;
    var R_3: f32;
    var off: f32;
    var phi_1875_: bool;

    let _e188 = pc.f1_;
    (*d) = _e188.xy;
    (*start) = vec2<f32>(0f, 0f);
    (*steps) = 0i;
    let _e190 = (*d);
    let _e191 = (*d);
    let _e193 = (dot(_e190, _e191) < 0.000001f);
    phi_1875_ = _e193;
    if !(_e193) {
        let _e197 = pc.f0_[0u];
        phi_1875_ = (_e197 <= 0f);
    }
    let _e200 = phi_1875_;
    if _e200 {
        return false;
    }
    let _e201 = (*d);
    (*d) = normalize(_e201);
    let _e204 = (*d)[1u];
    let _e207 = (*d)[0u];
    nrm_2 = vec2<f32>(-(_e204), _e207);
    let _e209 = g_n;
    wc = (vec2<f32>(_e209) * 0.5f);
    let _e212 = wc;
    R_3 = (length(_e212) + 2f);
    let _e215 = (*k_7);
    off = ((f32(_e215) - 320f) + 0.5f);
    let _e219 = wc;
    let _e220 = (*d);
    let _e221 = R_3;
    let _e224 = nrm_2;
    let _e225 = off;
    (*start) = ((_e219 - (_e220 * _e221)) + (_e224 * _e225));
    let _e228 = R_3;
    (*steps) = i32((2f * _e228));
    return true;
}

fn sun_waves_u0028_i1_u003b_i1_u003b(group: ptr<function, i32>, pass_1: ptr<function, i32>) {
    var li_7: u32;
    var k_8: i32;
    var d_1: vec2<f32>;
    var start_1: vec2<f32>;
    var steps_1: i32;
    var param_155: i32;
    var param_156: vec2<f32>;
    var param_157: vec2<f32>;
    var param_158: i32;
    var wc_1: vec2<f32>;
    var R_4: f32;
    var myHit: bool;
    var myT: i32;
    var h_1: u32;
    var e_2: u32;
    var t0_: i32;
    var flags_1: u32;
    var passes_1: i32;
    var range_4: f32;
    var w_2: vec3<f32>;
    var local_15: vec3<f32>;
    var indexable_2: array<vec4<f32>, 8>;
    var r_5: Ray;
    var local_16: f32;
    var indexable_3: array<vec4<f32>, 8>;
    var param_159: vec2<f32>;
    var param_160: vec2<f32>;
    var param_161: vec3<f32>;
    var param_162: f32;
    var param_163: f32;
    var param_164: u32;
    var param_165: f32;
    var param_166: f32;
    var param_167: f32;
    var pending: bool;
    var landL_4: vec3<f32>;
    var landX_2: vec2<f32>;
    var landEv_2: i32;
    var maxT: i32;
    var pend_1: i32;
    var t_4: i32;
    var airL_3: vec3<f32>;
    var lL_1: vec3<f32>;
    var n_6: i32;
    var q_13: vec2<i32>;
    var Ld: vec3<f32>;
    var param_168: vec2<i32>;
    var inAir_3: bool;
    var param_169: Ray;
    var param_170: vec3<f32>;
    var param_171: bool;
    var param_172: vec3<f32>;
    var param_173: u32;
    var param_174: i32;
    var param_175: vec2<f32>;
    var param_176: i32;
    var param_177: vec3<f32>;
    var param_178: vec2<f32>;
    var param_179: u32;
    var param_180: i32;
    var param_181: bool;
    var param_182: u32;
    var param_183: i32;
    var param_184: vec2<f32>;
    var param_185: i32;
    var param_186: vec3<f32>;
    var param_187: vec2<f32>;
    var phi_1941_: bool;

    let _e248 = gl_LocalInvocationIndex_1;
    li_7 = _e248;
    let _e249 = (*group);
    let _e251 = li_7;
    k_8 = ((_e249 * 64i) + bitcast<i32>(_e251));
    let _e255 = pc.f1_;
    let _e258 = pc.f1_;
    let _e261 = (dot(_e255.xy, _e258.xy) < 0.000001f);
    phi_1941_ = _e261;
    if !(_e261) {
        let _e265 = pc.f0_[0u];
        phi_1941_ = (_e265 <= 0f);
    }
    let _e268 = phi_1941_;
    if _e268 {
        return;
    }
    let _e269 = k_8;
    param_155 = _e269;
    let _e270 = sun_ray_u0028_i1_u003b_vf2_u003b_vf2_u003b_i1_u003b((&param_155), (&param_156), (&param_157), (&param_158));
    let _e271 = param_156;
    d_1 = _e271;
    let _e272 = param_157;
    start_1 = _e272;
    let _e273 = param_158;
    steps_1 = _e273;
    let _e274 = g_n;
    wc_1 = (vec2<f32>(_e274) * 0.5f);
    let _e277 = wc_1;
    R_4 = (length(_e277) + 2f);
    let _e280 = li_7;
    if (_e280 == 0u) {
        atomicStore((&wu_flags), 0u);
        atomicStore((&wu_alive0_), 0u);
        atomicStore((&wu_alive1_), 0u);
        atomicStore((&sh_tmin), 2147483647i);
    }
    workgroupBarrier();
    myHit = false;
    myT = 0i;
    let _e282 = k_8;
    let _e285 = unnamed_2.sun_hit[_e282];
    h_1 = _e285;
    let _e286 = h_1;
    if (_e286 != 0u) {
        let _e288 = h_1;
        e_2 = (2147483647u - _e288);
        myHit = true;
        let _e290 = e_2;
        myT = bitcast<i32>((_e290 >> bitcast<u32>(1i)));
        let _e294 = e_2;
        let _e298 = atomicOr((&wu_flags), select(1u, 3u, ((_e294 & 1u) != 0u)));
        let _e299 = myT;
        let _e300 = atomicMin((&sh_tmin), _e299);
    }
    workgroupBarrier();
    let _e301 = atomicLoad((&sh_tmin));
    t0_ = max((_e301 - 2i), 0i);
    let _e304 = workgroupUniformLoad((&wu_flags));
    flags_1 = _e304;
    let _e305 = flags_1;
    if ((_e305 & 1u) == 0u) {
        return;
    }
    let _e308 = flags_1;
    passes_1 = select(1i, 8i, ((_e308 & 2u) != 0u));
    let _e312 = (*pass_1);
    let _e313 = passes_1;
    if (_e312 >= _e313) {
        return;
    }
    let _e317 = pc.f0_[1u];
    range_4 = max(_e317, 1f);
    let _e319 = passes_1;
    if (_e319 == 1i) {
        local_15 = vec3<f32>(1f, 1f, 1f);
    } else {
        let _e321 = (*pass_1);
        indexable_2 = array<vec4<f32>, 8>(vec4<f32>(0.024f, 0f, 0.266f, 1.468f), vec4<f32>(0.022f, 0.0036f, 0.5882f, 0.918f), vec4<f32>(0f, 0.1629f, 0.1455f, 0.488f), vec4<f32>(0f, 0.4539f, 0.0004f, 0.145f), vec4<f32>(0.2057f, 0.3374f, 0f, -0.131f), vec4<f32>(0.495f, 0.0419f, 0f, -0.358f), vec4<f32>(0.2289f, 0f, 0f, -0.547f), vec4<f32>(0.0245f, 0.0004f, 0f, -0.705f));
        let _e323 = indexable_2[_e321];
        local_15 = _e323.xyz;
    }
    let _e325 = local_15;
    w_2 = _e325;
    let _e326 = start_1;
    let _e327 = d_1;
    let _e328 = t0_;
    let _e332 = passes_1;
    if (_e332 == 1i) {
        local_16 = -99f;
    } else {
        let _e334 = (*pass_1);
        indexable_3 = array<vec4<f32>, 8>(vec4<f32>(0.024f, 0f, 0.266f, 1.468f), vec4<f32>(0.022f, 0.0036f, 0.5882f, 0.918f), vec4<f32>(0f, 0.1629f, 0.1455f, 0.488f), vec4<f32>(0f, 0.4539f, 0.0004f, 0.145f), vec4<f32>(0.2057f, 0.3374f, 0f, -0.131f), vec4<f32>(0.495f, 0.0419f, 0f, -0.358f), vec4<f32>(0.2289f, 0f, 0f, -0.547f), vec4<f32>(0.0245f, 0.0004f, 0f, -0.705f));
        let _e337 = indexable_3[_e334][3u];
        local_16 = _e337;
    }
    param_159 = (_e326 + (_e327 * f32(_e328)));
    let _e338 = d_1;
    param_160 = _e338;
    param_161 = vec3<f32>(0f, 0f, 0f);
    let _e339 = range_4;
    param_162 = _e339;
    param_163 = 0f;
    param_164 = 0u;
    param_165 = 0f;
    let _e340 = local_16;
    param_166 = _e340;
    param_167 = 0f;
    let _e341 = ray_init_u0028_vf2_u003b_vf2_u003b_vf3_u003b_f1_u003b_f1_u003b_u1_u003b_f1_u003b_f1_u003b_f1_u003b((&param_159), (&param_160), (&param_161), (&param_162), (&param_163), (&param_164), (&param_165), (&param_166), (&param_167));
    r_5 = _e341;
    let _e342 = myHit;
    r_5.alive = _e342;
    pending = true;
    landL_4 = vec3<f32>(0f, 0f, 0f);
    landX_2 = vec2<f32>(0f, 0f);
    landEv_2 = -1i;
    let _e345 = pc.i0_;
    maxT = (i32((2f * (length((vec2<f32>(_e345.xy) * 0.5f)) + 2f))) + 240i);
    pend_1 = 0i;
    t_4 = 0i;
    loop {
        let _e354 = t_4;
        let _e355 = maxT;
        if (_e354 < _e355) {
            airL_3 = vec3<f32>(0f, 0f, 0f);
            lL_1 = vec3<f32>(0f, 0f, 0f);
            let _e357 = pending;
            let _e359 = r_5.alive;
            if (_e357 && _e359) {
                let _e361 = t0_;
                let _e362 = t_4;
                n_6 = ((_e361 + _e362) + 1i);
                let _e365 = n_6;
                let _e366 = myT;
                if (_e365 == _e366) {
                    let _e368 = start_1;
                    let _e369 = d_1;
                    let _e370 = n_6;
                    q_13 = vec2<i32>(floor((_e368 + (_e369 * f32(_e370)))));
                    let _e376 = start_1;
                    let _e377 = d_1;
                    let _e378 = n_6;
                    r_5.x = (_e376 + (_e377 * f32((_e378 - 1i))));
                    let _e385 = r_5.x;
                    let _e386 = g_n;
                    let _e389 = textureSampleLevel(day_tex, day_tex_smp, (_e385 / vec2<f32>(_e386)), 0f);
                    Ld = (_e389.xyz * 1.6f);
                    let _e392 = q_13;
                    param_168 = _e392;
                    let _e393 = state_u0028_vi2_u003b((&param_168));
                    if (_e393 == 1u) {
                        let _e395 = q_13;
                        let _e396 = textureLoad(cells, _e395, 0i);
                        let _e402 = Ld;
                        Ld = (_e402 * (1f - (f32((_e396.w & 255u)) / 255f)));
                    }
                    let _e404 = Ld;
                    let _e405 = w_2;
                    let _e409 = pc.f0_[0u];
                    r_5.L = (((_e404 * _e405) * _e409) * 1.6f);
                    r_5.travelled = 0f;
                    let _e415 = r_5.x;
                    r_5.last = vec2<i32>(floor(_e415));
                    pending = false;
                    let _e421 = r_5.L[0u];
                    let _e424 = r_5.L[1u];
                    let _e427 = r_5.L[2u];
                    if (max(_e421, max(_e424, _e427)) < 0.002f) {
                        r_5.alive = false;
                    }
                } else {
                    let _e432 = start_1;
                    let _e433 = d_1;
                    let _e434 = n_6;
                    r_5.x = (_e432 + (_e433 * f32(_e434)));
                }
            } else {
                let _e440 = r_5.alive;
                if _e440 {
                    let _e441 = r_5;
                    param_169 = _e441;
                    ray_step_u0028_struct_u002d_Ray_u002d_vf2_u002d_vf2_u002d_vf3_u002d_f1_u002d_f1_u002d_f1_u002d_i1_u002d_f1_u002d_f1_u002d_vi2_u002d_u1_u002d_f1_u002d_b11_u003b_vf3_u003b_b1_u003b_vf3_u003b((&param_169), (&param_170), (&param_171), (&param_172));
                    let _e442 = param_169;
                    r_5 = _e442;
                    let _e443 = param_170;
                    airL_3 = _e443;
                    let _e444 = param_171;
                    inAir_3 = _e444;
                    let _e445 = param_172;
                    lL_1 = _e445;
                    let _e446 = lL_1;
                    if any((_e446 != vec3<f32>(0f, 0f, 0f))) {
                        let _e449 = lL_1;
                        landL_4 = _e449;
                        let _e451 = r_5.x;
                        landX_2 = (floor(_e451) + vec2(0.5f));
                        let _e456 = r_5.events;
                        landEv_2 = _e456;
                    }
                }
            }
            let _e457 = t_4;
            if ((_e457 & 1i) == 0i) {
                let _e460 = li_7;
                param_173 = _e460;
                let _e461 = t_4;
                param_174 = _e461;
                let _e463 = r_5.x;
                param_175 = _e463;
                let _e465 = r_5.events;
                param_176 = _e465;
                let _e466 = airL_3;
                param_177 = _e466;
                let _e468 = r_5.dir;
                param_178 = _e468;
                wf_record_u0028_u1_u003b_i1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b((&param_173), (&param_174), (&param_175), (&param_176), (&param_177), (&param_178));
                let _e469 = pend_1;
                pend_1 = (_e469 + 1i);
                let _e471 = t_4;
                if ((_e471 & 15i) == 14i) {
                    pend_1 = 0i;
                    let _e474 = li_7;
                    param_179 = _e474;
                    let _e475 = t_4;
                    param_180 = _e475;
                    let _e477 = r_5.alive;
                    param_181 = _e477;
                    let _e478 = wf_flush_u0028_u1_u003b_i1_u003b_b1_u003b((&param_179), (&param_180), (&param_181));
                    if _e478 {
                        break;
                    }
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e479 = t_4;
            t_4 = (_e479 + 1i);
        }
    }
    let _e481 = li_7;
    param_182 = _e481;
    let _e482 = pend_1;
    param_183 = _e482;
    let _e483 = landX_2;
    param_184 = _e483;
    let _e484 = landEv_2;
    param_185 = _e484;
    let _e485 = landL_4;
    param_186 = _e485;
    let _e486 = d_1;
    param_187 = _e486;
    wf_finish_u0028_u1_u003b_i1_u003b_vf2_u003b_i1_u003b_vf3_u003b_vf2_u003b((&param_182), (&param_183), (&param_184), (&param_185), (&param_186), (&param_187));
    return;
}

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var g: i32;
    var sunN: i32;
    var param_188: i32;
    var param_189: i32;
    var lampLayer: i32;
    var lampN: i32;
    var local_17: i32;
    var layer: i32;
    var r_6: i32;
    var param_190: vec3<i32>;
    var mx: i32;
    var param_191: vec2<i32>;

    g_afterEvent = false;
    let _e192 = pc.i0_;
    g_n = _e192.xy;
    let _e195 = gl_WorkGroupID_1[0u];
    g = bitcast<i32>(_e195);
    let _e199 = pc.i1_[2u];
    sunN = select(0i, 80i, (_e199 != 0i));
    let _e202 = g;
    let _e203 = sunN;
    if (_e202 < _e203) {
        let _e205 = g;
        let _e213 = g;
        param_188 = (_e205 % 10i + select(0i, 10i, _e205 % 10i != 0i && ((_e205 % 10i < 0i) != (10i < 0i))));
        param_189 = (_e213 / 10i);
        sun_waves_u0028_i1_u003b_i1_u003b((&param_188), (&param_189));
        return;
    }
    let _e215 = sunN;
    let _e216 = g;
    g = (_e216 - _e215);
    let _e220 = pc.i1_[0u];
    let _e223 = pc.i1_[1u];
    lampLayer = (_e220 * _e223);
    let _e227 = pc.i1_[3u];
    if (_e227 != 0i) {
        let _e229 = lampLayer;
        local_17 = (_e229 * 8i);
    } else {
        local_17 = 0i;
    }
    let _e231 = local_17;
    lampN = _e231;
    let _e232 = g;
    let _e233 = lampN;
    if (_e232 < _e233) {
        let _e235 = g;
        let _e236 = lampLayer;
        layer = (_e235 / _e236);
        let _e238 = g;
        let _e239 = layer;
        let _e240 = lampLayer;
        r_6 = (_e238 - (_e239 * _e240));
        let _e243 = r_6;
        let _e246 = pc.i1_[0u];
        let _e254 = r_6;
        let _e257 = pc.i1_[0u];
        let _e259 = layer;
        param_190 = vec3<i32>((_e243 % _e246 + select(0i, _e246, _e243 % _e246 != 0i && ((_e243 % _e246 < 0i) != (_e246 < 0i)))), (_e254 / _e257), _e259);
        lamp_rays_u0028_vi3_u003b((&param_190));
        return;
    }
    let _e261 = lampN;
    let _e262 = g;
    g = (_e262 - _e261);
    let _e265 = g_n[0u];
    mx = ((_e265 + 7i) / 8i);
    let _e268 = g;
    let _e269 = mx;
    let _e277 = g;
    let _e278 = mx;
    let _e283 = gl_LocalInvocationID_1;
    param_191 = ((vec2<i32>((_e268 % _e269 + select(0i, _e269, _e268 % _e269 != 0i && ((_e268 % _e269 < 0i) != (_e269 < 0i)))), (_e277 / _e278)) * vec2(8i)) + bitcast<vec2<i32>>(_e283.xy));
    mirror_cell_u0028_vi2_u003b((&param_191));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(local_invocation_index) gl_LocalInvocationIndex: u32, @builtin(workgroup_id) gl_WorkGroupID: vec3<u32>, @builtin(local_invocation_id) gl_LocalInvocationID: vec3<u32>) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    gl_LocalInvocationID_1 = gl_LocalInvocationID;
    main_1(gl_WorkGroupID);
}
