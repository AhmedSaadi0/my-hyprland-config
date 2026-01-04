// components/tab/IconLabel.qml

import QtQuick
import "root:/themes"
import "root:/utils/helpers.js" as Helper

Item {
    id: root

    property string iconText
    property string labelText
    property bool isActive
    property bool isCurrent
    property int currentWidth

    Text {
        id: icon
        text: iconText
        color: {
            if (root.isCurrent) {
                return Helper.getAccurteTextColor(highlightColor);
            } else if (root.isActive) {
                return Helper.getAccurteTextColor(hoverColor);
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
        width: Math.max(0, root.width - icon.width - 25)
        text: labelText
        color: icon.color
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
