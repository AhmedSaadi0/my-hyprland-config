// windows/leftwindow/monitoring/components/EventHeader.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

Item {
    id: root

    property string eventType
    property string eventValue
    property string eventSeverity
    property string eventTime
    property bool isExpanded: false
    property color stateColor

    readonly property var theme: ThemeManager.selectedTheme

    implicitHeight: headerRow.implicitHeight

    RowLayout {
        id: headerRow
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12

        // Icon Box
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: theme.dimensions.elementRadius
            color: theme.colors.leftMenuBgColorV2
            border.width: 1
            border.color: Qt.rgba(theme.colors.subtleText.r, theme.colors.subtleText.g, theme.colors.subtleText.b, 0.12)
            Text {
                anchors.centerIn: parent
                text: (eventType === "CPU") ? "" : (eventType === "RAM") ? "" : (eventType === "TEMP") ? "" : ""
                font.family: theme.typography.iconFont
                font.pixelSize: 18
                color: stateColor
            }
        }

        // Text Info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Text {
                    text: eventType + " Spike"
                    color: theme.colors.secondary
                    font.family: theme.typography.bodyFont
                    font.pixelSize: theme.typography.small + 2
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: eventSeverity === "CRITICAL"
                    height: 18
                    radius: 9
                    color: Qt.rgba(theme.colors.error.r, theme.colors.error.g, theme.colors.error.b, 0.18)
                    border.color: Qt.rgba(theme.colors.error.r, theme.colors.error.g, theme.colors.error.b, 0.5)
                    border.width: 1
                    Layout.preferredWidth: 54
                    Text {
                        anchors.centerIn: parent
                        text: "CRITICAL"
                        color: theme.colors.error
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            Text {
                text: qsTr("Value") + ": " + eventValue
                color: theme.colors.subtleText
                font.family: theme.typography.bodyFont
                font.pixelSize: theme.typography.small + 1
                wrapMode: Text.WordWrap
            }
        }

        // Time and Expand Icon
        ColumnLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            spacing: 4

            Text {
                Layout.alignment: Qt.AlignRight
                text: eventTime
                color: theme.colors.subtleText
                font.family: "Monospace"
                font.pixelSize: theme.typography.small
            }
            Text {
                Layout.alignment: Qt.AlignRight
                text: ""
                font.family: theme.typography.iconFont
                font.pixelSize: 16
                color: isExpanded ? theme.colors.primary : theme.colors.subtleText
                rotation: isExpanded ? 180 : 0
                Behavior on rotation {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }
        }
    }
}
