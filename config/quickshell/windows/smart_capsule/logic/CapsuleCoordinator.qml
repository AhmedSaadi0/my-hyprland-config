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
    property int _musicAnalysisTimeout: 10000
    property int _musicBasicInfoTimeout: 3000

    property int _sysOsdTimeout: 2000
    property int _sysEyeReactDuration: 1000

    property int _weatherTimeout: 8000
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
        function onCpuAlert(value) {
            root.handleResourceAlert("CPU", value, App.playCpuAlarmSound);
        }
        function onRamAlert(value) {
            root.handleResourceAlert("RAM", value, App.playRamAlarmSound);
        }
    }

    // --- Weather ---
    Connections {
        target: Weather
        function onAiAnalysisCompleted(aiData) {
            root.handleWeatherUpdate(aiData);
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
            changeW: false
        });
    }

    function handleChargingState() {
        if (SystemService.isCharging) {
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
                timeout: root._batChargingTimeout
            });
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

        if (level <= root._batLevelWarning) {
            alertType = "warning";
            emotion = "suspicious";
            priority = C.WARNING;
        }
        if (level <= root._batLevelLow) {
            alertType = "warning";
            emotion = "sad";
            msg = `Low Battery (${level}%). Please plug in.`;
        }
        if (level <= root._batLevelCritical) {
            alertType = "critical";
            emotion = "shocked";
            priority = C.CRITICAL;
            msg = `Critical Battery (${level}%)!`;
            timeout = root._batTimeoutCritical;
        }
        if (level <= root._batLevelDying) {
            alertType = "critical";
            emotion = "dead";
            msg = `Battery Dying (${level}%)... Goodbye?`;
            timeout = root._batTimeoutDying;
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
            fgColor: colors.fg
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
        default:
            return {
                bg1: ThemeManager.selectedTheme.colors.primary,
                bg2: ThemeManager.selectedTheme.colors.secondary,
                fg: ThemeManager.selectedTheme.colors.onPrimary
            };
        }
    }
}
