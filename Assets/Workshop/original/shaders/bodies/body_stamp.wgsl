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

struct Body {
    pose: vec4<f32>,
    com: vec4<f32>,
    rect: vec4<i32>,
    aabb: vec4<i32>,
}

struct Bodies {
    bodies: array<Body>,
}

struct Owner {
    owner: array<u32>,
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

struct Atlas {
    atlas: array<vec4<u32>>,
}

struct Stamped {
    stamped: array<u32>,
}

struct Displaced {
    disp_count: u32,
    disp_pad: array<u32, 3>,
    disp: array<vec4<u32>>,
}

struct Stamped_1 {
    stamped: array<atomic<u32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(6) 
var<storage> unnamed: Bodies;
@group(0) @binding(4) 
var<storage> unnamed_1: Owner;
@group(0) @binding(2) 
var<storage> unnamed_2: Materials;
@group(0) @binding(3) 
var<storage> unnamed_3: Atlas;
@group(0) @binding(5) 
var<storage, read_write> unnamed_4: Stamped_1;
@group(0) @binding(7) 
var<storage, read_write> unnamed_5: Displaced;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e36 = (*c).mat;
    let _e39 = (*c).variant;
    let _e45 = (*c).flags;
    let _e51 = (*c).temp;
    let _e54 = (*c).life;
    let _e57 = (*c).aux;
    let _e63 = (*c).extra;
    return vec4<u32>((((_e36 & 255u) | ((_e39 & 255u) << bitcast<u32>(8u))) | ((_e45 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e51), ((_e54 & 65535u) | ((_e57 & 65535u) << bitcast<u32>(16u))), _e63);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p: ptr<function, vec2<i32>>, c_1: ptr<function, Cell>) {
    var param: Cell;

    let _e37 = (*p);
    let _e38 = (*c_1);
    param = _e38;
    let _e39 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param));
    textureStore(cells_out, _e37, _e39);
    return;
}

fn unpack_cell_u0028_vu4_u003b(v: ptr<function, vec4<u32>>) -> Cell {
    var c_2: Cell;

    let _e37 = (*v)[0u];
    c_2.mat = (_e37 & 255u);
    let _e41 = (*v)[0u];
    c_2.variant = ((_e41 >> bitcast<u32>(8u)) & 255u);
    let _e47 = (*v)[0u];
    c_2.flags = (_e47 >> bitcast<u32>(16u));
    let _e52 = (*v)[1u];
    c_2.temp = bitcast<f32>(_e52);
    let _e56 = (*v)[2u];
    c_2.life = (_e56 & 65535u);
    let _e60 = (*v)[2u];
    c_2.aux = (_e60 >> bitcast<u32>(16u));
    let _e65 = (*v)[3u];
    c_2.extra = _e65;
    let _e67 = c_2;
    return _e67;
}

fn det_q_u0028_f1_u003b_f1_u003b(v_1: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e36 = (*v_1);
    let _e37 = (*scale);
    return i32(round((_e36 * _e37)));
}

fn load_cell_u0028_vi2_u003b(p_1: ptr<function, vec2<i32>>) -> Cell {
    var param_1: vec4<u32>;

    let _e36 = (*p_1);
    let _e37 = textureLoad(cells_in, _e36, 0i);
    param_1 = _e37;
    let _e38 = unpack_cell_u0028_vu4_u003b((&param_1));
    return _e38;
}

fn in_world_u0028_vi2_u003b(p_2: ptr<function, vec2<i32>>) -> bool {
    var phi_55_: bool;
    var phi_69_: bool;
    var phi_77_: bool;

    let _e36 = (*p_2)[0u];
    let _e37 = (_e36 >= 0i);
    phi_55_ = _e37;
    if _e37 {
        let _e39 = (*p_2)[1u];
        phi_55_ = (_e39 >= 0i);
    }
    let _e42 = phi_55_;
    phi_69_ = _e42;
    if _e42 {
        let _e44 = (*p_2)[0u];
        let _e47 = pc.i0_[0u];
        phi_69_ = (_e44 < _e47);
    }
    let _e50 = phi_69_;
    phi_77_ = _e50;
    if _e50 {
        let _e52 = (*p_2)[1u];
        let _e55 = pc.i0_[1u];
        phi_77_ = (_e52 < _e55);
    }
    let _e58 = phi_77_;
    return _e58;
}

fn main_1() {
    var p_3: vec2<i32>;
    var param_2: vec2<i32>;
    var c_3: Cell;
    var param_3: vec2<i32>;
    var b: i32;
    var B: Body;
    var d: vec2<i32>;
    var param_4: f32;
    var param_5: f32;
    var param_6: f32;
    var param_7: f32;
    var co: i32;
    var param_8: f32;
    var param_9: f32;
    var si: i32;
    var param_10: f32;
    var param_11: f32;
    var l: vec2<i32>;
    var param_12: f32;
    var param_13: f32;
    var param_14: f32;
    var param_15: f32;
    var li: vec2<i32>;
    var pix: u32;
    var st: u32;
    var bc: Cell;
    var param_16: vec4<u32>;
    var param_17: vec2<i32>;
    var param_18: Cell;
    var param_19: vec2<i32>;
    var param_20: Cell;
    var phi_243_: bool;
    var phi_252_: bool;
    var phi_261_: bool;
    var phi_348_: bool;
    var phi_357_: bool;
    var phi_366_: bool;

    let _e65 = gl_GlobalInvocationID_1;
    p_3 = bitcast<vec2<i32>>(_e65.xy);
    let _e68 = p_3;
    param_2 = _e68;
    let _e69 = in_world_u0028_vi2_u003b((&param_2));
    if !(_e69) {
        return;
    }
    let _e71 = p_3;
    param_3 = _e71;
    let _e72 = load_cell_u0028_vi2_u003b((&param_3));
    c_3 = _e72;
    b = 0i;
    loop {
        let _e73 = b;
        let _e76 = pc.i0_[2u];
        if (_e73 < _e76) {
            let _e78 = b;
            let _e81 = unnamed.bodies[_e78];
            B.pose = _e81.pose;
            B.com = _e81.com;
            B.rect = _e81.rect;
            B.aabb = _e81.aabb;
            let _e91 = p_3[0u];
            let _e94 = B.aabb[0u];
            let _e95 = (_e91 < _e94);
            phi_243_ = _e95;
            if !(_e95) {
                let _e98 = p_3[1u];
                let _e101 = B.aabb[1u];
                phi_243_ = (_e98 < _e101);
            }
            let _e104 = phi_243_;
            phi_252_ = _e104;
            if !(_e104) {
                let _e107 = p_3[0u];
                let _e110 = B.aabb[2u];
                phi_252_ = (_e107 >= _e110);
            }
            let _e113 = phi_252_;
            phi_261_ = _e113;
            if !(_e113) {
                let _e116 = p_3[1u];
                let _e119 = B.aabb[3u];
                phi_261_ = (_e116 >= _e119);
            }
            let _e122 = phi_261_;
            if _e122 {
                continue;
            }
            let _e123 = p_3;
            let _e130 = B.pose[0u];
            param_4 = _e130;
            param_5 = 16f;
            let _e131 = det_q_u0028_f1_u003b_f1_u003b((&param_4), (&param_5));
            let _e134 = B.pose[1u];
            param_6 = _e134;
            param_7 = 16f;
            let _e135 = det_q_u0028_f1_u003b_f1_u003b((&param_6), (&param_7));
            d = (((_e123 * vec2(16i)) + vec2(8i)) - vec2<i32>(_e131, _e135));
            let _e140 = B.pose[2u];
            param_8 = _e140;
            param_9 = 16384f;
            let _e141 = det_q_u0028_f1_u003b_f1_u003b((&param_8), (&param_9));
            co = _e141;
            let _e144 = B.pose[3u];
            param_10 = _e144;
            param_11 = 16384f;
            let _e145 = det_q_u0028_f1_u003b_f1_u003b((&param_10), (&param_11));
            si = _e145;
            let _e146 = co;
            let _e148 = d[0u];
            let _e150 = si;
            let _e152 = d[1u];
            let _e157 = si;
            let _e160 = d[0u];
            let _e162 = co;
            let _e164 = d[1u];
            let _e172 = B.com[0u];
            param_12 = _e172;
            param_13 = 16f;
            let _e173 = det_q_u0028_f1_u003b_f1_u003b((&param_12), (&param_13));
            let _e176 = B.com[1u];
            param_14 = _e176;
            param_15 = 16f;
            let _e177 = det_q_u0028_f1_u003b_f1_u003b((&param_14), (&param_15));
            l = (vec2<i32>((((_e146 * _e148) + (_e150 * _e152)) >> bitcast<u32>(14i)), (((-(_e157) * _e160) + (_e162 * _e164)) >> bitcast<u32>(14i))) + vec2<i32>(_e173, _e177));
            let _e180 = l;
            li = (_e180 >> bitcast<vec2<u32>>(vec2(4i)));
            let _e185 = li[0u];
            let _e186 = (_e185 < 0i);
            phi_348_ = _e186;
            if !(_e186) {
                let _e189 = li[1u];
                phi_348_ = (_e189 < 0i);
            }
            let _e192 = phi_348_;
            phi_357_ = _e192;
            if !(_e192) {
                let _e195 = li[0u];
                let _e198 = B.rect[1u];
                phi_357_ = (_e195 >= _e198);
            }
            let _e201 = phi_357_;
            phi_366_ = _e201;
            if !(_e201) {
                let _e204 = li[1u];
                let _e207 = B.rect[2u];
                phi_366_ = (_e204 >= _e207);
            }
            let _e210 = phi_366_;
            if _e210 {
                continue;
            }
            let _e213 = B.rect[0u];
            let _e215 = li[1u];
            let _e218 = B.rect[1u];
            let _e222 = li[0u];
            pix = bitcast<u32>(((_e213 + (_e215 * _e218)) + _e222));
            let _e225 = pix;
            let _e228 = unnamed_1.owner[_e225];
            let _e231 = B.rect[3u];
            if (_e228 != bitcast<u32>(_e231)) {
                continue;
            }
            let _e235 = c_3.mat;
            let _e240 = unnamed_2.mats[_e235].ids[0u];
            st = _e240;
            let _e242 = c_3.flags;
            let _e245 = st;
            let _e248 = st;
            if ((((_e242 & 64u) != 0u) || (_e245 == 3u)) || (_e248 == 2u)) {
                break;
            }
            let _e251 = pix;
            let _e254 = unnamed_3.atlas[_e251];
            param_16 = _e254;
            let _e255 = unpack_cell_u0028_vu4_u003b((&param_16));
            bc = _e255;
            let _e257 = bc.flags;
            bc.flags = (_e257 | 64u);
            let _e260 = pix;
            bc.extra = (_e260 << bitcast<u32>(8u));
            let _e264 = p_3;
            param_17 = _e264;
            let _e265 = bc;
            param_18 = _e265;
            store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_17), (&param_18));
            let _e266 = pix;
            let _e271 = pix;
            let _e275 = atomicOr((&unnamed_4.stamped[(_e266 >> bitcast<u32>(5u))]), (1u << bitcast<u32>((_e271 & 31u))));
            return;
        } else {
            break;
        }
        continuing {
            let _e276 = b;
            b = (_e276 + 1i);
        }
    }
    let _e278 = p_3;
    param_19 = _e278;
    let _e279 = c_3;
    param_20 = _e279;
    store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_19), (&param_20));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
