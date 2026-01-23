// settings/MonitorSettings.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

import "root:/components"

M3GroupBox {
    id: root
    title: qsTr("Monitor Settings")

    property var workingTheme
    property var selectedTheme

    ListModel {
        id: monitorModel
        ListElement {
            name: "DP-1"
            description: "Dell U2721DE"
            isEnabled: true
            resolution: "2560x1440"
            refreshRate: "60.000 Hz"
            scale: 1.0
            positionX: 0
            positionY: 0
            isPrimary: true
        }
        ListElement {
            name: "HDMI-A-1"
            description: "LG Electronics 24MP59G"
            isEnabled: true
            resolution: "1920x1080"
            refreshRate: "75.000 Hz"
            scale: 1.1
            positionX: 2560
            positionY: 360
            isPrimary: false
        }
        ListElement {
            name: "eDP-1"
            description: "Internal Laptop Display"
            isEnabled: false
            resolution: "1920x1080"
            refreshRate: "144.000 Hz"
            scale: 1.0
            positionX: 0
            positionY: 1440
            isPrimary: false
        }
    }

    footer: RowLayout {
        spacing: selectedTheme.dimensions.spacingMedium
    }
}
