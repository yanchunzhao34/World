/** Occlusion for local glow and front fog. Original renderer scheduling is retained. */
function registerLightingOcclusion() {
    for (const name of ['bloom_down', 'bloom_up', 'tonemap', 'front_fog', 'view3d']) {
        const bindings = Ne['render/' + name + '.comp'].bindings;
        for (const [binding, label] of [[30, 'occlusion_extinction'], [31, 'occlusion_emission']]) {
            bindings.push({group: 0, binding, name: label, kind: 'texture', dim: '2d', sampleType: 'float'});
        }
        if (name !== 'front_fog' && name !== 'view3d') {
            bindings.push({group: 0, binding: 32, name: 'occlusion_view', kind: 'uniform'});
        }
    }
}

function installLightingOcclusion(renderer) {
    // Select the UBO for the current view, including extra views and camera zoom.
    const originalView = renderer.renderView;
    let viewUbo = renderer.ubo;
    renderer.renderView = function(sim, view) {
        const previous = viewUbo;
        viewUbo = view.ubo;
        try { return originalView.call(this, sim, view); }
        finally { viewUbo = previous; }
    };
    for (const name of ['bloom_down', 'bloom_up', 'tonemap', 'front_fog', 'view3d']) {
        const pass = renderer.p[name];
        const originalDispatch = pass.dispatch;
        pass.dispatch = function(bindings, params, ...size) {
            bindings.image(30, renderer.extMips[0]).image(31, renderer.emissive);
            if (name !== 'front_fog' && name !== 'view3d') bindings.ubo(32, viewUbo);
            return originalDispatch.call(this, bindings, params, ...size);
        };
    }
    const backlight = renderer.p.fog_backlight;
    const originalBacklight = backlight.dispatch;
    backlight.dispatch = function(bindings, params, ...size) {
        // Front fog performs its own spatial integral. Feeding it already blurred
        // light imported energy from across walls before visibility could be tested.
        bindings.sampler(2, renderer.gpu.linearClamp, renderer.fluence.read);
        bindings.sampler(3, renderer.gpu.linearClamp, renderer.fluence.read);
        return originalBacklight.call(this, bindings, params, ...size);
    };
}
