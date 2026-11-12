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

struct Owner {
    owner: array<u32>,
}

struct Atlas {
    atlas: array<vec4<u32>>,
}

struct Pick {
    pick: array<u32>,
}

struct Alive {
    alive: array<u32>,
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

struct Pick_1 {
    pick: array<atomic<u32>>,
}

struct Alive_1 {
    alive: array<atomic<u32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(4) 
var<storage> unnamed: Owner;
@group(0) @binding(3) 
var<storage, read_write> unnamed_1: Atlas;
@group(0) @binding(6) 
var<storage, read_write> unnamed_2: Pick_1;
@group(0) @binding(5) 
var<storage, read_write> unnamed_3: Alive_1;
@group(0) @binding(2) 
var<storage> unnamed_4: Materials;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e32 = (*c).mat;
    let _e35 = (*c).variant;
    let _e41 = (*c).flags;
    let _e47 = (*c).temp;
    let _e50 = (*c).life;
    let _e53 = (*c).aux;
    let _e59 = (*c).extra;
    return vec4<u32>((((_e32 & 255u) | ((_e35 & 255u) << bitcast<u32>(8u))) | ((_e41 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e47), ((_e50 & 65535u) | ((_e53 & 65535u) << bitcast<u32>(16u))), _e59);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p: ptr<function, vec2<i32>>, c_1: ptr<function, Cell>) {
    var param: Cell;

    let _e33 = (*p);
    let _e34 = (*c_1);
    param = _e34;
    let _e35 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param));
    textureStore(cells_out, _e33, _e35);
    return;
}

fn unpack_cell_u0028_vu4_u003b(v: ptr<function, vec4<u32>>) -> Cell {
    var c_2: Cell;

    let _e33 = (*v)[0u];
    c_2.mat = (_e33 & 255u);
    let _e37 = (*v)[0u];
    c_2.variant = ((_e37 >> bitcast<u32>(8u)) & 255u);
    let _e43 = (*v)[0u];
    c_2.flags = (_e43 >> bitcast<u32>(16u));
    let _e48 = (*v)[1u];
    c_2.temp = bitcast<f32>(_e48);
    let _e52 = (*v)[2u];
    c_2.life = (_e52 & 65535u);
    let _e56 = (*v)[2u];
    c_2.aux = (_e56 >> bitcast<u32>(16u));
    let _e61 = (*v)[3u];
    c_2.extra = _e61;
    let _e63 = c_2;
    return _e63;
}

fn load_cell_u0028_vi2_u003b(p_1: ptr<function, vec2<i32>>) -> Cell {
    var param_1: vec4<u32>;

    let _e32 = (*p_1);
    let _e33 = textureLoad(cells_in, _e32, 0i);
    param_1 = _e33;
    let _e34 = unpack_cell_u0028_vu4_u003b((&param_1));
    return _e34;
}

fn in_world_u0028_vi2_u003b(p_2: ptr<function, vec2<i32>>) -> bool {
    var phi_49_: bool;
    var phi_63_: bool;
    var phi_71_: bool;

    let _e32 = (*p_2)[0u];
    let _e33 = (_e32 >= 0i);
    phi_49_ = _e33;
    if _e33 {
        let _e35 = (*p_2)[1u];
        phi_49_ = (_e35 >= 0i);
    }
    let _e38 = phi_49_;
    phi_63_ = _e38;
    if _e38 {
        let _e40 = (*p_2)[0u];
        let _e43 = pc.i0_[0u];
        phi_63_ = (_e40 < _e43);
    }
    let _e46 = phi_63_;
    phi_71_ = _e46;
    if _e46 {
        let _e48 = (*p_2)[1u];
        let _e51 = pc.i0_[1u];
        phi_71_ = (_e48 < _e51);
    }
    let _e54 = phi_71_;
    return _e54;
}

fn main_1() {
    var p_3: vec2<i32>;
    var param_2: vec2<i32>;
    var c_3: Cell;
    var param_3: vec2<i32>;
    var pix: u32;
    var ok: bool;
    var me: u32;
    var param_4: Cell;
    var a: Cell;
    var param_5: vec2<i32>;
    var param_6: Cell;
    var param_7: vec2<i32>;
    var param_8: Cell;
    var phi_196_: bool;
    var phi_229_: bool;
    var phi_243_: bool;

    let _e43 = gl_GlobalInvocationID_1;
    p_3 = bitcast<vec2<i32>>(_e43.xy);
    let _e46 = p_3;
    param_2 = _e46;
    let _e47 = in_world_u0028_vi2_u003b((&param_2));
    if !(_e47) {
        return;
    }
    let _e49 = p_3;
    param_3 = _e49;
    let _e50 = load_cell_u0028_vi2_u003b((&param_3));
    c_3 = _e50;
    let _e53 = pc.i0_[3u];
    let _e54 = (_e53 == 0i);
    phi_196_ = _e54;
    if _e54 {
        let _e56 = c_3.flags;
        phi_196_ = ((_e56 & 64u) == 0u);
    }
    let _e60 = phi_196_;
    if _e60 {
        return;
    }
    let _e62 = c_3.flags;
    if ((_e62 & 64u) != 0u) {
        let _e66 = c_3.extra;
        pix = (_e66 >> bitcast<u32>(8u));
        let _e69 = pix;
        let _e72 = pc.i0_[2u];
        let _e74 = (_e69 < bitcast<u32>(_e72));
        phi_229_ = _e74;
        if _e74 {
            let _e75 = pix;
            let _e78 = unnamed.owner[_e75];
            phi_229_ = (_e78 != 4294967295u);
        }
        let _e81 = phi_229_;
        phi_243_ = _e81;
        if _e81 {
            let _e82 = pix;
            let _e86 = unnamed_1.atlas[_e82][0u];
            let _e89 = c_3.mat;
            phi_243_ = ((_e86 & 255u) == _e89);
        }
        let _e92 = phi_243_;
        ok = _e92;
        let _e94 = p_3[1u];
        let _e97 = pc.i0_[0u];
        let _e100 = p_3[0u];
        me = ~(bitcast<u32>(((_e94 * _e97) + _e100)));
        let _e106 = pc.i0_[3u];
        if (_e106 == 0i) {
            let _e108 = ok;
            if _e108 {
                let _e109 = pix;
                let _e112 = me;
                let _e113 = atomicMax((&unnamed_2.pick[_e109]), _e112);
            }
            return;
        }
        let _e114 = ok;
        if _e114 {
            let _e115 = pix;
            let _e118 = atomicLoad((&unnamed_2.pick[_e115]));
            let _e119 = me;
            if (_e118 == _e119) {
                let _e121 = pix;
                let _e122 = c_3;
                param_4 = _e122;
                let _e123 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_4));
                unnamed_1.atlas[_e121] = _e123;
            }
            let _e126 = pix;
            let _e131 = pix;
            let _e135 = atomicOr((&unnamed_3.alive[(_e126 >> bitcast<u32>(5u))]), (1u << bitcast<u32>((_e131 & 31u))));
            a.mat = 0u;
            let _e138 = c_3.variant;
            a.variant = _e138;
            a.flags = 0u;
            let _e142 = c_3.temp;
            a.temp = _e142;
            a.life = 0u;
            a.aux = 0u;
            a.extra = 0u;
            let _e147 = p_3;
            param_5 = _e147;
            let _e148 = a;
            param_6 = _e148;
            store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_5), (&param_6));
            return;
        }
        let _e150 = c_3.flags;
        c_3.flags = (_e150 & 4294967231u);
        let _e154 = c_3.extra;
        c_3.extra = (_e154 & 255u);
    }
    let _e157 = p_3;
    param_7 = _e157;
    let _e158 = c_3;
    param_8 = _e158;
    store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_7), (&param_8));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
