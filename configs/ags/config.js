import { exec } from 'resource:///com/github/Aylur/ags/utils.js';
import { Bar } from "./modules/topbar.js";
import { LeftMenu } from "./modules/menus/left_menu.js";
import { HardwareMenu } from "./modules/menus/HardwareMenu.js";
import { NotificationCenter } from "./modules/menus/notification_center.js";
import { VolumeOSD } from "./modules/on-screen/volume.js";
import MyNotifications from './modules/notifications/Notifications.js';
import App from "resource:///com/github/Aylur/ags/app.js";
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import { PrayerTimesMenu } from './modules/menus/PrayerTimesMenu.js';
import ColorWidget from './modules/widgets/desktop/ColorsWidget.js';
import win20Widget from "./modules/widgets/desktop/Win20Widget.js";
import materialWidget from "./modules/widgets/desktop/MaterialYouOne.js";
import unicatWidget from "./modules/widgets/desktop/UnicatWidget.js";
import blackHoleWidget from "./modules/widgets/desktop/BlackHole.js";
import goldenWidget from "./modules/widgets/desktop/Golden.js";
import harmonyWidget from './modules/widgets/desktop/Harmony.js';
import newCatWidget from './modules/widgets/desktop/NewCat.js';
import deerWidget from './modules/widgets/desktop/DeerWidget.js';
import circlesMusicWidget from './modules/widgets/desktop/Circles.js';
import whiteFlowerWidget from './modules/widgets/desktop/WhiteFlower.js';
// import ScreenCorners from './modules/components/ScreenCorners.js';

// in config.js
const scss = App.configDir + '/scss/main.scss';
const css = App.configDir + '/style.css';

exec(`sassc ${scss} ${css}`);

export default {
    css: css,
    cacheNotificationActions: true,
    windows: [
        // Bar({monitor : 1}),
        Bar({monitor : 0}),
        VolumeOSD(),
        MyNotifications(),
        LeftMenu(),
        NotificationCenter(),
        HardwareMenu(),
        PrayerTimesMenu(),
        // ScreenCorners,
        // Desktop widgets
        ColorWidget,
        win20Widget,
        materialWidget,
        unicatWidget,
        blackHoleWidget,
        goldenWidget,
        harmonyWidget,
        newCatWidget,
        deerWidget,
        circlesMusicWidget,
        whiteFlowerWidget
    ],
};

globalThis.getNot = () => Notifications;
