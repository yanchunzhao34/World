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

struct Expo {
    lsum: i32,
    lcount: u32,
    ev: f32,
    mult: f32,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var hdr: texture_2d<f32>;
@group(0) @binding(1) 
var bloom_tex: texture_2d<f32>;
@group(2) @binding(1) 
var bloom_tex_smp: sampler;
@group(0) @binding(4) 
var<uniform> rp: RenderParams;
@group(0) @binding(2) 
var<storage> ex: Expo;
@group(0) @binding(3) 
var lut: texture_3d<f32>;
@group(2) @binding(3) 
var lut_smp: sampler;
@group(0) @binding(6) 
var cost_img: texture_2d<f32>;
@group(0) @binding(5) 
var out_img: texture_storage_2d<rgba8unorm,write>;

fn u01_u0028_u1_u003b(x: ptr<function, u32>) -> f32 {
    let _e102 = (*x);
    return (f32((_e102 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e102 = (*v);
    (*v) = ((_e102 * vec3(1664525u)) + vec3(1013904223u));
    let _e108 = (*v)[1u];
    let _e110 = (*v)[2u];
    let _e113 = (*v)[0u];
    (*v)[0u] = (_e113 + (_e108 * _e110));
    let _e117 = (*v)[2u];
    let _e119 = (*v)[0u];
    let _e122 = (*v)[1u];
    (*v)[1u] = (_e122 + (_e117 * _e119));
    let _e126 = (*v)[0u];
    let _e128 = (*v)[1u];
    let _e131 = (*v)[2u];
    (*v)[2u] = (_e131 + (_e126 * _e128));
    let _e134 = (*v);
    let _e138 = (*v);
    (*v) = (_e138 ^ (_e134 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e141 = (*v)[1u];
    let _e143 = (*v)[2u];
    let _e146 = (*v)[0u];
    (*v)[0u] = (_e146 + (_e141 * _e143));
    let _e150 = (*v)[2u];
    let _e152 = (*v)[0u];
    let _e155 = (*v)[1u];
    (*v)[1u] = (_e155 + (_e150 * _e152));
    let _e159 = (*v)[0u];
    let _e161 = (*v)[1u];
    let _e164 = (*v)[2u];
    (*v)[2u] = (_e164 + (_e159 * _e161));
    let _e167 = (*v);
    return _e167;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param: vec3<u32>;

    let _e103 = (*v_1);
    param = _e103;
    let _e104 = pcg3d_u0028_vu3_u003b((&param));
    return _e104.x;
}

fn agx_eotf_u0028_vf3_u003b(v_2: ptr<function, vec3<f32>>) -> vec3<f32> {
    let _e102 = (*v_2);
    return (mat3x3<f32>(vec3<f32>(1.196879f, -0.052896854f, -0.052971635f), vec3<f32>(-0.09802088f, 1.1519032f, -0.09804345f), vec3<f32>(-0.09902974f, -0.098961174f, 1.1510737f)) * _e102);
}

fn agx_look_u0028_vf3_u003b(v_3: ptr<function, vec3<f32>>) -> vec3<f32> {
    var luma: f32;

    let _e103 = (*v_3);
    luma = dot(_e103, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e105 = (*v_3);
    (*v_3) = pow(max(_e105, vec3<f32>(0f, 0f, 0f)), vec3<f32>(1.35f, 1.35f, 1.35f));
    let _e108 = luma;
    let _e109 = (*v_3);
    let _e110 = luma;
    return (vec3(_e108) + ((_e109 - vec3(_e110)) * 1.4f));
}

fn agx_contrast_u0028_vf3_u003b(x_1: ptr<function, vec3<f32>>) -> vec3<f32> {
    var x2_: vec3<f32>;
    var x4_: vec3<f32>;

    let _e104 = (*x_1);
    let _e105 = (*x_1);
    x2_ = (_e104 * _e105);
    let _e107 = x2_;
    let _e108 = x2_;
    x4_ = (_e107 * _e108);
    let _e110 = x4_;
    let _e112 = x2_;
    let _e114 = x4_;
    let _e116 = (*x_1);
    let _e119 = x4_;
    let _e122 = x2_;
    let _e124 = (*x_1);
    let _e127 = x2_;
    let _e130 = (*x_1);
    return ((((((((_e110 * 15.5f) * _e112) - ((_e114 * 40.14f) * _e116)) + (_e119 * 31.96f)) - ((_e122 * 6.868f) * _e124)) + (_e127 * 0.4298f)) + (_e130 * 0.1191f)) - vec3(0.00232f));
}

fn agx_u0028_vf3_u003b(v_4: ptr<function, vec3<f32>>) -> vec3<f32> {
    var param_1: vec3<f32>;

    let _e103 = (*v_4);
    (*v_4) = (mat3x3<f32>(vec3<f32>(0.84247905f, 0.042328242f, 0.042375654f), vec3<f32>(0.0784336f, 0.87846863f, 0.0784336f), vec3<f32>(0.079223745f, 0.07916613f, 0.879143f)) * _e103);
    let _e105 = (*v_4);
    (*v_4) = clamp(log2(max(_e105, vec3<f32>(0.0000000001f, 0.0000000001f, 0.0000000001f))), vec3(-12.47393f), vec3(4.026069f));
    let _e111 = (*v_4);
    (*v_4) = ((_e111 - vec3(-12.47393f)) / vec3(16.499998f));
    let _e116 = (*v_4);
    param_1 = _e116;
    let _e117 = agx_contrast_u0028_vf3_u003b((&param_1));
    return _e117;
}

fn luminance_u0028_vf3_u003b(c: ptr<function, vec3<f32>>) -> f32 {
    let _e102 = (*c);
    return dot(_e102, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn main_1() {
    var p: vec2<i32>;
    var uv: vec2<f32>;
    var c_1: vec3<f32>;
    var bl: vec3<f32>;
    var local: f32;
    var local_1: f32;
    var param_2: vec3<f32>;
    var d: vec3<f32>;
    var param_3: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec3<f32>;
    var luma_1: f32;
    var graded: vec3<f32>;
    var n: f32;
    var param_6: vec3<u32>;
    var param_7: u32;
    var param_8: vec3<u32>;
    var param_9: u32;
    var c_2: f32;
    var heat: vec3<f32>;
    var local_2: vec3<f32>;
    var local_3: vec3<f32>;
    var param_10: vec3<f32>;

    let _e124 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e124.xy);
    let _e127 = p;
    let _e129 = pc.i0_;
    if any((_e127 >= _e129.xy)) {
        return;
    }
    let _e133 = p;
    let _e138 = pc.i0_;
    uv = ((vec2<f32>(_e133) + vec2(0.5f)) / vec2<f32>(_e138.xy));
    let _e142 = p;
    let _e143 = textureLoad(hdr, _e142, 0i);
    c_1 = _e143.xyz;
    let _e145 = uv;
    let _e146 = textureSampleLevel(bloom_tex, bloom_tex_smp, _e145, 0f);
    bl = _e146.xyz;
    let _e148 = bl;
    let _e151 = rp.bloom[2u];
    let _e153 = c_1;
    c_1 = (_e153 + (_e148 * _e151));
    let _e156 = ex.mult;
    if (_e156 > 0f) {
        let _e159 = ex.mult;
        local = _e159;
    } else {
        local = 1f;
    }
    let _e160 = local;
    let _e161 = c_1;
    c_1 = (_e161 * _e160);
    let _e165 = rp.look3_[3u];
    if (_e165 > 0f) {
        let _e169 = rp.look3_[3u];
        local_1 = _e169;
    } else {
        local_1 = 1f;
    }
    let _e170 = local_1;
    let _e171 = c_1;
    c_1 = (_e171 * _e170);
    let _e175 = rp.look4_[0u];
    let _e178 = c_1;
    param_2 = _e178;
    let _e179 = luminance_u0028_vf3_u003b((&param_2));
    let _e184 = c_1;
    c_1 = (_e184 + (((vec3<f32>(0.9f, 0.95f, 1.05f) * _e175) * 0.05f) * exp((-(_e179) * 12f))));
    let _e186 = c_1;
    param_3 = _e186;
    let _e187 = agx_u0028_vf3_u003b((&param_3));
    param_4 = _e187;
    let _e188 = agx_look_u0028_vf3_u003b((&param_4));
    param_5 = _e188;
    let _e189 = agx_eotf_u0028_vf3_u003b((&param_5));
    d = _e189;
    let _e190 = d;
    d = clamp(_e190, vec3(0f), vec3(1f));
    let _e194 = d;
    luma_1 = dot(_e194, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
    let _e196 = luma_1;
    let _e198 = d;
    let _e201 = rp.fx[2u];
    d = mix(vec3(_e196), _e198, vec3(_e201));
    let _e204 = d;
    let _e209 = rp.fx[3u];
    d = clamp((((_e204 - vec3(0.5f)) * _e209) + vec3(0.5f)), vec3(0f), vec3(1f));
    let _e216 = d;
    let _e220 = textureSampleLevel(lut, lut_smp, ((_e216 * 0.96875f) + vec3(0.015625f)), 0f);
    graded = _e220.xyz;
    let _e222 = d;
    let _e223 = graded;
    let _e226 = rp.misc[1u];
    d = mix(_e222, _e223, vec3(_e226));
    let _e229 = p;
    let _e230 = bitcast<vec2<u32>>(_e229);
    let _e233 = pc.i0_[2u];
    param_6 = vec3<u32>(_e230.x, _e230.y, bitcast<u32>(_e233));
    let _e238 = hash1_u0028_vu3_u003b((&param_6));
    param_7 = _e238;
    let _e239 = u01_u0028_u1_u003b((&param_7));
    let _e240 = p;
    let _e243 = bitcast<vec2<u32>>((_e240 + vec2(977i)));
    let _e246 = pc.i0_[2u];
    param_8 = vec3<u32>(_e243.x, _e243.y, bitcast<u32>(_e246));
    let _e251 = hash1_u0028_vu3_u003b((&param_8));
    param_9 = _e251;
    let _e252 = u01_u0028_u1_u003b((&param_9));
    n = ((_e239 + _e252) - 1f);
    let _e255 = n;
    let _e257 = d;
    d = (_e257 + vec3((_e255 / 255f)));
    let _e262 = rp.look3_[2u];
    if (_e262 > 0.5f) {
        let _e264 = p;
        let _e265 = textureLoad(cost_img, _e264, 0i);
        c_2 = clamp((_e265.w / 160f), 0f, 1f);
        let _e269 = c_2;
        if (_e269 < 0.33f) {
            let _e271 = c_2;
            local_2 = mix(vec3<f32>(0.05f, 0.1f, 0.6f), vec3<f32>(0.1f, 0.8f, 0.3f), vec3((_e271 / 0.33f)));
        } else {
            let _e275 = c_2;
            if (_e275 < 0.66f) {
                let _e277 = c_2;
                local_3 = mix(vec3<f32>(0.1f, 0.8f, 0.3f), vec3<f32>(1f, 0.9f, 0.1f), vec3(((_e277 - 0.33f) / 0.33f)));
            } else {
                let _e282 = c_2;
                local_3 = mix(vec3<f32>(1f, 0.9f, 0.1f), vec3<f32>(1f, 0.15f, 0.1f), vec3(((_e282 - 0.66f) / 0.34f)));
            }
            let _e287 = local_3;
            local_2 = _e287;
        }
        let _e288 = local_2;
        heat = _e288;
        let _e289 = d;
        param_10 = _e289;
        let _e290 = luminance_u0028_vf3_u003b((&param_10));
        let _e293 = heat;
        d = mix((vec3(_e290) * 0.35f), _e293, vec3(0.75f));
    }
    let _e296 = p;
    let _e297 = d;
    let _e300 = clamp(_e297, vec3(0f), vec3(1f));
    textureStore(out_img, _e296, vec4<f32>(_e300.x, _e300.y, _e300.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
