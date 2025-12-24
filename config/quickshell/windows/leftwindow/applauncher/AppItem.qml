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

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 180
                easing.type: Easing.OutQuad
            }
        }
    }

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
            transformOrigin: Item.Center
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
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.itemClicked();
            bounceAnim.restart();
        }

        onEntered: hoverBg.color = ThemeManager.selectedTheme.colors.primary.alpha(0.1)
        onExited: hoverBg.color = "transparent"
    }

    SequentialAnimation {
        id: bounceAnim
        running: false
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 0.85
            duration: 100
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 1.1
            duration: 120
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: icon
            property: "scale"
            to: 1.0
            duration: 100
            easing.type: Easing.OutBack
        }
    }
}
