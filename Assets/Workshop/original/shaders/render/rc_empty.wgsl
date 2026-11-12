struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Mask {
    mask: array<u32>,
}

struct Mask_1 {
    mask: array<atomic<u32>>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> sh_any: atomic<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var src: texture_2d<f32>;
@group(0) @binding(1) 
var ext: texture_2d<f32>;
@group(0) @binding(2) 
var gloss: texture_2d<f32>;
@group(0) @binding(3) 
var<storage, read_write> unnamed: Mask_1;

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var p: vec2<i32>;
    var li: u32;
    var any_: bool;
    var off: vec2<i32>;
    var r: i32;
    var nb: vec2<i32>;
    var idx: u32;
    var m: i32;
    var phi_75_: bool;
    var phi_86_: bool;
    var phi_142_: bool;

    let _e35 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e35.xy);
    let _e38 = gl_LocalInvocationIndex_1;
    li = _e38;
    let _e39 = li;
    if (_e39 == 0u) {
        atomicStore((&sh_any), 0u);
    }
    workgroupBarrier();
    let _e41 = p;
    let _e43 = pc.i0_;
    if all((_e41 < _e43.xy)) {
        let _e47 = p;
        let _e48 = textureLoad(src, _e47, 0i);
        let _e50 = (_e48.w != 0f);
        phi_75_ = _e50;
        if !(_e50) {
            let _e52 = p;
            let _e53 = textureLoad(ext, _e52, 0i);
            phi_75_ = any((_e53.xyz != vec3<f32>(0f, 0f, 0f)));
        }
        let _e58 = phi_75_;
        phi_86_ = _e58;
        if !(_e58) {
            let _e60 = p;
            let _e61 = textureLoad(gloss, _e60, 0i);
            phi_86_ = any((_e61.xyz != vec3<f32>(0f, 0f, 0f)));
        }
        let _e66 = phi_86_;
        any_ = _e66;
        let _e67 = any_;
        if _e67 {
            let _e68 = atomicOr((&sh_any), 1u);
        }
    }
    workgroupBarrier();
    let _e69 = atomicLoad((&sh_any));
    let _e71 = li;
    if ((_e69 == 0u) || (_e71 >= 49u)) {
        return;
    }
    let _e74 = li;
    let _e78 = li;
    off = vec2<i32>((bitcast<i32>((_e74 % 7u)) - 3i), (bitcast<i32>((_e78 / 7u)) - 3i));
    let _e84 = off[0u];
    let _e87 = off[1u];
    r = max(abs(_e84), abs(_e87));
    let _e90 = gl_WorkGroupID_1;
    let _e93 = off;
    nb = (bitcast<vec2<i32>>(_e90.xy) + _e93);
    let _e95 = nb;
    let _e97 = any((_e95 < vec2<i32>(0i, 0i)));
    phi_142_ = _e97;
    if !(_e97) {
        let _e99 = nb;
        let _e101 = pc.i0_;
        phi_142_ = any((_e99 >= _e101.zw));
    }
    let _e106 = phi_142_;
    if _e106 {
        return;
    }
    let _e108 = nb[1u];
    let _e111 = pc.i0_[2u];
    let _e114 = nb[0u];
    idx = bitcast<u32>(((_e108 * _e111) + _e114));
    let _e117 = r;
    m = (max(_e117, 1i) - 1i);
    loop {
        let _e120 = m;
        if (_e120 < 3i) {
            let _e122 = m;
            let _e125 = idx;
            let _e131 = idx;
            let _e135 = atomicOr((&unnamed.mask[(bitcast<u32>((_e122 * 128i)) + (_e125 >> bitcast<u32>(5u)))]), (1u << bitcast<u32>((_e131 & 31u))));
            continue;
        } else {
            break;
        }
        continuing {
            let _e136 = m;
            m = (_e136 + 1i);
        }
    }
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(local_invocation_index) gl_LocalInvocationIndex: u32, @builtin(workgroup_id) gl_WorkGroupID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1(gl_WorkGroupID);
}
