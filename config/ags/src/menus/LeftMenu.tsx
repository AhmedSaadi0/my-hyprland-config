import { Box, Button, Label, Revealer, Stack, Window } from 'astal/gtk3/widget';
import settings from '../utils/settings';
import strings from '../utils/strings';
import { TitleTextRevealer } from '../widgets/TitleText';
import { Astal, Gtk } from 'astal/gtk3';

const sharedTabAttrs = {
    spacing: 7,
    vertical: false,
    buttonClass: 'toolbar-button',
    titleXalign: 0.7,
    textXalign: 0,
    titleClass: 'toolbar-button-icon',
    textClass: 'toolbar-button-text',
    onHover: (btn: Button) => {},
    onHoverLost: (btn: Button) => {},
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
    onClicked: () => {
        switchToTab(settings.menuTabs.notifications);
    },
});

const weatherTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '󰖐',
    text: strings.weatherTab,
    onClicked: () => {
        switchToTab(settings.menuTabs.weather);
    },
});

const hardwareTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '',
    text: strings.monitorsTab,
    onClicked: () => {
        switchToTab(settings.menuTabs.monitor);
    },
});

const networkTabIcon = TitleTextRevealer({
    ...sharedTabAttrs,
    title: '',
    text: strings.networkTab,
    onClicked: () => {
        switchToTab(settings.menuTabs.network);
    },
});

// إنشاء صندوق الأيقونات (ToolbarIconsBox) باستخدام new Box
const toolbarIconsBox = new Box({
    className: 'toolbar-icons-box',
    children: [
        dashboardTabIcon,
        notificationTabIcon,
        weatherTabIcon,
        hardwareTabIcon,
        networkTabIcon,
    ],
});

const stack = new Stack({
    transition_type: Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
    children: [
        new Label({
            label: 'dashboard',
            name: settings.menuTabs.dashboard,
        }),
        new Label({
            label: 'notifications',
            name: settings.menuTabs.notifications,
        }),
        new Label({
            label: 'weather',
            name: settings.menuTabs.weather,
        }),
        new Label({
            label: 'monitor',
            name: settings.menuTabs.monitor,
        }),
        new Label({
            label: 'network',
            name: settings.menuTabs.network,
        }),
    ],
    shown: settings.menuTabs.dashboard,
});

// تجميع الودجات معًا في صندوق رئيسي
const widgets = new Box({
    className: 'left-menu-box unset',
    vertical: true,
    children: [toolbarIconsBox, stack],
});

// إنشاء Revealer للقائمة باستخدام new Revealer
const menuRevealer = new Revealer({
    transition: settings.theme.menuTransitions.mainMenu,
    child: widgets,
    transitionDuration: settings.theme.menuTransitions.mainMenuDuration,
    revealChild: true,
});

// تعريف المكون الرئيسي للقائمة (MainMenu) باستخدام new Window
export function MainMenu({ monitor }: { monitor?: any } = {}) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

    return new Window({
        name: `left_menu_${monitor}`,
        margins: [-2, 0, 0, 0],
        keymode: 'on-demand',
        anchor: [TOP | LEFT],
        child: new Box({
            css: 'min-height: 2px;',
            children: [menuRevealer],
        }),
    });
}

// تعريف زر القائمة (MenuButton) باستخدام new Button
export const MenuButton = new Button({
    className: 'menu-button unset',
    label: '',
    onClicked: () => {
        openMenu(settings.menuTabs.dashboard);
    },
});

function toggleDashboardTab() {
    if (stack.shown === settings.menuTabs.dashboard) {
        dashboardTabIcon.className = 'toolbar-button-selected small-shadow';
        dashboardTabIcon.get_child().children[1].reveal_child = true;
    } else {
        dashboardTabIcon.className = 'toolbar-button';
        dashboardTabIcon.get_child().children[1].reveal_child = false;
    }
}

function toggleNotificationTab() {
    if (stack.shown === settings.menuTabs.notifications) {
        notificationTabIcon.className = 'toolbar-button-selected small-shadow';
        notificationTabIcon.get_child().children[1].reveal_child = true;
    } else {
        notificationTabIcon.className = 'toolbar-button';
        notificationTabIcon.get_child().children[1].reveal_child = false;
    }
}

function toggleWeatherTab() {
    if (stack.shown === settings.menuTabs.weather) {
        weatherTabIcon.className = 'toolbar-button-selected small-shadow';
        weatherTabIcon.get_child().children[1].reveal_child = true;
    } else {
        weatherTabIcon.className = 'toolbar-button';
        weatherTabIcon.get_child().children[1].reveal_child = false;
    }
}

function toggleMonitorsTab() {
    if (stack.shown === settings.menuTabs.monitor) {
        hardwareTabIcon.className = 'toolbar-button-selected small-shadow';
        hardwareTabIcon.get_child().children[1].reveal_child = true;
    } else {
        hardwareTabIcon.className = 'toolbar-button';
        hardwareTabIcon.get_child().children[1].reveal_child = false;
    }
}

function toggleNetworkTab() {
    if (stack.shown === settings.menuTabs.network) {
        networkTabIcon.className = 'toolbar-button-selected small-shadow';
        networkTabIcon.get_child().children[1].reveal_child = true;
    } else {
        networkTabIcon.className = 'toolbar-button';
        networkTabIcon.get_child().children[1].reveal_child = false;
    }
}

function switchToTab(menuTabs: String) {
    stack.shown = menuTabs;

    toggleDashboardTab();
    toggleNotificationTab();
    toggleWeatherTab();
    toggleMonitorsTab();
    toggleNetworkTab();
    // revealMediaControls(false);
    // revealPowerButtons(false);
    // revealAllThemes(false);
}

function openMenu(menuTab: String) {
    // revealMediaControls(false);
    // revealPowerButtons(false);
    // revealAllThemes(false);

    if (menuRevealer.revealChild && stack.shown.toString() === menuTab) {
        menuRevealer.revealChild = false;
        return;
    }

    if (!menuRevealer.revealChild) {
        menuRevealer.revealChild = true;
    }

    switchToTab(menuTab);
}

// globalThis.getMenuStatus = () => {
//     return menuRevealer.revealChild;
// };
//
// globalThis.toggleMainMenu = () => {
//     openMenu(settings.menuTabs.dashboard);
// };
//
// globalThis.hideMainMenu = () => {
//     menuRevealer.revealChild = false;
// };
//
// globalThis.ToggleNotificationCenter = () => {
//     openMenu(settings.menuTabs.notifications);
// };
//
// globalThis.toggleWeather = () => {
//     openMenu(settings.menuTabs.weather);
// };
//
// globalThis.toggleMonitors = () => {
//     openMenu(settings.menuTabs.monitor);
// };
//
// globalThis.toggleNetwork = () => {
//     openMenu(settings.menuTabs.network);
// };
