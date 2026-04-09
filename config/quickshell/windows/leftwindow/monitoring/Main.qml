// windows/leftwindow/monitoring/Main.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/components"
import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"
import "../base"

BaseMenuView {
    id: monitoringMenu
    objectName: "monitoring"

    menuTitle: qsTr("System")
    menuIcon: ""
    showPrimaryAction: false

    // ─── Progresses كهيدر يتمرر مع المحتوى ──────────────────────
    Progresses {
        width: parent.width
    }

    // ─── المحتوى ─────────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
        spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

        RowLayout {
            Layout.fillWidth: true
            spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            ProcessTable {
                id: cpuTable
                Layout.fillWidth: true
                title: "Cpu Usage"
                command: [...App.scripts.python.systemDiagnosticsCommand, "--action", "cpu"]
            }
            ProcessTable {
                id: ramTable
                Layout.fillWidth: true
                title: "Mem Usage"
                command: [...App.scripts.python.systemDiagnosticsCommand, "--action", "ram"]
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            TempTable {
                id: tempTable
                Layout.fillWidth: true
                Layout.preferredHeight: 120
            }
            BatteryTable {
                id: batteryTable
                Layout.fillWidth: true
                Layout.preferredHeight: 120
            }
        }

        SystemMonitor {
            id: systemMonitor
            Layout.fillWidth: true
            Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin / 2
        }
    }

    // ─── دورة حياة القائمة ───────────────────────────────────────
    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, () => monitoringMenu.menuIsOpened(), monitoringMenu);
        EventBus.on(Events.LEFT_MENU_IS_CLOSED, () => monitoringMenu.menuIsClosed(), monitoringMenu);
    }

    function menuIsOpened() {
        if (!cpuTable.running) {
            cpuTable.running = true;
            ramTable.running = true;
            tempTable.running = true;
            batteryTable.running = true;
            console.info("Start menu monitoring tables");
        }
    }

    function menuIsClosed() {
        if (cpuTable.running) {
            cpuTable.running = false;
            ramTable.running = false;
            tempTable.running = false;
            batteryTable.running = false;
            console.info("Stop menu monitoring tables");
        }
    }
}
