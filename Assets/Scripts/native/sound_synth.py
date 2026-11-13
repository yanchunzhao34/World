"""逐样本保留原 SoundSynth 滤波与包络公式，通过 Windows 音频设备流式播放。"""

import math
import random
from _infernux_packages.workshop.runtime.library.dependencies import array, ctypes, threading, wintypes


class WaveFormat(ctypes.Structure):
    _fields_ = [("format", wintypes.WORD), ("channels", wintypes.WORD),
                ("rate", wintypes.DWORD), ("bytes_per_second", wintypes.DWORD),
                ("block", wintypes.WORD), ("bits", wintypes.WORD), ("extra", wintypes.WORD)]


class WaveHeader(ctypes.Structure):
    _fields_ = [("data", ctypes.c_void_p), ("length", wintypes.DWORD),
                ("recorded", wintypes.DWORD), ("user", ctypes.c_size_t),
                ("flags", wintypes.DWORD), ("loops", wintypes.DWORD),
                ("next", ctypes.c_void_p), ("reserved", ctypes.c_size_t)]


class SoundSynth:
    def __init__(self):
        self.volume, self.muted = .8, False
        self.fire = self.sizzle = self.boil = self.reaction = 0.0
        self.fire_low = self.previous_noise = self.previous_high = 0.0
        self.bubble_phase = self.bubble_frequency = self.bubble_envelope = 0.0
        self.crackle_envelope = self.reaction_envelope = self.reaction_low = self.gain = 0.0
        self.explosion_envelopes = [0.0] * 6
        self.explosion_low = [0.0] * 6
        self.explosion_pitch = [0.0] * 6
        self.stop = threading.Event()
        self.thread = None
        self.error = None

    def update(self, state):
        events = state["events"]
        multiplier = 0 if state["paused"] else 1
        self.fire += (min(1, math.sqrt(events[0]) / 25) * multiplier - self.fire) * .2
        self.sizzle = max(self.sizzle * .9, min(1, events[3] / 15) * multiplier)
        self.boil += (min(1, math.sqrt(events[1]) / 6) * multiplier - self.boil) * .25
        self.reaction += (min(1, math.sqrt(events[4]) / 12) * multiplier - self.reaction) * .3
        for explosion in state.get("explosions", [])[:3]:
            amount = min(1.4, max(.3, explosion[2] / 10))
            # 优先复用最弱爆炸声部，降低新事件对明显尾音的截断
            voice = min(range(6), key=self.explosion_envelopes.__getitem__)
            self.explosion_envelopes[voice] = min(.6 + .4 * amount, 1.2)
            self.explosion_pitch[voice] = .04 + .03 / amount

    def generate(self, count, rate=44100):
        samples = array.array("h")
        # 滤波与衰减按采样率换算，避免音色和包络时长随设备变化
        scale = 44100 / rate
        target = 0 if self.muted else self.volume
        for _ in range(count):
            # 平滑音量跳变，减少开关静音时的点击杂音
            self.gain += (target - self.gain) * .0005 * scale
            noise = random.random() * 2 - 1
            self.fire_low += (noise - self.fire_low) * (1 - .98 ** scale)
            total = self.fire_low * self.fire * .9
            if random.random() < self.fire * .0009 * scale:
                self.crackle_envelope = .5 + random.random() * .5
            self.crackle_envelope *= .992 ** scale
            total += noise * self.crackle_envelope * .35 * self.fire
            high = noise - self.previous_noise + .97 * self.previous_high
            self.previous_noise, self.previous_high = noise, high
            total += high * self.sizzle * .18
            if self.bubble_envelope < .01 and random.random() < self.boil * .0015 * scale:
                self.bubble_envelope, self.bubble_frequency = .6, 180 + random.random() * 500
            self.bubble_frequency *= 1.00004 ** scale
            self.bubble_phase += self.bubble_frequency / rate
            total += math.sin(self.bubble_phase * 6.283185307) * self.bubble_envelope * .25
            self.bubble_envelope *= .9985 ** scale
            if random.random() < self.reaction * .003 * scale:
                self.reaction_envelope = .4
            self.reaction_envelope *= .9975 ** scale
            self.reaction_low += (noise - self.reaction_low) * .35
            total += self.reaction_low * self.reaction_envelope * .4
            for voice in range(6):
                if self.explosion_envelopes[voice] >= .001:
                    self.explosion_low[voice] += (noise - self.explosion_low[voice]) * (
                        self.explosion_pitch[voice] + self.explosion_envelopes[voice] * .05)
                    total += self.explosion_low[voice] * self.explosion_envelopes[voice] * 3.2
                    self.explosion_envelopes[voice] *= .99987 ** scale
            # 软限幅压低爆炸叠加的峰值，减少硬裁剪失真
            sample = round(math.tanh(total * self.gain) * .5 * 32767)
            samples.extend((sample, sample))
        return samples.tobytes()

    def enable(self):
        if self.thread is None:
            self.thread = threading.Thread(target=self.run, name="Element Workshop Audio", daemon=True)
            self.thread.start()

    def run(self):
        device = ctypes.c_void_p()
        headers = []
        try:
            api = ctypes.WinDLL("winmm")
            api.waveOutOpen.argtypes = [ctypes.POINTER(ctypes.c_void_p), wintypes.UINT,
                ctypes.POINTER(WaveFormat), ctypes.c_size_t, ctypes.c_size_t, wintypes.DWORD]
            for name in ("waveOutPrepareHeader", "waveOutWrite", "waveOutUnprepareHeader"):
                getattr(api, name).argtypes = [ctypes.c_void_p, ctypes.POINTER(WaveHeader), wintypes.UINT]
            api.waveOutReset.argtypes = [ctypes.c_void_p]
            api.waveOutClose.argtypes = [ctypes.c_void_p]
            format = WaveFormat(1, 2, 44100, 44100 * 4, 4, 16, 0)
            error = api.waveOutOpen(ctypes.byref(device), 0xFFFFFFFF, ctypes.byref(format), 0, 0, 0)
            if error:
                raise RuntimeError(f"Audio device open failed ({error})")
            # 多缓冲覆盖生成与提交耗时，降低音频断流概率
            for _ in range(4):
                storage = ctypes.create_string_buffer(1024 * 4)
                header = WaveHeader(ctypes.addressof(storage), len(storage), 0, 0, 0, 0, None, 0)
                if api.waveOutPrepareHeader(device, ctypes.byref(header), ctypes.sizeof(header)):
                    raise RuntimeError("Audio buffer preparation failed")
                # 持有样本内存引用，避免系统播放期间音频地址失效
                headers.append((header, storage))
            print("AUDIO_STREAM_READY rate=44100 channels=2", flush=True)
            while not self.stop.is_set():
                for header, storage in headers:
                    if not (header.flags & 0x10) or header.flags & 1:
                        data = self.generate(1024)
                        ctypes.memmove(storage, data, len(data))
                        if api.waveOutWrite(device, ctypes.byref(header), ctypes.sizeof(header)):
                            raise RuntimeError("Audio buffer submission failed")
                self.stop.wait(.003)
        except BaseException as error:
            self.error = str(error)
            print("AUDIO_ERROR", error, flush=True)
        finally:
            if device.value:
                # 先归还系统占用的缓冲，再撤销头部以免悬挂引用
                api.waveOutReset(device)
                for header, _ in headers:
                    api.waveOutUnprepareHeader(device, ctypes.byref(header), ctypes.sizeof(header))
                api.waveOutClose(device)

    def close(self):
        self.stop.set()
        if self.thread:
            self.thread.join()
