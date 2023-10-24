import { Bar } from "./modules/topbar.js";
import { VolumeOSD } from "./modules/on-screen/volume.js";
import MyNotifications from './modules/notifications/Notifications.js';
import { LeftMenu } from "./modules/menus/left_menu.js";
import { NotificationCenter } from "./modules/menus/notification_center.js";
import ColorWidget  from './modules/widgets/desktop/ColorsWidget.js';
import App from "resource:///com/github/Aylur/ags/app.js";
import { exec } from 'resource:///com/github/Aylur/ags/utils.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';

// in config.js
const scss = App.configDir + '/scss/main.scss';
const css = App.configDir + '/style.css';

exec(`sassc ${scss} ${css}`);


// const colorWidget = ColorWidget();


export default {
    style: css,
    cacheNotificationActions: true,
    windows: [
        Bar(),
        VolumeOSD(),
        MyNotifications(),
        LeftMenu(),
        NotificationCenter(),
        ColorWidget
    ],
};

globalThis.getNot = () => Notifications;