import { Utils, App, Notifications } from './modules/utils/imports.js';
import { Bar } from './modules/topbar.js';
import { LeftMenu } from './modules/menus/left_menu.js';
import { HardwareMenu } from './modules/menus/HardwareMenu.js';
import { NotificationCenter } from './modules/menus/notification_center.js';
import { VolumeOSD } from './modules/on-screen/volume.js';
import MyNotifications from './modules/notifications/OSDNotifications.js';
import { PrayerTimesMenu } from './modules/menus/PrayerTimesMenu.js';
import ColorWidget from './modules/widgets/desktop/ColorsWidget.js';
import win20Widget from './modules/widgets/desktop/Win20Widget.js';
import materialWidget from './modules/widgets/desktop/MaterialYouOne.js';
import unicatWidget from './modules/widgets/desktop/UnicatWidget.js';
import blackHoleWidget from './modules/widgets/desktop/BlackHole.js';
import goldenWidget from './modules/widgets/desktop/Golden.js';
import harmonyWidget from './modules/widgets/desktop/Harmony.js';
import newCatWidget from './modules/widgets/desktop/NewCat.js';
import deerWidget from './modules/widgets/desktop/DeerWidget.js';
import circlesMusicWidget from './modules/widgets/desktop/Circles.js';
import whiteFlowerWidget from './modules/widgets/desktop/WhiteFlower.js';
import { WeatherMenu } from './modules/menus/WeatherMenu.js';
import settings from './modules/settings.js';
import {
  TopLeftCorner,
  TopRightCorner,
} from './modules/components/ScreenCorners.js';

// in config.js
const scss = App.configDir + '/scss/main.scss';
const css = App.configDir + '/style.css';

Utils.exec(`sassc ${scss} ${css}`);

let windows = [
  // Bar({monitor : 1}),
  // Bar({ monitor: 0 }),
  VolumeOSD(),
  MyNotifications(),
  NotificationCenter(),
  HardwareMenu(),
  PrayerTimesMenu(),
  WeatherMenu(),
  // ... Desktop widgets ... //
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
  whiteFlowerWidget,
];

const screens = JSON.parse(Utils.exec('hyprctl monitors all -j'));

for (let i = 0; i < screens.length; i++) {
  const screen = screens[i];

  windows.push(Bar({ monitor: screen.id }));

  const leftMene = LeftMenu({ monitor: screen.id });
  windows.push(leftMene);
  windows.push(TopLeftCorner({ monitor: screen.id }));
  windows.push(TopRightCorner({ monitor: screen.id }));
}

export default {
  css: css,
  // cacheNotificationActions: true,
  windows: windows,
};
Notifications.cacheActions;
globalThis.getNot = () => Notifications;

Utils.execAsync([`paplay`, settings.assets.audio.desktop_login]).catch(print);
