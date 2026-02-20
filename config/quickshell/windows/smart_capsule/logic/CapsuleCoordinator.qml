// windows/smart_capsule/logic/CapsuleCoordinator.qml
pragma Singleton

import QtQuick
import Quickshell
import "root:/services"
import "root:/config"
import "root:/themes"
import "root:/config/ConstValues.js" as C

Singleton {
    id: root

    // ========================================================================
    // ⚙️ Configuration (Timeouts & Thresholds)
    // ========================================================================
    property int _musicEyeReactDuration: 2000
    property int _musicAnalysisTimeout: 6000
    property int _musicBasicInfoTimeout: 3000

    property int _sysOsdTimeout: 2000
    property int _sysEyeReactDuration: 1000

    property int _weatherTimeout: 6000
    property int _weatherWinkDuration: 700

    property int _batChargingTimeout: 3000
    property int _batLevelWarning: 25
    property int _batLevelLow: 20
    property int _batLevelCritical: 10
    property int _batLevelDying: 5

    property int _batTimeoutWarning: 4000
    property int _batTimeoutCritical: 6000
    property int _batTimeoutDying: 8000

    property int _resourceAlertTimeout: 5000

    // ========================================================================
    // 🔒 Internal State
    // ========================================================================
    property int _lastAlertLevel: -1
    readonly property int currentPriority: CapsuleManager.currentPriority

    // ========================================================================
    // 🔌 Service Connections
    // ========================================================================

    // --- Music ---
    Connections {
        target: MusicService
        function onFullInfoChanged() {
            if (MusicService.isPlaying) {
                root.updateEyes("happy", root._musicEyeReactDuration);
                root.notifyBasicMusicInfo();
            }
        }
        function onAnalysisCompleted(emotion, comment, tags) {
            root.handleMusicAnalysis(emotion, comment, tags);
        }

        // function onResumeCommentReceived(emotion, comment) {
        //     console.info("Coordinator: Resume Comment -> " + emotion);
        //     root.handleMusicAnalysis(emotion, comment);
        // }
    }

    Binding {
        target: EyeController
        property: "isMusicPlaying"
        value: MusicService.isPlaying
    }

    // --- System ---
    Connections {
        target: SystemService
        function onBrightnessChanged() {
            root.handleBrightnessChange();
        }
        function onVolumeChanged() {
            root.handleVolumeChange();
        }
        function onIsChargingChanged() {
            root.handleChargingState();
        }
        function onBatteryPercentChanged() {
            root.monitorBatteryDischarge();
        }
        function onBootAnalysisStatusChanged() {
            root.handleBootAnalysisStatus();
        }
        function onCpuAlert(value) {
            root.handleResourceAlert("CPU", value, App.playCpuAlarmSound);
        }
        function onRamAlert(value) {
            root.handleResourceAlert("RAM", value, App.playRamAlarmSound);
        }
        function onCurrentLayoutChanged() {
            root.handleLayoutChanged();
        }
    }

    // --- Weather ---
    Connections {
        target: Weather
        function onAiAnalysisCompleted(aiData) {
            root.handleWeatherUpdate(aiData);
        }
    }

    // --- Todo ---
    Connections {
        target: TodoService
        function onTaskDue(task) {
            root.handleTodoDue(task);
        }
        function onStartupSummaryReady(summary) {
            root.handleTodoStartupSummary(summary);
        }
    }

    // --- Themes & Wallpapers ---
    Connections {
        target: ThemeManager

        // عند تغيير الثيم بالكامل
        // function onSelectedThemeUpdated() {
        //     if (ThemeManager.selectedTheme) {
        //         root.handleThemeUpdate(ThemeManager.selectedTheme.themeName);
        //     }
        // }

        // عند تغيير الخلفية
        function onWallpaperChanged(path) {
            root.handleWallpaperChange(path);
        }

        // عند بدء معالجة صورة العمق (Depth Effect)
        function onCreatingOverlayImageStarted() {
            root.handleDepthEffectStatus("processing");
        }

        // عند الانتهاء من معالجة صورة العمق
        function onCreatingOverlayImageFinished(path) {
            root.handleDepthEffectStatus("finished");
        }

        // عند تنظيف الكاش
        function onUnusedCachedOverlayImagesDeleted() {
            root.handleThemeCacheCleaned();
        }

        // مراقبة أخطاء التحميل
        function onWallpaperDownloadError(errorDetails) {
            root.handleThemeError("Download Failed", errorDetails);
        }
    }

    // ========================================================================
    // 🧠 Core Logic Handlers (Public for Testing)
    // ========================================================================

    // 1. Weather Logic
    function handleWeatherUpdate(aiData) {
        console.info("Coordinator: Handling Weather Data. Urgent: " + aiData.urgent_alert);

        const emotion = aiData.ui.emotion;
        const ui = aiData.ui;
        const eyeDuration = (emotion === "wink") ? root._weatherWinkDuration : root._weatherTimeout;

        root.updateEyes(emotion, eyeDuration);

        const priority = aiData.urgent_alert ? C.WARNING : C.NOTIFICATION;
        const icon = aiData.urgent_alert ? "" : ui.icon;
        const tags = Weather.aiTags;

        CapsuleManager.request({
            priority: priority,
            source: C.SRC_WEATHER,
            icon: icon,
            text: aiData.smart_summary.summary_text,
            timeout: root._weatherTimeout,
            bgColor1: ui.bg_color1,
            bgColor2: ui.bg_color2,
            fgColor: ui.fg_color,
            tags: tags
        });
    }

    // 2. Music Logic
    function handleMusicAnalysis(emotion, comment, tags) {
        console.info("Coordinator: Handling Music AI Analysis -> " + emotion);

        root.updateEyes(emotion, root._musicAnalysisTimeout);

        let colors = getColorsForState("music");
        CapsuleManager.request({
            priority: C.NOTIFICATION,
            source: C.SRC_MUSIC,
            icon: "󰝚",
            text: comment,
            timeout: root._musicAnalysisTimeout,
            changeW: true,
            changeH: true,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            tags: tags,
            playTone: false
        });
    }

    // 2.5 Todo Logic
    function handleTodoDue(task) {
        if (!task || !task.title)
            return;

        const isUrgent = !!task.isUrgent;
        const stateType = isUrgent ? "warning" : "info";
        const priority = isUrgent ? C.WARNING : C.NOTIFICATION;
        const colors = getColorsForState(stateType);

        root.updateEyes(isUrgent ? "focused" : "thinking", 2500);

        CapsuleManager.request({
            priority: priority,
            source: C.SRC_TODO,
            icon: "󰄳",
            text: `Task due: ${task.title}`,
            timeout: 5000,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            tags: task.isUrgent ? ["Urgent"] : []
        });
    }

    function handleTodoStartupSummary(summary) {
        if (!summary || !summary.summary)
            return;

        if (currentPriority > C.IDLE)
            return;

        let colors = getColorsForState("info");
        root.updateEyes("thinking", 3500);

        CapsuleManager.request({
            priority: C.NOTIFICATION,
            source: C.SRC_TODO,
            icon: "󰄳",
            text: summary.summary,
            timeout: 6000,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            tags: summary.tags || [],
            changeH: true
        });
    }

    function notifyHoverExtra(text, emotion) {
        if (!text || text === "")
            return;
        root.updateEyes(emotion || "thinking", 1500);
        CapsuleManager.request({
            priority: C.NOTIFICATION,
            source: C.SRC_MUSIC,
            icon: "󰒋",
            text: text,
            timeout: 3500,
            changeW: true,
            changeH: false,
            playTone: false
        });
    }

    function notifyBasicMusicInfo() {
        let colors = getColorsForState("music");
        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: C.SRC_MUSIC,
            icon: "󰝚",
            text: MusicService.fullInfo,
            timeout: root._musicBasicInfoTimeout,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            playTone: false
        });
    }

    // 3. System Handlers
    function handleBrightnessChange() {
        if (currentPriority <= C.TRANSIENT) {
            root.updateEyes("focused", root._sysEyeReactDuration);
        }
        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: C.SRC_SYSTEM,
            icon: SystemService.brightnessIcon,
            text: `${Math.round(SystemService.brightness * 100)}%`,
            progress: SystemService.brightness,
            withProgress: true,
            timeout: root._sysOsdTimeout,
            changeW: false
        });
    }

    function handleLayoutChanged() {
        let layoutName = SystemService.currentLayout || "Unknown";

        root.updateEyes("wink", root._sysEyeReactDuration);

        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: C.SRC_SYSTEM,
            icon: "󰌌",
            text: "Layout: " + layoutName,
            timeout: root._sysOsdTimeout,
            // bgColor1: colors.bg1,
            // bgColor2: colors.bg2,
            // fgColor: colors.fg,
            changeH: false
            // playTone: true,
            // tone: App.assets.audio.notifySoft
        });
    }

    function handleVolumeChange() {
        // if (currentPriority <= C.TRANSIENT) {
        //     root.updateEyes("wink", root._sysEyeReactDuration);
        // }
        let colors = getColorsForState("info");
        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: C.SRC_SYSTEM,
            icon: SystemService.volumeIcon,
            text: `${Math.round(SystemService.volume * 100)}%`,
            progress: SystemService.volume,
            withProgress: true,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            timeout: root._sysOsdTimeout,
            changeW: false,
            playTone: true,
            tone: App.assets.audio.notifySoft
        });
    }

    function handleChargingState() {
        if (SystemService.isCharging) {
            // --- حالة توصيل الشاحن ---
            root._lastAlertLevel = -1;

            if (currentPriority <= C.TRANSIENT)
                root.updateEyes("happy", 4000);

            let colors = getColorsForState("success");
            CapsuleManager.request({
                priority: C.NOTIFICATION,
                source: C.SRC_BATTERY,
                icon: SystemService.batteryIcon,
                text: `Charging: ${Math.round(SystemService.batteryPercent * 100)}%`,
                bgColor1: colors.bg1,
                bgColor2: colors.bg2,
                fgColor: colors.fg,
                timeout: root._batChargingTimeout,
                playTone: true,
                tone: App.assets.audio.powerConnect
            });
        } else {
            // --- حالة فصل الشاحن ---
            if (currentPriority <= C.TRANSIENT)
                root.updateEyes("suspicious", 3000);

            let colors = getColorsForState("info");
            CapsuleManager.request({
                priority: C.NOTIFICATION,
                source: C.SRC_BATTERY,
                icon: SystemService.batteryIcon,
                text: `Power Disconnected: ${Math.round(SystemService.batteryPercent * 100)}%`,
                bgColor1: colors.bg1,
                bgColor2: colors.bg2,
                fgColor: colors.fg,
                timeout: root._batChargingTimeout
                // playTone: true,
                // tone: App.assets.audio.powerDisconnect
            });

            // التحقق فوراً من مستوى البطارية في حال فصلنا الشاحن والبطارية منخفضة جداً
            monitorBatteryDischarge();
        }
    }

    function monitorBatteryDischarge() {
        if (SystemService.isCharging) {
            root._lastAlertLevel = -1;
            return;
        }
        const currentPct = Math.round(SystemService.batteryPercent * 100);
        // نمرر القيمة للدالة المنطقية
        _checkBatteryLevel(currentPct);
    }

    // دالة داخلية للتحقق من المستويات (تم فصلها لتسهيل القراءة)
    function _checkBatteryLevel(currentPct) {
        const alertLevels = [40, 30, 23, 22, 21, 20, 15, 10, 8, 7, 6, 5, 4, 3];

        if (root._lastAlertLevel === -1) {
            root._lastAlertLevel = currentPct;
            if (currentPct <= root._batLevelLow)
                triggerBatteryAlert(currentPct);
            return;
        }

        for (let i = 0; i < alertLevels.length; i++) {
            let lvl = alertLevels[i];
            if (currentPct <= lvl && root._lastAlertLevel > lvl) {
                root._lastAlertLevel = lvl;
                triggerBatteryAlert(lvl);
                break;
            }
        }
        if (currentPct < root._lastAlertLevel)
            root._lastAlertLevel = currentPct;
    }

    function triggerBatteryAlert(level) {
        let alertType = "info";
        let priority = C.NOTIFICATION;
        let msg = `Battery at ${level}%`;
        let emotion = "bored";
        let timeout = root._batTimeoutWarning;
        let tone = App.assets.audio.smartCapsuleWarning;

        if (level <= root._batLevelWarning) {
            alertType = "warning";
            emotion = "suspicious";
            tone = App.assets.audio.batteryLow;
        }
        if (level <= root._batLevelLow) {
            alertType = "warning";
            emotion = "sad";
            priority = C.WARNING;
            msg = `Low Battery (${level}%). Please plug in.`;
            tone = App.assets.audio.batteryLow;
        }
        if (level <= root._batLevelCritical) {
            alertType = "critical";
            emotion = "shocked";
            priority = C.CRITICAL;
            msg = `Critical Battery (${level}%)!`;
            timeout = root._batTimeoutCritical;
            tone = App.assets.audio.smartCapsuleWarning;
        }
        if (level <= root._batLevelDying) {
            alertType = "critical";
            emotion = "dead";
            priority = C.CRITICAL;
            msg = `Battery Dying (${level}%)... Goodbye?`;
            timeout = root._batTimeoutDying;
            tone = App.assets.audio.smartCapsuleCritical;
        }

        let colors = getColorsForState(alertType);
        root.updateEyes(emotion, timeout);

        CapsuleManager.request({
            priority: priority,
            source: C.SRC_BATTERY,
            icon: SystemService.batteryIcon,
            text: msg,
            progress: level / 100.0,
            withProgress: true,
            timeout: timeout,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            tone: tone
        });
    }

    function handleResourceAlert(type, value, playTone) {
        var pct = Math.round(value * 100);

        var isCritical = pct >= 95;

        var icon = "";
        var title = "";
        var emotion = "";

        if (type === "CPU") {
            icon = "";
            title = "High CPU Load";
            emotion = isCritical ? "shocked" : "focused";
        } else {
            icon = "";
            title = "High Memory Usage";
            emotion = isCritical ? "sad" : "confused";
        }

        var stateType = isCritical ? "critical" : "warning";
        var priority = isCritical ? C.CRITICAL : C.WARNING;
        var colors = getColorsForState(stateType);

        console.warn(`Coordinator: ${type} Alert! Usage: ${pct}%`);

        root.updateEyes(emotion, root._resourceAlertTimeout);

        CapsuleManager.request({
            priority: priority,
            source: C.SRC_SYSTEM,
            icon: icon,
            text: `${title}: ${pct}%`,
            progress: value,
            withProgress: true,
            changeH: false,
            timeout: root._resourceAlertTimeout,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            playTone: playTone
        });
    }

    function handleBootAnalysisStatus() {
        const status = SystemService.bootAnalysisStatus;

        if (status === "IDLE")
            return;

        if (status === "LOADING") {
            root.updateEyes("thinking", 3000);
            let colors = getColorsForState("info");
            CapsuleManager.request({
                priority: C.TRANSIENT,
                source: C.SRC_SYSTEM,
                icon: "󰞌",
                text: "Analyzing boot logs...",
                timeout: 3000,
                bgColor1: colors.bg1,
                bgColor2: colors.bg2,
                fgColor: colors.fg,
                changeH: false,
                playTone: false
            });
            return;
        }

        if (status === "SUCCESS") {
            let stateType = "success";
            const rawColor = (SystemService.bootStatusColor || "").toString().toLowerCase();
            if (rawColor === "red")
                stateType = "critical";
            else if (rawColor === "orange" || rawColor === "yellow")
                stateType = "warning";

            let colors = getBootColors();
            root.updateEyes(getBootEmotion(stateType), 4000);

            let summary = SystemService.aiBootSummary || "Boot analysis ready.";
            if (SystemService.bootTimeText && SystemService.bootTimeText !== "--")
                summary = `${summary} (${SystemService.bootTimeText})`;

            CapsuleManager.request({
                priority: stateType === "critical" ? C.WARNING : C.NOTIFICATION,
                source: C.SRC_SYSTEM,
                icon: SystemService.bootStatusIcon || "",
                text: summary,
                timeout: 5000,
                bgColor1: colors.bg1,
                bgColor2: colors.bg2,
                fgColor: colors.fg,
                changeH: true,
                playTone: false
            });
            return;
        }

        if (status === "ERROR") {
            let colors = getBootColors();
            root.updateEyes("sad", 4000);
            CapsuleManager.request({
                priority: C.WARNING,
                source: C.SRC_SYSTEM,
                icon: "󰞌",
                text: "Boot analysis failed. Try again later.",
                timeout: 5000,
                bgColor1: colors.bg1,
                bgColor2: colors.bg2,
                fgColor: colors.fg,
                changeH: true,
                playTone: false
            });
        }
    }

    function getBootEmotion(stateType) {
        if (stateType === "critical")
            return "shocked";
        if (stateType === "warning")
            return "focused";
        if (stateType === "success")
            return "happy";
        return "thinking";
    }

    function handleThemeUpdate(themeName) {
        root.updateEyes("happy", 3000);
        let colors = getColorsForState("theme_applied"); // سنضيف هذه الحالة في Helpers

        CapsuleManager.request({
            priority: C.NOTIFICATION,
            source: C.SRC_SYSTEM,
            icon: "󰔎",
            text: "Theme Applied: " + themeName,
            timeout: 1000,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            playTone: false,
            changeH: false
        });
    }

    function handleWallpaperChange(path) {
        // نستخرج اسم الملف فقط من المسار الكامل
        let filename = path.split('/').pop();
        root.updateEyes("wink", 1500);

        let colors = getColorsForState("info");
        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: C.SRC_SYSTEM,
            icon: "󰸉",
            text: "Wallpaper: " + filename,
            timeout: 3000,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            playTone: false,
            changeH: false
        });
    }

    function handleDepthEffectStatus(status) {
        if (status === "processing") {
            root.updateEyes("focused", 100000);
            CapsuleManager.request({
                priority: C.NOTIFICATION,
                source: C.SRC_SYSTEM,
                icon: "󰉔",
                text: "Generating Depth Effect...",
                timeout: 100000,
                bgColor1: "#4527A0",
                bgColor2: "#7B1FA2",
                fgColor: "#FFFFFF"
            });
        } else {
            root.updateEyes("happy", 3000);
            CapsuleManager.request({
                priority: C.NOTIFICATION,
                source: C.SRC_SYSTEM,
                icon: "󰉓",
                text: "Depth Effect Ready!",
                timeout: 3000,
                bgColor1: "#2E7D32",
                bgColor2: "#43A047",
                fgColor: "#FFFFFF"
            });
        }
    }

    function handleThemeCacheCleaned() {
        root.updateEyes("bored", 2000);
        CapsuleManager.request({
            priority: C.TRANSIENT,
            source: C.SRC_SYSTEM,
            icon: "󰃢",
            text: "Theme Cache Cleaned",
            timeout: 3000,
            playTone: false,
            changeH: false
        });
    }

    function handleThemeError(title, details) {
        root.updateEyes("dead", 4000);
        let colors = getColorsForState("critical");
        CapsuleManager.request({
            priority: C.WARNING,
            source: C.SRC_SYSTEM,
            icon: "󰚌",
            text: title + ": " + details,
            timeout: 5000,
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg,
            playTone: false,
            changeH: false
        });
    }

    // ========================================================================
    // 🛠️ Helpers
    // ========================================================================
    function updateEyes(emotion, duration) {
        if (typeof EyeController !== "undefined") {
            EyeController.showEmotion(emotion, duration);
        }
    }

    function getColorsForState(state) {
        switch (state) {
        case "critical":
            return {
                bg1: "#B00020",
                bg2: "#D32F2F",
                fg: "#FFFFFF"
            };
        case "warning":
            return {
                bg1: "#FF9800",
                bg2: "#FFC107",
                fg: "#000000"
            };
        case "success":
            return {
                bg1: "#00695C",
                bg2: "#2E7D32",
                fg: "#FFFFFF"
            };
        case "info":
            return {
                bg1: "#0277BD",
                bg2: "#0091EA",
                fg: "#FFFFFF"
            };
        case "ai":
            return {
                bg1: "#6200EA",
                bg2: "#7C4DFF",
                fg: "#FFFFFF"
            };
        case "music":
            return {
                bg1: "#880E4F",
                bg2: "#1A237E",
                fg: "#FFFFFF"
            };
        case "theme_applied":
            return {
                // نستخدم ألوان الثيم الجديد مباشرة
                bg1: ThemeManager.selectedTheme.colors.primary,
                bg2: ThemeManager.selectedTheme.colors.secondary,
                fg: ThemeManager.selectedTheme.colors.onPrimary
            };
        default:
            return {
                bg1: ThemeManager.selectedTheme.colors.primary,
                bg2: ThemeManager.selectedTheme.colors.secondary,
                fg: ThemeManager.selectedTheme.colors.onPrimary
            };
        }
    }

    function getBootColors() {
        const raw = (SystemService.bootStatusColor || "").toString().toLowerCase();
        if (raw.startsWith("#")) {
            return {
                bg1: raw,
                bg2: raw,
                fg: "#FFFFFF"
            };
        }
        if (raw === "red")
            return getColorsForState("critical");
        if (raw === "orange" || raw === "yellow")
            return getColorsForState("warning");
        if (raw === "green")
            return getColorsForState("success");
        return getColorsForState("info");
    }
}
