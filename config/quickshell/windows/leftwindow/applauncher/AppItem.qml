import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/themes"

Item {
    id: root
    signal itemClicked
    property var desktopEntity

    width: listView.width
    height: 70

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        Image {
            id: icon
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: Quickshell.iconPath(desktopEntity ? desktopEntity.icon : "application-x-executable", "application-x-executable")
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: desktopEntity ? desktopEntity.name : "Not available"
                font.pixelSize: 16
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }
            Text {
                text: desktopEntity ? (desktopEntity.genericName || desktopEntity.comment || "") : ""
                font.pixelSize: 12
                color: ThemeManager.selectedTheme.colors.topbarFgColorV1.alpha(0.7)
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                visible: text !== ""
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.itemClicked()
    }
}
