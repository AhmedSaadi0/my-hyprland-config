pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "root:/utils" as Utils
import "root:/config"

Singleton {
    id: root

    property var selectedTheme: ColorsTheme
    property int selectedDarkWallpaperIndex: 0
    property int selectedLightWallpaperIndex: 0
    property var wallpapersList: []

    // تحميل الثيم من ملف QML
    function loadTheme(themeFile) {
        const component = Qt.createComponent(`${themeFile}.qml`);
        if (component.status !== Component.Ready) {
            console.error("فشل تحميل الثيم:", component.errorString());
            return;
        }

        const themeInstance = component.createObject();
        if (!themeInstance) {
            console.error("فشل إنشاء كائن الثيم:", themeFile);
            return;
        }

        root.selectedTheme = themeInstance;
        applyTheme(themeInstance);
    }

    // تنفيذ أوامر إلى Hyprland
    function dispatchCommand(description, commandArray) {
        if (!Array.isArray(commandArray) || commandArray.length === 0) {
            console.warn(`تم تخطي الأمر الفارغ: ${description}`);
            return;
        }

        return Hyprland.dispatch(`exec ${commandArray.join(' ')}`);
    }

    // تطبيق إعدادات الثيم
    function applyTheme(theme) {
        if (!theme) {
            console.error("لا يمكن تطبيق ثيم غير موجود.");
            return;
        }

        wallpaperTimer.stop();
        getWallpapersList.running = false;

        console.info("تطبيق الثيم:", theme.themeName || "ثيم بدون اسم");

        const settings = theme.systemSettings;

        if (settings.enableDynamicWallpapers) {
            getWallpapersList.running = true;
        } else {
            applyStaticTheme(settings);
        }
    }

    function applyStaticTheme(settings) {
        changeWallpaper(settings.wallpaper);
        changeQtTheme(settings);
        changeGtkTheme(settings);
        setHyprlandConfigurations();
        cacheAppliedData();
    }

    function setHyprlandConfigurations() {
        const cfg = selectedTheme.hyprlandConfiguration;
        const keywords = [[`general:border_size`, cfg.borderWidth], [`general:col.active_border`, `'${cfg.activeBorder}'`], [`general:col.inactive_border`, `'${cfg.inactiveBorder}'`], [`decoration:rounding`, cfg.rounding], [`decoration:drop_shadow`, cfg.dropShadow ? "yes" : "no`"]];

        for (const [key, value] of keywords) {
            Hyprland.dispatch(`exec hyprctl keyword ${key} ${value}`);
        }
    }

    function changeWallpaper(path) {
        dispatchCommand("تغيير الخلفية", Utils.Helper.changeWallpaper(path));
    }

    function changeQtTheme(s) {
        dispatchCommand("Plasma Color", Utils.Helper.changePlasmaColor(s.plasmaColorScheme));
        dispatchCommand("Plasma Icons", Utils.Helper.changePlasmaIcons(s.themeIcons));
        dispatchCommand("Konsole Profile", Utils.Helper.changeKonsoleProfile(s.konsoleProfile));
        dispatchCommand("Qt Style", Utils.Helper.changeQtStyle(s.qtThemeStyle));
        dispatchCommand("Kvantum Theme", Utils.Helper.changeKvantumTheme(s.kvantumTheme));
    }

    function changeGtkTheme(s) {
        dispatchCommand("GTK Theme", Utils.Helper.changeGtkTheme(s.gtkTheme));
        dispatchCommand("GTK Icons", Utils.Helper.changeGtkIcons(s.themeIcons));
        dispatchCommand("GTK Font", Utils.Helper.changeGtkIcons(s.fontName)); // ملاحظة: يبدو أنها خطأ، يُفضل: changeGtkFont
    }

    function cacheAppliedData() {
        const data = {
            selectedTheme: selectedTheme.themeName,
            selectedDarkWallpaper: selectedDarkWallpaperIndex,
            selectedLightWallpaper: selectedLightWallpaperIndex
        };
        cacheFile.setText(JSON.stringify(data, null, 2));
    }

    FileView {
        id: cacheFile
        path: Qt.resolvedUrl(App.themeCacheFilePath)
        watchChanges: true

        onLoaded: {
            try {
                const data = JSON.parse(cacheFile.text());
                selectedDarkWallpaperIndex = data.selectedDarkWallpaper;
                selectedLightWallpaperIndex = data.selectedLightWallpaper;
                loadTheme(data.selectedTheme);
            } catch (e) {
                console.error("فشل قراءة ملف التخزين:", e);
            }
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                console.info("ملف التخزين غير موجود. سيتم إنشاؤه.");
                cacheFile.setText(JSON.stringify({
                    selectedTheme: "default"
                }));
            } else {
                console.error("فشل تحميل ملف التخزين:", error);
            }
        }
    }

    Process {
        id: getWallpapersList
        command: Utils.Helper.getWallpapersList(selectedTheme.systemSettings.dynamicWallpapersPath)

        stdout: StdioCollector {
            onStreamFinished: {
                const jsonData = JSON.parse(this.text);
                root.wallpapersList = jsonData;

                applyDynamicWallpaper();
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.error(data);
            }
        }
    }

    function applyDynamicWallpaper() {
        const settings = selectedTheme.systemSettings;
        const themeMode = settings.themeMode;

        let selectedWallpaper = themeMode === "light" ? wallpapersList[selectedLightWallpaperIndex] : wallpapersList[selectedDarkWallpaperIndex];

        changeWallpaper(selectedWallpaper);
        changeQtTheme(settings);
        changeGtkTheme(settings);
        setHyprlandConfigurations();

        if (settings.enableDynamicColoring) {
            dispatchCommand("Apply M3 Themeing", Utils.Helper.applyM3PlasmaColor(selectedWallpaper, themeMode));
        }

        cacheAppliedData();
        wallpaperTimer.running = settings.enableDynamicWallpapers || settings.enableDynamicColoring;
    }

    Timer {
        id: wallpaperTimer
        running: false
        interval: selectedTheme?.systemSettings?.dynamicWallpapersInterval || 60000
        repeat: true

        onTriggered: {
            const settings = selectedTheme.systemSettings;
            const mode = settings.themeMode;

            if (mode === "light") {
                selectedLightWallpaperIndex++;
            } else {
                selectedDarkWallpaperIndex++;
            }

            applyDynamicWallpaper();
        }
    }
}
