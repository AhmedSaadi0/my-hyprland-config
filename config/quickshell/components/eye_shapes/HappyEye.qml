import QtQuick

Item {
    id: root
    property color color: "white"
    property int eyeW: 8
    property bool active: false

    anchors.fill: parent
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
        border.width: 2
        radius: width / 2
    }
}
