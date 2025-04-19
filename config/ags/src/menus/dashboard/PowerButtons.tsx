import { execAsync } from 'astal';
import strings from '../../utils/strings';
import { Gtk } from 'astal/gtk3';
import DashboardBox from '../../widgets/DashboardBox';

var action = 'systemctl poweroff';

const powerOff = (
    <button
        className="power-action-btn"
        onClick={() => {
            if (
                !actionRevealer.reveal_child ||
                action === 'systemctl poweroff'
            ) {
                revealPowerButtons(!actionRevealer.reveal_child);
            }
            action = 'systemctl poweroff';
            actionRevealer.get_child().children[0].label =
                strings.doYouWantToPoweroff;
        }}
    >
        <label className="theme-btn-icon">{''}</label>
    </button>
);

const reboot = (
    <button
        className="power-action-btn"
        onClick={() => {
            if (!actionRevealer.reveal_child || action === 'systemctl reboot') {
                revealPowerButtons(!actionRevealer.reveal_child);
            }
            action = 'systemctl reboot';
            actionRevealer.get_child().children[0].label =
                strings.doYouWantToRestart;
        }}
    >
        <label className="theme-btn-icon">{''}</label>
    </button>
);

const logout = (
    <button
        className="logout-btn"
        onClick={() => {
            if (
                !actionRevealer.reveal_child ||
                action === 'loginctl kill-session self'
            ) {
                revealPowerButtons(!actionRevealer.reveal_child);
            }
            action = 'loginctl kill-session self';
            actionRevealer.get_child().children[0].label =
                strings.doYouWantToLogout;
        }}
    >
        <label className="theme-btn-icon">{''}</label>
    </button>
);

const buttonsRow = (
    <box>
        {powerOff}
        {reboot}
        {logout}
    </box>
);

const actionRevealer = (
    <revealer
        reveal_child={false}
        className="power-action-revealer"
        transition_duration={500}
        transition_type={Gtk.RevealerTransitionType.SLIDE_DOWN}
    >
        <box vertical={true}>
            <label>{strings.doYouWantToPoweroff}</label>
            <box css="margin-top:1rem;">
                <button
                    className="power-action-revealer-yes-btn"
                    onClick={() => execAsync(action).catch(print)}
                >
                    {strings.yes}
                </button>
                <button
                    className="power-action-revealer-no-btn"
                    onClick={() => revealPowerButtons(false)}
                >
                    {strings.no}
                </button>
            </box>
        </box>
    </revealer>
);

globalThis.revealPowerButtons = (reveal_child = true) => {
    actionRevealer.reveal_child = reveal_child;
};

export default (
    <DashboardBox
        icon=""
        text={'Power options'}
        widget={
            <box vertical={true}>
                {buttonsRow}
                {actionRevealer}
            </box>
        }
    />
);
