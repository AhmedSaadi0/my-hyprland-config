import { Box, Button, Label, Revealer, Stack, Window } from 'astal/gtk3/widget';
import settings from '../utils/settings';
import strings from '../utils/strings';
import { TitleTextRevealer } from '../widgets/TitleText';
import { Astal, Gtk } from 'astal/gtk3';
import Header from './profile/Header';
import Profile from './profile/Profile';

const sharedTabAttrs = {
    spacing: 7,
    vertical: false,
    buttonClass: 'toolbar-button',
    titleXalign: 0.7,
    textXalign: 0.3,
    titleClass: 'toolbar-button-icon',
    textClass: 'toolbar-button-text',
    onHover: (btn: Button) => {},
    onHoverLost: (btn: Button) => {},
};

const dashboardTabIcon = (
    <TitleTextRevealer
        {...sharedTabAttrs}
        title="󰨝"
        text={strings.controlTab}
        buttonClass="toolbar-button-selected small-shadow"
        onClicked={() => switchToTab(settings.menuTabs.dashboard)}
    />
);

const notificationTabIcon = (
    <TitleTextRevealer
        {...sharedTabAttrs}
        title="󰂞"
        text={strings.notificationsTab}
        onClicked={() => switchToTab(settings.menuTabs.notifications)}
    />
);

const weatherTabIcon = (
    <TitleTextRevealer
        {...sharedTabAttrs}
        title="󰖐"
        text={strings.weatherTab}
        onClicked={() => switchToTab(settings.menuTabs.weather)}
    />
);

const hardwareTabIcon = (
    <TitleTextRevealer
        {...sharedTabAttrs}
        title=""
        text={strings.monitorsTab}
        onClicked={() => switchToTab(settings.menuTabs.monitor)}
    />
);

const networkTabIcon = (
    <TitleTextRevealer
        {...sharedTabAttrs}
        title=""
        text={strings.networkTab}
        onClicked={() => switchToTab(settings.menuTabs.network)}
    />
);

const toolbarIconsBox = (
    <Box className="toolbar-icons-box">
        {dashboardTabIcon}
        {notificationTabIcon}
        {weatherTabIcon}
        {hardwareTabIcon}
        {networkTabIcon}
    </Box>
);

const stack = (
    <Stack
        transition_type={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
        transition_duration={300}
        shown={settings.menuTabs.dashboard}
    >
        <Label label="dashboard" name={settings.menuTabs.dashboard} />
        <Label label="notifications" name={settings.menuTabs.notifications} />
        <Label label="weather" name={settings.menuTabs.weather} />
        <Label label="monitor" name={settings.menuTabs.monitor} />
        <Label label="network" name={settings.menuTabs.network} />
    </Stack>
);

const widgets = (
    <Box css="min-width:24.5rem;" vertical>
        <Header />
        <Profile />
        {toolbarIconsBox}
        {stack}
    </Box>
);

const menuRevealer = (
    <Revealer
        transition={settings.theme.menuTransitions.mainMenu}
        transitionDuration={settings.theme.menuTransitions.mainMenuDuration}
        revealChild
    >
        {widgets}
    </Revealer>
);

export function MainMenu({ monitor }: { monitor?: any } = {}) {
    const { TOP, LEFT } = Astal.WindowAnchor;

    return (
        <Window
            name={`left_menu_${monitor}`}
            className="main-menu"
            keymode="on-demand"
            anchor={[TOP | LEFT]}
        >
            <Box css="min-height: 1px;">{menuRevealer}</Box>
        </Window>
    );
}

export const MenuButton = (
    <Button
        className="menu-button unset"
        label=""
        onClicked={() => openMenu(settings.menuTabs.dashboard)}
    />
);

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
}

function openMenu(menuTab: String) {
    if (menuRevealer.revealChild && stack.shown.toString() === menuTab) {
        menuRevealer.revealChild = false;
        return;
    }

    if (!menuRevealer.revealChild) {
        menuRevealer.revealChild = true;
    }

    switchToTab(menuTab);
}
