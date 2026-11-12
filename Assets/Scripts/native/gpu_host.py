"""后台 GPU 资源所有者，接口与原有 GpuHost 一致。

Infernux 0.4.1 的公开 compute API 仅接受 buffer。现有算法依赖整数、
半精度和三维 storage texture，因此保留独立 Vulkan 计算设备的架构，
通过 wgpu-native 驱动同一套 WGSL，结果交给 Infernux 显示。
"""

import os
from pathlib import Path

from _infernux_packages.workshop.runtime.library.dependencies import wgpu

from .gpu_host_storage import Storage
from .gpu_host_shaders import ShaderPipelines
from .gpu_readback import FrameReadback


STRIDES = {"rgba32uint": 16, "rgba32float": 16, "rgba16float": 8,
           "rgba8unorm": 4, "rgba8uint": 4, "r32float": 4}


class GpuHost(Storage, ShaderPipelines):
    def __init__(self, assets, save_directory, *, lighting_corrections=True):
        super().__init__(assets, save_directory)
        os.environ.setdefault("WGPU_BACKEND_TYPE", "Vulkan")
        self.assets = Path(assets)
        self.lighting_corrections = lighting_corrections
        self.adapter = wgpu.gpu.request_adapter_sync(power_preference="high-performance")
        features = [name for name in ("float32-filterable",) if name in self.adapter.features]
        self.device = self.adapter.request_device_sync(required_features=features,
            required_limits={"max-storage-buffer-binding-size": 134217728,
                             "max-buffer-size": 268435456})
        self.resources = {}
        self.dimensions = {}
        self.views = {}
        self.shaders = {}
        self.metadata = {}
        self.bind_groups = {}
        self.dispatch_bindings = {}
        self.parameters = []
        self.parameter_index = 0
        self.encoder = None
        self.compute_pass = None
        self.dispatches = 0
        self.next_id = 1
        self.last_error = None
        self.readback = FrameReadback(self)

    def add(self, resource):
        identifier = self.next_id
        self.next_id += 1
        self.resources[identifier] = resource
        return identifier

    def commands(self):
        if self.compute_pass is not None:
            self.compute_pass.end()
            self.compute_pass = None
        if self.encoder is None:
            self.encoder = self.device.create_command_encoder()
        return self.encoder

    def compute_commands(self):
        if self.compute_pass is None:
            self.compute_pass = self.commands().begin_compute_pass(label="Workshop compute")
        return self.compute_pass

    def make_texture(self, width, height, format, depth):
        usage = (wgpu.TextureUsage.COPY_SRC | wgpu.TextureUsage.COPY_DST
                 | wgpu.TextureUsage.TEXTURE_BINDING | wgpu.TextureUsage.STORAGE_BINDING)
        texture = self.device.create_texture(size=(width, height, depth),
            dimension="3d" if depth > 1 else "2d", format=format, usage=usage)
        identifier = self.add(texture)
        self.dimensions[identifier] = (width, height, depth, STRIDES[format])
        self.views[identifier] = texture.create_view()
        # WebGPU guarantees zero-initialized resources, including every channel.
        return identifier

    def make_buffer(self, size, uniform):
        usage = wgpu.BufferUsage.UNIFORM if uniform else wgpu.BufferUsage.STORAGE
        return self.add(self.device.create_buffer(size=max(16, (size + 15) & -16),
            usage=usage | wgpu.BufferUsage.COPY_DST | wgpu.BufferUsage.COPY_SRC))

    def make_sampler(self, linear, repeat):
        filtering = "linear" if linear else "nearest"
        addressing = "repeat" if repeat else "clamp-to-edge"
        return self.add(self.device.create_sampler(mag_filter=filtering, min_filter=filtering,
            address_mode_u=addressing, address_mode_v=addressing))

    def upload_buffer(self, identifier, offset, data):
        self.readback.invalidate()
        self.flush()
        self.device.queue.write_buffer(self.resources[identifier], offset, data)

    def upload_texture(self, identifier, data):
        self.readback.invalidate()
        self.flush()
        width, height, depth, stride = self.dimensions[identifier]
        if len(data) != width * height * depth * stride:
            raise ValueError("Texture upload has incorrect byte length")
        self.device.queue.write_texture({"texture": self.resources[identifier]}, data,
            {"bytes_per_row": width * stride, "rows_per_image": height}, (width, height, depth))

    def clear_texture(self, identifier):
        width, height, depth, stride = self.dimensions[identifier]
        self.upload_texture(identifier, bytes(width * height * depth * stride))

    def clear_buffer(self, identifier, offset, size):
        self.readback.invalidate()
        self.commands().clear_buffer(self.resources[identifier], offset, size)

    def copy_texture(self, source, destination):
        self.readback.invalidate()
        width, height, depth, _ = self.dimensions[source]
        self.commands().copy_texture_to_texture({"texture": self.resources[source]},
            {"texture": self.resources[destination]}, (width, height, depth))

    def flush(self):
        if self.encoder is not None:
            self.device.queue.submit([self.commands().finish()])
            self.encoder = None
        self.parameter_index = 0

    def read_buffer(self, identifier, offset, size):
        data = self.readback.read(("buffer", identifier, offset, size))
        if data is not None:
            return data
        self.flush()
        return bytes(self.device.queue.read_buffer(self.resources[identifier], offset, size))

    def read_texture(self, identifier, x=0, y=0, width=None, height=None, stride=None):
        tw, th, depth, pixel_stride = self.dimensions[identifier]
        width, height = width or tw, height or th
        if stride is not None and stride != pixel_stride:
            raise ValueError("Texture stride mismatch")
        layers = depth if width == tw and height == th else 1
        data = self.readback.read(("texture", identifier, x, y, width, height, layers))
        if data is not None:
            return data
        self.flush()
        return bytes(self.device.queue.read_texture(
            {"texture": self.resources[identifier], "origin": (x, y, 0)},
            {"bytes_per_row": width * pixel_stride, "rows_per_image": height},
            (width, height, layers)))

    def queue_frame_readbacks(self, stats, stats_size, occupancy, occupancy_size,
                             owners, owners_size, output):
        self.readback.stage([(stats, stats_size), (occupancy, occupancy_size),
                             (owners, owners_size)], output)

    def destroy(self, identifier):
        self.readback.invalidate()
        self.flush()
        # Bind groups retain their resources, so invalidate cached descriptors first.
        self.bind_groups.clear()
        self.dispatch_bindings.clear()
        resource = self.resources.pop(identifier, None)
        self.views.pop(identifier, None)
        self.dimensions.pop(identifier, None)
        if resource is not None and hasattr(resource, "destroy"):
            resource.destroy()

    def close(self):
        self.flush()
        self.device.queue.on_submitted_work_done_sync()
        self.readback.close()
        self.bind_groups.clear()
        self.dispatch_bindings.clear()
        self.shaders.clear()
        self.views.clear()
        for resource in [*self.parameters, *self.resources.values()]:
            if hasattr(resource, "destroy"):
                resource.destroy()
        self.resources.clear()
        self.parameters.clear()
        self.device.destroy()
