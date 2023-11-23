import { Widget, Utils, Battery } from "../utils/imports.js";


const cpuProgress = Widget.CircularProgress({
    className: "menu-cpu",
    child: Widget.Label({
        className: "menu-cpu-icon",
        label: ""
    }),
    startAt: 0,
    rounded: false,
    // inverted: true,
    connections: [
        [1000, self => {
            Utils.execAsync(`/home/ahmed/.config/ags/scripts/cpu.sh`)
                .then(val => {
                    cpuProgress.value = val / 100;
                }).catch(print);
        }],
    ],
});

const ramProgress = Widget.CircularProgress({
    className: "menu-ram",
    child: Widget.Label({
        className: "menu-ram-icon",
        label: ""
    }),
    startAt: 0,
    rounded: false,
    // inverted: true,
    connections: [
        [30000, self => {
            Utils.execAsync(`/home/ahmed/.config/ags/scripts/ram.sh`)
                .then(val => {
                    self.value = (val / 100);
                }).catch(print);
        }],
    ],
});

const batteryProgress = Widget.CircularProgress({
    className: "menu-battery",
    child: Widget.Label({
        className: "menu-battery-icon",
        label: ""
    }),
    startAt: 0,
    rounded: false,
    // inverted: true,
    connections: [[Battery, self => {
        let percentage = Battery.percent;
        self.value = percentage / 100;
        if (Battery.charging) {
            self.child.label = "";
            self.child.className = "menu-battery-icon-charging";
        } else {
            self.child.label = "";
            self.child.className = "menu-battery-icon";
        }
    }]],

});

const tempProgress = Widget.CircularProgress({
    className: "menu-temp",
    child: Widget.Label({
        className: "menu-temp-icon",
        label: ""
    }),
    startAt: 0,
    rounded: false,
    // inverted: true,
    connections: [
        [30000, self => {
            Utils.execAsync(`/home/ahmed/.config/ags/scripts/temp.sh`)
                .then(val => {
                    const temps = val.split("\n");
                    let total = 0;
                    for (let index = 0; index < temps.length; index++) {
                        const element = temps[index].replace("+", "").replace("°C", "");
                        total += parseInt(element);
                    }
                    total = parseInt(total / temps.length);
                    self.value = (total / 100);

                }).catch(print);
        }],
    ],
});

const headerBox = Widget.Box({
    className: "hardware-menu-header-box",
    spacing: 6.5,
    children: [
        cpuProgress,
        ramProgress,
        batteryProgress,
        tempProgress,
    ]
});


const hardwareUsageTable = ({
    scriptPath,
    deviceName,
    interval = 2000,
}) => {
    let tableRow = ({
        appName = "",
        percentage = "",
        header = false,
    }) => Widget.Box({
        className: header ? `hardware-${deviceName}-table-row-header` : `hardware-${deviceName}-table-row`,
        children: [
            Widget.Label({
                className: header ? "table-row-app-name-header" : "table-row-app-name",
                label: appName,
                justification: 'left',
                truncate: 'end',
                xalign: 0,
                maxWidthChars: 7,
                wrap: true,
                useMarkup: true,
            }),
            Widget.Label({
                className: header ? "table-row-app-percentage-header" : "table-row-app-percentage",
                label: percentage,
                justification: 'right',
                truncate: 'end',
                xalign: header ? 0.8 : 1,
                maxWidthChars: 5,
                wrap: true,
                useMarkup: true,
            }),
        ]
    })

    return Widget.Box({
        className: `hardware-${deviceName}-box`,
        vertical: true,
        children: [],
        connections: [
            [interval, self => {
                Utils.execAsync(scriptPath)
                    .then(val => {
                        let data = JSON.parse(val);
                        let children = [
                            tableRow({
                                appName: "العملية",
                                percentage: "%",
                                header: true,
                            })
                        ];

                        for (let index = 0; index < data.length; index++) {
                            const element = data[index];
                            children.push(tableRow({
                                appName: element["process"],
                                percentage: element["%"],
                            }));
                        }
                        self.children = children;
                    }).catch(print);
            }],
        ],
    })
};


const tablesBox = Widget.Box({
    // className: "hardware-menu-box",
    // vertical: true,
    spacing: 13,
    children: [
        hardwareUsageTable({
            scriptPath: "/home/ahmed/.config/ags/scripts/cpu_usage.sh",
            deviceName: "cpu"
        }),
        hardwareUsageTable({
            scriptPath: "/home/ahmed/.config/ags/scripts/ram_usage.sh",
            deviceName: "ram",
            interval: 5 * 60 * 1000,
        }),
        hardwareUsageTable({
            scriptPath: "/home/ahmed/.config/ags/scripts/cpu_usage.sh",
            deviceName: "cpu"
        }),
    ]
});



const menuRevealer = Widget.Revealer({
    transition: "slide_down",
    child: Widget.Box({
        className: "hardware-menu-box",
        vertical: true,
        children: [
            headerBox,
            tablesBox,
        ]
    }),
})

export const HardwareMenu = () => Widget.Window({
    name: `hardware_menu`,
    margins: [6, 250],
    // layer: 'overlay',
    anchor: ['top', "right"],
    child: Widget.Box({
        // className: "left-menu-window",
        css: `
            min-height: 0.0001rem;
        `,
        children: [
            menuRevealer,
        ],
    })
})


globalThis.showHardwareMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild
};
