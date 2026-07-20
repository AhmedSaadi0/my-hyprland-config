// services/AiTask.qml
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: task

    property var command: []

    signal success(var data)
    signal failed(string error)

    function start() {
        if (command.length === 0) {
            failed("Empty command");
            return;
        }
        aiProcess.command = task.command;
        aiProcess.running = true;
    }

    property Process aiProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                console.info(`[AiTask] Ai Process Result :-> \n${this.text}`);

                // نُمرّر الـ envelope كاملاً (success/response/updated_history/error)
                // إلى AiService ليقوم بالتنظيف وإدارة التاريخ
                var envelope = null;
                try {
                    envelope = JSON.parse(this.text);
                } catch (e) {
                    task.failed("Invalid JSON envelope: " + e.message);
                    return;
                }

                if (envelope && envelope.success) {
                    task.success(envelope);
                } else {
                    task.failed(envelope && envelope.error ? envelope.error : "Empty AI response");
                }
            }
        }

        stderr: SplitParser {
            onRead: data => console.error("[AiTask Process Stderr]:", data)
        }

        onRunningChanged: {
            if (!running && !this.stdout.text) {
                // صمت لتجنب التكرار، الفشل سيتم التقاطه في stdout أو stderr
            }
        }
    }
}
