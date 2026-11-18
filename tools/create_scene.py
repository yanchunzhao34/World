"""通过熔炉资源及场景 API 生成可打开的 Workshop.scene。"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / ".runtime/packages"), str(ROOT / "Assets"), str(ROOT / "Assets/Scripts")]

import infernux as inx
from infernux.core.assets import AssetManager
from infernux.components.component_identity import bind_asset_script_guid
from infernux.lib import RuntimeMode, SceneManager
from workshop_bootstrap import preload_dependencies
DEPENDENCIES = preload_dependencies(ROOT)
from Scripts.Workshop import Workshop


def main():
    frontend = inx.Engine(mode=RuntimeMode.Headless)
    native = frontend.get_native_engine()
    try:
        frontend.init_headless(str(ROOT))
        database = frontend.get_asset_database()
        result = AssetManager.import_asset(str(ROOT / "Assets/Scripts/Workshop.py"), database=database)
        if not result:
            raise RuntimeError(result.error)
        metadata = json.loads((ROOT / "Assets/Scripts/Workshop.py.meta").read_text("utf-8"))
        script_guid = metadata["metadata"]["guid"]["value"]
        bind_asset_script_guid(Workshop, script_guid)
        scene = SceneManager.instance().get_active_scene()
        scene.name = "Workshop"
        for obj in scene.get_root_objects():
            scene.destroy_game_object(obj)
        scene.create_game_object("Element Workshop").add_py_component(Workshop())
        scene.save_to_file(str(ROOT / "Assets/Scenes/Workshop.scene"))
        imported = AssetManager.import_asset(str(ROOT / "Assets/Scenes/Workshop.scene"), database=database)
        if not imported:
            raise RuntimeError(imported.error)
        scene_metadata = json.loads((ROOT / "Assets/Scenes/Workshop.scene.meta").read_text("utf-8"))
        scene_guid = scene_metadata["metadata"]["guid"]["value"]
        (ROOT / "ProjectSettings/BuildSettings.json").write_text(json.dumps(dict(
            game_name="元素工坊", scene_guids=[scene_guid], debug_mode=False,
            icon_guid="", output_dir="", platform_options={}, splash_items=[]),
            ensure_ascii=False, indent=2), "utf-8")
        print("EDITOR_SCENE_CREATED", scene_guid, flush=True)
    finally:
        native.cleanup()


if __name__ == "__main__":
    main()
