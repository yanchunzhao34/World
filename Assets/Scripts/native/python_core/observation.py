"""Read-only world-observation v1 metadata and bounded action traces."""

from _infernux_packages.workshop.runtime.library.dependencies import copy

from .commands import SimulationStatistics


class WorldObservation:
    def __init__(self):
        self.enabled = False
        self.frameSequence = self.worldEpoch = self.actionSequence = 0
        self.pendingActions, self.pendingResets = [], []
        self.droppedActions = self.droppedResets = 0
        self.trace = None

    def setEnabled(self, enabled):
        self.enabled = bool(enabled)
        if not self.enabled:
            self.trace = None

    def recordReset(self, reason, map_key):
        self.worldEpoch += 1
        if self.enabled:
            if len(self.pendingResets) < 256:
                self.pendingResets.append(dict(world_epoch=self.worldEpoch, reason=reason, map=map_key))
            else:
                self.droppedResets += 1

    def recordAction(self, action, epoch_before, tick, handled=True):
        if not self.enabled:
            return
        self.actionSequence += 1
        item = dict(sequence=self.actionSequence, epoch_before=epoch_before, epoch_after=self.worldEpoch,
            tick_at_acceptance=tick, status='handled_by_action_dispatch' if handled else 'ignored_unknown_type',
            input=copy.deepcopy(action))
        if len(self.pendingActions) < 256:
            self.pendingActions.append(item)
        else:
            self.droppedActions += 1

    def beginFrame(self, app, delta, forced_ticks):
        self.frameSequence += 1
        if not self.enabled:
            return
        self.trace = dict(frame_sequence=self.frameSequence, world_epoch_start=self.worldEpoch,
            tick_start=app.sim.tick, frame_delta_seconds=delta, forced_ticks=forced_ticks,
            actions=self.pendingActions, actions_omitted=self.droppedActions,
            resets=self.pendingResets, resets_omitted=self.droppedResets,
            grid_boundaries=[], grid_boundaries_omitted=0, events=[], coverage=dict(
                actions='accepted_during_this_observed_frame_only',
                commands='actual_admitted_queue_including_demo_and_title_commands',
                reactions='aggregate_counters_only_no_per_reaction_positions',
                explosions='last_grid_step_gpu_statistics_not_all_steps'))
        self.pendingActions, self.pendingResets = [], []
        self.droppedActions = self.droppedResets = 0

    def beginGridBoundary(self, app, commands, kind, ordinal):
        if not self.enabled:
            return None
        if len(self.trace['grid_boundaries']) >= 256:
            self.trace['grid_boundaries_omitted'] += 1
            return None
        return dict(ordinal=ordinal, kind=kind, world_epoch=self.worldEpoch, tick_before=app.sim.tick,
            duration_seconds=1/60 if kind == 'grid_step' else 0,
            command_seed_start=commands.seed if commands else None,
            commands=copy.deepcopy(commands.pending) if commands else [])

    def endGridBoundary(self, boundary, app):
        if boundary is not None:
            boundary['tick_after'] = app.sim.tick
            self.trace['grid_boundaries'].append(boundary)

    def recordExplosions(self, explosions):
        if self.enabled:
            self.trace['events'].extend(dict(kind='explosion', source='gpu_stats', values=list(value)) for value in explosions)

    def endFrame(self, app):
        if not self.enabled:
            return
        self.trace.update(tick_end=app.sim.tick, world_epoch_end=self.worldEpoch)
        remaining = 256-len(self.trace['resets'])
        self.trace['resets'].extend(self.pendingResets[:remaining])
        self.trace['resets_omitted'] += self.droppedResets+max(0, len(self.pendingResets)-remaining)
        self.pendingResets, self.droppedResets = [], 0

    def describe(self, simulation):
        app, resources = simulation.app, []

        def texture(name, value, dtype, channels, unit):
            if value is not None:
                resources.append(dict(name=name, kind='texture', id=value.id, dtype=dtype,
                    shape=[value.height, value.width, channels], unit=unit, encoding=value.format))

        def buffer(name, value, dtype, shape, unit):
            resources.append(dict(name=name, kind='buffer', id=value.id, dtype=dtype,
                                 shape=shape, unit=unit, encoding='little_endian'))

        texture('cells_packed', app.sim.cells.read, 'uint32', 4, 'packed_cell_v1')
        texture('fluid_velocity', app.sim.fluidVel.read, 'float16', 4, 'engine_units')
        texture('fluid_pressure', app.sim.pressure.read, 'float32', 1, 'engine_units')
        texture('fluid_divergence', app.sim.divergence, 'float32', 1, 'engine_units')
        texture('medium', app.sim.medium.read, 'float16', 4, 'engine_units')
        texture('simulation_light_input', app.sim.lightTex, 'float16', 4, 'engine_units')
        texture('simulation_daylight_input', app.sim.daylightTex, 'float16', 4, 'engine_units')
        texture('render_fluence', app.render.fluenceTex, 'float16', 4, 'engine_units')
        texture('render_daylight', app.render.daylightTex, 'float16', 4, 'engine_units')
        for index, value in enumerate(app.sim.fluidState):
            buffer('fluid_state_'+str(index), value, 'int32', [app.sim.fluidH, app.sim.fluidW, 4], 'engine_fixed_point')
        buffer('statistics_packed', app.sim.statsBuf, 'uint32', [SimulationStatistics.SizeBytes//4], 'mixed_stats_v1')
        resources.append(dict(name='background_rgba', kind='cpu', dtype='uint8', shape=[app.H, app.W, 4],
                              unit='unorm_0_255', encoding='rgba8'))
        bodies = [dict(slot=body.slot, position=body.pos, velocity=body.vel, angle_radians=body.angle,
            angular_velocity=body.angVel, asleep=body.asleep, mass_engine_units=body.mass,
            inertia_engine_units=body.inertia, center_of_mass=body.com, shape_width=body.rw,
            shape_height=body.rh, shape_mask=body.mask.tolist(), density=body.dens.tolist()) for body in app.rigid.bodies]
        stats = app.stats
        return dict(schema='element-workshop.world-observation', schema_version=1,
            boundary=dict(kind='frame_end', frame_sequence=self.frameSequence, world_epoch=self.worldEpoch,
                scene_revision=simulation.sceneRevision, tick=app.sim.tick, render_frame=app.render.frame,
                grid_time_seconds=app.sim.tick/60, frame_time_seconds=app.time,
                ordering='after_native_frame_return_before_next_frame'),
            completeness=dict(kind='observation', restorable=False, omitted=['full_gpu_temporal_histories',
                'rigid_gpu_ownership_atlas', 'all_random_generator_states', 'per_reaction_position_events',
                'full_state_at_each_internal_grid_boundary']),
            world=dict(width=app.W, height=app.H, coordinate_order='x_y', array_order='y_x_channel',
                origin='top_left', y_axis='down', length_unit='cell'),
            material_catalog=[dict(id=material.get('id', index), key=material['key'], name=material['zh'],
                state=material['state'], flags=material['flags']) for index, material in enumerate(app.materials)],
            reaction_catalog=[dict(index=index, key=reaction['key'], input_a=reaction['a'], input_b=reaction['b'],
                output_a=reaction['outA'], output_b=reaction['outB']) for index, reaction in enumerate(simulation.info['reactions'])],
            view=dict(camera_center=app.camera.view.center, camera_screen=app.camera.screen,
                      zoom=app.camera.zoom, view_mode=app.render.mode),
            control=dict(map=app.currentMap, paused=app.paused, speed=app.speed, pending_manual_steps=app.steps,
                accumulator=app.accum, day=app.settings.timeOfDay, pending_commands=copy.deepcopy(app.commands.pending),
                command_seed_next=app.commands.seed, demo=simulation.demo.current['key'] if simulation.demo.current else '',
                title_elapsed=simulation.titleElapsed),
            settings=dict(simulation=vars(app.sim.settings), render=app.settings.v), bodies=bodies,
            statistics=dict(histogram=stats.histogram.tolist(), reactions=stats.reactionCount.tolist(),
                ignite=stats.igniteCount.tolist(), phase_hi=stats.phaseHi.tolist(), phase_lo=stats.phaseLo.tolist(),
                events=stats.events.tolist(), explosions=stats.explosions,
                scope='raw_gpu_counters_not_episode_deltas; events_may_be_retained_when_no_grid_step'),
            trace=self.trace if self.enabled else None, gpu_resources=resources)
