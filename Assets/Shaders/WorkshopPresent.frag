#version 450
ShaderInfo {
    Name "Element Workshop Present"
    Hidden On
    Capabilities [Fullscreen]
    Resources { BufferUInt _Frame BufferUInt _State }
    Inputs { Float2 inUV }
    Outputs { Float4 outColor }
}

vec3 pixel(ivec2 point, ivec2 dimensions) {
    point = clamp(point, ivec2(0), dimensions - 1);
    uint value = _Frame.data[uint(point.y * dimensions.x + point.x)];
    return vec3(value & 255u, (value >> 8u) & 255u, (value >> 16u) & 255u) / 255.0;
}

vec3 sampleImage(vec2 uv, ivec2 dimensions) {
    vec2 position = uv * vec2(dimensions) - 0.5;
    ivec2 base = ivec2(floor(position));
    vec2 blend = fract(position);
    return mix(mix(pixel(base, dimensions), pixel(base + ivec2(1, 0), dimensions), blend.x),
               mix(pixel(base + ivec2(0, 1), dimensions), pixel(base + ivec2(1, 1), dimensions), blend.x), blend.y);
}

vec3 sharp(vec2 position, ivec2 dimensions, float scale) {
    vec2 base = floor(position - 0.5) + 0.5;
    vec2 fraction = position - base;
    vec2 blend = clamp((fraction - 0.5) * max(scale, 1.0) + 0.5, 0.0, 1.0);
    return sampleImage((base + blend) / vec2(dimensions), dimensions);
}

float hash21(vec2 position) {
    vec2 q = fract(position * vec2(443.897, 441.423));
    q += dot(q, q.yx + 19.19);
    return fract((q.x + q.y) * q.x);
}

void main() {
    ivec2 dimensions = ivec2(_State.data[0], _State.data[1]);
    vec2 rectSize = vec2(uintBitsToFloat(_State.data[2]), uintBitsToFloat(_State.data[3]));
    vec2 cameraSize = vec2(uintBitsToFloat(_State.data[4]), uintBitsToFloat(_State.data[5]));
    vec2 center = vec2(uintBitsToFloat(_State.data[6]), uintBitsToFloat(_State.data[7]));
    float zoom = uintBitsToFloat(_State.data[8]);
    float vignette = uintBitsToFloat(_State.data[9]);
    float grain = uintBitsToFloat(_State.data[10]);
    float chroma = uintBitsToFloat(_State.data[11]);
    float gameTime = uintBitsToFloat(_State.data[12]);
    vec3 color;
    if (_State.data[13] == 0u) {
        vec2 point = inUV * vec2(dimensions);
        vec2 d = (inUV - 0.5) * chroma * 6.0;
        float scale = rectSize.y / float(dimensions.y);
        color = vec3(sharp(point + d, dimensions, scale).r,
                     sharp(point, dimensions, scale).g,
                     sharp(point - d, dimensions, scale).b);
    } else {
        vec2 cell = center + (inUV * cameraSize - cameraSize * 0.5) / zoom;
        bool inside = all(greaterThanEqual(cell, vec2(0))) && all(lessThanEqual(cell, vec2(512, 288)));
        color = inside ? sharp(cell, dimensions, zoom * rectSize.y / cameraSize.y) : vec3(0.015, 0.016, 0.022);
    }
    vec2 q = inUV - 0.5;
    color *= 1.0 - vignette * smoothstep(0.2, 0.9, dot(q, q) * 2.2);
    color += (hash21(inUV * rectSize + fract(gameTime) * 137.0) - 0.5) * grain;
    color = clamp(color, 0.0, 1.0);
    // The native render target's present pass performs the output sRGB encoding.
    vec3 linear = mix(color / 12.92, pow((color + 0.055) / 1.055, vec3(2.4)),
                      greaterThan(color, vec3(0.04045)));
    outColor = vec4(linear, 1.0);
}
