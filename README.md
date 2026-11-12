# 元素工坊 · 熔炉移植

移植基准为 `D:\godot_project\元素工坊` 的当前工程，目标环境为 Windows、Infernux 0.4.1、Python 3.13 和 Vulkan。

## 从 GitHub 获取工程

```powershell
git clone https://github.com/yanchunzhao34/World.git
cd World
```

仓库包含游戏脚本、场景、着色器、地图素材、项目配置、验证工具及图像对照基准。熔炉引擎、Python 环境和第三方库由本机安装提供，版本要求记录在 `.infernux-version`、`ProjectSettings/PythonRuntime.json` 和 `requirements.txt`。

在熔炉 Hub 中准备 Infernux 0.4.1 的 Python 3.13 环境，然后打开克隆得到的工程目录。使用该环境安装项目依赖并启动游戏。

```powershell
$workshopPython = 'D:\你的熔炉Python环境\python.exe'
& $workshopPython -m pip install -r requirements.txt
$env:INFERNUX_PYTHON = $workshopPython
.\StartGame.bat
```

工程本地已有 `.runtime/python313/python.exe` 时，也可直接使用下一节的命令。`Packages/workshop/` 是游戏自己的依赖预加载代码，需要随源码保存。`.gitignore` 排除了 `.runtime/`、`Library/`、`Cache/`、`Logs/`、引擎插件安装目录、个人存档和编辑器本机状态。`.gitattributes` 保留文件原始字节，保证来源校验哈希在克隆后仍然有效。

## 运行

双击 `StartGame.bat`。启动器优先使用本工程的 `.runtime/python313/python.exe`。也可设置 `INFERNUX_PYTHON` 指向安装了 Infernux 的 Python 3.13。

Windows 启动时会在创建窗口前设置 Per-Monitor V2 DPI 上下文，兼容由 Anaconda 等父启动器继承的高 DPI 设置。关闭游戏时会先停止模拟和音频、释放 GPU 与熔炉资源，再按熔炉独立播放器的方式退出进程。

```powershell
& '.\.runtime\python313\python.exe' launch.py
```

熔炉编辑器打开本目录后，双击 `Assets/Scenes/Workshop.scene`，再点播放。播放会切换到“游戏”视图，界面和输入限定在该视图内；停止后恢复编辑场景。默认的未命名场景只有相机和灯光，不包含游戏入口。场景组件与独立启动器共用 `WorkshopSession`。

首次在新的 Python 环境部署时，先执行：

```powershell
& '.\.runtime\python313\python.exe' -m pip install -r requirements.txt
```

依赖安装或预加载配置修改后，重新打开编辑器。QuickJS-NG 的导入名为 `quickjs`，熔炉 0.4.1 的通用依赖检查器会误判为 `quickjs_ng`，因此其版本声明保留在根目录的 `requirements.txt`，由上述安装命令处理。

界面偏好及图鉴进度保存在 `UserData/workshop_ui.json`，快速存档保存在 `UserData/saves/quick.ewsave`。快速存档沿用 Godot 版 ZIP 容器及二进制布局，可读取原有的 `cells.bin`、`background.bin`、`info.json`。

## 保留的内容

- 90 种材料、85 种可选物质、44 条反应、100 项图鉴条目。
- 原有九个主场景、十一张演示专用地图及十六项演示编排。
- 原有五个 JavaScript 运行时文件、53 份 WGSL、地图、背景、字体、图标和缩略图。238 个来源文件的 SHA-256 记录在 `source-manifest.json`。
- 固定 60 Hz 网格步、每显示帧最多追赶两步、双缓冲布局、GPU 阶段顺序、流体、刚体、热传导、反应及相变。
- 级联光照、日光、镜面光束、折射、体积雾、景深、泛光、自动曝光及色调映射。
- 主页三种语言、场景单击选择及双击启动、三段顶栏、笔刷、快捷栏、物质库、图鉴、设置和悬停探针。
- 收藏、最近使用、中英搜索、数字键分配、快捷栏交换与材料拖放。
- 原有程序化音效滤波器和包络公式，以及按需帧末世界观测 v1。

联机入口沿用 Godot 基准中的开发状态说明。快速存档仍保存格子、温度和背景，读取时重建刚体。全界面多语言、完整流体及刚体速度存档的范围沿用 Godot 基准。

## 引擎适配与架构

JavaScript 核心通过 QuickJS-NG 在后台线程运行。熔炉 0.4.1 的公开 compute 接口接受 buffer，现有算法需要整数、半精度和三维 storage texture，因此 `GpuHost` 使用 wgpu-native 的独立 Vulkan 计算设备，保留 Godot 版独立计算设备的资源边界。最终图像经过熔炉 `RenderStack`，由 `WorkshopPresent.frag` 执行原有采样、暗角、颗粒和色差公式。

主线程负责熔炉界面、输入、显示缓冲与声音控制。后台线程独占 JavaScript 和 GPU。操作队列与最新帧邮箱沿用原结构。普通游玩按原流程读取显示帧与统计，世界观测仅在收到请求后采集数组。

| Godot 模块 | 熔炉模块 |
| --- | --- |
| `Main.tscn` | `Assets/Scenes/Workshop.scene`、`Assets/Scripts/Workshop.py` |
| `native/GameRuntime.cs` | `Assets/Scripts/native/game_runtime.py` |
| `native/GpuHost.cs` | `Assets/Scripts/native/gpu_host.py` |
| `native/GpuHost.Shaders.cs` | `Assets/Scripts/native/gpu_host_shaders.py` |
| `native/GpuHost.Storage.cs` | `Assets/Scripts/native/gpu_host_storage.py` |
| `native/WorldStateCapture.cs`、快照邮箱 | `Assets/Scripts/native/world_state_capture.py` |
| `native/SoundSynth.cs` | `Assets/Scripts/native/sound_synth.py` |
| `runtime/*.js` | `Assets/Workshop/runtime/*.js` |
| `ui/*.gd` | `Assets/Scripts/ui/*.py` |
| `original/` | `Assets/Workshop/original/` |

原 JavaScript 和 WGSL 文件保持原始内容。GPU 加载时沿用 Godot 转换器的 `workgroupUniformLoad` 原子变量兼容处理。Python 与 JavaScript 的二进制桥接保留子视图字节偏移、零字节和浮点位。

编辑器的组件脚本不在导入时修改 `sys.path`。QuickJS、wgpu、Pillow 及线程、音频和压缩库由 `Packages/workshop/runtime/WorkshopDependencies.py` 的 `InxPreload` 生命周期预加载；`runtime/library` 通过 `own_python_library` 声明为普通运行库。设备、线程和音频仍由 `WorkshopSession` 创建及释放，原有 `native/`、`ui/` 模块边界保持不变。场景中的 RenderStack 由引擎负责销毁，停止游戏后保留编辑器所需的渲染管线。

### 帧率与帧间隔

游戏内容的更新率取决于后台生成新画面的速度。编辑器原先显示的上千 FPS 包含重复绘制上一帧，不能用来代表模拟速度。性能记录单独统计新画面、模拟步数和帧间隔。

2026-11-06 的优化保留原画质、固定 60 Hz 模拟规则与模块职责：

- 二进制桥接使用 QuickJS-NG 的原生 Base64 编解码，保留任意字节、浮点位和子视图范围。
- 刚体占用位图用 NumPy 查表展开，随后继续调用原版更新方法；碰撞求解、回调顺序和 GPU 交换包沿用原逻辑。
- 同一帧的统计、占用、owner 和最终图像合并到一个可复用的 GPU 读回缓冲。读回后持有独立字节，后续写入使缓存失效，已发布画面和世界快照保持不可变。
- 计算派发复用资源绑定，在纹理复制、缓冲清理和提交边界结束计算通道，保留着色器执行顺序。
- 模拟采用固定时间期限调度；显示端在已有画面后最多等待一个目标帧间隔，让新画面的到达与显示同步。编辑器组件的 `update` 负责交付画面，界面刷新负责控件与输入。
- 播放期间的重复绘制上限为 120 FPS，并尊重用户设置的更低上限；停止时恢复原值。已有帧和视口尺寸均未改变时，不重复上传显示状态。

本机实验室场景的后台真实新画面更新率从约 18 FPS 提升到 60 FPS，平均每帧计算耗时从 55.2 ms 降到 10.5 ms，95% 帧间隔从 58.0 ms 降到 17.8 ms。独立后台测试见 `validation/performance-before.json`、`validation/performance-after.json`；开启音效的真实编辑器测试见 `validation/editor-play.json` 中的 `performance_cycles`，汇总见 `validation/performance-summary.json`。这些数据来自预热后采样，复杂刚体、演示和不同机器的性能应分别测量。

## 光晕与雾光的遮挡修正

默认渲染现在会检测局部光晕和前景雾光采样之间的材质遮挡。旧算法先把高亮区域模糊，再直接叠到画面；高温钠下方即使已经被容器底、木板挡住，后处理仍会给下层铁平台叠橙光。

`Assets/Workshop/runtime/lighting.js` 接入原有渲染阶段；`Assets/Scripts/native/lighting_shaders.py` 在加载时应用小范围着色器覆盖；共享可见性代码位于 `Assets/Workshop/shaders/`。按格子遍历避免跳过薄墙，玻璃沿用原有 RGB 消光值，插值之前分别检查采样点。雾光改用尚未跨墙模糊的光照，再进行带遮挡的积分。正常发光、玻璃透光、开口透光和玩家的泛光强度设置都保留。

238 个原始来源文件和旧参考图没有修改。此修正有意改变遮挡区域的最终像素；默认画面不再声明与旧版逐像素相同。使用 `--original-renderer` 可在验证工具中关闭修正，继续检查与原 Godot 图像一致性；这不是玩家设置，不会写入用户偏好或存档。`tools/verify_lighting.py` 另行验证无挡板、单格/双格墙、铁板、玻璃、开口、斜墙、高温钠、缩放以及移动遮挡，结果位于 `validation/lighting/`。

新增遮挡计算有开销；独立实验室运行的最新帧耗时及新画面更新率见 `validation/lighting/performance-final.json`，独立运行约 60 个新画面/秒，带界面和声音的编辑器复测约 55 个新画面/秒。雾光复用已有遮挡光场，保留原来的 32 层积分，避免重复向周围收集光线。当前实现哈希、遮挡数据和编辑器测量汇总在 `validation/lighting/summary.json`。前述性能优化记录是此次渲染修正之前的测量，不能混作当前耗时。

## 操作

- 左键绘制，右键擦除，Shift 拖动绘制直线。
- 中键或 Alt 加左键平移，滚轮缩放，Shift 加滚轮调整笔刷。
- B / G / E / H / C / F / X 切换工具，数字 1–9 选择快捷栏。
- M 打开物质库，Tab 打开图鉴，空格暂停，N 或句号单步，Home 适应画面。
- 物质库支持中文、英文搜索，选中材料后按数字键分配槽位，可拖放交换。
- Ctrl+S 快速保存，Ctrl+L 读取，Esc 关闭面板或结束演示。

## 验证记录

本机使用 NVIDIA RTX 5070 Ti 和 Vulkan。

- 关闭上述遮挡修正时，原 Godot 源码副本生成的九个场景，在固定 12 帧动态条件下，1536×864 游戏图像的全部 RGB 像素与移植版相同。旧记录在 `validation/dynamic-comparison.json`，参考图位于 `validation/reference/`，修正后的验证见 `validation/lighting/original-port-report.json`。
- 关闭遮挡修正时，实验室暂停模拟、120 个渲染帧后的 1536×864 图像逐像素相同。
- 暂停绘制、加热、单步、清空、存档逐字节恢复、分辨率调整、十一种调试视图和 GPU 探针通过验证。
- 十六项演示完成启动检查。五十种运行时管线通过编译，全部 53 份 WGSL 均保留。
- 十五个世界观测字段、邮箱容量、取消、场景 epoch、不可变副本及停止边界通过验证，结果位于 `validation/world-runtime.json`。
- 960×640 和 1920×1080 下完成主页、实验界面、物质库、图鉴和设置的原生运行检查。实际窗口中检查过搜索、键盘入口、字体和布局。
- 编辑器的 24 个项目脚本通过严格预检查和隔离导入；真实编辑器中验证键盘从主页进入实验室、Game 视图显示、鼠标点击暂停和两轮播放/停止，记录位于 `validation/editor-frontend.json`、`validation/editor-play.json`。
- 优化后的二进制桥接覆盖全部 256 种字节、空数组、奇数长度和子视图；24 次刚体更新与原版状态及交换包完全相同。GPU 读回覆盖行对齐、三维纹理、缓冲扩容、写入失效和不可变数据，记录位于 `validation/optimizations.json`。

逐像素图像对照覆盖上述固定运行条件，采样位置为游戏渲染输出。界面的字体栅格化和部分控件排版仍有细节差异，整段演示播放、长时间运行及音效听测仍需进一步验收。显示帧继续经过 GPU 读回，帧率受运行库和数据传输开销影响。

```powershell
$python = '.\.runtime\python313\python.exe'
& $python tools/verify_editor_frontend.py
& $python tools/verify_editor.py
& $python tools/verify_port.py --maps --compare
& $python tools/verify_port.py --maps --compare --original-renderer
& $python tools/verify_lighting.py
& $python tools/verify_world_runtime.py
& $python tools/verify_optimizations.py
& $python tools/measure_performance.py
& $python tools/verify_scene.py
& $python launch.py --ui-smoke --width 960 --height 640
```

编辑器依赖安装在本工程 `.runtime/python313` 的正常 `site-packages` 中。独立启动器也兼容已有的 `.runtime/packages`，但只安装到该附加目录不能供编辑器使用。
