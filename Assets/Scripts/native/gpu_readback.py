"""One reusable staging buffer for a completed simulation/render boundary."""

from _infernux_packages.workshop.runtime.library.dependencies import wgpu


class FrameReadback:
    def __init__(self, host):
        self.host = host
        self.buffer = None
        self.capacity = 0
        self.size = 0
        self.entries = {}
        self.data = None

    def invalidate(self):
        self.entries.clear()
        self.data = None

    def stage(self, buffers, texture_id):
        self.invalidate()
        copies, cursor = [], 0
        for identifier, size in buffers:
            if size <= 0:
                continue
            key = ("buffer", identifier, 0, size)
            self.entries[key] = (cursor, size, size, 1)
            copies.append((identifier, cursor, size))
            cursor = (cursor + size + 255) & -256
        width, height, depth, stride = self.host.dimensions[texture_id]
        row_bytes = width * stride
        # GPU纹理拷贝要求256字节行对齐，读回时再去除填充
        row_pitch = (row_bytes + 255) & -256
        texture_offset = cursor
        self.entries[("texture", texture_id, 0, 0, width, height, depth)] = (
            cursor, row_bytes, row_pitch, height * depth)
        cursor += row_pitch * height * depth
        if cursor > self.capacity:
            if self.buffer is not None:
                self.host.flush()
                # 等待旧拷贝完成，避免销毁仍在使用的读回缓冲
                self.host.device.queue.on_submitted_work_done_sync()
                self.buffer.destroy()
            # 按幂次扩容，减少视口变化引起的缓冲重建
            self.capacity = 1 << (cursor - 1).bit_length()
            self.buffer = self.host.device.create_buffer(
                label="Workshop frame readback", size=self.capacity,
                usage=wgpu.BufferUsage.COPY_DST | wgpu.BufferUsage.MAP_READ)
        self.size = cursor
        commands = self.host.commands()
        for identifier, offset, size in copies:
            commands.copy_buffer_to_buffer(self.host.resources[identifier], 0,
                                           self.buffer, offset, size)
        commands.copy_texture_to_buffer(
            {"texture": self.host.resources[texture_id]},
            {"buffer": self.buffer, "offset": texture_offset,
             "bytes_per_row": row_pitch, "rows_per_image": height},
            (width, height, depth))

    def read(self, key):
        entry = self.entries.get(key)
        if entry is None:
            return None
        if self.data is None:
            # 同批数据共享一次映射，减少CPU等待GPU的次数
            self.host.flush()
            self.buffer.map_sync(wgpu.MapMode.READ, 0, self.size)
            try:
                # 解除映射前复制字节，避免已发布帧随缓冲复用而改变
                self.data = bytes(self.buffer.read_mapped(copy=False))
            finally:
                self.buffer.unmap()
        offset, row_bytes, row_pitch, rows = entry
        if row_bytes == row_pitch:
            return self.data[offset:offset + row_bytes * rows]
        view = memoryview(self.data)
        return b"".join(view[offset + row * row_pitch:offset + row * row_pitch + row_bytes]
                        for row in range(rows))

    def close(self):
        self.invalidate()
        if self.buffer is not None:
            self.buffer.destroy()
            self.buffer = None
