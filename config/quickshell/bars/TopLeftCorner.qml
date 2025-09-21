// topbar/Corners.qml

import Quickshell
import Quickshell.Wayland
import QtQuick

import "root:/themes"
import "root:/components"

PanelWindow {
    id: root

    // implicitHeight: ThemeManager.selectedTheme.dimensions.elementRadius + 10
    // implicitWidth: ThemeManager.selectedTheme.dimensions.elementRadius + 10
    // exclusionMode: ExclusionMode.Normal
    // WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Auto

    focusable: false
    aboveWindows: true

    WlrLayershell.namespace: "NibrasShell:EdgeCorner"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}

    // width: 300
    // width: ThemeManager.selectedTheme.dimensions.menuWidth

    color: "transparent"

    margins {
        // top: -10
        left: 40
    }

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
        shapeColor: ThemeManager.selectedTheme.colors.topbarColor
        // shapeColor: ThemeManager.selectedTheme.colors.volOsdBgColor
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
