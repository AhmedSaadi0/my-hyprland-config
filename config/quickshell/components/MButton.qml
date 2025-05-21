import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

import "../themes"

Button {
    id: myCustomButton

    property var textHorizontalAlignment: Text.AlignHCenter
    property var textVerticalAlignment: Text.AlignVCenter

    property var disabledBackground: Kirigami.Theme.negativeBackgroundColor
    property var downBackground: Qt.darker(Kirigami.Theme.hoverColor, 1.15)
    property var hoveredBackground: Kirigami.Theme.hoverColor
    property var normalBackground: Kirigami.Theme.activeBackgroundColor

    property var disabledForeground: Kirigami.Theme.highlightColor.darker(0.5)
    property var downForeground: Kirigami.Theme.highlightColor.lighter(1.8)
    property var hoveredForeground: Kirigami.Theme.highlightColor
    property var normalForeground: Kirigami.Theme.textColor

    layer.enabled: true
    layer.effect: Shadow {
        alpha: 0.1
    }

    contentItem: Text {
        id: buttonTextContent
        font: myCustomButton.font
        text: myCustomButton.text

        horizontalAlignment: myCustomButton.textHorizontalAlignment
        verticalAlignment: myCustomButton.textVerticalAlignment

        color: {
            if (!myCustomButton.enabled) {
                return myCustomButton.disabledForeground;
            } else if (myCustomButton.down || myCustomButton.pressed) {
                return myCustomButton.downForeground;
            } else if (myCustomButton.hovered) {
                let bg = myCustomButton.hoveredBackground;
                let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                return luminance > 0.5 ? "black" : "white";
            } else {
                return myCustomButton.normalForeground;
            }
        }
    }

    background: Rectangle {
        radius: ThemeManager.selectedTheme.dimensions.elementRadius

        color: {
            if (!myCustomButton.enabled) {
                return myCustomButton.disabledBackground;
            } else if (myCustomButton.down || myCustomButton.pressed) {
                return myCustomButton.downBackground;
            } else if (myCustomButton.hovered) {
                return myCustomButton.hoveredBackground;
            } else {
                return myCustomButton.normalBackground;
            }
        }
        // border.color: myCustomButton.hovered ? "red" : "transparent" // Visual feedback

        border.color: myCustomButton.visualFocus ? Kirigami.Theme.focusColor : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 150 // Short duration for quick feedback
                // easing.type: Easing.InOutCubic
            }
        }
    }
}
