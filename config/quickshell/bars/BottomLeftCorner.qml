// topbar/Corners.qml

import Quickshell
import Quickshell.Wayland
import QtQuick

import "../themes"
import "../components"

PanelWindow {
    id: root

    // implicitHeight: 39
    // implicitWidth: 39
    exclusionMode: ExclusionMode.Normal

    focusable: false
    aboveWindows: true

    WlrLayershell.namespace: "NibrasShell:EdgeCorner"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}

    color: "transparent"

    anchors {
        // right: true
        // top: true
        bottom: true
        left: true
    }

    margins {
        left: 40
    }

    BarCorner {
        id: topRightBarCorner
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        position: "bottom-left"
        cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius * 2
        shapeColor: ThemeManager.selectedTheme.colors.topbarColor
    }
}
