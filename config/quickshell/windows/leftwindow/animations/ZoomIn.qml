import QtQuick

Transition {
    ParallelAnimation {
        NumberAnimation {
            property: "scale"
            from: 0.8
            to: 1.0
            duration: 400
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }
}
