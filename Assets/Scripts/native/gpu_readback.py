"""One reusable staging buffer for a completed simulation/render boundary."""

from _infernux_packages.workshop.runtime.library.dependencies import wgpu


class FrameReadback:
    # 初始化帧末读回缓冲与布局缓存。
    def __init__(self, host):
        self.host = host
        self.buffer = None
        self.capacity = 0
        self.size = 0
        self.entries = {}
        self.data = None

    # 使已缓存的帧末读回结果失效。
    def invalidate(self):
        self.entries.clear()

        self.data = None

    # 安排本帧缓冲和图像的合并读回布局。
    def stage(self, buffers, texture_id):
        self.invalidate()

        buffer_copies, staging_offset = [], 0

        for identifier, size in buffers:
            if size <= 0:
                continue

            key = ("buffer", identifier, 0, size)
            self.entries[key] = (staging_offset, size, size, 1)

            buffer_copies.append((identifier, staging_offset, size))

            staging_offset = (staging_offset + size + 255) & -256

        texture_width, texture_height, texture_depth, pixel_stride = (
            self.host.dimensions[texture_id]
        )
        row_bytes = texture_width * pixel_stride

        # GPU纹理拷贝要求256字节行对齐，读回时再去除填充
        row_pitch = (row_bytes + 255) & -256
        texture_offset = staging_offset
        self.entries[
            ("texture", texture_id, 0, 0, texture_width, texture_height, texture_depth)
        ] = (staging_offset, row_bytes, row_pitch, texture_height * texture_depth)
        staging_offset += row_pitch * texture_height * texture_depth

        if staging_offset > self.capacity:
            if self.buffer is not None:
                self.host.flush()

                # 等待旧拷贝完成，避免销毁仍在使用的读回缓冲
                self.host.device.queue.on_submitted_work_done_sync()
                self.buffer.destroy()

            # 按幂次扩容，减少视口变化引起的缓冲重建
            self.capacity = 1 << (staging_offset - 1).bit_length()
            self.buffer = self.host.device.create_buffer(
                label="Workshop frame readback",
                size=self.capacity,
                usage=wgpu.BufferUsage.COPY_DST | wgpu.BufferUsage.MAP_READ,
            )

        self.size = staging_offset
        commands = self.host.commands()

        for identifier, offset, size in buffer_copies:
            commands.copy_buffer_to_buffer(
                self.host.resources[identifier], 0, self.buffer, offset, size
            )

        commands.copy_texture_to_buffer(
            {"texture": self.host.resources[texture_id]},
            {
                "buffer": self.buffer,
                "offset": texture_offset,
                "bytes_per_row": row_pitch,
                "rows_per_image": texture_height,
            },
            (texture_width, texture_height, texture_depth),
        )

    # 映射一次帧末数据并按请求提取字节。
    def read(self, key):
        layout_entry = self.entries.get(key)

        if layout_entry is None:
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

        offset, row_bytes, row_pitch, row_count = layout_entry

        if row_bytes == row_pitch:
            return self.data[offset : offset + row_bytes * row_count]

        view = memoryview(self.data)

        return b"".join(
            view[offset + row * row_pitch : offset + row * row_pitch + row_bytes]
            for row in range(row_count)
        )

    # 释放读回缓冲及其缓存状态。
    def close(self):
        self.invalidate()

        if self.buffer is not None:
            self.buffer.destroy()

            self.buffer = None
