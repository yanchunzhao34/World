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

    # 通过宿主释放纹理及其关联绑定。
    def destroy(self, *_):
        self.host.destroy(self.id)


@dataclass
class Buffer:
    host: object
    id: int
    size: int
    label: str

    # 通过宿主释放缓冲及其关联绑定。
    def destroy(self, *_):
        self.host.destroy(self.id)


@dataclass
class Sampler:
    id: int


class DoubleBuffer:
    # 初始化计算阶段的读写资源对。
    def __init__(self, read, write):
        # 读写分离使邻域计算基于同一旧状态，避免原地更新干扰
        self.read, self.write = read, write

    # 交换计算阶段的读写资源角色。
    def swap(self):
        self.read, self.write = self.write, self.read


class Parameters:
    # 初始化着色器整数与浮点参数区。
    def __init__(self, **values):
        self.i = np.zeros(8, dtype='<i4')
        self.f = np.zeros(8, dtype='<f4')

        for name, value in values.items():
            self.set(name, value)

    # 将命名参数写入对应整数或浮点分量。
    def set(self, name, value):
        if name[1] == '0':
            group_offset = 0

        else:
            group_offset = 4

        component_offset = 'xyzw'.index(name[2])
        component_index = group_offset + component_offset

        if name[0] == 'i':
            # 按32位补码截断，保持Python与着色器的整数位模式一致
            unsigned_value = int(value) & 0xFFFFFFFF

            if unsigned_value < 0x80000000:
                signed_value = unsigned_value

            else:
                signed_value = unsigned_value - 0x100000000

            self.i[component_index] = signed_value

        else:
            self.f[component_index] = value

        return self

    # 复制计算参数以便独立调整阶段字段。
    def clone(self):
        result = Parameters()
        result.i[:] = self.i
        result.f[:] = self.f

        return result

    # 按着色器参数布局输出二进制数据。
    def bytes(self):
        return self.i.tobytes() + self.f.tobytes()


class Bindings:
    # 初始化计算管线的资源绑定集合。
    def __init__(self):
        self.entries = {}

    # 登记纹理绑定及其资源标识。
    def image(self, binding, texture):
        self.entries[binding] = (texture, None)

        return self

    # 登记存储缓冲的资源绑定。
    def buffer(self, binding, buffer):
        self.entries[binding] = (buffer, None)

        return self

    # 登记统一参数缓冲的资源绑定。
    def ubo(self, binding, buffer):
        return self.buffer(binding, buffer)

    # 登记采样纹理及其采样器。
    def sampler(self, binding, sampler, texture):
        self.entries[binding] = (texture, sampler)

        return self


# 将数组或字节载荷统一为原始字节。
def binary_bytes(value):
    return value.tobytes() if isinstance(value, np.ndarray) else bytes(value)


class NativeGPU:
    # 初始化模拟模块共用的GPU接入对象。
    def __init__(self, host):
        self.host = host
        self.submits = 0
        self.linearClamp = Sampler(host.make_sampler(True, False))
        self.nearestClamp = Sampler(host.make_sampler(False, False))
        self.linearRepeat = Sampler(host.make_sampler(True, True))
        self.scratch = {}
        self.jobs = []

    # 创建具有显式尺寸和格式的纹理资源。
    def createTexture(self, width, height, format, label, depth=1):
        width, height, depth = int(width), int(height), int(depth)

        return Texture(
            self.host,
            self.host.make_texture(width, height, format, depth),
            width,
            height,
            format,
            label,
            depth,
        )

    # 创建存储缓冲并上传可选初始数据。
    def createStorageBuffer(self, size, value, label):
        size = int(size)
        result = Buffer(self.host, self.host.make_buffer(size, False), size, label)

        if value is not None:
            self.writeBuffer(result, 0, value)

        return result

    # 创建着色器统一参数缓冲。
    def createUniformBuffer(self, size, label):
        return Buffer(self.host, self.host.make_buffer(size, True), size, label)

    # 按字节偏移上传指定缓冲数据。
    def writeBuffer(self, buffer, offset, value, data_offset=0, size=None):
        data = binary_bytes(value)
        buffer_id = buffer.id
        byte_offset = int(offset)

        if size is None:
            upload_data = data[data_offset:]

        else:
            upload_data = data[data_offset : data_offset + size]

        self.host.upload_buffer(buffer_id, byte_offset, upload_data)

    # 保留模拟阶段开始的统一调度接口。
    def begin(self):
        # 宿主按需创建编码器，保留阶段接口以统一模拟调度
        pass

    # 提交GPU命令并推进提交序号。
    def submit(self):
        self.host.flush()

        self.submits += 1

    # 通过宿主清空指定纹理。
    def clearTexture(self, texture):
        self.host.clear_texture(texture.id)

    # 将二进制载荷上传到指定纹理。
    def writeTexture(self, texture, value, *_):
        self.host.upload_texture(texture.id, binary_bytes(value))

    # 清空指定缓冲的全部或部分区域。
    def clearBuffer(self, buffer, offset=0, size=None):
        buffer_id = buffer.id

        if size is None:
            byte_count = buffer.size - offset

        else:
            byte_count = int(size)

        self.host.clear_buffer(buffer_id, offset, byte_count)

    # 通过宿主复制完整纹理。
    def copyTexture(self, source, destination):
        self.host.copy_texture(source.id, destination.id)

    # 取得读写纹理使用的旧状态副本。
    def scratchFor(self, texture):
        if texture.id not in self.scratch:
            self.scratch[texture.id] = self.createTexture(
                texture.width, texture.height, texture.format, texture.label + '_prev'
            )

        return self.scratch[texture.id]

    # 按字节范围读取存储缓冲。
    def readBuffer(self, buffer, size, offset=0):
        return self.host.read_buffer(buffer.id, offset, int(size))

    # 按区域读取纹理原始字节。
    def readTexture(self, texture, x=0, y=0, width=None, height=None, stride=None):
        return self.host.read_texture(texture.id, x, y, width, height, stride)


class ComputeShader:
    TYPES = {
        'texture': 2,
        'storage-texture': 3,
        'uniform': 4,
        'storage': 5,
        'read-only-storage': 5,
        'sampler': 1,
    }

    # 初始化计算着色器及其绑定描述。
    def __init__(self, gpu, path):
        self.gpu = gpu
        self.path = path
        self.info = gpu.host.metadata[path]

        gpu.host.load_shader(path)

    # 准备资源绑定并按工作组尺寸派发计算。
    def dispatch(self, bindings, parameters, width, height, z=1):
        scratch = {}

        # 为读写纹理保留旧副本，避免同一派发读到刚写入的邻格
        for name in self.info['readWrite']:
            binding_spec = next(
                item
                for item in self.info['bindings']
                if item['group'] == 0 and item['name'] == name
            )
            binding_entry = bindings.entries.get(binding_spec['binding'])

            if binding_entry is not None and isinstance(binding_entry[0], Texture):
                previous_texture = self.gpu.scratchFor(binding_entry[0])

                self.gpu.copyTexture(binding_entry[0], previous_texture)

                scratch[binding_spec['binding']] = previous_texture

        binding_packet = []

        for binding_spec in self.info['bindings']:
            group, binding = binding_spec['group'], binding_spec['binding']

            if group == 1:
                # 参数组由宿主注入，避免普通资源绑定覆盖派发参数槽
                continue

            if group == 3:
                resource, kind = scratch[binding], 2

            else:
                binding_entry, sampler = bindings.entries[binding]
                resource = sampler if group == 2 else binding_entry
                kind = self.TYPES[binding_spec['kind']]

            binding_packet.extend((group, binding, kind, resource.id))

        workgroup = self.info['workgroup']

        self.gpu.host.dispatch(
            self.path,
            binding_packet,
            parameters.bytes(),
            max(1, -(-int(width) // workgroup[0])),
            max(1, -(-int(height) // workgroup[1])),
            max(1, int(z)),
        )
