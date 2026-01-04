// config/CommandsRegistry.qml
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // All available launcher commands
    readonly property var commands: [
        {
            name: "Change Wallpaper",
            keywords: "wallpaper background",
            description: "Browse and set wallpapers",
            icon: "󰸉",
            view: "wallpaper",
            isAction: false
        },
        {
            name: "Open Settings",
            keywords: "settings preferences config",
            description: "Configure nibras-shell options",
            icon: "",
            view: "",
            isAction: true,
            action: "openSettings"
        }
    ]

    // Filter commands by search text
    function filterCommands(searchText) {
        if (!searchText || searchText === "")
            return commands;
        const lower = searchText.toLowerCase();
        return commands.filter(cmd => cmd.name.toLowerCase().includes(lower) || cmd.keywords.toLowerCase().includes(lower));
    }

    // Check if text starts with command prefix
    function isCommandMode(text) {
        return text && text.length > 0 && text.charAt(0) === ">";
    }

    // Extract command text (without the > prefix)
    function getCommandText(text) {
        if (!isCommandMode(text) || text.length <= 1)
            return "";
        return text.substring(1).trim().toLowerCase();
    }
}
