import QtQuick

Rectangle {
    id: root
    property int eyeR: 4
    property int animDur: 300
    property bool active: true

    anchors.fill: parent
    radius: eyeR
    color: "white"

    opacity: active ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }
    Behavior on radius {
        NumberAnimation {
            duration: animDur
        }
    }
}
