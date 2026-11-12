struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Expo {
    lsum: i32,
    lcount: u32,
    ev: f32,
    mult: f32,
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

struct Expo_1 {
    lsum: atomic<i32>,
    lcount: atomic<u32>,
    ev: f32,
    mult: f32,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(1) 
var<storage, read_write> ex: Expo_1;
@group(0) @binding(2) 
var<uniform> rp: RenderParams;
var<private> gl_LocalInvocationIndex_1: u32;
var<workgroup> s_sum: atomic<i32>;
var<workgroup> s_cnt: atomic<u32>;
@group(0) @binding(0) 
var hdr: texture_2d<f32>;

fn luminance_u0028_vf3_u003b(c: ptr<function, vec3<f32>>) -> f32 {
    let _e37 = (*c);
    return dot(_e37, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn web_isinf_u0028_f1_u003b(x: ptr<function, f32>) -> bool {
    let _e37 = (*x);
    return (abs(_e37) > 340000000000000000000000000000000000000f);
}

fn web_isnan_u0028_f1_u003b(x_1: ptr<function, f32>) -> bool {
    let _e37 = (*x_1);
    let _e38 = (*x_1);
    return (_e37 != _e38);
}

fn main_1() {
    var avg: f32;
    var local: f32;
    var target_: f32;
    var cur: f32;
    var param: f32;
    var param_1: f32;
    var rate: f32;
    var local_1: f32;
    var p: vec2<i32>;
    var l: f32;
    var param_2: vec3<f32>;
    var lg: f32;
    var phi_136_: bool;
    var phi_144_: bool;

    let _e50 = pc.i1_[0u];
    if (_e50 == 1i) {
        let _e52 = gl_GlobalInvocationID_1;
        if all((_e52.xy == vec2<u32>(0u, 0u))) {
            let _e57 = atomicLoad((&ex.lcount));
            if (_e57 > 0u) {
                let _e60 = atomicLoad((&ex.lsum));
                let _e64 = atomicLoad((&ex.lcount));
                local = ((f32(_e60) / 32f) / f32(_e64));
            } else {
                local = -2.5f;
            }
            let _e67 = local;
            avg = _e67;
            let _e68 = avg;
            let _e72 = rp.expo2_[0u];
            target_ = ((-2.473931f - _e68) + _e72);
            let _e74 = target_;
            let _e77 = rp.expo[0u];
            let _e80 = rp.expo[1u];
            target_ = clamp(_e74, _e77, _e80);
            let _e84 = rp.expo2_[1u];
            if (_e84 < 0.5f) {
                let _e88 = rp.expo2_[2u];
                target_ = _e88;
            }
            let _e90 = ex.ev;
            cur = _e90;
            let _e91 = cur;
            param = _e91;
            let _e92 = web_isnan_u0028_f1_u003b((&param));
            phi_136_ = _e92;
            if !(_e92) {
                let _e94 = cur;
                param_1 = _e94;
                let _e95 = web_isinf_u0028_f1_u003b((&param_1));
                phi_136_ = _e95;
            }
            let _e97 = phi_136_;
            phi_144_ = _e97;
            if !(_e97) {
                let _e99 = cur;
                phi_144_ = (abs(_e99) > 30f);
            }
            let _e103 = phi_144_;
            if _e103 {
                let _e104 = target_;
                cur = _e104;
            }
            let _e105 = target_;
            let _e106 = cur;
            if (_e105 > _e106) {
                let _e110 = rp.expo[2u];
                local_1 = _e110;
            } else {
                let _e113 = rp.expo[3u];
                local_1 = _e113;
            }
            let _e114 = local_1;
            rate = _e114;
            let _e115 = target_;
            let _e116 = cur;
            let _e118 = rate;
            let _e122 = rp.expo2_[3u];
            let _e127 = cur;
            cur = (_e127 + ((_e115 - _e116) * (1f - exp((-(_e118) * _e122)))));
            let _e129 = cur;
            ex.ev = _e129;
            let _e131 = cur;
            ex.mult = exp2(_e131);
            atomicStore((&ex.lsum), 0i);
            atomicStore((&ex.lcount), 0u);
        }
        return;
    }
    let _e136 = gl_LocalInvocationIndex_1;
    if (_e136 == 0u) {
        atomicStore((&s_sum), 0i);
        atomicStore((&s_cnt), 0u);
    }
    workgroupBarrier();
    let _e138 = gl_GlobalInvocationID_1;
    p = (bitcast<vec2<i32>>(_e138.xy) * vec2(2i));
    let _e143 = p;
    let _e145 = pc.i0_;
    if all((_e143 < _e145.xy)) {
        let _e149 = p;
        let _e150 = textureLoad(hdr, _e149, 0i);
        param_2 = _e150.xyz;
        let _e152 = luminance_u0028_vf3_u003b((&param_2));
        l = _e152;
        let _e153 = l;
        lg = clamp(log2(max(_e153, 0.0001f)), -12f, 12f);
        let _e157 = lg;
        let _e160 = atomicAdd((&s_sum), i32((_e157 * 32f)));
        let _e161 = atomicAdd((&s_cnt), 1u);
    }
    workgroupBarrier();
    let _e162 = gl_LocalInvocationIndex_1;
    if (_e162 == 0u) {
        let _e165 = atomicLoad((&s_sum));
        let _e166 = atomicAdd((&ex.lsum), _e165);
        let _e168 = atomicLoad((&s_cnt));
        let _e169 = atomicAdd((&ex.lcount), _e168);
    }
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>, @builtin(local_invocation_index) gl_LocalInvocationIndex: u32) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1();
}
