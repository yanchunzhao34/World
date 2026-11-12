struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(0) 
var src: texture_2d<f32>;
@group(2) @binding(0) 
var src_smp: sampler;
@group(0) @binding(1) 
var dst: texture_storage_2d<rgba16float,write>;

fn coc_u0028_f1_u003b(z: ptr<function, f32>) -> f32 {
    let _e25 = pc.f0_[0u];
    let _e28 = pc.f0_[1u];
    let _e31 = pc.f0_[2u];
    let _e32 = (*z);
    return (_e25 * smoothstep(_e28, _e31, _e32));
}

fn main_1() {
    var p: vec2<i32>;
    var n: vec2<i32>;
    var texel: vec2<f32>;
    var uv: vec2<f32>;
    var c: vec4<f32>;
    var r: f32;
    var param: f32;
    var acc: vec3<f32>;
    var wsum: f32;
    var i: i32;
    var rr: f32;
    var a: f32;
    var s: vec4<f32>;
    var w: f32;

    let _e36 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e36.xy);
    let _e40 = pc.i0_;
    n = _e40.xy;
    let _e42 = p;
    let _e43 = n;
    if any((_e42 >= _e43)) {
        return;
    }
    let _e46 = n;
    texel = (vec2(1f) / vec2<f32>(_e46));
    let _e50 = p;
    let _e54 = texel;
    uv = ((vec2<f32>(_e50) + vec2(0.5f)) * _e54);
    let _e56 = uv;
    let _e57 = textureSampleLevel(src, src_smp, _e56, 0f);
    c = _e57;
    let _e59 = c[3u];
    param = _e59;
    let _e60 = coc_u0028_f1_u003b((&param));
    r = _e60;
    let _e61 = r;
    if (_e61 < 0.35f) {
        let _e63 = p;
        let _e64 = c;
        textureStore(dst, _e63, _e64);
        return;
    }
    let _e65 = c;
    acc = _e65.xyz;
    wsum = 1f;
    i = 1i;
    loop {
        let _e67 = i;
        if (_e67 < 16i) {
            let _e69 = i;
            let _e73 = r;
            rr = (sqrt((f32(_e69) / 15f)) * _e73);
            let _e75 = i;
            a = (f32(_e75) * 2.3999631f);
            let _e78 = uv;
            let _e79 = a;
            let _e81 = a;
            let _e84 = rr;
            let _e86 = texel;
            let _e89 = textureSampleLevel(src, src_smp, (_e78 + ((vec2<f32>(cos(_e79), sin(_e81)) * _e84) * _e86)), 0f);
            s = _e89;
            let _e91 = c[3u];
            let _e94 = c[3u];
            let _e97 = s[3u];
            w = smoothstep((_e91 - 6f), (_e94 - 1f), _e97);
            let _e99 = s;
            let _e101 = w;
            let _e103 = acc;
            acc = (_e103 + (_e99.xyz * _e101));
            let _e105 = w;
            let _e106 = wsum;
            wsum = (_e106 + _e105);
            continue;
        } else {
            break;
        }
        continuing {
            let _e108 = i;
            i = (_e108 + 1i);
        }
    }
    let _e110 = p;
    let _e111 = acc;
    let _e112 = wsum;
    let _e114 = (_e111 / vec3(_e112));
    let _e116 = c[3u];
    textureStore(dst, _e110, vec4<f32>(_e114.x, _e114.y, _e114.z, _e116));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
