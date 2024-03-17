import { App } from './utils/imports.js';

const MAIN_PATH = `${App.configDir}`;
const ASSETS_PATH = `${App.configDir}/assets`;

const getAssets = (path) => {
    return `${ASSETS_PATH}/${path}`;
};

const getPath = (path) => {
    return `${MAIN_PATH}/${path}`;
};

const settings = {
    assets: {
        wallpapers: getAssets('wallpapers'),
        icons: {
            hot_weather: `${getAssets('icons')}/hot-weather.png`,
            cold_weather: `${getAssets('icons')}/cold-weather.png`,
            mosque: `${getAssets('icons')}/mosque.png`,
        },
        audio: {
            cold_weather: `${getAssets('audio')}/cold-weather.mp3`,
            prayer_time: `${getAssets('audio')}/prayer-notification.ogg`,
        },
    },
    scripts: {
        scripts: getPath('scripts'),
        dynamicM3Py: getPath('scripts/m3/dynamic-m3.py'),
        get_wallpapers: getPath('scripts/get_wallpapers.sh'),
    },
    theme: {
        scss: `${getPath('scss')}`,
        absoluteDynamicM3Scss: `${getPath('scss/themes/m3/dynamic.scss')}`,
        mainCss: `${getPath('/scss/main.scss')}`,
        styleCss: `${getPath('/style.scss')}`,
    },
    weather: {
        // provider is 'ar.wttr.in'
        language: 'ar', // Not implemented yot - only arabic is supported
        location: 'sanaa',
        format: 'j1',
    },
    prayerTimes: {
        // provider is 'api.aladhan.com'
        city: 'sanaa',
        country: 'yemen',
    },
    hardware: {
        network: {
            rx_path: '/sys/class/net/wlp0s20f3/statistics/tx_bytes',
            tx_path: '/sys/class/net/wlp0s20f3/statistics/tx_bytes',
        },
    },
};

export default settings;
