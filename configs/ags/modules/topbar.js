import { NetworkInformation } from "./widgets/internet.js";
import { Workspaces } from "./widgets/workspace.js";
// import { Volume } from "./widgets/volume.js";
import { HardwareBox } from "./widgets/hardware/all.js";
import { SysTrayBox } from "./widgets/systray.js";
// import NotificationIndicator from "./widgets/NotificationIndicator.js";
import { NotificationCenterButton } from "./menus/notification_center.js";
import { MenuButton } from './menus/left_menu.js'

import { Window, CenterBox, Box, Label } from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
import weatherService from "./services/WeatherService.js";
import prayerService from "./services/PrayerTimesService.js";


const Clock = () => Label({
    className: 'clock',
    connections: [
        [
            1000,
            label => execAsync(
                ['date', '+(%I:%M) %A, %d %B']
            ).then(
                date => label.label = date
            ).catch(print)
        ],
    ],
});

const Weather = () => {

    let icon = Label({
        className: 'bar-weather-icon',
    })
    let text = Label({
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 24,
    })

    return Box({
        className: 'bar-weather-box small-shadow',
        children: [
            icon,
            text,
        ],
        connections: [
            [
                weatherService,
                weatherBox => {
                    if (weatherService.arValue != '') {
                        const max = weatherService.maxTempC;
                        const min = weatherService.minTempC;
                        text.label = `(${min} - ${max}) ${weatherService.feelsLike} ${weatherService.arValue}`;
                        icon.label = `${weatherService.weatherCode}`;
                    } else {
                        text.label = `خدمة الطقس غير متاحة`;
                    }
                }
            ],
        ],
    })
}

const PrayerTimes = () => {

    let icon = Label({
        className: 'bar-prayer-times-icon',
        label: '',
    })
    let text = Label({
        truncate: 'end',
        xalign: 0,
        maxWidthChars: 24,
    })

    return Box({
        className: 'bar-prayer-times-box small-shadow',
        children: [
            icon,
            text,
        ],
        connections: [
            [
                prayerService,
                box => {
                    if (prayerService.nextPrayerName != '') {
                        if (!prayerService.prayerNow) {
                            text.label = `${prayerService.nextPrayerName} (${prayerService.nextPrayerTime})`
                        } else {
                            text.label = `حان الان وقت صلاة ${prayerService.prayerNow}`
                        }
                    } else {
                        text.label = `غير متاحة`;
                    }
                }
            ],
        ],
    })
}

// layout of the bar
const Right = () => Box({
    children: [
        Workspaces(),
        HardwareBox(),
        PrayerTimes(),
        // NotificationIndicator(),
        // ClientTitle(),
    ],
});

const Center = () => Box({
    children: [
        Clock(),
    ],
});

const Left = () => Box({
    hpack: 'end',
    children: [
        // Volume(),
        NotificationCenterButton(),
        Weather(),
        NetworkInformation(),
        SysTrayBox(),
        MenuButton,
    ],
});


export const Bar = ({ monitor } = {}) => Window({
    name: `bar${monitor || ''}`, // name has to be unique
    className: 'bar-bg',
    monitor,
    anchor: ['top', 'left', 'right'],
    exclusive: true,
    child: CenterBox({
        className: "bar shadow",
        startWidget: Right(),
        centerWidget: Center(),
        endWidget: Left(),
    }),
})