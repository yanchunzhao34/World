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
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(1) 
var<storage, read_write> unnamed_1: VelOut;

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e23 = (*a);
    if (_e23 >= 0i) {
        let _e25 = (*a);
        let _e26 = (*b);
        let _e29 = (*b);
        local = ((_e25 + (_e26 / 2i)) / _e29);
    } else {
        let _e31 = (*a);
        let _e33 = (*b);
        let _e36 = (*b);
        local = -(((-(_e31) + (_e33 / 2i)) / _e36));
    }
    let _e39 = local;
    return _e39;
}

fn lerp256_u0028_i1_u003b_i1_u003b_i1_u003b(a_1: ptr<function, i32>, b_1: ptr<function, i32>, f: ptr<function, i32>) -> i32 {
    var param: i32;
    var param_1: i32;

    let _e25 = (*a_1);
    let _e26 = (*f);
    let _e29 = (*b_1);
    let _e30 = (*f);
    param = ((_e25 * (256i - _e26)) + (_e29 * _e30));
    param_1 = 256i;
    let _e33 = det_div_u0028_i1_u003b_i1_u003b((&param), (&param_1));
    return _e33;
}

fn v_at_u0028_vi2_u003b(q: ptr<function, vec2<i32>>) -> vec2<i32> {
    let _e21 = (*q);
    let _e23 = pc.i0_;
    (*q) = clamp(_e21, vec2<i32>(0i, 0i), (_e23.xy - vec2(1i)));
    let _e29 = (*q)[1u];
    let _e32 = pc.i0_[0u];
    let _e35 = (*q)[0u];
    let _e39 = unnamed.vin[((_e29 * _e32) + _e35)];
    return _e39.xy;
}

fn det_floor_div_u0028_i1_u003b_i1_u003b(a_2: ptr<function, i32>, b_2: ptr<function, i32>) -> i32 {
    var local_1: i32;

    let _e23 = (*a_2);
    if (_e23 >= 0i) {
        let _e25 = (*a_2);
        let _e26 = (*b_2);
        local_1 = (_e25 / _e26);
    } else {
        let _e28 = (*a_2);
        let _e30 = (*b_2);
        let _e33 = (*b_2);
        local_1 = -((((-(_e28) + _e30) - 1i) / _e33));
    }
    let _e36 = local_1;
    return _e36;
}

fn det_q_u0028_f1_u003b_f1_u003b(v: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e22 = (*v);
    let _e23 = (*scale);
    return i32(round((_e22 * _e23)));
}

fn main_1() {
    var p: vec2<i32>;
    var here: vec4<i32>;
    var dtq: i32;
    var param_2: f32;
    var param_3: f32;
    var src: vec2<i32>;
    var param_4: i32;
    var param_5: i32;
    var param_6: i32;
    var param_7: i32;
    var base: vec2<i32>;
    var param_8: i32;
    var param_9: i32;
    var param_10: i32;
    var param_11: i32;
    var f_1: vec2<i32>;
    var a_3: vec2<i32>;
    var param_12: vec2<i32>;
    var b_3: vec2<i32>;
    var param_13: vec2<i32>;
    var c: vec2<i32>;
    var param_14: vec2<i32>;
    var d: vec2<i32>;
    var param_15: vec2<i32>;
    var tx: i32;
    var param_16: i32;
    var param_17: i32;
    var param_18: i32;
    var ty: i32;
    var param_19: i32;
    var param_20: i32;
    var param_21: i32;
    var bx: i32;
    var param_22: i32;
    var param_23: i32;
    var param_24: i32;
    var by: i32;
    var param_25: i32;
    var param_26: i32;
    var param_27: i32;
    var v_1: vec2<i32>;
    var param_28: i32;
    var param_29: i32;
    var param_30: i32;
    var param_31: i32;
    var param_32: i32;
    var param_33: i32;

    let _e67 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e67.xy);
    let _e70 = p;
    let _e72 = pc.i0_;
    if any((_e70 >= _e72.xy)) {
        return;
    }
    let _e77 = p[1u];
    let _e80 = pc.i0_[0u];
    let _e83 = p[0u];
    let _e87 = unnamed.vin[((_e77 * _e80) + _e83)];
    here = _e87;
    let _e90 = pc.f0_[0u];
    param_2 = _e90;
    param_3 = 256f;
    let _e91 = det_q_u0028_f1_u003b_f1_u003b((&param_2), (&param_3));
    dtq = _e91;
    let _e92 = p;
    let _e96 = here[0u];
    let _e97 = dtq;
    param_4 = (_e96 * _e97);
    param_5 = 65536i;
    let _e99 = det_div_u0028_i1_u003b_i1_u003b((&param_4), (&param_5));
    let _e101 = here[1u];
    let _e102 = dtq;
    param_6 = (_e101 * _e102);
    param_7 = 65536i;
    let _e104 = det_div_u0028_i1_u003b_i1_u003b((&param_6), (&param_7));
    src = ((_e92 * vec2(256i)) - vec2<i32>(_e99, _e104));
    let _e108 = src[0u];
    param_8 = _e108;
    param_9 = 256i;
    let _e109 = det_floor_div_u0028_i1_u003b_i1_u003b((&param_8), (&param_9));
    let _e111 = src[1u];
    param_10 = _e111;
    param_11 = 256i;
    let _e112 = det_floor_div_u0028_i1_u003b_i1_u003b((&param_10), (&param_11));
    base = vec2<i32>(_e109, _e112);
    let _e114 = src;
    let _e115 = base;
    f_1 = (_e114 - (_e115 * vec2(256i)));
    let _e119 = base;
    param_12 = _e119;
    let _e120 = v_at_u0028_vi2_u003b((&param_12));
    a_3 = _e120;
    let _e121 = base;
    param_13 = (_e121 + vec2<i32>(1i, 0i));
    let _e123 = v_at_u0028_vi2_u003b((&param_13));
    b_3 = _e123;
    let _e124 = base;
    param_14 = (_e124 + vec2<i32>(0i, 1i));
    let _e126 = v_at_u0028_vi2_u003b((&param_14));
    c = _e126;
    let _e127 = base;
    param_15 = (_e127 + vec2<i32>(1i, 1i));
    let _e129 = v_at_u0028_vi2_u003b((&param_15));
    d = _e129;
    let _e131 = a_3[0u];
    param_16 = _e131;
    let _e133 = b_3[0u];
    param_17 = _e133;
    let _e135 = f_1[0u];
    param_18 = _e135;
    let _e136 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_16), (&param_17), (&param_18));
    tx = _e136;
    let _e138 = a_3[1u];
    param_19 = _e138;
    let _e140 = b_3[1u];
    param_20 = _e140;
    let _e142 = f_1[0u];
    param_21 = _e142;
    let _e143 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_19), (&param_20), (&param_21));
    ty = _e143;
    let _e145 = c[0u];
    param_22 = _e145;
    let _e147 = d[0u];
    param_23 = _e147;
    let _e149 = f_1[0u];
    param_24 = _e149;
    let _e150 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_22), (&param_23), (&param_24));
    bx = _e150;
    let _e152 = c[1u];
    param_25 = _e152;
    let _e154 = d[1u];
    param_26 = _e154;
    let _e156 = f_1[0u];
    param_27 = _e156;
    let _e157 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_25), (&param_26), (&param_27));
    by = _e157;
    let _e158 = tx;
    param_28 = _e158;
    let _e159 = bx;
    param_29 = _e159;
    let _e161 = f_1[1u];
    param_30 = _e161;
    let _e162 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_28), (&param_29), (&param_30));
    let _e163 = ty;
    param_31 = _e163;
    let _e164 = by;
    param_32 = _e164;
    let _e166 = f_1[1u];
    param_33 = _e166;
    let _e167 = lerp256_u0028_i1_u003b_i1_u003b_i1_u003b((&param_31), (&param_32), (&param_33));
    v_1 = vec2<i32>(_e162, _e167);
    let _e170 = here[2u];
    if (_e170 >= 10i) {
        v_1 = vec2<i32>(0i, 0i);
    }
    let _e173 = p[1u];
    let _e176 = pc.i0_[0u];
    let _e179 = p[0u];
    let _e181 = v_1;
    let _e182 = here;
    let _e183 = _e182.zw;
    unnamed_1.vout[((_e173 * _e176) + _e179)] = vec4<i32>(_e181.x, _e181.y, _e183.x, _e183.y);
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
