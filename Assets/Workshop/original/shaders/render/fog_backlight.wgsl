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
var l0s: texture_2d<f32>;
@group(0) @binding(1) 
var l0t: texture_2d<f32>;
@group(0) @binding(2) 
var fl2_: texture_2d<f32>;
@group(2) @binding(2) 
var fl2_smp: sampler;
@group(0) @binding(3) 
var fl3_: texture_2d<f32>;
@group(2) @binding(3) 
var fl3_smp: sampler;
@group(0) @binding(4) 
var day_tex: texture_2d<f32>;
@group(2) @binding(4) 
var day_tex_smp: sampler;
@group(0) @binding(5) 
var out_img: texture_storage_2d<rgba16float,write>;

fn luminance_u0028_vf3_u003b(c: ptr<function, vec3<f32>>) -> f32 {
    let _e29 = (*c);
    return dot(_e29, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn main_1() {
    var c_1: vec2<i32>;
    var s: vec4<f32>;
    var through: vec3<f32>;
    var tr: vec4<f32>;
    var uv: vec2<f32>;
    var behind: vec3<f32>;
    var own: vec3<f32>;
    var param: vec3<f32>;

    let _e36 = gl_GlobalInvocationID_1;
    c_1 = bitcast<vec2<i32>>(_e36.xy);
    let _e39 = c_1;
    let _e41 = pc.i0_;
    if any((_e39 >= _e41.xy)) {
        return;
    }
    let _e45 = c_1;
    let _e46 = textureLoad(l0s, _e45, 0i);
    s = _e46;
    through = vec3<f32>(0f, 0f, 0f);
    let _e48 = s[3u];
    if (_e48 < 0.99f) {
        let _e50 = c_1;
        let _e51 = textureLoad(l0t, _e50, 0i);
        tr = _e51;
        let _e52 = c_1;
        let _e57 = pc.i0_;
        uv = ((vec2<f32>(_e52) + vec2(0.5f)) / vec2<f32>(_e57.xy));
        let _e61 = uv;
        let _e62 = textureSampleLevel(fl2_, fl2_smp, _e61, 0f);
        let _e64 = uv;
        let _e65 = textureSampleLevel(fl3_, fl3_smp, _e64, 0f);
        behind = (mix(_e62.xyz, _e65.xyz, vec3(0.32f)) * 0.6f);
        let _e70 = uv;
        let _e71 = textureSampleLevel(day_tex, day_tex_smp, _e70, 0f);
        let _e74 = behind;
        behind = (_e74 + (_e71.xyz * 0.5f));
        let _e76 = behind;
        let _e77 = tr;
        through = (_e76 * _e77.xyz);
    }
    let _e80 = s;
    let _e82 = s;
    param = _e82.xyz;
    let _e84 = luminance_u0028_vf3_u003b((&param));
    own = ((_e80.xyz * smoothstep(0.6f, 3f, _e84)) * 0.8f);
    let _e88 = c_1;
    let _e89 = through;
    let _e90 = own;
    let _e91 = (_e89 + _e90);
    textureStore(out_img, _e88, vec4<f32>(_e91.x, _e91.y, _e91.z, 0f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
