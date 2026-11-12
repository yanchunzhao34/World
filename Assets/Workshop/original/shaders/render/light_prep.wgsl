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
var<workgroup> sh_any: atomic<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var gloss: texture_2d<f32>;
@group(0) @binding(2) 
var albedo_img: texture_2d<f32>;
@group(0) @binding(3) 
var emissive_img: texture_2d<f32>;
@group(0) @binding(5) 
var cells: texture_2d<u32>;
@group(0) @binding(6) 
var day_cells: texture_storage_2d<rgba32uint,write>;
@group(0) @binding(4) 
var bg: texture_2d<u32>;
@group(0) @binding(1) 
var<storage, read_write> unnamed: Occ_1;

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var p: vec2<i32>;
    var li: u32;
    var alb: vec4<f32>;
    var st: u32;
    var c: vec4<u32>;
    var nb: vec2<i32>;
    var idx: u32;
    var phi_134_: bool;
    var phi_165_: bool;

    let _e40 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e40.xy);
    let _e43 = gl_LocalInvocationIndex_1;
    li = _e43;
    let _e44 = li;
    if (_e44 == 0u) {
        atomicStore((&sh_any), 0u);
    }
    workgroupBarrier();
    let _e46 = p;
    let _e48 = pc.i0_;
    if all((_e46 < _e48.xy)) {
        let _e52 = p;
        let _e53 = textureLoad(gloss, _e52, 0i);
        if any((_e53.xyz != vec3<f32>(0f, 0f, 0f))) {
            let _e57 = atomicOr((&sh_any), 1u);
        }
        let _e58 = p;
        let _e59 = textureLoad(albedo_img, _e58, 0i);
        alb = _e59;
        let _e60 = p;
        let _e61 = textureLoad(emissive_img, _e60, 0i);
        st = u32((_e61.w + 0.5f));
        let _e65 = p;
        let _e66 = textureLoad(cells, _e65, 0i);
        c = _e66;
        let _e67 = p;
        let _e68 = alb;
        let _e71 = alb;
        let _e74 = st;
        let _e75 = p;
        let _e76 = textureLoad(bg, _e75, 0i);
        let _e82 = c[0u];
        let _e88 = c[3u];
        textureStore(day_cells, _e67, vec4<u32>(pack2x16float(_e68.xy), pack2x16float(_e71.zw), (((_e74 | (_e76.x << bitcast<u32>(8i))) | ((_e82 & 255u) << bitcast<u32>(16i))) | ((_e88 & 255u) << bitcast<u32>(24i))), 0u));
    }
    workgroupBarrier();
    let _e94 = li;
    let _e95 = (_e94 < 9u);
    phi_134_ = _e95;
    if _e95 {
        let _e96 = atomicLoad((&sh_any));
        phi_134_ = (_e96 != 0u);
    }
    let _e99 = phi_134_;
    if _e99 {
        let _e100 = gl_WorkGroupID_1;
        let _e103 = li;
        let _e107 = li;
        nb = (bitcast<vec2<i32>>(_e100.xy) + vec2<i32>((bitcast<i32>((_e103 % 3u)) - 1i), (bitcast<i32>((_e107 / 3u)) - 1i)));
        let _e113 = nb;
        let _e115 = all((_e113 >= vec2<i32>(0i, 0i)));
        phi_165_ = _e115;
        if _e115 {
            let _e116 = nb;
            let _e118 = pc.i0_;
            phi_165_ = all((_e116 < _e118.zw));
        }
        let _e123 = phi_165_;
        if _e123 {
            let _e125 = nb[1u];
            let _e128 = pc.i0_[2u];
            let _e131 = nb[0u];
            idx = bitcast<u32>(((_e125 * _e128) + _e131));
            let _e134 = idx;
            let _e139 = idx;
            let _e143 = atomicOr((&unnamed.occ[(_e134 >> bitcast<u32>(5u))]), (1u << bitcast<u32>((_e139 & 31u))));
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
