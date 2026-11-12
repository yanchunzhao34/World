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
        row_pitch = (row_bytes + 255) & -256
        texture_offset = cursor
        self.entries[("texture", texture_id, 0, 0, width, height, depth)] = (
            cursor, row_bytes, row_pitch, height * depth)
        cursor += row_pitch * height * depth
        if cursor > self.capacity:
            if self.buffer is not None:
                self.host.flush()
                self.host.device.queue.on_submitted_work_done_sync()
                self.buffer.destroy()
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
            self.host.flush()
            self.buffer.map_sync(wgpu.MapMode.READ, 0, self.size)
            try:
                # Own the bytes before unmapping: published Frames and world
                # snapshots must remain immutable across subsequent GPU writes.
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
