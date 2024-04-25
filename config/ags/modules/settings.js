import { App, Utils } from './utils/imports.js';

const MAIN_PATH = `${App.configDir}`;
const ASSETS_PATH = `${App.configDir}/assets`;

const getAssets = (path) => {
  return `${ASSETS_PATH}/${path}`;
};

const getPath = (path) => {
  return `${MAIN_PATH}/${path}`;
};

var networkMonitor = '';
var networkTimeout = '';
var networkInterval = '';
var darkM3WallpaperPath = '';
var lightM3WallpaperPath = '';
var weatherLocation = '';
var city = '';
var country = '';

try {
  const configFile = JSON.parse(
    Utils.readFile(`/home/${Utils.USER}/.ahmed-config.json`)
  );
  networkMonitor = configFile.networkMonitor;
  darkM3WallpaperPath = configFile.darkM3WallpaperPath;
  lightM3WallpaperPath = configFile.lightM3WallpaperPath;
  weatherLocation = configFile.weatherLocation;
  city = configFile.city;
  country = configFile.country;
  networkTimeout = configFile.networkTimeout;
  networkInterval = configFile.networkInterval;
} catch (TypeError) {
  console.log('Error reading .ahmed-config.json file');
}

const settings = {
  assets: {
    wallpapers: getAssets('wallpapers'),
    icons: {
      hot_weather: `${getAssets('icons')}/hot-weather.png`,
      cold_weather: `${getAssets('icons')}/cold-weather.png`,
      mosque: `${getAssets('icons')}/mosque.png`,
      high_energy_rate: `${getAssets('icons')}/mosque.png`,
      high_voltage: `${getAssets('icons')}/electrical-danger-sign.png`,
      high_temp_warning: `${getAssets('icons')}/mosque.png`,
    },
    audio: {
      cold_weather: `${getAssets('audio')}/cold-weather.mp3`,
      prayer_time: `${getAssets('audio')}/prayer-notification.ogg`,
      desktop_login: `${getAssets('audio')}/desktop-login.mp3`,
      desktop_logout: `${getAssets('audio')}/desktop-logout.mp3`,
      high_energy_rate: `${getAssets('audio')}/warning-sound.mp3`,
      high_voltage: `${getAssets('audio')}/warning-sound.mp3`,
      high_temp_warning: `${getAssets('audio')}/warning-sound.mp3`,
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
    darkM3WallpaperPath: darkM3WallpaperPath,
    lightM3WallpaperPath: lightM3WallpaperPath,
  },
  weather: {
    // provider is 'ar.wttr.in'
    language: 'ar', // Not implemented yot - only arabic is supported
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
};

export default settings;
