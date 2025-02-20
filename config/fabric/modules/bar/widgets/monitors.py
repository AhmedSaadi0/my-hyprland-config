import psutil

from fabric.audio.service import Audio
from fabric.widgets.label import Label
from modules.widgets.circularprogressbar import MyCircularProgressBar
from modules.widgets.metricmonitor import WIDGET_SIZE, MetricMonitor


class CPUMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "cpu",
            lambda *args: psutil.cpu_percent(interval=0.1),
            style_classes=["cpu"],
            tooltip_text="CPU",
            child=Label(""),
        )


class RAMMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "ram",
            lambda *args: psutil.virtual_memory().percent,
            1000 * 60 * 3,
            style_classes=["ram"],
            initial_value=psutil.virtual_memory().percent,
            tooltip_text="RAM",
            child=Label(""),
        )


class BatteryMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "battery",
            lambda *args: (
                psutil.sensors_battery().percent if psutil.sensors_battery() else 0
            ),
            1000 * 60 * 5,
            style_classes=["battery"],
            initial_value=(
                psutil.sensors_battery().percent if psutil.sensors_battery() else 0
            ),
            tooltip_text="Battery",
            child=Label("󰁹"),
        )


class TemperatureMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "temperature",
            lambda *args: self.get_device_temperature(),
            1000 * 60 * 1,
            style_classes=["temp"],
            initial_value=self.get_device_temperature(),
            tooltip_text="Temperature",
            child=Label(""),
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
        self.widget = MyCircularProgressBar(
            # pie=True,
            size=WIDGET_SIZE,
            line_width=1,
            name=self.name,
            style_classes=["volume"],
            tooltip_text="Volume",
            child=Label(""),
            start_at=0.4,
            end_at=0.1,
            inverted=True,
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
