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

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;
@group(0) @binding(2) 
var<storage> unnamed: Materials;
var<private> gl_GlobalInvocationID_1: vec3<u32>;

fn pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> vec4<u32> {
    let _e54 = (*c).mat;
    let _e57 = (*c).variant;
    let _e63 = (*c).flags;
    let _e69 = (*c).temp;
    let _e72 = (*c).life;
    let _e75 = (*c).aux;
    let _e81 = (*c).extra;
    return vec4<u32>((((_e54 & 255u) | ((_e57 & 255u) << bitcast<u32>(8u))) | ((_e63 & 65535u) << bitcast<u32>(16u))), bitcast<u32>(_e69), ((_e72 & 65535u) | ((_e75 & 65535u) << bitcast<u32>(16u))), _e81);
}

fn store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(p: ptr<function, vec2<i32>>, c_1: ptr<function, Cell>) {
    var param: Cell;

    let _e55 = (*p);
    let _e56 = (*c_1);
    param = _e56;
    let _e57 = pack_cell_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param));
    textureStore(cells_out, _e55, _e57);
    return;
}

fn det_div_u0028_i1_u003b_i1_u003b(a: ptr<function, i32>, b: ptr<function, i32>) -> i32 {
    var local: i32;

    let _e55 = (*a);
    if (_e55 >= 0i) {
        let _e57 = (*a);
        let _e58 = (*b);
        let _e61 = (*b);
        local = ((_e57 + (_e58 / 2i)) / _e61);
    } else {
        let _e63 = (*a);
        let _e65 = (*b);
        let _e68 = (*b);
        local = -(((-(_e63) + (_e65 / 2i)) / _e68));
    }
    let _e71 = local;
    return _e71;
}

fn det_q_u0028_f1_u003b_f1_u003b(v: ptr<function, f32>, scale: ptr<function, f32>) -> i32 {
    let _e54 = (*v);
    let _e55 = (*scale);
    return i32(round((_e54 * _e55)));
}

fn kq_u0028_u1_u003b(mat: ptr<function, u32>) -> i32 {
    var param_1: f32;
    var param_2: f32;

    let _e55 = (*mat);
    let _e60 = unnamed.mats[_e55].thermo[1u];
    param_1 = _e60;
    param_2 = 2048f;
    let _e61 = det_q_u0028_f1_u003b_f1_u003b((&param_1), (&param_2));
    return _e61;
}

fn tq_u0028_f1_u003b(t: ptr<function, f32>) -> i32 {
    var param_3: f32;
    var param_4: f32;

    let _e55 = (*t);
    param_3 = clamp(_e55, 1f, 9000f);
    param_4 = 64f;
    let _e57 = det_q_u0028_f1_u003b_f1_u003b((&param_3), (&param_4));
    return _e57;
}

fn unpack_cell_u0028_vu4_u003b(v_1: ptr<function, vec4<u32>>) -> Cell {
    var c_2: Cell;

    let _e55 = (*v_1)[0u];
    c_2.mat = (_e55 & 255u);
    let _e59 = (*v_1)[0u];
    c_2.variant = ((_e59 >> bitcast<u32>(8u)) & 255u);
    let _e65 = (*v_1)[0u];
    c_2.flags = (_e65 >> bitcast<u32>(16u));
    let _e70 = (*v_1)[1u];
    c_2.temp = bitcast<f32>(_e70);
    let _e74 = (*v_1)[2u];
    c_2.life = (_e74 & 65535u);
    let _e78 = (*v_1)[2u];
    c_2.aux = (_e78 >> bitcast<u32>(16u));
    let _e83 = (*v_1)[3u];
    c_2.extra = _e83;
    let _e85 = c_2;
    return _e85;
}

fn load_cell_u0028_vi2_u003b(p_1: ptr<function, vec2<i32>>) -> Cell {
    var param_5: vec4<u32>;

    let _e54 = (*p_1);
    let _e55 = textureLoad(cells_in, _e54, 0i);
    param_5 = _e55;
    let _e56 = unpack_cell_u0028_vu4_u003b((&param_5));
    return _e56;
}

fn in_world_u0028_vi2_u003b(p_2: ptr<function, vec2<i32>>) -> bool {
    var phi_69_: bool;
    var phi_83_: bool;
    var phi_91_: bool;

    let _e54 = (*p_2)[0u];
    let _e55 = (_e54 >= 0i);
    phi_69_ = _e55;
    if _e55 {
        let _e57 = (*p_2)[1u];
        phi_69_ = (_e57 >= 0i);
    }
    let _e60 = phi_69_;
    phi_83_ = _e60;
    if _e60 {
        let _e62 = (*p_2)[0u];
        let _e65 = pc.i0_[0u];
        phi_83_ = (_e62 < _e65);
    }
    let _e68 = phi_83_;
    phi_91_ = _e68;
    if _e68 {
        let _e70 = (*p_2)[1u];
        let _e73 = pc.i0_[1u];
        phi_91_ = (_e70 < _e73);
    }
    let _e76 = phi_91_;
    return _e76;
}

fn main_1() {
    var p_3: vec2<i32>;
    var param_6: vec2<i32>;
    var c_3: Cell;
    var param_7: vec2<i32>;
    var m: Material;
    var ti: i32;
    var param_8: f32;
    var ki: i32;
    var param_9: u32;
    var ci: i32;
    var param_10: f32;
    var param_11: f32;
    var flux: i32;
    var ksum: i32;
    var i: i32;
    var q: vec2<i32>;
    var indexable: array<vec2<i32>, 4>;
    var param_12: vec2<i32>;
    var nq: vec4<u32>;
    var kn: i32;
    var param_13: u32;
    var kij: i32;
    var local_1: i32;
    var param_14: i32;
    var param_15: i32;
    var param_16: f32;
    var dt: i32;
    var qt: i32;
    var param_17: i32;
    var param_18: i32;
    var param_19: f32;
    var param_20: f32;
    var param_21: f32;
    var param_22: f32;
    var param_23: i32;
    var param_24: i32;
    var param_25: vec2<i32>;
    var param_26: Cell;
    var phi_468_: bool;

    let _e90 = gl_GlobalInvocationID_1;
    p_3 = bitcast<vec2<i32>>(_e90.xy);
    let _e93 = p_3;
    param_6 = _e93;
    let _e94 = in_world_u0028_vi2_u003b((&param_6));
    if !(_e94) {
        return;
    }
    let _e96 = p_3;
    param_7 = _e96;
    let _e97 = load_cell_u0028_vi2_u003b((&param_7));
    c_3 = _e97;
    let _e99 = c_3.mat;
    let _e102 = unnamed.mats[_e99];
    m.color_a = _e102.color_a;
    m.color_b = _e102.color_b;
    m.emission = _e102.emission;
    m.phys = _e102.phys;
    m.thermo = _e102.thermo;
    m.burn = _e102.burn;
    m.optics = _e102.optics;
    m.scatter = _e102.scatter;
    m.ids = _e102.ids;
    m.ids2_ = _e102.ids2_;
    m.misc = _e102.misc;
    m.surface = _e102.surface;
    m.sss = _e102.sss;
    m.sss_color = _e102.sss_color;
    m.optics2_ = _e102.optics2_;
    m.pal0_ = _e102.pal0_;
    m.pal1_ = _e102.pal1_;
    m.pal2_ = _e102.pal2_;
    m.pal3_ = _e102.pal3_;
    m.accent = _e102.accent;
    m.flame = _e102.flame;
    let _e146 = c_3.temp;
    param_8 = _e146;
    let _e147 = tq_u0028_f1_u003b((&param_8));
    ti = _e147;
    let _e149 = c_3.mat;
    param_9 = _e149;
    let _e150 = kq_u0028_u1_u003b((&param_9));
    ki = _e150;
    let _e153 = m.thermo[0u];
    param_10 = _e153;
    param_11 = 256f;
    let _e154 = det_q_u0028_f1_u003b_f1_u003b((&param_10), (&param_11));
    ci = _e154;
    flux = 0i;
    ksum = 0i;
    i = 0i;
    loop {
        let _e155 = i;
        if (_e155 < 4i) {
            let _e157 = p_3;
            let _e158 = i;
            indexable = array<vec2<i32>, 4>(vec2<i32>(1i, 0i), vec2<i32>(-1i, 0i), vec2<i32>(0i, 1i), vec2<i32>(0i, -1i));
            let _e160 = indexable[_e158];
            q = (_e157 + _e160);
            let _e162 = q;
            param_12 = _e162;
            let _e163 = in_world_u0028_vi2_u003b((&param_12));
            if !(_e163) {
                continue;
            }
            let _e165 = q;
            let _e166 = textureLoad(cells_in, _e165, 0i);
            nq = _e166;
            let _e168 = nq[0u];
            param_13 = (_e168 & 255u);
            let _e170 = kq_u0028_u1_u003b((&param_13));
            kn = _e170;
            let _e171 = ki;
            let _e172 = kn;
            if ((_e171 + _e172) > 0i) {
                let _e175 = ki;
                let _e177 = kn;
                let _e179 = ki;
                let _e180 = kn;
                param_14 = ((2i * _e175) * _e177);
                param_15 = (_e179 + _e180);
                let _e182 = det_div_u0028_i1_u003b_i1_u003b((&param_14), (&param_15));
                local_1 = _e182;
            } else {
                local_1 = 0i;
            }
            let _e183 = local_1;
            kij = _e183;
            let _e184 = kij;
            let _e186 = nq[1u];
            param_16 = bitcast<f32>(_e186);
            let _e188 = tq_u0028_f1_u003b((&param_16));
            let _e189 = ti;
            let _e192 = flux;
            flux = (_e192 + (_e184 * (_e188 - _e189)));
            let _e194 = kij;
            let _e195 = ksum;
            ksum = (_e195 + _e194);
            continue;
        } else {
            break;
        }
        continuing {
            let _e197 = i;
            i = (_e197 + 1i);
        }
    }
    dt = 0i;
    let _e199 = ci;
    if (_e199 > 0i) {
        let _e201 = ksum;
        let _e203 = ci;
        if ((5i * _e201) > (18i * _e203)) {
            let _e206 = flux;
            let _e207 = ksum;
            qt = (_e206 / _e207);
            let _e209 = qt;
            let _e211 = flux;
            let _e212 = qt;
            let _e213 = ksum;
            let _e217 = ksum;
            dt = (((_e209 * 9i) + (((_e211 - (_e212 * _e213)) * 9i) / _e217)) / 20i);
        } else {
            let _e221 = ci;
            let _e223 = flux;
            param_17 = _e223;
            param_18 = (8i * _e221);
            let _e224 = det_div_u0028_i1_u003b_i1_u003b((&param_17), (&param_18));
            dt = _e224;
        }
    }
    let _e225 = dt;
    let _e226 = ti;
    ti = (_e226 + _e225);
    let _e230 = m.ids[0u];
    let _e231 = (_e230 == 0u);
    phi_468_ = _e231;
    if _e231 {
        let _e234 = m.ids[1u];
        phi_468_ = ((_e234 & 64u) == 0u);
    }
    let _e238 = phi_468_;
    if _e238 {
        let _e241 = pc.f0_[1u];
        param_19 = _e241;
        param_20 = 64f;
        let _e242 = det_q_u0028_f1_u003b_f1_u003b((&param_19), (&param_20));
        let _e243 = ti;
        let _e247 = pc.f0_[0u];
        param_21 = _e247;
        param_22 = 65536f;
        let _e248 = det_q_u0028_f1_u003b_f1_u003b((&param_21), (&param_22));
        param_23 = ((_e242 - _e243) * _e248);
        param_24 = 65536i;
        let _e250 = det_div_u0028_i1_u003b_i1_u003b((&param_23), (&param_24));
        let _e251 = ti;
        ti = (_e251 + _e250);
    }
    let _e253 = ti;
    c_3.temp = (f32(clamp(_e253, 64i, 576000i)) / 64f);
    let _e258 = p_3;
    param_25 = _e258;
    let _e259 = c_3;
    param_26 = _e259;
    store_cell_u0028_vi2_u003b_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_25), (&param_26));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
