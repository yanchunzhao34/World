"""Grid simulation stages, fluid integration and fixed binary command packets."""

from _infernux_packages.workshop.runtime.library.dependencies import SimpleNamespace

from .commands import BrushCommands, SimulationStatistics
from .gpu import Bindings, ComputeShader, DoubleBuffer, Parameters


class SimulationGrid:
    OFFSETS = ((0, 0), (1, 1), (1, 0), (0, 1))

    # 初始化网格状态与各模拟阶段资源。
    def __init__(self, gpu, width, height, data, defaults):
        # 网格按32格对齐，满足多级降采样与分块计算的尺寸约束
        if width % 32 or height % 32:
            raise ValueError('World size must be a multiple of 32')

        self.gpu, self.width, self.height = gpu, width, height
        self.settings = SimpleNamespace(**defaults)
        self.tick = 0
        self.fireId, self.steamId = data['info']['fireId'], data['info']['steamId']
        self.lightTex = None
        self.daylightTex = None
        self.lightInput, self.debugStop = True, 99
        self.onTick = None
        self.onApply = None
        self.onHash = None
        self.hashEvery = 60
        self.cmdSubmit = -1
        texture = gpu.createTexture

        # 创建用于相邻阶段交换的纹理资源对。
        def pair(w, h, format, label):
            return DoubleBuffer(
                texture(w, h, format, label + '_a'), texture(w, h, format, label + '_b')
            )

        self.cells = pair(width, height, 'rgba32uint', 'cells')
        self.fluidVel = pair(self.fluidW, self.fluidH, 'rgba16float', 'vel')
        self.fluidState = [
            gpu.createStorageBuffer(
                self.fluidW * self.fluidH * 16, None, 'fluid_state_' + str(index)
            )
            for index in range(2)
        ]
        self.pressure = pair(self.fluidW, self.fluidH, 'r32float', 'p')
        self.divergence = texture(self.fluidW, self.fluidH, 'r32float', 'div')
        self.medium = pair(self.mediumW, self.mediumH, 'rgba16float', 'medium')
        self.commandsBuf = gpu.createStorageBuffer(
            BrushCommands.SizeBytes, None, 'commands'
        )
        self.statsBuf = gpu.createStorageBuffer(
            SimulationStatistics.SizeBytes, None, 'stats'
        )
        self.pendingBuf = gpu.createStorageBuffer(
            SimulationStatistics.PendingSize, None, 'pending'
        )
        self.exGrid = gpu.createStorageBuffer(
            width * height * 4, None, 'explosion_grid'
        )
        self.exCounts = gpu.createStorageBuffer(
            ((width * height + 1023) // 1024) * 4, None, 'explosion_counts'
        )
        self.mediumSrcBytes = self.mediumW * self.mediumH * 16
        self.mediumSrcBuf = gpu.createStorageBuffer(
            self.mediumSrcBytes, None, 'medium_src'
        )
        self.blackTex = texture(4, 4, 'rgba16float', 'black')

        gpu.clearTexture(self.blackTex)

        for attribute, key in [
            ('materialsBuf', 'materials'),
            ('lutBuf', 'lut'),
            ('reactionsBuf', 'reactions'),
        ]:
            setattr(
                self, attribute, gpu.createStorageBuffer(len(data[key]), data[key], key)
            )

        paths = {
            'apply': 'sim/apply_commands',
            'gather': 'sim/explosion_gather',
            'explosion': 'sim/explosion',
            'move': 'sim/margolus_move',
            'spread': 'sim/liquid_spread',
            'react': 'sim/reactions',
            'unary': 'sim/unary',
            'heat': 'sim/heat',
            'fInject': 'fluid/fluid_inject',
            'fAdvect': 'fluid/advect',
            'fDiv': 'fluid/divergence',
            'fPressure': 'fluid/pressure',
            'fProject': 'fluid/project',
            'mediumPass': 'fluid/medium',
            'hashPass': 'net/state_hash',
        }

        for name, path in paths.items():
            setattr(self, name, ComputeShader(gpu, path + '.comp'))

        self.hashBuf = gpu.createStorageBuffer(
            (height + self.fluidH) * 4, None, 'state_hash'
        )

    # 取得流体场的降采样宽度。
    @property
    def fluidW(self):
        return self.width // 4

    # 取得流体场的降采样高度。
    @property
    def fluidH(self):
        return self.height // 4

    # 取得介质场的降采样宽度。
    @property
    def mediumW(self):
        return self.width // 2

    # 取得介质场的降采样高度。
    @property
    def mediumH(self):
        return self.height // 2

    # 载入格子数据并重置派生模拟状态。
    def upload(self, data):
        if len(data) != self.width * self.height * 16:
            raise ValueError('Bad world size')

        gpu = self.gpu

        gpu.writeTexture(self.cells.read, data)

        # 切图时清除派生场，避免新材料继承旧世界的流体与事件
        gpu.clearTexture(self.medium.read)
        gpu.clearTexture(self.fluidVel.read)
        gpu.clearBuffer(self.fluidState[0])
        gpu.clearBuffer(self.exGrid)
        gpu.clearTexture(self.pressure.read)
        gpu.writeBuffer(self.pendingBuf, 0, bytes(SimulationStatistics.PendingSize))
        gpu.writeBuffer(
            self.statsBuf,
            SimulationStatistics.EventsOffset,
            bytes(SimulationStatistics.SizeBytes - SimulationStatistics.EventsOffset),
        )

        self.tick = 0

    # 创建包含世界尺寸与步号的计算参数。
    def P(self, tick=0, substep=0):
        return Parameters(
            i0x=self.width,
            i0y=self.height,
            i0z=tick,
            i0w=substep,
        )

    # 接纳画笔命令并推进一个网格步。
    def step(self, commands):
        packet = commands.drain() if commands is not None and commands.count else None

        if self.onTick:
            self.onTick(packet)

        self.stepBytes(packet)

    # 按既有顺序调度网格模拟各阶段。
    def stepBytes(self, packet):
        gpu, settings = self.gpu, self.settings
        tick = self.tick & 0x7FFFFFFF
        count = int.from_bytes(packet[:4], 'little') if packet else 0

        if count:
            self.writeCommands(packet)

        bindings = Bindings()

        bindings.buffer(0, self.exGrid)
        bindings.buffer(1, self.pendingBuf)
        bindings.buffer(2, self.exCounts)

        items = (self.width * self.height + 3) // 4

        # 先归并爆炸请求，保证后续阶段使用完整的本步事件集合
        for phase in (0, 1):
            self.gather.dispatch(
                bindings,
                Parameters(
                    i0x=self.width,
                    i0y=self.height,
                    i0z=phase,
                ),
                items,
                1,
            )

        gpu.clearBuffer(self.statsBuf, SimulationStatistics.HistOffset, 1024)
        gpu.clearBuffer(
            self.statsBuf,
            SimulationStatistics.EventsOffset,
            SimulationStatistics.SizeBytes - SimulationStatistics.EventsOffset,
        )
        gpu.clearBuffer(self.mediumSrcBuf)

        if self.debugStop < 1:
            self.tick += 1

            return

        if count:
            apply_bindings = Bindings()

            apply_bindings.image(0, self.cells.read)
            apply_bindings.image(1, self.cells.write)
            apply_bindings.buffer(2, self.materialsBuf)
            apply_bindings.buffer(3, self.commandsBuf)
            apply_bindings.buffer(4, self.statsBuf)
            apply_bindings.buffer(5, self.exGrid)

            apply_parameters = self.P(tick)

            apply_parameters.set('i1x', count)
            self.apply.dispatch(
                apply_bindings, apply_parameters, self.width, self.height
            )
            self.cells.swap()

        if self.debugStop < 2:
            self.tick += 1

            return

        explosion_bindings = Bindings()

        explosion_bindings.image(0, self.cells.read)
        explosion_bindings.image(1, self.cells.write)
        explosion_bindings.buffer(2, self.materialsBuf)
        explosion_bindings.buffer(3, self.pendingBuf)
        explosion_bindings.buffer(4, self.mediumSrcBuf)

        explosion_parameters = self.P(tick)

        explosion_parameters.set('i1y', self.fireId)
        self.explosion.dispatch(
            explosion_bindings, explosion_parameters, self.width, self.height
        )
        self.cells.swap()

        if self.debugStop < 3:
            self.tick += 1

            return

        block_width, block_height = self.width // 2 + 1, self.height // 2 + 1

        for substep in range(settings.substeps):
            # 交替移动分块起点，减轻固定网格边界造成的方向偏差
            offset = self.OFFSETS[(substep + tick) & 3]
            parameters = self.P(tick, substep)

            parameters.set('i1x', offset[0])
            parameters.set('i1y', offset[1])
            parameters.set('f0x', settings.windCoupling)

            move_bindings = Bindings()

            move_bindings.image(0, self.cells.read)
            move_bindings.image(1, self.cells.write)
            move_bindings.buffer(2, self.materialsBuf)
            move_bindings.buffer(3, self.fluidState[0])
            self.move.dispatch(move_bindings, parameters, block_width, block_height)
            self.cells.swap()

        if self.debugStop < 4:
            self.tick += 1

            return

        if settings.liquidSpread > 0:
            items = (self.width // 64 + 1) * self.height * 64

            for phase in (0, 1):
                parameters = self.P(tick)

                parameters.set('i1x', -1 if (tick + phase) & 1 else 1)
                parameters.set('i1y', 0 if phase == 0 else 32).set(
                    'i1z', settings.liquidSpread
                )

                spread_bindings = Bindings()

                spread_bindings.image(0, self.cells.read)
                spread_bindings.image(1, self.cells.write)
                spread_bindings.buffer(2, self.materialsBuf)
                self.spread.dispatch(spread_bindings, parameters, items, 1)
                self.cells.swap()

        if self.debugStop < 5:
            self.tick += 1

            return

        for phase in (0, 1):
            offset = self.OFFSETS[(phase * 2 + tick) & 3]
            parameters = self.P(tick)

            parameters.set('i1x', offset[0])
            parameters.set('i1y', offset[1])
            parameters.set('i1z', self.fireId)
            parameters.set('i1w', self.steamId)

            react_bindings = Bindings()

            react_bindings.image(0, self.cells.read)
            react_bindings.image(1, self.cells.write)
            react_bindings.buffer(2, self.materialsBuf)
            react_bindings.buffer(3, self.lutBuf)
            react_bindings.buffer(4, self.reactionsBuf)
            react_bindings.buffer(5, self.statsBuf)
            react_bindings.buffer(6, self.mediumSrcBuf)
            react_bindings.buffer(7, self.exGrid)
            self.react.dispatch(react_bindings, parameters, block_width, block_height)
            self.cells.swap()

        if self.debugStop < 6:
            self.tick += 1

            return

        unary_bindings = Bindings()

        unary_bindings.image(0, self.cells.read)
        unary_bindings.image(1, self.cells.write)
        unary_bindings.buffer(2, self.materialsBuf)
        unary_bindings.buffer(3, self.statsBuf)
        unary_bindings.buffer(4, self.mediumSrcBuf)
        unary_bindings.buffer(7, self.exGrid)
        unary_bindings.sampler(
            5,
            gpu.linearClamp,
            self.lightTex if self.lightInput and self.lightTex else self.blackTex,
        )
        unary_bindings.sampler(
            6,
            gpu.linearClamp,
            self.daylightTex if self.lightInput and self.daylightTex else self.blackTex,
        )
        self.unary.dispatch(unary_bindings, self.P(tick), self.width, self.height)
        self.cells.swap()

        if self.debugStop < 7:
            self.tick += 1

            return

        for _ in range(settings.heatIterations):
            heat_bindings = Bindings()

            heat_bindings.image(0, self.cells.read)
            heat_bindings.image(1, self.cells.write)
            heat_bindings.buffer(2, self.materialsBuf)

            heat_parameters = self.P(tick)

            heat_parameters.set('f0x', settings.gasRelax)
            heat_parameters.set('f0y', settings.ambient)
            self.heat.dispatch(heat_bindings, heat_parameters, self.width, self.height)
            self.cells.swap()

        if self.debugStop < 8:
            self.tick += 1

            return

        self.stepFluid()

        self.tick += 1

        if self.onHash and self.tick % self.hashEvery == 0:
            self.onHash(self.tick, self.encodeHash())

    # 在安全提交边界更新GPU画笔输入。
    def writeCommands(self, packet):
        if self.cmdSubmit == self.gpu.submits:
            # 写入新笔触前先提交，避免覆盖同批命令仍需使用的输入
            self.gpu.submit()
            self.gpu.begin()

        self.gpu.writeBuffer(self.commandsBuf, 0, packet)

        self.cmdSubmit = self.gpu.submits

    # 应用暂停编辑所需的画笔命令。
    def applyCommandsOnly(self, commands):
        # 暂停编辑只改材料场，避免额外推进反应与流体时间
        packet = commands.drain()

        if int.from_bytes(packet[:4], 'little') == 0:
            return

        if self.onApply:
            self.onApply(packet)

        self.applyBytes(packet)

    # 应用已打包命令并交换格子缓冲。
    def applyBytes(self, packet):
        count = int.from_bytes(packet[:4], 'little')

        if not count:
            return

        self.writeCommands(packet)

        apply_bindings_3 = Bindings()

        apply_bindings_3.image(0, self.cells.read)
        apply_bindings_3.image(1, self.cells.write)
        apply_bindings_3.buffer(2, self.materialsBuf)
        apply_bindings_3.buffer(3, self.commandsBuf)
        apply_bindings_3.buffer(4, self.statsBuf)
        apply_bindings_3.buffer(5, self.exGrid)

        apply_parameters_3 = self.P(self.tick & 0x7FFFFFFF)

        apply_parameters_3.set('i1x', count)
        self.apply.dispatch(
            apply_bindings_3, apply_parameters_3, self.width, self.height
        )
        self.cells.swap()

    # 推进流体速度、压力与介质场。
    def stepFluid(self):
        gpu, settings = self.gpu, self.settings
        width, height = self.fluidW, self.fluidH
        source, scratch = self.fluidState
        f_inject_bindings = Bindings()

        f_inject_bindings.image(0, self.cells.read)
        f_inject_bindings.buffer(1, self.materialsBuf)
        f_inject_bindings.buffer(2, source)
        f_inject_bindings.buffer(4, self.pendingBuf)
        self.fInject.dispatch(
            f_inject_bindings,
            Parameters(
                i0x=width,
                i0y=height,
                i1x=self.width,
                i1y=self.height,
                f0x=settings.buoyancy,
                f0y=settings.blastImpulse,
                f0z=settings.damping,
                f0w=settings.ambient,
            ),
            width,
            height,
        )

        f_advect_bindings = Bindings()

        f_advect_bindings.buffer(0, source)
        f_advect_bindings.buffer(1, scratch)
        self.fAdvect.dispatch(
            f_advect_bindings,
            Parameters(
                i0x=width,
                i0y=height,
                f0x=settings.fluidDt,
            ),
            width,
            height,
        )

        parameters = Parameters(i0x=width, i0y=height)
        f_div_bindings = Bindings()

        f_div_bindings.buffer(0, scratch)
        f_div_bindings.image(1, self.divergence)
        self.fDiv.dispatch(f_div_bindings, parameters, width, height)

        # 压力迭代约束速度散度，减轻流体凭空膨胀或收缩
        for _ in range(settings.pressureIterations):
            f_pressure_bindings = Bindings()

            f_pressure_bindings.image(0, self.pressure.read)
            f_pressure_bindings.image(1, self.pressure.write)
            f_pressure_bindings.image(2, self.divergence)
            f_pressure_bindings.buffer(3, scratch)
            self.fPressure.dispatch(f_pressure_bindings, parameters, width, height)
            self.pressure.swap()

        f_project_bindings = Bindings()

        f_project_bindings.buffer(0, scratch)
        f_project_bindings.buffer(1, source)
        f_project_bindings.image(2, self.pressure.read)
        f_project_bindings.image(3, self.fluidVel.write)
        self.fProject.dispatch(f_project_bindings, parameters, width, height)
        self.fluidVel.swap()

        parameters = Parameters(
            i0x=self.mediumW,
            i0y=self.mediumH,
            i1x=self.width,
            i1y=self.height,
            i1z=self.tick & 65535,
            f0x=settings.sootKeep,
            f0y=settings.steamKeep,
            f0z=settings.fluidDt,
            f0w=settings.mediumSource,
            f1x=settings.mediumRise,
            f1y=settings.flameKeep,
            f1z=settings.flameRise,
        )
        medium_pass_bindings = Bindings()

        medium_pass_bindings.sampler(0, gpu.linearClamp, self.medium.read)
        medium_pass_bindings.image(1, self.medium.write)
        medium_pass_bindings.sampler(2, gpu.linearClamp, self.fluidVel.read)
        medium_pass_bindings.buffer(3, self.mediumSrcBuf)
        medium_pass_bindings.image(4, self.cells.read)
        medium_pass_bindings.buffer(5, self.materialsBuf)
        self.mediumPass.dispatch(
            medium_pass_bindings, parameters, self.mediumW, self.mediumH
        )
        self.medium.swap()

    # 取得本次模拟的原始统计缓冲。
    def readStats(self):
        return self.gpu.readBuffer(self.statsBuf, SimulationStatistics.SizeBytes)

    # 计算网格与流体状态的校验结果。
    def encodeHash(self):
        hash_pass_bindings = Bindings()

        hash_pass_bindings.image(0, self.cells.read)
        hash_pass_bindings.buffer(1, self.materialsBuf)
        hash_pass_bindings.buffer(2, self.fluidState[0])
        hash_pass_bindings.image(3, self.pressure.read)
        hash_pass_bindings.buffer(4, self.hashBuf)
        self.hashPass.dispatch(
            hash_pass_bindings,
            Parameters(
                i0x=self.width,
                i0y=self.height,
                i0z=self.fluidW,
                i0w=self.fluidH,
            ),
            self.height + self.fluidH,
            1,
        )

        return self.gpu.readBuffer(self.hashBuf, (self.height + self.fluidH) * 4)
