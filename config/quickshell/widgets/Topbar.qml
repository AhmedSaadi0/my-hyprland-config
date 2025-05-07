import Quickshell
import QtQuick
import QtQuick.Layouts

import "../themes"
import "./topbar"
import "./topbar/monitors"
import "../components"

PanelWindow {
    id: topBar
    height: ThemeManager.selectedTheme.dimensions.barHeight
    // color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    // Background
    Rectangle {
        id: barBackground
        height: ThemeManager.selectedTheme.dimensions.barHeight
        width: parent.width
        // anchors {
        //     fill: parent
        // }
        color: palette.window
        layer.enabled: true
        layer.effect: Shadow {
            color: palette.shadow.alpha(0.8)
            // samples: 5
            radius: 8
        }
        // z: -1
    }

    // -------------------
    // ------ Clock ------
    // -------------------
    Rectangle {
        id: clockBackground
        height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
        width: clockText.width + 20
        anchors.centerIn: parent
        radius: ThemeManager.selectedTheme.dimensions.elementRadius
        color: palette.window

        layer.enabled: true
        layer.effect: Shadow {}

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
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 2
        }

        Rectangle {
            width: 110
            height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
            radius: ThemeManager.selectedTheme.dimensions.elementRadius
            layer.enabled: true
            layer.effect: Shadow {}
            color: palette.light
            // color: Kirigami.Theme.hoverColor.alpha(0.4)
            // color: palette.mid
            Monitors {
                anchors {
                    centerIn: parent
                }
            }
        }

        Workspaces {
            id: workspaces
            height: ThemeManager.selectedTheme.dimensions.barWidgetsHeight
            layer.enabled: true
            layer.effect: Shadow {}
            // width: children[0].width

        }
    }

    // --------------------------
    // ------ Left Widgets ------
    // --------------------------
    RowLayout {
        height: ThemeManager.selectedTheme.dimensions.barHeight
        spacing: 10

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            margins: 2
        }

        NetworkSpeedIndicator {
            id: internetIndicator

            layer.enabled: true
            layer.effect: Shadow {}
        }
    }
}
