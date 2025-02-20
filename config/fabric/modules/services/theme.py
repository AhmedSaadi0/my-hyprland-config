import json
import logging
import os
import subprocess
from threading import Timer

from fabric.core.service import Property, Service, Signal
from modules.utils.settings import get_settings
from modules.utils.themes import BLACK_HOLE_THEME

settings = get_settings()
logging.basicConfig(level=logging.INFO)

try:
    from modules.utils.themes import DYNAMIC_M3_LIGHT, UNICAT_THEME, ThemesDictionary
except ImportError:
    print(
        "Error: Could not import ThemesDictionary, DYNAMIC_M3_LIGHT, UNICAT_THEME from 'theme/themes.py'. You need to create this file or adjust the import path."
    )
    ThemesDictionary = {}
    DYNAMIC_M3_LIGHT = "dynamic_m3_light"
    UNICAT_THEME = "unicat_theme"


class ThemeService(Service):

    @Signal
    def changed(self) -> None:
        pass

    def __init__(self):
        super().__init__()
        logging.info("Starting theme service")
        try:
            subprocess.run(["swww-daemon"])
        except subprocess.CalledProcessError as e:
            logging.error(e)

        self.selectedTheme = UNICAT_THEME
        self.wallpapersList = []

        self.CACHE_FILE_PATH = os.path.expanduser("~/.cache/ahmed-hyprland-conf.temp")
        self.wallpaperIntervalId = None
        self.selectedLightWallpaper = 0
        self.selectedDarkWallpaper = 0
        self._dynamicWallpaperStatus = True
        self._showDesktopWidgetStatus = True

        self.get_cached_variables()

    @Property(str, flags="r")
    def dynamic_wallpaper_is_on(self):
        return self._dynamicWallpaperStatus

    @Property(str, flags="r")
    def is_dynamic_theme(self):
        return ThemesDictionary.get(self.selectedTheme, {}).get("dynamic", False)

    def change_theme(self, selectedTheme):
        """Changes the system theme to the specified theme."""
        theme = ThemesDictionary.get(selectedTheme)
        if not theme:
            logging.warning(f"Theme '{selectedTheme}' not found in ThemesDictionary.")
            return

        self.clear_dynamic_wallpaper_interval()

        is_dynamic = theme.dynamic

        if is_dynamic:
            self.set_dynamic_wallpapers(
                theme.wallpaper_path, theme.gtk_mode, theme.interval
            )
        else:
            self.change_css(theme.css_theme)
            self.change_wallpaper(theme.wallpaper)

        if settings.change_plasma_color:
            self.change_plasma_color(theme.plasma_color)
            self.change_plasma_icons(theme.qt_icon_theme)
        self.change_konsole_profile(theme.hypr.konsole)

        self.change_gtk_theme(
            theme.gtk_theme,
            theme.gtk_mode,
            theme.gtk_icon_theme,
            theme.font_name,
        )
        if not is_dynamic:
            self.change_gtk4_theme(
                theme.wallpaper,
                theme.gtk_theme,  # "ahmed-config-gtk-theme",
                theme.gtk_mode,
            )

        self.change_kvantum_theme(theme.kvantum_theme)

        if self._showDesktopWidgetStatus:
            self.show_desktop_widget(theme.desktop_widget)

        hypr = theme.hypr
        self.set_hyprland(
            hypr.border_width,
            hypr.active_border,
            hypr.inactive_border,
            hypr.rounding,
            hypr.drop_shadow,
        )

        self.selectedTheme = selectedTheme
        self.emit("changed")
        # prayer_service.emit_changed()

        self.cache_variables()

    def change_wallpaper(self, wallpaper):
        try:
            subprocess.run(
                [
                    "swww",
                    "img",
                    "--transition-type",
                    "random",
                    wallpaper,
                ],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            logging.error(f"Error changing wallpaper: {e}")

    def change_css(self, css_theme):
        scss = settings.theme.get("mainCss")
        css = settings.theme.get("styleCss")

        new_th = f"@import './themes/{css_theme}';"

        try:
            subprocess.run(["sed", "-i", f"1s|.*|{new_th}|", scss], check=True)
            subprocess.run(["sassc", scss, css], check=True)
            # Assuming App has reset_css and apply_css equivalents in Python Fabric
            # App.reset_css()  # Replace with Fabric equivalent if needed
            # App.apply_css(css)  # Replace with Fabric equivalent if needed
        except subprocess.CalledProcessError as e:
            print(f"Error changing CSS: {e}")

    def set_dynamic_wallpapers(self, path, theme_mode, interval):
        try:
            result = subprocess.run(
                [settings.scripts.get("get_wallpapers"), path],
                capture_output=True,
                text=True,
                check=True,
            )
            wallpapers = json.loads(result.stdout)
            self.wallpapersList = wallpapers

            self.call_next_wallpaper(theme_mode)

            if self._dynamicWallpaperStatus:
                self.wallpaperIntervalId = Timer(
                    interval / 1000, self.call_next_wallpaper, args=[theme_mode]
                )
                self.wallpaperIntervalId.start()

        except (subprocess.CalledProcessError, json.JSONDecodeError) as e:
            print(f"Error setting dynamic wallpapers: {e}")

    def toggle_dynamic_wallpaper(self):
        if self.is_dynamic_theme and self._dynamicWallpaperStatus:
            self.stop_dynamic_wallpaper()
        else:
            self.start_dynamic_wallpaper()

    def clear_dynamic_wallpaper_interval(self):
        if self.wallpaperIntervalId:
            self.wallpaperIntervalId.cancel()
            self.wallpaperIntervalId = None

    def stop_dynamic_wallpaper(self):
        self._dynamicWallpaperStatus = False
        self.clear_dynamic_wallpaper_interval()
        theme = ThemesDictionary.get(self.selectedTheme)
        if theme == DYNAMIC_M3_LIGHT:
            self.selectedLightWallpaper = (
                (self.selectedLightWallpaper - 1) % len(self.wallpapersList)
                if self.wallpapersList
                else 0
            )
        else:
            self.selectedDarkWallpaper = (
                (self.selectedDarkWallpaper - 1) % len(self.wallpapersList)
                if self.wallpapersList
                else 0
            )
        self.cache_variables()
        self.emit("changed")

    def start_dynamic_wallpaper(self):
        theme = ThemesDictionary.get(self.selectedTheme)
        self._dynamicWallpaperStatus = True
        self.clear_dynamic_wallpaper_interval()
        self.set_dynamic_wallpapers(
            theme.get("wallpaper_path", ""),
            theme.get("gtk_mode", ""),
            theme.get("interval", 30000),
        )
        self.cache_variables()
        self.emit("changed")

    def call_next_wallpaper(self, theme_mode):
        selected_wallpaper_index = 0

        if theme_mode == "dark":
            selected_wallpaper_index = self.selectedDarkWallpaper
            if self._dynamicWallpaperStatus:
                self.selectedDarkWallpaper = (
                    (self.selectedDarkWallpaper + 1) % len(self.wallpapersList)
                    if self.wallpapersList
                    else 0
                )
        else:
            selected_wallpaper_index = self.selectedLightWallpaper
            if self._dynamicWallpaperStatus:
                self.selectedLightWallpaper = (
                    (self.selectedLightWallpaper + 1) % len(self.wallpapersList)
                    if self.wallpapersList
                    else 0
                )

        wallpaper = (
            self.wallpapersList[selected_wallpaper_index]
            if self.wallpapersList
            else None
        )
        if wallpaper:
            self.change_wallpaper(wallpaper)
            self.create_m3_color_schema(wallpaper, theme_mode)
            self.cache_variables()

    def create_m3_color_schema(self, wallpaper, mode):
        try:
            subprocess.run(
                [
                    "python",
                    settings.scripts.get("dynamicM3Py"),
                    wallpaper,
                    "-m",
                    mode,
                ],
                check=True,
            )
            self.change_css("m3/dynamic.scss")
        except subprocess.CalledProcessError as e:
            print(f"Error creating M3 color schema: {e}")

    def change_plasma_color(self, plasma_color):
        plasma_cmd = "plasma-apply-colorscheme"
        try:
            subprocess.run([plasma_cmd, plasma_color.split(".")[0]], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error changing Plasma color: {e}")

    def change_plasma_icons(self, plasma_icons):
        try:
            subprocess.run(
                [
                    "kwriteconfig5",
                    "--file",
                    os.path.expanduser("~/.config/kdeglobals"),
                    "--group",
                    "Icons",
                    "--key",
                    "Theme",
                    plasma_icons,
                ],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print(f"Error changing Plasma icons: {e}")

    def change_gtk_theme(self, gtk_theme, gtk_mode, icon_theme, font_name):

        def set_gtk_settings():
            try:
                subprocess.run(
                    [
                        "gsettings",
                        "set",
                        "org.gnome.desktop.interface",
                        "gtk-theme",
                        gtk_theme,
                    ],
                    check=True,
                )
                subprocess.run(
                    [
                        "gsettings",
                        "set",
                        "org.gnome.desktop.wm.preferences",
                        "theme",
                        gtk_theme,
                    ],
                    check=True,
                )
            except subprocess.CalledProcessError as e:
                print(f"Error setting GTK theme: {e}")

        Timer(2, set_gtk_settings).start()

        try:
            subprocess.run(
                [
                    "gsettings",
                    "set",
                    "org.gnome.desktop.interface",
                    "icon-theme",
                    icon_theme,
                ],
                check=True,
            )
            subprocess.run(
                [
                    "gsettings",
                    "set",
                    "org.gnome.desktop.interface",
                    "font-name",
                    font_name,
                ],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print(f"Error setting GTK icon theme or font: {e}")

    def change_gtk4_theme(self, wallpaper_path, theme_name, theme_mode):
        try:
            subprocess.run(
                [
                    "python",
                    settings.scripts.get("gtk_theme"),
                    "-p",
                    wallpaper_path,
                    "-n",
                    theme_name,
                    "-m",
                    theme_mode,
                    "-t",
                    "20",
                ],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print(f"Error changing GTK4 theme: {e}")

    def set_hyprland(
        self,
        border_width,
        active_border,
        inactive_border,
        rounding,
        drop_shadow,
    ):
        def hyprctl_commands():
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
                        "decoration:drop_shadow",
                        "yes" if drop_shadow else "no",
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
                print(f"Error setting Hyprland: {e}")

        Timer(0.5, hyprctl_commands).start()  # 0.5 second delay

    def change_konsole_profile(self, konsole_profile):  # Python snake_case
        konsole_profile_data = f"""[Desktop Entry]
DefaultProfile={konsole_profile}.profile

[General]
ConfigVersion=1

[MainWindow]
ToolBarsMovable=Disabled
"""
        try:
            with open(os.path.expanduser("~/.config/konsolerc"), "w") as f:
                f.write(konsole_profile_data)
        except Exception as e:
            print(f"Error writing Konsole profile: {e}")

    def change_kvantum_theme(self, kvantum_theme):
        try:
            subprocess.run(["kvantummanager", "--set", kvantum_theme], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error changing Kvantum theme: {e}")

    def show_desktop_widget(self, widget):
        old_theme = ThemesDictionary.get(self.selectedTheme)
        old_widget = old_theme.get("desktop_widget", None) if old_theme else None

        if old_widget and old_widget != widget:
            self.hide_widget(old_widget)

        if widget:
            Timer(1, self.show_widget, args=[widget]).start()

    def hide_widget(self, function_name):
        try:
            # TODO:
            pass
        except subprocess.CalledProcessError as e:
            print(f"Error hiding widget: {e}")

    def show_widget(self, function_name):
        try:
            # TODO:
            pass
        except subprocess.CalledProcessError as e:
            print(f"Error showing widget: {e}")

    def cache_variables(self):  # Python snake_case
        new_data = {
            "selected_theme": self.selectedTheme,
            "selected_dark_wallpaper": self.selectedDarkWallpaper,
            "selected_light_wallpaper": self.selectedLightWallpaper,
            "dynamic_wallpaper_status": self._dynamicWallpaperStatus,
            "show_desktop_widget": self._showDesktopWidgetStatus,
        }
        try:
            with open(self.CACHE_FILE_PATH, "w") as f:
                json.dump(new_data, f, indent=2)
        except Exception as e:
            print(f"Error caching variables: {e}")

    def get_cached_variables(self):
        try:
            with open(self.CACHE_FILE_PATH, "r") as f:
                cached_data = json.load(f)
            self.selectedTheme = cached_data.get("selected_theme", BLACK_HOLE_THEME)
            self.selectedDarkWallpaper = cached_data.get("selected_dark_wallpaper", 0)
            self.selectedLightWallpaper = cached_data.get("selected_light_wallpaper", 0)
            self._dynamicWallpaperStatus = cached_data.get(
                "dynamic_wallpaper_status", True
            )
            self._showDesktopWidgetStatus = cached_data.get("show_desktop_widget", True)

        except (FileNotFoundError, json.JSONDecodeError, TypeError) as e:
            logging.warning(f"Error loading cached variables, recaching: {e}")
            self.cache_variables()
        self.change_theme(self.selectedTheme)
