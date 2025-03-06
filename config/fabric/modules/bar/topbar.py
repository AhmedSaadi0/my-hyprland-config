from fabric.hyprland.widgets import Language
from fabric.utils import FormattedString, bulk_replace
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.wayland import WaylandWindow as Window
from modules.utils.themes import COLOR_THEME

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


def update_theme(theme_service):
    theme_service.change_theme(COLOR_THEME)


class TopBar(Window):
    def __init__(self, theme_service, menu):
        super().__init__(
            name="bar",
            layer="top",
            anchor="left top right",
            exclusivity="auto",
            visible=False,
            all_visible=False,
            style_classes=["top-bar"],
        )
        self.menu = menu
        self.theme_service = theme_service

        # عناصر الواجهة
        self.workspaces = WorkspaceBox()
        self.language = self.create_language_widget()
        self.open_menu = self.create_open_menu_button()
        self.date_time = self.create_date_time_widget()
        # self.system_tray = SystemTray(name="system-tray", spacing=4)
        self.update_css = self.create_update_button()
        self.status_container = self.create_status_container()
        self.prayer_display = self.create_prayer_display()

        # إعداد الواجهة
        self.children = self.create_layout(self.prayer_display)

        self.show_all()

    def create_language_widget(self):
        """إنشاء عنصر اللغة."""
        return Language(
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
            # style_classes="topbar-btn",
            style_classes=["unset", "prayer-time-box"],
        )

    def create_open_menu_button(self):
        """إنشاء زر فتح القائمة."""
        return Button(
            label="menu",
            on_clicked=lambda *args: self.menu.toggle(),
            # style_classes="topbar-btn",
            style_classes=["unset", "prayer-time-box"],
        )

    def create_date_time_widget(self):
        """إنشاء عنصر التاريخ والوقت."""
        return DateTime(
            name="date-time",
            style_classes=["unset", "clock"],
            formatters="(%I:%M) %A, %d %B",
        )

    def create_update_button(self):
        """إنشاء زر تحديث CSS."""
        return Button(
            label="update",
            on_clicked=lambda *args: update_theme(self.theme_service),
            style_classes=["unset", "prayer-time-box"],
        )

    def create_prayer_display(self):
        """إنشاء عنصر عرض أوقات الصلاة."""
        return PrayerTimeDisplay(city="Sanaa", country="Yemen").get_widget()

    def create_status_container(self):
        """إنشاء حاوية لعناصر الحالة (CPU، RAM، إلخ)."""
        container = Box(
            name="widgets-container",
            spacing=4,
            orientation="h",
            style_classes=["hardware-box"],
        )
        widgets = [
            NetworkBarWidget().get_widget(),
            Box(style_classes="separator"),
            CPUMonitor().get_widget(),
            RAMMonitor().get_widget(),
            BatteryMonitor().get_widget(),
            TemperatureMonitor().get_widget(),
            VolumeMonitor().get_widget(),
        ]
        for widget in widgets:
            container.add(widget)
        return container

    def create_layout(self, prayer_display):
        """إنشاء التخطيط الرئيسي لشريط الحالة."""
        return CenterBox(
            name="bar-inner",
            start_children=Box(
                name="start-container",
                spacing=4,
                orientation="h",
                children=[
                    self.workspaces,
                    self.status_container,
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
                    prayer_display,
                    self.update_css,
                    self.language,
                    # self.system_tray,
                    self.open_menu,
                ],
            ),
        )
