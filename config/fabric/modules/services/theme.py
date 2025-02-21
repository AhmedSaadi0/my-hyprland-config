import json
import logging
import subprocess
from pathlib import Path
from threading import Timer

import dbus
import dbus.mainloop.glib
from gi.repository import Gio

from fabric.core.service import Property, Service, Signal
from modules.utils.settings import get_settings
from modules.utils.themes import (
    BLACK_HOLE_THEME,
    COLOR_THEME,
    DYNAMIC_M3_LIGHT,
    ThemesDictionary,
)

settings = get_settings()
logging.basicConfig(level=logging.INFO)


class ThemeService(Service):
    """
    Service to manage system theme changes
    including wallpapers, CSS, and various desktop settings.
    """

    CACHE_FILE_PATH: Path = Path.home() / ".cache" / "ahmed-hyprland-conf.temp"

    @Signal
    def changed(self) -> None:
        """
        Signal emitted when the theme is changed.
        """

    def __init__(self) -> None:
        """
        Initialize the ThemeService,
        set up the DBus main loop and load cached theme variables.
        """
        super().__init__()
        logging.info("Starting theme service")
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        self.bus = dbus.SessionBus()

        self.selected_theme: str = COLOR_THEME
        self.wallpapers_list: list = []

        self.wallpaper_interval_id: Timer | None = None
        self.selected_light_wallpaper: int = 0
        self.selected_dark_wallpaper: int = 0
        self._dynamic_wallpaper_status: bool = True
        self._show_desktop_widget_status: bool = True

        self._load_cached_variables()
        self.apply_cached_theme()

    @Property(str, flags="r")
    def dynamic_wallpaper_is_on(self) -> bool:
        """
        Returns whether the dynamic wallpaper is currently enabled.
        """
        return self._dynamic_wallpaper_status

    @Property(str, flags="r")
    def is_dynamic_theme(self) -> bool:
        """
        Returns True if the current theme is dynamic.
        """
        return ThemesDictionary.get(self.selected_theme, {}).get(
            "dynamic", False
        )

    def change_theme(self, selected_theme: str) -> None:
        """
        Changes the system theme to the specified theme.

        :param selected_theme: The key of the theme to apply.
        """
        theme = ThemesDictionary.get(selected_theme)
        if not theme:
            logging.warning(
                "Theme '%s' not found in ThemesDictionary.", selected_theme
            )
            return

        self._clear_dynamic_wallpaper_interval()
        is_dynamic = theme.dynamic

        if is_dynamic:
            self._set_dynamic_wallpapers(
                theme.wallpaper_path,
                theme.gtk_mode,
                theme.interval,
            )
        else:
            self.change_css(theme.css_theme)
            self.change_wallpaper(theme.wallpaper)

        if settings.change_plasma_theme:
            self.change_plasma_color(theme.plasma_color)
            self.change_plasma_icons(theme.qt_icon_theme)
            self.change_konsole_profile(theme.hypr.konsole)

        self.change_gtk_theme(
            theme.gtk_theme,
            theme.gtk_mode,
            theme.gtk_icon_theme,
            theme.font_name,
        )

        self.change_kvantum_theme(theme.kvantum_theme)

        if self._show_desktop_widget_status:
            self.show_desktop_widget(theme.desktop_widget)

        hypr = theme.hypr
        self._set_hyprland(
            hypr.border_width,
            hypr.active_border,
            hypr.inactive_border,
            hypr.rounding,
        )

        self.selected_theme = selected_theme
        self.emit("changed")
        self._cache_variables()

    def change_wallpaper(self, wallpaper: str) -> None:
        """
        Changes the desktop wallpaper.
        """
        try:
            subprocess.run(
                ["swww", "img", "--transition-type", "random", wallpaper],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            logging.exception("Error changing wallpaper: %s", e)

    def change_css(self, css_theme: str) -> None:
        """
        Updates the CSS theme.
        """
        scss = settings.theme.get("mainCss")
        css = settings.theme.get("styleCss")
        new_th = f"@import './themes/{css_theme}';"
        try:
            subprocess.run(["sed", "-i", f"1s|.*|{new_th}|", scss], check=True)
            subprocess.run(["sassc", scss, css], check=True)
        except subprocess.CalledProcessError as e:
            logging.exception("Error changing CSS: %s", e)

    def _set_dynamic_wallpapers(
        self,
        path: str,
        theme_mode: str,
        interval: int,
    ) -> None:
        """
        Sets up dynamic wallpapers using a provided script.

        :param path: The path to the wallpapers.
        :param theme_mode: The mode (e.g., 'dark' or 'light').
        :param interval: The interval in milliseconds between wallpaper changes.
        """
        try:
            result = subprocess.run(
                [settings.scripts.get("get_wallpapers"), path],
                capture_output=True,
                text=True,
                check=True,
            )
            wallpapers = json.loads(result.stdout)
            self.wallpapers_list = wallpapers

            self.call_next_wallpaper(theme_mode)

            if self._dynamic_wallpaper_status:
                self.wallpaper_interval_id = Timer(
                    interval / 1000,
                    self.call_next_wallpaper,
                    args=[theme_mode],
                )
                self.wallpaper_interval_id.start()

        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            logging.exception("Error setting dynamic wallpapers: %s", e)

    def toggle_dynamic_wallpaper(self) -> None:
        """
        Toggles the dynamic wallpaper feature.
        """
        if self.is_dynamic_theme and self._dynamic_wallpaper_status:
            self.stop_dynamic_wallpaper()
        else:
            self.start_dynamic_wallpaper()

    def _clear_dynamic_wallpaper_interval(self) -> None:
        """
        Clears the current dynamic wallpaper timer.
        """
        if self.wallpaper_interval_id:
            self.wallpaper_interval_id.cancel()
            self.wallpaper_interval_id = None

    def stop_dynamic_wallpaper(self) -> None:
        """
        Stops the dynamic wallpaper feature.
        """
        self._dynamic_wallpaper_status = False
        self._clear_dynamic_wallpaper_interval()
        theme = ThemesDictionary.get(self.selected_theme)
        if theme == DYNAMIC_M3_LIGHT:
            self.selected_light_wallpaper = (
                (self.selected_light_wallpaper - 1) % len(self.wallpapers_list)
                if self.wallpapers_list
                else 0
            )
        else:
            self.selected_dark_wallpaper = (
                (self.selected_dark_wallpaper - 1) % len(self.wallpapers_list)
                if self.wallpapers_list
                else 0
            )
        self._cache_variables()
        self.emit("changed")

    def start_dynamic_wallpaper(self) -> None:
        """
        Starts the dynamic wallpaper feature.
        """
        theme = ThemesDictionary.get(self.selected_theme)
        self._dynamic_wallpaper_status = True
        self._clear_dynamic_wallpaper_interval()
        self._set_dynamic_wallpapers(
            theme.get("wallpaper_path", ""),
            theme.get("gtk_mode", ""),
            theme.get("interval", 30000),
        )
        self._cache_variables()
        self.emit("changed")

    def call_next_wallpaper(self, theme_mode: str) -> None:
        """
        Switches to the next wallpaper based on the theme mode.

        :param theme_mode: Either 'dark' or 'light'.
        """
        selected_wallpaper_index = 0
        if theme_mode == "dark":
            selected_wallpaper_index = self.selected_dark_wallpaper
            if self._dynamic_wallpaper_status:
                self.selected_dark_wallpaper = (
                    (self.selected_dark_wallpaper + 1)
                    % len(self.wallpapers_list)
                    if self.wallpapers_list
                    else 0
                )
        else:
            selected_wallpaper_index = self.selected_light_wallpaper
            if self._dynamic_wallpaper_status:
                self.selected_light_wallpaper = (
                    (self.selected_light_wallpaper + 1)
                    % len(self.wallpapers_list)
                    if self.wallpapers_list
                    else 0
                )

        wallpaper = (
            self.wallpapers_list[selected_wallpaper_index]
            if self.wallpapers_list
            else None
        )
        if wallpaper:
            self.change_wallpaper(wallpaper)
            self.create_m3_color_schema(wallpaper, theme_mode)
            self._cache_variables()

    def create_m3_color_schema(self, wallpaper: str, mode: str) -> None:
        """
        Creates a Material You color schema based on the current wallpaper.

        :param wallpaper: The path or identifier of the wallpaper.
        :param mode: The current mode ('dark' or 'light').
        """
        # TODO: Implement schema creation logic

    def change_plasma_color(self, plasma_color: str) -> None:
        """
        Changes the plasma color scheme.
        """
        plasma_cmd = "plasma-apply-colorscheme"
        try:
            subprocess.run(
                [plasma_cmd, plasma_color.split(".")[0]], check=True
            )
        except subprocess.CalledProcessError as e:
            logging.exception("Error changing Plasma color: %s", e)

    def change_plasma_icons(self, plasma_icons: str) -> None:
        """
        Changes the plasma icons theme.
        """
        try:
            subprocess.run(
                [
                    "kwriteconfig5",
                    "--file",
                    str(Path.home() / ".config" / "kdeglobals"),
                    "--group",
                    "Icons",
                    "--key",
                    "Theme",
                    plasma_icons,
                ],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            logging.exception("Error changing Plasma icons: %s", e)

    def change_gtk_theme(
        self,
        gtk_theme: str,
        gtk_mode: str,
        icon_theme: str,
        font_name: str,
    ) -> None:
        """
        Changes the GTK theme and its related settings.
        """

        def set_gtk_settings() -> None:
            try:
                gtk_settings = Gio.Settings.new("org.gnome.desktop.interface")
                gtk_wm_settings = Gio.Settings.new(
                    "org.gnome.desktop.wm.preferences"
                )
                gtk_settings.set_string("gtk-theme", gtk_theme)
                gtk_wm_settings.set_string("theme", gtk_theme)
                logging.info("GTK theme set to: %s", gtk_theme)
            except Exception as e:
                logging.exception(
                    "Error setting GTK theme using Gio.Settings: %s", e
                )

        Timer(2, set_gtk_settings).start()

        try:
            gtk_interface_settings = Gio.Settings.new(
                "org.gnome.desktop.interface"
            )
            gtk_interface_settings.set_string("icon-theme", icon_theme)
            gtk_interface_settings.set_string("font-name", font_name)
            logging.info(
                "GTK icon theme set to: %s, font set to: %s",
                icon_theme,
                font_name,
            )
        except Exception as e:
            logging.exception(
                "Error setting GTK icon theme or font using Gio.Settings: %s",
                e,
            )

    def _set_hyprland(
        self,
        border_width: int,
        active_border: str,
        inactive_border: str,
        rounding: int,
    ) -> None:
        """
        Sets Hyprland configuration.
        """

        def hyprctl_commands() -> None:
            try:
                subprocess.run(
                    [
                        "hyprctl",
                        "keyword",
                        "general:border_size",
                        str(border_width),
                    ],
                    check=True,
                )
                subprocess.run(
                    [
                        "hyprctl",
                        "keyword",
                        "general:col.active_border",
                        active_border,
                    ],
                    check=True,
                )
                subprocess.run(
                    [
                        "hyprctl",
                        "keyword",
                        "general:col.inactive_border",
                        inactive_border,
                    ],
                    check=True,
                )
                subprocess.run(
                    [
                        "hyprctl",
                        "keyword",
                        "decoration:rounding",
                        str(rounding),
                    ],
                    check=True,
                )
            except subprocess.CalledProcessError as e:
                logging.exception("Error setting Hyprland: %s", e)

        Timer(0.5, hyprctl_commands).start()

    def change_konsole_profile(self, konsole_profile: str) -> None:
        """
        Changes the Konsole profile.
        """
        konsole_profile_data = f"""[Desktop Entry]
DefaultProfile={konsole_profile}.profile

[General]
ConfigVersion=1

[MainWindow]
ToolBarsMovable=Disabled
"""
        try:
            with open(Path.home() / ".config" / "konsolerc", "w") as f:
                f.write(konsole_profile_data)
        except Exception as e:
            logging.exception("Error writing Konsole profile: %s", e)

    def change_kvantum_theme(self, kvantum_theme: str) -> None:
        """
        Changes the Kvantum theme.
        """
        try:
            subprocess.run(
                ["kvantummanager", "--set", kvantum_theme], check=True
            )
        except subprocess.CalledProcessError as e:
            logging.exception("Error changing Kvantum theme: %s", e)

    def show_desktop_widget(self, widget: str) -> None:
        """
        Shows the desktop widget.
        """
        old_theme = ThemesDictionary.get(self.selected_theme)
        old_widget = (
            old_theme.get("desktop_widget", None) if old_theme else None
        )

        if old_widget and old_widget != widget:
            self.hide_widget(old_widget)

        if widget:
            Timer(1, self.show_widget, args=[widget]).start()

    def hide_widget(self, function_name: str) -> None:
        """
        Hides the specified widget.
        """
        try:
            # TODO: Implement widget hiding logic here if needed.
            pass
        except subprocess.CalledProcessError as e:
            logging.exception("Error hiding widget: %s", e)

    def show_widget(self, function_name: str) -> None:
        """
        Shows the specified widget.
        """
        try:
            # TODO: Implement widget showing logic here if needed.
            pass
        except subprocess.CalledProcessError as e:
            logging.exception("Error showing widget: %s", e)

    def _cache_variables(self) -> None:
        """
        Caches the current theme variables to a file.
        """
        new_data = {
            "selected_theme": self.selected_theme,
            "selected_dark_wallpaper": self.selected_dark_wallpaper,
            "selected_light_wallpaper": self.selected_light_wallpaper,
            "dynamic_wallpaper_status": self._dynamic_wallpaper_status,
            "show_desktop_widget": self._show_desktop_widget_status,
        }
        try:
            with open(self.CACHE_FILE_PATH, "w") as f:
                json.dump(new_data, f, indent=2)
        except Exception as e:
            logging.exception("Error caching variables: %s", e)

    def _load_cached_variables(self) -> None:
        """
        Loads cached theme variables from a file.
        """
        try:
            with open(self.CACHE_FILE_PATH, "r") as f:
                cached_data = json.load(f)
            self.selected_theme = cached_data.get(
                "selected_theme", BLACK_HOLE_THEME
            )
            self.selected_dark_wallpaper = cached_data.get(
                "selected_dark_wallpaper", 0
            )
            self.selected_light_wallpaper = cached_data.get(
                "selected_light_wallpaper", 0
            )
            self._dynamic_wallpaper_status = cached_data.get(
                "dynamic_wallpaper_status", True
            )
            self._show_desktop_widget_status = cached_data.get(
                "show_desktop_widget", True
            )
        except (FileNotFoundError, json.JSONDecodeError, TypeError) as e:
            logging.warning("Error loading cached variables, recaching: %s", e)
            self._cache_variables()

    def apply_cached_theme(self) -> None:
        """
        Applies the theme based on the cached variables.
        """
        self.change_theme(self.selected_theme)
