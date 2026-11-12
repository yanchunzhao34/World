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

struct FluidState {
    fstate: array<vec4<i32>>,
}

struct Out {
    hashes: array<u32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(0) @binding(2) 
var<storage> unnamed_1: FluidState;
@group(0) @binding(3) 
var pressure: texture_2d<f32>;
@group(0) @binding(4) 
var<storage, read_write> unnamed_2: Out;

fn mix_in_u0028_u1_u003b_u1_u003b(h: ptr<function, u32>, v: ptr<function, u32>) -> u32 {
    let _e23 = (*h);
    let _e24 = (*v);
    return ((_e23 ^ _e24) * 16777619u);
}

fn main_1() {
    var y: i32;
    var H: i32;
    var FH: i32;
    var h_1: u32;
    var x: i32;
    var v_1: vec4<u32>;
    var param: u32;
    var param_1: u32;
    var param_2: u32;
    var param_3: u32;
    var param_4: u32;
    var param_5: u32;
    var param_6: u32;
    var param_7: u32;
    var fy: i32;
    var x_1: i32;
    var f: vec4<i32>;
    var param_8: u32;
    var param_9: u32;
    var param_10: u32;
    var param_11: u32;
    var param_12: u32;
    var param_13: u32;
    var param_14: u32;
    var param_15: u32;
    var param_16: u32;
    var param_17: u32;

    let _e49 = gl_GlobalInvocationID_1[0u];
    y = bitcast<i32>(_e49);
    let _e53 = pc.i0_[1u];
    H = _e53;
    let _e56 = pc.i0_[3u];
    FH = _e56;
    let _e57 = y;
    let _e58 = H;
    let _e59 = FH;
    if (_e57 >= (_e58 + _e59)) {
        return;
    }
    let _e62 = y;
    h_1 = (2166136261u ^ bitcast<u32>(_e62));
    let _e65 = y;
    let _e66 = H;
    if (_e65 < _e66) {
        x = 0i;
        loop {
            let _e68 = x;
            let _e71 = pc.i0_[0u];
            if (_e68 < _e71) {
                let _e73 = x;
                let _e74 = y;
                let _e76 = textureLoad(cells, vec2<i32>(_e73, _e74), 0i);
                v_1 = _e76;
                let _e78 = v_1[0u];
                let _e84 = unnamed.mats[(_e78 & 255u)].ids[1u];
                if ((_e84 & 128u) != 0u) {
                    let _e88 = v_1[2u];
                    v_1[2u] = (_e88 & 4294901760u);
                }
                let _e91 = h_1;
                param = _e91;
                let _e93 = v_1[0u];
                param_1 = _e93;
                let _e94 = mix_in_u0028_u1_u003b_u1_u003b((&param), (&param_1));
                param_2 = _e94;
                let _e96 = v_1[1u];
                param_3 = _e96;
                let _e97 = mix_in_u0028_u1_u003b_u1_u003b((&param_2), (&param_3));
                param_4 = _e97;
                let _e99 = v_1[2u];
                param_5 = _e99;
                let _e100 = mix_in_u0028_u1_u003b_u1_u003b((&param_4), (&param_5));
                param_6 = _e100;
                let _e102 = v_1[3u];
                param_7 = _e102;
                let _e103 = mix_in_u0028_u1_u003b_u1_u003b((&param_6), (&param_7));
                h_1 = _e103;
                continue;
            } else {
                break;
            }
            continuing {
                let _e104 = x;
                x = (_e104 + 1i);
            }
        }
    } else {
        let _e106 = y;
        let _e107 = H;
        fy = (_e106 - _e107);
        x_1 = 0i;
        loop {
            let _e109 = x_1;
            let _e112 = pc.i0_[2u];
            if (_e109 < _e112) {
                let _e114 = fy;
                let _e117 = pc.i0_[2u];
                let _e119 = x_1;
                let _e123 = unnamed_1.fstate[((_e114 * _e117) + _e119)];
                f = _e123;
                let _e125 = f[0u];
                let _e127 = h_1;
                param_8 = _e127;
                param_9 = bitcast<u32>(_e125);
                let _e128 = mix_in_u0028_u1_u003b_u1_u003b((&param_8), (&param_9));
                let _e130 = f[1u];
                param_10 = _e128;
                param_11 = bitcast<u32>(_e130);
                let _e132 = mix_in_u0028_u1_u003b_u1_u003b((&param_10), (&param_11));
                let _e134 = f[2u];
                param_12 = _e132;
                param_13 = bitcast<u32>(_e134);
                let _e136 = mix_in_u0028_u1_u003b_u1_u003b((&param_12), (&param_13));
                let _e138 = f[3u];
                param_14 = _e136;
                param_15 = bitcast<u32>(_e138);
                let _e140 = mix_in_u0028_u1_u003b_u1_u003b((&param_14), (&param_15));
                h_1 = _e140;
                let _e141 = x_1;
                let _e142 = fy;
                let _e144 = textureLoad(pressure, vec2<i32>(_e141, _e142), 0i);
                let _e147 = h_1;
                param_16 = _e147;
                param_17 = bitcast<u32>(_e144.x);
                let _e148 = mix_in_u0028_u1_u003b_u1_u003b((&param_16), (&param_17));
                h_1 = _e148;
                continue;
            } else {
                break;
            }
            continuing {
                let _e149 = x_1;
                x_1 = (_e149 + 1i);
            }
        }
    }
    let _e151 = y;
    let _e152 = h_1;
    unnamed_2.hashes[_e151] = _e152;
    return;
}

@compute @workgroup_size(64, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
