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

struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct MatCost {
    mat_cost: array<u32>,
}

struct MatCost_1 {
    mat_cost: array<atomic<u32>>,
}

var<private> g_useCells: bool;
var<private> g_cost: vec3<u32>;
@group(0) @binding(11) 
var<uniform> rp: RenderParams;
@group(0) @binding(27) 
var cell_shade: texture_2d<f32>;
var<private> g_world: vec2<f32>;
@group(0) @binding(0) 
var l0s: texture_2d<f32>;
@group(0) @binding(14) 
var<storage> unnamed: Materials;
@group(0) @binding(13) 
var cells: texture_2d<u32>;
@group(0) @binding(3) 
var fl0_: texture_2d<f32>;
@group(2) @binding(3) 
var fl0_smp: sampler;
@group(0) @binding(4) 
var fl1_: texture_2d<f32>;
@group(2) @binding(4) 
var fl1_smp: sampler;
@group(0) @binding(5) 
var fl2_: texture_2d<f32>;
@group(2) @binding(5) 
var fl2_smp: sampler;
@group(0) @binding(6) 
var fl3_: texture_2d<f32>;
@group(2) @binding(6) 
var fl3_smp: sampler;
@group(0) @binding(7) 
var fl4_: texture_2d<f32>;
@group(2) @binding(7) 
var fl4_smp: sampler;
@group(0) @binding(8) 
var ldir_tex: texture_2d<f32>;
@group(2) @binding(8) 
var ldir_tex_smp: sampler;
@group(0) @binding(24) 
var cha_tex: texture_2d<f32>;
@group(2) @binding(24) 
var cha_tex_smp: sampler;
@group(0) @binding(25) 
var chb_tex: texture_2d<f32>;
@group(2) @binding(25) 
var chb_tex_smp: sampler;
var<private> g_time: f32;
@group(0) @binding(16) 
var occ_tex: texture_2d<f32>;
@group(2) @binding(16) 
var occ_tex_smp: sampler;
var<private> g_T0_: f32;
@group(0) @binding(15) 
var gaux_img: texture_2d<f32>;
var<private> g_frontRim: f32;
@group(0) @binding(2) 
var bg: texture_2d<u32>;
@group(0) @binding(20) 
var day_tex: texture_2d<f32>;
@group(2) @binding(20) 
var day_tex_smp: sampler;
@group(0) @binding(1) 
var l0t: texture_2d<f32>;
@group(0) @binding(26) 
var emissive_img: texture_2d<f32>;
@group(0) @binding(18) 
var bgsm_tex: texture_2d<f32>;
@group(2) @binding(18) 
var bgsm_tex_smp: sampler;
var<private> g_bgSmooth: f32;
var<private> g_lastBgZ: f32;
@group(0) @binding(9) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(9) 
var medium_tex_smp: sampler;
var<private> g_sigmaMax: f32;
var<private> g_F: f32;
@group(0) @binding(17) 
var side_tex: texture_2d<f32>;
@group(2) @binding(17) 
var side_tex_smp: sampler;
var<private> g_backFade: f32;
@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(10) 
var godray_tex: texture_2d<f32>;
@group(2) @binding(10) 
var godray_tex_smp: sampler;
@group(0) @binding(23) 
var fog_tex: texture_2d<f32>;
@group(2) @binding(23) 
var fog_tex_smp: sampler;
@group(0) @binding(19) 
var beam_tex: texture_2d<f32>;
@group(2) @binding(19) 
var beam_tex_smp: sampler;
@group(0) @binding(12) 
var out_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(21) 
var cost_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(22) 
var<storage, read_write> unnamed_1: MatCost_1;

fn web_isinf_u0028_vf3_u003b(x: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e333 = (*x);
    return (abs(_e333) > vec3<f32>(340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f));
}

fn web_isnan_u0028_vf3_u003b(x_1: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e333 = (*x_1);
    let _e334 = (*x_1);
    return (_e333 != _e334);
}

fn luminance_u0028_vf3_u003b(c: ptr<function, vec3<f32>>) -> f32 {
    let _e333 = (*c);
    return dot(_e333, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn fluence_at_u0028_vf2_u003b(xy: ptr<function, vec2<f32>>) -> vec3<f32> {
    let _e333 = (*xy);
    let _e334 = g_world;
    let _e336 = textureSampleLevel(fl0_, fl0_smp, (_e333 / _e334), 0f);
    return _e336.xyz;
}

fn light_at_u0028_vf2_u003b(xy_1: ptr<function, vec2<f32>>) -> vec4<f32> {
    let _e333 = (*xy_1);
    let _e334 = g_world;
    let _e336 = textureSampleLevel(ldir_tex, ldir_tex_smp, (_e333 / _e334), 0f);
    return _e336;
}

fn inw_u0028_vi2_u003b(c_1: ptr<function, vec2<i32>>) -> bool {
    var phi_1259_: bool;
    var phi_1269_: bool;
    var phi_1278_: bool;

    let _e334 = (*c_1)[0u];
    let _e335 = (_e334 >= 0i);
    phi_1259_ = _e335;
    if _e335 {
        let _e337 = (*c_1)[1u];
        phi_1259_ = (_e337 >= 0i);
    }
    let _e340 = phi_1259_;
    phi_1269_ = _e340;
    if _e340 {
        let _e342 = (*c_1)[0u];
        let _e344 = g_world[0u];
        phi_1269_ = (_e342 < i32(_e344));
    }
    let _e348 = phi_1269_;
    phi_1278_ = _e348;
    if _e348 {
        let _e350 = (*c_1)[1u];
        let _e352 = g_world[1u];
        phi_1278_ = (_e350 < i32(_e352));
    }
    let _e356 = phi_1278_;
    return _e356;
}

fn u01_u0028_u1_u003b(x_2: ptr<function, u32>) -> f32 {
    let _e333 = (*x_2);
    return (f32((_e333 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e333 = (*v);
    (*v) = ((_e333 * vec3(1664525u)) + vec3(1013904223u));
    let _e339 = (*v)[1u];
    let _e341 = (*v)[2u];
    let _e344 = (*v)[0u];
    (*v)[0u] = (_e344 + (_e339 * _e341));
    let _e348 = (*v)[2u];
    let _e350 = (*v)[0u];
    let _e353 = (*v)[1u];
    (*v)[1u] = (_e353 + (_e348 * _e350));
    let _e357 = (*v)[0u];
    let _e359 = (*v)[1u];
    let _e362 = (*v)[2u];
    (*v)[2u] = (_e362 + (_e357 * _e359));
    let _e365 = (*v);
    let _e369 = (*v);
    (*v) = (_e369 ^ (_e365 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e372 = (*v)[1u];
    let _e374 = (*v)[2u];
    let _e377 = (*v)[0u];
    (*v)[0u] = (_e377 + (_e372 * _e374));
    let _e381 = (*v)[2u];
    let _e383 = (*v)[0u];
    let _e386 = (*v)[1u];
    (*v)[1u] = (_e386 + (_e381 * _e383));
    let _e390 = (*v)[0u];
    let _e392 = (*v)[1u];
    let _e395 = (*v)[2u];
    (*v)[2u] = (_e395 + (_e390 * _e392));
    let _e398 = (*v);
    return _e398;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param: vec3<u32>;

    let _e334 = (*v_1);
    param = _e334;
    let _e335 = pcg3d_u0028_vu3_u003b((&param));
    return _e335.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_1: vec3<u32>;
    var param_2: u32;

    let _e335 = (*p);
    let _e337 = vec2<i32>(floor(_e335));
    param_1 = bitcast<vec3<u32>>(vec3<i32>(_e337.x, _e337.y, 1777i));
    let _e342 = hash1_u0028_vu3_u003b((&param_1));
    param_2 = _e342;
    let _e343 = u01_u0028_u1_u003b((&param_2));
    return _e343;
}

fn dust_motes_u0028_vf2_u003b(xy_2: ptr<function, vec2<f32>>) -> vec3<f32> {
    var amount: f32;
    var t: f32;
    var drift: vec2<f32>;
    var c_2: vec2<i32>;
    var h: f32;
    var param_3: vec2<f32>;
    var w: vec2<i32>;
    var param_4: vec2<i32>;
    var s: vec4<f32>;
    var ld: vec4<f32>;
    var param_5: vec2<f32>;
    var f: vec3<f32>;
    var param_6: vec2<f32>;
    var beam: f32;
    var param_7: vec3<f32>;
    var tw: f32;
    var phi_5311_: bool;
    var phi_5332_: bool;

    let _e351 = rp.reserved2_[3u];
    amount = _e351;
    let _e352 = amount;
    if (_e352 <= 0f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e354 = g_time;
    t = _e354;
    let _e355 = t;
    let _e358 = (*xy_2)[1u];
    let _e360 = t;
    let _e366 = t;
    drift = vec2<f32>(((_e355 * 0.6f) + (sin(((_e358 * 0.05f) + (_e360 * 0.3f))) * 2f)), (_e366 * 0.9f));
    let _e369 = (*xy_2);
    let _e370 = drift;
    c_2 = vec2<i32>(floor((_e369 - _e370)));
    let _e374 = c_2;
    param_3 = ((vec2<f32>(_e374) * 1.31f) + vec2(7f));
    let _e379 = hash21_u0028_vf2_u003b((&param_3));
    h = _e379;
    let _e380 = h;
    let _e381 = amount;
    if (_e380 < (1f - (0.002f * _e381))) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e385 = (*xy_2);
    w = vec2<i32>(floor(_e385));
    let _e388 = w;
    param_4 = _e388;
    let _e389 = inw_u0028_vi2_u003b((&param_4));
    if !(_e389) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e391 = w;
    let _e392 = textureLoad(l0s, _e391, 0i);
    s = _e392;
    let _e394 = s[3u];
    let _e395 = (_e394 >= 0.99f);
    phi_5311_ = _e395;
    if !(_e395) {
        let _e397 = w;
        let _e398 = textureLoad(cells, _e397, 0i);
        phi_5311_ = ((_e398.x & 255u) != 0u);
    }
    let _e403 = phi_5311_;
    if _e403 {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e404 = w;
    let _e405 = textureLoad(bg, _e404, 0i);
    let _e407 = (_e405.x == 0u);
    phi_5332_ = _e407;
    if !(_e407) {
        let _e409 = w;
        let _e412 = textureLoad(bg, max((_e409 - vec2<i32>(0i, 40i)), vec2<i32>(0i, 0i)), 0i);
        phi_5332_ = (_e412.x == 0u);
    }
    let _e416 = phi_5332_;
    if _e416 {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e417 = (*xy_2);
    param_5 = _e417;
    let _e418 = light_at_u0028_vf2_u003b((&param_5));
    ld = _e418;
    let _e419 = (*xy_2);
    param_6 = _e419;
    let _e420 = fluence_at_u0028_vf2_u003b((&param_6));
    f = _e420;
    let _e421 = f;
    param_7 = _e421;
    let _e422 = luminance_u0028_vf3_u003b((&param_7));
    let _e425 = ld[2u];
    beam = (smoothstep(0.7f, 2f, _e422) * smoothstep(0.5f, 0.9f, _e425));
    let _e428 = t;
    let _e429 = h;
    let _e433 = h;
    tw = (0.5f + (0.5f * sin(((_e428 * (2f + (_e429 * 40f))) + (_e433 * 100f)))));
    let _e439 = f;
    let _e440 = beam;
    let _e442 = tw;
    return (((_e439 * _e440) * _e442) * 1.6f);
}

fn vnoise_u0028_vf2_u003b(p_1: ptr<function, vec2<f32>>) -> f32 {
    var i: vec2<f32>;
    var f_1: vec2<f32>;
    var a: f32;
    var param_8: vec2<f32>;
    var b: f32;
    var param_9: vec2<f32>;
    var c_3: f32;
    var param_10: vec2<f32>;
    var d: f32;
    var param_11: vec2<f32>;

    let _e343 = (*p_1);
    i = floor(_e343);
    let _e345 = (*p_1);
    f_1 = fract(_e345);
    let _e347 = f_1;
    let _e348 = f_1;
    let _e350 = f_1;
    f_1 = ((_e347 * _e348) * (vec2(3f) - (_e350 * 2f)));
    let _e355 = i;
    param_8 = _e355;
    let _e356 = hash21_u0028_vf2_u003b((&param_8));
    a = _e356;
    let _e357 = i;
    param_9 = (_e357 + vec2<f32>(1f, 0f));
    let _e359 = hash21_u0028_vf2_u003b((&param_9));
    b = _e359;
    let _e360 = i;
    param_10 = (_e360 + vec2<f32>(0f, 1f));
    let _e362 = hash21_u0028_vf2_u003b((&param_10));
    c_3 = _e362;
    let _e363 = i;
    param_11 = (_e363 + vec2<f32>(1f, 1f));
    let _e365 = hash21_u0028_vf2_u003b((&param_11));
    d = _e365;
    let _e366 = a;
    let _e367 = b;
    let _e369 = f_1[0u];
    let _e371 = c_3;
    let _e372 = d;
    let _e374 = f_1[0u];
    let _e377 = f_1[1u];
    return mix(mix(_e366, _e367, _e369), mix(_e371, _e372, _e374), _e377);
}

fn fbm_u0028_vf2_u003b(p_2: ptr<function, vec2<f32>>) -> f32 {
    var s_1: f32;
    var a_1: f32;
    var i_1: i32;
    var param_12: vec2<f32>;

    s_1 = 0f;
    a_1 = 0.5f;
    i_1 = 0i;
    loop {
        let _e337 = i_1;
        if (_e337 < 4i) {
            let _e339 = a_1;
            let _e340 = (*p_2);
            param_12 = _e340;
            let _e341 = vnoise_u0028_vf2_u003b((&param_12));
            let _e343 = s_1;
            s_1 = (_e343 + (_e339 * _e341));
            let _e345 = (*p_2);
            (*p_2) = (_e345 * 2.03f);
            let _e347 = a_1;
            a_1 = (_e347 * 0.5f);
            continue;
        } else {
            break;
        }
        continuing {
            let _e349 = i_1;
            i_1 = (_e349 + 1i);
        }
    }
    let _e351 = s_1;
    return _e351;
}

fn sky_color_u0028_vf2_u003b(pos: ptr<function, vec2<f32>>) -> vec3<f32> {
    var h_1: f32;
    var s_2: vec3<f32>;
    var cl: f32;
    var param_13: vec2<f32>;

    let _e338 = (*pos)[1u];
    let _e341 = rp.misc[3u];
    h_1 = clamp((_e338 / _e341), 0f, 1f);
    let _e345 = rp.sky_top;
    let _e348 = rp.sky_horizon;
    let _e350 = h_1;
    s_2 = (mix(_e345.xyz, _e348.xyz, vec3(pow(_e350, 0.8f))) * 0.55f);
    let _e356 = (*pos)[0u];
    let _e360 = rp.misc[0u];
    let _e364 = (*pos)[1u];
    param_13 = vec2<f32>(((_e356 * 0.016f) + (_e360 * 0.01f)), (_e364 * 0.04f));
    let _e367 = fbm_u0028_vf2_u003b((&param_13));
    cl = smoothstep(0.55f, 0.85f, _e367);
    let _e369 = s_2;
    let _e371 = rp.sky_horizon;
    let _e375 = rp.sun_color;
    let _e379 = cl;
    let _e381 = h_1;
    s_2 = mix(_e369, ((_e371.xyz * 0.75f) + (_e375.xyz * 0.15f)), vec3(((_e379 * 0.5f) * (1f - _e381))));
    let _e386 = s_2;
    return _e386;
}

fn fl_level_u0028_i1_u003b_vf2_u003b(l: ptr<function, i32>, uv: ptr<function, vec2<f32>>) -> vec3<f32> {
    let _e334 = (*l);
    if (_e334 <= 0i) {
        let _e336 = (*uv);
        let _e337 = textureSampleLevel(fl0_, fl0_smp, _e336, 0f);
        return _e337.xyz;
    }
    let _e339 = (*l);
    if (_e339 == 1i) {
        let _e341 = (*uv);
        let _e342 = textureSampleLevel(fl1_, fl1_smp, _e341, 0f);
        return _e342.xyz;
    }
    let _e344 = (*l);
    if (_e344 == 2i) {
        let _e346 = (*uv);
        let _e347 = textureSampleLevel(fl2_, fl2_smp, _e346, 0f);
        return _e347.xyz;
    }
    let _e349 = (*l);
    if (_e349 == 3i) {
        let _e351 = (*uv);
        let _e352 = textureSampleLevel(fl3_, fl3_smp, _e351, 0f);
        return _e352.xyz;
    }
    let _e354 = (*uv);
    let _e355 = textureSampleLevel(fl4_, fl4_smp, _e354, 0f);
    return _e355.xyz;
}

fn fluence_depth_u0028_vf2_u003b_f1_u003b(xy_3: ptr<function, vec2<f32>>, z: ptr<function, f32>) -> vec3<f32> {
    var uv_1: vec2<f32>;
    var lv: f32;
    var a_2: i32;
    var b_1: i32;
    var param_14: i32;
    var param_15: vec2<f32>;
    var param_16: i32;
    var param_17: vec2<f32>;

    let _e342 = (*xy_3);
    let _e343 = g_world;
    uv_1 = (_e342 / _e343);
    let _e345 = (*z);
    lv = clamp(log2((1f + (max(_e345, 0f) / 10f))), 0f, 4f);
    let _e351 = lv;
    a_2 = i32(floor(_e351));
    let _e354 = a_2;
    b_1 = min((_e354 + 1i), 4i);
    let _e357 = a_2;
    param_14 = _e357;
    let _e358 = uv_1;
    param_15 = _e358;
    let _e359 = fl_level_u0028_i1_u003b_vf2_u003b((&param_14), (&param_15));
    let _e360 = b_1;
    param_16 = _e360;
    let _e361 = uv_1;
    param_17 = _e361;
    let _e362 = fl_level_u0028_i1_u003b_vf2_u003b((&param_16), (&param_17));
    let _e363 = lv;
    let _e364 = a_2;
    return mix(_e359, _e362, vec3((_e363 - f32(_e364))));
}

fn plane_backlight_u0028_vf2_u003b(xy_4: ptr<function, vec2<f32>>) -> vec3<f32> {
    var c_4: vec2<i32>;
    var param_18: vec2<i32>;
    var s_3: vec4<f32>;
    var tr: vec4<f32>;
    var k: u32;
    var behind: vec3<f32>;
    var param_19: vec2<f32>;
    var param_20: f32;
    var param_21: vec2<f32>;
    var through: vec3<f32>;
    var local: vec3<f32>;
    var own: vec3<f32>;
    var param_22: vec3<f32>;

    let _e346 = (*xy_4);
    c_4 = vec2<i32>(floor(_e346));
    let _e349 = c_4;
    param_18 = _e349;
    let _e350 = inw_u0028_vi2_u003b((&param_18));
    if !(_e350) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e352 = c_4;
    let _e353 = textureLoad(l0s, _e352, 0i);
    s_3 = _e353;
    let _e354 = c_4;
    let _e355 = textureLoad(l0t, _e354, 0i);
    tr = _e355;
    let _e356 = c_4;
    let _e357 = textureLoad(bg, _e356, 0i);
    k = _e357.x;
    let _e359 = (*xy_4);
    param_19 = _e359;
    param_20 = 40f;
    let _e360 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_19), (&param_20));
    behind = (_e360 * 0.6f);
    let _e362 = k;
    let _e364 = k;
    if ((_e362 == 0u) || (_e364 == 7u)) {
        let _e368 = (*xy_4)[0u];
        let _e370 = (*xy_4)[1u];
        param_21 = vec2<f32>(_e368, (_e370 * 0.5f));
        let _e373 = sky_color_u0028_vf2_u003b((&param_21));
        let _e375 = behind;
        behind = (_e375 + (_e373 * 0.5f));
    }
    let _e378 = s_3[3u];
    if (_e378 >= 0.99f) {
        local = vec3<f32>(0f, 0f, 0f);
    } else {
        let _e380 = behind;
        let _e381 = tr;
        local = (_e380 * _e381.xyz);
    }
    let _e384 = local;
    through = _e384;
    let _e385 = s_3;
    let _e387 = s_3;
    param_22 = _e387.xyz;
    let _e389 = luminance_u0028_vf3_u003b((&param_22));
    own = ((_e385.xyz * smoothstep(0.6f, 3f, _e389)) * 0.8f);
    let _e393 = through;
    let _e394 = own;
    return (_e393 + _e394);
}

fn front_volume_u0028_vf3_u003b_vf3_u003b_vi2_u003b_f1_u003b(p0_: ptr<function, vec3<f32>>, d_1: ptr<function, vec3<f32>>, pix: ptr<function, vec2<i32>>, Tv: ptr<function, f32>) -> vec3<f32> {
    var dens: f32;
    var depth: f32;
    var slope: vec2<f32>;
    var dzs: f32;
    var jit: f32;
    var indexable: array<f32, 16>;
    var L: vec3<f32>;
    var t_1: f32;
    var i_2: i32;
    var z_1: f32;
    var P: vec3<f32>;
    var Q: vec2<f32>;
    var wisp: f32;
    var param_23: vec2<f32>;
    var low: f32;
    var sd: f32;
    var param_24: vec2<f32>;

    (*Tv) = 1f;
    let _e355 = rp.reserved2_[1u];
    dens = _e355;
    let _e356 = dens;
    if (_e356 <= 0f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e360 = rp.view[3u];
    depth = _e360;
    let _e363 = rp.cam_right[2u];
    slope = vec2<f32>(0f, _e363);
    let _e365 = depth;
    dzs = (_e365 / 24f);
    let _e368 = (*pix)[1u];
    let _e372 = (*pix)[0u];
    indexable = array<f32, 16>(0f, 8f, 2f, 10f, 12f, 4f, 14f, 6f, 3f, 11f, 1f, 9f, 15f, 7f, 13f, 5f);
    let _e376 = indexable[(((_e368 & 3i) * 4i) + (_e372 & 3i))];
    jit = ((_e376 + 0.5f) / 16f);
    L = vec3<f32>(0f, 0f, 0f);
    let _e379 = g_time;
    t_1 = _e379;
    i_2 = 0i;
    loop {
        let _e380 = i_2;
        if (_e380 < 24i) {
            let _e383 = g_cost[1u];
            g_cost[1u] = (_e383 + 2u);
            let _e386 = i_2;
            let _e388 = jit;
            let _e391 = dzs;
            z_1 = (-((f32(_e386) + _e388)) * _e391);
            let _e393 = (*p0_);
            let _e394 = (*d_1);
            let _e395 = z_1;
            let _e397 = (*d_1)[2u];
            P = (_e393 + (_e394 * (_e395 / _e397)));
            let _e401 = P;
            let _e403 = slope;
            let _e404 = z_1;
            Q = (_e401.xy + (_e403 * _e404));
            let _e407 = P;
            let _e410 = t_1;
            let _e412 = z_1;
            let _e415 = t_1;
            param_23 = ((_e407.xy * 0.045f) + vec2<f32>((_e410 * 0.25f), ((-(_e412) * 0.04f) + (_e415 * 0.07f))));
            let _e420 = vnoise_u0028_vf2_u003b((&param_23));
            wisp = (0.55f + (0.9f * _e420));
            low = 1f;
            let _e423 = dens;
            let _e424 = wisp;
            let _e426 = low;
            let _e428 = dzs;
            sd = (((_e423 * _e424) * _e426) * _e428);
            let _e430 = (*Tv);
            let _e431 = Q;
            param_24 = _e431;
            let _e432 = plane_backlight_u0028_vf2_u003b((&param_24));
            let _e434 = sd;
            let _e436 = i_2;
            let _e441 = L;
            L = (_e441 + (((_e432 * _e430) * _e434) * mix(1f, 0.35f, (f32(_e436) / 24f))));
            let _e443 = sd;
            let _e447 = (*Tv);
            (*Tv) = (_e447 * exp((-(_e443) * 0.25f)));
            continue;
        } else {
            break;
        }
        continuing {
            let _e449 = i_2;
            i_2 = (_e449 + 1i);
        }
    }
    let _e451 = L;
    let _e454 = rp.reserved2_[2u];
    return (_e451 * _e454);
}

fn max3_u0028_vf3_u003b(v_2: ptr<function, vec3<f32>>) -> f32 {
    let _e334 = (*v_2)[0u];
    let _e336 = (*v_2)[1u];
    let _e338 = (*v_2)[2u];
    return max(_e334, max(_e336, _e338));
}

fn chroma_of_u0028_vf3_u003b(c_5: ptr<function, vec3<f32>>) -> vec3<f32> {
    var param_25: vec3<f32>;

    let _e334 = (*c_5);
    let _e335 = (*c_5);
    param_25 = _e335;
    let _e336 = max3_u0028_vf3_u003b((&param_25));
    return (_e334 / vec3(max(_e336, 0.001f)));
}

fn glossy_weigh_u0028_vf3_u003b_vf3_u003b_vf3_u003b_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_vf3_u003b(rc: ptr<function, vec3<f32>>, n: ptr<function, vec3<f32>>, d_2: ptr<function, vec3<f32>>, m: ptr<function, Material>, base: ptr<function, vec3<f32>>) -> vec3<f32> {
    var f0_: f32;
    var F: f32;
    var gloss: f32;
    var param_26: vec3<f32>;

    let _e343 = (*m).surface[2u];
    f0_ = mix(0.04f, 1f, _e343);
    let _e345 = f0_;
    let _e346 = f0_;
    let _e348 = (*d_2);
    let _e349 = (*n);
    F = (_e345 + ((1f - _e346) * pow((1f - clamp(-(dot(_e348, _e349)), 0f, 1f)), 5f)));
    let _e359 = (*m).surface[0u];
    let _e362 = (*m).surface[1u];
    let _e367 = (*m).sss[2u];
    let _e370 = (*m).sss[3u];
    gloss = max((_e359 * (1f - _e362)), (_e367 * (1f - _e370)));
    let _e374 = (*rc);
    let _e375 = F;
    let _e377 = gloss;
    let _e379 = (*base);
    param_26 = _e379;
    let _e380 = chroma_of_u0028_vf3_u003b((&param_26));
    let _e383 = (*m).surface[2u];
    return (((_e374 * _e375) * _e377) * mix(vec3<f32>(1f, 1f, 1f), _e380, vec3(_e383)));
}

fn bg_haze_u0028_vf3_u003b(hp: ptr<function, vec3<f32>>) -> vec4<f32> {
    var Lfar: vec3<f32>;
    var param_27: vec2<f32>;
    var param_28: f32;
    var open: f32;
    var k_1: i32;
    var a_3: f32;
    var c_6: vec2<i32>;
    var hazeCol: vec3<f32>;
    var param_29: vec2<f32>;

    let _e342 = (*hp);
    let _e344 = g_world;
    param_27 = clamp(_e342.xy, vec2<f32>(0f, 0f), _e344);
    param_28 = 160f;
    let _e346 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_27), (&param_28));
    Lfar = _e346;
    open = 0f;
    k_1 = 0i;
    loop {
        let _e347 = k_1;
        if (_e347 < 8i) {
            let _e349 = k_1;
            a_3 = (f32(_e349) * 0.785398f);
            let _e352 = (*hp);
            let _e354 = a_3;
            let _e356 = a_3;
            let _e362 = g_world;
            c_6 = clamp(vec2<i32>((_e352.xy + (vec2<f32>(cos(_e354), sin(_e356)) * 56f))), vec2<i32>(0i, 0i), (vec2<i32>(_e362) - vec2(1i)));
            let _e367 = c_6;
            let _e368 = textureLoad(bg, _e367, 0i);
            if (_e368.x == 0u) {
                let _e371 = open;
                open = (_e371 + 0.125f);
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e373 = k_1;
            k_1 = (_e373 + 1i);
        }
    }
    let _e375 = open;
    open = smoothstep(0.1f, 0.6f, _e375);
    let _e378 = rp.haze;
    let _e381 = Lfar;
    let _e385 = (*hp)[0u];
    let _e387 = (*hp)[1u];
    param_29 = vec2<f32>(_e385, (_e387 * 0.6f));
    let _e390 = sky_color_u0028_vf2_u003b((&param_29));
    let _e391 = open;
    hazeCol = mix(((_e378.xyz * 0.5f) + (_e381 * 0.2f)), _e390, vec3(_e391));
    let _e394 = hazeCol;
    let _e397 = rp.bgparams[3u];
    let _e400 = (*hp)[2u];
    return vec4<f32>(_e394.x, _e394.y, _e394.z, (1f - exp((-(_e397) * _e400))));
}

fn flame_radiance_u0028_f1_u003b(f_2: ptr<function, f32>) -> vec3<f32> {
    var t_2: f32;
    var c_7: vec3<f32>;

    let _e335 = (*f_2);
    if (_e335 <= 0.001f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e337 = (*f_2);
    t_2 = (1f - exp((-(_e337) * 0.9f)));
    let _e342 = t_2;
    c_7 = mix(vec3<f32>(0.9f, 0.12f, 0.02f), vec3<f32>(1f, 0.45f, 0.08f), vec3(smoothstep(0f, 0.5f, _e342)));
    let _e346 = c_7;
    let _e347 = t_2;
    c_7 = mix(_e346, vec3<f32>(1f, 0.86f, 0.55f), vec3(smoothstep(0.55f, 1f, _e347)));
    let _e351 = c_7;
    let _e352 = t_2;
    let _e356 = rp.medium[2u];
    return ((_e351 * _e352) * _e356);
}

fn flame_radiance_u0028_vf4_u003b(md: ptr<function, vec4<f32>>) -> vec3<f32> {
    var o: vec3<f32>;
    var param_30: f32;
    var h_2: f32;
    var t_3: f32;
    var blue: vec3<f32>;
    var white: vec3<f32>;
    var tinted: vec3<f32>;
    var w_1: f32;
    var local_1: f32;
    var phi_909_: bool;

    let _e343 = (*md)[2u];
    param_30 = _e343;
    let _e344 = flame_radiance_u0028_f1_u003b((&param_30));
    o = _e344;
    let _e346 = (*md)[2u];
    let _e347 = (_e346 <= 0.001f);
    phi_909_ = _e347;
    if !(_e347) {
        let _e350 = (*md)[3u];
        phi_909_ = (_e350 <= 0.001f);
    }
    let _e353 = phi_909_;
    if _e353 {
        let _e354 = o;
        return _e354;
    }
    let _e356 = (*md)[3u];
    let _e358 = (*md)[2u];
    h_2 = clamp((_e356 / _e358), 0f, 1f);
    let _e362 = (*md)[2u];
    t_3 = (1f - exp((-(_e362) * 0.9f)));
    let _e367 = t_3;
    let _e371 = rp.medium[2u];
    blue = (((vec3<f32>(0.15f, 0.35f, 1f) * _e367) * _e371) * 0.8f);
    let _e374 = t_3;
    let _e378 = rp.medium[2u];
    white = (((vec3<f32>(1f, 0.98f, 0.95f) * _e374) * _e378) * 3f);
    let _e381 = h_2;
    let _e383 = blue;
    let _e384 = white;
    tinted = select(_e384, _e383, vec3((_e381 < 0.75f)));
    let _e387 = h_2;
    if (_e387 < 0.75f) {
        let _e389 = h_2;
        local_1 = clamp((_e389 / 0.5f), 0f, 1f);
    } else {
        let _e392 = h_2;
        local_1 = clamp(((_e392 - 0.5f) / 0.5f), 0f, 1f);
    }
    let _e396 = local_1;
    w_1 = _e396;
    let _e397 = o;
    let _e398 = tinted;
    let _e399 = w_1;
    return mix(_e397, _e398, vec3(_e399));
}

fn diorama_bg_u0028_vf3_u003b_vf3_u003b_u1_u003b(col: ptr<function, vec3<f32>>, hp_1: ptr<function, vec3<f32>>, kind: ptr<function, u32>) -> vec3<f32> {
    var gap: f32;
    var sdir: vec2<f32>;
    var off: vec2<f32>;
    var o_1: vec4<f32>;
    var s_4: f32;
    var occ: f32;
    var local_2: f32;
    var sh: f32;
    var edge: f32;
    var contact: f32;
    var lit: bool;
    var shade: vec3<f32>;
    var l_1: f32;
    var param_31: vec3<f32>;
    var phi_2027_: bool;

    let _e351 = rp.look[1u];
    let _e352 = (_e351 <= 0f);
    phi_2027_ = _e352;
    if _e352 {
        let _e355 = rp.look[3u];
        phi_2027_ = (_e355 == 1f);
    }
    let _e358 = phi_2027_;
    if _e358 {
        let _e359 = (*col);
        return _e359;
    }
    let _e361 = (*hp_1)[2u];
    let _e362 = g_T0_;
    gap = max((_e361 - _e362), 0f);
    let _e366 = rp.look4_;
    sdir = normalize(mix(vec2<f32>(0.51449573f, 0.8574929f), normalize(_e366.zw), vec2(0.7f)));
    let _e372 = sdir;
    let _e373 = gap;
    let _e376 = rp.look[2u];
    off = (_e372 * min((3f + (_e373 * _e376)), 30f));
    let _e381 = (*hp_1);
    let _e383 = off;
    let _e385 = g_world;
    let _e387 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e381.xy - _e383) / _e385), 0f);
    o_1 = _e387;
    let _e388 = gap;
    let _e391 = rp.look[2u];
    s_4 = clamp(((3f + (_e388 * _e391)) / 16f), 0f, 1f);
    let _e396 = s_4;
    if (_e396 < 0.5f) {
        let _e399 = o_1[2u];
        let _e401 = o_1[2u];
        let _e402 = s_4;
        local_2 = mix(_e399, _e401, (_e402 * 2f));
    } else {
        let _e406 = o_1[2u];
        let _e408 = o_1[3u];
        let _e409 = s_4;
        local_2 = mix(_e406, _e408, ((_e409 * 2f) - 1f));
    }
    let _e413 = local_2;
    occ = _e413;
    let _e414 = occ;
    let _e418 = rp.look[1u];
    let _e420 = s_4;
    sh = ((smoothstep(0.15f, 0.85f, _e414) * _e418) * mix(1f, 0.6f, _e420));
    let _e423 = (*hp_1);
    let _e425 = g_world;
    let _e427 = textureSampleLevel(occ_tex, occ_tex_smp, (_e423.xy / _e425), 0f);
    edge = _e427.y;
    let _e429 = edge;
    contact = (0f * _e429);
    let _e431 = (*kind);
    let _e433 = (*kind);
    lit = ((_e431 == 7u) || (_e433 == 8u));
    let _e436 = sh;
    let _e439 = contact;
    let _e442 = rp.look[1u];
    shade = (mix(vec3<f32>(1f, 1f, 1f), vec3<f32>(0.42f, 0.46f, 0.6f), vec3(_e436)) * (1f - (_e439 * _e442)));
    let _e446 = lit;
    if _e446 {
        let _e447 = (*col);
        let _e448 = shade;
        return (_e447 * mix(vec3<f32>(1f, 1f, 1f), _e448, vec3(0.5f)));
    }
    let _e452 = (*col);
    param_31 = _e452;
    let _e453 = luminance_u0028_vf3_u003b((&param_31));
    l_1 = _e453;
    let _e454 = l_1;
    let _e456 = (*col);
    let _e462 = rp.look[3u];
    (*col) = ((mix(vec3(_e454), _e456, vec3(0.85f)) * vec3<f32>(0.95f, 0.98f, 1.06f)) * _e462);
    let _e464 = (*col);
    let _e465 = shade;
    return (_e464 * _e465);
}

fn ao_bg_u0028_vf3_u003b(hp_2: ptr<function, vec3<f32>>) -> f32 {
    var gap_1: f32;
    var r: f32;
    var occ_1: f32;
    var k_2: i32;
    var a_4: f32;
    var c_8: vec2<i32>;
    var param_32: vec2<i32>;
    var cov: f32;
    var local_3: f32;

    let _e343 = (*hp_2)[2u];
    let _e344 = g_T0_;
    gap_1 = max((_e343 - _e344), 0f);
    let _e347 = gap_1;
    r = (1.5f + (_e347 * 0.06f));
    occ_1 = 0f;
    k_2 = 0i;
    loop {
        let _e350 = k_2;
        if (_e350 < 8i) {
            let _e352 = k_2;
            a_4 = (f32(_e352) * 0.785398f);
            let _e355 = (*hp_2);
            let _e357 = a_4;
            let _e359 = a_4;
            let _e362 = r;
            c_8 = vec2<i32>(floor((_e355.xy + (vec2<f32>(cos(_e357), sin(_e359)) * _e362))));
            let _e367 = c_8;
            param_32 = _e367;
            let _e368 = inw_u0028_vi2_u003b((&param_32));
            if !(_e368) {
                continue;
            }
            let _e370 = c_8;
            let _e371 = textureLoad(l0s, _e370, 0i);
            cov = _e371.w;
            let _e373 = cov;
            if (_e373 >= 0.99f) {
                local_3 = 1f;
            } else {
                let _e375 = cov;
                local_3 = (_e375 * 0.5f);
            }
            let _e377 = local_3;
            let _e378 = occ_1;
            occ_1 = (_e378 + _e377);
            continue;
        } else {
            break;
        }
        continuing {
            let _e380 = k_2;
            k_2 = (_e380 + 1i);
        }
    }
    let _e382 = occ_1;
    let _e385 = gap_1;
    return (1f - ((0.6f * (_e382 / 8f)) * exp((-(_e385) / 50f))));
}

fn caustic_u0028_vf2_u003b_f1_u003b(p_3: ptr<function, vec2<f32>>, t_4: ptr<function, f32>) -> f32 {
    var q: vec2<f32>;
    var a_5: f32;
    var param_33: vec2<f32>;
    var b_2: f32;
    var param_34: vec2<f32>;
    var c_9: f32;

    let _e340 = (*p_3);
    q = (_e340 * 0.22f);
    let _e342 = q;
    let _e343 = (*t_4);
    let _e345 = (*t_4);
    param_33 = (_e342 + vec2<f32>((_e343 * 0.35f), (_e345 * 0.21f)));
    let _e349 = vnoise_u0028_vf2_u003b((&param_33));
    a_5 = _e349;
    let _e350 = q;
    let _e352 = (*t_4);
    let _e355 = (*t_4);
    let _e359 = a_5;
    param_34 = (((_e350 * 1.37f) + vec2<f32>((-(_e352) * 0.27f), (_e355 * 0.31f))) + vec2((_e359 * 1.7f)));
    let _e363 = vnoise_u0028_vf2_u003b((&param_34));
    b_2 = _e363;
    let _e364 = a_5;
    let _e365 = b_2;
    c_9 = (1f - (abs((_e364 - _e365)) * 3.2f));
    let _e370 = c_9;
    return (pow(max(_e370, 0f), 5f) * 1.6f);
}

fn layer0_filter_u0028_vf3_u003b_vf4_u003b(hp_3: ptr<function, vec3<f32>>, ld_1: ptr<function, vec4<f32>>) -> vec3<f32> {
    var sdir_1: vec3<f32>;
    var zc: f32;
    var t_5: f32;
    var P_1: vec2<f32>;
    var r_1: f32;
    var offs: array<vec2<f32>, 5>;
    var acc: vec3<f32>;
    var caus: f32;
    var k_3: i32;
    var c_10: vec2<i32>;
    var param_35: vec2<i32>;
    var s_5: vec4<f32>;
    var tr_1: vec4<f32>;
    var e: vec3<f32>;
    var f_3: vec3<f32>;
    var param_36: vec2<f32>;
    var param_37: f32;

    let _e351 = (*ld_1);
    let _e354 = (*ld_1)[2u];
    let _e356 = (_e351.xy * max(_e354, 0f));
    sdir_1 = normalize(vec3<f32>(_e356.x, _e356.y, -0.9f));
    let _e361 = g_T0_;
    zc = (_e361 * 0.5f);
    let _e363 = zc;
    let _e365 = (*hp_3)[2u];
    let _e368 = sdir_1[2u];
    t_5 = ((_e363 - _e365) / _e368);
    let _e370 = (*hp_3);
    let _e372 = sdir_1;
    let _e374 = t_5;
    P_1 = (_e370.xy + (_e372.xy * _e374));
    let _e378 = (*hp_3)[2u];
    let _e379 = zc;
    r_1 = (1f + ((_e378 - _e379) * 0.03f));
    let _e383 = r_1;
    let _e385 = r_1;
    let _e388 = r_1;
    let _e390 = r_1;
    offs = array<vec2<f32>, 5>(vec2<f32>(0f, 0f), vec2<f32>(_e383, 0f), vec2<f32>(-(_e385), 0f), vec2<f32>(0f, _e388), vec2<f32>(0f, -(_e390)));
    acc = vec3<f32>(0f, 0f, 0f);
    caus = 0f;
    k_3 = 0i;
    loop {
        let _e394 = k_3;
        if (_e394 < 5i) {
            let _e396 = P_1;
            let _e397 = k_3;
            let _e399 = offs[_e397];
            c_10 = vec2<i32>(floor((_e396 + _e399)));
            let _e403 = c_10;
            param_35 = _e403;
            let _e404 = inw_u0028_vi2_u003b((&param_35));
            if !(_e404) {
                let _e406 = acc;
                acc = (_e406 + vec3<f32>(1f, 1f, 1f));
                continue;
            }
            let _e408 = c_10;
            let _e409 = textureLoad(l0s, _e408, 0i);
            s_5 = _e409;
            let _e410 = c_10;
            let _e411 = textureLoad(l0t, _e410, 0i);
            tr_1 = _e411;
            let _e412 = c_10;
            let _e413 = textureLoad(emissive_img, _e412, 0i);
            e = _e413.xyz;
            let _e416 = e[0u];
            let _e418 = e[1u];
            let _e421 = e[2u];
            if (((_e416 + _e418) + _e421) > 0.15f) {
                let _e424 = acc;
                acc = (_e424 + vec3<f32>(1f, 1f, 1f));
                continue;
            }
            let _e427 = s_5[3u];
            if (_e427 >= 0.99f) {
                let _e429 = P_1;
                let _e430 = k_3;
                let _e432 = offs[_e430];
                let _e434 = g_world;
                let _e436 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e429 + _e432) / _e434), 0f);
                let _e441 = acc;
                acc = (_e441 + vec3((1f - smoothstep(0.25f, 0.8f, _e436.z))));
                continue;
            }
            let _e443 = tr_1;
            let _e445 = acc;
            acc = (_e445 + _e443.xyz);
            let _e448 = s_5[3u];
            if (abs((_e448 - 0.5f)) < 0.01f) {
                let _e452 = caus;
                caus = (_e452 + 1f);
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e454 = k_3;
            k_3 = (_e454 + 1i);
        }
    }
    let _e456 = acc;
    acc = (_e456 * 0.2f);
    let _e458 = caus;
    caus = (_e458 * 0.2f);
    let _e460 = acc;
    let _e462 = (*ld_1)[2u];
    f_3 = mix(vec3<f32>(1f, 1f, 1f), _e460, vec3((_e462 * 0.85f)));
    let _e466 = caus;
    let _e467 = P_1;
    param_36 = (_e467 * 1.3f);
    let _e469 = g_time;
    param_37 = _e469;
    let _e470 = caustic_u0028_vf2_u003b_f1_u003b((&param_36), (&param_37));
    let _e474 = (*ld_1)[2u];
    let _e477 = f_3;
    f_3 = (_e477 * (1f + (((_e466 * _e470) * 1.6f) * _e474)));
    let _e479 = f_3;
    return _e479;
}

fn light_dir3_u0028_vf4_u003b(ld_2: ptr<function, vec4<f32>>) -> vec3<f32> {
    let _e333 = (*ld_2);
    let _e336 = (*ld_2)[2u];
    let _e338 = (_e333.xy * max(_e336, 0.3f));
    return normalize(vec3<f32>(_e338.x, _e338.y, -0.55f));
}

fn ch_irradiance_u0028_vf3_u003b_vf4_u003b_vf4_u003b_vf2_u003b(a0_: ptr<function, vec3<f32>>, A: ptr<function, vec4<f32>>, B: ptr<function, vec4<f32>>, n_1: ptr<function, vec2<f32>>) -> vec3<f32> {
    var a1_: vec3<f32>;
    var b1_: vec3<f32>;
    var o1_: vec3<f32>;
    var l0_: f32;
    var o2_: f32;

    let _e341 = (*A);
    a1_ = _e341.xyz;
    let _e344 = (*A)[3u];
    let _e346 = (*B)[0u];
    let _e348 = (*B)[1u];
    b1_ = vec3<f32>(_e344, _e346, _e348);
    let _e350 = a1_;
    let _e352 = (*n_1)[0u];
    let _e354 = b1_;
    let _e356 = (*n_1)[1u];
    o1_ = (((_e350 * _e352) + (_e354 * _e356)) * 1.5707963f);
    let _e360 = (*a0_);
    l0_ = max(dot(_e360, vec3<f32>(0.2126f, 0.7152f, 0.0722f)), 0.00001f);
    let _e364 = (*B)[2u];
    let _e366 = (*n_1)[0u];
    let _e368 = (*n_1)[0u];
    let _e371 = (*n_1)[1u];
    let _e373 = (*n_1)[1u];
    let _e378 = (*B)[3u];
    let _e381 = (*n_1)[0u];
    let _e384 = (*n_1)[1u];
    o2_ = (((_e364 * ((_e366 * _e368) - (_e371 * _e373))) + (((_e378 * 2f) * _e381) * _e384)) * 0.6666667f);
    let _e388 = (*a0_);
    let _e390 = o1_;
    let _e392 = (*a0_);
    let _e393 = l0_;
    let _e396 = o2_;
    return max((((_e388 * 2f) + _e390) + ((_e392 / vec3(_e393)) * _e396)), vec3<f32>(0f, 0f, 0f));
}

fn ch_light_u0028_vf2_u003b_vf3_u003b(xy_5: ptr<function, vec2<f32>>, n_2: ptr<function, vec3<f32>>) -> vec3<f32> {
    var r_2: f32;
    var uv_2: vec2<f32>;
    var a0_1: vec3<f32>;
    var e_1: vec3<f32>;
    var param_38: vec3<f32>;
    var param_39: vec4<f32>;
    var param_40: vec4<f32>;
    var param_41: vec2<f32>;
    var ratio: vec3<f32>;
    var w_2: f32;
    var param_42: vec3<f32>;
    var phi_1507_: bool;

    let _e345 = (*n_2);
    r_2 = length(_e345.xy);
    let _e348 = r_2;
    let _e349 = (_e348 < 0.001f);
    phi_1507_ = _e349;
    if !(_e349) {
        let _e353 = rp.day[3u];
        phi_1507_ = (_e353 <= 0f);
    }
    let _e356 = phi_1507_;
    if _e356 {
        return vec3<f32>(1f, 1f, 1f);
    }
    let _e357 = (*xy_5);
    let _e358 = g_world;
    let _e362 = g_world;
    uv_2 = (clamp(_e357, vec2<f32>(0.5f, 0.5f), (_e358 - vec2(0.5f))) / _e362);
    let _e364 = uv_2;
    let _e365 = textureSampleLevel(fl0_, fl0_smp, _e364, 0f);
    a0_1 = _e365.xyz;
    let _e367 = uv_2;
    let _e368 = textureSampleLevel(cha_tex, cha_tex_smp, _e367, 0f);
    let _e369 = uv_2;
    let _e370 = textureSampleLevel(chb_tex, chb_tex_smp, _e369, 0f);
    let _e371 = (*n_2);
    let _e373 = r_2;
    let _e376 = a0_1;
    param_38 = _e376;
    param_39 = _e368;
    param_40 = _e370;
    param_41 = (_e371.xy / vec2(_e373));
    let _e377 = ch_irradiance_u0028_vf3_u003b_vf4_u003b_vf4_u003b_vf2_u003b((&param_38), (&param_39), (&param_40), (&param_41));
    e_1 = _e377;
    let _e378 = e_1;
    let _e379 = a0_1;
    ratio = clamp((_e378 / max((_e379 * 2f), vec3<f32>(0.0001f, 0.0001f, 0.0001f))), vec3<f32>(0f, 0f, 0f), vec3<f32>(3.2f, 3.2f, 3.2f));
    let _e384 = r_2;
    let _e387 = rp.day[3u];
    let _e389 = a0_1;
    param_42 = _e389;
    let _e390 = luminance_u0028_vf3_u003b((&param_42));
    w_2 = ((_e384 * _e387) * smoothstep(0.002f, 0.02f, _e390));
    let _e393 = ratio;
    let _e394 = w_2;
    return mix(vec3<f32>(1f, 1f, 1f), _e393, vec3(_e394));
}

fn face_n3_u0028_i1_u003b(face: ptr<function, i32>) -> vec3<f32> {
    let _e333 = (*face);
    if (_e333 == 1i) {
        return vec3<f32>(0f, -1f, 0f);
    }
    let _e335 = (*face);
    if (_e335 == 2i) {
        return vec3<f32>(0f, 1f, 0f);
    }
    let _e337 = (*face);
    if (_e337 == 3i) {
        return vec3<f32>(-1f, 0f, 0f);
    }
    let _e339 = (*face);
    if (_e339 == 4i) {
        return vec3<f32>(1f, 0f, 0f);
    }
    let _e341 = (*face);
    if (_e341 == 5i) {
        return vec3<f32>(0f, 0f, 1f);
    }
    return vec3<f32>(0f, 0f, -1f);
}

fn bg_albedo_u0028_u1_u003b_vf2_u003b_u1_u003b(kind_1: ptr<function, u32>, uv_3: ptr<function, vec2<f32>>, detail: ptr<function, u32>) -> vec3<f32> {
    var c_11: vec2<f32>;
    var n_3: f32;
    var param_43: vec2<f32>;
    var tile: vec2<f32>;
    var tp: vec2<f32>;
    var f_4: vec2<f32>;
    var mortar: f32;
    var tileVar: f32;
    var param_44: vec2<f32>;
    var base_1: vec3<f32>;
    var b_3: vec3<f32>;
    var plank: f32;
    var param_45: vec2<f32>;
    var w_3: vec3<f32>;
    var band: f32;
    var seam: f32;
    var rn: f32;
    var param_46: vec2<f32>;
    var rock: vec3<f32>;
    var local_4: vec3<f32>;

    let _e355 = (*uv_3);
    c_11 = (floor(_e355) + vec2(0.5f));
    let _e359 = c_11;
    let _e361 = (*kind_1);
    param_43 = ((_e359 * 1.37f) + vec2((f32(_e361) * 17f)));
    let _e366 = hash21_u0028_vf2_u003b((&param_43));
    n_3 = _e366;
    let _e367 = (*kind_1);
    if (_e367 == 2u) {
        tile = vec2<f32>(12f, 6f);
        let _e369 = c_11;
        let _e370 = tile;
        tp = (_e369 / _e370);
        let _e373 = tp[1u];
        let _e377 = tp[0u];
        tp[0u] = (_e377 + (floor(_e373) * 0.5f));
        let _e380 = tp;
        f_4 = fract(_e380);
        let _e383 = f_4[0u];
        let _e385 = tile[0u];
        let _e389 = f_4[1u];
        let _e391 = tile[1u];
        mortar = (step(_e383, (1f / _e385)) + step(_e389, (1f / _e391)));
        let _e395 = tp;
        param_44 = floor(_e395);
        let _e397 = hash21_u0028_vf2_u003b((&param_44));
        tileVar = (_e397 * 0.14f);
        let _e399 = (*detail);
        base_1 = select(vec3<f32>(0.31f, 0.29f, 0.29f), vec3<f32>(0.34f, 0.27f, 0.24f), vec3((_e399 == 1u)));
        let _e403 = base_1;
        let _e404 = tileVar;
        let _e406 = n_3;
        b_3 = (_e403 * ((0.9f + _e404) + ((_e406 - 0.5f) * 0.1f)));
        let _e411 = b_3;
        let _e412 = mortar;
        return mix(_e411, vec3<f32>(0.15f, 0.15f, 0.16f), vec3(clamp(_e412, 0f, 1f)));
    }
    let _e416 = (*kind_1);
    if (_e416 == 4u) {
        let _e419 = c_11[1u];
        let _e423 = (*detail);
        param_45 = (vec2<f32>(0f, floor((_e419 / 3f))) + vec2(f32(_e423)));
        let _e427 = hash21_u0028_vf2_u003b((&param_45));
        plank = _e427;
        let _e428 = plank;
        let _e432 = n_3;
        w_3 = ((vec3<f32>(0.36f, 0.23f, 0.13f) * (0.75f + (0.35f * _e428))) * (0.92f + (0.16f * _e432)));
        let _e436 = (*detail);
        if (_e436 == 1u) {
            let _e438 = w_3;
            w_3 = (_e438 * 0.55f);
        }
        let _e440 = w_3;
        return _e440;
    }
    let _e441 = (*kind_1);
    if (_e441 == 5u) {
        let _e444 = c_11[1u];
        band = (0.85f + (0.25f * step(0.5f, fract((_e444 * 0.5f)))));
        let _e450 = band;
        let _e452 = n_3;
        return ((vec3<f32>(0.4f, 0.42f, 0.46f) * _e450) * (0.94f + (0.12f * _e452)));
    }
    let _e456 = (*kind_1);
    if (_e456 == 6u) {
        let _e459 = c_11[0u];
        seam = step(fract((_e459 / 24f)), 0.041666668f);
        let _e463 = n_3;
        let _e467 = seam;
        return mix((vec3<f32>(0.36f, 0.35f, 0.33f) * (0.9f + (0.2f * _e463))), vec3<f32>(0.24f, 0.24f, 0.24f), vec3(_e467));
    }
    let _e470 = (*kind_1);
    if (_e470 == 8u) {
        return vec3<f32>(0.35f, 0.85f, 0.9f);
    }
    let _e472 = (*kind_1);
    let _e474 = (*detail);
    if ((_e472 == 3u) && (_e474 == 4u)) {
        let _e477 = n_3;
        return (vec3<f32>(0.07f, 0.12f, 0.1f) * (0.9f + (0.2f * _e477)));
    }
    let _e481 = c_11;
    param_46 = (_e481 * vec2<f32>(0.12f, 0.18f));
    let _e483 = fbm_u0028_vf2_u003b((&param_46));
    rn = _e483;
    let _e484 = rn;
    let _e487 = n_3;
    rock = (mix(vec3<f32>(0.2f, 0.18f, 0.165f), vec3<f32>(0.28f, 0.25f, 0.22f), vec3(_e484)) * (0.85f + (0.3f * _e487)));
    let _e491 = (*kind_1);
    if (_e491 == 3u) {
        let _e493 = rock;
        local_4 = (_e493 * 0.55f);
    } else {
        let _e495 = rock;
        local_4 = _e495;
    }
    let _e496 = local_4;
    return _e496;
}

fn shade_bg_u0028_vu4_u003b_i1_u003b_vf3_u003b_vf3_u003b_b1_u003b(b_4: ptr<function, vec4<u32>>, face_1: ptr<function, i32>, n_4: ptr<function, vec3<f32>>, hp_4: ptr<function, vec3<f32>>, relief: ptr<function, bool>) -> vec3<f32> {
    var uv_4: vec2<f32>;
    var local_5: vec2<f32>;
    var local_6: vec2<f32>;
    var alb: vec3<f32>;
    var param_47: u32;
    var param_48: vec2<f32>;
    var param_49: u32;
    var lp: vec2<f32>;
    var local_7: vec2<f32>;
    var local_8: vec2<f32>;
    var param_50: i32;
    var F_1: vec3<f32>;
    var local_9: vec2<f32>;
    var param_51: vec2<f32>;
    var param_52: f32;
    var fall: f32;
    var up: f32;
    var down: f32;
    var side: f32;
    var fk: f32;
    var local_10: f32;
    var local_11: f32;
    var local_12: f32;
    var local_13: f32;
    var ld_3: vec4<f32>;
    var param_53: vec2<f32>;
    var lam: vec3<f32>;
    var local_14: vec3<f32>;
    var param_54: vec2<f32>;
    var param_55: vec3<f32>;
    var param_56: vec4<f32>;
    var trans: vec3<f32>;
    var param_57: vec3<f32>;
    var param_58: vec4<f32>;
    var ao: f32;
    var param_59: vec3<f32>;
    var amb: vec3<f32>;
    var col_1: vec3<f32>;
    var amb_1: vec3<f32>;
    var local_15: vec3<f32>;
    var L_1: vec3<f32>;
    var h_3: vec3<f32>;
    var param_60: vec4<f32>;
    var param_61: vec2<f32>;
    var param_62: vec2<f32>;
    var param_63: vec3<f32>;
    var param_64: vec3<f32>;
    var param_65: u32;

    let _e385 = (*relief);
    let _e386 = (*face_1);
    if (_e385 || (_e386 == 0i)) {
        let _e389 = (*hp_4);
        local_5 = _e389.xy;
    } else {
        let _e391 = (*face_1);
        let _e393 = (*face_1);
        if ((_e391 == 1i) || (_e393 == 2i)) {
            let _e397 = (*hp_4)[0u];
            let _e399 = (*hp_4)[2u];
            local_6 = vec2<f32>(_e397, _e399);
        } else {
            let _e402 = (*hp_4)[2u];
            let _e404 = (*hp_4)[1u];
            local_6 = vec2<f32>(_e402, _e404);
        }
        let _e406 = local_6;
        local_5 = _e406;
    }
    let _e407 = local_5;
    uv_4 = _e407;
    let _e409 = (*b_4)[0u];
    param_47 = _e409;
    let _e410 = uv_4;
    param_48 = _e410;
    let _e412 = (*b_4)[2u];
    param_49 = _e412;
    let _e413 = bg_albedo_u0028_u1_u003b_vf2_u003b_u1_u003b((&param_47), (&param_48), (&param_49));
    alb = _e413;
    let _e414 = (*relief);
    if _e414 {
        let _e415 = (*hp_4);
        let _e417 = (*n_4);
        local_7 = (_e415.xy + (_e417.xy * 2f));
    } else {
        let _e421 = (*face_1);
        if (_e421 == 0i) {
            let _e423 = (*hp_4);
            local_8 = _e423.xy;
        } else {
            let _e425 = (*hp_4);
            let _e427 = (*face_1);
            param_50 = _e427;
            let _e428 = face_n3_u0028_i1_u003b((&param_50));
            local_8 = (_e425.xy + (_e428.xy * 2f));
        }
        let _e432 = local_8;
        local_7 = _e432;
    }
    let _e433 = local_7;
    lp = _e433;
    let _e434 = (*relief);
    if _e434 {
        let _e435 = lp;
        let _e436 = g_world;
        local_9 = clamp(_e435, vec2<f32>(0.5f, 0.5f), (_e436 - vec2(0.5f)));
    } else {
        let _e440 = lp;
        local_9 = _e440;
    }
    let _e441 = local_9;
    param_51 = _e441;
    let _e443 = (*hp_4)[2u];
    param_52 = _e443;
    let _e444 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_51), (&param_52));
    F_1 = _e444;
    let _e446 = (*hp_4)[2u];
    fall = (1f / (1f + (_e446 * 0.012f)));
    let _e451 = (*n_4)[1u];
    up = max(-(_e451), 0f);
    let _e455 = (*n_4)[1u];
    down = max(_e455, 0f);
    let _e458 = (*n_4)[0u];
    side = abs(_e458);
    let _e460 = (*relief);
    if _e460 {
        let _e461 = up;
        let _e464 = down;
        let _e469 = rp.view[2u];
        let _e471 = side;
        local_10 = (((1f + (0.15f * _e461)) - (0.5f * _e464)) - ((0.9f - _e469) * _e471));
    } else {
        let _e474 = (*face_1);
        if (_e474 == 0i) {
            local_11 = 1f;
        } else {
            let _e476 = (*face_1);
            if (_e476 == 1i) {
                local_12 = 1.15f;
            } else {
                let _e478 = (*face_1);
                if (_e478 == 2i) {
                    local_13 = 0.5f;
                } else {
                    let _e482 = rp.view[2u];
                    local_13 = (_e482 + 0.1f);
                }
                let _e484 = local_13;
                local_12 = _e484;
            }
            let _e485 = local_12;
            local_11 = _e485;
        }
        let _e486 = local_11;
        local_10 = _e486;
    }
    let _e487 = local_10;
    fk = _e487;
    let _e488 = lp;
    let _e489 = g_world;
    param_53 = clamp(_e488, vec2<f32>(0.5f, 0.5f), (_e489 - vec2(0.5f)));
    let _e493 = light_at_u0028_vf2_u003b((&param_53));
    ld_3 = _e493;
    lam = vec3<f32>(1f, 1f, 1f);
    let _e494 = (*relief);
    if _e494 {
        let _e497 = rp.day[3u];
        if (_e497 > 0f) {
            let _e499 = lp;
            param_54 = _e499;
            let _e500 = (*n_4);
            param_55 = _e500;
            let _e501 = ch_light_u0028_vf2_u003b_vf3_u003b((&param_54), (&param_55));
            local_14 = (vec3(0.8f) + (_e501 * 0.2f));
        } else {
            let _e505 = (*n_4);
            let _e506 = ld_3;
            param_56 = _e506;
            let _e507 = light_dir3_u0028_vf4_u003b((&param_56));
            let _e511 = ld_3[2u];
            local_14 = vec3((0.8f + ((0.4f * dot(_e505, _e507)) * _e511)));
        }
        let _e515 = local_14;
        lam = _e515;
    }
    let _e516 = (*hp_4);
    param_57 = _e516;
    let _e517 = ld_3;
    param_58 = _e517;
    let _e518 = layer0_filter_u0028_vf3_u003b_vf4_u003b((&param_57), (&param_58));
    trans = _e518;
    let _e519 = (*hp_4);
    param_59 = _e519;
    let _e520 = ao_bg_u0028_vf3_u003b((&param_59));
    ao = _e520;
    let _e521 = (*relief);
    if _e521 {
        let _e523 = rp.ambient;
        let _e525 = up;
        let _e529 = down;
        amb = ((_e523.xyz * mix(vec3<f32>(1f, 1f, 1f), vec3<f32>(0.95f, 1.05f, 1.25f), vec3(_e525))) * (1f - (0.4f * _e529)));
        let _e533 = alb;
        let _e534 = F_1;
        let _e538 = rp.ambient[3u];
        let _e540 = fall;
        let _e542 = fk;
        let _e544 = lam;
        let _e546 = trans;
        let _e548 = amb;
        let _e551 = ao;
        col_1 = ((_e533 * (((((((_e534 * 2f) * _e538) * _e540) * _e542) * _e544) * _e546) + _e548)) * _e551);
    } else {
        let _e554 = rp.ambient;
        let _e556 = (*face_1);
        if (_e556 == 1i) {
            local_15 = vec3<f32>(0.95f, 1.05f, 1.25f);
        } else {
            let _e558 = (*face_1);
            local_15 = select(vec3<f32>(1f, 1f, 1f), vec3<f32>(0.66f, 0.54f, 0.42f), vec3((_e558 == 2i)));
        }
        let _e562 = local_15;
        amb_1 = (_e554.xyz * _e562);
        let _e564 = F_1;
        let _e568 = rp.ambient[3u];
        let _e570 = fall;
        let _e572 = fk;
        let _e574 = trans;
        let _e576 = amb_1;
        let _e578 = ao;
        L_1 = (((((((_e564 * 2f) * _e568) * _e570) * _e572) * _e574) + _e576) * _e578);
        let _e580 = alb;
        let _e581 = L_1;
        col_1 = (_e580 * _e581);
    }
    let _e584 = (*b_4)[0u];
    if (_e584 == 5u) {
        let _e586 = ld_3;
        param_60 = _e586;
        let _e587 = light_dir3_u0028_vf4_u003b((&param_60));
        h_3 = normalize((_e587 + vec3<f32>(0f, 0f, -1f)));
        let _e590 = F_1;
        let _e592 = fall;
        let _e594 = trans;
        let _e596 = (*n_4);
        let _e597 = h_3;
        let _e603 = col_1;
        col_1 = (_e603 + (((((_e590 * 2f) * _e592) * _e594) * pow(max(dot(_e596, _e597), 0f), 40f)) * 2f));
    }
    let _e606 = (*b_4)[0u];
    if (_e606 == 7u) {
        let _e609 = (*hp_4)[0u];
        let _e611 = (*hp_4)[1u];
        param_61 = vec2<f32>(_e609, (_e611 * 0.5f));
        let _e614 = sky_color_u0028_vf2_u003b((&param_61));
        col_1 = ((_e614 * 0.85f) + vec3<f32>(0.04f, 0.04f, 0.04f));
    }
    let _e618 = (*b_4)[0u];
    if (_e618 == 8u) {
        let _e620 = (*hp_4);
        param_62 = floor(_e620.xy);
        let _e623 = hash21_u0028_vf2_u003b((&param_62));
        let _e627 = col_1;
        col_1 = (_e627 + (vec3<f32>(0.25f, 0.85f, 1f) * (1f + (0.5f * _e623))));
    }
    let _e629 = col_1;
    param_63 = _e629;
    let _e630 = (*hp_4);
    param_64 = _e630;
    let _e632 = (*b_4)[0u];
    param_65 = _e632;
    let _e633 = diorama_bg_u0028_vf3_u003b_vf3_u003b_u1_u003b((&param_63), (&param_64), (&param_65));
    return _e633;
}

fn bg_field_u0028_vf2_u003b(xy_6: ptr<function, vec2<f32>>) -> vec2<f32> {
    let _e333 = (*xy_6);
    let _e334 = g_world;
    let _e336 = textureSampleLevel(bgsm_tex, bgsm_tex_smp, (_e333 / _e334), 0f);
    return _e336.xy;
}

fn bg_zs_u0028_vf2_u003b(xy_7: ptr<function, vec2<f32>>) -> f32 {
    var f_5: vec2<f32>;
    var param_66: vec2<f32>;
    var local_16: f32;

    let _e336 = (*xy_7);
    param_66 = _e336;
    let _e337 = bg_field_u0028_vf2_u003b((&param_66));
    f_5 = _e337;
    let _e339 = f_5[1u];
    if (_e339 > 0.5f) {
        let _e343 = rp.bgparams[0u];
        let _e345 = f_5[0u];
        let _e348 = rp.bgparams[1u];
        let _e351 = rp.bgparams[0u];
        let _e356 = rp.bgparams[2u];
        local_16 = (_e343 + ((_e345 * (_e348 - _e351)) * _e356));
    } else {
        local_16 = 1000000000f;
    }
    let _e359 = local_16;
    return _e359;
}

fn bg_normal_u0028_vf2_u003b(xy_8: ptr<function, vec2<f32>>) -> vec3<f32> {
    var zx: f32;
    var param_67: vec2<f32>;
    var param_68: vec2<f32>;
    var zy: f32;
    var param_69: vec2<f32>;
    var param_70: vec2<f32>;

    let _e339 = (*xy_8);
    param_67 = (_e339 + vec2<f32>(0.8f, 0f));
    let _e341 = bg_zs_u0028_vf2_u003b((&param_67));
    let _e342 = (*xy_8);
    param_68 = (_e342 - vec2<f32>(0.8f, 0f));
    let _e344 = bg_zs_u0028_vf2_u003b((&param_68));
    zx = (_e341 - _e344);
    let _e346 = (*xy_8);
    param_69 = (_e346 + vec2<f32>(0f, 0.8f));
    let _e348 = bg_zs_u0028_vf2_u003b((&param_69));
    let _e349 = (*xy_8);
    param_70 = (_e349 - vec2<f32>(0f, 0.8f));
    let _e351 = bg_zs_u0028_vf2_u003b((&param_70));
    zy = (_e348 - _e351);
    let _e353 = zx;
    zx = clamp(_e353, -40f, 40f);
    let _e355 = zy;
    zy = clamp(_e355, -40f, 40f);
    let _e357 = zx;
    let _e359 = zy;
    return normalize(vec3<f32>((_e357 / 1.6f), (_e359 / 1.6f), -1f));
}

fn cell_shade_at_u0028_vi2_u003b(q_1: ptr<function, vec2<i32>>) -> vec4<f32> {
    let _e333 = (*q_1);
    let _e334 = textureLoad(cell_shade, _e333, 0i);
    return _e334;
}

fn dda_step_u0028_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b_f1_u003b_i1_u003b(cell: ptr<function, vec2<i32>>, stp: ptr<function, vec2<i32>>, tDelta: ptr<function, vec2<f32>>, tMax: ptr<function, vec2<f32>>, tCur: ptr<function, f32>, face_2: ptr<function, i32>) {
    let _e339 = (*tMax)[0u];
    let _e341 = (*tMax)[1u];
    if (_e339 < _e341) {
        let _e344 = (*stp)[0u];
        let _e346 = (*cell)[0u];
        (*cell)[0u] = (_e346 + _e344);
        let _e350 = (*tMax)[0u];
        (*tCur) = _e350;
        let _e352 = (*tDelta)[0u];
        let _e354 = (*tMax)[0u];
        (*tMax)[0u] = (_e354 + _e352);
        let _e358 = (*stp)[0u];
        (*face_2) = select(4i, 3i, (_e358 > 0i));
    } else {
        let _e362 = (*stp)[1u];
        let _e364 = (*cell)[1u];
        (*cell)[1u] = (_e364 + _e362);
        let _e368 = (*tMax)[1u];
        (*tCur) = _e368;
        let _e370 = (*tDelta)[1u];
        let _e372 = (*tMax)[1u];
        (*tMax)[1u] = (_e372 + _e370);
        let _e376 = (*stp)[1u];
        (*face_2) = select(2i, 1i, (_e376 > 0i));
    }
    return;
}

fn bg_depth_u0028_u1_u003b(d_3: ptr<function, u32>) -> f32 {
    let _e335 = rp.bgparams[0u];
    let _e336 = (*d_3);
    let _e341 = rp.bgparams[1u];
    let _e344 = rp.bgparams[0u];
    let _e349 = rp.bgparams[2u];
    return (_e335 + (((f32(_e336) / 255f) * (_e341 - _e344)) * _e349));
}

fn mirror_cell_u0028_vi2_u003b(c_12: ptr<function, vec2<i32>>) -> vec2<i32> {
    let _e333 = (*c_12);
    let _e334 = g_world;
    return clamp(_e333, vec2<i32>(0i, 0i), (vec2<i32>(_e334) - vec2(1i)));
}

fn dda_init_cell_u0028_vf2_u003b_vf2_u003b_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b(pos_1: ptr<function, vec2<f32>>, dxy: ptr<function, vec2<f32>>, cell_1: ptr<function, vec2<i32>>, stp_1: ptr<function, vec2<i32>>, tDelta_1: ptr<function, vec2<f32>>, tMax_1: ptr<function, vec2<f32>>) {
    var local_17: f32;
    var local_18: f32;
    var local_19: f32;
    var local_20: f32;
    var local_21: f32;
    var local_22: f32;

    let _e344 = (*dxy);
    (*stp_1) = vec2<i32>(sign(_e344));
    let _e348 = (*dxy)[0u];
    if (abs(_e348) > 0.0000001f) {
        let _e352 = (*dxy)[0u];
        local_17 = abs((1f / _e352));
    } else {
        local_17 = 1000000000000000000000000000000f;
    }
    let _e355 = local_17;
    let _e357 = (*dxy)[1u];
    if (abs(_e357) > 0.0000001f) {
        let _e361 = (*dxy)[1u];
        local_18 = abs((1f / _e361));
    } else {
        local_18 = 1000000000000000000000000000000f;
    }
    let _e364 = local_18;
    (*tDelta_1) = vec2<f32>(_e355, _e364);
    let _e367 = (*dxy)[0u];
    if (_e367 > 0f) {
        let _e370 = (*cell_1)[0u];
        let _e374 = (*pos_1)[0u];
        let _e378 = (*tDelta_1)[0u];
        local_19 = (max(((f32(_e370) + 1f) - _e374), 0f) * _e378);
    } else {
        let _e381 = (*dxy)[0u];
        if (_e381 < 0f) {
            let _e384 = (*pos_1)[0u];
            let _e386 = (*cell_1)[0u];
            let _e391 = (*tDelta_1)[0u];
            local_20 = (max((_e384 - f32(_e386)), 0f) * _e391);
        } else {
            local_20 = 1000000000000000000000000000000f;
        }
        let _e393 = local_20;
        local_19 = _e393;
    }
    let _e394 = local_19;
    (*tMax_1)[0u] = _e394;
    let _e397 = (*dxy)[1u];
    if (_e397 > 0f) {
        let _e400 = (*cell_1)[1u];
        let _e404 = (*pos_1)[1u];
        let _e408 = (*tDelta_1)[1u];
        local_21 = (max(((f32(_e400) + 1f) - _e404), 0f) * _e408);
    } else {
        let _e411 = (*dxy)[1u];
        if (_e411 < 0f) {
            let _e414 = (*pos_1)[1u];
            let _e416 = (*cell_1)[1u];
            let _e421 = (*tDelta_1)[1u];
            local_22 = (max((_e414 - f32(_e416)), 0f) * _e421);
        } else {
            local_22 = 1000000000000000000000000000000f;
        }
        let _e423 = local_22;
        local_21 = _e423;
    }
    let _e424 = local_21;
    (*tMax_1)[1u] = _e424;
    return;
}

fn trace_bg_u0028_vf3_u003b_vf3_u003b_vf2_u003b(o_2: ptr<function, vec3<f32>>, d_4: ptr<function, vec3<f32>>, distort: ptr<function, vec2<f32>>) -> vec3<f32> {
    var zNear: f32;
    var zFar: f32;
    var qs: vec3<f32>;
    var q_2: vec3<f32>;
    var cell_2: vec2<i32>;
    var stp_2: vec2<i32>;
    var tDelta_2: vec2<f32>;
    var tMax_2: vec2<f32>;
    var param_71: vec2<f32>;
    var param_72: vec2<f32>;
    var param_73: vec2<i32>;
    var param_74: vec2<i32>;
    var param_75: vec2<f32>;
    var param_76: vec2<f32>;
    var tCur_1: f32;
    var face_3: i32;
    var result: i32;
    var hp_5: vec3<f32>;
    var hb: vec4<u32>;
    var pixelLayer: bool;
    var cellHaze: bool;
    var cellAt: vec2<i32>;
    var c0_: vec2<i32>;
    var b_5: vec4<u32>;
    var param_77: vec2<i32>;
    var c_13: vec2<i32>;
    var param_78: u32;
    var param_79: vec2<i32>;
    var param_80: u32;
    var param_81: vec2<i32>;
    var param_82: u32;
    var param_83: vec2<i32>;
    var i_3: i32;
    var zIn: f32;
    var tNext: f32;
    var tSeg: f32;
    var tPrev: f32;
    var hit: bool;
    var k_4: i32;
    var t_6: f32;
    var qq: vec3<f32>;
    var param_84: vec2<f32>;
    var a_6: f32;
    var bb: f32;
    var j: i32;
    var m_1: f32;
    var qm: vec3<f32>;
    var param_85: vec2<f32>;
    var param_86: vec2<i32>;
    var k_5: i32;
    var o4_: vec2<i32>;
    var local_23: i32;
    var local_24: i32;
    var param_87: vec2<i32>;
    var param_88: vec2<i32>;
    var param_89: vec2<i32>;
    var param_90: vec2<f32>;
    var param_91: vec2<f32>;
    var param_92: f32;
    var param_93: i32;
    var b_6: vec4<u32>;
    var param_94: vec2<i32>;
    var zs: f32;
    var param_95: u32;
    var param_96: vec2<i32>;
    var param_97: vec2<i32>;
    var param_98: vec2<f32>;
    var param_99: vec2<f32>;
    var param_100: f32;
    var param_101: i32;
    var local_25: f32;
    var sp: vec3<f32>;
    var param_102: vec2<f32>;
    var col_2: vec3<f32>;
    var local_26: vec3<f32>;
    var param_103: vec2<i32>;
    var local_27: vec3<f32>;
    var param_104: vec2<f32>;
    var param_105: i32;
    var param_106: vec4<u32>;
    var param_107: i32;
    var param_108: vec3<f32>;
    var param_109: vec3<f32>;
    var param_110: bool;
    var zh: f32;
    var mid: vec3<f32>;
    var md_1: vec4<f32>;
    var gap_2: f32;
    var tauSoot: f32;
    var tauSteam: f32;
    var Tf: f32;
    var Lm: vec3<f32>;
    var param_111: vec2<f32>;
    var param_112: f32;
    var inscatter: vec3<f32>;
    var param_113: vec4<f32>;
    var beam_1: vec3<f32>;
    var k_6: i32;
    var sp_1: vec3<f32>;
    var f_6: vec3<f32>;
    var param_114: vec2<f32>;
    var param_115: f32;
    var param_116: vec3<f32>;
    var dz: f32;
    var hz: vec4<f32>;
    var local_28: vec4<f32>;
    var param_117: vec2<i32>;
    var param_118: vec3<f32>;
    var phi_3818_: bool;
    var phi_3866_: bool;
    var phi_3994_: bool;

    let _e445 = rp.bgparams[0u];
    zNear = _e445;
    let _e448 = rp.bgparams[0u];
    let _e451 = rp.bgparams[1u];
    let _e454 = rp.bgparams[0u];
    let _e458 = rp.bgparams[2u];
    zFar = (_e448 + ((_e451 - _e454) * _e458));
    let _e461 = (*o_2);
    qs = _e461;
    let _e462 = (*o_2);
    q_2 = _e462;
    let _e463 = (*distort);
    let _e464 = q_2;
    let _e466 = (_e464.xy + _e463);
    q_2[0u] = _e466.x;
    q_2[1u] = _e466.y;
    let _e471 = (*d_4);
    let _e472 = zNear;
    let _e474 = q_2[2u];
    let _e477 = (*d_4)[2u];
    let _e480 = q_2;
    q_2 = (_e480 + (_e471 * ((_e472 - _e474) / _e477)));
    let _e482 = q_2;
    cell_2 = vec2<i32>(floor(_e482.xy));
    let _e486 = q_2;
    param_71 = _e486.xy;
    let _e488 = (*d_4);
    param_72 = _e488.xy;
    let _e490 = cell_2;
    param_73 = _e490;
    dda_init_cell_u0028_vf2_u003b_vf2_u003b_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b((&param_71), (&param_72), (&param_73), (&param_74), (&param_75), (&param_76));
    let _e491 = param_74;
    stp_2 = _e491;
    let _e492 = param_75;
    tDelta_2 = _e492;
    let _e493 = param_76;
    tMax_2 = _e493;
    tCur_1 = 0f;
    face_3 = 0i;
    result = 0i;
    let _e494 = q_2;
    hp_5 = _e494;
    hb = vec4<u32>(0u, 0u, 0u, 0u);
    let _e497 = rp.look2_[3u];
    let _e499 = g_T0_;
    pixelLayer = ((_e497 > 0f) && (_e499 < 0.01f));
    cellHaze = false;
    cellAt = vec2<i32>(0i, 0i);
    let _e502 = pixelLayer;
    if _e502 {
        let _e503 = (*o_2);
        let _e505 = (*distort);
        c0_ = vec2<i32>(floor((_e503.xy + _e505)));
        let _e509 = c0_;
        param_77 = _e509;
        let _e510 = mirror_cell_u0028_vi2_u003b((&param_77));
        let _e511 = textureLoad(bg, _e510, 0i);
        b_5 = _e511;
        let _e512 = c0_;
        let _e514 = rp.look2_;
        let _e517 = b_5[1u];
        param_78 = _e517;
        let _e518 = bg_depth_u0028_u1_u003b((&param_78));
        c_13 = (_e512 + vec2<i32>(round((_e514.xy * _e518))));
        let _e523 = c_13;
        param_79 = _e523;
        let _e524 = mirror_cell_u0028_vi2_u003b((&param_79));
        let _e525 = textureLoad(bg, _e524, 0i);
        b_5 = _e525;
        let _e526 = c0_;
        let _e528 = rp.look2_;
        let _e531 = b_5[1u];
        param_80 = _e531;
        let _e532 = bg_depth_u0028_u1_u003b((&param_80));
        c_13 = (_e526 + vec2<i32>(round((_e528.xy * _e532))));
        let _e537 = c_13;
        param_81 = _e537;
        let _e538 = mirror_cell_u0028_vi2_u003b((&param_81));
        let _e539 = textureLoad(bg, _e538, 0i);
        b_5 = _e539;
        let _e540 = b_5;
        hb = _e540;
        let _e542 = b_5[0u];
        if (_e542 != 0u) {
            result = 1i;
            let _e544 = c_13;
            let _e547 = (vec2<f32>(_e544) + vec2(0.5f));
            let _e549 = b_5[1u];
            param_82 = _e549;
            let _e550 = bg_depth_u0028_u1_u003b((&param_82));
            hp_5 = vec3<f32>(_e547.x, _e547.y, _e550);
            let _e554 = g_useCells;
            phi_3818_ = _e554;
            if _e554 {
                let _e555 = c_13;
                param_83 = _e555;
                let _e556 = inw_u0028_vi2_u003b((&param_83));
                phi_3818_ = _e556;
            }
            let _e558 = phi_3818_;
            cellHaze = _e558;
            let _e559 = c_13;
            cellAt = _e559;
        } else {
            let _e560 = c_13;
            let _e563 = (vec2<f32>(_e560) + vec2(0.5f));
            let _e564 = zNear;
            q_2 = vec3<f32>(_e563.x, _e563.y, _e564);
        }
    }
    let _e569 = g_cost[0u];
    g_cost[0u] = (_e569 + 4u);
    i_3 = 0i;
    loop {
        let _e572 = i_3;
        let _e574 = pixelLayer;
        if ((_e572 < 320i) && !(_e574)) {
            let _e578 = g_cost[0u];
            g_cost[0u] = (_e578 + bitcast<u32>(1i));
            let _e582 = q_2[2u];
            let _e584 = (*d_4)[2u];
            let _e585 = tCur_1;
            zIn = (_e582 + (_e584 * _e585));
            let _e588 = zIn;
            let _e589 = zFar;
            let _e591 = (_e588 > (_e589 + 1f));
            phi_3866_ = _e591;
            if !(_e591) {
                let _e594 = cell_2[1u];
                phi_3866_ = (_e594 < 0i);
            }
            let _e597 = phi_3866_;
            if _e597 {
                break;
            }
            let _e599 = tMax_2[0u];
            let _e601 = tMax_2[1u];
            tNext = min(_e599, _e601);
            let _e603 = g_bgSmooth;
            if (_e603 > 0.5f) {
                let _e605 = tNext;
                let _e606 = tCur_1;
                let _e608 = (*d_4)[2u];
                tSeg = min(_e605, (_e606 + (6f / max(_e608, 0.001f))));
                let _e613 = tCur_1;
                tPrev = _e613;
                hit = false;
                k_4 = 1i;
                loop {
                    let _e614 = k_4;
                    if (_e614 <= 2i) {
                        let _e616 = tCur_1;
                        let _e617 = tSeg;
                        let _e618 = k_4;
                        t_6 = mix(_e616, _e617, (f32(_e618) * 0.5f));
                        let _e622 = q_2;
                        let _e623 = (*d_4);
                        let _e624 = t_6;
                        qq = (_e622 + (_e623 * _e624));
                        let _e628 = qq[2u];
                        let _e629 = qq;
                        param_84 = _e629.xy;
                        let _e631 = bg_zs_u0028_vf2_u003b((&param_84));
                        if (_e628 >= _e631) {
                            let _e633 = tPrev;
                            a_6 = _e633;
                            let _e634 = t_6;
                            bb = _e634;
                            j = 0i;
                            loop {
                                let _e635 = j;
                                if (_e635 < 5i) {
                                    let _e637 = a_6;
                                    let _e638 = bb;
                                    m_1 = ((_e637 + _e638) * 0.5f);
                                    let _e641 = q_2;
                                    let _e642 = (*d_4);
                                    let _e643 = m_1;
                                    qm = (_e641 + (_e642 * _e643));
                                    let _e647 = qm[2u];
                                    let _e648 = qm;
                                    param_85 = _e648.xy;
                                    let _e650 = bg_zs_u0028_vf2_u003b((&param_85));
                                    if (_e647 >= _e650) {
                                        let _e652 = m_1;
                                        bb = _e652;
                                    } else {
                                        let _e653 = m_1;
                                        a_6 = _e653;
                                    }
                                    continue;
                                } else {
                                    break;
                                }
                                continuing {
                                    let _e654 = j;
                                    j = (_e654 + 1i);
                                }
                            }
                            let _e656 = q_2;
                            let _e657 = (*d_4);
                            let _e658 = bb;
                            hp_5 = (_e656 + (_e657 * _e658));
                            hit = true;
                            break;
                        }
                        let _e661 = t_6;
                        tPrev = _e661;
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e662 = k_4;
                        k_4 = (_e662 + 1i);
                    }
                }
                let _e664 = hit;
                if _e664 {
                    result = 2i;
                    let _e665 = hp_5;
                    param_86 = vec2<i32>(floor(_e665.xy));
                    let _e669 = mirror_cell_u0028_vi2_u003b((&param_86));
                    let _e670 = textureLoad(bg, _e669, 0i);
                    hb = _e670;
                    k_5 = 0i;
                    loop {
                        let _e671 = k_5;
                        let _e672 = (_e671 < 4i);
                        phi_3994_ = _e672;
                        if _e672 {
                            let _e674 = hb[0u];
                            phi_3994_ = (_e674 == 0u);
                        }
                        let _e677 = phi_3994_;
                        if _e677 {
                            let _e678 = k_5;
                            if (_e678 == 0i) {
                                local_23 = 1i;
                            } else {
                                let _e680 = k_5;
                                local_23 = select(0i, -1i, (_e680 == 1i));
                            }
                            let _e683 = local_23;
                            let _e684 = k_5;
                            if (_e684 == 2i) {
                                local_24 = 1i;
                            } else {
                                let _e686 = k_5;
                                local_24 = select(0i, -1i, (_e686 == 3i));
                            }
                            let _e689 = local_24;
                            o4_ = vec2<i32>(_e683, _e689);
                            let _e691 = hp_5;
                            let _e695 = o4_;
                            param_87 = (vec2<i32>(floor(_e691.xy)) + _e695);
                            let _e697 = mirror_cell_u0028_vi2_u003b((&param_87));
                            let _e698 = textureLoad(bg, _e697, 0i);
                            hb = _e698;
                            continue;
                        } else {
                            break;
                        }
                        continuing {
                            let _e699 = k_5;
                            k_5 = (_e699 + 1i);
                        }
                    }
                    break;
                }
                let _e701 = tSeg;
                let _e702 = tNext;
                if (_e701 < _e702) {
                    let _e704 = tSeg;
                    tCur_1 = _e704;
                    continue;
                }
                let _e705 = cell_2;
                param_88 = _e705;
                let _e706 = stp_2;
                param_89 = _e706;
                let _e707 = tDelta_2;
                param_90 = _e707;
                let _e708 = tMax_2;
                param_91 = _e708;
                let _e709 = tCur_1;
                param_92 = _e709;
                dda_step_u0028_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b_f1_u003b_i1_u003b((&param_88), (&param_89), (&param_90), (&param_91), (&param_92), (&param_93));
                let _e710 = param_88;
                cell_2 = _e710;
                let _e711 = param_91;
                tMax_2 = _e711;
                let _e712 = param_92;
                tCur_1 = _e712;
                let _e713 = param_93;
                face_3 = _e713;
                continue;
            }
            let _e714 = cell_2;
            param_94 = _e714;
            let _e715 = mirror_cell_u0028_vi2_u003b((&param_94));
            let _e716 = textureLoad(bg, _e715, 0i);
            b_6 = _e716;
            let _e718 = b_6[0u];
            if (_e718 != 0u) {
                let _e721 = b_6[1u];
                param_95 = _e721;
                let _e722 = bg_depth_u0028_u1_u003b((&param_95));
                zs = _e722;
                let _e723 = zIn;
                let _e724 = zs;
                if (_e723 >= _e724) {
                    result = 1i;
                    let _e726 = q_2;
                    let _e727 = (*d_4);
                    let _e728 = tCur_1;
                    hp_5 = (_e726 + (_e727 * _e728));
                    let _e731 = b_6;
                    hb = _e731;
                    break;
                }
                let _e733 = q_2[2u];
                let _e735 = (*d_4)[2u];
                let _e736 = tNext;
                let _e739 = zs;
                if ((_e733 + (_e735 * _e736)) >= _e739) {
                    result = 1i;
                    face_3 = 0i;
                    let _e741 = q_2;
                    let _e742 = (*d_4);
                    let _e743 = zs;
                    let _e745 = q_2[2u];
                    let _e748 = (*d_4)[2u];
                    hp_5 = (_e741 + (_e742 * ((_e743 - _e745) / _e748)));
                    let _e752 = b_6;
                    hb = _e752;
                    break;
                }
            }
            let _e753 = cell_2;
            param_96 = _e753;
            let _e754 = stp_2;
            param_97 = _e754;
            let _e755 = tDelta_2;
            param_98 = _e755;
            let _e756 = tMax_2;
            param_99 = _e756;
            let _e757 = tCur_1;
            param_100 = _e757;
            dda_step_u0028_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b_f1_u003b_i1_u003b((&param_96), (&param_97), (&param_98), (&param_99), (&param_100), (&param_101));
            let _e758 = param_96;
            cell_2 = _e758;
            let _e759 = param_99;
            tMax_2 = _e759;
            let _e760 = param_100;
            tCur_1 = _e760;
            let _e761 = param_101;
            face_3 = _e761;
            continue;
        } else {
            break;
        }
        continuing {
            let _e762 = i_3;
            i_3 = (_e762 + 1i);
        }
    }
    let _e764 = result;
    if (_e764 == 0i) {
        local_25 = 400f;
    } else {
        let _e767 = hp_5[2u];
        local_25 = _e767;
    }
    let _e768 = local_25;
    g_lastBgZ = _e768;
    let _e769 = result;
    if (_e769 == 0i) {
        let _e771 = q_2;
        let _e772 = (*d_4);
        let _e774 = q_2[2u];
        let _e777 = (*d_4)[2u];
        sp = (_e771 + (_e772 * ((300f - _e774) / _e777)));
        let _e781 = sp;
        param_102 = _e781.xy;
        let _e783 = sky_color_u0028_vf2_u003b((&param_102));
        return _e783;
    }
    let _e784 = cellHaze;
    if _e784 {
        let _e785 = cellAt;
        let _e787 = g_world[1u];
        param_103 = (_e785 + vec2<i32>(0i, i32(_e787)));
        let _e791 = cell_shade_at_u0028_vi2_u003b((&param_103));
        local_26 = _e791.xyz;
    } else {
        let _e793 = result;
        if (_e793 == 2i) {
            let _e795 = hp_5;
            param_104 = _e795.xy;
            let _e797 = bg_normal_u0028_vf2_u003b((&param_104));
            local_27 = _e797;
        } else {
            let _e798 = face_3;
            param_105 = _e798;
            let _e799 = face_n3_u0028_i1_u003b((&param_105));
            local_27 = _e799;
        }
        let _e800 = result;
        let _e802 = hb;
        param_106 = _e802;
        let _e803 = face_3;
        param_107 = _e803;
        let _e804 = local_27;
        param_108 = _e804;
        let _e805 = hp_5;
        param_109 = _e805;
        param_110 = (_e800 == 2i);
        let _e806 = shade_bg_u0028_vu4_u003b_i1_u003b_vf3_u003b_vf3_u003b_b1_u003b((&param_106), (&param_107), (&param_108), (&param_109), (&param_110));
        local_26 = _e806;
    }
    let _e807 = local_26;
    col_2 = _e807;
    let _e809 = hp_5[2u];
    zh = _e809;
    let _e810 = qs;
    let _e811 = hp_5;
    mid = ((_e810 + _e811) * 0.5f);
    let _e814 = mid;
    let _e816 = g_world;
    let _e818 = textureSampleLevel(medium_tex, medium_tex_smp, (_e814.xy / _e816), 0f);
    md_1 = _e818;
    let _e819 = zh;
    let _e821 = qs[2u];
    let _e826 = rp.haze[3u];
    gap_2 = (max((_e819 - _e821), 0f) * _e826);
    let _e829 = md_1[0u];
    let _e832 = rp.medium[0u];
    let _e834 = gap_2;
    tauSoot = ((_e829 * _e832) * _e834);
    let _e837 = md_1[1u];
    let _e840 = rp.medium[1u];
    let _e842 = gap_2;
    tauSteam = ((_e837 * _e840) * _e842);
    let _e844 = tauSoot;
    let _e845 = tauSteam;
    Tf = exp(-((_e844 + _e845)));
    let _e849 = mid;
    param_111 = _e849.xy;
    let _e852 = mid[2u];
    param_112 = _e852;
    let _e853 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_111), (&param_112));
    let _e855 = rp.ambient;
    Lm = (_e853 + _e855.xyz);
    let _e858 = Lm;
    let _e860 = rp.steam_color;
    let _e862 = tauSteam;
    let _e868 = rp.soot_color;
    let _e870 = tauSoot;
    inscatter = (_e858 * ((_e860.xyz * (1f - exp(-(_e862)))) + (_e868.xyz * (1f - exp(-(_e870))))));
    let _e877 = col_2;
    let _e878 = Tf;
    let _e880 = inscatter;
    let _e882 = md_1;
    param_113 = _e882;
    let _e883 = flame_radiance_u0028_vf4_u003b((&param_113));
    let _e884 = gap_2;
    col_2 = (((_e877 * _e878) + _e880) + (_e883 * min((_e884 * 0.5f), 1f)));
    let _e891 = rp.reserved2_[0u];
    if (_e891 > 0f) {
        beam_1 = vec3<f32>(0f, 0f, 0f);
        k_6 = 0i;
        loop {
            let _e893 = k_6;
            if (_e893 < 4i) {
                let _e895 = qs;
                let _e896 = hp_5;
                let _e897 = k_6;
                sp_1 = mix(_e895, _e896, vec3(((f32(_e897) + 0.5f) / 4f)));
                let _e904 = sp_1[2u];
                let _e906 = sp_1;
                param_114 = _e906.xy;
                param_115 = (_e904 * 0.5f);
                let _e908 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_114), (&param_115));
                f_6 = _e908;
                let _e909 = f_6;
                let _e910 = f_6;
                param_116 = _e910;
                let _e911 = luminance_u0028_vf3_u003b((&param_116));
                let _e914 = beam_1;
                beam_1 = (_e914 + (_e909 * smoothstep(0.15f, 1.2f, _e911)));
                continue;
            } else {
                break;
            }
            continuing {
                let _e916 = k_6;
                k_6 = (_e916 + 1i);
            }
        }
        let _e918 = zh;
        let _e920 = qs[2u];
        dz = max((_e918 - _e920), 0f);
        let _e923 = beam_1;
        let _e927 = rp.reserved2_[0u];
        let _e929 = dz;
        let _e932 = col_2;
        col_2 = (_e932 + ((((_e923 * 0.25f) * _e927) * _e929) * 0.01f));
    }
    let _e934 = cellHaze;
    if _e934 {
        let _e935 = cellAt;
        let _e937 = g_world[1u];
        param_117 = (_e935 + vec2<i32>(0i, (2i * i32(_e937))));
        let _e942 = cell_shade_at_u0028_vi2_u003b((&param_117));
        local_28 = _e942;
    } else {
        let _e943 = hp_5;
        param_118 = _e943;
        let _e944 = bg_haze_u0028_vf3_u003b((&param_118));
        local_28 = _e944;
    }
    let _e945 = local_28;
    hz = _e945;
    let _e946 = col_2;
    let _e947 = hz;
    let _e950 = hz[3u];
    return mix(_e946, _e947.xyz, vec3(_e950));
}

fn glint_u0028_vi2_u003b_i1_u003b_f1_u003b(cell_3: ptr<function, vec2<i32>>, face_4: ptr<function, i32>, sparkle: ptr<function, f32>) -> f32 {
    var h_4: f32;
    var param_119: vec2<f32>;
    var param_120: vec2<f32>;

    let _e338 = (*sparkle);
    if (_e338 <= 0f) {
        return 0f;
    }
    let _e340 = (*cell_3);
    let _e343 = (*face_4);
    param_119 = ((vec2<f32>(_e340) * 1.13f) + vec2((f32(_e343) * 7.7f)));
    let _e348 = hash21_u0028_vf2_u003b((&param_119));
    h_4 = _e348;
    let _e349 = (*sparkle);
    let _e352 = h_4;
    let _e354 = (*cell_3);
    param_120 = (vec2<f32>(_e354) + vec2(17f));
    let _e358 = hash21_u0028_vf2_u003b((&param_120));
    return (step((1f - (_e349 * 0.035f)), _e352) * (0.5f + (0.5f * _e358)));
}

fn spec_core_u0028_f1_u003b_f1_u003b_f1_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b(ks: ptr<function, f32>, rough: ptr<function, f32>, metal: ptr<function, f32>, n_5: ptr<function, vec3<f32>>, v_3: ptr<function, vec3<f32>>, l_2: ptr<function, vec3<f32>>, Li: ptr<function, vec3<f32>>, base_2: ptr<function, vec3<f32>>) -> vec3<f32> {
    var r_3: f32;
    var shin: f32;
    var h_5: vec3<f32>;
    var s_6: f32;
    var f0_1: f32;
    var fres: f32;
    var tint: vec3<f32>;
    var param_121: vec3<f32>;

    let _e348 = (*ks);
    if (_e348 <= 0.001f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e350 = (*rough);
    r_3 = clamp(_e350, 0.03f, 1f);
    let _e352 = r_3;
    let _e353 = r_3;
    let _e355 = r_3;
    let _e357 = r_3;
    shin = clamp((2f / ((((_e352 * _e353) * _e355) * _e357) + 0.0001f)), 4f, 2048f);
    let _e362 = (*l_2);
    let _e363 = (*v_3);
    h_5 = normalize((_e362 + _e363));
    let _e366 = (*n_5);
    let _e367 = h_5;
    let _e370 = shin;
    let _e372 = shin;
    s_6 = ((pow(max(dot(_e366, _e367), 0f), _e370) * (_e372 + 8f)) / 50f);
    let _e376 = (*metal);
    f0_1 = mix(0.04f, 1f, _e376);
    let _e378 = f0_1;
    let _e379 = f0_1;
    let _e381 = (*v_3);
    let _e382 = h_5;
    fres = (_e378 + ((1f - _e379) * pow((1f - max(dot(_e381, _e382), 0f)), 5f)));
    let _e389 = (*base_2);
    param_121 = _e389;
    let _e390 = chroma_of_u0028_vf3_u003b((&param_121));
    let _e391 = (*metal);
    tint = mix(vec3<f32>(1f, 1f, 1f), _e390, vec3(_e391));
    let _e394 = (*Li);
    let _e395 = s_6;
    let _e398 = (*ks);
    let _e400 = fres;
    let _e402 = tint;
    return ((((_e394 * min(_e395, 60f)) * _e398) * _e400) * _e402);
}

fn spec_term_u0028_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b(m_2: ptr<function, Material>, n_6: ptr<function, vec3<f32>>, v_4: ptr<function, vec3<f32>>, l_3: ptr<function, vec3<f32>>, Li_1: ptr<function, vec3<f32>>, base_3: ptr<function, vec3<f32>>) -> vec3<f32> {
    var s_7: vec3<f32>;
    var param_122: f32;
    var param_123: f32;
    var param_124: f32;
    var param_125: vec3<f32>;
    var param_126: vec3<f32>;
    var param_127: vec3<f32>;
    var param_128: vec3<f32>;
    var param_129: vec3<f32>;
    var param_130: f32;
    var param_131: f32;
    var param_132: f32;
    var param_133: vec3<f32>;
    var param_134: vec3<f32>;
    var param_135: vec3<f32>;
    var param_136: vec3<f32>;
    var param_137: vec3<f32>;

    let _e357 = (*m_2).surface[0u];
    param_122 = _e357;
    let _e360 = (*m_2).surface[1u];
    param_123 = _e360;
    let _e363 = (*m_2).surface[2u];
    param_124 = _e363;
    let _e364 = (*n_6);
    param_125 = _e364;
    let _e365 = (*v_4);
    param_126 = _e365;
    let _e366 = (*l_3);
    param_127 = _e366;
    let _e367 = (*Li_1);
    param_128 = _e367;
    let _e368 = (*base_3);
    param_129 = _e368;
    let _e369 = spec_core_u0028_f1_u003b_f1_u003b_f1_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b((&param_122), (&param_123), (&param_124), (&param_125), (&param_126), (&param_127), (&param_128), (&param_129));
    s_7 = _e369;
    let _e372 = (*m_2).sss[2u];
    if (_e372 > 0f) {
        let _e376 = (*m_2).sss[2u];
        param_130 = _e376;
        let _e379 = (*m_2).sss[3u];
        param_131 = _e379;
        param_132 = 0f;
        let _e380 = (*n_6);
        param_133 = _e380;
        let _e381 = (*v_4);
        param_134 = _e381;
        let _e382 = (*l_3);
        param_135 = _e382;
        let _e383 = (*Li_1);
        param_136 = _e383;
        let _e384 = (*base_3);
        param_137 = _e384;
        let _e385 = spec_core_u0028_f1_u003b_f1_u003b_f1_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b((&param_130), (&param_131), (&param_132), (&param_133), (&param_134), (&param_135), (&param_136), (&param_137));
        let _e387 = s_7;
        s_7 = (_e387 + (_e385 * 1.4f));
    }
    let _e389 = s_7;
    return _e389;
}

fn form_tint_u0028_vf3_u003b(n_7: ptr<function, vec3<f32>>) -> vec3<f32> {
    var warm: vec3<f32>;
    var cool: vec3<f32>;

    warm = vec3<f32>(1.06f, 1f, 0.9f);
    cool = vec3<f32>(0.92f, 0.97f, 1.08f);
    let _e335 = cool;
    let _e336 = warm;
    let _e338 = (*n_7)[1u];
    let _e341 = (*n_7);
    let _e352 = rp.look[0u];
    let _e354 = (*n_7)[2u];
    return mix(vec3<f32>(1f, 1f, 1f), mix(_e335, _e336, vec3(clamp((((-(_e338) * 0.8f) + (dot(_e341.xy, vec2<f32>(-0.5323273f, -0.7259009f)) * 0.4f)) + 0.3f), 0f, 1f))), vec3((_e352 * select(0f, 1f, (_e354 > -0.9f)))));
}

fn form_k_u0028_vf3_u003b(n_8: ptr<function, vec3<f32>>) -> f32 {
    var a_7: f32;
    var k_7: f32;

    let _e335 = (*n_8);
    a_7 = (0.35f + (0.65f * max(dot(_e335, vec3<f32>(-0.5323273f, -0.7259009f, -0.43554053f)), 0f)));
    let _e340 = a_7;
    k_7 = (_e340 / 0.6425f);
    let _e343 = (*n_8)[1u];
    let _e347 = k_7;
    k_7 = (_e347 * (1f - (0.35f * max(_e343, 0f))));
    let _e349 = k_7;
    let _e352 = rp.look[0u];
    return mix(1f, _e349, _e352);
}

fn bevel_n_u0028_vf2_u003b(c_14: ptr<function, vec2<f32>>) -> vec3<f32> {
    var gx: f32;
    var gy: f32;
    var g: vec2<f32>;

    let _e336 = (*c_14);
    let _e338 = g_world;
    let _e340 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e336 + vec2<f32>(1.5f, 0f)) / _e338), 0f);
    let _e342 = (*c_14);
    let _e344 = g_world;
    let _e346 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e342 - vec2<f32>(1.5f, 0f)) / _e344), 0f);
    gx = (_e340.z - _e346.z);
    let _e349 = (*c_14);
    let _e351 = g_world;
    let _e353 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e349 + vec2<f32>(0f, 1.5f)) / _e351), 0f);
    let _e355 = (*c_14);
    let _e357 = g_world;
    let _e359 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e355 - vec2<f32>(0f, 1.5f)) / _e357), 0f);
    gy = (_e353.z - _e359.z);
    let _e362 = gx;
    let _e363 = gy;
    g = (vec2<f32>(_e362, _e363) / vec2(3f));
    let _e367 = g;
    let _e370 = ((-(_e367) * 2.5f) * 2.5f);
    return normalize(vec3<f32>(_e370.x, _e370.y, -1f));
}

fn hash3_u0028_vf2_u003b(p_4: ptr<function, vec2<f32>>) -> vec3<f32> {
    var h_6: vec3<u32>;
    var param_138: vec3<u32>;

    let _e335 = (*p_4);
    let _e341 = bitcast<vec2<u32>>((vec2<i32>(floor((_e335 * 7f))) + vec2(32768i)));
    param_138 = vec3<u32>(_e341.x, _e341.y, 91u);
    let _e345 = pcg3d_u0028_vu3_u003b((&param_138));
    h_6 = _e345;
    let _e346 = h_6;
    return (vec3<f32>((_e346 & vec3(65535u))) / vec3(65535f));
}

fn shade_l0_u0028_vf3_u003b_i1_u003b_vf3_u003b_vi2_u003b_vf3_u003b(S: ptr<function, vec3<f32>>, face_5: ptr<function, i32>, hp_6: ptr<function, vec3<f32>>, cell_4: ptr<function, vec2<i32>>, d_5: ptr<function, vec3<f32>>) -> vec3<f32> {
    var mid_1: u32;
    var m_3: Material;
    var n_9: vec3<f32>;
    var param_139: i32;
    var n2_: vec2<f32>;
    var local_29: vec2<f32>;
    var lp_1: vec2<f32>;
    var ld_4: vec4<f32>;
    var param_140: vec2<f32>;
    var l_4: vec3<f32>;
    var param_141: vec4<f32>;
    var v_5: vec3<f32>;
    var jit_1: vec3<f32>;
    var param_142: vec2<f32>;
    var nm: vec3<f32>;
    var k_8: f32;
    var kc: vec3<f32>;
    var b25_: bool;
    var nb: vec3<f32>;
    var param_143: vec2<f32>;
    var param_144: vec2<f32>;
    var param_145: vec3<f32>;
    var f_7: f32;
    var f_8: f32;
    var local_30: f32;
    var lit_1: f32;
    var param_146: vec2<f32>;
    var param_147: vec3<f32>;
    var param_148: vec3<f32>;
    var param_149: vec3<f32>;
    var col_3: vec3<f32>;
    var param_150: vec3<f32>;
    var edge_1: f32;
    var q_3: vec2<f32>;
    var Lb: vec3<f32>;
    var param_151: vec2<f32>;
    var param_152: f32;
    var kb: u32;
    var rim: f32;
    var param_153: vec2<f32>;
    var param_154: f32;
    var Li_2: vec3<f32>;
    var param_155: vec2<f32>;
    var notMirror: f32;
    var param_156: Material;
    var param_157: vec3<f32>;
    var param_158: vec3<f32>;
    var param_159: vec3<f32>;
    var param_160: vec3<f32>;
    var param_161: vec3<f32>;
    var r_4: vec3<f32>;
    var env: vec3<f32>;
    var param_162: vec2<f32>;
    var param_163: f32;
    var f0_2: f32;
    var fr: f32;
    var param_164: vec3<f32>;
    var Ldirect: vec3<f32>;
    var param_165: vec2<i32>;
    var param_166: i32;
    var param_167: f32;
    var param_168: vec3<f32>;
    var phi_2372_: bool;
    var phi_2481_: bool;
    var phi_2530_: bool;
    var phi_2666_: bool;

    let _e400 = g_cost[2u];
    g_cost[2u] = (_e400 + 6u);
    let _e403 = (*cell_4);
    let _e404 = textureLoad(cells, _e403, 0i);
    mid_1 = (_e404.x & 255u);
    let _e407 = mid_1;
    let _e410 = unnamed.mats[_e407];
    m_3.color_a = _e410.color_a;
    m_3.color_b = _e410.color_b;
    m_3.emission = _e410.emission;
    m_3.phys = _e410.phys;
    m_3.thermo = _e410.thermo;
    m_3.burn = _e410.burn;
    m_3.optics = _e410.optics;
    m_3.scatter = _e410.scatter;
    m_3.ids = _e410.ids;
    m_3.ids2_ = _e410.ids2_;
    m_3.misc = _e410.misc;
    m_3.surface = _e410.surface;
    m_3.sss = _e410.sss;
    m_3.sss_color = _e410.sss_color;
    m_3.optics2_ = _e410.optics2_;
    m_3.pal0_ = _e410.pal0_;
    m_3.pal1_ = _e410.pal1_;
    m_3.pal2_ = _e410.pal2_;
    m_3.pal3_ = _e410.pal3_;
    m_3.accent = _e410.accent;
    m_3.flame = _e410.flame;
    let _e453 = (*face_5);
    param_139 = _e453;
    let _e454 = face_n3_u0028_i1_u003b((&param_139));
    n_9 = _e454;
    let _e455 = (*face_5);
    if (_e455 == 0i) {
        let _e457 = (*cell_4);
        let _e458 = textureLoad(gaux_img, _e457, 0i);
        local_29 = _e458.xy;
    } else {
        let _e460 = n_9;
        local_29 = _e460.xy;
    }
    let _e462 = local_29;
    n2_ = _e462;
    let _e463 = (*cell_4);
    let _e467 = n2_;
    lp_1 = ((vec2<f32>(_e463) + vec2(0.5f)) + (_e467 * 1.5f));
    let _e470 = lp_1;
    param_140 = _e470;
    let _e471 = light_at_u0028_vf2_u003b((&param_140));
    ld_4 = _e471;
    let _e472 = ld_4;
    param_141 = _e472;
    let _e473 = light_dir3_u0028_vf4_u003b((&param_141));
    l_4 = _e473;
    let _e474 = (*d_5);
    v_5 = -(_e474);
    let _e476 = (*cell_4);
    let _e479 = (*face_5);
    param_142 = ((vec2<f32>(_e476) * 1.7f) + vec2((f32(_e479) * 3.3f)));
    let _e484 = hash3_u0028_vf2_u003b((&param_142));
    jit_1 = (_e484 - vec3(0.5f));
    let _e487 = n_9;
    let _e488 = jit_1;
    let _e491 = m_3.surface[1u];
    nm = normalize((_e487 + ((_e488 * _e491) * 0.6f)));
    k_8 = 1f;
    kc = vec3<f32>(1f, 1f, 1f);
    let _e498 = rp.look2_[3u];
    let _e500 = (*face_5);
    let _e503 = g_T0_;
    b25_ = (((_e498 > 0f) && (_e500 == 0i)) && (_e503 < 0.01f));
    let _e506 = n_9;
    nb = _e506;
    let _e507 = b25_;
    if _e507 {
        let _e508 = (*cell_4);
        param_143 = (vec2<f32>(_e508) + vec2(0.5f));
        let _e512 = bevel_n_u0028_vf2_u003b((&param_143));
        nb = _e512;
        let _e515 = rp.day[3u];
        if (_e515 > 0f) {
            let _e517 = lp_1;
            param_144 = _e517;
            let _e518 = nb;
            param_145 = _e518;
            let _e519 = ch_light_u0028_vf2_u003b_vf3_u003b((&param_144), (&param_145));
            let _e523 = rp.look2_[3u];
            kc = pow(max(_e519, vec3<f32>(0.05f, 0.05f, 0.05f)), vec3((_e523 * 0.6f)));
        } else {
            let _e527 = nb;
            let _e528 = l_4;
            let _e534 = l_4[2u];
            f_7 = ((0.45f + (0.55f * max(dot(_e527, _e528), 0f))) / (0.45f + (0.55f * max(-(_e534), 0f))));
            let _e540 = f_7;
            let _e544 = rp.look2_[3u];
            let _e546 = k_8;
            k_8 = (_e546 * pow(max(_e540, 0.05f), _e544));
        }
        let _e548 = nb;
        n_9 = _e548;
        let _e549 = nb;
        let _e550 = jit_1;
        let _e553 = m_3.surface[1u];
        nm = normalize((_e549 + ((_e550 * _e553) * 0.6f)));
    }
    let _e558 = (*face_5);
    let _e559 = (_e558 == 0i);
    phi_2372_ = _e559;
    if _e559 {
        let _e560 = n2_;
        let _e561 = n2_;
        phi_2372_ = (dot(_e560, _e561) > 0f);
    }
    let _e565 = phi_2372_;
    let _e566 = g_T0_;
    if (_e565 && (_e566 > 0.01f)) {
        let _e569 = n2_;
        f_8 = dot(normalize(_e569), vec2<f32>(-0.59136367f, -0.806405f));
        let _e572 = f_8;
        if (_e572 > 0f) {
            let _e574 = g_frontRim;
            let _e576 = f_8;
            local_30 = (1f + ((_e574 * 1.6f) * _e576));
        } else {
            let _e579 = g_frontRim;
            let _e581 = f_8;
            local_30 = (1f + ((_e579 * 1.2f) * _e581));
        }
        let _e584 = local_30;
        let _e585 = k_8;
        k_8 = (_e585 * _e584);
    }
    let _e587 = (*face_5);
    if (_e587 != 0i) {
        let _e589 = n_9;
        let _e591 = ld_4;
        let _e596 = ld_4[2u];
        lit_1 = (max(dot(_e589.xy, _e591.xy), 0f) * _e596);
        let _e600 = rp.day[3u];
        if (_e600 > 0f) {
            let _e602 = lp_1;
            param_146 = _e602;
            let _e603 = n_9;
            param_147 = _e603;
            let _e604 = ch_light_u0028_vf2_u003b_vf3_u003b((&param_146), (&param_147));
            kc = _e604;
            lit_1 = 0f;
        }
        let _e605 = (*face_5);
        if (_e605 == 1i) {
            let _e607 = lit_1;
            k_8 = (1f + (0.3f * _e607));
        } else {
            let _e610 = (*face_5);
            if (_e610 == 2i) {
                let _e612 = lit_1;
                k_8 = (0.42f + (0.2f * _e612));
            } else {
                let _e617 = rp.view[2u];
                let _e618 = lit_1;
                k_8 = (_e617 + (0.35f * _e618));
            }
        }
        let _e622 = (*hp_6)[2u];
        let _e623 = g_T0_;
        let _e628 = k_8;
        k_8 = (_e628 * mix(1f, 0.7f, clamp((_e622 / max(_e623, 0.001f)), 0f, 1f)));
        let _e630 = k_8;
        let _e631 = k_8;
        let _e632 = n_9;
        param_148 = _e632;
        let _e633 = form_k_u0028_vf3_u003b((&param_148));
        param_149 = vec3<f32>(0f, 0f, -1f);
        let _e635 = form_k_u0028_vf3_u003b((&param_149));
        let _e640 = rp.look[0u];
        k_8 = mix(_e630, ((_e631 * _e633) / max(_e635, 0.001f)), _e640);
        let _e642 = (*face_5);
        let _e643 = (_e642 == 1i);
        phi_2481_ = _e643;
        if _e643 {
            let _e645 = (*hp_6)[2u];
            phi_2481_ = (_e645 < 0.6f);
        }
        let _e648 = phi_2481_;
        if _e648 {
            let _e651 = rp.cam_down[3u];
            let _e653 = k_8;
            k_8 = (_e653 * (1f + _e651));
        }
    }
    let _e655 = nm;
    let _e656 = l_4;
    let _e663 = k_8;
    k_8 = (_e663 * (0.9f + (0.2f * clamp(((dot(_e655, _e656) * 0.5f) + 0.5f), 0f, 1f))));
    let _e665 = k_8;
    let _e666 = (*face_5);
    let _e673 = m_3.sss[0u];
    k_8 = mix(_e665, (1f + (0.12f * select(0f, 1f, (_e666 != 0i)))), (_e673 * 0.7f));
    let _e676 = (*S);
    let _e677 = k_8;
    let _e679 = kc;
    let _e681 = n_9;
    param_150 = _e681;
    let _e682 = form_tint_u0028_vf3_u003b((&param_150));
    let _e686 = m_3.surface[2u];
    col_3 = ((((_e676 * _e677) * _e679) * _e682) * (1f - (0.45f * _e686)));
    let _e690 = b25_;
    phi_2530_ = _e690;
    if _e690 {
        let _e693 = rp.look2_[2u];
        phi_2530_ = (_e693 > 0f);
    }
    let _e696 = phi_2530_;
    if _e696 {
        let _e698 = nb[2u];
        edge_1 = pow((1f - clamp(-(_e698), 0f, 1f)), 1.2f);
        let _e703 = edge_1;
        if (_e703 > 0.01f) {
            let _e705 = (*cell_4);
            let _e709 = nb;
            q_3 = ((vec2<f32>(_e705) + vec2(0.5f)) + (_e709.xy * 4f));
            let _e713 = q_3;
            let _e714 = g_world;
            param_151 = clamp(_e713, vec2<f32>(0.5f, 0.5f), (_e714 - vec2(0.5f)));
            param_152 = 40f;
            let _e718 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_151), (&param_152));
            Lb = _e718;
            let _e719 = q_3;
            let _e721 = g_world;
            let _e726 = textureLoad(bg, clamp(vec2<i32>(_e719), vec2<i32>(0i, 0i), (vec2<i32>(_e721) - vec2(1i))), 0i);
            kb = _e726.x;
            let _e728 = q_3;
            let _e729 = g_world;
            let _e731 = textureSampleLevel(day_tex, day_tex_smp, (_e728 / _e729), 0f);
            let _e734 = Lb;
            Lb = (_e734 + (_e731.xyz * 0.6f));
            let _e736 = Lb;
            let _e737 = edge_1;
            let _e741 = rp.look2_[2u];
            let _e744 = col_3;
            col_3 = (_e744 + (((_e736 * _e737) * _e741) * 2.2f));
        }
    }
    let _e748 = m_3.sss[0u];
    if (_e748 > 0f) {
        let _e750 = v_5;
        let _e751 = nm;
        rim = pow((1f - clamp(dot(_e750, _e751), 0f, 1f)), 4f);
        let _e756 = rim;
        let _e759 = m_3.sss[2u];
        let _e761 = (*cell_4);
        let _e765 = n2_;
        param_153 = ((vec2<f32>(_e761) + vec2(0.5f)) + (_e765 * 3f));
        param_154 = 4f;
        let _e768 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_153), (&param_154));
        let _e771 = col_3;
        col_3 = (_e771 + ((_e768 * (_e756 * _e759)) * 1.2f));
    }
    let _e773 = lp_1;
    param_155 = _e773;
    let _e774 = fluence_at_u0028_vf2_u003b((&param_155));
    let _e777 = rp.ambient;
    Li_2 = ((_e774 * 2f) + _e777.xyz);
    let _e782 = m_3.optics2_[1u];
    notMirror = (1f - _e782);
    let _e784 = m_3;
    param_156 = _e784;
    let _e785 = nm;
    param_157 = _e785;
    let _e786 = v_5;
    param_158 = _e786;
    let _e787 = l_4;
    param_159 = _e787;
    let _e788 = Li_2;
    param_160 = _e788;
    let _e789 = (*S);
    param_161 = _e789;
    let _e790 = spec_term_u0028_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b((&param_156), (&param_157), (&param_158), (&param_159), (&param_160), (&param_161));
    let _e791 = notMirror;
    let _e793 = col_3;
    col_3 = (_e793 + (_e790 * _e791));
    let _e797 = m_3.surface[0u];
    let _e798 = (_e797 > 0.3f);
    phi_2666_ = _e798;
    if _e798 {
        let _e801 = m_3.surface[1u];
        phi_2666_ = (_e801 < 0.5f);
    }
    let _e804 = phi_2666_;
    let _e805 = notMirror;
    if (_e804 && (_e805 > 0.5f)) {
        let _e808 = (*d_5);
        let _e809 = nm;
        r_4 = reflect(_e808, _e809);
        let _e811 = (*cell_4);
        let _e815 = r_4;
        param_162 = ((vec2<f32>(_e811) + vec2(0.5f)) + (_e815.xy * 6f));
        param_163 = 6f;
        let _e819 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_162), (&param_163));
        env = _e819;
        let _e822 = m_3.surface[2u];
        f0_2 = mix(0.04f, 1f, _e822);
        let _e824 = f0_2;
        let _e825 = f0_2;
        let _e827 = v_5;
        let _e828 = nm;
        fr = (_e824 + ((1f - _e825) * pow((1f - max(dot(_e827, _e828), 0f)), 5f)));
        let _e835 = env;
        let _e836 = fr;
        let _e840 = m_3.surface[0u];
        let _e844 = m_3.surface[1u];
        let _e847 = (*S);
        param_164 = _e847;
        let _e848 = chroma_of_u0028_vf3_u003b((&param_164));
        let _e851 = m_3.surface[2u];
        let _e855 = col_3;
        col_3 = (_e855 + ((((_e835 * _e836) * _e840) * (1f - _e844)) * mix(vec3<f32>(1f, 1f, 1f), _e848, vec3(_e851))));
    }
    let _e857 = Li_2;
    let _e859 = rp.ambient;
    Ldirect = max((_e857 - (_e859.xyz * 1.5f)), vec3<f32>(0f, 0f, 0f));
    let _e864 = Ldirect;
    let _e865 = (*cell_4);
    param_165 = _e865;
    let _e866 = (*face_5);
    param_166 = _e866;
    let _e869 = m_3.surface[3u];
    param_167 = _e869;
    let _e870 = glint_u0028_vi2_u003b_i1_u003b_f1_u003b((&param_165), (&param_166), (&param_167));
    let _e873 = (*S);
    param_168 = _e873;
    let _e874 = chroma_of_u0028_vf3_u003b((&param_168));
    let _e878 = col_3;
    col_3 = (_e878 + (((_e864 * _e870) * 5f) * mix(vec3<f32>(1f, 1f, 1f), _e874, vec3(0.3f))));
    let _e880 = col_3;
    return _e880;
}

fn march_l0_simple_u0028_vf3_u003b_vf3_u003b_vf3_u003b(o_3: ptr<function, vec3<f32>>, d_6: ptr<function, vec3<f32>>, T: ptr<function, vec3<f32>>) -> vec3<f32> {
    var C: vec3<f32>;
    var cell_5: vec2<i32>;
    var stp_3: vec2<i32>;
    var tDelta_3: vec2<f32>;
    var tMax_3: vec2<f32>;
    var param_169: vec2<f32>;
    var param_170: vec2<f32>;
    var param_171: vec2<i32>;
    var param_172: vec2<i32>;
    var param_173: vec2<f32>;
    var param_174: vec2<f32>;
    var tEnd: f32;
    var tCur_2: f32;
    var face_6: i32;
    var i_4: i32;
    var tNext_1: f32;
    var param_175: vec2<i32>;
    var s_8: vec4<f32>;
    var param_176: vec3<f32>;
    var param_177: i32;
    var param_178: vec3<f32>;
    var param_179: vec2<i32>;
    var param_180: vec3<f32>;
    var tr_2: vec4<f32>;
    var k_9: f32;
    var param_181: vec3<f32>;
    var param_182: vec2<i32>;
    var param_183: vec2<i32>;
    var param_184: vec2<f32>;
    var param_185: vec2<f32>;
    var param_186: f32;
    var param_187: i32;
    var phi_4523_: bool;

    C = vec3<f32>(0f, 0f, 0f);
    let _e368 = (*o_3)[2u];
    let _e369 = g_T0_;
    if (_e368 >= _e369) {
        let _e371 = C;
        return _e371;
    }
    let _e372 = (*o_3);
    cell_5 = vec2<i32>(floor(_e372.xy));
    let _e376 = (*o_3);
    param_169 = _e376.xy;
    let _e378 = (*d_6);
    param_170 = _e378.xy;
    let _e380 = cell_5;
    param_171 = _e380;
    dda_init_cell_u0028_vf2_u003b_vf2_u003b_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b((&param_169), (&param_170), (&param_171), (&param_172), (&param_173), (&param_174));
    let _e381 = param_172;
    stp_3 = _e381;
    let _e382 = param_173;
    tDelta_3 = _e382;
    let _e383 = param_174;
    tMax_3 = _e383;
    let _e384 = g_T0_;
    let _e386 = (*o_3)[2u];
    let _e389 = (*d_6)[2u];
    tEnd = ((_e384 - _e386) / _e389);
    tCur_2 = 0f;
    face_6 = 0i;
    i_4 = 0i;
    loop {
        let _e391 = i_4;
        if (_e391 < 48i) {
            let _e394 = g_cost[2u];
            g_cost[2u] = (_e394 + bitcast<u32>(1i));
            let _e398 = tMax_3[0u];
            let _e400 = tMax_3[1u];
            let _e402 = tEnd;
            tNext_1 = min(min(_e398, _e400), _e402);
            let _e405 = cell_5[1u];
            if (_e405 < 0i) {
                break;
            }
            let _e407 = cell_5;
            param_175 = _e407;
            let _e408 = inw_u0028_vi2_u003b((&param_175));
            if _e408 {
                let _e409 = cell_5;
                let _e410 = textureLoad(l0s, _e409, 0i);
                s_8 = _e410;
                let _e412 = s_8[3u];
                if (_e412 >= 0.99f) {
                    let _e414 = (*T);
                    let _e415 = (*o_3);
                    let _e416 = (*d_6);
                    let _e417 = tCur_2;
                    let _e420 = s_8;
                    param_176 = _e420.xyz;
                    let _e422 = face_6;
                    param_177 = _e422;
                    param_178 = (_e415 + (_e416 * _e417));
                    let _e423 = cell_5;
                    param_179 = _e423;
                    let _e424 = (*d_6);
                    param_180 = _e424;
                    let _e425 = shade_l0_u0028_vf3_u003b_i1_u003b_vf3_u003b_vi2_u003b_vf3_u003b((&param_176), (&param_177), (&param_178), (&param_179), (&param_180));
                    let _e427 = C;
                    C = (_e427 + (_e414 * _e425));
                    (*T) = vec3<f32>(0f, 0f, 0f);
                    let _e429 = C;
                    return _e429;
                }
                let _e430 = cell_5;
                let _e431 = textureLoad(l0t, _e430, 0i);
                tr_2 = _e431;
                let _e432 = tNext_1;
                let _e433 = tCur_2;
                let _e436 = (*d_6)[2u];
                let _e438 = g_T0_;
                k_9 = (((_e432 - _e433) * _e436) / _e438);
                let _e440 = (*T);
                let _e441 = s_8;
                let _e444 = k_9;
                let _e446 = C;
                C = (_e446 + ((_e440 * _e441.xyz) * _e444));
                let _e448 = tr_2;
                let _e451 = k_9;
                let _e454 = (*T);
                (*T) = (_e454 * pow(max(_e448.xyz, vec3<f32>(0.0001f, 0.0001f, 0.0001f)), vec3(_e451)));
            }
            let _e456 = tNext_1;
            let _e457 = tEnd;
            let _e458 = (_e456 >= _e457);
            phi_4523_ = _e458;
            if !(_e458) {
                let _e460 = (*T);
                param_181 = _e460;
                let _e461 = max3_u0028_vf3_u003b((&param_181));
                phi_4523_ = (_e461 < 0.01f);
            }
            let _e464 = phi_4523_;
            if _e464 {
                break;
            }
            let _e465 = cell_5;
            param_182 = _e465;
            let _e466 = stp_3;
            param_183 = _e466;
            let _e467 = tDelta_3;
            param_184 = _e467;
            let _e468 = tMax_3;
            param_185 = _e468;
            let _e469 = tCur_2;
            param_186 = _e469;
            dda_step_u0028_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b_f1_u003b_i1_u003b((&param_182), (&param_183), (&param_184), (&param_185), (&param_186), (&param_187));
            let _e470 = param_182;
            cell_5 = _e470;
            let _e471 = param_185;
            tMax_3 = _e471;
            let _e472 = param_186;
            tCur_2 = _e472;
            let _e473 = param_187;
            face_6 = _e473;
            continue;
        } else {
            break;
        }
        continuing {
            let _e474 = i_4;
            i_4 = (_e474 + 1i);
        }
    }
    let _e476 = (*o_3);
    let _e477 = (*d_6);
    let _e478 = tEnd;
    (*o_3) = (_e476 + (_e477 * _e478));
    let _e481 = C;
    return _e481;
}

fn glossy_dir_u0028_vf3_u003b_vf3_u003b_vf3_u003b_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b(hp_7: ptr<function, vec3<f32>>, n_10: ptr<function, vec3<f32>>, d_7: ptr<function, vec3<f32>>, m_4: ptr<function, Material>) -> vec3<f32> {
    var jit_2: vec3<f32>;
    var param_188: vec2<f32>;

    let _e338 = (*hp_7);
    let _e342 = (*hp_7)[2u];
    param_188 = ((_e338.xy * 3.1f) + vec2(_e342));
    let _e345 = hash3_u0028_vf2_u003b((&param_188));
    let _e350 = (*m_4).surface[1u];
    jit_2 = (((_e345 - vec3(0.5f)) * _e350) * 0.5f);
    let _e353 = (*d_7);
    let _e354 = (*n_10);
    let _e355 = jit_2;
    return normalize(reflect(_e353, normalize((_e354 + _e355))));
}

fn wave_normal_u0028_vf3_u003b_vf3_u003b(n_11: ptr<function, vec3<f32>>, hp_8: ptr<function, vec3<f32>>) -> vec3<f32> {
    var t_7: f32;
    var q_4: vec2<f32>;
    var local_31: vec2<f32>;
    var a_8: f32;
    var param_189: vec2<f32>;
    var b_7: f32;
    var param_190: vec2<f32>;
    var p_5: vec3<f32>;
    var local_32: vec3<f32>;

    let _e343 = g_time;
    t_7 = _e343;
    let _e345 = (*n_11)[1u];
    if (abs(_e345) > 0.5f) {
        let _e349 = (*hp_8)[0u];
        let _e351 = (*hp_8)[2u];
        local_31 = vec2<f32>(_e349, _e351);
    } else {
        let _e354 = (*hp_8)[0u];
        let _e356 = (*hp_8)[1u];
        local_31 = vec2<f32>(_e354, _e356);
    }
    let _e358 = local_31;
    q_4 = _e358;
    let _e359 = q_4;
    let _e361 = t_7;
    let _e363 = t_7;
    param_189 = ((_e359 * vec2<f32>(0.45f, 0.6f)) + vec2<f32>((_e361 * 1.3f), (_e363 * 0.4f)));
    let _e367 = vnoise_u0028_vf2_u003b((&param_189));
    a_8 = (_e367 - 0.5f);
    let _e369 = q_4;
    let _e371 = t_7;
    let _e374 = t_7;
    param_190 = (((_e369 * vec2<f32>(0.6f, 0.45f)) + vec2<f32>((-(_e371) * 0.9f), (_e374 * 1.1f))) + vec2(13f));
    let _e380 = vnoise_u0028_vf2_u003b((&param_190));
    b_7 = (_e380 - 0.5f);
    let _e383 = (*n_11)[1u];
    if (abs(_e383) > 0.5f) {
        let _e386 = a_8;
        let _e387 = b_7;
        local_32 = (vec3<f32>(_e386, 0f, _e387) * 0.45f);
    } else {
        let _e390 = a_8;
        let _e391 = b_7;
        local_32 = (vec3<f32>(_e390, _e391, 0f) * 0.18f);
    }
    let _e394 = local_32;
    p_5 = _e394;
    let _e395 = (*n_11);
    let _e396 = p_5;
    return normalize((_e395 + _e396));
}

fn field_at_u0028_vf3_u003b(q_5: ptr<function, vec3<f32>>) -> f32 {
    var o_4: vec4<f32>;
    var s_9: f32;

    let _e335 = (*q_5);
    let _e337 = g_world;
    let _e339 = textureSampleLevel(occ_tex, occ_tex_smp, (_e335.xy / _e337), 0f);
    o_4 = _e339;
    let _e340 = g_sigmaMax;
    let _e341 = g_F;
    let _e342 = g_T0_;
    let _e344 = (*q_5)[2u];
    s_9 = (_e340 * smoothstep(_e341, _e342, _e344));
    let _e347 = s_9;
    if (_e347 <= 1f) {
        let _e350 = o_4[0u];
        let _e352 = o_4[1u];
        let _e353 = s_9;
        return mix(_e350, _e352, _e353);
    }
    let _e355 = s_9;
    if (_e355 <= 2.5f) {
        let _e358 = o_4[1u];
        let _e360 = o_4[2u];
        let _e361 = s_9;
        return mix(_e358, _e360, ((_e361 - 1f) / 1.5f));
    }
    let _e366 = o_4[2u];
    let _e368 = o_4[3u];
    let _e369 = s_9;
    return mix(_e366, _e368, clamp(((_e369 - 2.5f) / 2f), 0f, 1f));
}

fn shade_side_u0028_vf3_u003b_vf3_u003b(hp_9: ptr<function, vec3<f32>>, d_8: ptr<function, vec3<f32>>) -> vec3<f32> {
    var g_1: vec3<f32>;
    var param_191: vec3<f32>;
    var param_192: vec3<f32>;
    var param_193: vec3<f32>;
    var param_194: vec3<f32>;
    var param_195: vec3<f32>;
    var param_196: vec3<f32>;
    var n_12: vec3<f32>;
    var local_33: vec3<f32>;
    var base_4: vec3<f32>;
    var lp_2: vec2<f32>;
    var ld_5: vec4<f32>;
    var param_197: vec2<f32>;
    var l_5: vec3<f32>;
    var param_198: vec4<f32>;
    var lam_1: f32;
    var k_10: f32;
    var ao_1: f32;
    var fade: f32;
    var param_199: vec3<f32>;
    var col_4: vec3<f32>;
    var param_200: vec3<f32>;
    var h_7: vec3<f32>;
    var param_201: vec2<f32>;

    let _e358 = (*hp_9);
    param_191 = (_e358 + vec3<f32>(0.6f, 0f, 0f));
    let _e360 = field_at_u0028_vf3_u003b((&param_191));
    let _e361 = (*hp_9);
    param_192 = (_e361 - vec3<f32>(0.6f, 0f, 0f));
    let _e363 = field_at_u0028_vf3_u003b((&param_192));
    let _e365 = (*hp_9);
    param_193 = (_e365 + vec3<f32>(0f, 0.6f, 0f));
    let _e367 = field_at_u0028_vf3_u003b((&param_193));
    let _e368 = (*hp_9);
    param_194 = (_e368 - vec3<f32>(0f, 0.6f, 0f));
    let _e370 = field_at_u0028_vf3_u003b((&param_194));
    let _e372 = (*hp_9);
    param_195 = (_e372 + vec3<f32>(0f, 0f, 1.2f));
    let _e374 = field_at_u0028_vf3_u003b((&param_195));
    let _e375 = (*hp_9);
    param_196 = (_e375 - vec3<f32>(0f, 0f, 1.2f));
    let _e377 = field_at_u0028_vf3_u003b((&param_196));
    g_1 = vec3<f32>((_e360 - _e363), (_e367 - _e370), (_e374 - _e377));
    let _e380 = g_1;
    let _e381 = g_1;
    if (dot(_e380, _e381) > 0.00000001f) {
        let _e384 = g_1;
        local_33 = -(normalize(_e384));
    } else {
        local_33 = vec3<f32>(0f, 0f, -1f);
    }
    let _e387 = local_33;
    n_12 = _e387;
    let _e388 = (*hp_9);
    let _e390 = g_world;
    let _e392 = textureSampleLevel(side_tex, side_tex_smp, (_e388.xy / _e390), 0f);
    base_4 = _e392.xyz;
    let _e394 = (*hp_9);
    let _e396 = n_12;
    lp_2 = (_e394.xy + (_e396.xy * 2f));
    let _e400 = lp_2;
    let _e401 = g_world;
    param_197 = clamp(_e400, vec2<f32>(0.5f, 0.5f), (_e401 - vec2(0.5f)));
    let _e405 = light_at_u0028_vf2_u003b((&param_197));
    ld_5 = _e405;
    let _e406 = ld_5;
    param_198 = _e406;
    let _e407 = light_dir3_u0028_vf4_u003b((&param_198));
    l_5 = _e407;
    let _e408 = n_12;
    let _e409 = l_5;
    lam_1 = max(dot(_e408, _e409), 0f);
    let _e414 = rp.view[2u];
    let _e416 = lam_1;
    let _e419 = ld_5[2u];
    let _e425 = n_12[1u];
    let _e431 = n_12[1u];
    k_10 = ((((_e414 * 0.85f) + ((0.5f * _e416) * (0.35f + (0.65f * _e419)))) + (0.22f * max(-(_e425), 0f))) - (0.12f * max(_e431, 0f)));
    let _e435 = (*hp_9);
    let _e437 = g_world;
    let _e439 = textureSampleLevel(occ_tex, occ_tex_smp, (_e435.xy / _e437), 0f);
    ao_1 = (1f - (0.35f * smoothstep(0.55f, 0.95f, _e439.w)));
    let _e444 = g_F;
    let _e445 = g_T0_;
    let _e447 = (*hp_9)[2u];
    fade = smoothstep(_e444, _e445, _e447);
    let _e449 = k_10;
    let _e450 = k_10;
    let _e451 = n_12;
    param_199 = _e451;
    let _e452 = form_k_u0028_vf3_u003b((&param_199));
    let _e457 = rp.look[0u];
    k_10 = mix(_e449, ((_e450 * _e452) * 1.25f), _e457);
    let _e459 = base_4;
    let _e460 = k_10;
    let _e462 = ao_1;
    let _e464 = n_12;
    param_200 = _e464;
    let _e465 = form_tint_u0028_vf3_u003b((&param_200));
    col_4 = (((_e459 * _e460) * _e462) * _e465);
    let _e467 = l_5;
    let _e468 = (*d_8);
    h_7 = normalize((_e467 - _e468));
    let _e471 = lp_2;
    let _e472 = g_world;
    param_201 = clamp(_e471, vec2<f32>(0.5f, 0.5f), (_e472 - vec2(0.5f)));
    let _e476 = fluence_at_u0028_vf2_u003b((&param_201));
    let _e477 = n_12;
    let _e478 = h_7;
    let _e484 = fade;
    let _e487 = col_4;
    col_4 = (_e487 + (((_e476 * pow(max(dot(_e477, _e478), 0f), 20f)) * 0.18f) * (1f - _e484)));
    let _e489 = col_4;
    let _e491 = rp.haze;
    let _e495 = rp.ambient;
    let _e499 = fade;
    let _e500 = g_backFade;
    col_4 = mix(_e489, ((_e491.xyz * 0.5f) + (_e495.xyz * 0.8f)), vec3(((_e499 * _e500) * 0.55f)));
    let _e505 = fade;
    let _e506 = g_backFade;
    let _e510 = col_4;
    col_4 = (_e510 * (1f - ((_e505 * _e506) * 0.35f)));
    let _e512 = col_4;
    return _e512;
}

fn smooth_hit_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b_f1_u003b(o_5: ptr<function, vec3<f32>>, d_9: ptr<function, vec3<f32>>, t0_: ptr<function, f32>, t1_: ptr<function, f32>, tHit: ptr<function, f32>) -> bool {
    var o4_1: vec4<f32>;
    var param_202: vec3<f32>;
    var tPrev_1: f32;
    var k_11: i32;
    var t_8: f32;
    var param_203: vec3<f32>;
    var a_9: f32;
    var b_8: f32;
    var j_1: i32;
    var m_5: f32;
    var param_204: vec3<f32>;
    var phi_4750_: bool;

    let _e349 = g_cost[2u];
    g_cost[2u] = (_e349 + 2u);
    let _e352 = (*t0_);
    (*tHit) = _e352;
    let _e353 = (*o_5);
    let _e355 = (*d_9);
    let _e357 = (*t0_);
    let _e358 = (*t1_);
    let _e363 = g_world;
    let _e365 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e353.xy + ((_e355.xy * (_e357 + _e358)) * 0.5f)) / _e363), 0f);
    o4_1 = _e365;
    let _e367 = o4_1[3u];
    let _e368 = (_e367 < 0.02f);
    phi_4750_ = _e368;
    if _e368 {
        let _e370 = o4_1[0u];
        phi_4750_ = (_e370 < 0.5f);
    }
    let _e373 = phi_4750_;
    if _e373 {
        return false;
    }
    let _e374 = (*o_5);
    let _e375 = (*d_9);
    let _e376 = (*t0_);
    param_202 = (_e374 + (_e375 * _e376));
    let _e379 = field_at_u0028_vf3_u003b((&param_202));
    if (_e379 > 0.5f) {
        return true;
    }
    let _e381 = (*t0_);
    tPrev_1 = _e381;
    k_11 = 1i;
    loop {
        let _e382 = k_11;
        if (_e382 <= 2i) {
            let _e384 = (*t0_);
            let _e385 = (*t1_);
            let _e386 = k_11;
            t_8 = mix(_e384, _e385, (f32(_e386) * 0.5f));
            let _e390 = (*o_5);
            let _e391 = (*d_9);
            let _e392 = t_8;
            param_203 = (_e390 + (_e391 * _e392));
            let _e395 = field_at_u0028_vf3_u003b((&param_203));
            if (_e395 > 0.5f) {
                let _e397 = tPrev_1;
                a_9 = _e397;
                let _e398 = t_8;
                b_8 = _e398;
                j_1 = 0i;
                loop {
                    let _e399 = j_1;
                    if (_e399 < 4i) {
                        let _e401 = a_9;
                        let _e402 = b_8;
                        m_5 = ((_e401 + _e402) * 0.5f);
                        let _e405 = (*o_5);
                        let _e406 = (*d_9);
                        let _e407 = m_5;
                        param_204 = (_e405 + (_e406 * _e407));
                        let _e410 = field_at_u0028_vf3_u003b((&param_204));
                        if (_e410 > 0.5f) {
                            let _e412 = m_5;
                            b_8 = _e412;
                        } else {
                            let _e413 = m_5;
                            a_9 = _e413;
                        }
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e414 = j_1;
                        j_1 = (_e414 + 1i);
                    }
                }
                let _e416 = b_8;
                (*tHit) = _e416;
                return true;
            }
            let _e417 = t_8;
            tPrev_1 = _e417;
            continue;
        } else {
            break;
        }
        continuing {
            let _e418 = k_11;
            k_11 = (_e418 + 1i);
        }
    }
    return false;
}

fn outside_fill_u0028_vi2_u003b_b1_u003b(c_15: ptr<function, vec2<i32>>, solid: ptr<function, bool>) -> vec3<f32> {
    var ce: vec2<i32>;
    var em: Material;
    var aEdge: vec3<f32>;
    var light: vec3<f32>;
    var k_12: i32;
    var q_6: vec2<i32>;
    var local_34: vec2<i32>;
    var sq: vec4<f32>;
    var local_35: vec3<f32>;
    var h_8: f32;
    var param_205: vec2<f32>;
    var a0_2: vec3<f32>;
    var param_206: vec2<f32>;
    var dist: f32;

    let _e348 = (*c_15);
    let _e349 = g_world;
    ce = clamp(_e348, vec2<i32>(0i, 0i), (vec2<i32>(_e349) - vec2(1i)));
    let _e354 = ce;
    let _e355 = textureLoad(l0s, _e354, 0i);
    (*solid) = (_e355.w >= 0.99f);
    let _e358 = (*solid);
    if !(_e358) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e360 = ce;
    let _e361 = textureLoad(cells, _e360, 0i);
    let _e366 = unnamed.mats[(_e361.x & 255u)];
    em.color_a = _e366.color_a;
    em.color_b = _e366.color_b;
    em.emission = _e366.emission;
    em.phys = _e366.phys;
    em.thermo = _e366.thermo;
    em.burn = _e366.burn;
    em.optics = _e366.optics;
    em.scatter = _e366.scatter;
    em.ids = _e366.ids;
    em.ids2_ = _e366.ids2_;
    em.misc = _e366.misc;
    em.surface = _e366.surface;
    em.sss = _e366.sss;
    em.sss_color = _e366.sss_color;
    em.optics2_ = _e366.optics2_;
    em.pal0_ = _e366.pal0_;
    em.pal1_ = _e366.pal1_;
    em.pal2_ = _e366.pal2_;
    em.pal3_ = _e366.pal3_;
    em.accent = _e366.accent;
    em.flame = _e366.flame;
    let _e410 = em.color_a;
    let _e413 = em.color_b;
    aEdge = mix(_e410.xyz, _e413.xyz, vec3(0.5f));
    light = vec3<f32>(0f, 0f, 0f);
    k_12 = -3i;
    loop {
        let _e417 = k_12;
        if (_e417 <= 3i) {
            let _e419 = ce;
            let _e421 = ce[0u];
            let _e423 = (*c_15)[0u];
            if (_e421 == _e423) {
                let _e425 = k_12;
                local_34 = vec2<i32>(_e425, 0i);
            } else {
                let _e427 = k_12;
                local_34 = vec2<i32>(0i, _e427);
            }
            let _e429 = local_34;
            let _e431 = g_world;
            q_6 = clamp((_e419 + _e429), vec2<i32>(0i, 0i), (vec2<i32>(_e431) - vec2(1i)));
            let _e436 = q_6;
            let _e437 = textureLoad(l0s, _e436, 0i);
            sq = _e437;
            let _e439 = sq[3u];
            if (_e439 >= 0.99f) {
                let _e441 = sq;
                local_35 = _e441.xyz;
            } else {
                local_35 = vec3<f32>(0f, 0f, 0f);
            }
            let _e443 = local_35;
            let _e444 = light;
            light = (_e444 + _e443);
            continue;
        } else {
            break;
        }
        continuing {
            let _e446 = k_12;
            k_12 = (_e446 + 1i);
        }
    }
    let _e448 = light;
    let _e451 = aEdge;
    light = ((_e448 / vec3(7f)) / max(_e451, vec3<f32>(0.03f, 0.03f, 0.03f)));
    let _e454 = (*c_15);
    param_205 = (vec2<f32>(_e454) + vec2<f32>(5f, 0f));
    let _e457 = hash21_u0028_vf2_u003b((&param_205));
    h_8 = _e457;
    let _e459 = em.color_a;
    let _e462 = em.color_b;
    let _e464 = h_8;
    let _e467 = (*c_15);
    param_206 = (vec2<f32>(_e467) + vec2<f32>(11f, 37f));
    let _e470 = hash21_u0028_vf2_u003b((&param_206));
    let _e474 = em.color_a[3u];
    a0_2 = (mix(_e459.xyz, _e462.xyz, vec3(_e464)) * (1f + (((_e470 - 0.5f) * _e474) * 0.9f)));
    let _e479 = (*c_15);
    let _e480 = ce;
    dist = length(vec2<f32>((_e479 - _e480)));
    let _e484 = a0_2;
    let _e485 = light;
    let _e487 = dist;
    return ((_e484 * _e485) * exp((-(_e487) / 18f)));
}

fn heat_offset_u0028_vf2_u003b_f1_u003b_f1_u003b(xy_9: ptr<function, vec2<f32>>, heat: ptr<function, f32>, time: ptr<function, f32>) -> vec2<f32> {
    var t_9: f32;
    var param_207: vec2<f32>;
    var param_208: vec2<f32>;
    var phi_4633_: bool;

    let _e338 = (*heat);
    let _e339 = (_e338 <= 0f);
    phi_4633_ = _e339;
    if !(_e339) {
        let _e343 = rp.fx[0u];
        phi_4633_ = (_e343 <= 0f);
    }
    let _e346 = phi_4633_;
    if _e346 {
        return vec2<f32>(0f, 0f);
    }
    let _e347 = (*time);
    t_9 = (_e347 * 6f);
    let _e349 = (*xy_9);
    let _e351 = t_9;
    param_207 = ((_e349 * 0.35f) + vec2<f32>(0f, _e351));
    let _e354 = vnoise_u0028_vf2_u003b((&param_207));
    let _e356 = (*xy_9);
    let _e358 = t_9;
    param_208 = ((_e356 * 0.35f) + vec2<f32>(17f, (_e358 * 1.3f)));
    let _e362 = vnoise_u0028_vf2_u003b((&param_208));
    let _e365 = (*heat);
    let _e369 = rp.fx[0u];
    return (((vec2<f32>((_e354 - 0.5f), (_e362 - 0.5f)) * _e365) * _e369) * 2.2f);
}

fn view_globals_u0028_() {
    let _e333 = pc.i1_;
    g_world = vec2<f32>(_e333.xy);
    let _e338 = rp.misc[0u];
    g_time = _e338;
    let _e341 = rp.cam_right[3u];
    g_T0_ = _e341;
    let _e344 = rp.cam_down[0u];
    g_F = _e344;
    let _e347 = rp.cam_down[1u];
    g_sigmaMax = _e347;
    let _e350 = rp.cam_down[2u];
    g_backFade = _e350;
    let _e353 = rp.cam_right[1u];
    g_frontRim = _e353;
    let _e356 = rp.misc2_[3u];
    g_bgSmooth = _e356;
    return;
}

fn main_1() {
    var p_6: vec2<i32>;
    var time_1: f32;
    var suv: vec2<f32>;
    var ndc: vec2<f32>;
    var plane: vec2<f32>;
    var d_10: vec3<f32>;
    var pitch: f32;
    var cp: f32;
    var sp_2: f32;
    var cy: f32;
    var sy: f32;
    var p0_1: vec3<f32>;
    var C_1: vec3<f32>;
    var T_1: vec3<f32>;
    var distort_1: vec2<f32>;
    var so: vec3<f32>;
    var zHit: f32;
    var glossy: bool;
    var gHp: vec3<f32>;
    var gN: vec3<f32>;
    var gD: vec3<f32>;
    var gBase: vec3<f32>;
    var gT: vec3<f32>;
    var gMid: u32;
    var nRefl: i32;
    var c_16: vec2<i32>;
    var param_209: vec2<i32>;
    var s_10: vec4<f32>;
    var tr_3: vec4<f32>;
    var local_36: vec3<f32>;
    var param_210: vec2<i32>;
    var param_211: vec3<f32>;
    var param_212: i32;
    var param_213: vec3<f32>;
    var param_214: vec2<i32>;
    var param_215: vec3<f32>;
    var param_216: vec2<f32>;
    var param_217: f32;
    var param_218: f32;
    var fc: vec3<f32>;
    var solid_1: bool;
    var param_219: vec2<i32>;
    var param_220: bool;
    var cell_6: vec2<i32>;
    var stp_4: vec2<i32>;
    var tDelta_4: vec2<f32>;
    var tMax_4: vec2<f32>;
    var param_221: vec2<f32>;
    var param_222: vec2<f32>;
    var param_223: vec2<i32>;
    var param_224: vec2<i32>;
    var param_225: vec2<f32>;
    var param_226: vec2<f32>;
    var tEnd_1: f32;
    var tCur_3: f32;
    var face_7: i32;
    var inMat: u32;
    var events: i32;
    var i_5: i32;
    var tNext_2: f32;
    var restart: bool;
    var deep: bool;
    var tHit_1: f32;
    var param_227: vec3<f32>;
    var param_228: vec3<f32>;
    var param_229: f32;
    var param_230: f32;
    var param_231: f32;
    var param_232: vec3<f32>;
    var param_233: vec3<f32>;
    var param_234: vec2<i32>;
    var fc_1: vec3<f32>;
    var solid_2: bool;
    var param_235: vec2<i32>;
    var param_236: bool;
    var param_237: vec2<i32>;
    var s_11: vec4<f32>;
    var melted: bool;
    var hp_10: vec3<f32>;
    var param_238: vec3<f32>;
    var param_239: i32;
    var param_240: vec3<f32>;
    var param_241: vec2<i32>;
    var param_242: vec3<f32>;
    var omid: u32;
    var om: Material;
    var param_243: i32;
    var mid_2: u32;
    var local_37: u32;
    var mm: Material;
    var transl: bool;
    var hp_11: vec3<f32>;
    var n_13: vec3<f32>;
    var param_244: i32;
    var n2_1: vec2<f32>;
    var param_245: vec2<f32>;
    var param_246: vec3<f32>;
    var param_247: vec3<f32>;
    var n2_2: vec2<f32>;
    var facet: vec3<f32>;
    var param_248: vec2<f32>;
    var ior: f32;
    var cosi: f32;
    var f0_3: f32;
    var F_2: f32;
    var rd: vec3<f32>;
    var env_1: vec3<f32>;
    var param_249: vec2<f32>;
    var param_250: f32;
    var param_251: vec3<f32>;
    var rOrg: array<vec3<f32>, 4>;
    var rDir: array<vec3<f32>, 4>;
    var rW: array<vec3<f32>, 4>;
    var rEnv: array<vec3<f32>, 4>;
    var param_252: vec2<f32>;
    var param_253: f32;
    var param_254: vec2<f32>;
    var param_255: f32;
    var rim_1: f32;
    var param_256: vec2<f32>;
    var param_257: f32;
    var lp_3: vec2<f32>;
    var ld_6: vec4<f32>;
    var param_258: vec2<f32>;
    var hl: vec3<f32>;
    var param_259: vec4<f32>;
    var param_260: vec2<f32>;
    var param_261: Material;
    var param_262: vec3<f32>;
    var param_263: vec3<f32>;
    var param_264: vec3<f32>;
    var param_265: vec3<f32>;
    var param_266: vec3<f32>;
    var nd: vec3<f32>;
    var pm: Material;
    var ior_1: f32;
    var param_267: vec3<f32>;
    var param_268: vec3<f32>;
    var nd_1: vec3<f32>;
    var local_38: vec3<f32>;
    var local_39: vec3<f32>;
    var param_269: vec2<f32>;
    var param_270: vec2<f32>;
    var param_271: vec2<i32>;
    var param_272: vec2<i32>;
    var param_273: vec2<f32>;
    var param_274: vec2<f32>;
    var tr_4: vec4<f32>;
    var local_40: vec4<f32>;
    var param_275: vec3<f32>;
    var k_13: f32;
    var param_276: vec2<f32>;
    var param_277: f32;
    var param_278: f32;
    var param_279: vec3<f32>;
    var param_280: vec2<i32>;
    var param_281: vec2<i32>;
    var param_282: vec2<f32>;
    var param_283: vec2<f32>;
    var param_284: f32;
    var param_285: i32;
    var param_286: vec3<f32>;
    var nd_2: vec3<f32>;
    var depthOut: f32;
    var gDir: vec3<f32>;
    var local_41: vec3<f32>;
    var param_287: vec3<f32>;
    var param_288: vec3<f32>;
    var param_289: vec3<f32>;
    var param_290: Material;
    var gl: bool;
    var r_5: i32;
    var last: bool;
    var refl: bool;
    var bo: vec3<f32>;
    var bd: vec3<f32>;
    var bT: vec3<f32>;
    var rc_1: vec3<f32>;
    var bdist: vec2<f32>;
    var param_291: vec3<f32>;
    var param_292: vec3<f32>;
    var param_293: vec3<f32>;
    var param_294: vec3<f32>;
    var bgc: vec3<f32>;
    var param_295: vec3<f32>;
    var param_296: vec3<f32>;
    var param_297: vec2<f32>;
    var param_298: vec3<f32>;
    var param_299: vec3<f32>;
    var param_300: vec3<f32>;
    var param_301: vec3<f32>;
    var param_302: vec3<f32>;
    var param_303: Material;
    var param_304: vec3<f32>;
    var fg: vec4<f32>;
    var Lv: vec3<f32>;
    var Tv_1: f32;
    var param_305: vec3<f32>;
    var param_306: vec3<f32>;
    var param_307: vec2<i32>;
    var param_308: f32;
    var bc: vec2<i32>;
    var param_309: vec2<i32>;
    var param_310: vec2<f32>;
    var param_311: vec3<f32>;
    var param_312: vec3<f32>;
    var total: u32;
    var mc: vec2<i32>;
    var mid0_: u32;
    var param_313: vec2<i32>;
    var local_42: u32;
    var phi_5423_: bool;
    var phi_5555_: bool;
    var phi_5830_: bool;
    var phi_5831_: bool;
    var phi_5832_: bool;
    var phi_5929_: bool;
    var phi_5936_: bool;
    var phi_6019_: bool;
    var phi_6037_: bool;
    var phi_6038_: bool;
    var phi_6179_: bool;
    var phi_6240_: bool;
    var phi_6367_: bool;
    var phi_6555_: bool;
    var phi_6563_: bool;
    var phi_6570_: bool;
    var phi_6577_: bool;
    var phi_6634_: bool;
    var phi_6669_: bool;
    var phi_6770_: bool;
    var phi_7023_: bool;
    var phi_7061_: bool;

    g_useCells = false;
    g_cost = vec3<u32>(0u, 0u, 0u);
    let _e543 = gl_GlobalInvocationID_1;
    p_6 = bitcast<vec2<i32>>(_e543.xy);
    let _e546 = p_6;
    let _e548 = pc.i0_;
    if any((_e546 >= _e548.xy)) {
        return;
    }
    view_globals_u0028_();
    let _e554 = pc.i1_[2u];
    let _e555 = (_e554 != 0i);
    phi_5423_ = _e555;
    if _e555 {
        let _e558 = rp.look2_[3u];
        phi_5423_ = (_e558 > 0f);
    }
    let _e561 = phi_5423_;
    let _e562 = g_T0_;
    g_useCells = (_e561 && (_e562 < 0.01f));
    let _e565 = g_time;
    time_1 = _e565;
    let _e566 = p_6;
    let _e571 = pc.i0_;
    suv = ((vec2<f32>(_e566) + vec2(0.5f)) / vec2<f32>(_e571.xy));
    let _e575 = suv;
    ndc = ((_e575 * 2f) - vec2(1f));
    let _e580 = rp.cam_plane;
    let _e582 = ndc;
    let _e584 = rp.cam_plane;
    plane = (_e580.xy + (_e582 * _e584.zw));
    let _e588 = plane;
    let _e590 = rp.cam_plane;
    let _e592 = (_e588 - _e590.xy);
    let _e595 = rp.cam_tilt[0u];
    d_10 = normalize(vec3<f32>(_e592.x, _e592.y, _e595));
    let _e602 = rp.cam_tilt[2u];
    let _e605 = rp.cam_tilt[1u];
    let _e607 = suv[1u];
    let _e612 = rp.cam_tilt[3u];
    pitch = mix(_e602, _e605, pow(clamp((1f - _e607), 0f, 1f), _e612));
    let _e615 = pitch;
    cp = cos(_e615);
    let _e617 = pitch;
    sp_2 = sin(_e617);
    let _e620 = d_10[0u];
    let _e622 = d_10[1u];
    let _e623 = cp;
    let _e626 = d_10[2u];
    let _e627 = sp_2;
    let _e631 = d_10[1u];
    let _e633 = sp_2;
    let _e636 = d_10[2u];
    let _e637 = cp;
    d_10 = vec3<f32>(_e620, ((_e622 * _e623) + (_e626 * _e627)), ((-(_e631) * _e633) + (_e636 * _e637)));
    let _e643 = rp.cam_right[0u];
    cy = cos(_e643);
    let _e647 = rp.cam_right[0u];
    sy = sin(_e647);
    let _e650 = d_10[0u];
    let _e651 = cy;
    let _e654 = d_10[2u];
    let _e655 = sy;
    let _e659 = d_10[1u];
    let _e661 = d_10[0u];
    let _e663 = sy;
    let _e666 = d_10[2u];
    let _e667 = cy;
    d_10 = normalize(vec3<f32>(((_e650 * _e651) + (_e654 * _e655)), _e659, ((-(_e661) * _e663) + (_e666 * _e667))));
    let _e673 = d_10[2u];
    d_10[2u] = max(_e673, 0.0001f);
    let _e676 = plane;
    p0_1 = vec3<f32>(_e676.x, _e676.y, 0f);
    let _e682 = rp.look2_[3u];
    let _e683 = (_e682 > 0f);
    phi_5555_ = _e683;
    if _e683 {
        let _e686 = rp.cam_right[3u];
        phi_5555_ = (_e686 < 0.01f);
    }
    let _e689 = phi_5555_;
    if _e689 {
        let _e691 = rp.look2_;
        let _e692 = _e691.xy;
        d_10 = normalize(vec3<f32>(_e692.x, _e692.y, 1f));
    }
    C_1 = vec3<f32>(0f, 0f, 0f);
    T_1 = vec3<f32>(1f, 1f, 1f);
    distort_1 = vec2<f32>(0f, 0f);
    let _e697 = p0_1;
    so = _e697;
    zHit = 0f;
    glossy = false;
    gHp = vec3<f32>(0f, 0f, 0f);
    gN = vec3<f32>(0f, 0f, 0f);
    gD = vec3<f32>(0f, 0f, 0f);
    gBase = vec3<f32>(0f, 0f, 0f);
    gT = vec3<f32>(0f, 0f, 0f);
    gMid = 0u;
    nRefl = 0i;
    let _e698 = g_T0_;
    if (_e698 < 0.01f) {
        let _e700 = p0_1;
        c_16 = vec2<i32>(floor(_e700.xy));
        let _e704 = c_16;
        param_209 = _e704;
        let _e705 = inw_u0028_vi2_u003b((&param_209));
        if _e705 {
            let _e706 = c_16;
            let _e707 = textureLoad(l0s, _e706, 0i);
            s_10 = _e707;
            let _e708 = c_16;
            let _e709 = textureLoad(l0t, _e708, 0i);
            tr_3 = _e709;
            let _e711 = s_10[3u];
            if (_e711 >= 0.99f) {
                let _e713 = g_useCells;
                if _e713 {
                    let _e714 = c_16;
                    param_210 = _e714;
                    let _e715 = cell_shade_at_u0028_vi2_u003b((&param_210));
                    local_36 = _e715.xyz;
                } else {
                    let _e717 = s_10;
                    param_211 = _e717.xyz;
                    param_212 = 0i;
                    let _e719 = p0_1;
                    param_213 = _e719;
                    let _e720 = c_16;
                    param_214 = _e720;
                    let _e721 = d_10;
                    param_215 = _e721;
                    let _e722 = shade_l0_u0028_vf3_u003b_i1_u003b_vf3_u003b_vi2_u003b_vf3_u003b((&param_211), (&param_212), (&param_213), (&param_214), (&param_215));
                    local_36 = _e722;
                }
                let _e723 = local_36;
                C_1 = _e723;
                T_1 = vec3<f32>(0f, 0f, 0f);
            } else {
                let _e724 = s_10;
                C_1 = _e724.xyz;
                let _e726 = tr_3;
                T_1 = _e726.xyz;
                let _e728 = p0_1;
                param_216 = _e728.xy;
                let _e731 = tr_3[3u];
                param_217 = _e731;
                let _e732 = time_1;
                param_218 = _e732;
                let _e733 = heat_offset_u0028_vf2_u003b_f1_u003b_f1_u003b((&param_216), (&param_217), (&param_218));
                distort_1 = _e733;
            }
        } else {
            let _e734 = c_16;
            param_219 = _e734;
            let _e735 = outside_fill_u0028_vi2_u003b_b1_u003b((&param_219), (&param_220));
            let _e736 = param_220;
            solid_1 = _e736;
            fc = _e735;
            let _e737 = solid_1;
            if _e737 {
                let _e738 = fc;
                C_1 = _e738;
                T_1 = vec3<f32>(0f, 0f, 0f);
            }
        }
    } else {
        let _e739 = so;
        cell_6 = vec2<i32>(floor(_e739.xy));
        let _e743 = so;
        param_221 = _e743.xy;
        let _e745 = d_10;
        param_222 = _e745.xy;
        let _e747 = cell_6;
        param_223 = _e747;
        dda_init_cell_u0028_vf2_u003b_vf2_u003b_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b((&param_221), (&param_222), (&param_223), (&param_224), (&param_225), (&param_226));
        let _e748 = param_224;
        stp_4 = _e748;
        let _e749 = param_225;
        tDelta_4 = _e749;
        let _e750 = param_226;
        tMax_4 = _e750;
        let _e751 = g_T0_;
        let _e753 = d_10[2u];
        tEnd_1 = (_e751 / _e753);
        tCur_3 = 0f;
        face_7 = 0i;
        inMat = 0u;
        events = 0i;
        i_5 = 0i;
        loop {
            let _e755 = i_5;
            if (_e755 < 64i) {
                let _e758 = g_cost[2u];
                g_cost[2u] = (_e758 + bitcast<u32>(1i));
                let _e762 = tMax_4[0u];
                let _e764 = tMax_4[1u];
                let _e766 = tEnd_1;
                tNext_2 = min(min(_e762, _e764), _e766);
                restart = false;
                let _e769 = so[2u];
                let _e771 = d_10[2u];
                let _e772 = tCur_3;
                let _e775 = g_F;
                let _e777 = g_sigmaMax;
                deep = (((_e769 + (_e771 * _e772)) >= _e775) && (_e777 > 0f));
                let _e780 = deep;
                let _e781 = inMat;
                if (_e780 && (_e781 == 0u)) {
                    let _e784 = so;
                    param_227 = _e784;
                    let _e785 = d_10;
                    param_228 = _e785;
                    let _e786 = tCur_3;
                    param_229 = _e786;
                    let _e787 = tNext_2;
                    param_230 = _e787;
                    let _e788 = smooth_hit_u0028_vf3_u003b_vf3_u003b_f1_u003b_f1_u003b_f1_u003b((&param_227), (&param_228), (&param_229), (&param_230), (&param_231));
                    let _e789 = param_231;
                    tHit_1 = _e789;
                    if _e788 {
                        let _e790 = T_1;
                        let _e791 = so;
                        let _e792 = d_10;
                        let _e793 = tHit_1;
                        param_232 = (_e791 + (_e792 * _e793));
                        let _e796 = d_10;
                        param_233 = _e796;
                        let _e797 = shade_side_u0028_vf3_u003b_vf3_u003b((&param_232), (&param_233));
                        let _e799 = C_1;
                        C_1 = (_e799 + (_e790 * _e797));
                        let _e802 = so[2u];
                        let _e804 = d_10[2u];
                        let _e805 = tHit_1;
                        zHit = (_e802 + (_e804 * _e805));
                        T_1 = vec3<f32>(0f, 0f, 0f);
                        break;
                    }
                }
                let _e808 = cell_6;
                param_234 = _e808;
                let _e809 = inw_u0028_vi2_u003b((&param_234));
                let _e811 = deep;
                if (!(_e809) && !(_e811)) {
                    let _e814 = cell_6;
                    param_235 = _e814;
                    let _e815 = outside_fill_u0028_vi2_u003b_b1_u003b((&param_235), (&param_236));
                    let _e816 = param_236;
                    solid_2 = _e816;
                    fc_1 = _e815;
                    let _e817 = solid_2;
                    if _e817 {
                        let _e818 = T_1;
                        let _e819 = fc_1;
                        let _e821 = face_7;
                        let _e825 = C_1;
                        C_1 = (_e825 + ((_e818 * _e819) * select(0.7f, 1f, (_e821 == 0i))));
                        let _e828 = so[2u];
                        let _e830 = d_10[2u];
                        let _e831 = tCur_3;
                        zHit = (_e828 + (_e830 * _e831));
                        T_1 = vec3<f32>(0f, 0f, 0f);
                        break;
                    }
                }
                let _e834 = cell_6;
                param_237 = _e834;
                let _e835 = inw_u0028_vi2_u003b((&param_237));
                if _e835 {
                    let _e836 = cell_6;
                    let _e837 = textureLoad(l0s, _e836, 0i);
                    s_11 = _e837;
                    let _e838 = deep;
                    phi_5832_ = _e838;
                    if _e838 {
                        let _e840 = s_11[3u];
                        let _e841 = (_e840 >= 0.99f);
                        phi_5831_ = _e841;
                        if !(_e841) {
                            let _e844 = s_11[3u];
                            let _e845 = (_e844 > 0f);
                            phi_5830_ = _e845;
                            if _e845 {
                                let _e846 = cell_6;
                                let _e847 = textureLoad(cells, _e846, 0i);
                                let _e854 = unnamed.mats[(_e847.x & 255u)].ids[0u];
                                phi_5830_ = (_e854 == 2u);
                            }
                            let _e857 = phi_5830_;
                            phi_5831_ = _e857;
                        }
                        let _e859 = phi_5831_;
                        phi_5832_ = _e859;
                    }
                    let _e861 = phi_5832_;
                    melted = _e861;
                    let _e863 = s_11[3u];
                    let _e865 = melted;
                    if ((_e863 >= 0.99f) && !(_e865)) {
                        let _e868 = so;
                        let _e869 = d_10;
                        let _e870 = tCur_3;
                        hp_10 = (_e868 + (_e869 * _e870));
                        let _e873 = T_1;
                        let _e874 = s_11;
                        param_238 = _e874.xyz;
                        let _e876 = face_7;
                        param_239 = _e876;
                        let _e877 = hp_10;
                        param_240 = _e877;
                        let _e878 = cell_6;
                        param_241 = _e878;
                        let _e879 = d_10;
                        param_242 = _e879;
                        let _e880 = shade_l0_u0028_vf3_u003b_i1_u003b_vf3_u003b_vi2_u003b_vf3_u003b((&param_238), (&param_239), (&param_240), (&param_241), (&param_242));
                        let _e882 = C_1;
                        C_1 = (_e882 + (_e873 * _e880));
                        let _e885 = hp_10[2u];
                        zHit = _e885;
                        let _e886 = face_7;
                        if (_e886 == 1i) {
                            let _e888 = cell_6;
                            let _e889 = textureLoad(cells, _e888, 0i);
                            omid = (_e889.x & 255u);
                            let _e892 = omid;
                            let _e895 = unnamed.mats[_e892];
                            om.color_a = _e895.color_a;
                            om.color_b = _e895.color_b;
                            om.emission = _e895.emission;
                            om.phys = _e895.phys;
                            om.thermo = _e895.thermo;
                            om.burn = _e895.burn;
                            om.optics = _e895.optics;
                            om.scatter = _e895.scatter;
                            om.ids = _e895.ids;
                            om.ids2_ = _e895.ids2_;
                            om.misc = _e895.misc;
                            om.surface = _e895.surface;
                            om.sss = _e895.sss;
                            om.sss_color = _e895.sss_color;
                            om.optics2_ = _e895.optics2_;
                            om.pal0_ = _e895.pal0_;
                            om.pal1_ = _e895.pal1_;
                            om.pal2_ = _e895.pal2_;
                            om.pal3_ = _e895.pal3_;
                            om.accent = _e895.accent;
                            om.flame = _e895.flame;
                            let _e940 = om.surface[0u];
                            let _e941 = (_e940 > 0.5f);
                            phi_5929_ = _e941;
                            if _e941 {
                                let _e944 = om.surface[1u];
                                phi_5929_ = (_e944 < 0.4f);
                            }
                            let _e947 = phi_5929_;
                            phi_5936_ = _e947;
                            if !(_e947) {
                                let _e951 = om.sss[2u];
                                phi_5936_ = (_e951 > 0.5f);
                            }
                            let _e954 = phi_5936_;
                            if _e954 {
                                glossy = true;
                                let _e955 = hp_10;
                                gHp = _e955;
                                let _e956 = face_7;
                                param_243 = _e956;
                                let _e957 = face_n3_u0028_i1_u003b((&param_243));
                                gN = _e957;
                                let _e958 = d_10;
                                gD = _e958;
                                let _e959 = s_11;
                                gBase = _e959.xyz;
                                let _e961 = T_1;
                                gT = _e961;
                                let _e962 = omid;
                                gMid = _e962;
                            }
                        }
                        T_1 = vec3<f32>(0f, 0f, 0f);
                        break;
                    }
                    let _e963 = melted;
                    if _e963 {
                        s_11 = vec4<f32>(0f, 0f, 0f, 0f);
                    }
                    let _e964 = melted;
                    if _e964 {
                        local_37 = 0u;
                    } else {
                        let _e965 = cell_6;
                        let _e966 = textureLoad(cells, _e965, 0i);
                        local_37 = (_e966.x & 255u);
                    }
                    let _e969 = local_37;
                    mid_2 = _e969;
                    let _e970 = mid_2;
                    let _e973 = unnamed.mats[_e970];
                    mm.color_a = _e973.color_a;
                    mm.color_b = _e973.color_b;
                    mm.emission = _e973.emission;
                    mm.phys = _e973.phys;
                    mm.thermo = _e973.thermo;
                    mm.burn = _e973.burn;
                    mm.optics = _e973.optics;
                    mm.scatter = _e973.scatter;
                    mm.ids = _e973.ids;
                    mm.ids2_ = _e973.ids2_;
                    mm.misc = _e973.misc;
                    mm.surface = _e973.surface;
                    mm.sss = _e973.sss;
                    mm.sss_color = _e973.sss_color;
                    mm.optics2_ = _e973.optics2_;
                    mm.pal0_ = _e973.pal0_;
                    mm.pal1_ = _e973.pal1_;
                    mm.pal2_ = _e973.pal2_;
                    mm.pal3_ = _e973.pal3_;
                    mm.accent = _e973.accent;
                    mm.flame = _e973.flame;
                    let _e1016 = mid_2;
                    let _e1017 = (_e1016 != 0u);
                    phi_6019_ = _e1017;
                    if _e1017 {
                        let _e1020 = mm.ids[0u];
                        phi_6019_ = (_e1020 != 0u);
                    }
                    let _e1023 = phi_6019_;
                    transl = _e1023;
                    let _e1024 = events;
                    let _e1025 = (_e1024 < 4i);
                    phi_6038_ = _e1025;
                    if _e1025 {
                        let _e1026 = transl;
                        let _e1027 = mid_2;
                        let _e1028 = inMat;
                        let _e1030 = (_e1026 && (_e1027 != _e1028));
                        phi_6037_ = _e1030;
                        if !(_e1030) {
                            let _e1032 = transl;
                            let _e1034 = inMat;
                            phi_6037_ = (!(_e1032) && (_e1034 != 0u));
                        }
                        let _e1038 = phi_6037_;
                        phi_6038_ = _e1038;
                    }
                    let _e1040 = phi_6038_;
                    if _e1040 {
                        let _e1041 = so;
                        let _e1042 = d_10;
                        let _e1043 = tCur_3;
                        hp_11 = (_e1041 + (_e1042 * _e1043));
                        let _e1046 = face_7;
                        param_244 = _e1046;
                        let _e1047 = face_n3_u0028_i1_u003b((&param_244));
                        n_13 = _e1047;
                        let _e1048 = transl;
                        if _e1048 {
                            let _e1051 = mm.sss[2u];
                            if (_e1051 > 0f) {
                                let _e1053 = cell_6;
                                let _e1054 = textureLoad(gaux_img, _e1053, 0i);
                                n2_1 = _e1054.xy;
                                let _e1056 = face_7;
                                if (_e1056 == 0i) {
                                    let _e1058 = n2_1;
                                    let _e1059 = (_e1058 * 0.9f);
                                    n_13 = normalize(vec3<f32>(_e1059.x, _e1059.y, -1f));
                                }
                                let _e1064 = n_13;
                                let _e1065 = cell_6;
                                param_245 = (vec2<f32>(_e1065) * 1.9f);
                                let _e1068 = hash3_u0028_vf2_u003b((&param_245));
                                n_13 = normalize((_e1064 + ((_e1068 - vec3(0.5f)) * 0.08f)));
                            } else {
                                let _e1076 = mm.ids[0u];
                                if (_e1076 == 1u) {
                                    let _e1078 = n_13;
                                    let _e1079 = n_13;
                                    param_246 = _e1079;
                                    let _e1080 = hp_11;
                                    param_247 = _e1080;
                                    let _e1081 = wave_normal_u0028_vf3_u003b_vf3_u003b((&param_246), (&param_247));
                                    let _e1082 = face_7;
                                    n_13 = normalize(mix(_e1078, _e1081, vec3(select(1f, 0.25f, (_e1082 == 1i)))));
                                } else {
                                    let _e1088 = cell_6;
                                    let _e1089 = textureLoad(gaux_img, _e1088, 0i);
                                    n2_2 = _e1089.xy;
                                    let _e1091 = cell_6;
                                    let _e1094 = face_7;
                                    param_248 = ((vec2<f32>(_e1091) * 2.3f) + vec2(f32(_e1094)));
                                    let _e1098 = hash3_u0028_vf2_u003b((&param_248));
                                    facet = ((_e1098 - vec3(0.5f)) * 0.5f);
                                    let _e1102 = face_7;
                                    if (_e1102 == 0i) {
                                        let _e1104 = n2_2;
                                        let _e1105 = (_e1104 * 0.7f);
                                        let _e1109 = facet;
                                        n_13 = normalize((vec3<f32>(_e1105.x, _e1105.y, -1f) + _e1109));
                                    } else {
                                        let _e1112 = n_13;
                                        let _e1113 = facet;
                                        n_13 = normalize((_e1112 + (_e1113 * 0.6f)));
                                    }
                                }
                            }
                            let _e1119 = mm.optics[2u];
                            ior = max(_e1119, 1f);
                            let _e1121 = d_10;
                            let _e1122 = n_13;
                            cosi = clamp(-(dot(_e1121, _e1122)), 0f, 1f);
                            let _e1126 = ior;
                            let _e1128 = ior;
                            f0_3 = pow(((_e1126 - 1f) / (_e1128 + 1f)), 2f);
                            let _e1132 = f0_3;
                            let _e1133 = f0_3;
                            let _e1135 = cosi;
                            let _e1142 = mm.surface[0u];
                            F_2 = ((_e1132 + ((1f - _e1133) * pow((1f - _e1135), 5f))) * _e1142);
                            let _e1146 = mm.ids[0u];
                            let _e1147 = (_e1146 == 1u);
                            phi_6179_ = _e1147;
                            if _e1147 {
                                let _e1150 = mm.sss[2u];
                                phi_6179_ = (_e1150 <= 0f);
                            }
                            let _e1153 = phi_6179_;
                            if _e1153 {
                                let _e1156 = rp.reserved[2u];
                                let _e1157 = F_2;
                                F_2 = (_e1157 * _e1156);
                            }
                            let _e1159 = F_2;
                            let _e1162 = mm.sss[2u];
                            let _e1163 = cosi;
                            F_2 = max(_e1159, (_e1162 * (0.04f + (0.96f * pow((1f - _e1163), 5f)))));
                            let _e1170 = d_10;
                            let _e1171 = n_13;
                            rd = reflect(_e1170, _e1171);
                            let _e1175 = mm.ids[0u];
                            let _e1177 = face_7;
                            if ((_e1175 == 1u) && (_e1177 == 1i)) {
                                let _e1180 = hp_11;
                                param_249 = (_e1180.xy - vec2<f32>(0f, 4f));
                                param_250 = 10f;
                                let _e1183 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_249), (&param_250));
                                env_1 = (_e1183 * 1.4f);
                                let _e1185 = T_1;
                                let _e1186 = F_2;
                                let _e1188 = env_1;
                                let _e1190 = env_1;
                                param_251 = _e1190;
                                let _e1191 = max3_u0028_vf3_u003b((&param_251));
                                let _e1196 = C_1;
                                C_1 = (_e1196 + (((_e1185 * _e1186) * _e1188) / vec3((1f + (_e1191 * 0.35f)))));
                            } else {
                                let _e1198 = F_2;
                                let _e1199 = (_e1198 > 0.01f);
                                phi_6240_ = _e1199;
                                if _e1199 {
                                    let _e1201 = rd[2u];
                                    phi_6240_ = (_e1201 > 0.02f);
                                }
                                let _e1204 = phi_6240_;
                                if _e1204 {
                                    let _e1205 = nRefl;
                                    let _e1206 = hp_11;
                                    let _e1207 = n_13;
                                    rOrg[_e1205] = (_e1206 + (_e1207 * 0.02f));
                                    let _e1211 = nRefl;
                                    let _e1212 = rd;
                                    rDir[_e1211] = _e1212;
                                    let _e1214 = nRefl;
                                    let _e1215 = T_1;
                                    let _e1216 = F_2;
                                    rW[_e1214] = (_e1215 * _e1216);
                                    let _e1219 = nRefl;
                                    let _e1220 = hp_11;
                                    param_252 = (_e1220.xy - vec2<f32>(0f, 2f));
                                    param_253 = 4f;
                                    let _e1223 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_252), (&param_253));
                                    rEnv[_e1219] = (_e1223 * 1.5f);
                                    let _e1226 = nRefl;
                                    nRefl = (_e1226 + 1i);
                                } else {
                                    let _e1228 = F_2;
                                    F_2 = (_e1228 * 0.5f);
                                    let _e1230 = T_1;
                                    let _e1231 = F_2;
                                    let _e1233 = hp_11;
                                    let _e1235 = n_13;
                                    param_254 = (_e1233.xy + (_e1235.xy * 3f));
                                    param_255 = 4f;
                                    let _e1239 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_254), (&param_255));
                                    let _e1241 = C_1;
                                    C_1 = (_e1241 + ((_e1230 * _e1231) * _e1239));
                                }
                            }
                            let _e1245 = mm.ids[0u];
                            if (_e1245 != 1u) {
                                let _e1247 = d_10;
                                let _e1248 = n_13;
                                rim_1 = pow((1f - clamp(-(dot(_e1247, _e1248)), 0f, 1f)), 3f);
                                let _e1254 = T_1;
                                let _e1255 = rim_1;
                                let _e1259 = mm.surface[0u];
                                let _e1261 = hp_11;
                                let _e1263 = n_13;
                                param_256 = (_e1261.xy + (_e1263.xy * 4f));
                                param_257 = 4f;
                                let _e1267 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_256), (&param_257));
                                let _e1270 = C_1;
                                C_1 = (_e1270 + ((((_e1254 * _e1255) * _e1259) * _e1267) * 1.2f));
                            }
                            let _e1272 = hp_11;
                            let _e1274 = n_13;
                            lp_3 = (_e1272.xy + (_e1274.xy * 1.5f));
                            let _e1278 = lp_3;
                            param_258 = _e1278;
                            let _e1279 = light_at_u0028_vf2_u003b((&param_258));
                            ld_6 = _e1279;
                            let _e1280 = d_10;
                            let _e1282 = ld_6;
                            param_259 = _e1282;
                            let _e1283 = light_dir3_u0028_vf4_u003b((&param_259));
                            let _e1284 = lp_3;
                            param_260 = _e1284;
                            let _e1285 = fluence_at_u0028_vf2_u003b((&param_260));
                            let _e1288 = rp.ambient;
                            let _e1291 = mm;
                            param_261 = _e1291;
                            let _e1292 = n_13;
                            param_262 = _e1292;
                            param_263 = -(_e1280);
                            param_264 = _e1283;
                            param_265 = ((_e1285 * 2f) + _e1288.xyz);
                            param_266 = vec3<f32>(1f, 1f, 1f);
                            let _e1293 = spec_term_u0028_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b((&param_261), (&param_262), (&param_263), (&param_264), (&param_265), (&param_266));
                            hl = _e1293;
                            let _e1296 = mm.ids[0u];
                            let _e1297 = (_e1296 == 1u);
                            phi_6367_ = _e1297;
                            if _e1297 {
                                let _e1300 = mm.sss[2u];
                                phi_6367_ = (_e1300 <= 0f);
                            }
                            let _e1303 = phi_6367_;
                            if _e1303 {
                                let _e1306 = rp.reserved[3u];
                                let _e1307 = face_7;
                                let _e1311 = hl;
                                hl = (_e1311 * (_e1306 * select(1f, 0.35f, (_e1307 == 1i))));
                            }
                            let _e1313 = T_1;
                            let _e1314 = hl;
                            let _e1316 = C_1;
                            C_1 = (_e1316 + (_e1313 * _e1314));
                            let _e1318 = F_2;
                            let _e1320 = T_1;
                            T_1 = (_e1320 * (1f - _e1318));
                            let _e1322 = d_10;
                            let _e1323 = n_13;
                            let _e1324 = ior;
                            nd = refract(_e1322, _e1323, (1f / _e1324));
                            let _e1327 = nd;
                            let _e1328 = nd;
                            if (dot(_e1327, _e1328) > 0f) {
                                let _e1331 = nd;
                                d_10 = _e1331;
                            }
                            let _e1332 = mid_2;
                            inMat = _e1332;
                        } else {
                            let _e1333 = inMat;
                            let _e1336 = unnamed.mats[_e1333];
                            pm.color_a = _e1336.color_a;
                            pm.color_b = _e1336.color_b;
                            pm.emission = _e1336.emission;
                            pm.phys = _e1336.phys;
                            pm.thermo = _e1336.thermo;
                            pm.burn = _e1336.burn;
                            pm.optics = _e1336.optics;
                            pm.scatter = _e1336.scatter;
                            pm.ids = _e1336.ids;
                            pm.ids2_ = _e1336.ids2_;
                            pm.misc = _e1336.misc;
                            pm.surface = _e1336.surface;
                            pm.sss = _e1336.sss;
                            pm.sss_color = _e1336.sss_color;
                            pm.optics2_ = _e1336.optics2_;
                            pm.pal0_ = _e1336.pal0_;
                            pm.pal1_ = _e1336.pal1_;
                            pm.pal2_ = _e1336.pal2_;
                            pm.pal3_ = _e1336.pal3_;
                            pm.accent = _e1336.accent;
                            pm.flame = _e1336.flame;
                            let _e1381 = pm.optics[2u];
                            ior_1 = max(_e1381, 1f);
                            let _e1385 = pm.ids[0u];
                            if (_e1385 == 1u) {
                                let _e1387 = n_13;
                                param_267 = _e1387;
                                let _e1388 = hp_11;
                                param_268 = _e1388;
                                let _e1389 = wave_normal_u0028_vf3_u003b_vf3_u003b((&param_267), (&param_268));
                                n_13 = _e1389;
                            }
                            let _e1390 = d_10;
                            let _e1391 = n_13;
                            let _e1392 = ior_1;
                            nd_1 = refract(_e1390, _e1391, _e1392);
                            let _e1396 = pm.ids[0u];
                            if (_e1396 == 1u) {
                                let _e1398 = nd_1;
                                let _e1399 = nd_1;
                                if (dot(_e1398, _e1399) > 0f) {
                                    let _e1402 = d_10;
                                    let _e1403 = nd_1;
                                    local_38 = normalize(mix(_e1402, _e1403, vec3(0.3f)));
                                } else {
                                    let _e1407 = d_10;
                                    local_38 = _e1407;
                                }
                                let _e1408 = local_38;
                                d_10 = _e1408;
                            } else {
                                let _e1409 = nd_1;
                                let _e1410 = nd_1;
                                if (dot(_e1409, _e1410) > 0f) {
                                    let _e1413 = nd_1;
                                    local_39 = _e1413;
                                } else {
                                    let _e1414 = d_10;
                                    let _e1415 = n_13;
                                    local_39 = reflect(_e1414, _e1415);
                                }
                                let _e1417 = local_39;
                                d_10 = _e1417;
                            }
                            inMat = 0u;
                        }
                        let _e1419 = d_10[2u];
                        d_10[2u] = max(_e1419, 0.35f);
                        let _e1422 = d_10;
                        d_10 = normalize(_e1422);
                        let _e1424 = hp_11;
                        so = _e1424;
                        let _e1425 = so;
                        param_269 = _e1425.xy;
                        let _e1427 = d_10;
                        param_270 = _e1427.xy;
                        let _e1429 = cell_6;
                        param_271 = _e1429;
                        dda_init_cell_u0028_vf2_u003b_vf2_u003b_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b((&param_269), (&param_270), (&param_271), (&param_272), (&param_273), (&param_274));
                        let _e1430 = param_272;
                        stp_4 = _e1430;
                        let _e1431 = param_273;
                        tDelta_4 = _e1431;
                        let _e1432 = param_274;
                        tMax_4 = _e1432;
                        let _e1433 = g_T0_;
                        let _e1435 = so[2u];
                        let _e1438 = d_10[2u];
                        tEnd_1 = ((_e1433 - _e1435) / _e1438);
                        tCur_3 = 0f;
                        let _e1440 = events;
                        events = (_e1440 + 1i);
                        restart = true;
                    } else {
                        let _e1442 = melted;
                        if _e1442 {
                            local_40 = vec4<f32>(1f, 1f, 1f, 1f);
                        } else {
                            let _e1443 = cell_6;
                            let _e1444 = textureLoad(l0t, _e1443, 0i);
                            local_40 = _e1444;
                        }
                        let _e1445 = local_40;
                        tr_4 = _e1445;
                        let _e1447 = s_11[3u];
                        let _e1448 = (_e1447 > 0f);
                        phi_6555_ = _e1448;
                        if !(_e1448) {
                            let _e1450 = s_11;
                            param_275 = _e1450.xyz;
                            let _e1452 = max3_u0028_vf3_u003b((&param_275));
                            phi_6555_ = (_e1452 > 0f);
                        }
                        let _e1455 = phi_6555_;
                        phi_6563_ = _e1455;
                        if !(_e1455) {
                            let _e1458 = tr_4[0u];
                            phi_6563_ = (_e1458 < 0.999f);
                        }
                        let _e1461 = phi_6563_;
                        phi_6570_ = _e1461;
                        if !(_e1461) {
                            let _e1464 = tr_4[1u];
                            phi_6570_ = (_e1464 < 0.999f);
                        }
                        let _e1467 = phi_6570_;
                        phi_6577_ = _e1467;
                        if !(_e1467) {
                            let _e1470 = tr_4[2u];
                            phi_6577_ = (_e1470 < 0.999f);
                        }
                        let _e1473 = phi_6577_;
                        if _e1473 {
                            let _e1474 = tNext_2;
                            let _e1475 = tCur_3;
                            let _e1478 = d_10[2u];
                            let _e1480 = g_T0_;
                            k_13 = (((_e1474 - _e1475) * _e1478) / _e1480);
                            let _e1482 = T_1;
                            let _e1483 = s_11;
                            let _e1486 = k_13;
                            let _e1488 = C_1;
                            C_1 = (_e1488 + ((_e1482 * _e1483.xyz) * _e1486));
                            let _e1490 = tr_4;
                            let _e1493 = k_13;
                            let _e1496 = T_1;
                            T_1 = (_e1496 * pow(max(_e1490.xyz, vec3<f32>(0.0001f, 0.0001f, 0.0001f)), vec3(_e1493)));
                            let _e1498 = cell_6;
                            param_276 = (vec2<f32>(_e1498) + vec2(0.5f));
                            let _e1503 = tr_4[3u];
                            param_277 = _e1503;
                            let _e1504 = time_1;
                            param_278 = _e1504;
                            let _e1505 = heat_offset_u0028_vf2_u003b_f1_u003b_f1_u003b((&param_276), (&param_277), (&param_278));
                            let _e1506 = k_13;
                            let _e1508 = distort_1;
                            distort_1 = (_e1508 + (_e1505 * _e1506));
                        }
                    }
                }
                let _e1510 = restart;
                if _e1510 {
                    continue;
                }
                let _e1511 = tNext_2;
                let _e1512 = tEnd_1;
                let _e1513 = (_e1511 >= _e1512);
                phi_6634_ = _e1513;
                if !(_e1513) {
                    let _e1515 = T_1;
                    param_279 = _e1515;
                    let _e1516 = max3_u0028_vf3_u003b((&param_279));
                    phi_6634_ = (_e1516 < 0.01f);
                }
                let _e1519 = phi_6634_;
                if _e1519 {
                    break;
                }
                let _e1520 = cell_6;
                param_280 = _e1520;
                let _e1521 = stp_4;
                param_281 = _e1521;
                let _e1522 = tDelta_4;
                param_282 = _e1522;
                let _e1523 = tMax_4;
                param_283 = _e1523;
                let _e1524 = tCur_3;
                param_284 = _e1524;
                dda_step_u0028_vi2_u003b_vi2_u003b_vf2_u003b_vf2_u003b_f1_u003b_i1_u003b((&param_280), (&param_281), (&param_282), (&param_283), (&param_284), (&param_285));
                let _e1525 = param_280;
                cell_6 = _e1525;
                let _e1526 = param_283;
                tMax_4 = _e1526;
                let _e1527 = param_284;
                tCur_3 = _e1527;
                let _e1528 = param_285;
                face_7 = _e1528;
                continue;
            } else {
                break;
            }
            continuing {
                let _e1529 = i_5;
                i_5 = (_e1529 + 1i);
            }
        }
        let _e1531 = so;
        let _e1532 = d_10;
        let _e1533 = tEnd_1;
        so = (_e1531 + (_e1532 * _e1533));
        let _e1536 = inMat;
        let _e1537 = (_e1536 != 0u);
        phi_6669_ = _e1537;
        if _e1537 {
            let _e1538 = T_1;
            param_286 = _e1538;
            let _e1539 = max3_u0028_vf3_u003b((&param_286));
            phi_6669_ = (_e1539 > 0.01f);
        }
        let _e1542 = phi_6669_;
        if _e1542 {
            let _e1543 = d_10;
            let _e1544 = inMat;
            let _e1549 = unnamed.mats[_e1544].optics[2u];
            nd_2 = refract(_e1543, vec3<f32>(0f, 0f, -1f), max(_e1549, 1f));
            let _e1552 = nd_2;
            let _e1553 = nd_2;
            if (dot(_e1552, _e1553) > 0f) {
                let _e1556 = d_10;
                let _e1557 = nd_2;
                nd_2 = normalize(mix(_e1556, _e1557, vec3(0.35f)));
            } else {
                let _e1561 = d_10;
                nd_2 = _e1561;
            }
            let _e1562 = nd_2;
            let _e1563 = _e1562.xy;
            let _e1565 = nd_2[2u];
            d_10 = normalize(vec3<f32>(_e1563.x, _e1563.y, max(_e1565, 0.35f)));
        }
    }
    depthOut = 0f;
    let _e1571 = glossy;
    if _e1571 {
        let _e1572 = gMid;
        let _e1573 = gHp;
        param_287 = _e1573;
        let _e1574 = gN;
        param_288 = _e1574;
        let _e1575 = gD;
        param_289 = _e1575;
        let _e1578 = unnamed.mats[_e1572];
        param_290.color_a = _e1578.color_a;
        param_290.color_b = _e1578.color_b;
        param_290.emission = _e1578.emission;
        param_290.phys = _e1578.phys;
        param_290.thermo = _e1578.thermo;
        param_290.burn = _e1578.burn;
        param_290.optics = _e1578.optics;
        param_290.scatter = _e1578.scatter;
        param_290.ids = _e1578.ids;
        param_290.ids2_ = _e1578.ids2_;
        param_290.misc = _e1578.misc;
        param_290.surface = _e1578.surface;
        param_290.sss = _e1578.sss;
        param_290.sss_color = _e1578.sss_color;
        param_290.optics2_ = _e1578.optics2_;
        param_290.pal0_ = _e1578.pal0_;
        param_290.pal1_ = _e1578.pal1_;
        param_290.pal2_ = _e1578.pal2_;
        param_290.pal3_ = _e1578.pal3_;
        param_290.accent = _e1578.accent;
        param_290.flame = _e1578.flame;
        let _e1621 = glossy_dir_u0028_vf3_u003b_vf3_u003b_vf3_u003b_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b((&param_287), (&param_288), (&param_289), (&param_290));
        local_41 = _e1621;
    } else {
        local_41 = vec3<f32>(0f, 0f, 0f);
    }
    let _e1622 = local_41;
    gDir = _e1622;
    let _e1623 = glossy;
    phi_6770_ = _e1623;
    if _e1623 {
        let _e1625 = gDir[2u];
        phi_6770_ = (_e1625 >= 0.02f);
    }
    let _e1628 = phi_6770_;
    gl = _e1628;
    r_5 = 0i;
    loop {
        let _e1629 = r_5;
        let _e1630 = nRefl;
        if (_e1629 <= _e1630) {
            let _e1632 = r_5;
            let _e1633 = nRefl;
            last = (_e1632 == _e1633);
            let _e1635 = last;
            let _e1637 = gl;
            refl = (!(_e1635) || _e1637);
            let _e1639 = so;
            bo = _e1639;
            let _e1640 = d_10;
            bd = _e1640;
            let _e1641 = T_1;
            bT = _e1641;
            rc_1 = vec3<f32>(0f, 0f, 0f);
            let _e1642 = distort_1;
            bdist = _e1642;
            let _e1643 = last;
            if !(_e1643) {
                let _e1645 = r_5;
                let _e1647 = rOrg[_e1645];
                bo = _e1647;
                let _e1648 = r_5;
                let _e1650 = rDir[_e1648];
                bd = _e1650;
            } else {
                let _e1651 = gl;
                if _e1651 {
                    let _e1652 = gHp;
                    let _e1653 = gN;
                    bo = (_e1652 + (_e1653 * 0.02f));
                    let _e1656 = gDir;
                    bd = _e1656;
                }
            }
            let _e1657 = refl;
            if _e1657 {
                bdist = vec2<f32>(0f, 0f);
                bT = vec3<f32>(1f, 1f, 1f);
                let _e1658 = bo;
                param_291 = _e1658;
                let _e1659 = bd;
                param_292 = _e1659;
                let _e1660 = bT;
                param_293 = _e1660;
                let _e1661 = march_l0_simple_u0028_vf3_u003b_vf3_u003b_vf3_u003b((&param_291), (&param_292), (&param_293));
                let _e1662 = param_291;
                bo = _e1662;
                let _e1663 = param_293;
                bT = _e1663;
                rc_1 = _e1661;
            }
            let _e1664 = bT;
            param_294 = _e1664;
            let _e1665 = max3_u0028_vf3_u003b((&param_294));
            if (_e1665 > 0.01f) {
                let _e1667 = bo;
                param_295 = _e1667;
                let _e1668 = bd;
                param_296 = _e1668;
                let _e1669 = bdist;
                param_297 = _e1669;
                let _e1670 = trace_bg_u0028_vf3_u003b_vf3_u003b_vf2_u003b((&param_295), (&param_296), (&param_297));
                bgc = _e1670;
                let _e1671 = refl;
                if _e1671 {
                    let _e1672 = bT;
                    let _e1673 = bgc;
                    let _e1675 = rc_1;
                    rc_1 = (_e1675 + (_e1672 * _e1673));
                } else {
                    let _e1677 = T_1;
                    let _e1678 = bgc;
                    let _e1680 = C_1;
                    C_1 = (_e1680 + (_e1677 * _e1678));
                    let _e1682 = g_lastBgZ;
                    let _e1683 = T_1;
                    param_298 = _e1683;
                    let _e1684 = luminance_u0028_vf3_u003b((&param_298));
                    depthOut = mix(0f, _e1682, clamp(_e1684, 0f, 1f));
                }
            }
            let _e1687 = last;
            if !(_e1687) {
                let _e1689 = rc_1;
                let _e1690 = rc_1;
                param_299 = _e1690;
                let _e1691 = max3_u0028_vf3_u003b((&param_299));
                rc_1 = (_e1689 / vec3((1f + (_e1691 * 0.35f))));
                let _e1696 = rc_1;
                let _e1697 = r_5;
                let _e1699 = rEnv[_e1697];
                rc_1 = mix(_e1696, _e1699, vec3(0.4f));
                let _e1702 = r_5;
                let _e1704 = rW[_e1702];
                let _e1705 = rc_1;
                let _e1707 = C_1;
                C_1 = (_e1707 + (_e1704 * _e1705));
            } else {
                let _e1709 = gl;
                if _e1709 {
                    let _e1710 = gT;
                    let _e1711 = gMid;
                    let _e1712 = rc_1;
                    param_300 = _e1712;
                    let _e1713 = gN;
                    param_301 = _e1713;
                    let _e1714 = gD;
                    param_302 = _e1714;
                    let _e1717 = unnamed.mats[_e1711];
                    param_303.color_a = _e1717.color_a;
                    param_303.color_b = _e1717.color_b;
                    param_303.emission = _e1717.emission;
                    param_303.phys = _e1717.phys;
                    param_303.thermo = _e1717.thermo;
                    param_303.burn = _e1717.burn;
                    param_303.optics = _e1717.optics;
                    param_303.scatter = _e1717.scatter;
                    param_303.ids = _e1717.ids;
                    param_303.ids2_ = _e1717.ids2_;
                    param_303.misc = _e1717.misc;
                    param_303.surface = _e1717.surface;
                    param_303.sss = _e1717.sss;
                    param_303.sss_color = _e1717.sss_color;
                    param_303.optics2_ = _e1717.optics2_;
                    param_303.pal0_ = _e1717.pal0_;
                    param_303.pal1_ = _e1717.pal1_;
                    param_303.pal2_ = _e1717.pal2_;
                    param_303.pal3_ = _e1717.pal3_;
                    param_303.accent = _e1717.accent;
                    param_303.flame = _e1717.flame;
                    let _e1760 = gBase;
                    param_304 = _e1760;
                    let _e1761 = glossy_weigh_u0028_vf3_u003b_vf3_u003b_vf3_u003b_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_vf3_u003b((&param_300), (&param_301), (&param_302), (&param_303), (&param_304));
                    let _e1763 = C_1;
                    C_1 = (_e1763 + (_e1710 * _e1761));
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e1765 = r_5;
            r_5 = (_e1765 + 1i);
        }
    }
    let _e1767 = p0_1;
    let _e1769 = g_world;
    let _e1771 = textureSampleLevel(godray_tex, godray_tex_smp, (_e1767.xy / _e1769), 0f);
    let _e1775 = rp.bloom[3u];
    let _e1777 = C_1;
    C_1 = (_e1777 + (_e1771.xyz * _e1775));
    let _e1781 = rp.look2_[3u];
    let _e1783 = g_T0_;
    if ((_e1781 > 0f) && (_e1783 < 0.01f)) {
        let _e1786 = p0_1;
        let _e1788 = g_world;
        let _e1790 = textureSampleLevel(fog_tex, fog_tex_smp, (_e1786.xy / _e1788), 0f);
        fg = _e1790;
        let _e1791 = fg;
        Lv = _e1791.xyz;
        let _e1794 = fg[3u];
        Tv_1 = _e1794;
        let _e1796 = g_cost[1u];
        g_cost[1u] = (_e1796 + 1u);
    } else {
        let _e1799 = p0_1;
        param_305 = _e1799;
        let _e1800 = d_10;
        param_306 = _e1800;
        let _e1801 = p_6;
        param_307 = _e1801;
        let _e1802 = front_volume_u0028_vf3_u003b_vf3_u003b_vi2_u003b_f1_u003b((&param_305), (&param_306), (&param_307), (&param_308));
        let _e1803 = param_308;
        Tv_1 = _e1803;
        Lv = _e1802;
    }
    let _e1804 = p0_1;
    bc = vec2<i32>(floor(_e1804.xy));
    let _e1808 = bc;
    param_309 = _e1808;
    let _e1809 = inw_u0028_vi2_u003b((&param_309));
    phi_7023_ = _e1809;
    if _e1809 {
        let _e1810 = bc;
        let _e1811 = textureLoad(l0s, _e1810, 0i);
        phi_7023_ = (_e1811.w < 0.99f);
    }
    let _e1815 = phi_7023_;
    if _e1815 {
        let _e1816 = p0_1;
        let _e1818 = g_world;
        let _e1820 = textureSampleLevel(beam_tex, beam_tex_smp, (_e1816.xy / _e1818), 0f);
        let _e1823 = Lv;
        Lv = (_e1823 + (_e1820.xyz * 0.12f));
    }
    let _e1825 = C_1;
    let _e1826 = Tv_1;
    let _e1828 = Lv;
    let _e1830 = p0_1;
    param_310 = _e1830.xy;
    let _e1832 = dust_motes_u0028_vf2_u003b((&param_310));
    C_1 = (((_e1825 * _e1826) + _e1828) + _e1832);
    let _e1834 = C_1;
    param_311 = _e1834;
    let _e1835 = web_isnan_u0028_vf3_u003b((&param_311));
    let _e1836 = any(_e1835);
    phi_7061_ = _e1836;
    if !(_e1836) {
        let _e1838 = C_1;
        param_312 = _e1838;
        let _e1839 = web_isinf_u0028_vf3_u003b((&param_312));
        phi_7061_ = any(_e1839);
    }
    let _e1842 = phi_7061_;
    if _e1842 {
        C_1 = vec3<f32>(0f, 0f, 0f);
    }
    let _e1843 = p_6;
    let _e1844 = C_1;
    let _e1845 = max(_e1844, vec3<f32>(0f, 0f, 0f));
    let _e1846 = depthOut;
    textureStore(out_img, _e1843, vec4<f32>(_e1845.x, _e1845.y, _e1845.z, _e1846));
    let _e1853 = rp.look3_[2u];
    if (_e1853 > 0.5f) {
        let _e1856 = g_cost[1u];
        g_cost[1u] = (_e1856 + 2u);
        let _e1860 = g_cost[0u];
        let _e1862 = g_cost[1u];
        let _e1865 = g_cost[2u];
        total = ((_e1860 + _e1862) + _e1865);
        let _e1867 = p_6;
        let _e1868 = g_cost;
        let _e1869 = vec3<f32>(_e1868);
        let _e1870 = total;
        textureStore(cost_img, _e1867, vec4<f32>(_e1869.x, _e1869.y, _e1869.z, f32(_e1870)));
        let _e1876 = p0_1;
        mc = vec2<i32>(floor(_e1876.xy));
        let _e1880 = mc;
        param_313 = _e1880;
        let _e1881 = inw_u0028_vi2_u003b((&param_313));
        if _e1881 {
            let _e1882 = mc;
            let _e1883 = textureLoad(cells, _e1882, 0i);
            local_42 = (_e1883.x & 255u);
        } else {
            local_42 = 0u;
        }
        let _e1886 = local_42;
        mid0_ = _e1886;
        let _e1887 = mid0_;
        let _e1890 = total;
        let _e1891 = atomicAdd((&unnamed_1.mat_cost[_e1887]), _e1890);
        let _e1895 = g_cost[0u];
        let _e1896 = atomicAdd((&unnamed_1.mat_cost[256i]), _e1895);
        let _e1900 = g_cost[1u];
        let _e1901 = atomicAdd((&unnamed_1.mat_cost[257i]), _e1900);
        let _e1905 = g_cost[2u];
        let _e1906 = atomicAdd((&unnamed_1.mat_cost[258i]), _e1905);
    }
    return;
}

@compute @workgroup_size(64, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
