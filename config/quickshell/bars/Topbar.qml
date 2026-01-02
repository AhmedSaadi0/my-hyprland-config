import Quickshell
import QtQuick.Effects
import QtQuick

import "../themes"
import "./widgets"
import "./systemtray"
import "../components"

PanelWindow {
    id: topBar
    implicitHeight: ThemeManager.selectedTheme.dimensions.barHeight
    color: ThemeManager.selectedTheme.colors.topbarColor

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
    // Rectangle {
    //     id: barBackground
    //     height: ThemeManager.selectedTheme.dimensions.barHeight
    //     width: parent.width
    //     // color: palette.window

    // -------------------
    // ------ Clock ------
    // -------------------
    // ClockWidget {}

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
        width: 162
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
