struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var l0s: texture_2d<f32>;
@group(0) @binding(1) 
var occ_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(3) 
var bg: texture_2d<u32>;
@group(0) @binding(4) 
var bg_out: texture_storage_2d<rgba16float,write>;
@group(0) @binding(2) 
var side_out: texture_storage_2d<rgba16float,write>;

fn main_1() {
    var p: vec2<i32>;
    var n: vec2<i32>;
    var w: vec3<f32>;
    var acc: vec3<f32>;
    var col: vec3<f32>;
    var cw: f32;
    var cwAll: f32;
    var self_: f32;
    var y: i32;
    var x: i32;
    var r2_: f32;
    var s: vec4<f32>;
    var o: f32;
    var k: vec3<f32>;
    var kc: f32;
    var dsum: f32;
    var csum: f32;
    var wsum: f32;
    var win: f32;
    var wdep: f32;
    var y_1: i32;
    var x_1: i32;
    var k_1: f32;
    var b: vec4<u32>;
    var local: f32;
    var local_1: f32;
    var local_2: vec3<f32>;

    let _e60 = gl_GlobalInvocationID_1;
    p = bitcast<vec2<i32>>(_e60.xy);
    let _e64 = pc.i0_;
    n = _e64.xy;
    let _e66 = p;
    let _e67 = n;
    if any((_e66 >= _e67)) {
        return;
    }
    w = vec3<f32>(0f, 0f, 0f);
    acc = vec3<f32>(0f, 0f, 0f);
    col = vec3<f32>(0f, 0f, 0f);
    cw = 0f;
    cwAll = 0f;
    let _e70 = p;
    let _e71 = textureLoad(l0s, _e70, 0i);
    self_ = select(0f, 1f, (_e71.w >= 0.99f));
    y = -9i;
    loop {
        let _e75 = y;
        if (_e75 <= 9i) {
            x = -9i;
            loop {
                let _e77 = x;
                if (_e77 <= 9i) {
                    let _e79 = x;
                    let _e80 = x;
                    let _e82 = y;
                    let _e83 = y;
                    r2_ = f32(((_e79 * _e80) + (_e82 * _e83)));
                    let _e87 = r2_;
                    if (_e87 > 81.5f) {
                        continue;
                    }
                    let _e89 = p;
                    let _e90 = x;
                    let _e91 = y;
                    let _e94 = n;
                    let _e98 = textureLoad(l0s, clamp((_e89 + vec2<i32>(_e90, _e91)), vec2<i32>(0i, 0i), (_e94 - vec2(1i))), 0i);
                    s = _e98;
                    let _e100 = s[3u];
                    o = select(0f, 1f, (_e100 >= 0.99f));
                    let _e103 = r2_;
                    k = exp((vec3(-(_e103)) / vec3<f32>(2f, 12.5f, 40.5f)));
                    let _e108 = k;
                    let _e109 = w;
                    w = (_e109 + _e108);
                    let _e111 = k;
                    let _e112 = o;
                    let _e114 = acc;
                    acc = (_e114 + (_e111 * _e112));
                    let _e117 = k[1u];
                    kc = _e117;
                    let _e118 = kc;
                    let _e119 = cwAll;
                    cwAll = (_e119 + _e118);
                    let _e121 = o;
                    if (_e121 > 0f) {
                        let _e123 = kc;
                        let _e124 = s;
                        let _e127 = col;
                        col = (_e127 + (_e124.xyz * _e123));
                        let _e129 = kc;
                        let _e130 = cw;
                        cw = (_e130 + _e129);
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e132 = x;
                    x = (_e132 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e134 = y;
            y = (_e134 + 1i);
        }
    }
    let _e136 = p;
    let _e137 = self_;
    let _e138 = acc;
    let _e139 = w;
    let _e140 = (_e138 / _e139);
    textureStore(occ_out, _e136, vec4<f32>(_e137, _e140.x, _e140.y, _e140.z));
    dsum = 0f;
    csum = 0f;
    wsum = 0f;
    win = 0f;
    wdep = 0f;
    y_1 = -3i;
    loop {
        let _e145 = y_1;
        if (_e145 <= 3i) {
            x_1 = -3i;
            loop {
                let _e147 = x_1;
                if (_e147 <= 3i) {
                    let _e149 = x_1;
                    let _e150 = x_1;
                    let _e152 = y_1;
                    let _e153 = y_1;
                    k_1 = exp((-(f32(((_e149 * _e150) + (_e152 * _e153)))) / 2.88f));
                    let _e160 = p;
                    let _e161 = x_1;
                    let _e162 = y_1;
                    let _e165 = n;
                    let _e169 = textureLoad(bg, clamp((_e160 + vec2<i32>(_e161, _e162)), vec2<i32>(0i, 0i), (_e165 - vec2(1i))), 0i);
                    b = _e169;
                    let _e170 = k_1;
                    let _e171 = wsum;
                    wsum = (_e171 + _e170);
                    let _e174 = b[0u];
                    if (_e174 != 0u) {
                        let _e176 = k_1;
                        let _e178 = b[1u];
                        let _e182 = dsum;
                        dsum = (_e182 + ((_e176 * f32(_e178)) / 255f));
                        let _e184 = k_1;
                        let _e185 = csum;
                        csum = (_e185 + _e184);
                    }
                    let _e188 = b[0u];
                    if (_e188 == 7u) {
                        let _e190 = k_1;
                        let _e191 = win;
                        win = (_e191 + _e190);
                        let _e193 = k_1;
                        let _e195 = b[1u];
                        let _e199 = wdep;
                        wdep = (_e199 + ((_e193 * f32(_e195)) / 255f));
                    }
                    continue;
                } else {
                    break;
                }
                continuing {
                    let _e201 = x_1;
                    x_1 = (_e201 + 1i);
                }
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e203 = y_1;
            y_1 = (_e203 + 1i);
        }
    }
    let _e205 = p;
    let _e206 = csum;
    if (_e206 > 0f) {
        let _e208 = dsum;
        let _e209 = csum;
        local = (_e208 / _e209);
    } else {
        local = 1f;
    }
    let _e211 = local;
    let _e212 = csum;
    let _e213 = wsum;
    let _e215 = win;
    let _e216 = wsum;
    let _e218 = win;
    if (_e218 > 0f) {
        let _e220 = wdep;
        let _e221 = win;
        local_1 = (_e220 / _e221);
    } else {
        local_1 = 0.6f;
    }
    let _e223 = local_1;
    textureStore(bg_out, _e205, vec4<f32>(_e211, (_e212 / _e213), (_e215 / _e216), _e223));
    let _e225 = p;
    let _e226 = cw;
    if (_e226 > 0f) {
        let _e228 = col;
        let _e229 = cw;
        local_2 = (_e228 / vec3(_e229));
    } else {
        local_2 = vec3<f32>(0f, 0f, 0f);
    }
    let _e232 = local_2;
    let _e233 = cw;
    let _e234 = cwAll;
    textureStore(side_out, _e225, vec4<f32>(_e232.x, _e232.y, _e232.z, (_e233 / max(_e234, 0.0001f))));
    return;
}

@compute @workgroup_size(8, 8, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
