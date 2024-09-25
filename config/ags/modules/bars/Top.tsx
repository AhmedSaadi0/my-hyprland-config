import { Astal, App, Variable } from 'astal';
import Workspaces from './widgets/Workspaces';

const time = Variable<string>('').poll(1000, ['date', '+(%I:%M:%S) %A, %d %B']);

export default function TopBar(monitor: number) {
    return (
        <window
            className="top-bar"
            monitor={monitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            application={App}
            anchor={
                Astal.WindowAnchor.TOP |
                Astal.WindowAnchor.LEFT |
                Astal.WindowAnchor.RIGHT
            }
        >
            <centerbox>
                <box>{Workspaces()}</box>
                <label label={time()} />
                <button>Right widget</button>
            </centerbox>
        </window>
    );
}
