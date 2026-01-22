// windows/settings/pages/SystemPage.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell.Io // للـ Process

import "root:/components"
import "root:/windows/settings/components"
import "root:/config"

BaseGeneralSettings {
    id: page
    title: qsTr("System & Resources")
    icon: ""

    property var theme: page.selectedTheme

    // =========================================================
    // 1. المتغيرات المحلية
    // =========================================================
    // Network
    property string localNetworkMonitor: ""
    property int localNetworkInterval: 1000

    // CPU Alert
    property bool localEnableHighCpuAlert: false
    property bool localPlayCpuAlarmSound: false
    property int localCpuThreshold: 90

    // RAM Alert
    property bool localEnableHighRamAlert: false
    property bool localPlayRamAlarmSound: false
    property int localRamThreshold: 90

    // Internal
    ListModel {
        id: networkModel
    }

    // =========================================================
    // 2. المزامنة (Read)
    // =========================================================
    function syncFromConfig() {
        localNetworkMonitor = App.networkMonitor || "";
        localNetworkInterval = App.networkInterval || 1000;

        localEnableHighCpuAlert = App.enableHighCpuAlert;
        localPlayCpuAlarmSound = App.playCpuAlarmSound;
        localCpuThreshold = App.cpuHighLoadThreshold || 90;

        localEnableHighRamAlert = App.enableHighRamAlert;
        localPlayRamAlarmSound = App.playRamAlarmSound;
        localRamThreshold = App.ramHighLoadThreshold || 90;

        // تحديث قائمة الشبكات عند الفتح
        refreshNetworkList();
    }

    // =========================================================
    // 3. التجهيز للحفظ (Write)
    // =========================================================
    function serializeData() {
        return {
            "networkMonitor": localNetworkMonitor,
            "networkInterval": localNetworkInterval,
            "enableHighCpuAlert": localEnableHighCpuAlert,
            "playCpuAlarmSound": localPlayCpuAlarmSound,
            "cpuHighLoadThreshold": localCpuThreshold,
            "enableHighRamAlert": localEnableHighRamAlert,
            "playRamAlarmSound": localPlayRamAlarmSound,
            "ramHighLoadThreshold": localRamThreshold
        };
    }

    // =========================================================
    // 4. منطق جلب كروت الشبكة
    // =========================================================
    Process {
        id: networkInterfacesProcess
        command: ["ls", "/sys/class/net"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const interfaceName = data.trim();
                if (interfaceName !== "") {
                    networkModel.append({
                        text: interfaceName
                    });
                    // تحديد العنصر الحالي
                    if (interfaceName === page.localNetworkMonitor)
                    // سيتم ضبط الـ ComboBox لاحقاً عبر الـ binding أو الـ index
                    {}
                }
            }
        }
    }

    function refreshNetworkList() {
        networkModel.clear();
        networkInterfacesProcess.running = true;
    }

    // =========================================================
    // 5. الواجهة
    // =========================================================
    ColumnLayout {
        spacing: theme.dimensions.spacingLarge
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        // --- INPUT FIELDS ---
        GridLayout {
            Layout.preferredWidth: 600
            Layout.alignment: Qt.AlignHCenter
            columns: 2
            rowSpacing: 20
            columnSpacing: 20

            // ==========================
            // Section 1: Network
            // ==========================
            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: "" // Wifi/Network Icon
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Network Interface")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }

            // Interface Selection
            Controls.Label {
                text: qsTr("Interface Name")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignVCenter
                // color removed
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                SettingsComboBox {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: networkModel
                    textRole: "text" // مهم إذا كان الموديل يحتوي على كائنات

                    // البحث عن الـ index المناسب للنص المحفوظ
                    currentIndex: {
                        for (var i = 0; i < networkModel.count; i++) {
                            if (networkModel.get(i).text === page.localNetworkMonitor)
                                return i;
                        }
                        return -1;
                    }

                    onActivated: index => {
                        page.localNetworkMonitor = networkModel.get(index).text;
                    }
                }

                MButton {
                    text: "" // Refresh Icon
                    font.family: theme.typography.iconFont
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 30
                    onClicked: refreshNetworkList()
                }
            }

            // Refresh Interval
            Controls.Label {
                text: qsTr("Update Interval")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Controls.Slider {
                        Layout.fillWidth: true
                        from: 100
                        to: 5000
                        stepSize: 100
                        value: page.localNetworkInterval
                        onMoved: page.localNetworkInterval = value
                    }
                    Text {
                        text: page.localNetworkInterval + " ms"
                        font.family: theme.typography.bodyFont
                        color: theme.colors.subtleText
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            // ==========================
            // Section 2: Resources
            // ==========================
            Item {
                Layout.columnSpan: 2
                height: 10
            }

            RowLayout {
                Layout.columnSpan: 2
                spacing: 10
                Text {
                    text: "" // Server/Usage Icon
                    font.family: theme.typography.iconFont
                    color: theme.colors.primary
                    font.pixelSize: theme.typography.heading4Size
                }
                Text {
                    text: qsTr("Resource Alerts")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.heading4Size
                    color: theme.colors.primary
                }
            }

            // --- CPU Configuration ---
            Controls.Label {
                text: qsTr("CPU Alert")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignVCenter
            }
            RowLayout {
                Layout.fillWidth: true
                SettingSwitch {
                    isChecked: page.localEnableHighCpuAlert
                    onIsCheckedChanged: page.localEnableHighCpuAlert = isChecked
                }
                Item {
                    Layout.fillWidth: true
                }
                // Sound Toggle
                Text {
                    text: "Sound"
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.subtleText
                    visible: page.localEnableHighCpuAlert
                }
                SettingSwitch {
                    visible: page.localEnableHighCpuAlert
                    isChecked: page.localPlayCpuAlarmSound
                    onIsCheckedChanged: page.localPlayCpuAlarmSound = isChecked
                }
            }

            // CPU Threshold (Only visible if enabled)
            Controls.Label {
                text: qsTr("CPU Threshold")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                visible: page.localEnableHighCpuAlert
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
            }
            RowLayout {
                Layout.fillWidth: true
                visible: page.localEnableHighCpuAlert
                Controls.Slider {
                    Layout.fillWidth: true
                    from: 50
                    to: 100
                    stepSize: 1
                    value: page.localCpuThreshold
                    onMoved: page.localCpuThreshold = value
                }
                Text {
                    text: page.localCpuThreshold + "%"
                    font.family: theme.typography.bodyFont
                    color: theme.colors.subtleText
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }

            // --- RAM Configuration ---
            Controls.Label {
                text: qsTr("RAM Alert")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                Layout.alignment: Qt.AlignVCenter
                Layout.topMargin: 10
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                SettingSwitch {
                    isChecked: page.localEnableHighRamAlert
                    onIsCheckedChanged: page.localEnableHighRamAlert = isChecked
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: "Sound"
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small
                    color: theme.colors.subtleText
                    visible: page.localEnableHighRamAlert
                }
                SettingSwitch {
                    visible: page.localEnableHighRamAlert
                    isChecked: page.localPlayRamAlarmSound
                    onIsCheckedChanged: page.localPlayRamAlarmSound = isChecked
                }
            }

            // RAM Threshold
            Controls.Label {
                text: qsTr("RAM Threshold")
                font.bold: true
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.medium
                visible: page.localEnableHighRamAlert
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 8
            }
            RowLayout {
                Layout.fillWidth: true
                visible: page.localEnableHighRamAlert
                Controls.Slider {
                    Layout.fillWidth: true
                    from: 50
                    to: 100
                    stepSize: 1
                    value: page.localRamThreshold
                    onMoved: page.localRamThreshold = value
                }
                Text {
                    text: page.localRamThreshold + "%"
                    font.family: theme.typography.bodyFont
                    color: theme.colors.subtleText
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
