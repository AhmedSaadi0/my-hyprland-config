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

    // exclusionMode: ExclusionMode.Overlay
    // WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Auto

    focusable: false
    aboveWindows: true

    WlrLayershell.namespace: "NibrasShell:EdgeCorner"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}

    color: "transparent"

    anchors {
        right: true
        top: true
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
        cornerRadius: ThemeManager.selectedTheme.dimensions.elementRadius * 2
        shapeColor: ThemeManager.selectedTheme.colors.topbarColor
    }
}
