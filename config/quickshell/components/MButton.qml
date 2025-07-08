// components/MButton.qml

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

import "../themes"

Button {
    id: myCustomButton

    property int cursorShape: Qt.ArrowCursor

    property var textHorizontalAlignment: Text.AlignHCenter
    property var textVerticalAlignment: Text.AlignVCenter
    property bool isActive: false

    property var disabledBackground: Kirigami.Theme.negativeBackgroundColor
    property var downBackground: Kirigami.Theme.hoverColor.darker(1.15)
    property var hoveredBackground: Kirigami.Theme.hoverColor
    property var normalBackground: Kirigami.Theme.activeBackgroundColor // Original value
    property var activeBackground: ThemeManager.selectedTheme.colors.primary

    property var disabledForeground: Kirigami.Theme.highlightColor.darker(0.5)
    property var downForeground: Kirigami.Theme.highlightColor.lighter(1.8)
    // property var hoveredForeground: ThemeManager.selectedTheme.colors.onPrimary
    property var normalForeground: Kirigami.Theme.textColor
    property var activeForeground: ThemeManager.selectedTheme.colors.onPrimary

    property int topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    property var textElide: Text.ElideRight

    contentItem: Text {
        id: buttonTextContent
        font: myCustomButton.font
        text: myCustomButton.text
        horizontalAlignment: myCustomButton.textHorizontalAlignment
        verticalAlignment: myCustomButton.textVerticalAlignment
        elide: myCustomButton.textElide

        color: {
            if (!myCustomButton.enabled) {
                return myCustomButton.disabledForeground;
                // } else if (myCustomButton.down || myCustomButton.pressed) {
                //     return myCustomButton.downForeground;
            } else if (myCustomButton.isActive) {
                return myCustomButton.activeForeground;
                // let bg = myCustomButton.activeBackground;
                // let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                // return luminance > 0.5 ? "black" : "white";
            } else if (myCustomButton.hovered) {
                // return myCustomButton.hoveredForeground;
                let bg = myCustomButton.hoveredBackground;
                let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                return luminance > 0.5 ? "black" : "white";
            } else {
                return myCustomButton.normalForeground;
            }
        }
    }

    background: Rectangle {
        topLeftRadius: myCustomButton.topLeftRadius
        topRightRadius: myCustomButton.topRightRadius
        bottomLeftRadius: myCustomButton.bottomLeftRadius
        bottomRightRadius: myCustomButton.bottomRightRadius

        color: {
            if (!myCustomButton.enabled) {
                return myCustomButton.disabledBackground;
                // } else if (myCustomButton.down || myCustomButton.pressed) {
                //     return myCustomButton.downBackground;
            } else if (myCustomButton.hovered) {
                return myCustomButton.hoveredBackground;
            } else if (myCustomButton.isActive) {
                return myCustomButton.activeBackground;
            } else {
                return myCustomButton.normalBackground;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 400
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        // ربط شكل المؤشر بالخاصية التي أضفناها للزر
        cursorShape: myCustomButton.cursorShape

        // مهم جداً: هذه الخصائص تضمن أن هذه المنطقة لا تتداخل
        // مع وظيفة النقر الخاصة بالزر الأساسي.
        // هي فقط تغير شكل المؤشر وتمرر الأحداث لما تحتها.
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
    }
}
