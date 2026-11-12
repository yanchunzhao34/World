// Visibility in simulation coordinates, using full-resolution optical extinction.
// Cell traversal cannot jump over one-cell walls, even at diagonal angles.
@group(0) @binding(30) var occlusion_extinction: texture_2d<f32>;
@group(0) @binding(31) var occlusion_emission: texture_2d<f32>;

fn workshop_extinction(cell: vec2<i32>) -> vec3<f32> {
    let size = vec2<i32>(textureDimensions(occlusion_extinction));
    if any(cell < vec2<i32>(0)) || any(cell >= size) { return vec3<f32>(0.0); }
    let extinction = max(textureLoad(occlusion_extinction, cell, 0).rgb, vec3<f32>(0.0));
    if all(extinction == vec3<f32>(0.0)) { return extinction; }
    let emission = textureLoad(occlusion_emission, cell, 0).rgb;
    // A visible hot/emissive surface is itself a source of the glow, not a wall
    // between that glow and the camera. Cold opaque material still blocks it.
    if max(emission.r, max(emission.g, emission.b)) > 0.02 { return vec3<f32>(0.0); }
    return extinction;
}

fn workshop_transmission(start: vec2<f32>, end: vec2<f32>) -> vec3<f32> {
    let delta = end - start;
    let distance = length(delta);
    if distance < 0.0001 { return vec3<f32>(1.0); }
    let direction = delta / distance;
    var cell = vec2<i32>(floor(start));
    let last = vec2<i32>(floor(end));
    if all(cell == last) { return vec3<f32>(1.0); }
    let first = cell;
    let step = vec2<i32>(sign(direction));
    let interval = 1.0 / max(abs(direction), vec2<f32>(0.000001));
    let boundary = vec2<f32>(cell) + select(vec2<f32>(0.0), vec2<f32>(1.0), direction > vec2<f32>(0.0));
    var next = (boundary - start) / select(vec2<f32>(0.000001), direction, abs(direction) > vec2<f32>(0.000001));
    next = select(vec2<f32>(1e20), next, abs(direction) > vec2<f32>(0.000001));
    var current = 0.0;
    var transmission = vec3<f32>(1.0);
    // The longest segment inside the 512 x 288 grid visits at most 800 cells.
    for (var index = 0; index < 1024; index++) {
        let until = min(distance, min(next.x, next.y));
        if any(cell != first) && any(cell != last) {
            let extinction = workshop_extinction(cell);
            if any(extinction > vec3<f32>(0.0)) {
                transmission *= exp(-extinction * max(until - current, 0.0));
                if max(transmission.r, max(transmission.g, transmission.b)) < 0.003 {
                    return vec3<f32>(0.0);
                }
            }
        }
        if until >= distance { return transmission; }
        let axes = next <= vec2<f32>(until + 0.000001);
        cell += select(vec2<i32>(0), step, axes);
        next += select(vec2<f32>(0.0), interval, axes);
        current = until;
    }
    return vec3<f32>(0.0);
}
