import Quickshell
import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

import "../themes"
import "./topbar"
import "./topbar/monitors"
import "../components"

PanelWindow {
    id: topBar
    height: ThemeManager.selectedTheme.dimensions.barHeight + 7
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    signal openLeftPanelRequested(var btn)

    // Background
    Rectangle {
        id: barBackground
        height: ThemeManager.selectedTheme.dimensions.barHeight
        width: parent.width
        color: palette.window
        layer.enabled: true
        anchors.top: parent.top

        layer.effect: Shadow {
            color: palette.shadow.alpha(0.8)
            radius: 8
        }

        // z: -1

        // -------------------
        // ------ Clock ------
        // -------------------
        ClockWidget {}

        // ---------------------------
        // ------ Right Widgets ------
        // ---------------------------
        Workspaces {
            id: workspaces
            height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
            layer.enabled: true
            layer.effect: Shadow {}
            anchors {
                right: parent.right
                margins: 2
                verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: 108
            height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: palette.light
            layer.enabled: true
            layer.effect: Shadow {}

            anchors {
                right: workspaces.left
                verticalCenter: parent.verticalCenter
                margins: 10
            }

            Monitors {
                anchors.centerIn: parent
            }
        }

        // --------------------------
        // ------ Left Widgets ------
        // --------------------------
        Button {
            id: myCustomButton
            implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
            implicitWidth: 35
            text: ""
            font.family: ThemeManager.selectedTheme.typography.iconFont
            onClicked: {
                topBar.openLeftPanelRequested(myCustomButton);
            }

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 5
            }

            property var textRotation: 0

            contentItem: Text {
                id: buttonTextContent
                text: myCustomButton.text
                font: myCustomButton.font

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: {
                    if (!myCustomButton.enabled) {
                        return Kirigami.Theme.highlightColor;
                    } else if (myCustomButton.down || myCustomButton.pressed) {
                        return Kirigami.Theme.highlightColor.lighter(1.8); // Light text for dark background
                    } else if (myCustomButton.hovered) {
                        return "#F6D6DA";
                    } else {
                        return Kirigami.Theme.textColor; // Standard text color
                    }
                }

                transform: Rotation {
                    id: iconRotation
                    origin.x: buttonTextContent.width / 2
                    origin.y: buttonTextContent.height / 2
                    angle: myCustomButton.textRotation

                    Behavior on angle {
                        RotationAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }
                }
            }

            background: Rectangle {
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                color: {
                    if (!myCustomButton.enabled) {
                        return Kirigami.Theme.negativeBackgroundColor;
                    } else if (myCustomButton.down) {
                        return Qt.darker(Kirigami.Theme.hoverColor, 1.15);
                    } else if (myCustomButton.pressed) {
                        return Qt.darker(Kirigami.Theme.hoverColor, 1.15); // Same as 'down' for consistency here
                    } else if (myCustomButton.hovered) {
                        return Kirigami.Theme.hoverColor.darker(1.4);
                    } else {
                        return Kirigami.Theme.activeBackgroundColor;
                    }
                }

                border.color: myCustomButton.visualFocus ? Kirigami.Theme.focusColor : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: 150 // Short duration for quick feedback
                    }
                }
            }
        }

        NetworkSpeedIndicator {
            id: internetIndicator
            layer.enabled: true
            layer.effect: Shadow {}
            anchors {
                left: myCustomButton.right
                verticalCenter: parent.verticalCenter
                leftMargin: 10
            }
        }
    }
}
