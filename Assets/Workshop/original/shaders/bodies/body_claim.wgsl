struct Cell {
    mat: u32,
    variant: u32,
    flags: u32,
    temp: f32,
    life: u32,
    aux: u32,
    extra: u32,
}

struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Claims {
    claims: array<vec4<u32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(1) 
var<storage> unnamed: Claims;
@group(3) @binding(0) 
var cells_r: texture_2d<u32>;
@group(0) @binding(0) 
var cells: texture_storage_2d<rgba32uint,write>;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e24 = (*c).mat;
    let _e27 = (*c).variant;
    let _e33 = (*c).flags;
    let _e39 = (*c).temp;
    let _e42 = (*c).life;
    let _e45 = (*c).aux;
    let _e51 = (*c).extra;
    return vec4<u32>((((_e24 & 255u) | ((_e27 & 255u) << bitcast<u32>(8u))) | ((_e33 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e39), ((_e42 & 65535u) | ((_e45 & 65535u) << bitcast<u32>(16u))), _e51);
}

fn unpack_cell_u0028_vu4_u003b(v: ptr<function, vec4<u32>>) -> Cell {
    var c_1: Cell;

    let _e25 = (*v)[0u];
    c_1.mat = (_e25 & 255u);
    let _e29 = (*v)[0u];
    c_1.variant = ((_e29 >> bitcast<u32>(8u)) & 255u);
    let _e35 = (*v)[0u];
    c_1.flags = (_e35 >> bitcast<u32>(16u));
    let _e40 = (*v)[1u];
    c_1.temp = bitcast<f32>(_e40);
    let _e44 = (*v)[2u];
    c_1.life = (_e44 & 65535u);
    let _e48 = (*v)[2u];
    c_1.aux = (_e48 >> bitcast<u32>(16u));
    let _e53 = (*v)[3u];
    c_1.extra = _e53;
    let _e55 = c_1;
    return _e55;
}

fn in_world_u0028_vi2_u003b(p: ptr<function, vec2<i32>>) -> bool {
    var phi_40_: bool;
    var phi_54_: bool;
    var phi_62_: bool;

    let _e24 = (*p)[0u];
    let _e25 = (_e24 >= 0i);
    phi_40_ = _e25;
    if _e25 {
        let _e27 = (*p)[1u];
        phi_40_ = (_e27 >= 0i);
    }
    let _e30 = phi_40_;
    phi_54_ = _e30;
    if _e30 {
        let _e32 = (*p)[0u];
        let _e35 = pc.i0_[0u];
        phi_54_ = (_e32 < _e35);
    }
    let _e38 = phi_54_;
    phi_62_ = _e38;
    if _e38 {
        let _e40 = (*p)[1u];
        let _e43 = pc.i0_[1u];
        phi_62_ = (_e40 < _e43);
    }
    let _e46 = phi_62_;
    return _e46;
}

fn main_1() {
    var i: u32;
    var cl: vec4<u32>;
    var p_1: vec2<i32>;
    var param: vec2<i32>;
    var c_2: Cell;
    var param_1: vec4<u32>;
    var param_2: Cell;
    var phi_203_: bool;

    let _e30 = gl_GlobalInvocationID_1[0u];
    i = _e30;
    let _e31 = i;
    let _e34 = pc.i1_[0u];
    if (_e31 >= bitcast<u32>(_e34)) {
        return;
    }
    let _e37 = i;
    let _e40 = unnamed.claims[_e37];
    cl = _e40;
    let _e42 = cl[0u];
    let _e46 = cl[0u];
    p_1 = vec2<i32>(bitcast<i32>((_e42 & 65535u)), bitcast<i32>((_e46 >> bitcast<u32>(16u))));
    let _e51 = p_1;
    param = _e51;
    let _e52 = in_world_u0028_vi2_u003b((&param));
    if !(_e52) {
        return;
    }
    let _e54 = p_1;
    let _e55 = textureLoad(cells_r, _e54, 0i);
    param_1 = _e55;
    let _e56 = unpack_cell_u0028_vu4_u003b((&param_1));
    c_2 = _e56;
    let _e58 = c_2.mat;
    let _e60 = cl[3u];
    let _e61 = (_e58 != _e60);
    phi_203_ = _e61;
    if !(_e61) {
        let _e64 = c_2.flags;
        phi_203_ = ((_e64 & 64u) != 0u);
    }
    let _e68 = phi_203_;
    if _e68 {
        return;
    }
    let _e70 = c_2.flags;
    c_2.flags = (_e70 | 64u);
    let _e74 = cl[1u];
    let _e78 = c_2.extra;
    c_2.extra = ((_e74 << bitcast<u32>(8u)) | (_e78 & 255u));
    let _e82 = p_1;
    let _e83 = c_2;
    param_2 = _e83;
    let _e84 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_2));
    textureStore(cells, _e82, _e84);
    return;
}

@compute @workgroup_size(64, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
