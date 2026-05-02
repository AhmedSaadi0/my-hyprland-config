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

                // التغيير هنا: استدعاء الدالة من AiService مباشرة
                var parsed = AiService.cleanAndParseJson(this.text);

                if (parsed) {
                    task.success(parsed);
                } else {
                    task.failed("Failed to parse AI response or invalid JSON.");
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
