"""Prepare native libraries through Infernux's explicit preload lifecycle."""

import infernux as inx


class WorkshopDependencies(inx.InxPreload):
    def preload(self, context):
        # 依赖由预载包持有，避免组件重载拆散第三方模块状态
        context.own_python_library("runtime/library")
        from .library import dependencies

        self.dependencies = dependencies

    def unload(self):
        self.dependencies = None
