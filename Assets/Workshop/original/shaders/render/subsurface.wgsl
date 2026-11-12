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

@group(0) @binding(3) 
var emissive_img: texture_2d<f32>;
@group(0) @binding(2) 
var albedo_img: texture_2d<f32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(7) 
var out_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
@group(0) @binding(6) 
var prev_img: texture_2d<f32>;
@group(0) @binding(5) 
var fluence_tex: texture_2d<f32>;
@group(2) @binding(5) 
var fluence_tex_smp: sampler;
@group(0) @binding(4) 
var gaux_img: texture_2d<f32>;

fn web_isinf_u0028_vf3_u003b(x: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e63 = (*x);
    return (abs(_e63) > vec3<f32>(340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f));
}

fn web_isnan_u0028_vf3_u003b(x_1: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e63 = (*x_1);
    let _e64 = (*x_1);
    return (_e63 != _e64);
}

fn dense_u0028_vi2_u003b_vi2_u003b(q: ptr<function, vec2<i32>>, n: ptr<function, vec2<i32>>) -> bool {
    var st: u32;
    var phi_51_: bool;
    var phi_92_: bool;
    var phi_93_: bool;

    let _e65 = (*q);
    let _e67 = any((_e65 < vec2<i32>(0i, 0i)));
    phi_51_ = _e67;
    if !(_e67) {
        let _e69 = (*q);
        let _e70 = (*n);
        phi_51_ = any((_e69 >= _e70));
    }
    let _e74 = phi_51_;
    if _e74 {
        return false;
    }
    let _e75 = (*q);
    let _e76 = textureLoad(emissive_img, _e75, 0i);
    st = u32((_e76.w + 0.5f));
    let _e80 = st;
    let _e82 = st;
    let _e84 = ((_e80 == 3u) || (_e82 == 2u));
    phi_93_ = _e84;
    if !(_e84) {
        let _e86 = st;
        let _e87 = (_e86 == 1u);
        phi_92_ = _e87;
        if _e87 {
            let _e88 = (*q);
            let _e89 = textureLoad(albedo_img, _e88, 0i);
            phi_92_ = (_e89.w > 0.97f);
        }
        let _e93 = phi_92_;
        phi_93_ = _e93;
    }
    let _e95 = phi_93_;
    return _e95;
}

fn main_1() {
    var p: vec2<i32>;
    var n_1: vec2<i32>;
    var param: vec2<i32>;
    var param_1: vec2<i32>;
    var m: Material;
    var pen: f32;
    var alb: vec3<f32>;
    var pos: vec2<f32>;
    var src: vec3<f32>;
    var inner: vec3<f32>;
    var cnt: f32;
    var k: i32;
    var q_1: vec2<i32>;
    var indexable: array<vec2<i32>, 4>;
    var param_2: vec2<i32>;
    var param_3: vec2<i32>;
    var indexable_1: array<vec2<i32>, 4>;
    var a: f32;
    var tint: vec3<f32>;
    var diffused: vec3<f32>;
    var local: vec3<f32>;
    var L: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec3<f32>;
    var phi_296_: bool;
    var phi_380_: bool;

    let _e86 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e86.xy);
    let _e90 = pc.i0_;
    n_1 = _e90.xy;
    let _e92 = p;
    let _e93 = n_1;
    if any((_e92 >= _e93)) {
        return;
    }
    let _e96 = p;
    param = _e96;
    let _e97 = n_1;
    param_1 = _e97;
    let _e98 = dense_u0028_vi2_u003b_vi2_u003b((&param), (&param_1));
    if !(_e98) {
        let _e100 = p;
        textureStore(out_img, _e100, vec4<f32>(0f, 0f, 0f, 0f));
        return;
    }
    let _e101 = p;
    let _e102 = textureLoad(cells, _e101, 0i);
    let _e107 = unnamed.mats[(_e102.x & 255u)];
    m.color_a = _e107.color_a;
    m.color_b = _e107.color_b;
    m.emission = _e107.emission;
    m.phys = _e107.phys;
    m.thermo = _e107.thermo;
    m.burn = _e107.burn;
    m.optics = _e107.optics;
    m.scatter = _e107.scatter;
    m.ids = _e107.ids;
    m.ids2_ = _e107.ids2_;
    m.misc = _e107.misc;
    m.surface = _e107.surface;
    m.sss = _e107.sss;
    m.sss_color = _e107.sss_color;
    m.optics2_ = _e107.optics2_;
    m.pal0_ = _e107.pal0_;
    m.pal1_ = _e107.pal1_;
    m.pal2_ = _e107.pal2_;
    m.pal3_ = _e107.pal3_;
    m.accent = _e107.accent;
    m.flame = _e107.flame;
    let _e152 = m.optics2_[0u];
    pen = max(_e152, 0.05f);
    let _e154 = p;
    let _e155 = textureLoad(albedo_img, _e154, 0i);
    alb = _e155.xyz;
    let _e157 = p;
    pos = (vec2<f32>(_e157) + vec2(0.5f));
    src = vec3<f32>(0f, 0f, 0f);
    inner = vec3<f32>(0f, 0f, 0f);
    cnt = 0f;
    k = 0i;
    loop {
        let _e161 = k;
        if (_e161 < 4i) {
            let _e163 = p;
            let _e164 = k;
            indexable = array<vec2<i32>, 4>(vec2<i32>(1i, 0i), vec2<i32>(-1i, 0i), vec2<i32>(0i, 1i), vec2<i32>(0i, -1i));
            let _e166 = indexable[_e164];
            q_1 = (_e163 + _e166);
            let _e168 = q_1;
            param_2 = _e168;
            let _e169 = n_1;
            param_3 = _e169;
            let _e170 = dense_u0028_vi2_u003b_vi2_u003b((&param_2), (&param_3));
            if _e170 {
                let _e171 = q_1;
                let _e172 = textureLoad(prev_img, _e171, 0i);
                let _e174 = inner;
                inner = (_e174 + _e172.xyz);
                let _e176 = cnt;
                cnt = (_e176 + 1f);
            } else {
                let _e178 = q_1;
                let _e180 = all((_e178 >= vec2<i32>(0i, 0i)));
                phi_296_ = _e180;
                if _e180 {
                    let _e181 = q_1;
                    let _e182 = n_1;
                    phi_296_ = all((_e181 < _e182));
                }
                let _e186 = phi_296_;
                if _e186 {
                    let _e187 = src;
                    let _e188 = pos;
                    let _e189 = k;
                    indexable_1 = array<vec2<i32>, 4>(vec2<i32>(1i, 0i), vec2<i32>(-1i, 0i), vec2<i32>(0i, 1i), vec2<i32>(0i, -1i));
                    let _e191 = indexable_1[_e189];
                    let _e195 = n_1;
                    let _e198 = textureSampleLevel(fluence_tex, fluence_tex_smp, ((_e188 + (vec2<f32>(_e191) * 1.5f)) / vec2<f32>(_e195)), 0f);
                    src = max(_e187, (_e198.xyz * 2f));
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e202 = k;
            k = (_e202 + 1i);
        }
    }
    let _e204 = pen;
    a = exp((-1f / _e204));
    let _e207 = alb;
    let _e209 = alb[0u];
    let _e211 = alb[1u];
    let _e213 = alb[2u];
    tint = mix(vec3<f32>(1f, 1f, 1f), (_e207 / vec3(max(max(_e209, max(_e211, _e213)), 0.05f))), vec3(0.35f));
    let _e221 = cnt;
    if (_e221 > 0f) {
        let _e223 = inner;
        let _e224 = cnt;
        let _e227 = a;
        let _e229 = tint;
        local = (((_e223 / vec3(_e224)) * _e227) * _e229);
    } else {
        local = vec3<f32>(0f, 0f, 0f);
    }
    let _e231 = local;
    diffused = _e231;
    let _e232 = src;
    let _e233 = diffused;
    L = max(_e232, _e233);
    let _e235 = L;
    param_4 = _e235;
    let _e236 = web_isnan_u0028_vf3_u003b((&param_4));
    let _e237 = any(_e236);
    phi_380_ = _e237;
    if !(_e237) {
        let _e239 = L;
        param_5 = _e239;
        let _e240 = web_isinf_u0028_vf3_u003b((&param_5));
        phi_380_ = any(_e240);
    }
    let _e243 = phi_380_;
    if _e243 {
        L = vec3<f32>(0f, 0f, 0f);
    }
    let _e244 = p;
    let _e245 = L;
    textureStore(out_img, _e244, vec4<f32>(_e245.x, _e245.y, _e245.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
