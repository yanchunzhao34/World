"""Rigid-body masks, connected components, buoyancy and contact impulses."""

import math

import numpy as np
from _infernux_packages.workshop.runtime.library.dependencies import (
    SimpleNamespace,
    struct,
)

from .settings import clamp, vector_length


class XorShift32:
    # 初始化确定性随机数发生器状态。
    def __init__(self, seed):
        self.state = (seed & 0xFFFFFFFF) or 1

    # 推进确定性随机状态并输出单位区间值。
    def next(self):
        # 限定32位溢出，保持跨语言的随机序列一致
        self.state ^= (self.state << 13) & 0xFFFFFFFF
        self.state ^= self.state >> 17
        self.state ^= (self.state << 5) & 0xFFFFFFFF
        self.state &= 0xFFFFFFFF

        return self.state / 4294967296

    # 生成指定上界内的确定性随机整数。
    def int(self, limit):
        return math.floor(self.next() * limit)


# 计算两个二维向量的点积。
def dot(a, b):
    horizontal_product = a[0] * b[0]
    vertical_product = a[1] * b[1]

    return horizontal_product + vertical_product


# 计算两个二维向量的标量叉积。
def cross(a, b):
    first_diagonal_product = a[0] * b[1]
    second_diagonal_product = a[1] * b[0]

    return first_diagonal_product - second_diagonal_product


class RigidBody:
    # 初始化刚体形状、质量与运动状态。
    def __init__(self):
        self.slot = 0
        self.atlas = 0
        self.rw = 0
        self.rh = 0
        self.count = 0
        self.mask = np.empty(0, 'uint8')
        self.dens = np.empty(0, '<f4')

        self.com = [0, 0]
        self.mass = 0
        self.inertia = 0
        self.invMass = 0
        self.invInertia = 0

        self.pos = [0, 0]
        self.vel = [0, 0]
        self.angle = 0
        self.angVel = 0

        self.asleep = False
        self.stillFrames = 0
        self.sleepCheck = 0
        self.created = -1

        self.edge = []
        self.all = []

    # 将刚体局部向量旋转到当前姿态。
    def rot(self, point):
        cosine, sine = math.cos(self.angle), math.sin(self.angle)

        return [
            cosine * point[0] - sine * point[1],
            sine * point[0] + cosine * point[1],
        ]

    # 按有效材料重算刚体质心与惯性。
    def recompute(self):
        self.count = 0
        weighted_x = 0
        weighted_y = 0
        mass = 0

        for y in range(self.rh):
            for x in range(self.rw):
                local_index = y * self.rw + x

                if self.mask[local_index]:
                    density = float(self.dens[local_index])
                    self.count += 1
                    weighted_x += (x + 0.5) * density
                    weighted_y += (y + 0.5) * density
                    mass += density

        if not self.count:
            return

        previous_com = self.com
        self.com, self.mass = [weighted_x / mass, weighted_y / mass], mass
        moment_of_inertia, local_points, boundary_points = 0, [], []

        for y in range(self.rh):
            for x in range(self.rw):
                local_index = y * self.rw + x

                if not self.mask[local_index]:
                    continue

                local_point = [x + 0.5 - self.com[0], y + 0.5 - self.com[1]]

                # 计入单格自身转动惯量，避免小刚体旋转响应失真
                moment_of_inertia += float(self.dens[local_index]) * (
                    local_point[0] * local_point[0]
                    + local_point[1] * local_point[1]
                    + 1 / 6
                )

                local_points.append(local_point)

                if (
                    x == 0
                    or y == 0
                    or x == self.rw - 1
                    or y == self.rh - 1
                    or not self.mask[local_index - 1]
                    or not self.mask[local_index + 1]
                    or not self.mask[local_index - self.rw]
                    or not self.mask[local_index + self.rw]
                ):
                    boundary_points.append(local_point)

        self.inertia, self.invMass, self.invInertia = (
            moment_of_inertia,
            1 / mass,
            1 / max(moment_of_inertia, 0.001),
        )
        self.all, self.edge = local_points, boundary_points

        if self.created >= 0 and (previous_com[0] != 0 or previous_com[1] != 0):
            # 质心变化时补偿位置，避免形状受损后整体跳动
            shift = self.rot(
                [self.com[0] - previous_com[0], self.com[1] - previous_com[1]]
            )
            self.pos = [self.pos[0] + shift[0], self.pos[1] + shift[1]]


class RigidBodyWorld:
    # 初始化刚体集合及世界碰撞状态。
    def __init__(self, width, height, materials):
        self.w, self.h, self.mats = width, height, materials
        self.gravity, self.restitution, self.friction, self.substeps = 320, 0.15, 0.6, 4

        self.bodies = []
        self.nextSlot, self.atlasUsed, self.frame = 1, 0, 0
        self.resetPending = True
        self.newRegions, self.ownerUpdates, self.claims = [], [], []

        self.occ = np.zeros(width * height, 'uint8')
        self.bodyAt = np.zeros(width * height, '<i4')
        self.bodyCells = []
        self.haveOcc = False
        self.occIn = None
        self.ownersIn = None
        self.cellsIn = None
        self.ownersFrame = 0

        self.rng = XorShift32(7)
        self.contacts = []
        self.wetRows = set()

    # 取得当前刚体图集的已占用格子数。
    @property
    def used(self):
        return self.atlasUsed

    # 重置刚体集合及其待交换状态。
    def clear(self):
        self.bodies.clear()

        self.nextSlot, self.atlasUsed, self.resetPending = 1, 0, True
        self.newRegions, self.ownerUpdates, self.claims = [], [], []
        self.haveOcc = False

        self.bodyAt.fill(0)

        self.bodyCells = []
        self.occIn = None
        self.ownersIn = None
        self.cellsIn = None

    # 接纳下一次物理更新使用的占用数据。
    def onOccupancy(self, data):
        self.occIn = data

    # 接纳带帧边界的刚体归属读回结果。
    def onOwners(self, data, frame):
        self.ownersIn, self.ownersFrame = data, frame

    # 暂存用于建立刚体的世界格子数据。
    def onCells(self, data):
        self.cellsIn = data

    # 取得物理计算使用的归一化材料密度。
    def densityOf(self, identifier):
        if identifier < len(self.mats):
            density = self.mats[identifier].get('density', 1000)

        else:
            density = 1000

        # 密度下限避免轻质材料产生过大的逆质量与碰撞响应
        return max(density / 1000, 0.05)

    # 在固定刚体图集中分配连续格子区域。
    def allocate(self, count):
        if self.atlasUsed + count > 262144:
            return -1

        offset = self.atlasUsed
        self.atlasUsed += count

        return offset

    # 从材料图建立具有初始运动状态的刚体。
    def createFromImage(
        self,
        width,
        height,
        materials,
        origin,
        angle=0,
        velocity=None,
        angular_velocity=0,
    ):
        offset = self.allocate(width * height)

        if offset < 0:
            return None

        cells = bytearray(width * height * 16)
        owners = np.full(width * height, 0xFFFFFFFF, '<u4')
        body = RigidBody()
        body.slot, self.nextSlot = self.nextSlot, self.nextSlot + 1
        body.atlas, body.rw, body.rh = offset, width, height
        body.mask, body.dens = np.zeros(width * height, 'uint8'), np.zeros(
            width * height, '<f4'
        )

        for index in range(width * height):
            material = int(materials[index])

            if material > 0:
                body.mask[index], body.dens[index] = 1, self.densityOf(material)
                specification = self.mats[material]
                packed_material = material & 255 | (self.rng.int(256) & 255) << 8

                if specification['defaultTemp'] > 0:
                    initial_temperature = specification['defaultTemp']

                else:
                    initial_temperature = 293

                struct.pack_into(
                    '<IfI',
                    cells,
                    index * 16,
                    packed_material,
                    initial_temperature,
                    max(specification['lifeInit'], 0) & 65535,
                )

                owners[index] = body.slot

        body.recompute()

        body.created, body.angle = self.frame, angle
        rotated_com = body.rot(body.com)
        body.pos = [origin[0] + rotated_com[0], origin[1] + rotated_com[1]]
        body.vel, body.angVel = list(velocity or [0, 0]), angular_velocity

        self.bodies.append(body)
        self.newRegions.append(
            SimpleNamespace(
                offset=offset,
                cells=bytes(cells),
                owners=owners.tobytes(),
            )
        )

        return body

    # 将未归属的可动材料连通块建立为刚体。
    def bodify(self, data):
        packed_cells = np.frombuffer(data, '<u4').reshape(-1, 4)

        # 排除已有归属的格子，避免同一块材料生成重复刚体
        owned_atlas_indices = {
            body.atlas + cell_index
            for body in self.bodies
            for cell_index in np.flatnonzero(body.mask)
        }
        flags = np.asarray([material['flags'] for material in self.mats], '<u4')
        material_ids = packed_cells[:, 0] & 255
        eligible_cells = (material_ids != 0) & ((flags[material_ids] & 256) != 0)

        for cell_index in np.flatnonzero(
            eligible_cells & ((packed_cells[:, 0] >> 16 & 64) != 0)
        ):
            if int(packed_cells[cell_index, 3] >> 8) in owned_atlas_indices:
                eligible_cells[cell_index] = False

        visited_cells = np.zeros(self.w * self.h, 'uint8')

        for seed_cell_index in np.flatnonzero(eligible_cells):
            seed_cell_index = int(seed_cell_index)

            if visited_cells[seed_cell_index]:
                continue

            visited_cells[seed_cell_index] = 1
            stack, component = [seed_cell_index], []
            minimum_x, minimum_y, maximum_x, maximum_y = self.w, self.h, 0, 0

            while stack:
                cell_index = stack.pop()

                component.append(cell_index)

                x, y = cell_index % self.w, cell_index // self.w
                minimum_x, minimum_y = min(minimum_x, x), min(minimum_y, y)
                maximum_x, maximum_y = max(maximum_x, x), max(maximum_y, y)
                neighbours = []

                if x > 0:
                    neighbours.append(cell_index - 1)

                if x < self.w - 1:
                    neighbours.append(cell_index + 1)

                if y > 0:
                    neighbours.append(cell_index - self.w)

                if y < self.h - 1:
                    neighbours.append(cell_index + self.w)

                for neighbour in neighbours:
                    if eligible_cells[neighbour] and not visited_cells[neighbour]:
                        visited_cells[neighbour] = 1

                        stack.append(neighbour)

            width, height = maximum_x - minimum_x + 1, maximum_y - minimum_y + 1
            offset = self.allocate(width * height)

            if offset < 0:
                return

            body = RigidBody()
            body.slot, self.nextSlot = self.nextSlot, self.nextSlot + 1
            body.atlas, body.rw, body.rh = offset, width, height
            body.mask, body.dens = np.zeros(width * height, 'uint8'), np.zeros(
                width * height, '<f4'
            )
            cells = bytearray(width * height * 16)
            owners = np.full(width * height, 0xFFFFFFFF, '<u4')

            for cell_index in component:
                local_index = (
                    (cell_index // self.w - minimum_y) * width
                    + cell_index % self.w
                    - minimum_x
                )
                body.mask[local_index], body.dens[local_index] = 1, self.densityOf(
                    int(material_ids[cell_index])
                )
                cells[local_index * 16 : local_index * 16 + 16] = data[
                    cell_index * 16 : cell_index * 16 + 16
                ]
                owners[local_index] = body.slot

                self.claims.extend(
                    (
                        (cell_index % self.w | (cell_index // self.w) << 16)
                        & 0xFFFFFFFF,
                        offset + local_index,
                        body.slot,
                        int(material_ids[cell_index]),
                    )
                )

            body.recompute()

            body.created = self.frame
            body.pos = [minimum_x + body.com[0], minimum_y + body.com[1]]

            self.bodies.append(body)
            self.newRegions.append(
                SimpleNamespace(
                    offset=offset,
                    cells=bytes(cells),
                    owners=owners.tobytes(),
                )
            )

    # 提取刚体当前形状中的独立连通块。
    @staticmethod
    def components(body):
        visited_cells = np.zeros(len(body.mask), 'uint8')
        components = []

        for seed_index in range(len(body.mask)):
            if not body.mask[seed_index] or visited_cells[seed_index]:
                continue

            visited_cells[seed_index] = 1
            stack, component = [seed_index], []

            while stack:
                local_index = stack.pop()

                component.append(local_index)

                column, row = local_index % body.rw, local_index // body.rw
                neighbours = []

                if column > 0:
                    neighbours.append(local_index - 1)

                if column < body.rw - 1:
                    neighbours.append(local_index + 1)

                if row > 0:
                    neighbours.append(local_index - body.rw)

                if row < body.rh - 1:
                    neighbours.append(local_index + body.rw)

                for neighbour in neighbours:
                    if body.mask[neighbour] and not visited_cells[neighbour]:
                        visited_cells[neighbour] = 1

                        stack.append(neighbour)

            components.append(component)

        return components

    # 根据GPU归属结果移除材料并处理断裂。
    def applyOwners(self, data, frame):
        owner_slots = np.frombuffer(data, '<u4')
        fragments = []

        for body_index in range(len(self.bodies) - 1, -1, -1):
            body = self.bodies[body_index]

            if body.created > frame - 3:
                # 延迟接纳旧归属读回，避免新刚体被在途结果误删
                continue

            removed = 0

            for local_index in range(len(body.mask)):
                atlas_index = body.atlas + local_index

                if (
                    body.mask[local_index]
                    and atlas_index < len(owner_slots)
                    and owner_slots[atlas_index] == 0xFFFFFFFF
                ):
                    body.mask[local_index] = 0
                    removed += 1

            if not removed:
                continue

            body.asleep, body.stillFrames = False, 0
            connected_components = self.components(body)

            if not connected_components:
                self.bodies.pop(body_index)

                continue

            # 最大连通块沿用原归属，减少断裂后的GPU所有权改写
            connected_components.sort(key=len, reverse=True)

            previous_center_of_mass = body.com

            for component in connected_components[1:]:
                fragment = RigidBody()
                fragment.slot, self.nextSlot = self.nextSlot, self.nextSlot + 1
                fragment.atlas, fragment.rw, fragment.rh = body.atlas, body.rw, body.rh
                fragment.mask, fragment.dens = (
                    np.zeros(len(body.mask), 'uint8'),
                    body.dens,
                )
                fragment.angle, fragment.angVel = body.angle, body.angVel

                for local_index in component:
                    fragment.mask[local_index], body.mask[local_index] = 1, 0

                    self.ownerUpdates.extend((body.atlas + local_index, fragment.slot))

                fragment.recompute()

                fragment.created = self.frame
                shift = body.rot(
                    [
                        fragment.com[0] - previous_center_of_mass[0],
                        fragment.com[1] - previous_center_of_mass[1],
                    ]
                )
                fragment.pos = [body.pos[0] + shift[0], body.pos[1] + shift[1]]

                # 碎片继承断裂点速度，避免分裂瞬间出现运动突变
                fragment.vel = [
                    body.vel[0] - body.angVel * shift[1],
                    body.vel[1] + body.angVel * shift[0],
                ]

                fragments.append(fragment)

            body.recompute()

        self.bodies.extend(fragments)

    # 查询世界格子对指定刚体的阻挡状态。
    def blocked(self, x, y, slot):
        if x < 0 or y < 0 or x >= self.w or y >= self.h:
            return True

        index = y * self.w + x

        if self.occ[index] & 1:
            return True

        owner = self.bodyAt[index]

        return owner != 0 and owner != slot

    # 将刚体当前形状写入CPU占用索引。
    def rasterizeBodies(self):
        self.bodyAt[self.bodyCells] = 0
        self.bodyCells = []

        for body in self.bodies:
            cosine, sine = math.cos(body.angle), math.sin(body.angle)

            for point in body.all:
                x = math.floor(body.pos[0] + cosine * point[0] - sine * point[1])
                y = math.floor(body.pos[1] + sine * point[0] + cosine * point[1])

                if 0 <= x < self.w and 0 <= y < self.h:
                    index = y * self.w + x

                    if self.bodyAt[index] == 0:
                        self.bodyCells.append(index)

                    self.bodyAt[index] = body.slot

    # 根据稳定归属编号查找刚体对象。
    def bySlot(self, slot):
        return next((body for body in self.bodies if body.slot == slot), None)

    # 为当前刚体建立与世界及其他刚体的接触。
    def findContacts(self, body, offset):
        cosine, sine = math.cos(body.angle), math.sin(body.angle)

        for edge in body.edge:
            contact_arm = [
                cosine * edge[0] - sine * edge[1],
                sine * edge[0] + cosine * edge[1],
            ]
            contact_point = [
                body.pos[0] + offset[0] + contact_arm[0],
                body.pos[1] + offset[1] + contact_arm[1],
            ]
            cell_x, cell_y = math.floor(contact_point[0]), math.floor(contact_point[1])

            if not self.blocked(cell_x, cell_y, body.slot):
                continue

            occupied_x = 0
            occupied_y = 0

            for neighbor_offset_y in range(-1, 2):
                for neighbor_offset_x in range(-1, 2):
                    if (neighbor_offset_x or neighbor_offset_y) and self.blocked(
                        cell_x + neighbor_offset_x,
                        cell_y + neighbor_offset_y,
                        body.slot,
                    ):
                        occupied_x += neighbor_offset_x
                        occupied_y += neighbor_offset_y

            contact_normal = [-occupied_x, -occupied_y]

            if dot(contact_normal, contact_normal) < 0.01:
                contact_normal = [-contact_arm[0], -contact_arm[1]]

            if dot(contact_normal, contact_normal) < 0.000001:
                contact_normal = [0, -1]

            length = vector_length(*contact_normal)
            contact_normal = [contact_normal[0] / length, contact_normal[1] / length]
            depth = clamp(
                0.5
                - (
                    (contact_point[0] - (cell_x + 0.5)) * contact_normal[0]
                    + (contact_point[1] - (cell_y + 0.5)) * contact_normal[1]
                ),
                0,
                1,
            )
            other_body = None

            if (
                0 <= cell_x < self.w
                and 0 <= cell_y < self.h
                and not self.occ[cell_y * self.w + cell_x] & 1
            ):
                other_body = self.bySlot(self.bodyAt[cell_y * self.w + cell_x])

            if other_body:
                other_contact_arm = [
                    contact_point[0] - other_body.pos[0],
                    contact_point[1] - other_body.pos[1],
                ]

            else:
                other_contact_arm = [0, 0]

            self.contacts.append(
                SimpleNamespace(
                    a=body,
                    b=other_body,
                    ra=contact_arm,
                    rb=other_contact_arm,
                    n=contact_normal,
                    depth=depth,
                    jn=0,
                    jt=0,
                )
            )

    # 计算刚体指定接触点的瞬时速度。
    @staticmethod
    def pointVel(body, arm):
        if body is None or body.asleep:
            return [0, 0]

        return [body.vel[0] - body.angVel * arm[1], body.vel[1] + body.angVel * arm[0]]

    # 迭代求解接触法向与摩擦冲量。
    def solve(self):
        # 迭代分摊接触冲量，减轻堆叠物体间的约束误差
        for _ in range(8):
            for contact in self.contacts:
                primary_body = contact.a

                if contact.b and not contact.b.asleep:
                    secondary_body = contact.b

                else:
                    secondary_body = None

                primary_velocity = self.pointVel(primary_body, contact.ra)
                secondary_velocity = self.pointVel(secondary_body, contact.rb)
                relative_velocity = [
                    primary_velocity[0] - secondary_velocity[0],
                    primary_velocity[1] - secondary_velocity[1],
                ]
                normal_speed = dot(relative_velocity, contact.n)
                primary_cross = cross(contact.ra, contact.n)

                if secondary_body:
                    secondary_cross = cross(contact.rb, contact.n)

                else:
                    secondary_cross = 0

                inverse_effective_mass = (
                    primary_body.invMass
                    + primary_body.invInertia * primary_cross * primary_cross
                )

                if secondary_body:
                    inverse_effective_mass += (
                        secondary_body.invMass
                        + secondary_body.invInertia * secondary_cross * secondary_cross
                    )

                if normal_speed < -40:
                    contact_restitution = self.restitution

                else:
                    contact_restitution = 0

                # 保持冲量运算顺序，避免舍入差异改变后续碰撞轨迹
                impulse = (
                    -(1 + contact_restitution) * normal_speed / inverse_effective_mass
                )
                total_impulse = max(contact.jn + impulse, 0)
                impulse = total_impulse - contact.jn
                contact.jn = total_impulse
                impulse_vector = [contact.n[0] * impulse, contact.n[1] * impulse]

                self.applyImpulse(primary_body, contact.ra, impulse_vector, 1)

                if secondary_body:
                    self.applyImpulse(secondary_body, contact.rb, impulse_vector, -1)

                tangent = [-contact.n[1], contact.n[0]]
                primary_velocity = self.pointVel(primary_body, contact.ra)
                secondary_velocity = self.pointVel(secondary_body, contact.rb)
                relative_velocity = [
                    primary_velocity[0] - secondary_velocity[0],
                    primary_velocity[1] - secondary_velocity[1],
                ]
                primary_cross = cross(contact.ra, tangent)

                if secondary_body:
                    secondary_cross = cross(contact.rb, tangent)

                else:
                    secondary_cross = 0

                inverse_effective_mass = (
                    primary_body.invMass
                    + primary_body.invInertia * primary_cross * primary_cross
                )

                if secondary_body:
                    inverse_effective_mass += (
                        secondary_body.invMass
                        + secondary_body.invInertia * secondary_cross * secondary_cross
                    )

                impulse = -dot(relative_velocity, tangent) / inverse_effective_mass
                friction_limit = self.friction * contact.jn
                total_impulse = clamp(
                    contact.jt + impulse, -friction_limit, friction_limit
                )
                impulse = total_impulse - contact.jt
                contact.jt = total_impulse
                impulse_vector = [tangent[0] * impulse, tangent[1] * impulse]

                self.applyImpulse(primary_body, contact.ra, impulse_vector, 1)

                if secondary_body:
                    self.applyImpulse(secondary_body, contact.rb, impulse_vector, -1)

    # 将接触冲量施加到刚体线速度与角速度。
    @staticmethod
    def applyImpulse(body, arm, impulse, sign):
        body.vel = [
            body.vel[0] + sign * impulse[0] * body.invMass,
            body.vel[1] + sign * impulse[1] * body.invMass,
        ]
        body.angVel += sign * cross(arm, impulse) * body.invInertia

    # 推进重力、浮力、阻尼及刚体运动。
    def integrate(self, body, delta):
        body.vel = [body.vel[0], body.vel[1] + self.gravity * delta]

        if self.haveOcc and body.edge:
            cosine, sine = math.cos(body.angle), math.sin(body.angle)

            self.wetRows.clear()

            for point in body.edge:
                world_x = body.pos[0] + cosine * point[0] - sine * point[1]
                world_y = body.pos[1] + sine * point[0] + cosine * point[1]
                row = math.floor(world_y)

                if row < 0 or row >= self.h or row in self.wetRows:
                    continue

                left = math.floor(world_x - 1.5)
                right = math.floor(world_x + 1.5)
                left_index, right_index = row * self.w + left, row * self.w + right

                # 限定扁平索引范围，避免负索引回绕改变原版浮力
                left_wet = (
                    left >= 0
                    and 0 <= left_index < len(self.occ)
                    and self.occ[left_index] & 2
                )
                right_wet = (
                    right < self.w
                    and 0 <= right_index < len(self.occ)
                    and self.occ[right_index] & 2
                )

                if left_wet or right_wet:
                    self.wetRows.add(row)

            submerged_count = 0
            buoyancy_center_x = 0
            buoyancy_center_y = 0

            if self.wetRows:
                for point in body.all:
                    rotated_x, rotated_y = (
                        cosine * point[0] - sine * point[1],
                        sine * point[0] + cosine * point[1],
                    )

                    if math.floor(body.pos[1] + rotated_y) in self.wetRows:
                        submerged_count += 1
                        buoyancy_center_x += rotated_x
                        buoyancy_center_y += rotated_y

            if submerged_count > 0:
                submerged_fraction = submerged_count / len(body.all)
                buoyancy_force = submerged_fraction * body.count * self.gravity
                buoyancy_center_x, buoyancy_center_y = (
                    buoyancy_center_x / submerged_count,
                    buoyancy_center_y / submerged_count,
                )
                body.vel = [
                    body.vel[0],
                    body.vel[1] - buoyancy_force * body.invMass * delta,
                ]
                body.angVel += (
                    cross([buoyancy_center_x, buoyancy_center_y], [0, -buoyancy_force])
                    * body.invInertia
                    * delta
                )
                buoyancy_damping = math.exp(-6 * submerged_fraction * delta)
                body.vel = [
                    body.vel[0] * buoyancy_damping,
                    body.vel[1]
                    * buoyancy_damping
                    * math.exp(-6 * submerged_fraction * delta),
                ]
                body.angVel *= math.exp(-8 * submerged_fraction * delta)

        body.angVel *= math.exp(-0.2 * delta)
        speed = vector_length(*body.vel)

        if speed > 500:
            # 限制单步位移，降低高速刚体穿过格子障碍的风险
            body.vel = [body.vel[0] / speed * 500, body.vel[1] / speed * 500]

        body.angVel = clamp(body.angVel, -20, 20)
        body.pos = [
            body.pos[0] + body.vel[0] * delta,
            body.pos[1] + body.vel[1] * delta,
        ]
        body.angle += body.angVel * delta

    # 将爆炸冲击接入范围内的刚体运动。
    def blast(self, explosion):
        for body in self.bodies:
            offset = [body.pos[0] - explosion[0], body.pos[1] - explosion[1]]
            distance, radius = vector_length(*offset), explosion[2] * 2.5

            if distance > radius:
                continue

            falloff = 1 - distance / radius

            if distance > 0.01:
                direction = [offset[0] / distance, offset[1] / distance]

            else:
                direction = [0, -1]

            body.asleep, body.stillFrames = False, 0
            impulse = (
                260 * falloff * explosion[3] / math.sqrt(max(body.mass, 1) / 30 + 1)
            )
            body.vel = [
                body.vel[0] + direction[0] * impulse,
                body.vel[1] + direction[1] * impulse,
            ]
            body.angVel += (self.rng.next() - 0.5) * 8 * falloff * explosion[3]

    # 处理GPU反馈并推进刚体物理子步。
    def update(self, delta, paused):
        self.frame += 1
        occupancy, owners, cells, owners_frame = (
            self.occIn,
            self.ownersIn,
            self.cellsIn,
            self.ownersFrame,
        )
        self.occIn = None
        self.ownersIn = None
        self.cellsIn = None

        if occupancy is not None:
            packed = np.frombuffer(occupancy, 'uint8')
            self.occ[:] = (
                (packed[:, None] >> np.asarray([0, 2, 4, 6], 'uint8')) & 3
            ).reshape(-1)
            self.haveOcc = True

        if owners is not None:
            self.applyOwners(owners, owners_frame)

        if cells is not None:
            self.bodify(cells)

        if not paused and self.haveOcc and self.bodies:
            step = delta / self.substeps

            for _ in range(self.substeps):
                self.rasterizeBodies()

                for body in self.bodies:
                    if not body.asleep:
                        self.integrate(body, step)

                self.rasterizeBodies()

                self.contacts = []

                for body in self.bodies:
                    if not body.asleep:
                        self.findContacts(body, [0, 0])

                self.solve()

                for body in self.bodies:
                    if body.asleep:
                        continue

                    shift_x = 0
                    shift_y = 0
                    count = 0

                    for contact in self.contacts:
                        if contact.a is body:
                            depth = max(contact.depth - 0.05, 0)
                            shift_x += contact.n[0] * depth
                            shift_y += contact.n[1] * depth
                            count += 1

                    if count:
                        body.pos = [
                            body.pos[0] + shift_x / count * 0.5,
                            body.pos[1] + shift_y / count * 0.5,
                        ]

                for contact in self.contacts:
                    if contact.b and contact.b.asleep and contact.jn > 30:
                        contact.b.asleep, contact.b.stillFrames = False, 0

            for body in self.bodies:
                if body.asleep:
                    body.sleepCheck += 1

                    if body.sleepCheck >= 15:
                        # 休眠后仍复查支撑，避免底部材料消失时物体悬空
                        body.sleepCheck, self.contacts = 0, []

                        self.rasterizeBodies()
                        self.findContacts(body, [0, 0.8])

                        if not self.contacts:
                            body.asleep, body.stillFrames = False, 0

                    continue

                if dot(body.vel, body.vel) < 36 and abs(body.angVel) < 0.25:
                    body.stillFrames = body.stillFrames + 1

                else:
                    body.stillFrames = 0

                if body.stillFrames > 30:
                    body.asleep, body.vel, body.angVel, body.sleepCheck = (
                        True,
                        [0, 0],
                        0,
                        0,
                    )

        self.bodies[:] = [
            body
            for body in self.bodies
            if not (
                body.pos[1] > self.h + 200
                or body.pos[0] < -200
                or body.pos[0] > self.w + 200
            )
        ]

        return self.snapshot(paused)

    # 按GPU布局生成当前刚体交换包。
    def snapshot(self, paused):
        body_count = min(len(self.bodies), 1024)

        # 交换包固定为着色器的64字节布局，避免CPU与GPU错读
        body_packet = bytearray(body_count * 64)

        for body_index, body in enumerate(self.bodies[:body_count]):
            cosine, sine = math.cos(body.angle), math.sin(body.angle)
            world_corners = []

            for corner_x, corner_y in (
                (0, 0),
                (body.rw, 0),
                (0, body.rh),
                (body.rw, body.rh),
            ):
                local_x, local_y = corner_x - body.com[0], corner_y - body.com[1]

                world_corners.append(
                    [
                        body.pos[0] + cosine * local_x - sine * local_y,
                        body.pos[1] + sine * local_x + cosine * local_y,
                    ]
                )

            struct.pack_into(
                '<6f', body_packet, body_index * 64, *body.pos, cosine, sine, *body.com
            )
            struct.pack_into(
                '<8i',
                body_packet,
                body_index * 64 + 32,
                body.atlas,
                body.rw,
                body.rh,
                body.slot,
                clamp(
                    math.floor(min(corner[0] for corner in world_corners)) - 1,
                    0,
                    self.w,
                ),
                clamp(
                    math.floor(min(corner[1] for corner in world_corners)) - 1,
                    0,
                    self.h,
                ),
                clamp(
                    math.ceil(max(corner[0] for corner in world_corners)) + 1, 0, self.w
                ),
                clamp(
                    math.ceil(max(corner[1] for corner in world_corners)) + 1, 0, self.h
                ),
            )

        result = SimpleNamespace(
            frame=self.frame,
            atlasUsed=self.atlasUsed,
            reset=self.resetPending,
            step=not paused,
            count=body_count,
            bodies=bytes(body_packet),
            newRegions=self.newRegions,
            ownerUpdates=self.ownerUpdates,
            claims=self.claims,
        )
        self.resetPending = False
        self.newRegions, self.ownerUpdates, self.claims = [], [], []

        return result
