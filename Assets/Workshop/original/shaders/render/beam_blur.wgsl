struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Beams {
    beam: array<u32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var<storage> unnamed: Beams;
@group(0) @binding(1) 
var prev_img: texture_2d<f32>;
@group(0) @binding(2) 
var out_img: texture_storage_2d<rgba16float,write>;
@group(0) @binding(4) 
var dir_prev: texture_2d<f32>;
@group(0) @binding(3) 
var dir_img: texture_storage_2d<rgba16float,write>;

fn main_1() {
    var p: vec2<i32>;
    var n: vec2<i32>;
    var acc: vec3<f32>;
    var dsum: vec2<f32>;
    var lsum: f32;
    var w: f32;
    var y: i32;
    var x: i32;
    var q: vec2<i32>;
    var i: u32;
    var k: f32;
    var local: f32;
    var L: vec3<f32>;
    var now: vec3<f32>;
    var prev: vec3<f32>;
    var dv: vec3<f32>;

    let _e45 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e45.xy);
    let _e49 = pc.i0_;
    n = _e49.xy;
    let _e51 = p;
    let _e52 = n;
    if any((_e51 >= _e52)) {
        return;
    }
    acc = vec3<f32>(0f, 0f, 0f);
    dsum = vec2<f32>(0f, 0f);
    lsum = 0f;
    w = 0f;
    y = -1i;
    loop {
        let _e55 = y;
        if (_e55 <= 1i) {
            x = -1i;
            loop {
                let _e57 = x;
                if (_e57 <= 1i) {
                    let _e59 = p;
                    let _e60 = x;
                    let _e61 = y;
                    let _e64 = n;
                    q = clamp((_e59 + vec2<i32>(_e60, _e61)), vec2<i32>(0i, 0i), (_e64 - vec2(1i)));
                    let _e69 = q[1u];
                    let _e71 = n[0u];
                    let _e74 = q[0u];
                    i = (bitcast<u32>(((_e69 * _e71) + _e74)) * 5u);
                    let _e78 = x;
                    let _e80 = y;
                    if ((_e78 == 0i) && (_e80 == 0i)) {
                        local = 4f;
                    } else {
                        let _e83 = x;
                        let _e85 = y;
                        local = select(1f, 2f, ((_e83 == 0i) || (_e85 == 0i)));
                    }
                    let _e89 = local;
                    k = _e89;
                    let _e90 = i;
                    let _e93 = unnamed.beam[_e90];
                    let _e95 = i;
                    let _e99 = unnamed.beam[(_e95 + 1u)];
                    let _e101 = i;
                    let _e105 = unnamed.beam[(_e101 + 2u)];
                    L = (vec3<f32>(f32(_e93), f32(_e99), f32(_e105)) / vec3(256f));
                    let _e110 = L;
                    let _e111 = k;
                    let _e113 = acc;
                    acc = (_e113 + (_e110 * _e111));
                    let _e115 = i;
                    let _e119 = unnamed.beam[(_e115 + 3u)];
                    let _e122 = i;
                    let _e126 = unnamed.beam[(_e122 + 4u)];
                    let _e132 = k;
                    let _e134 = dsum;
                    dsum = (_e134 + ((vec2<f32>(f32(bitcast<i32>(_e119)), f32(bitcast<i32>(_e126))) / vec2(256f)) * _e132));
                    let _e137 = L[0u];
                    let _e139 = L[1u];
                    let _e142 = L[2u];
                    let _e145 = k;
                    let _e147 = lsum;
                    lsum = (_e147 + ((((_e137 + _e139) + _e142) / 3f) * _e145));
                    let _e149 = k;
                    let _e150 = w;
                    w = (_e150 + _e149);
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e152 = x;
                    x = (_e152 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e154 = y;
            y = (_e154 + 1i);
        }
    }
    let _e156 = acc;
    let _e157 = w;
    now = (_e156 / vec3(_e157));
    let _e160 = now;
    let _e162 = now[0u];
    let _e164 = now[1u];
    let _e166 = now[2u];
    now = (_e160 / vec3((1f + (max(_e162, max(_e164, _e166)) * 0.25f))));
    let _e173 = p;
    let _e174 = textureLoad(prev_img, _e173, 0i);
    prev = _e174.xyz;
    let _e176 = p;
    let _e177 = prev;
    let _e178 = now;
    let _e181 = pc.f0_[0u];
    let _e183 = mix(_e177, _e178, vec3(_e181));
    textureStore(out_img, _e176, vec4<f32>(_e183.x, _e183.y, _e183.z, 1f));
    let _e188 = p;
    let _e189 = textureLoad(dir_prev, _e188, 0i);
    let _e191 = dsum;
    let _e192 = lsum;
    let _e196 = w;
    let _e201 = pc.f0_[0u];
    dv = mix(_e189.xyz, (vec3<f32>(_e191.x, _e191.y, _e192) / vec3(_e196)), vec3(_e201));
    let _e204 = p;
    let _e205 = dv;
    textureStore(dir_img, _e204, vec4<f32>(_e205.x, _e205.y, _e205.z, 1f));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
