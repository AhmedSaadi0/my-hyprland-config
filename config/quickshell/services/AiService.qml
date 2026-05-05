// services/AiService.qml
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // =========================================================
    // إعدادات الحماية من الحظر (Rate Limiting)
    // =========================================================
    property int requestCooldownMs: 3000   // وقت الانتظار بين كل طلب وطلب (3 ثواني)
    property int requestThrottleMs: 15000  // الوقت المطلوب قبل السماح بتكرار نفس نوع الطلب (15 ثانية)

    property var _queue: []
    property bool _isBusy: false
    property var _lastRunTimes: ({}) // سجل يحفظ متى تم تشغيل كل طلب

    // =========================================================
    // أدوات الطباعة للوج
    // =========================================================
    function _safePrettyJson(value) {
        try {
            return JSON.stringify(value, null, 2);
        } catch (e) {
            return `[unserializable: ${e}]`;
        }
    }

    function _extractMessageArg(args) {
        if (!args || !args.length)
            return "";
        const idx = args.indexOf("--message");
        return (idx !== -1 && idx + 1 < args.length) ? args[idx + 1] : "";
    }

    function _logOutgoingRequest(requestId, args, fullCmd) {
        console.info(`[AiService] [Queue: ${_queue.length}] Preparing request: ${requestId}`);
    }

    // =========================================================
    // الدالة الرئيسية الذكية
    // =========================================================
    // 0 = Low (Background tasks like Hover, System Actions)
    // 1 = Normal (Weather, Todo, Boot Analysis)
    // 2 = High (Music changes, System Spikes, Direct User Actions)

    function sendRequest(command, args, callback, errorCallback, requestId = "default", priority = 1) {
        const now = Date.now();

        // منع التكرار (كما هو)
        if (requestId !== "default" && root._lastRunTimes[requestId]) {
            if (now - root._lastRunTimes[requestId] < root.requestThrottleMs) {
                console.warn(`[AiService] ⏳ Ignored '${requestId}' (Too soon).`);
                return;
            }
        }

        // إزالة القديم إذا كان موجوداً
        if (requestId !== "default") {
            root._queue = root._queue.filter(item => item.id !== requestId);
        }

        // إنشاء كائن الطلب مع الأولوية
        let requestItem = {
            cmd: command,
            args: args,
            cb: callback,
            errCb: errorCallback,
            id: requestId,
            prio: priority
        };

        // إدراج الطلب في المكان الصحيح بناءً على الأولوية
        _insertWithPriority(requestItem);

        _processNext();
    }

    // دالة جديدة لترتيب الطابور حسب الأولوية
    function _insertWithPriority(item) {
        let inserted = false;
        // نبحث عن أول عنصر أولويته أقل من العنصر الجديد، ونضعه قبله
        for (let i = 0; i < root._queue.length; i++) {
            if (root._queue[i].prio < item.prio) {
                root._queue.splice(i, 0, item);
                inserted = true;
                break;
            }
        }
        // إذا لم نجد (أو كان الطابور فارغاً)، نضعه في النهاية
        if (!inserted) {
            root._queue.push(item);
        }
    }

    // =========================================================
    // المعالجة والطابور
    // =========================================================
    function _processNext() {
        if (root._isBusy || root._queue.length === 0)
            return;

        root._isBusy = true;
        var next = root._queue.shift();

        // تسجيل وقت التشغيل لهذا النوع من الطلبات
        if (next.id !== "default") {
            root._lastRunTimes[next.id] = Date.now();
        }

        _runTask(next.cmd, next.args, next.cb, next.errCb, next.id);
    }

    function _runTask(command, args, callback, errorCallback, requestId) {
        const component = Qt.createComponent("AiTask.qml");

        var fullCmd = [...command];
        if (args)
            fullCmd = fullCmd.concat(args);

        _logOutgoingRequest(requestId, args, fullCmd);

        const task = component.createObject(root, {
            "command": fullCmd
        });

        task.success.connect(data => {
            if (callback)
                callback(data);
            task.destroy();
            cooldownTimer.start(); // تشغيل العداد قبل معالجة الطلب التالي
        });

        task.failed.connect(err => {
            if (errorCallback)
                errorCallback(err);
            task.destroy();
            cooldownTimer.start(); // حتى عند الفشل ننتظر لتجنب الانهيار المتكرر
        });

        task.start();
    }

    // مؤقت التبريد (يسمح للـ API بالتنفس)
    Timer {
        id: cooldownTimer
        interval: root.requestCooldownMs
        onTriggered: {
            root._isBusy = false;
            root._processNext();
        }
    }

    // =========================================================
    // منظف الـ JSON
    // =========================================================
    function cleanAndParseJson(rawText) {
        if (!rawText || rawText.trim() === "")
            return null;

        try {
            var result = JSON.parse(rawText);

            if (!result.success || !result.response)
                return null;

            var finalData = result.response;

            if (typeof finalData === 'string') {
                var cleanJson = finalData.replace(/```json/g, "").replace(/```/g, "").trim();
                var firstBrace = cleanJson.indexOf("{");
                var lastBrace = cleanJson.lastIndexOf("}");
                if (firstBrace !== -1 && lastBrace !== -1) {
                    cleanJson = cleanJson.substring(firstBrace, lastBrace + 1);
                }
                finalData = JSON.parse(cleanJson);
            }
            return finalData;
        } catch (e) {
            console.error("[AiService] Parsing Error.");
            return null;
        }
    }
}
