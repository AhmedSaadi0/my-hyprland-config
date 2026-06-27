import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "root:/themes"
import "root:/config"
import "root:/components"
import "root:/components/settings"

ColumnLayout {
    id: root

    property int selectedPreset: 1
    property string customStartDate: ""
    property string customEndDate: ""

    readonly property var presets: [
        {
            label: qsTr("Last 24 hours"),
            hours: 24
        },
        {
            label: qsTr("Last 7 days"),
            hours: 168
        },
        {
            label: qsTr("Last 30 days"),
            hours: 720
        },
        {
            label: qsTr("Last 12 months"),
            hours: 8760
        },
        {
            label: qsTr("Custom"),
            hours: 0
        }
    ]

    signal rangeChanged(int hours, string startDate, string endDate)

    spacing: 6

    SettingsComboBox {
        id: combo
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        model: root.presets.map(p => p.label)
        currentIndex: root.selectedPreset

        onCurrentIndexChanged: {
            if (root.selectedPreset !== currentIndex) {
                root.selectedPreset = currentIndex;
                root.emitRange();
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        visible: root.selectedPreset === 4

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
            border.color: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 4
                spacing: 4

                Label {
                    text: qsTr("From")
                    font.pixelSize: ThemeManager.selectedTheme.typography.small
                    color: ThemeManager.selectedTheme.colors.onSurfaceVariant.alpha(0.7)
                }
                Item {
                    Layout.fillWidth: true
                }
                Label {
                    text: root.customStartDate || qsTr("Pick date")
                    font.pixelSize: ThemeManager.selectedTheme.typography.small
                    color: root.customStartDate ? ThemeManager.selectedTheme.colors.onSurface : ThemeManager.selectedTheme.colors.onSurfaceVariant.alpha(0.5)
                }
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 4
                    color: startMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.15) : "transparent"

                    Label {
                        anchors.centerIn: parent
                        text: "󰃭"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                    }
                    MouseArea {
                        id: startMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: startCalendarPopup.open()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
            border.color: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 4
                spacing: 4

                Label {
                    text: qsTr("To")
                    font.pixelSize: ThemeManager.selectedTheme.typography.small
                    color: ThemeManager.selectedTheme.colors.onSurfaceVariant.alpha(0.7)
                }
                Item {
                    Layout.fillWidth: true
                }
                Label {
                    text: root.customEndDate || qsTr("Pick date")
                    font.pixelSize: ThemeManager.selectedTheme.typography.small
                    color: root.customEndDate ? ThemeManager.selectedTheme.colors.onSurface : ThemeManager.selectedTheme.colors.onSurfaceVariant.alpha(0.5)
                }
                Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 4
                    color: endMouse.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.15) : "transparent"

                    Label {
                        anchors.centerIn: parent
                        text: "󰃭"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                    }
                    MouseArea {
                        id: endMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: endCalendarPopup.open()
                    }
                }
            }
        }
    }

    CustomCalendar {
        id: startCalendarPopup
        x: parent ? (parent.width - width) / 2 : 0
        y: parent ? parent.height + 8 : 0
        z: 100
        onDateSelected: date => {
            root.customStartDate = Qt.formatDate(date, "yyyy-MM-dd");
            root.emitRange();
        }
    }

    CustomCalendar {
        id: endCalendarPopup
        x: parent ? (parent.width - width) / 2 : 0
        y: parent ? parent.height + 8 : 0
        z: 100
        onDateSelected: date => {
            root.customEndDate = Qt.formatDate(date, "yyyy-MM-dd");
            root.emitRange();
        }
    }

    function emitRange() {
        if (selectedPreset === 4) {
            if (customStartDate && customEndDate)
                rangeChanged(0, customStartDate, customEndDate);
        } else {
            rangeChanged(presets[selectedPreset].hours, "", "");
        }
    }

    function setPresetHours(hours) {
        for (var i = 0; i < presets.length; i++) {
            if (presets[i].hours === hours && i !== 4) {
                selectedPreset = i;
                return;
            }
        }
        selectedPreset = 4;
    }
}
