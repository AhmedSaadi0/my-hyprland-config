// topbar/Corners.qml

import Quickshell

import QtQuick

import "root:/themes"
import "root:/components"

PanelWindow {
    id: root

    implicitHeight: 20
    implicitWidth: 25
    exclusionMode: ExclusionMode.Normal

    // width: 300
    // width: ThemeManager.selectedTheme.dimensions.menuWidth

    color: "transparent"

    property real cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius * 2

    anchors {
        top: true
        left: true
        // right: true
    }

    BarCorner {
        id: topLeftBarCorners
        anchors {
            top: parent.top
            left: parent.left
        }
        position: "top-left"
        cornerRadius: root.cornerRadius
    }

    // BarCorner {
    //     id: topRightBarCorners
    //     anchors {
    //         top: parent.top
    //         right: parent.right
    //     }
    //
    //     position: "top-right"
    //     cornerRadius: root.cornerRadius
    //     shapeColor: palette.window
    // }
}
