// windows/leftwindow/monitoring/components/DiskCard.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "root:/themes"
import "root:/config"

// =============================================================================
//  كرت الأقراص: كرت مستقل يعرض لكل قرص (الماونت ← بروقرس عرضي ← نسبة %)
//  مكوّن خاص بالكرت — لا يستخدم ProcessTable ولا SimpleTable
//  جلب البيانات: Process + SplitParser يملأ ListModel مباشرة + Timer
// =============================================================================
Item {
    id: root

    // =========================================================================
    //  Public Properties
    // =========================================================================
    property bool running: false
    property int interval: 30000 // تحديث كل 30 ثانية

    Layout.fillWidth: true
    implicitHeight: mainLayout.implicitHeight

    readonly property var theme: ThemeManager.selectedTheme

    // =========================================================================
    //  Data Model
    // =========================================================================
    ListModel {
        id: disksModel
    }

    // ملخص المساحة المتبقية الإجمالية لجميع الأقراص (GB)
    readonly property string totalFreeText: {
        var total = 0;
        for (var i = 0; i < disksModel.count; i++) {
            total += disksModel.get(i).freeGb;
        }
        return total.toFixed(1) + " GB free";
    }

    // =========================================================================
    //  UI
    // =========================================================================
    Rectangle {
        width: parent.width
        height: root.implicitHeight

        color: root.theme.colors.surfaceContainerHigh
        radius: root.theme.dimensions.elementRadius
        clip: true

        ColumnLayout {
            id: mainLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: root.theme.dimensions.spacingSmall / 2

            // --- Header: أيقونة + عنوان + ملخص المساحة المتبقية ---
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: root.theme.dimensions.menuWidgetsMargin
                Layout.leftMargin: root.theme.dimensions.menuWidgetsMargin
                Layout.rightMargin: root.theme.dimensions.menuWidgetsMargin

                Text {
                    text: "󰋊"
                    font.family: root.theme.typography.iconFont
                    font.pixelSize: 18
                    color: root.theme.colors.primary
                }

                Text {
                    text: qsTr("Storage")
                    font.pixelSize: 16
                    font.bold: true
                    color: root.theme.colors.onSurface
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: root.totalFreeText
                    font.pixelSize: root.theme.typography.small
                    color: root.theme.colors.onSurfaceVariant
                }
            }

            // --- صفوف الأقراص ---
            Repeater {
                model: disksModel

                delegate: DiskRow {
                    mount: model.mount
                    percent: model.percent

                    Layout.leftMargin: root.theme.dimensions.menuWidgetsMargin
                    Layout.rightMargin: root.theme.dimensions.menuWidgetsMargin
                }
            }

            // ختم سفلي (Bottom Padding)
            Item {
                Layout.preferredHeight: root.theme.dimensions.menuWidgetsMargin
            }
        }
    }

    // =========================================================================
    //  Fetching (Process + Timer + running lifecycle)
    // =========================================================================
    Process {
        id: process
        command: App.scripts.python.diskUsageCommand

        stdout: SplitParser {
            splitMarker: "" // السكربت يطبع JSON مرة واحدة ويغلق
            onRead: data => root.onReadHandler(data.trim())
        }

        stderr: SplitParser {
            onRead: data => console.error("Disk Script Error:", data)
        }

        // عند انتهاء العملية، أعد تشغيلها بعد المدة المحددة
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
                process.running = false; // Reset state
                process.running = true;
            }
        }
    }

    // مراقبة خاصية running الرئيسية
    onRunningChanged: {
        if (root.running) {
            process.running = true;
        } else {
            process.running = false;
            refreshTimer.stop();
        }
    }

    // =========================================================================
    //  Handlers
    // =========================================================================
    function onReadHandler(data) {
        if (!data)
            return; // تجاهل البيانات الفارغة

        try {
            var disks = JSON.parse(data);
            disksModel.clear();

            for (var i = 0; i < disks.length; i++) {
                disksModel.append({
                    mount: disks[i].mount,
                    percent: disks[i].percent,
                    freeGb: disks[i].free_gb
                });
            }
        } catch (e) {
            console.error("Disk JSON Parsing Error:", e.message);
            console.error("Received Data:", data);
            // في حال الخطأ: إبقاء البيانات السابقة (لا نمسح النموذج)
        }
    }
}
