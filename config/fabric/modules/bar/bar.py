import psutil

from fabric.hyprland.widgets import ActiveWindow, Language
from fabric.system_tray.widgets import SystemTray
from fabric.utils import FormattedString, bulk_replace, invoke_repeater
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.datetime import DateTime
from fabric.widgets.label import Label
from fabric.widgets.overlay import Overlay
from fabric.widgets.wayland import WaylandWindow as Window

from .widgets.monitors import (
    BatteryMonitor,
    CPUMonitor,
    RAMMonitor,
    TemperatureMonitor,
    VolumeMonitor,
)
from .widgets.network import NetworkBarWidget
from .widgets.prayer_times import PrayerTimeDisplay
from .widgets.workspaces import WorkspaceBox


class StatusBar(Window):
    def __init__(self):
        super().__init__(
            name="bar",
            layer="top",
            anchor="left top right",
            margin="10px 10px -2px 10px",
            exclusivity="auto",
            visible=False,
            all_visible=False,
        )
        self.workspaces = WorkspaceBox()
        self.active_window = ActiveWindow(name="hyprland-window")
        self.language = Language(
            formatter=FormattedString(
                "{replace_lang(language)}",
                replace_lang=lambda lang: bulk_replace(
                    lang,
                    (r".*Eng.*", r".*Ar.*"),
                    ("ENG", "ARA"),
                    regex=True,
                ),
            ),
            name="hyprland-window",
        )
        self.date_time = DateTime(name="date-time")
        self.system_tray = SystemTray(name="system-tray", spacing=4)

        self.ram_progress_bar = CircularProgressBar(
            name="ram-progress-bar", pie=True, size=24
        )
        self.cpu_progress_bar = CircularProgressBar(
            name="cpu-progress-bar", pie=True, size=24
        )
        self.progress_bars_overlay = Overlay(
            child=self.ram_progress_bar,
            overlays=[
                self.cpu_progress_bar,
                Label("", style="margin: 0px 6px 0px 0px; font-size: 12px"),
            ],
        )

        self.status_container = Box(
            name="widgets-container",
            spacing=4,
            orientation="h",
            children=self.progress_bars_overlay,
        )
        monitor = CPUMonitor()
        vol_monitor = VolumeMonitor()
        temp = TemperatureMonitor()
        ram = RAMMonitor()
        bat = BatteryMonitor()
        network = NetworkBarWidget()
        self.status_container.add(monitor.get_widget())
        self.status_container.add(vol_monitor.get_widget())
        self.status_container.add(temp.get_widget())
        self.status_container.add(ram.get_widget())
        self.status_container.add(bat.get_widget())
        self.status_container.add(network.get_widget())

        prayer_display = PrayerTimeDisplay(city="Sanaa", country="Yemen").get_widget()

        self.children = CenterBox(
            name="bar-inner",
            start_children=Box(
                name="start-container",
                spacing=4,
                orientation="h",
                children=[
                    self.workspaces,
                    prayer_display,
                ],
            ),
            center_children=Box(
                name="center-container",
                spacing=4,
                orientation="h",
                children=self.active_window,
            ),
            end_children=Box(
                name="end-container",
                spacing=4,
                orientation="h",
                children=[
                    self.status_container,
                    self.system_tray,
                    self.date_time,
                    self.language,
                ],
            ),
        )

        invoke_repeater(1000, self.update_progress_bars)

        self.show_all()

    def update_progress_bars(self):
        self.ram_progress_bar.value = psutil.virtual_memory().percent / 100
        self.cpu_progress_bar.value = psutil.cpu_percent() / 100
        return True
