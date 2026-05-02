// StyledComboBox.qml

import QtQuick
import QtQuick.Controls

import "root:/themes"

ComboBox {
    id: root

    property color componentColor: ThemeManager.selectedTheme.colors.topbarBgColorV2
    property color componentBorderColor: ThemeManager.selectedTheme.colors.secondary.alpha(0.4)

    property color componentActiveBorderColor: ThemeManager.selectedTheme.colors.primary
    property color componentOpenColor: ThemeManager.selectedTheme.colors.primary.alpha(0.4)

    property int componentBorderWidth: 1
    property int componentRadius: ThemeManager.selectedTheme.dimensions.elementRadius

    property string indicatorIcon: ""
    property string indicatorFontFamily: ThemeManager.selectedTheme.typography.iconFont

    background: Rectangle {
        id: comboBackground
        radius: root.componentRadius
        border.width: root.componentBorderWidth

        border.color: root.hovered || root.activeFocus ? root.componentActiveBorderColor : root.componentBorderColor

        color: root.popup.visible ? root.componentOpenColor : root.componentColor
    }

    contentItem: Text {
        text: root.displayText
        font: root.font
        color: ThemeManager.selectedTheme.colors.topbarFgColorV2
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
        rightPadding: indicatorIcon.width + 10
        leftPadding: 8

        function positionToRectangle(pos) {
            return Qt.rect(0, 0, 0, 0);
        }
    }

    indicator: Text {
        id: indicatorIcon
        text: root.indicatorIcon
        color: ThemeManager.selectedTheme.colors.topbarFgColorV2.alpha(0.7)

        font {
            family: root.indicatorFontFamily
            pixelSize: 14
        }

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10

        rotation: root.popup.visible ? 180 : 0

        Behavior on rotation {
            RotationAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Prevent wheel events from changing selection when popup is closed
    WheelHandler {
        enabled: !root.popup.visible
        onWheel: (event) => {
            event.accepted = true;
        }
    }
}
