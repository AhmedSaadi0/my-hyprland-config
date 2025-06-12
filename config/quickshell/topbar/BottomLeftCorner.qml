// topbar/Corners.qml

import Quickshell

import QtQuick

import "../themes"
import "../components"

PanelWindow {
    id: root

    implicitHeight: 20
    exclusionMode: ExclusionMode.Normal

    // focusable: false
    // aboveWindows: false

    color: "transparent"

    property real cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius * 2

    anchors {
        bottom: true
        left: true
        // right: true
        // top: true
    }

    BarCorner {
        id: bottomRightBarCorner
        anchors {
            // top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        position: "bottom-left"
        cornerRadius: root.cornerRadius
        shapeColor: palette.window
    }
}
