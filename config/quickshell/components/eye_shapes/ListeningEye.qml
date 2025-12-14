import QtQuick

Item {
    id: root
    property color color: "white"
    property int eyeW: 8
    property bool active: false

    anchors.centerIn: parent
    width: eyeW
    height: width

    opacity: active ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    Rectangle {
        id: micDot
        anchors.centerIn: parent
        width: root.eyeW
        height: root.eyeW
        radius: width / 2
        color: root.color

        // نبض الحجم والشفافية معاً
        SequentialAnimation {
            running: root.active
            loops: Animation.Infinite
            ParallelAnimation {
                NumberAnimation {
                    target: micDot
                    property: "scale"
                    to: 0.7
                    duration: 400
                    easing.type: Easing.OutSine
                }
                NumberAnimation {
                    target: micDot
                    property: "opacity"
                    to: 0.5
                    duration: 400
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: micDot
                    property: "scale"
                    to: 1.1
                    duration: 400
                    easing.type: Easing.OutSine
                }
                NumberAnimation {
                    target: micDot
                    property: "opacity"
                    to: 1.0
                    duration: 400
                }
            }
        }
    }
}
