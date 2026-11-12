struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var low: texture_2d<f32>;
@group(2) @binding(0) 
var low_smp: sampler;
@group(0) @binding(1) 
var cur: texture_2d<f32>;
@group(2) @binding(1) 
var cur_smp: sampler;
@group(0) @binding(2) 
var dst: texture_storage_2d<rgba16float,write>;

fn main_1() {
    var p: vec2<i32>;
    var uv: vec2<f32>;
    var t: vec2<f32>;
    var s: vec3<f32>;
    var c: vec3<f32>;

    let _e24 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e24.xy);
    let _e27 = p;
    let _e29 = pc.i0_;
    if any((_e27 >= _e29.xy)) {
        return;
    }
    let _e33 = p;
    let _e38 = pc.i0_;
    uv = ((vec2<f32>(_e33) + vec2(0.5f)) / vec2<f32>(_e38.xy));
    let _e44 = pc.f0_[0u];
    let _e45 = textureDimensions(low, 0i);
    t = (vec2(_e44) / vec2<f32>(vec2<i32>(_e45)));
    let _e50 = uv;
    let _e52 = t[0u];
    let _e55 = t[1u];
    let _e59 = textureSampleLevel(low, low_smp, (_e50 + vec2<f32>(-(_e52), -(_e55))), 0f);
    let _e61 = uv;
    let _e63 = t[0u];
    let _e65 = t[1u];
    let _e69 = textureSampleLevel(low, low_smp, (_e61 + vec2<f32>(_e63, -(_e65))), 0f);
    let _e72 = uv;
    let _e74 = t[0u];
    let _e77 = t[1u];
    let _e80 = textureSampleLevel(low, low_smp, (_e72 + vec2<f32>(-(_e74), _e77)), 0f);
    let _e83 = uv;
    let _e85 = t[0u];
    let _e87 = t[1u];
    let _e90 = textureSampleLevel(low, low_smp, (_e83 + vec2<f32>(_e85, _e87)), 0f);
    s = (((_e59.xyz + _e69.xyz) + _e80.xyz) + _e90.xyz);
    let _e93 = uv;
    let _e95 = t[1u];
    let _e99 = textureSampleLevel(low, low_smp, (_e93 + vec2<f32>(0f, -(_e95))), 0f);
    let _e101 = uv;
    let _e103 = t[1u];
    let _e106 = textureSampleLevel(low, low_smp, (_e101 + vec2<f32>(0f, _e103)), 0f);
    let _e109 = uv;
    let _e111 = t[0u];
    let _e115 = textureSampleLevel(low, low_smp, (_e109 + vec2<f32>(-(_e111), 0f)), 0f);
    let _e118 = uv;
    let _e120 = t[0u];
    let _e123 = textureSampleLevel(low, low_smp, (_e118 + vec2<f32>(_e120, 0f)), 0f);
    let _e127 = s;
    s = (_e127 + ((((_e99.xyz + _e106.xyz) + _e115.xyz) + _e123.xyz) * 2f));
    let _e129 = uv;
    let _e130 = textureSampleLevel(low, low_smp, _e129, 0f);
    let _e133 = s;
    s = (_e133 + (_e130.xyz * 4f));
    let _e135 = s;
    s = (_e135 / vec3(16f));
    let _e138 = uv;
    let _e139 = textureSampleLevel(cur, cur_smp, _e138, 0f);
    let _e141 = s;
    let _e144 = pc.f0_[1u];
    c = (_e139.xyz + (_e141 * _e144));
    let _e147 = p;
    let _e148 = c;
    textureStore(dst, _e147, vec4<f32>(_e148.x, _e148.y, _e148.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
