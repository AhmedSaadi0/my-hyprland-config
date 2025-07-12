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
        return ['swww', 'img', '--transition-type', 'random', `'${wallpaperPath}'`];
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

    function getWallpapersList(path) {
        const scriptFile = Config.App.scripts.bash.getWallpapers;
        return [scriptFile, `${path}`];
    }

    function applyM3PlasmaColor(selectedWallpaperPath, themeMode) {
        const scriptCommand = Config.App.scripts.python.dynamicM3Command;
        const command = [...scriptCommand, `'${selectedWallpaperPath}'`, "-m", themeMode];
        return command;
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

    /**
     * @function changeGtkIcons
     * @description Generates a command to apply a GTK icon theme.
     * @param {string} iconThemeName - The name of the icon theme.
     * @returns {string[]} The command array.
     */
    function changeGtkIcons(iconThemeName) {
        return ['gsettings', 'set', 'org.gnome.desktop.interface', 'icon-theme', iconThemeName];
    }

    function changeGtkFont(fontName) {
        // This command sets the theme for both GTK3 and GTK4 in most modern environments.
        return ['gsettings', 'set', 'org.gnome.desktop.interface', 'font-name', fontName];
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
}
