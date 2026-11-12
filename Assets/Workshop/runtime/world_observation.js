/**
 * 世界观测协议 v1：只读描述、操作轨迹和明确的计算边界。
 * 不拥有模拟状态，不调用刚体 snapshot()（该方法会排空待上传队列）。
 * 默认关闭详细轨迹；只有请求快照的帧才复制命令和事件。
 */
class WorldObservation {
    constructor() {
        this.enabled = false;
        this.frameSequence = 0;
        this.worldEpoch = 0;
        this.actionSequence = 0;
        this.pendingActions = [];
        this.pendingResets = [];
        this.droppedActions = 0;
        this.droppedResets = 0;
        this.trace = null;
    }

    setEnabled(enabled) {
        this.enabled = !!enabled;
        this.pendingActions = [];
        this.pendingResets = [];
        this.droppedActions = 0;
        this.droppedResets = 0;
        this.trace = null;
    }

    /** epoch 同时限定刚体 slot 的身份；清空后 slot 可以复用，不能作为永久 ID。 */
    recordReset(reason, map) {
        this.worldEpoch++;
        if (this.enabled) {
            if (this.pendingResets.length < 256)
                this.pendingResets.push({world_epoch: this.worldEpoch, reason, map});
            else this.droppedResets++;
        }
    }

    recordAction(action, epochBefore, tick, handled = true) {
        if (!this.enabled) return;
        const item = {
            sequence: ++this.actionSequence,
            epoch_before: epochBefore,
            epoch_after: this.worldEpoch,
            tick_at_acceptance: tick,
            status: handled ? 'handled_by_action_dispatch' : 'ignored_unknown_type',
            input: JSON.parse(JSON.stringify(action))
        };
        // 轨迹有明确容量与缺失标记；不让一次异常输入造成无限增长。
        if (this.pendingActions.length < 256) this.pendingActions.push(item);
        else this.droppedActions++;
    }

    beginFrame(app, delta, forcedTicks) {
        this.frameSequence++;
        if (!this.enabled) return;
        this.trace = {
            frame_sequence: this.frameSequence,
            world_epoch_start: this.worldEpoch,
            tick_start: app.sim.tick,
            frame_delta_seconds: delta,
            forced_ticks: forcedTicks,
            actions: this.pendingActions,
            actions_omitted: this.droppedActions,
            resets: this.pendingResets,
            resets_omitted: this.droppedResets,
            grid_boundaries: [],
            grid_boundaries_omitted: 0,
            events: [],
            coverage: {
                actions: 'accepted_during_this_observed_frame_only',
                commands: 'actual_admitted_queue_including_demo_and_title_commands',
                reactions: 'aggregate_counters_only_no_per_reaction_positions',
                explosions: 'last_grid_step_gpu_statistics_not_all_steps'
            }
        };
        this.pendingActions = [];
        this.pendingResets = [];
        this.droppedActions = 0;
        this.droppedResets = 0;
    }

    /** 此边界位于刚体 preStep 之后；不宣称包含一次完整刚体或光照更新。 */
    beginGridBoundary(app, commands, kind, ordinal) {
        if (!this.enabled) return null;
        if (this.trace.grid_boundaries.length >= 256) {
            this.trace.grid_boundaries_omitted++;
            return null;
        }
        return {
            ordinal,
            kind,
            world_epoch: this.worldEpoch,
            tick_before: app.sim.tick,
            duration_seconds: kind === 'grid_step' ? 1 / 60 : 0,
            command_seed_start: commands ? commands.seed : null,
            commands: commands ? JSON.parse(JSON.stringify(commands.pending)) : []
        };
    }

    endGridBoundary(boundary, app) {
        if (!boundary) return;
        boundary.tick_after = app.sim.tick;
        this.trace.grid_boundaries.push(boundary);
    }

    recordExplosions(explosions) {
        if (!this.enabled) return;
        for (const value of explosions) {
            this.trace.events.push({kind: 'explosion', source: 'gpu_stats', values: Array.from(value)});
        }
    }

    endFrame(app) {
        if (!this.enabled) return;
        this.trace.tick_end = app.sim.tick;
        this.trace.world_epoch_end = this.worldEpoch;
        // 主页动画可能在帧内重新载图；将这些 reset 放在当前帧，避免留给下一帧。
        const remaining = 256 - this.trace.resets.length;
        this.trace.resets.push(...this.pendingResets.slice(0, remaining));
        this.trace.resets_omitted += this.droppedResets + Math.max(0, this.pendingResets.length - remaining);
        this.pendingResets = [];
        this.droppedResets = 0;
    }
}

const worldObservation = new WorldObservation();

/** 仅由 GameRuntime 后台线程在帧开始前切换，不能从 UI 直接接触 Jint。 */
function setWorldObservationEnabled(enabled) {
    worldObservation.setEnabled(enabled);
}

/**
 * 帧末描述：包含内部资源定位信息，C# 读取后剥离 ID，生成对外的稳定字段清单。
 * 此函数没有 GPU 写入、随机调用、模拟推进或消耗队列的操作。
 */
function describeWorldObservation() {
    const resources = [];
    function texture(name, value, dtype, channels, unit) {
        if (!value) return;
        resources.push({name, kind: 'texture', id: value.id, dtype,
            shape: [value.height, value.width, channels], unit, encoding: value.format});
    }
    function buffer(name, value, dtype, shape, unit) {
        resources.push({name, kind: 'buffer', id: value.id, dtype, shape, unit, encoding: 'little_endian'});
    }
    texture('cells_packed', app.sim.cells.read, 'uint32', 4, 'packed_cell_v1');
    texture('fluid_velocity', app.sim.fluidVel.read, 'float16', 4, 'engine_units');
    texture('fluid_pressure', app.sim.pressure.read, 'float32', 1, 'engine_units');
    texture('fluid_divergence', app.sim.divergence, 'float32', 1, 'engine_units');
    texture('medium', app.sim.medium.read, 'float16', 4, 'engine_units');
    texture('simulation_light_input', app.sim.lightTex, 'float16', 4, 'engine_units');
    texture('simulation_daylight_input', app.sim.daylightTex, 'float16', 4, 'engine_units');
    texture('render_fluence', app.render.fluenceTex, 'float16', 4, 'engine_units');
    texture('render_daylight', app.render.daylightTex, 'float16', 4, 'engine_units');
    for (let index = 0; index < app.sim.fluidState.length; index++) {
        buffer('fluid_state_' + index, app.sim.fluidState[index], 'int32',
            [app.sim.fluidH, app.sim.fluidW, 4], 'engine_fixed_point');
    }
    buffer('statistics_packed', app.sim.statsBuf, 'uint32', [D.SizeBytes / 4], 'mixed_stats_v1');
    resources.push({name: 'background_rgba', kind: 'cpu', dtype: 'uint8',
        shape: [app.H, app.W, 4], unit: 'unorm_0_255', encoding: 'rgba8'});

    return JSON.stringify({
        schema: 'element-workshop.world-observation',
        schema_version: 1,
        boundary: {kind: 'frame_end', frame_sequence: worldObservation.frameSequence,
            world_epoch: worldObservation.worldEpoch, scene_revision: sceneRevision,
            tick: app.sim.tick, render_frame: app.render.frame,
            grid_time_seconds: app.sim.tick / 60, frame_time_seconds: app.time,
            ordering: 'after_native_frame_return_before_next_frame'},
        completeness: {kind: 'observation', restorable: false,
            omitted: ['full_gpu_temporal_histories', 'rigid_gpu_ownership_atlas',
                'all_random_generator_states', 'per_reaction_position_events',
                'full_state_at_each_internal_grid_boundary']},
        world: {width: app.W, height: app.H, coordinate_order: 'x_y', array_order: 'y_x_channel',
            origin: 'top_left', y_axis: 'down', length_unit: 'cell'},
        material_catalog: app.materials.map((material, index) => ({
            id: material.id === undefined ? index : material.id,
            key: material.key, name: material.zh, state: material.state, flags: material.flags
        })),
        reaction_catalog: gameInfo.reactions.map((reaction, index) => ({
            index, key: reaction.key, input_a: reaction.a, input_b: reaction.b,
            output_a: reaction.outA, output_b: reaction.outB
        })),
        view: {camera_center: app.camera.view.center, camera_screen: app.camera.screen,
            zoom: app.camera.zoom, view_mode: app.render.mode},
        control: {map: app.currentMap, paused: app.paused, speed: app.speed,
            pending_manual_steps: app.steps, accumulator: app.accum, day: app.settings.timeOfDay,
            pending_commands: JSON.parse(JSON.stringify(app.commands.pending)),
            command_seed_next: app.commands.seed, demo: demo.current ? demo.current.key : '',
            title_elapsed: titleElapsed},
        settings: {simulation: app.sim.settings, render: app.settings.v},
        bodies: app.rigid.bodies.map(body => ({
            slot: body.slot, position: Array.from(body.pos), velocity: Array.from(body.vel),
            angle_radians: body.angle, angular_velocity: body.angVel, asleep: body.asleep,
            mass_engine_units: body.mass, inertia_engine_units: body.inertia,
            center_of_mass: Array.from(body.com), shape_width: body.rw, shape_height: body.rh,
            shape_mask: Array.from(body.mask || []), density: Array.from(body.dens || [])
        })),
        statistics: {histogram: Array.from(app.stats.histogram),
            reactions: Array.from(app.stats.reactionCount), ignite: Array.from(app.stats.igniteCount),
            phase_hi: Array.from(app.stats.phaseHi), phase_lo: Array.from(app.stats.phaseLo),
            events: Array.from(app.stats.events), explosions: app.stats.explosions,
            scope: 'raw_gpu_counters_not_episode_deltas; events_may_be_retained_when_no_grid_step'},
        trace: worldObservation.enabled ? worldObservation.trace : null,
        gpu_resources: resources
    });
}

function readWorldObservationCpuField(name) {
    if (name !== 'background_rgba') throw new Error('Unknown CPU observation field: ' + name);
    return app.currentBackground.buffer;
}
