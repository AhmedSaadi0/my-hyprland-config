const { Hyprland } = ags.Service;
const { Box, Label, Button } = ags.Widget;
const { execAsync } = ags.Utils;

export const Workspaces = () => Box({
    className: 'unset workspaces',
    connections: [[Hyprland, box => {
        // generate an array [1..10] then make buttons from the index
        const arr = Array.from({ length: 10 }, (_, i) => i + 1);
        const inActiveIcons = [
            "",
            "󰿤",
            "󰂕",
            "",
            "󱙌",
            "󰆉",
            "",
            "󰺶",
            "󱋢",
            ""
        ];
        const activeIcons = [
            "",
            "󰿣",
            "󰂔",
            "",
            "󱙋",
            "󰆈",
            "",
            "󰺵",
            "󱋡",
            ""
        ];

        box.children = arr.map(i => Button({
            onClicked: () => execAsync(`hyprctl dispatch workspace ${i}`),
            child: Label({
                label: Hyprland.active.workspace.id == i ? activeIcons[i - 1] : inActiveIcons[i - 1]
            }),
            className: Hyprland.active.workspace.id == i ? 'focused unset' :
                Hyprland.workspaces[i]?.windows > 0 ? 'unfocused unset has-windows' : "unfocused unset"
        }));
    }]],
});

