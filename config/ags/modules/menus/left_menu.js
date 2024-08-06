import themeService from '../services/ThemeService.js';

import Profile from './dashboard/Profile.js';
import Header from './dashboard/Header.js';
import ThemesButtonsRowOne from './dashboard/ThemesButtonsRowOne.js';
import PowerButtonsRow from './dashboard/PowerButtonsRow.js';
import settings from '../settings.js';
import { TitleTextRevealer, local, truncateString } from '../utils/helpers.js';
import MediaControl from './dashboard/MediaControl.js';
import weatherService from '../services/WeatherService.js';

const sharedTabAttrs = {
    spacing: 7,
    vertical: false,
    buttonClass: 'toolbar-button small-shadow',
    onHover: null,
    onHoverLost: null,
};

const dashboardTab = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰨝',
    text: truncateString('التحكم', 7),
    buttonClass: 'toolbar-button-selected small-shadow',
    onClicked: (btn) => {
        selectDashboard();
    },
});

function selectDashboard() {
    notificationTab.className = 'toolbar-button';
    weatherTab.className = 'toolbar-button';
    calenderTab.className = 'toolbar-button';
    hardwareTab.className = 'toolbar-button';

    notificationTab.child.children[1].reveal_child = false;
    weatherTab.child.children[1].reveal_child = false;
    calenderTab.child.children[1].reveal_child = false;
    hardwareTab.child.children[1].reveal_child = false;

    dashboardTab.className = 'toolbar-button-selected small-shadow';
    dashboardTab.child.children[1].reveal_child = true;
}

const notificationTab = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰂞',
    text: truncateString('اشعارات', 7),
    onClicked: (btn) => {
        dashboardTab.className = 'toolbar-button';
        weatherTab.className = 'toolbar-button';
        calenderTab.className = 'toolbar-button';
        hardwareTab.className = 'toolbar-button';

        dashboardTab.child.children[1].reveal_child = false;
        weatherTab.child.children[1].reveal_child = false;
        calenderTab.child.children[1].reveal_child = false;
        hardwareTab.child.children[1].reveal_child = false;

        btn.className = 'toolbar-button-selected small-shadow';
        btn.child.children[1].reveal_child = true;
    },
});

const weatherTab = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰖐',
    text: truncateString('الطقس', 7),
    onClicked: (btn) => {
        dashboardTab.className = 'toolbar-button';
        notificationTab.className = 'toolbar-button';
        calenderTab.className = 'toolbar-button';
        hardwareTab.className = 'toolbar-button';

        dashboardTab.child.children[1].reveal_child = false;
        notificationTab.child.children[1].reveal_child = false;
        calenderTab.child.children[1].reveal_child = false;
        hardwareTab.child.children[1].reveal_child = false;

        btn.className = 'toolbar-button-selected small-shadow';
        btn.child.children[1].reveal_child = true;
    },
}).hook(weatherService, (self) => {
    self.child.children[0].label = '󰖐';
    if (weatherService.weatherCode != '') {
        self.child.children[0].label = weatherService.weatherCode;
    }
});

const hardwareTab = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '',
    text: truncateString('العتاد', 7),
    onClicked: (btn) => {
        dashboardTab.className = 'toolbar-button';
        notificationTab.className = 'toolbar-button';
        weatherTab.className = 'toolbar-button';
        calenderTab.className = 'toolbar-button';

        dashboardTab.child.children[1].reveal_child = false;
        weatherTab.child.children[1].reveal_child = false;
        notificationTab.child.children[1].reveal_child = false;
        calenderTab.child.children[1].reveal_child = false;

        btn.className = 'toolbar-button-selected small-shadow';
        btn.child.children[1].reveal_child = true;
    },
});

const calenderTab = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰸗',
    text: truncateString('التقويم', 7),
    onClicked: (btn) => {
        dashboardTab.className = 'toolbar-button';
        weatherTab.className = 'toolbar-button';
        hardwareTab.className = 'toolbar-button';
        notificationTab.className = 'toolbar-button';

        dashboardTab.child.children[1].reveal_child = false;
        weatherTab.child.children[1].reveal_child = false;
        hardwareTab.child.children[1].reveal_child = false;
        notificationTab.child.children[1].reveal_child = false;

        btn.className = 'toolbar-button-selected small-shadow';
        btn.child.children[1].reveal_child = true;
    },
});

const toolbarIconsBox = Widget.Box({
    className: 'toolbar-icons-box',
    children: [
        dashboardTab,
        notificationTab,
        weatherTab,
        hardwareTab,
        calenderTab,
    ],
}).hook(themeService, (box) => {
    box.children[0].child.children[1].revealChild = true;
});

const widgets = Widget.Box({
    className: 'left-menu-box unset',
    vertical: true,
    children: [
        Header(),
        Profile(),
        toolbarIconsBox,
        ThemesButtonsRowOne(),
        MediaControl(),
        PowerButtonsRow(),
    ],
});

const stack = Widget.Stack({
    children: {
        child1: Widget.Label('first child'),
        child2: Widget.Label('second child'),
    },
    shown: 'child2',
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
    selectDashboard();
};

function changeMenuBtn() {
    if (menuRevealer.revealChild) {
        MenuButton.label = '';
    } else {
        MenuButton.label = '';
    }
}
