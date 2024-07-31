import themeService from '../services/ThemeService.js';

import Profile from './dashboard/Profile.js';
import Header from './dashboard/Header.js';
import ThemesButtonsRowOne from './dashboard/ThemesButtonsRowOne.js';
import PowerButtonsRow from './dashboard/PowerButtonsRow.js';
import settings from '../settings.js';
import { local } from '../utils/helpers.js';
import MediaControl from './dashboard/MediaControl.js';

const widgets = Widget.Box({
    className: 'left-menu-box unset',
    vertical: true,
    children: [
        Header(),
        Profile(),
        ThemesButtonsRowOne(),
        MediaControl(),
        PowerButtonsRow(),
    ],
});

const menuRevealer = Widget.Revealer({
    transition: settings.theme.menuTransitions.leftMenu,
    child: widgets,
    transitionDuration: settings.theme.menuTransitions.leftMenuDuration,
});

export const LeftMenu = ({ monitor } = {}) =>
    Widget.Window({
        name: `left_menu_${monitor}`,
        margins: [-2, 0, 0, 0],
        // layer: 'overlay',
        anchor: ['top', local === 'RTL' ? 'left' : 'right'],
        child: Widget.Box({
            // className: "left-menu-window",
            css: ` min-height: 2px;`,
            children: [menuRevealer],
        }),
    });

export const MenuButton = () =>
    Widget.Button({
        className: 'menu-button unset',
        label: '',
        onClicked: () => {
            menuRevealer.revealChild = !menuRevealer.revealChild;
            changeMenuBtn();
        },
    });

globalThis.showLeftMenu = () => {
    menuRevealer.revealChild = !menuRevealer.revealChild;
    changeMenuBtn();
};

function changeMenuBtn() {
    if (menuRevealer.revealChild) {
        MenuButton.label = '';
    } else {
        MenuButton.label = '';
    }
}
