// topbar/Corners.qml

import Quickshell

import QtQuick

import "../themes"
import "../components"

PanelWindow {
    id: root

    implicitHeight: 20
    exclusionMode: ExclusionMode.Normal

    focusable: false
    // aboveWindows: false

    color: "transparent"

    property real cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius * 2

    anchors {
        top: true
        right: true
        // bottom: true
        // left: true
    }

    BarCorner {
        id: topRightBarCorner
        anchors {
            top: parent.top
            right: parent.right
        }
        position: "top-right"
        cornerRadius: root.cornerRadius
        shapeColor: palette.window
    }
}
