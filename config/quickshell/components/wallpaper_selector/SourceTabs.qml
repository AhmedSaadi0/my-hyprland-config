// components/wallpaper_selector/SourceTabs.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "root:/themes"

RowLayout {
    id: root

    property int currentSource: 0
    property var sourceNames: ["Local", "Downloaded", "Wallhaven"]
    readonly property var theme: ThemeManager.selectedTheme

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
            radius: root.theme.dimensions.elementRadius
            color: root.currentSource === tabRect.index
                ? root.theme.colors.primary.alpha(0.2)
                : tabMouseArea.containsMouse
                    ? root.theme.colors.primary.alpha(0.1)
                    : "transparent"
            border.color: root.currentSource === tabRect.index
                ? root.theme.colors.primary
                : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: tabRect.modelData
                font.pixelSize: 12
                font.weight: root.currentSource === tabRect.index ? Font.Bold : Font.Normal
                color: root.currentSource === tabRect.index
                    ? root.theme.colors.primary
                    : root.theme.colors.leftMenuFgColorV1
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
