struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct LastSent {
    last_sent: array<u32>,
}

struct Pending {
    pending: array<u32>,
}

struct Out {
    out_data: array<u32>,
}

struct Out_1 {
    out_data: array<atomic<u32>>,
}

var<private> gl_LocalInvocationIndex_1: u32;
@group(1) @binding(0) 
var<uniform> pc: Params;
var<workgroup> sh_changed: atomic<u32>;
var<workgroup> sh_rank: atomic<u32>;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
var<private> gl_LocalInvocationID_1: vec3<u32>;
@group(0) @binding(2) 
var<storage, read_write> unnamed: LastSent;
@group(0) @binding(1) 
var medium: texture_2d<f32>;
@group(0) @binding(3) 
var<storage, read_write> unnamed_1: Pending;
@group(0) @binding(4) 
var<storage, read_write> unnamed_2: Out_1;

fn near_cursor_u0028_vf2_u003b_vf2_u003b(c: ptr<function, vec2<f32>>, cur: ptr<function, vec2<f32>>) -> bool {
    var phi_78_: bool;

    let _e49 = (*cur)[0u];
    let _e50 = (_e49 >= 0f);
    phi_78_ = _e50;
    if _e50 {
        let _e51 = (*c);
        let _e52 = (*cur);
        phi_78_ = all((abs((_e51 - _e52)) <= vec2<f32>(24f, 24f)));
    }
    let _e58 = phi_78_;
    return _e58;
}

fn medium_changed_u0028_u1_u003b_u1_u003b(now: ptr<function, u32>, before: ptr<function, u32>) -> bool {
    var a: vec2<f32>;
    var b: vec2<f32>;

    let _e50 = (*now);
    a = unpack2x16float(_e50);
    let _e52 = (*before);
    b = unpack2x16float(_e52);
    let _e54 = a;
    let _e55 = b;
    let _e58 = a;
    return any((abs((_e54 - _e55)) > (vec2<f32>(0.01f, 0.01f) + (abs(_e58) * 0.02f))));
}

fn web_isinf_u0028_f1_u003b(x: ptr<function, f32>) -> bool {
    let _e47 = (*x);
    return (abs(_e47) > 340000000000000000000000000000000000000f);
}

fn web_isnan_u0028_f1_u003b(x_1: ptr<function, f32>) -> bool {
    let _e47 = (*x_1);
    let _e48 = (*x_1);
    return (_e47 != _e48);
}

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var li: u32;
    var chunk: i32;
    var count: u32;
    var cxy: vec2<i32>;
    var mode: u32;
    var all_raw: bool;
    var write_: bool;
    var cap: u32;
    var base_last: u32;
    var c_1: vec4<u32>;
    var o: vec4<u32>;
    var swept: bool;
    var exact: bool;
    var snd: vec4<u32>;
    var t: f32;
    var to: f32;
    var local: f32;
    var param: f32;
    var param_1: f32;
    var life: i32;
    var lo: i32;
    var changed: bool;
    var m0_: u32;
    var m1_: u32;
    var l0_: u32;
    var l1_: u32;
    var m: vec4<f32>;
    var param_2: u32;
    var param_3: u32;
    var param_4: u32;
    var param_5: u32;
    var centre: vec2<f32>;
    var near: bool;
    var param_6: vec2<f32>;
    var param_7: vec2<f32>;
    var param_8: vec2<f32>;
    var param_9: vec2<f32>;
    var param_10: vec2<f32>;
    var param_11: vec2<f32>;
    var param_12: vec2<f32>;
    var param_13: vec2<f32>;
    var rot: u32;
    var key: u32;
    var local_1: u32;
    var i: u32;
    var k: u32;
    var goes: bool;
    var slot: u32;
    var base: u32;
    var x_2: vec4<u32>;
    var local_2: vec4<u32>;
    var local_3: u32;
    var local_4: u32;
    var phi_282_: bool;
    var phi_327_: bool;
    var phi_355_: bool;
    var phi_430_: bool;
    var phi_447_: bool;
    var phi_490_: bool;
    var phi_502_: bool;
    var phi_513_: bool;
    var phi_605_: bool;

    let _e99 = gl_LocalInvocationIndex_1;
    li = _e99;
    let _e101 = gl_WorkGroupID_1[0u];
    chunk = bitcast<i32>(_e101);
    let _e105 = pc.i0_[3u];
    count = bitcast<u32>(_e105);
    let _e107 = chunk;
    let _e110 = pc.i0_[2u];
    let _e118 = chunk;
    let _e121 = pc.i0_[2u];
    cxy = vec2<i32>((_e107 % _e110 + select(0i, _e110, _e107 % _e110 != 0i && ((_e107 % _e110 < 0i) != (_e110 < 0i)))), (_e118 / _e121));
    let _e126 = pc.i1_[1u];
    mode = bitcast<u32>(_e126);
    let _e128 = mode;
    all_raw = ((_e128 & 1u) != 0u);
    let _e131 = mode;
    write_ = ((_e131 & 4u) != 0u);
    let _e134 = mode;
    cap = (_e134 >> bitcast<u32>(4u));
    let _e137 = li;
    if (_e137 == 0u) {
        atomicStore((&sh_changed), 0u);
        atomicStore((&sh_rank), 0u);
    }
    workgroupBarrier();
    let _e139 = chunk;
    base_last = (bitcast<u32>(_e139) * 1152u);
    let _e142 = cxy;
    let _e145 = gl_LocalInvocationID_1;
    let _e149 = textureLoad(cells, ((_e142 * vec2(16i)) + bitcast<vec2<i32>>(_e145.xy)), 0i);
    c_1 = _e149;
    let _e150 = base_last;
    let _e151 = li;
    let _e156 = unnamed.last_sent[(_e150 + (_e151 * 4u))];
    let _e157 = base_last;
    let _e158 = li;
    let _e164 = unnamed.last_sent[((_e157 + (_e158 * 4u)) + 1u)];
    let _e165 = base_last;
    let _e166 = li;
    let _e172 = unnamed.last_sent[((_e165 + (_e166 * 4u)) + 2u)];
    let _e173 = base_last;
    let _e174 = li;
    let _e180 = unnamed.last_sent[((_e173 + (_e174 * 4u)) + 3u)];
    o = vec4<u32>(_e156, _e164, _e172, _e180);
    let _e182 = chunk;
    let _e184 = count;
    let _e188 = pc.i1_[3u];
    let _e191 = count;
    swept = ((((bitcast<u32>(_e182) + _e184) - bitcast<u32>(_e188)) % _e191) < 2u);
    let _e194 = mode;
    let _e197 = all_raw;
    exact = (((_e194 & 2u) != 0u) || _e197);
    let _e199 = c_1;
    snd = _e199;
    let _e200 = exact;
    if !(_e200) {
        let _e203 = c_1[0u];
        let _e205 = o[0u];
        if (((_e203 ^ _e205) & 4292739071u) == 0u) {
            let _e210 = o[0u];
            snd[0u] = _e210;
        }
        let _e213 = c_1[1u];
        t = bitcast<f32>(_e213);
        let _e216 = o[1u];
        to = bitcast<f32>(_e216);
        let _e218 = t;
        let _e219 = to;
        let _e222 = swept;
        if _e222 {
            local = 0.0625f;
        } else {
            let _e223 = t;
            local = max(1f, (abs(_e223) * 0.005f));
        }
        let _e227 = local;
        if (abs((_e218 - _e219)) <= _e227) {
            let _e230 = o[1u];
            snd[1u] = _e230;
        } else {
            let _e232 = t;
            param = _e232;
            let _e233 = web_isnan_u0028_f1_u003b((&param));
            let _e234 = !(_e233);
            phi_282_ = _e234;
            if _e234 {
                let _e235 = t;
                param_1 = _e235;
                let _e236 = web_isinf_u0028_f1_u003b((&param_1));
                phi_282_ = !(_e236);
            }
            let _e239 = phi_282_;
            if _e239 {
                let _e240 = t;
                snd[1u] = bitcast<u32>((round((_e240 * 8f)) / 8f));
            }
        }
        let _e246 = swept;
        if !(_e246) {
            let _e249 = c_1[2u];
            life = bitcast<i32>((_e249 & 65535u));
            let _e253 = o[2u];
            lo = bitcast<i32>((_e253 & 65535u));
            let _e257 = c_1[2u];
            let _e261 = o[2u];
            let _e264 = ((_e257 >> bitcast<u32>(16u)) == (_e261 >> bitcast<u32>(16u)));
            phi_327_ = _e264;
            if _e264 {
                let _e265 = life;
                let _e266 = lo;
                let _e269 = lo;
                phi_327_ = (abs((_e265 - _e266)) <= max(2i, (_e269 / 8i)));
            }
            let _e274 = phi_327_;
            if _e274 {
                let _e276 = o[2u];
                snd[2u] = _e276;
            }
            let _e279 = c_1[3u];
            let _e282 = o[3u];
            let _e284 = ((_e279 & 4294967040u) == (_e282 & 4294967040u));
            phi_355_ = _e284;
            if _e284 {
                let _e286 = c_1[3u];
                let _e290 = o[3u];
                phi_355_ = (abs((bitcast<i32>((_e286 & 255u)) - bitcast<i32>((_e290 & 255u)))) <= 16i);
            }
            let _e297 = phi_355_;
            if _e297 {
                let _e299 = o[3u];
                snd[3u] = _e299;
            }
        }
    }
    let _e301 = snd;
    let _e302 = o;
    changed = any((_e301 != _e302));
    m0_ = 0u;
    m1_ = 0u;
    l0_ = 0u;
    l1_ = 0u;
    let _e305 = li;
    if (_e305 < 64u) {
        let _e307 = cxy;
        let _e310 = li;
        let _e313 = li;
        let _e319 = textureLoad(medium, ((_e307 * vec2(8i)) + vec2<i32>(bitcast<i32>((_e310 & 7u)), bitcast<i32>((_e313 >> bitcast<u32>(3u))))), 0i);
        m = _e319;
        let _e320 = m;
        m0_ = pack2x16float(_e320.xy);
        let _e323 = m;
        m1_ = pack2x16float(_e323.zw);
        let _e326 = base_last;
        let _e328 = li;
        let _e333 = unnamed.last_sent[((_e326 + 1024u) + (_e328 * 2u))];
        l0_ = _e333;
        let _e334 = base_last;
        let _e336 = li;
        let _e342 = unnamed.last_sent[(((_e334 + 1024u) + (_e336 * 2u)) + 1u)];
        l1_ = _e342;
        let _e343 = exact;
        let _e345 = swept;
        let _e347 = (!(_e343) && !(_e345));
        phi_430_ = _e347;
        if _e347 {
            let _e348 = m0_;
            param_2 = _e348;
            let _e349 = l0_;
            param_3 = _e349;
            let _e350 = medium_changed_u0028_u1_u003b_u1_u003b((&param_2), (&param_3));
            phi_430_ = !(_e350);
        }
        let _e353 = phi_430_;
        if _e353 {
            let _e354 = l0_;
            m0_ = _e354;
        }
        let _e355 = exact;
        let _e357 = swept;
        let _e359 = (!(_e355) && !(_e357));
        phi_447_ = _e359;
        if _e359 {
            let _e360 = m1_;
            param_4 = _e360;
            let _e361 = l1_;
            param_5 = _e361;
            let _e362 = medium_changed_u0028_u1_u003b_u1_u003b((&param_4), (&param_5));
            phi_447_ = !(_e362);
        }
        let _e365 = phi_447_;
        if _e365 {
            let _e366 = l1_;
            m1_ = _e366;
        }
        let _e367 = changed;
        let _e368 = m0_;
        let _e369 = l0_;
        let _e372 = m1_;
        let _e373 = l1_;
        changed = ((_e367 || (_e368 != _e369)) || (_e372 != _e373));
    }
    let _e376 = changed;
    if _e376 {
        let _e377 = atomicOr((&sh_changed), 1u);
    }
    let _e378 = cxy;
    centre = vec2<f32>(((_e378 * vec2(16i)) + vec2(8i)));
    let _e384 = centre;
    param_6 = _e384;
    let _e386 = pc.f0_;
    param_7 = _e386.xy;
    let _e388 = near_cursor_u0028_vf2_u003b_vf2_u003b((&param_6), (&param_7));
    phi_490_ = _e388;
    if !(_e388) {
        let _e390 = centre;
        param_8 = _e390;
        let _e392 = pc.f0_;
        param_9 = _e392.zw;
        let _e394 = near_cursor_u0028_vf2_u003b_vf2_u003b((&param_8), (&param_9));
        phi_490_ = _e394;
    }
    let _e396 = phi_490_;
    phi_502_ = _e396;
    if !(_e396) {
        let _e398 = centre;
        param_10 = _e398;
        let _e400 = pc.f1_;
        param_11 = _e400.xy;
        let _e402 = near_cursor_u0028_vf2_u003b_vf2_u003b((&param_10), (&param_11));
        phi_502_ = _e402;
    }
    let _e404 = phi_502_;
    phi_513_ = _e404;
    if !(_e404) {
        let _e406 = centre;
        param_12 = _e406;
        let _e408 = pc.f1_;
        param_13 = _e408.zw;
        let _e410 = near_cursor_u0028_vf2_u003b_vf2_u003b((&param_12), (&param_13));
        phi_513_ = _e410;
    }
    let _e412 = phi_513_;
    near = _e412;
    let _e413 = chunk;
    let _e415 = count;
    let _e419 = pc.i1_[2u];
    let _e422 = count;
    rot = (((bitcast<u32>(_e413) + _e415) - bitcast<u32>(_e419)) % _e422);
    let _e424 = near;
    let _e425 = all_raw;
    if (_e424 && !(_e425)) {
        let _e428 = rot;
        local_1 = _e428;
    } else {
        let _e429 = count;
        let _e430 = rot;
        local_1 = (_e429 + _e430);
    }
    let _e432 = local_1;
    key = (_e432 + 1u);
    let _e434 = write_;
    if _e434 {
        let _e435 = li;
        i = _e435;
        loop {
            let _e436 = i;
            let _e437 = count;
            if (_e436 < _e437) {
                let _e439 = i;
                let _e442 = unnamed_1.pending[_e439];
                k = _e442;
                let _e443 = k;
                let _e445 = k;
                let _e446 = key;
                if ((_e443 != 0u) && (_e445 < _e446)) {
                    let _e449 = atomicAdd((&sh_rank), 1u);
                }
                continue;
            } else {
                break;
            }
            continuing {
                let _e450 = i;
                i = (_e450 + 256u);
            }
        }
    }
    workgroupBarrier();
    let _e452 = atomicLoad((&sh_changed));
    let _e454 = all_raw;
    goes = ((_e452 != 0u) || _e454);
    let _e456 = write_;
    if !(_e456) {
        let _e458 = li;
        if (_e458 == 0u) {
            let _e460 = chunk;
            let _e461 = goes;
            let _e462 = key;
            unnamed_1.pending[_e460] = select(0u, _e462, _e461);
        }
        return;
    }
    let _e466 = atomicLoad((&sh_rank));
    slot = _e466;
    let _e467 = goes;
    let _e468 = !(_e467);
    phi_605_ = _e468;
    if !(_e468) {
        let _e470 = all_raw;
        let _e472 = slot;
        let _e473 = cap;
        phi_605_ = (!(_e470) && (_e472 >= _e473));
    }
    let _e477 = phi_605_;
    if _e477 {
        return;
    }
    let _e478 = li;
    if (_e478 == 0u) {
        let _e480 = slot;
        let _e482 = chunk;
        atomicStore((&unnamed_2.out_data[(1u + _e480)]), bitcast<u32>(_e482));
        let _e488 = slot;
        let _e490 = atomicMax((&unnamed_2.out_data[0i]), (_e488 + 1u));
    }
    let _e493 = pc.i1_[0u];
    let _e495 = slot;
    base = (bitcast<u32>(_e493) + (_e495 * 1152u));
    let _e498 = all_raw;
    if _e498 {
        let _e499 = snd;
        local_2 = _e499;
    } else {
        let _e500 = snd;
        let _e501 = o;
        local_2 = (_e500 ^ _e501);
    }
    let _e503 = local_2;
    x_2 = _e503;
    let _e504 = base;
    let _e505 = li;
    let _e509 = x_2[0u];
    atomicStore((&unnamed_2.out_data[(_e504 + (_e505 * 4u))]), _e509);
    let _e512 = base;
    let _e513 = li;
    let _e518 = x_2[1u];
    atomicStore((&unnamed_2.out_data[((_e512 + (_e513 * 4u)) + 1u)]), _e518);
    let _e521 = base;
    let _e522 = li;
    let _e527 = x_2[2u];
    atomicStore((&unnamed_2.out_data[((_e521 + (_e522 * 4u)) + 2u)]), _e527);
    let _e530 = base;
    let _e531 = li;
    let _e536 = x_2[3u];
    atomicStore((&unnamed_2.out_data[((_e530 + (_e531 * 4u)) + 3u)]), _e536);
    let _e539 = base_last;
    let _e540 = li;
    let _e544 = snd[0u];
    unnamed.last_sent[(_e539 + (_e540 * 4u))] = _e544;
    let _e547 = base_last;
    let _e548 = li;
    let _e553 = snd[1u];
    unnamed.last_sent[((_e547 + (_e548 * 4u)) + 1u)] = _e553;
    let _e556 = base_last;
    let _e557 = li;
    let _e562 = snd[2u];
    unnamed.last_sent[((_e556 + (_e557 * 4u)) + 2u)] = _e562;
    let _e565 = base_last;
    let _e566 = li;
    let _e571 = snd[3u];
    unnamed.last_sent[((_e565 + (_e566 * 4u)) + 3u)] = _e571;
    let _e574 = li;
    if (_e574 < 64u) {
        let _e576 = base;
        let _e578 = li;
        let _e581 = all_raw;
        if _e581 {
            let _e582 = m0_;
            local_3 = _e582;
        } else {
            let _e583 = m0_;
            let _e584 = l0_;
            local_3 = (_e583 ^ _e584);
        }
        let _e586 = local_3;
        atomicStore((&unnamed_2.out_data[((_e576 + 1024u) + (_e578 * 2u))]), _e586);
        let _e589 = base;
        let _e591 = li;
        let _e595 = all_raw;
        if _e595 {
            let _e596 = m1_;
            local_4 = _e596;
        } else {
            let _e597 = m1_;
            let _e598 = l1_;
            local_4 = (_e597 ^ _e598);
        }
        let _e600 = local_4;
        atomicStore((&unnamed_2.out_data[(((_e589 + 1024u) + (_e591 * 2u)) + 1u)]), _e600);
        let _e603 = base_last;
        let _e605 = li;
        let _e608 = m0_;
        unnamed.last_sent[((_e603 + 1024u) + (_e605 * 2u))] = _e608;
        let _e611 = base_last;
        let _e613 = li;
        let _e617 = m1_;
        unnamed.last_sent[(((_e611 + 1024u) + (_e613 * 2u)) + 1u)] = _e617;
    }
    return;
}

@compute @workgroup_size(16, 16, 1) 
fn main(@builtin(local_invocation_index) gl_LocalInvocationIndex: u32, @builtin(workgroup_id) gl_WorkGroupID: vec3<u32>, @builtin(local_invocation_id) gl_LocalInvocationID: vec3<u32>) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    gl_LocalInvocationID_1 = gl_LocalInvocationID;
    main_1(gl_WorkGroupID);
}
