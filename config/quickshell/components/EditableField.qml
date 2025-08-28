// components/EditableField.qml
import QtQuick
import QtQuick.Controls

TextField {
    id: root

    topPadding: 0
    bottomPadding: 0

    property color normalBackground: "transparent"
    property color normalForeground: "white"
    property color borderColor: "gray"
    property int borderSize: 1

    property int topLeftRadius: 8
    property int topRightRadius: 8
    property int bottomLeftRadius: 8
    property int bottomRightRadius: 8

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    color: root.normalForeground

    background: Rectangle {
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius

        color: root.enabled ? root.normalBackground : root.normalBackground.alpha(0.3)

        border.color: root.enabled ? root.borderColor : root.borderColor.alpha(0.3)
        border.width: root.borderSize

        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }
    }
}
