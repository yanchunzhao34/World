"""Exchange body atlas ownership and occupancy with the original GPU shaders."""

import numpy as np
from _infernux_packages.workshop.runtime.library.dependencies import SimpleNamespace

from .gpu import Bindings, ComputeShader, Parameters


class RigidBodyGpuBridge:
    ATLAS_CELLS = 262144
    OWNER_WORDS = ATLAS_CELLS // 32
    MAX_UPDATES = 65536

    # 初始化刚体与格子世界的GPU交换资源。
    def __init__(self, gpu, width, height):
        self.gpu, self.w, self.h = gpu, width, height

        # 无主标记使用全1位，避免与合法刚体编号混淆
        self.deadOwners = bytes([255]) * (self.ATLAS_CELLS * 4)
        self.atlasBuf = gpu.createStorageBuffer(
            self.ATLAS_CELLS * 16, None, 'body_atlas'
        )
        self.owner = gpu.createStorageBuffer(
            self.ATLAS_CELLS * 4, self.deadOwners, 'body_owner'
        )
        self.alive = gpu.createStorageBuffer(self.OWNER_WORDS * 4, None, 'body_alive')
        self.stamped = [
            gpu.createStorageBuffer(
                self.OWNER_WORDS * 4, None, 'body_stamped_' + str(index)
            )
            for index in range(2)
        ]
        self.bodies = gpu.createStorageBuffer(1024 * 64, None, 'bodies')
        self.displaced = gpu.createStorageBuffer(262160, None, 'body_displaced')
        self.occ = gpu.createStorageBuffer(width * height // 4, None, 'body_occ')
        self.updates = gpu.createStorageBuffer(
            self.MAX_UPDATES * 8, None, 'body_owner_updates'
        )
        self.claims = gpu.createStorageBuffer(
            self.MAX_UPDATES * 16, None, 'body_claims'
        )
        self.pick = gpu.createStorageBuffer(self.ATLAS_CELLS * 4, None, 'body_pick')

        for name, path in [
            ('erase', 'body_erase'),
            ('dead', 'body_dead'),
            ('ownerPass', 'body_owner'),
            ('claimPass', 'body_claim'),
            ('stamp', 'body_stamp'),
            ('displace', 'body_displace'),
            ('occPass', 'body_occ'),
        ]:
            setattr(self, name, ComputeShader(gpu, 'bodies/' + path + '.comp'))

        self.parity, self.lastSubmit, self.atlasUsed = 0, -1, 0
        self.occPending = False
        self.ownerPending = False

    # 清除上一世界遗留的GPU刚体归属。
    def reset(self):
        # 清除旧世界的归属与盖章记录，避免切图后残留刚体
        self.gpu.writeBuffer(self.owner, 0, self.deadOwners)

        for texture in self.stamped:
            self.gpu.clearBuffer(texture)

        self.atlasUsed = 0

    # 在网格模拟前应用刚体交换包。
    def preStep(self, grid, packet):
        if packet is None:
            return

        gpu = self.gpu

        if self.lastSubmit == gpu.submits:
            # 同批更新前先提交，避免后续写入覆盖在途刚体数据
            gpu.submit()
            gpu.begin()

        self.lastSubmit = gpu.submits

        if packet.reset:
            self.reset()

        for region in packet.newRegions:
            gpu.writeBuffer(self.atlasBuf, region.offset * 16, region.cells)
            gpu.writeBuffer(self.owner, region.offset * 4, region.owners)

        self.atlasUsed = packet.atlasUsed

        if self.atlasUsed == 0 and not packet.claims:
            return

        parameters = Parameters(i0x=self.w, i0y=self.h)

        if packet.claims:
            count = min(len(packet.claims) // 4, self.MAX_UPDATES)

            gpu.writeBuffer(
                self.claims, 0, np.asarray(packet.claims[: count * 4], '<u4')
            )

            claim_pass_bindings = Bindings()

            claim_pass_bindings.image(0, grid.cells.read)
            claim_pass_bindings.buffer(1, self.claims)

            claim_pass_parameters = parameters.clone()

            claim_pass_parameters.set('i1x', count)
            self.claimPass.dispatch(
                claim_pass_bindings, claim_pass_parameters, count, 1
            )

        if packet.ownerUpdates:
            count = min(len(packet.ownerUpdates) // 2, self.MAX_UPDATES)

            gpu.writeBuffer(
                self.updates, 0, np.asarray(packet.ownerUpdates[: count * 2], '<u4')
            )

            owner_pass_bindings = Bindings()

            owner_pass_bindings.buffer(0, self.owner)
            owner_pass_bindings.buffer(1, self.updates)
            self.ownerPass.dispatch(
                owner_pass_bindings, Parameters(i0x=count), count, 1
            )

        if not packet.step:
            return

        words = (self.atlasUsed + 31) // 32

        gpu.clearBuffer(self.alive, 0, max(words, 1) * 4)
        gpu.clearBuffer(self.pick, 0, max(self.atlasUsed, 1) * 4)
        parameters.set('i0z', self.atlasUsed)

        # 组装刚体旧位置擦除所需的资源绑定。
        def erase_bindings():
            stage_bindings = Bindings()

            stage_bindings.image(0, grid.cells.read)
            stage_bindings.image(1, grid.cells.write)
            stage_bindings.buffer(2, grid.materialsBuf)
            stage_bindings.buffer(3, self.atlasBuf)
            stage_bindings.buffer(4, self.owner)
            stage_bindings.buffer(5, self.alive)
            stage_bindings.buffer(6, self.pick)

            return stage_bindings

        # 先擦除旧位置再盖章，避免刚体移动时残留材料副本
        for phase in (0, 1):
            erase_parameters = parameters.clone()

            erase_parameters.set('i0w', phase)
            self.erase.dispatch(erase_bindings(), erase_parameters, self.w, self.h)

        grid.cells.swap()

        # 双份盖章记录区分前后帧，便于清理已消失的刚体格子
        previous, current = self.stamped[self.parity ^ 1], self.stamped[self.parity]
        dead_bindings = Bindings()

        dead_bindings.buffer(0, self.owner)
        dead_bindings.buffer(1, self.alive)
        dead_bindings.buffer(2, previous)
        self.dead.dispatch(dead_bindings, Parameters(i0x=words), words, 1)
        gpu.clearBuffer(current, 0, max(words, 1) * 4)
        gpu.clearBuffer(self.displaced, 0, 16)

        if packet.count > 0:
            gpu.writeBuffer(self.bodies, 0, packet.bodies, 0, packet.count * 64)
            parameters.set('i0z', packet.count)

            stamp_bindings = Bindings()

            stamp_bindings.image(0, grid.cells.read)
            stamp_bindings.image(1, grid.cells.write)
            stamp_bindings.buffer(2, grid.materialsBuf)
            stamp_bindings.buffer(3, self.atlasBuf)
            stamp_bindings.buffer(4, self.owner)
            stamp_bindings.buffer(5, current)
            stamp_bindings.buffer(6, self.bodies)
            stamp_bindings.buffer(7, self.displaced)
            self.stamp.dispatch(stamp_bindings, parameters, self.w, self.h)
            grid.cells.swap()

            displace_bindings = Bindings()

            displace_bindings.image(0, grid.cells.read)
            displace_bindings.buffer(1, grid.materialsBuf)
            displace_bindings.buffer(2, self.displaced)
            displace_bindings.image(4, grid.cells.write)
            self.displace.dispatch(
                displace_bindings, Parameters(i0x=self.w, i0y=self.h), 256, 1
            )

        self.parity ^= 1

    # 取得刚体图集与盖章资源的当前描述。
    @property
    def state(self):
        return SimpleNamespace(
            atlasUsed=self.atlasUsed,
            parity=self.parity,
            words=max((self.atlasUsed + 31) // 32, 1),
            atlas=self.atlasBuf,
            owner=self.owner,
            stamped=self.stamped[self.parity ^ 1],
        )

    # 恢复刚体GPU图集与归属资源。
    def restore(self, used, parity, atlas, owners, stamped):
        self.gpu.writeBuffer(self.owner, 0, self.deadOwners)

        for buffer in self.stamped:
            self.gpu.writeBuffer(buffer, 0, bytes(self.OWNER_WORDS * 4))

        self.atlasUsed, self.parity = used, parity

        for buffer, data in [
            (self.atlasBuf, atlas),
            (self.owner, owners),
            (self.stamped[parity ^ 1], stamped),
        ]:
            if len(data):
                self.gpu.writeBuffer(buffer, 0, data)

    # 安排网格占用及刚体归属的帧末读回。
    def postStep(self, grid, frame, occupancy_callback, owners_callback):
        # 每类读回仅保留一个在途请求，避免重复读取占满队列
        if not self.occPending:
            occ_pass_bindings = Bindings()

            occ_pass_bindings.image(0, grid.cells.read)
            occ_pass_bindings.buffer(1, grid.materialsBuf)
            occ_pass_bindings.buffer(2, self.occ)
            self.occPass.dispatch(
                occ_pass_bindings,
                Parameters(i0x=self.w, i0y=self.h),
                self.w * self.h // 16,
                1,
            )

            self.occPending = True

            # 交付当前提交边界的世界占用结果。
            def read_occupancy():
                occupancy_data = self.gpu.readBuffer(self.occ, self.w * self.h // 4)
                self.occPending = False

                occupancy_callback(occupancy_data)

            self.gpu.jobs.append(read_occupancy)

        if not self.ownerPending and self.atlasUsed > 0:
            self.ownerPending = True
            owner_byte_count = self.atlasUsed * 4

            # 交付当前提交边界的刚体归属结果。
            def read_owners():
                owner_data = self.gpu.readBuffer(self.owner, owner_byte_count)
                self.ownerPending = False

                owners_callback(owner_data, frame)

            self.gpu.jobs.append(read_owners)
