"""Brush command and statistics binary layouts shared with the unchanged shaders."""

from _infernux_packages.workshop.runtime.library.dependencies import struct

import numpy as np


class BrushCommands:
    Max = 64
    Stride = 64
    SizeBytes = 16 + Max * Stride

    def __init__(self):
        self.pending = []
        self.seed = 1

    @property
    def count(self):
        return len(self.pending)

    def add(self, command):
        # 队列容量与GPU命令区一致，防止输入写穿固定布局
        if len(self.pending) < self.Max:
            self.pending.append(command)

    def drain(self):
        result = bytearray(self.SizeBytes)
        struct.pack_into('<I', result, 0, self.count)
        for index, command in enumerate(self.pending):
            offset = 16 + index * self.Stride
            struct.pack_into('<4i', result, offset, command['type'], command.get('material', 0),
                             command.get('shape', 0), int(bool(command.get('overwrite', False))))
            spray = command.get('spray', 1)
            # 连续种子区分同帧笔触，避免随机喷洒重复相同图案
            struct.pack_into('<7fI', result, offset + 16, *command['from'], *command['to'],
                             command['radius'], command.get('strength', 0),
                             spray if spray > 0 else 1, self.seed & 0xffffffff)
            self.seed += 1
            if 'clip' in command:
                struct.pack_into('<4f', result, offset + 48, *command['clip'])
        count = self.count
        self.pending.clear()
        return bytes(result[:16 + count * self.Stride])


class SimulationStatistics:
    HistOffset = 0
    ReactionOffset = 1024
    IgniteOffset = 5120
    PhaseHiOffset = 6144
    PhaseLoOffset = 7168
    EventsOffset = 8192
    ExCountOffset = 8256
    ExplosionsOffset = 8272
    MaxExplosions = 64
    SizeBytes = ExplosionsOffset + MaxExplosions * 16
    PendingSize = 16 + MaxExplosions * 16

    def __init__(self):
        self.histogram = np.zeros(256, '<u4')
        self.reactionCount = np.zeros(1024, '<u4')
        self.igniteCount = np.zeros(256, '<u4')
        self.phaseHi = np.zeros(256, '<u4')
        self.phaseLo = np.zeros(256, '<u4')
        self.events = np.zeros(16, '<u4')
        self.explosions = []

    def parse(self, data):
        if len(data) < self.SizeBytes:
            return
        # 拷贝读回视图，避免统计状态随后续缓冲复用而变化
        for name, offset, count in [('histogram', 0, 256), ('reactionCount', 1024, 1024),
                                   ('igniteCount', 5120, 256), ('phaseHi', 6144, 256),
                                   ('phaseLo', 7168, 256), ('events', 8192, 16)]:
            setattr(self, name, np.frombuffer(data, '<u4', count, offset).copy())
        count = min(struct.unpack_from('<I', data, self.ExCountOffset)[0], self.MaxExplosions)
        self.explosions = [list(struct.unpack_from('<4f', data, self.ExplosionsOffset + index * 16))
                           for index in range(count)]
