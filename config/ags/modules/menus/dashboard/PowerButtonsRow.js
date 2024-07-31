import settings from '../../settings.js';
import { local } from '../../utils/helpers.js';

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
            Utils.execAsync([
                `paplay`,
                settings.assets.audio.desktop_logout,
            ]).catch(print);
            execAsync('systemctl poweroff').catch(print);
        },
    });

    const reboot = Widget.Button({
        className: 'theme-btn',
        css: `min-width: 5rem;	min-height: 2rem;border-radius: 1rem;${powerBtnMargin}`,
        child: Widget.Label({
            label: '',
        }),
        onClicked: () => {
            Utils.execAsync([
                `paplay`,
                settings.assets.audio.desktop_logout,
            ]).catch(print);
            execAsync('systemctl reboot').catch(print);
        },
    });

    const logout = Widget.Button({
        className: 'theme-btn',
        css: `min-width: 5rem;min-height: 2rem;border-radius: 1rem;`,
        child: Widget.Label({
            label: '',
        }),
        onClicked: () => {
            Utils.execAsync([
                `paplay`,
                settings.assets.audio.desktop_logout,
            ]).catch(print);
            execAsync('loginctl kill-session self').catch(print);
        },
    });

    const row1 = Widget.Box({
        children: [powerOff, reboot, logout],
    });

    return Widget.Box({
        className: 'power-box unset',
        css: `margin-top:0rem;`,
        vertical: true,
        children: [row1],
    });
};

export default PowerButtonsRow;
