"""对应 GpuHost.Shaders.cs，拥有计算管线、描述符和派发逻辑。"""

from _infernux_packages.workshop.runtime.library.dependencies import re, wgpu

from .lighting_shaders import lighting_shader_source


class ShaderPipelines:
    def load_shader(self, path):
        if path in self.shaders:
            return
        spec = self.metadata[path]
        source = (self.assets / "original/shaders" / path.replace(".comp", ".wgsl")).read_text("utf-8")
        if self.lighting_corrections:
            source = lighting_shader_source(self.assets, path, source)
        # Apply precisely the existing Godot converter's atomic-load compatibility fix.
        for name in re.findall(r"var<workgroup> (\w+): atomic<", source):
            source = source.replace(f"workgroupUniformLoad((&{name}))", f"atomicLoad((&{name}))")
        module = self.device.create_shader_module(label=path, code=source)
        layouts = []
        for group in range(4):
            entries = []
            for binding in spec["bindings"]:
                if binding["group"] != group:
                    continue
                entry = dict(binding=binding["binding"], visibility=wgpu.ShaderStage.COMPUTE)
                kind = binding["kind"]
                if kind in ("uniform", "storage", "read-only-storage"):
                    entry["buffer"] = {"type": kind}
                elif kind == "sampler":
                    entry["sampler"] = {"type": "filtering"}
                elif kind == "storage-texture":
                    entry["storage_texture"] = dict(access=binding["access"],
                        format=binding["format"], view_dimension=binding["dim"])
                else:
                    entry["texture"] = dict(sample_type=binding.get("sampleType", "float"),
                                            view_dimension=binding["dim"])
                entries.append(entry)
            layouts.append(self.device.create_bind_group_layout(entries=entries))
        layout = self.device.create_pipeline_layout(bind_group_layouts=layouts)
        pipeline = self.device.create_compute_pipeline(label=path, layout=layout,
            compute={"module": module, "entry_point": "main"})
        self.shaders[path] = pipeline, layouts

    def dispatch(self, path, packed, parameters, x, y, z):
        self.readback.invalidate()
        self.load_shader(path)
        if self.parameter_index == len(self.parameters):
            self.parameters.append(self.device.create_buffer(size=64,
                usage=wgpu.BufferUsage.UNIFORM | wgpu.BufferUsage.COPY_DST))
        parameter = self.parameters[self.parameter_index]
        self.parameter_index += 1
        self.device.queue.write_buffer(parameter, 0, parameters)
        pipeline, layouts = self.shaders[path]
        dispatch_key = path, tuple(packed), self.parameter_index
        bindings = self.dispatch_bindings.get(dispatch_key)
        if bindings is None:
            groups = {group: [] for group in range(4)}
            identifiers = {group: [] for group in range(4)}
            for group, binding, kind, identifier in zip(*[iter(packed)] * 4):
                resource = self.resources[identifier]
                value = ({"buffer": resource} if kind in (4, 5)
                         else self.views[identifier] if kind in (2, 3) else resource)
                groups[group].append({"binding": binding, "resource": value})
                identifiers[group].append((binding, identifier))
            if any(b["group"] == 1 for b in self.metadata[path]["bindings"]):
                groups[1] = [{"binding": 0, "resource": {"buffer": parameter}}]
                identifiers[1] = [(0, self.parameter_index)]
            bindings = []
            for group in range(4):
                key = path, group, tuple(identifiers[group])
                if key not in self.bind_groups:
                    self.bind_groups[key] = self.device.create_bind_group(
                        layout=layouts[group], entries=groups[group])
                bindings.append(self.bind_groups[key])
            self.dispatch_bindings[dispatch_key] = bindings
        compute = self.compute_commands()
        compute.set_pipeline(pipeline)
        for group, binding in enumerate(bindings):
            compute.set_bind_group(group, binding)
        compute.dispatch_workgroups(x, y, z)
        self.dispatches += 1

