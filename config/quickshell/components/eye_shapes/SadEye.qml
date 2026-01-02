import QtQuick

Item {
    id: root
    property color color: "white"
    property int eyeW: 8
    property bool active: false

    anchors.fill: parent
    rotation: 180

    opacity: active ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    clip: true
    Rectangle {
        width: root.eyeW
        height: root.eyeW + (root.eyeW / 4)
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        border.color: root.color
        border.width: root.eyeW * 0.2
        radius: width / 2
    }
}
