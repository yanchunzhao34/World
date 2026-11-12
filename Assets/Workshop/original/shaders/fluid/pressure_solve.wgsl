struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

var<private> g_size: vec2<i32>;
var<workgroup> ssolid: array<atomic<u32>, 320>;
@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> sp: array<f32, 10240>;
@group(0) @binding(0) 
var p_in: texture_2d<f32>;
@group(0) @binding(2) 
var div_in: texture_2d<f32>;
@group(0) @binding(3) 
var vel: texture_2d<f32>;
@group(0) @binding(1) 
var p_out: texture_storage_2d<r32float,write>;

fn open_at_u0028_vi2_u003b(q: ptr<function, vec2<i32>>) -> bool {
    var j: i32;
    var phi_29_: bool;

    let _e36 = (*q);
    let _e38 = any((_e36 < vec2<i32>(0i, 0i)));
    phi_29_ = _e38;
    if !(_e38) {
        let _e40 = (*q);
        let _e41 = g_size;
        phi_29_ = any((_e40 >= _e41));
    }
    let _e45 = phi_29_;
    if _e45 {
        return false;
    }
    let _e47 = (*q)[1u];
    let _e49 = g_size[0u];
    let _e52 = (*q)[0u];
    j = ((_e47 * _e49) + _e52);
    let _e54 = j;
    let _e58 = atomicLoad((&ssolid[(_e54 >> bitcast<u32>(5i))]));
    let _e59 = j;
    return ((_e58 & (1u << bitcast<u32>(bitcast<u32>((_e59 & 31i))))) == 0u);
}

fn main_1() {
    var n: i32;
    var W: i32;
    var li: i32;
    var k: i32;
    var j_1: i32;
    var dv: array<f32, 10>;
    var q_1: vec2<i32>;
    var k_1: i32;
    var j_2: i32;
    var nb: array<u32, 10>;
    var p: vec2<i32>;
    var param: vec2<i32>;
    var param_1: vec2<i32>;
    var param_2: vec2<i32>;
    var param_3: vec2<i32>;
    var it: i32;
    var k_2: i32;
    var j_3: i32;
    var nv: array<f32, 10>;
    var c: f32;
    var m: u32;
    var s: f32;
    var local: f32;
    var local_1: f32;
    var local_2: f32;
    var local_3: f32;
    var k_3: i32;
    var j_4: i32;
    var k_4: i32;
    var j_5: i32;

    let _e65 = pc.i0_;
    g_size = _e65.xy;
    let _e68 = g_size[0u];
    let _e70 = g_size[1u];
    n = (_e68 * _e70);
    let _e73 = g_size[0u];
    W = _e73;
    let _e74 = gl_LocalInvocationIndex_1;
    li = bitcast<i32>(_e74);
    let _e76 = li;
    if (_e76 < 320i) {
        let _e78 = li;
        atomicStore((&ssolid[_e78]), 0u);
    }
    workgroupBarrier();
    k = 0i;
    loop {
        let _e80 = k;
        if (_e80 < 10i) {
            let _e82 = li;
            let _e83 = k;
            j_1 = (_e82 + (_e83 * 1024i));
            let _e86 = k;
            dv[_e86] = 0f;
            let _e88 = j_1;
            let _e89 = n;
            if (_e88 >= _e89) {
                continue;
            }
            let _e91 = j_1;
            let _e92 = W;
            let _e100 = j_1;
            let _e101 = W;
            q_1 = vec2<i32>((_e91 % _e92 + select(0i, _e92, _e91 % _e92 != 0i && ((_e91 % _e92 < 0i) != (_e92 < 0i)))), (_e100 / _e101));
            let _e104 = j_1;
            let _e105 = q_1;
            let _e106 = textureLoad(p_in, _e105, 0i);
            sp[_e104] = _e106.x;
            let _e109 = k;
            let _e110 = q_1;
            let _e111 = textureLoad(div_in, _e110, 0i);
            dv[_e109] = _e111.x;
            let _e114 = q_1;
            let _e115 = textureLoad(vel, _e114, 0i);
            if (_e115.z > 0.6f) {
                let _e118 = j_1;
                let _e122 = j_1;
                let _e127 = atomicOr((&ssolid[(_e118 >> bitcast<u32>(5i))]), (1u << bitcast<u32>(bitcast<u32>((_e122 & 31i)))));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e128 = k;
            k = (_e128 + 1i);
        }
    }
    workgroupBarrier();
    k_1 = 0i;
    loop {
        let _e130 = k_1;
        if (_e130 < 10i) {
            let _e132 = li;
            let _e133 = k_1;
            j_2 = (_e132 + (_e133 * 1024i));
            let _e136 = k_1;
            nb[_e136] = 0u;
            let _e138 = j_2;
            let _e139 = n;
            if (_e138 >= _e139) {
                continue;
            }
            let _e141 = j_2;
            let _e142 = W;
            let _e150 = j_2;
            let _e151 = W;
            p = vec2<i32>((_e141 % _e142 + select(0i, _e142, _e141 % _e142 != 0i && ((_e141 % _e142 < 0i) != (_e142 < 0i)))), (_e150 / _e151));
            let _e154 = k_1;
            let _e155 = p;
            param = (_e155 + vec2<i32>(1i, 0i));
            let _e157 = open_at_u0028_vi2_u003b((&param));
            let _e159 = p;
            param_1 = (_e159 - vec2<i32>(1i, 0i));
            let _e161 = open_at_u0028_vi2_u003b((&param_1));
            let _e164 = p;
            param_2 = (_e164 + vec2<i32>(0i, 1i));
            let _e166 = open_at_u0028_vi2_u003b((&param_2));
            let _e169 = p;
            param_3 = (_e169 - vec2<i32>(0i, 1i));
            let _e171 = open_at_u0028_vi2_u003b((&param_3));
            nb[_e154] = (((select(0u, 1u, _e157) | select(0u, 2u, _e161)) | select(0u, 4u, _e166)) | select(0u, 8u, _e171));
            continue;
        } else {
            break;
        }
        continuing {
            let _e175 = k_1;
            k_1 = (_e175 + 1i);
        }
    }
    it = 0i;
    loop {
        let _e177 = it;
        let _e180 = pc.i1_[0u];
        if (_e177 < _e180) {
            k_2 = 0i;
            loop {
                let _e182 = k_2;
                if (_e182 < 10i) {
                    let _e184 = li;
                    let _e185 = k_2;
                    j_3 = (_e184 + (_e185 * 1024i));
                    let _e188 = k_2;
                    nv[_e188] = 0f;
                    let _e190 = j_3;
                    let _e191 = n;
                    if (_e190 >= _e191) {
                        continue;
                    }
                    let _e193 = j_3;
                    let _e195 = sp[_e193];
                    c = _e195;
                    let _e196 = k_2;
                    let _e198 = nb[_e196];
                    m = _e198;
                    let _e199 = m;
                    if ((_e199 & 1u) != 0u) {
                        let _e202 = j_3;
                        let _e205 = sp[(_e202 + 1i)];
                        local = _e205;
                    } else {
                        let _e206 = c;
                        local = _e206;
                    }
                    let _e207 = local;
                    let _e208 = m;
                    if ((_e208 & 2u) != 0u) {
                        let _e211 = j_3;
                        let _e214 = sp[(_e211 - 1i)];
                        local_1 = _e214;
                    } else {
                        let _e215 = c;
                        local_1 = _e215;
                    }
                    let _e216 = local_1;
                    let _e218 = m;
                    if ((_e218 & 4u) != 0u) {
                        let _e221 = j_3;
                        let _e222 = W;
                        let _e225 = sp[(_e221 + _e222)];
                        local_2 = _e225;
                    } else {
                        let _e226 = c;
                        local_2 = _e226;
                    }
                    let _e227 = local_2;
                    let _e229 = m;
                    if ((_e229 & 8u) != 0u) {
                        let _e232 = j_3;
                        let _e233 = W;
                        let _e236 = sp[(_e232 - _e233)];
                        local_3 = _e236;
                    } else {
                        let _e237 = c;
                        local_3 = _e237;
                    }
                    let _e238 = local_3;
                    s = (((_e207 + _e216) + _e227) + _e238);
                    let _e240 = k_2;
                    let _e241 = s;
                    let _e242 = k_2;
                    let _e244 = dv[_e242];
                    nv[_e240] = ((_e241 - _e244) * 0.25f);
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e248 = k_2;
                    k_2 = (_e248 + 1i);
                }
            }
            workgroupBarrier();
            k_3 = 0i;
            loop {
                let _e250 = k_3;
                if (_e250 < 10i) {
                    let _e252 = li;
                    let _e253 = k_3;
                    j_4 = (_e252 + (_e253 * 1024i));
                    let _e256 = j_4;
                    let _e257 = n;
                    if (_e256 < _e257) {
                        let _e259 = j_4;
                        let _e260 = k_3;
                        let _e262 = nv[_e260];
                        sp[_e259] = _e262;
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e264 = k_3;
                    k_3 = (_e264 + 1i);
                }
            }
            workgroupBarrier();
            continue;
        } else {
            break;
        }
        continuing {
            let _e266 = it;
            it = (_e266 + 1i);
        }
    }
    k_4 = 0i;
    loop {
        let _e268 = k_4;
        if (_e268 < 10i) {
            let _e270 = li;
            let _e271 = k_4;
            j_5 = (_e270 + (_e271 * 1024i));
            let _e274 = j_5;
            let _e275 = n;
            if (_e274 < _e275) {
                let _e277 = j_5;
                let _e278 = W;
                let _e286 = j_5;
                let _e287 = W;
                let _e290 = j_5;
                let _e292 = sp[_e290];
                textureStore(p_out, vec2<i32>((_e277 % _e278 + select(0i, _e278, _e277 % _e278 != 0i && ((_e277 % _e278 < 0i) != (_e278 < 0i)))), (_e286 / _e287)), vec4(_e292));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e294 = k_4;
            k_4 = (_e294 + 1i);
        }
    }
    return;
}

@compute @workgroup_size(1024, 1, 1) 
fn main(@builtin(local_invocation_index) gl_LocalInvocationIndex: u32) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1();
}
