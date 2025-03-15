import { readFile } from 'astal';

const HOME_PATH = `/home/ahmed`;
const MAIN_PATH = `${HOME_PATH}/.config/ags_v2`;
const ASSETS_PATH = `${MAIN_PATH}/assets`;
const CACHE_PATH = `${HOME_PATH}/.cache/ahmed-config`;
const CACHE_FILE_PATH = `${CACHE_PATH}/ahmed-hyprland-conf.json`;

const getAssets = (path: string): string => `${ASSETS_PATH}/${path}`;
const getPath = (path: string): string => `${MAIN_PATH}/${path}`;

var networkMonitor = '';
var networkTimeout = '';
var networkInterval = '';
var darkM3WallpaperPath = '';
var lightM3WallpaperPath = '';
var weatherLocation = '';
var city = '';
var country = '';
var username = '';
var profilePicture = '';
var usePrayerTimes = false;
var changePlasmaColor = true;

var scripts: any = {};

try {
    const configFile = JSON.parse(readFile(`${HOME_PATH}/.ahmed-config.json`));
    networkMonitor = configFile.networkMonitor;
    darkM3WallpaperPath = configFile.darkM3WallpaperPath;
    lightM3WallpaperPath = configFile.lightM3WallpaperPath;
    weatherLocation = configFile.weatherLocation;
    city = configFile.city;
    country = configFile.country;
    networkTimeout = configFile.networkTimeout;
    networkInterval = configFile.networkInterval;
    username = configFile.username;
    profilePicture = configFile.profilePicture;
    usePrayerTimes = configFile.usePrayerTimes;
    changePlasmaColor = configFile.changePlasmaColor;

    scripts = {
        dynamicM3Py: configFile.scripts.dynamicM3Py,
        get_wallpapers: configFile.scripts.get_wallpapers,
        createThumbnail: configFile.scripts.createThumbnail,
        gtk_theme: configFile.scripts.gtk_theme,
        systemInfo: configFile.scripts.systemInfo,
        deviceLocal: configFile.scripts.deviceLocal,
        cpu: configFile.scripts.cpu,
        ram: configFile.scripts.ram,
        deviceTemp: configFile.scripts.deviceTemp,
        hardwareInfo: configFile.scripts.hardwareInfo,
        cpuUsage: configFile.scripts.cpuUsage,
        ramUsage: configFile.scripts.ramUsage,
        cpuCores: configFile.scripts.cpuCores,
        devicesTemp2: configFile.scripts.devicesTemp2,
        playerctl: configFile.scripts.playerctl,
    };
} catch (TypeError) {
    console.log('Error reading .ahmed-config.json file');
}

const settings = {
    homePath: HOME_PATH,
    username: username,
    profilePicture: profilePicture,
    usePrayerTimes: usePrayerTimes,
    changePlasmaColor: changePlasmaColor,
    cachePath: CACHE_PATH,
    cacheFilePath: CACHE_FILE_PATH,
    assets: {
        wallpapers: getAssets('wallpapers'),
        icons: {
            hotWeather: `${getAssets('icons')}/hot-weather.png`,
            coldWeather: `${getAssets('icons')}/cold-weather.png`,
            mosque: `${getAssets('icons')}/mosque.png`,
            highEnergyRate: `${getAssets('icons')}/electrical-danger-sign.png`,
            highVoltage: `${getAssets('icons')}/electrical-danger-sign.png`,
            highTempWarning: `${getAssets('icons')}/electrical-danger-sign.png`,
        },
        audio: {
            coldWeather: `${getAssets('audio')}/cold-weather.mp3`,
            prayerTime: `${getAssets('audio')}/prayer-notification.ogg`,
            desktopLogin: `${getAssets('audio')}/desktop-login.mp3`,
            desktopLogout: `${getAssets('audio')}/desktop-logout.mp3`,
            highEnergyRate: `${getAssets('audio')}/warning-sound.mp3`,
            warning: `${getAssets('audio')}/warning-sound.mp3`,
            highVoltage: `${getAssets('audio')}/warning-sound.mp3`,
            highTempWarning: `${getAssets('audio')}/warning-sound.mp3`,
            notificationAlert: `${getAssets('audio')}/mixkit-positive-notification.wav`,
            cpuHighUsage: `${getAssets('audio')}/cpu_high_usage.wav`,
        },
    },
    scripts: {
        scripts: getPath('scripts'),
        dynamicM3Py: scripts.dynamicM3Py ?? getPath('scripts/m3/dynamic-m3.py'),
        getWallpapers:
            scripts.getWallpapers ?? getPath('scripts/get_wallpapers.sh'),
        createThumbnail:
            scripts.createThumbnail ??
            getPath('scripts/m3/create_thumbnail.py'),
        deviceLocal: scripts.deviceLocal ?? getPath('scripts/lang.sh'),
        topCpu: scripts.cpuCores ?? getPath('scripts/top_cpu.sh'),
        topRam: scripts.cpuCores ?? getPath('scripts/top_ram.sh'),
        devicesTemp2: scripts.devicesTemp2 ?? getPath('scripts/temp.sh'),
        playerctl:
            scripts.playerctl ??
            `/home/ahmed/.config/hypr/scripts/playerctl.sh`,
    },
    theme: {
        scss: `${getPath('scss')}`,
        absoluteDynamicM3Scss: `${getPath('scss/themes/m3/dynamic.scss')}`,
        mainCss: `${getPath('scss/main.scss')}`,
        styleCss: `${CACHE_PATH}/style.css`,
        darkM3WallpaperPath: darkM3WallpaperPath,
        lightM3WallpaperPath: lightM3WallpaperPath,
        menuTransitions: {
            mainMenu: 'slide_down',
            weatherMenu: 'slide_down',
            networkMenu: 'slide_down',
            notificationMenu: 'slide_down',
            prayerTimesMenu: 'slide_down',
            hardwareMenu: 'slide_down',
            audioMenu: 'slide_down',
            calendarMenu: 'slide_down',

            mainMenuDuration: 300,
            weatherMenuDuration: 300,
            networkMenuDuration: 300,
            notificationMenuDuration: 300,
            prayerTimesMenuDuration: 300,
            hardwareMenuDuration: 300,
            audioMenuDuration: 300,
            calendarMenuDuration: 300,
        },
    },
    weather: {
        // provider is 'ar.wttr.in'
        language: 'ar', // Not implemented yet - only Arabic is supported
        location: weatherLocation,
        format: 'j1',
    },
    prayerTimes: {
        // provider is 'api.aladhan.com'
        city: city,
        country: country,
    },
    hardware: {
        network: {
            rxPath: `/sys/class/net/${networkMonitor}/statistics/rx_bytes`,
            txPath: `/sys/class/net/${networkMonitor}/statistics/tx_bytes`,
            timeout: networkTimeout,
            interval: networkInterval,
        },
    },
    menuTabs: {
        dashboard: 'dashboard',
        notifications: 'notifications',
        weather: 'weather',
        monitor: 'monitor',
        calender: 'calender',
        network: 'network',
    },
};

export default settings;
