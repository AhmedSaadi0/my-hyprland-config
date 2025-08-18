// components/EditableField.qml

import QtQuick
import QtQuick.Controls

import "root:/themes"

// EditText that checks if input is a color and changes accordingly
TextField {
    id: root

    topPadding: 0
    bottomPadding: 0

    property color normalBackground: ThemeManager.selectedTheme.colors.topbarBgColorV2
    property color normalForeground: ThemeManager.selectedTheme.colors.topbarFgColorV2
    property color borderColor: ThemeManager.selectedTheme.colors.secondary
    property int borderSize: 1

    property int topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    color: root.normalForeground

    background: Rectangle {
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius

        color: root.enabled ? root.normalBackground : root.normalBackground.alpha(0.3)

        border.color: root.enabled ? root.borderColor : root.borderColor.alpha(0.3)
        border.width: root.borderSize

        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }
    }
}
