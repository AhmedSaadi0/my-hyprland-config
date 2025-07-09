// topbar/Corners.qml

import Quickshell

import QtQuick

import "../themes"
import "../components"

PanelWindow {
    id: root

    implicitHeight: 19
    implicitWidth: 19
    exclusionMode: ExclusionMode.Normal

    focusable: false
    // aboveWindows: false

    color: "transparent"

    property real cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius * 2

    anchors {
        right: true
        top: true
        // bottom: true
        // left: true
    }

    margins {
        top: -10
    }

    BarCorner {
        id: topRightBarCorner
        anchors {
            top: parent.top
            right: parent.right
        }
        position: "top-right"
        cornerRadius: root.cornerRadius
    }
}
