"""Process libraries owned by WorkshopDependencies, outside component reload.

No device, window, audio stream or worker is started by these imports.
The simulation and UI continue to acquire and release those in WorkshopSession.
"""

import array
import base64
import ctypes
import gzip
import queue
import re
import tempfile
import threading
import time
import traceback
import uuid
import zipfile
from ctypes import wintypes
from types import MappingProxyType

import quickjs
import wgpu
from PIL import Image

# Public engine modules used by component candidates must be ready before the
# editor publishes the complete project script transaction.
from Infernux.core.assets import AssetManager
from Infernux.renderstack import RenderPipeline, RenderStack
from Infernux.renderstack.render_stack_pipeline import RenderStackPipeline
from Infernux.engine.ui import imgui_keys
from Infernux.input import Input
