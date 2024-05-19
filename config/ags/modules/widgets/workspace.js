import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import { Box, Label, Button } from 'resource:///com/github/Aylur/ags/widget.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

export const Workspaces = () =>
    Box({
        className: 'unset workspaces small-shadow',
    }).hook(Hyprland, (box) => {
        // generate an array [1..10] then make buttons from the index
        const arr = Array.from({ length: 10 }, (_, i) => i + 1);
        const inActiveIcons = [
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
        const activeIcons = ['󰋜', '󰿣', '󰂔', '󰉋', '󱙋', '󰆈', '󱍙', '󰺵', '󱋡', '󰙨'];

        box.children = arr.map((i) =>
            Button({
                onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`),
                child: Label({
                    label:
                        Hyprland.active.workspace.id == i
                            ? activeIcons[i - 1]
                            : inActiveIcons[i - 1],
                }),
                className:
                    Hyprland.active.workspace.id == i
                        ? 'unset focused'
                        : Hyprland.workspaces.find((item) => item.id === i)
                                ?.windows > 0
                          ? 'unset unfocused has-windows'
                          : 'unset unfocused',
            })
        );
    });
