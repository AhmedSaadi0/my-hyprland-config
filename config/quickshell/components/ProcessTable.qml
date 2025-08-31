// components/ProcessTable.qml

import QtQuick
import Quickshell.Io
import org.kde.kirigami as Kirigami

// import "../themes"

SimpleTable {
    id: root

    width: 167
    height: 270

    model: dataModel
    columns: tableColumns

    rowHeight: 30
    headerHeight: 30

    // tableBackgroundColor: palette.mid
    tableBorderWidth: 0

    showVerticalGridLines: false
    showHorizontalGridLines: false

    // Header Styling
    headerBackgroundColor: palette.mid
    headerTextColor: Kirigami.Theme.textColor

    // Cell Styling
    cellBackgroundColor: Kirigami.Theme.backgroundColor.lighter(1.5)
    alternatingCellBackgroundColor: Kirigami.Theme.backgroundColor
    cellTextColor: Kirigami.Theme.textColor

    // Spacing Control
    headerCellSpacing: 0
    cellColumnSpacing: 0
    cellRowSpacing: 0

    property var command: []
    property int interval: 2000
    property int showRows: 8
    property bool running: true
    property string title: "Process"
    property string value: "%"

    property var onReadHandler: function (data) {
        try {
            var processes = JSON.parse(data);
            dataModel.clear();

            for (var i = 0; i < Math.min(processes.length, showRows); i++) {
                let subValue = null;
                if (processes[i].memory_usage_mb) {
                    subValue = `${processes[i].memory_usage_mb} MB`;

                    dataModel.append({
                        textRole: processes[i].name,
                        valueRole: processes[i].value.toFixed(2),
                        subRole: subValue
                    });
                } else {
                    dataModel.append({
                        textRole: processes[i].name,
                        valueRole: processes[i].value.toFixed(2)
                    });
                }
            }

            if (dataModel.count === 0) {
                dataModel.append({
                    textRole: "لا عمليات متاحة",
                    valueRole: "0.00"
                });
            }
        } catch (e) {
            console.error("خطأ في تحليل JSON من سكربت المعالج:", e.message);
            console.error("البيانات المستلمة التي سببت الخطأ:", data);
            // Display an error message in the table if parsing fails
            if (dataModel.count === 0 || dataModel.get(0).textRole !== "خطأ في التحليل") {
                dataModel.clear();
                dataModel.append({
                    textRole: "خطأ في التحليل",
                    valueRole: "N/A"
                });
            }
        }
    }

    property var tableColumns: [
        {
            title: root.title,
            role: "textRole",
            alignment: Text.AlignLeft,
            width: 125,
            leftMargin: 12
        },
        {
            title: root.value,
            role: "valueRole",
            alignment: Text.AlignRight,
            width: 70,
            rightMargin: 10
        }
    ]

    // ListModel to hold the process data
    ListModel {
        id: dataModel
        // Initial placeholder data while waiting for the script to run
        ListElement {
            textRole: "جاري تحميل البيانات..."
            valueRole: "0.00"
        }
    }

    Process {
        id: process
        command: root.command
        running: root.running

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                root.onReadHandler(data.trim());
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.error("خطأ سكربت المعالج:", data);
                // Display a script error message in the table
                if (dataModel.count === 0 || dataModel.get(0).textRole !== "خطأ في السكربت") {
                    dataModel.clear();
                    dataModel.append({
                        textRole: "خطأ في السكربت",
                        valueRole: "N/A"
                    });
                }
            }
        }
    }

    // Timer to trigger the CPU usage process periodically
    Timer {
        id: refreshTimer
        interval: root.interval
        repeat: true
        running: false

        onTriggered: {
            process.running = root.running;
        }
    }

    // Ensure initial data is loaded immediately when the component is ready
    Component.onCompleted: {
        if (root.running) {
            refreshTimer.start();
        }
        process.running = root.running;
    }

    Component.onDestruction: {
        refreshTimer.stop();
        process.running = root.running;
    }
}
