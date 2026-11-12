struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct MediumSrc {
    msrc: array<u32>,
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

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(2) 
var vel_tex: texture_2d<f32>;
@group(2) @binding(2) 
var vel_tex_smp: sampler;
@group(0) @binding(0) 
var medium_in: texture_2d<f32>;
@group(2) @binding(0) 
var medium_in_smp: sampler;
@group(0) @binding(3) 
var<storage> unnamed: MediumSrc;
@group(0) @binding(5) 
var<storage> unnamed_1: Materials;
@group(0) @binding(4) 
var cells: texture_2d<u32>;
@group(0) @binding(1) 
var medium_out: texture_storage_2d<rgba16float,write>;

fn main_1() {
    var p: vec2<i32>;
    var size: vec2<i32>;
    var uv: vec2<f32>;
    var v: vec2<f32>;
    var src: vec2<f32>;
    var m: vec4<f32>;
    var fsrc: vec2<f32>;
    var mf: vec4<f32>;
    var idx: u32;
    var blocked: i32;
    var y: i32;
    var x: i32;

    let _e46 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e46.xy);
    let _e50 = pc.i0_;
    size = _e50.xy;
    let _e52 = p;
    let _e53 = size;
    if any((_e52 >= _e53)) {
        return;
    }
    let _e56 = p;
    let _e60 = size;
    uv = ((vec2<f32>(_e56) + vec2(0.5f)) / vec2<f32>(_e60));
    let _e63 = uv;
    let _e64 = textureSampleLevel(vel_tex, vel_tex_smp, _e63, 0f);
    v = (_e64.xy * 2f);
    let _e69 = pc.f1_[0u];
    let _e71 = v[1u];
    v[1u] = (_e71 - _e69);
    let _e74 = p;
    let _e78 = v;
    let _e81 = pc.f0_[2u];
    src = ((vec2<f32>(_e74) + vec2(0.5f)) - (_e78 * _e81));
    let _e84 = src;
    let _e85 = size;
    let _e88 = textureSampleLevel(medium_in, medium_in_smp, (_e84 / vec2<f32>(_e85)), 0f);
    m = _e88;
    let _e89 = src;
    let _e91 = p[1u];
    let _e96 = pc.i1_[2u];
    let _e104 = pc.f1_[2u];
    fsrc = (_e89 + vec2<f32>((sin(((f32(_e91) * 0.7f) + (f32(_e96) * 0.37f))) * 0.35f), _e104));
    let _e107 = fsrc;
    let _e108 = size;
    let _e111 = textureSampleLevel(medium_in, medium_in_smp, (_e107 / vec2<f32>(_e108)), 0f);
    mf = _e111;
    let _e113 = mf[2u];
    m[2u] = _e113;
    let _e116 = mf[3u];
    m[3u] = _e116;
    let _e119 = p[1u];
    let _e121 = size[0u];
    let _e124 = p[0u];
    idx = (bitcast<u32>(((_e119 * _e121) + _e124)) * 4u);
    let _e128 = idx;
    let _e132 = unnamed.msrc[(_e128 + 0u)];
    let _e137 = pc.f0_[3u];
    let _e140 = m[0u];
    m[0u] = (_e140 + ((f32(_e132) / 1024f) * _e137));
    let _e143 = idx;
    let _e147 = unnamed.msrc[(_e143 + 1u)];
    let _e152 = pc.f0_[3u];
    let _e155 = m[1u];
    m[1u] = (_e155 + ((f32(_e147) / 1024f) * _e152));
    let _e158 = idx;
    let _e162 = unnamed.msrc[(_e158 + 2u)];
    let _e167 = pc.f0_[3u];
    let _e170 = m[2u];
    m[2u] = (_e170 + ((f32(_e162) / 1024f) * _e167));
    let _e173 = idx;
    let _e177 = unnamed.msrc[(_e173 + 3u)];
    let _e182 = pc.f0_[3u];
    let _e185 = m[3u];
    m[3u] = (_e185 + ((f32(_e177) / 1024f) * _e182));
    let _e190 = pc.f0_[0u];
    let _e192 = m[0u];
    m[0u] = (_e192 * _e190);
    let _e197 = pc.f0_[1u];
    let _e199 = m[1u];
    m[1u] = (_e199 * _e197);
    let _e204 = pc.f1_[1u];
    let _e206 = m[2u];
    m[2u] = (_e206 * _e204);
    let _e211 = pc.f1_[1u];
    let _e213 = m[3u];
    m[3u] = (_e213 * _e211);
    let _e217 = m[3u];
    let _e219 = m[2u];
    m[3u] = min(_e217, _e219);
    blocked = 0i;
    y = 0i;
    loop {
        let _e222 = y;
        if (_e222 < 2i) {
            x = 0i;
            loop {
                let _e224 = x;
                if (_e224 < 2i) {
                    let _e226 = p;
                    let _e229 = x;
                    let _e230 = y;
                    let _e233 = textureLoad(cells, ((_e226 * vec2(2i)) + vec2<i32>(_e229, _e230)), 0i);
                    let _e240 = unnamed_1.mats[(_e233.x & 255u)].ids[0u];
                    if (_e240 != 0u) {
                        let _e242 = blocked;
                        blocked = (_e242 + 1i);
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e244 = x;
                    x = (_e244 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e246 = y;
            y = (_e246 + 1i);
        }
    }
    let _e248 = blocked;
    if (_e248 == 4i) {
        let _e250 = m;
        m = (_e250 * 0.5f);
    }
    let _e252 = p;
    let _e253 = m;
    textureStore(medium_out, _e252, clamp(_e253, vec4<f32>(0f, 0f, 0f, 0f), vec4<f32>(6f, 6f, 6f, 6f)));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
