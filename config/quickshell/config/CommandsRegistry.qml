// config/CommandsRegistry.qml
pragma Singleton

import QtQuick
import Quickshell

import "root:/themes"

Singleton {
    id: root

    readonly property bool isDynamicTheme: ThemeManager.selectedTheme && ThemeManager.selectedTheme.systemSettings && ThemeManager.selectedTheme.systemSettings.enableDynamicWallpapers

    // All available launcher commands
    readonly property var commands: [
        {
            name: "Change Wallpaper",
            keywords: "wallpaper background",
            description: "Browse and set wallpapers",
            icon: "󰸉",
            view: "wallpaper",
            isAction: false,
            enabled: true
        },
        {
            name: "Open Settings",
            keywords: "settings preferences config",
            description: "Configure nibras-shell options",
            icon: "",
            view: "",
            isAction: true,
            action: "openSettings",
            enabled: true
        },
        {
            name: "Next Wallpaper",
            keywords: "wallpaper background next dynamic",
            description: "Switch to next dynamic wallpaper",
            icon: "󰒭",
            view: "",
            isAction: true,
            action: "nextWallpaper",
            requiresDynamic: true
        },
        {
            name: "Previous Wallpaper",
            keywords: "wallpaper background previous dynamic",
            description: "Switch to previous dynamic wallpaper",
            icon: "󰒮",
            view: "",
            isAction: true,
            action: "previousWallpaper",
            requiresDynamic: true
        }
    ]

    // Filter commands by search text
    function filterCommands(searchText) {
        const dynamicAllowed = root.isDynamicTheme;
        const allowedCommands = commands.map(cmd => {
            const isEnabled = !cmd.requiresDynamic || dynamicAllowed;
            return Object.assign({}, cmd, {
                enabled: isEnabled
            });
        });
        if (!searchText || searchText === "")
            return allowedCommands;
        const lower = searchText.toLowerCase();
        return allowedCommands.filter(cmd => cmd.name.toLowerCase().includes(lower) || cmd.keywords.toLowerCase().includes(lower));
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
