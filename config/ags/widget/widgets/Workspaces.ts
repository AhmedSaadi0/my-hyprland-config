import { hook, Widget } from 'astal/gtk3';
import Hyprland from 'gi://AstalHyprland';
import { bind, execAsync } from 'astal';

const hyprland = Hyprland.get_default();

export const Workspaces = (): Widget.Box => {
    const arr: number[] = Array.from({ length: 10 }, (_, i) => i + 1);
    const inActiveIcons: string[] = [
        '',
        '󰿤',
        '󰂕',
        '󰉖',
        '󱙌',
        '󰆉',
        '󱍚',
        '󰺶',
        '󱋢',
        '󰤑',
    ];
    const activeIcons: string[] = [
        '󰋜',
        '󰿣',
        '󰂔',
        '󰉋',
        '󱙋',
        '󰆈',
        '󱍙',
        '󰺵',
        '󱋡',
        '󰙨',
    ];
    const box = new Widget.Box({
        className: 'unset workspaces small-shadow',
    });
    const workspaces = bind(hyprland, 'workspaces').as((wss) =>
        arr.map(
            (id) =>
                wss.find((ws: Hyprland.Workspace) => ws.id === id) ||
                Hyprland.Workspace.dummy(id, null)
        )
    );

    workspaces.as((wss) => {
        console.log(wss);
        wss.map((workspace) => console.log(workspace));
    });

    // box.children = arr.map((i) => {
    //     const isActive = hyprland.active.workspace.id === i;
    //     const hasWindows =
    //         hyprland.workspaces.find(
    //             (item: { id: number; windows: number }) => item.id === i
    //         )?.windows > 0;
    //
    //     return new Widget.Button({
    //         onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`),
    //         child: new Widget.Label({
    //             label: isActive ? activeIcons[i - 1] : inActiveIcons[i - 1],
    //         }),
    //         className: isActive
    //             ? 'unset focused'
    //             : hasWindows
    //               ? 'unset unfocused has-windows'
    //               : 'unset unfocused',
    //     });
    // });

    return box;
};
