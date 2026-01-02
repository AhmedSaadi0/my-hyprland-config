pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // =========================================================
    // Request Handler
    // =========================================================
    property var _queue: []
    property bool _isBusy: false

    function sendRequest(command, args, callback, errorCallback) {
        _queue.push({
            command: command,
            args: args,
            callback: callback,
            errorCallback: errorCallback
        });
        _processQueue();
    }

    function _processQueue() {
        if (_isBusy || _queue.length === 0)
            return;

        var request = _queue.shift(); // أخذ أول طلب
        _isBusy = true;

        // إعداد العملية
        aiProcess.currentRequest = request;
        aiProcess.hasFinishedSuccessfully = false;

        // دمج الأمر
        var fullCmd = [...request.command];
        if (request.args)
            fullCmd = fullCmd.concat(request.args);

        // console.info(`[AiService] command to send ${fullCmd}`);

        aiProcess.command = fullCmd;
        aiProcess.running = true;
    }

    Process {
        id: aiProcess
        property var currentRequest: null
        property bool hasFinishedSuccessfully: false

        stdout: StdioCollector {
            onStreamFinished: {
                console.info(`[AiService] Ai Process Result :-> ${this.text}`);
                var data = root.cleanAndParseJson(this.text);

                if (data) {
                    // بيانات سليمة
                    if (aiProcess.currentRequest && aiProcess.currentRequest.callback) {
                        aiProcess.currentRequest.callback(data);
                    }
                    aiProcess.hasFinishedSuccessfully = true;
                } else {
                    console.error("AiService: Invalid JSON received.");
                }
            }
        }

        stderr: SplitParser {
            onRead: data => console.error("AiService Stderr:", data)
        }

        onRunningChanged: {
            // "running" أصبح false (انتهت العملية سواء بنجاح أو فشل)
            if (!running && root._isBusy) {

                // إذا لم يتم وضع علامة النجاح (يعني لم يمر عبر stdout بنجاح)
                if (!aiProcess.hasFinishedSuccessfully) {
                    console.error("AiService: Process failed or crashed without valid output.");

                    // إبلاغ الخدمة الطالبة بالفشل
                    if (aiProcess.currentRequest && aiProcess.currentRequest.errorCallback) {
                        aiProcess.currentRequest.errorCallback("Process Crash or No Output");
                    }
                }

                // تنظيف المتغيرات
                aiProcess.currentRequest = null;

                // تحرير العلم وتشغيل التالي
                root._isBusy = false;
                root._processQueue();
            }
        }
    }

    // =========================================================
    // JSON Cleaner
    // =========================================================
    function cleanAndParseJson(rawText) {
        try {
            // 1. محاولة تحويل مباشر
            var result = JSON.parse(rawText);

            // 2. التحقق من هيكل الرد
            if (!result.success || !result.response) {
                console.warn("AiService: API returned success:false or missing response.");
                return null;
            }

            var finalData = result.response;

            // 3. التنظيف العميق (المشكلة التي تواجهها دائماً مع LLMs)
            // إذا كان الرد نصاً يحتوي على ماركداون ```json
            if (typeof finalData === 'string') {
                var cleanJson = finalData.replace(/```json/g, "") // حذف بداية الكود
                .replace(/```/g, "")     // حذف نهاية الكود
                .trim();

                // استخراج ما بين الأقواس فقط لضمان عدم وجود نصوص زائدة
                var firstBrace = cleanJson.indexOf("{");
                var lastBrace = cleanJson.lastIndexOf("}");
                if (firstBrace !== -1 && lastBrace !== -1) {
                    cleanJson = cleanJson.substring(firstBrace, lastBrace + 1);
                }

                // تحويل النص المنظف إلى كائن
                finalData = JSON.parse(cleanJson);
            }

            return finalData;
        } catch (e) {
            console.error("AiService: Parsing Error:", e);
            console.error("AiService: Raw Text was:", rawText);
            return null;
        }
    }
}
