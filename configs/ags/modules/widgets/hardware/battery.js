import { Button, Label, CircularProgress } from 'resource:///com/github/Aylur/ags/widget.js'
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js'

const label = Label({
    className: "battery-inner",
    label: "󰄯"
})

const button = Button({
    className: "unset no-hover",
    child: label,
});

// const progress = Widget.CircularProgress({
//     style:
//         'min-width: 50px;' + // its size is min(min-height, min-width)
//         'min-height: 50px;' +
//         'font-size: 6px;' + // to set its thickness set font-size on it
//         'margin: 4px;' + // you can set margin on it
//         'background-color: #131313;' + // set its bg color
//         'color: aqua;', // set its fg color
//     connections: [[Battery, self => {
//         self.value = Battery.percent / 100;
//     }]],
//     child: Widget.Icon({
//         binds: [['icon', Battery, 'icon-name']],
//     }),
//     rounded: false,
//     inverted: false,
//     startAt: 0.75,
// });

export const BatteryWidget = () => CircularProgress({
    className: "battery",
    child: button,
    startAt: 0,
    rounded: false,
    inverted: true,
    connections: [
        [Battery, batteryProgress => {

            if (Battery.charging) {
                label.className = "battery-inner-charging";
            } else {
                label.className = "battery-inner";
            }
            batteryProgress.value = (Battery.percent / 100);
            label.tooltipMarkup = `<span weight='bold' foreground='#FF8580'>نسبة البطارية (${Battery.percent}%)</span>`

        }],
    ],
});
