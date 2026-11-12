struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Material {
    color_a: vec4<f32>,
    color_b: vec4<f32>,
    emission: vec4<f32>,
    phys: vec4<f32>,
    thermo: vec4<f32>,
    burn: vec4<f32>,
    optics: vec4<f32>,
    scatter: vec4<f32>,
    ids: vec4<u32>,
    ids2_: vec4<u32>,
    misc: vec4<f32>,
    surface: vec4<f32>,
    sss: vec4<f32>,
    sss_color: vec4<f32>,
    optics2_: vec4<f32>,
    pal0_: vec4<f32>,
    pal1_: vec4<f32>,
    pal2_: vec4<f32>,
    pal3_: vec4<f32>,
    accent: vec4<f32>,
    flame: vec4<f32>,
}

struct Materials {
    mats: array<Material>,
}

struct Occ {
    occ: array<u32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(0) @binding(2) 
var<storage, read_write> unnamed_1: Occ;

fn main_1() {
    var i: u32;
    var wpr: u32;
    var y: i32;
    var x0_: i32;
    var word: u32;
    var k: i32;
    var v: vec4<u32>;
    var st: u32;
    var bits: u32;
    var phi_109_: bool;

    let _e28 = gl_GlobalInvocationID_1[0u];
    i = _e28;
    let _e31 = pc.i0_[0u];
    wpr = (bitcast<u32>(_e31) / 16u);
    let _e34 = i;
    let _e35 = wpr;
    let _e38 = pc.i0_[1u];
    if (_e34 >= (_e35 * bitcast<u32>(_e38))) {
        return;
    }
    let _e42 = i;
    let _e43 = wpr;
    y = bitcast<i32>((_e42 / _e43));
    let _e46 = i;
    let _e47 = wpr;
    x0_ = (bitcast<i32>((_e46 % _e47)) * 16i);
    word = 0u;
    k = 0i;
    loop {
        let _e51 = k;
        if (_e51 < 16i) {
            let _e53 = x0_;
            let _e54 = k;
            let _e56 = y;
            let _e58 = textureLoad(cells, vec2<i32>((_e53 + _e54), _e56), 0i);
            v = _e58;
            let _e60 = v[0u];
            let _e66 = unnamed.mats[(_e60 & 255u)].ids[0u];
            st = _e66;
            bits = 0u;
            let _e67 = st;
            let _e69 = st;
            let _e71 = ((_e67 == 3u) || (_e69 == 2u));
            phi_109_ = _e71;
            if _e71 {
                let _e73 = v[0u];
                phi_109_ = (((_e73 >> bitcast<u32>(16u)) & 64u) == 0u);
            }
            let _e79 = phi_109_;
            if _e79 {
                let _e80 = bits;
                bits = (_e80 | 1u);
            }
            let _e82 = st;
            if (_e82 == 1u) {
                let _e84 = bits;
                bits = (_e84 | 2u);
            }
            let _e86 = bits;
            let _e87 = k;
            let _e92 = word;
            word = (_e92 | (_e86 << bitcast<u32>(bitcast<u32>((2i * _e87)))));
            continue;
        } else {
            break;
        }
        continuing {
            let _e94 = k;
            k = (_e94 + 1i);
        }
    }
    let _e96 = i;
    let _e97 = word;
    unnamed_1.occ[_e96] = _e97;
    return;
}

@compute @workgroup_size(64, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
