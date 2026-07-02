// windows/leftwindow/monitoring/components/CommandBox.qml

import QtQuick
import QtQuick.Layouts
import "root:/config"
import "root:/themes"

Rectangle {
    id: root

    property string command: ""
    property string warning: ""

    readonly property var theme: ThemeManager.selectedTheme

    Layout.fillWidth: true
    implicitHeight: mainLayout.implicitHeight + 14

    radius: theme.dimensions.shapeExtraSmall
    color: Qt.rgba(theme.colors.surface.r, theme.colors.surface.g, theme.colors.surface.b, theme.systemSettings.themeMode == "dark" ? 0.45 : 0.08)
    border.color: Qt.rgba(theme.colors.onSurfaceVariant.r, theme.colors.onSurfaceVariant.g, theme.colors.onSurfaceVariant.b, 0.15)
    border.width: 1

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            TextEdit {
                id: commandText
                Layout.fillWidth: true
                text: root.command
                color: theme.colors.tertiary
                font.family: "Monospace"
                font.pixelSize: theme.typography.small - 1
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                readOnly: true
                selectionColor: theme.colors.tertiary
                selectedTextColor: theme.colors.onPrimary
            }

            Rectangle {
                width: 24
                height: 24
                radius: theme.dimensions.shapeExtraSmall
                color: copyMouse.containsMouse ? Qt.rgba(theme.colors.tertiary.r, theme.colors.tertiary.g, theme.colors.tertiary.b, 0.2) : "transparent"

                Text {
                    id: copyIcon
                    anchors.centerIn: parent
                    text: ""
                    font.family: theme.typography.iconFont
                    font.pixelSize: 13
                    color: theme.colors.tertiary
                }

                MouseArea {
                    id: copyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        App.dispatchCommand("Copy solution command", ["wl-copy", root.command]);
                        copyIcon.text = "";
                        copyResetTimer.start();
                    }
                }

                Timer {
                    id: copyResetTimer
                    interval: 1500
                    onTriggered: copyIcon.text = ""
                }
            }
        }

        Text {
            visible: root.warning !== "" && root.warning !== "null"
            Layout.fillWidth: true
            text: root.warning
            color: theme.colors.secondary
            font.pixelSize: theme.typography.small - 2
            wrapMode: Text.WordWrap
            opacity: 0.85
        }
    }
}
