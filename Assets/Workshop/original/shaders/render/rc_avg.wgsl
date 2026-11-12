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
var upper: texture_2d<f32>;
@group(2) @binding(0) 
var upper_smp: sampler;
@group(0) @binding(1) 
var out_img: texture_storage_2d<rgba32float,write>;

fn main_1() {
    var p: vec2<i32>;
    var tile: i32;
    var tileU: i32;
    var q: vec2<i32>;
    var local: vec2<i32>;
    var dirIndex: i32;
    var acc: vec3<f32>;
    var j: i32;
    var dd: i32;
    var texel: vec2<i32>;

    let _e26 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e26.xy);
    let _e29 = p;
    let _e31 = pc.i0_;
    if any((_e29 >= _e31.xy)) {
        return;
    }
    let _e37 = pc.i1_[1u];
    tile = _e37;
    let _e38 = tile;
    tileU = (_e38 * 2i);
    let _e40 = p;
    let _e41 = tile;
    q = (_e40 / vec2(_e41));
    let _e44 = p;
    let _e45 = q;
    let _e46 = tile;
    local = (_e44 - (_e45 * vec2(_e46)));
    let _e51 = local[1u];
    let _e52 = tile;
    let _e55 = local[0u];
    dirIndex = ((_e51 * _e52) + _e55);
    acc = vec3<f32>(0f, 0f, 0f);
    j = 0i;
    loop {
        let _e57 = j;
        if (_e57 < 4i) {
            let _e59 = dirIndex;
            let _e61 = j;
            dd = ((_e59 * 4i) + _e61);
            let _e63 = q;
            let _e64 = tileU;
            let _e67 = dd;
            let _e68 = tileU;
            let _e76 = dd;
            let _e77 = tileU;
            texel = ((_e63 * vec2(_e64)) + vec2<i32>((_e67 % _e68 + select(0i, _e68, _e67 % _e68 != 0i && ((_e67 % _e68 < 0i) != (_e68 < 0i)))), (_e76 / _e77)));
            let _e81 = texel;
            let _e82 = textureLoad(upper, _e81, 0i);
            let _e84 = acc;
            acc = (_e84 + _e82.xyz);
            continue;
        } else {
            break;
        }
        continuing {
            let _e86 = j;
            j = (_e86 + 1i);
        }
    }
    let _e88 = p;
    let _e89 = acc;
    let _e90 = (_e89 * 0.25f);
    textureStore(out_img, _e88, vec4<f32>(_e90.x, _e90.y, _e90.z, 0f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
