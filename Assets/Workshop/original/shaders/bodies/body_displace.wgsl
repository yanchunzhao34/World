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

struct Displaced {
    disp_count: u32,
    disp_pad: array<u32, 3>,
    disp: array<vec4<u32>>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
@group(3) @binding(0) 
var cells_r: texture_2d<u32>;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(0) @binding(4) 
var cells_pre: texture_2d<u32>;
@group(0) @binding(0) 
var cells: texture_storage_2d<rgba32uint,write>;
var<private> gl_LocalInvocationID_1: vec3<u32>;
var<workgroup> sh_n: array<u32, 256>;
@group(0) @binding(2) 
var<storage, read_write> unnamed_1: Displaced;

fn unpack_cell_u0028_vu4_u003b(v: ptr<function, vec4<u32>>) -> Cell {
    var c: Cell;

    let _e36 = (*v)[0u];
    c.mat = (_e36 & 255u);
    let _e40 = (*v)[0u];
    c.variant = ((_e40 >> bitcast<u32>(8u)) & 255u);
    let _e46 = (*v)[0u];
    c.flags = (_e46 >> bitcast<u32>(16u));
    let _e51 = (*v)[1u];
    c.temp = bitcast<f32>(_e51);
    let _e55 = (*v)[2u];
    c.life = (_e55 & 65535u);
    let _e59 = (*v)[2u];
    c.aux = (_e59 >> bitcast<u32>(16u));
    let _e64 = (*v)[3u];
    c.extra = _e64;
    let _e66 = c;
    return _e66;
}

fn in_world_u0028_vi2_u003b(p: ptr<function, vec2<i32>>) -> bool {
    var phi_43_: bool;
    var phi_57_: bool;
    var phi_65_: bool;

    let _e35 = (*p)[0u];
    let _e36 = (_e35 >= 0i);
    phi_43_ = _e36;
    if _e36 {
        let _e38 = (*p)[1u];
        phi_43_ = (_e38 >= 0i);
    }
    let _e41 = phi_43_;
    phi_57_ = _e41;
    if _e41 {
        let _e43 = (*p)[0u];
        let _e46 = pc.i0_[0u];
        phi_57_ = (_e43 < _e46);
    }
    let _e49 = phi_57_;
    phi_65_ = _e49;
    if _e49 {
        let _e51 = (*p)[1u];
        let _e54 = pc.i0_[1u];
        phi_65_ = (_e51 < _e54);
    }
    let _e57 = phi_65_;
    return _e57;
}

fn try_put_u0028_vi2_u003b_vu4_u003b(q: ptr<function, vec2<i32>>, v_1: ptr<function, vec4<u32>>) -> bool {
    var param: vec2<i32>;
    var tc: Cell;
    var param_1: vec4<u32>;
    var phi_174_: bool;

    let _e38 = (*q);
    param = _e38;
    let _e39 = in_world_u0028_vi2_u003b((&param));
    if !(_e39) {
        return false;
    }
    let _e41 = (*q);
    let _e42 = textureLoad(cells_r, _e41, 0i);
    param_1 = _e42;
    let _e43 = unpack_cell_u0028_vu4_u003b((&param_1));
    tc = _e43;
    let _e45 = tc.mat;
    let _e50 = unnamed.mats[_e45].ids[0u];
    let _e51 = (_e50 != 0u);
    phi_174_ = _e51;
    if !(_e51) {
        let _e54 = tc.flags;
        phi_174_ = ((_e54 & 64u) != 0u);
    }
    let _e58 = phi_174_;
    if _e58 {
        return false;
    }
    let _e59 = (*q);
    let _e60 = (*v_1);
    textureStore(cells, _e59, _e60);
    return true;
}

fn displaced_u0028_vi2_u003b(q_1: ptr<function, vec2<i32>>) -> bool {
    var param_2: vec4<u32>;

    let _e35 = (*q_1);
    let _e36 = textureLoad(cells_r, _e35, 0i);
    param_2 = _e36;
    let _e37 = unpack_cell_u0028_vu4_u003b((&param_2));
    if ((_e37.flags & 64u) == 0u) {
        return false;
    }
    let _e41 = (*q_1);
    let _e42 = textureLoad(cells_pre, _e41, 0i);
    let _e49 = unnamed.mats[(_e42.x & 255u)].ids[0u];
    return (_e49 == 1u);
}

fn main_1() {
    var t: u32;
    var total: u32;
    var per: u32;
    var i0_: u32;
    var i1_: u32;
    var n: u32;
    var i: u32;
    var param_3: vec2<i32>;
    var base: u32;
    var k: u32;
    var i_1: u32;
    var q_2: vec2<i32>;
    var param_4: vec2<i32>;
    var count: u32;
    var k_1: u32;
    var i_2: u32;
    var o: vec2<i32>;
    var v_2: vec4<u32>;
    var done: bool;
    var r: i32;
    var dy: i32;
    var k_2: i32;
    var dx: i32;
    var local: i32;
    var param_5: vec2<i32>;
    var param_6: vec4<u32>;
    var param_7: vec2<i32>;
    var param_8: vec4<u32>;
    var param_9: vec2<i32>;
    var param_10: vec4<u32>;
    var phi_464_: bool;

    let _e64 = gl_LocalInvocationID_1[0u];
    t = _e64;
    let _e67 = pc.i0_[0u];
    let _e70 = pc.i0_[1u];
    total = bitcast<u32>((_e67 * _e70));
    let _e73 = total;
    per = ((_e73 + 255u) / 256u);
    let _e76 = t;
    let _e77 = per;
    i0_ = (_e76 * _e77);
    let _e79 = i0_;
    let _e80 = per;
    let _e82 = total;
    i1_ = min((_e79 + _e80), _e82);
    n = 0u;
    let _e84 = i0_;
    i = _e84;
    loop {
        let _e85 = i;
        let _e86 = i1_;
        if (_e85 < _e86) {
            let _e88 = i;
            let _e91 = pc.i0_[0u];
            let _e95 = i;
            let _e98 = pc.i0_[0u];
            param_3 = vec2<i32>(bitcast<i32>((_e88 % bitcast<u32>(_e91))), bitcast<i32>((_e95 / bitcast<u32>(_e98))));
            let _e103 = displaced_u0028_vi2_u003b((&param_3));
            if _e103 {
                let _e104 = n;
                n = (_e104 + bitcast<u32>(1i));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e107 = i;
            i = (_e107 + bitcast<u32>(1i));
        }
    }
    let _e110 = t;
    let _e111 = n;
    sh_n[_e110] = _e111;
    workgroupBarrier();
    base = 0u;
    k = 0u;
    loop {
        let _e113 = k;
        let _e114 = t;
        if (_e113 < _e114) {
            let _e116 = k;
            let _e118 = sh_n[_e116];
            let _e119 = base;
            base = (_e119 + _e118);
            continue;
        } else {
            break;
        }
        continuing {
            let _e121 = k;
            k = (_e121 + bitcast<u32>(1i));
        }
    }
    let _e124 = i0_;
    i_1 = _e124;
    loop {
        let _e125 = i_1;
        let _e126 = i1_;
        let _e128 = base;
        if ((_e125 < _e126) && (_e128 < 8192u)) {
            let _e131 = i_1;
            let _e134 = pc.i0_[0u];
            let _e138 = i_1;
            let _e141 = pc.i0_[0u];
            q_2 = vec2<i32>(bitcast<i32>((_e131 % bitcast<u32>(_e134))), bitcast<i32>((_e138 / bitcast<u32>(_e141))));
            let _e146 = q_2;
            param_4 = _e146;
            let _e147 = displaced_u0028_vi2_u003b((&param_4));
            if _e147 {
                let _e148 = base;
                base = (_e148 + bitcast<u32>(1i));
                let _e152 = q_2[0u];
                let _e155 = q_2[1u];
                unnamed_1.disp[_e148] = vec4<u32>(bitcast<u32>(_e152), bitcast<u32>(_e155), 0u, 0u);
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e160 = i_1;
            i_1 = (_e160 + bitcast<u32>(1i));
        }
    }
    storageBarrier();
    workgroupBarrier();
    let _e163 = t;
    if (_e163 != 0u) {
        return;
    }
    count = 0u;
    k_1 = 0u;
    loop {
        let _e165 = k_1;
        if (_e165 < 256u) {
            let _e167 = k_1;
            let _e169 = sh_n[_e167];
            let _e170 = count;
            count = (_e170 + _e169);
            continue;
        } else {
            break;
        }
        continuing {
            let _e172 = k_1;
            k_1 = (_e172 + bitcast<u32>(1i));
        }
    }
    let _e175 = count;
    count = min(_e175, 8192u);
    i_2 = 0u;
    loop {
        let _e177 = i_2;
        let _e178 = count;
        if (_e177 < _e178) {
            let _e180 = i_2;
            let _e183 = unnamed_1.disp[_e180];
            o = bitcast<vec2<i32>>(_e183.xy);
            let _e186 = o;
            let _e187 = textureLoad(cells_pre, _e186, 0i);
            v_2 = _e187;
            done = false;
            r = 1i;
            loop {
                let _e188 = r;
                let _e190 = done;
                if ((_e188 <= 14i) && !(_e190)) {
                    let _e193 = r;
                    dy = -(_e193);
                    loop {
                        let _e195 = dy;
                        let _e196 = r;
                        let _e198 = done;
                        if ((_e195 <= _e196) && !(_e198)) {
                            let _e201 = dy;
                            let _e203 = r;
                            if (abs(_e201) == _e203) {
                                k_2 = 0i;
                                loop {
                                    let _e205 = k_2;
                                    let _e206 = r;
                                    let _e209 = done;
                                    if ((_e205 <= (2i * _e206)) && !(_e209)) {
                                        let _e212 = k_2;
                                        if ((_e212 & 1i) == 0i) {
                                            let _e215 = k_2;
                                            local = (_e215 / 2i);
                                        } else {
                                            let _e217 = k_2;
                                            local = (-((_e217 + 1i)) / 2i);
                                        }
                                        let _e221 = local;
                                        dx = _e221;
                                        let _e222 = o;
                                        let _e223 = dx;
                                        let _e224 = dy;
                                        param_5 = (_e222 + vec2<i32>(_e223, _e224));
                                        let _e227 = v_2;
                                        param_6 = _e227;
                                        let _e228 = try_put_u0028_vi2_u003b_vu4_u003b((&param_5), (&param_6));
                                        done = _e228;
                                        continue;
                                    } else {
                                        break;
                                    }
                                    continuing {
                                        let _e229 = k_2;
                                        k_2 = (_e229 + 1i);
                                    }
                                }
                            } else {
                                let _e231 = o;
                                let _e232 = r;
                                let _e234 = dy;
                                param_7 = (_e231 + vec2<i32>(-(_e232), _e234));
                                let _e237 = v_2;
                                param_8 = _e237;
                                let _e238 = try_put_u0028_vi2_u003b_vu4_u003b((&param_7), (&param_8));
                                phi_464_ = _e238;
                                if !(_e238) {
                                    let _e240 = o;
                                    let _e241 = r;
                                    let _e242 = dy;
                                    param_9 = (_e240 + vec2<i32>(_e241, _e242));
                                    let _e245 = v_2;
                                    param_10 = _e245;
                                    let _e246 = try_put_u0028_vi2_u003b_vu4_u003b((&param_9), (&param_10));
                                    phi_464_ = _e246;
                                }
                                let _e248 = phi_464_;
                                done = _e248;
                            }
                            continue;
                        } else {
                            break;
                        }
                        continuing {
                            let _e249 = dy;
                            dy = (_e249 + 1i);
                        }
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e251 = r;
                    r = (_e251 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e253 = i_2;
            i_2 = (_e253 + bitcast<u32>(1i));
        }
    }
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(local_invocation_id) gl_LocalInvocationID: vec3<u32>) {
    gl_LocalInvocationID_1 = gl_LocalInvocationID;
    main_1();
}
