import { NetworkInformation } from "./internet.js";
import { Workspaces } from "./workspace.js";
import { Volume } from "./volume.js";
import { HardwareBox } from "./hardware/all.js";
import { SysTrayBox } from "./systray.js";
const { Window, CenterBox, Box, Label } = ags.Widget
const { execAsync } = ags.Utils


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

// layout of the bar
const Right = () => Box({
    children: [
        Workspaces(),
        HardwareBox(),
        // ClientTitle(),
    ],
});

const Center = () => Box({
    children: [
        Clock(),
        // NotificationBox(),
        // Notification(),
    ],
});

const Left = () => Box({
    halign: 'end',
    children: [
        NetworkInformation(),
        Volume(),
        SysTrayBox(),
    ],
});


export const Bar = ({ monitor } = {}) => Window({
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