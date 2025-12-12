// services/MusicService.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

import "root:/config"
import "root:/windows/smart_capsule/logic"
import "root:/config/ConstValues.js" as C

Singleton {
    id: root

    // ============================================================
    //  PROPERTIES (البيانات العامة)
    // ============================================================

    readonly property var players: Mpris.players.values
    property int activeIndex: 0

    // المشغل النشط
    readonly property var activePlayer: (players.length > 0) ? players[activeIndex < players.length ? activeIndex : 0] : null
    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false

    // بيانات الأغنية
    readonly property string title: (activePlayer && activePlayer.trackTitle) ? activePlayer.trackTitle : "Unknown"
    readonly property string artist: (activePlayer && activePlayer.trackArtist) ? activePlayer.trackArtist : ""
    readonly property string coverArt: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""

    // المفتاح الفريد للأغنية (سنستخدمه للبحث في الذاكرة)
    readonly property string fullInfo: artist ? (artist + " - " + title) : title

    readonly property double position: activePlayer ? activePlayer.position : 0
    readonly property double length: (activePlayer && activePlayer.length > 0) ? activePlayer.length : 1
    readonly property double progress: position / length

    // ============================================================
    //  CACHING SYSTEM (نظام الذاكرة والاقتصاد)
    // ============================================================

    // الحد الأقصى للأغاني المحفوظة
    readonly property int maxCacheSize: 50

    // تخزين البيانات: المفتاح هو fullInfo والقيمة هي {emotion, comment}
    property var analysisCache: ({})

    // مصفوفة لتتبع الترتيب (FIFO) لحذف الأقدم عند الامتلاء
    property var cacheKeys: []

    // ============================================================
    //  LOGIC (المنطق ومراقبة التغييرات)
    // ============================================================

    onPlayersChanged: {
        if (activeIndex >= players.length)
            activeIndex = 0;
    }

    onIsPlayingChanged: {
        EyeController.isMusicPlaying = isPlaying;
        // إذا اشتغلت الموسيقى وكانت غير محللة مؤخراً، ننتظر قليلاً ثم نحلل
        if (isPlaying) {
            analysisDebouncer.restart();
        }
    }

    // عند تغير العنوان أو الفنان، نعيد تصفير المؤقت لنتأكد أن المستخدم استقر
    // هذا يحل مشكلة تحليل الأغنية السابقة لأن المؤقت سيعاد تشغيله مع كل ضغطة زر
    onFullInfoChanged: {
        if (isPlaying) {
            analysisDebouncer.restart();
        }
    }

    // مؤقت الانتظار (Debounce Timer)
    Timer {
        id: analysisDebouncer
        interval: 3000 // الانتظار 3 ثواني
        repeat: false
        onTriggered: {
            root.processCurrentSong();
        }
    }

    // الدالة الرئيسية التي تقرر: هل نستخدم الذاكرة أم نستدعي الذكاء الاصطناعي؟
    function processCurrentSong() {
        if (!root.fullInfo || root.fullInfo === "Unknown" || !root.isPlaying)
            return;

        console.info("Processing song:", root.fullInfo);

        // 1. فحص الذاكرة (Cache Hit)
        if (root.analysisCache.hasOwnProperty(root.fullInfo)) {
            console.info("Cache HIT! retrieving data for:", root.fullInfo);
            var cachedData = root.analysisCache[root.fullInfo];

            // تطبيق النتائج فوراً بدون استدعاء AI
            root.applyAnalysisResult(cachedData.emotion, cachedData.comment);
            return;
        }

        // 2. إذا لم توجد، نستدعي الـ AI (Cache Miss)
        console.info("Cache MISS. Calling AI...");
        root.analyzeWithAI();
    }

    // ============================================================
    //  CONTROLS (التحكم)
    // ============================================================
    // ملاحظة: تم إزالة analyzeWithAI من هنا لأن الـ Timer سيتكفل بالأمر تلقائياً
    // عند تغير العنوان (activePlayer.next يغير العنوان -> onFullInfoChanged -> Timer)

    function next() {
        if (activePlayer) {
            activePlayer.next();
            CapsuleManager.reset();
            EyeController.showEmotion("happy", 1500);
        }
    }
    function previous() {
        if (activePlayer) {
            activePlayer.previous();
            CapsuleManager.reset();
            EyeController.showEmotion("happy", 1500);
        }
    }
    function toggle() {
        if (activePlayer)
            activePlayer.togglePlaying();
    }
    function stop() {
        if (activePlayer)
            activePlayer.stop();
    }
    function cyclePlayers() {
        if (players.length > 1)
            activeIndex = (activeIndex + 1) % players.length;
    }

    property var _nextSongCall: NibrasShellShortcut {
        name: "nextSong"
        onPressed: root.next()
    }
    property var _prevSongCall: NibrasShellShortcut {
        name: "previousSong"
        onPressed: previous()
    }
    property var _toggleSongCall: NibrasShellShortcut {
        name: "togglePlaying"
        onPressed: toggle()
    }
    property var _stopPlayerCall: NibrasShellShortcut {
        name: "stopPlay"
        onPressed: stop()
    }

    // ============================================================
    //  AI PROCESSING & RESULTS
    // ============================================================

    function applyAnalysisResult(emotion, comment) {
        const timeout = 15 * 1000;

        EyeController.showEmotion(emotion, timeout);
        CapsuleManager.request({
            priority: C.NOTIFICATION,
            source: C.SRC_MUSIC,
            icon: "󰝚",
            text: comment,
            timeout: timeout,
            changeW: true,
            playTone: false
        });
    }

    // دالة إضافة للذاكرة
    function addToCache(key, emotion, comment) {
        // إذا كان موجوداً مسبقاً لا نفعل شيئاً (أو نحدثه)
        if (analysisCache.hasOwnProperty(key))
            return;

        // إضافة للمصفوفة والـ Map
        cacheKeys.push(key);
        analysisCache[key] = {
            emotion: emotion,
            comment: comment
        };

        // التنظيف إذا تجاوزنا الحد (FIFO)
        if (cacheKeys.length > maxCacheSize) {
            var oldKey = cacheKeys.shift(); // حذف أقدم عنصر من المصفوفة
            delete analysisCache[oldKey];   // حذفه من الـ Map
            console.info("Cache limit reached. Removed oldest song:", oldKey);
        }
    }

    function analyzeWithAI() {
        // نأخذ نسخة من العنوان الحالي كي نستخدمها كمفتاح عند الحفظ
        // (مهم جداً في حال تغيرت الأغنية أثناء عمل الـ Process)
        aiProcess.currentProcessingInfo = root.fullInfo;

        const command = App.scripts.python.callMusicAi;
        const message = `Title: ${title}, Artist:${artist}`;

        aiProcess.command = [...command, "--provider", "gemini", "--model", "gemini-robotics-er-1.5-preview", "--message", message];
        aiProcess.running = true;
    }

    Process {
        id: aiProcess
        // خاصية مؤقتة لتذكر اسم الأغنية التي يتم تحليلها الآن
        property string currentProcessingInfo: ""

        stdout: StdioCollector {
            onStreamFinished: {
                console.info("AI Raw Response: " + this.text);
                var result = JSON.parse(this.text.toString());

                if (result.success) {
                    var response = result.response;
                    if (response) {
                        const emotion = response.emotion.toString().trim();
                        const comment = response.comment.toString().trim();

                        // 1. عرض النتيجة
                        root.applyAnalysisResult(emotion, comment);

                        // 2. الحفظ في الذاكرة (للمستقبل)
                        // نستخدم العنوان الذي بدأنا به العملية وليس العنوان الحالي (لتفادي الأخطاء إذا قلب المستخدم بسرعة)
                        if (aiProcess.currentProcessingInfo !== "") {
                            root.addToCache(aiProcess.currentProcessingInfo, emotion, comment);
                        }
                    }
                } else {
                    console.error("AI Error:", result.error);
                }
            }
        }

        stderr: SplitParser {
            onRead: data => console.error("AI Process Error:", data)
        }
    }
}
