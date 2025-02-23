import json
import os
from dataclasses import dataclass, field


class Utils:
    USER = os.environ.get("USER") or os.environ.get("USERNAME")

    @staticmethod
    def read_file(path: str) -> str:
        try:
            with open(path, "r") as f:
                return f.read()
        except FileNotFoundError:
            return None
        except Exception as e:
            print(f"Error reading file {path}: {e}")
            return None

    @staticmethod
    def get_user_config_path(filename: str = ".ahmed-config.json") -> str:
        return os.path.join(os.path.expanduser("~"), filename)


@dataclass
class IconSettings:
    hot_weather: str = ""
    cold_weather: str = ""
    mosque: str = ""
    high_energy_rate: str = ""
    high_voltage: str = ""
    high_temp_warning: str = ""


@dataclass
class AudioSettings:
    cold_weather: str = ""
    prayer_time: str = ""
    desktop_login: str = ""
    desktop_logout: str = ""
    high_energy_rate: str = ""
    warning: str = ""
    high_voltage: str = ""
    high_temp_warning: str = ""
    notificationAlert: str = ""
    cpuHighUsage: str = ""


@dataclass
class AssetsSettings:
    wallpapers: str = ""
    icons: IconSettings = field(default_factory=IconSettings)
    audio: AudioSettings = field(default_factory=AudioSettings)


@dataclass
class ScriptsSettings:
    scripts: str = ""
    get_wallpapers: str = ""
    systemInfo: str = ""
    deviceLocal: str = ""
    cpu: str = ""
    ram: str = ""
    deviceTemp: str = ""
    hardwareInfo: str = ""
    cpuUsage: str = ""
    ramUsage: str = ""
    cpuCores: str = ""
    devicesTemp2: str = ""
    playerctl: str = ""


@dataclass
class MenuTransitionsSettings:
    mainMenu: str = ""
    weatherMenu: str = ""
    networkMenu: str = ""
    notificationMenu: str = ""
    prayerTimesMenu: str = ""
    hardwareMenu: str = ""
    audioMenu: str = ""
    calendarMenu: str = ""
    mainMenuDuration: int = 300
    weatherMenuDuration: int = 0
    networkMenuDuration: int = 0
    notificationMenuDuration: int = 0
    prayerTimesMenuDuration: int = 0
    hardwareMenuDuration: int = 0
    audioMenuDuration: int = 0
    calendarMenuDuration: int = 0


@dataclass
class ThemeSettings:
    scss_project_path: str = ""
    styles_scss: str = ""
    styles_css: str = ""
    dark_m3_wallpaper_path: str = ""
    light_m3_wallpaper_path: str = ""
    menu_transitions: MenuTransitionsSettings = field(
        default_factory=MenuTransitionsSettings
    )


@dataclass
class WeatherSettings:
    language: str = "ar"
    location: str = ""
    format: str = "j1"


@dataclass
class PrayerTimesSettings:
    city: str = ""
    country: str = ""


@dataclass
class HardwareNetworkSettings:
    rx_path: str = ""
    tx_path: str = ""
    timeout: str = ""
    interval: str = ""


@dataclass
class HardwareSettings:
    network: HardwareNetworkSettings = field(
        default_factory=HardwareNetworkSettings
    )


@dataclass
class MenuTabsSettings:
    dashboard: str = "dashboard"
    notifications: str = "notifications"
    weather: str = "weather"
    monitor: str = "monitor"
    calendar: str = "calendar"
    network: str = "network"


class Settings:
    MAIN_PATH = os.path.expanduser("~/.config/fabric/")
    ASSETS_PATH = os.path.join(MAIN_PATH, "assets")

    def __init__(self):
        self._load_config()
        self._initialize_paths()
        self._initialize_settings()

    def _get_assets_path(self, *paths) -> str:
        return os.path.join(self.ASSETS_PATH, *paths)

    def _get_path(self, *paths) -> str:
        return os.path.join(self.MAIN_PATH, *paths)

    @staticmethod
    def get_cache_path() -> str:
        path = os.path.expanduser("~/.cache/ahmed-config/")
        os.makedirs(path, exist_ok=True)
        return path

    @staticmethod
    def get_cache_file() -> str:
        return os.path.join(
            Settings.get_cache_path(), "ahmed-hyprland-conf.json"
        )

    def _load_config(self):
        config_file_path = Utils.get_user_config_path()
        config_content = Utils.read_file(config_file_path)
        if config_content:
            try:
                self.config_data = json.loads(config_content)
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON from {config_file_path}: {e}")
                self.config_data = {}
        else:
            print(f"Could not read config file: {config_file_path}")
            self.config_data = {}

    def _initialize_paths(self):
        scripts_config = self.config_data.get("scripts", {})
        default_scripts = {
            "get_wallpapers": "scripts/get_wallpapers.sh",
            "systemInfo": "scripts/system_info.sh",
            "deviceLocal": "scripts/lang.sh",
            "cpu": "scripts/cpu.sh",
            "ram": "scripts/ram.sh",
            "deviceTemp": "scripts/devices_temps.sh",
            "hardwareInfo": "scripts/hardware_info.sh",
            "cpuUsage": "scripts/cpu_usage.sh",
            "ramUsage": "scripts/ram_usage.sh",
            "cpuCores": "scripts/cpu_cores.sh",
            "devicesTemp2": "scripts/temp.sh",
        }

        self.scripts_paths = {"scripts": self._get_path("scripts")}
        for key, default in default_scripts.items():
            self.scripts_paths[key] = scripts_config.get(
                key
            ) or self._get_path(default)

        self.scripts_paths["playerctl"] = scripts_config.get(
            "playerctl"
        ) or os.path.join(
            os.path.expanduser("~"), ".config/hypr/scripts/playerctl.sh"
        )

        icons_base = self._get_assets_path("icons")
        audio_base = self._get_assets_path("audio")
        warning_icon = os.path.join(icons_base, "electrical-danger-sign.png")
        warning_audio = os.path.join(audio_base, "warning-sound.mp3")

        self.assets_paths = {
            "wallpapers": self._get_assets_path("wallpapers"),
            "icons": {
                "hot_weather": os.path.join(icons_base, "hot-weather.png"),
                "cold_weather": os.path.join(icons_base, "cold-weather.png"),
                "mosque": os.path.join(icons_base, "mosque.png"),
                "high_energy_rate": warning_icon,
                "high_voltage": warning_icon,
                "high_temp_warning": warning_icon,
            },
            "audio": {
                "cold_weather": os.path.join(audio_base, "cold-weather.mp3"),
                "prayer_time": os.path.join(
                    audio_base, "prayer-notification.ogg"
                ),
                "desktop_login": os.path.join(audio_base, "desktop-login.mp3"),
                "desktop_logout": os.path.join(
                    audio_base, "desktop-logout.mp3"
                ),
                "high_energy_rate": warning_audio,
                "warning": warning_audio,
                "high_voltage": warning_audio,
                "high_temp_warning": warning_audio,
                "notificationAlert": os.path.join(
                    audio_base, "mixkit-positive-notification.wav"
                ),
                "cpuHighUsage": os.path.join(audio_base, "cpu_high_usage.wav"),
            },
        }
        self.theme_paths = {}

    def _initialize_settings(self):
        config = self.config_data
        self.username = config.get("username", "")
        self.profile_picture = config.get("profilePicture", "")
        self.use_prayer_times = config.get("usePrayerTimes", False)
        self.change_plasma_theme = config.get("changePlasmaTheme", True)

        self.assets = AssetsSettings(
            wallpapers=self.assets_paths.get("wallpapers", ""),
            icons=IconSettings(**self.assets_paths.get("icons", {})),
            audio=AudioSettings(**self.assets_paths.get("audio", {})),
        )

        self.scripts = ScriptsSettings(**self.scripts_paths)

        self.theme = ThemeSettings(
            scss_project_path=self._get_path("scss"),
            styles_scss=self._get_path("scss", "main.scss"),
            styles_css=os.path.join(Settings.get_cache_path(), "main.css"),
            dark_m3_wallpaper_path=config.get("darkM3WallpaperPath", ""),
            light_m3_wallpaper_path=config.get("lightM3WallpaperPath", ""),
            menu_transitions=MenuTransitionsSettings(
                mainMenu="slide_down",
                weatherMenu="",
                networkMenu="",
                notificationMenu="",
                prayerTimesMenu="",
                hardwareMenu="",
                audioMenu="",
                calendarMenu="",
                mainMenuDuration=config.get("theme", {})
                .get("menuTransitions", {})
                .get("mainMenuDuration", 300),
            ),
        )

        self.weather = WeatherSettings(
            location=config.get("weatherLocation", "")
        )

        self.prayerTimes = PrayerTimesSettings(
            city=config.get("city", ""), country=config.get("country", "")
        )

        self.hardware = HardwareSettings(
            network=HardwareNetworkSettings(
                rx_path=f"/sys/class/net/{config.get('networkMonitor', '')}/statistics/rx_bytes",
                tx_path=f"/sys/class/net/{config.get('networkMonitor', '')}/statistics/tx_bytes",
                timeout=config.get("networkTimeout", ""),
                interval=config.get("networkInterval", ""),
            )
        )

        self.menuTabs = MenuTabsSettings()


def get_settings() -> Settings:
    return Settings()
