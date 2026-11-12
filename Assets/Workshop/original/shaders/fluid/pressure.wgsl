struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Vel {
    vel: array<vec4<i32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(3) 
var<storage> unnamed: Vel;
@group(0) @binding(0) 
var p_in: texture_2d<f32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(2) 
var div_in: texture_2d<f32>;
@group(0) @binding(1) 
var p_out: texture_storage_2d<r32float,write>;

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e24 = (*a);
    if (_e24 >= 0i) {
        let _e26 = (*a);
        let _e27 = (*b);
        let _e30 = (*b);
        local = ((_e26 + (_e27 / 2i)) / _e30);
    } else {
        let _e32 = (*a);
        let _e34 = (*b);
        let _e37 = (*b);
        local = -(((-(_e32) + (_e34 / 2i)) / _e37));
    }
    let _e40 = local;
    return _e40;
}

fn p_at_u0028_vi2_u003b_i1_u003b(q: ptr<function, vec2<i32>>, center: ptr<function, i32>) -> i32 {
    var phi_67_: bool;

    let _e23 = (*q);
    let _e25 = any((_e23 < vec2<i32>(0i, 0i)));
    phi_67_ = _e25;
    if !(_e25) {
        let _e27 = (*q);
        let _e29 = pc.i0_;
        phi_67_ = any((_e27 >= _e29.xy));
    }
    let _e34 = phi_67_;
    if _e34 {
        let _e35 = (*center);
        return _e35;
    }
    let _e37 = (*q)[1u];
    let _e40 = pc.i0_[0u];
    let _e43 = (*q)[0u];
    let _e48 = unnamed.vel[((_e37 * _e40) + _e43)][2u];
    if (_e48 >= 10i) {
        let _e50 = (*center);
        return _e50;
    }
    let _e51 = (*q);
    let _e52 = textureLoad(p_in, _e51, 0i);
    return i32(_e52.x);
}

fn main_1() {
    var p: vec2<i32>;
    var c: i32;
    var s: i32;
    var param: vec2<i32>;
    var param_1: i32;
    var param_2: vec2<i32>;
    var param_3: i32;
    var param_4: vec2<i32>;
    var param_5: i32;
    var param_6: vec2<i32>;
    var param_7: i32;
    var np: i32;
    var param_8: i32;
    var param_9: i32;

    let _e35 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e35.xy);
    let _e38 = p;
    let _e40 = pc.i0_;
    if any((_e38 >= _e40.xy)) {
        return;
    }
    let _e44 = p;
    let _e45 = textureLoad(p_in, _e44, 0i);
    c = i32(_e45.x);
    let _e48 = p;
    param = (_e48 + vec2<i32>(1i, 0i));
    let _e50 = c;
    param_1 = _e50;
    let _e51 = p_at_u0028_vi2_u003b_i1_u003b((&param), (&param_1));
    let _e52 = p;
    param_2 = (_e52 - vec2<i32>(1i, 0i));
    let _e54 = c;
    param_3 = _e54;
    let _e55 = p_at_u0028_vi2_u003b_i1_u003b((&param_2), (&param_3));
    let _e57 = p;
    param_4 = (_e57 + vec2<i32>(0i, 1i));
    let _e59 = c;
    param_5 = _e59;
    let _e60 = p_at_u0028_vi2_u003b_i1_u003b((&param_4), (&param_5));
    let _e62 = p;
    param_6 = (_e62 - vec2<i32>(0i, 1i));
    let _e64 = c;
    param_7 = _e64;
    let _e65 = p_at_u0028_vi2_u003b_i1_u003b((&param_6), (&param_7));
    s = (((_e51 + _e55) + _e60) + _e65);
    let _e67 = s;
    let _e68 = p;
    let _e69 = textureLoad(div_in, _e68, 0i);
    param_8 = (_e67 - i32(_e69.x));
    param_9 = 4i;
    let _e73 = det_div_u0028_i1_u003b_i1_u003b((&param_8), (&param_9));
    np = clamp(_e73, -8388608i, 8388608i);
    let _e75 = p;
    let _e76 = np;
    textureStore(p_out, _e75, vec4(f32(_e76)));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
