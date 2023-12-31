import { exec } from 'resource:///com/github/Aylur/ags/utils.js';
import { Bar } from "./modules/topbar.js";
import { LeftMenu } from "./modules/menus/left_menu.js";
import { HardwareMenu } from "./modules/menus/HardwareMenu.js";
import { NotificationCenter } from "./modules/menus/notification_center.js";
import { VolumeOSD } from "./modules/on-screen/volume.js";
import MyNotifications from './modules/notifications/Notifications.js';
import ColorWidget from './modules/widgets/desktop/ColorsWidget.js';
import App from "resource:///com/github/Aylur/ags/app.js";
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import win20Widget from "./modules/widgets/desktop/Win20Widget.js";
import materialWidget from "./modules/widgets/desktop/MaterialYouOne.js";
import unicatWidget from "./modules/widgets/desktop/UnicatWidget.js";
import blackHoleWidget from "./modules/widgets/desktop/BlackHole.js";
import goldenWidget from "./modules/widgets/desktop/Golden.js";
import harmonyWidget from './modules/widgets/desktop/Harmony.js';
import newCatWidget from './modules/widgets/desktop/NewCat.js';
import deerWidget from './modules/widgets/desktop/DeerWidget.js';
import { PrayerTimesMenu } from './modules/menus/PrayerTimesMenu.js';
import circlesMusicWidget from './modules/widgets/desktop/Circles.js';

// in config.js
const scss = App.configDir + '/scss/main.scss';
const css = App.configDir + '/style.css';

exec(`sassc ${scss} ${css}`);

export default {
    css: css,
    cacheNotificationActions: true,
    windows: [
        Bar(),
        VolumeOSD(),
        MyNotifications(),
        LeftMenu(),
        NotificationCenter(),
        HardwareMenu(),
        PrayerTimesMenu(),
    ],
};

globalThis.getNot = () => Notifications;
