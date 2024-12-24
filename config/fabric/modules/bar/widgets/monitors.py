import psutil

from fabric import Fabricator
from fabric.audio.service import Audio
from fabric.widgets.circularprogressbar import CircularProgressBar


class MetricMonitor:
    def __init__(self, name: str, poll_from, interval: int = 1000, stream=False):
        self.name = name
        self.widget = CircularProgressBar(pie=True, size=24, name=name)
        self.widget.value = poll_from()
        self.fabricator = Fabricator(
            poll_from=poll_from,
            interval=interval,
            stream=stream,
        )
        self.fabricator.connect("changed", self.update_widget)

    def update_widget(self, fabricator, value):
        self.widget.value = value

    def get_widget(self):
        return self.widget


class CPUMonitor(MetricMonitor):
    def __init__(self):
        super().__init__("cpu", lambda *args: psutil.cpu_percent(interval=0.1))


class RAMMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "ram",
            lambda *args: psutil.virtual_memory().percent,
            1000 * 60 * 3,
        )


class BatteryMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "battery",
            lambda *args: (
                psutil.sensors_battery().percent if psutil.sensors_battery() else 0
            ),
            1000 * 60 * 5,
        )


class TemperatureMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "temperature",
            lambda *args: self.get_device_temperature(),
            1000 * 60 * 1,
        )

    @staticmethod
    def get_device_temperature():
        try:
            temps = psutil.sensors_temperatures()
            if "coretemp" in temps:
                return temps["coretemp"][0].current
            elif "cpu_thermal" in temps:
                return temps["cpu_thermal"][0].current
            return 0.0
        except Exception:
            return 0.0


class VolumeMonitor:
    def __init__(self, audio_service: Audio = Audio()):
        self.name = "volume"
        self.widget = CircularProgressBar(pie=True, size=24, name=self.name)
        self.audio_service = audio_service
        self.audio_service.connect("speaker-changed", self.update_widget)

    def update_widget(self, *_):
        speaker = self.audio_service.speaker
        if speaker:
            self.widget.value = int(
                (speaker.volume / self.audio_service.max_volume) * 100
            )

    def get_widget(self):
        return self.widget
