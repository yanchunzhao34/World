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
var src: texture_2d<f32>;
@group(0) @binding(1) 
var dst: texture_storage_2d<rgba16float,write>;

fn main_1() {
    var p: vec2<i32>;
    var s: vec2<i32>;
    var c: vec4<f32>;

    let _e17 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e17.xy);
    let _e20 = p;
    let _e22 = pc.i0_;
    if any((_e20 >= _e22.xy)) {
        return;
    }
    let _e26 = p;
    s = (_e26 * vec2(2i));
    let _e29 = s;
    let _e30 = textureLoad(src, _e29, 0i);
    let _e31 = s;
    let _e33 = textureLoad(src, (_e31 + vec2<i32>(1i, 0i)), 0i);
    let _e35 = s;
    let _e37 = textureLoad(src, (_e35 + vec2<i32>(0i, 1i)), 0i);
    let _e39 = s;
    let _e41 = textureLoad(src, (_e39 + vec2<i32>(1i, 1i)), 0i);
    c = (((_e30 + _e33) + _e37) + _e41);
    let _e43 = p;
    let _e44 = c;
    textureStore(dst, _e43, (_e44 * 0.25f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
