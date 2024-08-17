const Battery = await Service.import('battery');

import tableRow from '../../components/TableRow.js';
import settings from '../../settings.js';
import strings from '../../strings.js';
import { getMinutesBetweenDates, local, notify } from '../../utils/helpers.js';
import { cpuUsage, menuIsOpen, ramUsage, tempList } from './Progresses.js';

let batDeviceName = 'bat';
let osClassName = 'os';

var cpuIsInitialized = false;
var ramIsInitialized = false;

var cpuHighUsageWarned = new Map();
const HIGH_CPU_USAGE_PERCENTAGE = 30;
const HIGH_CPU_USAGE_CHECK_INTERVEL = 3; // In minutes

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
                    checkHighCpuUsage(element);
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

            try {
                menuIsOpen = getMenuStatus();
            } catch (ReferenceError) {}

            // Calling only if menu is open
            callWidgetScripts(self);
            if (!cpuIsInitialized || !ramIsInitialized) {
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

function checkHighCpuUsage(element) {
    if (parseInt(element['%']) > HIGH_CPU_USAGE_PERCENTAGE) {
        const processLatestWarning = cpuHighUsageWarned.has(element['pid'])
            ? cpuHighUsageWarned.get(element['pid'])
            : new Date();

        if (
            getMinutesBetweenDates(
                processLatestWarning,
                new Date() > HIGH_CPU_USAGE_CHECK_INTERVEL
            )
        ) {
            cpuHighUsageWarned.set(element['pid'], {
                date: new Date(),
                process: element,
            });

            notify({
                tonePath: settings.assets.audio.cpuHighUsage,
                icon: 'cpu',
                title: strings.highCpuUsageTitle,
                message: strings.highCpuUsageMessage
                    .replace('${process}', element['process'])
                    .replace('${percentage}', element['%']),
            });
        }
    }
}

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

export default Widget.Box({
    // className: 'hardware-menu-tables-box',
    vertical: true,
    // spacing: 7,
    children: [
        Widget.Box({
            spacing: 13,
            // homogeneous: true,
            children: [
                hardwareUsageTable({
                    scriptPath: settings.scripts.cpuUsage,
                    deviceName: 'cpu',
                    headerRightText: strings.cpu,
                    // headerLeftText: `${cpuUsage}`,
                }),
                hardwareUsageTable({
                    scriptPath: settings.scripts.ramUsage,
                    deviceName: 'ram',
                    headerRightText: strings.ram,
                    // headerLeftText: `${ramUsage}`,
                    // interval: 5 * 60 * 1000,
                }),
            ],
        }),
        Widget.Box({
            // vertical: true,
            spacing: 13,
            children: [batteryTable, tempTable],
        }),
    ],
});
