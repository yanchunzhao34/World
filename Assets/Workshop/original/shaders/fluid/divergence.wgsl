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
@group(0) @binding(0) 
var<storage> unnamed: Vel;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(1) 
var div_out: texture_storage_2d<r32float,write>;

fn vel_at_u0028_vi2_u003b(q: ptr<function, vec2<i32>>) -> vec2<i32> {
    var v: vec4<i32>;
    var local: vec2<i32>;
    var phi_36_: bool;

    let _e18 = (*q);
    let _e20 = any((_e18 < vec2<i32>(0i, 0i)));
    phi_36_ = _e20;
    if !(_e20) {
        let _e22 = (*q);
        let _e24 = pc.i0_;
        phi_36_ = any((_e22 >= _e24.xy));
    }
    let _e29 = phi_36_;
    if _e29 {
        return vec2<i32>(0i, 0i);
    }
    let _e31 = (*q)[1u];
    let _e34 = pc.i0_[0u];
    let _e37 = (*q)[0u];
    let _e41 = unnamed.vel[((_e31 * _e34) + _e37)];
    v = _e41;
    let _e43 = v[2u];
    if (_e43 >= 10i) {
        local = vec2<i32>(0i, 0i);
    } else {
        let _e45 = v;
        local = _e45.xy;
    }
    let _e47 = local;
    return _e47;
}

fn main_1() {
    var p: vec2<i32>;
    var d: i32;
    var param: vec2<i32>;
    var param_1: vec2<i32>;
    var param_2: vec2<i32>;
    var param_3: vec2<i32>;

    let _e21 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e21.xy);
    let _e24 = p;
    let _e26 = pc.i0_;
    if any((_e24 >= _e26.xy)) {
        return;
    }
    let _e30 = p;
    param = (_e30 + vec2<i32>(1i, 0i));
    let _e32 = vel_at_u0028_vi2_u003b((&param));
    let _e34 = p;
    param_1 = (_e34 - vec2<i32>(1i, 0i));
    let _e36 = vel_at_u0028_vi2_u003b((&param_1));
    let _e39 = p;
    param_2 = (_e39 + vec2<i32>(0i, 1i));
    let _e41 = vel_at_u0028_vi2_u003b((&param_2));
    let _e43 = p;
    param_3 = (_e43 - vec2<i32>(0i, 1i));
    let _e45 = vel_at_u0028_vi2_u003b((&param_3));
    d = ((_e32.x - _e36.x) + (_e41.y - _e45.y));
    let _e49 = p;
    let _e50 = d;
    textureStore(div_out, _e49, vec4(f32(_e50)));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
