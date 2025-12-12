// windows/smart_capsule/logic/CapsuleManager.qml
pragma Singleton

import QtQuick
import Quickshell
import "root:/services"
import "root:/config"
import "root:/themes"
import "root:/config/ConstValues.js" as C
import "root:/utils/helpers.js" as Helper

Singleton {
    id: root

    // --- State ---
    property int currentPriority: C.IDLE
    property string activeSource: ""

    property string displayIcon: ""
    property string displayText: ""
    property real progressValue: 0.0
    property bool showProgress: false
    property bool changeWidth: true
    property bool changeHeight: false

    property color bgColor1: ThemeManager.selectedTheme.colors.primary
    property color bgColor2: ThemeManager.selectedTheme.colors.secondary
    property color fgColor: ThemeManager.selectedTheme.colors.onPrimary

    property var _timer: Timer {
        interval: 4000 // Default timeout
        repeat: false
        onTriggered: root.reset()
    }

    // --- Core Function ---
    function request({
        priority,
        source,
        icon,
        text,
        progress = null,
        withProgress = false,
        timeout = 4000,
        changeW = true,
        changeH = null,
        playTone = true,
        bgColor1 = ThemeManager.selectedTheme.colors.primary,
        bgColor2 = ThemeManager.selectedTheme.colors.secondary,
        fgColor = ThemeManager.selectedTheme.colors.onPrimary
    }) {
        if (priority >= currentPriority || currentPriority === C.IDLE) {
            currentPriority = priority;
            activeSource = source;
            displayIcon = icon;
            displayText = text;
            progressValue = progress;
            showProgress = withProgress;
            changeWidth = changeW;
            root.bgColor1 = bgColor1;
            root.bgColor2 = bgColor2;
            root.fgColor = fgColor;

            if (priority > C.TRANSIENT) {
                changeHeight = changeH ? changeH : true;
            } else {
                changeHeight = false;
            }

            _timer.stop();
            if (timeout > 0) {
                _timer.interval = timeout;
                _timer.start();
            }

            if (playTone) {
                playSmartCapsuleTone(priority);
            }
        }
    }

    NibrasShellShortcut {
        id: testCapsule
        name: "testCapsule"
        onPressed: {
            // --- 1. قائمة النصوص (قصير، متوسط، وطويل جداً لاختبار الارتفاع) ---
            const texts = ["تم الاتصال بالشبكة بنجاح.", "جاري تحميل الملف: 45% المتبقي 3 دقائق...", "تنبيه: البطارية منخفضة (15%)، يرجى توصيل الشاحن للحفاظ على العمل.", "رسالة جديدة من أحمد: 'هل يمكننا الاجتماع غداً لمناقشة تحديثات واجهة المستخدم الجديدة؟'", "عاجل: تحذير من عاصفة رعدية قوية تقترب من منطقتك خلال الساعة القادمة. يرجى البقاء في الداخل والابتعاد عن النوافذ.", "تحديث النظام: يتوفر إصدار جديد من نبراس (v2.0). يتضمن تحسينات في الأداء وإصلاحات للأخطاء. اضغط للتثبيت."];

            // --- 2. قائمة الألوان (تدرجات متناسقة) ---
            const colorThemes = [
                {
                    bg1: "#FF512F",
                    bg2: "#DD2476",
                    fg: "#FFFFFF",
                    name: "Red/Pink Warning"
                } // تحذير
                ,
                {
                    bg1: "#11998e",
                    bg2: "#38ef7d",
                    fg: "#000000",
                    name: "Green Success"
                }    // نجاح
                ,
                {
                    bg1: "#8E2DE2",
                    bg2: "#4A00E0",
                    fg: "#FFFFFF",
                    name: "Purple AI"
                }        // ذكاء اصطناعي
                ,
                {
                    bg1: "#F2994A",
                    bg2: "#F2C94C",
                    fg: "#000000",
                    name: "Orange Alert"
                }     // تنبيه
                ,
                {
                    bg1: "#2193b0",
                    bg2: "#6dd5ed",
                    fg: "#000000",
                    name: "Blue Info"
                }         // معلومة
            ];

            // --- 3. قائمة الأيقونات ---
            const icons = ["", "", "", "", "", ""];

            // --- 4. قائمة مشاعر العيون ---
            const emotions = ["happy", "sad", "shocked", "suspicious", "sleeping", "thinking"];

            // --- الاختيار العشوائي ---
            const randomText = texts[Math.floor(Math.random() * texts.length)];
            const randomTheme = colorThemes[Math.floor(Math.random() * colorThemes.length)];
            const randomIcon = icons[Math.floor(Math.random() * icons.length)];
            const randomEmotion = emotions[Math.floor(Math.random() * emotions.length)];

            // تحديد الأولوية بناءً على اللون (مجرد منطق لربط اللون بالصوت)
            let priorityLevel = C.NOTIFICATION;
            if (randomTheme.name.includes("Warning") || randomTheme.name.includes("Alert")) {
                priorityLevel = C.WARNING;
            }

            console.info(`Test Capsule: [${randomTheme.name}] - Text Length: ${randomText.length}`);

            // --- التنفيذ ---
            request({
                priority: priorityLevel,
                source: C.SRC_SYSTEM // مصدر وهمي
                ,
                icon: randomIcon,
                text: randomText,
                timeout: 5000 // 5 ثواني
                ,
                bgColor1: randomTheme.bg1,
                bgColor2: randomTheme.bg2,
                fgColor: randomTheme.fg,
                playTone: true
            });

            // تغيير العيون
            if (typeof EyeController !== "undefined") {
                EyeController.showEmotion(randomEmotion, 5000);
            }
        }
    }

    function playSmartCapsuleTone(priority) {
        const nibrasAudio = App.assets.audio;
        if (priority == C.NOTIFICATION) {
            nibrasAudio.playTone(nibrasAudio.smartCapsuleNotification);
        } else if (priority == C.WARNING) {
            nibrasAudio.playTone(nibrasAudio.smartCapsuleWarning);
        } else if (priority == C.CRITICAL) {
            nibrasAudio.playTone(nibrasAudio.smartCapsuleCritical);
        }
    }

    // --- Reset Function ---
    function reset() {
        currentPriority = C.IDLE;
        activeSource = "";
        showProgress = false;
        changeWidth = true;
        changeHeight = false;

        bgColor1 = ThemeManager.selectedTheme.colors.primary;
        bgColor2 = ThemeManager.selectedTheme.colors.secondary;
        fgColor = ThemeManager.selectedTheme.colors.onPrimary;
    }

    // ========================================================================
    // 1. Music Service Monitor
    // ========================================================================
    property var _musicConn: Connections {
        target: MusicService

        // --== FIXED SYNTAX ==--
        function onFullInfoChanged() {
            if (MusicService.isPlaying) {
                notifyMusic();
            }
        }

        // --== FIXED SYNTAX ==--
        function onIsPlayingChanged() {
            if (MusicService.isPlaying) {
                notifyMusic();
            }
        }
    }

    function notifyMusic() {
        request({
            priority: C.TRANSIENT,
            source: C.SRC_MUSIC,
            icon: "󰝚",
            text: MusicService.fullInfo,
            timeout: 3000
        });
    }

    // ========================================================================
    // 2. System Service Monitor (Volume, Brightness, Battery)
    // ========================================================================
    property var _systemConn: Connections {
        target: SystemService

        // --== FIXED SYNTAX ==--
        function onVolumeChanged() {
            request({
                priority: C.TRANSIENT,
                source: C.SRC_SYSTEM,
                icon: SystemService.volumeIcon,
                text: `${Math.round(SystemService.volume * 100)}%`,
                progress: SystemService.volume,
                withProgress: true,
                timeout: 2000
            });
        }

        // --== FIXED SYNTAX ==--
        function onBrightnessChanged() {
            request({
                priority: C.TRANSIENT,
                source: C.SRC_SYSTEM,
                icon: SystemService.brightnessIcon,
                text: `${Math.round(SystemService.brightness * 100)}%`,
                progress: SystemService.brightness,
                withProgress: true,
                timeout: 2000
            });
        }

        // --== FIXED SYNTAX ==--
        function onBatteryStateChanged() {
            if (SystemService.batteryState === 1) {
                // 1 = Charging
                request({
                    priority: C.WARNING,
                    source: C.SRC_BATTERY,
                    icon: SystemService.batteryIcon,
                    text: `Charging ${Math.round(SystemService.batteryPercent * 100)}%`,
                    progress: SystemService.batteryPercent,
                    withProgress: true,
                    timeout: 4000
                });
            }
        }
    }

    // ========================================================================
    // 3. Weather Service Monitor (The Smart Part)
    // ========================================================================
    property var _weatherConn: Connections {
        target: Weather

        function onAiAnalysisCompleted(aiData) {
            console.info("Smart capsule received AI weather data. Urgent: " + aiData.urgent_alert);

            const timeout = 8 * 1000;
            const emotion = aiData.ui.emotion;
            const bgColor1 = aiData.ui.bg_color1;
            const bgColor2 = aiData.ui.bg_color2;
            // const fgColor = Helper.getAccurteTextColor(bgColor);
            const fgColor = aiData.ui.fg_color;
            EyeController.showEmotion(emotion, timeout);

            const defaultAttrs = {
                text: aiData.smart_summary.summary_text,
                timeout: timeout,
                bgColor1: bgColor1,
                bgColor2: bgColor2,
                fgColor: fgColor
            };

            if (aiData.urgent_alert) {
                request({
                    priority: C.WARNING,
                    source: C.SRC_WEATHER,
                    icon: "",
                    text: aiData.smart_summary.summary_text,
                    timeout: timeout,
                    bgColor1: bgColor1,
                    bgColor2: bgColor2,
                    fgColor: fgColor
                });
            } else {
                request({
                    // Note: Changed to INFO so it doesn't override volume/brightness changes
                    priority: C.NOTIFICATION,
                    source: C.SRC_WEATHER,
                    icon: aiData.ui.icon,
                    text: aiData.smart_summary.summary_text,
                    timeout: timeout,
                    bgColor1: bgColor1,
                    bgColor2: bgColor2,
                    fgColor: fgColor
                });
            }
        }
    }
}
