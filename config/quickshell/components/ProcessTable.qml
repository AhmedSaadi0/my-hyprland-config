// components/ProcessTable.qml

import QtQuick
import Quickshell.Io
import "root:/themes"
import "root:/windows/processdetail" as ProcessDetail

SimpleTable {
    id: root

    // تحسين: استخدام implicit بدلاً من الحجم الثابت لمرونة أكبر
    implicitWidth: 167
    implicitHeight: 270

    // width: 167
    // height: 270

    model: dataModel
    columns: tableColumns

    rowHeight: 30
    headerHeight: 30

    tableBorderWidth: 0
    showVerticalGridLines: false
    showHorizontalGridLines: false

    // Header Styling
    headerBackgroundColor: ThemeManager.selectedTheme.colors.surfaceContainerHigh
    headerTextColor: ThemeManager.selectedTheme.colors.onSurface

    // Cell Styling
    cellBackgroundColor: ThemeManager.selectedTheme.colors.surfaceContainer
    alternatingCellBackgroundColor: ThemeManager.selectedTheme.colors.surfaceContainerHigh
    cellTextColor: ThemeManager.selectedTheme.colors.onSurface

    // Spacing Control
    headerCellSpacing: 0
    cellColumnSpacing: 0
    cellRowSpacing: 0

    property var command: []
    property int interval: 2000
    property int showRows: 8
    property bool running: true
    property string title: qsTr("Process")
    property string value: "%"

    property int highValueAlert: 50

    signal highUsageProcess(var processInfo)

    // دالة مساعدة لتحديث النموذج
    function updateModel(processes) {
        dataModel.clear();

        // حماية ضد البيانات الفارغة
        if (!processes || processes.length === 0) {
            dataModel.append({
                textRole: qsTr("No processes available"),
                valueRole: "0.00",
                subRole: "",
                pidRole: 0
            });
            return;
        }

        for (var i = 0; i < Math.min(processes.length, showRows); i++) {
            let subValue = "";
            let processValue = processes[i].value;
            let processName = processes[i].name;

            // التحقق من وجود القيمة قبل استخدامها
            if (processes[i].memory_usage_mb !== undefined) {
                subValue = `${processes[i].memory_usage_mb} MB`;
            }

            dataModel.append({
                textRole: processName || qsTr("Unknown"),
                valueRole: (processValue !== undefined) ? Number(processValue).toFixed(2) : "0.00",
                subRole: subValue,
                pidRole: processes[i].pid || 0
            });

            if (processValue >= highValueAlert) {
                root.highUsageProcess({
                    appName: processName,
                    usage: processValue
                });
            }
        }
    }

    property var onReadHandler: function (data) {
        if (!data)
            return; // تجاهل البيانات الفارغة

        try {
            var processes = JSON.parse(data);
            updateModel(processes);
        } catch (e) {
            console.error("JSON Parsing Error:", e.message);
            console.error("Received Data:", data);

            // عرض رسالة خطأ فقط إذا لم يكن هناك بيانات سابقة أو الخطأ مختلف
            if (dataModel.count === 0 || dataModel.get(0).textRole !== qsTr("Parsing Error")) {
                dataModel.clear();
                dataModel.append({
                    textRole: qsTr("Parsing Error"),
                    valueRole: "N/A",
                    subRole: "",
                    pidRole: 0
                });
            }
        }
    }

    property var tableColumns: [
        {
            title: root.title,
            role: "textRole",
            alignment: Text.AlignLeft,
            width: root.width * 0.65 // تحسين: عرض نسبي بدلاً من ثابت
            ,
            leftMargin: 12
        },
        {
            title: root.value,
            role: "valueRole",
            alignment: Text.AlignRight,
            width: root.width * 0.35 // تحسين: عرض نسبي
            ,
            rightMargin: 10
        }
    ]

    ListModel {
        id: dataModel
        ListElement {
            textRole: "Loading data..."
            valueRole: "0.00"
            subRole: ""
            pidRole: 0
        }
    }

    Process {
        id: process
        command: root.command
        // running: يتم التحكم به يدوياً عبر المؤقت

        stdout: SplitParser {
            splitMarker: "" // يقرأ الكل دفعة واحدة، تأكد أن السكربت يطبع JSON مرة واحدة ويغلق
            onRead: data => root.onReadHandler(data.trim())
        }

        stderr: SplitParser {
            onRead: data => {
                console.error("Script Error:", data);
                if (dataModel.count === 0 || dataModel.get(0).textRole !== qsTr("Script Error")) {
                    dataModel.clear();
                    dataModel.append({
                        textRole: qsTr("Script Error"),
                        valueRole: "N/A",
                        subRole: "",
                        pidRole: 0
                    });
                }
            }
        }

        // تحسين: عند انتهاء العملية، ابدأ المؤقت ليعيد تشغيلها
        onExited: (code, status) => {
            if (root.running) {
                refreshTimer.start();
            }
        }
    }

    // Timer logic update: Wait -> Run Process -> Wait -> Run Process
    Timer {
        id: refreshTimer
        interval: root.interval
        repeat: false // يعمل مرة واحدة بعد انتهاء العملية
        running: false

        onTriggered: {
            if (root.running) {
                // إعادة تشغيل العملية
                process.running = false; // Reset state
                process.running = true;
            }
        }
    }

    // مراقبة خاصية running الرئيسية
    onRunningChanged: {
        if (running) {
            process.running = true;
        } else {
            process.running = false;
            refreshTimer.stop();
        }
    }

    property var _detailWindows: []

    onRowClicked: function(rowIndex) {
        if (!showDetailButton) return;
        var pid = dataModel.get(rowIndex).pidRole;
        if (!pid || pid === 0) return;

        var component = Qt.createComponent("root:/windows/processdetail/ProcessDetailWindow.qml");
        if (component.status === Component.Ready) {
            var window = component.createObject(null, { "targetPid": pid });
            _detailWindows.push(window);
            window.onClosing.connect(function() {
                var idx = _detailWindows.indexOf(window);
                if (idx !== -1) _detailWindows.splice(idx, 1);
            });
        } else {
            console.error("Failed to create ProcessDetailWindow:", component.errorString());
        }
    }

    Component.onCompleted: {
        // تحديث النص الأولي ليكون مترجماً
        dataModel.clear();
        dataModel.append({
            textRole: qsTr("Loading data..."),
            valueRole: "0.00",
            subRole: "",
            pidRole: 0
        });

        if (root.running) {
            process.running = true;
        }
    }
}
