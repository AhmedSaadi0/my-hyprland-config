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
        // color: isActive ? root.textHighlightColor : root.textColor
        color: {
            if (isActive) {
                let bg = textHighlightColor;
                let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                return luminance > 0.5 ? "black" : "white";
            }

            return root.textColor;
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
        width: currentWidth - icon.width - 25
        text: labelText
        color: {
            if (isActive) {
                let bg = textHighlightColor;
                let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                return luminance > 0.5 ? "black" : "white";
            }

            return root.textColor;
        }
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
