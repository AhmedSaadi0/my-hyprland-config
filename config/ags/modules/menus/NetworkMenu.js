import { local } from '../utils/helpers.js';
import { Widget, Utils, Battery } from '../utils/imports.js';
const network = await Service.import('network');

const stack = Widget.Stack({
    transition: 'slide_left_right',
    children: {
        child1: Widget.Label('first child'),
        child2: Widget.Label('second child'),
    },
    shown: 'child2',
});

const menuRevealer = Widget.Revealer({
    transition: 'slide_down',
    child: Widget.Box({
        className: 'hardware-menu-box',
        vertical: true,
        children: [stack],
    }),
});

export const networkMenu = Widget.Window({
    name: `network_menu`,
    margins: [2, 250],
    // layer: 'overlay',
    anchor: ['top', local === 'RTL' ? 'left' : 'right'],
    child: Widget.Box({
        css: `
            min-height: 2px;
        `,
        children: [menuRevealer],
    }),
});

globalThis.showNetworkMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild;
};
