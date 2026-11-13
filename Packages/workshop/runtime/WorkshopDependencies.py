"""Prepare native libraries through Infernux's explicit preload lifecycle."""

import infernux as inx


class WorkshopDependencies(inx.InxPreload):
    # 通过熔炉预载生命周期持有项目依赖。
    def preload(self, context):
        # 依赖由预载包持有，避免组件重载拆散第三方模块状态
        context.own_python_library("runtime/library")

        from .library import dependencies

        self.dependencies = dependencies

    # 释放预载包持有的依赖模块引用。
    def unload(self):
        self.dependencies = None
