"""Use the same dependency lifecycle in standalone tools as in the Editor."""

from infernux.plugins.preload import PreloadManager


def preload_dependencies(root):
    manager = PreloadManager(str(root), runtime=True)
    states = manager.reload_path(str(root / "Packages/workshop/runtime/WorkshopDependencies.py"))
    if not states or any(not state.loaded for state in states):
        errors = [state.error for state in states if state.error]
        raise RuntimeError("Workshop dependencies failed to preload: " + repr(errors or manager.failures))
    return manager
