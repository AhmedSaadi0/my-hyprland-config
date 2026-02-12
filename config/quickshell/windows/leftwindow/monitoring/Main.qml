// windows/leftwindow/monitoring/Main.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/components"
import "root:/themes"
import "root:/config/EventNames.js" as Events
import "root:/config"

Item {
    id: monitoringMenu
    objectName: "monitoring"

    // نجعل القائمة تأخذ كامل مساحة الأب (التي هي عادة MenuContainer)
    // anchors.fill: parent

    ScrollView {
        id: mainScrollView
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: mainScrollView.availableWidth
            spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

            // إضافة هوامش جانبية وعلوية
            Layout.leftMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
            Layout.rightMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
            Layout.topMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin
            // Layout.bottomMargin: 30 // مساحة إضافية في الأسفل

            Progresses {
                id: progresses
                Layout.fillWidth: true
            }

            // لترتيب الجداول جنباً إلى جنب بشكل مرن
            RowLayout {
                Layout.fillWidth: true
                spacing: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin

                ProcessTable {
                    id: cpuTable
                    Layout.fillWidth: true
                    title: "Cpu Usage"
                    command: App.scripts.python.topCpuUsageCommand
                    // أزل الـ anchors اليدوية
                }

                ProcessTable {
                    id: ramTable
                    Layout.fillWidth: true
                    title: "Mem Usage"
                    command: App.scripts.python.topRamUsageCommand
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
                // لا نضع height ثابت هنا، سيأخذ طوله من implicitHeight الذي عرفناه
                Layout.bottomMargin: ThemeManager.selectedTheme.dimensions.menuWidgetsMargin / 2
            }
        }
    }

    Component.onCompleted: {
        EventBus.on(Events.LEFT_MENU_IS_OPENED, function () {
            monitoringMenu.menuIsOpened();
        });

        EventBus.on(Events.LEFT_MENU_IS_CLOSED, function () {
            monitoringMenu.menuIsClosed();
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
