pragma Singleton
import QtQuick
import Quickshell.Io
import "root:/config"

QtObject {
    id: root

    property ListModel model: ListModel {}

    // ---------------------------------------------------------
    property Process monitor: Process {
        command: ["wl-paste", "--watch", "echo", "1"]
        running: true
        stdout: SplitParser {
            onRead: {
                // نطلب التحديث فقط إذا لم يكن جارياً
                if (!root.listProcess.running)
                    root.listProcess.fetch();
            }
        }
    }

    property Process listProcess: Process {
        function fetch() {
            const script = App.scripts.python.getClipboard;
            command = ["python3", script, "list"];
            running = true;
        }
        stdout: SplitParser {
            onRead: data => {
                try {
                    const newItems = JSON.parse(data);
                    root.syncModel(newItems);
                } catch (e) {
                    console.error("ClipboardService Sync Error:", e);
                }
            }
        }
    }

    property Process actionProcess: Process {
        function runCmd(action, id = "") {
            const script = App.scripts.python.getClipboard;
            if (action === "activate")
                command = ["python3", script, "activate", id];
            else if (action === "delete")
                command = ["python3", script, "delete", id];
            else if (action === "wipe") {
                root.model.clear();
                command = ["python3", script, "wipe"];
            }
            running = true;
        }
    }

    // ---------------------------------------------------------
    // دوال الخدمة (Public API)
    // ---------------------------------------------------------

    function refresh() {
        listProcess.fetch();
    }

    function activate(id) {
        actionProcess.runCmd("activate", id);
    }

    function remove(index, id) {
        if (index >= 0 && index < model.count) {
            model.remove(index);
            actionProcess.runCmd("delete", id);
            refreshTimer.restart();
        }
    }

    function wipe() {
        actionProcess.runCmd("wipe");
    }

    // ---------------------------------------------------------
    // المنطق الداخلي
    // ---------------------------------------------------------

    function syncModel(newItems) {
        if (model.count === 0) {
            newItems.forEach(item => model.append({
                    "text": item.text,
                    "type": item.type,
                    "clipId": item.id
                }));
            return;
        }

        let currentIdx = 0;
        for (let i = 0; i < newItems.length; i++) {
            let newItem = newItems[i];
            let found = false;

            for (let j = currentIdx; j < model.count; j++) {
                // مقارنة النص
                if (model.get(j).text === newItem.text) {
                    // تحديث clipId إذا تغير
                    if (model.get(j).clipId !== newItem.id) {
                        model.setProperty(j, "clipId", newItem.id);
                    }
                    if (j !== currentIdx)
                        model.move(j, currentIdx, 1);
                    found = true;
                    currentIdx++;
                    break;
                }
            }
            if (!found) {
                // إدخال العنصر الجديد مع التحويل
                model.insert(currentIdx, {
                    "text": newItem.text,
                    "type": newItem.type,
                    "clipId": newItem.id
                });
                currentIdx++;
            }
        }
        while (model.count > currentIdx)
            model.remove(currentIdx);
    }

    property Timer refreshTimer: Timer {
        interval: 300
        repeat: false
        onTriggered: root.listProcess.fetch()
    }

    Component.onCompleted: {
        refresh();
    }
}
