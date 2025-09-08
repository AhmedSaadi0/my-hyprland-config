// topbar/Corners.qml

import Quickshell

import QtQuick

import "../themes"
import "../components"

PanelWindow {
    id: root

    implicitHeight: 29
    implicitWidth: 29
    exclusionMode: ExclusionMode.Normal

    focusable: false
    // aboveWindows: false

    color: "transparent"

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
        cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius === 0 ? 0 : ThemeManager.selectedTheme.dimensions.elementRadius + 5
        shapeColor: ThemeManager.selectedTheme.colors.topbarColor
    }
}
