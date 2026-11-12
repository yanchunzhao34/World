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

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(4) 
var<uniform> rp: RenderParams;
@group(0) @binding(3) 
var out_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(0) 
var rcsrc: texture_2d<f32>;
@group(2) @binding(0) 
var rcsrc_smp: sampler;
@group(0) @binding(1) 
var bg: texture_2d<u32>;
@group(0) @binding(2) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(2) 
var medium_tex_smp: sampler;

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e41 = (*x);
    return (f32((_e41 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e41 = (*v);
    (*v) = ((_e41 * vec3(1664525u)) + vec3(1013904223u));
    let _e47 = (*v)[1u];
    let _e49 = (*v)[2u];
    let _e52 = (*v)[0u];
    (*v)[0u] = (_e52 + (_e47 * _e49));
    let _e56 = (*v)[2u];
    let _e58 = (*v)[0u];
    let _e61 = (*v)[1u];
    (*v)[1u] = (_e61 + (_e56 * _e58));
    let _e65 = (*v)[0u];
    let _e67 = (*v)[1u];
    let _e70 = (*v)[2u];
    (*v)[2u] = (_e70 + (_e65 * _e67));
    let _e73 = (*v);
    let _e77 = (*v);
    (*v) = (_e77 ^ (_e73 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e80 = (*v)[1u];
    let _e82 = (*v)[2u];
    let _e85 = (*v)[0u];
    (*v)[0u] = (_e85 + (_e80 * _e82));
    let _e89 = (*v)[2u];
    let _e91 = (*v)[0u];
    let _e94 = (*v)[1u];
    (*v)[1u] = (_e94 + (_e89 * _e91));
    let _e98 = (*v)[0u];
    let _e100 = (*v)[1u];
    let _e103 = (*v)[2u];
    (*v)[2u] = (_e103 + (_e98 * _e100));
    let _e106 = (*v);
    return _e106;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param: vec3<u32>;

    let _e42 = (*v_1);
    param = _e42;
    let _e43 = pcg3d_u0028_vu3_u003b((&param));
    return _e43.x;
}

fn main_1() {
    var p: vec2<i32>;
    var world: vec2<f32>;
    var pos: vec2<f32>;
    var dir: vec2<f32>;
    var jitter: f32;
    var param_1: vec3<u32>;
    var param_2: u32;
    var stepLen: f32;
    var sum: f32;
    var w: f32;
    var q: vec2<f32>;
    var i: i32;
    var sig: f32;
    var md: vec4<f32>;
    var fog: f32;
    var c: vec3<f32>;
    var phi_171_: bool;
    var phi_254_: bool;
    var phi_263_: bool;

    let _e56 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e56.xy);
    let _e59 = p;
    let _e61 = pc.i0_;
    if any((_e59 >= _e61.xy)) {
        return;
    }
    let _e66 = pc.i1_;
    world = vec2<f32>(_e66.xy);
    let _e69 = p;
    pos = ((vec2<f32>(_e69) + vec2(0.5f)) * 2f);
    let _e76 = rp.bloom[3u];
    let _e77 = (_e76 <= 0f);
    phi_171_ = _e77;
    if !(_e77) {
        let _e81 = rp.sun[3u];
        phi_171_ = (_e81 <= 0f);
    }
    let _e84 = phi_171_;
    if _e84 {
        let _e85 = p;
        textureStore(out_img, _e85, vec4<f32>(0f, 0f, 0f, 0f));
        return;
    }
    let _e87 = rp.sun;
    dir = normalize(_e87.xy);
    let _e90 = p;
    let _e91 = bitcast<vec2<u32>>(_e90);
    let _e94 = rp.misc[0u];
    param_1 = vec3<u32>(_e91.x, _e91.y, u32((_e94 * 60f)));
    let _e100 = hash1_u0028_vu3_u003b((&param_1));
    param_2 = _e100;
    let _e101 = u01_u0028_u1_u003b((&param_2));
    jitter = _e101;
    stepLen = 3f;
    sum = 0f;
    w = 1f;
    let _e102 = pos;
    let _e103 = dir;
    let _e104 = stepLen;
    let _e106 = jitter;
    q = (_e102 + ((_e103 * _e104) * _e106));
    i = 0i;
    loop {
        let _e109 = i;
        if (_e109 < 48i) {
            let _e111 = dir;
            let _e112 = stepLen;
            let _e114 = q;
            q = (_e114 + (_e111 * _e112));
            let _e117 = q[1u];
            if (_e117 < 0f) {
                let _e119 = w;
                let _e121 = sum;
                sum = (_e121 + (_e119 * 1.5f));
                break;
            }
            let _e124 = q[0u];
            let _e125 = (_e124 < 0f);
            phi_254_ = _e125;
            if !(_e125) {
                let _e128 = q[0u];
                let _e130 = world[0u];
                phi_254_ = (_e128 >= _e130);
            }
            let _e133 = phi_254_;
            phi_263_ = _e133;
            if !(_e133) {
                let _e136 = q[1u];
                let _e138 = world[1u];
                phi_263_ = (_e136 >= _e138);
            }
            let _e141 = phi_263_;
            if _e141 {
                break;
            }
            let _e142 = q;
            let _e143 = world;
            let _e145 = textureSampleLevel(rcsrc, rcsrc_smp, (_e142 / _e143), 0f);
            sig = _e145.w;
            let _e147 = sig;
            if (_e147 > 4f) {
                break;
            }
            let _e149 = q;
            let _e151 = textureLoad(bg, vec2<i32>(_e149), 0i);
            if (_e151.x == 0u) {
                let _e154 = w;
                let _e156 = sum;
                sum = (_e156 + (_e154 * 0.06f));
            }
            let _e158 = sig;
            let _e160 = stepLen;
            let _e165 = w;
            w = (_e165 * (0.97f * exp(((-(_e158) * _e160) * 0.5f))));
            continue;
        } else {
            break;
        }
        continuing {
            let _e167 = i;
            i = (_e167 + 1i);
        }
    }
    let _e169 = pos;
    let _e170 = world;
    let _e172 = textureSampleLevel(medium_tex, medium_tex_smp, (_e169 / _e170), 0f);
    md = _e172;
    let _e174 = md[0u];
    let _e178 = md[1u];
    fog = ((0.08f + (_e174 * 0.5f)) + (_e178 * 1.2f));
    let _e182 = rp.sun_color;
    let _e184 = sum;
    let _e186 = fog;
    c = (((_e182.xyz * _e184) * _e186) * 0.25f);
    let _e189 = p;
    let _e190 = c;
    textureStore(out_img, _e189, vec4<f32>(_e190.x, _e190.y, _e190.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
