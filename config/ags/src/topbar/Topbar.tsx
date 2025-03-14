import { App, Astal, Gdk, Gtk } from 'astal/gtk3';
import { bind, Variable } from 'astal';
import Workspaces from './widgets/Workspaces';
import HardwareBox from './widgets/Hardware';
import { MenuButton } from '../menus/LeftMenu';
import { networkSpeed } from '../utils/system-usage';
import InternetWidget from './widgets/Internet';

const time = Variable('').poll(1000, ['date', '+(%I:%M) %A, %d %B']);

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

    return (
        <window
            className="unset"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={TOP | LEFT | RIGHT}
            application={App}
        >
            <centerbox className="top-bar">
                <box>
                    {Workspaces()}
                    {HardwareBox()}
                </box>
                <label label={time()} className="unset clock" />
                <box halign={Gtk.Align.END}>
                    {InternetWidget()}
                    {MenuButton}
                </box>
            </centerbox>
        </window>
    );
}
