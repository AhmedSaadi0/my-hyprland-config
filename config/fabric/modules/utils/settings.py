import json
import os


class Settings:
    MAIN_PATH = f"{os.getenv('HOME')}/.config/ahmed"
    ASSETS_PATH = f"{MAIN_PATH}/assets"

    @staticmethod
    def get_assets(path: str) -> str:
        return f"{Settings.ASSETS_PATH}/{path}"

    @staticmethod
    def get_path(path: str) -> str:
        return f"{Settings.MAIN_PATH}/{path}"

    def __init__(self):
        self.network_monitor = ""
        self.network_timeout = ""
        self.network_interval = ""
        self.dark_m3_wallpaper_path = ""
        self.light_m3_wallpaper_path = ""
        self.weather_location = ""
        self.city = ""
        self.country = ""
        self.username = ""
        self.profile_picture = ""
        self.use_prayer_times = False
        self.change_plasma_color = True

        self.scripts = {}

        self.load_config()

    def load_config(self):
        try:
            config_path = f"{os.getenv('HOME')}/.ahmed-config.json"
            with open(config_path, "r") as file:
                config_file = json.load(file)

            self.network_monitor = config_file.get("networkMonitor", "")
            self.dark_m3_wallpaper_path = config_file.get("darkM3WallpaperPath", "")
            self.light_m3_wallpaper_path = config_file.get("lightM3WallpaperPath", "")
            self.weather_location = config_file.get("weatherLocation", "")
            self.city = config_file.get("city", "")
            self.country = config_file.get("country", "")
            self.network_timeout = config_file.get("networkTimeout", "")
            self.network_interval = config_file.get("networkInterval", "")
            self.username = config_file.get("username", "")
            self.profile_picture = config_file.get("profilePicture", "")
            self.use_prayer_times = config_file.get("usePrayerTimes", False)
            self.change_plasma_color = config_file.get("changePlasmaColor", True)

            self.scripts = config_file.get("scripts", {})
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(f"Error reading .ahmed-config.json file: {e}")

    @property
    def settings(self):
        return {
            "username": self.username,
            "profile_picture": self.profile_picture,
            "use_prayer_times": self.use_prayer_times,
            "change_plasma_color": self.change_plasma_color,
            "assets": {
                "wallpapers": self.get_assets("wallpapers"),
                "icons": {
                    "hot_weather": self.get_assets("icons/hot-weather.png"),
                    "cold_weather": self.get_assets("icons/cold-weather.png"),
                    "mosque": self.get_assets("icons/mosque.png"),
                    "high_energy_rate": self.get_assets(
                        "icons/electrical-danger-sign.png"
                    ),
                    "high_voltage": self.get_assets("icons/electrical-danger-sign.png"),
                    "high_temp_warning": self.get_assets(
                        "icons/electrical-danger-sign.png"
                    ),
                },
                "audio": {
                    "cold_weather": self.get_assets("audio/cold-weather.mp3"),
                    "prayer_time": self.get_assets("audio/prayer-notification.ogg"),
                    "desktop_login": self.get_assets("audio/desktop-login.mp3"),
                    "desktop_logout": self.get_assets("audio/desktop-logout.mp3"),
                    "high_energy_rate": self.get_assets("audio/warning-sound.mp3"),
                    "warning": self.get_assets("audio/warning-sound.mp3"),
                    "high_voltage": self.get_assets("audio/warning-sound.mp3"),
                    "high_temp_warning": self.get_assets("audio/warning-sound.mp3"),
                    "notification_alert": self.get_assets(
                        "audio/mixkit-positive-notification.wav"
                    ),
                    "cpu_high_usage": self.get_assets("audio/cpu_high_usage.wav"),
                },
            },
            "scripts": {
                "scripts": self.get_path("scripts"),
                "dynamic_m3_py": self.scripts.get(
                    "dynamicM3Py", self.get_path("scripts/m3/dynamic-m3.py")
                ),
                "get_wallpapers": self.scripts.get(
                    "get_wallpapers", self.get_path("scripts/get_wallpapers.sh")
                ),
                "create_thumbnail": self.scripts.get(
                    "createThumbnail", self.get_path("scripts/m3/create_thumbnail.py")
                ),
                "gtk_theme": self.scripts.get(
                    "gtk_theme", self.get_path("scripts/m3/gtk_theme.py")
                ),
                "system_info": self.scripts.get(
                    "systemInfo", self.get_path("scripts/system_info.sh")
                ),
                "device_local": self.scripts.get(
                    "deviceLocal", self.get_path("scripts/lang.sh")
                ),
                "cpu": self.scripts.get("cpu", self.get_path("scripts/cpu.sh")),
                "ram": self.scripts.get("ram", self.get_path("scripts/ram.sh")),
                "device_temp": self.scripts.get(
                    "deviceTemp", self.get_path("scripts/devices_temps.sh")
                ),
                "hardware_info": self.scripts.get(
                    "hardwareInfo", self.get_path("scripts/hardware_info.sh")
                ),
                "cpu_usage": self.scripts.get(
                    "cpuUsage", self.get_path("scripts/cpu_usage.sh")
                ),
                "ram_usage": self.scripts.get(
                    "ramUsage", self.get_path("scripts/ram_usage.sh")
                ),
                "cpu_cores": self.scripts.get(
                    "cpuCores", self.get_path("scripts/cpu_cores.sh")
                ),
                "devices_temp2": self.scripts.get(
                    "devicesTemp2", self.get_path("scripts/temp.sh")
                ),
                "playerctl": self.scripts.get(
                    "playerctl",
                    f"{os.getenv('HOME')}/.config/hypr/scripts/playerctl.sh",
                ),
            },
            "theme": {
                "scss": self.get_path("scss"),
                "absolute_dynamic_m3_scss": self.get_path(
                    "scss/themes/m3/dynamic.scss"
                ),
                "main_css": self.get_path("/scss/main.scss"),
                "style_css": self.get_path("/style.scss"),
                "dark_m3_wallpaper_path": self.dark_m3_wallpaper_path,
                "light_m3_wallpaper_path": self.light_m3_wallpaper_path,
                "menu_transitions": {
                    "main_menu": "slide_down",
                    "weather_menu": "slide_down",
                    "network_menu": "slide_down",
                    "notification_menu": "slide_down",
                    "prayer_times_menu": "slide_down",
                    "hardware_menu": "slide_down",
                    "audio_menu": "slide_down",
                    "calendar_menu": "slide_down",
                    "main_menu_duration": 300,
                    "weather_menu_duration": 300,
                    "network_menu_duration": 300,
                    "notification_menu_duration": 300,
                    "prayer_times_menu_duration": 300,
                    "hardware_menu_duration": 300,
                    "audio_menu_duration": 300,
                    "calendar_menu_duration": 300,
                },
            },
            "weather": {
                "language": "ar",
                "location": self.weather_location,
                "format": "j1",
            },
            "prayer_times": {
                "city": self.city,
                "country": self.country,
            },
            # "hardware": {
            #     "network": {
            #         "rx_path": f"/sys/class/net/{self.network_monitor}/statistics/rx_bytes",
            #         "tx_path": f"/sys/class/net/{self.network_monitor}/statistics/tx_bytes",
            #         "timeout": self.network_timeout,
            #         "interval": self.network_interval,
            #     },
            # },
            # "menu_tabs": {
            #     "dashboard": "dashboard",
            #     "notifications": "notifications",
            #     "weather": "weather",
            #     "monitor": "monitor",
            #     "calendar": "calendar",
            #     "network": "network",
            # },
        }


# Usage
settings = Settings()
config = settings.settings
