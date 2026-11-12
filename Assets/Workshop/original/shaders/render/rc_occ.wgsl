struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Occ {
    occ: array<u32>,
}

struct Occ_1 {
    occ: array<atomic<u32>>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> sh_bits: atomic<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var src: texture_2d<f32>;
@group(0) @binding(1) 
var ext: texture_2d<f32>;
@group(0) @binding(2) 
var gloss: texture_2d<f32>;
@group(0) @binding(3) 
var<storage, read_write> unnamed: Occ_1;

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var p: vec2<i32>;
    var li: u32;
    var b: u32;
    var bits: u32;
    var nb: vec2<i32>;
    var idx: u32;
    var plane: u32;
    var phi_131_: bool;

    let _e35 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e35.xy);
    let _e38 = gl_LocalInvocationIndex_1;
    li = _e38;
    let _e39 = li;
    if (_e39 == 0u) {
        atomicStore((&sh_bits), 0u);
    }
    workgroupBarrier();
    let _e41 = p;
    let _e43 = pc.i0_;
    if all((_e41 < _e43.xy)) {
        let _e47 = p;
        let _e48 = textureLoad(src, _e47, 0i);
        let _e52 = p;
        let _e53 = textureLoad(ext, _e52, 0i);
        let _e59 = p;
        let _e60 = textureLoad(gloss, _e59, 0i);
        b = ((select(0u, 1u, any((_e48 != vec4<f32>(0f, 0f, 0f, 0f)))) | select(0u, 2u, any((_e53.xyz != vec3<f32>(0f, 0f, 0f))))) | select(0u, 4u, any((_e60.xyz != vec3<f32>(0f, 0f, 0f)))));
        let _e66 = b;
        if (_e66 != 0u) {
            let _e68 = b;
            let _e69 = atomicOr((&sh_bits), _e68);
        }
    }
    workgroupBarrier();
    let _e70 = atomicLoad((&sh_bits));
    bits = _e70;
    let _e71 = li;
    let _e73 = bits;
    if ((_e71 < 9u) && (_e73 != 0u)) {
        let _e76 = gl_WorkGroupID_1;
        let _e79 = li;
        let _e83 = li;
        nb = (bitcast<vec2<i32>>(_e76.xy) + vec2<i32>((bitcast<i32>((_e79 % 3u)) - 1i), (bitcast<i32>((_e83 / 3u)) - 1i)));
        let _e89 = nb;
        let _e91 = all((_e89 >= vec2<i32>(0i, 0i)));
        phi_131_ = _e91;
        if _e91 {
            let _e92 = nb;
            let _e94 = pc.i0_;
            phi_131_ = all((_e92 < _e94.zw));
        }
        let _e99 = phi_131_;
        if _e99 {
            let _e101 = nb[1u];
            let _e104 = pc.i0_[2u];
            let _e107 = nb[0u];
            idx = bitcast<u32>(((_e101 * _e104) + _e107));
            plane = 0u;
            loop {
                let _e110 = plane;
                if (_e110 < 3u) {
                    let _e112 = bits;
                    let _e113 = plane;
                    if ((_e112 & (1u << bitcast<u32>(_e113))) != 0u) {
                        let _e118 = plane;
                        let _e120 = idx;
                        let _e126 = idx;
                        let _e130 = atomicOr((&unnamed.occ[((_e118 * 128u) + (_e120 >> bitcast<u32>(5u)))]), (1u << bitcast<u32>((_e126 & 31u))));
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e131 = plane;
                    plane = (_e131 + bitcast<u32>(1i));
                }
            }
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
