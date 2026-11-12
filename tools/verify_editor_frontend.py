"""Exercise both strict editor preflight and its isolated candidate importer."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Assets"))

from workshop_bootstrap import preload_dependencies
from Infernux.engine.candidate_import import CandidateImportTransaction
from Infernux.engine.project_context import (
    get_script_module_name, is_project_component_script, set_project_root,
)
from Infernux.engine.script_change_collector import ScriptChangeCollector


def main():
    dependencies = preload_dependencies(ROOT)
    set_project_root(str(ROOT))
    paths = sorted(path for folder in ("Assets/Scripts", "Packages/workshop")
                   for path in (ROOT / folder).rglob("*.py")
                   if is_project_component_script(str(path)))
    collector = ScriptChangeCollector()
    try:
        for path in paths:
            collector.submit(str(path), path.read_bytes(), origin="initial_scan",
                             change_kind="initial_scan")
        results = collector.process_worker_batch()
        failures = [result for result in results if not result.succeeded]
        assert not failures, failures
        transaction = CandidateImportTransaction()
        for path in paths:
            transaction.register(get_script_module_name(str(path)), str(path), source=path.read_bytes())
        for path in paths:
            transaction.load(get_script_module_name(str(path)))
        runtime = transaction.module_for("Scripts.native.game_runtime")
        payload = bytes(range(256)) * 2
        assert runtime.decode_binary(runtime.encode_binary(payload)) == payload
        report = {"script_preflight": len(results), "isolated_imports": len(paths),
                  "binary_bridge": "all 256 byte values round-trip", "passed": True}
        (ROOT / "validation/editor-frontend.json").write_text(
            json.dumps(report, indent=2), encoding="utf-8")
        print("EDITOR_FRONTEND_AND_IMPORT_PASS", len(paths), flush=True)
    finally:
        collector.shutdown()
        dependencies.unload_all()


if __name__ == "__main__":
    main()
