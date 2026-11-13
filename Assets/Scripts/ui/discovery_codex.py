"""图鉴模型。条目、分类与累计 GPU 计数增量沿用原逻辑。"""

KINDS = ["反应", "燃烧", "熔化", "沸腾", "凝固", "冷凝"]


class DiscoveryCodex:
    def __init__(self, data):
        self.data = data
        self.entries, self.found, self.previous = [], set(), {}
        self.revision = -1
        self.by_key = {m["key"]: m["id"] for m in data["materials"]}
        # 从材料与反应规则派生条目，避免图鉴与实验规则分别维护
        for index, reaction in enumerate(data["reactions"]):
            if reaction["hidden"]:
                continue
            outputs = []
            for key in (reaction["outA"], reaction["outB"]):
                identifier = self.id_of(key)
                if identifier > 0 and identifier not in outputs and key not in (reaction["a"], reaction["b"]):
                    outputs.append(identifier)
            self.add("r:" + reaction["key"], 0,
                [self.id_of(reaction["a"]), self.id_of(reaction["b"])],
                outputs or [self.id_of(reaction["outA"])], index, -1)
        for material in data["materials"]:
            identifier, key = material["id"], material["key"]
            if material["flags"] & 1:
                output = self.id_of(material["burnTo"])
                self.add("ign:" + key, 1, [identifier], [output] if output > 0 else [], -1, identifier)
            high, low = self.id_of(material["hiTo"]), self.id_of(material["loTo"])
            if material["hiTemp"] > 0 and high >= 0:
                kind = 3 if material["state"] == "Liquid" and data["materials"][high]["state"] == "Gas" else 2
                outputs = [high]
                if self.id_of(material["residue"]) > 0:
                    outputs.append(self.id_of(material["residue"]))
                self.add("hi:" + key, kind, [identifier], outputs, -1, identifier)
            if material["loTemp"] > 0 and low >= 0:
                self.add("lo:" + key, 5 if material["state"] == "Gas" else 4,
                         [identifier], [low], -1, identifier)

    def add(self, identifier, kind, inputs, outputs, reaction, material):
        self.entries.append(dict(id=identifier, kind=kind, inputs=inputs,
                                 outputs=outputs, reaction=reaction, material=material))

    def id_of(self, key):
        return self.by_key.get(key, -1)

    def name_of(self, identifier):
        return self.data["materials"][identifier]["zh"] if identifier >= 0 else "?"

    def title(self, entry):
        if entry["kind"] == 0:
            return " + ".join(self.name_of(i) for i in entry["inputs"])
        return self.name_of(entry["material"]) + KINDS[entry["kind"]]

    def description(self, entry):
        if entry["kind"] == 0:
            return self.data["reactions"][entry["reaction"]]["zh"]
        material = self.data["materials"][entry["material"]]
        kind = entry["kind"]
        if kind == 1:
            return (f'{material["zh"]}在 {round(material["igniteTemp"] - 273)}°C 以上燃烧'
                    + ("，变成" + self.name_of(entry["outputs"][0]) if entry["outputs"] else "，逐渐烧尽")
                    + ("，可能发生爆炸" if material["flags"] & 2 else ""))
        threshold = material["hiTemp" if kind in (2, 3) else "loTemp"]
        return (f'{material["zh"]}在 {round(threshold - 273)}°C '
                + ("以下" if kind in (4, 5) else "") + "变为"
                + "、".join(self.name_of(i) for i in entry["outputs"]))

    def hint(self, entry):
        if entry["kind"] == 0:
            return self.name_of(entry["inputs"][0]) + " + ?"
        return self.name_of(entry["material"]) + ["", "可以燃烧", "加热会怎样？", "加热会怎样？",
                                                  "冷却会怎样？", "冷却会怎样？"][entry["kind"]]

    def for_material(self, identifier):
        return [entry for entry in self.entries if identifier in entry["inputs"]]

    def count_found(self, entries=None):
        return sum(e["id"] in self.found for e in (self.entries if entries is None else entries))

    def update(self, state):
        counters = {"r": state.get("reactions", []), "ig": state.get("ignite", []),
                    "hi": state.get("phase_hi", []), "lo": state.get("phase_lo", [])}
        changed = False
        revision = state.get("scene_revision", 0)
        # 仅比较同一场景版本的累计增量，避免切图时误解锁图鉴
        if self.previous and self.revision == revision:
            for entry in self.entries:
                key = ["r", "ig", "hi", "hi", "lo", "lo"][entry["kind"]]
                index = entry["reaction"] if entry["kind"] == 0 else entry["material"]
                if (entry["id"] not in self.found and index < len(counters[key])
                        and index < len(self.previous[key]) and counters[key][index] > self.previous[key][index]):
                    self.found.add(entry["id"])
                    changed = True
        self.previous, self.revision = counters, revision
        return changed
