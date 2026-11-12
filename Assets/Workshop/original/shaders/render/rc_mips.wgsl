struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(2) 
var ext_src: texture_2d<f32>;
@group(0) @binding(0) 
var src: texture_2d<f32>;
@group(0) @binding(1) 
var dst: texture_storage_2d<rgba16float,write>;
@group(0) @binding(3) 
var ext_dst: texture_storage_2d<rgba16float,write>;

fn main_1() {
    var p: vec2<i32>;
    var rad: vec3<f32>;
    var ext: vec3<f32>;
    var wsum: f32;
    var sig: f32;
    var y: i32;
    var x: i32;
    var s: vec4<f32>;
    var w: f32;
    var local: vec3<f32>;

    let _e27 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e27.xy);
    let _e30 = p;
    let _e32 = pc.i0_;
    if any((_e30 >= _e32.xy)) {
        return;
    }
    rad = vec3<f32>(0f, 0f, 0f);
    ext = vec3<f32>(0f, 0f, 0f);
    wsum = 0f;
    sig = 0f;
    y = 0i;
    loop {
        let _e36 = y;
        if (_e36 < 2i) {
            x = 0i;
            loop {
                let _e38 = x;
                if (_e38 < 2i) {
                    let _e40 = p;
                    let _e43 = x;
                    let _e44 = y;
                    let _e47 = textureLoad(ext_src, ((_e40 * vec2(2i)) + vec2<i32>(_e43, _e44)), 0i);
                    let _e49 = ext;
                    ext = (_e49 + _e47.xyz);
                    let _e51 = p;
                    let _e54 = x;
                    let _e55 = y;
                    let _e58 = textureLoad(src, ((_e51 * vec2(2i)) + vec2<i32>(_e54, _e55)), 0i);
                    s = _e58;
                    let _e60 = s[3u];
                    w = (1f - exp(-(_e60)));
                    let _e64 = s;
                    let _e66 = w;
                    let _e68 = rad;
                    rad = (_e68 + (_e64.xyz * _e66));
                    let _e70 = w;
                    let _e71 = wsum;
                    wsum = (_e71 + _e70);
                    let _e74 = s[3u];
                    let _e75 = sig;
                    sig = (_e75 + _e74);
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e77 = x;
                    x = (_e77 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e79 = y;
            y = (_e79 + 1i);
        }
    }
    let _e81 = p;
    let _e82 = wsum;
    if (_e82 > 0f) {
        let _e84 = rad;
        let _e85 = wsum;
        local = (_e84 / vec3(_e85));
    } else {
        local = vec3<f32>(0f, 0f, 0f);
    }
    let _e88 = local;
    let _e89 = sig;
    textureStore(dst, _e81, vec4<f32>(_e88.x, _e88.y, _e88.z, (_e89 * 0.25f)));
    let _e95 = p;
    let _e96 = ext;
    let _e97 = (_e96 * 0.25f);
    textureStore(ext_dst, _e95, vec4<f32>(_e97.x, _e97.y, _e97.z, 0f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
