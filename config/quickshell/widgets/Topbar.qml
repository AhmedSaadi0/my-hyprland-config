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
        MButton {
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
                        return myCustomButton.disabledForeground;
                    } else if (myCustomButton.down || myCustomButton.pressed) {
                        return myCustomButton.downForeground;
                    } else if (myCustomButton.hovered) {
                        let bg = myCustomButton.hoveredBackground;
                        let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                        return luminance > 0.5 ? "black" : "white";
                    } else {
                        return myCustomButton.normalForeground;
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
