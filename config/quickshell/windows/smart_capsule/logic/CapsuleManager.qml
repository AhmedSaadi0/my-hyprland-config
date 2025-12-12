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
    property int _lastAlertLevel: -1

    property color bgColor1: ThemeManager.selectedTheme.colors.primary
    property color bgColor2: ThemeManager.selectedTheme.colors.secondary
    property color fgColor: ThemeManager.selectedTheme.colors.onPrimary

    Timer {
        id: _timer
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
                source: C.SRC_SYSTEM,
                icon: randomIcon,
                text: randomText,
                timeout: 5000,
                bgColor1: randomTheme.bg1,
                bgColor2: randomTheme.bg2,
                fgColor: randomTheme.fg,
                playTone: true,
                changeH: true
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

        bgColor1 = Qt.binding(function () {
            return ThemeManager.selectedTheme.colors.primary;
        });
        bgColor2 = Qt.binding(function () {
            return ThemeManager.selectedTheme.colors.secondary;
        });
        fgColor = Qt.binding(function () {
            return ThemeManager.selectedTheme.colors.onPrimary;
        });
    }

    // ========================================================================
    // 1. Music Service Monitor
    // ========================================================================
    Connections {
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
    Connections {
        target: SystemService

        function onBrightnessChanged() {
            if (typeof EyeController !== "undefined") {
                EyeController.showEmotion("focused", 1000);
            }

            root.request({
                priority: C.TRANSIENT,
                source: C.SRC_SYSTEM,
                icon: SystemService.brightnessIcon,
                text: `${Math.round(SystemService.brightness * 100)}%`,
                progress: SystemService.brightness,
                withProgress: true,
                timeout: 2000
            });
        }

        function onIsChargingChanged() {
            if (SystemService.isCharging) {
                root._lastAlertLevel = -1;

                if (typeof EyeController !== "undefined")
                    EyeController.showEmotion("happy", 4000);

                let colors = getColorsForState("success");

                root.request({
                    priority: C.NOTIFICATION,
                    source: C.SRC_BATTERY,
                    icon: SystemService.batteryIcon,
                    text: `Charging: ${Math.round(SystemService.batteryPercent * 100)}%`,
                    bgColor1: colors.bg1,
                    bgColor2: colors.bg2,
                    fgColor: colors.fg,
                    timeout: 3000
                });
            }
        }

        // الصوت (أزرق - Info)
        function onVolumeChanged() {
            if (typeof EyeController !== "undefined")
                EyeController.showEmotion("wink", 1000);

            let colors = getColorsForState("info"); // أزرق هادئ

            root.request({
                priority: C.TRANSIENT,
                source: C.SRC_SYSTEM,
                icon: SystemService.volumeIcon,
                text: `${Math.round(SystemService.volume * 100)}%`,
                progress: SystemService.volume,
                withProgress: true,
                bgColor1: colors.bg1,
                bgColor2: colors.bg2,
                fgColor: colors.fg,
                timeout: 2000
            });
        }

        function onBatteryPercentChanged() {
            if (SystemService.isCharging) {
                root._lastAlertLevel = -1;
                return;
            }

            const currentPct = Math.round(SystemService.batteryPercent * 100);

            // القائمة مرتبة تنازلياً
            const alertLevels = [40, 30, 20, 15, 10, 8, 7, 6, 5, 4, 3];

            // ---------------------------------------------------------
            // 1. معالجة التشغيل لأول مرة (Initialization)
            // ---------------------------------------------------------
            if (root._lastAlertLevel === -1) {
                // إذا فتحنا الجهاز والبطارية 20، لا نريد تنبيه الـ 40 والـ 30
                // نضبط آخر مستوى ليكون النسبة الحالية
                root._lastAlertLevel = currentPct;

                if (currentPct <= 20) {
                    triggerBatteryAlert(currentPct);
                }
                return;
            }

            // ---------------------------------------------------------
            // 2. مراقبة الهبوط (Discharge Logic)
            // ---------------------------------------------------------
            for (let i = 0; i < alertLevels.length; i++) {
                let lvl = alertLevels[i];

                // الشرط:
                // 1. النسبة الحالية وصلت للمستوى أو تحته (مثلاً 20 <= 20)
                // 2. التنبيه السابق كان عند مستوى أعلى (مثلاً 21 > 20)
                // هذا يضمن أننا عبرنا "خط" التنبيه للتو

                if (currentPct <= lvl && root._lastAlertLevel > lvl) {
                    root._lastAlertLevel = lvl; // تحديث للحماية من التكرار
                    triggerBatteryAlert(lvl);

                    console.info("Battery Alert Triggered at: " + lvl);
                    break; // نكتفي بتنبيه واحد (لأقرب مستوى)
                }
            }

            // تحديث حالة "آخر مستوى" دائماً لمواكبة النزول الطبيعي
            // مثلاً: نزلنا من 25 إلى 24 (لا يوجد تنبيه)، يجب أن يصبح _lastAlertLevel=24
            // لكي يعمل الشرط (24 > 22) عندما نصل لـ 22
            if (currentPct < root._lastAlertLevel) {
                root._lastAlertLevel = currentPct;
            }
        }
    }

    function triggerBatteryAlert(level) {
        let alertType = "info"; // الافتراضي
        let priority = C.NOTIFICATION;
        let msg = `Battery at ${level}%`;

        let emotion = "bored";
        let timeout = 4000;

        // --- المنطق ---
        if (level <= 25) {
            alertType = "warning"; // سيجلب اللون البرتقالي
            emotion = "suspicious";
            priority = C.WARNING;
        }

        if (level <= 20) {
            alertType = "warning";
            emotion = "sad";
            msg = `Low Battery (${level}%). Please plug in.`;
        }

        if (level <= 10) {
            alertType = "critical"; // سيجلب اللون الأحمر
            emotion = "shocked";
            priority = C.CRITICAL;
            msg = `Critical Battery (${level}%)!`;
            timeout = 6000;
        }

        if (level <= 5) {
            alertType = "critical";
            emotion = "dead";
            msg = `Battery Dying (${level}%)... Goodbye?`;
            timeout = 8000;
        }

        // 1. جلب الألوان المناسبة للحالة
        let colors = getColorsForState(alertType);

        // 2. تحديث العيون
        if (typeof EyeController !== "undefined") {
            EyeController.showEmotion(emotion, timeout);
        }

        // 3. إرسال الطلب بالألوان الجديدة
        root.request({
            priority: priority,
            source: C.SRC_BATTERY,
            icon: SystemService.batteryIcon,
            text: msg,
            progress: level / 100.0,
            withProgress: true,
            timeout: timeout,
            playTone: true,
            // تطبيق الألوان هنا
            bgColor1: colors.bg1,
            bgColor2: colors.bg2,
            fgColor: colors.fg
        });
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

    // ========================================================================
    // 3. Weather Service Monitor (The Smart Part)
    // ========================================================================
    Connections {
        target: Weather

        function onAiAnalysisCompleted(aiData) {
            console.info("Smart capsule received AI weather data. Urgent: " + aiData.urgent_alert);

            const timeout = 8 * 1000;
            const emotion = aiData.ui.emotion;
            const bgColor1 = aiData.ui.bg_color1;
            const bgColor2 = aiData.ui.bg_color2;
            // const fgColor = Helper.getAccurteTextColor(bgColor);
            const fgColor = aiData.ui.fg_color;
            EyeController.showEmotion(emotion, emotion === "wink" ? 700 : timeout);

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
