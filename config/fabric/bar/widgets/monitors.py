import psutil

from fabric import Fabricator
from fabric.widgets.circularprogressbar import CircularProgressBar


class MetricMonitor:
    def __init__(self, name: str, poll_from, interval: int = 1000):
        self.name = name
        self.widget = CircularProgressBar(pie=True, size=24)
        self.fabricator = Fabricator(poll_from=poll_from, interval=interval)
        self.fabricator.connect("changed", self.update_widget)

    def update_widget(self, fabricator, value):
        self.widget.value = value

    def get_widget(self):
        return self.widget


class CPUMonitor(MetricMonitor):
    def __init__(self):
        super().__init__("cpu", psutil.cpu_percent)


class RAMMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "ram",
            lambda: psutil.virtual_memory().percent,
            interval=1000 * 60 * 3,
        )


class BatteryMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "battery",
            lambda: psutil.sensors_battery().percent if psutil.sensors_battery() else 0,
            interval=1000 * 60 * 5,
        )


class TemperatureMonitor(MetricMonitor):
    def __init__(self):
        super().__init__(
            "temperature",
            self.get_device_temperature,
            interval=1000 * 60 * 1,
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
