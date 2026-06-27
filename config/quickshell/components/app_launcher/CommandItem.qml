// components/CommandItem.qml
import QtQuick

import "root:/themes"

Item {
    id: root

    property var commandData
    property bool isHighlighted: false
    readonly property var theme: ThemeManager.selectedTheme

    signal clicked

    height: 56

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: root.theme.dimensions.elementRadius
        opacity: commandData?.enabled === false ? 0.5 : 1

        color: {
            if (root.isHighlighted) {
                return root.theme.colors.primary.alpha(0.2);
            }
            if (mouseArea.containsMouse) {
                return root.theme.colors.primary.alpha(0.1);
            }
            return "transparent";
        }

        border.color: root.isHighlighted ? root.theme.colors.primary : "transparent"
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
        radius: root.theme.dimensions.elementRadius * 0.8
        color: root.theme.colors.surfaceContainerHigh
        opacity: commandData?.enabled === false ? 0.5 : 1

        Text {
            anchors.centerIn: parent
            text: commandData?.icon || ""
            font.pixelSize: 20
            font.family: root.theme.typography.iconFont
            color: root.theme.colors.primary
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
        opacity: commandData?.enabled === false ? 0.5 : 1

        Text {
            text: commandData?.name || ""
            font.pixelSize: 13
            font.weight: Font.Medium
            color: root.theme.colors.onSurface
        }

        Text {
            text: commandData?.description || ""
            font.pixelSize: 11
            color: root.theme.colors.onSurfaceVariant
        }
    }

    // Enter hint - positioned absolutely
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 24
        radius: root.theme.dimensions.shapeExtraSmall
        color: root.theme.colors.surfaceContainerHigh
        visible: (mouseArea.containsMouse || root.isHighlighted) && commandData?.enabled !== false
        opacity: 0.8

        Text {
            anchors.centerIn: parent
            text: "↵"
            font.pixelSize: 12
            color: root.theme.colors.onSurfaceVariant
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: commandData?.enabled !== false
        cursorShape: commandData?.enabled === false ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
