// components/AppItem.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

import "root:/themes"
import "root:/config"
import "root:/utils"

Item {
    id: root

    signal clicked
    signal hovered
    signal favoriteToggled

    property var appData
    property bool isSelected: false
    property bool isHighlighted: false
    property bool isFavorite: false

    height: 64

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        color: {
            if (root.isHighlighted) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.25);
            }
            if (root.isSelected) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.15);
            }
            if (mouseArea.containsMouse) {
                return ThemeManager.selectedTheme.colors.primary.alpha(0.1);
            }
            return "transparent";
        }

        border.color: root.isHighlighted ? ThemeManager.selectedTheme.colors.primary : "transparent"
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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.8
            color: ThemeManager.selectedTheme.colors.surfaceContainer

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                width: 38
                height: 38
                source: Quickshell.iconPath(appData ? appData.icon : "application-x-executable", "application-x-executable")
                transformOrigin: Item.Center
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: appData ? appData.name : "Unknown"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: root.isHighlighted ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onSurface
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: appData ? (appData.genericName || appData.comment || "") : ""
                font.pixelSize: 14
                color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 6

            Rectangle {
                Layout.alignment: Qt.AlignRight
                width: 24
                height: 24
                radius: 6
                color: ThemeManager.selectedTheme.colors.primary.alpha(0.12)
                visible: root.isFavorite

                Text {
                    anchors.centerIn: parent
                    text: "󰓎"
                    font.family: ThemeManager.selectedTheme.typography.iconFont
                    font.pixelSize: 13
                    color: ThemeManager.selectedTheme.colors.primary
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignRight
                width: 24
                height: 24
                radius: 6
                color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
                visible: mouseArea.containsMouse || root.isHighlighted || root.isSelected
                opacity: 0.85

                Text {
                    anchors.centerIn: parent
                    text: "↵"
                    font.pixelSize: 12
                    color: ThemeManager.selectedTheme.colors.onSurfaceVariant
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: mouse => {
            if (mouse.button === Qt.LeftButton) {
                bounceAnim.restart();
                root.clicked();
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.x = mouse.x;
                contextMenu.y = mouse.y;
                contextMenu.open();
            }
        }

        onEntered: root.hovered()
    }

    Popup {
        id: contextMenu
        width: 160
        padding: 6
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        transformOrigin: Item.TopLeft

        background: Rectangle {
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.surfaceContainerHigh
            border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.3)
            border.width: 1
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 200
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.8
                    to: 1.0
                    duration: 250
                    easing.type: Easing.OutBack
                }
            }
        }

        exit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: 150
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    property: "scale"
                    from: 1.0
                    to: 0.9
                    duration: 150
                    easing.type: Easing.InQuad
                }
            }
        }

        contentItem: ColumnLayout {
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: openMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "فتح"
                    font.pixelSize: 14
                    color: ThemeManager.selectedTheme.colors.onSurface
                }

                MouseArea {
                    id: openMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.close();
                        bounceAnim.restart();
                        root.clicked();
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: ThemeManager.selectedTheme.colors.primary.alpha(0.1)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
                color: favMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰦢"
                        font.family: ThemeManager.selectedTheme.typography.iconFont
                        font.pixelSize: 14
                        color: root.isFavorite ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.onSurfaceVariant
                    }

                    Text {
                        text: root.isFavorite ? "إزالة من المفضلة" : "إضافة للمفضلة"
                        font.pixelSize: 14
                        color: ThemeManager.selectedTheme.colors.onSurface
                    }
                }

                MouseArea {
                    id: favMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.close();
                        root.favoriteToggled();
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: bounceAnim
        running: false

        PropertyAnimation {
            target: appIcon
            property: "scale"
            to: 0.85
            duration: 80
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: appIcon
            property: "scale"
            to: 1.1
            duration: 100
            easing.type: Easing.OutQuad
        }
        PropertyAnimation {
            target: appIcon
            property: "scale"
            to: 1.0
            duration: 80
            easing.type: Easing.OutQuad
        }
    }
}
