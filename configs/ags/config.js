// importing 
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import Notifications from 'resource:///com/github/Aylur/ags/service/notifications.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import {
    Box, Button, Stack, Label, Icon, CenterBox, Window, Slider, ProgressBar, Revealer
} from 'resource:///com/github/Aylur/ags/widget.js';
import { exec, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

// import statements are long, so there is also the global ags object you can import from
// const { Hyprland, Notifications, Mpris, Audio, Battery } = ags.Service;
// const { App } = ags;
// const { exec } = ags.Utils;
// const {
//     Box, Button, Stack, Label, Icon, CenterBox, Window, Slider, ProgressBar
// } = ags.Widget;

// every widget is a subclass of Gtk.<widget>
// with a few extra available properties
// for example Box is a subclass of Gtk.Box

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, just make it a function
// then you can use it by calling simply calling it
const Workspaces = () => Box({
    className: 'unset workspaces',
    connections: [
        [
            Hyprland,
            box => {
                // generate an array [1..10] then make buttons from the index
                const arr = Array.from({ length: 10 }, (_, i) => i + 1);
                const inActiveIcons = [
                    "",
                    "󰿤",
                    "󰂕",
                    "",
                    "󱙌",
                    "󱗠",
                    "",
                    "󰺶",
                    "󱋢",
                    ""
                ];
                const activeIcons = [
                    "",
                    "󰿣",
                    "󰂔",
                    "",
                    "󱙋",
                    "󱗟",
                    "",
                    "󰺵",
                    "󱋡",
                    ""
                ];

                box.children = arr.map(i => Button({
                    onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`),
                    child: Label(
                        {
                            label: Hyprland.active.workspace.id == i ? activeIcons[i - 1] : `${inActiveIcons[i - 1]}`
                        }
                    ),
                    className: Hyprland.active.workspace.id == i ? 'focused unset' : 'unfocused unset',
                }));
            }
        ]
    ],
});

function convertToH(bytes) {
    let speed;
    let dim;
    let bits = bytes * 8;
    bits = bits / 10;

    if (bits < 1000) {
        bits = 0;
        speed = bits;
        dim = "b/s";
    } else if (bits < 1000000) {
        speed = bits / 1000;
        dim = "kb/s";
    } else if (bits < 1000000000) {
        speed = bits / 1000000;
        dim = "mb/s";
    } else if (bits < 1000000000000) {
        speed = bits / 1000000000;
        dim = "gb/s";
    } else {
        speed = parseFloat(bits);
        dim = "b/s";
    }

    return Math.floor(speed + 0.5) + dim;
}

const NetSpeedMeters = () => {
    let prevReceivedBytes = 0;
    let prevTransmittedBytes = 0;

    return Box({
        connections: [[1000, box => {
            const receivedBytes = exec("cat /sys/class/net/wlp0s20f3/statistics/rx_bytes");
            const transmittedBytes = exec("cat /sys/class/net/wlp0s20f3/statistics/tx_bytes");

            const download = Label({
                justification: "right",
                style: "min-width: 60px",
            });
            const upload = Label({
                justification: "right",
                style: "min-width: 80px",
            });

            const downloadSpeed = receivedBytes - prevReceivedBytes;
            const uploadSpeed = transmittedBytes - prevTransmittedBytes;

            download.label = `${convertToH(downloadSpeed)} `;
            upload.label = `${convertToH(uploadSpeed)} `;

            prevReceivedBytes = receivedBytes;
            prevTransmittedBytes = transmittedBytes;

            box.children = [
                download,
                upload
            ];

            box.show_all();
        }]]
    });
};


const NetworkInformation = () => Box({
    className: "internet-box",
    connections: [
        [Network, box => {
            let internetLabel;

            const ssidLabel = Label({
                className: "internet-wifi-name-label",
                label: `${Network.wifi.ssid}`
            });

            if (Network.wifi.internet === "disconnected") {
                internetLabel = "󰤮";
            } else if (Network.wifi.strength > 90) {
                internetLabel = "󰤨";
            } else if (Network.wifi.strength > 70) {
                internetLabel = "󰤥";
            } else if (Network.wifi.strength > 50) {
                internetLabel = "󰤢";
            } else if (Network.wifi.strength > 20) {
                internetLabel = "󰤟";
            } else {
                internetLabel = "󰤯";
            }

            const internetStatusLabel = Label({
                className: "internet-strength-icon",
                label: internetLabel,
            });

            box.children = [
                ssidLabel,
                internetStatusLabel,
                NetSpeedMeters()
            ];

            box.show_all();
        }],
    ],
});

const ClientTitle = () => Label({
    className: 'client-title',
    // an initial label value can be given but its pointless
    // because callbacks from connections are run on construction
    // so in this case this is redundant
    label: Hyprland.active.client.title || '',
    connections: [
        [
            Hyprland,
            label => {
                label.label = Hyprland.active.client.title || '';
            }
        ]
    ],
});

const Clock = () => Label({
    className: 'clock',
    connections: [
        [
            1000,
            label => execAsync(
                ['date', '+(%I:%M) %A, %d %B']
            ).then(
                date => label.label = date
            ).catch(console.error)
        ],
    ],
});

// we don't need dunst or any other notification daemon
// because ags has a notification daemon built in
const Notification = () => Box({
    className: 'notification',
    children: [
        Icon({
            icon: 'preferences-system-notifications-symbolic',
            connections: [
                [Notifications, icon => icon.visible = Notifications.popups.size > 0],
            ],
        }),
        Label({
            connections: [[Notifications, label => {
                // notifications is a map, to get the last element lets make an array
                label.label = Array.from(Notifications.popups.values())?.pop()?.summary || '';
            }]],
        }),
    ],
});

const Media = () => Button({
    className: 'media',
    onPrimaryClick: () => Mpris.getPlayer('')?.playPause(),
    onScrollUp: () => Mpris.getPlayer('')?.next(),
    onScrollDown: () => Mpris.getPlayer('')?.previous(),
    child: Label({
        connections: [[Mpris, label => {
            const mpris = Mpris.getPlayer('');
            // mpris player can be undefined
            if (mpris)
                label.label = `${mpris.trackArtists.join(', ')} - ${mpris.trackTitle}`;
            else
                label.label = 'Nothing is playing';
        }]],
    }),
});

const Volume = () => Box({
    className: 'volume',
    style: 'min-width: 100px',
    children: [
        Stack({
            className: "vol-stack",
            items: [
                // tuples of [string, Widget]
                ['101', Icon('audio-volume-overamplified-symbolic')],
                ['67', Icon('audio-volume-high-symbolic')],
                ['34', Icon('audio-volume-medium-symbolic')],
                ['1', Icon('audio-volume-low-symbolic')],
                ['0', Icon('audio-volume-muted-symbolic')],
            ],
            connections: [[Audio, stack => {
                if (!Audio.speaker)
                    return;

                if (Audio.speaker.isMuted) {
                    stack.shown = '0';
                    return;
                }

                const show = [101, 67, 34, 1, 0].find(
                    threshold => threshold <= Audio.speaker.volume * 100
                );

                stack.shown = `${show}`;
            }, 'speaker-changed']],
        }),
        Slider({
            hexpand: true,
            className: "unset",
            drawValue: false,
            onChange: ({ value }) => Audio.speaker.volume = value,
            connections: [[Audio, slider => {
                if (!Audio.speaker)
                    return;

                slider.value = Audio.speaker.volume;
            }, 'speaker-changed']],
        }),
    ],
});

const BatteryLabel = () => Box({
    className: 'battery',
    children: [
        Icon({
            connections: [[Battery, icon => {
                icon.icon = `battery-level-${Math.floor(Battery.percent / 10) * 10}-symbolic`;
            }]],
        }),
        ProgressBar({
            valign: 'center',
            connections: [[Battery, progress => {
                if (Battery.percent < 0)
                    return;

                progress.fraction = Battery.percent / 100;
            }]],
        }),
    ],
});

const BatteryRevealer = () => Revealer({
    child: BatteryLabel(),
    transition: "slide_left",
});

// layout of the bar
const Right = () => Box({
    children: [
        Workspaces(),
        ClientTitle(),
    ],
});

const Center = () => Box({
    children: [
        Clock(),
        Notification(),
    ],
});

const Left = () => Box({
    halign: 'end',
    children: [
        NetworkInformation(),
        Volume()
    ],
});

const Bar = ({ monitor } = {}) => Window({
    name: `bar${monitor || ''}`, // name has to be unique
    className: 'bar',
    monitor,
    anchor: ['top', 'left', 'right'],
    exclusive: true,
    child: CenterBox({
        startWidget: Right(),
        centerWidget: Center(),
        endWidget: Left(),
    }),
})

// exporting the config so ags can manage the windows
export default {
    style: App.configDir + '/style.css',
    windows: [
        Bar(),

        // you can call it, for each monitor
        // Bar({ monitor: 0 }),
        // Bar({ monitor: 1 })
    ],
};
