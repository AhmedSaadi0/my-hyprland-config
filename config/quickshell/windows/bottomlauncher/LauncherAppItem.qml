// windows/bottomlauncher/LauncherAppItem.qml
import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/themes"

Item {
    id: root

    signal clicked
    signal hovered

    property var appData
    property bool isSelected: false
    property bool isHighlighted: false

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

        // App Icon
        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.8
            color: ThemeManager.selectedTheme.colors.leftMenuBgColorV2

            Image {
                id: appIcon
                anchors.centerIn: parent
                width: 32
                height: 32
                fillMode: Image.PreserveAspectFit
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

        // App Info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: appData ? appData.name : "Unknown"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: root.isHighlighted ? ThemeManager.selectedTheme.colors.primary : ThemeManager.selectedTheme.colors.leftMenuFgColorV1
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
                font.pixelSize: 12
                color: ThemeManager.selectedTheme.colors.subtleText
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        // Pin button (optional feature)
        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            radius: ThemeManager.selectedTheme.dimensions.elementRadius * 0.6
            color: pinMouseArea.containsMouse ? ThemeManager.selectedTheme.colors.primary.alpha(0.2) : "transparent"
            visible: mouseArea.containsMouse || root.isSelected
            opacity: visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                font.family: ThemeManager.selectedTheme.typography.iconFont
                font.pixelSize: 14
                color: ThemeManager.selectedTheme.colors.subtleText
            }

            MouseArea {
                id: pinMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // TODO: Implement pinning functionality
                    console.log("Pin app:", appData.name);
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            bounceAnim.restart();
            root.clicked();
        }

        onEntered: root.hovered()
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
