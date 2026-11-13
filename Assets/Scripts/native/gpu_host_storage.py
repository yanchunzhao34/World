"""资源读取和兼容 Godot quick.ewsave 的原子存档。"""

import json
import os
from pathlib import Path

from _infernux_packages.workshop.runtime.library.dependencies import (
    gzip,
    tempfile,
    zipfile,
)

from .world_layout import WIDTH, HEIGHT, CELL_BYTES, BACKGROUND_BYTES


class Storage:
    # 初始化资源目录和快速存档位置。
    def __init__(self, assets, save_directory):
        self.data_directory = (Path(assets) / "original/data").resolve()
        self.save_directory = Path(save_directory)
        self.saved = None

    # 在项目数据目录范围内读取资源。
    def read_file(self, relative):
        # 解析真实路径后限定范围，避免资源名越过数据目录
        path = (self.data_directory / relative).resolve()

        if not path.is_relative_to(self.data_directory):
            raise ValueError("Invalid asset path")

        data = path.read_bytes()

        return gzip.decompress(data) if data.startswith(b"\x1f\x8b") else data

    # 校验世界布局并原子写入快速存档。
    def save_state(self, map_key, time, cells, background):
        if len(cells) != CELL_BYTES or len(background) != BACKGROUND_BYTES:
            raise ValueError("Invalid state dimensions")

        self.save_directory.mkdir(parents=True, exist_ok=True)

        # 临时文件与存档同目录，保证最终替换处于同一文件系统
        descriptor, temporary = tempfile.mkstemp(suffix=".tmp", dir=self.save_directory)

        try:
            with os.fdopen(descriptor, "wb") as stream:
                with zipfile.ZipFile(
                    stream, "w", compression=zipfile.ZIP_DEFLATED
                ) as archive:
                    archive.writestr("cells.bin", cells)
                    archive.writestr("background.bin", background)
                    archive.writestr(
                        "info.json",
                        json.dumps(
                            dict(
                                version=1,
                                map=map_key,
                                time=time,
                                width=WIDTH,
                                height=HEIGHT,
                            )
                        ),
                    )

                # 持久化后再替换，降低写入中断时损坏原存档的风险
                stream.flush()
                os.fsync(stream.fileno())

            os.replace(temporary, self.save_directory / "quick.ewsave")

        finally:
            Path(temporary).unlink(missing_ok=True)

    # 验证存档条目并载入可恢复的世界数据。
    def load_saved_info(self):
        with zipfile.ZipFile(self.save_directory / "quick.ewsave") as archive:
            payload = {}

            # 按布局限制解压大小，避免异常存档占用过量内存
            for name, limit in (
                ("cells.bin", CELL_BYTES),
                ("background.bin", BACKGROUND_BYTES),
                ("info.json", 4096),
            ):
                if archive.getinfo(name).file_size > limit:
                    raise ValueError("Save entry too large")

                payload[name] = archive.read(name)

        info = json.loads(payload["info.json"])

        if (
            len(payload["cells.bin"]) != CELL_BYTES
            or len(payload["background.bin"]) != BACKGROUND_BYTES
            or info.get("width") != WIDTH
            or info.get("height") != HEIGHT
            or info.get("version") != 1
        ):
            raise ValueError("Invalid save dimensions or version")

        # 完整校验后再发布载荷，避免读取失败留下半份状态
        self.saved = payload

        return json.dumps(info)
