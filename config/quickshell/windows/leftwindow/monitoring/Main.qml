// windows/leftwindow/monitoring/Main.qml

import QtQuick

import "root:/components"
import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"

Rectangle {
    id: monotoringMenu
    objectName: "monitoring"
    color: "transparent"
    // implicitHeight: Screen.height - ThemeManager.selectedTheme.dimensions.barHeight
    implicitWidth: 200

    // width: ThemeManager.selectedTheme.dimensions.menuWidth
    // spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsSpacing

    // This component is from the original code, keeping it as is.
    Progresses {
        id: progresses
        anchors {
            top: parent.top
            // left: parent.left
            // right: parent.right
            // horizontalCenter: parent.horizontalCenter
            leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
            rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        }
    }

    ProcessTable {
        id: cpuTable
        running: true
        // showRows: 20
        // command: ["python", ".config/quickshell/scripts/python/top_cpu_usage.py"]
        command: App.scripts.python.topCpuUsageCommand
        title: "Cpu Usage"
        anchors {
            top: progresses.bottom
            left: progresses.left
            topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        }
    }

    ProcessTable {
        id: ramTable
        interval: 1000 * 5
        // interval: 300
        running: true
        // showRows: 20
        // command: ["python", ".config/quickshell/scripts/python/top_ram_usage.py"]
        command: App.scripts.python.topRamUsageCommand
        title: "Mem Usage"

        anchors {
            top: progresses.bottom
            right: progresses.right
            topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        }
    }

    TempTable {
        id: tempTable

        anchors {
            top: ramTable.bottom
            right: cpuTable.right
            topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        }
    }

    BatteryTable {
        id: batteryTable

        anchors {
            top: ramTable.bottom
            right: progresses.right
            topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, function () {
            monotoringMenu.menuIsOpened();
        });

        EventBus.on(Events.LEFT_MENU_IS_CLOSED, function () {
            monotoringMenu.menuIsClosed();
        });
    }

    function menuIsOpened() {
        if (!cpuTable.running) {
            cpuTable.running = true;
            ramTable.running = true;
            tempTable.running = true;
            batteryTable.running = true;
            console.info("Start menu monotoring tables");
        }
    }

    function menuIsClosed() {
        if (cpuTable.running) {
            cpuTable.running = false;
            ramTable.running = false;
            tempTable.running = false;
            batteryTable.running = false;
            console.info("Stop menu monotoring tables");
        }
    }
}
