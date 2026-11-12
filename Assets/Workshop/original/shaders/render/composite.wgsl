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

var<private> g_open: f32;
@group(0) @binding(8) 
var<uniform> rp: RenderParams;
@group(0) @binding(12) 
var day_tex: texture_2d<f32>;
@group(2) @binding(12) 
var day_tex_smp: sampler;
var<private> g_world: vec2<f32>;
@group(0) @binding(13) 
var beam_tex: texture_2d<f32>;
@group(2) @binding(13) 
var beam_tex_smp: sampler;
@group(0) @binding(3) 
var fluence_tex: texture_2d<f32>;
@group(2) @binding(3) 
var fluence_tex_smp: sampler;
@group(0) @binding(15) 
var cha_tex: texture_2d<f32>;
@group(2) @binding(15) 
var cha_tex_smp: sampler;
@group(0) @binding(16) 
var chb_tex: texture_2d<f32>;
@group(2) @binding(16) 
var chb_tex_smp: sampler;
@group(0) @binding(1) 
var emissive_img: texture_2d<f32>;
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var albedo_img: texture_2d<f32>;
@group(0) @binding(2) 
var gaux_img: texture_2d<f32>;
@group(0) @binding(6) 
var cells: texture_2d<u32>;
@group(0) @binding(7) 
var<storage> unnamed: Materials;
@group(0) @binding(4) 
var ldir_tex: texture_2d<f32>;
@group(2) @binding(4) 
var ldir_tex_smp: sampler;
@group(0) @binding(14) 
var beam_dir_tex: texture_2d<f32>;
@group(2) @binding(14) 
var beam_dir_tex_smp: sampler;
@group(0) @binding(11) 
var sub_img: texture_2d<f32>;
@group(0) @binding(5) 
var medium_tex: texture_2d<f32>;
@group(2) @binding(5) 
var medium_tex_smp: sampler;
@group(0) @binding(9) 
var l0s_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(10) 
var l0t_out: texture_storage_2d<rgba16float,write>;

fn web_isinf_u0028_vf3_u003b(x: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e161 = (*x);
    return (abs(_e161) > vec3<f32>(340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f, 340000000000000000000000000000000000000f));
}

fn web_isnan_u0028_vf3_u003b(x_1: ptr<function, vec3<f32>>) -> vec3<bool> {
    let _e161 = (*x_1);
    let _e162 = (*x_1);
    return (_e161 != _e162);
}

fn flame_radiance_u0028_f1_u003b(f: ptr<function, f32>) -> vec3<f32> {
    var t: f32;
    var c: vec3<f32>;

    let _e163 = (*f);
    if (_e163 <= 0.001f) {
        return vec3<f32>(0f, 0f, 0f);
    }
    let _e165 = (*f);
    t = (1f - exp((-(_e165) * 0.9f)));
    let _e170 = t;
    c = mix(vec3<f32>(0.9f, 0.12f, 0.02f), vec3<f32>(1f, 0.45f, 0.08f), vec3(smoothstep(0f, 0.5f, _e170)));
    let _e174 = c;
    let _e175 = t;
    c = mix(_e174, vec3<f32>(1f, 0.86f, 0.55f), vec3(smoothstep(0.55f, 1f, _e175)));
    let _e179 = c;
    let _e180 = t;
    let _e184 = rp.medium[2u];
    return ((_e179 * _e180) * _e184);
}

fn flame_radiance_u0028_vf4_u003b(md: ptr<function, vec4<f32>>) -> vec3<f32> {
    var o: vec3<f32>;
    var param: f32;
    var h: f32;
    var t_1: f32;
    var blue: vec3<f32>;
    var white: vec3<f32>;
    var tinted: vec3<f32>;
    var w: f32;
    var local: f32;
    var phi_340_: bool;

    let _e171 = (*md)[2u];
    param = _e171;
    let _e172 = flame_radiance_u0028_f1_u003b((&param));
    o = _e172;
    let _e174 = (*md)[2u];
    let _e175 = (_e174 <= 0.001f);
    phi_340_ = _e175;
    if !(_e175) {
        let _e178 = (*md)[3u];
        phi_340_ = (_e178 <= 0.001f);
    }
    let _e181 = phi_340_;
    if _e181 {
        let _e182 = o;
        return _e182;
    }
    let _e184 = (*md)[3u];
    let _e186 = (*md)[2u];
    h = clamp((_e184 / _e186), 0f, 1f);
    let _e190 = (*md)[2u];
    t_1 = (1f - exp((-(_e190) * 0.9f)));
    let _e195 = t_1;
    let _e199 = rp.medium[2u];
    blue = (((vec3<f32>(0.15f, 0.35f, 1f) * _e195) * _e199) * 0.8f);
    let _e202 = t_1;
    let _e206 = rp.medium[2u];
    white = (((vec3<f32>(1f, 0.98f, 0.95f) * _e202) * _e206) * 3f);
    let _e209 = h;
    let _e211 = blue;
    let _e212 = white;
    tinted = select(_e212, _e211, vec3((_e209 < 0.75f)));
    let _e215 = h;
    if (_e215 < 0.75f) {
        let _e217 = h;
        local = clamp((_e217 / 0.5f), 0f, 1f);
    } else {
        let _e220 = h;
        local = clamp(((_e220 - 0.5f) / 0.5f), 0f, 1f);
    }
    let _e224 = local;
    w = _e224;
    let _e225 = o;
    let _e226 = tinted;
    let _e227 = w;
    return mix(_e225, _e226, vec3(_e227));
}

fn u01_u0028_u1_u003b(x_2: ptr<function, u32>) -> f32 {
    let _e161 = (*x_2);
    return (f32((_e161 >> bitcast<u32>(8u))) * 0.000000059604645f);
}

fn pcg3d_u0028_vu3_u003b(v: ptr<function, vec3<u32>>) -> vec3<u32> {
    let _e161 = (*v);
    (*v) = ((_e161 * vec3(1664525u)) + vec3(1013904223u));
    let _e167 = (*v)[1u];
    let _e169 = (*v)[2u];
    let _e172 = (*v)[0u];
    (*v)[0u] = (_e172 + (_e167 * _e169));
    let _e176 = (*v)[2u];
    let _e178 = (*v)[0u];
    let _e181 = (*v)[1u];
    (*v)[1u] = (_e181 + (_e176 * _e178));
    let _e185 = (*v)[0u];
    let _e187 = (*v)[1u];
    let _e190 = (*v)[2u];
    (*v)[2u] = (_e190 + (_e185 * _e187));
    let _e193 = (*v);
    let _e197 = (*v);
    (*v) = (_e197 ^ (_e193 >> bitcast<vec3<u32>>(vec3(16u))));
    let _e200 = (*v)[1u];
    let _e202 = (*v)[2u];
    let _e205 = (*v)[0u];
    (*v)[0u] = (_e205 + (_e200 * _e202));
    let _e209 = (*v)[2u];
    let _e211 = (*v)[0u];
    let _e214 = (*v)[1u];
    (*v)[1u] = (_e214 + (_e209 * _e211));
    let _e218 = (*v)[0u];
    let _e220 = (*v)[1u];
    let _e223 = (*v)[2u];
    (*v)[2u] = (_e223 + (_e218 * _e220));
    let _e226 = (*v);
    return _e226;
}

fn hash1_u0028_vu3_u003b(v_1: ptr<function, vec3<u32>>) -> u32 {
    var param_1: vec3<u32>;

    let _e162 = (*v_1);
    param_1 = _e162;
    let _e163 = pcg3d_u0028_vu3_u003b((&param_1));
    return _e163.x;
}

fn hash21_u0028_vf2_u003b(p: ptr<function, vec2<f32>>) -> f32 {
    var param_2: vec3<u32>;
    var param_3: u32;

    let _e163 = (*p);
    let _e165 = vec2<i32>(floor(_e163));
    param_2 = bitcast<vec3<u32>>(vec3<i32>(_e165.x, _e165.y, 1777i));
    let _e170 = hash1_u0028_vu3_u003b((&param_2));
    param_3 = _e170;
    let _e171 = u01_u0028_u1_u003b((&param_3));
    return _e171;
}

fn vnoise_u0028_vf2_u003b(p_1: ptr<function, vec2<f32>>) -> f32 {
    var i: vec2<f32>;
    var f_1: vec2<f32>;
    var a: f32;
    var param_4: vec2<f32>;
    var b: f32;
    var param_5: vec2<f32>;
    var c_1: f32;
    var param_6: vec2<f32>;
    var d: f32;
    var param_7: vec2<f32>;

    let _e171 = (*p_1);
    i = floor(_e171);
    let _e173 = (*p_1);
    f_1 = fract(_e173);
    let _e175 = f_1;
    let _e176 = f_1;
    let _e178 = f_1;
    f_1 = ((_e175 * _e176) * (vec2(3f) - (_e178 * 2f)));
    let _e183 = i;
    param_4 = _e183;
    let _e184 = hash21_u0028_vf2_u003b((&param_4));
    a = _e184;
    let _e185 = i;
    param_5 = (_e185 + vec2<f32>(1f, 0f));
    let _e187 = hash21_u0028_vf2_u003b((&param_5));
    b = _e187;
    let _e188 = i;
    param_6 = (_e188 + vec2<f32>(0f, 1f));
    let _e190 = hash21_u0028_vf2_u003b((&param_6));
    c_1 = _e190;
    let _e191 = i;
    param_7 = (_e191 + vec2<f32>(1f, 1f));
    let _e193 = hash21_u0028_vf2_u003b((&param_7));
    d = _e193;
    let _e194 = a;
    let _e195 = b;
    let _e197 = f_1[0u];
    let _e199 = c_1;
    let _e200 = d;
    let _e202 = f_1[0u];
    let _e205 = f_1[1u];
    return mix(mix(_e194, _e195, _e197), mix(_e199, _e200, _e202), _e205);
}

fn daylight_u0028_vf2_u003b(x_3: ptr<function, vec2<f32>>) -> vec3<f32> {
    let _e161 = (*x_3);
    let _e162 = g_world;
    let _e164 = textureSampleLevel(day_tex, day_tex_smp, (_e161 / _e162), 0f);
    let _e166 = (*x_3);
    let _e167 = g_world;
    let _e169 = textureSampleLevel(beam_tex, beam_tex_smp, (_e166 / _e167), 0f);
    return (_e164.xyz + _e169.xyz);
}

fn luminance_u0028_vf3_u003b(c_2: ptr<function, vec3<f32>>) -> f32 {
    let _e161 = (*c_2);
    return dot(_e161, vec3<f32>(0.2126f, 0.7152f, 0.0722f));
}

fn ambient_hemi_u0028_vf2_u003b(n: ptr<function, vec2<f32>>) -> vec3<f32> {
    var up: f32;
    var local_1: f32;
    var sky: vec3<f32>;
    var ground: vec3<f32>;

    let _e165 = (*n);
    let _e166 = (*n);
    if (dot(_e165, _e166) > 0f) {
        let _e170 = (*n)[1u];
        local_1 = clamp(((-(_e170) * 0.5f) + 0.5f), 0f, 1f);
    } else {
        local_1 = 0.5f;
    }
    let _e175 = local_1;
    up = _e175;
    let _e177 = rp.ambient;
    sky = (_e177.xyz * vec3<f32>(0.9f, 1f, 1.2f));
    let _e181 = rp.ambient;
    ground = ((_e181.xyz * vec3<f32>(1.25f, 1f, 0.75f)) * 0.7f);
    let _e185 = ground;
    let _e186 = sky;
    let _e187 = up;
    let _e190 = g_open;
    return (mix(_e185, _e186, vec3(_e187)) * _e190);
}

fn caustic_u0028_vf2_u003b_f1_u003b(p_2: ptr<function, vec2<f32>>, t_2: ptr<function, f32>) -> f32 {
    var q: vec2<f32>;
    var a_1: f32;
    var param_8: vec2<f32>;
    var b_1: f32;
    var param_9: vec2<f32>;
    var c_3: f32;

    let _e168 = (*p_2);
    q = (_e168 * 0.22f);
    let _e170 = q;
    let _e171 = (*t_2);
    let _e173 = (*t_2);
    param_8 = (_e170 + vec2<f32>((_e171 * 0.35f), (_e173 * 0.21f)));
    let _e177 = vnoise_u0028_vf2_u003b((&param_8));
    a_1 = _e177;
    let _e178 = q;
    let _e180 = (*t_2);
    let _e183 = (*t_2);
    let _e187 = a_1;
    param_9 = (((_e178 * 1.37f) + vec2<f32>((-(_e180) * 0.27f), (_e183 * 0.31f))) + vec2((_e187 * 1.7f)));
    let _e191 = vnoise_u0028_vf2_u003b((&param_9));
    b_1 = _e191;
    let _e192 = a_1;
    let _e193 = b_1;
    c_3 = (1f - (abs((_e192 - _e193)) * 3.2f));
    let _e198 = c_3;
    return (pow(max(_e198, 0f), 5f) * 1.6f);
}

fn state_up_u0028_vi2_u003b(q_1: ptr<function, vec2<i32>>) -> u32 {
    var u: vec2<i32>;

    let _e162 = (*q_1);
    u = (_e162 - vec2<i32>(0i, 1i));
    let _e165 = u[1u];
    if (_e165 < 0i) {
        return 0u;
    }
    let _e167 = u;
    let _e168 = textureLoad(emissive_img, _e167, 0i);
    return u32((_e168.w + 0.5f));
}

fn ch_irradiance_u0028_vf3_u003b_vf4_u003b_vf4_u003b_vf2_u003b(a0_: ptr<function, vec3<f32>>, A: ptr<function, vec4<f32>>, B: ptr<function, vec4<f32>>, n_1: ptr<function, vec2<f32>>) -> vec3<f32> {
    var a1_: vec3<f32>;
    var b1_: vec3<f32>;
    var o1_: vec3<f32>;
    var l0_: f32;
    var o2_: f32;

    let _e169 = (*A);
    a1_ = _e169.xyz;
    let _e172 = (*A)[3u];
    let _e174 = (*B)[0u];
    let _e176 = (*B)[1u];
    b1_ = vec3<f32>(_e172, _e174, _e176);
    let _e178 = a1_;
    let _e180 = (*n_1)[0u];
    let _e182 = b1_;
    let _e184 = (*n_1)[1u];
    o1_ = (((_e178 * _e180) + (_e182 * _e184)) * 1.5707963f);
    let _e188 = (*a0_);
    l0_ = max(dot(_e188, vec3<f32>(0.2126f, 0.7152f, 0.0722f)), 0.00001f);
    let _e192 = (*B)[2u];
    let _e194 = (*n_1)[0u];
    let _e196 = (*n_1)[0u];
    let _e199 = (*n_1)[1u];
    let _e201 = (*n_1)[1u];
    let _e206 = (*B)[3u];
    let _e209 = (*n_1)[0u];
    let _e212 = (*n_1)[1u];
    o2_ = (((_e192 * ((_e194 * _e196) - (_e199 * _e201))) + (((_e206 * 2f) * _e209) * _e212)) * 0.6666667f);
    let _e216 = (*a0_);
    let _e218 = o1_;
    let _e220 = (*a0_);
    let _e221 = l0_;
    let _e224 = o2_;
    return max((((_e216 * 2f) + _e218) + ((_e220 / vec3(_e221)) * _e224)), vec3<f32>(0f, 0f, 0f));
}

fn irradiance_u0028_vf2_u003b_vf2_u003b(pos: ptr<function, vec2<f32>>, n_2: ptr<function, vec2<f32>>) -> vec3<f32> {
    var uv: vec2<f32>;
    var a0_1: vec3<f32>;
    var dirl: vec3<f32>;
    var param_10: vec3<f32>;
    var param_11: vec4<f32>;
    var param_12: vec4<f32>;
    var param_13: vec2<f32>;

    let _e169 = (*pos);
    let _e170 = g_world;
    uv = (_e169 / _e170);
    let _e172 = uv;
    let _e173 = textureSampleLevel(fluence_tex, fluence_tex_smp, _e172, 0f);
    a0_1 = _e173.xyz;
    let _e175 = uv;
    let _e176 = textureSampleLevel(cha_tex, cha_tex_smp, _e175, 0f);
    let _e177 = uv;
    let _e178 = textureSampleLevel(chb_tex, chb_tex_smp, _e177, 0f);
    let _e179 = a0_1;
    param_10 = _e179;
    param_11 = _e176;
    param_12 = _e178;
    let _e180 = (*n_2);
    param_13 = _e180;
    let _e181 = ch_irradiance_u0028_vf3_u003b_vf4_u003b_vf4_u003b_vf2_u003b((&param_10), (&param_11), (&param_12), (&param_13));
    dirl = _e181;
    let _e182 = a0_1;
    let _e184 = dirl;
    let _e187 = rp.day[3u];
    return mix((_e182 * 2f), _e184, vec3(_e187));
}

fn ambient_light_u0028_() -> vec3<f32> {
    let _e161 = rp.ambient;
    return _e161.xyz;
}

fn fluence_u0028_vf2_u003b(pos_1: ptr<function, vec2<f32>>) -> vec3<f32> {
    let _e161 = (*pos_1);
    let _e162 = g_world;
    let _e164 = textureSampleLevel(fluence_tex, fluence_tex_smp, (_e161 / _e162), 0f);
    return _e164.xyz;
}

fn openness_u0028_vi2_u003b(p_3: ptr<function, vec2<i32>>) -> f32 {
    var o_1: f32;
    var k: i32;
    var a_2: f32;
    var dir: vec2<f32>;
    var r: i32;
    var q_2: vec2<i32>;
    var sq: u32;
    var phi_722_: bool;

    o_1 = 0f;
    k = 0i;
    loop {
        let _e168 = k;
        if (_e168 < 8i) {
            let _e170 = k;
            a_2 = ((f32(_e170) * 0.785398f) + 0.2f);
            let _e174 = a_2;
            let _e176 = a_2;
            dir = vec2<f32>(cos(_e174), sin(_e176));
            r = 1i;
            loop {
                let _e179 = r;
                if (_e179 <= 3i) {
                    let _e181 = (*p_3);
                    let _e182 = dir;
                    let _e183 = r;
                    q_2 = (_e181 + vec2<i32>(round((_e182 * f32((_e183 * 2i))))));
                    let _e190 = q_2;
                    let _e192 = any((_e190 < vec2<i32>(0i, 0i)));
                    phi_722_ = _e192;
                    if !(_e192) {
                        let _e194 = q_2;
                        let _e195 = g_world;
                        phi_722_ = any((_e194 >= vec2<i32>(_e195)));
                    }
                    let _e200 = phi_722_;
                    if _e200 {
                        let _e201 = o_1;
                        o_1 = (_e201 + 0.16666667f);
                        continue;
                    }
                    let _e203 = q_2;
                    let _e204 = textureLoad(emissive_img, _e203, 0i);
                    sq = u32((_e204.w + 0.5f));
                    let _e208 = sq;
                    if (_e208 == 0u) {
                        let _e210 = o_1;
                        o_1 = (_e210 + 0.33333334f);
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e212 = r;
                    r = (_e212 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e214 = k;
            k = (_e214 + 1i);
        }
    }
    let _e216 = o_1;
    return clamp(((_e216 / 8f) * 1.8f), 0.15f, 1f);
}

fn main_1() {
    var p_4: vec2<i32>;
    var pos_2: vec2<f32>;
    var time: f32;
    var alb: vec4<f32>;
    var em: vec4<f32>;
    var ga: vec4<f32>;
    var st: u32;
    var nrm: vec2<f32>;
    var temp: f32;
    var matId: u32;
    var m: Material;
    var agit: f32;
    var still: f32;
    var local_2: f32;
    var param_14: vec2<i32>;
    var coverage: f32;
    var heat: f32;
    var R: f32;
    var Lin: vec3<f32>;
    var param_15: vec2<f32>;
    var wsum: f32;
    var ring: i32;
    var r_1: f32;
    var w_1: f32;
    var k_1: i32;
    var a_3: f32;
    var param_16: vec2<f32>;
    var Lsurf: vec3<f32>;
    var local_3: vec3<f32>;
    var param_17: vec2<f32>;
    var e: f32;
    var k_2: i32;
    var dir_1: vec2<f32>;
    var j: i32;
    var q_3: vec2<i32>;
    var rimT: f32;
    var deep: vec3<f32>;
    var Lsss: vec3<f32>;
    var diffuse: vec3<f32>;
    var S: vec3<f32>;
    var local_4: f32;
    var tau: vec3<f32>;
    var local_5: vec3<f32>;
    var ld: vec4<f32>;
    var L: vec3<f32>;
    var param_18: vec2<f32>;
    var param_19: vec2<f32>;
    var q_4: vec2<f32>;
    var sunTo: vec2<f32>;
    var bv: vec3<f32>;
    var bdir: vec2<f32>;
    var local_6: vec2<f32>;
    var bcoh: f32;
    var local_7: f32;
    var bf: f32;
    var local_8: vec3<f32>;
    var k_3: i32;
    var a_4: f32;
    var param_20: vec2<f32>;
    var param_21: vec2<i32>;
    var d_1: i32;
    var k_4: i32;
    var param_22: vec2<i32>;
    var Lsurf_1: vec3<f32>;
    var param_23: vec2<f32>;
    var tint: vec3<f32>;
    var ag: f32;
    var cz: f32;
    var param_24: vec2<f32>;
    var param_25: f32;
    var param_26: vec2<f32>;
    var param_27: f32;
    var ldc: vec4<f32>;
    var gh: vec2<f32>;
    var param_28: vec2<f32>;
    var param_29: vec2<f32>;
    var pattern: i32;
    var amt: f32;
    var local_9: f32;
    var local_10: f32;
    var surf: vec3<f32>;
    var param_30: vec2<f32>;
    var albN: vec3<f32>;
    var param_31: vec3<f32>;
    var inner: vec3<f32>;
    var param_32: vec2<f32>;
    var param_33: vec2<f32>;
    var depth: f32;
    var absorbCoef: vec3<f32>;
    var path: f32;
    var Lsurf_2: vec3<f32>;
    var param_34: vec2<f32>;
    var near: f32;
    var L_1: vec3<f32>;
    var param_35: vec2<f32>;
    var param_36: vec2<f32>;
    var param_37: vec2<f32>;
    var param_38: f32;
    var param_39: vec2<f32>;
    var param_40: f32;
    var tint_1: vec3<f32>;
    var scatter: f32;
    var param_41: vec2<f32>;
    var param_42: vec3<f32>;
    var Lup: vec3<f32>;
    var param_43: vec2<f32>;
    var spark: f32;
    var param_44: vec2<f32>;
    var param_45: vec2<f32>;
    var md_1: vec4<f32>;
    var z: f32;
    var tauSoot: f32;
    var tauSteam: f32;
    var L_2: vec3<f32>;
    var param_46: vec2<f32>;
    var Ld: vec3<f32>;
    var param_47: vec2<f32>;
    var scat: f32;
    var Lb: vec3<f32>;
    var param_48: vec4<f32>;
    var tint_2: vec3<f32>;
    var param_49: vec3<f32>;
    var param_50: vec3<f32>;
    var phi_1202_: bool;
    var phi_1203_: bool;
    var phi_1995_: bool;

    g_open = 1f;
    let _e283 = gl_GlobalInvocationID_1;
    p_4 = bitcast<vec2<i32>>(_e283.xy);
    let _e287 = pc.i0_;
    g_world = vec2<f32>(_e287.xy);
    let _e290 = p_4;
    let _e292 = pc.i0_;
    if any((_e290 >= _e292.xy)) {
        return;
    }
    let _e296 = p_4;
    pos_2 = (vec2<f32>(_e296) + vec2(0.5f));
    let _e302 = rp.misc[0u];
    time = _e302;
    let _e303 = p_4;
    let _e304 = textureLoad(albedo_img, _e303, 0i);
    alb = _e304;
    let _e305 = p_4;
    let _e306 = textureLoad(emissive_img, _e305, 0i);
    em = _e306;
    let _e307 = p_4;
    let _e308 = textureLoad(gaux_img, _e307, 0i);
    ga = _e308;
    let _e310 = em[3u];
    st = u32((_e310 + 0.5f));
    let _e313 = ga;
    nrm = _e313.xy;
    let _e316 = ga[3u];
    temp = _e316;
    let _e317 = p_4;
    let _e318 = textureLoad(cells, _e317, 0i);
    matId = (_e318.x & 255u);
    let _e321 = matId;
    let _e324 = unnamed.mats[_e321];
    m.color_a = _e324.color_a;
    m.color_b = _e324.color_b;
    m.emission = _e324.emission;
    m.phys = _e324.phys;
    m.thermo = _e324.thermo;
    m.burn = _e324.burn;
    m.optics = _e324.optics;
    m.scatter = _e324.scatter;
    m.ids = _e324.ids;
    m.ids2_ = _e324.ids2_;
    m.misc = _e324.misc;
    m.surface = _e324.surface;
    m.sss = _e324.sss;
    m.sss_color = _e324.sss_color;
    m.optics2_ = _e324.optics2_;
    m.pal0_ = _e324.pal0_;
    m.pal1_ = _e324.pal1_;
    m.pal2_ = _e324.pal2_;
    m.pal3_ = _e324.pal3_;
    m.accent = _e324.accent;
    m.flame = _e324.flame;
    let _e367 = p_4;
    let _e368 = textureLoad(cells, _e367, 0i);
    agit = (f32((_e368.w & 255u)) / 255f);
    let _e375 = rp.look4_[1u];
    still = _e375;
    let _e376 = st;
    if (_e376 == 0u) {
        local_2 = 1f;
    } else {
        let _e378 = p_4;
        param_14 = _e378;
        let _e379 = openness_u0028_vi2_u003b((&param_14));
        local_2 = _e379;
    }
    let _e380 = local_2;
    g_open = _e380;
    coverage = 0f;
    heat = 0f;
    let _e383 = m.sss[0u];
    let _e385 = st;
    if ((_e383 > 0f) && (_e385 != 0u)) {
        let _e390 = m.sss[1u];
        R = _e390;
        let _e391 = pos_2;
        param_15 = _e391;
        let _e392 = fluence_u0028_vf2_u003b((&param_15));
        Lin = _e392;
        wsum = 1f;
        ring = 1i;
        loop {
            let _e393 = ring;
            if (_e393 <= 3i) {
                let _e395 = R;
                let _e397 = ring;
                r_1 = ((_e395 * 0.6f) * f32(_e397));
                let _e400 = r_1;
                let _e402 = R;
                w_1 = exp((-(_e400) / _e402));
                k_1 = 0i;
                loop {
                    let _e405 = k_1;
                    if (_e405 < 6i) {
                        let _e407 = k_1;
                        let _e409 = ring;
                        a_3 = ((f32(_e407) + (f32(_e409) * 0.5f)) * 1.0472f);
                        let _e414 = pos_2;
                        let _e415 = a_3;
                        let _e417 = a_3;
                        let _e420 = r_1;
                        param_16 = (_e414 + (vec2<f32>(cos(_e415), sin(_e417)) * _e420));
                        let _e423 = fluence_u0028_vf2_u003b((&param_16));
                        let _e424 = w_1;
                        let _e426 = Lin;
                        Lin = (_e426 + (_e423 * _e424));
                        let _e428 = w_1;
                        let _e429 = wsum;
                        wsum = (_e429 + _e428);
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e431 = k_1;
                        k_1 = (_e431 + 1i);
                    }
                }
                continue;
            } else {
                break;
            }
            continuing {
                let _e433 = ring;
                ring = (_e433 + 1i);
            }
        }
        let _e435 = wsum;
        let _e436 = Lin;
        Lin = (_e436 / vec3(_e435));
        let _e439 = nrm;
        let _e440 = nrm;
        if (dot(_e439, _e440) > 0f) {
            let _e443 = pos_2;
            let _e444 = nrm;
            param_17 = (_e443 + (_e444 * 1.5f));
            let _e447 = fluence_u0028_vf2_u003b((&param_17));
            local_3 = (_e447 * 2f);
        } else {
            let _e449 = Lin;
            local_3 = (_e449 * 2f);
        }
        let _e451 = local_3;
        Lsurf = _e451;
        e = 8f;
        k_2 = 0i;
        loop {
            let _e452 = k_2;
            if (_e452 < 8i) {
                let _e454 = k_2;
                let _e458 = k_2;
                dir_1 = vec2<f32>(cos((f32(_e454) * 0.785398f)), sin((f32(_e458) * 0.785398f)));
                j = 1i;
                loop {
                    let _e463 = j;
                    if (_e463 <= 8i) {
                        let _e465 = p_4;
                        let _e466 = dir_1;
                        let _e467 = j;
                        let _e474 = pc.i0_;
                        q_3 = clamp((_e465 + vec2<i32>(round((_e466 * f32(_e467))))), vec2<i32>(0i, 0i), (_e474.xy - vec2(1i)));
                        let _e479 = q_3;
                        let _e480 = textureLoad(cells, _e479, 0i);
                        let _e483 = matId;
                        if ((_e480.x & 255u) != _e483) {
                            let _e485 = e;
                            let _e486 = j;
                            e = min(_e485, f32(_e486));
                            break;
                        }
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e489 = j;
                        j = (_e489 + 1i);
                    }
                }
                continue;
            } else {
                break;
            }
            continuing {
                let _e491 = k_2;
                k_2 = (_e491 + 1i);
            }
        }
        let _e493 = e;
        let _e496 = R;
        rimT = exp((-((_e493 - 1f)) / max((_e496 * 0.6f), 0.5f)));
        let _e502 = m.sss_color;
        let _e506 = m.sss_color;
        let _e511 = rimT;
        deep = mix((_e502.xyz * 0.5f), (mix(vec3<f32>(1f, 1f, 1f), _e506.xyz, vec3(0.3f)) * 1.3f), vec3(_e511));
        let _e514 = Lin;
        let _e516 = deep;
        Lsss = ((_e514 * 2.2f) * _e516);
        let _e518 = alb;
        let _e520 = Lsurf;
        let _e521 = Lsss;
        let _e524 = m.sss[0u];
        let _e527 = ambient_light_u0028_();
        diffuse = (_e518.xyz * (mix(_e520, _e521, vec3(_e524)) + _e527));
        let _e530 = diffuse;
        let _e531 = em;
        S = (_e530 + _e531.xyz);
        let _e535 = alb[3u];
        if (_e535 >= 0.97f) {
            local_4 = 1f;
        } else {
            let _e538 = alb[3u];
            local_4 = _e538;
        }
        let _e539 = local_4;
        coverage = _e539;
        let _e540 = coverage;
        if (_e540 >= 1f) {
            local_5 = vec3<f32>(0f, 0f, 0f);
        } else {
            let _e543 = alb[3u];
            let _e545 = alb;
            let _e548 = m.sss_color;
            local_5 = (mix(vec3<f32>(1f, 1f, 1f), ((_e545.xyz * _e548.xyz) * 1.4f), vec3(0.7f)) * (1f - _e543));
        }
        let _e555 = local_5;
        tau = _e555;
        let _e556 = st;
        let _e558 = coverage;
        if ((_e556 == 1u) && (_e558 < 1f)) {
            coverage = 0.5f;
        }
    } else {
        let _e561 = st;
        let _e563 = st;
        let _e565 = ((_e561 == 3u) || (_e563 == 2u));
        phi_1203_ = _e565;
        if !(_e565) {
            let _e567 = st;
            let _e568 = (_e567 == 1u);
            phi_1202_ = _e568;
            if _e568 {
                let _e570 = alb[3u];
                phi_1202_ = (_e570 > 0.97f);
            }
            let _e573 = phi_1202_;
            phi_1203_ = _e573;
        }
        let _e575 = phi_1203_;
        if _e575 {
            let _e576 = pos_2;
            let _e577 = nrm;
            let _e580 = g_world;
            let _e582 = textureSampleLevel(ldir_tex, ldir_tex_smp, ((_e576 + (_e577 * 1.5f)) / _e580), 0f);
            ld = _e582;
            let _e583 = nrm;
            let _e584 = nrm;
            if (dot(_e583, _e584) > 0f) {
                let _e587 = pos_2;
                let _e588 = nrm;
                let _e591 = nrm;
                param_18 = (_e587 + (_e588 * 1.5f));
                param_19 = normalize(_e591);
                let _e593 = irradiance_u0028_vf2_u003b_vf2_u003b((&param_18), (&param_19));
                L = _e593;
                let _e594 = pos_2;
                let _e595 = nrm;
                let _e598 = g_world;
                q_4 = ((_e594 + (_e595 * 1.5f)) / _e598);
                let _e601 = rp.look4_;
                sunTo = -(normalize(_e601.zw));
                let _e605 = q_4;
                let _e606 = textureSampleLevel(day_tex, day_tex_smp, _e605, 0f);
                let _e608 = nrm;
                let _e609 = sunTo;
                let _e615 = L;
                L = (_e615 + (_e606.xyz * (0.25f + (0.75f * max(dot(_e608, _e609), 0f)))));
                let _e617 = q_4;
                let _e618 = textureSampleLevel(beam_dir_tex, beam_dir_tex_smp, _e617, 0f);
                bv = _e618.xyz;
                let _e620 = bv;
                let _e622 = bv;
                if (dot(_e620.xy, _e622.xy) > 0.00000001f) {
                    let _e626 = bv;
                    local_6 = normalize(_e626.xy);
                } else {
                    local_6 = vec2<f32>(0f, 0f);
                }
                let _e629 = local_6;
                bdir = _e629;
                let _e631 = bv[2u];
                if (_e631 > 0.0001f) {
                    let _e633 = bv;
                    let _e637 = bv[2u];
                    local_7 = clamp((length(_e633.xy) / _e637), 0f, 1f);
                } else {
                    local_7 = 0f;
                }
                let _e640 = local_7;
                bcoh = _e640;
                let _e641 = nrm;
                let _e642 = bdir;
                let _e648 = bcoh;
                bf = mix(0.6f, (0.15f + (0.85f * max(dot(_e641, -(_e642)), 0f))), _e648);
                let _e650 = q_4;
                let _e651 = textureSampleLevel(beam_tex, beam_tex_smp, _e650, 0f);
                let _e653 = bf;
                let _e656 = L;
                L = (_e656 + ((_e651.xyz * _e653) * 1.4f));
                let _e658 = L;
                let _e659 = p_4;
                let _e660 = textureLoad(sub_img, _e659, 0i);
                L = max(_e658, (_e660.xyz * 0.85f));
            } else {
                let _e664 = p_4;
                let _e665 = textureLoad(sub_img, _e664, 0i);
                L = _e665.xyz;
                local_8 = vec3<f32>(0f, 0f, 0f);
                k_3 = 0i;
                loop {
                    let _e667 = k_3;
                    if (_e667 < 8i) {
                        let _e669 = k_3;
                        a_4 = (f32(_e669) * 0.785398f);
                        let _e672 = pos_2;
                        let _e673 = a_4;
                        let _e675 = a_4;
                        param_20 = (_e672 + (vec2<f32>(cos(_e673), sin(_e675)) * 8f));
                        let _e680 = fluence_u0028_vf2_u003b((&param_20));
                        let _e681 = local_8;
                        local_8 = (_e681 + _e680);
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e683 = k_3;
                        k_3 = (_e683 + 1i);
                    }
                }
                let _e685 = L;
                let _e686 = local_8;
                let _e690 = rp.misc2_[2u];
                L = max(_e685, ((_e686 * 0.25f) * _e690));
            }
            let _e693 = p_4;
            param_21 = _e693;
            let _e694 = state_up_u0028_vi2_u003b((&param_21));
            if (_e694 == 1u) {
                d_1 = 0i;
                k_4 = 1i;
                loop {
                    let _e696 = k_4;
                    if (_e696 <= 32i) {
                        let _e698 = p_4;
                        let _e699 = k_4;
                        param_22 = (_e698 - vec2<i32>(0i, (_e699 - 1i)));
                        let _e703 = state_up_u0028_vi2_u003b((&param_22));
                        if (_e703 != 1u) {
                            break;
                        }
                        let _e705 = k_4;
                        d_1 = _e705;
                        continue;
                    } else {
                        break;
                    }
                    continuing {
                        let _e706 = k_4;
                        k_4 = (_e706 + 1i);
                    }
                }
                let _e708 = pos_2;
                let _e709 = d_1;
                param_23 = (_e708 - vec2<f32>(0f, (f32(_e709) + 1.5f)));
                let _e714 = fluence_u0028_vf2_u003b((&param_23));
                Lsurf_1 = _e714;
                let _e715 = p_4;
                let _e717 = textureLoad(albedo_img, (_e715 - vec2<i32>(0i, 1i)), 0i);
                tint = _e717.xyz;
                let _e719 = p_4;
                let _e721 = textureLoad(cells, (_e719 - vec2<i32>(0i, 1i)), 0i);
                ag = (f32((_e721.w & 255u)) / 255f);
                let _e726 = time;
                let _e728 = pos_2;
                param_24 = _e728;
                param_25 = (_e726 * 0.08f);
                let _e729 = caustic_u0028_vf2_u003b_f1_u003b((&param_24), (&param_25));
                let _e730 = pos_2;
                param_26 = _e730;
                let _e731 = time;
                param_27 = _e731;
                let _e732 = caustic_u0028_vf2_u003b_f1_u003b((&param_26), (&param_27));
                let _e733 = ag;
                let _e735 = still;
                let _e736 = ag;
                cz = (mix(_e729, _e732, _e733) * mix(_e735, 1f, _e736));
                let _e739 = Lsurf_1;
                let _e740 = cz;
                let _e742 = d_1;
                let _e748 = tint;
                let _e754 = L;
                L = (_e754 + ((((_e739 * _e740) * exp((-(f32(_e742)) * 0.025f))) * mix(vec3<f32>(1f, 1f, 1f), (_e748 * 1.6f), vec3(0.5f))) * 1.6f));
            }
            let _e756 = L;
            let _e757 = em;
            L = max((_e756 - (_e757.xyz * 1.5f)), vec3<f32>(0f, 0f, 0f));
            let _e762 = pos_2;
            let _e763 = g_world;
            let _e765 = textureSampleLevel(ldir_tex, ldir_tex_smp, (_e762 / _e763), 0f);
            ldc = _e765;
            let _e766 = alb;
            let _e770 = p_4[0u];
            param_28 = ((_e766.xy * 913f) + vec2<f32>(f32((_e770 & 1i)), 0f));
            let _e775 = hash21_u0028_vf2_u003b((&param_28));
            let _e776 = alb;
            let _e780 = p_4[1u];
            param_29 = ((_e776.yz * 577f) + vec2<f32>(0f, f32((_e780 & 1i))));
            let _e785 = hash21_u0028_vf2_u003b((&param_29));
            gh = (vec2<f32>(_e775, _e785) - vec2(0.5f));
            let _e791 = m.sss_color[3u];
            pattern = i32((_e791 + 0.5f));
            let _e794 = pattern;
            if (_e794 == 1i) {
                local_9 = 0.9f;
            } else {
                let _e796 = st;
                if (_e796 == 2u) {
                    local_10 = 0.6f;
                } else {
                    let _e800 = m.surface[1u];
                    local_10 = (0.25f * _e800);
                }
                let _e802 = local_10;
                let _e805 = m.surface[2u];
                local_9 = (_e802 * (1f - _e805));
            }
            let _e808 = local_9;
            amt = _e808;
            let _e809 = amt;
            let _e810 = gh;
            let _e812 = ldc;
            let _e817 = ldc[2u];
            let _e821 = L;
            L = (_e821 * max((1f + ((_e809 * dot((_e810 * 2f), _e812.xy)) * _e817)), 0.3f));
            let _e823 = alb;
            let _e825 = L;
            let _e826 = nrm;
            param_30 = _e826;
            let _e827 = ambient_hemi_u0028_vf2_u003b((&param_30));
            let _e830 = em;
            surf = ((_e823.xyz * (_e825 + _e827)) + _e830.xyz);
            let _e833 = nrm;
            let _e834 = nrm;
            if (dot(_e833, _e834) == 0f) {
                let _e837 = alb;
                let _e839 = alb;
                param_31 = _e839.xyz;
                let _e841 = luminance_u0028_vf3_u003b((&param_31));
                albN = ((_e837.xyz / vec3(max(_e841, 0.06f))) * 0.3f);
                let _e846 = alb;
                let _e850 = rp.misc2_[2u];
                let _e853 = surf;
                surf = (_e853 + ((_e846.xyz * _e850) * 0.55f));
            }
            let _e856 = alb[3u];
            if (_e856 < 0.97f) {
                let _e858 = alb;
                let _e860 = pos_2;
                param_32 = _e860;
                let _e861 = fluence_u0028_vf2_u003b((&param_32));
                let _e862 = em;
                let _e870 = m.optics[1u];
                inner = ((_e858.xyz * max((_e861 - (_e862.xyz * 0.8f)), vec3<f32>(0f, 0f, 0f))) * _e870);
                let _e872 = surf;
                let _e874 = alb[3u];
                let _e876 = inner;
                let _e878 = alb[3u];
                S = ((_e872 * _e874) + (_e876 * (1f - _e878)));
                let _e882 = pos_2;
                param_33 = _e882;
                let _e883 = fluence_u0028_vf2_u003b((&param_33));
                let _e886 = nrm[1u];
                let _e891 = nrm;
                let _e892 = nrm;
                let _e896 = S;
                S = (_e896 + (((_e883 * 0.15f) * pow((1f - abs(_e886)), 4f)) * step(0.01f, dot(_e891, _e892))));
                let _e899 = alb[3u];
                let _e901 = alb;
                tau = (mix(vec3<f32>(1f, 1f, 1f), _e901.xyz, vec3(0.6f)) * (1f - _e899));
                let _e907 = alb[3u];
                coverage = _e907;
            } else {
                let _e908 = surf;
                S = _e908;
                tau = vec3<f32>(0f, 0f, 0f);
                coverage = 1f;
            }
        } else {
            let _e909 = st;
            if (_e909 == 1u) {
                let _e912 = ga[2u];
                depth = (_e912 + 0.5f);
                let _e914 = alb;
                let _e920 = m.optics[3u];
                absorbCoef = ((vec3(1f) - _e914.xyz) * _e920);
                let _e922 = depth;
                path = (1f + (min(_e922, 28f) * 0.12f));
                let _e926 = absorbCoef;
                let _e928 = path;
                tau = exp(((-(_e926) * _e928) * 2f));
                let _e932 = pos_2;
                let _e933 = depth;
                param_34 = (_e932 - vec2<f32>(0f, (_e933 + 1f)));
                let _e937 = fluence_u0028_vf2_u003b((&param_34));
                Lsurf_2 = _e937;
                let _e938 = depth;
                near = exp((-(_e938) * 0.06f));
                let _e942 = pos_2;
                param_35 = _e942;
                let _e943 = fluence_u0028_vf2_u003b((&param_35));
                let _e944 = pos_2;
                param_36 = _e944;
                let _e945 = daylight_u0028_vf2_u003b((&param_36));
                let _e948 = Lsurf_2;
                let _e949 = near;
                let _e951 = pos_2;
                let _e953 = time;
                param_37 = (_e951 * 0.8f);
                param_38 = (_e953 * 0.08f);
                let _e955 = caustic_u0028_vf2_u003b_f1_u003b((&param_37), (&param_38));
                let _e956 = pos_2;
                let _e958 = time;
                param_39 = (_e956 * 0.8f);
                param_40 = (_e958 * 1.1f);
                let _e960 = caustic_u0028_vf2_u003b_f1_u003b((&param_39), (&param_40));
                let _e961 = agit;
                let _e963 = still;
                let _e964 = agit;
                let _e968 = depth;
                L_1 = ((_e943 + (_e945 * 0.8f)) + ((_e948 * _e949) * (0.35f + (((mix(_e955, _e960, _e961) * mix(_e963, 1f, _e964)) * 0.35f) * smoothstep(1.5f, 4f, _e968)))));
                let _e974 = alb;
                let _e976 = alb;
                let _e978 = alb;
                let _e982 = depth;
                tint_1 = mix(_e974.xyz, ((_e976.xyz * _e978.xyz) * 1.6f), vec3(clamp((_e982 / 30f), 0f, 1f)));
                let _e989 = m.optics[1u];
                let _e992 = depth;
                scatter = ((0.25f + (_e989 * 0.6f)) * (1f - (0.6f * clamp((_e992 / 40f), 0f, 1f))));
                let _e998 = tint_1;
                let _e999 = L_1;
                param_41 = vec2<f32>(0f, 0f);
                let _e1000 = ambient_hemi_u0028_vf2_u003b((&param_41));
                let _e1003 = scatter;
                let _e1005 = tau;
                param_42 = _e1005;
                let _e1006 = luminance_u0028_vf3_u003b((&param_42));
                let _e1010 = em;
                S = ((((_e998 * (_e999 + _e1000)) * _e1003) * (1f - (_e1006 * 0.6f))) + _e1010.xyz);
                let _e1013 = pos_2;
                param_43 = (_e1013 - vec2<f32>(0f, 1.5f));
                let _e1015 = fluence_u0028_vf2_u003b((&param_43));
                Lup = _e1015;
                let _e1017 = ga[2u];
                if (_e1017 < 0.5f) {
                    let _e1020 = pos_2[0u];
                    let _e1022 = time;
                    let _e1025 = time;
                    param_44 = vec2<f32>(((_e1020 * 0.5f) + (_e1022 * 3f)), (_e1025 * 1.7f));
                    let _e1028 = vnoise_u0028_vf2_u003b((&param_44));
                    spark = (pow(_e1028, 12f) * 3f);
                    let _e1031 = Lup;
                    let _e1032 = spark;
                    let _e1036 = rp.reserved[3u];
                    let _e1038 = agit;
                    param_45 = vec2<f32>(0f, -1f);
                    let _e1042 = ambient_hemi_u0028_vf2_u003b((&param_45));
                    let _e1045 = alb;
                    let _e1052 = rp.fx[1u];
                    let _e1055 = S;
                    S = (_e1055 + (((((_e1031 * (0.5f + (((_e1032 * 0.25f) * _e1036) * _e1038))) + (_e1042 * 2f)) * mix(vec3<f32>(1f, 1f, 1f), _e1045.xyz, vec3(0.3f))) * _e1052) * 0.6f));
                    let _e1057 = tau;
                    tau = (_e1057 * 0.55f);
                } else {
                    let _e1060 = ga[2u];
                    if (_e1060 < 1.5f) {
                        let _e1062 = Lup;
                        let _e1064 = alb;
                        let _e1067 = S;
                        S = (_e1067 + ((_e1062 * 0.12f) * _e1064.xyz));
                    }
                }
                coverage = 0.5f;
            } else {
                let _e1069 = pos_2;
                let _e1070 = g_world;
                let _e1072 = textureSampleLevel(medium_tex, medium_tex_smp, (_e1069 / _e1070), 0f);
                md_1 = _e1072;
                let _e1075 = rp.medium[3u];
                z = _e1075;
                let _e1077 = md_1[0u];
                let _e1080 = rp.medium[0u];
                let _e1082 = z;
                tauSoot = ((_e1077 * _e1080) * _e1082);
                let _e1085 = md_1[1u];
                let _e1088 = rp.medium[1u];
                let _e1090 = z;
                tauSteam = ((_e1085 * _e1088) * _e1090);
                let _e1092 = pos_2;
                param_46 = _e1092;
                let _e1093 = fluence_u0028_vf2_u003b((&param_46));
                let _e1094 = ambient_light_u0028_();
                L_2 = (_e1093 + _e1094);
                let _e1096 = pos_2;
                param_47 = _e1096;
                let _e1097 = daylight_u0028_vf2_u003b((&param_47));
                Ld = _e1097;
                let _e1100 = rp.look3_[0u];
                let _e1104 = rp.reserved2_[0u];
                let _e1108 = md_1[0u];
                let _e1110 = md_1[1u];
                scat = (((_e1100 * 0.012f) + (_e1104 * 0.05f)) + ((_e1108 + _e1110) * 0.5f));
                let _e1114 = Ld;
                let _e1116 = L_2;
                L_2 = (_e1116 + (_e1114 * 2f));
                let _e1118 = pos_2;
                let _e1119 = g_world;
                let _e1121 = textureSampleLevel(beam_tex, beam_tex_smp, (_e1118 / _e1119), 0f);
                Lb = _e1121.xyz;
                let _e1123 = Ld;
                let _e1124 = scat;
                let _e1126 = Lb;
                let _e1129 = L_2;
                let _e1131 = rp.steam_color;
                let _e1133 = tauSteam;
                let _e1139 = rp.soot_color;
                let _e1141 = tauSoot;
                let _e1149 = md_1;
                param_48 = _e1149;
                let _e1150 = flame_radiance_u0028_vf4_u003b((&param_48));
                S = ((((_e1123 * _e1124) + (_e1126 * 0.1f)) + (_e1129 * ((_e1131.xyz * (1f - exp(-(_e1133)))) + (_e1139.xyz * (1f - exp(-(_e1141))))))) + _e1150);
                let _e1152 = tauSoot;
                let _e1153 = tauSteam;
                tau = vec3(exp(-((_e1152 + _e1153))));
                let _e1159 = alb[3u];
                if (_e1159 > 0f) {
                    let _e1161 = alb;
                    let _e1163 = L_2;
                    let _e1167 = m.optics[1u];
                    tint_2 = ((_e1161.xyz * _e1163) * (0.6f + _e1167));
                    let _e1170 = S;
                    let _e1171 = tint_2;
                    let _e1173 = alb[3u];
                    S = mix(_e1170, _e1171, vec3(_e1173));
                    let _e1177 = alb[3u];
                    let _e1179 = tau;
                    tau = (_e1179 * (1f - _e1177));
                }
                let _e1181 = em;
                let _e1183 = S;
                S = (_e1183 + _e1181.xyz);
                let _e1185 = temp;
                heat = smoothstep(380f, 1400f, _e1185);
            }
        }
    }
    let _e1187 = S;
    param_49 = _e1187;
    let _e1188 = web_isnan_u0028_vf3_u003b((&param_49));
    let _e1189 = any(_e1188);
    phi_1995_ = _e1189;
    if !(_e1189) {
        let _e1191 = S;
        param_50 = _e1191;
        let _e1192 = web_isinf_u0028_vf3_u003b((&param_50));
        phi_1995_ = any(_e1192);
    }
    let _e1195 = phi_1995_;
    if _e1195 {
        S = vec3<f32>(0f, 0f, 0f);
    }
    let _e1196 = p_4;
    let _e1197 = S;
    let _e1198 = max(_e1197, vec3<f32>(0f, 0f, 0f));
    let _e1199 = coverage;
    textureStore(l0s_out, _e1196, vec4<f32>(_e1198.x, _e1198.y, _e1198.z, _e1199));
    let _e1204 = p_4;
    let _e1205 = tau;
    let _e1208 = clamp(_e1205, vec3(0f), vec3(1f));
    let _e1209 = heat;
    textureStore(l0t_out, _e1204, vec4<f32>(_e1208.x, _e1208.y, _e1208.z, _e1209));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
