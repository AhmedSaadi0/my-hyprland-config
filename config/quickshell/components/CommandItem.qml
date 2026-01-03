// components/CommandItem.qml
import QtQuick

import "root:/themes"

Item {
    id: root

    property var commandData
    property bool isHighlighted: false

    signal clicked

    height: 56

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8

        color: {
            if (root.isHighlighted) {
                return ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333";
            }
            if (mouseArea.containsMouse) {
                return ThemeManager.selectedTheme?.colors?.primary.alpha(0.1) || "#222";
            }
            return "transparent";
        }

        border.color: root.isHighlighted ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1" : "transparent"
        border.width: root.isHighlighted ? 1 : 0

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // Icon container - fixed position
    Rectangle {
        id: iconContainer
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        height: 40
        radius: (ThemeManager.selectedTheme?.dimensions?.elementRadius || 8) * 0.8
        color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#1a1a2e"

        Text {
            anchors.centerIn: parent
            text: commandData?.icon || ""
            font.pixelSize: 20
            font.family: ThemeManager.selectedTheme?.typography?.iconFont || "Material Design Icons"
            color: ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
        }
    }

    // Text content - fixed left anchor
    Column {
        anchors.left: iconContainer.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 48
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: commandData?.name || ""
            font.pixelSize: 13
            font.weight: Font.Medium
            color: ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
        }

        Text {
            text: commandData?.description || ""
            font.pixelSize: 11
            color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
        }
    }

    // Enter hint - positioned absolutely
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: 4
        color: ThemeManager.selectedTheme?.colors?.leftMenuBgColorV2 || "#1a1a2e"
        visible: mouseArea.containsMouse || root.isHighlighted
        opacity: 0.8

        Text {
            anchors.centerIn: parent
            text: "↵"
            font.pixelSize: 12
            color: ThemeManager.selectedTheme?.colors?.subtleText || "#888"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
