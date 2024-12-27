import os

import sass

from fabric import Application
from fabric.hyprland.widgets import Language
from fabric.system_tray.widgets import SystemTray
from fabric.utils import FormattedString, bulk_replace, get_relative_path
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
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


def update_css(application: Application):
    scss_path = get_relative_path("../../scss/main.scss")
    css_path = get_relative_path("../../main.css")

    try:

        with open(scss_path, "r") as scss:
            compiled_css = sass.compile(string=scss.read())

        with open(css_path, "w") as css:
            css.write(compiled_css)
            css.flush()
            os.fsync(css.fileno())

        if os.path.exists(css_path):
            with open(css_path, "r") as file:
                css_data = file.read().strip()
                if not css_data:
                    print(f"CSS file {css_path} is empty!")
                    return  # Skip if the file is empty
        else:
            print(f"Error: {css_path} does not exist.")
            return  # Exit if the file does not exist

        application.set_stylesheet_from_file(css_path)

    except FileNotFoundError:
        print(f"Error: {scss_path} not found.")
    except sass.CompileError as e:
        print(f"Error compiling SCSS: {e}")


class StatusBar(Window):

    def __init__(self):
        super().__init__(
            name="bar",
            layer="top",
            anchor="left top right",
            # margin="10px 10px -2px 10px",
            exclusivity="auto",
            visible=False,
            all_visible=False,
            style_classes=["top-bar"],
        )
        self.workspaces = WorkspaceBox()
        # self.active_window = ActiveWindow(name="hyprland-window")
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
        self.date_time = DateTime(
            name="date-time",
            style_classes=["unset", "clock"],
            formatters="(%I:%M) %A, %d %B",
        )
        self.system_tray = SystemTray(name="system-tray", spacing=4)
        self.update_css = Button(
            label="update",
            on_clicked=lambda *args: update_css(self.application),
        )

        self.status_container = Box(
            name="widgets-container",
            spacing=4,
            orientation="h",
            # children=self.progress_bars_overlay,
            style_classes=["hardware-box"],
        )
        cpu_monitor = CPUMonitor()
        vol_monitor = VolumeMonitor()
        temp = TemperatureMonitor()
        ram = RAMMonitor()
        bat = BatteryMonitor()
        network = NetworkBarWidget()
        self.status_container.add(network.get_widget())
        self.status_container.add(Box(style_classes="separator"))
        self.status_container.add(cpu_monitor.get_widget())
        self.status_container.add(ram.get_widget())
        self.status_container.add(bat.get_widget())
        self.status_container.add(temp.get_widget())
        self.status_container.add(vol_monitor.get_widget())

        prayer_display = PrayerTimeDisplay(city="Sanaa", country="Yemen").get_widget()

        self.children = CenterBox(
            name="bar-inner",
            start_children=Box(
                name="start-container",
                spacing=4,
                orientation="h",
                children=[
                    self.workspaces,
                    self.update_css,
                    prayer_display,
                ],
            ),
            center_children=Box(
                name="center-container",
                spacing=4,
                orientation="h",
                children=[
                    self.date_time,
                ],
            ),
            end_children=Box(
                name="end-container",
                spacing=4,
                orientation="h",
                children=[
                    self.system_tray,
                    self.status_container,
                    self.language,
                ],
            ),
        )

        self.show_all()
