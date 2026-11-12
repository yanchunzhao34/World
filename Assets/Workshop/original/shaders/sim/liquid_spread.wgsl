struct Rng {
    s: u32,
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
@group(0) @binding(2) 
var<storage> unnamed: Materials;
@group(0) @binding(0) 
var cells_in: texture_2d<u32>;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> sh_any: atomic<u32>;
var<workgroup> sh_row: array<vec4<u32>, 64>;
var<workgroup> sh_below: array<u32, 64>;
var<workgroup> sh_st: array<u32, 64>;
var<workgroup> sh_dens: array<f32, 64>;
var<workgroup> sh_visc: array<f32, 64>;
@group(0) @binding(1) 
var cells_out: texture_storage_2d<rgba32uint,write>;

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e57 = (*x);
    return (f32((_e57 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b(r: ptr<function, Rng>) -> u32 {
    let _e58 = (*r).s;
    let _e62 = (*r).s;
    (*r).s = (_e62 ^ (_e58 << bitcast<u32>(13u)));
    let _e66 = (*r).s;
    let _e70 = (*r).s;
    (*r).s = (_e70 ^ (_e66 >> bitcast<u32>(17u)));
    let _e74 = (*r).s;
    let _e78 = (*r).s;
    (*r).s = (_e78 ^ (_e74 << bitcast<u32>(5u)));
    let _e82 = (*r).s;
    return _e82;
}

fn rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b(r_1: ptr<function, Rng>) -> f32 {
    var param: Rng;
    var param_1: u32;

    let _e59 = (*r_1);
    param = _e59;
    let _e60 = rng_next_u0028_struct_u002d_Rng_u002d_u11_u003b((&param));
    let _e61 = param;
    (*r_1) = _e61;
    param_1 = _e60;
    let _e62 = u01_u0028_u1_u003b((&param_1));
    return _e62;
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e57 = (*v);
    (*v) = ((_e57 * vec3(1664525u)) + vec3(1013904223u));
    let _e63 = (*v)[1u];
    let _e65 = (*v)[2u];
    let _e68 = (*v)[0u];
    (*v)[0u] = (_e68 + (_e63 * _e65));
    let _e72 = (*v)[2u];
    let _e74 = (*v)[0u];
    let _e77 = (*v)[1u];
    (*v)[1u] = (_e77 + (_e72 * _e74));
    let _e81 = (*v)[0u];
    let _e83 = (*v)[1u];
    let _e86 = (*v)[2u];
    (*v)[2u] = (_e86 + (_e81 * _e83));
    let _e89 = (*v);
    let _e93 = (*v);
    (*v) = (_e93 ^ (_e89 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e96 = (*v)[1u];
    let _e98 = (*v)[2u];
    let _e101 = (*v)[0u];
    (*v)[0u] = (_e101 + (_e96 * _e98));
    let _e105 = (*v)[2u];
    let _e107 = (*v)[0u];
    let _e110 = (*v)[1u];
    (*v)[1u] = (_e110 + (_e105 * _e107));
    let _e114 = (*v)[0u];
    let _e116 = (*v)[1u];
    let _e119 = (*v)[2u];
    (*v)[2u] = (_e119 + (_e114 * _e116));
    let _e122 = (*v);
    return _e122;
}

fn rng_init_u0028_vu3_u003b(seed: ptr<function, vec3<u32>>) -> Rng {
    var r_2: Rng;
    var param_2: vec3<u32>;

    let _e59 = (*seed);
    param_2 = _e59;
    let _e60 = pcg3d_u0028_vu3_u003b((&param_2));
    r_2.s = (_e60.x | 1u);
    let _e64 = r_2;
    return _e64;
}

fn in_world_u0028_vi2_u003b(p: ptr<function, vec2<i32>>) -> bool {
    var phi_182_: bool;
    var phi_196_: bool;
    var phi_204_: bool;

    let _e58 = (*p)[0u];
    let _e59 = (_e58 >= 0i);
    phi_182_ = _e59;
    if _e59 {
        let _e61 = (*p)[1u];
        phi_182_ = (_e61 >= 0i);
    }
    let _e64 = phi_182_;
    phi_196_ = _e64;
    if _e64 {
        let _e66 = (*p)[0u];
        let _e69 = pc.i0_[0u];
        phi_196_ = (_e66 < _e69);
    }
    let _e72 = phi_196_;
    phi_204_ = _e72;
    if _e72 {
        let _e74 = (*p)[1u];
        let _e77 = pc.i0_[1u];
        phi_204_ = (_e74 < _e77);
    }
    let _e80 = phi_204_;
    return _e80;
}

fn state_in_u0028_vi2_u003b(p_1: ptr<function, vec2<i32>>) -> u32 {
    var param_3: vec2<i32>;

    let _e58 = (*p_1);
    param_3 = _e58;
    let _e59 = in_world_u0028_vi2_u003b((&param_3));
    if !(_e59) {
        return 3u;
    }
    let _e61 = (*p_1);
    let _e62 = textureLoad(cells_in, _e61, 0i);
    let _e69 = unnamed.mats[(_e62.x & 255u)].ids[0u];
    return _e69;
}

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var gid: i32;
    var li: i32;
    var segs: i32;
    var row: i32;
    var seg: i32;
    var x0_: i32;
    var x1_: i32;
    var n: i32;
    var p_2: vec2<i32>;
    var c: vec4<u32>;
    var below: u32;
    var param_4: vec2<i32>;
    var m: Material;
    var d: i32;
    var right: bool;
    var rng: Rng;
    var param_5: vec3<u32>;
    var start: i32;
    var local: i32;
    var stop: i32;
    var local_1: i32;
    var x_1: i32;
    var xi: i32;
    var visc: f32;
    var dens: f32;
    var param_6: Rng;
    var maxd: i32;
    var k: i32;
    var s: i32;
    var nx: i32;
    var tst: u32;
    var raw: vec4<u32>;
    var param_7: Rng;
    var qi: i32;
    var other: vec4<u32>;
    var ost: u32;
    var odens: f32;
    var ovisc: f32;
    var phi_443_: bool;
    var phi_585_: bool;
    var phi_631_: bool;
    var phi_640_: bool;

    let _e95 = gl_WorkGroupID_1[0u];
    gid = bitcast<i32>(_e95);
    let _e97 = gl_LocalInvocationIndex_1;
    li = bitcast<i32>(_e97);
    let _e101 = pc.i0_[0u];
    segs = ((_e101 / 64i) + 1i);
    let _e104 = gid;
    let _e105 = segs;
    row = (_e104 / _e105);
    let _e107 = gid;
    let _e108 = segs;
    seg = (_e107 % _e108 + select(0i, _e108, _e107 % _e108 != 0i && ((_e107 % _e108 < 0i) != (_e108 < 0i))));
    let _e116 = row;
    let _e119 = pc.i0_[1u];
    if (_e116 >= _e119) {
        return;
    }
    let _e121 = seg;
    let _e125 = pc.i1_[1u];
    x0_ = max(((_e121 * 64i) - _e125), 0i);
    let _e128 = seg;
    let _e132 = pc.i1_[1u];
    let _e137 = pc.i0_[0u];
    x1_ = min((((_e128 * 64i) - _e132) + 64i), _e137);
    let _e139 = x0_;
    let _e140 = x1_;
    if (_e139 >= _e140) {
        return;
    }
    let _e142 = x1_;
    let _e143 = x0_;
    n = (_e142 - _e143);
    let _e145 = li;
    if (_e145 == 0i) {
        atomicStore((&sh_any), 0u);
    }
    workgroupBarrier();
    let _e147 = li;
    let _e148 = n;
    if (_e147 < _e148) {
        let _e150 = x0_;
        let _e151 = li;
        let _e153 = row;
        p_2 = vec2<i32>((_e150 + _e151), _e153);
        let _e155 = p_2;
        let _e156 = textureLoad(cells_in, _e155, 0i);
        c = _e156;
        let _e157 = li;
        let _e158 = c;
        sh_row[_e157] = _e158;
        let _e160 = p_2;
        param_4 = (_e160 + vec2<i32>(0i, 1i));
        let _e162 = state_in_u0028_vi2_u003b((&param_4));
        below = _e162;
        let _e163 = li;
        let _e164 = below;
        sh_below[_e163] = _e164;
        let _e167 = c[0u];
        let _e171 = unnamed.mats[(_e167 & 255u)];
        m.color_a = _e171.color_a;
        m.color_b = _e171.color_b;
        m.emission = _e171.emission;
        m.phys = _e171.phys;
        m.thermo = _e171.thermo;
        m.burn = _e171.burn;
        m.optics = _e171.optics;
        m.scatter = _e171.scatter;
        m.ids = _e171.ids;
        m.ids2_ = _e171.ids2_;
        m.misc = _e171.misc;
        m.surface = _e171.surface;
        m.sss = _e171.sss;
        m.sss_color = _e171.sss_color;
        m.optics2_ = _e171.optics2_;
        m.pal0_ = _e171.pal0_;
        m.pal1_ = _e171.pal1_;
        m.pal2_ = _e171.pal2_;
        m.pal3_ = _e171.pal3_;
        m.accent = _e171.accent;
        m.flame = _e171.flame;
        let _e214 = li;
        let _e217 = m.ids[0u];
        sh_st[_e214] = _e217;
        let _e219 = li;
        let _e222 = m.phys[0u];
        sh_dens[_e219] = _e222;
        let _e224 = li;
        let _e227 = m.phys[1u];
        sh_visc[_e224] = _e227;
        let _e231 = m.ids[0u];
        let _e233 = below;
        if ((_e231 == 1u) && (_e233 != 0u)) {
            let _e236 = atomicOr((&sh_any), 1u);
        }
    }
    workgroupBarrier();
    let _e237 = li;
    let _e238 = (_e237 == 0i);
    phi_443_ = _e238;
    if _e238 {
        let _e239 = atomicLoad((&sh_any));
        phi_443_ = (_e239 != 0u);
    }
    let _e242 = phi_443_;
    if _e242 {
        let _e245 = pc.i1_[0u];
        d = _e245;
        let _e246 = d;
        right = (_e246 > 0i);
        let _e248 = row;
        let _e250 = seg;
        let _e254 = pc.i0_[2u];
        param_5 = vec3<u32>(bitcast<u32>(_e248), bitcast<u32>(_e250), ((bitcast<u32>(_e254) * 3u) + 1u));
        let _e259 = rng_init_u0028_vu3_u003b((&param_5));
        rng = _e259;
        let _e260 = right;
        if _e260 {
            let _e261 = x1_;
            local = (_e261 - 1i);
        } else {
            let _e263 = x0_;
            local = _e263;
        }
        let _e264 = local;
        start = _e264;
        let _e265 = right;
        if _e265 {
            let _e266 = x0_;
            local_1 = (_e266 - 1i);
        } else {
            let _e268 = x1_;
            local_1 = _e268;
        }
        let _e269 = local_1;
        stop = _e269;
        let _e270 = start;
        x_1 = _e270;
        loop {
            let _e271 = x_1;
            let _e272 = stop;
            if (_e271 != _e272) {
                let _e274 = x_1;
                let _e275 = x0_;
                xi = (_e274 - _e275);
                let _e277 = xi;
                let _e279 = sh_st[_e277];
                if (_e279 != 1u) {
                    continue;
                }
                let _e281 = xi;
                let _e283 = sh_below[_e281];
                if (_e283 == 0u) {
                    continue;
                }
                let _e285 = xi;
                let _e287 = sh_visc[_e285];
                visc = _e287;
                let _e288 = xi;
                let _e290 = sh_dens[_e288];
                dens = _e290;
                let _e291 = rng;
                param_6 = _e291;
                let _e292 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_6));
                let _e293 = param_6;
                rng = _e293;
                let _e294 = visc;
                if (_e292 < _e294) {
                    continue;
                }
                let _e298 = pc.i1_[2u];
                let _e300 = visc;
                maxd = max(1i, i32((f32(_e298) * (1f - _e300))));
                k = 0i;
                s = 1i;
                loop {
                    let _e305 = s;
                    let _e306 = maxd;
                    if (_e305 <= _e306) {
                        let _e308 = x_1;
                        let _e309 = d;
                        let _e310 = s;
                        nx = (_e308 + (_e309 * _e310));
                        let _e313 = nx;
                        let _e314 = x0_;
                        let _e316 = nx;
                        let _e317 = x1_;
                        if ((_e313 < _e314) || (_e316 >= _e317)) {
                            break;
                        }
                        let _e320 = nx;
                        let _e321 = x0_;
                        let _e324 = sh_st[(_e320 - _e321)];
                        tst = _e324;
                        let _e325 = tst;
                        let _e326 = (_e325 > 1u);
                        phi_585_ = _e326;
                        if !(_e326) {
                            let _e328 = nx;
                            let _e329 = x0_;
                            let _e332 = sh_dens[(_e328 - _e329)];
                            let _e333 = dens;
                            phi_585_ = (_e332 >= _e333);
                        }
                        let _e336 = phi_585_;
                        if _e336 {
                            break;
                        }
                        let _e337 = s;
                        k = _e337;
                        let _e338 = tst;
                        if (_e338 == 1u) {
                            break;
                        }
                        let _e340 = nx;
                        let _e341 = x0_;
                        let _e344 = sh_below[(_e340 - _e341)];
                        if (_e344 == 0u) {
                            break;
                        }
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e346 = s;
                        s = (_e346 + 1i);
                    }
                }
                let _e348 = k;
                if (_e348 == 0i) {
                    continue;
                }
                let _e350 = xi;
                let _e352 = sh_row[_e350];
                raw = _e352;
                let _e353 = x_1;
                let _e354 = d;
                let _e355 = k;
                let _e358 = x0_;
                let _e361 = sh_below[((_e353 + (_e354 * _e355)) - _e358)];
                let _e362 = (_e361 != 0u);
                phi_631_ = _e362;
                if _e362 {
                    let _e364 = raw[3u];
                    phi_631_ = ((_e364 & 255u) == 0u);
                }
                let _e368 = phi_631_;
                phi_640_ = _e368;
                if _e368 {
                    let _e369 = rng;
                    param_7 = _e369;
                    let _e370 = rng_f_u0028_struct_u002d_Rng_u002d_u11_u003b((&param_7));
                    let _e371 = param_7;
                    rng = _e371;
                    phi_640_ = (_e370 > 0.01f);
                }
                let _e374 = phi_640_;
                if _e374 {
                    continue;
                }
                let _e376 = raw[3u];
                raw[3u] = ((_e376 & 4294967040u) | 255u);
                let _e380 = right;
                if _e380 {
                    let _e382 = raw[0u];
                    raw[0u] = (_e382 | 131072u);
                } else {
                    let _e386 = raw[0u];
                    raw[0u] = (_e386 & 4294836223u);
                }
                let _e389 = x_1;
                let _e390 = d;
                let _e391 = k;
                let _e394 = x0_;
                qi = ((_e389 + (_e390 * _e391)) - _e394);
                let _e396 = qi;
                let _e398 = sh_row[_e396];
                other = _e398;
                let _e399 = qi;
                let _e400 = raw;
                sh_row[_e399] = _e400;
                let _e402 = xi;
                let _e403 = other;
                sh_row[_e402] = _e403;
                let _e405 = qi;
                let _e407 = sh_st[_e405];
                ost = _e407;
                let _e408 = qi;
                let _e410 = sh_dens[_e408];
                odens = _e410;
                let _e411 = qi;
                let _e413 = sh_visc[_e411];
                ovisc = _e413;
                let _e414 = qi;
                sh_st[_e414] = 1u;
                let _e416 = qi;
                let _e417 = dens;
                sh_dens[_e416] = _e417;
                let _e419 = qi;
                let _e420 = visc;
                sh_visc[_e419] = _e420;
                let _e422 = xi;
                let _e423 = ost;
                sh_st[_e422] = _e423;
                let _e425 = xi;
                let _e426 = odens;
                sh_dens[_e425] = _e426;
                let _e428 = xi;
                let _e429 = ovisc;
                sh_visc[_e428] = _e429;
                continue;
            } else {
                break;
            }
            continuing {
                let _e431 = d;
                let _e432 = x_1;
                x_1 = (_e432 - _e431);
            }
        }
    }
    workgroupBarrier();
    let _e434 = li;
    let _e435 = n;
    if (_e434 < _e435) {
        let _e437 = x0_;
        let _e438 = li;
        let _e440 = row;
        let _e442 = li;
        let _e444 = sh_row[_e442];
        textureStore(cells_out, vec2<i32>((_e437 + _e438), _e440), _e444);
    }
    return;
}

@compute @workgroup_size(64, 1, 1) 
fn main(@builtin(workgroup_id) gl_WorkGroupID: vec3<u32>, @builtin(local_invocation_index) gl_LocalInvocationIndex: u32) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1(gl_WorkGroupID);
}
