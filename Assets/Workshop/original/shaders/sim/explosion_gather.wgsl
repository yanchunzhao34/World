struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct ExGrid {
    ex_grid: array<u32>,
}

struct Counts {
    counts: array<u32>,
}

struct Pending {
    pend_header: vec4<u32>,
    pend: array<vec4<f32>>,
}

var<private> gl_LocalInvocationIndex_1: u32;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(0) 
var<storage, read_write> unnamed: ExGrid;
var<workgroup> sh_count: atomic<u32>;
@group(0) @binding(2) 
var<storage, read_write> unnamed_1: Counts;
var<workgroup> sh_scan: array<u32, 256>;
var<workgroup> sh_sum: array<u32, 256>;
@group(0) @binding(1) 
var<storage, read_write> unnamed_2: Pending;

fn main_1(gl_WorkGroupID_1: vec3<u32>) {
    var li: u32;
    var g: u32;
    var n: u32;
    var i0_: u32;
    var mine: u32;
    var k: u32;
    var keys: array<u32, 4>;
    var local: u32;
    var off: u32;
    var v: u32;
    var local_1: u32;
    var blocks: u32;
    var upto: u32;
    var s: u32;
    var k_1: u32;
    var half: u32;
    var idx: u32;
    var local_2: u32;
    var k_2: u32;
    var i: u32;
    var x: u32;
    var y: u32;

    let _e47 = gl_LocalInvocationIndex_1;
    li = _e47;
    let _e49 = gl_WorkGroupID_1[0u];
    g = _e49;
    let _e52 = pc.i0_[0u];
    let _e55 = pc.i0_[1u];
    n = bitcast<u32>((_e52 * _e55));
    let _e58 = g;
    let _e60 = li;
    i0_ = (((_e58 * 256u) + _e60) * 4u);
    mine = 0u;
    k = 0u;
    loop {
        let _e63 = k;
        if (_e63 < 4u) {
            let _e65 = k;
            let _e66 = i0_;
            let _e67 = k;
            let _e69 = n;
            if ((_e66 + _e67) < _e69) {
                let _e71 = i0_;
                let _e72 = k;
                let _e76 = unnamed.ex_grid[(_e71 + _e72)];
                local = _e76;
            } else {
                local = 0u;
            }
            let _e77 = local;
            keys[_e65] = _e77;
            let _e79 = k;
            let _e81 = keys[_e79];
            if (_e81 != 0u) {
                let _e83 = mine;
                mine = (_e83 + bitcast<u32>(1i));
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e86 = k;
            k = (_e86 + bitcast<u32>(1i));
        }
    }
    let _e91 = pc.i0_[2u];
    if (_e91 == 0i) {
        let _e93 = li;
        if (_e93 == 0u) {
            atomicStore((&sh_count), 0u);
        }
        workgroupBarrier();
        let _e95 = mine;
        if (_e95 != 0u) {
            let _e97 = mine;
            let _e98 = atomicAdd((&sh_count), _e97);
        }
        workgroupBarrier();
        let _e99 = li;
        if (_e99 == 0u) {
            let _e101 = g;
            let _e102 = atomicLoad((&sh_count));
            unnamed_1.counts[_e101] = _e102;
        }
        return;
    }
    let _e105 = li;
    let _e106 = mine;
    sh_scan[_e105] = _e106;
    workgroupBarrier();
    off = 1u;
    loop {
        let _e108 = off;
        if (_e108 < 256u) {
            let _e110 = li;
            let _e111 = off;
            if (_e110 >= _e111) {
                let _e113 = li;
                let _e114 = off;
                let _e117 = sh_scan[(_e113 - _e114)];
                local_1 = _e117;
            } else {
                local_1 = 0u;
            }
            let _e118 = local_1;
            v = _e118;
            workgroupBarrier();
            let _e119 = li;
            let _e120 = v;
            let _e122 = sh_scan[_e119];
            sh_scan[_e119] = (_e122 + _e120);
            workgroupBarrier();
            continue;
        } else {
            break;
        }
        continuing {
            let _e125 = off;
            off = (_e125 << bitcast<u32>(1u));
        }
    }
    let _e128 = n;
    blocks = (((_e128 + 1024u) - 1u) / 1024u);
    let _e132 = g;
    let _e134 = blocks;
    let _e135 = g;
    upto = select(_e135, _e134, (_e132 == 0u));
    s = 0u;
    let _e137 = li;
    k_1 = _e137;
    loop {
        let _e138 = k_1;
        let _e139 = upto;
        if (_e138 < _e139) {
            let _e141 = k_1;
            let _e144 = unnamed_1.counts[_e141];
            let _e145 = s;
            s = (_e145 + _e144);
            continue;
        } else {
            break;
        }
        continuing {
            let _e147 = k_1;
            k_1 = (_e147 + 256u);
        }
    }
    let _e149 = li;
    let _e150 = s;
    sh_sum[_e149] = _e150;
    workgroupBarrier();
    half = 128u;
    loop {
        let _e152 = half;
        if (_e152 > 0u) {
            let _e154 = li;
            let _e155 = half;
            if (_e154 < _e155) {
                let _e157 = li;
                let _e158 = li;
                let _e159 = half;
                let _e162 = sh_sum[(_e158 + _e159)];
                let _e164 = sh_sum[_e157];
                sh_sum[_e157] = (_e164 + _e162);
            }
            workgroupBarrier();
            continue;
        } else {
            break;
        }
        continuing {
            let _e167 = half;
            half = (_e167 >> bitcast<u32>(1u));
        }
    }
    let _e170 = g;
    if (_e170 == 0u) {
        local_2 = 0u;
    } else {
        let _e173 = sh_sum[0i];
        local_2 = _e173;
    }
    let _e174 = local_2;
    let _e175 = li;
    let _e177 = sh_scan[_e175];
    let _e179 = mine;
    idx = ((_e174 + _e177) - _e179);
    k_2 = 0u;
    loop {
        let _e181 = k_2;
        if (_e181 < 4u) {
            let _e183 = k_2;
            let _e185 = keys[_e183];
            if (_e185 == 0u) {
                continue;
            }
            let _e187 = i0_;
            let _e188 = k_2;
            i = (_e187 + _e188);
            let _e190 = idx;
            if (_e190 < 64u) {
                let _e192 = i;
                let _e195 = pc.i0_[0u];
                x = (_e192 % bitcast<u32>(_e195));
                let _e198 = i;
                let _e201 = pc.i0_[0u];
                y = (_e198 / bitcast<u32>(_e201));
                let _e204 = idx;
                let _e205 = x;
                let _e208 = y;
                let _e211 = k_2;
                let _e213 = keys[_e211];
                let _e217 = k_2;
                let _e219 = keys[_e217];
                unnamed_2.pend[_e204] = vec4<f32>((f32(_e205) + 0.5f), (f32(_e208) + 0.5f), f32((_e213 >> bitcast<u32>(16u))), (f32((_e219 & 65535u)) / 256f));
            }
            let _e226 = idx;
            idx = (_e226 + bitcast<u32>(1i));
            let _e229 = i;
            unnamed.ex_grid[_e229] = 0u;
            continue;
        } else {
            break;
        }
        continuing {
            let _e232 = k_2;
            k_2 = (_e232 + bitcast<u32>(1i));
        }
    }
    let _e235 = g;
    let _e237 = li;
    if ((_e235 == 0u) && (_e237 == 0u)) {
        let _e241 = sh_sum[0i];
        unnamed_2.pend_header = vec4<u32>(min(_e241, 64u), 0u, 0u, 0u);
    }
    return;
}

@compute @workgroup_size(256, 1, 1) 
fn main(@builtin(local_invocation_index) gl_LocalInvocationIndex: u32, @builtin(workgroup_id) gl_WorkGroupID: vec3<u32>) {
    gl_LocalInvocationIndex_1 = gl_LocalInvocationIndex;
    main_1(gl_WorkGroupID);
}
