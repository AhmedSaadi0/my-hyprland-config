import Quickshell
import Quickshell.Io
import QtQuick
// import QtQuick.Controls
// import org.kde.kirigami as Kirigami

import "../themes"
// import "./widgets"
import "../components"

PanelWindow {
    id: root
    implicitWidth: 1
    color: "transparent"

    // exclusionMode: ExclusionMode.Auto
    exclusionMode: ExclusionMode.Normal

    anchors {
        top: true
        left: true
        // right: true
        bottom: true
    }

    // Background
    Rectangle {
        id: barBackground
        height: ThemeManager.selectedTheme.dimensions.barHeight
        width: parent.width
        color: palette.window

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        layer.enabled: true
        layer.effect: Shadow {
            color: palette.shadow.alpha(0.8)
            radius: 8
        }

        // z: -1

    }
}
