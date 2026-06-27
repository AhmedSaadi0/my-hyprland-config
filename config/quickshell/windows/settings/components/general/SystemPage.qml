// windows/settings/pages/SystemPage.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell.Io // للـ Process

import "root:/components"
import "root:/components/settings"
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

    // Temperature Alert
    property bool localEnableHighTempAlert: false
    property bool localPlayTempAlarmSound: false
    property int localTempThreshold: 85

    property int localResourceAlertCooldownMinutes: 1

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

        localEnableHighTempAlert = App.enableHighTempAlert;
        localPlayTempAlarmSound = App.playTempAlarmSound;
        localTempThreshold = App.tempHighThreshold || 85;

        localResourceAlertCooldownMinutes = Math.max(1, Math.round((App.resourceAlertCooldownMs || 60000) / 60000));

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
            "ramHighLoadThreshold": localRamThreshold,
            "enableHighTempAlert": localEnableHighTempAlert,
            "playTempAlarmSound": localPlayTempAlarmSound,
            "tempHighThreshold": localTempThreshold,
            "resourceAlertCooldownMs": localResourceAlertCooldownMinutes * 60000
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
        spacing: theme.dimensions.spacingMedium
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        SectionCard {
            title: qsTr("Network Interface")
            subtitle: qsTr("Choose the active network interface and monitoring frequency.")
            Layout.preferredWidth: 600
            Layout.alignment: Qt.AlignHCenter

            GridLayout {
                columns: 2
                rowSpacing: 16
                columnSpacing: 20
                Layout.fillWidth: true

                Controls.Label {
                    text: qsTr("Interface Name")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    SettingsComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        model: networkModel
                        textRole: "text"
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
                        text: ""
                        font.family: theme.typography.iconFont
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 30
                        onClicked: refreshNetworkList()
                    }
                }

                Controls.Label {
                    text: qsTr("Update Interval")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
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
                        color: theme.colors.onSurfaceVariant
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        SectionCard {
            title: qsTr("Resource Alerts")
            subtitle: qsTr("Configure system resource thresholds and notification alerts.")
            Layout.preferredWidth: 600
            Layout.alignment: Qt.AlignHCenter

            GridLayout {
                columns: 2
                rowSpacing: 16
                columnSpacing: 20
                Layout.fillWidth: true

                // CPU
                Controls.Label {
                    text: qsTr("CPU Alert")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                }
                RowLayout {
                    Layout.fillWidth: true
                    SettingSwitch {
                        isChecked: page.localEnableHighCpuAlert
                        onIsCheckedChanged: page.localEnableHighCpuAlert = isChecked
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Sound"
                        font.family: theme.typography.bodyFont
                        font.pixelSize: theme.typography.small
                        color: theme.colors.onSurfaceVariant
                        visible: page.localEnableHighCpuAlert
                    }
                    SettingSwitch {
                        visible: page.localEnableHighCpuAlert
                        isChecked: page.localPlayCpuAlarmSound
                        onIsCheckedChanged: page.localPlayCpuAlarmSound = isChecked
                    }
                }

                Controls.Label {
                    text: qsTr("CPU Threshold")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                    visible: page.localEnableHighCpuAlert
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
                        color: theme.colors.onSurfaceVariant
                        Layout.preferredWidth: 40
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // RAM
                Controls.Label {
                    text: qsTr("RAM Alert")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                }
                RowLayout {
                    Layout.fillWidth: true
                    SettingSwitch {
                        isChecked: page.localEnableHighRamAlert
                        onIsCheckedChanged: page.localEnableHighRamAlert = isChecked
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Sound"
                        font.family: theme.typography.bodyFont
                        font.pixelSize: theme.typography.small
                        color: theme.colors.onSurfaceVariant
                        visible: page.localEnableHighRamAlert
                    }
                    SettingSwitch {
                        visible: page.localEnableHighRamAlert
                        isChecked: page.localPlayRamAlarmSound
                        onIsCheckedChanged: page.localPlayRamAlarmSound = isChecked
                    }
                }

                Controls.Label {
                    text: qsTr("RAM Threshold")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                    visible: page.localEnableHighRamAlert
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
                        color: theme.colors.onSurfaceVariant
                        Layout.preferredWidth: 40
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Temp
                Controls.Label {
                    text: qsTr("Temperature Alert")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                }
                RowLayout {
                    Layout.fillWidth: true
                    SettingSwitch {
                        isChecked: page.localEnableHighTempAlert
                        onIsCheckedChanged: page.localEnableHighTempAlert = isChecked
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Sound"
                        font.family: theme.typography.bodyFont
                        font.pixelSize: theme.typography.small
                        color: theme.colors.onSurfaceVariant
                        visible: page.localEnableHighTempAlert
                    }
                    SettingSwitch {
                        visible: page.localEnableHighTempAlert
                        isChecked: page.localPlayTempAlarmSound
                        onIsCheckedChanged: page.localPlayTempAlarmSound = isChecked
                    }
                }

                Controls.Label {
                    text: qsTr("Temperature Threshold")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                    visible: page.localEnableHighTempAlert
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: page.localEnableHighTempAlert
                    Controls.Slider {
                        Layout.fillWidth: true
                        from: 60
                        to: 110
                        stepSize: 1
                        value: page.localTempThreshold
                        onMoved: page.localTempThreshold = value
                    }
                    Text {
                        text: page.localTempThreshold + "°C"
                        font.family: theme.typography.bodyFont
                        color: theme.colors.onSurfaceVariant
                        Layout.preferredWidth: 50
                        horizontalAlignment: Text.AlignRight
                    }
                }
                
                // Cooldown
                Controls.Label {
                    text: qsTr("Reminder Cooldown")
                    font.bold: true
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.medium
                }
                RowLayout {
                    Layout.fillWidth: true
                    Controls.Slider {
                        Layout.fillWidth: true
                        from: 1
                        to: 15
                        stepSize: 1
                        value: page.localResourceAlertCooldownMinutes
                        onMoved: page.localResourceAlertCooldownMinutes = value
                    }
                    Text {
                        text: page.localResourceAlertCooldownMinutes + " min"
                        font.family: theme.typography.bodyFont
                        color: theme.colors.onSurfaceVariant
                        Layout.preferredWidth: 55
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
