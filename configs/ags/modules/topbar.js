import { NetworkInformation } from "./widgets/internet.js";
import { Workspaces } from "./widgets/workspace.js";
import { Volume } from "./widgets/volume.js";
import { HardwareBox } from "./widgets/hardware/all.js";
import { SysTrayBox } from "./widgets/systray.js";
import NotificationIndicator from "./widgets/NotificationIndicator.js";
import {NotificationCenterButton} from "./menus/notification_center.js";
import { MenuButton } from './menus/left_menu.js'
const { Window, CenterBox, Box, Label, Button } = ags.Widget;
const { execAsync } = ags.Utils;


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
        NotificationIndicator(),
        NetworkInformation(),
        Volume(),
        NotificationCenterButton(),
        SysTrayBox(),
        MenuButton(),
    ],
});


export const Bar = ({ monitor } = {}) => Window({
    name: `bar${monitor || ''}`, // name has to be unique
    className: 'bar shadow',
    monitor,
    anchor: ['top', 'left', 'right'],
    exclusive: true,
    child: CenterBox({
        startWidget: Right(),
        centerWidget: Center(),
        endWidget: Left(),
    }),
})