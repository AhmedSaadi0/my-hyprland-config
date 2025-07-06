// components/tab/IconLabel.qml

import QtQuick
import "../../themes"

// This component is now simpler. It ONLY handles a horizontal layout.
// Its parent (TabButtonDelegate) is responsible for rotating it.
Item {
    id: root

    property string iconText
    property string labelText
    property bool isActive
    property int currentWidth // This is the width it's given to lay out content

    // These are no longer needed, as the parent handles the layout.
    // width: currentWidth
    // height: parent.height

    Text {
        id: icon
        text: iconText
        color: {
            if (isActive) {
                let bg = textHighlightColor;
                let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                return luminance > 0.5 ? "black" : "white";
            }
            return textColor;
        }
        font.pixelSize: 14
        font.bold: isActive
        font.family: ThemeManager.selectedTheme.typography.iconFont
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 13
        }
    }

    Text {
        id: label
        // The width is now calculated based on the parent's width, which is passed via currentWidth
        width: Math.max(0, root.width - icon.width - 25)
        text: labelText
        color: icon.color // Match the icon's color
        font.pixelSize: 14
        font.bold: isActive
        elide: Text.ElideRight
        anchors {
            left: icon.right
            verticalCenter: parent.verticalCenter
            leftMargin: 10
        }
    }
}
