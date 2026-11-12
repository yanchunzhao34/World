"""Prepare native libraries through Infernux's explicit preload lifecycle."""

import infernux as inx


class WorkshopDependencies(inx.InxPreload):
    def preload(self, context):
        context.own_python_library("runtime/library")
        from .library import dependencies

        self.dependencies = dependencies

    def unload(self):
        self.dependencies = None
