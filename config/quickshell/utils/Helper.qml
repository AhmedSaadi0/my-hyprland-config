// helpers/Helper.qml
pragma Singleton

import QtQuick
import Quickshell

import "root:/config" as Config

Singleton {
    id: root

    // ==========================================================
    // ==                 WALLPAPER COMMANDS                   ==
    // ==========================================================

    /**
     * @function changeWallpaper
     * @description Generates a command to change the desktop wallpaper using 'swww'.
     * @param {string} wallpaperName - The filename of the wallpaper (e.g., "my-wallpaper.jpg").
     * @returns {string[]} The command array to be executed.
     */
    function changeWallpaper(wallpaperPath) {
        return ['swww', 'img', '--transition-type', 'grow', `'${wallpaperPath}'`];
    }

    function getCursorpos(wallpaperPath) {
        return ["hyprctl", "cursorpos"];
    }

    // ==========================================================
    // ==                  PLASMA COMMANDS                     ==
    // ==========================================================

    /**
     * @function changePlasmaColor
     * @description Generates a command to apply a Plasma color scheme.
     * @param {string} colorSchemeName - The name of the color scheme (e.g., "BreezeDark").
     * @returns {string[]} The command array.
     */
    function changePlasmaColor(colorSchemeName) {
        // This requires the 'plasma-apply-colorscheme' tool to be installed.
        return ['plasma-apply-colorscheme', colorSchemeName];
    }

    function changePlasmaAccentColor(accentColor) {
        // This requires the 'plasma-apply-colorscheme' tool to be installed.
        return ['plasma-apply-colorscheme', '-a', `"${accentColor}"`];
    }

    function getWallpapersList(path) {
        const scriptFile = Config.App.scripts.bash.getWallpapers;
        return [scriptFile, `${path}`];
    }

    function applyM3PlasmaColor({
        selectedWallpaperPath,
        themeMode,
        scheme,
        chroma,
        tone
    }) {
        const scriptCommand = Config.App.scripts.python.dynamicM3Command;
        const command = [...scriptCommand, `'${selectedWallpaperPath}'`, "-m", themeMode, "--scheme", scheme, "--chroma", chroma, "--tone", tone];
        console.info(command);
        return command;
    }

    function changePlasmaFont({
        font,
        key,
        group = "General"
    }) {
        return ['kwriteconfig6', '--file', 'kdeglobals', '--group', group, '--key', key, font];
    }

    /**
     * @function changePlasmaIcons
     * @description Generates a command to apply an icon theme.
     * @param {string} iconThemeName - The name of the icon theme (e.g., "breeze-dark").
     * @returns {string[]} The command array.
     */
    function changePlasmaIcons(iconThemeName) {
        // Uses 'kwriteconfig5' to directly modify the system settings.
        return ['kwriteconfig5', '--file', 'kdeglobals', '--group', 'Icons', '--key', 'Theme', iconThemeName];
    }

    /**
     * @function changeKonsoleProfile
     * @description Generates a command to set the default Konsole profile.
     * @param {string} profileName - The name of the Konsole profile file (e.g., "MyProfile.profile").
     * @returns {string[]} The command array.
     */
    function changeKonsoleProfile(profileName) {
        return ['kwriteconfig5', '--file', 'konsolerc', '--group', "'Desktop Entry'", '--key', 'DefaultProfile', profileName];
    }

    // ==========================================================
    // ==                    GTK COMMANDS                      ==
    // ==========================================================

    /**
     * @function changeGtkTheme
     * @description Generates a command to apply a GTK3/4 theme.
     * @param {string} themeName - The name of the GTK theme (e.g., "Breeze").
     * @returns {string[]} The command array.
     */
    function changeGtkTheme(themeName) {
        // This command sets the theme for both GTK3 and GTK4 in most modern environments.
        return ['gsettings', 'set', 'org.gnome.desktop.interface', 'gtk-theme', themeName];
    }

    function changeGtkColorSchemeTheme(themeName) {
        // This command sets the theme for both GTK3 and GTK4 in most modern environments.
        return ['gsettings', 'set', 'org.gnome.desktop.interface', 'color-scheme', `prefer-${themeName}`];
    }

    function removeOldGtk4Theme() {
        return ['find', '-P', '~/.config/gtk-4.0/', '-mindepth', '1', '!', '-name', '"settings.ini"', '-delete'];
    }

    function changeGtk4Theme(themeName) {
        // This command sets the theme for both GTK3 and GTK4 in most modern environments.
        return ['cp', '-rf', `~/.themes/${themeName}/gtk-4.0/*`, '~/.config/gtk-4.0/'];
    }

    /**
     * @function changeGtkIcons
     * @description Generates a command to apply a GTK icon theme.
     * @param {string} iconThemeName - The name of the icon theme.
     * @returns {string[]} The command array.
     */
    function changeGtkIcons(iconThemeName) {
        return ['gsettings', 'set', 'org.gnome.desktop.interface', 'icon-theme', iconThemeName];
    }

    function changeGtkFont(fontName, fontSize) {
        // This command sets the theme for both GTK3 and GTK4 in most modern environments.
        return ['gsettings', 'set', 'org.gnome.desktop.interface', 'font-name', `'${fontName} ${fontSize}'`];
    }
    // ==========================================================
    // ==               APPLICATION STYLING                    ==
    // ==========================================================

    /**
     * @function changeQtStyle
     * @description Generates a command to set the Qt widget style (e.g., Fusion, Breeze).
     * @param {string} styleName - The name of the Qt style.
     * @returns {string[]} The command array.
     */
    function changeQtStyle(styleName) {
        // For KDE Plasma, using kwriteconfig5 is a direct and reliable method.
        return ['kwriteconfig5', '--file', 'kdeglobals', '--group', 'KDE', '--key', 'widgetStyle', styleName];
    }

    /**
     * @function changeKvantumTheme
     * @description Generates a command to apply a Kvantum theme.
     * @param {string} themeName - The name of the Kvantum theme.
     * @returns {string[]} The command array.
     */
    function changeKvantumTheme(themeName) {
        // Requires the 'kvantummanager' tool to be installed.
        return ['kvantummanager', '--set', themeName];
    }

    // ==========================================================
    // ==               NOTIFICATION COMMANDS                  ==
    // ==========================================================

    /**
     * @function sendNotification
     * @description Generates a fully-featured 'notify-send' command array with explicit arguments.
     * @param {string} summary - The notification title (required).
     * @param {string} body - The main notification message.
     * @param {string} icon - Icon name (e.g., "info") or full path to an image.
     * @param {string} urgency - Urgency level: "low", "normal", or "critical".
     * @returns {string[]} The command array for a Process element.
     */
    function sendNotification({
        summary,
        body = "",
        icon = "",
        urgency = "normal"
    }) {
        // Basic validation
        if (!summary) {
            console.error("sendNotification Error: 'summary' (title) is a required argument.");
            return [];
        }

        let command = ['notify-send'];

        // Add App name
        command.push('-a', `NibrasShell`);

        if (urgency) {
            command.push('-u', `'${urgency}'`);
        }
        if (icon) {
            command.push('-i', `'${icon}'`);
        }

        // Add the main content (must be last)
        command.push(`'${summary}'`); // Title
        if (body) {
            command.push(`'${body}'`); // Message body
        }

        return command;
    }

    function playSoundCommand(soundPath) {
        return ['paplay', `'${soundPath}'`];
    }

    function createImageOverlayRembg({
        wallpaperPath,
        outputPath,
        model = "u2net",
        alphaMatting = false,
        foregroundThreshold = 240,
        backgroundThreshold = 10,
        erodeSize = 10
    }) {
        if (!wallpaperPath || !outputPath) {
            console.error("createImageOverlayRembg: wallpaperPath and outputPath are required.");
            return [];
        }

        const scriptCommand = Config.App.scripts.python.rembgOverylayWallpaperCommand;

        let commandArray = [...scriptCommand, wallpaperPath, outputPath];

        if (model && model !== "u2net") {
            commandArray.push("--model", model);
        }

        if (alphaMatting) {
            commandArray.push("--alpha-matting");
            if (foregroundThreshold !== undefined) {
                commandArray.push("--foreground-threshold", foregroundThreshold.toString());
            }
            if (backgroundThreshold !== undefined) {
                commandArray.push("--background-threshold", backgroundThreshold.toString());
            }
            if (erodeSize !== undefined) {
                commandArray.push("--erode-size", erodeSize.toString());
            }
        }

        return commandArray;
    }

    // Not in use
    function createImageOverlayOpencv({
        wallpaperPath
    }) {
        const scriptCommand = Config.App.scripts.python.opencvOverylayWallpaperCommand;
        return [scriptCommand, `'${wallpaperPath}'`];
    }

    function generateRandomString(length = 7) {
        const characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        let result = "";
        const charactersLength = characters.length;

        for (let i = 0; i < length; i++) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }

        return result;
    }

    function removeUnusedCachedOverlayImages({
        jsonDir,
        imagesDir
    }) {
        const pythonCommand = Config.App.scripts.python.removeUnusedCachedOverlayImagesCommand;
        return [...pythonCommand, "--json_dir", jsonDir, "--images_dir", imagesDir];
    }

    function copyFile(sourcePath, destinationPath) {
        return ['cp', '-f', `'${sourcePath}'`, `'${destinationPath}'`];
    }

    function listWifiCommand(wifiInterface = Config.App.networkMonitor) {
        const pythonCommand = Config.App.scripts.python.listWifiCommand;
        const fullCommand = [...pythonCommand, "--interface", `${wifiInterface}`];
        return fullCommand;
    }

    function connectWifiCommand({
        ssid,
        command = "connect",
        password = null,
        wifiInterface = Config.App.networkMonitor
    }) {
        const pythonCommand = Config.App.scripts.python.connectWifiCommand;
        const fullCommand = [...pythonCommand, command, "--ssid", ssid, "--interface", wifiInterface];
        if (password) {
            fullCommand.push("--password", password);
        }
        return fullCommand;
    }

    function wifiDataUsageCommand({
        wifiInterface = Config.App.networkMonitor,
        startDate = null,
        endDate = null
    }) {
        const pythonCommand = Config.App.scripts.python.dataUsageCommand;
        let fullCommand = [...pythonCommand, "--interface", `${wifiInterface}`];
        if (startDate !== null) {
            fullCommand.push("--start-date", startDate);
        }
        if (endDate !== null) {
            fullCommand.push("--end-date", endDate);
        }
        return fullCommand;
    }
}
