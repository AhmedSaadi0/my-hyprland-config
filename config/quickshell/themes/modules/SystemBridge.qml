import QtQuick
import "root:/config"
import "root:/utils" as Utils

Item {
    id: root

    // دالة لتطبيق الثيم العام (GTK/Qt)
    function applySystemTheme(settings, colors, typography) {
        if (!settings)
            return;

        // Qt & Plasma
        _dispatch("Plasma Color", Utils.Helper.changePlasmaColor(settings.plasmaColorScheme));
        _dispatch("Plasma Icons", Utils.Helper.changePlasmaIcons(settings.themeIcons));
        _dispatch("Konsole Profile", Utils.Helper.changeKonsoleProfile(settings.konsoleProfile));
        _dispatch("Qt Style", Utils.Helper.changeQtStyle(settings.qtThemeStyle));
        _dispatch("Kvantum Theme", Utils.Helper.changeKvantumTheme(settings.kvantumTheme));

        const generalFont = `'${settings.fontName}',11,-1,5,50,0,0,0,0,0`;
        const titleFont = `'${settings.fontName}',11,-1,5,75,0,0,0,0,0`;
        const smallFont = `'${settings.fontName}',9,-1,5,75,0,0,0,0,0`;
        const toolBarFont = `'${settings.fontName}',10,-1,5,75,0,0,0,0,0`;
        const monoFont = "'FantasqueSansM Nerd Font Mono',10,-1,5,50,0,0,0,0,0";

        _dispatch("Plasma General Font", Utils.Helper.changePlasmaFont({
            font: generalFont,
            key: "font",
            group: "General"
        }));
        _dispatch("Plasma General Font", Utils.Helper.changePlasmaFont({
            font: generalFont,
            key: "menuFont",
            group: "General"
        }));
        _dispatch("Plasma General Font", Utils.Helper.changePlasmaFont({
            font: titleFont,
            key: "activeFont",
            group: "WM"
        }));
        _dispatch("Plasma General Font", Utils.Helper.changePlasmaFont({
            font: monoFont,
            key: "fixed",
            group: "General"
        }));
        _dispatch("Plasma General Font", Utils.Helper.changePlasmaFont({
            font: smallFont,
            key: "smallestReadableFont",
            group: "General"
        }));
        _dispatch("Plasma General Font", Utils.Helper.changePlasmaFont({
            font: toolBarFont,
            key: "toolBarFont",
            group: "General"
        }));
        // GTK
        _dispatch("GTK Theme", Utils.Helper.changeGtkTheme(settings.gtkTheme));
        _dispatch("GTK Icons", Utils.Helper.changeGtkIcons(settings.themeIcons));
        _dispatch("GTK Color Schema", Utils.Helper.changeGtkColorSchemeTheme(settings.themeMode));
        _dispatch("GTK 4 Clean", Utils.Helper.removeOldGtk4Theme());
        _dispatch("GTK 4 Apply", Utils.Helper.changeGtk4Theme(settings.gtkTheme));
        _dispatch("GTK Font", Utils.Helper.changeGtkFont(settings.fontName, typography.baseFontSize));

        // Accent Color
        if (!settings.enableDynamicColoring && settings.enableAccentColoring) {
            accentColorTimer.accentColor = colors.primary;
            accentColorTimer.start();
        }
    }

    // دالة منفصلة لتطبيق M3 (تستدعى عند تغير الخلفية)
    function applyM3(wallpaperPath, themeMode, enabled, scheme, chroma, tone) {
        if (!enabled)
            return;

        // حماية: لا نطبق M3 على مسارات غير صحيحة
        if (!wallpaperPath || wallpaperPath === "" || wallpaperPath.indexOf("/") === -1) {
            console.warn("[SystemBridge] Skipping M3, invalid wallpaper path:", wallpaperPath);
            return;
        }

        const data = {
            selectedWallpaperPath: wallpaperPath,
            themeMode: themeMode,
            scheme: scheme,
            chroma: chroma,
            tone: tone
        };

        console.info("[SystemBridge] Applying M3 on:", wallpaperPath);
        _dispatch("Apply M3", Utils.Helper.applyM3PlasmaColor(data));
    }

    function _dispatch(desc, cmd) {
        if (cmd)
            App.dispatchCommand(desc, cmd);
    }

    Timer {
        id: accentColorTimer
        property color accentColor
        interval: 1500
        repeat: false
        onTriggered: _dispatch("Plasma Accent Color", Utils.Helper.changePlasmaAccentColor(accentColor))
    }
}
