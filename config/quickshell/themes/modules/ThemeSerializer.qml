import QtQuick
import Quickshell.Io
import "root:/config" // للوصول لـ App

Item {
    id: root

    // القوائم التي نود حفظها (منقولة من ThemeManager القديم)
    readonly property var _colorKeys: ["themeName", "_primary", "_secondary", "_onPrimary", "_onSecondary", "_tertiary", "_onTertiary", "_error", "_onError", "_success", "_onSuccess", "_warning", "_onWarning", "_topbarColor", "_topbarFgColor", "_topbarBgColorV1", "_topbarBgColorV2", "_topbarBgColorV3", "_topbarFgColorV1", "_topbarFgColorV2", "_topbarFgColorV3", "_leftMenuBgColorV1", "_leftMenuBgColorV2", "_leftMenuBgColorV3", "_leftMenuFgColorV1", "_leftMenuFgColorV2", "_leftMenuFgColorV3", "_subtleTextColor", "_volOsdBgColor", "_volOsdFgColor"]
    readonly property var _dimKeys: ["_baseRadius", "_barHeight", "_barBottomMargin", "_barWidgetsHeight", "_menuHeight", "_menuWidth", "_menuWidgetsMargin", "_elementRadius", "_spacingSmall", "_spacingMedium", "_spacingLarge"]
    readonly property var _typeKeys: ["_iconFont", "_bodyFont", "_baseFontSize", "_heading1Size", "_heading2Size", "_heading3Size", "_heading4Size", "_mediumFontSize", "_smallFontSize"]
    readonly property var _hyprKeys: ["_hyprBorderWidth", "_hyprActiveBorder", "_hyprInactiveBorder", "_hyprRounding", "_hyprDropShadow", "_hyprGapsIn", "_hyprGapsOut", "_hyprLayout", "_hyprAnimationsEnabled", "_hyprBezier", "_hyprAnimWindows", "_hyprAnimWorkspaces", "_hyprBlurEnabled", "_hyprBlurSize", "_hyprBlurPasses", "_hyprDimInactive", "_hyprDimStrength", "_hyprShadowRange", "_hyprShadowOffset", "_hyprShadowColor"]
    readonly property var _wallKeys: ["_enableDynamicColoring", "_enableDynamicWallpapers", "_dynamicWallpapersInterval", "_dynamicWallpapersPath", "_selectedWallpaperIndex", "_wallpaper", "_dynamicColoringSchemeVariant", "_dynamicColoringChromaMult", "_dynamicColoringToneMult"]
    readonly property var _sysKeys: ["_qtThemeStyle", "_kvantumTheme", "_plasmaColorScheme", "_konsoleProfile", "_enableAccentColoring", "_gtkTheme", "_themeIcons", "_themeMode"]
    readonly property var _clockKeys: ["_desktopClockLocal", "_desktopClockFont", "_desktopClockEnabled", "_desktopClockColor", "_desktopClockFormat", "_desktopClockPosition", "_desktopClockDepthEffectEnabled", "_desktopClockDepthModel", "_desktopClockDepthOverlayPath", "_desktopClockSize", "_desktopClockSahdowColor", "_desktopClockSahdowEnabled", "_desktopClockUseThemeColor", "_desktopClockUseAnimation"]

    // تجميع الكل
    readonly property var allKeys: _colorKeys.concat(_dimKeys).concat(_typeKeys).concat(_hyprKeys).concat(_wallKeys).concat(_sysKeys).concat(_clockKeys)

    // حفظ الثيم الحالي للكاش
    function saveToCache(themeInstance, fileName, notify = false) {
        if (!themeInstance)
            return;

        let data = {};
        for (const key of allKeys) {
            if (themeInstance.hasOwnProperty(key)) {
                data[key] = themeInstance[key];
            }
        }

        // كتابة الملف
        cacheFile.path = App.themeCacheFolderPath + `/${fileName}.json`;
        cacheFile.setText(JSON.stringify(data, null, 2));

        if (notify) {
            // إشعار (اختياري)
            console.info("Theme saved to cache:", fileName);
        }
    }

    // تطبيق بيانات JSON على الثيم النشط
    function applyData(themeInstance, jsonData) {
        console.info("[ThemeSerializer] applyData called.");

        if (!themeInstance) {
            console.error("[ThemeSerializer] ERROR: themeInstance is null!");
            return;
        }
        if (!jsonData) {
            console.error("[ThemeSerializer] ERROR: jsonData is null!");
            return;
        }

        let appliedCount = 0;
        let keys = Object.keys(jsonData);
        console.info(`[ThemeSerializer] Processing ${keys.length} keys from JSON.`);

        for (const key of keys) {
            // تجاهل الاسم
            if (key === "themeName")
                continue;

            if (themeInstance.hasOwnProperty(key)) {
                // تخطي الألوان الديناميكية
                // (أضف منطق التحقق من المصفوفات هنا إذا أردت)

                try {
                    let oldVal = themeInstance[key];
                    let newVal = jsonData[key];

                    // سنطبع فقط أول 3 تغييرات لتجنب إغراق اللوق، أو نطبع الأخطاء
                    if (oldVal !== newVal) {
                        themeInstance[key] = newVal;
                        appliedCount++;
                        // console.info(`[ThemeSerializer] Updated ${key}: ${oldVal} -> ${newVal}`);
                    }
                } catch (err) {
                    console.warn(`[ThemeSerializer] Failed to set property ${key}: ${err.message}`);
                }
            } else
            // خاصية في الجيسون غير موجودة في الثيم
            // console.info(`[ThemeSerializer] Skipped unknown key: ${key}`);
            {}
        }
        console.info(`[ThemeSerializer] Finished. Total properties updated: ${appliedCount}`);
    }

    FileView {
        id: cacheFile
        watchChanges: false
    }
}
