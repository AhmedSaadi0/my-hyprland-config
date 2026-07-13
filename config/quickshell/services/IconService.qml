// services/IconService.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "root:/themes"
import "root:/config"
import "root:/utils"
import "root:/utils/IconCache.js" as IconCache

Singleton {
    id: root

    readonly property string currentTheme: (ThemeManager.selectedTheme && ThemeManager.selectedTheme.systemSettings) ? ThemeManager.selectedTheme.systemSettings.themeIcons : ""

    // Tracks the old theme for fallback during transition (prevents flicker)
    property string previousTheme: ""

    // Incremented after each resolve batch completes; components bind to this for reactivity
    property int iconUpdateTrigger: 0

    // أيقونة افتراضية bundle (لا تعتمد على KIconEngine / Quickshell.iconPath)
    readonly property string fallbackIconSource:
        Helper.toImageSource(App.assets.fallbackAppIcon)

    // Emitted when a batch resolve completes with the full icon map
    signal iconsResolved(var iconMap)

    // --- Public API ---

    function getCached(iconName) {
        if (!iconName || iconName === "")
            return root.fallbackIconSource;
        if (Helper.isDirectImageSource(iconName))
            return Helper.toImageSource(iconName);

        // 1. Try current (new) theme first
        if (currentTheme) {
            let cached = IconCache.get(iconName, currentTheme);
            if (cached)
                return cached;
        }

        // 2. Fall back to previous theme during transition (prevents flicker)
        if (previousTheme && previousTheme !== currentTheme) {
            let cached = IconCache.get(iconName, previousTheme);
            if (cached)
                return cached;
        }

        // 3. Fall back to bundled icon (تجنّب KIconEngine لتفادي SEGV)
        return root.fallbackIconSource;
    }

    function getCachedForTheme(iconName, themeName) {
        if (!iconName || iconName === "")
            return root.fallbackIconSource;
        if (Helper.isDirectImageSource(iconName))
            return Helper.toImageSource(iconName);
        if (themeName) {
            let cached = IconCache.get(iconName, themeName);
            if (cached)
                return cached;
        }
        return root.fallbackIconSource;
    }

    // إرجاع أسماء كل الأيقونات المخزنة لثيم معيّن
    function getAllForTheme(themeName) {
        return IconCache.getAllForTheme(themeName);
    }

    // Queue icons for batch resolution; they will be resolved after debounce
    function requestResolve(iconNames) {
        if (!iconNames || iconNames.length === 0)
            return;
        for (let i = 0; i < iconNames.length; i++) {
            let name = iconNames[i];
            if (name && pendingIcons.indexOf(name) === -1) {
                pendingIcons.push(name);
            }
        }
        resolveDebounce.restart();
    }

    // Force a full re-resolution (e.g. on theme change)
    function refreshAll() {
        pendingIcons = [];
        batchIconResolveTimer.restart();
    }

    // إعادة دفع كل أيقونات الثيم السابق إلى طابور الحل في الثيم الحالي
    // (تُستدعى من applyGuardTimer في ThemeManager بعد 500ms من تطبيق الثيم)
    function refreshForNewTheme() {
        let oldTheme = root.previousTheme;
        if (!oldTheme || oldTheme === root.currentTheme)
            return;
        let allIcons = IconCache.getAllForTheme(oldTheme);
        for (let i = 0; i < allIcons.length; i++) {
            if (root.pendingIcons.indexOf(allIcons[i]) === -1) {
                root.pendingIcons.push(allIcons[i]);
            }
        }
        if (root.pendingIcons.length > 0) {
            root.batchIconResolveTimer.restart();
        }
    }

    // --- Internal State ---

    property var pendingIcons: []
    property bool _applyingTheme: false

    // Debounce timer for requestResolve() calls
    Timer {
        id: resolveDebounce
        interval: 150
        repeat: false
        onTriggered: root._flushPendingIcons()
    }

    // Main batch resolve timer (used by refreshAll)
    Timer {
        id: batchIconResolveTimer
        interval: 100
        repeat: false
        onTriggered: root._flushPendingIcons()
    }

    Timer {
        id: retryTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (!batchIconResolver.running) {
                root._flushPendingIcons();
            } else {
                retryTimer.restart();
            }
        }
    }

    // تأجيل iconUpdateTrigger خارج QProcess::finished callback لتفادي SEGV
    // (KIconEngine يتفلتر إذا طُلب QIcon فوراً داخل QProcess::finished)
    Timer {
        id: deferTriggerTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (!root._applyingTheme)
                root.iconUpdateTrigger++;
        }
    }

    Process {
        id: batchIconResolver
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let parsed = JSON.parse(this.text.toString());
                    for (let iconKey in parsed) {
                        let path = parsed[iconKey];
                        if (path) {
                            IconCache.set(iconKey, root.currentTheme, Helper.toImageSource(path));
                        }
                    }
                    root.iconsResolved(parsed);
                } catch (e) {
                    console.warn("[IconService] Failed to parse batch icon resolver JSON:", e);
                } finally {
                    // Update previousTheme after batch completes (ready for next transition)
                    root.previousTheme = root.currentTheme;
                    // تأجيل تحديث الـ trigger خارج callback QProcess::finished
                    deferTriggerTimer.restart();
                }
            }
        }
    }

    Connections {
        target: ThemeManager
        // Capture old theme before it changes (called at start of requestLoadTheme)
        function onThemeLoadStarted(themeName) {
            void themeName;
            root.previousTheme = root.currentTheme;
        }
        // إعادة حلّ الأيقونات تتولاها applyGuardTimer في ThemeManager
        // (تطلق بعد 500ms من تطبيق الثيم للسماح لـ KIconEngine بالاستقرار أولاً)
        function onSelectedThemeUpdated() {
        }
        // Sync _applyingTheme مع حارس ThemeManager
        function onIsApplyingThemeChanged() {
            root._applyingTheme = ThemeManager.isApplyingTheme;
        }
    }

    function clearCache() {
        IconCache.clear();
    }

    function _flushPendingIcons() {
        if (!root.currentTheme)
            return;

        let uncachedIcons = [];
        for (let i = 0; i < root.pendingIcons.length; i++) {
            let iconKey = root.pendingIcons[i];
            if (!IconCache.get(iconKey, root.currentTheme)) {
                uncachedIcons.push(iconKey);
            }
        }

        root.pendingIcons = [];

        if (uncachedIcons.length === 0) {
            root.iconUpdateTrigger++;
            return;
        }

        if (batchIconResolver.running) {
            for (let j = 0; j < uncachedIcons.length; j++) {
                if (root.pendingIcons.indexOf(uncachedIcons[j]) === -1)
                    root.pendingIcons.push(uncachedIcons[j]);
            }
            retryTimer.restart();
            return;
        }

        batchIconResolver.command = [App.pythonPath, App.pythonScriptsPath + "/resolve_theme_icons.py", "--theme", root.currentTheme, "--icons-json", JSON.stringify(uncachedIcons)];
        batchIconResolver.running = true;
    }
}
