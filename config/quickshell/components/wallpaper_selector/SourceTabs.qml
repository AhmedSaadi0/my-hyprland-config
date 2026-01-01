// components/wallpaper_selector/SourceTabs.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "root:/themes"

RowLayout {
    id: root

    property int currentSource: 0
    property var sourceNames: ["Local", "Downloaded", "Wallhaven"]

    signal sourceSelected(int index)

    spacing: 4

    Repeater {
        model: root.sourceNames

        Rectangle {
            id: tabRect
            required property int index
            required property string modelData
            
            Layout.fillWidth: true
            height: 32
            radius: ThemeManager.selectedTheme?.dimensions?.elementRadius || 8
            color: root.currentSource === tabRect.index
                ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.2) || "#333"
                : tabMouseArea.containsMouse
                    ? ThemeManager.selectedTheme?.colors?.primary.alpha(0.1) || "#222"
                    : "transparent"
            border.color: root.currentSource === tabRect.index
                ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: tabRect.modelData
                font.pixelSize: 12
                font.weight: root.currentSource === tabRect.index ? Font.Bold : Font.Normal
                color: root.currentSource === tabRect.index
                    ? ThemeManager.selectedTheme?.colors?.primary || "#6366f1"
                    : ThemeManager.selectedTheme?.colors?.leftMenuFgColorV1 || "#fff"
            }

            MouseArea {
                id: tabMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.sourceSelected(tabRect.index)
            }
        }
    }
}
