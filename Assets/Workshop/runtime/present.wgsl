
struct P {
	rect_size: vec2f, view_size: vec2f,
	world_size: vec2f, cam_center: vec2f,
	zoom: f32, vignette: f32, grain: f32, chroma: f32,
	time: f32, mode: f32, pad0: f32, pad1: f32,
	outside: vec4f,
};
@group(0) @binding(0) var view_tex: texture_2d<f32>;
@group(0) @binding(1) var world_tex: texture_2d<f32>;
@group(0) @binding(2) var smp: sampler;
@group(0) @binding(3) var<uniform> p: P;

struct V { @builtin(position) pos: vec4f, @location(0) uv: vec2f };
@vertex fn vs(@builtin(vertex_index) i: u32) -> V {
	var q = array<vec2f, 3>(vec2f(-1.0, -1.0), vec2f(3.0, -1.0), vec2f(-1.0, 3.0));
	var o: V;
	o.pos = vec4f(q[i], 0.0, 1.0);
	o.uv = vec2f(q[i].x * 0.5 + 0.5, 0.5 - q[i].y * 0.5);
	return o;
}

fn hash(p0: vec2f) -> f32 {
	var q = fract(p0 * vec2f(443.897, 441.423));
	q += dot(q, q.yx + 19.19);
	return fract((q.x + q.y) * q.x);
}

// texel-space position t in a texture of size 'size', magnified by 'scale' screen pixels per texel
fn sharp(tex: texture_2d<f32>, t: vec2f, size: vec2f, scale: f32) -> vec3f {
	let base = floor(t - 0.5) + 0.5;
	let f = t - base;
	let s = clamp((f - 0.5) * max(scale, 1.0) + 0.5, vec2f(0.0), vec2f(1.0));
	return textureSampleLevel(tex, smp, (base + s) / size, 0.0).rgb;
}

@fragment fn fs(v: V) -> @location(0) vec4f {
	let px = v.uv * p.rect_size;
	var col: vec3f;
	if (p.mode < 0.5) {
		let scale = p.rect_size.y / p.view_size.y;
		let t = v.uv * p.view_size;
		if (p.chroma > 0.0) {
			let d = (v.uv - 0.5) * p.chroma * 6.0;
			col = vec3f(sharp(view_tex, t + d, p.view_size, scale).r, sharp(view_tex, t, p.view_size, scale).g, sharp(view_tex, t - d, p.view_size, scale).b);
		} else {
			col = sharp(view_tex, t, p.view_size, scale);
		}
	} else {
		let cell = p.cam_center + (px - p.rect_size * 0.5) / p.zoom;
		let inside = all(cell >= vec2f(0.0)) && all(cell <= p.world_size);
		col = select(p.outside.rgb, sharp(world_tex, cell, p.world_size, p.zoom), inside);
	}
	let q = v.uv - 0.5;
	let vg = 1.0 - p.vignette * smoothstep(0.2, 0.9, dot(q, q) * 2.2);
	col *= vg;
	col += (hash(px + fract(p.time) * 137.0) - 0.5) * p.grain;
	return vec4f(col, 1.0);
}