import themeService from '../services/ThemeService.js';

import Profile from './header/Profile.js';
import Header from './header/Header.js';
import ThemesButtonsRowOne from './dashboard/ThemesButtons.js';
import PowerButtonsRow from './dashboard/PowerButtons.js';
import settings from '../settings.js';
import { TitleTextRevealer, local, truncateString } from '../utils/helpers.js';
import MediaControl from './dashboard/MediaControl.js';
import weatherService from '../services/WeatherService.js';
import notificationContainer from './notifications/Notifications.js';
import dashboardTabMenu from './dashboard/DashboardTab.js';
import strings from '../strings.js';
import notificationHeader from './notifications/NotificationHeader.js';
import weatherHeaderCard from './weather/WeatherTab.js';

const sharedTabAttrs = {
    spacing: 7,
    vertical: false,
    buttonClass: 'toolbar-button',
    onHover: null,
    onHoverLost: null,
};

const dashboardTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰨝',
    text: strings.controlTab,
    buttonClass: 'toolbar-button-selected small-shadow',
    onClicked: (btn) => {
        switchToTab(settings.menuTabs.dashboard);
    },
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

function toggleCalenderTab() {
    if (stack.shown === settings.menuTabs.calender) {
        calenderTabIcon.className = 'toolbar-button-selected small-shadow';
        calenderTabIcon.child.children[1].reveal_child = true;
    } else {
        calenderTabIcon.className = 'toolbar-button';
        calenderTabIcon.child.children[1].reveal_child = false;
    }
}

function switchToTab(menuTabs) {
    stack.shown = menuTabs;

    toggleDashboardTab();
    toggleNotificationTab();
    toggleWeatherTab();
    toggleMonitorsTab();
    toggleCalenderTab();
}

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

const calenderTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰸗',
    text: strings.calenderTab,
    onClicked: (btn) => {
        switchToTab(settings.menuTabs.calender);
    },
});

const toolbarIconsBox = Widget.Box({
    className: 'toolbar-icons-box',
    children: [
        dashboardTabIcon,
        notificationTabIcon,
        weatherTabIcon,
        hardwareTabIcon,
        calenderTabIcon,
    ],
}).hook(themeService, (box) => {
    box.children[0].child.children[1].revealChild = true;
});

const notificationTabMenu = Widget.Box({
    vertical: true,
    children: [notificationHeader, notificationContainer],
});

const stack = Widget.Stack({
    transition: 'slide_left_right',
    children: {
        dashboard: dashboardTabMenu,
        notifications: notificationTabMenu,
        weather: weatherHeaderCard,
        monitor: Widget.Label('Monitor here'),
        calender: Widget.Label('Calender here'),
    },
    shown: settings.menuTabs.dashboard,
});

const widgets = Widget.Box({
    className: 'left-menu-box unset',
    vertical: true,
    children: [Header(), Profile(), toolbarIconsBox, stack],
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

function openMenu(menuTab) {
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

globalThis.toggleLeftMenu = () => {
    openMenu(settings.menuTabs.dashboard);
};

globalThis.hideLeftMenu = () => {
    menuRevealer.revealChild = false;
};

globalThis.showNotificationCenter = () => {
    openMenu(settings.menuTabs.notifications);
};
