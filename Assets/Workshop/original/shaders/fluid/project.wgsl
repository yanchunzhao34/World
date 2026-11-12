struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct VelIn {
    vin: array<vec4<i32>>,
}

struct VelOut {
    vout: array<vec4<i32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var<storage> unnamed: VelIn;
@group(0) @binding(2) 
var pres: texture_2d<f32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(1) 
var<storage, read_write> unnamed_1: VelOut;
@group(0) @binding(3) 
var vel_view: texture_storage_2d<rgba16float,write>;

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e26 = (*a);
    if (_e26 >= 0i) {
        let _e28 = (*a);
        let _e29 = (*b);
        let _e32 = (*b);
        local = ((_e28 + (_e29 / 2i)) / _e32);
    } else {
        let _e34 = (*a);
        let _e36 = (*b);
        let _e39 = (*b);
        local = -(((-(_e34) + (_e36 / 2i)) / _e39));
    }
    let _e42 = local;
    return _e42;
}

fn p_at_u0028_vi2_u003b_i1_u003b(q: ptr<function, vec2<i32>>, center: ptr<function, i32>) -> i32 {
    var phi_67_: bool;

    let _e25 = (*q);
    let _e27 = any((_e25 < vec2<i32>(0i, 0i)));
    phi_67_ = _e27;
    if !(_e27) {
        let _e29 = (*q);
        let _e31 = pc.i0_;
        phi_67_ = any((_e29 >= _e31.xy));
    }
    let _e36 = phi_67_;
    if _e36 {
        let _e37 = (*center);
        return _e37;
    }
    let _e39 = (*q)[1u];
    let _e42 = pc.i0_[0u];
    let _e45 = (*q)[0u];
    let _e50 = unnamed.vin[((_e39 * _e42) + _e45)][2u];
    if (_e50 >= 10i) {
        let _e52 = (*center);
        return _e52;
    }
    let _e53 = (*q);
    let _e54 = textureLoad(pres, _e53, 0i);
    return i32(_e54.x);
}

fn main_1() {
    var p: vec2<i32>;
    var v: vec4<i32>;
    var c: i32;
    var param: vec2<i32>;
    var param_1: i32;
    var param_2: vec2<i32>;
    var param_3: i32;
    var param_4: i32;
    var param_5: i32;
    var param_6: vec2<i32>;
    var param_7: i32;
    var param_8: vec2<i32>;
    var param_9: i32;
    var param_10: i32;
    var param_11: i32;

    let _e38 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e38.xy);
    let _e41 = p;
    let _e43 = pc.i0_;
    if any((_e41 >= _e43.xy)) {
        return;
    }
    let _e48 = p[1u];
    let _e51 = pc.i0_[0u];
    let _e54 = p[0u];
    let _e58 = unnamed.vin[((_e48 * _e51) + _e54)];
    v = _e58;
    let _e59 = p;
    let _e60 = textureLoad(pres, _e59, 0i);
    c = i32(_e60.x);
    let _e63 = p;
    param = (_e63 + vec2<i32>(1i, 0i));
    let _e65 = c;
    param_1 = _e65;
    let _e66 = p_at_u0028_vi2_u003b_i1_u003b((&param), (&param_1));
    let _e67 = p;
    param_2 = (_e67 - vec2<i32>(1i, 0i));
    let _e69 = c;
    param_3 = _e69;
    let _e70 = p_at_u0028_vi2_u003b_i1_u003b((&param_2), (&param_3));
    param_4 = (_e66 - _e70);
    param_5 = 4i;
    let _e72 = det_div_u0028_i1_u003b_i1_u003b((&param_4), (&param_5));
    let _e74 = v[0u];
    v[0u] = (_e74 - _e72);
    let _e77 = p;
    param_6 = (_e77 + vec2<i32>(0i, 1i));
    let _e79 = c;
    param_7 = _e79;
    let _e80 = p_at_u0028_vi2_u003b_i1_u003b((&param_6), (&param_7));
    let _e81 = p;
    param_8 = (_e81 - vec2<i32>(0i, 1i));
    let _e83 = c;
    param_9 = _e83;
    let _e84 = p_at_u0028_vi2_u003b_i1_u003b((&param_8), (&param_9));
    param_10 = (_e80 - _e84);
    param_11 = 4i;
    let _e86 = det_div_u0028_i1_u003b_i1_u003b((&param_10), (&param_11));
    let _e88 = v[1u];
    v[1u] = (_e88 - _e86);
    let _e92 = v[2u];
    if (_e92 >= 10i) {
        v[0u] = vec2<i32>(0i, 0i).x;
        v[1u] = vec2<i32>(0i, 0i).y;
    }
    let _e99 = p[1u];
    let _e102 = pc.i0_[0u];
    let _e105 = p[0u];
    let _e107 = v;
    unnamed_1.vout[((_e99 * _e102) + _e105)] = _e107;
    let _e110 = p;
    let _e111 = v;
    let _e115 = (vec2<f32>(_e111.xy) / vec2(65536f));
    let _e117 = v[2u];
    let _e121 = v[3u];
    textureStore(vel_view, _e110, vec4<f32>(_e115.x, _e115.y, (f32(_e117) / 16f), (f32(_e121) / 64f)));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
