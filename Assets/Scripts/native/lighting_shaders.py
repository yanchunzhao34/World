"""Scoped shader overlays; the archived Godot shader sources stay unchanged."""

POSTPROCESS = {"render/bloom_down.comp", "render/bloom_up.comp", "render/tonemap.comp"}
FOG = {"render/front_fog.comp", "render/view3d.comp"}


# 将遮挡修正接入指定着色器源码。
def lighting_shader_source(assets, path, source):
    if path not in POSTPROCESS and path not in FOG:
        return source

    shared = (assets / "shaders/occlusion.wgsl").read_text("utf-8")

    if path in POSTPROCESS:
        shared += (
            "\nconst WORKSHOP_BLOOM_DOWN: bool = "
            + ("true" if path == "render/bloom_down.comp" else "false")
            + ";\n"
        )
        shared += (assets / "shaders/bloom_visibility.wgsl").read_text("utf-8")
        textures = {
            "render/bloom_down.comp": [("src", "src_smp")],
            "render/bloom_up.comp": [("low", "low_smp"), ("cur", "cur_smp")],
            "render/tonemap.comp": [("bloom_tex", "bloom_tex_smp")],
        }

        for texture, sampler in textures[path]:
            old = f"textureSampleLevel({texture}, {sampler}, "

            if old not in source:
                raise ValueError("Lighting overlay no longer matches " + path)

            source = source.replace(
                old, f"workshop_bloom_sample({texture}, {sampler}, "
            )

    else:
        # Radiance cascades already integrate incident light with material
        # occlusion. Sample that field once per volume slice instead of blurring
        # neighbouring sources across walls a second time. Keep all 32 slices,
        # original density/noise, view parallax and extinction integration.
        if path == "render/front_fog.comp":
            begin = source.index("                Lin = (_e159 * 0.25f);")
            end = source.index("                let _e186 = Tv;", begin)
            source = source[:begin] + "                Lin = _e159;\n" + source[end:]

        samples = ("param_9",) if path == "render/front_fog.comp" else ("param_24",)
        origin = "p0_.xy" if path == "render/front_fog.comp" else "(*p0_).xy"

        for sample in samples:
            old = f"plane_backlight_u0028_vf2_u003b((&{sample}))"

            if source.count(old) != 1:
                raise ValueError("Fog overlay no longer matches " + path)

            source = source.replace(old, f"workshop_fog_sample({origin}, {sample})")

        if path == "render/view3d.comp":
            old = "let _e360 = fluence_depth_u0028_vf2_u003b_f1_u003b((&param_19), (&param_20));"

            if source.count(old) != 1:
                raise ValueError("Volume overlay no longer matches " + path)

            source = source.replace(
                old, "let _e360 = fluence_at_u0028_vf2_u003b((&param_19));"
            )

        shared += """
fn workshop_fog_sample(receiver: vec2<f32>, sample: vec2<f32>) -> vec3<f32> {
    var position = sample;
    let radiance = plane_backlight_u0028_vf2_u003b(&position);
    if all(radiance == vec3<f32>(0.0)) { return radiance; }
    return radiance * workshop_transmission(receiver, sample);
}
"""

    return source + "\n" + shared
