pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

import "root:/config"
import "root:/services"

Singleton {
    id: root

    // ============================================================
    //  SIGNALS
    // ============================================================
    signal analysisCompleted(string emotion, string comment)

    readonly property var players: Mpris.players.values
    property int activeIndex: 0
    readonly property var activePlayer: (players.length > 0) ? players[activeIndex < players.length ? activeIndex : 0] : null
    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false

    // بيانات الأغنية
    readonly property string title: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "Unknown"
    readonly property string artist: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : ""

    // المفتاح الفريد للأغنية
    readonly property string fullInfo: artist ? (artist + " - " + title) : title

    // لتتبع الأغنية التي تم تحليلها مؤخراً لمنع التكرار عند الاستئناف العادي
    property string lastProcessedSong: ""

    readonly property double position: activePlayer ? activePlayer.position : 0
    readonly property double length: (activePlayer && activePlayer.length > 0) ? activePlayer.length : 1

    // سجل التشغيل (للسياق فقط)
    property var recentTracks: []

    // ============================================================
    //  مراقبة التغييرات
    // ============================================================
    onPlayersChanged: {
        if (activeIndex >= players.length)
            activeIndex = 0;
    }

    onFullInfoChanged: {
        // عند تغيير الأغنية، نقوم بتصفير المتغير لتجهيز التحليل الجديد
        if (fullInfo && fullInfo !== "Unknown") {
            console.info("[DEBUG] New song detected:", fullInfo);
            // ملاحظة: لم نعد نضيفها للهيستوري هنا، سنضيفها بعد التعليق
        }

        if (isPlaying) {
            analysisDebouncer.restart();
        }
    }

    onIsPlayingChanged: {
        console.info("[DEBUG] IsPlaying changed to:", isPlaying);
        if (isPlaying) {
            // الحالة 1: أغنية جديدة (تم التعامل معها عبر onFullInfoChanged وتعتمد على Debouncer)

            // الحالة 2: استئناف أغنية (Resume)
            // نعرف ذلك إذا كانت الأغنية الحالية هي نفسها التي تم تحليلها آخر مرة
            if (root.fullInfo === root.lastProcessedSong) {
                // تفعيل المنطق العشوائي للاستئناف
                root.checkRandomResumeComment();
            } else {
                // أغنية جديدة وبدأ التشغيل، المؤقت سيتكفل بالأمر
                analysisDebouncer.restart();
            }
        }
    }

    // ============================================================
    //  المنطق والمؤقتات
    // ============================================================
    Timer {
        id: analysisDebouncer
        interval: 3000
        repeat: false
        onTriggered: {
            root.processCurrentSong(false); // false تعني هذا ليس تعليق استئناف
        }
    }

    // دالة التحقق العشوائي عند الاستئناف (Pause -> Play)
    function checkRandomResumeComment() {
        // توليد رقم عشوائي بين 0 و 1
        // نريد احتمالية قليلة (مثلاً 15% أي تقريباً 1 من كل 7 مرات)
        // إذا كان الرقم أكبر من 0.85 تحقق الشرط
        if (Math.random() > 0.85) {
            console.info("[DEBUG] Random Resume Triggered!");
            root.processCurrentSong(true); // true تعني هذا تعليق استئناف
        } else {
            console.info("[DEBUG] Random Resume Skipped (Saving tokens).");
        }
    }

    function processCurrentSong(isResumeContext) {
        if (!root.fullInfo || root.fullInfo === "Unknown" || !root.isPlaying) {
            return;
        }

        // تم إلغاء التحقق من الذاكرة (Cache) هنا بناءً على طلبك
        // سيتم طلب تحليل جديد في كل مرة

        root.analyzeWithAI(isResumeContext);
    }

    // ============================================================
    //  الذكاء الاصطناعي
    // ============================================================
    function analyzeWithAI(isResumeContext) {
        if (!App.scripts.python || !App.scripts.python.callMusicAi)
            return;

        // نحفظ اسم الأغنية التي نعالجها الآن
        aiProcess.currentProcessingInfo = root.fullInfo;

        // --- بناء السياق ---
        const currentTime = new Date().toLocaleTimeString(Qt.locale(), "hh:mm ap");

        // حساب مدة التشغيل الحالية للدقيقة (للاستئناف)
        console.info(`[DEBUG] Formatting time for position: ${root.position}`);
        const timestamp = formatTime(root.position);
        const resumeTimeStr = isResumeContext ? `Resumed at timestamp ${timestamp}` : "Start of track";
        console.info(`[DEBUG] resumeTimeStr: ${resumeTimeStr}`);

        // --- البحث في التاريخ (History Check) ---
        // نبحث هل هذه الأغنية موجودة في القائمة السابقة؟
        let historyContextMsg = "First time playing in this session.";

        // نبحث عن الأغنية في القائمة
        // index 0 هو آخر أغنية تم تشغيلها، index 1 التي قبلها...
        let lastIndex = root.recentTracks.indexOf(root.fullInfo);

        if (lastIndex !== -1) {
            // وجدنا الأغنية في السجل
            // إذا كانت في الرقم 0، يعني تم تشغيلها قبل أغنية واحدة (أو إعادة تشغيل فورية)
            let songsAgo = lastIndex + 1;
            historyContextMsg = `User played this specific song ${songsAgo} tracks ago. Mention this repetition in the comment.`;
        }

        // تحويل قائمة الهيستوري لنص
        const historyStr = root.recentTracks.slice(0, 5).join(", ");

        // بناء الرسالة بناء على هل هو تشغيل جديد أم استئناف
        let message = "";

        if (isResumeContext) {
            // رسالة الاستئناف (مختصرة)
            message = `
            Action: User RESUMED playback.
            Song: ${title} by ${artist}
            Resume Time: ${resumeTimeStr}
            `;
        } else {
            // رسالة الأغنية الجديدة الكاملة
            message = `
            Current Song: ${title} by ${artist}
            Context:
            - Time: ${currentTime}
            - Play History: [${historyStr}]
            - Repetition Info: ${historyContextMsg}`;
        }

        console.info(`[DEBUG] message to send -> ${message}`);

        const command = App.scripts.python.callMusicAi;
        aiProcess.command = [...command, "--provider", "gemini", "--model", "gemini-robotics-er-1.5-preview", "--message", message];
        aiProcess.running = true;
    }

    // ============================================================
    //  معالجة الرد
    // ============================================================

    Process {
        id: aiProcess
        property string currentProcessingInfo: ""

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(this.text.toString());

                    if (result.success && result.response) {
                        const emotion = result.response.emotion.toString().trim();
                        const comment = result.response.comment.toString().trim();

                        // إرسال الإشارة للواجهة
                        root.analysisCompleted(emotion, comment);

                        // === التغيير هنا: الحفظ في السجل بعد استلام التعليق ===
                        // نتأكد أننا لا نضيف تكرار متتالي لنفس الأغنية في قمة القائمة لتجنب الفوضى
                        // لكنك طلبت أن ترى الهيستوري عند التشغيل التالي، لذا سنضيفها.

                        // نضيف الأغنية التي تم الانتهاء من تحليلها الآن إلى الهيستوري
                        if (aiProcess.currentProcessingInfo !== "") {
                            root.addToHistory(aiProcess.currentProcessingInfo);
                            // تحديث المتغير لمنع تكرار التحليل في حالة الـ Resume
                            root.lastProcessedSong = aiProcess.currentProcessingInfo;
                        }
                    }
                } catch (e) {
                    console.error("[DEBUG] Error:", e);
                }
            }
        }
    }

    // ============================================================
    //  دوال مساعدة
    // ============================================================

    function addToHistory(trackName) {
        // الحماية من التكرار المباشر (اختياري، يمكنك إزالته إذا أردت تسجيل كل مرة حتى لو أعدت الأغنية فوراً)
        // لكن ليكون منطق "قبل 2 أغاني" صحيحاً، يفضل عدم تسجيل التكرار الفوري كإدخال جديد إلا إذا انتقلت لأغنية أخرى
        // السطر التالي يمنع تسجيل الأغنية إذا كانت هي نفسها آخر أغنية مسجلة
        if (recentTracks.length > 0 && recentTracks[0] === trackName)
            return;

        var newHistory = [trackName];
        // نحتفظ بآخر 20 أغنية
        for (var i = 0; i < recentTracks.length && i < 19; i++) {
            newHistory.push(recentTracks[i]);
        }
        recentTracks = newHistory;
        console.info("[DEBUG] History Updated. Last played:", trackName);
    }

    function formatTime(secondsInput) {
        // بما أن القيمة 196.087 فهذا يعني أنها ثواني
        let totalSeconds = Math.floor(secondsInput);

        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;

        // إضافة صفر إذا كانت الثواني خانة واحدة (مثلاً 5 تصبح 05)
        let secStr = seconds < 10 ? "0" + seconds : seconds;

        return minutes + ":" + secStr;
    }

    // دوال التحكم بالمشغل (كما هي)
    function next() {
        if (activePlayer)
            activePlayer.next();
    }
    function previous() {
        if (activePlayer)
            activePlayer.previous();
    }
    function toggle() {
        if (activePlayer)
            activePlayer.togglePlaying();
    }
    function stop() {
        if (activePlayer)
            activePlayer.stop();
    }

    NibrasShellShortcut {
        name: "nextSong"
        onPressed: root.next()
    }
    NibrasShellShortcut {
        name: "previousSong"
        onPressed: previous()
    }
    NibrasShellShortcut {
        name: "togglePlaying"
        onPressed: toggle()
    }
    NibrasShellShortcut {
        name: "stopPlay"
        onPressed: stop()
    }
}
