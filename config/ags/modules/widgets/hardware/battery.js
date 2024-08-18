import {
    Button,
    Label,
    CircularProgress,
} from 'resource:///com/github/Aylur/ags/widget.js';
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import strings from '../../strings.js';

export const BatteryWidget = () => {
    const label = Label({
        className: 'battery-inner',
        label: '󰁹',
    });

    const button = Button({
        className: 'unset no-hover',
        child: label,
        onClicked: () => toggleMonitors(),
    });

    return CircularProgress({
        className: 'battery',
        child: button,
        startAt: 0,
        rounded: false,
        // inverted: true,
    }).hook(Battery, (batteryProgress) => {
        let percentage = Battery.percent;
        var labelText = '';

        const adapterIsOn = Utils.exec('acpi -a').includes('on-line');

        if (Battery.charging) {
            label.className = 'battery-inner-charging';
        } else {
            label.className = 'battery-inner';
        }

        if (adapterIsOn) {
            if (percentage <= 10) {
                labelText = '󰢜';
            } else if (percentage <= 20) {
                labelText = '󰂆';
            } else if (percentage <= 30) {
                labelText = '󰂇';
            } else if (percentage <= 40) {
                labelText = '󰂈';
            } else if (percentage <= 50) {
                labelText = '󰢝';
            } else if (percentage <= 60) {
                labelText = '󰂉';
            } else if (percentage <= 70) {
                labelText = '󰢞';
            } else if (percentage <= 80) {
                labelText = '󰂊';
            } else if (percentage <= 90) {
                labelText = '󰂋';
            } else {
                labelText = '󰂅';
            }
        } else {
            if (percentage <= 10) {
                labelText = '󰁺';
            } else if (percentage <= 20) {
                labelText = '󰁻';
            } else if (percentage <= 30) {
                labelText = '󰁼';
            } else if (percentage <= 40) {
                labelText = '󰁽';
            } else if (percentage <= 50) {
                labelText = '󰁾';
            } else if (percentage <= 60) {
                labelText = '󰁿';
            } else if (percentage <= 70) {
                labelText = '󰂀';
            } else if (percentage <= 80) {
                labelText = '󰂁';
            } else if (percentage <= 90) {
                labelText = '󰂂';
            } else {
                labelText = '󰁹';
            }
        }

        batteryProgress.value = Battery.percent / 100;
        label.tooltipMarkup = `<span weight='bold' foreground='#FF8580'>${strings.batteryPercentage} (${Battery.percent}%)</span>`;

        label.label = labelText;
    });
};
