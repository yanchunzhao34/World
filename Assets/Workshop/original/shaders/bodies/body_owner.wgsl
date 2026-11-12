struct Params {
    i0_: vec4<i32>,
    i1_: vec4<i32>,
    f0_: vec4<f32>,
    f1_: vec4<f32>,
}

struct Updates {
    upd: array<vec2<u32>>,
}

struct Owner {
    owner: array<u32>,
}

var<private> gl_GlobalInvocationID_1: vec3<u32>;
@group(1) @binding(0) 
var<uniform> pc: Params;
@group(0) @binding(1) 
var<storage> unnamed: Updates;
@group(0) @binding(0) 
var<storage, read_write> unnamed_1: Owner;

fn main_1() {
    var i: u32;
    var u: vec2<u32>;

    let _e13 = gl_GlobalInvocationID_1[0u];
    i = _e13;
    let _e14 = i;
    let _e17 = pc.i0_[0u];
    if (_e14 >= bitcast<u32>(_e17)) {
        return;
    }
    let _e20 = i;
    let _e23 = unnamed.upd[_e20];
    u = _e23;
    let _e25 = u[0u];
    let _e28 = unnamed_1.owner[_e25];
    if (_e28 != 4294967295u) {
        let _e31 = u[0u];
        let _e33 = u[1u];
        unnamed_1.owner[_e31] = _e33;
    }
    return;
}

@compute @workgroup_size(64, 1, 1) 
fn main(@builtin(global_invocation_id) gl_GlobalInvocationID: vec3<u32>) {
    gl_GlobalInvocationID_1 = gl_GlobalInvocationID;
    main_1();
}
