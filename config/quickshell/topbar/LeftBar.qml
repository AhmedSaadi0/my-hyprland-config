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
    implicitWidth: 26
    color: "transparent"

    // exclusionMode: ExclusionMode.Auto
    exclusionMode: ExclusionMode.Normal

    anchors {
        top: true
        left: true
        // right: true
        bottom: true
    }

    CorneredBox {
        // width: 50
        height: parent.height
        bottomRightVisible: false
        topRightVisible: false
        anchors {
            fill: parent
        }

        layer.enabled: true
        layer.effect: Shadow {}
    }
}
