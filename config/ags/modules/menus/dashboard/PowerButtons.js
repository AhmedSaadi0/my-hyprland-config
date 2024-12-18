import settings from '../../settings.js';
import strings from '../../strings.js';
import { local } from '../../utils/helpers.js';
import { Widget } from '../../utils/imports.js';

var action = 'systemctl poweroff';

const actionRevealer = Widget.Revealer({
    revealChild: false,
    className: 'power-action-revealer',
    transitionDuration: 500,
    transition: 'slide_down',
    child: Widget.Box({
        vertical: true,
        spacing: 20,
        children: [
            Widget.Label({
                label: strings.doYouWantToPoweroff,
            }),
            Widget.Box({
                homogeneous: true,
                children: [
                    Widget.Button({
                        className: 'power-action-revealer-yes-btn',
                        label: strings.yes,
                        onClicked: () => {
                            Utils.execAsync(action).catch(print);
                        },
                    }),
                    Widget.Button({
                        className: 'power-action-revealer-no-btn',
                        label: strings.no,
                        onClicked: (self, value) => {
                            revealPowerButtons(false);
                            revealAllThemes(false);
                        },
                    }),
                ],
            }),
        ],
    }),
});

globalThis.revealPowerButtons = (reveal_child = true) => {
    actionRevealer.reveal_child = reveal_child;
};

const powerBtnMargin =
    local === 'RTL' ? 'margin-left: 1rem;' : 'margin-right: 1rem;';

const powerOff = Widget.Button({
    className: 'theme-btn',
    css: `min-width: 5rem; min-height: 2rem;border-radius: 1rem;${powerBtnMargin}`,
    child: Widget.Label({
        label: '',
    }),
    onClicked: () => {
        if (!actionRevealer.reveal_child || action === 'systemctl poweroff') {
            revealPowerButtons(!actionRevealer.reveal_child);
            revealMediaControls(false);
            revealAllThemes(false);
        }
        action = 'systemctl poweroff';
        actionRevealer.child.children[0].label = strings.doYouWantToPoweroff;
    },
});

const reboot = Widget.Button({
    className: 'theme-btn',
    css: `min-width: 5rem;	min-height: 2rem;border-radius: 1rem;${powerBtnMargin}`,
    child: Widget.Label({
        label: '',
    }),
    onClicked: () => {
        if (!actionRevealer.reveal_child || action === 'systemctl reboot') {
            revealPowerButtons(!actionRevealer.reveal_child);
            revealMediaControls(false);
            revealAllThemes(false);
        }
        // actionRevealer.reveal_child = !actionRevealer.reveal_child;
        action = 'systemctl reboot';
        actionRevealer.child.children[0].label = strings.doYouWantToRestart;
    },
});

const logout = Widget.Button({
    className: 'theme-btn',
    css: `min-width: 5rem;min-height: 2rem;border-radius: 1rem;`,
    child: Widget.Label({
        label: '',
    }),
    onClicked: () => {
        if (
            !actionRevealer.reveal_child ||
            action === 'loginctl kill-session self'
        ) {
            revealPowerButtons(!actionRevealer.reveal_child);
            revealMediaControls(false);
            revealAllThemes(false);
        }
        // actionRevealer.reveal_child = !actionRevealer.reveal_child;
        action = 'loginctl kill-session self';
        actionRevealer.child.children[0].label = strings.doYouWantToLogout;
    },
});

const row1 = Widget.Box({
    children: [powerOff, reboot, logout],
});

const PowerButtonsRow = Widget.Box({
    className: 'power-box unset',
    // css: `margin-top:0rem;`,
    vertical: true,
    children: [row1, actionRevealer],
});

export default PowerButtonsRow;
