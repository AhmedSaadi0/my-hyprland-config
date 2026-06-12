// components/MButton.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "root:/themes"
import "root:/config/ConstValues.js" as Consts

Button {
    id: root

    property int cursorShape: Qt.ArrowCursor

    property string iconText: ""
    property bool showIcon: iconText !== ""
    property bool iconFirst: false
    property alias iconItem: iconTextItem

    property alias textItem: buttonMainText
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

    // -----------------------------------------------------------------
    // ألوان وتأثيرات متوافقة مع معايير Material Design 3 (M3)
    // -----------------------------------------------------------------
    property var disabledBackground: ThemeManager.selectedTheme.colors.onSurface.alpha(0.12)
    property var disabledForeground: ThemeManager.selectedTheme.colors.onSurface.alpha(0.38)

    property var normalBackground: ThemeManager.selectedTheme.colors.surfaceContainer
    property var normalForeground: ThemeManager.selectedTheme.colors.onSurface

    property var activeBackground: ThemeManager.selectedTheme.colors.primary
    property var activeForeground: ThemeManager.selectedTheme.colors.onPrimary

    property var hoveredBackground: root.isActive ? root.activeBackground : root.normalBackground
    property var downBackground: root.isActive ? root.activeBackground : root.normalBackground
    property var hoveredForeground: root.isActive ? root.activeForeground : root.normalForeground
    property var downForeground: root.isActive ? root.activeForeground : root.normalForeground

    property int topLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / Consts.M3_BUTTON_RADIUS_DIVISOR
    property int topRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / Consts.M3_BUTTON_RADIUS_DIVISOR
    property int bottomLeftRadius: ThemeManager.selectedTheme.dimensions.elementRadius / Consts.M3_BUTTON_RADIUS_DIVISOR
    property int bottomRightRadius: ThemeManager.selectedTheme.dimensions.elementRadius / Consts.M3_BUTTON_RADIUS_DIVISOR

    // -----------------------------------------------------------------
    // تأثير الانكماش غير المتماثل (Asymmetric Scale Spring Animation)
    // -----------------------------------------------------------------
    scale: root.down ? 0.95 : 1.0

    Behavior on scale {
        SpringAnimation {
            // صلابة عالية وخمود كامل عند الضغط (استجابة صلبة وفورية)
            // ليونة واهتزاز ناعم عند الإفلات (ارتداد مرن ممتع بصرياً)
            spring: root.down ? 5.0 : 3.2
            damping: root.down ? 1.0 : 0.5
            epsilon: 0.005
        }
    }
    // -----------------------------------------------------------------

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
                    duration: 150
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }
        }

        Text {
            id: buttonMainText
            text: (root.isActive && root.activeText) ? root.activeText : root.originalText
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
                } else {
                    return root.normalForeground;
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
            }
        }
    }

    background: Rectangle {
        id: bgContainer
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius

        color: {
            if (!root.enabled) {
                return root.disabledBackground;
            } else if (root.isActive) {
                return root.activeBackground;
            } else {
                return root.normalBackground;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
            }
        }

        // طبقة التفاعل الشفافة (State Layer)
        Rectangle {
            id: stateLayer
            anchors.fill: parent
            topLeftRadius: bgContainer.topLeftRadius
            topRightRadius: bgContainer.topRightRadius
            bottomLeftRadius: bgContainer.bottomLeftRadius
            bottomRightRadius: bgContainer.bottomRightRadius

            color: root.isActive ? root.activeForeground : root.normalForeground

            opacity: {
                if (!root.enabled) {
                    return 0.0;
                } else if (root.down) {
                    return 0.12;
                } else if (root.hovered) {
                    return 0.08;
                }
                return 0.0;
            }

            // -------------------------------------------------------------
            // سرعات انتقال غير متماثلة (Asymmetric Fade Transitions)
            // -------------------------------------------------------------
            Behavior on opacity {
                NumberAnimation {
                    // دخول سريع جداً عند النقر أو التحويم (85ms) لضمان الفورية والاستجابة
                    // خروج ناعم وتلاشٍ أبطأ عند ترك الزر (200ms) لإعطاء مظهر انسيابي طبيعي
                    duration: (root.hovered || root.down) ? 85 : 200
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
                }
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
