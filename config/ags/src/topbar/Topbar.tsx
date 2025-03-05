import { App, Astal, Gdk } from 'astal/gtk3';
import { Variable } from 'astal';
import Workspaces from './widgets/Workspaces';
import HardwareBox from './widgets/hardware/All';

const time = Variable('').poll(1000, ['date', '+(%I:%M) %A, %d %B']);

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

    return (
        <window
            className="top-bar"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={TOP | LEFT | RIGHT}
            application={App}
        >
            <centerbox>
                <box>
                    {Workspaces()}
                    {HardwareBox()}
                </box>
                <label label={time()} className="unset clock" />
                <button>Right widget</button>
            </centerbox>
        </window>
    );
}
