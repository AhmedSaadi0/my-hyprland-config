// windows/leftwindow/monitoring/CpuTable.qml

import QtQuick
import Quickshell.Io
import org.kde.kirigami as Kirigami

SimpleTable {
    id: root

    width: 167
    height: 180

    model: dataModel // Assign the ListModel as the table's model
    columns: tableColumns // Assign the column definitions

    rowHeight: 25
    headerHeight: 30

    tableBackgroundColor: palette.accent
    tableBorderWidth: 0

    showVerticalGridLines: false
    showHorizontalGridLines: false

    // Header Styling
    headerBackgroundColor: palette.mid
    headerTextColor: Kirigami.Theme.textColor

    // Cell Styling
    cellBackgroundColor: Kirigami.Theme.backgroundColor.alpha(0.8)
    alternatingCellBackgroundColor: "transparent"
    cellTextColor: Kirigami.Theme.textColor

    // Spacing Control
    headerCellSpacing: 0
    cellColumnSpacing: 0
    cellRowSpacing: 0

    property var command: []
    property int interval: 2000
    property bool running: true
    property string title: "Process"
    property string value: "%"

    property var onReadHandler: function (data) {
        try {
            var processes = JSON.parse(data);
            dataModel.clear();

            for (var i = 0; i < Math.min(processes.length, 6); i++) {
                dataModel.append({
                    memoryRole: processes[i].name,
                    percentageRole: processes[i].value.toFixed(2)
                });
            }

            if (dataModel.count === 0) {
                dataModel.append({
                    memoryRole: "لا عمليات متاحة",
                    percentageRole: "0.00"
                });
            }
        } catch (e) {
            console.error("خطأ في تحليل JSON من سكربت المعالج:", e.message);
            console.error("البيانات المستلمة التي سببت الخطأ:", data);
            // Display an error message in the table if parsing fails
            if (dataModel.count === 0 || dataModel.get(0).memoryRole !== "خطأ في التحليل") {
                dataModel.clear();
                dataModel.append({
                    memoryRole: "خطأ في التحليل",
                    percentageRole: "N/A"
                });
            }
        }
    }

    property var tableColumns: [
        {
            title: root.title,
            role: "memoryRole",
            alignment: Text.AlignLeft,
            width: 140,
            leftMargin: 12
        },
        {
            title: root.value,
            role: "percentageRole",
            alignment: Text.AlignRight,
            width: 50,
            rightMargin: 10
        }
    ]

    // ListModel to hold the process data
    ListModel {
        id: dataModel
        // Initial placeholder data while waiting for the script to run
        ListElement {
            memoryRole: "جاري تحميل البيانات..."
            percentageRole: "0.00"
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

        // Handle standard error output from the script
        stderr: SplitParser {
            onRead: data => {
                console.error("خطأ سكربت المعالج:", data);
                // Display a script error message in the table
                if (dataModel.count === 0 || dataModel.get(0).memoryRole !== "خطأ في السكربت") {
                    dataModel.clear();
                    dataModel.append({
                        memoryRole: "خطأ في السكربت",
                        percentageRole: "N/A"
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
