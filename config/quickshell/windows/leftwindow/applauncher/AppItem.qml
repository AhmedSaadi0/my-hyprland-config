import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "root:/themes"

Item {
    id: root
    signal itemClicked
    property var desktopEntity
    property bool isSelected: false

    width: listView.width
    height: 70

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: {
            if (root.isSelected) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.15);
            }
            if (mouseArea.containsMouse) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.1);
            }
            return "transparent";
        }

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

        IconImage {
            id: icon
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignVCenter
            // fillMode: Image.PreserveAspectFit
            source: Quickshell.iconPath(desktopEntity ? desktopEntity.icon : "application-x-executable", "application-x-executable")
            transformOrigin: Item.Center
            asynchronous: true
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
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.itemClicked();
            bounceAnim.restart();
        }
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
