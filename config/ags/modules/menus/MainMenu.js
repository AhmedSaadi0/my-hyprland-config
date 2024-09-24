import themeService from '../services/ThemeService.js';

import Profile from './header/Profile.js';
import Header from './header/Header.js';
import settings from '../settings.js';
import { TitleTextRevealer, local } from '../utils/helpers.js';
import weatherService from '../services/WeatherService.js';
import dashboardTabMenu from './dashboard/DashboardTab.js';
import strings from '../strings.js';
import weatherHeaderCard from './weather/WeatherTab.js';
import MonitorsTab from './monitor/MonitorsTab.js';
import wifiMenu from './network/WifiMenu.js';
import notificationTabMenu from './notifications/NotificationBox.js';

const sharedTabAttrs = {
    spacing: 7,
    vertical: false,
    buttonClass: 'toolbar-button',
    onHover: null,
    onHoverLost: null,
    titleXalign: 0.7,
    textXalign: 0,
    titleClass: 'toolbar-button-icon',
    textClass: 'toolbar-button-text',
};

const dashboardTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰨝',
    text: strings.controlTab,
    buttonClass: 'toolbar-button-selected small-shadow',
    onClicked: () => {
        switchToTab(settings.menuTabs.dashboard);
    },
});

const notificationTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰂞',
    text: strings.notificationsTab,
    onClicked: (btn) => {
        switchToTab(settings.menuTabs.notifications);
    },
});

const weatherTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰖐',
    text: strings.weatherTab,
    onClicked: (btn) => {
        switchToTab(settings.menuTabs.weather);
    },
}).hook(weatherService, (self) => {
    self.child.children[0].label = '󰖐';
    if (weatherService.weatherCode != '') {
        self.child.children[0].label = weatherService.weatherCode;
    }
});

const hardwareTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '',
    text: strings.monitorsTab,
    onClicked: (btn) => {
        switchToTab(settings.menuTabs.monitor);
    },
});

const networkTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '',
    text: strings.networkTab,
    onClicked: (btn) => {
        switchToTab(settings.menuTabs.network);
    },
});

const toolbarIconsBox = Widget.Box({
    className: 'toolbar-icons-box',
    children: [
        dashboardTabIcon,
        notificationTabIcon,
        weatherTabIcon,
        hardwareTabIcon,
        networkTabIcon,
    ],
}).hook(themeService, (box) => {
    box.children[0].child.children[1].revealChild = true;
});

const stack = Widget.Stack({
    transition: 'slide_left_right',
    children: {
        dashboard: dashboardTabMenu,
        notifications: notificationTabMenu,
        weather: weatherHeaderCard,
        monitor: MonitorsTab,
        network: wifiMenu,
    },
    shown: settings.menuTabs.dashboard,
});

const widgets = Widget.Box({
    className: 'left-menu-box unset',
    vertical: true,
    children: [Header(), Profile(), toolbarIconsBox, stack],
});

const menuRevealer = Widget.Revealer({
    transition: settings.theme.menuTransitions.mainMenu,
    child: widgets,
    transitionDuration: settings.theme.menuTransitions.mainMenuDuration,
});

export const MainMenu = ({ monitor } = {}) =>
    Widget.Window({
        name: `left_menu_${monitor}`,
        margins: [-2, 0, 0, 0],
        keymode: 'on-demand',
        // layer: 'overlay',
        anchor: ['top', local === 'RTL' ? 'left' : 'right'],
        child: Widget.Box({
            // className: "left-menu-window",
            css: ` min-height: 2px;`,
            children: [menuRevealer],
        }),
    });

function toggleDashboardTab() {
    if (stack.shown === settings.menuTabs.dashboard) {
        dashboardTabIcon.className = 'toolbar-button-selected small-shadow';
        dashboardTabIcon.child.children[1].reveal_child = true;
    } else {
        dashboardTabIcon.className = 'toolbar-button';
        dashboardTabIcon.child.children[1].reveal_child = false;
    }
}

function toggleNotificationTab() {
    if (stack.shown === settings.menuTabs.notifications) {
        notificationTabIcon.className = 'toolbar-button-selected small-shadow';
        notificationTabIcon.child.children[1].reveal_child = true;
    } else {
        notificationTabIcon.className = 'toolbar-button';
        notificationTabIcon.child.children[1].reveal_child = false;
    }
}

function toggleWeatherTab() {
    if (stack.shown === settings.menuTabs.weather) {
        weatherTabIcon.className = 'toolbar-button-selected small-shadow';
        weatherTabIcon.child.children[1].reveal_child = true;
    } else {
        weatherTabIcon.className = 'toolbar-button';
        weatherTabIcon.child.children[1].reveal_child = false;
    }
}

function toggleMonitorsTab() {
    if (stack.shown === settings.menuTabs.monitor) {
        hardwareTabIcon.className = 'toolbar-button-selected small-shadow';
        hardwareTabIcon.child.children[1].reveal_child = true;
    } else {
        hardwareTabIcon.className = 'toolbar-button';
        hardwareTabIcon.child.children[1].reveal_child = false;
    }
}

function toggleNetworkTab() {
    if (stack.shown === settings.menuTabs.network) {
        networkTabIcon.className = 'toolbar-button-selected small-shadow';
        networkTabIcon.child.children[1].reveal_child = true;
    } else {
        networkTabIcon.className = 'toolbar-button';
        networkTabIcon.child.children[1].reveal_child = false;
    }
}

function switchToTab(menuTabs) {
    stack.shown = menuTabs;

    toggleDashboardTab();
    toggleNotificationTab();
    toggleWeatherTab();
    toggleMonitorsTab();
    toggleNetworkTab();
    revealMediaControls(false);
    revealPowerButtons(false);
    revealAllThemes(false);
}

function openMenu(menuTab) {
    revealMediaControls(false);
    revealPowerButtons(false);
    revealAllThemes(false);

    if (menuRevealer.revealChild && stack.shown.toString() === menuTab) {
        menuRevealer.revealChild = false;
        return;
    }

    if (!menuRevealer.revealChild) {
        menuRevealer.revealChild = true;
    }

    switchToTab(menuTab);
}

export const MenuButton = () =>
    Widget.Button({
        className: 'menu-button unset',
        label: '',
        onClicked: () => {
            openMenu(settings.menuTabs.dashboard);
        },
    });

globalThis.getMenuStatus = () => {
    return menuRevealer.revealChild;
};

globalThis.toggleMainMenu = () => {
    openMenu(settings.menuTabs.dashboard);
};

globalThis.hideMainMenu = () => {
    menuRevealer.revealChild = false;
};

globalThis.ToggleNotificationCenter = () => {
    openMenu(settings.menuTabs.notifications);
};

globalThis.toggleWeather = () => {
    openMenu(settings.menuTabs.weather);
};

globalThis.toggleMonitors = () => {
    openMenu(settings.menuTabs.monitor);
};

globalThis.toggleNetwork = () => {
    openMenu(settings.menuTabs.network);
};
