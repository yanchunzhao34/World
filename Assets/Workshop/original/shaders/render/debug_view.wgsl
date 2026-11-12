struct Cell {
    mat: u32,
    variant: u32,
    flags: u32,
    temp: f32,
    life: u32,
    aux: u32,
    extra: u32,
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
var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(0) @binding(0) 
var cells: texture_2d<u32>;
@group(0) @binding(1) 
var<storage> unnamed: Materials;
@group(0) @binding(3) 
var aux_tex: texture_2d<f32>;
@group(2) @binding(3) 
var aux_tex_smp: sampler;
@group(0) @binding(2) 
var out_img: texture_storage_2d<rgba8unorm,write>;

fn cell_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b(c: ptr<function, Cell>) -> u32 {
    let _e84 = (*c).flags;
    return ((_e84 & 28u) >> bitcast<u32>(2u));
}

fn heat_ramp_u0028_f1_u003b(t: ptr<function, f32>) -> vec3<f32> {
    var c_1: array<vec3<f32>, 7>;
    var i: i32;

    c_1 = array<vec3<f32>, 7>(vec3<f32>(0f, 0f, 0f), vec3<f32>(0.1f, 0.1f, 0.8f), vec3<f32>(0f, 0.8f, 0.9f), vec3<f32>(0.1f, 0.9f, 0.2f), vec3<f32>(1f, 0.95f, 0.1f), vec3<f32>(1f, 0.2f, 0.05f), vec3<f32>(1f, 1f, 1f));
    let _e85 = (*t);
    (*t) = (clamp(_e85, 0f, 1f) * 6f);
    let _e88 = (*t);
    i = min(i32(_e88), 5i);
    let _e91 = i;
    let _e93 = c_1[_e91];
    let _e94 = i;
    let _e97 = c_1[(_e94 + 1i)];
    let _e98 = (*t);
    let _e99 = i;
    return mix(_e93, _e97, vec3((_e98 - f32(_e99))));
}

fn hue_u0028_f1_u003b(h: ptr<function, f32>) -> vec3<f32> {
    let _e83 = (*h);
    return clamp((abs(((fract((vec3(_e83) + vec3<f32>(0f, 0.6666667f, 0.33333334f))) * 6f) - vec3(3f))) - vec3(1f)), vec3(0f), vec3(1f));
}

fn unpack_cell_u0028_vu4_u003b(v: ptr<function, vec4<u32>>) -> Cell {
    var c_2: Cell;

    let _e85 = (*v)[0u];
    c_2.mat = (_e85 & 255u);
    let _e89 = (*v)[0u];
    c_2.variant = ((_e89 >> bitcast<u32>(8u)) & 255u);
    let _e95 = (*v)[0u];
    c_2.flags = (_e95 >> bitcast<u32>(16u));
    let _e100 = (*v)[1u];
    c_2.temp = bitcast<f32>(_e100);
    let _e104 = (*v)[2u];
    c_2.life = (_e104 & 65535u);
    let _e108 = (*v)[2u];
    c_2.aux = (_e108 >> bitcast<u32>(16u));
    let _e113 = (*v)[3u];
    c_2.extra = _e113;
    let _e115 = c_2;
    return _e115;
}

fn in_world_u0028_vi2_u003b(p: ptr<function, vec2<i32>>) -> bool {
    var phi_49_: bool;
    var phi_63_: bool;
    var phi_71_: bool;

    let _e84 = (*p)[0u];
    let _e85 = (_e84 >= 0i);
    phi_49_ = _e85;
    if _e85 {
        let _e87 = (*p)[1u];
        phi_49_ = (_e87 >= 0i);
    }
    let _e90 = phi_49_;
    phi_63_ = _e90;
    if _e90 {
        let _e92 = (*p)[0u];
        let _e95 = pc.i0_[0u];
        phi_63_ = (_e92 < _e95);
    }
    let _e98 = phi_63_;
    phi_71_ = _e98;
    if _e98 {
        let _e100 = (*p)[1u];
        let _e103 = pc.i0_[1u];
        phi_71_ = (_e100 < _e103);
    }
    let _e106 = phi_71_;
    return _e106;
}

fn main_1() {
    var p_1: vec2<i32>;
    var param: vec2<i32>;
    var c_3: Cell;
    var param_1: vec4<u32>;
    var m: Material;
    var uv: vec2<f32>;
    var mode: i32;
    var v_1: f32;
    var col: vec3<f32>;
    var local: f32;
    var local_1: vec3<f32>;
    var param_2: f32;
    var t_1: f32;
    var param_3: f32;
    var v_2: vec2<f32>;
    var md: vec4<f32>;
    var t_2: vec4<f32>;
    var local_2: vec3<f32>;
    var param_4: Cell;

    let _e101 = gl_GlobalInvocationID_1;
    p_1 = bitcast<vec2<i32>>(_e101.xy);
    let _e104 = p_1;
    param = _e104;
    let _e105 = in_world_u0028_vi2_u003b((&param));
    if !(_e105) {
        return;
    }
    let _e107 = p_1;
    let _e108 = textureLoad(cells, _e107, 0i);
    param_1 = _e108;
    let _e109 = unpack_cell_u0028_vu4_u003b((&param_1));
    c_3 = _e109;
    let _e111 = c_3.mat;
    let _e114 = unnamed.mats[_e111];
    m.color_a = _e114.color_a;
    m.color_b = _e114.color_b;
    m.emission = _e114.emission;
    m.phys = _e114.phys;
    m.thermo = _e114.thermo;
    m.burn = _e114.burn;
    m.optics = _e114.optics;
    m.scatter = _e114.scatter;
    m.ids = _e114.ids;
    m.ids2_ = _e114.ids2_;
    m.misc = _e114.misc;
    m.surface = _e114.surface;
    m.sss = _e114.sss;
    m.sss_color = _e114.sss_color;
    m.optics2_ = _e114.optics2_;
    m.pal0_ = _e114.pal0_;
    m.pal1_ = _e114.pal1_;
    m.pal2_ = _e114.pal2_;
    m.pal3_ = _e114.pal3_;
    m.accent = _e114.accent;
    m.flame = _e114.flame;
    let _e157 = p_1;
    let _e162 = pc.i0_;
    uv = ((vec2<f32>(_e157) + vec2(0.5f)) / vec2<f32>(_e162.xy));
    let _e168 = pc.i1_[0u];
    mode = _e168;
    let _e169 = mode;
    if (_e169 == 0i) {
        let _e172 = c_3.variant;
        v_1 = (f32(_e172) / 255f);
        let _e176 = m.color_a;
        let _e179 = m.color_b;
        let _e181 = v_1;
        col = mix(_e176.xyz, _e179.xyz, vec3(_e181));
        let _e184 = col;
        let _e186 = c_3.mat;
        if (_e186 == 0u) {
            local = 0f;
        } else {
            let _e190 = m.color_b[3u];
            local = max(_e190, 0.25f);
        }
        let _e192 = local;
        col = mix(vec3<f32>(0.05f, 0.06f, 0.08f), _e184, vec3(_e192));
        let _e196 = m.emission;
        let _e199 = col;
        col = (_e199 + (_e196.xyz * 0.25f));
        let _e202 = c_3.flags;
        if ((_e202 & 1u) != 0u) {
            let _e205 = col;
            col = mix(_e205, vec3<f32>(1f, 0.5f, 0.1f), vec3(0.6f));
        }
    } else {
        let _e208 = mode;
        if (_e208 == 1i) {
            let _e211 = c_3.mat;
            if (_e211 == 0u) {
                local_1 = vec3<f32>(0f, 0f, 0f);
            } else {
                let _e214 = c_3.mat;
                param_2 = (f32(_e214) * 0.618034f);
                let _e217 = hue_u0028_f1_u003b((&param_2));
                let _e219 = c_3.variant;
                local_1 = (_e217 * (0.6f + ((0.4f * f32(_e219)) / 255f)));
            }
            let _e225 = local_1;
            col = _e225;
        } else {
            let _e226 = mode;
            if (_e226 == 2i) {
                let _e229 = c_3.temp;
                t_1 = (log2((max(_e229, 1f) / 150f)) / 4.7369657f);
                let _e234 = t_1;
                param_3 = _e234;
                let _e235 = heat_ramp_u0028_f1_u003b((&param_3));
                col = _e235;
                let _e237 = c_3.mat;
                if (_e237 != 0u) {
                    let _e241 = m.ids[0u];
                    let _e246 = col;
                    col = (_e246 * (0.75f + (0.25f * select(0f, 1f, (_e241 != 0u)))));
                }
            } else {
                let _e248 = mode;
                if (_e248 == 3i) {
                    let _e250 = uv;
                    let _e251 = textureSampleLevel(aux_tex, aux_tex_smp, _e250, 0f);
                    let _e255 = pc.f0_[0u];
                    v_2 = (_e251.xy * _e255);
                    let _e258 = v_2[0u];
                    let _e262 = v_2[1u];
                    let _e266 = uv;
                    let _e267 = textureSampleLevel(aux_tex, aux_tex_smp, _e266, 0f);
                    col = (vec3<f32>((0.5f + (0.5f * _e258)), (0.5f + (0.5f * _e262)), 0.5f) * select(1f, 0.3f, (_e267.z > 0.6f)));
                } else {
                    let _e272 = mode;
                    if (_e272 == 4i) {
                        let _e274 = uv;
                        let _e275 = textureSampleLevel(aux_tex, aux_tex_smp, _e274, 0f);
                        let _e278 = pc.f0_[0u];
                        md = (_e275 * _e278);
                        let _e281 = md[0u];
                        let _e284 = md[1u];
                        let _e287 = md[2u];
                        let _e290 = md[1u];
                        let _e292 = md[2u];
                        let _e296 = md[1u];
                        col = vec3<f32>((((_e281 * 0.6f) + _e284) + _e287), (_e290 + (_e292 * 0.4f)), _e296);
                        let _e298 = col;
                        col = (vec3(1f) - exp(-(_e298)));
                    } else {
                        let _e303 = mode;
                        if (_e303 == 5i) {
                            let _e305 = uv;
                            let _e306 = textureSampleLevel(aux_tex, aux_tex_smp, _e305, 0f);
                            let _e309 = pc.f0_[0u];
                            t_2 = (_e306 * _e309);
                            let _e313 = pc.i1_[1u];
                            if (_e313 == 1i) {
                                let _e316 = t_2[3u];
                                local_2 = vec3((1f - exp(-(_e316))));
                            } else {
                                let _e321 = t_2;
                                let _e323 = t_2;
                                local_2 = (_e321.xyz / (vec3(1f) + _e323.xyz));
                            }
                            let _e328 = local_2;
                            col = _e328;
                        } else {
                            col = vec3<f32>(0.04f, 0.04f, 0.04f);
                            let _e330 = c_3.mat;
                            if (_e330 != 0u) {
                                let _e333 = m.color_a;
                                col = mix(_e333.xyz, vec3<f32>(0.1f, 0.1f, 0.1f), vec3(0.8f));
                            }
                            let _e338 = c_3.flags;
                            if ((_e338 & 1u) != 0u) {
                                col = vec3<f32>(1f, 0.4f, 0f);
                            }
                            let _e341 = c_3;
                            param_4 = _e341;
                            let _e342 = cell_flash_u0028_struct_u002d_Cell_u002d_u1_u002d_u1_u002d_u1_u002d_f1_u002d_u1_u002d_u1_u002d_u11_u003b((&param_4));
                            let _e347 = col;
                            col = (_e347 + ((vec3<f32>(0.2f, 0.9f, 1f) * f32(_e342)) / vec3(7f)));
                        }
                    }
                }
            }
        }
    }
    let _e349 = p_1;
    let _e350 = col;
    let _e354 = pow(clamp(_e350, vec3(0f), vec3(1f)), vec3<f32>(0.45454547f, 0.45454547f, 0.45454547f));
    textureStore(out_img, _e349, vec4<f32>(_e354.x, _e354.y, _e354.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
