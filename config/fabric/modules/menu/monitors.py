from fabric.widgets.box import Box
from modules.bar.widgets.monitors import (
    BatteryMonitor,
    CPUMonitor,
    RAMMonitor,
    TemperatureMonitor,
)
from modules.utils.strings import get_string
from modules.widgets.titletext import TitleText


class MonitorsHeaderBox(Box):
    def __init__(self, **kwargs):
        super().__init__(
            style="margin-bottom: 1rem;",
            style_classes="menu-monitors-box",
            orientation="h",
            spacing=17,
            **kwargs,
        )

        self.cpu_progress = self.create_cpu_progress()
        self.ram_progress = self.create_ram_progress()
        self.battery_progress = self.create_battery_progress()
        self.temp_progress = self.create_temp_progress()

        self.children = [
            self.cpu_progress,
            self.ram_progress,
            self.battery_progress,
            self.temp_progress,
        ]

    def create_cpu_progress(self):
        return TitleText(
            title=get_string("cpu"),
            text_widget=CPUMonitor(
                size=60, style_classes=["menu-cpu"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )

    def create_ram_progress(self):
        return TitleText(
            title=get_string("ram"),
            text_widget=RAMMonitor(
                size=65, style_classes=["menu-ram"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )

    def create_battery_progress(self):
        return TitleText(
            title=get_string("battery"),
            text_widget=BatteryMonitor(
                size=65, style_classes=["menu-battery"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )

    def create_temp_progress(self):
        return TitleText(
            title=get_string("temp"),
            text_widget=TemperatureMonitor(
                size=65, style_classes=["menu-temp"]
            ).get_widget(),
            button_class="unset",
            spacing=10,
        )
