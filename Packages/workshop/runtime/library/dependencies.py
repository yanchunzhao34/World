"""Process libraries owned by WorkshopDependencies, outside component reload.

No device, window, audio stream or worker is started by these imports.
The simulation and UI continue to acquire and release those in WorkshopSession.
"""

import array
import base64
import ctypes
import copy
import gzip
import queue
import random
import re
import struct
import tempfile
import threading
import time
import traceback
import uuid
import zipfile
from ctypes import wintypes
from types import MappingProxyType, SimpleNamespace

import wgpu
from PIL import Image

# 预载公共引擎模块，避免组件隔离导入时出现依赖缺失
from infernux.core.assets import AssetManager
from infernux.renderstack import RenderPipeline, RenderStack
from infernux.renderstack.render_stack_pipeline import RenderStackPipeline
from infernux.engine.ui import imgui_keys
from infernux.input import Input


# 按需载入迁移对照使用的参考解释器。
def load_reference_js():
    """Load the archived runtime only when a migration parity check requests it."""

    try:
        # 按需加载参考解释器，让正常游戏依赖保持精简
        import quickjs

    except ImportError as error:
        raise RuntimeError('Reference checks require quickjs-ng==0.17.0.2') from error

    return quickjs
