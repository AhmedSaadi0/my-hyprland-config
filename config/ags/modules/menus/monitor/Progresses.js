import settings from '../../settings.js';
import strings from '../../strings.js';
import { TitleText } from '../../utils/helpers.js';

const Battery = await Service.import('battery');
export var ramUsage = 0;
export var cpuUsage = 0;
export var tempList = new Map();

export var menuIsOpen = null;

const cpuProgress = Widget.CircularProgress({
    className: 'menu-cpu',
    child: Widget.Label({
        className: 'menu-cpu-icon',
        label: '',
    }),
    // startAt: 0.5,
    // endAt: 1,
    rounded: true,
}).poll(1000, (self) => {
    try {
        menuIsOpen = getMenuStatus();
    } catch (ReferenceError) {}
    if (menuIsOpen) {
        Utils.execAsync(settings.scripts.cpu)
            .then((val) => {
                cpuProgress.value = val / 100;
                self.child.tooltipMarkup = `<span weight='bold'>${strings.cpuUsage} (${val}%)</span>`;
                cpuUsage = val;
            })
            .catch(print);
    }
});

const ramProgress = Widget.CircularProgress({
    className: 'menu-ram',
    child: Widget.Label({
        className: 'menu-ram-icon',
        label: '',
    }),
    // startAt: 0.5,
    // endAt: 1,
    rounded: true,
}).poll(1000, (self) => {
    try {
        menuIsOpen = getMenuStatus();
    } catch (ReferenceError) {}
    if (menuIsOpen) {
        Utils.execAsync(settings.scripts.ram)
            .then((val) => {
                self.value = val / 100;
                self.child.tooltipMarkup = `<span weight='bold'>${strings.ramUsage} (${val}%)</span>`;
                ramUsage = val;
            })
            .catch(print);
    }
});

const batteryProgress = Widget.CircularProgress({
    className: 'menu-battery',
    child: Widget.Label({
        className: 'menu-battery-icon',
        label: '',
    }),
    // endAt: 1,
    // startAt: 0.5,
    rounded: true,
}).hook(Battery, (self) => {
    let percentage = Battery.percent;
    self.value = percentage / 100;

    var labelText = '';

    const adapterIsOn = Utils.exec('acpi -a').includes('on-line');

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

    if (Battery.charging) {
        self.child.className = 'menu-battery-icon-charging';
    } else {
        self.child.className = 'menu-battery-icon';
    }
    self.child.label = labelText;

    self.child.tooltipMarkup = `<span weight='bold'>${strings.batteryPercentage} (${percentage}%)</span>`;
});

const tempProgress = Widget.CircularProgress({
    className: 'menu-temp',
    child: Widget.Label({
        className: 'menu-temp-icon',
        label: '',
    }),
    // endAt: 1,
    // startAt: 0.5,
    rounded: true,
}).poll(30000, (self) => {
    Utils.execAsync(settings.scripts.deviceTemp)
        .then((val) => {
            let temps = JSON.parse(val);
            tempList = temps;

            const wifiTemp = parseInt(temps['wifi']);
            const CRITICAL_WIFI_TEMP = 90;
            const nvmeTemp = parseInt(temps['nvme_total']);
            const CRITICAL_NVME_TEMP = 90;
            const cpuTemp = parseInt(temps['cpu_total']);
            const CRITICAL_CPU_TEMP = 100;

            if (wifiTemp >= CRITICAL_WIFI_TEMP) {
                notify({
                    tonePath: settings.assets.audio.high_temp_warning,
                    title: strings.highWifiTempWarning,
                    message: strings.highWifiTempMessage.replace(
                        '${wifiTemp}',
                        wifiTemp
                    ),
                    icon: settings.assets.icons.high_temp_warning,
                    priority: 'critical',
                });
            }

            if (nvmeTemp >= CRITICAL_NVME_TEMP) {
                notify({
                    tonePath: settings.assets.audio.high_temp_warning,
                    title: strings.highNVMeTempWarning,
                    message: strings.highNVMeTempMessage.replace(
                        '${nvmeTemp}',
                        nvmeTemp
                    ),
                    icon: settings.assets.icons.high_temp_warning,
                    priority: 'critical',
                });
            }

            if (cpuTemp >= CRITICAL_CPU_TEMP) {
                notify({
                    tonePath: settings.assets.audio.high_temp_warning,
                    title: strings.highCpuTempWarning,
                    message: strings.highCpuTempMessage.replace(
                        '${cpuTemp}',
                        cpuTemp
                    ),
                    icon: settings.assets.icons.high_temp_warning,
                    priority: 'critical',
                });
            }

            var totalTemp = wifiTemp + nvmeTemp + cpuTemp;
            totalTemp = totalTemp / 3;

            tempList['total'] = totalTemp;

            self.value = totalTemp / 100;
            self.child.tooltipMarkup = `<span weight='bold'>${strings.deviceTempTotal} (${parseInt(totalTemp)}%)</span>`;
        })
        .catch(print);
});

const ramAndCpu = Widget.Box({
    homogeneous: true,
    spacing: 12,
    className: '',
    children: [
        TitleText({
            title: strings.cpu,
            titleClass: 'monitor-progress-title',
            textWidget: cpuProgress,
        }),
        TitleText({
            title: strings.ram,
            titleClass: 'monitor-progress-title',
            textWidget: ramProgress,
        }),
    ],
});

const batAndTemp = Widget.Box({
    className: '',
    homogeneous: true,
    spacing: 12,
    children: [
        TitleText({
            title: strings.battery,
            titleClass: 'monitor-progress-title',
            textWidget: batteryProgress,
        }),
        ,
        TitleText({
            title: strings.temp,
            titleClass: 'monitor-progress-title',
            textWidget: tempProgress,
        }),
    ],
});

export default Widget.Box({
    // vertical: true,
    spacing: 10,
    className: 'progresses-box',
    children: [ramAndCpu, batAndTemp],
});
