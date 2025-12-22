pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "root:/config"
import "root:/themes/modules"
import "root:/themes"

Singleton {
    id: root

    // =========================================================
    // Public API
    // =========================================================
    property bool _initialReady: false
    readonly property alias selectedTheme: loader.activeThemeInstance
    readonly property alias currentWallpaper: wallpaperCtrl.currentWallpaperPath
    readonly property bool isInitialThemeReady: _initialReady

    signal selectedThemeUpdated
    signal initialThemeReady

    // =========================================================
    // Internal State for Sequence Control
    // =========================================================
    // لتخزين بيانات الكاش مؤقتاً قبل إنشاء الثيم
    property var _pendingCacheData: null
    // لتخزين اسم الثيم المطلوب بينما ننتظر الكاش
    property string _pendingThemeName: ""

    // =========================================================
    // Modules
    // =========================================================
    ThemeLoader {
        id: loader
        onThemeLoaded: themeInstance => {
            // المرحلة 4: تم إنشاء الكائن الخام
            console.info("[ThemeManager] Phase 4: Theme Object Created");

            // المرحلة 5: الحقن في الذاكرة (Hydration)
            if (root._pendingCacheData) {
                console.info("[ThemeManager] Phase 5: Injecting cached data into memory...");
                serializer.applyData(themeInstance, root._pendingCacheData);
            } else {
                console.info("[ThemeManager] Phase 5: No cache data found, using defaults.");
            }

            // المرحلة 6: التطبيق مرة واحدة فقط (Single Source of Truth)
            _applyToSystem(themeInstance);

            // حفظ الجلسة
            sessionSaver.setText(JSON.stringify({
                activeThemeName: loader.currentThemeName
            }));

            // تنظيف
            root._pendingCacheData = null;
            root._pendingThemeName = "";

            // إعلام الواجهة
            root.selectedThemeUpdated();

            if (!_initialReady) {
                console.info("[ThemeManager] System Ready.");
                _initialReady = true;
                root.initialThemeReady();
            }
        }
    }

    WallpaperController {
        id: wallpaperCtrl
        onWallpaperReady: path => {
            if (selectedTheme && selectedTheme.systemSettings.enableDynamicColoring) {
                sysBridge.applyM3(path, selectedTheme.systemSettings.themeMode, true);
            }
        }
    }

    HyprlandBridge {
        id: hyprBridge
    }
    SystemBridge {
        id: sysBridge
    }
    ThemeSerializer {
        id: serializer
    }

    // =========================================================
    // Core Logic: The Sequence Manager
    // =========================================================

    function requestLoadTheme(themeName) {
        if (themeName === loader.currentThemeName && _initialReady)
            return;

        console.info(`[ThemeManager] Phase 1: Request received for ${themeName}`);

        // إعداد المتغيرات
        root._pendingThemeName = themeName;
        root._pendingCacheData = null;

        // ضبط مسار الكاش لبدء القراءة
        const cachePath = App.themeCacheFolderPath + `/${themeName}.json`;

        // خدعة لضمان إعادة قراءة الملف حتى لو كان المسار نفسه (في حال تغير المحتوى خارجياً)
        if (cacheFile.path === cachePath) {
            cacheFile.path = "";
        }
        cacheFile.path = cachePath;

        // بدء مؤقت الأمان (Safety Timeout)
        // في حال لم يستجب FileView (الملف غير موجود)، نكمل بعد فترة قصيرة
        cacheTimeoutTimer.restart();
    }

    // يتم استدعاؤه عندما ينتهي FileView من القراءة
    function _onCacheFileReady(content) {
        // إيقاف مؤقت الأمان لأننا حصلنا على رد
        cacheTimeoutTimer.stop();

        console.info("[ThemeManager] Phase 2: Cache File Check Complete.");

        if (content && content.trim() !== "") {
            try {
                let json = JSON.parse(content);
                // التأكد من أن الكاش يخص الثيم المطلوب
                if (json.themeName === root._pendingThemeName) {
                    root._pendingCacheData = json;
                    console.info("[ThemeManager] Valid cache found.");
                }
            } catch (e) {
                console.warn("[ThemeManager] Cache corrupted, ignoring.");
            }
        }

        // المرحلة 3: البدء الفعلي لتحميل الثيم
        console.info(`[ThemeManager] Phase 3: Instructing Loader to load ${root._pendingThemeName}`);
        loader.loadTheme(root._pendingThemeName);
    }

    // =========================================================
    // Helper Functions
    // =========================================================

    function updateAndApplyTheme(data, saveToDisk) {
        if (!selectedTheme)
            return;

        // تعديل مباشر
        serializer.applyData(selectedTheme, data);
        _applyToSystem(selectedTheme);

        if (saveToDisk) {
            serializer.saveToCache(selectedTheme, loader.currentThemeName, true);
        }
        root.selectedThemeUpdated();
    }

    function _applyToSystem(theme) {
        console.info("[ThemeManager] Applying Final Configuration...");
        hyprBridge.applyConfig(theme.hyprlandConfiguration);
        sysBridge.applySystemTheme(theme.systemSettings, theme.colors, theme.typography);
        wallpaperCtrl.configure(theme.systemSettings);
    }

    function getCurrentWallpaper() {
        return wallpaperCtrl.currentWallpaperPath;
    }
    function switchToNextWallpaper() {
        wallpaperCtrl.nextWallpaper();
    }
    function reloadTheme() {
        requestLoadTheme(loader.currentThemeName);
    }

    // =========================================================
    // Initialization & I/O
    // =========================================================

    Component.onCompleted: {
        // لا نحمل شيئاً فوراً، ننتظر تحميل الجلسة
        startTimer.start();
    }

    Timer {
        id: startTimer
        interval: 50 // تأخير بسيط جداً للسماح لـ FileView بالتهيئة
        repeat: false
        onTriggered: {
            console.info("[ThemeManager] Startup: Reading Session...");
            try {
                let txt = sessionLoader.text();
                let session = JSON.parse(txt);
                let target = session.activeThemeName || "ColorsTheme";
                requestLoadTheme(target);
            } catch (e) {
                console.warn("[ThemeManager] Session missing or invalid. Loading default.");
                requestLoadTheme("ColorsTheme");
            }
        }
    }

    // مؤقت الأمان: إذا لم نجد ملف الكاش خلال 200ms، نعتبره غير موجود ونكمل
    Timer {
        id: cacheTimeoutTimer
        interval: 200
        repeat: false
        onTriggered: {
            console.warn("[ThemeManager] Cache lookup timed out (File likely missing). Proceeding with defaults.");
            _onCacheFileReady(""); // نرسل نصاً فارغاً لنكمل العملية
        }
    }

    FileView {
        id: sessionLoader
        path: App.themeCacheFilePath
    }

    FileView {
        id: sessionSaver
        path: App.themeCacheFilePath
        watchChanges: false
    }

    FileView {
        id: cacheFile
        watchChanges: false

        // عندما يتغير المسار وينتهي التحميل
        onLoaded: {
            // نتأكد أننا في منتصف عملية تحميل (لنتجنب الاستدعاءات العشوائية)
            if (root._pendingThemeName !== "") {
                _onCacheFileReady(text());
            }
        }
    }
}
