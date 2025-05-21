import QtQuick
import "../../themes"

Item {
    property string iconText
    property string labelText
    property bool isActive
    property int currentWidth
    // property bool isCurrent

    width: currentWidth
    height: parent.height

    Text {
        id: icon
        width: Math.max(7, paintedWidth)
        text: iconText
        color: isActive ? root.textHighlightColor : root.textColor
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
        width: currentWidth - icon.width - 25
        text: labelText
        color: root.textHighlightColor
        font.pixelSize: 14
        font.bold: isActive
        elide: Text.ElideRight
        anchors {
            left: icon.right
            verticalCenter: parent.verticalCenter
            leftMargin: 10
            // right: parent.right
            // rightMargin: 10
        }

        // Behavior on width {
        //     NumberAnimation {
        //         duration: root.animationDuration
        //         easing.type: Easing.OutBack
        //     }
        // }
    }
}
