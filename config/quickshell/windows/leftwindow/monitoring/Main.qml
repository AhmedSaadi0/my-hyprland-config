// windows/leftwindow/monitoring/Main.qml

import QtQuick

import "root:/components"
import "root:/themes"
import "root:/config"

Rectangle {
    id: monotoringMenu
    objectName: "monitoring"
    color: "transparent"
    implicitHeight: Screen.height - ThemeManager.selectedTheme.dimensions.barHeight

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
        running: true
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
}
