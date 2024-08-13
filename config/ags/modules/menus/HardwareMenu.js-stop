import tableRow from '../components/TableRow.js';
import { TitleText, local, notify } from '../utils/helpers.js';
import settings from '../settings.js';
import strings from '../strings.js';

const powerProfiles = await Service.import('powerprofiles');
const Battery = await Service.import('battery');

var menuIsOpen = null;
var cpuIsInitialized = false;
var ramIsInitialized = false;

var ramUsage = 0;
var cpuUsage = 0;
var tempList = new Map();

const cpuProgress = Widget.CircularProgress({
    className: 'menu-cpu',
    child: Widget.Label({
        className: 'menu-cpu-icon',
        label: '',
    }),
    startAt: 0,
    rounded: true,
}).poll(1000, (self) => {
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
    startAt: 0,
    rounded: true,
}).poll(1000, (self) => {
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
    startAt: 0,
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
    startAt: 0,
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

const hwProgressBox = Widget.Box({
    className: 'hardware-menu-header-box',
    // spacing: 2,
    children: [cpuProgress, ramProgress, batteryProgress, tempProgress],
});

const powerProfilesBox = Widget.Box({
    className: 'hardware-menu-power-profile-box',
    vertical: true,
    children: [
        Widget.Button({
            className: 'power-profiles-box-btn',
            on_clicked: () => (powerProfiles.active_profile = 'performance'),
            child: TitleText({
                title: strings.highPerformance,
                text: '󰾆',
                titleClass: 'power-profiles-title',
                vertical: false,
                titleXalign: 1,
                textXalign: 0,
                spacing: 10,
            }),
            // child: Widget.Label({
            //   label: 'مرتفع  󰾆',
            //   useMarkup: true,
            //   tooltipMarkup: `<span weight='bold'>وضع الاداء العالي</span>`,
            // }),
        }),
        Widget.Button({
            className: 'power-profiles-box-btn',
            on_clicked: () => (powerProfiles.active_profile = 'balanced'),
            child: TitleText({
                title: strings.balanced,
                text: '󰾅',
                titleClass: 'power-profiles-title',
                vertical: false,
                titleXalign: 0,
                textXalign: 1,
                spacing: 10,
            }),
            // child: Widget.Label({
            //   label: 'معتدل  󰾅',
            //   useMarkup: true,
            //   tooltipMarkup: `<span weight='bold'>وضع الاداء المتزن</span>`,
            // }),
        }),
        Widget.Button({
            className: 'power-profiles-box-btn',
            on_clicked: () => (powerProfiles.active_profile = 'power-saver'),
            child: TitleText({
                title: strings.powerSaver,
                text: '󰓅',
                titleClass: 'power-profiles-title',
                vertical: false,
                titleXalign: 0,
                textXalign: 1,
                spacing: 3.5,
            }),
            // child: Widget.Label({
            //   label: 'منخفظ  󰓅',
            //   useMarkup: true,
            //   tooltipMarkup: `<span weight='bold'>وضع حفظ الطاقة</span>`,
            // }),
        }),
    ],
}).hook(powerProfiles, (self) => {
    self.children[0].className = 'power-profiles-box-btn';
    self.children[1].className = 'power-profiles-box-btn';
    self.children[2].className = 'power-profiles-box-btn';

    if (powerProfiles.active_profile == 'performance') {
        self.children[0].className =
            'power-profiles-box-btn power-profiles-box-btn-active';
    } else if (powerProfiles.active_profile == 'balanced') {
        self.children[1].className =
            'power-profiles-box-btn power-profiles-box-btn-active';
    } else if (powerProfiles.active_profile == 'power-saver') {
        self.children[2].className =
            'power-profiles-box-btn power-profiles-box-btn-active';
    }
});

const headerBox = Widget.Box({
    spacing: 3,
    children: [powerProfilesBox, hwProgressBox],
});

const hardwareUsageTable = ({
    scriptPath,
    deviceName,
    interval = 2000,
    headerRightText = strings.process,
    headerLeftText = '%',
}) => {
    const table = Widget.Box({
        className: `hardware-${deviceName}-box`,
        vertical: true,
        children: [],
    });

    function callWidgetScripts(self) {
        Utils.execAsync(scriptPath)
            .then((val) => {
                let data = JSON.parse(val);
                let children = [
                    tableRow({
                        appName: headerRightText,
                        percentage: headerLeftText,
                        header: true,
                        deviceName: deviceName,
                    }),
                ];
                for (let index = 0; index < data.length; index++) {
                    const element = data[index];
                    children.push(
                        tableRow({
                            appName: element['process'],
                            percentage: element['%'],
                            deviceName: deviceName,
                        })
                    );
                }
                self.children = children;
            })
            .catch(print);
    }

    if (scriptPath) {
        table.poll(interval, (self) => {
            if (deviceName === 'cpu') {
                headerLeftText = `${cpuUsage}%`;
            }
            if (deviceName === 'ram') {
                headerLeftText = `${ramUsage}%`;
            }

            // Calling only if menu is open
            if (!cpuIsInitialized || !ramIsInitialized || menuIsOpen) {
                callWidgetScripts(self);
                if (deviceName === 'cpu' && !cpuIsInitialized) {
                    cpuIsInitialized = true;
                }
                if (deviceName === 'ram' && !ramIsInitialized) {
                    ramIsInitialized = true;
                }
            }
        });
    }

    return table;
};

const tablesBox = () => {
    let batDeviceName = 'bat';

    let batteryTable = hardwareUsageTable({
        scriptPath: '',
        deviceName: batDeviceName,
    }).hook(Battery, (self) => {
        Utils.execAsync(settings.scripts.hardwareInfo)
            .then((val) => {
                let data = JSON.parse(val);

                const currentEnergyRate = parseFloat(data['Energy_Rate']);
                const maxAllowedEnergyRate = 35; // Maximum allowed energy rate in W
                const currentVoltage = parseFloat(data['Voltage']);
                const highVoltage = 14; // High voltage in V

                // if (currentEnergyRate > maxAllowedEnergyRate) {
                //   notify({
                //     tonePath: settings.assets.audio.high_energy_rate,
                //     title: 'تحذير: شحن طاقة مرتفع جداً',
                //     message: `جهازك يشحن بشاحن ذو طاقة مرتفعة جداً (${data['Energy_Rate']} W)، وقد يؤدي ذلك إلى تلف البطارية أو الدوائر الإلكترونية. يرجى التحقق من توافق شاحن الطاقة مع مواصفات جهازك.`,
                //     icon: settings.assets.icons.high_energy_rate,
                //     priority: 'critical',
                //   });
                // }

                if (currentVoltage > highVoltage) {
                    notify({
                        tonePath: settings.assets.audio.high_voltage,
                        title: strings.highVoltageWarning,
                        message: strings.highVoltageMessage
                            .replace('${voltage}', data['Voltage'])
                            .replace('${highVoltage}', highVoltage),
                        icon: settings.assets.icons.high_voltage,
                        priority: 'critical',
                    });
                }

                let children = [
                    // Header
                    tableRow({
                        appName: strings.battery,
                        percentage: '',
                        header: true,
                        deviceName: batDeviceName,
                        rightTextXalign: 1,
                    }),
                    // Body
                    tableRow({
                        appName: local === 'RTL' ? 'النسبة  ' : 'percentage ',
                        percentage: `${Battery.percent}%`,
                        deviceName: batDeviceName,
                    }),
                    tableRow({
                        appName: local === 'RTL' ? 'الصحة   ' : 'Health   ',
                        percentage: data['Capacity'] + '%',
                        deviceName: batDeviceName,
                    }),
                    tableRow({
                        appName: local === 'RTL' ? 'الفولتية  󰚥' : 'Voltage  󰚥',
                        percentage: data['Voltage'],
                        deviceName: batDeviceName,
                    }),
                    tableRow({
                        appName: local === 'RTL' ? 'الطاقة  ' : 'Energy  ',
                        // percentage: `${Battery.energy}`,
                        percentage: data['Energy_Rate'],
                        deviceName: batDeviceName,
                    }),
                    tableRow({
                        appName: local === 'RTL' ? 'الدورات  󱍸' : 'Cycles  󱍸',
                        percentage: data['Charge_Cycles'],
                        deviceName: batDeviceName,
                    }),
                ];
                self.children = children;
            })
            .catch(print);
    });

    let osClassName = 'os';
    let tempTable = hardwareUsageTable({
        scriptPath: '',
        deviceName: osClassName,
    }).poll(10 * 1000, (self) => {
        let children = [
            // Header
            tableRow({
                appName: strings.devicesTemp,
                percentage: parseInt(tempList['total']) + '%',
                header: true,
                rightTextXalign: 0,
                deviceName: osClassName,
            }),
            // Body
            tableRow({
                appName: `${strings.wifiTemp}  `,
                percentage: parseInt(tempList['wifi']) + ' C°',
                deviceName: osClassName,
            }),
            tableRow({
                appName: strings.nvmeTemp + '  󰋊',
                percentage: parseInt(tempList['nvme_total']) + ' C°',
                deviceName: osClassName,
            }),
            tableRow({
                appName: strings.cpuTemp + '  ',
                percentage: parseInt(tempList['cpu_total']) + ' C°',
                deviceName: osClassName,
            }),
        ];
        self.children = children;
    });

    return Widget.Box({
        className: 'hardware-menu-tables-box',
        // vertical: true,
        spacing: 13,
        children: [
            hardwareUsageTable({
                scriptPath: settings.scripts.cpuUsage,
                deviceName: 'cpu',
                headerRightText: 'CPU',
                // headerLeftText: `${cpuUsage}`,
            }),
            hardwareUsageTable({
                scriptPath: settings.scripts.ramUsage,
                deviceName: 'ram',
                headerRightText: 'RAM',
                // headerLeftText: `${ramUsage}`,
                // interval: 5 * 60 * 1000,
            }),
            Widget.Box({
                vertical: true,
                children: [batteryTable, tempTable],
            }),
        ],
    });
};

const menuRevealer = Widget.Revealer({
    transition: settings.theme.menuTransitions.hardwareMenu,
    transitionDuration: settings.theme.menuTransitions.hardwareMenuDuration,
    child: Widget.Box({
        className: 'hardware-menu-box',
        vertical: true,
        children: [
            Widget.Label({
                className: 'media-menu-header',
                label: strings.hardwareCenter,
            }),
            headerBox,
            tablesBox(),
        ],
    }),
});

export const HardwareMenu = () =>
    Widget.Window({
        name: `hardware_menu`,
        margins: [2, 250],
        // layer: 'overlay',
        anchor: ['top', local === 'RTL' ? 'right' : 'left'],
        child: Widget.Box({
            // className: "left-menu-window",
            css: `
            min-height: 2px;
        `,
            children: [menuRevealer],
        }),
    });

globalThis.showHardwareMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild;
    menuIsOpen = menuRevealer.revealChild;
};
