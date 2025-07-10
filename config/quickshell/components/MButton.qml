// components/MButton.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

import "root:/themes"

Button {
    id: root

    property int cursorShape: Qt.ArrowCursor

    property string iconText: ""
    property bool showIcon: iconText !== ""

    property var textHorizontalAlignment: showIcon ? Text.AlignRight : Text.AlignHCenter
    property var textVerticalAlignment: Text.AlignVCenter
    property int textPreferredWidth: 3
    property int textLeftMargin: 0
    property int textRightMargin: 0
    property var textElide: Text.ElideRight

    property var iconHorizontalAlignment: Text.AlignHCenter
    property var iconVerticalAlignment: Text.AlignVCenter
    property int iconPreferredWidth: 2
    property int iconLeftMargin: 0
    property int iconRightMargin: 0

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

    contentItem: RowLayout {
        anchors.fill: parent
        Layout.alignment: Qt.AlignVCenter

        Text {
            id: buttonMainText
            text: root.text
            font: root.font
            elide: root.textElide
            horizontalAlignment: root.textHorizontalAlignment
            verticalAlignment: root.textVerticalAlignment
            Layout.fillWidth: true
            Layout.preferredWidth: root.textPreferredWidth

            Layout.leftMargin: root.textLeftMargin
            Layout.rightMargin: root.textRightMargin

            color: {
                if (!root.enabled) {
                    return root.disabledForeground;
                } else if (root.isActive) {
                    return root.activeForeground;
                } else if (root.hovered) {
                    let bg = root.hoveredBackground;
                    let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                    return luminance > 0.5 ? "black" : "white";
                } else {
                    return root.normalForeground;
                }
            }
        }

        Text {
            id: iconTextItem
            visible: root.showIcon
            text: root.iconText
            font.family: ThemeManager.selectedTheme.typography.iconFont
            font.pixelSize: buttonMainText.font.pixelSize
            horizontalAlignment: root.iconHorizontalAlignment
            verticalAlignment: root.iconVerticalAlignment
            color: buttonMainText.color
            Layout.fillWidth: root.showIcon
            Layout.preferredWidth: root.iconPreferredWidth

            Layout.leftMargin: root.iconLeftMargin
            Layout.rightMargin: root.iconRightMargin
        }
    }

    background: Rectangle {
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius

        color: {
            if (!root.enabled) {
                return root.disabledBackground;
                // } else if (myCustomButton.down || myCustomButton.pressed) {
                //     return myCustomButton.downBackground;
            } else if (root.hovered) {
                return root.hoveredBackground;
            } else if (root.isActive) {
                return root.activeBackground;
            } else {
                return root.normalBackground;
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

        cursorShape: root.cursorShape

        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
    }
}
