import Quickshell
import QtQuick.Effects
import QtQuick

import "../themes"
import "./widgets"
import "./systemtray"
import "../components"

PanelWindow {
    id: topBar
    implicitHeight: ThemeManager.selectedTheme.dimensions.barHeight + 10
    color: "transparent"

    exclusionMode: ExclusionMode.Auto

    // LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    // LayoutMirroring.childrenInherit: true

    anchors {
        top: true
        left: true
        right: true
    }

    signal openLeftPanelRequested(var btn)
    property bool menuIsOpen: false

    // Background
    Rectangle {
        id: barBackground
        height: ThemeManager.selectedTheme.dimensions.barHeight
        width: parent.width
        // color: palette.window
        color: ThemeManager.selectedTheme.colors.topbarColor
        anchors.top: parent.top

        // layer.effect: Shadow {}
        // layer.enabled: true
        // layer.effect: MultiEffect {
        //     source: barBackground
        //     anchors.fill: barBackground
        //     shadowEnabled: true
        //     shadowColor: Qt.rgba(0, 0, 0, 0.25)  // نفس alpha 0.25
        //     shadowBlur: 0.6                      // 0.0 إلى 1.0 (كلما زادت زاد النعومة)
        //     shadowVerticalOffset: 2
        //     shadowHorizontalOffset: 2
        //
        //     // خصائص إضافية لجعل الظل يشبه CSS العصري:
        //     blurEnabled: false
        //     // contrast: 1.0
        //     // brightness: 1.0
        //     // saturation: 1.0
        // }

        z: -1

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
            id: monitors
            width: 108
            height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            color: ThemeManager.selectedTheme.colors.topbarBgColorV1
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
        // MButton {
        //     id: myCustomButton
        //     implicitHeight: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
        //     implicitWidth: 35
        //     text: ""
        //     font.family: ThemeManager.selectedTheme.typography.iconFont
        //     onClicked: {
        //         topBar.openLeftPanelRequested(myCustomButton);
        //     }
        //
        //     anchors {
        //         left: parent.left
        //         verticalCenter: parent.verticalCenter
        //         leftMargin: 5
        //     }
        //
        //     property var textRotation: menuIsOpen ? 180 : 0
        //
        //     contentItem: Text {
        //         id: buttonTextContent
        //         text: myCustomButton.text
        //         font: myCustomButton.font
        //
        //         horizontalAlignment: Text.AlignHCenter
        //         verticalAlignment: Text.AlignVCenter
        //
        //         color: {
        //             if (!myCustomButton.enabled) {
        //                 return myCustomButton.disabledForeground;
        //             } else if (myCustomButton.hovered) {
        //                 let bg = myCustomButton.hoveredBackground;
        //                 let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
        //                 return luminance > 0.5 ? "black" : "white";
        //             } else {
        //                 return myCustomButton.normalForeground;
        //             }
        //         }
        //
        //         transform: Rotation {
        //             id: iconRotation
        //             origin.x: buttonTextContent.width / 2
        //             origin.y: buttonTextContent.height / 2
        //             angle: myCustomButton.textRotation
        //
        //             Behavior on angle {
        //                 RotationAnimation {
        //                     duration: 300
        //                     easing.type: Easing.InOutCubic
        //                 }
        //             }
        //         }
        //     }
        // }

        SystemTray {
            id: systemTray
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 10
            }
        }

        NetworkSpeedIndicator {
            id: internetIndicator
            layer.enabled: true
            layer.effect: Shadow {}
            anchors {
                left: systemTray.right
                verticalCenter: parent.verticalCenter
                leftMargin: 10
            }
        }
    }
}
