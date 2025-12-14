import QtQuick

Rectangle {
    id: browRoot

    property int animDur: 300
    property int angle: 0
    property real yOffset: 0

    radius: 1

    transform: Rotation {
        origin.x: browRoot.width / 2
        origin.y: browRoot.height / 2
        angle: browRoot.angle
        Behavior on angle {
            NumberAnimation {
                duration: browRoot.animDur
                easing.type: Easing.OutBack
            }
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: browRoot.animDur
        }
    }
}
