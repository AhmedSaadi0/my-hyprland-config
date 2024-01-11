import { App } from './utils/imports.js'

const ASSETS_PATH = `${App.configDir}/assets`

const getPath = (path) => {
    return `${ASSETS_PATH}/${path}`
}

const settings = {
    assets: {
        wallpapers: getPath("wallpapers"),
        icons: {
            hot_weather: `${getPath("icons")}/hot-weather.png`,
            cold_weather: `${getPath("icons")}/cold-weather.png`,
            mosque: `${getPath("icons")}/mosque.png`,
        },
        audio: {
            cold_weather: `${getPath("audio")}/cold-weather.mp3`,
            prayer_time: `${getPath("audio")}/prayer-notification.ogg`,
        },
    },
    // More settings will be moved to here
}

export default settings