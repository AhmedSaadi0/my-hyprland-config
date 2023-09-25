import App from 'resource:///com/github/Aylur/ags/app.js';
import { Bar } from "./modules/topbar.js";
import { VolumeOSD } from "./modules/on-screen/volume.js";
import { NotificationOSD } from "./modules/on-screen/notification.js";
import Notifications from './modules/notifications/Notifications.js';

// exporting the config so ags can manage the windows
export default {
    style: App.configDir + '/style.scss',
    windows: [
        Bar(),
        VolumeOSD(),
        Notifications(),
    ],
};