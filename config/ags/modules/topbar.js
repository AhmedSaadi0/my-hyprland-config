import { NetworkInformation } from './widgets/internet.js';
import { Workspaces } from './widgets/workspace.js';
import { HardwareBox } from './widgets/hardware/all.js';
import { SysTrayBox } from './widgets/systray.js';
import { NotificationCenterButton } from './menus/notification_center.js';
import { MenuButton } from './menus/MainMenu.js';

import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import weatherService from './services/WeatherService.js';
import prayerService from './services/PrayerTimesService.js';
import themeService from './services/ThemeService.js';
import strings from './strings.js';
import settings from './settings.js';

const Window = Widget.Window;
const CenterBox = Widget.CenterBox;
const Box = Widget.Box;
const Label = Widget.Label;

const Clock = () => {
    let label = Label({
        className: 'clock small-shadow unset',
    });

    let button = Widget.Button({
        className: 'unset un-hover',
        onClicked: () => showCalendarMenu(),
        child: label,
    });

    label.poll(1000, (self) =>
        execAsync(['date', '+(%I:%M) %A, %d %B'])
            .then((date) => (self.label = date))
            .catch(print)
    );

    return button;
};

const Weather = () => {
    let icon = Label({
        className: 'bar-weather-icon unset',
    });

    let text = Label({
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 24,
    });

    let button = Widget.Button({
        className: 'unset un-hover',
        onClicked: () => toggleWeather(),
        child: Box({
            className: 'bar-weather-box small-shadow unset',
            children: [icon, text],
        }).hook(weatherService, (self) => {
            if (weatherService.value != '') {
                const max = weatherService.maxTempC;
                const min = weatherService.minTempC;
                text.label = `(${min} - ${max}) ${weatherService.feelsLike} ${weatherService.value}`;
                icon.label = `${weatherService.weatherCode}`;
            } else {
                text.label = strings.weatherNotAvailable;
            }
        }),
    });

    return button;
};

const PrayerTimes = () => {
    if (!settings.usePrayerTimes) {
        return null;
    }

    const iconButton = Widget.Button({
        className: 'unset un-hover unset',
        onClicked: () => showPrayerTimesMenu(),
        child: Label({
            className: 'bar-prayer-times-icon unset',
            label: '',
        }),
    });

    let text = Widget.Button({
        className: 'unset un-hover unset',
        onClicked: () => showPrayerTimesMenu(),
        child: Label({
            truncate: 'end',
            xalign: 0,
            maxWidthChars: 24,
        }),
    });

    return Box({
        className: 'bar-prayer-times-box small-shadow unset',
        children: [iconButton, text],
    }).hook(prayerService, (box) => {
        if (prayerService.nextPrayerName != '') {
            if (!prayerService.prayerNow) {
                text.child.label = `${prayerService.nextPrayerName} (${prayerService.nextPrayerTime})`;
            } else {
                text.child.label = `${strings.prayerTimeNow} ${prayerService.prayerNow}`;
            }
        } else {
            text.child.label = `-`;
        }
    });
};

const DynamicWallpaper = () =>
    Widget.Button({
        className: 'unset dynamic-wallpaper',
        onClicked: () => {
            themeService.toggleDynamicWallpaper();
        },
    }).hook(themeService, (btn) => {
        if (!themeService.isDynamicTheme) {
            btn.visible = false;
            return;
        }

        btn.visible = true;
        if (themeService.dynamicWallpaperIsOn) btn.label = '󰋹';
        else btn.label = '󰋩';
    });

// layout of the bar
const Right = () =>
    Box({
        children: [
            Workspaces(),
            HardwareBox(),
            PrayerTimes(),
            DynamicWallpaper(),
            // NotificationIndicator(),
            // ClientTitle(),
        ],
    });

const Center = () =>
    Box({
        children: [Clock()],
    });

const Left = () =>
    Box({
        hpack: 'end',
        children: [
            // Volume(),
            Weather(),
            NetworkInformation(),
            NotificationCenterButton(),
            SysTrayBox(),
            MenuButton(),
        ],
    });

export const Bar = ({ monitor } = {}) =>
    Window({
        name: `bar${monitor || ''}`, // name has to be unique
        className: 'bar-bg unset',
        monitor: monitor,
        anchor: ['top', 'left', 'right'],
        exclusivity: 'exclusive',
        child: CenterBox({
            className: 'bar shadow',
            startWidget: Right(),
            centerWidget: Center(),
            endWidget: Left(),
        }),
    });
