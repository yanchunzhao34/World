"""Rigid-body masks, connected components, buoyancy and contact impulses."""

import math

import numpy as np
from _infernux_packages.workshop.runtime.library.dependencies import SimpleNamespace, struct

from .settings import clamp, vector_length


class XorShift32:
    def __init__(self, seed):
        self.state = (seed & 0xffffffff) or 1

    def next(self):
        # 限定32位溢出，保持跨语言的随机序列一致
        self.state ^= (self.state << 13) & 0xffffffff
        self.state ^= self.state >> 17
        self.state ^= (self.state << 5) & 0xffffffff
        self.state &= 0xffffffff
        return self.state / 4294967296

    def int(self, limit):
        return math.floor(self.next() * limit)


def dot(a, b):
    return a[0]*b[0] + a[1]*b[1]


def cross(a, b):
    return a[0]*b[1] - a[1]*b[0]


class RigidBody:
    def __init__(self):
        self.slot = self.atlas = self.rw = self.rh = self.count = 0
        self.mask = np.empty(0, 'uint8')
        self.dens = np.empty(0, '<f4')
        self.com = [0, 0]
        self.mass = self.inertia = self.invMass = self.invInertia = 0
        self.pos = [0, 0]
        self.vel = [0, 0]
        self.angle = self.angVel = 0
        self.asleep = False
        self.stillFrames = self.sleepCheck = 0
        self.created = -1
        self.edge = []
        self.all = []

    def rot(self, point):
        cosine, sine = math.cos(self.angle), math.sin(self.angle)
        return [cosine*point[0]-sine*point[1], sine*point[0]+cosine*point[1]]

    def recompute(self):
        self.count = 0
        moment_x = moment_y = mass = 0
        for y in range(self.rh):
            for x in range(self.rw):
                index = y*self.rw+x
                if self.mask[index]:
                    density = float(self.dens[index])
                    self.count += 1
                    moment_x += (x+.5)*density
                    moment_y += (y+.5)*density
                    mass += density
        if not self.count:
            return
        previous_com = self.com
        self.com, self.mass = [moment_x/mass, moment_y/mass], mass
        inertia, points, edges = 0, [], []
        for y in range(self.rh):
            for x in range(self.rw):
                index = y*self.rw+x
                if not self.mask[index]:
                    continue
                point = [x+.5-self.com[0], y+.5-self.com[1]]
                # 计入单格自身转动惯量，避免小刚体旋转响应失真
                inertia += float(self.dens[index])*(point[0]*point[0]+point[1]*point[1]+1/6)
                points.append(point)
                if (x == 0 or y == 0 or x == self.rw-1 or y == self.rh-1 or
                    not self.mask[index-1] or not self.mask[index+1] or
                    not self.mask[index-self.rw] or not self.mask[index+self.rw]):
                    edges.append(point)
        self.inertia, self.invMass, self.invInertia = inertia, 1/mass, 1/max(inertia, .001)
        self.all, self.edge = points, edges
        if self.created >= 0 and (previous_com[0] != 0 or previous_com[1] != 0):
            # 质心变化时补偿位置，避免形状受损后整体跳动
            shift = self.rot([self.com[0]-previous_com[0], self.com[1]-previous_com[1]])
            self.pos = [self.pos[0]+shift[0], self.pos[1]+shift[1]]


class RigidBodyWorld:
    def __init__(self, width, height, materials):
        self.w, self.h, self.mats = width, height, materials
        self.gravity, self.restitution, self.friction, self.substeps = 320, .15, .6, 4
        self.bodies = []
        self.nextSlot, self.atlasUsed, self.frame = 1, 0, 0
        self.resetPending = True
        self.newRegions, self.ownerUpdates, self.claims = [], [], []
        self.occ = np.zeros(width*height, 'uint8')
        self.bodyAt = np.zeros(width*height, '<i4')
        self.bodyCells = []
        self.haveOcc = False
        self.occIn = self.ownersIn = self.cellsIn = None
        self.ownersFrame = 0
        self.rng = XorShift32(7)
        self.contacts = []
        self.wetRows = set()

    @property
    def used(self):
        return self.atlasUsed

    def clear(self):
        self.bodies.clear()
        self.nextSlot, self.atlasUsed, self.resetPending = 1, 0, True
        self.newRegions, self.ownerUpdates, self.claims = [], [], []
        self.haveOcc = False
        self.bodyAt.fill(0)
        self.bodyCells = []
        self.occIn = self.ownersIn = self.cellsIn = None

    def onOccupancy(self, data):
        self.occIn = data

    def onOwners(self, data, frame):
        self.ownersIn, self.ownersFrame = data, frame

    def onCells(self, data):
        self.cellsIn = data

    def densityOf(self, identifier):
        density = self.mats[identifier].get('density', 1000) if identifier < len(self.mats) else 1000
        # 密度下限避免轻质材料产生过大的逆质量与碰撞响应
        return max(density/1000, .05)

    def allocate(self, count):
        if self.atlasUsed+count > 262144:
            return -1
        offset = self.atlasUsed
        self.atlasUsed += count
        return offset

    def createFromImage(self, width, height, materials, origin, angle=0, velocity=None, angular_velocity=0):
        offset = self.allocate(width*height)
        if offset < 0:
            return None
        cells = bytearray(width*height*16)
        owners = np.full(width*height, 0xffffffff, '<u4')
        body = RigidBody()
        body.slot, self.nextSlot = self.nextSlot, self.nextSlot+1
        body.atlas, body.rw, body.rh = offset, width, height
        body.mask, body.dens = np.zeros(width*height, 'uint8'), np.zeros(width*height, '<f4')
        for index in range(width*height):
            material = int(materials[index])
            if material > 0:
                body.mask[index], body.dens[index] = 1, self.densityOf(material)
                specification = self.mats[material]
                struct.pack_into('<IfI', cells, index*16, material & 255 | (self.rng.int(256)&255)<<8,
                    specification['defaultTemp'] if specification['defaultTemp'] > 0 else 293,
                    max(specification['lifeInit'], 0)&65535)
                owners[index] = body.slot
        body.recompute()
        body.created, body.angle = self.frame, angle
        rotated_com = body.rot(body.com)
        body.pos = [origin[0]+rotated_com[0], origin[1]+rotated_com[1]]
        body.vel, body.angVel = list(velocity or [0, 0]), angular_velocity
        self.bodies.append(body)
        self.newRegions.append(SimpleNamespace(offset=offset, cells=bytes(cells), owners=owners.tobytes()))
        return body

    def bodify(self, data):
        packed = np.frombuffer(data, '<u4').reshape(-1, 4)
        # 排除已有归属的格子，避免同一块材料生成重复刚体
        owned = {body.atlas+index for body in self.bodies for index in np.flatnonzero(body.mask)}
        flags = np.asarray([material['flags'] for material in self.mats], '<u4')
        materials = packed[:, 0] & 255
        eligible = (materials != 0) & ((flags[materials] & 256) != 0)
        for index in np.flatnonzero(eligible & ((packed[:, 0] >> 16 & 64) != 0)):
            if int(packed[index, 3] >> 8) in owned:
                eligible[index] = False
        visited = np.zeros(self.w*self.h, 'uint8')
        for seed in np.flatnonzero(eligible):
            seed = int(seed)
            if visited[seed]:
                continue
            visited[seed] = 1
            stack, component = [seed], []
            minimum_x, minimum_y, maximum_x, maximum_y = self.w, self.h, 0, 0
            while stack:
                index = stack.pop()
                component.append(index)
                x, y = index % self.w, index // self.w
                minimum_x, minimum_y = min(minimum_x, x), min(minimum_y, y)
                maximum_x, maximum_y = max(maximum_x, x), max(maximum_y, y)
                neighbours = []
                if x > 0:
                    neighbours.append(index-1)
                if x < self.w-1:
                    neighbours.append(index+1)
                if y > 0:
                    neighbours.append(index-self.w)
                if y < self.h-1:
                    neighbours.append(index+self.w)
                for neighbour in neighbours:
                    if eligible[neighbour] and not visited[neighbour]:
                        visited[neighbour] = 1
                        stack.append(neighbour)
            width, height = maximum_x-minimum_x+1, maximum_y-minimum_y+1
            offset = self.allocate(width*height)
            if offset < 0:
                return
            body = RigidBody()
            body.slot, self.nextSlot = self.nextSlot, self.nextSlot+1
            body.atlas, body.rw, body.rh = offset, width, height
            body.mask, body.dens = np.zeros(width*height, 'uint8'), np.zeros(width*height, '<f4')
            cells = bytearray(width*height*16)
            owners = np.full(width*height, 0xffffffff, '<u4')
            for index in component:
                local = (index//self.w-minimum_y)*width + index%self.w-minimum_x
                body.mask[local], body.dens[local] = 1, self.densityOf(int(materials[index]))
                cells[local*16:local*16+16] = data[index*16:index*16+16]
                owners[local] = body.slot
                self.claims.extend(((index%self.w | (index//self.w)<<16)&0xffffffff,
                                    offset+local, body.slot, int(materials[index])))
            body.recompute()
            body.created = self.frame
            body.pos = [minimum_x+body.com[0], minimum_y+body.com[1]]
            self.bodies.append(body)
            self.newRegions.append(SimpleNamespace(offset=offset, cells=bytes(cells), owners=owners.tobytes()))

    @staticmethod
    def components(body):
        visited = np.zeros(len(body.mask), 'uint8')
        components = []
        for seed in range(len(body.mask)):
            if not body.mask[seed] or visited[seed]:
                continue
            visited[seed] = 1
            stack, component = [seed], []
            while stack:
                index = stack.pop()
                component.append(index)
                x, y = index % body.rw, index // body.rw
                neighbours = []
                if x > 0:
                    neighbours.append(index-1)
                if x < body.rw-1:
                    neighbours.append(index+1)
                if y > 0:
                    neighbours.append(index-body.rw)
                if y < body.rh-1:
                    neighbours.append(index+body.rw)
                for neighbour in neighbours:
                    if body.mask[neighbour] and not visited[neighbour]:
                        visited[neighbour] = 1
                        stack.append(neighbour)
            components.append(component)
        return components

    def applyOwners(self, data, frame):
        owners = np.frombuffer(data, '<u4')
        fragments = []
        for index in range(len(self.bodies)-1, -1, -1):
            body = self.bodies[index]
            if body.created > frame-3:
                # 延迟接纳旧归属读回，避免新刚体被在途结果误删
                continue
            removed = 0
            for local in range(len(body.mask)):
                atlas_index = body.atlas+local
                if body.mask[local] and atlas_index < len(owners) and owners[atlas_index] == 0xffffffff:
                    body.mask[local] = 0
                    removed += 1
            if not removed:
                continue
            body.asleep, body.stillFrames = False, 0
            components = self.components(body)
            if not components:
                self.bodies.pop(index)
                continue
            # 最大连通块沿用原归属，减少断裂后的GPU所有权改写
            components.sort(key=len, reverse=True)
            previous_com = body.com
            for component in components[1:]:
                fragment = RigidBody()
                fragment.slot, self.nextSlot = self.nextSlot, self.nextSlot+1
                fragment.atlas, fragment.rw, fragment.rh = body.atlas, body.rw, body.rh
                fragment.mask, fragment.dens = np.zeros(len(body.mask), 'uint8'), body.dens
                fragment.angle, fragment.angVel = body.angle, body.angVel
                for local in component:
                    fragment.mask[local], body.mask[local] = 1, 0
                    self.ownerUpdates.extend((body.atlas+local, fragment.slot))
                fragment.recompute()
                fragment.created = self.frame
                shift = body.rot([fragment.com[0]-previous_com[0], fragment.com[1]-previous_com[1]])
                fragment.pos = [body.pos[0]+shift[0], body.pos[1]+shift[1]]
                # 碎片继承断裂点速度，避免分裂瞬间出现运动突变
                fragment.vel = [body.vel[0]-body.angVel*shift[1], body.vel[1]+body.angVel*shift[0]]
                fragments.append(fragment)
            body.recompute()
        self.bodies.extend(fragments)

    def blocked(self, x, y, slot):
        if x < 0 or y < 0 or x >= self.w or y >= self.h:
            return True
        index = y*self.w+x
        if self.occ[index] & 1:
            return True
        owner = self.bodyAt[index]
        return owner != 0 and owner != slot

    def rasterizeBodies(self):
        self.bodyAt[self.bodyCells] = 0
        self.bodyCells = []
        for body in self.bodies:
            cosine, sine = math.cos(body.angle), math.sin(body.angle)
            for point in body.all:
                x = math.floor(body.pos[0]+cosine*point[0]-sine*point[1])
                y = math.floor(body.pos[1]+sine*point[0]+cosine*point[1])
                if 0 <= x < self.w and 0 <= y < self.h:
                    index = y*self.w+x
                    if self.bodyAt[index] == 0:
                        self.bodyCells.append(index)
                    self.bodyAt[index] = body.slot

    def bySlot(self, slot):
        return next((body for body in self.bodies if body.slot == slot), None)

    def findContacts(self, body, offset):
        cosine, sine = math.cos(body.angle), math.sin(body.angle)
        for edge in body.edge:
            arm = [cosine*edge[0]-sine*edge[1], sine*edge[0]+cosine*edge[1]]
            point = [body.pos[0]+offset[0]+arm[0], body.pos[1]+offset[1]+arm[1]]
            x, y = math.floor(point[0]), math.floor(point[1])
            if not self.blocked(x, y, body.slot):
                continue
            occupied_x = occupied_y = 0
            for dy in range(-1, 2):
                for dx in range(-1, 2):
                    if (dx or dy) and self.blocked(x+dx, y+dy, body.slot):
                        occupied_x += dx
                        occupied_y += dy
            normal = [-occupied_x, -occupied_y]
            if dot(normal, normal) < .01:
                normal = [-arm[0], -arm[1]]
            if dot(normal, normal) < .000001:
                normal = [0, -1]
            length = vector_length(*normal)
            normal = [normal[0]/length, normal[1]/length]
            depth = clamp(.5-((point[0]-(x+.5))*normal[0]+(point[1]-(y+.5))*normal[1]), 0, 1)
            other = None
            if 0 <= x < self.w and 0 <= y < self.h and not self.occ[y*self.w+x]&1:
                other = self.bySlot(self.bodyAt[y*self.w+x])
            self.contacts.append(SimpleNamespace(a=body, b=other, ra=arm,
                rb=[point[0]-other.pos[0], point[1]-other.pos[1]] if other else [0, 0],
                n=normal, depth=depth, jn=0, jt=0))

    @staticmethod
    def pointVel(body, arm):
        if body is None or body.asleep:
            return [0, 0]
        return [body.vel[0]-body.angVel*arm[1], body.vel[1]+body.angVel*arm[0]]

    def solve(self):
        # 迭代分摊接触冲量，减轻堆叠物体间的约束误差
        for _ in range(8):
            for contact in self.contacts:
                first, second = contact.a, contact.b if contact.b and not contact.b.asleep else None
                first_velocity, second_velocity = self.pointVel(first, contact.ra), self.pointVel(second, contact.rb)
                relative = [first_velocity[0]-second_velocity[0], first_velocity[1]-second_velocity[1]]
                speed = dot(relative, contact.n)
                first_cross, second_cross = cross(contact.ra, contact.n), cross(contact.rb, contact.n) if second else 0
                effective_mass = first.invMass+first.invInertia*first_cross*first_cross
                if second:
                    effective_mass += second.invMass+second.invInertia*second_cross*second_cross
                impulse = -(1+(self.restitution if speed < -40 else 0))*speed/effective_mass
                accumulated = max(contact.jn+impulse, 0)
                impulse, contact.jn = accumulated-contact.jn, accumulated
                vector = [contact.n[0]*impulse, contact.n[1]*impulse]
                self.applyImpulse(first, contact.ra, vector, 1)
                if second:
                    self.applyImpulse(second, contact.rb, vector, -1)
                tangent = [-contact.n[1], contact.n[0]]
                first_velocity, second_velocity = self.pointVel(first, contact.ra), self.pointVel(second, contact.rb)
                relative = [first_velocity[0]-second_velocity[0], first_velocity[1]-second_velocity[1]]
                first_cross, second_cross = cross(contact.ra, tangent), cross(contact.rb, tangent) if second else 0
                effective_mass = first.invMass+first.invInertia*first_cross*first_cross
                if second:
                    effective_mass += second.invMass+second.invInertia*second_cross*second_cross
                impulse = -dot(relative, tangent)/effective_mass
                bound = self.friction*contact.jn
                accumulated = clamp(contact.jt+impulse, -bound, bound)
                impulse, contact.jt = accumulated-contact.jt, accumulated
                vector = [tangent[0]*impulse, tangent[1]*impulse]
                self.applyImpulse(first, contact.ra, vector, 1)
                if second:
                    self.applyImpulse(second, contact.rb, vector, -1)

    @staticmethod
    def applyImpulse(body, arm, impulse, sign):
        body.vel = [body.vel[0]+sign*impulse[0]*body.invMass, body.vel[1]+sign*impulse[1]*body.invMass]
        body.angVel += sign*cross(arm, impulse)*body.invInertia

    def integrate(self, body, delta):
        body.vel = [body.vel[0], body.vel[1]+self.gravity*delta]
        if self.haveOcc and body.edge:
            cosine, sine = math.cos(body.angle), math.sin(body.angle)
            self.wetRows.clear()
            for point in body.edge:
                x = body.pos[0]+cosine*point[0]-sine*point[1]
                y = body.pos[1]+sine*point[0]+cosine*point[1]
                row = math.floor(y)
                if row < 0 or row >= self.h or row in self.wetRows:
                    continue
                left, right = math.floor(x-1.5), math.floor(x+1.5)
                left_index, right_index = row*self.w+left, row*self.w+right
                # 限定扁平索引范围，避免负索引回绕改变原版浮力
                left_wet = left >= 0 and 0 <= left_index < len(self.occ) and self.occ[left_index]&2
                right_wet = right < self.w and 0 <= right_index < len(self.occ) and self.occ[right_index]&2
                if left_wet or right_wet:
                    self.wetRows.add(row)
            wet_count = center_x = center_y = 0
            if self.wetRows:
                for point in body.all:
                    x, y = cosine*point[0]-sine*point[1], sine*point[0]+cosine*point[1]
                    if math.floor(body.pos[1]+y) in self.wetRows:
                        wet_count += 1
                        center_x += x
                        center_y += y
            if wet_count > 0:
                fraction = wet_count/len(body.all)
                force = fraction*body.count*self.gravity
                center_x, center_y = center_x/wet_count, center_y/wet_count
                body.vel = [body.vel[0], body.vel[1]-force*body.invMass*delta]
                body.angVel += cross([center_x, center_y], [0, -force])*body.invInertia*delta
                damping = math.exp(-6*fraction*delta)
                body.vel = [body.vel[0]*damping, body.vel[1]*damping*math.exp(-6*fraction*delta)]
                body.angVel *= math.exp(-8*fraction*delta)
        body.angVel *= math.exp(-.2*delta)
        speed = vector_length(*body.vel)
        if speed > 500:
            # 限制单步位移，降低高速刚体穿过格子障碍的风险
            body.vel = [body.vel[0]/speed*500, body.vel[1]/speed*500]
        body.angVel = clamp(body.angVel, -20, 20)
        body.pos = [body.pos[0]+body.vel[0]*delta, body.pos[1]+body.vel[1]*delta]
        body.angle += body.angVel*delta

    def blast(self, explosion):
        for body in self.bodies:
            offset = [body.pos[0]-explosion[0], body.pos[1]-explosion[1]]
            distance, radius = vector_length(*offset), explosion[2]*2.5
            if distance > radius:
                continue
            falloff = 1-distance/radius
            direction = [offset[0]/distance, offset[1]/distance] if distance > .01 else [0, -1]
            body.asleep, body.stillFrames = False, 0
            impulse = 260*falloff*explosion[3]/math.sqrt(max(body.mass, 1)/30+1)
            body.vel = [body.vel[0]+direction[0]*impulse, body.vel[1]+direction[1]*impulse]
            body.angVel += (self.rng.next()-.5)*8*falloff*explosion[3]

    def update(self, delta, paused):
        self.frame += 1
        occupancy, owners, cells, owners_frame = self.occIn, self.ownersIn, self.cellsIn, self.ownersFrame
        self.occIn = self.ownersIn = self.cellsIn = None
        if occupancy is not None:
            packed = np.frombuffer(occupancy, 'uint8')
            self.occ[:] = ((packed[:, None] >> np.asarray([0, 2, 4, 6], 'uint8')) & 3).reshape(-1)
            self.haveOcc = True
        if owners is not None:
            self.applyOwners(owners, owners_frame)
        if cells is not None:
            self.bodify(cells)
        if not paused and self.haveOcc and self.bodies:
            step = delta/self.substeps
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
                    shift_x = shift_y = count = 0
                    for contact in self.contacts:
                        if contact.a is body:
                            depth = max(contact.depth-.05, 0)
                            shift_x += contact.n[0]*depth
                            shift_y += contact.n[1]*depth
                            count += 1
                    if count:
                        body.pos = [body.pos[0]+shift_x/count*.5, body.pos[1]+shift_y/count*.5]
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
                        self.findContacts(body, [0, .8])
                        if not self.contacts:
                            body.asleep, body.stillFrames = False, 0
                    continue
                body.stillFrames = body.stillFrames+1 if dot(body.vel, body.vel)<36 and abs(body.angVel)<.25 else 0
                if body.stillFrames > 30:
                    body.asleep, body.vel, body.angVel, body.sleepCheck = True, [0, 0], 0, 0
        self.bodies[:] = [body for body in self.bodies if not (body.pos[1]>self.h+200 or body.pos[0]<-200 or body.pos[0]>self.w+200)]
        return self.snapshot(paused)

    def snapshot(self, paused):
        count = min(len(self.bodies), 1024)
        # 交换包固定为着色器的64字节布局，避免CPU与GPU错读
        data = bytearray(count*64)
        for index, body in enumerate(self.bodies[:count]):
            cosine, sine = math.cos(body.angle), math.sin(body.angle)
            corners = []
            for x, y in ((0, 0), (body.rw, 0), (0, body.rh), (body.rw, body.rh)):
                local_x, local_y = x-body.com[0], y-body.com[1]
                corners.append([body.pos[0]+cosine*local_x-sine*local_y, body.pos[1]+sine*local_x+cosine*local_y])
            struct.pack_into('<6f', data, index*64, *body.pos, cosine, sine, *body.com)
            struct.pack_into('<8i', data, index*64+32, body.atlas, body.rw, body.rh, body.slot,
                clamp(math.floor(min(p[0] for p in corners))-1, 0, self.w),
                clamp(math.floor(min(p[1] for p in corners))-1, 0, self.h),
                clamp(math.ceil(max(p[0] for p in corners))+1, 0, self.w),
                clamp(math.ceil(max(p[1] for p in corners))+1, 0, self.h))
        result = SimpleNamespace(frame=self.frame, atlasUsed=self.atlasUsed, reset=self.resetPending,
            step=not paused, count=count, bodies=bytes(data), newRegions=self.newRegions,
            ownerUpdates=self.ownerUpdates, claims=self.claims)
        self.resetPending = False
        self.newRegions, self.ownerUpdates, self.claims = [], [], []
        return result
