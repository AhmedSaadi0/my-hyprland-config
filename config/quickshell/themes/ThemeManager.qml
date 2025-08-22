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
    // القسم 2: الواجهة العامة (Public API)
    // - الخصائص والإشارات والدوال التي تتعامل معها واجهة المستخدم بشكل مباشر.
    //================================================================

    // 2.1. الإشارات (Signals)
    signal selectedThemeUpdated

    // 2.2. الخصائص العامة (Public Properties)
    property string _currentThemeFile: "" // لتخزين مسار ملف السمة المحمل حالياً
    property var selectedTheme: ColorsTheme
    // --- انتهى قسم الإضافة ---
    property var wallpapersList: []
    property string targetedCacheThemeFile: App.themeCacheFolderPath + `/${selectedTheme.themeName}.json`

    // 2.3. الدوال العامة (Public Functions)

    /**
     * يقوم بتحميل سمة جديدة من ملف واستبدال السمة الحالية.
     * @param themeFile المسار إلى ملف السمة (بدون الامتداد .qml).
     */
    function loadTheme(themeFile) {
        _stopRunningAllProcess();
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
        root._currentThemeFile = themeFile; // حفظ مسار السمة الحالية
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
    // القسم 3: الحالة الداخلية والثوابت (Internal State & Constants)
    // - خصائص للقراءة فقط تستخدم داخليًا لتنظيم منطق العمل.
    //================================================================

    readonly property var _colorPropertyKeys: ["themeName", "_primary", "_secondary", "_onPrimary", "_onSecondary", "_topbarColor", "_topbarFgColor", "_topbarBgColorV1", "_topbarBgColorV2", "_topbarBgColorV2", "_topbarBgColorV2", "_topbarBgColorV3", "_topbarFgColorV1", "_topbarFgColorV2", "_topbarFgColorV3", "_leftMenuBgColorV1", "_leftMenuBgColorV2", "_leftMenuBgColorV3", "_leftMenuFgColorV1", "_leftMenuFgColorV2", "_leftMenuFgColorV3", "_subtleTextColor", "_volOsdBgColor", "_volOsdFgColor",]
    readonly property var _dimensionPropertyKeys: ["_baseRadius", "_barHeight", "_barBottomMargin", "_barWidgetsHeight", "_menuHeight", "_menuWidth", "_menuWidgetsMargin", "_elementRadius", "_spacingSmall", "_spacingMedium", "_spacingLarge"]
    readonly property var _typographyPropertyKeys: ["_iconFont", "_bodyFont", "_baseFontSize", "_heading2Size", "_heading2Size", "_heading3Size", "_heading4Size", "_mediumFontSize", "_smallFontSize"]
    readonly property var _systemPropertyKeys: ["_wallpaper", "_qtThemeStyle", "_kvantumTheme", "_gtkTheme", "_themeIcons", "_themeMode", "_plasmaColorScheme", "_konsoleProfile", "_enableDynamicColoring", "_enableDynamicWallpapers", "_dynamicWallpapersInterval", "_dynamicWallpapersPath", "_selectedWallpaperIndex", "_enableAccentColoring"]
    readonly property var _hyprlandPropertyKeys: ["_hyprBorderWidth", "_hyprActiveBorder", "_hyprInactiveBorder", "_hyprRounding", "_hyprDropShadow"]

    // خصائص محددة للاستعادة
    readonly property var _wallpaperSystemPropertyKeys: ["_enableDynamicColoring", "_enableDynamicWallpapers", "_dynamicWallpapersInterval", "_dynamicWallpapersPath", "_selectedWallpaperIndex", "_wallpaper"]
    readonly property var _plasmaPropertyKeys: ["_qtThemeStyle", "_kvantumTheme", "_plasmaColorScheme", "_konsoleProfile", "_themeIcons"]
    readonly property var _gtkPropertyKeys: ["_gtkTheme", "_themeIcons"]

    readonly property var _allSerializableKeys: _colorPropertyKeys.concat(_dimensionPropertyKeys).concat(_typographyPropertyKeys).concat(_systemPropertyKeys).concat(_hyprlandPropertyKeys)

    //================================================================
    // القسم 4: معالجات دورة الحياة (Lifecycle Handlers)
    // - يتم تشغيلها عند إنشاء المكون.
    //================================================================

    Component.onCompleted: {
        console.info("Application starting. Loading last session...");
        startUpTimer.start();
    }

    /**
     * ينتقل إلى الخلفية التالية في القائمة إذا كانت الخلفيات الديناميكية مفعلة.
     */
    function switchToNextWallpaper() {
        if (!selectedTheme.systemSettings.enableDynamicWallpapers || wallpapersList.length === 1) {
            console.info("Cannot switch wallpaper: Dynamic wallpapers are not enabled or list is empty.");
            return;
        }
        console.info("Switching to the next wallpaper manually.");
        wallpaperTimer.triggered();
        wallpaperTimer.restart(); // إعادة تشغيل المؤقت ليبدأ العد من جديد
    }

    /**
     * يستعيد إعدادات الألوان إلى القيم الافتراضية للسمة الحالية.
     */
    function resetColorSettings() {
        console.info("Resetting color settings to default.");
        _resetPropertiesToDefault(_colorPropertyKeys);
    }

    /**
     * يستعيد إعدادات الخلفية (ديناميكية، مسار، ...) إلى القيم الافتراضية.
     */
    function resetWallpaperSystemSettings() {
        console.info("Resetting wallpaper system settings to default.");
        _resetPropertiesToDefault(_wallpaperSystemPropertyKeys);
    }

    /**
     * يستعيد إعدادات Hyprland إلى القيم الافتراضية للسمة.
     */
    function resetHyprlandSettings() {
        console.info("Resetting Hyprland settings to default.");
        _resetPropertiesToDefault(_hyprlandPropertyKeys);
    }

    /**
     * يستعيد إعدادات Plasma (الألوان، الأيقونات، ...) إلى القيم الافتراضية.
     */
    function resetPlasmaSettings() {
        console.info("Resetting Plasma settings to default.");
        _resetPropertiesToDefault(_plasmaPropertyKeys);
    }

    /**
     * يستعيد إعدادات GTK (السمة، الأيقونات) إلى القيم الافتراضية.
     */
    function resetGtkSettings() {
        console.info("Resetting GTK settings to default.");
        _resetPropertiesToDefault(_gtkPropertyKeys);
    }

    function resetWholeTheme() {
        resetColorSettings();
        resetWallpaperSystemSettings();
        resetHyprlandSettings();
        resetPlasmaSettings();
        resetGtkSettings();
    }

    //================================================================
    // القسم 5: المنطق الداخلي (Internal Logic)
    // - الدوال الخاصة التي تدير عملية تطبيق السمات وحفظها.
    //================================================================

    // 5.1. تنسيق تطبيق السمة (Theme Application Coordination)

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

        if (!settings.enableDynamicColoring && settings.enableAccentColoring) {
            applyAccentColorTimer.start();
        }
    }

    /**
     * يطبق الإعدادات الأساسية المشتركة بين الوضع الثابت والديناميكي.
     */
    function _applyCoreThemeSettings(settings, wallpaperPath) {
        _changeWallpaper(wallpaperPath);
        _changeQtTheme(settings);
        _changeGtkTheme(settings);
        _changeGtk4Theme(settings);
        _setHyprlandConfigurations(settings);
    }

    /**
     * يطبق السمة الثابتة (خلفية واحدة).
     */
    function _applyStaticTheme(settings) {
        _applyCoreThemeSettings(settings, settings.wallpaper);
    }

    // 5.2. منطق الخلفيات الديناميكية (Dynamic Wallpaper Logic)

    /**
     * يطبق الخلفية الديناميكية بناءً على وضع السمة (فاتح/داكن).
     */
    function _applyDynamicWallpaper() {
        const settings = selectedTheme.systemSettings;
        const themeMode = settings.themeMode;

        let currentIndex = settings.selectedWallpaperIndex;

        if (currentIndex >= wallpapersList.length && wallpapersList.length != 1) {
            currentIndex = 1;
            selectedTheme._selectedWallpaperIndex = 1;
        }

        const selectedWallpaper = wallpapersList[currentIndex];
        _applyCoreThemeSettings(settings, selectedWallpaper);

        if (settings.enableDynamicColoring) {
            _dispatchCommand("Apply M4 Theming", Utils.Helper.applyM3PlasmaColor(selectedWallpaper, themeMode));
        }

        wallpaperTimer.running = settings.enableDynamicWallpapers || settings.enableDynamicColoring;
    }

    // 5.3. دوال مساعدة منخفضة المستوى (Low-level Action Helpers)

    /**
     * يرسل أمرًا تنفيذيًا عبر Hyprland.
     */
    function _dispatchCommand(description, commandArray) {
        App.dispatchCommand(description, commandArray);
    // if (!Array.isArray(commandArray) || commandArray.length === 1) {
    //     console.warn(`Skipping empty command: ${description}`);
    //     return;
    // }
    // console.info(description + " -> " + commandArray.join(' '));
    // Hyprland.dispatch(`exec ${commandArray.join(' ')}`);
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
        const fontSize = root.selectedTheme.typography.baseFontSize;
        _dispatchCommand("GTK Theme", Utils.Helper.changeGtkTheme(settings.gtkTheme));
        _dispatchCommand("GTK Icons", Utils.Helper.changeGtkIcons(settings.themeIcons));
        _dispatchCommand("GTK Font", Utils.Helper.changeGtkFont(settings.fontName, fontSize));
    }

    function _changeGtk4Theme(settings) {
        _dispatchCommand("GTK 4 Theme", Utils.Helper.removeOldGtk4Theme());
        _dispatchCommand("GTK 4 Theme", Utils.Helper.changeGtk4Theme(settings.gtkTheme));
    }

    function _applyAccentColor() {
        const accentColor = selectedTheme.colors.primary;
        // ملاحظة: استدعاء الأمر مرتين هو حل بديل لمشكلة في تطبيق اللون بشكل موثوق.
        _dispatchCommand("Plasma Accent Color", Utils.Helper.changePlasmaAccentColor(accentColor));
    }

    /**
     * دالة مساعدة خاصة لاستعادة مجموعة معينة من الخصائص إلى قيمها الافتراضية.
     * @param keysToReset مصفوفة من أسماء الخصائص المراد استعادتها.
     */
    function _resetPropertiesToDefault(keysToReset) {
        if (!_currentThemeFile) {
            console.error("Cannot reset properties: Current theme file is unknown.");
            return;
        }

        // 2. إنشاء مكون مؤقت من ملف السمة الأصلي للحصول على القيم الافتراضية
        const tempComponent = Qt.createComponent(`${_currentThemeFile}.qml`);
        if (tempComponent.status !== Component.Ready) {
            console.error("Failed to load temporary theme for reset:", tempComponent.errorString());
            return;
        }

        const defaultThemeObject = tempComponent.createObject();
        if (!defaultThemeObject) {
            console.error("Failed to create temporary theme object for reset.");
            return;
        }

        // 3. نسخ القيم الافتراضية إلى السمة النشطة
        let modifiedData = {};
        for (const key of keysToReset) {
            if (root.selectedTheme.hasOwnProperty(key) && defaultThemeObject.hasOwnProperty(key)) {
                const defaultValue = defaultThemeObject[key];
                root.selectedTheme[key] = defaultValue; // تحديث السمة الحية
                modifiedData[key] = defaultValue;       // تجميع البيانات للتطبيق
            }
        }

        // 4. تدمير الكائن المؤقت لتحرير الذاكرة
        defaultThemeObject.destroy();
        tempComponent.destroy();

        // 5. تطبيق التغييرات وحفظها
        // نقوم بتمرير false لـ saveTheme هنا لأن _cacheAppliedData سيتم استدعاؤها عبر المؤقت
        updateAndApplyTheme(modifiedData, true);
    }

    // 5.4. حفظ البيانات والتخزين المؤقت (Data Persistence & Caching)

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
        cacheThemeFile.setText(JSON.stringify(dataToSave, null, 3));
        console.info(`Data for '${selectedTheme.themeName}' saved to ${cacheThemeFile.path}`);
    }

    function _stopRunningAllProcess() {
        getWallpapersList.running = false;
        wallpaperTimer.stop();
        applyAccentColorTimer.stop();
        startUpTimer.stop();
        sendChangedSignalTimer.stop();
    }

    //================================================================
    // القسم 6: المكونات الفرعية والعاملة (Child Components & Workers)
    // - عناصر لإدارة العمليات غير المتزامنة، والمؤقتات، وملفات الإدخال/الإخراج.
    //================================================================

    // 6.1. عمال إدارة الملفات (File I/O Workers)

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
        watchChanges: false

        onLoaded: {
            // if (this.path !== root.targetedCacheThemeFile) {
            //     console.warn("Ignoring stale cache load for:", this.path);
            //     return; // تجاهل هذه النتيجة لأنها قديمة
            // }
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
            if (this.path !== root.targetedCacheThemeFile) {
                console.warn("Ignoring stale cache load for:", this.path);
                return; // تجاهل هذه النتيجة لأنها قديمة
            }
            console.info("Cache file not found. It will be created with default values.");
            root._cacheAppliedData();
        }
    }

    // 6.2. عامل جلب الخلفيات (Wallpaper Fetcher Process)

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
        interval: 2000
        repeat: false
        onTriggered: {
            root._applyAccentColor();
            root._applyAccentColor();
        }
    }

    Timer {
        id: startUpTimer
        interval: 1000
        repeat: false
        onTriggered: {
            sessionLoader.path = App.themeCacheFilePath;
        }
    }

    Timer {
        id: sendChangedSignalTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root._cacheAppliedData();
            root.selectedThemeUpdated();
        }
    }
}
