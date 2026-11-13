"""逐样本保留原 SoundSynth 滤波与包络公式，通过 Windows 音频设备流式播放。"""

import math
import random
from _infernux_packages.workshop.runtime.library.dependencies import (
    array,
    ctypes,
    threading,
    wintypes,
)


class WaveFormat(ctypes.Structure):
    _fields_ = [
        ("format", wintypes.WORD),
        ("channels", wintypes.WORD),
        ("rate", wintypes.DWORD),
        ("bytes_per_second", wintypes.DWORD),
        ("block", wintypes.WORD),
        ("bits", wintypes.WORD),
        ("extra", wintypes.WORD),
    ]


class WaveHeader(ctypes.Structure):
    _fields_ = [
        ("data", ctypes.c_void_p),
        ("length", wintypes.DWORD),
        ("recorded", wintypes.DWORD),
        ("user", ctypes.c_size_t),
        ("flags", wintypes.DWORD),
        ("loops", wintypes.DWORD),
        ("next", ctypes.c_void_p),
        ("reserved", ctypes.c_size_t),
    ]


class SoundSynth:
    # 初始化声音包络与音频线程状态。
    def __init__(self):
        self.volume, self.muted = 0.8, False
        self.fire = 0.0
        self.sizzle = 0.0
        self.boil = 0.0
        self.reaction = 0.0

        self.fire_low = 0.0
        self.previous_noise = 0.0
        self.previous_high = 0.0

        self.bubble_phase = 0.0
        self.bubble_frequency = 0.0
        self.bubble_envelope = 0.0

        self.crackle_envelope = 0.0
        self.reaction_envelope = 0.0
        self.reaction_low = 0.0
        self.gain = 0.0

        self.explosion_envelopes = [0.0] * 6
        self.explosion_low = [0.0] * 6
        self.explosion_pitch = [0.0] * 6

        self.stop = threading.Event()
        self.thread = None
        self.error = None

    # 由最新模拟事件更新各类声音强度。
    def update(self, state):
        events = state["events"]
        multiplier = 0 if state["paused"] else 1
        self.fire += (min(1, math.sqrt(events[0]) / 25) * multiplier - self.fire) * 0.2
        self.sizzle = max(self.sizzle * 0.9, min(1, events[3] / 15) * multiplier)
        self.boil += (min(1, math.sqrt(events[1]) / 6) * multiplier - self.boil) * 0.25
        self.reaction += (
            min(1, math.sqrt(events[4]) / 12) * multiplier - self.reaction
        ) * 0.3

        for explosion in state.get("explosions", [])[:3]:
            amount = min(1.4, max(0.3, explosion[2] / 10))

            # 优先复用最弱爆炸声部，降低新事件对明显尾音的截断
            voice = min(range(6), key=self.explosion_envelopes.__getitem__)
            self.explosion_envelopes[voice] = min(0.6 + 0.4 * amount, 1.2)
            self.explosion_pitch[voice] = 0.04 + 0.03 / amount

    # 按当前包络合成双声道PCM样本。
    def generate(self, count, rate=44100):
        samples = array.array("h")

        # 滤波与衰减按采样率换算，避免音色和包络时长随设备变化
        sample_rate_scale = 44100 / rate
        target_gain = 0 if self.muted else self.volume

        for _ in range(count):
            # 平滑音量跳变，减少开关静音时的点击杂音
            self.gain += (target_gain - self.gain) * 0.0005 * sample_rate_scale
            noise_sample = random.random() * 2 - 1
            self.fire_low += (noise_sample - self.fire_low) * (
                1 - 0.98**sample_rate_scale
            )
            mixed_sample = self.fire_low * self.fire * 0.9

            if random.random() < self.fire * 0.0009 * sample_rate_scale:
                self.crackle_envelope = 0.5 + random.random() * 0.5

            self.crackle_envelope *= 0.992**sample_rate_scale
            mixed_sample += noise_sample * self.crackle_envelope * 0.35 * self.fire
            high = noise_sample - self.previous_noise + 0.97 * self.previous_high
            self.previous_noise, self.previous_high = noise_sample, high
            mixed_sample += high * self.sizzle * 0.18

            if (
                self.bubble_envelope < 0.01
                and random.random() < self.boil * 0.0015 * sample_rate_scale
            ):
                self.bubble_envelope, self.bubble_frequency = (
                    0.6,
                    180 + random.random() * 500,
                )

            self.bubble_frequency *= 1.00004**sample_rate_scale
            self.bubble_phase += self.bubble_frequency / rate
            mixed_sample += (
                math.sin(self.bubble_phase * 6.283185307) * self.bubble_envelope * 0.25
            )
            self.bubble_envelope *= 0.9985**sample_rate_scale

            if random.random() < self.reaction * 0.003 * sample_rate_scale:
                self.reaction_envelope = 0.4

            self.reaction_envelope *= 0.9975**sample_rate_scale
            self.reaction_low += (noise_sample - self.reaction_low) * 0.35
            mixed_sample += self.reaction_low * self.reaction_envelope * 0.4

            for voice_index in range(6):
                if self.explosion_envelopes[voice_index] >= 0.001:
                    self.explosion_low[voice_index] += (
                        noise_sample - self.explosion_low[voice_index]
                    ) * (
                        self.explosion_pitch[voice_index]
                        + self.explosion_envelopes[voice_index] * 0.05
                    )
                    mixed_sample += (
                        self.explosion_low[voice_index]
                        * self.explosion_envelopes[voice_index]
                        * 3.2
                    )
                    self.explosion_envelopes[voice_index] *= 0.99987**sample_rate_scale

            # 软限幅压低爆炸叠加的峰值，减少硬裁剪失真
            pcm_sample = round(math.tanh(mixed_sample * self.gain) * 0.5 * 32767)

            samples.extend((pcm_sample, pcm_sample))

        return samples.tobytes()

    # 按需启动程序化音效输出线程。
    def enable(self):
        if self.thread is None:
            self.thread = threading.Thread(
                target=self.run, name="Element Workshop Audio", daemon=True
            )

            self.thread.start()

    # 持续合成并提交Windows音频缓冲。
    def run(self):
        audio_device = ctypes.c_void_p()
        headers = []

        try:
            audio_api = ctypes.WinDLL("winmm")
            audio_api.waveOutOpen.argtypes = [
                ctypes.POINTER(ctypes.c_void_p),
                wintypes.UINT,
                ctypes.POINTER(WaveFormat),
                ctypes.c_size_t,
                ctypes.c_size_t,
                wintypes.DWORD,
            ]

            for name in (
                "waveOutPrepareHeader",
                "waveOutWrite",
                "waveOutUnprepareHeader",
            ):
                getattr(audio_api, name).argtypes = [
                    ctypes.c_void_p,
                    ctypes.POINTER(WaveHeader),
                    wintypes.UINT,
                ]

            audio_api.waveOutReset.argtypes = [ctypes.c_void_p]
            audio_api.waveOutClose.argtypes = [ctypes.c_void_p]
            wave_format = WaveFormat(1, 2, 44100, 44100 * 4, 4, 16, 0)
            error = audio_api.waveOutOpen(
                ctypes.byref(audio_device),
                0xFFFFFFFF,
                ctypes.byref(wave_format),
                0,
                0,
                0,
            )

            if error:
                raise RuntimeError(f"Audio device open failed ({error})")

            # 多缓冲覆盖生成与提交耗时，降低音频断流概率
            for _ in range(4):
                storage = ctypes.create_string_buffer(1024 * 4)
                header = WaveHeader(
                    ctypes.addressof(storage), len(storage), 0, 0, 0, 0, None, 0
                )

                if audio_api.waveOutPrepareHeader(
                    audio_device, ctypes.byref(header), ctypes.sizeof(header)
                ):
                    raise RuntimeError("Audio buffer preparation failed")

                # 持有样本内存引用，避免系统播放期间音频地址失效
                headers.append((header, storage))

            print("AUDIO_STREAM_READY rate=44100 channels=2", flush=True)

            while not self.stop.is_set():
                for header, storage in headers:
                    if not (header.flags & 0x10) or header.flags & 1:
                        data = self.generate(1024)

                        ctypes.memmove(storage, data, len(data))

                        if audio_api.waveOutWrite(
                            audio_device, ctypes.byref(header), ctypes.sizeof(header)
                        ):
                            raise RuntimeError("Audio buffer submission failed")

                self.stop.wait(0.003)

        except BaseException as error:
            self.error = str(error)

            print("AUDIO_ERROR", error, flush=True)

        finally:
            if audio_device.value:
                # 先归还系统占用的缓冲，再撤销头部以免悬挂引用
                audio_api.waveOutReset(audio_device)

                for header, _ in headers:
                    audio_api.waveOutUnprepareHeader(
                        audio_device, ctypes.byref(header), ctypes.sizeof(header)
                    )

                audio_api.waveOutClose(audio_device)

    # 请求结束音频输出并等待设备清理。
    def close(self):
        self.stop.set()

        if self.thread:
            self.thread.join()
