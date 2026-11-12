// Godot RenderingDevice implementation of the original GPU facade.
// No DOM, browser, network service or external process is used at runtime.
/** 保留 TypedArray 的 byteOffset；不能把子视图误当成完整底层缓冲。 */
function bytes(value, offset = 0, count) {
    const buffer = value instanceof ArrayBuffer ? value : value.buffer;
    const start = (value instanceof ArrayBuffer ? 0 : value.byteOffset) + offset;
    return new Uint8Array(buffer, start, count === undefined ? value.byteLength - offset : count);
}
// Jint 中的回调由 nativeFrame 末尾排空，保持原版异步读回回调的执行边界。
const jobs = [];

function queueMicrotask(job) {
    jobs.push(job);
}

function structuredClone(obj) {
    return JSON.parse(JSON.stringify(obj));
}

function jn(key, zh, en) {
    return zh || en || key;
}
/**
 * 最小原版 GPU facade。资源对象只保存整数 ID，真实 RID 由 GpuHost 拥有。
 * submit/readBuffer/readTexture 均经 C# 同步完成；Promise 是原接口形状。
 */
class NativeGPU {
    constructor() {
        this.submits = 0;
        this.limits = {};
        this.linearClamp = {
            id: host.MakeSampler(true, false)
        };
        this.nearestClamp = {
            id: host.MakeSampler(false, false)
        };
        this.linearRepeat = {
            id: host.MakeSampler(true, true)
        };
        this.scratch = new Map();
        this.device = {
            queue: {
                writeBuffer: (buf, offset, value, dataOffset = 0, size) =>
                    host.UploadBuffer(buf.id, offset, bytes(value, dataOffset, size)),
                onSubmittedWorkDone: () => Promise.resolve()
            }
        };
    }
    createTexture(w, h, format, label, depth = 1) {
        const id = host.MakeTexture(w, h, format, depth);
        return {
            id,
            width: w,
            height: h,
            format,
            depthOrArrayLayers: depth,
            label,
            destroy() {
                host.Destroy(id);
            }
        };
    }
    createStorageBuffer(size, value, label) {
        const id = host.MakeBuffer(size, false);
        if (value) host.UploadBuffer(id, 0, bytes(value));
        return {
            id,
            size,
            label,
            destroy() {
                host.Destroy(id);
            }
        };
    }
    createUniformBuffer(size, label) {
        const id = host.MakeBuffer(size, true);
        return {
            id,
            size,
            label,
            destroy() {
                host.Destroy(id);
            }
        };
    }
    begin() {
        host.Begin();
    }
    submit() {
        host.Flush();
        this.submits++;
    }
    clearTexture(tex) {
        host.ClearTexture(tex.id);
    }
    writeTexture(tex, value) {
        host.UploadTexture(tex.id, bytes(value));
    }
    clearBuffer(buf, offset = 0, count) {
        host.ClearBuffer(buf.id, offset, count === undefined ? buf.size - offset : count);
    }
    copyTexture(a, b) {
        host.CopyTexture(a.id, b.id);
    }
    scratchFor(tex) {
        let scratch = this.scratch.get(tex.id);
        if (!scratch) {
            scratch = this.createTexture(tex.width, tex.height, tex.format, tex.label + '_prev');
            this.scratch.set(tex.id, scratch);
        }
        return scratch;
    }
    readBuffer(buf, size, offset = 0) {
        return Promise.resolve(host.ReadBuffer(buf.id, offset, size));
    }
    readTexture(tex, x, y, w, h, stride) {
        return Promise.resolve(host.ReadTexture(tex.id, x, y, w, h, stride));
    }
}
/**
 * 计算着色器适配：绑定元数据 → 临时读写副本 → 参数块 → C# Dispatch。
 * 原版通过 Ve 名称引用此类型，文件末尾保留兼容别名。
 */
class ComputeShader {
    constructor(gpu, path) {
        this.gpu = gpu;
        this.path = path;
        this.info = Ne[path];
        if (!this.info) throw Error('Missing original shader metadata: ' + path);
        host.LoadShader(path);
    }
    dispatch(bindings, params, width, height, z = 1) {
        // WebGPU 读写纹理在 SPIR-V 中拆为独立输入/输出，先复制旧值供只读绑定使用。
        const scratch = new Map();
        for (const name of this.info.readWrite) {
            const spec = this.info.bindings.find(v => v.group === 0 && v.name === name);
            const target = spec && bindings.e.get(spec.binding);
            if (target && target.tex) {
                const copy = this.gpu.scratchFor(target.tex);
                this.gpu.copyTexture(target.tex, copy);
                scratch.set(spec.binding, copy);
            }
        }
        // 每四个整数：group、binding、类型编号、资源 ID。编号与 GpuHost.Dispatch 对应。
        const flat = [];
        const types = {
            'texture': 2,
            'storage-texture': 3,
            'uniform': 4,
            'storage': 5,
            'read-only-storage': 5,
            'sampler': 1
        };
        for (const spec of this.info.bindings) {
            if (spec.group === 1) continue;
            let target, type;
            if (spec.group === 3) {
                target = scratch.get(spec.binding);
                type = 2;
            } else {
                const value = bindings.e.get(spec.binding);
                if (!value) throw Error(this.path + ': missing ' + spec.name);
                target = spec.group === 2 ? value.smp : value.tex || value.buf;
                type = types[spec.kind];
            }
            flat.push(spec.group, spec.binding, type, target.id);
        }
        // 前 32 字节为 8 个 int，后 32 字节为 8 个 float，不能改变偏移与长度。
        const push = new ArrayBuffer(64);
        new Int32Array(push).set(params.i);
        new Float32Array(push).set(params.f, 8);
        host.Dispatch(this.path, new Int32Array(flat), new Uint8Array(push),
            Math.max(1, Math.ceil(width / this.info.workgroup[0])),
            Math.max(1, Math.ceil(height / this.info.workgroup[1])), Math.max(1, z));
    }
}

// 与 original_core.js 中保留的发布包类名衔接。
const Ve = ComputeShader;
