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
    property bool iconFirst: false

    property var textHorizontalAlignment: {
        if (showIcon) {
            if (iconFirst) {
                return Text.AlignLeft;
            }
            return Text.AlignRight;
        }
        return Text.AlignHCenter;
    }
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
    property bool showTooltip: false
    property string originalText: text
    property string activeText: ""

    // الألوان
    property var disabledBackground: Kirigami.Theme.negativeBackgroundColor
    // جعل لون الضغط أغمق قليلاً من لون التحويم
    property var downBackground: Qt.darker(root.hoveredBackground, 1.2)
    property var hoveredBackground: Kirigami.Theme.hoverColor
    property var normalBackground: Kirigami.Theme.activeBackgroundColor
    property var activeBackground: ThemeManager.selectedTheme.colors.primary

    property var disabledForeground: Kirigami.Theme.highlightColor.darker(0.5)
    property var downForeground: Kirigami.Theme.highlightColor.lighter(1.8)
    property var normalForeground: Kirigami.Theme.textColor
    property var activeForeground: ThemeManager.selectedTheme.colors.onPrimary

    property int topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius
    property int bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    // ---------------------------------------------------------
    // 1. إضافة تأثير الانكماش (Scale Animation)
    // ---------------------------------------------------------
    // ينكمش الزر إلى 92% من حجمه عند الضغط
    scale: root.down ? 0.92 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
    // ---------------------------------------------------------

    ToolTip.text: root.text
    ToolTip.visible: root.hovered && root.showTooltip
    ToolTip.delay: 500

    contentItem: RowLayout {
        anchors.fill: parent
        Layout.alignment: Qt.AlignVCenter
        spacing: 0

        layoutDirection: root.iconFirst ? Qt.LeftToRight : Qt.RightToLeft

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

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

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
                buttonMainText.text = root.originalText;
                if (!root.enabled) {
                    return root.disabledForeground;
                } else if (root.isActive) {
                    if (root.activeText) {
                        buttonMainText.text = root.activeText;
                    }
                    return root.activeForeground;
                    // إضافة تغيير لون النص عند الضغط
                } else if (root.down) {
                    return root.downForeground;
                } else if (root.hovered) {
                    let bg = root.hoveredBackground;
                    // حساب التباين للون الخط
                    if (bg && typeof bg.r !== 'undefined') {
                        let luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b;
                        return luminance > 0.5 ? "black" : "white";
                    }
                    return "white"; // Fallback
                } else {
                    return root.normalForeground;
                }
            }

            // إضافة انميشن لتغيير اللون
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }

    background: Rectangle {
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius

        // ---------------------------------------------------------
        // 2. تصحيح منطق الألوان لتفعيل لون الضغط
        // ---------------------------------------------------------
        color: {
            if (!root.enabled) {
                return root.disabledBackground;
            } else if (root.down) {
                // تفعيل لون الخلفية عند الضغط
                return root.downBackground;
            } else if (root.isActive) {
                return root.activeBackground;
            } else if (root.hovered) {
                return root.hoveredBackground;
            } else {
                return root.normalBackground;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        // إضافة حدود ناعمة عند التركيز (اختياري)
        // border.width: root.activeFocus ? 2 : 0
        // border.color: ThemeManager.selectedTheme.colors.primary.alpha(0.5)
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.cursorShape
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
    }
}
