import settings from '../../settings.js';
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
                label: 'هل تريد ايقاف التشغيل',
            }),
            Widget.Box({
                homogeneous: true,
                children: [
                    Widget.Button({
                        className: 'power-action-revealer-yes-btn',
                        label: 'نعم',
                        onClicked: () => {
                            Utils.execAsync(action).catch(print);
                        },
                    }),
                    Widget.Button({
                        className: 'power-action-revealer-no-btn',
                        label: 'لا',
                        onClicked: (self, value) => {
                            actionRevealer.reveal_child = false;
                        },
                    }),
                ],
            }),
        ],
    }),
});

const PowerButtonsRow = () => {
    const powerBtnMargin =
        local === 'RTL' ? 'margin-left: 1rem;' : 'margin-right: 1rem;';

    const powerOff = Widget.Button({
        className: 'theme-btn',
        css: `min-width: 5rem; min-height: 2rem;border-radius: 1rem;${powerBtnMargin}`,
        child: Widget.Label({
            label: '',
        }),
        onClicked: () => {
            if (
                !actionRevealer.reveal_child ||
                action === 'systemctl poweroff'
            ) {
                actionRevealer.reveal_child = !actionRevealer.reveal_child;
            }
            action = 'systemctl poweroff';
            actionRevealer.child.children[0].label = 'هل تريد ايقاف التشغيل';
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
                actionRevealer.reveal_child = !actionRevealer.reveal_child;
            }
            // actionRevealer.reveal_child = !actionRevealer.reveal_child;
            action = 'systemctl reboot';
            actionRevealer.child.children[0].label = 'هل تريد اعادة التشغيل';
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
                actionRevealer.reveal_child = !actionRevealer.reveal_child;
            }
            // actionRevealer.reveal_child = !actionRevealer.reveal_child;
            action = 'loginctl kill-session self';
            actionRevealer.child.children[0].label = 'هل تريد تسجيل الخروج';
        },
    });

    const row1 = Widget.Box({
        children: [powerOff, reboot, logout],
    });

    return Widget.Box({
        className: 'power-box unset',
        css: `margin-top:0rem;`,
        vertical: true,
        children: [row1, actionRevealer],
    });
};

export default PowerButtonsRow;
