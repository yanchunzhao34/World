"""Infernux RenderStack 的最终呈现，保留原 present.gdshader 公式。"""

import numpy as np
import infernux as inx
from infernux.core.assets import AssetManager
from infernux.renderstack import RenderPipeline, RenderStack
from infernux.renderstack.render_stack_pipeline import RenderStackPipeline


class WorkshopPipeline(RenderPipeline):
    name = "Element Workshop Present Pipeline"

    # 声明游戏图像在熔炉中的最终呈现通道。
    def define_topology(self, graph):
        pixels = graph.import_buffer("workshop_frame", self.pixels)
        state = graph.import_buffer("workshop_view", self.state)
        output = graph.create_texture("color", camera_target=True)

        with graph.add_pass("Workshop Present") as render_pass:
            render_pass.set_buffer("_Frame", pixels)
            render_pass.set_buffer("_State", state)
            render_pass.write_color(output)
            render_pass.fullscreen_quad("Element Workshop Present")

        with graph.add_present_pass("Present") as render_pass:
            render_pass.present(output)


class Presentation:
    # 初始化熔炉显示缓冲与呈现管线。
    def __init__(self, frontend, scene, root, scene_owned=False):
        self.frontend = frontend
        self.scene_owned = scene_owned
        self.capacity = 1536 * 864
        self.pixels = inx.buffer(shape=self.capacity, dtype=np.uint32, device="gpu")
        self.state = inx.buffer(shape=16, dtype=np.uint32, device="gpu")
        imported = AssetManager.import_asset(
            str(root / "Assets/Shaders/WorkshopPresent.frag"),
            database=frontend.get_asset_database(),
        )

        if not imported:
            raise RuntimeError(imported.error)

        self.stack = RenderStack()

        scene.create_game_object("Workshop Presentation").add_py_component(self.stack)
        self.stack.set_pipeline(WorkshopPipeline.name)

        self.stack.pipeline.pixels = self.pixels
        self.stack.pipeline.state = self.state

        frontend.set_render_pipeline(RenderStackPipeline())

        self.last_frame = None
        self.last_dimensions = None

    # 上传新画面及当前视口的显示参数。
    def update(self, frame, width, height):
        if frame is None and self.last_dimensions == (width, height):
            # 画面和视口都未变化时复用显示状态，减少重复上传
            return

        if frame is not None:
            self.last_frame = frame
            values = np.frombuffer(frame.pixels, dtype="<u4")

            if values.size > self.capacity:
                self.capacity = values.size
                old = self.pixels
                self.pixels = inx.buffer(
                    shape=self.capacity, dtype=np.uint32, device="gpu"
                )
                self.stack.pipeline.pixels = self.pixels

                self.stack.invalidate_graph()
                old.close()

            # 仅扩容可复用小尺寸调试视图，避免切换时反复分配
            self.pixels.set_data(values, offset=0)

        if self.last_frame is None:
            return

        self.last_dimensions = width, height
        current = self.last_frame
        state = current.state
        packed = np.zeros(16, dtype=np.uint32)
        packed[:2] = current.width, current.height
        floats = packed.view(np.float32)
        floats[2:4] = width, height
        floats[4:6] = state["camera_size"]
        floats[6:8] = state["camera_center"]
        floats[8:13] = [
            state["zoom"],
            state["vignette"],
            state["grain"],
            state["chroma"],
            state["time"],
        ]
        packed[13] = state["view_mode"]

        self.state.set_data(packed)

    # 结束呈现生命周期并释放显示缓冲。
    def close(self):
        # 场景组件由编辑器销毁，提前释放会打断其生命周期
        if not getattr(self, "scene_owned", True):
            self.stack.on_destroy()

        self.frontend.set_render_pipeline(RenderStackPipeline())
        self.pixels.close()
        self.state.close()
