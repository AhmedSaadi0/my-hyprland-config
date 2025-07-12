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
            readonly property string hot_weather: "file://" + root.assetsPath + "/icons/hot-weather.png"
            readonly property string cold_weather: "file://" + root.assetsPath + "/icons/cold-weather.png"
            readonly property string mosque: "file://" + root.assetsPath + "/icons/mosque.png"
            readonly property string high_energy_rate: "file://" + root.assetsPath + "/icons/electrical-danger-sign.png"
            readonly property string high_voltage: "file://" + root.assetsPath + "/icons/electrical-danger-sign.png"
            readonly property string high_temp_warning: "file://" + root.assetsPath + "/icons/electrical-danger-sign.png"
        }
        readonly property QtObject audio: QtObject {
            readonly property string cold_weather: root.assetsPath + "/audio/cold-weather.mp3"
            readonly property string prayer_time: root.assetsPath + "/audio/prayer-notification.ogg"
            readonly property string desktop_login: root.assetsPath + "/audio/desktop-login.mp3"
            readonly property string desktop_logout: root.assetsPath + "/audio/desktop-logout.mp3"
            readonly property string high_energy_rate: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string warning: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string high_voltage: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string high_temp_warning: root.assetsPath + "/audio/warning-sound.mp3"
            readonly property string notificationAlert: root.assetsPath + "/audio/new-notification.mp3"
            readonly property string cpuHighUsage: root.assetsPath + "/audio/cpu_high_usage.wav"
        }

        function getWallpaperPath(wallpaper) {
            return root.wallpapersPath + "/" + wallpaper;
        }
    }

    readonly property QtObject scripts: QtObject {
        readonly property QtObject python: QtObject {
            // Files
            readonly property string batteryInfo: root.pythonScriptsPath + "/battery_info.py"
            readonly property string devicesTemp: root.pythonScriptsPath + "/devices_temp.py"
            readonly property string topCpuUsage: root.pythonScriptsPath + "/top_cpu_usage.py"
            readonly property string topRamUsage: root.pythonScriptsPath + "/top_ram_usage.py"
            readonly property string dynamicM3: root.pythonScriptsPath + "/m3/dynamic-m3.py"

            // Commands
            readonly property var batteryInfoCommand: ["python", batteryInfo]
            readonly property var devicesTempCommand: ["python", devicesTemp]
            readonly property var topCpuUsageCommand: ["python", topCpuUsage]
            readonly property var topRamUsageCommand: ["python", topRamUsage]
            readonly property var dynamicM3Command: ["python", dynamicM3]
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
}
