import { bind } from 'astal';
import Hyprland from 'gi://AstalHyprland';

const hyprland = Hyprland.get_default();

const arr = Array.from({ length: 10 }, (_, id) => id + 1);
const inActiveIcons = ['', '󰿤', '󰂕', '󰉖', '󱙌', '󰆉', '󱍚', '󰺶', '󱋢', '󰤑'];
const activeIcons = ['󰋜', '󰿣', '󰂔', '󰉋', '󱙋', '󰆈', '󱍙', '󰺵', '󱋡', '󰙨'];

function workspaceIcon(workspace: Hyprland.Workspace) {
    const focusedWorkspace = bind(hyprland, 'focusedWorkspace');
    const clients = bind(workspace, 'clients');

    const hasWindows = clients.as((val) => {
        const newVal = val.length > 0 ? 'has-windows' : 'empty';
        return newVal;
    });

    const className = focusedWorkspace.as((val) => {
        let newVal = val === workspace ? 'unset focused ' : 'unset unfocused ';
        newVal += hasWindows.get();
        return newVal;
    });

    const workspaceIcon = focusedWorkspace.as((val) => {
        const newVal =
            val === workspace
                ? activeIcons[workspace.id - 1] || ''
                : inActiveIcons[workspace.id - 1] || '';
        return newVal;
    });

    return (
        <button onClick={() => workspace.focus()} className={className}>
            {workspaceIcon}
        </button>
    );
}

export default function Workspaces() {
    const workspaces = bind(hyprland, 'workspaces').as((wss) =>
        arr.map(
            (id) =>
                wss.find((ws: Hyprland.Workspace) => ws.id === id) ||
                Hyprland.Workspace.dummy(id, null)
        )
    );

    return (
        <box className="workspaces">
            {workspaces.as((wss) =>
                wss.map((workspace) => workspaceIcon(workspace))
            )}
        </box>
    );
}
