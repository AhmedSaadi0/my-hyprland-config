import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/themes"

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 50
    color: "transparent"

    signal clearAllClicked

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Label {
            text: qsTr("Clipboard History")
            font.pixelSize: ThemeManager.selectedTheme.typography.heading4Size
            font.bold: true
            color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: clearMA.containsMouse ? ThemeManager.selectedTheme.colors.error.alpha(0.15) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰆴"
                font.family: ThemeManager.selectedTheme.typography.iconFont
                color: clearMA.containsMouse ? ThemeManager.selectedTheme.colors.error : ThemeManager.selectedTheme.colors.subtleText
            }

            MouseArea {
                id: clearMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clearAllClicked()
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: ThemeManager.selectedTheme.colors.leftMenuFgColorV1.alpha(0.1)
    }
}
