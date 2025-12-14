pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: controller

    // ================= المدخلات =================
    property bool isMusicPlaying: false
    property bool isHovered: false

    // ================= المتغيرات الداخلية =================
    // نستخدم متغيرات بسيطة للتحكم
    property string _forcedEmotion: "" // لحفظ الشعور المؤقت
    property bool _isThinking: false   // لحفظ حالة التفكير

    // ================= منطق تحديد الحالة (The Logic) =================
    readonly property string currentEmotion: {
        // الأولوية 1: أي شعور مؤقت (showEmotion) يغطي على كل شيء
        if (_forcedEmotion !== "")
            return _forcedEmotion;

        // الأولوية 2: التفكير
        if (_isThinking)
            return "thinking";

        // الأولوية 3: تفاعل الماوس (هوفر)
        if (isHovered) {
            return isMusicPlaying ? "happy" : "suspicious";
        }

        // الأولوية 4: الوضع الطبيعي (موسيقى أو خمول)
        return isMusicPlaying ? "music" : "idle";
    }

    // ================= الوظائف =================

    // دالة التفكير
    function think(duration = 3000) {
        // نصفر أي شعور مؤقت سابق لضمان ظهور التفكير
        _forcedEmotion = "";
        _isThinking = true;

        startResetTimer(duration);
    }

    // دالة إظهار شعور مؤقت (تجبر العين على التغيير فوراً)
    function showEmotion(name, duration = 3000) {
        // نوقف التفكير لنظهر الشعور فوراً
        _isThinking = false;
        _forcedEmotion = name;

        startResetTimer(duration);
    }

    // دالة مساعدة لتشغيل التايمر
    function startResetTimer(duration) {
        resetTimer.stop(); // إيقاف أي عد سابق
        resetTimer.interval = duration;
        resetTimer.start();
    }

    // ================= التايمر السيد (Master Timer) =================
    // وظيفة هذا التايمر وحيدة: تنظيف كل شيء والعودة للوضع الافتراضي
    Timer {
        id: resetTimer
        repeat: false
        onTriggered: {
            console.log("Resetting eye state to default...");
            controller._forcedEmotion = "";
            controller._isThinking = false;
        }
    }
}
