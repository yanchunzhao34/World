struct WorkshopOcclusionView { values: array<vec4<f32>, 29> }
@group(0) @binding(32) var<uniform> occlusion_view: WorkshopOcclusionView;

fn workshop_bloom_world(uv: vec2<f32>) -> vec2<f32> {
    let camera = occlusion_view.values[16];
    return camera.xy + (uv * 2.0 - 1.0) * camera.zw;
}

fn workshop_bloom_sample(tex: texture_2d<f32>, smp: sampler, uv: vec2<f32>, level: f32) -> vec4<f32> {
    let size = vec2<i32>(textureDimensions(tex));
    let at = uv * vec2<f32>(size) - 0.5;
    let base = vec2<i32>(floor(at));
    let fraction = fract(at);
    let output_uv = (vec2<f32>(gl_GlobalInvocationID_1.xy) + 0.5) / vec2<f32>(pc.i0_.xy);
    let receiver = workshop_bloom_world(output_uv);
    var result = vec4<f32>(0.0);
    // Visibility is applied to individual texels before interpolation. Testing
    // one interpolated value would already mix the two sides of a thin wall.
    for (var y = 0; y < 2; y++) {
        for (var x = 0; x < 2; x++) {
            let cell = clamp(base + vec2<i32>(x, y), vec2<i32>(0), size - 1);
            let source = workshop_bloom_world((vec2<f32>(cell) + 0.5) / vec2<f32>(size));
            // A cold wall may receive bloom but must not relay that accumulated
            // bloom to its far side in the next pyramid level. Actual HDR
            // highlights can still seed bloom during the initial prefilter.
            if !(WORKSHOP_BLOOM_DOWN && pc.i1_.x != 0) && any(floor(source) != floor(receiver)) {
                if all(workshop_extinction(vec2<i32>(floor(source))) >= vec3<f32>(999.0)) { continue; }
            }
            let weight = select(1.0 - fraction.x, fraction.x, x == 1) * select(1.0 - fraction.y, fraction.y, y == 1);
            let value = textureLoad(tex, cell, 0);
            if weight <= 0.00001 || max(value.r, max(value.g, value.b)) <= 0.000001 { continue; }
            result += vec4<f32>(value.rgb * workshop_transmission(receiver, source), value.a) * weight;
        }
    }
    return result;
}
