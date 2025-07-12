pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Hyprland

import "root:/utils" as Utils
import "root:/config"

Singleton {
    id: root

    property var selectedTheme: ColorsTheme

    function loadTheme(themeFile) {
        const component = Qt.createComponent(`${themeFile}.qml`);
        if (component.status === Component.Ready) {
            const themeInstance = component.createObject();
            if (themeInstance) {
                root.selectedTheme = themeInstance;
                applyTheme(themeInstance);
            } else {
                console.error("فشل إنشاء كائن الثيم:", themeFile);
            }
        } else {
            console.error("فشل تحميل الثيم:", component.errorString());
        }
    }

    function dispatchCommand(description, commandArray) {
        if (!commandArray || commandArray.length === 0) {
            console.warn(`تم تخطي الأمر الفارغ: ${description}`);
            return;
        }

        const commandString = commandArray.join(' ');

        // console.info(`[${description}] Dispatching: exec ${commandString}`);

        Hyprland.dispatch(`exec ${commandString}`);
    }

    function applyTheme(themeObject) {
        if (!themeObject) {
            console.error("Cannot apply a null theme object.");
            return;
        }

        console.log("Applying theme:", themeObject.themeName || "Unnamed Theme");

        const settings = themeObject.systemSettings;

        dispatchCommand("Change Wallpaper", Utils.Helper.changeWallpaper(settings.wallpaper));
        dispatchCommand("Change Plasma Color", Utils.Helper.changePlasmaColor(settings.plasmaColorScheme));
        dispatchCommand("Change Plasma Icons", Utils.Helper.changePlasmaIcons(settings.themeIcons));
        dispatchCommand("Change Konsole Profile", Utils.Helper.changeKonsoleProfile(settings.konsoleProfile));
        dispatchCommand("Change GTK Theme", Utils.Helper.changeGtkTheme(settings.gtkTheme));
        dispatchCommand("Change GTK Icons", Utils.Helper.changeGtkIcons(settings.themeIcons));
        dispatchCommand("Change GTK Font", Utils.Helper.changeGtkIcons(settings.fontName));
        dispatchCommand("Change Qt Style", Utils.Helper.changeQtStyle(settings.qtThemeStyle));
        dispatchCommand("Change Kvantum Theme", Utils.Helper.changeKvantumTheme(settings.kvantumTheme));

        setHyprlandConfigurations();
        const newData = {
            selectedTheme: this.selectedTheme.themeName
        };
        cacheFile.setText(JSON.stringify(newData, null, 2));
    }

    function setHyprlandConfigurations() {
        const cfg = selectedTheme.hyprlandConfiguration;
        Hyprland.dispatch(`exec hyprctl keyword general:border_size ${cfg.borderWidth}`);
        Hyprland.dispatch(`exec hyprctl keyword general:col.active_border '${cfg.activeBorder}'`);
        Hyprland.dispatch(`exec hyprctl keyword general:col.inactive_border '${cfg.inactiveBorder}'`);
        Hyprland.dispatch(`exec hyprctl keyword decoration:rounding ${cfg.rounding}`);
        Hyprland.dispatch(`exec hyprctl keyword decoration:drop_shadow ${cfg.dropShadow ? "yes" : "no"}`);
    }

    FileView {
        id: cacheFile
        path: Qt.resolvedUrl(App.themeCacheFilePath)
        watchChanges: true
        onLoaded: {
            const fileContents = JSON.parse(cacheFile.text());
            loadTheme(fileContents.selectedTheme);
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                console.info("Cache File not found, creating new file.");
                cacheFile.setText(JSON.stringify("{selectedTheme:0}"));
            } else {
                console.error("Cache file could not be load: " + error);
            }
        }
    }
}
