/**
 * 原版类名来自发布包压缩结果；只在这个边界映射为可读名称。
 * original_core.js 保留算法来源，避免大范围改名破坏其内部依赖。
 */
const RenderSettings = kt;
const SimulationGrid = et;
const WorldRenderer = Qt;
const WorldCamera = Ft;
const BrushCommands = Xe;
const RigidBodyWorld = dt;
const RigidBodyGpuBridge = mt;
const SimulationStatistics = D;
const BrushCommandType = E;

// 世界格子二进制布局：每格四个 32 位字，共 16 字节；不是窗口像素尺寸。
const WORLD_WIDTH = 512;
const WORLD_HEIGHT = 288;
const CELL_BYTES = 16;

const gameInfo = JSON.parse(gameJson);
const gpu = new NativeGPU();
const gameData = {
    info: gameInfo,
    materials: host.ReadFile('materials.bin'),
    reactions: host.ReadFile('reactions.bin'),
    lut: host.ReadFile('lut.bin')
};
const app = {
    W: WORLD_WIDTH,
    H: WORLD_HEIGHT,
    materials: gameInfo.materials,
    settings: new RenderSettings(gameInfo.renderSettings),
    sim: null,
    render: null,
    camera: new WorldCamera(),
    commands: new BrushCommands(),
    rigid: null,
    bodyGpu: null,
    currentMap: 'lab',
    currentBackground: null,
    paused: false,
    speed: 1,
    time: 0,
    accum: 0,
    steps: 0,
    bodify: false,
    stats: new SimulationStatistics(),
    probe: {
        valid: false
    },
    selected: 14,
    matId(key) {
        return this.materials.findIndex(m => m.key === key);
    },
    requestBodify() {
        this.bodify = true;
    }
};
app.sim = new SimulationGrid(gpu, WORLD_WIDTH, WORLD_HEIGHT, gameData);
app.render = new WorldRenderer(gpu, WORLD_WIDTH, WORLD_HEIGHT, app.settings, 1536, 864);
app.rigid = new RigidBodyWorld(WORLD_WIDTH, WORLD_HEIGHT, app.materials);
app.bodyGpu = new RigidBodyGpuBridge(gpu, WORLD_WIDTH, WORLD_HEIGHT);
app.camera.worldSize = [512, 288];
app.camera.screen = [1536, 864];
app.camera.fit();
let sceneRevision = 0;
let titleElapsed = 0;
const demo = {
    current: null,
    t: 0,
    next: 0,
    caption: '',
    alpha: 0,
    saved: [],
    freeze: false
};
/** 结束演示后恢复临时覆盖的设置；不把演示参数写成玩家永久配置。 */
function stopDemo() {
    if (demo.current) {
        app.settings.freezeTime = demo.freeze;
        for (const [key, value] of demo.saved) app.settings.set(key, value);
    }
    demo.current = null;
    demo.caption = '';
    demo.alpha = 0;
    demo.saved = [];
}
/** 原版演示包含地图、临时设置、时间、步骤、镜头和字幕。 */
function playDemo(key) {
    const item = er.find(e => e.key === key);
    if (!item) throw new Error('Unknown demo: ' + key);
    stopDemo();
    loadMap(item.scene);
    demo.freeze = app.settings.freezeTime;
    demo.saved = item.settings.map(([key, value]) => {
        const old = app.settings.v[key];
        app.settings.set(key, value);
        return [key, old];
    });
    app.settings.freezeTime = true;
    app.settings.timeOfDay = item.timeOfDay;
    app.paused = false;
    item.steps.sort((a, b) => a[0] - b[0]);
    demo.t = 0;
    demo.next = 0;
    demo.current = item;
}
/** 按经过时间执行所有到期命令，再更新镜头与字幕；结束时恢复设置。 */
function updateDemo(delta) {
    const item = demo.current;
    if (!item) return;
    demo.t += delta;
    const time = demo.t;
    while (demo.next < item.steps.length && item.steps[demo.next][0] <= time) item.steps[demo.next++][1](app);
    if (item.cam.length) {
        let index = 0;
        while (index + 1 < item.cam.length && item.cam[index + 1][0] <= time) index++;
        const a = item.cam[index],
            b = item.cam[Math.min(index + 1, item.cam.length - 1)],
            duration = Math.min(1.6, Math.max(b[0] - a[0], .01));
        let mix = b[0] > a[0] ? Math.min(Math.max((time - (b[0] - duration)) / duration, 0), 1) : 0;
        mix = mix * mix * (3 - 2 * mix);
        app.camera.setView([a[1] + (b[1] - a[1]) * mix, a[2] + (b[2] - a[2]) * mix], a[3] + (b[3] - a[3]) *
            mix);
    }
    demo.caption = '';
    demo.alpha = 0;
    for (const [start, duration, zh] of item.captions)
        if (time >= start && time < start + duration) {
            demo.caption = zh;
            demo.alpha = Math.min(Math.max(Math.min(time - start, start + duration - time) / .4, 0), 1);
        }
    if (time >= item.length) stopDemo();
}
/** 载入格子与背景，并清空光照时间历史。sceneRevision 通知图鉴重建计数基线。 */
function loadMap(key) {
    sceneRevision++;
    titleElapsed = 0;
    app.probe = {
        valid: false
    };
    app.probePoint = null;
    const cells = host.ReadFile('maps/' + key + '.cells.gz');
    const bg = new Uint8Array(host.ReadFile('maps/' + key + '.bg.gz'));
    app.currentMap = key;
    app.currentBackground = bg;
    app.sim.upload(cells);
    app.render.uploadBackground(bg);
    app.rigid.clear();
    app.rigid.onCells(cells);
    app.bodify = false;
    app.time = 0;
    app.accum = 0;
    app.camera.fit();
    // Reset temporal histories, exposure and render scheduling as a fresh scene.
    for (const pair of [app.render.fluence, app.render.day, app.render.beamTex, app.render.beamDir, app.render
            .sub, app.render.chA, app.render.chB
        ]) {
        gpu.clearTexture(pair.read);
        gpu.clearTexture(pair.write);
    }
    for (const t of [app.render.ldir, ...app.render.cascades, app.render.upperAvg]) gpu.clearTexture(t);
    gpu.device.queue.writeBuffer(app.render.exposureBuf, 0, new Float32Array([0, 0, 0, 1]));
    app.render.frame = 0;
    app.render.lastTime = 0;
    app.settings.timeOfDay = key === 'titlelab' ? 9.5 : 10;
    worldObservation.recordReset('load', key);
}
/** 主页背景沿用原版每帧两次推进时钟的编排，不能改成一次而改变播放节奏。 */
function updateTitle(delta) {
    if (app.currentMap !== 'titlelab') return;
    app.camera.center = [app.W / 2, app.H / 2];
    // Preserve the published title animation's two updates of its local clock.
    titleElapsed += delta;
    const previous = titleElapsed;
    titleElapsed += delta;
    or(app, previous, titleElapsed);
    if (titleElapsed >= 22) loadMap('titlelab');
}
/** Godot → JS 的操作协议入口。名称及参数与 workshop_ui.gd 的 send 保持一致。 */
function applyAction(json) {
    const action = JSON.parse(json);
    const epochBefore = worldObservation.worldEpoch;
    const tickAtAcceptance = app.sim.tick;
    let handled = true;
    switch (action.type) {
        case 'load':
            stopDemo();
            loadMap(action.map);
            break;
        case 'demo':
            playDemo(action.key);
            break;
        case 'demo_stop':
            stopDemo();
            break;
        case 'pause':
            app.paused = !!action.value;
            break;
        case 'step':
            app.steps++;
            break;
        case 'speed':
            app.speed = action.value;
            break;
        case 'time':
            app.settings.timeOfDay = action.value;
            break;
        case 'setting':
            app.settings.set(action.key, action.value);
            break;
        case 'debug':
            app.render.mode = action.value;
            break;
        case 'resize':
            app.camera.screen = [action.width, action.height];
            app.camera.fit();
            const height = Math.min(Math.max(app.settings.n('ViewHeight'), 270), 2160) & -8;
            app.render.setViewSize(Math.max(64, Math.round(height * action.width / action.height) & -8),
                height);
            break;
        case 'fit':
            app.camera.fit();
            break;
        case 'pan':
            app.camera.panBy(action.x, action.y);
            break;
        case 'zoom':
            app.camera.zoomBy(action.x, action.y, action.factor);
            break;
        case 'yaw':
            app.camera.turn(action.value);
            break;
        case 'probe': {
            app.probePoint = {
                screen_x: action.x,
                screen_y: action.y,
                request_id: action.request_id || 0
            };
            break;
        }
        case 'paint':
            queuePaintCommand(action);
            break;
        case 'clear':
            app.commands.add({
                type: BrushCommandType.Clear,
                from: [0, 0],
                to: [0, 0],
                radius: 0
            });
            app.rigid.clear();
            worldObservation.recordReset('clear_queued', app.currentMap);
            break;
        case 'save':
            host.SaveState(app.currentMap, app.settings.timeOfDay,
                host.ReadTexture(app.sim.cells.read.id, 0, 0, WORLD_WIDTH, WORLD_HEIGHT, CELL_BYTES), app
                .currentBackground.buffer);
            break;
        case 'restore': {
            const saved = JSON.parse(host.LoadSavedInfo());
            const cells = host.LoadSavedCells();
            app.sim.upload(cells);
            app.currentBackground = new Uint8Array(host.LoadSavedBackground());
            app.render.uploadBackground(app.currentBackground);
            stopDemo();
            sceneRevision++;
            app.currentMap = saved.map;
            app.settings.timeOfDay = saved.time;
            app.rigid.clear();
            app.rigid.onCells(cells);
            worldObservation.recordReset('restore', app.currentMap);
            break;
        }
        default:
            handled = false;
    }
    worldObservation.recordAction(action, epochBefore, tickAtAcceptance, handled);
}
/**
 * 每帧唯一入口。调用顺序影响反馈纹理、刚体占用与探针结果，必须保持：
 * 时间编排 → 相机 → 模拟/渲染/统计 → 探针 → 微任务回调 → UI 状态。
 * forcedTicks 是验证入口；正常运行由累计时间决定固定 60 Hz 的步数。
 */
function nativeFrame(delta, forcedTicks = -1) {
    worldObservation.beginFrame(app, delta, forcedTicks);
    app.time += delta;
    updateTitle(delta);
    updateDemo(delta);
    const ticks = calculateSimulationTicks(delta, forcedTicks);
    updateCameraAndDaylight(delta);
    simulateAndRender(ticks);
    updatePointerProbe();
    while (jobs.length) jobs.shift()();
    worldObservation.endFrame(app);
    return serializeFrameState();
}

/** 自动追赶最多两步；手动单步在其后累加，不能一并截断。 */
function calculateSimulationTicks(delta, forcedTicks) {
    let ticks = 0;

    if (!app.paused) {
        app.accum += delta * 60 * app.speed;
        ticks = Math.floor(app.accum);
        app.accum -= ticks;
        if (ticks > 2) {
            ticks = 2;
            app.accum = 0;
        }
    }
    ticks += app.steps;
    app.steps = 0;
    if (forcedTicks >= 0) ticks = forcedTicks;

    return ticks;
}

/** 相机参数和时间变化只在此处同步，保持原版帧视差公式。 */
function updateCameraAndDaylight(delta) {
    const camera = app.camera,
        settings = app.settings;
    camera.tiltTopDeg = settings.effectiveTilt;
    camera.tiltBottomDeg = settings.voxel ? settings.n('TiltBottom') : 0;
    camera.tiltCurve = settings.n('TiltCurve');
    camera.yawMaxDeg = settings.effectiveYaw;
    camera.applyYaw = settings.voxel;
    camera.fovYDeg = settings.n('FovY');
    camera.update(delta);
    if (settings.b('DayCycleOn') && !settings.freezeTime && !app.paused)
        settings.timeOfDay = (settings.timeOfDay + delta * 24 / Math.max(settings.n('DayLength') * 60, 1) *
            app.speed) % 24;
    settings.frameParallax = [-(camera.center[0] - 256) / 256 * settings.n('Parallax') + Math.tan(camera
            .userYaw * Math.PI / 180) * .5,
        -(camera.center[1] - 144) / 144 * settings.n('Parallax')
    ];

}

/**
 * CPU 刚体与 GPU 格子在 preStep/postStep 交换数据。
 * 暂停时仍允许应用笔刷命令；渲染之后同步读取统计，并反馈爆炸冲量。
 */
function simulateAndRender(ticks) {
    const camera = app.camera;
    const bodies = app.rigid.update(ticks / 60, ticks === 0);
    gpu.begin();
    app.bodyGpu.preStep(app.sim, bodies);
    advanceGridSimulation(ticks);
    app.bodyGpu.postStep(app.sim, bodies.frame, buffer => app.rigid.onOccupancy(buffer), (buffer, frame) =>
        app.rigid.onOwners(buffer, frame));
    app.sim.lightTex = app.render.fluenceTex;
    app.sim.daylightTex = app.render.daylightTex;
    app.render.render(app.sim, app.time, camera.view);
    gpu.submit();
    if (app.bodify) {
        app.bodify = false;
        app.rigid.onCells(host.ReadTexture(app.sim.cells.read.id, 0, 0, WORLD_WIDTH, WORLD_HEIGHT,
            CELL_BYTES));
    }
    app.stats.parse(host.ReadBuffer(app.sim.statsBuf.id, 0, SimulationStatistics.SizeBytes));
    worldObservation.recordExplosions(app.stats.explosions);
    for (const explosion of app.stats.explosions) {
        camera.addShake(Math.min(Math.max(explosion[3] * explosion[2] * .08, .2), 2.5));
        app.rigid.blast(explosion);
    }

}

/**
 * 仅抽出网格推进边界。刚体仍在每帧 preStep/postStep 更新，光照仍在之后渲染。
 * 观测关闭时不复制命令、不读回 GPU；观察者不拥有也不改变模拟器。
 */
function advanceGridSimulation(ticks) {
    for (let ordinal = 0; ordinal < ticks; ordinal++) {
        const commands = ordinal === 0 ? app.commands : null;
        const boundary = worldObservation.beginGridBoundary(app, commands, 'grid_step', ordinal);
        app.sim.step(commands);
        worldObservation.endGridBoundary(boundary, app);
    }
    if (ticks === 0 && app.commands.count) {
        const boundary = worldObservation.beginGridBoundary(app, app.commands, 'paused_commands', 0);
        app.sim.applyCommandsOnly(app.commands);
        worldObservation.endGridBoundary(boundary, app);
    }
}

/**
 * 探针读取的是模拟格子，不从显示颜色推断材料。
 * 温度在格子第二个 32 位字中，以 Kelvin 保存，传给界面时转为摄氏度。
 * 请求编号原样返回，供 UI 拒绝鼠标移走后才返回的过期样本。
 */
function updatePointerProbe() {
    const camera = app.camera;
    if (app.probePoint) {
        const request = app.probePoint,
            pos = camera.screenToCell(request.screen_x, request.screen_y);
        const x = Math.floor(pos[0]),
            y = Math.floor(pos[1]);
        app.probe = {
            ...request,
            valid: false
        };
        if (Number.isFinite(x) && Number.isFinite(y) && x >= 0 && x < app.W && y >= 0 && y < app.H) {
            const b = new DataView(host.ReadTexture(app.sim.cells.read.id, x, y, 1, 1, CELL_BYTES));
            const temp = b.getFloat32(4, true) - 273.15;
            app.probe = {
                ...request,
                valid: Number.isFinite(temp),
                x,
                y,
                material: b.getUint32(0, true) & 255,
                temp
            };
        }
        app.probePoint = null;
    }

}

/** FrameReady 的 JSON 协议。字段名与数组顺序供 GDScript/验证程序使用。 */
function serializeFrameState() {
    const settings = app.settings,
        camera = app.camera;
    const output = app.render.mode === 0 ? app.render.output : app.render.debugOutput;
    return JSON.stringify({
        texture: output.id,
        width: output.width,
        height: output.height,
        tick: app.sim.tick,
        time: app.time,
        day: settings.timeOfDay,
        bodies: app.rigid.bodies.length,
        map: app.currentMap,
        title_elapsed: titleElapsed,
        paused: app.paused,
        probe: app.probe,
        events: Array.from(app.stats.events),
        explosions: app.stats.explosions,
        histogram: Array.from(app.stats.histogram),
        reactions: Array.from(app.stats.reactionCount),
        ignite: Array.from(app.stats.igniteCount),
        phase_hi: Array.from(app.stats.phaseHi),
        phase_lo: Array.from(app.stats.phaseLo),
        scene_revision: sceneRevision,
        frame: app.render.frame,
        demo: demo.current ? demo.current.key : '',
        demo_caption: demo.caption,
        demo_alpha: demo.alpha,
        vignette: settings.n('Vignette'),
        grain: settings.n('Grain'),
        chroma: settings.n('Chroma') * Math.min(Math.hypot(...camera.shake) * .4 + .15, 1),
        zoom: camera.zoom,
        camera_center: camera.view.center,
        camera_size: camera.screen,
        view_mode: app.render.mode
    });
}

/** UI 坐标先经相机转换为格子坐标；数值工具 ID 是既有操作协议。 */
function queuePaintCommand(action) {
    let start = app.camera.screenToCell(action.x0, action.y0),
        end = app.camera.screenToCell(action.x1, action.y1);
    const tool = action.tool;
    let command = {
        type: tool === 2 ? BrushCommandType.Erase : tool === 3 ? BrushCommandType.Heat : tool === 4 ?
            BrushCommandType.Cool : tool === 5 ? BrushCommandType.Ignite : tool === 6 ? BrushCommandType
            .Explode : BrushCommandType.Paint,
        material: tool === 5 ? app.sim.fireId : action.material,
        from: start,
        to: end,
        radius: tool === 6 ? action.radius * 1.5 + 4 : action.radius,
        shape: action.shape || 0,
        overwrite: !!action.overwrite,
        spray: tool === 1 ? .06 : tool === 5 ? .5 : 1,
        strength: tool === 3 || tool === 4 ? 40 : tool === 6 ? 1.2 : 0
    };
    app.commands.add(command);
    if (tool <= 1 && app.materials[action.material].flags & 256) app.bodify = true;

}
