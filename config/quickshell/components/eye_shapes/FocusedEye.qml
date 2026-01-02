import QtQuick

Item {
    id: root
    property color color: "white"
    property int eyeW: 8
    property int eyeH: 14
    property bool active: false

    anchors.centerIn: parent
    width: eyeW
    height: eyeH

    opacity: active ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: 150
        }
    }

    // جسم العين
    Rectangle {
        id: eyeBody
        anchors.centerIn: parent
        width: root.eyeW * 1.2
        height: root.eyeH * 0.6
        radius: height / 2
        color: "transparent"
        border.color: root.color
        border.width: 2

        SequentialAnimation on height {
            running: root.active
            loops: Animation.Infinite
            NumberAnimation {
                to: root.eyeH * 0.5
                duration: 1200
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                to: root.eyeH * 0.6
                duration: 1200
                easing.type: Easing.InOutSine
            }
        }
    }

    // الحدقة المهتزة
    Rectangle {
        id: pupil
        anchors.centerIn: parent
        width: root.eyeW * 0.4
        height: width
        radius: width / 2
        color: root.color

        SequentialAnimation {
            running: root.active
            loops: Animation.Infinite
            NumberAnimation {
                target: pupil
                property: "anchors.horizontalCenterOffset"
                from: 0
                to: 0.5
                duration: 50
            }
            NumberAnimation {
                target: pupil
                property: "anchors.horizontalCenterOffset"
                from: 0.5
                to: -0.5
                duration: 50
            }
            NumberAnimation {
                target: pupil
                property: "anchors.horizontalCenterOffset"
                from: -0.5
                to: 0
                duration: 50
            }
            PauseAnimation {
                duration: 1000
            }
        }
    }
}
