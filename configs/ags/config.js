import { Bar } from "./modules/topbar.js";
import { VolumeOSD } from "./modules/on-screen/volume.js";
import Notifications from './modules/notifications/Notifications.js';


// in config.js
const scss = ags.App.configDir + '/scss/main.scss';
const css = ags.App.configDir + '/style.css';

ags.Utils.exec(`sassc ${scss} ${css}`);

export default {
    style: css,
    cacheNotificationActions: true,
    windows: [
        Bar(),
        VolumeOSD(),
        Notifications(),
    ],
};