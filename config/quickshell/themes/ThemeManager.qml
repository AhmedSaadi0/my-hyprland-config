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
    // القسم 1: الواجهة العامة (Public API)
    // - الخصائص والإشارات والدوال التي تتعامل معها واجهة المستخدم بشكل مباشر.
    //================================================================

    // 1.1. الإشارات (Signals)
    signal selectedThemeUpdated

    // 1.2. الخصائص العامة (Public Properties)
    property var selectedTheme: ColorsTheme
    property var wallpapersList: []
    property string targetedCacheThemeFile: App.themeCacheFolderPath + `/${selectedTheme.themeName}.json`

    // 1.3. الدوال العامة (Public Functions)

    /**
     * يقوم بتحميل سمة جديدة من ملف واستبدال السمة الحالية.
     * @param themeFile المسار إلى ملف السمة (بدون الامتداد .qml).
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
        sessionSaver.setText(JSON.stringify({
            activeThemeName: themeFile
        }));
        cacheThemeFile.path = App.themeCacheFolderPath + `/${themeFile}.json`;
        cacheThemeFile.reload();
    }

    /**
     * يقوم بتحديث السمة الحالية بالبيانات المعدلة ثم تطبيقها على النظام.
     * @param modifiedThemeData كائن يحتوي على الخصائص المراد تحديثها.
     * @param saveTheme منطقي، إذا كان يجب حفظ التغييرات بشكل دائم.
     */
    function updateAndApplyTheme(modifiedThemeData, saveTheme) {
        if (!selectedTheme || !modifiedThemeData) {
            console.error("Cannot update theme: invalid data received.");
            return;
        }

        const preserveColorBindings = modifiedThemeData._enableDynamicColoring;
        console.info("Updating live theme. Preserving reactive color bindings:", preserveColorBindings);

        // حقن الخصائص الجديدة في السمة الحالية
        for (const key in modifiedThemeData) {
            if (root.selectedTheme.hasOwnProperty(key)) {
                // إذا كان التلوين الديناميكي مفعلًا، لا تقم بالكتابة فوق خصائص الألوان للحفاظ على الربط التفاعلي
                if (preserveColorBindings && _colorPropertyKeys.includes(key)) {
                    continue;
                }
                root.selectedTheme[key] = modifiedThemeData[key];
            }
        }

        // تطبيق الإعدادات على النظام
        _applyExternalSettings(saveTheme);
    }

    //================================================================
    // القسم 2: الحالة الداخلية والثوابت (Internal State & Constants)
    // - خصائص للقراءة فقط تستخدم داخليًا لتنظيم منطق العمل.
    //================================================================

    readonly property var _colorPropertyKeys: ["_primary", "_secondary", "_onPrimary", "_onSecondary", "_topbarColor", "_topbarFgColor", "_topbarBgColorV1", "_topbarBgColorV2", "_topbarBgColorV3", "_topbarFgColorV1", "_topbarFgColorV2", "_topbarFgColorV3", "_leftMenuBgColorV1", "_leftMenuBgColorV2", "_leftMenuBgColorV3", "_leftMenuFgColorV1", "_leftMenuFgColorV2", "_leftMenuFgColorV3", "_subtleTextColor", "_volOsdBgColor", "_volOsdFgColor"]
    readonly property var _dimensionPropertyKeys: ["_baseRadius", "_barHeight", "_barBottomMargin", "_barWidgetsHeight", "_menuHeight", "_menuWidth", "_menuWidgetsMargin", "_elementRadius", "_spacingSmall", "_spacingMedium", "_spacingLarge"]
    readonly property var _typographyPropertyKeys: ["_iconFont", "_bodyFont", "_baseFontSize", "_heading1Size", "_heading2Size", "_heading3Size", "_heading4Size", "_mediumFontSize", "_smallFontSize"]
    readonly property var _systemPropertyKeys: ["_wallpaper", "_qtThemeStyle", "_kvantumTheme", "_gtkTheme", "_themeIcons", "_themeMode", "_plasmaColorScheme", "_konsoleProfile", "_enableDynamicColoring", "_enableDynamicWallpapers", "_dynamicWallpapersInterval", "_dynamicWallpapersPath", "_selectedWallpaperIndex"]
    readonly property var _hyprlandPropertyKeys: ["_hyprBorderWidth", "_hyprActiveBorder", "_hyprInactiveBorder", "_hyprRounding", "_hyprDropShadow"]
    readonly property var _allSerializableKeys: _colorPropertyKeys.concat(_dimensionPropertyKeys).concat(_typographyPropertyKeys).concat(_systemPropertyKeys).concat(_hyprlandPropertyKeys)

    //================================================================
    // القسم 3: معالجات دورة الحياة (Lifecycle Handlers)
    // - يتم تشغيلها عند إنشاء المكون.
    //================================================================

    Component.onCompleted: {
        console.log("Application starting. Loading last session...");
        sessionLoader.path = App.themeCacheFilePath; // بدء تحميل الجلسة السابقة
    }

    //================================================================
    // القسم 4: المنطق الداخلي (Internal Logic)
    // - الدوال الخاصة التي تدير عملية تطبيق السمات وحفظها.
    //================================================================

    // 4.1. تنسيق تطبيق السمة (Theme Application Coordination)

    /**
     * الدالة المنسقة الرئيسية. تقرأ من السمة الحالية وتطبق الإعدادات.
     */
    function _applyExternalSettings(saveTheme) {
        if (!root.selectedTheme)
            return;

        console.info("Applying external settings for:", root.selectedTheme.themeName);
        const settings = root.selectedTheme.systemSettings;

        wallpaperTimer.stop();

        getWallpapersList.running = false;

        if (settings.enableDynamicWallpapers) {
            getWallpapersList.command = Utils.Helper.getWallpapersList(root.selectedTheme.systemSettings.dynamicWallpapersPath);
            getWallpapersList.running = true; // يبدأ عملية جلب الخلفيات وتطبيقها
        } else {
            _applyStaticTheme(settings);
        }

        if (saveTheme) {
            sendChangedSignalTimer.start();
        }
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
        applyAccentColorTimer.start(); // تطبيق اللون المميز بعد فترة قصيرة
    }

    // 4.2. منطق الخلفيات الديناميكية (Dynamic Wallpaper Logic)

    /**
     * يطبق الخلفية الديناميكية بناءً على وضع السمة (فاتح/داكن).
     */
    function _applyDynamicWallpaper() {
        const settings = selectedTheme.systemSettings;
        const themeMode = settings.themeMode;

        let currentIndex = settings.selectedWallpaperIndex;

        if (currentIndex >= wallpapersList.length) {
            currentIndex = 0;
            selectedTheme._selectedWallpaperIndex = 0;
        }

        const selectedWallpaper = wallpapersList[currentIndex];
        _applyCoreThemeSettings(settings, selectedWallpaper);

        if (settings.enableDynamicColoring) {
            _dispatchCommand("Apply M3 Theming", Utils.Helper.applyM3PlasmaColor(selectedWallpaper, themeMode));
        }

        wallpaperTimer.running = settings.enableDynamicWallpapers || settings.enableDynamicColoring;
    }

    // 4.3. دوال مساعدة منخفضة المستوى (Low-level Action Helpers)

    /**
     * يرسل أمرًا تنفيذيًا عبر Hyprland.
     */
    function _dispatchCommand(description, commandArray) {
        if (!Array.isArray(commandArray) || commandArray.length === 0) {
            console.warn(`Skipping empty command: ${description}`);
            return;
        }
        Hyprland.dispatch(`exec ${commandArray.join(' ')}`);
    }

    function _changeWallpaper(path) {
        _dispatchCommand("Changing Wallpaper", Utils.Helper.changeWallpaper(path));
    }

    function _setHyprlandConfigurations() {
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
        // ملاحظة: استدعاء الأمر مرتين هو حل بديل لمشكلة في تطبيق اللون بشكل موثوق.
        _dispatchCommand("Plasma Accent Color", Utils.Helper.changePlasmaAccentColor(accentColor));
        _dispatchCommand("Plasma Accent Color", Utils.Helper.changePlasmaAccentColor(accentColor));
    }

    // 4.4. حفظ البيانات والتخزين المؤقت (Data Persistence & Caching)

    /**
     * يجمع البيانات الحالية من السمة ويحفظها في ملف التخزين المؤقت.
     */
    function _cacheAppliedData() {
        let dataToSave = {};
        for (const key of _allSerializableKeys) {
            if (root.selectedTheme.hasOwnProperty(key)) {
                dataToSave[key] = root.selectedTheme[key];
            }
        }
        cacheThemeFile.setText(JSON.stringify(dataToSave, null, 2));
        console.log(`Data for '${selectedTheme.themeName}' saved to ${cacheThemeFile.path}`);
    }

    //================================================================
    // القسم 5: المكونات الفرعية والعاملة (Child Components & Workers)
    // - عناصر لإدارة العمليات غير المتزامنة، والمؤقتات، وملفات الإدخال/الإخراج.
    //================================================================

    // 5.1. عمال إدارة الملفات (File I/O Workers)

    FileView {
        id: sessionLoader
        onLoaded: {
            try {
                const session = JSON.parse(this.text());
                root.loadTheme(session.activeThemeName || "ColorsTheme");
            } catch (e) {
                console.error("Failed to parse session file, loading default theme.", e);
                root.loadTheme("ColorsTheme");
            }
        }
        onLoadFailed: {
            console.info("Session file not found. Starting with default theme.");
            root.loadTheme("ColorsTheme");
        }
    }

    FileView {
        id: sessionSaver
        path: App.themeCacheFilePath
    }

    FileView {
        id: cacheThemeFile
        path: root.targetedCacheThemeFile
        watchChanges: true

        onLoaded: {
            try {
                const data = JSON.parse(cacheThemeFile.text());
                root.updateAndApplyTheme(data, true);
            } catch (e) {
                console.error("Failed to read cache file, applying default values.", e);
                root.loadTheme("ColorsTheme");
                root.updateAndApplyTheme({}, true);
            }
        }
        onLoadFailed: {
            console.info("Cache file not found. It will be created with default values.");
            root._cacheAppliedData();
        }
    }

    // 5.2. عامل جلب الخلفيات (Wallpaper Fetcher Process)

    Process {
        id: getWallpapersList
        command: Utils.Helper.getWallpapersList(root.selectedTheme.systemSettings.dynamicWallpapersPath)

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.wallpapersList = JSON.parse(this.text);
                    root._applyDynamicWallpaper();
                } catch (e) {
                    console.error(root.selectedTheme.systemSettings.dynamicWallpapersPath);
                    console.error("Failed to parse wallpapers list:", e);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => console.error("Error getting wallpaper list:", data)
        }
    }

    // 5.3. المؤقتات المساعدة (Utility Timers)

    Timer {
        id: wallpaperTimer
        repeat: true
        running: false
        interval: root.selectedTheme?.systemSettings?.dynamicWallpapersInterval || 60000

        onTriggered: {
            root.selectedTheme._selectedWallpaperIndex++;
            root._applyDynamicWallpaper();
            sendChangedSignalTimer.start();
        }
    }

    Timer {
        id: applyAccentColorTimer
        interval: 1000 // تأخير لتطبيق اللون المميز
        repeat: false
        onTriggered: root._applyAccentColor()
    }

    Timer {
        id: sendChangedSignalTimer
        interval: 1000 // تأخير قبل الحفظ وإرسال إشارة التحديث
        repeat: false
        onTriggered: {
            root._cacheAppliedData();
            root.selectedThemeUpdated();
        }
    }
}
