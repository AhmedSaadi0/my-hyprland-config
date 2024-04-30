import tableRow from '../components/TableRow.js';
import { local, notify } from '../utils/helpers.js';
import { Widget, Utils, Battery } from '../utils/imports.js';
import settings from '../settings.js';

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
  rounded: false,
}).poll(1000, (self) => {
  if (menuIsOpen) {
    Utils.execAsync(`/home/${Utils.USER}/.config/ags/scripts/cpu.sh`)
      .then((val) => {
        cpuProgress.value = val / 100;
        self.child.tooltipMarkup = `<span weight='bold'>مستهلك من المعالج(${val}%)</span>`;
        cpuUsage = val;
      })
      .catch(print);
  }
});

const ramProgress = Widget.CircularProgress({
  className: 'menu-ram',
  child: Widget.Label({
    className: 'menu-ram-icon',
    label: '',
  }),
  startAt: 0,
  rounded: false,
}).poll(1000, (self) => {
  if (menuIsOpen) {
    Utils.execAsync(`/home/${Utils.USER}/.config/ags/scripts/ram.sh`)
      .then((val) => {
        self.value = val / 100;
        self.child.tooltipMarkup = `<span weight='bold'>مستهلك من الرام (${val}%)</span>`;
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
  rounded: false,
}).hook(Battery, (self) => {
  let percentage = Battery.percent;
  self.value = percentage / 100;

  var label = '';

  if (Battery.charging) {
    if (percentage <= 55) {
      label = '󱊤';
    } else if (percentage <= 70) {
      label = '󱊥';
    } else if (percentage > 70) {
      label = '󱊦';
    }
    // self.child.label = "";
    self.child.className = 'menu-battery-icon-charging';
  } else {
    if (percentage <= 55) {
      label = '󱊡';
    } else if (percentage <= 70) {
      label = '󱊢';
    } else if (percentage > 70) {
      label = '󱊣';
    }
    // self.child.label = "";
    self.child.className = 'menu-battery-icon';
  }
  self.child.label = label;

  self.child.tooltipMarkup = `<span weight='bold'>نسبة البطارية (${percentage}%)</span>`;
});

const tempProgress = Widget.CircularProgress({
  className: 'menu-temp',
  child: Widget.Label({
    className: 'menu-temp-icon',
    label: '',
  }),
  startAt: 0,
  rounded: false,
}).poll(30000, (self) => {
  Utils.execAsync(`/home/${Utils.USER}/.config/ags/scripts/devices_temps.sh`)
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
          title: 'تحذير: درجة حرارة الواي فاي مرتفعة جداً',
          message: `درجة حرارة جهاز الواي فاي مرتفعة (${wifiTemp}°C) وقد تؤدي إلى أداء غير مستقر أو تلف الأجهزة. يرجى التحقق من تهوية الجهاز والتأكد من عدم وجود مشكلات في التبريد.`,
          icon: settings.assets.icons.high_temp_warning,
          priority: 'critical',
        });
      }

      if (nvmeTemp >= CRITICAL_NVME_TEMP) {
        notify({
          tonePath: settings.assets.audio.high_temp_warning,
          title: 'تحذير: درجة حرارة NVMe مرتفعة جداً',
          message: `درجة حرارة NVMe مرتفعة (${nvmeTemp}°C) وقد تؤدي إلى أداء غير مستقر أو تلف الأجهزة. يرجى التحقق من تهوية الجهاز والتأكد من عدم وجود مشكلات في التبريد.`,
          icon: settings.assets.icons.high_temp_warning,
          priority: 'critical',
        });
      }

      if (cpuTemp >= CRITICAL_CPU_TEMP) {
        notify({
          tonePath: settings.assets.audio.high_temp_warning,
          title: 'تحذير: درجة حرارة المعالج المركزي مرتفعة جداً',
          message: `درجة حرارة المعالج المركزي مرتفعة (${cpuTemp}°C) وقد تؤدي إلى أداء غير مستقر أو تلف الأجهزة. يرجى التحقق من تهوية الجهاز والتأكد من عدم وجود مشكلات في التبريد.`,
          icon: settings.assets.icons.high_temp_warning,
          priority: 'critical',
        });
      }

      var totalTemp = wifiTemp + nvmeTemp + cpuTemp;
      totalTemp = totalTemp / 3;

      tempList['total'] = totalTemp;

      self.value = totalTemp / 100;
      self.child.tooltipMarkup = `<span weight='bold'>اجمالي درجة حرارة الاجهزة (${parseInt(totalTemp)}%)</span>`;
    })
    .catch(print);
});

const headerBox = Widget.Box({
  className: 'hardware-menu-header-box',
  spacing: 32,
  children: [cpuProgress, ramProgress, batteryProgress, tempProgress],
});

const hardwareUsageTable = ({
  scriptPath,
  deviceName,
  interval = 2000,
  headerRightText = 'العملية',
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
    Utils.execAsync(`/home/${Utils.USER}/.config/ags/scripts/hardware_info.sh`)
      .then((val) => {
        let data = JSON.parse(val);

        const currentEnergyRate = parseFloat(data['Energy_Rate']);
        const maxAllowedEnergyRate = 35; // Maximum allowed energy rate in W
        const currentVoltage = parseFloat(data['Voltage']);
        const highVoltage = 13; // High voltage in V

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
            title: 'تحذير: فولتية مرتفعة جداً',
            message: `جهازك يستخدم شاحن بفولتية (${data['Voltage']} V) أعلى من المتوقع (${highVoltage} V). قد يؤدي ذلك إلى تلف البطارية أو الدوائر الإلكترونية. يرجى استخدام شاحن مناسب لجهازك.`,
            icon: settings.assets.icons.high_voltage,
            priority: 'critical',
          });
        }

        let children = [
          // Header
          tableRow({
            appName: 'البطارية',
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
        appName: 'حرارة الاجهزة',
        percentage: parseInt(tempList['total']) + '%',
        header: true,
        rightTextXalign: 0,
        deviceName: osClassName,
      }),
      // Body
      tableRow({
        appName: 'الوايفاي  ',
        percentage: parseInt(tempList['wifi']) + ' C°',
        deviceName: osClassName,
      }),
      tableRow({
        appName: 'الهارد  󰋊',
        percentage: parseInt(tempList['nvme_total']) + ' C°',
        deviceName: osClassName,
      }),
      tableRow({
        appName: 'المعالج  ',
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
        scriptPath: `/home/${Utils.USER}/.config/ags/scripts/cpu_usage.sh`,
        deviceName: 'cpu',
        headerRightText: 'CPU',
        // headerLeftText: `${cpuUsage}`,
      }),
      hardwareUsageTable({
        scriptPath: `/home/${Utils.USER}/.config/ags/scripts/ram_usage.sh`,
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
  transition: 'slide_down',
  child: Widget.Box({
    className: 'hardware-menu-box',
    vertical: true,
    children: [headerBox, tablesBox()],
  }),
});

export const HardwareMenu = () =>
  Widget.Window({
    name: `hardware_menu`,
    margins: [4, 250],
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
