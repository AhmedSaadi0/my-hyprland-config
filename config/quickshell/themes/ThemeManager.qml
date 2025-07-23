pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "root:/utils" as Utils
import "root:/config"

Singleton {
    id: root

    //================================================================
    // 1. Signals & Properties (الإشارات والخصائص)
    // - لإدارة حالة الواجهة والإبلاغ عن التغييرات.
    //================================================================

    signal selectedThemeUpdated

    property var selectedTheme: ColorsTheme
    property int selectedDarkWallpaperIndex: 0
    property int selectedLightWallpaperIndex: 0
    property var wallpapersList: []

    //================================================================
    // 2. Public API Functions (الدوال العامة)
    // - الدوال الرئيسية التي يتم استدعاؤها من واجهة المستخدم.
    //================================================================

    /**
     * يقوم بتحميل سمة جديدة من ملف واستبدال السمة الحالية.
     */
    function loadTheme(themeFile) {
        const component = Qt.createComponent(`${themeFile}.qml`);
        if (component.status !== Component.Ready) {
            console.error("Failed to load theme:", component.errorString());
            return;
        }

        const themeInstance = component.createObject();
        if (!themeInstance) {
            console.error("Failed to create theme object:", themeFile);
            return;
        }

        root.selectedTheme = themeInstance;
        _applyExternalSettings(); // تطبيق إعدادات السمة الجديدة.
    }

    /**
     * يقوم بتحديث السمة الحالية بالبيانات المعدلة ثم تطبيقها.
     */
    readonly property var _colorPropertyKeys: ["_primary", "_secondary", "_onPrimary", "_onSecondary", "_topbarColor", "_topbarFgColor", "_topbarBgColorV1", "_topbarBgColorV2", "_topbarBgColorV3", "_topbarFgColorV1", "_topbarFgColorV2", "_topbarFgColorV3", "_leftMenuBgColorV1", "_leftMenuBgColorV2", "_leftMenuBgColorV3", "_leftMenuFgColorV1", "_leftMenuFgColorV2", "_leftMenuFgColorV3", "_subtleTextColor", "_volOsdBgColor", "_volOsdFgColor"]

    function updateAndApplyTheme(modifiedThemeData) {
        if (!selectedTheme || !modifiedThemeData) {
            console.error("Cannot update theme: invalid data received.");
            return;
        }

        // تحقق من حالة "التلوين الديناميكي" من البيانات القادمة
        const preserveColorBindings = modifiedThemeData._enableDynamicColoring;

        console.info("Updating live theme. Preserving reactive color bindings:", preserveColorBindings);

        // 1. حقن الخصائص المعدلة في السمة الحالية
        for (const key in modifiedThemeData) {
            if (root.selectedTheme.hasOwnProperty(key)) {

                // ---- المنطق الجديد والمهم هنا ----
                // إذا كان التلوين الديناميكي مفعلًا، وهذا المفتاح هو أحد خصائص الألوان،
                // فتجاوزه للحفاظ على الربط التفاعلي مع Kirigami.Theme.
                if (preserveColorBindings && _colorPropertyKeys.includes(key)) {
                    // console.debug(`Skipping color property '${key}' to preserve binding.`);
                    continue; // انتقل إلى الخاصية التالية
                }

                // إذا لم يكن الشرط صحيحًا، قم بالتحديث كالمعتاد
                root.selectedTheme[key] = modifiedThemeData[key];
            }
        }

        // 2. تطبيق الإعدادات على النظام
        _applyExternalSettings();
    }

    //================================================================
    // 3. Core Internal Logic (منطق التطبيق الداخلي)
    // - الدوال التي تنسق عملية تطبيق الإعدادات.
    //================================================================

    /**
     * الدالة المنسقة الرئيسية. تقرأ من السمة الحالية وتطبق الإعدادات.
     */
    function _applyExternalSettings() {
        if (!root.selectedTheme)
            return;

        console.info("Applying external settings for:", root.selectedTheme.themeName);

        const settings = root.selectedTheme.systemSettings;

        // إيقاف العمليات المؤقتة قبل البدء من جديد
        wallpaperTimer.stop();
        getWallpapersList.running = false;

        if (settings.enableDynamicWallpapers) {
            getWallpapersList.running = true; // سيبدأ عملية جلب الخلفيات وتطبيقها
        } else {
            _applyStaticTheme(settings);
        }

        sendChangedSignalTimer.start();
    }

    /**
     * يطبق الإعدادات الأساسية المشتركة بين الوضع الثابت والديناميكي.
     */
    function _applyCoreThemeSettings(settings, wallpaperPath) {
        _changeWallpaper(wallpaperPath);
        _changeQtTheme(settings);
        _changeGtkTheme(settings);
        _setHyprlandConfigurations(settings);
    }

    /**
     * يطبق السمة الثابتة (خلفية واحدة).
     */
    function _applyStaticTheme(settings) {
        _applyCoreThemeSettings(settings, settings.wallpaper);
        applyAccentColorTimer.start(); // تطبيق اللون المميز بشكل منفصل
    // _cacheAppliedData();
    }

    //================================================================
    // 4. Dynamic Wallpaper Logic (منطق الخلفيات الديناميكية)
    //================================================================

    /**
     * يطبق الخلفية الديناميكية بناءً على وضع السمة (فاتح/داكن).
     */
    function _applyDynamicWallpaper() {
        const settings = selectedTheme.systemSettings;
        const themeMode = settings.themeMode;

        let currentIndex = themeMode === "light" ? selectedLightWallpaperIndex : selectedDarkWallpaperIndex;
        if (currentIndex >= wallpapersList.length) {
            currentIndex = 0; // العودة إلى البداية إذا تجاوزنا عدد الخلفيات
            if (themeMode === "light")
                selectedLightWallpaperIndex = 0;
            else
                selectedDarkWallpaperIndex = 0;
        }

        const selectedWallpaper = wallpapersList[currentIndex];

        _applyCoreThemeSettings(settings, selectedWallpaper);

        if (settings.enableDynamicColoring) {
            _dispatchCommand("Apply M3 Theming", Utils.Helper.applyM3PlasmaColor(selectedWallpaper, themeMode));
        }

        _cacheAppliedData();
        wallpaperTimer.running = settings.enableDynamicWallpapers || settings.enableDynamicColoring;
    }

    Process {
        id: getWallpapersList
        command: Utils.Helper.getWallpapersList(selectedTheme.systemSettings.dynamicWallpapersPath)

        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapersList = JSON.parse(this.text);
                _applyDynamicWallpaper();
            }
        }
        stderr: SplitParser {
            onRead: data => console.error(data)
        }
    }

    Timer {
        id: wallpaperTimer
        repeat: true
        running: false
        interval: selectedTheme?.systemSettings?.dynamicWallpapersInterval || 60000

        onTriggered: {
            if (selectedTheme.systemSettings.themeMode === "light") {
                selectedLightWallpaperIndex++;
            } else {
                selectedDarkWallpaperIndex++;
            }
            _applyDynamicWallpaper();
            sendChangedSignalTimer.start();
        }
    }

    //================================================================
    // 5. Low-level Action Helpers (الدوال المساعدة منخفضة المستوى)
    // - دوال مسؤولة عن تنفيذ أوامر محددة.
    //================================================================

    function _dispatchCommand(description, commandArray) {
        if (!Array.isArray(commandArray) || commandArray.length === 0) {
            console.warn(`Skipping empty command: ${description}`);
            return;
        }
        // console.info(`${description} -> ${commandArray.join(' ')}`);
        Hyprland.dispatch(`exec ${commandArray.join(' ')}`);
    }

    function _changeWallpaper(path) {
        _dispatchCommand("Changing Wallpaper", Utils.Helper.changeWallpaper(path));
    }

    function _setHyprlandConfigurations(settings) {
        const cfg = root.selectedTheme.hyprlandConfiguration;
        const keywords = [[`general:border_size`, cfg.borderWidth], [`general:col.active_border`, `'${cfg.activeBorder}'`], [`general:col.inactive_border`, `'${cfg.inactiveBorder}'`], [`decoration:rounding`, cfg.rounding], [`decoration:drop_shadow`, cfg.dropShadow ? "yes" : "no"]];

        for (const [key, value] of keywords) {
            Hyprland.dispatch(`exec hyprctl keyword ${key} ${value}`);
        }
    }

    function _changeQtTheme(settings) {
        _dispatchCommand("Plasma Color", Utils.Helper.changePlasmaColor(settings.plasmaColorScheme));
        _dispatchCommand("Plasma Icons", Utils.Helper.changePlasmaIcons(settings.themeIcons));
        _dispatchCommand("Konsole Profile", Utils.Helper.changeKonsoleProfile(settings.konsoleProfile));
        _dispatchCommand("Qt Style", Utils.Helper.changeQtStyle(settings.qtThemeStyle));
        _dispatchCommand("Kvantum Theme", Utils.Helper.changeKvantumTheme(settings.kvantumTheme));
    }

    function _changeGtkTheme(settings) {
        _dispatchCommand("GTK Theme", Utils.Helper.changeGtkTheme(settings.gtkTheme));
        _dispatchCommand("GTK Icons", Utils.Helper.changeGtkIcons(settings.themeIcons));
        _dispatchCommand("GTK Font", Utils.Helper.changeGtkFont(settings.fontName));
    }

    function _applyAccentColor() {
        const accentColor = selectedTheme.colors.primary;
        // ملاحظة: استدعاء الأمر مرتين هو حل بديل لمشكلة غير معروفة.
        // قد يكون هناك حاجة لتأخير أو آلية أخرى لتطبيق اللون بشكل موثوق.
        _dispatchCommand("Plasma Accent Color", Utils.Helper.changePlasmaAccentColor(accentColor));
        _dispatchCommand("Plasma Accent Color", Utils.Helper.changePlasmaAccentColor(accentColor));
    }

    //================================================================
    // 6. Data Persistence & Caching (حفظ البيانات والتخزين المؤقت)
    //================================================================

    function _getCustomizationFilePath(themeName) {
        return App.themeCacheFolderPath + `/${themeName}.json`;
    }

    function _cacheAppliedData() {
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
                selectedDarkWallpaperIndex = data.selectedDarkWallpaper || 0;
                selectedLightWallpaperIndex = data.selectedLightWallpaper || 0;
                loadTheme(data.selectedTheme || "default");
            } catch (e) {
                console.error("فشل قراءة ملف التخزين:", e);
                loadTheme("default"); // تحميل السمة الافتراضية عند الفشل
            }
        }
        onLoadFailed: {
            console.info("ملف التخزين غير موجود. سيتم إنشاؤه بالقيم الافتراضية.");
            _cacheAppliedData();
        }
    }

    //================================================================
    // 7. Utility Timers (المؤقتات المساعدة)
    //================================================================

    Timer {
        id: applyAccentColorTimer
        interval: 2000 // ثانيتان
        repeat: false
        onTriggered: _applyAccentColor()
    }

    Timer {
        id: sendChangedSignalTimer
        interval: 3000 // 3 ثوانٍ
        repeat: false
        onTriggered: selectedThemeUpdated()
    }
}
