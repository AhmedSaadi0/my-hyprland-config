import json
import os
from typing import TypedDict


class Utils:
    USER = os.environ.get("USER") or os.environ.get("USERNAME")

    @staticmethod
    def readFile(path):
        try:
            with open(path, "r") as f:
                return f.read()
        except FileNotFoundError:
            return None
        except Exception as e:
            print(f"Error reading file {path}: {e}")
            return None

    @staticmethod
    def get_user_config_path(filename=".ahmed-config.json"):
        return os.path.join(os.path.expanduser("~"), filename)


class IconSettings(TypedDict):
    hot_weather: str
    cold_weather: str
    mosque: str
    high_energy_rate: str
    high_voltage: str
    high_temp_warning: str


class AudioSettings(TypedDict):
    cold_weather: str
    prayer_time: str
    desktop_login: str
    desktop_logout: str
    high_energy_rate: str
    warning: str
    high_voltage: str
    high_temp_warning: str
    notificationAlert: str
    cpuHighUsage: str


class AssetsSettings(TypedDict):
    wallpapers: str
    icons: IconSettings
    audio: AudioSettings


class ScriptsSettings(TypedDict):
    scripts: str
    dynamicM3Py: str
    get_wallpapers: str
    createThumbnail: str
    gtk_theme: str
    systemInfo: str
    deviceLocal: str
    cpu: str
    ram: str
    deviceTemp: str
    hardwareInfo: str
    cpuUsage: str
    ramUsage: str
    cpuCores: str
    devicesTemp2: str
    playerctl: str


class MenuTransitionsSettings(TypedDict):
    mainMenu: str
    weatherMenu: str
    networkMenu: str
    notificationMenu: str
    prayerTimesMenu: str
    hardwareMenu: str
    audioMenu: str
    calendarMenu: str
    mainMenuDuration: int
    weatherMenuDuration: int
    networkMenuDuration: int
    notificationMenuDuration: int
    prayerTimesMenuDuration: int
    hardwareMenuDuration: int
    audioMenuDuration: int
    calendarMenuDuration: int


class ThemeSettings(TypedDict):
    scss: str
    absoluteDynamicM3Scss: str
    mainCss: str
    styleCss: str
    darkM3WallpaperPath: str
    lightM3WallpaperPath: str
    menuTransitions: MenuTransitionsSettings


class WeatherSettings(TypedDict):
    language: str
    location: str
    format: str


class PrayerTimesSettings(TypedDict):
    city: str
    country: str


class HardwareNetworkSettings(TypedDict):
    rx_path: str
    tx_path: str
    timeout: str
    interval: str


class HardwareSettings(TypedDict):
    network: HardwareNetworkSettings


class MenuTabsSettings(TypedDict):
    dashboard: str
    notifications: str
    weather: str
    monitor: str
    calender: str  # Note: "calender" likely should be "calendar"
    network: str


class Settings:
    username: str
    profile_picture: str
    use_prayer_times: bool
    changePlasmaColor: bool
    assets: AssetsSettings
    scripts: ScriptsSettings
    theme: ThemeSettings
    weather: WeatherSettings
    prayerTimes: PrayerTimesSettings
    hardware: HardwareSettings
    menuTabs: MenuTabsSettings

    MAIN_PATH = os.path.expanduser("~/.config/fabric/")
    ASSETS_PATH = os.path.join(MAIN_PATH, "assets")

    def __init__(self):
        self._load_config()
        self._initialize_paths()
        self._initialize_settings()

    def _get_assets_path(self, path: str) -> str:
        return os.path.join(self.ASSETS_PATH, path)

    def _get_path(self, path: str) -> str:
        return os.path.join(self.MAIN_PATH, path)

    def _load_config(self):
        config_file_path = Utils.get_user_config_path()
        config_content = Utils.readFile(config_file_path)
        if config_content:
            try:
                self.config_data = json.loads(config_content)
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON from {config_file_path}: {e}")
                self.config_data = (
                    {}
                )  # Initialize as empty dict to avoid errors later
        else:
            print(f"Could not read config file: {config_file_path}")
            self.config_data = {}  # Initialize as empty dict

    def _initialize_paths(self):
        self.scripts_paths = {
            "scripts": self._get_path("scripts"),
            "dynamicM3Py": self.config_data.get("scripts", {}).get(
                "dynamicM3Py"
            )
            or self._get_path("scripts/m3/dynamic-m3.py"),
            "get_wallpapers": self.config_data.get("scripts", {}).get(
                "get_wallpapers"
            )
            or self._get_path("scripts/get_wallpapers.sh"),
            "createThumbnail": self.config_data.get("scripts", {}).get(
                "createThumbnail"
            )
            or self._get_path("scripts/m3/create_thumbnail.py"),
            "gtk_theme": self.config_data.get("scripts", {}).get("gtk_theme")
            or self._get_path("scripts/m3/gtk_theme.py"),
            "systemInfo": self.config_data.get("scripts", {}).get("systemInfo")
            or self._get_path("scripts/system_info.sh"),
            "deviceLocal": self.config_data.get("scripts", {}).get(
                "deviceLocal"
            )
            or self._get_path("scripts/lang.sh"),
            "cpu": self.config_data.get("scripts", {}).get("cpu")
            or self._get_path("scripts/cpu.sh"),
            "ram": self.config_data.get("scripts", {}).get("ram")
            or self._get_path("scripts/ram.sh"),
            "deviceTemp": self.config_data.get("scripts", {}).get("deviceTemp")
            or self._get_path("scripts/devices_temps.sh"),
            "hardwareInfo": self.config_data.get("scripts", {}).get(
                "hardwareInfo"
            )
            or self._get_path("scripts/hardware_info.sh"),
            "cpuUsage": self.config_data.get("scripts", {}).get("cpuUsage")
            or self._get_path("scripts/cpu_usage.sh"),
            "ramUsage": self.config_data.get("scripts", {}).get("ramUsage")
            or self._get_path("scripts/ram_usage.sh"),
            "cpuCores": self.config_data.get("scripts", {}).get("cpuCores")
            or self._get_path("scripts/cpu_cores.sh"),
            "devicesTemp2": self.config_data.get("scripts", {}).get(
                "devicesTemp2"
            )
            or self._get_path("scripts/temp.sh"),
            "playerctl": self.config_data.get("scripts", {}).get("playerctl")
            or os.path.join(
                os.path.expanduser("~"), ".config/hypr/scripts/playerctl.sh"
            ),
        }

        self.assets_paths = {
            "wallpapers": self._get_assets_path("wallpapers"),
            "icons": {
                "hot_weather": os.path.join(
                    self._get_assets_path("icons"), "hot-weather.png"
                ),
                "cold_weather": os.path.join(
                    self._get_assets_path("icons"), "cold-weather.png"
                ),
                "mosque": os.path.join(
                    self._get_assets_path("icons"), "mosque.png"
                ),
                "high_energy_rate": os.path.join(
                    self._get_assets_path("icons"),
                    "electrical-danger-sign.png",
                ),
                "high_voltage": os.path.join(
                    self._get_assets_path("icons"),
                    "electrical-danger-sign.png",
                ),
                "high_temp_warning": os.path.join(
                    self._get_assets_path("icons"),
                    "electrical-danger-sign.png",
                ),
            },
            "audio": {
                "cold_weather": os.path.join(
                    self._get_assets_path("audio"), "cold-weather.mp3"
                ),
                "prayer_time": os.path.join(
                    self._get_assets_path("audio"), "prayer-notification.ogg"
                ),
                "desktop_login": os.path.join(
                    self._get_assets_path("audio"), "desktop-login.mp3"
                ),
                "desktop_logout": os.path.join(
                    self._get_assets_path("audio"), "desktop-logout.mp3"
                ),
                "high_energy_rate": os.path.join(
                    self._get_assets_path("audio"), "warning-sound.mp3"
                ),
                "warning": os.path.join(
                    self._get_assets_path("audio"), "warning-sound.mp3"
                ),
                "high_voltage": os.path.join(
                    self._get_assets_path("audio"), "warning-sound.mp3"
                ),
                "high_temp_warning": os.path.join(
                    self._get_assets_path("audio"), "warning-sound.mp3"
                ),
                "notificationAlert": os.path.join(
                    self._get_assets_path("audio"),
                    "mixkit-positive-notification.wav",
                ),
                "cpuHighUsage": os.path.join(
                    self._get_assets_path("audio"), "cpu_high_usage.wav"
                ),
            },
        }

        self.theme_paths = {
            "scss": self._get_path("scss"),
            "absoluteDynamicM3Scss": self._get_path(
                "scss/themes/m3/dynamic.scss"
            ),
            "mainCss": self._get_path("/scss/main.scss"),
            "styleCss": self._get_path("/style.scss"),
        }

    def _initialize_settings(self):
        config_data = self.config_data  # For easier access

        self.username = config_data.get("username", "")
        self.profile_picture = config_data.get("profilePicture", "")
        self.use_prayer_times = config_data.get("usePrayerTimes", False)
        self.change_plasma_theme = config_data.get("changePlasmaTheme", True)

        self.assets = AssetsSettings(self.assets_paths)
        self.scripts = ScriptsSettings(self.scripts_paths)

        self.theme = ThemeSettings(
            {  # Construct ThemeSettingsDict directly
                "scss": self.theme_paths["scss"],
                "absoluteDynamicM3Scss": self.theme_paths[
                    "absoluteDynamicM3Scss"
                ],
                "mainCss": self.theme_paths["mainCss"],
                "styleCss": self.theme_paths["styleCss"],
                "darkM3WallpaperPath": config_data.get(
                    "darkM3WallpaperPath", ""
                ),
                "lightM3WallpaperPath": config_data.get(
                    "lightM3WallpaperPath", ""
                ),
                "menuTransitions": MenuTransitionsSettings(
                    {  # Nested TypedDict construction
                        "mainMenu": "slide_down",
                        "weatherMenu": "slide_down",
                        "networkMenu": "slide_down",
                        "notificationMenu": "slide_down",
                        "prayerTimesMenu": "slide_down",
                        "hardwareMenu": "slide_down",
                        "audioMenu": "slide_down",
                        "calendarMenu": "slide_down",
                        "mainMenuDuration": config_data.get("theme", {})
                        .get("menuTransitions", {})
                        .get("mainMenuDuration", 300),
                        "weatherMenuDuration": config_data.get("theme", {})
                        .get("menuTransitions", {})
                        .get("weatherMenuDuration", 300),
                        "networkMenuDuration": config_data.get("theme", {})
                        .get("menuTransitions", {})
                        .get("networkMenuDuration", 300),
                        "notificationMenuDuration": config_data.get(
                            "theme", {}
                        ).get("notificationMenuDuration", 300),
                        "prayerTimesMenuDuration": config_data.get(
                            "theme", {}
                        ).get("prayerTimesMenuDuration", 300),
                        "hardwareMenuDuration": config_data.get(
                            "theme", {}
                        ).get("hardwareMenuDuration", 300),
                        "audioMenuDuration": config_data.get("theme", {}).get(
                            "audioMenuDuration", 300
                        ),
                        "calendarMenuDuration": config_data.get(
                            "theme", {}
                        ).get("calendarMenuDuration", 300),
                    }
                ),
            }
        )

        self.weather = WeatherSettings(
            {  # Construct WeatherSettingsDict
                "language": "ar",
                "location": config_data.get("weatherLocation", ""),
                "format": "j1",
            }
        )

        self.prayerTimes = PrayerTimesSettings(
            {  # Construct PrayerTimesSettingsDict
                "city": config_data.get("city", ""),
                "country": config_data.get("country", ""),
            }
        )

        self.hardware = HardwareSettings(
            {  # Construct HardwareSettingsDict
                "network": HardwareNetworkSettings(
                    {  # Nested TypedDict construction
                        "rx_path": f"/sys/class/net/{config_data.get('networkMonitor', '')}/statistics/rx_bytes",
                        "tx_path": f"/sys/class/net/{config_data.get('networkMonitor', '')}/statistics/tx_bytes",
                        "timeout": config_data.get("networkTimeout", ""),
                        "interval": config_data.get("networkInterval", ""),
                    }
                )
            }
        )

        self.menuTabs = MenuTabsSettings(
            {  # Construct MenuTabsSettingsDict
                "dashboard": "dashboard",
                "notifications": "notifications",
                "weather": "weather",
                "monitor": "monitor",
                "calender": "calender",  # Note: "calender" likely should be "calendar"
                "network": "network",
            }
        )


def get_settings():
    settings = Settings()
    return settings
