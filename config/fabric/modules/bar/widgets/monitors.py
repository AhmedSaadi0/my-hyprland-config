import psutil

from fabric.audio.service import Audio
from fabric.widgets.label import Label
from modules.widgets.circularprogressbar import MyCircularProgressBar
from modules.widgets.metricmonitor import WIDGET_SIZE, MetricMonitor


class CPUMonitor(MetricMonitor):
    def __init__(self, **kwargs):
        kwargs.setdefault("style_classes", ["cpu"])
        kwargs.setdefault("tooltip_text", "CPU")
        kwargs.setdefault("child", Label(""))
        super().__init__(
            "cpu", lambda *args: psutil.cpu_percent(interval=0.1), **kwargs
        )


class RAMMonitor(MetricMonitor):
    def __init__(self, **kwargs):
        kwargs.setdefault("style_classes", ["ram"])
        kwargs.setdefault("tooltip_text", "RAM")
        kwargs.setdefault("child", Label(""))
        kwargs.setdefault("initial_value", psutil.virtual_memory().percent)
        super().__init__(
            "ram",
            lambda *args: psutil.virtual_memory().percent,
            1000 * 60 * 3,
            **kwargs,
        )


class BatteryMonitor(MetricMonitor):
    def __init__(self, **kwargs):
        kwargs.setdefault("style_classes", ["battery"])
        kwargs.setdefault("tooltip_text", "Battery")
        kwargs.setdefault("child", Label("󰁹"))
        kwargs.setdefault(
            "initial_value",
            (
                psutil.sensors_battery().percent
                if psutil.sensors_battery()
                else 0
            ),
        )
        super().__init__(
            "battery",
            lambda *args: (
                psutil.sensors_battery().percent
                if psutil.sensors_battery()
                else 0
            ),
            1000 * 60 * 5,
            **kwargs,
        )


class TemperatureMonitor(MetricMonitor):
    def __init__(self, **kwargs):
        kwargs.setdefault("style_classes", ["temp"])
        kwargs.setdefault("tooltip_text", "Temperature")
        kwargs.setdefault("child", Label(""))
        kwargs.setdefault("initial_value", self.get_device_temperature())
        super().__init__(
            "temperature",
            lambda *args: self.get_device_temperature(),
            1000 * 60 * 1,
            **kwargs,
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
    def __init__(self, audio_service: Audio = Audio(), **kwargs):
        kwargs.setdefault("style_classes", ["volume"])
        kwargs.setdefault("tooltip_text", "Volume")
        kwargs.setdefault("child", Label(""))
        kwargs.setdefault("start_at", 0.4)
        kwargs.setdefault("end_at", 0.1)
        kwargs.setdefault("inverted", True)

        self.name = "volume"
        self.widget = MyCircularProgressBar(
            size=WIDGET_SIZE, line_width=1, name=self.name, **kwargs
        )
        self.audio_service = audio_service
        self.audio_service.connect("speaker-changed", self.update_widget)

    def update_widget(self, *_):
        speaker = self.audio_service.speaker
        if speaker:
            value = int((speaker.volume / self.audio_service.max_volume) * 100)
            self.widget.value = value / 100
            self.widget.set_property("tooltip_text", f"Volume ({value})")

    def get_widget(self):
        return self.widget
