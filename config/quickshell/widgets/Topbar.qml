import Quickshell
import QtQuick
import QtQuick.Layouts
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
        Rectangle {
            id: clockBackground
            height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
            width: clockText.width + 20
            radius: ThemeManager.selectedTheme.dimensions.elementRadius

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: ThemeManager.selectedTheme.colors.textBackgroundColor1
                }
                GradientStop {
                    position: 1.0
                    color: ThemeManager.selectedTheme.colors.textBackgroundColor2
                }
            }

            anchors.centerIn: parent
            layer.enabled: true
            layer.effect: Shadow {
                color: palette.shadow.alpha(0.3)
            }

            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }

            Text {
                id: clockText
                text: clock.date.toLocaleString(Qt.locale(), "hh:mm:ss AP - dddd, dd MMMM yyyy")
                anchors.centerIn: parent
                color: ThemeManager.selectedTheme.colors.textFg
            }
        }

        // ---------------------------
        // ------ Right Widgets ------
        // ---------------------------
        RowLayout {
            height: ThemeManager.selectedTheme.dimensions.barHeight
            anchors {
                right: parent.right
                margins: 2
            }

            Rectangle {
                width: 108
                height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
                radius: ThemeManager.selectedTheme.dimensions.elementRadius
                color: palette.light
                layer.enabled: true
                layer.effect: Shadow {}

                Monitors {
                    anchors.centerIn: parent
                }
            }

            Workspaces {
                id: workspaces
                height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
                layer.enabled: true
                layer.effect: Shadow {}
            }
        }

        // --------------------------
        // ------ Left Widgets ------
        // --------------------------
        RowLayout {
            id: leftWidget
            height: ThemeManager.selectedTheme.dimensions.barHeight
            spacing: 8
            anchors {
                left: parent.left
                margins: 2
            }

            Button {
                id: myCustomButton
                implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
                implicitWidth: 35
                text: ""
                font.family: ThemeManager.selectedTheme.typography.iconFont
                property var textRotation: 0
                onClicked: {
                    topBar.openLeftPanelRequested(myCustomButton);
                }

                contentItem: Text {
                    id: buttonTextContent
                    text: myCustomButton.text
                    font: myCustomButton.font

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

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
                            return Kirigami.Theme.hoverColor.darker(1.7);
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
            }
        }
    }
}
