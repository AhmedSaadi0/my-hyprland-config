pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string mainPath: Quickshell.shellRoot
    readonly property var homePath: mainPath.split(".")[0]
    readonly property var configFilePath: homePath + ".nibrasshell.json"
    readonly property string assetsPath: mainPath + "/assets"
    readonly property string bashScriptsPath: mainPath + "/scripts"
    readonly property string pythonScriptsPath: mainPath + "/scripts/python"
    readonly property string wallpapersPath: assetsPath + "/wallpapers"
    readonly property string cacheFolderPath: homePath + ".cache/nibrasshell"
    readonly property string themeCacheFilePath: cacheFolderPath + "/theme.json"
    readonly property string themeCacheFolderPath: cacheFolderPath + "/themes/"

    // --------------------------------------------------------------
    property string username: "Username"
    property string subtitle: "subtitle"
    property string profilePicture: "file://" + assetsPath + "/icons/profile-modified.png"
    property string networkMonitor: "wlp0s20f3"
    property int networkInterval: 400
    property string darkM3WallpaperPath: homePath + "wallpapers/dark/"
    property string lightM3WallpaperPath: homePath + "wallpapers/light/"
    property string city: "sanaa"
    property string country: "yemen"
    property string weatherLocation: "sanaa"
    property bool usePrayerTimes: true
    // -------------------------------------------------------------------------

    Component.onCompleted: {
        Hyprland.dispatch(`exec mkdir -p ${cacheFolderPath}`);
        Hyprland.dispatch(`exec mkdir -p ${themeCacheFolderPath}`);
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl(root.configFilePath)
        onLoaded: {
            const fileContents = JSON.parse(fileView.text());
            root.username = fileContents.username;
            root.subtitle = fileContents.subtitle !== undefined ? fileContents.subtitle : "";
            root.profilePicture = fileContents.profilePicture;
            root.networkMonitor = fileContents.networkMonitor;
            root.networkInterval = fileContents.networkInterval;
            root.darkM3WallpaperPath = fileContents.darkM3WallpaperPath;
            root.lightM3WallpaperPath = fileContents.lightM3WallpaperPath;
            root.city = fileContents.city;
            root.country = fileContents.country;
            root.weatherLocation = fileContents.weatherLocation;
            root.usePrayerTimes = fileContents.usePrayerTimes;
        }
    }

    // كائن لتنظيم مسارات الأصول (Assets)
    readonly property QtObject assets: QtObject {
        readonly property QtObject icons: QtObject {
            readonly property string notification: root.assetsPath + "/icons/notification.png"
            readonly property string weather: root.assetsPath + "/icons/weather-icon.png"
            readonly property string hotWeather: root.assetsPath + "/icons/hot-weather.png"
            readonly property string coldWeather: root.assetsPath + "/icons/cold-weather.png"
            readonly property string fog: root.assetsPath + "/icons/fog.png"
            readonly property string rain: root.assetsPath + "/icons/rain.png"
            readonly property string wind: root.assetsPath + "/icons/wind.png"
            readonly property string thunder: root.assetsPath + "/icons/thunder.png"
            readonly property string mosque: root.assetsPath + "/icons/mosque.png"
            readonly property string highEnergyRate: root.assetsPath + "/icons/electrical-danger-sign.png"
            readonly property string highVoltage: root.assetsPath + "/icons/electrical-danger-sign.png"
            readonly property string highTempWarning: root.assetsPath + "/icons/electrical-danger-sign.png"
        }
        readonly property QtObject audio: QtObject {
            readonly property string hotWeather: root.assetsPath + "/audio/cold-weather.mp3"
            readonly property string coldWeather: root.assetsPath + "/audio/cold-weather.mp3"
            readonly property string prayerTime: root.assetsPath + "/audio/prayer-notification.ogg"
            readonly property string desktopLogin: root.assetsPath + "/audio/desktop-login.mp3"
            readonly property string desktopLogout: root.assetsPath + "/audio/desktop-logout.mp3"
            readonly property string highEnergyRate: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string warning: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string highVoltage: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string highTempWarning: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string notificationAlert: root.assetsPath + "/audio/new-notification.mp3"
            readonly property string cpuHighUsage: root.assetsPath + "/audio/cpu_high_usage.wav"
        }

        function getWallpaperPath(wallpaper) {
            return root.wallpapersPath + "/" + wallpaper;
        }
    }

    readonly property QtObject scripts: QtObject {
        readonly property QtObject python: QtObject {
            // Monotoring
            readonly property string batteryInfo: root.pythonScriptsPath + "/battery_info.py"
            readonly property string devicesTemp: root.pythonScriptsPath + "/devices_temp.py"
            readonly property string topCpuUsage: root.pythonScriptsPath + "/top_cpu_usage.py"
            readonly property string topRamUsage: root.pythonScriptsPath + "/top_ram_usage.py"

            // Wallpaper coloring
            readonly property string dynamicM3: root.pythonScriptsPath + "/m3/dynamic-m3.py"

            // Depth effect
            readonly property string rembgOverylayWallpaper: root.pythonScriptsPath + "/create_depth_image_rembg.py"
            readonly property string opencvOverylayWallpaper: root.pythonScriptsPath + "/create_depth_image_opencv.py"
            readonly property string removeUnusedCachedOverlayImages: root.pythonScriptsPath + "/overlay_cache_images_cleaner.py"

            // WIFI
            readonly property string listWifi: root.pythonScriptsPath + "/network/list_wifi.py"
            readonly property string connectWifi: root.pythonScriptsPath + "/network/connect_wifi.py"
            readonly property string dataUsage: root.pythonScriptsPath + "/network/data_usage.py"
            readonly property string liveUsage: root.pythonScriptsPath + "/network/live_usage.py"

            // Commands
            readonly property var batteryInfoCommand: ["python", batteryInfo]
            readonly property var devicesTempCommand: ["python", devicesTemp]
            readonly property var topCpuUsageCommand: ["python", topCpuUsage]
            readonly property var topRamUsageCommand: ["python", topRamUsage]
            readonly property var dynamicM3Command: ["python", dynamicM3]
            readonly property var rembgOverylayWallpaperCommand: ["python", rembgOverylayWallpaper]
            readonly property var opencvOverylayWallpaperCommand: ["python", opencvOverylayWallpaper]
            readonly property var removeUnusedCachedOverlayImagesCommand: ["python", removeUnusedCachedOverlayImages]

            readonly property var listWifiCommand: ["python", listWifi]
            readonly property var liveUsageCommand: ["python", liveUsage]
            readonly property var dataUsageCommand: ["python", dataUsage]
            readonly property var connectWifiCommand: ["python", connectWifi]
        }

        readonly property QtObject bash: QtObject {
            // Files
            readonly property string cpuUsage: root.bashScriptsPath + "/cpu_usage.sh"
            readonly property string ramUsage: root.bashScriptsPath + "/ram_usage.sh"
            readonly property string internet: root.bashScriptsPath + "/internet.sh"
            readonly property string deviceTempreture: root.bashScriptsPath + "/temp.sh"
            readonly property string playerctl: root.homePath + "/.config/hypr/scripts/playerctl.sh"
            readonly property string getWallpapers: root.bashScriptsPath + "/get_wallpapers.sh"

            // Commands
            readonly property var internetCommand: ["sh", "-c", `${internet} ${root.networkMonitor}`]
            readonly property var cpuCommand: ["sh", "-c", cpuUsage]
            readonly property var ramCommand: ["sh", "-c", ramUsage]
            readonly property var deviceTempretureCommand: ["sh", "-c", deviceTempreture]
        }
    }

    readonly property QtObject weather: QtObject {
        readonly property string language: "ar"
        readonly property string location: root.weatherLocation
        readonly property string format: "j1"
    }

    readonly property QtObject prayerTimes: QtObject {
        readonly property string city: root.city
        readonly property string country: root.country
    }

    function dispatchCommand(description, commandArray) {
        if (!Array.isArray(commandArray) || commandArray.length === 1) {
            console.warn(`Skipping empty command: ${description}`);
            return;
        }
        console.info(description + " -> " + commandArray.join(' '));
        Hyprland.dispatch(`exec ${commandArray.join(' ')}`);
    }
}
