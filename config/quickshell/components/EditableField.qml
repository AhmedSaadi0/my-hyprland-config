// components/EditableField.qml
import QtQuick
import QtQuick.Controls

TextField {
    id: root

    topPadding: 0
    bottomPadding: 0

    leftPadding: 12
    rightPadding: 12

    property var selectedTheme

    property color normalBackground: selectedTheme.colors.topbarBgColorV2
    property color normalForeground: selectedTheme.colors.topbarFgColorV2
    property color borderColor: selectedTheme.colors.secondary
    property int borderSize: 1

    property color focusedBorderColor: borderColor

    property int topLeftRadius: selectedTheme.dimensions.elementRadius
    property int topRightRadius: selectedTheme.dimensions.elementRadius
    property int bottomLeftRadius: selectedTheme.dimensions.elementRadius
    property int bottomRightRadius: selectedTheme.dimensions.elementRadius

    color: root.normalForeground

    placeholderTextColor: Qt.rgba(root.normalForeground.r, root.normalForeground.g, root.normalForeground.b, 0.5)

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    cursorDelegate: Rectangle {
        width: 2
        height: root.height - 10
        color: root.normalForeground
        visible: root.cursorVisible
        anchors.verticalCenter: parent.verticalCenter
    }

    background: Rectangle {
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius

        color: root.enabled ? root.normalBackground : root.normalBackground.alpha(0.3)

        border {
            color: root.activeFocus ? root.focusedBorderColor : root.borderColor
            width: root.activeFocus ? 2 : root.borderSize
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
