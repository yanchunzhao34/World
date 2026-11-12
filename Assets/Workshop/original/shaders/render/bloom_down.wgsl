struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

@group(1) @binding(0) 
var<uniform> pc: Params;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(0) 
var src: texture_2d<f32>;
@group(2) @binding(0) 
var src_smp: sampler;
@group(0) @binding(1) 
var dst: texture_storage_2d<rgba16float,write>;

fn luminance_u0028_vf3_u003b(c: ptr<function, vec3<f32>>) -> f32 {
    let _e43 = (*c);
    return dot(_e43, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn karis_u0028_vf3_u003b(c_1: ptr<function, vec3<f32>>) -> f32 {
    var param: vec3<f32>;

    let _e44 = (*c_1);
    param = _e44;
    let _e45 = luminance_u0028_vf3_u003b((&param));
    return (1f / (1f + _e45));
}

fn prefilter_u0028_vf3_u003b(c_2: ptr<function, vec3<f32>>) -> vec3<f32> {
    var br: f32;
    var th: f32;
    var knee: f32;
    var soft: f32;
    var contrib: f32;

    let _e49 = (*c_2)[0u];
    let _e51 = (*c_2)[1u];
    let _e53 = (*c_2)[2u];
    br = max(_e49, max(_e51, _e53));
    let _e58 = pc.f0_[0u];
    th = _e58;
    let _e59 = th;
    let _e62 = pc.f0_[1u];
    knee = ((_e59 * _e62) + 0.0001f);
    let _e65 = br;
    let _e66 = th;
    let _e68 = knee;
    let _e70 = knee;
    soft = clamp(((_e65 - _e66) + _e68), 0f, (2f * _e70));
    let _e73 = soft;
    let _e74 = soft;
    let _e76 = knee;
    soft = ((_e73 * _e74) / (4f * _e76));
    let _e79 = soft;
    let _e80 = br;
    let _e81 = th;
    let _e84 = br;
    contrib = (max(_e79, (_e80 - _e81)) / max(_e84, 0.0001f));
    let _e87 = (*c_2);
    let _e88 = contrib;
    return (_e87 * _e88);
}

fn main_1() {
    var p: vec2<i32>;
    var texel: vec2<f32>;
    var uv: vec2<f32>;
    var a: vec3<f32>;
    var b: vec3<f32>;
    var c_3: vec3<f32>;
    var d: vec3<f32>;
    var e: vec3<f32>;
    var f: vec3<f32>;
    var g: vec3<f32>;
    var h: vec3<f32>;
    var i: vec3<f32>;
    var j: vec3<f32>;
    var k: vec3<f32>;
    var l: vec3<f32>;
    var m: vec3<f32>;
    var g0_: vec3<f32>;
    var g1_: vec3<f32>;
    var g2_: vec3<f32>;
    var g3_: vec3<f32>;
    var g4_: vec3<f32>;
    var param_1: vec3<f32>;
    var param_2: vec3<f32>;
    var param_3: vec3<f32>;
    var param_4: vec3<f32>;
    var param_5: vec3<f32>;
    var w0_: f32;
    var param_6: vec3<f32>;
    var w1_: f32;
    var param_7: vec3<f32>;
    var w2_: f32;
    var param_8: vec3<f32>;
    var w3_: f32;
    var param_9: vec3<f32>;
    var w4_: f32;
    var param_10: vec3<f32>;
    var res: vec3<f32>;

    let _e79 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e79.xy);
    let _e82 = p;
    let _e84 = pc.i0_;
    if any((_e82 >= _e84.xy)) {
        return;
    }
    let _e88 = textureDimensions(src, 0i);
    texel = (vec2(1f) / vec2<f32>(vec2<i32>(_e88)));
    let _e93 = p;
    let _e98 = pc.i0_;
    uv = ((vec2<f32>(_e93) + vec2(0.5f)) / vec2<f32>(_e98.xy));
    let _e102 = uv;
    let _e103 = texel;
    let _e106 = textureSampleLevel(src, src_smp, (_e102 + (_e103 * vec2<f32>(-2f, -2f))), 0f);
    a = _e106.xyz;
    let _e108 = uv;
    let _e109 = texel;
    let _e112 = textureSampleLevel(src, src_smp, (_e108 + (_e109 * vec2<f32>(0f, -2f))), 0f);
    b = _e112.xyz;
    let _e114 = uv;
    let _e115 = texel;
    let _e118 = textureSampleLevel(src, src_smp, (_e114 + (_e115 * vec2<f32>(2f, -2f))), 0f);
    c_3 = _e118.xyz;
    let _e120 = uv;
    let _e121 = texel;
    let _e124 = textureSampleLevel(src, src_smp, (_e120 + (_e121 * vec2<f32>(-2f, 0f))), 0f);
    d = _e124.xyz;
    let _e126 = uv;
    let _e127 = textureSampleLevel(src, src_smp, _e126, 0f);
    e = _e127.xyz;
    let _e129 = uv;
    let _e130 = texel;
    let _e133 = textureSampleLevel(src, src_smp, (_e129 + (_e130 * vec2<f32>(2f, 0f))), 0f);
    f = _e133.xyz;
    let _e135 = uv;
    let _e136 = texel;
    let _e139 = textureSampleLevel(src, src_smp, (_e135 + (_e136 * vec2<f32>(-2f, 2f))), 0f);
    g = _e139.xyz;
    let _e141 = uv;
    let _e142 = texel;
    let _e145 = textureSampleLevel(src, src_smp, (_e141 + (_e142 * vec2<f32>(0f, 2f))), 0f);
    h = _e145.xyz;
    let _e147 = uv;
    let _e148 = texel;
    let _e151 = textureSampleLevel(src, src_smp, (_e147 + (_e148 * vec2<f32>(2f, 2f))), 0f);
    i = _e151.xyz;
    let _e153 = uv;
    let _e154 = texel;
    let _e157 = textureSampleLevel(src, src_smp, (_e153 + (_e154 * vec2<f32>(-1f, -1f))), 0f);
    j = _e157.xyz;
    let _e159 = uv;
    let _e160 = texel;
    let _e163 = textureSampleLevel(src, src_smp, (_e159 + (_e160 * vec2<f32>(1f, -1f))), 0f);
    k = _e163.xyz;
    let _e165 = uv;
    let _e166 = texel;
    let _e169 = textureSampleLevel(src, src_smp, (_e165 + (_e166 * vec2<f32>(-1f, 1f))), 0f);
    l = _e169.xyz;
    let _e171 = uv;
    let _e172 = texel;
    let _e175 = textureSampleLevel(src, src_smp, (_e171 + (_e172 * vec2<f32>(1f, 1f))), 0f);
    m = _e175.xyz;
    let _e179 = pc.i1_[0u];
    if (_e179 != 0i) {
        let _e181 = a;
        let _e182 = b;
        let _e184 = d;
        let _e186 = e;
        g0_ = ((((_e181 + _e182) + _e184) + _e186) * 0.25f);
        let _e189 = b;
        let _e190 = c_3;
        let _e192 = e;
        let _e194 = f;
        g1_ = ((((_e189 + _e190) + _e192) + _e194) * 0.25f);
        let _e197 = d;
        let _e198 = e;
        let _e200 = g;
        let _e202 = h;
        g2_ = ((((_e197 + _e198) + _e200) + _e202) * 0.25f);
        let _e205 = e;
        let _e206 = f;
        let _e208 = h;
        let _e210 = i;
        g3_ = ((((_e205 + _e206) + _e208) + _e210) * 0.25f);
        let _e213 = j;
        let _e214 = k;
        let _e216 = l;
        let _e218 = m;
        g4_ = ((((_e213 + _e214) + _e216) + _e218) * 0.25f);
        let _e221 = g0_;
        param_1 = _e221;
        let _e222 = prefilter_u0028_vf3_u003b((&param_1));
        g0_ = _e222;
        let _e223 = g1_;
        param_2 = _e223;
        let _e224 = prefilter_u0028_vf3_u003b((&param_2));
        g1_ = _e224;
        let _e225 = g2_;
        param_3 = _e225;
        let _e226 = prefilter_u0028_vf3_u003b((&param_3));
        g2_ = _e226;
        let _e227 = g3_;
        param_4 = _e227;
        let _e228 = prefilter_u0028_vf3_u003b((&param_4));
        g3_ = _e228;
        let _e229 = g4_;
        param_5 = _e229;
        let _e230 = prefilter_u0028_vf3_u003b((&param_5));
        g4_ = _e230;
        let _e231 = g0_;
        param_6 = _e231;
        let _e232 = karis_u0028_vf3_u003b((&param_6));
        w0_ = (_e232 * 0.125f);
        let _e234 = g1_;
        param_7 = _e234;
        let _e235 = karis_u0028_vf3_u003b((&param_7));
        w1_ = (_e235 * 0.125f);
        let _e237 = g2_;
        param_8 = _e237;
        let _e238 = karis_u0028_vf3_u003b((&param_8));
        w2_ = (_e238 * 0.125f);
        let _e240 = g3_;
        param_9 = _e240;
        let _e241 = karis_u0028_vf3_u003b((&param_9));
        w3_ = (_e241 * 0.125f);
        let _e243 = g4_;
        param_10 = _e243;
        let _e244 = karis_u0028_vf3_u003b((&param_10));
        w4_ = (_e244 * 0.5f);
        let _e246 = g0_;
        let _e247 = w0_;
        let _e249 = g1_;
        let _e250 = w1_;
        let _e253 = g2_;
        let _e254 = w2_;
        let _e257 = g3_;
        let _e258 = w3_;
        let _e261 = g4_;
        let _e262 = w4_;
        let _e265 = w0_;
        let _e266 = w1_;
        let _e268 = w2_;
        let _e270 = w3_;
        let _e272 = w4_;
        res = ((((((_e246 * _e247) + (_e249 * _e250)) + (_e253 * _e254)) + (_e257 * _e258)) + (_e261 * _e262)) / vec3(((((_e265 + _e266) + _e268) + _e270) + _e272)));
    } else {
        let _e276 = e;
        let _e278 = a;
        let _e279 = c_3;
        let _e281 = g;
        let _e283 = i;
        let _e287 = b;
        let _e288 = d;
        let _e290 = f;
        let _e292 = h;
        let _e296 = j;
        let _e297 = k;
        let _e299 = l;
        let _e301 = m;
        res = ((((_e276 * 0.125f) + ((((_e278 + _e279) + _e281) + _e283) * 0.03125f)) + ((((_e287 + _e288) + _e290) + _e292) * 0.0625f)) + ((((_e296 + _e297) + _e299) + _e301) * 0.125f));
    }
    let _e305 = p;
    let _e306 = res;
    let _e307 = max(_e306, vec3<f32>(0f, 0f, 0f));
    textureStore(dst, _e305, vec4<f32>(_e307.x, _e307.y, _e307.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
