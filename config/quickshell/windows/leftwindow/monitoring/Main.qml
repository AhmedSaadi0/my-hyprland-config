// windows/leftwindow/monitoring/Main.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/components"
import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config/ConstValues.js" as C
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
        spacing: 7

        property int groupRadius: ThemeManager.selectedTheme.dimensions.elementRadius / C.M3_BUTTON_RADIUS_DIVISOR
        property int innerRadiusDiv: 3

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            ProcessTable {
                id: cpuTable
                Layout.fillWidth: true
                title: "Cpu Usage"
                showDetailButton: true
                command: [...App.scripts.python.systemDiagnosticsCommand, "--action", "cpu"]
                topLeftTableRadius: parent.parent.groupRadius
                topRightTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                bottomLeftTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                bottomRightTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
            }
            ProcessTable {
                id: ramTable
                Layout.fillWidth: true
                title: "Mem Usage"
                showDetailButton: true
                command: [...App.scripts.python.systemDiagnosticsCommand, "--action", "ram"]
                topLeftTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                topRightTableRadius: parent.parent.groupRadius
                bottomLeftTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                bottomRightTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            TempTable {
                id: tempTable
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                topLeftTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                topRightTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                bottomLeftTableRadius: parent.parent.groupRadius
                bottomRightTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
            }
            BatteryTable {
                id: batteryTable
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                topLeftTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                topRightTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                bottomLeftTableRadius: parent.parent.groupRadius / parent.parent.innerRadiusDiv
                bottomRightTableRadius: parent.parent.groupRadius
            }
        }

        SystemMonitor {
            id: systemMonitor
            Layout.fillWidth: true
            Layout.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin / 2
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
