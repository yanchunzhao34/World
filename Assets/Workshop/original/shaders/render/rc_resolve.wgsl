struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
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

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> sh_cs: array<vec4<f32>, 64>;
@group(0) @binding(0) 
var c0_: texture_2d<f32>;
@group(0) @binding(4) 
var<uniform> rp: RenderParams;
@group(0) @binding(1) 
var prev: texture_2d<f32>;
@group(0) @binding(5) 
var cha_prev: texture_2d<f32>;
@group(0) @binding(6) 
var chb_prev: texture_2d<f32>;
@group(0) @binding(2) 
var fluence_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(7) 
var cha_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(8) 
var chb_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(3) 
var dir_out: texture_storage_2d<rgba16float,write>;

fn web_isinf_u0028_vf4_u003b(x: ptr<function, vec4<f32>>) -> vec4<bool> {
    let _e44 = (*x);
    return (abs(_e44) > vec4<f32>(340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f));
}

fn web_isnan_u0028_vf4_u003b(x_1: ptr<function, vec4<f32>>) -> vec4<bool> {
    let _e44 = (*x_1);
    let _e45 = (*x_1);
    return (_e44 != _e45);
}

fn web_isinf_u0028_vf3_u003b(x_2: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e44 = (*x_2);
    return (abs(_e44) > vec3<f32>(340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f));
}

fn web_isnan_u0028_vf3_u003b(x_3: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e44 = (*x_3);
    let _e45 = (*x_3);
    return (_e44 != _e45);
}

fn luminance_u0028_vf3_u003b(c: ptr<function, vec3<f32>>) -> f32 {
    let _e44 = (*c);
    return dot(_e44, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn main_1() {
    var q: vec2<i32>;
    var tile: i32;
    var dirs: i32;
    var li: i32;
    var ang: f32;
    var sum: vec3<f32>;
    var c1_: vec3<f32>;
    var s1_: vec3<f32>;
    var c2_: f32;
    var s2_: f32;
    var d: i32;
    var L: vec3<f32>;
    var h: vec4<f32>;
    var l: f32;
    var param: vec3<f32>;
    var k: f32;
    var fl: vec3<f32>;
    var a1_: vec3<f32>;
    var b1_: vec3<f32>;
    var a2_: f32;
    var local: f32;
    var b2_: f32;
    var local_1: f32;
    var A: vec4<f32>;
    var B: vec4<f32>;
    var old: vec4<f32>;
    var a: f32;
    var param_1: vec3<f32>;
    var param_2: vec3<f32>;
    var res: vec3<f32>;
    var rA: vec4<f32>;
    var rB: vec4<f32>;
    var param_3: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec4<f32>;
    var param_6: vec4<f32>;
    var param_7: vec4<f32>;
    var param_8: vec4<f32>;
    var dl: vec2<f32>;
    var param_9: vec3<f32>;
    var param_10: vec3<f32>;
    var ll: f32;
    var m0_: f32;
    var param_11: vec3<f32>;
    var local_2: vec2<f32>;
    var phi_343_: bool;
    var phi_351_: bool;
    var phi_359_: bool;
    var phi_367_: bool;
    var phi_375_: bool;

    let _e88 = gl_GlobalInvocationID_1;
    q = bitcast<vec2<i32>>(_e88.xy);
    let _e93 = pc.i1_[0u];
    tile = _e93;
    let _e94 = tile;
    let _e95 = tile;
    dirs = (_e94 * _e95);
    let _e97 = gl_LocalInvocationIndex_1;
    li = bitcast<i32>(_e97);
    let _e99 = li;
    let _e100 = dirs;
    if (_e99 < _e100) {
        let _e102 = li;
        let _e105 = dirs;
        ang = (((f32(_e102) + 0.5f) / f32(_e105)) * 6.2831855f);
        let _e109 = li;
        let _e110 = ang;
        let _e112 = ang;
        let _e114 = ang;
        let _e117 = ang;
        sh_cs[_e109] = vec4<f32>(cos(_e110), sin(_e112), cos((2f * _e114)), sin((2f * _e117)));
    }
    workgroupBarrier();
    let _e122 = q;
    let _e124 = pc.i0_;
    if any((_e122 >= _e124.xy)) {
        return;
    }
    sum = vec3<f32>(0f, 0f, 0f);
    c1_ = vec3<f32>(0f, 0f, 0f);
    s1_ = vec3<f32>(0f, 0f, 0f);
    c2_ = 0f;
    s2_ = 0f;
    d = 0i;
    loop {
        let _e128 = d;
        let _e129 = dirs;
        if (_e128 < _e129) {
            let _e131 = q;
            let _e132 = tile;
            let _e135 = d;
            let _e136 = tile;
            let _e144 = d;
            let _e145 = tile;
            let _e149 = textureLoad(c0_, ((_e131 * vec2(_e132)) + vec2<i32>((_e135 % _e136 + select(0i, _e136, _e135 % _e136 != 0i && ((_e135 % _e136 < 0i) != (_e136 < 0i)))), (_e144 / _e145))), 0i);
            L = _e149.xyz;
            let _e151 = d;
            let _e153 = sh_cs[_e151];
            h = _e153;
            let _e154 = L;
            param = _e154;
            let _e155 = luminance_u0028_vf3_u003b((&param));
            l = _e155;
            let _e156 = L;
            let _e157 = sum;
            sum = (_e157 + _e156);
            let _e159 = L;
            let _e161 = h[0u];
            let _e163 = c1_;
            c1_ = (_e163 + (_e159 * _e161));
            let _e165 = L;
            let _e167 = h[1u];
            let _e169 = s1_;
            s1_ = (_e169 + (_e165 * _e167));
            let _e171 = l;
            let _e173 = h[2u];
            let _e175 = c2_;
            c2_ = (_e175 + (_e171 * _e173));
            let _e177 = l;
            let _e179 = h[3u];
            let _e181 = s2_;
            s2_ = (_e181 + (_e177 * _e179));
            continue;
        } else {
            break;
        }
        continuing {
            let _e183 = d;
            d = (_e183 + 1i);
        }
    }
    let _e187 = rp.gi[3u];
    let _e188 = dirs;
    k = (_e187 / f32(_e188));
    let _e191 = sum;
    let _e192 = k;
    fl = (_e191 * _e192);
    let _e194 = c1_;
    let _e196 = k;
    a1_ = ((_e194 * 2f) * _e196);
    let _e198 = s1_;
    let _e200 = k;
    b1_ = ((_e198 * 2f) * _e200);
    let _e202 = dirs;
    if (_e202 > 4i) {
        let _e204 = c2_;
        let _e206 = k;
        local = ((_e204 * 2f) * _e206);
    } else {
        local = 0f;
    }
    let _e208 = local;
    a2_ = _e208;
    let _e209 = dirs;
    if (_e209 > 4i) {
        let _e211 = s2_;
        let _e213 = k;
        local_1 = ((_e211 * 2f) * _e213);
    } else {
        local_1 = 0f;
    }
    let _e215 = local_1;
    b2_ = _e215;
    let _e216 = a1_;
    let _e218 = b1_[0u];
    A = vec4<f32>(_e216.x, _e216.y, _e216.z, _e218);
    let _e224 = b1_[1u];
    let _e226 = b1_[2u];
    let _e227 = a2_;
    let _e228 = b2_;
    B = vec4<f32>(_e224, _e226, _e227, _e228);
    let _e230 = q;
    let _e231 = textureLoad(prev, _e230, 0i);
    old = _e231;
    let _e234 = rp.gi[1u];
    a = _e234;
    let _e235 = fl;
    param_1 = _e235;
    let _e236 = luminance_u0028_vf3_u003b((&param_1));
    let _e237 = old;
    param_2 = _e237.xyz;
    let _e239 = luminance_u0028_vf3_u003b((&param_2));
    if (_e236 > (_e239 * 1.6f)) {
        let _e242 = a;
        a = max(_e242, 0.85f);
    }
    let _e244 = old;
    let _e246 = fl;
    let _e247 = a;
    res = mix(_e244.xyz, _e246, vec3(_e247));
    let _e250 = q;
    let _e251 = textureLoad(cha_prev, _e250, 0i);
    let _e252 = A;
    let _e253 = a;
    rA = mix(_e251, _e252, vec4(_e253));
    let _e256 = q;
    let _e257 = textureLoad(chb_prev, _e256, 0i);
    let _e258 = B;
    let _e259 = a;
    rB = mix(_e257, _e258, vec4(_e259));
    let _e262 = res;
    param_3 = _e262;
    let _e263 = web_isnan_u0028_vf3_u003b((&param_3));
    let _e264 = any(_e263);
    phi_343_ = _e264;
    if !(_e264) {
        let _e266 = res;
        param_4 = _e266;
        let _e267 = web_isinf_u0028_vf3_u003b((&param_4));
        phi_343_ = any(_e267);
    }
    let _e270 = phi_343_;
    phi_351_ = _e270;
    if !(_e270) {
        let _e272 = rA;
        param_5 = _e272;
        let _e273 = web_isnan_u0028_vf4_u003b((&param_5));
        phi_351_ = any(_e273);
    }
    let _e276 = phi_351_;
    phi_359_ = _e276;
    if !(_e276) {
        let _e278 = rB;
        param_6 = _e278;
        let _e279 = web_isnan_u0028_vf4_u003b((&param_6));
        phi_359_ = any(_e279);
    }
    let _e282 = phi_359_;
    phi_367_ = _e282;
    if !(_e282) {
        let _e284 = rA;
        param_7 = _e284;
        let _e285 = web_isinf_u0028_vf4_u003b((&param_7));
        phi_367_ = any(_e285);
    }
    let _e288 = phi_367_;
    phi_375_ = _e288;
    if !(_e288) {
        let _e290 = rB;
        param_8 = _e290;
        let _e291 = web_isinf_u0028_vf4_u003b((&param_8));
        phi_375_ = any(_e291);
    }
    let _e294 = phi_375_;
    if _e294 {
        res = vec3<f32>(0f, 0f, 0f);
        rA = vec4<f32>(0f, 0f, 0f, 0f);
        rB = vec4<f32>(0f, 0f, 0f, 0f);
    }
    let _e295 = q;
    let _e296 = res;
    textureStore(fluence_out, _e295, vec4<f32>(_e296.x, _e296.y, _e296.z, 1f));
    let _e301 = q;
    let _e302 = rA;
    textureStore(cha_out, _e301, _e302);
    let _e303 = q;
    let _e304 = rB;
    textureStore(chb_out, _e303, _e304);
    let _e305 = rA;
    param_9 = _e305.xyz;
    let _e307 = luminance_u0028_vf3_u003b((&param_9));
    let _e309 = rA[3u];
    let _e311 = rB[0u];
    let _e313 = rB[1u];
    param_10 = vec3<f32>(_e309, _e311, _e313);
    let _e315 = luminance_u0028_vf3_u003b((&param_10));
    dl = vec2<f32>(_e307, _e315);
    let _e317 = dl;
    ll = length(_e317);
    let _e319 = res;
    param_11 = _e319;
    let _e320 = luminance_u0028_vf3_u003b((&param_11));
    m0_ = _e320;
    let _e321 = q;
    let _e322 = ll;
    if (_e322 > 0.00001f) {
        let _e324 = dl;
        let _e325 = ll;
        local_2 = (_e324 / vec2(_e325));
    } else {
        local_2 = vec2<f32>(0f, 0f);
    }
    let _e328 = local_2;
    let _e329 = ll;
    let _e330 = m0_;
    textureStore(dir_out, _e321, vec4<f32>(_e328.x, _e328.y, min((_e329 / max((2f * _e330), 0.00001f)), 1f), 0f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(local_invocation_index) gl_LocalInvocationIndex: u32) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1();
}
