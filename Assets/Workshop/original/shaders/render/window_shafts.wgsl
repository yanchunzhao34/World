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

struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

@group(0) @binding(2) 
var<uniform> rp: RenderParams;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var bgsm_tex: texture_2d<f32>;
@group(2) @binding(0) 
var bgsm_tex_smp: sampler;
@group(0) @binding(1) 
var out_img: texture_storage_2d<rgba16float,write>;

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e45 = (*x);
    return (f32((_e45 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e45 = (*v);
    (*v) = ((_e45 * vec3(1664525u)) + vec3(1013904223u));
    let _e51 = (*v)[1u];
    let _e53 = (*v)[2u];
    let _e56 = (*v)[0u];
    (*v)[0u] = (_e56 + (_e51 * _e53));
    let _e60 = (*v)[2u];
    let _e62 = (*v)[0u];
    let _e65 = (*v)[1u];
    (*v)[1u] = (_e65 + (_e60 * _e62));
    let _e69 = (*v)[0u];
    let _e71 = (*v)[1u];
    let _e74 = (*v)[2u];
    (*v)[2u] = (_e74 + (_e69 * _e71));
    let _e77 = (*v);
    let _e81 = (*v);
    (*v) = (_e81 ^ (_e77 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e84 = (*v)[1u];
    let _e86 = (*v)[2u];
    let _e89 = (*v)[0u];
    (*v)[0u] = (_e89 + (_e84 * _e86));
    let _e93 = (*v)[2u];
    let _e95 = (*v)[0u];
    let _e98 = (*v)[1u];
    (*v)[1u] = (_e98 + (_e93 * _e95));
    let _e102 = (*v)[0u];
    let _e104 = (*v)[1u];
    let _e107 = (*v)[2u];
    (*v)[2u] = (_e107 + (_e102 * _e104));
    let _e110 = (*v);
    return _e110;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param: vec3<u32>;

    let _e46 = (*v_1);
    param = _e46;
    let _e47 = pcg3d_u0028_vu3_u003b((&param));
    return _e47.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_1: vec3<u32>;
    var param_2: u32;

    let _e47 = (*p);
    let _e49 = vec2<i32>(floor(_e47));
    param_1 = bitcast<vec3<u32>>(vec3<i32>(_e49.x, _e49.y, 1777i));
    let _e54 = hash1_u0028_vu3_u003b((&param_1));
    param_2 = _e54;
    let _e55 = u01_u0028_u1_u003b((&param_2));
    return _e55;
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

    let _e55 = (*p_1);
    i = floor(_e55);
    let _e57 = (*p_1);
    f = fract(_e57);
    let _e59 = f;
    let _e60 = f;
    let _e62 = f;
    f = ((_e59 * _e60) * (vec2(3f) - (_e62 * 2f)));
    let _e67 = i;
    param_3 = _e67;
    let _e68 = hash21_u0028_vf2_u003b((&param_3));
    a = _e68;
    let _e69 = i;
    param_4 = (_e69 + vec2<f32>(1f, 0f));
    let _e71 = hash21_u0028_vf2_u003b((&param_4));
    b = _e71;
    let _e72 = i;
    param_5 = (_e72 + vec2<f32>(0f, 1f));
    let _e74 = hash21_u0028_vf2_u003b((&param_5));
    c = _e74;
    let _e75 = i;
    param_6 = (_e75 + vec2<f32>(1f, 1f));
    let _e77 = hash21_u0028_vf2_u003b((&param_6));
    d = _e77;
    let _e78 = a;
    let _e79 = b;
    let _e81 = f[0u];
    let _e83 = c;
    let _e84 = d;
    let _e86 = f[0u];
    let _e89 = f[1u];
    return mix(mix(_e78, _e79, _e81), mix(_e83, _e84, _e86), _e89);
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
        let _e49 = i_1;
        if (_e49 < 4i) {
            let _e51 = a_1;
            let _e52 = (*p_2);
            param_7 = _e52;
            let _e53 = vnoise_u0028_vf2_u003b((&param_7));
            let _e55 = s;
            s = (_e55 + (_e51 * _e53));
            let _e57 = (*p_2);
            (*p_2) = (_e57 * 2.03f);
            let _e59 = a_1;
            a_1 = (_e59 * 0.5f);
            continue;
        } else {
            break;
        }
        continuing {
            let _e61 = i_1;
            i_1 = (_e61 + 1i);
        }
    }
    let _e63 = s;
    return _e63;
}

fn sky_color_u0028_vf2_u003b(pos: ptr<function, vec2<f32>>) -> vec3<f32> {
    var h: f32;
    var s_1: vec3<f32>;
    var cl: f32;
    var param_8: vec2<f32>;

    let _e50 = (*pos)[1u];
    let _e53 = rp.misc[3u];
    h = clamp((_e50 / _e53), 0f, 1f);
    let _e57 = rp.sky_top;
    let _e60 = rp.sky_horizon;
    let _e62 = h;
    s_1 = (mix(_e57.xyz, _e60.xyz, vec3(pow(_e62, 0.8f))) * 0.55f);
    let _e68 = (*pos)[0u];
    let _e72 = rp.misc[0u];
    let _e76 = (*pos)[1u];
    param_8 = vec2<f32>(((_e68 * 0.016f) + (_e72 * 0.01f)), (_e76 * 0.04f));
    let _e79 = fbm_u0028_vf2_u003b((&param_8));
    cl = smoothstep(0.55f, 0.85f, _e79);
    let _e81 = s_1;
    let _e83 = rp.sky_horizon;
    let _e87 = rp.sun_color;
    let _e91 = cl;
    let _e93 = h;
    s_1 = mix(_e81, ((_e83.xyz * 0.75f) + (_e87.xyz * 0.15f)), vec3(((_e91 * 0.5f) * (1f - _e93))));
    let _e98 = s_1;
    return _e98;
}

fn main_1() {
    var p_3: vec2<i32>;
    var n: vec2<i32>;
    var pos_1: vec2<f32>;
    var dir: vec2<f32>;
    var len: f32;
    var acc: f32;
    var t: i32;
    var s_2: f32;
    var q: vec2<f32>;
    var m: f32;
    var src: vec2<f32>;
    var param_9: vec2<f32>;

    let _e56 = gl_GlobalInvocationID_1;
    p_3 = bitcast<vec2<i32>>(_e56.xy);
    let _e60 = pc.i0_;
    n = _e60.xy;
    let _e62 = p_3;
    let _e63 = n;
    if any((_e62 >= _e63)) {
        return;
    }
    let _e66 = p_3;
    pos_1 = (vec2<f32>(_e66) + vec2(0.5f));
    let _e71 = pc.f0_;
    dir = _e71.xy;
    let _e75 = pc.f0_[2u];
    len = _e75;
    acc = 0f;
    t = 0i;
    loop {
        let _e76 = t;
        if (_e76 < 128i) {
            let _e78 = t;
            s_2 = f32(_e78);
            let _e80 = s_2;
            let _e81 = len;
            if (_e80 > (_e81 * 1.6f)) {
                break;
            }
            let _e84 = pos_1;
            let _e85 = dir;
            let _e86 = s_2;
            q = (_e84 - (_e85 * _e86));
            let _e90 = q[1u];
            if (_e90 < 0f) {
                break;
            }
            let _e92 = q;
            let _e93 = n;
            let _e96 = textureSampleLevel(bgsm_tex, bgsm_tex_smp, (_e92 / vec2<f32>(_e93)), 0f);
            m = _e96.z;
            let _e98 = m;
            let _e99 = s_2;
            let _e102 = s_2;
            let _e104 = len;
            let _e108 = acc;
            acc = (_e108 + ((_e98 * smoothstep(0f, 6f, _e99)) * exp((-(_e102) / _e104))));
            continue;
        } else {
            break;
        }
        continuing {
            let _e110 = t;
            t = (_e110 + 1i);
        }
    }
    let _e112 = pos_1;
    let _e113 = dir;
    let _e114 = len;
    src = (_e112 - ((_e113 * _e114) * 0.6f));
    let _e118 = p_3;
    let _e120 = src[0u];
    let _e122 = src[1u];
    param_9 = vec2<f32>(_e120, (_e122 * 0.5f));
    let _e125 = sky_color_u0028_vf2_u003b((&param_9));
    let _e126 = acc;
    let _e127 = len;
    let _e129 = (_e125 * (_e126 / _e127));
    textureStore(out_img, _e118, vec4<f32>(_e129.x, _e129.y, _e129.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
