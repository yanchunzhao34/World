"""Typed GPU resources and compute calls shared by the Python simulation modules."""

from dataclasses import dataclass

import numpy as np


@dataclass
class Texture:
    host: object
    id: int
    width: int
    height: int
    format: str
    label: str
    depthOrArrayLayers: int = 1

    def destroy(self, *_):
        self.host.destroy(self.id)


@dataclass
class Buffer:
    host: object
    id: int
    size: int
    label: str

    def destroy(self, *_):
        self.host.destroy(self.id)


@dataclass
class Sampler:
    id: int


class DoubleBuffer:
    def __init__(self, read, write):
        self.read, self.write = read, write

    def swap(self):
        self.read, self.write = self.write, self.read


class Parameters:
    def __init__(self, **values):
        self.i = np.zeros(8, dtype='<i4')
        self.f = np.zeros(8, dtype='<f4')
        for name, value in values.items():
            self.set(name, value)

    def set(self, name, value):
        index = (0 if name[1] == '0' else 4) + 'xyzw'.index(name[2])
        if name[0] == 'i':
            value = int(value) & 0xffffffff
            self.i[index] = value if value < 0x80000000 else value - 0x100000000
        else:
            self.f[index] = value
        return self

    def clone(self):
        result = Parameters()
        result.i[:] = self.i
        result.f[:] = self.f
        return result

    def bytes(self):
        return self.i.tobytes() + self.f.tobytes()


class Bindings:
    def __init__(self):
        self.entries = {}

    def image(self, binding, texture):
        self.entries[binding] = (texture, None)
        return self

    def buffer(self, binding, buffer):
        self.entries[binding] = (buffer, None)
        return self

    def ubo(self, binding, buffer):
        return self.buffer(binding, buffer)

    def sampler(self, binding, sampler, texture):
        self.entries[binding] = (texture, sampler)
        return self


def binary_bytes(value):
    return value.tobytes() if isinstance(value, np.ndarray) else bytes(value)


class NativeGPU:
    def __init__(self, host):
        self.host = host
        self.submits = 0
        self.linearClamp = Sampler(host.make_sampler(True, False))
        self.nearestClamp = Sampler(host.make_sampler(False, False))
        self.linearRepeat = Sampler(host.make_sampler(True, True))
        self.scratch = {}
        self.jobs = []

    def createTexture(self, width, height, format, label, depth=1):
        width, height, depth = int(width), int(height), int(depth)
        return Texture(self.host, self.host.make_texture(width, height, format, depth),
                       width, height, format, label, depth)

    def createStorageBuffer(self, size, value, label):
        size = int(size)
        result = Buffer(self.host, self.host.make_buffer(size, False), size, label)
        if value is not None:
            self.writeBuffer(result, 0, value)
        return result

    def createUniformBuffer(self, size, label):
        return Buffer(self.host, self.host.make_buffer(size, True), size, label)

    def writeBuffer(self, buffer, offset, value, data_offset=0, size=None):
        data = binary_bytes(value)
        self.host.upload_buffer(buffer.id, int(offset), data[data_offset:] if size is None else data[data_offset:data_offset+size])

    def begin(self):
        pass

    def submit(self):
        self.host.flush()
        self.submits += 1

    def clearTexture(self, texture):
        self.host.clear_texture(texture.id)

    def writeTexture(self, texture, value, *_):
        self.host.upload_texture(texture.id, binary_bytes(value))

    def clearBuffer(self, buffer, offset=0, size=None):
        self.host.clear_buffer(buffer.id, offset, buffer.size-offset if size is None else int(size))

    def copyTexture(self, source, destination):
        self.host.copy_texture(source.id, destination.id)

    def scratchFor(self, texture):
        if texture.id not in self.scratch:
            self.scratch[texture.id] = self.createTexture(texture.width, texture.height,
                texture.format, texture.label+'_prev')
        return self.scratch[texture.id]

    def readBuffer(self, buffer, size, offset=0):
        return self.host.read_buffer(buffer.id, offset, int(size))

    def readTexture(self, texture, x=0, y=0, width=None, height=None, stride=None):
        return self.host.read_texture(texture.id, x, y, width, height, stride)


class ComputeShader:
    TYPES = {'texture': 2, 'storage-texture': 3, 'uniform': 4, 'storage': 5,
             'read-only-storage': 5, 'sampler': 1}

    def __init__(self, gpu, path):
        self.gpu = gpu
        self.path = path
        self.info = gpu.host.metadata[path]
        gpu.host.load_shader(path)

    def dispatch(self, bindings, parameters, width, height, z=1):
        scratch = {}
        for name in self.info['readWrite']:
            spec = next(item for item in self.info['bindings'] if item['group'] == 0 and item['name'] == name)
            target = bindings.entries.get(spec['binding'])
            if target is not None and isinstance(target[0], Texture):
                copy = self.gpu.scratchFor(target[0])
                self.gpu.copyTexture(target[0], copy)
                scratch[spec['binding']] = copy
        packed = []
        for spec in self.info['bindings']:
            group, binding = spec['group'], spec['binding']
            if group == 1:
                continue
            if group == 3:
                resource, kind = scratch[binding], 2
            else:
                target, sampler = bindings.entries[binding]
                resource = sampler if group == 2 else target
                kind = self.TYPES[spec['kind']]
            packed.extend((group, binding, kind, resource.id))
        workgroup = self.info['workgroup']
        self.gpu.host.dispatch(self.path, packed, parameters.bytes(),
            max(1, -(-int(width) // workgroup[0])), max(1, -(-int(height) // workgroup[1])), max(1, int(z)))
