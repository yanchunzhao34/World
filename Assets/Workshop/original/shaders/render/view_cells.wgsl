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

var<private> g_useCells: bool;
var<private> g_cost: vec3<u32>;
@group(0) @binding(11) 
var<uniform> rp: RenderParams;
var<private> g_world: vec2<f32>;
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
@group(0) @binding(16) 
var occ_tex: texture_2d<f32>;
@group(2) @binding(16) 
var occ_tex_smp: sampler;
var<private> g_T0_: f32;
@group(0) @binding(13) 
var cells: texture_2d<u32>;
@group(0) @binding(14) 
var<storage> unnamed: Materials;
@group(0) @binding(15) 
var gaux_img: texture_2d<f32>;
var<private> g_frontRim: f32;
@group(0) @binding(2) 
var bg: texture_2d<u32>;
@group(0) @binding(20) 
var day_tex: texture_2d<f32>;
@group(2) @binding(20) 
var day_tex_smp: sampler;
@group(0) @binding(0) 
var l0s: texture_2d<f32>;
@group(0) @binding(1) 
var l0t: texture_2d<f32>;
@group(0) @binding(26) 
var emissive_img: texture_2d<f32>;
var<private> g_time: f32;
@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> g_F: f32;
var<private> g_sigmaMax: f32;
var<private> g_backFade: f32;
var<private> g_bgSmooth: f32;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(27) 
var cell_shade: texture_storage_2d<rgba32float,write>;
@group(0) @binding(9) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(9) 
var medium_tex_smp: sampler;
@group(0) @binding(10) 
var godray_tex: texture_2d<f32>;
@group(2) @binding(10) 
var godray_tex_smp: sampler;
@group(0) @binding(12) 
var out_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(17) 
var side_tex: texture_2d<f32>;
@group(2) @binding(17) 
var side_tex_smp: sampler;
@group(0) @binding(18) 
var bgsm_tex: texture_2d<f32>;
@group(2) @binding(18) 
var bgsm_tex_smp: sampler;
@group(0) @binding(19) 
var beam_tex: texture_2d<f32>;
@group(2) @binding(19) 
var beam_tex_smp: sampler;
@group(0) @binding(21) 
var cost_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(23) 
var fog_tex: texture_2d<f32>;
@group(2) @binding(23) 
var fog_tex_smp: sampler;
@group(0) @binding(22) 
var<storage, read_write> unnamed_1: MatCost;
var<private> g_lastBgZ: f32;

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e271 = (*x);
    return (f32((_e271 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e271 = (*v);
    (*v) = ((_e271 * vec3(1664525u)) + vec3(1013904223u));
    let _e277 = (*v)[1u];
    let _e279 = (*v)[2u];
    let _e282 = (*v)[0u];
    (*v)[0u] = (_e282 + (_e277 * _e279));
    let _e286 = (*v)[2u];
    let _e288 = (*v)[0u];
    let _e291 = (*v)[1u];
    (*v)[1u] = (_e291 + (_e286 * _e288));
    let _e295 = (*v)[0u];
    let _e297 = (*v)[1u];
    let _e300 = (*v)[2u];
    (*v)[2u] = (_e300 + (_e295 * _e297));
    let _e303 = (*v);
    let _e307 = (*v);
    (*v) = (_e307 ^ (_e303 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e310 = (*v)[1u];
    let _e312 = (*v)[2u];
    let _e315 = (*v)[0u];
    (*v)[0u] = (_e315 + (_e310 * _e312));
    let _e319 = (*v)[2u];
    let _e321 = (*v)[0u];
    let _e324 = (*v)[1u];
    (*v)[1u] = (_e324 + (_e319 * _e321));
    let _e328 = (*v)[0u];
    let _e330 = (*v)[1u];
    let _e333 = (*v)[2u];
    (*v)[2u] = (_e333 + (_e328 * _e330));
    let _e336 = (*v);
    return _e336;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param: vec3<u32>;

    let _e272 = (*v_1);
    param = _e272;
    let _e273 = pcg3d_u0028_vu3_u003b((&param));
    return _e273.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_1: vec3<u32>;
    var param_2: u32;

    let _e273 = (*p);
    let _e275 = vec2<i32>(floor(_e273));
    param_1 = bitcast<vec3<u32>>(vec3<i32>(_e275.x, _e275.y, 1777i));
    let _e280 = hash1_u0028_vu3_u003b((&param_1));
    param_2 = _e280;
    let _e281 = u01_u0028_u1_u003b((&param_2));
    return _e281;
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

    let _e281 = (*p_1);
    i = floor(_e281);
    let _e283 = (*p_1);
    f = fract(_e283);
    let _e285 = f;
    let _e286 = f;
    let _e288 = f;
    f = ((_e285 * _e286) * (vec2(3f) - (_e288 * 2f)));
    let _e293 = i;
    param_3 = _e293;
    let _e294 = hash21_u0028_vf2_u003b((&param_3));
    a = _e294;
    let _e295 = i;
    param_4 = (_e295 + vec2<f32>(1f, 0f));
    let _e297 = hash21_u0028_vf2_u003b((&param_4));
    b = _e297;
    let _e298 = i;
    param_5 = (_e298 + vec2<f32>(0f, 1f));
    let _e300 = hash21_u0028_vf2_u003b((&param_5));
    c = _e300;
    let _e301 = i;
    param_6 = (_e301 + vec2<f32>(1f, 1f));
    let _e303 = hash21_u0028_vf2_u003b((&param_6));
    d = _e303;
    let _e304 = a;
    let _e305 = b;
    let _e307 = f[0u];
    let _e309 = c;
    let _e310 = d;
    let _e312 = f[0u];
    let _e315 = f[1u];
    return mix(mix(_e304, _e305, _e307), mix(_e309, _e310, _e312), _e315);
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
        let _e275 = i_1;
        if (_e275 < 4i) {
            let _e277 = a_1;
            let _e278 = (*p_2);
            param_7 = _e278;
            let _e279 = vnoise_u0028_vf2_u003b((&param_7));
            let _e281 = s;
            s = (_e281 + (_e277 * _e279));
            let _e283 = (*p_2);
            (*p_2) = (_e283 * 2.03f);
            let _e285 = a_1;
            a_1 = (_e285 * 0.5f);
            continue;
        } else {
            break;
        }
        continuing {
            let _e287 = i_1;
            i_1 = (_e287 + 1i);
        }
    }
    let _e289 = s;
    return _e289;
}

fn sky_color_u0028_vf2_u003b(pos: ptr<function, vec2<f32>>) -> vec3<f32> {
    var h: f32;
    var s_1: vec3<f32>;
    var cl: f32;
    var param_8: vec2<f32>;

    let _e276 = (*pos)[1u];
    let _e279 = rp.misc[3u];
    h = clamp((_e276 / _e279), 0f, 1f);
    let _e283 = rp.sky_top;
    let _e286 = rp.sky_horizon;
    let _e288 = h;
    s_1 = (mix(_e283.xyz, _e286.xyz, vec3(pow(_e288, 0.8f))) * 0.55f);
    let _e294 = (*pos)[0u];
    let _e298 = rp.misc[0u];
    let _e302 = (*pos)[1u];
    param_8 = vec2<f32>(((_e294 * 0.016f) + (_e298 * 0.01f)), (_e302 * 0.04f));
    let _e305 = fbm_u0028_vf2_u003b((&param_8));
    cl = smoothstep(0.55f, 0.85f, _e305);
    let _e307 = s_1;
    let _e309 = rp.sky_horizon;
    let _e313 = rp.sun_color;
    let _e317 = cl;
    let _e319 = h;
    s_1 = mix(_e307, ((_e309.xyz * 0.75f) + (_e313.xyz * 0.15f)), vec3(((_e317 * 0.5f) * (1f - _e319))));
    let _e324 = s_1;
    return _e324;
}

fn fl_level_u0028_i1_u003b_vf2_u003b(l: ptr<function, i32>, uv: ptr<function, vec2<f32>>) -> vec3<f32> {
    let _e272 = (*l);
    if (_e272 <= 0i) {
        let _e274 = (*uv);
        let _e275 = textureSampleLevel(fl0_, fl0_smp, _e274, 0f);
        return _e275.xyz;
    }
    let _e277 = (*l);
    if (_e277 == 1i) {
        let _e279 = (*uv);
        let _e280 = textureSampleLevel(fl1_, fl1_smp, _e279, 0f);
        return _e280.xyz;
    }
    let _e282 = (*l);
    if (_e282 == 2i) {
        let _e284 = (*uv);
        let _e285 = textureSampleLevel(fl2_, fl2_smp, _e284, 0f);
        return _e285.xyz;
    }
    let _e287 = (*l);
    if (_e287 == 3i) {
        let _e289 = (*uv);
        let _e290 = textureSampleLevel(fl3_, fl3_smp, _e289, 0f);
        return _e290.xyz;
    }
    let _e292 = (*uv);
    let _e293 = textureSampleLevel(fl4_, fl4_smp, _e292, 0f);
    return _e293.xyz;
}

fn fluence_depth_u0028_vf2_u003b_f1_u003b(xy: ptr<function, vec2<f32>>, z: ptr<function, f32>) -> vec3<f32> {
    var uv_1: vec2<f32>;
    var lv: f32;
    var a_2: i32;
    var b_1: i32;
    var param_9: i32;
    var param_10: vec2<f32>;
    var param_11: i32;
    var param_12: vec2<f32>;

    let _e280 = (*xy);
    let _e281 = g_world;
    uv_1 = (_e280 / _e281);
    let _e283 = (*z);
    lv = clamp(log2((1f + (max(_e283, 0f) / 10f))), 0f, 4f);
    let _e289 = lv;
    a_2 = i32(floor(_e289));
    let _e292 = a_2;
    b_1 = min((_e292 + 1i), 4i);
    let _e295 = a_2;
    param_9 = _e295;
    let _e296 = uv_1;
    param_10 = _e296;
    let _e297 = fl_level_u0028_i1_u003b_vf2_u003b((&param_9), (&param_10));
    let _e298 = b_1;
    param_11 = _e298;
    let _e299 = uv_1;
    param_12 = _e299;
    let _e300 = fl_level_u0028_i1_u003b_vf2_u003b((&param_11), (&param_12));
    let _e301 = lv;
    let _e302 = a_2;
    return mix(_e297, _e300, vec3((_e301 - f32(_e302))));
}

fn bg_haze_u0028_vf3_u003b(hp: ptr<function, vec3<f32>>) -> vec4<f32> {
    var Lfar: vec3<f32>;
    var param_13: vec2<f32>;
    var param_14: f32;
    var open: f32;
    var k: i32;
    var a_3: f32;
    var c_1: vec2<i32>;
    var hazeCol: vec3<f32>;
    var param_15: vec2<f32>;

    let _e280 = (*hp);
    let _e282 = g_world;
    param_13 = clamp(_e280.xy, vec2<f32>(0f, 0f), _e282);
    param_14 = 160f;
    let _e284 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_13), (&param_14));
    Lfar = _e284;
    open = 0f;
    k = 0i;
    loop {
        let _e285 = k;
        if (_e285 < 8i) {
            let _e287 = k;
            a_3 = (f32(_e287) * 0.785398f);
            let _e290 = (*hp);
            let _e292 = a_3;
            let _e294 = a_3;
            let _e300 = g_world;
            c_1 = clamp(vec2<i32>((_e290.xy + (vec2<f32>(cos(_e292), sin(_e294)) * 56f))), vec2<i32>(0i, 0i), (vec2<i32>(_e300) - vec2(1i)));
            let _e305 = c_1;
            let _e306 = textureLoad(bg, _e305, 0i);
            if (_e306.x == 0u) {
                let _e309 = open;
                open = (_e309 + 0.125f);
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e311 = k;
            k = (_e311 + 1i);
        }
    }
    let _e313 = open;
    open = smoothstep(0.1f, 0.6f, _e313);
    let _e316 = rp.haze;
    let _e319 = Lfar;
    let _e323 = (*hp)[0u];
    let _e325 = (*hp)[1u];
    param_15 = vec2<f32>(_e323, (_e325 * 0.6f));
    let _e328 = sky_color_u0028_vf2_u003b((&param_15));
    let _e329 = open;
    hazeCol = mix(((_e316.xyz * 0.5f) + (_e319 * 0.2f)), _e328, vec3(_e329));
    let _e332 = hazeCol;
    let _e335 = rp.bgparams[3u];
    let _e338 = (*hp)[2u];
    return vec4<f32>(_e332.x, _e332.y, _e332.z, (1f - exp((-(_e335) * _e338))));
}

fn luminance_u0028_vf3_u003b(c_2: ptr<function, vec3<f32>>) -> f32 {
    let _e271 = (*c_2);
    return dot(_e271, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn diorama_bg_u0028_vf3_u003b_vf3_u003b_u1_u003b(col: ptr<function, vec3<f32>>, hp_1: ptr<function, vec3<f32>>, kind: ptr<function, u32>) -> vec3<f32> {
    var gap: f32;
    var sdir: vec2<f32>;
    var off: vec2<f32>;
    var o: vec4<f32>;
    var s_2: f32;
    var occ: f32;
    var local: f32;
    var sh: f32;
    var edge: f32;
    var contact: f32;
    var lit: bool;
    var shade: vec3<f32>;
    var l_1: f32;
    var param_16: vec3<f32>;
    var phi_1479_: bool;

    let _e289 = rp.look[1u];
    let _e290 = (_e289 <= 0f);
    phi_1479_ = _e290;
    if _e290 {
        let _e293 = rp.look[3u];
        phi_1479_ = (_e293 == 1f);
    }
    let _e296 = phi_1479_;
    if _e296 {
        let _e297 = (*col);
        return _e297;
    }
    let _e299 = (*hp_1)[2u];
    let _e300 = g_T0_;
    gap = max((_e299 - _e300), 0f);
    let _e304 = rp.look4_;
    sdir = normalize(mix(vec2<f32>(0.51449573f, 0.8574929f), normalize(_e304.zw), vec2(0.7f)));
    let _e310 = sdir;
    let _e311 = gap;
    let _e314 = rp.look[2u];
    off = (_e310 * min((3f + (_e311 * _e314)), 30f));
    let _e319 = (*hp_1);
    let _e321 = off;
    let _e323 = g_world;
    let _e325 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e319.xy - _e321) / _e323), 0f);
    o = _e325;
    let _e326 = gap;
    let _e329 = rp.look[2u];
    s_2 = clamp(((3f + (_e326 * _e329)) / 16f), 0f, 1f);
    let _e334 = s_2;
    if (_e334 < 0.5f) {
        let _e337 = o[2u];
        let _e339 = o[2u];
        let _e340 = s_2;
        local = mix(_e337, _e339, (_e340 * 2f));
    } else {
        let _e344 = o[2u];
        let _e346 = o[3u];
        let _e347 = s_2;
        local = mix(_e344, _e346, ((_e347 * 2f) - 1f));
    }
    let _e351 = local;
    occ = _e351;
    let _e352 = occ;
    let _e356 = rp.look[1u];
    let _e358 = s_2;
    sh = ((smoothstep(0.15f, 0.85f, _e352) * _e356) * mix(1f, 0.6f, _e358));
    let _e361 = (*hp_1);
    let _e363 = g_world;
    let _e365 = textureSampleLevel(occ_tex, occ_tex_smp, (_e361.xy / _e363), 0f);
    edge = _e365.y;
    let _e367 = edge;
    contact = (0f * _e367);
    let _e369 = (*kind);
    let _e371 = (*kind);
    lit = ((_e369 == 7u) || (_e371 == 8u));
    let _e374 = sh;
    let _e377 = contact;
    let _e380 = rp.look[1u];
    shade = (mix(vec3<f32>(1f, 1f, 1f), vec3<f32>(0.42f, 0.46f, 0.6f), vec3(_e374)) * (1f - (_e377 * _e380)));
    let _e384 = lit;
    if _e384 {
        let _e385 = (*col);
        let _e386 = shade;
        return (_e385 * mix(vec3<f32>(1f, 1f, 1f), _e386, vec3(0.5f)));
    }
    let _e390 = (*col);
    param_16 = _e390;
    let _e391 = luminance_u0028_vf3_u003b((&param_16));
    l_1 = _e391;
    let _e392 = l_1;
    let _e394 = (*col);
    let _e400 = rp.look[3u];
    (*col) = ((mix(vec3(_e392), _e394, vec3(0.85f)) * vec3<f32>(0.95f, 0.98f, 1.06f)) * _e400);
    let _e402 = (*col);
    let _e403 = shade;
    return (_e402 * _e403);
}

fn inw_u0028_vi2_u003b(c_3: ptr<function, vec2<i32>>) -> bool {
    var phi_778_: bool;
    var phi_790_: bool;
    var phi_799_: bool;

    let _e272 = (*c_3)[0u];
    let _e273 = (_e272 >= 0i);
    phi_778_ = _e273;
    if _e273 {
        let _e275 = (*c_3)[1u];
        phi_778_ = (_e275 >= 0i);
    }
    let _e278 = phi_778_;
    phi_790_ = _e278;
    if _e278 {
        let _e280 = (*c_3)[0u];
        let _e282 = g_world[0u];
        phi_790_ = (_e280 < i32(_e282));
    }
    let _e286 = phi_790_;
    phi_799_ = _e286;
    if _e286 {
        let _e288 = (*c_3)[1u];
        let _e290 = g_world[1u];
        phi_799_ = (_e288 < i32(_e290));
    }
    let _e294 = phi_799_;
    return _e294;
}

fn ao_bg_u0028_vf3_u003b(hp_2: ptr<function, vec3<f32>>) -> f32 {
    var gap_1: f32;
    var r: f32;
    var occ_1: f32;
    var k_1: i32;
    var a_4: f32;
    var c_4: vec2<i32>;
    var param_17: vec2<i32>;
    var cov: f32;
    var local_1: f32;

    let _e281 = (*hp_2)[2u];
    let _e282 = g_T0_;
    gap_1 = max((_e281 - _e282), 0f);
    let _e285 = gap_1;
    r = (1.5f + (_e285 * 0.06f));
    occ_1 = 0f;
    k_1 = 0i;
    loop {
        let _e288 = k_1;
        if (_e288 < 8i) {
            let _e290 = k_1;
            a_4 = (f32(_e290) * 0.785398f);
            let _e293 = (*hp_2);
            let _e295 = a_4;
            let _e297 = a_4;
            let _e300 = r;
            c_4 = vec2<i32>(floor((_e293.xy + (vec2<f32>(cos(_e295), sin(_e297)) * _e300))));
            let _e305 = c_4;
            param_17 = _e305;
            let _e306 = inw_u0028_vi2_u003b((&param_17));
            if !(_e306) {
                continue;
            }
            let _e308 = c_4;
            let _e309 = textureLoad(l0s, _e308, 0i);
            cov = _e309.w;
            let _e311 = cov;
            if (_e311 >= 0.99f) {
                local_1 = 1f;
            } else {
                let _e313 = cov;
                local_1 = (_e313 * 0.5f);
            }
            let _e315 = local_1;
            let _e316 = occ_1;
            occ_1 = (_e316 + _e315);
            continue;
        } else {
            break;
        }
        continuing {
            let _e318 = k_1;
            k_1 = (_e318 + 1i);
        }
    }
    let _e320 = occ_1;
    let _e323 = gap_1;
    return (1f - ((0.6f * (_e320 / 8f)) * exp((-(_e323) / 50f))));
}

fn caustic_u0028_vf2_u003b_f1_u003b(p_3: ptr<function, vec2<f32>>, t: ptr<function, f32>) -> f32 {
    var q: vec2<f32>;
    var a_5: f32;
    var param_18: vec2<f32>;
    var b_2: f32;
    var param_19: vec2<f32>;
    var c_5: f32;

    let _e278 = (*p_3);
    q = (_e278 * 0.22f);
    let _e280 = q;
    let _e281 = (*t);
    let _e283 = (*t);
    param_18 = (_e280 + vec2<f32>((_e281 * 0.35f), (_e283 * 0.21f)));
    let _e287 = vnoise_u0028_vf2_u003b((&param_18));
    a_5 = _e287;
    let _e288 = q;
    let _e290 = (*t);
    let _e293 = (*t);
    let _e297 = a_5;
    param_19 = (((_e288 * 1.37f) + vec2<f32>((-(_e290) * 0.27f), (_e293 * 0.31f))) + vec2((_e297 * 1.7f)));
    let _e301 = vnoise_u0028_vf2_u003b((&param_19));
    b_2 = _e301;
    let _e302 = a_5;
    let _e303 = b_2;
    c_5 = (1f - (abs((_e302 - _e303)) * 3.2f));
    let _e308 = c_5;
    return (pow(max(_e308, 0f), 5f) * 1.6f);
}

fn layer0_filter_u0028_vf3_u003b_vf4_u003b(hp_3: ptr<function, vec3<f32>>, ld: ptr<function, vec4<f32>>) -> vec3<f32> {
    var sdir_1: vec3<f32>;
    var zc: f32;
    var t_1: f32;
    var P: vec2<f32>;
    var r_1: f32;
    var offs: array<vec2<f32>, 5>;
    var acc: vec3<f32>;
    var caus: f32;
    var k_2: i32;
    var c_6: vec2<i32>;
    var param_20: vec2<i32>;
    var s_3: vec4<f32>;
    var tr: vec4<f32>;
    var e: vec3<f32>;
    var f_1: vec3<f32>;
    var param_21: vec2<f32>;
    var param_22: f32;

    let _e289 = (*ld);
    let _e292 = (*ld)[2u];
    let _e294 = (_e289.xy * max(_e292, 0f));
    sdir_1 = normalize(vec3<f32>(_e294.x, _e294.y, -0.9f));
    let _e299 = g_T0_;
    zc = (_e299 * 0.5f);
    let _e301 = zc;
    let _e303 = (*hp_3)[2u];
    let _e306 = sdir_1[2u];
    t_1 = ((_e301 - _e303) / _e306);
    let _e308 = (*hp_3);
    let _e310 = sdir_1;
    let _e312 = t_1;
    P = (_e308.xy + (_e310.xy * _e312));
    let _e316 = (*hp_3)[2u];
    let _e317 = zc;
    r_1 = (1f + ((_e316 - _e317) * 0.03f));
    let _e321 = r_1;
    let _e323 = r_1;
    let _e326 = r_1;
    let _e328 = r_1;
    offs = array<vec2<f32>, 5>(vec2<f32>(0f, 0f), vec2<f32>(_e321, 0f), vec2<f32>(-(_e323), 0f), vec2<f32>(0f, _e326), vec2<f32>(0f, -(_e328)));
    acc = vec3<f32>(0f, 0f, 0f);
    caus = 0f;
    k_2 = 0i;
    loop {
        let _e332 = k_2;
        if (_e332 < 5i) {
            let _e334 = P;
            let _e335 = k_2;
            let _e337 = offs[_e335];
            c_6 = vec2<i32>(floor((_e334 + _e337)));
            let _e341 = c_6;
            param_20 = _e341;
            let _e342 = inw_u0028_vi2_u003b((&param_20));
            if !(_e342) {
                let _e344 = acc;
                acc = (_e344 + vec3<f32>(1f, 1f, 1f));
                continue;
            }
            let _e346 = c_6;
            let _e347 = textureLoad(l0s, _e346, 0i);
            s_3 = _e347;
            let _e348 = c_6;
            let _e349 = textureLoad(l0t, _e348, 0i);
            tr = _e349;
            let _e350 = c_6;
            let _e351 = textureLoad(emissive_img, _e350, 0i);
            e = _e351.xyz;
            let _e354 = e[0u];
            let _e356 = e[1u];
            let _e359 = e[2u];
            if (((_e354 + _e356) + _e359) > 0.15f) {
                let _e362 = acc;
                acc = (_e362 + vec3<f32>(1f, 1f, 1f));
                continue;
            }
            let _e365 = s_3[3u];
            if (_e365 >= 0.99f) {
                let _e367 = P;
                let _e368 = k_2;
                let _e370 = offs[_e368];
                let _e372 = g_world;
                let _e374 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e367 + _e370) / _e372), 0f);
                let _e379 = acc;
                acc = (_e379 + vec3((1f - smoothstep(0.25f, 0.8f, _e374.z))));
                continue;
            }
            let _e381 = tr;
            let _e383 = acc;
            acc = (_e383 + _e381.xyz);
            let _e386 = s_3[3u];
            if (abs((_e386 - 0.5f)) < 0.01f) {
                let _e390 = caus;
                caus = (_e390 + 1f);
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e392 = k_2;
            k_2 = (_e392 + 1i);
        }
    }
    let _e394 = acc;
    acc = (_e394 * 0.2f);
    let _e396 = caus;
    caus = (_e396 * 0.2f);
    let _e398 = acc;
    let _e400 = (*ld)[2u];
    f_1 = mix(vec3<f32>(1f, 1f, 1f), _e398, vec3((_e400 * 0.85f)));
    let _e404 = caus;
    let _e405 = P;
    param_21 = (_e405 * 1.3f);
    let _e407 = g_time;
    param_22 = _e407;
    let _e408 = caustic_u0028_vf2_u003b_f1_u003b((&param_21), (&param_22));
    let _e412 = (*ld)[2u];
    let _e415 = f_1;
    f_1 = (_e415 * (1f + (((_e404 * _e408) * 1.6f) * _e412)));
    let _e417 = f_1;
    return _e417;
}

fn light_dir3_u0028_vf4_u003b(ld_1: ptr<function, vec4<f32>>) -> vec3<f32> {
    let _e271 = (*ld_1);
    let _e274 = (*ld_1)[2u];
    let _e276 = (_e271.xy * max(_e274, 0.3f));
    return normalize(vec3<f32>(_e276.x, _e276.y, -0.55f));
}

fn ch_irradiance_u0028_vf3_u003b_vf4_u003b_vf4_u003b_vf2_u003b(a0_: ptr<function, vec3<f32>>, A: ptr<function, vec4<f32>>, B: ptr<function, vec4<f32>>, n: ptr<function, vec2<f32>>) -> vec3<f32> {
    var a1_: vec3<f32>;
    var b1_: vec3<f32>;
    var o1_: vec3<f32>;
    var l0_: f32;
    var o2_: f32;

    let _e279 = (*A);
    a1_ = _e279.xyz;
    let _e282 = (*A)[3u];
    let _e284 = (*B)[0u];
    let _e286 = (*B)[1u];
    b1_ = vec3<f32>(_e282, _e284, _e286);
    let _e288 = a1_;
    let _e290 = (*n)[0u];
    let _e292 = b1_;
    let _e294 = (*n)[1u];
    o1_ = (((_e288 * _e290) + (_e292 * _e294)) * 1.5707963f);
    let _e298 = (*a0_);
    l0_ = max(dot(_e298, vec3<f32>(0.2126f, 0.7152f, 0.0722f)), 0.00001f);
    let _e302 = (*B)[2u];
    let _e304 = (*n)[0u];
    let _e306 = (*n)[0u];
    let _e309 = (*n)[1u];
    let _e311 = (*n)[1u];
    let _e316 = (*B)[3u];
    let _e319 = (*n)[0u];
    let _e322 = (*n)[1u];
    o2_ = (((_e302 * ((_e304 * _e306) - (_e309 * _e311))) + (((_e316 * 2f) * _e319) * _e322)) * 0.6666667f);
    let _e326 = (*a0_);
    let _e328 = o1_;
    let _e330 = (*a0_);
    let _e331 = l0_;
    let _e334 = o2_;
    return max((((_e326 * 2f) + _e328) + ((_e330 / vec3(_e331)) * _e334)), vec3<f32>(0f, 0f, 0f));
}

fn ch_light_u0028_vf2_u003b_vf3_u003b(xy_1: ptr<function, vec2<f32>>, n_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var r_2: f32;
    var uv_2: vec2<f32>;
    var a0_1: vec3<f32>;
    var e_1: vec3<f32>;
    var param_23: vec3<f32>;
    var param_24: vec4<f32>;
    var param_25: vec4<f32>;
    var param_26: vec2<f32>;
    var ratio: vec3<f32>;
    var w: f32;
    var param_27: vec3<f32>;
    var phi_1033_: bool;

    let _e283 = (*n_1);
    r_2 = length(_e283.xy);
    let _e286 = r_2;
    let _e287 = (_e286 < 0.001f);
    phi_1033_ = _e287;
    if !(_e287) {
        let _e291 = rp.day[3u];
        phi_1033_ = (_e291 <= 0f);
    }
    let _e294 = phi_1033_;
    if _e294 {
        return vec3<f32>(1f, 1f, 1f);
    }
    let _e295 = (*xy_1);
    let _e296 = g_world;
    let _e300 = g_world;
    uv_2 = (clamp(_e295, vec2<f32>(0.5f, 0.5f), (_e296 - vec2(0.5f))) / _e300);
    let _e302 = uv_2;
    let _e303 = textureSampleLevel(fl0_, fl0_smp, _e302, 0f);
    a0_1 = _e303.xyz;
    let _e305 = uv_2;
    let _e306 = textureSampleLevel(cha_tex, cha_tex_smp, _e305, 0f);
    let _e307 = uv_2;
    let _e308 = textureSampleLevel(chb_tex, chb_tex_smp, _e307, 0f);
    let _e309 = (*n_1);
    let _e311 = r_2;
    let _e314 = a0_1;
    param_23 = _e314;
    param_24 = _e306;
    param_25 = _e308;
    param_26 = (_e309.xy / vec2(_e311));
    let _e315 = ch_irradiance_u0028_vf3_u003b_vf4_u003b_vf4_u003b_vf2_u003b((&param_23), (&param_24), (&param_25), (&param_26));
    e_1 = _e315;
    let _e316 = e_1;
    let _e317 = a0_1;
    ratio = clamp((_e316 / max((_e317 * 2f), vec3<f32>(0.0001f, 0.0001f, 0.0001f))), vec3<f32>(0f, 0f, 0f), vec3<f32>(3.2f, 3.2f, 3.2f));
    let _e322 = r_2;
    let _e325 = rp.day[3u];
    let _e327 = a0_1;
    param_27 = _e327;
    let _e328 = luminance_u0028_vf3_u003b((&param_27));
    w = ((_e322 * _e325) * smoothstep(0.002f, 0.02f, _e328));
    let _e331 = ratio;
    let _e332 = w;
    return mix(vec3<f32>(1f, 1f, 1f), _e331, vec3(_e332));
}

fn light_at_u0028_vf2_u003b(xy_2: ptr<function, vec2<f32>>) -> vec4<f32> {
    let _e271 = (*xy_2);
    let _e272 = g_world;
    let _e274 = textureSampleLevel(ldir_tex, ldir_tex_smp, (_e271 / _e272), 0f);
    return _e274;
}

fn face_n3_u0028_i1_u003b(face: ptr<function, i32>) -> vec3<f32> {
    let _e271 = (*face);
    if (_e271 == 1i) {
        return vec3<f32>(0f, -1f, 0f);
    }
    let _e273 = (*face);
    if (_e273 == 2i) {
        return vec3<f32>(0f, 1f, 0f);
    }
    let _e275 = (*face);
    if (_e275 == 3i) {
        return vec3<f32>(-1f, 0f, 0f);
    }
    let _e277 = (*face);
    if (_e277 == 4i) {
        return vec3<f32>(1f, 0f, 0f);
    }
    let _e279 = (*face);
    if (_e279 == 5i) {
        return vec3<f32>(0f, 0f, 1f);
    }
    return vec3<f32>(0f, 0f, -1f);
}

fn bg_albedo_u0028_u1_u003b_vf2_u003b_u1_u003b(kind_1: ptr<function, u32>, uv_3: ptr<function, vec2<f32>>, detail: ptr<function, u32>) -> vec3<f32> {
    var c_7: vec2<f32>;
    var n_2: f32;
    var param_28: vec2<f32>;
    var tile: vec2<f32>;
    var tp: vec2<f32>;
    var f_2: vec2<f32>;
    var mortar: f32;
    var tileVar: f32;
    var param_29: vec2<f32>;
    var base: vec3<f32>;
    var b_3: vec3<f32>;
    var plank: f32;
    var param_30: vec2<f32>;
    var w_1: vec3<f32>;
    var band: f32;
    var seam: f32;
    var rn: f32;
    var param_31: vec2<f32>;
    var rock: vec3<f32>;
    var local_2: vec3<f32>;

    let _e293 = (*uv_3);
    c_7 = (floor(_e293) + vec2(0.5f));
    let _e297 = c_7;
    let _e299 = (*kind_1);
    param_28 = ((_e297 * 1.37f) + vec2((f32(_e299) * 17f)));
    let _e304 = hash21_u0028_vf2_u003b((&param_28));
    n_2 = _e304;
    let _e305 = (*kind_1);
    if (_e305 == 2u) {
        tile = vec2<f32>(12f, 6f);
        let _e307 = c_7;
        let _e308 = tile;
        tp = (_e307 / _e308);
        let _e311 = tp[1u];
        let _e315 = tp[0u];
        tp[0u] = (_e315 + (floor(_e311) * 0.5f));
        let _e318 = tp;
        f_2 = fract(_e318);
        let _e321 = f_2[0u];
        let _e323 = tile[0u];
        let _e327 = f_2[1u];
        let _e329 = tile[1u];
        mortar = (step(_e321, (1f / _e323)) + step(_e327, (1f / _e329)));
        let _e333 = tp;
        param_29 = floor(_e333);
        let _e335 = hash21_u0028_vf2_u003b((&param_29));
        tileVar = (_e335 * 0.14f);
        let _e337 = (*detail);
        base = select(vec3<f32>(0.31f, 0.29f, 0.29f), vec3<f32>(0.34f, 0.27f, 0.24f), vec3((_e337 == 1u)));
        let _e341 = base;
        let _e342 = tileVar;
        let _e344 = n_2;
        b_3 = (_e341 * ((0.9f + _e342) + ((_e344 - 0.5f) * 0.1f)));
        let _e349 = b_3;
        let _e350 = mortar;
        return mix(_e349, vec3<f32>(0.15f, 0.15f, 0.16f), vec3(clamp(_e350, 0f, 1f)));
    }
    let _e354 = (*kind_1);
    if (_e354 == 4u) {
        let _e357 = c_7[1u];
        let _e361 = (*detail);
        param_30 = (vec2<f32>(0f, floor((_e357 / 3f))) + vec2(f32(_e361)));
        let _e365 = hash21_u0028_vf2_u003b((&param_30));
        plank = _e365;
        let _e366 = plank;
        let _e370 = n_2;
        w_1 = ((vec3<f32>(0.36f, 0.23f, 0.13f) * (0.75f + (0.35f * _e366))) * (0.92f + (0.16f * _e370)));
        let _e374 = (*detail);
        if (_e374 == 1u) {
            let _e376 = w_1;
            w_1 = (_e376 * 0.55f);
        }
        let _e378 = w_1;
        return _e378;
    }
    let _e379 = (*kind_1);
    if (_e379 == 5u) {
        let _e382 = c_7[1u];
        band = (0.85f + (0.25f * step(0.5f, fract((_e382 * 0.5f)))));
        let _e388 = band;
        let _e390 = n_2;
        return ((vec3<f32>(0.4f, 0.42f, 0.46f) * _e388) * (0.94f + (0.12f * _e390)));
    }
    let _e394 = (*kind_1);
    if (_e394 == 6u) {
        let _e397 = c_7[0u];
        seam = step(fract((_e397 / 24f)), 0.041666668f);
        let _e401 = n_2;
        let _e405 = seam;
        return mix((vec3<f32>(0.36f, 0.35f, 0.33f) * (0.9f + (0.2f * _e401))), vec3<f32>(0.24f, 0.24f, 0.24f), vec3(_e405));
    }
    let _e408 = (*kind_1);
    if (_e408 == 8u) {
        return vec3<f32>(0.35f, 0.85f, 0.9f);
    }
    let _e410 = (*kind_1);
    let _e412 = (*detail);
    if ((_e410 == 3u) && (_e412 == 4u)) {
        let _e415 = n_2;
        return (vec3<f32>(0.07f, 0.12f, 0.1f) * (0.9f + (0.2f * _e415)));
    }
    let _e419 = c_7;
    param_31 = (_e419 * vec2<f32>(0.12f, 0.18f));
    let _e421 = fbm_u0028_vf2_u003b((&param_31));
    rn = _e421;
    let _e422 = rn;
    let _e425 = n_2;
    rock = (mix(vec3<f32>(0.2f, 0.18f, 0.165f), vec3<f32>(0.28f, 0.25f, 0.22f), vec3(_e422)) * (0.85f + (0.3f * _e425)));
    let _e429 = (*kind_1);
    if (_e429 == 3u) {
        let _e431 = rock;
        local_2 = (_e431 * 0.55f);
    } else {
        let _e433 = rock;
        local_2 = _e433;
    }
    let _e434 = local_2;
    return _e434;
}

fn shade_bg_u0028_vu4_u003b_i1_u003b_vf3_u003b_vf3_u003b_b1_u003b(b_4: ptr<function, vec4<u32>>, face_1: ptr<function, i32>, n_3: ptr<function, vec3<f32>>, hp_4: ptr<function, vec3<f32>>, relief: ptr<function, bool>) -> vec3<f32> {
    var uv_4: vec2<f32>;
    var local_3: vec2<f32>;
    var local_4: vec2<f32>;
    var alb: vec3<f32>;
    var param_32: u32;
    var param_33: vec2<f32>;
    var param_34: u32;
    var lp: vec2<f32>;
    var local_5: vec2<f32>;
    var local_6: vec2<f32>;
    var param_35: i32;
    var F: vec3<f32>;
    var local_7: vec2<f32>;
    var param_36: vec2<f32>;
    var param_37: f32;
    var fall: f32;
    var up: f32;
    var down: f32;
    var side: f32;
    var fk: f32;
    var local_8: f32;
    var local_9: f32;
    var local_10: f32;
    var local_11: f32;
    var ld_2: vec4<f32>;
    var param_38: vec2<f32>;
    var lam: vec3<f32>;
    var local_12: vec3<f32>;
    var param_39: vec2<f32>;
    var param_40: vec3<f32>;
    var param_41: vec4<f32>;
    var trans: vec3<f32>;
    var param_42: vec3<f32>;
    var param_43: vec4<f32>;
    var ao: f32;
    var param_44: vec3<f32>;
    var amb: vec3<f32>;
    var col_1: vec3<f32>;
    var amb_1: vec3<f32>;
    var local_13: vec3<f32>;
    var L: vec3<f32>;
    var h_1: vec3<f32>;
    var param_45: vec4<f32>;
    var param_46: vec2<f32>;
    var param_47: vec2<f32>;
    var param_48: vec3<f32>;
    var param_49: vec3<f32>;
    var param_50: u32;

    let _e323 = (*relief);
    let _e324 = (*face_1);
    if (_e323 || (_e324 == 0i)) {
        let _e327 = (*hp_4);
        local_3 = _e327.xy;
    } else {
        let _e329 = (*face_1);
        let _e331 = (*face_1);
        if ((_e329 == 1i) || (_e331 == 2i)) {
            let _e335 = (*hp_4)[0u];
            let _e337 = (*hp_4)[2u];
            local_4 = vec2<f32>(_e335, _e337);
        } else {
            let _e340 = (*hp_4)[2u];
            let _e342 = (*hp_4)[1u];
            local_4 = vec2<f32>(_e340, _e342);
        }
        let _e344 = local_4;
        local_3 = _e344;
    }
    let _e345 = local_3;
    uv_4 = _e345;
    let _e347 = (*b_4)[0u];
    param_32 = _e347;
    let _e348 = uv_4;
    param_33 = _e348;
    let _e350 = (*b_4)[2u];
    param_34 = _e350;
    let _e351 = bg_albedo_u0028_u1_u003b_vf2_u003b_u1_u003b((&param_32), (&param_33), (&param_34));
    alb = _e351;
    let _e352 = (*relief);
    if _e352 {
        let _e353 = (*hp_4);
        let _e355 = (*n_3);
        local_5 = (_e353.xy + (_e355.xy * 2f));
    } else {
        let _e359 = (*face_1);
        if (_e359 == 0i) {
            let _e361 = (*hp_4);
            local_6 = _e361.xy;
        } else {
            let _e363 = (*hp_4);
            let _e365 = (*face_1);
            param_35 = _e365;
            let _e366 = face_n3_u0028_i1_u003b((&param_35));
            local_6 = (_e363.xy + (_e366.xy * 2f));
        }
        let _e370 = local_6;
        local_5 = _e370;
    }
    let _e371 = local_5;
    lp = _e371;
    let _e372 = (*relief);
    if _e372 {
        let _e373 = lp;
        let _e374 = g_world;
        local_7 = clamp(_e373, vec2<f32>(0.5f, 0.5f), (_e374 - vec2(0.5f)));
    } else {
        let _e378 = lp;
        local_7 = _e378;
    }
    let _e379 = local_7;
    param_36 = _e379;
    let _e381 = (*hp_4)[2u];
    param_37 = _e381;
    let _e382 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_36), (&param_37));
    F = _e382;
    let _e384 = (*hp_4)[2u];
    fall = (1f / (1f + (_e384 * 0.012f)));
    let _e389 = (*n_3)[1u];
    up = max(-(_e389), 0f);
    let _e393 = (*n_3)[1u];
    down = max(_e393, 0f);
    let _e396 = (*n_3)[0u];
    side = abs(_e396);
    let _e398 = (*relief);
    if _e398 {
        let _e399 = up;
        let _e402 = down;
        let _e407 = rp.view[2u];
        let _e409 = side;
        local_8 = (((1f + (0.15f * _e399)) - (0.5f * _e402)) - ((0.9f - _e407) * _e409));
    } else {
        let _e412 = (*face_1);
        if (_e412 == 0i) {
            local_9 = 1f;
        } else {
            let _e414 = (*face_1);
            if (_e414 == 1i) {
                local_10 = 1.15f;
            } else {
                let _e416 = (*face_1);
                if (_e416 == 2i) {
                    local_11 = 0.5f;
                } else {
                    let _e420 = rp.view[2u];
                    local_11 = (_e420 + 0.1f);
                }
                let _e422 = local_11;
                local_10 = _e422;
            }
            let _e423 = local_10;
            local_9 = _e423;
        }
        let _e424 = local_9;
        local_8 = _e424;
    }
    let _e425 = local_8;
    fk = _e425;
    let _e426 = lp;
    let _e427 = g_world;
    param_38 = clamp(_e426, vec2<f32>(0.5f, 0.5f), (_e427 - vec2(0.5f)));
    let _e431 = light_at_u0028_vf2_u003b((&param_38));
    ld_2 = _e431;
    lam = vec3<f32>(1f, 1f, 1f);
    let _e432 = (*relief);
    if _e432 {
        let _e435 = rp.day[3u];
        if (_e435 > 0f) {
            let _e437 = lp;
            param_39 = _e437;
            let _e438 = (*n_3);
            param_40 = _e438;
            let _e439 = ch_light_u0028_vf2_u003b_vf3_u003b((&param_39), (&param_40));
            local_12 = (vec3(0.8f) + (_e439 * 0.2f));
        } else {
            let _e443 = (*n_3);
            let _e444 = ld_2;
            param_41 = _e444;
            let _e445 = light_dir3_u0028_vf4_u003b((&param_41));
            let _e449 = ld_2[2u];
            local_12 = vec3((0.8f + ((0.4f * dot(_e443, _e445)) * _e449)));
        }
        let _e453 = local_12;
        lam = _e453;
    }
    let _e454 = (*hp_4);
    param_42 = _e454;
    let _e455 = ld_2;
    param_43 = _e455;
    let _e456 = layer0_filter_u0028_vf3_u003b_vf4_u003b((&param_42), (&param_43));
    trans = _e456;
    let _e457 = (*hp_4);
    param_44 = _e457;
    let _e458 = ao_bg_u0028_vf3_u003b((&param_44));
    ao = _e458;
    let _e459 = (*relief);
    if _e459 {
        let _e461 = rp.ambient;
        let _e463 = up;
        let _e467 = down;
        amb = ((_e461.xyz * mix(vec3<f32>(1f, 1f, 1f), vec3<f32>(0.95f, 1.05f, 1.25f), vec3(_e463))) * (1f - (0.4f * _e467)));
        let _e471 = alb;
        let _e472 = F;
        let _e476 = rp.ambient[3u];
        let _e478 = fall;
        let _e480 = fk;
        let _e482 = lam;
        let _e484 = trans;
        let _e486 = amb;
        let _e489 = ao;
        col_1 = ((_e471 * (((((((_e472 * 2f) * _e476) * _e478) * _e480) * _e482) * _e484) + _e486)) * _e489);
    } else {
        let _e492 = rp.ambient;
        let _e494 = (*face_1);
        if (_e494 == 1i) {
            local_13 = vec3<f32>(0.95f, 1.05f, 1.25f);
        } else {
            let _e496 = (*face_1);
            local_13 = select(vec3<f32>(1f, 1f, 1f), vec3<f32>(0.66f, 0.54f, 0.42f), vec3((_e496 == 2i)));
        }
        let _e500 = local_13;
        amb_1 = (_e492.xyz * _e500);
        let _e502 = F;
        let _e506 = rp.ambient[3u];
        let _e508 = fall;
        let _e510 = fk;
        let _e512 = trans;
        let _e514 = amb_1;
        let _e516 = ao;
        L = (((((((_e502 * 2f) * _e506) * _e508) * _e510) * _e512) + _e514) * _e516);
        let _e518 = alb;
        let _e519 = L;
        col_1 = (_e518 * _e519);
    }
    let _e522 = (*b_4)[0u];
    if (_e522 == 5u) {
        let _e524 = ld_2;
        param_45 = _e524;
        let _e525 = light_dir3_u0028_vf4_u003b((&param_45));
        h_1 = normalize((_e525 + vec3<f32>(0f, 0f, -1f)));
        let _e528 = F;
        let _e530 = fall;
        let _e532 = trans;
        let _e534 = (*n_3);
        let _e535 = h_1;
        let _e541 = col_1;
        col_1 = (_e541 + (((((_e528 * 2f) * _e530) * _e532) * pow(max(dot(_e534, _e535), 0f), 40f)) * 2f));
    }
    let _e544 = (*b_4)[0u];
    if (_e544 == 7u) {
        let _e547 = (*hp_4)[0u];
        let _e549 = (*hp_4)[1u];
        param_46 = vec2<f32>(_e547, (_e549 * 0.5f));
        let _e552 = sky_color_u0028_vf2_u003b((&param_46));
        col_1 = ((_e552 * 0.85f) + vec3<f32>(0.04f, 0.04f, 0.04f));
    }
    let _e556 = (*b_4)[0u];
    if (_e556 == 8u) {
        let _e558 = (*hp_4);
        param_47 = floor(_e558.xy);
        let _e561 = hash21_u0028_vf2_u003b((&param_47));
        let _e565 = col_1;
        col_1 = (_e565 + (vec3<f32>(0.25f, 0.85f, 1f) * (1f + (0.5f * _e561))));
    }
    let _e567 = col_1;
    param_48 = _e567;
    let _e568 = (*hp_4);
    param_49 = _e568;
    let _e570 = (*b_4)[0u];
    param_50 = _e570;
    let _e571 = diorama_bg_u0028_vf3_u003b_vf3_u003b_u1_u003b((&param_48), (&param_49), (&param_50));
    return _e571;
}

fn bg_depth_u0028_u1_u003b(d_1: ptr<function, u32>) -> f32 {
    let _e273 = rp.bgparams[0u];
    let _e274 = (*d_1);
    let _e279 = rp.bgparams[1u];
    let _e282 = rp.bgparams[0u];
    let _e287 = rp.bgparams[2u];
    return (_e273 + (((f32(_e274) / 255f) * (_e279 - _e282)) * _e287));
}

fn glint_u0028_vi2_u003b_i1_u003b_f1_u003b(cell: ptr<function, vec2<i32>>, face_2: ptr<function, i32>, sparkle: ptr<function, f32>) -> f32 {
    var h_2: f32;
    var param_51: vec2<f32>;
    var param_52: vec2<f32>;

    let _e276 = (*sparkle);
    if (_e276 <= 0f) {
        return 0f;
    }
    let _e278 = (*cell);
    let _e281 = (*face_2);
    param_51 = ((vec2<f32>(_e278) * 1.13f) + vec2((f32(_e281) * 7.7f)));
    let _e286 = hash21_u0028_vf2_u003b((&param_51));
    h_2 = _e286;
    let _e287 = (*sparkle);
    let _e290 = h_2;
    let _e292 = (*cell);
    param_52 = (vec2<f32>(_e292) + vec2(17f));
    let _e296 = hash21_u0028_vf2_u003b((&param_52));
    return (step((1f - (_e287 * 0.035f)), _e290) * (0.5f + (0.5f * _e296)));
}

fn max3_u0028_vf3_u003b(v_2: ptr<function, vec3<f32>>) -> f32 {
    let _e272 = (*v_2)[0u];
    let _e274 = (*v_2)[1u];
    let _e276 = (*v_2)[2u];
    return max(_e272, max(_e274, _e276));
}

fn chroma_of_u0028_vf3_u003b(c_8: ptr<function, vec3<f32>>) -> vec3<f32> {
    var param_53: vec3<f32>;

    let _e272 = (*c_8);
    let _e273 = (*c_8);
    param_53 = _e273;
    let _e274 = max3_u0028_vf3_u003b((&param_53));
    return (_e272 / vec3(max(_e274, 0.001f)));
}

fn spec_core_u0028_f1_u003b_f1_u003b_f1_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b(ks: ptr<function, f32>, rough: ptr<function, f32>, metal: ptr<function, f32>, n_4: ptr<function, vec3<f32>>, v_3: ptr<function, vec3<f32>>, l_2: ptr<function, vec3<f32>>, Li: ptr<function, vec3<f32>>, base_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var r_3: f32;
    var shin: f32;
    var h_3: vec3<f32>;
    var s_4: f32;
    var f0_: f32;
    var fres: f32;
    var tint: vec3<f32>;
    var param_54: vec3<f32>;

    let _e286 = (*ks);
    if (_e286 <= 0.001f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e288 = (*rough);
    r_3 = clamp(_e288, 0.03f, 1f);
    let _e290 = r_3;
    let _e291 = r_3;
    let _e293 = r_3;
    let _e295 = r_3;
    shin = clamp((2f / ((((_e290 * _e291) * _e293) * _e295) + 0.0001f)), 4f, 2048f);
    let _e300 = (*l_2);
    let _e301 = (*v_3);
    h_3 = normalize((_e300 + _e301));
    let _e304 = (*n_4);
    let _e305 = h_3;
    let _e308 = shin;
    let _e310 = shin;
    s_4 = ((pow(max(dot(_e304, _e305), 0f), _e308) * (_e310 + 8f)) / 50f);
    let _e314 = (*metal);
    f0_ = mix(0.04f, 1f, _e314);
    let _e316 = f0_;
    let _e317 = f0_;
    let _e319 = (*v_3);
    let _e320 = h_3;
    fres = (_e316 + ((1f - _e317) * pow((1f - max(dot(_e319, _e320), 0f)), 5f)));
    let _e327 = (*base_1);
    param_54 = _e327;
    let _e328 = chroma_of_u0028_vf3_u003b((&param_54));
    let _e329 = (*metal);
    tint = mix(vec3<f32>(1f, 1f, 1f), _e328, vec3(_e329));
    let _e332 = (*Li);
    let _e333 = s_4;
    let _e336 = (*ks);
    let _e338 = fres;
    let _e340 = tint;
    return ((((_e332 * min(_e333, 60f)) * _e336) * _e338) * _e340);
}

fn spec_term_u0028_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b(m: ptr<function, Material>, n_5: ptr<function, vec3<f32>>, v_4: ptr<function, vec3<f32>>, l_3: ptr<function, vec3<f32>>, Li_1: ptr<function, vec3<f32>>, base_2: ptr<function, vec3<f32>>) -> vec3<f32> {
    var s_5: vec3<f32>;
    var param_55: f32;
    var param_56: f32;
    var param_57: f32;
    var param_58: vec3<f32>;
    var param_59: vec3<f32>;
    var param_60: vec3<f32>;
    var param_61: vec3<f32>;
    var param_62: vec3<f32>;
    var param_63: f32;
    var param_64: f32;
    var param_65: f32;
    var param_66: vec3<f32>;
    var param_67: vec3<f32>;
    var param_68: vec3<f32>;
    var param_69: vec3<f32>;
    var param_70: vec3<f32>;

    let _e295 = (*m).surface[0u];
    param_55 = _e295;
    let _e298 = (*m).surface[1u];
    param_56 = _e298;
    let _e301 = (*m).surface[2u];
    param_57 = _e301;
    let _e302 = (*n_5);
    param_58 = _e302;
    let _e303 = (*v_4);
    param_59 = _e303;
    let _e304 = (*l_3);
    param_60 = _e304;
    let _e305 = (*Li_1);
    param_61 = _e305;
    let _e306 = (*base_2);
    param_62 = _e306;
    let _e307 = spec_core_u0028_f1_u003b_f1_u003b_f1_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b((&param_55), (&param_56), (&param_57), (&param_58), (&param_59), (&param_60), (&param_61), (&param_62));
    s_5 = _e307;
    let _e310 = (*m).sss[2u];
    if (_e310 > 0f) {
        let _e314 = (*m).sss[2u];
        param_63 = _e314;
        let _e317 = (*m).sss[3u];
        param_64 = _e317;
        param_65 = 0f;
        let _e318 = (*n_5);
        param_66 = _e318;
        let _e319 = (*v_4);
        param_67 = _e319;
        let _e320 = (*l_3);
        param_68 = _e320;
        let _e321 = (*Li_1);
        param_69 = _e321;
        let _e322 = (*base_2);
        param_70 = _e322;
        let _e323 = spec_core_u0028_f1_u003b_f1_u003b_f1_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b((&param_63), (&param_64), (&param_65), (&param_66), (&param_67), (&param_68), (&param_69), (&param_70));
        let _e325 = s_5;
        s_5 = (_e325 + (_e323 * 1.4f));
    }
    let _e327 = s_5;
    return _e327;
}

fn fluence_at_u0028_vf2_u003b(xy_3: ptr<function, vec2<f32>>) -> vec3<f32> {
    let _e271 = (*xy_3);
    let _e272 = g_world;
    let _e274 = textureSampleLevel(fl0_, fl0_smp, (_e271 / _e272), 0f);
    return _e274.xyz;
}

fn form_tint_u0028_vf3_u003b(n_6: ptr<function, vec3<f32>>) -> vec3<f32> {
    var warm: vec3<f32>;
    var cool: vec3<f32>;

    warm = vec3<f32>(1.06f, 1f, 0.9f);
    cool = vec3<f32>(0.92f, 0.97f, 1.08f);
    let _e273 = cool;
    let _e274 = warm;
    let _e276 = (*n_6)[1u];
    let _e279 = (*n_6);
    let _e290 = rp.look[0u];
    let _e292 = (*n_6)[2u];
    return mix(vec3<f32>(1f, 1f, 1f), mix(_e273, _e274, vec3(clamp((((-(_e276) * 0.8f) + (dot(_e279.xy, vec2<f32>(-0.5323273f, -0.7259009f)) * 0.4f)) + 0.3f), 0f, 1f))), vec3((_e290 * select(0f, 1f, (_e292 > -0.9f)))));
}

fn form_k_u0028_vf3_u003b(n_7: ptr<function, vec3<f32>>) -> f32 {
    var a_6: f32;
    var k_3: f32;

    let _e273 = (*n_7);
    a_6 = (0.35f + (0.65f * max(dot(_e273, vec3<f32>(-0.5323273f, -0.7259009f, -0.43554053f)), 0f)));
    let _e278 = a_6;
    k_3 = (_e278 / 0.6425f);
    let _e281 = (*n_7)[1u];
    let _e285 = k_3;
    k_3 = (_e285 * (1f - (0.35f * max(_e281, 0f))));
    let _e287 = k_3;
    let _e290 = rp.look[0u];
    return mix(1f, _e287, _e290);
}

fn bevel_n_u0028_vf2_u003b(c_9: ptr<function, vec2<f32>>) -> vec3<f32> {
    var gx: f32;
    var gy: f32;
    var g: vec2<f32>;

    let _e274 = (*c_9);
    let _e276 = g_world;
    let _e278 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e274 + vec2<f32>(1.5f, 0f)) / _e276), 0f);
    let _e280 = (*c_9);
    let _e282 = g_world;
    let _e284 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e280 - vec2<f32>(1.5f, 0f)) / _e282), 0f);
    gx = (_e278.z - _e284.z);
    let _e287 = (*c_9);
    let _e289 = g_world;
    let _e291 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e287 + vec2<f32>(0f, 1.5f)) / _e289), 0f);
    let _e293 = (*c_9);
    let _e295 = g_world;
    let _e297 = textureSampleLevel(occ_tex, occ_tex_smp, ((_e293 - vec2<f32>(0f, 1.5f)) / _e295), 0f);
    gy = (_e291.z - _e297.z);
    let _e300 = gx;
    let _e301 = gy;
    g = (vec2<f32>(_e300, _e301) / vec2(3f));
    let _e305 = g;
    let _e308 = ((-(_e305) * 2.5f) * 2.5f);
    return normalize(vec3<f32>(_e308.x, _e308.y, -1f));
}

fn hash3_u0028_vf2_u003b(p_4: ptr<function, vec2<f32>>) -> vec3<f32> {
    var h_4: vec3<u32>;
    var param_71: vec3<u32>;

    let _e273 = (*p_4);
    let _e279 = bitcast<vec2<u32>>((vec2<i32>(floor((_e273 * 7f))) + vec2(32768i)));
    param_71 = vec3<u32>(_e279.x, _e279.y, 91u);
    let _e283 = pcg3d_u0028_vu3_u003b((&param_71));
    h_4 = _e283;
    let _e284 = h_4;
    return (vec3<f32>((_e284 & vec3(65535u))) / vec3(65535f));
}

fn shade_l0_u0028_vf3_u003b_i1_u003b_vf3_u003b_vi2_u003b_vf3_u003b(S: ptr<function, vec3<f32>>, face_3: ptr<function, i32>, hp_5: ptr<function, vec3<f32>>, cell_1: ptr<function, vec2<i32>>, d_2: ptr<function, vec3<f32>>) -> vec3<f32> {
    var mid: u32;
    var m_1: Material;
    var n_8: vec3<f32>;
    var param_72: i32;
    var n2_: vec2<f32>;
    var local_14: vec2<f32>;
    var lp_1: vec2<f32>;
    var ld_3: vec4<f32>;
    var param_73: vec2<f32>;
    var l_4: vec3<f32>;
    var param_74: vec4<f32>;
    var v_5: vec3<f32>;
    var jit: vec3<f32>;
    var param_75: vec2<f32>;
    var nm: vec3<f32>;
    var k_4: f32;
    var kc: vec3<f32>;
    var b25_: bool;
    var nb: vec3<f32>;
    var param_76: vec2<f32>;
    var param_77: vec2<f32>;
    var param_78: vec3<f32>;
    var f_3: f32;
    var f_4: f32;
    var local_15: f32;
    var lit_1: f32;
    var param_79: vec2<f32>;
    var param_80: vec3<f32>;
    var param_81: vec3<f32>;
    var param_82: vec3<f32>;
    var col_2: vec3<f32>;
    var param_83: vec3<f32>;
    var edge_1: f32;
    var q_1: vec2<f32>;
    var Lb: vec3<f32>;
    var param_84: vec2<f32>;
    var param_85: f32;
    var kb: u32;
    var rim: f32;
    var param_86: vec2<f32>;
    var param_87: f32;
    var Li_2: vec3<f32>;
    var param_88: vec2<f32>;
    var notMirror: f32;
    var param_89: Material;
    var param_90: vec3<f32>;
    var param_91: vec3<f32>;
    var param_92: vec3<f32>;
    var param_93: vec3<f32>;
    var param_94: vec3<f32>;
    var r_4: vec3<f32>;
    var env: vec3<f32>;
    var param_95: vec2<f32>;
    var param_96: f32;
    var f0_1: f32;
    var fr: f32;
    var param_97: vec3<f32>;
    var Ldirect: vec3<f32>;
    var param_98: vec2<i32>;
    var param_99: i32;
    var param_100: f32;
    var param_101: vec3<f32>;
    var phi_1849_: bool;
    var phi_1958_: bool;
    var phi_2007_: bool;
    var phi_2144_: bool;

    let _e338 = g_cost[2u];
    g_cost[2u] = (_e338 + 6u);
    let _e341 = (*cell_1);
    let _e342 = textureLoad(cells, _e341, 0i);
    mid = (_e342.x & 255u);
    let _e345 = mid;
    let _e348 = unnamed.mats[_e345];
    m_1.color_a = _e348.color_a;
    m_1.color_b = _e348.color_b;
    m_1.emission = _e348.emission;
    m_1.phys = _e348.phys;
    m_1.thermo = _e348.thermo;
    m_1.burn = _e348.burn;
    m_1.optics = _e348.optics;
    m_1.scatter = _e348.scatter;
    m_1.ids = _e348.ids;
    m_1.ids2_ = _e348.ids2_;
    m_1.misc = _e348.misc;
    m_1.surface = _e348.surface;
    m_1.sss = _e348.sss;
    m_1.sss_color = _e348.sss_color;
    m_1.optics2_ = _e348.optics2_;
    m_1.pal0_ = _e348.pal0_;
    m_1.pal1_ = _e348.pal1_;
    m_1.pal2_ = _e348.pal2_;
    m_1.pal3_ = _e348.pal3_;
    m_1.accent = _e348.accent;
    m_1.flame = _e348.flame;
    let _e391 = (*face_3);
    param_72 = _e391;
    let _e392 = face_n3_u0028_i1_u003b((&param_72));
    n_8 = _e392;
    let _e393 = (*face_3);
    if (_e393 == 0i) {
        let _e395 = (*cell_1);
        let _e396 = textureLoad(gaux_img, _e395, 0i);
        local_14 = _e396.xy;
    } else {
        let _e398 = n_8;
        local_14 = _e398.xy;
    }
    let _e400 = local_14;
    n2_ = _e400;
    let _e401 = (*cell_1);
    let _e405 = n2_;
    lp_1 = ((vec2<f32>(_e401) + vec2(0.5f)) + (_e405 * 1.5f));
    let _e408 = lp_1;
    param_73 = _e408;
    let _e409 = light_at_u0028_vf2_u003b((&param_73));
    ld_3 = _e409;
    let _e410 = ld_3;
    param_74 = _e410;
    let _e411 = light_dir3_u0028_vf4_u003b((&param_74));
    l_4 = _e411;
    let _e412 = (*d_2);
    v_5 = -(_e412);
    let _e414 = (*cell_1);
    let _e417 = (*face_3);
    param_75 = ((vec2<f32>(_e414) * 1.7f) + vec2((f32(_e417) * 3.3f)));
    let _e422 = hash3_u0028_vf2_u003b((&param_75));
    jit = (_e422 - vec3(0.5f));
    let _e425 = n_8;
    let _e426 = jit;
    let _e429 = m_1.surface[1u];
    nm = normalize((_e425 + ((_e426 * _e429) * 0.6f)));
    k_4 = 1f;
    kc = vec3<f32>(1f, 1f, 1f);
    let _e436 = rp.look2_[3u];
    let _e438 = (*face_3);
    let _e441 = g_T0_;
    b25_ = (((_e436 > 0f) && (_e438 == 0i)) && (_e441 < 0.01f));
    let _e444 = n_8;
    nb = _e444;
    let _e445 = b25_;
    if _e445 {
        let _e446 = (*cell_1);
        param_76 = (vec2<f32>(_e446) + vec2(0.5f));
        let _e450 = bevel_n_u0028_vf2_u003b((&param_76));
        nb = _e450;
        let _e453 = rp.day[3u];
        if (_e453 > 0f) {
            let _e455 = lp_1;
            param_77 = _e455;
            let _e456 = nb;
            param_78 = _e456;
            let _e457 = ch_light_u0028_vf2_u003b_vf3_u003b((&param_77), (&param_78));
            let _e461 = rp.look2_[3u];
            kc = pow(max(_e457, vec3<f32>(0.05f, 0.05f, 0.05f)), vec3((_e461 * 0.6f)));
        } else {
            let _e465 = nb;
            let _e466 = l_4;
            let _e472 = l_4[2u];
            f_3 = ((0.45f + (0.55f * max(dot(_e465, _e466), 0f))) / (0.45f + (0.55f * max(-(_e472), 0f))));
            let _e478 = f_3;
            let _e482 = rp.look2_[3u];
            let _e484 = k_4;
            k_4 = (_e484 * pow(max(_e478, 0.05f), _e482));
        }
        let _e486 = nb;
        n_8 = _e486;
        let _e487 = nb;
        let _e488 = jit;
        let _e491 = m_1.surface[1u];
        nm = normalize((_e487 + ((_e488 * _e491) * 0.6f)));
    }
    let _e496 = (*face_3);
    let _e497 = (_e496 == 0i);
    phi_1849_ = _e497;
    if _e497 {
        let _e498 = n2_;
        let _e499 = n2_;
        phi_1849_ = (dot(_e498, _e499) > 0f);
    }
    let _e503 = phi_1849_;
    let _e504 = g_T0_;
    if (_e503 && (_e504 > 0.01f)) {
        let _e507 = n2_;
        f_4 = dot(normalize(_e507), vec2<f32>(-0.59136367f, -0.806405f));
        let _e510 = f_4;
        if (_e510 > 0f) {
            let _e512 = g_frontRim;
            let _e514 = f_4;
            local_15 = (1f + ((_e512 * 1.6f) * _e514));
        } else {
            let _e517 = g_frontRim;
            let _e519 = f_4;
            local_15 = (1f + ((_e517 * 1.2f) * _e519));
        }
        let _e522 = local_15;
        let _e523 = k_4;
        k_4 = (_e523 * _e522);
    }
    let _e525 = (*face_3);
    if (_e525 != 0i) {
        let _e527 = n_8;
        let _e529 = ld_3;
        let _e534 = ld_3[2u];
        lit_1 = (max(dot(_e527.xy, _e529.xy), 0f) * _e534);
        let _e538 = rp.day[3u];
        if (_e538 > 0f) {
            let _e540 = lp_1;
            param_79 = _e540;
            let _e541 = n_8;
            param_80 = _e541;
            let _e542 = ch_light_u0028_vf2_u003b_vf3_u003b((&param_79), (&param_80));
            kc = _e542;
            lit_1 = 0f;
        }
        let _e543 = (*face_3);
        if (_e543 == 1i) {
            let _e545 = lit_1;
            k_4 = (1f + (0.3f * _e545));
        } else {
            let _e548 = (*face_3);
            if (_e548 == 2i) {
                let _e550 = lit_1;
                k_4 = (0.42f + (0.2f * _e550));
            } else {
                let _e555 = rp.view[2u];
                let _e556 = lit_1;
                k_4 = (_e555 + (0.35f * _e556));
            }
        }
        let _e560 = (*hp_5)[2u];
        let _e561 = g_T0_;
        let _e566 = k_4;
        k_4 = (_e566 * mix(1f, 0.7f, clamp((_e560 / max(_e561, 0.001f)), 0f, 1f)));
        let _e568 = k_4;
        let _e569 = k_4;
        let _e570 = n_8;
        param_81 = _e570;
        let _e571 = form_k_u0028_vf3_u003b((&param_81));
        param_82 = vec3<f32>(0f, 0f, -1f);
        let _e573 = form_k_u0028_vf3_u003b((&param_82));
        let _e578 = rp.look[0u];
        k_4 = mix(_e568, ((_e569 * _e571) / max(_e573, 0.001f)), _e578);
        let _e580 = (*face_3);
        let _e581 = (_e580 == 1i);
        phi_1958_ = _e581;
        if _e581 {
            let _e583 = (*hp_5)[2u];
            phi_1958_ = (_e583 < 0.6f);
        }
        let _e586 = phi_1958_;
        if _e586 {
            let _e589 = rp.cam_down[3u];
            let _e591 = k_4;
            k_4 = (_e591 * (1f + _e589));
        }
    }
    let _e593 = nm;
    let _e594 = l_4;
    let _e601 = k_4;
    k_4 = (_e601 * (0.9f + (0.2f * clamp(((dot(_e593, _e594) * 0.5f) + 0.5f), 0f, 1f))));
    let _e603 = k_4;
    let _e604 = (*face_3);
    let _e611 = m_1.sss[0u];
    k_4 = mix(_e603, (1f + (0.12f * select(0f, 1f, (_e604 != 0i)))), (_e611 * 0.7f));
    let _e614 = (*S);
    let _e615 = k_4;
    let _e617 = kc;
    let _e619 = n_8;
    param_83 = _e619;
    let _e620 = form_tint_u0028_vf3_u003b((&param_83));
    let _e624 = m_1.surface[2u];
    col_2 = ((((_e614 * _e615) * _e617) * _e620) * (1f - (0.45f * _e624)));
    let _e628 = b25_;
    phi_2007_ = _e628;
    if _e628 {
        let _e631 = rp.look2_[2u];
        phi_2007_ = (_e631 > 0f);
    }
    let _e634 = phi_2007_;
    if _e634 {
        let _e636 = nb[2u];
        edge_1 = pow((1f - clamp(-(_e636), 0f, 1f)), 1.2f);
        let _e641 = edge_1;
        if (_e641 > 0.01f) {
            let _e643 = (*cell_1);
            let _e647 = nb;
            q_1 = ((vec2<f32>(_e643) + vec2(0.5f)) + (_e647.xy * 4f));
            let _e651 = q_1;
            let _e652 = g_world;
            param_84 = clamp(_e651, vec2<f32>(0.5f, 0.5f), (_e652 - vec2(0.5f)));
            param_85 = 40f;
            let _e656 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_84), (&param_85));
            Lb = _e656;
            let _e657 = q_1;
            let _e659 = g_world;
            let _e664 = textureLoad(bg, clamp(vec2<i32>(_e657), vec2<i32>(0i, 0i), (vec2<i32>(_e659) - vec2(1i))), 0i);
            kb = _e664.x;
            let _e666 = q_1;
            let _e667 = g_world;
            let _e669 = textureSampleLevel(day_tex, day_tex_smp, (_e666 / _e667), 0f);
            let _e672 = Lb;
            Lb = (_e672 + (_e669.xyz * 0.6f));
            let _e674 = Lb;
            let _e675 = edge_1;
            let _e679 = rp.look2_[2u];
            let _e682 = col_2;
            col_2 = (_e682 + (((_e674 * _e675) * _e679) * 2.2f));
        }
    }
    let _e686 = m_1.sss[0u];
    if (_e686 > 0f) {
        let _e688 = v_5;
        let _e689 = nm;
        rim = pow((1f - clamp(dot(_e688, _e689), 0f, 1f)), 4f);
        let _e694 = rim;
        let _e697 = m_1.sss[2u];
        let _e699 = (*cell_1);
        let _e703 = n2_;
        param_86 = ((vec2<f32>(_e699) + vec2(0.5f)) + (_e703 * 3f));
        param_87 = 4f;
        let _e706 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_86), (&param_87));
        let _e709 = col_2;
        col_2 = (_e709 + ((_e706 * (_e694 * _e697)) * 1.2f));
    }
    let _e711 = lp_1;
    param_88 = _e711;
    let _e712 = fluence_at_u0028_vf2_u003b((&param_88));
    let _e715 = rp.ambient;
    Li_2 = ((_e712 * 2f) + _e715.xyz);
    let _e720 = m_1.optics2_[1u];
    notMirror = (1f - _e720);
    let _e722 = m_1;
    param_89 = _e722;
    let _e723 = nm;
    param_90 = _e723;
    let _e724 = v_5;
    param_91 = _e724;
    let _e725 = l_4;
    param_92 = _e725;
    let _e726 = Li_2;
    param_93 = _e726;
    let _e727 = (*S);
    param_94 = _e727;
    let _e728 = spec_term_u0028_struct_u002d_Material_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vu4_u002d_vu4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf4_u002d_vf41_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b_vf3_u003b((&param_89), (&param_90), (&param_91), (&param_92), (&param_93), (&param_94));
    let _e729 = notMirror;
    let _e731 = col_2;
    col_2 = (_e731 + (_e728 * _e729));
    let _e735 = m_1.surface[0u];
    let _e736 = (_e735 > 0.3f);
    phi_2144_ = _e736;
    if _e736 {
        let _e739 = m_1.surface[1u];
        phi_2144_ = (_e739 < 0.5f);
    }
    let _e742 = phi_2144_;
    let _e743 = notMirror;
    if (_e742 && (_e743 > 0.5f)) {
        let _e746 = (*d_2);
        let _e747 = nm;
        r_4 = reflect(_e746, _e747);
        let _e749 = (*cell_1);
        let _e753 = r_4;
        param_95 = ((vec2<f32>(_e749) + vec2(0.5f)) + (_e753.xy * 6f));
        param_96 = 6f;
        let _e757 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_95), (&param_96));
        env = _e757;
        let _e760 = m_1.surface[2u];
        f0_1 = mix(0.04f, 1f, _e760);
        let _e762 = f0_1;
        let _e763 = f0_1;
        let _e765 = v_5;
        let _e766 = nm;
        fr = (_e762 + ((1f - _e763) * pow((1f - max(dot(_e765, _e766), 0f)), 5f)));
        let _e773 = env;
        let _e774 = fr;
        let _e778 = m_1.surface[0u];
        let _e782 = m_1.surface[1u];
        let _e785 = (*S);
        param_97 = _e785;
        let _e786 = chroma_of_u0028_vf3_u003b((&param_97));
        let _e789 = m_1.surface[2u];
        let _e793 = col_2;
        col_2 = (_e793 + ((((_e773 * _e774) * _e778) * (1f - _e782)) * mix(vec3<f32>(1f, 1f, 1f), _e786, vec3(_e789))));
    }
    let _e795 = Li_2;
    let _e797 = rp.ambient;
    Ldirect = max((_e795 - (_e797.xyz * 1.5f)), vec3<f32>(0f, 0f, 0f));
    let _e802 = Ldirect;
    let _e803 = (*cell_1);
    param_98 = _e803;
    let _e804 = (*face_3);
    param_99 = _e804;
    let _e807 = m_1.surface[3u];
    param_100 = _e807;
    let _e808 = glint_u0028_vi2_u003b_i1_u003b_f1_u003b((&param_98), (&param_99), (&param_100));
    let _e811 = (*S);
    param_101 = _e811;
    let _e812 = chroma_of_u0028_vf3_u003b((&param_101));
    let _e816 = col_2;
    col_2 = (_e816 + (((_e802 * _e808) * 5f) * mix(vec3<f32>(1f, 1f, 1f), _e812, vec3(0.3f))));
    let _e818 = col_2;
    return _e818;
}

fn view_globals_u0028_() {
    let _e271 = pc.i1_;
    g_world = vec2<f32>(_e271.xy);
    let _e276 = rp.misc[0u];
    g_time = _e276;
    let _e279 = rp.cam_right[3u];
    g_T0_ = _e279;
    let _e282 = rp.cam_down[0u];
    g_F = _e282;
    let _e285 = rp.cam_down[1u];
    g_sigmaMax = _e285;
    let _e288 = rp.cam_down[2u];
    g_backFade = _e288;
    let _e291 = rp.cam_right[1u];
    g_frontRim = _e291;
    let _e294 = rp.misc2_[3u];
    g_bgSmooth = _e294;
    return;
}

fn main_1() {
    var c_10: vec2<i32>;
    var H: i32;
    var d_3: vec3<f32>;
    var front: vec3<f32>;
    var s_6: vec4<f32>;
    var param_102: vec3<f32>;
    var param_103: i32;
    var param_104: vec3<f32>;
    var param_105: vec2<i32>;
    var param_106: vec3<f32>;
    var col_3: vec3<f32>;
    var haze: vec4<f32>;
    var b_5: vec4<u32>;
    var hp_6: vec3<f32>;
    var param_107: u32;
    var param_108: i32;
    var param_109: vec4<u32>;
    var param_110: i32;
    var param_111: vec3<f32>;
    var param_112: vec3<f32>;
    var param_113: bool;
    var param_114: vec3<f32>;

    g_useCells = false;
    g_cost = vec3<u32>(0u, 0u, 0u);
    let _e292 = gl_GlobalInvocationID_1;
    c_10 = bitcast<vec2<i32>>(_e292.xy);
    let _e295 = c_10;
    let _e297 = pc.i1_;
    if any((_e295 >= _e297.xy)) {
        return;
    }
    view_globals_u0028_();
    let _e303 = pc.i1_[1u];
    H = _e303;
    let _e305 = rp.look2_;
    let _e306 = _e305.xy;
    d_3 = normalize(vec3<f32>(_e306.x, _e306.y, 1f));
    front = vec3<f32>(0f, 0f, 0f);
    let _e311 = c_10;
    let _e312 = textureLoad(l0s, _e311, 0i);
    s_6 = _e312;
    let _e314 = s_6[3u];
    if (_e314 >= 0.99f) {
        let _e316 = c_10;
        let _e319 = (vec2<f32>(_e316) + vec2(0.5f));
        let _e323 = s_6;
        param_102 = _e323.xyz;
        param_103 = 0i;
        param_104 = vec3<f32>(_e319.x, _e319.y, 0f);
        let _e325 = c_10;
        param_105 = _e325;
        let _e326 = d_3;
        param_106 = _e326;
        let _e327 = shade_l0_u0028_vf3_u003b_i1_u003b_vf3_u003b_vi2_u003b_vf3_u003b((&param_102), (&param_103), (&param_104), (&param_105), (&param_106));
        front = _e327;
    }
    col_3 = vec3<f32>(0f, 0f, 0f);
    haze = vec4<f32>(0f, 0f, 0f, 0f);
    let _e328 = c_10;
    let _e329 = textureLoad(bg, _e328, 0i);
    b_5 = _e329;
    let _e331 = b_5[0u];
    if (_e331 != 0u) {
        let _e333 = c_10;
        let _e336 = (vec2<f32>(_e333) + vec2(0.5f));
        let _e338 = b_5[1u];
        param_107 = _e338;
        let _e339 = bg_depth_u0028_u1_u003b((&param_107));
        hp_6 = vec3<f32>(_e336.x, _e336.y, _e339);
        param_108 = 0i;
        let _e343 = face_n3_u0028_i1_u003b((&param_108));
        let _e344 = b_5;
        param_109 = _e344;
        param_110 = 0i;
        param_111 = _e343;
        let _e345 = hp_6;
        param_112 = _e345;
        param_113 = false;
        let _e346 = shade_bg_u0028_vu4_u003b_i1_u003b_vf3_u003b_vf3_u003b_b1_u003b((&param_109), (&param_110), (&param_111), (&param_112), (&param_113));
        col_3 = _e346;
        let _e347 = hp_6;
        param_114 = _e347;
        let _e348 = bg_haze_u0028_vf3_u003b((&param_114));
        haze = _e348;
    }
    let _e349 = c_10;
    let _e350 = front;
    textureStore(cell_shade, _e349, vec4<f32>(_e350.x, _e350.y, _e350.z, 0f));
    let _e355 = c_10;
    let _e356 = H;
    let _e359 = col_3;
    textureStore(cell_shade, (_e355 + vec2<i32>(0i, _e356)), vec4<f32>(_e359.x, _e359.y, _e359.z, 0f));
    let _e364 = c_10;
    let _e365 = H;
    let _e369 = haze;
    textureStore(cell_shade, (_e364 + vec2<i32>(0i, (2i * _e365))), _e369);
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
