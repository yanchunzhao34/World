struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct StampedPrev {
    stamped_prev: array<u32>,
}

struct Alive {
    alive: array<u32>,
}

struct Owner {
    owner: array<u32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(2) 
var<storage> unnamed: StampedPrev;
@group(0) @binding(1) 
var<storage> unnamed_1: Alive;
@group(0) @binding(0) 
var<storage, read_write> unnamed_2: Owner;

fn web_findLSB_u0028_u1_u003b(x: ptr<function, u32>) -> i32 {
    var i: i32;

    i = 0i;
    loop {
        let _e17 = i;
        if (_e17 < 32i) {
            let _e19 = (*x);
            let _e20 = i;
            if ((_e19 & (1u << bitcast<u32>(bitcast<u32>(_e20)))) != 0u) {
                let _e26 = i;
                return _e26;
            }
            continue;
        } else {
            break;
        }
        continuing {
            let _e27 = i;
            i = (_e27 + 1i);
        }
    }
    return -1i;
}

fn main_1() {
    var w: u32;
    var dead: u32;
    var b: i32;
    var param: u32;

    let _e20 = gl_GlobalInvocationID_1[0u];
    w = _e20;
    let _e21 = w;
    let _e24 = pc.i0_[0u];
    if (_e21 >= bitcast<u32>(_e24)) {
        return;
    }
    let _e27 = w;
    let _e30 = unnamed.stamped_prev[_e27];
    let _e31 = w;
    let _e34 = unnamed_1.alive[_e31];
    dead = (_e30 & ~(_e34));
    loop {
        let _e37 = dead;
        if (_e37 != 0u) {
            let _e39 = dead;
            param = _e39;
            let _e40 = web_findLSB_u0028_u1_u003b((&param));
            b = _e40;
            let _e41 = w;
            let _e43 = b;
            unnamed_2.owner[((_e41 * 32u) + bitcast<u32>(_e43))] = 4294967295u;
            let _e48 = dead;
            let _e50 = dead;
            dead = (_e50 & (_e48 - 1u));
            continue;
        } else {
            break;
        }
    }
    return;
}

@compute @workgroup_size(64, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
