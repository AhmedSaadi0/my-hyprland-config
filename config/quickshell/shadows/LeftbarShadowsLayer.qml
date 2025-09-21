// ShadowTopbar.qml

import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland

import "root:/themes"

PanelWindow {
    id: shadowTopbar

    implicitHeight: ThemeManager.selectedTheme.dimensions.barHeight + 10

    aboveWindows: false
    focusable: false

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region {}

    anchors {
        top: true
        left: true
        bottom: true
        // right: true
    }

    Rectangle {
        id: barShadow
        anchors.left: parent.left

        height: parent.height

        width: 40
        color: ThemeManager.selectedTheme.colors.topbarColor

        layer.enabled: true
        layer.effect: MultiEffect {
            source: barShadow
            anchors.fill: barShadow
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.25)
            shadowBlur: 0.6
            shadowVerticalOffset: 2
            shadowHorizontalOffset: 2
            blurEnabled: false
        }

        z: -1
    }
}
