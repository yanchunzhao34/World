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

var<private> g_world: vec2<f32>;
@group(0) @binding(8) 
var backlight: texture_2d<f32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(6) 
var<uniform> rp: RenderParams;
@group(0) @binding(5) 
var out_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(0) 
var l0s: texture_2d<f32>;
@group(0) @binding(1) 
var l0t: texture_2d<f32>;
@group(0) @binding(2) 
var bg: texture_2d<u32>;
@group(0) @binding(3) 
var fl2_: texture_2d<f32>;
@group(2) @binding(3) 
var fl2_smp: sampler;
@group(0) @binding(4) 
var fl3_: texture_2d<f32>;
@group(2) @binding(4) 
var fl3_smp: sampler;
@group(0) @binding(7) 
var day_tex: texture_2d<f32>;
@group(2) @binding(7) 
var day_tex_smp: sampler;

fn inw_u0028_vi2_u003b(c: ptr<function, vec2<i32>>) -> bool {
    var phi_213_: bool;
    var phi_225_: bool;
    var phi_234_: bool;

    let _e58 = (*c)[0u];
    let _e59 = (_e58 >= 0i);
    phi_213_ = _e59;
    if _e59 {
        let _e61 = (*c)[1u];
        phi_213_ = (_e61 >= 0i);
    }
    let _e64 = phi_213_;
    phi_225_ = _e64;
    if _e64 {
        let _e66 = (*c)[0u];
        let _e68 = g_world[0u];
        phi_225_ = (_e66 < i32(_e68));
    }
    let _e72 = phi_225_;
    phi_234_ = _e72;
    if _e72 {
        let _e74 = (*c)[1u];
        let _e76 = g_world[1u];
        phi_234_ = (_e74 < i32(_e76));
    }
    let _e80 = phi_234_;
    return _e80;
}

fn plane_backlight_u0028_vf2_u003b(xy: ptr<function, vec2<f32>>) -> vec3<f32> {
    var c_1: vec2<i32>;
    var param: vec2<i32>;

    let _e59 = (*xy);
    c_1 = vec2<i32>(floor(_e59));
    let _e62 = c_1;
    param = _e62;
    let _e63 = inw_u0028_vi2_u003b((&param));
    if !(_e63) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e65 = c_1;
    let _e66 = textureLoad(backlight, _e65, 0i);
    return _e66.xyz;
}

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e57 = (*x);
    return (f32((_e57 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e57 = (*v);
    (*v) = ((_e57 * vec3(1664525u)) + vec3(1013904223u));
    let _e63 = (*v)[1u];
    let _e65 = (*v)[2u];
    let _e68 = (*v)[0u];
    (*v)[0u] = (_e68 + (_e63 * _e65));
    let _e72 = (*v)[2u];
    let _e74 = (*v)[0u];
    let _e77 = (*v)[1u];
    (*v)[1u] = (_e77 + (_e72 * _e74));
    let _e81 = (*v)[0u];
    let _e83 = (*v)[1u];
    let _e86 = (*v)[2u];
    (*v)[2u] = (_e86 + (_e81 * _e83));
    let _e89 = (*v);
    let _e93 = (*v);
    (*v) = (_e93 ^ (_e89 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e96 = (*v)[1u];
    let _e98 = (*v)[2u];
    let _e101 = (*v)[0u];
    (*v)[0u] = (_e101 + (_e96 * _e98));
    let _e105 = (*v)[2u];
    let _e107 = (*v)[0u];
    let _e110 = (*v)[1u];
    (*v)[1u] = (_e110 + (_e105 * _e107));
    let _e114 = (*v)[0u];
    let _e116 = (*v)[1u];
    let _e119 = (*v)[2u];
    (*v)[2u] = (_e119 + (_e114 * _e116));
    let _e122 = (*v);
    return _e122;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param_1: vec3<u32>;

    let _e58 = (*v_1);
    param_1 = _e58;
    let _e59 = pcg3d_u0028_vu3_u003b((&param_1));
    return _e59.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_2: vec3<u32>;
    var param_3: u32;

    let _e59 = (*p);
    let _e61 = vec2<i32>(floor(_e59));
    param_2 = bitcast<vec3<u32>>(vec3<i32>(_e61.x, _e61.y, 1777i));
    let _e66 = hash1_u0028_vu3_u003b((&param_2));
    param_3 = _e66;
    let _e67 = u01_u0028_u1_u003b((&param_3));
    return _e67;
}

fn vnoise_u0028_vf2_u003b(p_1: ptr<function, vec2<f32>>) -> f32 {
    var i: vec2<f32>;
    var f: vec2<f32>;
    var a: f32;
    var param_4: vec2<f32>;
    var b: f32;
    var param_5: vec2<f32>;
    var c_2: f32;
    var param_6: vec2<f32>;
    var d: f32;
    var param_7: vec2<f32>;

    let _e67 = (*p_1);
    i = floor(_e67);
    let _e69 = (*p_1);
    f = fract(_e69);
    let _e71 = f;
    let _e72 = f;
    let _e74 = f;
    f = ((_e71 * _e72) * (vec2(3f) - (_e74 * 2f)));
    let _e79 = i;
    param_4 = _e79;
    let _e80 = hash21_u0028_vf2_u003b((&param_4));
    a = _e80;
    let _e81 = i;
    param_5 = (_e81 + vec2<f32>(1f, 0f));
    let _e83 = hash21_u0028_vf2_u003b((&param_5));
    b = _e83;
    let _e84 = i;
    param_6 = (_e84 + vec2<f32>(0f, 1f));
    let _e86 = hash21_u0028_vf2_u003b((&param_6));
    c_2 = _e86;
    let _e87 = i;
    param_7 = (_e87 + vec2<f32>(1f, 1f));
    let _e89 = hash21_u0028_vf2_u003b((&param_7));
    d = _e89;
    let _e90 = a;
    let _e91 = b;
    let _e93 = f[0u];
    let _e95 = c_2;
    let _e96 = d;
    let _e98 = f[0u];
    let _e101 = f[1u];
    return mix(mix(_e90, _e91, _e93), mix(_e95, _e96, _e98), _e101);
}

fn main_1() {
    var p_2: vec2<i32>;
    var dens: f32;
    var Tv: f32;
    var L: vec3<f32>;
    var p0_: vec3<f32>;
    var d_1: vec3<f32>;
    var depth: f32;
    var dzs: f32;
    var t: f32;
    var i_1: i32;
    var z: f32;
    var P: vec3<f32>;
    var wisp: f32;
    var param_8: vec2<f32>;
    var sd: f32;
    var rad: f32;
    var Lin: vec3<f32>;
    var param_9: vec2<f32>;
    var k: i32;
    var a_1: f32;
    var param_10: vec2<f32>;

    let _e77 = gl_GlobalInvocationID_1;
    p_2 = bitcast<vec2<i32>>(_e77.xy);
    let _e81 = pc.i0_;
    g_world = vec2<f32>(_e81.xy);
    let _e84 = p_2;
    let _e86 = pc.i0_;
    if any((_e84 >= _e86.xy)) {
        return;
    }
    let _e92 = rp.reserved2_[1u];
    dens = _e92;
    Tv = 1f;
    L = vec3<f32>(0f, 0f, 0f);
    let _e93 = dens;
    if (_e93 > 0f) {
        let _e95 = p_2;
        let _e98 = (vec2<f32>(_e95) + vec2(0.5f));
        p0_ = vec3<f32>(_e98.x, _e98.y, 0f);
        let _e103 = rp.look2_;
        let _e104 = _e103.xy;
        d_1 = normalize(vec3<f32>(_e104.x, _e104.y, 1f));
        let _e111 = rp.view[3u];
        depth = _e111;
        let _e112 = depth;
        dzs = (_e112 / 32f);
        let _e116 = rp.misc[0u];
        t = _e116;
        i_1 = 0i;
        loop {
            let _e117 = i_1;
            if (_e117 < 32i) {
                let _e119 = i_1;
                let _e123 = dzs;
                z = (-((f32(_e119) + 0.5f)) * _e123);
                let _e125 = p0_;
                let _e126 = d_1;
                let _e127 = z;
                let _e129 = d_1[2u];
                P = (_e125 + (_e126 * (_e127 / _e129)));
                let _e133 = P;
                let _e136 = t;
                let _e138 = z;
                let _e141 = t;
                param_8 = ((_e133.xy * 0.045f) + vec2<f32>((_e136 * 0.12f), ((-(_e138) * 0.04f) + (_e141 * 0.035f))));
                let _e146 = vnoise_u0028_vf2_u003b((&param_8));
                wisp = (0.55f + (0.9f * _e146));
                let _e149 = dens;
                let _e150 = wisp;
                let _e152 = dzs;
                sd = ((_e149 * _e150) * _e152);
                let _e154 = z;
                rad = (-(_e154) * 0.7f);
                let _e157 = P;
                param_9 = _e157.xy;
                let _e159 = plane_backlight_u0028_vf2_u003b((&param_9));
                Lin = (_e159 * 0.25f);
                k = 0i;
                loop {
                    let _e161 = k;
                    if (_e161 < 6i) {
                        let _e163 = k;
                        let _e166 = i_1;
                        a_1 = ((f32(_e163) * 1.0471976f) + (f32(_e166) * 0.618f));
                        let _e170 = P;
                        let _e172 = a_1;
                        let _e174 = a_1;
                        let _e177 = rad;
                        param_10 = (_e170.xy + (vec2<f32>(cos(_e172), sin(_e174)) * _e177));
                        let _e180 = plane_backlight_u0028_vf2_u003b((&param_10));
                        let _e182 = Lin;
                        Lin = (_e182 + (_e180 * 0.125f));
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e184 = k;
                        k = (_e184 + 1i);
                    }
                }
                let _e186 = Tv;
                let _e187 = Lin;
                let _e189 = sd;
                let _e191 = i_1;
                let _e196 = L;
                L = (_e196 + (((_e187 * _e186) * _e189) * mix(1f, 0.35f, (f32(_e191) / 32f))));
                let _e198 = sd;
                let _e202 = Tv;
                Tv = (_e202 * exp((-(_e198) * 0.25f)));
                continue;
            } else {
                break;
            }
            continuing {
                let _e204 = i_1;
                i_1 = (_e204 + 1i);
            }
        }
        let _e208 = rp.reserved2_[2u];
        let _e209 = L;
        L = (_e209 * _e208);
    }
    let _e211 = p_2;
    let _e212 = L;
    let _e213 = Tv;
    textureStore(out_img, _e211, vec4<f32>(_e212.x, _e212.y, _e212.z, _e213));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
