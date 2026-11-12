struct Cell {
    mat: u32,
    variant: u32,
    flags: u32,
    temp: f32,
    life: u32,
    aux: u32,
    extra: u32,
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

struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct RenderParams {
    sky_top: vec4<f32>,
    sky_horizon: vec4<f32>,
    sun: vec4<f32>,
    sun_color: vec4<f32>,
    ambient: vec4<f32>,
    gi: vec4<f32>,
    bloom: vec4<f32>,
    expo: vec4<f32>,
    expo2_: vec4<f32>,
    medium: vec4<f32>,
    soot_color: vec4<f32>,
    steam_color: vec4<f32>,
    fx: vec4<f32>,
    misc: vec4<f32>,
    misc2_: vec4<f32>,
    reserved: vec4<f32>,
    cam_plane: vec4<f32>,
    cam_tilt: vec4<f32>,
    cam_right: vec4<f32>,
    cam_down: vec4<f32>,
    bgparams: vec4<f32>,
    haze: vec4<f32>,
    view: vec4<f32>,
    reserved2_: vec4<f32>,
    look: vec4<f32>,
    look2_: vec4<f32>,
    look3_: vec4<f32>,
    look4_: vec4<f32>,
    day: vec4<f32>,
}

struct Materials {
    mats: array<Material>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(4) 
var<uniform> rp: RenderParams;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(2) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(2) 
var medium_tex_smp: sampler;
@group(0) @binding(3) 
var fluence_prev: texture_2d<f32>;
@group(2) @binding(3) 
var fluence_prev_smp: sampler;
@group(0) @binding(12) 
var day_tex: texture_2d<f32>;
@group(2) @binding(12) 
var day_tex_smp: sampler;
@group(0) @binding(9) 
var bg: texture_2d<u32>;
@group(0) @binding(11) 
var beam_tex: texture_2d<f32>;
@group(2) @binding(11) 
var beam_tex_smp: sampler;
@group(0) @binding(5) 
var albedo_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(6) 
var emissive_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(7) 
var rcsrc_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(10) 
var rcext_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(8) 
var gaux_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(13) 
var ldir_prev: texture_2d<f32>;
@group(2) @binding(13) 
var ldir_prev_smp: sampler;
@group(0) @binding(14) 
var gloss_a_out: texture_storage_2d<rgba16float,write>;

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e215 = (*x);
    return (f32((_e215 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e215 = (*v);
    (*v) = ((_e215 * vec3(1664525u)) + vec3(1013904223u));
    let _e221 = (*v)[1u];
    let _e223 = (*v)[2u];
    let _e226 = (*v)[0u];
    (*v)[0u] = (_e226 + (_e221 * _e223));
    let _e230 = (*v)[2u];
    let _e232 = (*v)[0u];
    let _e235 = (*v)[1u];
    (*v)[1u] = (_e235 + (_e230 * _e232));
    let _e239 = (*v)[0u];
    let _e241 = (*v)[1u];
    let _e244 = (*v)[2u];
    (*v)[2u] = (_e244 + (_e239 * _e241));
    let _e247 = (*v);
    let _e251 = (*v);
    (*v) = (_e251 ^ (_e247 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e254 = (*v)[1u];
    let _e256 = (*v)[2u];
    let _e259 = (*v)[0u];
    (*v)[0u] = (_e259 + (_e254 * _e256));
    let _e263 = (*v)[2u];
    let _e265 = (*v)[0u];
    let _e268 = (*v)[1u];
    (*v)[1u] = (_e268 + (_e263 * _e265));
    let _e272 = (*v)[0u];
    let _e274 = (*v)[1u];
    let _e277 = (*v)[2u];
    (*v)[2u] = (_e277 + (_e272 * _e274));
    let _e280 = (*v);
    return _e280;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param: vec3<u32>;

    let _e216 = (*v_1);
    param = _e216;
    let _e217 = pcg3d_u0028_vu3_u003b((&param));
    return _e217.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_1: vec3<u32>;
    var param_2: u32;

    let _e217 = (*p);
    let _e219 = vec2<i32>(floor(_e217));
    param_1 = bitcast<vec3<u32>>(vec3<i32>(_e219.x, _e219.y, 1777i));
    let _e224 = hash1_u0028_vu3_u003b((&param_1));
    param_2 = _e224;
    let _e225 = u01_u0028_u1_u003b((&param_2));
    return _e225;
}

fn vnoise_u0028_vf2_u003b(p_1: ptr<function, vec2<f32>>) -> f32 {
    var i: vec2<f32>;
    var f: vec2<f32>;
    var a: f32;
    var param_3: vec2<f32>;
    var b: f32;
    var param_4: vec2<f32>;
    var c: f32;
    var param_5: vec2<f32>;
    var d: f32;
    var param_6: vec2<f32>;

    let _e225 = (*p_1);
    i = floor(_e225);
    let _e227 = (*p_1);
    f = fract(_e227);
    let _e229 = f;
    let _e230 = f;
    let _e232 = f;
    f = ((_e229 * _e230) * (vec2(3f) - (_e232 * 2f)));
    let _e237 = i;
    param_3 = _e237;
    let _e238 = hash21_u0028_vf2_u003b((&param_3));
    a = _e238;
    let _e239 = i;
    param_4 = (_e239 + vec2<f32>(1f, 0f));
    let _e241 = hash21_u0028_vf2_u003b((&param_4));
    b = _e241;
    let _e242 = i;
    param_5 = (_e242 + vec2<f32>(0f, 1f));
    let _e244 = hash21_u0028_vf2_u003b((&param_5));
    c = _e244;
    let _e245 = i;
    param_6 = (_e245 + vec2<f32>(1f, 1f));
    let _e247 = hash21_u0028_vf2_u003b((&param_6));
    d = _e247;
    let _e248 = a;
    let _e249 = b;
    let _e251 = f[0u];
    let _e253 = c;
    let _e254 = d;
    let _e256 = f[0u];
    let _e259 = f[1u];
    return mix(mix(_e248, _e249, _e251), mix(_e253, _e254, _e256), _e259);
}

fn fbm_u0028_vf2_u003b(p_2: ptr<function, vec2<f32>>) -> f32 {
    var s: f32;
    var a_1: f32;
    var i_1: i32;
    var param_7: vec2<f32>;

    s = 0f;
    a_1 = 0.5f;
    i_1 = 0i;
    loop {
        let _e219 = i_1;
        if (_e219 < 4i) {
            let _e221 = a_1;
            let _e222 = (*p_2);
            param_7 = _e222;
            let _e223 = vnoise_u0028_vf2_u003b((&param_7));
            let _e225 = s;
            s = (_e225 + (_e221 * _e223));
            let _e227 = (*p_2);
            (*p_2) = (_e227 * 2.03f);
            let _e229 = a_1;
            a_1 = (_e229 * 0.5f);
            continue;
        } else {
            break;
        }
        continuing {
            let _e231 = i_1;
            i_1 = (_e231 + 1i);
        }
    }
    let _e233 = s;
    return _e233;
}

fn sky_color_u0028_vf2_u003b(pos: ptr<function, vec2<f32>>) -> vec3<f32> {
    var h: f32;
    var s_1: vec3<f32>;
    var cl: f32;
    var param_8: vec2<f32>;

    let _e220 = (*pos)[1u];
    let _e223 = rp.misc[3u];
    h = clamp((_e220 / _e223), 0f, 1f);
    let _e227 = rp.sky_top;
    let _e230 = rp.sky_horizon;
    let _e232 = h;
    s_1 = (mix(_e227.xyz, _e230.xyz, vec3(pow(_e232, 0.8f))) * 0.55f);
    let _e238 = (*pos)[0u];
    let _e242 = rp.misc[0u];
    let _e246 = (*pos)[1u];
    param_8 = vec2<f32>(((_e238 * 0.016f) + (_e242 * 0.01f)), (_e246 * 0.04f));
    let _e249 = fbm_u0028_vf2_u003b((&param_8));
    cl = smoothstep(0.55f, 0.85f, _e249);
    let _e251 = s_1;
    let _e253 = rp.sky_horizon;
    let _e257 = rp.sun_color;
    let _e261 = cl;
    let _e263 = h;
    s_1 = mix(_e251, ((_e253.xyz * 0.75f) + (_e257.xyz * 0.15f)), vec3(((_e261 * 0.5f) * (1f - _e263))));
    let _e268 = s_1;
    return _e268;
}

fn bg_transmission_u0028_u1_u003b(kind: ptr<function, u32>) -> vec3<f32> {
    let _e215 = (*kind);
    if (_e215 == 0u) {
        return vec3<f32>(1f, 1f, 1f);
    }
    let _e217 = (*kind);
    if (_e217 == 7u) {
        return vec3<f32>(0.82f, 0.88f, 0.9f);
    }
    return vec3<f32>(0f, 0f, 0f);
}

fn flame_radiance_u0028_f1_u003b(f_1: ptr<function, f32>) -> vec3<f32> {
    var t: f32;
    var c_1: vec3<f32>;

    let _e217 = (*f_1);
    if (_e217 <= 0.001f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e219 = (*f_1);
    t = (1f - exp((-(_e219) * 0.9f)));
    let _e224 = t;
    c_1 = mix(vec3<f32>(0.9f, 0.12f, 0.02f), vec3<f32>(1f, 0.45f, 0.08f), vec3(smoothstep(0f, 0.5f, _e224)));
    let _e228 = c_1;
    let _e229 = t;
    c_1 = mix(_e228, vec3<f32>(1f, 0.86f, 0.55f), vec3(smoothstep(0.55f, 1f, _e229)));
    let _e233 = c_1;
    let _e234 = t;
    let _e238 = rp.medium[2u];
    return ((_e233 * _e234) * _e238);
}

fn flame_radiance_u0028_vf4_u003b(md: ptr<function, vec4<f32>>) -> vec3<f32> {
    var o: vec3<f32>;
    var param_9: f32;
    var h_1: f32;
    var t_1: f32;
    var blue: vec3<f32>;
    var white: vec3<f32>;
    var tinted: vec3<f32>;
    var w: f32;
    var local: f32;
    var phi_611_: bool;

    let _e225 = (*md)[2u];
    param_9 = _e225;
    let _e226 = flame_radiance_u0028_f1_u003b((&param_9));
    o = _e226;
    let _e228 = (*md)[2u];
    let _e229 = (_e228 <= 0.001f);
    phi_611_ = _e229;
    if !(_e229) {
        let _e232 = (*md)[3u];
        phi_611_ = (_e232 <= 0.001f);
    }
    let _e235 = phi_611_;
    if _e235 {
        let _e236 = o;
        return _e236;
    }
    let _e238 = (*md)[3u];
    let _e240 = (*md)[2u];
    h_1 = clamp((_e238 / _e240), 0f, 1f);
    let _e244 = (*md)[2u];
    t_1 = (1f - exp((-(_e244) * 0.9f)));
    let _e249 = t_1;
    let _e253 = rp.medium[2u];
    blue = (((vec3<f32>(0.15f, 0.35f, 1f) * _e249) * _e253) * 0.8f);
    let _e256 = t_1;
    let _e260 = rp.medium[2u];
    white = (((vec3<f32>(1f, 0.98f, 0.95f) * _e256) * _e260) * 3f);
    let _e263 = h_1;
    let _e265 = blue;
    let _e266 = white;
    tinted = select(_e266, _e265, vec3((_e263 < 0.75f)));
    let _e269 = h_1;
    if (_e269 < 0.75f) {
        let _e271 = h_1;
        local = clamp((_e271 / 0.5f), 0f, 1f);
    } else {
        let _e274 = h_1;
        local = clamp(((_e274 - 0.5f) / 0.5f), 0f, 1f);
    }
    let _e278 = local;
    w = _e278;
    let _e279 = o;
    let _e280 = tinted;
    let _e281 = w;
    return mix(_e279, _e280, vec3(_e281));
}

fn cell_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c_2: ptr<function, Cell>) -> u32 {
    let _e216 = (*c_2).flags;
    return ((_e216 & 28u) >> bitcast<u32>(2u));
}

fn blackbody_color_u0028_f1_u003b(t_2: ptr<function, f32>) -> vec3<f32> {
    var r: f32;
    var local_1: f32;
    var g: f32;
    var local_2: f32;
    var b_1: f32;
    var local_3: f32;
    var local_4: f32;

    let _e222 = (*t_2);
    (*t_2) = (clamp(_e222, 800f, 12000f) / 100f);
    let _e225 = (*t_2);
    if (_e225 <= 66f) {
        local_1 = 1f;
    } else {
        let _e227 = (*t_2);
        local_1 = (1.2929362f * pow((_e227 - 60f), -0.13320476f));
    }
    let _e231 = local_1;
    r = _e231;
    let _e232 = (*t_2);
    if (_e232 <= 66f) {
        let _e234 = (*t_2);
        local_2 = ((0.39008158f * log(_e234)) - 0.6318414f);
    } else {
        let _e238 = (*t_2);
        local_2 = (1.1298909f * pow((_e238 - 60f), -0.075514846f));
    }
    let _e242 = local_2;
    g = _e242;
    let _e243 = (*t_2);
    if (_e243 >= 66f) {
        local_3 = 1f;
    } else {
        let _e245 = (*t_2);
        if (_e245 <= 19f) {
            local_4 = 0f;
        } else {
            let _e247 = (*t_2);
            local_4 = ((0.5432068f * log((_e247 - 10f))) - 1.1962541f);
        }
        let _e252 = local_4;
        local_3 = _e252;
    }
    let _e253 = local_3;
    b_1 = _e253;
    let _e254 = r;
    let _e255 = g;
    let _e256 = b_1;
    return pow(clamp(vec3<f32>(_e254, _e255, _e256), vec3(0f), vec3(1f)), vec3<f32>(2.2f, 2.2f, 2.2f));
}

fn blackbody_u0028_f1_u003b(t_3: ptr<function, f32>) -> vec3<f32> {
    var k: f32;
    var param_10: f32;

    let _e217 = (*t_3);
    k = (max((_e217 - 720f), 0f) / 1300f);
    let _e221 = (*t_3);
    param_10 = _e221;
    let _e222 = blackbody_color_u0028_f1_u003b((&param_10));
    let _e223 = k;
    let _e224 = k;
    let _e226 = k;
    return (_e222 * min((((_e223 * _e224) * sqrt(_e226)) * 4f), 40f));
}

fn luminance_u0028_vf3_u003b(c_3: ptr<function, vec3<f32>>) -> f32 {
    let _e215 = (*c_3);
    return dot(_e215, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn in_world_u0028_vi2_u003b(p_3: ptr<function, vec2<i32>>) -> bool {
    var phi_223_: bool;
    var phi_236_: bool;
    var phi_244_: bool;

    let _e216 = (*p_3)[0u];
    let _e217 = (_e216 >= 0i);
    phi_223_ = _e217;
    if _e217 {
        let _e219 = (*p_3)[1u];
        phi_223_ = (_e219 >= 0i);
    }
    let _e222 = phi_223_;
    phi_236_ = _e222;
    if _e222 {
        let _e224 = (*p_3)[0u];
        let _e227 = pc.i0_[0u];
        phi_236_ = (_e224 < _e227);
    }
    let _e230 = phi_236_;
    phi_244_ = _e230;
    if _e230 {
        let _e232 = (*p_3)[1u];
        let _e235 = pc.i0_[1u];
        phi_244_ = (_e232 < _e235);
    }
    let _e238 = phi_244_;
    return _e238;
}

fn state_at_u0028_vi2_u003b(q: ptr<function, vec2<i32>>) -> u32 {
    var param_11: vec2<i32>;

    let _e216 = (*q);
    param_11 = _e216;
    let _e217 = in_world_u0028_vi2_u003b((&param_11));
    if !(_e217) {
        return 3u;
    }
    let _e219 = (*q);
    let _e220 = textureLoad(cells, _e219, 0i);
    let _e227 = unnamed.mats[(_e220.x & 255u)].ids[0u];
    return _e227;
}

fn occ_u0028_vi2_u003b(q_1: ptr<function, vec2<i32>>) -> f32 {
    var param_12: vec2<i32>;

    let _e216 = (*q_1);
    param_12 = _e216;
    let _e217 = state_at_u0028_vi2_u003b((&param_12));
    return select(0f, 1f, (_e217 != 0u));
}

fn depth_into_u0028_vi2_u003b(p_4: ptr<function, vec2<i32>>) -> f32 {
    var r_1: i32;
    var k_1: i32;
    var q_2: vec2<i32>;
    var indexable: array<vec2<i32>, 8>;
    var indexable_1: array<i32, 5>;
    var param_13: vec2<i32>;
    var s_2: u32;
    var param_14: vec2<i32>;
    var indexable_2: array<i32, 5>;

    r_1 = 0i;
    loop {
        let _e224 = r_1;
        if (_e224 < 5i) {
            k_1 = 0i;
            loop {
                let _e226 = k_1;
                if (_e226 < 8i) {
                    let _e228 = (*p_4);
                    let _e229 = k_1;
                    indexable = array<vec2<i32>, 8>(vec2<i32>(1i, 0i), vec2<i32>(-1i, 0i), vec2<i32>(0i, 1i), vec2<i32>(0i, -1i), vec2<i32>(1i, 1i), vec2<i32>(-1i, 1i), vec2<i32>(1i, -1i), vec2<i32>(-1i, -1i));
                    let _e231 = indexable[_e229];
                    let _e232 = r_1;
                    indexable_1 = array<i32, 5>(1i, 2i, 4i, 7i, 11i);
                    let _e234 = indexable_1[_e232];
                    q_2 = (_e228 + (_e231 * vec2(_e234)));
                    let _e238 = q_2;
                    param_13 = _e238;
                    let _e239 = in_world_u0028_vi2_u003b((&param_13));
                    if !(_e239) {
                        continue;
                    }
                    let _e241 = q_2;
                    param_14 = _e241;
                    let _e242 = state_at_u0028_vi2_u003b((&param_14));
                    s_2 = _e242;
                    let _e243 = s_2;
                    let _e245 = s_2;
                    if ((_e243 == 0u) || (_e245 == 1u)) {
                        let _e248 = r_1;
                        indexable_2 = array<i32, 5>(1i, 2i, 4i, 7i, 11i);
                        let _e250 = indexable_2[_e248];
                        return (f32(_e250) - 1f);
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e253 = k_1;
                    k_1 = (_e253 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e255 = r_1;
            r_1 = (_e255 + 1i);
        }
    }
    return 12f;
}

fn voronoi_u0028_vf2_u003b(x_1: ptr<function, vec2<f32>>) -> vec3<f32> {
    var i_2: vec2<f32>;
    var f_2: vec2<f32>;
    var d1_: f32;
    var d2_: f32;
    var id: f32;
    var y: i32;
    var xx: i32;
    var g_1: vec2<f32>;
    var o_1: vec2<f32>;
    var param_15: vec2<f32>;
    var param_16: vec2<f32>;
    var d_1: f32;
    var param_17: vec2<f32>;

    let _e228 = (*x_1);
    i_2 = floor(_e228);
    let _e230 = (*x_1);
    f_2 = fract(_e230);
    d1_ = 8f;
    d2_ = 8f;
    id = 0f;
    y = -1i;
    loop {
        let _e232 = y;
        if (_e232 <= 1i) {
            xx = -1i;
            loop {
                let _e234 = xx;
                if (_e234 <= 1i) {
                    let _e236 = xx;
                    let _e238 = y;
                    g_1 = vec2<f32>(f32(_e236), f32(_e238));
                    let _e241 = i_2;
                    let _e242 = g_1;
                    param_15 = ((_e241 + _e242) + vec2(17f));
                    let _e246 = hash21_u0028_vf2_u003b((&param_15));
                    let _e247 = i_2;
                    let _e248 = g_1;
                    param_16 = ((_e247 + _e248) + vec2(91f));
                    let _e252 = hash21_u0028_vf2_u003b((&param_16));
                    o_1 = vec2<f32>(_e246, _e252);
                    let _e254 = g_1;
                    let _e255 = o_1;
                    let _e257 = f_2;
                    d_1 = length(((_e254 + _e255) - _e257));
                    let _e260 = d_1;
                    let _e261 = d1_;
                    if (_e260 < _e261) {
                        let _e263 = d1_;
                        d2_ = _e263;
                        let _e264 = d_1;
                        d1_ = _e264;
                        let _e265 = i_2;
                        let _e266 = g_1;
                        param_17 = ((_e265 + _e266) + vec2(53f));
                        let _e270 = hash21_u0028_vf2_u003b((&param_17));
                        id = _e270;
                    } else {
                        let _e271 = d_1;
                        let _e272 = d2_;
                        if (_e271 < _e272) {
                            let _e274 = d_1;
                            d2_ = _e274;
                        }
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e275 = xx;
                    xx = (_e275 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e277 = y;
            y = (_e277 + 1i);
        }
    }
    let _e279 = d1_;
    let _e280 = d2_;
    let _e281 = id;
    return vec3<f32>(_e279, _e280, _e281);
}

fn pattern_t_u0028_i1_u003b_vf2_u003b_f1_u003b_f1_u003b_f1_u003b_f1_u003b(pat: ptr<function, i32>, wp: ptr<function, vec2<f32>>, seed: ptr<function, f32>, scale: ptr<function, f32>, noiseAmt: ptr<function, f32>, accent: ptr<function, f32>) -> f32 {
    var q_3: vec2<f32>;
    var w_1: f32;
    var param_18: vec2<f32>;
    var t_4: f32;
    var kc: vec2<f32>;
    var kp: vec2<f32>;
    var param_19: vec2<f32>;
    var param_20: vec2<f32>;
    var param_21: vec2<f32>;
    var t_5: f32;
    var param_22: vec2<f32>;
    var param_23: vec2<f32>;
    var vo: vec3<f32>;
    var param_24: vec2<f32>;
    var warp: f32;
    var param_25: vec2<f32>;
    var layers: f32;
    var param_26: vec2<f32>;
    var blot: f32;
    var param_27: vec2<f32>;
    var t_6: f32;
    var vein: f32;
    var param_28: vec2<f32>;
    var vo_1: vec3<f32>;
    var param_29: vec2<f32>;
    var t_7: f32;
    var vo_2: vec3<f32>;
    var param_30: vec2<f32>;
    var t_8: f32;
    var t_9: f32;
    var param_31: vec2<f32>;
    var cell: vec2<f32>;
    var c0_: vec2<f32>;
    var param_32: vec2<f32>;
    var param_33: vec2<f32>;
    var r_2: f32;
    var param_34: vec2<f32>;
    var d_2: f32;
    var param_35: vec2<f32>;
    var param_36: vec2<f32>;
    var layers_1: f32;
    var param_37: vec2<f32>;
    var param_38: vec2<f32>;
    var param_39: vec2<f32>;

    (*accent) = 0f;
    let _e264 = (*wp);
    let _e265 = (*scale);
    q_3 = (_e264 / vec2(max(_e265, 0.25f)));
    let _e269 = (*pat);
    if (_e269 == 1i) {
        let _e271 = (*seed);
        return _e271;
    }
    let _e272 = (*pat);
    if (_e272 == 2i) {
        let _e274 = q_3;
        param_18 = (_e274 * vec2<f32>(0.03f, 0.35f));
        let _e276 = fbm_u0028_vf2_u003b((&param_18));
        w_1 = (_e276 * 6f);
        let _e279 = q_3[1u];
        let _e281 = w_1;
        t_4 = (0.5f + (0.3f * sin(((_e279 * 1.1f) + _e281))));
        let _e287 = q_3[1u];
        let _e289 = w_1;
        let _e296 = t_4;
        t_4 = (_e296 - (0.35f * smoothstep(0.85f, 1f, abs(sin(((_e287 * 0.37f) + (_e289 * 0.5f)))))));
        let _e298 = q_3;
        kc = floor((_e298 / vec2<f32>(23f, 9f)));
        let _e301 = kc;
        let _e302 = kc;
        param_19 = _e302;
        let _e303 = hash21_u0028_vf2_u003b((&param_19));
        let _e304 = kc;
        param_20 = (_e304 + vec2(7f));
        let _e307 = hash21_u0028_vf2_u003b((&param_20));
        kp = ((_e301 + vec2<f32>(_e303, _e307)) * vec2<f32>(23f, 9f));
        let _e311 = q_3;
        let _e312 = kp;
        let _e317 = kc;
        param_21 = (_e317 + vec2(3f));
        let _e320 = hash21_u0028_vf2_u003b((&param_21));
        (*accent) = (smoothstep(2.2f, 0.8f, length(((_e311 - _e312) * vec2<f32>(0.6f, 1f)))) * step(0.7f, _e320));
        let _e323 = t_4;
        let _e324 = (*seed);
        return (_e323 + ((_e324 - 0.5f) * 0.15f));
    }
    let _e328 = (*pat);
    if (_e328 == 3i) {
        let _e331 = q_3[0u];
        let _e334 = q_3[1u];
        param_22 = vec2<f32>((_e331 * 0.06f), (_e334 * 1.7f));
        let _e337 = vnoise_u0028_vf2_u003b((&param_22));
        let _e341 = q_3[1u];
        param_23 = vec2<f32>(floor(_e341), 4f);
        let _e344 = hash21_u0028_vf2_u003b((&param_23));
        t_5 = ((0.45f + (0.35f * _e337)) + (0.12f * (_e344 - 0.5f)));
        let _e348 = q_3;
        param_24 = (_e348 * vec2<f32>(0.08f, 0.2f));
        let _e350 = voronoi_u0028_vf2_u003b((&param_24));
        vo = _e350;
        let _e352 = vo[1u];
        let _e354 = vo[0u];
        let _e358 = t_5;
        t_5 = (_e358 - (0.25f * smoothstep(0.08f, 0f, (_e352 - _e354))));
        let _e360 = t_5;
        return _e360;
    }
    let _e361 = (*pat);
    if (_e361 == 4i) {
        let _e363 = q_3;
        param_25 = (_e363 * 0.04f);
        let _e365 = fbm_u0028_vf2_u003b((&param_25));
        warp = (_e365 * 9f);
        let _e368 = q_3[0u];
        let _e371 = q_3[1u];
        let _e373 = warp;
        param_26 = vec2<f32>((_e368 * 0.025f), ((_e371 * 0.16f) + (_e373 * 0.12f)));
        let _e377 = fbm_u0028_vf2_u003b((&param_26));
        layers = _e377;
        let _e378 = q_3;
        param_27 = ((_e378 * 0.09f) + vec2(3.3f));
        let _e382 = fbm_u0028_vf2_u003b((&param_27));
        blot = _e382;
        let _e383 = layers;
        let _e386 = blot;
        let _e390 = (*seed);
        t_6 = (((0.25f + (_e383 * 0.55f)) + ((_e386 - 0.5f) * 0.35f)) + ((_e390 - 0.5f) * 0.18f));
        let _e394 = q_3;
        param_28 = ((_e394 * 0.07f) + vec2(9.1f));
        let _e398 = fbm_u0028_vf2_u003b((&param_28));
        vein = abs((_e398 - 0.5f));
        let _e401 = vein;
        (*accent) = smoothstep(0.022f, 0f, _e401);
        let _e403 = t_6;
        return _e403;
    }
    let _e404 = (*pat);
    if (_e404 == 5i) {
        let _e406 = q_3;
        param_29 = (_e406 * 0.16f);
        let _e408 = voronoi_u0028_vf2_u003b((&param_29));
        vo_1 = _e408;
        let _e410 = vo_1[2u];
        t_7 = (0.25f + (_e410 * 0.65f));
        let _e414 = vo_1[1u];
        let _e416 = vo_1[0u];
        (*accent) = (smoothstep(0.07f, 0f, (_e414 - _e416)) * 0.8f);
        let _e420 = t_7;
        return _e420;
    }
    let _e421 = (*pat);
    if (_e421 == 6i) {
        let _e423 = q_3;
        param_30 = (_e423 * 0.22f);
        let _e425 = voronoi_u0028_vf2_u003b((&param_30));
        vo_2 = _e425;
        let _e427 = vo_2[2u];
        let _e430 = (*seed);
        t_8 = ((0.3f + (_e427 * 0.5f)) + ((_e430 - 0.5f) * 0.25f));
        let _e435 = vo_2[1u];
        let _e437 = vo_2[0u];
        let _e441 = t_8;
        t_8 = (_e441 - (0.3f * smoothstep(0.1f, 0f, (_e435 - _e437))));
        let _e443 = t_8;
        return _e443;
    }
    let _e444 = (*pat);
    if (_e444 == 7i) {
        let _e446 = q_3;
        param_31 = (_e446 * 0.06f);
        let _e448 = fbm_u0028_vf2_u003b((&param_31));
        t_9 = (0.45f + ((_e448 - 0.5f) * 0.5f));
        let _e452 = q_3;
        cell = floor((_e452 / vec2(6f)));
        let _e456 = cell;
        let _e459 = cell;
        param_32 = (_e459 + vec2(4f));
        let _e462 = hash21_u0028_vf2_u003b((&param_32));
        let _e463 = cell;
        param_33 = (_e463 + vec2(9f));
        let _e466 = hash21_u0028_vf2_u003b((&param_33));
        c0_ = (((_e456 + vec2(0.2f)) + (vec2<f32>(_e462, _e466) * 0.6f)) * 6f);
        let _e471 = cell;
        param_34 = (_e471 + vec2(2f));
        let _e474 = hash21_u0028_vf2_u003b((&param_34));
        r_2 = (0.8f + (1.4f * _e474));
        let _e477 = q_3;
        let _e478 = c0_;
        d_2 = length((_e477 - _e478));
        let _e481 = cell;
        param_35 = (_e481 + vec2(31f));
        let _e484 = hash21_u0028_vf2_u003b((&param_35));
        let _e486 = d_2;
        let _e487 = r_2;
        if ((_e484 > 0.45f) && (_e486 < _e487)) {
            (*accent) = 1f;
            let _e491 = q_3[1u];
            let _e493 = c0_[1u];
            let _e496 = t_9;
            t_9 = (_e496 + select(-0.25f, 0.35f, (_e491 < _e493)));
        }
        let _e498 = t_9;
        return _e498;
    }
    let _e499 = (*pat);
    if (_e499 == 8i) {
        let _e502 = q_3[0u];
        let _e505 = q_3[1u];
        param_36 = vec2<f32>((_e502 * 0.05f), (_e505 * 0.7f));
        let _e508 = vnoise_u0028_vf2_u003b((&param_36));
        let _e511 = (*seed);
        return ((0.25f + (0.6f * _e508)) + ((_e511 - 0.5f) * 0.2f));
    }
    let _e515 = (*pat);
    if (_e515 == 9i) {
        let _e518 = q_3[0u];
        let _e521 = q_3[1u];
        param_37 = vec2<f32>((_e518 * 0.02f), (_e521 * 0.45f));
        let _e524 = vnoise_u0028_vf2_u003b((&param_37));
        let _e527 = q_3[0u];
        let _e530 = q_3[1u];
        param_38 = vec2<f32>((_e527 * 0.05f), (_e530 * 0.9f));
        let _e533 = vnoise_u0028_vf2_u003b((&param_38));
        layers_1 = ((_e524 * 0.6f) + (_e533 * 0.25f));
        let _e536 = layers_1;
        let _e538 = (*seed);
        return ((0.15f + _e536) + ((_e538 - 0.5f) * 0.3f));
    }
    let _e542 = q_3;
    param_39 = (_e542 * 0.22f);
    let _e544 = fbm_u0028_vf2_u003b((&param_39));
    let _e547 = (*noiseAmt);
    let _e551 = (*seed);
    return ((0.5f + (((_e544 - 0.5f) * 1.6f) * max(_e547, 0.15f))) + ((_e551 - 0.5f) * 0.45f));
}

fn material_albedo_u0028_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_u1_u003b(m: ptr<function, Material>, c_4: ptr<function, Cell>, p_5: ptr<function, vec2<i32>>, st: ptr<function, u32>) -> vec3<f32> {
    var wp_1: vec2<f32>;
    var seed_1: f32;
    var pat_1: i32;
    var t_10: f32;
    var accent_1: f32;
    var param_40: i32;
    var param_41: vec2<f32>;
    var param_42: f32;
    var param_43: f32;
    var param_44: f32;
    var param_45: f32;
    var dep: f32;
    var local_5: f32;
    var param_46: vec2<i32>;
    var crust: f32;
    var local_6: f32;
    var dth: f32;
    var indexable_3: array<f32, 4>;
    var idx: i32;
    var k_2: i32;
    var q_4: vec2<i32>;
    var local_7: i32;
    var local_8: i32;
    var param_47: vec2<i32>;
    var s_3: u32;
    var param_48: vec2<i32>;
    var col: vec3<f32>;
    var local_9: vec3<f32>;
    var local_10: vec3<f32>;
    var local_11: vec3<f32>;
    var rare: f32;
    var local_12: f32;
    var param_49: vec2<f32>;
    var local_13: f32;
    var param_50: vec2<f32>;
    var local_14: vec3<f32>;
    var phi_1349_: bool;
    var phi_1469_: bool;

    let _e254 = (*p_5);
    wp_1 = (vec2<f32>(_e254) + vec2(0.5f));
    let _e259 = (*c_4).variant;
    seed_1 = (f32(_e259) / 255f);
    let _e264 = (*m).sss_color[3u];
    pat_1 = i32((_e264 + 0.5f));
    let _e267 = pat_1;
    param_40 = _e267;
    let _e268 = wp_1;
    param_41 = _e268;
    let _e269 = seed_1;
    param_42 = _e269;
    let _e272 = (*m).pal0_[3u];
    param_43 = _e272;
    let _e275 = (*m).color_a[3u];
    param_44 = _e275;
    let _e276 = pattern_t_u0028_i1_u003b_vf2_u003b_f1_u003b_f1_u003b_f1_u003b_f1_u003b((&param_40), (&param_41), (&param_42), (&param_43), (&param_44), (&param_45));
    let _e277 = param_45;
    accent_1 = _e277;
    t_10 = _e276;
    let _e280 = (*m).pal2_[3u];
    let _e281 = (_e280 > 0f);
    phi_1349_ = _e281;
    if !(_e281) {
        let _e285 = (*m).accent[3u];
        phi_1349_ = (_e285 > 0f);
    }
    let _e288 = phi_1349_;
    if _e288 {
        let _e289 = (*p_5);
        param_46 = _e289;
        let _e290 = depth_into_u0028_vi2_u003b((&param_46));
        local_5 = _e290;
    } else {
        local_5 = 4f;
    }
    let _e291 = local_5;
    dep = _e291;
    let _e294 = (*m).pal2_[3u];
    if (_e294 > 0f) {
        let _e298 = (*m).pal2_[3u];
        let _e302 = (*m).pal2_[3u];
        let _e304 = dep;
        local_6 = (1f - smoothstep((_e298 - 0.5f), (_e302 + 0.5f), _e304));
    } else {
        local_6 = 0f;
    }
    let _e307 = local_6;
    crust = _e307;
    let _e310 = (*m).accent[3u];
    let _e311 = dep;
    let _e315 = t_10;
    t_10 = (_e315 - ((_e310 * smoothstep(1f, 10f, _e311)) * 0.5f));
    let _e318 = (*p_5)[0u];
    let _e321 = (*p_5)[1u];
    indexable_3 = array<f32, 4>(0f, 0.5f, 0.75f, 0.25f);
    let _e326 = indexable_3[((_e318 & 1i) + ((_e321 & 1i) * 2i))];
    dth = ((_e326 - 0.375f) * 0.18f);
    let _e329 = t_10;
    let _e331 = dth;
    idx = clamp(i32(floor(((_e329 * 4f) + _e331))), 0i, 3i);
    k_2 = 0i;
    loop {
        let _e336 = k_2;
        if (_e336 < 4i) {
            let _e338 = (*p_5);
            let _e339 = k_2;
            if (_e339 == 0i) {
                local_7 = 1i;
            } else {
                let _e341 = k_2;
                local_7 = select(0i, -1i, (_e341 == 1i));
            }
            let _e344 = local_7;
            let _e345 = k_2;
            if (_e345 == 2i) {
                local_8 = 1i;
            } else {
                let _e347 = k_2;
                local_8 = select(0i, -1i, (_e347 == 3i));
            }
            let _e350 = local_8;
            q_4 = (_e338 + vec2<i32>(_e344, _e350));
            let _e353 = q_4;
            param_47 = _e353;
            let _e354 = in_world_u0028_vi2_u003b((&param_47));
            if !(_e354) {
                continue;
            }
            let _e356 = q_4;
            param_48 = _e356;
            let _e357 = state_at_u0028_vi2_u003b((&param_48));
            s_3 = _e357;
            let _e358 = s_3;
            let _e360 = s_3;
            let _e362 = ((_e358 == 3u) || (_e360 == 2u));
            phi_1469_ = _e362;
            if _e362 {
                let _e363 = q_4;
                let _e364 = textureLoad(cells, _e363, 0i);
                let _e368 = (*c_4).mat;
                phi_1469_ = ((_e364.x & 255u) != _e368);
            }
            let _e371 = phi_1469_;
            if _e371 {
                let _e372 = idx;
                idx = max((_e372 - 1i), 0i);
                break;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e375 = k_2;
            k_2 = (_e375 + 1i);
        }
    }
    let _e377 = idx;
    if (_e377 == 0i) {
        let _e380 = (*m).pal0_;
        local_9 = _e380.xyz;
    } else {
        let _e382 = idx;
        if (_e382 == 1i) {
            let _e385 = (*m).pal1_;
            local_10 = _e385.xyz;
        } else {
            let _e387 = idx;
            if (_e387 == 2i) {
                let _e390 = (*m).pal2_;
                local_11 = _e390.xyz;
            } else {
                let _e393 = (*m).pal3_;
                local_11 = _e393.xyz;
            }
            let _e395 = local_11;
            local_10 = _e395;
        }
        let _e396 = local_10;
        local_9 = _e396;
    }
    let _e397 = local_9;
    col = _e397;
    let _e400 = (*m).pal1_[3u];
    if (_e400 > 0f) {
        let _e404 = (*m).pal1_[3u];
        let _e406 = wp_1;
        let _e408 = seed_1;
        param_49 = (((_e406 * 1.13f) + vec2((_e408 * 97f))) + vec2(7f));
        let _e414 = hash21_u0028_vf2_u003b((&param_49));
        local_12 = step((1f - _e404), _e414);
    } else {
        local_12 = 0f;
    }
    let _e416 = local_12;
    rare = _e416;
    let _e417 = pat_1;
    let _e419 = pat_1;
    let _e422 = pat_1;
    if (((_e417 == 1i) || (_e419 == 6i)) || (_e422 == 9i)) {
        let _e427 = (*m).pal1_[3u];
        if (_e427 > 0f) {
            let _e431 = (*m).pal1_[3u];
            let _e433 = seed_1;
            let _e436 = (*c_4).mat;
            param_50 = (vec2<f32>((_e433 * 255f), f32(_e436)) + vec2(3f));
            let _e441 = hash21_u0028_vf2_u003b((&param_50));
            local_13 = step((1f - _e431), _e441);
        } else {
            local_13 = 0f;
        }
        let _e443 = local_13;
        rare = _e443;
    }
    let _e444 = col;
    let _e446 = (*m).accent;
    let _e448 = accent_1;
    let _e449 = rare;
    let _e453 = (*m).accent;
    col = mix(_e444, _e446.xyz, vec3((clamp(max(_e448, _e449), 0f, 1f) * step(0.01f, length(_e453.xyz)))));
    let _e460 = col;
    let _e463 = (*m).pal3_[3u];
    if (_e463 > 0f) {
        let _e466 = (*m).accent;
        local_14 = _e466.xyz;
    } else {
        let _e468 = col;
        local_14 = _e468;
    }
    let _e469 = local_14;
    let _e470 = crust;
    let _e473 = (*m).pal3_[3u];
    col = mix(_e460, _e469, vec3((_e470 * _e473)));
    let _e477 = col;
    return _e477;
}

fn unpack_cell_u0028_vu4_u003b(v_2: ptr<function, vec4<u32>>) -> Cell {
    var c_5: Cell;

    let _e217 = (*v_2)[0u];
    c_5.mat = (_e217 & 255u);
    let _e221 = (*v_2)[0u];
    c_5.variant = ((_e221 >> bitcast<u32>(8u)) & 255u);
    let _e227 = (*v_2)[0u];
    c_5.flags = (_e227 >> bitcast<u32>(16u));
    let _e232 = (*v_2)[1u];
    c_5.temp = bitcast<f32>(_e232);
    let _e236 = (*v_2)[2u];
    c_5.life = (_e236 & 65535u);
    let _e240 = (*v_2)[2u];
    c_5.aux = (_e240 >> bitcast<u32>(16u));
    let _e245 = (*v_2)[3u];
    c_5.extra = _e245;
    let _e247 = c_5;
    return _e247;
}

fn main_1() {
    var p_6: vec2<i32>;
    var param_51: vec2<i32>;
    var c_6: Cell;
    var param_52: vec4<u32>;
    var m_1: Material;
    var st_1: u32;
    var pos_1: vec2<f32>;
    var uv: vec2<f32>;
    var time: f32;
    var alb: vec3<f32>;
    var param_53: Material;
    var param_54: Cell;
    var param_55: vec2<i32>;
    var param_56: u32;
    var v_3: f32;
    var param_57: vec2<f32>;
    var n: f32;
    var param_58: vec2<f32>;
    var opacity: f32;
    var local_15: f32;
    var burning: bool;
    var tl: f32;
    var param_59: vec2<i32>;
    var t_11: f32;
    var param_60: vec2<i32>;
    var tr: f32;
    var param_61: vec2<i32>;
    var l: f32;
    var param_62: vec2<i32>;
    var r_3: f32;
    var param_63: vec2<i32>;
    var bl: f32;
    var param_64: vec2<i32>;
    var b_2: f32;
    var param_65: vec2<i32>;
    var br: f32;
    var param_66: vec2<i32>;
    var g_2: vec2<f32>;
    var nrm: vec2<f32>;
    var local_16: vec2<f32>;
    var acc: vec2<f32>;
    var y_1: i32;
    var x_2: i32;
    var param_67: vec2<i32>;
    var depth: f32;
    var k_3: i32;
    var param_68: vec2<i32>;
    var flicker: f32;
    var param_69: vec2<f32>;
    var emis: vec3<f32>;
    var life01_: f32;
    var tint: vec3<f32>;
    var gain: f32;
    var fc: vec3<f32>;
    var k_4: f32;
    var hue: vec3<f32>;
    var hot: f32;
    var veins: f32;
    var param_70: vec2<f32>;
    var plate: f32;
    var param_71: vec2<f32>;
    var crust_1: f32;
    var param_72: vec3<f32>;
    var param_73: vec3<f32>;
    var param_74: f32;
    var flameCol: vec3<f32>;
    var local_17: vec3<f32>;
    var param_75: f32;
    var fl: u32;
    var param_76: Cell;
    var med: vec4<f32>;
    var sig_mat: f32;
    var sig_med: f32;
    var src_mat: vec3<f32>;
    var surf: vec3<f32>;
    var here: vec3<f32>;
    var here_1: vec3<f32>;
    var sig_scatter: f32;
    var med_alb: vec3<f32>;
    var src_med: vec3<f32>;
    var param_77: vec4<f32>;
    var sig_bg: f32;
    var src_bg: vec3<f32>;
    var b_3: vec4<u32>;
    var tr_1: vec3<f32>;
    var param_78: u32;
    var param_79: vec2<f32>;
    var bl_1: vec3<f32>;
    var sig: f32;
    var src: vec3<f32>;
    var local_18: vec3<f32>;
    var sig_rgb: vec3<f32>;
    var ga: vec4<f32>;
    var gr: vec2<f32>;
    var rough: f32;
    var q_5: vec2<f32>;
    var ld: vec4<f32>;
    var gw: f32;
    var inDir: vec2<f32>;
    var cosi: f32;
    var F0_: vec3<f32>;
    var F: vec3<f32>;
    var Lin: vec3<f32>;
    var phi_1886_: bool;
    var phi_2175_: bool;
    var phi_2295_: bool;
    var phi_2569_: bool;
    var phi_2660_: bool;
    var phi_2667_: bool;
    var phi_2673_: bool;

    let _e317 = gl_GlobalInvocationID_1;
    p_6 = bitcast<vec2<i32>>(_e317.xy);
    let _e320 = p_6;
    param_51 = _e320;
    let _e321 = in_world_u0028_vi2_u003b((&param_51));
    if !(_e321) {
        return;
    }
    let _e323 = p_6;
    let _e324 = textureLoad(cells, _e323, 0i);
    param_52 = _e324;
    let _e325 = unpack_cell_u0028_vu4_u003b((&param_52));
    c_6 = _e325;
    let _e327 = c_6.mat;
    let _e330 = unnamed.mats[_e327];
    m_1.color_a = _e330.color_a;
    m_1.color_b = _e330.color_b;
    m_1.emission = _e330.emission;
    m_1.phys = _e330.phys;
    m_1.thermo = _e330.thermo;
    m_1.burn = _e330.burn;
    m_1.optics = _e330.optics;
    m_1.scatter = _e330.scatter;
    m_1.ids = _e330.ids;
    m_1.ids2_ = _e330.ids2_;
    m_1.misc = _e330.misc;
    m_1.surface = _e330.surface;
    m_1.sss = _e330.sss;
    m_1.sss_color = _e330.sss_color;
    m_1.optics2_ = _e330.optics2_;
    m_1.pal0_ = _e330.pal0_;
    m_1.pal1_ = _e330.pal1_;
    m_1.pal2_ = _e330.pal2_;
    m_1.pal3_ = _e330.pal3_;
    m_1.accent = _e330.accent;
    m_1.flame = _e330.flame;
    let _e375 = m_1.ids[0u];
    st_1 = _e375;
    let _e376 = p_6;
    pos_1 = (vec2<f32>(_e376) + vec2(0.5f));
    let _e380 = pos_1;
    let _e382 = pc.i0_;
    uv = (_e380 / vec2<f32>(_e382.xy));
    let _e388 = rp.misc[0u];
    time = _e388;
    let _e389 = st_1;
    let _e391 = st_1;
    if ((_e389 == 3u) || (_e391 == 2u)) {
        let _e394 = m_1;
        param_53 = _e394;
        let _e395 = c_6;
        param_54 = _e395;
        let _e396 = p_6;
        param_55 = _e396;
        let _e397 = st_1;
        param_56 = _e397;
        let _e398 = material_albedo_u0028_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b_vi2_u003b_u1_u003b((&param_53), (&param_54), (&param_55), (&param_56));
        alb = _e398;
    } else {
        let _e400 = c_6.variant;
        v_3 = (f32(_e400) / 255f);
        let _e403 = st_1;
        if (_e403 == 1u) {
            let _e405 = pos_1;
            let _e408 = c_6.mat;
            param_57 = ((_e405 * 0.07f) + vec2((f32(_e408) * 3.7f)));
            let _e413 = fbm_u0028_vf2_u003b((&param_57));
            v_3 = _e413;
        }
        let _e415 = m_1.color_a;
        let _e418 = m_1.color_b;
        let _e420 = v_3;
        alb = mix(_e415.xyz, _e418.xyz, vec3(_e420));
        let _e423 = pos_1;
        let _e426 = c_6.mat;
        param_58 = ((_e423 * 0.22f) + vec2((f32(_e426) * 13.1f)));
        let _e431 = fbm_u0028_vf2_u003b((&param_58));
        n = (_e431 - 0.5f);
        let _e433 = n;
        let _e436 = m_1.color_a[3u];
        let _e440 = alb;
        alb = (_e440 * (1f + ((_e433 * _e436) * 0.9f)));
    }
    let _e443 = c_6.mat;
    if (_e443 == 0u) {
        local_15 = 0f;
    } else {
        let _e447 = m_1.color_b[3u];
        local_15 = _e447;
    }
    let _e448 = local_15;
    opacity = _e448;
    let _e450 = c_6.flags;
    burning = ((_e450 & 1u) != 0u);
    let _e453 = burning;
    if _e453 {
        let _e454 = alb;
        alb = (_e454 * 0.45f);
    }
    let _e456 = p_6;
    param_59 = (_e456 + vec2<i32>(-1i, -1i));
    let _e458 = occ_u0028_vi2_u003b((&param_59));
    tl = _e458;
    let _e459 = p_6;
    param_60 = (_e459 + vec2<i32>(0i, -1i));
    let _e461 = occ_u0028_vi2_u003b((&param_60));
    t_11 = _e461;
    let _e462 = p_6;
    param_61 = (_e462 + vec2<i32>(1i, -1i));
    let _e464 = occ_u0028_vi2_u003b((&param_61));
    tr = _e464;
    let _e465 = p_6;
    param_62 = (_e465 + vec2<i32>(-1i, 0i));
    let _e467 = occ_u0028_vi2_u003b((&param_62));
    l = _e467;
    let _e468 = p_6;
    param_63 = (_e468 + vec2<i32>(1i, 0i));
    let _e470 = occ_u0028_vi2_u003b((&param_63));
    r_3 = _e470;
    let _e471 = p_6;
    param_64 = (_e471 + vec2<i32>(-1i, 1i));
    let _e473 = occ_u0028_vi2_u003b((&param_64));
    bl = _e473;
    let _e474 = p_6;
    param_65 = (_e474 + vec2<i32>(0i, 1i));
    let _e476 = occ_u0028_vi2_u003b((&param_65));
    b_2 = _e476;
    let _e477 = p_6;
    param_66 = (_e477 + vec2<i32>(1i, 1i));
    let _e479 = occ_u0028_vi2_u003b((&param_66));
    br = _e479;
    let _e480 = tr;
    let _e481 = r_3;
    let _e484 = br;
    let _e486 = tl;
    let _e487 = l;
    let _e490 = bl;
    let _e493 = bl;
    let _e494 = b_2;
    let _e497 = br;
    let _e499 = tl;
    let _e500 = t_11;
    let _e503 = tr;
    g_2 = vec2<f32>((((_e480 + (2f * _e481)) + _e484) - ((_e486 + (2f * _e487)) + _e490)), (((_e493 + (2f * _e494)) + _e497) - ((_e499 + (2f * _e500)) + _e503)));
    let _e507 = g_2;
    if (length(_e507) > 0.01f) {
        let _e510 = g_2;
        local_16 = -(normalize(_e510));
    } else {
        local_16 = vec2<f32>(0f, 0f);
    }
    let _e513 = local_16;
    nrm = _e513;
    let _e514 = nrm;
    let _e515 = nrm;
    let _e518 = opacity;
    let _e520 = ((dot(_e514, _e515) > 0f) && (_e518 < 0.97f));
    phi_1886_ = _e520;
    if _e520 {
        let _e521 = st_1;
        let _e523 = st_1;
        phi_1886_ = ((_e521 == 3u) || (_e523 == 2u));
    }
    let _e527 = phi_1886_;
    if _e527 {
        acc = vec2<f32>(0f, 0f);
        y_1 = -3i;
        loop {
            let _e528 = y_1;
            if (_e528 <= 3i) {
                x_2 = -3i;
                loop {
                    let _e530 = x_2;
                    if (_e530 <= 3i) {
                        let _e532 = x_2;
                        let _e533 = x_2;
                        let _e535 = y_1;
                        let _e536 = y_1;
                        if (((_e532 * _e533) + (_e535 * _e536)) <= 10i) {
                            let _e540 = x_2;
                            let _e542 = y_1;
                            let _e545 = p_6;
                            let _e546 = x_2;
                            let _e547 = y_1;
                            param_67 = (_e545 + vec2<i32>(_e546, _e547));
                            let _e550 = occ_u0028_vi2_u003b((&param_67));
                            let _e552 = acc;
                            acc = (_e552 + (vec2<f32>(f32(_e540), f32(_e542)) * _e550));
                        }
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e554 = x_2;
                        x_2 = (_e554 + 1i);
                    }
                }
                continue;
            } else {
                break;
            }
            continuing {
                let _e556 = y_1;
                y_1 = (_e556 + 1i);
            }
        }
        let _e558 = acc;
        let _e559 = acc;
        if (dot(_e558, _e559) > 0.25f) {
            let _e562 = acc;
            nrm = -(normalize(_e562));
        }
    }
    depth = 0f;
    let _e565 = st_1;
    if (_e565 == 1u) {
        k_3 = 1i;
        loop {
            let _e567 = k_3;
            if (_e567 <= 24i) {
                let _e569 = p_6;
                let _e570 = k_3;
                param_68 = (_e569 - vec2<i32>(0i, _e570));
                let _e573 = state_at_u0028_vi2_u003b((&param_68));
                if (_e573 != 1u) {
                    break;
                }
                let _e575 = depth;
                depth = (_e575 + 1f);
                continue;
            } else {
                break;
            }
            continuing {
                let _e577 = k_3;
                k_3 = (_e577 + 1i);
            }
        }
    }
    let _e580 = pos_1[0u];
    let _e582 = time;
    let _e585 = pos_1[1u];
    param_69 = vec2<f32>((_e580 * 0.35f), ((_e582 * 9f) + (_e585 * 0.2f)));
    let _e589 = vnoise_u0028_vf2_u003b((&param_69));
    flicker = (0.75f + (0.5f * _e589));
    let _e593 = m_1.emission;
    emis = _e593.xyz;
    let _e597 = m_1.ids[1u];
    if ((_e597 & 64u) != 0u) {
        let _e601 = c_6.life;
        let _e605 = m_1.misc[1u];
        life01_ = clamp((f32(_e601) / max(_e605, 1f)), 0f, 1f);
        let _e609 = life01_;
        tint = mix(vec3<f32>(1f, 0.22f, 0.04f), vec3<f32>(1f, 0.78f, 0.38f), vec3(smoothstep(0.15f, 0.9f, _e609)));
        gain = 1f;
        let _e614 = c_6.flags;
        if ((_e614 & 128u) != 0u) {
            let _e618 = c_6.variant;
            let _e622 = unnamed.mats[_e618].flame;
            fc = _e622.xyz;
            let _e625 = fc[0u];
            let _e627 = fc[1u];
            let _e630 = fc[2u];
            k_4 = max(max(_e625, _e627), _e630);
            let _e632 = fc;
            let _e633 = k_4;
            hue = (_e632 / vec3(max(_e633, 0.001f)));
            let _e637 = hue;
            let _e639 = hue;
            let _e642 = life01_;
            tint = mix((_e637 * 0.55f), mix(_e639, vec3<f32>(1f, 1f, 1f), vec3(0.3f)), vec3(smoothstep(0.15f, 0.9f, _e642)));
            let _e646 = k_4;
            gain = clamp((_e646 / 2.2f), 0.8f, 2.5f);
        }
        let _e649 = tint;
        let _e651 = m_1.emission;
        let _e656 = gain;
        let _e658 = flicker;
        let _e660 = life01_;
        emis = (((((_e649 * length(_e651.xyz)) * 0.75f) * _e656) * _e658) * (0.3f + (0.9f * _e660)));
    }
    let _e666 = m_1.emission[3u];
    if (_e666 > 0f) {
        let _e669 = c_6.temp;
        hot = clamp(((_e669 - 900f) / 700f), 0f, 1.25f);
        let _e673 = pos_1;
        let _e675 = time;
        let _e677 = time;
        param_70 = ((_e673 * 0.18f) + vec2<f32>((_e675 * 0.1f), (-(_e677) * 0.24f)));
        let _e682 = fbm_u0028_vf2_u003b((&param_70));
        veins = (0.55f + (0.9f * _e682));
        let _e685 = hot;
        let _e686 = veins;
        let _e688 = emis;
        emis = (_e688 * (_e685 * _e686));
        let _e690 = st_1;
        if (_e690 == 1u) {
            let _e692 = pos_1;
            let _e694 = time;
            let _e696 = time;
            param_71 = ((_e692 * 0.11f) + vec2<f32>((_e694 * 0.03f), (_e696 * 0.05f)));
            let _e700 = fbm_u0028_vf2_u003b((&param_71));
            plate = _e700;
            let _e701 = plate;
            let _e703 = hot;
            crust_1 = smoothstep(0.42f, 0.56f, ((_e701 + 0.18f) - (_e703 * 0.22f)));
            let _e707 = crust_1;
            let _e709 = emis;
            emis = (_e709 * mix(1f, 0.06f, _e707));
            let _e711 = alb;
            let _e712 = crust_1;
            alb = mix(_e711, vec3<f32>(0.09f, 0.07f, 0.065f), vec3((_e712 * 0.85f)));
        }
    }
    let _e718 = m_1.ids[1u];
    if ((_e718 & 64u) == 0u) {
        let _e721 = alb;
        param_72 = _e721;
        let _e722 = luminance_u0028_vf3_u003b((&param_72));
        let _e724 = m_1.color_a;
        param_73 = _e724.xyz;
        let _e726 = luminance_u0028_vf3_u003b((&param_73));
        let _e730 = emis;
        emis = (_e730 * clamp((_e722 / max(_e726, 0.001f)), 0.25f, 1.6f));
    }
    let _e734 = m_1.ids[1u];
    let _e736 = ((_e734 & 136u) != 0u);
    phi_2175_ = _e736;
    if _e736 {
        let _e739 = m_1.ids[1u];
        phi_2175_ = ((_e739 & 64u) == 0u);
    }
    let _e743 = phi_2175_;
    if _e743 {
        let _e745 = c_6.life;
        let _e749 = m_1.misc[1u];
        let _e753 = emis;
        emis = (_e753 * clamp((f32(_e745) / max(_e749, 1f)), 0f, 1f));
    }
    let _e756 = c_6.temp;
    param_74 = _e756;
    let _e757 = blackbody_u0028_f1_u003b((&param_74));
    let _e760 = m_1.emission[3u];
    let _e762 = emis;
    emis = (_e762 + (_e757 * _e760));
    let _e765 = m_1.flame;
    let _e768 = m_1.flame;
    if (dot(_e765.xyz, _e768.xyz) > 0f) {
        let _e773 = m_1.flame;
        local_17 = _e773.xyz;
    } else {
        local_17 = vec3<f32>(2.2f, 0.924f, 0.22f);
    }
    let _e775 = local_17;
    flameCol = _e775;
    let _e776 = burning;
    if _e776 {
        let _e777 = flameCol;
        let _e778 = flicker;
        let _e781 = c_6.temp;
        param_75 = _e781;
        let _e782 = blackbody_u0028_f1_u003b((&param_75));
        let _e785 = emis;
        emis = (_e785 + ((_e777 * _e778) + (_e782 * 0.3f)));
    }
    let _e787 = c_6;
    param_76 = _e787;
    let _e788 = cell_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_76));
    fl = _e788;
    let _e789 = fl;
    if (_e789 > 0u) {
        let _e791 = fl;
        let _e795 = emis;
        emis = (_e795 + ((vec3<f32>(1f, 0.85f, 0.6f) * f32(_e791)) * 0.9f));
    }
    let _e797 = uv;
    let _e798 = textureSampleLevel(medium_tex, medium_tex_smp, _e797, 0f);
    med = _e798;
    let _e801 = m_1.optics[0u];
    sig_mat = _e801;
    let _e803 = med[0u];
    let _e806 = rp.medium[0u];
    let _e809 = med[1u];
    let _e812 = rp.medium[1u];
    let _e817 = rp.reserved[0u];
    let _e820 = med[2u];
    sig_med = ((((_e803 * _e806) + (_e809 * _e812)) * _e817) + (_e820 * 0.1f));
    let _e823 = emis;
    src_mat = _e823;
    let _e824 = st_1;
    let _e826 = st_1;
    let _e828 = ((_e824 == 3u) || (_e826 == 2u));
    phi_2295_ = _e828;
    if !(_e828) {
        let _e830 = st_1;
        let _e832 = opacity;
        phi_2295_ = ((_e830 == 1u) && (_e832 > 0.95f));
    }
    let _e836 = phi_2295_;
    if _e836 {
        let _e837 = nrm;
        let _e838 = nrm;
        if (dot(_e837, _e838) > 0f) {
            let _e841 = pos_1;
            let _e842 = nrm;
            let _e846 = pc.i0_;
            let _e850 = textureSampleLevel(fluence_prev, fluence_prev_smp, ((_e841 + (_e842 * 1.5f)) / vec2<f32>(_e846.xy)), 0f);
            surf = _e850.xyz;
            let _e852 = alb;
            let _e853 = surf;
            let _e857 = rp.gi[0u];
            let _e860 = m_1.optics2_[1u];
            let _e864 = src_mat;
            src_mat = (_e864 + ((_e852 * _e853) * max(_e857, (_e860 * 0.6f))));
            let _e866 = alb;
            let _e867 = pos_1;
            let _e868 = nrm;
            let _e872 = pc.i0_;
            let _e876 = textureSampleLevel(day_tex, day_tex_smp, ((_e867 + (_e868 * 1.5f)) / vec2<f32>(_e872.xy)), 0f);
            let _e880 = src_mat;
            src_mat = (_e880 + ((_e866 * _e876.xyz) * 0.5f));
        }
    } else {
        let _e882 = sig_mat;
        if (_e882 > 0f) {
            let _e884 = uv;
            let _e885 = textureSampleLevel(fluence_prev, fluence_prev_smp, _e884, 0f);
            here = _e885.xyz;
            let _e888 = m_1.scatter;
            let _e892 = m_1.optics[1u];
            let _e894 = here;
            let _e898 = rp.gi[0u];
            let _e900 = src_mat;
            src_mat = (_e900 + (((_e888.xyz * _e892) * _e894) * _e898));
        }
    }
    let _e902 = uv;
    let _e903 = textureSampleLevel(fluence_prev, fluence_prev_smp, _e902, 0f);
    here_1 = _e903.xyz;
    let _e906 = med[0u];
    let _e909 = rp.medium[0u];
    let _e912 = med[1u];
    let _e915 = rp.medium[1u];
    sig_scatter = ((_e906 * _e909) + (_e912 * _e915));
    let _e919 = med[0u];
    let _e922 = rp.medium[0u];
    let _e925 = rp.soot_color;
    let _e929 = med[1u];
    let _e932 = rp.medium[1u];
    let _e935 = rp.steam_color;
    let _e939 = sig_scatter;
    med_alb = (((_e925.xyz * (_e919 * _e922)) + (_e935.xyz * (_e929 * _e932))) / vec3(max(_e939, 0.0001f)));
    let _e943 = med_alb;
    let _e944 = here_1;
    let _e948 = rp.reserved[1u];
    let _e950 = med;
    param_77 = _e950;
    let _e951 = flame_radiance_u0028_vf4_u003b((&param_77));
    let _e952 = sig_med;
    src_med = (((_e943 * _e944) * _e948) + ((_e951 / vec3(max(_e952, 0.05f))) * 0.1f));
    sig_bg = 0f;
    src_bg = vec3<f32>(0f, 0f, 0f);
    let _e958 = st_1;
    if (_e958 == 0u) {
        let _e960 = p_6;
        let _e961 = textureLoad(bg, _e960, 0i);
        b_3 = _e961;
        let _e963 = b_3[0u];
        param_78 = _e963;
        let _e964 = bg_transmission_u0028_u1_u003b((&param_78));
        tr_1 = _e964;
        let _e966 = tr_1[0u];
        let _e968 = tr_1[1u];
        let _e970 = tr_1[2u];
        if (max(_e966, max(_e968, _e970)) > 0f) {
            sig_bg = 0.1f;
            let _e975 = pos_1[0u];
            let _e977 = pos_1[1u];
            param_79 = vec2<f32>(_e975, (_e977 * 0.5f));
            let _e980 = sky_color_u0028_vf2_u003b((&param_79));
            let _e982 = tr_1;
            src_bg = ((_e980 * 0.4f) * _e982);
        } else {
            let _e985 = b_3[0u];
            if (_e985 == 8u) {
                sig_bg = 0.1f;
                src_bg = vec3<f32>(0.4f, 1.36f, 1.6f);
            }
        }
    }
    let _e987 = st_1;
    if (_e987 == 0u) {
        let _e989 = uv;
        let _e990 = textureSampleLevel(beam_tex, beam_tex_smp, _e989, 0f);
        bl_1 = _e990.xyz;
        let _e993 = bl_1[0u];
        let _e995 = bl_1[1u];
        let _e997 = bl_1[2u];
        if (max(_e993, max(_e995, _e997)) > 0f) {
            let _e1001 = src_bg;
            let _e1002 = sig_bg;
            let _e1004 = bl_1;
            let _e1007 = sig_bg;
            src_bg = (((_e1001 * _e1002) + (_e1004 * 0.03f)) / vec3((_e1007 + 0.03f)));
            let _e1011 = sig_bg;
            sig_bg = (_e1011 + 0.03f);
        }
    }
    let _e1013 = sig_mat;
    let _e1014 = sig_med;
    let _e1016 = sig_bg;
    sig = ((_e1013 + _e1014) + _e1016);
    let _e1018 = sig;
    if (_e1018 > 0f) {
        let _e1020 = sig_mat;
        let _e1021 = src_mat;
        let _e1023 = sig_med;
        let _e1024 = src_med;
        let _e1027 = sig_bg;
        let _e1028 = src_bg;
        let _e1031 = sig;
        local_18 = ((((_e1021 * _e1020) + (_e1024 * _e1023)) + (_e1028 * _e1027)) / vec3(_e1031));
    } else {
        local_18 = vec3<f32>(0f, 0f, 0f);
    }
    let _e1034 = local_18;
    src = _e1034;
    let _e1035 = sig_mat;
    if (_e1035 >= 999f) {
        let _e1037 = src_mat;
        src = _e1037;
    }
    let _e1038 = sig;
    let _e1039 = sig_bg;
    sig_rgb = vec3((_e1038 - _e1039));
    let _e1042 = sig_mat;
    let _e1043 = (_e1042 < 999f);
    phi_2569_ = _e1043;
    if _e1043 {
        let _e1045 = c_6.mat;
        phi_2569_ = (_e1045 != 0u);
    }
    let _e1048 = phi_2569_;
    let _e1049 = st_1;
    if (_e1048 && (_e1049 != 0u)) {
        let _e1052 = sig_mat;
        let _e1053 = sig_med;
        let _e1055 = sig_bg;
        let _e1058 = alb;
        let _e1066 = m_1.optics[3u];
        sig_rgb = (vec3(((_e1052 + _e1053) + _e1055)) + (((vec3(1f) - clamp(_e1058, vec3(0f), vec3(1f))) * _e1066) * 1.5f));
    }
    let _e1070 = p_6;
    let _e1071 = alb;
    let _e1072 = opacity;
    textureStore(albedo_out, _e1070, vec4<f32>(_e1071.x, _e1071.y, _e1071.z, _e1072));
    let _e1077 = p_6;
    let _e1078 = emis;
    let _e1079 = st_1;
    textureStore(emissive_out, _e1077, vec4<f32>(_e1078.x, _e1078.y, _e1078.z, f32(_e1079)));
    let _e1085 = p_6;
    let _e1086 = src;
    let _e1087 = sig;
    textureStore(rcsrc_out, _e1085, vec4<f32>(_e1086.x, _e1086.y, _e1086.z, _e1087));
    let _e1092 = p_6;
    let _e1093 = sig_rgb;
    textureStore(rcext_out, _e1092, vec4<f32>(_e1093.x, _e1093.y, _e1093.z, 0f));
    let _e1098 = p_6;
    let _e1099 = nrm;
    let _e1100 = depth;
    let _e1102 = c_6.temp;
    textureStore(gaux_out, _e1098, vec4<f32>(_e1099.x, _e1099.y, _e1100, _e1102));
    ga = vec4<f32>(0f, 0f, 0f, 0f);
    gr = vec2<f32>(0f, 0f);
    let _e1108 = m_1.surface[1u];
    rough = clamp(_e1108, 0.03f, 1f);
    let _e1110 = st_1;
    let _e1112 = st_1;
    let _e1114 = ((_e1110 == 3u) || (_e1112 == 2u));
    phi_2660_ = _e1114;
    if !(_e1114) {
        let _e1116 = st_1;
        let _e1118 = opacity;
        phi_2660_ = ((_e1116 == 1u) && (_e1118 > 0.95f));
    }
    let _e1122 = phi_2660_;
    phi_2667_ = _e1122;
    if _e1122 {
        let _e1123 = nrm;
        let _e1124 = nrm;
        phi_2667_ = (dot(_e1123, _e1124) > 0f);
    }
    let _e1128 = phi_2667_;
    phi_2673_ = _e1128;
    if _e1128 {
        let _e1131 = m_1.surface[0u];
        phi_2673_ = (_e1131 > 0.2f);
    }
    let _e1134 = phi_2673_;
    let _e1135 = rough;
    if (_e1134 && (_e1135 < 0.6f)) {
        let _e1138 = pos_1;
        let _e1139 = nrm;
        let _e1143 = pc.i0_;
        q_5 = ((_e1138 + (_e1139 * 1.5f)) / vec2<f32>(_e1143.xy));
        let _e1147 = q_5;
        let _e1148 = textureSampleLevel(ldir_prev, ldir_prev_smp, _e1147, 0f);
        ld = _e1148;
        let _e1150 = ld[2u];
        let _e1152 = ld;
        let _e1154 = nrm;
        let _e1159 = emis[0u];
        let _e1161 = emis[1u];
        let _e1163 = emis[2u];
        gw = ((smoothstep(0.15f, 0.4f, _e1150) * smoothstep(0f, 0.25f, dot(_e1152.xy, _e1154))) * (1f - smoothstep(0.02f, 0.1f, max(_e1159, max(_e1161, _e1163)))));
        let _e1169 = gw;
        if (_e1169 > 0f) {
            let _e1171 = ld;
            inDir = -(normalize(_e1171.xy));
            let _e1175 = inDir;
            let _e1176 = nrm;
            gr = reflect(_e1175, _e1176);
            let _e1178 = inDir;
            let _e1180 = nrm;
            cosi = clamp(dot(-(_e1178), _e1180), 0f, 1f);
            let _e1183 = alb;
            let _e1186 = m_1.surface[2u];
            F0_ = mix(vec3<f32>(0.04f, 0.04f, 0.04f), _e1183, vec3(_e1186));
            let _e1189 = F0_;
            let _e1190 = F0_;
            let _e1193 = cosi;
            F = (_e1189 + ((vec3(1f) - _e1190) * pow((1f - _e1193), 5f)));
            let _e1198 = q_5;
            let _e1199 = textureSampleLevel(fluence_prev, fluence_prev_smp, _e1198, 0f);
            let _e1201 = q_5;
            let _e1202 = textureSampleLevel(day_tex, day_tex_smp, _e1201, 0f);
            let _e1207 = ld[2u];
            let _e1209 = gw;
            Lin = ((((_e1199.xyz + _e1202.xyz) * 2f) * _e1207) * _e1209);
            let _e1211 = Lin;
            let _e1212 = F;
            let _e1216 = m_1.surface[0u];
            let _e1218 = rough;
            let _e1223 = rp.day[2u];
            let _e1224 = ((((_e1211 * _e1212) * _e1216) * (1f - _e1218)) * _e1223);
            ga[0u] = _e1224.x;
            ga[1u] = _e1224.y;
            ga[2u] = _e1224.z;
            let _e1231 = rough;
            let _e1232 = rough;
            ga[3u] = clamp((2f / ((_e1231 * _e1232) + 0.02f)), 2f, 120f);
        }
    }
    let _e1238 = p_6;
    let _e1239 = ga;
    let _e1240 = _e1239.xyz;
    let _e1242 = gr[1u];
    let _e1244 = gr[0u];
    textureStore(gloss_a_out, _e1238, vec4<f32>(_e1240.x, _e1240.y, _e1240.z, atan2(_e1242, _e1244)));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
