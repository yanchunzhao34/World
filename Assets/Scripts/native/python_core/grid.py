"""Grid simulation stages, fluid integration and fixed binary command packets."""

from _infernux_packages.workshop.runtime.library.dependencies import SimpleNamespace

from .commands import BrushCommands, SimulationStatistics
from .gpu import Bindings, ComputeShader, DoubleBuffer, Parameters


class SimulationGrid:
    OFFSETS = ((0, 0), (1, 1), (1, 0), (0, 1))

    def __init__(self, gpu, width, height, data, defaults):
        if width % 32 or height % 32:
            raise ValueError('World size must be a multiple of 32')
        self.gpu, self.width, self.height = gpu, width, height
        self.settings = SimpleNamespace(**defaults)
        self.tick = 0
        self.fireId, self.steamId = data['info']['fireId'], data['info']['steamId']
        self.lightTex = self.daylightTex = None
        self.lightInput, self.debugStop = True, 99
        self.onTick = self.onApply = self.onHash = None
        self.hashEvery = 60
        self.cmdSubmit = -1
        texture = gpu.createTexture

        def pair(w, h, format, label):
            return DoubleBuffer(texture(w, h, format, label+'_a'), texture(w, h, format, label+'_b'))

        self.cells = pair(width, height, 'rgba32uint', 'cells')
        self.fluidVel = pair(self.fluidW, self.fluidH, 'rgba16float', 'vel')
        self.fluidState = [gpu.createStorageBuffer(self.fluidW*self.fluidH*16, None, 'fluid_state_'+str(index)) for index in range(2)]
        self.pressure = pair(self.fluidW, self.fluidH, 'r32float', 'p')
        self.divergence = texture(self.fluidW, self.fluidH, 'r32float', 'div')
        self.medium = pair(self.mediumW, self.mediumH, 'rgba16float', 'medium')
        self.commandsBuf = gpu.createStorageBuffer(BrushCommands.SizeBytes, None, 'commands')
        self.statsBuf = gpu.createStorageBuffer(SimulationStatistics.SizeBytes, None, 'stats')
        self.pendingBuf = gpu.createStorageBuffer(SimulationStatistics.PendingSize, None, 'pending')
        self.exGrid = gpu.createStorageBuffer(width*height*4, None, 'explosion_grid')
        self.exCounts = gpu.createStorageBuffer(((width*height+1023)//1024)*4, None, 'explosion_counts')
        self.mediumSrcBytes = self.mediumW*self.mediumH*16
        self.mediumSrcBuf = gpu.createStorageBuffer(self.mediumSrcBytes, None, 'medium_src')
        self.blackTex = texture(4, 4, 'rgba16float', 'black')
        gpu.clearTexture(self.blackTex)
        for attribute, key in [('materialsBuf','materials'), ('lutBuf','lut'), ('reactionsBuf','reactions')]:
            setattr(self, attribute, gpu.createStorageBuffer(len(data[key]), data[key], key))
        paths = {
            'apply':'sim/apply_commands', 'gather':'sim/explosion_gather', 'explosion':'sim/explosion',
            'move':'sim/margolus_move', 'spread':'sim/liquid_spread', 'react':'sim/reactions',
            'unary':'sim/unary', 'heat':'sim/heat', 'fInject':'fluid/fluid_inject',
            'fAdvect':'fluid/advect', 'fDiv':'fluid/divergence', 'fPressure':'fluid/pressure',
            'fProject':'fluid/project', 'mediumPass':'fluid/medium', 'hashPass':'net/state_hash',
        }
        for name, path in paths.items():
            setattr(self, name, ComputeShader(gpu, path+'.comp'))
        self.hashBuf = gpu.createStorageBuffer((height+self.fluidH)*4, None, 'state_hash')

    @property
    def fluidW(self):
        return self.width//4

    @property
    def fluidH(self):
        return self.height//4

    @property
    def mediumW(self):
        return self.width//2

    @property
    def mediumH(self):
        return self.height//2

    def upload(self, data):
        if len(data) != self.width*self.height*16:
            raise ValueError('Bad world size')
        gpu = self.gpu
        gpu.writeTexture(self.cells.read, data)
        gpu.clearTexture(self.medium.read)
        gpu.clearTexture(self.fluidVel.read)
        gpu.clearBuffer(self.fluidState[0])
        gpu.clearBuffer(self.exGrid)
        gpu.clearTexture(self.pressure.read)
        gpu.writeBuffer(self.pendingBuf, 0, bytes(SimulationStatistics.PendingSize))
        gpu.writeBuffer(self.statsBuf, SimulationStatistics.EventsOffset,
                        bytes(SimulationStatistics.SizeBytes-SimulationStatistics.EventsOffset))
        self.tick = 0

    def P(self, tick=0, substep=0):
        return Parameters(i0x=self.width, i0y=self.height, i0z=tick, i0w=substep)

    def step(self, commands):
        packet = commands.drain() if commands is not None and commands.count else None
        if self.onTick:
            self.onTick(packet)
        self.stepBytes(packet)

    def stepBytes(self, packet):
        gpu, settings = self.gpu, self.settings
        tick = self.tick & 0x7fffffff
        count = int.from_bytes(packet[:4], 'little') if packet else 0
        if count:
            self.writeCommands(packet)
        bindings = Bindings().buffer(0, self.exGrid).buffer(1, self.pendingBuf).buffer(2, self.exCounts)
        items = (self.width*self.height+3)//4
        for phase in (0, 1):
            self.gather.dispatch(bindings, Parameters(i0x=self.width, i0y=self.height, i0z=phase), items, 1)
        gpu.clearBuffer(self.statsBuf, SimulationStatistics.HistOffset, 1024)
        gpu.clearBuffer(self.statsBuf, SimulationStatistics.EventsOffset,
                        SimulationStatistics.SizeBytes-SimulationStatistics.EventsOffset)
        gpu.clearBuffer(self.mediumSrcBuf)
        if self.debugStop < 1:
            self.tick += 1
            return
        if count:
            self.apply.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write)
                .buffer(2, self.materialsBuf).buffer(3, self.commandsBuf).buffer(4, self.statsBuf).buffer(5, self.exGrid),
                self.P(tick).set('i1x', count), self.width, self.height)
            self.cells.swap()
        if self.debugStop < 2:
            self.tick += 1
            return
        self.explosion.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write)
            .buffer(2, self.materialsBuf).buffer(3, self.pendingBuf).buffer(4, self.mediumSrcBuf),
            self.P(tick).set('i1y', self.fireId), self.width, self.height)
        self.cells.swap()
        if self.debugStop < 3:
            self.tick += 1
            return
        block_width, block_height = self.width//2+1, self.height//2+1
        for substep in range(settings.substeps):
            offset = self.OFFSETS[(substep+tick)&3]
            parameters = self.P(tick, substep).set('i1x', offset[0]).set('i1y', offset[1]).set('f0x', settings.windCoupling)
            self.move.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write)
                .buffer(2, self.materialsBuf).buffer(3, self.fluidState[0]), parameters, block_width, block_height)
            self.cells.swap()
        if self.debugStop < 4:
            self.tick += 1
            return
        if settings.liquidSpread > 0:
            items = (self.width//64+1)*self.height*64
            for phase in (0, 1):
                parameters = self.P(tick).set('i1x', -1 if (tick+phase)&1 else 1)
                parameters.set('i1y', 0 if phase == 0 else 32).set('i1z', settings.liquidSpread)
                self.spread.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write)
                    .buffer(2, self.materialsBuf), parameters, items, 1)
                self.cells.swap()
        if self.debugStop < 5:
            self.tick += 1
            return
        for phase in (0, 1):
            offset = self.OFFSETS[(phase*2+tick)&3]
            parameters = self.P(tick).set('i1x', offset[0]).set('i1y', offset[1]).set('i1z', self.fireId).set('i1w', self.steamId)
            self.react.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write)
                .buffer(2, self.materialsBuf).buffer(3, self.lutBuf).buffer(4, self.reactionsBuf)
                .buffer(5, self.statsBuf).buffer(6, self.mediumSrcBuf).buffer(7, self.exGrid), parameters, block_width, block_height)
            self.cells.swap()
        if self.debugStop < 6:
            self.tick += 1
            return
        self.unary.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write)
            .buffer(2, self.materialsBuf).buffer(3, self.statsBuf).buffer(4, self.mediumSrcBuf).buffer(7, self.exGrid)
            .sampler(5, gpu.linearClamp, self.lightTex if self.lightInput and self.lightTex else self.blackTex)
            .sampler(6, gpu.linearClamp, self.daylightTex if self.lightInput and self.daylightTex else self.blackTex),
            self.P(tick), self.width, self.height)
        self.cells.swap()
        if self.debugStop < 7:
            self.tick += 1
            return
        for _ in range(settings.heatIterations):
            self.heat.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write).buffer(2, self.materialsBuf),
                self.P(tick).set('f0x', settings.gasRelax).set('f0y', settings.ambient), self.width, self.height)
            self.cells.swap()
        if self.debugStop < 8:
            self.tick += 1
            return
        self.stepFluid()
        self.tick += 1
        if self.onHash and self.tick % self.hashEvery == 0:
            self.onHash(self.tick, self.encodeHash())

    def writeCommands(self, packet):
        if self.cmdSubmit == self.gpu.submits:
            self.gpu.submit()
            self.gpu.begin()
        self.gpu.writeBuffer(self.commandsBuf, 0, packet)
        self.cmdSubmit = self.gpu.submits

    def applyCommandsOnly(self, commands):
        packet = commands.drain()
        if int.from_bytes(packet[:4], 'little') == 0:
            return
        if self.onApply:
            self.onApply(packet)
        self.applyBytes(packet)

    def applyBytes(self, packet):
        count = int.from_bytes(packet[:4], 'little')
        if not count:
            return
        self.writeCommands(packet)
        self.apply.dispatch(Bindings().image(0, self.cells.read).image(1, self.cells.write)
            .buffer(2, self.materialsBuf).buffer(3, self.commandsBuf).buffer(4, self.statsBuf).buffer(5, self.exGrid),
            self.P(self.tick & 0x7fffffff).set('i1x', count), self.width, self.height)
        self.cells.swap()

    def stepFluid(self):
        gpu, settings = self.gpu, self.settings
        width, height = self.fluidW, self.fluidH
        source, scratch = self.fluidState
        self.fInject.dispatch(Bindings().image(0, self.cells.read).buffer(1, self.materialsBuf)
            .buffer(2, source).buffer(4, self.pendingBuf), Parameters(i0x=width, i0y=height,
                i1x=self.width, i1y=self.height, f0x=settings.buoyancy, f0y=settings.blastImpulse,
                f0z=settings.damping, f0w=settings.ambient), width, height)
        self.fAdvect.dispatch(Bindings().buffer(0, source).buffer(1, scratch),
            Parameters(i0x=width, i0y=height, f0x=settings.fluidDt), width, height)
        parameters = Parameters(i0x=width, i0y=height)
        self.fDiv.dispatch(Bindings().buffer(0, scratch).image(1, self.divergence), parameters, width, height)
        for _ in range(settings.pressureIterations):
            self.fPressure.dispatch(Bindings().image(0, self.pressure.read).image(1, self.pressure.write)
                .image(2, self.divergence).buffer(3, scratch), parameters, width, height)
            self.pressure.swap()
        self.fProject.dispatch(Bindings().buffer(0, scratch).buffer(1, source)
            .image(2, self.pressure.read).image(3, self.fluidVel.write), parameters, width, height)
        self.fluidVel.swap()
        parameters = Parameters(i0x=self.mediumW, i0y=self.mediumH, i1x=self.width, i1y=self.height,
            i1z=self.tick & 65535, f0x=settings.sootKeep, f0y=settings.steamKeep,
            f0z=settings.fluidDt, f0w=settings.mediumSource, f1x=settings.mediumRise,
            f1y=settings.flameKeep, f1z=settings.flameRise)
        self.mediumPass.dispatch(Bindings().sampler(0, gpu.linearClamp, self.medium.read)
            .image(1, self.medium.write).sampler(2, gpu.linearClamp, self.fluidVel.read)
            .buffer(3, self.mediumSrcBuf).image(4, self.cells.read).buffer(5, self.materialsBuf),
            parameters, self.mediumW, self.mediumH)
        self.medium.swap()

    def readStats(self):
        return self.gpu.readBuffer(self.statsBuf, SimulationStatistics.SizeBytes)

    def encodeHash(self):
        self.hashPass.dispatch(Bindings().image(0, self.cells.read).buffer(1, self.materialsBuf)
            .buffer(2, self.fluidState[0]).image(3, self.pressure.read).buffer(4, self.hashBuf),
            Parameters(i0x=self.width, i0y=self.height, i0z=self.fluidW, i0w=self.fluidH), self.height+self.fluidH, 1)
        return self.gpu.readBuffer(self.hashBuf, (self.height+self.fluidH)*4)
