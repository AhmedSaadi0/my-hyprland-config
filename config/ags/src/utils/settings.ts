// TODO: -> get current user, config dir
import { readFile } from 'astal';

const MAIN_PATH = `/home/ahmed/.config/ags_v2/`;
const ASSETS_PATH = `${MAIN_PATH}/assets`;

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
    const configFile = JSON.parse(readFile(`/home/ahmed/.ahmed-config.json`));
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
    username: username,
    profilePicture: profilePicture,
    usePrayerTimes: usePrayerTimes,
    changePlasmaColor: changePlasmaColor,
    assets: {
        wallpapers: getAssets('wallpapers'),
        icons: {
            hot_weather: `${getAssets('icons')}/hot-weather.png`,
            cold_weather: `${getAssets('icons')}/cold-weather.png`,
            mosque: `${getAssets('icons')}/mosque.png`,
            high_energy_rate: `${getAssets('icons')}/electrical-danger-sign.png`,
            high_voltage: `${getAssets('icons')}/electrical-danger-sign.png`,
            high_temp_warning: `${getAssets('icons')}/electrical-danger-sign.png`,
        },
        audio: {
            cold_weather: `${getAssets('audio')}/cold-weather.mp3`,
            prayer_time: `${getAssets('audio')}/prayer-notification.ogg`,
            desktop_login: `${getAssets('audio')}/desktop-login.mp3`,
            desktop_logout: `${getAssets('audio')}/desktop-logout.mp3`,
            high_energy_rate: `${getAssets('audio')}/warning-sound.mp3`,
            warning: `${getAssets('audio')}/warning-sound.mp3`,
            high_voltage: `${getAssets('audio')}/warning-sound.mp3`,
            high_temp_warning: `${getAssets('audio')}/warning-sound.mp3`,
            notificationAlert: `${getAssets('audio')}/mixkit-positive-notification.wav`,
            cpuHighUsage: `${getAssets('audio')}/cpu_high_usage.wav`,
        },
    },
    scripts: {
        scripts: getPath('scripts'),
        dynamicM3Py: scripts.dynamicM3Py ?? getPath('scripts/m3/dynamic-m3.py'),
        get_wallpapers:
            scripts.get_wallpapers ?? getPath('scripts/get_wallpapers.sh'),
        createThumbnail:
            scripts.createThumbnail ??
            getPath('scripts/m3/create_thumbnail.py'),
        deviceLocal: scripts.deviceLocal ?? getPath('scripts/lang.sh'),
        topCpu: scripts.cpuCores ?? getPath('scripts/top_cpu.sh'),
        devicesTemp2: scripts.devicesTemp2 ?? getPath('scripts/temp.sh'),
        playerctl:
            scripts.playerctl ??
            `/home/ahmed/.config/hypr/scripts/playerctl.sh`,
    },
    theme: {
        scss: `${getPath('scss')}`,
        absoluteDynamicM3Scss: `${getPath('scss/themes/m3/dynamic.scss')}`,
        mainCss: `${getPath('/scss/main.scss')}`,
        styleCss: `${getPath('/style.scss')}`,
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
            rx_path: `/sys/class/net/${networkMonitor}/statistics/rx_bytes`,
            tx_path: `/sys/class/net/${networkMonitor}/statistics/tx_bytes`,
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
