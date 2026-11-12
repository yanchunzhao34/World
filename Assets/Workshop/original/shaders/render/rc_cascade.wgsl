struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Occ {
    occ: array<u32>,
}

struct RenderParams {
    sky_top: vec4<f32>,
    sky_horizon: vec4<f32>,
    sun: vec4<f32>,
    sun_color: vec4<f32>,
    ambient: vec4<f32>,
    gi: vec4<f32>,
    bloom: vec4<f32>,
    expo: vec4<f32>,
    expo2_: vec4<f32>,
    medium: vec4<f32>,
    soot_color: vec4<f32>,
    steam_color: vec4<f32>,
    fx: vec4<f32>,
    misc: vec4<f32>,
    misc2_: vec4<f32>,
    reserved: vec4<f32>,
    cam_plane: vec4<f32>,
    cam_tilt: vec4<f32>,
    cam_right: vec4<f32>,
    cam_down: vec4<f32>,
    bgparams: vec4<f32>,
    haze: vec4<f32>,
    view: vec4<f32>,
    reserved2_: vec4<f32>,
    look: vec4<f32>,
    look2_: vec4<f32>,
    look3_: vec4<f32>,
    look4_: vec4<f32>,
    day: vec4<f32>,
}

var<private> g_world: vec2<f32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var scene: texture_2d<f32>;
@group(2) @binding(0) 
var scene_smp: sampler;
var<private> g_useOcc: bool;
var<workgroup> sh_gloss: array<u32, 128>;
@group(0) @binding(5) 
var gloss_a: texture_2d<f32>;
@group(2) @binding(5) 
var gloss_a_smp: sampler;
@group(0) @binding(4) 
var ext_scene: texture_2d<f32>;
@group(2) @binding(4) 
var ext_scene_smp: sampler;
@group(0) @binding(1) 
var upper_avg: texture_2d<f32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
var<private> gl_LocalInvocationIndex_1: u32;
@group(0) @binding(6) 
var<storage> unnamed: Occ;
@group(0) @binding(2) 
var out_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(3) 
var<uniform> rp: RenderParams;

fn upper_probe_u0028_vi2_u003b_i1_u003b_i1_u003b(q: ptr<function, vec2<i32>>, dirIndex: ptr<function, i32>, tileU: ptr<function, i32>) -> vec3<f32> {
    var tile: i32;

    let _e57 = (*tileU);
    tile = (_e57 / 2i);
    let _e59 = (*q);
    let _e60 = tile;
    let _e63 = (*dirIndex);
    let _e64 = tile;
    let _e72 = (*dirIndex);
    let _e73 = tile;
    let _e77 = textureLoad(upper_avg, ((_e59 * vec2(_e60)) + vec2<i32>((_e63 % _e64 + select(0i, _e64, _e63 % _e64 != 0i && ((_e63 % _e64 < 0i) != (_e64 < 0i)))), (_e72 / _e73))), 0i);
    return _e77.xyz;
}

fn exit_distance_u0028_vf2_u003b_vf2_u003b(o: ptr<function, vec2<f32>>, d: ptr<function, vec2<f32>>) -> f32 {
    var inv: vec2<f32>;
    var t0_: vec2<f32>;
    var t1_: vec2<f32>;
    var tmax: vec2<f32>;

    let _e59 = (*d);
    let _e64 = (*d);
    inv = ((vec2(1f) / max(abs(_e59), vec2<f32>(0.000001f, 0.000001f))) * sign((_e64 + vec2(0.000000000001f))));
    let _e69 = (*o);
    let _e71 = inv;
    t0_ = ((vec2<f32>(0f, 0f) - _e69) * _e71);
    let _e73 = g_world;
    let _e74 = (*o);
    let _e76 = inv;
    t1_ = ((_e73 - _e74) * _e76);
    let _e78 = t0_;
    let _e79 = t1_;
    tmax = max(_e78, _e79);
    let _e82 = tmax[0u];
    let _e84 = tmax[1u];
    return min(_e82, _e84);
}

fn march_u0028_vf2_u003b_vf2_u003b_vf2_u003b_vf3_u003b(a: ptr<function, vec2<f32>>, b: ptr<function, vec2<f32>>, dir: ptr<function, vec2<f32>>, Tout: ptr<function, vec3<f32>>) -> vec3<f32> {
    var ab: vec2<f32>;
    var len: f32;
    var d_1: vec2<f32>;
    var inside: bool;
    var tex: f32;
    var param: vec2<f32>;
    var param_1: vec2<f32>;
    var exits: bool;
    var marchLen: f32;
    var stepLen: f32;
    var steps: i32;
    var ds: f32;
    var L: vec3<f32>;
    var T: vec3<f32>;
    var blocks: vec2<i32>;
    var k: i32;
    var pos: vec2<f32>;
    var uvp: vec2<f32>;
    var sc: vec4<f32>;
    var s: vec3<f32>;
    var glossHere: bool;
    var bq: vec2<i32>;
    var idx: u32;
    var g: vec4<f32>;
    var c: f32;
    var c2_: f32;
    var ext: vec3<f32>;
    var tau: vec3<f32>;
    var phi_110_: bool;

    let _e85 = (*b);
    let _e86 = (*a);
    ab = (_e85 - _e86);
    let _e88 = ab;
    len = length(_e88);
    (*Tout) = vec3<f32>(1f, 1f, 1f);
    let _e90 = len;
    if (_e90 <= 0f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e92 = ab;
    let _e93 = len;
    d_1 = (_e92 / vec2(_e93));
    let _e96 = (*a);
    let _e98 = all((_e96 >= vec2<f32>(0f, 0f)));
    phi_110_ = _e98;
    if _e98 {
        let _e99 = (*a);
        let _e100 = g_world;
        phi_110_ = all((_e99 <= _e100));
    }
    let _e104 = phi_110_;
    inside = _e104;
    let _e105 = inside;
    if !(_e105) {
        (*Tout) = vec3<f32>(0f, 0f, 0f);
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e107 = (*a);
    param = _e107;
    let _e108 = d_1;
    param_1 = _e108;
    let _e109 = exit_distance_u0028_vf2_u003b_vf2_u003b((&param), (&param_1));
    tex = _e109;
    let _e110 = tex;
    let _e111 = len;
    exits = (_e110 < _e111);
    let _e113 = len;
    let _e114 = tex;
    marchLen = min(_e113, _e114);
    let _e118 = pc.f0_[2u];
    stepLen = _e118;
    let _e119 = marchLen;
    let _e120 = stepLen;
    steps = max(1i, i32(ceil((_e119 / _e120))));
    let _e125 = marchLen;
    let _e126 = steps;
    ds = (_e125 / f32(_e126));
    L = vec3<f32>(0f, 0f, 0f);
    T = vec3<f32>(1f, 1f, 1f);
    let _e129 = g_world;
    blocks = (vec2<i32>(_e129) >> bitcast<vec2<u32>>(vec2(3i)));
    k = 0i;
    loop {
        let _e134 = k;
        let _e135 = steps;
        if (_e134 < _e135) {
            let _e137 = (*a);
            let _e138 = d_1;
            let _e139 = ds;
            let _e140 = k;
            pos = (_e137 + (_e138 * (_e139 * (f32(_e140) + 0.5f))));
            let _e146 = pos;
            let _e147 = g_world;
            uvp = (_e146 / _e147);
            let _e149 = uvp;
            let _e150 = textureSampleLevel(scene, scene_smp, _e149, 0f);
            sc = _e150;
            let _e151 = sc;
            s = _e151.xyz;
            let _e155 = pc.i0_[2u];
            glossHere = (_e155 < 3i);
            let _e157 = glossHere;
            let _e158 = g_useOcc;
            if (_e157 && _e158) {
                let _e160 = pos;
                let _e166 = blocks;
                bq = clamp((vec2<i32>(floor(_e160)) >> bitcast<vec2<u32>>(vec2(3i))), vec2<i32>(0i, 0i), (_e166 - vec2(1i)));
                let _e171 = bq[1u];
                let _e173 = blocks[0u];
                let _e176 = bq[0u];
                idx = bitcast<u32>(((_e171 * _e173) + _e176));
                let _e179 = idx;
                let _e183 = sh_gloss[(_e179 >> bitcast<u32>(5u))];
                let _e184 = idx;
                glossHere = ((_e183 & (1u << bitcast<u32>((_e184 & 31u)))) != 0u);
            }
            let _e190 = glossHere;
            if _e190 {
                let _e191 = uvp;
                let _e192 = textureSampleLevel(gloss_a, gloss_a_smp, _e191, 0f);
                g = _e192;
                let _e194 = g[0u];
                let _e196 = g[1u];
                let _e199 = g[2u];
                if (((_e194 + _e196) + _e199) > 0.001f) {
                    let _e203 = g[3u];
                    let _e206 = g[3u];
                    let _e209 = (*dir);
                    c = max(dot(vec2<f32>(cos(_e203), sin(_e206)), -(_e209)), 0f);
                    let _e213 = c;
                    let _e214 = c;
                    c2_ = (_e213 * _e214);
                    let _e216 = g;
                    let _e218 = c2_;
                    let _e220 = c2_;
                    let _e223 = s;
                    s = (_e223 + (((_e216.xyz * _e218) * _e220) * 2.5f));
                }
            }
            let _e225 = uvp;
            let _e226 = textureSampleLevel(ext_scene, ext_scene_smp, _e225, 0f);
            ext = _e226.xyz;
            let _e228 = ext;
            let _e230 = ds;
            tau = exp((-(_e228) * _e230));
            let _e233 = T;
            let _e234 = s;
            let _e237 = sc[3u];
            let _e239 = ext;
            let _e242 = ds;
            let _e248 = L;
            L = (_e248 + ((_e233 * _e234) * (vec3(1f) - exp((-(max(vec3(_e237), _e239)) * _e242)))));
            let _e250 = tau;
            let _e251 = T;
            T = (_e251 * _e250);
            let _e254 = T[0u];
            let _e256 = T[1u];
            let _e258 = T[2u];
            if (max(_e254, max(_e256, _e258)) < 0.003f) {
                (*Tout) = vec3<f32>(0f, 0f, 0f);
                let _e262 = L;
                return _e262;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e263 = k;
            k = (_e263 + 1i);
        }
    }
    let _e265 = exits;
    if _e265 {
        T = vec3<f32>(0f, 0f, 0f);
    }
    let _e266 = T;
    (*Tout) = _e266;
    let _e267 = L;
    return _e267;
}

fn main_1() {
    var p: vec2<i32>;
    var nb: vec2<i32>;
    var words: i32;
    var i: i32;
    var cascade: i32;
    var count: i32;
    var spacing: i32;
    var tile_1: i32;
    var probe: vec2<i32>;
    var local: vec2<i32>;
    var dirIndex_1: i32;
    var dirs: i32;
    var ang: f32;
    var dir_1: vec2<f32>;
    var center: vec2<f32>;
    var t0_1: f32;
    var t1_1: f32;
    var result: vec3<f32>;
    var Tr: vec3<f32>;
    var param_2: vec2<f32>;
    var param_3: vec2<f32>;
    var param_4: vec2<f32>;
    var param_5: vec3<f32>;
    var spacingU: i32;
    var tileU_1: i32;
    var probesU: vec2<i32>;
    var pu: vec2<f32>;
    var base: vec2<i32>;
    var f: vec2<f32>;
    var w: array<f32, 4>;
    var offs: array<vec2<i32>, 4>;
    var k_1: i32;
    var q_1: vec2<i32>;
    var cu: vec2<f32>;
    var L_1: vec3<f32>;
    var param_6: vec2<f32>;
    var param_7: vec2<f32>;
    var param_8: vec2<f32>;
    var param_9: vec3<f32>;
    var up: vec3<f32>;
    var local_1: vec3<f32>;
    var param_10: vec2<i32>;
    var param_11: i32;
    var param_12: i32;
    var L_2: vec3<f32>;
    var param_13: vec2<f32>;
    var param_14: vec2<f32>;
    var param_15: vec2<f32>;
    var param_16: vec3<f32>;
    var up_1: vec3<f32>;
    var k_2: i32;
    var q_2: vec2<i32>;
    var param_17: vec2<i32>;
    var param_18: i32;
    var param_19: i32;
    var phi_414_: bool;

    let _e108 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e108.xy);
    let _e112 = pc.i0_;
    g_world = vec2<f32>(_e112.xy);
    let _e116 = pc.i0_;
    nb = (_e116.xy >> bitcast<vec2<u32>>(vec2(3i)));
    let _e123 = pc.i0_[2u];
    let _e124 = (_e123 < 3i);
    phi_414_ = _e124;
    if _e124 {
        let _e126 = nb[0u];
        let _e128 = nb[1u];
        phi_414_ = ((_e126 * _e128) <= 4096i);
    }
    let _e132 = phi_414_;
    g_useOcc = _e132;
    let _e133 = g_useOcc;
    if _e133 {
        let _e135 = nb[0u];
        let _e137 = nb[1u];
        words = (((_e135 * _e137) + 31i) >> bitcast<u32>(5i));
        let _e142 = gl_LocalInvocationIndex_1;
        i = bitcast<i32>(_e142);
        loop {
            let _e144 = i;
            let _e145 = words;
            if (_e144 < _e145) {
                let _e147 = i;
                let _e148 = i;
                let _e151 = unnamed.occ[_e148];
                sh_gloss[_e147] = _e151;
                continue;
            } else {
                break;
            }
            continuing {
                let _e153 = i;
                i = (_e153 + 128i);
            }
        }
    }
    workgroupBarrier();
    let _e155 = p;
    let _e156 = textureDimensions(out_img);
    if any((_e155 >= vec2<i32>(_e156))) {
        return;
    }
    let _e162 = pc.i0_[2u];
    cascade = _e162;
    let _e165 = pc.i0_[3u];
    count = _e165;
    let _e168 = pc.i1_[0u];
    spacing = _e168;
    let _e171 = pc.i1_[1u];
    tile_1 = _e171;
    let _e172 = p;
    let _e173 = tile_1;
    probe = (_e172 / vec2(_e173));
    let _e176 = p;
    let _e177 = probe;
    let _e178 = tile_1;
    local = (_e176 - (_e177 * vec2(_e178)));
    let _e183 = local[1u];
    let _e184 = tile_1;
    let _e187 = local[0u];
    dirIndex_1 = ((_e183 * _e184) + _e187);
    let _e189 = tile_1;
    let _e190 = tile_1;
    dirs = (_e189 * _e190);
    let _e192 = dirIndex_1;
    let _e195 = dirs;
    ang = (((f32(_e192) + 0.5f) / f32(_e195)) * 6.2831855f);
    let _e199 = ang;
    let _e201 = ang;
    dir_1 = vec2<f32>(cos(_e199), sin(_e201));
    let _e204 = probe;
    let _e208 = spacing;
    center = ((vec2<f32>(_e204) + vec2(0.5f)) * f32(_e208));
    let _e213 = pc.f0_[0u];
    t0_1 = _e213;
    let _e216 = pc.f0_[1u];
    t1_1 = _e216;
    let _e217 = cascade;
    let _e218 = count;
    if (_e217 == (_e218 - 1i)) {
        let _e221 = center;
        let _e222 = dir_1;
        let _e223 = t0_1;
        let _e226 = center;
        let _e227 = dir_1;
        let _e228 = t1_1;
        param_2 = (_e221 + (_e222 * _e223));
        param_3 = (_e226 + (_e227 * _e228));
        let _e231 = dir_1;
        param_4 = _e231;
        let _e232 = march_u0028_vf2_u003b_vf2_u003b_vf2_u003b_vf3_u003b((&param_2), (&param_3), (&param_4), (&param_5));
        let _e233 = param_5;
        Tr = _e233;
        result = _e232;
    } else {
        let _e234 = spacing;
        spacingU = (_e234 * 2i);
        let _e236 = tile_1;
        tileU_1 = (_e236 * 2i);
        let _e239 = pc.i0_;
        let _e241 = spacingU;
        probesU = (_e239.xy / vec2(_e241));
        let _e244 = center;
        let _e245 = spacingU;
        pu = ((_e244 / vec2(f32(_e245))) - vec2(0.5f));
        let _e251 = pu;
        base = vec2<i32>(floor(_e251));
        let _e254 = pu;
        let _e255 = base;
        f = (_e254 - vec2<f32>(_e255));
        let _e259 = f[0u];
        let _e262 = f[1u];
        let _e266 = f[0u];
        let _e268 = f[1u];
        let _e272 = f[0u];
        let _e275 = f[1u];
        let _e278 = f[0u];
        let _e280 = f[1u];
        w = array<f32, 4>(((1f - _e259) * (1f - _e262)), (_e266 * (1f - _e268)), ((1f - _e272) * _e275), (_e278 * _e280));
        offs = array<vec2<i32>, 4>(vec2<i32>(0i, 0i), vec2<i32>(1i, 0i), vec2<i32>(0i, 1i), vec2<i32>(1i, 1i));
        let _e285 = pc.i1_[2u];
        if (_e285 != 0i) {
            result = vec3<f32>(0f, 0f, 0f);
            k_1 = 0i;
            loop {
                let _e287 = k_1;
                if (_e287 < 4i) {
                    let _e289 = base;
                    let _e290 = k_1;
                    let _e292 = offs[_e290];
                    let _e294 = probesU;
                    q_1 = clamp((_e289 + _e292), vec2<i32>(0i, 0i), (_e294 - vec2(1i)));
                    let _e298 = q_1;
                    let _e302 = spacingU;
                    cu = ((vec2<f32>(_e298) + vec2(0.5f)) * f32(_e302));
                    let _e305 = center;
                    let _e306 = dir_1;
                    let _e307 = t0_1;
                    let _e310 = cu;
                    let _e311 = dir_1;
                    let _e312 = t1_1;
                    param_6 = (_e305 + (_e306 * _e307));
                    param_7 = (_e310 + (_e311 * _e312));
                    let _e315 = dir_1;
                    param_8 = _e315;
                    let _e316 = march_u0028_vf2_u003b_vf2_u003b_vf2_u003b_vf3_u003b((&param_6), (&param_7), (&param_8), (&param_9));
                    let _e317 = param_9;
                    Tr = _e317;
                    L_1 = _e316;
                    let _e319 = Tr[0u];
                    let _e321 = Tr[1u];
                    let _e323 = Tr[2u];
                    if (max(_e319, max(_e321, _e323)) > 0f) {
                        let _e327 = q_1;
                        param_10 = _e327;
                        let _e328 = dirIndex_1;
                        param_11 = _e328;
                        let _e329 = tileU_1;
                        param_12 = _e329;
                        let _e330 = upper_probe_u0028_vi2_u003b_i1_u003b_i1_u003b((&param_10), (&param_11), (&param_12));
                        local_1 = _e330;
                    } else {
                        local_1 = vec3<f32>(0f, 0f, 0f);
                    }
                    let _e331 = local_1;
                    up = _e331;
                    let _e332 = k_1;
                    let _e334 = w[_e332];
                    let _e335 = L_1;
                    let _e336 = Tr;
                    let _e337 = up;
                    let _e341 = result;
                    result = (_e341 + ((_e335 + (_e336 * _e337)) * _e334));
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e343 = k_1;
                    k_1 = (_e343 + 1i);
                }
            }
        } else {
            let _e345 = center;
            let _e346 = dir_1;
            let _e347 = t0_1;
            let _e350 = center;
            let _e351 = dir_1;
            let _e352 = t1_1;
            param_13 = (_e345 + (_e346 * _e347));
            param_14 = (_e350 + (_e351 * _e352));
            let _e355 = dir_1;
            param_15 = _e355;
            let _e356 = march_u0028_vf2_u003b_vf2_u003b_vf2_u003b_vf3_u003b((&param_13), (&param_14), (&param_15), (&param_16));
            let _e357 = param_16;
            Tr = _e357;
            L_2 = _e356;
            up_1 = vec3<f32>(0f, 0f, 0f);
            let _e359 = Tr[0u];
            let _e361 = Tr[1u];
            let _e363 = Tr[2u];
            if (max(_e359, max(_e361, _e363)) > 0f) {
                k_2 = 0i;
                loop {
                    let _e367 = k_2;
                    if (_e367 < 4i) {
                        let _e369 = base;
                        let _e370 = k_2;
                        let _e372 = offs[_e370];
                        let _e374 = probesU;
                        q_2 = clamp((_e369 + _e372), vec2<i32>(0i, 0i), (_e374 - vec2(1i)));
                        let _e378 = k_2;
                        let _e380 = w[_e378];
                        let _e381 = q_2;
                        param_17 = _e381;
                        let _e382 = dirIndex_1;
                        param_18 = _e382;
                        let _e383 = tileU_1;
                        param_19 = _e383;
                        let _e384 = upper_probe_u0028_vi2_u003b_i1_u003b_i1_u003b((&param_17), (&param_18), (&param_19));
                        let _e386 = up_1;
                        up_1 = (_e386 + (_e384 * _e380));
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e388 = k_2;
                        k_2 = (_e388 + 1i);
                    }
                }
            }
            let _e390 = L_2;
            let _e391 = Tr;
            let _e392 = up_1;
            result = (_e390 + (_e391 * _e392));
        }
    }
    let _e395 = p;
    let _e396 = result;
    textureStore(out_img, _e395, vec4<f32>(_e396.x, _e396.y, _e396.z, 1f));
    return;
}

@compute @workgroup_size(128, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(local_invocation_index) gl_LocalInvocationIndex: u32) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1();
}
