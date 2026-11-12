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
@group(0) @binding(10) 
var day_cells: texture_2d<u32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(5) 
var<uniform> rp: RenderParams;
@group(0) @binding(7) 
var<storage> unnamed: Materials;
@group(0) @binding(3) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(3) 
var medium_tex_smp: sampler;
@group(0) @binding(8) 
var prev_img: texture_2d<f32>;
@group(0) @binding(4) 
var out_img: texture_storage_2d<rgba16float,write>;

fn local_normal_u0028_vi2_u003b_u1_u003b(q: ptr<function, vec2<i32>>, mid: ptr<function, u32>) -> vec2<f32> {
    var g: vec2<f32>;
    var y: i32;
    var x: i32;
    var c: vec2<i32>;
    var inside: bool;
    var same: bool;
    var dc: vec4<u32>;
    var phi_96_: bool;
    var phi_137_: bool;
    var phi_138_: bool;

    g = vec2<f32>(0f, 0f);
    y = -1i;
    loop {
        let _e64 = y;
        if (_e64 <= 1i) {
            x = -1i;
            loop {
                let _e66 = x;
                if (_e66 <= 1i) {
                    let _e68 = (*q);
                    let _e69 = x;
                    let _e70 = y;
                    c = (_e68 + vec2<i32>(_e69, _e70));
                    let _e73 = c;
                    let _e75 = all((_e73 >= vec2<i32>(0i, 0i)));
                    phi_96_ = _e75;
                    if _e75 {
                        let _e76 = c;
                        let _e78 = pc.i0_;
                        phi_96_ = all((_e76 < _e78.xy));
                    }
                    let _e83 = phi_96_;
                    inside = _e83;
                    same = false;
                    let _e84 = inside;
                    if _e84 {
                        let _e85 = c;
                        let _e86 = textureLoad(day_cells, _e85, 0i);
                        dc = _e86;
                        let _e88 = dc[2u];
                        let _e92 = (*mid);
                        let _e93 = (((_e88 >> bitcast<u32>(16i)) & 255u) == _e92);
                        phi_138_ = _e93;
                        if !(_e93) {
                            let _e96 = dc[1u];
                            let _e99 = (unpack2x16float(_e96).y < 0.97f);
                            phi_137_ = _e99;
                            if _e99 {
                                let _e101 = dc[2u];
                                phi_137_ = ((_e101 & 255u) == 3u);
                            }
                            let _e105 = phi_137_;
                            phi_138_ = _e105;
                        }
                        let _e107 = phi_138_;
                        same = _e107;
                    }
                    let _e108 = same;
                    if !(_e108) {
                        let _e110 = x;
                        let _e112 = y;
                        let _e115 = g;
                        g = (_e115 + vec2<f32>(f32(_e110), f32(_e112)));
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e117 = x;
                    x = (_e117 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e119 = y;
            y = (_e119 + 1i);
        }
    }
    let _e121 = g;
    return _e121;
}

fn bg_transmission_u0028_u1_u003b(kind: ptr<function, u32>) -> vec3<f32> {
    let _e56 = (*kind);
    if (_e56 == 0u) {
        return vec3<f32>(1f, 1f, 1f);
    }
    let _e58 = (*kind);
    if (_e58 == 7u) {
        return vec3<f32>(0.82f, 0.88f, 0.9f);
    }
    return vec3<f32>(0f, 0f, 0f);
}

fn main_1() {
    var p: vec2<i32>;
    var n: vec2<i32>;
    var dir: vec2<f32>;
    var sun: vec3<f32>;
    var T: vec3<f32>;
    var L: vec3<f32>;
    var self_: bool;
    var pos: vec2<f32>;
    var t: i32;
    var x_1: vec2<f32>;
    var q_1: vec2<i32>;
    var dc_1: vec4<u32>;
    var st: u32;
    var alb: vec4<f32>;
    var mat: u32;
    var agitation: u32;
    var gas: bool;
    var tr: vec3<f32>;
    var param: u32;
    var open: bool;
    var ior: f32;
    var nq: vec2<f32>;
    var param_1: vec2<i32>;
    var param_2: u32;
    var oblique: bool;
    var agit: f32;
    var moving: bool;
    var md: vec4<f32>;
    var spread: f32;
    var prev: vec3<f32>;
    var phi_241_: bool;
    var phi_250_: bool;
    var phi_296_: bool;
    var phi_353_: bool;
    var phi_365_: bool;

    let _e85 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e85.xy);
    let _e89 = pc.i0_;
    n = _e89.xy;
    let _e91 = p;
    let _e92 = n;
    if any((_e91 >= _e92)) {
        return;
    }
    let _e96 = pc.f0_;
    dir = _e96.xy;
    let _e99 = rp.sun_color;
    let _e103 = pc.f0_[2u];
    sun = (_e99.xyz * _e103);
    T = vec3<f32>(1f, 1f, 1f);
    L = vec3<f32>(0f, 0f, 0f);
    self_ = false;
    let _e105 = p;
    pos = (vec2<f32>(_e105) + vec2(0.5f));
    t = 0i;
    loop {
        let _e109 = t;
        if (_e109 < 360i) {
            let _e111 = pos;
            let _e112 = dir;
            let _e113 = t;
            x_1 = (_e111 - (_e112 * f32(_e113)));
            let _e117 = x_1;
            q_1 = vec2<i32>(floor(_e117));
            let _e121 = q_1[1u];
            if (_e121 < 0i) {
                break;
            }
            let _e124 = q_1[0u];
            let _e125 = (_e124 < 0i);
            phi_241_ = _e125;
            if !(_e125) {
                let _e128 = q_1[0u];
                let _e130 = n[0u];
                phi_241_ = (_e128 >= _e130);
            }
            let _e133 = phi_241_;
            phi_250_ = _e133;
            if !(_e133) {
                let _e136 = q_1[1u];
                let _e138 = n[1u];
                phi_250_ = (_e136 >= _e138);
            }
            let _e141 = phi_250_;
            if _e141 {
                break;
            }
            let _e142 = q_1;
            let _e143 = textureLoad(day_cells, _e142, 0i);
            dc_1 = _e143;
            let _e145 = dc_1[2u];
            st = (_e145 & 255u);
            let _e148 = dc_1[0u];
            let _e149 = unpack2x16float(_e148);
            let _e151 = dc_1[1u];
            let _e152 = unpack2x16float(_e151);
            alb = vec4<f32>(_e149.x, _e149.y, _e152.x, _e152.y);
            let _e159 = dc_1[2u];
            mat = ((_e159 >> bitcast<u32>(16i)) & 255u);
            let _e164 = dc_1[2u];
            agitation = (_e164 >> bitcast<u32>(24i));
            let _e167 = st;
            gas = (_e167 == 0u);
            let _e169 = gas;
            let _e170 = !(_e169);
            phi_296_ = _e170;
            if _e170 {
                let _e172 = alb[3u];
                phi_296_ = (_e172 >= 0.97f);
            }
            let _e175 = phi_296_;
            if _e175 {
                T = vec3<f32>(0f, 0f, 0f);
                break;
            }
            let _e177 = dc_1[2u];
            param = ((_e177 >> bitcast<u32>(8i)) & 255u);
            let _e181 = bg_transmission_u0028_u1_u003b((&param));
            tr = _e181;
            let _e183 = tr[0u];
            let _e185 = tr[1u];
            let _e187 = tr[2u];
            open = (max(_e183, max(_e185, _e187)) > 0f);
            let _e191 = gas;
            let _e193 = open;
            if (!(_e191) && !(_e193)) {
                let _e196 = mat;
                let _e201 = unnamed.mats[_e196].optics[2u];
                ior = _e201;
                let _e202 = q_1;
                param_1 = _e202;
                let _e203 = mat;
                param_2 = _e203;
                let _e204 = local_normal_u0028_vi2_u003b_u1_u003b((&param_1), (&param_2));
                nq = _e204;
                let _e206 = nq[0u];
                let _e208 = (abs(_e206) > 0.5f);
                phi_353_ = _e208;
                if _e208 {
                    let _e210 = nq[1u];
                    phi_353_ = (abs(_e210) > 0.5f);
                }
                let _e214 = phi_353_;
                phi_365_ = _e214;
                if _e214 {
                    let _e216 = nq[0u];
                    let _e219 = nq[1u];
                    phi_365_ = (abs((abs(_e216) - abs(_e219))) < 0.5f);
                }
                let _e225 = phi_365_;
                oblique = _e225;
                let _e226 = st;
                let _e228 = ior;
                let _e231 = oblique;
                if (((_e226 != 1u) && (_e228 > 1.05f)) && _e231) {
                    T = vec3<f32>(0f, 0f, 0f);
                    break;
                }
                let _e233 = st;
                if (_e233 == 1u) {
                    let _e235 = agitation;
                    agit = (f32(_e235) / 255f);
                    let _e238 = agit;
                    let _e239 = T;
                    T = (_e239 * _e238);
                    let _e242 = T[0u];
                    let _e244 = T[1u];
                    let _e246 = T[2u];
                    if (max(_e242, max(_e244, _e246)) < 0.01f) {
                        break;
                    }
                }
            }
            let _e250 = gas;
            if !(_e250) {
                let _e252 = st;
                let _e254 = agitation;
                moving = ((_e252 == 1u) && (_e254 != 0u));
                let _e257 = moving;
                if _e257 {
                    let _e258 = alb;
                    let _e266 = T;
                    T = (_e266 * mix(vec3<f32>(1f, 1f, 1f), clamp((_e258.xyz * 1.25f), vec3(0f), vec3(1f)), vec3(0.04f)));
                } else {
                    let _e268 = alb;
                    let _e275 = alb[3u];
                    let _e281 = alb[3u];
                    let _e285 = T;
                    T = (_e285 * (mix(vec3<f32>(1f, 1f, 1f), clamp((_e268.xyz * 1.25f), vec3(0f), vec3(1f)), vec3(((0.6f * _e275) + 0.15f))) * (1f - (0.06f * _e281))));
                }
            } else {
                let _e287 = x_1;
                let _e288 = n;
                let _e291 = textureSampleLevel(medium_tex, medium_tex_smp, (_e287 / vec2<f32>(_e288)), 0f);
                md = _e291;
                let _e293 = md[0u];
                let _e296 = rp.medium[0u];
                let _e300 = md[1u];
                let _e303 = rp.medium[1u];
                let _e309 = T;
                T = (_e309 * exp(-((((_e293 * _e296) * 0.6f) + ((_e300 * _e303) * 0.25f)))));
                let _e313 = pc.f0_[3u];
                if (_e313 > 0f) {
                    let _e317 = pc.f0_[3u];
                    let _e320 = T;
                    T = (_e320 * exp((-1f / _e317)));
                }
            }
            let _e322 = open;
            if _e322 {
                let _e323 = gas;
                if !(_e323) {
                    let _e325 = alb;
                    let _e333 = T;
                    T = (_e333 * mix(vec3<f32>(1f, 1f, 1f), clamp((_e325.xyz * 1.3f), vec3(0f), vec3(1f)), vec3(0.85f)));
                }
                let _e335 = t;
                spread = (1f - smoothstep(180f, 352.8f, f32(_e335)));
                let _e339 = sun;
                let _e340 = T;
                let _e342 = tr;
                let _e344 = spread;
                L = (((_e339 * _e340) * _e342) * _e344);
                let _e346 = t;
                self_ = (_e346 == 0i);
                break;
            }
            let _e349 = T[0u];
            let _e351 = T[1u];
            let _e353 = T[2u];
            if (max(_e349, max(_e351, _e353)) < 0.01f) {
                break;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e357 = t;
            t = (_e357 + 1i);
        }
    }
    let _e359 = p;
    let _e360 = textureLoad(prev_img, _e359, 0i);
    prev = _e360.xyz;
    let _e362 = p;
    let _e363 = prev;
    let _e364 = L;
    let _e366 = mix(_e363, _e364, vec3(0.15f));
    let _e367 = self_;
    textureStore(out_img, _e362, vec4<f32>(_e366.x, _e366.y, _e366.z, select(0f, 1f, _e367)));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
